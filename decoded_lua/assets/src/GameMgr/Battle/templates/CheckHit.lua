local CheckHit = class("CheckHit", BattleTemplate)

function CheckHit:ctor(templateInfo)

    CheckHit.super.ctor(self,templateInfo)

end

function CheckHit:checkCondition(data, ownerPet, templateLevel)

    return (not BattleCotroller.getCurrentBattle().miss)

end

return CheckHit