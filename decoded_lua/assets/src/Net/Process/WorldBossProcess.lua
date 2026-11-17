require("src.Net.Proto.ProtoInclude")

local WorldBossProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function WorldBossProcess.init()
    NetMgr.addProcess(Proto.Command.GC_UPDATEMESSAGE_ACK,
        WorldBossProcess.onGC_UpdateMessage_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETWEEKCHAMPIONDATA_ACK,
        WorldBossProcess.onGC_GetWeekChampionData_Ack)
    NetMgr.addProcess(Proto.Command.GC_TAKEWEEKAWARD_ACK,
        WorldBossProcess.onGC_TakeWeekAward_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETDAMAGERANK_ACK,
        WorldBossProcess.onGC_GetDamageRank_Ack)
    NetMgr.addProcess(Proto.Command.GC_CHARSTATECHANGE_NTF,
        WorldBossProcess.onGC_CharStateChange_Ntf)
    NetMgr.addProcess(Proto.Command.GC_BOSSATTACK_ACK,
        WorldBossProcess.onGC_BossAttack_Ack)
    NetMgr.addProcess(Proto.Command.GC_NORMALRECOVER_ACK,
        WorldBossProcess.onGC_NormalRecover_Ack)
    NetMgr.addProcess(Proto.Command.GC_DIAMONDRECOVERALL_ACK,
        WorldBossProcess.onGC_DiamondRecoverAll_Ack)
    NetMgr.addProcess(Proto.Command.GC_DIAMONDRECOVERPET_ACK,
        WorldBossProcess.onGC_DiamondRecoverPet_Ack)
    NetMgr.addProcess(Proto.Command.GC_TAKEAWARD_ACK,
        WorldBossProcess.onGC_TakeAward_Ack)
    NetMgr.addProcess(Proto.Command.GC_ATTACKBOSS_ACK,
        WorldBossProcess.onGC_AttackBoss_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETSELFWORLDBOSSDATA_ACK,
        WorldBossProcess.onGC_GetSelfWorldBossData_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETWORLDBOSS_ACK,
        WorldBossProcess.onGC_GetWorldBoss_Ack)

end

function WorldBossProcess.onGC_GetWorldBoss_Ack(msg)

    local res = Proto.parseP_GC_GetWorldBoss_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetWorldBoss_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        WorldBossInfo.setCurBossInfo(res)
        --[[
        print("########onGC_GetWorldBoss_Ack res=",sz_T2S(res))
        local bossID = WorldBossInfo.getWorldBossInfoByID(res.bossID).model
        local deltaTime = CharInfo.getServerTime() - res.createTime
        local remainTime = res.duration - (deltaTime > 0 and deltaTime or 0)
        local totalTime = res.duration
        BossMapMgr.addLocalBossMapInfo(1, bossID)
        BossMapMgr.addLocalMembersInfo(CharInfo.getLevel(), CharInfo.getLevel(), res.bossID, remainTime > 0 and remainTime or 0, totalTime)
        BossBattleMgr.start(bossID)
        WorldBossInfo.GetDamageRank()
        ]]
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETWORLDBOSS_ACK)
    return res.code

end

function WorldBossProcess.onGC_GetSelfWorldBossData_Ack(msg)

    local res = Proto.parseP_GC_GetSelfWorldBossData_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetSelfWorldBossData_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        --print("++++++++usedPets=",sz_T2S(res.usedPets))
        local usedPets = res.usedPets or {}
        local damage = res.damage or 0
        local state = res.state or 0
        local actionTime = res.actionTime or 0
        WorldBossInfo.setDamageOwner(damage)
        if actionTime ~= 0 then
            WorldBossInfo.NormalRecover()
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETSELFWORLDBOSSDATA_ACK)
    return res.code

end

function WorldBossProcess.onGC_AttackBoss_Ack(msg)

    local res = Proto.parseP_GC_AttackBoss_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_AttackBoss_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        WorldBossInfo.setDamageFromServer(res.damage)
        BossTopBarMgr.updateOwnerDamage()
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_ATTACKBOSS_ACK)
    return res.code

end

function WorldBossProcess.onGC_TakeAward_Ack(msg)

    local res = Proto.parseP_GC_TakeAward_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_TakeAward_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_TAKEAWARD_ACK)
    return res.code

end

function WorldBossProcess.onGC_DiamondRecoverPet_Ack(msg)

    local res = Proto.parseP_GC_DiamondRecoverPet_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_DiamondRecoverPet_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_DIAMONDRECOVERPET_ACK)
    return res.code

end

function WorldBossProcess.onGC_DiamondRecoverAll_Ack(msg)

    local res = Proto.parseP_GC_DiamondRecoverAll_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_DiamondRecoverAll_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_DIAMONDRECOVERALL_ACK)
    return res.code

end

function WorldBossProcess.onGC_NormalRecover_Ack(msg)

    local res = Proto.parseP_GC_NormalRecover_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_NormalRecover_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_NORMALRECOVER_ACK)
    return res.code

end

function WorldBossProcess.onGC_BossAttack_Ack(msg)

    local res = Proto.parseP_GC_BossAttack_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_BossAttack_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_BOSSATTACK_ACK)
    return res.code

end

function WorldBossProcess.onGC_CharStateChange_Ntf(msg)

    local res = Proto.parseP_GC_CharStateChange_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_CharStateChange_Ntf")
    print("###########onGC_CharStateChange_Ntf res="..sz_T2S(res))
    if res.state == 0 then
        BossTopBarMgr.stopTickBallProgress()
        BossMapMgr.setPlayerHp(CharInfo.getCharID(), 0)
        BossMapMgr.changePlayerCurrentState(CharInfo.getCharID(), false)
        BossFailedMgr.show(SceneMgr.getRunningScene, SystemInfo.getGlobalConfigAddInfoByID(81).values[1], "worldboss1", "worldboss2")
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CHARSTATECHANGE_NTF)
    return res.code

end

function WorldBossProcess.onGC_GetDamageRank_Ack(msg)

    local res = Proto.parseP_GC_GetDamageRank_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetDamageRank_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("########onGC_GetDamageRank_Ack res=",sz_T2S(res))
        BossTopBarMgr.updateRank(res.damageRank)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETDAMAGERANK_ACK)
    return res.code

end

function WorldBossProcess.onGC_TakeWeekAward_Ack(msg)

    local res = Proto.parseP_GC_TakeWeekAward_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_TakeWeekAward_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        AwardsListMgr.show(SceneMgr.getRunningScene, res.award)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_TAKEWEEKAWARD_ACK)
    return res.code

end

function WorldBossProcess.onGC_GetWeekChampionData_Ack(msg)

    local res = Proto.parseP_GC_GetWeekChampionData_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetWeekChampionData_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        WorldBossInfo.setWeekChampionData(res)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETWEEKCHAMPIONDATA_ACK)
    return res.code

end

function WorldBossProcess.onGC_UpdateMessage_Ack(msg)

    local res = Proto.parseP_GC_UpdateMessage_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_UpdateMessage_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_UPDATEMESSAGE_ACK)
    return res.code

end

return WorldBossProcess
