-- 宠物养成喂食二级弹窗

local PetFeedViewMgr = {}

local resName = "Pet/Education/PetFeedPageNew.csb"

local expItemIDList = {}
local itemNode = {}
PetFeedViewMgr.CurrPetInfo = nil
PetFeedViewMgr.CurrPetRP = nil --稀有度
PetFeedViewMgr.CurrPetExp = nil
PetFeedViewMgr.CurrPetLevel = nil
PetFeedViewMgr.PlayCurrPetLevel = nil
PetFeedViewMgr.ExpItemUsed = {}
PetFeedViewMgr.ExpGrowList = {} --经验增长列表，一次增长量
PetFeedViewMgr.PlayCurrPetExp = nil
PetFeedViewMgr.TopLevel = nil
PetFeedViewMgr.ExpItemAddNum = 0
PetFeedViewMgr.haveGuideFeed = false--喂食引导用
local expAddPercent = 0

function PetFeedViewMgr.Init()
    expItemIDList = clone(SystemInfo.getGlobalConfigAddInfoByID(9).values)
    table.remove(expItemIDList, #expItemIDList)
end

local function getLevelWithExp(exp, rarePoint)
    if exp == 0 then return 1 end

    local tmpExp = 0
    local tmpLevel = 0
    while exp >= tmpExp do
        tmpLevel = tmpLevel + 1
        tmpExp = ExperienceInfo.getExperienceInfoByID(tmpLevel).petExpVec[rarePoint]
    end
    return tmpLevel
end

function PetFeedViewMgr.doPlayExpGrowAction()
    local expBar = CSResourceMgr.getNodeByName (resName, {"tc_d","tc_d2","exp_bar"})
    -- transition.stopTarget(expBar)
    local ptm = 100
    local spd = 1
    local function playAction(expGrowNum, partTimes, speed)
        local playGap = 0.005  --播放时间间隔
        local playTimes = partTimes  --播放次数(分段)
        local expNum = math.floor(expGrowNum / playTimes)
        if expNum == 0 then
            playTimes = expGrowNum
        end
        for i = 1, playTimes do
            -- local expNum = math.floor(expGrowNum / playTimes)
            if i == playTimes then
                expNum = expGrowNum - (expNum * (playTimes - 1))
            end
            local changeLv, expNow = PetFeedViewMgr.TryFeed(PetFeedViewMgr.PlayCurrPetLevel, PetFeedViewMgr.PlayCurrPetExp, expNum)
            if changeLv > 0 then
                local expBar     = CSResourceMgr.getNodeByName (resName, {"tc_d","tc_d2","exp_bar"})
                CSResourceMgr.createCCBI(expBar, "texture/ui_dc_02.ccbi", expBar:getContentSize().width/2, expBar:getContentSize().height/2)
            end

            PetFeedViewMgr.PlayCurrPetExp = PetFeedViewMgr.PlayCurrPetExp + expNum
            PetFeedViewMgr.PlayCurrPetLevel = PetFeedViewMgr.PlayCurrPetLevel + changeLv

            local currExp = PetFeedViewMgr.PlayCurrPetExp
            local currLevel = PetFeedViewMgr.PlayCurrPetLevel

            expBar:performWithDelay(function ()
                PetFeedViewMgr.refreshExpBar(currExp, currLevel)
            end, playGap * speed * (i - 1))
        end

        expBar:performWithDelay(function()
            table.remove(PetFeedViewMgr.ExpGrowList, 1)
            if #PetFeedViewMgr.ExpGrowList ~= 0 then
                playAction(PetFeedViewMgr.ExpGrowList[1], ptm, spd)
            end
        end, playGap * speed * (playTimes - 1))
    end
    playAction(PetFeedViewMgr.ExpGrowList[1], ptm, spd)
end

function PetFeedViewMgr.playExpGrowAction()
    if #PetFeedViewMgr.ExpGrowList == 1 then
        PetFeedViewMgr.doPlayExpGrowAction()
    end
end

function PetFeedViewMgr.show(scene, petInfo, closeCallback)
    UIStack.push("PetFeedViewMgr",PetFeedViewMgr.hide,false)
    PetFeedViewMgr.CurrPetExp   = petInfo.exp
    PetFeedViewMgr.CurrPetInfo  = petInfo
    PetFeedViewMgr.CurrPetLevel = petInfo.level
    PetFeedViewMgr.PlayCurrPetLevel = petInfo.level
    PetFeedViewMgr.CurrPetRP    = PokemonInfo.getPokemonInfoByID(petInfo.pokeID).rarePoint
    PetFeedViewMgr.PlayCurrPetExp = petInfo.exp
    PetFeedViewMgr.TopLevel     = PokemonInfo.getPokemonInfoByID(petInfo.pokeID).topLevel

    local function initExpList()
        local upInfo,skillNum = AchievementListMgr.getSkillUpInfo("petExp")
        if upInfo then
            expAddPercent = upInfo.params[1] * 0.01
        end
    end

    local curLayer
    local function loadCSB()
        curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(25)
        -- curLayer:setVisible(false)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.clickEventBinding(resName,"close",function()
            local index = 0
            for k,v in pairs(PetFeedViewMgr.ExpItemUsed) do
                if v ~= 0 then
                    index = 1
                    break
                end
            end
            if index > 0 then
                DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, "train182", function ()
                    PetFeedViewMgr.hide()
                end)
            else
                PetFeedViewMgr.hide()
            end
        end)

        local title     = CSResourceMgr.getNodeByName (resName, {"tc_d","title"})
        local expTitle  = CSResourceMgr.getNodeByName (resName, {"tc_d","tc_d2","exp_t"})
        local petLevel  = CSResourceMgr.getNodeByName (resName, {"tc_d","tc_d2","level"})
        local btnMax    = CSResourceMgr.getNodeByName (resName,  {"tc_d","tc_d2","quick_feed"})
        local strMax    = CSResourceMgr.seekNodeByName(btnMax,  "max")
        local btnSure   = CSResourceMgr.getNodeByName (resName, {"tc_d","confirm"})
        local strSure   = CSResourceMgr.seekNodeByName(btnSure, "sure")
        local expBar    = CSResourceMgr.getNodeByName (resName, {"tc_d","tc_d2","exp_bar"})
        local labelExp  = CSResourceMgr.seekNodeByName(expBar,  "exp_num")

        CSResourceMgr.setLabelStringByNode(title,    "train91", {r=38,g=54,b=76,a=255,w=2})
        CSResourceMgr.setLabelStringByNode(expTitle, "train92", {r=0,g=0,b=0,a=255,w=1})
        CSResourceMgr.setLabelStringByNode(petLevel, "Lv."..petInfo.level, {r=0,g=0,b=0,a=255})
        CSResourceMgr.setLabelStringByNode(strMax,   "MAX", {r=62,g=77,b=27,a=255,w=1})
        CSResourceMgr.setLabelStringByNode(strSure,  "train24", {r=0,g=0,b=0,a=255,w=2}, 1, 110)

        CSResourceMgr.setLabelColorByNode (strSure,  {r=227,g=233,b=255,a=255})
        CSResourceMgr.setLabelColorByNode (title,    {r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelColorByNode (expTitle, {r=254,g=243,b=57,a=255})
        CSResourceMgr.setLabelColorByNode (petLevel, {r=254,g=243,b=57,a=255})
        
        local rarePoint = PetFeedViewMgr.CurrPetRP
        local preExp    = ExperienceInfo.getExperienceInfoByID(petInfo.level - 1).petExpVec[rarePoint]--根据稀有度拿当前等级升级所需要的经验
        local expText   = (petInfo.exp - preExp).."/"..(ExperienceInfo.getExperienceInfoByID(petInfo.level).petExpVec[rarePoint] - preExp)
        CSResourceMgr.setLabelStringByNode(labelExp, expText, {r=0,g=0,b=0,a=255,w=1})
        local percent   = (petInfo.exp - preExp) * 100 / (ExperienceInfo.getExperienceInfoByID(petInfo.level).petExpVec[rarePoint] - preExp)--下一级所需要的经验
        expBar:setPercent((percent < 0) and 0 or percent)

        PetFeedViewMgr.refreshExpItemList()--设置exp列表

        CSResourceMgr.clickEventBindingByNode(btnMax, function ()
            local haveItem = false
            for k,v in pairs(expItemIDList) do
                local itemCount = ItemInfo.getCharItemNum(v)
                if itemCount > 0 then
                    haveItem = true
                    break
                end
            end
            if haveItem == false then
                DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "train104")
                return
            end

            local limitLevel  = math.min(CharInfo.getLevel(), PetFeedViewMgr.TopLevel)
            if PetFeedViewMgr.CurrPetLevel == limitLevel then
                if PetFeedViewMgr.CurrPetLevel == PetFeedViewMgr.TopLevel then
                    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "train93")
                elseif PetFeedViewMgr.CurrPetLevel == CharInfo.getLevel() then
                    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "train94")
                end
                return
            end
            for i=1, #itemNode do
                local node = itemNode[i]
                if node ~= nil and node.num > 0 then
                    CSResourceMgr.createCCBI(node, "texture/ui_dc_03.ccbi", node:getContentSize().width/2, node:getContentSize().height/2 + 10)
                end
            end
            GameAudio.playUISound("exp")
            PetFeedViewMgr.useExpItemToMax()
            CSResourceMgr.setButtonEnabledByNode(btnMax, false)
            CSResourceMgr.setButtonEnabledByNode(btnSure, true)
        end, 3)

        CSResourceMgr.setButtonEnabledByNode(btnSure, false)
        CSResourceMgr.clickEventBindingByNode(btnSure, function ()
            PetFeedViewMgr.sendExpItemUsed(closeCallback)
        end)
    end

    local function setBtnQianli()
        local upInfo,skillNum = AchievementListMgr.getSkillUpInfo("petExp")
        local btnQianli = CSResourceMgr.getNodeByName(resName, "qianli")
        btnQianli:setVisible(upInfo ~= nil)
        if upInfo ~= nil then
            local qianliIcon = CSResourceMgr.seekNodeByName(btnQianli, "qianli_icon")
            local qianliLv = CSResourceMgr.seekNodeByName(btnQianli, "qianli_lv")
            CSResourceMgr.setLabelStringByNode(qianliLv, "Lv"..skillNum, {r=0,g=0,b=0,a=255,w=1,s=1})
            CSResourceMgr.setSpriteTextureByNode(qianliIcon, "Battle/skillIcon/"..upInfo.icon)
            qianliIcon:setScale(0.5)
            CSResourceMgr.clickEventBindingByNode(btnQianli, function()
                AchievementListMgr.showSkillInfo(upInfo, false, false, nil)
            end, 3)
        end
    end

    local function playCSB()
        curLayer:setVisible(true)
        CSResourceMgr.playAction(resName, 0, 5)
    end

    local funcTable = {initExpList, loadCSB, setBtnQianli, playCSB}
    UnblockLoader.load(funcTable, "PetFeedViewMgr")
