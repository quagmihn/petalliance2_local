--
-- Author: Li Xiaolong
-- Date: 2014-10-20 11:52:27
--
--[[
0, 方寸
1, 91
2, 同步推
3, 快用
4, pp助手
15, 网易
15-netease, 网易网易
15-91_assistant, 网易91
15-tongbutui, 网易同步
15-kuaiyong, 网易快用
15-25pp, 网易PP
15-itools, 网易it
15-xyzs - 网易xy
15-dangle -网易当乐
15-yixin, 网易易信,这个值不启用,还是使用netease
--]]
---------------------------------------------------------------------------------------------FangCun
AllSDKManager.FangCun = {}
local FangCunSDKManager = cc.FangCunSDKManager
local FangCun = AllSDKManager.FangCun
local Platform = "netease"

local isInMainScene = false
function setisInMainScene(bool)
   isInMainScene = bool
end

--[[
14 1013服 苹果审核
15 1010服(默认)
16 1011服 网易QA
17 1012服 运营服
--]]
if not IOS_IsAtReview then
	IOS_IsAtReview = function()
		return false
	end
end
if not IOS_IsAtQA then
	IOS_IsAtQA = function()
		return false
	end
end
if not IOS_IsAtYY then
	IOS_IsAtYY = function ()
		return false
	end
end
function FangCun:init()
	if device.platform == "ios" then
		if IOS_IsAtReview() then
			print("审核版本")
			if gameConfig.language=="tw" then
				FangCunSDKManager:updateCoreID(5)
			else
				FangCunSDKManager:updateCoreID(14)
			end
			return
		end
		if FangCunSDKManager.openCurrency then
			print("外网版本 设置货币限制")
			FangCunSDKManager:addCurrency("CNY")
			FangCunSDKManager:openCurrency()
		end
	end
end
if not isDevelopMode then
	FangCun:init()
end
--[[
nil 未登录|登录失败
0 登录中
1 登录成功
--]]
FangCun.m_loginState = nil
--是否在login界面打开用户中心
FangCun.m_notLogin = nil
--用户token
FangCun.userid_token = nil
local txChannel = nil
--登录游戏
function FangCun:login()
	--没有登录成功,重新点击登录
	if not self.m_loginState or self.m_loginState == 0 then
		self.m_loginState = 0
		FangCunSDKManager:FCLogin()
	end
end
--打开用户中心,是否在login界面打开
FangCun.button = nil
function FangCun:memgerCenter(notLogin)
	print("memgerCenter",notLogin)
	FangCun.m_notLogin = notLogin
	FangCunSDKManager:FCMemberCenter()
end
function FangCun:getNetEaseMemberCenterUpdate()
	if FangCunSDKManager.getNetEaseMemberCenterUpdate then
	   return FangCunSDKManager:getNetEaseMemberCenterUpdate()
	else
	   return false
	end
end
function FangCun:showMemgerCenter()
	print("showMemgerCenter",FangCunSDKManager:hasFCMemberCenter())
	if not FangCun.button then
		return
	end
	if 	device.platform == "ios" then
		if not FangCunSDKManager:hasFCMemberCenter() then
			FangCun.button:setVisible(false)
		end
	end
end
function FangCun:getMemgerCenter()
	if FangCun.button then
		return FangCun.button
	end
	if (device.platform == "android" and FangCunSDKManager:hasFCMemberCenter()) or
		(device.platform == "ios" and gameConfig.language~="tw") then
		FangCun.button = cc.luaButton({
		    image1 = {"UI/login/btn_he.png","UI/login/btn_he_down.png"},
		    text1 = "用户中心",
	    	fontSize = 24,
	    	fontID = 2,
	    	ap=ccp(1, 0),
	    	onClicked = function ()
	    	   setisfirstopenMemberCenter(false)
	    	   RemindHelper.checkMemberCenterNotice()
	    	   AllSDKManager.FangCun:memgerCenter()
	    	end,
		})
		FangCun.button:addNodeEventListener(cc.NODE_EVENT, function(event)
	        if event.name == "cleanup" then
	           FangCun.button = nil
	        end
	    end)
		return FangCun.button
	end
end
--退出登录,收到退出成功后android重启,iOS退出游戏
function FangCun:logout()
	FangCunSDKManager:FCLogout()
end
--退出游戏
function FangCun:exit()
    --[[
	device.showAlert("温馨提示","退出游戏后请重新登录","我知道了",function()
		AllSDKManager.FangCun:roleInfo(getSession().id, getCharacterData().nickname, getCharacterData().mLevel, getCharacterData().vip.level, game.localConfigTable.lastWorldIdx, game.localConfigTable.lastWorldName,"logout",returnRoleParameter())
		os.exit(0)
	end)
    ]]
