local advResetView = {}

local resName = "Searching/Other/advResetView.csb"
local tag = ""

local Layer

function advResetView.Init()
end

function advResetView.makeData(floor)

    local mapInfoTable        = clone(SearchingMgr.mapInfoTable)
    local eventInfoTable      = clone(SearchingMapMgr.OriginalData[2]["floor"..floor])
    local itemTypeTable       = clone(SearchingMapMgr.OriginalData[3]["floor"..floor])
    local eventStateInfoTable = clone(SearchingMapMgr.OriginalData[4]["floor"..floor])
    local monsterDefendInfo   = clone(SearchingMgr.monsterDefendInfo)
    
    -- 训练师可能移动过，恢复
    for i = 1, #SearchingMgr.eventInfoTable do
        if SearchingMgr.eventInfoTable[i] == LtEventOption.EVENT_TRAINER then
            local pos = SearchingMgr.itemTypeTable[i].tag
            SearchingMgr.itemTypeTable[pos] = SearchingMgr.itemTypeTable[i]
            SearchingMgr.eventStateInfoTable[pos] = SearchingMgr.eventStateInfoTable[i]
        end
        
        -- 消失的训练师处理
        if SearchingMgr.eventInfoTable[i] == LtEventOption.EVENT_VOID and SearchingMgr.itemTypeTable[i].trainerDisappear then
            local pos = SearchingMgr.itemTypeTable[i].tag
            SearchingMgr.itemTypeTable[pos].clear = true
            SearchingMgr.eventStateInfoTable[pos] = SearchingMgr.eventStateInfoTable[i]
        end
    end
    
    for i = 1, #eventInfoTable do
        -- 宠物数据处理
        if eventInfoTable[i] == LtEventOption.EVENT_MONSTER then
--            if SearchingMgr.eventStateInfoTable[i] == 3 then
--                eventInfoTable[i] = LtEventOption.EVENT_VOID
--                itemTypeTable[i] = {}
--                eventStateInfoTable[i] = 3
--            end
            if SearchingMgr.eventStateInfoTable[i] == 3 or SearchingMgr.itemTypeTable[i].clear then
                itemTypeTable[i].clear = true
            end
        end
        
        -- 训练师数据处理
        if eventInfoTable[i] == LtEventOption.EVENT_TRAINER then
            if SearchingMgr.eventStateInfoTable[i] == 3 or SearchingMgr.itemTypeTable[i].clear then
                itemTypeTable[i].clear = true
            end
        end
        
        -- 副本npc数据处理
        if eventInfoTable[i] == LtEventOption.EVENT_ADV_NPC then
            if SearchingMgr.eventStateInfoTable[i] == 3 or SearchingMgr.itemTypeTable[i].clear then
                itemTypeTable[i].clear = true
            end
        end
    
        -- 拾取事件数据处理
        if eventInfoTable[i] == LtEventOption.EVENT_PICKING then
            if SearchingMgr.eventStateInfoTable[i] == 3 or SearchingMgr.itemTypeTable[i].picked then
                itemTypeTable[i].picked = true
            end
        end
        
        -- 障碍物数据处理[道具清除障碍]
