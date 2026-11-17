local LtPetsMgr = {}

LtPetsMgr.LtPets = {} 

LtPetsMgr.LtArmy = {} -- objIDs
LtPetsMgr.LtHelpArmy = {}

LtPetsMgr.LtEmptyPetNodes = {}
LtPetsMgr.LtArmyPetNodes = {}
LtPetsMgr.LtHelpArmyNodes = {}

-- 战斗返回数据
LtPetsMgr.petsAfterBattle = {}

function LtPetsMgr.Init()
end

function LtPetsMgr.getArmy()
end

---获取己方宠物信息 [战斗用]
function LtPetsMgr.getCurrMyPets()
    local ret = {}
    local helpRet = {}
    for i=1, #LtPetsMgr.LtArmy do
        local objID = LtPetsMgr.LtArmy[i]
        local petInfo = clone( PokemonInfo.getPetInfoByObjID(objID) )
        petInfo.hp = LtPetsMgr.LtPets[objID]
        table.insert(ret,petInfo)
    end
    for i=1, #LtPetsMgr.LtHelpArmy do
        local objID = LtPetsMgr.LtHelpArmy[i]
        local petInfo = clone( PokemonInfo.getPetInfoByObjID(objID) )
        petInfo.hp = LtPetsMgr.LtPets[objID]
        table.insert(helpRet,petInfo)
    end
    return ret, helpRet
end

function LtPetsMgr.setPetHpByObjID(id, hp)
    LtPetsMgr.LtPets[id] = hp
end

function LtPetsMgr.getHpByObjID(id)
    return LtPetsMgr.LtPets[id] or 0
end

function LtPetsMgr.handleHpAfterBattle(objidVec, hpVec)
    local tmpVec = {}
    for i = 1, #objidVec do tmpVec[objidVec[i]] = hpVec[i] end
    
    local Vec
    if LtMapOption.getMapType() == "ADVENTURE" then
        Vec = AdvPetsMgr.advArmy
    elseif LtMapOption.getMapType() == "LOSTTOWER" then
        Vec = LtPetsMgr.LtArmy
    else 
        Vec = {}
    end
    
    local currInfo = {}
    local battleDetails = {}
    for i=1, #Vec do
        local _obiID = Vec[i]
        table.insert(currInfo, {objID = _obiID, hp = tmpVec[_obiID]})
        table.insert(battleDetails, _obiID..","..tmpVec[_obiID])
    end
    
    return currInfo, battleDetails
end

function LtPetsMgr.resortArmy(objIDs, helpList)
    NetInterface.sendWithBlock("GC_CHANGEREADYPET_ACK", function()
        local LostTowerSend = require("src.Net.Send.LostTowerSend")
        LostTowerSend.sendCG_changeReadyPet_Req({
            activityArmysList = objIDs,
            activityHelpArmysList = helpList,
        })
    end, function()
    end)
end

--- 宠物恢复
-- @param type number 1:恢复 2:重置 3:地图恢复点
function LtPetsMgr.reocverArmyPets(type, pets)

    pets = pets or {}

    local function playRecoverEffect(node, tag)
        if not node then return end
    
        local eff = AnimationMgr.createAni(node,"Spine/effects/Ui_chongwuhuixue.png",49,85,tag)
        AnimationMgr.playAniWithCallback(eff.res, "animation", nil, eff.tag, true)
    end
    
    local function playReliveEffect(node, tag)
        if not node then return end
        
        local eff = AnimationMgr.createAni(node,"Spine/effects/Ui_fuhuotexiao.png",49,85)
        AnimationMgr.playAniWithCallback(eff.res, "animation", nil, eff.tag, true)
    end
    
    local tmpPets = {}
    for i = 1, #pets do
        tmpPets[pets[i].objID] = pets[i]
    end

    for i=1, #LtPetsMgr.LtArmy do
        local parent = LtPetsMgr.LtArmyPetNodes[i]
        local hpBar = CSResourceMgr.seekNodeByName(parent,"bar")
        
        local flag = false
        
        if type == 1 or type == 2 then      -- 恢复 & 重置
            flag = true
            if LtPetsMgr.getHpByObjID(LtPetsMgr.LtArmy[i]) > 0 then
                playRecoverEffect(LtPetsMgr.LtArmyPetNodes[i], LtMapOption.getMapType().."ArmyPet"..i)
            else
                playReliveEffect(LtPetsMgr.LtArmyPetNodes[i], LtMapOption.getMapType().."ArmyPet"..i)
            end
        elseif type == 3 then  -- 恢复点恢复
            if LtPetsMgr.getHpByObjID(LtPetsMgr.LtArmy[i]) > 0 then
                flag = true
                playRecoverEffect(LtPetsMgr.LtArmyPetNodes[i], LtMapOption.getMapType().."ArmyPet"..i)
            end
        end
        
        if flag then
            local objID = LtPetsMgr.LtArmy[i]
            local petInfo = PokemonInfo.getPetInfoByObjID(objID)
            
            local hp = petInfo.hpmax
            if tmpPets[objID] then hp = tmpPets[objID].hp end
            
            LtPetsMgr.setPetHpByObjID(LtPetsMgr.LtArmy[i], hp)
            hpBar:setPercent(math.floor(100 * hp / petInfo.hpmax))
            parent:setColor({r=255,g=255,b=255,a=255})
        end
    end
    
end

--- update army nodes
-- @param pets table pets为更新宠物，长度<=LtPetsMgr.LtArmy
function LtPetsMgr.updateArmyNodes(pets)
    if #pets > #LtPetsMgr.LtArmy then
        print("LT_DUBUG_INFO: ERROR PARAMS in function LtPetsMgr.updateArmyNodes")
        for i=1,#pets do
            print("**************************", i)
            for k, v in pairs(pets[i]) do
                print("petInfo",k,v)
            end
            print(LtPetsMgr.LtArmy[i])
        end
    end
    
    local tmpPets = {}
    for i = 1, #pets do
        tmpPets[pets[i].objID] = pets[i]
    end
    
    for i = 1, #LtPetsMgr.LtArmy do
        local objID = LtPetsMgr.LtArmy[i]
        if tmpPets[objID] then
            local parent = LtPetsMgr.LtArmyPetNodes[i]
            local hpBar = CSResourceMgr.seekNodeByName(parent,"bar")
    
            local petInfo = clone( PokemonInfo.getPetInfoByObjID(objID) )
            LtPetsMgr.setPetHpByObjID(objID, tmpPets[objID].hp)
            local percent = 100 * tmpPets[objID].hp / petInfo.hpmax
            hpBar:setPercent( math.floor(percent) )
            if tmpPets[objID].hp <= 0 then
                parent:setColor({r=130,g=130,b=130,a=255})
            else
                parent:setColor({r=255,g=255,b=255,a=255})
            end
        end
    end
end

return LtPetsMgr