end

function PetFeedViewMgr.refreshExpItemList()
    local list   = CSResourceMgr.getNodeByName(resName, {"tc_d","tc_d2","conList"})
    local parent = CSResourceMgr.getNodeByName(resName, "tc_k")
 
    for i = 1, #expItemIDList do
        -- if i == #expItemIDList then break end
        itemNode[i] = parent:clone()
        PetFeedViewMgr.ExpItemUsed[i] = 0
        PetFeedViewMgr.refreshSingleExpItem(itemNode[i], i)
        list:pushBackCustomItem(itemNode[i])
    end
end

function PetFeedViewMgr.refreshSingleExpItem(node, index)
    local expItemID  = expItemIDList[index]
    local itemInfo   = ItemInfo.getItemInfoById(expItemID)
    local name       = itemInfo.name
    local icon       = itemInfo.icon
    local paramA     = itemInfo.paramA
    local itemCount  = ItemInfo.getCharItemNum(expItemID)
    local num        = itemCount - PetFeedViewMgr.ExpItemUsed[index]
    paramA = expAddPercent > 0 and paramA + math.floor(paramA * expAddPercent) or paramA

    local labelName  = CSResourceMgr.seekNodeByName(node, "m_name")
    local spriteIcon = CSResourceMgr.seekNodeByName(node, "m_icon")
    local labelNum   = CSResourceMgr.seekNodeByName(node, "m_num")
    local labelInfo  = CSResourceMgr.seekNodeByName(node, "exp_num")
    local spriteGray = CSResourceMgr.seekNodeByName(node, "gray")

    CSResourceMgr.setLabelStringByNode(labelName, name, {r=0,g=0,b=0,a=255,w=1}, 1, 98)
    CSResourceMgr.setLabelStringByNode(labelNum,  num, {r=0,g=0,b=0,a=255})
    CSResourceMgr.setLabelStringByNode(labelInfo, "Exp+"..paramA, {r=14,g=40,b=47,a=255,w=1}, 1, 98)
    CSResourceMgr.setLabelColorByNode (labelName, (itemInfo.itemRare == 0) and {r=247,g=253,b=254,a=255} or PokemonInfo.COLOR[itemInfo.itemRare])
    CSResourceMgr.setLabelColorByNode (labelNum,  (num > 0) and {r=255,g=255,b=255,a=255} or {r=255,g=72,b=0,a=255})
    CSResourceMgr.setLabelColorByNode (labelInfo, expAddPercent > 0 and {r=0,g=255,b=0,a=255} or {r=255,g=255,b=255,a=255})
    node.num = num
    CSResourceMgr.setSpriteTextureByNode(spriteIcon, icon)
    spriteIcon:setScale(0.8)

    if num < 1 then--遮挡
        spriteGray:setVisible(true)
        spriteGray:setColor({r=0,g=0,b=0,a=255})
        spriteGray:setOpacity(153)
    end

    CSResourceMgr.clickEventBindingByNode(node, function ()
        if num < 1 then
            ItemInfoViewMgr.show({id = expItemID}, false)
        else
            PetFeedViewMgr.useOneExpItem(node, index, paramA, function ()
                DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "train94")
            end)
            CSResourceMgr.createCCBI(node, "texture/ui_dc_03.ccbi", node:getContentSize().width/2, node:getContentSize().height/2 + 10)
        end
    end)
