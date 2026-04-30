import os
import sys


sys.path.append(os.getcwd())


from fastapi import *
from fastapi.responses import *
from fastapi.middleware.cors import *

from server.Environment import *


app = FastAPI(title=TITLE, version="1.0.0", docs_url="/")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])

from routers.Room import router as room
from routers.Pluto import router as pluto
from routers.Pluto_Sample import router as pluto_sample

app.include_router(pluto, prefix="/pluto", tags=["PlutoGrid"])
app.include_router(pluto_sample, prefix="/pluto-sample", tags=["PlutoGrid Sample"])
app.include_router(room, prefix="/room", tags=["Room"])

# from routers.Credential import router as credential

# app.include_router(credential, prefix="/credential", tags=["Credential"])


# from routers.CRUD import router as crud

# app.include_router(crud, prefix="/crud", tags=["CRUD"])


if __name__ == "__main__":

    import os
    import uvicorn
    import webbrowser
    from threading import Timer

    def open_browser():
        webbrowser.open("http://127.0.0.1:8000")

    Timer(1, open_browser).start()

    module_name = os.path.relpath(os.path.abspath(__file__), os.getcwd()).replace("\\", ".").replace("/", ".")[:-3]
    variable_name = "app"

    uvicorn.run(
        f"{module_name}:{variable_name}",
        host="127.0.0.1",
        port=8000,
        reload=True,
        reload_includes=[
            "server/routers/*.py",
            "server/utilities/*.py",
            ".env",
            "server/Application.py",
            "server/Environment.py",
        ],
        reload_excludes=["__pycache__"],
    )
