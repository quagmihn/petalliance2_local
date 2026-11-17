local NextCritical = class("NextCritical", BattleTemplate)

function NextCritical:ctor(templateInfo)

    NextCritical.super.ctor(self, templateInfo)

end

function NextCritical:work(data, ownerPet, templateLevel)

	ownerPet.nextCritical = true

end

return NextCritical