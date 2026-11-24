--created on 2015-07-23

local SearchingMgr = {}

local Point = require("src.GameMgr.Searching.Point")
local Astar = require("src.GameMgr.Searching.Astar")

SearchingMgr.ADV_DEBUG = false


--迷雾解锁状态信息
SearchingMgr.mapInfoTable = {}
--event信息
SearchingMgr.eventInfoTable = {}
--event触发信息
SearchingMgr.eventStateInfoTable = {}
--itemType信息
SearchingMgr.itemTypeTable = {}
--monster防卫信息
SearchingMgr.monsterDefendInfo = {}

--场景入口
SearchingMgr.enterance =  nil
--场景出口
SearchingMgr.exit  = nil
--当前副本编号
SearchingMgr.floors = nil     --副本層數

--人物參數
SearchingMgr.onmove   = false   --can change when cancel move
SearchingMgr.onbattle = false
SearchingMgr.isFound  = false
SearchingMgr.cancelMove = false
SearchingMgr.cancelAt = 0
SearchingMgr.canMove = true   --player can't move anyway when canMove is false 
SearchingMgr.player = nil   --player node
SearchingMgr.player_dir = 5 --[-5:UP 5:DOWN -1:LEFT 1:RIGHT]
SearchingMgr.playerLastPosition = 0
SearchingMgr.playerCurrPosition = 0
SearchingMgr.playerNextStep     = 0
SearchingMgr.destination = 0

--副本狀態
SearchingMgr.dungeonClear = true
SearchingMgr.floorClear = true

--副本通关信息
SearchingMgr.finished = {}
SearchingMgr.awardsTbl = {}

SearchingMgr.isFailed  = false
SearchingMgr.canGiveUp = true

function SearchingMgr.Init() 
    print("SearchingMgr.Init()")
    SearchingMgr.guideFunc = nil
    SearchingMgr.canGiveUp = true
    SearchingMgr.isFailed  = false
    
    SearchingMgr.eventAfterBattle = nil
    
    SearchingMgr.tutorialFunc = nil
    SearchingMgr.fellFlag     = false
    
    SearchingMgr.onmove = false
    
    --副本狀態  [[[ reset adventure flag]]]
    SearchingMgr.dungeonClear = true
    SearchingMgr.floorClear = true
end

--定时器全局检查
local globalhandler
local globalDelta = 0
function SearchingMgr.SCH_GLOBAL_CHECK()
    SearchingMgr.UN_SCH_GLOBAL_CHECK()
    
    globalDelta = 0
    local scheduler = require("framework.scheduler")
    globalhandler =  scheduler.scheduleUpdateGlobal(function()
        AdvCharMgr.upadateAll(globalDelta)
        
        for k, char in pairs(AdvCharMgr.getTrainers()) do
            AdvCharMgr.update(char, globalDelta)
        end
        
        globalDelta = globalDelta + 1
        if globalDelta == 180 then globalDelta = 0 end
    end)
end
function SearchingMgr.UN_SCH_GLOBAL_CHECK()
    local scheduler = require("framework.scheduler")
    if globalhandler ~= nil then 
        globalDelta = 0
        scheduler.unscheduleGlobal(globalhandler)
    end
end

---从服务器端获取地图信息
function SearchingMgr.getInfoFromServer()

end

local function setGuideCallback(_callback)
    if _callback ~= nil then
        SearchingMapMgr.guideCallback = _callback  --引导回调
    else
        SearchingMapMgr.guideCallback = function() print("callback is nil.") end
    end
end

--副本引导接口
local guideAdvs = {1,2,3,4,5,6,7}  --需要引导的关卡
function SearchingMgr.adventureGuide(callback)
    print("SearchingMgr.adventureGuide")
    if SearchingMapMgr.currAdventure == guideAdvs[1] then
    
        SearchingMgr.guideFunc = function()
            CSResourceMgr.setButtonEnabled(SearchingUIMgr.topResName,{"db","giveup"},false)
            CSResourceMgr.setButtonEnabled(SearchingUIMgr.topResName,{"db","giveup_db"},false)
            SearchingMgr.canGiveUp = false
            BattleCCSB.stopQuitBattle()
            
            local steps = {}

            local step0 = CSResourceMgr.getNodeByName("Searching/bottomBar/bottomBar.csb","targets")
            local step1 = SearchingUIMgr.getBlockNode(29)
            local step2 = SearchingUIMgr.getBlockNode(30)
            local step3 = SearchingUIMgr.getBlockNode(18)
            local step4 = SearchingUIMgr.getBlockNode(13)
            
            local questID = {11,12,13,14}
            
            local function firstAdvNpc_1(_callback)
                local npcPos = 22
                local _char = AdvCharMgr.getTrainerByPos(npcPos)
                local _node1 = _char.info.node
                local _node2 = SearchingUIMgr.getBlockNode(13)

                local function walk(_callback2)
                    local movetime = 0.25
                    SearchingUIMgr.StepTo(nil, 29, movetime, function()
                        SearchingUIMgr.StepTo(nil, 28, movetime, function()
                            SearchingUIMgr.StepTo(nil, 27, movetime, function()
                                if _callback2 then _callback2() end
                            end)
                        end)
                    end)
                end
                
                local flag = false
                CSResourceMgr.clickEventBindingByNode(_char.info.node, function()
                    if flag then return end
                    flag = true
                
                    local params = {
                        mID     = tonumber(SearchingMgr.itemTypeTable[npcPos].param1),
                        dialog1 = SearchingMgr.itemTypeTable[npcPos].dialog1,
                        dialog2 = SearchingMgr.itemTypeTable[npcPos].dialog2,
                    }
                    walk(function()
                        NpcDialogueMgr.show(params.dialog1,function()
                            SearchingFuncMgr.takeNpcTask(params["mID"])
                            CocosModuleMgr.setButtonGuide(_node2, 2.5, function()
                                SceneMgr.getRunningScene:performWithDelay(function()
                                    if _callback then _callback() end
                                end, 0.25*4)
                            end)
                        end)
                    end)
                end)
                
                CocosModuleMgr.setButtonGuide(_node1,2.5,function()
                end)
            end
            
            local function _battle(_callback)
                SearchingUIMgr.TurnToBlock(14)  --Mend your manners!
                SearchingMapMgr.firstAdventure = true   --副本引导，战斗读取标志(moveWithCallback中有判定)

                local char = AdvCharMgr.getTrainerByPos(15)
                AdvCharMgr.cancelWatching(char)  --cancel watching
                AdvCharMgr.stepTo(char,{c=-1,r=0},0.5)

                SearchingMgr.canMove = false
                SceneMgr.getRunningScene:performWithDelay(function()
                    SearchingMgr.canMove = true
                    NpcDialogueMgr.show(questID[4], function()   --trainer
                        if callback ~= nil then
                            SearchingMapMgr.guideCallback = callback  --引导回调
                        else
                            SearchingMapMgr.guideCallback = function() print("callback is nil.") end
                        end
                        AdvCharMgr.tutorialBattle(char, function()
                            MapSeekerMgr.SeekFunc = function()
                                SearchingMgr.adventureGuide_1()
                            end
                        end)
                    end)
                end,0.5 + 0.25)
            end

            CocosModuleMgr.setScreenTouch(false)
            SceneMgr.getRunningScene:performWithDelay(function()
                CocosModuleMgr.setScreenTouch(true)
                NpcDialogueMgr.show(questID[2], function() end)
                CocosModuleMgr.setButtonGuide(step1, 3.5, function()
                    NpcDialogueMgr.hide()
                    CocosModuleMgr.setScreenTouch(false)
                    SceneMgr.getRunningScene:performWithDelay(function()
                        CocosModuleMgr.setButtonGuide(step2, 3.5, function()
                            SceneMgr.getRunningScene:performWithDelay(function()   --防止事件绑定覆盖[迷雾消失重新绑定按钮事件]
                                if not SearchingMgr.onmove then  --avoid duplicate click
                                    CocosModuleMgr.setButtonGuide(step2, 3.5, function()
                                        SceneMgr.getRunningScene:performWithDelay(function()
                                            NpcDialogueMgr.show(questID[3], function()   -- 捡完金币对话
                                                CocosModuleMgr.setScreenTouch(true)
                                                setGuideCallback(function()
                                                    SearchingMgr.canGiveUp = true
                                                    if callback then callback() end
                                                end)
                                                -- 全不要了!!!
                                                --firstAdvNpc_1(function()
                                                --    _battle()
                                                --end)
                                            end)
                                        end,0.5+1.0)
                                    end)
                                end
                            end,0.5*2)
                        end)
                    end,0.5*2)
                end)
            end,0.5)
        end
    elseif SearchingMapMgr.currAdventure == guideAdvs[2] then
        SearchingMgr.guideFunc = function()
            CSResourceMgr.setButtonEnabled(SearchingUIMgr.topResName,{"db","giveup"},false)
            CSResourceMgr.setButtonEnabled(SearchingUIMgr.topResName,{"db","giveup_db"},false)
            SearchingMgr.canGiveUp = false
            BattleCCSB.stopQuitBattle()
            
            local questID = {32,33,34,35}
        
            local step1 = SearchingUIMgr.getBlockNode(4)
            local step2 = SearchingUIMgr.getBlockNode(16)
            local step3 = SearchingUIMgr.getBlockNode(18)
            local step4 = SearchingUIMgr.getBlockNode(13)
            
            NpcDialogueMgr.show(questID[1], function()
                CocosModuleMgr.setScreenTouch(false)
                CocosModuleMgr.setButtonGuide(step1, 3.5, function()
                    SceneMgr.getRunningScene:performWithDelay(function()
                        NpcDialogueMgr.show(questID[2], function()
                            CocosModuleMgr.setButtonGuide(step1, 3.5, function()
                                if PokemonInfo.getAllPets() and #PokemonInfo.getAllPets() >= 3 then -- 超过三只宠直接跳过引导
                                    setGuideCallback(function()
                                        SearchingMgr.canGiveUp = true
                                        if callback then callback() end
                                    end)
                                    CocosModuleMgr.setScreenTouch(true)
                                    return
                                end
                            
                                SceneMgr.getRunningScene:performWithDelay(function()  -- 延时等待弹窗弹出
                                    local button = CSResourceMgr.getNodeByName("Searching/Other/SkillMissingView.csb", {"db1","close"})
                                    local bg     = CSResourceMgr.getNodeByName("Searching/Other/SkillMissingView.csb", "block")
                                    local f = function()
                                        -- 引导回调移出延时，防止卡引导
                                        setGuideCallback(function()
                                            SearchingMgr.canGiveUp = true
                                            if callback then callback() end
                                        end)
                                        SceneMgr.getRunningScene:performWithDelay(function()
                                            NpcDialogueMgr.show(questID[3], function()
                                                CocosModuleMgr.setScreenTouch(true)
                                                -- 全不要了!!!!
--                                                CocosModuleMgr.setButtonGuide(step2, 2.5, function()
--                                                    SearchingMapMgr.firstAdventure = true
--                                                    SearchingFuncMgr.setAddtionalCheck(function(i)
--                                                        if i == 16 then   -- 训练师前面一格
--                                                            return false
--                                                        end
--                                                        return true
--                                                    end)
--                                                    SearchingFuncMgr.setAddtionalCallback(function()
--                                                        SearchingFuncMgr.clearAddtionalCheck()
--                                                        SearchingFuncMgr.clearAddtionalCallback()
--
--                                                        SearchingUIMgr.TurnToBlock(17)  --Mend your manners!
--                                                        CocosModuleMgr.setScreenTouch(true)
--                                                        SearchingMapMgr.firstAdventure = true   --副本引导，战斗读取标志(moveWithCallback中有判定)
--                                                        AdvCharMgr.cancelWatching(AdvCharMgr.getTrainerByPos(17))  --cancel watching
--                                                        NpcDialogueMgr.show(questID[4], function()   --trainer
--                                                            if callback ~= nil then
--                                                                SearchingMapMgr.guideCallback = callback  --引导回调
--                                                            else
--                                                                SearchingMapMgr.guideCallback = function() print("callback is nil.") end
--                                                            end
--                                                            local char = AdvCharMgr.getTrainerByPos(17)
--                                                            AdvCharMgr.tutorialBattle(char, function()
--                                                                MapSeekerMgr.SeekFunc = function()
--                                                                    SearchingMgr.adventureGuide_1()
--                                                                end
--                                                            end)
--                                                        end)-- end of questID[4]
--                                                    end)
--                                                end)
                                            end)-- end of questID[3]
                                        end,0.5)
                                    end -- end of function `f`

                                    CocosModuleMgr.setScreenTouch(true)
                                    SearchingUIMgr.btnAdditionalFunc(button,function()
                                        CocosModuleMgr.setScreenTouch(false)
                                        f()
                                    end)-- end of btnAdditionalFunc
                                    SearchingUIMgr.btnAdditionalFunc(bg,function()
                                        CocosModuleMgr.setScreenTouch(false)
                                        f()
                                    end)-- end of btnAdditionalFunc
                                end,0.5)
                            end)
                        end)-- end of questID[2]
                    end,2*0.5)
                end)
            end)-- end of questID[1]
            
        end
    end

