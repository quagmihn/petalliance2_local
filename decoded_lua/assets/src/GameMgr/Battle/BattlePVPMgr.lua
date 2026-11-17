local BattlePVPMgr          = {} 
local scienceData_B         = {}
BattlePVPMgr.data           = {}
BattlePVPMgr.dataIndex      = 1
BattlePVPMgr.sendIsCommand  = false

BattlePVPMgr.mIsPVPBattle       = false
BattlePVPMgr.mPVPIsChallenger   = true

PVP_NO_ARENA  = 0
PVP_YES_ARENA = 1

BattlePVPMgr.isPVPArenaBattle = PVP_NO_ARENA
BattlePVPMgr.isPVPArenaOver   = false

local mbattleID = nil
local mserverID = nil
local mRoundIndex = nil
local mBattleSceneCreated = {} 
local scheduler         = require(cc.PACKAGE_NAME..".scheduler") 
local PVPDailog         = require("src.GameMgr.Battle.UI.PVPDailog") 
local handle         = nil
local opponentInfo   = nil
local pvpArenaPoints = nil
local pvpArenaGrade  = nil
local everyArenaPoints = nil
local everyArenaGrade  = nil

function BattlePVPMgr.cleanAfterReplaceScene()
    everyArenaPoints = nil
    everyArenaGrade  = nil
    pvpArenaPoints   = nil
    pvpArenaGrade    = nil
    BattlePVPMgr.isPVPArenaBattle = PVP_NO_ARENA
    BattleMapMgr.afterCleanPVPInfo()
    scienceData_B         = {}
    BattlePVPMgr.endCalcTime()
end

function BattlePVPMgr.setScienceDataB(data) 
    scienceData_B = data
    scienceData_B.addToBattle = true
end

function BattlePVPMgr.getScienceDataB()
    return scienceData_B
end

function BattlePVPMgr.ArenaWinShow()
    
    BattlePVPMgr.startCalcTime(function()
        print("战斗结束 查找 战斗结果数据")
        
        if BattlePVPMgr.geteveryArenaPoints() then
            BattlePVPMgr.endCalcTime()
            local Info = {}
            Info[TEAM_A] = {}
            Info[TEAM_B] = {}
            if BattlePVPMgr.geteveryArenaPoints() > 0 then
                BattleCCSB.createSummary(0,Info,nil,nil,nil,1,false)
            else
                BattleCCSB.createSummary(0,Info,nil,nil,nil,0,false)
            end
        end

        if true == BattleCCSB.MENU.isOut then
            BattlePVPMgr.endCalcTime()
            return 
        end

    end,0.05)

end

function BattlePVPMgr.ArenaLoseShow()

    BattlePVPMgr.startCalcTime(function()
        print("战斗结束 查找 战斗结果数据")
        
        if BattlePVPMgr.geteveryArenaPoints() then
            BattlePVPMgr.endCalcTime()
            local Info = {}
            Info[TEAM_A] = {}
            Info[TEAM_B] = {}
            if BattlePVPMgr.geteveryArenaPoints() > 0 then
                BattleCCSB.createSummary(0,Info,nil,nil,nil,1,false)
            else
                BattleCCSB.createSummary(0,Info,nil,nil,nil,0,false)
            end
        end

        if true == BattleCCSB.MENU.isOut then
            BattlePVPMgr.endCalcTime()
            return 
        end

    end,0.05)
end

function BattlePVPMgr.seteveryArenaPoints(Points)
    everyArenaPoints = Points
end

function BattlePVPMgr.geteveryArenaPoints()
    return everyArenaPoints
end

function BattlePVPMgr.seteveryArenaGrade(Grade) 
    everyArenaGrade = Grade
end

function BattlePVPMgr.geteveryArenaGrade()
    return everyArenaGrade
end

function BattlePVPMgr.getpvpArenaPoints()
    return pvpArenaPoints
end

function BattlePVPMgr.setpvpArenaPoints(Points)
    pvpArenaPoints = Points
