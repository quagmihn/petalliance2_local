local GachaViewMgr = {}

local resNameBG = ""
local resName = {}
local resNameA = {}
local resNameB = {}
local resNameC = {}
local resNameD = {}
local resNameE = {}
local eggtype = {} 
local colorTable = {}
local colorTable2 = {}
local outLineColorTable = {}
local titleTable = {}
local level1Table = {}
local level2Table = {}
local theEggType = 1
local isEggMFree = 0--1免费 0不免费
local isEggGFree = 0
local levelPath = {}
local eggAllInfo = {}
-- local eggAllInfo2 = {}
local hopeValue = 0
local openHopeForce = false
local monsterTable = {}
local isHopeForce = false
local isDreamForce = false
local hopeValueMax = 0
-- local hopeValue2 = 0
-- local openHopeForce2 = false
-- local monsterTable2 = {}
-- local isHopeForce2 = false
-- local hopeValueMax2 = 0
local dreamValue = 0
local dreamMonsterTable = {}
local dreamValueMax = 0
local gMachineTime = nil
local mMachineTime = nil
local oneDrawCostLabelG = nil
local oneDrawCostLabelM = nil
local oneDrawCostLabelG2 = nil
local oneDrawCostLabelM2 = nil
local lastTime1 = 0
local lastTime2 = 0
local todayTimeG = 0
local petWiki = {}
local havePetTable = {}
local havePetInfoTable = {}
local pausePoint = 0
local isTenChou = false
local tenAwardAniTable = {}
local freeEggHandler = nil
local scheduler = require("src.framework.scheduler")
local circlePath = {}
local titlePath = {}
local stopGachaAnim = false
local orderString = {}
local curSound = nil

local function showDrawError(code)
    if code and code > 0 and code ~= Proto.Error.ERROR__PET_BRINGLIMIT
            and code ~= Proto.Error.ERROR_NOT_ENOUGH_BAG_FREE_CELL then
        TipsMgr.showError(SceneMgr.getRunningScene, code)
    end
end

local function machineDrawFailed(machine, buttonGroup, code)
    GameGuideMgr.cancelGachaResultWait()
    if CSResourceMgr.getCsbObj(resNameA) == machine then
        CSResourceMgr.setButtonEnabledByNode(buttonGroup, true)
        showDrawError(code)
    end
end

local function resultDrawFailed(machine, code)
    GameGuideMgr.cancelGachaResultWait()
    if machine and CSResourceMgr.getCsbObj(resNameA) == machine then
        GachaViewMgr.setVisible(true)
        showDrawError(code)
    end
end

function GachaViewMgr.Init()
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    resName = "Item/Gacha/gachaListView.csb"
    resNameA = "Item/Gacha/gachaMachineView.csb"
    resNameB = "Item/Gacha/oneDrawAwardView.csb"
    resNameC = "Item/Gacha/tenDrawAwardView.csb"
    resNameD = "Item/Gacha/hopeForceView.csb"
    resNameE = "Item/Gacha/getPetView.csb"

    eggType = {gMachine = 1,mMachine = 2 ,vMachine = 3} 
    colorTable = {{r=103,g=91,b=71},{r=71,g=96,b=103},{r=93,g=71,b=103}}
    colorTable2 = {{r=67,g=51,b=16,a=255},{r=3,g=70,b=108,a=255},{r=130,g=14,b=130,a=255}}
    descColorTable = {{r=255,g=234,b=158,a=255},{r=143,g=227,b=255,a=255},{r=255,g=197,b=255,a=255}}
    outLineColorTable = {{r=67,g=51,b=16,a=255},{r=11,g=51,b=76,a=255},{r=77,g=14,b=93,a=255}}
    titleTable = {"egg1","egg5","egg7"}
    level1Table = {"c","a","s"}
    level2Table = {"a","s","2s"}
    theEggType = 1
    isEggMFree = 0
    isEggGFree = 0
    levelPath = {"c","b","a","s","2s","3s"}
    eggAllInfo = {}
    -- eggAllInfo2 = {}
    hopeValue = 0
    monsterTable = {}
    hopeValueMax = 0
    -- hopeValue2 = 0
    -- monsterTable2 = {}
    -- hopeValueMax2 = 0
    dreamValue = 0
    dreamMonsterTable = {}
    dreamValueMax = 0
    gMachineTime = nil
    mMachineTime = nil
    oneDrawCostLabelG = nil
    oneDrawCostLabelM = nil
    oneDrawCostLabelG2 = nil
    oneDrawCostLabelM2 = nil
    lastTime1 = 0
    lastTime2 = 0
    todayTimeG = 0
    petWiki = {}
    pausePoint = 0
    havePetTable = {}
    havePetInfoTable = {}
    isTenChou = false
    tenAwardAniTable = {}
    circlePath = {"UI/CommonFiles/zhutu_chuji.png","UI/CommonFiles/zhutu_gaoji.png","UI/CommonFiles/zhutu_jinengshu.png"}
    titlePath = {"chujixinyuan.png","gaojixinyuan.png","jinengxinyuan.png"}
    stopGachaAnim = false
    orderString = {
        [1] = "Pet/Education/c.png",
        [2] = "Pet/Education/b.png",
        [3] = "Pet/Education/a.png",
        [4] = "Pet/Education/s.png",
        [5] = "Pet/Education/2s.png",
        [6] = "Pet/Education/3s.png",
    }
    curSound = nil
end


