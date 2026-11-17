local Eca = require("Eca.Eca")
local HDVector = require("Utils.HDVector")
local questList = {}

local function getQuestCount()

	return #questList

end

local function getQuestDetail(idx)

	-- Proto_Quest_Types parseQuestDetail
	return questList[idx]

end

----------------------------------------

local function init()

	questList = {}
	HDVector.extend(questList)

end

local function onZC_QuestList_Ack(data)

	if (Proto.Error.ERROR_OK == data.code) then
		questList:copy(data.questList)
		Eca.dispatchEvent(ECA.OnQuestDataRefresh)
	end

end

local function onZC_NewQuest_Ntf(data)

	for i = 1, #data.questList do
		questList:push_back(data.questList[i])
	end
	Eca.dispatchEvent(ECA.OnQuestDataRefresh)

end

local function onZC_UpdateQuest_Ntf(data)

	for i = 1, #questList do
		if (questList[i].questID == data.quest.questID) then
			questList[i].status = data.quest.status
			questList[i].updateTime = data.quest.updateTime
			questList[i].progressList = data.quest.progressList
			break
		end
	end
	Eca.dispatchEvent(ECA.OnQuestDataRefresh)

end

local function onZC_DeleteQuest_Ntf(data)

	for i = 1, #questList do
		if (questList[i].questID == data.questID) then
			questList:erase(i)
			break
		end
	end
	Eca.dispatchEvent(ECA.OnQuestDataRefresh)

end

local QuestInfo = {
	getQuestCount = getQuestCount,
	getQuestDetail = getQuestDetail,

	init = init,
	onZC_QuestList_Ack = onZC_QuestList_Ack,
	onZC_NewQuest_Ntf = onZC_NewQuest_Ntf,
	onZC_UpdateQuest_Ntf = onZC_UpdateQuest_Ntf,
	onZC_DeleteQuest_Ntf = onZC_DeleteQuest_Ntf,
}
return QuestInfo