local BattleMapMgr = {}

BattleMapMgr.handle     = nil
BattleMapMgr.scheduler  = nil
local battleMgr         = nil
local mPVPChallenger    = {}
local mPVPBeChallenge   = {}
local mIsArena          = false
local mIsCommonBattle   = true
local mAdveChallenge    = {false,{}} 
local battleScene       = nil
local petInfo           = {}
local catchPet          = 0
local enemyPets         = {}
local myPets            = {}
local funcCallBK        = nil 
local testMyPetID       = 9
local testHisPetID      = 9
local testSKillID       = {11,11,11,11}
local hisTestSkillID    = {11,11,11,11}
local myTemporaryBuffer = {}
local potentialSkills   = {}
local fashionSkills     = {}
local lastDialog        = ""
local testPaSkills      = nil 
local hisTestPaSkills   = nil
local isInterNet        = true
local newExp            = 0
local myPetSkin         = 0
local hisPetSkin        = 0 
local BattleCotroller = require("src.GameMgr.Battle.BattleCotroller") 


---重新初始化BattleMapMgr，用于动态lua调试
function BattleMapMgr.Init()
    print("BattleMapMgr初始化")
--    BattlePVPMgr.mIsPVPBattle = false
    mPVPChallenger = {}
    mPVPBeChallenge = {}
    BattlePVPMgr.mPVPIsChallenger = false
    catchPet = 0
end

function BattleMapMgr.getFashionSkills()
    NetInterface.sendWithBlock("GC_GetFashions_Ack", function()
        local FashionSend = require("src.Net.Send.FashionSend")
        FashionSend.sendCG_GetFashions_Req()
    end, function()
        local vec = {}
        for k,v in pairs(fashionTabel.curFashion) do
            local fashionInfo = ItemInfo.getFashionItemInfoById(v)
            if fashionInfo.petAttributeType ~= 0 then
                table.insert(vec,fashionInfo.skillID)
            end
        end
        
    end, function(code)
        TipsMgr.showError(scene, code)
    end)
end

function BattleMapMgr.setTemporaryBuffer(bufferType,percent,value)
    myTemporaryBuffer[bufferType] = {per = percent,val = value}
end

function BattleMapMgr.getTemporaryBuffer(bufferType)
    if not myTemporaryBuffer[bufferType] then
        return false
    else
        return myTemporaryBuffer[bufferType]
    end
end

function BattleMapMgr.cleanTemporaryBuffer()
    myTemporaryBuffer = {}
end

function BattleMapMgr.cleanPVPInfo() 
    BattlePVPMgr.mIsPVPBattle       = false
    BattlePVPMgr.mPVPIsChallenger   = false
    BattlePVPMgr.cleanPVPInfo() 
    mPVPChallenger      = {}
    mPVPBeChallenge     = {} 
    myTemporaryBuffer   = {}
    lastDialog  = ""
    catchPet            = 0
end

function BattleMapMgr.afterCleanPVPInfo()
    mAdveChallenge      = {false,{}}
    mIsArena            = false
    
end

function BattleMapMgr.cleanRecord()
    mIsCommonBattle = true
    BattleCotroller.cleanRecord()
end
 
function BattleMapMgr.getIsCommonBattle()
    return mIsCommonBattle
end

function BattleMapMgr.getlastDialog()
    return lastDialog
end

function BattleMapMgr.setArenaBattle(sendMyPets,sendEnemyPets,callBack,isAuto)
    if isAuto == nil then
        mIsArena = false
    else
        mIsArena = true
    end
    print("mIsArena..",mIsArena)
    mIsCommonBattle = false
    mAdveChallenge[1] = true
    catchPet = 0 
    
    local function getPetsInfo(pets)
            local playerPets = {}
            for key,var in pairs(pets) do
                local cjson = require("cjson")
                local v = cjson.decode(var)
                playerPets[key] = {}
                -- local monsInfo = AdventureInfo.getMonstrosityInfoByID(v["mID"]) 
--                print(sz_T2S(sendMyPets))
                for k,value in pairs(v) do
                    playerPets[key][k] = value
                end
