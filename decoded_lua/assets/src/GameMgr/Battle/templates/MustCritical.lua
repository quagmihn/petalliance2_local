local MustCritical = class("MustCritical", BattleTemplate)

function MustCritical:ctor(templateInfo)

    MustCritical.super.ctor(self, templateInfo)

end

function MustCritical:work(data,ownerPet,templateLevel)

	BattleCotroller.getCurrentBattle().iscritical = true

end

function MustCritical:getSkillDesc(data, templateLevel)
    
    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return MustCritical