local BattleGetPetInfo  = {}
local skillInfo         = nil
local skillData         = {}
local skillAniTbl       = {}
local petTag            = 1

function BattleGetPetInfo.createPet(pet,petType,scienceValue)
    local info = PokemonInfo.getPokemonInfoByID(pet.pokeID)
    local baseAttr = {}
    local _fightSkin = tonumber(info.fightSkin)
    local resStr = PokemonInfo.getPokemonResByID(pet.pokeID)
    if petType == 0 then
        resStr = PokemonInfo.getPokemonResBackByID(pet.pokeID) 
    end
    
    local star          = 5
    local hpx           = 0
    local stage         = 0
    local petMon        = nil
    local petPaSkills   = {}
    local buffPercent   = 1
    local buffValue     = 0
    local angerMax      = 0
    local experience    = 0
    local YokeValues    = {}
    local YokeRates     = {}
    local YokePercent   = {}
    local petAnger      = pet.anger or 0
    -- local Yoke  = PetEducationMgr.getYokeParamsTable(pet)
    -- YokeValues  = Yoke.values
    -- YokeRates   = Yoke.rates
    -- YokePercent = Yoke.yokePer

    YokeValues = {0,0,0,0,0,0,}
    YokeRates  = {0,0,0,0,0,0,}
    YokePercent = {0,0,0,0,0,0,0,0,0,0,}

    local valueTable = {1,2,3,4,5,6}
    local ratesTable = {12,13,14,15,16,17}--这个已经不用了，id是错的
    local percentTable = {7,9,11,12,13,8,15,16,10,14}
    if pet.yoke and pet.yoke.yokeValues then
        local values = pet.yoke.yokeValues
        for i = 1, #valueTable do
            YokeValues[i] = values[valueTable[i]] or 0
        end
        for i = 1, #ratesTable do
            YokeRates[i] = 0
        end
        for i = 1, #percentTable do
            YokePercent[i] = values[percentTable[i]] or 0
        end
    end

    local skinValue = PetEducationMgr.getDiversAttrsTable(pet)
    local equipmentValue    = PetEquipmentMgr.calcAllAttr(pet)
    local scieMaxLevel   = SystemInfo.getGlobalConfigAddInfoByID(61005).values[1] 

    if pet.level < scieMaxLevel  then
        scienceValue = {}
    end

    local function setbuffInfo(buffType)
        local buffer = BattleMapMgr.getTemporaryBuffer(buffType)
        if buffer then
            if buffer.per then
                buffPercent = buffer.per + 1
            else
                buffPercent = 1
            end
            if buffer.val then
                buffValue  = buffer.val
            else
                buffValue = 0
            end
        else
            buffPercent = 1
            buffValue   = 0
        end
    end
    
    if pet.Stage ~= nil then
        stage = pet.Stage
    end

    if not pet.skin then
        pet.skin = 0 
    end

    if pet.star ~= nil then 
        star = pet.star
    end

    if pet.hpx ~= nil then
        hpx = pet.hpx
    end

    if petType == 0 then
        setbuffInfo("hp")
    end

    if pet.hp == nil then
        if pet.monster then
            baseAttr["hp"] = math.floor(BattleBasicValueCalc.calcHp(info,star,hpx,equipmentValue[Proto.PEET_HP],YokeValues[1],
                equipmentValue[Proto.PEET_HP_Per],YokeRates[1],
                stage,pet.level,skinValue[Proto.AT_HP])*pet.monster.amendmentHP/1000,scienceValue[Proto.AT_HP]) 
        else
            baseAttr["hp"] = math.floor(BattleBasicValueCalc.calcHp(info,star,hpx,equipmentValue[Proto.PEET_HP],YokeValues[1],
                equipmentValue[Proto.PEET_HP_Per],YokeRates[1],
                stage,pet.level,skinValue[Proto.AT_HP])*buffPercent + buffValue,scienceValue[Proto.AT_HP])
        end
    else
        baseAttr["hp"] = pet.hp
    end

    if pet.objID == nil then
        baseAttr["objID"] = 0
    else
        baseAttr["objID"] = pet.objID
    end

    if pet.hpmax == nil then
        if pet.monster then
            baseAttr["hpmax"] = math.floor(BattleBasicValueCalc.calcHp(info,star,hpx,equipmentValue[Proto.PEET_HP],YokeValues[1],
                            equipmentValue[Proto.PEET_HP_Per],YokeRates[1],stage,pet.level,
                            skinValue[Proto.AT_HP])*pet.monster.amendmentHP/1000,scienceValue[Proto.AT_HP]) 
        else
            baseAttr["hpmax"] = math.floor(BattleBasicValueCalc.calcHp(info,star,hpx,equipmentValue[Proto.PEET_HP],YokeValues[1],
                            equipmentValue[Proto.PEET_HP_Per],YokeRates[1],stage,
                            pet.level,skinValue[Proto.AT_HP])*buffPercent + buffValue,scienceValue[Proto.AT_HP])
        end
    else
        if IS_SERVER_CODE == nil then 
            baseAttr["hpmax"] = pet.hpmax
        else
            baseAttr["hpmax"] = pet.hpmax + (scienceValue[Proto.AT_HP] or 0)
        end
    end 

    --if baseAttr["hp"] > baseAttr["hpmax"] then 
   --     baseAttr["hp"] = baseAttr["hpmax"]
   -- end

    local baseValue = 0
    if pet.speed == nil then
        pet.speed = 0
        baseValue = pet.speedV or BattleBasicValueCalc.calcSpeed(info,star,pet.speed,equipmentValue[Proto.PEET_SPEED],YokeValues[6],equipmentValue[Proto.PEET_SPEED_Per],
                YokeRates[6],stage,pet.level,skinValue[Proto.AT_SPEED],scienceValue[Proto.AT_SPEED])*pet.monster.amendmentSPD/1000
        baseAttr["speed"] = baseValue
    else
        baseValue = pet.speedV or BattleBasicValueCalc.calcSpeed(info,star,pet.speed,equipmentValue[Proto.PEET_SPEED],
            YokeValues[6],equipmentValue[Proto.PEET_SPEED_Per],YokeRates[6],stage,pet.level,
            skinValue[Proto.AT_SPEED],scienceValue[Proto.AT_SPEED])
        baseAttr["speed"] = baseValue
    end
 
    if petType == 0 then
        setbuffInfo("speed")
        baseAttr["speed"] = baseValue*buffPercent + buffValue
    end

    if pet.atk == nil then
        baseValue = pet.atkV or BattleBasicValueCalc.calcAct(info,star,0,equipmentValue[Proto.PEET_ATK],YokeValues[2],equipmentValue[Proto.PEET_ATK_Per],YokeRates[2],
            stage,pet.level,skinValue[Proto.AT_ATK],scienceValue[Proto.AT_ATK])*pet.monster.amendmentATK/1000
        baseAttr["atk"] = baseValue
        pet.atk = 0
    else
        baseValue = pet.atkV or BattleBasicValueCalc.calcAct(info,star,pet.atk,equipmentValue[Proto.PEET_ATK],YokeValues[2],equipmentValue[Proto.PEET_ATK_Per],
            YokeRates[2],stage,pet.level,skinValue[Proto.AT_ATK],scienceValue[Proto.AT_ATK])
        baseAttr["atk"] = baseValue
    end 

    if petType == 0 then
        setbuffInfo("atk")
        baseAttr["atk"] = baseValue*buffPercent + buffValue 
    end

    if pet.def == nil then
        baseValue = pet.defV or BattleBasicValueCalc.calcDef(info,star,0,equipmentValue[Proto.PEET_DEF],YokeValues[3],
            equipmentValue[Proto.PEET_DEF_Per],YokeRates[3],stage,pet.level,skinValue[Proto.AT_DEF],scienceValue[Proto.AT_DEF])*pet.monster.amendmentDEF/1000
        baseAttr["def"] = baseValue
        pet.def = 0
    else
        baseValue = pet.defV or BattleBasicValueCalc.calcDef(info,star,pet.def,equipmentValue[Proto.PEET_DEF],YokeValues[3],equipmentValue[Proto.PEET_DEF_Per],
            YokeRates[3],stage,pet.level,skinValue[Proto.AT_DEF],scienceValue[Proto.AT_DEF])
        baseAttr["def"] = baseValue
    end

    if petType == 0 then
        setbuffInfo("def")  
        baseAttr["def"] = baseValue*buffPercent + buffValue
    end

    if pet.satk == nil then
        pet.satk = 0
        baseValue = pet.satkV or BattleBasicValueCalc.calcSpeAct(info,star,0,equipmentValue[Proto.PEET_SATK],YokeValues[4],equipmentValue[Proto.PEET_SATK_Per],
            YokeRates[4],stage,pet.level,skinValue[Proto.AT_SATK],scienceValue[Proto.AT_SATK])*pet.monster.amendmentSATK/1000
        baseAttr["satk"] = baseValue
    else
        baseValue = pet.satkV or BattleBasicValueCalc.calcSpeAct(info,star,pet.satk,equipmentValue[Proto.PEET_SATK],YokeValues[4],equipmentValue[Proto.PEET_SATK_Per],
            YokeRates[4],stage,pet.level,skinValue[Proto.AT_SATK],scienceValue[Proto.AT_SATK])
        baseAttr["satk"] = baseValue
        
    end

    if petType == 0 then
        setbuffInfo("satk") 
        baseAttr["satk"] = baseValue*buffPercent + buffValue
    end

    if pet.sdef == nil then
        pet.sdef = 0
        baseAttr["sdef"] = pet.sdefV or BattleBasicValueCalc.calcSpeDef(info,star,0,equipmentValue[Proto.PEET_SDEF],YokeValues[5],equipmentValue[Proto.PEET_SDEF_Per],
            YokeRates[5],stage,pet.level,skinValue[Proto.AT_SDEF],scienceValue[Proto.AT_SDEF])*pet.monster.amendmentSDEF/1000
        baseValue = baseAttr["sdef"]
    else
        -- baseAttr["sdef"] = BattleBasicValueCalc.calcSpeDef(info,star,pet.sdef,0,YokeValues[5],0,YokeRates[5],stage,pet.level)*buffPercent + buffValue
        baseValue = pet.sdefV or BattleBasicValueCalc.calcSpeDef(info,star,pet.sdef,equipmentValue[Proto.PEET_SDEF],
            YokeValues[5],equipmentValue[Proto.PEET_SDEF_Per],YokeRates[5],stage,pet.level,
            skinValue[Proto.AT_SDEF],scienceValue[Proto.AT_SDEF])
        baseAttr["sdef"] = baseValue
    end

    if petType == 0 then
        baseAttr["sdef"] = baseValue*buffPercent + buffValue
    end

    local getCSDamageRate = BattleBasicValueCalc.calcDamageRate(info, pet.atk, pet.satk,YokePercent[3]+equipmentValue[Proto.PEET_CRTHURT],scienceValue[Proto.AT_CRTHURT]) 
    local getDodge = BattleBasicValueCalc.calcDodge(info, pet.speed, YokePercent[6]+equipmentValue[Proto.PEET_EVD], 
        skinValue[Proto.AT_SPEED],scienceValue[Proto.AT_EVD])
    -- local getFC = baseAttr["hpmax"]/(3+3*pet.level/50) + baseAttr["atk"] + baseAttr["satk"] + baseAttr["def"] + baseAttr["sdef"] + baseAttr["speed"]
    local getFC = BattleBasicValueCalc.calcFC(pet.level,baseAttr["hpmax"],
            baseAttr["atk"],baseAttr["def"],baseAttr["satk"],baseAttr["sdef"],baseAttr["speed"])
    -- local getTenacity =  (info.lifeRateValue + info.sdefRateValue + info.defRateValue + hpx*2 + pet.sdef*2 + pet.def*2)/35
    local getTenacity =  BattleBasicValueCalc.calcTenacity(info, hpx, pet.sdef, pet.def)
    local healFix     =  BattleBasicValueCalc.calchealRate((YokePercent[10] or 0)+equipmentValue[Proto.PEET_HEALRATE],scienceValue[Proto.AT_HEALRATE])
    local sdefFix  =  BattleBasicValueCalc.calMDRexvalue((YokePercent[5] or 0) +equipmentValue[Proto.PEET_SDEFFIX],scienceValue[Proto.AT_DAMAGEREDUCE])
    local defFix   =  BattleBasicValueCalc.calPDRexvalue((YokePercent[4] or 0)+equipmentValue[Proto.PEET_DEFFIX],scienceValue[Proto.AT_ANTIHURT])
    
    if pet.monster ~= nil then
        petMon = pet.monster
    end

    local skills = {} 
