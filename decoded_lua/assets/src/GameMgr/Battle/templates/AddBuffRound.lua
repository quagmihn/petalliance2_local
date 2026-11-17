local AddBuffRound = class("AddBuffRound", BattleTemplate)

function AddBuffRound:ctor(templateInfo)

    AddBuffRound.super.ctor(self, templateInfo)

end

function AddBuffRound:work(data, ownerPet, templateLevel)

    local buffName = data:getParamValue("buff名", templateLevel)
    local addRound = data:getParamValue("延长回合", templateLevel)
    printFileLog("addRound", addRound)

    for i = 1, #ownerPet.buffs do
        for j = 1, #ownerPet.buffs[i].info.tags do
            if (buffName == ownerPet.buffs[i].info.tags[j]) then
                ownerPet.buffs[i]:addRound(addRound)
                break
            end
        end
    end

end

function AddBuffRound:getSkillDesc(data, templateLevel)
    
    local addRound = data:getParamValue("延长回合", templateLevel)
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["延长回合"] = addRound})

end

return AddBuffRound