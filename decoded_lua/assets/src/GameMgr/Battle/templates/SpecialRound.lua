local SpecialRound = class("SpecialRound", BattleTemplate)

function SpecialRound:ctor(templateInfo)

    SpecialRound.super.ctor(self, templateInfo)
    
end

function SpecialRound:checkCondition(data, ownerPet, templateLevel)

    local triggerRound = tonumber(data:getParamValue("回合", templateLevel))
    local round = BattleCotroller.getCurrentBattle():getBattleRound()
    if round%triggerRound == 0 then
    	return true
    end
    return false
    
end


return SpecialRound