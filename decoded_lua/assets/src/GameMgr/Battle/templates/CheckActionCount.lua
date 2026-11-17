local CheckActionCount = class("CheckActionCount", BattleTemplate)

function CheckActionCount:ctor(templateInfo)

    CheckActionCount.super.ctor(self,templateInfo)

end

function CheckActionCount:checkCondition(data, ownerPet, templateLevel)

    local count = data:getParamValue("行动次数", templateLevel)
    count = tonumber(count)

    if (nil ~= count) and (count == BattleCotroller.getCurrentBattle().currentAttackCount) then
        return true
    end
    return false
end

function CheckActionCount:getSkillDesc(data, templateLevel)

	local count = data:getParamValue("行动次数", templateLevel)
    count = tonumber(count)
    return count

end

return CheckActionCount