require("src.Net.Proto.ProtoInclude")

local LostTowerProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function LostTowerProcess.init()
    NetMgr.addProcess(Proto.Command.GC_MONEYOPENCHEST_ACK,
        LostTowerProcess.onGC_MoneyOpenChest_Ack)
    NetMgr.addProcess(Proto.Command.GC_LOSTTOWEREVENTS_NTF,
        LostTowerProcess.onGC_LostTowerEvents_Ntf)
    NetMgr.addProcess(Proto.Command.GC_ADDLOSTTOWERPETS_NTF,
        LostTowerProcess.onGC_AddLostTowerPets_Ntf)
    NetMgr.addProcess(Proto.Command.GC_RECOVERSTEPNUMBER_ACK,
        LostTowerProcess.onGC_RecoverStepNumber_Ack)
    NetMgr.addProcess(Proto.Command.GC_LOSTTOWERSTEPNUMBERUPDATE_NTF,
        LostTowerProcess.onGC_LostTowerStepNumberUpdate_Ntf)
    NetMgr.addProcess(Proto.Command.GC_LOSTTOWERITEMUPDATE_NTF,
        LostTowerProcess.onGC_LostTowerItemUpdate_Ntf)
    NetMgr.addProcess(Proto.Command.GC_USELOSTTOWERITEM_ACK,
        LostTowerProcess.onGC_UseLostTowerItem_Ack)
    NetMgr.addProcess(Proto.Command.GC_LOSTTOWERWEEKPOINTCHANGE_NTF,
        LostTowerProcess.onGC_LostTowerWeekPointChange_Ntf)
    NetMgr.addProcess(Proto.Command.GC_ENTERTRANSFERDOOR_ACK,
        LostTowerProcess.onGC_EnterTransferDoor_Ack)
    NetMgr.addProcess(Proto.Command.GC_TRANSFERCELL_NTF,
        LostTowerProcess.onGC_TransferCell_Ntf)
    NetMgr.addProcess(Proto.Command.GC_QUERYPOINTRANK_ACK,
        LostTowerProcess.onGC_QueryPointRank_Ack)
    NetMgr.addProcess(Proto.Command.GC_QUERYFLOORRANK_ACK,
        LostTowerProcess.onGC_QueryFloorRank_Ack)
    NetMgr.addProcess(Proto.Command.GC_LOSTTOWERPVPBATTLEEND_ACK,
        LostTowerProcess.onGC_LostTowerPVPBattleEnd_Ack)
    NetMgr.addProcess(Proto.Command.GC_ONTRAP_ACK,
        LostTowerProcess.onGC_onTrap_Ack)
    NetMgr.addProcess(Proto.Command.GC_MOVEOBSTACLE_ACK,
        LostTowerProcess.onGC_MoveObstacle_Ack)
    NetMgr.addProcess(Proto.Command.GC_TRANSFERFLOOR_ACK,
        LostTowerProcess.onGC_TransferFloor_Ack)
    NetMgr.addProcess(Proto.Command.GC_RECOVERSTATE_ACK,
        LostTowerProcess.onGC_RecoverState_Ack)
    NetMgr.addProcess(Proto.Command.GC_LOSTTOWERPOINTCHANGE_NTF,
        LostTowerProcess.onGC_LostTowerPointChange_Ntf)
    NetMgr.addProcess(Proto.Command.GC_CHANGEREADYPET_ACK,
        LostTowerProcess.onGC_changeReadyPet_Ack)
    NetMgr.addProcess(Proto.Command.GC_RANDOMEVENT_NTF,
        LostTowerProcess.onGC_RandomEvent_Ntf)
    NetMgr.addProcess(Proto.Command.GC_EVENTAWARD_NTF,
        LostTowerProcess.onGC_EventAward_Ntf)
    NetMgr.addProcess(Proto.Command.GC_FIREEVENTCELL_ACK,
        LostTowerProcess.onGC_fireEventCell_Ack)
    NetMgr.addProcess(Proto.Command.GC_CHANGEFLOOR_ACK,
        LostTowerProcess.onGC_ChangeFloor_Ack)
    NetMgr.addProcess(Proto.Command.GC_MOVENEWCELL_ACK,
        LostTowerProcess.onGC_moveNewCell_Ack)
    NetMgr.addProcess(Proto.Command.GC_RESETDATA_ACK,
        LostTowerProcess.onGC_resetData_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETLOSTTOWERDATA_ACK,
        LostTowerProcess.onGC_GetLostTowerData_Ack)

