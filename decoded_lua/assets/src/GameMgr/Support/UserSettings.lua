local UserSettings = {}

local UserSettingsFileTable = {}
local SavePath = ""

function UserSettings.Init()
    print("UserSettings初始化")
    UserSettingsFileTable = {
                                "BattleSettings.plist",     --1
                                "ChatSettings.plist",
                                "OtherSettings.plist",
                                "SystemSettings.plist",
                                "MiniMapSettings.plist",    --5
                                "UserInfo.plist",
                                "WorldMapSettings.plist",
                                "TownChatSettings.plist",
                                "TownMapSettings.plist",
                                "SearchingData.plist",      --10
                                "PlayerInfo.plist",
                                "WatchMain.plist",
                                "WatchExtension.plist",
                                "WatchCatchPet.plist",
                                "CommitProto.plist",        --15
                                "iosIAPData.plist",
                            }
    SavePath = string.gsub(CONFIG_STORE_PATH, "download", "settings")
    local checkdir = UserSettings.checkDirOK(SavePath)
    if not checkdir then
    	print("本地设置存储文件夹创建失败")
    end
end

---设置用户本地设置
--@param table table 设置的内容. e.g.{key = value}
--@param tag int UserSettingsFileTable表的标签
function UserSettings.set(table, tag)
    tag = tag or 1
    local valPlist = {}
    if tag==11 or tag==12 or tag==13 then
    	valPlist = table
    else
        valPlist = cc.FileUtils:getInstance():getValueMapFromFile(SavePath..UserSettingsFileTable[tag])
        for key, var in pairs(table) do
            valPlist[key] = var
        end
    end
    cc.FileUtils:getInstance():writeToFile(valPlist, SavePath..UserSettingsFileTable[tag])
end

---获取用户本地设置
--@param key string 设置的名称
--@param tag int UserSettingsFileTable表的标签
function UserSettings.get(key, tag)
    tag = tag or 1
    local valPlist = cc.FileUtils:getInstance():getValueMapFromFile(SavePath..UserSettingsFileTable[tag])
    local value = valPlist[key]
    return value
end

---获取用户某标签下所有本地设置
--@param tag int UserSettingsFileTable表的标签
function UserSettings.getAll(tag)
    if not tag then
        printError("UserSettings.getAll() - Invalid tag")
        return false
    end

    local valPlist = cc.FileUtils:getInstance():getValueMapFromFile(SavePath..UserSettingsFileTable[tag])
    return valPlist
end

function UserSettings.getFullPath(tag)
    if UserSettingsFileTable[tag] then
        return SavePath..UserSettingsFileTable[tag]
    end
    return ""
end

function UserSettings.checkDirOK(path)
    require "lfs"
    local oldpath = lfs.currentdir()
    if lfs.chdir(path) then
        lfs.chdir(oldpath)
        return true
    end
    if lfs.mkdir(path) then
        return true
    end
end

return UserSettings