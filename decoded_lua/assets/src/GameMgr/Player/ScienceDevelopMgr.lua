local ScienceDevelopMgr = {}

local resVec = {}
local tagMain = ""

function ScienceDevelopMgr.Init()
    resVec = {"Player/Science/ScienceFeedexp.csb", "Player/Science/ScienceUpgrade.csb"}
    tagMain = "ScienceDevelopMgr"
end

local function hideUI(type)
    local tag = tagMain..type
    local resName = resVec[type]
    if not resName then
        return
    end
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    UnblockLoader.cancel(tag)
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop(tag)
end

local function showUI(type, info)
	local tag = tagMain..type
	local resName = resVec[type]
	if not resName then
		return
	end
    if not CSResourceMgr.getCsbObj(resName) then
        UIStack.push(tag, function()
        	hideUI(type)
        end, false)
    end
    local function loadCSB()
        local layer = CSResourceMgr.getCsbObj(resName)
        if not layer then
            layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, resName)
            layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
            CSResourceMgr.setRelativePosition(resName, 320, 480)
            CSResourceMgr.getNodeByName(resName, "db"):hide()
            local edb1 = CSResourceMgr.getNodeByName(resName, "edb1")
            local edb2 = CSResourceMgr.getNodeByName(resName, "edb2")
            layer.stars = {{}, {}}
            local maxs = ScienceInfo.getMaxStar()
            for n=1, maxs*2 do
                local star = display.newSprite("empty.png")
                if n<=maxs then
                    star:addTo(edb1)
                    layer.stars[1][n] = star
                    star:pos(142+(n-1)*33, 70)
                else
                    star:addTo(edb2)
                    layer.stars[2][n-10] = star
                    star:pos(142+(n-11)*33, 70)
                end
            end
        end
        CSResourceMgr.clickEventBinding(resName, "close", function()
            hideUI(type)
        end)
        CSResourceMgr.clickEventBinding(resName, "bg", function()
            hideUI(type)
        end)
        local outlineColor = {r=0,g=0,b=0,a=255,w=1,s=1}
        local expMax = ScienceInfo.getExpMax(info.id, info.star, info.level)
        local progressBar = CSResourceMgr.getNodeByName(resName, "progress")
        local expPercent = info.exp*100/expMax
        local barSpeed = 5
        local function setExpBar(boolAni)
            if boolAni then
                CocosModuleMgr.setLoadingBarPercent(progressBar, expPercent, barSpeed, function(p)
                    if p==expPercent then
                        CSResourceMgr.setLabelString(resName, "t5", info.exp, nil, outlineColor, nil, 100)
                    else
                        CSResourceMgr.setLabelString(resName, "t5", math.floor(p*expMax/100), nil, outlineColor, nil, 100)
                    end
                end)
            else
                progressBar:setPercent(expPercent)
                CSResourceMgr.setLabelString(resName, "t5", info.exp, nil, outlineColor, nil, 100)
            end
        end
        local needSetT6 = true
        if progressBar.level and progressBar.percent then
            if info.level>=progressBar.level then
                if info.level==ScienceInfo.getMaxLevel() and progressBar.level==ScienceInfo.getMaxLevel()-1 then
                    progressBar:setPercent(0)
                    setExpBar(true)
                else
                    progressBar:setPercent(0)
                    local tmpMax = ScienceInfo.getExpMax(info.id, info.star, progressBar.level)
                    CSResourceMgr.setLabelString(resName, "t6", "/"..tmpMax, nil, outlineColor, nil, 100)
                    needSetT6 = false
                    CocosModuleMgr.setLoadingBarPercent(progressBar, 100, barSpeed, function(p)
                        if p==100 then
                            CSResourceMgr.setLabelString(resName, "t6", "/"..expMax, nil, outlineColor, nil, 100)
                            CSResourceMgr.setLabelString(resName, "t5", 0, nil, outlineColor, nil, 100)
                            progressBar:setPercent(0)
                        else
                            CSResourceMgr.setLabelString(resName, "t5", math.floor(p*tmpMax/100), nil, outlineColor, nil, 100)
                        end
                    end)
                end
                --[[
                if info.level==progressBar.level or 
                    (info.level==ScienceInfo.getMaxLevel() and progressBar.level==ScienceInfo.getMaxLevel()-1) then
                    if progressBar.percent+1<expPercent then
                        setExpBar(true)
        			else
                        setExpBar()
        			end
        		else
                    progressBar:setPercent(0)
                    setExpBar(true)
        		end]]
        	else
                setExpBar()
        	end
        else
            setExpBar()
        end
        progressBar.level = info.level
        progressBar.percent = expPercent
        CSResourceMgr.setSpriteTexture(resName, "icdb", ScienceInfo.getIconFrameRes(info.type))
        CSResourceMgr.setSpriteTexture(resName, "icon", info.icon)
        CSResourceMgr.setLabelColor(resName, "title", {r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelColor(resName, "t3", {r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelString(resName, "t3", info.name, nil, {r=12,g=27,b=38,a=255}, nil, 300)
        CSResourceMgr.setLabelString(resName, "t4", "science18", nil, outlineColor, nil, 50)
        CSResourceMgr.setLabelColor(resName, "t6", {r=252,g=255,b=0,a=255})
        if needSetT6 then
            CSResourceMgr.setLabelString(resName, "t6", "/"..expMax, nil, outlineColor, nil, 100)
        end
        CSResourceMgr.setLabelColor(resName, "t7", {r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelString(resName, "t7", "train86", nil, {r=12,g=27,b=38,a=255}, nil, 120)
        CSResourceMgr.setLabelString(resName, "t8", "Lv."..info.level, nil, outlineColor, nil, 80)
        CSResourceMgr.setLabelString(resName, "t10", info.desc, nil, outlineColor, nil, 200)
        CSResourceMgr.setLabelString(resName, "t11", info.desc, nil, outlineColor, nil, 200)
        local effstr = "science4"
        if info.type==2 then
        	effstr = "<1>%"
        end
        CSResourceMgr.setLabelString(resName, "t12", CocosModuleMgr.createStringWithFormat({effstr, 
            ScienceInfo.getSkillEffect(info.id, info.star, info.level)}), nil, outlineColor, nil, 120)
        CSResourceMgr.setLabelString(resName, "t13", CocosModuleMgr.createStringWithFormat({effstr,
            ScienceInfo.getSkillEffect(info.id, info.star, info.level, true)}), nil, outlineColor, nil, 120)
        local function setStar(starnum, index)
            for var=1, starnum do
                CSResourceMgr.setSpriteTextureByNode(layer.stars[index][var], "Player/Science/xing.png")
            end
            for var=starnum+1, ScienceInfo.getMaxStar() do
                CSResourceMgr.setSpriteTextureByNode(layer.stars[index][var], "Player/Science/xing_hui.png")
            end
        end
        setStar(info.star, 1)
        local seq = cc.Sequence:create({cc.ScaleTo:create(0.1, 0, 1), cc.ScaleTo:create(0.3, 1, 1), cc.DelayTime:create(1)})
        local rep = cc.RepeatForever:create(seq)
        local arrow = CSResourceMgr.getNodeByName(resName, "arrow")
        transition.stopTarget(arrow)
        arrow:runAction(rep)
        local function playBlinkAni(node)
            transition.stopTarget(node)
            local seq = cc.Sequence:create({cc.FadeOut:create(0.5), cc.FadeIn:create(0.2), cc.DelayTime:create(1)})
            local rep = cc.RepeatForever:create(seq)
            node:runAction(rep)
        end
        playBlinkAni(CSResourceMgr.getNodeByName(resName, "max1"))
        if type==1 then
            setStar(info.star, 2)
            CSResourceMgr.setLabelString(resName, "title", "science15", nil, {r=12,g=27,b=38,a=255}, nil, 300)
            CSResourceMgr.setLabelColor(resName, "info", {r=255,g=114,b=0,a=255})
            CSResourceMgr.setLabelString(resName, "info", "science19", nil, outlineColor)
            CSResourceMgr.setLabelMaxWidth(resName, "info", 520)
            local ainfo = ItemInfo.getItemInfoById(ScienceInfo.ITEM_ID)
            CSResourceMgr.setLabelColor(resName, "t1", {r=144,g=238,b=255,a=255})
            CSResourceMgr.setLabelString(resName, "t1", CocosModuleMgr.createStringWithFormat({"science11", ainfo.name}), 
                nil, outlineColor, nil, 120)
            CSResourceMgr.setLabelString(resName, "t2", ScienceInfo.getSciencePoint(), nil, outlineColor, nil, 130)
            CSResourceMgr.setLabelString(resName, "t9", "Lv."..(info.level+1), nil, outlineColor, nil, 80)
            local b1 = CSResourceMgr.getNodeByName(resName, "b1")
            local b2 = CSResourceMgr.getNodeByName(resName, "b2")
            local max1 = CSResourceMgr.getNodeByName(resName, "max1")
            local max2 = CSResourceMgr.getNodeByName(resName, "max2")
            playBlinkAni(max2)
            local vnodes = {b1, arrow, CSResourceMgr.getNodeByName(resName, "edb2"), CSResourceMgr.getNodeByName(resName, "line2"),
                CSResourceMgr.getNodeByName(resName, "t9"), CSResourceMgr.getNodeByName(resName, "t11"), 
                CSResourceMgr.getNodeByName(resName, "t13")}
            local uvnodes = {b2, --[[max1,]] max2}
            for key, var in pairs(vnodes) do
                var:setVisible(not (info.level>=ScienceInfo.getMaxLevel()))
            end
            for key, var in pairs(uvnodes) do
                var:setVisible(info.level>=ScienceInfo.getMaxLevel())
            end
            CSResourceMgr.setButtonString(resName, "b1", "science16", nil, outlineColor)
            CSResourceMgr.setButtonString(resName, "b2", "science14", nil, outlineColor)
            CSResourceMgr.clickEventBinding(resName, "b1", function()
                --[[
                local level = GetRandom.random(info.level, ScienceInfo.getMaxLevel())
                local expmax = ScienceInfo.getExpMax(info.id, info.star, level)
                local exp = GetRandom.random(0, expmax)
                if level==info.level then
                    exp = GetRandom.random(info.exp, expmax)
                elseif level==ScienceInfo.getMaxLevel() then
                    exp = expmax
                end
                info.exp = exp
                info.level = level
                ]]
                --[[
                local curPoint = ScienceInfo.getSciencePoint()
                local needPoint = 0
                local level = info.level
                local exp = 0
                for var=info.level, ScienceInfo.getMaxLevel()-1 do
                    local expmax = ScienceInfo.getExpMax(info.id, info.star, var)
                    exp = expmax
                	if var==info.level then
                        needPoint = needPoint+expmax-info.exp
                    else
                        needPoint = needPoint+expmax
                	end
                    if needPoint>curPoint then
                        exp = exp-(needPoint-curPoint)
                        needPoint = curPoint
                		break
                	else
                        level = var+1
                	end
                end
                info.exp = exp
                info.level = level
                ScienceInfo.changeSciencePoint(-needPoint)
                ]]
                if ScienceInfo.getSciencePoint()<ScienceInfo.getExpMax(info.id, info.star, info.level) then
                    StandardTipsMgr.show(1, "science21")
                	return
                end
                NetInterface.sendWithBlock("GC_ScienceLevelUp_Ack", function()
                	local PetSend = require("src.Net.Send.PetSend")
                	PetSend.sendCG_ScienceLevelUp_Req(info.id)
                end, function()
                    showUI(1, info)
                    ScienceViewMgr.refreshSkillItem(info)
                end, function(code)
                	TipsMgr.showError(nil, code)
                end)
            end)
            CSResourceMgr.clickEventBinding(resName, "b2", function()
                hideUI(1)
                showUI(2, info)
            end)
            if info.star>=ScienceInfo.getMaxStar() then
                CSResourceMgr.setButtonString(resName, "b2", "science20", nil, outlineColor)
                CSResourceMgr.setButtonEnabled(resName, "b2", false)
            end
        elseif type==2 then
            setStar(info.star+1, 2)
            local materials = ScienceInfo.getUpgradeMaterial(info.id, info.star)
            CSResourceMgr.setLabelString(resName, "title", "science12", nil, {r=12,g=27,b=38,a=255}, nil, 300)
            CSResourceMgr.setLabelString(resName, "t9", "Lv.1", nil, outlineColor, nil, 80)
            CSResourceMgr.setLabelColor(resName, "t14", {r=144,g=238,b=255,a=255})
            CSResourceMgr.setLabelString(resName, "t14", "science13", nil, {r=12,g=27,b=38,a=255}, nil, 120)
            CSResourceMgr.setButtonString(resName, "b1", "science3", nil, outlineColor)
            CSResourceMgr.clickEventBinding(resName, "b1", function()
                for var=1, #materials do
                    local iInfo = materials[var]
                    local num = ItemInfo.getCharItemNum(iInfo[1])
                    if iInfo[1]==ScienceInfo.ITEM_ID then
                    	num = ScienceInfo.getSciencePoint()
                    end
                    if num<iInfo[2] then
                        StandardTipsMgr.show(1, "train120")
                    	return
                    end
                end
                NetInterface.sendWithBlock("GC_ScienceStarUp_Ack", function()
                    local PetSend = require("src.Net.Send.PetSend")
                    PetSend.sendCG_ScienceStarUp_Req(info.id)
                end, function()
                    ScienceViewMgr.refreshSkillItem(info)
                    hideUI(2)
                end, function(code)
                    TipsMgr.showError(nil, code)
                end)
            end)
            for var=1, #materials do
                local iInfo = materials[var]
            	local list = CSResourceMgr.getNodeByName(resName, "list")
            	local node = CSResourceMgr.getNodeByName(resName, "example"):clone()
                list:pushBackCustomItem(node)
                node:show()
                local item = ItemInfo.getItemIconById(iInfo[1])
                item:addTo(node)
                item:pos(64, 76)
                item:scale(0.7)
                local num1 = CSResourceMgr.seekNodeByName(node, "num1")
                local num2 = CSResourceMgr.seekNodeByName(node, "num2")
                local num = ItemInfo.getCharItemNum(iInfo[1])
                if iInfo[1]==ScienceInfo.ITEM_ID then
                    num = ScienceInfo.getSciencePoint()
                end
                CSResourceMgr.setLabelStringByNode(num1, num, outlineColor, nil, 50)
                CSResourceMgr.setLabelStringByNode(num2, "/"..iInfo[2], outlineColor, nil, 50)
                if num<iInfo[2] then
                    CSResourceMgr.setLabelColorByNode(num1, {r=255,g=66,b=0,a=255})
                end
                CSResourceMgr.buttonEventBindingByNode(item, function()
                    ItemInfoViewMgr.show({id = iInfo[1], type = 2}, false)
                end, function()
                    ItemInfoViewMgr.hide()
                end, nil, function()
                    ItemInfoViewMgr.hide()
                end)
            end
            if info.star>=ScienceInfo.getMaxStar() then
                StandardTipsMgr.show(1, "science20")
                hideUI(2)
            end
        end
    end
    local function playCSB()
        local node = CSResourceMgr.getNodeByName(resName, "db")
        if node:isVisible()==false then
            node:show()
            CocosModuleMgr.showUIAnimation(node, "down")
        end
    end
    local funcTable = {loadCSB, playCSB}
    UnblockLoader.load(funcTable, tag)
end

function ScienceDevelopMgr.showFeed(info)
    showUI(1, info)
end

function ScienceDevelopMgr.showUpgrade(info)
    showUI(2, info)
end

return ScienceDevelopMgr