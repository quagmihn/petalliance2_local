local ActivityPublicjMgr = {}

ActivityPublicjMgr.LUOTIANYI_TYPE = 10

local labelColor = {
    {r=0,g=0,b=0,a=255},
    {r=255,g=252,b=0,a=255},
    {r=166,g=243,b=255,a=255},
}
local outlineColor = {
    {r=0,g=0,b=0,a=255},
    {r=0,g=0,b=0,a=255,w=1,s=1},
    {r=0,g=0,b=0,a=255,w=1,s=2},
}
local scheduler = require("src.framework.scheduler")

local resNameBG = ""
local resName = {}
local tag = {}
local rankInfo = {}
local refreshRankTime = 0
local lockInfo = nil
local awardsVec = nil
local myPoint = 0
local myRank = 0
local percentHandler = nil

function ActivityPublicjMgr.Init()
    --[[
    resNameBG = "Pet/Formation/FormationBGNew.csb"
	resName = {
	    "UI/Activity/Luotianyi/Luotianyi.csb",
        "UI/Activity/Luotianyi/LuotianyiRank.csb",
        "Spine/effects/Ui_chongwulingqujiemian.png",
        "UI/Activity/Luotianyi/LuotianyiRule.csb",
	}
    tag = {
        "ActivityPublicjMgr.showLuotianyi",
        "ActivityPublicjMgr.showLuotianyiRank",
        "ActivityPublicjMgr.showLuotianyiRule",
    }
    rankInfo = {}
    refreshRankTime = 0
    if lockInfo==nil then
        awardsVec = {}
        local dayDiff = 0
        local dayDiffInfo = SystemInfo.getGlobalConfigAddInfoByID(77)
        if dayDiffInfo then
            dayDiff = dayDiffInfo.values[1]
        end
        local posVec = {72, 149, 259, 336.5, 412, 507, 602}
        local lockInfoReader = TxtReader.new("Config/luotianyilock.txt")
        lockInfo = lockInfoReader.init({"id", "time", "pick", "awards"}, 1, {id=1, time=1, pick=1})
        for var=1, #lockInfo do
            lockInfo[var].time = lockInfo[var].time-86400*dayDiff
        	if lockInfo[var].awards~="0" then
                local aVec = lua_string_split(lockInfo[var].awards, "&")
                local tmpVec = {}
                for v=1, #aVec do
                    local iVec = lua_string_split(aVec[v], "_")
                    table.insert(tmpVec, iVec)
                end
                local curP = posVec[#awardsVec+1]
                table.insert(awardsVec, {per=lockInfo[var].id, awards=tmpVec, pos=curP, time=lockInfo[var].time})
        	end
        end
    end
    
    if percentHandler then
        scheduler.unscheduleGlobal(percentHandler)
        percentHandler = nil
    end
    ]]
end

function ActivityPublicjMgr.refreshServerTime()
    if not CharInfo.get().activity then
    	return
    end
    local function addRedPoint()
    	StatusBarMgr.addRedPoint(10)
    end
    if lockInfo[#lockInfo].time>CharInfo.getServerTime() then
        for var=1, #awardsVec do
            local aInfo = awardsVec[var]
            local haveGot = ActivityPublicjMgr.getBoxStatus(aInfo.per)
            if aInfo.time<=CharInfo.getServerTime() then
                if not haveGot then
                    addRedPoint()
                end
            else
                if percentHandler then
                    scheduler.unscheduleGlobal(percentHandler)
                end
                local timediff = aInfo.time-CharInfo.getServerTime()
                percentHandler = scheduler.performWithDelayGlobal(function()
                    addRedPoint()
                end, timediff)
                print("下次洛天依礼盒能领取时间", timediff)
                break
            end
        end
    end    
end

function ActivityPublicjMgr.requestLuotianyi(scene)
    NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
        local LoginSend = require("src.Net.Send.LoginSend")
        LoginSend.sendCG_GetCharacterValues_Req({"activity"})
    end, function()
        ActivityPublicjMgr.showLuotianyi(scene)
    end, function(code)
        TipsMgr.showError(nil, code)
    end)
end

function ActivityPublicjMgr.showLuotianyi(scene)
    UIStack.push(tag[1], ActivityPublicjMgr.hideLuotianyi, true)
    scene = scene or SceneMgr.getRunningScene
    
    local percentVec = awardsVec
    local pickIDs = {}
    local currentPercent = 0
    for var=1, #lockInfo do
        local lInfo = lockInfo[var]
        if lInfo.time<CharInfo.getServerTime() then
            if lInfo.pick~=0 then
                table.insert(pickIDs, lInfo.pick)
            end
            currentPercent = var
        else
            break
        end
    end
    print("当前拼图进度", currentPercent)
    
    local function loadCSB()
    	CSResourceMgr.createRes(scene, resNameBG, tag[1]):zorder(CocosModuleMgr.ZORDER_WINDOW)
    	CSResourceMgr.setRelativePosition(resNameBG, 320, 480, tag[1])
    	CSResourceMgr.clickEventBinding(resNameBG, "block", function()
    	    if CSResourceMgr.getCsbObj(resName[1]):isVisible() then
                ActivityPublicjMgr.hideLuotianyi()
    	    end
    	end, tag[1])
    	
        local layer = CSResourceMgr.createRes(scene, resName[1])
        layer:zorder(CocosModuleMgr.ZORDER_WINDOW)
        layer:hide()
        CSResourceMgr.setFullScreen(resName[1])
        CSResourceMgr.setLabelString(resName[1], "title", "activity15", nil, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 250)
        CSResourceMgr.setButtonString(resName[1], "rank", "stageboss3", nil, {r=0,g=0,b=0,a=255,w=1,s=1})
        CSResourceMgr.clickEventBinding(resName[1], "rank", function()
            NetInterface.sendWithBlock("GC_GetMyPlayerPoint_Ack", function()
            	local LoginSend = require("src.Net.Send.LoginSend")
                LoginSend.sendCG_GetMyPlayerPoint_Req()
            end, function()
                ActivityPublicjMgr.showLuotianyiRank(scene)
            end, function(code)
            	TipsMgr.showError(nil, code)
            end)
        end)
        CSResourceMgr.setButtonString(resName[1], "rule", "activity13", nil, {r=0,g=0,b=0,a=255,w=1,s=1})
        CSResourceMgr.clickEventBinding(resName[1], "rule", function()
            local function closeRule()
                CSResourceMgr.removeCSObjectByTag(resName[4])
                UIStack.pop(tag[3])
            end
            UIStack.push(tag[3], closeRule, false)
        	CSResourceMgr.createRes(scene, resName[4]):zorder(CocosModuleMgr.ZORDER_WINDOW)
        	CSResourceMgr.setFullScreen(resName[4])
            CSResourceMgr.clickEventBinding(resName[4], "closeTipBtn", closeRule)
            CSResourceMgr.setLabelString(resName[4], "title1", "activity13", nil, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 250)
            CSResourceMgr.setLabelString(resName[4], "tipInfo", "activity14", nil, {r=0,g=0,b=0,a=255,w=1,s=1}, -1)
            CSResourceMgr.setLabelMaxWidth(resName[4], "tipInfo", CSResourceMgr.getNodeByName(resName[4], "list")
                :getContentSize().width, nil, -1)
            CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName[4], "TipsPage"), "down")
        end)
    end
    
    local function playCSB()
        local layer = CSResourceMgr.getCsbObj(resName[1])
        layer:show()
        CocosModuleMgr.showUIAnimation(layer, "down")
        CocosModuleMgr.setLoadingBarPercent(CSResourceMgr.getNodeByName(resName[1], "bar"), currentPercent, 3)
        local function showPick(index)
            if not pickIDs[index] then
                if currentPercent==100 then
                	transition.fadeOut(CSResourceMgr.getNodeByName(resName[1], "pickdb"), {time=0.5})
                	CSResourceMgr.getNodeByName(resName[1], "image"):show()
                end
        		return
        	end
            CSResourceMgr.getNodeByName(resName[1], pickIDs[index]..""):show()
            layer:performWithDelay(function()
                showPick(index+1)
            end, 0.05)
        end
        showPick(1)
    end
    
    local funcTable = {loadCSB, playCSB}
    for var=1, #percentVec do
        table.insert(funcTable, function()            
            local boxTag = "luotianyi"..var
            local parent = CSResourceMgr.getNodeByName(resName[1], "example")
            local info = percentVec[var]
            local haveGot = ActivityPublicjMgr.getBoxStatus(info.per)
            local itemVec = {}
            for k=1, #info.awards do
                local eleID = info.awards[k][1]
                local eleNum = info.awards[k][2] or 1
                local rInfo = ItemInfo.getAwardElementInfoById(eleID)
                local rType = rInfo.elementType
                local rID = rInfo.elementID
                if rType==3 then
                    local iInfo = ItemInfo.getItemInfoById(rID)
                    table.insert(itemVec, {rID, eleNum})
                elseif rType==5 then
                    for v=1, eleNum do
                        table.insert(itemVec, {"pet", rID})
                    end
                else
                    table.insert(itemVec, {ItemInfo.AWARD[rType], eleNum})
                end
            end
        	if var>1 then
                parent = parent:clone()
                parent:addTo(CSResourceMgr.getCsbObj(resName[1]))
        	end
        	parent:setScale(0)
        	parent:show()
        	parent:setPositionX(info.pos)
        	local pNum = CSResourceMgr.seekNodeByName(parent, "percent")
        	CSResourceMgr.setLabelStringByNode(pNum, info.per.."%", {r=0,g=0,b=0,a=255,w=2})
        	local button = CSResourceMgr.seekNodeByName(parent, "button")
        	CSResourceMgr.clickEventBindingByNode(button, function()
                if currentPercent>=info.per then
                    NetInterface.sendWithBlock("GC_FetchSpokesmanGuessAwards_Ack", function()
                        local ActivitySend = require("src.Net.Send.ActivitySend")
                        ActivitySend.sendCG_FetchSpokesmanGuessAwards_Req({aID=ActivityPublicjMgr.LUOTIANYI_TYPE, awardIndex=info.per-1})
                    end, function()
                        print("GC_FetchSpokesmanGuessAwards_Ack ok")
                        AwardsListMgr.show(SceneMgr.getRunningScene, itemVec)
                        AnimationMgr.removeGafObjectByTag(resName[3], boxTag)
                        CSResourceMgr.setButtonEnabledByNode(button, false)
                        ActivityPublicjMgr.setBoxStatus(info.per, true)
                    end, function(code)
                        TipsMgr.showError(nil, code)
                    end)
                else                    
                    DropInfoViewMgr.show(itemVec)
        	    end
        	end, 1)
            CSResourceMgr.setButtonEnabledByNode(button, not haveGot)
            if currentPercent>=info.per and not haveGot then
                local ani = AnimationMgr.createAni(button, resName[3], 40, 40, boxTag)
                ani:setScale(0.15)
                ani:setLocalZOrder(-1)
                AnimationMgr.playAni(resName[3], "animation", true, boxTag)
            end
        	transition.scaleTo(parent, {scale=1, time=0.1})
        end)
    end
    
    UnblockLoader.load(funcTable, tag[1])
