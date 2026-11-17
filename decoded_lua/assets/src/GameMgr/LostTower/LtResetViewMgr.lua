local LtResetViewMgr = {}

-- 直接用恢复弹窗资源
local resName = "LostTower/Menu/HealView.csb"
local tag = "LtResetViewMgr"

local cunsumeID  = 0
local consumeNum = 0
LtResetViewMgr.resetTime  = 0
LtResetViewMgr.resetCount = 0

function LtResetViewMgr.Init()
    cunsumeID  = 0
    consumeNum = 0
    LtResetViewMgr.resetTime  = 0
    LtResetViewMgr.resetCount = 0
end

function LtResetViewMgr.show(scene)
    UIStack.push("LtResetViewMgr",LtResetViewMgr.hide)
    GameAudio.playUISound("popup")

    local function loadCSB()

        local layer = CSResourceMgr.createRes(scene,resName,tag)
        CSResourceMgr.setRelativePosition(resName, 320, 480, tag)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)

        -- title
        CSResourceMgr.setLabelColor(resName,{"db","title"},{r=144,g=238,b=255,a=255},tag)
        CSResourceMgr.setLabelString(resName,{"db","title"},"LtReset1",tag,{r=38,g=54,b=76,a=255})  -- "恢复"
        CSResourceMgr.getNodeByName(resName,"help",tag):setVisible(false)  -- 隐藏帮助按钮

        -- desc
        CSResourceMgr.setLabelColor(resName,{"db","db2","desc_db","heal_desc"},{r=217,g=243,b=255,a=255},tag)
        CSResourceMgr.setLabelString(resName,{"db","db2","desc_db","heal_desc"},"LtReset2",tag,{r=11,g=17,b=67,a=255})  -- "是否恢复所有宠物状态？"

        -- mcash
        local c0 = {r=11,g=17,b=67,a=255}
        local c1 = {r=217,g=234,b=255,a=255}
        CSResourceMgr.setLabelColor(resName,{"db","db2","mcash_n"},c1,tag)
        CSResourceMgr.setLabelString(resName,{"db","db2","mcash_n"},CharInfo.getMCash(),tag)

        -- 重置计数/消耗
        if not LtResetViewMgr.resetCount then LtResetViewMgr.resetCount = 0 end
        
        local offsetTime = 24*3600
        local t1 = LtResetViewMgr.resetTime 
        local t2 = CharInfo.getServerTime()
        local dayDiff = CocosModuleMgr.getDayTimeDiff(t1,t2,offsetTime)
        if dayDiff ~= 0 then -- 非同一天
            print("test")
            LtResetViewMgr.resetCount = 0
        end
        
        local count = LtResetViewMgr.resetCount + 1
        local resetInfo = LostTowerInfo.getLostTowerResetInfoById(count)
        if not resetInfo then 
            local infoConfig = require("src.DatReader.LostTowerResetInfoConfig")
            local _id = infoConfig.getEntryID(infoConfig.getEntryCount())
            local coumsumeID = LostTowerInfo.getLostTowerResetInfoById(_id).consume
            consumeNum = ItemInfo.getConsumeElementInfoById(coumsumeID).num
        else
            local consumeID = resetInfo.consume
            local consume = ItemInfo.getConsumeElementInfoById(consumeID)
            consumeNum = consume.num
        end
        
        CSResourceMgr.setLabelString(resName,{"db","db2","consume_n"},consumeNum,tag,nil)
        CSResourceMgr.setLabelString(resName,{"db","db2","consume_desc"},CocosModuleMgr.createStringWithFormat({"LtReset3", count}),tag,c0,nil,190)  -- "本进度 第<1>次 恢复消耗："

        CSResourceMgr.setButtonString(resName,{"db","cancel"},"LtNo",tag)  -- 取消
        CSResourceMgr.setButtonString(resName,{"db","okay"},"LtYes",tag)   -- 确定
    end

    local function playCSB()
        CSResourceMgr.playAction(resName,0,5,false,tag)
    end

    local function init()
    end

    local function buttonBinding()

        -- help button binding
        CSResourceMgr.clickEventBinding(resName,{"db","help"},function()
        end,tag)

        -- mcash add button binding
        CSResourceMgr.clickEventBinding(resName,{"db","db2","mcash_btn"},function()
        end,tag,true)

        CSResourceMgr.clickEventBinding(resName,{"db","cancel"},function()
            LtResetViewMgr.hide()
        end,tag)

        CSResourceMgr.clickEventBinding(resName,{"db","okay"},function()
            if not NetInterface.isConnect then return end
            
            if CharInfo.getMCash() < consumeNum then
                StandardTipsMgr.show(1,"tips14")   -- 钻石不足
                return
            end

            NetInterface.sendWithBlock("GC_RESETDATA_ACK", function()
                local LostTowerSend = require("src/Net/Send/LostTowerSend.lua")
                LostTowerSend.sendCG_resetData_Req()
            end, function()
                LtResetViewMgr.hide()
                
                LtFuncMgr.transferEffect(SearchingMgr.playerCurrPosition, function()
                    PlayerAnimeMgr.removePlayerByTag(LtPlayerMgr.playerTag)
                    LtFuncMgr.resetEffect(function()
                        LtPetsMgr.reocverArmyPets(2)
                    end)
                    
                    LtPropMgr.clearAllProps()
                    LtExBufferMgr.clearBuffList()
                end)

                local TaskWatcherManager = require("src.GameMgr.TaskWatcher.TaskWatcherManager")
                TaskWatcherManager.saveLostTowerResultState("losttowerchongzhi")
            end)
        end,tag)

    end

    local funcTable = {loadCSB, playCSB, init, buttonBinding}

    UnblockLoader.load(funcTable,"LtResetViewMgr")

--    for i=1,#funcTable do
--        funcTable[i]()
--    end

end

function LtResetViewMgr.hide()
    UIStack.pop("LtResetViewMgr")
    GameAudio.playUISound("retract")
    
    CSResourceMgr.removeCSObjectByTag(resName,tag)
end

return LtResetViewMgr