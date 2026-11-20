local AdvPetsMgr = {}

AdvPetsMgr.CurrTeam = 1

AdvPetsMgr.emptyNodes = {}

local myPets = {}   --pet info
local dead_pets = 0
local petNodes = {} --pet 节点
local curr_team = 1
local TEAM_NUM = 2

AdvPetsMgr.advArmy = {}
AdvPetsMgr.advHelpArmy = {}

AdvPetsMgr.advArmyPetNodes = {}
AdvPetsMgr.advHelpArmyNodes = {}

local ADV_PETS_EVENT

local last_injury_time   --to fix successive injuries

local injury_pets = {}    --ObjIDs
local injury_damages = {} --damages
local injury_infos = {
    --pets = {},   --ObjIDs
    --damage = {}, --damages
}

--当前队首pet血量
local curr_pet_hp

function AdvPetsMgr.Init()
    curr_team = 1
    myPets = {}
    for var=1, TEAM_NUM do
        myPets[var] = {}
    end
	dead_pets = 0
	injury_pets = {}
    injury_damages = {}
    curr_pet_hp = 0
    AdvPetsMgr.advArmy = {}
    AdvPetsMgr.advHelpArmy = {}
end

function AdvPetsMgr.reset()
    --dead_pets = 0
    injury_pets = {}
    injury_damages = {}
    curr_pet_hp = 0
end

function AdvPetsMgr.getPetIcon(id)
    if not id or type(id) ~= "number" then return "empty.png" end
    return string.format("Battle/bloodHead/%d.png", id)
end

function AdvPetsMgr.setCurrTeam(team_num)
    curr_team = team_num
    AdvPetsMgr.advArmy = clone(PokemonInfo.getPetArmy(curr_team))
    AdvPetsMgr.advHelpArmy = clone(PokemonInfo.getPetHelpArmy())
end
function AdvPetsMgr.getCurrTeam()
	return curr_team
end

