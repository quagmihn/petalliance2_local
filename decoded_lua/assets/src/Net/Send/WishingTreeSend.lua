require( "src.Net.Proto.ProtoInclude")

local WishingTreeSend = {}
local NetMgr = require("src.Net.NetMgr")

function WishingTreeSend.sendCG_GetWishingTreesData_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetWishingTreesData_Req, data)

end

function WishingTreeSend.sendCG_PrayToTree_Req(params)

    local data = {
    	treeID = params.treeID
    }
    NetMgr.send(Proto.writeP_CG_PrayToTree_Req, data)

end

return WishingTreeSend
