require("src.Net.Proto.ProtoInclude")

local VipProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function VipProcess.init()
    NetMgr.addProcess(Proto.Command.GC_RECHARGETESTCMD_ACK,
        VipProcess.onGC_RechargeTestCmd_Ack)
    NetMgr.addProcess(Proto.Command.GC_VIPAWARDINFO_ACK,
        VipProcess.onGC_VipAwardInfo_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETVIPAWARD_ACK,
        VipProcess.onGC_GetVipAward_Ack)

end

function VipProcess.onGC_GetVipAward_Ack(msg)

    local res = Proto.parseP_GC_GetVipAward_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetVipAward_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    	print("GetVipAward Success!")
    elseif (Proto.Error.ERROR__PET_BRINGLIMIT == res.code) then
        GachaViewMgr.showBringLimitDialog()
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETVIPAWARD_ACK)
    return res.code

end

function VipProcess.onGC_VipAwardInfo_Ack(msg)

    local res = Proto.parseP_GC_VipAwardInfo_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_VipAwardInfo_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        PurchaseViewMgr.setVipAwardInfo(res.vipAwardsInfo)
        PurchaseViewMgr.setRedPoint()
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_VIPAWARDINFO_ACK)
    return res.code

end

function VipProcess.onGC_RechargeTestCmd_Ack(msg)

    local res = Proto.parseP_GC_RechargeTestCmd_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_RechargeTestCmd_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("RechargeTestCmd Success!")
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_RECHARGETESTCMD_ACK)
    return res.code

end

return VipProcess