end

function ActivityPublicjMgr.hideLuotianyi()
    UnblockLoader.cancel(tag[1])
    CSResourceMgr.removeCSObjectByTag(resNameBG, tag[1])
    CSResourceMgr.removeCSObjectByTag(resName[1])
    UIStack.pop(tag[1])
end

function ActivityPublicjMgr.showLuotianyiRank(scene)
    UIStack.push(tag[2], ActivityPublicjMgr.hideLuotianyiRank, false)
    
    CSResourceMgr.getCsbObj(resName[1]):hide()
    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, resName[2])
        layer:zorder(CocosModuleMgr.ZORDER_WINDOW)
        layer:hide()
        
        local diff = CocosModuleMgr.getScreenSizeDiff()
        local frame = CSResourceMgr.getNodeByName(resName[2], "bg3")
        local fsize = frame:getContentSize()
        frame:setContentSize(fsize.width, fsize.height+diff)
        local title = CSResourceMgr.getNodeByName(resName[2], "titlediban")
        local tposy = title:getPositionY()
        title:setPositionY(tposy+diff)
        local line = CSResourceMgr.getNodeByName(resName[2], "player_info")
        local lposy = line:getPositionY()
        line:setPositionY(lposy+diff)
        local list = CSResourceMgr.getNodeByName(resName[2], "list")
        local lsize = list:getContentSize()
        list:setContentSize(lsize.width, lsize.height+diff)
        
        CSResourceMgr.clickEventBinding(resName[2], "close", function()
            ActivityPublicjMgr.hideLuotianyiRank()
        end)
        local labelTitle = CSResourceMgr.getNodeByName(resName[2], "title1")
        CSResourceMgr.setLabelStringByNode(labelTitle, "arena28", {r=221,g=82,b=26,a=255,w=2}, nil, 240)
        ActivityPublicjMgr.refreshRankPlayerSelfInfo()
        
        local function getRankCell(info)
            local parent = CSResourceMgr.getNodeByName(resName[2], "btn_item"):clone()
            local btnDir = CSResourceMgr.seekNodeByName(parent, "btn_info")
            local button = parent
            if info == nil or PetEducationMgr.getTableLength(info) <= 0 then return parent end
            ActivityPublicjMgr.setSingleRankItem(parent, info)

            if info.rank>=1 and info.rank<=5 then
                CSResourceMgr.setButtonTextureByNode(btnDir, ArenaViewMgr.DirIconPath[1], 
                    ArenaViewMgr.DirIconPath[1], ArenaViewMgr.DirIconPath[1])
            end
            parent:setCascadeOpacityEnabled(true)
            return parent
        end

        local requestRankProcess = 1
        local showSize = 10
        local rankListObj = nil
        rankListObj = CSResourceMgr.setCommonListInfo(rankInfo, resName[2], "list", "", showSize, nil, function(id, var)
            local cellNode = getRankCell(var)
            cellNode:setVisible(true)
            list:pushBackCustomItem(cellNode)
            cellNode:setScaleY(0)
            transition.scaleTo(cellNode, {scaleY = 1, time = 0.1})
            return cellNode
        end, function(callback)
            local function completeFunc()
                requestRankProcess = 1+showSize
                callback()
            end
            if CharInfo.getServerTime()>refreshRankTime then
                NetInterface.send("GC_GetPlayerPointRank_Ack", function()
                    rankInfo = {}
                    refreshRankTime = CharInfo.getServerTime()+ArenaInfo.REQUEST_TIMEDIFF
                    local LoginSend = require("src.Net.Send.LoginSend")
                    LoginSend.sendCG_GetPlayerPointRank_Req({rankMin=1, rankMax=showSize+1})
                end, function()
                    if rankListObj then
                        rankListObj.setContent(rankInfo)
                    end
                    completeFunc()
                end, function()
                    StandardTipsMgr.show(1, "arena29")
                end)
            else
                completeFunc()
                TipsMgr.show(scene, "activity12")
            end
        end, function(callback)
            if requestRankProcess>100 then
                callback()
                return
            end
            local function completeFunc()
                requestRankProcess = requestRankProcess+showSize
                callback()
            end
            if rankInfo[requestRankProcess] then
                completeFunc()
            else
                NetInterface.send("GC_GetPlayerPointRank_Ack", function()
                    local LoginSend = require("src.Net.Send.LoginSend")
                    LoginSend.sendCG_GetPlayerPointRank_Req({rankMin=requestRankProcess, rankMax=requestRankProcess+showSize})
                end, function()
                    if rankListObj then
                        rankListObj.setContent(rankInfo)
                    end
                    completeFunc()
                end, function()
                    StandardTipsMgr.show(1, "arena29")
                end)
            end
        end)
    end
    
    local function playCSB()
        local layer = CSResourceMgr.getCsbObj(resName[2])
        layer:show()
        CocosModuleMgr.showUIAnimation(layer, "down")
    end
    
    local funcTable = {loadCSB, playCSB}
    UnblockLoader.load(funcTable, tag[2])
