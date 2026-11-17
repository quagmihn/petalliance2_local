-- Net.Proto.Proto_Signin

function Proto.writeP_CG_LoadSigninData_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_LOADSIGNINDATA_REQ);
end

function Proto.parseP_GC_LoadSigninData_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_LOADSIGNINDATA_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	data.signinData=Proto.parseString(entry); -- 签到数据
	return data;
end

function Proto.parseP_GC_SigninData_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_SIGNINDATA_NTF;
	data.signinData=Proto.parseString(entry); -- 签到数据
	return data;
end

function Proto.writeP_CG_Signin_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_SIGNIN_REQ);
end

function Proto.parseP_GC_Signin_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_SIGNIN_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code==Proto.Error.ERROR_OK) then
		data.signinData=Proto.parseString(entry); -- 签到数据
	end
	return data;
end

function Proto.writeP_CG_SigninRepair_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_SIGNINREPAIR_REQ);
	Proto.writeBYTE(msg,data.day); -- 需要补签的日期
end

function Proto.parseP_GC_SigninRepair_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_SIGNINREPAIR_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code==Proto.Error.ERROR_OK) then
		data.signinData=Proto.parseString(entry); -- 签到数据
	end
	return data;
end

