require("src.Net.Proto.ProtoInclude")

local WArenaProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function WArenaProcess.init()
    NetMgr.addProcess(Proto.Command.GC_BUYWARENAFIGHTTIMES_ACK,
        WArenaProcess.onGC_BuyWArenaFightTimes_Ack)
    NetMgr.addProcess(Proto.Command.GC_PLAYWARENARECODE4_NTF,
        WArenaProcess.onGC_PlayWArenaRecode4_Ntf)
    NetMgr.addProcess(Proto.Command.GC_GETWARENARECODE_NTF,
        WArenaProcess.onGC_GetWArenaRecode_Ntf)
    NetMgr.addProcess(Proto.Command.GC_PLAYWARENARECODE3_NTF,
        WArenaProcess.onGC_PlayWArenaRecode3_Ntf)
    NetMgr.addProcess(Proto.Command.GC_PLAYWARENARECODE2_NTF,
        WArenaProcess.onGC_PlayWArenaRecode2_Ntf)
    NetMgr.addProcess(Proto.Command.GC_PLAYWARENARECODE_NTF,
        WArenaProcess.onGC_PlayWArenaRecode_Ntf)
    NetMgr.addProcess(Proto.Command.GC_PLAYWARENARECODE_ACK,
        WArenaProcess.onGC_PlayWArenaRecode_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETWARENARECODE_ACK,
        WArenaProcess.onGC_GetWArenaRecode_Ack)
    NetMgr.addProcess(Proto.Command.GC_QUERYWARENARANK_ACK,
        WArenaProcess.onGC_QueryWArenaRank_Ack)
    NetMgr.addProcess(Proto.Command.GC_RANDOMWARENAENEMYS_ACK,
        WArenaProcess.onGC_RandomWArenaEnemys_Ack)
    NetMgr.addProcess(Proto.Command.GC_WARENARANKFIGHT_ACK,
        WArenaProcess.onGC_WArenaRankFight_Ack)
    NetMgr.addProcess(Proto.Command.GC_JOINWARENA_ACK,
        WArenaProcess.onGC_JoinWArena_Ack)

end

function WArenaProcess.onGC_JoinWArena_Ack(msg)

    local res = Proto.parseP_GC_JoinWArena_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_JoinWArena_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        local WorldPKServerMgr = require("src.GameMgr.Player.WorldPKServerMgr")
        WorldPKServerMgr:setData(res)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_JOINWARENA_ACK)
    return res.code

end

function WArenaProcess.onGC_WArenaRankFight_Ack(msg)

    local res = Proto.parseP_GC_WArenaRankFight_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_WArenaRankFight_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        local WorldPKServerMgr = require("src.GameMgr.Player.WorldPKServerMgr")
        WorldPKServerMgr:setFightInfo(res) 
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_WARENARANKFIGHT_ACK)
    return res.code

end

function WArenaProcess.onGC_RandomWArenaEnemys_Ack(msg)

    local res = Proto.parseP_GC_RandomWArenaEnemys_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_RandomWArenaEnemys_Ack")
    print(Proto.Error.ERROR_OK,res.code)
    if (Proto.Error.ERROR_OK == res.code) then
        local WorldPKServerMgr = require("src.GameMgr.Player.WorldPKServerMgr")
        WorldPKServerMgr:setRandomEnemysInfo(res)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_RANDOMWARENAENEMYS_ACK)
    return res.code

end

function WArenaProcess.onGC_QueryWArenaRank_Ack(msg)

    local res = Proto.parseP_GC_QueryWArenaRank_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_QueryWArenaRank_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        local WorldPKServerMgr = require("src.GameMgr.Player.WorldPKServerMgr")
        WorldPKServerMgr:setRankPlayers(res.soldiers)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_QUERYWARENARANK_ACK)
    return res.code

end

function WArenaProcess.onGC_GetWArenaRecode_Ack(msg)

    local res = Proto.parseP_GC_GetWArenaRecode_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetWArenaRecode_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        local WorldPKServerMgr = require("src.GameMgr.Player.WorldPKServerMgr")
        -- WorldPKServerMgr:setRecordPlayers(res,"GC_GetWArenaRecode_Ack1111")
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETWARENARECODE_ACK)
    return res.code

end

function WArenaProcess.onGC_GetWArenaRecode_Ntf(msg)

    local res = Proto.parseP_GC_GetWArenaRecode_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_GetWArenaRecode_Ntf")
    local WorldPKServerMgr = require("src.GameMgr.Player.WorldPKServerMgr")
    WorldPKServerMgr:setRecordPlayers(res,"GC_GetWArenaRecode_Ntf1111")
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETWARENARECODE_NTF)
    return res.code

end

function WArenaProcess.onGC_PlayWArenaRecode_Ack(msg)

    local res = Proto.parseP_GC_PlayWArenaRecode_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PlayWArenaRecode_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        local WorldPKServerMgr = require("src.GameMgr.Player.WorldPKServerMgr")
        WorldPKServerMgr:setRecordNum(res.recodeNum)
        if res.recodeInfo ~= "" then
            WorldPKServerMgr:addRecordPetInfo2(res.recodeInfo)
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PLAYWARENARECODE_ACK)
    return res.code

end

function WArenaProcess.onGC_PlayWArenaRecode_Ntf(msg)

    local res = Proto.parseP_GC_PlayWArenaRecode_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_PlayWArenaRecode_Ntf")
    local WorldPKServerMgr = require("src.GameMgr.Player.WorldPKServerMgr")
    WorldPKServerMgr:setRecords(res.turnIndex, res.recode)
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PLAYWARENARECODE_NTF)
    return res.code

end

function WArenaProcess.onGC_PlayWArenaRecode2_Ntf(msg)

    local res = Proto.parseP_GC_PlayWArenaRecode2_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_PlayWArenaRecode2_Ntf")
    local WorldPKServerMgr = require("src.GameMgr.Player.WorldPKServerMgr")
    WorldPKServerMgr:addRecordPetInfo(res.recodeInfo)
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PLAYWARENARECODE2_NTF)
    return res.code

end

function WArenaProcess.onGC_PlayWArenaRecode3_Ntf(msg)

    local res = Proto.parseP_GC_PlayWArenaRecode3_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_PlayWArenaRecode3_Ntf")
    local WorldPKServerMgr = require("src.GameMgr.Player.WorldPKServerMgr")
    WorldPKServerMgr:addRecordPetInfo(res.recodeInfo)
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PLAYWARENARECODE3_NTF)
    return res.code

end

function WArenaProcess.onGC_PlayWArenaRecode4_Ntf(msg)

    local res = Proto.parseP_GC_PlayWArenaRecode4_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_PlayWArenaRecode4_Ntf")
    local WorldPKServerMgr = require("src.GameMgr.Player.WorldPKServerMgr")
    WorldPKServerMgr:addRecordPetInfo2(res.recodeInfo)
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PLAYWARENARECODE4_NTF)
    return res.code

end

function WArenaProcess.onGC_BuyWArenaFightTimes_Ack(msg)

    local res = Proto.parseP_GC_BuyWArenaFightTimes_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_BuyWArenaFightTimes_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_BUYWARENAFIGHTTIMES_ACK)
    return res.code

end

return WArenaProcess
