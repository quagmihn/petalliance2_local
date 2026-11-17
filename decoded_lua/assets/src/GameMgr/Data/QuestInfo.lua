local QuestInfo = {}

local NewQuestInfoConfig = nil
local FamilyQuestInfoConfig = nil
local PVPArenaQuestInfoConfig = nil
local curQuestDatas = {}
local dailyQuestDatas = {}
local finishedQuestIDs = {}
local isContinuousFinishing = false

local pvpArenaQuestDatas = {}

-- ios评论相关
QuestInfo.commentBeginTime  = nil
QuestInfo.IOSCommemtQuestID = nil

function QuestInfo.Init()
    if NewQuestInfoConfig==nil then
        NewQuestInfoConfig = require("src.DatReader.NewQuestInfoConfig")
        NewQuestInfoConfig.init()
    end
    if FamilyQuestInfoConfig==nil then
    	FamilyQuestInfoConfig = require("src.DatReader.FamilyQuestInfoConfig")
    	FamilyQuestInfoConfig.init()
    end
    if PVPArenaQuestInfoConfig==nil then
        PVPArenaQuestInfoConfig = require("src.DatReader.PVPArenaQuestInfoConfig")
        PVPArenaQuestInfoConfig.init()
    end
    --[[
    for var=1, NewQuestInfoConfig.getEntryCount() do
        local id = NewQuestInfoConfig.getEntryID(var)
        local data = NewQuestInfoConfig.readEntryByID(id)
        
        print(data.id,data.name,data.objectiveDesc,data.strongType,data.dailyQuestPower)
        for var=1, #data.objectiveList do
            local data = data.objectiveList[var]
            print(data.eventType,data.mainID,data.subID,data.numType,data.amount,data.queryType)
        end
    end]]
    
    curQuestDatas = {}
    dailyQuestDatas = {}
    finishedQuestIDs = {}
    isContinuousFinishing = false
    
    QuestInfo.IOSCommemtQuestID = SystemInfo.getGlobalConfigAddInfoByID(30001).values[1]
end

--[[
param.questID=Proto.parseDWORD(entry); -- 任务ID
param.status=Proto.parseBYTE(entry); -- 任务状态
param.updateTime=Proto.parseQWORD(entry); -- 任务更新时间
param.progressList=Proto.parseVector(entry,Proto.parseDWORD); -- 任务目标进度
]]
function QuestInfo.add(param)
    local newVec = {}
    
    local function __add(data)
        local qid = data.questID
        print("recv quest id:", qid)
        local qInfo = QuestInfo.getNewQuestInfoById(qid)
        if qInfo.type==Proto.QUEST_TYPE_EVERYDAY and qInfo.needVisable==1 then
            dailyQuestDatas[qid] = data
        else
            if data.status==Proto.QUEST_STATUS_DONE then
                finishedQuestIDs[qid] = true
            else
                if not curQuestDatas[qid] then
                    print("new mission", qid)
                    table.insert(newVec, data)
                end
                curQuestDatas[qid] = data
                if qInfo.needVisable==0 then
                    local params = qInfo.objectiveList[1]
                    local eType = params.eventType
                    if eType==19 then
                    	local advID = params.mainID
                        if QuestInfo.checkAdventureFinished(advID) then
                            print("hided mission is Finished", qid, advID)
                            data.progressList[1] = 1
                    	end
                    end
                end
            end
        end
    end
    
	for var=1, #param do
	    local qid = param[var].questID
	    if qid == QuestInfo.IOSCommemtQuestID then
            if device.platform == "ios" or device.platform == "windows" then
                __add(param[var])

                local cBeginTime = UserSettings.get("commentBeginTime", 15)
                if cBeginTime and cBeginTime ~= 0 then
                    print("local commentBeginTime", cBeginTime)
                    local pass = CharInfo.getServerTime() - cBeginTime
                    if pass >= 10 then
                        QuestInfo.sendQuestUpdate(QuestInfo.IOSCommemtQuestID, 1)
                    end
                    UserSettings.set({commentBeginTime = 0}, 15)
                end
	        end
        else
            __add(param[var])
	    end
	end
    MissionListMgr.addNewMission(newVec)
    GameGuideMgr.checkProcess()
    GameGuideMgr.checkProcessInTown()
    WorldMapMgr.checkMapMissionInfo()