end

function PetFeedViewMgr.useExpItemToMax()
    local limitLevel  = math.min(CharInfo.getLevel(), PetFeedViewMgr.TopLevel)
    local limitExp    = PetFeedViewMgr.getLimitExpByLevel(limitLevel)
    local index = 1
    local currExp = PetFeedViewMgr.CurrPetExp
    for k,v in pairs(expItemIDList) do
        local itemCount   = ItemInfo.getCharItemNum(v)
        local itemInfo    = ItemInfo.getItemInfoById(v)
        local expItemLeft = itemCount - PetFeedViewMgr.ExpItemUsed[index]
        local paramA      = itemInfo.paramA
        local node        = itemNode[index]
        for i = 1, expItemLeft do
            if PetFeedViewMgr.CurrPetLevel < limitLevel then
                local changeLv, expNow = PetFeedViewMgr.TryFeed(PetFeedViewMgr.CurrPetLevel, PetFeedViewMgr.CurrPetExp, paramA)
                PetFeedViewMgr.ExpItemUsed[index] = PetFeedViewMgr.ExpItemUsed[index] + 1
                local expGrowNum = (PetFeedViewMgr.CurrPetExp + paramA) > limitExp and (limitExp - PetFeedViewMgr.CurrPetExp - 1) or paramA
                PetFeedViewMgr.CurrPetLevel = PetFeedViewMgr.CurrPetLevel + changeLv
                PetFeedViewMgr.CurrPetExp = PetFeedViewMgr.CurrPetExp + expGrowNum
            end
        end
        PetFeedViewMgr.refreshSingleExpItem(node, index)
        index = index + 1
    end
    table.insert(PetFeedViewMgr.ExpGrowList, PetFeedViewMgr.CurrPetExp - currExp)
    PetFeedViewMgr.playExpGrowAction()
