local Skill = class("Skill")

SHOW_TRIGGERED = 1
SHOW_ROUND_START = 2
SHOW_ACTIVE = 3

function Skill:ctor(id,level,index)
    self.id = id
    self.level = level
    self.index = index
    self.info = BattleInfo.getSkillInfoByID(id)
    self.addPower = 0
    
    if self.info.skill_A_Type == Proto.eST_Passive or self.info.skill_A_Type == Proto.eST_Assist then
        --计算触发条件
        if self.info.triggerEvent == "" then
            self.triggerEvent = "ROUND_START"
        else
            self.triggerEvent = self.info.triggerEvent
        end
        if level > #self.info.triggerRates then
            self.triggerRate = 100
        else
            self.triggerRate = self.info.triggerRates[level]
        end
        self.triggerExtraRate = 0
        self.conditionRate = 0

        if #self.info.conditions > 0 then
            self.triggerCondition = BattleTemplateData.new(self.info,self.info.conditions[1])
        end
         
        if self.info.power == 0 then
            self.info.power = 100
        end
        
        --计算触发类型
        if (self.triggerRate ~= 100) and (self.triggerEvent ~= "ROUND_START") then
            self.triggerType = SHOW_TRIGGERED
        else
            if self.triggerEvent ~= "ROUND_START" then
                self.triggerType = SHOW_ROUND_START
            else
                self.triggerType = SHOW_ACTIVE
            end
        end
    end
    self.triggerType = SHOW_TRIGGERED
    --for debug
    self.name = LuaSqlite.getLanguageByKey(self.info.name)
    
end

function Skill:getPower()
    return self.addPower + self.info.power
end

function Skill:testTrigger(ownerPet,EVENT_TYPE)
    local result = {}
    result.show = false
    result.triggered = false
    if self.info.skill_A_Type ~= Proto.eST_Passive then
        return result
    end
    if EVENT_DESC[EVENT_TYPE] ~= self.triggerEvent then
        return result
    end
    
    if self.triggerCondition then
        local Template = self.triggerCondition:getTemplate()
        if Template.checkCondition then
            local condition = Template:checkCondition(self.triggerCondition,ownerPet,self.level,self.id)
            if condition == false then
                return result
            elseif type(condition) == "number" then
                self.conditionRate = condition
            end
        end
    end

    local hit = GetRandom.random(0,99)
    if hit >= (self.triggerRate + self.triggerExtraRate) then
        self.triggerExtraRate = self.triggerExtraRate + self.conditionRate
        return result
    else
        self.triggerExtraRate = 0
    end
    --触发了,计算是否需要显示
    result.triggered = true
    if self.triggerType == SHOW_TRIGGERED then
        printFileLog(string.format("SHOW_TRIGGERED:<%s>",self.name))
        result.show = true
        return result
    end
    local currentRound = BattleCotroller.getCurrentBattle().round
    if self.triggerType == SHOW_ROUND_START then
        if currentRound == 1 then
            printFileLog(string.format("SHOW_ROUND_START:<%s>",self.name))
            result.show = true
            return result
        end
    end
    --SHOW_ACTIVE
    if nil == self.lastTriggerRound then
        self.lastTriggerRound = -1
    end
    assert(currentRound >= self.lastTriggerRound)
    if currentRound > (self.lastTriggerRound + 1) then
        printFileLog(string.format("SHOW_ACTIVE:<%s>",self.name))
        result.show = true
    else
        printFileLog(string.format("不显示:<%s> currentRound:%d lastRound:%d",self.name,currentRound,self.lastTriggerRound))
    end    
    self.lastTriggerRound = currentRound
    return result
end

function Skill:testAssistTrigger(ownerPet,EVENT_TYPE)

    if EVENT_DESC[EVENT_TYPE] ~= self.triggerEvent then
        return false
    end

    return true

end

