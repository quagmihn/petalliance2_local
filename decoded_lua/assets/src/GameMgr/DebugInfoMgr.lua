local DebugInfoMgr = {}

local diban = nil
local richLabels = {}

local num = 1

function DebugInfoMgr.show(string)
    local scene = SceneMgr.getRunningScene
    CSResourceMgr.createRes(scene, "Scene/DebugInfoLayer.csb"):setLocalZOrder(99)
    CSResourceMgr.setLabelString("Scene/DebugInfoLayer.csb", "string", string)
    CSResourceMgr.setRelativePosition("Scene/DebugInfoLayer.csb", 320, 480)
end

function DebugInfoMgr.test()
    --[[
    CocosModuleMgr.playVideo("Video/take2.mp4", function()
    	DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "视频播放完毕")
    end)]]
    
    --CocosModuleMgr.setButtonHint(CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_rw"), 3.5)
    --CocosModuleMgr.showUnlockAnimation(CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_rw"))
    CocosModuleMgr.showUnlockAnimation(CSResourceMgr.getNodeByName("Charactor/Menu/MainMenu.csb", "b1"))

    --GameGuideMgr.firstMission()
    
    --ChoosePetViewMgr.addUI(SceneMgr.getRunningScene)
    --ChoosePetViewMgr.show()
    
    --GameGuideMgr.firstMission()

    --DebugInfoMgr.testDialogBox()
    --DebugInfoMgr.testRichLabel()
    --GameGuideMgr.getPet()
    --GameGuideMgr.firstPetCatch()
    --[[
    local obj = AnimationMgr.createAni(SceneMgr.getRunningScene, "Spine/test/088.png", display.cx, display.cy)
    AnimationMgr.playAni("Spine/test/088.png", "idle", true)
    obj:setLocalZOrder(200)
    obj:setScale(0.6)
    --]]
end

function DebugInfoMgr.debugChat(str)    
    if string.sub(str, 1, 1)=="p" then
        local id = string.gsub(str, "p", "")
        print(str, string.gsub(str, "p", ""))
        local pid = tonumber(id)
        if pid then
            PokemonInfo.setFollowPokemon(pid)
        end
    end
    
    if string.sub(str, 1, 1)=="b" then
        local id = string.gsub(str, "b", "")
        print(str, string.gsub(str, "b", ""))
        local pid = tonumber(id)
        if pid then
            BattleMapMgr.setTestPetID(pid) 
        end
    end
    
    if string.sub(str, 1, 1)=="s" then
        local id = string.gsub(str, "s", "")
        print(str, string.gsub(str, "s", ""))
        local pid = tonumber(id)
        if pid then
            BattleMapMgr.setTestSkillID(pid)
        end
    end
    
    if string.sub(str, 1, 1)=="a" then
        local id = string.gsub(str, "a", "")
        print(str, string.gsub(str, "a", ""))
        local pid = tonumber(id)
        if pid then
            
        end
    end
    
    --[[
    if str=="1" then
        GameGuideMgr.getPet()
    elseif str=="2" then
        GameGuideMgr.firstBattle()
    elseif str=="3" then
        GameGuideMgr.firstAdventure()
    elseif str=="4" then
        GameGuideMgr.firstPetCatch()
    elseif str=="5" then
        GameGuideMgr.firstAdventureSkill()
    elseif str=="6" then
        GameGuideMgr.firstPetEvolution()
    elseif str=="7" then
        GameGuideMgr.firstBossBattle()
    end
    --]]
end

function DebugInfoMgr.testAvatar()
    local resName = "Scene/DebugAvatar.csb"
    local tag = "DebugInfoMgr.testAvatar()"
    CSResourceMgr.createRes(SceneMgr.getRunningScene, resName):setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
    CSResourceMgr.setFullScreen(resName)

    local editbox = {}
    local skinIDs = {{1, 999}, {1001, 1999}, {2001, 2999}, {3001, 3999}, {4001, 4999}, {5001, 5999}}
    local defaultSkin = PlayerAnimeMgr.skinInfoTransfer(CharInfo.getCurfashion())
    local index = 1
    local aniTable = {"idle", "walk", "fly", "death", "attack"}
    for var=1, #skinIDs do
        editbox[var] = CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resName, "ed"..var-1), "UI/CommonFiles/chat_text_box_su.png", 
            100, 40, 0, 0, 20, 4, "时装编号", 2, function()
                local curID = tonumber(editbox[var]:getText())
                if curID<=skinIDs[var][1] then
                    editbox[var]:setText(skinIDs[var][1])
                end
                if curID>=skinIDs[var][2] then
                    editbox[var]:setText(skinIDs[var][2])
                end
                curID = editbox[var]:getText()
                PlayerAnimeMgr.setPlayerSkin(tag, curID)
            	index = 1
                CSResourceMgr.setButtonString(resName, "name", aniTable[index])
                PlayerAnimeMgr.playAni(tag, aniTable[index], true)
            end)        
        if not defaultSkin[var] then
            defaultSkin[var] = skinIDs[var][1]
        end
        editbox[var]:setText(tonumber(defaultSkin[var]))
        CSResourceMgr.clickEventBinding(resName, "minus"..var-1, function()
            local curID = tonumber(editbox[var]:getText())
            if curID<=skinIDs[var][1] then
        		return
        	end
            editbox[var]:setText(curID-1)
            PlayerAnimeMgr.setPlayerSkin(tag, curID-1)
            index = 1
            CSResourceMgr.setButtonString(resName, "name", aniTable[index])
            PlayerAnimeMgr.playAni(tag, aniTable[index], true)
        end)
        CSResourceMgr.clickEventBinding(resName, "plus"..var-1, function()
            local curID = tonumber(editbox[var]:getText())
            if curID>=skinIDs[var][2] then
                return
            end
            editbox[var]:setText(curID+1)
            PlayerAnimeMgr.setPlayerSkin(tag, curID+1)
            index = 1
            CSResourceMgr.setButtonString(resName, "name", aniTable[index])
            PlayerAnimeMgr.playAni(tag, aniTable[index], true)
        end)
    end

    local aniDB = CSResourceMgr.getNodeByName(resName, "ani")
    PlayerAnimeMgr.createPlayer(aniDB, {skin=defaultSkin}, tag):setScale(2)
    CSResourceMgr.clickEventBinding(resName, "close", function()
        PlayerAnimeMgr.removePlayerByTag(tag, true)
        CSResourceMgr.removeCSObjectByTag(resName)
    end)
    CSResourceMgr.clickEventBinding(resName, "use", function()
        local fvec = {}
        for var=1, #skinIDs do
            local curID = tonumber(editbox[var]:getText())
            table.insert(fvec, curID)
        end
        CharInfo.set({curfashion=fvec})
        CSResourceMgr.callButtonFunc(resName, "close")
    end)
    CSResourceMgr.clickEventBinding(resName, "left", function()
        if index<=1 then
            index = #aniTable
        else
            index = index-1
        end
        PlayerAnimeMgr.playAni(tag, aniTable[index], true)
        CSResourceMgr.setButtonString(resName, "name", aniTable[index])
    end, "", 1)
    CSResourceMgr.clickEventBinding(resName, "right", function()
        if index>=#aniTable then
            index = 1
        else
            index = index+1
        end
        PlayerAnimeMgr.playAni(tag, aniTable[index], true)
        CSResourceMgr.setButtonString(resName, "name", aniTable[index])
    end, "", 1)
