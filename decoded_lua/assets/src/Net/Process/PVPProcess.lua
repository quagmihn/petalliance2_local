require("src.Net.Proto.ProtoInclude")

local PVPProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function PVPProcess.init()
    NetMgr.addProcess(Proto.Command.GC_GETPVPRECORDS_ACK,
        PVPProcess.onGC_GetPVPRecords_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETPVPARENAAWARD_ACK,
        PVPProcess.onGC_GetPVPArenaAward_Ack)
    NetMgr.addProcess(Proto.Command.GC_CANCELJOINPVPARENA_ACK,
        PVPProcess.onGC_CancelJoinPVPArena_Ack)
    NetMgr.addProcess(Proto.Command.GC_JOINPVPARENA_ACK,
        PVPProcess.onGC_JoinPVPArena_Ack)
    NetMgr.addProcess(Proto.Command.GC_LEAVEPVP_ACK,
        PVPProcess.onGC_LeavePVP_Ack)
    NetMgr.addProcess(Proto.Command.GC_PVPBATTLECOMMAND_NTF,
        PVPProcess.onGC_PVPBattleCommand_Ntf)
    NetMgr.addProcess(Proto.Command.GC_PVPINFO_NTF,
        PVPProcess.onGC_PVPInfo_Ntf)
    NetMgr.addProcess(Proto.Command.GC_PVPBATTLESTART_ACK,
        PVPProcess.onGC_PVPBattleStart_Ack)
    NetMgr.addProcess(Proto.Command.GC_PVPBATTLECOMMAND_ACK,
        PVPProcess.onGC_PVPBattleCommand_Ack)
    NetMgr.addProcess(Proto.Command.GC_JOINPVP_ACK,
        PVPProcess.onGC_JoinPVP_Ack)
    NetMgr.addProcess(Proto.Command.GC_READYPVP_ACK,
        PVPProcess.onGC_ReadyPVP_Ack)
    NetMgr.addProcess(Proto.Command.GC_STARTPVP_ACK,
        PVPProcess.onGC_StartPVP_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETMYPVPARENAQUESTS_ACK,
        PVPProcess.onGC_GetMyPvpArenaQuests_Ack)
    NetMgr.addProcess(Proto.Command.GC_COMMITPVPARENAQUEST_ACK,
        PVPProcess.onGC_CommitPVPArenaQuest_Ack)
    NetMgr.addProcess(Proto.Command.GC_RESETPVPARENAQUEST_ACK,
        PVPProcess.onGC_ResetPVPArenaQuest_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETPVPARENAQUESTPOWERAWARD_ACK,
        PVPProcess.onGC_GetPVPArenaQuestPowerAward_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETPVPARENARANK_ACK,
        PVPProcess.onGC_GetPVPArenaRank_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETMYPVPARENARANK_ACK,
        PVPProcess.onGC_GetMyPVPArenaRank_Ack)

end

function PVPProcess.onGC_StartPVP_Ack(msg)

    local res = Proto.parseP_GC_StartPVP_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_StartPVP_Ack") 
    if (Proto.Error.ERROR_OK == res.code) then 
--        CSResourceMgr.getCsbObj("Charactor/Menu/MainMenu.csb")
--        local btn = CSResourceMgr.getNodeByName("Charactor/Menu/MainMenu.csb","b1")
--        BattleFuncMgr.setNodeGray(btn,false)
--        local ChatSend = require("src.Net.Send.ChatSend.lua")
--        ChatSend.sendCZ_UseSpaceBugle_Req({content = {text = tostring(res.battleID),dataItems = {}},color = 1})
--        BattlePVPMgr.onCreateBattleID(res.battleID) 
--        local PVPSend = require("src.Net.Send.PVPSend")
--        PVPSend.sendCG_JoinPVP_Req({battleID = BattlePVPMgr.getBattleID()})  
    end
    
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_STARTPVP_ACK)
    return res.code

end