end
--重启游戏,android重启,iOS退出游戏
function FangCun:resetLocalLogin()
    if not self.m_localLogin then
        return
    end
    self.userid_token = nil
    self.m_loginState = nil
    self.m_localLogin = nil
    self.m_localLoginStarted = nil
    self.platformType = nil
end

function FangCun:restart()
    if self.m_localLogin then
        self:resetLocalLogin()
        return
    end
	if device.platform == "android" then
		--FangCunSDKManager:reStart()
        if self.m_loginState ~=nil and self.m_loginState ~= 0 then 
            FangCun:logout()
        end
	elseif device.platform == "ios" then
		FangCun:exit()
	end
end
function FangCun:pay(orderNO, productId, productName, productDesc, price,amount)
	print("FangCun",orderNO, productId, productName, productDesc, price,amount)
	FangCunSDKManager:FCPay(tostring(orderNO), tostring(productId), tostring(productName), tostring(productDesc), tostring(price),tostring(amount))
end
function FangCun:roleInfo(roleId, roleName, roleLevel, vipLevel, serverId, serverName,dataType,parameter)
	print(roleId, roleName, roleLevel, vipLevel, serverId, serverName,dataType,parameter)
	Platform = FangCun:getPlatformChannel()
	FangCunSDKManager:FCSetRoleInfo(tostring(roleId), tostring(roleName), tostring(roleLevel), tostring(vipLevel), tostring(serverId), tostring(serverName),tostring(dataType),tostring(parameter))
end
function FangCun:getPlatformID()
	if self.m_loginState and self.m_loginState==1 then
		return FangCunSDKManager:FCPlatformId()
	else
		return "-1"
	end
end
function FangCun:getPlatformChannel()
	if self.m_loginState and self.m_loginState==1 then
		return FangCunSDKManager:FCPlatformChannel()
	else
		return ""
	end
end
function FangCun:getPlatformAppChannel()
	if self.m_loginState and self.m_loginState==1 then
		return FangCunSDKManager:FCPlatformAppChannel()
	else
		return ""
	end
end
function FangCun:getPlatformType()
	if not self.platformType then
		self.platformType = FangCun:getPlatformID()
		local channel = FangCun:getPlatformChannel()
        txChannel=channel
		if self.platformType=="-1" then
			print("玩家未登录,平台id无效")
			self.platformType = nil
			return "-1"
		end
		if channel~="" then
			self.platformType = self.platformType .. "-" .. channel
		end
	end
	return self.platformType
end
function FangCun:loginLocal()
    if self.m_localLoginStarted then
        print("local login already started")
        return
    end

    local deviceId = "monster2-waydroid"
    if device and device.getOpenUDID then
        deviceId = tostring(device.getOpenUDID() or deviceId)
    end
    local uid = "local-" .. crypto.md5(deviceId)
    local token = crypto.md5("monster2-private:" .. deviceId)

    self.userid_token = {userId = uid, openid = uid, token = token}
    self.m_loginState = nil
    self.m_localLogin = true
    self.m_localLoginStarted = true
    self.platformType = "local-private"
    txChannel = "local"

    print("using local account", uid)
    if GameLogMgr and GameLogMgr.OnGameStateChange then
        pcall(function()
            GameLogMgr.OnGameStateChange(GameLogMgr.UserGameState.STATE_USERIDENTIFY)
        end)
    end

    local NetMgr = require("src.Net.NetMgr")
    NetMgr.getServerList()
end

function FangCun:isAppstore()
	if self.m_bIsAppstore == nil then
		if FangCun:getPlatformType() == "15-netease" or FangCun:getPlatformType() == "15-yixin" then
			self.m_bIsAppstore = true
		else
			self.m_bIsAppstore = false
		end
	end
	return self.m_bIsAppstore