end

function DebugInfoMgr.testAvatarChange()
    local resTable = 
        {
            "Spine/avatar/leaf3.png",
            "Spine/avatar/head.png",
            "Spine/avatar/leaf2.png",
            "Spine/avatar/leaf1.png",
        }
    if num==1 then
        for var=1, #resTable do
            local resName = resTable[var]
            local obj = AnimationMgr.createAni(SceneMgr.getRunningScene, resName, display.cx, display.cy)
            obj:setSkin("yellow")
            obj:setLocalZOrder(200)
            obj:setScale(0.4)
        end
        num=2
    elseif num==2 then
        AnimationMgr.getGafObj(resTable[1]):setSkin("red")
        num=3
    elseif num==3 then
        AnimationMgr.getGafObj(resTable[2]):setSkin("red")
        num=4
    elseif num==4 then
        AnimationMgr.getGafObj(resTable[3]):setSkin("red")
        num=5
    elseif num==5 then
        AnimationMgr.getGafObj(resTable[4]):setSkin("red")
        num=6
    elseif num==6 then
        for var=1, #resTable do
            local resName = resTable[var]
            AnimationMgr.removeGafObjectByTag(resName)
        end
        num=1
    end
end

function DebugInfoMgr.testSpine()
    local resName = "Spine/pet/kuailong.png"
    local spineObj = AnimationMgr.createAni(SceneMgr.getRunningScene, resName, display.cx, display.cy)
    AnimationMgr.playAniWithCallback(resName, "idle", function()
        AnimationMgr.playAniWithCallback(resName, "walk", function()
            AnimationMgr.playAni(resName, "walk", true)
        end)
    end)
    spineObj:setLocalZOrder(200)
    spineObj:setColor({r=128,g=128,b=128,a=255})
    --[[
    local spineObj = sp.SkeletonAnimation:create("Spine/pet/kuailong.json", "Spine/pet/kuailong.atlas", 1)
    spineObj:setPosition(display.cx, display.cy)
    spineObj:setAnimation(0, "idle", true)
    --spineObj:setTimeScale(0.5)
    --spineObj:setOpacity(128)
    SceneMgr.getRunningScene:addChild(spineObj, 200)
    --]]
end

function DebugInfoMgr.testDialogBox()
    DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 1, 
    string.rep("一二三四五12345",100))
end

function DebugInfoMgr.testRichLabel()
    if diban then
        for key, var in pairs(richLabels) do
            var:removeFromParent(true)
            richLabels[key] = nil
        end
        diban:removeFromParent(true)
        diban = nil
        return
    end
    local w = GetRandom.random(300,600)
    local s = GetRandom.random(15,30)
    local f = "cuyuan_GBK.ttf"
    local m = 
        {
            "cocos2d: TextureCache: removing unused texture: C:/Users/Administrator/AppData/Local/QuickGame6/deb",
            "一二三四五12345一二三四五12345一二三四五12345一二三四五12345一二三四五12345一二三四五12345一二三四五12345一二三四五12345",
            "一二三四五一二三四五一二三四五一二三四五一二三四五一二三四五一二三四五一二三四五一二三四五一二三四五一二三四五",
            "1234567891234567891234567891234567891234567891234567891234567891234567891234567891234567891234567891",
            "一二三四五 一二三四五 一二三四五 一二三四五 一二三四五 一二三四五 一二三四五 一二三四五 一二三四五",
        }
    for key, var in pairs(m) do
        m[key] = CocosModuleMgr.createRichLabelString({{color="111111", text=var}})
    end

    diban = display.newScale9Sprite("point.png", display.cx, display.cy, cc.size(w,800))
    SceneMgr.getRunningScene:addChild(diban, 200)

    richLabels[1] = CocosModuleMgr.createRichLabel(diban, m[1], s, f, w, 0, 600)
    richLabels[2] = CocosModuleMgr.createRichLabel(diban, m[2], s, f, w, 0, 450)
    richLabels[3] = CocosModuleMgr.createRichLabel(diban, m[3], s, f, w, 0, 300)
    richLabels[4] = CocosModuleMgr.createRichLabel(diban, m[4], s, f, w, 0, 150)
    richLabels[5] = CocosModuleMgr.createRichLabel(diban, m[5], s, f, w, 0, 0)