end

function BattlePVPMgr.setpvpArenaGrade(grade)
    pvpArenaGrade = grade
end

function BattlePVPMgr.getpvpArenaGrade()
    return pvpArenaGrade
end

function BattlePVPMgr.setOpponentContent(playerInfo)
    opponentInfo = playerInfo
end

function BattlePVPMgr.getOpponentDetail()
    return opponentInfo
end

function BattlePVPMgr.getBattleID()
    return mbattleID
end

function BattlePVPMgr.setBattleID(id)
    mbattleID = id
end

function BattlePVPMgr.getserverID()
    return mserverID
end

function BattlePVPMgr.setserverID(id)
    mserverID = id
end

function BattlePVPMgr.checkPVPRecords()
    local time_count = 0
    handle = scheduler.scheduleGlobal(function()

            time_count = time_count + 1
            print("checkPVPRecords............",time_count)
            if #BattleCotroller.getCurrentRecords() > 0 then
                scheduler.unscheduleGlobal(handle)
                return
            end
            if time_count == 10 then
                scheduler.unscheduleGlobal(handle) 
                DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,2,"pvp断连请退出",function() 
                        BattleUIMgr.cleanUIMgr() 
                        BattleMapMgr.cleanPVPInfo()
                        BattlePVPMgr.cleanPVPInfo()         
                        SceneMgr.replaceScene(SceneMgr.getRunningScene, SceneMgr.previousScene) 
                        -- DialogBoxMgr.hideSmallDialogBox(tag) 
                    end,function()
                        -- DialogBoxMgr.hideSmallDialogBox(tag)
                    end,nil,false)
            end
        end,1.0)
end

function BattlePVPMgr.checkCopyRecords()
    local time_count = 0
    local speed = false
    BattlePVPMgr.endCalcTime()
    BattlePVPMgr.isGetRecords = true
    if not BattleCotroller.isRecordContent() then
        handle = scheduler.scheduleGlobal(function()
            time_count = time_count + 0.05
            print("checkCopyRecords...查到次数为.........",time_count)
            print("1111",mserverID,mbattleID,BattlePVPMgr.dataIndex) 
            if 26 == math.floor(time_count%27) and true == BattlePVPMgr.isGetRecords then
                time_count = 27
                -- BattlePVPMgr.checkPVPBattle() 
                speed = true
                BattlePVPMgr.getPVPRecords()
            end
            if BattleCotroller.isRecordContent() or not BattleUIMgr.showSkillTip then
                if true == speed then
                    cc.Director:getInstance():getScheduler():setTimeScale(8.0)
                end
                scheduler.unscheduleGlobal(handle)
                return
            end 
            

            if true == BattleCCSB.MENU.isOut then 
                if true == BattlePVPMgr.mIsPVPBattle then
                    PVPDailog.waitOpponentHide()
                end
                scheduler.unscheduleGlobal(handle) 
                print("退出战斗")
            end 
        end,0.05)
    end

end

function BattlePVPMgr.getPVPRecords()
    -- local PVPSend = require("src.Net.Send.PVPSend")
    -- PVPSend.sendCG_GetPVPRecords_Req({serverID = mserverID,
    --     battleID = mbattleID,startIndex = BattlePVPMgr.dataIndex})
    -- BattlePVPMgr.endCalcTime()
    if nil == mbattleID then
        -- BattlePVPMgr.checkPVPBattle() 
        print("战斗id为nil 取消获取pvp记录")
        return
    end
    BattlePVPMgr.isGetRecords = false
    NetInterface.sendWithBlock("GC_GetPVPRecords_Ack", function()
        local PVPSend = require("src.Net.Send.PVPSend")
        print("GC_GetPVPRecords_Ack~~~~",mserverID,mbattleID,BattlePVPMgr.dataIndex)
        PVPSend.sendCG_GetPVPRecords_Req({serverID = mserverID,
            battleID = mbattleID,startIndex = BattlePVPMgr.dataIndex})
        end, function()
            BattlePVPMgr.isGetRecords = true
            print("GC_GetPVPRecords_Ack发送成功") 
        end, function(code)
            TipsMgr.showError(nil, code)
        end)
