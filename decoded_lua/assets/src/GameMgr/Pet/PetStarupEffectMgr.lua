local PetStarupEffectMgr = {}

local resName = ""
local borrowAniInfo = {}

function PetStarupEffectMgr.Init()
    resName = "Pet/Education/PetStarupEffect.csb"
    borrowAniInfo = {}
end

function PetStarupEffectMgr.hideUI()
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("PetStarupEffectMgr")
end

--升星材料亮边特效
function PetStarupEffectMgr.showStarUpLightEffect(parent)
    local light = CSResourceMgr.createCCBI(parent, "texture/ui_dc_10a.ccbi",
        parent:getContentSize().width*0.5, parent:getContentSize().height*0.5)
    light:setGlobalZOrder(CocosModuleMgr.ZORDER_GUIDE)
    parent:performWithDelay(function()
        parent:removeChild(light)
    end, 0.5)
end

local function initStaticData(petID, starLevel)
    local petInfo = PokemonInfo.getPokemonInfoByID(petID)
    CSResourceMgr.setLabelString(resName, "txt_bg1", CocosModuleMgr.createStringWithFormat({"train109", LuaSqlite.getLanguageByKey(petInfo.name), starLevel}))
end

local function borrowEducationAni(petID, tag)
    local aniPetRes = PokemonInfo.getPokemonResByID(petID)
    local aniRes = AnimationMgr.getGafObj(aniPetRes, tag)
    if aniRes then
        borrowAniInfo.aniPetRes = aniPetRes
        borrowAniInfo.aniRes = aniRes
        borrowAniInfo.aniTag = tag
        borrowAniInfo.tag = aniRes:getTag()
        borrowAniInfo.parent = aniRes:getParent()
        borrowAniInfo.scale = aniRes:getScale()
        local x, y = aniRes:getPosition()
        borrowAniInfo.x = x
        borrowAniInfo.y = y
        borrowAniInfo.localZOrder = aniRes:getLocalZOrder()
        borrowAniInfo.motionName = AnimationMgr.getGafObjCurMotionName(aniPetRes, tag)
        
        aniRes:removeFromParent(false)
        aniRes:retain()
    end
    return aniRes
end

local function returnEducationAni()
    if borrowAniInfo.aniRes and borrowAniInfo.parent then
        borrowAniInfo.aniRes:removeFromParent(false)
        borrowAniInfo.aniRes:retain()
        borrowAniInfo.aniRes:addTo(borrowAniInfo.parent, borrowAniInfo.localZOrder, borrowAniInfo.tag)
        borrowAniInfo.aniRes:setPosition(borrowAniInfo.x, borrowAniInfo.y)
        borrowAniInfo.aniRes:setScale(borrowAniInfo.scale)
        AnimationMgr.playAni(borrowAniInfo.aniPetRes,borrowAniInfo.motionName,true,borrowAniInfo.aniTag)
    end
end

local function updateEffect(petID)
    local spriteTitle = CSResourceMgr.getNodeByName(resName, "title")
    CSResourceMgr.setSpriteTextureByNode(spriteTitle, CocosModuleMgr.getWordImage("starup.png"))
    local aniPetRes = PokemonInfo.getPokemonResByID(petID)
    local aniPetTag = "edu-"..petID
    local petAniNode = CSResourceMgr.getNodeByName(resName, "petAni")
    local aniRes = borrowEducationAni(petID, aniPetTag)--AnimationMgr.createAni(petAniNode, aniPetRes, 0, 0, aniPetTag)
    if aniRes then
        aniRes:addTo(petAniNode)
        aniRes:setPosition(0, 0)
        aniRes:setScale(0.2)
        aniRes:setLocalZOrder(CocosModuleMgr.ZORDER_GUIDE)
        --CocosModuleMgr.lightenNode(aniRes, 1.0001)
        -- AnimationMgr.playAni(aniPetRes, "idle", true, aniPetTag)
        AnimationMgr.playAni(aniPetRes, "walk", true, aniPetTag)
        transition.scaleTo(aniRes,{scale=1.2,time = 0.2})
    
        --aniRes:performWithDelay(function()
        --    CocosModuleMgr.lightenNode(aniRes, 0)
        --end, 0.4)
    
        local eff1 = CSResourceMgr.createCCBI(petAniNode, "texture/ui_dc_05a.ccbi", 0, 120)
        eff1:setGlobalZOrder(CocosModuleMgr.ZORDER_GUIDE)
        local eff2 = CSResourceMgr.createCCBI(petAniNode, "texture/ui_dc_05b.ccbi", 0, 120)
        eff2:setGlobalZOrder(CocosModuleMgr.ZORDER_GUIDE)
        aniRes:performWithDelay(function()
            --AnimationMgr.removeGafObjectByTag(aniPetRes, aniPetTag)
            --eff1:removeFromParent(true)
            --eff2:removeFromParent(true)
            transition.scaleTo(aniRes,{scale=1.5,time = 0.075})
            GameAudio.playUISound("petLevelup")
        end,0.2)
    end
end

local function updateEffect2(petID, starNode)
    local node = PetEducationMgr.getStarUpEffectNode()
    local eff1 = CSResourceMgr.createCCBI(node, "texture/ui_dc_08a.ccbi", -58, 30)
    eff1:setGlobalZOrder(CocosModuleMgr.ZORDER_GUIDE)
    local eff2 = CSResourceMgr.createCCBI(starNode, "texture/ui_dc_08b.ccbi", 15, 15)
    eff2:setGlobalZOrder(CocosModuleMgr.ZORDER_GUIDE)
end

function PetStarupEffectMgr.show(scene, petID, starLevel, closeCallback)
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end
    UIStack.push("PetStarupEffectMgr",PetStarupEffectMgr.hideUI,false)
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)
        
        CSResourceMgr.clickEventBinding(resName, "bg", function()
            local aniRes = borrowEducationAni(petID, "edu-"..petID)
            transition.stopTarget(aniRes)

            returnEducationAni()
            PetStarupEffectMgr.hideUI()
            updateEffect2(petID, PetEducationMgr.getStarNodeByStarLv(starLevel))
            if closeCallback then closeCallback() end
        end)
        
        initStaticData(petID, starLevel)
    end
    
    local function playCSB()
        local curLayer = CSResourceMgr.getNodeByName(resName, "db")
        if curLayer ~= nil then
            curLayer:setVisible(true)
            curLayer:setScale(0.3)
            curLayer:setOpacity(0.5)
            transition.scaleTo(curLayer,{scale=1.0,time = 0.05})
            transition.fadeIn(curLayer, {time=0.25})
            --CocosModuleMgr.showUIAnimation(curLayer, "down")
            
            -- curLayer:performWithDelay(function()
                local tip = CSResourceMgr.getNodeByName(resName, "bg1")
                tip:setVisible(true)
                transition.moveTo(tip, {x = display.cx, time = 0.25})
                updateEffect(petID)
            -- end, 0.5)
        end
    end
    
    loadCSB()
    playCSB()
end

return PetStarupEffectMgr