end

--副本引导战斗返回衔接
function SearchingMgr.adventureGuide_1()
    local movetime = 0.25

    print("adventureGuide_1()")

    if SearchingMapMgr.currAdventure == guideAdvs[1] then
        CSResourceMgr.setButtonEnabled(SearchingUIMgr.topResName,{"db","giveup"},false)
        CSResourceMgr.setButtonEnabled(SearchingUIMgr.topResName,{"db","giveup_db"},false)
        local step1 = SearchingUIMgr.getBlockNode(4)
        local step2 = SearchingUIMgr.getBlockNode(5)
        local step3 = CSResourceMgr.getNodeByName("Searching/bottomBar/bottomBar.csb","targets")
        local step4 = CSResourceMgr.getNodeByName("Searching/MissionUI/starBoard.csb","block")
        local step5 = SearchingUIMgr.getBlockNode(11)
        
        -- 副本任务NPC第二段
        local function firstAdvNpc_2(_callback)
            local npcPos = 22
            local _char = AdvCharMgr.getTrainerByPos(npcPos)
            local _node1 = _char.info.node

            local function walk(_callback2)
                local movetime = 0.25
                SearchingUIMgr.StepTo(nil, 18, movetime, function()
                    SearchingUIMgr.StepTo(nil, 23, movetime, function()
                        if _callback2 then _callback2() end
                    end)
                end)
            end
            
            local flag = false
            CSResourceMgr.clickEventBindingByNode(_node1, function()
                if flag then return end
                flag = true
                
                local params = {
                    mID     = tonumber(SearchingMgr.itemTypeTable[npcPos].param1),
                    dialog1 = SearchingMgr.itemTypeTable[npcPos].dialog1,
                    dialog2 = SearchingMgr.itemTypeTable[npcPos].dialog2,
                }
                walk(function()
                    SearchingUIMgr.TurnToBlock(npcPos)
                    NpcDialogueMgr.show(params.dialog2,function()
                        SearchingFuncMgr.handInNpcTask(npcPos, params["_mID"], function()
                            SearchingMapMgr.disposableFireFlag = true
                            local _info = SearchingMapMgr.firedDisposableEvents[SearchingMapMgr.currFloor][npcPos]
                            if _info.state and _info.state == 0 then
                                _info.state = 1
                                SearchingMapMgr.firedDisposableEvents[SearchingMapMgr.currFloor][npcPos].fireFlag = true
                            end
                        
                            NpcDialogueMgr.show(1354,function()
                                if _callback then _callback() end
                            end)
                        end)
                    end)
                end)
            end)

            CocosModuleMgr.setButtonGuide(_node1,2.5,function()
            end)
        end
        
        local function showMissionBoard(_callback)
            NpcDialogueMgr.show(16, function() end)-- end of questID[2]
            CocosModuleMgr.setScreenTouch(false)
            CocosModuleMgr.setButtonGuide(step3, 1.5, function()
                NpcDialogueMgr.hide()
                CocosModuleMgr.setScreenTouch(true)
                SearchingUIMgr.btnAdditionalFunc(step4, function()
                    if _callback then _callback() end
                end)
            end)
        end
        
        local function process2(_callback)
            local questID = {15, 16}
            NpcDialogueMgr.show(questID[1], function()
                showMissionBoard(function()
                    firstAdvNpc_2(function()
                        CocosModuleMgr.setScreenTouch(false)
                        CocosModuleMgr.setButtonGuide(step1, 3.5, function()
                            SceneMgr.getRunningScene:performWithDelay(function()
                                CocosModuleMgr.setButtonGuide(step2, 3.5, function()
                                    SceneMgr.getRunningScene:performWithDelay(function()
                                        if not SearchingMgr.onmove then  --avoid duplicate click
                                            CocosModuleMgr.setButtonGuide(step2, 3.5, function()
                                                SceneMgr.getRunningScene:performWithDelay(function()
                                                    CocosModuleMgr.setScreenTouch(false)
                                                    CocosModuleMgr.setButtonGuide(step5, 2.5, function()
                                                        step5:performWithDelay(function()
                                                            CocosModuleMgr.setScreenTouch(true)
                                                            if _callback then _callback() end
                                                            --SearchingMapMgr.firstAdventure = false
                                                        end,0.25*5)
                                                    end)
                                                end,1.0)
                                            end)
                                        end
                                    end,0.5*2)
                                end)
                            end,0.25*4+1.0)
                        end) -- end of step1
                    end)
                end) -- end of firstAdvNpc2_2
            end)-- end of questID[1]
        end
        
        process2(function()
        end)
        
    elseif SearchingMapMgr.currAdventure == guideAdvs[2] then
        CSResourceMgr.setButtonEnabled(SearchingUIMgr.topResName,{"db","giveup"},false)
        CSResourceMgr.setButtonEnabled(SearchingUIMgr.topResName,{"db","giveup_db"},false)
        local questID = {36,37,}
        local step1 = SearchingUIMgr.getBlockNode(18)
        CocosModuleMgr.setScreenTouch(true)
        NpcDialogueMgr.show(questID[1], function()
            NpcDialogueMgr.show(questID[2], function()
                CocosModuleMgr.setScreenTouch(false)
                CocosModuleMgr.setButtonGuide(step1, 3.5, function()
                    CocosModuleMgr.setScreenTouch(true)
                    --SearchingMapMgr.firstAdventure = false
                end)
            end)
        end)
    end
end