end

function ActivityPublicjMgr.hideLuotianyiRank()
    CSResourceMgr.getCsbObj(resName[1]):show()
    UnblockLoader.cancel(tag[2])
    CSResourceMgr.removeList(resName[2], "list")
    CSResourceMgr.removeCSObjectByTag(resName[2])
    UIStack.pop(tag[2])
end

function ActivityPublicjMgr.setSingleRankItem(node, info)    
    local rankNum = info.rank
    local faimly = info.playerInfo.familyName
    local diban = CSResourceMgr.seekNodeByName(node, "player_diban")
    local bg11 = CSResourceMgr.seekNodeByName(node, "bg11")
    local bg21 = CSResourceMgr.seekNodeByName(node, "bg21")
    local bg14 = CSResourceMgr.seekNodeByName(node, "bg14")
    local fmbg = CSResourceMgr.seekNodeByName(node, "family_bg")
    local rankTex = CSResourceMgr.seekNodeByName(node, "rank_num_sprite")
    local rankLab = CSResourceMgr.seekNodeByName(node, "rank_num_label")
    local playerIcon = CSResourceMgr.seekNodeByName(node, "player_icon")
    local spriteVip = CSResourceMgr.seekNodeByName(node, "bg13")
    local vip = CSResourceMgr.seekNodeByName(node, "player_vip")
    local playerLv = CSResourceMgr.seekNodeByName(node, "player_level")
    local playerName = CSResourceMgr.seekNodeByName(node, "player_name")
    local fc = CSResourceMgr.seekNodeByName(node, "fc")
    local familyNode = CSResourceMgr.seekNodeByName(node, "family")
    local familyName = CSResourceMgr.seekNodeByName(node, "family_name")

    if rankNum <= 3 then
        rankLab:setVisible(false)
        CSResourceMgr.setSpriteTextureByNode(rankTex, ArenaViewMgr.PlayerRankNumTex[rankNum])
    else
        rankTex:setVisible(false)
        CSResourceMgr.setLabelStringByNode(rankLab, rankNum, outlineColor[3])
        CSResourceMgr.setLabelColorByNode(rankLab, labelColor[3])
    end

    if rankNum > 3 then rankNum = 4 end
    CSResourceMgr.setSpriteTextureByNode(playerIcon, CharInfo.getHeadIcon(info.playerInfo.fashion))
    CSResourceMgr.setSpriteTextureByNode(diban, ArenaViewMgr.PlayerRankBackgroudTex[rankNum])
    bg11:setColor(ArenaViewMgr.BGTexColor1[rankNum])
    bg21:setColor(ArenaViewMgr.BGTexColor2[rankNum])
    bg14:setColor(ArenaViewMgr.BGTexColor3[rankNum])
    fmbg:setColor(ArenaViewMgr.BGTexColor2[rankNum])
    local vipLv = CharInfo.getVipInfoByID(info.playerInfo.vipLevel).viplevel
    CSResourceMgr.setLabelStringByNode(vip, vipLv, outlineColor[2])
    CSResourceMgr.setLabelStringByNode(playerLv, "Lv."..info.playerInfo.Level)
    CSResourceMgr.setLabelStringByNode(playerName, info.playerInfo.nickname, outlineColor[2], nil, 198)
    CSResourceMgr.setLabelStringByNode(fc, info.point, outlineColor[2], nil, 112)

    CSResourceMgr.setLabelColorByNode(vip, labelColor[2])
    CSResourceMgr.setLabelColorByNode(playerLv, ArenaViewMgr.PlayerLvColor[rankNum])
    spriteVip:setVisible(vipLv ~= 0)
    vip:setVisible(vipLv ~= 0)
    playerIcon:setScale(1)
    playerIcon:setPositionY(66)
    if faimly then
        CSResourceMgr.setLabelStringByNode(familyName, faimly, outlineColor[2], nil, 124)
    else
        familyNode:setVisible(false)
    end
