local ExploreInfo = {}

local ExploreInfoConfig = nil
local ExploreRandomAwardInfoConfig = nil
local ExplorePacketBuyInfoConfig = nil
local ExploreEventSInfoConfig = nil
local ExploreInfoData = nil

local exploreData = {}
local diffcultDatas = {}
local startTime = nil

local scheduler = require("src.framework.scheduler")
local refreshGoldHandler = nil
local bagFullTipHandler = nil

function ExploreInfo.Init()
    if ExploreInfoConfig==nil then
        ExploreInfoConfig = require("src.DatReader.ExploreInfoConfig")
        ExploreInfoConfig.init()
    end
    
    if ExploreRandomAwardInfoConfig==nil then
        ExploreRandomAwardInfoConfig = require("src.DatReader.ExploreRandomAwardInfoConfig")
        ExploreRandomAwardInfoConfig.init()
    end
    
    if ExplorePacketBuyInfoConfig==nil then
        ExplorePacketBuyInfoConfig = require("src.DatReader.ExplorePacketBuyInfoConfig")
        ExplorePacketBuyInfoConfig.init()
    end
    
    if ExploreEventSInfoConfig==nil then
        ExploreEventSInfoConfig = require("src.DatReader.ExploreEventSInfoConfig")
        ExploreEventSInfoConfig.init()
    end
    
    if ExploreInfoData==nil then
        local ExploreInfoReader = TxtReader.new("Config/Explore.txt")
        ExploreInfoData = ExploreInfoReader.init({"aid", "name", "mapf", "map", "mapb", "icon", "iconl"}, 1)
        local searchInfoVec = {}
        for key, var in pairs(WorldMapInfo.getSearchInfo()) do
            for k, v in pairs(var) do
                searchInfoVec[v.info] = {key, v.id}
            end
        end
        for key, var in pairs(ExploreInfoData) do
            local resName = EmbeddedMapMgr.getMapResByID(WorldMapInfo.getEmbeddedMapID(searchInfoVec[key][1], searchInfoVec[key][2]))
            ExploreInfoData[key].mapf = string.gsub(resName, ".png", "_front.png")
            ExploreInfoData[key].map = resName
            ExploreInfoData[key].mapb = string.gsub(resName, ".png", "_back.png")
        end
    end
    
    exploreData = {{events={}}}
    diffcultDatas = {}
    startTime = nil
    
    if refreshGoldHandler then
        scheduler.unscheduleGlobal(refreshGoldHandler)
        refreshGoldHandler = nil
    end
    if bagFullTipHandler then
        scheduler.unscheduleGlobal(bagFullTipHandler)
        bagFullTipHandler = nil
    end
end

function ExploreInfo.update(idx, dataStr)
    --当前只能同时挂一处
    idx = 1
    
	print("挂机数据", idx, dataStr)
    local cjson = require("cjson")
    local tbl = cjson.decode(dataStr)
    if not tbl then
    	return
    end
    exploreData[idx] = {}
    exploreData[idx] = tbl
    
    if not exploreData[idx].events then
        exploreData[idx].events = {}
    end
    local id = exploreData[idx].exploreID
    if not id then
        return
    end
    local eventsVec = {}
    for key, var in pairs(exploreData[idx].events) do
        table.insert(eventsVec, var)
    end
    exploreData[idx].events = eventsVec
    if type(exploreData[idx].nextGetAwardTime)=="table" then
        exploreData[idx].nextGetAwardTime = exploreData[idx].nextGetAwardTime["$numberLong"]
    end
    
    ExploreInfo.refreshServerTime()
end