end

function BattlePVPMgr.startCalcTime(func,time)
    BattlePVPMgr.endCalcTime()
    handle = scheduler.scheduleGlobal(function()
            if func then
                func() 
            end
        end,time)
end

function BattlePVPMgr.endCalcTime()
    if handle then 
        scheduler.unscheduleGlobal(handle)
        handle = nil
    end
end

function BattlePVPMgr.sendBattleCommand(sendRoundIndex,sendSkillIndex,sendpetID)
    BattlePVPMgr.sendIsCommand  = true 
    local PVPSend = require("src.Net.Send.PVPSend")
    print("BattlePVPMgr.getBattleID....",mbattleID)
    print("BattlePVPMgr.mserverID....",mserverID)
    if not mbattleID then
        return  
    end
    PVPSend.sendCG_PVPBattleCommand_Req({battleID = BattlePVPMgr.getBattleID(),
        roundIndex = sendRoundIndex,skillIndex = sendSkillIndex,petID = sendpetID,serverID = mserverID}) 
    BattleUIMgr.setStopAction(false)  
    -- BattlePVPMgr.checkPVPRecords()
    BattleCotroller.findPVPRecord() 
    PVPDailog.waitOpponentShow()

end

function BattlePVPMgr.sendLeaveBattleCommand(callback)
    if not mbattleID then
        print("mbattleID  为空 停掉")
        mbattleID = 0
        BattlePVPMgr.endCalcTime()
        BattleUIMgr.quiteBattle()
        return
    end
    if not mserverID then 
        mserverID = 0
    end 
    NetInterface.sendWithBlock("GC_LEAVEPVP_ACK", function()
            local pvpSend = require("src.Net.Send.PVPSend") 
            pvpSend.sendCG_LeavePVP_Req({battleID = mbattleID,serverID = mserverID}) -- 744594 
        end, function() 
            mbattleID = nil
            mserverID = nil
            if callback then
                callback()
            end
        end, function(code)
            TipsMgr.showError(nil, code)
        end)
end

function BattlePVPMgr.checkPlayerIsinBattle(callBack)
    NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
                local LoginSend = require("src.Net.Send.LoginSend")
                LoginSend.sendCG_GetCharacterValues_Req({"pvpBattleID","pvpServerID"})
            end, function()
                print("GC_GetCharacterValues_Ack...pvpBattleID...",mbattleID)
                print("GC_GetCharacterValues_Ack...pvpServerID...",mserverID)  
                if mbattleID then
                    PVPDailog.hide()  
                    BattlePVPMgr.sendLeaveBattleCommand(callBack)  
                    
                else
                    if callBack then 
                        callBack()
                    end
                end
            end, function(code)
                
                TipsMgr.showError(nil, code)
            end)
end

function BattlePVPMgr.sendCG_StartPVP_Req(CharID)
    local function sendPVP()
        NetInterface.sendWithBlock("GC_STARTPVP_ACK", function()
            local pvpSend = require("src.Net.Send.PVPSend") 
            pvpSend.sendCG_StartPVP_Req({bechallengeCharID = CharID}) -- 744594 
        end, function()
            print("GC_STARTPVP_ACK ok.......................................")
        end, function(code)
            NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
                local LoginSend = require("src.Net.Send.LoginSend")
                LoginSend.sendCG_GetCharacterValues_Req({"pvpBattleID","pvpServerID"})
            end, function()
                print("GC_GetCharacterValues_Ack...pvpBattleID...",mbattleID) 
                print("GC_GetCharacterValues_Ack...pvpServerID...",mserverID)  
                if mbattleID then
                    PVPDailog.hide()  
                    BattlePVPMgr.sendLeaveBattleCommand()  
                    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,1,"wifiPK1",function()
                            end,nil,nil,false)
                end
            end, function(code)
                 
                TipsMgr.showError(nil, code)
            end)
            TipsMgr.showError(nil, code)
        end)
    end
    NetInterface.sendWithBlock("GC_GETFRIENDDETAIL_ACK", function()
            local ChatUserSend = require("src.Net.Send.ChatUserSend")
            ChatUserSend.sendCG_GetFriendDetail_Req({friendID = CharID}) -- 744594 
        end, function()
            local opponentDetail =  BattlePVPMgr.getOpponentDetail()  
            
            PVPDailog.show(opponentDetail) 
            print("sendWithBlock   GC_GetFriendDetail_Ack.....",sz_T2S(opponentDetail))
            sendPVP()
        end, function(code)
            TipsMgr.showError(nil, code)
        end)
    
