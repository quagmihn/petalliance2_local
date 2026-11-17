require( "src.Net.Proto.ProtoInclude")

local FashionShowSend = {}
local NetMgr = require("src.Net.NetMgr")

function FashionShowSend.sendCG_GetFashionShowRank_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetFashionShowRank_Req, data)

end

function FashionShowSend.sendCG_SaveFashionShow_Req(params)

    local data = {
        fashions = params.fashions,
        petObjID = params.petObjID,
        sceneID = params.sceneID
    }
    NetMgr.send(Proto.writeP_CG_SaveFashionShow_Req, data)

end

function FashionShowSend.sendCG_GetSingleFashionShow_Req(params)

    local data = {
        charID = params.charID
    }
    NetMgr.send(Proto.writeP_CG_GetSingleFashionShow_Req, data)

end

function FashionShowSend.sendCG_TakeFashionShowRankAward_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_TakeFashionShowRankAward_Req, data)

end

function FashionShowSend.sendCG_GetFashionShowPeopers_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetFashionShowPeopers_Req, data)

end

function FashionShowSend.sendCG_LikeFashionShow_Req(params)

    local data = {
        charID = params.charID
    }
    NetMgr.send(Proto.writeP_CG_LikeFashionShow_Req, data)

end

function FashionShowSend.sendCG_GetLikeList_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetLikeList_Req, data)

end

return FashionShowSend
