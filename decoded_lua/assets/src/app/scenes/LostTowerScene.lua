require("src.GameMgr.GameInit")

local LostTowerScene = class("LostTowerScene", function()
    return display.newScene("LostTowerScene")
end)

function LostTowerScene:ctor()

    LtMapOption.setMapType("LOSTTOWER")
    --LtMapOption.setMapSize(6, 9)
    
    -- AdvEnvironmentMgr.initEnvironmentParams(2)
    local sceneID = LostTowerMgr.LtMapData[1]["sceneID"]
    
    local code = 2
    local mapInfo = LostTowerInfo.getLostTowerMapInfoById(sceneID)
    if mapInfo then
        code = LostTowerInfo.getLostTowerMapInfoById(sceneID)["lostTowerList"][1]["terrRes"]
    end
    
    AdvEnvironmentMgr.initEnvironmentParams(code)
    SearchingUIMgr.setEnv(code)
    
    LostTowerMgr.createMap()
    
    LostTowerUIMgr.AddUI(self)
    
    StatusBarMgr.loadTopBar(self)
    
    if SceneMgr.previousScene == "BattleScene" then
        self:performWithDelay(function()
            if SearchingMgr.checkBattleResult(self) then
--                if LostTowerMgr.previousPoint >= 0 then
--                    SearchingMgr.canMove = false
--                    LostTowerUIMgr.pointEffectToTopbar(SearchingMapMgr.battlePos,function()
--                        if not CSResourceMgr.getCsbObj(LostTowerUIMgr.topResName) then return end
--                        local label = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName,{"acc_point_box","acc_point_num"})
--                        CSResourceMgr.setLabelStringByNode(label, LostTowerMgr.previousPoint)
--                        local k = 0
--                        for i = LostTowerMgr.previousPoint, LostTowerMgr.points do
--                            k = k + 1
--                            self:performWithDelay(function()
--                                CSResourceMgr.setLabelStringByNode(label, i)
--                            end,0.1*k)
--                        end
--                        local scaleto_1_1 = cc.ScaleTo:create(0.1*k/2, 1.1)
--                        local scaleto_1_0 = cc.ScaleTo:create(0.1*k/2, 1.0)
--                        label:runAction(cc.Sequence:create(scaleto_1_1, scaleto_1_0))
--                        LostTowerMgr.previousPoint = -1
--    
--                        SearchingMgr.canMove = true
--                    end)
--                    
--                    if LostTowerMgr.battleAwards then
--                        GameAudio.playUISound("itemGet")
--                        AwardsListMgr.show(SceneMgr.getRunningScene, LostTowerMgr.battleAwards)
--                        LostTowerMgr.battleAwards = nil
--                    end
--                end-- end of if
                
                LostTowerUIMgr.rollTheLtPoints(self)
                LostTowerUIMgr.rollTheStepNumber(self)
                LostTowerUIMgr.showBattleAwards()
            end-- end of if 
        end,0.3)-- end of performWithDelay
    end
    
    -- 移动服务器通信：队列首标志位
    LostTowerMgr.firstSend = true
    
    require("src.GameMgr.LostTower.LTGuideMgr").SecondGuide(function()
    end)

    GameAudio.playMusic2("losttowermusic")
    
    self:performWithDelay(function()
        LostTowerMgr.preCheck(LostTowerMgr.preCheckData)
        LostTowerMgr.preCheckData = {}
    end, 0.3)
    
end

function LostTowerScene:onEnter()
    SceneMgr.clearScene(self)
end

function LostTowerScene:onExit()
    SceneMgr.onSceneExit(self)
end

return LostTowerScene