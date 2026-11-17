local EmptyTemplate = class("EmptyTemplate", BattleTemplate)

function EmptyTemplate:ctor(templateInfo)

    EmptyTemplate.super.ctor(self,templateInfo)

end

function EmptyTemplate:work(data,ownerPet,templateLevel)
end


function EmptyTemplate:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return EmptyTemplate