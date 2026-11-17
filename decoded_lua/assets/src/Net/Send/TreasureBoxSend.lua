require( "src.Net.Proto.ProtoInclude")

local TreasureBoxSend = {}
local NetMgr = require("src.Net.NetMgr")

function TreasureBoxSend.sendCG_GetTreasureBoxData_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetTreasureBoxData_Req, data)

end

function TreasureBoxSend.sendCG_OpenTreasureBox_Req(params)

    local data = {
        boxID = params.boxID,   --0~3
        bFree = params.bFree,   --0nofree, 1free
    }
    NetMgr.send(Proto.writeP_CG_OpenTreasureBox_Req, data)

end

function TreasureBoxSend.sendCG_UnlockTreasureBox_Req(params)

    local data = {
        boxID = params.boxID,   --0~3
    }
    NetMgr.send(Proto.writeP_CG_UnlockTreasureBox_Req, data)

end

function TreasureBoxSend.sendCG_SelectTreasureBox_Req(params)

    local data = {
        boxID = params.boxID,
    }
    print("###########sendCG_SelectTreasureBox_Req data="..sz_T2S(data))
    NetMgr.send(Proto.writeP_CG_SelectTreasureBox_Req, data)

end

return TreasureBoxSend
