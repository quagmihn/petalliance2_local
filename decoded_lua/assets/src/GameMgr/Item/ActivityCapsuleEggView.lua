local ActivityCapsuleEggView = {}

local resName = ""
local resNameBuy = ""
local resNameC = ""
local TimeLimitEggReader = nil
local TimeLimitEggInfo = nil
local havePetTable = {}
local havePetInfoTable = {}
local tenAwardAniTable = {}
local stopGachaAnim = false
local activityInfo1 = {}
local theEggType = 1
local curSound = nil
local aID1 = nil
local pausePoint = 0
local petWiki = {}
local levelPath = {"c","b","a","s","2s","3s"}
local isCapsuling = false

function ActivityCapsuleEggView.Init()
    resName = "Item/Activity/ActivityCapsuleEggView.csb"
    resNameBuy = "Item/Activity/BuyCapsuleEggView.csb"
    resNameC = "Item/Activity/GetCapsuleEggView.csb"
    havePetTable = {}
    activityInfo1 = {}
    stopGachaAnim = false
    curSound = nil
    aID1 = nil
    pausePoint = 0
    petWiki = {}
    isCapsuling = false

    if TimeLimitEggReader==nil then
        TimeLimitEggReader = TxtReader.new("Config/TimeLimitEgg.txt")
        TimeLimitEggInfo = TimeLimitEggReader.init({"id","itemID", "rate"}, 1)
    end
end

function ActivityCapsuleEggView.show(scene,timeStr,aID,activityInfo)
    activityInfo1 = activityInfo
    aID1 = aID
    UIStack.push("ActivityCapsuleEggView", ActivityCapsuleEggView.hide, false)
    ActivityCapsuleEggView.hideTopInfoBar(false)
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)

        local title = CSResourceMgr.getNodeByName(resName, "title")        
        CSResourceMgr.setLabelStringByNode(title, "activity101", {r=115,g=61,b=4,a=255})
        local dayTips = CSResourceMgr.getNodeByName(resName, "dayTips")
        CSResourceMgr.setLabelStringByNode(dayTips, CocosModuleMgr.createStringWithFormat({"activity102", timeStr}), {r=0,g=0,b=0,a=255})

        petWiki = PetHandBook.getPetWikiInfoLst()

        local petTips = CSResourceMgr.getNodeByName(resName, "petTips")
        local bookTips = CSResourceMgr.getNodeByName(resName, "bookTips")
        local richLabelP = CocosModuleMgr.createRichLabel(petTips, CocosModuleMgr.createStringWithFormat({"activity21", activityInfo1[1].mCash}), 22, "cuyuan_GBK.ttf", 335,nil,nil,nil,true)
        petTips:setString(" ")
        petTips:setTextAreaSize({width = 0, height = richLabelP.realHeight})
        petTips:ignoreContentAdaptWithSize(false)

        local richLabelB = CocosModuleMgr.createRichLabel(bookTips, CocosModuleMgr.createStringWithFormat({"activity22", activityInfo1[2].mCash}), 22, "cuyuan_GBK.ttf", 335,nil,nil,nil,true)
        bookTips:setString(" ")
        bookTips:setTextAreaSize({width = 0, height = richLabelB.realHeight})
        bookTips:ignoreContentAdaptWithSize(false)

        local cover = CSResourceMgr.getNodeByName(resName, "cover")
        CSResourceMgr.clickEventBindingByNode(cover, function()
            ActivityCapsuleEggView.hide()
        end)

        local petBtn = CSResourceMgr.getNodeByName(resName, "petBtn")
        CSResourceMgr.clickEventBindingByNode(petBtn, function()
            ActivityCapsuleEggView.showBuyView(1)
        end)

        local bookBtn = CSResourceMgr.getNodeByName(resName, "bookBtn")
        CSResourceMgr.clickEventBindingByNode(bookBtn, function()
            ActivityCapsuleEggView.showBuyView(2)
        end)
    end

    local function playCSB()
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName,"diban"),"down")
    end

    local funcTable = {loadCSB, playCSB}
    loadCSB()
    playCSB()
