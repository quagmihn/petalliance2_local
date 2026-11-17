require("src.Net.Proto.ProtoInclude")

local AdventureProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function AdventureProcess.init()
    NetMgr.addProcess(Proto.Command.GC_GETADVAWARD_ACK,
        AdventureProcess.onGC_GetAdvAward_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETMAPSTARAWARD_ACK,
        AdventureProcess.onGC_GetMapStarAward_Ack)
    NetMgr.addProcess(Proto.Command.GC_RESETADVENTURE_ACK,
        AdventureProcess.onGC_ResetAdventure_Ack)
    NetMgr.addProcess(Proto.Command.GC_RESETADVENTURETIMES_ACK,
        AdventureProcess.onGC_ResetAdventureTimes_Ack)
    NetMgr.addProcess(Proto.Command.GC_BUYNPCSHOPGOODS_ACK,
        AdventureProcess.onGC_BuyNpcShopGoods_Ack)
    NetMgr.addProcess(Proto.Command.GC_REFRESHMAPNODEEVENT_ACK,
        AdventureProcess.onGC_RefreshMapNodeEvent_Ack)
    NetMgr.addProcess(Proto.Command.GC_FIREADVENTUREEVENT_ACK,
        AdventureProcess.onGC_FireAdventureEvent_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETMYMAPNODEEVENTINFO_ACK,
        AdventureProcess.onGC_GetMyMapNodeEventInfo_Ack)
    NetMgr.addProcess(Proto.Command.GC_TRIGGERNODEEVENT_ACK,
        AdventureProcess.onGC_TriggerNodeEvent_Ack)
    NetMgr.addProcess(Proto.Command.GC_QUICKCLEARADVENTURE_ACK,
        AdventureProcess.onGC_QuickClearAdventure_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETFINISHEDADVENTURES_NTF,
        AdventureProcess.onGC_GetFinishedAdventures_Ntf)
    NetMgr.addProcess(Proto.Command.GC_ADVENTUREDAMAGE_ACK,
        AdventureProcess.onGC_AdventureDamage_Ack)
    NetMgr.addProcess(Proto.Command.GC_ADVENTUREUSESKILL_ACK,
        AdventureProcess.onGC_AdventureUseSkill_Ack)
    NetMgr.addProcess(Proto.Command.GC_FINISHADVENTURE_ACK,
        AdventureProcess.onGC_FinishAdventure_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETADVENTUREAWARD_ACK,
        AdventureProcess.onGC_GetAdventureAward_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETFINISHEDADVENTURES_ACK,
        AdventureProcess.onGC_GetFinishedAdventures_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETCURRENTADVENTRUE_ACK,
        AdventureProcess.onGC_GetCurrentAdventrue_Ack)
    NetMgr.addProcess(Proto.Command.GC_CREATEADVENTURE_ACK,
        AdventureProcess.onGC_CreateAdventure_Ack)
end

function AdventureProcess.onGC_CreateAdventure_Ack(msg)

    local res = Proto.parseP_GC_CreateAdventure_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_CreateAdventure_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("@@@@@@@@@@@    res.adventureInfo:"..res.adventureInfo)
        SearchingMapMgr.getDataFromServer(res.adventureInfo)
    else
        print("====    error code    ====",res.code)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CREATEADVENTURE_ACK)
    return res.code

end

function AdventureProcess.onGC_GetCurrentAdventrue_Ack(msg)

    local res = Proto.parseP_GC_GetCurrentAdventrue_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetCurrentAdventrue_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        -- for k, v in pairs(res) do print(k,v) end
        
        if res.adventureID ~= 0 then
            NetInterface.sendWithBlock("GC_FINISHADVENTURE_ACK", 
            function()
                local AdventureSend = require("src/Net/Send/AdventureSend.lua")
                AdventureSend.sendCG_FinishAdventure_Req({star=0,})  --star number equals zero means failed the stage
            end, 
            function()
            end, 
            function(code)
                if code ~= 0 then
                    print("GC_GetCurrentAdventrue_Ack", "ERROR code", code)
                end
            end)
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETCURRENTADVENTRUE_ACK)
    return res.code

end

function AdventureProcess.onGC_GetFinishedAdventures_Ack(msg)

    local res = Proto.parseP_GC_GetFinishedAdventures_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetFinishedAdventures_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        local cjson = require("cjson")
        print("GC_GetFinishedAdventures_Ack", res.num)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETFINISHEDADVENTURES_ACK)
    return res.code

end

function AdventureProcess.onGC_GetAdventureAward_Ack(msg)

    local res = Proto.parseP_GC_GetAdventureAward_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetAdventureAward_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("onGC_GetAdventureAward_Ack")
        local cjson = require("cjson")
        for key, var in pairs(res.awards) do
            print("$$$$$    awards    $$$$$",key,var)
        end
        SearchingFuncMgr.advAwards = res.awards
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETADVENTUREAWARD_ACK)
    return res.code

end

function AdventureProcess.onGC_FinishAdventure_Ack(msg)

    local res = Proto.parseP_GC_FinishAdventure_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_FinishAdventure_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("GC_FinishAdventure_Ack")
        local cjson = require("cjson")
        for key, var in pairs(res.awards) do
            print("$$$$$    awards    $$$$$",key,var)
            local tbl = cjson.decode(var)
            table.insert(SearchingMgr.awardsTbl,tbl)
        end
        
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FINISHADVENTURE_ACK)
    return res.code

