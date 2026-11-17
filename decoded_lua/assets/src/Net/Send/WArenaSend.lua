require( "src.Net.Proto.ProtoInclude")

local WArenaSend = {}
local NetMgr = require("src.Net.NetMgr")

function WArenaSend.sendCG_JoinWArena_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_JoinWArena_Req, data)

end

function WArenaSend.sendCG_WArenaRankFight_Req(params)

    local data = {
        rank = params.rank
    }
    NetMgr.send(Proto.writeP_CG_WArenaRankFight_Req, data)

end

function WArenaSend.sendCG_RandomWArenaEnemys_Req(params)

    local data = {
    	nowRank = params.nowRank
    }
    NetMgr.send(Proto.writeP_CG_RandomWArenaEnemys_Req, data)

end

function WArenaSend.sendCG_QueryWArenaRank_Req(params)

    local data = {
    	rankMin = params.rankMin,
    	rankMax = params.rankMax

    }
    NetMgr.send(Proto.writeP_CG_QueryWArenaRank_Req, data)

end

function WArenaSend.sendCG_GetWArenaRecode_Req(params)

    local data = {
        startIndex = params.startIndex,
        endIndex   = params.endIndex
    }
    NetMgr.send(Proto.writeP_CG_GetWArenaRecode_Req, data)

end

function WArenaSend.sendCG_PlayWArenaRecode_Req(params)

    local data = {
        t = params.t
    }
    NetMgr.send(Proto.writeP_CG_PlayWArenaRecode_Req, data)

end

function WArenaSend.sendCG_BuyWArenaFightTimes_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_BuyWArenaFightTimes_Req, data)

end

return WArenaSend
