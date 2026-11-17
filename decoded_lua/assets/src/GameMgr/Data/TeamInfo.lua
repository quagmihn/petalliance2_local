local TeamInfo = {}

TeamInfo.KEY_MEMBER = "member"
TeamInfo.KEY_SELPET = "selPet"
TeamInfo.KEY_JOINSTATUS = "join"
TeamInfo.KEY_ADVENTUREID = "adventureid"
TeamInfo.KEY_TEAMID = "teamid"
TeamInfo.KEY_LEADERID = "leaderid"
TeamInfo.KEY_SORT = "sort"
TeamInfo.KEY_STATUS = "isstart"
TeamInfo.KEY_COMMITJOIN = "commitjoin"

local tInfo = {}
local isGettingTeamMember = false
local isExitingTeam = false
local getTeamMemberFunc = {}
local exitTeamFunc = {}

function TeamInfo.Init()
    tInfo = {}
    isGettingTeamMember = false
    isExitingTeam = false
    getTeamMemberFunc = {}
    exitTeamFunc = {}
end

function TeamInfo.setInfo(key, val)
	tInfo[key] = val
end

function TeamInfo.getInfo(key)
    return tInfo[key]
end

function TeamInfo.getSelPet()
    local selPet = tInfo[TeamInfo.KEY_SELPET]
    if not selPet then
        tInfo[TeamInfo.KEY_SELPET] = {clone(PokemonInfo.getPetArmy(1)), clone(PokemonInfo.getPetHelpArmy())}
    end
    return tInfo[TeamInfo.KEY_SELPET]
end

--检查队员是否都准备完毕
function TeamInfo.checkMemberReady()
    local readyNum = 0
    if tInfo[TeamInfo.KEY_MEMBER] then
        for key, var in pairs(tInfo[TeamInfo.KEY_MEMBER]) do
            if var.charID~=tInfo[TeamInfo.KEY_LEADERID] then
                if var.isReady then
                    readyNum = readyNum+1
                end
            end
        end
	end
    if readyNum>=2 then
		return true
	else
	    return false
	end
end

--根据玩家ID获取组队成员索引和信息
function TeamInfo.getTeamMember(charID)
    local index = nil
    local memberInfo = nil
    for key, var in pairs(tInfo[TeamInfo.KEY_MEMBER]) do
        if var.charID==charID then
            index = key
            memberInfo = var
            break
        end
    end
    return index, memberInfo
end

--更新准备状态并刷新UI
function TeamInfo.setReady(charID, isReady)
    local index, memberInfo = TeamInfo.getTeamMember(charID)
    if index and memberInfo then
        memberInfo.isReady = isReady==1
        TeamViewMgr.refreshTeamMember(index, memberInfo)
    end
end

--更新队员信息并刷新UI
function TeamInfo.updateTeamMember(index, memberInfo)
    if not tInfo[TeamInfo.KEY_MEMBER] then
    	tInfo[TeamInfo.KEY_MEMBER] = {}
    end
    tInfo[TeamInfo.KEY_MEMBER][index] = memberInfo
    TeamViewMgr.refreshTeamMember(index, memberInfo)
end

--更新自动加入状态，若发生改变则刷新UI
function TeamInfo.updateJoinStatus(status)
    if not tInfo[TeamInfo.KEY_MEMBER] then
        return
    end
    local boolUpdated = false
    if tInfo[TeamInfo.KEY_JOINSTATUS]~=status then
        boolUpdated = true
    end
    tInfo[TeamInfo.KEY_JOINSTATUS] = status
    if boolUpdated then
        for n=1, TeamViewMgr.TEAM_PLAYER_NUM do
            if not tInfo[TeamInfo.KEY_MEMBER][n] then
                TeamViewMgr.refreshTeamMember(n, nil)
            end
        end
    end
end

--更新编队顺序，若发生改变则刷新UI
function TeamInfo.updateTeamSort(sort)
    if #sort==0 then
        sort = {0,1,2}
    end
    local sortChanged = false
    if tInfo[TeamInfo.KEY_SORT] then
        if #tInfo[TeamInfo.KEY_SORT]==#sort then
            for var=1, #tInfo[TeamInfo.KEY_SORT] do
                if tInfo[TeamInfo.KEY_SORT][var]~=sort[var] then
                    sortChanged = true
                    break
                end
            end
        end
    end
    tInfo[TeamInfo.KEY_SORT] = sort
    if sortChanged==true then
        print("队伍位置变更")
        TeamViewMgr.refreshTeamMemberSort(tInfo[TeamInfo.KEY_SORT])
    end
end

