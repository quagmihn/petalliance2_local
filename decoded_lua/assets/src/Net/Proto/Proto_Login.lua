-- Net.Proto.Proto_Login

function Proto.writeP_CG_GetLoginValidate_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETLOGINVALIDATE_REQ);
	Proto.writeBYTE(msg,data.temp); -- 无作用
end

function Proto.parseP_GC_GetLoginValidate_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETLOGINVALIDATE_ACK;
	data.pic=Proto.parseValidatePicBuff(entry); -- 验证码图片buffer
	return data;
end

function Proto.writeP_CG_Login_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_LOGIN_REQ);
	Proto.writeUserName(msg,data.username); -- 用户名
	Proto.writePassWord(msg,data.password); -- 密码
	Proto.writeCharacterID(msg,data.userID); -- 玩家ID
end

function Proto.parseP_GC_Login_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_LOGIN_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.chars=Proto.parseVector(entry,Proto.parseCharBriefInfo); -- 玩家列表
		data.serverTime=Proto.parseQWORD(entry); -- 
		data.serverTimeZone=Proto.parsefloat(entry); -- 时区秒数 (例 +8时区为8*3600) 
	end
	if ((data.code+0)==Proto.Error.ERROR_QUEUE) then
		data.num=Proto.parseDWORD(entry); -- 排在第几位
	end
	return data;
end

function Proto.writeP_CG_NewAccountBindOldRoleID_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_NEWACCOUNTBINDOLDROLEID_REQ);
	Proto.writeString(msg,data.QRCode); -- 角色二维码
end

function Proto.parseP_GC_NewAccountBindOldRoleID_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_NEWACCOUNTBINDOLDROLEID_ACK;
	data.code=Proto.parseWORD(entry); -- 
	data.world=Proto.parseDWORD(entry); -- 
	return data;
end

function Proto.writeP_CG_GetCountries_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETCOUNTRIES_REQ);
end

function Proto.parseP_GC_GetCountries_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETCOUNTRIES_ACK;
	data.countries=Proto.parseVector(entry,Proto.parseCountryID); -- 可选择的国家
	return data;
end

function Proto.writeP_CM_CreateChar_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CM_CREATECHAR_REQ);
	Proto.writeNickName(msg,data.nickname); -- 玩家昵称
	Proto.writeBYTE(msg,data.gender); -- 玩家性别(0:女,1:男)
	Proto.writeBYTE(msg,data.country); -- 国家
	Proto.writeBYTE(msg,data.cullPet); -- 宠物蛋编号
	Proto.writeBYTE(msg,data.iconID); -- 头像编号
	Proto.writeint(msg,data.world); -- 所在世界
	Proto.writeString(msg,data.spreader); -- 推广员编号
	Proto.writeVector(msg,data.initFashionInfos,Proto.writeDWORD); -- 初始服装
end

function Proto.parseP_MC_CreateChar_Ack(entry)
	local data={};
	data.msgID=Proto.Command.MC_CREATECHAR_ACK;
	data.code=Proto.parseCode(entry); -- 返回码
	if (data.code.value==Proto.Error.ERROR_OK) then
		data.charID=Proto.parseCharacterID(entry); -- 玩家ID
		data.baseInfo=Proto.parseCharBaseInfo(entry); -- 基本信息
	end
	return data;
end

function Proto.parseP_GC_SNSServerStatus_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_SNSSERVERSTATUS_NTF;
	data.status=Proto.parseBYTE(entry); -- 当前状态
	return data;
end

function Proto.writeP_CG_LoginSNS_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_LOGINSNS_REQ);
end

function Proto.parseP_GC_LoginSNS_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_LOGINSNS_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.parseP_GC_CloseClient_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_CLOSECLIENT_NTF;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.parseP_MC_QueueNum_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.MC_QUEUENUM_NTF;
	data.num=Proto.parseDWORD(entry); -- 前方排队人数
	return data;
end

function Proto.writeP_CM_GetUserNickFromID_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CM_GETUSERNICKFROMID_REQ);
	Proto.writeUserID(msg,data.roleID); -- 玩家ID
end

function Proto.parseP_MC_GetUserNickFromID_Ack(entry)
	local data={};
	data.msgID=Proto.Command.MC_GETUSERNICKFROMID_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.nickname=Proto.parseNickName(entry); -- 玩家昵称
	end
	return data;
end

