require("src.Net.Proto.ProtoInclude")

local ExpeditionProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function ExpeditionProcess.init()
    NetMgr.addProcess(Proto.Command.GC_PETDETAIL_NTF,
        ExpeditionProcess.onGC_PetDetail_Ntf)
    NetMgr.addProcess(Proto.Command.GC_BUYROLLCOUNT_ACK,
        ExpeditionProcess.onGC_BuyRollCount_Ack)
    NetMgr.addProcess(Proto.Command.GC_EXPEDITIONAWARD_NTF,
        ExpeditionProcess.onGC_ExpeditionAward_Ntf)
    NetMgr.addProcess(Proto.Command.GC_ROLLDICE_ACK,
        ExpeditionProcess.onGC_RollDice_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETPOINTLOTTERYDATA_ACK,
        ExpeditionProcess.onGC_GetPointLotteryData_Ack)
    NetMgr.addProcess(Proto.Command.GC_EXPEDITIONBATTLEEND_ACK,
        ExpeditionProcess.onGC_ExpeditionBattleEnd_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETEXPEDITIONDATA_ACK,
        ExpeditionProcess.onGC_GetExpeditionData_Ack)

end

function ExpeditionProcess.onGC_GetExpeditionData_Ack(msg)

    local res = Proto.parseP_GC_GetExpeditionData_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetExpeditionData_Ack")

    if (Proto.Error.ERROR_OK == res.code) then
        local ExpeditionalInfo =  require("src.GameMgr.Data.ExpeditionalInfo")
        expeditionalViewMgr.expedition = ExpeditionalInfo.new(res.expeditionData)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETEXPEDITIONDATA_ACK)
    return res.code

end

function ExpeditionProcess.onGC_ExpeditionBattleEnd_Ack(msg)

    local res = Proto.parseP_GC_ExpeditionBattleEnd_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ExpeditionBattleEnd_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_EXPEDITIONBATTLEEND_ACK)
    return res.code

end

function ExpeditionProcess.onGC_GetPointLotteryData_Ack(msg)

    local res = Proto.parseP_GC_GetPointLotteryData_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetPointLotteryData_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("onGC_GetPointLotteryData_Ack~~~~~~~~~~~~~~~~~~~~~~~~") 
        print(sz_T2S(res))  
        expeditionalViewMgr.setRollIndex(res.currentPos)
        expeditionalViewMgr.expedition:setbuyCount(res.buyCount)
        expeditionalViewMgr.expedition:setmaxBuyCount(res.maxBuyCount)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETPOINTLOTTERYDATA_ACK)
    return res.code

end

function ExpeditionProcess.onGC_RollDice_Ack(msg)

    local res = Proto.parseP_GC_RollDice_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_RollDice_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("onGC_RollDice_Ack~~~~~~~~~~",res.stepNumber)
        expeditionalViewMgr.setRollstepNum(res.stepNumber)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_ROLLDICE_ACK)
    return res.code

end

function ExpeditionProcess.onGC_ExpeditionAward_Ntf(msg)

    local res = Proto.parseP_GC_ExpeditionAward_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_ExpeditionAward_Ntf")
    print("GC_ExpeditionAward_Ntf~~~~~~~~~~",sz_T2S(res)) 
    expeditionalViewMgr.setAwardThings(res.awards)
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_EXPEDITIONAWARD_NTF)
    return res.code

end

function ExpeditionProcess.onGC_BuyRollCount_Ack(msg)

    local res = Proto.parseP_GC_BuyRollCount_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_BuyRollCount_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_BUYROLLCOUNT_ACK)
    return res.code

end

function ExpeditionProcess.onGC_PetDetail_Ntf(msg)

    local res = Proto.parseP_GC_PetDetail_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_PetDetail_Ntf")
    print("onGC_PetDetail_Ntf ~~~~~~~ ",sz_T2S(res)) 
    local cjson     = require("cjson")
    local scienceValue = ScienceInfo.getScienceAttrsTable()
    local scienceLimitDat   = SystemInfo.getGlobalConfigAddInfoByID(61005)

    for key,var in pairs(res.pets) do 
        local pet = cjson.decode(var)
        local CPet = PokemonInfo.getPetInfoByObjID(pet.objID) 
        pet.name = (CPet and PetEducationMgr.getPetName(CPet)) or pet.personal.name
        if scienceLimitDat and pet.level >= scienceLimitDat.values[1] then
            pet.hpmax = pet.hpmax + (scienceValue[Proto.AT_HP] or 0) 
        end
        table.insert(expeditionalViewMgr.pets,pet)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PETDETAIL_NTF)
    return res.code

end

return ExpeditionProcess
