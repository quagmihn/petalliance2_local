require("src.Net.Proto.ProtoInclude")

local MarketProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function MarketProcess.init()
    NetMgr.addProcess(Proto.Command.GC_BUYMARKETITEM_ACK,
        MarketProcess.onGC_BuyMarketItem_Ack)
    NetMgr.addProcess(Proto.Command.GC_DELMYPRODUCT_ACK,
        MarketProcess.onGC_DelMyProduct_Ack)
    NetMgr.addProcess(Proto.Command.GC_BUYPRODUCT_ACK,
        MarketProcess.onGC_BuyProduct_Ack)
    NetMgr.addProcess(Proto.Command.GC_SEARCHPRODUCTS_ACK,
        MarketProcess.onGC_SearchProducts_Ack)
    NetMgr.addProcess(Proto.Command.GC_SELLONMARKET_ACK,
        MarketProcess.onGC_SellOnMarket_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETMYMARKET_ACK,
        MarketProcess.onGC_GetMyMarket_Ack)

end

function MarketProcess.onGC_GetMyMarket_Ack(msg)

    local res = Proto.parseP_GC_GetMyMarket_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetMyMarket_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        AuctionMgrNew.onRecvGetMyMarketAck(res.products)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETMYMARKET_ACK)
    return res.code

end

function MarketProcess.onGC_SellOnMarket_Ack(msg)

    local res = Proto.parseP_GC_SellOnMarket_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_SellOnMarket_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_SELLONMARKET_ACK)
    return res.code

end

function MarketProcess.onGC_SearchProducts_Ack(msg)

    local res = Proto.parseP_GC_SearchProducts_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_SearchProducts_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        AuctionMgrNew.onRecvSearchProductsAck(res.products)

    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_SEARCHPRODUCTS_ACK)
    return res.code

end

function MarketProcess.onGC_BuyProduct_Ack(msg)

    local res = Proto.parseP_GC_BuyProduct_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_BuyProduct_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_BUYPRODUCT_ACK)
    return res.code

end

function MarketProcess.onGC_DelMyProduct_Ack(msg)

    local res = Proto.parseP_GC_DelMyProduct_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_DelMyProduct_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_DELMYPRODUCT_ACK)
    return res.code

end

function MarketProcess.onGC_BuyMarketItem_Ack(msg)

    local res = Proto.parseP_GC_BuyMarketItem_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_BuyMarketItem_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_BUYMARKETITEM_ACK)
    return res.code

end

return MarketProcess