--    pet.skills = {1,76,6,911} 
    if not pet.skills then
        pet.skills = {0,0,0,0}
    end
    
    for k1,v1 in pairs(pet.skills) do
        if v1 ~= 0 then
            local skillInfomation = clone(PokemonInfo.getPetSkillInfoById(v1))

            skills[k1] = {}

            if IS_SERVER_CODE == nil then
                local skillName = LuaSqlite.getLanguageByKey(skillInfomation.name)
				local skillPlay = clone(PokemonInfo.getSkillPlayById(v1))
                skills[k1].id      = v1
                skills[k1].selfAct = tonumber(skillPlay.myAction)
                skills[k1].emNtf   = tonumber(skillPlay.hisAction)
                skills[k1].res1    = skillPlay.readyAni
                skills[k1].res2    = skillPlay.fireAniBg
                skills[k1].res3    = skillPlay.fireAniTop
                skills[k1].res     = skillPlay.beAttackedAni
                skills[k1].partA   = skillPlay.aniPos
                skills[k1].partB   = skillPlay.firePointPos
                skills[k1].sound   = skillPlay.sound
                skills[k1].Bupdown = skillPlay.bgUD
                skills[k1].BLR     = skillPlay.bgLR
                skills[k1].icon    = skillPlay.typeIcon
                skills[k1].Aupdown = skillPlay.topUD
                skills[k1].ALR     = skillPlay.topLR
                skills[k1].triY    = skillPlay.firePointUD
                skills[k1].triX    = skillPlay.firePointLR
                skills[k1].beatSound = skillPlay.hitsound 
                skills[k1].name   = skillName
                skills[k1].scale  = skillPlay.scale
            end        
             
            skills[k1].info     = skillInfomation
            skills[k1].id       = skillInfomation.id
           
            
            if k1 == 1 then
                skills[k1].energy = 0
            else
                skills[k1].energy   = skillInfomation.energy
            end  
            if IS_SERVER_CODE == nil then
                table.insert(skillData[1],skills[k1]) 
            end
        else
            skills[k1] = 0
        end
    end

    if type(skills[4]) == "number" then
        angerMax = 4
    else
        angerMax = skills[4].energy
        if angerMax > 4 then
            angerMax = 4
        end
    end


    local petName = "" 

    if IS_SERVER_CODE == nil then
        -- petName = LuaSqlite.getLanguageByKey(info.name)
        if pet.name then
            petName =  pet.name
        else
            petName = PetEducationMgr.getPetName(pet)
        end
        
    end

    if pet.exp then
        experience = pet.exp
    end

    local starLimit = {0,0,1,3,5,5,5,5,5,5}

    if pet.paSkills ~= nil then
        for key,var in pairs(pet.paSkills) do
            if var.paSkillID ~= 0 then
                if key > 10 then
                    break
                end
                if star >= starLimit[key] then
                    local paskillInfo         = clone(PokemonInfo.getPetSkillInfoById(var.paSkillID))
                    if IS_SERVER_CODE == nil then
                        local skillName           = LuaSqlite.getLanguageByKey(paskillInfo.name)
                        paskillInfo.name          = skillName
                    end
                    paskillInfo.paSkillType   = var.paSkillType
                    petPaSkills[key]          = paskillInfo
                else
                    petPaSkills[key]          = 0
                end            
            else 
                petPaSkills[key]          = 0
            end
        end
    else
        petPaSkills = {0,0,0,0,0}
    end

    --增加技能优先级功能
    table.sort(petPaSkills, function(a, b)
        if type(a) == "table" and type(b) == "table" then  
            local speedA = tonumber(a.speed) or 99
            local speedB = tonumber(b.speed) or 99
            -- print("petType,speedA,speedB,",petType,speedA,speedB)
            return speedA < speedB
        else
            return false
        end 
    end)
 
    local penetration  = BattleBasicValueCalc.calcPhysicalPenetration((YokePercent[7] or 0) + equipmentValue[Proto.PEET_PENETRATION],scienceValue[Proto.AT_PENETRATION])
    local spenetration = BattleBasicValueCalc.calcMagicPenetration((YokePercent[8] or 0) + equipmentValue[Proto.PEET_SPENETRATION],scienceValue[Proto.AT_SPENETRATION])
    local petTbl = {
        infomation = pet,
        blood = baseAttr["hp"], 
        bloodLimit = baseAttr["hpmax"],
        damage = 0,
        level = pet.level,
        starValue = star,
        stageValue= stage,
        monster = petMon,
        res = resStr,
        name = petName,
        attri1 = info.elementAtt1,
        attri2 = info.elementAtt2,
        rarePoint = info.rarePoint,
        skill = skills,
        icon = {"Battle/bloodHead/"..info.icon..".png","Battle/skillHead/"..pet.pokeID..".png","Battle/cardHead/"..pet.pokeID..".png","Battle/ys_shui.png"},
        iconID = info.icon,
        pokeID = pet.pokeID,
        CSdamageRate = getCSDamageRate,
        Critical = BattleBasicValueCalc.calcCritical((YokePercent[2] or 0) + equipmentValue[Proto.PEET_CRT] , scienceValue[Proto.AT_CRT]), 
        HitRate = BattleBasicValueCalc.calcHitRate((YokePercent[1] or 0) + equipmentValue[Proto.PEET_RATE] , scienceValue[Proto.AT_RATE]),
        penetration  = penetration,
        spenetration = spenetration,
        Dodge   = getDodge,
        Tenacity = getTenacity,
        CritResistance = 0,
        AoyiSpd = 350,
        healRate = 1,
        tag = petTag,
        anger = petAnger,
        angerMax = angerMax,
        atk = baseAttr["atk"],
        satk = baseAttr["satk"],
        def = baseAttr["def"],
        sdef = baseAttr["sdef"], 
        speed = baseAttr["speed"],
        damageRate = 1.0,
        buffer = {},
        paSkills = petPaSkills,
        objID = baseAttr["objID"],
        exp  = experience,
        skin = pet.skin,
        healFix = healFix,
        sdefFix = sdefFix,
        defFix = defFix
    }
    local readPetTbl = {
--        basecriticallv = 0,
--        baseHitRatelv = 0,
--        baseatklv = 0,
--        basesatklv = 0,
--        basedeflv = 0, 
--        basesdeflv = 0,
--        basespdlv = 0, 
        baseCSdamageRate = CSdamageRate,
        baseTenacity    = getTenacity,
        baseatk         = baseAttr["atk"],
        basesatk        = baseAttr["satk"],
        basedef         = baseAttr["def"],
        basesdef        = baseAttr["sdef"], 
        basespeed       = baseAttr["speed"],
        baseDodge       = getDodge,
        baseHitRate     = 0,
        baseAoyiSpd     = 350,
        baseAoyiLim     = 1000,
        basehealRate    = 1,
        FC              = getFC,
    }
    local lastPetTbl = {}
    if IS_SERVER_CODE == nil then
        local function table_partOfread(writeTbl,readTbl)
                local temp= writeTbl
                local mt = {
                __index = readTbl,
                __newindex = function(t, k, v)
                        DialogBoxMgr.showSmallDialogBox(BattleMapMgr.getBattleScene(), 1, "发生错误：修改了战斗基础数据，请重新登陆.", function()
                            end,function()end)
                        BattleMapMgr.getBattleScene():performWithDelay(function()
                            LoginViewMgr.gameReInit()
                            --GameInit.Init(true)
                            --SceneMgr.replaceScene(SceneMgr.getRunningScene, "LoginScene")
                        end,2.0)      
                    end
                }
            setmetatable(temp, mt) 
            return temp 
        end

        lastPetTbl = table_partOfread(petTbl,readPetTbl)
    else
        for key,var in pairs(readPetTbl) do
            petTbl[key] = var
        end
        lastPetTbl = petTbl
    end

    petTag = petTag +1
    return lastPetTbl
