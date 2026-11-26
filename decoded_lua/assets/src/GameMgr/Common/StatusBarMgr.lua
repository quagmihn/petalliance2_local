local StatusBarMgr = {}

local resName = ""
local resNameBtns = ""
local resNameTop = ""
local playerTag = ""
local curActionVal = 0
local btnsList = {}
local btnNames = {}
local isMenuNew = {}
local isBallOpen = false
local lockInfo = {}
local topBarCloseCallback = nil
local redPointTabel = {}
local resNameArena = ""
local startTime = nil
local endTime = nil
StatusBarMgr.TOPBARSHOW = false

function StatusBarMgr.Init()
    print("StatusBarMgr初始化")
    
    resName = "Charactor/CharactorLayer.csb"
    resNameBtns = "Charactor/extendLayer.csb"
    resNameTop = "Charactor/TopInfoLayer.csb"
    resNameArena = "Charactor/TopInfoArena.csb"
    CSResourceMgr.createRes(nil, resName, nil, true)
    CSResourceMgr.createRes(nil, resNameBtns, nil, true)
    CSResourceMgr.createRes(nil, resNameTop, nil, true)
    
    playerTag = PlayerAnimeMgr.STATUSBAR_TAG_STRING
    curActionVal = 0

    btnsList = {"btnList2", "btnList1", "btnList3", "btnList4", "btnList5", "btnList6", "btnList7", "btnList8", "btnList9", "mail1","btnList12","btnList13"}
    --1任务 2扭蛋 3成就 4好友 5图鉴 6活动 7首冲 8充值 9组队 10邮件
    btnNames = {"Button_rw", "Button_nd", "Button_hd", "Button_hy", "Button_sz", "Button_xs", "Button_sc", "Button_cz", 
        "Button_zd", "Button_yj","Button_hdNew","Button_zb"}
    for var=1, #btnNames do
        isMenuNew[var] = false
    end
    isBallOpen = SystemOptionsMgr.getOption(1)
    local lockid = {21001, 21003, 21005, 21006, 24015, nil, nil, nil, nil, nil,nil,24016}
    for key, var in pairs(lockid) do
    	if var then
            local value = SystemInfo.getGlobalConfigAddInfoByID(var)
            if value then
                lockInfo[key] = value.values[1]
            end
    	end
    end
    topBarCloseCallback = nil
    redPointTabel = {}
    StatusBarMgr.TOPBARSHOW = false

    local activityInfoTabel = ActivityInfo.getActivityAllInfo()
    for k,v in pairs(activityInfoTabel) do
        if v.page == 4 then
            local lastTime = v.beginTime + v.lastTime
            if startTime then
                if startTime > v.beginTime then
                    startTime = v.beginTime
                end
            else
                startTime = v.beginTime
            end
            if endTime then
                if endTime < lastTime then
                    endTime = lastTime
                end
            else
                endTime = lastTime
            end
        end
    end
end

