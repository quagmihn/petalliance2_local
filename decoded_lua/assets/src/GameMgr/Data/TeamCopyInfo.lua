local TeamCopyInfo = {}

local enableMoveCell = true
local enableTriggerGrid = true
local lastMoveCellIndex = 0
local targetMoveCellIndex = 0

function TeamCopyInfo.Init()
    enableMoveCell = true
    enableTriggerGrid = true
    lastMoveCellIndex = 0
    targetMoveCellIndex = 0
end

function TeamCopyInfo.reset()
    enableMoveCell = true
    enableTriggerGrid = true
    lastMoveCellIndex = 0
    targetMoveCellIndex = 0
end

function TeamCopyInfo.EnterTeamCopyMap()
    local TeamSend = require("src.Net.Send.TeamSend")
    
    NetInterface.sendWithBlock("GC_ENTERTEAMDUNGEON_ACK", function()
        print("!!!!!!!!!!!!!!!EnterTeamCopyMap---sendCG_EnterTeamDungeon_Req")
        TeamSend.sendCG_EnterTeamDungeon_Req({mapID = 1})
    end,function()
    end, function(code)
        StandardTipsMgr.show(1,"team27")
    end)
end

function TeamCopyInfo.GetTeamCopyMapInfo()
    local w, h = TeamCopyMapMgr.getLocalCopyMapSize()
    if w <= 0 or h <= 0 then
        local FamilySend = require("src.Net.Send.FamilySend")
    
        NetInterface.sendWithBlock("GC_GetDungeon_Ack", function()
            print("!!!!!!!!!!!!!!!GetTeamCopyMapInfo---sendCG_GetDungeon_Req")
            FamilySend.sendCG_GetDungeon_Req({type = 2})
        end,function()
        end, function(code)
            --StandardTipsMgr.show(1,"GetTeamCopyMapInfo failed code="..code)
            if code == Proto.Error.ERROR_NOTEAM--[[ or code == Proto.Error.ERROR_NOGAME]] then
                NetInterface.send("GC_GetCharacterValues_Ack", function()
                    local LoginSend = require("src.Net.Send.LoginSend")
                    LoginSend.sendCG_GetCharacterValues_Req({"treasureBoxSelect"})                 
                end, function()
                    TeamCopyMapMgr.forceQuitTeamCopy()
                end, function(code)
                    TeamCopyMapMgr.forceQuitTeamCopy()
                end)
            end
        end)
    else
        if SceneMgr.currentScene == "TeamCopyMapScene" then
            TeamCopyMapMgr.addLocalCopyMapInfo({})
            TeamCopyMapMgr.addLocalMembersInfo({})
        end
    end
end

function TeamCopyInfo.TeamCopyMovingGrid(index, width)
    targetMoveCellIndex = index
    if enableMoveCell and targetMoveCellIndex ~= lastMoveCellIndex then
        local x = math.ceil(index/width)
        local y = (index%width == 0 and width or index%width)
        local FamilySend = require("src.Net.Send.FamilySend")

        NetInterface.send("GC_DungeonMoveCell_Ack", function()
            print("!!!!!!!!!!!!!!!TeamCopyMovingGrid---sendCG_DungeonMoveCell_Req",x,y)
            enableMoveCell = false
            lastMoveCellIndex = targetMoveCellIndex
            FamilySend.sendCG_DungeonMoveCell_Req({x = x, y = y, path = "", type = 2})
        end,function()
            enableMoveCell = true
            if targetMoveCellIndex ~= lastMoveCellIndex then
                TeamCopyInfo.TeamCopyMovingGrid(targetMoveCellIndex, width)
            end
        end, function(code)
            enableMoveCell = true
            if targetMoveCellIndex ~= lastMoveCellIndex then
                TeamCopyInfo.TeamCopyMovingGrid(targetMoveCellIndex, width)
            end
            --StandardTipsMgr.show(1,"TeamCopyMovingGrid failed code="..code)
            if code == Proto.Error.ERROR_NOTEAM then
                TeamCopyMapMgr.forceQuitTeamCopy()
            end
        end)
    end
end

function TeamCopyInfo.TeamCopyTriggerGrid(x, y, callback)
    if enableTriggerGrid then
        local FamilySend = require("src.Net.Send.FamilySend")

        NetInterface.send("GC_FireDungeonCell_Ack", function()
            print("!!!!!!!!!!!!!!!TeamCopyTriggerGrid---sendCG_FireDungeonCell_Req",x,y)
            enableTriggerGrid = false
            FamilySend.sendCG_FireDungeonCell_Req({x = x, y = y, type = 2})
        end,function()
            enableTriggerGrid = true
            if callback then callback() end
        end, function(code)
            enableTriggerGrid = true
            --StandardTipsMgr.show(1,"family102")
            if code == Proto.Error.ERROR_NOTEAM then
                TeamCopyMapMgr.forceQuitTeamCopy()
            end
        end)
    end
end

function TeamCopyInfo.TeamBattleEnd(isWin, battleDetails, monsterHp, battleID, x, y)
    local TeamSend = require("src.Net.Send.TeamSend")

    NetInterface.sendWithBlock("GC_TEAMBATTLEEND_ACK", function()
        print("!!!!!!!!!!!!!!!TeamBattleEnd---sendCG_TeamBattleEnd_Req",isWin, sz_T2S(battleDetails), monsterHp, battleID,x,y)
        TeamSend.sendCG_TeamBattleEnd_Req({isWin = isWin, battleDetails = battleDetails, monsterHp = monsterHp, battleID = battleID, x = x, y = y})
    end,function()
    end, function(code)
        StandardTipsMgr.show(1,"TeamBattleEnd failed code="..code)
    end)