end

function PetFeedViewMgr.useOneExpItem(node, index, paramA, callback)
    local limitLevel = math.min(CharInfo.getLevel(), PetFeedViewMgr.TopLevel)
    local limitExp = PetFeedViewMgr.getLimitExpByLevel(limitLevel)
    if PetFeedViewMgr.CurrPetLevel == limitLevel then
        if PetFeedViewMgr.CurrPetLevel == PetFeedViewMgr.TopLevel then
            DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "train93")
        elseif PetFeedViewMgr.CurrPetLevel == CharInfo.getLevel() then
            DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "train94")
        end
        return
    else
        local changeLv, expNow = PetFeedViewMgr.TryFeed(PetFeedViewMgr.CurrPetLevel, PetFeedViewMgr.CurrPetExp, paramA)
        PetFeedViewMgr.CurrPetLevel = PetFeedViewMgr.CurrPetLevel + changeLv
        local currExp = (PetFeedViewMgr.CurrPetExp + paramA) > limitExp and (limitExp - PetFeedViewMgr.CurrPetExp - 1) or paramA
        PetFeedViewMgr.CurrPetExp = PetFeedViewMgr.CurrPetExp + currExp
        PetFeedViewMgr.ExpItemUsed[index] = PetFeedViewMgr.ExpItemUsed[index] + 1
        table.insert(PetFeedViewMgr.ExpGrowList, currExp)
    end
    GameAudio.playUISound("exp1")
    PetFeedViewMgr.refreshSingleExpItem(node, index)
    PetFeedViewMgr.playExpGrowAction()
    local btnSure = CSResourceMgr.getNodeByName (resName, {"tc_d","confirm"})
    CSResourceMgr.setButtonEnabledByNode(btnSure, true)
