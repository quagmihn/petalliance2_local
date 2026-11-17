local ExchangeViewMgr = {}

ExchangeViewMgr.POWERTYPE = 1
ExchangeViewMgr.GCASHTYPE = 2

local resName = ""
local resNameSkill = ""
local gCashRate = nil
local skillUpInfo = nil
local num = nil

function ExchangeViewMgr.Init()
    print("ExchangeViewMgr Init")

    resName = "Player/ExchangeView.csb"
    resNameSkill = "Player/SkillUpItem.csb"
    gCashRate = nil
    skillUpInfo = nil
    num = nil
end

function ExchangeViewMgr.hide()
    -- UnblockLoader.cancel("createEfx")
    gCashRate = nil
    skillUpInfo = nil
    num = nil
    CSResourceMgr.removeCSObjectByTag(resNameSkill)
	CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("ExchangeViewMgr")
end

function ExchangeViewMgr.show(scene,buyType,callback)
    if not NetInterface.isConnect then
        return
    end
    NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
        local LoginSend = require("src.Net.Send.LoginSend")
        LoginSend.sendCG_GetCharacterValues_Req({"todayBuyPowerCount","lastBuyPowerTime","todayBuyGCashCount","lastBuyGCashTime"})
    end, function()
        UIStack.push("ExchangeViewMgr", ExchangeViewMgr.hide, false)
        ExchangeViewMgr.getBuyPowerCount()
        ExchangeViewMgr.open(scene,buyType,callback)
    end, function(code)
        TipsMgr.showError(scene, code)
    end)
end

