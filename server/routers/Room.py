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
from utilities.Converter import converter as cvt
from utilities.Token import token as tk
from utilities.Storage import storage as s3
from utilities.Database import database as db


#################### Arguments ####################

COLLECTION = "collection_room"


class Column_String(BaseModel):
    name_: str | None = Form(None, examples=[""], alias="name")
    type_: str | None = Form(None, examples=[""], alias="type")
    status_: str | None = Form(None, examples=[""], alias="status")


class Column_Number(BaseModel):
    capacity_: float | None = Form(None, examples=[""], alias="capacity")
    price_: float | None = Form(None, examples=[""], alias="price")


#################### End Arguments ####################

router = APIRouter()


class Column_Date(BaseModel):
    created_at_: datetime | None = Form(None, examples=[""], alias="created_at")
    updated_at_: datetime | None = Form(None, examples=[""], alias="updated_at")
    deleted_at_: datetime | None = Form(None, examples=[""], alias="deleted_at")


class Sortable(Column_Date, Column_Number, Column_String):
    pass


class Create(Column_Number, Column_String):
    pass


@router.post("/create", deprecated=False)
async def create(
    form: Create = Form(None),
):
    try:

        # prepare data
        data = {
            **form.model_dump(by_alias=True),
            "created_at": datetime.now(),
            "updated_at": None,
            "deleted_at": None,
        }

        # insert data
        await db[COLLECTION].insert_one(data)

        return "create successfully"

    except Exception:
        return Response("server error", 500)


class Read(BaseModel):
    key_: Literal[*list(Sortable().model_dump(by_alias=True).keys())] | None = Form(None, examples=[""], alias="key")
    # string
    query_: str | None = Form(None, examples=[""], alias="query")
    # number
    min_: float | None = Form(None, examples=[""], alias="min")
    max_: float | None = Form(None, examples=[""], alias="max")
    # date
    start_: datetime | None = Form(None, examples=[""], alias="start")
    end_: datetime | None = Form(None, examples=[""], alias="end")
    # order
    order_: Literal["-1", "1"] | None = Form(None, examples=[""], alias="order")
    # pagination
    offset_: int | None = Form(None, examples=[""], ge=0, alias="offset")
    limit_: int | None = Form(None, examples=[""], ge=1, le=10000, alias="limit")


@router.post("/read", deprecated=False)
async def read(
    form: Read = Form(None),
):
    try:

        # default query
        query = {"deleted_at": {"$in": [None, ""]}}

        # for query string
        if form.key_ in list(Column_String().model_dump(by_alias=True).keys()) and form.query_:
            query["$and"] = [
                {form.key_: {"$regex": re.escape(form.query_ or ""), "$options": "i"}},
            ]

        # for number range
        if form.key_ in list(Column_Number().model_dump(by_alias=True).keys()) and form.min_ and form.max_:
            query["$and"] = [
                {form.key_: {"$gte": form.min_}},
                {form.key_: {"$lte": form.max_}},
            ]

        # for date range
        # ! need to check for flutter date format
        if form.key_ in list(Column_Date().model_dump(by_alias=True).keys()) and form.start_ and form.end_:
            query["$and"] = [
                {form.key_: {"$gte": form.start_}},
                {form.key_: {"$lte": form.end_}},
            ]

        # search
        search = (
            await db[COLLECTION]  #
            .find(query)
            .sort(
                form.key_ or "created_at",
                int(form.order_ or 1),
            )
            .skip(form.offset_ or 0)
            .limit(form.limit_ or 100)
            .to_list(length=None)
        )

        return json.loads(json_util.dumps(search))

    except Exception:
        return Response("server error", 500)


class Refer(BaseModel):
    column_: Literal[*list(Create().model_dump(by_alias=True).keys())] = Form(..., alias="column")