end

function AdventureProcess.onGC_AdventureUseSkill_Ack(msg)

    local res = Proto.parseP_GC_AdventureUseSkill_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_AdventureUseSkill_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("ok")
    else
        print("code:",res.code)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_ADVENTUREUSESKILL_ACK)
    return res.code

end

function AdventureProcess.onGC_AdventureDamage_Ack(msg)

    local res = Proto.parseP_GC_AdventureDamage_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_AdventureDamage_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("__GC_AdventureDamage_Ack__")
        for k, v in pairs(res.petObjIDs) do
            print(v,res.damageTypes[k],res.hp[k])
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_ADVENTUREDAMAGE_ACK)
    return res.code

end

function AdventureProcess.onGC_GetFinishedAdventures_Ntf(msg)

    local res = Proto.parseP_GC_GetFinishedAdventures_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_GetFinishedAdventures_Ntf")
    print("GC_GetFinishedAdventures_Ntf")
    
    local cjson = require("cjson")
    if res.finished ~= nil then 
        for k,v in pairs(res.finished) do
            print("finished:",k,v)
            AdventureInfo.setFinished( {cjson.decode(v)} ) 
        end
    end
    WorldMapMgr.refreshAdventureStars()
    WorldMapAwardsMgr.refresh()
    
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETFINISHEDADVENTURES_NTF)
    return res.code

end

function AdventureProcess.onGC_QuickClearAdventure_Ack(msg)

    local res = Proto.parseP_GC_QuickClearAdventure_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_QuickClearAdventure_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        AwardsListMgr.show(SceneMgr.getRunningScene, res.awards)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_QUICKCLEARADVENTURE_ACK)
    return res.code

end

function AdventureProcess.onGC_TriggerNodeEvent_Ack(msg)

    local res = Proto.parseP_GC_TriggerNodeEvent_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_TriggerNodeEvent_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("TriggerNodeEventAwards size", #res.awards)
        for k,v in pairs(res.awards) do
            print("TriggerNodeEventAwards",k,v)
        end
        if #res.awards>0 then
            AwardsListMgr.show(SceneMgr.getRunningScene, res.awards)
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_TRIGGERNODEEVENT_ACK)
    return res.code

end

function AdventureProcess.onGC_GetMyMapNodeEventInfo_Ack(msg)

    local res = Proto.parseP_GC_GetMyMapNodeEventInfo_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetMyMapNodeEventInfo_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        AdventureInfo.setMapEventInfo(res.nodeEventInfo)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETMYMAPNODEEVENTINFO_ACK)
    return res.code

end

function AdventureProcess.onGC_FireAdventureEvent_Ack(msg)

    local res = Proto.parseP_GC_FireAdventureEvent_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_FireAdventureEvent_Ack")
    print("GC_FireAdventureEvent_Ack",res.code)
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FIREADVENTUREEVENT_ACK)
    return res.code

end

function AdventureProcess.onGC_RefreshMapNodeEvent_Ack(msg)

    local res = Proto.parseP_GC_RefreshMapNodeEvent_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_RefreshMapNodeEvent_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        --print("=========RefreshMapNodeEvent_Ack nodeEventInfo=",res.nodeEventInfo)
        local cjson = require("cjson")
        local eventInfo = cjson.decode(res.nodeEventInfo)
        if eventInfo ~= nil then
            FurnitureTVMgr.setRefreshTimes(eventInfo.refreshTimes)
            AdventureInfo.setMapEventInfo(res.nodeEventInfo)
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_REFRESHMAPNODEEVENT_ACK)
    return res.code

end

function AdventureProcess.onGC_BuyNpcShopGoods_Ack(msg)

    local res = Proto.parseP_GC_BuyNpcShopGoods_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_BuyNpcShopGoods_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_BUYNPCSHOPGOODS_ACK)
    return res.code

end

function AdventureProcess.onGC_ResetAdventureTimes_Ack(msg)

    local res = Proto.parseP_GC_ResetAdventureTimes_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ResetAdventureTimes_Ack")
    print("GC_ResetAdventureTimes_Ack", res.code)
    if (Proto.Error.ERROR_OK == res.code) then
        print("finAdv:", res.finAdv)
        local cjson = require("cjson")
        local info = cjson.decode(res.finAdv)
        local data = AdventureInfo.getFinishedByID(info.advID)
        for k, v in pairs(info) do data[k] = info[k] end
        AdventureInfo.setFinished( {data,} )
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_RESETADVENTURETIMES_ACK)
    return res.code

end

function AdventureProcess.onGC_ResetAdventure_Ack(msg)

    local res = Proto.parseP_GC_ResetAdventure_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ResetAdventure_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_RESETADVENTURE_ACK)
    return res.code

end

function AdventureProcess.onGC_GetMapStarAward_Ack(msg)

    local res = Proto.parseP_GC_GetMapStarAward_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetMapStarAward_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        AwardsListMgr.show(SceneMgr.getRunningScene, res.awards)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETMAPSTARAWARD_ACK)
    return res.code

end

function AdventureProcess.onGC_GetAdvAward_Ack(msg)

    local res = Proto.parseP_GC_GetAdvAward_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetAdvAward_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        AwardsListMgr.show(SceneMgr.getRunningScene, res.awards)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETADVAWARD_ACK)
    return res.code

end

return AdventureProcess
