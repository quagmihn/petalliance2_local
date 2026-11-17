require("src.Net.Proto.ProtoInclude")

local NewShopProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")
local ActivitySnatch = require("src.GameMgr.Item.ActivitySnatch")

function NewShopProcess.init()
    NetMgr.addProcess(Proto.Command.GC_GETONEMCASHSHOPLOG_ACK,
        NewShopProcess.onGC_GetOneMCashShopLog_Ack)
    NetMgr.addProcess(Proto.Command.GC_BUYONEMCASHSHOP_ACK,
        NewShopProcess.onGC_BuyOneMCashShop_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETONEMCASHSHOPDETAIL_ACK,
        NewShopProcess.onGC_GetOneMCashShopDetail_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETONEMCASHSHOP_ACK,
        NewShopProcess.onGC_GetOneMCashShop_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETONEMCASHSHOP_NTF,
        NewShopProcess.onGC_GetOneMCashShop_Ntf)
    NetMgr.addProcess(Proto.Command.GC_REDHEARTSHOPREFRESHNTF_NTF,
        NewShopProcess.onGC_RedHeartShopRefreshNTF_Ntf)
    NetMgr.addProcess(Proto.Command.GC_GETMYREDHEARTSHOPINFO_ACK,
        NewShopProcess.onGC_GetMyRedHeartShopInfo_Ack)
    NetMgr.addProcess(Proto.Command.GC_BUYREDHEARTGOODS_ACK,
        NewShopProcess.onGC_BuyRedHeartGoods_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETREDHEARTSHOPINFO_ACK,
        NewShopProcess.onGC_GetRedHeartShopInfo_Ack)

end

function NewShopProcess.onGC_GetRedHeartShopInfo_Ack(msg)

    local res = Proto.parseP_GC_GetRedHeartShopInfo_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetRedHeartShopInfo_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        FriendsViewMgr.SetShop(res.goodsList)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETREDHEARTSHOPINFO_ACK)
    return res.code

end

function NewShopProcess.onGC_BuyRedHeartGoods_Ack(msg)

    local res = Proto.parseP_GC_BuyRedHeartGoods_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_BuyRedHeartGoods_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_BUYREDHEARTGOODS_ACK)
    return res.code

end

function NewShopProcess.onGC_GetMyRedHeartShopInfo_Ack(msg)

    local res = Proto.parseP_GC_GetMyRedHeartShopInfo_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetMyRedHeartShopInfo_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        local cjson = require("cjson")
        local j = cjson.decode(res.data) or {}
        FriendsViewMgr.setRedHeartShopInfo(j)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETMYREDHEARTSHOPINFO_ACK)
    return res.code

end

function NewShopProcess.onGC_RedHeartShopRefreshNTF_Ntf(msg)

    local res = Proto.parseP_GC_RedHeartShopRefreshNTF_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_RedHeartShopRefreshNTF_Ntf")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_REDHEARTSHOPREFRESHNTF_NTF)
    return res.code

end

function NewShopProcess.onGC_GetOneMCashShop_Ntf(msg)

    local res = Proto.parseP_GC_GetOneMCashShop_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_GetOneMCashShop_Ntf")
    if (Proto.Error.ERROR_OK == res.code) then
    end

    for key,var in pairs(res.itemInfos) do
        local cjson = require("cjson")
        local itemInfos = cjson.decode(var)
        print("itemInfos.cjsoncjson.",sz_T2S(itemInfos))   
        ActivitySnatch.insertItems(itemInfos) 
    end
    
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETONEMCASHSHOP_NTF)
    return res.code

end

function NewShopProcess.onGC_GetOneMCashShop_Ack(msg)

    local res = Proto.parseP_GC_GetOneMCashShop_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetOneMCashShop_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("onGC_GetOneMCashShop_Ack.......",res.itemNum)
        ActivitySnatch.setItemsNums(res.itemNum)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETONEMCASHSHOP_ACK)
    return res.code

end

function NewShopProcess.onGC_GetOneMCashShopDetail_Ack(msg)

    local res = Proto.parseP_GC_GetOneMCashShopDetail_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetOneMCashShopDetail_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        local cjson = require("cjson")
        local itemInfo = cjson.decode(res.itemInfo)
        ActivitySnatch.setPlayerList(itemInfo) 
        print("GetOneMCashShopDetail")
        print(sz_T2S(itemInfo))      
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETONEMCASHSHOPDETAIL_ACK)
    return res.code

end

function NewShopProcess.onGC_BuyOneMCashShop_Ack(msg)

    local res = Proto.parseP_GC_BuyOneMCashShop_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_BuyOneMCashShop_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("onGC_BuyOneMCachShop_Ack~~~~~~~~~~~~~~~~~~~~~~~~")
        local cjson = require("cjson")
        local itemInfo = cjson.decode(res.itemInfo)
        ActivitySnatch.refresh(itemInfo)
        print(sz_T2S(itemInfo)) 
    end
    print("onGC_BuyOneMCachShop_Ack~~~~~~~~~~~~~~~1111111~~~~~~~~~")
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_BUYONEMCASHSHOP_ACK)
    return res.code

end

function NewShopProcess.onGC_GetOneMCashShopLog_Ack(msg)

    local res = Proto.parseP_GC_GetOneMCashShopLog_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetOneMCashShopLog_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("GetOneMCashShopLog success!")
        for k,v in pairs(res.wins) do
            ActivitySnatch.update(v)
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETONEMCASHSHOPLOG_ACK)
    return res.code

end

return NewShopProcess
