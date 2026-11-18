require("src.Net.Proto.ProtoInclude")

local PVEProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function PVEProcess.init()
    NetMgr.addProcess(Proto.Command.GC_PVEPOKEMONCATCH_ACK,
        PVEProcess.onGC_PVEPokemonCatch_Ack)
    NetMgr.addProcess(Proto.Command.GC_PVEBATTLEEND_ACK,
        PVEProcess.onGC_PVEBattleEnd_Ack)
    NetMgr.addProcess(Proto.Command.GC_CREATEPVEBATTLE_ACK,
        PVEProcess.onGC_CreatePVEBattle_Ack)
    NetMgr.addProcess(Proto.Command.GC_INDULGETHREE_NTF,
        PVEProcess.onGC_Test_Ntf)
end

function PVEProcess.onGC_CreatePVEBattle_Ack(msg)
    local res = Proto.parseP_GC_CreatePVEBattle_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_CreatePVEBattle_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        if SceneMgr.currentScene == "BattleScene" then
            return
        end
        LoadingView.hide()
        print("onGC_CreatePVEBattle_Ack")
        print(sz_T2S(res.monsters))
        local canCatchPet = 0
        local function getEnemyPetsInfoServe(emTbl)
            local Pets = {}
            for key,var in pairs(emTbl) do
                local cjson = require("cjson")
                print("monsInfoBefore~~~~~~~~~~~~~~~~~")
                print(sz_T2S(var)) 
                local v = cjson.decode(var)
         
                local monsInfo = nil
                local petPaSkills = {}
                local star    = 0
                local Stage   = 0

                if SceneMgr.currentScene == "LostTowerScene" then
                    star = v.petStar
                    monsInfo = LostTowerInfo.getLostTowerMonsterInfoById(v["mID"])
                -- elseif SceneMgr.currentScene == "SearchingScene" then
                    
                elseif SceneMgr.currentScene == "FamilyCopyMapScene" then
                    monsInfo = FamilyDataInfo.getFamilyMonsterInfoById(v["mID"])
                    star = monsInfo.petStar
                elseif SceneMgr.currentScene == "TeamCopyMapScene" then
                    monsInfo = TeamMapInfo.getTeamMonsterInfoById(v["mID"])
                    star = monsInfo.petStar
                else 
                    monsInfo = AdventureInfo.getMonstrosityInfoByID(v["mID"])
                    print("find monsInfo......mID....",v["mID"]) 
                    star = monsInfo.petStar
                end
                
                for key,var in pairs(monsInfo.paSkills) do
                    table.insert(petPaSkills,{paSkillID = var,paSkillType = 2})
                end
                
                local petname = LuaSqlite.getLanguageByKey(monsInfo.number)
                
                if v.petStage then
                    Stage = v.petStage
                else
                    Stage = monsInfo.petStage
                end
                
                Pets[key] = {monster = monsInfo,level = v.level,pokeID = monsInfo.petnumber,
                    skills = {v.skill1,v.skill2,v.skill3,monsInfo.skill4},paSkills = petPaSkills,
                    star = star,Stage = Stage,name = petname,hp = v.hp,hpmax = monsInfo.maxHP,skin = v.skin}
                if v.canCatch ~= nil then
                    canCatchPet = monsInfo.petnumber
                end
                print("petnumber~~~~~~skin~~~~~~~~~~~~",v.skin) 
                print("canCatchPet...."..canCatchPet)  
                BattleMapMgr.setCanCatchPet(canCatchPet)   
            end
            return Pets
        end
        local enemyPets = {}
        enemyPets[OUTPETS] = getEnemyPetsInfoServe(res.monsters)
        if res.helpMonsters then 
            if res.helpMonsters[1] ~= "" then
                enemyPets[INPETS] = getEnemyPetsInfoServe(res.helpMonsters) 
            else
                enemyPets[INPETS]  = {}
            end
        else 
            enemyPets[INPETS]  = {}
        end
        if res.exp then
            print("res.onGC_CreatePVEBattle_Ack.exp~~~~~~~~~~~~~~.."..res.exp) 
            BattleMapMgr.setNewExp(res.exp)
        end