end

function BattlePVPMgr.setRoundIndex(roundIndex) 
    mRoundIndex = roundIndex 
end

function BattlePVPMgr.onCreateBattleID(battleID)
    mbattleID = battleID
end


function BattlePVPMgr.cleanPVPInfo()  
    mbattleID = nil
    mRoundIndex = nil
    mserverID = nil
    mBattleSceneCreated     = {} 
    BattlePVPMgr.data       = {}
    BattlePVPMgr.dataIndex  = 1
    BattlePVPMgr.sendIsCommand  =false
    
end

function BattlePVPMgr.onRecvNewBattleID(battleID)
    if mbattleID == battleID then
        return 
    end
    mbattleID = battleID
    printFileLog("mbattleID" .. mbattleID)
end

function BattlePVPMgr.onBattleSceneCreated(battleID)
    mBattleSceneCreated[battleID] = true
end

function BattlePVPMgr.isBattleSceneCreated(battleID)
    if mBattleSceneCreated[battleID] == nil then
        return false
    end
    return true
end

function BattlePVPMgr.getArmPets()
    local objIDs =  PokemonInfo.getPetArmy(1)
    local pets   =  {}
    for key,var in pairs(objIDs) do
        table.insert(pets,PokemonInfo.getPetInfoByObjID(var))
    end
    return pets
end

function BattlePVPMgr.checkPVPBattle()  
    if BattlePVPMgr.mIsPVPBattle then
        if handle then
            scheduler.unscheduleGlobal(handle) 
            handle = nil
        end
        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,1,"wifiPK5",function()
                BattleUIMgr.quiteBattle()
            end,function() BattleUIMgr.quiteBattle() end,nil,false)
    end
end

