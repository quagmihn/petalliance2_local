local CheckFullHP = class("CheckFullHP", BattleTemplate)

function CheckFullHP:ctor(templateInfo)

    CheckFullHP.super.ctor(self,templateInfo)

end

function CheckFullHP:checkCondition(data, ownerPet, templateLevel)

    return (ownerPet.hp == ownerPet.attributes[Proto.AT_HP])

end

return CheckFullHP