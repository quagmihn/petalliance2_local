local ExpeditionQuestInfo = require("src.GameMgr.Data.ExpeditionQuestInfo") 
local ExpeditionalInfo = class("ExpeditionalInfo")
local map_Infomation   = nil 
local node_infomation  = nil
local routeTable       = {}
local invisibleTable   = {}
local mapInfoTable     = {}
local pointsInfoTable  = {}
local ExpeditionLotteryInfoConfig     = nil
local ExpeditionMonsterPoolInfoConfig = nil
local ExpeditionMonsterInfoConfig     = nil
local ExpeditionInfoConfig            = nil
local LotteryBuyCountInfoConfig       = nil


function ExpeditionalInfo:init()
    ExpeditionQuestInfo.init()
    if not ExpeditionInfoConfig then 
        ExpeditionInfoConfig = require("src.DatReader.ExpeditionInfoConfig")
        ExpeditionInfoConfig.init()
    end

    if not ExpeditionLotteryInfoConfig then
        ExpeditionLotteryInfoConfig = require("src.DatReader.ExpeditionLotteryInfoConfig")
        ExpeditionLotteryInfoConfig.init()
    end

    if not ExpeditionMonsterPoolInfoConfig then
        ExpeditionMonsterPoolInfoConfig = require("src.DatReader.ExpeditionMonsterPoolInfoConfig")
        ExpeditionMonsterPoolInfoConfig.init()
    end
    
    if not ExpeditionMonsterInfoConfig then
        ExpeditionMonsterInfoConfig = require("src.DatReader.ExpeditionMonsterInfoConfig")
        ExpeditionMonsterInfoConfig.init()
    end

    if not LotteryBuyCountInfoConfig then
        LotteryBuyCountInfoConfig = require("src.DatReader.LotteryBuyCountInfoConfig")
        LotteryBuyCountInfoConfig.init()
    end

    if not map_Infomation then
        local mapLineInfo   = TxtReader.new("Config/ExpeditionMap.txt")
        map_Infomation      = mapLineInfo.init({"mapid", "name", "res", "info"}, 1)
    
        for key, var in pairs(map_Infomation) do 
            local mapid = tonumber(var.mapid)
            local mapinfo = var.info
            local infoVec = lua_string_split(mapinfo, ",")
            mapInfoTable[mapid] = {name=var.name, res=var.res, mapResPath = var.mapResPath}
            routeTable[mapid]       = {}
            invisibleTable[mapid]   = {}
            pointsInfoTable[mapid]  = {}
            
            for idx = 1, #infoVec do
                local idVec = lua_string_split(infoVec[idx], "-")
                if #idVec==2 then
                    table.insert(routeTable[mapid], {tonumber(idVec[1]), tonumber(idVec[2])})
                end
            end
        end
        
        local nodeLineInfo = TxtReader.new("Config/ExpeditionNode.txt")
        node_infomation = nodeLineInfo.init({"mapid", "pid", "ptype", "pparam", "showmapid", "pname"},nil,{
            mapid = 1,pid = 1,ptype = 1,pparam = 1,showmapid = 1
            })
        -- print("node_infomation~~",sz_T2S(node_infomation)) 
        for key, var in pairs(node_infomation) do
            local mapid = tonumber(var.mapid)
            local pid = tonumber(var.pid)
            local ptype = tonumber(var.ptype)
            local pparam = var.pparam
            local showmapid = tonumber(var.showmapid)
            local pname = var.pname
            -- local lockIndex = tonumber(var.lockid)
            local iconPath = ""
            -- print("ptype~~~~~~~~~",ptype)
            if ptype==WorldMapInfo.POINT_TYPE_INVISIBLE then
                invisibleTable[mapid].pid = var.pid
                -- print("POINT_TYPE_INVISIBLE~~~~~~~~~",var.pid)
            elseif ptype==WorldMapInfo.POINT_TYPE_TOWN then

            end

            pointsInfoTable[mapid][key] = var

            -- if var.icon then
            --  iconPath = "Map/WorldMap/icon/"..var.icon..".png"
            -- end
            -- if lockIndex then
            --     if not lockIDsVec[lockIndex] then
            --      lockIDsVec[lockIndex] = {}
            --     end
            --     table.insert(lockIDsVec[lockIndex], {mapid=mapid, pid=pid})
            -- end            
            -- bgInfoTable[mapid][pid] = showmapid
            -- if ptype==WorldMapInfo.POINT_TYPE_TOWN then
            --     townTable[mapid][pid] = {id=pid, info=pparam}
            -- elseif ptype==WorldMapInfo.POINT_TYPE_STAGE then
            --     local avID = tonumber(pparam)
            --     lockAdvTable[avID] = lockIndex
            --     searchTable[mapid][pid] = {id=pid, info=avID}
            --     mapNodeIconTable[tonumber(pparam)] = iconPath
            -- elseif ptype==WorldMapInfo.POINT_TYPE_EXPLORE then
            --     exploreTable[mapid][pid] = {id=pid, info=tonumber(pparam)}
            -- elseif ptype==WorldMapInfo.POINT_TYPE_TRANSFER then
            --     local transferInfoVec = lua_string_split(pparam, "-")
            --     local mID = 1
            --     if transferInfoVec[1] then
            --         mID = tonumber(transferInfoVec[1]) or 1
            --     end
            --     local pID = 1
            --     if transferInfoVec[2] then
            --         pID = tonumber(transferInfoVec[2]) or 1
            --     end
            --     transferTable[mapid][pid] = {id=pid, info=mID, param=pID}
            -- elseif ptype==WorldMapInfo.POINT_TYPE_TEAM then
            --     teamTable[mapid] = {pid=pid, level=mapid*10, aid=tonumber(pparam), name=pname, lock=lockIndex, icon=iconPath}
            -- elseif ptype==WorldMapInfo.POINT_TYPE_BOSS then
            --     bossTable[mapid] = {pid=pid, name=pname}
            -- elseif ptype==WorldMapInfo.POINT_TYPE_INVISIBLE then
            --     invisibleTable[mapid][pid] = {id=pid, info={}}
            -- elseif ptype==WorldMapInfo.POINT_TYPE_EMPTY then
            --     if var.pevent~=nil then
            --         local pevent = lua_string_split(var.pevent, ",")
            --         eventTable[mapid][pid] = {id=pid, info=pevent}
            --     else
            --         eventTable[mapid][pid] = {id=pid, info={}}
            --     end
            -- end
            -- lockTable[mapid][pid] = lockIndex
            -- pointTable[mapid][pid] = {type=ptype, name=pname, param=tonumber(pparam)}
        end
    end