function PVPProcess.onGC_ReadyPVP_Ack(msg)

    local res = Proto.parseP_GC_ReadyPVP_Ack(msg) 
    MsgPrinter.rcvMsg(res, "GC_ReadyPVP_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_READYPVP_ACK)
    return res.code

end

function PVPProcess.onGC_JoinPVP_Ack(msg)

    local res = Proto.parseP_GC_JoinPVP_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_JoinPVP_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_JOINPVP_ACK)
    return res.code

end

function PVPProcess.onGC_PVPBattleCommand_Ack(msg)

    local res = Proto.parseP_GC_PVPBattleCommand_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PVPBattleCommand_Ack") 
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PVPBATTLECOMMAND_ACK)
    return res.code

end

function PVPProcess.onGC_PVPBattleStart_Ack(msg)

    local res = Proto.parseP_GC_PVPBattleStart_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PVPBattleStart_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PVPBATTLESTART_ACK)
    return res.code

end

function PVPProcess.onGC_PVPInfo_Ntf(msg)

    local res = Proto.parseP_GC_PVPInfo_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_PVPInfo_Ntf")
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PVPINFO_NTF)
    print("onGC_PVPInfo_Ntf____onGC_PVPInfo_Ntf..................") 
    
    BattlePVPMgr.setPVPInfomation(res)
    return res.code

end

function PVPProcess.onGC_PVPBattleCommand_Ntf(msg)
    print("onGC_PVPBattleCommand_Ntf_onGC_PVPBattleCommand_Ntf")
    local res = Proto.parseP_GC_PVPBattleCommand_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_PVPBattleCommand_Ntf")
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PVPBATTLECOMMAND_NTF)
    
--    if BattlePVPMgr.getBattleID() ~= res.battleID then
--        return
--    end
--    BattlePVPMgr.setRoundIndex(res.roundIndex) 
--    if res.battleCommandStatus == Proto.BattleWaitCommand then
--        BattleUIMgr.PVPTime() 
--        CocosModuleMgr.setScreenTouch(true) 
--        print("@@@@@res.BattleWaitCommand") 
--    	return
--    elseif res.battleCommandStatus == Proto.BattlePlayCommand then
--        for k,v in pairs(res.battleCommands) do
--            print("comands " .. k .. ":" .. v)
--        end
--        if res.battleCommands[1] == "petAnimation" then
--            
--            if table.getn(res.battleCommands) < 4 then
--                print("table.getn(res.battleCommands) < 4 error")
--            else
--                BattleUIMgr.petAnimation(tonumber(res.battleCommands[2]),
--                    tonumber(res.battleCommands[3]),
--                    tonumber(res.battleCommands[4]),
--                    loadstring("return " .. res.battleCommands[5])())
--            end
--        elseif res.battleCommands[1] == "exchangePets" then 
--            for k,v in pairs(res.battleCommands) do
--                print("comands " .. k .. ":" .. v) 
--            end
--            if table.getn(res.battleCommands) < 5 then
--                print("error")
--            else
--                BattleUIMgr.exchangePets(tonumber(res.battleCommands[2]),tonumber(res.battleCommands[3]),tonumber(res.battleCommands[4]),loadstring("return " .. res.battleCommands[5])())
--            end
--        elseif res.battleCommands[1] == "showBufDamage" then
--            BattleUIMgr.showBufDamage(tonumber(res.battleCommands[2]), tonumber(res.battleCommands[3]))
--        elseif res.battleCommands[1] == "delBufState" then
--            BattleUIMgr.delBufState(tonumber(res.battleCommands[2]),tonumber(res.battleCommands[3]))
--        end
--         
--    elseif res.battleCommandStatus == Proto.BattlePlayChallengerWin then
--        if  BattleMapMgr.getIsChallenger()  then
--            BattleUIMgr.gamePlayerWin()
--        else
--            BattleUIMgr.gameEnemyWin()
--        end 
--        BattleUIMgr.cleanPVPInfo()
--        BattlePVPMgr.cleanPVPInfo()
--        BattleMapMgr.cleanPVPInfo()
--    elseif res.battleCommandStatus == Proto.BattlePlayBeChallengeWin then
--        if  BattleMapMgr.getIsChallenger()  then
--            BattleUIMgr.gameEnemyWin()
--        else
--            BattleUIMgr.gamePlayerWin()
--        end 
--        BattleUIMgr.cleanPVPInfo()
--        BattlePVPMgr.cleanPVPInfo()
--        BattleMapMgr.cleanPVPInfo()
--    elseif res.battleCommandStatus == Proto.BattlePlayNoneWin then
--        BattleUIMgr.gameOverEqual() 
--        BattleUIMgr.cleanPVPInfo()
--        BattlePVPMgr.cleanPVPInfo() 
--        BattleMapMgr.cleanPVPInfo()
--    end
    
    
    return res.code

