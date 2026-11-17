local WorldMapMoveMgr = {}

WorldMapMoveMgr.SHOW_ROUTE = false

local tipRes = ""
local tipResBoss = ""
local awardsResBoss = ""
local helpResBoss = ""
local tagsAwards = ""

local flyItemID = 0
local routeLineObjs = {}
local routeLineObjs_bak = {}
local itemNodes = {}
local itemNodesBoss = {}
local showBossRecords = {}

local curP = 0
local flyItemName = ""
local allTimes = {}

function WorldMapMoveMgr.Init()
    tipRes = "Map/WorldMap/MoveTips.csb"
    tipResBoss = "Map/WorldMap/BossMoveTips.csb"
    awardsResBoss = "Charactor/QRCodeRewardList.csb"
    helpResBoss = "Map/WorldMap/BossHelp.csb"
    tagsAwards = "WorldMapMoveMgr-BossAwards"
    --CSResourceMgr.createRes(nil, tipRes, nil, true)
    flyItemID = SystemInfo.getGlobalConfigAddInfoByID(6001).values[1]
    routeLineObjs = {}
    routeLineObjs_bak = {}
    itemNodes = {}
    itemNodesBoss = {}
    showBossRecords = {}
    
    curP = 0
    flyItemName = ItemInfo.getItemInfoById(flyItemID).icon
    
    allTimes = SystemInfo.getGlobalConfigAddInfoByID(8002).values
end

function WorldMapMoveMgr.createRoute()
    routeLineObjs = {}
    routeLineObjs_bak = {}
    
    if WorldMapMoveMgr.SHOW_ROUTE then
        local resName = WorldMapInfo.getWorldMapInfoByID(WorldMapMgr.curMapID).res
        local maplayer = CSResourceMgr.getNodeByName(resName, "map")
        for key, var in pairs(WorldMapInfo.getRouteInfoByID(WorldMapMgr.curMapID)) do
            local b1 = CSResourceMgr.getNodeByName(resName, "p"..var[1])
            local b2 = CSResourceMgr.getNodeByName(resName, "p"..var[2])
            if b1 and b2 then
                local line = display.newLine(
                    {{b1:getPositionX(), b1:getPositionY()}, {b2:getPositionX(), b2:getPositionY()}}, 
                    {borderColor = cc.c4f(0.95, 0.91, 0.48, 0.8), borderWidth = 5})
                line:addTo(maplayer)
                local line_bak = display.newLine(
                    {{b1:getPositionX(), b1:getPositionY()}, {b2:getPositionX(), b2:getPositionY()}}, 
                    {borderColor = cc.c4f(0.72, 0.97, 0.27, 0.8), borderWidth = 5})
                line_bak:setVisible(false)
                line_bak:addTo(maplayer)
                routeLineObjs[var[1].."-"..var[2]] = line
                routeLineObjs_bak[var[1].."-"..var[2]] = line_bak
            end
        end
    end
end

