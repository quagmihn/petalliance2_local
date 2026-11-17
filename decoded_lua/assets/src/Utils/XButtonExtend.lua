local XButtonExtend = {}

function XButtonExtend.extend(object)

	local UIButton = require("framework.cc.ui.UIButton")
	local HDDragHandler = require("UI.HDDragHandler")
	local ActionBuilder = require("Utils.ActionBuilder")
	local Eca = require("Eca.Eca")
	local scheduler = require("framework.scheduler")
	require("Effects.HDAudio")

	object.OPTSTATE_CLICK = 1
	object.OPTSTATE_MOVE = 2
	object.OPTSTATE_DRAG = 3

	object.DRAGOUT_EVENT = "DRAGOUT_EVENT"
	object.DRAGIN_EVENT = "DRAGIN_EVENT"

	function object:init(params)

		if (params.x and params.y) then
			self:setPosition(params.x, params.y)
		end

		if (params.listener) then
			self:onButtonClicked(params.listener)
		end

		self.pressX = 0
		self.pressY = 0
		self.optState = self.OPTSTATE_CLICK

		self.findParent = false
		self.dragParent = nil
		self.dragAngle = nil
		-- 为了使HDDrag和HDScrollView的玩法统一就这么做了
		-- 默认moveParent为true，代表是HDDrag
		if (params.moveParent == nil) then
		    self.moveParent = false
		else
		    self.moveParent = params.moveParent
		end

		self.content = nil
		self.touchID = -1
		-- 拖出拖入响应函数
		if (params.dragOutListener) then
		    self:addEventListener(self.DRAGOUT_EVENT, params.dragOutListener)
		end
		if (params.dragInListener) then
		    self:addEventListener(self.DRAGIN_EVENT, params.dragInListener)
		end
		-- 是拷贝拖出，还是自己不保留了
		self.dragCopy = params.dragCopy or false

		self.pressDelay = params.pressDelay or 0
		self.skipClick = params.skipClick or false
		self.skipClickFlag = false
		if (params.pressListener) then
		    self:addEventListener(UIButton.PRESSED_EVENT, params.pressListener)
		end
		if (params.releaseListener) then
		    self:addEventListener(UIButton.RELEASE_EVENT, params.releaseListener)
		end

		self.pressHandler = nil
		self:addScriptEventListener(CLEANUP_EVENT, function()
				if (nil ~= self.pressHandler) then
					scheduler.unscheduleGlobal(self.pressHandler)
					self.pressHandler = nil
				end
			end)

		self.inDragIn = false
		self.processDragIn = false

		self.eventActParam = params.eventAct
	    
	end

	function object:getButtonSize()
	    
	    if self.sprite_ then
	    	return self.sprite_:getContentSize()
	    else
	    	return CCSize(0, 0)
	    end

	end

	function object:setEnabled(enabled)

	    self:setTouchEnabled(enabled)

	    if enabled and self.fsm_:canDoEvent("enable") then
	        self.fsm_:doEventForce("enable")
	        self:dispatchEvent({name = self.STATE_CHANGED_EVENT, state = self.fsm_:getState()})
	    elseif not enabled and self.fsm_:canDoEvent("disable") then
	        self.fsm_:doEventForce("disable")
	        self:dispatchEvent({name = self.STATE_CHANGED_EVENT, state = self.fsm_:getState()})
	    end

	end

	function object:getClickPointX()

		return self.clickX

	end

	function object:getClickPointY()

		return self.clickY

	end

	function object:onTouch_(event, x, y, touchID)

	    if event == "ended" and self:checkTouchInSprite_(x, y) then
	        self.clickX = x
	        self.clickY = y
	    end

	    if (not self.findParent) then
	        self.findParent = true
	        self.dragParent, self.dragAngle = self:findDragParent()
	    end

	    if event == "began" then
	        if not self:checkTouchInSprite_(x, y) then
	        	return false
	        end

	        local scrollParent = self:findScrollParent()
	        if (scrollParent) then
	        	local pos = scrollParent:convertToWorldSpace(ccp(0, 0))
	        	local viewSize = scrollParent:getViewSize()
	        	if (x < pos.x or x > pos.x + viewSize.width
	        		or y < pos.y or y > pos.y + viewSize.height) then
	        		return false
	        	end
	        end

	        self.fsm_:doEvent("press")
	        self:onEvent("press")
	        if (0 == self.pressDelay) then
		        Eca.dispatchEvent(ECA.PreButtonPress, self.name, { name = self.name, x = x, y = y, })
		        self:dispatchEvent({name = UIButton.PRESSED_EVENT, x = x, y = y, touchInTarget = true})
		        Eca.dispatchEvent(ECA.AfterButtonPress, self.name, { name = self.name, x = x, y = y, })

		        if (self.skipClick) then
					self.skipClickFlag = true
				end
	        else
	        	self.pressHandler = scheduler.performWithDelayGlobal(function()
	        			Eca.dispatchEvent(ECA.PreButtonPress, self.name, { name = self.name, x = x, y = y, })
				        self:dispatchEvent({name = UIButton.PRESSED_EVENT, x = x, y = y, touchInTarget = true})
				        Eca.dispatchEvent(ECA.AfterButtonPress, self.name, { name = self.name, x = x, y = y, })

				        if (self.skipClick) then
							self.skipClickFlag = true
						end

				        self.pressHandler = nil
	        		end, self.pressDelay)
	        end
	        
	        self.pressX = x
	        self.pressY = y
	        self.optState = self.OPTSTATE_CLICK
	        if (self.dragParent and self.moveParent) then
	        	self.dragParent:onTouch_(event, x, y)
	        end
	        
	        return true
	    end

	    local touchInTarget = self:checkTouchInSprite_(x, y)
	    if event == "moved" then
	        if touchInTarget and self.fsm_:canDoEvent("press") then
	            self.fsm_:doEvent("press")
	            self:onEvent("press")
	            Eca.dispatchEvent(ECA.PreButtonPress, self.name, { name = self.name, x = x, y = y, })
	            self:dispatchEvent({name = UIButton.PRESSED_EVENT, x = x, y = y, touchInTarget = true})
	            Eca.dispatchEvent(ECA.AfterButtonPress, self.name, { name = self.name, x = x, y = y, })

	            if (self.skipClick) then
					self.skipClickFlag = true
				end
	        elseif not touchInTarget and self.fsm_:canDoEvent("release") then
	        	if (nil ~= self.pressHandler) then
					scheduler.unscheduleGlobal(self.pressHandler)
					self.pressHandler = nil
				end
				self.skipClickFlag = false

	            self.fsm_:doEvent("release")
	            self:onEvent("release")
	            Eca.dispatchEvent(ECA.PreButtonRelease, self.name, { name = self.name, x = x, y = y, })
	            self:dispatchEvent({name = UIButton.RELEASE_EVENT, x = x, y = y, touchInTarget = false})
	            Eca.dispatchEvent(ECA.AfterButtonRelease, self.name, { name = self.name, x = x, y = y, })
	        end

	        if (self.OPTSTATE_CLICK == self.optState) then
	            local dist = self:calcDragDist(x - self.pressX, y - self.pressY)
	            if (self.content and dist >= 5) then
	                self.optState = self.OPTSTATE_DRAG
	                self.touchID = touchID
	                if (self.dragParent and not self.moveParent) then
	                    -- 这个用来阻断ScrollView的移动
	                    self.dragParent:stopMove()
	                end
	                Eca.dispatchEvent(ECA.PreDragOut, self.name, { name = self.name, x = x, y = y, })
	                self:dispatchEvent({name = self.DRAGOUT_EVENT, x = x, y = y, touchInTarget = false})
	                Eca.dispatchEvent(ECA.AfterDragOut, self.name, { name = self.name, x = x, y = y, })
	            else
	                dist = self:calcMoveDist(x - self.pressX, y - self.pressY)
	                if (dist >= 5 and self.dragParent) then
	                    if (self.moveParent) then
	                        self.dragParent:onTouch_(event, x, y)
	                    end
	                    self.optState = self.OPTSTATE_MOVE
	                end
	            end
	        elseif (self.OPTSTATE_MOVE == self.optState) then
	            if (self.dragParent and self.moveParent) then
	                self.dragParent:onTouch_(event, x, y)
	            end
	        elseif (self.OPTSTATE_DRAG == self.optState) then
	            HDDragHandler.onContentMove(x, y)
	        end
	    else
	        self.touchID = -1
	        if self.fsm_:canDoEvent("release") then
	        	if (nil ~= self.pressHandler) then
					scheduler.unscheduleGlobal(self.pressHandler)
					self.pressHandler = nil
				end

	            self.fsm_:doEvent("release")
	            self:onEvent("release")
	            Eca.dispatchEvent(ECA.PreButtonRelease, self.name, { name = self.name, x = x, y = y, })
	            self:dispatchEvent({name = UIButton.RELEASE_EVENT, x = x, y = y, touchInTarget = touchInTarget})
	            Eca.dispatchEvent(ECA.AfterButtonRelease, self.name, { name = self.name, x = x, y = y, })
	        end
	        if event == "ended" then
	            if (touchInTarget and self.OPTSTATE_CLICK == self.optState) then
	            	if (self.skipClickFlag) then
	            		self.skipClickFlag = false
	            	else
		                self:onClickXP()
		                HDAudioPlayEffect("audio/ButtonClick.mp3")
		                Eca.dispatchEvent(ECA.PreButtonClick, self.name, { name = self.name, x = x, y = y, })
		                self:dispatchEvent({name = UIButton.CLICKED_EVENT, x = x, y = y, touchInTarget = true})
		                Eca.dispatchEvent(ECA.AfterButtonClick, self.name, { name = self.name, x = x, y = y, })
		            end
	            end
	            if (self.dragParent and self.moveParent) then
	                self.dragParent:onTouch_(event, x, y)
	            end
	        end
	    end

	    if ("beganfake" == event) then
	        -- 有拖出物在自己头上松手了
	        self.inDragIn = true
			self.processDragIn = false
			Eca.dispatchEvent(ECA.PreDragIn, self.name, { name = self.name, x = x, y = y, })
	        self:dispatchEvent({name = self.DRAGIN_EVENT, x = x, y = y, touchInTarget = true})
	        Eca.dispatchEvent(ECA.AfterDragIn, self.name, { name = self.name, x = x, y = y, })
	        if (true == self.processDragIn) then
	        	return kCCTouchBegan
	        else
	        	return kCCTouchIgnore
	        end
	    end

	    if ("endedfake" == event) then
	        -- 从自己拖出的东西，松手了没人要
	        Eca.dispatchEvent(ECA.PreDragCancel, self.name, { name = self.name, x = x, y = y, })
	        self:getBackContent()
	        Eca.dispatchEvent(ECA.AfterDragCancel, self.name, { name = self.name, x = x, y = y, })
	    end

	end

	function object:findDragParent()

	    local parent = self:getParent()
	    while (parent) do
	        if (parent.getDragAngle) then
	            return parent, parent:getDragAngle()
	        else
	            parent = parent:getParent()
	        end
	    end

	end

	function object:findScrollParent()

	    local parent = self:getParent()
	    while (parent) do
	        if (parent.iAmScrollView) then
	            return parent
	        else
	            parent = parent:getParent()
	        end
	    end

	end

	function object:calcMoveDist(x, y)

	    if (nil == self.dragParent or nil == self.dragAngle) then
	        return 0
	    end

	    if (-1 == self.dragAngle) then
	        return math.sqrt(x * x + y * y)
	    else
	        local x0 = math.cos(math.rad(self.dragAngle))
	        local y0 = math.sin(math.rad(self.dragAngle))
	        return math.abs(x0 * x + y0 * y)
	    end

	end

	function object:calcDragDist(x, y)

	    if (nil ~= self.dragParent) then
	    	if (nil == self.dragAngle) then
		        return 0
		    elseif (-1 == self.dragAngle) then
		        return math.sqrt(x * x + y * y)
		    else
		        local angle = self.dragAngle + 90
		        local x0 = math.cos(math.rad(angle))
		        local y0 = math.sin(math.rad(angle))
		        return math.abs(x0 * x + y0 * y)
		    end
		else
			return math.sqrt(x * x + y * y)
		end

	end

	function object:setContent(content)

	    if (self.content) then
	        self:removeChild(self.content)
	        self.content = nil
	    end

	    if (content) then
		    self.content = content
		    self:addChild(self.content)
		    self.content:setPosition(0, 0)
		    self.content:setContainer(self)
	    end

	end

	function object:getContent()

		return self.content
		
	end

	function object:dragOutContent()

	    if (self.content) then
	        self:registDrag(self.touchID)

	        if (self.dragCopy) then
	            local newcontent = require("UI.HDContent").new(clone(self.content:getParams()))
	            local x = self.content:getPositionX()
	            local y = self.content:getPositionY()
	            local coord = self:convertToWorldSpace(ccp(x, y))
	            newcontent:setPosition(coord.x, coord.y)
	            HDDragHandler.onContentDragOut(newcontent)
	        else
	            HDDragHandler.onContentDragOut(self.content)
	            self.content = nil
	        end
	    end

	end

	function object:dragInContent()

		HDDragHandler.onContentDragIn(self)
		if (self.inDragIn) then
			self.processDragIn = true
	    end

	end

	function object:switchContent()

		local content = HDDragHandler.getContent()
		local container = nil
		if (content) then
			container = content:getContainer()
		end

		if (self.content and container) then
			self.content:retain()
			self:removeChild(self.content, false)
			container:setContent(self.content)
			self.content:release()
		end
	    self:dragInContent()

	end

	function object:getBackContent()

	    if (not self.conetent) then
	        HDDragHandler.onContentDragIn(self)
	    end
	    if (self.inDragIn) then
			self.processDragIn = true
	    end

	end

	function object:onEvent(event)

		if (self.eventActParam and self.eventActParam[event]) then
			local action = ActionBuilder.build(self.eventActParam[event])
	    	self:runAction(action)
		end

	end

	return object

end

return XButtonExtend