end

function QuestInfo.update(param)
    local qid = param.questID
    if QuestInfo.getNewQuestInfoById(qid).type==Proto.QUEST_TYPE_EVERYDAY then
        dailyQuestDatas[qid] = param
    else
        if param.status==Proto.QUEST_STATUS_DONE then
            finishedQuestIDs[qid] = true
        else
            curQuestDatas[qid] = param
        end
    end
    MissionListMgr.updateMission(param)
    print("更新任务id:", param.questID, #param.progressList, "状态:", param.status)
    if SceneMgr.currentScene=="MainScene" or SceneMgr.currentScene=="TownScene" then
    	QuestInfo.checkAllQuestAndFinish()
    end
end

function QuestInfo.delete(questID)
    print("删除任务id", questID, type(questID))
    questID = tonumber(questID)
    if QuestInfo.getNewQuestInfoById(questID).type==Proto.QUEST_TYPE_EVERYDAY then
        dailyQuestDatas[questID].status = Proto.QUEST_STATUS_DONE
    else
        curQuestDatas[questID] = nil
        finishedQuestIDs[questID] = true
    end
end

--questID, status, updateTime, progressList(table)
function QuestInfo.getCurQuestInfos()
    local tmpVec = curQuestDatas
    return tmpVec
end

--questID, status, updateTime, progressList(table)
function QuestInfo.getDailyQuestInfos()
    local tmpVec = dailyQuestDatas
    return tmpVec
end

function QuestInfo.getMapSmallPointQuestInfos()
	local tmpVec = {}
    for key, var in pairs(curQuestDatas) do
        if not QuestInfo.checkQuestFinished(key) then
            local params = QuestInfo.getNewQuestInfoById(key).objectiveList[1]
            if params.eventType==18 then
                table.insert(tmpVec, {mapid=params.mainID, pid=params.subID})
            end
        end
    end
    return tmpVec
end

--获取当前引导任务id
function QuestInfo.getCurGuideID()
    for key, var in pairs(curQuestDatas) do
        local id = var.questID
        if var.status==Proto.QUEST_STATUS_NORMAL and QuestInfo.getNewQuestInfoById(id).strongType then
            if tonumber(QuestInfo.getNewQuestInfoById(id).strongType)==1 then
                return id
            end
        end
    end
    return nil
end

--获取当前引导任务ids
function QuestInfo.getCurGuideIDs()
    local vec = {}
    for key, var in pairs(curQuestDatas) do
        local id = var.questID
        if var.status==Proto.QUEST_STATUS_NORMAL and QuestInfo.getNewQuestInfoById(id).strongType then
            if tonumber(QuestInfo.getNewQuestInfoById(id).strongType)==1 then
                table.insert(vec, id)
            end
        end
    end
    table.sort(vec, function(a, b)
        if a>=30000 and b>=30000 then
            return a<b
        end
        if a<30000 and b<30000 then
            return a<b
        end
        return a>b
    end)
    return vec
end

--[[
data.id=Proto.parseDWORD(entry); -- 任务ID
data.name=Proto.parseString(entry); -- 任务名字
data.type=Proto.parseBYTE(entry); -- 任务类型
data.parentID=Proto.parseDWORD(entry); -- 上一级任务ID
data.childIDs=Proto.parseVector(entry,Proto.parseDWORD); -- 下一级任务ID
data.startTime=Proto.parseString(entry); -- 开始时间
data.endTime=Proto.parseString(entry); -- 结束时间
data.resetType=Proto.parseBYTE(entry); -- 重置类型
data.resetPeriod=Proto.parseWORD(entry); -- 重置周期
data.awardID=Proto.parseDWORD(entry); -- 奖励ID
data.icon=Proto.parseString(entry); -- 图标
data.desc=Proto.parseString(entry); -- 描述
data.objectiveDesc=Proto.parseString(entry); -- 目标描述
data.objectiveList=Proto.parseVector(entry,Proto.parseObjectiveInfo); -- 任务目标列表
    >data.eventType=Proto.parseWORD(entry); -- 目标事件类型
    >data.mainID=Proto.parseDWORD(entry); -- 目标主要ID
    >data.subID=Proto.parseDWORD(entry); -- 目标次要ID
    >data.finalID=Proto.parseDWORD(entry); -- 目标末位ID
    >data.numType=Proto.parseBYTE(entry); -- 目标数量类型
    >data.amount=Proto.parseDWORD(entry); -- 目标需要的数量
    >data.queryType=Proto.parseBYTE(entry); -- 状态查询类型
data.strongType=Proto.parseString(entry); -- 强制类型
data.buttonName=Proto.parseString(entry); -- 金币奖励
data.targetMapName=Proto.parseString(entry); -- 经验奖励
data.mcash=Proto.parseDWORD(entry); -- 钻石奖励
data.dailyQuestPower=Proto.parseDWORD(entry); -- 活跃度
data.awardIcon=Proto.parseString(entry); -- 奖励图标
data.unlockMapID=Proto.parseString(entry); -- 解锁地图id
data.needVisable=Proto.parseDWORD(entry); -- 显示
--]]
function QuestInfo.getNewQuestInfoById(id)
    return NewQuestInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- id
data.familyQuestType=Proto.parseDWORD(entry); -- 类型
data.name=Proto.parseString(entry); -- 名称
data.icon=Proto.parseString(entry); -- 图标
data.classType=Proto.parseDWORD(entry); -- 级别
data.level=Proto.parseDWORD(entry); -- 家族等级
data.charLevel=Proto.parseDWORD(entry); -- 家族等级
data.rate=Proto.parseDWORD(entry); -- 权重
data.desc=Proto.parseString(entry); -- 描述
data.params=Proto.parseVector(entry,Proto.parseDWORD); -- 参数
data.awardElements=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励元素
data.awardElementNums=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励数量
data.devotePoint=Proto.parseDWORD(entry); -- 贡献度
data.familyCoin=Proto.parseDWORD(entry); -- 公会徽章
--]]
function QuestInfo.getFamilyQuestInfoById(id)
    return FamilyQuestInfoConfig.readEntryByID(id)
