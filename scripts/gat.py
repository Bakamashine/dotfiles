import requests
URL = "https://tools.aimylogic.com/api/now?tz=Europe/Moscow"
req = requests.get(URL)
req.raise_for_status()
timestamp = req.json()["timestamp"]
print(f"Timestamp: {timestamp}")
print("===================")
print("Git commands:")
print("git add .")
print(f"git commit -m {timestamp}")
print("git push")
