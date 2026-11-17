require("src.GameMgr.GameInit")
local PVPDailog         = require("src.GameMgr.Battle.UI.PVPDailog") 

local BattleScene = class("BattleScene", function()
    return display.newScene("BattleScene")
end)

function BattleScene:ctor()
--    GameAudio.playMusic("Music/bgm/bg_battle4.m4a") 
    BattleMapMgr.createBattleScene(self)
end
  
function BattleScene:onEnter()
--    GameAudio.playMusic("Music/bgm/bg_battle4.m4a")
    SystemOptionsMgr.setCurrentFps(1/60.0)
    local sceneInfo = BattleMapMgr.getBattleSceneInfo()
    local musicID = sceneInfo.musicID or 70
    if sceneInfo.GroupID then
        if SceneMgr.previousScene == "SearchingScene" then
            musicID = AdventureInfo.getMonsterGroupManInfoByID(sceneInfo.GroupID).levelClass
        elseif SceneMgr.previousScene == "LostTowerScene" then
            if sceneInfo.type == Proto.BTT_LOSTTOWER_BOSS then
                musicID = LostTowerInfo.getLostTowerBossInfoById(sceneInfo.GroupID).levelClass
            elseif sceneInfo.type == Proto.BTT_LOSTTOWER_JUMP_BOSS then
                musicID = 72
            else
                musicID = LostTowerInfo.getLostTowerMonsterManGroupInfoById(sceneInfo.GroupID).levelClass
            end
            
        end
        GameAudio.playMusicById(musicID)
    else
        -- GameAudio.playMusic2("ordinarybattle")
        GameAudio.playMusicById(musicID)
    end
    SceneMgr.clearScene(self)
end

function BattleScene:onExit()
--    PVPDailog.waitOpponentHide()  
    BattleMapMgr.cleanRecord()
    SystemOptionsMgr.restoreCurrentFps()
    --SceneMgr.onSceneExit(self)
    BattleMapMgr.setEnemyPets({})
    BattleMapMgr.setMyPets({})
    BattlePVPMgr.cleanAfterReplaceScene() 
    BattleCotroller.setNoMiss(false)
    cc.Director:getInstance():getScheduler():setTimeScale(1.0) 
end

return BattleScene