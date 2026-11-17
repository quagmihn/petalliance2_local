require("Utils.SDKManager")
require("src.GameMgr.login")

local LoginViewMgr = {}

LoginViewMgr.DEBUG_MODE = false
LoginViewMgr.DEFAULT_SHOWSERVER_SIZE = 5
LoginViewMgr.DEFAULT_NICKNNAME_MAXLENGTH = 16

LoginViewMgr.selectZoneId = 0
LoginViewMgr.isKickByServer = 0
LoginViewMgr.loginWorld =  0
local resNameDiban = ""
local resNameServer = ""
local resNameTopBar = ""
local resNamePatch = ""
local loginAni = nil
local logoAni = nil

local serverData = {}
local serverList = {}
local charList = {}
local curMaxItemNum = 0
local curPageItem = {}
local curServerTab = 3

local selectCharId = 0

local LoginSend = nil
local PortalSend = nil
local GenInfo = nil
local NetMgr = nil
local Reconnector = nil
local loginWorld = "1"

function LoginViewMgr.Init()
    print("LoginViewMgr初始化")
    
    LoginViewMgr.selectZoneId = 0
    
    resNameDiban = "UI/Login/LoginBg.csb"
    resNameServer = "UI/Login/SelectServer.csb"
    resNameTopBar = "UI/Login/TopBar.csb"
    resNamePatch = "UI/Login/PatchVer.csb"
    loginAni = nil
    logoAni = nil
    
    serverData = {}
    serverList = {}
    charList = {}
    curMaxItemNum = 0
    curPageItem = {}
    curServerTab = 3
    
    selectCharId = 0
    
    LoginSend = require("src.Net.Send.LoginSend")
    GenInfo = require("src.Data.GenInfo")
    NetMgr = require("src.Net.NetMgr")
    Reconnector = require("src.Net.Reconnector")
    loginWorld = "1"
end

