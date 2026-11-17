local ReduceAnger = class("ReduceAnger", BattleTemplate)

function ReduceAnger:ctor(templateInfo)

    ReduceAnger.super.ctor(self, templateInfo)
    
end

function ReduceAnger:work(data, ownerPet, templateLevel)

    local val = tonumber(data:getParamValue("减少量", templateLevel))
    if (nil == val) then
        return
    end
    BattleCotroller.getCurrentBattle():getEnemy(ownerPet):reduceAngerDirectly(val)

end

function ReduceAnger:getSkillDesc(data, templateLevel)

    local val = tonumber(data:getParamValue("减少量", templateLevel))
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["减少量"] = val})

end

return ReduceAnger