function Proto.writeP_CM_GetUserIDFromNick_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CM_GETUSERIDFROMNICK_REQ);
	Proto.writeNickName(msg,data.nickname); -- 玩家昵称
end

function Proto.parseP_MC_GetUserIDFromNick_Ack(entry)
	local data={};
	data.msgID=Proto.Command.MC_GETUSERIDFROMNICK_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.roleID=Proto.parseUserID(entry); -- 玩家ID
	end
	return data;
end

function Proto.writeP_CM_ResetClientFlag_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CM_RESETCLIENTFLAG_REQ);
	Proto.writeDWORD(msg,data.flag); -- 客户端标志
end

function Proto.parseP_MC_ResetClientFlag_Ack(entry)
	local data={};
	data.msgID=Proto.Command.MC_RESETCLIENTFLAG_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.parseP_MC_SystemSetting_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.MC_SYSTEMSETTING_NTF;
	data.seasonTime=Proto.parseDWORD(entry); -- 一个季节所占的秒数
	return data;
end

function Proto.parseP_GC_IndulgeClean_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_INDULGECLEAN_NTF;
	return data;
end

function Proto.parseP_GC_IndulgeThree_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_INDULGETHREE_NTF;
	return data;
end

function Proto.parseP_GC_IndulgeFive_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_INDULGEFIVE_NTF;
	return data;
end

function Proto.parseP_GC_QuitZone_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_QUITZONE_NTF;
	return data;
end

function Proto.writeP_CZ_TestServerSpeed_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_TESTSERVERSPEED_REQ);
	Proto.writeDWORD(msg,data.pingID); -- 测试pingid
end

function Proto.parseP_ZC_TestServerSpeed_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_TESTSERVERSPEED_ACK;
	data.pingID=Proto.parseDWORD(entry); -- 测试pingid
	return data;
end

function Proto.parseP_MC_UserBanInfo_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.MC_USERBANINFO_NTF;
	data.unlockTime=Proto.parseTIME_SEC(entry); -- 解封时刻
	data.reason=Proto.parseString(entry); -- 停封原因
	return data;
end

function Proto.parseP_MC_SystemTime_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.MC_SYSTEMTIME_NTF;
	data.time=Proto.parseTIME_SEC(entry); -- 系统时间
	data.timeZone=Proto.parseString(entry); -- 时区
	return data;
end

function Proto.writeP_CM_ChangeStorgePassword_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CM_CHANGESTORGEPASSWORD_REQ);
	Proto.writePassWord(msg,data.oldPassword); -- 旧密码(无密码可为空串)
	Proto.writePassWord(msg,data.newPassword); -- 新密码
end

function Proto.parseP_MC_ChangeStorgePassword_Ack(entry)
	local data={};
	data.msgID=Proto.Command.MC_CHANGESTORGEPASSWORD_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CM_LoginStorgePassword_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CM_LOGINSTORGEPASSWORD_REQ);
	Proto.writePassWord(msg,data.password); -- 密码
end

function Proto.parseP_MC_LoginStorgePassword_Ack(entry)
	local data={};
	data.msgID=Proto.Command.MC_LOGINSTORGEPASSWORD_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CA_GetConfigScript_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CA_GETCONFIGSCRIPT_REQ);
	Proto.writeDWORD(msg,data.index); -- 脚本序列号
end

function Proto.parseP_AC_GetConfigScript_Ack(entry)
	local data={};
	data.msgID=Proto.Command.AC_GETCONFIGSCRIPT_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	data.index=Proto.parseDWORD(entry); -- 脚本序列号
	if (data.code==Proto.Error.ERROR_OK) then
		data.script=Proto.parseString(entry); -- 脚本代码
	end
	return data;
end

function Proto.parseP_AC_GetConfigScriptOver_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.AC_GETCONFIGSCRIPTOVER_NTF;
	data.index=Proto.parseDWORD(entry); -- 脚本序列号
	return data;
end

function Proto.parseP_GC_GetConfigScriptUpdate_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETCONFIGSCRIPTUPDATE_NTF;
	data.index=Proto.parseDWORD(entry); -- 脚本序列号
	return data;
end

function Proto.parseP_MC_UserOnlineTime_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.MC_USERONLINETIME_NTF;
	data.userOnlineTime=Proto.parseDWORD(entry); -- 玩家在线时长
	return data;
end

function Proto.writeP_CM_QueryCharBriefInfo_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CM_QUERYCHARBRIEFINFO_REQ);
	Proto.writeVector(msg,data.users,Proto.writeUserID); -- 玩家列表
