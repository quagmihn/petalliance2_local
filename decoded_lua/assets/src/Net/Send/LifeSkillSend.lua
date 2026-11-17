require( "src.Net.Proto.ProtoInclude")

local LifeSkillSend = {}
local NetMgr = require("src.Net.NetMgr")

function LifeSkillSend.sendCG_GetLifeSkillData_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetLifeSkillData_Req, data)

end

function LifeSkillSend.sendCG_UnlockLifeSkill_Req(params)

    local data = {
        career = params
    }
    NetMgr.send(Proto.writeP_CG_UnlockLifeSkill_Req, data)

end

function LifeSkillSend.sendCG_ChangeLifeCareer_Req(params)

    local data = {
        career = params
    }
    NetMgr.send(Proto.writeP_CG_ChangeLifeCareer_Req, data)

end

function LifeSkillSend.sendCG_Manufacture_Req(params)

    local data = {
        drawingID = params.makeid,
        count = params.count
    }
    NetMgr.send(Proto.writeP_CG_Manufacture_Req, data)

end



function LifeSkillSend.sendCG_BuyDrawings_Req(params)

    local data = {
        drawingID = params
    }
    NetMgr.send(Proto.writeP_CG_BuyDrawings_Req, data)

end

return LifeSkillSend
