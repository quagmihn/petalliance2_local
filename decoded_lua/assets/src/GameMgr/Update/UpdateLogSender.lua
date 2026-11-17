local UpdateLogSender = {}
local UpdateLogSenderInner = {}

UpdateLogSenderInner.m_ver = "0.2"
UpdateLogSenderInner.m_printFlag = true
UpdateLogSender.FirstMainScene = 0
UpdateLogSender.LoginView = 0
UpdateLogSender.UpdateStartTime = 0
UpdateLogSender.UpdateEndTime = 0
UpdateLogSender.UpdateFailTime = 0
UpdateLogSender.LoadTimeLogStart = 0
UpdateLogSender.GameGuideStart = 0
UpdateLogSender.GameGuideEnd = 0
local platformtag = "aofei"
local groupid = 3
local channel_id = "1" --这又是什么
local appchannel = "empty"
function UpdateLogSenderInner.onRequestFinished(event)

    if (true == UpdateLogSenderInner.m_printFlag) then
--        print("UpdateLogSenderInner.onRequestFinished, event.name:", event.name)
    end

    local request = event.request
    if ("completed" ~= event.name) then
        if (true == UpdateLogSenderInner.m_printFlag) then
            print(request:getErrorCode(), request:getErrorMessage())
        end
        return
    end

    local code = request:getResponseStatusCode()
    if (true == UpdateLogSenderInner.m_printFlag) then
--        print("UpdateLogSenderInner.onRequestFinished, response status code:", code)
    end
    if (200 ~= code) then
        return
    end

    if (true == UpdateLogSenderInner.m_printFlag) then
--        print("UpdateLogSenderInner.onRequestFinished, response string:", request:getResponseString())
    end

end

function UpdateLogSender.setVer(ver)

    UpdateLogSenderInner.m_ver = ver

end

function UpdateLogSender.getVer()

    return UpdateLogSenderInner.m_ver

end

function UpdateLogSender.Init()
    UpdateLogSender.FirstMainScene = 0
    UpdateLogSender.LoginView = 0
    UpdateLogSender.UpdateStartTime = 0
    UpdateLogSender.UpdateEndTime = 0
    UpdateLogSender.UpdateFailTime = 0
    UpdateLogSender.LoadTimeLogStart = 0
    UpdateLogSender.GameGuideStart = 0
    UpdateLogSender.GameGuideEnd = 0

    if device.platform == "android" then
        groupid = 2
        platformtag = UpdateLogFunction.getPlatFormTag()
        channel_id = UpdateLogFunction.getChannelId()
    end
    if device.platform == "ios" then 
        groupid = 1
        platformtag = UpdateLogFunction.getPlatFormTag()
        channel_id = UpdateLogFunction.getChannelId()
    end
end

local function getAccountId()
    local accountidstr = " "
    if AllSDKManager~=nil and AllSDKManager.FangCun~=nil and AllSDKManager.FangCun.userid_token ~=nil then 
        accountidstr = AllSDKManager.FangCun.userid_token["userId"]
    end

    return accountidstr
end

function UpdateLogSender.getAppid()
    return channel_id
end

function UpdateLogSender.log(operation, datas)
  
	local jsonSrc = {}
    local sortKeys = {}
	local md5Src = ""
	for i = 1, #datas do
		jsonSrc[datas[i][1]] = datas[i][2]
        --print("datas[i][2] is ............"..datas[i][1],datas[i][2])
		--md5Src = md5Src .. datas[i][2]
        sortKeys[i] = datas[i][1]
        if datas[i][1] == nil then print("operation has nil data,name:"..operation) return end
	end
    table.sort(sortKeys, function(a, b)
        return a < b
    end)
    for i = 1, #sortKeys do
        
        md5Src = md5Src .. jsonSrc[sortKeys[i]]
    end

	md5Src = md5Src .. "fangcun15166"
    if (true == UpdateLogSenderInner.m_printFlag) then
        print("md5Src", md5Src)
    end
	local md5Res = crypto.md5(md5Src)
	jsonSrc.md5data = md5Res

	local jsonRes = json.encode(jsonSrc)
    if (true == UpdateLogSenderInner.m_printFlag) then
        print("jsonRes", jsonRes)
    end

    local urlstr = UpdateLogFunction.getDataLogUrl()
    local req = network.createHTTPRequest(function(event) UpdateLogSenderInner.onRequestFinished(event) end, urlstr.."/" .. operation, "POST")
    req:setPOSTData(jsonRes)
    req:start()

