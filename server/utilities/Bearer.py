import os
import sys


sys.path.append(os.getcwd())


from fastapi.security import *


bearer = OAuth2PasswordBearer(tokenUrl="signin")


if __name__ == "__main__":
    pass
