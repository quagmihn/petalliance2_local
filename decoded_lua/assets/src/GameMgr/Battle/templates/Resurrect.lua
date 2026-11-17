local Resurrect = class("Resurrect", BattleTemplate)

function Resurrect:ctor(templateInfo)

    Resurrect.super.ctor(self, templateInfo)
end

function Resurrect:work(data, ownerPet, templateLevel)

    BattleCotroller.getCurrentBattle().attackTarget = ownerPet
    BattleCotroller.getCurrentBattle().attackType = ATTACK_CURE

    local cureRatio = data:getParamValue("复活恢复血量", templateLevel)
    if cureRatio == nil then
        return
    end
    local cureRatio = BattleAidFunc.str2Percent(cureRatio)
    local cureVal = ownerPet.attributes[Proto.AT_HP] * cureRatio
    ownerPet:addBuffCure(cureVal)
    
end

function Resurrect:getSkillDesc(data, templateLevel)
    
    local cureRatio = data:getParamValue("复活恢复血量", templateLevel)
    cureRatio = BattleAidFunc.str2Percent(cureRatio)

    return BattleAidFunc.getSkillDesc(data, templateLevel, {["复活恢复血量"] = (cureRatio*100).."%%"})

end

return Resurrect