end



---激活日志
function UpdateLogSender.logActivation()
    if device.platform=="android" or device.platform == "ios" then
        print("start UpdateLogSender Activation")
		UpdateLogSender.log("Activation", 
			{
            
				{ "log_ymd",        tonumber(UpdateLogFunction.getYMD()) },
				{ "log_ym",         tonumber(UpdateLogFunction.getYM()) },
				{ "year",           tonumber(UpdateLogFunction.getYear()) },
				{ "month",          tonumber(UpdateLogFunction.getMonth())},
				{ "day",            tonumber(UpdateLogFunction.getDay()) },
				{ "hour",           tonumber(UpdateLogFunction.getHour()) },
                { "minute",         tonumber(UpdateLogFunction.getMiniute())},
				{ "week",           tonumber(UpdateLogFunction.getWeekOfTheYear())},
				{ "ip",             UpdateLogFunction.getIpAddress() },
				{ "device_model",   UpdateLogFunction.getDeviceModel() },
				{ "os_name",        device.platform },
				{ "os_ver",         UpdateLogFunction.getOSVer() },
				{ "mac_addr",       UpdateLogFunction.getMacAddress() },
				{ "udid",           UpdateLogFunction.getUDID() },
				{ "app_channel",    appchannel },
				{ "app_ver",        UpdateLogSender.getVer() },
				{ "network",        UpdateLogFunction.getNetworkState() },
				{ "platform_tag",   platformtag},
                { "group_id",       groupid },
                { "channel_id",     channel_id},
				{ "active_time",    os.time() },
			})
        print("end UpdateLogSender Activation")
	end
	
end


--登陆界面到达日志
function UpdateLogSender.LoginUI()
    if device.platform=="android" or device.platform == "ios"  then
        print("start UpdateLogSender LoginUI")
        if UpdateLogSender.LoginView == 0 then
            UpdateLogSender.log("LoginUI", 
                {
  				    { "log_ymd",           tonumber(UpdateLogFunction.getYMD()) },
				    { "log_ym",            tonumber(UpdateLogFunction.getYM()) },
				    { "year",              tonumber(UpdateLogFunction.getYear()) },
				    { "month",             tonumber(UpdateLogFunction.getMonth())},
				    { "day",               tonumber(UpdateLogFunction.getDay()) },
				    { "hour",              tonumber(UpdateLogFunction.getHour()) },
                    { "minute",            tonumber(UpdateLogFunction.getMiniute())},
				    { "week",              tonumber(UpdateLogFunction.getWeekOfTheYear())},
                    { "ip",                 UpdateLogFunction.getIpAddress() },
                    { "device_model",       UpdateLogFunction.getDeviceModel() },
                    { "os_name",            device.platform },
                    { "os_ver",             UpdateLogFunction.getOSVer() },
                    { "mac_addr",           UpdateLogFunction.getMacAddress() },
                    { "udid",               UpdateLogFunction.getUDID() },
                    { "app_channel",        appchannel },
                    { "app_ver",            UpdateLogSender.getVer() },
                    { "network",            UpdateLogFunction.getNetworkState() },
                    { "platform_tag",       platformtag },
                    { "group_id",           groupid },
                    { "channel_id",         channel_id},
                    { "reach_login_time",   os.time() },
                })
            UpdateLogSender.LoginView = 1
            
            print("end UpdateLogSender LoginUI")  
        end          
    end    
end

