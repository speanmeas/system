import os
import re
import time
import paramiko
from tqdm import tqdm


# read pubspec.yaml
content = ""
with open("Environment.py", "r", encoding="utf-8") as f:
    content = f.read()


# find the current build number
# VERSION = "1.0.0+1"
build_match = re.search(r"VERSION = \"(\d+).(\d+).(\d+)\+(\d+)\"", content)
if build_match:

    major = int(build_match.group(1))
    # print(f"major : {major}")

    minor = int(build_match.group(2))
    # print(f"minor : {minor}")

    patch = int(build_match.group(3))
    # print(f"patch : {patch}")

    build_num = int(build_match.group(4))
    new_build_num = build_num + 1
    # print(f"build_num : {build_num} -> {new_build_num}")

    # update the build number in pubspec.yaml content
    new_content = re.sub(
        r"VERSION = \"(\d+).(\d+).(\d+)\+(\d+)\"",
        f'VERSION = "{build_match.group(1)}.{build_match.group(2)}.{build_match.group(3)}+{new_build_num}"',
        content,
    )
    # print(new_content)

    # write back to env.dart
    with open("Environment.py", "w", encoding="utf-8") as f:
        f.write(new_content)


# git commit and push
os.chdir("../")
os.system("git add .")
os.system(f'git commit -m "update"')
os.system("git push")


# delay for 10 seconds
for _ in tqdm(range(100), desc="Waiting"):
    time.sleep(0.01)


# create SSH client
client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

# connect to the server
client.connect(
    hostname="msl-t470",
    port=22,
    username="root",
    password="asdfghjkl;'",
)

# single line commands
command = [
    "cd /root/sm_system",
    "git pull",
    # "docker-compose -f docker-compose.yml up -d --build",  # update all
    "docker-compose -f docker-compose.yml up -d --build server",  # update server only
]

# execute commands
stdin, stdout, stderr = client.exec_command(" && ".join(command))
print(stdout.read().decode())


print("Update successfully!")

client.close()
