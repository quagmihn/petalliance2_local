local StandardTipsMgr = {}

StandardTipsMgr.MOVE_DIFF = 60
StandardTipsMgr.SHOW_MAX_NUM = 3
StandardTipsMgr.SP_ZORDER = nil

local resName = {}
local tag = {}

function StandardTipsMgr.Init()
	resName = {"UI/Common/SuccessTips.csb", "UI/Common/FailureTips.csb"}
    tag = {1, 1}
end

---标准提示框(不支持richlabel格式的文本)
--@param type int 默认0(成功0-底板蓝色,失败1-底板红色)
--@param str string tips文字
function StandardTipsMgr.show(type, str)
    local scene = SceneMgr.getRunningScene
    if type~=0 and type~=1 then
        print("StandardTipsMgr type error, use 0 or 1")
    	return
    end
    
    -- 添加音效  add by hxf
    if type == 1 then
        GameAudio.playUISound("error")
    end
    
    type = type+1

    if tag[type]>255 then
        if not CSResourceMgr.getCsbObj(resName[type], tag[type]) then
            tag[type] = 1
        end
    end
    tag[type] = tag[type]+1
    local tipsLayer = CSResourceMgr.createRes(scene, resName[type], tag[type])
    CSResourceMgr.setRelativePosition(resName[type], 320, 190, tag[type])
    local outlineColor = {}
    if type==1 then
        CocosModuleMgr.setEdgeDistance(tipsLayer, nil, 0, nil, nil)
        outlineColor = {r=2,g=23,b=38,a=255}
    else
        CocosModuleMgr.setEdgeDistance(tipsLayer, 0, nil, nil, nil)
        outlineColor = {r=101,g=25,b=4,a=255}
    end
    local posy = tipsLayer:getPositionY()
    tipsLayer.tipsPosy = posy
    tipsLayer:setLocalZOrder(StandardTipsMgr.SP_ZORDER or CocosModuleMgr.ZORDER_TIPS)

    if CocosModuleMgr.checkIsRichLabelString(str) then
        print("StandardTips not support richlabel")
        print(str, LuaSqlite.getLanguageByKey(str))
    else
        CSResourceMgr.setLabelString(resName[type], "text", str, tag[type], outlineColor, nil, 320)
    end

    CSResourceMgr.playAction(resName[type], 0, 10, false, tag[type])

    local function tipsDisappear(tag)
        local node = CSResourceMgr.getCsbObj(resName[type], tag)
        node:performWithDelay(function()
            transition.fadeOut(node, {time = 0.5})
            tipsLayer:performWithDelay(function()
                CSResourceMgr.removeCSObjectByTag(resName[type], tag)
            end, 0.5)
        end, 3)
    end

    tipsDisappear(tag[type])

    local function tipsMoving(tag)
        local node = CSResourceMgr.getCsbObj(resName[type], tag)
        if node then
            if node.tipsPosy>=StandardTipsMgr.MOVE_DIFF*(StandardTipsMgr.SHOW_MAX_NUM-1)+posy then
                CSResourceMgr.removeCSObjectByTag(node.res, node.tag)
                return
            end
            --[[
            local nodePosy = node:getPositionY()
            if nodePosy>=StandardTipsMgr.MOVE_DIFF*(StandardTipsMgr.SHOW_MAX_NUM-1)+posy then
                CSResourceMgr.removeCSObjectByTag(node.res, node.tag)
            	return
            end]]
            transition.moveBy(node, {y=StandardTipsMgr.MOVE_DIFF, time=0.1})
            node.tipsPosy = node.tipsPosy+StandardTipsMgr.MOVE_DIFF
            tipsMoving(tag-1)
        end
    end

    tipsMoving(tag[type]-1)
end

return StandardTipsMgr