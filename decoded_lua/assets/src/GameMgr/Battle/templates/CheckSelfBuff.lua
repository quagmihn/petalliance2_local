local CheckSelfBuff = class("CheckSelfBuff", BattleTemplate)

function CheckSelfBuff:ctor(templateInfo)

    CheckSelfBuff.super.ctor(self,templateInfo)

end

function CheckSelfBuff:checkCondition(data, ownerPet, templateLevel)

    local buffName = data:getParamValue("buff名", templateLevel)
    return ownerPet:hasBuffTag(buffName)

end

function CheckSelfBuff:getSkillDesc(data, templateLevel)
    
    local buffName = data:getParamValue("buff名", templateLevel)
    return buffName

end

return CheckSelfBuff