import os
import sys


sys.path.append(os.getcwd())

from typing import *
from fastapi import *
from fastapi.responses import *
from fastapi.security import *

import json
import secrets
import requests
from io import BytesIO
from bson import ObjectId, json_util
from datetime import datetime
from rich import print as pprint
from PIL import Image

from server.Environment import *
from utilities.Security import hash as se
from utilities.Database import database as db
from utilities.Storage import storage as s3
from utilities.Token import token as tk
from utilities.Converter import converter as cvt
from utilities.Bearer import bearer as oa


router = APIRouter()


@router.post("/signup_otp", deprecated=0)
async def _(
    telegram_id: str = Form(..., json_schema_extra={"example": ""}),
):
    try:
        # validate input data
        if telegram_id is None or telegram_id == "":
            return Response(status_code=status.HTTP_400_BAD_REQUEST)

        # generate otp code
        otp = f"{secrets.randbelow(1000000):06d}"

        # prepare data
        body = {
            "telegram_id": telegram_id,
            "signup_otp": otp,
            "created_at": datetime.now(),
        }

        print(f"body : {body}")

        # check existing telegram_id in database
        existing = await db["c_credential_signup_otp"].find_one({"telegram_id": telegram_id})
        if existing:
            await db["c_credential_signup_otp"].update_one(
                {"telegram_id": telegram_id},
                {"$set": {"signup_otp": otp, "created_at": datetime.now()}},
            )
        else:
            await db["c_credential_signup_otp"].insert_one(body)

        # send otp code via telegram bot
        message = f"Your signup OTP:"
        requests.get(f"""{TELEGRAM_API_URL}?chat_id={telegram_id}&text={message}""", timeout=5)
        requests.get(f"""{TELEGRAM_API_URL}?chat_id={telegram_id}&text={otp}""", timeout=5)

        return 1

    except Exception:
        return Response(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


@router.post("/signup", deprecated=0)
async def _(
    username: str = Form(..., json_schema_extra={"example": ""}),
    password: str = Form(..., json_schema_extra={"example": ""}),
    telegram_id: str = Form(..., json_schema_extra={"example": ""}),
    signup_otp: str = Form(..., json_schema_extra={"example": ""}),
):

    try:
        # validate otp
        telegram_otp = await db["c_credential_signup_otp"].find_one({"telegram_id": telegram_id})
        if not telegram_otp:
            return Response(status_code=status.HTTP_400_BAD_REQUEST)

        # validate otp
        if telegram_otp["signup_otp"] != signup_otp:
            return Response(status_code=status.HTTP_400_BAD_REQUEST)

        # create user
        user = {
            "username": username,
            "password_hash": se.to_hash(password),
            "telegram_id": telegram_id,
            "created_at": datetime.now(),
        }

        # insert user into database
        await db["c_credential"].insert_one(user)

        # delete otp record after successful registration
        await db["c_credential_signup_otp"].delete_one({"telegram_id": telegram_id})

        return 1

    except Exception:
        return Response(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


@router.post("/signin", deprecated=0)
async def _(
    username: str = Form(..., json_schema_extra={"example": ""}),
    password: str = Form(..., json_schema_extra={"example": ""}),
):
    try:
        # Debug.debug()
        # 1. verify username and password
        data = {
            "username": username,
            "password_hash": se.to_hash(password),
        }
        user = await db["c_credential"].find_one(data)

        if not user:
            return Response(status_code=status.HTTP_401_UNAUTHORIZED)

        if user.get("deleted_at"):
            return Response(status_code=status.HTTP_401_UNAUTHORIZED)

        if user.get("access_token"):
            return {"token_type": "bearer", "access_token": user["access_token"]}

        # 2. generate token
        access_token = tk.gen(32)

        # 3. store token into database
        await db["c_credential"].update_one(
            {"_id": user["_id"]},
            {"$set": {"access_token": access_token}},
        )

        result = {"token_type": "bearer", "access_token": access_token}

        return result

    except Exception:
        return Response(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


@router.post("/reset_otp", deprecated=0)
async def _(
    telegram_id: str = Form(..., json_schema_extra={"example": ""}),
):
    try:
        # validate telegram_id in database
        user = await db["c_credential"].find_one({"telegram_id": telegram_id})
        if not user:
            return Response(status_code=status.HTTP_400_BAD_REQUEST)

        # generate reset otp code
        reset_otp = f"{secrets.randbelow(1000000):06d}"
        print(reset_otp)

        # prepare data
        body = {
            "user_id": user["_id"],
            "telegram_id": telegram_id,
            "reset_otp": reset_otp,
            "created_at": datetime.now(),
        }

        # check existing telegram_id in database
        existing = await db["c_credential_reset_otp"].find_one({"user_id": user["_id"]})
        if existing:
            await db["c_credential_reset_otp"].update_one(
                {"user_id": user["_id"]},
                {"$set": {"reset_otp": reset_otp, "created_at": datetime.now()}},
            )
        else:
            await db["c_credential_reset_otp"].insert_one(body)

        # send username and reset otp code via telegram bot
        message = f"Your reset OTP:"
        requests.get(f"""{TELEGRAM_API_URL}?chat_id={telegram_id}&text={message}""", timeout=5)
        requests.get(f"""{TELEGRAM_API_URL}?chat_id={telegram_id}&text={reset_otp}""", timeout=5)

        return 1
    except Exception:
        return Response(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


@router.post("/reset", deprecated=0)
async def _(
    telegram_id: str = Form(..., json_schema_extra={"example": ""}),
    reset_otp: str = Form(..., json_schema_extra={"example": ""}),
    new_username: str = Form(..., json_schema_extra={"example": ""}),
    new_password: str = Form(..., json_schema_extra={"example": ""}),
):
    try:

        # validate telegram_id and reset_otp
        query = {"telegram_id": telegram_id, "reset_otp": reset_otp}

        exist = await db["c_credential_reset_otp"].find_one(query)
        if not exist:
            return Response(status_code=status.HTTP_400_BAD_REQUEST)

        user_id = exist["user_id"]

        # clear reset otp record after successful validation
        await db["c_credential_reset_otp"].delete_one({"user_id": user_id})

        # update new password_hash
        await db["c_credential"].update_one(
            {"_id": user_id},
            {
                "$set": {
                    "username": new_username,
                    "password_hash": se.to_hash(new_password),
                    "updated_at": datetime.now(),
                }
            },
        )

    except Exception:
        return Response(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)


def read_one_credential():
    async def _(
        access_token: str = Depends(oa),
    ):
        try:
            # validate token and get user info
            user = await db["c_credential"].find_one({"access_token": access_token})
            if not user:
                return Response(status_code=status.HTTP_401_UNAUTHORIZED)

            return json.loads(json_util.dumps(user))

        except Exception:
            return Response(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)

    return _


router.post("/read", deprecated=0)(read_one_credential())


def update_string(key):
    async def _(
        access_token: str = Depends(oa),
        value: str | None = Form(None, json_schema_extra={"example": ""}),
    ):
        try:
            exist = await db["c_credential"].find_one({"access_token": access_token})
            if not exist:
                return Response(status_code=status.HTTP_401_UNAUTHORIZED)

            await db["c_credential"].update_one(
                {"_id": exist["_id"]},
                {"$set": {key: value, "updated_at": datetime.now()}},
            )

            return 1
        except Exception:
            return Response(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)

    return _


def update_number(key):
    async def _(
        access_token: str = Depends(oa),
        value: float | None = Form(None, json_schema_extra={"example": 0}),
    ):
        try:
            exist = await db["c_credential"].find_one({"access_token": access_token})
            if not exist:
                return Response(status_code=status.HTTP_401_UNAUTHORIZED)

            await db["c_credential"].update_one(
                {"_id": exist["_id"]},
                {"$set": {key: value, "updated_at": datetime.now()}},
            )

            return 1
        except Exception:
            return Response(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)

    return _


COLLUMN_STRINGS = [
    "name",
    "address",
    # "store_id",
    # "driver_id",
]
for key in COLLUMN_STRINGS:
    router.post(f"/update/{key}", deprecated=0)(update_string(key))

COLLUMN_NUMBERS = [
    "phone_number",
]
for key in COLLUMN_NUMBERS:
    router.post(f"/update/{key}", deprecated=0)(update_number(key))

COLLUMN_CREDENTIALS = [
    "username",
    "password",
    "telegram_id",
]
for key in COLLUMN_CREDENTIALS:
    router.post(f"/update/{key}", deprecated=0)(update_string(key))


# * OK
def upload_image(key):
    async def _(
        access_token: str = Depends(oa),
        value: UploadFile = File(...),
    ):
        try:
            # check if id exists
            exist = await db["c_credential"].find_one({"access_token": access_token})
            if not exist:
                return Response(status_code=status.HTTP_404_NOT_FOUND)

            # check image size max 10 MB
            content = await value.read()
            if len(content) > 10 * 1024 * 1024 or len(content) <= 0:
                return Response(status_code=status.HTTP_400_BAD_REQUEST)

            # prepare image name and path
            date_time = datetime.now().strftime("%Y%m%d%H%M%S%f")
            name_token = tk.gen(16)
            image_ext = "png"  # convert all images to png format

            new_image_name = f"{date_time}_{name_token}.{image_ext}"
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
            await db["c_credential"].update_one(
                {"access_token": access_token},
                {"$set": {key: f"images/{new_image_name}", "updated_at": datetime.now()}},
            )

            cvt.to_thumbnail(f"images/{new_image_name}", 100)
            cvt.to_thumbnail(f"images/{new_image_name}", 200)
            return 1
        except Exception:
            return Response(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)

    return _


COLLUMN_IMAGES = ["profile_image", "background_image"]
for key in COLLUMN_IMAGES:
    router.post(f"/upload/{key}", deprecated=0)(upload_image(key))


def delete(key=None):
    async def _(
        access_token: str = Depends(oa),
    ):
        try:
            # check if id exists
            exist = await db["c_credential"].find_one({"access_token": access_token})
            if not exist:
                return Response(status_code=status.HTTP_404_NOT_FOUND)

            # soft delete a row
            if key is None:
                await db["c_credential"].update_one(
                    {"access_token": access_token},
                    {"$set": {"deleted_at": datetime.now()}},
                )
                return 1

            # delete a specific field
            await db["c_credential"].update_one(
                {"access_token": access_token},
                {"$set": {key: None, "updated_at": datetime.now()}},
            )

            return 1

        except Exception:
            return Response(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)

    return _


router.post("/delete", deprecated=0)(delete())
for c in [*COLLUMN_STRINGS, *COLLUMN_NUMBERS, *COLLUMN_IMAGES]:
    router.post(f"/delete/{c}", deprecated=0)(delete(c))


if __name__ == "__main__":
    os.system("python Main.py")