function SearchingMgr.optionalTutorial(callback)
    if SearchingMapMgr.currAdventure == guideAdvs[3] then  -- 智者竞技场
        SearchingMgr.guideFunc = function()
            CSResourceMgr.setButtonEnabled(SearchingUIMgr.topResName,{"db","giveup"},false)
            CSResourceMgr.setButtonEnabled(SearchingUIMgr.topResName,{"db","giveup_db"},false)
            SearchingMgr.canGiveUp = false
            BattleCCSB.stopQuitBattle()
            
            NpcDialogueMgr.show(1029, function()
                -- SearchingMapMgr.firstAdventure = true  --副本引导战斗限制标记
                if callback ~= nil then
                    SearchingMapMgr.guideCallback = callback  --引导回调
                else
                    SearchingMapMgr.guideCallback = function() print("callback is nil.") end
                end
                MapSeekerMgr.SeekFunc = function()
                    CSResourceMgr.setButtonEnabled(SearchingUIMgr.topResName,{"db","giveup"},false)
                    CSResourceMgr.setButtonEnabled(SearchingUIMgr.topResName,{"db","giveup_db"},false)
                    MapSeekerMgr.SeekFunc = function()
                        MapSeekerMgr.SeekFunc = function()
                            CSResourceMgr.setButtonEnabled(SearchingUIMgr.topResName,{"db","giveup"},false)
                            CSResourceMgr.setButtonEnabled(SearchingUIMgr.topResName,{"db","giveup_db"},false)
                        end
                    end
                end
            end)
        end
    elseif SearchingMapMgr.currAdventure == guideAdvs[4] then  -- 地下通路
        local function cuttreeAndPickFlute(_callback)
            local node1 = SearchingUIMgr.getBlockNode(28)
            local node2 = SearchingUIMgr.getBlockNode(30)
            
            CocosModuleMgr.setScreenTouch(false)
--            CocosModuleMgr.setButtonGuide(node1,3.5,function()
--                SceneMgr.getRunningScene:performWithDelay(function()
                    CocosModuleMgr.setButtonGuide(node2,3.5,function()
                        SceneMgr.getRunningScene:performWithDelay(function()
                            NpcDialogueMgr.show(1021, function()
                                SearchingFuncMgr.setAddtionalCheck(function(i)
                                    if i == 26 then   -- 训练师前面一格
                                        return false
                                    end
                                    return true
                                end)
                                SearchingFuncMgr.setAddtionalCallback(function()
                                    SearchingFuncMgr.clearAddtionalCheck()
                                    SearchingFuncMgr.clearAddtionalCallback()
                                    
                                    if _callback then _callback() end
                                end)
                                CocosModuleMgr.setScreenTouch(true)
                            end)  -- end of 1021
                        end,4*0.25+1.0)
                    end)
--                end,2*0.25+0.5)
--            end) -- end of node1
        end
        
        local function removeBigFatty(_callback)
            MapSeekerMgr.SeekFunc = function()
                local node1 = SearchingUIMgr.getBlockNode(23)  -- big fatty here
                local node2 = SearchingUIMgr.getBlockNode(28)  -- billboard

                local f2 = function()  -- use prop flute
                    local _node1 = CSResourceMgr.getNodeByName(SearchingUIMgr.bottomResName,"prop1") -- prop 1
                    NpcDialogueMgr.show(1024,function()
                        CocosModuleMgr.setButtonGuide(_node1,2.5,function()
                            SceneMgr.getRunningScene:performWithDelay(function()
                                local _node2 = CSResourceMgr.getNodeByName("Searching/Node.csb", "stone",23)
                                CocosModuleMgr.setButtonGuide(_node2,2.5,function()
                                    SceneMgr.getRunningScene:performWithDelay(function()
                                        NpcDialogueMgr.show(1025,function()
                                            if _callback then _callback() end
                                        end)
                                    end,0.5)
                                end)
                            end,0.5)
                        end)
                    end)
                end -- end of function `f2`

                local f = function()  -- show billboard
                    NpcDialogueMgr.show(1023,function()
                        CocosModuleMgr.setButtonGuide(node2,2.5,function()
                            SceneMgr.getRunningScene:performWithDelay(function()  -- 延时等待弹窗弹出
                                CocosModuleMgr.setScreenTouch(true)
                                local button = CSResourceMgr.getNodeByName("Searching/Other/BillboardView.csb", "block")
                                SearchingUIMgr.btnAdditionalFunc(button,function()
                                    CocosModuleMgr.setScreenTouch(false)
                                    f2()
                                end)-- end of btnAdditionalFunc
                            end,0.25+0.5)
                        end)
                    end)
                end -- end of function `f`
                
                CocosModuleMgr.setScreenTouch(false)
                SceneMgr.getRunningScene:performWithDelay(function()
                    NpcDialogueMgr.show(1022,function()
                        CocosModuleMgr.setButtonGuide(node1,2.5,function()
                            SceneMgr.getRunningScene:performWithDelay(function()  -- 延时等待弹窗弹出
                                CocosModuleMgr.setScreenTouch(true)
                                local button = CSResourceMgr.getNodeByName("UI/DialogBox/SmallDialogBox.csb", {"db", "diban", "b3"})
                                SearchingUIMgr.btnAdditionalFunc(button,function()
                                    CocosModuleMgr.setScreenTouch(false)
                                    f()
                                end)-- end of btnAdditionalFunc
                            end,0.25+0.5)
                        end)
                    end)
                end,0.5)
            end
        end
        
        local function pushStone(_callback)
            local node1 = SearchingUIMgr.getBlockNode(18)
            local node2 = SearchingUIMgr.getBlockNode(13)
            
            CocosModuleMgr.setScreenTouch(false)
            CocosModuleMgr.setButtonGuide(node1,2.5,function()
                SceneMgr.getRunningScene:performWithDelay(function()
                    CocosModuleMgr.setButtonGuide(node2,2.5,function()
                        SceneMgr.getRunningScene:performWithDelay(function()
                            NpcDialogueMgr.show(1026,function()
                                SearchingMapMgr.firstAdventure = false  -- 副本出场景无回调，可设为false
                                if _callback then _callback() end
                            end) -- end of 1026
                        end,0.5)
                    end)
                end,2*0.25+0.5+0.3)
            end)
        end
    
        SearchingMgr.guideFunc = function()
            SearchingFuncMgr.setAddtionalCheck(function(i)
                if i == 22 then   -- 训练师前面一格
                    return false
                end
                return true
            end)
            SearchingFuncMgr.setAddtionalCallback(function()
                SearchingFuncMgr.clearAddtionalCheck()
                SearchingFuncMgr.clearAddtionalCallback()

                SearchingUIMgr.TurnToBlock(21)  --Mend your manners!
                CocosModuleMgr.setScreenTouch(true)
                SearchingMapMgr.firstAdventure = true   --副本引导，战斗读取标志(moveWithCallback中有判定)
                AdvCharMgr.cancelWatching(AdvCharMgr.getTrainerByPos(21))  --cancel watching
                if callback ~= nil then
                    SearchingMapMgr.guideCallback = callback  --引导回调
                else
                    SearchingMapMgr.guideCallback = function() print("callback is nil.") end
                end
                
                local char = AdvCharMgr.getTrainerByPos(21)
                AdvCharMgr.tutorialBattle(char, function()
                    MapSeekerMgr.SeekFunc = function()
                        print("~~~~~~~~~~~~~~~~~~~~  test tutorial API  ~~~~~~~~~~~~~~~~~~~~~~~~")
                        CocosModuleMgr.setScreenTouch(false)
                        SceneMgr.getRunningScene:performWithDelay(function()
                            CocosModuleMgr.setScreenTouch(true)
                            NpcDialogueMgr.show(1020, function()   --trainer
                                cuttreeAndPickFlute(function()
                                    removeBigFatty(function()
                                        pushStone(function()
                                            CocosModuleMgr.setScreenTouch(true)
                                        end)
                                    end)
                                end)
                            end)-- end of 1020
                        end,0.5)
                    end
                end)
            end)
        end
    elseif SearchingMapMgr.currAdventure == guideAdvs[5] then  -- 遗迹
        local questID = {1300,1377,1378,1388} -- {1300,1377,1378,1303}  -- {1377,1378,1302,1303}  -- {1300,1301,1302,1303}
        
        SearchingMapMgr.floorEventTbl["floor2"][12] = LtEventOption.EVENT_TRAINER
        SearchingMapMgr.floorItemTbl["floor2"][12] = clone(AdventureInfo.getMonsterGroupManInfoByID(10000))
        SearchingMapMgr.floorItemTbl["floor2"][12].floor = SearchingMapMgr.currFloor
        SearchingMapMgr.floorItemTbl["floor2"][12].tag = 12
        
        SearchingMapMgr.floorItemTbl["floor2"][12].eventFunc = function()
            NpcDialogueMgr.show(questID[1],function()
                NpcDialogueMgr.show(questID[2],function()
                    NpcDialogueMgr.show(questID[3],function()
                        NpcDialogueMgr.show(questID[4],function()
                            CocosModuleMgr.playVideo("Video/take2.mp4",function()
                                local char = AdvCharMgr.getTrainerByPos(12)
                                AdvCharMgr.stepTo(char,{c=-1, r=0},0.25)
                                char.info.node:runAction(cc.FadeOut:create(0.25))
                                
                                SearchingMgr.canMove = false
                                SceneMgr.getRunningScene:performWithDelay(function()
                                    SearchingMgr.canMove = true
                                    AdvCharMgr.clearTrainerVision(char)
                                    AdvCharMgr.removeTrainer(char)
                                    SearchingMapMgr.floorEventTbl["floor2"][12] = LtEventOption.EVENT_VOID
                                    SearchingMapMgr.floorItemTbl["floor2"][12] = {}
                                    SearchingMgr.eventInfoTable[12] = LtEventOption.EVENT_VOID
                                    SearchingMgr.itemTypeTable[12] = {}
                                end,0.25)
                            end,false,true)
                        end)
                    end)
                end)
            end)
        end
        
        -- SearchingMapMgr.OriginalData尚未初始话不可赋值
        -- SearchingMapMgr.OriginalData[2]["floor2"][12] = LtEventOption.EVENT_TRAINER
        -- SearchingMapMgr.OriginalData[3]["floor2"][12] = clone(SearchingMapMgr.floorItemTbl["floor2"][12])
    elseif SearchingMapMgr.currAdventure == 10009 then
        SearchingMgr.tutorialFunc = function(callback)
            if SearchingMapMgr.currFloor == 1 then
                if SearchingMgr.fellFlag then
                    CocosModuleMgr.setScreenTouch(false)
                    NpcDialogueMgr.show(1365, function()
                        local scrollview = CSResourceMgr.getNodeByName(SearchingUIMgr.centerResName,"fog")
                        local showHimThePath = AnimationMgr.createAni(scrollview, "Spine/effects/UI_pathindicator.png", 270, 240)
                        showHimThePath:setLocalZOrder(CocosModuleMgr.ZORDER_GUIDE)
                        AnimationMgr.playAniWithCallback(showHimThePath.res,"animation",function()
                            CocosModuleMgr.setScreenTouch(true)
                            SearchingMgr.fellFlag = false
                        end,showHimThePath.tag,true)
                    end)
                end
            end

            if callback then callback() end
        end
    elseif SearchingMapMgr.currAdventure == 10 then  -- 幼龙巢穴
        SearchingMgr.tutorialFunc = function(callback)
            local questID = {10039,10040,10041,10042,10043,10044,10045,10046}
            
            local function showDialog(i, _callback)
                if i > #questID then
                    if _callback then _callback() end
                    return 
                end
                NpcDialogueMgr.show(questID[i], function()
                    showDialog(i, _callback)
                end)
                i = i + 1
            end
        
            SearchingMgr.eventAfterBattle = {}
            SearchingMgr.eventAfterBattle["floor"] = 2
            SearchingMgr.eventAfterBattle["block"] = 14
            SearchingMgr.eventAfterBattle["check"] = function(floor, block)
                if floor ~= SearchingMgr.eventAfterBattle["floor"] then return false end
                if block ~= SearchingMgr.eventAfterBattle["block"] then return false end
                return true
            end
            SearchingMgr.eventAfterBattle["func"]  = function()
                --CocosModuleMgr.playVideo("Video/take3.mp4",function()
                    showDialog(1, function()
                        SearchingMgr.eventAfterBattle = nil
                    end)
                --end,false,true)
            end

            if callback then callback() end
        end
    end
