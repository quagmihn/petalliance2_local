require( "src.Net.Proto.ProtoInclude")

local MessageBoardSend = {}
local NetMgr = require("src.Net.NetMgr")

function MessageBoardSend.sendCG_PostMessagePet_Req(params)

    local data = {
        sContent = params.sContent,
        pokeID = params.pokeID,
    }
    NetMgr.send(Proto.writeP_CG_PostMessagePet_Req, data)

end

function MessageBoardSend.sendCG_PostMessageFB_Req(params)

    local data = {
        sContent = params.sContent,
        mapID = params.mapID,
        nodeID = params.nodeID,
        diffi = params.diffi,
    }
    NetMgr.send(Proto.writeP_CG_PostMessageFB_Req, data)

end

function MessageBoardSend.sendCG_PostApprovePet_Req(params)

    local data = {
        sCommentID = params.sCommentID,
        bApprove = params.bApprove,
    }
    NetMgr.send(Proto.writeP_CG_PostApprovePet_Req, data)

end

function MessageBoardSend.sendCG_PostApproveFB_Req(params)

    local data = {
        sCommentID = params.sCommentID,
        bApprove = params.bApprove,
    }
    NetMgr.send(Proto.writeP_CG_PostApproveFB_Req, data)

end

function MessageBoardSend.sendCG_GetMessagesPetByTime_Req(params)

    local data = {
        pokeID = params.pokeID,
        startIndex = params.startIndex,
        num = params.num,
    }
    NetMgr.send(Proto.writeP_CG_GetMessagesPetByTime_Req, data)

end

function MessageBoardSend.sendCG_GetMessagesPetByApprove_Req(params)

    local data = {
        pokeID = params.pokeID,
        tipNum = params.tipNum,
        skipNum = params.skipNum,
        num = params.num,
    }
    NetMgr.send(Proto.writeP_CG_GetMessagesPetByApprove_Req, data)

end

function MessageBoardSend.sendCG_GetMessagesFBByTime_Req(params)

    local data = {
        mapID = params.mapID,
        nodeID = params.nodeID,
        diffi = params.diffi,
        startIndex = params.startIndex,
        num = params.num,
    }
    NetMgr.send(Proto.writeP_CG_GetMessagesFBByTime_Req, data)

end

function MessageBoardSend.sendCG_GetMessagesFBByApprove_Req(params)

    local data = {
        mapID = params.mapID,
        nodeID = params.nodeID,
        diffi = params.diffi,
        tipNum = params.tipNum,
        skipNum = params.skipNum,
        num = params.num,
    }
    NetMgr.send(Proto.writeP_CG_GetMessagesFBByApprove_Req, data)

end

return MessageBoardSend
