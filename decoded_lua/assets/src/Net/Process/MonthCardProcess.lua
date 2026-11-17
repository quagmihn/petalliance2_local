require("src.Net.Proto.ProtoInclude")

local MonthCardProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function MonthCardProcess.init()
    NetMgr.addProcess(Proto.Command.GC_RECHARGECD_ACK,
        MonthCardProcess.onGC_RechargeCD_Ack)
    NetMgr.addProcess(Proto.Command.ZC_TAKEMONTHCARDAWARD_ACK,
        MonthCardProcess.onZC_TakeMonthCardAward_Ack)
    NetMgr.addProcess(Proto.Command.ZC_LOADMONTHCARD_ACK,
        MonthCardProcess.onZC_LoadMonthCard_Ack)

end

function MonthCardProcess.onZC_LoadMonthCard_Ack(msg)
    local res = Proto.parseP_ZC_LoadMonthCard_Ack(msg)
    MsgPrinter.rcvMsg(res, "ZC_LoadMonthCard_Ack")
    if (Proto.Error.ERROR_OK == res.code.value) then
        PurchaseViewMgr.setMonthCardInfo(res.infos)
        PurchaseViewMgr.getMCardAward()
    end
    CallbackMgr.doCallFunc(res.code.value, Proto.Command.ZC_LOADMONTHCARD_ACK)
    return res.code.value

end

function MonthCardProcess.onZC_TakeMonthCardAward_Ack(msg)

    local res = Proto.parseP_ZC_TakeMonthCardAward_Ack(msg)
    MsgPrinter.rcvMsg(res, "ZC_TakeMonthCardAward_Ack")
    if (Proto.Error.ERROR_OK == res.code.value) then
        print("TakeMonthCardAward success!")
    end
    CallbackMgr.doCallFunc(res.code.value, Proto.Command.ZC_TAKEMONTHCARDAWARD_ACK)
    return res.code.value

end

function MonthCardProcess.onGC_RechargeCD_Ack(msg)

    local res = Proto.parseP_GC_RechargeCD_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_RechargeCD_Ack")
    if (Proto.Error.ERROR_OK == res.code.value) then
        local cjson = require("cjson")
        local cdInfo = cjson.decode(res.jsCD)
        PurchaseViewMgr.setRechargeCDInfo(cdInfo)
    end
    CallbackMgr.doCallFunc(res.code.value, Proto.Command.GC_RECHARGECD_ACK)
    return res.code.value

end

return MonthCardProcess
