local ExpeditionalInfo =  require("src.GameMgr.Data.ExpeditionalInfo")

local expeditionalViewMgr   = {}
local mapSize           = {}
local reward_lights     = {}
local battleInfo        = {}
local petNodes          = {}
local selPets           = {}
local curPointID        = 1
local cur_R_index       = 1
local map_zorder        = 1
local score_zorder      = map_zorder+1
-- local petNodesPosY      = 80
local expeditiondata    = nil
local isShowLotter      = false
local roll_stepNum      = 0
local awardThings       = nil  
local LotterBtn         = nil   
local helpBtn           = nil
local scene             = nil
 
expeditionalViewMgr.curMapID    = 1
expeditionalViewMgr.isMovePlay  = false
expeditionalViewMgr.expedition  = nil
expeditionalViewMgr.refresh     = false
expeditionalViewMgr.playerSpeed = 100
expeditionalViewMgr.pets  = {}

expeditionalViewMgr.POINT_TYPE_BATTLE = 1
expeditionalViewMgr.POINT_TYPE_HIDE   = 9

local labelColor = {
    {r=254,g=234,b=  0,a=255},
    {r=119,g=204,b=245,a=255},
    {r=225,g=233,b=254,a=255},
    {r=165,g=243,b=255,a=255},
    {r=120,g=146,b=181,a=255},

    {r=255,g=255,b=255,a=255},
    {r=166,g=243,b=253,a=255},
}

local outlineColor = {
    {r=0,g=0,b=0,a=255,w=1,s=1},
    {r=0,g=0,b=0,a=255,w=2,s=1},
    {r=0,g=0,b=0,a=255,w=3,s=1},
}
local resName_scoreReward = "Activity/scoreReward.csb"
local resName_battle      = "Activity/SurviveBattle.csb"

function expeditionalViewMgr.Init()
    expeditionalViewMgr.curMapID = 1
    mapSize = {}
    expeditionalViewMgr.selectedPet = {}
end

function expeditionalViewMgr.setAwardThings(things)
    awardThings = things
end

function expeditionalViewMgr.checkIsemptySelPets()
    for key,var in pairs(selPets) do
        return false
    end
    return true
end

function expeditionalViewMgr.checkSelPetsNumber()
    local num = 0
    for key,var in pairs(selPets) do
        num = num + 1
    end
    return num 
end

function expeditionalViewMgr.selectPetsView(EType)
    local resName = "Activity/selectPets.csb" 
    local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, resName)
    layer:zorder(CocosModuleMgr.ZORDER_MSGBOX - 1)
    CSResourceMgr.setRelativePosition(resName, 320, 480)

    local limitNum   =  SystemInfo.getGlobalConfigAddInfoByID(63001).values[1] 
    local expeditionRow    = 4
    local expeditionLine   = 6
    local selPosX  = 60
    local selPosY  = 40
    local oneButton = CSResourceMgr.getNodeByName(resName, "oneButton")
    local list      = CSResourceMgr.getNodeByName(resName, "list")
    local panel     = CSResourceMgr.getNodeByName(resName, "panel")
    local sure      = CSResourceMgr.getNodeByName(resName, "sure")
    local close     = CSResourceMgr.getNodeByName(resName, "close") 
    local title     = CSResourceMgr.getNodeByName(resName, "title")
    local num       = CSResourceMgr.getNodeByName(resName, "num")
    local allPets   = clone(PokemonInfo.getAllPets())
    local totalLine  = math.ceil(#allPets / expeditionRow)
    local showCnt    = expeditionRow * expeditionLine
    local showLine   = math.min(expeditionLine, totalLine) 
    local diffX      = 124
    local panelNodes  = {}
    local cardNodes   = {}
    local judgeSel    = {}
    local oneSelBtn   = nil
    local resSel = "Battle/funcMenu/fight_auto_form.png"
    local petNodesPosY = 80
    local selPetNum  = 0

    local function intButton(btn)
        local btn_txt = btn:getTitleRenderer()
        local btn_Str = LuaSqlite.getLanguageByKey(btn_txt:getString())
        btn_txt:enableOutline({r=0,g=0,b=0}, 1) 
        btn_txt:setString(btn_Str)

    end 
    intButton(sure)
    intButton(oneButton)
    -- title:setString(LuaSqlite.getLanguageByKey(title:getString()))
    CSResourceMgr.setLabelStringByNode(title,title:getString())
    title:enableOutline({r=0,g=0,b=0,a=255}, 1)
    title:setTextColor({r=255,g=255,b=204,a=255})
    num:setString(selPetNum.."/"..limitNum)
    num:enableOutline({r=0,g=0,b=0,a=255}, 2)
    table.sort(allPets, function(a, b) 
            return a.fc > b.fc
        end)

    for i = 1, showLine do
        panelNodes[i] = panel:clone()
        list:pushBackCustomItem(panelNodes[i])
    end

    local index = 1
    for key,var in pairs(allPets) do
        if key > showCnt then break end
        local line = math.ceil(key / expeditionRow)
        local row = key % expeditionRow == 0 and expeditionRow or key % expeditionRow
        local petNode = BattleFuncMgr.startCreatePetCard(var, 3, true) 
        if var.skin ~= 0 then
            CSResourceMgr.setLabelColorByNode(petNode.level, {r=96,g=255,b=0,a=255})
        end
        cardNodes[key] = petNode.button
        cardNodes[key]:setVisible(true)
        cardNodes[key]:setScale(1.3, 1.3)
        
        cardNodes[key]:setPosition(cardNodes[key]:getPositionX() + (row - 1) * diffX + 72, petNodesPosY)
        if not panelNodes[line].button then
            panelNodes[line].button = {}
        end 
        cardNodes[key].index  = key
        panelNodes[line].button[row] = cardNodes[key]
        panelNodes[line].button[row].select  = false
        panelNodes[line].button[row].selNode = nil
        panelNodes[line].button[row]:addTo(panelNodes[line])


        CSResourceMgr.clickEventBindingByNode(cardNodes[key], function ()
                if judgeSel[key] then
                    judgeSel[key] = false
                    if cardNodes[key].selNode then
                        cardNodes[key].selNode:removeFromParent()
                        cardNodes[key].selNode = nil
                    end
                    selPets[key] = nil
                    selPetNum = selPetNum - 1
                    num:setString(selPetNum.."/"..limitNum)
                else
                    if expeditionalViewMgr.checkSelPetsNumber() >= limitNum  then
                        return 
                    end
                    if not cardNodes[key].selNode then
                        cardNodes[key].selNode = display.newSprite(resSel)
                        cardNodes[key].selNode:addTo(cardNodes[key])
                        cardNodes[key].selNode:setPosition(selPosX,selPosY)
                        cardNodes[key].selNode:zorder(10)
                    end
                    judgeSel[key] = true
                    selPets[key] = var
                    selPetNum = selPetNum + 1
                    num:setString(selPetNum.."/"..limitNum)
                end
            end, 3)
    end

    BattleFuncMgr.endCreatePetCard()

    HighPerformList.makeHighPerFormVerticalList(list, expeditionLine, 0, expeditionRow, 200, 190, allPets,
    function(item, currentIndex)
        for i=1,expeditionRow do
            if currentIndex + i -1 <= #allPets then--防止越界
                -- item.button[i]:setVisible(true)
                PetCommonListViewMgr.updateCard(allPets[currentIndex+i-1], item.button[i]) 
                item.button[i].index = currentIndex+i-1
                if judgeSel[currentIndex+i-1] then
                    if not item.button[i].selNode then 
                        item.button[i].selNode = display.newSprite(resSel)
                        item.button[i].selNode:addTo(item.button[i])
                        item.button[i].selNode:setPosition(selPosX,selPosY)
                        item.button[i].selNode:zorder(10)
                    end
                else 
                    if item.button[i].selNode then 
                        item.button[i].selNode:removeFromParent() 
                        item.button[i].selNode = nil
                    end
                end
            
            end 
            CSResourceMgr.clickEventBindingByNode(item.button[i], function () 
                if judgeSel[currentIndex+i-1] then
                    if item.button[i].selNode then
                        item.button[i].selNode:removeFromParent()
                        item.button[i].selNode = nil
                    end
                    judgeSel[currentIndex+i-1] = false
                    selPets[currentIndex+i-1] = nil
                    selPetNum = selPetNum - 1
                    num:setString(selPetNum.."/"..limitNum)
                else
                    if expeditionalViewMgr.checkSelPetsNumber() >= limitNum  then
                        return 
                    end
                    if not item.button[i].selNode then
                        item.button[i].selNode = display.newSprite(resSel)
                        item.button[i].selNode:addTo(item.button[i])
                        item.button[i].selNode:setPosition(selPosX,selPosY)
                        item.button[i].selNode:zorder(10)
                    end 
                    judgeSel[currentIndex+i-1] = true
                    selPets[currentIndex+i-1] = allPets[currentIndex+i-1] 
                    selPetNum = selPetNum + 1
                    num:setString(selPetNum.."/"..limitNum) 
                end
            end,3)
        end
    end)

    CSResourceMgr.clickEventBindingByNode(sure, function()
                BattlePVPMgr.endCalcTime()
                if expeditionalViewMgr.checkSelPetsNumber() > 0  then
                    if expeditionalViewMgr.checkSelPetsNumber() >= limitNum then
                        expeditionalViewMgr.enterExpedition(EType,true) 
                        CSResourceMgr.setButtonEnabledByNode(sure,false)
                    else
                        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, LuaSqlite.getLanguageByKey("expedition36"), 
                        function() expeditionalViewMgr.enterExpedition(EType,true) 
                            CSResourceMgr.setButtonEnabledByNode(sure,false) end)
                    end
                else
                    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, LuaSqlite.getLanguageByKey("expedition37"), 
                        function()end)
                end
            end, 3)
    
    CSResourceMgr.clickEventBindingByNode(oneButton, function()
                if not isOneBtn then 
                    for key,var in pairs(allPets) do
                        if expeditionalViewMgr.checkSelPetsNumber() < limitNum  then
                            if not judgeSel[key]  then
                                if not cardNodes[key].selNode and cardNodes[key].index == key then
                                    cardNodes[key].selNode = display.newSprite(resSel)
                                    cardNodes[key].selNode:setPosition(selPosX,selPosY)
                                    cardNodes[key].selNode:addTo(cardNodes[key])
                                    cardNodes[key].selNode:zorder(10)    
                                end 
                                judgeSel[key] = true
                                selPets[key] = var
                            end
                            selPetNum = limitNum
                            num:setString(limitNum.."/"..limitNum)
                        else
                            break
                        end
                    end
                end
            end, 3)

    CSResourceMgr.clickEventBindingByNode(close, function()
                BattlePVPMgr.endCalcTime()
                selPets = {}
                CSResourceMgr.removeCSObjectByTag(resName)
            end, 2)

end