--帐号认证日志
function UpdateLogSender.Identification()
    if device.platform=="android" or device.platform == "ios"  then
        print("start UpdateLogSender Identification")
        UpdateLogSender.log("Identification", 
            {
  				{ "log_ymd",           tonumber(UpdateLogFunction.getYMD()) },
				{ "log_ym",            tonumber(UpdateLogFunction.getYM()) },
				{ "year",              tonumber(UpdateLogFunction.getYear()) },
				{ "month",             tonumber(UpdateLogFunction.getMonth())},
				{ "day",               tonumber(UpdateLogFunction.getDay()) },
				{ "hour",              tonumber(UpdateLogFunction.getHour()) },
                { "minute",            tonumber(UpdateLogFunction.getMiniute())},
				{ "week",              tonumber(UpdateLogFunction.getWeekOfTheYear())},
                { "ip",                 UpdateLogFunction.getIpAddress() },
                { "device_model",       UpdateLogFunction.getDeviceModel() },
                { "os_name",            device.platform },
                { "os_ver",             UpdateLogFunction.getOSVer() },
                { "mac_addr",           UpdateLogFunction.getMacAddress() },
                { "udid",               UpdateLogFunction.getUDID() },
                { "app_channel",        appchannel },
                { "app_ver",            UpdateLogSender.getVer() },
                { "network",            UpdateLogFunction.getNetworkState() },
                { "platform_tag",       platformtag },
                { "group_id",           groupid },
                { "channel_id",         channel_id},
                { "reach_login_time",   os.time() },
                { "account_id",         getAccountId()},
            })
        print("end UpdateLogSender Identification")  
         
    end    
end

--到达游戏界面日志
function UpdateLogSender.logLoad()
    if device.platform=="android" or device.platform == "ios"  then
        if UpdateLogSender.FirstMainScene == 0 then
            --[[
            local accountidstr = " "
            if AllSDKManager.FangCun.userid_token ~=nil then 
                accountidstr = AllSDKManager.FangCun.userid_token["userId"]
            end
            ]]
            print("start UpdateLogSender Load")
            UpdateLogSender.log("Load", 
                {
   				    { "log_ymd",           tonumber(UpdateLogFunction.getYMD()) },
				    { "log_ym",            tonumber(UpdateLogFunction.getYM()) },
				    { "year",              tonumber(UpdateLogFunction.getYear()) },
				    { "month",             tonumber(UpdateLogFunction.getMonth())},
				    { "day",               tonumber(UpdateLogFunction.getDay()) },
				    { "hour",              tonumber(UpdateLogFunction.getHour()) },
                    { "minute",            tonumber(UpdateLogFunction.getMiniute())},
				    { "week",              tonumber(UpdateLogFunction.getWeekOfTheYear())},
                    { "ip",                 UpdateLogFunction.getIpAddress() },
                    { "device_model",       UpdateLogFunction.getDeviceModel() },
                    { "os_name",            device.platform },
                    { "os_ver",             UpdateLogFunction.getOSVer() },
                    { "mac_addr",           UpdateLogFunction.getMacAddress() },
                    { "udid",               UpdateLogFunction.getUDID() },
                    { "app_channel",        appchannel },
                    { "app_ver",            UpdateLogSender.getVer() },
                    { "network",            UpdateLogFunction.getNetworkState() },
                    { "activate_game_time", 0 },
                    { "platform_tag",       platformtag  },
                    { "group_id",           groupid },
                    { "channel_id",         channel_id },
                    { "reach_game_time",    os.time() },
                    { "account_id",         getAccountId()},
                    { "load_time_long",     os.time()-UpdateLogSender.LoadTimeLogStart},
                }) 
                UpdateLogSender.FirstMainScene = 1
            print("end UpdateLogSender Load")  
        end 
    end
end

