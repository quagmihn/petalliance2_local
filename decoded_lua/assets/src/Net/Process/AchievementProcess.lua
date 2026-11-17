require("src.Net.Proto.ProtoInclude")

local AchievementProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function AchievementProcess.init()
    NetMgr.addProcess(Proto.Command.GC_RESETACHIEVEMENT_ACK,
        AchievementProcess.onGC_ResetAchievement_Ack)
    NetMgr.addProcess(Proto.Command.GC_BUYPOTENTIAL_ACK,
        AchievementProcess.onGC_BuyPotential_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETPOTENTIALS_ACK,
        AchievementProcess.onGC_GetPotentials_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETPOKEMONACHIEVEMENTS_ACK,
        AchievementProcess.onGC_GetPokemonAchievements_Ack)
    NetMgr.addProcess(Proto.Command.GC_FINISHPOKEMONACHIEVEMENT_ACK,
        AchievementProcess.onGC_FinishPokemonAchievement_Ack)
    NetMgr.addProcess(Proto.Command.GC_FINISHACHIEVEMENT_ACK,
        AchievementProcess.onGC_FinishAchievement_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETACHIEVEMENTS_ACK,
        AchievementProcess.onGC_GetAchievements_Ack)

end

function AchievementProcess.onGC_GetAchievements_Ack(msg)

    local res = Proto.parseP_GC_GetAchievements_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetAchievements_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print(res.code)
        AchievementListMgr.setAchievementIDs(res.achievementIDs)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETACHIEVEMENTS_ACK)
    return res.code

end

function AchievementProcess.onGC_FinishAchievement_Ack(msg)

    local res = Proto.parseP_GC_FinishAchievement_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_FinishAchievement_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FINISHACHIEVEMENT_ACK)
    return res.code

end

function AchievementProcess.onGC_FinishPokemonAchievement_Ack(msg)

    local res = Proto.parseP_GC_FinishPokemonAchievement_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_FinishPokemonAchievement_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FINISHPOKEMONACHIEVEMENT_ACK)
    return res.code

end

function AchievementProcess.onGC_GetPokemonAchievements_Ack(msg)

    local res = Proto.parseP_GC_GetPokemonAchievements_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetPokemonAchievements_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        AchievementListMgr.setFinishPetAchieve(res.pokeAchievementIDs or {})
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETPOKEMONACHIEVEMENTS_ACK)
    return res.code

end

function AchievementProcess.onGC_GetPotentials_Ack(msg)

    local res = Proto.parseP_GC_GetPotentials_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetPotentials_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        AchievementListMgr.setFinishSkill(res.potentials or {})
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETPOTENTIALS_ACK)
    return res.code

end

function AchievementProcess.onGC_BuyPotential_Ack(msg)

    local res = Proto.parseP_GC_BuyPotential_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_BuyPotential_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_BUYPOTENTIAL_ACK)
    return res.code

end

function AchievementProcess.onGC_ResetAchievement_Ack(msg)

    local res = Proto.parseP_GC_ResetAchievement_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ResetAchievement_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_RESETACHIEVEMENT_ACK)
    return res.code

end

return AchievementProcess
