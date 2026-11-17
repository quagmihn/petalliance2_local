local BossMapScene = class("BossMapScene", function()
    return display.newScene("BossMapScene")
end)

function BossMapScene:ctor()
--local copyMapRes = "Map/Family/CopyMap.csb"   --以后读表
--FamilyCopyMapMgr.createWithRes(self, copyMapRes, 20, 20)
--StatusBarMgr.addStatusBar(self)
--CommonPetBar.show(self)
--FamilyCopyTopBarMgr.show(self)    
end

function BossMapScene:onEnter()
    SceneMgr.clearScene(self)
    
    local CurBossInfo = WorldBossInfo.getCurBossInfo()
    local bossID = WorldBossInfo.getWorldBossInfoByID(CurBossInfo.bossID).model
    local deltaTime = CharInfo.getServerTime() - CurBossInfo.createTime
    local remainTime = CurBossInfo.duration - (deltaTime > 0 and deltaTime or 0)
    local totalTime = CurBossInfo.duration
    BossMapMgr.addLocalBossMapInfo(CurBossInfo.mapID, bossID)
    BossBattleMgr.start(CurBossInfo.bossID)
    BossMapMgr.createRandomPlayers(5)
    BossMapMgr.addLocalMembersInfo(CharInfo.getLevel(), CharInfo.getLevel(), CurBossInfo.bossID, remainTime > 0 and remainTime or 0, totalTime)
    WorldBossInfo.GetDamageRank()
    --WorldBossInfo.GetWorldBossMapInfo()
    --BossMapMgr.addLocalBossMapInfo(195)
    --BossMapMgr.addLocalMembersInfo(100.0, 195, 120, 120)
    --BossTopBarMgr.updateRank({{name="aaa"},{name="bbb"},{name="ccc"},{name="ddd"},{name="eee"}})
    
    --StatusBarMgr.addStatusBar(self, false, false)

    BossBattleMgr.createBossEffect()
    GameAudio.playMusic2("bossbattle")
end

function BossMapScene:onExit()
    BossBattleMgr.stop()
--TeamCopyMapMgr.quitMap()
--TownChatMgr.removeUI()
end

return BossMapScene