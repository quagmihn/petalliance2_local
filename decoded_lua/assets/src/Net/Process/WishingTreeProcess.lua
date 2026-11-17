require("src.Net.Proto.ProtoInclude")

local WishingTreeProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function WishingTreeProcess.init()
    NetMgr.addProcess(Proto.Command.GC_PRAYTOTREE_ACK,
        WishingTreeProcess.onGC_PrayToTree_Ack)
    NetMgr.addProcess(Proto.Command.GC_PLANTTREENTF_NTF,
        WishingTreeProcess.onGC_PlantTreeNTF_Ntf)
    NetMgr.addProcess(Proto.Command.GC_GETWISHINGTREESDATA_ACK,
        WishingTreeProcess.onGC_GetWishingTreesData_Ack)

end

function WishingTreeProcess.onGC_GetWishingTreesData_Ack(msg)

    local res = Proto.parseP_GC_GetWishingTreesData_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetWishingTreesData_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        TreeInfoView.setTreesData(res.treesData)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETWISHINGTREESDATA_ACK)
    return res.code

end

function WishingTreeProcess.onGC_PlantTreeNTF_Ntf(msg)

    local res = Proto.parseP_GC_PlantTreeNTF_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_PlantTreeNTF_Ntf")

    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PLANTTREENTF_NTF)
    return res.code

end

function WishingTreeProcess.onGC_PrayToTree_Ack(msg)

    local res = Proto.parseP_GC_PrayToTree_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PrayToTree_Ack")
    print(res.code)
    if (Proto.Error.ERROR_OK == res.code) then
        for k,v in pairs(res.awards) do
            print(k,v)
        end
        TreeInfoView.showAwards(res.awards)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PRAYTOTREE_ACK)
    return res.code

end

return WishingTreeProcess
