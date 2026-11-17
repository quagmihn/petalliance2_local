local BossDmgAwardsMgr = {}

local resName = ""
local resNameBG = ""
local tag = ""
local npcTag = ""
local isRequesting = false
local takeInfo = {}
local townResName = ""

function BossDmgAwardsMgr.Init()
    resName = "Map/WorldMap/BossAwards.csb"
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    tag = "BossDmgAwardsMgr"
    npcTag = "      "
    isRequesting = false
    takeInfo = {}
    townResName = ""
end

function BossDmgAwardsMgr.addChampionAni(townRes)
    townResName = townRes
    local player = PlayerAnimeMgr.createPlayer(CSResourceMgr.getNodeByName(townResName, "starani"), 
        {skin={15, 1057, 2057, 3057, 4057, 5057}}, tag)
    --[[
    local vec = PlayerAnimeMgr.playerTable[tag].spineobj
    for key, var in pairs(vec) do
        CocosModuleMgr.darkNode(var, true)
    end
    player:performWithDelay(function()
        for key, var in pairs(vec) do
            AnimationMgr.pauseAni(var.res, var.tag)
        end
    end, 0.1)]]
    
    CSResourceMgr.setLabelColor(townResName, "startitle", {r=0,g=0,b=0,a=255})
    CSResourceMgr.setLabelString(townResName, "startitle", "bossdmgaward6", nil, {r=255,g=255,b=255,a=255,w=1}, nil, 160)
    CSResourceMgr.setLabelString(townResName, "starawardst", "bossdmgaward7", nil, {r=0,g=0,b=0,a=255,w=1}, nil, 80)
    CSResourceMgr.setLabelString(townResName, "starinfot", "bossdmgaward8", nil, {r=0,g=0,b=0,a=255,w=1}, nil, 80)
    CSResourceMgr.getNodeByName(townResName, "starinfodb"):zorder(-1)
    
    CSResourceMgr.getNodeByName(townResName, "starinfo"):hide()
    CSResourceMgr.getNodeByName(townResName, "startipsdb"):hide()
    CSResourceMgr.clickEventBinding(townResName, "starawards", function()
    	BossDmgAwardsMgr.show()
    end, nil, 3)
    CSResourceMgr.clickEventBinding(townResName, "starinfo", function()
        BossDmgAwardsMgr.showInputBox()
    end, nil, 3)
end

function BossDmgAwardsMgr.refreshChampionAni()
    local npcAniVec = PlayerAnimeMgr.getPlayer(tag)
    if npcAniVec then
        local ChampionData = WorldBossInfo.getWeekChampionData()
        local name = GameGuideMgr.NPC_NAME[2]
        if ChampionData then
            name = ChampionData.nickName
            PlayerAnimeMgr.setPlayerSkins(tag, ChampionData.fashions)
            --ChampionData.familyName
            if CharInfo.getCharID()==ChampionData.charID then
            	--显示改名言按钮
                CSResourceMgr.getNodeByName(townResName, "starinfo"):show()
            end
            if ChampionData.message~="" then
                local maxLength = 150
                CSResourceMgr.getNodeByName(townResName, "startipsdb"):show()
                local dbNode = CSResourceMgr.getNodeByName(townResName, "startips")
                dbNode:removeAllChildren(true)
                local richStr = CocosModuleMgr.createRichLabelString({{color="000000", text=ChampionData.message}})
                local richtext = CocosModuleMgr.createRichLabel(dbNode, richStr, 16, "cuyuan_GBK.ttf",
                    maxLength, 0, 0, nil, false)
                richtext:setPosition(-richtext.realWidth/2, 0)
                --[[
                CSResourceMgr.setLabelColor(townResName, "startips", {r=0,g=0,b=0,a=255})
                CSResourceMgr.setLabelString(townResName, "startips", ChampionData.message, nil, {r=255,g=255,b=255,a=255,w=1})
                CSResourceMgr.setLabelMaxWidth(townResName, "startips", maxLength)
                
                --换行保护
                local label = CSResourceMgr.getNodeByName(townResName, "startips")
                local rate = label:getScaleX()
                label:ignoreContentAdaptWithSize(true)
                label:setTextAreaSize({width = 150/rate, height = 0})
                label:ignoreContentAdaptWithSize(false)
                label:setTextAreaSize({width = 150/rate, height = label:getContentSize().height})
                ]]
            end
        end
        CSResourceMgr.setLabelString(townResName, "starname", name, nil, {r=0,g=0,b=0,a=255,w=1})
	end
end

