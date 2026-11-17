local CheckCritical = class("CheckCritical", BattleTemplate)

function CheckCritical:ctor(templateInfo)

    CheckCritical.super.ctor(self,templateInfo)

end

function CheckCritical:checkCondition(data, ownerPet, templateLevel)

    return BattleCotroller.getCurrentBattle().iscritical

end

return CheckCritical