--新手引导日志
function UpdateLogSender.Tutorial(params)
    if device.platform=="android" or device.platform == "ios"  then
        print("start UpdateLogSender Tutorial")
        UpdateLogSender.log("Tutorial", 
            {
  				{ "log_ymd",           tonumber(UpdateLogFunction.getYMD()) },
				{ "log_ym",            tonumber(UpdateLogFunction.getYM()) },
				{ "year",              tonumber(UpdateLogFunction.getYear()) },
				{ "month",             tonumber(UpdateLogFunction.getMonth())},
				{ "day",               tonumber(UpdateLogFunction.getDay()) },
				{ "hour",              tonumber(UpdateLogFunction.getHour()) },
                { "minute",            tonumber(UpdateLogFunction.getMiniute())},
				{ "week",              tonumber(UpdateLogFunction.getWeekOfTheYear())},
                { "ip",                 UpdateLogFunction.getIpAddress() },
                { "device_model",       UpdateLogFunction.getDeviceModel() },
                { "os_name",            device.platform },
                { "os_ver",             UpdateLogFunction.getOSVer() },
                { "mac_addr",           UpdateLogFunction.getMacAddress() },
                { "udid",               UpdateLogFunction.getUDID() },
                { "app_channel",        appchannel },
                { "app_ver",            UpdateLogSender.getVer() },
                { "network",            UpdateLogFunction.getNetworkState() },
                { "platform_tag",       platformtag },
                { "group_id",           groupid },
                { "channel_id",         channel_id},
                { "server",             LoginViewMgr.selectZoneId},
                { "account_id",         getAccountId()},
                { "role_id",            tostring(CharInfo.getCharID())},--string
                { "role_name",          CharInfo.getNickName()},--string
                { "tutorial_id",        params.tutorialId},--string 例：“001-1022”。
                { "tutorial_name",      params.tutorialName},--string 例：“第一次主城升级”
                { "begin_time",         params.beginTime},--开始新手引导的时间 os time
                { "begin_role_level",   params.beginLevel},--开始教程时玩家角色等级
                { "end_role_level",     params.endLevel},--结束教程时玩家角色等级
                { "vip_level",          CharInfo.getVIPLevel()},--int角色VIP等级
                { "use_time",           params.useTime},--int玩法耗时（单位秒，瞬时玩法的耗时记为0）
                { "step_type",          params.stepType},--int引导情况（未完成：-1，完成：1，开始 ：0）
            })
        print("end UpdateLogSender Tutorial")  
         
    end    
end

function UpdateLogSender.logUpdateStart()
    if device.platform=="android" or device.platform == "ios" then
        print("start UpdateLogSender Update start")
        UpdateLogSender.UpdateStartTime = os.time()
        UpdateLogSender.log("Update", 
            {
   				{ "log_ymd",           tonumber (UpdateLogFunction.getYMD()) },
				{ "log_ym",            tonumber (UpdateLogFunction.getYM()) },
				{ "year",              tonumber (UpdateLogFunction.getYear()) },
				{ "month",             tonumber (UpdateLogFunction.getMonth())},
				{ "day",               tonumber (UpdateLogFunction.getDay()) },
				{ "hour",              tonumber (UpdateLogFunction.getHour()) },
                { "minute",            tonumber (UpdateLogFunction.getMiniute())},
				{ "week",              tonumber (UpdateLogFunction.getWeekOfTheYear())},
                { "ip",                 UpdateLogFunction.getIpAddress() },
                { "device_model",       UpdateLogFunction.getDeviceModel() },
                { "os_name",            device.platform },
                { "os_ver",             UpdateLogFunction.getOSVer() },
                { "mac_addr",           UpdateLogFunction.getMacAddress() },
                { "udid",               UpdateLogFunction.getUDID() },
                { "app_channel",        appchannel },
                { "app_ver",            UpdateLogSender.getVer() },
                { "network",            UpdateLogFunction.getNetworkState() },
                { "platform_tag",       platformtag },
                { "group_id",           groupid },
                { "channel_id",         channel_id},
                { "reach_update_time",  0 },
                { "update_status",      0 },
                { "update_time",        UpdateLogSender.UpdateStartTime },
                { "use_time",           0 },
            })
        print("end UpdateLogSender Update start")
    end
    
