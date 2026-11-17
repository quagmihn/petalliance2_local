local AndroidFunction = {}

local iOSFunction = require("src.GameMgr.Support.iOSFunction")

function AndroidFunction.Init()
end

function AndroidFunction.checkPlatform()
    if device.platform == "android" then
        return true
    end
    return false
end

function AndroidFunction.isTraditionalChinese()
    if device.platform == "android" then
        local args = {}
        local sig = "()I"
        local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/GameLaguage", "isChineseTradictional", args, sig)
        if ok then
            print("SystemFunction.isTraditionalChinese", ret)
            if ret==0 then
                --TipsMgr.show(nil,"fanti")
                return true
            else
                --TipsMgr.show(nil,"jianti")
                return false
            end
        else
            return false
        end
    end
end

function AndroidFunction.registerLocalNotification(time, timezone, title, message, key, type)
    if device.platform == "android" then
        local args = {time, timezone, title, message, key, type}
        local sig = "(IILjava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
        local ok = luaj.callStaticMethod("com/fangcun/push/LocalPush", "registerLocalNotification", args,sig)
        if ok then
            print("call SystemFunction.registerLocalNotification success")
        else
            print("call SystemFunction.registerLocalNotification failed")        
        end
    end
end

function AndroidFunction.cancelLocalNotificationWithKey(key)
    if device.platform == "android" then
        local args = {key}
        local sig = "(Ljava/lang/String;)V"
        local ok = luaj.callStaticMethod("com/fangcun/push/LocalPush", "cancelLocalNotificationWithKey", args,sig)
        if ok then
            print("call SystemFunction.cancelLocalNotificationWithKey success")
        else
            print("call SystemFunction.cancelLocalNotificationWithKey failed")        
        end
    end
end
			
function AndroidFunction.getYMD()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,YMDStr = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getYMD", args, sig)
	    return YMDStr
    end
    if device.platform == "ios" then
        return iOSFunction.getYMD()
    end
end

function AndroidFunction.getYM()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,YMStr = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getYM", args, sig)
	    return YMStr
    end
    if device.platform == "ios" then
        return iOSFunction.getYM()
    end
end

function AndroidFunction.getYear()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,YearStr = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getYear", args, sig)
	    return YearStr
    end
    if device.platform == "ios" then
        return iOSFunction.getYear()
    end
end

function AndroidFunction.getMonth()
    if device.platform == "android" then    
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,MonthStr = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getMonth", args, sig)
	    return MonthStr
    end
    if device.platform == "ios" then
        return iOSFunction.getMonth()
    end
end

function AndroidFunction.getDay()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,DayStr = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getDay", args, sig)
	    return DayStr
    end
    if device.platform == "ios" then
        return iOSFunction.getDay()
    end
end


function AndroidFunction.getHour()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,HourStr = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getHour", args, sig)
	    return HourStr
    end
    if device.platform == "ios" then
        return iOSFunction.getHour()
    end
end


function AndroidFunction.getMiniute()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,MiniuteStr = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getMiniute", args, sig)
	    return MiniuteStr
    end
    if device.platform == "ios" then
        return iOSFunction.getMinute()
    end
end

function AndroidFunction.getWeekOfTheYear()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,WeekOfTheYearStr = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getWeekOfTheYear", args, sig)
	    return WeekOfTheYearStr
    end
    if device.platform == "ios" then
        return iOSFunction.getWeekOfTheYear()
    end
end

function AndroidFunction.getIpAddress()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,IpAddressStr = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getIpAddress", args, sig)
	    return IpAddressStr
    end
    if device.platform == "ios" then
        return iOSFunction.getIpAddress()
    end
end

function AndroidFunction.getDeviceModel()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,DeviceModel = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getDeviceModel", args, sig)
	    return DeviceModel
    end
    if device.platform == "ios" then
        return iOSFunction.getDeviceModel()
    end
end

function AndroidFunction.getOSVer()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,OSVer = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getOSVer", args, sig)
	    return OSVer
    end
    if device.platform == "ios" then
        return iOSFunction.getOSVer()
    end
end


function AndroidFunction.getMacAddress()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,macAddress = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getMacAddress", args, sig)
	    return macAddress
    end
    if device.platform == "ios" then
        return iOSFunction.getMacAddress()
    end
end


function AndroidFunction.getUDID()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,UDID = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getUDID", args, sig)
	    return UDID
    end
    if device.platform == "ios" then
        return iOSFunction.getUDID()
    end
end

function AndroidFunction.getNetworkState()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,networkstate = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getNetworkState", args, sig)
	    return networkstate
    end
    if device.platform == "ios" then
        return iOSFunction.getNetworkState()
    end
end

function AndroidFunction.exitApp()
    if device.platform == "android" then
        local args = {}
        local sig = "()V"
        luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "exitApp", args, sig)
    end
end

function AndroidFunction.eixtGameDialogue()
    if device.platform == "android" then
        local args = {}
        local sig = "()V"
        luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "eixtGameDialogue", args, sig)
    end
