local MustEvade = class("MustEvade", BattleTemplate)

function MustEvade:ctor(templateInfo)

    MustEvade.super.ctor(self,templateInfo)

    -- self:registerEvent(USE_SKILL, MustEvade.useSkillOnSelf)
    -- self:registerEvent(BEFORE_DEFENCE, MustEvade.beforeDefence)

end

-- function MustEvade:useSkillOnSelf(data, ownerPet, templateLevel)

--     MustEvade.super:useSkillOnSelf(data, ownerPet, templateLevel)
--     -- ownerPet.preAddBuff.hide = true

-- end

function MustEvade:work(data, ownerPet, templateLevel)

	if (false == BattleCotroller.getCurrentBattle().mustHit) then
		BattleCotroller.getCurrentBattle().miss = true
	end

end

function MustEvade:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return MustEvade