function ExploreInfo.refreshServerTime()
    local idx = 1
    local id = exploreData[idx].exploreID
    local eventsVec = exploreData[idx].events
    local nextTime = exploreData[idx].nextGetAwardTime
    if startTime==nil then
    	startTime = exploreData[idx].startTime
    end
    if not id or not eventsVec or not nextTime or not startTime then
        return
    end
    
    local function checkExploreBag()
        if #eventsVec>=CharInfo.get().explorepacketnum then
            ExploreViewMgr.addRedPoint(1)
        else
            if bagFullTipHandler then
                scheduler.unscheduleGlobal(bagFullTipHandler)
            end
            local timediff = nextTime - CharInfo.getServerTime()
            local timep = ExploreInfo.getExploreInfoByID(id).randomAwardTime
            timediff = timediff + (CharInfo.get().explorepacketnum-#eventsVec-1)*timep
            print(timediff.."秒后，探索背包满...")
            if timediff<0 then
                ExploreViewMgr.addRedPoint(1)
            else
                bagFullTipHandler = scheduler.performWithDelayGlobal(function()
                    ExploreViewMgr.addRedPoint(1)
                end, timediff)
                BaseFunction.cancelLocalNotificationWithKey(1)
                BaseFunction.registerLocalNotification(os.time()+timediff, nil, "idling27", "", 1, 0)
            end
        end
    end
    checkExploreBag()
    
    local sec = ExploreInfo.getExploreInfoByID(id).normalAwardTime
    local timediff = CharInfo.getServerTime() - startTime    
    local times = math.floor(timediff/sec)
    startTime = startTime+times*sec
    local nextrefreshtime = sec-timediff%sec
    local normalmoney = ExploreInfo.getExploreInfoByID(id).normalMoney
    local money = CharInfo.getGCash()+times*normalmoney
    CharInfo.set({g_cash=money})
    print("挂机金币刷新", nextrefreshtime, money, timediff, times)
    if refreshGoldHandler then
        scheduler.unscheduleGlobal(refreshGoldHandler)
    end
    refreshGoldHandler = scheduler.performWithDelayGlobal(function()
        local function refresh()
            startTime = startTime+sec
            local money = CharInfo.getGCash()+normalmoney
            CharInfo.set({g_cash=money})
            refreshGoldHandler = scheduler.performWithDelayGlobal(function()
                refresh()
            end, sec)
        end
        refresh()
    end, nextrefreshtime)
end

function ExploreInfo.getCurAwardsItemNum()
    local idx = 1
    local id = exploreData[idx].exploreID
    local eventsVec = exploreData[idx].events
    local nextTime = exploreData[idx].nextGetAwardTime
    local startTime = exploreData[idx].startTime
    if not id or not eventsVec or not nextTime or not startTime then
        return 0
    end
    if #eventsVec>=CharInfo.get().explorepacketnum then
        return #eventsVec
    else
        local timediff = nextTime - CharInfo.getServerTime()
        local timep = ExploreInfo.getExploreInfoByID(id).randomAwardTime
        if timediff<0 then
            local addNum = math.ceil(math.abs(timediff/timep))
            if addNum+#eventsVec>CharInfo.get().explorepacketnum then
                return CharInfo.get().explorepacketnum
            else
                return addNum+#eventsVec
            end
        else
            return #eventsVec
        end
    end
end

function ExploreInfo.updateDiffcultDatas(dataStr)
    print("挂机层数数据更新", dataStr)
    local cjson = require("cjson")
    local tbl = cjson.decode(dataStr)
    for key, var in pairs(tbl) do
    	diffcultDatas[tonumber(key)] = tonumber(var)
    end
end

---exploreID, nextGetAwardTime, startTime, updateTime
--events: count, item, eventID
function ExploreInfo.get()
    --当前只能同时挂一处
    local idx = 1
    
    if exploreData[idx] then
    	return exploreData[idx]
    end
    return {events={}}
end

function ExploreInfo.getDiffcult(idx)
    local attr = exploreData[idx].needAttr
    return diffcultDatas[attr]
end

function ExploreInfo.getExploreInfoData()
    return ExploreInfoData
end

function ExploreInfo.getExploreInfoDataByID(attr)
    return ExploreInfoData[attr]
end

function ExploreInfo.getSeverExploreData()

end

--[[
data.id=Proto.parseDWORD(entry); -- 探索ID
data.name=Proto.parseString(entry); -- 名称
data.needStar=Proto.parseDWORD(entry); -- 解锁星级
data.normalMoney=Proto.parseDWORD(entry); -- 探索总时间
data.normalPetExp=Proto.parseDWORD(entry); -- 探索领队类型
data.normalAwardTime=Proto.parseDWORD(entry); -- 固定收益时间间隔
data.randomAwardIDs=Proto.parseVector(entry,Proto.parseDWORD); -- 随机物品掉落ID
data.randomAwardTime=Proto.parseDWORD(entry); -- 随机收益时间间隔
data.territorialTime=Proto.parseDWORD(entry); -- 领主随机收益时间
data.familyTime=Proto.parseDWORD(entry); -- 家族成员随机收益
data.worldID=Proto.parseDWORD(entry); -- 地图ID
]]
function ExploreInfo.getExploreInfoByID(id)
    local data = ExploreInfoConfig.readEntryByID(id)
    local info = {}
    for key, var in pairs(data) do
    	info[key] = var
    end
    local vipLevel = CharInfo.getVIPLevel()
    local vipInfo = CharInfo.getVipInfoByID(vipLevel)
    info.randomAwardTime = info.randomAwardTime*(1-vipInfo.exploreAwardTimeReduceRate/100)
    info.territorialTime = info.territorialTime*(1-vipInfo.exploreAwardTimeReduceRate/100)
    info.familyTime = info.familyTime*(1-vipInfo.exploreAwardTimeReduceRate/100)
    return info
end

function ExploreInfo.getExplorePacketBuyCostStr(id)
    local data = ExplorePacketBuyInfoConfig.readEntryByID(id)
    local tmpStr = ""
    if data.gcash~=0 then
        --阿杜修改英文版显示
        if LuaSqlite.LANG_TYPE ~=3 then
            tmpStr = CocosModuleMgr.createStringWithFormat({"<1><2>", data.gcash, "tips16"})
        else
            tmpStr = CocosModuleMgr.createStringWithFormat({"idling140", data.gcash})
        end
    end
    if data.mcash~=0 then
        if tmpStr~="" then
            tmpStr = tmpStr..","
        end
        --阿杜修改英文版显示
        if LuaSqlite.LANG_TYPE ~=3 then
            tmpStr = tmpStr..CocosModuleMgr.createStringWithFormat({"<1><2>", data.mcash, "tips17"})
        else
            tmpStr = tmpStr..CocosModuleMgr.createStringWithFormat({"idling141", data.mcash})
        end
    end
    return tmpStr
end

--[[
data.id=Proto.parseDWORD(entry); -- 
data.gcash=Proto.parseDWORD(entry); -- G币
data.mcash=Proto.parseDWORD(entry); -- M币
]]
function ExploreInfo.getExplorePacketBuyInfoByID(id)
    return ExplorePacketBuyInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- 
data.rate=Proto.parseDWORD(entry); -- 概率
data.itemID=Proto.parseDWORD(entry); -- 道具ID
data.count=Proto.parseDWORD(entry); -- 数量
data.eventLevel=Proto.parseDWORD(entry); -- 事件等级
]]
function ExploreInfo.getExploreRandomAwardInfoByID(id)
    return ExploreRandomAwardInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.eventType=Proto.parseDWORD(entry); --  探索类型,ExploreTypes
data.name=Proto.parseString(entry); -- 名称
data.describe=Proto.parseString(entry); -- 描述
data.quality=Proto.parseDWORD(entry); -- 品质
data.recover=Proto.parseDWORD(entry); -- 回复体力
data.rewardElement=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励元素
data.rewardNum=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励数量
data.parameter=Proto.parseString(entry); -- 参数
--]]
function ExploreInfo.getExploreEventSInfoByID(id)
    return ExploreEventSInfoConfig.readEntryByID(id)
end

return ExploreInfo