function BattlePVPMgr.setPVPInfomation(res) 
    local PVPSend = require("src.Net.Send.PVPSend.lua")
    local scienceData_A  = clone(ScienceInfo.getScienceAttrsTable())
    if res.battleStatus == Proto.BattleReady then
        printFileLog("@@@@battlestatus BattleReady") 
        printFileLog("@@@@CharInfo.getCharID()"..CharInfo.getCharID()) 
        printFileLog("@@@@bechallengeCharID"..res.bechallengeCharID )
        printFileLog("@@@@challengerID"..res.challengerID )  
        if res.challengerID == CharInfo.getCharID() or res.bechallengeCharID == CharInfo.getCharID() then
            printFileLog("@@@@battlestatus BattleReady1")  
            if table.getn(res.challengerPets) == 0 then 
                printFileLog("@@@@battlestatus BattleReady2") 
                local pets = clone(BattlePVPMgr.getArmPets())
                local helpPets = PokemonInfo.getActiveHelperPets()

                for key,var in pairs(pets) do
                    if var.level >= ScienceInfo.getPetAttrLockLevel() then
                        pets[key].hpmax = pets[key].hpmax - (scienceData_A[Proto.AT_HP] or 0)
                    end
                end
                printFileLog("petsaddBasicMenu~~~"..sz_T2S(pets))  
                local cjson     = require("cjson")
                local petjsons = {}
                local helpjsons = {}

                for key,var in pairs(pets) do
                    table.insert(petjsons,cjson.encode(var))
                end

                for key,var in pairs(helpPets) do
                    table.insert(helpjsons,cjson.encode(var))
                end

                PVPSend.sendCG_ReadyPVP_Req({battleID = res.battleID,pets = petjsons,serverID = res.serverID,helperPets=helpjsons})
            end 
        elseif res.bechallengeCharID == CharInfo.getCharID() then 
            printFileLog("@@@@battlestatus BattleReady3") 
            if table.getn(res.bechallengePets) == 0 then
                printFileLog("@@@@battlestatus BattleReady4") 
                
                local pets = clone(BattlePVPMgr.getArmPets())
                local helpPets = PokemonInfo.getActiveHelperPets()
                printFileLog("petsaddBasicMenu~~~"..sz_T2S(pets)) 
                local cjson     = require("cjson")
                local petjsons  = {}
                local helpjsons = {} 
                for key,var in pairs(pets) do
                    if var.level >= ScienceInfo.getPetAttrLockLevel() then
                        pets[key].hpmax = pets[key].hpmax - (scienceData_A[Proto.AT_HP] or 0)
                    end
                end
                for key,var in pairs(pets) do
                    table.insert(petjsons,cjson.encode(var))
                end

                for key,var in pairs(helpPets) do
                    table.insert(helpjsons,cjson.encode(var))
                end

                PVPSend.sendCG_ReadyPVP_Req({battleID = res.battleID,pets = petjsons,serverID = res.serverID,helperPets=helpjsons})
