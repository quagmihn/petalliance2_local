require( "src.Net.Proto.ProtoInclude")

local PortalSend = {}
local NetMgr = require("src.Net.NetMgr")

function PortalSend.sendCG_PlatformLogin_Req(params)
    local data = {
        username = params.username,
        token = params.token
    }
    NetMgr.send(Proto.writeP_CG_PlatformLogin_Req, data)
end

function PortalSend.sendCG_DeviceBind_Req(params)

    local data = {
        id = params.id,
        world = params.world,
        token = params.token
    }
    NetMgr.send(Proto.writeP_CG_DeviceBind_Req, data)

end

return PortalSend