--                playerPets[key] = {atk = v.atk,def = v.def,exp = v.exp,level = v.level,objID = v.objID,pokeID = v.pokeID,pps = v.pps,
--                satk = v.satk,sdef = v.sdef,speed = v.speed,skills = v.skills,paSkills = v.paSkills} 
            end
            return playerPets
    end
    
    if type(sendMyPets[OUTPETS][1]) == "table" then
        myPets[OUTPETS] = sendMyPets[OUTPETS]
        myPets[INPETS]  = sendMyPets[INPETS]
    else
        myPets[OUTPETS] = getPetsInfo(sendMyPets[OUTPETS])
        myPets[INPETS]  = getPetsInfo(sendMyPets[INPETS])
    end
    
    if type(sendEnemyPets[OUTPETS][1]) == "table" then 
        enemyPets[OUTPETS] = sendEnemyPets[OUTPETS]
        enemyPets[INPETS]  = sendEnemyPets[INPETS]
    else
        enemyPets[OUTPETS] = getPetsInfo(sendEnemyPets[OUTPETS])
        enemyPets[INPETS]  = getPetsInfo(sendEnemyPets[INPETS])
    end 
    
    funcCallBK = callBack
    SceneMgr.replaceScene(SceneMgr.getRunningScene, "BattleScene")
end

function BattleMapMgr.useCallBK(detail) 
    if funcCallBK ~= nil then
        funcCallBK(detail)
        funcCallBK = nil
    end
end

function BattleMapMgr.setBattleCallback(callFuc)
    funcCallBK = callFuc
end

function BattleMapMgr.getIsChallenger()
    return BattlePVPMgr.mPVPIsChallenger
end

function BattleMapMgr.getBattleScene() 
    return battleScene 
end

function BattleMapMgr.getPetsInfo() 
    return petInfo
end

function BattleMapMgr.getIsArena()
    return mIsArena
end

function BattleMapMgr.setIsArena(isBool)
    mIsArena = isBool
end

function BattleMapMgr.enterPVP(PVPChallenger,PVPBeChallenge,isChallenger)
    BattlePVPMgr.mIsPVPBattle = true
    BattlePVPMgr.mPVPIsChallenger = isChallenger 
    mPVPChallenger = PVPChallenger
    mPVPBeChallenge = PVPBeChallenge
    
end

function BattleMapMgr.createBattleScene(scene) 
    battleScene = scene
    local BattleGetPetInfo = require("src.GameMgr.Battle.BattleGetPetInfo")
    local outPets    = 0
    local inPets     = 1
    
    if BattlePVPMgr.mIsPVPBattle == true then
        mAdveChallenge[1] = true
    end
    battleMgr         = nil
    if isInterNet then 
        if not mIsArena then   
            if SceneMgr.previousScene == "SearchingScene" then 
                myPets[outPets],myPets[inPets] = AdvPetsMgr.getCurrMyPets()
            elseif SceneMgr.previousScene == "LostTowerScene" then
                myPets[outPets],myPets[inPets] = LtPetsMgr.getCurrMyPets() 
            else
                if #myPets <= 0 then
                    if mAdveChallenge[2]["mPets"] then
                        myPets[outPets] = mAdveChallenge[2]["mPets"]
                        myPets[inPets]  = mAdveChallenge[2]["hPets"]

                    else
                        myPets[outPets] = PokemonInfo.getActivePets()
                        local helpObjID = PokemonInfo.getPetHelpArmy()
                        myPets[inPets]  = {}
                        for key,var in pairs(helpObjID) do
                            myPets[inPets][key] = PokemonInfo.getPetInfoByObjID(var)
                        end
                    end
                end
            end
            if not myPets[inPets] then
                myPets[inPets] = {}
            end
            print("非竞技场宠物信息为....") 
        end 
        print("敌人信息信息",sz_T2S(enemyPets))
        if not enemyPets[outPets] then 
            print("没有敌人的信息表")
            DialogBoxMgr.showSmallDialogBox(BattleMapMgr.getBattleScene(), 1, "没有敌人的信息表", function()
                end,function()end)
            BattleMapMgr.getBattleScene():performWithDelay(function()
                GameInit.Init(true)
                SceneMgr.replaceScene(SceneMgr.getRunningScene, "LoginScene")
            end,2.0)      
            return
        end

        if not enemyPets[inPets] then
            enemyPets[inPets] = {}
        end

        petInfo = BattleGetPetInfo.new(myPets,enemyPets,battleScene)
        potentialSkills = AchievementListMgr.getAttackSkillIDs() 
    else    
        myPets      = {}
        enemyPets   = {}
        local pet = {paSkills = testPaSkills,atk = 0,def = 0,exp = 0,level = 1,objID = 1,
            pokeID = testMyPetID,satk = 0,sdef = 0,speed = 0,
            skills = {testSKillID[1],testSKillID[2],testSKillID[3],testSKillID[4]},skin = myPetSkin,Stage = 0}
        local hisPet = {atk = 0,def = 0,exp = 0,level = 1,objID = 2,
            pokeID = testHisPetID,satk = 0,sdef = 0,speed = 0,
            skills = {hisTestSkillID[1],hisTestSkillID[2],hisTestSkillID[3],hisTestSkillID[4],Stage = 0},
            skin = HisPetSkin,paSkills = hisTestPaSkills} 
       
        myPets[outPets] = {pet,pet,pet}
        myPets[inPets]  = {pet,pet,pet}
        enemyPets[outPets] = {hisPet,hisPet,hisPet}
        enemyPets[inPets] = {hisPet,hisPet,hisPet}
        
