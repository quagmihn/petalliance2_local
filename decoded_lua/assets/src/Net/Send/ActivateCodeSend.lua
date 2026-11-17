require( "src.Net.Proto.ProtoInclude")

local ActivateCodeSend = {}
local NetMgr = require("src.Net.NetMgr")

function ActivateCodeSend.sendCG_UseActivateCode_Req(params)

    local data = {
    	strCode = params.strCode
    }
    NetMgr.send(Proto.writeP_CG_UseActivateCode_Req, data)

end

return ActivateCodeSend
