local LTGuideMgr = {}

function LTGuideMgr.test()
    print("LTGuideMgr-test")
end

function LTGuideMgr.FirstGuide(finishCallback)
    if LostTowerMgr.currentFloor ~= 1 then
        if finishCallback then finishCallback() end
        return
    end

    local questID = {40000,40001,40002,40003,40004,40005}
    
    local node1 = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName,"step_point_db")
    local node2 = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,"floor_info_button")
    local node3 = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,"effect_info_button")
    local node4 = SearchingUIMgr.getBlockNode(23)  -- key
    local node5 = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_r, "key_db")  -- key board
    local node6 = SearchingUIMgr.getBlockNode(32)  -- box
    local node7 = LtPetsMgr.LtArmyPetNodes[1]      -- petNode

    local _node3 = SearchingUIMgr.getBlockNode(23) -- gettint item
    local _node4 = SearchingUIMgr.getBlockNode(24) -- key
    local _node5 = SearchingUIMgr.getBlockNode(25) -- box
    local _node6 = SearchingUIMgr.getBlockNode(33) -- trap
    
    local function Introduction(callback)
        if SearchingMgr.playerCurrPosition ~= 21 then
            if callback then callback() end
            return
        end
        
        local _node1 = SearchingUIMgr.getBlockNode(22)
        local _node2 = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName,"step_point_db")
        
        NpcDialogueMgr.show(questID[1],function()
            CocosModuleMgr.setButtonGuide(_node1,2.5,function()
                CocosModuleMgr.setNodeHint(_node2,2.5,function()
                    NpcDialogueMgr.show(questID[2], function()
                        SceneMgr.getRunningScene:performWithDelay(function()
                            if callback then callback() end
                        end,0.5)
                    end) -- end of quest
                end)
            end) -- end of _node1
        end)
    end
    
    -- 千层塔记录显示
    local function ShowPickingRecord(callback)
        
        if callback then 
            callback() 
        end
        
        -- 后面不要了
