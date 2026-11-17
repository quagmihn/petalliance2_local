local FamilyCopyMapScene = class("FamilyCopyMapScene", function()
    return display.newScene("FamilyCopyMapScene")
end)

function FamilyCopyMapScene:ctor()
    --local copyMapRes = "Map/Family/CopyMap.csb"   --以后读表
    --FamilyCopyMapMgr.createWithRes(self, copyMapRes, 20, 20)
    --StatusBarMgr.addStatusBar(self)
    CommonPetBar.show(self)
    FamilyCopyTopBarMgr.show(self)
end

function FamilyCopyMapScene:onEnter()
    SceneMgr.clearScene(self)
    FamilyInfo.GetFamilyCopyMapInfo()
end

function FamilyCopyMapScene:onExit()
    --FamilyCopyMapMgr.quitMap()
    --SceneMgr.onSceneExit(self)
end

return FamilyCopyMapScene