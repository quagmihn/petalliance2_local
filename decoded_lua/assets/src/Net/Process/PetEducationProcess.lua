require("src.Net.Proto.ProtoInclude")

local PetEducationProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function PetEducationProcess.init()
    NetMgr.addProcess(Proto.Command.GC_SUPEREVOLUTIONPET_ACK,
        PetEducationProcess.onGC_SuperEvolutionPet_Ack)
    NetMgr.addProcess(Proto.Command.GC_PETSTRENGOVERFLOW_ACK,
        PetEducationProcess.onGC_PetStrengOverflow_Ack)
    NetMgr.addProcess(Proto.Command.GC_CLEAREVOSKILLS_ACK,
        PetEducationProcess.onGC_ClearEvoSkills_Ack)
    NetMgr.addProcess(Proto.Command.GC_RESETPETSTAR_ACK,
        PetEducationProcess.onGC_ResetPetStar_Ack)
    NetMgr.addProcess(Proto.Command.GC_EATPET_ACK,
        PetEducationProcess.onGC_EatPet_Ack)
    NetMgr.addProcess(Proto.Command.GC_CHANGEPETEVOSKILL_ACK,
        PetEducationProcess.onGC_ChangePetEvoSkill_Ack)
    NetMgr.addProcess(Proto.Command.GC_POKEMONSKILLCHANGE_ACK,
        PetEducationProcess.onGC_PokemonSkillChange_Ack)
    NetMgr.addProcess(Proto.Command.GC_POKEMONSKILLLEVELUP_ACK,
        PetEducationProcess.onGC_PokemonSkillLevelUp_Ack)
    NetMgr.addProcess(Proto.Command.GC_PETSTARUP_ACK,
        PetEducationProcess.onGC_PetStarUp_Ack)
    NetMgr.addProcess(Proto.Command.GC_DELYOKEPET_ACK,
        PetEducationProcess.onGC_DelYokePet_Ack)
    NetMgr.addProcess(Proto.Command.GC_CHANGEYOKEPET_ACK,
        PetEducationProcess.onGC_ChangeYokePet_Ack)
    NetMgr.addProcess(Proto.Command.GC_UPDATEPETYOKEINFO_NTF,
        PetEducationProcess.onGC_UpdatePetYokeInfo_Ntf)
    NetMgr.addProcess(Proto.Command.GC_ADDYOKEPET_ACK,
        PetEducationProcess.onGC_AddYokePet_Ack)
    NetMgr.addProcess(Proto.Command.GC_EVOLUTIONPET_ACK,
        PetEducationProcess.onGC_EvolutionPet_Ack)
    NetMgr.addProcess(Proto.Command.GC_POKEMONADVASTAGELEVEL_ACK,
        PetEducationProcess.onGC_PokemonAdvaStageLevel_Ack)
    NetMgr.addProcess(Proto.Command.GC_RESETPETSTRENG_ACK,
        PetEducationProcess.onGC_ResetPetStreng_Ack)
    NetMgr.addProcess(Proto.Command.GC_PETSTRENG_ACK,
        PetEducationProcess.onGC_PetStreng_Ack)

end

function PetEducationProcess.onGC_PetStreng_Ack(msg)

    local res = Proto.parseP_GC_PetStreng_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PetStreng_Ack")
    print("GC_PetStreng_Ack",res.code)
    if (Proto.Error.ERROR_OK == res.code) then
    end
    if (Proto.Error.ERROR_NORESOURCE == res.code) then
        print("no resource...")
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PETSTRENG_ACK)
    return res.code

end

function PetEducationProcess.onGC_ResetPetStreng_Ack(msg)

    local res = Proto.parseP_GC_ResetPetStreng_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ResetPetStreng_Ack")
    print("GC_ResetPetStreng_Ack",res.code)
    if (Proto.Error.ERROR_OK == res.code) then
    end
    if (Proto.Error.ERROR_NOTENOUGH_RMB == res.code) then
        print("ERROR_NOTENOUGH_RMB")
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_RESETPETSTRENG_ACK)
    return res.code

end

function PetEducationProcess.onGC_PokemonAdvaStageLevel_Ack(msg)

    local res = Proto.parseP_GC_PokemonAdvaStageLevel_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PokemonAdvaStageLevel_Ack")
    print(res.code)
    if (Proto.Error.ERROR_OK == res.code) then
        print(res.stage)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_POKEMONADVASTAGELEVEL_ACK)
    return res.code

end

function PetEducationProcess.onGC_EvolutionPet_Ack(msg)

    local res = Proto.parseP_GC_EvolutionPet_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_EvolutionPet_Ack")
    print("GC_EvolutionPet_Ack",res.code)
    if (Proto.Error.ERROR_OK == res.code) then
        PetEducationMgr.addSkills = res.addSkills
    end
    if (Proto.Error.ERROR_PetEvoLowLevel == res.code) then
        print("ERROR_PetEvoLowLevel")
        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,1,"ERROR_PetEvoLowLevel")
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_EVOLUTIONPET_ACK)
    return res.code

