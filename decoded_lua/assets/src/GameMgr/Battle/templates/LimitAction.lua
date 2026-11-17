local LimitAction = class("LimitAction", BattleTemplate)

function LimitAction:ctor(templateInfo)

    LimitAction.super.ctor(self,templateInfo)

end

function LimitAction:work(data, ownerPet, templateLevel)

	local rate = data:getParamValue("限制概率", templateLevel)
	rate = BattleAidFunc.str2Percent(rate) * 100
	local limit = GetRandom.random(0,99)
	if (limit >= rate) then -- 判断是否限制
		printFileLog(string.format("%s:限制行动效果不触发!(%d >= %d)", ownerPet.name,limit,rate))
		return
	end

    if nil == ownerPet.attributes.limitSkills then
        ownerPet.attributes.limitSkills = {}
    end
    ownerPet.attributes.limitSkills[Proto.eST_Normal] = true
    ownerPet.attributes.limitSkills[Proto.eST_Profound] = true
    ownerPet.attributes.limitSkills[Proto.eST_Genius] = true

end

function LimitAction:getSkillDesc(data, templateLevel)
    local rate = data:getParamValue("限制概率", templateLevel)
    rate = BattleAidFunc.str2Percent(rate)
    print(data:getParamValue("限制概率", templateLevel))
    if val == nil then
        print("val ============ nil")
        val = 100
    end
    return BattleAidFunc.getSkillDesc(data, templateLevel,{["限制概率"] = (rate*100).."%%"})

end

return LimitAction