FROM ubuntu:24.04



# set timezone
RUN ln -snf /usr/share/zoneinfo/Asia/Phnom_Penh /etc/localtime && echo "Asia/Phnom_Penh" > /etc/timezone


# update and upgrade
RUN apt update && apt upgrade -y

# install python3
RUN apt install python3 -y
RUN apt install python3-dev -y
RUN apt install python3-venv -y
RUN apt install build-essential -y

# create virtual environment
RUN python3 -m venv /.venv

# Add virtual environment to PATH
ENV PATH="/.venv/bin:$PATH"


# 
RUN pip install --upgrade pip 

RUN pip install fastapi[all]
RUN pip install uvicorn
RUN pip install pymongo
RUN pip install minio
RUN pip install requests
RUN pip install python-dotenv

RUN pip install ipdb
RUN pip install pillow
RUN pip install matplotlib
RUN pip install python-telegram-bot

#
# RUN pip install opencv-python-headless
# RUN pip install insightface
# RUN pip install onnxruntime


# development dependencies
# RUN pip install jupyter
# RUN pip install paramiko

# copy project files
COPY . .


EXPOSE 8000


CMD ["uvicorn", "Application:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]