--        for i = 1,6 do 
--            myPets[i] = {paSkills = testPaSkills,atk = 10,hp = 130,hpmax = 130,def = 10,exp = 0,level = 1,objID = 3,pokeID = testMyPetID,satk = 10,sdef = 10,speed = 13,skills = {testSKillID[1],testSKillID[2],testSKillID[3],testSKillID[4]}}
--        end 
 
--        getEnemyPetsInfo(mAdveChallenge[2]["pets"]) 
        petInfo = BattleGetPetInfo.new(myPets,enemyPets,battleScene) 
        
    end
    print("BattleMapMgr.getIsArena......",BattleMapMgr.getIsArena())
    print("BattleMapMgr.mIsPVPBattle......",BattlePVPMgr.mIsPVPBattle)  
    if not BattleMapMgr.getIsArena() and not  BattlePVPMgr.mIsPVPBattle then
        petInfo[TEAM_A].potentialSkills = potentialSkills
        petInfo[TEAM_A].FashionSkills   = AvatarViewMgr.getFashionSkills()
        battleMgr = BattleMgr.new(clone(petInfo),BattleMapMgr.getWeather())  
    end  
    
    BattleUIMgr.Init(battleMgr,clone(petInfo),battleScene)
    BattleCotroller.init(battleMgr) 
    if BattleMapMgr.getIsArena() or BattlePVPMgr.mIsPVPBattle then 
        BattleCotroller.setIsRecord(true)
    end


    BattleUIMgr.addUI()
    
end  

function BattleMapMgr.setMyPetSkin(skin)
    myPetSkin = skin
end

function BattleMapMgr.setHisPetSkin(skin)
    HisPetSkin = skin
end

function BattleMapMgr.setPotentialSkills(IDs)
    potentialSkills = IDs
end

function BattleMapMgr.enterBattleUI() 
    BattleUIMgr.Init(battleMgr,clone(petInfo),battleScene)
    BattleUIMgr.addUI()
end

function BattleMapMgr.setIsConnectNet(isBool)
    isInterNet = isBool
end

function BattleMapMgr.setNewExp(exp)
    newExp = exp
end

function BattleMapMgr.getNewExp()
    return newExp    
end

function BattleMapMgr.setTestSkillID(ids)
    testSKillID = ids
    if #testSKillID < 4 then
        print("设置技能失败")
    end
    print("设置技能..."..sz_T2S(testSKillID))

end

function BattleMapMgr.setHisTestSkillID(ids)
    hisTestSkillID = ids
    if #hisTestSkillID < 4 then
        print("设置技能失败")
    end
    print("设置敌方技能..."..sz_T2S(hisTestSkillID))

end

function BattleMapMgr.sethisPaSkillID(paSkills)
    hisTestPaSkills = paSkills 