end

function PetEducationProcess.onGC_AddYokePet_Ack(msg)

    local res = Proto.parseP_GC_AddYokePet_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_AddYokePet_Ack")
    print(res.code)
    if (Proto.Error.ERROR_OK == res.code) then
        print("succeed...")
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_ADDYOKEPET_ACK)
    return res.code

end

function PetEducationProcess.onGC_DelYokePet_Ack(msg)

    local res = Proto.parseP_GC_DelYokePet_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_DelYokePet_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_DELYOKEPET_ACK)
    return res.code

end

function PetEducationProcess.onGC_ChangeYokePet_Ack(msg)

    local res = Proto.parseP_GC_ChangeYokePet_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ChangeYokePet_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CHANGEYOKEPET_ACK)
    return res.code

end

function PetEducationProcess.onGC_UpdatePetYokeInfo_Ntf(msg)

    local res = Proto.parseP_GC_UpdatePetYokeInfo_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_UpdatePetYokeInfo_Ntf")
    print("GC_UpdatePetYokeInfo_Ntf")
    PetEducationMgr.updatePetYokeInfo(res.petsYoke)
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_UPDATEPETYOKEINFO_NTF)
    return res.code

end

function PetEducationProcess.onGC_PetStarUp_Ack(msg)

    local res = Proto.parseP_GC_PetStarUp_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PetStarUp_Ack")
    print(res.code)
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PETSTARUP_ACK)
    return res.code

end

function PetEducationProcess.onGC_PokemonSkillLevelUp_Ack(msg)
    local res = Proto.parseP_GC_PokemonSkillLevelUp_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PokemonSkillLevelUp_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        if CSResourceMgr.getCsbObj("Pet/Education/HomePageNew.csb") then
            PetEducationMgr.refreshMainPageSingleSkill(res.objID, res.newSkillID, res.skillIndex)
        elseif CSResourceMgr.getCsbObj("Pet/Education/StarupPageNew.csb") then
            PetStarUpMgr.OnSkillUpdate(res)
        end
    else
        print("faild in upgrade pet skill!")
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_POKEMONSKILLLEVELUP_ACK)
    return res.code
end

function PetEducationProcess.onGC_PokemonSkillChange_Ack(msg)
    local res = Proto.parseP_GC_PokemonSkillChange_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PokemonSkillChange_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        if CSResourceMgr.getCsbObj("Pet/Education/HomePageNew.csb") then
            PetEducationMgr.refreshMainPageSingleSkill(res.objID, res.newSkillID, res.skillIndex)
        elseif CSResourceMgr.getCsbObj("Pet/Education/StarupPageNew.csb") then
            PetStarUpMgr.OnSkillUpdate(res)
        end
    else
        print("faild in change pet skill!")
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_POKEMONSKILLCHANGE_ACK)
    return res.code
end

function PetEducationProcess.onGC_ChangePetEvoSkill_Ack(msg)

    local res = Proto.parseP_GC_ChangePetEvoSkill_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ChangePetEvoSkill_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        PetEducationMgr.refreshMainPageSingleSkill(res.petObjID, res.skillID, res.skillIndex)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CHANGEPETEVOSKILL_ACK)
    return res.code

end

function PetEducationProcess.onGC_EatPet_Ack(msg)

    local res = Proto.parseP_GC_EatPet_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_EatPet_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        PetEatPetViewMgr.onEatPetSuccess()
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_EATPET_ACK)
    return res.code

end

function PetEducationProcess.onGC_ResetPetStar_Ack(msg)

    local res = Proto.parseP_GC_ResetPetStar_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ResetPetStar_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_RESETPETSTAR_ACK)
    return res.code

end

function PetEducationProcess.onGC_ClearEvoSkills_Ack(msg)

    local res = Proto.parseP_GC_ClearEvoSkills_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ClearEvoSkills_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CLEAREVOSKILLS_ACK)
    return res.code

end

function PetEducationProcess.onGC_PetStrengOverflow_Ack(msg)

    local res = Proto.parseP_GC_PetStrengOverflow_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PetStrengOverflow_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PETSTRENGOVERFLOW_ACK)
    return res.code

end

function PetEducationProcess.onGC_SuperEvolutionPet_Ack(msg)

    local res = Proto.parseP_GC_SuperEvolutionPet_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_SuperEvolutionPet_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
		PetEducationMgr.addSkills = res.addSkills
    end

    if (Proto.Error.ERROR_PetEvoLowLevel == res.code) then
        print("ERROR_PetEvoLowLevel")
        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,1,"ERROR_PetEvoLowLevel")
    end
    
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_SUPEREVOLUTIONPET_ACK)
    return res.code

end

return PetEducationProcess