end

function PVPProcess.onGC_LeavePVP_Ack(msg)

    local res = Proto.parseP_GC_LeavePVP_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_LeavePVP_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_LEAVEPVP_ACK)
    return res.code

end

function PVPProcess.onGC_JoinPVPArena_Ack(msg)

    local res = Proto.parseP_GC_JoinPVPArena_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_JoinPVPArena_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_JOINPVPARENA_ACK)
    return res.code

end

function PVPProcess.onGC_CancelJoinPVPArena_Ack(msg)

    local res = Proto.parseP_GC_CancelJoinPVPArena_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_CancelJoinPVPArena_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CANCELJOINPVPARENA_ACK)
    return res.code

end

function PVPProcess.onGC_GetPVPArenaAward_Ack(msg)

    local res = Proto.parseP_GC_GetPVPArenaAward_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetPVPArenaAward_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETPVPARENAAWARD_ACK)
    return res.code

end

function PVPProcess.onGC_GetMyPvpArenaQuests_Ack(msg)

    local res = Proto.parseP_GC_GetMYPVPArenaQuests_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetMYPVPArenaQuests_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        QuestInfo.setPvpArenaQuestDatas(json.decode(res.pvpArenaQuestData))
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETMYPVPARENAQUESTS_ACK)
    return res.code

end

function PVPProcess.onGC_CommitPVPArenaQuest_Ack(msg)

    local res = Proto.parseP_GC_CommitPVPArenaQuest_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_CommitPVPArenaQuest_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_COMMITPVPARENAQUEST_ACK)
    return res.code

end

function PVPProcess.onGC_ResetPVPArenaQuest_Ack(msg)

    local res = Proto.parseP_GC_ResetPVPArenaQuest_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ResetPVPArenaQuest_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_RESETPVPARENAQUEST_ACK)
    return res.code

end

function PVPProcess.onGC_GetPVPArenaQuestPowerAward_Ack(msg)

    local res = Proto.parseP_GC_GetPVPArenaQuestPowerAward_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetPVPArenaQuestPowerAward_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        AwardsListMgr.show(SceneMgr.getRunningScene, res.awards)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETPVPARENAQUESTPOWERAWARD_ACK)
    return res.code

end

function PVPProcess.onGC_GetPVPArenaRank_Ack(msg)

    local res = Proto.parseP_GC_GetPVPArenaRank_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetPVPArenaRank_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        ArenaInfo.setPVPArenaRank(res.soldiers)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETPVPARENARANK_ACK)
    return res.code

end

function PVPProcess.onGC_GetMyPVPArenaRank_Ack(msg)

    local res = Proto.parseP_GC_GetMYPVPArenaRank_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetMYPVPArenaRank_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        ArenaInfo.setMyPVPArenaRank(res.rank)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETMYPVPARENARANK_ACK)
    return res.code

end

function PVPProcess.onGC_GetPVPRecords_Ack(msg)

    local res = Proto.parseP_GC_GetPVPRecords_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetPVPRecords_Ack")
    print("GC_GetPVPRecords_Ack 结果  ",Proto.Error.ERROR_OK,res.code)
    if (Proto.Error.ERROR_OK == res.code) then
        -- local record = loadstring("return "..res.report)()
        -- BattleCotroller.setBattleRecords(record,index)
    else
        BattlePVPMgr.checkPVPBattle()
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETPVPRECORDS_ACK)
    return res.code

end

return PVPProcess
