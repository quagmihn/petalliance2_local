require("src.Net.Proto.ProtoInclude")

local FamilyProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

local QueryMyFamilyMembersTotal = 0
local QueryMyFamilyMembersTbl = {}
local QueryFamilyMembersTotal = 0
local QueryFamilyMembersTbl = {}

function FamilyProcess.init()
    NetMgr.addProcess(Proto.Command.GC_LEVELREFLASHFAMILYSHOP_ACK,
        FamilyProcess.onGC_LevelReflashFamilyShop_Ack)
    NetMgr.addProcess(Proto.Command.GC_REFALSHFAMILYSHOP_ACK,
        FamilyProcess.onGC_RefalshFamilyShop_Ack)
    NetMgr.addProcess(Proto.Command.GC_BUYFAMILYSHOPGOODS_ACK,
        FamilyProcess.onGC_BuyFamilyShopGoods_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETFAMILYSHOPDATA_ACK,
        FamilyProcess.onGC_GetFamilyShopData_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETDUNGEONLOG_ACK,
        FamilyProcess.onGC_GetDungeonLog_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETDUNGEONAWARD_ACK,
        FamilyProcess.onGC_GetDungeonAward_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETDUNGEONAWARDINFO_ACK,
        FamilyProcess.onGC_GetDungeonAwardInfo_Ack)
    NetMgr.addProcess(Proto.Command.GC_RESETDUNGEON_ACK,
        FamilyProcess.onGC_ResetDungeon_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETDUNGEONCREATETIME_ACK,
        FamilyProcess.onGC_GetDungeonCreateTime_Ack)
    NetMgr.addProcess(Proto.Command.GC_LEAVEFLOOR_NTF,
        FamilyProcess.onGC_LeaveFloor_Ntf)
    NetMgr.addProcess(Proto.Command.GC_DUNGEONCHANGEFLOOR_ACK,
        FamilyProcess.onGC_DungeonChangeFloor_Ack)
    NetMgr.addProcess(Proto.Command.GC_ALLBATTLE_NTF,
        FamilyProcess.onGC_AllBattle_Ntf)
    NetMgr.addProcess(Proto.Command.GC_OPENCHEST_NTF,
        FamilyProcess.onGC_OpenChest_Ntf)
    NetMgr.addProcess(Proto.Command.GC_CLEANCELL_NTF,
        FamilyProcess.onGC_CleanCell_Ntf)
    NetMgr.addProcess(Proto.Command.GC_FAMILYKILLBOSS_NTF,
        FamilyProcess.onGC_FamilyKillBoss_Ntf)
    NetMgr.addProcess(Proto.Command.GC_DISPLAYCELL_NTF,
        FamilyProcess.onGC_DisplayCell_Ntf)
    NetMgr.addProcess(Proto.Command.GC_BATTLESTARTLOCKED_NTF,
        FamilyProcess.onGC_BattleStartLocked_Ntf)
    NetMgr.addProcess(Proto.Command.GC_DUNGEONBATTLEEND_ACK,
        FamilyProcess.onGC_DungeonBattleEnd_Ack)
    NetMgr.addProcess(Proto.Command.GC_ALLBUFF_NTF,
        FamilyProcess.onGC_AllBuff_Ntf)
    NetMgr.addProcess(Proto.Command.GC_CURRENTFLOORALLMEBERS_NTF,
        FamilyProcess.onGC_CurrentFloorAllMebers_Ntf)
    NetMgr.addProcess(Proto.Command.GC_ADDBUFF_NTF,
        FamilyProcess.onGC_AddBuff_Ntf)
    NetMgr.addProcess(Proto.Command.GC_FAMILYBATTLEINFO_NTF,
        FamilyProcess.onGC_FamilyBattleInfo_Ntf)
    NetMgr.addProcess(Proto.Command.GC_FAMILYRANDOMCHESTAWARD_NTF,
        FamilyProcess.onGC_FamilyRandomChestAward_Ntf)
    NetMgr.addProcess(Proto.Command.GC_FIREDUNGEONCELL_ACK,
        FamilyProcess.onGC_FireDungeonCell_Ack)
    NetMgr.addProcess(Proto.Command.GC_FAMILYDISPLAYCELL_ACK,
        FamilyProcess.onGC_FamilyDisplayCell_Ack)
    NetMgr.addProcess(Proto.Command.GC_CHARACTERMOVECELL_NTF,
        FamilyProcess.onGC_CharacterMoveCell_Ntf)
    NetMgr.addProcess(Proto.Command.GC_DUNGEONMOVECELL_ACK,
        FamilyProcess.onGC_DungeonMoveCell_Ack)
    NetMgr.addProcess(Proto.Command.GC_DUNGEONCELLS_NTF,
        FamilyProcess.onGC_DungeonCells_Ntf)
    NetMgr.addProcess(Proto.Command.GC_GETDUNGEON_ACK,
        FamilyProcess.onGC_GetDungeon_Ack)
    NetMgr.addProcess(Proto.Command.GC_FAMILY_NTF,
        FamilyProcess.onGC_Family_Ntf)
    NetMgr.addProcess(Proto.Command.GC_FAMILY_ACK,
        FamilyProcess.onGC_Family_Ack)

    QueryMyFamilyMembersTotal = 0
    QueryMyFamilyMembersTbl = {}
    QueryFamilyMembersTotal = 0
    QueryFamilyMembersTbl = {}
