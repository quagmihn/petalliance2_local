function PetEducationMgr.calPetAttrs(pokemonInfo, petInfo, yokeValues, yokeRates, petLevel, petStage, calScience)
    local equipmentValue    = PetEquipmentMgr.calcAllAttr(petInfo)
    local skinValue = PetEducationMgr.getDiversAttrsTable(petInfo)
    local scienceValue = {}
    if calScience==nil or calScience==true then
    	scienceValue = ScienceInfo.getScienceAttrsTable()
    end
    
    local hpx = petInfo.hpx == nil and 0 or petInfo.hpx
    local atk = petInfo.atk == nil and 0 or petInfo.atk
    local satk = petInfo.satk == nil and 0 or petInfo.satk
    local speed = petInfo.speed == nil and 0 or petInfo.speed
    local sdef = petInfo.sdef == nil and 0 or petInfo.sdef
    local def = petInfo.def == nil and 0 or petInfo.def
    local level = petLevel or petInfo.level
    local stage = petStage or petInfo.Stage
    if level<ScienceInfo.getPetAttrLockLevel() then
    	scienceValue = {}
    end
    
    local petAttrs = {
        BattleBasicValueCalc.calcHp    (pokemonInfo,petInfo.star,hpx,equipmentValue[Proto.PEET_HP],yokeValues[1],
            equipmentValue[Proto.PEET_HP_Per],yokeRates[1],stage,level,skinValue[Proto.AT_HP],
            scienceValue[Proto.AT_HP]),
        BattleBasicValueCalc.calcAct   (pokemonInfo,petInfo.star,atk,equipmentValue[Proto.PEET_ATK],yokeValues[2],
            equipmentValue[Proto.PEET_ATK_Per],yokeRates[2],stage,level,skinValue[Proto.AT_ATK],
            scienceValue[Proto.AT_ATK]),
        BattleBasicValueCalc.calcDef   (pokemonInfo,petInfo.star,def,equipmentValue[Proto.PEET_DEF],yokeValues[3],
            equipmentValue[Proto.PEET_DEF_Per],yokeRates[3],stage,level,skinValue[Proto.AT_DEF],
            scienceValue[Proto.AT_DEF]),
        BattleBasicValueCalc.calcSpeAct(pokemonInfo,petInfo.star,satk,equipmentValue[Proto.PEET_SATK],yokeValues[4],
            equipmentValue[Proto.PEET_SATK_Per],yokeRates[4],stage,level,skinValue[Proto.AT_SATK],
            scienceValue[Proto.AT_SATK]),
        BattleBasicValueCalc.calcSpeDef(pokemonInfo,petInfo.star,sdef,equipmentValue[Proto.PEET_SDEF],yokeValues[5],
            equipmentValue[Proto.PEET_SDEF_Per],yokeRates[5],stage,level,skinValue[Proto.AT_SDEF],
            scienceValue[Proto.AT_SDEF]),
        BattleBasicValueCalc.calcSpeed (pokemonInfo,petInfo.star,speed,equipmentValue[Proto.PEET_SPEED],yokeValues[6],
            equipmentValue[Proto.PEET_SPEED_Per],yokeRates[6],stage,level,skinValue[Proto.AT_SPEED],
            scienceValue[Proto.AT_SPEED]),
    }
    return petAttrs
end