--        if eventInfoTable[i] == LtEventOption.EVENT_OBSTRUCTION then
--            if SearchingMgr.eventStateInfoTable[i] == 3 then
--                local cond = itemTypeTable[i].cond
--                if cond and cond[1] and cond[1][1] == "1" then
--                    eventInfoTable[i] = LtEventOption.EVENT_VOID
--                    itemTypeTable[i] = {}
--                    eventStateInfoTable[i] = 3
--                end
--            end
--        end
    end

    SearchingMapMgr.floorMapInfoTbl["floor"..floor]    = mapInfoTable
    SearchingMapMgr.floorEventTbl["floor"..floor]      = eventInfoTable
    SearchingMapMgr.floorItemTbl["floor"..floor]       = itemTypeTable
    SearchingMapMgr.floorEventStateTbl["floor"..floor] = eventStateInfoTable
    SearchingMapMgr.floorMstrDefendTbl["floor"..floor] = monsterDefendInfo
    
    if floor == 1 then
        SearchingMapMgr.floorEnterance["floor"..floor] = SearchingMapMgr.OriginalData[6]["floor"..floor]
    end
    
    -- 皇冠成就数据处理
    local data = {}
    for k, v in pairs(SearchingMapMgr.GoalRecord[floor]) do
        if not data[v.eventType] then data[v.eventType] = {} end
        data[v.eventType][v.eId] = v.count
        v.count = 0
    end
    for k, v in pairs(SearchingMapMgr.GoalTable) do
        if data[v.eventType] then
            if data[v.eventType][v.eId] then
                v.count = v.count - data[v.eventType][v.eId]
            end
        end
        if v.count < 0 then v.count = 0 end

        local _goal = tonumber(v.goal)
        if _goal <= 0 then
            if v.count > math.abs(_goal) then
                v.clear = false 
            else
                v.clear = true
            end
        else
            if v.count < _goal then v.clear = false end
        end
    end
    data = nil
    
    -- 道具使用数据处理
    local propMgr = require("src.GameMgr.Searching.propMgr")
    for _, value in pairs(SearchingMapMgr.propUseRecord[floor]) do
        local index = #SearchingMapMgr.allItems + 1
        local img = value.info["img"]
        propMgr.addProp(index,img,value["info"].info)
    end
    SearchingMapMgr.propUseRecord[floor] = {}
    
end

