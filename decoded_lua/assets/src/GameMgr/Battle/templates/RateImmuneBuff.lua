local RateImmuneBuff = class("RateImmuneBuff", BattleTemplate)

function RateImmuneBuff:ctor(templateInfo)

    RateImmuneBuff.super.ctor(self,templateInfo)

end

function RateImmuneBuff:work(data, ownerPet, templateLevel)

    local tag = data:getParamValue("免疫类型", templateLevel)

    local rate = data:getParamValue("概率", templateLevel)
    rate = BattleAidFunc.str2Percent(rate)*100
    local hit = GetRandom.random(0,99)

    if (true == ownerPet.currentAddBuff:hasTag(tag)) and hit < rate then
        ownerPet.canAddBuff = false
    end

end

function RateImmuneBuff:getSkillDesc(data, templateLevel)

    local rate = data:getParamValue("概率", templateLevel)
    rate = BattleAidFunc.str2Percent(rate)
    
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["概率"] = (rate*100).."%%"})

end

return RateImmuneBuff