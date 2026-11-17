local ExtraAttackSpeed = class("ExtraAttackSpeed", ExtraAttackBase)

function ExtraAttackSpeed:ctor(templateInfo)

    ExtraAttackSpeed.super.ctor(self,templateInfo)

end

function ExtraAttackSpeed:work(data,ownerPet,templateLevel)

    local battle = BattleCotroller.getCurrentBattle()
    if battle.attackCount > 1 then
        return
    end
    
    local extraAttackCount = tonumber(data:getParamValue("追击次数",templateLevel)) + self:getExtraCount(data, ownerPet, templateLevel)
    extraAttackCount = self:getFinalCount(extraAttackCount, templateLevel)    
    battle.attackCount = battle.attackCount + extraAttackCount
    
end

function ExtraAttackSpeed:getSkillDesc(data, templateLevel)

    local rate = data:getParamValue("速度放大比", templateLevel)
    rate = BattleAidFunc.str2Percent(rate)
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["速度放大比"] = (rate*100).."%%"})

end

return ExtraAttackSpeed