import os
import sys

sys.path.append(os.getcwd())


import ipdb
import inspect


class Debug:

    @staticmethod
    def debug():
        in_docker = os.path.isfile("/.dockerenv")

        if not in_docker:
            caller_frame = inspect.currentframe().f_back
            ipdb.set_trace(frame=caller_frame)


if __name__ == "__main__":
    pass
