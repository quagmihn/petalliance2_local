local Team = class("Team")

function Team:ctor(info,side)
    self.pets = {}
    for i = 1,#info[OUTPETS] do
        self.pets[i] = Pet.new(info[OUTPETS][i],self,i)    
    end
    self.assistantPets = {}
    for i = 1,#info[INPETS] do
        self.assistantPets[i] = Pet.new(info[INPETS][i],self,i+3)
    end
    self.potentialSkills = {}
    if nil ~= info.potentialSkills then
        for i = 1,#info.potentialSkills do
            local skillInfo = BattleInfo.getPotentialSkillInfoById(info.potentialSkills[i])
            if skillInfo then
                local skill = Skill.new(skillInfo.skillID,skillInfo.skillID%10,i)
                skill.prob = skillInfo.prob
                skill.potentialId = info.potentialSkills[i]
                skill.potentialType = skillInfo.type 
                self.potentialSkills[#self.potentialSkills+1] = skill
            end
        end
    end
    self.reduceSpeedSkills = Skill.new(30051,1,1)

    self.FashionSkills = {}
    if nil ~= info.FashionSkills then
        for i = 1,#info.FashionSkills do
            local skill = Skill.new(info.FashionSkills[i],info.FashionSkills[i]%10,i)
            self.FashionSkills[#self.FashionSkills+1] = skill
        end
    end
    
    self.side = side
    self.petIndex = 0 
    self.energy = 0
    self.energyIncrement = 2
    self.currentPet = nil
end

function Team:reset()
    if nil == self.currentPet then
        return
    end
    self.currentPet:reset(1)
end

function Team:resetEnergyIncrement()

    self.energyIncrement = 2

end

function Team:addEnergyIncrement(val)

    self.energyIncrement = self.energyIncrement + val

end

function Team:reduceEnergyIncrement(val)

    self.energyIncrement = self.energyIncrement - val
    if (self.energyIncrement < 0) then
        self.energyIncrement = 0
    end

end

function Team:addEnergy()

    self.energy = self.energy + self.energyIncrement
    if (self.energy > ENERGY_LIMIT) then 
        self.energy = ENERGY_LIMIT
    end

end

function Team:addEnergyDirectly(val)

    self.energy = self.energy + val
    if (self.energy > ENERGY_LIMIT) then 
        self.energy = ENERGY_LIMIT
    end

end

function Team:reduceEnergyDirectly(val)

    self.energy = self.energy - val
    if (self.energy < 0) then 
        self.energy = 0
    end

end

function Team:checkPetEnter()
    if self.currentPet == nil then
        self.currentPet = self.pets[1]
        self.petIndex = 1
        return true
    end
    return false
end

function Team:onPetDie()
    if self.currentPet ~= nil then
        self.currentPet:tryUsePotentialSkill("dead_changepet")
    end
end

function Team:forceChangePet()
    for key,var in pairs(self.pets) do
        if (type(key) == "number") and (key ~= self.petIndex) then
            if self.pets[key].hp > 0 then
                BattleCotroller.getCurrentBattle():changePetAndSendInfo(self.side,key)
                return self.pets[key].pokeID
            end
        end
    end
    return -1
end

return Team