end

function Proto.parseP_MC_QueryCharBriefInfo_Ack(entry)
	local data={};
	data.msgID=Proto.Command.MC_QUERYCHARBRIEFINFO_ACK;
	data.users=Proto.parseVector(entry,Proto.parseCharBriefInfo); -- 玩家列表
	return data;
end

function Proto.writeP_CM_KickChar_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CM_KICKCHAR_REQ);
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
end

function Proto.parseP_MC_KickChar_Ack(entry)
	local data={};
	data.msgID=Proto.Command.MC_KICKCHAR_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.parseP_MC_AllowLogin_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.MC_ALLOWLOGIN_NTF;
	return data;
end

function Proto.writeP_CM_AppointNickName_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CM_APPOINTNICKNAME_REQ);
	Proto.writeNickName(msg,data.nickname); -- 昵称
end

function Proto.parseP_MC_AppointNickName_Ack(entry)
	local data={};
	data.msgID=Proto.Command.MC_APPOINTNICKNAME_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.parseP_ZC_Mobility_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.ZC_MOBILITY_NTF;
	data.mobility=Proto.parseWORD(entry); -- 当前行动力
	data.maxMobility=Proto.parseWORD(entry); -- 行动力上线
	return data;
end

function Proto.writeP_CM_RewardCoding_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CM_REWARDCODING_REQ);
	Proto.writeCharacterID(msg,data.charid); -- 玩家编号
	Proto.writeWORD(msg,data.rewardType); -- 奖励编码类型
end

function Proto.parseP_MC_RewardCoding_Ack(entry)
	local data={};
	data.msgID=Proto.Command.MC_REWARDCODING_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.rewardCodingInfo=Proto.parseRewardCodingInfo(entry); -- 奖励code
	end
	return data;
end

function Proto.writeP_CM_ExchangeRewardCoding_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CM_EXCHANGEREWARDCODING_REQ);
	Proto.writeString(msg,data.rewardCode); -- 奖励编码
end

function Proto.parseP_MC_ExchangeRewardCoding_Ack(entry)
	local data={};
	data.msgID=Proto.Command.MC_EXCHANGEREWARDCODING_ACK;
	data.charid=Proto.parseCharacterID(entry); -- 玩家编号
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CJ_login_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CJ_LOGIN_REQ);
end

function Proto.parseP_JC_login_Ack(entry)
	local data={};
	data.msgID=Proto.Command.JC_LOGIN_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CM_RenameCharacterNickname_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CM_RENAMECHARACTERNICKNAME_REQ);
	Proto.writeNickName(msg,data.nickname); -- 昵称
end

function Proto.parseP_MC_RenameCharacterNickname_Ack(entry)
	local data={};
	data.msgID=Proto.Command.MC_RENAMECHARACTERNICKNAME_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.parseP_GC_CharacterValuesUpdate_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_CHARACTERVALUESUPDATE_NTF;
	data.jsCode=Proto.parseString(entry); -- json格式
	return data;
end

function Proto.writeP_CG_SelectPokemon_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_SELECTPOKEMON_REQ);
	Proto.writeDWORD(msg,data.pokemonID); -- 宠物ID
end

function Proto.writeP_CG_SelectPokemon_Ack(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_SELECTPOKEMON_ACK);
	Proto.writeWORD(msg,data.code); -- 
end

function Proto.writeP_CM_ChangeInfo_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CM_CHANGEINFO_REQ);
	Proto.writeDWORD(msg,data.charId); -- 玩家id
	Proto.writeString(msg,data.key); -- 关键字
	Proto.writeString(msg,data.content); -- 内容
end

function Proto.parseP_MC_ChangeInfo_Ack(entry)
	local data={};
	data.msgID=Proto.Command.MC_CHANGEINFO_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CM_ReadInfo_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CM_READINFO_REQ);
	Proto.writeString(msg,data.key); -- 关键字
end

function Proto.parseP_MC_ReadInfo_Ack(entry)
	local data={};
	data.msgID=Proto.Command.MC_READINFO_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	data.content=Proto.parseString(entry); -- 内容
	return data;
end

function Proto.writeP_CG_GetServerTime_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETSERVERTIME_REQ);
end