end

function LostTowerProcess.onGC_GetLostTowerData_Ack(msg)

    local res = Proto.parseP_GC_GetLostTowerData_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetLostTowerData_Ack")
    print("GC_GetLostTowerData_Ack -- code",res.code)
    print(res.lostTowerData)
    
    if (Proto.Error.ERROR_OK == res.code) then
        -- res.LostTowerData = "{\"armys\":{\"0\":{\"objID\":1},\"1\":{\"objID\":2},\"2\":{\"objID\":4},\"3\":{\"objID\":5},\"4\":{\"objID\":20}},\"currentFloor\":1,\"events\":{\"0\":{\"eventID\":1,\"flo\":0,\"sceneID\":8,\"type\":15,\"x\":1,\"xyID\":6,\"y\":1},\"1\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":1,\"xyID\":12,\"y\":2},\"10\":{\"eventID\":66,\"flo\":0,\"sceneID\":8,\"type\":2,\"x\":2,\"xyID\":13,\"y\":2},\"11\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":2,\"xyID\":19,\"y\":3},\"12\":{\"eventID\":66,\"flo\":0,\"sceneID\":8,\"type\":2,\"x\":2,\"xyID\":25,\"y\":4},\"13\":{\"eventID\":8000,\"flo\":0,\"sceneID\":8,\"type\":8,\"x\":2,\"xyID\":31,\"y\":5},\"14\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":2,\"xyID\":37,\"y\":6},\"15\":{\"eventID\":10,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":2,\"xyID\":43,\"y\":7},\"16\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":2,\"xyID\":49,\"y\":8},\"17\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":2,\"xyID\":55,\"y\":9},\"18\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":3,\"xyID\":8,\"y\":1},\"19\":{\"eventID\":8000,\"flo\":0,\"sceneID\":8,\"type\":8,\"x\":3,\"xyID\":14,\"y\":2},\"2\":{\"eventID\":1,\"flo\":0,\"sceneID\":8,\"type\":1,\"x\":1,\"xyID\":18,\"y\":3},\"20\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":3,\"xyID\":20,\"y\":3},\"21\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":3,\"xyID\":26,\"y\":4},\"22\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":15,\"x\":3,\"xyID\":32,\"y\":5},\"23\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":3,\"xyID\":38,\"y\":6},\"24\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":3,\"xyID\":44,\"y\":7},\"25\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":3,\"xyID\":50,\"y\":8},\"26\":{\"eventID\":1,\"flo\":0,\"sceneID\":8,\"type\":1,\"x\":3,\"xyID\":56,\"y\":9},\"27\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":4,\"xyID\":9,\"y\":1},\"28\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":4,\"xyID\":15,\"y\":2},\"29\":{\"eventID\":1,\"flo\":0,\"sceneID\":8,\"type\":1,\"x\":4,\"xyID\":21,\"y\":3},\"3\":{\"eventID\":10,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":1,\"xyID\":24,\"y\":4},\"30\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":4,\"xyID\":27,\"y\":4},\"31\":{\"eventID\":66,\"flo\":0,\"sceneID\":8,\"type\":2,\"x\":4,\"xyID\":33,\"y\":5},\"32\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":4,\"xyID\":39,\"y\":6},\"33\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":15,\"x\":4,\"xyID\":45,\"y\":7},\"34\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":4,\"xyID\":51,\"y\":8},\"35\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":4,\"xyID\":57,\"y\":9},\"36\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":5,\"xyID\":10,\"y\":1},\"37\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":15,\"x\":5,\"xyID\":16,\"y\":2},\"38\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":5,\"xyID\":22,\"y\":3},\"39\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":5,\"xyID\":28,\"y\":4},\"4\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":1,\"xyID\":30,\"y\":5},\"40\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":5,\"xyID\":34,\"y\":5},\"41\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":5,\"xyID\":40,\"y\":6},\"42\":{\"eventID\":8000,\"flo\":0,\"sceneID\":8,\"type\":8,\"x\":5,\"xyID\":46,\"y\":7},\"43\":{\"eventID\":66,\"flo\":0,\"sceneID\":8,\"type\":2,\"x\":5,\"xyID\":52,\"y\":8},\"44\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":5,\"xyID\":58,\"y\":9},\"45\":{\"eventID\":5,\"flo\":0,\"sceneID\":8,\"type\":5,\"x\":6,\"xyID\":11,\"y\":1},\"46\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":6,\"xyID\":17,\"y\":2},\"47\":{\"eventID\":10,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":6,\"xyID\":23,\"y\":3},\"48\":{\"eventID\":1,\"flo\":0,\"sceneID\":8,\"type\":15,\"x\":6,\"xyID\":29,\"y\":4},\"49\":{\"eventID\":66,\"flo\":0,\"sceneID\":8,\"type\":2,\"x\":6,\"xyID\":35,\"y\":5},\"5\":{\"eventID\":1,\"flo\":0,\"sceneID\":8,\"type\":15,\"x\":1,\"xyID\":36,\"y\":6},\"50\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":6,\"xyID\":41,\"y\":6},\"51\":{\"eventID\":1,\"flo\":0,\"sceneID\":8,\"type\":15,\"x\":6,\"xyID\":47,\"y\":7},\"52\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":6,\"xyID\":53,\"y\":8},\"53\":{\"eventID\":1,\"flo\":0,\"sceneID\":8,\"type\":15,\"x\":6,\"xyID\":59,\"y\":9},\"6\":{\"eventID\":66,\"flo\":0,\"sceneID\":8,\"type\":2,\"x\":1,\"xyID\":42,\"y\":7},\"7\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":1,\"xyID\":48,\"y\":8},\"8\":{\"eventID\":6,\"flo\":0,\"sceneID\":8,\"type\":4,\"x\":1,\"xyID\":54,\"y\":9},\"9\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":2,\"xyID\":7,\"y\":1}},\"firedEventCell\":[{\"x\":4,\"y\":3}],\"lastUpdateStepNumberTime\":1456304785,\"maxFloor\":1,\"pets\":{\"0\":{\"hp\":2043,\"objID\":1},\"1\":{\"hp\":112,\"objID\":10},\"10\":{\"hp\":522,\"objID\":19},\"11\":{\"hp\":548,\"objID\":2},\"12\":{\"hp\":812,\"objID\":20},\"13\":{\"hp\":719,\"objID\":21},\"14\":{\"hp\":155,\"objID\":22},\"15\":{\"hp\":1188,\"objID\":23},\"16\":{\"hp\":540,\"objID\":24},\"17\":{\"hp\":530,\"objID\":25},\"18\":{\"hp\":171,\"objID\":26},\"19\":{\"hp\":537,\"objID\":27},\"2\":{\"hp\":112,\"objID\":11},\"20\":{\"hp\":203,\"objID\":28},\"21\":{\"hp\":203,\"objID\":29},\"22\":{\"hp\":370,\"objID\":3},\"23\":{\"hp\":441,\"objID\":30},\"24\":{\"hp\":171,\"objID\":31},\"25\":{\"hp\":116,\"objID\":32},\"26\":{\"hp\":330,\"objID\":4},\"27\":{\"hp\":525,\"objID\":5},\"28\":{\"hp\":296,\"objID\":6},\"29\":{\"hp\":267,\"objID\":7},\"3\":{\"hp\":187,\"objID\":12},\"30\":{\"hp\":307,\"objID\":8},\"31\":{\"hp\":187,\"objID\":9},\"4\":{\"hp\":100,\"objID\":13},\"5\":{\"hp\":187,\"objID\":14},\"6\":{\"hp\":171,\"objID\":15},\"7\":{\"hp\":181,\"objID\":16},\"8\":{\"hp\":649,\"objID\":17},\"9\":{\"hp\":522,\"objID\":18}},\"pickupItem\":[{\"itemID\":1}],\"points\":0,\"recordingPoint\":1,\"resetCount\":0,\"resetTime\":1456304785,\"stepNumber\":50}"
        LostTowerMgr.setLostTowerData(res.lostTowerData)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETLOSTTOWERDATA_ACK)
    return res.code

