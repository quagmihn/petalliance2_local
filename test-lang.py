from pathlib import Path
import struct

path = Path("apk_extracted/assets/res/Config/LangInfo.dat")
data = path.read_bytes()

count = struct.unpack_from("<I", data, 0)[0]

print("Expected records:", count)

offset = 4
records = []

for i in range(count):
    if offset + 4 > len(data):
        print("Unexpected EOF at record", i)
        break

    length = struct.unpack_from("<I", data, offset)[0]
    start = offset + 4
    end = start + length

    if end > len(data):
        print("Invalid length at record", i)
        break

    raw = data[start:end]
    parts = raw.split(b"\x00", 2)

    if len(parts) < 2:
        print("Invalid record at", i)
        break

    key = parts[0].decode("utf-8", errors="replace")
    value = parts[1].decode("utf-8", errors="replace")

    records.append((key, value))
    offset = end

print("Parsed records:", len(records))
print("Final offset:", offset)
print("File size:", len(data))
print("First records:", records[:3])