---set by army index
function AdvPetsMgr.setMyPets(idx)
    print("set army index................."..idx)
    if idx > TEAM_NUM then return end
    --myPets = {}  -- clear myPets
    if NetInterface.isConnect then
        AdvPetsMgr.advArmy = clone( PokemonInfo.getPetArmy(idx) )
        AdvPetsMgr.advHelpArmy = clone( PokemonInfo.getPetHelpArmy() )
    
        myPets[idx] = {} -- clear myPets
        --local tmpPetArmyVec = (#AdvPetsMgr.advArmy > 0) and AdvPetsMgr.advArmy or PokemonInfo.getPetArmy(idx)
        local tmpPetArmyVec = PokemonInfo.getPetArmy(idx)
        for i=1, #tmpPetArmyVec do
            local tmpPinfo = clone( PokemonInfo.getActivePetsByObjID(tmpPetArmyVec[i]) )
            if not tmpPinfo then
                tmpPinfo = clone( PokemonInfo.getUnactivePetsByObjID(tmpPetArmyVec[i]) )
            end
            myPets[idx][i] = tmpPinfo
        end
    else
        myPets = {}
    end
    
    return myPets[idx]
end

function AdvPetsMgr.setCurrMyPetsWithObjIDs(objIDs)
    AdvPetsMgr.advArmy = objIDs
    for i=1, #AdvPetsMgr.advArmy do
        local tmpPinfo = PokemonInfo.getActivePetsByObjID(AdvPetsMgr.advArmy[i])
        if not tmpPinfo then
            tmpPinfo = PokemonInfo.getUnactivePetsByObjID(AdvPetsMgr.advArmy[i])
        end
        myPets[curr_team][i] = tmpPinfo
    end
end

function AdvPetsMgr.getMyPetsByIdx(idx)
    if idx > TEAM_NUM then return {} end
    return myPets[idx]
end

-- in sync with PokemonInfo
function AdvPetsMgr.updateCurrMyPets(objIDs)
    for k, v in pairs(myPets[curr_team]) do  --更新副本中myPets
        for kk, vv in pairs(objIDs) do
            if v.objID == vv then
                myPets[curr_team][k] = clone(PokemonInfo.getPetInfoByObjID(vv))
            end
        end
    end
end

function AdvPetsMgr.getCurrMyPets()

    local ret = {}
    local helpRet = {}
    for i=1, #AdvPetsMgr.advArmy do
        local tmpPinfo = PokemonInfo.getPetInfoByObjID(AdvPetsMgr.advArmy[i])
        ret[i] = tmpPinfo
    end
    for i=1, #AdvPetsMgr.advHelpArmy do
        local tmpPinfo = PokemonInfo.getPetInfoByObjID(AdvPetsMgr.advHelpArmy[i])
        helpRet[i] = tmpPinfo
    end
    return ret, helpRet
    
end


function AdvPetsMgr.useSkill(pets, skillIDs)

    --show pet avatar in bubble
    local function showPet(parent, petImg, posx, posy, boolAutoDisappear)
        if not parent then
            return nil
        end
        local filename = "Searching/skillEffect.csb"
        local tag = tostring(parent)
        local node = CSResourceMgr.createRes(parent, filename, tag)
        local pet = CSResourceMgr.getNodeByName(filename,"petAva",tag)
        pet:loadTexture(petImg)

        CSResourceMgr.playAllFrame(filename, true, tag)
        node:setPosition(posx, posy)
        node:setLocalZOrder(100)
        node:setScale(0.9)
        if boolAutoDisappear then
            node:performWithDelay(function()
                transition.fadeOut(node, {time = 0.5})
            end, 1.5)
            node:performWithDelay(function()
                CSResourceMgr.removeCSObjectByTag(filename, tag)
            end, 2.0)
        end
        return node
    end
    
    -- send ADVENTUTRE_USE_SKILL_REQ
    local function sendReq(index,pet,skillID,type)
        local petAva = AdvPetsMgr.getPetIcon(pet.pokeID)
        showPet(SearchingMgr.player, petAva, -40, 110, true)
        
        if not type then return end
        
        local skillInfo = PokemonInfo.getPetSkillInfoById(skillID)
        
        -- 副本技能互动
        local node, empty
        if type == "m_pet" then
            node = AdvPetsMgr.getPetNodes()[index]
            empty = AdvPetsMgr.emptyNodes[index]
        end
        if type == "h_pet" then
            node = AdvPetsMgr.advHelpArmyNodes[index]
            empty = AdvPetsMgr.emptyNodes[3 + index]
        end
        
        local skillSp = display.newSprite(PokemonInfo.getSkillIcon(skillID))
        
        
        local skillName
        if LtMapOption.getMapType() == "ADVENTURE" then
            skillName = CSResourceMgr.getNodeByName(SearchingUIMgr.bottomResName, "hp_inc_dec"):clone()
        end

        local param1 = {
            func1 = function()
                if not skillSp then skillSp = display.newSprite(PokemonInfo.getSkillIcon(skillID)) end
                local width, height = empty:getContentSize().width, empty:getContentSize().height
                empty:addChild(skillSp)
                skillSp:setPosition(width / 2, height / 2)
                if skillName then
                    CSResourceMgr.setLabelStringByNode(skillName,skillInfo.name,{r=0,g=0,b=0,a=255,w=1})
                    empty:addChild(skillName)
                    skillName:setPosition(width / 2, height / 2 - skillSp:getContentSize().height / 2)
                    skillName:setFontSize(22)
                end
            end,
            func2 = function()
            end,
            endFunc = function()
                local param2 = {
                    func1 = function()
                    end,
                    endFunc = function()
                        skillSp:removeFromParent()
                        if skillName then skillName:removeFromParent() end
                    end,
                }
                node:performWithDelay(function()
                    LtFuncMgr.flipCard(empty, node, param2)
                end,0.6)
            end,
        }
        LtFuncMgr.flipCard(node, empty, param1)
    end
    
    local function checkSkill(pTab, type)
        for k,v in pairs(pTab) do  --pets
            for i=1,#v.skills do   --skills
                for kk,vv in pairs(skillIDs) do --valid skills
                    local condID = vv
                    if v.skills[i] ~= 0 then
                        local _ID = math.floor(v.skills[i] / 10)
                        if _ID == condID then
                            sendReq(k, v, v.skills[i], type)
                            return true
                        end
                    end
                end
            end
        end
        
        return false
    end
    
    if checkSkill(pets["m_pet"],"m_pet") then
        return true
    end
    
    if checkSkill(pets["h_pet"],"h_pet") then
        return true
    end
    
    if checkSkill(PokemonInfo.getAllPets()) then
        return true
    end
    
    return false
    
end

--+++++++++++++++++++++++    trap damage func   +++++++++++++++++++++++++++++++

local function clearDamageInfo()
    injury_pets = {}
    injury_damages = {}
end

---
--@param objid int injuried pet's objid
--@param damage int damage added
function AdvPetsMgr.updateInjuriedPet(objid, damage)
    for k,v in pairs(injury_pets) do
        if v == objid then --to avoid duplicate insert
            injury_damages[k] = injury_damages[k] + damage
            return
        end
    end
    table.insert(injury_pets,objid)
    table.insert(injury_damages, damage)
end

---send damages req
function AdvPetsMgr.dealDamages(callback)
    if #injury_pets == 0 then 
        if callback ~= nil then callback() end
        return 
    end
    if NetInterface.isConnect then
        local objIDs = injury_pets
        local damageTypes = {}
        local damages = injury_damages
        for i=1,#objIDs do 
            print(injury_pets[i], injury_damages[i])
            table.insert(damageTypes, 1) 
        end
        SearchingMgr.canMove = false
        NetInterface.sendWithBlock("GC_ADVENTUREDAMAGE_ACK", 
        function()
            local AdventureSend = require("src/Net/Send/AdventureSend.lua")
            AdventureSend.sendCG_AdventureDamage_Req({
                petObjIDs = objIDs,
                damageTypes = damageTypes,
                damages = damages,
            })
        end, 
        function()
            SearchingMgr.canMove = true
            AdvPetsMgr.updateCurrMyPets(objIDs)
            clearDamageInfo()   --clear injury infos
            if callback ~= nil then callback() end
        end, 
        function()
            print("连接中...")
        end)
    end
end

function AdvPetsMgr.injuryEffect(pNode, objid, callback)
    local petInfo = PokemonInfo.getPetInfoByObjID(objid)
    local damage = math.ceil(petInfo.hpmax/10)
    
    local curr_pet_hp = 0
    for i=1,#injury_pets do
        if objid == injury_pets[i] then
            curr_pet_hp = petInfo.hp - injury_damages[i]
            if curr_pet_hp < 0 then curr_pet_hp = 0 end
        end
    end
    
--    if curr_pet_hp <= 0 then 
--        curr_pet_hp = petInfo.hp
--    end
--    curr_pet_hp = curr_pet_hp - damage
    
    local hp = CSResourceMgr.seekNodeByName(pNode, "bar")
    local last_percent = hp:getPercent()
    local HPpercentage = 100*curr_pet_hp/petInfo.hpmax
    if curr_pet_hp <= 0 then  --die
        pNode:setColor({r=130,g=130,b=130,a=255})
        
        hp:setPercent(0)
        AdvPetsMgr.readjustForLeaderDied()
        dead_pets = dead_pets + 1
--        if dead_pets == #PokemonInfo.getPetArmy(curr_team) then  --pets all died
--            require("src.GameMgr.Searching.AdvFailedView").show()
--            return
--        end
        local isAllDied = true
        for i = 1, #AdvPetsMgr.advArmyPetNodes do
            local hpbar = CSResourceMgr.seekNodeByName(AdvPetsMgr.advArmyPetNodes[i], "bar")
            if hpbar:getPercent() > 0 then
                isAllDied = false
                break 
            end
        end
        if isAllDied then 
            SearchingMgr.canMove = false
            transition.stopTarget(SearchingMgr.player)
            require("src.GameMgr.Searching.AdvFailedView").show()
            PlayerAnimeMgr.playAni(DungeonPlayerMgr.getPlayerTag(), "idle", true)
            return 
        end
    end
    
    --check to avoid duplicate `loadTexture` [ percentage will not set ]
    if HPpercentage > 0 and HPpercentage <= 50 and last_percent > 50 then  
--        hp:loadTexture("Searching/bottomBar/tn_xuet0003.png")
--        print("get percentage after loadTexture",hp:getPercent())
    end
    if math.abs(HPpercentage - hp:getPercent()) < 0.00001 then
        -- print("HPpercentage == hp:getPercent()")
    else
        hp:setPercent(HPpercentage)
    end

    local hp_inc_dec = CSResourceMgr.getNodeByName(SearchingUIMgr.bottomResName, "hp_inc_dec"):clone()

    hp_inc_dec:removeFromParent()
    hp_inc_dec:addTo(pNode)
    hp_inc_dec:setPosition(52, 100)
    
    CSResourceMgr.setLabelStringByNode(hp_inc_dec, "-"..damage, {r=255,g=255,b=0,a=255})
    hp_inc_dec:setTextColor({r=255,g=0,b=0,a=255})
    hp_inc_dec:setFontSize(48)
    hp_inc_dec:setVisible(true)
    transition.stopTarget( hp_inc_dec )
    local actionup =  cc.JumpBy:create(0.4, cc.p(0,0), 40, 1)
    hp_inc_dec:runAction(actionup)
    hp_inc_dec:performWithDelay(function()
        hp_inc_dec:removeFromParent()
    end,0.3)

    if callback ~= nil then callback() end
    
end

--++++++++++++++++++++++++++   for bottom bar   +++++++++++++++++++++++++++++++++++

function AdvPetsMgr.setPetNodes(pNodes)
    for k,v in pairs(pNodes) do
        AdvPetsMgr.advArmyPetNodes[k] = v
    end
end

function AdvPetsMgr.pNodes()
    return AdvPetsMgr.advArmyPetNodes
end

function AdvPetsMgr.getPetNodes()
    return AdvPetsMgr.advArmyPetNodes
end

function AdvPetsMgr.getPetNodeBySlot(i)
    return AdvPetsMgr.advArmyPetNodes[i]
end

function AdvPetsMgr.ObjIDs()
    --return PokemonInfo.getPetArmy(curr_team)
    return AdvPetsMgr.advArmy
end

---leader died, readjust
function AdvPetsMgr.readjustForLeaderDied(callback)
    local objIDs = AdvPetsMgr.advArmy --PokemonInfo.getPetArmy(curr_team)

    local head = 1
    local tail = #AdvPetsMgr.advArmy
    
    print(tail, #AdvPetsMgr.advArmy)

    local dt
    local pNode = AdvPetsMgr.advArmyPetNodes[head]
    local px = pNode:getPositionX()
    local py = 0  -- pNode:getContentSize().height/2
    local tagx = AdvPetsMgr.advArmyPetNodes[tail]:getPositionX()

    local function moveTo()
        pNode:setLocalZOrder(21)
        dt = 0.1 + 0.0002*math.abs(px - tagx)
        transition.moveTo(pNode,{x=tagx,y=py,time=dt})
        pNode:performWithDelay(function() pNode:setLocalZOrder(20) end,dt)
    end

    local function readjustOthers()
        local ppx = px
        for i=head+1, tail do
            local pn = AdvPetsMgr.advArmyPetNodes[i]
            local pppx = ppx
            ppx = pn:getPositionX()
            transition.moveTo(pn,{x=pppx,y=py,time=0.4})
        end
        local oID = objIDs[head]
        table.remove(objIDs, head)
        table.insert(objIDs, oID)
        
        local tmpNode = AdvPetsMgr.advArmyPetNodes[head]
        table.remove(AdvPetsMgr.advArmyPetNodes, head)
        table.insert(AdvPetsMgr.advArmyPetNodes, tmpNode)
    end

    moveTo()
    pNode:performWithDelay(function() 
        readjustOthers()
        AdvPetsMgr.resort(objIDs)
        if callback then callback() end
    end,dt)
end


--- 宠物队伍变换时，援助宠中血量为零宠物排后
function AdvPetsMgr.readjustForChangeArmy(deadPet)
    local objIDs = AdvPetsMgr.advHelpArmy

    local head = deadPet
    local tail = #AdvPetsMgr.advHelpArmy

    local dt
    local pNode = AdvPetsMgr.advHelpArmyNodes[head]
    local px = pNode:getPositionX()
    local py = 0
    local tagx = AdvPetsMgr.advHelpArmyNodes[tail]:getPositionX()
    
    -- 非死亡宠物不改变顺序
    local hpbar = CSResourceMgr.seekNodeByName(pNode, "bar")
    if hpbar:getPercent() > 0 then return end

    local function moveTo()
        pNode:setLocalZOrder(21)
        dt = 0.1 + 0.0002*math.abs(px - tagx)
        transition.moveTo(pNode,{x=tagx,y=py,time=dt})
        pNode:performWithDelay(function() pNode:setLocalZOrder(20) end,dt)
    end

    local function readjustOthers()
        local ppx = px
        for i=head+1, tail do
            local pn = AdvPetsMgr.advHelpArmyNodes[i]
            local pppx = ppx
            ppx = pn:getPositionX()
            transition.moveTo(pn,{x=pppx,y=py,time=0.4})
        end
        local oID = objIDs[head]
        table.remove(objIDs, head)
        table.insert(objIDs, oID)

        local tmpNode = AdvPetsMgr.advHelpArmyNodes[head]
        table.remove(AdvPetsMgr.advHelpArmyNodes, head)
        table.insert(AdvPetsMgr.advHelpArmyNodes, tmpNode)
    end

    moveTo()
    pNode:performWithDelay(function() 
        readjustOthers()
        AdvPetsMgr.advHelpArmy = objIDs
    end,dt)
end

---resort pets
function AdvPetsMgr.resort(objidVec)

    --编队与服务器同步
--    local petInfo = PokemonInfo.getPetInfoByObjID(objidVec[1])
--    curr_pet_hp = petInfo.hp
--
--    if not NetInterface.isConnect then return end
--    local armyVec = {}
--    local tmpVec = {armyIndex=curr_team, armyMembers=objidVec}
--    table.insert(armyVec, tmpVec)
--    NetInterface.sendWithBlock("GC_UpdatePetArmys_Ack", function()
--        local PetSend = require("src.Net.Send.PetSend")
--        PetSend.sendCG_UpdatePetArmys_Req({petArmys=armyVec})
--    end, function()
--        print("resort done")
--        PokemonInfo.setPetArmyByIdx(curr_team,objidVec)
--        PokemonInfo.updateActivePetsWithObjIDs(objidVec)
--        AdvPetsMgr.setMyPets(curr_team)
--        NetInterface.sendWithBlock("GC_ACTIVEPETARMY_ACK", function()
--            local PetSend = require("src.Net.Send.PetSend")
--            PetSend.sendCG_ActivePetArmy_Req({petArmyIndex=curr_team,})
--        end, function()
--        end)
--    end, function(code)
--    end)

    --编队不与服务器同步
    AdvPetsMgr.setCurrMyPetsWithObjIDs(objidVec)
    
end

return AdvPetsMgr