end

function PetFeedViewMgr.refreshExpBar(currExp, currLevel)
    local petLevel  = currLevel
    local rarePoint = PetFeedViewMgr.CurrPetRP
    local preExp    = ExperienceInfo.getExperienceInfoByID(petLevel - 1).petExpVec[rarePoint]
    local limitExp  = ExperienceInfo.getExperienceInfoByID(petLevel).petExpVec[rarePoint] - preExp
    local expText   = (currExp - preExp).."/"..limitExp
    local percent   = (currExp - preExp) * 100 / limitExp
    PetFeedViewMgr.setExpBar(petLevel, expText, percent)
end

function PetFeedViewMgr.setExpBar(petLevel, petExp, percent)
    local labelLevel = CSResourceMgr.getNodeByName (resName, {"tc_d","tc_d2","level"})
    local expBar     = CSResourceMgr.getNodeByName (resName, {"tc_d","tc_d2","exp_bar"})
    local labelExp   = CSResourceMgr.seekNodeByName(expBar,  "exp_num")
    CSResourceMgr.setLabelStringByNode(labelLevel, "Lv."..petLevel)
    CSResourceMgr.setLabelStringByNode(labelExp, petExp)
    expBar:setPercent((percent < 0) and 0 or percent)
end

-- return cnt 2
-- expNow : int
function PetFeedViewMgr.TryFeed(currPetLevel, currPetExp, exp)
    local petInfo = PetFeedViewMgr.CurrPetInfo
    local currExp = currPetExp
    local finalExp = currExp + exp
    local level  = currPetLevel
    local expNow = 0
    while true do
        local expInfo = ExperienceInfo.getExperienceInfoByID(level)
        local maxExp  = expInfo.petExpVec[PetFeedViewMgr.CurrPetRP]
        if level > CharInfo.getLevel() then
            level    = level - 1
            limitExp = PetFeedViewMgr.getLimitExpByLevel(level)
            expNow   = (finalExp >= limitExp) and (limitExp - 1) or finalExp
            break
        else
            if finalExp < maxExp then
                expInfo = ExperienceInfo.getExperienceInfoByID(level - 1)
                maxExp  = expInfo.petExpVec[PetFeedViewMgr.CurrPetRP]
                expNow  = finalExp - maxExp
                break
            end
        end
        level = level + 1
    end
    return level - currPetLevel, expNow
end

function PetFeedViewMgr.getLimitExpByLevel(level)
    local eInfo1  = ExperienceInfo.getExperienceInfoByID(level - 1)
    local eInfo2  = ExperienceInfo.getExperienceInfoByID(level)
    local maxExp1 = eInfo1.petExpVec[PetFeedViewMgr.CurrPetRP]
    local maxExp2 = eInfo2.petExpVec[PetFeedViewMgr.CurrPetRP]
    return maxExp2-- - maxExp1
end

