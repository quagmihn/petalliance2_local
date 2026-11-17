require("src.Net.Proto.ProtoInclude")

local ArenaProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function ArenaProcess.init()
    NetMgr.addProcess(Proto.Command.GC_PLAYMARENARECODE4_NTF,
        ArenaProcess.onGC_PlayMArenaRecode4_Ntf)
    NetMgr.addProcess(Proto.Command.GC_PLAYMARENARECODE3_NTF,
        ArenaProcess.onGC_PlayMArenaRecode3_Ntf)
    NetMgr.addProcess(Proto.Command.GC_PLAYMARENARECODE2_NTF,
        ArenaProcess.onGC_PlayMArenaRecode2_Ntf)
    NetMgr.addProcess(Proto.Command.GC_PLAYARENARECODE4_NTF,
        ArenaProcess.onGC_PlayArenaRecode4_Ntf)
    NetMgr.addProcess(Proto.Command.GC_PLAYARENARECODE3_NTF,
        ArenaProcess.onGC_PlayArenaRecode3_Ntf)
    NetMgr.addProcess(Proto.Command.GC_PLAYARENARECODE2_NTF,
        ArenaProcess.onGC_PlayArenaRecode2_Ntf)
    NetMgr.addProcess(Proto.Command.GC_GETMARENARECODE_NTF,
        ArenaProcess.onGC_GetMArenaRecode_Ntf)
    NetMgr.addProcess(Proto.Command.GC_PLAYMARENARECODE_NTF,
        ArenaProcess.onGC_PlayMArenaRecode_Ntf)
    NetMgr.addProcess(Proto.Command.GC_PLAYMARENARECODE_ACK,
        ArenaProcess.onGC_PlayMArenaRecode_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETMARENARECODE_ACK,
        ArenaProcess.onGC_GetMArenaRecode_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETMARENAAWARD_ACK,
        ArenaProcess.onGC_GetMArenaAward_Ack)
    NetMgr.addProcess(Proto.Command.GC_BUYMARENAFIGHTTIMES_ACK,
        ArenaProcess.onGC_BuyMArenaFightTimes_Ack)
    NetMgr.addProcess(Proto.Command.GC_CLEARMARENACD_ACK,
        ArenaProcess.onGC_ClearMArenaCD_Ack)
    NetMgr.addProcess(Proto.Command.GC_QUERYMARENASOLDIERDETAIL_ACK,
        ArenaProcess.onGC_QueryMArenaSoldierDetail_Ack)
    NetMgr.addProcess(Proto.Command.GC_QUERYMARENARANK_ACK,
        ArenaProcess.onGC_QueryMArenaRank_Ack)
    NetMgr.addProcess(Proto.Command.GC_MARENARANKFIGHTEND_ACK,
        ArenaProcess.onGC_MArenaRankFightEnd_Ack)
    NetMgr.addProcess(Proto.Command.GC_MARENARANKFIGHT_ACK,
        ArenaProcess.onGC_MArenaRankFight_Ack)
    NetMgr.addProcess(Proto.Command.GC_JOINMARENA_ACK,
        ArenaProcess.onGC_JoinMArena_Ack)
    NetMgr.addProcess(Proto.Command.GC_CHANGEMARENAPETOBJIDS_ACK,
        ArenaProcess.onGC_ChangeMArenaPetObjIDs_Ack)
    NetMgr.addProcess(Proto.Command.GC_RANDOMMARENAENEMYS_ACK,
        ArenaProcess.onGC_RandomMArenaEnemys_Ack)
    NetMgr.addProcess(Proto.Command.GC_MARENAPETSCHANGE_NTF,
        ArenaProcess.onGC_MArenaPetsChange_Ntf)
    NetMgr.addProcess(Proto.Command.GC_MARENARANKCHANGE_NTF,
        ArenaProcess.onGC_MArenaRankChange_Ntf)
    NetMgr.addProcess(Proto.Command.GC_QUERYMARENADATA_ACK,
        ArenaProcess.onGC_QueryMArenaData_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETARENARECODE_NTF,
        ArenaProcess.onGC_GetArenaRecode_Ntf)
    NetMgr.addProcess(Proto.Command.GC_PLAYARENARECODE_NTF,
        ArenaProcess.onGC_PlayArenaRecode_Ntf)
    NetMgr.addProcess(Proto.Command.GC_PLAYARENARECODE_ACK,
        ArenaProcess.onGC_PlayArenaRecode_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETARENARECODE_ACK,
        ArenaProcess.onGC_GetArenaRecode_Ack)
    NetMgr.addProcess(Proto.Command.GC_QUERYARENASOLDIERDETAIL_ACK,
        ArenaProcess.onGC_QueryArenaSoldierDetail_Ack)
    NetMgr.addProcess(Proto.Command.GC_QUERYARENARANK_ACK,
        ArenaProcess.onGC_QueryArenaRank_Ack)
    NetMgr.addProcess(Proto.Command.GC_ARENARANKCHANGE_NTF,
        ArenaProcess.onGC_ArenaRankChange_Ntf)
    NetMgr.addProcess(Proto.Command.GC_ARENAPETSCHANGE_NTF,
        ArenaProcess.onGC_ArenaPetsChange_Ntf)
    NetMgr.addProcess(Proto.Command.GC_ARENARANKFIGHTEND_ACK,
        ArenaProcess.onGC_ArenaRankFightEnd_Ack)
    NetMgr.addProcess(Proto.Command.GC_ARENARANKFIGHT_ACK,
        ArenaProcess.onGC_ArenaRankFight_Ack)
    NetMgr.addProcess(Proto.Command.GC_CHANGEARENAPETOBJIDS_ACK,
        ArenaProcess.onGC_ChangeArenaPetObjIDs_Ack)
    NetMgr.addProcess(Proto.Command.GC_JOINARENA_ACK,
        ArenaProcess.onGC_JoinArena_Ack)
    NetMgr.addProcess(Proto.Command.GC_RANDOMARENAENEMYS_ACK,
        ArenaProcess.onGC_RandomArenaEnemys_Ack)
    NetMgr.addProcess(Proto.Command.GC_QUERYARENADATA_ACK,
        ArenaProcess.onGC_QueryArenaData_Ack)
    NetMgr.addProcess(Proto.Command.GC_CLEARARENACD_ACK,
        ArenaProcess.onGC_ClearArenaCD_Ack)
    NetMgr.addProcess(Proto.Command.GC_BUYARENAFIGHTTIMES_ACK,
        ArenaProcess.onGC_BuyArenaFightTimes_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETARENAAWARD_ACK,
        ArenaProcess.onGC_GetArenaAward_Ack)

