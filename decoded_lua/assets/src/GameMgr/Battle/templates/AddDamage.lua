local AddDamage = class("AddDamage", BattleTemplate)

function AddDamage:ctor(templateInfo)

    AddDamage.super.ctor(self, templateInfo)

end

function AddDamage:work(data, ownerPet, templateLevel)

    local rate = data:getParamValue("增伤比例", templateLevel)
    rate = BattleAidFunc.str2Percent(rate)

    ownerPet.attributes.damageRate = ownerPet.attributes.damageRate + rate
    printFileLog(string.format("%s:个人增伤(AddDamage):增加伤害:%s", ownerPet.name, data:getParamValue("增伤比例", templateLevel)))
    
end

function AddDamage:getSkillDesc(data, templateLevel)

    local rate = data:getParamValue("增伤比例", templateLevel)
    rate = BattleAidFunc.str2Percent(rate)
    
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["增伤比例"] = (rate*100).."%%"})

end

return AddDamage