end

function TeamCopyInfo.TeamChangeFloor(type)
    local FamilySend = require("src.Net.Send.FamilySend")

    NetInterface.send("GC_DungeonChangeFloor_Ack", function()
        print("!!!!!!!!!!!!!!!TeamChangeFloor---sendCG_DungeonChangeFloor_Req",type)
        FamilySend.sendCG_DungeonChangeFloor_Req({type = type, mapType = 2})
        TeamCopyMapMgr.playChangeFloorEffect()
    end,function()
        if type == 1 then
            TeamCopyMapMgr.incOwnerPlayerCurrentFloor()
        else
            TeamCopyMapMgr.decOwnerPlayerCurrentFloor()
        end
        TeamCopyMapMgr.cleanLocalCopyMapInfo()
        TeamCopyInfo.GetTeamCopyMapInfo()
    end, function(code)
        --StandardTipsMgr.show(1,"TeamChangeFloor failed code="..code)
        if code == Proto.Error.ERROR_NOTEAM then
            TeamCopyMapMgr.forceQuitTeamCopy()
        end
    end)
end

function TeamCopyInfo.LeaveTeamCopy()
    local TeamSend = require("src.Net.Send.TeamSend")

    NetInterface.sendWithBlock("GC_LEAVETEAMDUNGEON_ACK", function()
        print("!!!!!!!!!!!!!!!LeaveTeamCopy---sendCG_LeaveTeamDungeon_Req")
        TeamSend.sendCG_LeaveTeamDungeon_Req()
    end,function()
        TeamInfo.exitTeam(nil, function()
            TeamInfo.clearTeam()
        end)
    end, function(code)
        StandardTipsMgr.show(1,"LeaveTeamCopy failed code="..code)
    end)
end

function TeamCopyInfo.ChangeArmyPet(pets, helperPets)
    local TeamSend = require("src.Net.Send.TeamSend")

    NetInterface.sendWithBlock("GC_CHANGEARMYPET_ACK", function()
        print("!!!!!!!!!!!!!!!ChangeArmyPet---sendCG_ChangeArmyPet_Req",sz_T2S(pets),sz_T2S(helperPets))
        TeamSend.sendCG_ChangeArmyPet_Req({pets = pets, helperPets = helperPets})
    end,function()
    end, function(code)
        StandardTipsMgr.show(1,"ChangeArmyPet failed code="..code)
    end)
end

function TeamCopyInfo.ReviveCharacter(charID, callback)
    local TeamSend = require("src.Net.Send.TeamSend")
    
    NetInterface.sendWithBlock("GC_REVIVECHARACTER_ACK", function()
        print("!!!!!!!!!!!!!!!ReviveCharacter---sendCG_ReviveCharacter_Req",charID)
        TeamSend.sendCG_ReviveCharacter_Req({charID = charID})
    end,function()
        if callback then callback() end
    end, function(code)
        StandardTipsMgr.show(1,"ReviveCharacter failed code="..code)
    end)
end

function TeamCopyInfo.TeamDungeonBattleStart(monsterID)

    --增加如果失败 自动从服务器中退出战斗
    NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
            local LoginSend = require("src.Net.Send.LoginSend")
            LoginSend.sendCG_GetCharacterValues_Req({"pvpBattleID","pvpServerID"})
        end, function()
            local battleID = BattlePVPMgr.getBattleID() 
            local serverID = BattlePVPMgr.getserverID()
            print("GC_GetCharacterValues_Ack...pvpBattleID...",battleID) 
            print("GC_GetCharacterValues_Ack...pvpServerID...",serverID)   
            if battleID then
                BattlePVPMgr.sendLeaveBattleCommand()
                BattlePVPMgr.setBattleID(nil)
                BattlePVPMgr.setserverID(nil)
                DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,1,"请重新再试",function()
                        end,nil,nil,false)
            else
                local TeamSend = require("src.Net.Send.TeamSend")
                NetInterface.sendWithBlock("GC_TEAMDUNGEONBATTLESTART_ACK", function()
                    print("!!!!!!!!!!!!!!!TeamDungeonBattleStart---sendCG_TeamDungeonBattleStart_Req",monsterID)
                    TeamSend.sendCG_TeamDungeonBattleStart_Req({monsterID = monsterID})
                end,function()
                    CopyMapLoadingMgr.show(SceneMgr.getRunningScene, 5.0, "TeamCopyPVELoading", function()
                        local boxes = TeamCopyWinMgr.getBoxes()
                        if boxes then
                            TeamCopyWinMgr.show(SceneMgr.getRunningScene, boxes)
                        end
                    end)
                end, function(code)

                    --StandardTipsMgr.show(1,"TeamDungeonBattleStart failed code="..code)
                    if code == Proto.Error.ERROR_NOTEAM then
                        TeamCopyMapMgr.forceQuitTeamCopy()
                    end
                end)
            end
        end, function(code)
                 
            TipsMgr.showError(nil, code)
        end)

    
end

function TeamCopyInfo.QueryTeamDungeonMonsterHp()
    local TeamSend = require("src.Net.Send.TeamSend")

    NetInterface.sendWithBlock("GC_QUERYTEAMDUNGEONMONSTERHP_ACK", function()
        print("!!!!!!!!!!!!!!!QueryTeamDungeonMonsterHp---sendCG_QueryTeamDungeonMonsterHp_Req")
        TeamSend.sendCG_QueryTeamDungeonMonsterHp_Req()
    end,function()
    end, function(code)
        StandardTipsMgr.show(1,"QueryTeamDungeonMonsterHp failed code="..code)
    end)
end

return TeamCopyInfo