end

function DebugInfoMgr.testPets()
	local resName = "Scene/DebugPetAni.csb"
    local tag = "DebugInfoMgr.testPets()"
    CSResourceMgr.createRes(SceneMgr.getRunningScene, resName):setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
	CSResourceMgr.setFullScreen(resName)
	
	local curPetID, curPetSkin = PokemonInfo.getFollowPokemonID()
	local editbox = nil
	editbox = CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resName, "edb"), "empty.png", 
	   180, 50, 100, 25, 20, 5, "宠物编号", 2, function()
            local curID = tonumber(editbox:getText())
            if curID<0 then
                editbox:setText("0")
            end
	        CSResourceMgr.callButtonFunc(resName, "enter")
	   end)
    editbox:setText(curPetID.."")
	
    local petSkin = curPetSkin or 0
    local aniDB1 = CSResourceMgr.getNodeByName(resName, "ani1")
    local aniDB2 = CSResourceMgr.getNodeByName(resName, "ani2")
    local petRes = ""
    local petResB = ""
    local index1 = 1
    local index2 = 1
    local aniTable1 = {"idle", "walk", "attack", "power", "hurt"}
    local aniTable2 = {"idle", "attack", "power", "hurt"}
    local timeScale = 1
    local timeScaleTable = {0.1, 0.5, 1, 2, 3}
	CSResourceMgr.clickEventBinding(resName, "close", function()
        AnimationMgr.removeGafObjectByTag(petRes, tag)
        AnimationMgr.removeGafObjectByTag(petResB, tag)
		CSResourceMgr.removeCSObjectByTag(resName)
	end)
    CSResourceMgr.clickEventBinding(resName, "use", function()
        PokemonInfo.setFollowPokemon(tonumber(editbox:getText()), petSkin)
        CSResourceMgr.callButtonFunc(resName, "close")
    end)
    CSResourceMgr.clickEventBinding(resName, "minus", function()
        local curID = tonumber(editbox:getText())-1
        if curID>=0 then
            editbox:setText(curID.."")
        end
        CSResourceMgr.callButtonFunc(resName, "enter")
    end)
    CSResourceMgr.clickEventBinding(resName, "plus", function()
        local curID = tonumber(editbox:getText())+1
        editbox:setText(curID.."")
        CSResourceMgr.callButtonFunc(resName, "enter")
    end)
    CSResourceMgr.clickEventBinding(resName, "enter", function()
        if editbox:getText()=="" then
        	return
        end
        aniDB1:removeAllChildren()
        aniDB2:removeAllChildren()
        index1 = 1
        index2 = 1
        petRes = PokemonInfo.getPokemonResByID(tonumber(editbox:getText()))
        petResB = PokemonInfo.getPokemonResBackByID(tonumber(editbox:getText()))
        local time1 = os.clock()
        AnimationMgr.createAni(aniDB1, petRes, 0, 0, tag)
        AnimationMgr.playAni(petRes, aniTable1[index1], true, tag)
        AnimationMgr.createAni(aniDB2, petResB, 0, 0, tag)
        local time2 = os.clock()
        AnimationMgr.playAni(petResB, aniTable2[index2], true, tag)
        local time3 = os.clock()
        print("anim load take time:"..time2-time1.."anim play take time:"..time3-time2)
        CSResourceMgr.setButtonString(resName, "name1", aniTable1[index1])
        CSResourceMgr.setButtonString(resName, "name2", aniTable2[index2])
        AnimationMgr.setSpeedRate(petRes, timeScale, tag)
        AnimationMgr.setSpeedRate(petResB, timeScale, tag)
        AnimationMgr.setSkin(petRes, petSkin, tag)
        AnimationMgr.setSkin(petResB, petSkin, tag)
    end)
    CSResourceMgr.clickEventBinding(resName, "turnleft1", function()
        if petRes=="" then
            return
        end
    	if index1<=1 then
    		index1 = #aniTable1
    	else
            index1 = index1-1
    	end
        AnimationMgr.playAni(petRes, aniTable1[index1], true, tag)
        CSResourceMgr.setButtonString(resName, "name1", aniTable1[index1])
    end, "", 1)
    CSResourceMgr.clickEventBinding(resName, "turnright1", function()
        if petRes=="" then
            return
        end
        if index1>=#aniTable1 then
            index1 = 1
        else
            index1 = index1+1
        end
        AnimationMgr.playAni(petRes, aniTable1[index1], true, tag)
        CSResourceMgr.setButtonString(resName, "name1", aniTable1[index1])
    end, "", 1)
    CSResourceMgr.clickEventBinding(resName, "turnleft2", function()
        if petResB=="" then
            return
        end
        if index2<=1 then
            index2 = #aniTable2
        else
            index2 = index2-1
        end
        AnimationMgr.playAni(petResB, aniTable2[index2], true, tag)
        CSResourceMgr.setButtonString(resName, "name2", aniTable2[index2])
    end, "", 1)
    CSResourceMgr.clickEventBinding(resName, "turnright2", function()
        if petResB=="" then
            return
        end
        if index2>=#aniTable2 then
            index2 = 1
        else
            index2 = index2+1
        end
        AnimationMgr.playAni(petResB, aniTable2[index2], true, tag)
        CSResourceMgr.setButtonString(resName, "name2", aniTable2[index2])
    end, "", 1)
    CSResourceMgr.clickEventBinding(resName, "skin+", function()
        if petSkin<10 then
            petSkin = petSkin+1
        end
        CSResourceMgr.setLabelString(resName, "skinid", petSkin)
        AnimationMgr.setSkin(petRes, petSkin, tag)
        AnimationMgr.setSkin(petResB, petSkin, tag)
    end, "", 1)
    CSResourceMgr.clickEventBinding(resName, "skin-", function()
        if petSkin>0 then
            petSkin = petSkin-1
        end
        CSResourceMgr.setLabelString(resName, "skinid", petSkin)
        AnimationMgr.setSkin(petRes, petSkin, tag)
        AnimationMgr.setSkin(petResB, petSkin, tag)
    end, "", 1)
    CSResourceMgr.setLabelString(resName, "skinid", petSkin)
    for var=1, #timeScaleTable do
        local s = timeScaleTable[var]
        CSResourceMgr.clickEventBinding(resName, s.."x", function()
            CSResourceMgr.setButtonEnabled(resName, timeScale.."x", true)
            CSResourceMgr.setButtonEnabled(resName, s.."x", false)
            timeScale = s
            if petRes~="" and petResB~="" then
            	AnimationMgr.setSpeedRate(petRes, timeScale, tag)
            	AnimationMgr.setSpeedRate(petResB, timeScale, tag)
            end
        end)
    end
    CSResourceMgr.setButtonEnabled(resName, timeScale.."x", false)
    CSResourceMgr.callButtonFunc(resName, "enter")
