local CountReduce = class("CountReduce", BattleTemplate)

function CountReduce:ctor(templateInfo)

    CountReduce.super.ctor(self, templateInfo)

end

function CountReduce:work(data, ownerPet, templateLevel)

    ownerPet.triggerBuff:reduceRound(1)

end

return CountReduce