end

function AndroidFunction.deviceLoginFailDialogue()
    if device.platform == "android" then
        local args = {}
        local sig = "()V"
        luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "deviceLoginFailDialogue", args, sig)
    end
end

function AndroidFunction.getDataLogUrl()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,url = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getDataLogUrl", args, sig)
	    return url 
    end
    if device.platform == "ios" then
        return iOSFunction.getDataLogUrl()
    end
end

function AndroidFunction.getPlatFormTag()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,platformtag = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getPlatFormTag", args, sig)
        return platformtag
    --local sig = "(II)I"
    end
    if device.platform == "ios" then
        return iOSFunction.getPlatFormTag()
    end
end

function AndroidFunction.getDeviceScreen()
    --[[
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,devicescreen = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getDeviceScreen", args, sig)
        if not ok then 
            return "50X50"
        else
            return devicescreen
        end
    --local sig = "(II)I"
    end
    if device.platform == "ios" then
        return ""
    end    
    ]]
    local devicestr = display.sizeInPixels.height.."X"..display.sizeInPixels.width
    return devicestr
end

function AndroidFunction.getChannelId()
    if device.platform == "android" then
        local args = {}
        local sig = "()I"
        local ok,channelid = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getChannelId", args, sig)
        return channelid
    end
    if device.platform == "ios" then
        return iOSFunction.getChannelId()
    end
end



function AndroidFunction.SetRoleInfo(roleId,roleName,roleLevel,serverId,serverName,goldCoin,dataType,createTime,param)
    if device.platform == "android" then
        local args = {
            roleId,--string
            roleName,--string
            roleLevel,--int
            serverId,--string
            serverName,--string
            goldCoin,--int
            dataType,--string
            createTime,
            param,--string 留空
        }

        print("AndroidFunction.SetRoleInfo",args[1],args[7],args[3],args[8])
        local sig = "(Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;ILjava/lang/String;ILjava/lang/String;)V"

        luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "setRoleInfo", args, sig)
    end
end

function AndroidFunction.ShowVideoSkip()
    if device.platform == "android" then
        local args = {}
        local sig = "()V"
        luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "showVideoSkip", args, sig)
    elseif device.platform == "ios" then
        iOSFunction.addSkipButton()
    end
end

---android版跳过函数
--------------------------------------------------------------------------
function AndroidFunction.isUseSdkExit()
    if device.platform == "android" then
        local args = {}
        local sig = "()I"
        local ok,ret = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog","isUseSdkExit",args,sig)
        return ret
    end
end

---android版推出函数
-----------------------------------------------------------------------
function AndroidFunction.sdkExit()
    if device.platform == "android" then
        local args = {}
        local sig = "()V"
        luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog","sdkExit",args,sig)   
    end     
end

----android版跳出按钮消失
-----------------------------------------------------------------------
function AndroidFunction.videoSkipViewHide()
    if device.platform == "android" then
        local args = {}
        local sig  = "()V"
        luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog","skipViewHide",args,sig)  
    end
end

---android Pay
function AndroidFunction.payOnAndroid(productData)
    if device.platform == "android" then 
        local orderno = PayConfig.genOrderNo(productData.productId)
        print("orderno & price:"..orderno,productData.price)
        local price = productData.price
        --price = 1.0
        local args = {orderno,price,productData.productId,LuaSqlite.getLanguageByKey(productData.productName),LuaSqlite.getLanguageByKey(productData.productDesc)}
        local sig = "(Ljava/lang/String;FLjava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
        luaj.callStaticMethod("org/cocos2dx/lua/FCSdk","payMoney",args,sig)

        local params = {}
        params.zuanshi = productData.zuanshi
        params.cash = productData.price
        params.sn_cp = orderno
        params.create_time = GameLogMgr.roleInfo.roleCreateTime
        local totalmoney = 0 
        if CharInfo.get().recharge then
            totalmoney = CharInfo.get().recharge.totalMoney or 0
        end
        params.total_pay = totalmoney
        GameLogMgr.OnGameStateChange(GameLogMgr.UserGameState.STATE_PAY_GENERATE,params)
    end
end


function AndroidFunction.showWebPage(url,horizonalScroll,verticalScroll)

    local args = {url,horizonalScroll,verticalScroll}
    local sig = "(Ljava/lang/String;ZZ)V"
    luaj.callStaticMethod("org/cocos2dx/lua/FCSdk","openWebView",args,sig)    
    print("AndroidFunction.showWebPage:......"..url)
end

function AndroidFunction.AdTrackingOnLogin(parameters)
    local loginstr = tostring(parameters.account)
    local args = {loginstr}
    local sig = "(Ljava/lang/String;)V"
    local channelid = AndroidFunction.getChannelId()
    if channelid == 1002 then --奥飞的id
        luaj.callStaticMethod("org/cocos2dx/lua/FCSdk","AdTrackingOnLogin",args,sig)         
    end
end