function GachaViewMgr.show(scene)
    if CSResourceMgr.getCsbObj(resName) then
        return
    end
    UIStack.push("GachaViewMgr",GachaViewMgr.hide,true)
    eggAllInfo = {}
    -- eggAllInfo2 = {}
    openHopeForce = false
    -- openHopeForce2 = false
    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG, "GachaViewMgr")
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "GachaViewMgr")
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    end

    local function playCSB()
        if CSResourceMgr.getCsbObj(resName) then
            CSResourceMgr.getCsbObj(resName):setVisible(true)
            local node = CSResourceMgr.getNodeByName(resName,"diban")
            -- CocosModuleMgr.showUIAnimation(node,"up")
            local buttonEggG = CSResourceMgr.getNodeByName(resName,"Button_Enter1")
            local buttonEggM = CSResourceMgr.getNodeByName(resName,"Button_Enter2")
            local buttonEggV = CSResourceMgr.getNodeByName(resName,"Button_Enter3")
            transition.moveTo(buttonEggG,{x = 240,time = 0.2})
            transition.moveTo(buttonEggM,{x = 360,time = 0.2})
            transition.moveTo(buttonEggV,{x = 240,time = 0.2})
            node:performWithDelay(function()
                transition.moveTo(buttonEggG,{x = 300,time = 0.1})
                transition.moveTo(buttonEggM,{x = 300,time = 0.1})
                transition.moveTo(buttonEggV,{x = 300,time = 0.1})
            end,0.2)
            StatusBarMgr.showTopInfoBar(function()
                GachaViewMgr.hide()
            end)
        end
    end

    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        curLayer:setVisible(false)
        CSResourceMgr.setFullScreen(resName)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CocosModuleMgr.setEdgeDistance(page, nil, nil, nil, 0)

        --...

        petWiki = PetHandBook.getPetWikiInfoLst()

        local capsuleEggInfo1 = PokemonInfo.getCapsuleEggInfoByID(eggType.gMachine)
        local consumeElementInfo1 = ItemInfo.getConsumeElementInfoById(capsuleEggInfo1.OneEggCons)
        local consumeElementInfo2 = ItemInfo.getConsumeElementInfoById(capsuleEggInfo1.tenEggCons)
        local eggG = CSResourceMgr.getNodeByName(resName, "eggG")
        local freeTimeLabel1 = CSResourceMgr.seekNodeByName(eggG,"freeTimeNum")
        CSResourceMgr.setLabelColorByNode(freeTimeLabel1, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(freeTimeLabel1, LuaSqlite.getLanguageByKey("egg2").."00:00:00", colorTable2[1],nil,225)
        local money1G = CSResourceMgr.seekNodeByName(eggG,"money1Num")
        CSResourceMgr.setLabelColorByNode(money1G, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(money1G, LuaSqlite.getLanguageByKey("egg35").."/"..consumeElementInfo1.num,colorTable2[1],nil,115)
        local money2G = CSResourceMgr.seekNodeByName(eggG,"money2Num")
        CSResourceMgr.setLabelColorByNode(money2G, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(money2G, LuaSqlite.getLanguageByKey("egg36").."/"..consumeElementInfo2.num,colorTable2[1],nil,166)
        local descLabel1 = CSResourceMgr.seekNodeByName(eggG,"desc")
        CSResourceMgr.setLabelColorByNode(descLabel1, descColorTable[1])
        CSResourceMgr.setLabelStringByNode(descLabel1, nil,outLineColorTable[1],nil,595)
        descLabel1:setString("LOCAL PRIZE POOL")
        CSResourceMgr.seekNodeByName(eggG,"title"):loadTexture(CocosModuleMgr.getWordImage("chujixinyuan.png"))

        local capsuleEggInfo2 = PokemonInfo.getCapsuleEggInfoByID(eggType.mMachine)
        openHopeForce = capsuleEggInfo2.addTypeName ~= ""
        local consumeElementInfo3 = ItemInfo.getConsumeElementInfoById(capsuleEggInfo2.OneEggCons)
        local consumeElementInfo4 = ItemInfo.getConsumeElementInfoById(capsuleEggInfo2.tenEggCons)
        local eggM = CSResourceMgr.getNodeByName(resName, "eggM")
        local freeTimeLabel2 = CSResourceMgr.seekNodeByName(eggM,"freeTimeNum")
        CSResourceMgr.setLabelColorByNode(freeTimeLabel2, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(freeTimeLabel2, LuaSqlite.getLanguageByKey("egg2").."00:00:00", colorTable2[2],nil,225)
        local money1M = CSResourceMgr.seekNodeByName(eggM,"money1Num")
        CSResourceMgr.setLabelColorByNode(money1M, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(money1M, LuaSqlite.getLanguageByKey("egg35").."/"..consumeElementInfo3.num,colorTable2[2],nil,115)
        local money2M = CSResourceMgr.seekNodeByName(eggM,"money2Num")
        CSResourceMgr.setLabelColorByNode(money2M, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(money2M, LuaSqlite.getLanguageByKey("egg36").."/"..consumeElementInfo4.num,colorTable2[2],nil,166)
        local descLabel2 = CSResourceMgr.seekNodeByName(eggM,"desc")
        CSResourceMgr.setLabelColorByNode(descLabel2, descColorTable[2])
        CSResourceMgr.setLabelStringByNode(descLabel2, nil,outLineColorTable[2],nil,595)
        descLabel2:setString("LOCAL PRIZE POOL")
        CSResourceMgr.seekNodeByName(eggM,"title"):loadTexture(CocosModuleMgr.getWordImage("gaojixinyuan.png"))
        hopeValueMax = capsuleEggInfo2.wishCost
        dreamValueMax = capsuleEggInfo2.dreamCost
        CSResourceMgr.seekNodeByName(eggM, "blackback"):setVisible(false)

        local capsuleEggInfo3 = PokemonInfo.getCapsuleEggInfoByID(eggType.vMachine)
        -- openHopeForce2 = capsuleEggInfo3.addTypeName ~= ""
        local consumeElementInfo5 = ItemInfo.getConsumeElementInfoById(capsuleEggInfo3.OneEggCons)
        local consumeElementInfo6 = ItemInfo.getConsumeElementInfoById(capsuleEggInfo3.tenEggCons)
        local eggV = CSResourceMgr.getNodeByName(resName, "eggV")
        local money1V = CSResourceMgr.seekNodeByName(eggV,"money1Num")
        CSResourceMgr.setLabelColorByNode(money1V, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(money1V, LuaSqlite.getLanguageByKey("egg35").."/"..consumeElementInfo5.num,colorTable2[3],nil,115)
        local money2V = CSResourceMgr.seekNodeByName(eggV,"money2Num")
        CSResourceMgr.setLabelColorByNode(money2V, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(money2V, LuaSqlite.getLanguageByKey("egg36").."/"..consumeElementInfo6.num,colorTable2[3],nil,166)
        local descLabel3 = CSResourceMgr.seekNodeByName(eggV,"desc")
        CSResourceMgr.setLabelColorByNode(descLabel3, descColorTable[3])
        CSResourceMgr.setLabelStringByNode(descLabel3, nil,outLineColorTable[3],nil,595)
        descLabel3:setString("LOCAL PRIZE POOL")
        CSResourceMgr.seekNodeByName(eggV,"title"):loadTexture(CocosModuleMgr.getWordImage("jinengxinyuan.png"))
        -- hopeValueMax2 = capsuleEggInfo3.addTypeCost

        local buttonEggG = CSResourceMgr.getNodeByName(resName,"Button_Enter1")
        CSResourceMgr.clickEventBindingByNode(buttonEggG, function()
            theEggType = eggType.gMachine
            GachaViewMgr.setMachine(theEggType)
            -- CSResourceMgr.getNodeByName(resName,"redPointG"):setVisible(false)
        end,2)
        
        local buttonEggM = CSResourceMgr.getNodeByName(resName,"Button_Enter2")
        CSResourceMgr.clickEventBindingByNode(buttonEggM, function()
            theEggType = eggType.mMachine
            GachaViewMgr.setMachine(theEggType)
            --屏蔽心愿梦想
            -- if hopeValue < hopeValueMax and dreamValue < dreamValueMax then
            --     GachaViewMgr.setMachine(theEggType)
            -- elseif hopeValue >= hopeValueMax then
            --     GachaViewMgr.setHopeForce(3)
            -- else
            --     GachaViewMgr.setHopeForce(4)
            -- end

            -- CSResourceMgr.getNodeByName(resName,"redPointM"):setVisible(false)
        end,2)

        local capsuleEggInfo3 = PokemonInfo.getCapsuleEggInfoByID(eggType.vMachine)
        local needVipLv = capsuleEggInfo3.vipLevel
        -- if CharInfo.getVIPLevel() >= needVipLv then
        if true then
            eggV:setColor({r=255,g=255,b=255})
            local buttonEggV = CSResourceMgr.getNodeByName(resName,"Button_Enter3")
            CSResourceMgr.clickEventBindingByNode(buttonEggV, function()
                theEggType = eggType.vMachine
                -- if hopeValue2 < hopeValueMax2 then
                    GachaViewMgr.setMachine(theEggType)
                -- else
                    -- GachaViewMgr.setHopeForce()
                -- end   
            end,2)
        else
            eggV:setColor({r=128,g=128,b=128})
        end

        if openHopeForce --[[or openHopeForce2]] then
            NetInterface.sendWithBlock("GC_CapsuleEggAllInfoCmd_Ack", function()
                local PetSend = require("src.Net.Send.PetSend")
                PetSend.sendCG_CapsuleEggAllInfoCmd_Req()
            end)
        end

        CSResourceMgr.clickEventBinding(resName, "bg", function()
            GachaViewMgr.hide()
        end)

        local diff = CocosModuleMgr.getScreenSizeDiff()
        if diff<0 then
            diff = 0
        end
        local gposy = eggG:getPositionY()
        eggG:setPositionY(gposy+diff/3)  
        local vposy = eggV:getPositionY()
        eggV:setPositionY(vposy-diff/3) 
        local node = CSResourceMgr.getNodeByName(resName,"node")
        local nposy = node:getPositionY()
        node:setPositionY(nposy+diff/2)   

        NetInterface.sendWithBlock("GC_CapsuleEggCDs_Ack", function()
            local PetSend = require("src.Net.Send.PetSend")
            PetSend.sendCG_CapsuleEggCDs_Req()
        end,function()
            playCSB()
        end,function(code)
            if code == -1 then
                NetInterface.sendWithBlock("GC_CapsuleEggCDs_Ack", function()
                    local PetSend = require("src.Net.Send.PetSend")
                    PetSend.sendCG_CapsuleEggCDs_Req()
                end,function()
                    playCSB()
                end)
            end
        end)
    end

    local funcTable = {loadBG,loadCSB}

    UnblockLoader.load(funcTable, "GachaViewMgr")
end

function GachaViewMgr.setMachine(theEggType)
    UIStack.push("GachaViewMgr.setMachine",function()
        GameGuideMgr.cancelGachaResultWait()
        UIStack.pop("GachaViewMgr.setMachine")
        gMachineTime = nil
        mMachineTime = nil
        oneDrawCostLabelG = nil
        oneDrawCostLabelM = nil
        UnblockLoader.cancel("GachaViewMgrA")
        CSResourceMgr.removeCSObjectByTag(resNameA)   
        if CSResourceMgr.getCsbObj(resName) then
            CSResourceMgr.getNodeByName(resName,"diban"):setVisible(true)
        end
        CSResourceMgr.clickEventBinding("Charactor/TopInfoLayer.csb", "close", function()
            GachaViewMgr.hide()
        end)   
    end,false)
    isHopeForce = false
    isDreamForce = false
    -- isHopeForce2 = false
    GameAudio.playUISound("popup")
    local function loadCSB()
        local page = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameA)
        page:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        page:setVisible(false)
        CSResourceMgr.setFullScreen(resNameA)
        CSResourceMgr.setRelativePosition(resNameA, 320, 480)
        CocosModuleMgr.setEdgeDistance(page, nil, nil, nil, 0)

        local diff = CocosModuleMgr.getScreenSizeDiff()
        if diff<0 then
            diff = 0
        end
        local circle = CSResourceMgr.getNodeByName(resNameA, "circle")
        local cposy = circle:getPositionY()
        circle:setPositionY(cposy+diff/2) 
        local OneChou = CSResourceMgr.getNodeByName(resNameA, "OneChou")
        local oposy = OneChou:getPositionY()
        OneChou:setPositionY(oposy+diff/2) 
        local TenChou = CSResourceMgr.getNodeByName(resNameA, "TenChou")
        local tposy = TenChou:getPositionY()
        TenChou:setPositionY(tposy+diff/2)   
        local title = CSResourceMgr.getNodeByName(resNameA, "title")
        local ttposy = title:getPositionY()
        title:setPositionY(ttposy+diff) 
        local timeBack = CSResourceMgr.getNodeByName(resNameA, "timeBack")
        local tbposy = timeBack:getPositionY()
        timeBack:setPositionY(tbposy+diff) 
        local diban = CSResourceMgr.getNodeByName(resNameA, "diban")
        local cbbi = CSResourceMgr.createCCBI(diban, "texture/ui_dc_16.ccbi", circle:getPositionX()-17, circle:getPositionY())
        cbbi:setLocalZOrder(-1)

        local function closeMachine()
            GameGuideMgr.cancelGachaResultWait()
            UIStack.pop("GachaViewMgr.setMachine")
            GameAudio.playUISound("retract")
            gMachineTime = nil
            mMachineTime = nil
            oneDrawCostLabelG = nil
            oneDrawCostLabelM = nil
            UnblockLoader.cancel("GachaViewMgrA")
            CSResourceMgr.removeCSObjectByTag(resNameA)
            if CSResourceMgr.getCsbObj(resName) then   
                CSResourceMgr.getNodeByName(resName,"diban"):setVisible(true)
            end        
        end

        CSResourceMgr.clickEventBinding("Charactor/TopInfoLayer.csb", "close", function()
            closeMachine()
            CSResourceMgr.clickEventBinding("Charactor/TopInfoLayer.csb", "close", function()
                GachaViewMgr.hide()
            end)
        end)

        local capsuleEggInfo1 = PokemonInfo.getCapsuleEggInfoByID(theEggType)
        local consumeElementInfo1 = ItemInfo.getConsumeElementInfoById(capsuleEggInfo1.OneEggCons)
        local consumeElementInfo2 = ItemInfo.getConsumeElementInfoById(capsuleEggInfo1.tenEggCons)

        local cashIconPath = theEggType>1 and "UI/CommonFiles/ico_gbis.png" or "UI/CommonFiles/ico_jinbis.png"
        local cashIconPath2 = theEggType>1 and "Player/MissionIcon/lanzuan_32.png" or "UI/CommonFiles/gbi_32.png"
        local charCashNum =  theEggType>1 and CharInfo.getMCash() or CharInfo.getGCash()
        -- local cashIconPath = "UI/CommonFiles/ico_jinbis.png"
        -- local cashIconPath2 = "UI/CommonFiles/gbi_32.png"
        -- local charCashNum =  CharInfo.getGCash()

        local isMachineFree = 0
        if theEggType == eggType.gMachine then
            isMachineFree = isEggGFree
        elseif theEggType == eggType.mMachine then
            isMachineFree = isEggMFree
        end
        local money = isMachineFree==1 and "egg29" or consumeElementInfo1.num

        local OneChou = CSResourceMgr.getNodeByName(resNameA, "OneChou")
        local moneyNum = CSResourceMgr.seekNodeByName(OneChou,"moneyNum")
        CSResourceMgr.setLabelColorByNode(moneyNum, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(moneyNum, money)
        local moneyIcon = CSResourceMgr.seekNodeByName(OneChou,"moneyIcon")
        CSResourceMgr.setSpriteTextureByNode(moneyIcon, cashIconPath2)
        local buttonOneDrawLabel = CSResourceMgr.seekNodeByName(OneChou,"Text_Go")
        CSResourceMgr.setLabelColorByNode(buttonOneDrawLabel, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(buttonOneDrawLabel, "egg13", {r=29,g=131,b=185,a=255})
  
        local freeLabelNum = CSResourceMgr.getNodeByName(resNameA,"Text_freeTime")
        CSResourceMgr.setLabelColorByNode(freeLabelNum, {r=255,g=255,b=255,a=255})
        
        if isEggGFree==1 and theEggType == eggType.gMachine then
            CSResourceMgr.setLabelStringByNode(freeLabelNum, LuaSqlite.getLanguageByKey("egg31")..":"..todayTimeG)
        else
            CSResourceMgr.setLabelStringByNode(freeLabelNum, LuaSqlite.getLanguageByKey("egg2").."00:00:00")
        end

        local unEnoughLabel = ""
        if theEggType == eggType.gMachine then
            gMachineTime = freeLabelNum
            unEnoughLabel = "egg25"
            oneDrawCostLabelG = moneyNum
        elseif theEggType == eggType.mMachine then
            mMachineTime = freeLabelNum
            unEnoughLabel = "egg27"
            oneDrawCostLabelM = moneyNum
        else
            unEnoughLabel = "egg27"
        end

        local TenChou = CSResourceMgr.getNodeByName(resNameA, "TenChou")
        local moneyNum2 = CSResourceMgr.seekNodeByName(TenChou,"moneyNum")
        CSResourceMgr.setLabelColorByNode(moneyNum2, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(moneyNum2, consumeElementInfo2.num)
        local moneyIcon2 = CSResourceMgr.seekNodeByName(TenChou,"moneyIcon")
        CSResourceMgr.setSpriteTextureByNode(moneyIcon2, cashIconPath2)
        local buttonTenDrawLabel = CSResourceMgr.seekNodeByName(TenChou,"Text_Go")
        CSResourceMgr.setLabelColorByNode(buttonTenDrawLabel, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(buttonTenDrawLabel, "egg14", {r=29,g=131,b=185,a=255})

        CSResourceMgr.getNodeByName(resNameA,"circle"):loadTexture(circlePath[theEggType])
        CSResourceMgr.getNodeByName(resNameA,"pic"):setVisible(false)
        CSResourceMgr.getNodeByName(resNameA,"title"):loadTexture(CocosModuleMgr.getWordImage(titlePath[theEggType]))

        local timeBack = CSResourceMgr.getNodeByName(resNameA, "timeBack")
        local titleWidth = CSResourceMgr.getNodeByName(resNameA,"title"):getContentSize().width
        local titlePosX = CSResourceMgr.getNodeByName(resNameA,"title"):getPositionX()
        timeBack:setPositionX(titlePosX-titleWidth/2+6)

        if theEggType ==  eggType.vMachine then
             local freeNode = CSResourceMgr.getNodeByName(resNameA,"timeBack")
             freeNode:setVisible(false)
        end

        -- The packaged preview is for the original pools and does not show
        -- the rewards selected by the configured local server.
        local preview = CSResourceMgr.getNodeByName(resNameA, "MaybeGetItem")
        if preview then
            preview:setVisible(false)
        end

        local buttonOneDraw = CSResourceMgr.seekNodeByName(OneChou,"Button_Go")
        CSResourceMgr.clickEventBindingByNode(buttonOneDraw, function()
                    GameAudio.playUISound("select1")
                    isTenChou = false
                    local bfree = 0
                    if theEggType == eggType.gMachine then
                        bfree = isEggGFree
                    elseif theEggType == eggType.mMachine then
                        bfree = isEggMFree
                    end
                    charCashNum =  theEggType>1 and CharInfo.getMCash() or CharInfo.getGCash()
                    -- charCashNum =  CharInfo.getGCash()
                    if charCashNum>= consumeElementInfo1.num or bfree==1 then
                        local isFree = bfree==1
                        CSResourceMgr.setButtonEnabledByNode(OneChou, false)
                        NetInterface.sendWithBlock("GC_CapsuleEgg_Ack", function()
                            local PetSend = require("src.Net.Send.PetSend")
                            PetSend.sendCG_CapsuleEgg_Req({optType=theEggType ,choice = 1 ,bFree = bfree,choiceEx = 0})
                            end,function()
                                    CSResourceMgr.setButtonEnabledByNode(OneChou, true)
                                    if theEggType == eggType.mMachine and openHopeForce then
                                        NetInterface.sendWithBlock("GC_CapsuleEggAllInfoCmd_Ack", function()
                                        local PetSend = require("src.Net.Send.PetSend")
                                        PetSend.sendCG_CapsuleEggAllInfoCmd_Req()
                                        end)
                                    end
                                    -- if theEggType == eggType.vMachine and openHopeForce2 then
                                    --     NetInterface.sendWithBlock("GC_CapsuleEggAllInfoCmd_Ack", function()
                                    --     local PetSend = require("src.Net.Send.PetSend")
                                    --     PetSend.sendCG_CapsuleEggAllInfoCmd_Req()
                                    --     end)
                                    -- end
                                    NetInterface.sendWithBlock("GC_CapsuleEggCDs_Ack", function()
                                    local PetSend = require("src.Net.Send.PetSend")
                                    PetSend.sendCG_CapsuleEggCDs_Req()
                                    end,function()
                                        -- GachaViewMgr.refreshServerTime()
                                    end)
                                end,function(code)
                                    machineDrawFailed(page, OneChou, code)
                                end,nil,false,function()
                                    machineDrawFailed(page, OneChou)
                                end)
                    else
                        DialogBoxMgr.showSmallDialogBox(scene, 1, unEnoughLabel)
                    end
            end)

        local buttonTenDraw = CSResourceMgr.seekNodeByName(TenChou,"Button_Go")
        CSResourceMgr.clickEventBindingByNode(buttonTenDraw, function()
                    GameAudio.playUISound("select1")
                    isTenChou = true
                    charCashNum =  theEggType>1 and CharInfo.getMCash() or CharInfo.getGCash()
                    -- charCashNum = CharInfo.getGCash()
                    if  charCashNum>= consumeElementInfo2.num then
                        CSResourceMgr.setButtonEnabledByNode(TenChou, false)
                        NetInterface.sendWithBlock("GC_CapsuleEgg_Ack", function()
                            local PetSend = require("src.Net.Send.PetSend")
                            PetSend.sendCG_CapsuleEgg_Req({optType=theEggType ,choice = 2 ,bFree = 0,choiceEx = 0})
                            end,function()
                                    CSResourceMgr.setButtonEnabledByNode(TenChou, true)
                                    if theEggType == eggType.mMachine and openHopeForce then
                                        NetInterface.sendWithBlock("GC_CapsuleEggAllInfoCmd_Ack", function()
                                        local PetSend = require("src.Net.Send.PetSend")
                                        PetSend.sendCG_CapsuleEggAllInfoCmd_Req()
                                        end)
                                    end
                                    -- if theEggType == eggType.vMachine and openHopeForce2 then
                                    --     NetInterface.sendWithBlock("GC_CapsuleEggAllInfoCmd_Ack", function()
                                    --     local PetSend = require("src.Net.Send.PetSend")
                                    --     PetSend.sendCG_CapsuleEggAllInfoCmd_Req()
                                    --     end)
                                    -- end
                                end,function(code)
                                    machineDrawFailed(page, TenChou, code)
                                end,nil,false,function()
                                    machineDrawFailed(page, TenChou)
                                end)
                    else
                        DialogBoxMgr.showSmallDialogBox(scene, 1, unEnoughLabel)
                    end
            end)

        CSResourceMgr.getNodeByName(resName,"diban"):setVisible(false)

    end
    local function playCSB()
        CSResourceMgr.getCsbObj(resNameA):setVisible(true)
        local node = CSResourceMgr.getNodeByName(resNameA,"diban")
        CocosModuleMgr.showUIAnimation(node,"up")
    end

    local funcTable = {loadCSB, playCSB}

    UnblockLoader.load(funcTable, "GachaViewMgrA")
end

function GachaViewMgr.setOneDrawAward(awardVec)
    UIStack.push("GachaViewMgr.setOneDrawAward",function()
        UIStack.pop("GachaViewMgr.setOneDrawAward")
        if awardVec.elementType == "pet" then
            petWiki[awardVec.elementID] = awardVec.elementID
        end
        oneDrawCostLabelG2 = nil
        oneDrawCostLabelM2 = nil
        UnblockLoader.cancel("GachaViewMgrB")
        CSResourceMgr.removeCSObjectByTag(resNameB)
        GachaViewMgr.setVisible(true)
        --屏蔽心愿梦想
        -- if theEggType == eggType.mMachine then
        --     if hopeValue >= hopeValueMax then
        --         GachaViewMgr.setHopeForce(3)
        --     elseif dreamValue >= dreamValueMax then
        --         GachaViewMgr.setHopeForce(4)
        --     end
        -- end
    end,false)
    GachaViewMgr.setVisible(false)
    local isNewPet = false
    
    local function loadCSB()
        local page = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameB)
        page:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resNameB)
        CSResourceMgr.setRelativePosition(resNameB, 320, 480)

        CSResourceMgr.clickEventBinding(resNameB, "Button_Confirm", function()
            UIStack.pop("GachaViewMgr.setOneDrawAward")
            if awardVec.elementType == "pet" then
                petWiki[awardVec.elementID] = awardVec.elementID
            end
            GameAudio.playUISound("retract")
            oneDrawCostLabelG2 = nil
            oneDrawCostLabelM2 = nil
            UnblockLoader.cancel("GachaViewMgrB")
            CSResourceMgr.removeCSObjectByTag(resNameB)
            GachaViewMgr.setVisible(true)
            --屏蔽心愿梦想
            -- if theEggType == eggType.mMachine then
            --     if hopeValue >= hopeValueMax then
            --         GachaViewMgr.setHopeForce(3)
            --     elseif dreamValue >= dreamValueMax then
            --         GachaViewMgr.setHopeForce(4)
            --     end
            -- end
        end)
        CSResourceMgr.clickEventBinding(resNameB, "bg", function()
            --todo
        end)
        local capsuleEggInfo = PokemonInfo.getCapsuleEggInfoByID(theEggType)
        local consumeElementInfo = ItemInfo.getConsumeElementInfoById(capsuleEggInfo.OneEggCons)
        local moneyLabel = CSResourceMgr.getNodeByName(resNameB, "moneyNum")
        CSResourceMgr.setLabelColorByNode(moneyLabel, {r=255,g=255,b=255,a=255})
        local costNum = 0
        local unEnoughLabel = ""
        if theEggType == eggType.gMachine then
            unEnoughLabel = "egg25"
            oneDrawCostLabelG2 = moneyLabel
            local time = capsuleEggInfo.CD+lastTime1-CharInfo.getServerTime()
            costNum = time>0 and consumeElementInfo.num or "egg29"
        elseif theEggType == eggType.mMachine then
            unEnoughLabel = "egg27"
            oneDrawCostLabelM2 = moneyLabel
            local time = capsuleEggInfo.CD+lastTime2-CharInfo.getServerTime()
            costNum = time>0 and consumeElementInfo.num or "egg29"
        else
            unEnoughLabel = "egg27"
            costNum = consumeElementInfo.num
        end
        CSResourceMgr.setLabelStringByNode(moneyLabel, costNum,{r=0,g=0,b=0,a=255})

        CSResourceMgr.clickEventBinding(resNameB, "Button_Again", function()
            GameAudio.playUISound("select1")
            local machine = CSResourceMgr.getCsbObj(resNameA)
            local charCashNum = theEggType > 1 and CharInfo.getMCash() or CharInfo.getGCash()
            local bfree = 0
            if theEggType == eggType.gMachine then
                bfree = isEggGFree
            elseif theEggType == eggType.mMachine then
                bfree = isEggMFree
            end
            if charCashNum>= consumeElementInfo.num or bfree==1 then
                NetInterface.sendWithBlock("GC_CapsuleEgg_Ack", function()
                    local PetSend = require("src.Net.Send.PetSend")
                    PetSend.sendCG_CapsuleEgg_Req({optType=theEggType ,choice = 1 ,bFree = bfree,choiceEx = 0})
                    UIStack.pop("GachaViewMgr.setOneDrawAward")
                    if awardVec.elementType == "pet" then
                        petWiki[awardVec.elementID] = awardVec.elementID
                    end
                    oneDrawCostLabelG2 = nil
                    oneDrawCostLabelM2 = nil
                    UnblockLoader.cancel("GachaViewMgrB")
                    CSResourceMgr.removeCSObjectByTag(resNameB)
                end,function()
                    if theEggType == eggType.mMachine and openHopeForce then
                        NetInterface.sendWithBlock("GC_CapsuleEggAllInfoCmd_Ack", function()
                        local PetSend = require("src.Net.Send.PetSend")
                        PetSend.sendCG_CapsuleEggAllInfoCmd_Req()
                        end)
                    end
                    -- if theEggType == eggType.vMachine and openHopeForce2 then
                    --     NetInterface.sendWithBlock("GC_CapsuleEggAllInfoCmd_Ack", function()
                    --     local PetSend = require("src.Net.Send.PetSend")
                    --     PetSend.sendCG_CapsuleEggAllInfoCmd_Req()
                    --     end)
                    -- end
                    NetInterface.sendWithBlock("GC_CapsuleEggCDs_Ack", function()
                    local PetSend = require("src.Net.Send.PetSend")
                    PetSend.sendCG_CapsuleEggCDs_Req()
                    end,function()
                        -- GachaViewMgr.refreshServerTime()
                    end)
                end,function(code)
                    resultDrawFailed(machine, code)
                end,nil,false,function()
                    resultDrawFailed(machine)
                end)
            else
                DialogBoxMgr.showSmallDialogBox(scene, 1, unEnoughLabel)
            end
        end)

        local cashIconPath = theEggType>1 and "Player/MissionIcon/lanzuan_32.png" or "UI/CommonFiles/gbi_32.png"
        -- local cashIconPath = "UI/CommonFiles/gbi_32.png"
        local moneyIcon = CSResourceMgr.getNodeByName(resNameB,"moneyIcon")
        CSResourceMgr.setSpriteTextureByNode(moneyIcon, cashIconPath)
        local title = CSResourceMgr.getNodeByName(resNameB, "title")
        CSResourceMgr.setLabelColorByNode(title, {r=254,g=215,b=34,a=255})
        CSResourceMgr.setLabelStringByNode(title, "egg37",{r=113,g=66,b=32,a=255})
        local confirmLabel = CSResourceMgr.getNodeByName(resNameB, "Text_Confirm")
        CSResourceMgr.setLabelColorByNode(confirmLabel, {r=227,g=233,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(confirmLabel, "egg20",{r=0,g=0,b=0,a=255})
        local againLabel = CSResourceMgr.getNodeByName(resNameB, "Text_Again")
        CSResourceMgr.setLabelColorByNode(againLabel, {r=227,g=233,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(againLabel, "egg21",{r=0,g=0,b=0,a=255})
        local getTitle = CSResourceMgr.getNodeByName(resNameB, "getTitle")
        CSResourceMgr.setLabelColorByNode(getTitle, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(getTitle, "egg19",{r=0,g=0,b=0,a=255},nil,250)

        local parent = CSResourceMgr.getNodeByName(resNameB,"getItem_Copy")
        local effAni = AnimationMgr.createAni(parent, "Spine/effects/Ui_chongwulingqujiemian.png", 
            parent:getContentSize().width/2, parent:getContentSize().height/2,"getAward")
        effAni:setLocalZOrder(-2)
        effAni:setScale(0.5)
        AnimationMgr.playAni(effAni.res, "animation", true, "getAward")
        local function setAward(parent,oneAwardVec)
            local itemBack = CSResourceMgr.seekNodeByName(parent, "item")
            itemBack:setVisible(true)
            local awardIconPath = ""
            local awardIconPathTable = {"UI/CommonFiles/icon_jinbi.png","UI/CommonFiles/ico_lanzuan.png"}
            local itemIcon = CSResourceMgr.seekNodeByName(parent, "itemIcon")
            if oneAwardVec.elementType == "g_cash" then
                awardIconPath = awardIconPathTable[1]
                oneAwardVec.elementID = 9998
            elseif oneAwardVec.elementType == "m_cash" then
                awardIconPath = awardIconPathTable[2]
                oneAwardVec.elementID = 9999
            else
                local itemType = ItemInfo.getItemType(oneAwardVec.elementID)
                local btnRes = ItemInfo.getItemRareBGImage(oneAwardVec.elementID)
                if itemType==4 then
                    local petPieceInfo = ItemInfo.getPetPieceInfoById(oneAwardVec.elementID)
                    local pokemonInfo = PokemonInfo.getPokemonInfoByID(PokemonInfo.getGeneInfoByID(petPieceInfo.pokeID).petID)
                    awardIconPath =  "Pet/PetIcon/"..pokemonInfo.icon..".png"
                    CSResourceMgr.seekNodeByName(parent, "mask"):setVisible(true)
                    itemIcon:setScale(0.9,0.9)
                else
                    local itemInfo = ItemInfo.getItemInfoById(oneAwardVec.elementID)
                    awardIconPath =itemInfo.icon
                end
                CSResourceMgr.setButtonTextureByNode(itemBack, btnRes,btnRes,btnRes)
            end
            CSResourceMgr.setSpriteTextureByNode(itemIcon, awardIconPath)
            local itemNum = CSResourceMgr.seekNodeByName(parent, "itemNum")
            CSResourceMgr.setLabelColorByNode(itemNum, {r=255,g=255,b=255,a=255})
            CSResourceMgr.setLabelStringByNode(itemNum, oneAwardVec.num,{r=0,g=0,b=0,a=255},1,80)
            CSResourceMgr.clickEventBindingByNode(itemBack, function()
                ItemInfoViewMgr.show({id = oneAwardVec.elementID, sum = oneAwardVec.num, type = 1}, false)
            end, 3)
            parent:setScale(0)
        end

        local function setPet(parent,oneAwardVec)
            local pokemonInfo = PokemonInfo.getPokemonInfoByID(oneAwardVec.elementID)
            local petBack = CSResourceMgr.seekNodeByName(parent, "pet")
            CSResourceMgr.setButtonTextureByNode(petBack,"Pet/BasicPetList_2/Stage/"..pokemonInfo.rarePoint..".png","Pet/BasicPetList_2/Stage/"..pokemonInfo.rarePoint..".png","Pet/BasicPetList_2/Stage/"..pokemonInfo.rarePoint..".png")
            petBack:setVisible(true)
            local monsterIcon = CSResourceMgr.seekNodeByName(parent,"petIcon")
            CSResourceMgr.setSpriteTextureByNode(monsterIcon, "Pet/PetIcon/"..pokemonInfo.icon..".png")
            local monsterAttr = CSResourceMgr.seekNodeByName(parent,"attributeIcon")
            CSResourceMgr.setSpriteTextureByNode(monsterAttr, "Pet/AttriIcon/"..pokemonInfo.elementAtt1..".png")
            local monsterAttrBack = CSResourceMgr.seekNodeByName(parent,"attributeIconBack")
            CSResourceMgr.setSpriteTextureByNode(monsterAttrBack, "Pet/AttriIcon/small_"..pokemonInfo.elementAtt1..".png")
            local monsterLevel = CSResourceMgr.seekNodeByName(parent,"petLevel")
            CSResourceMgr.setSpriteTextureByNode(monsterLevel, "Pet/Education/"..levelPath[pokemonInfo.rarePoint]..".png")
            CSResourceMgr.clickEventBindingByNode(petBack, function()
                PetInfoViewMgr.show(SceneMgr.getRunningScene, oneAwardVec.elementID)
            end, 3)
            parent:setScale(0)
            local cjson = require("cjson")
            if not GachaViewMgr.isHavePet(oneAwardVec.elementID,cjson.decode(oneAwardVec.detail)) then
                isNewPet = true
            end
        end

        -- Local draw results come from ACK 1561. The bundled result
        -- template also advertises fixed EXP and wish-coin bonuses.
        CSResourceMgr.getNodeByName(resNameB, "getItemMain"):setVisible(false)
        CSResourceMgr.getNodeByName(resNameB, "getItemMain2"):setVisible(false)

        if isHopeForce or isDreamForce--[[or isHopeForce2]] then
            local againBtn = CSResourceMgr.getNodeByName(resNameB,"Button_Again")
            againBtn:setVisible(false)
            local confirmBtn = CSResourceMgr.getNodeByName(resNameB,"Button_Confirm")
            confirmBtn:setPositionX(295)
            isHopeForce = false
            isDreamForce = false
            -- isHopeForce2 = false
        end

        if awardVec.elementType == "pet" then
            setPet(parent,awardVec)
        else
            setAward(parent,awardVec)
        end
    end

    local function playCSB()
        CSResourceMgr.playActionWithCallback(resNameB, 0, 5, 1, function()
            local parent = CSResourceMgr.getNodeByName(resNameB,"getItem_Copy")
            -- local ball = CSResourceMgr.getNodeByName(resNameB,"ball")
            -- transition.moveTo(ball,{x = ball:getPositionX(), y = ball:getPositionY()-600, time = 0.5})
            -- parent:performWithDelay(function()
                -- transition.scaleTo(ball, {scale = 0, time = 0.2})
                -- transition.rotateTo(ball, {rotate = 180, time = 0.2})
                if isNewPet then
                    parent:performWithDelay(function()
                        local cjson = require("cjson")
                        local petInfo = cjson.decode(awardVec.detail)
                        GachaViewMgr.playGetAPet(awardVec.elementID,petInfo)
                    end,0.1)
                end
                parent:performWithDelay(function()
                    GameAudio.playUISound("tenRaffleBreak")
                    transition.scaleTo(parent, {scale=1, time=0.2})
                    end,0.1)
                -- end,0.2)
            -- parent:performWithDelay(function()
            --     ball:setVisible(false)
            --     end,0.6)
        end,"")
    end

    local funcTable = {loadCSB, playCSB}

    GachaViewMgr.addGachaAni(function()
        UnblockLoader.load(funcTable, "GachaViewMgrB")
    end)
end

function GachaViewMgr.playGetAPet(petID,petInfo,closeCallback,skinID,isActivity)
    if stopGachaAnim then
        return
    end
    local petWikiNew = PetHandBook.getPetWikiInfoLst()
    if curSound then
        audio.stopSound(curSound)
        curSound = nil
    end
    GameAudio.playUISound("petGet")
    local animationTable = {}

    local scene = SceneMgr.getRunningScene
    local page = CSResourceMgr.createRes(scene, resNameE)
    page:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
    CSResourceMgr.setRelativePosition(resNameE, 320,480)

    --...
    local diff = CocosModuleMgr.getScreenSizeDiff()
    local diban = CSResourceMgr.getNodeByName(resNameE, "di")
    local dbsize = diban:getContentSize()
    diban:setContentSize(dbsize.width, dbsize.height+diff)
    local diban2 = CSResourceMgr.getNodeByName(resNameE, "di2")
    local db2size = diban2:getContentSize()
    diban2:setContentSize(db2size.width, db2size.height+diff)
    local share = CSResourceMgr.getNodeByName(resNameE, "share")
    local sposy = share:getPositionY()
    share:setPositionY(sposy+diff/2)  
    local achieveBack1 = CSResourceMgr.getNodeByName(resNameE, "achieveBack1")
    local a2posy = achieveBack1:getPositionY()
    achieveBack1:setPositionY(a2posy+diff/2) 
    local achieveBack2 = CSResourceMgr.getNodeByName(resNameE, "achieveBack2")
    local a2posy = achieveBack2:getPositionY()
    achieveBack2:setPositionY(a2posy+diff/2) 
    local Panel = CSResourceMgr.getNodeByName(resNameE, "Panel")
    local pposy = Panel:getPositionY()
    Panel:setPositionY(pposy+diff/2) 
    local achieveLabel2 = CSResourceMgr.getNodeByName(resNameE,"achieveLabel2")
    CSResourceMgr.setLabelColorByNode(achieveLabel2, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(achieveLabel2, "egg38", {r=128,g=75,b=23,a=255})
    local achieveLabel1 = CSResourceMgr.getNodeByName(resNameE,"achieveLabel1")
    CSResourceMgr.setLabelColorByNode(achieveLabel1, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(achieveLabel1, "egg39", {r=128,g=75,b=23,a=255})
    local bookIcon = CSResourceMgr.seekNodeByName(achieveBack2,"icon")
    bookIcon:setScale(0)
    if GachaViewMgr.isHavePet(petID,petInfo) then
        achieveBack2:setVisible(false)
    else
        petWikiNew[petID] = petID
        PetHandBook.SetPetWikiInfo(petWikiNew)
        achieveBack2:performWithDelay(function()
            transition.moveTo(achieveBack2, {x = 250,  time = 0.2})
            achieveBack2:performWithDelay(function()
                transition.moveTo(achieveBack2, {x = 320,  time = 0.2})
                achieveBack2:performWithDelay(function()
                    local size = achieveBack2:getContentSize()
                    CSResourceMgr.createCCBI(achieveBack2, "texture/ui_dc_15a.ccbi", size.width/2, size.height/2)
                    CSResourceMgr.createCCBI(achieveBack2, "texture/ui_dc_15b.ccbi", size.width/2, size.height/2)
                end,0.2)
            end,0.2) 
        end,0.2) 
        achieveBack2:performWithDelay(function()
            transition.scaleTo(bookIcon, {scale = 1.5, time = 0.3})
            achieveBack2:performWithDelay(function()
                transition.scaleTo(bookIcon, {scale = 1, time = 0.2})
            end,0.3)
        end,0.4) 
    end
    local pokemonAchievementInfo = AchievementListMgr.isThisPetAchieveOK(petID)
    if pokemonAchievementInfo then
        StatusBarMgr.addRedPoint(3)
        local parent = CSResourceMgr.getNodeByName(resNameE,"Panel")
        parent:setVisible(true)
        achieveBack1:setVisible(true)

        transition.moveTo(achieveBack1, {x = 250,  time = 0.2})
        achieveBack1:performWithDelay(function()
            transition.moveTo(achieveBack1, {x = 320,  time = 0.2})
            achieveBack1:performWithDelay(function()
                local size = achieveBack1:getContentSize()
                CSResourceMgr.createCCBI(achieveLabel1, "texture/ui_dc_15a.ccbi", size.width/2, size.height/2)
            end,0.2)
        end,0.2) 

        parent:performWithDelay(function()
            transition.moveTo(parent, {x = 110,  time = 0.2})
            parent:performWithDelay(function()
                transition.moveTo(parent, {x = 180,  time = 0.2})
            end,0.2)
        end,0.1) 
        local biaoti = CSResourceMgr.seekNodeByName(parent,"biaoti")
        CSResourceMgr.setLabelColorByNode(biaoti, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(biaoti, pokemonAchievementInfo.name, {r=0,g=0,b=0,a=255,w=1,s=1})
        local jiangliwenzi = CSResourceMgr.seekNodeByName(parent,"jiangliwenzi")  
        CSResourceMgr.setLabelColorByNode(jiangliwenzi, {r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(jiangliwenzi, "achieveList2",{r=0,g=0,b=0,a=255})
        for k,v in pairs(pokemonAchievementInfo.petIDs) do
            local pokemonInfo = PokemonInfo.getPokemonInfoByID(v)
            local pet = CSResourceMgr.seekNodeByName(parent, "pet"..k)
            pet:setVisible(true)
            local petIcon = CSResourceMgr.seekNodeByName(pet, "petIcon")
            CSResourceMgr.setSpriteTextureByNode(petIcon, "Pet/PetIcon/"..pokemonInfo.icon..".png")
            petIcon:setScale(0.9,0.9)
            pet:loadTexture("Pet/BasicPetList_2/Stage/"..pokemonInfo.rarePoint..".png")
            CSResourceMgr.seekNodeByName(pet,"rare"):loadTexture(orderString[pokemonInfo.rarePoint])
            local icon1 = "UI/CommonFiles/"..pokemonInfo.elementAtt1..".png"
            CSResourceMgr.seekNodeByName(pet,"attr"):loadTexture(icon1)
            local name = CSResourceMgr.seekNodeByName(pet, "name")
            CSResourceMgr.setLabelColorByNode(name, PokemonInfo.COLOR[pokemonInfo.rarePoint])
            CSResourceMgr.setLabelStringByNode(name, pokemonInfo.name) 
            local petBtn = CSResourceMgr.seekNodeByName(parent,  "pet"..k.."Btn")
            CSResourceMgr.clickEventBindingByNode(petBtn, function()
                PetInfoViewMgr.show(SceneMgr.getRunningScene, v)
                end,3)
        end  
        local jiangli1Num = CSResourceMgr.seekNodeByName(parent,"jiangli1Num") 
        local jiangli2Num = CSResourceMgr.seekNodeByName(parent,"jiangli2Num")   
        CSResourceMgr.setLabelColorByNode(jiangli1Num, {r=255,g=252,b=0,a=255})
        CSResourceMgr.setLabelStringByNode(jiangli1Num, "x"..pokemonAchievementInfo.point, {r=0,g=0,b=0,a=255,w=1,s=1})
        CSResourceMgr.setLabelColorByNode(jiangli2Num, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(jiangli2Num, "x"..pokemonAchievementInfo.mcash, {r=0,g=0,b=0,a=255,w=1,s=1}) 
    end

    share:setVisible(false)
    CSResourceMgr.clickEventBindingByNode(share, function()
        local textTable = {textType = "pet",petInfo = petInfo}
        local cjson = require("cjson")
        local str = json.encode(textTable)
        NetInterface.sendWithBlock("GC_Chat_Ack", function()
            local ChatSend = require("src.Net.Send.ChatSend")
            ChatSend.sendCG_Chat_Req({charID = "",channel = "world",concent =str})
            end,function()
                TipsMgr.show(scene, "egg33")
                TownChatMgr.changeStatus(1)
            end)
    end,3)

    local pokemonInfo = PokemonInfo.getPokemonInfoByID(petID)
    local nameBack = CSResourceMgr.getNodeByName(resNameE, "nameBack")
    nameBack:setScaleX(0)
    local name = CSResourceMgr.getNodeByName(resNameE, "petName")
    CSResourceMgr.setLabelColorByNode(name, PokemonInfo.COLOR[pokemonInfo.rarePoint])
    CSResourceMgr.setLabelStringByNode(name, pokemonInfo.name, {r=62,g=46,b=6,a=255})
    name:setVisible(false)
    local rareIcon = CSResourceMgr.getNodeByName(resNameE, "rareIcon")
    rareIcon:setScale(0)

    --宠物动画
    local res = PokemonInfo.getPokemonResByID(petID)
    local petIcon = AnimationMgr.createAni(diban2, res, diban2:getContentSize().width/2, diban2:getContentSize().height/2)
    AnimationMgr.playAni(petIcon.res, "idle", true, petIcon.tag)
    if skinID then
        AnimationMgr.setSkin(petIcon.res, skinID, petIcon.tag)
    else
        AnimationMgr.setSkin(petIcon.res, petInfo and petInfo.skin or 0, petIcon.tag)
    end

    local attriIcon = CSResourceMgr.getNodeByName(resNameE, "attriIcon")
    CSResourceMgr.setSpriteTextureByNode(attriIcon, "Pet/AttriIcon/"..pokemonInfo.elementAtt1..".png")
    local attriBack = CSResourceMgr.getNodeByName(resNameE, "0")
    CSResourceMgr.setSpriteTextureByNode(attriBack, "Pet/AttriIcon/small_"..pokemonInfo.elementAtt1..".png")
    local rareIcon = CSResourceMgr.getNodeByName(resNameE, "rareIcon")
    CSResourceMgr.setSpriteTextureByNode(rareIcon, "Pet/Education/"..levelPath[pokemonInfo.rarePoint]..".png")
    --动画
    local function playAnim()
        local effAni = AnimationMgr.createAni(petIcon, "Spine/effects/Ui_chongwulingqujiemian.png", 
            petIcon:getContentSize().width/2, petIcon:getContentSize().height/2+100)
        effAni:setLocalZOrder(-2)
        effAni:setScale(1)
        AnimationMgr.playAni(effAni.res, "animation", true, effAni.tag)
        local particle = CSResourceMgr.createParticle(petIcon, "Spine/effects/huodechongwu_1_1.plist",
            petIcon:getContentSize().width/2, petIcon:getContentSize().height/2+100)
        particle:setLocalZOrder(-1)
    end

    table.insert(animationTable,function()
        petIcon:setScaleX(0)
        transition.scaleTo(petIcon, {scale = 2.5, time = 0.2})
        petIcon:performWithDelay(function()
            transition.scaleTo(petIcon, {scale = 1.2, time = 0.1})
            petIcon:performWithDelay(function()
                playAnim()
                transition.scaleTo(nameBack, {scaleX = 1, time = 0.1})
                petIcon:performWithDelay(function()
                    local posY = name:getPositionY()
                    name:setPositionY(posY+200)
                    name:setVisible(true)
                    posY = name:getPositionY()
                    transition.moveTo(name, {y = posY-200,  time = 0.1})
                    local particle = CSResourceMgr.createParticle(petIcon, "Spine/effects/huodechongwu_1_2.plist",
                        petIcon:getContentSize().width/2, petIcon:getContentSize().height/2)
                    particle:setLocalZOrder(1)
                    local info = CSResourceMgr.getNodeByName(resNameE, "0")
                    local raraBase = CSResourceMgr.getNodeByName(resNameE, "raraBase")
                    local posX = info:getPositionX()
                    local posX2 = raraBase:getPositionX()
                    info:performWithDelay(function()
                        transition.moveTo(info, {x = posX+50, time = 0.1})
                        transition.fadeIn(info, {time=0.1})
                        transition.moveTo(raraBase, {x = posX2+50, time = 0.1})
                        transition.fadeIn(raraBase, {time=0.1})
                    end,0.1)
                    info:performWithDelay(function()
                        posX = info:getPositionX()
                        posX2 = raraBase:getPositionX()
                        transition.moveTo(raraBase, {x = posX2-50, time = 0.1})
                        transition.moveTo(info, {x = posX-50, time = 0.1})
                        transition.scaleTo(rareIcon, {scale = 2.5, time = 0.1})
                        info:performWithDelay(function()
                            transition.scaleTo(rareIcon, {scale = 1, time = 0.1})
                        end,0.1)
                    end,0.2)
                end,0.1)
            end,0.1)
        end,0.2)
    end)

    local attriTable = {"lifeRateValue","atkRateValue","defRateValue","satkRateValue","sdefRateValue","speedRateValue"}
    local attriNameTable = {"GachaPetAttri1","GachaPetAttri2","GachaPetAttri3","GachaPetAttri4","GachaPetAttri5","GachaPetAttri6"}
    for i=1,6 do
        local info = CSResourceMgr.getNodeByName(resNameE, tostring(i))
        local value = CSResourceMgr.seekNodeByName(info,"Num_Copy")
        CSResourceMgr.setLabelColorByNode(value, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(value, pokemonInfo[attriTable[i]], {r=1,g=42,b=72,a=255})
        local label = CSResourceMgr.seekNodeByName(info,"label_Copy")
        CSResourceMgr.setLabelColorByNode(label, {r=151,g=190,b=220,a=255})
        CSResourceMgr.setLabelStringByNode(label, attriNameTable[i], {r=21,g=33,b=42,a=255})
        info:setOpacity(0)
        table.insert(animationTable,function()
            local posX = info:getPositionX()
            info:performWithDelay(function()
                transition.moveTo(info, {x = posX+50, time = 0.1})
                transition.fadeIn(info, {time=0.1})
            end,0.1*i+0.7)
            info:performWithDelay(function()
                posX = info:getPositionX()
                transition.moveTo(info, {x = posX-50, time = 0.1})
            end,0.1*i+0.8)
        end)
        if petInfo then
            local attrType, attrValue = PetEducationMgr.getDiversificationAttrs(petInfo)
            if attrType ~= 0 and i == attrType then
                CSResourceMgr.seekNodeByName(info,"arrow_Copy"):setVisible(true)
                local addValue_Copy =  CSResourceMgr.seekNodeByName(info,"addValue_Copy")
                CSResourceMgr.setLabelColorByNode(addValue_Copy, {r=1,g=254,b=3,a=255})
                CSResourceMgr.setLabelStringByNode(addValue_Copy, "+"..math.ceil(pokemonInfo[attriTable[i]]*attrValue/100), {r=0,g=0,b=0,a=255,w=1,s=1})
            end
        end
    end
    UnblockLoader.load(animationTable, "GachaViewMgr.playGetAPet")

    CSResourceMgr.clickEventBinding(resNameE, "ButtonScreen", function()
        PetHandBook.SetPetWikiInfo(petWikiNew)
        UnblockLoader.cancel("GachaViewMgr.playGetAPet")
        CSResourceMgr.removeParticle("Spine/effects/huodechongwu_1_1.plist")
        CSResourceMgr.removeParticle("Spine/effects/huodechongwu_1_2.plist")
        CSResourceMgr.removeCSObjectByTag(resNameE)
        if isTenChou and pausePoint<=10 then
            GachaViewMgr.playSetAward(pausePoint)
        end
        if isActivity then
            ActivityCapsuleEggView.playSetAward(ActivityCapsuleEggView.getPausePoint())
            HalloweenCapsuleEggView.playSetAward(HalloweenCapsuleEggView.getPausePoint())
        end
        if closeCallback then
            closeCallback()
        end
    end)
end

function GachaViewMgr.setTenDrawAward(awardsVec)
    UIStack.push("GachaViewMgr.setTenDrawAward",function()
        UIStack.pop("GachaViewMgr.setTenDrawAward")
        for k,v in pairs(awardsVec) do
            if v.elementType == "pet" then
                petWiki[v.elementID] = v.elementID
            end
        end
        UnblockLoader.cancel("GachaViewMgrC")
        CSResourceMgr.removeCSObjectByTag(resNameC)
        GachaViewMgr.setVisible(true)
        stopGachaAnim = false
        --屏蔽心愿梦想
        -- if theEggType == eggType.mMachine then
        --     if hopeValue >= hopeValueMax then
        --         GachaViewMgr.setHopeForce(3)
        --     elseif dreamValue >= dreamValueMax then
        --         GachaViewMgr.setHopeForce(4)
        --     end
        -- end
    end,false)
    GachaViewMgr.setVisible(false)
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

        CSResourceMgr.clickEventBinding(resNameC, "Button_Confirm", function()
            UIStack.pop("GachaViewMgr.setTenDrawAward")
            for k,v in pairs(awardsVec) do
                if v.elementType == "pet" then
                    petWiki[v.elementID] = v.elementID
                end
            end
            GameAudio.playUISound("retract")
            UnblockLoader.cancel("GachaViewMgrC")
            CSResourceMgr.removeCSObjectByTag(resNameC)
            GachaViewMgr.setVisible(true)
            stopGachaAnim = false
            --屏蔽心愿梦想
            -- if theEggType == eggType.mMachine then
            --     if hopeValue >= hopeValueMax then
            --         GachaViewMgr.setHopeForce(3)
            --     elseif dreamValue >= dreamValueMax then
            --         GachaViewMgr.setHopeForce(4)
            --     end
            -- end
        end)
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
        local capsuleEggInfo = PokemonInfo.getCapsuleEggInfoByID(theEggType)
        local consumeElementInfo = ItemInfo.getConsumeElementInfoById(capsuleEggInfo.tenEggCons)

        local unEnoughLabel = ""
        if theEggType == eggType.gMachine then
            unEnoughLabel = "egg25"
        elseif theEggType == eggType.mMachine then
            unEnoughLabel = "egg27"
        else
            unEnoughLabel = "egg27"
        end

        CSResourceMgr.clickEventBinding(resNameC, "Button_Again", function()
            GameAudio.playUISound("select1")
            local machine = CSResourceMgr.getCsbObj(resNameA)
            local charCashNum = theEggType > 1 and CharInfo.getMCash() or CharInfo.getGCash()
            stopGachaAnim = false
            if  charCashNum>= consumeElementInfo.num then
                NetInterface.sendWithBlock("GC_CapsuleEgg_Ack", function()
                    local PetSend = require("src.Net.Send.PetSend")
                    PetSend.sendCG_CapsuleEgg_Req({optType=theEggType ,choice = 2 ,bFree = 0,choiceEx = 0})
                    UIStack.pop("GachaViewMgr.setTenDrawAward")
                    for k,v in pairs(awardsVec) do
                        if v.elementType == "pet" then
                            petWiki[v.elementID] = v.elementID
                        end
                    end
                    UnblockLoader.cancel("GachaViewMgrC")
                    CSResourceMgr.removeCSObjectByTag(resNameC)
                end,function()
                    if theEggType == eggType.mMachine and openHopeForce then
                        NetInterface.sendWithBlock("GC_CapsuleEggAllInfoCmd_Ack", function()
                        local PetSend = require("src.Net.Send.PetSend")
                        PetSend.sendCG_CapsuleEggAllInfoCmd_Req()
                        end)
                    end
                    -- if theEggType == eggType.vMachine and openHopeForce2 then
                    --     NetInterface.sendWithBlock("GC_CapsuleEggAllInfoCmd_Ack", function()
                    --     local PetSend = require("src.Net.Send.PetSend")
                    --     PetSend.sendCG_CapsuleEggAllInfoCmd_Req()
                    --     end)
                    -- end
                end,function(code)
                    resultDrawFailed(machine, code)
                end,nil,false,function()
                    resultDrawFailed(machine)
                end)
            else
                DialogBoxMgr.showSmallDialogBox(scene, 1, unEnoughLabel)
            end
        end)

        local cashIconPath = theEggType>1 and "Player/MissionIcon/lanzuan_32.png" or "UI/CommonFiles/gbi_32.png"
        -- local cashIconPath = "UI/CommonFiles/gbi_32.png"
        local moneyIcon = CSResourceMgr.getNodeByName(resNameC,"moneyIcon")
        CSResourceMgr.setSpriteTextureByNode(moneyIcon, cashIconPath)
        local title = CSResourceMgr.getNodeByName(resNameC, "title")
        CSResourceMgr.setLabelColorByNode(title, {r=254,g=215,b=34,a=255})
        CSResourceMgr.setLabelStringByNode(title, "egg37",{r=113,g=66,b=32,a=255})
        local confirmLabel = CSResourceMgr.getNodeByName(resNameC, "Text_Confirm")
        CSResourceMgr.setLabelColorByNode(confirmLabel, {r=227,g=233,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(confirmLabel, "egg20",{r=0,g=0,b=0,a=255})
        local againLabel = CSResourceMgr.getNodeByName(resNameC, "Text_Again")
        CSResourceMgr.setLabelColorByNode(againLabel, {r=227,g=233,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(againLabel, "egg26",{r=0,g=0,b=0,a=255})
        local moneyLabel = CSResourceMgr.getNodeByName(resNameC, "moneyNum")
        CSResourceMgr.setLabelColorByNode(moneyLabel, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(moneyLabel, consumeElementInfo.num,{r=0,g=0,b=0,a=255})
        local serviceLabel = CSResourceMgr.getNodeByName(resNameC, "serviceLabel")
        CSResourceMgr.setLabelColorByNode(serviceLabel, {r=255,g=252,b=0,a=255})
        serviceLabel:setString("LOCAL PRIZE POOL")
        local getTitle = CSResourceMgr.getNodeByName(resNameC, "getTitle")
        CSResourceMgr.setLabelColorByNode(getTitle, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(getTitle, "egg19",{r=0,g=0,b=0,a=255},nil,250)

        --用来调整动画位置
        local i = 0
        if theEggType == eggType.mMachine then
            i = -1
        end
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

        CSResourceMgr.getNodeByName(resNameC, "getItemMain"):setVisible(false)
        CSResourceMgr.getNodeByName(resNameC, "getItemMain2"):setVisible(false)

        local m = 1
        for k,v in pairs(awardsVec) do
            local cjson = require("cjson")
            local parent = CSResourceMgr.getNodeByName(resNameC, "getItem_Copy_"..k)
            if v.elementType == "pet" and GachaViewMgr.isHavePet(v.elementID,cjson.decode(v.detail)) then
                setPet(parent,v)
            elseif v.elementType == "pet" and not GachaViewMgr.isHavePet(v.elementID,cjson.decode(v.detail)) then
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
            -- for i=1,10 do
            --     local ball = CSResourceMgr.getNodeByName(resNameC,"ball"..i)
            --     if i<=5 then
            --         transition.moveTo(ball,{x = ball:getPositionX(), y = ball:getPositionY()-600, time = 0.5})
            --     else
            --         transition.moveTo(ball,{x = ball:getPositionX(), y = ball:getPositionY()+600, time = 0.5})
            --     end
            -- end
            GachaViewMgr.playSetAward(1)
        end, "")
    end

    local funcTable = {loadCSB, playCSB}

    GachaViewMgr.addGachaAni(function()
        UnblockLoader.load(funcTable, "GachaViewMgrC")
    end)
end

function GachaViewMgr.addGachaAni(callback)
    if isHopeForce or isDreamForce then
        callback()
        return
    end
    if CSResourceMgr.getCsbObj(resNameA) then
        local diff = CocosModuleMgr.getScreenSizeDiff()
        if diff<0 then
            diff = 0
        end
        local aniBlock = CSResourceMgr.getNodeByName(resNameA,"aniBlock")
        aniBlock:setVisible(true)
        local diban = CSResourceMgr.getNodeByName(resNameA,"diban")
        local circle = CSResourceMgr.getNodeByName(resNameA,"circle")
        local getAni = AnimationMgr.createAni(diban, "Spine/effects/Ui_chongwuchoujiang.png", 
            circle:getPositionX()-15, circle:getPositionY()+15,"getAni")
        GameAudio.playUISound("gashapon")
        AnimationMgr.playAniWithCallback(getAni.res, "animation", function()
            aniBlock:setVisible(false)
            callback()
        end, "getAni", true)
    else
        callback()
    end
end

function GachaViewMgr.playSetAward(m)
    local deltaTime = m==1 and 0.1 or 0
    local diban = CSResourceMgr.getNodeByName(resNameC, "diban")
    diban:performWithDelay(function()
        local musicStr = m==10 and "tenRaffleBreak" or "tenRaffle"
        curSound = GameAudio.playUISound(musicStr)
    end,deltaTime)
    for i=m,10 do
        local parent = CSResourceMgr.getNodeByName(resNameC, "getItem_Copy_"..i)
        -- local ball = CSResourceMgr.getNodeByName(resNameC,"ball"..i)
        diban:performWithDelay(function()
            -- transition.scaleTo(ball, {scale = 0, time = 0.2})
            -- transition.rotateTo(ball, {rotate = 180, time = 0.2})
            if havePetTable[i] then
                diban:performWithDelay(function()
                    GachaViewMgr.playGetAPet(havePetTable[i],havePetInfoTable[i])
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
        -- diban:performWithDelay(function()
        --     ball:setVisible(false)
        -- end,0.4*(i-m+deltaTime))
        if havePetTable[i] then
            pausePoint = i+1
            break
        end
    end   
end

--type--3:心愿 4:梦想
function GachaViewMgr.setHopeForce(type)
    UIStack.push("GachaViewMgr.setHopeForce",function()
        UIStack.pop("GachaViewMgr.setHopeForce")
        UnblockLoader.cancel("GachaViewMgrD")
        CSResourceMgr.removeCSObjectByTag(resNameD)
        GameAudio.playUISound("back")
        GachaViewMgr.setVisible(true)
    end,false)
    GachaViewMgr.setVisible(false)
    GameAudio.playUISound("ok")
    local function loadCSB()
        local page = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameD)
        page:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        -- CSResourceMgr.setFullScreen(resNameD)
        CSResourceMgr.setRelativePosition(resNameD, 320, 480)
        -- CocosModuleMgr.setEdgeDistance(page, nil, nil, nil, 0)

        CSResourceMgr.clickEventBinding(resNameD, "close", function()
            UIStack.pop("GachaViewMgr.setHopeForce")
            UnblockLoader.cancel("GachaViewMgrD")
            CSResourceMgr.removeCSObjectByTag(resNameD)
            GameAudio.playUISound("back")
            GachaViewMgr.setVisible(true)
        end)
        CSResourceMgr.clickEventBinding(resNameD, "bg", function()
            -- UIStack.pop("GachaViewMgr.setHopeForce")
            -- UnblockLoader.cancel("GachaViewMgrD")
            -- CSResourceMgr.removeCSObjectByTag(resNameD)
            -- GameAudio.playUISound("back")
            -- GachaViewMgr.setVisible(true)
        end)
        local choiceEx = 0
        local isChoose = false

        local level1 = CSResourceMgr.getNodeByName(resNameD,"level1")
        if theEggType == eggType.mMachine then
            CSResourceMgr.setSpriteTextureByNode(level1, "Pet/Education/a.png")
        -- elseif theEggType == eggType.vMachine then
        --     CSResourceMgr.setSpriteTextureByNode(level1, "Pet/Education/s.png")
        end
        local level2 = CSResourceMgr.getNodeByName(resNameD,"level2")
        CSResourceMgr.setSpriteTextureByNode(level2, "Pet/Education/s.png")
        local desc = CSResourceMgr.getNodeByName(resNameD,"desc")
        CSResourceMgr.setLabelColorByNode(desc, {r=66,g=101,b=126,a=255})
        if theEggType == eggType.mMachine then
            CSResourceMgr.setLabelStringByNode(desc, "egg23")
        -- elseif theEggType == eggType.vMachine then
        --     CSResourceMgr.setLabelStringByNode(desc, "egg40")
        end
        local confirmLabel = CSResourceMgr.getNodeByName(resNameD,"Text_Confirm")
        CSResourceMgr.setLabelColorByNode(confirmLabel, {r=227,g=233,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(confirmLabel, "egg20",{r=0,g=0,b=0,a=255})
        local closeLabel = CSResourceMgr.getNodeByName(resNameD,"Text_close")
        CSResourceMgr.setLabelColorByNode(closeLabel, {r=227,g=233,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(closeLabel, "egg18",{r=0,g=0,b=0,a=255})

        if type == 3 then
            local title = CSResourceMgr.getNodeByName(resNameD, "title")
            CSResourceMgr.setLabelColorByNode(title, {r=144,g=238,b=255,a=255})
            CSResourceMgr.setLabelStringByNode(title, "egg45",{r=0,g=0,b=0,a=255,w=1})
            
            local tip = CSResourceMgr.getNodeByName(resNameD,{"db", "diban", "info1", "tip1"})
            local tipTxt = CSResourceMgr.seekNodeByName(tip, "txt")
            --CSResourceMgr.setLabelColorByNode(tipTxt, {r=66,g=101,b=126,a=255})
            CSResourceMgr.setLabelStringByNode(tipTxt, "x "..(PokemonInfo.getCapsuleEggInfoByID(eggType.mMachine).dreamValuePer + CharInfo.getVipInfoByID(CharInfo.getVIPLevel()).dreamCoinAdd), {r=0,g=0,b=0,a=255,w=2})
            
            tip = CSResourceMgr.getNodeByName(resNameD,{"db", "diban", "info1", "tip2"})
            tipTxt = CSResourceMgr.seekNodeByName(tip, "txt")
            --CSResourceMgr.setLabelColorByNode(tipTxt, {r=66,g=101,b=126,a=255})
            CSResourceMgr.setLabelStringByNode(tipTxt, "egg42", {r=0,g=0,b=0,a=255,w=1})
            
            local node = CSResourceMgr.getNodeByName(resNameD, {"db", "diban", "info1"})
            node:setVisible(true)
            local richLabelL = CocosModuleMgr.createRichLabel(node, "egg43", 32, "cuyuan_GBK.ttf", 600,LuaSqlite.LANG_TYPE == 3 and 100 or 180,380)
        elseif type == 4 then
            local title = CSResourceMgr.getNodeByName(resNameD, "title")
            CSResourceMgr.setLabelColorByNode(title, {r=255,g=232,b=79,a=255})
            CSResourceMgr.setLabelStringByNode(title, "egg46",{r=0,g=0,b=0,a=255,w=1})
            
            local node = CSResourceMgr.getNodeByName(resNameD, {"db", "diban", "info2"})
            node:setVisible(true)
            local richLabelL = CocosModuleMgr.createRichLabel(node, "egg44", 32, "cuyuan_GBK.ttf", 600,LuaSqlite.LANG_TYPE == 3 and 50 or 160,310)
        end

        local lastSelected = nil
        local function setMonster(parent,elementID,index)
            local pokemonInfo = PokemonInfo.getPokemonInfoByID(elementID)

            local monsterName = CSResourceMgr.seekNodeByName(parent, "name_Copy")
            CSResourceMgr.setLabelColorByNode(monsterName, {r=255,g=255,b=255,a=255})
            CSResourceMgr.setLabelStringByNode(monsterName, pokemonInfo.name,{r=0,g=0,b=0,a=255})
            local monsterIcon = CSResourceMgr.seekNodeByName(parent,"petIcon_Copy")
            CSResourceMgr.setSpriteTextureByNode(monsterIcon, "Pet/PetIcon/"..pokemonInfo.icon..".png")
            local monsterAttr = CSResourceMgr.seekNodeByName(parent,"attributeIcon_Copy")
            CSResourceMgr.setSpriteTextureByNode(monsterAttr, "Pet/AttriIcon/"..pokemonInfo.elementAtt1..".png")
            local monsterAttrBack = CSResourceMgr.seekNodeByName(parent,"attributeIconBack_Copy")
            CSResourceMgr.setSpriteTextureByNode(monsterAttrBack, "Pet/AttriIcon/small_"..pokemonInfo.elementAtt1..".png")
            local monsterLevel = CSResourceMgr.seekNodeByName(parent,"petLevel_Copy")
            CSResourceMgr.setSpriteTextureByNode(monsterLevel, "Pet/Education/"..levelPath[pokemonInfo.rarePoint]..".png")
            local petBack = CSResourceMgr.seekNodeByName(parent, "pet_Copy")
            CSResourceMgr.setSpriteTextureByNode(petBack, "Pet/BasicPetList_2/Stage/"..pokemonInfo.rarePoint..".png")

            local selectBtn = CSResourceMgr.seekNodeByName(parent, "Button_Select_Copy")
            CSResourceMgr.longtouchEventBindingByNode(selectBtn, function()
                PetInfoViewMgr.show(SceneMgr.getRunningScene, elementID)
            end,function()
                GameAudio.playUISound("select1")
                choiceEx = index
                isChoose = true
                local light = CSResourceMgr.seekNodeByName(parent, "light_Copy")
                light:setVisible(true)
                if lastSelected then
                    local lastParent = CSResourceMgr.getNodeByName(resNameD, "getItem_Copy_"..lastSelected)
                    local lastLight = CSResourceMgr.seekNodeByName(lastParent, "light_Copy")
                    if lastSelected~=index then
                        lastLight:setVisible(false)
                    end
                end
                lastSelected = index
            end)
        end

        -- local function setSkillBook(parent,elementID,index)
        --     local iteminfo = ItemInfo.getItemInfoById(elementID)

        --     local monsterName = CSResourceMgr.seekNodeByName(parent, "name_Copy")
        --     CSResourceMgr.setLabelColorByNode(monsterName, {r=255,g=255,b=255,a=255})
        --     CSResourceMgr.setLabelStringByNode(monsterName, iteminfo.name,{r=0,g=0,b=0,a=255})
        --     local monsterIcon = CSResourceMgr.seekNodeByName(parent,"petIcon_Copy")
        --     CSResourceMgr.setSpriteTextureByNode(monsterIcon, iteminfo.icon)
        --     local monsterAttr = CSResourceMgr.seekNodeByName(parent,"attributeIcon_Copy")
        --     monsterAttr:setVisible(false)
        --     local monsterAttrBack = CSResourceMgr.seekNodeByName(parent,"attributeIconBack_Copy")
        --     monsterAttrBack:setVisible(false)
        --     local monsterLevel = CSResourceMgr.seekNodeByName(parent,"petLevel_Copy")
        --     monsterLevel:setVisible(false)
        --     local petBack = CSResourceMgr.seekNodeByName(parent, "pet_Copy")
        --     CSResourceMgr.setSpriteTextureByNode(petBack, ItemInfo.getItemRareBGImage(elementID))

        --     local selectBtn = CSResourceMgr.seekNodeByName(parent, "Button_Select_Copy")
        --     CSResourceMgr.longtouchEventBindingByNode(selectBtn, function()
        --         ItemInfoViewMgr.show({id = elementID, sum = 1, type = 1}, false)
        --     end,function()
        --         GameAudio.playUISound("select1")
        --         choiceEx = index
        --         isChoose = true
        --         local light = CSResourceMgr.seekNodeByName(parent, "light_Copy")
        --         light:setVisible(true)
        --         if lastSelected then
        --             local lastParent = CSResourceMgr.getNodeByName(resNameD, "getItem_Copy_"..lastSelected)
        --             local lastLight = CSResourceMgr.seekNodeByName(lastParent, "light_Copy")
        --             if lastSelected~=index then
        --                 lastLight:setVisible(false)
        --             end
        --         end
        --         lastSelected = index
        --     end)
        -- end

        local monsters = {}
        if type == 3 then
            monsters = monsterTable
        else
            monsters = dreamMonsterTable
        end
        if theEggType == eggType.mMachine then
            for k,v in pairs(monsters) do
                if k<=5 then
                    local parent = CSResourceMgr.getNodeByName(resNameD, "getItem_Copy_"..k)
                    local itemInfo = ItemInfo.getAwardElementInfoById(v)
                    local elementID = itemInfo.elementID
                    parent:setVisible(true)
                    setMonster(parent,elementID,k)
                    --心愿选宠物居中
                    if type == 4 then
                        parent:setPositionX(82+122*k)
                    end
                end
            end
        -- elseif theEggType == eggType.vMachine then
        --     for k,v in pairs(monsterTable2) do
        --         local parent = CSResourceMgr.getNodeByName(resNameD, "getItem_Copy_"..k)
        --         local itemInfo = ItemInfo.getAwardElementInfoById(v)
        --         local elementID = itemInfo.elementID
        --         parent:setVisible(true)
        --         setSkillBook(parent,elementID,k)
        --     end
        end


        CSResourceMgr.clickEventBinding(resNameD, "Button_Confirm", function()
            GameAudio.playUISound("itemGet")
            if isChoose then
                isTenChou = false
                NetInterface.sendWithBlock("GC_CapsuleEgg_Ack", function()
                    local PetSend = require("src.Net.Send.PetSend")
                    PetSend.sendCG_CapsuleEgg_Req({optType=theEggType ,choice = type ,bFree = 0,choiceEx = choiceEx})
                    UIStack.pop("GachaViewMgr.setHopeForce")
                    UnblockLoader.cancel("GachaViewMgrD")
                    CSResourceMgr.removeCSObjectByTag(resNameD)
                    if theEggType == eggType.mMachine then
                        if type == 3 then
                            isHopeForce = true
                        elseif type == 4 then
                            isDreamForce = true
                        end
                    -- elseif theEggType == eggType.vMachine then
                    --     isHopeForce2 = true
                    end
                end,function()
                    NetInterface.sendWithBlock("GC_CapsuleEggAllInfoCmd_Ack", function()
                    local PetSend = require("src.Net.Send.PetSend")
                    PetSend.sendCG_CapsuleEggAllInfoCmd_Req()
                    end)
                end,function(code)
                    isHopeForce = false
                    isDreamForce = false
                    showDrawError(code)
                end,nil,false,function()
                    isHopeForce = false
                    isDreamForce = false
                end)
            else
                if theEggType == eggType.mMachine then
                    DialogBoxMgr.showSmallDialogBox(scene, 1, "egg30")
                -- elseif theEggType == eggType.vMachine then
                    -- DialogBoxMgr.showSmallDialogBox(scene, 1, "egg41")
                end 
            end
        end)
    end

    local function playCSB()
        CSResourceMgr.playAllFrameWithCallback(resNameD, 1, function()
        end)
    end

    local funcTable = {loadCSB, playCSB}

    UnblockLoader.load(funcTable, "GachaViewMgrD")
end

function GachaViewMgr.hide()
    GameGuideMgr.cancelGachaResultWait()
    StatusBarMgr.hideTopInfoBar()
    UIStack.pop("GachaViewMgr")
    if isEggMFree==0 and isEggGFree==0 and hopeValue<hopeValueMax and dreamValue<dreamValueMax --[[and hopeValue2<hopeValueMax2]] then
        StatusBarMgr.hideRedPoint(2)
    end
    isTenChou = false
    stopGachaAnim = false
    UnblockLoader.cancel("GachaViewMgr")
    CSResourceMgr.removeCSObjectByTag(resName)
    CSResourceMgr.removeCSObjectByTag(resNameBG, "GachaViewMgr")
    GameAudio.playUISound("retract")
    curSound = nil
end

function GachaViewMgr.getLastTime()
    return lastTime1,lastTime2
end

function GachaViewMgr.setLastTime(lastTime1G,timesG,lastTime1M)
    todayTimeG = 5-timesG
    if todayTimeG == 0 then
        todayTimeG = 5
    end
    if timesG < 5 then
        lastTime1 = lastTime1G
    else
        local timeSec = CharInfo.getServerTime()+CharInfo.getServerTimeZone()
        local daySec = timeSec%86400
        local lastSec = (lastTime1G+CharInfo.getServerTimeZone())%86400

        local today = math.ceil(timeSec/86400)
        local lastDay = math.ceil((lastTime1G+CharInfo.getServerTimeZone())/86400)

        if not PurchaseViewMgr.getMonthCardInfo() then
            if lastSec < 21300 then
                lastTime1 = timeSec - daySec + 21300-CharInfo.getServerTimeZone()
            elseif lastSec>=21300 and lastSec<21600 then
                lastTime1 = lastTime1G
            elseif lastSec >= 21600 then
                if today == lastDay then
                    lastTime1 = 107700-daySec+timeSec-CharInfo.getServerTimeZone()
                else
                    lastTime1 = 21300-daySec+timeSec-CharInfo.getServerTimeZone()
                end
            end
        else
            if lastSec < 21300 then
                lastTime1 = timeSec - daySec + 21300-CharInfo.getServerTimeZone()
            elseif lastSec >= 21300 then
                if today == lastDay then
                    lastTime1 = 107700-daySec+timeSec-CharInfo.getServerTimeZone()
                else
                    lastTime1 = 21300-daySec+timeSec-CharInfo.getServerTimeZone()
                end
            end
        end
    end
    lastTime2 = lastTime1M

    --检测红点
    local timeG = PokemonInfo.getCapsuleEggInfoByID(eggType.gMachine).CD+lastTime1-CharInfo.getServerTime()
    local timeM = PokemonInfo.getCapsuleEggInfoByID(eggType.mMachine).CD+lastTime2-CharInfo.getServerTime()
    if timeG<=0 or timeM<=0 then
        print("加红点")
        StatusBarMgr.addRedPoint(2)
        if timeG<=0 and timeM>0 then
            --红点提示
            if freeEggHandler then
                scheduler.unscheduleGlobal(freeEggHandler)
            end
            print(timeM.."秒后，免费M扭蛋...")
            freeEggHandler = scheduler.performWithDelayGlobal(function()
                StatusBarMgr.addRedPoint(2)
            end, timeM)
            BaseFunction.cancelLocalNotificationWithKey(2)
            BaseFunction.registerLocalNotification(os.time()+timeM, nil, "idling28", "", 2, 0)
        elseif  timeG>0 and timeM<=0 then
            --红点提示
            if freeEggHandler then
                scheduler.unscheduleGlobal(freeEggHandler)
            end
            print(timeG.."秒后，免费G扭蛋...")
            freeEggHandler = scheduler.performWithDelayGlobal(function()
                StatusBarMgr.addRedPoint(2)
            end, timeG)
            BaseFunction.cancelLocalNotificationWithKey(2)
            BaseFunction.registerLocalNotification(os.time()+timeG, nil, "idling28", "", 2, 0)          
        end
    else
        if timeG<timeM and timesG~=5 then
            --红点提示
            if freeEggHandler then
                scheduler.unscheduleGlobal(freeEggHandler)
            end
            print(timeG.."秒后，免费G扭蛋...")
            freeEggHandler = scheduler.performWithDelayGlobal(function()
                StatusBarMgr.addRedPoint(2)
            end, timeG)
            BaseFunction.cancelLocalNotificationWithKey(2)
            BaseFunction.registerLocalNotification(os.time()+timeG, nil, "idling28", "", 2, 0)
        end
        if timeG>=timeM or timesG==5 then
            --红点提示
            if freeEggHandler then
                scheduler.unscheduleGlobal(freeEggHandler)
            end
            print(timeM.."秒后，免费M扭蛋...")
            freeEggHandler = scheduler.performWithDelayGlobal(function()
                StatusBarMgr.addRedPoint(2)
            end, timeM)
            BaseFunction.cancelLocalNotificationWithKey(2)
            BaseFunction.registerLocalNotification(os.time()+timeM, nil, "idling28", "", 2, 0)
        end
    end
    GachaViewMgr.refreshServerTime()
end

function GachaViewMgr.refreshHopeValue()
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    if openHopeForce then
        local capsuleEggInfo2 = PokemonInfo.getCapsuleEggInfoByID(eggType.mMachine)
        local eggM = CSResourceMgr.getNodeByName(resName, "eggM")
        --屏蔽心愿梦想
        -- local hope = CSResourceMgr.seekNodeByName(eggM,"hope")
        -- hope:setVisible(true)
        -- local dream = CSResourceMgr.seekNodeByName(eggM,"dream")
        -- dream:setVisible(true)
        local hopeNum = CSResourceMgr.seekNodeByName(eggM,"hopeNum")
        CSResourceMgr.setLabelColorByNode(hopeNum, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(hopeNum, hopeValue.."/"..hopeValueMax,{r=0,g=0,b=0,a=255})
        hopeNum:enableOutline({r=0,g=0,b=0,a=255}, 1)
        local hopeBar = CSResourceMgr.seekNodeByName(eggM,"hopeBar")
        hopeBar:setPercent(hopeValue/hopeValueMax*100)
        local dreamBar = CSResourceMgr.seekNodeByName(eggM,"dreamBar")
        dreamBar:setPercent(dreamValue/dreamValueMax*100)
        local dreamNum = CSResourceMgr.seekNodeByName(eggM,"dreamNum")
        CSResourceMgr.setLabelColorByNode(dreamNum, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(dreamNum, dreamValue.."/"..dreamValueMax,{r=0,g=0,b=0,a=255})
        dreamNum:enableOutline({r=0,g=0,b=0,a=255}, 1)
        local hopeLabel = CSResourceMgr.seekNodeByName(eggM,"hopeLabel")
        CSResourceMgr.setLabelColorByNode(hopeLabel, {r=46,g=205,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(hopeLabel, LuaSqlite.getLanguageByKey("tips52").."：",{r=0,g=0,b=0,a=255})
        hopeLabel:enableOutline({r=0,g=0,b=0,a=255}, 1)
        local dreamLabel = CSResourceMgr.seekNodeByName(eggM,"dreamLabel")
        CSResourceMgr.setLabelColorByNode(dreamLabel, {r=255,g=232,b=79,a=255})
        CSResourceMgr.setLabelStringByNode(dreamLabel, LuaSqlite.getLanguageByKey("tips53").."：",{r=0,g=0,b=0,a=255})
        dreamLabel:enableOutline({r=0,g=0,b=0,a=255}, 1)
        --屏蔽梦想心愿
        -- CSResourceMgr.getNodeByName(resName,"redPointM"):setVisible(isEggMFree==1 or hopeValue>=hopeValueMax or dreamValue>=dreamValueMax)
        CSResourceMgr.getNodeByName(resName,"redPointM"):setVisible(isEggMFree==1)
    end
    -- if openHopeForce2 then
    --     local capsuleEggInfo3 = PokemonInfo.getCapsuleEggInfoByID(eggType.vMachine)
    --     local eggV = CSResourceMgr.getNodeByName(resName, "eggV")
    --     local hope = CSResourceMgr.seekNodeByName(eggV,"hope")
    --     hope:setVisible(true)
    --     local hopeNum = CSResourceMgr.seekNodeByName(eggV,"hopeNum")
    --     CSResourceMgr.setLabelColorByNode(hopeNum, {r=255,g=255,b=255,a=255})
    --     CSResourceMgr.setLabelStringByNode(hopeNum, hopeValue2.."/"..hopeValueMax2,{r=0,g=0,b=0,a=255})
    --     hopeNum:enableOutline({r=0,g=0,b=0,a=255}, 1)
    --     local hopeLabel = CSResourceMgr.seekNodeByName(eggV,"hopeLabel")
    --     CSResourceMgr.setLabelColorByNode(hopeLabel, {r=46,g=205,b=255,a=255})
    --     CSResourceMgr.setLabelStringByNode(hopeLabel, "egg9",{r=0,g=0,b=0,a=255})
    --     hopeLabel:enableOutline({r=0,g=0,b=0,a=255}, 1)
    --     CSResourceMgr.getNodeByName(resName,"redPointV"):setVisible(hopeValue2>=hopeValueMax2)
    -- end
end

function GachaViewMgr.setCapsuleEggAllInfo(capsuleEggAllInfo)
    if openHopeForce then
        eggAllInfo = capsuleEggAllInfo
        hopeValue = BagViewMgr.getItemNum(9992) or 0
        dreamValue = BagViewMgr.getItemNum(9993) or 0
        monsterTable = eggAllInfo["2"].wishPets or {}
        dreamMonsterTable = eggAllInfo["2"].dreamPets or {}
        GachaViewMgr.refreshHopeValue()
        -- if hopeValue>=hopeValueMax or dreamValue>=dreamValueMax then
        --     StatusBarMgr.addRedPoint(2)
        -- end
    end
    -- if openHopeForce2 then
    --     eggAllInfo2 = capsuleEggAllInfo2
    --     hopeValue2 = eggAllInfo["3"].addValue or 0
    --     monsterTable2 = eggAllInfo["3"].addPets
    --     GachaViewMgr.refreshHopeValue()
    --     if hopeValue2>=hopeValueMax2 then
    --         StatusBarMgr.addRedPoint(2)
    --     end
    -- end
end

function GachaViewMgr.refreshServerTime() 
    local curLayer = CSResourceMgr.getCsbObj(resName)
    if curLayer then
        GachaViewMgr.refreshServerTime2(lastTime1,eggType.gMachine)
        GachaViewMgr.refreshServerTime2(lastTime2,eggType.mMachine)
    end
end

function GachaViewMgr.showBringLimitDialog() 
    DialogBoxMgr.showSmallDialogBox(scene, 1, "egg28")
    GachaViewMgr.setVisible(true)
end

function GachaViewMgr.showNotEnoughBagFreeCellDialog() 
    DialogBoxMgr.showSmallDialogBox(scene, 1, "egg32")
    GachaViewMgr.setVisible(true)
end

function GachaViewMgr.refreshServerTime2(lastTime,gachaType)
    local eggMachine = {}
    local capsuleEggInfo = {}
    if gachaType == eggType.gMachine then
        eggMachine = CSResourceMgr.getNodeByName(resName, "eggG")
        capsuleEggInfo = PokemonInfo.getCapsuleEggInfoByID(eggType.gMachine)
    elseif gachaType == eggType.mMachine then
        eggMachine = CSResourceMgr.getNodeByName(resName, "eggM")
        capsuleEggInfo = PokemonInfo.getCapsuleEggInfoByID(eggType.mMachine)
    end

    local timeLabel = CSResourceMgr.seekNodeByName(eggMachine, "freeTimeNum")
    if timeLabel then
        transition.stopTarget(timeLabel)
        local coodDownTime = capsuleEggInfo.CD
        print(coodDownTime+lastTime-CharInfo.getServerTime())
        if CharInfo.getServerTime()<lastTime+coodDownTime then
            local time = coodDownTime+lastTime-CharInfo.getServerTime()
            local h = math.floor(time/3600)
            local m = math.floor((time-h*3600)/60)
            local s = time-h*3600-m*60
            GachaViewMgr.updateTime(h, m, s,gachaType)
            if gachaType == eggType.gMachine then
                isEggGFree = 0
            elseif gachaType == eggType.mMachine then
                isEggMFree = 0
            end
        else
            GachaViewMgr.updateTime(0, 0, 0,gachaType)
            if gachaType == eggType.gMachine then
                StatusBarMgr.addRedPoint(2)
                isEggGFree = 1
            elseif gachaType == eggType.mMachine then
                StatusBarMgr.addRedPoint(2)
                isEggMFree = 1
            end
        end
    end
    CSResourceMgr.getNodeByName(resName,"redPointG"):setVisible(isEggGFree==1)
    --屏蔽梦想心愿
    -- CSResourceMgr.getNodeByName(resName,"redPointM"):setVisible(isEggMFree==1 or hopeValue>=hopeValueMax or dreamValue>=dreamValueMax)
    CSResourceMgr.getNodeByName(resName,"redPointM"):setVisible(isEggMFree==1)
    -- CSResourceMgr.getNodeByName(resName,"redPointV"):setVisible(hopeValue2>=hopeValueMax2)
end

function GachaViewMgr.updateTime(h, m, s,gachaType)
    local tmpAwardsEvent = {}
    local h_str = string.format("%02d", h)
    local m_str = string.format("%02d", m)
    local s_str = string.format("%02d", s)

    local capsuleEggInfo1 = PokemonInfo.getCapsuleEggInfoByID(gachaType)
    local consumeElementInfo1 = ItemInfo.getConsumeElementInfoById(capsuleEggInfo1.OneEggCons)
    local eggMachine = {}
    if gachaType == eggType.gMachine then
        eggMachine = CSResourceMgr.getNodeByName(resName, "eggG")
        if gMachineTime and CSResourceMgr.getCsbObj(resNameA) then
            CSResourceMgr.setLabelStringByNode(gMachineTime, LuaSqlite.getLanguageByKey("egg2")..h_str..":"..m_str..":"..s_str)
        end
        if oneDrawCostLabelG and CSResourceMgr.getCsbObj(resNameA) then
            CSResourceMgr.setLabelStringByNode(oneDrawCostLabelG, consumeElementInfo1.num)
        end
    elseif gachaType == eggType.mMachine then
        eggMachine = CSResourceMgr.getNodeByName(resName, "eggM")
        if mMachineTime and CSResourceMgr.getCsbObj(resNameA) then
            CSResourceMgr.setLabelStringByNode(mMachineTime, LuaSqlite.getLanguageByKey("egg2")..h_str..":"..m_str..":"..s_str)
        end
        if oneDrawCostLabelM and CSResourceMgr.getCsbObj(resNameA) then
            CSResourceMgr.setLabelStringByNode(oneDrawCostLabelM, consumeElementInfo1.num)
        end
    end
    local timeLabel = CSResourceMgr.seekNodeByName(eggMachine, "freeTimeNum")

    CSResourceMgr.setLabelStringByNode(timeLabel,  LuaSqlite.getLanguageByKey("egg2")..h_str..":"..m_str..":"..s_str,nil,nil,225)
    timeLabel:performWithDelay(function()
        GachaViewMgr.updateTime(h, m, s,gachaType)
    end, 1)
    s=s-1
    if s<0 then
        s=59
        m=m-1
        if m<0 then
            m=59
            h=h-1
            if h<0 then
                h=0
                m=0
                s=0
                transition.stopTarget(timeLabel)
                if gachaType == eggType.gMachine then
                    timeLabel:setScaleX(timeLabel:getScaleY()*1)
                    CSResourceMgr.setLabelStringByNode(timeLabel, LuaSqlite.getLanguageByKey("egg31")..":"..todayTimeG)
                    isEggGFree = 1
                    if CSResourceMgr.getCsbObj(resNameA) then
                        if gMachineTime then
                            CSResourceMgr.setLabelStringByNode(gMachineTime, LuaSqlite.getLanguageByKey("egg31")..":"..todayTimeG)
                        end
                        if oneDrawCostLabelG then
                            CSResourceMgr.setLabelStringByNode(oneDrawCostLabelG, "egg29")
                        end
                    end
                    if oneDrawCostLabelG2 then
                        CSResourceMgr.setLabelStringByNode(oneDrawCostLabelG2, "egg29")
                    end
                elseif gachaType == eggType.mMachine then
                    CSResourceMgr.setLabelStringByNode(timeLabel, LuaSqlite.getLanguageByKey("egg2").."00:00:00",nil,nil,225)
                    isEggMFree = 1
                    if CSResourceMgr.getCsbObj(resNameA) then
                        if mMachineTime then
                            CSResourceMgr.setLabelStringByNode(mMachineTime, LuaSqlite.getLanguageByKey("egg2").."00:00:00")
                        end
                        if oneDrawCostLabelM then
                            CSResourceMgr.setLabelStringByNode(oneDrawCostLabelM, "egg29")
                        end
                    end
                    if oneDrawCostLabelM2 then
                        CSResourceMgr.setLabelStringByNode(oneDrawCostLabelM2, "egg29")
                    end
                end 
            end
        end
    end
end

function GachaViewMgr.isHavePet(petID,petInfo)
    local petWikiNew = PetHandBook.getPetWikiInfoLst()
    if petInfo and petInfo.skin~=0 then
        return false
    end
    if petWikiNew[petID] then
        return true
    end
    return false
end

function GachaViewMgr.setVisible(visible)
    if not CSResourceMgr.getCsbObj(resName) or CSResourceMgr.getCsbObj(resNameB) or CSResourceMgr.getCsbObj(resNameC) or CSResourceMgr.getCsbObj(resNameD) then
        return
    end
    if visible == false then
        StatusBarMgr.hideTopInfoBar(0)
    else
        StatusBarMgr.showTopInfoBar(nil,0)
    end
end

return GachaViewMgr