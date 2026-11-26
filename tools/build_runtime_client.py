"""Repackage the verified runtime APK with scene and quest error recovery fixes."""
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
    mode = p.add_mutually_exclusive_group()
    mode.add_argument("--pet-economy-overlay", action="store_true",
                   help="replace only the Pet default-tab and economy Lua on an already patched APK")
    mode.add_argument("--freedom-overlay", action="store_true",
                      help="overlay private-local access gates and safe storage UI on the Pet economy APK")
    args = p.parse_args()
    if args.pet_economy_overlay:
        overlay = {
            "assets/src/GameMgr/Pet/PetEducationMgr.lua",
            "assets/src/GameMgr/Item/PurchaseViewMgr.lua",
            "assets/src/GameMgr/Item/VipShopViewMgr.lua",
            "assets/src/Utils/pay/PayConfig.lua",
        }
    if args.freedom_overlay:
        overlay = {"assets/src/" + name for name in (
            "GameMgr/Common/BasicMenuMgr.lua",
            "GameMgr/Common/GameGuideMgr.lua",
            "GameMgr/Common/LoginMsgMgr.lua",
            "GameMgr/Common/StatusBarMgr.lua",
            "GameMgr/Player/PersonalCenterMgr.lua",
            "GameMgr/Pet/PetEducationMgr.lua",
            "GameMgr/Pet/PetListMgr.lua",
            "GameMgr/Item/BagViewMgr.lua",
            "Net/Send/PetSend.lua",
        )}
    if args.pet_economy_overlay or args.freedom_overlay:
        with zipfile.ZipFile(args.input) as source, zipfile.ZipFile(args.output, "w") as output:
            if not overlay <= set(source.namelist()):
                raise ValueError("the input APK is missing one or more Lua modules in the selected overlay")
            for info in source.infolist():
                if info.filename.upper().startswith("META-INF/"):
                    continue
                data = source.read(info)
                if info.filename in overlay:
                    data = b"XXTEA" + encrypt((Path("decoded_lua") / info.filename).read_bytes(), b"kyopkm")
                output.writestr(info, data)
        return
    target = "assets/src/GameMgr/Map/SceneMgr.lua"
    capture_language_files = {
        "assets/res/Config/db/lang.db",
        "assets/res/Config/db/lang_en.db",
        "assets/res/Config/db/lang_id.db",
        "assets/res/Config/db/lang_th.db",
        "assets/res/Config/db/lang_tw.db",
        "assets/res/Config/db/lang_vn.db",
    }
    with zipfile.ZipFile(args.input) as source, zipfile.ZipFile(args.output, "w") as output:
        source_names = set(source.namelist())
        db_overrides = {
            name: (Path("apk_extracted/assets") / name.removeprefix("assets/")).read_bytes()
            for name in capture_language_files
            if name in source_names
        }
        for info in source.infolist():
            if info.filename.upper().startswith("META-INF/"):
                continue
            data = source.read(info)
            if info.filename in db_overrides:
                data = db_overrides[info.filename]
            elif info.filename.endswith(".db.b64") and info.filename[:-4] in db_overrides:
                data = base64.b64encode(db_overrides[info.filename[:-4]])
            if info.filename == "AndroidManifest.xml":
                data = patch_activity_config(data)
            if info.filename == "assets/src/GameMgr/Support/LuaSqlite.lua":
                data = b"XXTEA" + encrypt(Path("decoded_lua/assets/src/GameMgr/Support/LuaSqlite.lua").read_bytes(), b"kyopkm")
            if info.filename == "assets/src/Net/Process/PVEProcess.lua":
                data = b"XXTEA" + encrypt(Path("decoded_lua/assets/src/Net/Process/PVEProcess.lua").read_bytes(), b"kyopkm")
            if info.filename == "assets/src/GameMgr/Battle/BattleCCSB.lua":
                data = b"XXTEA" + encrypt(Path("decoded_lua/assets/src/GameMgr/Battle/BattleCCSB.lua").read_bytes(), b"kyopkm")
            if info.filename in {
                "assets/src/GameMgr/Data/PokemonInfo.lua",
                "assets/src/GameMgr/Common/GameGuideMgr.lua",
                "assets/src/GameMgr/Common/GameGuideMgr1.lua",
                "assets/src/GameMgr/Item/GachaViewMgr.lua",
                "assets/src/GameMgr/Map/BattleMapMgr.lua",
                "assets/src/GameMgr/Searching/AdvCharMgr.lua",
                "assets/src/GameMgr/Searching/SearchingMgr.lua",
                "assets/src/Net/Process/ChatProcess.lua",
                "assets/src/Net/CallbackMgr.lua",
                "assets/src/Net/Process/PetProcess.lua",
                "assets/src/Net/Proto/Proto_Pet.lua",
                "assets/src/Net/Send/PetSend.lua",
                "assets/src/GameMgr/Support/NetInterface.lua",
                "assets/src/Net/Reconnector.lua",
                "assets/src/Utils/pay/PayConfig.lua",
                "assets/src/GameMgr/Item/PurchaseViewMgr.lua",
            }:
                source_path = Path("decoded_lua") / info.filename
                data = b"XXTEA" + encrypt(source_path.read_bytes(), b"kyopkm")
            if info.filename == "assets/src/GameMgr/Data/QuestInfo.lua":
                text = decrypt(data[5:], b"kyopkm").decode()
                newline = "\r\n" if "\r\n" in text else "\n"
                text = text.replace("\r\n", "\n")
                old = """            if curQuestDatas[questID] then
                curQuestDatas[questID].status = Proto.QUEST_STATUS_NORMAL
            end
        end"""
                new = old.replace("            end\n        end", "            end\n            CocosModuleMgr.setScreenTouch(true)\n        end")
                if new not in text:
                    assert text.count(old) == 1, "QuestInfo release callback changed unexpectedly"
                    text = text.replace(old, new, 1)
                text = text.replace("\n", newline)
                data = b"XXTEA" + encrypt(text.encode(), b"kyopkm")
            if info.filename.startswith("assets/res/Config/db/") and info.filename.endswith(".db"):
                sidecar_name = info.filename + ".b64"
                if sidecar_name not in source_names:
                    sidecar = zipfile.ZipInfo(sidecar_name)
                    sidecar.compress_type = zipfile.ZIP_DEFLATED
                    output.writestr(sidecar, base64.b64encode(data))
            if info.filename.lower().endswith((".mp4", ".m4a", ".mp3", ".ogg")):
                # Android MediaPlayer opens packaged media through AssetFileDescriptor.
                info.compress_type = zipfile.ZIP_STORED
            if info.filename == target:
                text = decrypt(data[5:], b"kyopkm").decode()
                old = '    print("开始加载新场景"..sceneName)'
                entry_trace = '    print("[SCENE_DIAG] from="..tostring(SceneMgr.currentScene).." to="..tostring(sceneName).." stack="..debug.traceback())'
                if entry_trace not in text:
                    assert text.count(old) == 1
                    text = text.replace(old, old + '\n' + entry_trace, 1)
                old = 'local ret,errMessage = pcall(function()\n                replaceFunc()\n            end)'
                # Preserve the exact line endings of the existing asset.
                text = text.replace('\r\n', '\n')
                if old in text:
                    text = text.replace(old, 'local ret,errMessage = xpcall(replaceFunc, function(err)\n                local trace = debug.traceback(tostring(err), 2)\n                print("[SCENE_DIAG] initialization_failed target="..tostring(sceneName).." error="..trace)\n                return trace\n            end)', 1)
                else:
                    assert '[SCENE_DIAG] initialization_failed' in text, "scene init diagnostics missing"
                data = b"XXTEA" + encrypt(text.encode(), b"kyopkm")
            output.writestr(info, data)


if __name__ == "__main__":
    main()