end

function LostTowerProcess.onGC_resetData_Ack(msg)

    local res = Proto.parseP_GC_resetData_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_resetData_Ack")
    print("GC_resetData_Ack", res.code)
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_RESETDATA_ACK)
    return res.code

end

function LostTowerProcess.onGC_moveNewCell_Ack(msg)

    local res = Proto.parseP_GC_moveNewCell_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_moveNewCell_Ack")
    print("GC_moveNewCell_Ack", res.code)
    if (Proto.Error.ERROR_OK == res.code) then
        if SceneMgr.currentScene == "LostTowerScene" and LostTowerMgr.newCells[1] then
            LostTowerMgr.movedCells[LostTowerMgr.newCells[1]] = true
            table.remove(LostTowerMgr.newCells,1)

            LostTowerInfo.refreshServerTime()
            LtExBufferMgr.updateBuffList()

            local id = LostTowerMgr.newCells[1]
            if id and LostTowerMgr.canMove(id) then
                OvertimeListener.cancel(string.upper("GC_MOVENEWCELL_ACK"), true)
                local _col, _row = LtMapOption.convertToCoord(id)
                NetInterface.send("GC_MOVENEWCELL_ACK", function()
                    local LostTowerSend = require("src/Net/Send/LostTowerSend.lua")
                    LostTowerSend.sendCG_moveNewCell_Req({ x=_row, y=_col, })
                end, function()
                end,function(code)
                    StandardTipsMgr.show(1, "GC_MOVENEWCELL_ACK:Error code --",code)
                end)
            else
                LostTowerMgr.newCells  = {}
                LostTowerMgr.firstSend = true
            end
        else
            print("不在千层塔中，或者移动队列已空")
        end
    else 
        local id = SearchingMgr.playerLastPosition
        if id then    
            local x, y = SearchingUIMgr.getBlockNode(id):getPosition()
            LtPlayerMgr.playerNode:setPosition(x, y-12)
            SearchingMgr.playerCurrPosition = id
            
            -- LostTowerUIMgr.scrollMapTo(id,0.25)
            local scrollview = CSResourceMgr.getNodeByName(LostTowerUIMgr.centerResName,"fog")
            DungeonMapMgr.scrollMapWithCellID(scrollview, id)
            
            LostTowerMgr.stepNumber = LostTowerMgr.stepNumber + 1
            LostTowerUIMgr.updateStepNumber(LostTowerMgr.getStepNumber())
            
            LostTowerMgr.newCells  = {}
            LostTowerMgr.firstSend = true
            
            SearchingMgr.canMove = false
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_MOVENEWCELL_ACK)
    return res.code