function expeditionalViewMgr.enterExpedition(EType,isSelect)
    NetInterface.sendWithBlock("GC_GetExpeditionData_Ack", function()
            local ExpeditionSend = require("src.Net.Send.ExpeditionSend")
            local objIDs = {} 
            for key,var in pairs(selPets) do
                table.insert(objIDs,var.objID)
            end
            ExpeditionSend.sendCG_GetExpeditionData_Req({type = EType,petList = objIDs}) 
        end, function()
            ExpeditionalInfo:init() 
            local expeditiondata = expeditionalViewMgr.expedition:getExpeditionData()
            local mapID    = 1

            if expeditiondata.buyCount then
                expeditiondata.point = expeditiondata.point + expeditiondata.buyCount 
            end

            CharInfo.setExpeditionPoint(expeditiondata.point)

            -- print("expeditiondata1111111111111111111",sz_T2S(expeditiondata)) 
            battleInfo.battlelist = {} 
            battleInfo.battlelist = clone(expeditiondata.mapList)  
            -- for key,var in pairs(expeditiondata.mapList) do
            --     battleInfo.battlelist[key] = clone(var)
            -- end
            if expeditionalViewMgr.refresh then
                expeditionalViewMgr.expedition:setPoint(true) 
            end

            local mapPointVec = expeditionalViewMgr.expedition:getMapPoints(mapID)

            if expeditiondata.currentSchedule == 0 then
                curPointID = 1
            end

            for key,var in pairs(mapPointVec) do 
                if expeditiondata.currentSchedule == var.pparam then
                    curPointID = key
                else
                	curPointID = 1
                end
            end

            CharInfo.setExpediCreateTime(expeditiondata.createTime)
            if expeditiondata.level == EType then
                if isSelect then
                    BattlePVPMgr.startCalcTime(function() 
                        if #expeditionalViewMgr.pets >= expeditiondata.petCount then 
                            SceneMgr.replaceScene(SceneMgr.getRunningScene,"ExpeditionScene")
                            BattlePVPMgr.endCalcTime()
                        end
                        
                    end,0.5)
                else
                    BattlePVPMgr.startCalcTime(function() 
                        if #expeditionalViewMgr.pets >= expeditiondata.petCount then 
                            SceneMgr.replaceScene(SceneMgr.getRunningScene,"ExpeditionScene")
                            BattlePVPMgr.endCalcTime()
                        end
                        
                    end,0.5)
                    SceneMgr.replaceScene(SceneMgr.getRunningScene,"ExpeditionScene")
                    BattlePVPMgr.endCalcTime()
                end
                
            else
                StandardTipsMgr.show(1,"error")
            end
        end, function(code)
            StandardTipsMgr.show(1,"GC_GetExpeditionData_Ack failed code="..code)
        end) 

end

function expeditionalViewMgr.OpenChooseTypesUI(parent)
    local resName = "Activity/ExpeditionSelectType.csb"
    local layer = CSResourceMgr.createRes(parent, resName)
    local btn_1 = CSResourceMgr.getNodeByName(resName, "btn_1")
    local btn_2 = CSResourceMgr.getNodeByName(resName, "btn_2")
    local btn_3 = CSResourceMgr.getNodeByName(resName, "btn_3")
    local btn_4 = CSResourceMgr.getNodeByName(resName, "btn_4")
    local btn_5 = CSResourceMgr.getNodeByName(resName, "btn_5")
    local close = CSResourceMgr.getNodeByName(resName, "close")
    local sure  = CSResourceMgr.getNodeByName(resName, "sure")
    local help  = CSResourceMgr.getNodeByName(resName, "help")
    local selectText = CSResourceMgr.getNodeByName(resName, "selectText")
    local chooseType = 0
    CSResourceMgr.setRelativePosition(resName, 320, 480)
    layer:zorder(CocosModuleMgr.ZORDER_MSGBOX - 1)
    CocosModuleMgr.showUIAnimation(layer, "down")
    local buttonList = {btn_1,btn_2,btn_3,btn_4,btn_5,sure,help}
    local function intButton(btn)
        local btn_txt = btn:getTitleRenderer()
        local btn_Str = LuaSqlite.getLanguageByKey(btn_txt:getString())
        btn_txt:enableOutline({r=0,g=0,b=0}, 1) 
        -- btn_txt:setString(btn_Str)
        CSResourceMgr.setButtonStringByNode(btn, btn_Str)
    end

    for key,var in pairs(buttonList) do
        intButton(var)
    end

    local selectTextStr = LuaSqlite.getLanguageByKey(selectText:getString())
    local isFirst   = false
    local isSecond  = false
    local isOverTime = false
    local isAwardTime = false

    -- selectText:setString(selectTextStr)
    CSResourceMgr.setLabelStringByNode(selectText,selectTextStr)
    selectText:enableOutline({r=0,g=0,b=0}, 2) 
    selectText:setTextColor({r=152,g=225,b=234,a=255})

    local maxLevel  = CharInfo.getFinishExpeditionLevel()
    local currLevel = CharInfo.getCurrentExpeditionLevel()
    
	if expeditionalViewMgr.checkExpeditionOverDate() then
		isOverTime = true
	end

    if expeditionalViewMgr.checkExpeditionAwardTime() then
        isAwardTime = true
    end
    if not maxLevel then
        maxLevel = 0
    end

    local ExLevelInfo = TxtReader.new("Config/ExpeditionLevel.txt")
    local ExLevel = ExLevelInfo.init({"id", "type", "level"},nil,{
        id = 1,level = 1})

    for key,var in pairs(ExLevel) do
        local ex_text =  CSResourceMgr.getNodeByName(resName, "Text_"..key)
        -- ex_text:setString(LuaSqlite.getLanguageByKey("expedition40").." "..var.level)
        CSResourceMgr.setLabelStringByNode(ex_text,LuaSqlite.getLanguageByKey("expedition40").." "..var.level)
        ex_text:enableOutline({r=0,g=0,b=0}, 1) 
        ex_text:setTextColor({r=255,g=0,b=0,a=255}) 
    end

    local function closeBtn(btn)
        BattleFuncMgr.setNodeGray(btn,false) 
        btn:setTouchEnabled(false)
    end

    local function buttonEvent(EventIndex)
        CSResourceMgr.setButtonEnabledByNode(buttonList[EventIndex],false) 
        if isAwardTime and not isOverTime and EventIndex ~= currLevel then
            DialogBoxMgr.showSmallDialogBox(parent, 1, LuaSqlite.getLanguageByKey("expedition28"), function()end)
        end
        for i = 1,5 do   
            if EventIndex ~= i then
                if i > maxLevel  then
                    if maxLevel + 1 == i then
                        CSResourceMgr.setButtonEnabledByNode(buttonList[i],true)
                    end
                else
                    if isAwardTime and not isOverTime then
                        if i == maxLevel then
                            CSResourceMgr.setButtonEnabledByNode(buttonList[i],true)
                        end
                    else
                        CSResourceMgr.setButtonEnabledByNode(buttonList[i],true)
                    end 
                end
            end
        end
    end

    for i = 1,5 do
        if i > maxLevel  then
            if maxLevel + 1 ~= i then
                closeBtn(buttonList[i])
            end
        else
            if isAwardTime and not isOverTime then
                if i ~= maxLevel then
                    closeBtn(buttonList[i])
                end
            end 
        end
    end

    CSResourceMgr.buttonEventBindingByNodeXP(btn_1, function()
        end, function()
            chooseType = 1
            buttonEvent(chooseType)
        end, nil, function()
            
        end, false, nil, function()
            
        end)

    CSResourceMgr.buttonEventBindingByNodeXP(btn_2, function() 
        end, function()
            chooseType = 2
            buttonEvent(chooseType)
        end, nil, function()end, false, nil, function() end)

    CSResourceMgr.buttonEventBindingByNodeXP(btn_3, function()
        end, function()
            chooseType = 3
            buttonEvent(chooseType)
        end, nil, function()end, false, nil, function()end)

    CSResourceMgr.buttonEventBindingByNodeXP(btn_4, function()
        end, function()
            chooseType = 4
            buttonEvent(chooseType)
        end, nil, function()end, false, nil, function()end)

    CSResourceMgr.buttonEventBindingByNodeXP(btn_5, function()
        end, function()
            chooseType = 5
            buttonEvent(chooseType)
        end, nil, function()end, false, nil, function()end)

    CSResourceMgr.buttonEventBindingByNodeXP(close, function()
        end, function()
            CSResourceMgr.removeCSObjectByTag(resName)
        end, nil, function()end, false, nil, function()end)

    CSResourceMgr.buttonEventBindingByNodeXP(help, function()
        end, function()
            DialogBoxMgr.showSmallDialogBox(parent, 1, "expedition16", function()end)
        end, nil, function()end, false, nil, function()end)

    CSResourceMgr.buttonEventBindingByNodeXP(sure, function()
        end, function()
            if chooseType ~= 0 then
                if isAwardTime and not isOverTime and chooseType == maxLevel then
                    expeditionalViewMgr.enterExpedition(chooseType) 
                else
                    expeditionalViewMgr.selectPetsView(chooseType)
                end
            else
                DialogBoxMgr.showSmallDialogBox(parent, 1, LuaSqlite.getLanguageByKey("expedition25"), function()end)
            end
        end, nil, function()end, false, nil, function()end)
end

function expeditionalViewMgr.cleanup()
    battleInfo        = {}
    mapSize           = {}
    selPets           = {}
    expeditionalViewMgr.pets  = {}
    expeditionalViewMgr.isMovePlay = false
    isShowLotter      = false
end

function expeditionalViewMgr.checkRedPoint()
    local effRes    = "UI/Effect/redPoint.csb"
    local effAniRes = "Spine/effects/touch1.png"
    if expeditionalViewMgr.expedition:getDropUnusedCount() > 0 then

        if not AnimationMgr.AnimationObjTable[effAniRes] then
            local eff = CSResourceMgr.createRes(LotterBtn, effRes)
            CSResourceMgr.playAllFrame(effRes, true)
            local size = LotterBtn:getContentSize()
            if eff then
                eff:setAnchorPoint(0.5, 0.5) 
                eff:setPosition(size.width/2, size.height/2+10)
                eff:setScale(0.7,0.7)
            end 

            local effAni = AnimationMgr.createAni(scene, effAniRes, 
                2*display.cx-44, 2*display.cy-126)
            AnimationMgr.playAni(effAniRes, "idle", true)
            effAni:zorder(map_zorder) 
            effAni:setTimeScale(0.5)
            effAni:setScale(1.5,1.6)
        end
    else
        CSResourceMgr.removeCSObjectByTag(effRes)
        AnimationMgr.removeGafObjectByTag(effAniRes)
    end
end

