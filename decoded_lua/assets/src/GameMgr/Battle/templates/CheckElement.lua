local CheckElement = class("CheckElement", BattleTemplate)

function CheckElement:ctor(templateInfo)

    CheckElement.super.ctor(self,templateInfo)

end

function CheckElement:checkCondition(data, ownerPet, templateLevel)

    local enemy = BattleCotroller.getCurrentBattle():getEnemy(ownerPet)
    if enemy and ownerPet:getSelectedSkill() then
	    local res = BattleAidFunc.getAttributeStateValue(ownerPet:getSelectedSkill().info.id, enemy.pokeID)
	    if (res > 1.1) then
	        return true
	    end
	end
    return false

end

return CheckElement