local RemoveCurBuff = class("RemoveCurBuff", BattleTemplate)

function RemoveCurBuff:ctor(templateInfo)

    RemoveCurBuff.super.ctor(self, templateInfo)

end

function RemoveCurBuff:work(data, ownerPet, templateLevel)

    ownerPet.triggerBuff:clearRound()

end

return RemoveCurBuff