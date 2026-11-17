require("src.Net.Proto.ProtoInclude")

local PetProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")
local count = nil
local index = 0

function PetProcess.init()
    NetMgr.addProcess(Proto.Command.GC_RESETSCIENCECONSUMES_ACK,
        PetProcess.onGC_ResetScienceConsumes_Ack)
    NetMgr.addProcess(Proto.Command.GC_SCIENCECONSUME_ACK,
        PetProcess.onGC_ScienceConsume_Ack)
    NetMgr.addProcess(Proto.Command.GC_SCIENCESTARUP_ACK,
        PetProcess.onGC_ScienceStarUp_Ack)
    NetMgr.addProcess(Proto.Command.GC_SCIENCELEVELUP_ACK,
        PetProcess.onGC_ScienceLevelUp_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETSCIENCEDATAS_ACK,
        PetProcess.onGC_GetScienceDatas_Ack)
    NetMgr.addProcess(Proto.Command.GC_IWATCHCATCHPET_ACK,
        PetProcess.onGC_IwatchCatchPet_Ack)
    NetMgr.addProcess(Proto.Command.GC_CHANGEPETNAME_ACK,
        PetProcess.onGC_ChangePetName_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETPETWIKI_NTF,
        PetProcess.onGC_GetPetWiki_Ntf)
    NetMgr.addProcess(Proto.Command.GC_GETPETWIKI_ACK,
        PetProcess.onGC_GetPetWiki_Ack)
    NetMgr.addProcess(Proto.Command.GC_COMPOUNDPETPIECE_ACK,
        PetProcess.onGC_CompoundPetPiece_Ack)
    NetMgr.addProcess(Proto.Command.GC_UPDATEPETSKILLWIKI_NTF,
        PetProcess.onGC_UpdatePetSkillWiki_Ntf)
    NetMgr.addProcess(Proto.Command.GC_GETPETSKILLWIKI_NTF,
        PetProcess.onGC_GetPetSkillWiki_Ntf)
    NetMgr.addProcess(Proto.Command.GC_GETPETSKILLWIKI_ACK,
        PetProcess.onGC_GetPetSkillWiki_Ack)
    NetMgr.addProcess(Proto.Command.GC_RESOLVEPETSKILL_ACK,
        PetProcess.onGC_ResolvePetSkill_Ack)
    NetMgr.addProcess(Proto.Command.GC_COMPOUNDPETSKILL_ACK,
        PetProcess.onGC_CompoundPetSkill_Ack)
    NetMgr.addProcess(Proto.Command.GC_CAPSULEEGGALLINFOCMD_ACK,
        PetProcess.onGC_CapsuleEggAllInfoCmd_Ack)
    NetMgr.addProcess(Proto.Command.GC_CAPSULEEGGCDS_ACK,
        PetProcess.onGC_CapsuleEggCDs_Ack)
    NetMgr.addProcess(Proto.Command.GC_CAPSULEEGG_ACK,
        PetProcess.onGC_CapsuleEgg_Ack)
    NetMgr.addProcess(Proto.Command.GC_PETFREEDOM_ACK,
        PetProcess.onGC_PetFreedom_Ack)
    NetMgr.addProcess(Proto.Command.ZC_FREEPET_ACK,
        PetProcess.onZC_FreePet_Ack)
    NetMgr.addProcess(Proto.Command.GC_ACTIVEPETARMY_ACK,
        PetProcess.onGC_ActivePetArmy_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETPETARMYS_ACK,
        PetProcess.onGC_GetPetArmys_Ack)
    NetMgr.addProcess(Proto.Command.GC_UPDATEPETARMYS_ACK,
        PetProcess.onGC_UpdatePetArmys_Ack)
    NetMgr.addProcess(Proto.Command.GC_UPDATEACTIVEPETLIST_ACK,
        PetProcess.onGC_UpdateActivePetList_Ack)
    NetMgr.addProcess(Proto.Command.GC_UPDATEACTIVITYPOKEMONS_NTF,
        PetProcess.onGC_UpdateActivityPokemons_Ntf)
    NetMgr.addProcess(Proto.Command.GC_DELPOKEMON_NTF,
        PetProcess.onGC_DelPokemon_Ntf)
    NetMgr.addProcess(Proto.Command.GC_UPDATEPOKEMON_NTF,
        PetProcess.onGC_UpdatePokemon_Ntf)
    NetMgr.addProcess(Proto.Command.GC_QUERYPOKEMONS_ACK,
        PetProcess.onGC_QueryPokemons_Ack)
	NetMgr.addProcess(Proto.Command.GC_IMPORTETHPET_ACK,
        PetProcess.onGC_ImportEthPet_Ack)

