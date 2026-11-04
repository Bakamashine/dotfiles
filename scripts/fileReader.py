import os
from pathlib import Path
import sys

ignoreDirectory = [
    "node_modules",
    "img",
    "image",
    ".git",
    ".idea",
    "vendor"
]

def should_ignore(path):
    parts = path.parts
    for ignored in ignoreDirectory:
        if ignored in parts:
            return True
    return False

fileName = "output.txt"
if os.path.exists(fileName):
    os.remove(fileName)

writeFile = open(fileName, "w", encoding="utf-8")
listFiles = list(Path().rglob("*.php"))

print(f"Найдено файлов .php: {len(listFiles)}")

count = 0
for item in listFiles:
    if item.name == os.path.basename(sys.argv[0]):
        print(f"Пропуск: текущий скрипт {item.name}")
        continue
    elif should_ignore(item):
        print(f"Пропуск: исключённая директория {item}")
        continue
    elif os.path.isfile(item):
        try:
            with open(item, "rt", encoding="utf-8") as file:
                text = file.read()
                writeFile.write(f"\n{'='*50}\n{item}:\n{'='*50}\n{text}\n")
                writeFile.flush()
                count += 1
                print(f"✓ Записано: {item.name}")
        except Exception as e:
            print(f"✗ Ошибка при чтении {item}: {e}")

writeFile.close()
print(f"\nВсего записано файлов: {count}")
