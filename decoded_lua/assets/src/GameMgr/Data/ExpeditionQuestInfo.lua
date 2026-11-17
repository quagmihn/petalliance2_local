local ExpeditionQuestInfo = {}
local ExpeditionQuestInfoConfig       = nil

ExpeditionQuestInfo.USE_PETS   = 1
ExpeditionQuestInfo.USE_TYPE   = 2
ExpeditionQuestInfo.LESS_ROUND = 3
ExpeditionQuestInfo.PET_LEVEL  = 4

local questID    = 1
local awardID    = 2
local awardCount = 3 

ExpeditionQuestInfo.commonFunctions = {}


function ExpeditionQuestInfo.usePetsQuest(id) 
	local questInfo = ExpeditionQuestInfo:getExpeditionQuestInfoById(id)  
	local battle    = BattleCotroller.getCurrentBattle()
	local result  =  {true,{[questID] = id,
						[awardID] = questInfo.awardID,
						[awardCount] = questInfo.awardCount}}
	if battle then
	end
	return result
end 

function ExpeditionQuestInfo.useTypeQuest(id)
	local questInfo = ExpeditionQuestInfo:getExpeditionQuestInfoById(id)
	local battle    = BattleCotroller.getCurrentBattle()
	local result  =  {true,{[questID] = id,
						[awardID] = questInfo.awardID,
						[awardCount] = questInfo.awardCount}}

	if battle then
		local pets = battle:getPetsInfo(TEAM_A)
		local pet  = pets[OUTPETS][1]
		local info = PokemonInfo.getPokemonInfoByID(pet.pokeID)
		if info.elementAtt1 == questInfo.param or info.elementAtt2 == questInfo.param then
			result[1] = true
		else
			result[1] = false
		end
	end
	return result
end

function ExpeditionQuestInfo.lessRoundQuest(id)
	local questInfo = ExpeditionQuestInfo:getExpeditionQuestInfoById(id)
	local battle    = BattleCotroller.getCurrentBattle()
	local result  =  {true,{[questID] = id,
						[awardID] = questInfo.awardID,
						[awardCount] = questInfo.awardCount}}

	if battle then
		local round = battle:getBattleRound()
		if round <= questInfo.param then
			result[1] = true
		else
			result[1] = false
		end
	end
	
	return result
end

function ExpeditionQuestInfo.petLevelQuest(id)
	local questInfo = ExpeditionQuestInfo:getExpeditionQuestInfoById(id)
	local battle    = BattleCotroller.getCurrentBattle()
	local result  =  {true,{[questID] = id,
						[awardID] = questInfo.awardID,
						[awardCount] = questInfo.awardCount}}

	if battle then
		local pets = battle:getPetsInfo(TEAM_A)
		local pet  = pets[OUTPETS][1]

		if pet.level <=  questInfo.param then
			result[1] = true
		else
			result[1] = false
		end
	end

	
	return result
end

function ExpeditionQuestInfo.init()
	if not ExpeditionQuestInfoConfig then
        ExpeditionQuestInfoConfig = require("src.DatReader.ExpeditionQuestInfoConfig")
        ExpeditionQuestInfoConfig.init()
    end

    local usePetsQuest 		= ExpeditionQuestInfo.usePetsQuest
    local useTypeQuest 		= ExpeditionQuestInfo.useTypeQuest
    local lessRoundQuest 	= ExpeditionQuestInfo.lessRoundQuest
    local petLevelQuest     = ExpeditionQuestInfo.petLevelQuest

    ExpeditionQuestInfo.commonFunctions = {
    	[ExpeditionQuestInfo.USE_PETS] 		= usePetsQuest,
    	[ExpeditionQuestInfo.USE_TYPE] 		= useTypeQuest,
    	[ExpeditionQuestInfo.LESS_ROUND] 	= lessRoundQuest,
    	[ExpeditionQuestInfo.PET_LEVEL]		= petLevelQuest,
	}
end


-- data.id=Proto.parseDWORD(entry); -- ID
-- data.type=Proto.parseDWORD(entry); -- 类型
-- data.param=Proto.parseDWORD(entry); -- 参数
-- data.awardID=Proto.parseDWORD(entry); -- 奖励ID
-- data.awardCount=Proto.parseDWORD(entry); -- 奖励个数
function ExpeditionQuestInfo:getExpeditionQuestInfoById(id)
    return ExpeditionQuestInfoConfig.readEntryByID(id)
end

return ExpeditionQuestInfo