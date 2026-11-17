require( "src.Net.Proto.ProtoInclude")

local NewShopSend = {}
local NetMgr = require("src.Net.NetMgr")

function NewShopSend.sendCG_GetRedHeartShopInfo_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetRedHeartShopInfo_Req, data)

end

function NewShopSend.sendCG_BuyRedHeartGoods_Req(params)

    local data = {
    	pos = params.pos
    }
    NetMgr.send(Proto.writeP_CG_BuyRedHeartGoods_Req, data)

end

function NewShopSend.sendCG_GetMyRedHeartShopInfo_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetMyRedHeartShopInfo_Req, data)

end

function NewShopSend.sendCG_GetOneMCashShop_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetOneMCashShop_Req, data)

end

function NewShopSend.sendCG_GetOneMCashShopDetail_Req(params)
    local data = {
        itemID = params.itemID
    }
    NetMgr.send(Proto.writeP_CG_GetOneMCashShopDetail_Req, data)

end

function NewShopSend.sendCG_BuyOneMCashShop_Req(params)

    local data = {
        itemID = params.itemID,
        buyNum = params.buyNum
    }
    NetMgr.send(Proto.writeP_CG_BuyOneMCashShop_Req, data)

end

function NewShopSend.sendCG_GetOneMCashShopLog_Req(params)

    local data = {
        startIndex = params.startIndex,
        endIndex = params.endIndex
    }
    NetMgr.send(Proto.writeP_CG_GetOneMCashShopLog_Req, data)

end

return NewShopSend
