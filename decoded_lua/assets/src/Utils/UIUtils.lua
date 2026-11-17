local UIUtils = {}
local GenUtils = require("Utils.GenUtils")

-----------------------------------------------获取样式---------------------------------------------

--获取道具ICON
function UIUtils.getItemIconByID( id )
    local ItemInfoConfig = require("DatReader.ItemInfoConfig")
    ItemInfoConfig.init()
    local info = ItemInfoConfig.readEntryByID( id )
    return "item/"..info.icon
end

--获取宠物头像
function UIUtils.getPetIconByID( id )
    local PetRaceInfoConfig = require("DatReader.PetRaceInfoConfig")
    PetRaceInfoConfig.init()
    local info = PetRaceInfoConfig.readEntryByID( id )
    return "petinfo/petportrait/"..info.model..".png"
end

--获取花费的ICON
function UIUtils.getCostIconByType(type, id)
    local url = ""
    if type==Proto.COST_TYPE_G then
        url = "general/icon_base/jinbi.png"
    elseif type==Proto.COST_TYPE_M then
        url = "general/icon_base/zuanshi.png"
    elseif type==Proto.COST_TYPE_CREDIT_CARD then
        local CreditCardInfoConfig = require("DatReader.CreditCardInfoConfig")
        CreditCardInfoConfig:init()
        local info = CreditCardInfoConfig.readEntryByID(id)
        url = "general/icon_base/"..info.icon
    end
    return url
end

--获取宠物类型图标
function UIUtils.getPetTypeIcon(pType)
    if pType == Proto.PET_RACE_EARTH then
        return "dialogs/troopselect/tu.png"
    elseif pType == Proto.PET_RACE_WIND then
        return "dialogs/troopselect/feng.png"
    elseif pType == Proto.PET_RACE_FIRE then
        return "dialogs/troopselect/huo.png"
    elseif pType == Proto.PET_RACE_WATER then
        return "dialogs/troopselect/shui.png"
    else
        print("getPetTypeIcon_没有此宠物类型："..pType)
        return nil
    end
end

--获取白底宠物图片下方的等级图标
function UIUtils.getPetQualityIcon(pQuality)
    if pQuality == Proto.PET_QUALITY_C then
        return "dialogs/petcompose/lv.png"
    elseif pQuality == Proto.PET_QUALITY_B then
        return "dialogs/petcompose/lan.png"
    elseif pQuality == Proto.PET_QUALITY_A then
        return "dialogs/petcompose/zi.png"
    elseif pQuality == Proto.PET_QUALITY_S then
        return "dialogs/petcompose/cheng.png"
    else
        print("getPetQualityIcon_没有此宠物品阶："..pQuality)
        return nil
    end
end

local tip
--创建TIP
local function openEquipmentTip( eID )
    tip = require("Tips.TipEquipment").new({
        equipmentID = eID,
    })

end

--创建道具tip
local function openItemTip( awardsType, itemID, pos )
    local tipWidth = 200
    local tipHeight = 250
    local offsetX = 170
    local offsetY = 180

    if pos.y + offsetY + tipHeight/2 > display.height then
        if pos.x- offsetX - tipWidth/2 < 0 then
            pos.x = pos.x + offsetX
        else
            pos.x = pos.x - offsetX
        end

        if pos.y + tipHeight/2 > display.height then
            pos.y = display.height - tipHeight/2
        end
    else
        pos.y = pos.y + offsetY
    end

    tip = require("Tips.ItemTip").new({
        awardsType = awardsType,
        itemID = itemID,
        pos = pos,
        size = CCSize(tipWidth, tipHeight),
    })
end

--获取道具对应的颜色
function UIUtils.getColorByItemQuality(quality)
    local color
    if quality==1 then
        color = ccc3(36,255,0)
    elseif quality==2 then
        color = ccc3(0,180,255)
    elseif quality==3 then
        color = ccc3(185,0,255)
    elseif quality==4 then
        color = ccc3(255,147,0) 
    else
        color = ccc3(255,255,255) 
    end
    return color
end

--按钮添加TIPS事件
function UIUtils.addBtnTipsListener(btn, awardsType, itemID)
    if btn.tipEvent then
        return 
    end
    btn.tipEvent = true

    local UIButton = require("framework.cc.ui.UIButton")
    btn:addEventListener(
        UIButton.PRESSED_EVENT, 
        function() 
            local pos = btn:convertToWorldSpace(ccp(0,0))
            openItemTip(awardsType, itemID, pos) 
        end
    )
    btn:addEventListener(UIButton.RELEASE_EVENT, function() if tip then tip:hideAllTipes() end end )
end

function UIUtils.removeBtnTipsListener(btn)
    if btn.tipEvent then
        local UIButton = require("framework.cc.ui.UIButton")
        btn:removeEventListener(UIButton.PRESSED_EVENT)
    end
end

--在假面中添加角色升级的监听事件
function UIUtils.addUpLevelUpListenerInDialog(self)
    local GenInfo = require("Data.GenInfo")
    require("Eca.EcaInclude")
    local lastLevel = GenInfo.getMyBaseInfo().level
    local function onLevelUp(code)
        local newLevel = GenInfo.getMyBaseInfo().level
        if newLevel>lastLevel then
            self:openDialog("PlayerLevelUP",{
                oriLevel = lastLevel,
                curLevel = newLevel,
            })
            lastLevel = newLevel
        end
    end
    self:addListener(ECA.OnMsgRcv, onLevelUp, Proto.Command.ZC_UPDATELEVEL_NTF)
end

--播放点击动画
function UIUtils.playClickAction(box, fun, s1)
    local scale1 = s1 or 0.16
    box:stopAllActions()
    if not box.theBaseScaleInAction then
        box.theBaseScaleInAction = box:getScale()
    else
        box:setScale(box.theBaseScaleInAction)
    end
    local bs = box.theBaseScaleInAction
    local arr = {   
        "seq",
        { "scaleto", 0.15, bs+scale1 },
        { "scaleto", 0.07, bs},
    }
    if fun then
        arr[#arr+1] = { "call", fun }
    end
    local action = require("Utils.ActionBuilder").build( arr )
    box:runAction(action)
end

--获取宠物GAF
function UIUtils.getPetGafUrl(petID)
    local url = ""
    local HDConfigManager = require("Battle.HDConfigManager")
    local pet = HDConfigManager:getPetinfoByConfig(petID)
    local petMODELID = pet.model

    if pet.colorFile ~= nil and pet.colorFile ~= "" then
        url = "actor/" .. pet.colorFile .."/" .. petMODELID ..".gaf"
    else
        url = "actor/" .. petMODELID .. "/" .. petMODELID ..".gaf"
    end
    return url
end

return UIUtils