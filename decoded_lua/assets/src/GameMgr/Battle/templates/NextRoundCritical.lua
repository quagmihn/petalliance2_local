local NextRoundCritical = class("NextRoundCritical", BattleTemplate)

function NextRoundCritical:ctor(templateInfo)

    NextRoundCritical.super.ctor(self, templateInfo)

end

function NextRoundCritical:work(data, ownerPet, templateLevel)

	ownerPet.nextRoundCritical = true
	
end

return NextRoundCritical