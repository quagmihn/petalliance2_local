local DungeonTestMapMgr = {}

local resName = "CommonDungeon/testMenu.csb"

DungeonTestMapMgr.xmlStartID = 1

local TEST_MAP_EDIT = 1
local TEST_RUN_MAP  = 2

local eventList = {
    [LtEventOption.EVENT_VOID]          = "空事件",
    [LtEventOption.EVENT_PICKING]       = "拾取道具",
    [LtEventOption.EVENT_MONSTER]       = "战斗",
    [LtEventOption.EVENT_OBSTRUCTION]   = "障碍物",
    [LtEventOption.EVENT_EXIT]          = "出口",
--    [LtEventOption.EVENT_ENTERANCE]     = "入口事件",
    [LtEventOption.EVENT_SWITCH]        = "机关",
    [LtEventOption.EVENT_PORTAL]        = "传送门",
    [LtEventOption.EVENT_TRAINER]       = "训练师",
--    [LtEventOption.EVENT_BUFF]          = "属性变化",
--    [LtEventOption.EVENT_RANDOMBOX]     = "随机宝箱",
--    [LtEventOption.EVENT_HEALPOINT]     = "恢复点",
--    [LtEventOption.EVENT_SPECIAL]       = "特殊效果",
--    [LtEventOption.EVENT_NPC]           = "稀有NPC",
--    [LtEventOption.EVENT_RANDOM]        = "随机事件",
--    [LtEventOption.EVENT_C_AWARDS]      = "固定奖励",
--    [LtEventOption.EVENT_OTHERTRAINER]  = "PVP战斗",
--    [LtEventOption.EVENT_LTBOSS]        = "boss战斗",
--    [LtEventOption.EVENT_TRAP]          = "陷阱",
--    [LtEventOption.EVENT_COLLECTION]    = "采集",
    [LtEventOption.EVENT_BILLBOARD]     = "告示板",
--    [LtEventOption.EVENT_DISPOSABLE]    = "一次性事件",
    [LtEventOption.EVENT_ADV_NPC]       = "事件npc",
}

local currentEvent = {index = -1, eventID = 0}
local currentType  = {index = -1, typeID  = 0}

local eventListButton = {}
local subListButton   = {}

local selectBlocks  = {}
local selectCircles = {}

local currentSingleSelect = 0
local singleSelectCircle = nil
local cellTargets = {}

local mapInfo = {
    event   = {},
    subType = {},
}

function DungeonTestMapMgr.init()
    for i = 1, LtMapOption.getMapSize() do
        mapInfo["event"][i] = 0
        mapInfo["subType"][i] = 0
    end
end

local lines = {}

local function drawLine(x1, y1, x2, y2)
    local scrollview = SearchingUIMgr.getBlockContainer()
    local quarLB = cc.p(x1, y1)
    local quarRT = cc.p(x2, y2)
    local dnode = cc.DrawNode:create()
    scrollview:addChild(dnode)
    dnode:drawSegment(quarLB, quarRT, 4, cc.c4f(1, 0, 0, 1))
    dnode:drawDot(quarRT,10,cc.c4f(1, 1, 0, 1))
    table.insert(lines,dnode)
end

local function clearLines()
    for i, v in pairs(lines) do
        pcall(function() lines[i]:removeFromParent() end)
        lines[i] = nil
    end
    lines = {}
end