function expeditionalViewMgr.OpenMap(parent)
    local mapID  = 1
    local isChangeRoutine = false
    local mapSize = {}
    local resName = "Map/WorldMap/WorldMapLayer_tts.csb"
    local headTagStr = "expeditionPlayer"
    local expeditiondata = expeditionalViewMgr.expedition:getExpeditionData()
    local layer = CSResourceMgr.createRes(parent, resName)
    CSResourceMgr.setRelativePosition(resName, 320, 480)
    CocosModuleMgr.setEdgeDistance(layer, nil, nil, 0, nil) 
    layer:setLocalZOrder(map_zorder)

    local sizediff   = CocosModuleMgr.getScreenSizeDiff()
    local scrollview = CSResourceMgr.getNodeByName(resName, "scrollview")
    local scrollwidth   = scrollview:getContentSize().width
    local oringinheight = scrollview:getContentSize().height
    local scrollheight  = oringinheight+sizediff 
    local playerAni      = nil
    mapSize = scrollview:getInnerContainerSize() 
    scene = parent
    scrollview:setContentSize(scrollwidth, scrollheight)
    local mapScale = 0.9

    StatusBarMgr.showExpeditionTopBar(parent, function()
            
            if isShowLotter then
                StatusBarMgr.refreshExpeditionScore()  
                CSResourceMgr.removeCSObjectByTag(resName_scoreReward)
                CSResourceMgr.removeCSObjectByTag("Pet/Formation/FormationBGNew.csb")
                helpBtn:show()
                isShowLotter = false
            else
                expeditionalViewMgr.cleanup()
                CSResourceMgr.removeCSObjectByTag(resName)
                SceneMgr.replaceScene(SceneMgr.getRunningScene, "MainScene")
            end
        end,function(layer)
            layer:zorder(map_zorder+3)
        end)
    StatusBarMgr.refreshExpeditionScore()

    LotterBtn = cc.ui.UIPushButton.new({normal = "UI/CommonFiles/jfbz_icon.png", pressed = "UI/CommonFiles/jfbz_icon.png"})
    LotterBtn:onButtonClicked(function()
                expeditionalViewMgr.sendLotteryNet()
        end)
    LotterBtn:pos(2*display.cx-40,2*display.cy-130)
    LotterBtn:addTo(parent)
    LotterBtn:zorder(map_zorder + 1) 

    helpBtn = cc.ui.UIPushButton.new({normal = "UI/CommonFiles/share_menu_help_02_nomal.png", 
        pressed = "UI/CommonFiles/share_menu_help_02_ed.png"}) 
    helpBtn:onButtonClicked(function() 
            DialogBoxMgr.showSmallDialogBox(parent, 1, "expedition16", function()end)
        end)
    local helpSize = helpBtn:getContentSize()
    helpBtn:setAnchorPoint(0.0,1.0) 
    helpBtn:pos(0,2*display.cy)
    helpBtn:addTo(parent)
    helpBtn:setScale(1.3,1.3)
    helpBtn:zorder(CocosModuleMgr.ZORDER_WINDOW+2)  
    
    expeditionalViewMgr.checkRedPoint()
    function scrollMapTo(px, py, time)
        if time<=0 then
            scrollview:jumpToPercentHorizontal(px)
            scrollview:jumpToPercentVertical(py)
        else
            transition.stopTarget(scrollview)
            scrollview:performWithDelay(function()
                scrollview:scrollToPercentBothDirection({x=px, y=py}, time, true)
            end, 0.001)
        end
    end

    function checkScroll(i, time)
        local node = CSResourceMgr.getNodeByName(resName, "p"..i)
        if node then
            local posx = node:getPositionX() 
            local posy = node:getPositionY()
            local diffx = posx*mapScale-scrollwidth/2
            local diffw = mapSize.width*mapScale-scrollwidth
            local ratex = diffx/diffw*100
            if ratex<0 then
                ratex = 0
            elseif ratex>100 then
                ratex = 100
            end
            local diffy = mapSize.height*mapScale-posy*mapScale-scrollheight/2
            local diffh = mapSize.height*mapScale-scrollheight
            local ratey = diffy/diffh*100
            if ratey<0 then
                ratey = 0
            elseif ratey>100 then
                ratey = 100
            end
            scrollMapTo(ratex, ratey, time)
        end
    end

    local touchPoint = 0
    local touchInfo = {}
    local touchInfoTmp = {}
    local touchDistance = 0
    local touchRate = 0
    local isTouchScaling = false
    local touchLayer = display.newLayer():addTo(parent)
    scrollview:setSwallowTouches(false)
    scrollview:setBounceEnabled(false)
    local listenner = cc.EventListenerTouchAllAtOnce:create()
    listenner:registerScriptHandler(function(touch,event)
            touchPoint = touchPoint+#touch
            for key, var in pairs(touch) do
                if #touchInfo<2 then
                    local x = touchLayer:convertToNodeSpace(var:getLocation()).x
                    local y = touchLayer:convertToNodeSpace(var:getLocation()).y
                    table.insert(touchInfo, {x=x, y=y})
                end
            end

            if #touchInfo==1 then
                local x = touchInfo[1].x
                local y = touchInfo[1].y
                --点击脚印效果
                local footPrintRes = "Spine/effects/Ui_jiemiandianji.png"
                local footPrint = AnimationMgr.createAni(scene, footPrintRes, x, y)
                AnimationMgr.playAniWithCallback(footPrintRes, "animation", nil, nil, true)
                footPrint:setLocalZOrder(CocosModuleMgr.ZORDER_TIPS)
                if CSResourceMgr.getCsbObj("UI/Chat/TownChatLayer.csb") then
                    TownChatMgr.showChatView(false)
                end
            end
        end, cc.Handler.EVENT_TOUCHES_BEGAN)

    --放背景音乐
    GameAudio.playMusic2("mapmusic1")

    local function moveTo(rountPoints,isFirst,pid)
        local terPointID   = rountPoints[1]
        local curMapButton = CSResourceMgr.getNodeByName(resName, "p"..curPointID)
        local terMapButton = CSResourceMgr.getNodeByName(resName, "p"..terPointID)
        local curPosx = curMapButton:getPositionX()
        local terPosx = terMapButton:getPositionX()
        local curPosy = curMapButton:getPositionY()
        local terPosy = terMapButton:getPositionY()
        local curScalex = math.abs(playerAni:getScaleX())
        local curScaley = math.abs(playerAni:getScaleY())

        playerAni = PlayerAnimeMgr.getPlayer(headTagStr)
        if terPosx-curPosx<0 then
            playerAni:setScale(-curScalex, curScaley)
        else
            playerAni:setScale(curScalex, curScaley)
        end
        local distance = math.sqrt(math.pow(terPosx-curPosx, 2)+math.pow(terPosy-curPosy, 2))
        local movetime  = distance/expeditionalViewMgr.playerSpeed
        transition.moveTo(playerAni, {x=terPosx, y=terPosy, time=movetime}) 
        PlayerAnimeMgr.playAni(headTagStr, "walk", true)
        playerAni:performWithDelay(function()
            PlayerAnimeMgr.playAni(headTagStr, "idle", true)
            curPointID = rountPoints[1]
            table.remove(rountPoints, 1)
            if #rountPoints > 0 and not isChangeRoutine then
                moveTo(rountPoints,false,pid) 
            else
                if curPointID == pid then 
                    expeditionalViewMgr.checkEvents(pid) 
                end
                isChangeRoutine = false 
                expeditionalViewMgr.isMovePlay = false
                return
            end
            if isFirst then
                checkScroll(curPointID, 0.5)
                playerAni:performWithDelay(function()
                    checkScroll(terPointID, movetime-0.5)
                end, 0.5)
            else
                checkScroll(terPointID, movetime)
            end
        end, movetime)
    end

    local function initMapButton(i)
        local mapnode = CSResourceMgr.getNodeByName(resName, {"scrollview", "map", "p"..i, "p"..i.."_"})
        local btn     = nil
        if mapnode then
            btn = mapnode
        else
            btn = CSResourceMgr.getNodeByName(resName, {"scrollview", "map", "p"..i}) 
        end

        local btnScaleX = btn:getScaleX()
        local btnScaleY = btn:getScaleY()
        CSResourceMgr.buttonEventBindingByNode(btn, function()

                transition.stopTarget(btn)
                CocosModuleMgr.lightenNode(btn, 0) 
                local sequence = transition.sequence({
                        cc.ScaleTo:create(0.15, btnScaleX*1.05, btnScaleY*0.9),
                        cc.ScaleTo:create(0.1, btnScaleX*0.95, btnScaleY*1.12),
                        cc.ScaleTo:create(0.15, btnScaleX, btnScaleY*0.94),
                        cc.ScaleTo:create(0.1, btnScaleX, btnScaleY), 
                    })
                btn:performWithDelay(function()
                        CocosModuleMgr.lightenNode(btn, 0.5)
                    end, 0.15)
                btn:performWithDelay(function()
                    CocosModuleMgr.lightenNode(btn, 0)
                end, 0.25)
                btn:runAction(sequence) 
        end,function()  
            curPointID = i 
            local curPointID_p = CSResourceMgr.getNodeByName(resName, "p"..curPointID)
            playerAni:setPosition(curPointID_p:getPositionX(),curPointID_p:getPositionY())
            if curPointID == i then 
                expeditionalViewMgr.checkEvents(curPointID)
                print("已经在该点上了~~")
                return 
            end 
            if not expeditionalViewMgr.isMovePlay then   --移动代码
                -- expeditionalViewMgr.isMovePlay = true
                -- local routTbl = expeditionalViewMgr.searchRoutine(i)
                -- moveTo(routTbl,true,i)  
                
            else 
                -- isChangeRoutine = true
            end
        end)
        btn:zorder(1)
        btn:setSwallowTouches(false)
    end

    local mapPointVec = ExpeditionalInfo:getMapPoints(mapID)
    local battleIndex = 1
    local isEnoughHp  = false
    local openPID     = 1000
    
    for key,var in pairs(mapPointVec) do 
        if expeditiondata.currentSchedule == var.pparam then
            curPointID = key
        end
        
        local pointNode = CSResourceMgr.getNodeByName(resName, {"scrollview", "map", "p"..key})
        if var.ptype == expeditionalViewMgr.POINT_TYPE_HIDE then
            pointNode:hide()
        elseif var.ptype == expeditionalViewMgr.POINT_TYPE_BATTLE then
            local listTbl = clone(battleInfo.battlelist[battleIndex]) 
            local monsInfo = ExpeditionalInfo:getExpeditionMonsterInfoConfigById(listTbl.monsterID)
            local  btn     = CSResourceMgr.getNodeByName(resName, {"scrollview", "map", "p"..key, "p"..key.."_"})
            local petPaSkills = {}
            for key,var in pairs(monsInfo["paSkills"]) do
                petPaSkills[key] = {paSkillID = var,paSkillType= 1} 
            end
            local Pet = {monster = monsInfo,level = monsInfo.level,pokeID = monsInfo.petnumber,
            skills = {monsInfo.skill1[1],monsInfo.skill2[1],monsInfo.skill3[1],monsInfo.skill4},paSkills = petPaSkills,
            star = monsInfo.petStar,Stage = monsInfo.petStage,name = monsInfo.number,hp = listTbl.hp,hpmax = monsInfo.maxHP,skin = monsInfo.skin}
            battleInfo[key] = {}
            battleInfo[key].pet = Pet
            battleInfo[key].info = listTbl
            battleInfo[key].PointValue = var

            if var.pname ~= "nil" then
                if var.pparam <= expeditiondata.currentSchedule then  
                    local finishRes = CocosModuleMgr.getWordImage("rw_yiwancheng.png")
                    local finishSp  = display.newSprite(finishRes) 
                    finishSp:addTo(btn)
                    finishSp:setPosition(btn:getContentSize().width/2,btn:getContentSize().height/2) 
                end 

                local mapName  = display.newTTFLabel({ 
                    font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
                    text = LuaSqlite.getLanguageByKey(var.pname),
                    size = 24, 
                    align = cc.TEXT_ALIGN_CENTER, 
                    color = cc.c3b(234, 254, 255)
                })
                mapName:enableOutline({r = 13,g = 47,b = 60, a = 255}, 2)
                mapName:addTo(btn)
                mapName:setPosition(btn:getContentSize().width/2,0) 
            end
            -- CSResourceMgr.setLabelString(sboard.res, "name", WorldMapInfo.getPointNameByID(WorldMapMgr.curMapID, id), 
        --     sboard.tag, {r=13,g=47,b=60,a=255})
        -- CSResourceMgr.setLabelColor(sboard.res, "name", {r=234,g=254,b=255,a=255}, sboard.tag)

            if not isEnoughHp and Pet.hp > 0 then
                openPID    = key
                isEnoughHp = true
            end   
            --解琐地图结点
            if key > openPID then
                CSResourceMgr.setButtonEnabledByNode(btn,false) 
                btn:setTouchEnabled(false)       
            end

            battleIndex = battleIndex + 1
        end  
        
        initMapButton(key) 
    end  

    local curMapButton = CSResourceMgr.getNodeByName(resName, "p"..curPointID)
    local parent = curMapButton:getParent()
    local nodePx = curMapButton:getPositionX()
    local nodePy = curMapButton:getPositionY()
    playerAni = PlayerAnimeMgr.createPlayer(parent, 
        {gender=CharInfo.getSex(), x=nodePx, y=nodePy, skin=CharInfo.getCurfashion()}, headTagStr)
    playerAni:setScale(WorldMapMgr.PLAYER_SCALE)
    playerAni:setLocalZOrder(3) 

    parent:performWithDelay(function() 
            checkScroll(curPointID,0)
        end, 0.1)
    expeditionalViewMgr.easeUI()  
end