end

function ArenaProcess.onGC_QueryArenaData_Ack(msg)

    local res = Proto.parseP_GC_QueryArenaData_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_QueryArenaData_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        ArenaInfo.update({rank=res.rank, teamID=res.teamID})
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_QUERYARENADATA_ACK)
    return res.code

end

function ArenaProcess.onGC_RandomArenaEnemys_Ack(msg)

    local res = Proto.parseP_GC_RandomArenaEnemys_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_RandomArenaEnemys_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("GC_RandomArenaEnemys_Ack enemys size:", #res.enemys)
        ArenaInfo.setEnemys(res.enemys)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_RANDOMARENAENEMYS_ACK)
    return res.code

end

function ArenaProcess.onGC_JoinArena_Ack(msg)

    local res = Proto.parseP_GC_JoinArena_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_JoinArena_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        ArenaInfo.update({rank=res.rank, teamID=res.teamID})
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_JOINARENA_ACK)
    return res.code

end

function ArenaProcess.onGC_ChangeArenaPetObjIDs_Ack(msg)

    local res = Proto.parseP_GC_ChangeArenaPetObjIDs_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ChangeArenaPetObjIDs_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CHANGEARENAPETOBJIDS_ACK)
    return res.code

end

function ArenaProcess.onGC_ArenaRankFight_Ack(msg)

    local res = Proto.parseP_GC_ArenaRankFight_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ArenaRankFight_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("GC_ArenaRankFight_Ack battleID:", res.arenaBattleID)
        print("GC_ArenaRankFight_Ack self size:", #res.self)
        local cjson = require("cjson") 
        local enemyOtherParams = cjson.decode(res.enemyOtherParams)
        local scienceData_B    = {}
        if enemyOtherParams and enemyOtherParams.science and enemyOtherParams.science.data then 
            for key,var in pairs(enemyOtherParams.science.data) do
                scienceData_B[var[1]] = ScienceInfo.getSkillEffect(var[1], var[3], var[2])
            end
        end 

        BattlePVPMgr.setScienceDataB(scienceData_B)
        local petTbl ={}
        petTbl.self = {}
        petTbl.self[OUTPETS] = res.self
        petTbl.self[INPETS] = res.selfHelper
        for var=1, #res.self do
        	print(res.self[var])
        end
        print("GC_ArenaRankFight_Ack enemys size:", #res.enemys)
        for var=1, #res.enemys do
            print(res.enemys[var])
        end
        petTbl.enemys = {}
        petTbl.enemys[OUTPETS] = res.enemys
        petTbl.enemys[INPETS] = res.enemysHelper
        ArenaInfo.setBattleInfo(petTbl)
    else
        if GameGuideMgr.arenaGuideStart == true then
            GameGuideMgr.backToArena()
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_ARENARANKFIGHT_ACK)
    return res.code

end

function ArenaProcess.onGC_ArenaRankFightEnd_Ack(msg)

    local res = Proto.parseP_GC_ArenaRankFightEnd_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ArenaRankFightEnd_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_ARENARANKFIGHTEND_ACK)
    return res.code

