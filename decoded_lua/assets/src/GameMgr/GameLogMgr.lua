--[[
这是记录游戏日志的管理类，所以游戏日志的操作都记录在这个文件

]]


local GameLogMgr = {}

local gameGuideTempParams = {} --temp params for save game guide
local payMoneyRecords = {} --record pay money
GameLogMgr.UserGameState = { --玩家状态
	STATE_BEGIN                 = 0,    --开始标志位
	STATE_ACTIVATION            = 1,    --激活
	STATE_SELECTSERVER          = 2,    --选择服务器
	STATE_CREATECHAR            = 3,    --创建脚色
	STATE_LOGINVIEW             = 4,    --打开登陆界面
	STATE_UPDATEGAME_START      = 5,    --更新游戏开始
    STATE_UPDATEGAME_SUCCESS    = 6,    --更新游戏成功
    STATE_UPDATEGAME_ERROR      = 7,    --更新游戏失败
	STATE_LOGIN                 = 8,    --登陆游戏成功
	STATE_LOADINGTOGAME         = 9,    --进入了游戏
	STATE_LEVELUP               = 10,   --等级提升
	STATE_LOGOUT                = 11,   --退出游
    STATE_APK_INSTALL           = 12,   --APK安装时
    STATE_USERIDENTIFY          = 13,   --玩家登录成功时
    STATE_APP_EXIT              = 14,   --terminate app
    STATE_GAME_GUIDE            = 15,   --新手引导
    STATE_PAY_GENERATE          = 16,   --支付订单生成
    STATE_PAY_CALLBACK          = 17,   --支付成功回调
}

GameLogMgr.dataTypeEnum = {--角色信息类型枚举,奥飞SDK需要记录
    EVENT_TYPE_SELECT   = "select",
    EVENT_TYPE_LOGIN    = "login",
    EVENT_TYPE_CREATE   = "create",
    EVENT_TYPE_UPGRADE  = "upgrade",
    EVENT_TYPE_LOGOUT   = "logout",
    EVENT_TYPE_PAY      = "pay",
    EVENT_TYPE_PAUSE    = "pause",
    EVENT_TYPE_EXIT     = "exit",
    EVENT_TYPE_GUIDESTART = "guidestart",
    EVENT_TYPE_GUIDEEND   = "guideend",

}

GameLogMgr.roleInfo = { --玩家角色信息
    bCreateChar = false,
    roleId  = 0,
    roleName = "",
    roleLevel = 0,
    serverId = 0,
    serverName = "",
    gcash = "",
    roleCreateTime = 0,
}

local curGameState = 0
local firstLoadingToGame = 0 --是否第一次加载到场景
function GameLogMgr.Init()
	curGameState = GameLogMgr.UserGameState.STATE_BEGIN
    GameLogMgr.roleInfo.bCreateChar = false
    firstLoadingToGame = 0
    gameGuideTempParams = {}
end