--                BattleMapMgr.setEnemyPets(pets)               
            end
        else
            printFileLog("@@@@battlestatus BattleReady5")  
        end
    elseif res.battleStatus == Proto.BattleReadyOK or res.battleStatus == Proto.BattleLoading then 
        if BattlePVPMgr.isBattleSceneCreated(res.battleID) == false then
            BattlePVPMgr.onBattleSceneCreated(res.battleID) 
            printFileLog("@@@@battlestatus BattleReadyOK")
            local challgPetsTbl = {}  
            local challengerHelperPets = {}
            local bechallPetsTbl        = {}  
            local bechallengeHelperPets    = {}
            local cjson = require("cjson") 
            
            for key, var in pairs(res.challengerPets) do 
                local tbl = {}
               
                printFileLog("挑战者........",type(var))
                if type(var) == "string" then
                    printFileLog("挑战者........",var) 
                    tbl = cjson.decode(var)
                else
                    tbl = clone(var)
                end
                table.insert(challgPetsTbl,tbl)
                printFileLog("挑战者的宠......."..sz_T2S(tbl)) 
            end

            for key,var in pairs(res.challengerHelperPets) do
                local tbl = {}
               
                printFileLog("挑战者help........",type(var))
                if type(var) == "string" then
                    tbl = cjson.decode(var)
                else
                    tbl = clone(var)
                end
                table.insert(challengerHelperPets,tbl)
                printFileLog("挑战者的宠......."..sz_T2S(tbl)) 
            end

            for key, var in pairs(res.bechallengePets) do
                local tbl = {}
                printFileLog("守战者........"..type(var)) 
                
                if type(var) == "string" then
                    printFileLog("守战者........",var)
                    tbl = cjson.decode(var)
                else
                    tbl = clone(var)
                end
                table.insert(bechallPetsTbl,tbl) 
            end

            for key, var in pairs(res.bechallengeHelperPets) do
                local tbl = {}
                printFileLog("守战者help........"..type(var)) 
                
                if type(var) == "string" then
                    printFileLog("守战者........",var)
                    tbl = cjson.decode(var)
                else
                    tbl = clone(var)
                end
                table.insert(bechallengeHelperPets,tbl) 
            end
            BattlePVPMgr.sendIsCommand = true

            pvpArenaPoints                = ArenaInfo.getPVPArenaPoint()
            pvpArenaGrade                 = ArenaInfo.getPVPArenaLevel() 
            
            if res.challengerID == CharInfo.getCharID() then  

                local challengerOtherParam = cjson.decode(res.challengerOtherParam)
                local bechallengeOtherParam = cjson.decode(res.bechallengeOtherParam)
                BattlePVPMgr.mPVPIsChallenger = true    
                local myPets = {}
                myPets[OUTPETS]     = challgPetsTbl
                myPets[INPETS]      = challengerHelperPets
                local hisPets = {}
                hisPets[OUTPETS]    = bechallPetsTbl
                hisPets[INPETS]     = bechallengeHelperPets
                local name = ""
                if res.battleStatus == Proto.BattleLoading then
                    name = bechallengeOtherParam.nickname
                    if not name then
                        name = bechallengeOtherParam.name
                    end
                else
                    name = PVPDailog.getOpponentNickName()
                end
                BattleCotroller.setRecordName(CharInfo.getNickName(), name)
                BattleMapMgr.setBattleCallback(function(detail)
                    if detail.result == PLAYER_WIN then 
                        print("PVP完成传出世界窗口") 
                        TownChatMgr.sendBattleEndResult(CharInfo.getNickName(),name)
                    end
                end)
                scienceData_B = {}
                if bechallengeOtherParam and bechallengeOtherParam.science and bechallengeOtherParam.science.data then 
                    for key,var in pairs(bechallengeOtherParam.science.data) do
                        scienceData_B[var[1]] = ScienceInfo.getSkillEffect(var[1], var[3], var[2])
                    end
                end
                BattlePVPMgr.setScienceDataB(scienceData_B) 
                -- for key,var in pairs(myPets[OUTPETS]) do
                --     myPets[OUTPETS][key].hpmax = myPets[OUTPETS][key].hpmax + (scienceData_A[Proto.AT_HP] or 0)
                -- end
                -- for key,var in pairs(hisPets[OUTPETS]) do
                --     hisPets[OUTPETS][key].hpmax = hisPets[OUTPETS][key].hpmax + (scienceData_B[Proto.AT_HP] or 0)
                -- end 
                BattleMapMgr.setEnemyPets(hisPets)
                BattleMapMgr.setMyPets(myPets)
            elseif res.bechallengeCharID == CharInfo.getCharID() then 
                local challengerOtherParam = cjson.decode(res.challengerOtherParam)
                local bechallengeOtherParam = cjson.decode(res.bechallengeOtherParam)
                
                BattlePVPMgr.mPVPIsChallenger = false 
                local myPets = {}
                myPets[OUTPETS]     =  bechallPetsTbl
                myPets[INPETS]      =  bechallengeHelperPets

                local hisPets = {}
                hisPets[OUTPETS]    = challgPetsTbl
                hisPets[INPETS]     = challengerHelperPets
                
                if res.battleStatus == Proto.BattleLoading then
                    BattleCotroller.setRecordName(CharInfo.getNickName(), challengerOtherParam.nickname)
                end
                scienceData_B = {}
                if challengerOtherParam and challengerOtherParam.science and challengerOtherParam.science.data then 
                    for key,var in pairs(challengerOtherParam.science.data) do
                        scienceData_B[var[1]] = ScienceInfo.getSkillEffect(var[1], var[3], var[2])
                    end
                end 
                BattlePVPMgr.setScienceDataB(scienceData_B)
                -- for key,var in pairs(myPets[OUTPETS]) do
                --     myPets[OUTPETS][key].hpmax = myPets[OUTPETS][key].hpmax + (scienceData_A[Proto.AT_HP] or 0)
                -- end
                -- for key,var in pairs(hisPets[OUTPETS]) do
                --     hisPets[OUTPETS][key].hpmax = hisPets[OUTPETS][key].hpmax + (scienceData_B[Proto.AT_HP] or 0)
                -- end
                BattleMapMgr.setEnemyPets(hisPets) 
                BattleMapMgr.setMyPets(myPets)
            end
            PVPDailog.hide() 
            BattlePVPMgr.mIsPVPBattle = true 
            --SceneMgr.replaceScene(SceneMgr.getRunningScene,"BattleScene")
            if res.battleStatus == Proto.BattleLoading then
                local challengerOtherParam = cjson.decode(res.challengerOtherParam) 
                local bechallengeOtherParam = cjson.decode(res.bechallengeOtherParam)
                local PVPDetail = require("src.GameMgr.Battle.UI.PVPDetail")
                if res.challengerID == CharInfo.getCharID() then
                    local vInfo = bechallengeOtherParam
                    if not vInfo.nickname then
                        vInfo.nickname = vInfo.name
                    end
                    vInfo.point = res.bechallengePoint
                    vInfo.grade = res.bechallengeGrade
                    PVPDetail.show(vInfo)
                elseif res.bechallengeCharID == CharInfo.getCharID() then
                    local vInfo = challengerOtherParam
                    vInfo.point = res.challengerPoint
                    vInfo.grade = res.challengerGrade
                    PVPDetail.show(vInfo)
                end
            else
                SceneMgr.replaceScene(SceneMgr.getRunningScene,"BattleScene")
            end
            BattleMapMgr.setShareBattle()
            BattlePVPMgr.isPVPArenaBattle = res.isPVPArenaBattle
            if BattlePVPMgr.isPVPArenaBattle == PVP_YES_ARENA then 
                BattleGuide.funcs[GUIDE_FINISH] = function()
                    MapSeekerMgr.SeekFunc = function() 
                            ArenaPKViewMgr.show(SceneMgr.getRunningScene)
                        end
                end
            end

            BattlePVPMgr.isPVPArenaOver   = false
            PVPSend.sendCG_PVPBattleStart_Req({battleID = res.battleID,serverID = res.serverID}) 
            mbattleID = res.battleID
            mserverID = res.serverID
        end
    elseif res.battleStatus == Proto.BattleUnReady then
        if res.bechallengeCharID == CharInfo.getCharID() then
            if TeamInfo.getInfo(TeamInfo.KEY_TEAMID) then
                print("当前已经在队伍中，此次队伍邀请不弹。")
                StandardTipsMgr.show(1, "team45")
                return
            end 
            if SceneMgr.currentScene ~= "BattleScene" and 
                SceneMgr.currentScene ~= "SearchingScene" and
                SceneMgr.currentScene ~= "LostTowerScene" and
                SceneMgr.currentScene ~= "BossMapScene" and
                GameGuideMgr.checkIsGuiding() == false then 
                local function joinFunc()
                    local Namestr = res.name 
                    local str=string.gsub(LuaSqlite.getLanguageByKey("wifibattle1"),"<1>",Namestr)
                    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2,str, function()
                        -- if BattlePVPMgr.getBattleID() then
                            PVPSend.sendCG_JoinPVP_Req({battleID = res.battleID,serverID = res.serverID}) 
                        -- end 
                        BattleMapMgr.setShareBattle() 
                        BattleCotroller.setRecordName(CharInfo.getNickName(), Namestr) 
                        BattleMapMgr.setBattleCallback(function(detail)

                                if detail.result == PLAYER_WIN then 
                                    print("PVP完成传出世界窗口")
                                    TownChatMgr.sendBattleEndResult(CharInfo.getNickName(),Namestr)
                                end
                            end)
                        CocosModuleMgr.setScreenTouch(false)
                        SceneMgr.getRunningScene:performWithDelay(function() 
                                CocosModuleMgr.setScreenTouch(true)
                            end, 4.0)
                    end, nil, nil, false) 
                    mserverID = res.serverID
                    mbattleID = res.battleID
                end
                BattlePVPMgr.checkPlayerIsinBattle(joinFunc) 
            end
            
        end
    end
end

return BattlePVPMgr