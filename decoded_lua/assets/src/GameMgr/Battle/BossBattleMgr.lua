local BossBattleMgr = {}

BossBattleMgr.instance = nil

BossBattleMgr.hit = 100
BossBattleMgr.critical = 0

BossBattleMgr.baserare = 0.85
BossBattleMgr.rare = {0, 0.02, 0.04, 0.06, 0.08,0.1}

BossBattleMgr.restraintValue = 0.5
BossBattleMgr.restraint = 0
BossBattleMgr.restraintlimit = 10

BossBattleMgr.bossPokeID = 0

BossBattleMgr.bossSkill = {}

function BossBattleMgr.start(bossID)

    BossBattleMgr.restraint = 0

    local bossInfo = WorldBossInfo.getWorldBossInfoByID(bossID)
    BossBattleMgr.bossPokeID = bossInfo.model

    BossBattleMgr.instance = require("src.GameMgr.Battle.boss."..bossInfo.skill)
    BossBattleMgr.instance.AI()

end

function BossBattleMgr.stop()

    BossBattleMgr.instance.stop()
    BossBattleMgr.bossSkill = {}

end

function BossBattleMgr.clearRestraint()

    BossBattleMgr.restraint = 0

end

function BossBattleMgr.createBossEffect()

    local tab = clone(BossMapMgr.getWalkableGridIndex())
    table.insert(tab, BossMapMgr.getPlayerOwnerBornGridIndex()[1])
    local nodes = BossMapMgr.getMapNodeByGridIndex(tab)

    for i=1,#BossBattleMgr.instance.anim do
        if BossBattleMgr.instance.anim[i].grid then
            for j=1,#nodes do
                BattleUIMgr.addBossEffect(BossBattleMgr.instance.anim[i], nodes[j])
            end
        else
            BattleUIMgr.addBossEffect(BossBattleMgr.instance.anim[i], BossMapMgr.getBossNode())
        end
    end

    local rootNode = BossMapMgr.getMapRootNode()
    BattleUIMgr.addBossSceneEffect("Gaf/bossEffect/fengwei_qian.gaf", BossMapMgr.getBossNode(), cc.p(40,40))
    BattleUIMgr.addBossSceneEffect("Gaf/bossEffect/fengwei_hou.gaf", BossMapMgr.getBossNode(), cc.p(-50,-30), -1)
    BattleUIMgr.addBossSceneEffect("Gaf/bossEffect/BossEffectScene.gaf", rootNode, cc.p(100,200))

end

function BossBattleMgr.getPetSkinAttrs(pokeID, skin)

    if skin == 0 then
        return 0
    end
    local pokeInfo = PokemonInfo.getPokemonInfoByID(pokeID)
    if pokeInfo.skins[skin] ~= nil then
        return pokeInfo.skins[skin]
    end
    return 0

end

function BossBattleMgr.getDiversificationAttrs(petInfo)

    local attrTable = BossBattleMgr.getPetSkinAttrs(petInfo.pokeID, petInfo.skin)
    if attrTable ~= 0 then
        return attrTable.attribType, attrTable.attribValue
    end
    return 0, 0

end

function BossBattleMgr.getDiversAttrsTable(petInfo)

    local attrType, attrValue = BossBattleMgr.getDiversificationAttrs(petInfo)
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

function BossBattleMgr.getYokeParamsTable(info)

    local values  = {0,0,0,0,0,0,}
    local rates   = {0,0,0,0,0,0,}
    local yokePer = {0,0,0,0,0,0,}
    
    local valueTable = {1,2,3,4,5,6}
    local ratesTable = {12,13,14,15,16,17}
    local percentTable = {8,9,11,12,13,8}
    if info.yoke and info.yoke.yokeValues then
        local value = info.yoke.yokeValues
        for i = 1, #valueTable do
            values[i] = value[valueTable[i]]
        end
        for i = 1, #ratesTable do
            rates[i] = 0
        end
        for i = 1, #percentTable do
            yokePer[i] = value[percentTable[i]]
        end
    end
    return {values=values,rates=rates,yokePer=yokePer}

end

