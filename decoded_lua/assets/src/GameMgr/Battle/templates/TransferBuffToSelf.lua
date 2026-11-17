local TransferBuffToSelf = class("TransferBuffToSelf", BattleTemplate)

function TransferBuffToSelf:ctor(templateInfo)

    TransferBuffToSelf.super.ctor(self, templateInfo)

end

function TransferBuffToSelf:work(data, ownerPet, templateLevel)

    local tagName = data:getParamValue("buff名", templateLevel)

    local targetPet = BattleCotroller.getCurrentBattle().attackTarget
    local buffList = targetPet:getBuffsByTag(tagName)

    if (#buffList > 0) then
        for i = 1, #buffList do
            ownerPet:addBuff(buffList[i])
        end

        targetPet:removeBuffByTag(tagName)
    end

end

function TransferBuffToSelf:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return TransferBuffToSelf