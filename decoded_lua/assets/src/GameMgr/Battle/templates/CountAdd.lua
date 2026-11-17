local CountAdd = class("CountAdd", BattleTemplate)

function CountAdd:ctor(templateInfo)

    CountAdd.super.ctor(self, templateInfo)

end

function CountAdd:work(data, ownerPet, templateLevel)

    ownerPet.triggerBuff:addRound(1)

end

return CountAdd