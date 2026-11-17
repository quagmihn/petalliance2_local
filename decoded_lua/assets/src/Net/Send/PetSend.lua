require( "src.Net.Proto.ProtoInclude")

local PetSend = {}
local NetMgr = require("src.Net.NetMgr")

function PetSend.sendCG_QueryPokemons_Req()
    local endID = PokemonInfo.getEndIndex()+5
    if endID>PokemonInfo.getUnactivePetNum() then
        endID = PokemonInfo.getUnactivePetNum()
    end
    local data = {
        characterID = CharInfo.getCharID(),
        startIndex = PokemonInfo.getEndIndex(),
        endIndex = endID,
    }
    NetMgr.send(Proto.writeP_CG_QueryPokemons_Req, data)

end

function PetSend.sendCG_UpdateActivePetList_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_UpdateActivePetList_Req, data)

end

function PetSend.sendCG_UpdatePetArmys_Req(params)

    local data = {
        petArmys = params.petArmys,
    }
    NetMgr.send(Proto.writeP_CG_UpdatePetArmys_Req, data)

end

function PetSend.sendCG_GetPetArmys_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetPetArmys_Req, data)

end

function PetSend.sendCG_ActivePetArmy_Req(params)

    local data = {
        petArmyIndex = params.petArmyIndex,
    }
    NetMgr.send(Proto.writeP_CG_ActivePetArmy_Req, data)

end

function PetSend.sendCZ_FreePet_Req(params)

    local data = {
        petID = params,
    }
    NetMgr.send(Proto.writeP_CZ_FreePet_Req, data)

end

function PetSend.sendCG_PetFreedom_Req(params)

    local data = {
        petObjIDs = params,
    }
    NetMgr.send(Proto.writeP_CG_PetFreedom_Req, data)

end

function PetSend.sendCG_CapsuleEgg_Req(params)

    local data = {
        optType = params.optType,
        choice = params.choice,
        bFree = params.bFree,
        choiceEx = params.choiceEx,
    }
    NetMgr.send(Proto.writeP_CG_CapsuleEgg_Req, data)

end

function PetSend.sendCG_CapsuleEggCDs_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_CapsuleEggCDs_Req, data)

end

function PetSend.sendCG_CapsuleEggAllInfoCmd_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_CapsuleEggAllInfoCmd_Req, data)

end

function PetSend.sendCG_CompoundPetSkill_Req(params)

    local data = {
        SkillBookID = params.id,
        num = params.num
    }
    NetMgr.send(Proto.writeP_CG_CompoundPetSkill_Req, data)

end

function PetSend.sendCG_ResolvePetSkill_Req(params)

    local data = {
        SkillBookInfo = params
    }
    NetMgr.send(Proto.writeP_CG_ResolvePetSkill_Req, data)

end

function PetSend.sendCG_GetPetSkillWiki_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetPetSkillWiki_Req, data)

end

function PetSend.sendCG_CompoundPetPiece_Req(params)

    local data = {
        PetPieceID = params.PetPieceID
    }
    NetMgr.send(Proto.writeP_CG_CompoundPetPiece_Req, data)

end

function PetSend.sendCG_GetPetWiki_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetPetWiki_Req, data)

end

function PetSend.sendCG_ChangePetName_Req(params)

    local data = {
        petObjID = params.petObjID,
        newName = params.newName
    }
    NetMgr.send(Proto.writeP_CG_ChangePetName_Req, data)

end

function PetSend.sendCG_IwatchCatchPet_Req(params)

    local data = {
        petID = params.petID,
        itemID = params.itemID,
    }
    NetMgr.send(Proto.writeP_CG_IwatchCatchPet_Req, data)

end

function PetSend.sendCG_GetScienceDatas_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetScienceDatas_Req, data)

end

function PetSend.sendCG_ScienceLevelUp_Req(id)

    local data = {
        scienceID = id,
    }
    NetMgr.send(Proto.writeP_CG_ScienceLevelUp_Req, data)

end

function PetSend.sendCG_ScienceStarUp_Req(id)

    local data = {
        scienceID = id,
    }
    NetMgr.send(Proto.writeP_CG_ScienceStarUp_Req, data)

end

function PetSend.sendCG_ScienceConsume_Req(id, num)

    local data = {
        consumeID = id,
        consumeNum = num,
    }
    NetMgr.send(Proto.writeP_CG_ScienceConsume_Req, data)

end

function PetSend.sendCG_ResetScienceConsumes_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_ResetScienceConsumes_Req, data)

end

function PetSend.sendCG_ImportEthPet_Req(code)

    local data = {
		address = code
    }
    NetMgr.send(Proto.writeP_CG_ImportEthPet_Req, data)

end

return PetSend