end

function BattleGetPetInfo.new(myPets,enemyPets,scene)
    if IS_SERVER_CODE == nil then
        skillData[0] = {}
        skillData[1] = {}
    end
    
    petTag = 1

    local scienceData_A  = clone(ScienceInfo.getScienceAttrsTable())
    local scienceData_B  = {}
    local scieMaxLevel   = nil
    local petInfo = {}
    local petID = 1
    local FirstPet = -1
    local scienceLimitDat   = SystemInfo.getGlobalConfigAddInfoByID(61005)

    if scienceLimitDat then
        scieMaxLevel = scienceLimitDat.values[1]
    end 

    petInfo[MYPETS]     = {}
    petInfo[MYPETS][OUTPETS]   = {}
    petInfo[MYPETS][INPETS]     = {}

    petInfo[HISPETS]  = {}
    petInfo[HISPETS][OUTPETS]   = {}
    petInfo[HISPETS][INPETS]     = {} 

    scienceData_B = BattlePVPMgr.getScienceDataB() or {}
    for key,var in pairs(enemyPets[OUTPETS]) do
        if var["hp"] ~= nil then
            if var["hp"] > 0 then
                FirstPet = key
                break
            else
                FirstPet = 1
            end
        else
            FirstPet = 1
        end
        petID = petID + 1
        if petID > 3 then
            break
        end
    end
    petID = 1
    for k,v in pairs(enemyPets[OUTPETS]) do
        if v["skills"] == nil then
            return
        end
        local science = {}
        if scieMaxLevel and v.level >= scieMaxLevel then
            science = scienceData_B
        end
        if scienceData_B.addToBattle then
            enemyPets[OUTPETS][k].hpmax = enemyPets[OUTPETS][k].hpmax + (science[Proto.AT_HP] or 0)
        end
        if k == FirstPet then
            local pet = BattleGetPetInfo.createPet(v,1,science)
            table.insert(petInfo[HISPETS][OUTPETS],1,pet)
        else
            local pet = BattleGetPetInfo.createPet(v,1,science)
            table.insert(petInfo[HISPETS][OUTPETS],pet)
            
        end
        petID = petID + 1
        if petID > 3 then
            break
        end
        
    end
    petID = 1
    for k,v in pairs(enemyPets[INPETS]) do
        local pet = BattleGetPetInfo.createPet(v,1,scienceData_B)
        table.insert(petInfo[HISPETS][INPETS],pet)
        petID = petID + 1
        if petID > 3 then
            break
        end
        
    end
    FirstPet = -1
    
    petID = 1
    
    for key,var in pairs(myPets[OUTPETS]) do
        if var["hp"] ~= nil then
            if var["hp"] > 0 then
                FirstPet = key
                break
            else
                FirstPet = 1
            end
        else
            FirstPet = 1
        end
        petID = petID + 1
        if petID > 3 then
            break
        end
    end
    petID = 1
    for k,v in pairs(myPets[OUTPETS]) do
        if v["skills"] == nil then
            return
        end
        local science = {}
        if scieMaxLevel and v.level >= scieMaxLevel then
            science = scienceData_A
        end
        if BattlePVPMgr.mIsPVPBattle or scienceData_B.addToBattle then
            myPets[OUTPETS][k].hpmax = myPets[OUTPETS][k].hpmax + (science[Proto.AT_HP] or 0)
        end
        if k == FirstPet then
            local pet = BattleGetPetInfo.createPet(v,0,science)
            table.insert(petInfo[MYPETS][OUTPETS],1,pet)
        else
            local pet = BattleGetPetInfo.createPet(v,0,science)
            table.insert(petInfo[MYPETS][OUTPETS],pet)
            
        end
        petID = petID + 1
        if petID > 3 then
            break
        end
  
    end
    petID = 1
    for k,v in pairs(myPets[INPETS]) do
        local pet = BattleGetPetInfo.createPet(v,0,scienceData_A)
        table.insert(petInfo[MYPETS][INPETS],pet)
        petID = petID + 1
        if petID > 3 then
            break
        end
        
    end

    BattleMapMgr.cleanTemporaryBuffer()

    return petInfo
end

function BattleGetPetInfo.setPetTag(value)
    petTag = value
end

function BattleGetPetInfo.getSkillData()
    return skillData
end

function BattleGetPetInfo.getCircleHeadRes(iconID)
    local headres = "Battle/bloodHead/"..iconID..".png"
    local fileExist = cc.FileUtils:getInstance():isFileExist(headres)
    if fileExist then
        return headres
    else
        return "Battle/bloodHead/1.png" 
    end
end

function BattleGetPetInfo.getSkillRes(iconID)
    local skillres = "Battle/skillIcon/"..iconID..".png"
    local fileExist = cc.FileUtils:getInstance():isFileExist(skillres)

    if fileExist then
        return skillres
    else
        return "Battle/skillIcon/default.png"
    end
end

return BattleGetPetInfo