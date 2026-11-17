local LimitSkill = class("LimitSkill", BattleTemplate)

function LimitSkill:ctor(templateInfo)

    LimitSkill.super.ctor(self,templateInfo)

end

function LimitSkill:work(data, ownerPet, templateLevel)

    local skillType = data:getParamValue("技能类型", templateLevel)
    skillType = BattleAidFunc.str2Enum(skillType)
    
    if nil == ownerPet.attributes.limitSkills then
        ownerPet.attributes.limitSkills = {}
    end
    ownerPet.attributes.limitSkills[skillType] = true

end

function LimitSkill:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return LimitSkill