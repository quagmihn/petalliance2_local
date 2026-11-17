local LuaSqlite = {}

require("src.GameMgr.Support.AndroidFunction")

LuaSqlite.LANG_TYPE = 1 --1简2繁3英4日
LuaSqlite.FONT_SIZE_DIFF = {nil, nil, 2, nil}

local sqlite3 = nil
local langInfoData = nil
local filename = ""
local foldername = ""
local curLangFilename = ""
local lang_table = {}
local missingLanguageKeys = {}
local languageDatabasePath = ""
local languageTranslationCount = 0
local languageInitAttempted = false
local languageInitialized = false
local loggedEarlyLookup = false
local diagnosticKeys = {
    menu5=true, town8=true, npcname2=true, npcnick4=true, train99998=true,
    activity51=true, login21=true, login22=true,
}

local function readLanguageOptions()
    local fileUtils = cc.FileUtils:getInstance()
    local relativePath = "Config/lang.txt"
    local content = fileUtils:getStringFromFile(fileUtils:fullPathForFilename(relativePath))
    if not content or content == "" then
        content = fileUtils:getStringFromFile(relativePath)
    end
    if not content or content == "" then
        print("[LANG_DIAG] language catalog is missing:", relativePath)
        return {}
    end

    if string.sub(content, 1, 5) == "XXTEA" then
        local crypto = require("src.framework.crypto")
        local ok, decoded = pcall(crypto.decryptXXTEA, string.sub(content, 6), "kyopkm")
        if not ok or not decoded then
            print("[LANG_DIAG] cannot decrypt Config/lang.txt:", tostring(decoded))
            return {}
        end
        content = decoded
    end

    if string.sub(content, 1, 3) ~= "ID\t" then
        print("[LANG_DIAG] Config/lang.txt has an unexpected header")
        return {}
    end

    content = string.gsub(content, "\r", "")
    local result = {}
    local isHeader = true
    for line in string.gmatch(content .. "\n", "([^\n]*)\n") do
        if isHeader then
            isHeader = false
        elseif line ~= "" then
            local fields = {}
            for field in string.gmatch(line .. "\t", "([^\t]*)\t") do
                fields[#fields + 1] = field
            end
            local id = tonumber(fields[1])
            if id and fields[2] and fields[3] and fields[4] then
                result[id] = {fileName=fields[2], folderName=fields[3], lang=fields[4]}
            end
        end
    end
    return result
end

function LuaSqlite.Init()
    languageInitAttempted = true
    languageInitialized = false
    loggedEarlyLookup = false
    lang_table = {}
    curLangFilename = ""
    languageDatabasePath = ""
    languageTranslationCount = 0
    sqlite3 = require("lsqlite3")
    if langInfoData == nil then
        langInfoData = readLanguageOptions()
    end

    local requestedFilename = UserSettings.get("language", 4)
    local selectionSource = "saved_setting"
    local requestedFound = false
    for languageID, languageInfo in pairs(langInfoData) do
        if languageInfo.fileName == requestedFilename then
            filename = requestedFilename
            LuaSqlite.LANG_TYPE = languageID
            foldername = languageInfo.folderName
            requestedFound = true
            break
        end
    end
    if not requestedFound then
        selectionSource = "device_locale"
        filename = LuaSqlite.getDeviceLanguage()
        for languageID, languageInfo in pairs(langInfoData) do
            if languageInfo.fileName == filename then
                LuaSqlite.LANG_TYPE = languageID
                foldername = languageInfo.folderName
                requestedFound = true
                break
            end
        end
    end
    if not requestedFound then
        selectionSource = "english_fallback"
        for languageID, languageInfo in pairs(langInfoData) do
            if languageInfo.fileName == "lang_en" then
                filename = languageInfo.fileName
                LuaSqlite.LANG_TYPE = languageID
                foldername = languageInfo.folderName
                requestedFound = true
                break
            end
        end
    end
    AndroidFunction.PushLanguage()

    print(string.format("[LANG_DIAG] selection_source=%s requested_language=%s selected_file=%s type=%s folder=%s options=%d",
        tostring(selectionSource), tostring(requestedFilename),
        tostring(filename), tostring(LuaSqlite.LANG_TYPE), tostring(foldername),
        (function() local n = 0; for _ in pairs(langInfoData) do n = n + 1 end; return n end)()))
    if not LuaSqlite.initLanguageDB() and filename ~= "lang_en" then
        print("[LANG_DIAG] selected database failed; trying English fallback:", tostring(filename))
        for languageID, languageInfo in pairs(langInfoData) do
            if languageInfo.fileName == "lang_en" then
                filename = languageInfo.fileName
                LuaSqlite.LANG_TYPE = languageID
                foldername = languageInfo.folderName
                break
            end
        end
        LuaSqlite.initLanguageDB()
    end
end

function LuaSqlite.getLangInfoData()
    return langInfoData
end

function LuaSqlite.getLangFolderName()
    return foldername
end

function LuaSqlite.getDeviceLanguage()
    local currentLanguageType = cc.Application:getInstance():getCurrentLanguage()
    print("current language code", currentLanguageType)
    local langID = 3
    local lang = nil

    --[[
    ENGLISH=0, CHINESE=1, FRENCH=2, ITALIAN=3, GERMAN=4, SPANISH=5, DUTCH=6, RUSSIAN=7,
    KOREAN=8, JAPANESE=9, HUNGARIAN=10, PORTUGUESE=11, ARABIC==12, NORWEGIAN=13, POLISH=14
	VIETNAMESE=15, THAI=16, INDONESIAN=17]]
    if currentLanguageType == 0 then
        langID = 3
        print("current language is English")  
    elseif currentLanguageType == 1 then
        if BaseFunction.isTraditionalChinese()==true then
            langID = 2
            print("current language is Chinese hant") 
        else
            langID = 1
            print("current language is Chinese hans") 
        end
    elseif currentLanguageType == 15 and device.platform=="android" then
        langID = 6
        print("current language is Vietnamese")
    elseif currentLanguageType == 16 and device.platform=="android" then
        langID = 5
        print("current language is Thai")
    elseif currentLanguageType == 17 and device.platform=="android" then
        langID = 4
        print("current language is Indonesian")		
    end
    
    if langInfoData[langID] then
        lang = langInfoData[langID].fileName
    else
        for key, var in pairs(langInfoData) do
            lang = var.fileName
        	break
        end
    end

    return lang
end

function LuaSqlite.loadDB(name, tableName)
    local filePath = cc.FileUtils:getInstance():fullPathForFilename(name)

    print("loadDB db filepath is,platform is.."..filePath,device.platform)
    local db = sqlite3.open(filePath)
    local isOpen = db:isopen()
    if isOpen then
        local dbtabel = db:rows("SELECT * FROM "..tableName)
        local i = 1
        for row in db:rows("SELECT * FROM "..tableName) do
            dbtabel[i] = row
        end
        db:close()
        return dbtabel
    else
        TipsMgr.show(nil, "Failed to load:"..name)
        return nil
    end
end

local function getLanguageDatabasePath()
    local fileUtils = cc.FileUtils:getInstance()
    local relativePath = "Config/db/"..filename..".db"
    local cachePath = fileUtils:getWritablePath().."language_"..filename..".db"
    local sqliteHeader = "SQLite format 3\0"
    local searchPaths = fileUtils:getSearchPaths() or {}
    local resolvedPath = fileUtils:fullPathForFilename(relativePath)
    local candidates = {}
    local candidateSet = {}
    local function addCandidate(path)
        if type(path) == "string" and path ~= "" and not candidateSet[path] then
            candidateSet[path] = true
            candidates[#candidates + 1] = path
        end
    end
    addCandidate(resolvedPath)
    addCandidate(relativePath)

    print(string.format("[LANG_DIAG] search_paths=%s getDataFromFile_api=%s",
        table.concat(searchPaths, "|"), tostring(type(fileUtils.getDataFromFile) == "function")))
    print(string.format("[LANG_DIAG] resolved_path=%s", tostring(resolvedPath)))

    local contents = nil
    local sourcePath = nil
    local fileUtilsError = nil
    for _, candidatePath in ipairs(candidates) do
        local existsOk, exists = pcall(function()
            return fileUtils:isFileExist(candidatePath)
        end)
        local readOk, candidateBytes = pcall(function()
            return fileUtils:getStringFromFile(candidatePath)
        end)
        local readSuccess = readOk and type(candidateBytes) == "string" and #candidateBytes > 0
        local headerValid = readSuccess and string.sub(candidateBytes, 1, 16) == sqliteHeader
        print(string.format("[LANG_DIAG] candidate_path=%s fileutils_exists=%s read_success=%s asset_byte_length=%d sqlite_header_valid=%s",
            candidatePath, tostring(existsOk and exists or false), tostring(readSuccess),
            readSuccess and #candidateBytes or 0, tostring(headerValid)))
        if headerValid then
            contents = candidateBytes
            sourcePath = candidatePath
            break
        end
        if not readOk then
            fileUtilsError = debug.traceback(tostring(candidateBytes), 2)
        end
    end
    -- A raw searchPath..relativePath passed to getStringFromFile may be
    -- resolved through the search path list a second time. Temporarily move
    -- each engine-provided path to the front, resolve the relative asset with
    -- FileUtils, read it, then restore the original order and path cache.
    if not contents and type(fileUtils.setSearchPaths) == "function" then
        for index, selectedSearchPath in ipairs(searchPaths) do
            local prioritizedPaths = {selectedSearchPath}
            for otherIndex, otherSearchPath in ipairs(searchPaths) do
                if otherIndex ~= index then
                    prioritizedPaths[#prioritizedPaths + 1] = otherSearchPath
                end
            end
            local probeOk, probe = pcall(function()
                fileUtils:setSearchPaths(prioritizedPaths)
                if type(fileUtils.purgeCachedEntries) == "function" then
                    fileUtils:purgeCachedEntries()
                end
                local candidatePath = fileUtils:fullPathForFilename(relativePath)
                local exists = fileUtils:isFileExist(candidatePath)
                local bytes = fileUtils:getStringFromFile(candidatePath)
                return {path=candidatePath, exists=exists, bytes=bytes}
            end)
            local restoreOk, restoreError = pcall(function()
                fileUtils:setSearchPaths(searchPaths)
                if type(fileUtils.purgeCachedEntries) == "function" then
                    fileUtils:purgeCachedEntries()
                end
            end)
            if not restoreOk then
                error("failed to restore FileUtils search paths: "..tostring(restoreError))
            end
            if not probeOk then
                fileUtilsError = debug.traceback(tostring(probe), 2)
                print(string.format("[LANG_DIAG] candidate_path=%s fileutils_exists=false read_success=false asset_byte_length=0 sqlite_header_valid=false probe_error=%s",
                    tostring(selectedSearchPath)..relativePath, tostring(probe)))
            else
                local candidateBytes = probe.bytes
                local readSuccess = type(candidateBytes) == "string" and #candidateBytes > 0
                local headerValid = readSuccess and string.sub(candidateBytes, 1, 16) == sqliteHeader
                print(string.format("[LANG_DIAG] candidate_path=%s fileutils_exists=%s read_success=%s asset_byte_length=%d sqlite_header_valid=%s",
                    tostring(probe.path), tostring(probe.exists), tostring(readSuccess),
                    readSuccess and #candidateBytes or 0, tostring(headerValid)))
                if headerValid then
                    contents = candidateBytes
                    sourcePath = probe.path
                    break
                end
            end
        end
    end
    if not contents then
        local apiError = fileUtilsError and (" fileutils_error="..fileUtilsError) or ""
        print(string.format("[LANG_DIAG] language=%s database_path=%s database_open_status=missing_or_not_sqlite translation_count=0 fallback_reason=invalid_asset%s",
            tostring(filename), relativePath, apiError))
        return nil
    end

    local cryptoModule = require("src.framework.crypto")
    local sourceChecksum = cryptoModule.md5(contents)
    local temporaryPath = cachePath..".tmp"
    os.remove(temporaryPath)
    local output, openError = io.open(temporaryPath, "wb")
    if not output then
        print(string.format("[LANG_DIAG] language=%s database_path=%s database_open_status=cache_write_failed translation_count=0 fallback_reason=writable_path_unavailable error=%s",
            tostring(filename), temporaryPath, tostring(openError)))
        return nil
    end
    local writeResult, writeError = output:write(contents)
    local closeResult, closeError = output:close()
    if not writeResult or closeResult == nil then
        os.remove(temporaryPath)
        print(string.format("[LANG_DIAG] language=%s database_path=%s database_open_status=cache_write_failed translation_count=0 fallback_reason=cache_write_failed error=%s",
            tostring(filename), temporaryPath, tostring(writeError or closeError)))
        return nil
    end

    local verifyFile, verifyOpenError = io.open(temporaryPath, "rb")
    if not verifyFile then
        os.remove(temporaryPath)
        print(string.format("[LANG_DIAG] language=%s database_path=%s database_open_status=cache_verify_failed translation_count=0 fallback_reason=cache_read_failed error=%s",
            tostring(filename), temporaryPath, tostring(verifyOpenError)))
        return nil
    end
    local cachedBytes = verifyFile:read("*a")
    verifyFile:close()
    local cachedChecksum = type(cachedBytes) == "string" and cryptoModule.md5(cachedBytes) or ""
    if type(cachedBytes) ~= "string" or #cachedBytes ~= #contents or cachedChecksum ~= sourceChecksum
        or string.sub(cachedBytes, 1, 16) ~= sqliteHeader then
        os.remove(temporaryPath)
        print(string.format("[LANG_DIAG] language=%s database_path=%s database_open_status=cache_verify_failed translation_count=0 fallback_reason=length_checksum_or_header_mismatch source_length=%d cache_length=%d source_md5=%s cache_md5=%s",
            tostring(filename), temporaryPath, #contents, type(cachedBytes) == "string" and #cachedBytes or 0,
            tostring(sourceChecksum), tostring(cachedChecksum)))
        return nil
    end
    local renameOk, renameError = os.rename(temporaryPath, cachePath)
    if not renameOk then
        os.remove(temporaryPath)
        print(string.format("[LANG_DIAG] language=%s database_path=%s database_open_status=cache_commit_failed translation_count=0 fallback_reason=atomic_rename_failed error=%s",
            tostring(filename), cachePath, tostring(renameError)))
        return nil
    end

    languageDatabasePath = cachePath
    print(string.format("[LANG_DIAG] language=%s source_path=%s database_path=%s database_open_status=asset_copied translation_count=0 fallback_reason=none asset_byte_length=%d md5=%s",
        tostring(filename), tostring(sourcePath), cachePath, #contents, tostring(sourceChecksum)))
    return cachePath
end

function LuaSqlite.initLanguageDB()
    local filePath = getLanguageDatabasePath()
    if not filePath then
        return false
    end
    if curLangFilename == filename and next(lang_table) ~= nil then
        return true
    end
    lang_table = {}

    local db = sqlite3.open(filePath)
    if not db then
        print(string.format("[LANG_DIAG] language=%s database_path=%s database_open_status=open_failed translation_count=0 fallback_reason=sqlite_open_failed",
            tostring(filename), filePath))
        return false
    end
    if db.isopen and not db:isopen() then
        db:close()
        print(string.format("[LANG_DIAG] language=%s database_path=%s database_open_status=closed translation_count=0 fallback_reason=sqlite_handle_closed",
            tostring(filename), filePath))
        return false
    end

    local loaded = 0
    local databaseRowCount = 0
    local ok, err = xpcall(function()
        for row in db:nrows("SELECT COUNT(*) AS count FROM tbl_lang") do
            databaseRowCount = tonumber(row.count) or 0
            break
        end
        -- LuaSQLite3 rows() yields positional return values; nrows() yields
        -- a row table keyed by column name. Use nrows for the table access below.
        for row in db:nrows("SELECT code, lang FROM tbl_lang") do
            local key = row.code
            local value = row.lang
            if key ~= nil and value ~= nil then
                lang_table[tostring(key)] = tostring(value)
                loaded = loaded + 1
            end
        end
    end, function(message)
        return debug.traceback(tostring(message), 2)
    end)
    db:close()
    if not ok or loaded == 0 or databaseRowCount == 0 or loaded ~= databaseRowCount then
        lang_table = {}
        languageTranslationCount = 0
        print(string.format("[LANG_DIAG] language=%s database_path=%s database_open_status=query_failed translation_count=%d sqlite_count=%d fallback_reason=%s",
            tostring(filename), tostring(filePath), loaded, databaseRowCount,
            tostring(err or (loaded == 0 and "empty_tbl_lang" or "row_count_mismatch"))))
        return false
    end
    curLangFilename = filename
    languageTranslationCount = loaded
    languageInitialized = true
    print(string.format("[LANG_DIAG] language=%s database_path=%s database_open_status=ok translation_count=%d sqlite_count=%d fallback_reason=none login21=%s login22=%s",
        tostring(filename), tostring(filePath), loaded,
        databaseRowCount,
        tostring(lang_table.login21), tostring(lang_table.login22)))
    return true
end

function LuaSqlite.getLanguageByKey(key)
    if not languageInitialized then
        if not loggedEarlyLookup then
            loggedEarlyLookup = true
            local status = languageInitAttempted and "initialization_failed" or "not_initialized"
            local reason = languageInitAttempted and "loader_failed_before_lookup" or "lookup_before_init"
            print(string.format("[LANG_DIAG] language=%s database_path=%s database_open_status=%s translation_count=%d lookup_key=%s lookup_result=key fallback_reason=%s",
                tostring(filename), tostring(languageDatabasePath), status,
                languageTranslationCount, tostring(key), reason))
        end
        return tostring(key or "")
    end
    local aliases = {tip15 = "tips15"}
    local str = lang_table[key] or lang_table[aliases[key]]
    if str==nil then
        if key and not missingLanguageKeys[key] then
            missingLanguageKeys[key] = true
            print(string.format("[LANG_DIAG] language=%s database_path=%s database_open_status=%s translation_count=%s lookup_key=%s lookup_result=key fallback_reason=translation_missing",
                tostring(filename), tostring(languageDatabasePath), next(lang_table) and "ok" or "not_loaded",
                tostring(languageTranslationCount), tostring(key)))
        end
        return tostring(key or "")
    end
    str = string.gsub(str, "\\n", "\n")
	if diagnosticKeys[key] and not missingLanguageKeys["found:"..key] then
		missingLanguageKeys["found:"..key] = true
		print(string.format("[LANG_DIAG] language=%s database_path=%s database_open_status=ok translation_count=%s lookup_key=%s lookup_result=%s fallback_reason=none",
			tostring(filename), tostring(languageDatabasePath), tostring(languageTranslationCount), tostring(key), tostring(str)))
	end
	return str
end

return LuaSqlite
