from fastapi import Response


class R(Response):
    def __init__(self, status_code=200, content=""):

        if status_code == 200:
            print("\033[1m\033[92m" + str(status_code) + ": " + str(content) + "\033[0m\033[0m")

        if status_code == 400:
            print("\033[1m\033[91m" + str(status_code) + ": " + str(content) + "\033[0m\033[0m")

        super().__init__(content=content, status_code=status_code)