--检查大地图的组队副本是否上锁
function TeamInfo.checkLock(mapid)
    for key, var in pairs(WorldMapInfo.getSearchInfoByID(mapid)) do
        local starNum, starMax = AdvStarMgr.getWorldMapStarNum(var.info)
        starNum = starNum or 0
        starMax = starMax or 1
        if starNum<starMax then
        	return false
        end
    end
    return true
end

--获取组队副本解锁进度
function TeamInfo.getLockInfo(mapid)
	local curNum = 0
	local totalNum = 0
    for key, var in pairs(WorldMapInfo.getSearchInfoByID(mapid)) do
        local starNum, starMax = AdvStarMgr.getWorldMapStarNum(var.info)
        starNum = starNum or 0
        starMax = starMax or 1
        curNum = curNum+starNum
        totalNum = totalNum+starMax
    end
    return curNum, totalNum
end

--data.teamID=Proto.parseDWORD(entry); -- 组队ID
--data.leaderID=Proto.parseDWORD(entry); -- 组队ID
--data.adventureID=Proto.parseDWORD(entry); -- 副本ID
--data.canAutoJoin=Proto.parseDWORD(entry); -- 能否自动匹配
--data.isStart=Proto.parseDWORD(entry); -- 是否开始
--data.teamSort=Proto.parseVector(entry,Proto.parseDWORD); -- 组队位置排列，空数组代表正常排列位置，[0,1,2]正常顺序排列
function TeamInfo.updateTeamData(info)
    if info.canAutoJoin==0 then
    	tInfo[TeamInfo.KEY_JOINSTATUS] = false
    else
        tInfo[TeamInfo.KEY_JOINSTATUS] = true
    end
    tInfo[TeamInfo.KEY_ADVENTUREID] = info.adventureID
    tInfo[TeamInfo.KEY_TEAMID] = info.teamID
    tInfo[TeamInfo.KEY_LEADERID] = info.leaderID
    tInfo[TeamInfo.KEY_STATUS] = info.isStart
    print("更新队伍主要信息", info.teamID)
    TeamInfo.updateTeamSort(info.teamSort)
    TownChatMgr.isTeamChat(true)
end

--请求退出队伍
function TeamInfo.exitTeam(callback, failedCallback)
    if isExitingTeam then
        table.insert(exitTeamFunc, function()
            TeamInfo.exitTeam(callback, failedCallback)
        end)
        return
    end
    local function finish()
        isExitingTeam = false
        if callback then
            callback()
        end
        if exitTeamFunc[1] then
            exitTeamFunc[1]()
            table.remove(exitTeamFunc, 1)
        end
    end
    NetInterface.sendWithBlock("GC_KickTeamMember_Ack", function()
        isExitingTeam = true
        local TeamSend = require("src.Net.Send.TeamSend")
        TeamSend.sendCG_KickTeamMember_Req({charID=CharInfo.getCharID()})
    end, function()
        TeamInfo.clearTeam()
        finish()
    end, function(code)
        if failedCallback then
            failedCallback()
        end
        finish()
    end)
end

--退出队伍清空信息
function TeamInfo.clearTeam()
    print("退出队伍清空信息")
    tInfo[TeamInfo.KEY_TEAMID] = nil
    tInfo[TeamInfo.KEY_MEMBER] = nil
    --tInfo[TeamInfo.KEY_SELPET] = nil
    tInfo[TeamInfo.KEY_COMMITJOIN] = nil
    TownChatMgr.isTeamChat(false)
end

