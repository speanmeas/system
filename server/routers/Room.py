import os
import sys

sys.path.append(os.getcwd())


import re
import json


from fastapi import *
from typing import *
from pydantic import *

from io import BytesIO
from PIL import Image
from datetime import datetime
from bson import ObjectId, json_util
from rich import print as pprint


from server.Environment import *
from server.utilities.Response import R
from server.utilities.Converter import converter as cvt
from server.utilities.Token import token as tk
from server.utilities.Storage import storage as s3
from server.utilities.Database import database as db


router = APIRouter()


# collection name
COLLECTION = "c_room"


class Room_Column_ID(BaseModel):
    id: str | None = Field(None, examples=[None], alias="_id")


class Room_Column_Data(BaseModel):
    name: str | None = Field(None, examples=[None])
    type: str | None = Field(None, examples=[None])
    ac_or_fan: str | None = Field(None, examples=[None])
    capacity: int | None = Field(None, examples=[None], ge=0)
    price: float | None = Field(None, examples=[None], ge=0)
    status: str | None = Field(None, examples=[None])


class Room_Column_Image(BaseModel):
    image_1: str | None = Field(None, examples=[None])
    image_2: str | None = Field(None, examples=[None])


class Room_Column_DateTime(BaseModel):
    created_at: datetime | None = Field(None, examples=[None])
    updated_at: datetime | None = Field(None, examples=[None])
    deleted_at: datetime | None = Field(None, examples=[None])


class Room_Column_Sortable(Room_Column_Data, Room_Column_DateTime):
    pass


##########


class Room_Create(Room_Column_Data):
    pass


class Room_Read(BaseModel):
    query: str | None = Field(None, examples=[None])
    sort_by: Literal[*Room_Column_Sortable.model_fields.keys()] | None = Field(None, examples=[None])
    sort_order: Literal[-1, 1] | None = Field(None, examples=[None])
    offset: int | None = Field(None, examples=[None], ge=0)
    limit: int | None = Field(None, examples=[None], ge=1, le=10000)


class Room_Refer(BaseModel):
    column: Literal[*Room_Column_Sortable.model_fields.keys()] = Field(..., examples=[None])


class Room_Update(Room_Column_Data, Room_Column_ID):
    pass


# special case
class Room_Upload(BaseModel):
    id: str = Field(..., examples=[""], alias="_id")
    column: Literal[*Room_Column_Image.model_fields.keys()] = Field(..., examples=[None])
    image_data: UploadFile = File(...)


class Room_Delete(Room_Column_ID):
    pass


# * OK
@router.post("/create", deprecated=False)
async def create(input: Room_Create):
    try:

        # prepare data
        data = {
            **input.model_dump(),
            **Room_Column_Image().model_dump(),
            "created_at": datetime.now(),
            "updated_at": None,
            "deleted_at": None,
        }

        # insert data
        await db[COLLECTION].insert_one(data)

        return R(200, "create successfully")

    except Exception:
        return R(500, "server error")


@router.post("/count")
async def count():
    try:
        # get total count of non-deleted records
        total = await db[COLLECTION].count_documents({"deleted_at": None})

        return total

    except Exception:
        return R(500, "server error")


# * OK
@router.post("/read", deprecated=False)
async def read(input: Room_Read):
    try:

        # search
        search = (
            await db[COLLECTION]
            .find(
                {
                    "$and": [
                        {"deleted_at": None} if not input.query else {"$or": [{c: {"$regex": re.escape(input.query), "$options": "i"}} for c in Room_Create.model_fields.keys()]},
                    ]
                }
            )
            .sort(input.sort_by or "created_at", input.sort_order or 1)
            .skip(input.offset or 0)
            .limit(input.limit or 1000)
            .to_list(length=None)
        )

        # convert to flutter list<map<string,string>>
        for item in search:
            item["_id"] = str(item["_id"])
            item["created_at"] = item.get("created_at", None) and item["created_at"].strftime("%Y-%m-%d %H:%M:%S") or None
            item["updated_at"] = item.get("updated_at", None) and item["updated_at"].strftime("%Y-%m-%d %H:%M:%S") or None
            item["deleted_at"] = item.get("deleted_at", None) and item["deleted_at"].strftime("%Y-%m-%d %H:%M:%S") or None

        return search

    except Exception:
        return R(500, "server error")