end

function ActivityCapsuleEggView.hide()
    activityInfo1 = {}
    CSResourceMgr.removeCSObjectByTag(resNameBuy)
	CSResourceMgr.removeCSObjectByTag(resName)
    ActivityCapsuleEggView.hideTopInfoBar(true)
    UIStack.pop("ActivityCapsuleEggView")
end

function ActivityCapsuleEggView.getItemInfo(id)
    local itemInfo = {}
    local awardElementInfo = ItemInfo.getAwardElementInfoById(id)
    if awardElementInfo.elementType == 1 then
        itemInfo = ItemInfo.getItemInfoById(9998)
    elseif awardElementInfo.elementType == 2 then
        itemInfo = ItemInfo.getItemInfoById(9999)
    elseif awardElementInfo.elementType == 11 then
        itemInfo = ItemInfo.getItemInfoById(9996)
    elseif awardElementInfo.elementType == Proto.AET_PET then
        local pokeInfo = PokemonInfo.getPokemonInfoByID(awardElementInfo.elementID)
        itemInfo.icon = "Pet/PetIcon/"..pokeInfo.icon..".png"
        itemInfo.name = pokeInfo.name
        itemInfo.itemRare = pokeInfo.rarePoint
    else
        itemInfo = ItemInfo.getItemInfoById(awardElementInfo.elementID)
    end
    return itemInfo,awardElementInfo.elementType
end

function ActivityCapsuleEggView.showBuyView(aType, aID, activityInfo)
    theEggType = aType
    local function closeFunc()
        if aID and activityInfo then
            ActivityCapsuleEggView.hideTopInfoBar(true)
        end
        CSResourceMgr.removeCSObjectByTag(resNameBuy)
        UIStack.pop("ActivityCapsuleEggView.showBuyView")
    end
    if activityInfo then
    	activityInfo1 = activityInfo
    end
    if aID then
        aID1 = aID
    end
    if aID and activityInfo then
    	ActivityCapsuleEggView.hideTopInfoBar(false)
        UIStack.push("ActivityCapsuleEggView.showBuyView", closeFunc, false)
    end
    local buyLayer = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameBuy)
    buyLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
    CSResourceMgr.setFullScreen(resNameBuy)
    local diban = CSResourceMgr.getNodeByName(resNameBuy,"diban")
    CocosModuleMgr.showUIAnimation(diban,"down")

    local cover = CSResourceMgr.getNodeByName(resNameBuy, "cover")
    CSResourceMgr.clickEventBindingByNode(cover, function()
        closeFunc()
    end)

    for var=1,4 do
        local count = CSResourceMgr.getNodeByName(resNameBuy, "count"..var)
        CSResourceMgr.setLabelStringByNode(count, LuaSqlite.getLanguageByKey("activity"..(16+var)), {r=0,g=0,b=0,a=255})
        if aType == 2 and var < 4 then
            local tip = CSResourceMgr.getNodeByName(resNameBuy, "tip"..var)
            CSResourceMgr.setSpriteTextureByNode(tip, "Item/Activity/artword_activity_0"..4+var..".png")
        end
    end

    local cost = CSResourceMgr.getNodeByName(resNameBuy, "cost")
    CSResourceMgr.setLabelStringByNode(cost, activityInfo1[aType].mCash, {r=0,g=0,b=0,a=255})

    local count = 0
    if aType == 2 then
        count = 8
    end
    local index = 1
    for var=1+count,8+count do
        local awardBtn = CSResourceMgr.getNodeByName(resNameBuy, "awardBtn"..index)
        local itemInfo,petType = ActivityCapsuleEggView.getItemInfo(TimeLimitEggInfo[var].itemID)
        if petType == Proto.AET_PET then
            local icon = CSResourceMgr.getNodeByName(resNameBuy, "icon"..index)
            CSResourceMgr.setSpriteTextureByNode(icon, itemInfo.icon)
            local name = CSResourceMgr.getNodeByName(resNameBuy, "name"..index)
            CSResourceMgr.setLabelColorByNode(name, ItemInfo.COLOR[itemInfo.itemRare+1])
            CSResourceMgr.setLabelStringByNode(name, itemInfo.name, {r=0,g=0,b=0,a=255})

            local awardElementInfo = ItemInfo.getAwardElementInfoById(TimeLimitEggInfo[var].itemID)
            CSResourceMgr.clickEventBindingByNode(awardBtn, function()
                PetInfoViewMgr.show(SceneMgr.getRunningScene, awardElementInfo.elementID)
            end)
        else
            local icon = CSResourceMgr.getNodeByName(resNameBuy, "icon"..index)
            CSResourceMgr.setSpriteTextureByNode(icon, itemInfo.icon)
            icon:setScale(1.2)
            local name = CSResourceMgr.getNodeByName(resNameBuy, "name"..index)
            CSResourceMgr.setLabelColorByNode(name, ItemInfo.COLOR[itemInfo.itemRare+1])
            CSResourceMgr.setLabelStringByNode(name, itemInfo.name, {r=0,g=0,b=0,a=255})

            CSResourceMgr.clickEventBindingByNode(awardBtn, function()
                ItemInfoViewMgr.show({id = itemInfo.id}, false)
            end)
        end
        local path = "Pet/BasicPetList_2/Stage/"..itemInfo.itemRare..".png"
        CSResourceMgr.setButtonTextureByNode(awardBtn,path,path,path)
        local chance = CSResourceMgr.getNodeByName(resNameBuy, "chance"..index)
        CSResourceMgr.setLabelStringByNode(chance, CocosModuleMgr.createStringWithFormat({"activity23", TimeLimitEggInfo[var].rate}), {r=0,g=0,b=0,a=255})

        index = index + 1
    end

    local buyBtn = CSResourceMgr.getNodeByName(resNameBuy, "buyBtn")
    CSResourceMgr.clickEventBindingByNode(buyBtn, function()
        local mCash = CharInfo.getMCash()
        if mCash < activityInfo1[aType].mCash then
            StandardTipsMgr.show(1, "tips14")
        else
            local params = {}
            params.aID = aID1
            params.atype = aType
            NetInterface.sendWithBlock("GC_TimeLimitCapsuleEgg_Ack", function()
                local ActivitySend = require("src.Net.Send.ActivitySend")
                ActivitySend.sendCG_TimeLimitCapsuleEgg_Req(params)
            end)
        end
    end)