function StatusBarMgr.addStatusBar(scene, showCamera, showMenuArrow)
    local function loadCSB()
        local head = CSResourceMgr.createRes(scene, resName)
        head:setLocalZOrder(CocosModuleMgr.ZORDER_BAR)
        CocosModuleMgr.setEdgeDistance(head, 0, nil, 0, nil)
        CSResourceMgr.setLabelColor(resName, "name", {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelColor(resName, "level", {r=255,g=255,b=0,a=255})
        CSResourceMgr.setLabelColor(resName, "vipNum", {r=255,g=255,b=0,a=255})
        CSResourceMgr.setLabelColor(resName, "attackNum", {r=0,g=228,b=255,a=255})
        CSResourceMgr.setLabelColor(resName, "buyTime", {r=210,g=255,b=0,a=255})
        CSResourceMgr.setLabelColor(resName, "buyTimeNum", {r=210,g=255,b=0,a=255})
        CSResourceMgr.setLabelColor(resName, "nextTime", {r=210,g=255,b=0,a=255})
        CSResourceMgr.setLabelColor(resName, "nextTimeNum", {r=210,g=255,b=0,a=255})
        CSResourceMgr.setLabelString(resName, "name", CharInfo.getNickName().." ", "", {r=0,g=0,b=0,a=255}, nil, 132)
        CSResourceMgr.setLabelString(resName, "level", " ", "", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setLabelString(resName, "attackNum", "","", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setLabelString(resName, "buyTime", "tips50", "", {r=0,g=0,b=0,a=255},nil,88)
        CSResourceMgr.setLabelString(resName, "buyTimeNum", "25/25", "", {r=0,g=0,b=0,a=255},nil,64)
        CSResourceMgr.setLabelString(resName, "nextTime", "tips51", "", {r=0,g=0,b=0,a=255},nil,132)
        CSResourceMgr.setLabelString(resName, "nextTimeNum", "12.12.12", "", {r=0,g=0,b=0,a=255},nil,75)
        CSResourceMgr.setLabelString(resName, "hpoint", "", "", {r=0,g=0,b=0,a=255}, nil, 90)
        CSResourceMgr.setLabelString(resName, "gcoin", "", "", {r=0,g=0,b=0,a=255}, nil, 90)
        CSResourceMgr.setLabelString(resName, "mcoin", "", "", {r=0,g=0,b=0,a=255}, nil, 90)
        redPointTabel = {}
        for i=1,#btnsList do
            CSResourceMgr.getNodeByName(resNameBtns, "Text"..i):setVisible(true)
        end
        
        local pAni = PlayerAnimeMgr.createPlayer(nil, {skin=CharInfo.getCurfashion()}, playerTag)
        --隐藏不必要的部件
        for var=1, #PlayerAnimeMgr.HIDE_PART do
            local pIndex = PlayerAnimeMgr.HIDE_PART[var]
            PlayerAnimeMgr.playerTable[playerTag].spineobj[pIndex]:hide()
        end
        
        local clip = CocosModuleMgr.maskSprite(CSResourceMgr.getNodeByName(resName, "z_touxiao"), pAni, 
            "Charactor/charcircle.png", {x=67, y=6})
        clip:setScale(0.9)
        pAni:setScale(1.4)
        pAni:setPosition(70, -170)

        if showCamera then
            CSResourceMgr.getNodeByName(resName, "cameraBtn"):setVisible(true)
            CSResourceMgr.clickEventBinding(resName, "cameraBtn", function()
                FurnitureViewMgr.snapShot()
            end)
        else
            CSResourceMgr.getNodeByName(resName, "cameraBtn"):setVisible(false)
        end
        
        if showMenuArrow == false then
            CSResourceMgr.getNodeByName(resNameBtns, "Node"):setVisible(false)
        else
            CSResourceMgr.getNodeByName(resNameBtns, "Node"):setVisible(true)
        end

        local node = CSResourceMgr.seekNodeByName(head, "b1")
        local btns = CSResourceMgr.createRes(node, resNameBtns)
        for var=1, #btnsList do
            CSResourceMgr.setLabelColor(resNameBtns, "Text"..var, {r=254,g=250,b=175,a=255})
            CSResourceMgr.setLabelString(resNameBtns, "Text"..var, btnsList[var], "", {r=0,g=0,b=0,a=255})
        end
        
        --邮件按钮动画
        --[[
        local mailBtn = CSResourceMgr.getNodeByName(resNameBtns, btnNames[10])
        transition.stopTarget(mailBtn)
        local sequence = transition.sequence({
            cc.RotateBy:create(0.1, 20),
            cc.RotateBy:create(0.1, -40),
            cc.RotateBy:create(0.1, 30),
            cc.RotateBy:create(0.1, -20),
            cc.RotateBy:create(0.1, 10),
        })
        local ani = cc.RepeatForever:create(sequence)
        mailBtn:runAction(ani)]]

        for var=1, #btnNames do
            if isMenuNew[var]==true then
                StatusBarMgr.addRedPoint(var, true)
            end
        end

        CSResourceMgr.clickEventBinding(resName, "HeadButton", function()
            WorldMapMgr.locateCharactor()
            PersonalCenterMgr.show(scene, CharInfo.getCharID())
        end)

        local function showHpoint(enabled)
            local xinxiTwo = CSResourceMgr.getNodeByName(resName, "xinxi2") 
            if enabled then
                xinxiTwo:setVisible(true)
                xinxiTwo:setScaleX(0)
                transition.scaleTo(xinxiTwo, {scaleX = 1.2, time = 0.1})
                xinxiTwo:performWithDelay(function()
                    transition.scaleTo(xinxiTwo, {scaleX = 1, time = 0.1})
                end,0.1)
            else
                if xinxiTwo:getScaleX()<1 then
                    transition.scaleTo(xinxiTwo, {scaleX = 1, time = 0.1})
                    xinxiTwo:performWithDelay(function()
                        transition.scaleTo(xinxiTwo, {scaleX = 0, time = 0.1})
                        xinxiTwo:performWithDelay(function()
                            xinxiTwo:setVisible(false)
                        end,0.1)
                    end,0.1)
                else
                    transition.scaleTo(xinxiTwo, {scaleX = 0, time = 0.1})
                    xinxiTwo:performWithDelay(function()
                        xinxiTwo:setVisible(false)
                    end,0.1)
                end
            end
        end
        --查看体力信息按钮
        CSResourceMgr.buttonEventBinding(resName, "info_hpoint", function()
            showHpoint(true)
        end,function()
            showHpoint(false)
        end,function()
            --拖拽
        end,function()
            showHpoint(false)
        end)

        CSResourceMgr.clickEventBinding(resName, "add_hpoint", function()
            ExchangeViewMgr.show(scene, ExchangeViewMgr.POWERTYPE)
        end)

        CSResourceMgr.clickEventBinding(resName, "add_gcoin", function()
            ExchangeViewMgr.show(scene, ExchangeViewMgr.GCASHTYPE)
        end)
        CSResourceMgr.clickEventBinding(resName, "add_mcoin", function()
            PurchaseViewMgr.show(scene)
        end)
        CSResourceMgr.clickEventBinding(resName, "allWorld", function()
            AllWorldMapMgr.show(scene)
        end, "", 1)
        CSResourceMgr.getNodeByName(resName, "allWorld"):setVisible(SceneMgr.currentScene=="MainScene")
        CSResourceMgr.setLabelString(resName, "WorldLabel", "btnList10")

        local j7 = CSResourceMgr.getNodeByName(resName, "j7")
        local effAni = AnimationMgr.createAni(j7, "Spine/effects/UI_huodong.png", 
            j7:getContentSize().width/2, j7:getContentSize().height/2,"UI_huodong")
        effAni:setLocalZOrder(-2)
        AnimationMgr.playAni(effAni.res, "animation", true, "UI_huodong")

        local j11 = CSResourceMgr.getNodeByName(resName, "j11")
        local effAni = AnimationMgr.createAni(j11, "Spine/effects/UI_huodong.png", 
            j11:getContentSize().width/2, j11:getContentSize().height/2,"UI_huodong2")
        effAni:setLocalZOrder(-2)
        AnimationMgr.playAni(effAni.res, "animation", true, "UI_huodong2")

        --[[
        local bg = display.newSprite("UI/MiniMap/p_blue.png")
        local progressTimer = cc.ProgressTimer:create(display.newSprite("UI/MiniMap/p_red.png"))
        bg.progressTimer = progressTimer
        progressTimer:setType(cc.PROGRESS_TIMER_TYPE_RADIAL) 
        progressTimer:setPercentage(60)
        progressTimer:setPosition(bg:getContentSize().width/2, bg:getContentSize().height/2)
        progressTimer:setScale(-1, 1)
        bg:addChild(progressTimer)
        bg:addTo(CSResourceMgr.getNodeByName(resName, "HeadButton"))
        bg:setPosition(100, 0)]]
        StatusBarMgr.loadTopBar(scene)
        
        StatusBarMgr.refreshGold()
        StatusBarMgr.refreshCash()
        StatusBarMgr.refreshLevel()
        StatusBarMgr.refreshVipLevel()
        StatusBarMgr.refreshServerTime()
        StatusBarMgr.refreshBuyPowerTimes()
        StatusBarMgr.refreshFightPower(PetFormationMgr.getCurTab())
        StatusBarMgr.checkMapLockInfo()

        StatusBarMgr.setFamilyBuffBtn()

        --临时活动按钮显示
		if endTime and startTime then 
			local loginTime = CharInfo.getServerTime()
			if loginTime < startTime then
				StatusBarMgr.showNewBtn(false)
			else
				if loginTime > endTime then
					StatusBarMgr.showNewBtn(false)
				else
					StatusBarMgr.showNewBtn(true)
				end
			end
		end
    end
    
    local function playCSB()
        CSResourceMgr.playAction(resName, 0, 10, false)
        
        for var=1, #btnNames do
            CSResourceMgr.getNodeByName(resNameBtns, btnNames[var]):setScale(1.2)
        end
        
        local btnsListV = CSResourceMgr.getNodeByName(resNameBtns, "Btns_vertical")
        local btnsListH = CSResourceMgr.getNodeByName(resNameBtns, "Btns_horizontal")
        local function setBtnsEnabled(enabled)
            btnsListV:setVisible(enabled)
            btnsListH:setVisible(enabled)
        end
        setBtnsEnabled(false)
        local function hideList()
            isBallOpen = false
            CSResourceMgr.playActionWithCallback(resNameBtns, 35, 40, 1, function()
                setBtnsEnabled(isBallOpen)
                CSResourceMgr.setButtonTexture(resNameBtns, "Button_List", "UI/CommonFiles/ico_zuhe.png", 
                    "UI/CommonFiles/ico_zuhe.png", "UI/CommonFiles/ico_zuhe.png")
            end, "", 0.01)
            for k,v in pairs(redPointTabel) do
                CSResourceMgr.getNodeByName(resNameBtns, "redPoint"):setVisible(true)
                break
            end
        end
        local function showList()
            isBallOpen = true
            setBtnsEnabled(isBallOpen)
            CSResourceMgr.setButtonTexture(resNameBtns, "Button_List", "UI/CommonFiles/ico_zuhe2.png", 
                "UI/CommonFiles/ico_zuhe2.png", "UI/CommonFiles/ico_zuhe2.png")
            CSResourceMgr.playActionWithCallback(resNameBtns, 0, 5, 1, function()
                for var=1, #btnNames do
                    CSResourceMgr.clickEventBinding(resNameBtns, btnNames[var], function()
                        --1任务 2扭蛋 3成就 4好友 5设置 6活动 7首冲 8充值 9签到
                        if var==1 then
                            MissionListMgr.show(scene)
                        elseif var==2 then
                            GachaViewMgr.show(scene)
                        elseif var==3 then
                            AchievementListMgr.show(scene)
                        elseif var==4 then
                            FriendsViewMgr.show(scene)
                        elseif var==5 then
                            PokedexMenuViewMgr.show(scene)
                        elseif var==6 then
                            ActivityViewMgr.show(scene)
                        elseif var==7 then
                            RechargeViewMgr.show(scene)
                        elseif var==8 then
                            PurchaseViewMgr.show(scene)
                        elseif var==9 then
                            CheckViewMgr.show(scene)
                        elseif var==10 then
                            MailMgr.show(scene)
                        elseif var==11 then
                            ActivityHalloweenViewMgr.show(scene)
                        elseif var==12 then
                            --宠物装备按钮接口
                            PetEquipmentMgr.show(scene)
                        end
                        GameAudio.playUISound("popup")
                        StatusBarMgr.hideRedPoint(var)
                    end, "", 3)
                end
            end)
            CSResourceMgr.getNodeByName(resNameBtns, "redPoint"):setVisible(false)
        end
        CSResourceMgr.clickEventBinding(resNameBtns, "Button_List", function()
            if isBallOpen then
                hideList()
            else
                showList()
            end
            SystemOptionsMgr.setOption(1, isBallOpen)
        end, "", true)
        if isBallOpen then
            showList()
        else
            hideList()
        end
        
        --暂时隐藏活动和首冲按钮
        -- CSResourceMgr.getNodeByName(resNameBtns, "Button_xs"):setVisible(false)
        -- CSResourceMgr.getNodeByName(resNameBtns, "Button_sc"):setVisible(false)
        -- CSResourceMgr.getNodeByName(resNameBtns, "Text6"):setVisible(false)
        -- CSResourceMgr.getNodeByName(resNameBtns, "Text7"):setVisible(false)
        -- CSResourceMgr.getNodeByName(resNameBtns, "y6"):setVisible(false)
        -- CSResourceMgr.getNodeByName(resNameBtns, "y7"):setVisible(false)

        if LuaSqlite.LANG_TYPE~= 1 and LuaSqlite.LANG_TYPE~= 2 then--外国版隐藏文字
            for i=1,#btnsList do
                CSResourceMgr.getNodeByName(resNameBtns, "Text"..i):setVisible(false)
            end
        end
    end

    local funcTable = {loadCSB, playCSB}
    UnblockLoader.load(funcTable, "addStatusBar")
end

function StatusBarMgr.remove()
    UnblockLoader.cancel("addStatusBar")
    PlayerAnimeMgr.removePlayerByTag(playerTag, false)
    CSResourceMgr.playActionWithCallback(resName, 50, 60, 1, function()
        CSResourceMgr.removeCSObjectByTag(resName)
    end)
end

function StatusBarMgr.refreshHead()
    PlayerAnimeMgr.setPlayerSkins(playerTag, CharInfo.getCurfashion())
end

function StatusBarMgr.refreshGold()
    local curLayer = CSResourceMgr.getCsbObj(resName)
    if curLayer then
        local gcoin = CSResourceMgr.seekNodeByName(curLayer, "gcoin")
        local gold = CharInfo.getGCash()
        CSResourceMgr.setLabelStringByNode(gcoin, gold,nil,-1,90)
        --[[
        gcoin:removeAllChildren()
        local labelGold = CocosModuleMgr.createAtlasLabel(gold, "UI/Atlas/hompage18x14.png", 14, 18, "/", -1)
        labelGold:addTo(gcoin)
        labelGold:setPosition(37, 12)
        ]]
    end
    local curTopLayer = CSResourceMgr.getCsbObj(resNameTop)
    if curTopLayer then
        local gcoin = CSResourceMgr.seekNodeByName(curTopLayer, "gcoin")
        local gold = CharInfo.getGCash()
        CSResourceMgr.setLabelStringByNode(gcoin, gold,nil,-1,100)
    end
    local achieveTopLayer = CSResourceMgr.getCsbObj("Player/AchieveTopInfoLayer.csb")
    if achieveTopLayer then
        local gcoin = CSResourceMgr.seekNodeByName(achieveTopLayer, "gcoin")
        local gold = CharInfo.getGCash()
        CSResourceMgr.setLabelStringByNode(gcoin, gold,nil,-1,100)
    end
    
    local resNameTop = "Charactor/TopInfoLayerSilverCoin.csb"
    local top2 = CSResourceMgr.getCsbObj(resNameTop)
    if top2 then
        CSResourceMgr.setLabelString(resNameTop, "gcoin", CharInfo.getGCash(), "", nil, -1,100)
        --CSResourceMgr.setLabelString(resNameTop, "mcoin", CharInfo.getMCash(), "", nil, -1)
    end

    local arenaTopLayer = CSResourceMgr.getCsbObj(resNameArena)
    if arenaTopLayer then
        CSResourceMgr.setLabelString(resNameArena, "gcoin", CharInfo.getGCash(), "", nil, -1,100)
    end
end

function StatusBarMgr.refreshCash()
    local curLayer = CSResourceMgr.getCsbObj(resName)
    if curLayer then
        local mcoin = CSResourceMgr.seekNodeByName(curLayer, "mcoin")
        local cash = CharInfo.getMCash()
        CSResourceMgr.setLabelStringByNode(mcoin, cash,nil,-1,90)
        --[[
        mcoin:removeAllChildren()
        local labelCash = CocosModuleMgr.createAtlasLabel(cash, "UI/Atlas/hompage18x14.png", 14, 18, "/", -1)
        labelCash:addTo(mcoin)
        labelCash:setPosition(37, 12)
        ]]
    end
    local curTopLayer = CSResourceMgr.getCsbObj(resNameTop)
    if curTopLayer then
        local mcoin = CSResourceMgr.seekNodeByName(curTopLayer, "mcoin")
        local cash = CharInfo.getMCash()
        CSResourceMgr.setLabelStringByNode(mcoin, cash,nil,-1,100)
    end
    local achieveTopLayer = CSResourceMgr.getCsbObj("Player/AchieveTopInfoLayer.csb")
    if achieveTopLayer then
        local mcoin = CSResourceMgr.seekNodeByName(achieveTopLayer, "mcoin")
        local cash = CharInfo.getMCash()
        CSResourceMgr.setLabelStringByNode(mcoin, cash,nil,-1,100)
    end
    
    local resNameTop = "Charactor/TopInfoLayerSilverCoin.csb"
    local top2 = CSResourceMgr.getCsbObj(resNameTop)
    if top2 then
    --CSResourceMgr.setLabelString(resNameTop, "gcoin", CharInfo.getGCash(), "", nil, -1)
        CSResourceMgr.setLabelString(resNameTop, "mcoin", CharInfo.getMCash(), "", nil, -1,100)
    end

    local arenaTopLayer = CSResourceMgr.getCsbObj(resNameArena)
    if arenaTopLayer then
        CSResourceMgr.setLabelString(resNameArena, "mcoin", CharInfo.getMCash(), "", nil, -1,100)
    end
end

function StatusBarMgr.refreshLevel()
    local curLayer = CSResourceMgr.getCsbObj(resName)
    if curLayer then
        CSResourceMgr.setLabelString(resName, "level", "LV "..CharInfo.getLevel())
    end
end

function StatusBarMgr.refreshVipLevel()
    local vipInfo = CharInfo.getVipInfoByID(CharInfo.getVIPLevel())
    CSResourceMgr.setLabelString(resName, "vipNum", "VIP "..vipInfo.viplevel, "", {r=0,g=0,b=0,a=255})
end

function StatusBarMgr.refreshBuyPowerTimes()
    local curLayer = CSResourceMgr.getCsbObj(resName)
    if curLayer then
        if not NetInterface.isConnect or CharInfo.getCharID()==0 then
        	return
        end
        local vipInfo = CharInfo.getVipInfoByID(CharInfo.getVIPLevel())
        local charInfo = CharInfo.get()
        local todayBuyPowerCount = charInfo["todaybuypowercount"] or 0
        local lastBuyPowerTime = charInfo["lastbuypowertime"] or 0
        local buyCount = 0
        if lastBuyPowerTime~=0 then
            local dayNow = math.floor((CharInfo.getServerTime()+CharInfo.getServerTimeZone())/86400)
            local dayLastBuy = math.floor((lastBuyPowerTime+CharInfo.getServerTimeZone())/86400)
            if dayNow == dayLastBuy then
                if (lastBuyPowerTime+CharInfo.getServerTimeZone())%86400 >= 21600 then
                    buyCount = todayBuyPowerCount
                end
            elseif (dayNow-dayLastBuy) == 1 then
                if (CharInfo.getServerTime()+CharInfo.getServerTimeZone())%86400 < 21600 then
                    buyCount = todayBuyPowerCount
                end
            end
        end
        CSResourceMgr.setLabelString(resName, "buyTimeNum", buyCount.."/"..vipInfo.buyPower, "", {r=0,g=0,b=0,a=255},nil,64)
    end
end

function StatusBarMgr.refreshServerTime()
    local curLayer = CSResourceMgr.getCsbObj(resName)
    local curTopLayer = CSResourceMgr.getCsbObj(resNameTop)
    local actionVal, changeTime = nil, nil
    local maxActionVal = nil
    if curLayer or curTopLayer then
    	actionVal, changeTime = CharInfo.getActionValue()
        maxActionVal= CharInfo.getActionValueMax()
    end
    if curLayer then
        local hpNode = CSResourceMgr.getNodeByName(resName, "hpoint")
        CSResourceMgr.setLabelStringByNode(hpNode, actionVal.."/"..maxActionVal)
        --[[
        hpNode:removeAllChildren()
        local labelHpoint = CocosModuleMgr.createAtlasLabel(actionVal..":"..maxActionVal, "UI/Atlas/hompage18x14.png", 14, 18, "/",-1)
        labelHpoint:addTo(hpNode)
        labelHpoint:setPosition(37, 12)
        ]]
        transition.stopTarget(hpNode)
        if changeTime then
            local timeLabel = CSResourceMgr.getNodeByName(resName, "nextTimeNum")
            CocosModuleMgr.setTimeLabelCountDown(timeLabel, changeTime)
            if changeTime==0 then
            	changeTime = 2
            end
            hpNode:performWithDelay(function()
                StatusBarMgr.refreshServerTime()
            end, changeTime)
        else
            local timeLabel = CSResourceMgr.getNodeByName(resName, "nextTimeNum")
            CocosModuleMgr.setTimeLabelCountDown(timeLabel, 0)
        end
    end
    
    if curTopLayer then
        local hpNode = CSResourceMgr.seekNodeByName(curTopLayer, "hpoint")
        CSResourceMgr.setLabelStringByNode(hpNode,actionVal.."/"..maxActionVal)
    end
end

function StatusBarMgr.getTotalFightPoint(team)
    team = team or PetFormationMgr.getCurTab()
    local petInfoVec = {}
    local myPets = PokemonInfo.getPetArmy(team)
    for k,v in pairs(myPets) do
        local petInfo = PokemonInfo.getPetInfoByObjID(v)
        table.insert(petInfoVec,petInfo)
    end
    return PokemonInfo.getFightPoint(petInfoVec)
end

function StatusBarMgr.refreshFightPower(team)
    local curLayer = CSResourceMgr.getCsbObj(resName)
    if curLayer then
        local fightPoint = StatusBarMgr.getTotalFightPoint(team)
        CSResourceMgr.setLabelString(resName, "attackNum", fightPoint)
    end
end

--1任务 2扭蛋 3成就 4好友 5图鉴 6活动 7首冲 8充值 9组队 10邮件 11活动 12装备
function StatusBarMgr.addRedPoint(type, boolFirst)
    if isMenuNew[type]==true and not boolFirst then
    	return
    end
    local charLock = CharInfo.get().maplock
    if type==4 then
        charLock = CharInfo.getLevel()
    end
    if lockInfo[type] then
        if CharInfo.get().local_freedom ~= true and charLock < lockInfo[type] then
            return 
        end
    end
    isMenuNew[type] = true
    if type==10 then
        --邮件按钮显示
        CSResourceMgr.getNodeByName(resNameBtns, "j10"):show()
    end
    CocosModuleMgr.showShiningToNode(CSResourceMgr.getNodeByName(resNameBtns, btnNames[type]), 4)

    redPointTabel[type] = type
    if not SystemOptionsMgr.getOption(1) and CSResourceMgr.getCsbObj(resNameBtns) then
        CSResourceMgr.getNodeByName(resNameBtns, "redPoint"):setVisible(true)
    end
end

function StatusBarMgr.hideRedPoint(type)
    isMenuNew[type] = false
    if type==10 then
        --邮件按钮隐藏
        CSResourceMgr.getNodeByName(resNameBtns, "j10"):hide()
    end
    CocosModuleMgr.hideShiningToNode(CSResourceMgr.getNodeByName(resNameBtns, btnNames[type]))
    redPointTabel[type] = nil
end

function StatusBarMgr.checkMapLockInfo(boolAnimate)
    if not CSResourceMgr.getCsbObj(resNameBtns) then
        return
    end
    if boolAnimate==nil then
    	boolAnimate = false
    end
    
    for var, value in pairs(lockInfo) do
        local charLock = CharInfo.get().maplock
        if var==4 then
            charLock = CharInfo.getLevel()
        end
        --print("StatusBarMgr.checkMapLockInfo", charLock, lockInfo[var])
        local accessible = CharInfo.get().local_freedom == true or charLock >= value
        if accessible then
            if boolAnimate then
                --CocosModuleMgr.showUnlockAnimation(CSResourceMgr.getNodeByName(resNameBtns, btnNames[var]))
            else
                CSResourceMgr.setButtonEnabled(resNameBtns, btnNames[var], true)
            end
            if LuaSqlite.LANG_TYPE~=3 then--外国版隐藏文字
                CSResourceMgr.getNodeByName(resNameBtns, "Text"..var):setVisible(true)
            end
        else
            CSResourceMgr.setButtonEnabled(resNameBtns, btnNames[var], false)
            CSResourceMgr.getNodeByName(resNameBtns, "Text"..var):setVisible(false)
        end
        --新加解锁TIPS
        local btn = CSResourceMgr.getNodeByName(resNameBtns,btnNames[var])
        local tipsBtn = CSResourceMgr.seekNodeByName(btn,"UnLockTipsBtn")
        tipsBtn:setVisible(not accessible)
        CSResourceMgr.clickEventBindingByNode(tipsBtn, function()
            DialogBoxMgr.showSmallDialogBox(nil, 1, LuaSqlite.getLanguageByKey("unlockTips"..var))
        end)
    end
end

function StatusBarMgr.setVisible(val)
    local function setVisible(res)
        local layer = CSResourceMgr.getCsbObj(res)
        if layer then
            layer:setVisible(val)
        end
    end
    setVisible(resName)
    setVisible(resNameBtns)
end

function StatusBarMgr.playAni(posx, posy)
    local function move(res, px, py)
        local layer = CSResourceMgr.getCsbObj(res)
        if layer then
            transition.moveBy(layer, {time=0.1, x=px, y=py})
        end
    end
    move(resName, nil, posy)
    move(resNameBtns, posx, nil)
end

function StatusBarMgr.getTopBarCallback()
    return topBarCloseCallback
end

--needClose:是否关闭之前界面改变回调 1为true 0为false 不填默认为true 
function StatusBarMgr.showTopInfoBar(callback,needClose)
    if needClose then
        needClose = needClose~=0
    else
        needClose = true
    end 
    callback = callback or function() end
    local node = CSResourceMgr.getNodeByName(resNameTop, "up")
    if node then
        if needClose then
            if topBarCloseCallback then
            	topBarCloseCallback()
            end
            topBarCloseCallback = callback
            node:setVisible(true)
            transition.moveTo(node, {y=151, time=0.2})
            CSResourceMgr.clickEventBinding(resNameTop, "close", function()
                callback()
            end)
        else
            node:setVisible(true)
            transition.moveTo(node, {y=151, time=0.2})
        end
    end
    StatusBarMgr.TOPBARSHOW = true
end

function StatusBarMgr.hideTopInfoBar(needClose,paramGetWay)
    if needClose then
        needClose = needClose~=0
    else
        needClose = true
    end 
    local node = CSResourceMgr.getNodeByName(resNameTop, "up")
    if node then
        if needClose then
            node:setPositionY(230)
            node:setVisible(false)
            topBarCloseCallback = nil
        else
            node:setPositionY(230)
            node:setVisible(false)
        end
    end
    if not paramGetWay then
        StatusBarMgr.TOPBARSHOW = false
    end
end

function StatusBarMgr.hideArenaTopBar()
    local node = CSResourceMgr.getNodeByName(resNameArena, "up")
    node:setVisible(false)
end

function StatusBarMgr.setFamilyBuffBtn()
    if CharInfo.getFamilyID() and FamilyInfo.GetLocalFamilyInfo() then
        local xinxi3 = CSResourceMgr.getNodeByName(resName, "xinxi3")
        xinxi3:setVisible(true)
        local jiazu_btn = CSResourceMgr.seekNodeByName(xinxi3, "jiazu_btn")
        jiazu_btn:setScale(0.6)
        local jiazuFlagPath = FamilyInfo.GetLocalFamilyInfo().icon
        CSResourceMgr.setButtonTextureByNode(jiazu_btn, jiazuFlagPath, jiazuFlagPath, jiazuFlagPath)
        local tips_label = CSResourceMgr.seekNodeByName(xinxi3, "tips_label")
        local tips_info = CSResourceMgr.seekNodeByName(xinxi3, "tips_info")
        CSResourceMgr.setLabelColorByNode(tips_label, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(tips_label, "family87",nil,nil,48)
        CSResourceMgr.setLabelColorByNode(tips_info, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(tips_info, "family88")

        jiazu_btn:setColor({r=255,g=255,b=255,a=255})
        local jiazu_info = CSResourceMgr.seekNodeByName(xinxi3, "jiazu_info")
        local add_label = CSResourceMgr.seekNodeByName(xinxi3, "add_label")
        local add_Num = CSResourceMgr.seekNodeByName(xinxi3, "add_Num")
        local time_label = CSResourceMgr.seekNodeByName(xinxi3, "time_label")
        local time_Num = CSResourceMgr.seekNodeByName(xinxi3, "time_Num")
        CSResourceMgr.setLabelColorByNode(add_label, {r=0,g=227,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(add_label, "family85",nil,nil,90)
        CSResourceMgr.setLabelColorByNode(time_label, {r=0,g=227,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(time_label, "family86",nil,nil,90)
        CSResourceMgr.setLabelColorByNode(add_Num, {r=172,g=253,b=255,a=255})
        CSResourceMgr.setLabelColorByNode(time_Num, {r=172,g=253,b=255,a=255})
        CSResourceMgr.buttonEventBindingByNode(jiazu_btn, function()
            jiazu_info:setVisible(true)
            local buff = CharInfo.getFamilyDevoteBuffer()
            local buffTime = (CharInfo.getFamilyDevoteBufferTime() or 0)+ 24*3600 - CharInfo.getServerTime()
            if buff==0 or not HomeInfo.GetMaxRareDegreeFurniture(Proto.FT_SOFA) or buffTime<0 then
                add_label:setVisible(false)
                add_Num:setVisible(false)
                time_label:setVisible(false)
                time_Num:setVisible(false)
                CSResourceMgr.seekNodeByName(xinxi3, "jiazu_info"):setContentSize(372, 100)
            else
                add_label:setVisible(buffTime>0)
                add_Num:setVisible(buffTime>0)
                time_label:setVisible(buffTime>0)
                time_Num:setVisible(buffTime>0)
                CSResourceMgr.setLabelStringByNode(add_Num, tostring(buff/100).."%")
                CocosModuleMgr.setTimeLabelCountDown(time_Num, buffTime)
                CSResourceMgr.seekNodeByName(xinxi3, "jiazu_info"):setContentSize(372, 200)
            end


            transition.scaleTo(jiazu_info, {scale = 1, time = 0.2})
        end,function()
            local jiazu_info = CSResourceMgr.seekNodeByName(xinxi3, "jiazu_info")
            transition.scaleTo(jiazu_info, {scale = 0, time = 0.2})  
            jiazu_info:performWithDelay(function()
                jiazu_info:setVisible(false)
            end,0.2)
        end,function()
            --拖拽
        end,function()
            local jiazu_info = CSResourceMgr.seekNodeByName(xinxi3, "jiazu_info")
            transition.scaleTo(jiazu_info, {scale = 0, time = 0.2})  
            jiazu_info:performWithDelay(function()
                jiazu_info:setVisible(false)
            end,0.2)
        end)
        if not HomeInfo.GetMaxRareDegreeFurniture(Proto.FT_SOFA) then
            -- CSResourceMgr.setButtonEnabledByNode(jiazu_btn, false)
            jiazu_btn:setColor({r=88,g=88,b=88,a=255})
        end
    else
        local xinxi3 = CSResourceMgr.getNodeByName(resName, "xinxi3")
        xinxi3:setVisible(false)
    end
end

function StatusBarMgr.loadTopBar(scene)
    --通用顶部条
    topBarCloseCallback = nil
    local top = CSResourceMgr.createRes(scene, resNameTop)
    top:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
    CocosModuleMgr.setEdgeDistance(top, 0, nil, 0, nil)
    CSResourceMgr.setLabelString(resNameTop, "hpoint", "", "", nil, -1)
    CSResourceMgr.setLabelString(resNameTop, "gcoin", "", "", nil, -1,100)
    CSResourceMgr.setLabelString(resNameTop, "mcoin", "", "", nil, -1,100)
    CSResourceMgr.setLabelColor(resNameTop, "hpoint", {r=190,g=221,b=245,a=255})
    CSResourceMgr.setLabelColor(resNameTop, "gcoin", {r=190,g=221,b=245,a=255})
    CSResourceMgr.setLabelColor(resNameTop, "mcoin", {r=190,g=221,b=245,a=255})
    CSResourceMgr.getNodeByName(resNameTop, "up"):setVisible(false)

    --顶部通用条功能
    CSResourceMgr.buttonEventBinding(resNameTop, "add_hpoint", function()
        ExchangeViewMgr.show(scene,ExchangeViewMgr.POWERTYPE)
    end)
    CSResourceMgr.clickEventBinding(resNameTop, "add_gcoin", function()
        ExchangeViewMgr.show(scene,ExchangeViewMgr.GCASHTYPE)
    end)
    CSResourceMgr.clickEventBinding(resNameTop, "add_mcoin", function()
        PurchaseViewMgr.show(scene)
    end)

    StatusBarMgr.refreshGold()
    StatusBarMgr.refreshCash()
    StatusBarMgr.refreshServerTime()
end

function StatusBarMgr.enabledWorldBtn(enabled)
    local allWorld = CSResourceMgr.getNodeByName(resName, "allWorld")
    CSResourceMgr.setButtonEnabledByNode(allWorld, enabled)
    if enabled then
        transition.moveTo(allWorld, {x=0, time=0.1})
    else
        transition.moveTo(allWorld, {x=-64, time=0.1})       
    end
end

function StatusBarMgr.showArenaTopBar(scene, closeCallBack)
    local resPath = resNameArena
    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, resPath)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW + 1)
        CocosModuleMgr.setEdgeDistance(layer, 0, nil, 0, nil)

        local panel = CSResourceMgr.getNodeByName(resPath, "up")
        if panel then
            panel:setVisible(true)
            transition.moveTo(panel, {y=151, time=0.2})
        end
    end
    
    local function loadNum()
        CSResourceMgr.setLabelColor(resNameTop, "hpoint", {r=190,g=221,b=245,a=255})
        CSResourceMgr.setLabelColor(resNameTop, "gcoin",  {r=190,g=221,b=245,a=255})
        CSResourceMgr.setLabelColor(resNameTop, "mcoin",  {r=190,g=221,b=245,a=255})

        StatusBarMgr.refreshScore()
        StatusBarMgr.refreshGold()
        StatusBarMgr.refreshCash()
    end

    local function loadBtn()
        CSResourceMgr.clickEventBinding(resPath, "close", function()
            StatusBarMgr.hide()
            if closeCallBack then closeCallBack() end
        end)
        CSResourceMgr.buttonEventBinding(resPath, "add_hpoint", function()
            -- ExchangeViewMgr.show(scene,ExchangeViewMgr.POWERTYPE)
        end)
        CSResourceMgr.clickEventBinding(resPath, "add_gcoin", function()
            ExchangeViewMgr.show(scene,ExchangeViewMgr.GCASHTYPE)
        end)
        CSResourceMgr.clickEventBinding(resPath, "add_mcoin", function()
            PurchaseViewMgr.show(scene)

        end)
    end

    local funcTable = {loadCSB, loadNum, loadBtn}
    UnblockLoader.load(funcTable, "showArenaTopBar")
end

function StatusBarMgr.showExpeditionTopBar(scene, callBack,callBack1)
    local resPath = resNameArena
    local layer = CSResourceMgr.createRes(scene, resPath)
    local isBuyM  = false
    local Mbtn    = CSResourceMgr.getNodeByName(resPath, "add_mcoin")
    local function loadCSB()
        
        if callBack1 then
            callBack1(layer)
        else
            layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW + 1)
        end
        CocosModuleMgr.setEdgeDistance(layer, 0, nil, 0, nil)

        local panel = CSResourceMgr.getNodeByName(resPath, "up")
        if panel then
            panel:setVisible(true)
            transition.moveTo(panel, {y=151, time=0.2})
        end
    end
    
    local function loadNum()
        CSResourceMgr.setLabelColor(resNameTop, "hpoint", {r=190,g=221,b=245,a=255})
        CSResourceMgr.setLabelColor(resNameTop, "gcoin",  {r=190,g=221,b=245,a=255})
        CSResourceMgr.setLabelColor(resNameTop, "mcoin",  {r=190,g=221,b=245,a=255})

        -- StatusBarMgr.refreshExpeditionScore() 
        StatusBarMgr.refreshGold()
        StatusBarMgr.refreshCash()
    end

    local function loadBtn()
        CSResourceMgr.clickEventBinding(resPath, "close", function()
            if isBuyM then
                PurchaseViewMgr.hide() 
                Mbtn:setTouchEnabled(true)
                layer:zorder(CocosModuleMgr.ZORDER_WINDOW+1)
                isBuyM = false
                return
            end
            if callBack then callBack() end 
        end)
        local res = "UI/CommonFiles/expedition_intergral_01.png" 
        local add_hpoint = CSResourceMgr.getNodeByName(resPath, "add_hpoint")
        -- CSResourceMgr.setButtonTexture(resPath, "add_hpoint", res, res, res)
        -- add_hpoint:setScale(0.26,0.26)
        CSResourceMgr.buttonEventBinding(resPath, "add_hpoint", function()
            expeditionalViewMgr.buyPointTime()
            -- ExchangeViewMgr.show(scene,ExchangeViewMgr.POWERTYPE)
        end)
        CSResourceMgr.clickEventBinding(resPath, "add_gcoin", function()
            ExchangeViewMgr.show(scene,ExchangeViewMgr.GCASHTYPE)
        end)
        CSResourceMgr.clickEventBinding(resPath, "add_mcoin", function()
                PurchaseViewMgr.show(scene)
                layer:zorder(CocosModuleMgr.ZORDER_WINDOW+10)
                isBuyM = true
                Mbtn:setTouchEnabled(false)
        end)
    end

    local funcTable = {loadCSB, loadNum, loadBtn}
    UnblockLoader.load(funcTable, "showExpeditionTopBar")
end

function StatusBarMgr.hide()
    UnblockLoader.cancel("showArenaTopBar")
    CSResourceMgr.removeCSObjectByTag(resNameArena)
end

function StatusBarMgr.refreshExpeditionScore()
    local arenaTopLayer = CSResourceMgr.getCsbObj(resNameArena)
    if arenaTopLayer then 
        local expeditiondata = expeditionalViewMgr.expedition:getExpeditionData()
        local pointAll   =  expeditiondata.point
        local unusePoint =   pointAll - expeditiondata.usedCount 
        local res = "UI/CommonFiles/expedition_intergral_02.png" 
        CSResourceMgr.getNodeByName(resNameArena, "add_hpoint"):setTouchEnabled(false)
        CSResourceMgr.setButtonTexture(resNameArena, "add_hpoint", res, res, res)
        -- local str = unusePoint
        CSResourceMgr.setLabelString(resNameArena, "hpoint", unusePoint, "", nil, -1, 100)
    end
end

function StatusBarMgr.refreshExpeditionScoreInRoll()
    local arenaTopLayer = CSResourceMgr.getCsbObj(resNameArena)
    if arenaTopLayer then
        local expeditiondata = expeditionalViewMgr.expedition:getExpeditionData()
        local pointAll   =  expeditiondata.point
        local unusePoint =   pointAll - expeditiondata.usedCount  
        local str = unusePoint.."/"..pointAll
        local res = "UI/CommonFiles/expedition_intergral_01.png" 
        CSResourceMgr.setButtonTexture(resNameArena, "add_hpoint", res, res, res)
        CSResourceMgr.getNodeByName(resNameArena, "add_hpoint"):setTouchEnabled(true)
        CSResourceMgr.setLabelString(resNameArena, "hpoint", str, "", nil, -1, 100)
    end
end

function StatusBarMgr.refreshScore()
    local arenaTopLayer = CSResourceMgr.getCsbObj(resNameArena)
    if arenaTopLayer then
        CSResourceMgr.setLabelString(resNameArena, "hpoint", CharInfo.getArenaScore(), "", nil, -1, 100)
    end
end

function StatusBarMgr.hideRechargeBtn(show)
    CSResourceMgr.getNodeByName(resNameBtns, "j7"):setVisible(show)
end

--新加的临时活动的按钮
function StatusBarMgr.showNewBtn(show)
    CSResourceMgr.getNodeByName(resNameBtns, "j11"):setVisible(show)
end

return StatusBarMgr