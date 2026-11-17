local BasicPetListMgr = {}

BasicPetListMgr.RANK_NUM = 5

local resNameP = ""
local resName = ""
local panelTable = {}
local petSpriteTable = {}
local hideCallback = nil

function BasicPetListMgr.Init()
    print("BasicPetListMgr初始化")

    resNameP = "Pet/BasicPetList_2/CommonPet.csb"
    resName = "Pet/BasicPetList/PetList.csb"
    panelTable = {}
    petSpriteTable = {}
    hideCallback = nil
end

--scene可以为场景，也可以为任意父节点（可设置pos）
--callback可以为单function，也可以为function组（暂不支持）
function BasicPetListMgr.show(scene, btnCallback, resetCallback, closeCallback, pos)
    local myPets = PokemonInfo.getAllPets()
    hideCallback = closeCallback

    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        if scene==SceneMgr.getRunningScene then
            curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
            CSResourceMgr.setRelativePosition(resName, 320, 480)
        else
            if pos then
            	curLayer:setPosition(pos.x, pos.y)
            end
            CSResourceMgr.getNodeByName(resName, "close"):setVisible(false)
            CSResourceMgr.getNodeByName(resName, "bg"):setVisible(false)
            CSResourceMgr.setFrame(resName, 5)
        end

        CSResourceMgr.clickEventBinding(resName, "close", function()
            BasicPetListMgr.hide()
        end)
        CSResourceMgr.setButtonString(resName, "close", "petmenu11", "", {r=2,g=43,b=155,a=200})
    end

    local function playCSB()
        if scene==SceneMgr.getRunningScene then
            CSResourceMgr.playAction(resName, 0, 5, false)
        end
    end

    local function initPet()
        BasicPetListMgr.reset(myPets, btnCallback, resetCallback)
    end

    local funcTable = {loadCSB, playCSB, initPet}
    loadCSB()
    playCSB()
    initPet()
    --UnblockLoader.load(funcTable, "BasicPetListMgr")
end

function BasicPetListMgr.hide()
    UnblockLoader.cancel("BasicPetListMgr-reset")
    UnblockLoader.cancel("BasicPetListMgr")
    for var=1, #panelTable do
        panelTable[var]:removeAllChildren(true)
    end
    panelTable = {}
    petSpriteTable = {}
    CSResourceMgr.getNodeByName(resName, "list"):removeAllItems()
    CSResourceMgr.removeCSObjectByTag(resName)
    
    if hideCallback then
        hideCallback()
        hideCallback = nil
    end
end

function BasicPetListMgr.getPetListNode(objID)
	return petSpriteTable[objID]
end

function BasicPetListMgr.refresh(petInfo)
	if not CSResourceMgr.getCsbObj(resName) then
		return
	end
    print("BasicPetListMgr.refresh", petInfo.objID)
    if petSpriteTable[petInfo.objID] then
        CSResourceMgr.setLabelStringByNode(petSpriteTable[petInfo.objID].level, "Lv."..petInfo.level)
        local rarePoint = PokemonInfo.getPokemonInfoByID(petInfo.pokeID).rarePoint
        local preExp = ExperienceInfo.getExperienceInfoByID(petInfo.level-1).petExpVec[rarePoint]
        local levelpercent = (petInfo.exp-preExp)*100/
            (ExperienceInfo.getExperienceInfoByID(petInfo.level).petExpVec[rarePoint]-preExp)
        petSpriteTable[petInfo.objID].levelbar:setPercent(levelpercent)
	end
end

function BasicPetListMgr.setStatus(objID, enable, sel, dark)
    if petSpriteTable[objID] then
        CSResourceMgr.setButtonEnabledByNode(petSpriteTable[objID].node, enable)
        CSResourceMgr.seekNodeByName(petSpriteTable[objID].node, "sel"):setVisible(sel)
        if dark then
        	petSpriteTable[objID].icon:setColor({r=100,g=100,b=100})
        else
            petSpriteTable[objID].icon:setColor({r=255,g=255,b=255})
        end
    end
end

function BasicPetListMgr.reset(myPets, btnCallback, resetCallback)
    local list = CSResourceMgr.getNodeByName(resName, "list")
    list:removeAllItems()
    panelTable = {}
    petSpriteTable = {}
    local funcTable = {}
    for i=1, #myPets do
        local row = math.ceil(i/BasicPetListMgr.RANK_NUM)
        local rank = i%BasicPetListMgr.RANK_NUM
        if rank==0 then
            rank = BasicPetListMgr.RANK_NUM
        end
        if rank==1 then
            local panel = CSResourceMgr.getNodeByName(resName, "panel"):clone()
            table.insert(panelTable, panel)
            list:pushBackCustomItem(panel)
        end
        local petInfo = myPets[i]
        local function itemFunc()
            local parent = CSResourceMgr.seekNodeByName(panelTable[row], "btn")
            if rank>1 then
                parent = CSResourceMgr.getNodeByName(resName, "btn"):clone()
                parent:addTo(panelTable[row])
                parent:setPositionX(110*(rank-1)+55)
            end
            if petInfo.star then
                for var=1, tonumber(petInfo.star) do