function BossDmgAwardsMgr.checkRedPoint()
    local canGet = false
    local bossDamageNum = WorldBossInfo.getWeekDamage()
    for key, var in pairs(takeInfo) do
		if CharInfo.get()[var.key]==1 then
            if not WorldBossInfo.checkWeekTimeValid(CharInfo.get()[var.time]) then
                if bossDamageNum>=var.damage then
                    canGet = true
                    break
                end
			end
		else
            if bossDamageNum>=var.damage then
                canGet = true
                break
            end
		end
	end
    local button = CSResourceMgr.getNodeByName(townResName, "starawards")
    if canGet then
    	print("BOSS伤害奖励-有可领取红点")
        CocosModuleMgr.showShiningToNode(button, 4)
    else
        print("BOSS伤害奖励-无可领取红点")
        CocosModuleMgr.hideShiningToNode(button)
    end
end

function BossDmgAwardsMgr.requestMyData(boolBlock, callback)
    local funcName = NetInterface.send
    if boolBlock then
        funcName = NetInterface.sendWithBlock
    end
    local reqVec = {"weekDamage", "weekDamageTime"}
    local content = WorldBossInfo.getWorldBossWeekAwardInfo()
    for var=1, #content do
        local index = content[var].id
        table.insert(reqVec, "weekTake"..index)
        table.insert(reqVec, "takeWeekAwardTime"..index)
        takeInfo[index] = {key="weektake"..index, time="takeweekawardtime"..index, damage=content[var].damageCondition}
    end
    funcName("GC_GetCharacterValues_Ack", function()
        local LoginSend = require("src.Net.Send.LoginSend")
        LoginSend.sendCG_GetCharacterValues_Req(reqVec)
    end, function()
        if callback then
        	callback()
        end
        --计算红点
        BossDmgAwardsMgr.checkRedPoint()
    end, function(code)
        TipsMgr.showError(nil, code)
    end)
end

function BossDmgAwardsMgr.requestChampionData()
    if isRequesting or CharInfo.getCharID()==0 then
    	return
    end
    isRequesting = true
    NetInterface.send("GC_GetWeekChampionData_Ack", function()
    	local WorldBossSend = require("src.Net.Send.WorldBossSend")
    	WorldBossSend.sendCG_GetWeekChampionData_Req()
    end, function()
        isRequesting = false
        BossDmgAwardsMgr.requestMyData()
        --刷新冠军形象
        BossDmgAwardsMgr.refreshChampionAni()
    end, function(code)
        isRequesting = false
    	TipsMgr.showError(nil, code)
        BossDmgAwardsMgr.requestMyData()
    end)
end