function AndroidFunction.AdTrackingOnCreateRole(parameters)
    local nickname = parameters.name 
    local args = {nickname}
    local sig = "(Ljava/lang/String;)V"
    local channelid = AndroidFunction.getChannelId()
    if channelid == 1002 then --奥飞id
        luaj.callStaticMethod("org/cocos2dx/lua/FCSdk","AdTrackingOnCreateRole",args,sig)        
    end
end

function AndroidFunction.AdTrackingOnPay(parameters)
    
    local userid = parameters.userid
    local orderid = parameters.orderid
    local amount = parameters.amount
    local curency = parameters.curency
    local paytype = parameters.paytype
    amount = amount*100
    local args = {userid,orderid,amount,curency,paytype}
    local sig = "(Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;)V"
    local channelid = AndroidFunction.getChannelId()
    if channelid == 1002 then --奥飞id
        luaj.callStaticMethod("org/cocos2dx/lua/FCSdk","AdTrackingOnPay",args,sig)        
    end
end

---以下的函数是android手机调用Lua的函数
---全局函数
function globalBackMenuForAndroid(param)
    UIStack.onBackMenu()
end 

--SDK切换账号
function globalSwitchForAndroid(param)
	AllSDKManager.FangCun:restart()
end 

---SDK登录界面被取消
function globalCancelSdkLoginUIForAndroid(param)
    LoginViewMgr.onAndroidSdkUICancel()
end 

---apk安装时调用此函数
function globalOnApkInstall(param)
    GameLogMgr.OnGameStateChange(GameLogMgr.UserGameState.STATE_APK_INSTALL)
end

---跳过视频的全局函数
function globalSkipVideoPlay(param)
    local layer= CSResourceMgr.getCsbObj("Scene/CommonMask.csb","CocosModuleMgr.playVideo")
    local layerBlack = CSResourceMgr.getCsbObj("Scene/CommonBlack.csb","CocosModuleMgr.playVideo")
    if layer~=nil and layerBlack~=nil then 
        print("layer is not nil")
        layer:performWithDelay(function()
            --CSResourceMgr.callButtonFunc(layer.res, "mask", layer.tag)
            --videoPlayer:removeFromParent(true)
            CocosModuleMgr.VideoPlayer:removeFromParent(true)
            CocosModuleMgr.VideoPlayer = nil
            CSResourceMgr.removeCSObjectByTag(layer.res, layer.tag)
            CSResourceMgr.removeCSObjectByTag(layerBlack.res, layerBlack.tag)
            SceneMgr.setMapVisible(true)
            if CocosModuleMgr.VideoCallBack then
                CocosModuleMgr.VideoCallBack()
            end
            if CocosModuleMgr.IsMusicOpen then
                GameAudio.setMusicOpen(true)
            else
                GameAudio.setMusicOpen(false)               
            end
        end, 0.1)
    end
end

--游戏日志的退出调用
function globalExitAndroidApp(param)                  
    GameLogMgr.OnGameStateChange(GameLogMgr.UserGameState.STATE_APP_EXIT)
end

function AndroidFunction.DoBlockChain(param)   
	if device.platform == "android" then 
        local BlockChainKey = param
        print("-----BlockChainKey:"..BlockChainKey.."-----")
		local BlockChaincallbackname = "GlobalOnBlackChainResult"
		local timestamp = CharInfo.getServerTime()
		local action = "sign"
        local args = {action,BlockChainKey,timestamp,BlockChaincallbackname}
        local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
        luaj.callStaticMethod("org/cocos2dx/lua/FCSdk","BlockChain",args,sig)
    end
end

function globalReloginGame(param)
	AllSDKManager.FangCun.m_loginState =nil
    LoginViewMgr.gameReInit()
end

AndroidFunction.scanCodeCallBack = nil
function globalOnScanCodeResult(param) 
    print("globalOnScanCodeResult:",param) 
    SceneMgr.getRunningScene:performWithDelay(function()
                   --DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,1,param)
                   if AndroidFunction.scanCodeCallBack~=nil then
                        AndroidFunction.scanCodeCallBack(param)
                        AndroidFunction.scanCodeCallBack = nil
                   end
                end, 0.5)               
    --DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,1,param)
end

--获得语言
function AndroidFunction.PushLanguage()
    if device.platform == "android" then
		local langtype = LuaSqlite.LANG_TYPE
        local args = {langtype}
        local sig = "(I)V"
        luaj.callStaticMethod("org/cocos2dx/lua/FCSdk", "PushLanguage", args, sig)
	elseif device.platform == "ios" then
		--when you need ,you add.
    end
end
function GlobalOnBlackChainResult(param) 
    print("GlobalOnBlackChainResult:",param) 
	NetInterface.sendWithBlock("GC_ImportEthPet_Ack", function()
		local PetSend = require("src.Net.Send.PetSend")
		PetSend.sendCG_ImportEthPet_Req(param)
	end, function()
		TipsMgr.show(nil, "chain6")
	end, function(code)
		TipsMgr.showError(nil, code)
	end)

end

return AndroidFunction