end

function FamilyProcess.onGC_Family_Ack(msg)

    local res = Proto.parseP_GC_Family_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_Family_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        local cjson = require("cjson")
        print("###########onGC_Family_Ack res.cmd="..tostring(res.cmd).." res.ackConcent="..tostring(res.ackConcent))
        if res.cmd == "QueryFamilyList" then
            FamilyListViewMgr.famliyLstJsonStr = res.ackConcent
        elseif res.cmd == FamilyInfo.CMD.QUERY_FAMILY then
            local cfg = cjson.decode(res.ackConcent)
            QueryFamilyMembersTotal = (cfg.memberCount or 0)
            QueryFamilyMembersTbl = {}
            --FamilyInfo.SetQueryFamilyInfo(cfg)
            SearchFamilyMgr.Refresh(cfg)
        elseif res.cmd == FamilyInfo.CMD.QUERY_MY_FAMILY then
            local cfg = cjson.decode(res.ackConcent)
            QueryMyFamilyMembersTotal = (cfg.memberCount or 0)
            QueryMyFamilyMembersTbl = {}
            FamilyInfo.SetLocalFamilyInfo(cfg)
            TownMapMgr.refreshNameLabel(nil, nil, cfg.name)
            FamilyInfoMgr.RefreshByFamilyCfg(cfg)
            FamilyLogViewMgr.createList(cfg.familyQuestLog)
            MyFamilyLstViewMgr.initUIBaseData()
            FamilyNpcManagerViewMgr.initDynamicData(cfg)
        elseif res.cmd == FamilyInfo.CMD.MODIFY_FAMILY_INFO then
            local cfg = cjson.decode(res.ackConcent)
            FamilyInfo.ModifyFamilyInfo(cfg)
        elseif res.cmd == FamilyInfo.CMD.GET_FAMILY_QUEST then
            local cfg = cjson.decode(res.ackConcent)
            FamilyQuestListMgr.createList(cfg.familyQuests, cfg.familyQuestAwards)
        elseif res.cmd == FamilyInfo.CMD.QUERY_FAMILY_DONATION then
            local cfg = cjson.decode(res.ackConcent)
            FamilyDonateMgr.updateDonatedNum(cfg.goldNum)
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FAMILY_ACK)
    return res.code

end

function FamilyProcess.onGC_Family_Ntf(msg)

    local res = Proto.parseP_GC_Family_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_Family_Ntf")
    print("###########onGC_Family_Ntf res.cmd="..tostring(res.cmd).." res.ackConcent="..tostring(res.ackConcent))
    if res.cmd == FamilyInfo.CMD.QUERY_MY_FAMILY_MEMBERS then
        local cjson = require("cjson")
        local members = cjson.decode(res.ackConcent)
        
        local tableLen = 0
        for k,v in pairs(QueryMyFamilyMembersTbl) do
            tableLen = tableLen + 1
        end
        
        for k,v in pairs(members) do
            QueryMyFamilyMembersTbl[k] = v
            tableLen = tableLen + 1
        end
        
        if tableLen >= QueryMyFamilyMembersTotal then
            FamilyInfo.SetLocalFamilyMembersInfo(QueryMyFamilyMembersTbl)
            if FamilyApplyListViewMgr.isOpen() == false then
                MyFamilyLstViewMgr.refreshMemberList(QueryMyFamilyMembersTbl)
            end
        end
    elseif res.cmd == FamilyInfo.CMD.QUERY_MY_FAMILY_APPLYS then
        --print("###########onGC_Family_Ntf res.cmd="..tostring(res.cmd).." res.ackConcent="..tostring(res.ackConcent))
        local cjson = require("cjson")
        FamilyApplyListViewMgr.refreshApplyList(cjson.decode(res.ackConcent))
    elseif res.cmd == FamilyInfo.CMD.QUERY_FAMILY_MEMBERS then
        if SceneMgr.currentScene == "HomeScene" then
            local cjson = require("cjson")
            local members = cjson.decode(res.ackConcent)
            
            local tableLen = 0
            for k,v in pairs(QueryFamilyMembersTbl) do
                tableLen = tableLen + 1
            end
            
            for k,v in pairs(members) do
                QueryFamilyMembersTbl[k] = v
                tableLen = tableLen + 1
            end
            
            if tableLen >= QueryFamilyMembersTotal then
                HomeInfo.GetNeighborByActivity(QueryFamilyMembersTbl)
            end
        end
    end
    
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FAMILY_NTF)
    return res.code