--data.charID=Proto.parseDWORD(entry); -- 玩家ID
--data.charInfo=Proto.parseString(entry); -- 玩家信息
--data.pets=Proto.parseVector(entry,Proto.parseString); -- 
--data.helperPets=Proto.parseVector(entry,Proto.parseString); -- 
--data.isReady=Proto.parseDWORD(entry); -- 是否准备
function TeamInfo.updateTeamMemberData(index, info)
    if not index then
        if tInfo[TeamInfo.KEY_MEMBER] then
            for key, var in pairs(tInfo[TeamInfo.KEY_MEMBER]) do
                if var.charID==info.charID then
                    index = key-1
                    break
                end
            end
        end
    end
    if not index then
        print("TeamInfo.updateTeamMemberData error, index not found!")
    	return
    end
    print("更新队伍成员信息", index, info.charID, info.charInfo, info.isReady, #info.pets, #info.helperPets)
    if info.charID~=0 then
        local cjson = require("cjson")
        if info.charInfo then
            local tbl = cjson.decode(info.charInfo)
            if tbl then
                for key, var in pairs(tbl) do
                    info[key] = var
                end
            end
        end
        info.isReady = info.isReady==1
        if tInfo[TeamInfo.KEY_LEADERID]==info.charID then
            info.isReady = false
        end
        info.name = info.name or info.nickname
        TeamInfo.updateTeamMember(index+1, info)
    else
        TeamInfo.updateTeamMember(index+1, nil)
    end
end

function TeamInfo.receiveTeamJoinNtf(res, callback)
    print("玩家加入队伍（需要手动请求成员信息）")
    if isGettingTeamMember then
        table.insert(getTeamMemberFunc, function()
            TeamInfo.receiveTeamJoinNtf(res, callback)
        end)
    	return
    end
    local function finish(cb)
        isGettingTeamMember = false
        if cb then
            cb()
        end
        if getTeamMemberFunc[1] then
            getTeamMemberFunc[1]()
            table.remove(getTeamMemberFunc, 1)
        end
    end
    NetInterface.sendWithBlock("GC_GetTeamMembers_Ack", function()
        isGettingTeamMember = true
        local TeamSend = require("src.Net.Send.TeamSend")
        TeamSend.sendCG_GetTeamMembers_Req({memberIndexs={0, 1, 2}})
    end, function()
        finish(callback)
    end, function(code)
        finish()
        TipsMgr.showError(nil, code)
    end)
end

function TeamInfo.receiveTeamInvite(res)
    print("被邀请队伍通知")
    for key, var in pairs(res) do
        print(key, var)
    end
    res.name = res.name or res.nickname
    res.charID = res.teamID or res.charID
    local function refuseFunc()
        NetInterface.sendWithBlock("GC_RefuseJoinTeam_Ack", function()
    		local TeamSend = require("src.Net.Send.TeamSend")
            TeamSend.sendCG_RefuseJoinTeam_Req({teamID = res.charID})
    	end)
    end    
    if TeamInfo.getInfo(TeamInfo.KEY_TEAMID) or TeamInfo.getInfo(TeamInfo.KEY_COMMITJOIN) then
        print("当前已经在队伍中，此次队伍邀请不弹。")
        StandardTipsMgr.show(1, "team38")
        StandardTipsMgr.show(1, CocosModuleMgr.createStringWithFormat({"team39", res.name}))
        refuseFunc()
        return
    end
    if not (SceneMgr.currentScene=="TownScene" or SceneMgr.currentScene=="HomeScene" or SceneMgr.currentScene=="LabScene"
        or SceneMgr.currentScene == "StarScene"
        or SceneMgr.currentScene=="MainScene") or GameGuideMgr.checkIsGuiding() or CSResourceMgr.getCsbObj("Scene/MsgLoader.csb") then
        print("当前不在指定场景中，此次队伍邀请不弹。")
        StandardTipsMgr.show(1, "team37")
        StandardTipsMgr.show(1, CocosModuleMgr.createStringWithFormat({"team39", res.name}))
        refuseFunc()
        return
    end
    local eInfoVec = WorldMapInfo.getTeamMapInfo()
    local mapid = 1
    for key, var in pairs(eInfoVec) do
        if var.aid==res.advID then
            mapid = key
        	break
        end
    end
    if not TeamInfo.checkLock(mapid) then
        print("组队副本进入条件不满足。")
        StandardTipsMgr.show(1, "team59")
        StandardTipsMgr.show(1, CocosModuleMgr.createStringWithFormat({"team39", res.name}))
        refuseFunc()
        return
    end
    local teamInfo = TeamMapInfo.getTeamFloorInfoById(res.advID)
    if CharInfo.getLevel()<teamInfo.enterMinLevel or CharInfo.getLevel()>teamInfo.enterMaxLevel then
        print("组队副本等级条件不满足。")
        StandardTipsMgr.show(1, "team59")
        StandardTipsMgr.show(1, CocosModuleMgr.createStringWithFormat({"team39", res.name}))
        refuseFunc()
        return
    end
    
    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, CocosModuleMgr.createStringWithFormat({"team33", res.name}),
        function()
            tInfo[TeamInfo.KEY_COMMITJOIN] = res.charID
            if not TeamViewMgr.isTeamViewOpen() then
                UIStack.closeAllUI()
            end            
            TeamViewMgr.show(SceneMgr.getRunningScene, res.advID)
            NetInterface.sendWithBlock("GC_AutoJoinTeam_Ack", function()
                local TeamSend = require("src.Net.Send.TeamSend")
                TeamSend.sendCG_AutoJoinTeam_Req({adventureID=res.advID, leaderID=res.charID})
            end, nil, function(code)
                tInfo[TeamInfo.KEY_COMMITJOIN] = nil
                TipsMgr.showError(nil, code)
            end)
        end, function()
            refuseFunc()
        end)
