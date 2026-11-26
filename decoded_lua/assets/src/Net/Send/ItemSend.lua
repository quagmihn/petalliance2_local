require( "src.Net.Proto.ProtoInclude")

local ItemSend = {}
local NetMgr = require("src.Net.NetMgr")

function ItemSend.sendCG_GetItemPacket_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetItemPacket_Req, data)

end

local chestSerial = 0
function ItemSend.sendCG_UseItem_Req(params)

    local data = {
        itemID = params.itemID,
        targetNum = params.targetNum,
        targetStr = params.targetStr,
        useNum = params.useNum,
    }
    if params.chest then
        chestSerial = chestSerial + 1
        data.targetStr = string.format("local:%08x%08x%08x", os.time(), chestSerial, math.random(0, 0x7fffffff))
    end
    NetMgr.send(Proto.writeP_CG_UseItem_Req, data)

end

function ItemSend.sendCG_BuyPacket_Req(type)

    local data = {
        packetType = type,   -- 1 item bag 2 pet bag
    }
    NetMgr.send(Proto.writeP_CG_BuyPacket_Req, data)

end

function ItemSend.sendCG_SellItem_Req(params)

    local data = {
        itemID = params.itemID,
        objID = params.objID,
        num = params.num,
    }
    NetMgr.send(Proto.writeP_CG_SellItem_Req, data)

end

function ItemSend.sendCG_QuerySomeItems_Req(params)

    local data = {
        itemIDs = params.itemIDs
    }
    NetMgr.send(Proto.writeP_CG_QuerySomeItems_Req, data)

end

function ItemSend.sendCG_ChangeName_Req(params)

    local data = {
        nickname = params.nickname
    }
    NetMgr.send(Proto.writeP_CG_ChangeName_Req, data)

end

return ItemSend
