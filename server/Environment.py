import os
import sys

sys.path.append(os.getcwd())


from dotenv import load_dotenv

# ? load environment variables
load_dotenv("../.env")


# ? General configuration for the application
TITLE = os.getenv("TITLE", "Local Server")


# ? Database configuration for the application
MONGO_HOST = os.getenv("MONGO_HOST", "localhost")
MONGO_PORT = int(os.getenv("MONGO_PORT", 27017))
MONGO_INITDB_ROOT_USERNAME = os.getenv("MONGO_INITDB_ROOT_USERNAME", "admin")
MONGO_INITDB_ROOT_PASSWORD = os.getenv("MONGO_INITDB_ROOT_PASSWORD", "adminadmin")

MONGO_DATABASE = os.getenv("MONGO_DATABASE", "my_database")
MONGO_URL = f"mongodb://{MONGO_INITDB_ROOT_USERNAME}:{MONGO_INITDB_ROOT_PASSWORD}@{MONGO_HOST}:{MONGO_PORT}"


# ? MinIO configuration for the application
MINIO_HOST = os.getenv("MINIO_HOST", "localhost")
MINIO_PORT = int(os.getenv("MINIO_PORT", 9000))
MINIO_CONSOLE_PORT = int(os.getenv("MINIO_CONSOLE_PORT", 9001))
MINIO_ROOT_USER = os.getenv("MINIO_ROOT_USER", "admin")
MINIO_ROOT_PASSWORD = os.getenv("MINIO_ROOT_PASSWORD", "adminadmin")
MINIO_BUCKET_PUBLIC = os.getenv("MINIO_BUCKET_PUBLIC", "public")
MINIO_URL = f"{MINIO_HOST}:{MINIO_PORT}"


# ? Secret key for security purposes
SECRET_KEY = os.getenv("SECRET_KEY", "my_secret_key")


MAX_IMAGE_UPLOAD_SIZE = 10 * 1024 * 1024  # 10 MB