function Skill:testAssistTriggerShow(ownerPet,EVENT_TYPE)

    local show = false
    if self.triggerType == SHOW_TRIGGERED then
        printFileLog(string.format("SHOW_TRIGGERED:<%s>",self.name))
        show = true
        return show
    end
    local currentRound = BattleCotroller.getCurrentBattle().round
    if self.triggerType == SHOW_ROUND_START then
        if currentRound == 1 then
            printFileLog(string.format("SHOW_ROUND_START:<%s>",self.name))
            show = true
            return show
        end
    end
    --SHOW_ACTIVE
    if nil == self.lastTriggerRound then
        self.lastTriggerRound = -1
    end
    assert(currentRound >= self.lastTriggerRound)
    if currentRound > (self.lastTriggerRound + 1) then
        printFileLog(string.format("SHOW_ACTIVE:<%s>",self.name))
        show = true
    else
        printFileLog(string.format("不显示:<%s> currentRound:%d lastRound:%d",self.name,currentRound,self.lastTriggerRound))
    end    
    self.lastTriggerRound = currentRound
    return show
end

function Skill:storeInfo()
    local info = {}
    info.id = self.id
    info.name = self.info.name
    info.icon = self.info.icon
    return info
end

function Skill:dispatchBattleEvent(eventType,ownerPet)
    assert(false)
    local skillTags = self.info.tags
    local oldTriggerSkill = ownerPet.triggerSkill
    local oldTriggerBuff = ownerPet.triggerBuff
    ownerPet.triggerSkill = self
    ownerPet.triggerBuff = nil
    for i=1,#skillTags do
        local skillTag = skillTags[i].instance
        local tagLevel = skillTags[i].tagLevel
        for j=1,#skillTag.templateDatas do
            local tagTemplateInfo = skillTag.templateDatas[j]
            if BattleAidFunc.testTagEvent(tagTemplateInfo,eventType,skillTag.name) and (BattleAidFunc.testTagCondition(tagTemplateInfo,ownerPet,tagLevel)) then
                local templateDatas = tagTemplateInfo.actions
                for index=1,#templateDatas do
                    local templateData = templateDatas[index]
                    if nil ~= templateData:getTemplate().work then
                        templateData.skillid = self.id
                        templateData:getTemplate():work(templateData,ownerPet,tagLevel)
                    else
                        templateData:getTemplate():onBattleEvent(USE_SKILL,templateData,ownerPet,tagLevel)
                    end
                end
            end      
        end    
    end
    ownerPet.triggerSkill = oldTriggerSkill
    ownerPet.triggerBuff = oldTriggerBuff
end

function Skill:getSkillPriority(ownerPet)

    local skillTags = self.info.tags
    local priority = 0
    for i=1,#skillTags do
        local skillTag = skillTags[i].instance
        local tagLevel = skillTags[i].tagLevel
        local hasbuff = false
        for j=1,#ownerPet.buffs do
            if ownerPet.buffs[j].skillID == self.id and ownerPet.buffs[j].id == skillTag.id then
                hasbuff = true
                break
            end
        end
        if not hasbuff then
            local targetPet = BattleCotroller.getCurrentBattle():getEnemy(ownerPet)
            for j=1,#targetPet.buffs do
                if targetPet.buffs[j].skillID == self.id and targetPet.buffs[j].id == skillTag.id then
                    hasbuff = true
                    break
                end
            end
        end
        if not hasbuff then
            for j=1,#skillTag.templateDatas do
                local tagTemplateInfo = skillTag.templateDatas[j]
                local tagLevelExtra = 0
                local templateInfo = BattleInfo.getTemplateInfoByID(tagTemplateInfo.actions[1].templateData.id)
                if templateInfo.code == "Cure" or templateInfo.code == "AOECure" then
                    if ownerPet.hp/ownerPet:getMaxHP() <= 0.5 then
                        tagLevelExtra = 1
                    end
                end
                if BattleAidFunc.testTagCondition(tagTemplateInfo,ownerPet,tagLevel,self.id) then
                    priority = priority + tagLevel + tagLevelExtra
                    break
                end      
            end
        end    
    end
    return priority
    
end

function Skill:isSkillCure(ownerPet)

    local skillTags = self.info.tags
    local priority = 0
    for i=1,#skillTags do
        local skillTag = skillTags[i].instance
        for j=1,#skillTag.templateDatas do
            local tagTemplateInfo = skillTag.templateDatas[j]
            local templateInfo = BattleInfo.getTemplateInfoByID(tagTemplateInfo.actions[1].templateData.id)
            if templateInfo.code == "Cure" or templateInfo.code == "AOECure" then
                if ownerPet.hp == ownerPet:getMaxHP() then
                    return true
                end
            end     
        end  
    end
    return false
    
end

return Skill