end

function LostTowerProcess.onGC_ChangeFloor_Ack(msg)

    local res = Proto.parseP_GC_ChangeFloor_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ChangeFloor_Ack")
    print("GC_ChangeFloor_Ack",res.code)
    print(res.events)
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CHANGEFLOOR_ACK)
    return res.code

end

function LostTowerProcess.onGC_fireEventCell_Ack(msg)

    local res = Proto.parseP_GC_fireEventCell_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_fireEventCell_Ack")
    print("GC_fireEventCell_Ack",res.code)
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FIREEVENTCELL_ACK)
    return res.code

end

function LostTowerProcess.onGC_EventAward_Ntf(msg)

    local res = Proto.parseP_GC_EventAward_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_EventAward_Ntf")
    for k,v in pairs(res.awards) do
        print(k,v)
    end
    if SceneMgr.currentScene == "LostTowerScene" then
        GameAudio.playUISound("itemGet")
        LtFuncMgr.pickEffect(LtFuncMgr.FireBlock, res.awards)
        AwardsListMgr.show(SceneMgr.getRunningScene, res.awards)
    elseif SceneMgr.currentScene == "BattleScene" then
        LostTowerMgr.battleAwards = res.awards
    end
    
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_EVENTAWARD_NTF)
    return res.code

end

function LostTowerProcess.onGC_RandomEvent_Ntf(msg)

    local res = Proto.parseP_GC_RandomEvent_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_RandomEvent_Ntf")
    print("event",res.type,res.eventID)
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_RANDOMEVENT_NTF)
    return res.code

end

function LostTowerProcess.onGC_changeReadyPet_Ack(msg)

    local res = Proto.parseP_GC_changeReadyPet_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_changeReadyPet_Ack")
    print("GC_changeReadyPet_Ack", res.code)
    for i=1, #LtPetsMgr.LtArmy do
        print(">>>>>>>>>>>>>>   army", LtPetsMgr.LtArmy[i])
    end
    for i=1, #LtPetsMgr.LtHelpArmy do
        print(">>>>>>>>>>>>>>   LtHelpArmy", LtPetsMgr.LtHelpArmy[i])
    end
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CHANGEREADYPET_ACK)
    return res.code

end

