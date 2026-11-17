--[[
高性能list构造器
]]

local HighPerformList = {}
local updateInterval = 1.0/24.0
local debugprint = false
local scheduleHandlerTable = {}
local listUpdateHandler = nil
local function getItemPositionYInView(item,list)
    local x,y = item:getPosition()
    local worldPos = item:getParent():convertToWorldSpaceAR(cc.p(x,y));
    local viewPos = list:convertToNodeSpaceAR(worldPos);
    return viewPos.y;
end

local function getItemPositionXInView(item,list)
    local x,y = item:getPosition()
    local worldPos = item:getParent():convertToWorldSpaceAR(cc.p(x,y));
    local viewPos = list:convertToNodeSpaceAR(worldPos);
    return viewPos.x;
end

local scheduler = require("src.framework.scheduler")
--------------------------------
-- 高性能垂直滚动列表控件
-- @function HighPerformList.makeHighPerFormLst
-- @param UIListView list 需要转成高性能列表的列表
-- @param int spwanCount 基础数据的列表行数
-- @param int spacing 列表上下间距，没有则填0
-- @param int countPerLine 每行的列表显示数量
-- @param int bufferZone 列表替换的缓冲区域，一定要比单行列表高一些
-- @param int listCellHeight 列表高度
-- @param array datalist 数据列表数组
-- @param function callback 列表元素更新时的回调函数，会传递item和替换数据的下标
function HighPerformList.makeHighPerFormVerticalList(list1,spawnCount,spacing,countPerLine,bufferZone,listcellHeight,datalist,callback)
    local allnum = #datalist
    list1.totalcount = math.floor(allnum/countPerLine)
    list1.totalheight = 0
    list1.reuseItemOffset = 0
    list1.timeTick = 0
    list1.lastContentPosY = 0
    if allnum%countPerLine > 0 then list1.totalcount = list1.totalcount+1 end
	
	local function initListItemIndex()
        local items = list1:getItems()
        --print("list1:getItems。。。。。。"..#items)
		for i = 1,#items do 
			items[i].highperformIndex = 1+(i-1)*countPerLine
		end
	end
	
    local function resizeInnerHeight()
        if list1.totalcount > 0 then 
            list1.totalheight = listcellHeight * list1.totalcount + (list1.totalcount-1)*spacing;
            list1.reuseItemOffset = (listcellHeight + spacing) * (spawnCount);
            local size = list1:getInnerContainerSize()
            --print("before setInnerSize height:"..size.height)
            size.height = list1.totalheight

            -- list1:forceDoLayout()
            list1:requestRefreshView()
            list1:doLayout()
            list1:setInnerContainerSize({width = size.width,height = list1.totalheight})
            --print("after setInnerSize height:"..size.height)
            -- print("total height,resueItemOffset,listcellheight"..size.height,reuseItemOffset,listcellHeight)
            list1:jumpToTop()
        end
    end
    
    local function updateItem(item,isdown,countperline,spawncount,showlist) 
		local index = item.highperformIndex
		local currentindex = 0
		if item.highperformIndex == nil then return end
		
		if isdown then --如果是向下滑
			currentindex = item.highperformIndex - spawncount*countPerLine
			if debugprint then 
				print("isdown true item.index:"..item.highperformIndex,currentindex)
			end
			
		else --向上滑
			currentindex = item.highperformIndex + spawncount*countPerLine
			if debugprint then
				print("isdown false item.index:"..item.highperformIndex,currentindex)
			end
		end
		
		if currentindex >  0 then
			--local cellindex = (item.index)%countperline
		   item.highperformIndex = currentindex
		   
		   callback(item,currentindex)
			--print("currentindex,cellindex",currentindex,cellindex)
			--BattleFuncMgr.startCreatePetHandBookData(pokemonInfoLst[currentindex],item.element[cellindex])
		end	
	end
    --注册全局事件   
    local function registerCheckFunc()
        list1.timeTick = os.clock()
        
        if listUpdateHandler~= nil then 
            --print("list1..... is not nil"..list1.listUpdateHandler)
            scheduler.unscheduleGlobal(listUpdateHandler)
            listUpdateHandler = nil
            
		else
			--print("list1..... is nil")
        end
        HighPerformList.resetAllSchedule()
        listUpdateHandler = scheduler.scheduleUpdateGlobal(function() 
            --print("xxxxx"..list1.timeTick)
            if list1.timeTick == nil then
                if listUpdateHandler~= nil then 
                    scheduler.unscheduleGlobal(listUpdateHandler)
                    listUpdateHandler = nil
                end
                
                return
            end
            
            local deltaTime = os.clock() - list1.timeTick
           
            if deltaTime < updateInterval then return end
            list1.timeTick = os.clock()
            local container = (list1:getInnerContainer())
            local pos1,pos2 = container:getPosition()
            local listviewheight = list1:getContentSize().height
            local isDown = false
            if pos2 -list1.lastContentPosY<0 then isDown = true end
            if list1.lastContentPosY~=-1 then
                local cnt = #datalist
                if cnt > spawnCount then 
                    cnt = spawnCount
                end

                for i = 1 ,cnt do
                    if i > list1.totalcount then break end
                    local item = list1:getItem(i-1)
                    if item ~= nil then 
                        local itemPos = getItemPositionYInView(item,list1);
                        local x,y = item:getPosition()
                        if isDown then 
                            if  itemPos < -bufferZone and y + list1.reuseItemOffset < list1.totalheight then
                                item:setPositionY(item:getPositionY() + list1.reuseItemOffset)
    
    							
                                updateItem(item,isDown,countPerLine,spawnCount,datalist)                   
                            end
    
                            --this->updateItem(itemID, i);
                        else 
                            if  itemPos > bufferZone + listviewheight and y - list1.reuseItemOffset >= 0 then
                                --print("item index, posy,reuseitemoffset"..item:getPositionY(),reuseItemOffset)
                                item:setPositionY(item:getPositionY() - list1.reuseItemOffset)
                                updateItem(item,isDown,countPerLine,spawnCount,datalist) 
    
                            end
    
                        end
                    end
                end
            end
           -- print("inery postion y is:"..pos2)
            container = (list1:getInnerContainer())
            pos1,pos2 = container:getPosition()
            list1.lastContentPosY = pos2
        end) 
        table.insert(scheduleHandlerTable,listUpdateHandler)   
    end

    initListItemIndex()
    resizeInnerHeight()
    registerCheckFunc()
end

function HighPerformList.makeHighPerFormHorizontalList(list1,spawnCount,spacing,countPerLine,bufferZone,listcellWidth,datalist,callback)
    local allnum = #datalist
    list1.totalcount = math.floor(allnum/countPerLine)
    list1.totalwidth = 0
    list1.reuseItemOffset = 0
    list1.timeTick = 0
    list1.lastContentPosX = 0
    if allnum%countPerLine > 0 then list1.totalcount = list1.totalcount+1 end

    local function initListItemIndex()
        local items = list1:getItems()
        --print("list1:getItems。。。。。。"..#items)
        for i = 1,#items do 
            items[i].highperformIndex = 1+(i-1)*countPerLine
        end
    end

    local function resizeInnerWidth()
        if list1.totalcount > 0 then 
            list1.totalwidth = listcellWidth * list1.totalcount + (list1.totalcount-1)*spacing;
            list1.reuseItemOffset = (listcellWidth + spacing) * (spawnCount);
            local size = list1:getInnerContainerSize()
            --print("before setInnerSize height:"..size.height)
            size.width = list1.totalwidth

            -- list1:forceDoLayout()
            list1:requestRefreshView()
            list1:doLayout()
            list1:setInnerContainerSize({width = list1.totalwidth,height = list1:getContentSize().height})
            --print("after setInnerSize width:"..size.width)
            -- print("total height,resueItemOffset,listcellheight"..size.height,reuseItemOffset,listcellHeight)
            list1:jumpToLeft()
        end
    end

    local function updateItem(item,isRight,countperline,spawncount,showlist) 
        local index = item.highperformIndex
        local currentindex = 0
        if item.highperformIndex == nil then return end

        if isRight then --如果是向右滑
            currentindex = item.highperformIndex - spawncount*countPerLine
            if debugprint then 
                print("isRight true item.index:"..item.highperformIndex,currentindex)
            end

        else --向左滑
            currentindex = item.highperformIndex + spawncount*countPerLine
            if debugprint then
                print("isRight false item.index:"..item.highperformIndex,currentindex)
            end
        end

        if currentindex >  0 then
            --local cellindex = (item.index)%countperline
            item.highperformIndex = currentindex

            callback(item,currentindex)
            --print("currentindex,cellindex",currentindex,cellindex)
            --BattleFuncMgr.startCreatePetHandBookData(pokemonInfoLst[currentindex],item.element[cellindex])
        end 
    end
    --注册全局事件   
    local function registerCheckFunc()
        list1.timeTick = os.clock()

        if listUpdateHandler~= nil then 
            --print("list1..... is not nil"..list1.listUpdateHandler)
            scheduler.unscheduleGlobal(listUpdateHandler)
            listUpdateHandler = nil

        else
        --print("list1..... is nil")
        end
        HighPerformList.resetAllSchedule()
        listUpdateHandler = scheduler.scheduleUpdateGlobal(function() 
            --print("xxxxx"..list1.timeTick)
            if list1.timeTick == nil then
                if listUpdateHandler~= nil then 
                    scheduler.unscheduleGlobal(listUpdateHandler)
                    listUpdateHandler = nil
                end

                return
            end

            local deltaTime = os.clock() - list1.timeTick

            if deltaTime < updateInterval then return end
            list1.timeTick = os.clock()
            local container = (list1:getInnerContainer())
            local pos1,pos2 = container:getPosition()
            local listviewwidth = list1:getContentSize().width
            local isRight = false
            if pos1 -list1.lastContentPosX>0 then isRight = true end
            --print("list1.lastContentPosX=",list1.lastContentPosX)
            if list1.lastContentPosX~=-1 then
                local cnt = #datalist
                if cnt > spawnCount then 
                    cnt = spawnCount
                end

                for i = 1 ,cnt do
                    if i > list1.totalcount then break end
                    local item = list1:getItem(i-1)
                    if item ~= nil then 
                        local itemPos = getItemPositionXInView(item,list1);
                        local x,y = item:getPosition()
                        if isRight then 
                            if  itemPos > bufferZone + listviewwidth and x - list1.reuseItemOffset >= 0 then
                                item:setPositionX(item:getPositionX() - list1.reuseItemOffset)


                                updateItem(item,isRight,countPerLine,spawnCount,datalist)                   
                            end

                            --this->updateItem(itemID, i);
                        else 
                            --print("itemPos=",itemPos,bufferZone + listviewwidth,x - list1.reuseItemOffset)
                            if  itemPos < -bufferZone and x + list1.reuseItemOffset < list1.totalwidth then
                                --print("item index, posy,reuseitemoffset"..item:getPositionY(),reuseItemOffset)
                                item:setPositionX(item:getPositionX() + list1.reuseItemOffset)
                                updateItem(item,isRight,countPerLine,spawnCount,datalist) 

                            end

                        end
                    end
                end
            end
            -- print("inery postion y is:"..pos2)
            container = (list1:getInnerContainer())
            pos1,pos2 = container:getPosition()
            list1.lastContentPosX = pos1
        end) 
        table.insert(scheduleHandlerTable,listUpdateHandler)   
    end

    initListItemIndex()
    resizeInnerWidth()
    registerCheckFunc()
end

--------------------------------
-- 高性能控件重置
function HighPerformList.resetHighPerFormList(list)
    --print("list.listUpdateHandler"..list.listUpdateHandler)
    if list.listUpdateHandler~=nil then 
        scheduler.unscheduleGlobal(list.listUpdateHandler)
        list.listUpdateHandler = nil
    end
    list:removeAllItems()

    
end

--------------------------------
-- 初始化
function HighPerformList.Init()
    HighPerformList.resetAllSchedule()
end

function HighPerformList.resetAllSchedule()
    print("resetAllSchedule............."..#scheduleHandlerTable)

    for i = 1,#scheduleHandlerTable do 
        if scheduleHandlerTable[i]~=nil then 
            print("handler is not null.....................")
            scheduler.unscheduleGlobal(scheduleHandlerTable[i])
            scheduleHandlerTable[i] = nil
        else 
            print("handler is null.....................")
        end
 
    end
    scheduleHandlerTable = {}
end

return HighPerformList