end

function ArenaProcess.onGC_ArenaPetsChange_Ntf(msg)

    local res = Proto.parseP_GC_ArenaPetsChange_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_ArenaPetsChange_Ntf")
    print("GC_ArenaPetsChange_Ntf")
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_ARENAPETSCHANGE_NTF)
    return res.code

end

function ArenaProcess.onGC_ArenaRankChange_Ntf(msg)

    local res = Proto.parseP_GC_ArenaRankChange_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_ArenaRankChange_Ntf")
    print("Char Rank update:", res.rank)
    ArenaInfo.update({rank=res.rank})
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_ARENARANKCHANGE_NTF)
    return res.code

end

function ArenaProcess.onGC_QueryArenaRank_Ack(msg)

    local res = Proto.parseP_GC_QueryArenaRank_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_QueryArenaRank_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("GC_QueryArenaRank_Ack ", #res.soldiers)
        for var=1, #res.soldiers do
            print(res.soldiers[var])
        end
        ArenaInfo.setWorldRankList(res.soldiers)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_QUERYARENARANK_ACK)
    return res.code

end

function ArenaProcess.onGC_QueryArenaSoldierDetail_Ack(msg)

    local res = Proto.parseP_GC_QueryArenaSoldierDetail_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_QueryArenaSoldierDetail_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("GC_QueryArenaSoldierDetail_Ack ", res.charID, res.teamID)
        for var=1, #res.pets do
        	print(res.pets[var])
        end
        ArenaInfo.setRankListPets(res.charID, res.pets)
        ArenaInfo.setRankListHelperPets(res.charID, res.helperPets)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_QUERYARENASOLDIERDETAIL_ACK)
    return res.code

end

function ArenaProcess.onGC_ClearArenaCD_Ack(msg)

    local res = Proto.parseP_GC_ClearArenaCD_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ClearArenaCD_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("GC_ClearArenaCD_Ack ")
        -- ArenaViewMgr.OnClearArenaCD()
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CLEARARENACD_ACK)
    return res.code

end

function ArenaProcess.onGC_BuyArenaFightTimes_Ack(msg)

    local res = Proto.parseP_GC_BuyArenaFightTimes_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_BuyArenaFightTimes_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("GC_BuyArenaFightTimes_Ack ")
        -- ArenaViewMgr.OnBuyArenaFightTimes()
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_BUYARENAFIGHTTIMES_ACK)
    return res.code

end

