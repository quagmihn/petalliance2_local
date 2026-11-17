require("src.Net.Proto.ProtoInclude")

local CommonShopProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function CommonShopProcess.init()
    NetMgr.addProcess(Proto.Command.GC_RESETSHOP_ACK,
        CommonShopProcess.onGC_ResetShop_Ack)
    NetMgr.addProcess(Proto.Command.GC_SYSTEMREFRESHGOODS_ACK,
        CommonShopProcess.onGC_SystemRefreshGoods_Ack)
    NetMgr.addProcess(Proto.Command.GC_REFRESHGOODS_ACK,
        CommonShopProcess.onGC_RefreshGoods_Ack)
    NetMgr.addProcess(Proto.Command.GC_BUYGOODS_ACK,
        CommonShopProcess.onGC_BuyGoods_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETSHOP_ACK,
        CommonShopProcess.onGC_getShop_Ack)

end

function CommonShopProcess.onGC_getShop_Ack(msg)

    local res = Proto.parseP_GC_getShop_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_getShop_Ack")
    print("GC_getShop_Ack",res.code)
    if (Proto.Error.ERROR_OK == res.code) then
        print("reflashCount:",res.shop.reflashCount)
        print("systemReflashTime:",res.shop.systemReflashTime)
        if res.shop then
            if WishCoinShopView.getShop then 
                WishCoinShopView.setWishShopCreateTime(res.shop.systemReflashTime)
                WishCoinShopView.setItemList(res.shop.shopList)
            end
            if ArenaViewMgr.getShop == true or MArenaViewMgr.getShop == true then
                ArenaExchangeMgr.shopItems = res.shop.shopList
                ArenaExchangeMgr.shopResetTime = res.shop.resetTime
                ArenaExchangeMgr.refreshCount = res.shop.reflashCount
                ArenaExchangeMgr.systemReflashTime = res.shop.systemReflashTime
            else
                LtExchangeViewMgr.shopItems = res.shop.shopList
                LtExchangeViewMgr.shopResetTime = res.shop.resetTime
                LtExchangeViewMgr.refreshCount = res.shop.reflashCount
                LtExchangeViewMgr.systemReflashTime = res.shop.systemReflashTime
            end
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETSHOP_ACK)
    return res.code

end

function CommonShopProcess.onGC_BuyGoods_Ack(msg)

    local res = Proto.parseP_GC_BuyGoods_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_BuyGoods_Ack")
    print("GC_BuyGoods_Ack", res.code)
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_BUYGOODS_ACK)
    return res.code

end

function CommonShopProcess.onGC_RefreshGoods_Ack(msg)

    local res = Proto.parseP_GC_RefreshGoods_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_RefreshGoods_Ack")
    print("GC_RefreshGoods_Ack",res.code)
    if (Proto.Error.ERROR_OK == res.code) then
        if res.shopList then
            if ArenaExchangeMgr.resetGoods == true then
                ArenaExchangeMgr.shopItems = res.shopList
            else
                LtExchangeViewMgr.shopItems = res.shopList
            end
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_REFRESHGOODS_ACK)
    return res.code

end

function CommonShopProcess.onGC_SystemRefreshGoods_Ack(msg)

    local res = Proto.parseP_GC_SystemRefreshGoods_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_SystemRefreshGoods_Ack")
    print("GC_SystemRefreshGoods_Ack",res.code)
    if (Proto.Error.ERROR_OK == res.code) then
        if ArenaViewMgr.systemRefresh == true then
            ArenaExchangeMgr.shopItems = res.shopList
        else
            LtExchangeViewMgr.shopItems = res.shopList
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_SYSTEMREFRESHGOODS_ACK)
    return res.code

end

function CommonShopProcess.onGC_ResetShop_Ack(msg)

    local res = Proto.parseP_GC_ResetShop_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ResetShop_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        if ArenaViewMgr.resetShop == true then
            ArenaExchangeMgr.refreshCount = 0
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_RESETSHOP_ACK)
    return res.code

end

return CommonShopProcess
