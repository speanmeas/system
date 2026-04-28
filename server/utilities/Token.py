import os
import sys

sys.path.append(os.getcwd())


import secrets
import string


class Token:
    alphabet = string.ascii_letters + string.digits  # 62 chars [a-zA-Z0-9]

    def gen(self, length: int = 16) -> str:
        return "".join(secrets.choice(self.alphabet) for _ in range(length))


token = Token()


if __name__ == "__main__":
    pass
