require("src.Net.Proto.ProtoInclude")

local TreasureBoxProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function TreasureBoxProcess.init()
    NetMgr.addProcess(Proto.Command.GC_SELECTTREASUREBOX_ACK,
        TreasureBoxProcess.onGC_SelectTreasureBox_Ack)
    NetMgr.addProcess(Proto.Command.GC_NEWTREASUREBOX_NTF,
        TreasureBoxProcess.onGC_NewTreasureBox_Ntf)
    NetMgr.addProcess(Proto.Command.GC_UNLOCKTREASUREBOX_ACK,
        TreasureBoxProcess.onGC_UnlockTreasureBox_Ack)
    NetMgr.addProcess(Proto.Command.GC_TREASUREBOXNTF_NTF,
        TreasureBoxProcess.onGC_TreasureBoxNTF_Ntf)
    NetMgr.addProcess(Proto.Command.GC_OPENTREASUREBOX_ACK,
        TreasureBoxProcess.onGC_OpenTreasureBox_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETTREASUREBOXDATA_ACK,
        TreasureBoxProcess.onGC_GetTreasureBoxData_Ack)

end

function TreasureBoxProcess.onGC_GetTreasureBoxData_Ack(msg)

    local res = Proto.parseP_GC_GetTreasureBoxData_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetTreasureBoxData_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        local cjson = require("cjson")
        local boxes = cjson.decode(res.boxes)
        print("###########onGC_GetTreasureBoxData_Ack res.boxes=", res.boxes)
        TreasureBoxInfo.setMyTreasureBoxData(boxes)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETTREASUREBOXDATA_ACK)
    return res.code

end

function TreasureBoxProcess.onGC_OpenTreasureBox_Ack(msg)

    local res = Proto.parseP_GC_OpenTreasureBox_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_OpenTreasureBox_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        if res.awards then
            if #res.awards>0 then
                for key, var in pairs(res.awards) do
                	print(key, var)
                end
                AwardsListMgr.show(SceneMgr.getRunningScene, res.awards)
        	end
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_OPENTREASUREBOX_ACK)
    return res.code

end

function TreasureBoxProcess.onGC_TreasureBoxNTF_Ntf(msg)

    local res = Proto.parseP_GC_TreasureBoxNTF_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_TreasureBoxNTF_Ntf")
    
    --data.boxes=Proto.parseString(entry);
    
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_TREASUREBOXNTF_NTF)
    return res.code

end

function TreasureBoxProcess.onGC_UnlockTreasureBox_Ack(msg)

    local res = Proto.parseP_GC_UnlockTreasureBox_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_UnlockTreasureBox_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        --print("###########onGC_UnlockTreasureBox_Ack res.boxes=", res.boxes)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_UNLOCKTREASUREBOX_ACK)
    return res.code

end

local function checkTeamCopyFinishState()
    local isHaveFriend = TeamCopyMapMgr.isHaveFriend()
    TaskWatcherManager.saveZuduiResultState("zdfbpass_"..TeamCopyMapMgr.getCopyID(), function()
        if isHaveFriend == true then
            TaskWatcherManager.saveZuduiResultState("zdfbfriend")
        end
    end)
end

function TreasureBoxProcess.onGC_NewTreasureBox_Ntf(msg)

    local res = Proto.parseP_GC_NewTreasureBox_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_NewTreasureBox_Ntf")
    checkTeamCopyFinishState()
    print("###########onGC_NewTreasureBox_Ntf res=",sz_T2S(res))
    local cjson = require("cjson")
    local boxes = cjson.decode(res.boxes)
    TeamCopyWinMgr.show(SceneMgr.getRunningScene, boxes)
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_NEWTREASUREBOX_NTF)
    return res.code

end

function TreasureBoxProcess.onGC_SelectTreasureBox_Ack(msg)

    local res = Proto.parseP_GC_SelectTreasureBox_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_SelectTreasureBox_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_SELECTTREASUREBOX_ACK)
    return res.code

end

return TreasureBoxProcess
