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


from Environment import *
from utilities.Response import R
from utilities.Converter import converter as cvt
from utilities.Token import token as tk
from utilities.Storage import storage as s3
from utilities.Database import database as db


router = APIRouter()


COLLECTION = "collection_room"


COLUMNS = ["name", "type", "capacity", "price", "status"]


@router.post("/create", deprecated=False)
async def create(
    name_: str | None = Form(None, examples=[""], alias="name"),
    type_: str | None = Form(None, examples=[""], alias="type"),
    capacity_: int | None = Form(None, examples=[""], alias="capacity"),
    price_: float | None = Form(None, examples=[""], alias="price"),
    status_: str | None = Form(None, examples=[""], alias="status"),
):
    try:

        # prepare data
        data = {
            "name": name_,
            "type": type_,
            "capacity": capacity_,
            "price": price_,
            "status": status_,
            "created_at": datetime.now(),
        }

        # insert data
        await db[COLLECTION].insert_one(data)

        return R(200, "create successfully")

    except Exception:
        return R(500, "server error")


@router.post("/read", deprecated=False)
async def read(
    column_: Literal[*COLUMNS] | None = Form(None, alias="column"),
    query_: str | None = Form(None, examples=[""], alias="query"),
    order_: Literal[-1, 1] | None = Form(None, examples=[""], alias="order"),
    offset_: int | None = Form(None, examples=[""], ge=0, alias="offset"),
    limit_: int | None = Form(None, examples=[""], ge=1, le=10000, alias="limit"),
):
    try:

        query = {"deleted_at": {"$eq": "" or None}}

        if column_:
            query["$and"] = [
                {column_: {"$regex": re.escape(query_ or ""), "$options": "i"}},
                {"deleted_at": None},
            ]

        search = (
            await db[COLLECTION]  #
            .find(query)
            .sort(
                column_ or "created_at",
                order_ or 1,
            )
            .skip(offset_ or 0)
            .limit(limit_ or 100)
            .to_list(length=None)
        )

        return json.loads(json_util.dumps(search))

    except Exception:
        return R(500, "server error")


@router.post("/refer", deprecated=False)
async def refer(
    column_: Literal[*COLUMNS] = Form(..., alias="column"),
):
    try:

        # get distinct values
        unique = await db[COLLECTION].distinct(  # distinct = get unique values
            column_,
            {
                "deleted_at": None,  # eq = equal
                column_: {"$ne": None, "$nin": [""]},  # ne = not equal, nin = not in
            },
        )

        return json.loads(json_util.dumps(unique))

    except Exception:
        return R(500, "server error")


@router.post("/update", deprecated=False)
async def update(
    id_: str = Form(..., examples=[""], alias="id"),
    column_: Literal[*COLUMNS] = Form(..., alias="column"),
    value_: str | None = Form(None, examples=[""], alias="value"),
):
    try:
        # validate id
        if not id_ or id_ == "" or not ObjectId.is_valid(id_):
            return R(400, "invalid id")

        # validate room exist
        exist = await db[COLLECTION].find_one({"_id": ObjectId(id_)})
        if not exist:
            return R(400, "not found")

        # update room - use by_alias=True to get DB field names (name, type, etc.)
        await db[COLLECTION].update_one(
            {"_id": ObjectId(id_)},
            {
                "$set": {
                    column_: value_ or "",
                    "updated_at": datetime.now(),
                }
            },
        )

        return R(200, "update success")
    except Exception:
        return R(500, "server error")


@router.post("/upload", deprecated=False)
async def upload_image(
    id_: str = Form(..., examples=[""], alias="id"),
    index_: Literal[0, 1, 2, 3, 4, 5, 6, 7, 8, 9] = Form(..., alias="index"),
    data_: UploadFile | None = File(None, examples=[None], alias="data"),
):
    try:

        # validate id
        if not id_ or id_ == "" or not ObjectId.is_valid(id_):
            return R(400, "invalid id")

        # validate column
        if not column_ or column_ == "" or column_ not in Room_Column_Image.model_fields.keys():
            return R(400, "invalid column name")

        # validate room
        exist = await db[COLLECTION].find_one({"_id": ObjectId(id_)})
        if not exist:
            return R(404, "room not found")

        # validate image size
        content = await data_.read()
        if len(content) > 10 * 1024 * 1024 or len(content) <= 0:
            return R(400, "image size must be less than 10 MB")

        # prepare image name and path
        date_time = datetime.now().strftime("%Y%m%d%H%M%S%f")
        access_token = tk.gen(16)
        image_ext = "png"  # convert all images to png format

        image_name_new = f"{date_time}_{access_token}.{image_ext}"
        print(f"image_name : {image_name_new}")

        # delete old image file if exists
        # ! need to check
        image_name_old = exist.get("Images")[index_]
        if image_name_old:
            if s3.object_exists(MINIO_BUCKET_PUBLIC, image_name_old):
                s3.remove_object(MINIO_BUCKET_PUBLIC, image_name_old)

        # convert image to png format
        data_ = Image.open(BytesIO(content))
        image_buffer = BytesIO()
        data_.save(image_buffer, format="PNG")
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
            {"_id": ObjectId(id)},
            # ! need to check
            {"$set": {f"Images.{index_}": image_name_new, "updated_at": datetime.now()}},
        )

        # generate thumbnails
        cvt.to_thumbnail(f"images/{image_name_new}", 100)
        cvt.to_thumbnail(f"images/{image_name_new}", 200)

        return R(200, "uploaded successfully")
    except Exception:
        return R(500, "server error")


# * OK
@router.post("/delete", deprecated=False)
async def delete_row(
    id_: str = Form(..., examples=[""], alias="id"),
):
    try:

        # check if id is valid
        if not ObjectId.is_valid(id_):
            return R(400, "invalid id")

        # check if id exists in database
        exist = await db[COLLECTION].find_one({"_id": ObjectId(id_)})
        if not exist:
            return R(400, "room not found")

        # soft delete a row
        await db[COLLECTION].update_one(
            {"_id": ObjectId(id_)},
            {"$set": {"deleted_at": datetime.now()}},
        )

        return R(200, "deleted successfully")

    except Exception:
        return R(500, "server error")


if __name__ == "__main__":
    os.system("python Main.py")
