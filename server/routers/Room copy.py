import re
import os
import sys
import json


from fastapi import *
from typing import *
from io import BytesIO
from PIL import Image
from datetime import datetime
from bson import ObjectId, json_util


from Environment import *
from utilities.Converter import converter as cvt
from utilities.Response import R
from utilities.Token import token as tk
from utilities.Storage import storage as s3
from utilities.Database import database as db

sys.path.append(os.getcwd())


router = APIRouter()

# collection name
COLLECTION = "c_room"

# columns data
COLLUMN_STRINGS = [
    "Room Number",
    "Room Type",
    "AC or Fan",
    "Capacity",
    "Price",
    "Status",
]

# columns image
COLLUMN_IMAGES = [
    "Image 1",
    "Image 2",
]


# * OK
@router.post("/create", deprecated=False)
async def create(
    data: Optional[dict] = Body(None, examples=[{c: "" for c in COLLUMN_STRINGS}]),
):
    try:

        # set default data
        if not data:
            data = {}

        # validate columns
        for k in data.keys():
            if k not in COLLUMN_STRINGS:
                return R(400, "invalid column name")

        # prepare data
        data = {
            **{k: data.get(k) for k in COLLUMN_STRINGS},
            **{c: None for c in COLLUMN_IMAGES},
            "created_at": datetime.now(),
            "updated_at": None,
            "deleted_at": None,
        }

        # insert data
        await db[COLLECTION].insert_one({**data})

        return R(200, "create success")

    except Exception:
        return R(500, "internal server error")


# * OK
@router.post("/read", deprecated=False)
async def read(
    data: Optional[dict] = Body(
        None,
        examples=[
            {
                "query": "",
                "sort_by": "",
                "sort_order": "",
                "offset": "",
                "limit": "",
            }
        ],
    )
):
    try:

        # set default data
        if not data:
            data = {}

        # validate data
        query = "" if data.get("query") is None or data.get("query") == "" else data.get("query")
        sort_by = "created_at" if data.get("sort_by") is None or data.get("sort_by") == "" else data.get("sort_by")
        sort_order = 1 if data.get("sort_order") is None or data.get("sort_order") == "" else data.get("sort_order")
        offset = 0 if data.get("offset") is None or data.get("offset") == "" else data.get("offset")
        limit = 10 if data.get("limit") is None or data.get("limit") == "" else data.get("limit")

        # search
        search = (
            await db[COLLECTION]
            .find(
                {
                    "$and": [
                        {"$or": [{c: {"$regex": re.escape(query), "$options": "i"}} for c in [*COLLUMN_STRINGS]]},
                        {"deleted_at": {"$eq": None}},
                    ]
                }
            )
            .sort(sort_by, int(sort_order))
            .skip(int(offset))
            .limit(int(limit))
            .to_list(length=None)
        )

        return json.loads(json_util.dumps(search))

    except Exception:
        return R(500, "internal server error")


@router.post("/refer", deprecated=False)
async def refer(
    data: Optional[dict] = Body(None, examples=[{"column": "room_number"}]),
):
    try:

        # set default data
        if not data:
            return R(400, "invalid data")

        # validate column
        if not data.get("column") or data.get("column") == "" or data.get("column") not in COLLUMN_STRINGS:
            return R(400, "invalid column name")

        # get distinct values
        value = await db[COLLECTION].distinct(  # distinct = get unique values
            data.get("column"),
            {
                "deleted_at": None,  # eq = equal
                data.get("column"): {"$ne": None, "$nin": [""]},  # ne = not equal, nin = not in
            },
        )

        # sort
        reference = sorted(
            {str(v).strip() for v in value if str(v).strip()},
            key=lambda x: x.lower(),
        )

        return reference

    except Exception:
        return R(500, "internal server error")


@router.post("/update", deprecated=False)
async def update(
    data: Optional[dict] = Body(None, examples=[{c: "" for c in ["id", *COLLUMN_STRINGS]}]),
):
    try:

        # set default data
        if not data:
            data = {}

        # validate id
        if not data.get("id") or data.get("id") == "" or not ObjectId.is_valid(data.get("id")):
            return R(400, "invalid id")

        # validate columns
        for k in data.keys() - ["id"]:
            if k not in COLLUMN_STRINGS:
                return R(400, "invalid column name")

        exist = await db[COLLECTION].find_one({"_id": ObjectId(data.get("id"))})
        if not exist:
            return R(400, "room not found")

        for k in data.keys() - ["id"]:
            if data.get(k) and data.get(k) != "":
                print(k)
                await db[COLLECTION].update_one(
                    {"_id": ObjectId(data.get("id"))},
                    {"$set": {k: data.get(k), "updated_at": datetime.now()}},
                )

        return 1
    except Exception:
        return Response(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


# * OK
@router.post("/upload", deprecated=False)
async def upload_image(
    data: Optional[dict] = Body(None, examples=[{"id": "", "column": ""}]),
    image_data: Optional[UploadFile] = File(None),
):
    try:

        # validate data
        if not data:
            return R(400, "invalid data")

        # validate id
        if not data.get("id") or data.get("id") == "" or not ObjectId.is_valid(data.get("id")):
            return R(400, "invalid id")

        # validate column
        if not data.get("column") or data.get("column") == "" or data.get("column") not in COLLUMN_IMAGES:
            return R(400, "invalid column name")

        # validate room
        exist = await db[COLLECTION].find_one({"_id": ObjectId(data.get("id"))})
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
        image_name_old = exist.get(data.get("column"))
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
            {"_id": ObjectId(data.get("id"))},
            {"$set": {data.get("column"): image_name_new, "updated_at": datetime.now()}},
        )

        # generate thumbnails
        cvt.to_thumbnail(f"images/{image_name_new}", 100)
        cvt.to_thumbnail(f"images/{image_name_new}", 200)

        return 1
    except Exception:
        return R(500, "internal server error")


# * OK
@router.post("/delete", deprecated=False)
async def delete_row(
    data: Optional[dict] = Body(None, examples=[{"id": ""}]),
):
    try:

        # validate data
        if not data:
            return R(400, "data is required")

        # check if id exists in request body
        if not data.get("id") or data.get("id") == "":
            return R(400, "id is required")

        # check if id is valid
        if not ObjectId.is_valid(data.get("id")):
            return R(400, "invalid id")

        # check if id exists in database
        exist = await db[COLLECTION].find_one({"_id": ObjectId(data.get("id"))})
        if not exist:
            return R(400, "room not found")

        # soft delete a row
        await db[COLLECTION].update_one(
            {"_id": ObjectId(data.get("id"))},
            {"$set": {"deleted_at": datetime.now()}},
        )

        return R(200, "deleted success")

    except Exception:
        return R(500, "internal server error")


if __name__ == "__main__":
    os.system("python Main.py")
