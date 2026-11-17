require("src.Net.Proto.ProtoInclude")

local LifeSkillProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function LifeSkillProcess.init()
    NetMgr.addProcess(Proto.Command.GC_BUYDRAWINGS_ACK,
        LifeSkillProcess.onGC_BuyDrawings_Ack)
    NetMgr.addProcess(Proto.Command.GC_LIFESKILLUPDATE_NTF,
        LifeSkillProcess.onGC_LifeSkillUpdate_Ntf)
    NetMgr.addProcess(Proto.Command.GC_MANUFACTURE_ACK,
        LifeSkillProcess.onGC_Manufacture_Ack)
    NetMgr.addProcess(Proto.Command.GC_CHANGELIFECAREER_ACK,
        LifeSkillProcess.onGC_ChangeLifeCareer_Ack)
    NetMgr.addProcess(Proto.Command.GC_UNLOCKLIFESKILL_ACK,
        LifeSkillProcess.onGC_UnlockLifeSkill_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETLIFESKILLDATA_ACK,
        LifeSkillProcess.onGC_GetLifeSkillData_Ack)

end

function LifeSkillProcess.onGC_GetLifeSkillData_Ack(msg)

    local res = Proto.parseP_GC_GetLifeSkillData_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetLifeSkillData_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        CharInfo.setLifeSkillInfo(res.lifeSkillData)
        print("setLifeSkillInfo:"..res.lifeSkillData)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETLIFESKILLDATA_ACK)
    return res.code

end

function LifeSkillProcess.onGC_UnlockLifeSkill_Ack(msg)

    local res = Proto.parseP_GC_UnlockLifeSkill_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_UnlockLifeSkill_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        CharInfo.setLifeSkillInfo(res.lifeSkillData)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_UNLOCKLIFESKILL_ACK)
    return res.code

end

function LifeSkillProcess.onGC_ChangeLifeCareer_Ack(msg)

    local res = Proto.parseP_GC_ChangeLifeCareer_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ChangeLifeCareer_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        CharInfo.setLifeSkillInfo(res.lifeSkillData)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CHANGELIFECAREER_ACK)
    return res.code

end

function LifeSkillProcess.onGC_Manufacture_Ack(msg)

    local res = Proto.parseP_GC_Manufacture_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_Manufacture_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        CharInfo.setLifeSkillInfo(res.lifeSkillData)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_MANUFACTURE_ACK)
    return res.code

end

function LifeSkillProcess.onGC_LifeSkillUpdate_Ntf(msg)

    local res = Proto.parseP_GC_LifeSkillUpdate_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_LifeSkillUpdate_Ntf")
    print(res.lifeSkillData)
    CharInfo.setLifeSkillInfo(res.lifeSkillData)
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_LIFESKILLUPDATE_NTF)
    return res.code

end

function LifeSkillProcess.onGC_BuyDrawings_Ack(msg)

    local res = Proto.parseP_GC_BuyDrawings_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_BuyDrawings_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_BUYDRAWINGS_ACK)
    return res.code

end

return LifeSkillProcess