function ExchangeViewMgr.open(scene,buyType,callback) 

    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName)

        skillUpInfo,num = AchievementListMgr.getSkillUpInfo("gold")

        CSResourceMgr.setLabelColor(resName,"title",{r=165,g=239,b=252,a=255})
        CSResourceMgr.setLabelColor(resName,"tips",{r=255,g=235,b=17,a=255})

        local vipInfo = CharInfo.getVipInfoByID(CharInfo.getVIPLevel())
        local buyCount = ExchangeViewMgr.getBuyPowerCount()
        CSResourceMgr.setLabelColor(resName,"countLabel",{r=164,g=238,b=252,a=255})
        CSResourceMgr.setLabelString(resName,"countLabel","Exchange0001")

        CSResourceMgr.clickEventBinding(resName, "cover", function()
            ExchangeViewMgr.hide()
        end)

        CSResourceMgr.clickEventBinding(resName, "closeBtn", function()
            ExchangeViewMgr.hide()
        end)

        local powerInfoS = CharInfo.getBuyPowerInfoByID(buyCount[buyType])
        local gCashInfoS = CharInfo.getGoldPointInfoByID(buyCount[buyType])
        local powerInfo = CharInfo.getBuyPowerInfoByID(buyCount[buyType]+1)
        local gCashInfo = CharInfo.getGoldPointInfoByID(buyCount[buyType]+1)

        local icon = CSResourceMgr.getNodeByName(resName, "icon")
        icon:setScale(0.88)
        if buyType == ExchangeViewMgr.POWERTYPE then
            CSResourceMgr.setLabelString(resName,"title","Exchange0002","",{r=39,g=54,b=75,a=255})
            CSResourceMgr.setLabelString(resName,"tips","Exchange0004")
            CSResourceMgr.setSpriteTexture(resName,"icon", "UI/CommonFiles/icon_tili.png")
            CSResourceMgr.setLabelString(resName,"count", vipInfo.buyPower-buyCount[buyType].."/"..vipInfo.buyPower)
            if powerInfo then
                CSResourceMgr.setLabelString(resName,"diamondCount", powerInfo.cost)
                CSResourceMgr.setLabelString(resName,"resCount", powerInfo.power)
            else
                CSResourceMgr.setLabelString(resName,"diamondCount", powerInfoS.cost)
                CSResourceMgr.setLabelString(resName,"resCount", powerInfoS.power)
            end
        elseif buyType == ExchangeViewMgr.GCASHTYPE then
            CSResourceMgr.setLabelString(resName,"title","Exchange0003","",{r=39,g=54,b=75,a=255})
            CSResourceMgr.setLabelString(resName,"tips","Exchange0005")
            CSResourceMgr.setSpriteTexture(resName,"icon", "UI/CommonFiles/icon_jinbi.png")
            CSResourceMgr.setLabelString(resName,"count", vipInfo.goldTimes-buyCount[buyType].."/"..vipInfo.goldTimes)
            if gCashInfo then
                CSResourceMgr.setLabelString(resName,"diamondCount", gCashInfo.jewel)
                CSResourceMgr.setLabelString(resName,"resCount", gCashInfo.gold)
            else
                CSResourceMgr.setLabelString(resName,"diamondCount", gCashInfoS.jewel)
                CSResourceMgr.setLabelString(resName,"resCount", gCashInfoS.gold)
            end

            if skillUpInfo then
                local curLayer = CSResourceMgr.createRes(scene, resNameSkill)
                curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
                local icon = CSResourceMgr.getNodeByName(resNameSkill, "icon")
                local iconRes = "Battle/skillIcon/"..skillUpInfo.icon
                icon:setScale(0.5)
                CSResourceMgr.setSpriteTextureByNode(icon, iconRes)

                local skillLv = CSResourceMgr.getNodeByName(resNameSkill, "skillLv")
                CSResourceMgr.setLabelColorByNode(skillLv, {r=255,g=255,b=255,a=255})
                CSResourceMgr.setLabelStringByNode(skillLv, "Lv"..num, {r=0,g=0,b=0,a=255})

                local skillBtn = CSResourceMgr.getNodeByName(resNameSkill, "skillBtn")
                CSResourceMgr.clickEventBindingByNode(skillBtn, function()
                    AchievementListMgr.showSkillInfo(skillUpInfo,false,false,nil)
                end)

                local upIcon = CSResourceMgr.getNodeByName(resName, "upIcon")
                upIcon:setVisible(true)
                
                CSResourceMgr.setLabelColor(resName,"resCount",{r=147,g=254,b=6,a=255})
                CSResourceMgr.setLabelString(resName,"resCount", gCashInfo.gold + skillUpInfo.params[1])
            end
        end
        --阿杜修改英文版显示
        local countLabel = CSResourceMgr.getNodeByName(resName,"countLabel")
        local count = CSResourceMgr.getNodeByName(resName,"count")
        countLabel:setPositionX(count:getPositionX()-count:getContentSize().width-5)

        CSResourceMgr.setButtonString(resName, "confirmBtn", "tips3", "", {r=23,g=36,b=85,a=255})
        CSResourceMgr.setButtonStringColor(resName, "confirmBtn", {r=227,g=233,b=255,a=255})

        CSResourceMgr.clickEventBinding(resName, "confirmBtn", function()
            if buyType == ExchangeViewMgr.POWERTYPE then
                if buyCount[buyType] < vipInfo.buyPower then
                    if powerInfo.cost <= CharInfo.getMCash() then
                        NetInterface.sendWithBlock("GC_BuyPower_Ack", function()
                            local LoginSend = require("src.Net.Send.LoginSend")
                            LoginSend.sendCG_BuyPower_Req()
                        end, function()
                            buyCount[buyType] = buyCount[buyType] + 1
                            local powerInfo = CharInfo.getBuyPowerInfoByID(buyCount[buyType])
                            local powerInfoN = CharInfo.getBuyPowerInfoByID(buyCount[buyType]+1)
                            ExchangeViewMgr.setEfx(buyType,powerInfo.power)
                            CSResourceMgr.setLabelString(resName,"count", vipInfo.buyPower-buyCount[buyType].."/"..vipInfo.buyPower)
                            if powerInfoN then
                                CSResourceMgr.setLabelString(resName,"diamondCount", powerInfoN.cost)
                                CSResourceMgr.setLabelString(resName,"resCount", powerInfoN.power)
                            end
                            if callback then
                                callback()
                            end
                        end, function(code)
                            TipsMgr.showError(scene, code)
                        end)
                    else
                        StandardTipsMgr.show(1,"Exchange0006")
                    end
                else
                    StandardTipsMgr.show(1,"Exchange0007")
                end
            elseif buyType == ExchangeViewMgr.GCASHTYPE then
                if buyCount[buyType] < vipInfo.goldTimes then
                    if gCashInfo.jewel <= CharInfo.getMCash() then
                        NetInterface.sendWithBlock("GC_BuyGCash_Ack", function()
                            local LoginSend = require("src.Net.Send.LoginSend")
                            LoginSend.sendCG_BuyGCash_Req()
                        end, function()
                            buyCount[buyType] = buyCount[buyType] + 1
                            local gCashInfo = CharInfo.getGoldPointInfoByID(buyCount[buyType])
                            local gCashInfoN = CharInfo.getGoldPointInfoByID(buyCount[buyType]+1)
                            if skillUpInfo then
                                ExchangeViewMgr.setEfx(buyType,gCashInfo.gold + skillUpInfo.params[1])
                            else
                                ExchangeViewMgr.setEfx(buyType,gCashInfo.gold)
                            end
                            CSResourceMgr.setLabelString(resName,"count", vipInfo.goldTimes-buyCount[buyType].."/"..vipInfo.goldTimes)
                            if gCashInfoN then
                                CSResourceMgr.setLabelString(resName,"diamondCount", gCashInfoN.jewel)
                                CSResourceMgr.setLabelString(resName,"resCount", gCashInfoN.gold)
                                if skillUpInfo then
                                    CSResourceMgr.setLabelString(resName,"resCount", gCashInfoN.gold + skillUpInfo.params[1])
                                end
                            end
                        end, function(code)
                            TipsMgr.showError(scene, code)
                        end)
                    else
                        StandardTipsMgr.show(1,"Exchange0006")
                    end
                else
                    StandardTipsMgr.show(1,"Exchange0007")
                end
            end
        end)
    end
    
    local function playCSB()
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName,"background"),"down")
    end
    
    loadCSB() 
    playCSB()
