require( "src.Net.Proto.ProtoInclude")

local NewQuestSend = {}
local NetMgr = require("src.Net.NetMgr")

function NewQuestSend.sendCZ_QuestList_Req(param)

    local data = {
    }
    NetMgr.send(Proto.writeP_CZ_QuestList_Req, data)

end

function NewQuestSend.sendCZ_UpdateQuest_Req(param)

    local data = {
        quest = param
    }
    NetMgr.send(Proto.writeP_CZ_UpdateQuest_Req, data)

end

function NewQuestSend.sendCZ_CommitQuest_Req(param)

    local data = {
        questID = param
    }
    NetMgr.send(Proto.writeP_CZ_CommitQuest_Req, data)

end

function NewQuestSend.sendCG_GetDailyQuestStepAward_Req(id)
    --id:1,2,3
    local data = {
        stepIndex = id-1
    }
    NetMgr.send(Proto.writeP_CG_GetDailyQuestStepAward_Req, data)

end

return NewQuestSend



