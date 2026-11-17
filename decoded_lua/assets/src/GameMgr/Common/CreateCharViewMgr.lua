local CreateCharViewMgr = {}

CreateCharViewMgr.AVATAR_TYPE = {39, 40, 41, 69}

local resName = {}
local plistName = {}
local spName = {}
local storyRes = {}
local playerTag = ""
local outlineColor = {}

function CreateCharViewMgr.Init()
    print("CreateCharViewMgr初始化")

    resName = 
    {
        "UI/Login/CreateCharSel.csb",
        "UI/Login/CreateCharTitle.csb",
    }
    plistName = 
    {
        "UI/Login/setskin.plist",
        --"Spine/effects/juesechuangjianlizi.plist",
    }
    spName = 
    {
        {res="Spine/effects/Ui_juesechuangjian_zhengmian.png", tag="back"},
        {res="Spine/effects/Ui_juesechuangjian_beimian.png", tag="front"},
    }
    storyRes = 
    {
        "UI/Login/StoryBoard.csb",
        "UI/Login/StoryContent.csb",
    }
    playerTag = "CreateCharViewMgr"
    outlineColor = {r=0,g=0,b=0,a=51}
end

function CreateCharViewMgr.show(scene)
    --CreateCharViewMgr.showStory(scene)
    local LoginSend = require("src.Net.Send.LoginSend")
    local uiStatus = 1
    local boolOpen = false
    local boolPlayerSkinChose = false
    local skinVec = {}
    
    local function loadCSB()
        local layerA = CSResourceMgr.createRes(scene, resName[1])
        layerA:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName[1], 320, 480)
        CocosModuleMgr.setEdgeDistance(layerA, nil, nil, nil, 0)
        CSResourceMgr.getNodeByName(resName[1], "db"):setVisible(false)

        local layerB = CSResourceMgr.createRes(scene, resName[2])
        layerB:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName[2], 320, 480)
        CocosModuleMgr.setEdgeDistance(layerB, nil, nil, 0, nil)
        layerB:setVisible(false)
        
        --背景人物跑动
        local bgNode = CSResourceMgr.getNodeByName(resName[1], "background")
        CSResourceMgr.getNodeByName(resName[1], "frontground"):zorder(3)
        local playerPosInfo = {
            {x=200, y=650, scale=0.35*1.4, z=2, dir=1},
            {x=540, y=610, scale=0.45*1.4, z=4, dir=-1},
            {x=400, y=670, scale=0.3*1.4, z=1, dir=-1},
            {x=480, y=610, scale=0.45*1.4, z=4, dir=1},
        }
        local petPosInfo = {
            {x=150, y=650, scale=0.35*0.7, z=2, dir=1},
            {x=600, y=610, scale=0.45*0.7, z=4, dir=-1},
            {x=430, y=675, scale=0.3*0.7, z=1, dir=-1},
        }
        local idVec = {}
        local movePosxVec = {-200,120,-150,-300}
        local moveTimeVec = {}
        for var=1, #playerPosInfo do
        	idVec[var] = GetRandom.random(5, 50)
        	--movePosxVec[var] = GetRandom.random(-200, 200)
            moveTimeVec[var] = GetRandom.random(1, 5)
        end
        local function moveFunc(ani, scale, movepx, waitTime)
            if movepx==0 then
            	return
            end
        	ani:performWithDelay(function()
        	    if movepx>0 then
                    ani:setScale(scale, scale)
        	    else
                    ani:setScale(-scale, scale)
        	    end
        	    local speed = 200
        	    local movetime = math.abs(movepx)/speed
        	    if ani.res then
        	    	AnimationMgr.playAni(ani.res, "walk", true, ani.tag)
        	    else
                    PlayerAnimeMgr.playAni(ani.tag, "walk", true)
        	    end
        	    transition.moveBy(ani, {x=movepx, time=movetime})
        	    ani:performWithDelay(function()
                    if ani.res then
                        AnimationMgr.playAni(ani.res, "idle", true, ani.tag)
                    else
                        PlayerAnimeMgr.playAni(ani.tag, "idle", true)
                    end
                    moveFunc(ani, scale, -movepx, waitTime)
        	    end, movetime)
            end, waitTime)
        end
        for var=1, #petPosInfo do
        	local petid = PokemonInfo.getRandomPokemonID()
        	local pInfo = petPosInfo[var]
        	local petRes = PokemonInfo.getPokemonResByID(petid)
            local ani = AnimationMgr.createAni(bgNode, petRes, pInfo.x, pInfo.y, "CreateCharViewMgr"..var)
            AnimationMgr.playAni(ani.res, "idle", true, ani.tag)
            AnimationMgr.setSkin(ani.res, 0, ani.tag)
            ani:setScale(pInfo.scale*pInfo.dir, pInfo.scale)
            ani:zorder(pInfo.z)
            moveFunc(ani, pInfo.scale, movePosxVec[var], moveTimeVec[var])
        end
        for var=1, #playerPosInfo do
            local fashionInfo = {GetRandom.random(1, 10), 1000+idVec[var], 2000+idVec[var], 3000+idVec[var]}
            local pInfo = playerPosInfo[var]
            local tag = "CreateCharViewMgr"..var
            local ani = PlayerAnimeMgr.createPlayer(bgNode, {x=pInfo.x, y=pInfo.y, skin=fashionInfo}, tag)
            ani:setScale(pInfo.scale*pInfo.dir, pInfo.scale)
            ani:zorder(pInfo.z)
            moveFunc(ani, pInfo.scale, movePosxVec[var], moveTimeVec[var])
        end
        
        local function addSkinEffect()
            local particle = CSResourceMgr.createParticle(PlayerAnimeMgr.getPlayer(playerTag), plistName[1], 0, 0)
            particle:setScale(0.5)
            particle:setLocalZOrder(10)
        end

        local avtName = {"fashion0", "fashion1", "fashion2", "fashion16"}    --要与CreateCharViewMgr.AVATAR_TYPE对应
        local avatarIdVec = {}
        local avatarBtnVec = {}
        local aviconRes = {"Player/Avatar/tou_2.png", "Player/Avatar/shang_2.png", "Player/Avatar/xia_2.png", "Player/Avatar/face_2.png"}
        local avtitleColor = {{r=227,g=233,b=255,a=255}, {r=255,g=255,b=255,a=255}}
        for var=1, #CreateCharViewMgr.AVATAR_TYPE do
            CSResourceMgr.setLabelColor(resName[1], "partname"..var, avtitleColor[1])
            CSResourceMgr.setLabelString(resName[1], "partname"..var, avtName[var], "", outlineColor, nil, 120)
            CSResourceMgr.clickEventBinding(resName[1], "avatar"..var, function()
                CSResourceMgr.setLabelString(resName[1], "avtitle", avtName[var], "", outlineColor, nil, 80)
                CSResourceMgr.setSpriteTexture(resName[1], "avtitleicon", aviconRes[var])
                for n=1, #CreateCharViewMgr.AVATAR_TYPE do
                    CSResourceMgr.setLabelColor(resName[1], "partname"..n, avtitleColor[1])
                    CSResourceMgr.setButtonEnabled(resName[1], "avatar"..n, true)
                    CSResourceMgr.getNodeByName(resName[1], "list"..n):setVisible(false)
                end
                CSResourceMgr.setLabelColor(resName[1], "partname"..var, avtitleColor[2])
                CSResourceMgr.setButtonEnabled(resName[1], "avatar"..var, false)
                CSResourceMgr.getNodeByName(resName[1], "list"..var):setVisible(true)
                if uiStatus==1 then
                    CSResourceMgr.playAction(resName[1], 0, 5, false)
                end
                uiStatus = 2
            end, nil, nil, "dressMenu")
            local avVec = SystemInfo.getGlobalConfigAddInfoByID(CreateCharViewMgr.AVATAR_TYPE[var]).values
            avVec = avVec or {}
            avatarIdVec[var] = avVec
            avatarBtnVec[var] = {}
            local list = CSResourceMgr.getNodeByName(resName[1], "list"..var)
            for i=1, #avVec do
                local parent = CSResourceMgr.getNodeByName(resName[1], "example"):clone()
                list:pushBackCustomItem(parent)
                parent:setVisible(true)
                local fashionId = avVec[i]
                local iconRes = ItemInfo.getFashionItemInfoById(fashionId).filePath
                local icon = CSResourceMgr.seekNodeByName(parent, "icon")
                CSResourceMgr.setSpriteTextureByNode(icon, iconRes)
                icon:setScale(1.1)
                local selbtn = CSResourceMgr.seekNodeByName(parent, "selbtn")
                avatarBtnVec[var][i] = selbtn
                CSResourceMgr.clickEventBindingByNode(selbtn, function()
                    boolPlayerSkinChose = true
                    PlayerAnimeMgr.setPlayerSkin(playerTag, fashionId)
                    skinVec[var] = fashionId
                    for k=1, #avVec do
                        CSResourceMgr.setButtonEnabledByNode(avatarBtnVec[var][k], true)
                    end
                    CSResourceMgr.setButtonEnabledByNode(selbtn, false)
                    addSkinEffect()
                end, nil, "dress")
            end
            --悬浮动画
            local btn = CSResourceMgr.getNodeByName(resName[1], "avatar"..var)
            btn:performWithDelay(function()
                local sequence = transition.sequence({
                    cc.MoveBy:create(0.1, cc.p(-1.5, -1)),
                    cc.MoveBy:create(0.1, cc.p(-1.7, 1)),
                    cc.MoveBy:create(0.1, cc.p(-1.5, -2)),
                    cc.MoveBy:create(0.1, cc.p(1.2, -1.5)),
                    cc.MoveBy:create(0.1, cc.p(3, 1.5)),
                    cc.MoveBy:create(0.1, cc.p(2, 0.5)),
                    cc.MoveBy:create(0.1, cc.p(-1, 2)),
                    cc.MoveBy:create(0.1, cc.p(-0.5, -0.5)),
                })
                local ani = cc.RepeatForever:create(sequence)
                btn:runAction(ani)
            end, 0.3*var)
        end
        
        local aniBack = CSResourceMgr.getNodeByName(resName[1], "ani")
        aniBack:setPosition(290, 270)
        AnimationMgr.createAni(aniBack, spName[1].res, 0, 315, spName[1].tag):zorder(-1)
        AnimationMgr.playAni(spName[1].res, "animation", true, spName[1].tag)
        local playerAni = PlayerAnimeMgr.createPlayer(aniBack, {skin={avatarIdVec[1][1], avatarIdVec[2][1], avatarIdVec[3][1]}}, 
            playerTag)
        playerAni:setScale(2)
        AnimationMgr.createAni(aniBack, spName[2].res, 0, 315, spName[2].tag)
        AnimationMgr.playAni(spName[2].res, "animation", true, spName[2].tag)

        local function setRandomSkin()
            for var=1, #CreateCharViewMgr.AVATAR_TYPE do
                local randomIndex = GetRandom.random(1, #avatarIdVec[var])
                local aid = avatarIdVec[var][randomIndex]
                for k, v in pairs(avatarBtnVec[var]) do
                    CSResourceMgr.setButtonEnabledByNode(v, true)
                end
                CSResourceMgr.setButtonEnabledByNode(avatarBtnVec[var][randomIndex], false)
                skinVec[var] = aid
            end
            PlayerAnimeMgr.setPlayerSkins(playerTag, skinVec)
            addSkinEffect()
        end

        CSResourceMgr.setLabelColor(resName[1], "name", {r=255,g=246,b=0,a=255})
        CSResourceMgr.setLabelString(resName[1], "name", "login28", "", {r=0,g=0,b=0,a=255}, nil, 200)
        CSResourceMgr.setLabelColor(resName[2], "title", {r=80,g=61,b=35,a=255})
        CSResourceMgr.setLabelString(resName[2], "title", "login25", "", {r=221,g=192,b=138,a=255}, nil, 230)

        local nickname_u = CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resName[1], "namedb"), 
            "empty.png", 230, 40, 115, 20, 24, LoginViewMgr.DEFAULT_NICKNNAME_MAXLENGTH, "login23")
        
        local oktitleColor = {{r=250,g=242,b=219,a=255}, {r=255,g=255,b=255,a=255}}
        local okoutlineColor = {{r=0,g=0,b=0,a=63,w=3}, {r=0,g=0,b=0,a=12,w=3}}
        CSResourceMgr.setLabelColor(resName[1], "oktitle", oktitleColor[1])
        CSResourceMgr.setLabelString(resName[1], "oktitle", "login24", "", okoutlineColor[1], nil, 150)
        CSResourceMgr.buttonEventBinding(resName[1], "ok", function()
            CSResourceMgr.setLabelColor(resName[1], "oktitle", oktitleColor[2])
            CSResourceMgr.setLabelString(resName[1], "oktitle", "login24", "", okoutlineColor[2], nil, 150)
        end, function()
            CSResourceMgr.setLabelColor(resName[1], "oktitle", oktitleColor[1])
            CSResourceMgr.setLabelString(resName[1], "oktitle", "login24", "", okoutlineColor[1], nil, 150)
            if nickname_u:getText()=="" then
                --StandardTipsMgr.show(1, "11111")
                return
            end
            NetInterface.sendWithBlock("MC_AppointNickName_Ack", function()
                LoginSend.sendCM_AppointNickName_Req(nickname_u:getText())
                local skinInfo = {skinVec[1], skinVec[2], skinVec[3], 0, 0, skinVec[4]}
                CharInfo.set({nickname=nickname_u:getText(), gender=0, curfashion=skinInfo})
            end, function()
                CreateCharViewMgr.hide()
                --开始播放滚动剧情
                --[[
                local scrollLabel = CSResourceMgr.getNodeByName(storyRes[2], "content")
                transition.moveTo(scrollLabel, {time=30, y=2000})
                scrollLabel:performWithDelay(function()
                CSResourceMgr.getNodeByName(storyRes[2], "start"):setVisible(true)
                end, 10)]]
                GameGuideMgr.getPet()
            end, function(code)
                StandardTipsMgr.show(1, CocosModuleMgr.createStringWithFormat({"login30", code}))
            end)
        end, nil, function()
            CSResourceMgr.setLabelColor(resName[1], "oktitle", oktitleColor[1])
            CSResourceMgr.setLabelString(resName[1], "oktitle", "login24", "", okoutlineColor[1], nil, 150)
        end)

        CSResourceMgr.clickEventBinding(resName[1], "random", function()
            nickname_u:setText(LuaSqlite.getLanguageByKey("petname"..GetRandom.random(1, 151))..string.char(GetRandom.random(65, 90))
                ..string.char(GetRandom.random(97, 122)))
            if not boolPlayerSkinChose then
                setRandomSkin()
            end
        end, "", 3)
        CSResourceMgr.callButtonFunc(resName[1], "random")

        CSResourceMgr.setSpriteTexture(resName[1], "stagetitle", CocosModuleMgr.getWordImage("facelift_create_title.png"))
        CSResourceMgr.setButtonStringColor(resName[1], "change", {r=229,g=245,b=255,a=255})
        CSResourceMgr.setButtonString(resName[1], "change", "login29", "", {r=0,g=0,b=0,a=63,w=3})
        CSResourceMgr.clickEventBinding(resName[1], "change", function()
            for var=1, #CreateCharViewMgr.AVATAR_TYPE do
                CSResourceMgr.getNodeByName(resName[1], "line"..var):setVisible(true)
                CSResourceMgr.getNodeByName(resName[1], "avatar"..var):setVisible(true)
            end
            CSResourceMgr.playAction(resName[1], 50, 60, false)
            CSResourceMgr.getNodeByName(resName[1], "change"):setVisible(false)
            boolOpen = true
        end, nil, nil, "dressMenu")

        CSResourceMgr.clickEventBinding(resName[1], "block", function()
            if boolOpen then
                local function hideAni()
                    CSResourceMgr.playActionWithCallback(resName[1], 70, 80, 1, function()
                        for var=1, #CreateCharViewMgr.AVATAR_TYPE do
                            CSResourceMgr.getNodeByName(resName[1], "line"..var):setVisible(false)
                            CSResourceMgr.getNodeByName(resName[1], "avatar"..var):setVisible(false)
                            CSResourceMgr.setButtonEnabled(resName[1], "avatar"..var, true)
                        end
                    end)
                end
                if uiStatus==2 then
                    CSResourceMgr.playAction(resName[1], 30, 35, false)
                    CSResourceMgr.playActionWithCallback(resName[1], 30, 35, 1, function()
                        hideAni()
                    end)
                else
                    hideAni()
                end
                uiStatus = 1
                CSResourceMgr.getNodeByName(resName[1], "change"):setVisible(true)
                boolOpen = false
            else
                CSResourceMgr.callButtonFunc(resName[1], "change")
            end
        end)

        CSResourceMgr.clickEventBinding(resName[2], "close", function()
            CreateCharViewMgr.hide()
            NetInterface.Init()
            SceneMgr.replaceScene(scene, "LoginScene")
        end)
        CSResourceMgr.getNodeByName(resName[2], "close"):setVisible(false)

        local circle1 = CSResourceMgr.getNodeByName(resName[1], "circle1")
        local ani = cc.RepeatForever:create(cc.RotateBy:create(10, 180))
        circle1:runAction(ani)
        local circle2 = CSResourceMgr.getNodeByName(resName[1], "circle2")
        local ani = cc.RepeatForever:create(cc.RotateBy:create(10, -180))
        circle2:runAction(ani)

        local diff = CocosModuleMgr.getScreenSizeDiff()
        if diff<0 then
            local titlenode = CSResourceMgr.getNodeByName(resName[1], "avtitledb")
            local cposy = titlenode:getPositionY()
            titlenode:setPositionY(cposy+diff)
            for var=1, #CreateCharViewMgr.AVATAR_TYPE do
                local list = CSResourceMgr.getNodeByName(resName[1], "list"..var)
                local lsize = list:getContentSize()
                list:setContentSize(lsize.width, lsize.height+diff)
            end
            local listdb = CSResourceMgr.getNodeByName(resName[1], "listdb")
            local ldbsize = listdb:getContentSize()
            listdb:setContentSize(ldbsize.width, ldbsize.height+diff)
        end
        
        --local parNode = CSResourceMgr.createParticle(aniBack, plistName[2], 0, 200)
        --parNode:setScale(2)
    end
    
    local function playCSB()
        local node1 = CSResourceMgr.getNodeByName(resName[1], "db")
        node1:setVisible(true)
        CocosModuleMgr.showUIAnimation(node1, "up")
        local node2 = CSResourceMgr.getCsbObj(resName[2])
        node2:setVisible(true)
        CocosModuleMgr.showUIAnimation(node2, "down")
    end
    
    local funcTable = {loadCSB, playCSB}
    UnblockLoader.load(funcTable, "CreateCharViewMgr")
