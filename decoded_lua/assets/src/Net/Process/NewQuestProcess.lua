require("src.Net.Proto.ProtoInclude")

local NewQuestProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function NewQuestProcess.init()
    NetMgr.addProcess(Proto.Command.ZC_UPDATEQUEST_NTF,
        NewQuestProcess.onZC_UpdateQuest_Ntf)
    NetMgr.addProcess(Proto.Command.GC_GETDAILYQUESTSTEPAWARD_ACK,
        NewQuestProcess.onGC_GetDailyQuestStepAward_Ack)
    NetMgr.addProcess(Proto.Command.ZC_COMMITQUEST_ACK,
        NewQuestProcess.onZC_CommitQuest_Ack)
    NetMgr.addProcess(Proto.Command.ZC_UPDATEQUEST_ACK,
        NewQuestProcess.onZC_UpdateQuest_Ack)
    NetMgr.addProcess(Proto.Command.ZC_NEWQUEST_NTF,
        NewQuestProcess.onZC_NewQuest_Ntf)
    NetMgr.addProcess(Proto.Command.ZC_QUESTLIST_ACK,
        NewQuestProcess.onZC_QuestList_Ack)

end

function NewQuestProcess.onZC_QuestList_Ack(msg)

    local res = Proto.parseP_ZC_QuestList_Ack(msg)
    MsgPrinter.rcvMsg(res, "ZC_QuestList_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("current mission num"..res.questNum)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.ZC_QUESTLIST_ACK)
    return res.code

end

function NewQuestProcess.onZC_NewQuest_Ntf(msg)

    local res = Proto.parseP_ZC_NewQuest_Ntf(msg)
    MsgPrinter.rcvMsg(res, "ZC_NewQuest_Ntf")

    QuestInfo.add(res.questList)
    --MissionGuideMgr.refresh()
        
    CallbackMgr.doCallFunc(res.code, Proto.Command.ZC_NEWQUEST_NTF)
    return res.code

end

function NewQuestProcess.onZC_UpdateQuest_Ack(msg)

    local res = Proto.parseP_ZC_UpdateQuest_Ack(msg)
    MsgPrinter.rcvMsg(res, "ZC_UpdateQuest_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.ZC_UPDATEQUEST_ACK)
    return res.code

end

function NewQuestProcess.onZC_CommitQuest_Ack(msg)

    local res = Proto.parseP_ZC_CommitQuest_Ack(msg)
    MsgPrinter.rcvMsg(res, "ZC_CommitQuest_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        QuestInfo.delete(res.questID)
        local isGuideMission = false
        if QuestInfo.getNewQuestInfoById(res.questID).strongType then
            if tonumber(QuestInfo.getNewQuestInfoById(res.questID).strongType)==1 then
                isGuideMission = true
            end
        end
        if not isGuideMission and #res.awards>0 and QuestInfo.getNewQuestInfoById(res.questID).type~=Proto.QUEST_TYPE_EVERYDAY then
            AwardsListMgr.show(SceneMgr.getRunningScene, res.awards)
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.ZC_COMMITQUEST_ACK)
    return res.code

end

function NewQuestProcess.onGC_GetDailyQuestStepAward_Ack(msg)

    local res = Proto.parseP_GC_GetDailyQuestStepAward_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetDailyQuestStepAward_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        --[[
        data.stepIndex=Proto.parseDWORD(entry); -- 
        data.awards=Proto.parseVector(entry,Proto.parseString); -- 
        ]]
        AwardsListMgr.show(SceneMgr.getRunningScene, res.awards)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETDAILYQUESTSTEPAWARD_ACK)
    return res.code

end

function NewQuestProcess.onZC_UpdateQuest_Ntf(msg)

    local res = Proto.parseP_ZC_UpdateQuest_Ntf(msg)
    MsgPrinter.rcvMsg(res, "ZC_UpdateQuest_Ntf")
    
    QuestInfo.update(res.quest)
    
    CallbackMgr.doCallFunc(res.code, Proto.Command.ZC_UPDATEQUEST_NTF)
    return res.code

end

return NewQuestProcess
