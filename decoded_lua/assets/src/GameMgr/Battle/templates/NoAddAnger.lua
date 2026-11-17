local NoAddAnger = class("NoAddAnger", BattleTemplate)

function NoAddAnger:ctor(templateInfo)

    NoAddAnger.super.ctor(self,templateInfo)

end

function NoAddAnger:work(data,ownerPet,templateLevel) 
	-- print("NoAddAnger:work ",ownerPet.team.side) 
	BattleCotroller.getCurrentBattle():getEnemy(ownerPet).isAddAnger = false

end

function NoAddAnger:getSkillDesc(data, templateLevel)
    return BattleAidFunc.getSkillDesc(data, templateLevel)
end

return NoAddAnger