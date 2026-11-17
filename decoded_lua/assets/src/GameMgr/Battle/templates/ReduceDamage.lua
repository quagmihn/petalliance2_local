local ReduceDamage = class("ReduceDamage", BattleTemplate)

function ReduceDamage:ctor(templateInfo)

    ReduceDamage.super.ctor(self, templateInfo)

end

function ReduceDamage:work(data, ownerPet, templateLevel)
    
    local rate = data:getParamValue("减伤比例", templateLevel)
    rate = BattleAidFunc.str2Percent(rate)
   
    BattleCotroller.getCurrentBattle():getEnemy(ownerPet).attributes.damageRate = BattleCotroller.getCurrentBattle():getEnemy(ownerPet).attributes.damageRate - rate
    printFileLog(string.format("%s:个人减伤(ReduceDamage):减少伤害:%s", ownerPet.name, data:getParamValue("减伤比例", templateLevel))) 
    
end

function ReduceDamage:getSkillDesc(data, templateLevel)

    local rate = data:getParamValue("减伤比例", templateLevel)
    rate = BattleAidFunc.str2Percent(rate)
    
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["减伤比例"] = (rate*100).."%%"})

end

return ReduceDamage