local ImmuneElementDefence = class("ImmuneElementDefence", BattleTemplate)

function ImmuneElementDefence:ctor(templateInfo)

    ImmuneElementDefence.super.ctor(self,templateInfo)

end

function ImmuneElementDefence:work(data, ownerPet, templateLevel)

    local enemy = BattleCotroller.getCurrentBattle():getEnemy(ownerPet)
    if (enemy.attributes.damageRateElement > 1) then
        enemy.attributes.damageRateElement = 1
    end

end

function ImmuneElementDefence:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return ImmuneElementDefence