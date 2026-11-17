local ImmuneResurrect = class("ImmuneResurrect", BattleTemplate)

function ImmuneResurrect:ctor(templateInfo)

    ImmuneResurrect.super.ctor(self, templateInfo)
end

function ImmuneResurrect:work(data, ownerPet, templateLevel)

    ownerPet.immuneResurrect = true
    
end

return ImmuneResurrect