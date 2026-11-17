require( "src.Net.Proto.ProtoInclude")

local ExploreSend = {}
local NetMgr = require("src.Net.NetMgr")

function ExploreSend.sendCG_GetExploreData_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetExploreData_Req, data)

end

function ExploreSend.sendCG_Explore_Req(params)

    local data = {
        exploreIndex = params.exploreIndex,     --1~5
        difficulty = params.difficulty,         --0~1
        option = params.option,                 --0~1
        petObjIDs = params.petObjIDs,           --探索宠物列表 第一个为队长
    }
    NetMgr.send(Proto.writeP_CG_Explore_Req, data)

end

function ExploreSend.sendCG_EndExplore_Req(params)

    local data = {
        exploreIndex = params.exploreIndex,     --1~5
    }
    NetMgr.send(Proto.writeP_CG_EndExplore_Req, data)

end

function ExploreSend.sendCG_BuyExplorePacket_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_BuyExplorePacket_Req, data)

end

return ExploreSend