function PetFeedViewMgr.sendExpItemUsed(closeCallback)
    local reqTable = {}
    for k,v in pairs(PetFeedViewMgr.ExpItemUsed) do
        local req = {}
        req.itemID = expItemIDList[k]
        req.num = v
        if req.num ~= 0 then
            reqTable[#reqTable + 1] = req
        end
    end

    local on_success = function()
        table.remove(reqTable, 1)
        if #reqTable == 0 then
            if closeCallback ~= nil then
                closeCallback()
                PetFeedViewMgr.hide()
            end
        else
            local req = reqTable[1]
            -- PetFeedViewMgr.sendUseExpItem(req.itemID, req.num, on_success, on_failed)
        end
    end

    local function send()
        NetInterface.sendWithBlock("GC_UseItem_Ack", function()
            local ItemSend = require("src.Net.Send.ItemSend")
            local itemID = reqTable[1].itemID
            local num = reqTable[1].num
            local req =
            {
                itemID = itemID,
                targetNum = PetFeedViewMgr.CurrPetInfo.objID,
                targetStr = "",
                useNum = num
            }
            ItemSend.sendCG_UseItem_Req(req)
        end, function()
            GameAudio.playUISound("success")
            table.remove(reqTable, 1)
            if #reqTable == 0 then
                if closeCallback ~= nil then
                    closeCallback()
                end
                PetFeedViewMgr.hide()
            else
                local req = reqTable[1]
                send()
            end
            if PetFeedViewMgr.haveGuideFeed == true then
                GameGuideMgr.guideFeedAfterSendProcess()
                PetFeedViewMgr.haveGuideFeed = false
            end
            
        end,function()
            print("use exp item failed!")
        end, nil, false)
    end

    local on_failed = function()
        print("use exp item failed!")
    end

    send()
    -- local req = reqTable[1]
    -- PetFeedViewMgr.sendUseExpItem(req.itemID, req.num, on_success, on_failed)
end

function PetFeedViewMgr.sendUseExpItem(itemID, num ,on_success, on_failed)
    
    local sendFunc = function()
        local ItemSend = require("src.Net.Send.ItemSend")
        local req =
        {
            itemID = itemID,
            targetNum = PetFeedViewMgr.CurrPetInfo.objID,
            targetStr = "",
            useNum = num
        }
        ItemSend.sendCG_UseItem_Req(req)
    end
    NetInterface.sendWithBlock("GC_UseItem_Ack", sendFunc, on_success, on_failed)
end

function PetFeedViewMgr.hide()
    -- expItemIDList = {}
    itemNode = {}
    PetFeedViewMgr.CurrPetInfo = nil
    PetFeedViewMgr.CurrPetRP = nil
    PetFeedViewMgr.CurrPetExp = nil
    PetFeedViewMgr.CurrPetLevel = nil
    PetFeedViewMgr.ExpItemUsed = {}
    PetFeedViewMgr.ExpGrowList = {}
    PetFeedViewMgr.PlayCurrPetExp = nil
    expAddPercent = 0

    UnblockLoader.cancel("PetFeedViewMgr")
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("PetFeedViewMgr")
end

function PetFeedViewMgr.commonTryFeed(currPetLevel, currPetExp, exp, currPetRP)
    local currExp = currPetExp
    local finalExp = currExp + exp
    local level  = currPetLevel
    local expNow = 0
    local addExp = false--是否有经验值增加
    while true do
        local expInfo = ExperienceInfo.getExperienceInfoByID(level)
        local maxExp  = expInfo.petExpVec[currPetRP]
        if level > CharInfo.getLevel() then
            level    = level - 1
            limitExp = PetFeedViewMgr.getLimitExpByLevel2(level, currPetRP)
            expNow   = (finalExp >= limitExp) and (limitExp - 1) or finalExp
            addExp  = true
            break
        else
            if finalExp < maxExp then
                expInfo = ExperienceInfo.getExperienceInfoByID(level - 1)
                maxExp  = expInfo.petExpVec[currPetRP]
                expNow  = finalExp - maxExp
                break
            end
        end
        level = level + 1
    end
    return level - currPetLevel, expNow, addExp
end

function PetFeedViewMgr.getLimitExpByLevel2(level, rare)
    local eInfo1  = ExperienceInfo.getExperienceInfoByID(level - 1)
    local eInfo2  = ExperienceInfo.getExperienceInfoByID(level)
    local maxExp1 = eInfo1.petExpVec[rare]
    local maxExp2 = eInfo2.petExpVec[rare]
    return maxExp2-- - maxExp1
end

function PetFeedViewMgr.refreshExpItem()
    PetFeedViewMgr.ExpItemAddNum = 0
    for k,v in pairs(expItemIDList) do
        local itemInfo   = ItemInfo.getItemInfoById(v)
        local paramA     = itemInfo.paramA
        local itemCount  = ItemInfo.getCharItemNum(v)
        PetFeedViewMgr.ExpItemAddNum = PetFeedViewMgr.ExpItemAddNum + paramA * itemCount
    end
end

function PetFeedViewMgr.getPetCanLvUp(petInfo)
    local level     = petInfo.level
    local topLevel  = PokemonInfo.getPokemonInfoByID(petInfo.pokeID).topLevel

    if level == topLevel or level == CharInfo.getLevel() then
        return false
    end

    local currExp   = petInfo.exp
    local rarePoint = PokemonInfo.getPokemonInfoByID(petInfo.pokeID).rarePoint
    local expInfo   = ExperienceInfo.getExperienceInfoByID(level)
    local needExp   = expInfo.petExpVec[rarePoint] - currExp
    return needExp <= PetFeedViewMgr.ExpItemAddNum
end

return PetFeedViewMgr