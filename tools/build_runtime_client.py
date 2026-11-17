"""Repackage current APK with scene error tracing; preserve all other Lua assets."""
import argparse
import zipfile
import struct
import base64
from pathlib import Path
from decode_lua import decrypt, encrypt


def patch_activity_config(data):
    """Change only AppActivity's existing configChanges typed integer in AXML.

    Waydroid resizes change screenLayout/smallestScreenSize/density. Recreating
    this legacy Cocos Activity reinitializes a native Application singleton.
    """
    out = bytearray(data)
    strings = []; cursor = 8; changed = 0
    while cursor < len(out):
        kind, header, size = struct.unpack_from("<HHI", out, cursor)
        if kind == 1:
            count, _, flags, start = struct.unpack_from("<IIII", out, cursor + 8)
            def length(pos, utf8):
                if utf8:
                    value = out[pos]; pos += 1
                    if value & 128: value = ((value & 127) << 8) | out[pos]; pos += 1
                else:
                    value = struct.unpack_from("<H", out, pos)[0]; pos += 2
                    if value & 32768:
                        value = ((value & 32767) << 16) | struct.unpack_from("<H", out, pos)[0]; pos += 2
                return value, pos
            for i in range(count):
                pos = cursor + start + struct.unpack_from("<I", out, cursor + header + 4 * i)[0]
                n, pos = length(pos, bool(flags & 256))
                if flags & 256:
                    n, pos = length(pos, True)
                    strings.append(bytes(out[pos:pos+n]).decode())
                else:
                    strings.append(bytes(out[pos:pos+2*n]).decode("utf-16le"))
        if kind == 0x102:
            name = struct.unpack_from("<I", out, cursor + 20)[0]
            attr_start, attr_size, count = struct.unpack_from("<HHH", out, cursor + 24)
            if strings[name] == "activity":
                attrs = [cursor + 16 + attr_start + i * attr_size for i in range(count)]
                names = {strings[struct.unpack_from("<I", out, a + 4)[0]]: a for a in attrs}
                if "name" in names and "configChanges" in names:
                    name_index = struct.unpack_from("<I", out, names["name"] + 16)[0]
                    if strings[name_index] == "org.cocos2dx.lua.AppActivity":
                        a = names["configChanges"] + 16
                        value = struct.unpack_from("<I", out, a)[0]
                        struct.pack_into("<I", out, a, value | 0x1900)
                        changed += 1
        cursor += size
    assert changed == 1, "expected one AppActivity configChanges"
    return bytes(out)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--input", type=Path, default=Path("dist/monster2_patched.apk"))
    p.add_argument("--output", type=Path, default=Path("dist/monster2_runtime-unsigned.apk"))
    args = p.parse_args()
    target = "assets/src/GameMgr/Map/SceneMgr.lua"
    with zipfile.ZipFile(args.input) as source, zipfile.ZipFile(args.output, "w") as output:
        for info in source.infolist():
            if info.filename.upper().startswith("META-INF/"):
                continue
            data = source.read(info)
            if info.filename == "AndroidManifest.xml":
                data = patch_activity_config(data)
            if info.filename == "assets/src/GameMgr/Support/LuaSqlite.lua":
                data = b"XXTEA" + encrypt(Path("decoded_lua/assets/src/GameMgr/Support/LuaSqlite.lua").read_bytes(), b"kyopkm")
            if info.filename.startswith("assets/res/Config/db/") and info.filename.endswith(".db"):
                sidecar = zipfile.ZipInfo(info.filename + ".b64")
                sidecar.compress_type = zipfile.ZIP_DEFLATED
                output.writestr(sidecar, base64.b64encode(data))
            if info.filename.lower().endswith((".mp4", ".m4a", ".mp3", ".ogg")):
                # Android MediaPlayer opens packaged media through AssetFileDescriptor.
                info.compress_type = zipfile.ZIP_STORED
            if info.filename == target:
                text = decrypt(data[5:], b"kyopkm").decode()
                old = '    print("开始加载新场景"..sceneName)'
                assert text.count(old) == 1
                text = text.replace(old, old + '\n    print("[SCENE_DIAG] from="..tostring(SceneMgr.currentScene).." to="..tostring(sceneName).." stack="..debug.traceback())', 1)
                old = 'local ret,errMessage = pcall(function()\n                replaceFunc()\n            end)'
                # Preserve the exact line endings of the existing asset.
                text = text.replace('\r\n', '\n')
                assert text.count(old) == 1
                text = text.replace(old, 'local ret,errMessage = xpcall(replaceFunc, function(err)\n                local trace = debug.traceback(tostring(err), 2)\n                print("[SCENE_DIAG] initialization_failed target="..tostring(sceneName).." error="..trace)\n                return trace\n            end)', 1)
                data = b"XXTEA" + encrypt(text.encode(), b"kyopkm")
            output.writestr(info, data)


if __name__ == "__main__":
    main()
