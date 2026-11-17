local LabScene = class("LabScene", function()
    return display.newScene("LabScene")
end)

local labRes = "Map/TownMap/lab_01.csb"   --以后读表

function LabScene:ctor()
    TownMapMgr.setPetScale(0.5)
    
    --SceneMgr.mapEnterType = 1
    TownMapMgr.createWithRes(self, labRes,  function()
        SceneMgr.mapEnterType = 99
        SceneMgr.replaceScene(self, "TownScene")
    end, nil)
    
    TownMapMgr.setMapButton("step1", function() end)
    TownMapMgr.setMapButton("step2", function() end)
    TownMapMgr.setMapButton("step3", function() end)
    
    TownMapMgr.setMapButton("trainstone", function()
        ScienceViewMgr.show(self)
    end)
    CSResourceMgr.setLabelString(labRes, "traintitle", "science1", "", {r=0,g=0,b=0,a=255}, nil, 300)
    
    local val = SystemInfo.getGlobalConfigAddInfoByID(24017).values[1]
    if CharInfo.getLevel()<val then
        CSResourceMgr.getNodeByName(labRes, "trainstone"):setColor({r=100,g=100,b=100})
        CSResourceMgr.setButtonEnabled(labRes, "trainstone", false)
        CSResourceMgr.getNodeByName(labRes, "traintitle"):setVisible(false)
        CSResourceMgr.getNodeByName(labRes, "trainlock"):setVisible(true)
    else
        CSResourceMgr.getNodeByName(labRes, "trainstone"):setColor({r=255,g=255,b=255})
        CSResourceMgr.setButtonEnabled(labRes, "trainstone", true)
        CSResourceMgr.getNodeByName(labRes, "traintitle"):setVisible(true)
        CSResourceMgr.getNodeByName(labRes, "trainlock"):setVisible(false)
    end
    CSResourceMgr.setLabelString(labRes, "trainlocktext", "science1", "", {r=75,g=47,b=6,a=255}, nil, 200)
    CSResourceMgr.setLabelColor(labRes, "trainlockinfo", {r=113,g=69,b=5,a=255})
    if val==999 then
        CSResourceMgr.setLabelString(labRes, "trainlockinfo", "tips41", "", {r=252,g=213,b=87,a=255}, nil, 200)
        --[[
        if (device.platform=="ios" or device.platform=="windows") and val == 999 then
            CSResourceMgr.getNodeByName(labRes, "trainlock"):setVisible(false)
            CSResourceMgr.getNodeByName(labRes, "trainstone"):setVisible(false)
            CSResourceMgr.getNodeByName(labRes, "traintitle"):setVisible(false)
            CSResourceMgr.getNodeByName(labRes, "trainlockinfo"):setVisible(false)
        end]]
    else
        CSResourceMgr.setLabelString(labRes, "trainlockinfo", CocosModuleMgr.createStringWithFormat({"tips15", val}), "",
            {r=252,g=213,b=87,a=255}, nil, 200)
    end    
    
    StatusBarMgr.addStatusBar(self)
    BasicMenuMgr.addBasicMenu(self)
    
    NpcMgr.addNPC(1, "npcname1", 700, function()
        PetEatPetViewMgr.show(self)
    end)
    
    --检查boss战
    WorldMapMgr.refreshWorldBoss(self)
    
    GameAudio.playMusic2("town")
    GameAudio.playUISound("mapchange1")
end

function LabScene:onEnter()
    SceneMgr.clearScene(self)
    GameLogMgr.OnGameStateChange(GameLogMgr.UserGameState.STATE_LOADINGTOGAME)
end

function LabScene:onExit()
    TownMapMgr.sendSelfPosition(-999, labRes)
    --SceneMgr.onSceneExit(self)
end

return LabScene