--        local enemyPets = getEnemyPetsInfoServe(res.monsters)
        BattleMapMgr.setEnemyPets(enemyPets) 
        print("敌人的列表信息为 "..sz_T2S(enemyPets)) 
        if #enemyPets <= 0 then 
            print("敌人的列表信息为空")
            return
        end 
        SceneMgr.replaceScene(SceneMgr.getRunningScene, "BattleScene") 
    else
        -- SearchingMgr locks movement before the server confirms the encounter.
        -- Release that lock and restore the trainer cell when the server rejects
        -- the request so a corrected/configured encounter can be retried.
        if SceneMgr.currentScene == "SearchingScene" then
            SearchingMgr.onbattle = false
            SearchingMgr.canMove = true
            local battlePos = SearchingMapMgr and SearchingMapMgr.battlePos
            if battlePos and battlePos > 0
            and SearchingMgr.eventStateInfoTable
            and SearchingMgr.eventStateInfoTable[battlePos] == 2 then
                SearchingMgr.eventStateInfoTable[battlePos] = 1
            end
        end
        StandardTipsMgr.show(1, "error code: "..res.code)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CREATEPVEBATTLE_ACK)
    return res.code
end

function PVEProcess.onGC_PVEBattleEnd_Ack(msg)

    local res = Proto.parseP_GC_PVEBattleEnd_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PVEBattleEnd_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("onGC_PVEBattleEnd_Ack is successful")
        if res.exp then
--            print("res.exp~~~~~~~~~~~~~~.."..res.exp)
--            BattleMapMgr.setNewExp(res.exp)
        end
    else
        StandardTipsMgr.show(1, "error code: "..res.code)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PVEBATTLEEND_ACK) 
    return res.code

end

function PVEProcess.onGC_PVEPokemonCatch_Ack(msg)

    local res = Proto.parseP_GC_PVEPokemonCatch_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PVEPokemonCatch_Ack")
    print("GC_PVEPokemonCatch_Ack..."..res.code)
    print("Proto.Error.ERROR_OK ",Proto.Error.ERROR_OK)
    local function catchPetState(catchState,catchRate)
        BattleUIMgr.ballNum[BattleUIMgr.ballID] = BattleUIMgr.ballNum[BattleUIMgr.ballID] - 1 
        CSResourceMgr.setLabelString("Battle/catch/catchDown.csb","ballNum"..BattleUIMgr.ballID, 
            "X"..BattleUIMgr.ballNum[BattleUIMgr.ballID],"",nil,0) 
        BattleUIMgr.catchPetPoccessing(BattleUIMgr.getcatchedMonster(),catchState,catchRate)
    end

    if (Proto.Error.ERROR_OK == res.code) then 
        LoadingView.hide() 
        if BattleUIMgr.firstBattle == 2 and res.isCatched == 1 then
            GameGuideMgr.finishProcess()
        end
        catchPetState(res.isCatched,res.pb)
    else
        
        StandardTipsMgr.show(1, "error code: "..res.code)
        -- A server-side rejection does not consume a ball or an attempt.
        -- Release the request's global touch lock so the player can retry.
        CocosModuleMgr.setScreenTouch(true)
        if BattleCCSB and BattleCCSB.setCatchButtonEnabled then
            BattleCCSB.setCatchButtonEnabled(true)
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_PVEPOKEMONCATCH_ACK)
    return res.code

end 

function PVEProcess.onGC_Test_Ntf(msg)
	local res = {};
	res.s = Proto.parseString(msg)
	print(res.s)
	res.a = Proto.parseVector(msg,Proto.parseDWORD)
	res.b = Proto.parseVector(msg,Proto.parseString)
end 

return PVEProcess