end

function FamilyProcess.onGC_GetDungeon_Ack(msg)

    local res = Proto.parseP_GC_GetDungeon_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetDungeon_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        --print("###########GetDungeon_Ack res=",sz_T2S(res))
        print("###########GetDungeon_Ack res=",res.cellNum,res.membersNum,res.buffNum,res.battleNum,res.advID,res.maxKilled)
        if SceneMgr.currentScene == "FamilyCopyMapScene" then
            FamilyCopyMapMgr.cleanLocalCopyMapInfo()
            FamilyCopyMapMgr.setGridNum(res.cellNum)
            FamilyCopyMapMgr.setBuffNum(res.buffNum)
            FamilyCopyMapMgr.setMembersNum(res.membersNum)
            FamilyCopyMapMgr.setBattleNum(res.battleNum)
        elseif SceneMgr.currentScene == "TeamCopyMapScene" then
            if res.cellNum > 0 and res.membersNum > 0 then
                TeamCopyMapMgr.cleanLocalCopyMapInfo()
                TeamCopyMapMgr.setGridNum(res.cellNum)
                --TeamCopyMapMgr.setBuffNum(res.buffNum)
                TeamCopyMapMgr.setMembersNum(res.membersNum)
                TeamCopyMapMgr.setBattleNum(res.battleNum)
                TeamCopyMapMgr.setCopyID(res.advID)
                TeamCopyMapMgr.setKillMonsterNum(res.maxKilled, false)
            else
                TeamCopyMapMgr.forceQuitTeamCopy()
                TeamCopyInfo.LeaveTeamCopy()
            end
        end
    else
        if SceneMgr.currentScene == "TeamCopyMapScene" then
            TeamCopyMapMgr.forceQuitTeamCopy()
            TeamCopyInfo.LeaveTeamCopy()
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETDUNGEON_ACK)
    return res.code

end

function FamilyProcess.onGC_DungeonCells_Ntf(msg)

    local res = Proto.parseP_GC_DungeonCells_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_DungeonCells_Ntf")
    --print("###########DungeonCells_Ntf res.cells="..sz_T2S(res.cells))
    if SceneMgr.currentScene == "FamilyCopyMapScene" then
        FamilyCopyMapMgr.addLocalCopyMapInfo(res.cells)
    elseif SceneMgr.currentScene == "TeamCopyMapScene" then
        local isAllMapInfoRecv = TeamCopyMapMgr.addLocalCopyMapInfo(res.cells)
        if isAllMapInfoRecv then
            TeamCopyInfo.QueryTeamDungeonMonsterHp()
        end
    end
    
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_DUNGEONCELLS_NTF)
    return res.code

end

function FamilyProcess.onGC_CurrentFloorAllMebers_Ntf(msg)

    local res = Proto.parseP_GC_CurrentFloorAllMebers_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_CurrentFloorAllMebers_Ntf")
    print("###########onGC_CurrentFloorAllMebers_Ntf res.membersList="..sz_T2S(res.membersList))
    if SceneMgr.currentScene == "FamilyCopyMapScene" then
        FamilyCopyMapMgr.addLocalMembersInfo(res.membersList)
    elseif SceneMgr.currentScene == "TeamCopyMapScene" then
        TeamCopyMapMgr.addLocalMembersInfo(res.membersList)
    end
    
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CURRENTFLOORALLMEBERS_NTF)
    return res.code

end