function LoginViewMgr.show(scene)
    CSResourceMgr.createRes(scene, resNameDiban)
    CSResourceMgr.setRelativePosition(resNameDiban, 320, 480)
    
    --[[
    local patchBar = CSResourceMgr.createRes(scene, resNamePatch)
    CSResourceMgr.setRelativePosition(resNamePatch, 320, 480)    
    CocosModuleMgr.setEdgeDistance(patchBar, nil, nil, nil, 0)
    ]]
    
    local topBar = CSResourceMgr.createRes(scene, resNameTopBar)
    topBar:setVisible(LoginViewMgr.DEBUG_MODE)
    CSResourceMgr.setRelativePosition(resNameTopBar, 320, 480)
    CocosModuleMgr.setEdgeDistance(topBar, nil, nil, 0, nil)
    
    local serverUI = CSResourceMgr.createRes(scene, resNameServer)
    CSResourceMgr.setRelativePosition(resNameServer, 320, 480)
    CSResourceMgr.setFullScreen(resNameServer)
    serverUI:zorder(CocosModuleMgr.ZORDER_WINDOW)
    serverUI:setVisible(false)
    
    -- if LuaSqlite.LANG_TYPE==1 then
    --     local detailInfo = CSResourceMgr.getNodeByName(resNameDiban, "tinfo"):clone()
    --     detailInfo:setFontSize(16)
    --     detailInfo:addTo(scene)
    --     detailInfo:zorder(1)
    --     CocosModuleMgr.setEdgeDistance(detailInfo, 10, nil, 10, nil)
    --     detailInfo:setAnchorPoint(0, 1)
    --     local dString = "批准文号：沪新出科数[2016]707号\nISBN：978-7-7979-0319-6\n游戏著作权人与出版服务单位：\n上海方寸信息科技有限公司"
    --     CSResourceMgr.setLabelStringByNode(detailInfo, dString, {r=0,g=0,b=0,a=0,w=1,s=1})
    -- end
    
    CSResourceMgr.setButtonString(resNameTopBar, "b1", "For iOS", "", {r=255,g=255,b=255,a=255,w=3})
    CSResourceMgr.setButtonStringColor(resNameTopBar, "b1", {r=42,g=69,b=85,a=255})
    CSResourceMgr.setButtonString(resNameTopBar, "b2", "login1", "", {r=255,g=255,b=255,a=255,w=3})
    CSResourceMgr.setButtonStringColor(resNameTopBar, "b2", {r=42,g=69,b=85,a=255})
    CSResourceMgr.setButtonString(resNameTopBar, "b3", "login2", "", {r=255,g=255,b=255,a=255,w=3})
    CSResourceMgr.setButtonStringColor(resNameTopBar, "b3", {r=42,g=69,b=85,a=255})
    CSResourceMgr.setLabelString(resNameTopBar, "t1", "Patch Ver:")
    local versionPlist = cc.FileUtils:getInstance():getValueMapFromFile(CONFIG_STORE_PATH.."version.plist")
    local localVersion = versionPlist["version"]
    if localVersion==nil then
        local filePath = cc.FileUtils:getInstance():fullPathForFilename("version.xml")
        localVersion = cc.FileUtils:getInstance():getStringFromFile(filePath)
    end
    CSResourceMgr.setLabelString(resNameTopBar, "t2", localVersion)
    CSResourceMgr.setLabelString(resNameDiban, "tinfo", "login3")
    CSResourceMgr.setLabelColor(resNameServer, "title", {r=255,g=255,b=83,a=255})
    CSResourceMgr.setLabelString(resNameServer, "title", "login32", "", {r=114,g=28,b=11,a=255}, nil, 240)
    CSResourceMgr.getNodeByName(resNameServer, "dk"):setLocalZOrder(2)
    CSResourceMgr.getNodeByName(resNameServer, "panel"):setLocalZOrder(3)
    local btnStr = {"login33", "login34", "login35"}
    local colorTable = {{r=255,g=243,b=227,a=255}, {r=227,g=233,b=255,a=255}}
    local outlineTable = {{r=89,g=47,b=5,a=255,w=1,s=1}, {r=10,g=22,b=65,a=255,w=1,s=1}}
    curServerTab = 3
    for var=1, #btnStr do
        local posy = CSResourceMgr.getNodeByName(resNameServer, "tab"..var):getPositionY()
        CSResourceMgr.setButtonString(resNameServer, "tab"..var, btnStr[var], "", outlineTable[2])
        CSResourceMgr.setButtonStringColor(resNameServer, "tab"..var, colorTable[2])
        CSResourceMgr.clickEventBinding(resNameServer, "tab"..var, function(sender)
            for v=1, #btnStr do
                CSResourceMgr.setButtonEnabled(resNameServer, "tab"..v, true)
                CSResourceMgr.setButtonString(resNameServer, "tab"..v, btnStr[v], "", outlineTable[2])
                CSResourceMgr.setButtonStringColor(resNameServer, "tab"..v, colorTable[2])
                --CSResourceMgr.getNodeByName(resNameServer, "tab"..v):setScale(1)
                CSResourceMgr.getNodeByName(resNameServer, "tab"..v):setLocalZOrder(0)
                --CSResourceMgr.getNodeByName(resNameServer, "tab"..v):setPositionY(posy)
            end
        	CSResourceMgr.setButtonEnabled(resNameServer, "tab"..var, false)
            CSResourceMgr.setButtonString(resNameServer, "tab"..var, btnStr[var], "", outlineTable[1])
            CSResourceMgr.setButtonStringColor(resNameServer, "tab"..var, colorTable[1])
            --CSResourceMgr.getNodeByName(resNameServer, "tab"..var):setScale(1.2)
            CSResourceMgr.getNodeByName(resNameServer, "tab"..var):setLocalZOrder(1)
            --CSResourceMgr.getNodeByName(resNameServer, "tab"..var):setPositionY(posy+5)
            curServerTab = var
            if var==1 then
                local tmpVec = {}
                for _k, _v in pairs(serverData) do
                    if _v.hot==Proto.WS_RECOMMEND then
                        table.insert(tmpVec, _v)
                	end
                end
                LoginViewMgr.setServerList(tmpVec)
            elseif var==2 then
                LoginViewMgr.checkMyServer()
            elseif var==3 then
                LoginViewMgr.setServerList(serverData)
            end
        end)
        if var==curServerTab then
            CSResourceMgr.setButtonEnabled(resNameServer, "tab"..var, false)
            CSResourceMgr.setButtonString(resNameServer, "tab"..var, btnStr[var], "", outlineTable[1])
            CSResourceMgr.setButtonStringColor(resNameServer, "tab"..var, colorTable[1])
            --CSResourceMgr.getNodeByName(resNameServer, "tab"..var):setScale(1.2)
            CSResourceMgr.getNodeByName(resNameServer, "tab"..var):setLocalZOrder(1)
            --CSResourceMgr.getNodeByName(resNameServer, "tab"..var):setPositionY(posy+5)
        end
    end
    local sequencel = transition.sequence({
        cc.FadeTo:create(1, 100),
        cc.FadeIn:create(0.5),
    })
    local actionl = cc.RepeatForever:create(sequencel)
    CSResourceMgr.getNodeByName(resNameDiban, "btn_l1"):runAction(actionl)
    
    --背景动画
    local loginBgNode = CSResourceMgr.getNodeByName(resNameDiban, "bg")
    local loginBgSize = loginBgNode:getContentSize()
    local screenDiff = CocosModuleMgr.getScreenSizeDiff()-178
    loginAni = AnimationMgr.createAni(loginBgNode, CocosModuleMgr.getWordImage("UI_denglujiemian.png"), loginBgSize.width/2, 
        loginBgSize.height/2)
    logoAni = AnimationMgr.createAni(loginBgNode, CocosModuleMgr.getWordImage("UI_denglujiemian_logo.png"), loginBgSize.width/2, 
        loginBgSize.height/2-screenDiff/2+30)
    CSResourceMgr.getNodeByName(resNameDiban, "touch"):zorder(1)
    
    --文字光泽 
    --[[
    local sequencet = transition.sequence({
        cc.FadeOut:create(1),
        cc.FadeIn:create(0.5),
    })
    local actiont = cc.RepeatForever:create(sequencet)
    CSResourceMgr.getNodeByName(resNamePatch, "pokemonlogo_glow"):runAction(actiont)
    local shineSp = display.newSprite(CocosModuleMgr.getWordImage("logo_shine.png"))
    local pokemonLogo = CSResourceMgr.getNodeByName(resNamePatch, "pokemonlogo")
    local pokemonlogo_glow = CSResourceMgr.getNodeByName(resNamePatch, "pokemonlogo_glow")
    CSResourceMgr.setSpriteTextureByNode(pokemonLogo, CocosModuleMgr.getWordImage("pokemonlogo.png"), false)
    CSResourceMgr.setSpriteTextureByNode(pokemonlogo_glow, CocosModuleMgr.getWordImage("pokemonlogo_glow.png"), false)
    local clip = CocosModuleMgr.maskSprite(pokemonLogo, shineSp, CocosModuleMgr.getWordImage("logo_shine_diban.png"), {x=0, y=0})
    clip:setPosition(pokemonLogo:getContentSize().width/2, pokemonLogo:getContentSize().height/2)
    shineSp:setPosition(-400, 0)
    local sequencec = transition.sequence({
        cc.MoveBy:create(2, cc.p(800, 0)),
        cc.CallFunc:create(function()
            shineSp:setPosition(-400, 0)
        end),
        cc.DelayTime:create(2),
    })
    local actionc = cc.RepeatForever:create(sequencec)
    shineSp:runAction(actionc)
    ]]
    
    CSResourceMgr.clickEventBinding(resNameDiban, "touch", function()
        print("touch event")
        if loginAni then
            AnimationMgr.playAni(loginAni.res, "idle", true)
        end
        if logoAni then
            AnimationMgr.playAni(logoAni.res, "idle", true)
        end
        charList = {}
        --XFangCunLogSender.logActivation()--激活日志调用
        GameLogMgr.OnGameStateChange(GameLogMgr.UserGameState.STATE_ACTIVATION)--激活日志调用
        CSResourceMgr.getNodeByName(resNameDiban, "btn_l1"):setVisible(true)
        CSResourceMgr.setButtonEnabled(resNameDiban, "touch", true)
        if device.platform == "android" and LoginViewMgr.DEBUG_MODE == false then
            -- Avoid waiting on FCManager; use a stable device-derived account.
            AllSDKManager.FangCun:loginLocal()
        elseif device.platform == "ios" and LoginViewMgr.DEBUG_MODE == false then
            iOSFunction.login()
        else
            NetMgr.getServerList()
        end
    end, nil, nil, "enter")
    CSResourceMgr.clickEventBinding(resNameTopBar, "b2", function()
        --SceneMgr.replaceScene(scene, "MainScene")
        local filePath = cc.FileUtils:getInstance():fullPathForFilename("share.jpg")
        print("share picture:", filePath)
        luaoc.callStaticMethod("SdkInterface", "weixinShare", {path=filePath, 
            listener = function(codeStr)
            	TipsMgr.show(scene, codeStr)
            end})
    end, "", 1)
    CSResourceMgr.clickEventBinding(resNameTopBar, "b3", function()
        --DebugInfoMgr.test()
        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, "是否生成一个新号？注意：生成后旧账号就找不回来了。", function()
            local username = UserSettings.get("username_device", 6)
            local id = tonumber(string.sub(username, -1, -1)) or 0
            username = string.sub(username, 1, -2)..id+1
            UserSettings.set({username_device=username}, 6)
        	DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "生成成功，请重启游戏。")
        end)
    end, "", 1)
    CSResourceMgr.clickEventBinding(resNameTopBar, "b1", function()
        if device.platform=="ios" then
            PlayerShareMgr.show()
        end
    end, "", 1)
    CSResourceMgr.clickEventBinding(resNameServer, "back", function()
        CSResourceMgr.getNodeByName(resNameDiban, "btn_l1"):setVisible(true)
        CSResourceMgr.setButtonEnabled(resNameDiban, "touch", true)
        serverUI:setVisible(false)
        AllSDKManager.FangCun:restart()
        if device.platform == "ios" then
            iOSFunction.logout()
        end
    end)
    CSResourceMgr.clickEventBinding(resNameServer, "enter", function()
        if LoginViewMgr.selectZoneId==0 then
        	TipsMgr.show(scene, "login11")
        else
            local serverInfo = nil
            for key, var in pairs(serverData) do
                if var.zoneID==LoginViewMgr.selectZoneId then
            		serverInfo = var
            		break
            	end
            end
            if serverInfo then
                if serverInfo.hot==Proto.WS_MAINTAIN and NetMgr.isWhiteNameUser~=true then
                    StandardTipsMgr.show(1, "login37")
                else
                    UserSettings.set({select_zoneid = LoginViewMgr.selectZoneId}, 6)
                    NetMgr.setServerInfo(serverInfo.ip, serverInfo.port)            
                    NetInterface.connectServer(function()
                        LoginViewMgr.autoLogin()
                    end, nil)
                end
            end
        end
    end)
    
    CSResourceMgr.setLabelString(resNameServer, "backtlt", "login21", "", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 180)
    CSResourceMgr.setLabelString(resNameServer, "entertlt", "login22", "", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 180)
    
    GameNoticeMgr.checkProto(scene)
    GameAudio.playMusic("Music/bgm/main.m4a")
    LoginViewMgr.playAnimation()


    
    if device.platform == "android" then --判断是否是旧版本
        local function exitGame()
            if device.platform == "android" then 
                AndroidFunction.exitApp()         
            end  
        end
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,versions = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getGameVersion", args, sig)
        if not ok then 
            print("androidFunction.getVersion() not found:need download new versions") 
            DialogBoxMgr.showDialogBox(scene, 1, "tips54",function() 
                ExitGameViewMgr.show(SceneMgr.getRunningScene,exitGame)
            end)
        end        
    end
    
