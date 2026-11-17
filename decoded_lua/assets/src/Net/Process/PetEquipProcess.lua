require("src.Net.Proto.ProtoInclude")

local PetEquipProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function PetEquipProcess.init()
    NetMgr.addProcess(Proto.Command.GC_UPDATEPETEQUIP_NTF,
        PetEquipProcess.onGC_UpdatePetEquip_Ntf)
    NetMgr.addProcess(Proto.Command.GC_PETEQUIPAPPRAISE_ACK,
        PetEquipProcess.onGC_PetEquipAppraise_Ack)
    NetMgr.addProcess(Proto.Command.GC_PETEQUIPRESTORE_ACK,
        PetEquipProcess.onGC_PetEquipRestore_Ack)
    NetMgr.addProcess(Proto.Command.GC_PETEQUIPPURIFY_ACK,
        PetEquipProcess.onGC_PetEquipPurify_Ack)
    NetMgr.addProcess(Proto.Command.GC_PETEQUIPBAPTISM_ACK,
        PetEquipProcess.onGC_PetEquipBaptism_Ack)
    NetMgr.addProcess(Proto.Command.GC_PETEQUIPSTRENGTHEN_ACK,
        PetEquipProcess.onGC_PetEquipStrengthen_Ack)
    NetMgr.addProcess(Proto.Command.GC_PETEQUIPCOMPOSE_ACK,
        PetEquipProcess.onGC_PetEquipCompose_Ack)
    NetMgr.addProcess(Proto.Command.GC_PETEQUIPOFF_ACK,
        PetEquipProcess.onGC_PetEquipOff_Ack)
    NetMgr.addProcess(Proto.Command.GC_PETEQUIPON_ACK,
        PetEquipProcess.onGC_PetEquipOn_Ack)

end

function PetEquipProcess.onGC_PetEquipOn_Ack(msg)

    local res = Proto.parseP_GC_PetEquipOn_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PetEquipOn_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PETEQUIPON_ACK)
    return res.code

end

function PetEquipProcess.onGC_PetEquipOff_Ack(msg)

    local res = Proto.parseP_GC_PetEquipOff_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PetEquipOff_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PETEQUIPOFF_ACK)
    return res.code

end

function PetEquipProcess.onGC_PetEquipCompose_Ack(msg)

    local res = Proto.parseP_GC_PetEquipCompose_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PetEquipCompose_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PETEQUIPCOMPOSE_ACK)
    return res.code

end

function PetEquipProcess.onGC_PetEquipStrengthen_Ack(msg)

    local res = Proto.parseP_GC_PetEquipStrengthen_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PetEquipStrengthen_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PETEQUIPSTRENGTHEN_ACK)
    return res.code

end

function PetEquipProcess.onGC_PetEquipBaptism_Ack(msg)

    local res = Proto.parseP_GC_PetEquipBaptism_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PetEquipBaptism_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PETEQUIPBAPTISM_ACK)
    return res.code

end

function PetEquipProcess.onGC_PetEquipPurify_Ack(msg)

    local res = Proto.parseP_GC_PetEquipPurify_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PetEquipPurify_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PETEQUIPPURIFY_ACK)
    return res.code

end

function PetEquipProcess.onGC_PetEquipRestore_Ack(msg)

    local res = Proto.parseP_GC_PetEquipRestore_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PetEquipRestore_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PETEQUIPRESTORE_ACK)
    return res.code

end

function PetEquipProcess.onGC_PetEquipAppraise_Ack(msg)

    local res = Proto.parseP_GC_PetEquipAppraise_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PetEquipAppraise_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("########onGC_PetEquipAppraise_Ack res=",sz_T2S(res))
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PETEQUIPAPPRAISE_ACK)
    return res.code

end

function PetEquipProcess.onGC_UpdatePetEquip_Ntf(msg)

    local res = Proto.parseP_GC_UpdatePetEquip_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_UpdatePetEquip_Ntf")
    print("###########onGC_UpdatePetEquip_Ntf res=",sz_T2S(res))
    PetEquipmentMgr.updateAllPetEquipment(res)
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_UPDATEPETEQUIP_NTF)
    return res.code

end

return PetEquipProcess
