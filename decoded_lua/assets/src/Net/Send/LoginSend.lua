require("src.Net.Proto.ProtoInclude")

local LoginSend = {}
local NetMgr = require("src.Net.NetMgr")
local GenInfo = require("src.Data.GenInfo")

function LoginSend.sendCM_AppointNickName_Req(name)
	
	local data = {
        nickname = name
	}
    NetMgr.send(Proto.writeP_CM_AppointNickName_Req, data)
	
end

function LoginSend.sendCM_CreateChar_Req(params)
	
	local data = {
        nickname = params.name,
        gender = params.gender,
        world = params.world,
        country = 1,
        cullPet = params.cullPet,
        iconID = 1,
        spreader = "1",
        initFashionInfos = params.initFashionInfos,
	}
	print("send create char:"..tostring(data))
	
    NetMgr.send(Proto.writeP_CM_CreateChar_Req, data)
	
end

function LoginSend.sendCM_SelectChar_Req(id)

    local data = {
        charID = id,
    }
    NetMgr.send(Proto.writeP_CM_SelectChar_Req, data)
    
end

function LoginSend.sendCM_GetUserIDFromNick_Req(nickname)
	
	local data = {
	    nickname = nickname,
	}
	NetMgr.send(Proto.writeP_CM_GetUserIDFromNick_Req, data)
	
end

function LoginSend.sendCJ_login_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CJ_login_Req, data)

end

function LoginSend.sendCG_LoginSNS_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_LoginSNS_Req, data)

end

function LoginSend.sendCM_ReLoginCharacter_Req(params)

    local data = {
        username = params.username,
        password = params.password,
        userID = params.userid,
        charID = params.charid,
    }
    print("username:", data.username)
    print("password:", data.password)
    print("userID:", data.userID)
    print("charID:", data.charID)
    NetMgr.send(Proto.writeP_CM_ReLoginCharacter_Req, data)

end

function LoginSend.sendCG_GetServerTime_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetServerTime_Req, data)

end

function LoginSend.sendCM_ChangeInfo_Req(params)

    local data = {
        charId = CharInfo.getCharID(),
        key = params.key,
        content = params.content,
    }
    NetMgr.send(Proto.writeP_CM_ChangeInfo_Req, data)

end

function LoginSend.sendCM_ReadInfo_Req(key)

    local data = {
        key = key,
    }
    NetMgr.send(Proto.writeP_CM_ReadInfo_Req, data)

end

function LoginSend.sendCG_GetCharacterValues_Req(params)

    local data = {
        keys = params,
    }
    print("call LoginSend.sendCG_GetCharacterValues_Req")    
    
    NetMgr.send(Proto.writeP_CG_GetCharacterValues_Req, data)

end

function LoginSend.sendCM_KickChar_Req()

    local data = {
        charID = CharInfo.getCharID(),
    }
    NetMgr.send(Proto.writeP_CM_KickChar_Req, data)

end

function LoginSend.sendCG_DeviceLogin_Req(params)
    local data = {
        id = params.id,
        world = params.world,
        token = params.token,
    }
    print("send device-login request id:%s world:%s,token:%s" ,params.id,params.world,params.token)
    NetMgr.send(Proto.writeP_CG_DeviceLogin_Req, data)

end

function LoginSend.sendCG_DeviceRelogin_Req(params)
    print("send device-relogin request")
    info = getLoginInfo()
    local data = {
        userID = info.userID,
        userToken = info.userToken
    }
    NetMgr.send(Proto.writeP_CG_DeviceRelogin_Req, data)
end

function LoginSend.sendCG_BuyPower_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_BuyPower_Req, data)

end

function LoginSend.sendCG_BuyGCash_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_BuyGCash_Req, data)

end

function LoginSend.sendCG_SetCharSign_Req(params)

    local data = {
        charSign = params
    }
    NetMgr.send(Proto.writeP_CG_SetCharSign_Req, data)

end

function LoginSend.sendCG_GetCharSign_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetCharSign_Req, data)

end

function LoginSend.sendCG_ClientInfo_Req(params)

    local data = {
		ip = params.ip,
		device_model = params.device_model,
		os_name = params.os_name,
		os_ver = params.os_ver,
		mac_addr = params.mac_addr,
		udid = params.udid,
		app_channel = params.app_channel,
		app_ver = params.app_ver,
		network = params.network,
		device_screen = tostring(params.device_screen),
        platform_tag = params.platform_tag,
        group_id = params.group_id,
        channel_id = tonumber(params.channel_id),

    }
    NetMgr.send(Proto.writeP_CG_ClientInfo_Req, data)

end

function LoginSend.sendCG_GetPlayerPointRank_Req(params)

    local data = {
        rankMin = params.rankMin,
        rankMax = params.rankMax,
    }
    NetMgr.send(Proto.writeP_CG_GetPlayerPointRank_Req, data)

end

function LoginSend.sendCG_GetMyPlayerPoint_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetMyPlayerPoint_Req, data)

end

function LoginSend.sendCG_CheckUserCode_Req(code)

    local data = {
        code = code,
    }
    NetMgr.send(Proto.writeP_CG_CheckUserCode_Req, data)

end

function LoginSend.sendCG_NewAccountBindOldRoleID_Req(code)

    local data = {
        QRCode = code,
    }
    NetMgr.send(Proto.writeP_CG_NewAccountBindOldRoleID_Req, data)

end

return LoginSend