---function OnGameStateChange玩家游戏状态变化
--@param state UserGameState 
--@param params table 参数
function GameLogMgr.OnGameStateChange(state,params)
    if device.platform == "android" or device.platform == "ios" then
	    curGameState = state
	    if curGameState == GameLogMgr.UserGameState.STATE_ACTIVATION then --激活
		    XFangCunLogSender.logActivation()
	    end
	
        if curGameState == GameLogMgr.UserGameState.STATE_SELECTSERVER then --选择服务器
           
	       NetInterface.sendWithBlock("GC_ClientInfo_ACK",
	       function() 
	      
                local LoginSend = require("src.Net.Send.LoginSend")
	            LoginSend.sendCG_ClientInfo_Req(XFangCunLogSender.createUserInfoTable())
	       end,
	   
	       function() 
	       end,
	       function(code) 
	   
	       end)	 

            if params~=nil then 
                --GameLogMgr.roleInfo.serverId = tostring(params.serverid)
                --GameLogMgr.roleInfo.serverName = params.servername
                --print("GameLogMgr.roleInfo.serverName" ..GameLogMgr.roleInfo.serverName)
            else
                
            end

            if device.platform == "android" then 
                AndroidFunction.SetRoleInfo(GameLogMgr.roleInfo.roleId,GameLogMgr.roleInfo.roleName,GameLogMgr.roleInfo.roleLevel,GameLogMgr.roleInfo.serverId,GameLogMgr.roleInfo.serverName,GameLogMgr.roleInfo.gcash,GameLogMgr.dataTypeEnum.EVENT_TYPE_SELECT,GameLogMgr.roleInfo.roleCreateTime,"")  
            elseif device.platform == "ios" then
                iOSFunction.setRoleInfo(GameLogMgr.roleInfo)
            end
        end

	    if curGameState == GameLogMgr.UserGameState.STATE_CREATECHAR then --服务器作,但奥飞sdk要发送信息
	       GameLogMgr.roleInfo.bCreateChar = true
	    end
	
        if curGameState == GameLogMgr.UserGameState.STATE_UPDATEGAME_START then --更新游戏开始
	       XFangCunLogSender.logUpdateStart()
	    end

        if curGameState == GameLogMgr.UserGameState.STATE_UPDATEGAME_ERROR then --更新游戏失败
	       XFangCunLogSender.logUpdateFail()
	    end

        if curGameState == GameLogMgr.UserGameState.STATE_UPDATEGAME_SUCCESS then --更新游戏失败
	       XFangCunLogSender.logUpdateEnd()
	    end
	
	    if curGameState  == GameLogMgr.UserGameState.STATE_LOGINVIEW then --游戏登陆界面
	       XFangCunLogSender.LoginUI()
	    end
	
	    if curGameState == GameLogMgr.UserGameState.STATE_LOADINGTOGAME then --进入游戏
            XFangCunLogSender.logLoad()
            --进入了游戏后，开始进行奥飞的东东
            if params == nil then return end
            
            local roleId = CharInfo.getCharID()
            if roleId~=0 and firstLoadingToGame == 0 then -- 如果不等于0，说明有帐号了,并且是第一次进游戏
                GameLogMgr.roleInfo.roleId = tostring(roleId)
                GameLogMgr.roleInfo.roleName = CharInfo.getNickName()
                GameLogMgr.roleInfo.roleLevel = CharInfo.getLevel()
                GameLogMgr.roleInfo.gcash = CharInfo.getGCash()
                
                if device.platform == "android" then 

                    if GameLogMgr.roleInfo.bCreateChar == true then 
                        AndroidFunction.SetRoleInfo(GameLogMgr.roleInfo.roleId,GameLogMgr.roleInfo.roleName,GameLogMgr.roleInfo.roleLevel,GameLogMgr.roleInfo.serverId,GameLogMgr.roleInfo.serverName,GameLogMgr.roleInfo.gcash,GameLogMgr.dataTypeEnum.EVENT_TYPE_CREATE,GameLogMgr.roleInfo.roleCreateTime,"")    
                        GameLogMgr.roleInfo.bCreateChar = false          
                    end
                    AndroidFunction.SetRoleInfo(GameLogMgr.roleInfo.roleId,GameLogMgr.roleInfo.roleName,GameLogMgr.roleInfo.roleLevel,GameLogMgr.roleInfo.serverId,GameLogMgr.roleInfo.serverName,GameLogMgr.roleInfo.gcash,GameLogMgr.dataTypeEnum.EVENT_TYPE_LOGIN,GameLogMgr.roleInfo.roleCreateTime,"")   
                elseif device.platform == "ios" then
                iOSFunction.setRoleInfo(GameLogMgr.roleInfo)
                GameLogMgr.roleInfo.bCreateChar = false  
                end
                firstLoadingToGame = 1
    
                --获得角色创建时间
                --[[这段代码要注释掉，有可能引发加载卡住的bug
                NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
                    local LoginSend = require("src.Net.Send.LoginSend")
                    LoginSend.sendCG_GetCharacterValues_Req({"create_time"})
                end, function()
                    print("create_time is:"..GameLogMgr.roleInfo.roleCreateTime)
                    if device.platform == "android" then 
    
                        if GameLogMgr.roleInfo.bCreateChar == true then 
                          AndroidFunction.SetRoleInfo(GameLogMgr.roleInfo.roleId,GameLogMgr.roleInfo.roleName,GameLogMgr.roleInfo.roleLevel,GameLogMgr.roleInfo.serverId,GameLogMgr.roleInfo.serverName,GameLogMgr.roleInfo.gcash,GameLogMgr.dataTypeEnum.EVENT_TYPE_CREATE,GameLogMgr.roleInfo.roleCreateTime,"")    
                          GameLogMgr.roleInfo.bCreateChar = false          
                        end
                        AndroidFunction.SetRoleInfo(GameLogMgr.roleInfo.roleId,GameLogMgr.roleInfo.roleName,GameLogMgr.roleInfo.roleLevel,GameLogMgr.roleInfo.serverId,GameLogMgr.roleInfo.serverName,GameLogMgr.roleInfo.gcash,GameLogMgr.dataTypeEnum.EVENT_TYPE_LOGIN,GameLogMgr.roleInfo.roleCreateTime,"")   
    
    
                    end
                    firstLoadingToGame = 1
                end)
                ]]
            end

	    end
	    
        if curGameState == GameLogMgr.UserGameState.STATE_APP_EXIT then 
             AndroidFunction.SetRoleInfo(GameLogMgr.roleInfo.roleId,GameLogMgr.roleInfo.roleName,GameLogMgr.roleInfo.roleLevel,GameLogMgr.roleInfo.serverId,GameLogMgr.roleInfo.serverName,GameLogMgr.roleInfo.gcash,GameLogMgr.dataTypeEnum.EVENT_TYPE_EXIT,GameLogMgr.roleInfo.roleCreateTime,"")            
            iOSFunction.setRoleInfo(GameLogMgr.roleInfo)
        end

	    if curGameState == GameLogMgr.UserGameState.STATE_LOGIN then 

        --[[
	       NetInterface.sendWithBlock("GC_ClientInfo_ACK",
	       function() 
	      
                local LoginSend = require("src.Net.Send.LoginSend")
	            LoginSend.sendCG_ClientInfo_Req(XFangCunLogSender.createUserInfoTable())
	       end,
	   
	       function() 
	       end,
	       function(code) 
	   
	       end)	   
           ]]
	    end

        if curGameState == GameLogMgr.UserGameState.STATE_APK_INSTALL then --第一次安装游戏
            
            XFangCunLogSender.Install()
        end

        if curGameState == GameLogMgr.UserGameState.STATE_LEVELUP then --人物升级
            GameLogMgr.roleInfo.roleLevel = CharInfo.getLevel()
            AndroidFunction.SetRoleInfo(GameLogMgr.roleInfo.roleId,GameLogMgr.roleInfo.roleName,GameLogMgr.roleInfo.roleLevel,GameLogMgr.roleInfo.serverId,GameLogMgr.roleInfo.serverName,GameLogMgr.roleInfo.gcash,GameLogMgr.dataTypeEnum.EVENT_TYPE_UPGRADE,GameLogMgr.roleInfo.roleCreateTime,"")  
            GameLogMgr.roleInfo.levelup = true
            iOSFunction.setRoleInfo(GameLogMgr.roleInfo)
            GameLogMgr.roleInfo.levelup = nil    
        end

        if curGameState == GameLogMgr.UserGameState.STATE_USERIDENTIFY then --角色认证成功
            XFangCunLogSender.Identification()
        end

        if curGameState == GameLogMgr.UserGameState.STATE_PAY_GENERATE then 
            XFangCunLogSender.logPayGenerate(params)
            payMoneyRecords[params.sn_cp] = params
        end

        if curGameState == GameLogMgr.UserGameState.STATE_PAY_CALLBACK then 
            local realparam = payMoneyRecords[params.orderNO]
            if realparam~=nil then 
                realparam.sn = params.sdkOrderNO
                XFangCunLogSender.logPayCallBack(realparam) 
                payMoneyRecords[params.orderNO] = nil 
            else
                print("GameLogMgr.UserGameState.STATE_PAY_CALLBACK cant find:"..params.orderNO)    
            end   
              
        end

        if curGameState == GameLogMgr.UserGameState.STATE_GAME_GUIDE then --新手引导 
            if params.logtype == GameLogMgr.dataTypeEnum.EVENT_TYPE_GUIDESTART then 
                gameGuideTempParams = params
            end

            if params.logtype == GameLogMgr.dataTypeEnum.EVENT_TYPE_GUIDEEND then
                if params.endLevel == nil or params.beginTime == nil or params.stepType == nil then 
                    if params.tutorialId == nil then params.tutorialId = "unknowquestid" end
                    print("Game Guide Log Problem: gameGuideTempParams guide start is nil:"..params.tutorialId)
                    return
                end
                gameGuideTempParams = params
                --[[
                gameGuideTempParams.endLevel = params.endLevel
                gameGuideTempParams.useTime  = params.beginTime - gameGuideTempParams.beginTime
                gameGuideTempParams.stepType = params.stepType
                ]]
            end
            pcall(function() 
                XFangCunLogSender.Tutorial(gameGuideTempParams)
            end)

            gameGuideTempParams = {}
        end
    end
end



return GameLogMgr