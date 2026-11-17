local BattleTemplate = class("BattleTemplate")

function BattleTemplate:ctor(templateInfo)
    printFileLog("create template:",templateInfo.name)
    self.templateInfo = templateInfo
    self.listeners = {}    
end

function BattleTemplate:useSkillOnSelf(data, ownerPet, templateLevel)

    

end

function BattleTemplate:useSkillOnEnemy(data, ownerPet, templateLevel)
    
    
end

function BattleTemplate:onBattleEvent(eventType,data,ownerPet,templateLevel)
    if self.listeners[eventType] == nil then
        return
    end
    local isTriggered = self.listeners[eventType](self,data,ownerPet,templateLevel)
    if nil == isTriggered then
        isTriggered = true
    end
	if IS_SERVER_CODE == nil then
		if isTriggered and (BattleLogConfig.triggerEffectLogFlag == true) then
			if ownerPet.triggerBuff == nil then
				printFileLog(string.format("%s:<%d级%s>效果触发(%s:%s)",ownerPet.name,templateLevel,self.templateInfo.name,data.ownerInfo.name,EVENT_DESC[eventType]))
			else
				local round = ownerPet.triggerBuff.round
				printFileLog(string.format("%s:<%d级%s %0.1f回合>效果触发(%s:%s)",ownerPet.name,templateLevel,self.templateInfo.name,round,data.ownerInfo.name,EVENT_DESC[eventType]))
			end
		end
	end
end

function BattleTemplate:onGetSkillDesc(data,templateLevel)
    if self.getSkillDesc == nil then
        return false
    end
    local desc = self.getSkillDesc(self,data,templateLevel)
    return desc
end

function BattleTemplate:onGetSkillAttribute(data,templateLevel)
    if self.getSkillAttribute == nil then
        return nil
    end
    local Att = self.getSkillAttribute(self,data,templateLevel)
    return Att
end

function BattleTemplate:registerEvent(eventType,func)
    self.listeners[eventType] = func
end

return BattleTemplate