function BossBattleMgr.getPetFC(pokemonInfo, petInfo)

    local yokeParam = BossBattleMgr.getYokeParamsTable(petInfo)
    local yokeValues = yokeParam.values
    local yokeRates  = yokeParam.rates

    local skinValue = BossBattleMgr.getDiversAttrsTable(petInfo)
    local petAttrs = {
        BattleBasicValueCalc.calcHp    (pokemonInfo,petInfo.star,petInfo.hpx,  0,yokeValues[1],0,yokeRates[1],petInfo.Stage,petInfo.level,skinValue[Proto.AT_HP]),
        BattleBasicValueCalc.calcAct   (pokemonInfo,petInfo.star,petInfo.atk,  0,yokeValues[2],0,yokeRates[2],petInfo.Stage,petInfo.level,skinValue[Proto.AT_ATK]),
        BattleBasicValueCalc.calcDef   (pokemonInfo,petInfo.star,petInfo.def,  0,yokeValues[3],0,yokeRates[3],petInfo.Stage,petInfo.level,skinValue[Proto.AT_DEF]),
        BattleBasicValueCalc.calcSpeAct(pokemonInfo,petInfo.star,petInfo.satk, 0,yokeValues[4],0,yokeRates[4],petInfo.Stage,petInfo.level,skinValue[Proto.AT_SATK]),
        BattleBasicValueCalc.calcSpeDef(pokemonInfo,petInfo.star,petInfo.sdef, 0,yokeValues[5],0,yokeRates[5],petInfo.Stage,petInfo.level,skinValue[Proto.AT_SDEF]),
        BattleBasicValueCalc.calcSpeed (pokemonInfo,petInfo.star,petInfo.speed,0,yokeValues[6],0,yokeRates[6],petInfo.Stage,petInfo.level,skinValue[Proto.AT_SPEED]),
    }
    local fc = BattleBasicValueCalc.calcFC(petInfo.level,petAttrs[1],petAttrs[2],petAttrs[3],petAttrs[4],petAttrs[5],petAttrs[6])
    return fc

end

function BossBattleMgr.getRestraint(petID)
    
    local petInfo = PokemonInfo.getPetInfoByObjID(petID)

    local pokeID = petInfo.pokeID
    local pokemonInfo = PokemonInfo.getPokemonInfoByID(pokeID)

    local petAttFirst = pokemonInfo.elementAtt1
    local petAttSceond = pokemonInfo.elementAtt2

    local bossPokemonInfo = PokemonInfo.getPokemonInfoByID(BossBattleMgr.bossPokeID)
    local bossAttFirst = bossPokemonInfo.elementAtt1
    local bossAttSceond = bossPokemonInfo.elementAtt2

    local element1 = ELEMENT_GRAMS[petAttFirst][bossAttFirst] * ELEMENT_GRAMS[petAttFirst][bossAttSceond]
    local element2 = ELEMENT_GRAMS[petAttSceond][bossAttFirst] * ELEMENT_GRAMS[petAttSceond][bossAttSceond]
    local element = element1*element2

    local state = 1
    if element > 1.05 then
        state = 2
    elseif element < 1 then
        state = 3
    end

    return state

end

function BossBattleMgr.fight(petID)

    local petInfo = PokemonInfo.getPetInfoByObjID(petID)

    local pokeID = petInfo.pokeID
    local pokemonInfo = PokemonInfo.getPokemonInfoByID(pokeID)

    local fightValue = BossBattleMgr.getPetFC(pokemonInfo, petInfo)

    local rarePoint = pokemonInfo.rarePoint
    local rareStart = (BossBattleMgr.baserare + BossBattleMgr.rare[rarePoint])*100
    local rareEnd = 100
    local rare = GetRandom.random(rareStart,rareEnd)

    local petAttFirst = pokemonInfo.elementAtt1
    local petAttSceond = pokemonInfo.elementAtt2

    local bossPokemonInfo = PokemonInfo.getPokemonInfoByID(BossBattleMgr.bossPokeID)
    local bossAttFirst = bossPokemonInfo.elementAtt1
    local bossAttSceond = bossPokemonInfo.elementAtt2

    local element1 = ELEMENT_GRAMS[petAttFirst][bossAttFirst] * ELEMENT_GRAMS[petAttFirst][bossAttSceond]
    local element2 = ELEMENT_GRAMS[petAttSceond][bossAttFirst] * ELEMENT_GRAMS[petAttSceond][bossAttSceond]
    local element = element1*element2

    local state = 1
    if element > 1.05 then
        if BossBattleMgr.restraint < BossBattleMgr.restraintlimit then
            BossBattleMgr.restraint = BossBattleMgr.restraint + 1
        end
        state = 2
    else
        BossBattleMgr.restraint = 0
        if element < 1 then
            state = 3
        end
    end

    local damage = math.floor(fightValue*(1+BossBattleMgr.restraintValue*BossBattleMgr.restraint)*rare/100)

    return damage, state, BossBattleMgr.restraint

