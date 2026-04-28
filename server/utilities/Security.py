import os
import sys


sys.path.append(os.getcwd())


import hmac
from Environment import *


class HASH:

    secret_key: str

    base62_characters: str = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    len_alphabet: int = len(base62_characters)

    def __init__(self, secret_key: str) -> None:
        self.secret_key = secret_key

    def hex_to_base62(self, hex_str: str) -> str:
        num = int(hex_str, 16)  # Convert hex to decimal

        # convert decimal to base62
        encoded = []
        while num > 0:
            num, rem = divmod(num, self.len_alphabet)
            encoded.append(self.base62_characters[rem])

        result = "".join(reversed(encoded))  # reverse the encoded list to get the correct order

        return result

    def to_hash(self, message: str) -> str:
        # generate HMAC-SHA256
        hex_data = (
            hmac.new(
                self.secret_key.encode(),
                message.encode(),
                digestmod="sha256",
            )
            .digest()  # get the binary digest
            .hex()  # convert binary digest to hex string
        )

        result = self.hex_to_base62(hex_data)

        return result


hash = HASH(SECRET_KEY)


if __name__ == "__main__":
    pass