function expeditionalViewMgr.sendLotteryNet()
    NetInterface.sendWithBlock("GC_GetPointLotteryData_Ack", function()
            local ExpeditionSend = require("src.Net.Send.ExpeditionSend")
            ExpeditionSend.sendCG_GetPointLotteryData_Req() 
        end, function()
            expeditionalViewMgr.createScoreReward()
        end, function(code)
            StandardTipsMgr.show(1,"GC_GetPointLotteryData_Ack failed code="..code)
        end) 
end

function expeditionalViewMgr.setRollIndex(index)
    cur_R_index = index + 1
end

function expeditionalViewMgr.createScoreReward()
    helpBtn:hide()
    local function createBK()
        local res   = "Pet/Formation/FormationBGNew.csb"
        layer_BK = CSResourceMgr.createRes(SceneMgr.getRunningScene, res)
        CSResourceMgr.setRelativePosition(res, 320, 480, nil)
        layer_BK:zorder(score_zorder)
    end
    local function createAward()
        local resName = resName_scoreReward
        local layer  = CSResourceMgr.createRes(SceneMgr.getRunningScene, resName)
        local db_A   = CSResourceMgr.getNodeByName(resName, "db_A") 
        db_A:hide()
        local expeditiondata = expeditionalViewMgr.expedition:getExpeditionData()
        CSResourceMgr.setRelativePosition(resName, 320, 480)  
        layer:zorder(score_zorder+1)
        isShowLotter = true
        local LotteryInfo = ExpeditionalInfo:getExpeditionLotteryInfoById(expeditiondata.level)
        local awardList   = {}
        local awardType   = {}
        local gridAni     = nil

        StatusBarMgr.refreshExpeditionScoreInRoll()
        for i = 1,24 do
            local element = ItemInfo.getAwardElementInfoById(LotteryInfo.lotteryAwardList[i].awardID)
            local item    = nil
            local r  = CSResourceMgr.getNodeByName(resName, "r_"..i) 
            local posx,posy = r:getPosition()
            r:hide()
            r:setScale(0.9,0.9)
            reward_lights[i] = r

            if element then 
                if element.elementType ==3 then
                    item = ItemInfo.getItemIconById(element.elementID,
                         LotteryInfo.lotteryAwardList[i].awardCount, nil, true)  
                    item:setPosition(posx,posy) 
                    item:addTo(layer) 
                    item:zorder(10)
                    item:setScale(0.55,0.55) 
                    local itemname = CSResourceMgr.seekNodeByName(item,"name")
                    itemname:hide()
                elseif element.elementType==5 then
                    item = ItemInfo.getPetIconById2(element.elementID, LotteryInfo.lotteryAwardList[i].awardCount, 
                        nil, nil, nil)
                    item:setPosition(posx,posy) 
                    item:addTo(layer) 
                    item:zorder(10)
                    item:setScale(0.55,0.55) 
                    local itemname = CSResourceMgr.seekNodeByName(item,"name") 
                    itemname:hide()
                else
                    item = ItemInfo.getItemIconById(ItemInfo.AWARD[element.elementType],
                         LotteryInfo.lotteryAwardList[i].awardCount, nil, true) 
                    item:setPosition(posx,posy) 
                    item:addTo(layer) 
                    item:zorder(10)
                    item:setScale(0.55,0.55) 
                    local itemname = CSResourceMgr.seekNodeByName(item,"name")
                    itemname:hide()
                end
                CSResourceMgr.clickEventBindingByNode(item, function()
                    if element.elementType == Proto.AET_ITEM then
                        ItemInfoViewMgr.show({id = element.elementID,type = 1}, false)
                    -- elseif element.elementType == Proto.AET_PET then
                    --     PetInfoViewMgr.show(SceneMgr.getRunningScene, itemInfo.elementID)
                    else
                        ItemInfoViewMgr.show({id = ItemInfo.AWARD[element.elementType],type = 1}, false) 
                    end
                end)
                awardList[i] = {{element.elementID,LotteryInfo.lotteryAwardList[i].awardCount}}
                awardType[i] = element.elementType
            end
            
        end
        reward_lights[cur_R_index]:show() 
        local tropBtn   = CSResourceMgr.getNodeByName(resName, "tropBtn")
        local title_txt =  CSResourceMgr.getNodeByName(resName, "title_txt")
        local showBtn   =  CSResourceMgr.getNodeByName(resName, "showBtn")
        local tropBtnLabel = tropBtn:getTitleRenderer()
        local showBtnLabel = showBtn:getTitleRenderer()
        local showBtnStr   = showBtnLabel:getString()
        local title_txtStr = title_txt:getString()
        local tropBtnLabelStr = tropBtnLabel:getString()
        CSResourceMgr.setButtonStringByNode(tropBtn, tropBtnLabelStr)
        CSResourceMgr.setButtonStringByNode(showBtn, showBtnStr)
        showBtnLabel:setPositionY(showBtnLabel:getPositionY()-3)
        tropBtnLabel:enableOutline({r=164,g=86,b=1,a=255}, 2) 
        showBtnLabel:enableOutline({r=0,g=0,b=0,a=255}, 1)
        title_txt:enableOutline({r=0,g=0,b=1,a=255}, 2)
        tropBtnLabel:setPosition(tropBtnLabel:getPositionX(),tropBtnLabel:getPositionY()+6)
        showBtnLabel:setPosition(showBtnLabel:getPositionX(),showBtnLabel:getPositionY()+6)
        -- tropBtnLabel:setString(LuaSqlite.getLanguageByKey(tropBtnLabelStr))
        -- showBtnLabel:setString(LuaSqlite.getLanguageByKey(showBtnStr))
        
        -- title_txt:setString(LuaSqlite.getLanguageByKey(title_txtStr))
        CSResourceMgr.setLabelStringByNode(title_txt,title_txtStr)
        title_txt:setTextColor({r=165,g=243,b=255,a=255})

        CSResourceMgr.clickEventBindingByNode(showBtn, function() 
                    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "expedition27",function()end) 
                end, 3)

        CSResourceMgr.clickEventBindingByNode(tropBtn, function() 
                    
                    local topBarRes = "Charactor/TopInfoArena.csb"
                    local closeBtn = CSResourceMgr.getNodeByName(topBarRes, "close")
                    BattleFuncMgr.setNodeGray(tropBtn,false)
                    BattleFuncMgr.setNodeGray(closeBtn,false) 
                    tropBtn:setTouchEnabled(false)
                    closeBtn:setTouchEnabled(false)
                    if expeditionalViewMgr.expedition:getDropUnusedCount() <= 0 then
                        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "expedition26",function()
                                BattleFuncMgr.setNodeGray(tropBtn,true)
                                BattleFuncMgr.setNodeGray(closeBtn,true) 
                                tropBtn:setTouchEnabled(true)
                                closeBtn:setTouchEnabled(true)
                            end) 

                        return 
                    end
                    local res = "Gaf/effect/griddle.gaf"
                    if gridAni then
                        gridAni:removeFromParent() 
                        gridAni = nil
                    end
                    display.addImageAsync(string.gsub(res,"gaf","png"),function() 
                        gridAni = BattleFuncMgr.createGafAni(res,layer,0.5,-0.5,320,480)
                        gridAni:zorder(100)
                        local function griddleRun()
                            if not isShowLotter then
                                return  
                            end
                            BattleFuncMgr.playGafAniWithSequenceAndCallBack(gridAni,"Play",false,function()
                                if roll_stepNum == 0 then
                                    griddleRun()
                                else
                                    BattleFuncMgr.playGafAniWithSequenceAndCallBack(gridAni,"E"..roll_stepNum,false,function()
                                            expeditionalViewMgr.tropRun(roll_stepNum,awardList,awardType) 
                                            roll_stepNum = 0 
                                        end)
                                end
                            end)
                        end
                        griddleRun()
                    end)
                    NetInterface.sendWithBlock("GC_RollDice_Ack", function()
                        local ExpeditionSend = require("src.Net.Send.ExpeditionSend")
                        ExpeditionSend.sendCG_RollDice_Req() 
                    end, function()
                        expeditionalViewMgr.expedition:setUseCount()
                         
                        StatusBarMgr.refreshExpeditionScoreInRoll()
                    end, function(code)
                        BattleFuncMgr.setNodeGray(tropBtn,true)
                        BattleFuncMgr.setNodeGray(closeBtn,true) 
                        tropBtn:setTouchEnabled(true)
                        closeBtn:setTouchEnabled(true)
                        StandardTipsMgr.show(1,"GC_RollDice_Ack failed code="..code)
                    end) 
                end, 3)
        CocosModuleMgr.showUIAnimation(layer, "down")
    end
    local funcs = {}
    funcs[1] = createBK 
    funcs[2] = createAward 
    UnblockLoader.load(funcs, "ExpedtionalAward")
end

function expeditionalViewMgr.setRollstepNum(num)
    roll_stepNum = num
end

function expeditionalViewMgr.tropRun(trop_num,awardList,awardType) 
    local tropBtn = CSResourceMgr.getNodeByName(resName_scoreReward, "tropBtn")
    local count = 0 
    local topBarRes = "Charactor/TopInfoArena.csb"
    local closeBtn = CSResourceMgr.getNodeByName(topBarRes, "close")

    local function tropRun() 
        reward_lights[cur_R_index]:show()
        SceneMgr.getRunningScene:performWithDelay(function()
                count = count + 1
                if count > trop_num then
                    BattleFuncMgr.setNodeGray(tropBtn,true)
                    tropBtn:setTouchEnabled(true)
                    BattleFuncMgr.setNodeGray(closeBtn,true)
                    closeBtn:setTouchEnabled(true)
                    if awardList[cur_R_index][1][1] == 0 then
                        awardList[cur_R_index][1][1] = ItemInfo.AWARD[awardType[cur_R_index]]
                    end
                    AwardsListMgr.show(SceneMgr.getRunningScene,awardList[cur_R_index]) 
                    expeditionalViewMgr.checkRedPoint() 
                    return
                end
                reward_lights[cur_R_index]:hide()
                cur_R_index = cur_R_index + 1
                
                if cur_R_index > 24 then 
                    cur_R_index = 1
                end
                local btnScaleX = reward_lights[cur_R_index]:getScaleX()
                local btnScaleY = reward_lights[cur_R_index]:getScaleY()
                local sequence = transition.sequence({
                        cc.ScaleTo:create(0.5/trop_num/4, btnScaleX*1.05, btnScaleY*1.05),
                        cc.ScaleTo:create(0.5/trop_num/4, btnScaleX*1.12, btnScaleY*1.12),
                        cc.ScaleTo:create(0.5/trop_num/4, btnScaleX*0.94, btnScaleY*0.94),
                        cc.ScaleTo:create(0.5/trop_num/4, btnScaleX, btnScaleY), 
                    })
                reward_lights[cur_R_index]:runAction(sequence) 
                reward_lights[cur_R_index]:show()
                tropRun(cur_R_index)
            end, 0.5/trop_num)
    end
    tropRun()
end

function expeditionalViewMgr.buyPointTime()
    local data = expeditionalViewMgr.expedition:getExpeditionData()
    -- for key,var in pairs(data.mapList) do
        -- local questInfo = expeditionalViewMgr.expedition:getExpeditionQuestInfoById(id)
    local maxBuyCount =  expeditionalViewMgr.expedition:getmaxBuyCount()
    local buyCount = expeditionalViewMgr.expedition:getbuyCount() + 1
    -- end
    local diamond   = expeditionalViewMgr.expedition:getLotteryBuyCountInfoById(buyCount).costCount
    local str    =   string.gsub(LuaSqlite.getLanguageByKey("expedition22"),"<1>",diamond)
    local dialogLimt = 1
    str  =   string.gsub(str,"<2>",maxBuyCount)
    if maxBuyCount > 0 then 
        dialogLimt = 2
        
    else
        str = LuaSqlite.getLanguageByKey("expedition24") 
    end
    
    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, dialogLimt, str, function()
                if dialogLimt == 2 then
                    NetInterface.sendWithBlock("GC_BuyRollCount_Ack", function()
                        local ExpeditionSend = require("src.Net.Send.ExpeditionSend")
                        ExpeditionSend.sendCG_BuyRollCount_Req({})  
                    end, function()
                        expeditionalViewMgr.expedition:setbuyCount(buyCount) 
                        maxBuyCount = maxBuyCount - 1
                        expeditionalViewMgr.expedition:setmaxBuyCount(maxBuyCount) 
                        expeditionalViewMgr.expedition:setPoint()
                        StatusBarMgr.refreshExpeditionScoreInRoll()
                        expeditionalViewMgr.checkRedPoint()

                    end, function(code)
                        StandardTipsMgr.show(1,"GC_GetExpeditionData_Ack failed code="..code)
                    end) 
                end
            end)