local clickFuncs = {
    ["edit_select"] = function(i)
        local _b = SearchingUIMgr.getBlockNode(i)
        if selectBlocks[i] then
            selectBlocks[i] = false
            if selectCircles[i] then 
                selectCircles[i]:removeFromParent()
                selectCircles[i] = nil
            end
        else
            local circle = CSResourceMgr.getNodeByName("CommonDungeon/testMenu.csb","select_circle"):clone()
            _b:addChild(circle)
            circle:setScale(1.1)
            circle:setPosition(52, 52)
            selectCircles[i] = circle

            selectBlocks[i] = true
        end
    end,
    ["single_select"] = function(i)
        if currentSingleSelect == i then return end
        
        local _b = SearchingUIMgr.getBlockNode(i)
        
        -- clear
        for i, v in pairs(selectBlocks) do
            if selectBlocks[i] then
                selectBlocks[i] = false
                if selectCircles[i] then 
                    pcall(function() selectCircles[i]:removeFromParent() end)
                    selectCircles[i] = nil
                end
            end
        end
        
        if singleSelectCircle then pcall(function() singleSelectCircle:removeFromParent() end) end
        singleSelectCircle = CSResourceMgr.getNodeByName("CommonDungeon/testMenu.csb","select_circle"):clone()
        _b:addChild(singleSelectCircle)
        singleSelectCircle:setScale(1.1)
        singleSelectCircle:setPosition(52, 52)
        singleSelectCircle:setColor({r=200,g=0,b=0,a=255})
        currentSingleSelect = i
        
        DungeonTestMapMgr.addSubMenu()
    end,
    ["single_select_2"] = function(i)
        if not currentSingleSelect then return end
        
        local x1,y1 = SearchingUIMgr.getBlockNode(currentSingleSelect):getPosition()
        local x2,y2 = SearchingUIMgr.getBlockNode(i):getPosition()
        drawLine(x1,y1,x2,y2)
    end,
    ["test_map"] = function(i)
        print(i)
    end,
}

function DungeonTestMapMgr.reBindBlock(op, except)
    except = except or 0
    for i = 1, LtMapOption.getMapSize() do
        if i ~= except then
            local _b = SearchingUIMgr.getBlockNode(i)
            local char = AdvCharMgr.getTrainerByPos(i)
            if char then
                CSResourceMgr.clickEventBindingByNode(char.info.node,function()
                    clickFuncs[op](i)
                end)
            end
            CSResourceMgr.clickEventBindingByNode(_b,function()
                clickFuncs[op](i)
            end)
        end
    end
end

local function getSubList(eventID)
    local Readers = LtEventOption.getTxtData()
    
    local ret

    if eventID == SearchingMapMgr.EVENT_VOID then
        ret = clone(Readers.itemsInfo.content)
    end
    if eventID == SearchingMapMgr.EVENT_PICKING then
        ret = clone(Readers.fbpickupInfo.content)
    end
    if eventID == SearchingMapMgr.EVENT_MONSTER then
        ret = {}
        local MonstrosityInfoConfig = require("src.DatReader.MonstrosityInfoConfig")
        for var = 1, MonstrosityInfoConfig.getEntryCount() do
            local id = MonstrosityInfoConfig.getEntryID(var)
            local data = MonstrosityInfoConfig.readEntryByID(id)
            table.insert(ret, data)
        end
    end
    if eventID == SearchingMapMgr.EVENT_TRAINER then
        ret = {}
        local MonsterGroupManInfoConfig = require("src.DatReader.MonsterGroupManInfoConfig")
        for var = 1, MonsterGroupManInfoConfig.getEntryCount() do
            local id = MonsterGroupManInfoConfig.getEntryID(var)
            local data = MonsterGroupManInfoConfig.readEntryByID(id)
            table.insert(ret, data)
        end
    end
    if eventID == SearchingMapMgr.EVENT_SWITCH then
        ret = clone(Readers.switchInfo.content)
    end
    if eventID == SearchingMapMgr.EVENT_PORTAL then
        ret = clone(Readers.teleportInfo.content)
    end
    if eventID == SearchingMapMgr.EVENT_OBSTRUCTION then
        ret = clone(Readers.obstructionInfo.content)
    end
    if eventID == SearchingMapMgr.EVENT_EXIT then
        ret = clone(Readers.itemsInfo.content)
    end
    if eventID == LtEventOption.EVENT_BILLBOARD then
        ret = clone(Readers.billboardInfo.content)
    end
    if eventID == LtEventOption.EVENT_ADV_NPC then
        ret = clone(Readers.fbnpcInfo.content)
    end
    
    return ret
