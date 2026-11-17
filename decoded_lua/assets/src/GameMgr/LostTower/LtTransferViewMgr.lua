local LtTransferViewmgr = {}

local resName = "LostTower/Menu/TransferView.csb"

local floorTable = {}
local currSelect = 0

function LtTransferViewmgr.Init()
    floorTable = {}
    currSelect = 0
end

LtTransferViewmgr.transferBossInfo = nil

function LtTransferViewmgr.challengeTransferBoss(floor, callback)
    if not LostTowerMgr.hasEnoughSteps(floor - 1) then
        StandardTipsMgr.show(1, "LtTips24")   -- "步数不够"
        return
    end

    local trainerInfo = {
        field           = 2,
        weather         = GetRandom.random(1,7),
        type            = Proto.BTT_LOSTTOWER_JUMP_BOSS,
        GroupID         = 0,
        battleTypeSubID = floor,
        callback        = function(detail)
            LtTransferViewmgr.transferBossInfo = {floor = floor}
        
            SearchingMapMgr.battleResult = detail.result
            if detail.result ~= PLAYER_WIN then return end  -- 0:失败 1:胜利 2:平局

            detail.me.hp = LtPlayerMgr.recoverFromFashion(detail.me.objID, detail.me.hp)

            LtPetsMgr.petsAfterBattle, _ = LtPetsMgr.handleHpAfterBattle(detail.me.objID, detail.me.hp)

            BattleMapMgr.sendGameOver(detail.result,detail.me)
        end,
    }
    BattleMapMgr.sendReBattleServe({true, trainerInfo})
end

function LtTransferViewmgr.checkTransferBossResult(data, result)
    if not data then return end
    
    if result ~= PLAYER_WIN then
        print("战斗失败不给传送...")
        return
    end

    NetInterface.sendWithBlock("GC_TRANSFERFLOOR_ACK", function()
        local LostTowerSend = require("src.Net.Send.LostTowerSend")
        LostTowerSend.sendCG_TransferFloor_Req({floor = data.floor,})
    end, function()
        LtFuncMgr.transferEffect(SearchingMgr.playerCurrPosition, function()
            LtFuncMgr.resetEffect(function()
                print("effect end...")
            end)
        end)

        local TaskWatcherManager = require("src.GameMgr.TaskWatcher.TaskWatcherManager")
        TaskWatcherManager.saveLostTowerResultState("losttowerchuansong")
    end)
end

LtTransferViewmgr.transferFreeFlag = 0
function LtTransferViewmgr.getFreeFlag(callback)
    NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
        local LoginSend = require("src.Net.Send.LoginSend")
        LoginSend.sendCG_GetCharacterValues_Req({
            "lostTowerFreeTransfer"})
    end, function()
        LtTransferViewmgr.transferFreeFlag = CharInfo.get().losttowerfreetransfer
        if callback then callback() end
    end, function(code)
        StandardTipsMgr.show(1,"get transfer free code failed:"..code)
    end)
end

