import os
import sys

sys.path.append(os.getcwd())

from server.utilities.Database import database as db

sample_data = {}

for c in range(1, 101):
    for r in range(1, 101):
        sample_data[f"C{c}R{r}"] = f"Data {c}-{r}"


print(sample_data)


# db["c_sample"].insert_one({"name": "Sample Data", "value": 123})