end

---层切换重置副本
function SearchingMgr.reset_for_floorChange()

    SearchingMgr.floorChange(false)
    
    -- player state
    SearchingMgr.onmove = false
    SearchingMgr.canMove = true
    SearchingMgr.onbattle = false
    SearchingMgr.cancelMove = false
    
    --trainer
    AdvCharMgr.resetTrainers()
    
    --pets init
    AdvPetsMgr.reset()
    
end

---副本结束重置副本
function SearchingMgr.reset_for_dungeonEnd()

    SearchingMgr.floorClear = true
    SearchingMgr.dungeonClear = true
    SearchingMapMgr.currFloor = 1

    --trainer
    AdvCharMgr.resetTrainers()
    
    --star
    AdvStarMgr.Init()
    
    --pets
    AdvPetsMgr.Init()

end

function SearchingMgr.isFloorChanged()
    return SearchingMgr.floorClear
end

function SearchingMgr.floorChange(isChanged)
    SearchingMgr.floorClear = isChanged
end

function SearchingMgr.isAdventureEnd()
    return SearchingMgr.dungeonClear
end

function SearchingMgr.adventureEnd(isEnd)
    SearchingMgr.dungeonClear = isEnd
end

function SearchingMgr.enterAdventure()
end

function SearchingMgr.leaveAdventure()
    SearchingMgr.tutorialFunc = nil
    SearchingMgr.fellFlag     = nil
    
    AdvCharMgr.clearTrainers()

    require("src.GameMgr.Searching.propMgr").removeShadow()  -- 移除道具压暗遮罩
    
    SearchingMgr.closeAdventure()
end

function SearchingMgr.closeAdventure()
    SearchingMgr.UN_SCH_GLOBAL_CHECK()
    
    SearchingMgr.tutorialFunc = nil
    SearchingMgr.fellFlag     = nil
    
    SearchingMgr.dungeonClear  = true
    SearchingMgr.floorClear    = true
    SearchingMapMgr.currFloor  = 1
    SearchingMapMgr.itemsCount = 0
    
    SearchingMapMgr.floorMapInfoTbl    = {}
    SearchingMapMgr.floorEventTbl      = {}
    SearchingMapMgr.floorEventStateTbl = {}
    SearchingMapMgr.floorItemTbl       = {}
    SearchingMapMgr.floorMstrDefendTbl = {}
    SearchingMapMgr.floorTargetBlocks  = {}
    SearchingMapMgr.floorEnterance     = {}
    SearchingMapMgr.floorExit          = {}
    
    SearchingMapMgr.OriginalData       = {}
    
    SearchingMapMgr.clearGoalData()
    SearchingMapMgr.clearPickingData()
    SearchingMapMgr.clearPropUseData()

    SearchingMapMgr.disposablePoint = 0
    SearchingMapMgr.disposableFireFlag = false
    SearchingMapMgr.clearDispEvents()
end

---初始化地图信息，注意初始化數據！！
function SearchingMgr.initMapInfo()
    if SearchingMgr.isFloorChanged() then   --層刷新(外部场景进入/层切换...)
        AdvEnvironmentMgr.setEnv(AdvEnvironmentMgr.getCurrentFieldType())
    
        --直接赋值table地址，改变原始数据
        SearchingMgr.mapInfoTable        = SearchingMapMgr.floorMapInfoTbl["floor"..SearchingMapMgr.currFloor]
        SearchingMgr.eventInfoTable      = SearchingMapMgr.floorEventTbl["floor"..SearchingMapMgr.currFloor]
        SearchingMgr.itemTypeTable       = SearchingMapMgr.floorItemTbl["floor"..SearchingMapMgr.currFloor]
        SearchingMgr.eventStateInfoTable = SearchingMapMgr.floorEventStateTbl["floor"..SearchingMapMgr.currFloor]
        SearchingMgr.monsterDefendInfo   = SearchingMapMgr.floorMstrDefendTbl["floor"..SearchingMapMgr.currFloor]

        SearchingMgr.enterance = SearchingMapMgr.floorEnterance["floor"..SearchingMapMgr.currFloor]
        SearchingMgr.exit = SearchingMapMgr.floorExit["floor"..SearchingMapMgr.currFloor]
        
        SearchingMgr.playerCurrPosition = SearchingMgr.enterance or 1
        SearchingMgr.mapInfoTable[SearchingMgr.playerCurrPosition] = 0 

        SearchingMgr.onmove = false
        SearchingMgr.canMove = true
        SearchingMgr.floorClear = false
        
        SearchingMgr.printMap()
        SearchingMgr.printEvent()
        SearchingMgr.printDefend()

    end
    
    AdvCharMgr.resetTrainers()
    SearchingMgr.onmove = false
    SearchingMgr.canMove = true
    SearchingMgr.onbattle = false
    SearchingMgr.cancelMove = false
    AdvStarMgr.setIsShown(false)

end

--+++++++++++++++事件邏輯++++++++++++++++++++++++++++++++++++++++

local function addToGoalRecord(record, info, count)
    for k, v in pairs(record) do
        if v.eventType == info.eventType and v.eId == info.eId then
            v.count = v.count + count
            return
        end
    end
    table.insert(record, {eventType = info.eventType, eId = info.eId, count = count})
end

---检查更新目标达成标志，方格事件信息有更新时检查
function SearchingMgr.checkGoals(block)

    local function check(_block, _info)
        if SearchingMgr.eventStateInfoTable[_block] == 3 then
            if SearchingMgr.eventInfoTable[_block] == _info.eventType then
                if SearchingMgr.eventInfoTable[_block] == LtEventOption.EVENT_PICKING then
                    if SearchingMgr.itemTypeTable[_block].type == _info.eId
                    or SearchingMgr.itemTypeTable[block].type == tonumber(_info.eId)
                    or "0" == _info.eId then
                        return true
                    end
                else
                    if SearchingMgr.itemTypeTable[block].id == _info.eId    --txt中取的id为string类型
                    or SearchingMgr.itemTypeTable[block].id == tonumber(_info.eId)
                    or "0" == _info.eId  -- 0 不管子类型
                    then
                        return true
                    end
                end
            end
        end
        
        return false
    end

    for key, val in pairs(SearchingMapMgr.GoalTable) do
        if check(block, val) then
            val.count = val.count + 1
            print("count+1:",val.count)
            
            addToGoalRecord(SearchingMapMgr.GoalRecord[SearchingMapMgr.currFloor], val, 1)
            
            local _goal = tonumber(val.goal)
            
            if _goal > 0 then
                if not val.clear then
                    if val.count == val.goal then
                        val.clear = true
                        if not val.clear_b then AdvStarMgr.setStarRecordByKey(key) end
                        AdvStarMgr.updateClearedStarNum(1)

                        GameAudio.playUISound("starCollect")
                        SearchingUIMgr.starEffectOnTopbar(AdvStarMgr.getClearedStarNum(),block,function()
                            AdvStarMgr.updateMissionUI()
                        end)
                    end
                end
            else
                print(val.count, math.abs(_goal), tonumber(string.sub(key,-1)))
                if val.clear then
                    if val.count > math.abs(_goal) then
                        val.clear = false
                        AdvStarMgr.updateClearedStarNum(-1)
                        AdvStarMgr.loseCrowne(tonumber(string.sub(key,-1)))
                    end
                end
            end
        end
    end
    
    -- 检查更新副本任务npc状态
    for key, val in pairs(SearchingMapMgr.GoalTable) do
        for _, char in pairs(AdvCharMgr.getTrainers()) do
            local funcType = tonumber(SearchingMgr.itemTypeTable[char.info.pos].funcType)
            if funcType and funcType == 1 then  -- npc 类型为任务NPC
                local charMID = tonumber(SearchingMgr.itemTypeTable[char.info.pos].param1)
                if charMID and val.mID == charMID and val.clear then
                    if not AdvStarMgr.currAdvMissions[val.mID] then
                        AdvStarMgr.currAdvMissions[val.mID] = 0
                    end
                    AdvCharMgr.updateTaskNpcState(char)
                end
            end
        end
    end
    