end

function UpdateLogSender.logUpdateEnd()
    if device.platform=="android" or device.platform == "ios" then
        print("start UpdateLogSender Update end")
        UpdateLogSender.UpdateEndTime = os.time()
        UpdateLogSender.log("Update", 
            {
   				{ "log_ymd",           tonumber (UpdateLogFunction.getYMD()) },
				{ "log_ym",            tonumber (UpdateLogFunction.getYM()) },
				{ "year",              tonumber (UpdateLogFunction.getYear()) },
				{ "month",             tonumber (UpdateLogFunction.getMonth())},
				{ "day",               tonumber (UpdateLogFunction.getDay()) },
				{ "hour",              tonumber (UpdateLogFunction.getHour()) },
                { "minute",            tonumber (UpdateLogFunction.getMiniute())},
				{ "week",              tonumber (UpdateLogFunction.getWeekOfTheYear())},
                { "ip",                 UpdateLogFunction.getIpAddress() },
                { "device_model",       UpdateLogFunction.getDeviceModel() },
                { "os_name",            device.platform },
                { "os_ver",             UpdateLogFunction.getOSVer() },
                { "mac_addr",           UpdateLogFunction.getMacAddress() },
                { "udid",               UpdateLogFunction.getUDID() },
                { "app_channel",        appchannel },
                { "app_ver",            UpdateLogSender.getVer() },
                { "network",            UpdateLogFunction.getNetworkState() },
                { "platform_tag",       platformtag },
                { "group_id",           groupid },
                { "channel_id",         channel_id},
                { "reach_update_time",  0 },
                { "update_status",      1 },
                { "update_time",        UpdateLogSender.UpdateEndTime},
                { "use_time",           UpdateLogSender.UpdateEndTime - UpdateLogSender.UpdateStartTime},
            })
        print("end UpdateLogSender Update end")
    end
    
end

function UpdateLogSender.logUpdateFail()
    if device.platform=="android" or device.platform == "ios" then
        print("start UpdateLogSender Update Fail")
        UpdateLogSender.UpdateFailTime = os.time()
        UpdateLogSender.log("Update", 
            {
   				{ "log_ymd",           tonumber (UpdateLogFunction.getYMD()) },
				{ "log_ym",            tonumber (UpdateLogFunction.getYM()) },
				{ "year",              tonumber (UpdateLogFunction.getYear()) },
				{ "month",             tonumber (UpdateLogFunction.getMonth())},
				{ "day",               tonumber (UpdateLogFunction.getDay()) },
				{ "hour",              tonumber (UpdateLogFunction.getHour()) },
                { "minute",            tonumber (UpdateLogFunction.getMiniute())},
				{ "week",              tonumber (UpdateLogFunction.getWeekOfTheYear())},
                { "ip",                 UpdateLogFunction.getIpAddress() },
                { "device_model",       UpdateLogFunction.getDeviceModel() },
                { "os_name",            device.platform },
                { "os_ver",             UpdateLogFunction.getOSVer() },
                { "mac_addr",           UpdateLogFunction.getMacAddress() },
                { "udid",               UpdateLogFunction.getUDID() },
                { "app_channel",        appchannel },
                { "app_ver",            UpdateLogSender.getVer() },
                { "network",            UpdateLogFunction.getNetworkState() },
                { "platform_tag",       platformtag },
                { "group_id",           groupid },
                { "channel_id",         channel_id},
                { "reach_update_time",  0 },
                { "update_status",      -1 },
                { "update_time",        UpdateLogSender.UpdateFailTime},
                { "use_time",           UpdateLogSender.UpdateFailTime - UpdateLogSender.UpdateStartTime},
            })
        print("end UpdateLogSender Update Fail")
    end
    
end

