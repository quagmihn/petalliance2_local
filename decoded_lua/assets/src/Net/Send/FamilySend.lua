require( "src.Net.Proto.ProtoInclude")

local FamilySend = {}
local NetMgr = require("src.Net.NetMgr")

function FamilySend.sendCG_Family_Req(params)

    local data = {
        cmd = params.cmd,
        concent = params.concent,
    }
    NetMgr.send(Proto.writeP_CG_Family_Req, data)

end

function FamilySend.sendCG_GetDungeon_Req(params)

    local data = {
        type = params.type,
    }
    NetMgr.send(Proto.writeP_CG_GetDungeon_Req, data)

end

function FamilySend.sendCG_DungeonMoveCell_Req(params)

    local data = {
        x = params.x,
        y = params.y,
        path = params.path,
        type = params.type,
    }
    NetMgr.send(Proto.writeP_CG_DungeonMoveCell_Req, data)

end

function FamilySend.sendCG_FamilyDisplayCell_Req(params)

    local data = {
        x = params.x,
        y = params.y,
    }
    NetMgr.send(Proto.writeP_CG_FamilyDisplayCell_Req, data)

end

function FamilySend.sendCG_FireDungeonCell_Req(params)

    local data = {
        x = params.x,
        y = params.y,
        type = params.type,
    }
    NetMgr.send(Proto.writeP_CG_FireDungeonCell_Req, data)

end

function FamilySend.sendCG_DungeonBattleEnd_Req(params)

    local data = {
        isWin = params.isWin,
        battleID = params.battleID,
        monsterHp = params.monsterHp,
        dps = params.dps,
        x = params.x,
        y = params.y,
        type = params.type,
    }
    NetMgr.send(Proto.writeP_CG_DungeonBattleEnd_Req, data)

end

function FamilySend.sendCG_DungeonChangeFloor_Req(params)

    local data = {
        type = params.type,
        mapType = params.mapType,
    }
    NetMgr.send(Proto.writeP_CG_DungeonChangeFloor_Req, data)

end

function FamilySend.sendCG_GetDungeonCreateTime_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetDungeonCreateTime_Req, data)

end

function FamilySend.sendCG_ResetDungeon_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_ResetDungeon_Req, data)

end

function FamilySend.sendCG_GetDungeonAwardInfo_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetDungeonAwardInfo_Req, data)

end

function FamilySend.sendCG_GetDungeonAward_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetDungeonAward_Req, data)

end

function FamilySend.sendCG_GetDungeonLog_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetDungeonLog_Req, data)

end

function FamilySend.sendCG_GetFamilyShopData_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetFamilyShopData_Req, data)

end

function FamilySend.sendCG_BuyFamilyShopGoods_Req(params)

    local data = {
        goodsID = params.goodsID,
    }
    NetMgr.send(Proto.writeP_CG_BuyFamilyShopGoods_Req, data)

end

function FamilySend.sendCG_RefalshFamilyShop_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_RefalshFamilyShop_Req, data)

end

function FamilySend.sendCG_LevelReflashFamilyShop_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_LevelReflashFamilyShop_Req, data)

end

return FamilySend
