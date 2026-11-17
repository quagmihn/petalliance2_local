require( "src.Net.Proto.ProtoInclude")

local SigninSend = {}
local NetMgr = require("src.Net.NetMgr")

function SigninSend.sendCG_LoadSigninData_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_LoadSigninData_Req, data)

end

function SigninSend.sendCG_Signin_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_Signin_Req, data)

end

function SigninSend.sendCG_SigninRepair_Req(params)

    local data = {
    	day = params,
    }
    NetMgr.send(Proto.writeP_CG_SigninRepair_Req, data)

end

return SigninSend