end

function QuestInfo.getPVPArenaQuestInfoById(id)
    return PVPArenaQuestInfoConfig.readEntryByID(id)
end

--完成所有不可见任务
function QuestInfo.checkAllQuestAndFinish()
    print("QuestInfo.checkAllQuestAndFinish()")
    for key, var in pairs(curQuestDatas) do
        print("checkAllQuestAndFinish id:"..var.questID, "visible:"..QuestInfo.getNewQuestInfoById(var.questID).needVisable,
            "status"..var.status)
        if QuestInfo.getNewQuestInfoById(var.questID).needVisable==0 then
            if var.status==Proto.QUEST_STATUS_DONE then
                QuestInfo.delete(var.questID)
            else
                if QuestInfo.checkQuestFinished(var.questID) then
                    QuestInfo.sendQuestFinished(var.questID, true)
                    print(var.questID, "完成")
                    return true
                end
            end
        end
    end
    return false
end

function QuestInfo.checkQuestFinished(questID)
    local qInfo = QuestInfo.getNewQuestInfoById(questID)
    local processList = {}
    if curQuestDatas[questID] then
    	processList = curQuestDatas[questID].progressList
    elseif dailyQuestDatas[questID] then
        processList = dailyQuestDatas[questID].progressList
    end
    local curProcess = processList[1] or 0
    local needProcess = qInfo.objectiveList[1].amount
    if curProcess>=needProcess then
        return true
    end
    return false
end

