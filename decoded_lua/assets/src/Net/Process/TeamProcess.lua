require("src.Net.Proto.ProtoInclude")

local TeamProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function TeamProcess.init()
    NetMgr.addProcess(Proto.Command.GC_REFUSEJOINTEAM_ACK,
        TeamProcess.onGC_RefuseJoinTeam_Ack)
    NetMgr.addProcess(Proto.Command.GC_QUERYTEAMDUNGEONMONSTERHP_ACK,
        TeamProcess.onGC_QueryTeamDungeonMonsterHp_Ack)
    NetMgr.addProcess(Proto.Command.GC_TEAMDUNGEONBATTLESTART_ACK,
        TeamProcess.onGC_TeamDungeonBattleStart_Ack)
    NetMgr.addProcess(Proto.Command.GC_REVIVECHARACTER_ACK,
        TeamProcess.onGC_ReviveCharacter_Ack)
    NetMgr.addProcess(Proto.Command.GC_CHANGEARMYPET_ACK,
        TeamProcess.onGC_ChangeArmyPet_Ack)
    NetMgr.addProcess(Proto.Command.GC_CHARACTERLEAVEDUNGEON_NTF,
        TeamProcess.onGC_CharacterLeaveDungeon_Ntf)
    NetMgr.addProcess(Proto.Command.GC_LEAVETEAMDUNGEON_ACK,
        TeamProcess.onGC_LeaveTeamDungeon_Ack)
    NetMgr.addProcess(Proto.Command.GC_TEAMBATTLEEND_ACK,
        TeamProcess.onGC_TeamBattleEnd_Ack)
    NetMgr.addProcess(Proto.Command.GC_ENTERTEAMDUNGEON_ACK,
        TeamProcess.onGC_EnterTeamDungeon_Ack)
    NetMgr.addProcess(Proto.Command.GC_SETTEAMAUTOJOIN_ACK,
        TeamProcess.onGC_SetTeamAutoJoin_Ack)
    NetMgr.addProcess(Proto.Command.GC_TEAMDUNGEONEND_NTF,
        TeamProcess.onGC_TeamDungeonEnd_Ntf)
    NetMgr.addProcess(Proto.Command.GC_SETTEAMSORT_ACK,
        TeamProcess.onGC_SetTeamSort_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETMYTEAM_ACK,
        TeamProcess.onGC_GetMyTeam_Ack)
    NetMgr.addProcess(Proto.Command.GC_INVITETEAMMEMBER_ACK,
        TeamProcess.onGC_InviteTeamMember_Ack)
    NetMgr.addProcess(Proto.Command.GC_KICKTEAMMEMBER_NTF,
        TeamProcess.onGC_KickTeamMember_Ntf)
    NetMgr.addProcess(Proto.Command.GC_KICKTEAMMEMBER_ACK,
        TeamProcess.onGC_KickTeamMember_Ack)
    NetMgr.addProcess(Proto.Command.GC_SETTEAMPETS_ACK,
        TeamProcess.onGC_SetTeamPets_Ack)
    NetMgr.addProcess(Proto.Command.GC_SETTEAMREADY_ACK,
        TeamProcess.onGC_SetTeamReady_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETTEAMMEMBERS_ACK,
        TeamProcess.onGC_GetTeamMembers_Ack)
    NetMgr.addProcess(Proto.Command.GC_CREATETEAM_ACK,
        TeamProcess.onGC_CreateTeam_Ack)
    NetMgr.addProcess(Proto.Command.GC_CANCELAUTOJOINTEAM_ACK,
        TeamProcess.onGC_CancelAutoJoinTeam_Ack)
    NetMgr.addProcess(Proto.Command.GC_AUTOJOINTEAM_NTF,
        TeamProcess.onGC_AutoJoinTeam_Ntf)
    NetMgr.addProcess(Proto.Command.GC_AUTOJOINTEAM_ACK,
        TeamProcess.onGC_AutoJoinTeam_Ack)

end