end

function TeamInfo.receiveTeammemberUpdate(res)
    print("成员信息更变通知")
    for key, var in pairs(res) do
        print(key, var)
    end
    TeamInfo.updateTeamMemberData(nil, res)
end

function TeamInfo.receiveTeamKick(res)
    print("成员被踢通知")
    for key, var in pairs(res) do
        print(key, var)
    end
    if res.charID==CharInfo.getCharID() then
        if tInfo[TeamInfo.KEY_TEAMID] then
            TeamInfo.clearTeam()
            TeamViewMgr.checkTab(1)
            StandardTipsMgr.show(1, "team35")
            --DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "team35")
        end
    else
        if tInfo[TeamInfo.KEY_MEMBER] then
            local index, memberinfo = TeamInfo.getTeamMember(res.charID)
            if index and memberinfo then
                table.remove(tInfo[TeamInfo.KEY_MEMBER], index)
                StandardTipsMgr.show(1, CocosModuleMgr.createStringWithFormat({"team40", memberinfo.name}))
                for var=1, TeamViewMgr.TEAM_PLAYER_NUM do
                    TeamInfo.updateTeamMember(var, tInfo[TeamInfo.KEY_MEMBER][var])
                end
            end
        end
    end
end

function TeamInfo.receiveTeamSort(res)
    print("队伍顺序更变通知")
    for key, var in pairs(res) do
        print(key, var)
    end
    TeamInfo.updateTeamSort(res.teamSort)
end

function TeamInfo.receiveTeamCanautojoinChange(res)
    print("通用通知自动加入设置更变")
    for key, var in pairs(res) do
        print(key, var)
    end
    TeamInfo.updateJoinStatus(res.canAutoJoin==1)
end

function TeamInfo.receiveTeamChangeLeader(res)
    print("队长更变")
    for key, var in pairs(res) do
        print(key, var)
    end
    tInfo[TeamInfo.KEY_LEADERID] = res.newLeaderID
    local index, memberInfo = TeamInfo.getTeamMember(res.newLeaderID)
    if index and memberInfo then
        TeamInfo.updateTeamMemberData(index-1, memberInfo)
    end
    TeamViewMgr.refreshTeamMain()
end

function TeamInfo.receiveTeamRefuseJoin(res)
    print("邀请组队被拒")
    for key, var in pairs(res) do
        print(key, var)
    end
    StandardTipsMgr.show(1, CocosModuleMgr.createStringWithFormat({"team64", res.name}))
end

function TeamInfo.checkTeamWhenLogin(callback)
    local TeamSend = require("src.Net.Send.TeamSend")
    if CharInfo.get().teamid and CharInfo.get().teamid~=0 then
        NetInterface.sendWithBlock("GC_GetMyTeam_Ack", function()
            TeamSend.sendCG_GetMyTeam_Req({})
        end, function()
            if tInfo[TeamInfo.KEY_STATUS]==0 then
                --队伍未开始
                TeamViewMgr.show(SceneMgr.getRunningScene, tInfo[TeamInfo.KEY_ADVENTUREID], 2)
            else
                --队伍已开始
                TreasureBoxInfo.GetTreasureBoxData()
                TeamCopyMapMgr.cleanLocalCopyMapInfo()
                SceneMgr.replaceScene(SceneMgr.getRunningScene, "TeamCopyMapScene")
            end
        end, function(code)
            --TipsMgr.showError(nil, code)
            TeamInfo.exitTeam(callback)
            callback()
        end)
    else
        callback()
    end
end

function TeamInfo.checkTeamStatus()
    if TeamViewMgr.isTeamViewOpen() then
        if tInfo[TeamInfo.KEY_TEAMID] then
            NetInterface.sendWithBlock("GC_GetMyTeam_Ack", function()
                local TeamSend = require("src.Net.Send.TeamSend")
                TeamSend.sendCG_GetMyTeam_Req({})
            end, function()
                print("刷新队伍信息")
            end, function(code)
                TeamInfo.exitTeam(function()
                    TeamViewMgr.setTabA(true)
                end)
            end)
        end
	end
end

function TeamInfo.checkTeamMapStatus()
    if SceneMgr.currentScene == "TeamCopyMapScene" then
        local boxes = TeamCopyWinMgr.getBoxes()
        if boxes then
            TeamCopyWinMgr.show(SceneMgr.getRunningScene, boxes)
        else
            TeamCopyMapMgr.cleanLocalCopyMapInfo()
            TeamCopyInfo.GetTeamCopyMapInfo()
        end
    end
end

return TeamInfo