end

function PetProcess.onGC_QueryPokemons_Ack(msg) 
    local res = Proto.parseP_GC_QueryPokemons_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_QueryPokemons_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        PokemonInfo.set(res)
--        print("@@@@@@@@@@@"..#res.activePets) 
--        print("###########"..res.activePets[1])
        --[[
        local many =table.getn(res.activePets)
        print(many)
        for i = 1,#res.activePets do
            print("###########"..res.activePets[i])
        end
        local cjson = require("cjson")
        local j = cjson.decode(res.activePets[1])
        for k,v in pairs(j) do
            print(k..":",v)  
        end]]
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_QUERYPOKEMONS_ACK)
    return res.code

end

function PetProcess.onGC_UpdatePokemon_Ntf(msg)

    local res = Proto.parseP_GC_UpdatePokemon_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_UpdatePokemon_Ntf")
    
    print("###########add/fresh pet:"..res.objID, res.pet)
    PokemonInfo.refreshPet(res.objID, res.pet)
    ItemInfoViewMgr.setCompoundPetInfo(res.pet)
    PurchaseViewMgr.setCompoundPetInfo(res.pet)
    ActivityViewMgr.setCompoundPetInfo(res.pet)
    ActivityHalloweenViewMgr.setCompoundPetInfo(res.pet)
    TreeInfoView.setCompoundPetInfo(res.pet)
    PetEducationMgr.updateSevenDayPetYoke(res.objID)

    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_UPDATEPOKEMON_NTF)
    return res.code

end

function PetProcess.onGC_DelPokemon_Ntf(msg)
    local res = Proto.parseP_GC_DelPokemon_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_DelPokemon_Ntf")
    
    print("###########delete pet"..res.objID)
    PokemonInfo.deletePet(res.objID)
    
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_DELPOKEMON_NTF)
    return res.code 

end

function PetProcess.onGC_UpdateActivityPokemons_Ntf(msg)

    local res = Proto.parseP_GC_UpdateActivityPokemons_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_UpdateActivityPokemons_Ntf")
    PokemonInfo.set(res)
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_UPDATEACTIVITYPOKEMONS_NTF)
    return res.code

end

function PetProcess.onGC_UpdateActivePetList_Ack(msg)

    local res = Proto.parseP_GC_UpdateActivePetList_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_UpdateActivePetList_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_UPDATEACTIVEPETLIST_ACK)
    return res.code

end

function PetProcess.onGC_UpdatePetArmys_Ack(msg)

    local res = Proto.parseP_GC_UpdatePetArmys_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_UpdatePetArmys_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("UpdatePetArmys success...")
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_UPDATEPETARMYS_ACK)
    return res.code

end

function PetProcess.onGC_GetPetArmys_Ack(msg)

    local res = Proto.parseP_GC_GetPetArmys_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetPetArmys_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("##########pet army:", res.petArmys)
        if res.petArmys then
            local cjson = require("cjson")
            local vec = cjson.decode(res.petArmys)
            if vec then
                local armyVec = {}
                local helpVec = {}
                for k, v in pairs(vec) do
                    local idx = tonumber(k)
                    if idx then
                        armyVec[idx] = v
                    end
                    if tostring(k) == "1h" then
                        helpVec = v
                    end
                end
                PokemonInfo.setPetArmy(armyVec)
                PokemonInfo.setHelpArmy(helpVec)
            end
        end
        
        --[[
        print("##########pet army size:", #res.petArmys)
        local tmpVec = {}
        for var=1, #res.petArmys do
            tmpVec[var] = res.petArmys[var].DWORDVec
        end
        PokemonInfo.setPetArmy(tmpVec)]]
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETPETARMYS_ACK)
    return res.code

end

function PetProcess.onGC_ActivePetArmy_Ack(msg)

    local res = Proto.parseP_GC_ActivePetArmy_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ActivePetArmy_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_ACTIVEPETARMY_ACK)
    return res.code

