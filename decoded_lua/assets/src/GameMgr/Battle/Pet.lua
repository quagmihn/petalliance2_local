local Pet = class("Pet")

local Event4Skill = 1
local Event4Buff = 2
    
function Pet:ctor(petTbl,team,index)
    self.team = team
    self.index = index
    self.pokeID = petTbl.pokeID
    self.level = petTbl.level
    self.hp = petTbl.blood
    self.objID = petTbl.objID
    self.name = string.format("%s(%d号)",LuaSqlite.getLanguageByKey(PokemonInfo.getPokemonInfoByID(self.pokeID).name),index)
    self.lastSkillID = 0
    self.anger = petTbl.anger
    self.attributes = {}
    self.attributes[Proto.AT_HP] = petTbl.bloodLimit
    self.attributes[Proto.AT_ATK] = petTbl.atk
    self.attributes[Proto.AT_DEF] = petTbl.def
    self.attributes[Proto.AT_RATE] = petTbl.HitRate
    self.attributes[Proto.AT_EVD] = petTbl.Dodge
    self.attributes[Proto.AT_CRT] = petTbl.Critical   
    self.attributes[Proto.AT_ANTICRT] = petTbl.CritResistance

    self.attributes[Proto.AT_CRTHURT] = petTbl.CSdamageRate
    self.attributes[Proto.AT_SATK] = petTbl.satk
    self.attributes[Proto.AT_SDEF] = petTbl.sdef
    self.attributes[Proto.AT_SPEED] = petTbl.speed
    self.attributes[Proto.AT_HEALRATE] = petTbl.healFix
    self.attributes[Proto.AT_ANTICRT]  = petTbl.CritResistance
    self.attributes[Proto.AT_DAMAGEREDUCE] = 123
    self.attributes[Proto.AT_SDEFFIX] = petTbl.sdefFix
    self.attributes[Proto.AT_DEFFIX]  = petTbl.defFix
    self.attributes[Proto.AT_PENETRATION]  = petTbl.penetration
    self.attributes[Proto.AT_SPENETRATION] = petTbl.spenetration
    
    self.attributes.Tenacity = petTbl.Tenacity
    self.attributes.damageRate = petTbl.damageRate

    self.attributes.physicalDamageRate = 1
    self.attributes.magicDamageRate = 1

    self.attributes.damageRateElement = 1
    self.attributes.canChangePet = true
    self.attributes.invincible = false
    self.attributes.limitDamage = 0
    self.attributes.ignoreDef = false
    self.roundDamage = 0
    self.addPriority = 0
    self.saveAttributes = {}
