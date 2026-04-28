# windows
python -m venv .venv
.venv\Scripts\activate

# upgrade pip
python -m pip install --upgrade pip


pip install fastapi[all]
pip install uvicorn
pip install pymongo
pip install minio
pip install requests
pip install python-dotenv

pip install ipdb
pip install pillow
pip install matplotlib
pip install python-telegram-bot

#
pip install opencv-python-headless
pip install insightface
pip install onnxruntime


# development dependencies
pip install jupyter
pip install paramiko



# docker save volume name minio_data
# docker run -v minio_data:/data --name minio -p 9000:9000 -e "MIN