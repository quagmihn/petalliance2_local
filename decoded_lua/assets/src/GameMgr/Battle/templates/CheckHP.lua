local CheckHP = class("CheckHP", BattleTemplate)

function CheckHP:ctor(templateInfo)

    CheckHP.super.ctor(self, templateInfo)

end

function CheckHP:checkCondition(data, ownerPet, templateLevel)

    local triggerTarget = data:getParamValue("对象", templateLevel)
    local operator = data:getParamValue("大小关系", templateLevel)
    local attRatio = BattleAidFunc.str2Percent(data:getParamValue("血量比例", templateLevel))
    local pet = ownerPet
    if triggerTarget == "敌方" then
        pet = BattleCotroller.getCurrentBattle():getEnemy(ownerPet)
    end
    local res = false
    if ("大于" == operator) then
        res = (pet.hp / pet:getMaxHP()) > attRatio
    elseif ("大于等于" == operator) then
        res = (pet.hp / pet:getMaxHP()) >= attRatio
    elseif ("小于" == operator) then
        res = (pet.hp / pet:getMaxHP()) < attRatio
    elseif ("小于等于" == operator) then
        res = (pet.hp / pet:getMaxHP()) <= attRatio
    elseif ("等于" == operator) then
        res = (pet.hp / pet:getMaxHP()) == attRatio
    end

    return res
    
end

return CheckHP