end

function BossBattleMgr.getRestraintForServer(pokeID, bossID)

    local pokemonInfo = PokemonInfo.getPokemonInfoByID(pokeID)

    local petAttFirst = pokemonInfo.elementAtt1
    local petAttSceond = pokemonInfo.elementAtt2

    local bossInfo = WorldBossInfo.getWorldBossInfoByID(bossID)
    local bossPokeID = bossInfo.model

    local bossPokemonInfo = PokemonInfo.getPokemonInfoByID(bossPokeID)
    local bossAttFirst = bossPokemonInfo.elementAtt1
    local bossAttSceond = bossPokemonInfo.elementAtt2

    local element1 = ELEMENT_GRAMS[petAttFirst][bossAttFirst] * ELEMENT_GRAMS[petAttFirst][bossAttSceond]
    local element2 = ELEMENT_GRAMS[petAttSceond][bossAttFirst] * ELEMENT_GRAMS[petAttSceond][bossAttSceond]
    local element = element1*element2

    if element > 1.05 then
        return true
    else
        return false
    end

end

function BossBattleMgr.fightForServer(petInfo, restraint, multiple)

    local pokeID = petInfo.pokeID
    local pokemonInfo = PokemonInfo.getPokemonInfoByID(pokeID)

    local fightValue = BossBattleMgr.getPetFC(pokemonInfo, petInfo)

    local rarePoint = pokemonInfo.rarePoint
    local rareStart = (BossBattleMgr.baserare + BossBattleMgr.rare[rarePoint])*100
    local rareEnd = 100
    local rare = GetRandom.random(rareStart,rareEnd)

    if restraint > BossBattleMgr.restraintlimit then
        restraint = BossBattleMgr.restraintlimit
    end
    local damage = math.floor(fightValue*(1+BossBattleMgr.restraintValue*restraint)*rare/100)
    if multiple then
        damage = damage*multiple
    end

    return damage

end

function BossBattleMgr.addBossSkill(skill)

    table.insert(BossBattleMgr.bossSkill, skill)

    if #BossBattleMgr.bossSkill == 1 then
        BossBattleMgr.playBossSkill()
    end
    
end

function BossBattleMgr.playGridEffect(tab,damage)
    
    local node = BossMapMgr.getAllPlayerNodeByGridIndex(tab)
    local myNode = BossMapMgr.getPlayerOwnerNode()
    for i=1,#node do
        if node[i] == myNode and not BossMapMgr.isPlayerOwnerBallsEmpty() 
            and not BossMapMgr.isPlayerOwnerInSecurityRegion(BossMapMgr.getPlayerOwnerBornGridIndex()) 
            and not BossMapMgr.isPlayerOwnerPowerOverwhelming() then
            WorldBossInfo.BossAttack(damage, function()
                BattleUIMgr.showBossAttackDamage(node[i],damage)
            end)
        elseif node[i] ~= myNode then
            BossMapMgr.takeDamage(node[i])
            BattleUIMgr.showBossAttackDamage(node[i],damage)
        end
    end

end