end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


--+++++++++++++++人物行動邏輯++++++++++++++++++++++++++++++++++++++

function SearchingMgr.getPath(startBlock, tagBlock)
    if SearchingMgr.ADV_DEBUG then 
        print("ADV_DEBUG_INFO: get path from",startBlock,"to",tagBlock)
    end
    
    if tagBlock == startBlock then return nil end
    
    SearchingMgr.destination = tagBlock
    
    if SearchingMgr.onmove then 
        print("isMoving...")
        return nil 
    end

    local startPoint = Point.create(startBlock)
    local endPoint = Point.create(tagBlock)
    local presentPoint = Astar.findpath(startPoint,endPoint)
    if presentPoint == nil then 
        return nil
    end

    local path = {presentPoint.posId,}

    while presentPoint.parentPoint do
        table.insert(path, 1, presentPoint.parentPoint.posId)
        presentPoint = presentPoint.parentPoint
    end

    return path
end

---角色移动后检查，是否进战斗
function SearchingMgr.checkIfBattleAfterMove()
    --训练师战斗检查
    for _,var in pairs( AdvCharMgr.getTrainers() ) do
        if var.info.floor == SearchingMapMgr.currFloor then
            if SearchingMgr.itemTypeTable[var.info.pos].autoAttack == 1 then  --主动出击
                if SearchingMgr.eventStateInfoTable[var.info.pos] ~= 3 then  --未触发状态
                    if AdvCharMgr.check(var) then
                        SearchingUIMgr.TurnToBlock(var.info.pos)
                        AdvCharMgr.battle_(var)
                        return
                    end
                end
            end
        end
    end
end

---取消行动
function SearchingMgr.playerCancelMove()
end