end

function LoginViewMgr.playAnimation()
    if loginAni then
        AnimationMgr.playAni(loginAni.res, "animation", false)
    end
    if logoAni then
        AnimationMgr.playAni(logoAni.res, "animation", false)
    end
end

function LoginViewMgr.autoLogin()
    if (device.platform == "android" or device.platform == "ios") and LoginViewMgr.DEBUG_MODE == false then
        platformLogin_req()
    else
        LoginViewMgr.deviceCodeLogin()
    end
end

function LoginViewMgr.sendDeviceCodeLogin(params,needSave)
    --保存服务器信息log
    local serverparam = {}
    if LoginViewMgr.selectZoneId ~= nil then 
        --[[
        serverparam.serverid = serverList[LoginViewMgr.selectZoneId].world--LoginViewMgr.selectZoneId
        local desc = tostring(LoginViewMgr.selectZoneId)
        if serverList[LoginViewMgr.selectZoneId] ~=nil and serverList[LoginViewMgr.selectZoneId].desc ~=nil then 
            desc = serverList[LoginViewMgr.selectZoneId].desc
        end
        serverparam.servername = desc--serverList[LoginViewMgr.selectZoneId].desc
        ]]
        serverparam.serverid = GameLogMgr.roleInfo.serverId
        serverparam.servername = GameLogMgr.roleInfo.serverName
        print("serverparam.serverid and serverparam.servername is:",serverparam.serverid ,serverparam.servername)
    else 
        serverparam = nil
    end
   -- print("serverparam id,name"..serverparam.serverid,serverparam.servername)
    GameLogMgr.OnGameStateChange(GameLogMgr.UserGameState.STATE_SELECTSERVER,serverparam)
    ---------------------------------------------------
    NetInterface.sendWithBlock("GC_DEVICELOGIN_ACK", function()
        LoginSend.sendCG_DeviceLogin_Req(params)
        if needSave then
            UserSettings.set({username_device=username, password_device=password}, 6)
        end
    end,function()
        XFangCunLogSender.LoadTimeLogStart = os.time()
        local GenInfo = require("src.Data.GenInfo")
        if GenInfo.getCharCount()==0 then
            --如果没有角色，则创建角色
            CSResourceMgr.playActionWithCallback(resNameServer, 50, 60, 1, function()
                GameGuideMgr.createChar()
                GameLogMgr.OnGameStateChange(GameLogMgr.UserGameState.STATE_CREATECHAR)
                --CSResourceMgr.playAction(resNameCreate, 0, 10, false)
            end)
        else
            --如果有角色，则进入游戏
            local charInfo = GenInfo.getCharInfo(1)
            selectCharId = charInfo.userID
            LoginViewMgr.checkIn(selectCharId)
        end
    end, function(code)
        --TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"login12", code}))
        DialogBoxMgr.showTopDialogBox(SceneMgr.getRunningScene, 1, "device login failed:"..code, function()
            LoginViewMgr.gameReInit()
        end,nil,nil,false)
    end)
