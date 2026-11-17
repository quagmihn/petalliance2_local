local LevelUpViewMgr = {}

local resName = ""
local resNameDB = ""
local particleRes = ""
local spineRes = {}
local shineAni = {}
local closeCallback = nil

function LevelUpViewMgr.Init()
	resName = "Charactor/Effects/LevelUp.csb"
	resNameDB = "Charactor/Effects/LevelUpDB.csb"
    particleRes = "Spine/effects/jueseshengjitexiao_1.plist"
    spineRes = {    
        "Spine/effects/Ui_jueseshengjibeiguang.png", 
        "Spine/effects/Ui_jueseshengjiguangshu.png",
        "Spine/effects/Ui_jueseshengjiziti.png",
    }
    
    shineAni = {}
    closeCallback = nil
end

function LevelUpViewMgr.show(lv1, lv2)
    UIStack.push("LevelUpViewMgr", LevelUpViewMgr.hide, true)
	local scene = SceneMgr.getRunningScene
	
	local function initCSB()
        CSResourceMgr.createRes(scene, resNameDB):setLocalZOrder(CocosModuleMgr.ZORDER_GUIDE)
        CSResourceMgr.setRelativePosition(resNameDB, 320, 480)
        
		local layer = CSResourceMgr.createRes(scene, resName)
		layer:setLocalZOrder(CocosModuleMgr.ZORDER_GUIDE)
		CSResourceMgr.setFullScreen(resName)
		
        CSResourceMgr.setLabelString(resName, "t1", "Lv."..lv1, "", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setLabelString(resName, "t2", "Lv."..lv2, "", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setLabelColor(resName, "t1", {r=255,g=252,b=0,a=255})
        CSResourceMgr.setLabelColor(resName, "t2", {r=255,g=252,b=0,a=255})
        
        local a1 = ExperienceInfo.getExperienceInfoByID(lv1).limitPower
        local a2 = ExperienceInfo.getExperienceInfoByID(lv2).limitPower
        CSResourceMgr.setLabelString(resName, "t3", a1, "", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setLabelString(resName, "t4", a2, "", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setLabelColor(resName, "t3", {r=255,g=252,b=0,a=255})
        CSResourceMgr.setLabelColor(resName, "t4", {r=255,g=252,b=0,a=255})

        CSResourceMgr.getNodeByName(resName, "levelup"):loadTexture(CocosModuleMgr.getWordImage("shengji.png"))
        
        CSResourceMgr.clickEventBinding(resName, "close", function()
        	LevelUpViewMgr.hide()
        end)
	end
	
	local function addAni()
	    local aniDB = CSResourceMgr.getNodeByName(resName, "ani")
        AnimationMgr.createAni(aniDB, spineRes[1], 0, 150):setScale(1.3)
        AnimationMgr.playAni(spineRes[1], "animation", true)
        PlayerAnimeMgr.createPlayer(aniDB, {skin=CharInfo.getCurfashion()}, PlayerAnimeMgr.COMMON_UI_TAG_STRING)
        PlayerAnimeMgr.setPlayerAniScale(PlayerAnimeMgr.COMMON_UI_TAG_STRING, 1.2)
        AnimationMgr.createAni(aniDB, spineRes[2], 0, 100)
        AnimationMgr.playAni(spineRes[2], "animation", true)
        AnimationMgr.createAni(CSResourceMgr.getNodeByName(resName, "levelup"), spineRes[3], 230, 50)
        AnimationMgr.playAni(spineRes[3], "animation", true)
        CSResourceMgr.createParticle(aniDB, particleRes, 0, 50):setScale(1.5)
	end
	
	local function playCSB()
		CSResourceMgr.playAllFrame(resName, false)
	end
	
    local funcTable = {initCSB, addAni, playCSB}
    local LockInfo = ExperienceInfo.getLevelLockDataByLevel(lv2)
    local parentVec = {}
    shineAni = {}
    for key, var in pairs(LockInfo.curIDs) do
        table.insert(funcTable, function()
            local lockData = ExperienceInfo.getLevelLockInfoByID(var)
            local parent = CSResourceMgr.getNodeByName(resName, "example"):clone()
            CSResourceMgr.getNodeByName(resName, "list"):pushBackCustomItem(parent)
            local icon = CSResourceMgr.seekNodeByName(parent, "icon")
            if lockData.ismap=="Y" then
                CSResourceMgr.setSpriteTextureByNode(icon, "Map/WorldMap/icon/"..lockData.icon..".png")
                icon:setScale(0.35)
            else
                CSResourceMgr.setSpriteTextureByNode(icon, "UI/CommonFiles/"..lockData.icon..".png")
            end
            local title = CSResourceMgr.seekNodeByName(parent, "title")
            CSResourceMgr.setLabelStringByNode(title, lockData.name, {r=125,g=59,b=0,a=255}, nil, 200)
            local desc = CSResourceMgr.seekNodeByName(parent, "desc")
            CSResourceMgr.setLabelStringByNode(desc, lockData.desc, nil, nil, 200)
            CSResourceMgr.setLabelColorByNode(desc, {r=125,g=59,b=0,a=255})
            local frame = CSResourceMgr.seekNodeByName(parent, "frame")
            frame:setColor({r=220,g=172,b=22})
            local symbol = CSResourceMgr.seekNodeByName(parent, "symbol")
            CSResourceMgr.setSpriteTextureByNode(symbol, "Pet/BasicPetList_2/xuanzhong.png")
            CSResourceMgr.setButtonEnabledByNode(parent, false)
            parent:setVisible(true)
            parent:setScaleY(0)
            parentVec[key] = parent
        end)
        table.insert(funcTable, function()
            local parent = parentVec[key]
            transition.scaleTo(parent, {scale=1, time=0.2})
            local ani = AnimationMgr.createAni(parent, "Spine/effects/Ui_juesechengjiusaoguang.png", parent:getContentSize().width/2, 
                parent:getContentSize().height/2, "LevelUpViewMgr"..key)
            AnimationMgr.playAni(ani.res, "animation", true, ani.tag)
            shineAni[key] = ani
        end)
    end
    for key, var in pairs(LockInfo.nextIDs) do
        table.insert(funcTable, function()
            local lockData = ExperienceInfo.getLevelLockInfoByID(var)
            local parent = CSResourceMgr.getNodeByName(resName, "example"):clone()
            CSResourceMgr.getNodeByName(resName, "list"):pushBackCustomItem(parent)
            local icon = CSResourceMgr.seekNodeByName(parent, "icon")
            if lockData.ismap=="Y" then
                CSResourceMgr.setSpriteTextureByNode(icon, "Map/WorldMap/icon/"..lockData.icon..".png")
            	icon:setScale(0.35)
            else
                CSResourceMgr.setSpriteTextureByNode(icon, "UI/CommonFiles/"..lockData.icon..".png")
            end
            local title = CSResourceMgr.seekNodeByName(parent, "title")
            CSResourceMgr.setLabelStringByNode(title, lockData.name, {r=125,g=59,b=0,a=255}, nil, 200)
            local desc = CSResourceMgr.seekNodeByName(parent, "desc")
            CSResourceMgr.setLabelStringByNode(desc, CocosModuleMgr.createStringWithFormat({"tips15", lockData.level}), nil, nil, 200)
            CSResourceMgr.setLabelColorByNode(desc, {r=60,g=67,b=61,a=255})
            local frame = CSResourceMgr.seekNodeByName(parent, "frame")
            frame:setColor({r=149,g=176,b=185})
            local symbol = CSResourceMgr.seekNodeByName(parent, "symbol")
            CSResourceMgr.setSpriteTextureByNode(symbol, "UI/CommonFiles/share_unlock_01.png")
            parent:setVisible(true)
            parent:setScaleY(0)
            transition.scaleTo(parent, {scale=1, time=0.2})
        end)
    end
    table.insert(funcTable, function()
    	GameAudio.playUISound("levelUp")
    end)
    UnblockLoader.load(funcTable, "LevelUpViewMgr", 0.1)
end

function LevelUpViewMgr.hide()
    UnblockLoader.cancel("LevelUpViewMgr")
    for var=1, #spineRes do
        AnimationMgr.removeGafObjectByTag(spineRes[var])
    end
    for key, var in pairs(shineAni) do
    	AnimationMgr.removeGafObjectByTag(var.res, var.tag)
    end
    CSResourceMgr.removeParticle(particleRes)
    PlayerAnimeMgr.removePlayerByTag(PlayerAnimeMgr.COMMON_UI_TAG_STRING, false)
    CSResourceMgr.removeCSObjectByTag(resNameDB)
	CSResourceMgr.removeCSObjectByTag(resName)
	if closeCallback then
	    closeCallback()
        closeCallback = nil
	end
    UIStack.pop("LevelUpViewMgr")
end

function LevelUpViewMgr.setCloseCallback(callback)
	closeCallback = callback
end

return LevelUpViewMgr