--                    local starSp = CSResourceMgr.seekNodeByName(parent, "star"..var)
--                    starSp:setVisible(true)
--                    starSp:setLocalZOrder(1)
                end
            end
            local level = CSResourceMgr.seekNodeByName(parent, "level")
            CSResourceMgr.setLabelStringByNode(level, "Lv."..petInfo.level, {r=0,g=0,b=0,a=255})
            local levelbar = CSResourceMgr.seekNodeByName(parent, "levelbar")
            local rarePoint = PokemonInfo.getPokemonInfoByID(petInfo.pokeID).rarePoint
            local preExp = ExperienceInfo.getExperienceInfoByID(petInfo.level-1).petExpVec[rarePoint]
            local levelpercent = (petInfo.exp-preExp)*100/
                (ExperienceInfo.getExperienceInfoByID(petInfo.level).petExpVec[rarePoint]-preExp)
            levelbar:setPercent(levelpercent)
            local sprite = CSResourceMgr.seekNodeByName(parent, "icon")
            sprite:setScale(0.65)
            CSResourceMgr.setSpriteTextureByNode(sprite, PokemonInfo.getPokemonIconByID(petInfo.pokeID))
            local attri = CSResourceMgr.seekNodeByName(parent, "attri")
            local attriinfo = tonumber(PokemonInfo.getPokemonInfoByID(petInfo.pokeID).elementAtt1)
            CSResourceMgr.setSpriteTextureByNode(attri, "Pet/AttriIcon/"..attriinfo..".png")
            CSResourceMgr.clickEventBindingByNode(parent, function()
                if btnCallback then
                    btnCallback(petInfo)
                end
            end)
            local stage = CSResourceMgr.seekNodeByName(parent, "diban")
            local attridb = CSResourceMgr.seekNodeByName(parent, "attridiban")
            if petInfo.Stage then
                local pvec = PokemonInfo.getStagePics(petInfo.Stage)
                CSResourceMgr.setSpriteTextureByNode(stage, pvec.p1)
                CSResourceMgr.setSpriteTextureByNode(attridb, pvec.p2)
                if pvec.p3 then
                    local satgeFrame = display.newSprite(pvec.p3)
                    satgeFrame:addTo(stage)
                    satgeFrame:setPosition(stage:getContentSize().width/2, stage:getContentSize().height/2)
                end
            end
            petSpriteTable[petInfo.objID] = {level=level, levelbar=levelbar, node=parent, icon=sprite}

            parent:setScale(0, 0)
            transition.scaleTo(parent, {scale = 1, time = 0.2})
            parent:setVisible(true)
            parent:setSwallowTouches(true)
            if resetCallback then
                resetCallback(petInfo)
            end
        end
        itemFunc()
        table.insert(funcTable, itemFunc)
    end

    local panel = CSResourceMgr.getNodeByName(resName, "panel"):clone()
    table.insert(panelTable, panel)
    list:pushBackCustomItem(panel)
    list:performWithDelay(function()
        list:jumpToTop()
    end, 0.1)
    --UnblockLoader.load(funcTable, "BasicPetListMgr-reset", 0.01)
end

function BasicPetListMgr.createPetNode(petInfo, tag)
    tag = tag or ""
    local parent = CSResourceMgr.createRes(nil, resNameP, petInfo.objID..tag)
    if petInfo.star then
        for var=1, tonumber(petInfo.star) do
--            local starSp = CSResourceMgr.seekNodeByName(parent, "star"..var)
--            starSp:setVisible(true)
--            starSp:setLocalZOrder(1)
        end
    end
    local level = CSResourceMgr.seekNodeByName(parent, "level")
    CSResourceMgr.setLabelStringByNode(level, "Lv."..petInfo.level, {r=0,g=0,b=0,a=255})
    local levelbar = CSResourceMgr.seekNodeByName(parent, "levelbar")
    local rarePoint = PokemonInfo.getPokemonInfoByID(petInfo.pokeID).rarePoint
    local preExp = ExperienceInfo.getExperienceInfoByID(petInfo.level-1).petExpVec[rarePoint]
    local levelpercent = (petInfo.exp-preExp)*100/
        (ExperienceInfo.getExperienceInfoByID(petInfo.level).petExpVec[rarePoint]-preExp)
    levelbar:setPercent(levelpercent)
    local sprite = CSResourceMgr.seekNodeByName(parent, "icon")
    sprite:setScale(0.65)
    CSResourceMgr.setSpriteTextureByNode(sprite, PokemonInfo.getPokemonIconByID(petInfo.pokeID))
    local attri = CSResourceMgr.seekNodeByName(parent, "attri")
    local attriinfo = tonumber(PokemonInfo.getPokemonInfoByID(petInfo.pokeID).elementAtt1)
    CSResourceMgr.setSpriteTextureByNode(attri, "Pet/AttriIcon/"..attriinfo..".png")
    local stage = CSResourceMgr.seekNodeByName(parent, "diban")
    local attridb = CSResourceMgr.seekNodeByName(parent, "attridiban")
    if petInfo.Stage then
        local pvec = PokemonInfo.getStagePics(petInfo.Stage)
        CSResourceMgr.setSpriteTextureByNode(stage, pvec.p1)
        CSResourceMgr.setSpriteTextureByNode(attridb, pvec.p2)
        if pvec.p3 then
            local satgeFrame = display.newSprite(pvec.p3)
            satgeFrame:addTo(stage)
            satgeFrame:setPosition(stage:getContentSize().width/2, stage:getContentSize().height/2)
        end
    end
    local button = CSResourceMgr.seekNodeByName(parent, "diban")
    local struct = {node=parent, button=button,levelbar=levelbar,level=level, node=parent, icon=sprite}
    return struct
end

return BasicPetListMgr