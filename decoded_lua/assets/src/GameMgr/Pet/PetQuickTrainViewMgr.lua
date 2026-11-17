local PetQuickTrainViewMgr = {}

local resName = ""
local trainTimes = 1
local editBox = nil
local objID = 0
local index = 0
local closeCallBack = nil

local attrIconTable = {
    "UI/CommonFiles/develop_icon_hp_01.png",
    "UI/CommonFiles/develop_icon_atk_01.png",
    "UI/CommonFiles/develop_icon_def_01.png",
    "UI/CommonFiles/develop_icon_mag_01.png",
    "UI/CommonFiles/develop_icon_res_01.png",
    "UI/CommonFiles/develop_icon_sep_01.png",
}
local attrNameTable = {"train11","train12","train13","train14","train15","train16"}

local a_idx = {
    "hpx",
    "atk",
    "def",
    "satk",
    "sdef",
    "speed",
}

local labelColor = {
    {r=255,g=255,b=255,a=255},
    {r=166,g=243,b=255,a=255},
    {r=151,g=190,b=220,a=255},
    {r=227,g=233,b=255,a=255},
    {r=54 ,g=177,b=218,a=255},
    {r=129,g=233,b=249,a=255},
}

local outlineColor = {
    {r=0,g=0,b=0,a=255,w=1},
    {r=38,g=54,b=76,a=255,w=2},
    {r=62,g=77,b=27,a=255,w=2},
    {r=0,g=0,b=0,a=255,w=2},
}

function PetQuickTrainViewMgr.Init()
    resName = "Pet/Education/PetQuickTrainView.csb"
    trainTimes = 1
    editBox = nil
end

function PetQuickTrainViewMgr.hide()
    trainTimes = 1
    editBox = nil
    objID = 0
    index = 0
    closeCallBack = nil
    UnblockLoader.cancel("PetQuickTrainViewMgr")
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("PetQuickTrainViewMgr")
end

--usePoints使用了多少点(pet)
--currPoints当前点了多少点(item)
--maxPoints最大能点多少点(item)
function PetQuickTrainViewMgr.show(scene, objid, usePoints, totalPoints, currPoints, maxPoints, idx, callBack)
    UIStack.push("PetQuickTrainViewMgr", PetQuickTrainViewMgr.hide, false)
    objID = objid
    index = idx
    closeCallBack = callBack
    local panel = nil
    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.clickEventBinding(resName, "btn_close", function()
            PetQuickTrainViewMgr.hide()
        end)

        panel = CSResourceMgr.getNodeByName(resName, "panel")
        panel:setVisible(false)

        -- local diff = CocosModuleMgr.getScreenSizeDiff()
        -- ViewMgrUtils.vFitSetPos(diff, {panel})
    end

    local function loadUI()
        local labelTitle1 = CSResourceMgr.getNodeByName(resName, "title")
        local labelTitle2 = CSResourceMgr.getNodeByName(resName, "title2")
        local labelTitle3 = CSResourceMgr.getNodeByName(resName, "str_num_title")
        local labelTitle4 = CSResourceMgr.getNodeByName(resName, "str_cost_title")
        -- local labelMax    = CSResourceMgr.getNodeByName(resName, "str_max")
        local labelSure   = CSResourceMgr.getNodeByName(resName, "str_sure")
        local spriteIcon  = CSResourceMgr.getNodeByName(resName, "icon")
        local labelName   = CSResourceMgr.getNodeByName(resName, "name")
        local labelOnce   = CSResourceMgr.getNodeByName(resName, "str_add_one")
        local labelTen    = CSResourceMgr.getNodeByName(resName, "str_add_ten")

        CSResourceMgr.setLabelStringByNode(labelTitle1, "train49", outlineColor[2], nil, 400)
        CSResourceMgr.setLabelStringByNode(labelTitle2, "train210", outlineColor[4], nil, 250)
        CSResourceMgr.setLabelStringByNode(labelTitle3, "train211", outlineColor[2], nil, 114)
        CSResourceMgr.setLabelStringByNode(labelTitle4, "train212", outlineColor[2], nil, 180)
        -- CSResourceMgr.setLabelStringByNode(labelMax,    "MAX", outlineColor[3], nil, 80)
        CSResourceMgr.setLabelStringByNode(labelSure,   "tips3", outlineColor[2], nil, 140)
        CSResourceMgr.setLabelStringByNode(labelName,   attrNameTable[index], outlineColor[1])
        CSResourceMgr.setLabelStringByNode(labelOnce,   "+1", outlineColor[3], nil, 80)
        CSResourceMgr.setLabelStringByNode(labelTen,    "+10", outlineColor[3], nil, 80)

        CSResourceMgr.setLabelColorByNode(labelTitle1, labelColor[2])
        CSResourceMgr.setLabelColorByNode(labelTitle2, labelColor[5])
        CSResourceMgr.setLabelColorByNode(labelTitle3, labelColor[2])
        CSResourceMgr.setLabelColorByNode(labelTitle4, labelColor[6])
        CSResourceMgr.setLabelColorByNode(labelSure,   labelColor[4])
        CSResourceMgr.setLabelColorByNode(labelName,   labelColor[3])

        CSResourceMgr.setSpriteTextureByNode(spriteIcon, attrIconTable[index])

        local maxTrainTimes = PetQuickTrainViewMgr.getMaxTrainTimes(usePoints, totalPoints, currPoints, maxPoints)
        PetQuickTrainViewMgr.setEditBox(usePoints, maxTrainTimes, true)
        -- PetQuickTrainViewMgr.setBtnMax(currPoints, maxTrainTimes)
        PetQuickTrainViewMgr.setBtnAddOnce(usePoints, totalPoints, maxTrainTimes, currPoints, maxPoints)
        PetQuickTrainViewMgr.setBtnAddTen(usePoints, totalPoints, maxTrainTimes, currPoints, maxPoints)
        PetQuickTrainViewMgr.setBtnSure()
    end

    local function playAction()
        panel:setVisible(true)
        CocosModuleMgr.showUIAnimation(panel, "down")
    end

    local funcTable = {loadCSB, loadUI, playAction}
    UnblockLoader.load(funcTable, "PetQuickTrainViewMgr")
