local ExtraAttack = class("ExtraAttack", BattleTemplate)

function ExtraAttack:ctor(templateInfo)

    ExtraAttack.super.ctor(self,templateInfo)

end

function ExtraAttack:work(data,ownerPet,templateLevel)

    local battle = BattleCotroller.getCurrentBattle()
    if battle.attackCount > 1 then
        return
    end
    battle.attackCount = battle.attackCount + tonumber(data:getParamValue("追击次数",templateLevel))
end


function ExtraAttack:getSkillDesc(data, templateLevel)

    local ExtraAttackCount = data:getParamValue("追击次数",templateLevel)
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["追击次数"] = ExtraAttackCount})

end

return ExtraAttack