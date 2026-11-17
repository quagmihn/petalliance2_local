# Runtime localization trace

## Architecture and selection

`GameInit.Init()` initializes `UserSettings` before `LuaSqlite.Init()` (`GameInit.lua`, initialization steps 7 and 8). `LuaSqlite.Init()` reads the saved `SystemSettings.plist` value `language` (tag 4). If it is absent or not in the catalog, it selects a file from the Cocos device locale; if that also fails, it selects `lang_en`. The catalog is the encrypted `assets/res/Config/lang.txt`, decrypted with the game key and parsed into language ID, SQLite filename, resource folder, and display label. Changing language in `SystemOptionsMgr` persists the selected filename and calls `LoginViewMgr.gameReInit()`, which re-runs `GameInit.Init(true)`.

The actual language on a particular Android profile cannot be inferred from the project tree: `SystemSettings.plist` is in the app's writable storage. The runtime diagnostic now prints `selection_source`, `requested_language`, and `selected_file`. With no saved choice, the selection follows `LuaSqlite.getDeviceLanguage()`.

`LangInfo.dat` has its own verified 24,544-record binary format and agrees with the Chinese `lang.db`. No Lua reference to `LangInfo.dat` was found, and no `LangInfo`, `tbl_lang`, or `lang_en.db` string was found in the bundled native shared libraries. The Lua filename-selection path uses `Config/lang.txt`; translation lookup uses SQLite `tbl_lang`. Available evidence therefore supports treating `LangInfo.dat` as a separate/native resource, not as the source for Lua's selected translation table.

## Lookup and file access

`LuaSqlite.getLanguageByKey(key)` reads the in-memory `lang_table`. `CSResourceMgr.setLabelStringByNode()` and `setButtonStringByNode()` call that lookup. The concrete UI paths are:

- `menu5`: `BasicMenuMgr.addBasicMenu()` → `CSResourceMgr.setLabelString()` → `setLabelStringByNode()` → `getLanguageByKey()`.
- `login21`: `LoginViewMgr` server selection label → same `CSResourceMgr` label path.
- `town8`: `TownScene` assigns the map button label → same `CSResourceMgr` label path.

On initialization, the loader reads `Config/lang.txt`, chooses `Config/db/<selected filename>.db`, copies the asset bytes into `<writablePath>/language_<filename>.db`, opens that filesystem copy through `lsqlite3`, and builds `lang_table` from `tbl_lang`. `MyApp:run()` adds `res/` to FileUtils search paths and `MyApp:setSearchPath()` inserts `CONFIG_STORE_PATH` before it. Consequently a cached or partial file in the higher priority writable path can shadow the packaged resource. Previously, the loader tried `fullPathForFilename()` and then the same relative name; both accesses could resolve through that same first search path, so the retry did not necessarily reach the packaged asset.

The loader now logs the live search paths and resolved path, checks the resolved and relative names, then temporarily prioritizes each FileUtils search path in turn and resolves the asset again. This avoids passing a search-path-prefixed name through FileUtils a second time. It restores the original search order and clears the path cache after each probe. It accepts only bytes with the SQLite 3 header. It writes those bytes to a temporary writable file, reopens and checks byte length, SQLite header, and MD5 against the source, then atomically renames the verified file into place. No database bytes are logged. The bundled Lua binding exposes getStringFromFile, fullPathForFilename, getSearchPaths, setSearchPaths, and purgeCachedEntries; it does not expose getDataFromFile.

The database files in `unpacked/assets/res/Config/db/` were verified with SQLite integrity checks and contain these current row counts and examples:

| File | Rows | `menu5` | `login21` | `town8` |
|---|---:|---|---|---|
| `lang.db` | 24,544 | 冒险 | 切换账号 | 集结石 |
| `lang_en.db` | 18,367 | EXPLORE | LOG OUT | ASSEMBLE STONE |
| `lang_vn.db` | 24,457 | Mạo Hiểm | Đổi tài khoản | Đá Tập Kết |

## Root cause and fix

`initLanguageDB()` selected `code, lang` but iterated with `db:rows()` and treated the first yielded value as a row table (`row[1]`, `row[2]`). LuaSQLite3's `rows()` iterator yields positional column values; `nrows()` yields a table keyed by column name. Consequently the loader did not populate `lang_table` (or raised inside the guarded query), treated the query as failed, and `getLanguageByKey()` returned the original key. Runtime evidence additionally showed the resource-read stage failed its SQLite header check even though the APK contains valid databases. The old fallback repeated FileUtils resolution and did not walk the active search path list. The new candidate trace is designed to identify whether the first failing location is an invalid higher-priority cache or the packaged resource read itself.

The loader also queries `SELECT COUNT(*) FROM tbl_lang`, compares the result to the rows loaded, and marks initialization state explicitly. A lookup before initialization and a lookup after failed initialization now have distinct `fallback_reason` values; early lookups emit at most one diagnostic line instead of logging one line per key.

The loader now iterates `db:nrows("SELECT code, lang FROM tbl_lang")` and reads `row.code` / `row.lang`. Selection diagnostics now expose whether the setting, device locale, or English fallback selected the file. Existing lookup diagnostics distinguish a successful translation from the key fallback.

## Verification

- Lua harness exercised the loader with LuaSQLite3-compatible `rows()` positional and `nrows()` named-row behavior, an invalid higher-priority search-path candidate, and a valid later resource candidate.
- Verified `menu5`, `login21`, and `town8` return values in English, switched the saved language, reinitialized the loader, and verified all three Vietnamese values.
- Python SQLite checks confirmed table counts and the same key values in all three databases. The APK asset test extracted the packaged English DB, checked the SQLite header, copied it to a writable temporary path, and opened it to run `PRAGMA integrity_check` and a translation query.
- `luac -p` passed.
- Patched Lua was XXTEA round-tripped byte-for-byte from the rebuilt signed APK; APK v1/v2/v3 signatures verify.
- Waydroid runtime verification was unavailable in this environment (`waydroid status` reports `Session: STOPPED`). No claim is made about the language actually selected in the installed profile or rendered on screen until a fresh device log shows the new candidate trace, successful SQLite count, and lookup entries.
