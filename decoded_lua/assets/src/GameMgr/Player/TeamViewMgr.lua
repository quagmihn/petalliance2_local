local TeamViewMgr = {}

TeamViewMgr.DEFAULT_UI_HEIGHT = 700
TeamViewMgr.DEFAULT_AWARD_SIZE = 4
TeamViewMgr.TEAM_PLAYER_NUM = 3
TeamViewMgr.TEAM_PETLIST_RANK = 4

local resName = ""
local preResName = ""
local petResName = ""
local topResName = ""
local bgResName = ""
local curTab = 1
local curChatStatus = nil
local curIndex = 1
local resizeCSB = nil
local setTopBar = nil
local checkTab = nil
local refreshPet = nil
local advInfoVec = {}
local memberNodes = {}
local memberNodesPosx = {}
local memberAni = {}
local petListNodes = {}
local selPetIndex = {}
local curPetObjID = nil
local canChangeAid = true
local treasureBoxNodes = {}
local treasureBoxVipLock = nil
local chestLabelTbl = {}

local TeamSend = nil

local tag = "TeamViewMgr"

function TeamViewMgr.Init()
	resName = "Player/Team/TeamMain.csb"
    preResName = "Player/Team/TeamPrepare.csb"
    petResName = "Player/Team/TeamSelPet.csb"
    topResName = "Player/Team/TeamTopBar.csb"
    bgResName = "Pet/Formation/FormationBGNew.csb"
    curTab = 1
    curChatStatus = nil
    curIndex = 1
    resizeCSB = nil
    setTopBar = nil
    checkTab = nil
    refreshPet = nil
    advInfoVec = {}
    memberNodes = {}
    memberNodesPosx = {}
    memberAni = {}
    petListNodes = {}
    selPetIndex = {}
    curPetObjID = nil
    canChangeAid = true
    treasureBoxNodes = {}
    if treasureBoxVipLock==nil then
    	treasureBoxVipLock = SystemInfo.getGlobalConfigAddInfoByID(71).values
    end
    chestLabelTbl = {}
    
    TeamSend = require("src.Net.Send.TeamSend")
end

function TeamViewMgr.show(scene, aID, tab)
    if CSResourceMgr.getCsbObj(topResName) then
        if aID then
            local findIndex = nil
            for key, var in pairs(advInfoVec) do
                if var.aid==aID then
                    findIndex = key
                    break
                end
            end
            if findIndex then
                setTopBar(findIndex)
            end
        end
    	return
    end
    local eInfoVec = WorldMapInfo.getTeamMapInfo()
    advInfoVec = {}
    local pathStr = PetExploreMgr.ICON_PATH
    for key, var in pairs(eInfoVec) do
        local curNum, totalNum = TeamInfo.getLockInfo(key)
        var.curNum = curNum
        var.totalNum = totalNum
        var.worldMapName = WorldMapInfo.getWorldMapInfoByID(key).name
        var.worldMapID = key
        table.insert(advInfoVec, var)
    end
    if #advInfoVec==0 then
        StandardTipsMgr.show(1, "team25")
    	return
    end
    
    --[[
    if not TEAM_OPEN_MODE then
        StandardTipsMgr.show(1, "team24")
        return
    end]]
    UIStack.closeAllUI()
    UIStack.push(tag, function()
        if TeamInfo.getInfo(TeamInfo.KEY_TEAMID) then
            DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, "team34", function()
                TeamViewMgr.hide()
                NetInterface.sendWithBlock("GC_CancelAutoJoinTeam_Ack", function()
                    TeamSend.sendCG_CancelAutoJoinTeam_Req({adventureID=advInfoVec[curIndex].aid})
                end, function()
                    TeamInfo.exitTeam()
                end, function(code)
                    TeamInfo.exitTeam()
                end)                
    		end)
    	else
    	    TeamViewMgr.hide()
    	end
    end, true)
    
    memberNodes = {}
    memberAni = {}
    petListNodes = {}
    treasureBoxNodes = {}
    curChatStatus = nil
    checkTab = nil
    chestLabelTbl = {}
    
    TreasureBoxInfo.GetTreasureBoxData(TeamViewMgr.refreshTreasureBox)
    
    local function loadCSB()
        local layerBG = CSResourceMgr.createRes(scene, bgResName, tag)
        layerBG:zorder(CocosModuleMgr.ZORDER_MAP_FRONT)
        CocosModuleMgr.setRelativePosition(layerBG, 320, 480)
        local layerTop = CSResourceMgr.createRes(scene, topResName)
        layerTop:zorder(CocosModuleMgr.ZORDER_BAR)
        CocosModuleMgr.setRelativePosition(layerTop, 320, 480)
        CocosModuleMgr.setEdgeDistance(layerTop, nil, nil, 0, nil)
        layerTop:hide()
        
        resizeCSB =  function(csbRes)
            local cobj = CSResourceMgr.getCsbObj(csbRes)
            local diffY = cobj:getContentSize().height/2
            local posy = cobj:getPositionY()
            local screenDiff = CocosModuleMgr.getScreenSizeDiff()-1136+960
            if screenDiff>0 then
            	screenDiff = 0
            end
            local chatDiff, edgeDiff = TownChatMgr.getScreenSizeDiff()
            local rate = (TeamViewMgr.DEFAULT_UI_HEIGHT+screenDiff-chatDiff)/TeamViewMgr.DEFAULT_UI_HEIGHT
            cobj:scale(rate)
            cobj:setPositionY(posy+diffY)
            cobj:setAnchorPoint(0.5, 1)
        end
        
        CSResourceMgr.setButtonString(topResName, "drop", "team1", "", {r=0,g=0,b=0,a=255,w=1,s=1})
        CSResourceMgr.clickEventBinding(topResName, "drop", function()
            --掉落信息
            local curAdvId = advInfoVec[curIndex].aid
            TeamDropMgr.showDrop(curAdvId)
            --TeamDropMgr.show(scene, curAdvId)
        end, "", nil, "ok")
        
        setTopBar = function(idx)
            local curAdvId = advInfoVec[idx].aid
            local tInfo = TeamMapInfo.getTeamFloorInfoById(curAdvId)
            CSResourceMgr.setSpriteTexture(topResName, "icon", advInfoVec[idx].icon)
            CSResourceMgr.setLabelColor(topResName, "title", {r=255,g=252,b=0,a=255})
            CSResourceMgr.setLabelString(topResName, "title", CocosModuleMgr.createStringWithFormat({"<1>  Lv<2>-Lv<3>",
                advInfoVec[idx].name, tInfo.enterMinLevel, tInfo.enterMaxLevel}), "", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 400)
        end
        if aID then
            canChangeAid = false
            local findIndex = nil
            for key, var in pairs(advInfoVec) do
                if var.aid==aID then
                    findIndex = key
        			break
        		end
        	end
            if findIndex then
                curIndex = findIndex
            end
        else
            canChangeAid = true
        end
        setTopBar(curIndex)
    end
    
    local function playCSB()
    	CSResourceMgr.getCsbObj(topResName):show()
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(topResName), "down")
    end
    
    checkTab = function(idx)
        print("TeamViewMgr showTab", idx)
        curTab = idx
    	if idx==1 then
            TeamViewMgr.setTabA(true)
            TeamViewMgr.setTabB(false)
            TeamViewMgr.setTabC(false)
            CSResourceMgr.getNodeByName(topResName, "bar1"):show()
            CSResourceMgr.getNodeByName(topResName, "bar2"):hide()
            CSResourceMgr.getCsbObj(topResName):show()
            CSResourceMgr.clickEventBinding(topResName, "close", function()
                TeamViewMgr.hide()
            end)
        elseif idx==2 then
            TeamViewMgr.setTabA(false)
            TeamViewMgr.setTabB(true)
            TeamViewMgr.setTabC(false)
            CSResourceMgr.getNodeByName(topResName, "bar1"):hide()
            CSResourceMgr.getNodeByName(topResName, "bar2"):show()
            CSResourceMgr.getCsbObj(topResName):show()
            CSResourceMgr.clickEventBinding(topResName, "close", function()
                DialogBoxMgr.showSmallDialogBox(nil, 2, "team34", function()
                    TeamInfo.exitTeam(function()
                        checkTab(1)
                    end)
                end)
            end)
        elseif idx==3 then
            TeamViewMgr.setTabA(false)
            TeamViewMgr.setTabB(false)
            TeamViewMgr.setTabC(true)
            CSResourceMgr.getNodeByName(topResName, "bar1"):hide()
            CSResourceMgr.getNodeByName(topResName, "bar2"):hide()
            CSResourceMgr.getCsbObj(topResName):hide()
    	end
    end
    
    local funcTable = {loadCSB, playCSB, function()
        TeamViewMgr.setChatUI(true)
    end, function()
        tab = tab or curTab
        if not TeamInfo.getInfo(TeamInfo.KEY_TEAMID) then
        	tab = 1
        end
    	checkTab(tab or 1)
    end}    
    UnblockLoader.load(funcTable, tag)