function PetEducationMgr.calPetAttrsEx(petAttrs, pokemonInfo, petInfo, yokePercent)
    local equipmentValue    = PetEquipmentMgr.calcAllAttr(petInfo)
    local skinValue = PetEducationMgr.getDiversAttrsTable(petInfo)
    local scienceValue = ScienceInfo.getScienceAttrsTable()
    local level = petInfo.level or 1
    if level<ScienceInfo.getPetAttrLockLevel() then
        scienceValue = {}
    end
    
    local attBase = {}
    attBase[Proto.AT_HP]    = petAttrs[1]
    attBase[Proto.AT_ATK]   = petAttrs[2]
    attBase[Proto.AT_SATK]  = petAttrs[3]
    attBase[Proto.AT_DEF]   = petAttrs[4]
    attBase[Proto.AT_SDEF]  = petAttrs[5]
    attBase[Proto.AT_SPEED] = petAttrs[6]
    
    local extraAttr = PetEducationMgr.getExtraAttrsTable(AchievementInfo.getPotentialInfoCount(), attBase)
    local attPotentialValue = {
        extraAttr[Proto.AT_HP],
        extraAttr[Proto.AT_ATK],
        extraAttr[Proto.AT_SATK],
        extraAttr[Proto.AT_DEF],
        extraAttr[Proto.AT_SDEF],
        extraAttr[Proto.AT_SPEED],
        extraAttr[Proto.AT_RATE],
        extraAttr[Proto.AT_CRT],
        extraAttr[Proto.AT_CRTHURT],
        extraAttr[Proto.AT_DAMAGEREDUCE],
        extraAttr[Proto.AT_ANTIHURT],
        extraAttr[Proto.AT_EVD],
        extraAttr[Proto.AT_PENETRATION] or 0,
        extraAttr[Proto.AT_SPENETRATION] or 0,
        extraAttr[Proto.AT_ANTICRT] or 0,
        extraAttr[Proto.AT_HEALRATE] or 0,
    }
    
	local fullAttrs = {
        petAttrs[1],petAttrs[2],petAttrs[3],petAttrs[4],petAttrs[5],petAttrs[6],
        BattleBasicValueCalc.calcHitRate(yokePercent[1]+equipmentValue[Proto.PEET_RATE],scienceValue[Proto.AT_RATE]),--命中
        BattleBasicValueCalc.calcCritical(yokePercent[2]+equipmentValue[Proto.PEET_CRT],scienceValue[Proto.AT_CRT]),--暴击率
        BattleBasicValueCalc.calcDamageRate (pokemonInfo,petAttrs[2],petAttrs[3], 
            yokePercent[3]+equipmentValue[Proto.PEET_CRTHURT],scienceValue[Proto.AT_CRTHURT]),--暴击倍率
        math.floor(BattleBasicValueCalc.calcPhysicalDamageReduction(petAttrs[4]+attPotentialValue[4], 
            petInfo.level,yokePercent[4]+equipmentValue[Proto.PEET_DAMAGEREDUCE]/100.00,scienceValue[Proto.AT_DAMAGEREDUCE])*100),
        math.floor(BattleBasicValueCalc.calcMagicDamageReduction(petAttrs[5]+attPotentialValue[5], 
            petInfo.level,yokePercent[5]+equipmentValue[Proto.PEET_ANTIHURT]/100.00,scienceValue[Proto.AT_ANTIHURT])*100),
        BattleBasicValueCalc.calcDodge(pokemonInfo,petInfo.speed,yokePercent[6]+equipmentValue[Proto.PEET_EVD], 
            skinValue[Proto.AT_SPEED],scienceValue[Proto.AT_EVD]),
        BattleBasicValueCalc.calcPhysicalPenetration(yokePercent[7]+equipmentValue[Proto.PEET_PENETRATION],
            scienceValue[Proto.AT_PENETRATION]),--物理穿透
        BattleBasicValueCalc.calcMagicPenetration(yokePercent[8]+equipmentValue[Proto.PEET_SPENETRATION],
            scienceValue[Proto.AT_SPENETRATION]),--魔法穿透
        BattleBasicValueCalc.calcResistance(yokePercent[9]+equipmentValue[Proto.PEET_ANTICRT],
            scienceValue[Proto.AT_ANTICRT]),--暴击抵抗
        BattleBasicValueCalc.calchealRate(yokePercent[10]+equipmentValue[Proto.PEET_HEALRATE], 
            scienceValue[Proto.AT_HEALRATE])/10,--治疗比率
    }
    return fullAttrs, attPotentialValue
end

function PetEducationMgr.calPetAttrsFull(petAttrs, pokemonInfo, petInfo, yokePercent)
    local fullAttrs, attPotentialValue = PetEducationMgr.calPetAttrsEx(petAttrs, pokemonInfo, petInfo, yokePercent)
    return {fullAttrs[1], fullAttrs[2], fullAttrs[3], fullAttrs[4], fullAttrs[5], fullAttrs[6], nil, nil, nil, nil,
        fullAttrs[7], fullAttrs[8], fullAttrs[9], fullAttrs[10], fullAttrs[11], fullAttrs[12], 
        fullAttrs[13], fullAttrs[14], fullAttrs[15], fullAttrs[16]},
        {attPotentialValue[1], attPotentialValue[2], attPotentialValue[3], attPotentialValue[4], attPotentialValue[5], 
        attPotentialValue[6], nil, nil, nil, nil, attPotentialValue[7], attPotentialValue[8], attPotentialValue[9],
        attPotentialValue[10], attPotentialValue[11], attPotentialValue[12], 
        attPotentialValue[13], attPotentialValue[14], attPotentialValue[15], attPotentialValue[16]}
