local BattleLogConfig = {}

local HDOS = require("Utils.HDOS")

local logHandle = nil

function BattleLogConfig.configPrerequisites()
	BattleLogConfig.battleLogFlag 			= true 	-- 战斗Log总开关

	BattleLogConfig.changePetLogFlag 		= true 	-- 更换宠物
	BattleLogConfig.roundLogFlag 			= true 	-- 回合 数
	BattleLogConfig.skillUseLogFlag 		= true 	-- 使用技能
	BattleLogConfig.triggerEffectLogFlag	= true 	-- 效果触发 
	BattleLogConfig.skillCalDamageLogFlag	= true 	-- 技能的CalDamage结果
	BattleLogConfig.damageResultLogFlag		= true 	-- 造成的伤害结果
	BattleLogConfig.bufferLogFlag 			= true 	-- buffer
	BattleLogConfig.killCountLogFlag 		= true 	-- 击杀统计
    BattleLogConfig.roundResult             = true  -- 回合数据统计 
    BattleLogConfig.passiveSkillTrigger     = false  -- 被动技能触发
    BattleLogConfig.skillDesc     = true  -- 技能描述  
    BattleLogConfig.fight     = true  -- 攻击  

	if (BattleLogConfig.battleLogFlag == false) then
		BattleLogConfig.changePetLogFlag 		= false 	-- 更换宠物
		BattleLogConfig.roundLogFlag 			= false 	-- 回合 数
		BattleLogConfig.skillUseLogFlag 		= false 	-- 使用技能
		BattleLogConfig.triggerEffectLogFlag	= false 	-- 效果触发 
		BattleLogConfig.skillCalDamageLogFlag	= false 	-- 技能的CalDamage结果
		BattleLogConfig.damageResultLogFlag		= false 	-- 造成的伤害结果
		BattleLogConfig.bufferLogFlag 			= false 	-- buffer
		BattleLogConfig.killCountLogFlag 		= false 	-- 击杀统计
        BattleLogConfig.roundResult             = false     -- 回合数据统计 
        BattleLogConfig.passiveSkillTrigger     = false     -- 被动技能触发
        BattleLogConfig.skillDesc     = false  -- 技能描述
        BattleLogConfig.fight     = false  -- 攻击
	end
end

function BattleLogConfig.writeFile(text)
	if (nil ~= text and "windows" == device.platform) then
		logHandle:write(text)
		logHandle:flush()
	end
end

if ("windows" == device.platform) then
	local filePath = "../../gameDebug.log"
	local fileError = nil
	logHandle, fileError = io.open(filePath, "w")
	if (nil ~= fileError) then
		print(fileError)
	end
	BattleLogConfig.writeFile("startGame in " .. os.date("%Y-%m-%d %H:%M:%S  ", os.time()) .. "\n\n\n")
end

function printFileLog(...)
	-- print(...)
	-- if ("windows" == device.platform) then
	-- 	local logText = os.date("%Y-%m-%d %H:%M:%S  ", os.time())
	-- 	for key, value in pairs({...}) do
	-- 		logText = logText .. "\t" .. tostring(value)
	-- 	end
	-- 	BattleLogConfig.writeFile(logText .. "\n")
	-- end
end

return BattleLogConfig