end

function PetProcess.onZC_FreePet_Ack(msg)

    local res = Proto.parseP_ZC_FreePet_Ack(msg)
    MsgPrinter.rcvMsg(res, "ZC_FreePet_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.ZC_FREEPET_ACK)
    return res.code

end

function PetProcess.onGC_PetFreedom_Ack(msg)

    local res = Proto.parseP_GC_PetFreedom_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PetFreedom_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("PetFreedom_Ack success!")
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PETFREEDOM_ACK)
    return res.code

end

function PetProcess.onGC_CapsuleEgg_Ack(msg)

    local res = Proto.parseP_GC_CapsuleEgg_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_CapsuleEgg_Ack")
    print(res.code)
    if (Proto.Error.ERROR_OK == res.code) then
        for k,v in pairs(res.awardVecStr) do
            print(k,v)
        end
        local cjson = require("cjson")  
        if #res.awardVecStr == 1 then
            local award = cjson.decode(res.awardVecStr[1])
            GachaViewMgr.setOneDrawAward(award)
        else
            local awards = {}
            for k,v in pairs(res.awardVecStr) do
                local award = cjson.decode(v)
                awards[tonumber(k)] = award
            end
            GachaViewMgr.setTenDrawAward(awards)
        end
    elseif (Proto.Error.ERROR__PET_BRINGLIMIT == res.code) then
        GachaViewMgr.showBringLimitDialog() 
    elseif (Proto.Error.ERROR_NOT_ENOUGH_BAG_FREE_CELL == res.code) then
        GachaViewMgr.showNotEnoughBagFreeCellDialog() 
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CAPSULEEGG_ACK)
    return res.code

end

function PetProcess.onGC_CapsuleEggCDs_Ack(msg)

    local res = Proto.parseP_GC_CapsuleEggCDs_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_CapsuleEggCDs_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        -- for k,v in pairs(res.capsuleEggTimeAndCDsVec) do
        --     -- GachaViewMgr.setCoolDown(time)
        --     print(k,v)
        -- end
        local lastTime1G = res.capsuleEggTimeAndCDsVec[1].timeLast or 0
        local lastTime1M = res.capsuleEggTimeAndCDsVec[2].timeLast or 0
        GachaViewMgr.setLastTime(lastTime1G,res.capsuleEggTimeAndCDsVec[1].times,lastTime1M)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CAPSULEEGGCDS_ACK)
    return res.code

end

function PetProcess.onGC_CapsuleEggAllInfoCmd_Ack(msg)

    local res = Proto.parseP_GC_CapsuleEggAllInfoCmd_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_CapsuleEggAllInfoCmd_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print(res.capsuleEggAllInfo)

        local cjson = require("cjson")
        local capsuleEggAllInfo = cjson.decode(res.capsuleEggAllInfo)
        GachaViewMgr.setCapsuleEggAllInfo(capsuleEggAllInfo)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CAPSULEEGGALLINFOCMD_ACK)
    return res.code

end

function PetProcess.onGC_CompoundPetSkill_Ack(msg)

    local res = Proto.parseP_GC_CompoundPetSkill_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_CompoundPetSkill_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("CompoundPetSkill Success!")
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_COMPOUNDPETSKILL_ACK)
    return res.code

end

function PetProcess.onGC_ResolvePetSkill_Ack(msg)

    local res = Proto.parseP_GC_ResolvePetSkill_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ResolvePetSkill_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("ResolvePetSkill Success!")
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_RESOLVEPETSKILL_ACK)
    return res.code

end

function PetProcess.onGC_GetPetSkillWiki_Ack(msg)

    local res = Proto.parseP_GC_GetPetSkillWiki_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetPetSkillWiki_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("GetPetSkillWiki Success!")
        count = math.ceil(res.skillBookNum/20)
        if count == 0 then
            SkillBookViewMgr.open(SceneMgr.getRunningScene)
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETPETSKILLWIKI_ACK)
    return res.code

end

function PetProcess.onGC_GetPetSkillWiki_Ntf(msg)

    local res = Proto.parseP_GC_GetPetSkillWiki_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_GetPetSkillWiki_Ntf")
    for k,v in pairs(res.skillBookIDs) do
        SkillBookViewMgr.UpdateSkillInfo(v)
    end
    index = index + 1
    if index == count then
        SkillBookViewMgr.open(SceneMgr.getRunningScene)
        index = 0
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETPETSKILLWIKI_NTF)
    return res.code