end

function TeamViewMgr.checkTab(tabIndex)
    if not CSResourceMgr.getCsbObj(topResName) then
        return
    end
	checkTab(tabIndex)
end

function TeamViewMgr.setTabA(boolVisible)
	local curNode = CSResourceMgr.getCsbObj(resName)
    local function showAni(layer)
        transition.stopTarget(layer)
        CocosModuleMgr.setRelativePosition(layer, 320, 480)
        CocosModuleMgr.setEdgeDistance(layer, nil, nil, 0, nil)
        CocosModuleMgr.showUIAnimation(layer, "down")
    end
    if curNode then
        curNode:setVisible(boolVisible)
        if boolVisible then
            showAni(curNode)
        end
    else
        if not boolVisible then
        	return
        end
        local function loadCSB()
            local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, resName)
            layer:zorder(CocosModuleMgr.ZORDER_MAP_FRONT)
            layer:hide()
            resizeCSB(resName)

            local isAutoJoining = false
            CSResourceMgr.setLabelColor(resName, "waitstr", {r=166,g=243,b=255,a=255})
            CSResourceMgr.setLabelString(resName, "waitstr", "team8", "", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 400)
            CSResourceMgr.setButtonString(resName, "cancel", "team12", "", {r=0,g=0,b=0,a=255,w=1,s=1})
            local boxname = CSResourceMgr.getNodeByName(resName, "boxname")
            boxname:removeFromParent(false)
            boxname:addTo(CSResourceMgr.getNodeByName(resName, "award"))
            boxname:pos(75, -12)
            CSResourceMgr.clickEventBinding(resName, "cancel", function()
                --取消匹配
                local function cancelFunc()
                    CSResourceMgr.getNodeByName(resName, "state1"):show()
                    CSResourceMgr.getNodeByName(resName, "state2"):hide()
                    CSResourceMgr.getCsbObj(topResName):show()
                    CSResourceMgr.setButtonEnabled(resName, "left", true)
                    CSResourceMgr.setButtonEnabled(resName, "right", true)
                    transition.stopTarget(CSResourceMgr.getNodeByName(resName, "waitsec"))
                    if TeamInfo.getInfo(TeamInfo.KEY_TEAMID)==-1 then
                        TeamInfo.setInfo(TeamInfo.KEY_TEAMID, nil)
                    end
                end
                if isAutoJoining then
                    NetInterface.sendWithBlock("GC_CancelAutoJoinTeam_Ack", function()
                        TeamSend.sendCG_CancelAutoJoinTeam_Req({adventureID=advInfoVec[curIndex].aid})
                    end, function()
                        cancelFunc()
                    end, function(code)
                        TipsMgr.showError(nil, code)
                        cancelFunc()
                    end)
                else
                    cancelFunc()
                end
                isAutoJoining = false
            end, "", nil, "error")
            CSResourceMgr.setLabelString(resName, "waitsec", "", "", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 400)
            CSResourceMgr.setButtonString(resName, "create", "team2", "", {r=0,g=0,b=0,a=255,w=1,s=1})
            CSResourceMgr.clickEventBinding(resName, "create", function()
                --创建队伍
                local function createTeam()
                    NetInterface.sendWithBlock("GC_CreateTeam_Ack", function()
                        TeamSend.sendCG_CreateTeam_Req({adventureID=advInfoVec[curIndex].aid, canAutoJoin=0})
                    end, function()
                        TeamInfo.receiveTeamJoinNtf(nil, function()
                            checkTab(2)
                        end)
                    end, function(code)
                        TipsMgr.showError(nil, code)
                    end)
                end
                TeamInfo.exitTeam(createTeam)
            end, "", nil, "raidEnter")
            CSResourceMgr.setButtonString(resName, "auto", "team3", "", {r=0,g=0,b=0,a=255,w=1,s=1})
            CSResourceMgr.clickEventBinding(resName, "auto", function()
                --自动匹配
                local function autoJoin()
                    isAutoJoining = true
                    TeamInfo.setInfo(TeamInfo.KEY_TEAMID, -1)
                    NetInterface.sendWithBlock("GC_AutoJoinTeam_Ack", function()
                        TeamSend.sendCG_AutoJoinTeam_Req({adventureID=advInfoVec[curIndex].aid, leaderID=0})
                    end, function()
                        if not CSResourceMgr.getCsbObj(resName) then
                        	return
                        end
                        CSResourceMgr.getNodeByName(resName, "state1"):hide()
                        CSResourceMgr.getNodeByName(resName, "state2"):show()
                        local function wait(second)
                            local time = second+1
                            CSResourceMgr.setLabelString(resName, "waitsec", CocosModuleMgr.createStringWithFormat({"team18", second}))
                            if second>=300 then
                                --匹配超时
                                StandardTipsMgr.show(1, "team32")
                                CSResourceMgr.callButtonFunc(resName, "cancel")
                                return
                            end
                            CSResourceMgr.getNodeByName(resName, "waitsec"):performWithDelay(function()
                                wait(time)
                            end, 1)
                        end
                        wait(0)
                        CSResourceMgr.getCsbObj(topResName):hide()
                        CSResourceMgr.setButtonEnabled(resName, "left", false)
                        CSResourceMgr.setButtonEnabled(resName, "right", false)
                    end, function(code)
                        TipsMgr.showError(nil, code)
                    end)
                end
                TeamInfo.exitTeam(function()
                    NetInterface.sendWithBlock("GC_CancelAutoJoinTeam_Ack", function()
                        TeamSend.sendCG_CancelAutoJoinTeam_Req({adventureID=advInfoVec[curIndex].aid})
                    end, function()
                        autoJoin()
                    end, function(code)
                        autoJoin()
                    end)
                end)
            end, "", nil, "raidEnter")
        end

        local function setCSB()
            local function setMap(idx)
                curIndex = idx
                if idx==1 then
                    CSResourceMgr.getNodeByName(resName, "left"):hide()
                else
                    CSResourceMgr.getNodeByName(resName, "left"):show()
                end
                if idx==#advInfoVec then
                    CSResourceMgr.getNodeByName(resName, "right"):hide()
                else
                    CSResourceMgr.getNodeByName(resName, "right"):show()
                end
                local curAdvId = advInfoVec[idx].aid
                local tInfo = TeamMapInfo.getTeamFloorInfoById(curAdvId)
                CSResourceMgr.setLabelString(resName, "level", "Lv"..tInfo.enterMinLevel.."-Lv"..tInfo.enterMaxLevel, "", 
                    {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 300)
                CSResourceMgr.setLabelColor(resName, "title", {r=255,g=252,b=0,a=255})
                CSResourceMgr.setLabelString(resName, "title", advInfoVec[idx].name, "", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 300)
                --CSResourceMgr.setSpriteTexture(resName, "icon", advInfoVec[idx].icon)
                local iconNode = CSResourceMgr.getNodeByName(resName, "icon")
                iconNode:removeAllChildren()
                local iconAni = AnimationMgr.createAni(iconNode, WorldMapInfo.getTeamSpineAniRes(advInfoVec[idx].worldMapID), 0, 0, tag)
                AnimationMgr.playAni(iconAni.res, "animation", true, iconAni.tag)
                CSResourceMgr.getNodeByName(resName, "locknode"):show()
                CSResourceMgr.setLabelString(resName, "locktitle", "team51", "", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 200)
                CSResourceMgr.setLabelString(resName, "lockmap", advInfoVec[idx].worldMapName, "", 
                    {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 120)
                CSResourceMgr.setLabelString(resName, "locknum", advInfoVec[idx].curNum.."/"..advInfoVec[idx].totalNum, "",
                    {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 100)
                if CharInfo.getLevel()<tInfo.enterMinLevel or CharInfo.getLevel()>tInfo.enterMaxLevel then
                    CSResourceMgr.setLabelColor(resName, "level", {r=255,g=0,b=0,a=255})
                else
                    CSResourceMgr.setLabelColor(resName, "level", {r=255,g=252,b=0,a=255})
                end
                if advInfoVec[idx].curNum<advInfoVec[idx].totalNum then
                    CSResourceMgr.setButtonEnabled(resName, "create", false)
                    CSResourceMgr.setButtonEnabled(resName, "auto", false)
                elseif CharInfo.getLevel()<tInfo.enterMinLevel or CharInfo.getLevel()>tInfo.enterMaxLevel then
                    CSResourceMgr.setButtonEnabled(resName, "create", false)
                    CSResourceMgr.setButtonEnabled(resName, "auto", false)
                else
                    CSResourceMgr.setButtonEnabled(resName, "create", true)
                    CSResourceMgr.setButtonEnabled(resName, "auto", true)
                end
                setTopBar(idx)
            end
            CSResourceMgr.clickEventBinding(resName, "left", function()
                setMap(curIndex-1)
            end, nil, 1, "petchange")
            CSResourceMgr.clickEventBinding(resName, "right", function()
                setMap(curIndex+1)
            end, nil, 1, "petchange")
            setMap(curIndex)
            if not canChangeAid then
                CSResourceMgr.getNodeByName(resName, "left"):hide()
                CSResourceMgr.getNodeByName(resName, "right"):hide()
            end
        end

        local function playCSB()
            CSResourceMgr.getCsbObj(resName):setVisible(curTab==1)
            showAni(CSResourceMgr.getCsbObj(resName))
        end

        local funcTable = {loadCSB, setCSB, playCSB, TeamViewMgr.refreshTreasureBox}

        UnblockLoader.load(funcTable, tag.."A")
    end
end

function TeamViewMgr.setTabB(boolVisible)
    local curNode = CSResourceMgr.getCsbObj(preResName)
    local function showAni(layer)
        transition.stopTarget(layer)
        CocosModuleMgr.setRelativePosition(layer, 320, 480)
        CocosModuleMgr.setEdgeDistance(layer, nil, nil, 0, nil)
        CocosModuleMgr.showUIAnimation(layer, "down")
    end
    if curNode then
        curNode:setVisible(boolVisible)
        if boolVisible then
            TeamViewMgr.refreshTeamMain()
            showAni(curNode)
        end
    else
        if not boolVisible then
            return
        end
        local function loadCSB()
            local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, preResName)
            layer:zorder(CocosModuleMgr.ZORDER_MAP_FRONT)
            layer:hide()
            resizeCSB(preResName)
            CSResourceMgr.getNodeByName(preResName, "start"):hide()
        end

        local function playCSB()
            CSResourceMgr.getCsbObj(preResName):setVisible(curTab==2)
            showAni(CSResourceMgr.getCsbObj(preResName))
        end
        
        local funcTable = {loadCSB, playCSB}
        --初始化宠物
        local petTab = {}
        local petNodes = {}
        table.insert(funcTable, function()
            table.insert(petTab, CSResourceMgr.getNodeByName(preResName, "petdb"))
            local parent = petTab[1]:clone()
            parent:addTo(CSResourceMgr.getCsbObj(preResName))
            parent:setPositionX(480)
            table.insert(petTab, parent)
            local titleVec = {"train107", "train108"}
            for var=1, #petTab do
                local node = petTab[var]
                local ptitle = CSResourceMgr.seekNodeByName(node, "ptitle")
                CSResourceMgr.setLabelStringByNode(ptitle, titleVec[var], nil, nil, 70)
                CSResourceMgr.setLabelColorByNode(ptitle, {r=108,g=122,b=144,a=255})
                node:show()
                node:setScaleY(0)
                transition.scaleTo(node, {scale=1, time=0.1})
                petNodes[var] = {}
            end
        end)
        local selPet = TeamInfo.getSelPet()
        local selPetNodes = {{}, {}}
        function refreshPet(tabIndex, petIndex)
            local parent = petNodes[tabIndex][petIndex]
            if not parent then
            	return
            end
            local petObjID = TeamInfo.getSelPet()[tabIndex][petIndex]
            local add = CSResourceMgr.seekNodeByName(parent, "add")
            local lock = CSResourceMgr.seekNodeByName(parent, "lock")
            local lockinfo = CSResourceMgr.seekNodeByName(parent, "lockinfo")
            local function checkCanChangePet()
                local info = TeamInfo.getInfo(TeamInfo.KEY_MEMBER)
                for var=1, TeamViewMgr.TEAM_PLAYER_NUM do
                    local inf = info[var]
                    if inf then
                        if inf.charID==CharInfo.getCharID() and inf.isReady==true then
                            return false
                        end
                    end
                end
                return true
            end
            CSResourceMgr.clickEventBindingByNode(add, function()
                if not checkCanChangePet() then
                    StandardTipsMgr.show(1, "team23")
                    return
                end
                selPetIndex = {tabIndex, petIndex}
            	checkTab(3)
            end, 1)
            --print("refreshPet", petObjID, tabIndex, petIndex)
            if selPetNodes[tabIndex][petIndex] then
                selPetNodes[tabIndex][petIndex]:removeFromParent(true)
                selPetNodes[tabIndex][petIndex] = nil
            end
            if petObjID then
        		add:hide()
        		lock:hide()
        		lockinfo:hide()
                local petInfo = PokemonInfo.getPetInfoByObjID(petObjID)
                local nodeStruct = PetListMgr.createPetNode(petInfo, tag..tabIndex..petIndex)
                nodeStruct.node:addTo(parent)
                CSResourceMgr.clickEventBindingByNode(nodeStruct.button, function()
                    if not checkCanChangePet() then
                        StandardTipsMgr.show(1, "team23")
                        return
                    end
                    selPetIndex = {tabIndex, petIndex}
                    checkTab(3)
                end, 3)
                
                selPetNodes[tabIndex][petIndex] = nodeStruct.node
        	else
        	    local lockData = {{nil, nil, 9001}, {9002, 9003, 9004}}
        	    local lockID = lockData[tabIndex][petIndex]
                if lockID then
                    local lockLevel = SystemInfo.getGlobalConfigAddInfoByID(lockID).values[1]
                    if CharInfo.getLevel()>=lockLevel then
                    	add:show()
                        lock:hide()
                        lockinfo:hide()
                    else
                        add:hide()
                        lock:show()
                        lockinfo:show()
                        CSResourceMgr.setLabelColorByNode(lockinfo, {r=144,g=161,b=176,a=255})
                        local lStr = string.gsub(CocosModuleMgr.createStringWithFormat({"train51", lockLevel}), "Lv", "\nLv")
                        CSResourceMgr.setLabelStringByNode(lockinfo, lStr, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 90)
                    end
                else
                    add:show()
                    lock:hide()
                    lockinfo:hide()
        	    end
        	end
        end
        for var=1, PetFormationMgr.MAX_PET_NUM do
        	table.insert(funcTable, function()
                local parent = nil
                if var==1 then
                    parent = CSResourceMgr.seekNodeByName(petTab[1], "pdb")
                else
                    parent = CSResourceMgr.getNodeByName(preResName, "pdb"):clone()
                    parent:addTo(petTab[1])
                    local posx = parent:getPositionX()
                    local diff = parent:getParent():getContentSize().width/2-posx
                    parent:setPositionX(posx+diff*(var-1))
                end
                petNodes[1][var] = parent
                refreshPet(1, var)
                parent:setScale(0)
                parent:show()
                transition.scaleTo(parent, {scale=1, time=0.1})
        	end)
        end
        for var=1, PetFormationMgr.MAX_PET_NUM do
            table.insert(funcTable, function()
                local parent = nil
                if var==1 then
                    parent = CSResourceMgr.seekNodeByName(petTab[2], "pdb")
                else
                    parent = CSResourceMgr.getNodeByName(preResName, "pdb"):clone()
                    parent:addTo(petTab[2])
                    local posx = parent:getPositionX()
                    local diff = parent:getParent():getContentSize().width/2-posx
                    parent:setPositionX(posx+diff*(var-1))
                end
                petNodes[2][var] = parent
                refreshPet(2, var)
                parent:setScale(0)
                parent:show()
                transition.scaleTo(parent, {scale=1, time=0.1})
            end)
        end
        --初始化队员
        for var=1, TeamViewMgr.TEAM_PLAYER_NUM do
            table.insert(funcTable, function()
                local parent = nil
                if var==1 then
                	parent = CSResourceMgr.getNodeByName(preResName, "playerdb")
                else
                    parent = CSResourceMgr.getNodeByName(preResName, "playerdb"):clone()
                    parent:addTo(CSResourceMgr.getCsbObj(preResName))
                    local posx = parent:getPositionX()
                    local diff = parent:getParent():getContentSize().width/2-posx
                    local setPosx = posx+diff*(var-1)
                    parent:setPositionX(setPosx)
                end
                memberNodes[var] = parent
                memberNodesPosx[var] = parent:getPositionX()
                parent:setScaleY(0)
                parent:show()
                transition.scaleTo(parent, {scale=1, time=0.1})
            end)
        end
        
        UnblockLoader.load(funcTable, tag.."B")
        UnblockLoader.addCallback(tag.."B", function()
            TeamViewMgr.refreshTeamMain()
            TeamViewMgr.refreshTeamMemberSort(TeamInfo.getInfo(TeamInfo.KEY_SORT), false)
        end)
        
        --[[
        for var=1, #funcTable do
        	funcTable[var]()
        end
        TeamViewMgr.refreshTeamMain()
        TeamViewMgr.refreshTeamMemberSort(TeamInfo.getInfo(TeamInfo.KEY_SORT), false)
        ]]
    end
end

function TeamViewMgr.setTabC(boolVisible)
    local curNode = CSResourceMgr.getCsbObj(petResName)
    local function showAni(layer)
        transition.stopTarget(layer)
        CocosModuleMgr.setRelativePosition(layer, 320, 480)
        CocosModuleMgr.setEdgeDistance(layer, nil, nil, 0, nil)
        CocosModuleMgr.showUIAnimation(layer, "down")
    end
    local curTeamPets = TeamInfo.getSelPet()
    curPetObjID = nil
    local curTeamPetsObjID = {}
    if curTeamPets and selPetIndex[1] and selPetIndex[2] then
        curPetObjID = curTeamPets[selPetIndex[1]][selPetIndex[2]]
        for key, var in pairs(curTeamPets) do
            for k, v in pairs(var) do
                curTeamPetsObjID[v] = true
            end
        end
    end    
    if curNode then
        curNode:setVisible(boolVisible)
        if boolVisible then
            for key, var in pairs(petListNodes) do
                if curPetObjID==key then
                	var.sel:show()
                	var.str:hide()
                elseif curTeamPetsObjID[key] then
                    var.sel:hide()
                    var.str:show()
            	else
                    var.sel:hide()
                    var.str:hide()
            	end
            end
            showAni(curNode)
        end
    else
        if not boolVisible then
            return
        end
        local function changePet(petID)
            local preTeamPets = clone(curTeamPets)
            if not petID then
                if curTeamPets[selPetIndex[1]][selPetIndex[2]] then
                    table.remove(curTeamPets[selPetIndex[1]], selPetIndex[2])
                end
            else
                if curTeamPets[selPetIndex[1]][selPetIndex[2]] then
                    curTeamPets[selPetIndex[1]][selPetIndex[2]] = curPetObjID
                else
                    table.insert(curTeamPets[selPetIndex[1]], curPetObjID)
                end
            end
            local changeInfo = {}
            for var=1, #curTeamPets do
                for i=1, PetFormationMgr.MAX_PET_NUM do
                    --print("check", var, i, curTeamPets[var][i], preTeamPets[var][i])
                    if curTeamPets[var][i]~=preTeamPets[var][i] then
                        table.insert(changeInfo, {var, i})
                        --print("change", var, i)
            		end
            	end
            end
            for key, var in pairs(changeInfo) do
            	refreshPet(var[1], var[2])
            end
        end
        local function checkPet(petID)
            for var=1, #curTeamPets do
                for i=1, PetFormationMgr.MAX_PET_NUM do
                    if curTeamPets[var][i] then
                        if PokemonInfo.getPetInfoByObjID(petID).pokeID==PokemonInfo.getPetInfoByObjID(curTeamPets[var][i]).pokeID then
                            return false
                        end
                    end                    
                end
            end
            return true
        end
        
        local function loadCSB()
            local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, petResName)
            layer:zorder(CocosModuleMgr.ZORDER_MAP_FRONT)
            CSResourceMgr.setLabelColor(petResName, "title", {r=144,g=238,b=255,a=255})
            CSResourceMgr.setLabelString(petResName, "title", "LtPickTitle", "", {r=0,g=0,b=0,a=255,w=1,s=1})
            CSResourceMgr.setLabelString(petResName, "info", "LtTips1", "", nil, nil, 560)
            CSResourceMgr.setButtonString(petResName, "setoff", "LtPickBtn2", "", {r=0,g=0,b=0,a=255,w=1,s=1})
            CSResourceMgr.setButtonString(petResName, "seton", "LtPickBtn3", "", {r=0,g=0,b=0,a=255,w=1,s=1})
            CSResourceMgr.clickEventBinding(petResName, "setoff", function()
            	--下阵
                changePet(nil)
                checkTab(2)
            end, "", nil, "retract")
            CSResourceMgr.clickEventBinding(petResName, "seton", function()
                --上阵
                if not checkPet(curPetObjID) then
                    StandardTipsMgr.show(1, "tips59")
                	return
                end
                changePet(curPetObjID)
                checkTab(2)
            end, "", nil, "select1")
            CSResourceMgr.clickEventBinding(petResName, "close", function()
                checkTab(2)
            end, "", nil, "retract")
            layer:hide()
            resizeCSB(petResName)
        end

        local function playCSB()
            CSResourceMgr.getCsbObj(petResName):setVisible(curTab==3)
            showAni(CSResourceMgr.getCsbObj(petResName))
        end
        
        local funcTable = {loadCSB, playCSB}
        local allPets = PokemonInfo.getAllPets(nil, true)
        table.sort(allPets, function(a, b)
        	return a.fc>b.fc
        end)
        local rowSize = math.ceil(#allPets/TeamViewMgr.TEAM_PETLIST_RANK)
        local panelVec = {}
        petListNodes = {}
        for var=1, #allPets do
            local row = math.ceil(var/TeamViewMgr.TEAM_PETLIST_RANK)
            local rank = var%TeamViewMgr.TEAM_PETLIST_RANK
            if rank==0 then
                rank = TeamViewMgr.TEAM_PETLIST_RANK
            end
            if rank==1 then
                table.insert(funcTable, function()
                    local parent = CSResourceMgr.getNodeByName(petResName, "example"):clone()
                    CSResourceMgr.getNodeByName(petResName, "list"):pushBackCustomItem(parent)
                    parent:show()
                    parent:setScaleY(0)
                    transition.scaleTo(parent, {scale=1, time=0.1})
                    table.insert(panelVec, parent)
                    local bgimage = CSResourceMgr.seekNodeByName(parent, "bgimage")
                    if row%2==1 then
                        bgimage:setColor({r=52,g=74,b=107})
                    else
                        bgimage:setColor({r=41,g=64,b=87})
                    end
                    bgimage:setOpacity(153)
                    for var=1, TeamViewMgr.TEAM_PETLIST_RANK do
                        local statusStr = CSResourceMgr.seekNodeByName(parent, "str"..var)
                        CSResourceMgr.setLabelColorByNode(statusStr, {r=173,g=255,b=15,a=255})
                        CSResourceMgr.setLabelStringByNode(statusStr, "team29", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 120)
                    end
                end)
            end
            table.insert(funcTable, function()
                local petInfo = allPets[var]
                local returnObjectArray = ObjectPool.getObjectFromPool("PetListUI", 1)
                local object = returnObjectArray[1]
                local button = BattleFuncMgr.createPetCardWithObjectPool(object, petInfo, 3).button
                local size = panelVec[row]:getContentSize()
                button:addTo(panelVec[row])
                button:pos(size.width/2/TeamViewMgr.TEAM_PETLIST_RANK*(rank*2-1), size.height/2)
                button:zorder(1)
                button:scale(0)
                transition.scaleTo(button, {scale=1.4, time=0.1})
                CSResourceMgr.setButtonEnabledByNode(button, false)
                button:performWithDelay(function()
                    CSResourceMgr.setButtonEnabledByNode(button, true)
                    CSResourceMgr.clickEventBindingByNode(button, function()
                        print(petInfo.objID)
                        if PetEducationMgr.isPetYoked(petInfo) then
                            StandardTipsMgr.show(1, "train128")
                            return
                        end
                        if petListNodes[petInfo.objID].str:isVisible()==true then
                            StandardTipsMgr.show(1, "team30")
                        	return
                        end
                        if petListNodes[petInfo.objID].sel:isVisible()==true then
                            return
                        end
                        if curPetObjID then
                            petListNodes[curPetObjID].sel:hide()
                        end
                        petListNodes[petInfo.objID].sel:show()
                        curPetObjID = petInfo.objID
                    end, 3)
                end, 0.5)
                local selSymbol = CSResourceMgr.seekNodeByName(panelVec[row], "gou"..rank)
                local statusStr = CSResourceMgr.seekNodeByName(panelVec[row], "str"..rank)
                selSymbol:zorder(1)
                statusStr:zorder(1)
                local bPosx = button:getPositionX()
                local bPosy = button:getPositionY()
                selSymbol:pos(bPosx+size.width/2/TeamViewMgr.TEAM_PETLIST_RANK-40, bPosy+size.height/2-40)
                statusStr:pos(bPosx+size.width/2/TeamViewMgr.TEAM_PETLIST_RANK-10, bPosy+size.height/2-30)
                if curPetObjID==petInfo.objID then
                	selSymbol:show()
                elseif curTeamPetsObjID[petInfo.objID] then
                    statusStr:show()
                end
                if petInfo.yoke then
                    if petInfo.yoke.bindTo then
                        statusStr:show()
                        CSResourceMgr.setLabelColorByNode(statusStr, {r=255,g=246,b=0,a=255})
                        CSResourceMgr.setLabelStringByNode(statusStr, "train173", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 120)
                    end
                end
                local equiped = button:getChildByName("equiped")
                equiped:setVisible(PetEquipmentMgr.isPetEquiped(petInfo))
                petListNodes[petInfo.objID] = {btn=button, sel=selSymbol, str=statusStr}
            end)
        end
        UnblockLoader.load(funcTable, tag.."C")
    end
end

function TeamViewMgr.hide()
    memberNodes = {}
    memberAni = {}
    petListNodes = {}
    treasureBoxNodes = {}
    UnblockLoader.cancel(tag)
    UnblockLoader.cancel(tag.."A")
    UnblockLoader.cancel(tag.."B")
    UnblockLoader.cancel(tag.."C")
    UnblockLoader.cancel(tag.."R")
    UnblockLoader.cancel(tag.."T")
    TeamViewMgr.setChatUI(false)
    for var=1, TeamViewMgr.TEAM_PLAYER_NUM do
        PlayerAnimeMgr.removePlayerByTag(tag..var)
    end
    CSResourceMgr.removeList(petResName, "list")
    CSResourceMgr.removeCSObjectByTag(resName)
    CSResourceMgr.removeCSObjectByTag(preResName)
    CSResourceMgr.removeCSObjectByTag(petResName)
    CSResourceMgr.removeCSObjectByTag(topResName)
    CSResourceMgr.removeCSObjectByTag(bgResName, tag)
    curChatStatus = nil
    checkTab = nil
    TeamInfo.setInfo(TeamInfo.KEY_SELPET, nil)
    ObjectPool.reset("PetListUI")
    GameGuideMgr.checkProcessInTown()
    UIStack.pop(tag)
end

function TeamViewMgr.refreshTreasureBox()
    if not CSResourceMgr.getCsbObj(resName) then
    	return
    end
    UnblockLoader.cancel(tag.."T")
    TreasureBoxInfo.checkRedPoint()
    BaseFunction.cancelLocalNotificationWithKey(6)
    local TreasureBoxSend = require("src.Net.Send.TreasureBoxSend")
	local funcTable = {}
    local waitTime = {}
    local myBoxData = TreasureBoxInfo.getMyTreasureBoxData()
    local myBuyTimes = TreasureBoxInfo.getTodayBuyTimes()+1
    local imageIcon = {}
    local needTime = {}
    local awardPreIDs = {}
    local mPrice = {}
    local endTime = {}
    local boxName = {}
    if chestLabelTbl then
        for k,v in pairs(chestLabelTbl) do
            v:removeFromParent(true)
        end
    end
    chestLabelTbl = {}
    for key, var in pairs(myBoxData) do
        if var.type then
            local bInfo = TreasureBoxInfo.getTreasureBoxInfoById(var.type)
            imageIcon[key] = bInfo.imagePath
            needTime[key] = bInfo.CD
            awardPreIDs[key] = {bInfo.awards[1]}
            mPrice[key] = bInfo.speedSeconds[myBuyTimes] or bInfo.speedSeconds[#bInfo.speedSeconds]
            endTime[key] = var.time
            boxName[key] = bInfo.name
        end
    end
    local imageBackground = {"UI/CommonFiles/share_formation_selected_su_01.png", 
        "UI/CommonFiles/share_formation_substrate_su_04.png"}
    local boxPosy = {nil, 65, 115, 105}
    for var=1, TeamViewMgr.DEFAULT_AWARD_SIZE do
        table.insert(funcTable, function()
            local parent = treasureBoxNodes[var]
            local showAni = false
            if not parent then
                showAni = true
                parent = CSResourceMgr.getNodeByName(resName, "award"):clone()
                parent:addTo(CSResourceMgr.getNodeByName(resName, "state1"))
                parent:setPositionX(640/TeamViewMgr.DEFAULT_AWARD_SIZE*(var-0.5))
            end
            local vipLock = treasureBoxVipLock[var] or 0

            local button = CSResourceMgr.seekNodeByName(parent, "button")
            local empty = CSResourceMgr.seekNodeByName(parent, "empty")
            local lock = CSResourceMgr.seekNodeByName(parent, "lock")
            local unlock = CSResourceMgr.seekNodeByName(parent, "unlock")
            local open = CSResourceMgr.seekNodeByTag(parent, "open")
            local boxname = CSResourceMgr.seekNodeByName(parent, "boxname")
            if LuaSqlite.LANG_TYPE ~= 1 then
                local chestLabel = display.newTTFLabel({
                font = "cuyuan_GBK.ttf",
                text = "Chest",
                size = 16, 
                color = {r=69,g=165,b=209,a=255}
                })
                chestLabel:addTo(parent)
                chestLabel:setPosition(75,-30)
                chestLabel:enableOutline({r=0,g=0,b=0,a=255},1)
                chestLabel:enableShadow()
                chestLabelTbl[var] = chestLabel
                if imageIcon[var] then
                    chestLabel:setVisible(true)
                else
                    chestLabel:setVisible(false)
                end
            end
            CSResourceMgr.setLabelColorByNode(boxname, {r=69,g=165,b=209,a=255})
            CSResourceMgr.setLabelStringByNode(boxname, boxName[var] or "", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 150)
            local nodeVec = {empty, lock, unlock, open}
            button:scale(1.3)
            button:setPressedActionEnabled(true)
            --状态1:空箱位/状态2:未开启/状态3:可开启/状态4:开启中
            local function setType(index)
                for v=1, #nodeVec do
                    nodeVec[v]:hide()
                end
                nodeVec[index]:show()
                if boxPosy[index] then
                    button:setPositionY(boxPosy[index])
                    button:show()
                else
                    button:hide()
                end
                if index==3 or index==4 then
                    CSResourceMgr.setSpriteTextureByNode(parent, imageBackground[1])
                else
                    CSResourceMgr.setSpriteTextureByNode(parent, imageBackground[2])
                end
                if index==1 then
                    waitTime[var] = nil
                    local showStr = ""
                    if CharInfo.getVIPLevel()>=vipLock then
                        CSResourceMgr.setLabelColorByNode(empty, {r=115,g=152,b=187,a=255})
                        showStr = "team4"
                    else
                        CSResourceMgr.setSpriteTextureByNode(parent, "UI/CommonFiles/share_formation_selected_unlock.png")
                        CSResourceMgr.setLabelColorByNode(empty, {r=255,g=141,b=0,a=255})
                        local vipInfo = CharInfo.getVipInfoByID(vipLock)
                        showStr = CocosModuleMgr.createStringWithFormat({"team62", vipInfo.viplevel})
                    end
                    CSResourceMgr.setLabelStringByNode(empty, showStr, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 150)
                elseif index==2 then
                    local lockstr = CSResourceMgr.seekNodeByName(parent, "lockstr")
                    CSResourceMgr.setLabelColorByNode(lockstr, {r=255,g=245,b=175,a=255})
                    CSResourceMgr.setLabelStringByNode(lockstr, "team5", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 150)
                    local locktime = CSResourceMgr.seekNodeByName(parent, "locktime")
                    CSResourceMgr.setLabelStringByNode(locktime, CocosModuleMgr.createStringWithFormat({"team20", 
                        math.floor(needTime[var]/3600)}),{r=0,g=0,b=0,a=255,w=1,s=1}, nil, 150)
                    CSResourceMgr.longtouchEventBindingByNode(button, function()
                        DropInfoViewMgr.showWithAwardElements(awardPreIDs[var])
                    end, function()
                        for v=1, TeamViewMgr.DEFAULT_AWARD_SIZE do
                            if waitTime[v] then
                                StandardTipsMgr.show(1, "team19")
                                return
                            end
                        end
                        NetInterface.sendWithBlock("GC_UnlockTreasureBox_Ack", function()
                            TreasureBoxSend.sendCG_UnlockTreasureBox_Req({boxID=var-1})
                        end, function()
                            endTime[var] = CharInfo.getServerTime()+needTime[var]
                            waitTime[var] = needTime[var]
                            myBoxData[var].time = endTime[var]
                            setType(4)
                        end, function(code)
                        	TipsMgr.showError(nil, code)
                        end)
                    end, "select1")
                elseif index==3 then
                    CSResourceMgr.setLabelStringByNode(unlock, "team7", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 150)
                    CSResourceMgr.longtouchEventBindingByNode(button, function()
                        DropInfoViewMgr.showWithAwardElements(awardPreIDs[var])
                    end, function()
                        --TipsMgr.show(nil, "打开")
                        NetInterface.sendWithBlock("GC_OpenTreasureBox_Ack", function()
                            TreasureBoxSend.sendCG_OpenTreasureBox_Req({boxID=var-1, bFree=1})
                        end, function()
                            --setType(1)
                            myBoxData[var] = {}
                            TeamViewMgr.refreshTreasureBox()
                        end, function(code)
                            TipsMgr.showError(nil, code)
                        end)
                    end, "select1")
                elseif index==4 then
                    local timedb = CSResourceMgr.seekNodeByName(parent, "timedb")
                    timedb:setColor({r=151,g=190,b=240})
                    timedb:setOpacity(128)
                    local fast = CSResourceMgr.seekNodeByName(parent, "fast")
                    CSResourceMgr.setLabelColorByNode(fast, {r=166,g=243,b=255,a=255})
                    CSResourceMgr.setLabelStringByNode(fast, "team6", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 120)
                    CSResourceMgr.longtouchEventBindingByNode(button, function()
                        DropInfoViewMgr.showWithAwardElements(awardPreIDs[var])
                    end, function()
                        --TipsMgr.show(nil, "快速打开")
                        local mcoin = math.ceil((endTime[var]-CharInfo.getServerTime())/mPrice[var])
                        DialogBoxMgr.showSmallDialogBox(nil, 2, CocosModuleMgr.createStringWithFormat({"team50", mcoin}), function()
                            NetInterface.sendWithBlock("GC_OpenTreasureBox_Ack", function()
                                TreasureBoxSend.sendCG_OpenTreasureBox_Req({boxID=var-1, bFree=0})
                            end, function()
                                --setType(1)
                                TreasureBoxInfo.addTodayBuyTimes()
                                myBoxData[var] = {}
                                TeamViewMgr.refreshTreasureBox()
                            end, function(code)
                                TipsMgr.showError(nil, code)
                            end)
                        end)
                    end, "select1")
                    local currentMcoin = math.ceil(waitTime[var]/mPrice[var])
                    local opentime = CSResourceMgr.seekNodeByName(parent, "opentime")
                    local mcoin = CSResourceMgr.seekNodeByName(parent, "mcoin")
                    CSResourceMgr.setLabelStringByNode(opentime, "", {r=0,g=0,b=0,a=255,w=1,s=1})
                    CocosModuleMgr.setTimeLabelCountDown(opentime, waitTime[var], function()
                        setType(3)
                    end, function(sec)
                        local cMcoin = math.ceil(sec/mPrice[var])
                        if cMcoin~=currentMcoin then
                            currentMcoin = cMcoin
                            CSResourceMgr.setLabelStringByNode(mcoin, currentMcoin, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 80)
                        end
                    end)
                    CSResourceMgr.setLabelStringByNode(mcoin, currentMcoin, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 80)
                    --添加推送                        
                    BaseFunction.registerLocalNotification(os.time()+waitTime[var], nil, "idling31", "", 6, 0)
                end
            end
            if endTime[var] then
            	waitTime[var] = endTime[var]-CharInfo.getServerTime()
            end
            if imageIcon[var] then
                CSResourceMgr.setButtonTextureByNode(button, imageIcon[var], imageIcon[var], imageIcon[var])
                if waitTime[var] then
                    if waitTime[var]>0 then
                        setType(4)
                    else
                        setType(3)
                    end
                else
                    setType(2)
                end
            else
                setType(1)
            end
            
            if showAni then
                parent:show()
                parent:scale(0)
                transition.scaleTo(parent, {scale=1, time=0.2})
            end
            treasureBoxNodes[var] = parent
        end)
    end
    UnblockLoader.load(funcTable, tag.."T")
end

function TeamViewMgr.refreshTeamMain()
    if not CSResourceMgr.getCsbObj(preResName) then
    	return
    end
    local btnRes1 = {"UI/CommonFiles/menu_green_normal_su_03.png", 
        "UI/CommonFiles/menu_green_ed_su_03.png", "UI/CommonFiles/menu_gray_ed_su_03.png"}
    local btnRes2 = {"UI/CommonFiles/menu_yellow_normal_su_03.png", 
        "UI/CommonFiles/menu_yellow_ed_su_03.png", "UI/CommonFiles/menu_gray_ed_su_03.png"}
    local isCaptain = TeamInfo.getInfo(TeamInfo.KEY_LEADERID)==CharInfo.getCharID()
    if isCaptain then
        CSResourceMgr.setButtonTexture(preResName, "start", btnRes1[1], btnRes1[2], btnRes1[3])
        CSResourceMgr.setButtonString(preResName, "start", "team14", "", {r=0,g=0,b=0,a=255,w=1,s=1})
        CSResourceMgr.clickEventBinding(preResName, "start", function()
            local function check()
                local memberInfo = TeamInfo.getInfo(TeamInfo.KEY_MEMBER)
                for var=1, #memberInfo do
                    local mInfo = memberInfo[var]
                    if not mInfo.isReady and CharInfo.getCharID()~=mInfo.charID then
                        StandardTipsMgr.show(1, "team27")
                        return
                    end
                end
                if #TeamInfo.getSelPet()[1]==0 then
                    StandardTipsMgr.show(1, "team31")
                    return
                end
                NetInterface.sendWithBlock("GC_SetTeamPets_Ack", function()
                    TeamSend.sendCG_SetTeamPets_Req({petObjIDs=TeamInfo.getSelPet()[1], 
                        helperPetObjIDs=TeamInfo.getSelPet()[2]})
                end, function()
                    TeamCopyInfo.EnterTeamCopyMap()
                end, function(code)
                    TipsMgr.showError(nil, code)
                end)
            end
            local memberInfo = TeamInfo.getInfo(TeamInfo.KEY_MEMBER)
            if #memberInfo<TeamViewMgr.TEAM_PLAYER_NUM then
                DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, "team67", function()
                    check()
                end)
                return
            end
            check()
        end, "", nil, "mapchange2")
    else
        CSResourceMgr.setButtonTexture(preResName, "start", btnRes2[1], btnRes2[2], btnRes2[3])
        CSResourceMgr.setButtonString(preResName, "start", "team17", "", {r=0,g=0,b=0,a=255,w=1,s=1})
        local boolReady = false
        local memberInfo = TeamInfo.getInfo(TeamInfo.KEY_MEMBER)
        if memberInfo then
        	local index, minfo = TeamInfo.getTeamMember(CharInfo.getCharID())
            if minfo then
                boolReady = minfo.isReady
        	end
        end
        if boolReady then
            CSResourceMgr.setButtonString(preResName, "start", "team28")
        end
        CSResourceMgr.clickEventBinding(preResName, "start", function()
            if boolReady then
                NetInterface.sendWithBlock("GC_SetTeamReady_Ack", function()
                    TeamSend.sendCG_SetTeamReady_Req({isReady=0})
                end, function()
                    print("取消准备")
                    boolReady = false
                    CSResourceMgr.setButtonString(preResName, "start", "team17")
                end, function(code)
                    TipsMgr.showError(nil, code)
                end)
            else
                if #TeamInfo.getSelPet()[1]==0 then
                    StandardTipsMgr.show(1, "team31")
                	return
                end
                NetInterface.sendWithBlock("GC_SetTeamPets_Ack", function()
                    TeamSend.sendCG_SetTeamPets_Req({petObjIDs=TeamInfo.getSelPet()[1], 
                        helperPetObjIDs=TeamInfo.getSelPet()[2]})
                end, function()
                    NetInterface.sendWithBlock("GC_SetTeamReady_Ack", function()
                        TeamSend.sendCG_SetTeamReady_Req({isReady=1})
                    end, function()
                        print("准备就绪")
                        GameAudio.playUISound("success")
                        boolReady = true
                        CSResourceMgr.setButtonString(preResName, "start", "team28")
                    end, function(code)
                        TipsMgr.showError(nil, code)
                    end)
                end, function(code)
                    TipsMgr.showError(nil, code)
                end)
            end
        end)
    end
    CSResourceMgr.getNodeByName(preResName, "start"):show()
    local memberInfo = TeamInfo.getInfo(TeamInfo.KEY_MEMBER)
    if memberInfo then
        for var=1, TeamViewMgr.TEAM_PLAYER_NUM do
            local curMemberInfo = memberInfo[var]
            TeamViewMgr.refreshTeamMember(var, curMemberInfo)
        end
    end
end

function TeamViewMgr.refreshTeamMember(index, memberInfo)
    if not CSResourceMgr.getCsbObj(preResName) then
        return
    end
    local parent = memberNodes[index]
	if not parent then
		return
	end
    local start = CSResourceMgr.getNodeByName(preResName, "start")
    if TeamInfo.checkMemberReady() then
        transition.stopTarget(start)
        StandardTipsMgr.show(0, "team61")
        local function wait(second)
            local time = second-1
            if second<=5 then
                if second<=0 then
                	return
                else
                    local str = "team60"
                    TownChatMgr.addChatMessage(CocosModuleMgr.createStringWithFormat({str, second}), 7, false, {name = ""})
                end
            end
            start:performWithDelay(function()
                wait(time)
            end, 1)
        end
        wait(10)
    else
        transition.stopTarget(start)
    end
    UnblockLoader.load({function()
        local state1 = CSResourceMgr.seekNodeByName(parent, "state1")
        local state2 = CSResourceMgr.seekNodeByName(parent, "state2")
        local isCaptain = TeamInfo.getInfo(TeamInfo.KEY_LEADERID)==CharInfo.getCharID()
        if memberInfo then
            state1:show()
            state2:hide()
            local decorate = CSResourceMgr.seekNodeByName(parent, "decorate")
            decorate:setColor({r=0,g=0,b=0})
            decorate:setOpacity(51)
            transition.stopTarget(decorate)
            local ani = cc.RepeatForever:create(cc.RotateBy:create(5, 180))
            decorate:runAction(ani)
            if memberAni[index] then
                PlayerAnimeMgr.setPlayerSkins(tag..index, memberInfo.fashion.curFashion)
            else
                memberAni[index] = PlayerAnimeMgr.createPlayer(state1, {skin=memberInfo.fashion.curFashion}, tag..index)
            end
            local name = CSResourceMgr.seekNodeByName(parent, "name")
            CSResourceMgr.setLabelColorByNode(name, {r=196,g=230,b=252,a=255})
            CSResourceMgr.setLabelStringByNode(name, memberInfo.name, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 180)
            local level = CSResourceMgr.seekNodeByName(parent, "level")
            CSResourceMgr.setLabelColorByNode(level, {r=255,g=252,b=0,a=255})
            CSResourceMgr.setLabelStringByNode(level, "Lv"..memberInfo.level, {r=0,g=0,b=0,a=255,w=1}, nil, 180)
            local captain = CSResourceMgr.seekNodeByName(parent, "captain")
            if memberInfo.charID==TeamInfo.getInfo(TeamInfo.KEY_LEADERID) then
                captain:show()
            else
                captain:hide()
            end
            local ready = CSResourceMgr.seekNodeByName(parent, "ready")
            CSResourceMgr.setLabelStringByNode(ready, "team22", {r=0,g=0,b=0,a=255,w=1}, nil, 120)
            ready:zorder(1)
            CSResourceMgr.setLabelColorByNode(ready, {r=255,g=252,b=0,a=255})
            if memberInfo.isReady then
                ready:show()
            else
                ready:hide()
            end
            local startPosx = 0
            local isDraged = false
            local function cancelFunc()
                if isDraged then
                    local finalPosX = parent:getPositionX()
                    local diffMin = 640
                    local changeIndex = nil
                    local terminalIndex = nil
                    for key, var in pairs(memberNodesPosx) do
                        local diff = math.abs(var-finalPosX)
                        if diff<diffMin then
                            diffMin = diff
                    		changeIndex = key
                    	end
                    end
                    for key, var in pairs(memberNodes) do
                    	local posx = var:getPositionX()
                        if posx==memberNodesPosx[changeIndex] then
                            terminalIndex = key
                    		break
                    	end
                    end
                    if terminalIndex then
                        local sort = TeamInfo.getInfo(TeamInfo.KEY_SORT)
                        local tmpSort = {}
                        for key, var in pairs(sort) do
                    		if var==index-1 then
                                tmpSort[key] = terminalIndex-1
                    		elseif var==terminalIndex-1 then
                                tmpSort[key] = index-1
                    		else
                    		    tmpSort[key] = var
                    		end
                    		print("队伍排序", key, tmpSort[key])
                    	end
                        NetInterface.sendWithBlock("GC_SetTeamSort_Ack", function()
                            TeamSend.sendCG_SetTeamSort_Req({teamSort=tmpSort})
                        end, nil, function(code)
                            TeamViewMgr.refreshTeamMemberSort(TeamInfo.getInfo(TeamInfo.KEY_SORT))
                        	TipsMgr.showError(nil, code)
                        end)
                    else
                        TeamViewMgr.refreshTeamMemberSort(TeamInfo.getInfo(TeamInfo.KEY_SORT))
                    end
                else
                    --玩家信息
                    if CharInfo.getCharID()~=memberInfo.charID then
                        TeamInviteMgr.showPlayer(SceneMgr.getRunningScene, memberInfo.charID, isCaptain)
                    end
                    TeamViewMgr.refreshTeamMemberSort(TeamInfo.getInfo(TeamInfo.KEY_SORT))
                end
            end
            if isCaptain then
                CSResourceMgr.buttonEventBindingByNode(parent, function(sender)
                    local px = sender:getPositionX()
                    local py = sender:getPositionY()
                    startPosx = px
                    isDraged = false
                    sender:zorder(1)
                end, function()
                    cancelFunc()
                end, function(sender)
                    local bx = sender:getTouchBeganPosition().x
                    local by = sender:getTouchBeganPosition().y
                    local x = sender:getTouchMovePosition().x
                    local y = sender:getTouchMovePosition().y
                    sender:setPositionX(startPosx-bx+x)
                    if math.abs(x-bx)>20 then
                        isDraged = true
                    end
                end, function()
                    cancelFunc()
                end)
            else
                CSResourceMgr.clickEventBindingByNode(parent, function()
                    cancelFunc()
                end)
            end
            CSResourceMgr.setButtonEnabledByNode(parent, true)
        else
            state2:show()
            state1:hide()
            local change = CSResourceMgr.seekNodeByName(parent, "change")
            local invite = CSResourceMgr.seekNodeByName(parent, "invite")
            CSResourceMgr.setButtonStringByNode(invite, "team13", {r=0,g=0,b=0,a=255,w=1,s=1})
            CSResourceMgr.clickEventBindingByNode(invite, function()
            	--邀请
            	local curAdvId = advInfoVec[curIndex].aid
                local tInfo = TeamMapInfo.getTeamFloorInfoById(curAdvId)
                TeamInviteMgr.show(SceneMgr.getRunningScene, tInfo.enterMinLevel, tInfo.enterMaxLevel)
            end)
            local bardb = CSResourceMgr.seekNodeByName(parent, "bardb")
            local infostr1 = CSResourceMgr.seekNodeByName(parent, "infostr1")
            CSResourceMgr.setLabelStringByNode(infostr1, "team11", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 100)
            local infostr2 = CSResourceMgr.seekNodeByName(parent, "infostr2")
            CSResourceMgr.setLabelColorByNode(infostr2, {r=148,g=192,b=236,a=255})
            local infostr3 = CSResourceMgr.seekNodeByName(parent, "infostr3")
            CSResourceMgr.setLabelColorByNode(infostr3, {r=148,g=192,b=236,a=255})
            local slide = CSResourceMgr.seekNodeByName(parent, "slide")
            local function setCanJoin(boolCan)
                local sPosx = math.abs(slide:getPositionX())
                if boolCan then
                    slide:setPositionX(sPosx)
                    bardb:show()
                    CSResourceMgr.setLabelColorByNode(infostr1, {r=255,g=255,b=255,a=255})
                    CSResourceMgr.setLabelStringByNode(infostr2, "team3", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 180)
                    CSResourceMgr.setLabelStringByNode(infostr3, "team21", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 180)
                else
                    slide:setPositionX(-sPosx)
                    bardb:hide()
                    CSResourceMgr.setLabelColorByNode(infostr1, {r=69,g=97,b=118,a=255})
                    CSResourceMgr.setLabelStringByNode(infostr2, "team15", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 180)
                    CSResourceMgr.setLabelStringByNode(infostr3, "team16", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 180)
                end
            end
            local canJoin = TeamInfo.getInfo(TeamInfo.KEY_JOINSTATUS)
            setCanJoin(canJoin)
            if isCaptain then
                CSResourceMgr.setButtonEnabledByNode(change, true)
                invite:show()
                slide:setColor({r=255,g=255,b=255})
                CSResourceMgr.clickEventBindingByNode(change, function()
                    local canJoin = TeamInfo.getInfo(TeamInfo.KEY_JOINSTATUS)
                    local joinStatus = 1
                    if canJoin then
                        joinStatus = 0
                    end
                    NetInterface.sendWithBlock("GC_SetTeamAutoJoin_Ack", function()
                        TeamSend.sendCG_SetTeamAutoJoin_Req({canAutoJoin=joinStatus})
                    end, nil, function(code)
                    	TipsMgr.showError(nil, code)
                    end)
                end, nil, "select1")
            else
                CSResourceMgr.setButtonEnabledByNode(change, false)
                invite:hide()
                slide:setColor({r=128,g=128,b=128})
                CSResourceMgr.setLabelStringByNode(infostr3, "team21", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 180)
            end
            CSResourceMgr.setButtonEnabledByNode(parent, false)
        end
    end}, tag.."R")
end

function TeamViewMgr.refreshTeamMemberSort(sort, boolAni)
    if boolAni==nil then
    	boolAni = true
    end
	for key, var in pairs(sort) do
		local index = var+1
		local terminalPosx = memberNodesPosx[key]
        local node = memberNodes[index]
        if node then
            --print("move", index, key, terminalPosx)
            if boolAni then
                transition.stopTarget(node)
                transition.moveTo(node, {x=terminalPosx, time=0.1})
                node:zorder(0)
            else
                node:setPositionX(terminalPosx)
                node:zorder(0)
            end
        end
	end
end

function TeamViewMgr.setChatUI(boolOpen)
    local chatRes = "UI/Chat/TownChatLayer.csb"
    local layer = CSResourceMgr.getCsbObj(chatRes)
    if boolOpen then
        curChatStatus = nil
        if not layer then
            TownChatMgr.addUI()
            TownChatMgr.changeStatus(1)
            layer = CSResourceMgr.getCsbObj(chatRes)
            BasicMenuMgr.setChatBtnEnable(false)
            BasicMenuMgr.setChatRedPoint(false)
        else
            TownChatMgr.setVisible(true)
            curChatStatus = layer:getPositionY()
        end
        --附近聊天变更组队聊天
        local diff, edgeDiff = TownChatMgr.getScreenSizeDiff()
        CocosModuleMgr.setRelativePosition(layer, 320, 480)
        transition.stopTarget(layer)
        CocosModuleMgr.setEdgeDistance(layer, nil, nil, nil, edgeDiff-80)
        TownChatMgr.setVoiceDiff(-80)
        CocosModuleMgr.showUIAnimation(layer, "up")
        GameAudio.playUISound("messagePopup")
    else
        if curChatStatus and layer then
            --组队聊天变更附近聊天
            transition.moveTo(layer, {y=curChatStatus, time=0.1})
        elseif curChatStatus==nil then
            TownChatMgr.removeUI()
        end
        TownChatMgr.setVoiceDiff(0)
    end
end

function TeamViewMgr.refreshServerTime()
    if CSResourceMgr.getCsbObj(topResName) then
        TreasureBoxInfo.GetTreasureBoxData(TeamViewMgr.refreshTreasureBox)
    end
    TreasureBoxInfo.checkRedPoint()
end

function TeamViewMgr.isTeamViewOpen()
    if CSResourceMgr.getCsbObj(topResName) then
		return true
	end
	return false
end

return TeamViewMgr