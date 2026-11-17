local AddDebuffRound = class("AddDebuffRound", BattleTemplate)

function AddDebuffRound:ctor(templateInfo)

    AddDebuffRound.super.ctor(self, templateInfo)

end

function AddDebuffRound:work(data, ownerPet, templateLevel)

    local buffName = data:getParamValue("buff名", templateLevel)
    local addRound = data:getParamValue("延长回合", templateLevel)

    local enemyPet = BattleCotroller.getCurrentBattle():getEnemy(ownerPet)
    for i = 1, #enemyPet.buffs do
        for j = 1, #enemyPet.buffs[i].info.tags do
            if (buffName == enemyPet.buffs[i].info.tags[j]) then
                enemyPet.buffs[i]:addRound(addRound)
                break
            end
        end
    end

end

function AddDebuffRound:getSkillDesc(data, templateLevel)
    
    local addRound = data:getParamValue("延长回合", templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel, {["延长回合"] = addRound})

end

return AddDebuffRound