--安装日志
function UpdateLogSender.Install()
    if device.platform=="android" or device.platform == "ios"  then
        print("start UpdateLogSender Install")   
        UpdateLogSender.log("Install", 
            {
  				{ "log_ymd",           tonumber(UpdateLogFunction.getYMD()) },
				{ "log_ym",            tonumber(UpdateLogFunction.getYM()) },
				{ "year",              tonumber(UpdateLogFunction.getYear()) },
				{ "month",             tonumber(UpdateLogFunction.getMonth())},
				{ "day",               tonumber(UpdateLogFunction.getDay()) },
				{ "hour",              tonumber(UpdateLogFunction.getHour()) },
                { "minute",            tonumber(UpdateLogFunction.getMiniute())},
				{ "week",              tonumber(UpdateLogFunction.getWeekOfTheYear())},
                { "ip",                 UpdateLogFunction.getIpAddress() },
                { "device_model",       UpdateLogFunction.getDeviceModel() },
                { "os_name",            device.platform },
                { "os_ver",             UpdateLogFunction.getOSVer() },
                { "mac_addr",           UpdateLogFunction.getMacAddress() },
                { "udid",               UpdateLogFunction.getUDID() },
                { "app_channel",        appchannel },
                { "app_ver",            UpdateLogSender.getVer() },
                { "network",            UpdateLogFunction.getNetworkState() },
                { "platform_tag",       platformtag },
                { "group_id",           groupid },
                { "channel_id",         channel_id},
                { "install_time",       os.time() },
            })
           
            
        print("end UpdateLogSender Install")  
               
    end    
end

function UpdateLogSender.logPayGenerate(params)
   if device.platform=="android" or device.platform == "ios"  then
        print("start UpdateLogSender PayGenerate")   
        UpdateLogSender.log("Generate", 
            {
  				{ "log_ymd",           tonumber(UpdateLogFunction.getYMD()) },
				{ "log_ym",            tonumber(UpdateLogFunction.getYM()) },
				{ "year",              tonumber(UpdateLogFunction.getYear()) },
				{ "month",             tonumber(UpdateLogFunction.getMonth())},
				{ "day",               tonumber(UpdateLogFunction.getDay()) },
				{ "hour",              tonumber(UpdateLogFunction.getHour()) },
                { "minute",            tonumber(UpdateLogFunction.getMiniute())},
				{ "week",              tonumber(UpdateLogFunction.getWeekOfTheYear())},
                { "ip",                 UpdateLogFunction.getIpAddress() },
                { "device_model",       UpdateLogFunction.getDeviceModel() },
                { "os_name",            device.platform },
                { "os_ver",             UpdateLogFunction.getOSVer() },
                { "mac_addr",           UpdateLogFunction.getMacAddress() },
                { "udid",               UpdateLogFunction.getUDID() },
                { "app_channel",        appchannel },
                { "app_ver",            UpdateLogSender.getVer() },
                { "network",            UpdateLogFunction.getNetworkState() },
                { "platform_tag",       platformtag },
                { "group_id",           groupid },
                { "channel_id",         channel_id},
                { "server",             LoginViewMgr.selectZoneId},
                { "account_id",         getAccountId()},
                { "role_id",            tostring(CharInfo.getCharID())},--string
                { "role_name",          CharInfo.getNickName()},--string
                { "role_level",         CharInfo.getLevel()},--int
                { "pay_channel",        tostring(channel_id)},--string
                { "zuanshi",            params.zuanshi},--int
                { "cash",               params.cash},--float
                { "create_t",           os.time() },
                { "sn_cp",              params.sn_cp },
                { "create_time",        params.create_time },
                { "total_pay",          params.total_pay },
                { "vip_level",          CharInfo.getVIPLevel() },
            })
           
            
        print("end UpdateLogSender PayGenerate")  
               
    end        

end

