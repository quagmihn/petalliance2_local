require( "src.Net.Proto.ProtoInclude")

local OrderManSend = {}
local NetMgr = require("src.Net.NetMgr")

function OrderManSend.sendCG_PasswordGift_Req(params)

    local data = {
    	password = params.password,
    	useMCash = params.useMCash,
    }
    NetMgr.send(Proto.writeP_CG_PasswordGift_Req, data)

end

function OrderManSend.sendCG_BuyPasswordProduct_Req(params)

    local data = {
    	productID = params.productID
    }
    NetMgr.send(Proto.writeP_CG_BuyPasswordProduct_Req, data)

end

return OrderManSend
