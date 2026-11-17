require( "src.Net.Proto.ProtoInclude")

local CommonShopSend = {}
local NetMgr = require("src.Net.NetMgr")

function CommonShopSend.sendCG_getShop_Req(params)

    local data = {
        type = params.type,
    }
    NetMgr.send(Proto.writeP_CG_getShop_Req, data)

end

function CommonShopSend.sendCG_BuyGoods_Req(params)

    local data = {
        type = params.type,
        index = params.index,
        buyCount = params.buyCount
    }
    NetMgr.send(Proto.writeP_CG_BuyGoods_Req, data)

end

function CommonShopSend.sendCG_RefreshGoods_Req(params)

    local data = {
        type = params.type,
    }
    NetMgr.send(Proto.writeP_CG_RefreshGoods_Req, data)

end

function CommonShopSend.sendCG_SystemRefreshGoods_Req(params)

    local data = {
        type = params.type,
    }
    NetMgr.send(Proto.writeP_CG_SystemRefreshGoods_Req, data)

end

function CommonShopSend.sendCG_ResetShop_Req(params)

    local data = {
        type = params.type,
    }
    NetMgr.send(Proto.writeP_CG_ResetShop_Req, data)

end

return CommonShopSend