end

function DebugInfoMgr.testEffects()
    local resName = "Scene/DebugEffectAni.csb"
    local tag = "DebugInfoMgr.testEffects()"
    CSResourceMgr.createRes(SceneMgr.getRunningScene, resName):setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
    CSResourceMgr.setFullScreen(resName)
    
    local editbox1 = CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resName, "edb1"), "empty.png", 
        380, 50, 200, 25, 20, 100, "资源PNG名称")
    local editbox2 = CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resName, "edb2"), "empty.png", 
        380, 50, 200, 25, 20, 50, "动画名称")
    editbox2:setText("animation")
    
    local aniRes = ""
    local aniDB = CSResourceMgr.getNodeByName(resName, "ani")
    CSResourceMgr.clickEventBinding(resName, "close", function()
        AnimationMgr.removeGafObjectByTag(aniRes, tag)
        CSResourceMgr.removeCSObjectByTag(resName)
    end)
    CSResourceMgr.clickEventBinding(resName, "enter", function()
        aniDB:removeAllChildren()
        aniRes = "Spine/effects/"..editbox1:getText()
        local fileExist = cc.FileUtils:getInstance():isFileExist(aniRes)
        if not fileExist then
            TipsMgr.show(nil, "特效文件不存在")
            return
        end
        AnimationMgr.createAni(aniDB, aniRes, 0, 0, tag)
        AnimationMgr.playAni(aniRes, editbox2:getText(), true, tag)
    end)
end

function DebugInfoMgr.textItem()
    DebugInfoMgr.testItem()
end

