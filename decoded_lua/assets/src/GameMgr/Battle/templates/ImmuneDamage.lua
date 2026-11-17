local ImmuneDamage = class("ImmuneDamage", BattleTemplate)

function ImmuneDamage:ctor(templateInfo)
    ImmuneDamage.super.ctor(self,templateInfo)
--    self:registerEvent(USE_SKILL,ImmuneDamage.useSkillOnSelf)
--    self:registerEvent(AFTER_DEFENCE,ImmuneDamage.afterDefence)
    -- self:registerEvent(GET_SKILL_DESC, ImmuneDamage.getSkillDesc)
end

function ImmuneDamage:work(data,ownerPet,templateLevel)

    if ATTACK_ATTACK ~= BattleCotroller.getCurrentBattle().attackType then
        return false
    end
    local dmgType = data:getParamValue("伤害类型",templateLevel)
    if (("物理伤害" == dmgType and 3 == BattleCotroller.getCurrentBattle().attackPet:getSelectedSkill().info.skill_B_Type)
    	or ("魔法伤害" == dmgType and 4 == BattleCotroller.getCurrentBattle().attackPet:getSelectedSkill().info.skill_B_Type)) then
    	if not BattleCotroller.getCurrentBattle().attackPet.attributes.ignoreDef then
            BattleCotroller.getCurrentBattle().finaldamage = 0
        end
    end

end

function ImmuneDamage:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return ImmuneDamage