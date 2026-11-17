local AttConvert = class("AttConvert", BattleTemplate)

function AttConvert:ctor(templateInfo)

    AttConvert.super.ctor(self, templateInfo)

end

function AttConvert:work(data, ownerPet, templateLevel)

    local attTypeDown = data:getParamValue("减少属性", templateLevel)
    local attTypeUp = data:getParamValue("增加属性", templateLevel)
    local attReduceRatio = data:getParamValue("减少比例", templateLevel)
    attReduceRatio = BattleAidFunc.str2Percent(attReduceRatio)

    local attEnumDown = BattleAidFunc.str2Enum(attTypeDown)
    local attEnumUp = BattleAidFunc.str2Enum(attTypeUp)
    local attValDown = ownerPet:getAttribute(attEnumDown)
    local attValUp = ownerPet:getAttribute(attEnumUp)

    if (nil == ownerPet:getAttribute(attEnumDown) or nil == ownerPet:getAttribute(attEnumUp)) then
        printError("AttConvert:buffActive() can not find attribute of " .. attEnumDown..attEnumUp)
    end

    local addVal = attValDown * attReduceRatio
    ownerPet:setAttribute(attEnumDown, attValDown * (1-attReduceRatio))
    ownerPet:addAttribute(attEnumUp,addVal)
    printFileLog(string.format("%s:属性变化(AttConvert):%s %d->%d", ownerPet.name, attTypeUp, attValUp, ownerPet:getAttribute(attEnumUp)))
    printFileLog(string.format("%s:属性变化(AttConvert):%s %d->%d", ownerPet.name, attTypeDown, attValDown, ownerPet:getAttribute(attEnumDown)))
end

function AttConvert:getSkillDesc(data, templateLevel)

    local rate = data:getParamValue("减少比例", templateLevel)
    rate = BattleAidFunc.str2Percent(rate)
    
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["减少比例"] = (rate*100).."%%"})

end

return AttConvert