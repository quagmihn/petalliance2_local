require("src.Net.Proto.ProtoInclude")

local ExploreProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function ExploreProcess.init()
    NetMgr.addProcess(Proto.Command.GC_UPDATEEXPLOREDATA_NTF,
        ExploreProcess.onGC_UpdateExploreData_Ntf)
    NetMgr.addProcess(Proto.Command.GC_BUYEXPLOREPACKET_ACK,
        ExploreProcess.onGC_BuyExplorePacket_Ack)
    NetMgr.addProcess(Proto.Command.GC_UPDATEEXPLOREDIFFCULTDATAS_NTF,
        ExploreProcess.onGC_UpdateExploreDiffcultDatas_Ntf)
    NetMgr.addProcess(Proto.Command.GC_ENDEXPLORE_ACK,
        ExploreProcess.onGC_EndExplore_Ack)
    NetMgr.addProcess(Proto.Command.GC_EXPLORE_ACK,
        ExploreProcess.onGC_Explore_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETEXPLOREDATA_ACK,
        ExploreProcess.onGC_GetExploreData_Ack)

end

function ExploreProcess.onGC_GetExploreData_Ack(msg)

    local res = Proto.parseP_GC_GetExploreData_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetExploreData_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("explore point size:", #res.exploreDatas)
        for var=1, #res.exploreDatas do
            ExploreInfo.update(var, res.exploreDatas[var])
        end
        --ExploreInfo.updateDiffcultDatas(res.exploreDiffcultDatas)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETEXPLOREDATA_ACK)
    return res.code

end

function ExploreProcess.onGC_Explore_Ack(msg)

    local res = Proto.parseP_GC_Explore_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_Explore_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        ExploreInfo.update(res.exploreIndex, res.exploreData)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_EXPLORE_ACK)
    return res.code

end

function ExploreProcess.onGC_EndExplore_Ack(msg)

    local res = Proto.parseP_GC_EndExplore_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_EndExplore_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        ExploreInfo.update(res.exploreIndex, res.exploreData)
        --res.awards
        print("explore awards size:", #res.awards)
        for var=1, #res.awards do
            print("explore awards info:", var, res.awards[var])
        end
        --ExploreInfo.updateDiffcultDatas(res.exploreDiffcultDatas)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_ENDEXPLORE_ACK)
    return res.code

end

function ExploreProcess.onGC_UpdateExploreDiffcultDatas_Ntf(msg)

    local res = Proto.parseP_GC_UpdateExploreDiffcultDatas_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_UpdateExploreDiffcultDatas_Ntf")
    ExploreInfo.updateDiffcultDatas(res.exploreDiffcultDatas)
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_UPDATEEXPLOREDIFFCULTDATAS_NTF)
    return res.code

end

function ExploreProcess.onGC_BuyExplorePacket_Ack(msg)

    local res = Proto.parseP_GC_BuyExplorePacket_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_BuyExplorePacket_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        --res.explorePacketNum
        print("GC_BuyExplorePacket_Ack, packet num:", res.explorePacketNum)
        ExploreInfo.update(nil, res.exploreData)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_BUYEXPLOREPACKET_ACK)
    return res.code

end

function ExploreProcess.onGC_UpdateExploreData_Ntf(msg)

    local res = Proto.parseP_GC_UpdateExploreData_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_UpdateExploreData_Ntf")
    
    ExploreInfo.update(nil, res.exploreData)

    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_UPDATEEXPLOREDATA_NTF)
    return res.code

end

return ExploreProcess
