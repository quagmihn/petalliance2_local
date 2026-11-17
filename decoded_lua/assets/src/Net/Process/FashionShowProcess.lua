require("src.Net.Proto.ProtoInclude")

local FashionShowProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function FashionShowProcess.init()
    NetMgr.addProcess(Proto.Command.GC_GETLIKELIST_ACK,
        FashionShowProcess.onGC_GetLikeList_Ack)
    NetMgr.addProcess(Proto.Command.GC_LIKEFASHIONSHOW_ACK,
        FashionShowProcess.onGC_LikeFashionShow_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETFASHIONSHOWPEOPERS_ACK,
        FashionShowProcess.onGC_GetFashionShowPeopers_Ack)
    NetMgr.addProcess(Proto.Command.GC_TAKEFASHIONSHOWRANKAWARD_ACK,
        FashionShowProcess.onGC_TakeFashionShowRankAward_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETSINGLEFASHIONSHOW_ACK,
        FashionShowProcess.onGC_GetSingleFashionShow_Ack)
    NetMgr.addProcess(Proto.Command.GC_SAVEFASHIONSHOW_ACK,
        FashionShowProcess.onGC_SaveFashionShow_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETFASHIONSHOWRANK_ACK,
        FashionShowProcess.onGC_GetFashionShowRank_Ack)

end

function FashionShowProcess.onGC_GetFashionShowRank_Ack(msg)

    local res = Proto.parseP_GC_GetFashionShowRank_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetFashionShowRank_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print(res.rankInfo)
        local cjson = require("cjson")
        local rankInfo = cjson.decode(res.rankInfo).rank
        SelectBeautyViewMgr.setWorldRankInfo(rankInfo)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETFASHIONSHOWRANK_ACK)
    return res.code

end

function FashionShowProcess.onGC_SaveFashionShow_Ack(msg)

    local res = Proto.parseP_GC_SaveFashionShow_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_SaveFashionShow_Ack")
    print(res.code)
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_SAVEFASHIONSHOW_ACK)
    return res.code

end

function FashionShowProcess.onGC_GetSingleFashionShow_Ack(msg)

    local res = Proto.parseP_GC_GetSingleFashionShow_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetSingleFashionShow_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        SelectBeautyViewMgr.setFashionShow(res)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETSINGLEFASHIONSHOW_ACK)
    return res.code

end

function FashionShowProcess.onGC_TakeFashionShowRankAward_Ack(msg)

    local res = Proto.parseP_GC_TakeFashionShowRankAward_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_TakeFashionShowRankAward_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_TAKEFASHIONSHOWRANKAWARD_ACK)
    return res.code

end

function FashionShowProcess.onGC_GetFashionShowPeopers_Ack(msg)

    local res = Proto.parseP_GC_GetFashionShowPeopers_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetFashionShowPeopers_Ack")
    print(res.code)
    if (Proto.Error.ERROR_OK == res.code) then
        if not CSResourceMgr.getCsbObj("Player/SelectingView.csb") then
            SelectBeautyViewMgr.showSelecting(res.fashionShow)
        else
            SelectBeautyViewMgr.refreshPeoples(res.fashionShow)
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETFASHIONSHOWPEOPERS_ACK)
    return res.code

end

function FashionShowProcess.onGC_LikeFashionShow_Ack(msg)

    local res = Proto.parseP_GC_LikeFashionShow_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_LikeFashionShow_Ack")
    print(res.code)
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_LIKEFASHIONSHOW_ACK)
    return res.code

end

function FashionShowProcess.onGC_GetLikeList_Ack(msg)

    local res = Proto.parseP_GC_GetLikeList_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetLikeList_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        SelectBeautyViewMgr.setLikeList(res.likeList)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETLIKELIST_ACK)
    return res.code

end

return FashionShowProcess