function ArenaProcess.onGC_GetArenaAward_Ack(msg)

    local res = Proto.parseP_GC_GetArenaAward_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetArenaAward_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("GC_GetArenaAward_Ack ")
        -- ArenaViewMgr.OnGetArenaAward()
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETARENAAWARD_ACK)
    return res.code

end

function ArenaProcess.onGC_GetArenaRecode_Ack(msg)

    local res = Proto.parseP_GC_GetArenaRecode_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetArenaRecode_Ack")
    if (Proto.Error.ERROR_OK == res.code) then

    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETARENARECODE_ACK)
    return res.code

end

function ArenaProcess.onGC_PlayArenaRecode_Ack(msg)
    local res = Proto.parseP_GC_PlayArenaRecode_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PlayArenaRecode_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        if CSResourceMgr.getCsbObj("Player/Arena/ArenaWinView.csb") then
            if res.recodeInfo~="" then
                ArenaWinViewMgr.setBattlePets(res.recodeInfo)
            end
            ArenaWinViewMgr.setRecordNum(res.recodeNum)
        elseif CSResourceMgr.getCsbObj("Player/Arena/ArenaRecord.csb") then
            if res.recodeInfo~="" then
                ArenaRecordMgr.setBattlePets(res.recodeInfo)
            end
            ArenaRecordMgr.setRecordNum(res.recodeNum)     
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PLAYARENARECODE_ACK)
    return res.code

end

function ArenaProcess.onGC_PlayArenaRecode_Ntf(msg)

    local res = Proto.parseP_GC_PlayArenaRecode_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_PlayArenaRecode_Ntf")

    if CSResourceMgr.getCsbObj("Player/Arena/ArenaWinView.csb") then
        ArenaWinViewMgr.setRecordRounds(res.turnIndex, res.recode)
    elseif CSResourceMgr.getCsbObj("Player/Arena/ArenaRecord.csb") then
        ArenaRecordMgr.setRecordRounds(res.turnIndex, res.recode)
    end

    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PLAYARENARECODE_NTF)
    return res.code

end

function ArenaProcess.onGC_GetArenaRecode_Ntf(msg)

    local res = Proto.parseP_GC_GetArenaRecode_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_GetArenaRecode_Ntf")

    if res.isNew==1 and not CSResourceMgr.getCsbObj("Player/Arena/ArenaRecord.csb") then
        ArenaViewMgr.isNew = res.isNew
    end
    if CSResourceMgr.getCsbObj("Player/Arena/ArenaWinView.csb") then
        ArenaWinViewMgr.update(res.recodes)
    elseif CSResourceMgr.getCsbObj("Player/Arena/ArenaRecord.csb") then
        if #res.recodes == 0 then
            ArenaRecordMgr.stopRequireRecord()
        else
            ArenaRecordMgr.update(res.recodes)
        end
    end

    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETARENARECODE_NTF)
    return res.code

end

function ArenaProcess.onGC_QueryMArenaData_Ack(msg)

    local res = Proto.parseP_GC_QueryMArenaData_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_QueryMArenaData_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        ArenaInfo.update({rank=res.rank, teamID=res.teamID})
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_QUERYMARENADATA_ACK)
    return res.code

end

function ArenaProcess.onGC_MArenaRankChange_Ntf(msg)

    local res = Proto.parseP_GC_MArenaRankChange_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_MArenaRankChange_Ntf")
    print("Char Rank update:", res.rank)
    ArenaInfo.update({rank=res.rank})
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_MARENARANKCHANGE_NTF)
    return res.code

end

function ArenaProcess.onGC_MArenaPetsChange_Ntf(msg)

    local res = Proto.parseP_GC_MArenaPetsChange_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_MArenaPetsChange_Ntf")
    print("GC_MArenaPetsChange_Ntf")
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_MARENAPETSCHANGE_NTF)
    return res.code

end

function ArenaProcess.onGC_RandomMArenaEnemys_Ack(msg)

    local res = Proto.parseP_GC_RandomMArenaEnemys_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_RandomMArenaEnemys_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("GC_RandomMArenaEnemys_Ack enemys size:", #res.enemys)
        ArenaInfo.setEnemys(res.enemys)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_RANDOMMARENAENEMYS_ACK)
    return res.code

