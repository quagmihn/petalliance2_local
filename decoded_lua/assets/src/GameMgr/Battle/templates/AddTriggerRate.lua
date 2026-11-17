local AddTriggerRate = class("AddTriggerRate", BattleTemplate)

function AddTriggerRate:ctor(templateInfo)

    AddTriggerRate.super.ctor(self, templateInfo)
    
end

function AddTriggerRate:checkCondition(data, ownerPet, templateLevel)

    local triggerRate = BattleAidFunc.str2Percent(data:getParamValue("概率", templateLevel))
    return triggerRate*100
    
end

return AddTriggerRate