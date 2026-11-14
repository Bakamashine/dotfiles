import requests
import os
from sys import argv
URL = "https://tools.aimylogic.com/api/now?tz=Europe/Moscow"
req = requests.get(URL)
req.raise_for_status()
timestamp = req.json()["timestamp"]

commands = [
    "git add .",
    f"git commit -m {timestamp}",
    "git push"
]
print(f"Timestamp: {timestamp}")
print("===================")
print("Git commands:")
for cmd in commands:
    print(cmd)

if len(argv) > 1 and argv[1] == "p":
    for cmd in commands:
        os.system(cmd)
