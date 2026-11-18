# Asset compatibility inventory

A content hash/size/path registry for **16049** files across `apk_raw/unpacked/assets`, `apk_extracted/assets`, `decoded_lua/assets`, and extracted native libraries is in [asset_registry.jsonl](asset_registry.jsonl). Duplicate resources at raw and extracted locations are retained as distinct paths so integrity can be compared by SHA256. Compatibility is initially `SOURCE_PRESENT`; reference graph and runtime compatibility are not inferred from filename/hash alone.

Native library inspection: target includes stripped Android Cocos2d-x/Lua shared objects for armeabi, armeabi-v7a, and arm64-v8a. The arm64 `libcocos2dlua.so` is ELF AArch64; its dynamic symbol table contains Cocos2d, Lua, network, audio, and data-reader registrations. No native binary was modified or replaced.

| File type | Count |
| --- | --- |
| png | 8906 |
| lua | 3338 |
| atlas | 789 |
| csb | 618 |
| skel | 528 |
| m4a | 399 |
| dat | 360 |
| txt | 305 |
| gaf | 296 |
| json | 272 |
| ccbi | 91 |
| xml | 62 |
| plist | 42 |
| db | 9 |
| spine | 8 |
| fnt | 8 |
| so | 6 |
| ttf | 4 |
| mp4 | 4 |
| csd | 2 |
| properties | 1 |
| apk | 1 |

No newer-version resources have been integrated. Such assets need format, ID-reference, animation, texture/font, ABI, Lua loader, and Waydroid compatibility testing before replacement.
