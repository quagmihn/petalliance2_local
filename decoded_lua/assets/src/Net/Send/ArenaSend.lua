require( "src.Net.Proto.ProtoInclude")

local ArenaSend = {}
local NetMgr = require("src.Net.NetMgr")

function ArenaSend.sendCG_QueryArenaData_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_QueryArenaData_Req, data)

end

function ArenaSend.sendCG_RandomArenaEnemys_Req()

    local data = {
        nowRank = ArenaInfo.getRank(),
    }
    NetMgr.send(Proto.writeP_CG_RandomArenaEnemys_Req, data)

end

function ArenaSend.sendCG_JoinArena_Req()

    local data = {
        teamID = 1,
        petObjIDs = {},
    }
    NetMgr.send(Proto.writeP_CG_JoinArena_Req, data)

end

function ArenaSend.sendCG_ChangeArenaPetObjIDs_Req(teamID)

    local data = {
        teamID = teamID,
        petObjIDs = {},
    }
    NetMgr.send(Proto.writeP_CG_ChangeArenaPetObjIDs_Req, data)

end

function ArenaSend.sendCG_ArenaRankFight_Req(rank)

    local data = {
        rank = rank,
        teamID = ArenaInfo.getAttackArmyID(),
        petObjIDs = {},
    }
    NetMgr.send(Proto.writeP_CG_ArenaRankFight_Req, data)

end

function ArenaSend.sendCG_ArenaRankFightEnd_Req(params)

    local data = {
        arenaBattleID = params.arenaBattleID,
        isWin = params.isWin,
        report = params.report,
    }
    NetMgr.send(Proto.writeP_CG_ArenaRankFightEnd_Req, data)

end

function ArenaSend.sendCG_QueryArenaRank_Req(params)

    local data = {
        rankMin = params.min,
        rankMax = params.max,
    }
    NetMgr.send(Proto.writeP_CG_QueryArenaRank_Req, data)

end

function ArenaSend.sendCG_QueryArenaSoldierDetail_Req(params)

    local data = {
        charID = params.charID,
        teamID = params.teamID,
    }
    NetMgr.send(Proto.writeP_CG_QueryArenaSoldierDetail_Req, data)

end

function ArenaSend.sendCG_ClearArenaCD_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_ClearArenaCD_Req, data)

end

function ArenaSend.sendCG_BuyArenaFightTimes_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_BuyArenaFightTimes_Req, data)

end

function ArenaSend.sendCG_GetArenaAward_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetArenaAward_Req, data)

end

function ArenaSend.sendCG_GetArenaRecode_Req(params)

    local data = {
        startIndex = params.startIndex,
        endIndex = params.endIndex
    }
    NetMgr.send(Proto.writeP_CG_GetArenaRecode_Req, data)

end

function ArenaSend.sendCG_PlayArenaRecode_Req(params)

    local data = {
        t = params.t
    }
    NetMgr.send(Proto.writeP_CG_PlayArenaRecode_Req, data)

end

return ArenaSend