end

function expeditionalViewMgr.checkEvents(pid)
    local mapID      = 1
    local pointsInfo = ExpeditionalInfo:getMapPoints(mapID)
    local ptype      = pointsInfo[pid].ptype

    if ptype == expeditionalViewMgr.POINT_TYPE_BATTLE then
        expeditionalViewMgr.OpenBattle(battleInfo[pid].pet,battleInfo[pid].info.quests,battleInfo[pid].PointValue) 
    end
end

-- function expeditionalViewMgr.addMissionUI(allQuests,finishQuests)
--     local resName = "Searching/MissionUI/starBoard.csb"
--     local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, resName)
--     layer:zorder(100)
--     CocosModuleMgr.setRelativePosition(layer, 320, 480)

--     local adhLabel = CSResourceMgr.getNodeByName(resName,{"db","banner","title"})
--     CSResourceMgr.setLabelStringByNode(adhLabel,"expedition31") 
--     adhLabel:enableOutline({r=153,g=0,b=0,a=255}, 2) 
--     adhLabel:setTextColor({r=255,g=255,b=204,a=255})
--     adhLabel:setFontSize(32)
--     CSResourceMgr.setLabelString(resName,{"db","tip"},"advtext9")

--     CSResourceMgr.clickEventBinding(resName,"block",function()
--             CSResourceMgr.removeCSObjectByTag(resName) 
--         end, "", true)

--     CSResourceMgr.getNodeByName(resName, {"db","diban","msboard","list"}):removeAllItems()

--     local lastFinshTbl = {}
--     for key,var in pairs(allQuests) do
--         local ishave = false
--         for k,v in pairs(finishQuests) do
--             if v == var then
--                 ishave = true
--             end
--         end

--         if ishave then
--             lastFinshTbl[key] = var
--         else
--             lastFinshTbl[key] = nil
--         end

--     end

--     for key,var in pairs(allQuests) do
--         -- if var.desc == nil then 
--         --     print("ADV_ERROR: Check if [Fbmb.txt] is correct")
--         --     break 
--         -- end
--         -- print(var.desc, LuaSqlite.getLanguageByKey(var.desc))
--         local questInfo = ExpeditionalInfo:getExpeditionQuestInfoById(var)
-- local desc  = LuaSqlite.getLanguageByKey(questInfo.clientDisplay)
--         local color = {r=71, g=96, b=103, a=255}
--         
--         CSResourceMgr.setLabelString(resName, {"example", "desc"}, desc, "", {r=218,g=232,b=232,a=255,w=2})

--         local list = CSResourceMgr.getNodeByName(resName, {"db","diban","msboard","list"})
--         local item = CSResourceMgr.getNodeByName(resName, "example"):clone()
--         local text = CSResourceMgr.seekNodeByName(item, "desc")
--         local star = CSResourceMgr.seekNodeByName(item, "star")
--         text:setTextColor(color)
--         --text:setFontSize(36)  --cocos studio中设置统一字号 
--         item:setVisible(true)
--         CSResourceMgr.getNodeByName(resName, {"db","diban","msboard","list"}):pushBackCustomItem(item)
--         if lastFinshTbl[key] then 
--             star:loadTexture("Searching/Common/cj_xing0001.png") 
--         end
--     end
-- end

function expeditionalViewMgr.easeUI()
    local layer = CSResourceMgr.createRes(scene, resName_battle)
    layer:hide()
    CSResourceMgr.getNodeByName(resName_battle, "panel_2"):setVisible(true)
    expeditionalViewMgr.showPetsPage()
    CSResourceMgr.getNodeByName(resName_battle, "btn_battle"):setTouchEnabled(false) 
end

function expeditionalViewMgr.OpenBattle(pet,quest,PointValue)
    local resName = resName_battle
    local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, resName)
    local expeditiondata = expeditionalViewMgr.expedition:getExpeditionData()
    layer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT - 2)  
    CSResourceMgr.setFullScreen(resName)
    CSResourceMgr.setRelativePosition(resName, 320, 480)
    local pic_b1 = CSResourceMgr.getNodeByName(resName, "pic_b1")
    local pic_b2 = CSResourceMgr.getNodeByName(resName, "pic_b2")
    local pic_bg5   = CSResourceMgr.getNodeByName(resName, "pic_bg5")
    local panel     = CSResourceMgr.getNodeByName(resName, "panel")

    pic_b2:setAnchorPoint(0.5,1.0)
    pic_b2:setPosition(320,882)
    pic_b2:setContentSize(560,850)
    pic_b1:setContentSize(590,910)

    local btn_role = CSResourceMgr.getNodeByName(resName, "btn_role")
    btn_role:setPosition(480,380) 
    btn_role:zorder(20)
    local txt_role = CSResourceMgr.getNodeByName(resName, "txt_role")
    
    txt_role:setString("")
    txt_role:enableOutline(outlineColor[1], 2)

    -- local btn_Task     = btn_role:clone()   
    -- btn_Task:addTo(pic_bg5)
    -- btn_Task:setPosition(2*28+390,488) 
    -- local emptyRes = "empty.png" 
    -- CSResourceMgr.setButtonTextureByNode(btn_Task,emptyRes,emptyRes,emptyRes)
    CSResourceMgr.getNodeByName(resName, "pic_res"):hide()
    -- txt_role:setString(LuaSqlite.getLanguageByKey("expedition11"))
    CSResourceMgr.setLabelStringByNode(txt_role,"expedition11")
    if not pet.skin then
        pet.skin = 1 
    end

    local txt_title     = CSResourceMgr.getNodeByName(resName, "txt_title")
    local txt_title_str = LuaSqlite.getLanguageByKey("expedition1")
    -- txt_title:setString(txt_title_str)
    CSResourceMgr.setLabelStringByNode(txt_title,"expedition1")
    txt_title:enableOutline(outlineColor[1], 2)
    txt_title:setTextColor(labelColor[1])

    local txt_res_title = CSResourceMgr.getNodeByName(resName, "txt_res_title")
    local rewardStr = LuaSqlite.getLanguageByKey("expedition4")
    -- txt_res_title:setString(rewardStr)
    CSResourceMgr.setLabelStringByNode(txt_res_title,"expedition4")
    txt_res_title:enableOutline({r = 0,g = 0,b = 0, a = 255}, 2)
    txt_res_title:setTextColor(labelColor[4])
    txt_res_title:setPosition(180,315)

    local tower_str = LuaSqlite.getLanguageByKey("expeditionfloor"..PointValue.pparam)
    local tower_txt    = display.newTTFLabel({
            font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
            text = tower_str,
            size = 28, 
            align = cc.TEXT_ALIGN_CENTER, 
            color = cc.c3b(165, 243, 255)
        })
    tower_txt:enableOutline({r = 0,g = 0,b = 0, a = 255}, 2)
    tower_txt:addTo(layer)
    tower_txt:setPosition(320,377+395)   
    tower_txt:zorder(11) 

    local btn_challenge = CSResourceMgr.getNodeByName(resName, "btn_challenge")
    btn_challenge:setPosition(320,165) 
    local txt_challenge = CSResourceMgr.getNodeByName(resName, "txt_challenge")
    local challengeStr  = LuaSqlite.getLanguageByKey("expedition5")
    -- txt_challenge:setString(challengeStr) 
    CSResourceMgr.setLabelStringByNode(txt_challenge,"expedition5")
    txt_challenge:enableOutline({r = 0,g = 0,b = 0, a = 255}, 2)
    local txt_desc      = CSResourceMgr.getNodeByName(resName, "txt_desc")
    local tipsStr       = LuaSqlite.getLanguageByKey("expedition2")
    -- txt_desc:setString(tipsStr)
    CSResourceMgr.setLabelStringByNode(txt_desc,"expedition2")
    txt_desc:setPosition(320,70)
    txt_desc:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1)
    txt_desc:setTextColor(labelColor[5])

    
    local headDB_sp = cc.ui.UIImage.new("Activity/headBD.png")
    headDB_sp:align(display.LEFT_TOP, 10+60, 420+340)
    headDB_sp:addTo(panel) 
    headDB_sp:zorder(10)

    local hp_spri     = display.newSprite("Activity/hp_progress.png")
    local hp_Progress = cc.ProgressTimer:create(hp_spri)
    local hp_percent  = pet.hp*100/pet.hpmax
    hp_Progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    hp_Progress:setMidpoint(cc.p(0,0.5))
    hp_Progress:setBarChangeRate(cc.p(1.0,0))
    hp_Progress:setPercentage(hp_percent) 
    hp_Progress:addTo(headDB_sp)
    hp_Progress:setPosition(276,46)
    hp_Progress:zorder(10)

    local starDB  = {} 
    local stars   = {}
    local limitStar    = #quest
    local finishQuests = expeditiondata.finishQuest[PointValue.pparam]

    if not finishQuests then
        expeditiondata.finishQuest[PointValue.pparam] = {} 
        expeditiondata.finishQuest[PointValue.pparam].quests = {}
    end

    for starID = 1,limitStar do 
        local emptyHRes = "Searching/Common/cj_xing0002.png"
        local fullHRes  = "Searching/Common/cj_xing0001.png"
        if finishQuests then 
            if starID > #finishQuests.quests then
                starDB[starID] = cc.ui.UIImage.new(emptyHRes)
            else
                starDB[starID] = cc.ui.UIImage.new(fullHRes)
            end
        else
            starDB[starID] = cc.ui.UIImage.new(emptyHRes) 
        end
        
        starDB[starID]:addTo(pic_bg5)
        starDB[starID]:setPosition((starID-1)*40+20,480) 
        starDB[starID]:setScale(0.5,0.5) 
    end

    local txt_time_tilte = CSResourceMgr.getNodeByName(resName, "txt_time_tilte")
    local time_tilte_str = LuaSqlite.getLanguageByKey("expedition31")..":"
    -- txt_time_tilte:setString(time_tilte_str) 
    CSResourceMgr.setLabelStringByNode(txt_time_tilte,time_tilte_str)
    txt_time_tilte:enableOutline({r = 0,g = 0,b = 0, a = 255}, 2)
    txt_time_tilte:setTextColor(labelColor[2])
    txt_time_tilte:setPositionX(txt_time_tilte:getPositionX()+40)   
    txt_time_tilte:setAnchorPoint(0,0.5) 
    local txt_time_tilte_Size = txt_time_tilte:getContentSize()

    local questInfo = ExpeditionalInfo:getExpeditionQuestInfoById(quest[1]) 
    local desc  = LuaSqlite.getLanguageByKey(questInfo.clientDisplay) 
    local task_str = LuaSqlite.getLanguageByKey(desc) -- 任务 
    local task_txt    = display.newTTFLabel({
            font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
            text = task_str,
            size = 23,
            align = cc.TEXT_ALIGN_CENTER, 
            color = cc.c3b(255, 255, 204) 
        })
    task_txt:enableOutline({r = 0,g = 0,b = 0, a = 255}, 2)
    task_txt:addTo(pic_bg5)
    task_txt:setPosition(txt_time_tilte_Size.width+80,500)     
    task_txt:zorder(11)
    task_txt:setAnchorPoint(0,0.5)  

    local txt_time  = CSResourceMgr.getNodeByName(resName, "txt_time")