function DebugInfoMgr.testItem()
    local resName = "Scene/DebugItem.csb"
    local ItemInfoConfig = require("src.DatReader.ItemInfoConfig")
    ItemInfoConfig.init()
    local PokemonInfoConfig = require("src.DatReader.PokemonInfoConfig")
    PokemonInfoConfig.init()
    local selectIDs = {}
    CSResourceMgr.createRes(SceneMgr.getRunningScene, resName):setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
    CSResourceMgr.setFullScreen(resName)
    local editbox = CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resName, "edb"), "empty.png", 
        280, 68, 150, 34, 24, 100, "物品名", nil, nil, false)
    CSResourceMgr.clickEventBinding(resName, "close", function()
        CSResourceMgr.removeCSObjectByTag(resName)
    end)
    CSResourceMgr.clickEventBinding(resName, "search", function()
        local name = editbox:getText()
        LoadingView.show(SceneMgr.getRunningScene)
        local list = CSResourceMgr.getNodeByName(resName, "item")
        local curItems = list:getItems()
        for key, var in pairs(curItems) do
        	if var.itemID then
                if not selectIDs[var.itemID] then
        			list:removeItem(list:getIndex(var))
        		end
        	end
        end
        local funcTable = {}
        local result = {}
        if name=="" then
            TipsMgr.show(nil, "关键字为空，自动列出强化升星大礼包")
            result = {9998, 9999, 202, 10006, 11000, 10001, 154, 155, 156, 157, 35, 36, 37, 38, 39, 40, 41, 42, 43, 9,
                107, 108, 110, 111, 112, 114, 115, 120, 124, 186}
        else
            local total = ItemInfoConfig.getEntryCount()
            local perTimes = 400
            for var=1, math.ceil(total/perTimes) do
                table.insert(funcTable, function()
                    local limit = var*perTimes
                    if limit>total then
                        limit = total
                    end
                    for n=1+(var-1)*perTimes, limit do
                        local id = ItemInfoConfig.getEntryID(n)
                        local data = ItemInfoConfig.readEntryByID(id)
                        if string.gmatch(LuaSqlite.getLanguageByKey(data.name), name)() then
                            --print(LuaSqlite.getLanguageByKey(data.name), id)
                            table.insert(result, id)
                        end
                    end
                end)
            end
            local ptotal = PokemonInfoConfig.getEntryCount()
            table.insert(funcTable, function()
                for n=1, ptotal do
                    local id = PokemonInfoConfig.getEntryID(n)
                    local data = PokemonInfoConfig.readEntryByID(id)
                    if string.gmatch(LuaSqlite.getLanguageByKey(data.name), name)() then
                        --print(LuaSqlite.getLanguageByKey(data.name), id)
                        table.insert(result, "p"..id)
                    end
                end
            end)
        end
        table.insert(funcTable, function()
        	local itemFunc = {}
            for k, v in pairs(result) do
                local parent = nil
                local fullID = v
                if not selectIDs[fullID] then
                    local isPet = string.sub(v, 1, 1)=="p"                    
                    v = string.gsub(v, "p", "")
                    table.insert(itemFunc, function()
                        local info = nil
                        if isPet then
                        	info = PokemonInfo.getPokemonInfoByID(v)
                        else
                            info = ItemInfo.getItemInfoById(v)
                        end                        
                        parent = CSResourceMgr.getNodeByName(resName, "example"):clone()
                        parent.itemID = fullID
                        list:pushBackCustomItem(parent)
                        parent:show()
                        local t1 = CSResourceMgr.seekNodeByName(parent, "t1")
                        local rare = info.itemRare or info.rarePoint
                        CSResourceMgr.setLabelColorByNode(t1, ItemInfo.COLOR[rare+1])
                        CSResourceMgr.setLabelStringByNode(t1, info.name, {r=0,g=0,b=0,a=255}, nil, 380)
                        local t2 = CSResourceMgr.seekNodeByName(parent, "t2")
                        CSResourceMgr.setLabelStringByNode(t2, info.desc, {r=0,g=0,b=0,a=255})
                        CSResourceMgr.setLabelMaxWidthByNode(t2, 380)
                        t2:setAnchorPoint(0, 1)
                        local box = CSResourceMgr.seekNodeByName(parent, "box")
                        box:addEventListener(function()
                            local isselected = box:isSelected()
                            if isselected then
                                selectIDs[fullID] = true
                            else
                                selectIDs[fullID] = nil
                            end
                        end)
                        if name=="" then
                            selectIDs[fullID] = true
                            box:setSelected(true)
                        end
                    end)
                    table.insert(itemFunc, function()
                        local icon = nil
                        if isPet then
                            icon = ItemInfo.getPetIconById(v, "debug")
                            icon:scale(1)
                        else
                            icon = ItemInfo.getItemIconById(v)
                            CSResourceMgr.clickEventBindingByNode(icon, function()
                                ItemInfoViewMgr.show({id=v}, false)
                            end, 1)
                            icon:scale(0.6)
                        end 
                        icon:addTo(parent)
                        icon:pos(60, 50)                        
                    end)
                end                
            end
            table.insert(itemFunc, function()
                LoadingView.hide()
            end)
            UnblockLoader.load(itemFunc, "DebugInfoMgr.loadItem()")
        end)
        UnblockLoader.load(funcTable, "DebugInfoMgr.textItem()")
    end)
    local numTable = {9, 99, 999, 1000000}
    local selNumIdx = 3
    for var=1, #numTable do
    	CSResourceMgr.clickEventBinding(resName, "x"..numTable[var], function()
            selNumIdx = var
            for v=1, #numTable do
                CSResourceMgr.setButtonEnabled(resName, "x"..numTable[v], true)
            end
            CSResourceMgr.setButtonEnabled(resName, "x"..numTable[var], false)
    	end)
    end
    CSResourceMgr.setButtonEnabled(resName, "x"..numTable[selNumIdx], false)
    CSResourceMgr.clickEventBinding(resName, "ok", function()
    	if CharInfo.getCharID()==0 then
    	    StandardTipsMgr.show(1, "帐号未登录")
    		return
    	end
    	local boolSel = false
        for key, var in pairs(selectIDs) do
    		boolSel = true
    	end
    	if not boolSel then
            StandardTipsMgr.show(1, "未勾选物品")
            return
    	end
        local url = "http://192.168.240.1:8080/sendPersonMail?charID="..CharInfo.getCharID().."&from=GM"
            .."&title=%E8%87%AA%E5%8A%A9%E7%89%A9%E5%93%81%E5%8F%91%E6%94%BE"
            .."&content=%E5%8F%8B%E6%83%85%E6%8F%90%E9%86%92:%E6%89%AD%E8%9B%8B%E5%89%8D%E5%85%88%E5%90%B8%E7%82%B9%E6%AC%A7%E6%B0%94."
            .."&items="--&gCash=100000&mCash=10000&items=3 179 999"
        for key, var in pairs(selectIDs) do
            local boolSp = false
            for k, v in pairs(ItemInfo.AWARD) do
            	if v==key then
                    url = url..k.."%20"..k.."%20"..numTable[4].."%20"
                    boolSp = true
                    break
            	end
            end
            if not boolSp then
                local isPet = string.sub(key, 1, 1)=="p"
                key = string.gsub(key, "p", "")
                if isPet then
                    url = url.."5%20"..key.."%20".."1".."%20"
                else
                    url = url.."3%20"..key.."%20"..numTable[selNumIdx].."%20"
                end                
            end
        end
        print(url)
        local request = network.createHTTPRequest(function(event)
            local ok = (event.name == "completed")
            local request = event.request
            if event.name then print("request event.name = " .. event.name) end
            if not ok then
                return
            end
            local code = request:getResponseStatusCode()
            if code ~= 200 then
                TipsMgr.showError(nil, code)
                return
            end
        end, url, "GET")
        request:setTimeout(10)
        request:start()
    end)