end

function PetProcess.onGC_UpdatePetSkillWiki_Ntf(msg)

    local res = Proto.parseP_GC_UpdatePetSkillWiki_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_UpdatePetSkillWiki_Ntf")
    print("UpdatePetSkillWiki_Ntf")
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_UPDATEPETSKILLWIKI_NTF)
    return res.code

end

function PetProcess.onGC_CompoundPetPiece_Ack(msg)

    local res = Proto.parseP_GC_CompoundPetPiece_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_CompoundPetPiece_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_COMPOUNDPETPIECE_ACK)
    return res.code

end

function PetProcess.onGC_GetPetWiki_Ack(msg)

    local res = Proto.parseP_GC_GetPetWiki_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetPetWiki_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETPETWIKI_ACK)
    return res.code

end

function PetProcess.onGC_GetPetWiki_Ntf(msg)

    local res = Proto.parseP_GC_GetPetWiki_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_GetPetWiki_Ntf")
    PetHandBook.SetPetWikiInfo(res.petWiki)
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETPETWIKI_NTF)
    return res.code

end

function PetProcess.onGC_ChangePetName_Ack(msg)

    local res = Proto.parseP_GC_ChangePetName_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ChangePetName_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CHANGEPETNAME_ACK)
    return res.code

end

function PetProcess.onGC_IwatchCatchPet_Ack(msg)

    local res = Proto.parseP_GC_IwatchCatchPet_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_IwatchCatchPet_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_IWATCHCATCHPET_ACK)
    return res.code

end

function PetProcess.onGC_GetScienceDatas_Ack(msg)

    local res = Proto.parseP_GC_GetScienceDatas_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetScienceDatas_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        ScienceInfo.refreshSkillInfo(res.datas)
        ScienceInfo.setPurchaseOrder(res.consumeDatas, res.consumedDatas, res.updateTime)
        --[[
        local vec = ScienceInfo.getScienceAttrsTable(res.datas)
        print("~~~~~~~!!!!!", sz_T2S(vec))]]
    else
        print("GC_GetScienceDatas_Ack error code:", res.code, sz_T2S(res))
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETSCIENCEDATAS_ACK)
    return res.code

end

function PetProcess.onGC_ScienceLevelUp_Ack(msg)

    local res = Proto.parseP_GC_ScienceLevelUp_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ScienceLevelUp_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        ScienceInfo.refreshSkillInfo({res.data})
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_SCIENCELEVELUP_ACK)
    return res.code

end

function PetProcess.onGC_ScienceStarUp_Ack(msg)

    local res = Proto.parseP_GC_ScienceStarUp_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ScienceStarUp_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        ScienceInfo.refreshSkillInfo({res.data})
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_SCIENCESTARUP_ACK)
    return res.code

end

function PetProcess.onGC_ScienceConsume_Ack(msg)

    local res = Proto.parseP_GC_ScienceConsume_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ScienceConsume_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        --ScienceInfo.setPurchaseOrder(res.consumeDatas, res.consumedDatas) 
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_SCIENCECONSUME_ACK)
    return res.code

end

function PetProcess.onGC_ResetScienceConsumes_Ack(msg)

    local res = Proto.parseP_GC_ResetScienceConsumes_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ResetScienceConsumes_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        ScienceInfo.setPurchaseOrder(res.consumeDatas, res.consumedDatas) 
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_RESETSCIENCECONSUMES_ACK)
    return res.code

end

function PetProcess.onGC_ImportEthPet_Ack(msg)

    local res = Proto.parseP_GC_ImportEthPet_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ImportEthPet_Ack")
	
    if (Proto.Error.ERROR_OK == res.code) then
	    local cjson = require("cjson")
		local vec = cjson.decode(res.pet)
		GachaViewMgr.playGetAPet(tonumber(vec.pokeID),nil,nil,tonumber(vec.skin)) 
        print("ImportEthPet success...")
	else
		print("ImportEthPet failed...code:"..res.code)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_IMPORTETHPET_ACK)
    return res.code

end

return PetProcess
