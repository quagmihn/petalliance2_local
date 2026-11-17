local AdvFailedView = {}

local resName = "Searching/Summary/PlayerFailedView.csb"
local tag     = ""

function AdvFailedView.show(scene, type)
    scene = scene or SceneMgr.getRunningScene
    type = type or 1
    
    local Layer
    local banner, kekeke_db
    
    local function loadCSB()
        GameAudio.playBattleSound("fail")
    
        Layer = CSResourceMgr.createRes(scene,resName,tag)
        CocosModuleMgr.setRelativePosition(Layer, 320, 480)
        Layer:zorder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setFullScreen(resName,tag)
        
        banner = CSResourceMgr.getNodeByName(resName,"banner",tag)
        banner:setOpacity(0)
        
        local wordTex = CocosModuleMgr.getWordImage("adventureLose.png")
        CSResourceMgr.seekNodeByName(banner,"loseString"):loadTexture(wordTex)
        
        kekeke_db = CSResourceMgr.getNodeByName(resName,"kekeke_db",tag)
        kekeke_db:setOpacity(0)
        CSResourceMgr.seekNodeByName(kekeke_db,"kekeke"):setOpacity(0)
        
        if type == 2 then
            kekeke_db:setVisible(false)
            CSResourceMgr.getNodeByName(resName,"star_bar",tag):setVisible(false)
        else
            kekeke_db:setVisible(true)
            CSResourceMgr.getNodeByName(resName,"star_bar",tag):setVisible(true)
        end
        
    end
    
    local function init()
        CSResourceMgr.seekNodeByName(banner,"ghost_back"):setLocalZOrder(-1)
        CSResourceMgr.setButtonString(resName, "retry", "advtext5", tag)  -- "再战一次"
        CSResourceMgr.setButtonString(resName, "exit",  "advtext4", tag)  -- "退出"
    end
    
    local function playAction()
        local time = 0
        
        banner:runAction(cc.JumpBy:create(0.4,cc.p(0,0),300,1))
        
        time = time + 0.2
        
        scene:performWithDelay(function() 
            local fadeIn = cc.FadeTo:create(0.2,255)
            banner:runAction(fadeIn)
        end,time)
        
        time = time + 0.2
        
        scene:performWithDelay(function()
            banner:runAction(cc.JumpBy:create(0.2,cc.p(0,0),100,1))
        end,time)
        
        time = time + 0.2

        scene:performWithDelay(function()
            banner:runAction(cc.JumpBy:create(0.2,cc.p(0,0),50,1))
            
            local fadeIn = cc.FadeTo:create(0.2,255)
            kekeke_db:runAction(fadeIn)
        end,time)

        time = time + 0.2
        
        scene:performWithDelay(function()
            banner:runAction(cc.JumpBy:create(0.2,cc.p(0,0),10,1))
            
            local texture = {
                "Searching/Summary/failed/failed_btn01.png",
                "Searching/Summary/failed/failed_btn02.png",
                "Searching/Summary/failed/failed_btn03.png",
            }
            local text = { "advtext6", "advtext7", "advtext8", }
            for i = 1, 3 do 
                local node = CSResourceMgr.seekNodeByName(kekeke_db,"kekeke")
                if i ~= 1 then
                    node = CSResourceMgr.seekNodeByName(kekeke_db,"kekeke"):clone()
                    kekeke_db:addChild(node)
                    node:setPosition(150+140*(i-1), 113)
                end
                node:setOpacity(0)
                node:setScale(0.8)
                
                local icon = CSResourceMgr.seekNodeByName(node,"icon")
                CSResourceMgr.setButtonTextureByNode(icon,texture[i],texture[i],texture[i])
                icon:setScale(1.25)
                local label = CSResourceMgr.seekNodeByName(node,"name")
                CSResourceMgr.setLabelColorByNode(label,{r=206,g=243,b=255,a=255})
                CSResourceMgr.setLabelStringByNode(label,text[i])
                CSResourceMgr.clickEventBindingByNode(icon,function()
                    transition.stopTarget(scene)
                    AdvFailedView.hide()
                    
                    if SceneMgr.currentScene == "SearchingScene" then
                        AdvCharMgr.resetTrainers()
                        SearchingMgr.closeAdventure()
                        SearchingMgr.UN_SCH_GLOBAL_CHECK()
                        SearchingMgr.reset_for_dungeonEnd()
                    end

                    MapSeekerMgr.setSeekFunc(function()
                        PetFormationMgr.show(SceneMgr.getRunningScene)
                    end)
                    SceneMgr.replaceScene(SceneMgr.getRunningScene,"MainScene")
                end)
                
                scene:performWithDelay(function()
                    local fadeIn = cc.FadeTo:create(0.2,255)
                    local scale1 = cc.ScaleTo:create(0.1, 1.1)
                    local scale2 = cc.ScaleTo:create(0.1, 1.0)
                    node:runAction(fadeIn)
                    node:runAction(cc.Sequence:create(scale1, scale2))
                end,0.1*(i-1))
            end
        end,time)

        time = time + 0.2
        
        scene:performWithDelay(function()
            
        end,time)

        time = time + 0.1
        
        print(time)
    end
    
    local function bindEvent()
        CSResourceMgr.clickEventBinding(resName,"retry",function()
            transition.stopTarget(scene)
        
            NetInterface.sendWithBlock("GC_CREATEADVENTURE_ACK", function()
                local AdventureSend = require("src/Net/Send/AdventureSend.lua")
                AdventureSend.sendCG_CreateAdventure_Req({adventureID = SearchingMapMgr.currAdventure})
            end, 
            function()
                local advID = SearchingMapMgr.currAdventure
                local starRecord = (AdventureInfo.getFinishedByID(advID) ~= nil) and AdventureInfo.getFinishedByID(advID).star or 0
                AdvStarMgr.setStars({},starRecord)
                SearchingMgr.canMove = true
                SearchingMgr.floorClear = true
                SearchingMgr.dungeonClear = true
                SearchingMapMgr.currFloor = 1
                AdvCharMgr.resetTrainers()
                AdvPetsMgr.reset()
                AdvPetsMgr.setMyPets(1)
                SceneMgr.replaceScene(scene,"SearchingScene")
            end, 
            function()
            end)
        end)
    
        CSResourceMgr.clickEventBinding(resName,"exit",function()
            AdvCharMgr.resetTrainers()
            
            SearchingMgr.closeAdventure()
            
            transition.stopTarget(scene)
            
            AdvFailedView.hide()
            
            SearchingMgr.UN_SCH_GLOBAL_CHECK()
            if SearchingMapMgr.firstAdventure then
--                SearchingMapMgr.firstAdventure = false
--                SearchingMapMgr.guideCallback()
--                SearchingMapMgr.guideCallback = nil
                SearchingMgr.reset_for_dungeonEnd()
                SceneMgr.replaceScene(scene,"MainScene")
            else
                SearchingMgr.reset_for_dungeonEnd()
                SceneMgr.replaceScene(scene,"MainScene")
            end
        end,tag)
    end
    
    local funcTable = { loadCSB, init, playAction, bindEvent, }
    
    UnblockLoader.load(funcTable, "AdvFailedView-show")

--    for i=1, #funcTable do funcTable[i]() end
end

function AdvFailedView.hide()
    local kekeke_db = CSResourceMgr.getNodeByName(resName,"kekeke_db",tag)
    
    transition.stopTarget(CSResourceMgr.getNodeByName(resName,"banner",tag))
    transition.stopTarget(CSResourceMgr.seekNodeByName(kekeke_db,"kekeke"))
    transition.stopTarget(kekeke_db)
    transition.stopTarget(SceneMgr.getRunningScene)
    
    CSResourceMgr.removeCSObjectByTag(resName,tag)
end

return AdvFailedView