@router.post("/refer", deprecated=False)
async def refer(data: Room_Refer):
    try:

        # get distinct values
        value = await db[COLLECTION].distinct(  # distinct = get unique values
            data.column,
            {
                "deleted_at": None,  # eq = equal
                data.column: {"$ne": None, "$nin": [""]},  # ne = not equal, nin = not in
            },
        )

        return value

    except Exception:
        return R(500, "server error")


@router.post("/update", deprecated=False)
async def update(data: Room_Update):
    try:
        # validate id
        if not data.id or data.id == "" or not ObjectId.is_valid(data.id):
            return R(400, "invalid id")

        # validate room exist
        exist = await db[COLLECTION].find_one({"_id": ObjectId(data.id)})
        if not exist:
            return R(400, "not found")

        # update room
        for k, v in data.model_dump().items():
            if v is not None:
                print(k, v)
                await db[COLLECTION].update_one(
                    {"_id": ObjectId(data.id)},
                    {
                        "$set": {
                            k: v,
                            "updated_at": datetime.now(),
                        }
                    },
                )

        return R(200, "update success")
    except Exception:
        return R(500, "server error")


# * OK
@router.post("/upload", deprecated=False)
async def upload_image(data: Room_Upload = Form(...)):
    try:

        # validate id
        if not data.id or data.id == "" or not ObjectId.is_valid(data.id):
            return R(400, "invalid id")

        # validate column
        if not data.column or data.column == "" or data.column not in Room_Column_Image.model_fields.keys():
            return R(400, "invalid column name")

        # validate room
        exist = await db[COLLECTION].find_one({"_id": ObjectId(data.id)})
        if not exist:
            return R(404, "room not found")

        # validate image size
        content = await image_data.read()
        if len(content) > 10 * 1024 * 1024 or len(content) <= 0:
            return R(400, "image size must be less than 10 MB")

        # prepare image name and path
        date_time = datetime.now().strftime("%Y%m%d%H%M%S%f")
        access_token = tk.gen(16)
        image_ext = "png"  # convert all images to png format

        image_name_new = f"{date_time}_{access_token}.{image_ext}"
        print(f"image_name : {image_name_new}")

        # delete old image file if exists
        image_name_old = exist.get(data.column)
        if image_name_old:
            if s3.object_exists(MINIO_BUCKET_PUBLIC, image_name_old):
                s3.remove_object(MINIO_BUCKET_PUBLIC, image_name_old)

        # convert image to png format
        image = Image.open(BytesIO(content))
        image_buffer = BytesIO()
        image.save(image_buffer, format="PNG")
        image_buffer.seek(0)

        # upload new image file
        s3.put_object(
            bucket_name=MINIO_BUCKET_PUBLIC,  # bucket name
            object_name=f"images/{image_name_new}",  # file name in bucket
            data=image_buffer,  # file-like object
            length=image_buffer.getbuffer().nbytes,  # size of the data in bytes
        )

        # add image name to database
        await db[COLLECTION].update_one(
            {"_id": ObjectId(data.id)},
            {"$set": {data.column: image_name_new, "updated_at": datetime.now()}},
        )

        # generate thumbnails
        cvt.to_thumbnail(f"images/{image_name_new}", 100)
        cvt.to_thumbnail(f"images/{image_name_new}", 200)

        return R(200, "uploaded successfully")
    except Exception:
        return R(500, "server error")


# * OK
@router.post("/delete", deprecated=False)
async def delete_row(data: Room_Delete):
    try:

        # check if id is valid
        if not ObjectId.is_valid(data.id):
            return R(400, "invalid id")

        # check if id exists in database
        exist = await db[COLLECTION].find_one({"_id": ObjectId(data.id)})
        if not exist:
            return R(400, "room not found")

        # soft delete a row
        await db[COLLECTION].update_one(
            {"_id": ObjectId(data.id)},
            {"$set": {"deleted_at": datetime.now()}},
        )

        return R(200, "deleted successfully")

    except Exception:
        return R(500, "server error")


if __name__ == "__main__":
    os.system("python server/Main.py")