--备份战斗属性    
    self._attributes = clone(self.attributes)

    self.stealAttributes = {}

    self.killedBySelf = false
    self.nextCritical = false
    self.nextRoundCritical = false
    self.immuneResurrect = false
    self.isAddAnger = true
    
    self.skills = {}
    for i=1,#petTbl.skill do
        --todo set skill level
        if type(petTbl.skill[i]) == "table" then
            local skillLevel = petTbl.skill[i]["id"] % 5
            if skillLevel == 0 then
                skillLevel = 5
            end
            self.skills[i] = Skill.new(petTbl.skill[i]["id"],skillLevel,i)
        end
        --printFileLog("petTbl.skill:"..sz_T2S(petTbl.skill[i]))
    end
    self.passiveSkills = {}
    for i=1,#petTbl.paSkills do
        if "table" == type(petTbl.paSkills[i]) then
            local skillID = petTbl.paSkills[i].id
            if 0 ~= skillID then
                --todo set passive skill level
                local skillLevel = skillID % 5
                if skillLevel == 0 then
                    skillLevel = 5
                end
                self.passiveSkills[i] = Skill.new(skillID,skillLevel,i)                
            end
        end
    end

    local elementAtt = PokemonInfo.getPokemonInfoByID(self.pokeID).elementAtt1
    local elementAtt2 = PokemonInfo.getPokemonInfoByID(self.pokeID).elementAtt2

    local rep = false
    if elementAtt == Proto.ATTR_GOBLIN and elementAtt2 ~= ATTR_NONE and elementAtt2 ~= ATTR_COMMON then
        rep = elementAtt2
    elseif elementAtt2 == Proto.ATTR_GOBLIN and elementAtt ~= ATTR_NONE and elementAtt ~= ATTR_COMMON then
        rep = elementAtt
    end
    if rep then
        local id = 1
        for i=1,BattleInfo.getElementSkillInfoCount() do
            local elementSkillInfo = BattleInfo.getElementSkillInfo(i)
            if elementSkillInfo.elementType == rep then
                for j=1,#elementSkillInfo.skills do
                    local skillID = elementSkillInfo.skills[j]
                    local skillLevel = skillID%10
                    self.passiveSkills[#self.passiveSkills + 1] = Skill.new(skillID,skillLevel,#self.passiveSkills + 1)
                    id = math.floor(skillID/10)
                end
            end
        end
        for i=1,BattleInfo.getElementSkillInfoCount() do
            local elementSkillInfo = BattleInfo.getElementSkillInfo(i)
            if elementSkillInfo.elementType == Proto.ATTR_GOBLIN then
                for j=1,#elementSkillInfo.skills do
                    local skillID = elementSkillInfo.skills[j]
                    local skillLevel = skillID%10
                    if math.floor(skillID/10) ~= id then
                        self.passiveSkills[#self.passiveSkills + 1] = Skill.new(skillID,skillLevel,#self.passiveSkills + 1)
                    end
                end
            end
        end
    else
        for i=1,BattleInfo.getElementSkillInfoCount() do
            local elementSkillInfo = BattleInfo.getElementSkillInfo(i)
            if elementSkillInfo.elementType == elementAtt or elementSkillInfo.elementType == elementAtt2 then
                for j=1,#elementSkillInfo.skills do
                    local skillID = elementSkillInfo.skills[j]
                    local skillLevel = skillID%10
                    self.passiveSkills[#self.passiveSkills + 1] = Skill.new(skillID,skillLevel,#self.passiveSkills + 1)
                end
            end
        end
    end
    
    --self.buffer = petTbl.buffer
    self.selectedSkill = nil
    self.triggeredPassiveSkills = {}
    self.triggeredAssistSkills = {}
    self.buffChanged = false
    self.buffs = {}
    HDVector.extend(self.buffs)
    
    --self:initPassiveBuff(petTbl)
    self.skillUseInfo = {}
    self.newBuffs = {}

    self.buffCures = {}

    self.stopDamageAndCure = false
end

function Pet:savePetAttributes()
    self.saveAttributes = self.attributes
end

function Pet:reset(reduceBuffRound)
    self.attributes = clone(self._attributes)
    if self.selectedSkill ~= nil then
        self.lastSkillID = self.selectedSkill.id 
    end
    self.selectSkillIndex = -1
    self.selectedSkill = nil
    self.buffChanged = true
    self.roundDamage = 0
    
    self:clearBuff(reduceBuffRound)
    self.newBuffs = {}
    self.triggeredPassiveSkills = {}
    self.triggeredAssistSkills = {}

    local enemyPet = BattleCotroller.getCurrentBattle():getEnemy(self)
    if enemyPet then
        enemyPet.stealAttributes = {}
    end
end

function Pet:clearBuff(reduceBuffRound)
    local removeBuffIndex = {}
    for i=1,#self.buffs do
        local currentBuff = self.buffs[i]

        if reduceBuffRound>0 then
            currentBuff:reduceRound(reduceBuffRound)
        end
        if currentBuff.round <= 0 then
            table.insert(removeBuffIndex,i)
        end
    end
    for i=#removeBuffIndex,1,-1 do
        if IS_SERVER_CODE == nil and (BattleLogConfig.bufferLogFlag == true) then
            local buff = self.buffs[removeBuffIndex[i]]
            if true == buff.hide then
                printFileLog(string.format("%s:移除隐藏Buff<%s>",self.name,buff.info.name,buff.round))
            else
                printFileLog(string.format("%s:移除Buff<%s>",self.name,buff.info.name,buff.round))
            end
        end
        self.buffs:erase(removeBuffIndex[i])
        self.buffChanged = true
    end
end

function Pet:getMaxHP()
    return self.attributes[Proto.AT_HP]
end

function Pet:testUseSkill(skill)
    if nil == self.attributes.limitSkills then
        return true
    end
    if true ~= self.attributes.limitSkills[skill.info.skill_A_Type] then
        return true
    else
        local skillTags = skill.info.tags
        for i=1,#skillTags do
            local skillTag = skillTags[i].instance
            local tagLevel = skillTags[i].tagLevel
            for j=1,#skillTag.tags do
                if skillTag.tags[j] == "免疫禁用" then
                    return true
                end
            end
        end
    end
    -- if math.floor(skill.id/10) == 1001 or math.floor(skill.id/10) == 1002 then
    --     return true
    -- end
    if IS_SERVER_CODE == nil then
        if (BattleLogConfig.skillUseLogFlag == true) then
            printFileLog(string.format("%s:无法使用%s技能<%d级 %s>",self.name,SKILL_TYPE_DESC[skill.info.skill_A_Type],skill.level,skill.name))            
        end
    end
    return false
end

function Pet:getSkillUseCount(skillID)
    local count = self.skillUseInfo[skillID]
    if nil == count then
        return 0
    end
    return count
end

function Pet:getSelectedSkill()
    return self.selectedSkill
end

function Pet:replaceBuff(buff)
    for i=1,#self.buffs do
        local currentBuff = self.buffs[i]
        if (currentBuff.skillID == buff.skillID) and (currentBuff.info.id == buff.info.id) then
            if IS_SERVER_CODE == nil and (BattleLogConfig.bufferLogFlag == true) then
                printFileLog(string.format("%s:重置Buff<%s %d回合>",self.name,buff.info.name,buff.round))
            end
            self.buffs[i] = buff
            return true
        end
    end
    return false
end

function Pet:addBuff(buff)
    if IS_SERVER_CODE == nil and (BattleLogConfig.bufferLogFlag == true) then
        if true == buff.hide then
            printFileLog(string.format("%s:获得隐藏Buff<%s %d回合>",self.name,buff.info.name,buff.round))
        else
            printFileLog(string.format("%s:获得Buff<%s %d回合>",self.name,buff.info.name,buff.round))
        end            
    end
    self.canAddBuff = true
    self.currentAddBuff = buff
    self:dispatchBattleEvent(BEFORE_ADD_BUFF)
    self.currentAddBuff = nil
    if (false == self.canAddBuff) then
        if IS_SERVER_CODE == nil and (BattleLogConfig.bufferLogFlag == true) then
            printFileLog(string.format("%s:获得Buff<%s %d回合>被阻止...",self.name,buff.info.name,buff.round))           
        end
        return
    end

    if self:replaceBuff(buff) then
        return
    end
    local oldBuff = self:removeBuffByGourp(buff.info.groups)
    self.buffs:push_back(buff)
    self.newBuffs[#self.newBuffs+1] = buff

    if self.buffChanged == false then
        if oldBuff == nil or oldBuff.level ~= buff.level then
            self.buffChanged = true
        end
    end
    assert(buff.round>0,"new buff round <=0")   
end

--function Pet:removeBuffByIndex(index)
--    local buff = self.buffs[index]
-- if (BattleLogConfig.bufferLogFlag == true) then
--    printFileLog(string.format("%s:Buff<%s %d回合>效果消失了",self.name,buff.info.name,buff.round))
-- end
--    self.buffs:erase(index)
--end

function Pet:removeBuffByGourp(groupNames)
    for i=1,#self.buffs do
        local buff = self.buffs[i]
        if buff:hasGroup(groupNames) then
            if IS_SERVER_CODE == nil and (BattleLogConfig.bufferLogFlag == true) then
                printFileLog(string.format("%s:发现重复Buff<%s %d回合>",self.name,buff.info.name,buff.round))
            end
            buff.round = 0
            --self:clearBuff(0)
            self.buffChanged = true
            return buff
        end
    end
    return nil
end

function Pet:refreshBuff()
    if false == self.buffChanged then
        return
    end
    self.buffChanged = false
    if IS_SERVER_CODE == nil and (BattleLogConfig.bufferLogFlag == true) then
        printFileLog(string.format("%s:重置属性,刷新buff ",self.name))
    end
    self.attributes = clone(self._attributes)
    local enemyPet = BattleCotroller.getCurrentBattle():getEnemy(self)
    if enemyPet then
        enemyPet.stealAttributes = {}
    end
    for k,v in pairs(self.stealAttributes) do
        local key = v[1]
        local value = BattleAidFunc.normalize(v[2])
        self.attributes[key] = self.attributes[key]- value
        if self.attributes[key] < 0 then
            self.attributes[key] = 0
        end
    end
    self:dispatchBattleEvent(BUFF_ACTIVE)
end

function Pet:getAttribute(type)

    return self.attributes[type]

end

function Pet:setAttribute(type, value, limit)

    if (Proto.AT_HP == type or Proto.AT_ATK == type
        or Proto.AT_DEF == type or Proto.AT_SATK == type
        or Proto.AT_SDEF == type or Proto.AT_SPEED == type) then
        value = math.floor(math.max(1, value))
    elseif (Proto.AT_CRTHURT == type) then
        value = math.floor(math.max(100, value))
    else
        value = math.floor(math.max(0, value))
    end
    self.attributes[type] = value

    if (Proto.AT_HP == type and limit == nil) then
        if (self.hp > self.attributes[Proto.AT_HP]) then
            self.hp = self.attributes[Proto.AT_HP]
        end
    end

end

function Pet:setStealAttribute(type, value)

    table.insert(self.stealAttributes, {type, value})

end

function Pet:addAttribute(type, value, limit, skill)

    value = BattleAidFunc.normalize(value)
    self:setAttribute(type, self:getAttribute(type) + value, limit)
    if Proto.AT_HP == type and limit and skill then
        if not self.extra_hp then
            self.extra_hp = {}
        end
        self.extra_hp[skill] = value
    end

end

function Pet:resetHp()

    if self.hp > 0 then
        if self.extra_hp then
            for k,v in pairs(self.extra_hp) do
                self.hp = self.hp - v
            end
        end
        local minHp = math.ceil(self:getAttribute(Proto.AT_HP)/10000)
        if self.hp < minHp then
            self.hp = minHp
        end
    end

end

function Pet:reduceAttribute(type, value)

    value = BattleAidFunc.normalize(value)
    self:setAttribute(type, self:getAttribute(type) - value)

end

function Pet:_getAttribute(type)

    return self._attributes[type]

end

function Pet:_setAttribute(type, value)

    if (Proto.AT_HP == type or Proto.AT_ATK == type
        or Proto.AT_DEF == type or Proto.AT_SATK == type
        or Proto.AT_SDEF == type or Proto.AT_SPEED == type) then
        value = math.floor(math.max(1, value))
    elseif (Proto.AT_CRTHURT == type) then
        value = math.floor(math.max(100, value))
    else
        value = math.floor(math.max(0, value))
    end
    self._attributes[type] = value

end

function Pet:_addAttribute(type, value)

    value = BattleAidFunc.normalize(value)
    self:_setAttribute(type, self:_getAttribute(type) + value)

end

function Pet:_reduceAttribute(type, value)

    value = BattleAidFunc.normalize(value)
    self:_setAttribute(type, self:_getAttribute(type) - value)

end

function Pet:tryUsePassiveSkill(eventType)

    for key,var in pairs(self.passiveSkills) do
        local skill = self.passiveSkills[key]
        --todo 判定能否触发
        if skill.info.skill_A_Type == Proto.eST_Passive then
            local canUse = skill:testTrigger(self,eventType)
            if canUse.triggered then
                if true == self:testUseSkill(skill) then
                    self:useSkill(skill)
                    if canUse.show then
                        self.triggeredPassiveSkills[skill.id] = skill
                    end
                end
            end
        end
    end

end

function Pet:tryUseAssistSkill(eventType)
    
    local assistSkillTab = {}
    local assistTriggered = false
    local triggerRate = 1
    local triggerRate2 = 0
    local assistPets = self.team.assistantPets
    for i=1,#assistPets do
        for key,var in pairs(assistPets[i].passiveSkills) do
            local skill = assistPets[i].passiveSkills[key]
            if skill.info.skill_A_Type == Proto.eST_Assist then
                if skill:testAssistTrigger(self,eventType) then
                    local tbsize = #assistSkillTab
                    assistSkillTab[tbsize+1] = {}
                    assistSkillTab[tbsize+1].pet = assistPets[i]
                    assistSkillTab[tbsize+1].skill = skill
                    assistSkillTab[tbsize+1].id = i
                    triggerRate2 = triggerRate + skill.triggerRate - 1
                    assistSkillTab[tbsize+1].triggerRate = {triggerRate,triggerRate2}
                    triggerRate = triggerRate2 + 1
                end
            end
        end
    end
    if triggerRate2 < 100 then
        triggerRate2 = 100
    end
    local hit = GetRandom.random(1,triggerRate2)
    for i=1,#assistSkillTab do
        if hit >= assistSkillTab[i].triggerRate[1] and hit <= assistSkillTab[i].triggerRate[2] then
            if true == assistSkillTab[i].pet:testUseSkill(assistSkillTab[i].skill) then
                self:useSkill(assistSkillTab[i].skill)
                if assistSkillTab[i].skill:testAssistTriggerShow(self,eventType) then
                    self.triggeredAssistSkills[assistSkillTab[i].skill.id] = {}
                    self.triggeredAssistSkills[assistSkillTab[i].skill.id].id = assistSkillTab[i].id
                    self.triggeredAssistSkills[assistSkillTab[i].skill.id].skill = assistSkillTab[i].skill:storeInfo()
                    self.triggeredAssistSkills[assistSkillTab[i].skill.id].skill.pokeID_A = self.pokeID
                    local targetPet = BattleCotroller.getCurrentBattle():getEnemy(self)
                    self.triggeredAssistSkills[assistSkillTab[i].skill.id].skill.pokeID_B = targetPet.pokeID
                    self.triggeredAssistSkills[assistSkillTab[i].skill.id].side = self.team.side
                    self.triggeredAssistSkills[assistSkillTab[i].skill.id].pokeID = assistSkillTab[i].pet.pokeID
                end
            end
            break
        end
    end

end

function Pet:tryUsePotentialSkill(eventType)


    local potentialSkills = self.team.potentialSkills

    if eventType == ROUND_START then
        for i=1,#potentialSkills do
            local skill = potentialSkills[i]
            if Proto.PST_PASSIVE == skill.potentialType then                
                if true == self:testUseSkill(skill) then
                    self:useSkill(skill)
                end
            end
        end
    elseif eventType == "dead_changepet" then
        if self.potentialSkillUsed == nil then
            self.potentialSkillUsed = true
            
            local potentialSkillTab = {}
            local potentialTriggered = false
            local triggerRate = 1
            local triggerRate2 = 0

            for i=1,#potentialSkills do
                local skill = potentialSkills[i]
                if Proto.PST_APPEAR == skill.potentialType  then
                    local tbsize = #potentialSkillTab
                    potentialSkillTab[tbsize+1] = {}
                    potentialSkillTab[tbsize+1].skill = skill
                    triggerRate2 = triggerRate + skill.prob - 1
                    potentialSkillTab[tbsize+1].triggerRate = {triggerRate,triggerRate2}
                    triggerRate = triggerRate2 + 1
                end
            end

            if triggerRate2 < 10000000 then
                triggerRate2 = 10000000
            end
            local hit = GetRandom.random(1,triggerRate2)
            for i=1,#potentialSkillTab do
                local skill = potentialSkillTab[i].skill
                if hit >= potentialSkillTab[i].triggerRate[1] and hit <= potentialSkillTab[i].triggerRate[2] then
                    if true == self:testUseSkill(skill) then
                        self:useSkill(skill)
                        
                        self.triggeredPassiveSkills[skill.id] = skill
                    end
                    break
                end
            end
        end

        -- if self.reduceSpeedSkillUsed == nil then
        --     self.reduceSpeedSkillUsed = true

        --     local skill = self.team.reduceSpeedSkills
        --     if skill then
        --         if true == self:testUseSkill(skill) then
        --             printFileLog(string.format("%s:使用入场减速技能<%d级 %s>",self.name,skill.level,skill.info.name))
        --             self:useSkill(skill)
        --         end
        --     end
        -- end
    end
end

function Pet:tryUseFashionSkill(eventType)

    if eventType == ROUND_START then
        local FashionSkills = self.team.FashionSkills

        for i=1,#FashionSkills do
            local skill = FashionSkills[i]
            if true == self:testUseSkill(skill) then
                self:useSkill(skill)
            end
        end
    end

end

function Pet:paySkillCost(skill)
    if (skill.index>1) and (skill.index<4) then 
        if self.team.energy > skill.info.energy then
            self.team.energy = self.team.energy - skill.info.energy
        else        
            self.team.energy = 0
        end
    end
    if skill.index == 4 then
        if self.anger > skill.info.energy then
            self.anger = self.anger - skill.info.energy
        else        
            self.anger = 0
        end
    end
end

function Pet:useSkill(skill)
    
    local oldTriggerSkill = self.triggerSkill
    self.triggerSkill = skill
    
    self.canUseSkill = true
    self:dispatchBattleEvent(BEFORE_USE_SKILL)
    if (false == self.canUseSkill) then
        return
    end

    local friendPet = self.team.currentPet 

    if IS_SERVER_CODE == nil then
        if (BattleLogConfig.skillUseLogFlag == true) then
            printFileLog(string.format("%s:使用%s技能<%d级 %s>",self.name,SKILL_TYPE_DESC[skill.info.skill_A_Type],skill.level,skill.name))            
        end
    end
    
    self.skillUseInfo[skill.id] = self:getSkillUseCount(skill.id) + 1
    
    local targetPet = BattleCotroller.getCurrentBattle():getEnemy(self)
    local skillTags = skill.info.tags
    local skillLevel = skill.level
    
    local oldTriggerBuff = self.triggerBuff
    local targetOldTriggerBuff = targetPet.triggerBuff
    
    local buffInfo = {}
    for i=1,#skillTags do
        local skillTag = skillTags[i].instance
        local tagLevel = skillTags[i].tagLevel
        
        local buff = Buff.new(skill.id,skillTag,tagLevel)
        local isaddBuff = true
        table.insert(buffInfo,buff)
        for i=1,#buff.info.templateDatas do
            local tagTemplateInfo = buff.info.templateDatas[i]  
            local petOwn = targetPet
            if 1 == skillTag.selfBuff then
                petOwn = self
            end
            -- if not BattleAidFunc.testTagCondition(tagTemplateInfo,petOwn,buff.level,nil,true) then
            --     isaddBuff = false
            --     break 
            -- end
        end
               
        if 1 == skillTag.selfBuff then
            if IS_SERVER_CODE == nil and (BattleLogConfig.bufferLogFlag == true) then
                print(string.format("\t%s:给自己加buff<%s,%d回合>",self.name,buff.info.name,buff.round))            
            end
            if  isaddBuff then
                friendPet:addBuff(buff)
            else
                table.remove(buffInfo,i)
            end
--            self.triggerBuff = buff
        else
            if IS_SERVER_CODE == nil and (BattleLogConfig.bufferLogFlag == true) then
                print(string.format("\t%s:给敌方加buff<%s,%d回合>",self.name,buff.info.name,buff.round))            
            end
            if  isaddBuff then
                targetPet:addBuff(buff)
            else
                table.remove(buffInfo,i)
            end
--            targetPet.triggerBuff = buff
        end        
    end
    friendPet:refreshBuff()
    targetPet:refreshBuff()

    if skill.info.skill_A_Type ~= Proto.eST_Passive and skill.info.skill_A_Type ~= Proto.eST_Assist then
        self:dispatchBattleEvent(I_USE_SKILL)
        targetPet:dispatchBattleEvent(ENEMY_USE_SKILL)
    end
    
    for i=1,#skillTags do
        local skillTag = skillTags[i].instance
        local tagLevel = skillTags[i].tagLevel
        for j=1,#skillTag.templateDatas do
            local tagTemplateInfo = skillTag.templateDatas[j]
            if BattleAidFunc.testTagEvent(tagTemplateInfo,USE_SKILL,skillTag.name) and (BattleAidFunc.testTagCondition(tagTemplateInfo,self,tagLevel)) then
                local templateDatas = tagTemplateInfo.actions
                for index=1,#templateDatas do
                    local templateData = templateDatas[index]
                    if nil ~= templateData:getTemplate().work then
                        if IS_SERVER_CODE == nil and BattleLogConfig.triggerEffectLogFlag == true then
                            printFileLog(string.format("%s:<%d级%s>效果触发(%d级技能:%s)",self.name,tagLevel,templateData.ownerInfo.name,skillLevel,skill.name))
                        end
                        if 1 == skillTag.selfBuff then
                            self.triggerBuff = buffInfo[i]
                        else
                            targetPet.triggerBuff = buffInfo[i]
                        end 
                        templateData.skillid = skill.id
                        templateData:getTemplate():work(templateData,self,tagLevel,skill)
                    else
                        --                        assert(false)
                        templateData:getTemplate():onBattleEvent(USE_SKILL,templateData,self,tagLevel)
                    end
                end
            end   
        end
    end
    
    self.triggerSkill = oldTriggerSkill
    self.triggerBuff = oldTriggerBuff
    targetPet.triggerBuff = targetOldTriggerBuff
end

function Pet:dispatchBattleEvent(eventType)
    
    self:tryUsePassiveSkill(eventType)
    self:tryUseAssistSkill(eventType)
    self:tryUsePotentialSkill(eventType)
    self:tryUseFashionSkill(eventType)

    local targetPet = BattleCotroller.getCurrentBattle():getEnemy(self)

    for i=1,#self.buffs do
        local tempBuff = self.buffs[i]
        if tempBuff then
            tempBuff:dispatchBattleEvent(eventType,self)
        end
    end 

    self:clearBuff(0)
    targetPet:clearBuff(0)
    self:refreshBuff()
    targetPet:refreshBuff()

end

function Pet:clearBuffDamages()

    self.buffDamages = {}

end

function Pet:clearBuffCures()

    self.buffCures = {}

end

function Pet:addBuffDamage(damage)

    self.buffDamages[#self.buffDamages + 1] = damage 

end

function Pet:addBuffCure(cure)

    self.buffCures[#self.buffCures + 1] = cure 

end

function Pet:getDamage(damage, ignoreDef)

    if self.stopDamageAndCure then
        return
    end
    
    if not ignoreDef then
        if self.attributes.limitDamage > 0 and damage > self.attributes.limitDamage then
			if self.attributes.mustDie then
				damage = damage
			else
				damage = self.attributes.limitDamage
			end
        end

        if (true == self.attributes.invincible) then
            damage = 0
        end
    end

    self.hp = self.hp - damage

    self.roundDamage = self.roundDamage + damage
    -- if (self.hp < 0) then
    --     self.hp = 0
    -- end

    local battle = BattleCotroller.getCurrentBattle()
    if self.team.side == TEAM_A then
        battle.totalDamageB = battle.totalDamageB + damage
    else
        battle.totalDamageA = battle.totalDamageA + damage
    end

end

function Pet:getCure(cure)

    if self.stopDamageAndCure then
        return
    end

    self.hp = self.hp + BattleAidFunc.normalize(cure)
    if (self.hp > self:getAttribute(Proto.AT_HP)) then
        self.hp = self:getAttribute(Proto.AT_HP)
    end

    local battle = BattleCotroller.getCurrentBattle()
    if self.team.side == TEAM_A then
        battle.totalCureA = battle.totalCureA + BattleAidFunc.normalize(cure)
    else
        battle.totalCureB = battle.totalCureB + BattleAidFunc.normalize(cure)
    end

end

function Pet:storeAttrubiteInfo()
    local info = {}
    for i=Proto.AT_HP,Proto.AT_SPEED do
        info[i] = self.attributes[i]
    end
    return info
end

function Pet:hasBuffTag(tagName)
    for i = 1,#self.buffs do
        local buff = self.buffs[i]
        if (false==buff.hide) and (buff:hasTag(tagName)) then
            return true
        end
    end
    return false
end

function Pet:getBuffsByTag(tagName)
    local buffTagList = {}
    for i = 1, #self.buffs do
        local buff = self.buffs[i] 
        if (false==buff.hide) and (buff:hasTag(tagName)) then
            buffTagList[#buffTagList + 1] = clone(buff) 
        end
    end
    return buffTagList
end

function Pet:removeBuffByTag(tagName)
    for i = #self.buffs, 1, -1 do
        local buff = self.buffs[i]
        if (false==buff.hide) and (buff:hasTag(tagName)) and (not buff:hasTag("免疫驱散")) then
            buff.round = 0
        end
    end
    -- self:clearBuff(0)
end

function Pet:haveBuffByTag(tagName)
    for i = #self.buffs, 1, -1 do
        local buff = self.buffs[i]
        if (false==buff.hide) and (buff:hasTag(tagName)) and (not buff:hasTag("免疫驱散")) then
            return true
        end
    end
    return false
end

function Pet:resetBuffsRoundByTag(tagName)

    for i = 1, #self.buffs do
        local buff = self.buffs[i]
        if (false==buff.hide) and (buff.round>0)and (buff:hasTag(tagName)) then
            if buff.round < buff.originRound then
                buff.round = buff.originRound
            end
        end
    end

end

function Pet:autoSelectSkill()

    if (nil ~= self.selectSkillIndex) and (-1 ~= self.selectSkillIndex) then
        return
    end

    local skillTab = {}
    local isTriggerProSkill = false
    for i=1,4 do
        skillTab[i] = {}
        skillTab[i].id = i
        if self.skills[i] then
            skillTab[i].skillId = self.skills[i].id
            local energy = self.team.energy
            local infoenergy = 0
            local x2 = 1
            if i == 4 then
                energy = self.anger
                x2 = 2
            end
            local priority = 0
            if energy >= self.skills[i].info.energy then
                priority = self.skills[i]:getSkillPriority(self)
                infoenergy = self.skills[i].info.energy*x2
                if i == 4 then
                    isTriggerProSkill = true
                    priority = priority + self.addPriority
                end
            end
            skillTab[i].priority = priority
            skillTab[i].energy = infoenergy
        else
            skillTab[i].skillId = 0
            skillTab[i].priority = 0
            skillTab[i].energy = 0
        end
    end

    table.sort(skillTab, function(a, b)
        return a.priority*100+a.energy*10+(4-a.id) > b.priority*100+b.energy*10+(4-b.id)
    end)

    self.selectSkillIndex = skillTab[1].id
    if self.lastSkillID == skillTab[1].skillId or self.skills[self.selectSkillIndex]:isSkillCure(self) then
        for i=2,4 do
            if skillTab[i].priority > 0 then
                self.selectSkillIndex = skillTab[i].id
                break
            end
        end
    end
    if  self.selectSkillIndex ~= 4 then
        if isTriggerProSkill then
            self.addPriority = self.addPriority + 1
        end
    else
        self.addPriority = 0
    end
end

function Pet:increaseAnger()

    self.anger = self.anger + 1
    local limit = self:getAngerLimit()
    if self.anger > limit then
        self.anger = limit
    end

end

function Pet:addAngerDirectly(val)

    self.anger = self.anger + val
    local limit = self:getAngerLimit()
    if self.anger > limit then
        self.anger = limit
    end

end

function Pet:getAngerLimit()

    local limit = 0
    if (nil ~= self.skills[4]) then
        limit = self.skills[4].info.energy
    end
    return limit

end

function Pet:reduceAngerDirectly(val)

    self.anger = self.anger - val
    if self.anger < 0 then
        self.anger = 0
    end

end

function Pet:stopDamageCure(stop)

    self.stopDamageAndCure = stop
    
end

function Pet:clearBuffs()

    for i=1,#self.buffs do
        if self.buffs[i] and not self.buffs[i].notremove then
            self.buffs:erase(i)
            self:clearBuffs()
        end
    end
    
end

return Pet
