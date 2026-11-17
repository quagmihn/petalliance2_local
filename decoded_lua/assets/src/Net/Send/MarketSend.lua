require( "src.Net.Proto.ProtoInclude")

local MarketSend = {}
local NetMgr = require("src.Net.NetMgr")

function MarketSend.sendCG_GetMyMarket_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetMyMarket_Req, data)

end

function MarketSend.sendCG_SellOnMarket_Req(params)

    local data = params
    NetMgr.send(Proto.writeP_CG_SellOnMarket_Req, data)

end

function MarketSend.sendCG_SearchProducts_Req(params)

    local data = params
    NetMgr.send(Proto.writeP_CG_SearchProducts_Req, data)

end

function MarketSend.sendCG_BuyProduct_Req(params)

    local data = params
    NetMgr.send(Proto.writeP_CG_BuyProduct_Req, data)

end

function MarketSend.sendCG_DelMyProduct_Req(params)

    local data = params
    NetMgr.send(Proto.writeP_CG_DelMyProduct_Req, data)

end

function MarketSend.sendCG_BuyMarketItem_Req(params)

    local data = params
    NetMgr.send(Proto.writeP_CG_BuyMarketItem_Req, data)

end

return MarketSend