function TeamProcess.onGC_AutoJoinTeam_Ack(msg)

    local res = Proto.parseP_GC_AutoJoinTeam_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_AutoJoinTeam_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_AUTOJOINTEAM_ACK)
    return res.code

end

function TeamProcess.onGC_AutoJoinTeam_Ntf(msg)

    local res = Proto.parseP_GC_AutoJoinTeam_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_AutoJoinTeam_Ntf")
    
    NetInterface.sendWithBlock("GC_GetMyTeam_Ack", function()
        local TeamSend = require("src.Net.Send.TeamSend")
        TeamSend.sendCG_GetMyTeam_Req({})
    end, nil, function(code)
        TipsMgr.showError(nil, code)
    end)
    
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_AUTOJOINTEAM_NTF)
    return res.code

end

function TeamProcess.onGC_CancelAutoJoinTeam_Ack(msg)

    local res = Proto.parseP_GC_CancelAutoJoinTeam_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_CancelAutoJoinTeam_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CANCELAUTOJOINTEAM_ACK)
    return res.code

end

function TeamProcess.onGC_CreateTeam_Ack(msg)

    local res = Proto.parseP_GC_CreateTeam_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_CreateTeam_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        TeamInfo.updateTeamData(res.teamData)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CREATETEAM_ACK)
    return res.code

end

function TeamProcess.onGC_GetTeamMembers_Ack(msg)

    local res = Proto.parseP_GC_GetTeamMembers_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetTeamMembers_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        for var=1, #res.memberIndexs do
            TeamInfo.updateTeamMemberData(res.memberIndexs[var], res.teamMemberDatas[var])
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETTEAMMEMBERS_ACK)
    return res.code

end

function TeamProcess.onGC_SetTeamReady_Ack(msg)

    local res = Proto.parseP_GC_SetTeamReady_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_SetTeamReady_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        TeamInfo.setReady(CharInfo.getCharID(), res.isReady)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_SETTEAMREADY_ACK)
    return res.code

end

function TeamProcess.onGC_SetTeamPets_Ack(msg)

    local res = Proto.parseP_GC_SetTeamPets_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_SetTeamPets_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        TeamInfo.updateTeamMemberData(nil, res.teamMemberData)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_SETTEAMPETS_ACK)
    return res.code

end

function TeamProcess.onGC_KickTeamMember_Ack(msg)

    local res = Proto.parseP_GC_KickTeamMember_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_KickTeamMember_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        --data.charID=Proto.parseDWORD(entry); -- 
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_KICKTEAMMEMBER_ACK)
    return res.code

end

function TeamProcess.onGC_KickTeamMember_Ntf(msg)

    local res = Proto.parseP_GC_KickTeamMember_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_KickTeamMember_Ntf")
    
    --data.charID=Proto.parseDWORD(entry); -- 
    
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_KICKTEAMMEMBER_NTF)
    return res.code

end

function TeamProcess.onGC_InviteTeamMember_Ack(msg)

    local res = Proto.parseP_GC_InviteTeamMember_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_InviteTeamMember_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_INVITETEAMMEMBER_ACK)
    return res.code

end

function TeamProcess.onGC_GetMyTeam_Ack(msg)

    local res = Proto.parseP_GC_GetMyTeam_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetMyTeam_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        CSResourceMgr.callButtonFunc("Player/Team/TeamMain.csb", "cancel")

        TeamInfo.updateTeamData(res.teamData)
        TeamViewMgr.refreshTeamMain()

        TeamInfo.receiveTeamJoinNtf(nil, function()
            TeamViewMgr.checkTab(2)
        end)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETMYTEAM_ACK)
    return res.code

end

function TeamProcess.onGC_SetTeamSort_Ack(msg)

    local res = Proto.parseP_GC_SetTeamSort_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_SetTeamSort_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        TeamInfo.updateTeamSort(res.teamSort)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_SETTEAMSORT_ACK)
    return res.code

end

