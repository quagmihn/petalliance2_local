local TeamInviteMgr = {}

local resName = ""
local resNameA = ""
local curTab = 1
local tabALoad = false
local tabBLoad = false
local inTeamPlay = false
local isLeader = false
local minLevel = 0
local maxLevel = 0

function TeamInviteMgr.Init()
	resName = "Player/Team/invitePlayersView.csb"
	resNameA = "Player/Team/teamPlayerInfoWindow.csb"
    curTab = 1
    tabALoad = false
    tabBLoad = false
    inTeamPlay = false
    isLeader = false
end

function TeamInviteMgr.show(scene,minLv,maxLv)
    GameAudio.playUISound("popup")
    local function loadCSB()
	    local page = CSResourceMgr.createRes(scene, resName)
	    page:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
	    CSResourceMgr.setRelativePosition(resName, 320,480)

        local title = CSResourceMgr.getNodeByName(resName,"title")
        CSResourceMgr.setLabelColorByNode(title, {r=160,g=235,b=250,a=255})
        CSResourceMgr.setLabelStringByNode(title,"TeamInvite0" , {r=37,g=54,b=75,a=255})

        CSResourceMgr.clickEventBinding(resName,"close",function()
            TeamInviteMgr.hide()
        end)
        minLevel = minLv
        maxLevel = maxLv

        local selColor = {r=255,g=243,b=227,a=255}
        local selOutColor = {r=89,g=47,b=5,a=255,w=1}
        local unselColor = {r=227,g=233,b=255,a=255}
        local unselOutColor = {r=10,g=22,b=65,a=0}
        local tabName = {"TeamInvite2", "TeamInvite3"}
        for var=1, 2 do
            CSResourceMgr.clickEventBinding(resName, "tab"..var, function()
                GameAudio.playUISound("sheetClick")
                CSResourceMgr.setButtonEnabled(resName, "tab"..curTab, true)
                CSResourceMgr.getNodeByName(resName, "list"..curTab):setVisible(false)
                CSResourceMgr.setButtonStringColor(resName, "tab"..curTab, unselColor)
                CSResourceMgr.setButtonString(resName, "tab"..curTab, tabName[curTab],"",unselOutColor)
                local tabbtn = CSResourceMgr.getNodeByName(resName, "tab"..curTab)
                tabbtn:setPositionY(-10)
                tabbtn:setScale(1, 1)
                tabbtn:setLocalZOrder(1)
                curTab = var
                CSResourceMgr.setButtonEnabled(resName, "tab"..curTab, false)
                CSResourceMgr.getNodeByName(resName, "list"..curTab):setVisible(true)
                CSResourceMgr.setButtonStringColor(resName, "tab"..curTab, selColor)
                CSResourceMgr.setButtonString(resName, "tab"..curTab, tabName[curTab],"",selOutColor)
                local curtabbtn = CSResourceMgr.getNodeByName(resName, "tab"..curTab)
                curtabbtn:setPositionY(-5)
                curtabbtn:setScale(1.1, 1.1)
                curtabbtn:setLocalZOrder(2)
                if curTab == 1 and not tabALoad then
                    NetInterface.sendWithBlock("GC_GetMyFriends_Ack", function()
                        local ChatUserSend = require("src.Net.Send.ChatUserSend")
                        ChatUserSend.sendCG_GetMyFriends_Req()
                        end)
                    tabALoad = true
                elseif curTab == 2 and not tabBLoad then
                    TeamInviteMgr.setInviteFamilys()
                    tabBLoad = true
                end
            end)
            CSResourceMgr.setButtonStringColor(resName, "tab"..var, unselColor)
            CSResourceMgr.setButtonString(resName, "tab"..var, tabName[var],"",unselOutColor)
            local tabbtn = CSResourceMgr.getNodeByName(resName, "tab"..var)
            tabbtn:setPositionY(-10)
            tabbtn:setScale(1, 1)
            tabbtn:setLocalZOrder(1)
        end
        CSResourceMgr.setButtonStringColor(resName, "tab"..curTab, selColor)
        CSResourceMgr.setButtonString(resName, "tab"..curTab, tabName[curTab],"",selOutColor)
        CSResourceMgr.setButtonEnabled(resName, "tab"..curTab, false)
        CSResourceMgr.getNodeByName(resName, "list"..curTab):setVisible(true)
        local curtabbtn = CSResourceMgr.getNodeByName(resName, "tab"..curTab)
        curtabbtn:setPositionY(-5)
        curtabbtn:setScale(1.1, 1.1)
        curtabbtn:setLocalZOrder(2)  
        if curTab == 1 and not tabALoad then
            NetInterface.sendWithBlock("GC_GetMyFriends_Ack", function()
                local ChatUserSend = require("src.Net.Send.ChatUserSend")
                ChatUserSend.sendCG_GetMyFriends_Req()
                end)
            tabALoad = true
        elseif curTab == 2 and not tabBLoad then
            TeamInviteMgr.setInviteFamilys()
            tabBLoad = true
        end
        if not CharInfo.getFamilyID() then
            CSResourceMgr.getNodeByName(resName, "tab2"):setVisible(false)
        end
    end
    local function playCSB()
        CSResourceMgr.playAction(resName, 0, 5, false)
    end
    
    local funcTable = {loadCSB, playCSB}
    UnblockLoader.load(funcTable, "TeamInviteMgr.show")
