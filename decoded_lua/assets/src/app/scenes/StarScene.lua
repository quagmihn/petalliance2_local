local StarScene = class("StarScene", function()
    return display.newScene("StarScene")
end)

local labRes = "Map/TownMap/star_01.csb"   --以后读表

function StarScene:ctor()
    TownMapMgr.setPetScale(0.5)

    TownMapMgr.createWithRes(self, labRes,  function()
        SceneMgr.mapEnterType = 99
        SceneMgr.replaceScene(self, "TownScene")
    end, nil)
    
    StatusBarMgr.addStatusBar(self)
    BasicMenuMgr.addBasicMenu(self)
    
    --[[
    local skinIndex = GetRandom.random(1, 50)
    local npcAniVec = NpcMgr.addNPC(999, "点姐看B", 513.5, function()
        if GetRandom.random(1, 2)==1 then
            BossDmgAwardsMgr.requestMyData(true, function()
                BossDmgAwardsMgr.show(self)
            end)
        else
            BossDmgAwardsMgr.showInputBox()
        end
    end, nil, nil, nil, {GetRandom.random(1, 10), 1000+skinIndex, 2000+skinIndex, 3000+skinIndex})
    --npcAniVec.node:setPositionY(200)
    local vec = PlayerAnimeMgr.playerTable[npcAniVec.ani.tag].spineobj
    for key, var in pairs(vec) do
        CocosModuleMgr.darkNode(var, true)
    end
    npcAniVec.node:performWithDelay(function()
        for key, var in pairs(vec) do
            AnimationMgr.pauseAni(var.res, var.tag)
        end
    end, 0.1)]]
    --BossDmgAwardsMgr.addChampionAni()
    
    --检查boss战
    WorldMapMgr.refreshWorldBoss(self)
    
    --检查boss战冠军
    BossDmgAwardsMgr.requestChampionData()
    
    GameAudio.playMusic2("town")
    GameAudio.playUISound("mapchange1")
end

function StarScene:onEnter()
    SceneMgr.clearScene(self)
end

function StarScene:onExit()
    TownMapMgr.sendSelfPosition(-999, labRes)
    --SceneMgr.onSceneExit(self)
end

return StarScene