end

function DebugInfoMgr.testGuide()
    if CharInfo.getCharID()==0 then
        StandardTipsMgr.show(1, "帐号未登录")
        return
    end
    local resName = "Scene/DebugGuide.csb"
    local selectIDs = {}
    CSResourceMgr.createRes(SceneMgr.getRunningScene, resName):setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
    CSResourceMgr.setFullScreen(resName)
    CSResourceMgr.clickEventBinding(resName, "db", function()
        UnblockLoader.cancel("DebugInfoMgr.testGuide()")
        CSResourceMgr.removeList(resName, "list")
        CSResourceMgr.removeCSObjectByTag(resName)
    end)
    local guideVec = {}
    local NewQuestInfoConfig = require("src.DatReader.NewQuestInfoConfig")
    NewQuestInfoConfig.init()
    for var=1, NewQuestInfoConfig.getEntryCount() do
        local id = NewQuestInfoConfig.getEntryID(var)
        local data = NewQuestInfoConfig.readEntryByID(id)
        if data.strongType and tonumber(data.strongType)==1 then
            table.insert(guideVec, data)
        end
    end
    local funcTable = {}
    for key, var in pairs(guideVec) do
        table.insert(funcTable, function()
        	local parent = CSResourceMgr.getNodeByName(resName, "example"):clone()
            CSResourceMgr.getNodeByName(resName, "list"):pushBackCustomItem(parent)
            parent:show()
            local id = CSResourceMgr.seekNodeByName(parent, "id")
            CSResourceMgr.setLabelColorByNode(id, {r=0,g=0,b=0,a=255})
            CSResourceMgr.setLabelStringByNode(id, var.id, {r=255,g=255,b=255,a=255,w=1}, nil, 100)
            local desc = CSResourceMgr.seekNodeByName(parent, "desc")
            CSResourceMgr.setLabelColorByNode(desc, {r=0,g=0,b=0,a=255})
            CSResourceMgr.setLabelStringByNode(desc, CocosModuleMgr.createStringWithFormat({"<1>:<2>", var.name, var.desc}),
                {r=255,g=255,b=255,a=255,w=1}, nil, 270)
            CSResourceMgr.clickEventBindingByNode(parent, function()
                DialogBoxMgr.showSmallDialogBox(nil, 2, CocosModuleMgr.createStringWithFormat({"是否添加引导<1>:<2>?", var.id, var.name}), 
                    function()
                        CSResourceMgr.callButtonFunc(resName, "db")
                        GameGuideMgr.addDebugGuide(var.id)
            	    end)
            end)
        end)
    end
    UnblockLoader.load(funcTable, "DebugInfoMgr.testGuide()")
end

function DebugInfoMgr.testSkill()
    local resName = "Scene/DebugSkill.csb"
    local selectIDs = {}
    CSResourceMgr.createRes(SceneMgr.getRunningScene, resName):setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
    CSResourceMgr.setFullScreen(resName)
    CSResourceMgr.clickEventBinding(resName, "db", function()
        CSResourceMgr.removeCSObjectByTag(resName)
    end)
    for var=1, 2 do
        CSResourceMgr.setLabelColor(resName, "t"..var, {r=0,g=0,b=0,a=255})
        CSResourceMgr.setLabelString(resName, "t"..var, nil, "", {r=255,g=255,b=255,a=255,w=2}, nil, 150)
    end
    CSResourceMgr.clickEventBinding(resName, "start", function()
        local petID1 = tonumber(CSResourceMgr.getNodeByName(resName, "tf11"):getString())
        local petID2 = tonumber(CSResourceMgr.getNodeByName(resName, "tf21"):getString())
        if not petID1 or not petID1 then
        	StandardTipsMgr.show(1, "宠物id不正确")
        	return
        end
        local skID11 = tonumber(CSResourceMgr.getNodeByName(resName, "tf12"):getString()) or 0
        local skID12 = tonumber(CSResourceMgr.getNodeByName(resName, "tf13"):getString()) or 0
        local skID13 = tonumber(CSResourceMgr.getNodeByName(resName, "tf14"):getString()) or 0
        local skID14 = tonumber(CSResourceMgr.getNodeByName(resName, "tf15"):getString()) or 0
        local skID21 = tonumber(CSResourceMgr.getNodeByName(resName, "tf22"):getString()) or 0
        local skID22 = tonumber(CSResourceMgr.getNodeByName(resName, "tf23"):getString()) or 0
        local skID23 = tonumber(CSResourceMgr.getNodeByName(resName, "tf24"):getString()) or 0
        local skID24 = tonumber(CSResourceMgr.getNodeByName(resName, "tf25"):getString()) or 0
        StandardTipsMgr.SHOW_MAX_NUM = 20
        BattleMapMgr.setIsConnectNet(false)
        BattleMapMgr.setTestMyPetID(petID1)
        BattleMapMgr.setTestHisPetID(petID2)
        BattleMapMgr.setTestSkillID({skID11,skID12,skID13,skID14})
        BattleMapMgr.setHisTestSkillID({skID21,skID22,skID23,skID24})
        local paSkills = {
            {paSkillID = 0,paSkillType= 0},--天怒 1071
            {paSkillID = 0,paSkillType= 1},--下马威 1096
            {paSkillID = 0,paSkillType= 1},--刀枪不入 1076
            {paSkillID = 0,paSkillType= 1},--不屈 1081
            {paSkillID = 0,paSkillType= 1}--血性狂暴 1086
        }
        BattleMapMgr.setpaSkillID(paSkills)
        SceneMgr.replaceScene(SceneMgr.getRunningScene, "BattleScene", nil, function()
            MapSeekerMgr.setSeekFunc(function()
                StandardTipsMgr.SHOW_MAX_NUM = 3
            end)
        end)
    end)