end

function ActivityPublicjMgr.refreshRankPlayerSelfInfo()
    local panel1     = CSResourceMgr.getNodeByName(resName[2], "panel_1")
    local labelName  = CSResourceMgr.seekNodeByName(panel1, "char_name")
    local spriteVip  = CSResourceMgr.seekNodeByName(panel1, "vip_title")
    local labelVip   = CSResourceMgr.seekNodeByName(panel1, "vip_level")
    local labelLv    = CSResourceMgr.seekNodeByName(panel1, "char_level")
    local labelTitle = CSResourceMgr.seekNodeByName(panel1, "rank_title")
    local labelRank  = CSResourceMgr.seekNodeByName(panel1, "rank_num")
    local labelPoint  = CSResourceMgr.seekNodeByName(panel1, "jf_num")
    local spriteIcon = CSResourceMgr.seekNodeByName(panel1, "char_icon")

    local vipLv = CharInfo.getVipInfoByID(CharInfo.getVIPLevel()).viplevel
    spriteVip:setVisible(vipLv ~= 0)
    labelVip:setVisible(vipLv ~= 0)

    CSResourceMgr.setLabelStringByNode(labelName, CharInfo.getNickName(), outlineColor[3], nil, 161)
    CSResourceMgr.setLabelStringByNode(labelVip, vipLv, outlineColor[3])
    CSResourceMgr.setLabelStringByNode(labelLv, "Lv."..CharInfo.getLevel(), outlineColor[3])
    CSResourceMgr.setLabelStringByNode(labelTitle, "arena7", outlineColor[2], nil, 160)
    local rankStr = myRank
    if myRank==0 then
        rankStr = "stageboss6"
    end
    CSResourceMgr.setLabelStringByNode(labelRank, rankStr, outlineColor[1], nil, 138)
    CSResourceMgr.setLabelStringByNode(labelPoint, myPoint, outlineColor[1], nil, 200)    

    CSResourceMgr.setLabelColorByNode(labelName,  labelColor[2])
    CSResourceMgr.setLabelColorByNode(labelVip,   labelColor[2])
    CSResourceMgr.setLabelColorByNode(labelTitle, labelColor[3])

    CSResourceMgr.setSpriteTextureByNode(spriteIcon, CharInfo.getHeadIcon(CharInfo.getCurfashion()))
    spriteIcon:setScale(1.5)
    spriteIcon:setPositionY(69)