--    local sec       = expeditionalViewMgr.getRestSecond()

    -- CocosModuleMgr.setTimeLabelCountDown(txt_time, sec, function()
    --         -- DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, "expedition30", function()
    --         -- end)
    --     end, secCallback)
    local pic_atk       = CSResourceMgr.getNodeByName(resName, "pic_atk")
    local txt_atk       = CSResourceMgr.getNodeByName(resName, "txt_atk")
    local pic_atk_X     = 300
    pic_atk:setPosition(pic_atk_X,690)
    txt_atk:setPosition(pic_atk_X+20,690)
    local petInfo = PokemonInfo.getPokemonInfoByID(pet.pokeID)
    local atk   = BattleBasicValueCalc.calcAct(petInfo,pet.star,0,0,
            0,0,0,pet.Stage,pet.level,pet.skin)
    atk = atk*pet.monster.amendmentATK/1000
    local def   = BattleBasicValueCalc.calcDef(petInfo,pet.star,0,0,
            0,0,0,pet.Stage,pet.level,pet.skin)
    def = def*pet.monster.amendmentDEF/1000
    local satk  = BattleBasicValueCalc.calcSpeAct(petInfo,pet.star,0,0,
            0,0,0,pet.Stage,pet.level,pet.skin)
    satk = satk*pet.monster.amendmentSATK/1000
    local sdef  = BattleBasicValueCalc.calcSpeDef(petInfo,pet.star,0,0,
            0,0,0,pet.Stage,pet.level,pet.skin)
    sdef = sdef*pet.monster.amendmentSDEF/1000
    local spd   = BattleBasicValueCalc.calcSpeed(petInfo,pet.star,0,0,
            0,0,0,pet.Stage,pet.level,pet.skin)  
    spd = spd*pet.monster.amendmentSPD/1000
    local FC    = BattleBasicValueCalc.calcFC(pet.level,pet.hpmax,atk,def,satk,sdef,spd)      -- 计算战斗力公式
    txt_atk:setString(FC)
    txt_atk:enableOutline({r = 0,g = 0,b = 0, a = 255}, 2)
    local pic_boss     = CSResourceMgr.getNodeByName(resName, "pic_boss")
    pic_boss:setPositionY(406)
    local aniRes = PokemonInfo.getPokemonResByID(pet.pokeID)
    local aniAni = AnimationMgr.createAni(pic_boss, aniRes, 0, 0) 
    AnimationMgr.playAni(aniRes, "idle", true)
    aniAni:setScale(0.8)

    AnimationMgr.setSkin(aniRes, pet.skin)

    local petRes  = PokemonInfo.getPokemonIconByID(pet.pokeID)
    local petSpri = display.newSprite(petRes)
    petSpri:addTo(panel) 
    petSpri:setPosition(56+60,377+340)
    petSpri:setScale(0.45,0.45)
    petSpri:zorder(11)
    pet.name = LuaSqlite.getLanguageByKey(pet.name)
    local petname_txt    = display.newTTFLabel({
            font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
            text = pet.name,
            size = 20, 
            align = cc.TEXT_ALIGN_LEFT, 
            color = cc.c3b(235, 0, 3)
        })
    petname_txt:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1)
    petname_txt:addTo(panel)
    petname_txt:setPosition(56+95,377+320)
    petname_txt:setAnchorPoint(0,0.5) 
    local btn_close = CSResourceMgr.getNodeByName(resName, "btn_close")

    CSResourceMgr.clickEventBindingByNode(btn_close, function()
                expeditionalViewMgr.hidePetsPage() 
                CSResourceMgr.removeCSObjectByTag(resName)
            end, 3)

    if pet.hp <= 0 then
        btn_challenge:hide()
        -- local stop_txt    = display.newTTFLabel({
        --     font = "cuyuan_GBK.ttf",
        --     text = LuaSqlite.getLanguageByKey("expedition18"),
        --     size = 40, 
        --     align = cc.TEXT_ALIGN_CENTER, 
        --     color = cc.c3b(255, 0, 0)
        -- })
        -- stop_txt:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1) 
        local finishRes = CocosModuleMgr.getWordImage("rw_yiwancheng.png")
        local finishSp  = display.newSprite(finishRes) 
        finishSp:addTo(panel)
        finishSp:setPosition(320,480) 
        finishSp:zorder(10)
    else 
        expeditionalViewMgr.showPetsPage(pet,quest,PointValue)
    end
    local listH = cc.ui.UIListView.new {
        bgColor = nil,
        -- bg = "sunset.png",
        viewRect = cc.rect(0, 0, 450, 150),
        direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
        } 
    listH:onTouch(handler(layer,expeditionalViewTouchListener))
    listH:addTo(panel)
    listH:setPosition(90,190)  
    listH:zorder(100)

    local AwardList = expeditionalViewMgr.getAwardList(PointValue) 
    for key,var in pairs(AwardList)  do
        local content = ItemInfo.getItemIconById(var, nil, nil, true) 
        local item = listH:newItem()
        content:setScale(0.5,0.5)
        item:setItemSize(content:getContentSize().width-50, content:getContentSize().height)

        item:addContent(content) 
        listH:addItem(item)

        CSResourceMgr.clickEventBindingByNode(content, function() 
            ItemInfoViewMgr.show({id = var,type = 1}, false)        
        end)

    end 
    listH:reload() 
     
    CSResourceMgr.clickEventBindingByNode(btn_challenge, function()
                    local panel2 = CSResourceMgr.getNodeByName(resName_battle, "panel_2")
                    local btnBG2 = CSResourceMgr.getNodeByName(resName_battle, "btn_bg2")
                    panel2:setVisible(true)
                    btnBG2:setVisible(true)
                    CocosModuleMgr.showUIAnimation(panel2, "down") 
            end, 3)
    CSResourceMgr.clickEventBindingByNode(btn_role, function()
                expeditionalViewMgr.showPetSkillInfo(pet.skills,pet.paSkills)
            end, 3)
end 