function WorldMapMoveMgr.showMoveDlg(i)
    if WorldMapInfo.getPointInfoByID(WorldMapMgr.curMapID, i).type==WorldMapInfo.POINT_TYPE_EXPLORE then
        LostTowerMgr.sendCreateReq(function()
            SceneMgr.replaceScene(SceneMgr.getRunningScene, "LostTowerScene")
        end)
    	return
    elseif WorldMapInfo.getPointInfoByID(WorldMapMgr.curMapID, i).type==WorldMapInfo.POINT_TYPE_TEAM then
        if not TeamInfo.checkLock(WorldMapMgr.curMapID) then
            StandardTipsMgr.show(1, "worldmaplocktip"..WorldMapMgr.curMapID..i)
            return
        end
    else
        local lockID = WorldMapInfo.getLockInfoByID(WorldMapMgr.curMapID)[i]
        if lockID then
            if lockID>CharInfo.get().maplock then
                StandardTipsMgr.show(1, "worldmaplocktip"..WorldMapMgr.curMapID..i)
                return
            end
        end
    end
    
    curP = i
    if i==WorldMapMgr.curP and WorldMapMgr.isMoving==false then
        WorldMapMgr.checkEvent()
        return
    end
    if WorldMapMgr.isMoving then
        WorldMapMgr.isRouteChanged = true
        TipsMgr.show(nil, "tips28")
        return
    end

    if WorldMapMoveMgr.SHOW_ROUTE then
        local routeResult = WorldMapMgr.searchRoute(i)
        if routeResult then
            table.insert(routeResult, 1, WorldMapMgr.curP)

            for var=1, #routeResult-1 do
                if routeLineObjs_bak[routeResult[var].."-"..routeResult[var+1]] then
                    routeLineObjs_bak[routeResult[var].."-"..routeResult[var+1]]:setVisible(true)
                end
                if routeLineObjs_bak[routeResult[var+1].."-"..routeResult[var]] then
                    routeLineObjs_bak[routeResult[var+1].."-"..routeResult[var]]:setVisible(true)
                end
            end
        end        
    end

    if CSResourceMgr.getCsbObj(tipRes) then
    	return
    end
    
    UIStack.push("WorldMapMoveMgr", WorldMapMoveMgr.hideMoveDlg, false)
    
    CSResourceMgr.createRes(SceneMgr.getRunningScene, tipRes):setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
    CSResourceMgr.setRelativePosition(tipRes, 320, 400)
    CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(tipRes, "maindb"), "up")

    local title = CSResourceMgr.getNodeByName(tipRes, "title")
    title:enableOutline({r=0,g=0,b=0,a=255}, 1)
    CSResourceMgr.setLabelColor(tipRes, "title", {r=254,g=254,b=48,a=255})
    local fullName = WorldMapInfo.getPointNameByID(WorldMapMgr.curMapID, i)
    local aName = lua_string_split(LuaSqlite.getLanguageByKey(fullName), "\n")[2] or fullName
    CSResourceMgr.setLabelString(tipRes, "title", aName, "", nil, nil, 300)
    --[[
    local desc = CSResourceMgr.getNodeByName(tipRes, "desc")
    desc:enableOutline({r=202,g=202,b=202,a=255}, 1)
    CSResourceMgr.setLabelColor(tipRes, "desc", {r=78,g=61,b=37,a=255})
    CSResourceMgr.setLabelString(tipRes, "desc", CocosModuleMgr.createStringWithFormat({"tips1", 
        WorldMapInfo.getPointNameByID(WorldMapMgr.curMapID, i)}))
    if not isInited then
        CSResourceMgr.setLabelMaxWidth(tipRes, "desc", 220)
    end
    ]]
    
    local head = CSResourceMgr.getNodeByName(tipRes, "head")
    local nobody = CSResourceMgr.getNodeByName(tipRes, "nobody")
    local nameinfo = CSResourceMgr.getNodeByName(tipRes, "nameinfo")
    local moveicon = CSResourceMgr.getNodeByName(tipRes, "moveicon")
    if WorldMapInfo.getPointInfoByID(WorldMapMgr.curMapID, i).type==WorldMapInfo.POINT_TYPE_STAGE then
        local avID = WorldMapInfo.getPointInfoByID(WorldMapMgr.curMapID, i).param
        TerritorialInfo.getStageBossInfo(avID, function(info)
            if WorldMapInfo.getPointInfoByID(WorldMapMgr.curMapID, curP).param~=info._id then
            	return
            end
            if not CSResourceMgr.getCsbObj(tipRes) then
            	return
            end
            local head = CSResourceMgr.getNodeByName(tipRes, "head")
            local nobody = CSResourceMgr.getNodeByName(tipRes, "nobody")
            local nameinfo = CSResourceMgr.getNodeByName(tipRes, "nameinfo")
            local moveicon = CSResourceMgr.getNodeByName(tipRes, "moveicon")
            moveicon:setVisible(true)
            if info.charID then
                nobody:setVisible(false)
                CSResourceMgr.setSpriteTextureByNode(head, CharInfo.getHeadIcon(info.fashion.curFashion))
                head:scale(1)
                head:setVisible(true)
                nameinfo:setVisible(true)
                local playername = CSResourceMgr.getNodeByName(tipRes, "playername")
                CSResourceMgr.setLabelString(tipRes, "playername", info.nickname or "", "", nil, nil, 120)
                playername:enableOutline({r=0,g=0,b=0,a=255}, 1)
                CSResourceMgr.setLabelString(tipRes, "bosstitle", "")
        	else
                local bosstitle = CSResourceMgr.getNodeByName(tipRes, "bosstitle")
                CSResourceMgr.setLabelColor(tipRes, "bosstitle", {r=254,g=254,b=48,a=255})
                CSResourceMgr.setLabelString(tipRes, "bosstitle", "stageboss12", "", nil, nil, 80)
                bosstitle:enableOutline({r=0,g=0,b=0,a=255}, 1)
                head:setVisible(false)
                nobody:setVisible(true)
                nameinfo:setVisible(false)
        	end
        end)
        CSResourceMgr.getNodeByName(tipRes, "btnbg"):setPositionY(0)
        CSResourceMgr.getNodeByName(tipRes, "iteminfo"):setVisible(true)
        local titleStr = {"Territorialbtn2", "Territorialbtn3", "Territorialbtn4"}
        local colorVec = {{r=199,g=245,b=255,a=255}, {r=199,g=245,b=255,a=255}, {r=255,g=231,b=149,a=255}}
        local lengthVec = {120, 120, 320}
        for var=1, #titleStr do
            CSResourceMgr.getNodeByName(tipRes, "stage"..var):setVisible(false)
        end
        local avInfo = AdventureInfo.getAdventureInfoByID(avID)
        if not avInfo then
        	avInfo = {}
        	avInfo.diffcultType = 0
        end
        local funcTable = {function() end}
        itemNodes = {}
        for var=1, avInfo.diffcultType do
            CSResourceMgr.setLabelColor(tipRes, "stagetitle"..var, colorVec[var])
            CSResourceMgr.setLabelString(tipRes, "stagetitle"..var, titleStr[var], "", {r=2,g=16,b=38,a=255}, nil, lengthVec[var])
            local curAvID = avID+(var-1)*10000
            avInfo = AdventureInfo.getAdventureInfoByID(curAvID)
            local awardsInfo = lua_string_split(avInfo.rewards_Icon, ",")
            local function initItem(itemID, tag)
                if not tonumber(itemID) then
                	return
                end
                local diban = CSResourceMgr.getNodeByName(tipRes, "itemdb"..tag)
                local parent = ItemInfo.getItemIconById(itemID, nil, nil, LuaSqlite.LANG_TYPE~=3)
                parent:addTo(diban)
                parent:setScale(0)
                parent:pos(0, 12)
                --阿杜修改英文版显示
                if LuaSqlite.LANG_TYPE~= 1 then
                    parent:setPositionY(0)
                end
                CSResourceMgr.buttonEventBindingByNode(parent, function()
                    ItemInfoViewMgr.show({id = itemID, type = 2}, false)
                end, function()
                    ItemInfoViewMgr.hide()
                end, nil, function()
                    ItemInfoViewMgr.hide()
                end, 1)
                transition.scaleTo(parent, {scale = 0.65, time = 0.2})
                table.insert(itemNodes, parent)
            end
            if var==3 then
                for n=1, 3 do
                    if awardsInfo[n] then
                        table.insert(funcTable, function()
                            initItem(awardsInfo[n], var..n)
                        end)
                	end
                end
            else
                table.insert(funcTable, function()
                    initItem(awardsInfo[1], var)
                end)
            end
            local info = AdventureInfo.getFinishedByID(curAvID)
            local qctimes = info.qctimes
            local tNum = 0
            if qctimes == 0 then 
                tNum = allTimes[var]
            else
                local diff = CocosModuleMgr.getDayTimeDiff(info.qcupdatetime, CharInfo.getServerTime())
                diff = diff or 1
                if diff <=0 then 
                    tNum = allTimes[var]-qctimes
                else
                    tNum = allTimes[var]
                end
            end
            if var==3 then
                if tNum==0 then
                    CSResourceMgr.setLabelString(tipRes, "stagedesc"..var, "")
                    local richLabel = CocosModuleMgr.createRichLabel(CSResourceMgr.getNodeByName(tipRes, "stagedesc"..var), 
                        CocosModuleMgr.createRichLabelString({{color="CBDCE7", text=CocosModuleMgr.createStringWithFormat({"<1>", 
                        "tips29"})}, {color="FF0000", text=tNum..""}, {color="CBDCE7", text="/"..allTimes[var]}}), 18, 
                        "cuyuan_GBK.ttf", 640, 0, 0)
                    richLabel:setPosition(-richLabel.realWidth/2, richLabel.realHeight/2)
                else
                    CSResourceMgr.setLabelColor(tipRes, "stagedesc"..var, {r=203,g=220,b=231,a=255})
                    CSResourceMgr.setLabelString(tipRes, "stagedesc"..var, CocosModuleMgr.createStringWithFormat({"<1><2>/<3>",
                        "tips29", tNum, allTimes[var]}), "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
                    CSResourceMgr.getNodeByName(tipRes, "stagedesc"..var):removeAllChildren()
                end
            else
                CSResourceMgr.getNodeByName(tipRes, "stagedesc"..var):hide()
            end            
            CSResourceMgr.getNodeByName(tipRes, "stage"..var):show()
        end
        UnblockLoader.load(funcTable, "WorldMapMoveMgr.showMoveDlg")
    else
        nameinfo:setVisible(false)
        nobody:setVisible(false)
        head:setVisible(false)
        moveicon:setVisible(false)
        CSResourceMgr.setLabelString(tipRes, "bosstitle", "")
        CSResourceMgr.getNodeByName(tipRes, "btnbg"):setPositionY(200)
        CSResourceMgr.getNodeByName(tipRes, "iteminfo"):setVisible(false)
    end
    
    CSResourceMgr.clickEventBinding(tipRes, "go", function()
        WorldMapMgr.sendSelfPosition(WorldMapMgr.curP, i)
        WorldMapMoveMgr.hideMoveDlg()
        WorldMapMgr.moveTo(i)
    end, "", 3, "select1")
    CSResourceMgr.clickEventBinding(tipRes, "close", function()
        WorldMapMoveMgr.hideMoveDlg()
    end, "", nil, "back")
    CSResourceMgr.clickEventBinding(tipRes, "fly", function()
        NetInterface.sendWithBlock("GC_UseItem_Ack", function()
            local ItemSend = require("src.Net.Send.ItemSend")
            ItemSend.sendCG_UseItem_Req({itemID=flyItemID, targetNum=0, targetStr="", useNum=1})
        end, function()
            WorldMapMgr.sendSelfPosition(WorldMapMgr.curP, i)
            WorldMapMoveMgr.hideMoveDlg()
            WorldMapMgr.flyToPoint(i)
        end, function(code)
            TipsMgr.showError(nil, code)
        end)
        
    end, "", 3)
    if ItemInfo.getCharItemNum(flyItemID)>0 then
        CSResourceMgr.setButtonEnabled(tipRes, "fly", true)
        CSResourceMgr.setLabelString(tipRes, "flynum", CocosModuleMgr.createStringWithFormat({"x<1>",  
            ItemInfo.getCharItemNum(flyItemID)}), "", {r=47,g=22,b=0,a=255}, nil, 100)
        CSResourceMgr.setSpriteTexture(tipRes, "flyicon", flyItemName)
    else
        CSResourceMgr.setButtonEnabled(tipRes, "fly", false)
    end
    GameAudio.playUISound("ok")
end

function WorldMapMoveMgr.hideMoveDlg()
    UnblockLoader.cancel("WorldMapMoveMgr.showMoveDlg")
    for key, var in pairs(itemNodes) do
        var:removeFromParent(true)
    end
    itemNodes = {}
    CSResourceMgr.removeCSObjectByTag(tipRes)
    if WorldMapMoveMgr.SHOW_ROUTE then
        for key, var in pairs(routeLineObjs_bak) do
            if var then
                var:setVisible(false)
            end
        end
    end
    UIStack.pop("WorldMapMoveMgr")
end

function WorldMapMoveMgr.showBossMoveDlg(i, bossID)
    if CharInfo.getLevel()<WorldBossInfo.getEnterLevel() then
        StandardTipsMgr.show(1, "worldboss18")
    	return
    end
    curP = i
    if i==WorldMapMgr.curP and WorldMapMgr.isMoving==false then
        WorldMapMgr.checkEvent()
        return
    end
    if WorldMapMgr.isMoving then
        WorldMapMgr.isRouteChanged = true
        TipsMgr.show(nil, "tips28")
        return
    end
    if CSResourceMgr.getCsbObj(tipResBoss) then
        return
    end
    
    UIStack.push("WorldMapMoveMgrBoss", WorldMapMoveMgr.hideBossMoveDlg, false)
    
    CSResourceMgr.createRes(SceneMgr.getRunningScene, tipResBoss):setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
    CSResourceMgr.setRelativePosition(tipResBoss, 320, 480)
    CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(tipResBoss, "db"), "up")
    
    local bossInfo = WorldBossInfo.getWorldBossInfoByID(bossID)
    CSResourceMgr.setLabelString(tipResBoss, "atitle", "worldmapbosstip4", nil, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 400)
    CSResourceMgr.setSpriteTexture(tipResBoss, "icon", WorldBossInfo.getBossIconRes(bossID))    
    CSResourceMgr.setLabelString(tipResBoss, "title", WorldMapInfo.getBossMapPointName(WorldMapMgr.curMapID), nil, 
        {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 220)
    if bossInfo then
        CSResourceMgr.setLabelString(tipResBoss, "bossname", bossInfo.bossName, nil, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 220)
    end

    CSResourceMgr.clickEventBinding(tipResBoss, "awards", function()
        WorldMapMoveMgr.showAwardsList(SceneMgr.getRunningScene, bossID)
    end, nil, 1)
    CSResourceMgr.clickEventBinding(tipResBoss, "help", function()
        WorldMapMoveMgr.showBossHelp()
    end, nil, 1)
    CSResourceMgr.clickEventBinding(tipResBoss, "go", function()
        WorldMapMgr.sendSelfPosition(WorldMapMgr.curP, i)
        WorldMapMoveMgr.hideBossMoveDlg()
        WorldMapMgr.moveTo(i)
    end, "", 3, "select1")
    CSResourceMgr.clickEventBinding(tipResBoss, "close", function()
        WorldMapMoveMgr.hideBossMoveDlg()
    end, "", nil, "back")
    CSResourceMgr.clickEventBinding(tipResBoss, "fly", function()
        NetInterface.sendWithBlock("GC_UseItem_Ack", function()
            local ItemSend = require("src.Net.Send.ItemSend")
            ItemSend.sendCG_UseItem_Req({itemID=flyItemID, targetNum=0, targetStr="", useNum=1})
        end, function()
            WorldMapMgr.sendSelfPosition(WorldMapMgr.curP, i)
            WorldMapMoveMgr.hideBossMoveDlg()
            WorldMapMgr.flyToPoint(i)
        end, function(code)
            TipsMgr.showError(nil, code)
        end)
    end, "", 3)
    if ItemInfo.getCharItemNum(flyItemID)>0 then
        CSResourceMgr.setButtonEnabled(tipResBoss, "fly", true)
        CSResourceMgr.setLabelString(tipResBoss, "flynum", CocosModuleMgr.createStringWithFormat({"x<1>",  
            ItemInfo.getCharItemNum(flyItemID)}), "", {r=47,g=22,b=0,a=255}, nil, 100)
        CSResourceMgr.setSpriteTexture(tipResBoss, "flyicon", flyItemName)
    else
        CSResourceMgr.setButtonEnabled(tipResBoss, "fly", false)
    end
    GameAudio.playUISound("ok")
    
    local funcTable = {function() end}
    if bossInfo then
        local awardID = bossInfo.awardID
        local awardInfo = WorldBossInfo.getBossKillAwardInfoByID(awardID)
        if awardInfo then
            local awardsVec = awardInfo.awardList[1].awardItems
            local wDiff = 50            
            local loopNum = #awardsVec
            if loopNum>5 then
            	loopNum = 5
            end
            local pDiff = (640-wDiff*2)/loopNum
            for var=1, loopNum do
                table.insert(funcTable, function()
                    local itemID = awardsVec[var].itemID
                    local node = ItemInfo.getItemIconById(itemID, nil, nil, LuaSqlite.LANG_TYPE==1)
                    node:addTo(CSResourceMgr.getNodeByName(tipResBoss, "db"))
                    node:pos(wDiff+pDiff/2+(var-1)*pDiff-2, 113)
                    node:scale(0)
                    if LuaSqlite.LANG_TYPE~= 1 then
                        node:setPositionY(104)
                    end
                    CSResourceMgr.buttonEventBindingByNode(node, function()
                        ItemInfoViewMgr.show({id = itemID, type = 2}, false)
                    end, function()
                        ItemInfoViewMgr.hide()
                    end, nil, function()
                        ItemInfoViewMgr.hide()
                    end, 1)
                    transition.scaleTo(node, {scale = 0.7, time = 0.2})
                    table.insert(itemNodesBoss, node)
                end)
            end
        end
    end
    table.insert(funcTable, WorldMapMoveMgr.refreshServerTime)
    table.insert(funcTable, function()
    	local setting = UserSettings.get("WorldBossHelp", 15)
        if setting==nil then
            UserSettings.set({WorldBossHelp=1}, 15)
    		WorldMapMoveMgr.showBossHelp()
    	end
    end)
    UnblockLoader.load(funcTable, "WorldMapMoveMgr.showBossMoveDlg")
end

function WorldMapMoveMgr.hideBossMoveDlg()
    if not CSResourceMgr.getCsbObj(tipResBoss) then
    	return
    end
    UnblockLoader.cancel("WorldMapMoveMgr.showBossMoveDlg")
    for key, var in pairs(itemNodesBoss) do
        var:removeFromParent(true)
    end
    itemNodesBoss = {}
    CSResourceMgr.removeCSObjectByTag(tipResBoss)
    UIStack.pop("WorldMapMoveMgrBoss")
end

function WorldMapMoveMgr.refreshServerTime()
    if not CSResourceMgr.getCsbObj(tipResBoss) then
        return
    end
    local curBossInfo = WorldBossInfo.getCurBossInfo()
    if not curBossInfo then
        return
    end
    local progressBar = CSResourceMgr.getNodeByName(tipResBoss, "timeline")
    transition.stopTarget(progressBar)
    if CharInfo.getServerTime()<curBossInfo.createTime+curBossInfo.duration then
        local remainTime = curBossInfo.createTime+curBossInfo.duration-CharInfo.getServerTime()
        local function refresh()
            if remainTime<=0 then
                WorldMapMoveMgr.hideBossMoveDlg()
                WorldMapMgr.refreshWorldBoss()
            	return
            end
            local percent = math.ceil(remainTime/curBossInfo.duration*100)
            progressBar:setPercent(percent)
        	progressBar:performWithDelay(function()
                remainTime = remainTime - 1
                refresh()
            end, 1)
        end
        refresh()
    else        
        progressBar:setPercent(0)
        WorldMapMoveMgr.hideBossMoveDlg()
        WorldMapMgr.refreshWorldBoss()
    end    
end

function WorldMapMoveMgr.showBoss(scene)
    local curBossInfo = WorldBossInfo.getCurBossInfo()
    if not curBossInfo then
    	return
    end
    local bossID = curBossInfo.bossID
    if CharInfo.getServerTime()>=curBossInfo.createTime+curBossInfo.duration then
    	return
    end
    if curBossInfo.mapID~=WorldMapMgr.curMapID then
    	return
    end
    if showBossRecords[curBossInfo.createTime] then
    	return
    end
    showBossRecords[curBossInfo.createTime] = true    
    scene = scene or SceneMgr.getRunningScene
    local resName = "Map/WorldMap/BossWarning.csb"
    CSResourceMgr.createRes(scene, resName):zorder(CocosModuleMgr.ZORDER_FLOAT)
    CSResourceMgr.setRelativePosition(resName, 320, 480)
    CSResourceMgr.setLabelString(resName, "boss_txt", "team42", nil, {r=0,g=0,b=0,a=255,w=1}, nil, 400)
    if CSResourceMgr.getCsbObj(resName) then
        GameAudio.pauseMusic()
        GameAudio.playUISound("bossAlert")
        local node = CSResourceMgr.getNodeByName(resName, "boss")
        node:setVisible(true)
        node:setOpacity(0)
        transition.fadeIn(node, {time=0.4})
        node:performWithDelay(function()
            transition.fadeOut(node, {time=0.4})
            node:performWithDelay(function()
                transition.fadeIn(node, {time=0.4})
                node:performWithDelay(function()
                    transition.fadeOut(node, {time=0.4})
                    node:performWithDelay(function()
                        transition.fadeIn(node, {time=0.4})
                        node:performWithDelay(function()
                            transition.fadeOut(node, {time=0.4})
                            node:performWithDelay(function()
                                CSResourceMgr.removeCSObjectByTag(resName)
                                local cutInName = WorldBossInfo.getWorldBossInfoByID(bossID).cutIn
                                local aniRes = CocosModuleMgr.getWordImage("worldboss/"..cutInName..".gaf")
                                local aniNode = AnimationMgr.createAni(scene, aniRes, 0, 1136)
                                aniNode:zorder(CocosModuleMgr.ZORDER_FLOAT)
                                aniNode:setAnchorPoint(0, 0)
                                GameAudio.playUISound("bosschuxian")
                                AnimationMgr.playAniWithCallback(aniRes, "idle", function()
                                    AnimationMgr.removeGafObjectByTag(aniRes)
                                    GameAudio.resumeMusic()
                                end)                                
                            end,0.4)
                        end,0.4)
                    end,0.4)
                end,0.4)
            end,0.4)
        end,0.4)
    end
end

function WorldMapMoveMgr.showAwardsList(scene, bossID)
    local bossInfo = WorldBossInfo.getWorldBossInfoByID(bossID)
    if not bossInfo then
    	return
    end
    UIStack.push(tagsAwards, WorldMapMoveMgr.hideAwardsList, false)
    scene = scene or SceneMgr.getRunningScene
    
    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, awardsResBoss, tagsAwards)
        layer:zorder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(awardsResBoss, tagsAwards)

        local title = CSResourceMgr.getNodeByName(awardsResBoss, "title", tagsAwards)
        CSResourceMgr.setLabelStringByNode(title, "arena52", {r=0,g=0,b=0,a=255,w=1,s=2}, nil, 250)
        CSResourceMgr.setLabelColorByNode(title, {r=255,g=234,b=0,a=255})
        local btn_close = CSResourceMgr.getNodeByName(awardsResBoss, "btn_close", tagsAwards)
        CSResourceMgr.clickEventBindingByNode(btn_close, function()
            WorldMapMoveMgr.hideAwardsList()
        end)
        local btn = CSResourceMgr.getNodeByName(awardsResBoss, "btn", tagsAwards)
        CSResourceMgr.clickEventBindingByNode(btn, function()
            WorldMapMoveMgr.hideAwardsList()
        end)

        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(awardsResBoss, "panel_1", tagsAwards), "up")
    end

    local funcTable = {loadCSB}
    
    local awardID = bossInfo.awardID
    local awardInfo = WorldBossInfo.getBossKillAwardInfoByID(awardID)
    local content = {}
    if awardInfo then
        local rankNum = #awardInfo.awardList
        for var=1, rankNum do
            local awardsVec = awardInfo.awardList[var].awardItems
            local rankStr = ""
            local rankID = awardInfo.awardList[var].rank
            if var==rankNum then
                rankStr = rankID.."+"
            else
                local rankTo = awardInfo.awardList[var+1].rank-1
                if rankTo==rankID then
                    rankStr = rankID..""
                else
                    rankStr = rankID.."~"..rankTo
                end
            end
            local loopNum = #awardsVec
            if loopNum>5 then
                loopNum = 5
            end
            local itemVec = {}
            for v=1, loopNum do
                local itemID = awardsVec[v].itemID
                local num = awardsVec[v].count
                table.insert(itemVec, {itemID, num})
            end
            table.insert(content, {title=CocosModuleMgr.createStringWithFormat({"worldboss19", rankStr}), item=itemVec})
        end
    end
    
    for var=1, #content do
        local info = content[var]
        table.insert(funcTable, function()
            local list = CSResourceMgr.getNodeByName(awardsResBoss, "list", tagsAwards)
            local reward = CSResourceMgr.getNodeByName(awardsResBoss, "reward", tagsAwards)
            local parent = reward:clone()
            list:pushBackCustomItem(parent)
            local bg1 = CSResourceMgr.seekNodeByName(parent, "bg1")
            bg1:setColor({r=24,g=44,b=58,a=255})
            local bg2 = CSResourceMgr.seekNodeByName(parent, "bg2")
            local reward_title = CSResourceMgr.seekNodeByName(parent, "reward_title")
            CSResourceMgr.setLabelStringByNode(reward_title, info.title, nil, nil, 500)
            CSResourceMgr.setLabelColorByNode(reward_title, {r=255,g=234,b=0,a=255,w=1,w=2})
            if info.text then
                local newLabel = reward_title:clone()
                newLabel:addTo(parent)
                newLabel:pos(60, 58)
                CSResourceMgr.setLabelStringByNode(newLabel, info.text)
                CSResourceMgr.setLabelMaxWidthByNode(newLabel, 400)
                newLabel:setAnchorPoint(0, 0.5)
            elseif info.item then
                for var=1, #info.item do
                    local iInfo = info.item[var]
                    local node = ItemInfo.getItemIconById(iInfo[1], iInfo[2])
                    node:addTo(parent)
                    node:pos(100+(var-1)*90, 58)
                    node:scale(0.6)
                    CSResourceMgr.clickEventBindingByNode(node, function()
                        ItemInfoViewMgr.show({id=iInfo[1], sum=iInfo[2]}, false)
                    end, 3)
                end
            end
            parent:setScaleY(0)
            parent:show()
            transition.scaleTo(parent, {scale=1, time=0.1})
        end)
    end

    UnblockLoader.load(funcTable, tagsAwards)
