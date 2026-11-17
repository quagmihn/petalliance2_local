require( "src.Net.Proto.ProtoInclude")

local PetEquipSend = {}
local NetMgr = require("src.Net.NetMgr")

function PetEquipSend.sendCG_PetEquipOn_Req(params)

    local data = {
        petObjID = params.petObjID,
        equipObjID = params.equipObjID,
    }
    NetMgr.send(Proto.writeP_CG_PetEquipOn_Req, data)

end

function PetEquipSend.sendCG_PetEquipOff_Req(params)

    local data = {
        petObjID = params.petObjID,
        pos = params.pos,
    }
    NetMgr.send(Proto.writeP_CG_PetEquipOff_Req, data)

end

function PetEquipSend.sendCG_PetEquipCompose_Req(params)

    local data = {
        itemID = params.itemID,
    }
    NetMgr.send(Proto.writeP_CG_PetEquipCompose_Req, data)

end

function PetEquipSend.sendCG_PetEquipStrengthen_Req(params)

    local data = {
        ObjID = params.ObjID,
        pos = params.pos,
        luckStoneID = params.luckStoneID,
    }
    NetMgr.send(Proto.writeP_CG_PetEquipStrengthen_Req, data)

end

function PetEquipSend.sendCG_PetEquipBaptism_Req(params)

    local data = {
        ObjID = params.ObjID,
        pos = params.pos,
        strengthenLevel = params.strengthenLevel,
    }
    NetMgr.send(Proto.writeP_CG_PetEquipBaptism_Req, data)

end

function PetEquipSend.sendCG_PetEquipPurify_Req(params)

    local data = {
        ObjID = params.ObjID,
        pos = params.pos,
        purifyStoneNum = params.purifyStoneNum,
        equips = params.equips,
    }
    NetMgr.send(Proto.writeP_CG_PetEquipPurify_Req, data)

end

function PetEquipSend.sendCG_PetEquipRestore_Req(params)

    local data = {
        objID = params.objID,
        pos = params.pos,
    }
    NetMgr.send(Proto.writeP_CG_PetEquipRestore_Req, data)

end

function PetEquipSend.sendCG_PetEquipAppraise_Req(params)

    local data = {
        itemID = params.itemID,
    }
    NetMgr.send(Proto.writeP_CG_PetEquipAppraise_Req, data)

end

return PetEquipSend