end

function PetEducationMgr.calPetFC(pokemonInfo, petInfo, yokeValues, yokeRates)
    local petAttrs = PetEducationMgr.calPetAttrs(pokemonInfo, petInfo, yokeValues, yokeRates, nil, nil, false)
    --计算战斗力
    local fc = BattleBasicValueCalc.calcFC(petInfo.level,petAttrs[1],petAttrs[2],petAttrs[3],petAttrs[4],petAttrs[5],petAttrs[6])
    local fcS = ScienceInfo.getScienceFightPower(petInfo.level)
    return fc+fcS
end

function PetEducationMgr.sortPetAttrsForDrawing(pokemonInfo, petInfo, yokeValues, yokeRates, petLevel, petStage, calScience)
    local vec = PetEducationMgr.calPetAttrs(pokemonInfo, petInfo, yokeValues, yokeRates, petLevel, petStage, calScience)
    --1hp 2atk 3def 4satk 5sdef 6speed 
    local petAttrs = {vec[1], vec[2], vec[4], vec[6], vec[5], vec[3]}
    return petAttrs
end

function PetEducationMgr.sortPetAttrsForCommon(pokemonInfo, petInfo, yokeValues, yokeRates, petLevel, petStage, calScience)
    local vec = PetEducationMgr.calPetAttrs(pokemonInfo, petInfo, yokeValues, yokeRates, petLevel, petStage, calScience)
    --1hp 2atk 3def 4satk 5sdef 6speed 
    local petAttrs = {vec[1], vec[2], vec[4], vec[3], vec[5], vec[6]}
    return petAttrs
end

function PetEducationMgr.getFashionAttrsTable(FashionSkills, attBase)
    --
    local attFashionType = {}
    attFashionType[Proto.AT_HP] = Proto.AT_HP
    attFashionType[Proto.AT_ATK] = Proto.AT_ATK
    attFashionType[Proto.AT_SATK] = Proto.AT_SATK
    attFashionType[Proto.AT_DEF] = Proto.AT_DEF
    attFashionType[Proto.AT_SDEF] = Proto.AT_SDEF
    attFashionType[Proto.AT_SPEED] = Proto.AT_SPEED
    attFashionType[Proto.AT_RATE] = Proto.AT_RATE
    attFashionType[Proto.AT_CRT] = Proto.AT_CRT
    attFashionType[Proto.AT_CRTHURT] = Proto.AT_CRTHURT
    attFashionType[Proto.AT_DAMAGEREDUCE] = Proto.AT_DAMAGEREDUCE
    attFashionType[Proto.AT_ANTIHURT] = Proto.AT_ANTIHURT
    attFashionType[Proto.AT_EVD] = Proto.AT_EVD

    local attFashionValue = {}
    for i=1,Proto.AT_ANTIHURT do
        attFashionValue[i] = 0
    end

    for key,var in pairs(FashionSkills) do
        local attTable = BattleInfo.getSkillAttributeByID(var)
        for j=1,#attTable do
            if attFashionType[attTable[j].type] then
                if attTable[j].ctype == 1 then
                    attFashionValue[attFashionType[attTable[j].type]] = attFashionValue[attFashionType[attTable[j].type]] 
                        + math.floor(attBase[attTable[j].type]*attTable[j].value/100)
                else
                    attFashionValue[attFashionType[attTable[j].type]] = attFashionValue[attFashionType[attTable[j].type]] 
                        + attTable[j].value
                end
            end
        end
    end
    return attFashionValue
end