---带回调移动
function SearchingMgr.moveWithCallback(i, callback)

    if LtMapOption.getMapType() == "LOSTTOWER" and not LostTowerMgr.canMove(i) then
        print("LT_DEBUG_INFO: lost tower -- not enough step")
        return 
    end

    --到達目的地
    if SearchingMgr.playerCurrPosition == i then
        print("reached.")
        PlayerAnimeMgr.playAni(DungeonPlayerMgr.getPlayerTag(), "idle", true)
        return
    end
    
    --以下情况点击均不响应
    if SearchingMgr.onmove then 
        print("moving")
        return 
    end
    if SearchingMgr.onbattle then 
        print("battling")
        return 
    end
    if not SearchingMgr.canMove then return end

    local x, y = LtMapOption.convertToCoord(i)

    --玩家在事件方格旁边，直接触发
    if SearchingMgr.checkPlayer(i) 
    and not LtMapOption.isReachable(x,y) --可达区域在后面行动后判断事件，如金币等事件仍需移动
    then 
        if callback ~= nil then
            callback(i)
            PlayerAnimeMgr.playAni(DungeonPlayerMgr.getPlayerTag(), "idle", true)
            return
        end
    end

    local destination = i
    local path    
    
    path = SearchingMgr.getPath(SearchingMgr.playerCurrPosition, destination)
    
    if path ~= nil then 
        local ss = path[1]
        --TODO check when player leaves
        --取去起點
        table.remove(path,1)
    else
        print("path nil")
        PlayerAnimeMgr.playAni(DungeonPlayerMgr.getPlayerTag(), "idle", true)
        return 
    end

    --path中移除不可達終點
    if SearchingMgr.mapInfoTable[i] == 1 then 
        table.remove(path,#path)
    elseif SearchingMgr.mapInfoTable[i] == 0 then
        local _col, _row = LtMapOption.convertToCoord(i)
        if not LtMapOption.isReachable(_col,_row) then 
            table.remove(path,#path)
        end
    else  --迷霧狀態爲2時方格按鈕禁用，不進此函式
    end

    local function moveto(path)
        if LtMapOption.getMapType() == "LOSTTOWER" and not LostTowerMgr.canMove(i) then
            PlayerAnimeMgr.playAni(DungeonPlayerMgr.getPlayerTag(), "idle", true)
            print("LT_DEBUG_INFO: lost tower -- not enough step")
            return
        end

        if SearchingMgr.onbattle then return end
        
        -- 寻路失败
        if not path or #path == 0 then
            if callback then callback(i) end
            return
        end
        
        -- 千层塔检查道具拾取
        if LtMapOption.getMapType() == "LOSTTOWER" and LtPropMgr.isPropBlock(path[1]) and LtPropMgr.isChecking then
            if LtPropMgr.isPropFull() then
                PlayerAnimeMgr.playAni(DungeonPlayerMgr.getPlayerTag(), "idle", true)
                LtPropMgr.checkPicking(path[1])
                return
            end
        end

        local id = path[1]
        SearchingMgr.playerNextStep = id
        
        for key,var in pairs( AdvCharMgr.getTrainers() ) do
            if AdvCharMgr.willTrainerStepIn(var, id) then
                return
            end
            
            if AdvCharMgr.willTrainerStepIn(var, SearchingMgr.playerCurrPosition) then
                return
            end
        end
        
        --设置当前方格装饰物Z值[在人物之下]
        SearchingUIMgr.setOrnamentZorder(SearchingMgr.playerCurrPosition, true)
        SearchingMgr.onmove = true
        
        SearchingMgr.player_dir = id - SearchingMgr.playerCurrPosition

        local movetime = 0.25

        DungeonMapMgr.checkScroll(id)
        DungeonPlayerMgr.checkPlayerAction(id, movetime)
        
        SearchingMgr.player:performWithDelay(function()
            local zorder = SearchingUIMgr.calcZOrderAt( id, true )
            SearchingMgr.player:setLocalZOrder( zorder )
        end, movetime / 2)
        
        SearchingMgr.player:performWithDelay(function()
            -- PlayerAnimeMgr.playAni(DungeonPlayerMgr.getPlayerTag(), "idle", true)
            
            if LtMapOption.getMapType() == "LOSTTOWER" then
                LostTowerMgr.LtMovedCallback(id)
            elseif LtMapOption.getMapType() == "COMMONDUNGEON" then
                
            end
            
            --設置player位置
            SearchingMgr.playerCurrPosition = id
            
            --检查设置装饰物品Z值[在人物之上]
            SearchingUIMgr.setOrnamentZorder(SearchingMgr.playerCurrPosition, false)
            table.remove(path, 1)
            SearchingMgr.onmove = false

            if #path <= 0 then
                PlayerAnimeMgr.playAni(DungeonPlayerMgr.getPlayerTag(), "idle", true)
            end
            
            --检查是否在敌方训练师警戒视野内
            if SearchingMapMgr.firstAdventure then   --引导限制
                --副本1中战斗限制，加引导
                print("first battle in adventure...")
            else
                for _,var in pairs( AdvCharMgr.getTrainers() ) do
                    if var.info.floor == SearchingMapMgr.currFloor then
                        if SearchingMgr.itemTypeTable[var.info.pos].autoAttack == 1 then  --主动出击
                            if SearchingMgr.eventStateInfoTable[var.info.pos] ~= 3 then  --未触发状态
                                if AdvCharMgr.check(var) then
                                    PlayerAnimeMgr.playAni(DungeonPlayerMgr.getPlayerTag(), "idle", true)
                                    
                                    AdvCharMgr.cancelWatching(var)  --cancel watching to avoid duplicate battle
                                    SearchingFuncMgr.check_(SearchingMgr.playerCurrPosition)
                                    SearchingUIMgr.TurnToBlock(var.info.pos)
                                    print("SearchingMgr module")
                                    AdvCharMgr.battle_(var)
                                    return
                                end
                            end
                        end
                    end
                end
            end
            
            --检查player经过方格事件
            if not SearchingFuncMgr.check_(SearchingMgr.playerCurrPosition) then
                print("////////////////   force    //////////////////")
                PlayerAnimeMgr.playAni(DungeonPlayerMgr.getPlayerTag(), "idle", true)
                SearchingMgr.cancelMove = false
                SearchingMgr.onmove = false
                return
            end
            
            --点击取消行动，并指向新的路径
            if SearchingMgr.cancelMove then
                print("////////////////   cancel   //////////////////")
                SearchingMgr.cancelMove = false
                local i = SearchingMgr.cancelAt
                local callback = SearchingFuncMgr.getEventFunc(i)
                SearchingMgr.moveWithCallback(i, function()
                    if callback ~= nil then
                        callback(i)
                    end
                end)
                return
            end
            
            if not SearchingMgr.canMove then
                return
            end
            
            if SearchingMgr.onbattle then
                return
            end

            if #path>0 then
                moveto(path)
            else
                if SearchingMgr.playerCurrPosition ~= i then  --player无法到达destination时[比如：解迷雾]
                    if callback ~= nil then 
                        callback(i)
                    end
                end
            end
        end, movetime)

    end
    if SearchingMgr.ADV_DEBUG then
        if path then
            for key, var in pairs(path) do
                print("~~~~~ ADV_DEBUG_INFO: path ~~~~~",key, var)
            end
        end
    end

    moveto(path)
    
end

---玩家点击其他位置，停止当前移动
function SearchingMgr.stopForCancel(block)
    
end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- 战斗结束后死宠后移
local function resortPetAfterBattle(detail)
    if not detail then return end

    local objidVec = detail.me.objID
    local hpVec    = detail.me.hp
    
    local function sortFunc(tab, hpTab)
        local ret = {}
        
        local deadPet = {}
        for i = 1, #tab do
            print("######hpTab######", i, tab[i], hpTab[tab[i]])
            if hpTab[tab[i]] and hpTab[tab[i]] > 0 then
                table.insert(ret, tab[i])
            else
                table.insert(deadPet, tab[i])
            end
        end
        
        for i = 1, #deadPet do
            table.insert(ret, deadPet[i])
        end
        
        return ret
    end

    local tmpTab = {}
    for i = 1, #objidVec do
        tmpTab[objidVec[i]] = hpVec[i]
    end
    
    for k,v in pairs(objidVec) do
        print("objidVec",k,v)
    end
    for k,v in pairs(hpVec) do
        print("hpVec",k,v)
    end
    for k,v in pairs(AdvPetsMgr.advArmy) do
        print(k,v)
    end
    
    if LtMapOption.getMapType() == "ADVENTURE" then
        AdvPetsMgr.advArmy = sortFunc(AdvPetsMgr.advArmy, tmpTab)
    elseif LtMapOption.getMapType() == "LOSTTOWER" then
        LtPetsMgr.LtArmy = sortFunc(LtPetsMgr.LtArmy, tmpTab)
    end
end

---进入战斗
--@param i int 战斗发生位置
--@param params table 战斗参数
function SearchingMgr.enterBattleAt(i, params)
    SearchingMgr.onbattle = true
    SearchingMapMgr.battlePos = i
    
    if LtMapOption.getMapType() == "LOSTTOWER" then
        LostTowerUIMgr.removeAllAnimation()
    end
    
    AdvPetsMgr.dealDamages(function()
        params[2].field = AdvEnvironmentMgr.getCurrentFieldType()
        params[2].weather = AdvEnvironmentMgr.getcurrentWeatherType()
        
        local tmpFunc = params[2].callback
        params[2].callback = function(detail)
            if detail.result == PLAYER_WIN then
                SearchingMgr.eventStateInfoTable[i] = 3
                resortPetAfterBattle(detail)
            else
                if LtMapOption.getMapType() == "ADVENTURE" then
                    SearchingMgr.isFailed = true
                end
            end
            
            tmpFunc(detail)
            
            if LtMapOption.getMapType() == "LOSTTOWER" then
                MapSeekerMgr.setSeekFunc(function()
                    LtPetsMgr.resortArmy(LtPetsMgr.LtArmy, LtPetsMgr.LtHelpArmy)
                end)
            end
        end
        
        LtExBufferMgr.setBuffBeforeBattle()
        BattleMapMgr.sendReBattleServe(params)
    end)
end

--
---检查战斗是否胜利
function SearchingMgr.checkBattleResult(scene)
    local result = SearchingMapMgr.battleResult
    print("?/////?",result)
    print("?/////?",SearchingMapMgr.battlePos)
    
    -- 传送boss检查
    if LtTransferViewMgr.transferBossInfo then
        print("check transfer boss battle result")
        LtTransferViewMgr.checkTransferBossResult(LtTransferViewMgr.transferBossInfo, result)
        LtTransferViewMgr.transferBossInfo = nil
        return
    end
    
    if result == PLAYER_WIN then
        SearchingMgr.canMove = true
        SearchingMgr.battle_win_at(SearchingMapMgr.battlePos)
        if SearchingMgr.eventAfterBattle then
            if SearchingMgr.eventAfterBattle["check"](SearchingMapMgr.currFloor, SearchingMapMgr.battlePos) then
                SearchingMgr.eventAfterBattle["func"]()
            end
        end
        return true
    else
        SearchingMgr.eventStateInfoTable[SearchingMapMgr.battlePos] = 1
        if LtMapOption.getMapType() == "LOSTTOWER" then
            return false
        end
        SearchingMgr.canMove = false
        SearchingMgr.adventure_failed(function()
            scene:performWithDelay(function()
                require("src.GameMgr.Searching.AdvFailedView").show()
            end,0.3)
        end)
    end
end


--+++++++++++++++++++++++++++训练师++++++++++++++++++++++++++++++++++++

---创建trainer
function SearchingMgr.createTrainer(block)
    print("SearchingMgr.createTrainer")
    
    SearchingUIMgr.hideBlock(block)
    
    -- local trainerFunc = SearchingFuncMgr.getEventFunc(block)
    -- trainerFunc(block)
    
    SearchingFuncMgr.battle_trainerFunc_At(block)

    if SearchingMgr.isAdventureEnd() then --初始時封鎖
        SearchingMgr.Lock_monsterAt(block, SearchingMapMgr.currFloor)
    end
end

function SearchingMgr.createNpc(block)
    if AdvCharMgr.getTrainerByPos(block) then return end
    
    SearchingUIMgr.hideBlock(block)

    local char = AdvCharMgr.createNpc({
        floor   = SearchingMapMgr.currFloor,
        pos     = block,
        res     = "",
    })
    AdvCharMgr.addTrainer(char)
end

--++++++++++++++++++++++++怪物邏輯+++++++++++++++++++++++++++++++++++++

---创建monster
--@param monsterType int 怪物类型
--@param monsterPos int 点击位置
--@param monsterId int ...
function SearchingMgr.createMonster(mType, block, monsterTag)
    mType = mType or nil
    SearchingUIMgr.initMonsterUI(mType, block, monsterTag)
    if SearchingMgr.isAdventureEnd() then --初始時封鎖
        SearchingMgr.Lock_monsterAt(block, SearchingMapMgr.currFloor)
    end
end


---怪物封鎖方格
--2015-09-26  增加传入参数floor
function SearchingMgr.monsterLock(col, row, floor)
    if col<=0 or col>LtMapOption.getMapCols()
    or row<=0 or row>LtMapOption.getMapRows()
    then
        return
    end
    
    floor = floor or SearchingMapMgr.currFloor
    local mapInfoTable = SearchingMapMgr.floorMapInfoTbl["floor"..floor]
    local monsterDefendInfo = SearchingMapMgr.floorMstrDefendTbl["floor"..floor]

    local block = LtMapOption.convertToIndex(col, row)
    if 1 == mapInfoTable[block] or 2 == SearchingMgr.mapInfoTable[block] then
        SearchingUIMgr.monsterLock(block)
        mapInfoTable[block] = 2
        monsterDefendInfo[block] = SearchingMgr.monsterDefendInfo[block] + 1
        SearchingMgr.printDefend()
    elseif 0 == mapInfoTable[block] then
    else
    end
end

---怪物封鎖周圍方格
function SearchingMgr.Lock_monsterAt(i, floor)
    floor = floor or SearchingMapMgr.currFloor
    local x, y = LtMapOption.convertToCoord(i)
    SearchingMgr.monsterLock(x-1,y-1,floor)
    SearchingMgr.monsterLock(x,y-1,floor)    
    SearchingMgr.monsterLock(x+1,y-1,floor)
    SearchingMgr.monsterLock(x-1,y,floor)
    SearchingMgr.monsterLock(x+1,y)
    SearchingMgr.monsterLock(x-1,y+1,floor)
    SearchingMgr.monsterLock(x,y+1,floor)
    SearchingMgr.monsterLock(x+1,y+1,floor)
end

---怪物死亡，解鎖方格
function SearchingMgr.unlockForMonsterDied(x, y)
    if x<=0 or x>LtMapOption.getMapCols() or y<=0 or y>LtMapOption.getMapRows() then
        return
    end

    local block = LtMapOption.convertToIndex(x, y)

    if 2 == SearchingMgr.mapInfoTable[block] then
        if  0 < SearchingMgr.monsterDefendInfo[block] then
            SearchingMgr.monsterDefendInfo[block] = SearchingMgr.monsterDefendInfo[block] - 1
            SearchingMgr.unlockBlock(x, y)
        end
    elseif 0 == SearchingMgr.mapInfoTable[block] then
        print("迷霧已解除")
    else
        print("+==+")
    end
end

---訓練師解鎖
function SearchingMgr.unlock4TrainerMovedOrFailed(block)
    print("unlock4TrainerMovedOrFailed:", block)
    local x, y = LtMapOption.convertToCoord(block)
    SearchingMgr.unlockForMonsterDied(x-1,y-1)
    SearchingMgr.unlockForMonsterDied(x,y-1)
    SearchingMgr.unlockForMonsterDied(x+1,y-1)
    SearchingMgr.unlockForMonsterDied(x-1,y)
    SearchingMgr.unlockForMonsterDied(x+1,y)
    SearchingMgr.unlockForMonsterDied(x-1,y+1)
    SearchingMgr.unlockForMonsterDied(x,y+1)
    SearchingMgr.unlockForMonsterDied(x+1,y+1)
    SearchingMgr.printDefend()
    print(">>>>>>>>>>>>>")
end

---战斗胜利,更新方格信息，注意区分训练师跟普通野怪
function SearchingMgr.battle_win_at(i)

    print("battle block:", i)
    
    SearchingMgr.canMove = true
    SearchingMgr.onbattle = false
    
    SearchingMgr.eventStateInfoTable[i] = 3   -- 训练师战败态
    
    if LtMapOption.getMapType() == "ADVENTURE" then
        --检查副本目标
        SearchingMgr.checkGoals(i)
    end
    
    if SearchingMgr.eventInfoTable[i] == SearchingMapMgr.EVENT_MONSTER then
        --monster死亡，刪除動畫，重新綁定底板点击事件
        local id = SearchingMgr.itemTypeTable[i].petnumber
        local resName = PokemonInfo.getPokemonResByID(id)
        if AnimationMgr.getGafObj(resName,i) then
            AnimationMgr.removeGafObjectByTag(resName, i)
        else
            AnimationMgr.removeGafObjectByTag("Spine/pet/default.png", i)
        end
        SearchingUIMgr.clearBlock(i)
    end
    
    if SearchingMgr.eventInfoTable[i] == SearchingMapMgr.EVENT_TRAINER
    or SearchingMgr.eventInfoTable[i] == LtEventOption.EVENT_OTHERTRAINER
    then
        local isDisappear = SearchingMgr.itemTypeTable[i].disappear
        if isDisappear == 1 then
            SearchingMgr.canMove = false
            local char = AdvCharMgr.getTrainerByPos(i)
            AdvCharMgr.turnTo(char, SearchingMgr.playerCurrPosition)
            PlayerAnimeMgr.playAni(char.info.aniTag,"death",true)
            SceneMgr.getRunningScene:performWithDelay(function()
                SearchingMgr.canMove = true
                local tag = SearchingMgr.itemTypeTable[i].tag
                AdvCharMgr.removeTrainer(AdvCharMgr.getTrainerByPos(i))
                SearchingMgr.itemTypeTable[i].tag              = tag
                SearchingMgr.itemTypeTable[i].trainerDisappear = true
            end,0.5)
        else
            -- 战败动画
            local char = AdvCharMgr.getTrainerByPos(i)
            PlayerAnimeMgr.playAni(char.info.aniTag,"death",true)
            char.info.nextStep = char.info.pos
        end
    end
    
    if LtMapOption.getMapType() == "ADVENTURE" then
        -- 检查通关副本标记
        if SearchingMapMgr.floorTargetBlocks["floor"..SearchingMapMgr.currFloor][i] == "99" then
            SearchingFuncMgr.exitFuncAt(i)
        end
    end

    local x, y = LtMapOption.convertToCoord(i)
    SearchingMgr.unlockForMonsterDied(x-1,y-1)
    SearchingMgr.unlockForMonsterDied(x,y-1)
    SearchingMgr.unlockForMonsterDied(x+1,y-1)
    SearchingMgr.unlockForMonsterDied(x-1,y)
    SearchingMgr.unlockForMonsterDied(x+1,y)
    SearchingMgr.unlockForMonsterDied(x-1,y+1)
    SearchingMgr.unlockForMonsterDied(x,y+1)
    SearchingMgr.unlockForMonsterDied(x+1,y+1)
    
    if LtMapOption.getMapType() == "ADVENTURE" then
        -- ...
    elseif LtMapOption.getMapType() == "LOSTTOWER" then
        -- 刷新宠物血量
        if #LtPetsMgr.petsAfterBattle > 0 then
            LtPetsMgr.updateArmyNodes(LtPetsMgr.petsAfterBattle)
            LtPetsMgr.petsAfterBattle = {}
        end
        
        local _col,_row = LtMapOption.convertToCoord(i)
        NetInterface.sendWithBlock("GC_FIREEVENTCELL_ACK", function()
            local LostTowerSend = require("src/Net/Send/LostTowerSend.lua")
            LostTowerSend.sendCG_fireEventCell_Req({ x=_row, y=_col, })
        end, function()
        end)
    end
    
end

---战斗失败，同时副本失败
function SearchingMgr.adventure_failed(callback)
    if NetInterface.isConnect then
        SearchingMgr.isFailed = true
        
        NetInterface.sendWithBlock("GC_FINISHADVENTURE_ACK", 
        function()
            local AdventureSend = require("src/Net/Send/AdventureSend.lua")
            AdventureSend.sendCG_FinishAdventure_Req({star=0,})  --星数为零挑战失败
        end, 
        function()
            callback()
        end, 
        function(code)
            TipsMgr.showError(nil,code)
        end)
    end
end


--++++++++++++++方格邏輯+++++++++++++++++++++++++++++++++++++++++

---檢查周圍是否有可經過的方格
function SearchingMgr.checkTonari(tag)
    local x, y = LtMapOption.convertToCoord(tag)
    if LtMapOption.isReachable(x,y-1) then return true end
    if LtMapOption.isReachable(x,y+1) then return true end
    if LtMapOption.isReachable(x-1,y) then return true end
    if LtMapOption.isReachable(x+1,y) then return true end
    return false
end

---获取四周方格ID
function SearchingMgr.getTonati(block)
    local ret = {}
    local col, row = LtMapOption.convertToCoord(block)
    table.insert(ret, LtMapOption.convertToIndex(col,row-1))
    table.insert(ret, LtMapOption.convertToIndex(col,row+1))
    table.insert(ret, LtMapOption.convertToIndex(col-1,row))
    table.insert(ret, LtMapOption.convertToIndex(col+1,row))
    return ret
end

---检查指定方格周围是否有玩家
function SearchingMgr.checkPlayer(tag)
    local x, y = LtMapOption.convertToCoord(tag)
    if LtMapOption.isOnBoard(x-1,y) and SearchingMgr.playerCurrPosition == LtMapOption.convertToIndex(x-1,y) then
        return true
    end
    if LtMapOption.isOnBoard(x+1,y) and SearchingMgr.playerCurrPosition == LtMapOption.convertToIndex(x+1,y) then
        return true
    end
    if LtMapOption.isOnBoard(x,y-1) and SearchingMgr.playerCurrPosition == LtMapOption.convertToIndex(x,y-1) then
        return true
    end
    if LtMapOption.isOnBoard(x,y+1) and SearchingMgr.playerCurrPosition == LtMapOption.convertToIndex(x,y+1) then
        return true
    end
    return false
end

---解鎖方格
--2015-09-26  增加传入参数floor
function SearchingMgr.unlockBlock(x, y, floor)
    if x<=0 or x>LtMapOption.getMapCols() or y<=0 or y>LtMapOption.getMapRows() then
        return
    end
    
    floor = floor or SearchingMapMgr.currFloor
    local mapInfoTable = SearchingMapMgr.floorMapInfoTbl["floor"..floor]
    local monsterDefendInfo = SearchingMapMgr.floorMstrDefendTbl["floor"..floor]
    
    local block = LtMapOption.convertToIndex(x, y)
    if 2 == mapInfoTable[block] then
        if 0 == monsterDefendInfo[block] then
            --print("解鎖一個方格")
            
            local t = SearchingMgr.getTonati(block)
            
            local function _check(_t, _i)
                for i = 1, #_t do
                    if _t[i] == _i then return true end
                end
                return false
            end
            
            if SearchingMgr.checkTonari(block) or _check(t, SearchingMapMgr.battlePos) then -- 训练师延时消失，为可达
                print("block", block)
                mapInfoTable[block] = 1
                if floor == SearchingMapMgr.currFloor then
                    SearchingUIMgr.activeSlab(block)
                end
            else
                local block_active = SearchingMapMgr.fogRes["active"]
                local block_locked = SearchingMapMgr.fogRes["locked"]["common"]
                SearchingUIMgr.setBlockImg(block,  block_active,  block_active,  block_locked)
            end
        end
    elseif 1 == mapInfoTable[block] then
        --print("方格已解鎖")
    else
        --print("可能是底板")
    end
    return block
end

---解鎖周圍四個方格
--2015-09-26  增加传入参数floor
function SearchingMgr.unlockTonari(block, floor)
    --打印
    local beginFlag = "******************  SearchingMgr.unlockTonari "..block.." *******************"
    local endFlag   = "*******************************   End   *************************************"
    SearchingMgr.printAllInfo(beginFlag,endFlag)
    
    floor = floor or SearchingMapMgr.currFloor

    local x, y = LtMapOption.convertToCoord(block)
    SearchingMgr.unlockBlock(x, y-1, floor)    --上
    SearchingMgr.unlockBlock(x, y+1, floor)    --下
    SearchingMgr.unlockBlock(x-1, y, floor)    --左
    SearchingMgr.unlockBlock(x+1, y, floor)    --右
end

---方格周圍動態發生變化時封鎖方格，如可推動石頭的移動
function SearchingMgr.lockBlock(x, y)
    --越界检查
    if not LtMapOption.isOnBoard(x, y) then
        return
    end

    local block = LtMapOption.convertToIndex(x,y)
    if SearchingMgr.mapInfoTable[block] ~= 0 then
        if not SearchingMgr.checkTonari(block) then
            SearchingMgr.mapInfoTable[block] = 2
            SearchingUIMgr.coverSlab(block)
        end
    end
end

---封鎖周圍四個方格
function SearchingMgr.lockTonari(block)
    local x, y = LtMapOption.convertToCoord(block)
    SearchingMgr.lockBlock(x, y-1)    --上
    SearchingMgr.lockBlock(x, y+1)    --下
    SearchingMgr.lockBlock(x-1, y)    --左
    SearchingMgr.lockBlock(x+1, y)    --右
end

---迷霧消除，更新MAP
--@param block int 消除迷霧所在方格
function SearchingMgr.mistHidAt(block)
    SearchingUIMgr.TurnToBlock(block)
    --人物動作
    local px, py = SearchingUIMgr.getBlockNode(SearchingMgr.playerCurrPosition):getPosition()
    local bx, by = SearchingUIMgr.getBlockNode(block):getPosition()
    --机关解锁迷雾时无人物动作
    if SearchingMgr.player and SearchingMgr.eventInfoTable[SearchingMgr.playerCurrPosition] ~= SearchingMapMgr.EVENT_SWITCH then
        transition.moveBy(SearchingMgr.player,{x=(bx-px)/8,y=(by-py)/8,time=0.1})
        SceneMgr.getRunningScene:performWithDelay(function()
            transition.moveBy(SearchingMgr.player,{x=(px-bx)/8,y=(py-by)/8,time=0.1})
        end,0.1)
    else
        print("player node 尚未创建")
    end

    SceneMgr.getRunningScene:performWithDelay(function()
        SearchingMgr.mapInfoTable[block] = 0

        local x, y = LtMapOption.convertToCoord(block)
        local eventType = SearchingMgr.eventInfoTable[block]
        
        --迷霧解鎖動畫, 事件UI顯示
        SearchingUIMgr.hideSlab(block)
        LtEventOption.createEvent(block)

        if LtMapOption.isReachable(x, y) then
            SearchingMgr.unlockTonari(block)
        end
        
        if SearchingMapMgr.EVENT_MONSTER == eventType or SearchingMapMgr.EVENT_TRAINER == eventType then
            SearchingMgr.Lock_monsterAt(block, SearchingMapMgr.currFloor)
        end
    end,0.2)
    
    -- 训练师事件，人物禁止行动  [防止拉怪]
    if SearchingMgr.eventInfoTable[block] == LtEventOption.EVENT_TRAINER then
        SearchingMgr.canMove = false
        SceneMgr.getRunningScene:performWithDelay(function()
            SearchingMgr.canMove = true
        end,0.5)
    end
end

---方格點擊事件，判斷可不可探索後進入後續
function SearchingMgr.blockClickedEvent(block)

    --点击效果
    local g_btn = SearchingUIMgr.getGroundNode(block)
    local effAni = AnimationMgr.createAni(g_btn, "Spine/effects/UI-fubendianji.png", 
        g_btn:getContentSize().width/2, 12+g_btn:getContentSize().height/2, block)
    AnimationMgr.playAniWithCallback(effAni.res, "animation", nil, block, true)
    
    AdvEnvironmentMgr.playSceneClickEffect(AdvEnvironmentMgr.getCurrentFieldType(),block)
    
    if 1 == SearchingMgr.mapInfoTable[block] and not SearchingMgr.checkPlayer(block) then  -- 迷霧還未探開
        local btn = SearchingUIMgr.getBlockNode(block)
        transition.stopTarget(btn)
        btn:setScale(SearchingUIMgr.getBlockContainer():getScale())
        local btnScaleX, btnScaleY = btn:getScaleX(), btn:getScaleY()
        local sequence = transition.sequence({
            cc.ScaleTo:create(0.15, btnScaleX*1.05, btnScaleY*0.9),
            cc.ScaleTo:create(0.1, btnScaleX*0.95, btnScaleY*1.12),
            --cc.ScaleTo:create(0.15, btnScaleX, btnScaleY*0.94),
            cc.ScaleTo:create(0.1, btnScaleX, btnScaleY),
        })
        btn:runAction(sequence)
    end

    --进入战斗，不响应点击事件
    if SearchingMgr.onbattle then return end
    if not SearchingMgr.canMove then return end

    --移动中，点击取消行动 [not canMove 时不可取消]
    if SearchingMgr.onmove and SearchingMgr.canMove then
        if block ~= SearchingMgr.destination then
            SearchingMgr.cancelMove = true  --移动取消标志 
            SearchingMgr.cancelAt = block
        end
        return
    end

    local x, y = LtMapOption.convertToCoord(block)

    --狀態爲0, 事件为空 -- move
    if SearchingMgr.mapInfoTable[block] == 0 then      -- 迷霧已探開
        if LtMapOption.isReachable(x, y) then
            SearchingMgr.moveWithCallback(block, nil)
        end
    elseif 1 == SearchingMgr.mapInfoTable[block] then  -- 迷霧還未探開
        if SearchingMgr.checkPlayer(block) then
            SearchingUIMgr.TurnToBlock(block)
            SearchingMgr.mapInfoTable[block] = 0
            SearchingMgr.mistHidAt(block)
        else
            SearchingMgr.moveWithCallback(block, function()
                if 1 == SearchingMgr.mapInfoTable[block] then
                    --portal时，强制传送，不解锁迷雾
                    if SearchingMgr.eventInfoTable[SearchingMgr.playerCurrPosition] ~= SearchingMapMgr.EVENT_PORTAL then
                        SearchingUIMgr.TurnToBlock(block)
                        SearchingMgr.mapInfoTable[block] = 0
                        SearchingMgr.mistHidAt(block)
                        return
                    end
                end
            end)
        end
    elseif 2 == SearchingMgr.mapInfoTable[block] then
    else
    end

    --打印
    local beginFlag = "******************  SearchingMgr.blockClickedEvent  *********************"
    local endFlag   = "****************************   End   ************************************"
    SearchingMgr.printAllInfo(beginFlag,endFlag)
    

end


--++++++++++++++++++item邏輯+++++++++++++++++++++++++++++++++

---创建事件物品，绑定响应函数
function SearchingMgr.createItem(block)
    if SearchingMgr.ADV_DEBUG then
        print("创建item at:",SearchingMapMgr.currFloor, block)
        print("type, subType:",SearchingMgr.eventInfoTable[block],SearchingMgr.itemTypeTable[block].name)
    end
        
    SearchingUIMgr.initItemUI(block)
    SearchingUIMgr.playAction(block, 1)

    SearchingUIMgr.bindBlockEvent(block, function()
        --移动中，点击取消行动
        if SearchingMgr.onmove and SearchingMgr.canMove then
            if block ~= SearchingMgr.destination then
                SearchingMgr.cancelMove = true  --移动取消标志 
                SearchingMgr.cancelAt = block
            end
            return
        end
        --进入战斗，不响应点击事件
        if SearchingMgr.onbattle then 
            print("battling")
            return 
        end

        SearchingMgr.moveWithCallback(block, function()
            local callback = SearchingFuncMgr.getEventFunc(block)
            if callback then callback(block) end
        end)
    end)
    
end


--+++++++++++++  测试输出      +++++++++++++++

---輸出所有信息
function SearchingMgr.printAllInfo(beginFlag,endFlag)
    if not SearchingMgr.ADV_DEBUG then return end
    print(beginFlag)
    SearchingMgr.printMap()
    SearchingMgr.printEvent()
    SearchingMgr.printEventState()
    SearchingMgr.printDefend()
    print(endFlag)
end

function SearchingMgr.printMap()
    if not SearchingMgr.ADV_DEBUG then return end
    print("+==================MapInfo===================+")
    local cols = LtMapOption.getMapCols()
    for i=1, LtMapOption.getMapRows() do
        local s = ""
        for j=1, LtMapOption.getMapCols() do
            s = s..SearchingMgr.mapInfoTable[cols*(i-1)+j]..", "
        end
        print(s)
        s = ""
    end
    print("+============================================+")
end

function SearchingMgr.printEvent()
    if not SearchingMgr.ADV_DEBUG then return end
    print("+===============EventInfo===================+")
    local cols = LtMapOption.getMapCols()
    for i=1, LtMapOption.getMapRows() do
        local s = ""
        for j=1, LtMapOption.getMapCols() do
            s = s..SearchingMgr.eventInfoTable[cols*(i-1)+j]..", "
        end
        print(s)
        s = ""
    end
    print("+============================================+")
end

function SearchingMgr.printEventState()
    if not SearchingMgr.ADV_DEBUG then return end
    print("+===============EventState===================+")
    local cols = LtMapOption.getMapCols()
    for i=1, LtMapOption.getMapRows() do
        local s = ""
        for j=1, LtMapOption.getMapCols() do
            s = s..SearchingMgr.eventStateInfoTable[cols*(i-1)+j]..", "
        end
        print(s)
        s = ""
    end
    print("+============================================+")
end

function SearchingMgr.printDefend()
    if not SearchingMgr.ADV_DEBUG then return end
    print("+===============DefendInfo===================+")
    local cols = LtMapOption.getMapCols()
    for i=1, LtMapOption.getMapRows() do
        local s = ""
        for j=1, LtMapOption.getMapCols() do
            s = s..SearchingMgr.monsterDefendInfo[cols*(i-1)+j]..", "
        end
        print(s)
        s = ""
    end
    print("+============================================+")
end

return SearchingMgr