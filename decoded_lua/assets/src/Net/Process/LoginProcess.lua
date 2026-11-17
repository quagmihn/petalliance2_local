require("src.Net.Proto.ProtoInclude")

local LoginProcess = {}
local NetMgr = require("src.Net.NetMgr")
local GenInfo = require("src.Data.GenInfo")
local CharInfo = require("src.GameMgr.Data.CharInfo")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function LoginProcess.init()
    NetMgr.addProcess(Proto.Command.GC_CHECKUSERCODE_ACK,
        LoginProcess.onGC_CheckUserCode_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETMYPLAYERPOINT_ACK,
        LoginProcess.onGC_GetMyPlayerPoint_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETPLAYERPOINTRANK_ACK,
        LoginProcess.onGC_GetPlayerPointRank_Ack)
    NetMgr.addProcess(Proto.Command.GC_CLIENTINFO_ACK,
        LoginProcess.onGC_ClientInfo_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETCHARSIGN_ACK,
        LoginProcess.onGC_GetCharSign_Ack)
    NetMgr.addProcess(Proto.Command.GC_SETCHARSIGN_ACK,
        LoginProcess.onGC_SetCharSign_Ack)
    NetMgr.addProcess(Proto.Command.GC_BUYGCASH_ACK,
        LoginProcess.onGC_BuyGCash_Ack)
    NetMgr.addProcess(Proto.Command.GC_BUYPOWER_ACK,
        LoginProcess.onGC_BuyPower_Ack)
    NetMgr.addProcess(Proto.Command.GC_DEVICERELOGIN_ACK,
        LoginProcess.onGC_DeviceRelogin_Ack)
    NetMgr.addProcess(Proto.Command.GC_DEVICELOGIN_ACK,
        LoginProcess.onGC_DeviceLogin_Ack)
    NetMgr.addProcess(Proto.Command.GC_CLOSECLIENT_NTF,
        LoginProcess.onGC_CloseClient_Ntf)
    NetMgr.addProcess(Proto.Command.MC_KICKCHAR_ACK,
        LoginProcess.onMC_KickChar_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETCHARACTERVALUES_ACK,
        LoginProcess.onGC_GetCharacterValues_Ack)
    NetMgr.addProcess(Proto.Command.MC_READINFO_ACK,
        LoginProcess.onMC_ReadInfo_Ack)
    NetMgr.addProcess(Proto.Command.MC_CHANGEINFO_ACK,
        LoginProcess.onMC_ChangeInfo_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETSERVERTIME_ACK,
        LoginProcess.onGC_GetServerTime_Ack)
    NetMgr.addProcess(Proto.Command.GC_CHARACTERVALUESUPDATE_NTF,
        LoginProcess.onGC_CharacterValuesUpdate_Ntf)
    NetMgr.addProcess(Proto.Command.GC_LOGINSNS_ACK,
        LoginProcess.onGC_LoginSNS_Ack)
    NetMgr.addProcess(Proto.Command.JC_LOGIN_ACK,
        LoginProcess.onJC_login_Ack)
    NetMgr.addProcess(Proto.Command.GC_LOGIN_ACK, 
        LoginProcess.onGC_Login_Ack)
    NetMgr.addProcess(Proto.Command.MC_APPOINTNICKNAME_ACK,
        LoginProcess.onMC_AppointNickName_Ack)
    NetMgr.addProcess(Proto.Command.MC_CREATECHAR_ACK,
        LoginProcess.onMC_CreateChar_Ack)
    NetMgr.addProcess(Proto.Command.MC_GETUSERIDFROMNICK_ACK,
        LoginProcess.onMC_GetUserIDFromNick_Ack)
	NetMgr.addProcess(Proto.Command.GC_NEWACCOUNTBINDOLDROLEID_ACK,
        LoginProcess.onGC_NewAccountBindOldRoleID_Ack)

end

function LoginProcess.onGC_Login_Ack(msg)

    local res = Proto.parseP_GC_Login_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_Login_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        GenInfo.onGC_Login_Ack(res)
        CharInfo.setServerTime(res.serverTime)
        CharInfo.setServerTimeZone(res.serverTimeZone)
    elseif (Proto.Error.ERROR_QUEUE == res.code) then
        print("正在排队，前面人数为"..res.num)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_LOGIN_ACK)
    return res.code

end