end

function DebugInfoMgr.testMapLock()
    local resName = "Scene/DebugGuide.csb"
    local tag = "DebugInfoMgr.testMapLock()"
    CSResourceMgr.createRes(SceneMgr.getRunningScene, resName, tag):setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
    CSResourceMgr.setFullScreen(resName, tag)
    CSResourceMgr.clickEventBinding(resName, "db", function()
        UnblockLoader.cancel(tag)
        CSResourceMgr.removeList(resName, "list", tag)
        CSResourceMgr.removeCSObjectByTag(resName, tag)
    end, tag)
    local lockVec = {}
    local tmpVec = WorldMapInfo.getMapIDandMapPointByLockID()
    for key, var in pairs(tmpVec) do
        for k, v in pairs(var) do
            local mapname = WorldMapInfo.getWorldMapInfoByID(v.mapid).name
            table.insert(lockVec, {lockid=key, map=mapname, name=WorldMapInfo.getPointNameByID(v.mapid, v.pid)})
        end        
    end
    table.sort(lockVec, function(a, b)
    	return a.lockid<b.lockid
    end)
    local funcTable = {}
    local lockIdNodes = {}
    for n=1, #lockVec do
        local var = lockVec[n]
        if var.lockid>0 then
            table.insert(funcTable, function()
                local parent = CSResourceMgr.getNodeByName(resName, "example", tag):clone()
                CSResourceMgr.getNodeByName(resName, "list", tag):pushBackCustomItem(parent)
                parent:show()
                local id = CSResourceMgr.seekNodeByName(parent, "id")
                CSResourceMgr.setLabelColorByNode(id, {r=0,g=0,b=0,a=255})
                CSResourceMgr.setLabelStringByNode(id, var.lockid, {r=255,g=255,b=255,a=255,w=1}, nil, 100)
                local desc = CSResourceMgr.seekNodeByName(parent, "desc")
                CSResourceMgr.setLabelColorByNode(desc, {r=0,g=0,b=0,a=255})
                CSResourceMgr.setLabelStringByNode(desc, CocosModuleMgr.createStringWithFormat({"<1>-<2>", var.map, var.name}),
                    {r=255,g=255,b=255,a=255,w=1}, nil, 270)
                CSResourceMgr.clickEventBindingByNode(parent, function()
                    DialogBoxMgr.showSmallDialogBox(nil, 2, CocosModuleMgr.createStringWithFormat({"是否将地图进度解锁到 <1>?", var.name}), 
                        function()
                            if lockIdNodes[CharInfo.get().maplock] then
                                for k, v in pairs(lockIdNodes[CharInfo.get().maplock]) do
                                    v:setColor({r=255,g=255,b=255})
                                end
                            end
                            if lockIdNodes[var.lockid] then
                                for k, v in pairs(lockIdNodes[var.lockid]) do
                                    v:setColor({r=255,g=132,b=0})
                                end
                            end
                            NetInterface.sendWithBlock("MC_ChangeInfo_Ack", function()
                                local LoginSend = require("src.Net.Send.LoginSend")
                                LoginSend.sendCM_ChangeInfo_Req({key="maplock", content=var.lockid.."-"..CharInfo.get().missionlock})
                            end, function()
                                CharInfo.set({maplock=var.lockid.."-"..CharInfo.get().missionlock}, true)
                            end, function(code)
                                TipsMgr.showError(nil, code)
                            end)                            
                        end)
                end)
                if var.lockid==CharInfo.get().maplock then
                    parent:setColor({r=255,g=132,b=0})
                end
                if not lockIdNodes[var.lockid] then
                	lockIdNodes[var.lockid] = {}
                end
                table.insert(lockIdNodes[var.lockid], parent)
            end)
        end        
    end
    UnblockLoader.load(funcTable, tag)
end