function LtTransferViewmgr.show(scene)
    UIStack.push("LtTransferViewmgr",LtTransferViewmgr.hide)

    local function loadCSB()

        local layer = CSResourceMgr.createRes(scene,resName)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.setFullScreen(resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)

        CSResourceMgr.getNodeByName(resName,"db"):setVisible(false)
        
        floorTable = {}
        
        --title
        CSResourceMgr.setLabelColor(resName,{"db","title"},{r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelString(resName,{"db","title"},"LtTransfer1","",{r=38,g=54,b=76,a=255})  -- "传送"
        CSResourceMgr.getNodeByName(resName,"help"):setVisible(false)  -- 隐藏帮助按钮
        
        -- current floor
        CSResourceMgr.setLabelColor(resName,{"db","db2","curr_flo_t"},{r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelString(resName,{"db","db2","curr_flo_t"},"LtTransfer2","",{r=0,g=0,b=0,a=255},nil,80)  -- "当前层数"
        CSResourceMgr.setLabelString(resName,{"db","db2","curr_flo_n"},LostTowerMgr.currentFloor,"",{r=0,g=0,b=0,a=255})

        CSResourceMgr.setLabelString(resName,{"db","db2","mcash_n"},CharInfo.getMCash())
        
        -- consume
        CSResourceMgr.setLabelColor(resName,{"db","db2","consume_t"},{r=249,g=221,b=155,a=255})
        CSResourceMgr.setLabelString(resName,{"db","db2","consume_t"},"LtTransfer3","",{r=0,g=0,b=0,a=255},nil,100)   -- "消耗"
        CSResourceMgr.setLabelString(resName,{"db","db2","consume_n"},0,"",{r=0,g=0,b=0,a=255})
        
        CSResourceMgr.setButtonString(resName,{"db","preview"},"LtTransfer5",nil,{r=1,g=0,b=0,a=255,w=1,s=1})  -- 宠物预览
        CSResourceMgr.setButtonString(resName,{"db","okay"},"LtYes",nil,{r=1,g=0,b=0,a=255,w=1,s=1})   -- 确定
        
        CSResourceMgr.setLabelString(resName,"tip","losttips1","")   -- "传送消耗提醒"
    end

    local function playCSB()
        CSResourceMgr.getNodeByName(resName,"db"):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName,"db"), "down")
    end
    
    local function initFloors()
        
        local floorLimited = SystemInfo.getGlobalConfigAddInfoByID(50001).values[1]
        local maxFloor = LostTowerMgr.recordingPoint > floorLimited and floorLimited or LostTowerMgr.recordingPoint
        for i = 1, maxFloor do
            local transferInfo = LostTowerInfo.getTransferInfoById(i)
            if transferInfo then
                table.insert(floorTable,i)
            end
        end
        LtTransferViewmgr.resetFloors(floorTable)
        
    end

    local function buttonBinding()
    
        CSResourceMgr.clickEventBinding(resName,{"db","close"},function()
            LtTransferViewmgr.hide()
        end)
        
        CSResourceMgr.clickEventBinding(resName,{"db","preview"},function()
            if currSelect == 0 then
                StandardTipsMgr.show(1, "LtTips16")  -- "未选择传送层..."
                return 
            end
            LtChangeFloorView.show(SceneMgr.getRunningScene, floorTable[currSelect],nil,nil,2)
        end)
        
        CSResourceMgr.clickEventBinding(resName,{"db","okay"},function()
            if currSelect == 0 then
                StandardTipsMgr.show(1, "LtTips16")  -- "未选择传送层..."
                return 
            end
            
            local consumeID = LostTowerInfo.getTransferInfoById(floorTable[currSelect]).consume
            local consume = ItemInfo.getConsumeElementInfoById(consumeID)
            
            -- 免费标记检查
            local consume_num = consume.num
            if LtTransferViewmgr.transferFreeFlag == 1 then
                consume_num = 0
            end
            
            if CharInfo.getMCash() < consume_num then
                StandardTipsMgr.show(1,"tips14")
                return
            end
            
            -- 目标传送层比当前层高时，需要进行boss挑战
            print("当前层，目标传送层：", LostTowerMgr.currentFloor, floorTable[currSelect])
            if LostTowerMgr.currentFloor < floorTable[currSelect] then
                LtTransferViewmgr.challengeTransferBoss(floorTable[currSelect])
                LtTransferViewmgr.hide()
                CSResourceMgr.callButtonFunc(LostTowerUIMgr.bottomResName, "targets")
            else
                NetInterface.sendWithBlock("GC_TRANSFERFLOOR_ACK", function()
                    local LostTowerSend = require("src.Net.Send.LostTowerSend")
                    LostTowerSend.sendCG_TransferFloor_Req({floor = floorTable[currSelect],})
                end, function()
                    LtTransferViewmgr.hide()
                    
                    -- 触发菜单按钮[关闭菜单]
                    CSResourceMgr.callButtonFunc(LostTowerUIMgr.bottomResName, "targets")
                    
                    LtFuncMgr.transferEffect(SearchingMgr.playerCurrPosition, function()
                        LtFuncMgr.resetEffect(function()
                            print("effect end...")
                        end)
                    end)
                    
                    local TaskWatcherManager = require("src.GameMgr.TaskWatcher.TaskWatcherManager")
                    TaskWatcherManager.saveLostTowerResultState("losttowerchuansong")
                end)
            end
        end)
        
    end

    local funcTable = {loadCSB, playCSB, initFloors, buttonBinding}

    LtTransferViewmgr.getFreeFlag(function()
        UnblockLoader.load(funcTable,"LtTransferViewmgr")
    end)

    --    for i=1,#funcTable do
    --        funcTable[i]()
    --    end

end

function LtTransferViewmgr.hide()
    UIStack.pop("LtTransferViewmgr")
    currSelect = 0
    floorTable = {}
    UnblockLoader.cancel("LtTransferViewmgr")
    UnblockLoader.cancel(" LtTransferViewmgr-reset")
    CSResourceMgr.getNodeByName(resName,{"db","db2","floList"}):removeAllItems()
    CSResourceMgr.removeCSObjectByTag(resName)
end

function LtTransferViewmgr.resetFloors(floors)
    local funcTable = {}

    local list = CSResourceMgr.getNodeByName(resName,{"db","db2","floList"})
    local sample = CSResourceMgr.getNodeByName(resName,"flo_bar")
    local panelTable = {}
    
    local texture1 = "UI/CommonFiles/tower_transfer_label_nomal_su.png"
    local texture2 = "UI/CommonFiles/tower_transfer_label_selected_su.png"
    
    local c_textColor1 = {r=217,g=234,b=255,a=255}
    local c_outline2 = {r=11,g=17,b=67,a=255}
    local c_textColor2 = {r=255,g=252,b=0,a=255}
    
    for i=1, #floors do
        local panel = sample:clone()
        table.insert(panelTable, panel)
        list:pushBackCustomItem(panel)
        
        local function itemFunc()
            CSResourceMgr.setButtonStringByNode(panel,CocosModuleMgr.createStringWithFormat({"LtTransfer4",floors[i]}),c_outline2)  -- floors[i].."层"
            CSResourceMgr.setButtonStringColorByNode(panelTable[currSelect],c_textColor1)
            
            CSResourceMgr.clickEventBindingByNode(panel,function()
                if currSelect == i then
                    return
                end
                if currSelect ~= 0 then
                    CSResourceMgr.setButtonEnabledByNode(panelTable[currSelect],true)
                    --CSResourceMgr.setButtonTextureByNode(panelTable[currSelect],texture1,texture2,texture2)
                    CSResourceMgr.setButtonStringColorByNode(panelTable[currSelect],c_textColor1)
                    --panelTable[currSelect]:setContentSize(400, 60)
                end
                currSelect = i
                CSResourceMgr.setButtonEnabledByNode(panelTable[currSelect],false)
                --CSResourceMgr.setButtonTextureByNode(panelTable[currSelect],texture2,texture2,texture2)
                CSResourceMgr.setButtonStringColorByNode(panelTable[currSelect],c_textColor2)
                --panelTable[currSelect]:setContentSize(400, 60)
                
                local consumeID = LostTowerInfo.getTransferInfoById(floors[i]).consume
                local consume = ItemInfo.getConsumeElementInfoById(consumeID)
                for k,v in pairs(consume) do
                    print(k,v)
                end
                print("\n")
                
                -- 免费标记检查
                local consume_num = consume.num
                if LtTransferViewmgr.transferFreeFlag == 1 then
                    consume_num = 0
                end
                
                CSResourceMgr.setLabelString(resName,{"db","db2","consume_n"},consume_num,"",{r=0,g=0,b=0,a=255})
            end)
            
            panel:setScaleX(0)
            transition.scaleTo(panel, {scaleX = 1, time = 0.1})
        end
        table.insert(funcTable,itemFunc)
    end

    UnblockLoader.load(funcTable,"LtTransferViewmgr-reset")
end

return LtTransferViewmgr