require("src.Net.Proto.ProtoInclude")

local ItemProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function ItemProcess.init()
    NetMgr.addProcess(Proto.Command.GC_CHANGENAME_ACK,
        ItemProcess.onGC_ChangeName_Ack)
    NetMgr.addProcess(Proto.Command.GC_QUERYSOMEITEMS_ACK,
        ItemProcess.onGC_QuerySomeItems_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETPETPIECEITEMPACKET_NTF,
        ItemProcess.onGC_GetPetPieceItemPacket_Ntf)
    NetMgr.addProcess(Proto.Command.GC_UPDATESKILLITEMS_NTF,
        ItemProcess.onGC_UpdateSkillItems_Ntf)
    NetMgr.addProcess(Proto.Command.GC_SELLITEM_ACK,
        ItemProcess.onGC_SellItem_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETSKILLITEMPACKET_NTF,
        ItemProcess.onGC_GetSkillItemPacket_Ntf)
    NetMgr.addProcess(Proto.Command.GC_GETFURNITUREPACKET_NTF,
        ItemProcess.onGC_GetFurniturePacket_Ntf)
    NetMgr.addProcess(Proto.Command.GC_UPDATEFURNITURES_NTF,
        ItemProcess.onGC_UpdateFurnitures_Ntf)
    NetMgr.addProcess(Proto.Command.GC_BUYPACKET_ACK,
        ItemProcess.onGC_BuyPacket_Ack)
    NetMgr.addProcess(Proto.Command.GC_USEITEM_ACK,
        ItemProcess.onGC_UseItem_Ack)
    NetMgr.addProcess(Proto.Command.GC_UPDATEITEMS_NTF,
        ItemProcess.onGC_UpdateItems_Ntf)
    NetMgr.addProcess(Proto.Command.GC_GETITEMPACKET_NTF,
        ItemProcess.onGC_GetItemPacket_Ntf)
    NetMgr.addProcess(Proto.Command.GC_GETITEMPACKET_ACK,
        ItemProcess.onGC_GetItemPacket_Ack)

end

function ItemProcess.onGC_GetItemPacket_Ack(msg)

    local res = Proto.parseP_GC_GetItemPacket_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetItemPacket_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("ItemProcess: item all num", res.itemNum)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETITEMPACKET_ACK)
    return res.code

end

function ItemProcess.onGC_GetItemPacket_Ntf(msg)

    local res = Proto.parseP_GC_GetItemPacket_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_GetItemPacket_Ntf")
    --[[
    for var=1, #res.items do
        print("ItemProcess: GetItemPacket", res.items[var])
    end]]
    ItemInfo.updateCharItemInfo(res.items)
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETITEMPACKET_NTF)
    return res.code

end

function ItemProcess.onGC_UpdateItems_Ntf(msg)

    local res = Proto.parseP_GC_UpdateItems_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_UpdateItems_Ntf")
    local itemBag = {}
    local skillBag = {}
    PetFreeListMgr.addAwardsItem(res.items)
    for var=1, #res.items do
        print("ItemProcess: UpdateItem", res.items[var])
        local cjson = require("cjson")
        local tbl = cjson.decode(res.items[var])
        local itemInfo = ItemInfo.getItemInfoById(tonumber(tbl.itemID))
        if itemInfo.itemType == 1 then
            table.insert(skillBag,res.items[var])
        else
            table.insert(itemBag,res.items[var])
        end
    end
    ItemInfo.updateCharItemInfo(itemBag, true)
    ItemInfo.updateCharSkillBookInfo(skillBag, true)

    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_UPDATEITEMS_NTF)
    return res.code

end

function ItemProcess.onGC_UseItem_Ack(msg)

    local res = Proto.parseP_GC_UseItem_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_UseItem_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("ItemProcess: UseItem", res.itemID, res.itemNum)
        ItemInfo.useItemCallback(res.itemID, res.itemNum)
        if res.awards then
            TreeInfoView.showAwards(res.awards)
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_USEITEM_ACK)
    return res.code

end

function ItemProcess.onGC_BuyPacket_Ack(msg)

    local res = Proto.parseP_GC_BuyPacket_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_BuyPacket_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("BuyPacket success.")
        if res.packetType==1 then
            CharInfo.set({itempacketnum=res.num})
        elseif res.packetType==2 then
            CharInfo.set({petpacketnum=res.num})
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_BUYPACKET_ACK)
    return res.code

end

function ItemProcess.onGC_UpdateFurnitures_Ntf(msg)

    local res = Proto.parseP_GC_UpdateFurnitures_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_UpdateFurnitures_Ntf")
    
    ItemInfo.updateCharFurnitureInfo(res.furnitures, true)
    
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_UPDATEFURNITURES_NTF)
    return res.code

end

function ItemProcess.onGC_GetFurniturePacket_Ntf(msg)

    local res = Proto.parseP_GC_GetFurniturePacket_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_GetFurniturePacket_Ntf")
    
    ItemInfo.updateCharFurnitureInfo(res.furnitures)
    
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETFURNITUREPACKET_NTF)
    return res.code

end

function ItemProcess.onGC_GetSkillItemPacket_Ntf(msg)

    local res = Proto.parseP_GC_GetSkillItemPacket_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_GetSkillItemPacket_Ntf")

    ItemInfo.updateCharSkillBookInfo(res.skillItems)

    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETSKILLITEMPACKET_NTF)
    return res.code

end

function ItemProcess.onGC_SellItem_Ack(msg)

    local res = Proto.parseP_GC_SellItem_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_SellItem_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_SELLITEM_ACK)
    return res.code

end

function ItemProcess.onGC_UpdateSkillItems_Ntf(msg)

    local res = Proto.parseP_GC_UpdateSkillItems_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_UpdateSkillItems_Ntf")
    ItemInfo.updateCharSkillBookInfo(res.skillItems)
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_UPDATESKILLITEMS_NTF)
    return res.code

end

function ItemProcess.onGC_GetPetPieceItemPacket_Ntf(msg)

    local res = Proto.parseP_GC_GetPetPieceItemPacket_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_GetPetPieceItemPacket_Ntf")

    BagViewMgr.addPetPiece(res.petPieceItems)

    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETPETPIECEITEMPACKET_NTF)
    return res.code

end

function ItemProcess.onGC_QuerySomeItems_Ack(msg)

    local res = Proto.parseP_GC_QuerySomeItems_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_QuerySomeItems_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        local itemBag = {}
        local skillBag = {}
        for var = 1 ,#res.itemIDs do
             local itemInfo = ItemInfo.getItemInfoById(tonumber(res.itemIDs[var]))
             local tmpDataTbl = {}
             tmpDataTbl.itemID = res.itemIDs[var]
             tmpDataTbl.num = res.nums[var]
             if itemInfo.itemType == 1 then
                table.insert(skillBag,tmpDataTbl)
             else
                table.insert(itemBag,tmpDataTbl)
            end           
        end
        
        ItemInfo.updateCharSkillBookInfoById(skillBag)
        ItemInfo.updateCharItemInfobyItemId(itemBag)
    end


    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_QUERYSOMEITEMS_ACK)
    return res.code

end

function ItemProcess.onGC_ChangeName_Ack(msg)

    local res = Proto.parseP_GC_ChangeName_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ChangeName_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CHANGENAME_ACK)
    return res.code

end

return ItemProcess
