local AddDamageRate = class("AddDamageRate", BattleTemplate)

function AddDamageRate:ctor(templateInfo)

    AddDamageRate.super.ctor(self, templateInfo)
    
end

function AddDamageRate:work(data, ownerPet, templateLevel)

    local rate = data:getParamValue("加成比例", templateLevel)
    rate = BattleAidFunc.str2Percent(rate)
    
    ownerPet.attributes.damageRate = ownerPet.saveAttributes.damageRate + rate
    printFileLog(string.format("%s:提高技能效果(AddDamageRate):加成比例:%s", ownerPet.name, data:getParamValue("加成比例", templateLevel)))

    return true
    
end

function AddDamageRate:getSkillDesc(data, templateLevel)

    local rate = data:getParamValue("加成比例", templateLevel)
    rate = BattleAidFunc.str2Percent(rate)
    
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["加成比例"] = (rate*100).."%%"})

end

return AddDamageRate