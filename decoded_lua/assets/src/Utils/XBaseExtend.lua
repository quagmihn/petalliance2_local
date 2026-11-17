local XBaseExtend = {}

function XBaseExtend.extend(object)

	local Eca = require("Eca.Eca")
	local scheduler = require("framework.scheduler")
	local DialogMgr = require("Dialogs.DialogMgr")
	local SceneMgr = require("Scenes.SceneMgr")

	function object:setAlignMode(align)

		self.alignMode = align

	end

	function object:getAlignMode(align)

		return self.alignMode

	end

	function object:delayCall(func, duration)

		if ("function" == type(func) and "number" == type(duration)) then
			return scheduler.performWithDelayGlobal(func, duration)
		end

	end

	function object:addTimer(func, interval)

		if ("function" == type(func) and "number" == type(interval)) then
			scheduler.scheduleGlobal(func, interval)
		end

	end

	function object:changeScene(next)

		if ("string" == type(next)) then
	   		SceneMgr.switch2Scene(next)
		end

	end

	function object:openDialog(dlgType, params)

		if ("string" == type(dlgType)) then
	   		local dlgInstance = DialogMgr.openDialogImp(dlgType, params)
	   		if (dlgInstance) then
		   		dlgInstance:playEnterAction()
		   		return dlgInstance
		   	end
		end

	end

	function object.move2Top(node)

		if (node) then
			node:retain()

			local parent = node:getParent()
			local touch = node:isTouchEnabled()
		    parent:removeChild(node, false)
		    -- remove的时候会自动把touchEnable设成false
		    -- add回去之前or之后要重新设成true，否则就不能点了
		    parent:addChild(node)
		    node:setTouchEnabled(touch)

		    node:release()
		end

	end

	function object:addCtrl(params)

		if (params.ctrlType) then
			local ctrl = require(params.ctrlType)
			ctrl = ctrl.new(params)
			ctrl.nameXP = params.name

			if (not self.ctrlNameSpace:registCtrl(ctrl, params.name, params.coverName)) then
				print("[Error] addCtrl: Regist ctrl faild!")
				return nil
			end

			if (params.parent) then
				local parentNode = params.parent
				if ("string" == type(params.parent)) then
					parentNode = self.ctrlNameSpace:getRegisteredCtrl(params.parent)
				end

				if (parentNode) then
					parentNode:addChild(ctrl)
				elseif (not params.noParent) then
					self:addChildXP(ctrl)
				end
			elseif (not params.noParent) then
				self:addChildXP(ctrl)
			end

			if (params.x and params.y and not params.nodeCoord) then

				--这一陀代码是根据不同语言版本添加的额外的偏移量
				local offset = U(params.name)
				if offset and offset.x and offset.y then
					params.x = params.x + offset.x
					params.y = params.y + offset.y
				end

				local parent = ctrl:getParent()
				if (parent) then
					local nodeCoord = ctrl:getParent():convertToNodeSpace(ccp(params.x, params.y))
					ctrl:setPosition(nodeCoord.x, nodeCoord.y)
				end
			end

			if (nil ~= ctrl.afterAdd) then
				ctrl:afterAdd()
			end

			return ctrl
		else
			print("[Error] addCtrl: Can't create ctrl without type")
			return nil
		end

	end

	function object:preAdd(params)

		if (params.noAlign) then
			return
		end

		if (params.x and params.y) then
			if (display.LEFT_CENTER == self.alignMode) then
				params.x = display.left + params.x
				params.y = display.cy + params.y
			elseif (display.RIGHT_CENTER == self.alignMode) then
				params.x = display.right + params.x
				params.y = display.cy + params.y
			elseif (display.TOP_CENTER == self.alignMode) then
				params.x = display.cx + params.x
				params.y = display.top + params.y
			elseif (display.BOTTOM_CENTER == self.alignMode) then
				params.x = display.cx + params.x
				params.y = display.bottom + params.y
			elseif (display.LEFT_TOP == self.alignMode) then
				params.x = display.left + params.x
				params.y = display.top + params.y
			elseif (display.LEFT_BOTTOM == self.alignMode) then
				params.x = display.left + params.x
				params.y = display.bottom + params.y
			elseif (display.RIGHT_TOP == self.alignMode) then
				params.x = display.right + params.x
				params.y = display.top + params.y
			elseif (display.RIGHT_BOTTOM == self.alignMode) then
				params.x = display.right + params.x
				params.y = display.bottom + params.y
			else
				params.x = display.cx + params.x
				params.y = display.cy + params.y
			end
		end


	end

	local ctrlTypes = {
		["Node"] = "HDNode",
		["Sprite"] = "HDSprite",
		["Content"] = "HDContent",
		["Button"] = "HDButton",
		["CheckBox"] = "HDCheckBox",
		["Drag"] = "HDDrag",
		["Label"] = "HDLabel",
		["TimerLabel"] = "HDTimerLabel",
		["LabelXP"] = "HDLabelXP",
		["BMFont"] = "HDBMFontLabel",
		["LayerColor"] = "HDLayerColor",
		["Scroll"] = "HDScrollView",
		["Progress"] = "HDProgressBar",
		["ProgressSB"] = "HDProgressBarSB",
		["ProgressSB2"] = "HDProgressBarSB2",
		["Edit"] = "HDEdit",
		["RenderTarget"] = "HDRenderTarget",
		["Poker"] = "HDPokerCom",
		["GAF"] = "HDGAFCtrl",
		["ScrollBar"] = "HDScrollBar",
		["Clip"] = "HDClip",
		["Marquee"] = "HDMarquee",
		["Blocker"] = "HDBlocker",
		["LabelColorful"] = "HDLabelColorful",
		["Slider"] = "HDSlider",
		["Shape"] = "HDShape",
	}

	for k, v in pairs(ctrlTypes) do
		-- 每个addXXX函数
		object["add" .. k] = function(object, params)

			params = params or {}
			params.ctrlType = "UI." .. v
			object:preAdd(params)
			return object:addCtrl(params)

		end
	end

	function object:addListener(event, func, cond)

		if (nil == self.eventParams) then
			self.eventParams = {}
		end

		local param = {
			event = event,
			func = func,
			cond = cond,
		}
		self.eventParams[#self.eventParams + 1] = param

		Eca.addListener(event, {self, func, cond})

	end

	function object:delListener(event, func, cond)

		Eca.delListener(event, {self, func, cond})

	end

	function object:clearListeners()

		if (self.eventParams) then
			for i = 1, #self.eventParams do
				local param = self.eventParams[i]
				self:delListener(param.event, param.func, param.cond)
			end
		end
		
	end

	function object.changeCtrlParent(ctrl, newParent)

		if (nil == ctrl or nil == newParent) then
			return
		end

		local oldParent = ctrl:getParent()
		if (nil == oldParent) then
			return
		end

		local worldCoord = oldParent:convertToWorldSpace(ccp(ctrl:getPositionX(), ctrl:getPositionY()))
		local newCoord = newParent:convertToNodeSpace(worldCoord)
		local touch = ctrl:isTouchEnabled()

		ctrl:retain()
		oldParent:removeChild(ctrl, false)
		newParent:addChild(ctrl)
		ctrl:setPosition(newCoord.x, newCoord.y)
		ctrl:setTouchEnabled(touch)
		ctrl:release()

	end

	function object.openLoadingMask(text, noImage)

		SceneMgr.curScene:openLoadingMaskImp(text, noImage)

	end

	function object.closeLoadingMask()

		SceneMgr.curScene:closeLoadingMaskImp()

	end

	return object
end

return XBaseExtend