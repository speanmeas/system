import os
import sys

sys.path.append(os.getcwd())

import re
from datetime import datetime
from typing import *

from fastapi import *
from pydantic import *

from server.Environment import *
from server.utilities.Response import R
from server.utilities.Database import database as db


router = APIRouter()


# ============================================================================
# Request/Response Models
# ============================================================================


class PlutoFilterCondition(BaseModel):
    """Individual filter condition for a column"""

    column: str
    condition: str  # Contains, Equals, StartsWith, EndsWith, etc.
    value: Any


class PlutoSortCondition(BaseModel):
    """Sort condition for a column"""

    column: str
    ascending: bool = True


class PlutoPaginationRequest(BaseModel):
    """Request model for PlutoGrid lazy pagination"""

    collection: str = Field(..., description="MongoDB collection name")
    page: int = Field(1, ge=1, description="Current page number (1-based)")
    page_size: int = Field(1000, ge=1, le=10000, description="Number of rows per page")
    filters: List[PlutoFilterCondition] = Field(default_factory=list, description="Filter conditions")
    sort: Optional[PlutoSortCondition] = Field(None, description="Sort condition")
    search_query: Optional[str] = Field(None, description="Global search query")


class PlutoCellData(BaseModel):
    """Cell data for PlutoGrid"""

    value: Any


class PlutoRowData(BaseModel):
    """Row data for PlutoGrid"""

    _id: str
    cells: Dict[str, Any]


class PlutoPaginationResponse(BaseModel):
    """Response model for PlutoGrid lazy pagination"""

    total_page: int
    total_count: int
    current_page: int
    page_size: int
    rows: List[Dict[str, Any]]


# ============================================================================
# Helper Functions
# ============================================================================


def build_filter_query(filters: List[PlutoFilterCondition], search_query: Optional[str] = None, searchable_columns: Optional[List[str]] = None) -> Dict:
    """Build MongoDB filter query from PlutoGrid filter conditions"""
    and_conditions = [{"deleted_at": None}]  # Soft delete filter

    # Handle specific column filters
    for f in filters:
        if f.column and f.value is not None:
            condition = f.condition.lower()

            if condition == "contains":
                and_conditions.append({f.column: {"$regex": re.escape(str(f.value)), "$options": "i"}})
            elif condition == "equals":
                and_conditions.append({f.column: f.value})
            elif condition == "startswith":
                and_conditions.append({f.column: {"$regex": f"^{re.escape(str(f.value))}", "$options": "i"}})
            elif condition == "endswith":
                and_conditions.append({f.column: {"$regex": f"{re.escape(str(f.value))}$", "$options": "i"}})
            elif condition == "greaterthan":
                and_conditions.append({f.column: {"$gt": f.value}})
            elif condition == "greaterthanorequalto":
                and_conditions.append({f.column: {"$gte": f.value}})
            elif condition == "lessthan":
                and_conditions.append({f.column: {"$lt": f.value}})
            elif condition == "lessthanorequalto":
                and_conditions.append({f.column: {"$lte": f.value}})
            else:
                # Default to contains for unknown filter types
                and_conditions.append({f.column: {"$regex": re.escape(str(f.value)), "$options": "i"}})

    # Handle global search query
    if search_query and searchable_columns:
        or_conditions = []
        for col in searchable_columns:
            or_conditions.append({col: {"$regex": re.escape(search_query), "$options": "i"}})
        if or_conditions:
            and_conditions.append({"$or": or_conditions})

    return {"$and": and_conditions}


def build_sort_query(sort: Optional[PlutoSortCondition]) -> List[tuple]:
    """Build MongoDB sort query from PlutoGrid sort condition"""
    if sort and sort.column:
        return [(sort.column, 1 if sort.ascending else -1)]
    return [("created_at", -1)]  # Default sort by created_at desc


