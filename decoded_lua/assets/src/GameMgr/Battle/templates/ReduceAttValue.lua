local ReduceAttValue = class("ReduceAtt", BattleTemplate)

function ReduceAttValue:ctor(templateInfo)

    ReduceAttValue.super.ctor(self, templateInfo)

end

function ReduceAttValue:work(data, ownerPet, templateLevel)

    local attType = data:getParamValue("减弱属性", templateLevel)
    local attEnum = BattleAidFunc.str2Enum(attType)
    if (nil == ownerPet:getAttribute(attEnum)) then
        printError("ReduceAtt:buffActive() can not find attribute of " .. attType)
    end

    local attAdjust = data:getParamValue("强度修正", templateLevel)

    local attVal = ownerPet:getAttribute(attEnum)
    local reduceValue = attVal - attAdjust
    ownerPet:reduceAttribute(attEnum, reduceValue)  
    printFileLog(string.format("%s:属性变化(ReduceAtt):%s %d->%d", ownerPet.name, attType, attVal, ownerPet:getAttribute(attEnum)))

end

function ReduceAttValue:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return ReduceAttValue