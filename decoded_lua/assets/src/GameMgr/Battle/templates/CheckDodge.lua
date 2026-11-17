local CheckDodge = class("CheckDodge", BattleTemplate)

function CheckDodge:ctor(templateInfo)

    CheckDodge.super.ctor(self,templateInfo)

end

function CheckDodge:checkCondition(data, ownerPet, templateLevel)

    return BattleCotroller.getCurrentBattle().miss

end

return CheckDodge