def format_document(doc: Dict, columns: Optional[List[str]] = None) -> Dict[str, Any]:
    """Format MongoDB document for PlutoGrid response"""
    result = {"_id": str(doc.get("_id", ""))}

    # Format cells
    cells = {}
    for key, value in doc.items():
        if key == "_id":
            continue
        # Format datetime values
        if isinstance(value, datetime):
            cells[key] = value.strftime("%Y-%m-%d %H:%M:%S")
        else:
            cells[key] = value

    result["cells"] = cells
    return result


# ============================================================================
# API Endpoints
# ============================================================================


@router.post("/lazy-pagination", deprecated=False)
async def lazy_pagination(input: PlutoPaginationRequest):
    """
    Fetch paginated data for PlutoGrid lazy pagination.

    Supports:
    - Pagination (page, page_size)
    - Column filtering
    - Column sorting
    - Global search
    """
    try:
        collection = input.collection

        # Validate collection exists (optional security check)
        # You may want to whitelist allowed collections
        allowed_collections = ["c_room", "c_booking", "c_customer", "c_product", "c_order", "c_user", "c_category"]
        if collection not in allowed_collections:
            return R(400, f"Collection '{collection}' not allowed")

        # Build filter query
        # Get sample document to determine searchable columns
        sample = await db[collection].find_one({"deleted_at": None})
        searchable_columns = None
        if sample:
            searchable_columns = [k for k in sample.keys() if k not in ["_id", "deleted_at", "created_at", "updated_at"]]

        filter_query = build_filter_query(input.filters, input.search_query, searchable_columns)

        # Build sort query
        sort_query = build_sort_query(input.sort)

        # Calculate skip
        skip = (input.page - 1) * input.page_size

        # Get total count for pagination
        total_count = await db[collection].count_documents(filter_query)
        total_page = (total_count + input.page_size - 1) // input.page_size  # Ceiling division

        # Fetch paginated data
        cursor = db[collection].find(filter_query).sort(sort_query).skip(skip).limit(input.page_size)

        documents = await cursor.to_list(length=None)

        # Format documents for PlutoGrid
        rows = [format_document(doc) for doc in documents]

        return {
            "total_page": max(1, total_page),
            "total_count": total_count,
            "current_page": input.page,
            "page_size": input.page_size,
            "rows": rows,
        }

    except Exception as e:
        return R(500, f"server error: {str(e)}")


@router.post("/columns", deprecated=False)
async def get_columns(collection: str = Body(..., embed=True)):
    """
    Get column information for a collection.
    Useful for dynamically generating PlutoGrid columns.
    """
    try:
        # Get sample document
        sample = await db[collection].find_one({"deleted_at": None})

        if not sample:
            return {"columns": []}

        columns = []
        for key, value in sample.items():
            if key == "_id":
                continue

            # Determine column type based on value
            if isinstance(value, bool):
                col_type = "boolean"
            elif isinstance(value, int):
                col_type = "number"
            elif isinstance(value, float):
                col_type = "number"
            elif isinstance(value, datetime):
                col_type = "datetime"
            else:
                col_type = "text"

            columns.append(
                {
                    "field": key,
                    "title": key.replace("_", " ").title(),
                    "type": col_type,
                }
            )

        return {"columns": columns}

    except Exception as e:
        return R(500, f"server error: {str(e)}")


@router.post("/export", deprecated=False)
async def export_data(input: PlutoPaginationRequest):
    """
    Export all filtered data (not paginated) for download.
    """
    try:
        collection = input.collection

        # Get searchable columns
        sample = await db[collection].find_one({"deleted_at": None})
        searchable_columns = None
        if sample:
            searchable_columns = [k for k in sample.keys() if k not in ["_id", "deleted_at", "created_at", "updated_at"]]

        # Build queries
        filter_query = build_filter_query(input.filters, input.search_query, searchable_columns)
        sort_query = build_sort_query(input.sort)

        # Fetch all matching data
        cursor = db[collection].find(filter_query).sort(sort_query)

        documents = await cursor.to_list(length=None)
        rows = [format_document(doc) for doc in documents]

        return {
            "total_count": len(rows),
            "rows": rows,
        }

    except Exception as e:
        return R(500, f"server error: {str(e)}")


if __name__ == "__main__":
    os.system("python server/Main.py")
