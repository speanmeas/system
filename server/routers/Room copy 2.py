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
from server.utilities.Converter import converter as cvt
from server.utilities.Response import R
from server.utilities.Token import token as tk
from server.utilities.Storage import storage as s3
from server.utilities.Database import database as db


router = APIRouter()


# collection name
COLLECTION = "c_room"


class Room(BaseModel):

    id: str | None = Field(None, examples=[None])

    room_number: str | None = Field(None, examples=[None])
    room_type: str | None = Field(None, examples=[None])
    ac_or_fan: str | None = Field(None, examples=[None])
    capacity: int | None = Field(None, examples=[None], ge=0)
    price: float | None = Field(None, examples=[None], ge=0)
    status: str | None = Field(None, examples=[None])

    image_1: str | None = Field(None, examples=[None])
    image_2: str | None = Field(None, examples=[None])

    created_at: datetime | None = Field(None, examples=[None])
    updated_at: datetime | None = Field(None, examples=[None])
    deleted_at: datetime | None = Field(None, examples=[None])


class Room_Refer(BaseModel):
    column: Literal[*Room.model_fields.keys()] | None = Field(None, examples=[None])


class Room_Query(BaseModel):
    query: str | None = Field(None, examples=[None])
    sort_by: Literal[*Room.model_fields.keys()] | None = Field(None, examples=[None])
    sort_order: Literal[-1, 1] | None = Field(None, examples=[None])
    offset: int | None = Field(None, examples=[None], ge=0)
    limit: int | None = Field(None, examples=[None], ge=1)


# * OK
@router.post("/create", deprecated=False)
async def create(
    room: Room | None,
):
    try:

        # set default data
        if not room:
            room = Room()

        room.created_at = datetime.now()

        # insert data
        await db[COLLECTION].insert_one(room.model_dump())

        return R(200, "create success")

    except Exception:
        return R(500, "internal server error")


# * OK
@router.post("/read", deprecated=False)
async def read(
    room: Room_Query | None = Body(None),
):
    try:

        # set default data
        if not room:
            room = Room_Query()

        # validate data
        query = room.query or ""
        sort_by = room.sort_by or "created_at"
        sort_order = room.sort_order or 1
        offset = room.offset or 0
        limit = room.limit or 1000

        # search
        search = (
            await db[COLLECTION]
            .find(
                {
                    "$and": [
                        {"$or": [{c: {"$regex": re.escape(query), "$options": "i"}} for c in Room_Create.model_fields.keys()]},
                        {"deleted_at": None},
                    ]
                }
            )
            .sort(sort_by, sort_order)
            .skip(offset)
            .limit(limit)
            .to_list(length=None)
        )

        return json.loads(json_util.dumps(search))

    except Exception:
        return R(500, "internal server error")


@router.post("/refer", deprecated=False)
async def refer(
    room: Room_Refer | None = Body(None),
):
    try:

        # set default data
        if not room:
            return R(400, "invalid data")

        # get distinct values
        value = await db[COLLECTION].distinct(  # distinct = get unique values
            room.column,
            {
                "deleted_at": None,  # eq = equal
                room.column: {"$ne": None, "$nin": [""]},  # ne = not equal, nin = not in
            },
        )

        # sort
        reference = sorted(
            {v for v in value},
            key=lambda x: str(x).lower(),
        )

        return reference

    except Exception:
        return R(500, "internal server error")


@router.post("/update", deprecated=False)
async def update():
    try:

        # # set default data
        # if not data:
        #     data = {}

        # # validate id
        # if not data.get("id") or data.get("id") == "" or not ObjectId.is_valid(data.get("id")):
        #     return R(400, "invalid id")

        # # validate columns
        # for k in data.keys() - ["id"]:
        #     if k not in COLUMN_STRINGS:
        #         return R(400, "invalid column name")

        # exist = await db[COLLECTION].find_one({"_id": ObjectId(data.get("id"))})
        # if not exist:
        #     return R(400, "room not found")

        # for k in data.keys() - ["id"]:
        #     if data.get(k) and data.get(k) != "":
        #         print(k)
        #         await db[COLLECTION].update_one(
        #             {"_id": ObjectId(data.get("id"))},
        #             {"$set": {k: data.get(k), "updated_at": datetime.now()}},
        #         )

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
        if not data.get("column") or data.get("column") == "" or data.get("column") not in COLUMN_IMAGES:
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
    os.system("python server/Main.py")