function FamilyProcess.onGC_AllBuff_Ntf(msg)

    local res = Proto.parseP_GC_AllBuff_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_AllBuff_Ntf")
    print("###########onGC_AllBuff_Ntf res.buffList="..sz_T2S(res.buffList))
    if SceneMgr.currentScene == "FamilyCopyMapScene" then
        FamilyCopyMapMgr.addLocalBuffInfo(res.buffList)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_ALLBUFF_NTF)
    return res.code

end

function FamilyProcess.onGC_DungeonMoveCell_Ack(msg)

    local res = Proto.parseP_GC_DungeonMoveCell_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_DungeonMoveCell_Ack")
    print("###########DungeonMoveCell_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_DUNGEONMOVECELL_ACK)
    return res.code

end

function FamilyProcess.onGC_CharacterMoveCell_Ntf(msg)

    local res = Proto.parseP_GC_CharacterMoveCell_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_CharacterMoveCell_Ntf")
    print("###########CharacterMoveCell_Ntf res="..sz_T2S(res))
    --if res.charID ~= CharInfo.getCharID() then
        if SceneMgr.currentScene == "FamilyCopyMapScene" or (SceneMgr.currentScene == "BattleScene" and SceneMgr.previousScene == "FamilyCopyMapScene") then
            FamilyCopyMapMgr.setMemberMoveTarget(res)
        elseif SceneMgr.currentScene == "TeamCopyMapScene" or (SceneMgr.currentScene == "BattleScene" and SceneMgr.previousScene == "TeamCopyMapScene") then
            TeamCopyMapMgr.setMemberMoveTarget(res)
        end
    --end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CHARACTERMOVECELL_NTF)
    return res.code

end

function FamilyProcess.onGC_FamilyDisplayCell_Ack(msg)

    local res = Proto.parseP_GC_FamilyDisplayCell_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_FamilyDisplayCell_Ack")
    print("###########FamilyDisplayCell_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FAMILYDISPLAYCELL_ACK)
    return res.code

end

function FamilyProcess.onGC_DisplayCell_Ntf(msg)

    local res = Proto.parseP_GC_DisplayCell_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_DisplayCell_Ntf")
    print("###########DisplayCell_Ntf")
    if SceneMgr.currentScene == "FamilyCopyMapScene" or (SceneMgr.currentScene == "BattleScene" and SceneMgr.previousScene == "FamilyCopyMapScene") then
        FamilyCopyMapMgr.displayGrid(res.x, res.y)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_DISPLAYCELL_NTF)
    return res.code

end

function FamilyProcess.onGC_FireDungeonCell_Ack(msg)

    local res = Proto.parseP_GC_FireDungeonCell_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_FireDungeonCell_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FIREDUNGEONCELL_ACK)
    return res.code

end

function FamilyProcess.onGC_FamilyRandomChestAward_Ntf(msg)

    local res = Proto.parseP_GC_FamilyRandomChestAward_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_FamilyRandomChestAward_Ntf")
    if SceneMgr.currentScene == "FamilyCopyMapScene" then
        local cjson = require("cjson")
        local content = cjson.decode(res.awardContent)
        if content.awardElements then
            local awardElementInfo = ItemInfo.getAwardElementInfoById(content.awardElements[1].aID)
            AwardsListMgr.show(SceneMgr.getRunningScene, {{awardElementInfo.elementID, content.awardElements[1].num}})
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FAMILYRANDOMCHESTAWARD_NTF)
    return res.code

end

function FamilyProcess.onGC_FamilyBattleInfo_Ntf(msg)

    local res = Proto.parseP_GC_FamilyBattleInfo_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_FamilyBattleInfo_Ntf")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FAMILYBATTLEINFO_NTF)
    return res.code

end

function FamilyProcess.onGC_AddBuff_Ntf(msg)

    local res = Proto.parseP_GC_AddBuff_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_AddBuff_Ntf")
    print("###########onGC_AddBuff_Ntf res.buffID=",res.buffID)
    if SceneMgr.currentScene == "FamilyCopyMapScene" or (SceneMgr.currentScene == "BattleScene" and SceneMgr.previousScene == "FamilyCopyMapScene") then
        local buffInfo = {}
        buffInfo[1] = res.buffID
        FamilyCopyMapMgr.addLocalBuffInfo(buffInfo, true)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_ADDBUFF_NTF)
    return res.code

end

function FamilyProcess.onGC_DungeonBattleEnd_Ack(msg)

    local res = Proto.parseP_GC_DungeonBattleEnd_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_DungeonBattleEnd_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_DUNGEONBATTLEEND_ACK)
    return res.code