function BossBattleMgr.playBossSkill()
    BossBattleMgr.bossAni = false
    if #BossBattleMgr.bossSkill > 0 then
        local skill = BossBattleMgr.bossSkill[1]
        BossBattleMgr.shake = true
        if skill.tabRandom and skill.warningTime and skill.damage and skill.motion then
            BossMapMgr.showWarningByGridIndex(skill.tabRandom, skill.warningTime, function()
                if skill.anim then
                    if skill.anim.grid then
                        local tab = clone(skill.tabRandom)
                        local tab123 = {{},{},{}}
                        for i=1,2 do
                            for j=1,skill.anim.grid do
                                local index = GetRandom.random(1,#tab)
                                local value = tab[index]
                                table.insert(tab123[i], value)
                                table.remove(tab, index)
                            end
                        end
                        tab123[3] = tab
                        local nodeGrid = BossMapMgr.getMapNodeByGridIndex(tab123[1])
                        for i=1,#nodeGrid do
                            if i == #nodeGrid then
                                BattleUIMgr.playBossEffect(skill.anim.name, nodeGrid[i], function()
                                    local nodeGrid2 = BossMapMgr.getMapNodeByGridIndex(tab123[2])
                                    for i=1,#nodeGrid2 do
                                        if i == #nodeGrid2 then
                                            BattleUIMgr.playBossEffect(skill.anim.name, nodeGrid2[i], function()
                                                local nodeGrid3 = BossMapMgr.getMapNodeByGridIndex(tab123[3])
                                                for i=1,#nodeGrid3 do
                                                    if i == #nodeGrid3 then
                                                        BattleUIMgr.playBossEffect(skill.anim.name, nodeGrid3[i], nil, function()
                                                            table.remove(BossBattleMgr.bossSkill, 1)
                                                            BossBattleMgr.playBossSkill()
                                                        end)
                                                    else
                                                        BattleUIMgr.playBossEffect(skill.anim.name, nodeGrid3[i])
                                                    end
                                                end
                                                BossBattleMgr.playGridEffect(tab123[3],skill.damage)
                                            end)
                                        else
                                            BattleUIMgr.playBossEffect(skill.anim.name, nodeGrid2[i])
                                        end
                                    end
                                    BossBattleMgr.playGridEffect(tab123[2],skill.damage)
                                end)
                            else
                                BattleUIMgr.playBossEffect(skill.anim.name, nodeGrid[i])
                            end
                        end
                        BossBattleMgr.playGridEffect(tab123[1],skill.damage)
                        BossMapMgr.playBossAnimWithCallback(skill.motion)
                    end
                end
            end)
        elseif skill.normalAttack and skill.motion and skill.anim then
            if skill.lastTime then
                BossBattleMgr.bossAni = true
                local isStart = false
                if skill.lastTime == skill.lastMaxTime then
                    BossMapMgr.playBossAnimByLoop(skill.motion)
                    isStart = true                 
                end
                BattleUIMgr.playBossEffectByLoop(skill.anim.name,BossMapMgr.getBossNode(),
                    function()
                        table.remove(BossBattleMgr.bossSkill, 1)
                        BossBattleMgr.playBossSkill()
                        if skill.lastTime <= 0 then
                            BossBattleMgr.bossAni = false
                            BossMapMgr.playBossAnimWithCallback(skill.motion)
                        end
                    end,isStart,skill.lastTime)
            else
                BattleUIMgr.playBossEffect(skill.anim.name, BossMapMgr.getBossNode(),nil,function()
                    table.remove(BossBattleMgr.bossSkill, 1)
                    BossBattleMgr.playBossSkill()
                end)
                BossMapMgr.playBossAnimWithCallback(skill.motion)
            end
            
            local myNode = BossMapMgr.getPlayerOwnerNode()
            if myNode and not BossMapMgr.isPlayerOwnerInSecurityRegion(BossMapMgr.getPlayerOwnerBornGridIndex()) 
                and not BossMapMgr.isPlayerOwnerBallsEmpty() and not BossMapMgr.isPlayerOwnerPowerOverwhelming() then
                WorldBossInfo.BossAttack(skill.normalAttack, function()
                    BattleUIMgr.showBossAttackDamage(myNode,skill.normalAttack)
                end)
            end
            local node = BossMapMgr.getAllPlayerNodeByGridIndex(BossMapMgr.getWalkableGridIndex())
            for i=1,#node do
                if node[i] ~= myNode then
                    BossMapMgr.takeDamage(node[i])
                    BattleUIMgr.showBossAttackDamage(node[i],skill.normalAttack)
                end
            end    
            
        end
    end
    
end

return BossBattleMgr