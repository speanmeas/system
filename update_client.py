import os
import re
import time
import paramiko
from tqdm import tqdm

os.chdir("client")


# read pubspec.yaml
content = ""
with open("pubspec.yaml", "r", encoding="utf-8") as f:
    content = f.read()


# find the current build number
build_match = re.search(r"version: (\d+).(\d+).(\d+)\+(\d+)", content)
if build_match:

    major = int(build_match.group(1))
    # print(f"major : {major}")

    minor = int(build_match.group(2))
    # print(f"minor : {minor}")

    patch = int(build_match.group(3))
    # print(f"patch : {patch}")

    build_num = int(build_match.group(4))
    new_build_num = build_num + 1
    # print(f"build_num : {build_num} -> new_build_num : {new_build_num}")

    # update the build number in pubspec.yaml content
    new_content = re.sub(
        r"version: (\d+)\.(\d+)\.(\d+)\+(\d+)",
        f"version: {build_match.group(1)}.{build_match.group(2)}.{build_match.group(3)}+{new_build_num}",
        content,
    )
    # print(new_content)

    # write back to env.dart
    with open("pubspec.yaml", "w", encoding="utf-8") as f:
        f.write(new_content)


# clean
# os.system("flutter clean")

# build web release
# os.system("flutter build web --release --base-href /")
os.system("flutter build web --release --base-href /system/")
# os.system("flutter build web --release --base-href /app/ --output=build/github")


# delay for 10 seconds
for _ in tqdm(range(100)):
    time.sleep(0.1)


# git commit and push
os.chdir("../")
os.system("git add .")
os.system(f'git commit -m "update"')
os.system("git push")