end

function FamilyProcess.onGC_BattleStartLocked_Ntf(msg)

    local res = Proto.parseP_GC_BattleStartLocked_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_BattleStartLocked_Ntf")
    print("###########onGC_BattleStartLocked_Ntf res=",sz_T2S(res))
    if SceneMgr.currentScene == "FamilyCopyMapScene" or (SceneMgr.currentScene == "BattleScene" and SceneMgr.previousScene == "FamilyCopyMapScene") then
        FamilyCopyMapMgr.setLockPVEGrid(res.x, res.y, res.isLocked, res.lockedTime)
    elseif SceneMgr.currentScene == "TeamCopyMapScene" or (SceneMgr.currentScene == "BattleScene" and SceneMgr.previousScene == "TeamCopyMapScene") then
        TeamCopyMapMgr.setLockPVEGrid(res.x, res.y, res.isLocked, res.lockedTime)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_BATTLESTARTLOCKED_NTF)
    return res.code

end

function FamilyProcess.onGC_FamilyKillBoss_Ntf(msg)

    local res = Proto.parseP_GC_FamilyKillBoss_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_FamilyKillBoss_Ntf")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FAMILYKILLBOSS_NTF)
    return res.code

end

function FamilyProcess.onGC_CleanCell_Ntf(msg)

    local res = Proto.parseP_GC_CleanCell_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_CleanCell_Ntf")
    print("###########onGC_CleanCell_Ntf res=",sz_T2S(res))
    if SceneMgr.currentScene == "FamilyCopyMapScene" or (SceneMgr.currentScene == "BattleScene" and SceneMgr.previousScene == "FamilyCopyMapScene") then
        FamilyCopyMapMgr.cleanGrid(res.x, res.y)
    elseif SceneMgr.currentScene == "TeamCopyMapScene" or (SceneMgr.currentScene == "BattleScene" and SceneMgr.previousScene == "TeamCopyMapScene") then
        TeamCopyMapMgr.cleanGrid(res.x, res.y)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CLEANCELL_NTF)
    return res.code

end

function FamilyProcess.onGC_OpenChest_Ntf(msg)

    local res = Proto.parseP_GC_OpenChest_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_OpenChest_Ntf")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_OPENCHEST_NTF)
    return res.code

end

function FamilyProcess.onGC_AllBattle_Ntf(msg)

    local res = Proto.parseP_GC_AllBattle_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_AllBattle_Ntf")
    print("###########onGC_AllBattle_Ntf res.battleList="..sz_T2S(res.battleList))
    if SceneMgr.currentScene == "FamilyCopyMapScene" then
        FamilyCopyMapMgr.addLocalBattleInfo(res.battleList)
    elseif SceneMgr.currentScene == "TeamCopyMapScene" then
        --TeamCopyMapMgr.addLocalBattleInfo(res.battleList)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_ALLBATTLE_NTF)
    return res.code

end

function FamilyProcess.onGC_DungeonChangeFloor_Ack(msg)

    local res = Proto.parseP_GC_DungeonChangeFloor_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_DungeonChangeFloor_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_DUNGEONCHANGEFLOOR_ACK)
    return res.code

end

function FamilyProcess.onGC_LeaveFloor_Ntf(msg)

    local res = Proto.parseP_GC_LeaveFloor_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_LeaveFloor_Ntf")
    print("###########onGC_LeaveFloor_Ntf res=",sz_T2S(res))
    if res.charID ~= CharInfo.getCharID() then
        if SceneMgr.currentScene == "FamilyCopyMapScene" or (SceneMgr.currentScene == "BattleScene" and SceneMgr.previousScene == "FamilyCopyMapScene") then
            FamilyCopyMapMgr.localMemberLeaveFloor(res.charID)
        elseif SceneMgr.currentScene == "TeamCopyMapScene" or (SceneMgr.currentScene == "BattleScene" and SceneMgr.previousScene == "TeamCopyMapScene") then
            TeamCopyMapMgr.localMemberLeaveFloor(res.charID)
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_LEAVEFLOOR_NTF)
    return res.code

end

function FamilyProcess.onGC_GetDungeonCreateTime_Ack(msg)

    local res = Proto.parseP_GC_GetDungeonCreateTime_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetDungeonCreateTime_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        if CharInfo.getFamilyID() ~= nil and CharInfo.getServerTime() >= res.createTime then
            FamilyInfo.ResetFamilyCopy()
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETDUNGEONCREATETIME_ACK)
    return res.code