end

function ExpeditionalInfo:getLotteryBuyCountInfoById(id)
    return LotteryBuyCountInfoConfig.readEntryByID(id)
end

function ExpeditionalInfo:getExpeditionLotteryInfoById(id)
    return ExpeditionLotteryInfoConfig.readEntryByID(id)
end

function ExpeditionalInfo:getExpeditionMonsterPoolInfoById(id)
    return ExpeditionMonsterPoolInfoConfig.readEntryByID(id)
end


function ExpeditionalInfo:getExpeditionMonsterInfoConfigById(id)
    return ExpeditionMonsterInfoConfig.readEntryByID(id)
end

function ExpeditionalInfo:getExpeditionInfoConfigById(id)
    return ExpeditionInfoConfig.readEntryByID(id)
end

function ExpeditionalInfo:ctor(data,petsList)
	self.ExpeditionalType  = 0
	self.createdTime       = 0
    self.expeditionData    = data
	self.buyCount       = 0
    self.maxBuyCount    = 0
    self.petsList       = petsList
end

function ExpeditionalInfo:setmaxBuyCount(count)
    self.maxBuyCount =  count
end

function ExpeditionalInfo:getmaxBuyCount()
    return self.maxBuyCount
end

function ExpeditionalInfo:setbuyCount(count)
    self.buyCount = count
