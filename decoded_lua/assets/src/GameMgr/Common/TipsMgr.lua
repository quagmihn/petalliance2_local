local TipsMgr = {}

local resName = ""
local tag = 1
local richLabelTable = {}

function TipsMgr.Init()
    resName = "UI/Common/Tips.csb"
    tag = 1
    richLabelTable = {}
end

function TipsMgr.show(scene, str)
    StandardTipsMgr.show(0, str)
    --[[
    scene = scene or SceneMgr.getRunningScene
    
    if tag>255 then
    	if not CSResourceMgr.getCsbObj(resName, tag) then
    		tag = 1
    	end
    end
    tag = tag + 1
    local tipsLayer = CSResourceMgr.createRes(scene, resName, tag)
    CSResourceMgr.setRelativePosition(resName, 320, 190, tag)
    tipsLayer:setLocalZOrder(CocosModuleMgr.ZORDER_TIPS)
    
    if CocosModuleMgr.checkIsRichLabelString(str) then
        local richLabel = CocosModuleMgr.createRichLabel(tipsLayer, str, 20, "cuyuan_GBK.ttf", 300)
        richLabel:setPosition(tipsLayer:getContentSize().width/2-richLabel.realWidth/2, 
            tipsLayer:getContentSize().height/2+richLabel.realHeight/2)
        richLabelTable[tag] = richLabel
    else
        CSResourceMgr.setLabelString(resName, "tips", str, tag, CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
    end
    
    CSResourceMgr.playAction(resName, 0, 20, false, tag)
    
    local function tipsDisappear(tag)
    	local node = CSResourceMgr.getCsbObj(resName, tag)
        node:performWithDelay(function()
            if richLabelTable[tag] then
                richLabelTable[tag]:removeFromParent(true)
                richLabelTable[tag] = nil
            end
            transition.fadeOut(node, {time = 0.5})
            tipsLayer:performWithDelay(function()
                CSResourceMgr.removeCSObjectByTag(resName, tag)
            end, 0.5)
        end, 3)
    end
    
    tipsDisappear(tag)
    
    local function tipsMoving(tag)
        local node = CSResourceMgr.getCsbObj(resName, tag)
    	if node then
    	    transition.moveBy(node, {y=50, time=0.1})
    		tipsMoving(tag-1)
    	end
    end
    
    tipsMoving(tag-1)
    ]]
end

function TipsMgr.showError(scene, code)
    StandardTipsMgr.show(1, CocosModuleMgr.createStringWithFormat({"tips12", code}))
    --[[
    scene = scene or SceneMgr.getRunningScene
    TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"tips12", code}))
    ]]
end

return TipsMgr