end

function PetQuickTrainViewMgr.setCostColor(col)
    local labelCost = CSResourceMgr.getNodeByName(resName, "str_cost")
    CSResourceMgr.setLabelColorByNode(labelCost, col)
end

function PetQuickTrainViewMgr.setEditBox(usePoints, maxTrainTimes, isFirstSet)
    if not editBox then
        editBox = CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resName, "str_num"), "UI/CommonFiles/chat_text_box_su.png", 
            150, 36, 10, 1, 24, 32, "", 2, function()
                trainTimes = tonumber(editBox:getText())
                trainTimes = math.min(maxTrainTimes, trainTimes)
                if trainTimes <= 0 then
                    trainTimes = 1
                end
                editBox:setText(trainTimes)
                PetQuickTrainViewMgr.setGCashCost(usePoints)
                PetQuickTrainViewMgr.setBtnSure()
            end)
        if isFirstSet == true then
            editBox:setText(1)
        end
    else
        editBox:setText(trainTimes)
    end
    PetQuickTrainViewMgr.setGCashCost(usePoints)
    PetQuickTrainViewMgr.setBtnSure()
end

function PetQuickTrainViewMgr.setGCashCost(usePoints)
    local labelCost = CSResourceMgr.getNodeByName(resName, "str_cost")
    CSResourceMgr.setLabelStringByNode(labelCost, PetQuickTrainViewMgr.getTotalGCashCost(usePoints), outlineColor[2])
    CSResourceMgr.setLabelColorByNode(labelCost, labelColor[6])
end

function PetQuickTrainViewMgr.setBtnMax(usePoints, maxTrainTimes)
    local btnMax = CSResourceMgr.getNodeByName(resName, "btn_max")
    CSResourceMgr.clickEventBindingByNode(btnMax, function()
        if maxTrainTimes == 0 then
            PetQuickTrainViewMgr.setCostColor({r=255,g=0,b=0,a=255})
        else
            trainTimes = maxTrainTimes
            editBox:setText(trainTimes)
            PetQuickTrainViewMgr.setGCashCost(usePoints)
            PetQuickTrainViewMgr.setBtnSure()
        end
    end)
end

