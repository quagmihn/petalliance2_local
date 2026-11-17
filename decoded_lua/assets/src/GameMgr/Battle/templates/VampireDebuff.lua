local VampireDebuff = class("VampireDebuff", BattleTemplate)

function VampireDebuff:ctor(templateInfo)

    VampireDebuff.super.ctor(self, templateInfo)

    self.damageVal = 0

end

function VampireDebuff:work(data, ownerPet, templateLevel)

    local damageRatio = data:getParamValue("伤害比例", templateLevel)
    damageRatio = BattleAidFunc.str2Percent(damageRatio)

    local counts = 0
    for i = 1,#ownerPet.buffs do
        local buff = ownerPet.buffs[i]
        if false == buff.hide and buff:hasTag("有害") then
            counts = counts + 1
        end
    end
    
    local value = BattleCotroller.getCurrentBattle().finaldamage * damageRatio*counts*ownerPet:getAttribute(Proto.AT_HEALRATE)/1000
    value = BattleAidFunc.normalize(value)
    
    ownerPet:addBuffCure(value)

end

function VampireDebuff:getSkillDesc(data, templateLevel)

    local damageRatio = data:getParamValue("伤害比例", templateLevel)
    damageRatio = BattleAidFunc.str2Percent(damageRatio)
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["伤害比例"] = (damageRatio*100).."%%"})

end

return VampireDebuff