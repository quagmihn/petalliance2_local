local OnceCure = class("OnceCure", BattleTemplate)

function OnceCure:ctor(templateInfo)

    OnceCure.super.ctor(self, templateInfo)

end


function OnceCure:work(data, ownerPet, templateLevel)

    ownerPet:addBuffCure(ownerPet.triggerBuff.cureValue)
    
    ownerPet.triggerBuff:clearRound()

end

function OnceCure:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return OnceCure