end

function LoginViewMgr.deviceCodeLogin()
    print("device login start")
    
    local username = UserSettings.get("username_device", 6) or ""
    local password = UserSettings.get("password_device", 6) or ""
    
    if (device.platform == "android" or device.platform == "ios") and LoginViewMgr.DEBUG_MODE == false then
        username = AllSDKManager.FangCun.userid_token["userId"]
        password = AllSDKManager.FangCun.userid_token["token"]
    end
    print("username:"..username)
    print("password:"..password)

    local needSave = false
    if username=="" then
        username = "fcpm"..device.getOpenUDID()
        print("create device username:", username)
        needSave = true
    end    
    if password=="" then
        password = crypto.md5("pswd#key$%@*`#"..device.getOpenUDID())
        print("create device password:", password)
        needSave = true
    end

    local params = {}
    params.id = username
    params.world = loginWorld
    params.token = password
    LoginViewMgr.sendDeviceCodeLogin(params,needSave)
end

function LoginViewMgr.deviceRelogin()
    print("device relogin start")
       
    NetInterface.sendWithBlock("GC_DEVICERELOGIN_ACK", function()
        LoginSend.sendCG_DeviceRelogin_Req()
    end,function()
        if CharInfo.getCharID()==0 then
            --如果没有角色，则创建角色
            GameGuideMgr.createChar()
        else
            --如果有角色，则进入游戏
            selectCharId = CharInfo.getCharID()
            LoginViewMgr.checkIn(selectCharId)
        end
    end, function(code)
        if device.platform == "android" then 
            --AndroidFunction.deviceLoginFailDialogue()
            DialogBoxMgr.showTopDialogBox(SceneMgr.getRunningScene, 1, "device login failed:"..code, function()
            LoginViewMgr.gameReInit()
        end,nil,nil,false)
        else 
            print("device relogin failed........"..code)
            DialogBoxMgr.showTopDialogBox(SceneMgr.getRunningScene, 1, "device login failed:"..code, function()
            LoginViewMgr.gameReInit()
        end,nil,nil,false)
        --[[
             DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "device relogin failed ", function()
                LoginViewMgr.gameReInit()
            end)   
            ]]        
        end
    end)
