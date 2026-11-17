require( "src.Net.Proto.ProtoInclude")

local BulletinSend = {}
local NetMgr = require("src.Net.NetMgr")

function BulletinSend.sendCG_ListBulletin_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_ListBulletin_Req, data)

end

function BulletinSend.sendCG_GetBulletin_Req(params)

    local data = {
    	id = params
    }
    NetMgr.send(Proto.writeP_CG_GetBulletin_Req, data)

end

return BulletinSend