end

function WorldMapMoveMgr.hideAwardsList()
    UnblockLoader.cancel(tagsAwards)
    CSResourceMgr.removeList(awardsResBoss, "list", tagsAwards)
    CSResourceMgr.removeCSObjectByTag(awardsResBoss, tagsAwards)
    UIStack.pop(tagsAwards)
end

function WorldMapMoveMgr.showBossHelp()
    UIStack.push("WorldMapMoveMgr.showBossHelp", WorldMapMoveMgr.hideBossHelp, false)
    local scene = SceneMgr.getRunningScene
    local layer = CSResourceMgr.createRes(scene, helpResBoss)
    layer:zorder(CocosModuleMgr.ZORDER_WINDOW)
    CSResourceMgr.setFullScreen(helpResBoss)
    CSResourceMgr.clickEventBinding(helpResBoss, "bg", function()
    	WorldMapMoveMgr.hideBossHelp()
    end)
    CSResourceMgr.setSpriteTexture(helpResBoss, "im1", CocosModuleMgr.getWordImage("boss_help_figure_01.png"), nil, false)
    CSResourceMgr.setSpriteTexture(helpResBoss, "im2", CocosModuleMgr.getWordImage("boss_help_figure_02.png"), nil, false)
    CSResourceMgr.setSpriteTexture(helpResBoss, "im3", CocosModuleMgr.getWordImage("boss_help_figure_03.png"), nil, false)
    layer:setOpacity(0)
    transition.fadeIn(layer, {time=1})
end

function WorldMapMoveMgr.hideBossHelp()
    CSResourceMgr.removeCSObjectByTag(helpResBoss)
    UIStack.pop("WorldMapMoveMgr.showBossHelp")
end

return WorldMapMoveMgr