local CheckUseSkillCount = class("CheckUseSkillCount", BattleTemplate)

function CheckUseSkillCount:ctor(templateInfo)

    CheckUseSkillCount.super.ctor(self,templateInfo)

end

function CheckUseSkillCount:checkCondition(data, ownerPet, templateLevel, id)

	local count = data:getParamValue("释放次数", templateLevel)
	count = tonumber(count)

	if nil ~= count and id then
		if count == ownerPet:getSkillUseCount(id) then
			return false
		else
			return true
		end
	end

	if (nil ~= count and ownerPet.triggerBuff and count == ownerPet:getSkillUseCount(ownerPet.triggerBuff.skillID)) then
		return true
	else
		return false
	end

end

function CheckUseSkillCount:getSkillDesc(data, templateLevel)
    
    local count = data:getParamValue("释放次数", templateLevel)
	count = tonumber(count)
    return count

end

return CheckUseSkillCount