local TownScene = class("TownScene", function()
    return display.newScene("TownScene")
end)

local townRes = "Map/TownMap/town_01.csb"   --以后读表

function TownScene:ctor()
    TownMapMgr.setPetScale(0.5)

    if SceneMgr.mapEnterType~=3 then
        SceneMgr.mapEnterType = 99
    end
    if GameGuideMgr.originalGuideStart then
    	TownMapMgr.createWithRes(self, townRes)
    else
        TownMapMgr.createWithRes(self, townRes, function()
            SceneMgr.replaceScene(self, "MainScene")
        end, function()
            SceneMgr.replaceScene(self, "MainScene")
        end)
        NpcMgr.addNPC(998, GameGuideMgr.NPC_NAME[2], 1860, function()
            WishCoinShopView.init()
            WishCoinShopView.sendServerShopType(Proto.SHOP_WISH) 
            --去掉洛天依对话
            -- NpcDialogueMgr.show(8,function()
            --     WishCoinShopView.init()
            --     WishCoinShopView.sendServerShopType(Proto.SHOP_WISH) 
            -- end)
        end)
        --2250
--        NpcMgr.addNPC(103,nil, nil, function()
  --          local OrderManUIMgr    = require("src.GameMgr.OrderMan.OrderManUIMgr")
 --           OrderManUIMgr.new(self)    
 --       end)

