local LtHealViewMgr = {}

local resName = "LostTower/Menu/HealView.csb"

local cunsumeID  = 0
local consumeNum = 0
LtHealViewMgr.recoverCount = 0

function LtHealViewMgr.Init()
    cunsumeID  = 0
    consumeNum = 0
    LtHealViewMgr.recoverCount = 0
end

function LtHealViewMgr.show(scene)
    UIStack.push("LtHealViewMgr",LtHealViewMgr.hide)

    local function loadCSB()

        local layer = CSResourceMgr.createRes(scene,resName)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)

        -- title
        CSResourceMgr.setLabelColor(resName,{"db","title"},{r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelString(resName,{"db","title"},"LtHeal1","",{r=38,g=54,b=76,a=255},nil,80)  -- "恢复"
        
        CSResourceMgr.getNodeByName(resName,{"db","help"}):setVisible(false)  -- 隐藏帮助按钮
        
        -- desc
        CSResourceMgr.setLabelColor(resName,{"db","db2","desc_db","heal_desc"},{r=217,g=243,b=255,a=255})
        CSResourceMgr.setLabelString(resName,{"db","db2","desc_db","heal_desc"},"LtText31","",{r=11,g=17,b=67,a=255})  -- "是否恢复所有宠物状态？"
        
        -- mcash
        local c0 = {r=11,g=17,b=67,a=255}
        local c1 = {r=217,g=234,b=255,a=255}
        CSResourceMgr.setLabelColor(resName,{"db","db2","mcash_n"},c1)
        CSResourceMgr.setLabelString(resName,{"db","db2","mcash_n"},CharInfo.getMCash(),"")
        
        -- 恢复计数/消耗
        local count = LtHealViewMgr.recoverCount + 1
        local recoverStateInfo = LostTowerInfo.getRecoverStateInfoById(count)
        if not recoverStateInfo then 
            local infoConfig = require("src.DatReader.RecoverStateInfoConfig")
            local _id = infoConfig.getEntryID(infoConfig.getEntryCount())
            local coumsumeID = LostTowerInfo.getRecoverStateInfoById(_id).consume
            consumeNum = ItemInfo.getConsumeElementInfoById(coumsumeID).num
        else
            local consumeID = recoverStateInfo.consume
            local consume = ItemInfo.getConsumeElementInfoById(consumeID)
            consumeNum = consume.num
        end
        CSResourceMgr.setLabelString(resName,{"db","db2","consume_n"},consumeNum,"",nil)
        CSResourceMgr.setLabelString(resName,{"db","db2","consume_desc"},CocosModuleMgr.createStringWithFormat({"LtText32", count}),"",c0,nil,190)  -- "本进度 第<1>次 恢复消耗："
        
        CSResourceMgr.setButtonString(resName,{"db","cancel"},"LtNo")  -- 取消
        CSResourceMgr.setButtonString(resName,{"db","okay"},"LtYes")   -- 确定
    end

    local function playCSB()
        CSResourceMgr.playAction(resName,0,5)
    end

    local function init()
    end

    local function buttonBinding()
        
        -- help button binding
        CSResourceMgr.clickEventBinding(resName,{"db","help"},function()
            
        end)
        
        -- mcash add button binding
        CSResourceMgr.clickEventBinding(resName,{"db","db2","mcash_btn"},function()
            
        end,"",true)
        
        CSResourceMgr.clickEventBinding(resName,{"db","cancel"},function()
            LtHealViewMgr.hide()
        end)

        CSResourceMgr.clickEventBinding(resName,{"db","okay"},function()
            if CharInfo.getMCash() < consumeNum then
                StandardTipsMgr.show(1,"tips14")   -- 钻石不足
                return
            end
            NetInterface.sendWithBlock("GC_RECOVERSTATE_ACK", function()
                local LostTowerSend = require("src.Net.Send.LostTowerSend")
                LostTowerSend.sendCG_RecoverState_Req()
            end, function()
                -- refresh bottom pets
                LtPetsMgr.reocverArmyPets(1)
                
                for objID, _ in pairs(LtPetsMgr.LtPets) do
                    LtPetsMgr.LtPets[objID] = PokemonInfo.getPetInfoByObjID(objID).hpmax
                end
                
                LtHealViewMgr.recoverCount = LtHealViewMgr.recoverCount + 1
                LtHealViewMgr.hide()

                local TaskWatcherManager = require("src.GameMgr.TaskWatcher.TaskWatcherManager")
                TaskWatcherManager.saveLostTowerResultState("losttowerhuifu")
            end)
        end)

    end

    local funcTable = {loadCSB, playCSB, init, buttonBinding}

    UnblockLoader.load(funcTable,"LtHealViewMgr")

--    for i=1,#funcTable do
--        funcTable[i]()
--    end

end

function LtHealViewMgr.hide()
    UIStack.pop("LtHealViewMgr")
    CSResourceMgr.removeCSObjectByTag(resName)
end

return LtHealViewMgr