end

function TeamInviteMgr.setInviteFriends(friendTable)
    local list = CSResourceMgr.getNodeByName(resName, "list1")
    local funcTable = {}

    local function setApplyPlayer(playerInfo)
        local player = CSResourceMgr.getNodeByName(resName, "applyPlayer"):clone()
        player:setVisible(true)
        local playerName = CSResourceMgr.seekNodeByName(player, "playerName")
        CSResourceMgr.setLabelColorByNode(playerName, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(playerName,playerInfo.name, {r=0,g=0,b=0,a=255,w=1,s=1})
        local attackNum = CSResourceMgr.seekNodeByName(player, "attackNum")
        CSResourceMgr.setLabelColorByNode(attackNum, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(attackNum,playerInfo.fightPoint, {r=0,g=0,b=0,a=255,w=1,s=1})
        local back = CSResourceMgr.seekNodeByName(player, "back")
        back:setColor({r=81,g=112,b=137})
        local back2 = CSResourceMgr.seekNodeByName(player, "back2")
        back2:setColor({r=81,g=112,b=137})
        local back3 = CSResourceMgr.seekNodeByName(player, "back3")
        back3:setColor({r=128,g=161,b=172})
        local level = CSResourceMgr.seekNodeByName(player, "level")
        CSResourceMgr.setLabelColorByNode(level, {r=255,g=252,b=0,a=255})
        CSResourceMgr.setLabelStringByNode(level,"lv"..playerInfo.level, {r=5,g=48,b=84,a=255})
        local trueBtn = CSResourceMgr.seekNodeByName(player,"trueBtn")
        CSResourceMgr.setButtonStringByNode(trueBtn, "TeamInvite1", {r=0,g=0,b=0,a=255,w=1,s=1})
        CSResourceMgr.setButtonStringColorByNode(trueBtn, {r=255,g=255,b=255,a=255})
        local headIcon = CSResourceMgr.seekNodeByName(player,"headIcon")
        if playerInfo.fashion then
            headIcon:loadTexture(CharInfo.getHeadIcon(playerInfo.fashion.curFashion))
        end

        if playerInfo.level > maxLevel or playerInfo.level < minLevel then
            CSResourceMgr.setButtonEnabledByNode(trueBtn)
        end
        CSResourceMgr.clickEventBindingByNode(trueBtn, function()
            GameAudio.playUISound("select1")
            NetInterface.sendWithBlock("GC_InviteTeamMember_Ack", function()
                local TeamSend = require("src.Net.Send.TeamSend")
                TeamSend.sendCG_InviteTeamMember_Req({charID = playerInfo.friendID})
                end,function()
                    StandardTipsMgr.show(0, "TeamInvite5")
                end,function(code)
                    if code == Proto.Error.ERROR_NOTEAM then
                        StandardTipsMgr.show(1, "TeamInvite12")
                    end
                end)
        end)
        list:pushBackCustomItem(player)
        player:setScaleY(0)
        transition.scaleTo(player, {scale=1, time=0.2})
    end
    for k,v in pairs(friendTable) do
        local cjson = require("cjson")
        local friendInfo = cjson.decode(v)
        if friendInfo.needConfirm ~= 1 then
            table.insert(funcTable,function()
                setApplyPlayer(friendInfo)
            end)
        end
    end
    UnblockLoader.load(funcTable, "TeamInviteMgr.setInviteFriends")
end

function TeamInviteMgr.setInviteFamilys()
    local list = CSResourceMgr.getNodeByName(resName, "list2")
    local funcTable = {}

    local function setApplyPlayer(playerInfo)
        local player = CSResourceMgr.getNodeByName(resName, "applyPlayer"):clone()
        player:setVisible(true)
        local playerName = CSResourceMgr.seekNodeByName(player, "playerName")
        CSResourceMgr.setLabelColorByNode(playerName, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(playerName,playerInfo.name, {r=0,g=0,b=0,a=255,w=1,s=1})
        local attackNum = CSResourceMgr.seekNodeByName(player, "attackNum")
        CSResourceMgr.setLabelColorByNode(attackNum, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(attackNum,playerInfo.fightPoint, {r=0,g=0,b=0,a=255,w=1,s=1})
        local back = CSResourceMgr.seekNodeByName(player, "back")
        back:setColor({r=81,g=112,b=137})
        local back2 = CSResourceMgr.seekNodeByName(player, "back2")
        back2:setColor({r=81,g=112,b=137})
        local back3 = CSResourceMgr.seekNodeByName(player, "back3")
        back3:setColor({r=128,g=161,b=172})
        local level = CSResourceMgr.seekNodeByName(player, "level")
        CSResourceMgr.setLabelColorByNode(level, {r=255,g=252,b=0,a=255})
        CSResourceMgr.setLabelStringByNode(level,"lv"..playerInfo.level, {r=5,g=48,b=84,a=255})
        local trueBtn = CSResourceMgr.seekNodeByName(player,"trueBtn")
        CSResourceMgr.setButtonStringByNode(trueBtn, "TeamInvite1", {r=0,g=0,b=0,a=255,w=1,s=1})
        CSResourceMgr.setButtonStringColorByNode(trueBtn, {r=255,g=255,b=255,a=255})
        local headIcon = CSResourceMgr.seekNodeByName(player,"headIcon")
        if playerInfo.fashion then
            headIcon:loadTexture(CharInfo.getHeadIcon(playerInfo.fashion.curFashion))
        end

        if playerInfo.level > maxLevel or playerInfo.level < minLevel then
            CSResourceMgr.setButtonEnabledByNode(trueBtn)
        end
        CSResourceMgr.clickEventBindingByNode(trueBtn, function()
            GameAudio.playUISound("select1")
            NetInterface.sendWithBlock("GC_InviteTeamMember_Ack", function()
                local TeamSend = require("src.Net.Send.TeamSend")
                TeamSend.sendCG_InviteTeamMember_Req({charID = playerInfo.charID})
                end,function()
                    StandardTipsMgr.show(0, "TeamInvite5")
                end)
        end)
        list:pushBackCustomItem(player)
        player:setScaleY(0)
        transition.scaleTo(player, {scale=1, time=0.2})
    end
    for k,v in pairs(FamilyInfo.GetLocalFamilyMembersInfo()) do
        if v.charID ~= CharInfo.getCharID() then
            table.insert(funcTable,function()
                setApplyPlayer(v)
            end)
        end
    end
    UnblockLoader.load(funcTable, "TeamInviteMgr.setInviteFamilys")
end

function TeamInviteMgr.hide()
    GameAudio.playUISound("retract")
    local list1 = CSResourceMgr.getNodeByName(resName, "list1")
    CSResourceMgr.removeListByNode(list1)
    local list2 = CSResourceMgr.getNodeByName(resName, "list2")
    CSResourceMgr.removeListByNode(list2)
	curTab = 1
    tabALoad = false
    tabBLoad = false
    UnblockLoader.cancel("TeamInviteMgr.show")
    UnblockLoader.cancel("TeamInviteMgr.setInviteFriends")
    UnblockLoader.cancel("TeamInviteMgr.setInviteFamilys")
    CSResourceMgr.removeCSObjectByTag(resName)
end

function TeamInviteMgr.showPlayer(scene, charID,leader)
    isLeader = leader
    inTeamPlay = true
    NetInterface.sendWithBlock("GC_GetFriendDetail_Ack", function()
        local ChatUserSend = require("src.Net.Send.ChatUserSend")
        ChatUserSend.sendCG_GetFriendDetail_Req({friendID = tostring(charID)})
        end)
end

function TeamInviteMgr.hidePlayer()
	inTeamPlay = false
    isLeader = false
    CSResourceMgr.removeCSObjectByTag(resNameA)
    UnblockLoader.cancel("TeamInviteMgr.showPlayerInfoWindow")
end

function TeamInviteMgr.isInTeamPlay()
    return inTeamPlay
end

function TeamInviteMgr.showPlayerInfoWindow(playerInfo)
    local function loadCSB()
        local page = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameA)
        page:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameA, 320,480)

        local title = CSResourceMgr.getNodeByName(resNameA,"title")
        CSResourceMgr.setLabelColorByNode(title, {r=160,g=235,b=250,a=255})
        CSResourceMgr.setLabelStringByNode(title,"TeamInvite6" , {r=37,g=54,b=75,a=255})

        CSResourceMgr.clickEventBinding(resNameA,"close",function()
            TeamInviteMgr.hidePlayer()
        end)

        local buttonList = {}
        local buttonLabeLs = {"TeamInvite7","TeamInvite8","TeamInvite9","TeamInvite10"}
        for i=1,4 do
            buttonList[i] = CSResourceMgr.getNodeByName(resNameA,"Button"..i)
            CSResourceMgr.setButtonStringColorByNode(buttonList[i], {r=227,g=233,b=255,a=255})
            CSResourceMgr.setButtonStringByNode(buttonList[i], buttonLabeLs[i], {r=0,g=0,b=0,a=255})
        end
        if isLeader then
            CSResourceMgr.setButtonStringByNode(buttonList[4], "TeamInvite4", {r=0,g=0,b=0,a=255})
        end

        --查看好友按钮
        CSResourceMgr.clickEventBindingByNode(buttonList[1],function()
            GameAudio.playUISound("ok")
            PersonalCenterMgr.show(SceneMgr.getRunningScene,playerInfo.charID)
        end)

        --添加好友按钮
        local friendInfo = {friendID = tonumber(playerInfo.charID)}
        local addFriendNeedLv = SystemInfo.getGlobalConfigAddInfoByID(21006).values[1]
        if FriendsViewMgr.isHaveFriend(friendInfo) or CharInfo.getLevel()<addFriendNeedLv then
            CSResourceMgr.setButtonEnabledByNode(buttonList[2], false)
        else
            CSResourceMgr.clickEventBindingByNode(buttonList[2],function()
                GameAudio.playUISound("friendAccecpt")
                FriendsViewMgr.AddFriend(playerInfo.charID)
                TeamInviteMgr.hidePlayer()
            end)
        end
        
        --设为私聊按钮
        CSResourceMgr.clickEventBindingByNode(buttonList[3],function()
            GameAudio.playUISound("ok")
            TownChatMgr.setOneChat({name = playerInfo.nickname,id = tonumber(playerInfo.charID)})
            TeamInviteMgr.hidePlayer()
        end)

        --屏蔽发言按钮
        CSResourceMgr.clickEventBindingByNode(buttonList[4],function()
            GameAudio.playUISound("friendDelete")
            if isLeader then
                --踢出队伍
                NetInterface.sendWithBlock("GC_KickTeamMember_Ack", function()
                    local TeamSend = require("src.Net.Send.TeamSend")
                    TeamSend.sendCG_KickTeamMember_Req({charID = playerInfo.charID})
                    end,function()
                        StandardTipsMgr.show(0, "TeamInvite11")
                    end,function(code)
                        if code == Proto.Error.ERROR_NOTEAM then
                            StandardTipsMgr.show(1, "TeamInvite12")
                        end
                    end)
            else
                TownChatMgr.blockPeople(playerInfo.nickname)
            end
            TeamInviteMgr.hidePlayer()
        end)
    end
    local function playCSB()
        CSResourceMgr.playAction(resNameA, 0, 5, false)
    end
    
    local funcTable = {loadCSB, playCSB}
    UnblockLoader.load(funcTable, "TeamInviteMgr.showPlayerInfoWindow")
end

return TeamInviteMgr