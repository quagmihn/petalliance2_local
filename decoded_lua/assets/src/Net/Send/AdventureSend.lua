require( "src.Net.Proto.ProtoInclude")

local AdventureSend = {}
local NetMgr = require("src.Net.NetMgr")

function AdventureSend.sendCG_CreateAdventure_Req(params)

    local data = {
        adventureID = params.adventureID
    }
    NetMgr.send(Proto.writeP_CG_CreateAdventure_Req, data)

end

function AdventureSend.sendCG_GetCurrentAdventrue_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetCurrentAdventrue_Req, data)

end

function AdventureSend.sendCG_GetFinishedAdventures_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetFinishedAdventures_Req, data)

end

function AdventureSend.sendCG_GetAdventureAward_Req(params)

    local data = {
        floor = params.floor,
        field = params.field,    --column
        row   = params.row,      --row
    }
    NetMgr.send(Proto.writeP_CG_GetAdventureAward_Req, data)

end

function AdventureSend.sendCG_FinishAdventure_Req(params)

    local data = {
        star = params.star,
    }
    NetMgr.send(Proto.writeP_CG_FinishAdventure_Req, data)

end

function AdventureSend.sendCG_AdventureUseSkill_Req(params)

    local data = {
        objID   = params.objID,
        skillID = params.skillID,
    }
    NetMgr.send(Proto.writeP_CG_AdventureUseSkill_Req, data)

end

function AdventureSend.sendCG_AdventureDamage_Req(params)

    local data = {
        petObjIDs   = params.petObjIDs,
        damageTypes = params.damageTypes,
        damages     = params.damages,
    }
    NetMgr.send(Proto.writeP_CG_AdventureDamage_Req, data)

end

function AdventureSend.sendCG_QuickClearAdventure_Req(params)

    local data = {
        adventureID = params.adventureID,
        clearType   = params.clearType,
        isManyTimes  = params.isManyTimes,
    }
    print("isManyTime",data.isManyTimes)
    NetMgr.send(Proto.writeP_CG_QuickClearAdventure_Req, data)

end

function AdventureSend.sendCG_TriggerNodeEvent_Req(params)

    local data = {
        mapIndex = params.mapid,
        nodeIndex = params.pid,
    }
    NetMgr.send(Proto.writeP_CG_TriggerNodeEvent_Req, data)

end

function AdventureSend.sendCG_GetAllMapRandEvents_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetAllMapRandEvents_Req, data)

end

function AdventureSend.sendCG_GetMyMapNodeEventInfo_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetMyMapNodeEventInfo_Req, data)

end

function AdventureSend.sendCG_FireAdventureEvent_Req(params)

    local data = {
        adventureID = params.adventureID,
        events     = params.events,
    }
    NetMgr.send(Proto.writeP_CG_FireAdventureEvent_Req, data)

end

function AdventureSend.sendCG_RefreshMapNodeEvent_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_RefreshMapNodeEvent_Req, data)

end

function AdventureSend.sendCG_BuyNpcShopGoods_Req(params)

    local data = {
        index = params.index,
    }
    NetMgr.send(Proto.writeP_CG_BuyNpcShopGoods_Req, data)

end

function AdventureSend.sendCG_ResetAdventureTimes_Req(params)

    local data = {
        adventureID = params.adventureID,
    }
    NetMgr.send(Proto.writeP_CG_ResetAdventureTimes_Req, data)

end

function AdventureSend.sendCG_ResetAdventure_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_ResetAdventure_Req, data)

end

function AdventureSend.sendCG_GetMapStarAward_Req(params)

    local data = {
        tID = params.tID,
    }
    NetMgr.send(Proto.writeP_CG_GetMapStarAward_Req, data)

end

function AdventureSend.sendCG_GetAdvAward_Req(params)

    local data = {
        advID = params.advID,
    }
    NetMgr.send(Proto.writeP_CG_GetAdvAward_Req, data)

end

return AdventureSend