end

local function setSubList(eventID)
    local listview = CSResourceMgr.getNodeByName(resName,{"db", "subList"})
    local sample   = CSResourceMgr.getNodeByName(resName,"label_db")

    listview:removeAllItems()
    
    local _table = getSubList(eventID)

    subListButton = {}
    for k,v in pairs(_table) do
        local label_db = sample:clone()
        
        local text = v.name or v.id
        local label = CSResourceMgr.seekNodeByName(label_db,"label")
        CSResourceMgr.setLabelStringByNode(label,text)

        CSResourceMgr.clickEventBindingByNode(label_db,function(sender, state)
            local index
            for i = 1, #subListButton do
                if sender == subListButton[i] then index = i end
            end

            if not index then return end

            local last = currentType.index

            if subListButton[last] then
                local _label = CSResourceMgr.seekNodeByName(subListButton[last],"label")
                CSResourceMgr.setLabelColorByNode(_label,{r=255,g=255,b=255,a=255})
            end

            currentType.index  = index
            currentType.typeID = _table[index].id

            local _label = CSResourceMgr.seekNodeByName(subListButton[index],"label")
            CSResourceMgr.setLabelColorByNode(_label,{r=255,g=255,b=0,a=255})
        end)

        listview:pushBackCustomItem(label_db)

        table.insert(subListButton, label_db)
    end
end

local function initEventList()
    local listview = CSResourceMgr.getNodeByName(resName,{"db", "eventList"})
    local sample   = CSResourceMgr.getNodeByName(resName,"label_db")
    
    listview:removeAllItems()
    
    eventListButton = {}
    for k,v in pairs(eventList) do
        local label_db = sample:clone()
        
        local label = CSResourceMgr.seekNodeByName(label_db,"label")
        CSResourceMgr.setLabelStringByNode(label,v)
        
        CSResourceMgr.clickEventBindingByNode(label_db,function(sender, state)
            local index
            for i = 1, #eventListButton do
                if sender == eventListButton[i] then index = i end
            end
            
            if not index then return end
            
            print("11111111111111111111111")
            
            setSubList(k)

            print("22222222222222222222222")
            
            local last = currentEvent.index
            
            if eventListButton[last] then
                local _label = CSResourceMgr.seekNodeByName(eventListButton[last],"label")
                CSResourceMgr.setLabelColorByNode(_label,{r=255,g=255,b=255,a=255})
            end
            
            currentEvent.index   = index
            currentEvent.eventID = k
            
            local _label = CSResourceMgr.seekNodeByName(eventListButton[index],"label")
            CSResourceMgr.setLabelColorByNode(_label,{r=255,g=255,b=0,a=255})
        end)
        
        listview:pushBackCustomItem(label_db)
        
        table.insert(eventListButton, label_db)
    end
end

