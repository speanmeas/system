import os
import sys


sys.path.append(os.getcwd())


from typing import *
from fastapi import *


import re
import json
from PIL import Image
from io import BytesIO
from datetime import datetime
from rich import print as pprint
from bson import ObjectId, json_util

from Environment import *
from utilities.Database import database as db
from utilities.Storage import storage as s3
from utilities.Token import token as tk
from utilities.Converter import converter as cvt

router = APIRouter()

COLLECTION = "c_crud"

COLLUMN_STRINGS = [
    "name",
    "description",
    "store_name",
]
COLLUMN_NUMBERS = [
    "price",
    "rating",
]
COLLUMN_IMAGES = [
    "profile",
    "background",
]


# * OK
def create():
    async def _():
        try:
            counter = await db["c_counter"].find_one_and_update(
                {"_id": COLLECTION},
                {"$inc": {"seq": 1}},
                upsert=True,
                return_document=True,
            )

            data = {
                **{c: None for c in COLLUMN_NUMBERS},
                **{c: None for c in COLLUMN_STRINGS},
                **{c: None for c in COLLUMN_IMAGES},
                "created_at": datetime.now(),
                "reorder": counter["seq"],
                "updated_at": None,
                "deleted_at": None,
            }

            await db[COLLECTION].insert_one({**data})

            return 1
        except Exception:
            return Response(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)

    return _


# * OK
def read():
    async def _(
        query: Optional[str] = Form(None, json_schema_extra={"example": ""}),
        offset: Optional[int] = Form(None, json_schema_extra={"example": 0}, ge=0),
        limit: Optional[int] = Form(None, json_schema_extra={"example": 1000}, ge=1, le=10000),
        sort_by: Literal["created_at", "order", *COLLUMN_STRINGS, *COLLUMN_NUMBERS] = Form("created_at"),  # type: ignore
        sort_order: Literal["-1", "1"] = Form("-1"),
    ):
        try:
            if not query:
                search = (
                    await db[COLLECTION]
                    .find(
                        {"deleted_at": {"$eq": None}},
                    )
                    .sort(sort_by, int(sort_order))
                    .skip(offset)
                    .limit(limit)
                    .to_list(length=None)
                )
                return json.loads(json_util.dumps(search))

            search = (
                await db[COLLECTION]
                .find(
                    {
                        "$and": [
                            {"$or": [{c: {"$regex": re.escape(query), "$options": "i"}} for c in [*COLLUMN_STRINGS, *COLLUMN_NUMBERS]]},
                            {"deleted_at": {"$eq": None}},
                        ]
                    }
                )
                .sort(sort_by, int(sort_order))
                .skip(offset)
                .limit(limit)
                .to_list(length=None)
            )
            return json.loads(json_util.dumps(search))
        except Exception:
            return Response(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)

    return _


# * OK
def update_string(key):
    async def _(
        id: str = Form(..., json_schema_extra={"example": ""}),
        value: str = Form(..., json_schema_extra={"example": ""}),
    ):
        try:
            exist = await db[COLLECTION].find_one({"_id": ObjectId(id)})
            if not exist:
                return Response(status_code=status.HTTP_404_NOT_FOUND)

            await db[COLLECTION].update_one(
                {"_id": ObjectId(id)},
                {"$set": {key: value, "updated_at": datetime.now()}},
            )

            return 1
        except Exception:
            return Response(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)

    return _


# * OK
def update_float(key):
    async def _(
        id: str = Form(..., json_schema_extra={"example": ""}),
        value: float = Form(..., json_schema_extra={"example": 0.0}),
    ):
        try:
            exist = await db[COLLECTION].find_one({"_id": ObjectId(id)})
            if not exist:
                return Response(status_code=status.HTTP_404_NOT_FOUND)

            await db[COLLECTION].update_one(
                {"_id": ObjectId(id)},
                {"$set": {key: value, "updated_at": datetime.now()}},
            )

            return 1
        except Exception:
            return Response(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)

    return _