function PetEducationMgr.getExtraAttrsTable(finishSkillCnt, attBase)
    --
    local attPotentialType = {}
    attPotentialType[Proto.AT_HP] = Proto.AT_HP
    attPotentialType[Proto.AT_ATK] = Proto.AT_ATK
    attPotentialType[Proto.AT_SATK] = Proto.AT_SATK
    attPotentialType[Proto.AT_DEF] = Proto.AT_DEF
    attPotentialType[Proto.AT_SDEF] = Proto.AT_SDEF
    attPotentialType[Proto.AT_SPEED] = Proto.AT_SPEED
    attPotentialType[Proto.AT_RATE] = Proto.AT_RATE
    attPotentialType[Proto.AT_CRT] = Proto.AT_CRT
    attPotentialType[Proto.AT_CRTHURT] = Proto.AT_CRTHURT
    attPotentialType[Proto.AT_DAMAGEREDUCE] = Proto.AT_DAMAGEREDUCE
    attPotentialType[Proto.AT_ANTIHURT] = Proto.AT_ANTIHURT
    attPotentialType[Proto.AT_EVD] = Proto.AT_EVD

    local attPotentialValue = {}
    for i=1,Proto.AT_ANTIHURT do
        attPotentialValue[i] = 0
    end

    local potentialEffect = {}

    for i=1,finishSkillCnt do
        local id = require("src.DatReader.PotentialInfoConfig").getEntryID(i)
        if AchievementListMgr.isFinishSkill(id) then
            local potentialInfo = AchievementInfo.getPotentialInfoById(id)
            local effect = potentialInfo.effect
            potentialEffect[effect] = id
        end
    end

    for key,var in pairs(potentialEffect) do
        local skillInfo = BattleInfo.getPotentialSkillInfoById(var)
        if skillInfo and skillInfo.type == Proto.PST_PASSIVE then
            local attTable = BattleInfo.getSkillAttributeByID(skillInfo.skillID)
            for j=1,#attTable do
                if attPotentialType[attTable[j].type] then
                    attPotentialValue[attPotentialType[attTable[j].type]] = attPotentialValue[attPotentialType[attTable[j].type]] 
                        + attTable[j].value
                end
            end
        end
    end

    local fashionAttr = PetEducationMgr.getFashionAttrsTable(AvatarViewMgr.getFashionSkills(), attBase)
    local attrValue = {}
    for i=1,Proto.AT_ANTIHURT do
        attrValue[i] = attPotentialValue[i] + fashionAttr[i]
    end
    return attrValue
end

function PetEducationMgr.getDiversAttrsTable(petInfo)
    local attrType, attrValue = PetEducationMgr.getDiversificationAttrs(petInfo)
    local attrsTable = {}
    attrsTable[Proto.AT_HP]             = 0
    attrsTable[Proto.AT_ATK]            = 0
    attrsTable[Proto.AT_SATK]           = 0
    attrsTable[Proto.AT_DEF]            = 0
    attrsTable[Proto.AT_SDEF]           = 0
    attrsTable[Proto.AT_SPEED]          = 0
    attrsTable[Proto.AT_RATE]           = 0
    attrsTable[Proto.AT_CRT]            = 0
    attrsTable[Proto.AT_CRTHURT]        = 0
    attrsTable[Proto.AT_DAMAGEREDUCE]   = 0
    attrsTable[Proto.AT_ANTIHURT]       = 0
    attrsTable[Proto.AT_EVD]            = 0

    attrsTable[attrType] = attrValue
    return attrsTable
end

--画六维图时需要的属性数据（PetInfo.level = 1）
function PetEducationMgr.getSixDimensionsDrawAttrs(petInfo, pokemonInfo, petLevel)
    local pokemonInfo = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
    local yokeParam = PetEducationMgr.getYokeParamsTable(petInfo)
    local values = yokeParam.values
    local rates  = yokeParam.rates

    -- local extraAttr = PetEducationMgr.getExtraAttrsTable(finishSkillCnt)
    -- values[1] = values[1] + extraAttr[1]--extraAttr[Proto.AT_HP]
    -- values[2] = values[2] + extraAttr[2]--extraAttr[Proto.AT_ATK]
    -- values[3] = values[3] + extraAttr[3]--extraAttr[Proto.AT_SATK]
    -- values[4] = values[4] + extraAttr[6]--extraAttr[Proto.AT_SPEED]
    -- values[5] = values[5] + extraAttr[5]--extraAttr[Proto.AT_SDEF]
    -- values[6] = values[6] + extraAttr[4]--extraAttr[Proto.AT_DEF]
    return PetEducationMgr.sortPetAttrsForDrawing(pokemonInfo, petInfo, values, rates, petLevel)
end