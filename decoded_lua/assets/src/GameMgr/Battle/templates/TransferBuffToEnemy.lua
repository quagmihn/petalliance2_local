local TransferBuffToEnemy = class("TransferBuffToEnemy", BattleTemplate)

function TransferBuffToEnemy:ctor(templateInfo)

    TransferBuffToEnemy.super.ctor(self, templateInfo)

end

function TransferBuffToEnemy:work(data, ownerPet, templateLevel)

    local tagName = data:getParamValue("buff名", templateLevel)

    local targetPet = BattleCotroller.getCurrentBattle():getEnemy(ownerPet)
    local buffList = ownerPet:getBuffsByTag(tagName)

    if (#buffList > 0) then
        for i = 1, #buffList do
            targetPet:addBuff(buffList[i])
        end

        ownerPet:removeBuffByTag(tagName)
    end

end

function TransferBuffToEnemy:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return TransferBuffToEnemy
