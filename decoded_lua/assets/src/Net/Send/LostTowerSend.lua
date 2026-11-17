require( "src.Net.Proto.ProtoInclude")

local LostTowerSend = {}
local NetMgr = require("src.Net.NetMgr")

function LostTowerSend.sendCG_GetLostTowerData_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetLostTowerData_Req, data)

end

function LostTowerSend.sendCG_resetData_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_resetData_Req, data)

end

function LostTowerSend.sendCG_moveNewCell_Req(params)

    local data = {
        x = params.x, -- x坐标
        y = params.y, -- y坐标
    }
    NetMgr.send(Proto.writeP_CG_moveNewCell_Req, data)

end

function LostTowerSend.sendCG_ChangeFloor_Req(params)

    local data = {
        floor = params.floor, 
    }
    NetMgr.send(Proto.writeP_CG_ChangeFloor_Req, data)

end

function LostTowerSend.sendCG_fireEventCell_Req(params)

    local data = {
        x = params.x, -- x坐标
        y = params.y, -- y坐标
    }
    NetMgr.send(Proto.writeP_CG_fireEventCell_Req, data)

end

function LostTowerSend.sendCG_changeReadyPet_Req(params)

    local data = {
        activityArmysList = params.activityArmysList,
        activityHelpArmysList = params.activityHelpArmysList,
    }
    NetMgr.send(Proto.writeP_CG_changeReadyPet_Req, data)

end

function LostTowerSend.sendCG_RecoverState_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_RecoverState_Req, data)

end

function LostTowerSend.sendCG_TransferFloor_Req(params)

    local data = {
        floor = params.floor,
    }
    NetMgr.send(Proto.writeP_CG_TransferFloor_Req, data)

end

function LostTowerSend.sendCG_MoveObstacle_Req(params)

    local data = {
        fromPos = params.fromPos,
        toPos   = params.toPos,
    }
    NetMgr.send(Proto.writeP_CG_MoveObstacle_Req, data)

end

function LostTowerSend.sendCG_onTrap_Req(params)

    local data = {
        position = params.position,
    }
    NetMgr.send(Proto.writeP_CG_onTrap_Req, data)

end

function LostTowerSend.sendCG_LostTowerPVPBattleEnd_Req(params)

    local data = {
        isWin = params.isWin,
        battleDetails = params.battleDetails,
    }
    NetMgr.send(Proto.writeP_CG_LostTowerPVPBattleEnd_Req, data)

end

function LostTowerSend.sendCG_QueryFloorRank_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_QueryFloorRank_Req, data)

end

function LostTowerSend.sendCG_QueryPointRank_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_QueryPointRank_Req, data)

end

function LostTowerSend.sendCG_EnterTransferDoor_Req(params)

    local data = {
        x = params.x, -- x坐标
        y = params.y, -- y坐标
    }
    NetMgr.send(Proto.writeP_CG_EnterTransferDoor_Req, data)

end

function LostTowerSend.sendCG_UseLostTowerItem_Req(params)

    local data = {
        itemID = params.itemID
    }
    NetMgr.send(Proto.writeP_CG_UseLostTowerItem_Req, data)

end

function LostTowerSend.sendCG_RecoverStepNumber_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_RecoverStepNumber_Req, data)

end

function LostTowerSend.sendCG_MoneyOpenChest_Req(params)

    local data = {
        x = params.x, -- x坐标
        y = params.y, -- y坐标
    }
    NetMgr.send(Proto.writeP_CG_MoneyOpenChest_Req, data)

end

return LostTowerSend