function PetQuickTrainViewMgr.setBtnAddOnce(usePoints, totalPoints, maxTrainTimes, currPoints, maxPoints)
    local btnOnce = CSResourceMgr.getNodeByName(resName, "btn_add_one")
    CSResourceMgr.clickEventBindingByNode(btnOnce, function()
        if trainTimes < maxTrainTimes then
            trainTimes = trainTimes + 1
            editBox:setText(trainTimes)
            PetQuickTrainViewMgr.setGCashCost(usePoints)
            PetQuickTrainViewMgr.setBtnSure()
        else
            if usePoints + trainTimes == totalPoints then
                StandardTipsMgr.show(1, "train170")
            elseif currPoints + trainTimes == maxPoints then
                StandardTipsMgr.show(1, "train213")
            else
                StandardTipsMgr.show(1, "tips13")
            end
        end
    end)
end

function PetQuickTrainViewMgr.setBtnAddTen(usePoints, totalPoints, maxTrainTimes, currPoints, maxPoints)
    local btnTen = CSResourceMgr.getNodeByName(resName, "btn_add_ten")
    CSResourceMgr.clickEventBindingByNode(btnTen, function()
        if trainTimes < maxTrainTimes then
            trainTimes = math.min(trainTimes + 10, maxTrainTimes)
            editBox:setText(trainTimes)
            PetQuickTrainViewMgr.setGCashCost(usePoints)
            PetQuickTrainViewMgr.setBtnSure()
        else
            if usePoints + trainTimes == totalPoints then
                StandardTipsMgr.show(1, "train170")
            elseif currPoints + trainTimes == maxPoints then
                StandardTipsMgr.show(1, "train213")
            else
                StandardTipsMgr.show(1, "tips13")
            end
        end
    end)
end

function PetQuickTrainViewMgr.setBtnSure()
    if objID ~= 0 and index ~= 0 and closeCallBack ~= nil then
        local btnSure = CSResourceMgr.getNodeByName(resName, "btn_sure")
        CSResourceMgr.clickEventBindingByNode(btnSure, function ()
            local addPoints = {
                hpx   = 0,
                atk   = 0,
                def   = 0,
                satk  = 0,
                sdef  = 0,
                speed = 0,
            }
            addPoints[a_idx[index]] = trainTimes
            local json = require("framework.json")
            local addP = json.encode(addPoints)
            NetInterface.sendWithBlock("GC_PETSTRENG_ACK", function()
                local PetEducationSend = require("src/Net/Send/PetEducationSend.lua")
                PetEducationSend.sendCG_PetStreng_Req({
                    petObjID = objID,
                    addPoints = addP,
                })
            end, function()
                PetEducationMgr.setTrainTimes(trainTimes)
                if closeCallBack then closeCallBack() end
                PetQuickTrainViewMgr.hide()
            end)
        end)
    else
        print("objID == 0 or index == 0 or closeCallBack == nil")
    end
end

function PetQuickTrainViewMgr.getMaxTrainTimes(usePoints, totalPoints, currPoints, maxPoints)--最高可训练次数
    local currGCash = CharInfo.getGCash()
    local maxTrainTimes1 = math.min(maxPoints - currPoints, totalPoints - usePoints)
    local maxTrainTimes2 = 0
    local idx = 1
    local localPoints = usePoints
    local needGCash = 0
    while (idx <= maxTrainTimes1 and currGCash >= needGCash + PetQuickTrainViewMgr.getOnceGCashCost(localPoints))
    do
        needGCash = needGCash + PetQuickTrainViewMgr.getOnceGCashCost(localPoints)
        idx = idx + 1
        localPoints = localPoints + 1
        maxTrainTimes2 = maxTrainTimes2 + 1
    end
    return math.min(maxTrainTimes1, maxTrainTimes2)
end

function PetQuickTrainViewMgr.getOnceGCashCost(usePoints)
    return PokemonInfo.getPetStrengthenInfo(usePoints + 1).gcash
end

function PetQuickTrainViewMgr.getTotalGCashCost(usePoints)
    local resCost = 0
    for i = 1, trainTimes do
        resCost = resCost + PokemonInfo.getPetStrengthenInfo(usePoints + i).gcash
    end
    return resCost
end

return PetQuickTrainViewMgr