require("src.GameMgr.GameInit")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    WorldMapMgr.show(self)
    WorldMapAwardsMgr.addUI(self)
    EmbeddedMapMgr.show(self)
    
    StatusBarMgr.addStatusBar(self)
    BasicMenuMgr.addBasicMenu(self)
    
    --检查boss战
    WorldMapMgr.refreshWorldBoss(self)
end

function MainScene:onEnter()
    SceneMgr.clearScene(self)
    
    local result = QuestInfo.checkAllQuestAndFinish()
    if not result then
        GameGuideMgr.checkProcess()
        if not GameGuideMgr.checkIsGuiding() then
            if LoginMsgMgr.CHECK_STATUS==0 then
                LoginMsgMgr.CHECK_STATUS = 1
            elseif LoginMsgMgr.CHECK_STATUS==1 then
--                CheckViewMgr.show(self)
                LoginMsgMgr.CHECK_STATUS = 2
            else
                LoginMsgMgr.refreshServerTime()
            end        	
        end
    end

    SevenDayRedPointManager.initRedPointDataList()

    --[[
    local param = {}
    GameLogMgr.OnGameStateChange(GameLogMgr.UserGameState.STATE_LOADINGTOGAME,param)
    ]]
    --XFangCunLogSender.logLoad()
end

function MainScene:onExit()
    --SceneMgr.onSceneExit(self)
end

return MainScene
