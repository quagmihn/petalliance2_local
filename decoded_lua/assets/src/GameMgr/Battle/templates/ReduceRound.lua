local ReduceRound = class("ReduceRound", BattleTemplate)

function ReduceRound:ctor(templateInfo)

    ReduceRound.super.ctor(self, templateInfo)

end

function ReduceRound:work(data, ownerPet, templateLevel)

    for i = 1,#ownerPet.buffs do
        local buff = ownerPet.buffs[i]
        if (false==buff.hide) and (buff:hasTag("有害")) then
            buff:reduceRound(1)
        end
    end

    ownerPet.triggerBuff:clearRound()

end

return ReduceRound