--        if SearchingMgr.playerCurrPosition ~= 22 then 
--            if callback then callback() end
--            return
--        end
--        local _node1 = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,"floor_info_button")
--        local _node2 = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,"effect_info_button")
--        NpcDialogueMgr.show(questID[3])
--        
--        CocosModuleMgr.setButtonGuide(_node1,2.5, function()
--            CocosModuleMgr.setButtonGuide(_node1,2.5, function()
--                CocosModuleMgr.setButtonGuide(_node2,2.5, function()
--                    CocosModuleMgr.setButtonGuide(_node2,2.5, function()
--                        NpcDialogueMgr.hide()
--                        if callback then callback() end
--                    end)
--                end)
--            end)
--        end)
    end
    
    local function getItem(callback)
        if SearchingMgr.eventInfoTable[23] == LtEventOption.EVENT_VOID then
            if callback then callback() end
            return
        end
        
        CocosModuleMgr.setButtonGuide(_node3,2.5,function()
            UnblockLoader.addCallback("AwardsListMgr-reset", function()
                local okbtn = CSResourceMgr.getNodeByName("Item/awardInfoView.csb", "ok")
                CocosModuleMgr.setButtonGuide(okbtn, 2.5, function()
                    SceneMgr.getRunningScene:performWithDelay(function()
                        if callback then callback() end
                    end,0.5+0.5)
                end)
            end, 1)
--            SceneMgr.getRunningScene:performWithDelay(function()
--                local resName = "Item/awardInfoView.csb"
--                local ok =  CSResourceMgr.getNodeByName(resName,"ok")
--                local tmpFunc = CSResourceMgr.ButtonFuncTable[ok]
--                
--                CocosModuleMgr.setButtonGuide(ok, 2.5, function()
--                    SceneMgr.getRunningScene:performWithDelay(function()
--                        if callback then callback() end
--                    end,0.5)
--                end)
--            end,0.5+1.0)
        end)
    end
    
    -- 获得钥匙
    local function getKeys(callback)
        if SearchingMgr.eventInfoTable[24] == LtEventOption.EVENT_VOID then
            if callback then callback() end
            return
        end
    
        local function f()
            CocosModuleMgr.setNodeHint(node5,3.5,function()
                NpcDialogueMgr.show(questID[4], function()
                    if callback then callback() end
                end)
            end)
        end
        
        CocosModuleMgr.setButtonGuide(_node4,2.5,function()
            UnblockLoader.addCallback("AwardsListMgr-reset", function()
                local okbtn = CSResourceMgr.getNodeByName("Item/awardInfoView.csb", "ok")
                CocosModuleMgr.setButtonGuide(okbtn, 2.5, function()
                    SceneMgr.getRunningScene:performWithDelay(function()
                        f()
                    end,0.5)
                end)
            end, 1) 
--            SceneMgr.getRunningScene:performWithDelay(function()
--                local resName = "Item/awardInfoView.csb"
--                local ok =  CSResourceMgr.getNodeByName(resName,"ok")
--                local tmpFunc = CSResourceMgr.ButtonFuncTable[ok]
--                
--                CocosModuleMgr.setButtonGuide(ok,2.5,function()
--                    SceneMgr.getRunningScene:performWithDelay(function()
--                        f()
--                    end,0.5)
--                end)
--            end,0.5+1.0)
        end)
    end
    
    -- 打开宝箱
    local function openBox(callback)
        if SearchingMgr.eventStateInfoTable[25] ~= 1 then
            if callback then callback() end
            return
        end
        
        CocosModuleMgr.setButtonGuide(_node5,2.5,function()
            SceneMgr.getRunningScene:performWithDelay(function()
                local tmpNode = CSResourceMgr.getNodeByName("LostTower/Others/OpenBoxView.csb",{"board", "open"},"LtOpenBoxView")
                CocosModuleMgr.setButtonGuide(tmpNode,2.5,function()
                    UnblockLoader.addCallback("AwardsListMgr-reset", function()
                        local okbtn = CSResourceMgr.getNodeByName("Item/awardInfoView.csb", "ok")
                        CocosModuleMgr.setButtonGuide(okbtn, 2.5, function()
                            SceneMgr.getRunningScene:performWithDelay(function()
                                if callback then callback() end
                            end,0.5)
                        end)
                    end, 1)
--                    SceneMgr.getRunningScene:performWithDelay(function()
--                        local resName = "Item/awardInfoView.csb"
--                        local ok =  CSResourceMgr.getNodeByName(resName,"ok")
--                        local tmpFunc = CSResourceMgr.ButtonFuncTable[ok]
--                        
--                        CocosModuleMgr.setButtonGuide(ok,2.5,function()
--                            SceneMgr.getRunningScene:performWithDelay(function()
--                                if callback then callback() end
--                            end,0.5)
--                        end)
--                    end,0.5+1.0)
                end)
            end,0.5)
        end)
    end
    
    -- trap guide  ## 不引导了
    local function trapGuide(callback)
        if LtHealViewMgr.recoverCount ~= 0 then
            if callback then callback() end
            return
        end
        
        local tmpNode1 = CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName, "targets") -- menu button
        local tmpNode2 = CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,{"menu_db","menu1"}) -- heal button
        CocosModuleMgr.setButtonGuide(_node6,2.5,function()
            SceneMgr.getRunningScene:performWithDelay(function()
                NpcDialogueMgr.show(questID[5], function()
                    CocosModuleMgr.setButtonGuide(tmpNode1,2.5,function()
                        SceneMgr.getRunningScene:performWithDelay(function()
                            CocosModuleMgr.setButtonGuide(tmpNode2,2.5,function()
                                SceneMgr.getRunningScene:performWithDelay(function()
                                    local tmpNode3 = CSResourceMgr.getNodeByName("LostTower/Menu/HealView.csb",{"db","okay"})
                                    CocosModuleMgr.setButtonGuide(tmpNode3,2.5,function()
                                        CSResourceMgr.callButtonFunc(LostTowerUIMgr.bottomResName, "targets")
                                        SceneMgr.getRunningScene:performWithDelay(function()
                                            NpcDialogueMgr.show(questID[6], function()
                                                if callback then callback() end
                                            end)
                                        end,0.5)
                                    end)
                                end,0.5)
                            end)
                        end,0.5)
                    end)
                end)
            end,0.5)
        end)
    end
    
    local function showMenuFunc(callback)
        local node0 = CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName, "targets")
        local node1 = CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,{"menu_db","menu4"})
        local node2 = CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,{"menu_db","menu3"})
        local node3 = CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,{"menu_db","menu2"})
        local node4 = CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,{"menu_db","menu1"})
        local node5 = CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,"package")
        
        local quest = {40004, 40005, 40007, 40008, 40009}
        local nodes = {node1, node2, node3, node4, node5}
        
        local function __process(id)
            if id <= #nodes then
                CocosModuleMgr.setNodeHint(nodes[id], 2.5, function()
                    CocosModuleMgr.setScreenTouch(false)
                    NpcDialogueMgr.show(quest[id], function()
                        __process(id + 1)
                    end)
                end)
            else
                CocosModuleMgr.setButtonGuide(node0, 2.5, function()
                    if callback then callback() end
                end)
            end
        end
        
        NpcDialogueMgr.show(40010, function()
            CocosModuleMgr.setButtonGuide(node0, 2.5, function()
                __process(1)
            end)
        end)
    end
    
    -- boss battle 
    local function bossGuide(callback)
        local tmpNode1 = SearchingUIMgr.getBlockNode(34)
        
        NpcDialogueMgr.show(40011, function()
            CocosModuleMgr.setButtonGuide(tmpNode1,2.5,function()
                if callback then callback() end
            end)
        end)
    end

    CocosModuleMgr.setScreenTouch(false, "t0")
    local resName = "Scene/CommonMask.csb", "mask"
    local tag = "setScreenToucht0"
    CSResourceMgr.clickEventBinding(resName, "mask", function()
        print("block button event")
    end, tag, nil, "")
    
    Introduction(function()
        ShowPickingRecord(function()
            getItem(function()
                getKeys(function()
                    openBox(function()
                        showMenuFunc(function()
                            bossGuide(function()
                                if finishCallback then finishCallback() end
                                CocosModuleMgr.setScreenTouch(true, "t0")
                            end)
                        end)
                    end)
                end)
            end) -- end of getItem
        end)
    end)