function LoginProcess.onMC_AppointNickName_Ack(msg)
	
    local res = Proto.parseP_MC_AppointNickName_Ack(msg)
    MsgPrinter.rcvMsg(res, "MC_AppointNickName_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.MC_APPOINTNICKNAME_ACK)
    return res.code
	
end

function LoginProcess.onMC_CreateChar_Ack(msg)

    local res = Proto.parseP_MC_CreateChar_Ack(msg)
    MsgPrinter.rcvMsg(res, "MC_CreateChar_Ack")
    GenInfo.onMC_CreateChar_Ack(res)
    if (Proto.Error.ERROR_OK == res.code.value) then
        local GenInfo = require("src.Data.GenInfo")
        local loginInfo = getLoginInfo()
        setLoginInfo(res.charID,loginInfo.userToken)
        GameLogMgr.OnGameStateChange(GameLogMgr.UserGameState.STATE_CREATECHAR)
        
        if device.platform == "ios" then
            iOSFunction.AdTrackingOnCreateRole({name=CharInfo.getNickName()})
        end

        if device.platform == "android" then 
            AndroidFunction.AdTrackingOnCreateRole({name=CharInfo.getNickName()})
        end
    end
    CallbackMgr.doCallFunc(res.code.value, Proto.Command.MC_CREATECHAR_ACK)
    return res.code
	
end

function LoginProcess.onMC_SelectChar_Ack(msg)

    local res = Proto.parseP_MC_SelectChar_Ack(msg)
    MsgPrinter.rcvMsg(res, "MC_SelectChar_Ack")
    print("select character result:"..res.code)
    if (Proto.Error.ERROR_OK == res.code) then
        CharInfo.set(res.baseInfo)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.MC_SELECTCHAR_ACK)
    return res.code

end

function LoginProcess.onMC_GetUserIDFromNick_Ack(msg)

    local res = Proto.parseP_MC_GetUserIDFromNick_Ack(msg)
    MsgPrinter.rcvMsg(res, "MC_GetUserIDFromNick_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.MC_GETUSERIDFROMNICK_ACK)
    return res.code
	
end

function LoginProcess.onJC_login_Ack(msg)

    local res = Proto.parseP_JC_login_Ack(msg)
    MsgPrinter.rcvMsg(res, "JC_login_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.JC_LOGIN_ACK)
    return res.code

end

function LoginProcess.onGC_LoginSNS_Ack(msg)

    local res = Proto.parseP_GC_LoginSNS_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_LoginSNS_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_LOGINSNS_ACK)
    return res.code

end

function LoginProcess.onMC_ReLoginCharacter_Ack(msg)

    local res = Proto.parseP_MC_ReLoginCharacter_Ack(msg)
    MsgPrinter.rcvMsg(res, "MC_ReLoginCharacter_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.MC_RELOGINCHARACTER_ACK)
    return res.code

end

function LoginProcess.onGC_CharacterValuesUpdate_Ntf(msg)

    local res = Proto.parseP_GC_CharacterValuesUpdate_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_CharacterValuesUpdate_Ntf")
    CharInfo.update(res.jsCode)
    return res.code

end

function LoginProcess.onGC_GetServerTime_Ack(msg)

    local res = Proto.parseP_GC_GetServerTime_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetServerTime_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        CharInfo.setServerTime(res.serverTime)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETSERVERTIME_ACK)
    return res.code

end

function LoginProcess.onMC_ChangeInfo_Ack(msg)

    local res = Proto.parseP_MC_ChangeInfo_Ack(msg)
    MsgPrinter.rcvMsg(res, "MC_ChangeInfo_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.MC_CHANGEINFO_ACK)
    return res.code

end

function LoginProcess.onMC_ReadInfo_Ack(msg)

    local res = Proto.parseP_MC_ReadInfo_Ack(msg)
    MsgPrinter.rcvMsg(res, "MC_ReadInfo_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        CharInfo.setCurReadContent(res.content)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.MC_READINFO_ACK)
    return res.code

end

function LoginProcess.onGC_GetCharacterValues_Ack(msg)

    local res = Proto.parseP_GC_GetCharacterValues_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetCharacterValues_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("GC_GetCharacterValues_Ack js:", res.js)
        CharInfo.update(res.js)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETCHARACTERVALUES_ACK)
    return res.code

end

function LoginProcess.onMC_KickChar_Ack(msg)

    local res = Proto.parseP_MC_KickChar_Ack(msg)
    MsgPrinter.rcvMsg(res, "MC_KickChar_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    print("MC_KickChar_Ack result", res.code)
    CallbackMgr.doCallFunc(res.code, Proto.Command.MC_KICKCHAR_ACK)
    return res.code

end

function LoginProcess.onGC_CloseClient_Ntf(msg)

    local res = Proto.parseP_GC_CloseClient_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_CloseClient_Ntf")
    
    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "login27", function()
        LoginViewMgr.gameReInit()
    end)
    NetInterface.isClientClosed = true
    
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CLOSECLIENT_NTF)
    return res.code

end

function LoginProcess.onGC_DeviceLogin_Ack(msg)

    local res = Proto.parseP_GC_DeviceLogin_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_DeviceLogin_Ack")
    if (Proto.Error.ERROR_OK ~= res.code.value) then
        CallbackMgr.doCallFunc(res.code.value, Proto.Command.GC_DEVICELOGIN_ACK)
        --DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "device login failed "..res.code.file..":"..res.code.line)
        DialogBoxMgr.showTopDialogBox(SceneMgr.getRunningScene, 1, "device login failed:"..res.code.value, function()
            LoginViewMgr.gameReInit()
        end,nil,nil,false)
        return
    end
     
    local data = {}
    data.code = Proto.Error.ERROR_OK 
    data.chars = {}
    if 0 ~= res.roleID then
        data.chars[1] = {
            characterID = res.roleID,
            userID = res.roleID
        }
        token = res.userToken
        print("characterID:",res.roleID,"token:",res.userToken,"baseInfo:",res.baseInfo)
        CharInfo.set(res.baseInfo)
    end
    setLoginInfo(res.roleID,res.userToken)
    GenInfo.onGC_Login_Ack(data)
    --print("character id:"..tostring(res.roleID))
    --print("character count:"..GenInfo.getCharCount())
    CharInfo.setServerTime(res.serverTime)
    CharInfo.setServerTimeZone(res.serverTimeZone)
    CallbackMgr.doCallFunc(res.code.value, Proto.Command.GC_DEVICELOGIN_ACK)
    GameLogMgr.OnGameStateChange(GameLogMgr.UserGameState.STATE_LOGIN)
    if device.platform == "ios" then iOSFunction.AdTrackingOnLogin({account=res.roleID}) end
    if device.platform == "android" then AndroidFunction.AdTrackingOnLogin({account=res.roleID}) end
    return res.code