end

function ExchangeViewMgr.getBuyPowerCount()
    local charInfo = CharInfo.get()
    local todayBuyPowerCount = charInfo["todaybuypowercount"] or 0
    local lastBuyPowerTime = charInfo["lastbuypowertime"] or 0
    local todayBuyGCashCount = charInfo["todaybuygcashcount"] or 0
    local lastBuyGCashTime = charInfo["lastbuygcashtime"] or 0
    local curTime = CharInfo.getServerTime()
    local buyCount = {0,0}
    
    if lastBuyPowerTime~=0 then
        local dayCount = CocosModuleMgr.getDayTimeDiff(curTime, lastBuyPowerTime, 21600)
        if dayCount == 0 then
            buyCount[1] = todayBuyPowerCount
        end
    end
    if lastBuyGCashTime~=0 then
        local dayCount = CocosModuleMgr.getDayTimeDiff(curTime, lastBuyGCashTime, 21600)
        if dayCount == 0 then
            buyCount[2] = todayBuyGCashCount
        end
    end
    return buyCount
end

function ExchangeViewMgr.setGCashRate(value)
    gCashRate = value
end

function ExchangeViewMgr.setEfx(buyType,buyCount)
    local efxNode = CSResourceMgr.getNodeByName(resName, "efxIcon")
    efxNode:setOpacity(255)
    if buyType == ExchangeViewMgr.POWERTYPE then
        CSResourceMgr.setSpriteTexture(resName,"efxIcon", "UI/CommonFiles/icon_tili.png")
    elseif buyType == ExchangeViewMgr.GCASHTYPE then
        CSResourceMgr.setSpriteTexture(resName,"efxIcon", "UI/CommonFiles/icon_jinbi.png")
    end
    CSResourceMgr.setLabelColor(resName,"efxCount",{r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelString(resName,"efxCount",buyCount,"",{r=0,g=0,b=0,a=255})
    efxNode:setVisible(true)

    transition.scaleTo(efxNode, {scale = 0.8, time = 0.3})
    efxNode:performWithDelay(function()
        transition.moveBy(efxNode, {y=30, time=0.5})
        transition.fadeOut(efxNode, {time=0.5})
    end,0.3)

    efxNode:performWithDelay(function()
        efxNode:setVisible(false)
        efxNode:setScale(3)
        transition.moveTo(efxNode, {x=318, y=410, time=0})
    end,0.8)
end

return ExchangeViewMgr