end

function LTGuideMgr.SecondGuide(finishCallback)
    print("Losttower second tutorial")
    
    local checkFloor = 5
    local bossPos
    
    if LostTowerMgr.currentFloor ~= checkFloor then return end
    
    local foundFlag = false
    local currQuestInfos = QuestInfo.getCurQuestInfos()
    for k, v in pairs(currQuestInfos) do
        if v.questID == 10019 then
            foundFlag = true
            break
        end
    end
    if not foundFlag then return end
    
    for i = 1, LtMapOption.getMapSize() do
        if SearchingMgr.eventInfoTable[i] == LtEventOption.EVENT_LTBOSS then
            bossPos = i
        end
    end
    if not bossPos then return end
    
    local button = SearchingUIMgr.getBlockNode(bossPos)
    local tmpFunc = CSResourceMgr.ButtonFuncTable[button]
    
    local function checkReward(_callback)
        local resName = "Item/awardInfoView.csb"
        
        if CSResourceMgr.getCsbObj(resName) then
            local ok =  CSResourceMgr.getNodeByName(resName,"ok")
            local tmpFunc = CSResourceMgr.ButtonFuncTable[ok]
    
            CSResourceMgr.clickEventBinding(resName, "ok", function()
                CocosModuleMgr.setScreenTouch(false)
                if tmpFunc~=nil then
                    tmpFunc()
                end
                SceneMgr.getRunningScene:performWithDelay(function()
                    if _callback then _callback() end
                end,0.5)
            end)
            CSResourceMgr.clickEventBinding(resName, "bg", function()
                CSResourceMgr.callButtonFunc(resName, "ok")
            end)
            CocosModuleMgr.setScreenTouch(true)
        else
            if _callback then _callback() end
        end
    end
    
    local function transferFunc(_callback)
        local questID = { 40006, }
        checkReward(function()
            CocosModuleMgr.setScreenTouch(false)
            NpcDialogueMgr.show(questID[1],function()
                local tmpNode1 = CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName, "targets") -- menu button
                local tmpNode2 = CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,{"menu_db","menu2"}) -- heal button
                SceneMgr.getRunningScene:performWithDelay(function()
                    CocosModuleMgr.setButtonGuide(tmpNode1,2.5,function()
                        SceneMgr.getRunningScene:performWithDelay(function()
                            CocosModuleMgr.setButtonGuide(tmpNode2,2.5,function()
                                CocosModuleMgr.setScreenTouch(true)
                                if _callback then _callback() end
                            end)
                        end,0.5)
                    end)
                end,0.5)
            end)
        end)
    end

    if SearchingMgr.eventStateInfoTable[bossPos] == 3 then
        button:performWithDelay(function()
            transferFunc(function()
                QuestInfo.sendQuestFinished(10019)
                print("~~~~~~~~~~~~~~~~~~~~~~~~~  End tutorial")
            end)
        end,0.5)
        
        return
    end
    
    CSResourceMgr.clickEventBindingByNode(button,function()
        tmpFunc()
        
        MapSeekerMgr.SeekFunc = function()
            if SceneMgr.currentScene ~= "BattleScene" then
                return 
            end
            
            MapSeekerMgr.SeekFunc = function()
                if SceneMgr.currentScene ~= "LostTowerScene" then
                    return
                end
                SceneMgr.getRunningScene:performWithDelay(function()
                    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>",SearchingMgr.eventStateInfoTable[bossPos])
                    if SearchingMgr.eventStateInfoTable[bossPos] == 3 then
                        transferFunc(function()
                            QuestInfo.sendQuestFinished(10019)
                            print("~~~~~~~~~~~~~~~~~~~~~~~~~  End tutorial")
                        end)
                    end
                end,0.5)
            end
        end
    end)
    
    print("Second tutorial end")
end

return LTGuideMgr