function expeditionalViewMgr.showPetsPage(enemy,quest,PointValue) 
    local panel2 = CSResourceMgr.getNodeByName(resName_battle, "panel_2")
    local btnBG2 = CSResourceMgr.getNodeByName(resName_battle, "btn_bg2")
    local expeditionRow    = 4
    local expeditionLine   = 6
    local selectedPetNode  = false
    local selectedPetIndex = 0
    local expeditiondata = expeditionalViewMgr.expedition:getExpeditionData()

    panel2:zorder(12) 
    local function loadCSB()
        local btnClose = CSResourceMgr.getNodeByName(resName_battle, "btn_close2")
        CSResourceMgr.clickEventBindingByNode(btnClose, function() 
            -- expeditionalViewMgr.hidePetsPage()
            panel2:setVisible(false)
            btnBG2:setVisible(false) 
        end)
    end

    local function getPetList()
        local petList = {}
        local tempPetList = {}
        local allPets = expeditionalViewMgr.pets
        table.sort(allPets, function(a, b) 
            return a.fc > b.fc
        end)  
        for k,v in pairs(allPets) do
            v.haveBattle = false
            for k1,v1 in pairs(expeditionalViewMgr.pets) do
                if v.hp <= 0 then  
                    v.haveBattle = true
                end
            end
            for k2,v2 in pairs(expeditiondata.usedPets) do 
                if v.objID == v2 then
                    v.haveBattle = true
                end
            end
            table.insert(tempPetList, v)
        end 
        for k,v in pairs(tempPetList) do
            if v.haveBattle == false then
                table.insert(petList, v)
            end
        end
        for k,v in pairs(tempPetList) do
            if v.haveBattle == true then
                table.insert(petList, v)
            end
        end
        return petList
    end

    local function loadPetList()
        local list = CSResourceMgr.getNodeByName(resName_battle, "list")
        local panel = CSResourceMgr.getNodeByName(resName_battle, "parent")
        local hook = CSResourceMgr.getNodeByName(resName_battle, {"parent","hook"})
        local black = CSResourceMgr.getNodeByName(resName_battle, {"parent","pic_black"})
        local fc = CSResourceMgr.getNodeByName(resName_battle, {"parent","pic_fc"})
        local showPets = getPetList()
        local totalLine = math.ceil(#showPets / expeditionRow)
        local showCnt = expeditionRow * expeditionLine
        local showLine = math.min(expeditionLine, totalLine)
        local diffX = 124
        local panelNodes = {}
        local petNodesPosY = 100
        local panelHeight = 210
        panel:setContentSize(516,panelHeight)
        for i = 1, showLine do
            panelNodes[i] = panel:clone()
            list:pushBackCustomItem(panelNodes[i])
        end
        local index = 1
        for k,v in pairs(showPets) do
            if index > showCnt then break end
            local line = math.ceil(index / expeditionRow)
            local row = index % expeditionRow == 0 and expeditionRow or index % expeditionRow
            local petNode = BattleFuncMgr.startCreatePetCard(v, 1, true)

            if v.skin ~= 0 then
                CSResourceMgr.setLabelColorByNode(petNode.level, {r=96,g=255,b=0,a=255}) 
            end
            petNodes[index] = petNode.button
            petNodes[index]:setVisible(true)
            petNodes[index]:setScale(1.3, 1.3)
            petNodes[index]:addTo(panelNodes[line])
            petNodes[index]:setPosition(petNodes[index]:getPositionX() + (row - 1) * diffX + 72, petNodesPosY)
            petNodes[index].sel = hook:clone()
            petNodes[index].sel:addTo(petNodes[index])
            petNodes[index].sel:setPosition(70,105)
            petNodes[index].sel:setScale(0.9) 

            -- petNode.str:setString(LuaSqlite.getLanguageByKey(v.name))  
            CSResourceMgr.setLabelStringByNode(petNode.str,v.name)
            petNode.str:setTextColor(PokemonInfo.COLOR[petNode.rarePoint]) 
            petNode.str:setPositionY(petNode.str:getPositionY()- 27)

            petNodes[index].black = black:clone()
            petNodes[index].black:addTo(petNodes[index])
            petNodes[index].black:setPosition(45,75)
            petNodes[index].black:setColor({r=0,g=0,b=0})
            petNodes[index].black:setOpacity(153)
            petNodes[index].black:setVisible(v.haveBattle)
            petNodes[index].black:setContentSize(94, 136)
            petNodes[index].black:setLocalZOrder(2)

            petNodes[index].fc = fc:clone()
            petNodes[index].fc:addTo(petNodes[index])
            petNodes[index].fc:setPosition(30,petNodesPosY+35) 
            petNodes[index].fc:setVisible(true)

            petNodes[index].objID = v.objID
            
            local labelFC = CSResourceMgr.seekNodeByName(petNodes[index].fc, "txt_fc")
            CSResourceMgr.setLabelStringByNode(labelFC, v.fc, outlineColor[1])

            if not panelNodes[line].button then
                panelNodes[line].button = {}
            end
            panelNodes[line].button[row] = petNodes[index]

            CSResourceMgr.clickEventBindingByNode(petNodes[index], function ()
                if v.haveBattle == true then
                    StandardTipsMgr.show(1, "expedition30")
                else
                    if selectedPetNode then
                        selectedPetNode.sel:setVisible(false)
                    end
                    panelNodes[line].button[row].sel:setVisible(true)
                    selectedPetNode = panelNodes[line].button[row]
                    expeditionalViewMgr.selectedPet = v
                end
            end, 3)
            index = index + 1
        end
        BattleFuncMgr.endCreatePetCard() 

        HighPerformList.makeHighPerFormVerticalList(list, expeditionLine, 0, expeditionRow, 200, panelHeight, showPets,
            function(item, currentIndex)
                local row = currentIndex % expeditionRow == 0 and expeditionRow or currentIndex % expeditionRow
                for i=1,expeditionRow do
                    if currentIndex + i - 1 <= #showPets then--防止越界 
                        item.button[i]:setVisible(true)
                        PetCommonListViewMgr.updateCard(showPets[currentIndex+i-1], item.button[i])
                        item.button[i].sel:setVisible(currentIndex + i - 1 == selectedPetIndex)
                        item.button[i].black:setVisible(showPets[currentIndex+i-1].haveBattle)
                        
                        local labelFC = CSResourceMgr.seekNodeByName(item.button[i].fc, "txt_fc")
                        CSResourceMgr.setLabelStringByNode(labelFC, showPets[currentIndex+i-1].fc, outlineColor[1])
                    else
                        item.button[i]:setVisible(false)
                    end
                    CSResourceMgr.clickEventBindingByNode(item.button[i], function ()
                        if showPets[currentIndex+i-1].haveBattle == true then
                            StandardTipsMgr.show(1, "expedition30") 
                        else
                            if selectedPetNode then
                                selectedPetNode.sel:setVisible(false)
                            end
                            item.button[i].sel:setVisible(true)
                            selectedPetIndex = currentIndex + i - 1
                            selectedPetNode = item.button[i]
                            expeditionalViewMgr.selectedPet = showPets[currentIndex+i-1]
                        end
                    end,3)
                end
            end)
    end

    local function loadUI()
        local labelTitle = CSResourceMgr.getNodeByName(resName_battle, "txt_battle_title")
        local labelDesc = CSResourceMgr.getNodeByName(resName_battle, "txt_information")
        local btnBattle = CSResourceMgr.getNodeByName(resName_battle, "btn_battle")
        local labelBattle = CSResourceMgr.getNodeByName(resName_battle, "txt_battle")

        CSResourceMgr.setLabelStringByNode(labelTitle, "activity94", outlineColor[1])
        if expeditiondata.level >= Proto.EDT_NIGHTMARE then
            CSResourceMgr.setLabelStringByNode(labelDesc, "activity95", outlineColor[1])
        else
            CSResourceMgr.setLabelStringByNode(labelDesc, "expedition39", outlineColor[1]) 
        end
        
        CSResourceMgr.setLabelStringByNode(labelBattle, "activity96", outlineColor[1])

        CSResourceMgr.setLabelColorByNode(labelTitle, labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelDesc, labelColor[5])
        CSResourceMgr.setLabelColorByNode(labelBattle, labelColor[6])
        if enemy then
            CSResourceMgr.clickEventBindingByNode(btnBattle, function ()
                if PetEducationMgr.getTableLength(expeditionalViewMgr.selectedPet) > 0 then
                    local myPets = {}
                    local enemyPets = {}
                    myPets[OUTPETS]= {expeditionalViewMgr.selectedPet}
                    myPets[INPETS] = {}
                    enemyPets[OUTPETS]= {enemy}
                    enemyPets[INPETS] = {}
                    BattleMapMgr.setArenaBattle(myPets, enemyPets, function(detail) 
                        if expeditionalViewMgr.jump then
                            detail.result = PLAYER_WIN 
                            detail.me.hp[1] = 1000
                            detail.enemy.hp[1] = 0
                            detail.myDamage = 5000000
                        end

                        --发出战斗结果 
                        if detail.result == nil then 
                            print("战斗结果  error~~~~~~~~")
                        else

                            local sendQuests  = {}
                            local damage      = 0
                            local enemyHP = detail.enemy.hp[1]
                            if enemyHP < 0 then 
                                enemyHP = 0
                            end

                            if detail.myDamage then
                                damage = enemy.hp - enemyHP
                            end
                            print("造成的伤害为..........",damage)
                            print("enemyHP.........",enemyHP)
                            
							local function getAward()
                                local lastCount = 0
                                -- MapSeekerMgr.setSeekFunc(function()  
                                    BattlePVPMgr.startCalcTime(function() 
                                        lastCount = lastCount + 1
                                        if awardThings then 
                                            AwardsListMgr.show(SceneMgr.getRunningScene,awardThings)
                                            BattlePVPMgr.endCalcTime()
                                            awardThings = nil
                                        elseif lastCount > 20 then 
                                            BattlePVPMgr.endCalcTime() 
                                            awardThings = nil
                                        end
                                    end,0.3)
                                    -- end) 
                            end
                            local function checkQuest() 
                                local finishQuest = expeditionalViewMgr.expedition:checkQuestProgress(quest,PointValue.pparam)
                                for key,var in pairs(finishQuest) do
                                    if var[2] then
                                        sendQuests[#sendQuests+1] = var[2][1]
                                        expeditionalViewMgr.expedition:setPoint() 
                                        -- StatusBarMgr.refreshExpeditionScore() 
                                    end
                                end
                            end
                            if detail.result == PLAYER_WIN then
                                expeditiondata.currentSchedule = PointValue.pparam
                                checkQuest()
                                if expeditiondata.level >= Proto.EDT_NIGHTMARE then
                                    expeditiondata.usedPets[#expeditiondata.usedPets+1] = expeditionalViewMgr.selectedPet.objID
                                    detail.me.hp[1] = 0 
                                end
                                getAward()
                            else
                                if detail.result == PLAYER_EQUAL then 
                                    checkQuest()
                                    getAward()
                                end
                                detail.me.hp[1] = 0
                                expeditiondata.usedPets[#expeditiondata.usedPets+1] = expeditionalViewMgr.selectedPet.objID
                            end
                            expeditionalViewMgr.expedition:setBattleHp(PointValue.pparam,enemyHP)
                            battleInfo.battlelist[PointValue.pparam].hp = enemyHP
                            local objID = expeditionalViewMgr.selectedPet.objID
                            local hp    = detail.me.hp[1] 
                            local hpmax = expeditionalViewMgr.selectedPet.hpmax
                            if hp > hpmax then 
                                hp = hpmax
                            end 
                            for key,var in pairs(expeditionalViewMgr.pets) do
                                if var.objID == objID then
                                    expeditionalViewMgr.pets[key].hp = hp
                                    break
                                end
                            end
                            expeditionalViewMgr.sendSurviveBattleResult(hp,
                                expeditionalViewMgr.selectedPet.objID,damage,sendQuests)
                        end 
                        expeditionalViewMgr.selectedPet = {} 
                    end)
                    BattleCotroller.setEnterBattleScene(false) 
                else
                    --请先选择出战宠物
                    StandardTipsMgr.show(1, "activity97")
                end
            end)
        end
    end

    local funcTable = {loadCSB, loadPetList, loadUI}
    UnblockLoader.load(funcTable, "expeditionalViewMgr_SelectPetPage")
end

function expeditionalViewMgr.getAwardList(pointValue)
    local awardInfo = ExpeditionalInfo:getExpeditionInfoConfigById(pointValue.pparam)
    local expeditiondata = expeditionalViewMgr.expedition:getExpeditionData()
    if expeditiondata.level == 1 then
        return awardInfo.easyDisplay
    elseif expeditiondata.level == 2 then
        return awardInfo.normalDisplay
    elseif expeditiondata.level == 3 then
        return awardInfo.hardDisplay
    elseif expeditiondata.level == 4 then
        return awardInfo.nightmareDisplay
    elseif expeditiondata.level == 5 then
        return awardInfo.hellDisplay
    end
end

function expeditionalViewTouchListener(event)
    local listView = event.listView
    if "clicked" == event.name then
        if 3 == event.itemPos then
            listView:removeItem(event.item, true)
        else
            -- event.item:setItemSize(120, 80)
        end
    elseif "moved" == event.name then
        self.bListViewMove = true
    elseif "ended" == event.name then
        self.bListViewMove = false
    else
        print("event name:" .. event.name)
    end
end

function expeditionalViewMgr.hidePetsPage()
    UnblockLoader.cancel("expeditionalViewMgr_SelectPetPage")

    expeditionalViewMgr.selectedPet = {}
    local panel2 = CSResourceMgr.getNodeByName(resName_battle, "panel_2")
    panel2:setVisible(false)
    local btnBG2 = CSResourceMgr.getNodeByName(resName_battle, "btn_bg2")
    btnBG2:setVisible(false)

    UIStack.pop("expeditionalViewMgr_SelectPetPage") 
end

function expeditionalViewMgr.showPetSkillInfo(skills,petPaSkills)
    local BattleGetPetInfo = require("src.GameMgr.Battle.BattleGetPetInfo") 

    local passiveSkillBackGroundPath = {
        "UI/CommonFiles/skill_passive_base_blue_01.png",
        "UI/CommonFiles/skill_passive_base_violet_01.png",
        "UI/CommonFiles/skill_passive_base_yellow_01.png",
    }

    local resName = "Activity/showExpeditionSKills.csb" 
    local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, resName)
    CSResourceMgr.setRelativePosition(resName, 320, 480)
    layer:zorder(CocosModuleMgr.ZORDER_FLOAT - 1)

    local skillNodes = {}
    local paSkillNodes = {}

    local mainSkillTxt = CSResourceMgr.getNodeByName(resName, "mainSkillTxt")
    local paSkillTxt   = CSResourceMgr.getNodeByName(resName, "paSkillTxt")
    local mainSkillStr = mainSkillTxt:getString()
    local paSkillTxtStr = paSkillTxt:getString()
    local sure = CSResourceMgr.getNodeByName(resName, "sure")
    local sureTxt = sure:getTitleRenderer()
    local sureStr = sureTxt:getString()

    -- mainSkillTxt:setString(LuaSqlite.getLanguageByKey(mainSkillStr)) 
    CSResourceMgr.setLabelStringByNode(mainSkillTxt,mainSkillStr)
    -- sureTxt:setString(LuaSqlite.getLanguageByKey(sureStr)) 
    CSResourceMgr.setButtonStringByNode(sure, sureStr)
    -- paSkillTxt:setString(LuaSqlite.getLanguageByKey(paSkillTxtStr))
    CSResourceMgr.setLabelStringByNode(paSkillTxt,paSkillTxtStr)

    local function clickEvent(info)
        PetSkillViewMgr.showBattleSkillInfoPage(info)
        local res = "Pet/Education/BattleSkillInfoViewNew.csb"
        -- if LuaSqlite.LANG_TYPE == 3 then
        --     res = "Pet/Education/BattleSkillInfoViewUS.csb"
        -- end

        local btn = CSResourceMgr.getNodeByName(res, "btn")
        CSResourceMgr.buttonEventBindingByNodeXP(btn, function() 
        end, function()
            PetSkillViewMgr.hideBattleSkillInfoPage()
            
        end, nil, function()
            
        end, false, nil, function()
            
        end) 
    end

    for i = 1,4 do
        local skillBtn = CSResourceMgr.getNodeByName(resName, "skill"..i)
        local skillPic = CSResourceMgr.getNodeByName(resName, "skillPic"..i)
        local atr      = CSResourceMgr.getNodeByName(resName, "atr"..i)
        local skillstage = CSResourceMgr.getNodeByName(resName, "skillstage_"..i)
        local s        = CSResourceMgr.getNodeByName(resName, "s"..i)
        local skillName = CSResourceMgr.getNodeByName(resName, "skillName"..i)
        local consume   = nil
        local value     = nil
        local ENE       = nil
        local skill4db  = nil
        if i>1 and i<4 then
            ENE       = CSResourceMgr.getNodeByName(resName, "ENE"..i)
            consume   = CSResourceMgr.getNodeByName(resName, "consume"..i)
        end
        if i ~=4 then
            value = CSResourceMgr.getNodeByName(resName, "value"..i)
        else
            skill4db = CSResourceMgr.getNodeByName(resName, "4db")
        end
        skillNodes[i] = {}
        skillNodes[i].skillPic = skillPic
        skillNodes[i].atr = atr
        skillNodes[i].skillstage = skillstage
        skillNodes[i].s = s 
        skillNodes[i].skillName = skillName

        if skills[i] and skills[i] ~= 0  then
            local skillID = skills[i]
            local info     = clone(PokemonInfo.getPetSkillInfoById(skillID))
            local playInfo = clone(PokemonInfo.getSkillPlayById(skillID))
            local skillIconRes = BattleGetPetInfo.getSkillRes(info.icon)
            local valueRes  = "Battle/downEdge_A/skillStage/"..info.airpower..".png"
            CSResourceMgr.setSpriteTextureByNode(atr, playInfo.typeIcon)
            CSResourceMgr.setSpriteTextureByNode(s, "UI/CommonFiles/"..info.skillAtt..".png")
            CSResourceMgr.setSpriteTextureByNode(skillPic, skillIconRes)
            PetEducationMgr.getRareIcon(rarePoint)
            CSResourceMgr.setSpriteTextureByNode(skillPic, skillIconRes)
            CSResourceMgr.setSpriteTextureByNode(skillstage, PetEducationMgr.getRareIcon(info.airpower))

            if consume then
                consume:setString(info.energy)  
                consume:enableOutline({r=0,g=0,b=0}, 1)
            end
            if i == 4 then
                CSResourceMgr.setSpriteTextureByNode(skill4db, PetEducationMgr.maxSkillEnergyPath[info.energy]) 
            end
            if value then
                CSResourceMgr.setSpriteTextureByNode(value, valueRes) 
            end
            skillName:enableOutline({r=0,g=0,b=0}, 1) 
            skillName:setTextColor(PokemonInfo.COLOR[info.airpower])
            -- skillName:setString(LuaSqlite.getLanguageByKey(info.name))
            CSResourceMgr.setLabelStringByNode(skillName,info.name,nil,0)
            CSResourceMgr.buttonEventBindingByNodeXP(skillBtn, function() 
            end, function()
                clickEvent(info)
            end, nil, function()
                
            end, false, nil, function()
                
            end)
        else
            skillPic:hide()
            if value then
                value:hide()
            end
            if ENE then
                ENE:hide()
            end
            if i == 4 then
                CSResourceMgr.setSpriteTextureByNode(skill4db, "empty.png")
            end

        end
    end

    for i = 1,5 do
        local paSkill    = CSResourceMgr.getNodeByName(resName, "paSkill"..i)
        local paSkillPic = CSResourceMgr.getNodeByName(resName, "paSkillPic"..i)
        local ps         = CSResourceMgr.getNodeByName(resName, "ps"..i)
        local paskiS     = CSResourceMgr.getNodeByName(resName, "paskiS_"..i)
        local paSkiName        = CSResourceMgr.getNodeByName(resName, "paSkiName"..i)
        paSkillNodes[i] = {}
        paSkillNodes[i].paSkillPic = paSkillPic
        paSkillNodes[i].ps = ps
        paSkillNodes[i].paskiS = paskiS
        paSkillNodes[i].paSkiName = paSkiName

        if petPaSkills[i] then
            local paskillID = petPaSkills[i].paSkillID
            local info = clone(PokemonInfo.getPetSkillInfoById(paskillID))
            local skillIconRes = BattleGetPetInfo.getSkillRes(info.icon)

            CSResourceMgr.setSpriteTextureByNode(paSkillPic, skillIconRes)
            CSResourceMgr.setSpriteTextureByNode(paskiS, PetEducationMgr.getRareIcon(info.airpower))
            CSResourceMgr.setSpriteTextureByNode(ps, "UI/CommonFiles/"..info.skillAtt..".png")
            paSkiName:enableOutline({r=0,g=0,b=0}, 1) 
            paSkiName:setTextColor(PokemonInfo.COLOR[info.airpower])
            -- paSkiName:setString(LuaSqlite.getLanguageByKey(info.name))
            CSResourceMgr.setLabelStringByNode(paSkiName,info.name,nil,0)
            local skillPowerIndex = info.airpower - 1
            if skillPowerIndex > 0 and skillPowerIndex < 4 then

                local paSkillRes = passiveSkillBackGroundPath[skillPowerIndex]
                CSResourceMgr.setButtonTextureByNode(paSkill,paSkillRes,paSkillRes,paSkillRes)
            end
            CSResourceMgr.buttonEventBindingByNodeXP(paSkill, function() 
            end, function()
                clickEvent(info)
            end, nil, function()end, false, nil, function()end)
        else
            paSkillPic:hide()
        end
    end 

    CSResourceMgr.buttonEventBindingByNodeXP(sure, function() 
            end, function()
                layer:removeFromParent()
            end, nil, function()end, false, nil, function()end)

    CocosModuleMgr.showUIAnimation(layer, "down")
end

function expeditionalViewMgr.sendSurviveBattleResult(hp,objID,damage,quest)
    NetInterface.sendWithBlock("GC_ExpeditionBattleEnd_Ack", function()
            local ExpeditionSend = require("src.Net.Send.ExpeditionSend")
            ExpeditionSend.sendCG_ExpeditionBattleEnd_Req({petObjID = objID,petHP = hp,damage = damage,quests = quest}) 
        end, function()
            
        end, function(code)
            MapSeekerMgr.setSeekFunc(function()  
                DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "battle Error~!!!!!", 
                function()end)
            end)
            expeditionalViewMgr.cleanup()
            SceneMgr.replaceScene(SceneMgr.getRunningScene, "MainScene")
                        
            StandardTipsMgr.show(1,"GC_ExpeditionBattleEnd_Ack failed code="..code)
        end) 
end

function expeditionalViewMgr.checkExpeditionFinishTime()
    local serverTime = CharInfo.getServerTime() 
    local finishTime = CharInfo.getFinishExpeditionTime()
    local createTime = CharInfo.getExpediCreateTime()
    local expeditionHour = SystemInfo.getGlobalConfigAddInfoByID(90).values[1]
    local currentLevel = CharInfo.getCurrentExpeditionLevel()
    local finishLevel = CharInfo.getFinishExpeditionLevel()
    if CocosModuleMgr.getDayTimeDiff(createTime, serverTime, expeditionHour*3600) ~= 0 then
        return true
    else
        if CocosModuleMgr.getDayTimeDiff(createTime, finishTime, expeditionHour*3600) == 0 and currentLevel == finishLevel then
            return true
        else
            return false
        end
    end
end

function expeditionalViewMgr.checkExpeditionOverDate()
	local serverTime = CharInfo.getServerTime() 
    local finishTime = CharInfo.getFinishExpeditionTime()
    local createTime = CharInfo.getExpediCreateTime()
    local expeditionHour = SystemInfo.getGlobalConfigAddInfoByID(90).values[1] 
    local currentLevel = CharInfo.getCurrentExpeditionLevel()
    local finishLevel  = CharInfo.getFinishExpeditionLevel()
    local days  =  CocosModuleMgr.getDayTimeDiff(createTime, serverTime, expeditionHour*3600)
    if days ~= 0 then
    	return true
    else 
        return false
    end
end

function expeditionalViewMgr.checkExpeditionAwardTime()
		local serverTime = CharInfo.getServerTime() 
    local finishTime = CharInfo.getFinishExpeditionTime()
    local createTime = CharInfo.getExpediCreateTime()
    local expeditionHour = SystemInfo.getGlobalConfigAddInfoByID(90).values[1]
    local currentLevel = CharInfo.getCurrentExpeditionLevel()
    local finishLevel = CharInfo.getFinishExpeditionLevel()
    if CocosModuleMgr.getDayTimeDiff(createTime, finishTime, expeditionHour*3600) == 0 and currentLevel == finishLevel then
    	return true
    else
    	return false
    end
end

function expeditionalViewMgr.checkExpeditionLimitTime(nowTime)
    local createTime = CharInfo.getExpediCreateTime()

    if not createTime then
        print("checkExpeditionLimitTime ========= nil") 
        return false
    end

    local date = os.date("*t",createTime)
    local expeditionHour = SystemInfo.getGlobalConfigAddInfoByID(90).values[1]  
    -- local expeditionHour = 11
    local overTime = expeditionHour*3600
    local newTime  = date.hour*3600 + date.min*60 + date.sec

    if newTime > overTime then
        date.day = date.day + 1
    end

    date.hour = expeditionHour
    date.min  = 0
    date.sec  = 0

    local newExpedtionTime = os.time(date)
    local serverData = os.date("*t",nowTime)
    
    if nowTime >= newExpedtionTime then
        print("false")
        return false
    else
        print("true")
        return true
    end
end

function expeditionalViewMgr.searchRoutine(terP)
    local expedition    = ExpeditionalInfo.new()  
    local mapID         = 1
    local tbl    = ExpeditionalInfo:getRouteTable(mapID)
    -- local tbl  = {{1,2},{2,3},{3,4},{4,5},{5,6},{6,7},{7,8},{8,9},{9,10},{9,11}}

    local branchTbl     = {}
    local resultRoutine = {}
    local errorRoutine  = false

    local function searchRoutine(cur)
        
        local tmpTbl       = {}
        table.insert(resultRoutine,cur)
        for key,var in pairs(tbl) do
            if (var[1] == cur and var[2] == terP) or (var[2] == cur and var[1] == terP) then
                table.insert(resultRoutine,terP)
                return resultRoutine
            end

            if var[1] == cur then
                table.insert(tmpTbl,var[2])
            end

            if var[2] == cur then
                table.insert(tmpTbl,var[1])
            end
        end

        for key,var in pairs(tmpTbl) do
            local isContained = false
            for k, v in pairs(resultRoutine) do
                if v==var then
                    isContained = true
                end
            end
            if isContained==true or var== curPointID then 
                table.remove(tmpTbl, key)
            end
        end
        if #tmpTbl > 1 then
            table.insert(branchTbl, tmpTbl)
            searchRoutine(tmpTbl[1], terP)
        elseif #tmpTbl == 0 then 
            if #branchTbl==0 then
                errorRoutine = true
                print("找不到路线，请检查routeTable")
                return
            end
            local branchid = branchTbl[#branchTbl][1]

            local function resetRouteResult(bid)
                local bkey = #resultRoutine
                local tmpRouteTbl = {}
                for key, var in pairs(resultRoutine) do
                    if var==bid then
                        bkey = key
                    end
                    if key<bkey then
                        table.insert(tmpRouteTbl, var)
                    end
                end
                resultRoutine = tmpRouteTbl
            end
            resetRouteResult(branchid)
     
            local function removeBranch(boolRemove)
                if boolRemove then
                    resetRouteResult(branchTbl[#branchTbl][1])
                end
                table.remove(branchTbl[#branchTbl], 1)
                if #branchTbl[#branchTbl]==0 then
                    table.remove(resultRoutine, #resultRoutine)
                    table.remove(branchTbl, #branchTbl)
                    if #branchTbl==0 then 
                        errorRoutine = true
                        print("找不到路线，请检查routeTable")
                        return
                    end
                    removeBranch(true) 
                end
            end
            removeBranch(false)
            if errorRoutine then
                return
            else
                searchRoutine(branchTbl[#branchTbl][1], terP)
            end 
        else
            searchRoutine(tmpTbl[1],terP)
        end
    end

    searchRoutine(curPointID,terP)
    if resultRoutine[1] == curPointID then
        table.remove(resultRoutine,1)
    end
    return resultRoutine
end

-- function expeditionalViewMgr.getRestSecond()
--     local serverTime = CharInfo.getServerTime()
--     local date = os.date("*t",serverTime)
--     local resetHour = SystemInfo.getGlobalConfigAddInfoByID(90).values[1]
--     local second    = 0

--     if date.hour > resetHour then
--         second = (23 - date.hour + resetHour)*3600 + (59-date.min)*60 + (60 - date.sec)
--     else
--         second = (resetHour - date.hour - 1)*3600 + (59-date.min)*60 + (60 - date.sec) 
--     end
--     return second
-- end

return expeditionalViewMgr