end

function LoginViewMgr.gameReInit()
    if AllSDKManager and AllSDKManager.FangCun then
        AllSDKManager.FangCun:resetLocalLogin()
    end
    expeditionalViewMgr.cleanup()
    BattleUIMgr.cleanBattleInfo()
    GameInit.Init(true)
    if device.platform == "ios" then
        iOSFunction.logout()
    end
     
    print("gameReInit~~~~~~~~")
    SceneMgr.replaceScene(SceneMgr.getRunningScene, "LoginScene")
end

function LoginViewMgr.setCharInfo(jsStr)
    local CharInfoUpdated = false
    if jsStr then
        charList = {}
        local ret, errMessage = pcall(function()
            local cjson = require("cjson")
            local j = cjson.decode(jsStr)
            for k, v in pairs(j) do
                if k=="characters" then
                    for key, var in pairs(v) do
                        print(key, var)
                        local charInfo = cjson.decode(var)
                        if charInfo.world then
                            charList[tonumber(charInfo.world)] = charInfo
                            --CharInfo.setCharWorld(tonumber(charInfo.world))
                        end                        
                    end
                end
            end
        end)
        if ret==true then
            CharInfoUpdated = true
        else
            print("服务器角色信息串格式不正确，解析失败")
        end
    end
    for key, var in pairs(curPageItem) do
        key = tonumber(var.world)
    	if charList[key] then
    		CSResourceMgr.seekNodeByName(var, "char"):setVisible(true)
            local level = CSResourceMgr.seekNodeByName(var, "level")
            CSResourceMgr.setLabelStringByNode(level, "LV "..charList[key].Level or 1, {r=0,g=0,b=0,a=255,w=1})
            local name = CSResourceMgr.seekNodeByName(var, "name")
            CSResourceMgr.setLabelStringByNode(name, charList[key].nickname or "", nil, nil, 350)
            local icon = CSResourceMgr.seekNodeByName(var, "icon")
            local fashionInfo = charList[key].fashion or {}
            CSResourceMgr.setSpriteTextureByNode(icon, CharInfo.getHeadIcon(fashionInfo.curFashion))
            icon:setScale(0.7)
    	end
    end
    if CharInfoUpdated and curServerTab==2 then
        LoginViewMgr.checkMyServer()
    end
