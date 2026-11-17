local platformData = nil
local login_deviceid = {}
local device_token = nil
local device_id = nil

local PortalSend = require("src.Net.Send.PortalSend")

function getLogin_deviceid()
   return device_id or ""
end
local drpf_account_id = ""
function get_drpf_account_id()
	return drpf_account_id
end
function set_drpf_account_id(drpf_account_id_)
	drpf_account_id = drpf_account_id_
end

function getPlatform_UsernameToken()
	platformData = AllSDKManager.FangCun.userid_token
    local params = {}
    params.username = AllSDKManager.FangCun.userid_token["userId"]
    params.token = AllSDKManager.FangCun.userid_token["token"]
	return params
end

--登陆步骤一：向服务器发送平台信息
function platformLogin_req()
    --AllSDKManager.FangCun:roleInfo("", "", 0, 0, game.localConfigTable.lastWorldIdx, "","","")
    platformData = AllSDKManager.FangCun.userid_token
    local params = {}
    params.username = AllSDKManager.FangCun.userid_token["userId"]
    params.token = AllSDKManager.FangCun.userid_token["token"]
    NetInterface.sendWithBlock("GC_PLATFORMLOGIN_ACK", function()
        PortalSend.sendCG_PlatformLogin_Req(params)
    end,function()
    end)
end

