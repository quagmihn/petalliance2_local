require( "src.Net.Proto.ProtoInclude")

local HomeSend = {}
local NetMgr = require("src.Net.NetMgr")

function HomeSend.sendCG_GetHome_Req(params)
    
    local data = {
        charID = params,
    }
    --print("$$$$$$$$$$$sendCG_GetHome_Req data="..sz_T2S(data))
    NetMgr.send(Proto.writeP_CG_GetHome_Req, data)

end

function HomeSend.sendCG_SetHome_Req(params)
    --[[
    if #params.addFurnitures > 0 then
        print("$$$$$$$$$$$sendCG_SetHome_Req addFurnitures="..tostring(params.addFurnitures[1]))
    elseif params.delFurnitureObjID > 0 then
        print("$$$$$$$$$$$sendCG_SetHome_Req delFurnitureObjID="..tostring(params.delFurnitureObjID))
    elseif #params.moveFurnitures > 0 then
        print("$$$$$$$$$$$sendCG_SetHome_Req moveFurnitures="..tostring(params.moveFurnitures[1]))
    end
    ]]--
    local data = {
        homeName = params.homeName,
        addFurnitures = params.addFurnitures,
        delFurnitureObjID = params.delFurnitureObjID,
        moveFurnitures = params.moveFurnitures,
    }
    print("###########sendCG_SetHome_Req data="..sz_T2S(data))
    NetMgr.send(Proto.writeP_CG_SetHome_Req, data)

end

function HomeSend.sendCG_BuyHome_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_BuyHome_Req, data)

end

return HomeSend
