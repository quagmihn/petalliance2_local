local ContinuedCure = class("ContinuedCure", BattleTemplate)

function ContinuedCure:ctor(templateInfo)

    ContinuedCure.super.ctor(self, templateInfo)

end


function ContinuedCure:work(data, ownerPet, templateLevel)

    ownerPet:addBuffCure(ownerPet.triggerBuff.cureValue)

end

function ContinuedCure:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return ContinuedCure