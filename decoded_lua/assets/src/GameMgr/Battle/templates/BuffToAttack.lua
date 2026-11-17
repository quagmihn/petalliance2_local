local BuffToAttack = class("BuffToAttack", BattleTemplate)

function BuffToAttack:ctor(templateInfo)

    BuffToAttack.super.ctor(self, templateInfo)

end

function BuffToAttack:work(data, ownerPet, templateLevel)

    local counts = 0
    for i = 1,#ownerPet.buffs do
        local buff = ownerPet.buffs[i]
        if false == buff.hide and buff:hasTag("有益") then
            counts = counts + 1
            --buff:clearRound()
        end
    end

    if counts > 0 then
        local param = data:getParamValue("转换参数", templateLevel)
        param = BattleAidFunc.str2Percent(param) 

        local atk = ownerPet:getAttribute(Proto.AT_ATK)*param*counts 
        ownerPet:addAttribute(Proto.AT_ATK, atk) 

        local satk = ownerPet:getAttribute(Proto.AT_SATK)*param*counts
        ownerPet:addAttribute(Proto.AT_SATK, satk)
    --else
        --ownerPet.triggerBuff:clearRound()
    end

end

function BuffToAttack:getSkillDesc(data, templateLevel)

    local param = data:getParamValue("转换参数", templateLevel)
    param = BattleAidFunc.str2Percent(param)

    local damageRatio = data:getParamValue("伤害比例", templateLevel)
    damageRatio = BattleAidFunc.str2Percent(damageRatio)

    return BattleAidFunc.getSkillDesc(data, templateLevel, {["转换参数"] = (param*100).."%%", ["伤害比例"] = (damageRatio*100).."%%"})

end

return BuffToAttack