function QuestInfo.sendQuestUpdate(questID, process, callback)
    print("任务进度请求刷新", questID, process)
    local questData = {}
    if curQuestDatas[questID] then
        if curQuestDatas[questID].status==Proto.QUEST_STATUS_NORMAL then
            questData = curQuestDatas[questID]
            questData.progressList = {process}
        else
            return false
        end
    else
        return false
    end
    local NewQuestSend = require("src.Net.Send.NewQuestSend")
    NetInterface.sendWithBlock("ZC_UpdateQuest_Ack", function()
        NewQuestSend.sendCZ_UpdateQuest_Req(questData)
    end, function()
        print("任务进度请求刷新成功", questID, process)
        curQuestDatas[questID] = questData
        if callback then
        	callback()
        end
    end, function(code)
    	TipsMgr.showError(nil, code)
    end)
    return true
end

function QuestInfo.sendQuestFinished(questID, checkNext, callback)
    if isContinuousFinishing then
        local qInfo = QuestInfo.getNewQuestInfoById(questID)
        if qInfo.strongType then
            if tonumber(qInfo.strongType)==1 then
                if curQuestDatas[questID] then
                    curQuestDatas[questID].progressList[1] = qInfo.objectiveList[1].amount
                elseif dailyQuestDatas[questID] then
                    dailyQuestDatas[questID].progressList[1] = qInfo.objectiveList[1].amount
                end
            end
        end
    	return false
    end
    local questData = {}
    if curQuestDatas[questID] then
        if curQuestDatas[questID].status==Proto.QUEST_STATUS_NORMAL then
            questData = curQuestDatas[questID]
            questData.status = Proto.QUEST_STATUS_DONE
        else
            return false
        end
    else
        return false
    end
    
    local function sendMission()
        local NewQuestSend = require("src.Net.Send.NewQuestSend")
        NetInterface.sendWithBlock("ZC_CommitQuest_Ack", function()
            curQuestDatas[questID] = questData
            NewQuestSend.sendCZ_CommitQuest_Req(questData.questID)
        end, function()
            local params = QuestInfo.getNewQuestInfoById(questData.questID).objectiveList[1]
            if params.eventType==18 then
                WorldMapMgr.removeEvent(params.mainID, params.subID)
            end
            print("quest ID:", questData.questID, "finished")
            isContinuousFinishing = false
            if callback then
            	callback()
            end
            if checkNext then
                QuestInfo.checkAllQuestAndFinish()
            end
        end, function(code)
            curQuestDatas[questID].status = Proto.QUEST_STATUS_NORMAL
            TipsMgr.showError(nil, code)
        end)
    end
    
    if checkNext then
        isContinuousFinishing = true
    end
    --[[
    local lockID = QuestInfo.getNewQuestInfoById(questID).unlockMapID
    if lockID then
        local LoginSend = require("src.Net.Send.LoginSend")
        if string.sub(lockID, 1, 1)=="q" then
            local tmpID = string.gsub(lockID, "q", "")
            lockID = tonumber(tmpID)
            if lockID then
                NetInterface.sendWithBlock("MC_ChangeInfo_Ack", function()
                    LoginSend.sendCM_ChangeInfo_Req({key="maplock", content=CharInfo.get().maplock.."-"..lockID})
                end, function()
                    CharInfo.set({maplock=CharInfo.get().maplock.."-"..lockID}, true)
                    sendMission()
                end, function(code)
                    TipsMgr.showError(nil, code)
                end)
            else
                sendMission()
            end
        elseif tonumber(lockID) then
            NetInterface.sendWithBlock("MC_ChangeInfo_Ack", function()
                LoginSend.sendCM_ChangeInfo_Req({key="maplock", content=lockID.."-"..CharInfo.get().missionlock})
            end, function()
                local passID = tonumber(lockID)-1
                local mapinfo = WorldMapInfo.getMapIDandMapPointByLockID(passID)
                if mapinfo and passID>1 then
                    for k, v in pairs(mapinfo) do
                        TaskWatcherManager.onPassXiaoJieDian({mapid=v.mapid, pid=v.pid})
                    end                    
                end
                CharInfo.set({maplock=lockID.."-"..CharInfo.get().missionlock}, true)
                sendMission()
            end, function(code)
                TipsMgr.showError(nil, code)
            end)
        else
            sendMission()
    	end
    else
        sendMission()
    end]]
    local lockID = QuestInfo.getNewQuestInfoById(questID).unlockMapID
    if lockID then
        if string.sub(lockID, 1, 1)=="q" then
            local tmpID = string.gsub(lockID, "q", "")
            lockID = tonumber(tmpID)
            if lockID then
                CharInfo.set({maplock=CharInfo.get().maplock.."-"..lockID}, true)
                sendMission()
            else
                sendMission()
            end
        elseif tonumber(lockID) then
            local passID = tonumber(lockID)-1
            local mapinfo = WorldMapInfo.getMapIDandMapPointByLockID(passID)
            if mapinfo and passID>1 then
                for k, v in pairs(mapinfo) do
                    TaskWatcherManager.onPassXiaoJieDian({mapid=v.mapid, pid=v.pid})
                end                    
            end
            CharInfo.set({maplock=lockID.."-"..CharInfo.get().missionlock}, true)
            sendMission()
        else
            sendMission()
        end
    else
        sendMission()
    end
    
    return true