# * OK
def upload_image(key):
    async def _(
        id: str = Form(..., json_schema_extra={"example": ""}),
        value: UploadFile = File(...),
    ):
        try:
            # check if id exists
            exist = await db[COLLECTION].find_one({"_id": ObjectId(id)})
            if not exist:
                return Response(status_code=status.HTTP_404_NOT_FOUND)

            # check image size max 10 MB
            content = await value.read()
            if len(content) > 10 * 1024 * 1024 or len(content) <= 0:
                return Response(status_code=status.HTTP_400_BAD_REQUEST)

            # prepare image name and path
            date_time = datetime.now().strftime("%Y%m%d%H%M%S%f")
            access_token = tk.gen(16)
            image_ext = "png"  # convert all images to png format

            new_image_name = f"{date_time}_{access_token}.{image_ext}"
            print(f"image_name : {new_image_name}")

            # delete old image file if exists
            old_image_name = exist.get(key)
            if old_image_name:
                if s3.object_exists(MINIO_BUCKET_PUBLIC, old_image_name):
                    s3.remove_object(MINIO_BUCKET_PUBLIC, old_image_name)

            # convert image to png format
            image = Image.open(BytesIO(content))
            image_buffer = BytesIO()
            image.save(image_buffer, format="PNG")
            image_buffer.seek(0)

            # upload new image file
            s3.put_object(
                bucket_name=MINIO_BUCKET_PUBLIC,  # bucket name
                object_name=f"images/{new_image_name}",  # file name in bucket
                data=image_buffer,  # file-like object
                length=image_buffer.getbuffer().nbytes,  # size of the data in bytes
            )

            # add image name to database
            await db[COLLECTION].update_one(
                {"_id": ObjectId(id)},
                {"$set": {key: new_image_name, "updated_at": datetime.now()}},
            )

            cvt.to_thumbnail(f"images/{new_image_name}", 100)
            cvt.to_thumbnail(f"images/{new_image_name}", 200)
            return 1
        except Exception:
            return Response(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)

    return _


# * OPTIONAL
def reorder():
    async def _(
        id: str = Form(..., json_schema_extra={"example": ""}),
        new_order: int = Form(..., json_schema_extra={"example": 0}, ge=1),
    ):
        try:
            # check if id exists
            exist = await db[COLLECTION].find_one({"_id": ObjectId(id)})
            if not exist:
                return Response(status_code=status.HTTP_404_NOT_FOUND)

            # check if new_order is valid
            max_order = await db["c_counter"].find_one({"_id": COLLECTION})
            if new_order >= max_order["seq"]:
                return Response(status_code=status.HTTP_400_BAD_REQUEST)

            # check if new_order is the same as old_order
            old_order = exist["reorder"]
            if new_order == old_order:
                return Response(status_code=status.HTTP_400_BAD_REQUEST)

            # increment or decrement order of other rows
            if new_order < old_order:
                await db[COLLECTION].update_many(
                    {"reorder": {"$gte": new_order, "$lt": old_order}},
                    {"$inc": {"reorder": 1}},
                )
            else:
                await db[COLLECTION].update_many(
                    {"reorder": {"$gt": old_order, "$lte": new_order}},
                    {"$inc": {"reorder": -1}},
                )

            # update order of the target row
            await db[COLLECTION].update_one(
                {"_id": ObjectId(id)},
                {"$set": {"reorder": new_order, "updated_at": datetime.now()}},
            )

            return 1
        except Exception:
            return Response(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)

    return _


# * OK
def delete(key=None):
    async def _(
        id: str = Form(..., json_schema_extra={"example": ""}),
    ):
        try:
            # check if id exists
            exist = await db[COLLECTION].find_one({"_id": ObjectId(id)})
            if not exist:
                return Response(status_code=status.HTTP_404_NOT_FOUND)

            # soft delete a row
            if key is None:
                await db[COLLECTION].update_one(
                    {"_id": ObjectId(id)},
                    {"$set": {"deleted_at": datetime.now()}},
                )
                return 1

            # delete a specific field
            await db[COLLECTION].update_one(
                {"_id": ObjectId(id)},
                {"$set": {key: None, "updated_at": datetime.now()}},
            )

            return 1

        except Exception:
            return Response(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)

    return _


# create
router.post("/create", deprecated=0)(create())

# read + search
router.post("/read", deprecated=0)(read())

# update + upload
for c in COLLUMN_STRINGS:
    router.post(f"/update/{c}", deprecated=0)(update_string(c))

for c in COLLUMN_NUMBERS:
    router.post(f"/update/{c}", deprecated=0)(update_float(c))

for c in COLLUMN_IMAGES:
    router.post(f"/upload/{c}", deprecated=0)(upload_image(c))

router.post("/reorder", deprecated=0)(reorder())

# delete
router.post("/delete", deprecated=0)(delete())

for c in [*COLLUMN_STRINGS, *COLLUMN_NUMBERS, *COLLUMN_IMAGES]:
    router.post(f"/delete/{c}", deprecated=0)(delete(c))


if __name__ == "__main__":
    os.system("python Application.py")
