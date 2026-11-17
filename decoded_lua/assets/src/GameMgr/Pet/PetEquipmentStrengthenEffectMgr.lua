local PetEquipmentStrengthenEffectMgr = {}

local resName = ""

function PetEquipmentStrengthenEffectMgr.Init()
    resName = "Pet/Equipment/PetEquipmentStrengthenEffect.csb"
end

function PetEquipmentStrengthenEffectMgr.hideUI()
    if CSResourceMgr.getCsbObj(resName) then
        CSResourceMgr.removeCSObjectByTag(resName)
        UIStack.pop("PetEquipmentStrengthenEffectMgr")
    end
end

local function initStaticData()
end

function PetEquipmentStrengthenEffectMgr.show(scene, res, tag, callback, soundCallback)
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end
    
    UIStack.push("PetEquipmentStrengthenEffectMgr",PetEquipmentStrengthenEffectMgr.hideUI,false)
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)
        
        initStaticData()
    end
    
    local function playCSB()
        local curLayer = CSResourceMgr.getNodeByName(resName, "db")
        if curLayer ~= nil then
            curLayer:setVisible(true)
            curLayer:setScale(0.3)
            curLayer:setOpacity(0.5)
            transition.scaleTo(curLayer,{scale=1.0,time = 0.05})
            transition.fadeIn(curLayer, {time=0.2})
            curLayer:performWithDelay(function()
                local nodeEff = CSResourceMgr.seekNodeByName(curLayer, "nodeEff")
                local eff = AnimationMgr.createAni(nodeEff, res, 0, 0, tag)
                AnimationMgr.playAniWithCallback(eff.res, "animation", function()
                    transition.fadeOut(curLayer, {time=0.2})
                    curLayer:performWithDelay(function()
                        PetEquipmentStrengthenEffectMgr.hideUI()
                    end, 0.2)
                    if callback then
                    	callback()
                    end
                end, eff.tag)
                eff:registerSpineEventHandler(function(event)
                    --print("-----------", event.animation, event.eventData.name)
                    if (event.eventData.name=="hit1" or event.eventData.name=="hit2" or event.eventData.name=="hit3")
                        and event.animation=="animation" then
                        GameAudio.playUISound("actbattleMeet")
                        --print("----------play music")
                    elseif event.eventData.name=="Popout" and event.animation=="animation" then
                        if soundCallback then
                        	soundCallback()
                        end
                    end
                end, sp.EventType.ANIMATION_EVENT)
            end, 0.2)
        end
    end
    
    loadCSB()
    playCSB()
end

return PetEquipmentStrengthenEffectMgr