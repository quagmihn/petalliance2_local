require( "src.Net.Proto.ProtoInclude")

local TeamSend = {}
local NetMgr = require("src.Net.NetMgr")

function TeamSend.sendCG_AutoJoinTeam_Req(params)

    local data = {
        adventureID = params.adventureID,
        leaderID = params.leaderID,
    }
    NetMgr.send(Proto.writeP_CG_AutoJoinTeam_Req, data)

end

function TeamSend.sendCG_CancelAutoJoinTeam_Req(params)

    local data = {
        adventureID = params.adventureID
    }
    NetMgr.send(Proto.writeP_CG_CancelAutoJoinTeam_Req, data)

end

function TeamSend.sendCG_CreateTeam_Req(params)

    local data = {
        adventureID = params.adventureID,
        canAutoJoin = params.canAutoJoin,   -- 0 canot 1 can
    }
    NetMgr.send(Proto.writeP_CG_CreateTeam_Req, data)

end

function TeamSend.sendCG_GetTeamMembers_Req(params)

    local data = {  
        memberIndexs = params.memberIndexs,
    }
    NetMgr.send(Proto.writeP_CG_GetTeamMembers_Req, data)

end

function TeamSend.sendCG_SetTeamReady_Req(params)

    local data = {
        isReady = params.isReady, -- 0:notReady 1:ready
    }
    NetMgr.send(Proto.writeP_CG_SetTeamReady_Req, data)

end

function TeamSend.sendCG_SetTeamPets_Req(params)

    local data = {
        petObjIDs = params.petObjIDs,
        helperPetObjIDs = params.helperPetObjIDs,
    }
    NetMgr.send(Proto.writeP_CG_SetTeamPets_Req, data)

end

function TeamSend.sendCG_KickTeamMember_Req(params)

    local data = {
        charID = params.charID,
    }
    NetMgr.send(Proto.writeP_CG_KickTeamMember_Req, data)

end

function TeamSend.sendCG_InviteTeamMember_Req(params)

    local data = {
        charID = params.charID,
    }
    NetMgr.send(Proto.writeP_CG_InviteTeamMember_Req, data)

end

function TeamSend.sendCG_GetMyTeam_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetMyTeam_Req, data)

end

function TeamSend.sendCG_SetTeamSort_Req(params)

    local data = {
        teamSort = params.teamSort, -- [0,1,2]
    }
    NetMgr.send(Proto.writeP_CG_SetTeamSort_Req, data)

end

function TeamSend.sendCG_SetTeamAutoJoin_Req(params)

    local data = {
        canAutoJoin = params.canAutoJoin,   -- 0 canot 1 can
    }
    NetMgr.send(Proto.writeP_CG_SetTeamAutoJoin_Req, data)

end

function TeamSend.sendCG_EnterTeamDungeon_Req(params)

    local data = {
        mapID = params.mapID
    }
    NetMgr.send(Proto.writeP_CG_EnterTeamDungeon_Req, data)

end

function TeamSend.sendCG_TeamBattleEnd_Req(params)

    local data = {
        isWin = params.isWin,
        battleDetails = params.battleDetails,
        monsterHP = params.monsterHp,
        battleID = params.battleID,
        x = params.x,
        y = params.y
    }
    NetMgr.send(Proto.writeP_CG_TeamBattleEnd_Req, data)

end

function TeamSend.sendCG_LeaveTeamDungeon_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_LeaveTeamDungeon_Req, data)

end

function TeamSend.sendCG_ChangeArmyPet_Req(params)

    local data = {
        pets = params.pets,
        helperPets = params.helperPets
    }
    NetMgr.send(Proto.writeP_CG_ChangeArmyPet_Req, data)

end

function TeamSend.sendCG_ReviveCharacter_Req(params)

    local data = {
        charID = params.charID,
    }
    NetMgr.send(Proto.writeP_CG_ReviveCharacter_Req, data)

end

function TeamSend.sendCG_TeamDungeonBattleStart_Req(params)

    local data = {
        monsterID = params.monsterID
    }
    NetMgr.send(Proto.writeP_CG_TeamDungeonBattleStart_Req, data)

end

function TeamSend.sendCG_QueryTeamDungeonMonsterHp_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_QueryTeamDungeonMonsterHp_Req, data)

end

function TeamSend.sendCG_RefuseJoinTeam_Req(params)

    local data = {
        teamID = params.teamID,
    }
    NetMgr.send(Proto.writeP_CG_RefuseJoinTeam_Req, data)

end

return TeamSend