function advResetView.show(scene, skillID)
    UIStack.push("advResetView",advResetView.hide)

    GameAudio.playUISound("ok")

    scene = scene or SceneMgr.getRunningScene
    
    local resetConsumeID   = AdventureInfo.getAdventureInfoByID(SearchingMapMgr.currAdventure).resetConsumeID
    local resetConsumeInfo = ItemInfo.getConsumeElementInfoById(resetConsumeID)
    
    local langID = {
        [Proto.AET_GCASH]       = "tips16",  -- 金币
        [Proto.AET_MCASH]       = "tips17",  -- 钻石
        [Proto.AET_ACTIONPOINT] = "tips37",  -- 体力
    }
    --阿杜修改英文版显示
    if LuaSqlite.LANG_TYPE == 3 then
        langID = {
            [Proto.AET_GCASH]       = "advtext230",  -- 金币
            [Proto.AET_MCASH]       = "advtext23",  -- 钻石
            [Proto.AET_ACTIONPOINT] = "advtext24",  -- 体力
        }
    end

    local function loadCSB()
        Layer = CSResourceMgr.createRes(scene,resName,tag)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        Layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        
        CSResourceMgr.getNodeByName(resName,"db1",tag):setVisible(false)

        local cells = {"title2", "reset_t", "reset_desc", "surrender_t", "surrender_desc"}
        
        local texts = {
            "advtext18",  -- "说明"
            "advtext19",  -- "重置"
            "advtext20",  -- "重置描述"
            "advtext14",  -- "放弃"
            "advtext22",  -- "放弃描述"
        }
        local textColor = {
            {r=144,g=238,b=255,a=255},
            {r=112,g=131,b=158,a=255},
            {r=112,g=131,b=158,a=255},
            {r=112,g=131,b=158,a=255},
            {r=112,g=131,b=158,a=255},
        }
        local outlineColor = {
            {r=38,g=54,b=76,a=255},
        }
        local lineWidth = { 110, 44, nil, 44, nil }
        
        for i = 1, #cells do
            CSResourceMgr.setLabelColor(resName,{"db1","db2", cells[i]},textColor[i], tag)
            CSResourceMgr.setLabelString(resName,{"db1","db2", cells[i]},texts[i],tag,outlineColor[i], nil, lineWidth[i])
        end
        
        local btn_cells = {"reset", "surrender"}
        
        local icons = {
            "Searching/topBar/reset.png" ,
            "Searching/topBar/fangqi.png",
        }
        texts = {
            CocosModuleMgr.createStringWithFormat({"advtext23", resetConsumeInfo.num, langID[resetConsumeInfo.elementType] or ""}),
            "advtext24",
        }
        --阿杜修改英文版显示
        if LuaSqlite.LANG_TYPE == 3 then
            texts = {
                CocosModuleMgr.createStringWithFormat({langID[resetConsumeInfo.elementType] or "", resetConsumeInfo.num}),
                "advtext24",
            }
        end
        textColor = {
            {r=217,g=234,b=255,a=255},
            {r=217,g=234,b=255,a=255},
        }
        outlineColor = {
            {r=0,g=0,b=0,a=255,w=1},
            {r=0,g=0,b=0,a=255,w=1},
        }
        lineWidth = { nil, nil, }
        
        for i = 1, #btn_cells do
            local btn = CSResourceMgr.getNodeByName(resName, {"db1","db2", btn_cells[i].."_btn"},tag)
            
            CSResourceMgr.seekNodeByName(btn, btn_cells[i].."_i"):loadTexture(icons[i])

            --阿杜修改英文版显示
            if LuaSqlite.LANG_TYPE ~= 3 then
                CSResourceMgr.setLabelColor(resName,{"db1","db2", btn_cells[i].."_btn", btn_cells[i].."_text"},textColor[i], tag)
                CSResourceMgr.setLabelString(resName,{"db1","db2", btn_cells[i].."_btn", btn_cells[i].."_text"},texts[i],tag,outlineColor[i], nil, lineWidth[i])
            else
                local label = CSResourceMgr.getNodeByName(resName, btn_cells[i].."_text")
                local richLabel = CocosModuleMgr.createRichLabel(label, texts[i], 24, "cuyuan_GBK.ttf", TownChatMgr.MAX_LABEL_WIDTH,nil,nil,nil,true)
                label:setString(" ")
                label:setTextAreaSize({width = 0, height = richLabel.realHeight})
                label:ignoreContentAdaptWithSize(false)
            end
        end
        
    end

    local function init()
    end

    local function playAction()
        local node = CSResourceMgr.getNodeByName(resName,"db1",tag)
        node:setVisible(true)
        
        CocosModuleMgr.showUIAnimation(node,"down")
    end

    local function bindEvent()
        CSResourceMgr.clickEventBinding(resName,"close",function()
            advResetView.hide()
        end,tag)
        
        CSResourceMgr.clickEventBinding(resName,{"db1","db2", "reset_btn"},function()
            local desc = "advtext19"
            DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 2, desc, function()
                NetInterface.sendWithBlock("GC_RESETADVENTURE_ACK", function()
                    local AdventureSend = require("src/Net/Send/AdventureSend.lua")
                    AdventureSend.sendCG_ResetAdventure_Req()
                end, 
                function()
                    advResetView.makeData(SearchingMapMgr.currFloor)
                    AdvCharMgr.clearTrainers()
                    SearchingMgr.floorClear = true
                    SearchingUIMgr.resetMap()
                    AdvStarMgr.refreshMissionUI()

                    advResetView.hideWithoutBobobo()
                end,
                function(code)
                    if code == Proto.Error.ERROR_NOTENOUGHMONEY then           -- 金币不足
                        StandardTipsMgr.show(1,"tips13")
                    elseif code == Proto.Error.ERROR_NOTENOUGH_RMB then        -- 钻石不足
                        StandardTipsMgr.show(1,"tips14")
                    elseif code == Proto.Error.ERROR_NOT_ENOUTH_MOBILITY then  -- 体力不足
                        StandardTipsMgr.show(1,"tips38")
                    end
                end)
            end)
        end,tag,nil,"popup")
        
        CSResourceMgr.clickEventBinding(resName,{"db1","db2", "surrender_btn"},function()
            DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 2, "advtext15", function() -- "确定放弃？"
                SearchingMgr.adventure_failed(function()
                    SearchingMgr.leaveAdventure()
                    SearchingMgr.closeAdventure()
                    SceneMgr.replaceScene(SceneMgr.getRunningScene, "MainScene")
                end)
            end)
        end,tag,nil,"popup")
    end

    local funcTable = { loadCSB, init, playAction, bindEvent, }

    UnblockLoader.load(funcTable,"advResetView")

--    for i = 1, #funcTable do funcTable[i]() end
end

function advResetView.hide()
    UIStack.pop("advResetView")
    GameAudio.playUISound("back")
    CSResourceMgr.removeCSObjectByTag(resName,tag)
end

function advResetView.hideWithoutBobobo()
    UIStack.pop("advResetView")
    CSResourceMgr.removeCSObjectByTag(resName,tag)
end


return advResetView