end

function LoginProcess.onGC_DeviceRelogin_Ack(msg)

    local res = Proto.parseP_GC_DeviceRelogin_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_DeviceRelogin_Ack")
    print("device relogin result:",res.code.value)
    if (Proto.Error.ERROR_OK == res.code.value) then
    end
    CallbackMgr.doCallFunc(res.code.value, Proto.Command.GC_DEVICERELOGIN_ACK)
    return res.code.value

end

function LoginProcess.onGC_BuyPower_Ack(msg)

    local res = Proto.parseP_GC_BuyPower_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_BuyPower_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("GC_BuyPower_Ack success!")
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_BUYPOWER_ACK)
    return res.code

end

function LoginProcess.onGC_BuyGCash_Ack(msg)

    local res = Proto.parseP_GC_BuyGCash_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_BuyGCash_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        local cjson = require("cjson")
        local rate = cjson.decode(res.rate)
        ExchangeViewMgr.setGCashRate(rate)
        PetEducationMgr.refreshGCash()
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_BUYGCASH_ACK)
    return res.code

end

function LoginProcess.onGC_SetCharSign_Ack(msg)

    local res = Proto.parseP_GC_SetCharSign_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_SetCharSign_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("SetCharSign success!")
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_SETCHARSIGN_ACK)
    return res.code

end

function LoginProcess.onGC_GetCharSign_Ack(msg)

    local res = Proto.parseP_GC_GetCharSign_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetCharSign_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        local label = tostring(res.charSign)
        PersonalCenterMgr.setSignLabel(label)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETCHARSIGN_ACK)
    return res.code

end

function LoginProcess.onGC_ClientInfo_Ack(msg)

    local res = Proto.parseP_GC_ClientInfo_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ClientInfo_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CLIENTINFO_ACK)
    return res.code

end

function LoginProcess.onGC_GetPlayerPointRank_Ack(msg)

    local res = Proto.parseP_GC_GetPlayerPointRank_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetPlayerPointRank_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        for var=1, #res.ranks do
            print("onGC_GetPlayerPointRank_Ack", res.ranks[var])
        end
        ActivityPublicjMgr.setLuotianyiRankInfo(res.ranks)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETPLAYERPOINTRANK_ACK)
    return res.code

end

function LoginProcess.onGC_GetMyPlayerPoint_Ack(msg)

    local res = Proto.parseP_GC_GetMyPlayerPoint_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetMyPlayerPoint_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        ActivityPublicjMgr.setMyRankInfo(res.point, res.rank)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETMYPLAYERPOINT_ACK)
    return res.code

end

function LoginProcess.onGC_CheckUserCode_Ack(msg)

    local res = Proto.parseP_GC_CheckUserCode_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_CheckUserCode_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CHECKUSERCODE_ACK)
    return res.code

end

function LoginProcess.onGC_NewAccountBindOldRoleID_Ack(msg)

    local res = Proto.parseP_GC_NewAccountBindOldRoleID_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_NewAccountBindOldRoleID_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
		if (res.world == 0) then
			TipsMgr.show(nil, "qrcode12")
		else
			local areaName = ""
			local ServerTxt = TxtReader.new("Config/ServerId.txt")
			ServerTxt.init({"id","area"},1,{id=1})
			areaName = ServerTxt.get(res.world).area
			TipsMgr.show(nil, "请去"..areaName.."找回账号")
		end
	else
		TipsMgr.show(nil, "还原失败，请重登再试，如果再失败，请联系客服")
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CHECKUSERCODE_ACK)
    return res.code

end

return LoginProcess