end

function ArenaProcess.onGC_ChangeMArenaPetObjIDs_Ack(msg)

    local res = Proto.parseP_GC_ChangeMArenaPetObjIDs_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ChangeMArenaPetObjIDs_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CHANGEMARENAPETOBJIDS_ACK)
    return res.code

end

function ArenaProcess.onGC_JoinMArena_Ack(msg)

    local res = Proto.parseP_GC_JoinMArena_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_JoinMArena_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        ArenaInfo.update({rank=res.rank, teamID=res.teamID})
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_JOINMARENA_ACK)
    return res.code

end

function ArenaProcess.onGC_MArenaRankFight_Ack(msg)

    local res = Proto.parseP_GC_MArenaRankFight_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_MArenaRankFight_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("GC_ArenaRankFight_Ack battleID:", res.battleID)
        print("GC_ArenaRankFight_Ack self size:", #res.self)
        for k,v in pairs(res) do
            print("dddddddddddddddddddddddd : ",k,v)
        end
        BattlePVPMgr.setBattleID(res.battleID)
        BattlePVPMgr.setserverID(res.serverID)
        local petTbl ={}
        petTbl.self = {}
        petTbl.self[OUTPETS] = res.self
        petTbl.self[INPETS] = res.selfHelper
        for var=1, #res.self do
            print(res.self[var])
        end
        print("GC_ArenaRankFight_Ack enemys size:", #res.enemys)
        for var=1, #res.enemys do
            print(res.enemys[var])
        end
        petTbl.enemys = {}
        petTbl.enemys[OUTPETS] = res.enemys
        petTbl.enemys[INPETS] = res.enemysHelper
        ArenaInfo.setBattleInfo(petTbl)
    else
        if GameGuideMgr.arenaGuideStart == true then
            GameGuideMgr.backToArena()
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_MARENARANKFIGHT_ACK)
    return res.code

end

function ArenaProcess.onGC_MArenaRankFightEnd_Ack(msg)

    local res = Proto.parseP_GC_MArenaRankFightEnd_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_MArenaRankFightEnd_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_MARENARANKFIGHTEND_ACK)
    return res.code

end

function ArenaProcess.onGC_QueryMArenaRank_Ack(msg)

    local res = Proto.parseP_GC_QueryMArenaRank_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_QueryMArenaRank_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("GC_QueryMArenaRank_Ack ", #res.soldiers)
        for k,v in pairs(res.soldiers) do
            print(k,v)
        end
        ArenaInfo.setWorldRankList(res.soldiers)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_QUERYMARENARANK_ACK)
    return res.code

end

function ArenaProcess.onGC_QueryMArenaSoldierDetail_Ack(msg)

    local res = Proto.parseP_GC_QueryMArenaSoldierDetail_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_QueryMArenaSoldierDetail_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("GC_QueryMArenaSoldierDetail_Ack ", res.charID, res.teamID)
        for var=1, #res.pets do
            print(res.pets[var])
        end
        ArenaInfo.setRankListPets(res.charID, res.pets)
        ArenaInfo.setRankListHelperPets(res.charID, res.helperPets)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_QUERYMARENASOLDIERDETAIL_ACK)
    return res.code

end

function ArenaProcess.onGC_ClearMArenaCD_Ack(msg)

    local res = Proto.parseP_GC_ClearMArenaCD_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ClearMArenaCD_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CLEARMARENACD_ACK)
    return res.code

end

function ArenaProcess.onGC_BuyMArenaFightTimes_Ack(msg)

    local res = Proto.parseP_GC_BuyMArenaFightTimes_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_BuyMArenaFightTimes_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_BUYMARENAFIGHTTIMES_ACK)
    return res.code

end

function ArenaProcess.onGC_GetMArenaAward_Ack(msg)

    local res = Proto.parseP_GC_GetMArenaAward_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetMArenaAward_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETMARENAAWARD_ACK)
    return res.code

end

function ArenaProcess.onGC_GetMArenaRecode_Ack(msg)

    local res = Proto.parseP_GC_GetMArenaRecode_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetMArenaRecode_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETMARENARECODE_ACK)
    return res.code