end

function QuestInfo.checkProcessBeatMonster(detail)
--击杀X只宠物  21
--击杀X只指定宠物 22
    local questVec = {}
    
    if detail.result~=PLAYER_WIN then
        print("战斗失败，不计算击杀宠物。")
    	return
    end
    local enemyPokeIDVec = detail.enemy.pokeID
    local enemyNumVec = detail.enemy.num
    for var=1, #enemyPokeIDVec do
        local pokeID = enemyPokeIDVec[var]
        local num = enemyNumVec[var] or 0
        if (BattleLogConfig.killCountLogFlag == true) then
            print("击杀宠物统计     pokeID:", pokeID, "num:", num)
        end
        for key, var in pairs(curQuestDatas) do
            if not QuestInfo.checkQuestFinished(key) then
                local params = QuestInfo.getNewQuestInfoById(key).objectiveList[1]
                if params.eventType==21 then
                    local curProcess = var.progressList[1] or 0
                    table.insert(questVec, {qid=key, process=curProcess+num})
                end
                if params.eventType==22 and pokeID==params.mainID then
                    local curProcess = var.progressList[1] or 0
                    table.insert(questVec, {qid=key, process=curProcess+num})
                end
                print("任务类型：", params.eventType, params.mainID)
            end
        end
    end
    
    local i = 1
    local function sendUpdate()
        if questVec[i] then
            QuestInfo.sendQuestUpdate(questVec[i].qid, questVec[i].process, function()
                i = i+1
                sendUpdate()
            end)
        end
    end
    sendUpdate()
end

function QuestInfo.checkAdventureFinished(advID)
    local index = math.ceil(advID/10000)
	local starNum, starMax = AdvStarMgr.getWorldMapStarNum(advID%10000)
    return index<=starNum
end

function QuestInfo.checkProcessMapSmallPoint(mapId, pId)
--通关某个小节点 18
    for key, var in pairs(curQuestDatas) do
        if not QuestInfo.checkQuestFinished(key) then
            local params = QuestInfo.getNewQuestInfoById(key).objectiveList[1]
            if params.eventType==18 and mapId==params.mainID and pId==params.subID then
                return key
            end
        end
    end
    return nil
end