function TeamProcess.onGC_TeamDungeonEnd_Ntf(msg)

    local res = Proto.parseP_GC_TeamDungeonEnd_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_TeamDungeonEnd_Ntf")
    print("###########onGC_TeamDungeonEnd_Ntf res=",sz_T2S(res))
    --if SceneMgr.currentScene == "TeamCopyMapScene" then
    --    TeamCopyWinMgr.show(SceneMgr.getRunningScene, res.chestID)
    --else
    --    TeamCopyWinMgr.setChestID(res.chestID)
        TeamCopyMapMgr.setKillMonsterNum(0, false)  
    --end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_TEAMDUNGEONEND_NTF)
    return res.code

end

function TeamProcess.onGC_SetTeamAutoJoin_Ack(msg)

    local res = Proto.parseP_GC_SetTeamAutoJoin_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_SetTeamAutoJoin_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        TeamInfo.updateJoinStatus(res.canAutoJoin==1)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_SETTEAMAUTOJOIN_ACK)
    return res.code

end

function TeamProcess.onGC_EnterTeamDungeon_Ack(msg)

    local res = Proto.parseP_GC_EnterTeamDungeon_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_EnterTeamDungeon_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_ENTERTEAMDUNGEON_ACK)
    return res.code

end

function TeamProcess.onGC_TeamBattleEnd_Ack(msg)

    local res = Proto.parseP_GC_TeamBattleEnd_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_TeamBattleEnd_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_TEAMBATTLEEND_ACK)
    return res.code

end

function TeamProcess.onGC_LeaveTeamDungeon_Ack(msg)

    local res = Proto.parseP_GC_LeaveTeamDungeon_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_LeaveTeamDungeon_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_LEAVETEAMDUNGEON_ACK)
    return res.code

end

function TeamProcess.onGC_CharacterLeaveDungeon_Ntf(msg)

    local res = Proto.parseP_GC_CharacterLeaveDungeon_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_CharacterLeaveDungeon_Ntf")
    if res.charID ~= CharInfo.getCharID() then
        if SceneMgr.currentScene == "TeamCopyMapScene" or (SceneMgr.currentScene == "BattleScene" and SceneMgr.previousScene == "TeamCopyMapScene") then
            TeamCopyMapMgr.localMemberLeaveTeam(res.charID)
        end
        TeamInfo.receiveTeamKick({charID = res.charID})
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CHARACTERLEAVEDUNGEON_NTF)
    return res.code

end

function TeamProcess.onGC_ChangeArmyPet_Ack(msg)

    local res = Proto.parseP_GC_ChangeArmyPet_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ChangeArmyPet_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CHANGEARMYPET_ACK)
    return res.code

end

function TeamProcess.onGC_ReviveCharacter_Ack(msg)

    local res = Proto.parseP_GC_ReviveCharacter_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ReviveCharacter_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_REVIVECHARACTER_ACK)
    return res.code

end

function TeamProcess.onGC_TeamDungeonBattleStart_Ack(msg)

    local res = Proto.parseP_GC_TeamDungeonBattleStart_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_TeamDungeonBattleStart_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_TEAMDUNGEONBATTLESTART_ACK)
    return res.code

end

function TeamProcess.onGC_QueryTeamDungeonMonsterHp_Ack(msg)

    local res = Proto.parseP_GC_QueryTeamDungeonMonsterHp_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_QueryTeamDungeonMonsterHp_Ack")
    print("###########onGC_QueryTeamDungeonMonsterHp_Ack res.vecMonsterHp="..sz_T2S(res.vecMonsterHp or {}))
    if (Proto.Error.ERROR_OK == res.code) then
        TeamCopyMapMgr.addLocalBattleInfo(res.vecMonsterHp or {})
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_QUERYTEAMDUNGEONMONSTERHP_ACK)
    return res.code

end

function TeamProcess.onGC_RefuseJoinTeam_Ack(msg)

    local res = Proto.parseP_GC_RefuseJoinTeam_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_RefuseJoinTeam_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_REFUSEJOINTEAM_ACK)
    return res.code

end

return TeamProcess
