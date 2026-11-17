local PersonalCenterMgr = {}

local resName = ""
local resNameS = ""
local playerInfoTabel = {}

local lifeskill = {"personalInfo4","personalInfo5","personalInfo6"}

function PersonalCenterMgr.Init()
	resName = "Charactor/CharactorBoard.csb"
    resNameS = "Charactor/CharSignView.csb"
    playerInfoTabel = {}
end

function PersonalCenterMgr.setPlayerInfo(playerInfo)
    playerInfoTabel = playerInfo
end

function PersonalCenterMgr.show(scene, charID)
    if not NetInterface.isConnect then
        return
    end
    NetInterface.sendWithBlock("GC_GetFriendDetail_Ack", function()
        local ChatUserSend = require("src.Net.Send.ChatUserSend")
        ChatUserSend.sendCG_GetFriendDetail_Req({friendID = tostring(charID)})
    end, function()
        UIStack.push("PersonalCenterMgr", PersonalCenterMgr.hide, false)
        GameAudio.playUISound("popup")
        PersonalCenterMgr.open(scene, charID)            
    end, function(code)
        TipsMgr.showError(scene, code)
    end)
end

function PersonalCenterMgr.open(scene, charID)
    
	local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.setFullScreen(resName)
        -- CocosModuleMgr.setEdgeDistance(curLayer, nil, nil, nil, 0, false)
        CSResourceMgr.getNodeByName(resName, "background"):setVisible(false)

        -- local diff = CocosModuleMgr.getScreenSizeDiff()
        -- local background = CSResourceMgr.getNodeByName(resName, "background")
        -- local bgsize = background:getContentSize()
        -- background:setContentSize(bgsize.width, bgsize.height+diff)
        -- local charFrame = CSResourceMgr.getNodeByName(resName, "charFrame")
        -- local cfsize = charFrame:getContentSize()
        -- charFrame:setContentSize(cfsize.width, cfsize.height+diff)
        -- local diwen = CSResourceMgr.getNodeByName(resName, "diwen")
        -- local dwsize = diwen:getContentSize()
        -- diwen:setContentSize(dwsize.width, dwsize.height+diff)
        -- local diwen = CSResourceMgr.getNodeByName(resName, "diwen")
        -- local dwsize = diwen:getContentSize()
        -- diwen:setContentSize(dwsize.width, dwsize.height+diff)
        -- local signBG = CSResourceMgr.getNodeByName(resName, "signBG")
        -- local sbsize = signBG:getContentSize()
        -- signBG:setContentSize(sbsize.width+diff, sbsize.height)
        -- local node = CSResourceMgr.getNodeByName(resName, "node")
        -- local nposy = node:getPositionY()
        -- node:setPositionY(nposy+diff)
        -- local signFrame = CSResourceMgr.getNodeByName(resName, "signFrame")
        -- local sfposy = signFrame:getPositionY()
        -- signFrame:setPositionY(sfposy+diff)
        -- local playerAnime = CSResourceMgr.getNodeByName(resName, "playerAnime")
        -- local paposy = playerAnime:getPositionY()
        -- playerAnime:setPositionY(paposy+diff)
        -- local signIcon = CSResourceMgr.getNodeByName(resName, "signIcon")
        -- local siposy = signIcon:getPositionY()
        -- signIcon:setPositionY(siposy+diff)
    end
    
    local function initCSB()
        local level = playerInfoTabel.level
        local id = CharInfo.getCharID()
        if id == charID then
            local exp = CharInfo.getExp()
            if level > 1 then
                local befLvInfo = ExperienceInfo.getExperienceInfoByID(level-1)
                local curLvInfo = ExperienceInfo.getExperienceInfoByID(level)
                local totleExp = curLvInfo.roleExp - befLvInfo.roleExp
                local curExp = exp - befLvInfo.roleExp
                CSResourceMgr.setLabelString(resName, "exp", curExp.."/"..totleExp)
                local expBar = CSResourceMgr.getNodeByName(resName, "expBar")
                expBar:setPercent((curExp/totleExp)*100)
            else
                local curLvInfo = ExperienceInfo.getExperienceInfoByID(level)
                CSResourceMgr.setLabelString(resName, "exp", exp.."/"..curLvInfo.roleExp)
                local expBar = CSResourceMgr.getNodeByName(resName, "expBar")
                expBar:setPercent((exp/curLvInfo.roleExp)*100)
            end
        else
            local expBG = CSResourceMgr.getNodeByName(resName, "expBG")
            expBG:setVisible(false)
            CSResourceMgr.setButtonEnabled(resName, "signBG", false)
            local fashionBtn = CSResourceMgr.getNodeByName(resName, "fashionBtn")
            fashionBtn:setVisible(false)
            local bookBtn = CSResourceMgr.getNodeByName(resName, "bookBtn")
            bookBtn:setVisible(false)
            local treeBtn = CSResourceMgr.getNodeByName(resName, "treeBtn")
            treeBtn:setVisible(false)
        end
		local nameBG = CSResourceMgr.getNodeByName(resName, "nameBG")
        local nameNode = CSResourceMgr.getNodeByName(resName, "name")
        local nameDB = display.newSprite("Charactor/shuruk.png")
        local writeNameBtn = CSResourceMgr.getNodeByName(resName, "closeBtn"):clone()
        local lsBG = CSResourceMgr.getNodeByName(resName, "lsBG")
        local writeBtnRes  = "Charactor/gaiming.png"

        nameNode:setFontSize(20) 
        
        writeNameBtn:setPosition(-112,10) 
        nameDB:addTo(nameBG)
        writeNameBtn:addTo(lsBG)
        nameDB:setPosition(280,22)

        CSResourceMgr.setButtonTextureByNode(writeNameBtn,writeBtnRes,writeBtnRes,writeBtnRes)
        CSResourceMgr.clickEventBindingByNode(writeNameBtn, function()
            local PlayerChangeNameMgr = require("src.GameMgr.Player.PlayerChangeNameMgr")
            PlayerChangeNameMgr.init()
            PlayerChangeNameMgr.show(SceneMgr.getRunningScene,function(nameStr)
                    CSResourceMgr.getNodeByName(resName, "name"):setString(nameStr)
                end) 
        end,3)
		
        CSResourceMgr.setLabelString(resName, "charTitle", "personalInfo1", "", {r=71,g=138,b=194,a=255})
        CSResourceMgr.setLabelColor(resName, "charTitle", {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelString(resName, "bookTitle", "personalInfo10", "", {r=209,g=138,b=0,a=255})
        CSResourceMgr.setLabelColor(resName, "bookTitle", {r=255,g=255,b=255,a=255})

        CSResourceMgr.setLabelString(resName, "expLabel", "personalInfo21")
        CSResourceMgr.setLabelString(resName, "signTitle", "personalInfo22")

        CSResourceMgr.setLabelString(resName, "ownLabel", "train187")
        CSResourceMgr.setLabelString(resName, "foundLabel", "train186")

        CSResourceMgr.setLabelString(resName, "lvLabel", "personalInfo11")
        CSResourceMgr.setLabelString(resName, "idLabel", "personalInfo12")
        CSResourceMgr.setLabelString(resName, "fightPowerLabel", "personalInfo13")
        CSResourceMgr.setLabelString(resName, "unionLabel", "personalInfo14")
        CSResourceMgr.setLabelString(resName, "achPointLabel", "personalInfo15")
        CSResourceMgr.setLabelString(resName, "arenaScoreLabel", "personalInfo16")
        CSResourceMgr.setLabelString(resName, "arenaPointLabel", "personalInfo17")
        CSResourceMgr.setLabelString(resName, "lostTowerLabel", "personalInfo18")
        CSResourceMgr.setLabelString(resName, "ltPowerLabel", "science22")
        local vipInfo = CharInfo.getVipInfoByID(playerInfoTabel.vipLevel)
        CSResourceMgr.setLabelString(resName, "name", playerInfoTabel.nickname)
        CSResourceMgr.setLabelString(resName, "vip", vipInfo.viplevel)
        CSResourceMgr.setLabelString(resName, "lv", level)
        CSResourceMgr.setLabelString(resName, "id", charID)
        local arenaPoint = playerInfoTabel.topRank or 0
        CSResourceMgr.setLabelString(resName, "arenaPoint", arenaPoint)
        local arenaScore = playerInfoTabel.arenaScore or 0
        CSResourceMgr.setLabelString(resName, "arenaScore", arenaScore)
        if playerInfoTabel.charSign ~= "" and playerInfoTabel.charSign then
            CSResourceMgr.setLabelString(resName, "signLabel", playerInfoTabel.charSign)
            CSResourceMgr.setLabelColor(resName, "signLabel", {r=217,g=234,b=255,a=255})
        else
            local id = CharInfo.getCharID()
            if id == charID then
                CSResourceMgr.setLabelString(resName, "signLabel", "personalInfo7")
            else
                CSResourceMgr.setLabelString(resName, "signLabel", "personalInfo20")
            end
            CSResourceMgr.setLabelColor(resName, "signLabel", {r=102,g=110,b=121,a=255})
        end
        local familyName = playerInfoTabel.familyName or "personalInfo3"
        CSResourceMgr.setLabelString(resName, "union", familyName)

        local ownCount = playerInfoTabel["pets.num"] or 0
        local foundCount = playerInfoTabel["diffPets.num"] or 0
        CSResourceMgr.setLabelString(resName, "ownCount", ownCount)
        CSResourceMgr.setLabelString(resName, "foundCount", foundCount)

        local fightPoint = playerInfoTabel.fightPoint or 0
        CSResourceMgr.setLabelString(resName, "fightPower", fightPoint)
        local achievementPoint = playerInfoTabel.achievementPoint or 0
        CSResourceMgr.setLabelString(resName, "achPoint", achievementPoint)
        if playerInfoTabel.lostTowerInfo then
            local losttowerfloor = playerInfoTabel.lostTowerInfo.currentFloor or 0
            CSResourceMgr.setLabelString(resName, "lostTower", losttowerfloor)
            
        else
            CSResourceMgr.setLabelString(resName, "lostTower", 0)
        end
        
        CSResourceMgr.setLabelString(resName, "ltPower", playerInfoTabel.scienceLevel or 0)
        CSResourceMgr.setSpriteTexture(resName, "ltPowerIcon", "Player/Science/icon_kejidian2.png")
        CSResourceMgr.getNodeByName(resName, "ltPowerIcon"):scale(0.9)

        local lifeskillcareer = playerInfoTabel.lifeSkill.career or 0
        local lifeskilllevel = playerInfoTabel.lifeSkill.level or 0
        if lifeskillcareer ~= 0 then
            CSResourceMgr.setLabelString(resName, "lifeskill", lifeskill[lifeskillcareer])
        else
            CSResourceMgr.setLabelString(resName, "lifeskill", "personalInfo2")
        end
        CSResourceMgr.setLabelString(resName, "lslevel", "Lv."..lifeskilllevel)

        CSResourceMgr.clickEventBinding(resName, "signBG", function()
            PersonalCenterMgr.setCharSign()
        end)

        local fashionBtn = CSResourceMgr.getNodeByName(resName, "fashionBtn")
        CSResourceMgr.setButtonStringByNode(fashionBtn, "personalInfo9", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setButtonStringColorByNode(fashionBtn, {r=255,g=255,b=255,a=255})
        local bookBtn = CSResourceMgr.getNodeByName(resName, "bookBtn")
        local bookLabel = CSResourceMgr.seekNodeByName(bookBtn,"bookLabel")
        CSResourceMgr.setLabelStringByNode(bookLabel, "train185", {r=0,g=0,b=0,a=255},nil,85)
        CSResourceMgr.setLabelColorByNode(bookLabel, {r=200,g=221,b=238,a=255})
        local treeBtn = CSResourceMgr.getNodeByName(resName, "treeBtn")
        CSResourceMgr.setButtonStringByNode(treeBtn, "achieveList9", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setButtonStringColorByNode(treeBtn, {r=255,g=255,b=255,a=255})
        local codeBtn = CSResourceMgr.getNodeByName(resName, "codeBtn")
        -- codeBtn:setVisible(false)
        CSResourceMgr.setButtonStringByNode(codeBtn, "qrcode4", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setButtonStringColorByNode(codeBtn, {r=255,g=255,b=255,a=255})

        local charLock = CharInfo.get().maplock
        local val = SystemInfo.getGlobalConfigAddInfoByID(21012).values[1]
        if charLock<val then
            CSResourceMgr.setButtonEnabledByNode(fashionBtn, false)
        end
        local level = CharInfo.getLevel()
        local val = SystemInfo.getGlobalConfigAddInfoByID(21016).values[1]
        if level<val then
            CSResourceMgr.setButtonEnabledByNode(treeBtn, false)
        end

        CSResourceMgr.clickEventBindingByNode(fashionBtn, function()
            GameAudio.playUISound("ok")
            AvatarViewMgr.show(scene)
            PersonalCenterMgr.hide()
        end)

        CSResourceMgr.clickEventBinding(resName, "closeBtn", function()
            GameAudio.playUISound("retract")
            PersonalCenterMgr.hide()
        end)
        
        CSResourceMgr.clickEventBindingByNode(bookBtn,function()
            GameAudio.playUISound("ok")
            SystemOptionsMgr.show(scene)
        end)

        CSResourceMgr.clickEventBindingByNode(codeBtn,function()
            GameAudio.playUISound("ok")
            --打开二维码
            PlayerShareMgr.show(scene)
        end)

        CSResourceMgr.clickEventBindingByNode(treeBtn,function()
            GameAudio.playUISound("ok")
            AchievementListMgr.show(scene,3)
        end)
    end
    
    local function playCSB()
        local db = CSResourceMgr.getNodeByName(resName, "background")
        db:setVisible(true)
        CocosModuleMgr.showUIAnimation(db, "down")

        local playerAniNode = PlayerAnimeMgr.createPlayer(CSResourceMgr.getNodeByName(resName,"playerAnime"), {gender=CharInfo.getSex(), 
            skin=playerInfoTabel.fashion.curFashion},PlayerAnimeMgr.COMMON_UI_TAG_STRING)
        playerAniNode:setScale(1.5)
    end

    --loadCSB() initCSB() playCSB()
    local funcTable = {loadCSB, initCSB, playCSB}
    UnblockLoader.load(funcTable, "PersonalCenterMgr")
end

function PersonalCenterMgr.setCharSign()
    local curEfx = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameS)
    curEfx:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
    CSResourceMgr.setFullScreen(resNameS)
    CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resNameS,"db"),"down")

    CSResourceMgr.setLabelString(resNameS, "title", "personalInfo22")

    local textfield = CSResourceMgr.getNodeByName(resNameS, "textfield")
    textfield:setPlaceHolder(LuaSqlite.getLanguageByKey("personalInfo7"))
    local saveBtn = CSResourceMgr.getNodeByName(resNameS, "saveBtn")
    CSResourceMgr.setButtonString(resNameS, "saveBtn", "arena19", "", {r=0,g=0,b=0,a=255})
    CSResourceMgr.setButtonStringColor(resNameS, "saveBtn", {r=255,g=255,b=255,a=255})

    CSResourceMgr.clickEventBindingByNode(saveBtn, function()
        NetInterface.sendWithBlock("GC_SetCharSign_Ack", function()
            local LoginSend = require("src.Net.Send.LoginSend")
            local str = textfield:getString()
            LoginSend.sendCG_SetCharSign_Req(SystemInfo.checkShieldString(str))
        end, function()
            local signInfo = textfield:getString()
            local signLabel = CSResourceMgr.getNodeByName(resName, "signLabel")
            if signInfo ~= "" then
                signInfo = SystemInfo.checkShieldString(signInfo)
                signLabel:setString(signInfo)
                signLabel:setColor({r=217,g=234,b=255,a=255})
            else
                signLabel:setString(LuaSqlite.getLanguageByKey("personalInfo7"))
                signLabel:setColor({r=102,g=110,b=121,a=255})
            end
            cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false)
            CSResourceMgr.removeCSObjectByTag(resNameS)
        end, function(code)
            TipsMgr.showError(scene, code)
        end)
    end)

    local cancelBtn = CSResourceMgr.getNodeByName(resNameS, "cancelBtn")
    CSResourceMgr.setButtonString(resNameS, "cancelBtn", "tips4", "", {r=0,g=0,b=0,a=255})
    CSResourceMgr.setButtonStringColor(resNameS, "cancelBtn", {r=255,g=255,b=255,a=255})
    CSResourceMgr.clickEventBindingByNode(cancelBtn, function()
        cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false)
        CSResourceMgr.removeCSObjectByTag(resNameS)
    end)

    local cover = CSResourceMgr.getNodeByName(resNameS, "cover")
    CSResourceMgr.clickEventBindingByNode(cover, function()
        cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false)
        CSResourceMgr.removeCSObjectByTag(resNameS)
    end)
end

function PersonalCenterMgr.hide()
    UnblockLoader.cancel("PersonalCenterMgr")
    PlayerAnimeMgr.removePlayerByTag(PlayerAnimeMgr.COMMON_UI_TAG_STRING,false)
    CSResourceMgr.removeCSObjectByTag(resNameS)
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("PersonalCenterMgr")
end

function PersonalCenterMgr.setResVisible(enable)
    local csbObj = CSResourceMgr.getCsbObj(resName)
    if csbObj then
        csbObj:setVisible(enable)
    end
end

return PersonalCenterMgr