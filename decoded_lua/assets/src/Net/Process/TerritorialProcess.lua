require("src.Net.Proto.ProtoInclude")

local TerritorialProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function TerritorialProcess.init()
    NetMgr.addProcess(Proto.Command.GC_TERRITORYINFOWIKI_NTF,
        TerritorialProcess.onGC_TerritoryInfoWiki_Ntf)
    NetMgr.addProcess(Proto.Command.GC_TERRITORYINFONOPETS_ACK,
        TerritorialProcess.onGC_TerritoryInfoNoPets_Ack)
    NetMgr.addProcess(Proto.Command.GC_TERRITORYCOUNTCHANGE_NTF,
        TerritorialProcess.onGC_TerritoryCountChange_Ntf)
    NetMgr.addProcess(Proto.Command.GC_TERRITORYCHANGE_NTF,
        TerritorialProcess.onGC_TerritoryChange_Ntf)
    NetMgr.addProcess(Proto.Command.GC_QUERYSELFTERRITORYIDINFO_ACK,
        TerritorialProcess.onGC_QuerySelfTerritoryIDInfo_Ack)
    NetMgr.addProcess(Proto.Command.GC_TERRITORYCOUNTINFO_ACK,
        TerritorialProcess.onGC_TerritoryCountInfo_Ack)
    NetMgr.addProcess(Proto.Command.GC_SELFTERRITORYINFO_ACK,
        TerritorialProcess.onGC_SelfTerritoryInfo_Ack)
    NetMgr.addProcess(Proto.Command.GC_TERRITORIALRESETINFO_ACK,
        TerritorialProcess.onGC_TerritorialResetInfo_Ack)
    NetMgr.addProcess(Proto.Command.GC_TERRITORYRANKINFO_ACK,
        TerritorialProcess.onGC_TerritoryRankInfo_Ack)
    NetMgr.addProcess(Proto.Command.GC_FIGHTEND_ACK,
        TerritorialProcess.onGC_FightEnd_Ack)
    NetMgr.addProcess(Proto.Command.GC_TERRITORYFIGHT_ACK,
        TerritorialProcess.onGC_TerritoryFight_Ack)
    NetMgr.addProcess(Proto.Command.GC_TERRITORYINFO_ACK,
        TerritorialProcess.onGC_TerritoryInfo_Ack)

end

function TerritorialProcess.onGC_TerritoryInfo_Ack(msg)

    local res = Proto.parseP_GC_TerritoryInfo_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_TerritoryInfo_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        TerritorialInfo.updateStageBossInfo(res.terrInfo)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_TERRITORYINFO_ACK)
    return res.code

end

function TerritorialProcess.onGC_TerritoryFight_Ack(msg)

    local res = Proto.parseP_GC_TerritoryFight_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_TerritoryFight_Ack")
    print("GC_TerritoryFight_Ack" ..res.code)
    if (Proto.Error.ERROR_OK == res.code) then
        TerritorialInfo.setBattleInfo(res)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_TERRITORYFIGHT_ACK)
    return res.code

end

function TerritorialProcess.onGC_FightEnd_Ack(msg)

    local res = Proto.parseP_GC_FightEnd_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_FightEnd_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FIGHTEND_ACK)
    return res.code

end

function TerritorialProcess.onGC_TerritoryRankInfo_Ack(msg)

    local res = Proto.parseP_GC_TerritoryRankInfo_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_TerritoryRankInfo_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        TerritorialInfo.updateRankList(res.rank)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_TERRITORYRANKINFO_ACK)
    return res.code

end

function TerritorialProcess.onGC_TerritorialResetInfo_Ack(msg)

    local res = Proto.parseP_GC_TerritorialResetInfo_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_TerritorialResetInfo_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_TERRITORIALRESETINFO_ACK)
    return res.code

end

function TerritorialProcess.onGC_SelfTerritoryInfo_Ack(msg)

    local res = Proto.parseP_GC_SelfTerritoryInfo_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_SelfTerritoryInfo_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        TerritorialInfo.updateMyRankInfo(res.rank)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_SELFTERRITORYINFO_ACK)
    return res.code

end

function TerritorialProcess.onGC_TerritoryCountInfo_Ack(msg)

    local res = Proto.parseP_GC_TerritoryCountInfo_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_TerritoryCountInfo_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        TerritorialInfo.setChallengeInfo(res)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_TERRITORYCOUNTINFO_ACK)
    return res.code

end

function TerritorialProcess.onGC_QuerySelfTerritoryIDInfo_Ack(msg)

    local res = Proto.parseP_GC_QuerySelfTerritoryIDInfo_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_QuerySelfTerritoryIDInfo_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        TerritorialInfo.setMyStageID(res.adventureID)
        TerritorialInfo.setFamilyTerritorialInfo(res.familyID)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_QUERYSELFTERRITORYIDINFO_ACK)
    return res.code

end

function TerritorialProcess.onGC_TerritoryChange_Ntf(msg)

    local res = Proto.parseP_GC_TerritoryChange_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_TerritoryChange_Ntf")
    
    if res.charID and res.charID == CharInfo.getCharID() then
        AdvConfirmMgrNew.isTerrWin = PLAYER_WIN
    else
        AdvConfirmMgrNew.isTerrWin = PLAYER_LOSE
    end 
    
    if res.oldcharID and res.oldcharID == CharInfo.getCharID() then
        if res.charID and res.charID ~= CharInfo.getCharID() and res.adventureID then
            local advInfo = AdventureInfo.getAdventureInfoByID(res.adventureID) or {}
            local advName = advInfo.name or ""
            StandardTipsMgr.show(1,CocosModuleMgr.createStringWithFormat({"Territorialtips24",advName}))
        end
    end
    
    -- query territory info when changed
    NetInterface.send("GC_TerritoryInfo_Ack", function()
        local TerritorialSend = require("src.Net.Send.TerritorialSend")
        TerritorialSend.sendCG_TerritoryInfo_Req({res.adventureID})
    end, function()
        AdvConfirmMgrNew.refreshServerTime()
    end)
    
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_TERRITORYCHANGE_NTF)
    return res.code

end

function TerritorialProcess.onGC_TerritoryCountChange_Ntf(msg)

    local res = Proto.parseP_GC_TerritoryCountChange_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_TerritoryCountChange_Ntf")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_TERRITORYCOUNTCHANGE_NTF)
    return res.code

end

function TerritorialProcess.onGC_TerritoryInfoNoPets_Ack(msg)

    local res = Proto.parseP_GC_TerritoryInfoNoPets_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_TerritoryInfoNoPets_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        -- TerritorialInfo.updateStageBossInfo_NOPETS(res.terrInfo)
        StageBossListMgr.listNum = res.terrInfo
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_TERRITORYINFONOPETS_ACK)
    return res.code

end

function TerritorialProcess.onGC_TerritoryInfoWiki_Ntf(msg)

    local res = Proto.parseP_GC_TerritoryInfoWiki_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_TerritoryInfoWiki_Ntf")
    
    for k,v in pairs(res.territoryInfo) do
        StageBossListMgr.currentDataNum = StageBossListMgr.currentDataNum + 1
    end
    TerritorialInfo.updateStageBossInfo_NOPETS(res.territoryInfo)
    if StageBossListMgr.currentDataNum == StageBossListMgr.listNum and StageBossListMgr.listLoadCallback then
        StageBossListMgr.listLoadCallback()
        StageBossListMgr.listLoadCallback = nil
        StageBossListMgr.listNum = 0
        StageBossListMgr.currentDataNum = 0
    end
        
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_TERRITORYINFOWIKI_NTF)
    return res.code

end

return TerritorialProcess
