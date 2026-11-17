ViewMgrUtils = {}

function ViewMgrUtils.hFitStretch(screenSizeDiff, fitNodes)
    for i,v in ipairs(fitNodes) do
        local size = v:getContentSize()
        v:setContentSize(size.width + screenSizeDiff, size.height)
    end
end

function ViewMgrUtils.vFitStretch(screenSizeDiff, fitNodes)
    for i,v in ipairs(fitNodes) do
        local size = v:getContentSize()
        v:setContentSize(size.width, size.height + screenSizeDiff)
    end
end

function ViewMgrUtils.vFitSetPos(screenSizeDiff, fitNodes)
    for i,v in ipairs(fitNodes) do
        local y = v:getPositionY()
        v:setPositionY(y+screenSizeDiff/2)  
    end
end


ViewMgrUtils.WrapViewMgr = function(viewMgr)
	viewMgr.strechNodes = {}
	viewMgr.setPosNodes = {}
	viewMgr.addStretchNode = function(node)
		viewMgr.strechNodes[#viewMgr.strechNodes + 1] = node
	end
	viewMgr.addPosNode = function(node)
		viewMgr.setPosNodes[#viewMgr.setPosNodes + 1]  = node
	end
	viewMgr.addStretchNodes = function(nodes)
		for i,v in ipairs(nodes) do
			viewMgr.addStretchNode(v)
		end
	end
	viewMgr.addPosNodes = function(nodes)
		for i,v in ipairs(nodes) do
			viewMgr.addPosNode(v)
		end
	end
end

function ViewMgrUtils.AutoFit(viewMgr, screenSizeDiff)
	if screenSizeDiff == nil then
		screenSizeDiff = CocosModuleMgr.getScreenSizeDiff() > 0 and CocosModuleMgr.getScreenSizeDiff() or 0 
	end
	assert(viewMgr.strechNodes ~= nil)
	assert(viewMgr.setPosNodes ~= nil)
	ViewMgrUtils.vFitStretch(screenSizeDiff, viewMgr.strechNodes)
	ViewMgrUtils.vFitSetPos(screenSizeDiff, viewMgr.setPosNodes)
end

return ViewMgrUtils
