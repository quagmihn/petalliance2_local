local ChangeTarget = class("ChangeTarget", BattleTemplate)

function ChangeTarget:ctor(templateInfo)

    ChangeTarget.super.ctor(self, templateInfo)

end

function ChangeTarget:work(data, ownerPet, templateLevel)
    
    if Proto.eST_Normal ~= ownerPet.triggerSkill.info.skill_A_Type
        and Proto.eST_Genius ~= ownerPet.triggerSkill.info.skill_A_Type
        and Proto.eST_Profound ~= ownerPet.triggerSkill.info.skill_A_Type then
        return
    end

    if (nil == ownerPet.selectedSkill) then
        return
    end
    
    local rate = data:getParamValue("混乱概率", templateLevel)
    rate = BattleAidFunc.str2Percent(rate) * 100
    local hit = GetRandom.random(0,99)
    if (hit >= rate) then--判断是否命中
        printFileLog(string.format("%s:混乱效果不触发!(%d >= %d)", ownerPet.name,hit,rate))
        return
    end
    
    BattleCotroller.getCurrentBattle().attackTarget = ownerPet
    BattleCotroller.getCurrentBattle().attackType = ATTACK_CHAOS
    BattleCotroller.getCurrentBattle():fight(1)
    ownerPet.canUseSkill = false

end

function ChangeTarget:getSkillDesc(data, templateLevel)

    local rate = data:getParamValue("混乱概率", templateLevel)
    rate = BattleAidFunc.str2Percent(rate)

    return BattleAidFunc.getSkillDesc(data, templateLevel, {["混乱概率"] = (rate*100).."%%"})

end

return ChangeTarget