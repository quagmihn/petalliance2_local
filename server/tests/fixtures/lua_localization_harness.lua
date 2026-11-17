package.path = "./?.lua;" .. package.path

local catalog = "ID\tname\tfolder\tlabel\n3\tlang_en\ten\tEnglish\n6\tlang_vn\tvn\tTiếng Việt\n"
local selected = "lang_en"
local activeSearchPaths = {"download/", "res/"}
local data = {
    lang_en = {menu5="EXPLORE", login21="LOG OUT", town8="ASSEMBLE STONE"},
    lang_vn = {menu5="KHÁM PHÁ", login21="Đổi tài khoản", town8="ĐÁ HỘI TỤ"},
}

package.preload["src.GameMgr.Support.AndroidFunction"] = function()
    return {PushLanguage=function() end}
end
package.preload["src.framework.crypto"] = function()
    return {
        decryptXXTEA=function() return catalog end,
        md5=function(value) return tostring(#value) end,
    }
end
package.preload["lsqlite3"] = function()
    return {open=function(path)
        local language = path:match("language_(.-)%.db$")
        local rows = data[language] or {}
        return {
            isopen=function() return true end,
            close=function() end,
            rows=function()
                local emitted = false
                return function()
                    if emitted then return nil end
                    emitted = true
                    return 1, "menu5", rows.menu5
                end
            end,
            nrows=function(_, _query)
                if _query:find("COUNT(*)", 1, true) then
                    local emitted = false
                    return function()
                        if emitted then return nil end
                        emitted = true
                        return {count=3}
                    end
                end
                local keys = {"menu5", "login21", "town8"}
                local index = 0
                return function()
                    index = index + 1
                    local key = keys[index]
                    if not key then return nil end
                    return {code=key, lang=rows[key]}
                end
            end,
        }
    end}
end

UserSettings = {get=function() return selected end}
AndroidFunction = {PushLanguage=function() end}
BaseFunction = {isTraditionalChinese=function() return false end}
device = {platform="android"}
cc = {
    FileUtils={getInstance=function()
        return {
            fullPathForFilename=function(_, path) return (activeSearchPaths[1] or "")..path end,
            getSearchPaths=function()
                local paths = {}
                for index, value in ipairs(activeSearchPaths) do paths[index] = value end
                return paths
            end,
            setSearchPaths=function(_, paths)
                activeSearchPaths = {}
                for index, value in ipairs(paths) do activeSearchPaths[index] = value end
            end,
            purgeCachedEntries=function() end,
            isFileExist=function(_, path) return path:find("Config/db/lang_", 1, true) ~= nil end,
            getStringFromFile=function(_, path)
                if path:find("Config/lang.txt", 1, true) then
                    return "XXTEA" .. string.rep("x", 12)
                end
                if path:sub(1, 8) == "download" or path:sub(1, 14) == "Config/db/lang" then
                    return "stale partial cache"
                end
                if path:sub(1, 4) == "res/" then
                    return "SQLite format 3\0" .. string.rep("x", 32)
                end
                return ""
            end,
            getWritablePath=function() return "/tmp/" end,
        }
    end},
    Application={getInstance=function()
        return {getCurrentLanguage=function() return 0 end}
    end},
}

local LuaSqlite = dofile("decoded_lua/assets/src/GameMgr/Support/LuaSqlite.lua")
LuaSqlite.Init()
assert(LuaSqlite.getLanguageByKey("menu5") == "EXPLORE")
assert(LuaSqlite.getLanguageByKey("login21") == "LOG OUT")
assert(LuaSqlite.getLanguageByKey("town8") == "ASSEMBLE STONE")

selected = "lang_vn"
LuaSqlite.Init()
assert(LuaSqlite.getLanguageByKey("menu5") == "KHÁM PHÁ")
assert(LuaSqlite.getLanguageByKey("login21") == "Đổi tài khoản")
assert(LuaSqlite.getLanguageByKey("town8") == "ĐÁ HỘI TỤ")
print("LUA_LOCALIZATION_HARNESS_OK")