end

function BattleMapMgr.setpaSkillID(paSkills)
    testPaSkills = paSkills
end
 
function BattleMapMgr.getEnemyPets()
    return enemyPets[OUTPETS]
end

function BattleMapMgr.setEnemyPets(pets)
    enemyPets = pets
end

function BattleMapMgr.setMyPets(pets)
    myPets = pets
end 

function BattleMapMgr.battleReq(isNeedVs,battleType,battleTypeID,name,callback)
    if NetInterface.isConnect then  
        mAdveChallenge[1] = isNeedVs
        mAdveChallenge[2]["name"] = name

        local PVESend = require("src.Net.Send.PVESend")
        local param = {battleType = battleType,battleTypeID = battleTypeID} 

        PVESend.sendCG_CreatePVEBattle_Req(param) 
        LoadingView.show(SceneMgr.getRunningScene)
        if callback then
            funcCallBK = callback
        end
    else
        print("BattleMapMgr.battleReq !NetInterface.isConnect") 
        SceneMgr.replaceScene(SceneMgr.getRunningScene, "BattleScene") 
    end
end

function BattleMapMgr.sendReBattleServe(info)
--    if NetInterface.isConnect then
    local isManDialog = false   
        mAdveChallenge = info
        local battleTypeSubID = info[2].battleTypeSubID or 0 
        local PVESend = require("src.Net.Send.PVESend")
        local param = {battleType = mAdveChallenge[2]["type"],battleTypeID = 1,battleTypeSubID = battleTypeSubID}
 
        local function sendBattleReq()
            NetInterface.sendWithBlock("GC_CREATEPVEBATTLE_ACK", function()
                PVESend.sendCG_CreatePVEBattle_Req(param)
            end)
        end
        
        if param.battleType == Proto.BTT_ADVENTURE_MONSTER_MAN_GROUP
        or param.battleType == Proto.BTT_LOSTTOWER_MONSTER_MAN_GROUP
        or param.battleType == Proto.BTT_MONSTER_MAN_GROUP
        then 
            if SceneMgr.currentScene == "SearchingScene" or SceneMgr.currentScene == "MainScene" then
                if mAdveChallenge[2]["GroupID"] and BattleUIMgr.firstBattle ~= 1 then
            
                    local dialogs =  AdventureInfo.getMonsterGroupManInfoByID(mAdveChallenge[2]["GroupID"]).commingTalk
                    lastDialog = AdventureInfo.getMonsterGroupManInfoByID(mAdveChallenge[2]["GroupID"]).deadTalk
                    if dialogs ~= "" then
                       BattleMapMgr.showBattleDialogs(dialogs,sendBattleReq)
                       isManDialog = true
                    end

                end
            end
        end
        
        if param.battleType == Proto.BTT_ADVENTURE_MONSTER  
        or param.battleType == Proto.BTT_ADVENTURE_MONSTER_MAN_GROUP 
        then
            param.battleTypeID = mAdveChallenge[2]["sceneID"]
        elseif param.battleType == Proto.BTT_MONSTER
        or param.battleType == Proto.BTT_LOSTTOWER_MONSTER
        or param.battleType == Proto.BTT_FAMILYDUNGEON_MONSTER
        or param.battleType == Proto.BTT_TEAMDUNGEON_MONSTER
        then
            param.battleTypeID = mAdveChallenge[2]["pets"][1]
        elseif param.battleType == Proto.BTT_MONSTER_MAN_GROUP 
        or param.battleType == Proto.BTT_MONSTER_GROUP 
        or param.battleType == Proto.BTT_LOSTTOWER_MONSTER_MAN_GROUP
        or param.battleType == Proto.BTT_LOSTTOWER_BOSS
        then   
            param.battleTypeID =mAdveChallenge[2]["GroupID"] 
        elseif param.battleType == Proto.BTT_EXPLORE_DIFFCULT_UNLOCK then
            param.battleTypeID =mAdveChallenge[2]["attr"]
        end

        if not isManDialog then
            sendBattleReq()
        end
        
        if info[2].callback then
            funcCallBK = info[2].callback
        end