end

function CreateCharViewMgr.hide()
    for var=1, #spName do
        AnimationMgr.removeGafObjectByTag(spName[var].res, spName[var].tag)
    end
    for var=1, #plistName do
        CSResourceMgr.removeParticle(plistName[var])
    end
    PlayerAnimeMgr.removePlayerByTag(playerTag)
    for var=1, #CreateCharViewMgr.AVATAR_TYPE do
        local list = CSResourceMgr.getNodeByName(resName[1], "list"..var)
        list:removeAllItems()
    end
    for var=1, #resName do
        CSResourceMgr.removeCSObjectByTag(resName[var])
    end
end

function CreateCharViewMgr.showStory(scene)
    local layerA = CSResourceMgr.createRes(scene, storyRes[1])
    layerA:setLocalZOrder(CocosModuleMgr.ZORDER_WORLDMAP)
    CSResourceMgr.setRelativePosition(storyRes[1], 320, 480)

    local layerB = CSResourceMgr.createRes(scene, storyRes[2])
    layerB:setLocalZOrder(CocosModuleMgr.ZORDER_WORLDMAP)
    CSResourceMgr.setRelativePosition(storyRes[2], 320, 480)
    CocosModuleMgr.setEdgeDistance(layerB, nil, nil, nil, 0)
    
    local diff = CocosModuleMgr.getScreenSizeDiff()
    local panel = CSResourceMgr.getNodeByName(storyRes[2], "panel")
    local psize = panel:getContentSize()
    panel:setContentSize(psize.width, psize.height+diff)
    local diban = CSResourceMgr.getNodeByName(storyRes[2], "upedge")
    local dposy = diban:getPositionY()
    diban:setPositionY(dposy+diff)
    local title = CSResourceMgr.getNodeByName(storyRes[2], "line")
    local tposy = title:getPositionY()
    title:setPositionY(tposy+diff)
    local close = CSResourceMgr.getNodeByName(storyRes[2], "skip")
    local cposy = close:getPositionY()
    close:setPositionY(cposy+diff)
    
    CSResourceMgr.setButtonString(storyRes[2], "start", "login24", "", outlineColor)
    CSResourceMgr.clickEventBinding(storyRes[2], "start", function()
        CreateCharViewMgr.hideStory()
    	GameGuideMgr.getPet()
    end, "", 1)
    CSResourceMgr.clickEventBinding(storyRes[2], "skip", function()
        CSResourceMgr.callButtonFunc(storyRes[2], "start")
    end, "", 2)
    CSResourceMgr.setLabelString(storyRes[2], "title", "login31", "", outlineColor)
    CSResourceMgr.setLabelString(storyRes[2], "content", "quest1000", "", {r=0,g=56,b=118,a=255})
    CSResourceMgr.setLabelMaxWidth(storyRes[2], "content", 500)
    CSResourceMgr.getNodeByName(storyRes[2], "start"):setVisible(false)
end

function CreateCharViewMgr.hideStory()
    for var=1, #storyRes do
        CSResourceMgr.removeCSObjectByTag(storyRes[var])
    end
end

return CreateCharViewMgr