@router.post("/refer", deprecated=False)
async def refer(
    form: Refer = Form(...),
):
    try:

        print(form.column_)

        # get distinct values
        unique = await db[COLLECTION].distinct(  # distinct = get unique values
            form.column_,
            {
                "deleted_at": {"$in": [None, ""]},
                form.column_: {"$ne": None, "$nin": [""]},  # ne = not equal, nin = not in
            },
        )

        return json.loads(json_util.dumps(unique))

    except Exception:
        return Response("server error", 500)


class Update(BaseModel):
    id_: str = Form(..., examples=[""], alias="id")
    key_: Literal[*list(Create().model_dump(by_alias=True).keys())] = Form(..., alias="key")
    value_: str | None = Form(None, examples=[""], alias="value")


@router.post("/update", deprecated=False)
async def update(
    form: Update = Form(...),
):
    try:
        # validate id
        if not form.id_ or form.id_ == "" or not ObjectId.is_valid(form.id_):
            return Response("invalid id", 400)

        # validate room exist
        exist = await db[COLLECTION].find_one({"_id": ObjectId(form.id_)})
        if not exist:
            return Response("not found", 400)

        if form.key_ in list(Column_String().model_dump(by_alias=True).keys()):
            await db[COLLECTION].update_one(
                {"_id": ObjectId(form.id_)},
                {
                    "$set": {
                        form.key_: form.value_ or "",
                        "updated_at": datetime.now(),
                    }
                },
            )
            return 1

        return "update success"
    except Exception:
        return Response("server error", 500)


class Upload(BaseModel):
    id_: str = Form(..., examples=[""], alias="id")
    key_: Literal[0, 1, 2, 3, 4, 5, 6, 7, 8, 9] = Form(..., alias="key")
    value_: UploadFile | None = File(None, examples=[None], alias="value")


@router.post("/upload", deprecated=False)
async def upload_image(
    form: Upload = Form(...),
):
    try:

        # validate id
        if not form.id_ or form.id_ == "" or not ObjectId.is_valid(form.id_):
            return Response("invalid id", 400)

        # validate column
        if not form.key_ or form.key_ < 0 or form.key_ > 9:
            return Response("invalid index", 400)

        # validate room
        exist = await db[COLLECTION].find_one({"_id": ObjectId(form.id_)})
        if not exist:
            return Response("room not found", 404)

        # validate image size
        content = await form.value_.read()
        if len(content) > 10 * 1024 * 1024 or len(content) <= 0:
            return Response("image size must be less than 10 MB", 400)

        # prepare image name and path
        date_time = datetime.now().strftime("%Y%m%d%H%M%S%f")
        access_token = tk.gen(16)
        image_ext = "png"  # convert all images to png format

        image_name_new = f"{date_time}_{access_token}.{image_ext}"
        print(f"image_name : {image_name_new}")

        # delete old image file if exists
        # ! need to check later
        image_name_old = exist.get("images")[form.key_]
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
            {"_id": ObjectId(form.id_)},
            # ! need to check later
            {"$set": {f"Images.{form.key_}": image_name_new, "updated_at": datetime.now()}},
        )

        # generate thumbnails
        cvt.to_thumbnail(f"images/{image_name_new}", 100)
        cvt.to_thumbnail(f"images/{image_name_new}", 200)

        return "upload successfully"
    except Exception:
        return Response("server error", 500)


class Delete(BaseModel):
    id_: str = Field(..., examples=[""], alias="id")


@router.post("/delete", deprecated=False)
async def delete_row(
    form: Delete = Form(...),
):
    try:

        # check if id is valid
        if not ObjectId.is_valid(form.id_):
            return Response("invalid id", 400)

        # check if id exists in database
        exist = await db[COLLECTION].find_one({"_id": ObjectId(form.id_)})
        if not exist:
            return Response("room not found", 400)

        # soft delete a row
        await db[COLLECTION].update_one(
            {"_id": ObjectId(form.id_)},
            {"$set": {"deleted_at": datetime.now()}},
        )

        return "delete successfully"

    except Exception:
        return Response("server error", 500)


if __name__ == "__main__":
    os.system("python Main.py")
