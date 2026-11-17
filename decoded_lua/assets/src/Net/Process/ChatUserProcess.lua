require("src.Net.Proto.ProtoInclude")

local ChatUserProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function ChatUserProcess.init()
    NetMgr.addProcess(Proto.Command.GC_DISBANDALLFRIENDAPPLY_ACK,
        ChatUserProcess.onGC_DisbandAllFriendApply_Ack)
    NetMgr.addProcess(Proto.Command.GC_FRIENDFULL_NTF,
        ChatUserProcess.onGC_FriendFull_Ntf)
    NetMgr.addProcess(Proto.Command.GC_UPDATEFRIENDDETAIL_ACK,
        ChatUserProcess.onGC_UpdateFriendDetail_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETRECOMMENDFRIEND_ACK,
        ChatUserProcess.onGC_GetRecommendFriend_Ack)
    NetMgr.addProcess(Proto.Command.GC_REDHEART_ACK,
        ChatUserProcess.onGC_RedHeart_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETMYREDHEARTS_NTF,
        ChatUserProcess.onGC_GetMyRedHearts_Ntf)
    NetMgr.addProcess(Proto.Command.GC_GETMYREDHEARTS_ACK,
        ChatUserProcess.onGC_GetMyRedHearts_Ack)
    NetMgr.addProcess(Proto.Command.GC_DELFRIEND_ACK,
        ChatUserProcess.onGC_DelFriend_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETFRIENDDETAIL_ACK,
        ChatUserProcess.onGC_GetFriendDetail_Ack)
    NetMgr.addProcess(Proto.Command.GC_CONFIRMADDFRIEND_ACK,
        ChatUserProcess.onGC_ConfirmAddFriend_Ack)
    NetMgr.addProcess(Proto.Command.GC_ADDFRIEND_NTF,
        ChatUserProcess.onGC_AddFriend_Ntf)
    NetMgr.addProcess(Proto.Command.GC_ADDFRIEND_ACK,
        ChatUserProcess.onGC_AddFriend_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETMYFRIENDS_NTF,
        ChatUserProcess.onGC_GetMyFriends_Ntf)
    NetMgr.addProcess(Proto.Command.GC_GETMYFRIENDS_ACK,
        ChatUserProcess.onGC_GetMyFriends_Ack)

end

function ChatUserProcess.onGC_GetMyFriends_Ack(msg)

    local res = Proto.parseP_GC_GetMyFriends_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetMyFriends_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        FriendsViewMgr.setAllFriendNum(res.friendNum)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETMYFRIENDS_ACK)
    return res.code

end

function ChatUserProcess.onGC_GetMyFriends_Ntf(msg)

    local res = Proto.parseP_GC_GetMyFriends_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_GetMyFriends_Ntf")
    if CSResourceMgr.getCsbObj("Player/SelectBeautyView.csb") then
        SelectBeautyViewMgr.setAllFriendTable(res.friends)
    elseif CSResourceMgr.getCsbObj("Player/Team/invitePlayersView.csb") then
        TeamInviteMgr.setInviteFriends(res.friends)
    else
        FriendsViewMgr.getAllFriend(res.friends)
    end

    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETMYFRIENDS_NTF)
    return res.code

end

function ChatUserProcess.onGC_AddFriend_Ack(msg)

    local res = Proto.parseP_GC_AddFriend_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_AddFriend_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        if res.newfriend~="{}" then
            local cjson = require("cjson")
            local friendInfo = cjson.decode(res.newfriend)
            FriendsViewMgr.addFriendToList(friendInfo)
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_ADDFRIEND_ACK)
    return res.code

end

function ChatUserProcess.onGC_AddFriend_Ntf(msg)

    local res = Proto.parseP_GC_AddFriend_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_AddFriend_Ntf")

    FriendsViewMgr.showNewFriendRedPoint(res.newfriend,res.needConfirm)

    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_ADDFRIEND_NTF)
    return res.code

end

function ChatUserProcess.onGC_ConfirmAddFriend_Ack(msg)

    local res = Proto.parseP_GC_ConfirmAddFriend_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ConfirmAddFriend_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CONFIRMADDFRIEND_ACK)
    return res.code

end

function ChatUserProcess.onGC_GetFriendDetail_Ack(msg)

    local res = Proto.parseP_GC_GetFriendDetail_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetFriendDetail_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        local cjson = require("cjson")
        local playerInfo = cjson.decode(res.detail)
        if TeamInviteMgr.isInTeamPlay() then
            TeamInviteMgr.showPlayerInfoWindow(playerInfo)
        end
        PersonalCenterMgr.setPlayerInfo(playerInfo)
        FriendsViewMgr.setSearchPlayer(playerInfo)
        FamilyInfo.SetLastQueryMemberDetailInfo(playerInfo)
        FriendsViewMgr.setFriendInfo(playerInfo)
        BattlePVPMgr.setOpponentContent(playerInfo)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETFRIENDDETAIL_ACK)
    return res.code

end

function ChatUserProcess.onGC_DelFriend_Ack(msg)

    local res = Proto.parseP_GC_DelFriend_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_DelFriend_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_DELFRIEND_ACK)
    return res.code

end

function ChatUserProcess.onGC_GetMyRedHearts_Ack(msg)

    local res = Proto.parseP_GC_GetMyRedHearts_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetMyRedHearts_Ack")
    print(res.code)
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETMYREDHEARTS_ACK)
    return res.code

end

function ChatUserProcess.onGC_GetMyRedHearts_Ntf(msg)

    local res = Proto.parseP_GC_GetMyRedHearts_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_GetMyRedHearts_Ntf")

    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETMYREDHEARTS_NTF)
    return res.code

end

function ChatUserProcess.onGC_RedHeart_Ack(msg)

    local res = Proto.parseP_GC_RedHeart_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_RedHeart_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_REDHEART_ACK)
    return res.code

end

function ChatUserProcess.onGC_GetRecommendFriend_Ack(msg)

    local res = Proto.parseP_GC_GetRecommendFriend_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetRecommendFriend_Ack")
    print(res.code)
    if (Proto.Error.ERROR_OK == res.code) then
        FriendsViewMgr.setRecommendFriend(res.recommends)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETRECOMMENDFRIEND_ACK)
    return res.code

end

function ChatUserProcess.onGC_UpdateFriendDetail_Ack(msg)

    local res = Proto.parseP_GC_UpdateFriendDetail_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_UpdateFriendDetail_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_UPDATEFRIENDDETAIL_ACK)
    return res.code

end

function ChatUserProcess.onGC_FriendFull_Ntf(msg)

    local res = Proto.parseP_GC_FriendFull_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_FriendFull_Ntf")

    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FRIENDFULL_NTF)
    return res.code

end

function ChatUserProcess.onGC_DisbandAllFriendApply_Ack(msg)

    local res = Proto.parseP_GC_DisbandAllFriendApply_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_DisbandAllFriendApply_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_DISBANDALLFRIENDAPPLY_ACK)
    return res.code

end

return ChatUserProcess
