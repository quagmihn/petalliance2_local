require( "src.Net.Proto.ProtoInclude")

local PVESend = {}
local NetMgr = require("src.Net.NetMgr")

function PVESend.sendCG_CreatePVEBattle_Req(params)

    local data = {
        battleType = params.battleType,
        battleTypeID = params.battleTypeID,
        battleTypeSubID = params.battleTypeSubID 
    }
    NetMgr.send(Proto.writeP_CG_CreatePVEBattle_Req, data)

end

function PVESend.sendCG_PVEBattleEnd_Req(params)

    local data = { 
        isWin = params.isWin,
        battleDetails = params.battleDetails
    }
    NetMgr.send(Proto.writeP_CG_PVEBattleEnd_Req, data)

end

function PVESend.sendCG_PVEPokemonCatch_Req(params)

    local data = {
        pokemonID = params.pokemonID,
        itemID = params.itemID
    }
    NetMgr.send(Proto.writeP_CG_PVEPokemonCatch_Req, data)

end

return PVESend
