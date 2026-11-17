local ExchangeBuff = class("ExchangeBuff", BattleTemplate)

function ExchangeBuff:ctor(templateInfo)

    ExchangeBuff.super.ctor(self, templateInfo)

end

function ExchangeBuff:work(data, ownerPet, templateLevel)

    local buffs = clone(ownerPet.buffs)

    local targetPet = BattleCotroller.getCurrentBattle():getEnemy(ownerPet)
    local targetBuffs = clone(targetPet.buffs)

    for i = 1,#ownerPet.buffs do
        local buff = ownerPet.buffs[i]
        if false == buff.hide then
            buff:clearRound()
        end
    end

    for i = 1,#targetPet.buffs do
        local buff = targetPet.buffs[i]
        if false == buff.hide then
            buff:clearRound()
        end
    end

    if (#buffs > 0) then
        for i = 1, #buffs do
            local buff = buffs[i]
            if false == buff.hide then
                targetPet:addBuff(buff)
            end
        end
    end

    if (#targetBuffs > 0) then
        for i = 1, #targetBuffs do
            local buff = targetBuffs[i]
            if false == buff.hide then
                ownerPet:addBuff(buff)
            end
        end
    end

end

function ExchangeBuff:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return ExchangeBuff