--    else 
--        SceneMgr.replaceScene(SceneMgr.getRunningScene, "BattleScene") 
--    end 
     
end

function BattleMapMgr.makeBattleOverWithoutSummary()
    mAdveChallenge[2].nosumm = true
end

function BattleMapMgr.getisGoSummary()
    return mAdveChallenge[2].nosumm
end

function BattleMapMgr.firstBattleShow()
    local petInfo  = TxtReader.new("Config/FirstBattle.txt")
        petInfo.init({"id","pokeID","name","level",
                            "stage","star","skin",
                            "hp","speed","atk","def","satk","sdef","skill1",
                            "skill2","skill3","skill4","anger","musicID","field"}, 1
                        ,{id=1,pokeID=1,level=1,stage=1,star=1,skin=1,hp=1,
                            speed=1,atk=1,def=1,satk=1,sdef=1,skill1=1,skill2=1,
                            skill3=1,skill4=1,anger=1,musicID=1}) 
    local myPets      = {} 
    local enemyPets   = {} 
    myPets[OUTPETS] = {}
    myPets[INPETS]  = {}

    enemyPets[OUTPETS] = {}
    enemyPets[INPETS]  = {}  
 
    mAdveChallenge[2].field     = petInfo.get(1).field
    mAdveChallenge[2].musicID   = petInfo.get(1).musicID
    mAdveChallenge[1]           = true

    BattleCCSB.stopAutoBattle(true) 
    funcCallBK = function()
        MapSeekerMgr.SeekFunc = function()
                NpcMgr.addNPC(4, GameGuideMgr.NPC_NAME[1], GameGuideMgr.NPC_POSX[2], nil).ani:setScaleX(1)
                ChoosePetViewMgr.addUI(SceneMgr.getRunningScene)
                TownMapMgr.Pet:setVisible(false) 
                NpcDialogueMgr.show(4, function()    
                    NpcDialogueMgr.show(44, function()
                        ChoosePetViewMgr.show()
                    end)
                end)
        end
    end

    for i = 1,3 do
        local value = petInfo.get(i)
        local pet = {atk = 0,atkV = value.atk,def = 0,defV = value.def,exp = 0,level = value.level,objID = 1,
            pokeID = value.pokeID,satk = 0,satkV = value.satk,sdef = 0,sdefV = value.sdef,speed = 0,speedV = value.speed,
            skills = {value.skill1,value.skill2,value.skill3,value.skill4},skin = value.skin,hp=value.hp,hpmax = value.hp,
            Stage = value.stage,star = value.star,anger=value.anger}
        myPets[OUTPETS][i] = pet
    end
    local petValue = petInfo.get(4)
    enemyPets[OUTPETS][1] = {atk = 0,atkV = petValue.atk,def = 0,defV = petValue.def,exp = 0,level = petValue.level,objID = 1,
            pokeID = petValue.pokeID,satk = 0,satkV = petValue.satk,sdef = 0,sdefV = petValue.sdef,speed = 0,speedV = petValue.speed,
            skills = {petValue.skill1,petValue.skill2,petValue.skill3,petValue.skill4},skin = petValue.skin,hp=petValue.hp,hpmax = petValue.hp,
            Stage = petValue.stage,star = petValue.star,anger = petValue.anger}
       
        
    BattleMapMgr.setEnemyPets(enemyPets)
    BattleMapMgr.setMyPets(myPets) 
    lastDialog = "50225,50226"

    -- local function showDailog()
    --     BattleMapMgr.showBattleDialogs("50224",function()
    --             BattleCotroller.judgeNextBattle()
    --             BattleGuide.funcs[GUIDE_FIRST] = nil 
    --         end)
    -- end
 
    -- BattleGuide.funcs[GUIDE_FIRST] = showDailog
    BattleCCSB.stopQuitBattle() 
    BattleMapMgr.makeBattleOverWithoutSummary()  
    BattleCotroller.setNoMiss(true)
    BattleMapMgr.setBossShow()
    BattleMapMgr.setFilmShow()

    SceneMgr.replaceScene(SceneMgr.getRunningScene, "BattleScene") 
end