function QuestInfo.guideFunc(qid)
    local params = QuestInfo.getNewQuestInfoById(qid).objectiveList[1]
    print("任务类型：", params.eventType, params.mainID, params.subID)
    local eType = params.eventType
    local scene = SceneMgr.getRunningScene
    if eType==1 then
    	--打怪
        GameGuideMgr.checkScene("MainScene")
    elseif eType==2 then
        --收集道具
        ItemInfoViewMgr.show({id = params.mainID}, false)
    elseif eType==3 or eType==4 or eType==5 then
        --通关普通、精英、英雄副本
        GameGuideMgr.checkScene("MainScene")
    elseif eType==6 then
        --喂养宠物经验
        PetFormationMgr.show(scene)
    elseif eType==7 then
        --扭蛋抽奖
        GachaViewMgr.show(scene)
    elseif eType==8 then
        --捕捉宠物
        WorldMapMgr.searchAdventureNode(params.subID)
    elseif eType==9 then
        --竞技场挑战
        MapSeekerMgr.autoSeekPath("TownScene", "b7")
    elseif eType==10 then
        --赠送体力
        FriendsViewMgr.show(scene)
    elseif eType==11 then
        --购买金币
        ExchangeViewMgr.show(scene, ExchangeViewMgr.GCASHTYPE)
    elseif eType==12 or eType==13 or eType==14 or eType==15 then
        --宠物升星、宠物强化、宠物训练、宠物进化
        PetFormationMgr.show(scene)
    elseif eType==16 then
        --击杀世界BOSS活动
    elseif eType==17 then
        --购买体力
        ExchangeViewMgr.show(scene, ExchangeViewMgr.POWERTYPE)
    elseif eType==18 then
        --通关节点
        GameGuideMgr.checkScene("MainScene")
    elseif eType==19 then
        --通关副本
        WorldMapMgr.searchAdventureNode(params.mainID)--, math.ceil(params.mainID/10000))
    elseif eType==20 then
        --人物升级
    elseif eType==21 then
        --击败宠物
        GameGuideMgr.checkScene("MainScene")
    elseif eType==22 then
        --击败指定宠物
        WorldMapMgr.searchAdventureNode(params.subID)
    elseif eType==23 or eType==24 or eType==25 then
        --领取月卡、领取年卡、领取终身卡
        PurchaseViewMgr.show(scene)
    elseif eType==26 then
        --挑战千层塔
        ExploreViewMgr.show(scene)
    elseif eType==27 then
        --领主争夺
        StageBossListMgr.show(scene)
    elseif eType==28 then
        --技能合成
        SkillBookViewMgr.show(scene)
    elseif eType==29 or eType==30 or eType==32 or eType==33  then
        local petVec = PokemonInfo.getAllPets()
        local objID = nil
        for key, var in pairs(petVec) do
            if var.pokeID==params.mainID then
        		objID = var.objID
        		break
        	end
        end
        if objID then
            local tab = 1
            if eType==29 then
                --指定宠物强化
                tab = 2
            elseif eType==30 then
                --指定宠物升级
                tab = 1
            elseif eType==32 then
                --指定宠物升星
                tab = 3
            elseif eType==33 then
                --指定宠物进化
                tab = 4
            end
            PetEducationMgr.show(scene, objID, tab, nil)
        end
    elseif eType==31 then
        --任意宠物升级
        PetFormationMgr.show(scene)
    elseif eType==34 then
        --探索
        ExploreViewMgr.show(scene)
    elseif eType==35 then
        --收集宠物
        GameGuideMgr.checkScene("MainScene")
    elseif eType==36 then
        --点赞
        local val = SystemInfo.getGlobalConfigAddInfoByID(21006).values[1]
        if CharInfo.getLevel()>=val then
            FriendsViewMgr.show(scene)
        else
            StandardTipsMgr.show(1, "tips22")
        end
    elseif eType==37 or eType==38 then
        --养成引导特殊任务
        PetFormationMgr.show(scene)
    elseif eType==39 then
        --生活技能
        MapSeekerMgr.autoSeekPath("TownScene", "b3")
    elseif eType==40 then
        --家园相关
        local val = SystemInfo.getGlobalConfigAddInfoByID(21007).values[1]
        if CharInfo.getLevel()>=val then
            FamilyInfo.GoHome()
        else
            StandardTipsMgr.show(1, "tips22")
        end
    elseif eType==42 then
        --组队副本
        MapSeekerMgr.autoSeekPath("TownScene", "b8")
    elseif eType==43 then
        --苹果评论任务
        if device.platform == "ios" or device.platform == "windows" then
            iOSFunction.goToAppStore()
        end
    elseif eType==44 then
        --实验室科技订单
        MapSeekerMgr.autoSeekPath("LabScene", "trainstone")
    end
end

function QuestInfo.setPvpArenaQuestDatas(quests)
    pvpArenaQuestDatas = quests
end

function QuestInfo.getPvpArenaQuestDatas()
    return pvpArenaQuestDatas
end

return QuestInfo