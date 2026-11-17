require("src.Net.Proto.ProtoInclude")

local OrderManProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function OrderManProcess.init()
    NetMgr.addProcess(Proto.Command.GC_BUYPASSWORDPRODUCT_ACK,
        OrderManProcess.onGC_BuyPasswordProduct_Ack)
    NetMgr.addProcess(Proto.Command.GC_PASSWORDGIFT_ACK,
        OrderManProcess.onGC_PasswordGift_Ack)

end

function OrderManProcess.onGC_PasswordGift_Ack(msg)

    local res = Proto.parseP_GC_PasswordGift_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PasswordGift_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("GC_PasswordGift_Ack~~~~~~~~~~",sz_T2S(res))
        local cjson = require("cjson")
        OrderManDataMgr.products = cjson.decode(res.passwordProducts)

    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PASSWORDGIFT_ACK)
    return res.code

end

function OrderManProcess.onGC_BuyPasswordProduct_Ack(msg)

    local res = Proto.parseP_GC_BuyPasswordProduct_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_BuyPasswordProduct_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_BUYPASSWORDPRODUCT_ACK)
    return res.code

end

return OrderManProcess