function LostTowerProcess.onGC_LostTowerPointChange_Ntf(msg)

    local res = Proto.parseP_GC_LostTowerPointChange_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_LostTowerPointChange_Ntf")
    
    print("GC_LostTowerPointChange_Ntf", res.points)
    if SceneMgr.currentScene == "BattleScene" then
        LostTowerMgr.previousPoint = LostTowerMgr.points
        LostTowerMgr.points        = res.points
    elseif SceneMgr.currentScene == "LostTowerScene" then
        LostTowerMgr.previousPoint = -1
        LostTowerMgr.points        = res.points
        LostTowerUIMgr.updatePoints(LostTowerMgr.points)
    end
    
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_LOSTTOWERPOINTCHANGE_NTF)
    return res.code

end

function LostTowerProcess.onGC_RecoverState_Ack(msg)

    local res = Proto.parseP_GC_RecoverState_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_RecoverState_Ack")
    print("GC_RecoverState_Ack", res.code)
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_RECOVERSTATE_ACK)
    return res.code

end

function LostTowerProcess.onGC_TransferFloor_Ack(msg)

    local res = Proto.parseP_GC_TransferFloor_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_TransferFloor_Ack")
    print("GC_TransferFloor_Ack", res.code)
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_TRANSFERFLOOR_ACK)
    return res.code

end

function LostTowerProcess.onGC_MoveObstacle_Ack(msg)

    local res = Proto.parseP_GC_MoveObstacle_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_MoveObstacle_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_MOVEOBSTACLE_ACK)
    return res.code

end

function LostTowerProcess.onGC_onTrap_Ack(msg)

    local res = Proto.parseP_GC_onTrap_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_onTrap_Ack")
    print("GC_onTrap_Ack",res.code)
    if (Proto.Error.ERROR_OK == res.code) then
        local pets = {}

        for k,v in pairs(res.pets) do
            local petInfo = PokemonInfo.getPetInfoByObjID(v.objID)
            local percent = v.hp
            local _hp = math.floor(percent * petInfo.hpmax / 10000)
            table.insert(pets, {objID = v.objID, hp = _hp})
        end
    
        LtPetsMgr.updateArmyNodes(pets)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_ONTRAP_ACK)
    return res.code

end

function LostTowerProcess.onGC_LostTowerPVPBattleEnd_Ack(msg)

    local res = Proto.parseP_GC_LostTowerPVPBattleEnd_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_LostTowerPVPBattleEnd_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_LOSTTOWERPVPBATTLEEND_ACK)
    return res.code

end

function LostTowerProcess.onGC_QueryFloorRank_Ack(msg)

    local res = Proto.parseP_GC_QueryFloorRank_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_QueryFloorRank_Ack")
    print("GC_QueryFloorRank_Ack",res.code)
    if (Proto.Error.ERROR_OK == res.code) then
        print(res.rankInfo)
        LostTowerInfo.setRankingList(res.rankInfo)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_QUERYFLOORRANK_ACK)
    return res.code

end

function LostTowerProcess.onGC_QueryPointRank_Ack(msg)

    local res = Proto.parseP_GC_QueryPointRank_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_QueryPointRank_Ack")
    print("GC_QueryPointRank_Ack",res.code)
    if (Proto.Error.ERROR_OK == res.code) then
        print(res.rankInfo)
        LostTowerInfo.setRankingList(res.rankInfo, 2)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_QUERYPOINTRANK_ACK)
    return res.code

end

function LostTowerProcess.onGC_TransferCell_Ntf(msg)

    local res = Proto.parseP_GC_TransferCell_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_TransferCell_Ntf")
    
    print("GC_TransferCell_Ntf",res.x, res.y)
    
    if SceneMgr.isProcessing == true then
        print("场景切换中，千层塔传送效果不执行...")
        return
    end
    
    GameAudio.playUISound("mapGo")
    local row, col = res.x, res.y
    local id = LtMapOption.convertToIndex(col,row)
    SearchingUIMgr.transferPlayerTo(id, 1)
    LtWarFogMgr.refreshWarFog(LostTowerMgr.movedCells, id)
    
    -- LostTowerUIMgr.scrollMapTo(id)
    local scrollview = CSResourceMgr.getNodeByName(LostTowerUIMgr.centerResName,"fog")
    DungeonMapMgr.scrollMapWithCellID(scrollview, id)
    
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_TRANSFERCELL_NTF)
    return res.code

end

function LostTowerProcess.onGC_EnterTransferDoor_Ack(msg)

    local res = Proto.parseP_GC_EnterTransferDoor_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_EnterTransferDoor_Ack")
    print("GC_EnterTransferDoor_Ack", res.code)
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_ENTERTRANSFERDOOR_ACK)
    return res.code

end

