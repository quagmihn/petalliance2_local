require( "src.Net.Proto.ProtoInclude")

local ChatUserSend = {}
local NetMgr = require("src.Net.NetMgr")

function ChatUserSend.sendCG_GetMyFriends_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetMyFriends_Req, data)

end

function ChatUserSend.sendCG_AddFriend_Req(params)

    local data = {
        friendID = params.friendID
    }
    NetMgr.send(Proto.writeP_CG_AddFriend_Req, data)

end

function ChatUserSend.sendCG_ConfirmAddFriend_Req(params)

    local data = {
        friendID = params.friendID,
        isConfirm = params.isConfirm
    }
    NetMgr.send(Proto.writeP_CG_ConfirmAddFriend_Req, data)

end

function ChatUserSend.sendCG_GetFriendDetail_Req(params)

    local data = {
        friendID = params.friendID
    }
    NetMgr.send(Proto.writeP_CG_GetFriendDetail_Req, data)

end

function ChatUserSend.sendCG_DelFriend_Req(params)

    local data = {
        friendID = params.friendID
    }
    NetMgr.send(Proto.writeP_CG_DelFriend_Req, data)

end

function ChatUserSend.sendCG_GetMyRedHearts_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetMyRedHearts_Req, data)

end

function ChatUserSend.sendCG_RedHeart_Req(params)

    local data = {
        friendID = params.friendID
    }
    NetMgr.send(Proto.writeP_CG_RedHeart_Req, data)

end

function ChatUserSend.sendCG_GetRecommendFriend_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetRecommendFriend_Req, data)

end

function ChatUserSend.sendCG_UpdateFriendDetail_Req(params)

    local data = {
        friendID = params.friendID,
        detail = params.detail
    }
    NetMgr.send(Proto.writeP_CG_UpdateFriendDetail_Req, data)

end

function ChatUserSend.sendCG_DisbandAllFriendApply_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_DisbandAllFriendApply_Req, data)

end

return ChatUserSend