function DungeonTestMapMgr.addTestMenu(scene)

    local currLayer = CSResourceMgr.createRes(scene, resName)
    CSResourceMgr.setFullScreen(resName)
    CocosModuleMgr.setEdgeDistance(currLayer, nil, nil, nil, 0)
    currLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)

    local menu1 = CSResourceMgr.getNodeByName(resName,"menu1")
    local menu2 = CSResourceMgr.getNodeByName(resName,"menu2")

    CSResourceMgr.clickEventBindingByNode(menu1,function()
        CSResourceMgr.playAction(resName,0,5,false)
        menu1:setVisible(false)
        menu2:setVisible(false)
        
        DungeonTestMapMgr.reBindBlock("edit_select")

        initEventList()
    end,true)
    
    CSResourceMgr.clickEventBindingByNode(menu2,function()
        for i = 1, LtMapOption.getMapSize() do
            if SearchingMgr.eventInfoTable[i] ~= LtEventOption.EVENT_TRAINER then
                SearchingUIMgr.bindBlockEvent(i, function()
                    if SearchingMgr.onmove and SearchingMgr.canMove then
                        if i ~= SearchingMgr.destination then
                            SearchingMgr.cancelMove = true  --移动取消标志 
                            SearchingMgr.cancelAt = i
                        end
                        return
                    end
                    if SearchingMgr.onbattle then return end
                    SearchingMgr.moveWithCallback(i, function()
                        local callback = SearchingFuncMgr.getEventFunc(i)
                        if callback then callback(i) end
                    end)
                end)
            end
        end
    end,true)
    
    -- close button
    CSResourceMgr.clickEventBinding(resName,"Button_7",function()
        -- do something
        
        SearchingMgr.closeAdventure()
        
        if LtMapOption.getMapType() == "ADVENTURE" then
            CSResourceMgr.removeCSObjectByTag(SearchingUIMgr.centerResName)
        else
            CSResourceMgr.removeCSObjectByTag(LostTowerUIMgr.centerResName)
        end
        CSResourceMgr.removeCSObjectByTag(resName)
    end,"",1)

    -- return button
    CSResourceMgr.clickEventBinding(resName,{"db", "return"},function()
        -- do something

        menu1:setVisible(true)
        menu2:setVisible(true)
        CSResourceMgr.getNodeByName(resName,"db"):setPositionY(0)
    end,"",1)
    
    -- select button
    CSResourceMgr.clickEventBinding(resName,{"db", "selectCell"},function()
        -- do something
        
        -- DungeonTestMapMgr.reBindBlock("single_select")
    end,"",1)

    -- ok button
    CSResourceMgr.clickEventBinding(resName,{"db", "ok_btn"},function()
        -- do something
        SearchingMapMgr.initTxtData()
        
        for i, v in pairs(selectBlocks) do
            if selectBlocks[i] then
                local _block = i
                local char = AdvCharMgr.getTrainerByPos(_block)
                if char then 
                    AdvCharMgr.clearTrainerVision(char)
                    AdvCharMgr.removeTrainer(char) 
                else
                    local aniRes = SearchingMgr.itemTypeTable[_block].aniRes
                    if aniRes and aniRes ~= "" then
                        local resName = aniRes
                        AnimationMgr.removeGafObjectByTag(resName, _block)
                    end
                    
                    SearchingUIMgr.resetGroudImg(_block)
                    SearchingUIMgr.clearBlock(_block)
                end
                SearchingMgr.eventInfoTable[_block] = currentEvent.eventID
                SearchingMgr.itemTypeTable[_block]  = SearchingMapMgr.getEventRes(currentEvent.eventID, currentType.typeID)
                LtEventOption.createEvent(_block)

                selectBlocks[i] = false
                if selectCircles[i] then 
                    pcall(function() selectCircles[i]:removeFromParent() end)
                    selectCircles[i] = nil
                end
            end
        end

        DungeonTestMapMgr.reBindBlock("edit_select")
    end,"",1)

    -- clear button
    CSResourceMgr.clickEventBinding(resName,{"db", "clear_btn"},function()
        -- do something
        
        for i, v in pairs(selectBlocks) do
            if selectBlocks[i] then
                selectBlocks[i] = false
                if selectCircles[i] then 
                    selectCircles[i]:removeFromParent()
                    selectCircles[i] = nil
                end
            end
        end
    end,"",1)
    
    -- import button
    CSResourceMgr.clickEventBinding(resName,{"db", "import"},function()
        -- do something
        SearchingMapMgr.initTxtData()
        
        local mapConfig = TxtReader.new("advImport.txt")
        mapConfig.init({"ID","aid","eventID","row","col","subType"},1)
        
        if #mapConfig.content ~= LtMapOption.getMapSize() then
            print("地图大小不匹配")
            mapConfig.unload()
            mapConfig = nil
            return
        end
        
        local allEventInfoList = {}
        for k,v in pairs(eventList) do
            allEventInfoList[k] = getSubList(k)
            allEventInfoList[k].nameString = v
        end
        
        for i = 1, #mapConfig.content do
            local _block = LtMapOption.convertToIndex(tonumber(mapConfig.content[i].col), tonumber(mapConfig.content[i].row))
            local char = AdvCharMgr.getTrainerByPos(_block)
            if char then 
                AdvCharMgr.clearTrainerVision(char)
                AdvCharMgr.removeTrainer(char) 
            else
                local aniRes = SearchingMgr.itemTypeTable[_block].aniRes
                if aniRes and aniRes ~= "" then
                    local resName = aniRes
                    AnimationMgr.removeGafObjectByTag(resName, _block)
                end

                SearchingUIMgr.resetGroudImg(_block)
                SearchingUIMgr.clearBlock(_block)
            end
            
            local eventID, subType
            for k,v in pairs(eventList) do
                if v == mapConfig.content[i].eventID then
                    eventID = k
                end
            end
            
            if not eventID then
                eventID = 0
                subType = 0
            else
                for k,v in pairs(allEventInfoList[eventID]) do
                    if v.name == mapConfig.content[i].subType then
                        subType = k
                    end
                end
            end
            
            if eventID == LtEventOption.EVENT_EXIT then subType = 2 end
            if eventID == LtEventOption.EVENT_MONSTER or eventID == LtEventOption.EVENT_NPC or eventID == LtEventOption.EVENT_TRAINER then
                eventID = 0
                subType = 0
            end
            SearchingMgr.eventInfoTable[_block] = eventID or 0
            SearchingMgr.itemTypeTable[_block]  = SearchingMapMgr.getEventRes(eventID, subType or 0)
            LtEventOption.createEvent(_block)
        end
    end,"",1)
    
    -- export button
    CSResourceMgr.clickEventBinding(resName,{"db", "export"},function()
        -- do something
        
        local file = io.open("advExport.txt","w")
        file:write("ID\t副本编号\t事件类型\t第X行\t第Y列\t事件表现\n")
        
        local eventID, eventTypeString, eventInfoList, eventInfo, subTypeString
        local startID = DungeonTestMapMgr.xmlStartID
        for i = 1, LtMapOption.getMapSize() do
            eventID = SearchingMgr.eventInfoTable[i]
            eventTypeString = eventList[eventID]
            local col, row = LtMapOption.convertToCoord(i)
            eventInfoList = getSubList(eventID)
            
            eventInfo = eventInfoList[tonumber(SearchingMgr.itemTypeTable[i].id)]
            subTypeString = ""
            if eventID == LtEventOption.EVENT_VOID then subTypeString = "空" end
            if eventID == LtEventOption.EVENT_EXIT then subTypeString = "出口" end
            if eventInfo then subTypeString = eventInfo.name or eventInfo.id or "空" end
            file:write(startID.."\t"..SearchingMapMgr.currAdventure.."\t"..eventTypeString.."\t"..row.."\t"..col.."\t"..subTypeString.."\n")
            startID = startID + 1
        end
        io.close(file)
    end,"")

end


function DungeonTestMapMgr.addSubMenu(scene, closeCallback)
    scene = scene or SceneMgr.getRunningScene

    local block = CSResourceMgr.getNodeByName(resName,"block")
    local subMenu = CSResourceMgr.getNodeByName(resName,"subMenu")
    
    block:setVisible(true)
    subMenu:setVisible(true)
    
    CSResourceMgr.clickEventBindingByNode(CSResourceMgr.seekNodeByName(subMenu,"setTargets"),function()
        block:setVisible(false)
        subMenu:setVisible(false)
        
        if not currentSingleSelect then return end
        DungeonTestMapMgr.reBindBlock("single_select_2", currentSingleSelect)
    end)
    
    CSResourceMgr.clickEventBindingByNode(CSResourceMgr.seekNodeByName(subMenu,"return2"),function()
        block:setVisible(false)
        subMenu:setVisible(false)
        if closeCallback then closeCallback() end
    end)
end

return DungeonTestMapMgr