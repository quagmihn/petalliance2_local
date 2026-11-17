local PetStrengthenMgr = {}

PetStrengthenMgr.RANK_NUM = 5

local resName = ""
local resNameBG = ""
local panelTable = {}

local closeCallback = nil

function PetStrengthenMgr.Init()
    print("PetStrengthenMgr初始化")
    
    resName = "Pet/Strengthen/PetStrengthen.csb"
    resNameBG = "Pet/Formation/FormationBG.csb"
    panelTable = {}
    
    closeCallback = nil
end

function PetStrengthenMgr.show(scene, callback)
    local myPets = PokemonInfo.getAllPets()
    closeCallback = callback
    
    local function loadCSB()
        local curLayerBG = CSResourceMgr.createRes(scene, resNameBG, "PetStrengthenMgr")
        curLayerBG:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "PetStrengthenMgr")
        --curLayerBG:setOpacity(0)
        --transition.fadeIn(curLayerBG, {time=1})
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)

        CSResourceMgr.clickEventBinding(resName, "close", function()
        	PetStrengthenMgr.hide()
        end)
        CSResourceMgr.setButtonString(resName, "close", "petmenu11", "", {r=2,g=43,b=155,a=200})
    end

    local function playCSB()
        CSResourceMgr.playAction(resName, 0, 5, false)
    end
    
    local function initPet()
        PetStrengthenMgr.reset(myPets)
    end

    local funcTable = {loadCSB, playCSB, initPet}
    UnblockLoader.load(funcTable, "PetStrengthenMgr")
end

function PetStrengthenMgr.hide()
    UnblockLoader.cancel("PetStrengthenMgr-reset")
    UnblockLoader.cancel("PetStrengthenMgr")
    for var=1, #panelTable do
    	panelTable[var]:removeAllChildren(true)
    end
    CSResourceMgr.getNodeByName(resName, "list"):removeAllItems()
    CSResourceMgr.removeCSObjectByTag(resName)
    CSResourceMgr.removeCSObjectByTag(resNameBG, "PetStrengthenMgr")
    if closeCallback then
        closeCallback()
        closeCallback = nil
    end
end

function PetStrengthenMgr.reset(myPets)
    local list = CSResourceMgr.getNodeByName(resName, "list")
    list:removeAllItems()
    local panelTable = {}
    local funcTable = {}
    for i=1, #myPets do
        local row = math.ceil(i/PetStrengthenMgr.RANK_NUM)
        local rank = i%PetStrengthenMgr.RANK_NUM
        if rank==0 then
            rank = PetStrengthenMgr.RANK_NUM
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
                    local starSp = CSResourceMgr.seekNodeByName(parent, "star"..var)
                    starSp:setVisible(true)
                    starSp:setLocalZOrder(1)
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
                PetEducationMgr.show(SceneMgr.getRunningScene, petInfo.objID)
            	--DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "objID:"..petInfo.objID.."\nattri:"..attriinfo)
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
            
            parent:setScale(0, 0)
            transition.scaleTo(parent, {scale = 1, time = 0.2})
            parent:setVisible(true)
        end
        table.insert(funcTable, itemFunc)
    end

    local panel = CSResourceMgr.getNodeByName(resName, "panel"):clone()
    table.insert(panelTable, panel)
    list:pushBackCustomItem(panel)
    list:performWithDelay(function()
        list:jumpToTop()
    end, 0.1)
    UnblockLoader.load(funcTable, "PetStrengthenMgr-reset", 0.01)
end

return PetStrengthenMgr