function BattleMapMgr.showBattleDialogs(dialogs,callback)
    local strTbl = lua_string_split(dialogs, ",")
    for key,var in pairs(strTbl) do
        strTbl[key] = tonumber(var)
    end
    local function showDialog(index)
        NpcDialogueMgr.show(strTbl[index], function()
            if strTbl[index+1] then
                showDialog(index+1)
            else
                callback()
            end
        end) 
    end
    
    showDialog(1)

end

function BattleMapMgr.sendGameOver(state,sendPets)
    local pets = {}
    
    if sendPets then
        for key,var in pairs(sendPets.hp) do
            table.insert(pets,sendPets.objID[key]..","..sendPets.hp[key])
        end
    end
    print("sendGameOver..........",state,sz_T2S(pets))

    NetInterface.sendWithBlock("GC_PVEBATTLEEND_ACK", function()
            local PVESend = require("src.Net.Send.PVESend")
            PVESend.sendCG_PVEBattleEnd_Req({isWin = state,battleDetails = pets})
        end, function()
            if catchPet ~= 0 then 
                BattleUIMgr.catchPet() 
                BattleMapMgr.cleanPVPInfo()
                BattlePVPMgr.cleanPVPInfo()
            end
        end, function(code)
            
            TipsMgr.showError(nil, code)
        end)
end

function BattleMapMgr.battleSchedulerStart(sec)
    local time  = sec
    if sec == nil then
        time = 1.0
    end

    BattleMapMgr.scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
    BattleMapMgr.handle = BattleMapMgr.scheduler.scheduleGlobal(function()
        battleMgr:oneRoleTurn() 
    end,time)
end 

function BattleMapMgr.setCanCatchPet(PetID) 
    catchPet = PetID
end

function BattleMapMgr.getCanCatchPet() 
    return catchPet 
end

function BattleMapMgr.getAdvChallage()
    return mAdveChallenge[1]
end

function BattleMapMgr.getCanShareBattle()
    return mAdveChallenge[2].share
end

function BattleMapMgr.setShareBattle()
    mAdveChallenge[2].share = true
end

function BattleMapMgr.setBossShow()
    mAdveChallenge[2].boss = true
end

function BattleMapMgr.setFilmShow()
    mAdveChallenge[2].film = true
end

function BattleMapMgr.getIsFilm()
    return mAdveChallenge[2].film
end

function BattleMapMgr.getBattleSceneInfo()
    return mAdveChallenge[2]
end

function BattleMapMgr.getWeather()
    return mAdveChallenge[2].weather
end

function BattleMapMgr.getField()
    return mAdveChallenge[2].field
end

function BattleMapMgr.setTestMyPetID(id)
    testMyPetID = id
end

function BattleMapMgr.setTestHisPetID(id)
    testHisPetID = id
end

function BattleMapMgr.getEnemyName() 
    if mAdveChallenge[2]["name"] == nil then
        mAdveChallenge[2]["name"] = "敌方"
    end
    return mAdveChallenge[2]["name"]
end

function BattleMapMgr.getseniorFigure()
    return "Battle/verticalImg/"..mAdveChallenge[2]["seniorFigure"]..".png"
end
function BattleMapMgr.setAdvChallage(isbool,tbl) 
    mAdveChallenge[1] = isbool  
    mAdveChallenge[2] = tbl
end

function BattleMapMgr.setRecordToBattle(TeamA,TeamB,records,result) 
    BattleCotroller.setTotalRecord(records,result)
    BattleCotroller.setIsRecord(true)
    myPets      = TeamA
    enemyPets   = TeamB 
    mIsArena    = true
    mAdveChallenge[1] = true
    SceneMgr.replaceScene(SceneMgr.getRunningScene, "BattleScene")
end

function BattleMapMgr.battleSchedulerCancel()
    if BattleMapMgr.scheduler ~= nil and BattleMapMgr.handle ~= nil then 
        BattleMapMgr.scheduler.unscheduleGlobal(BattleMapMgr.handle) 
    end
    BattleMapMgr.scheduler = nil
    BattleMapMgr.handle = nil 
end

function BattleMapMgr.getBattlePets()
    return clone(myPets), clone(enemyPets)
end
return BattleMapMgr