end

function ActivityCapsuleEggView.setTenDrawAward(awardsVec)
    if not CSResourceMgr.getCsbObj(resName) and not CSResourceMgr.getCsbObj(resNameBuy) and not isCapsuling then
        return
    end
    if isCapsuling then
        ActivityCapsuleEggView.hideTopInfoBar(false)
    end
    local closeFunc = function()
        UIStack.pop("ActivityCapsuleEggView.setTenDrawAward")
        for k,v in pairs(awardsVec) do
            if v.elementType == "pet" then
                petWiki[v.elementID] = v.elementID
            end
        end
        UnblockLoader.cancel("ActivityCapsuleEggC")
        CSResourceMgr.removeCSObjectByTag(resNameC)
        if isCapsuling then
            ActivityCapsuleEggView.hideTopInfoBar(true)
        end
        stopGachaAnim = false
        isCapsuling = false
    end
    UIStack.push("ActivityCapsuleEggView.setTenDrawAward", closeFunc, false)
    havePetTable = {}
    havePetInfoTable = {}
    tenAwardAniTable = {}
    local tenAwardsTable = {}
    awardsVec = GetRandom.randomTable(awardsVec)
    
    local function loadCSB()
        local page = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameC)
        page:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resNameC)
        CSResourceMgr.setRelativePosition(resNameC, 320, 480)

        CSResourceMgr.clickEventBinding(resNameC, "Button_Confirm", closeFunc)
        CSResourceMgr.clickEventBinding(resNameC, "bg", function()
            if curSound then
                audio.stopSound(curSound)
                GameAudio.playUISound("tenRaffleBreak")
                curSound = nil
            end
            stopGachaAnim = true
            for k,v in pairs(tenAwardsTable) do
                v:setScale(1)
                if tenAwardAniTable[k] then
                    AnimationMgr.playAni(tenAwardAniTable[k].res, "animation", true, "getAward"..k)
                end
            end
            transition.stopTarget(CSResourceMgr.getNodeByName(resNameC, "diban"))
        end)

        local title = CSResourceMgr.getNodeByName(resNameC, "title")
        CSResourceMgr.setLabelColorByNode(title, {r=254,g=215,b=34,a=255})
        CSResourceMgr.setLabelStringByNode(title, "activity31",{r=113,g=66,b=32,a=255})
        local confirmLabel = CSResourceMgr.getNodeByName(resNameC, "Text_Confirm")
        CSResourceMgr.setLabelColorByNode(confirmLabel, {r=227,g=233,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(confirmLabel, "egg20",{r=0,g=0,b=0,a=255})
        local str = "activity32"
        if theEggType == 2 then
            str = "activity33"
        end
        local serviceLabel = CSResourceMgr.getNodeByName(resNameC, "serviceLabel")
        CSResourceMgr.setLabelColorByNode(serviceLabel, {r=255,g=252,b=0,a=255})
        CSResourceMgr.setLabelStringByNode(serviceLabel, str,{r=151,g=48,b=29,a=255})
        
        local i = 1
        local function setAward(parent,awardVec)
            table.insert(tenAwardsTable,parent)
            local itemBack = CSResourceMgr.seekNodeByName(parent, "item_Copy")
            itemBack:setVisible(true)
            local awardIconPath = ""
            local awardIconPathTable = {"UI/CommonFiles/icon_jinbi.png","UI/CommonFiles/ico_lanzuan.png"}
            local itemIcon = CSResourceMgr.seekNodeByName(parent, "itemIcon_Copy")
            local itemRare = 0
            if awardVec.elementType == "g_cash" then
                awardIconPath = awardIconPathTable[1]
                awardVec.elementID = 9998
            elseif awardVec.elementType == "m_cash" then
                awardIconPath = awardIconPathTable[2]
                awardVec.elementID = 9999
            else
                local itemType = ItemInfo.getItemType(awardVec.elementID)
                local btnRes = ItemInfo.getItemRareBGImage(awardVec.elementID)
                if itemType==4 then
                    local petPieceInfo = ItemInfo.getPetPieceInfoById(awardVec.elementID)
                    local pokemonInfo = PokemonInfo.getPokemonInfoByID(PokemonInfo.getGeneInfoByID(petPieceInfo.pokeID).petID)
                    awardIconPath =  "Pet/PetIcon/"..pokemonInfo.icon..".png"
                    CSResourceMgr.seekNodeByName(parent, "mask"):setVisible(true)
                    itemIcon:setScale(0.9,0.9)
                    itemRare = pokemonInfo.rarePoint
                else
                    local itemInfo = ItemInfo.getItemInfoById(awardVec.elementID)
                    awardIconPath =itemInfo.icon
                    itemRare = itemInfo.itemRare+1
                end
                CSResourceMgr.setButtonTextureByNode(itemBack,btnRes,btnRes,btnRes)
            end
            CSResourceMgr.setSpriteTextureByNode(itemIcon, awardIconPath)
            local itemNum = CSResourceMgr.seekNodeByName(parent, "itemNum_Copy")
            CSResourceMgr.setLabelColorByNode(itemNum, {r=255,g=255,b=255,a=255})
            CSResourceMgr.setLabelStringByNode(itemNum, awardVec.num,{r=0,g=0,b=0,a=255},1,80)   
            if itemRare >= 5 then
                local effAni = AnimationMgr.createAni(itemBack, "Spine/effects/Ui_shilianchoudaojuwaikuang.png", 
                    itemBack:getContentSize().width/2+2, itemBack:getContentSize().height/2-2,"getAward"..i)
                effAni:setLocalZOrder(1)
                effAni:setScale(1,1.2)
                tenAwardAniTable[i] = effAni
            end     
            i = i + 1

            CSResourceMgr.clickEventBindingByNode(itemBack, function()
                ItemInfoViewMgr.show({id = awardVec.elementID, sum = awardVec.num, type = 1}, false)
            end, 3)
            parent:setScale(0)
        end
       
        local function setPet(parent,awardVec)
            table.insert(tenAwardsTable,parent)
            local pokemonInfo = PokemonInfo.getPokemonInfoByID(awardVec.elementID)
            local petBack = CSResourceMgr.seekNodeByName(parent, "pet_Copy")
            CSResourceMgr.setButtonTextureByNode(petBack,"Pet/BasicPetList_2/Stage/"..pokemonInfo.rarePoint..".png","Pet/BasicPetList_2/Stage/"..pokemonInfo.rarePoint..".png","Pet/BasicPetList_2/Stage/"..pokemonInfo.rarePoint..".png")
            petBack:setVisible(true)
            local monsterIcon = CSResourceMgr.seekNodeByName(parent,"petIcon_Copy")
            monsterIcon:setScale(0.95,0.95)
            CSResourceMgr.setSpriteTextureByNode(monsterIcon, "Pet/PetIcon/"..pokemonInfo.icon..".png")
            local monsterAttr = CSResourceMgr.seekNodeByName(parent,"attributeIcon_Copy")
            CSResourceMgr.setSpriteTextureByNode(monsterAttr, "Pet/AttriIcon/"..pokemonInfo.elementAtt1..".png")
            local monsterAttrBack = CSResourceMgr.seekNodeByName(parent,"attributeIconBack_Copy")
            CSResourceMgr.setSpriteTextureByNode(monsterAttrBack, "Pet/AttriIcon/small_"..pokemonInfo.elementAtt1..".png")
            local monsterLevel = CSResourceMgr.seekNodeByName(parent,"petLevel_Copy")
            CSResourceMgr.setSpriteTextureByNode(monsterLevel, "Pet/Education/"..levelPath[pokemonInfo.rarePoint]..".png")
            if pokemonInfo.rarePoint >= 5 then
                monsterAttrBack:setLocalZOrder(2)
                monsterAttr:setLocalZOrder(3)
                monsterLevel:setLocalZOrder(4)
                local effAni = AnimationMgr.createAni(petBack, "Spine/effects/Ui_shilianchoudaojuwaikuang.png", 
                    petBack:getContentSize().width/2+2, petBack:getContentSize().height/2-2,"getAward"..i)
                effAni:setLocalZOrder(1)
                effAni:setScale(1,1.2)
                tenAwardAniTable[i] = effAni
            end
            i = i + 1

            CSResourceMgr.clickEventBindingByNode(petBack, function()
                PetInfoViewMgr.show(SceneMgr.getRunningScene, awardVec.elementID)
            end, 3)
            parent:setScale(0)
        end

        local m = 1
        for k,v in pairs(awardsVec) do
            local cjson = require("cjson")
            local parent = CSResourceMgr.getNodeByName(resNameC, "getItem_Copy_"..k)
            if v.elementType == "pet" and ActivityCapsuleEggView.isHavePet(v.elementID,cjson.decode(v.detail)) then
                setPet(parent,v)
            elseif v.elementType == "pet" and not ActivityCapsuleEggView.isHavePet(v.elementID,cjson.decode(v.detail)) then
                setPet(parent,v)
                havePetTable[m] = v.elementID
                havePetInfoTable[m] = cjson.decode(v.detail)
            else
                setAward(parent,v)
            end
            m = m + 1   
        end
    end

    local function playCSB()
        CSResourceMgr.playActionWithCallback(resNameC, 0, 5, 1, function()
            local node = CSResourceMgr.getNodeByName(resNameC, "diwen2")
            local effAni = AnimationMgr.createAni(node, "Spine/effects/Ui_daojulingqu.png", 
                node:getContentSize().width/2, node:getContentSize().height/2+100)
            effAni:setLocalZOrder(-2)
            effAni:setScale(1.5)
            AnimationMgr.playAni(effAni.res, "animation", true, effAni.tag)
            ActivityCapsuleEggView.playSetAward(1)
        end, "")
    end

    local funcTable = {loadCSB, playCSB}

    ActivityCapsuleEggView.addGachaAni(function()
        UnblockLoader.load(funcTable, "ActivityCapsuleEggC")
    end)
end

function ActivityCapsuleEggView.addGachaAni(callback)
    local diff = CocosModuleMgr.getScreenSizeDiff()
    if diff<0 then
        diff = 0
    end
    local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, "Scene/CommonShade.csb", "getAni")
    CSResourceMgr.setRelativePosition(layer.res, 320, 480, layer.tag)
    layer:zorder(CocosModuleMgr.ZORDER_WINDOW)
    
    local circle = CSResourceMgr.getNodeByName(resNameBuy,"circle")
    local getAni = AnimationMgr.createAni(SceneMgr.getRunningScene, "Spine/effects/Ui_chongwuchoujiang.png", 
        display.cx, display.cy, "getAni")
    getAni:zorder(CocosModuleMgr.ZORDER_WINDOW)
    GameAudio.playUISound("gashapon")
    AnimationMgr.playAniWithCallback(getAni.res, "animation", function()
        CSResourceMgr.removeCSObjectByTag(layer.res, layer.tag)
        callback()
    end, "getAni", true)
end

function ActivityCapsuleEggView.playSetAward(m)
    if not CSResourceMgr.getCsbObj(resName) and not CSResourceMgr.getCsbObj(resNameBuy) and not isCapsuling then
        return
    end
    local deltaTime = m==1 and 0.1 or 0
    local diban = CSResourceMgr.getNodeByName(resNameC, "diban")
    diban:performWithDelay(function()
        local musicStr = m==10 and "tenRaffleBreak" or "tenRaffle"
        curSound = GameAudio.playUISound(musicStr)
    end,deltaTime)
    for i=m,10 do
        local parent = CSResourceMgr.getNodeByName(resNameC, "getItem_Copy_"..i)
        diban:performWithDelay(function()
            if havePetTable[i] then
                diban:performWithDelay(function()
                    GachaViewMgr.playGetAPet(havePetTable[i],havePetInfoTable[i],nil,nil,true)
                end,0.1)
            end
            diban:performWithDelay(function()
                if tenAwardAniTable[i] then
                    AnimationMgr.playAni(tenAwardAniTable[i].res, "animation", true, "getAward"..i)
                end
                transition.scaleTo(parent, {scale=1, time=0.2})
                if i == 10 and curSound then
                    audio.stopSound(curSound)
                    curSound = nil
                    GameAudio.playUISound("tenRaffleBreak")
                end
            end,0.1)
        end,0.2*(i-m+deltaTime))
        if havePetTable[i] then
            pausePoint = i+1
            break
        end
    end   
end

function ActivityCapsuleEggView.hideTopInfoBar(visible)
    if visible == false then
        StatusBarMgr.hideTopInfoBar(0)
    else
        StatusBarMgr.showTopInfoBar(nil,0)
    end
end

function ActivityCapsuleEggView.getPausePoint()
    return pausePoint
end

function ActivityCapsuleEggView.isHavePet(petID,petInfo)
    local petWikiNew = PetHandBook.getPetWikiInfoLst()
    if petInfo and petInfo.skin~=0 then
        return false
    end
    if petWikiNew[petID] then
        return true
    end
    return false
end

function ActivityCapsuleEggView.getGachaAwardsInfo()
    local vec = {}
	for var=1, 13 do
        local aID = TimeLimitEggInfo[var].itemID
        table.insert(vec, {aID, "nil"})
	end
	return vec
end

function ActivityCapsuleEggView.setIsCapsuling(val)
    isCapsuling = val
end

return ActivityCapsuleEggView