end

function FamilyProcess.onGC_ResetDungeon_Ack(msg)

    local res = Proto.parseP_GC_ResetDungeon_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ResetDungeon_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_RESETDUNGEON_ACK)
    return res.code

end

function FamilyProcess.onGC_GetDungeonAwardInfo_Ack(msg)

    local res = Proto.parseP_GC_GetDungeonAwardInfo_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetDungeonAwardInfo_Ack")
    FamilyCopyMgr.setAwardInfo(res.awardFloor, res.canTakeAward)
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETDUNGEONAWARDINFO_ACK)
    return res.code

end

function FamilyProcess.onGC_GetDungeonAward_Ack(msg)

    local res = Proto.parseP_GC_GetDungeonAward_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetDungeonAward_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        local cjson = require("cjson")
        local content = cjson.decode(res.awardContent)
        if content.awardElements then
            local awardTbl = {}
            for k,v in pairs(content.awardElements) do
                local awardElementInfo = ItemInfo.getAwardElementInfoById(v.aID)
                table.insert(awardTbl,{awardElementInfo.elementID, v.num})
            end
            --print("GetDungeonAward_Ack awardTbl=",sz_T2S(awardTbl))
            AwardsListMgr.show(SceneMgr.getRunningScene, awardTbl)
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETDUNGEONAWARD_ACK)
    return res.code

end

function FamilyProcess.onGC_GetDungeonLog_Ack(msg)

    local res = Proto.parseP_GC_GetDungeonLog_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetDungeonLog_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        --local cjson = require("cjson")
        --local log = cjson.decode(res.logList)
        print("########onGC_GetDungeonLog_Ack log=",sz_T2S(res.logList))
        FamilyCopyEventMgr.createList(res.logList)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETDUNGEONLOG_ACK)
    return res.code

end

function FamilyProcess.onGC_GetFamilyShopData_Ack(msg)

    local res = Proto.parseP_GC_GetFamilyShopData_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetFamilyShopData_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("########onGC_GetFamilyShopData_Ack res=",sz_T2S(res))
        local reflashTime = res.reflashTime or 0
        local timePoints = SystemInfo.getGlobalConfigAddInfoByID(75).values
        local offsetTime = timePoints[1] * 3600
        --print("**********timePoints[1]=",timePoints[1])
        local dayDiff = CocosModuleMgr.getDayTimeDiff(reflashTime, CharInfo.getServerTime(), offsetTime)
        if dayDiff ~= 0 then
            FamilyInfo.RefreshFamilyShop(function()
                FamilyShopMgr.createList({})
            end, function()
                FamilyShopMgr.createList(res.purchased)
            end)
        end
        reflashTime = res.levelReflashTime or 0
        local familyLevel = 1
        local info = FamilyInfo.GetLocalFamilyInfo()
        if info ~= nil then
            familyLevel = (info.familyLevel or 1)
        end
        timePoints = SystemInfo.getGlobalConfigAddInfoByID(76).values
        offsetTime = timePoints[2] * 3600
        --print("**********timePoints[2]=",timePoints[1],timePoints[2])
        dayDiff = CocosModuleMgr.getDayTimeDiff(reflashTime, CharInfo.getServerTime(), offsetTime)
        if familyLevel >= timePoints[1] and dayDiff ~= 0 then
            FamilyInfo.LevelRefreshFamilyShop(function()
                FamilyShopMgr.createList({})
            end, function()
                FamilyShopMgr.createList(res.purchased)
            end)
        else
            FamilyShopMgr.createList(res.purchased)
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETFAMILYSHOPDATA_ACK)
    return res.code

end

function FamilyProcess.onGC_BuyFamilyShopGoods_Ack(msg)

    local res = Proto.parseP_GC_BuyFamilyShopGoods_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_BuyFamilyShopGoods_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_BUYFAMILYSHOPGOODS_ACK)
    return res.code

end

function FamilyProcess.onGC_RefalshFamilyShop_Ack(msg)

    local res = Proto.parseP_GC_RefalshFamilyShop_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_RefalshFamilyShop_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_REFALSHFAMILYSHOP_ACK)
    return res.code

end

function FamilyProcess.onGC_LevelReflashFamilyShop_Ack(msg)

    local res = Proto.parseP_GC_LevelReflashFamilyShop_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_LevelReflashFamilyShop_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_LEVELREFLASHFAMILYSHOP_ACK)
    return res.code

end

return FamilyProcess
