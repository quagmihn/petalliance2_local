require( "src.Net.Proto.ProtoInclude")

local PVPSend = {}
local NetMgr = require("src.Net.NetMgr")

function PVPSend.sendCG_StartPVP_Req(params)
 
    local data = {
        bechallengeCharID = params.bechallengeCharID 
    }
    NetMgr.send(Proto.writeP_CG_StartPVP_Req, data)

end
 
function PVPSend.sendCG_ReadyPVP_Req(params)

    local data = {
        battleID=params.battleID,
        pets = params.pets,
        serverID = params.serverID,
		helperPets = params.helperPets
    }
    NetMgr.send(Proto.writeP_CG_ReadyPVP_Req, data)

end

function PVPSend.sendCG_JoinPVP_Req(params)

    local data = {
        battleID = params.battleID,
        serverID = params.serverID
    }
    print(data.battleID) 
    NetMgr.send(Proto.writeP_CG_JoinPVP_Req, data)

end

function PVPSend.sendCG_PVPBattleCommand_Req(params)

    local data = {
        battleID = params.battleID,
        roundIndex = params.roundIndex,
        skillIndex = params.skillIndex,
        petID = params.petID, 
        serverID = params.serverID
    }
    NetMgr.send(Proto.writeP_CG_PVPBattleCommand_Req, data)

end

function PVPSend.sendCG_PVPBattleStart_Req(params)

    local data = {
        battleID = params.battleID,
        serverID = params.serverID
    }
    NetMgr.send(Proto.writeP_CG_PVPBattleStart_Req, data)

end

function PVPSend.sendCG_LeavePVP_Req(params)

    local data = {
        battleID = params.battleID,
        serverID = params.serverID
    }
    NetMgr.send(Proto.writeP_CG_LeavePVP_Req, data)

end

function PVPSend.sendCG_JoinPVPArena_Req(level)

    print("sendCG_JoinPVPArena_Req change level", level)
    local data = {
        petObjIDs = PokemonInfo.getPetArmy(1),
        helperPetObjIDs = PokemonInfo.getPetHelpArmy(),
        level = level,
    }
    NetMgr.send(Proto.writeP_CG_JoinPVPArena_Req, data)

end

function PVPSend.sendCG_CancelJoinPVPArena_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_CancelJoinPVPArena_Req, data)

end

function PVPSend.sendCG_GetPVPArenaAward_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetPVPArenaAward_Req, data)

end

function PVPSend.sendCG_GetMYPVPArenaQuests_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetMYPVPArenaQuests_Req, data)

end

function PVPSend.sendCG_CommitPVPArenaQuest_Req(questID)

    local data = {
        questID = questID
    }
    NetMgr.send(Proto.writeP_CG_CommitPVPArenaQuest_Req, data)

end

function PVPSend.sendCG_ResetPVPArenaQuest_Req(questID)

    local data = {
        questID = questID
    }
    NetMgr.send(Proto.writeP_CG_ResetPVPArenaQuest_Req, data)

end

function PVPSend.sendCG_GetPVPArenaQuestPowerAward_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetPVPArenaQuestPowerAward_Req, data)

end

function PVPSend.sendCG_GetPVPArenaRank_Req(rankMin, rankMax)

    local data = {
        rankMin = rankMin,
        rankMax = rankMax,
    }
    NetMgr.send(Proto.writeP_CG_GetPVPArenaRank_Req, data)

end

function PVPSend.sendCG_GetMyPVPArenaRank_Req(rankMin, rankMax)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetMYPVPArenaRank_Req, data)

end

function PVPSend.sendCG_GetPVPRecords_Req(params)

    local data = {
        battleID = params.battleID,
        serverID = params.serverID,
        startIndex = params.startIndex
    }
    NetMgr.send(Proto.writeP_CG_GetPVPRecords_Req, data)

end

return PVPSend
