local GameGuideMgr = {}

GameGuideMgr.PET = {7, 1, 4}
GameGuideMgr.NPC_POSX = {2400, 300}
GameGuideMgr.NPC_NAME = {"npcname2", "npcname998"}
GameGuideMgr.GLOW_MISSION_ID_EVO = {10028, 10029, 10030}
GameGuideMgr.GLOW_MISSION_ID_STU = {10025, 10026, 10027}
GameGuideMgr.EXPLORE_ID = nil
GameGuideMgr.originalGuideStart = false
GameGuideMgr.arenaGuideStart = false
local process = nil
local isGuiding = false
local debugGuideIDs = {}

function GameGuideMgr.Init()
    print("GameGuideMgr初始化")

    GameGuideMgr.EXPLORE_ID = nil
    GameGuideMgr.arenaGuideStart = false
    GameGuideMgr.originalGuideStart = false
    process = nil
    isGuiding = false
    debugGuideIDs = {}
    
    require("src.GameMgr.Common.GameGuideMgr1")
    require("src.GameMgr.Common.GameGuideMgr2")
    require("src.GameMgr.Common.GameGuideMgr3")
end

function GameGuideMgr.checkProcess()
    if CharInfo.get().local_freedom == true then
        return
    end
    print("检查新手引导")
    if isGuiding then
        print("当前有其他引导")
        return
    end
    if SceneMgr.currentScene=="BattleScene" then
        print("当前在战斗场景，不执行新手引导")
        return
    end
    if CharInfo.get().teamid and CharInfo.get().teamid~=0 then
        print("当前在组队中，不执行新手引导")
        return
    end
    local guideVec = QuestInfo.getCurGuideIDs()
    local index = 1
    print("当前引导任务数量", #guideVec)
    if #guideVec>0 then
        local function checkFunc(idx)
            if process~=nil and process==guideVec[idx] then
                checkFunc(idx+1)
                return
            end
            if not guideVec[idx] then
                return
            end
            process = guideVec[idx]
            CocosModuleMgr.setScreenTouch(true)
            print("当前新手引导进度", process)
            print("开始新手引导", process)
            isGuiding = true
            local result = true
            if process==1 then
                result = GameGuideMgr.firstPet()
            elseif process==10001 then
                result = GameGuideMgr.firstBattle()
            elseif process==10002 then
                result = GameGuideMgr.firstAdventure()
            elseif process==10003 then
                result = GameGuideMgr.firstMission()
            elseif process==10004 then
                result = GameGuideMgr.firstBag()
            elseif process==10005 then
                result = GameGuideMgr.firstFeed()
            elseif process==10006 then
                result = GameGuideMgr.firstStrength()
            elseif process==10007 then
                result = GameGuideMgr.secondBattle()
            elseif process==10008 then
                result = GameGuideMgr.firstPetCatch()
            elseif process==10009 then
                result = GameGuideMgr.secondAdventure()
            elseif process==10010 then
                result = GameGuideMgr.firstGacha()
            elseif process==10011 then
                result = GameGuideMgr.firstFormation()
            elseif process==10012 then
                result = GameGuideMgr.firstLostTower()
            elseif process==10013 then
                result = GameGuideMgr.firstFreePet()
            elseif process==10014 then
                result = GameGuideMgr.firstEliteAdventure()
            elseif process==10015 then
                result = GameGuideMgr.firstAchievement()
            elseif process==10016 then
                result = GameGuideMgr.firstExplore()
            elseif process==10017 then
                result = GameGuideMgr.firstStageBoss()
            elseif process==10018 then
                result = GameGuideMgr.firstEvolution()
            elseif process==10023 then
                result = GameGuideMgr.firstStarUp()
            elseif process==10024 then
                result = GameGuideMgr.firstQuickClear()
            elseif process==10032 then
                result = GameGuideMgr.firstBuff()
            elseif process==10037 then
                result = GameGuideMgr.firstSignIn()
            elseif process==10040 then
                result = GameGuideMgr.firstHome()
            elseif process==10044 then
                result = GameGuideMgr.firstStarUpEnd()
            elseif process==10045 then
                result = GameGuideMgr.firstEvolutionEnd()
            elseif process==10047 then
                result = GameGuideMgr.firstFriend()
            elseif process==10049 then
                result = GameGuideMgr.firstFashion()
            elseif process==10050 then
                result = GameGuideMgr.firstMapTransfer()
            elseif process==10051 then
                result = GameGuideMgr.newEvolutionPre()
            elseif process==10052 or process==10053 or process==10054 then
                result = GameGuideMgr.newEvolution(process)
            elseif process==10055 then
                result = GameGuideMgr.newStarUpPre()
            elseif process==10056 or process==10057 or process==10058 then
                result = GameGuideMgr.newStarUp(process)
            elseif process==10059 then
                result = GameGuideMgr.battleBookGuide()
            elseif process==10066 then
                result = GameGuideMgr.firstSkillPromote()
            elseif process==10067 then
                result = GameGuideMgr.firstTeam()
            elseif process==10068 then
                result = GameGuideMgr.firstPieceGuide()
            elseif process==10071 then
                result = GameGuideMgr.firstPetEquip()
            else
                result = nil
                if NpcDialogueMgr.checkStory(process) then
                    GameGuideMgr.checkScene("MainScene", function()
                        NpcDialogueMgr.showStory(process)
                    end)
                else
                    result = true
                    process = nil
                end
            end
            if result==true then
                print("这个引导不触发，不满足条件")
                process = nil
                isGuiding = false
                checkFunc(idx+1)
            else
                NoticeViewMgr.hide()
                CheckViewMgr.hide()
                --触发引导了,开始发送log日志
                if process then
                    local params = {}
                    params.logtype      = GameLogMgr.dataTypeEnum.EVENT_TYPE_GUIDESTART
                    params.tutorialId   = tostring(process)
                    local questdata = QuestInfo.getNewQuestInfoById(process)
                    local questname = "unknownguidename"
                    if questdata~=nil then questname =  questdata.name end
                    params.tutorialName = questname
                    params.beginTime    = os.time()
                    params.beginLevel   = CharInfo.getLevel()
                    params.endLevel     = CharInfo.getLevel()
                    params.useTime      = 0
                    params.stepType     = 0
                    GameLogMgr.OnGameStateChange(GameLogMgr.UserGameState.STATE_GAME_GUIDE,params)
                end                
            end
        end

        if SceneMgr.isProcessing then
            MapSeekerMgr.setSeekFunc(function()
                checkFunc(index)
            end)
        else
            checkFunc(index)
        end
    end
end

function GameGuideMgr.checkGuideFinishByID(process)
    local guideVec = QuestInfo.getCurGuideIDs()
    for k,v in pairs(guideVec) do
        if v == process then
            return false
        end
    end
    return true
end

function GameGuideMgr.checkProcessInTown(boolCheckLevelUp)
    if CharInfo.get().local_freedom == true then
        return
    end
    print("检查城镇新手引导")
    local townMissionIDs = {10031, 10041, 10042, 10035, 10036}
    local guideVec = QuestInfo.getCurGuideIDs()
    local flag = false
    for key, var in pairs(guideVec) do
        for k, v in pairs(townMissionIDs) do
            if v==var then
                flag = true
                break
            end
        end
    end
    if SceneMgr.currentScene~="TownScene" then
        if flag then
            BasicMenuMgr.addRedPoint(5)
        end
        print("当前不在城镇场景")
        return
    end
    if isGuiding then
        print("当前有其他引导")
        return
    end
    if boolCheckLevelUp==nil then
    	boolCheckLevelUp = true
    end
    local index = 1
    print("当前引导任务数量", #guideVec)
    if #guideVec>0 and flag then
        local function checkFunc(idx)
            process = guideVec[idx]
            if process==nil then
                return
            end
            isGuiding = true
            print("当前新手引导进度", process)
            print("开始新手引导", process)
            local result = true
            if process==townMissionIDs[1] then
                result = GameGuideMgr.firstArena()
            elseif process==townMissionIDs[2] then
                result = GameGuideMgr.firstLifeSkill()
            elseif process==townMissionIDs[3] then
                result = GameGuideMgr.firstAuctionClose()
            elseif process==townMissionIDs[4] then
                result = GameGuideMgr.firstFamily()
            elseif process==townMissionIDs[5] then
                result = GameGuideMgr.firstStarRoad()
            else
                isGuiding = false
                checkFunc(idx+1)
            end
            if result==nil then
                MailMgr.hide()
                MailMgr.hideMailInfo()
                MissionListMgr.hide()
                AwardsListMgr.hide()
            end
        end
        if SceneMgr.isProcessing then
            MapSeekerMgr.setSeekFunc(function()
                checkFunc(index)
            end)
        elseif boolCheckLevelUp then
            CocosModuleMgr.setScreenTouch(false)
            SceneMgr.getRunningScene:performWithDelay(function()
                CocosModuleMgr.setScreenTouch(true)
                if CSResourceMgr.getCsbObj("Charactor/Effects/LevelUp.csb") then
                    LevelUpViewMgr.setCloseCallback(function()
                        checkFunc(index)
                    end)
                else
                    checkFunc(index)
                end
            end, 1)
        else
            checkFunc(index)
        end
    end
end

function GameGuideMgr.checkStory()
    if CharInfo.get().local_freedom == true then
        return
    end
    if isGuiding then
        print("当前有其他引导")
        return
    end
    local guideVec = QuestInfo.getCurGuideIDs()
    local index = 1
    print("当前引导任务数量", #guideVec)
    if #guideVec>0 then
        local function checkFunc(idx)
            if not guideVec[idx] then
                return
            end
            process = guideVec[idx]
            CocosModuleMgr.setScreenTouch(true)
            if NpcDialogueMgr.checkStory(process) then
                isGuiding = true
                GameGuideMgr.checkScene("MainScene", function()
                    NpcDialogueMgr.showStory(process)
                end)
            else
                process = nil
                isGuiding = false
                checkFunc(idx+1)
            end
        end
        checkFunc(index)
    end
end

function GameGuideMgr.sendQuestFinished()
    print("完成新手引导", process)
    if process then
        local result = QuestInfo.sendQuestFinished(process, true, nil)
    end

end

function GameGuideMgr.interruptProcess(guideID)
    if process == guideID and isGuiding then
        -- Keep the quest active and avoid starting the same guide again
        -- immediately in this session.
        isGuiding = false
        print("[GUIDE] interrupted id="..tostring(guideID))
    end
end

---完成当前新手引导
function GameGuideMgr.finishProcess()
    print("完成新手引导", process)
    isGuiding = false
    if process and debugGuideIDs[process] then
        debugGuideIDs[process] = nil
        QuestInfo.delete(process)
        process = nil
        return true
    end
    local result = QuestInfo.sendQuestFinished(process, true, function()
        --取消这句，城镇引导串联靠UI关闭回调
        --GameGuideMgr.checkProcessInTown()
    end)
    local boolLockUntilNextGuide = false
    if process then
        local childIDs = QuestInfo.getNewQuestInfoById(process).childIDs
        for key, var in pairs(childIDs) do
            print("这个引导有下级任务id:", var)
            local qInfo = QuestInfo.getNewQuestInfoById(var)
            if qInfo then
                if qInfo.strongType then
                    if tonumber(qInfo.strongType)==1 then
                        boolLockUntilNextGuide = true
                        print("有个下级任务是强制引导类型")
                        break
                    end
                end
            end
        end

        --引导完结了
        local params = {}
        params.logtype      = GameLogMgr.dataTypeEnum.EVENT_TYPE_GUIDEEND
        params.tutorialId   = tostring(process)
        local questdata = QuestInfo.getNewQuestInfoById(process)
        local questname = "unknownguidename"
        if questdata~=nil then questname =  questdata.name end
        params.tutorialName = questname
        params.beginTime    = os.time()
        params.beginLevel   = CharInfo.getLevel()
        params.endLevel     = CharInfo.getLevel()
        params.useTime      = 0
        params.stepType     = 1
        GameLogMgr.OnGameStateChange(GameLogMgr.UserGameState.STATE_GAME_GUIDE,params)
    end

    if result and boolLockUntilNextGuide then
        CocosModuleMgr.setScreenTouch(false)
    end
    if not boolLockUntilNextGuide then
    	GameGuideMgr.checkStory()
    end
    return result
end

function GameGuideMgr.checkScene(sceneName, callback)
    if SceneMgr.currentScene==sceneName and SceneMgr.isProcessing then
        if callback then
            MapSeekerMgr.setSeekFunc(function()
                callback()
            end)
        end
        return
    end
    if SceneMgr.currentScene~=sceneName then
        if callback then
            MapSeekerMgr.setSeekFunc(function()
                callback()
            end)
        end
        SceneMgr.replaceScene(SceneMgr.getRunningScene, sceneName)
    else
        if callback then
            callback()
        end
    end
end

function GameGuideMgr.checkLevelUpView(callback)
    if not callback then
        return
    end
    CocosModuleMgr.setScreenTouch(false)
    SceneMgr.getRunningScene:performWithDelay(function()
        CocosModuleMgr.setScreenTouch(true)
        if CSResourceMgr.getCsbObj("Charactor/Effects/LevelUp.csb") then
            LevelUpViewMgr.setCloseCallback(function()
                SceneMgr.replaceScene(SceneMgr.getRunningScene, "MainScene", nil, function()
                    callback()
                end)
            end)
        else
            callback()
        end
    end, 1)
end

function GameGuideMgr.addDebugGuide(id)
    QuestInfo.add({{questID=id, status=0, progressList={0}}})
    debugGuideIDs[id] = true
end

function GameGuideMgr.checkIsGuiding()
    return isGuiding
end

return GameGuideMgr