function BossDmgAwardsMgr.show(scene)
    UIStack.push(tag, BossDmgAwardsMgr.hide, true)
    scene = scene or SceneMgr.getRunningScene
    
    local bossDamageNum = WorldBossInfo.getWeekDamage()
    
    local function loadCSB()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG, tag)
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, tag)
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    
        local layer = CSResourceMgr.createRes(scene, resName)
        layer:zorder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName)

        local title = CSResourceMgr.getNodeByName(resName, "title")
        CSResourceMgr.setLabelStringByNode(title, "bossdmgaward1", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 250)
        local tinfo = CSResourceMgr.getNodeByName(resName, "info")
        CSResourceMgr.setLabelStringByNode(tinfo, "bossdmgaward2", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 300)
        local damage = CSResourceMgr.getNodeByName(resName, "damage")
        CSResourceMgr.setLabelStringByNode(damage, bossDamageNum, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 150)
        local tips = CSResourceMgr.getNodeByName(resName, "tips")
        local hour = math.floor(WorldBossInfo.getMainBossStartTime()/3600)
        CSResourceMgr.setLabelStringByNode(tips, CocosModuleMgr.createStringWithFormat({"bossdmgaward3", 
            WorldBossInfo.getMainBossStartDay(), hour}), {r=0,g=0,b=0,a=255,w=1,s=1})
        CSResourceMgr.setLabelMaxWidthByNode(tips, 490)
        tips:setAnchorPoint(0, 0.5)
        local btn_close = CSResourceMgr.getNodeByName(resName, "close")
        CSResourceMgr.clickEventBindingByNode(btn_close, function()
            BossDmgAwardsMgr.hide()
        end)
        CSResourceMgr.getNodeByName(resName, "list"):setItemsMargin(10)
        CSResourceMgr.getNodeByName(resName, "bg"):setOpacity(0)

        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName, "db"), "up")
    end
    
    local funcTable = {loadCSB}
    
    local content = WorldBossInfo.getWorldBossWeekAwardInfo()
    
    for n=1, #content do
        local info = content[n]
        table.insert(funcTable, function()
            local list = CSResourceMgr.getNodeByName(resName, "list")
            local reward = CSResourceMgr.getNodeByName(resName, "example")
            local parent = reward:clone()
            list:pushBackCustomItem(parent)
            local bg = CSResourceMgr.seekNodeByName(parent, "extdb")
            bg:setColor({r=4,g=64,b=74,a=255})
            local reward_title = CSResourceMgr.seekNodeByName(parent, "ext")
            CSResourceMgr.setLabelStringByNode(reward_title, CocosModuleMgr.createStringWithFormat({"bossdmgaward5", 
                CocosModuleMgr.getNumberString(info.damageCondition)}), {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 475)
            CSResourceMgr.setLabelColorByNode(reward_title, {r=255,g=252,b=0,a=255})
            local finish_title = CSResourceMgr.seekNodeByName(parent, "finish")
            CSResourceMgr.setLabelStringByNode(finish_title, "mission7", {r=32,g=126,b=192,a=255,w=3}, nil, 150)
            finish_title:setRotation(-25)
            local circle = CSResourceMgr.seekNodeByName(parent, "circle")
            local getBtn = CSResourceMgr.seekNodeByName(parent, "get")
            --如果领了
            local function getFunc()
                finish_title:show()
                circle:show()
                getBtn:hide()
            end
            --如果没有领
            local function restoreFunc()
                finish_title:hide()
                circle:hide()
                getBtn:show()
            end
            if CharInfo.get()[takeInfo[info.id].key]==1 then
                if WorldBossInfo.checkWeekTimeValid(CharInfo.get()[takeInfo[info.id].time]) then
                    getFunc()
                else
                    restoreFunc()
            	end
            else
                restoreFunc()
            end
            CSResourceMgr.clickEventBindingByNode(getBtn, function()
                getFunc()
                NetInterface.sendWithBlock("GC_TakeWeekAward_Ack", function()
                	local WorldBossSend = require("src.Net.Send.WorldBossSend")
                	WorldBossSend.sendCG_TakeWeekAward_Req(info.id)
                end, function()
                	local charData = CharInfo.get()
                	charData[takeInfo[info.id].key] = 1
                    charData[takeInfo[info.id].time] = CharInfo.getServerTime()
                end, function(code)
                	TipsMgr.showError(nil, code)
                end)
            end)
            CSResourceMgr.setButtonStringByNode(getBtn, "idling9", {r=0,g=0,b=0,a=255,w=1,s=1})
            CSResourceMgr.setButtonEnabledByNode(getBtn, info.damageCondition<=bossDamageNum)
            
            local loopNum = #info.awardList
            if loopNum>4 then
            	loopNum = 4
            end
            for var=1, loopNum do
                local iInfo = {}
                
                local itemID = info.awardList[var].itemID
                local rNum = info.awardList[var].count
                local rInfo = ItemInfo.getAwardElementInfoById(itemID)
                local rType = rInfo.elementType
                local rID = rInfo.elementID
                if rType==3 then
                    iInfo = {rID, rNum}
                elseif rType==5 then
                    print("BOSS战奖励不支持宠物")
                else
                    iInfo = {ItemInfo.AWARD[rType], rNum}
                end
                
                if #iInfo>0 then
                    local node = ItemInfo.getItemIconById(iInfo[1], iInfo[2], nil, true)
                    node:addTo(parent)
                    node:pos(60+(var-1)*85, 75)
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
    
    UnblockLoader.load(funcTable, tag)
end

function BossDmgAwardsMgr.hide()
    UnblockLoader.cancel(tag)
    CSResourceMgr.removeCSObjectByTag(resNameBG, tag)
    CSResourceMgr.removeList(resName, "list")
    CSResourceMgr.removeCSObjectByTag(resName)
    BossDmgAwardsMgr.checkRedPoint()
    UIStack.pop(tag)
end

function BossDmgAwardsMgr.showInputBox()
    DialogBoxMgr.INPUT_EDITBOX_LENTH = 108
    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 3, "bossdmgaward4", function()
        if DialogBoxMgr.GetInputText()~="" then
            GameAudio.playUISound("success")
            NetInterface.sendWithBlock("GC_UpdateMessage_Ack", function()
            	local WorldBossSend = require("src.Net.Send.WorldBossSend")
            	WorldBossSend.sendCG_UpdateMessage_Req(DialogBoxMgr.GetInputText())
            end, function()
                TipsMgr.show(nil, "chat12")
                local ChampionData = WorldBossInfo.getWeekChampionData()
                if ChampionData then
                    ChampionData.message = DialogBoxMgr.GetInputText()
                    BossDmgAwardsMgr.refreshChampionAni()
                end                
            end, function(code)
            	TipsMgr.showError(nil, code)
            end)
        end
    end)
    DialogBoxMgr.INPUT_EDITBOX_LENTH = 18
end

return BossDmgAwardsMgr