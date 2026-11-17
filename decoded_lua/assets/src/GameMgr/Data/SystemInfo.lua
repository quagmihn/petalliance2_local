local SystemInfo = {}

local GlobalConfigAddInfoConfig = nil
local GlobalConfigAddInfo = {}
local ShieldInfo = nil

function SystemInfo.Init()
    if GlobalConfigAddInfoConfig==nil then
        GlobalConfigAddInfoConfig = require("src.DatReader.GlobalConfigAddInfoConfig")
        GlobalConfigAddInfoConfig.init()
        --[[
        for var=1, GlobalConfigAddInfoConfig.getEntryCount() do
            local id = GlobalConfigAddInfoConfig.getEntryID(var)
            local data = GlobalConfigAddInfoConfig.readEntryByID(id)
            GlobalConfigAddInfo[id] = data
        end]]
    end
    
    if ShieldInfo==nil then
        local ShieldInfoReader = TxtReader.new("Config/hexie.txt")
        ShieldInfo = ShieldInfoReader.init({"sid", "code"}, 1)
    end
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.name=Proto.parseString(entry); -- 属性
data.values=Proto.parseVector(entry,Proto.parseDWORD); -- 值
data.describe=Proto.parseString(entry); -- 描述
--]]
function SystemInfo.getGlobalConfigAddInfoByID(id)
    id = tonumber(id)
    return GlobalConfigAddInfoConfig.readEntryByID(id)
end

function SystemInfo.checkShieldString(content)
    for key, var in pairs(ShieldInfo) do
        local langStr = LuaSqlite.getLanguageByKey(var.code)
        content = string.gsub(content, langStr, string.rep("*", string.len(langStr)))
	end
	return content
end

return SystemInfo