require( "src.Net.Proto.ProtoInclude")

local WorldBossSend = {}
local NetMgr = require("src.Net.NetMgr")

function WorldBossSend.sendCG_GetWorldBoss_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetWorldBoss_Req, data)

end

function WorldBossSend.sendCG_GetSelfWorldBossData_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetSelfWorldBossData_Req, data)

end

function WorldBossSend.sendCG_AttackBoss_Req(params)

    local data = {
        petObjID = params.petObjID,
        pos = params.pos,
    }
    NetMgr.send(Proto.writeP_CG_AttackBoss_Req, data)

end

function WorldBossSend.sendCG_TakeAward_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_TakeAward_Req, data)

end

function WorldBossSend.sendCG_DiamondRecoverPet_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_DiamondRecoverPet_Req, data)

end

function WorldBossSend.sendCG_DiamondRecoverAll_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_DiamondRecoverAll_Req, data)

end

function WorldBossSend.sendCG_NormalRecover_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_NormalRecover_Req, data)

end

function WorldBossSend.sendCG_BossAttack_Req(params)

    local data = {
        damage = params.damage
    }
    NetMgr.send(Proto.writeP_CG_BossAttack_Req, data)

end

function WorldBossSend.sendCG_GetDamageRank_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetDamageRank_Req, data)

end

function WorldBossSend.sendCG_TakeWeekAward_Req(type)

    local data = {
        type = type,
    }
    NetMgr.send(Proto.writeP_CG_TakeWeekAward_Req, data)

end

function WorldBossSend.sendCG_GetWeekChampionData_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetWeekChampionData_Req, data)

end

function WorldBossSend.sendCG_UpdateMessage_Req(content)

    local data = {
        content = content,
    }
    NetMgr.send(Proto.writeP_CG_UpdateMessage_Req, data)

end

return WorldBossSend