end

function ArenaProcess.onGC_PlayMArenaRecode_Ack(msg)

    local res = Proto.parseP_GC_PlayMArenaRecode_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PlayMArenaRecode_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        if CSResourceMgr.getCsbObj("Player/Arena/ArenaWinView.csb") then
            ArenaWinViewMgr.setBattlePets(res.recodeInfo)
            ArenaWinViewMgr.setRecordNum(res.recodeNum)
        elseif CSResourceMgr.getCsbObj("Player/Arena/ArenaRecord.csb") then
            ArenaRecordMgr.setBattlePets(res.recodeInfo)
            ArenaRecordMgr.setRecordNum(res.recodeNum)     
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PLAYMARENARECODE_ACK)
    return res.code

end

function ArenaProcess.onGC_PlayMArenaRecode_Ntf(msg)

    local res = Proto.parseP_GC_PlayMArenaRecode_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_PlayMArenaRecode_Ntf")
    
    if CSResourceMgr.getCsbObj("Player/Arena/ArenaWinView.csb") then
        ArenaWinViewMgr.setRecordRounds(res.turnIndex, res.recode)
    elseif CSResourceMgr.getCsbObj("Player/Arena/ArenaRecord.csb") then
        ArenaRecordMgr.setRecordRounds(res.turnIndex, res.recode)
    end

    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PLAYMARENARECODE_NTF)
    return res.code

end

function ArenaProcess.onGC_GetMArenaRecode_Ntf(msg)

    local res = Proto.parseP_GC_GetMArenaRecode_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_GetMArenaRecode_Ntf")
    
    if res.isNew==1 and not CSResourceMgr.getCsbObj("Player/Arena/ArenaRecord.csb") then
        ArenaViewMgr.isNew = res.isNew
    end
    if CSResourceMgr.getCsbObj("Player/Arena/ArenaWinView.csb") then
        ArenaWinViewMgr.update(res.recodes)
    elseif CSResourceMgr.getCsbObj("Player/Arena/ArenaRecord.csb") then
        if #res.recodes == 0 then
            ArenaRecordMgr.stopRequireRecord()
        else
            ArenaRecordMgr.update(res.recodes)
        end
    end

    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETMARENARECODE_NTF)
    return res.code

end

function ArenaProcess.onGC_PlayArenaRecode2_Ntf(msg)

    local res = Proto.parseP_GC_PlayArenaRecode2_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_PlayArenaRecode2_Ntf")

    ArenaRecordMgr.addPetInfo2(res.recodeInfo)

    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PLAYARENARECODE2_NTF)
    return res.code

end

function ArenaProcess.onGC_PlayArenaRecode3_Ntf(msg)

    local res = Proto.parseP_GC_PlayArenaRecode3_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_PlayArenaRecode3_Ntf")
    
    ArenaRecordMgr.addPetInfo3(res.recodeInfo)

    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PLAYARENARECODE3_NTF)
    return res.code

end

function ArenaProcess.onGC_PlayArenaRecode4_Ntf(msg)

    local res = Proto.parseP_GC_PlayArenaRecode4_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_PlayArenaRecode4_Ntf")

    ArenaRecordMgr.addPetInfo4(res.recodeInfo)

    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PLAYARENARECODE4_NTF)
    return res.code

end

function ArenaProcess.onGC_PlayMArenaRecode2_Ntf(msg)

    local res = Proto.parseP_GC_PlayMArenaRecode2_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_PlayMArenaRecode2_Ntf")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PLAYMARENARECODE2_NTF)
    return res.code

end

function ArenaProcess.onGC_PlayMArenaRecode3_Ntf(msg)

    local res = Proto.parseP_GC_PlayMArenaRecode3_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_PlayMArenaRecode3_Ntf")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PLAYMARENARECODE3_NTF)
    return res.code

end

function ArenaProcess.onGC_PlayMArenaRecode4_Ntf(msg)

    local res = Proto.parseP_GC_PlayMArenaRecode4_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_PlayMArenaRecode4_Ntf")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PLAYMARENARECODE4_NTF)
    return res.code

end

return ArenaProcess
