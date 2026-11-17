local TeamCopyMapScene = class("TeamCopyMapScene", function()
    return display.newScene("TeamCopyMapScene")
end)

function TeamCopyMapScene:ctor()
    --local copyMapRes = "Map/Family/CopyMap.csb"   --以后读表
    --FamilyCopyMapMgr.createWithRes(self, copyMapRes, 20, 20)
    --StatusBarMgr.addStatusBar(self)
    --CommonPetBar.show(self)
    --FamilyCopyTopBarMgr.show(self)
end

function TeamCopyMapScene:onEnter()
    SceneMgr.clearScene(self)
    local boxes = TeamCopyWinMgr.getBoxes()
    if boxes then
        TeamCopyWinMgr.show(SceneMgr.getRunningScene, boxes)
    else
        TeamCopyInfo.GetTeamCopyMapInfo()
    end
end

function TeamCopyMapScene:onExit()
    --TeamCopyMapMgr.quitMap()
    --TownChatMgr.removeUI()
end

return TeamCopyMapScene