end

function ActivityPublicjMgr.setLuotianyiRankInfo(vec)
    local cjson = require("cjson")
    local tmpVec = {}
    for var=1, #vec do
        local j = cjson.decode(vec[var])
        table.insert(tmpVec, j)
    end
    table.sort(tmpVec, function(a, b)
    	return a.point>b.point
    end)
    for var=1, #tmpVec do
        tmpVec[var].rank = #rankInfo+1
        table.insert(rankInfo, tmpVec[var])
    end
end

function ActivityPublicjMgr.setMyRankInfo(point, rank)
    myPoint = point
	myRank = rank
end

function ActivityPublicjMgr.getBoxStatus(index)
    local acvtInfo = CharInfo.get().activity.spokesmanGuess
    local haveGot = false
    if acvtInfo then
        local getVec = acvtInfo[ActivityPublicjMgr.LUOTIANYI_TYPE..""] or {}
        haveGot = getVec[(index-1)..""]
    end
    return haveGot
end

function ActivityPublicjMgr.setBoxStatus(index, val)
    local acvtVec = CharInfo.get().activity
    acvtVec.spokesmanGuess = acvtVec.spokesmanGuess or {}
    acvtVec.spokesmanGuess[ActivityPublicjMgr.LUOTIANYI_TYPE..""] = acvtVec.spokesmanGuess[ActivityPublicjMgr.LUOTIANYI_TYPE..""] or {}
    acvtVec.spokesmanGuess[ActivityPublicjMgr.LUOTIANYI_TYPE..""][(index-1)..""] = val
end

return ActivityPublicjMgr