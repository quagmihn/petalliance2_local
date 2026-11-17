local CommonList = {}

---csb元件命名规则：
--列表拖动提示label命名dragtip，子元件箭头命名dir
--列表加载提示label命名loadtip，子元件菊花圈命名hud
--
--@param contentTable table 列表内容
--@param resName string csb资源名
--@param listName string list元件名字
--@param resNameTag string tag名，默认为空
--@param showSize int 单次加载项数，默认为10
--@param sensor int 顶部和底部拉扯灵敏度，默认为1
--@param loadItemFunc function 加载项回调函数带参数id和var包含列表单项内容信息，请返回列表单项元素node
--@param refreshItemFunc function 请求刷新列表函数，带参数callback请完成后调用
--@param requestItemFunc function 请求加载更多函数，带参数callback请完成后调用
--
--@return #table 返回内容
--object.getContent()
--object.setContent()
--object.refreshFinished()
--object.requestFinished()
function CommonList.new(params)
	local object = {}
	
	params = params or {}
	
    params.contentTable = params.contentTable or {}
    params.resName = params.resName or ""
    params.resNameTag = params.resNameTag or ""
    params.sensor = params.sensor or 1
    params.showSize = params.showSize or 10
    params.loadItemFunc = params.loadItemFunc or function(id, var)
    	return nil
    end
    params.requestItemFunc = params.requestItemFunc or function()
    end
    params.refreshItemFunc = params.refreshItemFunc or function()
    end
    params.list = CSResourceMgr.getNodeByName(params.resName, params.listName, params.resNameTag)
    if not params.list then
        print("列表为nil")
        return
    end
	
    local tipsStr = {
        LuaSqlite.getLanguageByKey("tips6"), 
        LuaSqlite.getLanguageByKey("tips7"), 
        LuaSqlite.getLanguageByKey("tips8"), 
        LuaSqlite.getLanguageByKey("tips9"), 
        LuaSqlite.getLanguageByKey("tips10"),
    }
    local tipsTag = 23333
    local tipDragTag = "dragtip"
    local dirTag = "dir"
    local tipLoadTag = "loadtip"
    local hudTag = "hud"
    
    local wantUpdateMore = false
    local wantLoadMore = false
    local isUpdatingMore = false
    local isLoadingMore = false
    local canUpdateMore = true
    local canLoadMore = true
    local listSensor = 0
    local preEventType = -1
    local curListMaxNum = 0
    local curListTopState = -1
    local curListBottomState = -1
	
    local contentTable = params.contentTable
    
    CSResourceMgr.setLabelString(params.resName, tipDragTag, "", params.resNameTag, CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
    
    local function checkListValid()
    	local ret, errMessage = pcall(function()
            local tmpVal = params.list:getItemsMargin()
        end)
    	return ret
    end
    
    local function setListTopTip(string, state)
        if not checkListValid() then
        	return false
        end
        if curListMaxNum>0 and not isUpdatingMore and curListTopState~=state then
            curListTopState = state
            local tipLabel = params.list:getItem(0):getChildByTag(tipsTag)
            if tipLabel~=nil then
                tipLabel:setString(string)
                local arrow = tipLabel:getChildByName(dirTag)
                local posy = tipLabel:getContentSize().height/2
                arrow:setPositionY(posy)
                if state==0 then
                    arrow:setVisible(false)
                elseif state==1 then
                    arrow:setVisible(true)
                    arrow:setRotation(0)
                elseif state==2 then
                    arrow:setVisible(true)
                    arrow:setRotation(180)
                end
                return true
            end
        end
        return false
    end

    local function setListBottomTip(string, state)
        if not checkListValid() then
            return false
        end
        if curListMaxNum>0 and curListBottomState~=state then
            curListBottomState = state
            local tipLabel = params.list:getItem(curListMaxNum-1):getChildByTag(tipsTag)
            if tipLabel~=nil then
                local arrow = tipLabel:getChildByName(dirTag)
                arrow:setVisible(false)
                tipLabel:setString("")
                if #object.getContent()>=params.showSize and not isLoadingMore then
                    tipLabel:setString(string)
                    local posy = tipLabel:getContentSize().height/2
                    arrow:setPositionY(posy)
                    if state==0 then
                        arrow:setVisible(false)
                    elseif state==1 then
                        arrow:setVisible(true)
                        arrow:setRotation(0)
                    elseif state==2 then
                        arrow:setVisible(true)
                        arrow:setRotation(180)
                    end
                    return true
                else
                    return false
                end
            end
        end
        return false
    end
    
    local function loadItem(fromN, toN)
        if not checkListValid() then
            return
        end
        if toN>#object.getContent() then
            toN = #object.getContent()
        end
        local funcTable = {}
        for i=fromN, toN do
            local function loadListItem()
                local itemObj = params.loadItemFunc(i, object.getContent()[i])
                curListMaxNum = i
                if itemObj then
                    local lsize = params.list:getInnerContainerSize()
                    if i==1 then
                        local tip = CSResourceMgr.getNodeByName(params.resName, tipDragTag, params.resNameTag):clone()
                        local size = itemObj:getContentSize()
                        itemObj:addChild(tip, 0, tipsTag)
                        tip:setPosition(lsize.width/2, size.height+20)
                    elseif i==toN then
                        local tip = CSResourceMgr.getNodeByName(params.resName, tipDragTag, params.resNameTag):clone()
                        tip:setVisible(true)
                        itemObj:addChild(tip, 0, tipsTag)
                        tip:setPosition(lsize.width/2, -20)
                    end
                end
            end
            table.insert(funcTable, loadListItem)
            --loadListItem()
        end

        local function finish()
            isUpdatingMore = false
            isLoadingMore = false
            local tipNode = params.list:getItem(0)
            if tipNode then
                tipNode:getChildByTag(tipsTag):setVisible(true)
            end
        end
        table.insert(funcTable, finish)
        --finish()

        UnblockLoader.load(funcTable, "CommonList-LoadItem"..params.resName..params.resNameTag..params.listName)
    end
    
    ---列表刷新请求成功，开始刷新列表（不需要外部调用）
    local function updateMore()
        if not checkListValid() then
            return false
        end
        if not canUpdateMore then
            return false
        end
        --如果请求完成了，Table更新了，就走下面这段话
        params.list:removeAllItems()
        local maxLoadSize = params.showSize
        if maxLoadSize>#object.getContent() then
            maxLoadSize = #object.getContent()
            curListMaxNum = maxLoadSize
        end
        loadItem(1, maxLoadSize)
    end
    
    ---发送列表刷新请求（不需要外部调用）
    local function updateMoreRequest()
        if not checkListValid() then
            return false
        end
        setListTopTip("", 0)
        if isUpdatingMore or not wantUpdateMore or isLoadingMore then
            return false
        end
        isUpdatingMore = true
        canUpdateMore = false
        CSResourceMgr.setLabelString(params.resName, tipLoadTag, tipsStr[4], params.resNameTag, CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        local label = CSResourceMgr.getNodeByName(params.resName, tipLoadTag, params.resNameTag):clone()
        label:setVisible(true)
        local hud = label:getChildByName(hudTag)
        local ani = cc.RepeatForever:create(cc.RotateBy:create(1.5, 180))
        local posy = label:getContentSize().height/2
        hud:setPositionY(posy)
        hud:runAction(ani)
        params.list:insertCustomItem(label, 0)
        --发服务器请求，我先假装1秒后收到回复
        --[[
        params.list:performWithDelay(function()
            canUpdateMore = true
            updateMore()
        end, 1.5)
        --]]
        params.refreshItemFunc(object.refreshFinished)
    end
    
    function object.refreshFinished()
        canUpdateMore = true
        updateMore()
    end
    
    ---加载更多请求成功，开始刷新列表（不需要外部调用）
    local function loadMore()
        if not checkListValid() then
            return false
        end
        if not canLoadMore then
            return false
        end
        --如果请求完成了，MailTable更新了，就走下面这段话
        params.list:removeItem(curListMaxNum)
        loadItem(curListMaxNum+1, curListMaxNum+params.showSize)
    end

    ---发送加载更多请求（不需要外部调用）
    local function loadMoreRequest()
        if not checkListValid() then
            return false
        end
        if setListBottomTip("", 0)==false then
            print("no more load...")
            return false
        end
        if isLoadingMore or not wantLoadMore or isUpdatingMore or curListMaxNum==0 or #object.getContent()<params.showSize then
            return false
        end
        isLoadingMore = true
        canLoadMore = false
        params.list:getItem(curListMaxNum-1):removeChildByTag(tipsTag, true)
        CSResourceMgr.setLabelString(params.resName, tipLoadTag, tipsStr[5], params.resNameTag, CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        local label = CSResourceMgr.getNodeByName(params.resName, tipLoadTag, params.resNameTag):clone()
        label:setVisible(true)
        local hud = label:getChildByName(hudTag)
        local ani = cc.RepeatForever:create(cc.RotateBy:create(1.5, 180))
        local posy = label:getContentSize().height/2
        hud:setPositionY(posy)
        hud:runAction(ani)
        params.list:pushBackCustomItem(label)
        label:performWithDelay(function()
            params.list:jumpToBottom()
        end, 0.2)
        --发服务器请求，我先假装1秒后收到回复
        --[[
        params.list:performWithDelay(function()
            canLoadMore = true
            loadMore()
        end, 1.5)
        --]]
        params.requestItemFunc(object.requestFinished)
    end
    
    function object.requestFinished()
        canLoadMore = true
        loadMore()
    end
    
    params.list:addScrollViewEventListener(function(sender, eventType)
        if eventType==1 then
            --拖动到底
            if listSensor>params.sensor then
                wantLoadMore = true
                if not isLoadingMore then
                    setListBottomTip(tipsStr[3], 1)
                end
            end
        elseif eventType==6 then
            --反弹到底
            loadMoreRequest()
            wantLoadMore = false
        elseif eventType==0 then
            --拖动到顶
            if listSensor>params.sensor then
                wantUpdateMore = true
                if not isUpdatingMore then
                    setListTopTip(tipsStr[3], 2)
                end
            end
        elseif eventType==5 then
            --反弹到顶
            updateMoreRequest()
            wantUpdateMore = false
        elseif eventType==4 then
            --在滚动中
            if preEventType==0 and listSensor<=params.sensor then
                listSensor = listSensor+1
            elseif preEventType==1 and listSensor<=params.sensor then
                listSensor = listSensor+1
            elseif preEventType==4 then
                listSensor = 0
                setListBottomTip(tipsStr[1], 2)
                setListTopTip(tipsStr[2], 1)
                wantLoadMore = false
                wantUpdateMore = false
            end
        end
        preEventType = eventType
    end)
    
    function object.setContent(params)
        print("重置列表内容")
        contentTable = params
        print(#object.getContent())
    end
    
    function object.getContent()
        return contentTable
    end
    
    wantUpdateMore = true
    updateMoreRequest()
		
	return object
end

return CommonList