require( "src.Net.Proto.ProtoInclude")

local PetEducationSend = {}
local NetMgr = require("src.Net.NetMgr")

function PetEducationSend.sendCG_PetStreng_Req(params)

    local data = {
        petObjID = params.petObjID,
        addPoints = params.addPoints,
    }
    NetMgr.send(Proto.writeP_CG_PetStreng_Req, data)

end

function PetEducationSend.sendCG_ResetPetStreng_Req(params)

    local data = {
        petObjID = params.petObjID,
    }
    NetMgr.send(Proto.writeP_CG_ResetPetStreng_Req, data)

end

function PetEducationSend.sendCG_PokemonAdvaStageLevel_Req(params)

    local data = {
        objID = params.objID,
    }
    NetMgr.send(Proto.writeP_CG_PokemonAdvaStageLevel_Req, data)

end

function PetEducationSend.sendCG_EvolutionPet_Req(params)

    local data = {
        objID = params.objID, -- 请求进化的宠物ID
        choice = params.choice, -- 进化的方�?
        bProtectSkin = params.bProtectSkin -- 保留形态对应的属�?
    }
    NetMgr.send(Proto.writeP_CG_EvolutionPet_Req, data)

end

function PetEducationSend.sendCG_AddYokePet_Req(params)

    local data = {
        objID       = params.objID,
        yokeID      = params.yokeID,
        yokeCellID  = params.yokeCellID,
        assistObjID = params.assistObjID,
    }
    NetMgr.send(Proto.writeP_CG_AddYokePet_Req, data)

end

function PetEducationSend.sendCG_DelYokePet_Req(params)

    local data = {
        objID       = params.objID,
        yokeID      = params.yokeID,
        yokeCellID  = params.yokeCellID,
    }
    NetMgr.send(Proto.writeP_CG_DelYokePet_Req, data)

end

function PetEducationSend.sendCG_ChangeYokePet_Req(params)

    local data = {
        objID       = params.objID,
        yokeID      = params.yokeID,
        yokeCellID  = params.yokeCellID,
        assistObjID = params.assistObjID,
    }
    NetMgr.send(Proto.writeP_CG_ChangeYokePet_Req, data)

end

function PetEducationSend.sendCG_PetStarUp_Req(params)

    local data = {
        petObjID = params.petObjID,
        costPetObjIDs = params.costPetObjIDs
    }
    NetMgr.send(Proto.writeP_CG_PetStarUp_Req, data)

end

function PetEducationSend.sendCG_ChangePetEvoSkill_Req(params)
    
    local data = {
        petObjID = params.petObjID,
        skillIndex = params.skillIndex,
        skillID = params.skillID
    }
    NetMgr.send(Proto.writeP_CG_ChangePetEvoSkill_Req, data)

end

function PetEducationSend.sendCG_PokemonSkillLevelUp_Req(params)
    local data = {
        objID = params.objID,
        skillIndex = params.skillIndex
    }
    NetMgr.send(Proto.writeP_CG_PokemonSkillLevelUp_Req, data)
end

function PetEducationSend.sendCG_PokemonSkillChange_Req(params)
    local data = {
        objID = params.objID,
        skillIndex = params.skillIndex,
        itemID = params.itemID
    }
    NetMgr.send(Proto.writeP_CG_PokemonSkillChange_Req, data)
end

function PetEducationSend.sendCG_EatPet_Req(params)

    local data = {
        petObjID = params.petObjID,
        eatPetObjID = params.eatPetObjID,
    }
    NetMgr.send(Proto.writeP_CG_EatPet_Req, data)

end

function PetEducationSend.sendCG_ResetPetStar_Req(params)

    local data = {
        objID = params.objID,
    }
    NetMgr.send(Proto.writeP_CG_ResetPetStar_Req, data)

end

function PetEducationSend.sendCG_ClearEvoSkills_Req(params)

    local data = {
        objID = params.objID
    }
    NetMgr.send(Proto.writeP_CG_ClearEvoSkills_Req, data)

end

function PetEducationSend.sendCG_PetStrengOverflow_Req(params)

    local data = {
        petObjID = params.petObjID,
        oName    = params.oName
    }
    NetMgr.send(Proto.writeP_CG_PetStrengOverflow_Req, data)

end

function PetEducationSend.sendCG_SuperEvolutionPet_Req(params)
    print("sendCG_SuperEvolutionPet_Req",sz_T2S(params))
    local data = {
        objID = params.objID, -- 请求进化的宠物ID
        choice = params.choice, -- 进化
        bProtectSkin = params.bProtectSkin -- 保留形态对
    }
    NetMgr.send(Proto.writeP_CG_SuperEvolutionPet_Req, data)

end

return PetEducationSend