--登陆步骤一：向服务器发送平台信息服务器返回devices列表，从列表中寻找有无本区的device,
--            如果有则用此device登陆，如果没有则先附送设备绑定协议给服务器，绑定此设备和区号]
function platformLogin_ack(data)
    print("platform login success")
     -- "devices": 
     -- {
     --     "token": "1234567890123456",
     --     "id": "testDevice1"
     -- }
    if (data.devices == nil) or (#data.devices==0) then
        print("data.devices is nil") 
     	deviceBind_req(platformData)
     	return     	
    end
    print("device count:",#data.devices)
    local has_deviceid = false 
    --查询devices中有无本大区的deviceid
    for i,v in ipairs(data.devices) do
        if data.devices[i].world == tostring(LoginViewMgr.getCurrentWorld()) then
            print("find device in zone:",data.devices[i].world," try use device login") 
            login_deviceid = data.devices[i]
            device_token = data.devices[i].token
            local params = {}
            params.id = login_deviceid.id
            params.world = data.devices[i].world
            params.token = device_token
            LoginViewMgr.sendDeviceCodeLogin(params,false)
            return
        end
    end
    
    deviceBind_req(platformData)
    --[[
    if next(login_deviceid) then 
        has_deviceid = true
    end

    if has_deviceid then
        deviceLoginSDK_req(platformData)
    else 
        deviceBind_req(platformData)
    end
    ]]
end 

--登陆步骤二：向服务器发送设备绑定请求（可选）
function deviceBind_req(platform)
    --[[
    local data = {}
    data.deviceID = {}
    data.deviceID.id = device.getOpenUDID()..platform.userId
    data.deviceID.world = tostring(LoginViewMgr.selectZoneId)
	login_deviceid = data.deviceID

    data.deviceToken = crypto.md5("pswd#key$%@*`#"..device.getOpenUDID())
    data.platform = {}
    data.platform.username = platform.userId
    data.platform.token = platform.token
    ]]
    NetInterface.sendWithBlock("GC_DEVICEBIND_ACK", function()
        local params = {}
        params.id = device.getOpenUDID()..platform.userId
        params.world = LoginViewMgr.getCurrentWorld()
        params.token = crypto.md5("pswd#key$%@*`#"..device.getOpenUDID())
        PortalSend.sendCG_DeviceBind_Req(params)
    end,function()
        print("device bind success")
        local params = {}
        params.id = device.getOpenUDID()..platform.userId
        params.world = LoginViewMgr.getCurrentWorld()
        params.token = crypto.md5("pswd#key$%@*`#"..device.getOpenUDID())
        LoginViewMgr.sendDeviceCodeLogin(params,false)
    end, function(code)
        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "device bind failed:"..code, function()
            LoginViewMgr.gameReInit()
        end)
    end)
end

function deviceBind_ack(data)
	-- dump(data)
    deviceLoginSDK_req(platformData)
end

local loginState = {
	LOGOUT = 0,
	LOGIN = 1,
	WAIT = 2,
}
local curLoginState = loginState.LOGOUT

--设置网易信息
function getNetease()
    local DeviceInfoTable = helper.GetDeviceInfoTable()
	local neteaseLogin = {}

	local neteaseBase = {}
	neteaseBase.device_model = DeviceInfoTable.MachineModel
	if device.platform == "android" then
       neteaseBase.os_name = "Android"
    elseif device.platform == "ios" then
       neteaseBase.os_name = "IOS"
    end
	neteaseBase.os_ver = DeviceInfoTable.OSVersion
	neteaseBase.mac_addr = DeviceInfoTable.LocalMacAddress
	neteaseBase.udid = DeviceID:getUdid()
	neteaseBase.nation = 86
	neteaseBase.app_channel = AllSDKManager.FangCun:getPlatformChannel()
	neteaseBase.app_ver = DeviceInfoTable.app_ver

	neteaseLogin.base = neteaseBase
    neteaseLogin.device_height = DeviceInfoTable.ScreenHeight
    neteaseLogin.device_width = DeviceInfoTable.ScreenWidth
    neteaseLogin.isp = DeviceInfoTable.isp
    neteaseLogin.network = DeviceInfoTable.network
    neteaseLogin.root = DeviceInfoTable.isRoot
    return neteaseLogin
end

--登陆步骤三：向服务器发送sdk登录请求
function deviceLoginSDK_req(platform)
	print("进入sdk登陆请求")
	if curLoginState~= loginState.LOGOUT then
		return
	end
	local data = {}
	data.deviceID = {}
	data.deviceID = login_deviceid
	device_id = data.deviceID.id
	if device_token then
	   data.deviceToken = device_token
	else 
	   data.deviceToken = DeviceID:getDeviceToken()
	end
	--data.platform = {id=0, Uin="12", SessionId=getSession().id} --平台登录请求
    data.platform = {}
    data.platform.username = platform.userId
    data.platform.token = platform.token
    data.netease = getNetease()
    dump(data)
    DebugHelper:SetErrorReportURL(gameConfig.serverUrl.."debug.clientlog")	--将当前服务器地址设置为错误报告地址
    DebugHelper:AddErrorReportInfo("DeviceID", tostring(data.deviceID.id .. "+" ..data.deviceID.world))  --记录deviceID
	AllSDKManager.TalkingData:setAccount(data.deviceID.id)

	sendRequest(deviceLoginSDK_ack, "login.device.login", data , nil , true,
		{ReConnectFunction = function ()
			deviceLoginSDK_req(platform)
		end,
		whetherForceDealReConnectFunction = true})
	curLoginState = loginState.WAIT
	print("deviceLogin_req:", "ID= ", data.deviceID, " token= ", data.deviceToken)
	print("结束sdk登陆请求")
end

function deviceLoginSDK_ack( data )
	print("sdk登陆请求回调")
	curLoginState = loginState.LOGIN
	setSession(data.session,data.serverTime["$date"])
	setServerState(true)	--连接服务器成功
	-- require("framework.scheduler").scheduleGlobal(dateUpdate,1)
	cc.luaTimer:runSchedule(dateUpdate,1)
	require("framework.scheduler").scheduleUpdateGlobal(PlayerDataUpdate)		--注册每帧更新函数PlayerDataUpdate()
	
	require("scenes.WifiBattleScene.message.WFB_Mes")
	if data.character == nil then
		local _LoadingScene = require("scenes.LoadingScene").create(
		function()
			display.replaceScene(require("scenes.CreateCharacterScene").new(), "fade", 0.6, display.COLOR_WHITE)
		end)
		
		display.replaceScene( _LoadingScene, "fade", 0.6, display.COLOR_WHITE)
	else
		setCharacterData(data.character)
		setAccidents(data.character.accidents)
		setIsOldPlayer(true)	--是已注册用户
		
		require("message.preLoadMessage")
		preLoad()
	end
	require("message.ntf") -- 长连接函数注册
	print("sdk登陆请求回调结束")
end

function getdefaultNetease()
    local DeviceInfoTable = helper.GetDeviceInfoTable()
	local neteaseLogin = {}

	local neteaseBase = {}
	neteaseBase.device_model = ""--DeviceInfoTable.MachineModel
	if device.platform == "android" then
       neteaseBase.os_name = "Android"
    elseif device.platform == "ios" then
       neteaseBase.os_name = "IOS"
    end
    neteaseBase.os_name = ""
	neteaseBase.os_ver = ""--DeviceInfoTable.OSVersion
	neteaseBase.mac_addr = "123abc"--DeviceInfoTable.LocalMacAddress
	neteaseBase.udid = ""--DeviceID:getUdid()
	neteaseBase.nation = 86
	neteaseBase.app_channel = "" --AllSDKManager.FangCun:getPlatformChannel()
	neteaseBase.app_ver = "" --DeviceInfoTable.app_ver

	neteaseLogin.base = neteaseBase
    neteaseLogin.device_height = 1--DeviceInfoTable.ScreenHeight
    neteaseLogin.device_width = 1--DeviceInfoTable.ScreenWidth
    neteaseLogin.isp = "123"--DeviceInfoTable.isp
    neteaseLogin.network = "wifi"--DeviceInfoTable.network
    neteaseLogin.root = "true" --DeviceInfoTable.isRoot
    return neteaseLogin
end

function deviceLogin_req(loginWay)
	if curLoginState ~= loginState.LOGOUT then
		return
	end
	local data = {}
	data.deviceID = {}
	if loginWay == "DeviceIdLogin" then 
	   data.deviceID.id = DeviceID:getDeviceID()
	else 
		if CCUserDefault:sharedUserDefault():getStringForKey("newName") ~= nil then
		     data.deviceID.id = CCUserDefault:sharedUserDefault():getStringForKey("newName")
		     if data.deviceID.id == "" then 
		     	data.deviceID.id = DeviceID:getDeviceID()  
		     end
		else 
	      data.deviceID.id = DeviceID:getDeviceID()  
		end
	end

    --如果不想用新功能则可以自己取名字，把下面这行打开
	--data.deviceID.id = "925957317D78-3376-412B-AAF4-68B6BF872E0C15@115890@netease.win.163.com"
	data.deviceID.id = "yhb106" --"ffffffff-e41d-e999-6d7f-3813000000000@164828"--"yhb106"
	--"yhb106"--"111"--"敏行1003"--"001"------"敏行18"--"yhb106"------"111"--
	--"00000000-0c83-d144-6c62-6adb0000000015@d8f2009b7c1c12a77351aeb97b9f31f9@zhangyue_sdk.win.163.com"
	--"yhb106"--"敏行1003"----"00000000-7c24-ac97-bba8-a6020000000015@96998@netease.win.163.com"
	--data.deviceID.id =  "敏行1003"
	--"00000000-5f69-0fe3-d406-9ded0000000015@96993@netease.win.163.com"
	--"yhb105"--"ffffffff-f76b-ff35-a60b-c38d0000000015@485276440@37yyb.win.163.com"--"大大呱"--"敏行1003"----"yhb105"--"大大呱2"
	device_id = data.deviceID.id
	device_id = data.deviceID.id
	data.deviceID.world = tostring(game.localConfigTable.lastWorldIdx)
	data.deviceToken = DeviceID:getDeviceToken()
	data.netease = getdefaultNetease()
	DebugHelper:SetErrorReportURL(gameConfig.serverUrl.."debug.clientlog")	--将当前服务器地址设置为错误报告地址
	DebugHelper:AddErrorReportInfo("DeviceID", tostring(data.deviceID.id))		--记录deviceID
	AllSDKManager.TalkingData:setAccount(data.deviceID.id)
	
	sendRequest(deviceLoginSDK_ack, "login.device.login", data , nil , true)
	curLoginState = loginState.WAIT
	print("deviceLogin_req:", "ID= ", data.deviceID.id, " token= ", data.deviceToken)
end

-- function deviceLogin_ack( data )
-- 	curLoginState = loginState.LOGIN
-- 	setSession(data.session,data.serverTime["$date"])
-- 	setServerState(true)	--连接服务器成功
-- 	-- require("framework.scheduler").scheduleGlobal(dateUpdate,1)
-- 	cc.luaTimer:runSchedule(dateUpdate,1)
-- 	-- require("framework.scheduler").scheduleUpdateGlobal(PlayerDataUpdate)		--注册每帧更新函数PlayerDataUpdate()
-- 	cc.luaTimer:runSchedule(PlayerDataUpdate)
-- 	if data.character == nil then
-- 		local _LoadingScene = require("scenes.LoadingScene").create(
-- 		function()
-- 			display.replaceScene(require("scenes.CreateCharacterScene").new(), "fade", 0.6, display.COLOR_WHITE)
-- 		end)
		
-- 		display.replaceScene( _LoadingScene, "fade", 0.6, display.COLOR_WHITE)
-- 	else
-- 		setCharacterData(data.character)
-- 		setAccidents(data.character.accidents)
-- 		setIsOldPlayer(true)	--是已注册用户
		
-- 		require("message.preLoadMessage")
-- 		preLoad()
-- 	end
-- 	require("message.ntf") -- 长连接函数注册
-- end