function DebugInfoMgr.testMain()
    local resName = "Scene/DebugMain.csb"
    if CSResourceMgr.getCsbObj(resName) then
        CSResourceMgr.removeCSObjectByTag(resName)
    	return
    end
    CSResourceMgr.createRes(SceneMgr.getRunningScene, resName):setLocalZOrder(CocosModuleMgr.ZORDER_LOADING)
    CSResourceMgr.setFullScreen(resName)
    CSResourceMgr.playAllFrame(resName, false)
    CSResourceMgr.setSpeedRate(resName, 1.5)
    local titles = {"测试宠物", "测试时装", "测试特效", "物品自助", "测试引导", "测试技能"}
    for var=1, #titles do
    	CSResourceMgr.setLabelColor(resName, "t"..var, {r=255,g=222,b=0,a=255})
        CSResourceMgr.setLabelString(resName, "t"..var, titles[var], "", {r=0,g=0,b=0,a=200,w=3,s=1}, nil, 150)
        CSResourceMgr.clickEventBinding(resName, "b"..var, function()
            if var==1 then
            	DebugInfoMgr.testPets()
            elseif var==2 then
                DebugInfoMgr.testAvatar()
            elseif var==3 then
                DebugInfoMgr.testEffects()
            elseif var==4 then
                DebugInfoMgr.testItem()
            elseif var==5 then
                DebugInfoMgr.testGuide()
            elseif var==6 then
                DebugInfoMgr.testSkill()
            end
        	CSResourceMgr.removeCSObjectByTag(resName)
        end, "", 1)
    end
    CSResourceMgr.clickEventBinding(resName, "db", function()
        CSResourceMgr.removeCSObjectByTag(resName)
    end)
    CSResourceMgr.clickEventBinding(resName, "exit", function()
    	SceneMgr.replaceScene(SceneMgr.getRunningScene, "TownScene")
    end)
    CSResourceMgr.clickEventBinding(resName, "option", function()
        local list = CSResourceMgr.getNodeByName(resName, "list")
        list:setVisible(not list:isVisible())
        local tips = CSResourceMgr.getNodeByName(resName, "tips")
        tips:setVisible(not tips:isVisible())
    end)
    local list = CSResourceMgr.getNodeByName(resName, "list")
    list:hide()
    for var=1, #list:getItems() do
    	local checkBox = CSResourceMgr.getNodeByName(resName, "pn"..var)
    	if var==1 then
            checkBox:setSelected(WorldMapMoveMgr.SHOW_ROUTE)
        elseif var==2 then
            checkBox:setSelected(not UnblockLoader.USE_COROUTINE)
        elseif var==3 then
            checkBox:setSelected(not SceneMgr.SHOW_ERROR)
        elseif var==4 then
            checkBox:setSelected(TeamViewMgr.TEAM_PLAYER_NUM==1)
        elseif var==5 then
            local mnum1, mnum2 = TeamInfo.getLockInfo(1)
            checkBox:setSelected(mnum1==9999)
        elseif var==6 then
            checkBox:setSelected(CharInfo.get().maplock==9999)
            local testButton = CSResourceMgr.getNodeByName(resName, "pbtn"..var)
            if CharInfo.getCharID()==0 then
                CSResourceMgr.setButtonEnabledByNode(testButton, false)
            end
            CSResourceMgr.clickEventBindingByNode(testButton, function()
                DebugInfoMgr.testMapLock()
                CSResourceMgr.removeCSObjectByTag(resName)
            end)
        elseif var==7 then
            local curInfo = WorldBossInfo.getCurBossInfo() or {}
            checkBox:setSelected(curInfo.duration==60)
        elseif var==8 then
            checkBox:setSelected(PlayerShareMgr.DEBUG_MODE)
    	end
        checkBox:addEventListener(function()
            local isselected = checkBox:isSelected()
            if var==1 then
                WorldMapMoveMgr.SHOW_ROUTE = isselected
            elseif var==2 then
                UnblockLoader.USE_COROUTINE = not isselected
            elseif var==3 then
                SceneMgr.SHOW_ERROR = not isselected
            elseif var==4 then
                if isselected then
                	TeamViewMgr.TEAM_PLAYER_NUM = 1
                else
                    TeamViewMgr.TEAM_PLAYER_NUM = 3
                end
            elseif var==5 then
                TeamInfo.getLockInfo = function(mapid)
                    local curNum = 9999
                    local totalNum = 9999
                    return curNum, totalNum
                end
                AdvStarMgr.getWorldMapStarNum = function()
                    return 3, 3
                end
                TeamInfo.checkLock = function(mapid)
                    return true
                end
                StandardTipsMgr.SP_ZORDER = CocosModuleMgr.ZORDER_LOADING
                TipsMgr.show(nil, "此选项一旦打开，只有重启游戏才会关闭")
                StandardTipsMgr.SP_ZORDER = nil
                checkBox:setSelected(true)
            elseif var==6 then
                CharInfo.set({maplock=9999})
                StandardTipsMgr.SP_ZORDER = CocosModuleMgr.ZORDER_LOADING
                TipsMgr.show(nil, "此选项一旦打开，只有重启游戏才会关闭")
                StandardTipsMgr.SP_ZORDER = nil
                checkBox:setSelected(true)
            elseif var==7 then
                local size = 0
                local function checkNum(i)
                    if WorldBossInfo.getWorldBossInfoByID(i+1) then
                		size = size+1
                	else
                	   return
                	end
                	checkNum(i+1)
                end
                checkNum(0)
                local bossid = GetRandom.random(1, size)
                local mapvec = WorldBossInfo.getWorldBossInfoByID(bossid).mapList
                local mapid = mapvec[GetRandom.random(1, #mapvec)]
                local curTime = CharInfo.getServerTime()
                WorldBossInfo.setCurBossInfo({bossID=bossid, mapID=mapid, duration=60, createTime=curTime})
                WorldMapMgr.refreshWorldBoss()
                StandardTipsMgr.SP_ZORDER = CocosModuleMgr.ZORDER_LOADING
                TipsMgr.show(nil, "此选项一旦打开，只有重启游戏才会关闭")
                StandardTipsMgr.SP_ZORDER = nil
                checkBox:setSelected(true)
            elseif var==8 then
                PlayerShareMgr.DEBUG_MODE = isselected
            end
        end)
    end
end

return DebugInfoMgr