end

function ExpeditionalInfo:getbuyCount()
    return self.buyCount
end

function ExpeditionalInfo:setBattleHp(index,hp)
    self.expeditionData.mapList[index].hp = hp
end

function ExpeditionalInfo:getExpeditionData()
    return self.expeditionData
end

function ExpeditionalInfo:getExpeditionQuestInfoById(id)
    return ExpeditionQuestInfo:getExpeditionQuestInfoById(id)
end

function ExpeditionalInfo:setPoint(val)
    local point = 1
    if val then
        self.expeditionData.point = 0
        return
    end
    if self.expeditionData.point then
        self.expeditionData.point = self.expeditionData.point + point
    else
        print("error:  setPoint  set fail ")  
    end
end

function ExpeditionalInfo:checkQuestProgress(quests,pparam)
    local finishQuest = {}
    for key,var in pairs(quests) do 
        local isFinish = false
        if self.expeditionData.finishQuest and #self.expeditionData.finishQuest > 0  then 
            for k,v in pairs(self.expeditionData.finishQuest[pparam].quests) do 
                if v == var then
                    isFinish = true
                end
            end
        else
            for key,var in pairs(self.expeditionData.mapList) do 
                self.expeditionData.finishQuest[key] = {}
                self.expeditionData.finishQuest[key].quests = {}
            end
        end
        if not isFinish then
            local tp    = ExpeditionQuestInfo:getExpeditionQuestInfoById(var).type + 1
            -- print("远征任务类型是",tp)
            local quest = ExpeditionQuestInfo.commonFunctions[tp](var) 
            if quest then
                if quest[1] then
                    finishQuest[#finishQuest+1] = quest
                    table.insert(self.expeditionData.finishQuest[pparam].quests,var)
                end
            end
        end
    end
    return finishQuest
end

function ExpeditionalInfo:applyQuestProgress(pparam,taskID)
    table.insert(self.expeditionData.finishQuest[pparam].quests,taskID)
end

function ExpeditionalInfo:getDropUnusedCount()
    local count = self.expeditionData.point - self.expeditionData.usedCount
    return count
end

function ExpeditionalInfo:setUseCount()
    if self.expeditionData.usedCount then
        self.expeditionData.usedCount = self.expeditionData.usedCount + 1
    else
        print("error:  setUseCount  set fail ")
    end
end

function ExpeditionalInfo:getMaxBuyTimes()
    local count = 0
    for key,var in pairs(self.expeditionData.mapList) do
        local maxNum = #var.quests
        if #self.expeditionData.finishQuest > 0 then
            if #self.expeditionData.finishQuest[key] >= maxNum then
                count = count + 1
            end
        end    
    end

    local maxCount = self.expeditionData.currentSchedule - count

    return maxCount
end

function ExpeditionalInfo:setMyPetHp(objID,hp,hpmax)
    -- local hpx = math.floor(hp/hpmax*10000)
    -- local isHave = false
    -- for key,var in pairs(self.expeditionData.petDetail) do
    --     if var.currentPet == objID then
    --         self.expeditionData.petDetail[key].currentPetHp = hpx
    --         isHave = true
    --     end
    -- end 

    -- if not isHave then
    --     local index = #self.expeditionData.petDetail+1
    --     self.expeditionData.petDetail[index] = {}
    --     self.expeditionData.petDetail[index].objID = objID
    --     self.expeditionData.petDetail[index].hp    = hpx
    -- end

end

function ExpeditionalInfo:createExpedition(data)
    local expedition = ExpeditionalInfo.new(data)
    return expedition
end

function ExpeditionalInfo:getMapPoints(mapID)
    return pointsInfoTable[mapID] 
end

function ExpeditionalInfo:getRouteTable(mapID)
	return routeTable[mapID]
end

function ExpeditionalInfo:getinvisibleTable(mapID)
    return invisibleTable[mapID] 
end

return ExpeditionalInfo