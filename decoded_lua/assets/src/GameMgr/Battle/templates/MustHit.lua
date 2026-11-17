local MustHit = class("MustHit", BattleTemplate)

function MustHit:ctor(templateInfo)

    MustHit.super.ctor(self,templateInfo)

    -- self:registerEvent(USE_SKILL, MustHit.useSkillOnSelf)
    -- self:registerEvent(BEFORE_ATTACK, MustHit.beforeAttack)

end

-- function MustHit:useSkillOnSelf(data, ownerPet, templateLevel)

--     MustHit.super:useSkillOnSelf(data, ownerPet, templateLevel)
--     -- ownerPet.preAddBuff.hide = true

-- end

function MustHit:work(data, ownerPet, templateLevel)

	BattleCotroller.getCurrentBattle().mustHit = true

end

function MustHit:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return MustHit