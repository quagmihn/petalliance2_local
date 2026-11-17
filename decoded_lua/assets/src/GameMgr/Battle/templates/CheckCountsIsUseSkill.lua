local CheckCountsIsUseSkill = class("CheckCountsIsUseSkill", BattleTemplate)

function CheckCountsIsUseSkill:ctor(templateInfo)

    CheckCountsIsUseSkill.super.ctor(self,templateInfo)

end

function CheckCountsIsUseSkill:checkCondition(data, ownerPet, templateLevel, id)

	local count = data:getParamValue("使用次数", templateLevel)
	count = tonumber(count)

	if nil ~= count and id then
		if count <= ownerPet:getSkillUseCount(id) then
			return false
		else
			return true
		end
	end
	return false

end

function CheckCountsIsUseSkill:getSkillDesc(data, templateLevel)
    
    local count = data:getParamValue("释放次数", templateLevel)
	count = tonumber(count)
    return count

end

return CheckCountsIsUseSkill