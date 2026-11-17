local CheckGetDamage = class("CheckGetDamage", BattleTemplate)

function CheckGetDamage:ctor(templateInfo)

    CheckGetDamage.super.ctor(self,templateInfo)

end

function CheckGetDamage:checkCondition(data, ownerPet, templateLevel,id,isOpponent)
	local isResult = false
	if isOpponent then
		isResult = true
	end
    if (ownerPet.roundDamage > 0) then
    	if isOpponent then
			return false
		end
        return true
    end
    return isResult

end

return CheckGetDamage