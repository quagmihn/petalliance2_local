local Buff = class("Buff")

function Buff:ctor(skillID,skillTagInfo,tagLevel)
    self.skillID = skillID
    self.id = skillTagInfo.id
    self.info = skillTagInfo
    self.level = tagLevel
    self.hide = false
    if 1 == skillTagInfo.hideBuff then
        self.hide = true
    end
    self:refreshRound()
    self.originRound = self.round
    self.counts = 0
end

function Buff:refreshRound()
    self.round = nil
    for i=1,#self.info.templateDatas do
        local tagTemplateInfo = self.info.templateDatas[i]
        for index=1,#tagTemplateInfo.actions do
            local templateData = tagTemplateInfo.actions[index]
            local round = templateData:getParamValue("持续回合", self.level)
            if (nil ~= round) then
                round = tonumber(round)
                if (nil == self.round) or (self.round > round) then
                    self.round = round
                end
            end            
        end
    end
    if nil == self.round then
        self.round = 1
    end
end

function Buff:addRound(round)
    self.round = self.round + round    
end

function Buff:reduceRound(reduceBuffRound)
    if self.round == 0 then 
        return
    end
    self.round = self.round - reduceBuffRound
end

function Buff:clearRound()
    
    self.round = 0
    
end

function Buff:hasGroup(groupNames)
    if self.hide or (self.round==0) then
        return false
    end
    for i=1,#self.info.groups do
        for j=1,#groupNames do
            if self.info.groups[i] == groupNames[j] then
                return true
            end
        end
    end
    return false
end

function Buff:hasTag(TagName)
    if self.hide or (self.round==0) then
        return false
    end
    for i = 1,#self.info.tags do
        if TagName == self.info.tags[i] then
            return true
        end
    end
    return false
end

function Buff:storeInfo()
    if (self.hide == true or 0 == self.round) then
        return nil
    end
    local info = {}
    info.level = self.level
    info.id = self.id
    info.name = self.info.name
    info.effect = self.info.effect
    info.round  = self.round
    info.skillID = self.skillID
    info.isBuff = self:hasTag("有益")
    return info
end

function Buff:dispatchBattleEvent(eventType,ownerPet)
    if self.round <= 0 then
        return
    end
    --    printFileLog(string.format("buff:%s dispatch event:%s start",self.info.name,EVENT_DESC[eventType]))
    local oldTriggerBuff = ownerPet.triggerBuff
    ownerPet.triggerBuff = self

    for i=1,#self.info.templateDatas do
        local tagTemplateInfo = self.info.templateDatas[i] 
        if BattleAidFunc.testTagEvent(tagTemplateInfo,eventType,self.info.name) and (BattleAidFunc.testTagCondition(tagTemplateInfo,ownerPet,self.level)) then
            local templateDatas = tagTemplateInfo.actions
            for index=1,#templateDatas do
                local templateData = templateDatas[index]
                if nil ~= templateData:getTemplate().work then
                    if IS_SERVER_CODE == nil and BattleLogConfig.triggerEffectLogFlag == true then
                        printFileLog(string.format("%s:<%d级%s %d回合>效果触发 work(%s)",ownerPet.name,self.level,templateData.ownerInfo.name,self.round,EVENT_DESC[eventType]))
                    end
                    templateData.skillid = self.skillID
                    templateData:getTemplate():work(templateData,ownerPet,self.level)
                else
                    printFileLog(string.format("%s:<%d级%s %d回合>效果触发 work未实现(%s) ",ownerPet.name,self.level,templateData.ownerInfo.name,self.round,EVENT_DESC[eventType]))
                    assert(false)
                    templateData:getTemplate():onBattleEvent(eventType,templateData,ownerPet,self.level)
                end
            end
        end
    end    
    ownerPet.triggerBuff = oldTriggerBuff
    --    printFileLog(string.format("buff:%s dispatch event:%s end",self.info.name,EVENT_DESC[eventType]))
end

return Buff