end

function LoginViewMgr.checkMyServer()
    local tmpVec = {}
    for key, var in pairs(serverData) do
        if charList[tonumber(var.world)] then
            table.insert(tmpVec, var)
        end
    end
    LoginViewMgr.setServerList(tmpVec)
end

function LoginViewMgr.setServerListData(ListInfo)
    serverData = ListInfo
    LoginViewMgr.setServerList(ListInfo)
    --GameNoticeMgr.checkNotice(SceneMgr.getRunningScene)
end

function LoginViewMgr.setServerList(ListInfo)
    table.sort(ListInfo, function(a, b)
        if a and b then
            return a.zoneID>b.zoneID
            --[[
            if a.isNew==1 and b.isNew~=1 then
                return true
            elseif a.isNew~=1 and b.isNew==1 then
                return false
            end]]
        end
    	return false
    end)
    serverList = ListInfo
    if not CSResourceMgr.getCsbObj(resNameServer):isVisible() then
        CSResourceMgr.getCsbObj(resNameServer):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resNameServer, "db"), "down")
    end    
	
    curMaxItemNum = 0

    local zoneid = UserSettings.get("select_zoneid", 6)
    if zoneid then
        --设置LoginViewMgr.selectZoneId为上次登录的大区后，可以默认选上次登录的大区
        for key, var in ipairs(serverList) do
            if var.zoneID==zoneid then
                print("上次选择的zoneID", zoneid)
                local id = key
                local info = var
                table.remove(serverList, key)
                table.insert(serverList, 1, info)
                LoginViewMgr.setSelectedServer(1)
            end
        end
    else
        --默认选1区
        LoginViewMgr.setSelectedServer(1)
    end   
    
    local pageSize = math.ceil(#serverList/LoginViewMgr.DEFAULT_SHOWSERVER_SIZE)
    local curPage = 1
    CSResourceMgr.clickEventBinding(resNameServer, "left", function()
    	if curPage<=1 then
    		curPage = pageSize
    	else
    	    curPage = curPage - 1
    	end
        LoginViewMgr.loadCurServerListPage(curPage)
    end, "", 1)
    CSResourceMgr.clickEventBinding(resNameServer, "right", function()
        if curPage>=pageSize then
            curPage = 1
        else
            curPage = curPage + 1
        end
        LoginViewMgr.loadCurServerListPage(curPage)
    end, "", 1)
    local boolPageVisible = true
    if pageSize<=1 then
        boolPageVisible = false
    end
    CSResourceMgr.getNodeByName(resNameServer, "left"):setVisible(boolPageVisible)
    CSResourceMgr.getNodeByName(resNameServer, "right"):setVisible(boolPageVisible)
    LoginViewMgr.loadCurServerListPage(curPage)
end

function LoginViewMgr.loadCurServerListPage(page)
    UnblockLoader.cancel("LoginViewMgr-loadMoreServerList")
    local pageSize = math.ceil(#serverList/LoginViewMgr.DEFAULT_SHOWSERVER_SIZE)
    if pageSize>0 then
        CSResourceMgr.setLabelString(resNameServer, "page", page.."/"..pageSize, nil, {r=0,g=0,b=0,a=255,w=1,s=1})
    else
        CSResourceMgr.setLabelString(resNameServer, "page", "")
    end
    local panel = CSResourceMgr.getNodeByName(resNameServer, "panel")
    panel:removeAllChildren()
    local size = panel:getContentSize()

    local funcTable = {}
    curPageItem = {}
    for id=1, LoginViewMgr.DEFAULT_SHOWSERVER_SIZE do
        local index = id+(page-1)*LoginViewMgr.DEFAULT_SHOWSERVER_SIZE
        local var = serverList[index]
        if var then
            local function loadItem()
                local itemBtn = CSResourceMgr.getNodeByName(resNameServer, "example"):clone()
                local title = CSResourceMgr.seekNodeByName(itemBtn, "servername")
                CSResourceMgr.setButtonEnabledByNode(itemBtn, true)
                CSResourceMgr.clickEventBindingByNode(itemBtn, function(sender)
                    for k, v in pairs(curPageItem) do
                        CSResourceMgr.setButtonEnabledByNode(v, true)
                        CSResourceMgr.seekNodeByName(v, "selected"):setVisible(false)
                    end
                    CSResourceMgr.setButtonEnabledByNode(sender, false)
                    local selNode = CSResourceMgr.seekNodeByName(sender, "selected")
                    selNode:setVisible(true)
                    selNode:setScale(2.5)
                    transition.scaleTo(selNode, {scale=1, time=0.1})
                    LoginViewMgr.setSelectedServer(index)
                end)
                CSResourceMgr.setLabelStringByNode(title, var.desc, nil, nil, 260)
                local pointVec = {
                    [Proto.WS_MAINTAIN] = "UI/CommonFiles/fwq_ztqiu4.png", 
                    [Proto.WS_FREE]     = "UI/CommonFiles/fwq_ztqiu3.png",
                    [Proto.WS_RECOMMEND]= "UI/CommonFiles/fwq_ztqiu3.png",
                    [Proto.WS_CROWDED]  = "UI/CommonFiles/fwq_ztqiu2.png", 
                    [Proto.WS_FULL]     = "UI/CommonFiles/fwq_ztqiu.png",
                }
                local point = CSResourceMgr.seekNodeByName(itemBtn, "point")
                CSResourceMgr.setSpriteTextureByNode(point, pointVec[var.hot])
                point:setScale(0.7)
                if var.isNew==1 then
                    CSResourceMgr.seekNodeByName(itemBtn, "new"):setVisible(true)
                    local newtext = CSResourceMgr.seekNodeByName(itemBtn, "newtext")
                    CSResourceMgr.setLabelColorByNode(newtext, {r=255,g=252,b=0,a=255})
                    CSResourceMgr.setLabelStringByNode(newtext, "login38", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 50)
                else
                    CSResourceMgr.seekNodeByName(itemBtn, "new"):setVisible(false)
                end
                CSResourceMgr.seekNodeByName(itemBtn, "char"):setVisible(false)
                CSResourceMgr.seekNodeByName(itemBtn, "selected"):setVisible(false)
                if LoginViewMgr.selectZoneId==var.zoneID then
                    CSResourceMgr.seekNodeByName(itemBtn, "selected"):setVisible(true)
                    CSResourceMgr.setButtonEnabledByNode(itemBtn, false)
                else
                end
                itemBtn:addTo(panel)
                itemBtn:setVisible(true)
                itemBtn:setPosition(size.width/2, size.height-size.height/2/LoginViewMgr.DEFAULT_SHOWSERVER_SIZE*(1+(id-1)*2))
                itemBtn:setScaleY(0)
                transition.scaleTo(itemBtn, {scaleY = 1, time = 0.1})
                curPageItem[id] = itemBtn
                curPageItem[id].world = var.world
            end
            table.insert(funcTable, loadItem)
        end
    end
    table.insert(funcTable, function()
        LoginViewMgr.setCharInfo()
    end)

    UnblockLoader.load(funcTable, "LoginViewMgr-loadMoreServerList")
end

function LoginViewMgr.getCurrentWorld()
	return tonumber(loginWorld)
end

function LoginViewMgr.setSelectedServer(index)
    local var = serverList[index]
    if var==nil then
    	return
    end
    print("set select server:", index, var.desc, var.zoneID, var.ip, var.port, var.world)
    LoginViewMgr.selectZoneId = var.zoneID
	loginWorld = var.world
    GameLogMgr.roleInfo.serverId = tostring(var.world)
    GameLogMgr.roleInfo.serverName = var.desc
    LoginViewMgr.loginWorld = var.world or 0
    --print("GameLogMgr.roleInfo.serverId"..var.desc)
end

function LoginViewMgr.checkIn(charId, boolFirst)

    CharInfo.setCharID(charId)
    cc.DebugHelper:AddErrorReportInfo("playerName", CharInfo.getNickName())
    cc.DebugHelper:AddErrorReportInfo("playerID", charId)
    if boolFirst ~= true and NetInterface.isConnect and --[[Reconnector.reconnecting()]] Reconnector.flag == true then
        --重连后进入游戏,不需要请求其他数据
        Reconnector.finish()
        return
    end

    NetInterface.sendWithBlock("GC_QueryPokemons_Ack", function()
       local PetSend = require("src.Net.Send.PetSend")
       PetSend.sendCG_QueryPokemons_Req()
       end, function()
            WorldMapAwardsMgr.IS_LOGIN = true
       
            --主要的宠物数据请求完毕，进入游戏
            if not boolFirst then
                SceneMgr.replaceScene(SceneMgr.getRunningScene, "MainScene", "", function()
                   LoginMsgMgr.addUI()
                end)
            else
                LoginMsgMgr.addUI()
            end

            --依次请求其他数据，已经移到LoginMsgMgr中
            LoginMsgMgr.request()
        end, function(code)
        TipsMgr.showError(nil, code)
    end)
end


---android SDKUI被取消后的调用,
function LoginViewMgr.onAndroidSdkUICancel()
    CSResourceMgr.getNodeByName(resNameDiban, "btn_l1"):setVisible(true)
    CSResourceMgr.setButtonEnabled(resNameDiban, "touch", true)
end

return LoginViewMgr