function UpdateLogSender.logPayCallBack(params)
   if device.platform=="android" or device.platform == "ios"  then
        print("start UpdateLogSender PayCallBack")   
        UpdateLogSender.log("Paycallback", 
            {
  				{ "log_ymd",           tonumber(UpdateLogFunction.getYMD()) },
				{ "log_ym",            tonumber(UpdateLogFunction.getYM()) },
				{ "year",              tonumber(UpdateLogFunction.getYear()) },
				{ "month",             tonumber(UpdateLogFunction.getMonth())},
				{ "day",               tonumber(UpdateLogFunction.getDay()) },
				{ "hour",              tonumber(UpdateLogFunction.getHour()) },
                { "minute",            tonumber(UpdateLogFunction.getMiniute())},
				{ "week",              tonumber(UpdateLogFunction.getWeekOfTheYear())},
                { "ip",                 UpdateLogFunction.getIpAddress() },
                { "device_model",       UpdateLogFunction.getDeviceModel() },
                { "os_name",            device.platform },
                { "os_ver",             UpdateLogFunction.getOSVer() },
                { "mac_addr",           UpdateLogFunction.getMacAddress() },
                { "udid",               UpdateLogFunction.getUDID() },
                { "app_channel",        appchannel },
                { "app_ver",            UpdateLogSender.getVer() },
                { "network",            UpdateLogFunction.getNetworkState() },
                { "platform_tag",       platformtag },
                { "group_id",           groupid },
                { "channel_id",         channel_id},
                { "server",             LoginViewMgr.selectZoneId},
                { "account_id",         getAccountId()},
                { "role_id",            tostring(CharInfo.getCharID())},--string
                { "role_name",          CharInfo.getNickName()},--string
                { "role_level",         CharInfo.getLevel()},--int
                { "pay_channel",        tostring(channel_id)},--string
                { "zuanshi",            params.zuanshi},--int
                { "cash",               params.cash},--float
                { "pay_time",           os.time() },
                { "sn_cp",              params.sn_cp },
                { "sn",                 params.sn },
                { "create_time",        params.create_time },
                { "total_pay",          params.total_pay },
                { "vip_level",          CharInfo.getVIPLevel() },
            })
           
            
        print("end UpdateLogSender PayCallBack")  
               
    end   
end

function UpdateLogSender.createUserInfoTable()
    
    if device.platform == "android" then
        local userinfo = {
            ip = UpdateLogFunction.getIpAddress(),
            device_model = UpdateLogFunction.getDeviceModel(),
            os_name = device.platform,
            os_ver = UpdateLogFunction.getOSVer(),
            mac_addr = UpdateLogFunction.getMacAddress(),
            udid = UpdateLogFunction.getUDID(),
            app_channel = channel_id,
            app_ver = UpdateLogSender.getVer(),
            network = UpdateLogFunction.getNetworkState(),
            device_screen = UpdateLogFunction.getDeviceScreen(),
            platform_tag = platformtag,
            group_id = groupid,
            channel_id = tonumber(channel_id),
        }
        return userinfo
    end
    
    if device.platform == "ios" then
        local userinfo = {
            ip = "192.168.240.1",
            device_model = "pc",
            os_name = "windows",
            os_ver = "win7",
            mac_addr = "11:11:11:11:11:!1",
            udid = "12348574",
            app_channel = channel_id,
            app_ver = UpdateLogSender.getVer(),
            network = "wifi",
            device_screen = "",
            platform_tag = platformtag,
            group_id = groupid,
            channel_id = tonumber(channel_id),

        }
        return userinfo
    end
    
    if device.platform == "windows" then
        local userinfo = {
            ip = "192.168.240.1",
            device_model = "pc",
            os_name = "windows",
            os_ver = "win7",
            mac_addr = "11:11:11:11:11:!1",
            udid = "12348574",
            app_channel = channel_id,
            app_ver = UpdateLogSender.getVer(),
            network = "wifi",
            device_screen = UpdateLogFunction.getDeviceScreen(),
            platform_tag = platformtag,
            group_id = groupid,
            channel_id = tonumber(channel_id),
        }
       
        return userinfo
    end
    
end


return UpdateLogSender