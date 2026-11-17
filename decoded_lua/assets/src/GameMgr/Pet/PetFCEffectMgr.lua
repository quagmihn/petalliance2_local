local PetFCEffectMgr = {}

local resName = ""
local targetTable = {}

function PetFCEffectMgr.Init()
    resName = "Pet/Education/PetFCEffect.csb"
end

local function hideUI()
    UnblockLoader.cancel("PetFCEffectMgr")
    targetTable = {}
    CSResourceMgr.removeCSObjectByTag(resName)
end

local function initStaticData(perfc, currfc)
    local spriteFC = CSResourceMgr.getNodeByName(resName, "fc_icon")
    CSResourceMgr.setSpriteTextureByNode(spriteFC, CocosModuleMgr.getWordImage("zdl.png"))

    local strFcOld = CSResourceMgr.getNodeByName(resName, "fc_str_old")
    CSResourceMgr.setLabelStringByNode(strFcOld, perfc, {r=191,g=49,b=9,a=255,w=2})
    CSResourceMgr.setLabelColorByNode(strFcOld, {r=254,g=243,b=57,a=255})

    local strFcNow = CSResourceMgr.getNodeByName(resName, "fc_str_now")
    CSResourceMgr.setLabelStringByNode(strFcNow, currfc, {r=191,g=49,b=9,a=255,w=2})
    CSResourceMgr.setLabelColorByNode(strFcNow, {r=254,g=243,b=57,a=255})
    strFcNow:setOpacity(0)

    --阿杜修改英文版显示
    if LuaSqlite.LANG_TYPE ~= 1 then
        strFcOld:setPositionX(240)
        strFcNow:setPositionX(240)
    end
end

local function updateEffect()
    local node = CSResourceMgr.getNodeByName(resName, "fc_bg")
    local eff = CSResourceMgr.createCCBI(node, "texture/ui_dc_09.ccbi", 200, 27)
    eff:setGlobalZOrder(CocosModuleMgr.ZORDER_GUIDE)
end

local function updateLabelEffect()
    local moveTime = 0.2
    local deltaTime = 0.2
    local strFcOld = CSResourceMgr.getNodeByName(resName, "fc_str_old")
    local strFcNow = CSResourceMgr.getNodeByName(resName, "fc_str_now")
    strFcOld:performWithDelay(function()
        transition.moveBy(strFcOld, {y = 35, time = moveTime})
        transition.moveBy(strFcNow, {y = 35, time = moveTime})
        transition.fadeOut(strFcOld, {time = moveTime})
        transition.fadeIn(strFcNow, {time = moveTime + deltaTime})
        GameAudio.playBattleSound("resultNum")
    end, 0.1)
end

function PetFCEffectMgr.show(scene, perfc, currfc)
    if CSResourceMgr.getCsbObj(resName) then
        for k,v in pairs(targetTable) do
            transition.stopTarget(v)
        end
        hideUI()
    end

    local function initTargetTable()
        targetTable = {
            CSResourceMgr.getNodeByName(resName, "fc_bg"),
            CSResourceMgr.getNodeByName(resName, "fc_str_old"),
            CSResourceMgr.getNodeByName(resName, "fc_str_now")
        }
    end
    
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        local fcBG = CSResourceMgr.getNodeByName(resName, "fc_bg")
        fcBG:setScaleY(0)
        fcBG:setVisible(true)

        initTargetTable()
        initStaticData(perfc, currfc)

        local diff = CocosModuleMgr.getScreenSizeDiff()
        ViewMgrUtils.vFitSetPos(diff, {fcBG})
    end
    
    local function playCSB()
        local curLayer = CSResourceMgr.getNodeByName(resName, "fc_bg")
        if curLayer ~= nil then
            curLayer:setVisible(true)
            -- curLayer:setScaleY(0)
            curLayer:setOpacity(0.5)
            transition.scaleTo(curLayer,{scale = 1.0,time = 0.1})
            transition.fadeIn(curLayer, {time = 0.2})

            curLayer:performWithDelay(function ()
                updateEffect()
                updateLabelEffect()
            end, 0.3)
            
            curLayer:performWithDelay(function()
                transition.fadeOut(curLayer, {time = 0.3})
            end, 1.3)
            curLayer:performWithDelay(function()
                hideUI()
            end, 1.6)
        end
    end
    
    local funcTable = {loadCSB, playCSB}
    
    UnblockLoader.load(funcTable, "PetFCEffectMgr")

    -- for i=1,#funcTable do
    --     funcTable[i]()
    -- end
end

return PetFCEffectMgr