local RefreshSelfBuffRound = class("RefreshSelfBuffRound", BattleTemplate)

function RefreshSelfBuffRound:ctor(templateInfo)

    RefreshSelfBuffRound.super.ctor(self, templateInfo)

end

function RefreshSelfBuffRound:work(data,ownerPet,templateLevel)

    local tagName = data:getParamValue("buff名", templateLevel)
    ownerPet:resetBuffsRoundByTag(tagName)

end

function RefreshSelfBuffRound:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return RefreshSelfBuffRound