function Proto.parseP_GC_GetServerTime_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETSERVERTIME_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.serverTime=Proto.parseQWORD(entry); -- 内容
		data.serverTimeZone=Proto.parsefloat(entry); -- 时区秒数 (例 +8时区为8*3600) 
	end
	return data;
end

function Proto.writeP_CG_GetCharacterValues_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETCHARACTERVALUES_REQ);
	Proto.writeVector(msg,data.keys,Proto.writeString); -- 
end

function Proto.parseP_GC_GetCharacterValues_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETCHARACTERVALUES_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.js=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_ClientInfo_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CLIENTINFO_REQ);
	Proto.writeString(msg,data.ip); -- Ipv4地址
	Proto.writeString(msg,data.device_model); -- 设备型号
	Proto.writeString(msg,data.os_name); -- 操作系统
	Proto.writeString(msg,data.os_ver); -- 操作系统版本
	Proto.writeString(msg,data.mac_addr); -- 设备mac地址
	Proto.writeString(msg,data.udid); -- 设备唯一标示符
	Proto.writeString(msg,data.app_channel); -- 运营渠道
	Proto.writeString(msg,data.app_ver); -- 客户端版本号
	Proto.writeString(msg,data.network); -- 网络连接
	Proto.writeString(msg,data.device_screen); -- 屏幕高度X宽度 如100X80
	Proto.writeString(msg,data.platform_tag); -- 发行平台标记
	Proto.writeDWORD(msg,data.group_id); -- 操作系统ID
	Proto.writeDWORD(msg,data.channel_id); -- 运营渠道ID
end

function Proto.parseP_GC_ClientInfo_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CLIENTINFO_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_HaveDinner_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_HAVEDINNER_REQ);
end

function Proto.parseP_GC_HaveDinner_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_HAVEDINNER_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.js=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_GetReloginKey_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETRELOGINKEY_REQ);
end

function Proto.parseP_GC_GetReloginKey_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETRELOGINKEY_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.js=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_BuyPower_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_BUYPOWER_REQ);
end

function Proto.parseP_GC_BuyPower_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_BUYPOWER_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_BuyGCash_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_BUYGCASH_REQ);
end

function Proto.parseP_GC_BuyGCash_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_BUYGCASH_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.rate=Proto.parseWORD(entry); -- 倍率
	end
	return data;
end

function Proto.writeP_CG_SetCharSign_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_SETCHARSIGN_REQ);
	Proto.writeString(msg,data.charSign); -- 签名
end

function Proto.parseP_GC_SetCharSign_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_SETCHARSIGN_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_GetCharSign_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETCHARSIGN_REQ);
end

function Proto.parseP_GC_GetCharSign_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETCHARSIGN_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.charSign=Proto.parseString(entry); -- 签名
	end
	return data;
end

function Proto.writeP_CG_SetCountry_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_SETCOUNTRY_REQ);
	Proto.writeDWORD(msg,data.country); -- 国家信息ID
end

function Proto.parseP_GC_SetCountry_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_SETCOUNTRY_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_GetPlayerPointRank_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETPLAYERPOINTRANK_REQ);
	Proto.writeDWORD(msg,data.rankMin); -- 
	Proto.writeDWORD(msg,data.rankMax); -- 
end

function Proto.parseP_GC_GetPlayerPointRank_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETPLAYERPOINTRANK_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.ranks=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

function Proto.writeP_CG_GetMyPlayerPoint_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETMYPLAYERPOINT_REQ);
end

function Proto.parseP_GC_GetMyPlayerPoint_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETMYPLAYERPOINT_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.point=Proto.parseDWORD(entry); -- 
		data.rank=Proto.parseDWORD(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_CheckUserCode_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CHECKUSERCODE_REQ);
	Proto.writeString(msg,data.code); -- 
end

function Proto.parseP_GC_CheckUserCode_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CHECKUSERCODE_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_PasswordGift_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_PASSWORDGIFT_REQ);
	Proto.writeString(msg,data.password); -- 
	Proto.writeDWORD(msg,data.useMCash); -- 
end

function Proto.parseP_GC_PasswordGift_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_PASSWORDGIFT_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.passwordProducts=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_BuyPasswordProduct_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_BUYPASSWORDPRODUCT_REQ);
	Proto.writeDWORD(msg,data.productID); -- 
end

function Proto.parseP_GC_BuyPasswordProduct_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_BUYPASSWORDPRODUCT_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.passwordProducts=Proto.parseString(entry); -- 
	end
	return data;
end