end
--------------------------------------------------------------------------------
function FangCunCallBack(param)
    param = param or {}
    local ver = tonumber(param.ver) or param.ver
    print("SDK回調函數", ver, param.name)
    -- Ignore non-JSON SDK status strings such as "isLogined." safely.
    local token = {}
    if type(param.name) == "table" then
        token = param.name
    elseif type(param.name) == "string" and param.name ~= "" then
        local ok, decoded = pcall(json.decode, param.name)
        if ok and type(decoded) == "table" then
            token = decoded
        else
            print("SDK callback payload is not account JSON:", param.name)
        end
    end
    if ver == 0 then
        --CCDirector:sharedDirector():resume()
        --cc.luaAudio:resumeMusic()
        cc.luaAudio:setMusicVolume( 35 )
	elseif ver == 1 then
        --CCDirector:sharedDirector():pause()
        --cc.luaAudio:pauseMusic()
        cc.luaAudio:setMusicVolume( 0 )
    elseif ver == 2 then
        FangCun:restart()
	elseif ver == 100 then
		--初始化成功 登录
	elseif ver == 101 then
		print("初始化失败")
        
	elseif ver == 200 then
		--登录成功
		txChannel = FangCunSDKManager:FCPlatformChannel()
        --print("++++++++txChannel+++++++++++"..FangCun:getPlatformID()..txChannel)
		if FangCun.m_notLogin and device.platform=="ios" then
			--ios 用户在用户中心绑定游客账号
			return
		end
		FangCun.m_loginState = 1
		if FangCun.userid_token == nil then
            FangCun.userid_token = token
            print("sdk登录成功")
            local NetMgr = require("src.Net.NetMgr")
            GameLogMgr.OnGameStateChange(GameLogMgr.UserGameState.STATE_USERIDENTIFY)
            NetMgr.getServerList()
            --[[
            local schedule = require("framework.scheduler")
            getServerShow().textLabel0:stopAllActions()
            --schedule.unscheduleGlobal( getServerShow().sdkloginPictureSchedule)
            getServerShow().textLabel0:setImage("UI/login/btn_ksyx_djjr.png")
            getServerShow().textLabel0:setScale(1.2)
            if getServerShow().sdkloginPicturefadeSchedule ~= nil then
            require("framework.scheduler").unscheduleGlobal( getServerShow().sdkloginPicturefadeSchedule)
            end
            getServerShow().sdkloginPicturefadeSchedule = schedule.scheduleGlobal(sdkloginPicturefadeinfadeout,   0.3)
            getServerShow().blackLayer:setVisible(false)
            FangCun:showMemgerCenter()
            RemindHelper.checkMemberCenterNotice()
            FangCun:showUserAggrementButton()
            --]]
		elseif FangCun.userid_token == token then
			print("同一个用户不做处理")--token不一样,感觉永远不会走到
            local NetMgr = require("src.Net.NetMgr")
            GameLogMgr.OnGameStateChange(GameLogMgr.UserGameState.STATE_USERIDENTIFY)
            NetMgr.getServerList()
		else 
			print("另一个用户直接重启",FangCun.m_notLogin)
			if device.platform=="android" then
				if FangCun.m_notLogin then
					--FangCunSDKManager:reStart()
                    FangCun:restart()
				else
					if AllSDKManager.FangCun:getPlatformType() == "15-netease" then
					  FangCun.userid_token = nil
					else
					  --FangCunSDKManager:reStart()
                      FangCun:restart()
					end
				end
			elseif device.platform=="ios" then
				if FangCun.m_notLogin then
					FangCun:exit()
				else
					FangCun.userid_token = token
				end
			end
			FangCun:showMemgerCenter()
			RemindHelper.checkMemberCenterNotice()
			FangCun:showUserAggrementButton()
		end
	elseif ver == 201 then
		--取消登录 返回logo界面
		--print("++++201+++++++"..txChannel)
        print("++++201+++++++")
		if FangCun.userid_token then
            --if txChannel == "kuaifa" then
                FangCun:restart()
            --else 
                --FangCun.m_loginState = nil
           -- end
		else
            FangCun:restart()
			--FangCun.m_loginState = nil
		end
    elseif ver == 202 then
        -- FCManager can report "isLogined." even though Lua has no usable
        -- account token. Continue with the stable local identity instead.
        print("SDK login unavailable/already logged in; using local account")
        FangCun:loginLocal()
	elseif ver == 203 then
		--登录窗口关闭(包括登录成功后的关闭)
		FangCun.m_loginState = nil
		FangCun.userid_token = nil
		if FangCun.m_notLogin then
			--用户中心切换账号
		else
			if getServerShow().sdkloginPicturefadeSchedule then
		 	   require("framework.scheduler").unscheduleGlobal( getServerShow().sdkloginPicturefadeSchedule)
			end
			getServerShow().blackLayer:setVisible(false)
		end
	elseif ver == 300 then
		--登出成功
		print("++++300+++++++"..AllSDKManager.FangCun:getPlatformType())
		FangCun.m_loginState = nil
        FangCun.userid_token = nil
		if device.platform=="android" then
            LoginViewMgr.gameReInit() 
            --[[
           if SceneMgr.currentScene~="LoginScene" then 
                LoginViewMgr.gameReInit() 
           end
           ]]
			if isInMainScene then
			   if getSession().id ~= 0 then
				  AllSDKManager.FangCun:roleInfo(getSession().id, getCharacterData().nickname, getCharacterData().mLevel, getCharacterData().vip.level, game.localConfigTable.lastWorldIdx, game.localConfigTable.lastWorldName,"logout",returnRoleParameter())
			   end
               --AllSDKManager.FangCun:login()
			   --FangCunSDKManager:reStart()

               FangCun:restart()
			end
			if FangCun.m_notLogin then
				if getSession().id ~= 0 then
				   AllSDKManager.FangCun:roleInfo(getSession().id, getCharacterData().nickname, getCharacterData().mLevel, getCharacterData().vip.level, game.localConfigTable.lastWorldIdx, game.localConfigTable.lastWorldName,"logout",returnRoleParameter())
				end
				if AllSDKManager.FangCun:getPlatformType() == "15-netease" then
				  FangCun.userid_token = nil
				else
				  --FangCunSDKManager:reStart()
                  FangCun:restart()
				end
			else
				if AllSDKManager.FangCun:getPlatformType() == "15-netease" then
				  FangCun.userid_token = nil
				else
				  --FangCunSDKManager:reStart()
                  FangCun:restart()
				end
			end
		elseif device.platform=="ios" then
			if isInMainScene then
			   if getSession().id ~= 0 then
				  AllSDKManager.FangCun:roleInfo(getSession().id, getCharacterData().nickname, getCharacterData().mLevel, getCharacterData().vip.level, game.localConfigTable.lastWorldIdx, game.localConfigTable.lastWorldName,"logout",returnRoleParameter())
			   end
			   FangCun:exit()
			end
			if FangCun.m_notLogin then
				if getSession().id ~= 0 then
				   AllSDKManager.FangCun:roleInfo(getSession().id, getCharacterData().nickname, getCharacterData().mLevel, getCharacterData().vip.level, game.localConfigTable.lastWorldIdx, game.localConfigTable.lastWorldName,"logout",returnRoleParameter())
				end
				FangCun:exit()
			else
				FangCun.userid_token = nil
			end
		end
	elseif ver == 301 then
		--登出失败
	elseif ver == 400 then
		--退出成功
		FangCun:exit()
	elseif ver == 401 then
		--退出取消
	elseif ver == 402 then
		--退出失败
		device.showAlert("确认退出", "是否退出游戏？", {"是", "否"}, function(event)
			if event.buttonIndex == 1 then
				game.exit()
			end
		end)
	elseif ver == 500 then
		print("支付成功")
        local orderNO = token.orderNO
        local sdkOrderNO = token.sdkOrderNO
        PayConfig.onPaySuccess(orderNO,sdkOrderNO)
		--delete_chongzhi_blackLayer()
		--netease_order_req(0)
		-- recharge_ntf_query_req()
		--支付成功
	elseif ver == 501 then
		print("支付取消")
		--delete_chongzhi_blackLayer()
		--netease_order_req(1)
		-- payCancel()
	elseif ver == 502 then
		print("支付失败")
        --PayConfig.onPayError(param.ver)
        --[[
		dump(token)

        
		delete_chongzhi_blackLayer()
		netease_order_req(2)
		if device.platform == "ios" then
			--10及以后的版本才支持 充值日志协议
			require("message.neteaseToken")
			if FangCunSDKManager.IOSVersionInt and FangCunSDKManager:IOSVersionInt()>=10 then
				message.netease_order_poll(token)
			else
				message.netease_order_failed(token)
			end
		end
        ]]
		-- payCancel()
	elseif ver == 503 then
		print("服务器验证订单失败")
        PayConfig.onPayError(param.ver)
        --[[
		dump(token)
      
		if device.platform == "ios" then
			require("message.neteaseToken")
			if FangCunSDKManager.IOSVersionInt and FangCunSDKManager:IOSVersionInt()>=10 then
				message.netease_order_poll(token)
			else
				local failed_data = {}
				failed_data.orderNO = token.orderNO
				failed_data.failReason = "503 invalid order"
				failed_data.currency = token.errDesc.payCurrency
				message.netease_order_failed(failed_data)
			end
		end
        ]]
	elseif ver == 504 then
		print("所有订单的验证结果会通知")
        --PayConfig.onPayError(param.ver)
        --[[
		dump(token)
		if device.platform == "ios" then
			require("message.neteaseToken")
			if FangCunSDKManager.IOSVersionInt and FangCunSDKManager:IOSVersionInt()>=10 then
				message.netease_order_poll(token)
			end
		end
        ]]
	else
		print("方寸sdk新的错误码",param.ver,param.name)
	end
end

function SDkManager(param)
	FangCunCallBack( param )
end

return FangCun