--		NpcMgr.addNPC(104,nil, nil, function()
--            local ChainManUIMgr    = require("src.GameMgr.ChainMan.ChainManUIMgr")
--            ChainManUIMgr.show(self)    
--        end)
    end
    
    local cloud1 = CSResourceMgr.getNodeByName("Map/TownMap/town_01_back.csb", "cloud1")
    local sequence1 = transition.sequence({
        cc.CallFunc:create(function()
            cloud1:setPositionX(0)
        end),
        cc.MoveBy:create(150, cc.p(-3000, 0)),
    })
    local action1 = cc.RepeatForever:create(sequence1)
    cloud1:runAction(action1)
    
    local cloud2 = CSResourceMgr.getNodeByName("Map/TownMap/town_01_back.csb", "cloud2")
    local sequence2 = transition.sequence({
        cc.CallFunc:create(function()
            cloud2:setPositionX(3000)
        end),
        cc.MoveBy:create(150, cc.p(-3000, 0)),
    })
    local action2 = cc.RepeatForever:create(sequence2)
    cloud2:runAction(action2)
    
    StatusBarMgr.addStatusBar(self)
    BasicMenuMgr.addBasicMenu(self)
    
    local bname = {"town1", "town2", "town3", "town4", "town5", "town6", "town7", "town8"}
    local block = {nil, nil, 24004, 24005, 24006, 24003, 24002, nil}
    local needplayDefaultUISound = true --是否需要播放默认的打开声音
    for var=1, #bname do
        TownMapMgr.setMapButton("b"..var, function()
            if var==1 then
                CocosModuleMgr.hideShiningToNode(CSResourceMgr.getNodeByName(townRes, "b1"))
                MailMgr.show(self)
            elseif var==2 then
                SceneMgr.mapEnterType = 1
                SceneMgr.replaceScene(self, "LabScene")
            elseif var==3 then
                needplayDefaultUISound = false
                LifeSkillSelViewMgr.request(self)
            elseif var==4 then
                if CharInfo.getFamilyID() == nil then --没家族
                    FamilyListViewMgr.show(SceneMgr.getRunningScene)
                else --有家族
                    MyFamilyLstViewMgr.show(SceneMgr.getRunningScene)
                end
            elseif var==5 then
                AuctionMgrNew.request(self)
            elseif var==6 then
                --SelectBeautyViewMgr.show(self)
                SceneMgr.mapEnterType = 1
                SceneMgr.replaceScene(self, "StarScene")
            elseif var==7 then
                ArenaMainMgr.show(self)
            elseif var==8 then
                TeamViewMgr.show(self)
            end
            if needplayDefaultUISound == true then
                GameAudio.playUISound("popup")
            else
                needplayDefaultUISound = true
            end
        end)
        CSResourceMgr.setLabelString(townRes, "t"..var, bname[var], "", {r=0,g=0,b=0,a=255}, nil, 150)
        if block[var] then
            local val = SystemInfo.getGlobalConfigAddInfoByID(block[var]).values[1]
            CSResourceMgr.setLabelString(townRes, "locktext"..var, bname[var], "", {r=75,g=47,b=6,a=255}, nil, 200)
            CSResourceMgr.setLabelColor(townRes, "lockinfo"..var, {r=113,g=69,b=5,a=255})
            if val==999 then
                CSResourceMgr.setLabelString(townRes, "lockinfo"..var, "tips41", "", {r=252,g=213,b=87,a=255}, nil, 200)
            else
                CSResourceMgr.setLabelString(townRes, "lockinfo"..var, CocosModuleMgr.createStringWithFormat({"tips15", val}), "",
                    {r=252,g=213,b=87,a=255}, nil, 200)
            end
        end
    end
    TownMapMgr.refreshLevel = function()
        if not CSResourceMgr.getCsbObj(townRes) then
        	return
        end
        for var=1, #bname do
            if block[var] then
                local val = SystemInfo.getGlobalConfigAddInfoByID(block[var]).values[1]
                if CharInfo.getLevel()<val then
                    CSResourceMgr.getNodeByName(townRes, "b"..var):setColor({r=100,g=100,b=100})
                    CSResourceMgr.setButtonEnabled(townRes, "b"..var, false)
                    CSResourceMgr.getNodeByName(townRes, "t"..var):setVisible(false)
                    CSResourceMgr.getNodeByName(townRes, "lock"..var):setVisible(true)
                else
                    CSResourceMgr.getNodeByName(townRes, "b"..var):setColor({r=255,g=255,b=255})
                    CSResourceMgr.setButtonEnabled(townRes, "b"..var, true)
                    CSResourceMgr.getNodeByName(townRes, "t"..var):setVisible(true)
                    CSResourceMgr.getNodeByName(townRes, "lock"..var):setVisible(false)
                end
                if ((device.platform=="ios" or device.platform=="windows") and val == 999) or var==6 then
                    CSResourceMgr.getNodeByName(townRes, "b"..var):setVisible(false)
                    CSResourceMgr.getNodeByName(townRes, "t"..var):setVisible(false)
                    CSResourceMgr.getNodeByName(townRes, "lock"..var):setVisible(false)
                end
            end
        end
    end
    TownMapMgr.setBuildingLock = function(id)
        CSResourceMgr.getNodeByName(townRes, "b"..id):setColor({r=100,g=100,b=100})
        CSResourceMgr.setButtonEnabled(townRes, "b"..id, false)
        CSResourceMgr.getNodeByName(townRes, "t"..id):setVisible(false)
        CSResourceMgr.getNodeByName(townRes, "lock"..id):setVisible(true)
    end
    TownMapMgr.setBuildingUnlock = function(id, callback)
        CocosModuleMgr.setScreenTouch(false)
        local btn = CSResourceMgr.getNodeByName(townRes, "b"..id)
        local aniSp = AnimationMgr.createAni(btn, "Spine/effects/UI_jianzhujiesuo.png", btn:getContentSize().width/2, 
            btn:getContentSize().height/2, "TownMapMgr"..id)
        AnimationMgr.playAniWithCallback(aniSp.res, "animation", nil, aniSp.tag, true)
        transition.fadeOut(CSResourceMgr.getNodeByName(townRes, "lock"..id), {time=1})
        btn:performWithDelay(function()
            local ani = cc.TintTo:create(1, 255, 255, 255)
            btn:runAction(ani)
        end, 1)
        btn:performWithDelay(function()
            CocosModuleMgr.setScreenTouch(true)
            CSResourceMgr.getNodeByName(townRes, "t"..id):setVisible(true)
            CSResourceMgr.setButtonEnabledByNode(btn, true)
            if callback then
            	callback()
            end
        end, 2)
    end
    TownMapMgr.refreshLevel()
    
    --boss战冠军
    BossDmgAwardsMgr.addChampionAni(townRes)
    BossDmgAwardsMgr.requestChampionData()
    
    if MailMgr.getHasNewMail() then
        local mailNode = CSResourceMgr.getNodeByName(townRes, "b1")
        CocosModuleMgr.showShiningToNode(mailNode, 4)
    end

    --检查boss战
    WorldMapMgr.refreshWorldBoss(self)
    --检查生存战是否开启NPC
    SurviveBattleViewMgr.checkIsSurviveBattleActive()
    --检查活动商店是否开启NPC
    ActivityShopViewMgr.checkIsActivityShopActive()
    
    GameAudio.playMusic2("town")
end

function TownScene:onEnter()
    SceneMgr.clearScene(self)
    TownTreeMgr.initMapTree()
    GameGuideMgr.checkProcessInTown(false)
    SevenDayRedPointManager.initRedPointDataList()
end

function TownScene:onExit()
    TownMapMgr.refreshLevel = nil
    --TownMapMgr.PlayerTransferPosy = nil
    TownMapMgr.sendSelfPosition(-999, townRes)
    SceneMgr.onSceneExit(self)
    HighPerformList.resetAllSchedule()
end

return TownScene