function LostTowerProcess.onGC_LostTowerWeekPointChange_Ntf(msg)

    local res = Proto.parseP_GC_LostTowerWeekPointChange_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_LostTowerWeekPointChange_Ntf")
    print("GC_LostTowerWeekPointChange_Ntf", res.points)
    LostTowerMgr.weekMaxPoints = res.points
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_LOSTTOWERWEEKPOINTCHANGE_NTF)
    return res.code

end

function LostTowerProcess.onGC_UseLostTowerItem_Ack(msg)

    local res = Proto.parseP_GC_UseLostTowerItem_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_UseLostTowerItem_Ack")
    print("GC_UseLostTowerItem_Ack",res.code)
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_USELOSTTOWERITEM_ACK)
    return res.code

end

function LostTowerProcess.onGC_LostTowerItemUpdate_Ntf(msg)

    local res = Proto.parseP_GC_LostTowerItemUpdate_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_LostTowerItemUpdate_Ntf")
    print("GC_LostTowerItemUpdate_Ntf")
    for k,v in pairs(res.items) do
        print(k,v)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_LOSTTOWERITEMUPDATE_NTF)
    return res.code

end

function LostTowerProcess.onGC_LostTowerStepNumberUpdate_Ntf(msg)

    local res = Proto.parseP_GC_LostTowerStepNumberUpdate_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_LostTowerStepNumberUpdate_Ntf")
    
    print("setpNumber",res.setpNumber)
    print("lastUpdateTime",res.lastUpdateTime)

    LostTowerMgr.previousStepNum = LostTowerMgr.getStepNumber()
    
    LostTowerMgr.stepNumber = res.setpNumber
    LostTowerMgr.stepRefreshTime = res.lastUpdateTime
    LostTowerMgr.stepAdded = 0
    
    LostTowerUIMgr.updateStepNumber(LostTowerMgr.getStepNumber())
    
    if LostTowerMgr.stepRefreshTime ~= 0 then
        LostTowerInfo.refreshServerTime()
    end
    
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_LOSTTOWERSTEPNUMBERUPDATE_NTF)
    return res.code

end

function LostTowerProcess.onGC_RecoverStepNumber_Ack(msg)

    local res = Proto.parseP_GC_RecoverStepNumber_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_RecoverStepNumber_Ack")
    print("GC_RecoverStepNumber_Ack",res.code)
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_RECOVERSTEPNUMBER_ACK)
    return res.code

end

function LostTowerProcess.onGC_AddLostTowerPets_Ntf(msg)

    local res = Proto.parseP_GC_AddLostTowerPets_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_AddLostTowerPets_Ntf")
    print("GC_AddLostTowerPets_Ntf",res.objID,res.hp)
    LtPetsMgr.LtPets[res.objID] = res.hp
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_ADDLOSTTOWERPETS_NTF)
    return res.code

end

function LostTowerProcess.onGC_LostTowerEvents_Ntf(msg)

    local res = Proto.parseP_GC_LostTowerEvents_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_LostTowerEvents_Ntf")
    
    local cjson = require("cjson")
    
    for k,v in pairs(res.events) do
        print("GC_LostTowerEvents_Ntf", k, v)
        
        local event = cjson.decode(v)
        table.insert(LostTowerMgr.LtMapData, event)
    end
    
    -- make sure that all ntf are recieved
    if #LostTowerMgr.LtMapData == LostTowerMgr.eventNumber then
        local maxRow, maxCol = 1, 1
        for k, v in pairs(LostTowerMgr.LtMapData) do
            if v.x > maxRow then maxRow = v.x end
            if v.y > maxCol then maxCol = v.y end
        end

        LtMapOption.setMapSize(maxRow, maxCol)
        
        LostTowerMgr.setMovedCells(LostTowerMgr.movedCellString)
        LostTowerMgr.movedCellString = nil

        LostTowerMgr.setFiredEvent(LostTowerMgr.firedEventCellString)
        LostTowerMgr.firedEventCellString = nil
        
        if LostTowerMgr.enterFunc then
            LostTowerMgr.enterFunc()
            LostTowerMgr.enterFunc = nil
        end
    end
    
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_LOSTTOWEREVENTS_NTF)
    return res.code

end

function LostTowerProcess.onGC_MoneyOpenChest_Ack(msg)

    local res = Proto.parseP_GC_MoneyOpenChest_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_MoneyOpenChest_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_MONEYOPENCHEST_ACK)
    return res.code

end

return LostTowerProcess
