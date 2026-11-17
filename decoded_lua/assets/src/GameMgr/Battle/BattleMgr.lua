if IS_SERVER_CODE == nil then
    require("src.GameMgr.Battle.type_damage")
end
local BattleMgr = class("BattleMgr")

ANGER_LIMIT  = 4
ENERGY_LIMIT = 6
OUTPETS      = 0
INPETS       = 1

MYPETS       = 0
HISPETS      = 1

EVENT_DESC = {
    "ROUND_START",
    "ROUND_END",
    "AFTER_ROUND_END",
    "BEFORE_ATTACK",
    "ATTACK",
    "AFTER_ATTACK",
    "BEFORE_DEFENCE",
    "DEFENCE",
    "AFTER_DEFENCE",
    "PET_APPEAR",
    "PET_DISAPPEAR",
    "PET_DEAD",
    "USE_SKILL",
    "BUFF_ACTIVE",
    "WEATHER_CHANGED",
    "ATTACK_COMPLETE",
    "DEFENCE_COMPLETE",
    "SELECT_TARGET",
    "BEFORE_ADD_BUFF",
    "KILL_PET",
    "GET_SKILL_DESC",
    "BEFORE_USE_SKILL",
    "I_USE_SKILL",
    "ENEMY_USE_SKILL",
    "DAMAGE_COMPLETE",
    "REAL_GET_DAMAGE",
}

SKILL_TYPE_DESC = {}
SKILL_TYPE_DESC[Proto.eST_Normal] = "主动"
SKILL_TYPE_DESC[Proto.eST_Profound] = "奥义"
SKILL_TYPE_DESC[Proto.eST_Feature] = "特性"
SKILL_TYPE_DESC[Proto.eST_Physics] = "物理"
SKILL_TYPE_DESC[Proto.eST_Special] = "魔法"
SKILL_TYPE_DESC[Proto.eST_Variety] = "变化"
SKILL_TYPE_DESC[Proto.eST_Passive] = "被动"
SKILL_TYPE_DESC[Proto.eST_Assist] = "援助"
SKILL_TYPE_DESC[Proto.eST_Genius] = "天赋"
SKILL_TYPE_DESC[Proto.eST_ChangePet] = "换宠"

for k, v in pairs(EVENT_DESC) do
    _G[v] = k
end

TEAM_A = 0
TEAM_B = 1

ATTACK_ATTACK = 1
ATTACK_CURE = 2
ATTACK_CHAOS = 3




--UI动画表现说明
---   被动+buffer表现 @param toPetID
--      table.insert(self.curRecord,{buffAndPass = true,self.applyBuffandPass,energy = self.energy[0]})  
---   换宠表现 @param toPetID 换上宠的ID
--      table.insert(self.curRecord,{changePet = true,petType,toPetID,energy = self.energy[0]}) 
---   播放宠物放技能表现  @param oneTurnDamageTable 传伤害table @param sendAnger 已方愤怒值的表现  @param sendEnergy 已方能量值的表现
--table.insert(self.curRecord,{ani = true,attackType,skillType,attackedType,oneTurnDamageTable,sendAnger,sendEnergy})
 
STATE_ROUND_START       = 0
STATE_WAIT_SELECT_SKILL = 1
STATE_FIGHT_ONE         = 2
STATE_FIGHT_TWO         = 3
STATE_ROUND_END         = 4
STATE_BATTLE_END        = 5

STATE_DESC = {}
STATE_DESC[STATE_ROUND_START] = "STATE_ROUND_START"
STATE_DESC[STATE_WAIT_SELECT_SKILL] = "STATE_WAIT_SELECT_SKILL"
STATE_DESC[STATE_FIGHT_ONE] = "STATE_FIGHT_ONE"
STATE_DESC[STATE_FIGHT_TWO] = "STATE_FIGHT_TWO"
STATE_DESC[STATE_ROUND_END] = "STATE_ROUND_END"
STATE_DESC[STATE_BATTLE_END] = "STATE_BATTLE_END"

function BattleMgr:routine()
    printFileLog("routine:",STATE_DESC[self.routineState]) 
    if self.routineState == STATE_ROUND_START then
        self:clearCurRecord() 
        self:setState(STATE_WAIT_SELECT_SKILL)
        self:OnRoundStart()
        self:battleSummary()
        if not IS_SERVER_CODE and not BattleMapMgr.getIsArena() and not BattlePVPMgr.mIsPVPBattle then 
            self:selectSkill(TEAM_B)
        end
    end

    if self.routineState == STATE_FIGHT_ONE then
        self:oneRoundInfo()
        self:reset()
        self:clearCurRecord()
        self:addSelectSkillRecord(TEAM_A)
        self:logCurrentPetHP(0)
        self:enterPetPerform()
        self:battleSummary()
        self:logCurrentPetHP(1)
        if STATE_FIGHT_ONE == self.routineState then 
            self:setState(STATE_FIGHT_TWO)
        end 
    end
 
    if self.routineState == STATE_FIGHT_TWO then
        self:logCurrentPetHP(0)
        self:enterPetPerform()
        self:battleSummary()
        self:logCurrentPetHP(1)
        if STATE_FIGHT_TWO == self.routineState then 
            self:setState(STATE_ROUND_END)
        end    
    end
    
    if self.routineState == STATE_ROUND_END then
        self:onRoundEnd()
        self:battleSummary()
        self:setState(STATE_ROUND_START)
    end

    if IS_SERVER_CODE == nil then
        if BattleLogConfig.roundResult then
--           require("Utils.GenUtils").printTable(self.curRecord,"round result",5)
        end
    end
    table.insert(self.totalRecord,clone(self.curRecord))
end

function BattleMgr:jumpBattle()
    
    while true do
        if self.isGameOver == true then
            return self.result
        end

        if self.routineState ~= STATE_WAIT_SELECT_SKILL then
            self:setState(STATE_ROUND_START)
            self:routine()
        end

        if self.teams[TEAM_A].currentPet then
            self.teams[TEAM_A].currentPet.selectSkillIndex = -1
        end

        if self.teams[TEAM_B].currentPet then
            self.teams[TEAM_B].currentPet.selectSkillIndex = -1
        end

        self:setState(STATE_FIGHT_ONE)
        self:routine()
    end

end

function BattleMgr:getBattleHpResult()
    
    local petOrder = {}

    petOrder[1] = {}
    for i=1,#self.teams[TEAM_A].pets do
        if self.teams[TEAM_A].pets[i].objID then
            petOrder[1][self.teams[TEAM_A].pets[i].objID] = self.teams[TEAM_A].pets[i].hp
        end
    end
    
    petOrder[2] = {}
    for i=1,#self.teams[TEAM_B].pets do
        if self.teams[TEAM_B].pets[i].objID then
            petOrder[2][self.teams[TEAM_B].pets[i].objID] = self.teams[TEAM_B].pets[i].hp
        end
    end 
    return petOrder

end

function BattleMgr:getTotalRecord()
    return self.totalRecord
end

function BattleMgr:getRoutineState()
    return self.routineState
end

function BattleMgr:setRoutineState(state)
    self.routineState = state
end

function BattleMgr:battleSummary()

    if (nil == self.teams[TEAM_A].currentPet or nil == self.teams[TEAM_B].currentPet) then
        printError("At least one current pet is nil !")
    end

    local plaPetID = 0
    local emPetID = 0
    local petA = self.teams[TEAM_A].currentPet
    local petB = self.teams[TEAM_B].currentPet

    petA:clearBuffDamages()
    petA:clearBuffCures()
    petB:clearBuffDamages()
    petB:clearBuffCures()

    if (petA.hp <= 0) then
        petA.hp = 0
        petA:dispatchBattleEvent(PET_DEAD)
        if (true == petA.killedBySelf) then
            petA.killedBySelf = false
            petA:dispatchBattleEvent(KILL_PET)
            self:addToDamageTable("kill",petA,petA)
        else
            petB:dispatchBattleEvent(KILL_PET)
            self:addToDamageTable("kill",petB,petA)
            self.killPetsNumB = self.killPetsNumB + 1
        end
    end

    if (petB.hp <= 0) then
        petB.hp = 0
        petB:dispatchBattleEvent(PET_DEAD)
        if (true == petB.killedBySelf) then
            petB:dispatchBattleEvent(KILL_PET)
            self:addToDamageTable("kill",petB,petB)
        else
            petA:dispatchBattleEvent(KILL_PET)
            self:addToDamageTable("kill",petA,petB)
            self.killPetsNumA = self.killPetsNumA + 1
        end
    end

    if (true == petA.immuneResurrect) then
        petA.immuneResurrect = false
        petA:clearBuffCures()
    end
    if (true == petB.immuneResurrect) then
        petB.immuneResurrect = false
        petB:clearBuffCures()
    end

    local buffDamagesA = {}
    buffDamagesA = self:saveBuffState(buffDamagesA, petA, true)

    local buffDamagesB = {}
    buffDamagesB = self:saveBuffState(buffDamagesB, petB, true)

    self:add2CurRecord({
        buffDamage = true,
        buffDamagesA,
        buffDamagesB,
    })

    local changePet = false
    if (petA.hp <= 0) then
        self:setState(STATE_ROUND_END)
        plaPetID = self.teams[TEAM_A]:forceChangePet()
        changePet = true
    end

    if (petB.hp <= 0) then
        self:setState(STATE_ROUND_END)
        emPetID = self.teams[TEAM_B]:forceChangePet()
        changePet = true
    end
    
    if plaPetID < 0 then
        self:setState(STATE_BATTLE_END)
        self.isGameOver = true
        self.enemyWin = true
    end
    
    if emPetID < 0 then
        self:setState(STATE_BATTLE_END)
        self.isGameOver = true
        self.playerWin = true
    end
    
    if self.playerWin and self.enemyWin then
        self.playerWin = false
        self.result    = 2

    elseif self.playerWin then
        self.result  = 1

    elseif self.enemyWin then
        self.result = 0
    end

    self:saveChangePet()
    if self.isGameOver then
        self:add2CurRecord({gameover = true,self.result})
    end

    if changePet and self.isGameOver == false then
        self.eachRound = 0
    end

    if self.routineState == STATE_ROUND_END and self.eachRound >= 50 then
        petA.hp = 0
        petB.hp = 0
        self.eachRound = 0
        self:battleSummary()
    end
    
end

function BattleMgr:checkPetEnterBattle()
    local onPets = {}
    if self.teams[TEAM_A].currentPet == nil then
        self.teams[TEAM_A].currentPet = self.teams[TEAM_A][1]
        self.teams[TEAM_A].petIndex = 1
    end

    if self.teams[TEAM_B].currentPet == nil then
        self.teams[TEAM_B].currentPet = self.teams[TEAM_B][1]
        self.teams[TEAM_B].petIndex = 1
    end
end

function BattleMgr:setState(state)
    self.routineState = state
end

function BattleMgr:OnRoundStart() 

    local enterPets = {}
    
    -- 判断双方是否有宠上场
    if self.teams[TEAM_A]:checkPetEnter() then
        table.insert(enterPets,TEAM_A)
    end

    if self.teams[TEAM_B]:checkPetEnter() then
        table.insert(enterPets,TEAM_B)
    end
    
    self.teams[TEAM_A]:resetEnergyIncrement()
    self.teams[TEAM_B]:resetEnergyIncrement()

    if nil ~= self.teams[TEAM_A].currentPet then
        self.teams[TEAM_A].currentPet:refreshBuff()
        self.teams[TEAM_A].currentPet:dispatchBattleEvent(ROUND_START)
    end
    if nil ~= self.teams[TEAM_B].currentPet then
        self.teams[TEAM_B].currentPet:refreshBuff()
        self.teams[TEAM_B].currentPet:dispatchBattleEvent(ROUND_START)
    end
    self.round = self.round + 1
    self.eachRound = self.eachRound + 1
    self:add2CurRecord({round = self.round}) 
    
    --增加能量 
    self.teams[TEAM_A]:addEnergy()
    self.teams[TEAM_B]:addEnergy()
    self:add2CurRecord({energy = {self.teams[TEAM_A].energy, self.teams[TEAM_B].energy}, pp = 1,})

    self:add2CurRecord({petEnter = true,pets = enterPets})
    --选择技能
    self:add2CurRecord({selectSkill = true,teamA = true,teamB = true})

    if self.round == 1 then
        self.teams[TEAM_A].currentPet:tryUsePotentialSkill("dead_changepet")
        self.teams[TEAM_B].currentPet:tryUsePotentialSkill("dead_changepet")
    end
    self:saveBuffInfo()
end

function BattleMgr:onRoundEnd()

    local buffDamagesA = {}
    local buffDamagesB = {}
    local petA = self.teams[TEAM_A].currentPet
    local petB = self.teams[TEAM_B].currentPet
    if (nil ~= petA) then
        petA.killedBySelf = false
        petA:clearBuffDamages()
        petA:clearBuffCures()
    end
    if (nil ~= petB) then    
        petB.killedBySelf = false
        petB:clearBuffDamages()
        petB:clearBuffCures()
    end

    if (nil ~= petA) then
        if (true == petA.nextRoundCritical) then
            petA.nextRoundCritical = false
        end
        petA:dispatchBattleEvent(ROUND_END)
    end
    
    if (nil ~= petB) then
        if (true == petB.nextRoundCritical) then
            petB.nextRoundCritical = false
        end
        petB:dispatchBattleEvent(ROUND_END)
    end
    
    if (nil ~= petA) then
        if (true == petA.immuneResurrect) then
            petA.immuneResurrect = false
            petA:clearBuffCures()
        end
        buffDamagesA = self:saveBuffState(buffDamagesA, petA, true)
    end
    if (nil ~= petB) then
        if (true == petB.immuneResurrect) then
            petB.immuneResurrect = false
            petB:clearBuffCures()
        end
        buffDamagesB = self:saveBuffState(buffDamagesB, petB, true)
    end
   
    self:checkPassiveSkills()
    self:add2CurRecord({
        buffDamage = true,
        buffDamagesA,
        buffDamagesB,
    })

    if (nil ~= petA) then
        petA:dispatchBattleEvent(AFTER_ROUND_END)
    end
    if (nil ~= petB) then
        petB:dispatchBattleEvent(AFTER_ROUND_END)
    end

    if (nil ~= self.teams[TEAM_A].currentPet) then
        self.teams[TEAM_A]:reset()
    end
    
    if (nil ~= self.teams[TEAM_B].currentPet) then
        self.teams[TEAM_B]:reset()
    end

    self:saveBuffInfo()

end


function BattleMgr:ctor(info, weather)
    self.round         = 0
    self.gameStart     = true
    self.petInfo            = info

    --当前战斗信息顺序为 攻方、技能类型、被攻击方
    self.petsChange         = {false,-1,-1,false,-1,-1}
    self.forceChangePet     = false
    self.playerWin          = false
    self.enemyWin           = false
    self.result             = -1
    
    self.m_curWeather = Proto.AWT_NONE
    if weather then
        self.m_curWeather = weather
    end
    self.m_preWeather = Proto.AWT_NONE
    self.weatherChanged = false
    
    self.triggerWeather     = false
    self.currPetID       = {}
    self.currPetID[TEAM_A]     = 1
    self.currPetID[HISPETS]    = 1
    self.currPetInfo     = {}
    self.currPetInfo[TEAM_A]   = self.petInfo[TEAM_A][OUTPETS][self.currPetID[TEAM_A]]
    self.currPetInfo[HISPETS]  = self.petInfo[HISPETS][OUTPETS][self.currPetID[HISPETS]]
    --技能伤害数值
    self.curSelectedSkillTable      = {}
    self.curSelectedSkillTable[0]   = {false, false, false, false, false}
    self.curSelectedSkillTable[1]   = {false, false, false, false, false}
    self.curRoundFightInfo          = {}
    self.isGameOver                 = false
    self.curBlood                   = {}
    self.curBlood[TEAM_A]                = clone(self.currPetInfo[TEAM_A]["blood"])
    self.curBlood[HISPETS]               = clone(self.currPetInfo[HISPETS]["blood"])

    self.isProfouSkill                  = {}
    self.isProfouSkill[TEAM_A]          = false
    self.isProfouSkill[HISPETS]         = false

    self.preSkill               = {}
    self.preSKillIndex          = {}

    self.recordBattle           = {}
    self.applyBuffandPass       = {}

    self.preSkill[0]            = {}
    self.preSkill[1]            = {}
    self.preSKillIndex[0]       = 0
    self.preSKillIndex[1]       = 0


    self.result         = -1

    self:clearCurRecord()
    --zhangtonghai
    self.teams = {}
    self.teams[TEAM_A] = Team.new(info[TEAM_A],TEAM_A)
    self.teams[TEAM_B] = Team.new(info[TEAM_B],TEAM_B)
    self.routineState = STATE_ROUND_START

    self.totalRecord = {}

    self.eachRound = 0

    self.BossHp = 0

    self.BossHpChangeTab = {}

    self.damageTable = {}

    self.petAppear = true

    self.killPetsNumA = 0
    self.killPetsNumB = 0

    self.selectAoyiNumA = 0
    self.selectAoyiNumB = 0

    self.totalDamageA = 0
    self.totalDamageB = 0

    self.totalCureA = 0
    self.totalCureB = 0

    self.criticalNumA = 0
    self.criticalNumB = 0

    self.missNumA = 0
    self.missNumB = 0

    self.elementAttA = {}
    self.elementAttB = {}

    local petInfoA = info[TEAM_A]
    for i = 1,#petInfoA[OUTPETS] do
        local pokeID = petInfoA[OUTPETS][i].pokeID
        local elementAtt = PokemonInfo.getPokemonInfoByID(pokeID).elementAtt1
        local elementAtt2 = PokemonInfo.getPokemonInfoByID(pokeID).elementAtt2
        table.insert(self.elementAttA, elementAtt)
        table.insert(self.elementAttA, elementAtt2)
    end

    local petInfoB = info[TEAM_B]
    for i = 1,#petInfoB[OUTPETS] do
        local pokeID = petInfoB[OUTPETS][i].pokeID
        local elementAtt = PokemonInfo.getPokemonInfoByID(pokeID).elementAtt1
        local elementAtt2 = PokemonInfo.getPokemonInfoByID(pokeID).elementAtt2
        table.insert(self.elementAttB, elementAtt)
        table.insert(self.elementAttB, elementAtt2)
    end

end

function BattleMgr:getBattleInfo()

    local elementAttA = {}
    for i=1,19 do
        elementAttA[i] = 0
    end
    for i=1,#self.elementAttA do
        elementAttA[self.elementAttA[i]+1] = 1
    end
    local elementAttB = {}
    for i=1,19 do
        elementAttB[i] = 0
    end
    for i=1,#self.elementAttB do
        elementAttB[self.elementAttB[i]+1] = 1
    end
    return { 
            a = {   killpet = self.killPetsNumA,
                    releaseskill = self.selectAoyiNumA,
                    roundwin = self.round,
                    damage = self.totalDamageA,
                    crit = self.criticalNumA,
                    dodge = self.missNumA,
                    restore = self.totalCureA,
                    departmentpet = elementAttA,
                },

            b = {   killpet = self.killPetsNumB,
                    releaseskill = self.selectAoyiNumB,
                    roundwin = self.round,
                    damage = self.totalDamageB,
                    crit = self.criticalNumB,
                    dodge = self.missNumB,
                    restore = self.totalCureB,
                    departmentpet = elementAttB,
                } 
        }

end

function BattleMgr:oneRoundInfo()
    self:UseSkill()
    self:rankcurRoundFightInfo()
end

function BattleMgr:changePetAndSendInfo(petType,toPetID) 
    local orgPetID      = self.currPetID[petType]

    self.currPetID[petType] = toPetID   
    
    local team = petType
    local showSix  = {self.teams[TEAM_A].currentPet:storeAttrubiteInfo(),self.teams[TEAM_B].currentPet:storeAttrubiteInfo()}

    if nil == self.changePetRecord then
        self.changePetRecord = {}
    end
    table.insert(self.changePetRecord,{changePet = true,team,toPetID,showSix,
        hp= self.teams[team].currentPet.hp})
--    table.insert(self.curRecord,{changePet = true,team,toPetID,showSix}) 
    print("changePetAndSendInfo",self.teams[TEAM_A].currentPet.hp,self.teams[TEAM_B].currentPet.hp)
    self:setPetChange(false,team,-1)

    self.preSkill[team] = {}

    self.teams[team].currentPet:dispatchBattleEvent(PET_DISAPPEAR)

    self.teams[team].currentPet:clearBuffs()

    local petIndex = toPetID
    self.teams[team].petIndex = petIndex
    self.teams[team].currentPet = self.teams[team].pets[petIndex]

    self.teams[team].currentPet:dispatchBattleEvent(PET_APPEAR)

    self.teams[team]:onPetDie()

end

function BattleMgr:changePetCleanInfo(petType)
    self.preSkill[petType] = {}
    self.curBlood[petType] = clone(self.currPetInfo[petType]["blood"])
end

function BattleMgr:reset()
    
    self.attackCount = 1
    self.damageTbl = {}
    local size = table.getn(self.curRoundFightInfo)
    if self.curRoundFightInfo[size].attackSide == TEAM_A then
        self.attackTeam = self.teams[TEAM_A]
        self.defenceTeam = self.teams[TEAM_B]
    else  
        self.attackTeam = self.teams[TEAM_B]
        self.defenceTeam = self.teams[TEAM_A]     
    end

    --self.useSkillIndex = self.attackTeam.currentPet.selectSkillIndex    -- 大于4之后,有特殊含义 5表示无法行动 6表示换宠
    self.attackPet = self.attackTeam.currentPet
    self.defencePet = self.defenceTeam.currentPet
    
    self.attackTarget = self.defencePet
    --self.weatherChanged = false

    if self.petAppear then
        self.teams[TEAM_A].currentPet:tryUsePassiveSkill(PET_APPEAR)
        self.teams[TEAM_B].currentPet:tryUsePassiveSkill(PET_APPEAR)
        self.petAppear = false
    end

end

function BattleMgr:enterPetPerform()
    if #self.curRoundFightInfo <= 0 then
        return
    end

    self:reset()

    if IS_SERVER_CODE == nil then
		if (BattleLogConfig.roundLogFlag == true) then
			printFileLog(string.format("%s:第%d回合",self.attackPet.name,self.round))
		end
    end
    
    local size = table.getn(self.curRoundFightInfo)
    local skillInfo         = nil
    local stopSkill         = nil
    
    self.applyBuffandPass = {}
    
    self.attackPet:clearBuffDamages()
    self.attackPet:clearBuffCures()
    self.defencePet:clearBuffDamages()
    self.defencePet:clearBuffCures()


    if self.attackPet.selectSkillIndex == 6 then
        local changePetID   = -1
        local orgPetID      = self.currPetID[self.attackTeam.side]
        if self.attackTeam.side == 0 then
            changePetID = self.petsChange[3]
        else
            changePetID = self.petsChange[6]
        end
        if true == self.attackPet.attributes.canChangePet then
            self:changePetAndSendInfo(self.attackTeam.side,changePetID)
            self:saveChangePet()
        end    

    else
        if self.attackPet.hp <= 0 or self.defencePet.hp <= 0 then
            print("team",self.attackPet.team.side)
            for i=1,#self.attackPet.team.pets do
                if self.attackPet.team.pets[i] then
                    print("hp",self.attackPet.team.pets[i].hp)
                end
            end
            print("team",self.defencePet.team.side)
            for i=1,#self.defencePet.team.pets do
                if self.defencePet.team.pets[i] then
                    print("hp",self.defencePet.team.pets[i].hp)
                end
            end
            if IS_SERVER_CODE then
                return
            end
            assert(false)
            self.attackPet.selectSkillIndex = 5
            self.curRoundFightInfo[size][2] = 5
        end

        self.attackTarget = self.defencePet
        self.attackType = nil
        
        
        local skill = self.attackPet.skills[self.attackPet.selectSkillIndex]
        if true == self.attackPet:testUseSkill(skill) then
            self.attackPet.selectedSkill = skill
            self.attackPet:paySkillCost(skill)          
        else
            --表现不能动
            if (self.attackType ~= ATTACK_CHAOS) then
                self.attackPet.selectSkillIndex = 5
            end
            skill = nil
        end
        self.currentAttackCount = 0
        self.attackPet:savePetAttributes()
        while self.currentAttackCount < self.attackCount do
            self.currentAttackCount = self.currentAttackCount + 1
            if self.currentAttackCount > 1 then
                --检查死亡状态
                if self.attackPet.hp <= 0 or self.defencePet.hp <= 0 then
                    break
                end
                --尝试再次使用技能
                if false == self.attackPet:testUseSkill(skill) then
                    break
                end
            end
            printFileLog(string.format("%s 第%d/%d次攻击",self.attackPet.name,self.currentAttackCount,self.attackCount))
            if nil ~= skill then
                self.attackPet:useSkill(skill)
            end

            self.damageTbl = self:saveBuffState(self.damageTbl, self.attackPet, true)
            self.damageTbl = self:saveBuffState(self.damageTbl, self.defencePet, false)

            self:tryIncreaseAnger()
            self:savePetPerform()
            self:saveChangePet()
        end
    end
    
    self:saveBuffInfo()
    
    table.remove(self.curRoundFightInfo, #self.curRoundFightInfo)

end

function BattleMgr:tryIncreaseAnger()
    local increaseAnger = false
    local increaseAnger2 = false
    for key, var in pairs(self.damageTbl)  do
        if var["enemydamage"] ~= nil and self.defencePet.isAddAnger then
            increaseAnger =  true
        end
        if self.attackType == ATTACK_CHAOS and var["selfdamage"] ~= nil and self.attackPet.isAddAnger then
            increaseAnger2 =  true
        end              
    end

    if true == increaseAnger then
        self.defencePet:increaseAnger()
    end
    if true == increaseAnger2 then
        self.attackPet:increaseAnger()
    end
    self.defencePet.isAddAnger = true
    self.attackPet.isAddAnger  = true
end

function BattleMgr:saveBuffInfo()
    --zhangtonghai buff信息
    local aBuffs = {}
    local bBuffs = {}
    for i=1,#self.teams[TEAM_A].currentPet.buffs do
        local buff = self.teams[TEAM_A].currentPet.buffs[i]
        local info = buff:storeInfo()
        if nil ~= info then
            aBuffs[i] = buff:storeInfo()
        end
    end
    for i=1,#self.teams[TEAM_B].currentPet.buffs do
        local buff = self.teams[TEAM_B].currentPet.buffs[i]
        local info = buff:storeInfo()
        if nil ~= info then
            bBuffs[i] = buff:storeInfo()
        end
    end

    self:add2CurRecord({checkBuffer=true,aBuffs,bBuffs})
end

function BattleMgr:savePetPerform()

    if (self.attackPet.hp < 0) then
        self.attackPet.hp = 0
    end
    if (self.defencePet.hp < 0) then
        self.defencePet.hp = 0
    end
    
    local oneTurnDamageTable = {self.damageTbl,table.getn(self.damageTbl),self.defencePet.hp,self.attackPet.hp}
    if (ATTACK_CHAOS == self.attackType) then
        oneTurnDamageTable.chaos = true
    end
    local sendAnger      = {self.defenceTeam.currentPet.anger,self.attackTeam.currentPet.anger} 
    local sendEnergy     = {self.defenceTeam.energy,self.attackTeam.energy}
    local showSix        = {self.teams[TEAM_A].currentPet:storeAttrubiteInfo(),self.teams[TEAM_B].currentPet:storeAttrubiteInfo()}
    self.damageTbl = {}
    
    self:checkPassiveSkills()
    --援助技能信息
    local aAssistSkills = {}
    local bAssistSkills = {}
    for k,v in pairs(self.teams[TEAM_A].currentPet.triggeredAssistSkills) do
        aAssistSkills[#aAssistSkills+1] = v
    end
    for k,v in pairs(self.teams[TEAM_B].currentPet.triggeredAssistSkills) do
        bAssistSkills[#bAssistSkills+1] = v
    end
    if #aAssistSkills > 0 then
        self:add2CurRecord({assistSkill=true,aAssistSkills})
        self.teams[TEAM_A].currentPet.triggeredAssistSkills = {}
    end
    if #bAssistSkills > 0 then
        self:add2CurRecord({assistSkill=true,bAssistSkills})
        self.teams[TEAM_B].currentPet.triggeredAssistSkills = {}
    end
    if IS_SERVER_CODE == nil and BattleLogConfig.passiveSkillTrigger then
        printFileLog("show passive skill A:",self.teams[TEAM_A].currentPet.pokeID,#self.teams[TEAM_A].currentPet.buffs)
        for k,v in pairs(self.teams[TEAM_A].currentPet.triggeredPassiveSkills) do
            local skill = v
            -- dump(skill:storeInfo())
        end
        printFileLog("show passive skill B:",self.teams[TEAM_B].currentPet.pokeID,#self.teams[TEAM_B].currentPet.buffs)
        for k,v in pairs(self.teams[TEAM_B].currentPet.triggeredPassiveSkills) do
            local skill = v
            -- dump(skill:storeInfo())
        end
    end
    --zhangtonghai 战斗信息
    self:add2CurRecord({
        ani = true,
        self.attackTeam.side,
        self.attackTeam.currentPet.selectSkillIndex,
        self.defenceTeam.side,
        oneTurnDamageTable,
        sendAnger,
        sendEnergy,
        showSix,
    })

    if true == self.weatherChanged then 
        self.weatherChanged = false
        self:add2CurRecord({changeWeather = self:getCurWeather()})
    end
end

function BattleMgr:saveChangePet()
    if nil == self.changePetRecord then
        return
    end
    for i=1,#self.changePetRecord do
        self:add2CurRecord(self.changePetRecord[i])
    end
    self.changePetRecord = nil
end

function BattleMgr:NeedRunBattleStart()
	return table.getn(self.curRoundFightInfo) == 0
end

function BattleMgr:clearCurRecord()
    self.curRecord = {} 
    self.changePetRecord = nil
end

function BattleMgr:add2CurRecord(content)
    if content.showSelectSkill then
        if #self.curRecord > 1 then
            table.insert(self.curRecord, 2, content)
        else
            table.insert(self.curRecord, 1, content)
        end
    else
        table.insert(self.curRecord, content)
    end
end

function BattleMgr:getCurRecord()    
    return self.curRecord
end

function BattleMgr:getEnergy()
    return self.energy
end

function BattleMgr:rankPassiveSkills(timing_0,otming_1)
end

function BattleMgr:checkPassiveSkills()
    --zhangtonghai 被动技能信息 
    local aPassiveSkills = {}
    local bPassiveSkills = {}
    for k,v in pairs(self.teams[TEAM_A].currentPet.triggeredPassiveSkills) do
        local skill = v
        aPassiveSkills[#aPassiveSkills+1] = skill:storeInfo()
    end
    for k,v in pairs(self.teams[TEAM_B].currentPet.triggeredPassiveSkills) do
        local skill = v
        bPassiveSkills[#bPassiveSkills+1] = skill:storeInfo()
    end

    self:add2CurRecord({triggeredPassiveSkill=true,aPassiveSkills,bPassiveSkills})
end

function BattleMgr:applySkillEffect(petType,skillEffect)
    local anoType = 0
    if petType == 0 then
        anoType = 1
    end

    if skillEffect then
        
        if skillEffect[1]["selfheal"] ~= nil then
            if self.curBlood[petType] > 0 then
                self.curBlood[petType] = self.curBlood[petType] + skillEffect[1]["selfheal"]
                if self.curBlood[petType] > self.currPetInfo[petType]["bloodLimit"] then
                    self.curBlood[petType] = self.currPetInfo[petType]["bloodLimit"]
                end
            else
                skillEffect[1]["selfheal"] = nil
            end
        end   
        
        if skillEffect[1]["enemyheal"] ~= nil then
            if self.curBlood[anoType] > 0 then
                self.curBlood[anoType] = self.curBlood[anoType] + skillEffect[1]["enemyheal"]
                if self.curBlood[anoType] > self.currPetInfo[anoType]["bloodLimit"] then
                    self.curBlood[anoType] = self.currPetInfo[anoType]["bloodLimit"]
                end
            else
                skillEffect[1]["enemyheal"] = nil
            end
        end

        if skillEffect[1]["selfBuffer"] ~= nil then
            local buffID    = tostring(skillEffect[1]["selfBuffer"].id)
            local skillInfo =  PokemonInfo.getPetSkillInfoById(skillEffect[1]["selfBuffer"]["id"])
            local bufferInfo =  PokemonInfo.getPetBufferInfoByID(skillEffect[1]["selfBuffer"]["buffid"])
            self.currPetInfo[petType]["buffer"][buffID]  = skillEffect[1]["selfBuffer"]
            self.currPetInfo[petType]["buffer"][buffID].bufferInfo = bufferInfo
            self.currPetInfo[petType]["buffer"][buffID].icon = skillInfo.icon
        end

        if skillEffect[1]["enemyBuffer"] ~= nil then
            local buffID    = tostring(skillEffect[1]["enemyBuffer"].id)
            local skillInfo =  PokemonInfo.getPetSkillInfoById(skillEffect[1]["enemyBuffer"]["id"])
            local bufferInfo =  PokemonInfo.getPetBufferInfoByID(skillEffect[1]["enemyBuffer"]["buffid"])
            self.currPetInfo[anoType]["buffer"][buffID]  = skillEffect[1]["enemyBuffer"]
            self.currPetInfo[anoType]["buffer"][buffID].bufferInfo = bufferInfo
            self.currPetInfo[anoType]["buffer"][buffID].icon = skillInfo.icon
        end

        if skillEffect[1]["selfdamage"] ~= nil then
            self.curBlood[petType] = self.curBlood[petType] - skillEffect[1]["selfdamage"]
            if self.curBlood[petType] < 0 then
                self.curBlood[petType] = 0
            end
        end

        if skillEffect[1]["enemydamage"] ~= nil then
            self.curBlood[anoType] = self.curBlood[anoType] - skillEffect[1]["enemydamage"]
            if self.curBlood[anoType] < 0 then
                self.curBlood[anoType] = 0
            end
        end
    end
end

function BattleMgr:TriggerSkill(effect,skillInfo,attacker,defencer,timing)
    ME      = attacker
    ENEMY   = defencer
    ROUND   = self.round
    SKILL   = skillInfo
    TIMEING = timing
    local f = loadstring("BattleSkill." .. effect .. "(ME,ENEMY,ROUND,TIMEING,SKILL)")
    f()
    local ret = BattleSkill["ret"]
    return ret
end

function BattleMgr:TriggerBuffer(buffer,me,enemy,timing)
    ME = me
    ENEMY = enemy
    ROUND = self.round
    TIMEING = timing
    BUFF = buffer
    local f = loadstring("BattleBuffer." .. buffer.bufferInfo.effect .. "(ME,ENEMY,ROUND,BUFF,TIMEING)")
    f()
    local ret = BattleBuffer["ret"]
    return ret
end

function BattleMgr:BufferEnd(buffer,me,enemy)
    ME = me
    ENEMY = enemy
    ROUND = self.round
    BUFF = buffer
    local f = loadstring("BattleBuffer." .. buffer.bufferInfo.endEffect .. "(ME,ENEMY,ROUND,BUFF)")
    f()
    local ret = BattleBuffer["ret"]
    return ret
end

function BattleMgr:getBattleRound()
    return self.round
end

function BattleMgr:rankcurRoundFightInfo()
    local petA = self.teams[TEAM_A].currentPet
    local petB = self.teams[TEAM_B].currentPet
    if (petA.selectSkillIndex == nil) or (petA.selectSkillIndex == -1) or (petA.selectSkillIndex > 10) then
        petA:autoSelectSkill()
    end
    if (petB.selectSkillIndex == nil) or (petB.selectSkillIndex == -1) or (petB.selectSkillIndex > 10) then
        petB:autoSelectSkill()
    end
    local skillIndexA = petA.selectSkillIndex
    local skillIndexB = petB.selectSkillIndex
    printFileLog(string.format("skillA:%d skillB:%d",skillIndexA,skillIndexB))
    
    local speedA = 10000 * petA:getAttribute(Proto.AT_SPEED) 
    local speedB = 10000 * petB:getAttribute(Proto.AT_SPEED)
    
    if 6 ~= skillIndexA then
        speedA = petA:getAttribute(Proto.AT_SPEED) 
            * petA.skills[skillIndexA].info.speed
    end
    if 6 ~= skillIndexB then
        speedB = petB:getAttribute(Proto.AT_SPEED) 
            * petB.skills[skillIndexB].info.speed
    end        
    
    printFileLog(string.format("speedA:%f speedB:%f",speedA,speedB))
    self.curRoundFightInfo = {}
    self.curRoundFightInfo[1] = {}
    self.curRoundFightInfo[2] = {}
    if speedA >= speedB then
        self.curRoundFightInfo[1].attackSide = TEAM_B
        self.curRoundFightInfo[2].attackSide = TEAM_A  
    else
        self.curRoundFightInfo[1].attackSide = TEAM_A
        self.curRoundFightInfo[2].attackSide = TEAM_B
    end
    
    self:reset()

end



function BattleMgr:UseSkill()
    local petA = self.teams[TEAM_A].currentPet
    local petB = self.teams[TEAM_B].currentPet
    
    if (petB.selectSkillIndex == nil) or (petB.selectSkillIndex == -1)then
        petB:autoSelectSkill()
    end
    table.insert(self.curRoundFightInfo,{TEAM_B,petB.selectSkillIndex,TEAM_A})

    -- 玩家使用技能
    if (petA.selectSkillIndex == nil) or (petA.selectSkillIndex == -1) then
        petA:autoSelectSkill()
    end
    table.insert(self.curRoundFightInfo,{TEAM_A,petA.selectSkillIndex,TEAM_B})

    if petA.selectSkillIndex == 4 then
        self.selectAoyiNumA = self.selectAoyiNumA + 1
    end

    if petB.selectSkillIndex == 4 then
        self.selectAoyiNumB = self.selectAoyiNumB + 1
    end

end

function BattleMgr:randomDamage(damage)
    local seed = math.floor(damage/10)
    local diff = GetRandom.random(-seed, seed)
    local rDamage = damage+diff
    return rDamage
end

function BattleMgr:setPetChange(isBool,petType,typeCard)
    if petType == 0 then
        self.petsChange[1] = isBool
        self.petsChange[2] = petType
        self.petsChange[3] = typeCard
    elseif petType == 1 then
        self.petsChange[4] = isBool
        self.petsChange[5] = petType
        self.petsChange[6] = typeCard
    end
end
--- @param petType  攻击宠的类型
--- @param petSkills  宠物技能
--- @param isProSkill  第四个技能是否可发动
function BattleMgr:getBattleAILogic(petType,petSkills,isProSkill) 
    if type(petSkills[1]) == "number" and type(petSkills[2]) == "number" 
    and type(petSkills[3]) == "number" and type(petSkills[4]) == "number" then   
        return 5
    end 

    
    if petSkills[4] ~= 0 and self.currPetInfo[petType].anger >= self.currPetInfo[petType].angerMax then
        return 4
    end

    local notBuffSKills = {}
    local useSKills = {}

    local largeEnergy = 0

    for key,var in pairs(petSkills) do
        if var ~= 0 then
            if key ~= 4 and key ~= 1 then
                local isUseKey = true
                for k,v in pairs(self.preSkill[petType]) do
                    if key == v then
                        isUseKey = false
                    end
                end
                if isUseKey and self.energy[petType] >= var.energy then
                    if var.energy > largeEnergy then
                        largeEnergy = var.energy
                    end
                    useSKills[#useSKills+1] = {key,var.energy}
                end
            end
        end
    end

    for key,var in pairs(useSKills) do
        if largeEnergy == var[2] then
            return var[1]
        end 
    end

    return 1

end

function BattleMgr:getPetInfo()
    return self.currPetInfo
end

function BattleMgr:getPetInfoChangeInfo()
    return self.petsChange
end

function BattleMgr:getcurRoundFightInfo()
    return self.curRoundFightInfo
end

function BattleMgr:setcurRoundFightInfo(value)
    self.curRoundFightInfo = value
end

function BattleMgr:clearcurRoundFightInfo()
    self.curRoundFightInfo = {}
end

function BattleMgr:setcurSelectedSkill(team,skillIndex,isBool)
    self.teams[team].currentPet.selectSkillIndex = skillIndex
end

function BattleMgr:getcurSelectedSkill(team)
    return self.teams[team].currentPet.selectSkillIndex
end

function BattleMgr:showLog(log)
    ChatMsgMgr.addSystemMsg(log)
end

function BattleMgr:getIsGameOver()
    return self.isGameOver
end

function BattleMgr:getBattleResult()
    return self.result
end

function BattleMgr:getIsEmptyFgtInfo()
    if table.getn(self.curRoundFightInfo) == 0 then
        return true
    end
    return false
end

function BattleMgr:resortObjs()
    local objects = {}
    objects[#objects + 1] = self.petInfo[0]["objID"]
    for key,var in pairs(self.frdPets["playerPets"]) do
        objects[#objects + 1] = var["objID"]
    end

    return objects
end

function BattleMgr:setRankStorePets(isbool,tbl)
    self.rankStorePetsInfo[1] = isbool
    self.rankStorePetsInfo["tbl"] = tbl
end

function BattleMgr:getIsPlayerWin()
    return self.playerWin
end

function BattleMgr:showTargetInfo(tag)
    printFileLog(string.format("%s:\tattacker:%s\n\ttarget:%s\n\tdefencer:%s",tag,self.attackPet.name,self.attackTarget.name,self.defencePet.name))
end

function BattleMgr:judgeHitRate()
    
    local isHit = GetRandom.random(0,9999) < CalHitRate(self.attackPet,self.attackTarget,
        self.attackPet:getSelectedSkill())*100
    -- print("judgeHitRate     ",self.mustHit,BattleCotroller.noMiss,isHit) 
    if self.mustHit or BattleCotroller.noMiss or isHit then
        self.miss = false 
        return true
    else
        self.miss = true 
        return false
    end
end

function BattleMgr:fight(damageRate, multiRate, isCure)
    if IS_SERVER_CODE == nil and (BattleLogConfig.fight == true) then
        printFileLog(string.format("%s:攻击开始 damageRate=%0.1f 宠物damageRate=%0.1f" ,self.attackPet.name,damageRate,self.attackPet.attributes.damageRate))
    end
    
    self.attackPet.killedBySelf = false
    self.defencePet.killedBySelf = false
        
    self.mustHit = false
    self.miss = true
    self.iscritical = false
    self.finaldamage = 0
    
    if nil == self.attackPet:getSelectedSkill() then
        assert(false)
    end

    if (nil ~= self.attackTarget and (true == self.mustHit or isCure or BattleCotroller.noMiss
        or GetRandom.random(0,99) < CalHitRate(self.attackPet,self.attackTarget, self.attackPet:getSelectedSkill()))) then--判断是否命中 
        self.miss = false
        self.iscritical = CalIsCritical(self.attackPet:getAttribute(Proto.AT_CRT), self.attackTarget:getAttribute(Proto.AT_ANTICRT), 0)--计算是否暴击
        if (true == self.attackPet.nextCritical or true == self.attackPet.nextRoundCritical) then
            self.attackPet.nextCritical = false
            self.iscritical = true
        end
    end
    self.attackPet:dispatchBattleEvent(BEFORE_ATTACK)
    self.attackTarget:dispatchBattleEvent(BEFORE_DEFENCE)
    if (nil ~= self.attackTarget and nil ~= self.attackType) then
        self.attackPet.attributes.damageRateElement = BattleAidFunc.getAttributeStateValue(self.attackPet:getSelectedSkill().info.id, self.attackTarget.pokeID)

        self.attackPet:dispatchBattleEvent(ATTACK)
        self.attackTarget:dispatchBattleEvent(DEFENCE)

        if self.mustHit and self.miss then
            self.miss = false        
            self.iscritical = CalIsCritical(self.attackPet:getAttribute(Proto.AT_CRT), self.attackTarget:getAttribute(Proto.AT_ANTICRT), 0)--计算是否暴击
            if (true == self.attackPet.nextCritical or true == self.attackPet.nextRoundCritical) then
                self.attackPet.nextCritical = false
                self.iscritical = true
            end
        end

        if self.miss == false then
            if (ATTACK_ATTACK == self.attackType) then
                self.finaldamage = CalDamage(self.attackPet, self.attackTarget, self.attackPet:getSelectedSkill(), self.iscritical)
                if self.attackPet:getSelectedSkill().info.skill_B_Type == 3 then
                    self.finaldamage = self.finaldamage*self.attackTarget.attributes.physicalDamageRate
                elseif self.attackPet:getSelectedSkill().info.skill_B_Type == 4 then
                    self.finaldamage = self.finaldamage*self.attackTarget.attributes.magicDamageRate
                end
            elseif (ATTACK_CHAOS == self.attackType) then
                local chaosSkill = Skill.new(421, 1, 1)
                self.finaldamage = CalDamage(self.attackPet, self.attackTarget, chaosSkill, false)
                if chaosSkill.info.skill_B_Type == 3 then
                    self.finaldamage = self.finaldamage*self.attackTarget.attributes.physicalDamageRate
                elseif chaosSkill.info.skill_B_Type == 4 then
                    self.finaldamage = self.finaldamage*self.attackTarget.attributes.magicDamageRate
                end
            else
                self.finaldamage = CalCure(self.attackPet, self.attackTarget, self.attackPet:getSelectedSkill(), self.iscritical)
            end
            self.finaldamage = BattleAidFunc.normalize(self.finaldamage*damageRate)
            if IS_SERVER_CODE == nil and (BattleLogConfig.fight == true) then
                printFileLog(string.format("%s:finaldamage=%d miss =",self.attackPet.name,self.finaldamage),self.miss,"暴击 =",self.iscritical)
            end
        end
        
        self.attackPet:dispatchBattleEvent(AFTER_ATTACK)
        self.attackTarget:dispatchBattleEvent(AFTER_DEFENCE)

        if (ATTACK_ATTACK == self.attackType or ATTACK_CHAOS == self.attackType) then
            self.attackTarget:getDamage(self.finaldamage, self.attackPet.attributes.ignoreDef)
            self:addToDamageTable(self.finaldamage,self.attackPet,self.attackTarget)
            if (nil ~= multiRate) then
                local multiDamage = BattleAidFunc.normalize(self.finaldamage * multiRate)
                for i = 1, #self.defenceTeam.pets do
                    if (i ~= self.defenceTeam.petIndex) then
                        self.defenceTeam.pets[i]:getDamage(multiDamage)
                        self:addToDamageTable(multiDamage,self.attackPet,self.defenceTeam.pets[i])
                    end
                end
            end
            if ATTACK_ATTACK == self.attackType and self.attackTarget.roundDamage > 0 then
                self.attackPet:dispatchBattleEvent(REAL_GET_DAMAGE)
            end
        else
            self.attackTarget:getCure(self.finaldamage)
            if (nil ~= multiRate) then
                local multiCure = BattleAidFunc.normalize(self.finaldamage * multiRate)
                for i = 1, #self.attackTeam.pets do
                    if (i ~= self.attackTeam.petIndex) and (self.attackTeam.pets[i].hp > 0) then
                        self.attackTeam.pets[i]:getCure(multiCure)
                    end
                end
            end
        end

        self.attackPet:dispatchBattleEvent(ATTACK_COMPLETE)
        self.attackTarget:dispatchBattleEvent(DEFENCE_COMPLETE)
    end
    --处理战斗结果
    local result = {}
    if nil ~= self.attackTarget and nil ~= self.attackType then
        if self.miss == false then
            if (ATTACK_ATTACK == self.attackType or ATTACK_CHAOS == self.attackType) then
                local realDamage = self.finaldamage

                if self.attackTarget.attributes.limitDamage > 0 and realDamage > self.attackTarget.attributes.limitDamage then
					if self.attackTarget.attributes.mustDie then
						realDamage = self.finaldamage
					else
						realDamage = self.attackTarget.attributes.limitDamage
					end
                end

                if (true == self.attackTarget.attributes.invincible) then
                    realDamage = 0
                end

                if self.attackPet.attributes.ignoreDef then
                    realDamage = self.finaldamage
                end

                if self.attackTarget == self.defencePet then
                    result.enemydamage = BattleAidFunc.normalize(realDamage)
                    if (nil ~= multiRate) then
                        result.enemyOtherDamages = BattleAidFunc.normalize(self.finaldamage * multiRate)
                    end
                else
                    result.selfdamage = BattleAidFunc.normalize(realDamage)
                    if (nil ~= multiRate) then
                        result.selfOtherDamages = BattleAidFunc.normalize(self.finaldamage * multiRate)
                    end
                end
            else
                if (self.attackPet == self.attackTarget) then
                    result.selfheal = BattleAidFunc.normalize(self.finaldamage)
                    if (nil ~= multiRate) then
                        result.selfOtherHeals = BattleAidFunc.normalize(self.finaldamage * multiRate)
                    end
                else
                    result.enemyheal = BattleAidFunc.normalize(self.finaldamage)
                    if (nil ~= multiRate) then
                        result.enemyOtherHeals = BattleAidFunc.normalize(self.finaldamage * multiRate)
                    end
                end
            end
            result.critical = self.iscritical

            if self.iscritical and ATTACK_ATTACK == self.attackType then
                if self.attackPet.team.side == TEAM_A then
                    self.criticalNumA = self.criticalNumA + 1
                else
                    self.criticalNumB = self.criticalNumB + 1
                end
            end

            if self.attackPet.attributes.damageRateElement == 1 then
                result.weak = true
            end
            self.attackTarget:dispatchBattleEvent(DAMAGE_COMPLETE)
        else
            result.miss = true

            if ATTACK_ATTACK == self.attackType then
                if self.attackPet.team.side == TEAM_A then
                    self.missNumB = self.missNumB + 1
                else
                    self.missNumA = self.missNumA + 1
                end
            end
        end
    end

    if #self.attackPet.newBuffs >0 then
        for i=1,#self.attackPet.newBuffs do
            local temp = {}
            temp.selfBuffer = self.attackPet.newBuffs[i]:storeInfo()
            if temp.selfBuffer then
                table.insert(self.damageTbl,temp)
            end
        end
        self.attackPet.newBuffs = {}
    end

    if #self.defencePet.newBuffs >0 then
        for i=1,#self.defencePet.newBuffs do
            local temp = {}
            temp.enemyBuffer = self.defencePet.newBuffs[i]:storeInfo()
            if temp.enemyBuffer then
                table.insert(self.damageTbl,temp)
            end
        end
        self.defencePet.newBuffs = {}
    end
     
    table.insert(self.damageTbl,result)

    self.damageTbl = self:saveBuffState(self.damageTbl, self.attackPet, true)
    self.damageTbl = self:saveBuffState(self.damageTbl, self.defencePet, false)
    
    BattleSkill["ret"] = result
    if IS_SERVER_CODE == nil and (BattleLogConfig.fight == true) then
        printFileLog(string.format("%s:攻击结束 damageRate=%0.1f damage=%d",self.attackPet.name,damageRate,self.finaldamage))
    end
    -- return self.damageTbl
end

function BattleMgr:fightByDamageValue(petOwner,petTarget,dmgageType,isHit)
    if self.attackTarget then
        self.attackPet:dispatchBattleEvent(BEFORE_ATTACK)
        self.attackTarget:dispatchBattleEvent(BEFORE_DEFENCE)
        if isHit then
            isHit = self:judgeHitRate()
        else
            isHit = true
        end
        if isHit then 
            if petOwner.damage > 0 then
                petOwner.damage = BattleAidFunc.normalize(petOwner.damage)
                petOwner:getDamage(petOwner.damage, petOwner.attributes.ignoreDef)
                self:addExtraDamage(petOwner.damage,true) 
            end
            if petTarget.damage > 0 then
                petTarget.damage = BattleAidFunc.normalize(petTarget.damage)
                petTarget:getDamage(petTarget.damage, petTarget.attributes.ignoreDef)
                self:addExtraDamage(petTarget.damage) 
            end
        else
            self:addMiss() 
        end
        self.attackPet:dispatchBattleEvent(AFTER_ATTACK)
        self.attackTarget:dispatchBattleEvent(AFTER_DEFENCE)
        self.attackPet:dispatchBattleEvent(ATTACK_COMPLETE)
        self.attackTarget:dispatchBattleEvent(DEFENCE_COMPLETE)
    end
end

function BattleMgr:fight2(multiRate)    

    if self.attackTarget then

        local damage = CalDamage(self.attackPet, self.attackTarget, self.attackPet:getSelectedSkill(), self.iscritical)
        if self.attackPet:getSelectedSkill().info.skill_B_Type == 3 then
            damage = damage*self.attackTarget.attributes.physicalDamageRate
        elseif self.attackPet:getSelectedSkill().info.skill_B_Type == 4 then
            damage = damage*self.attackTarget.attributes.magicDamageRate
        end

        local multiDamage = BattleAidFunc.normalize(damage * multiRate)
        for i = 1, #self.defenceTeam.pets do
            if (i ~= self.defenceTeam.petIndex) then
                self.defenceTeam.pets[i]:getDamage(multiDamage)
                self:addToDamageTable(multiDamage,self.attackPet,self.defenceTeam.pets[i])
            end
        end

        local result = {}
        if self.attackTarget == self.defencePet then
            result.enemyOtherDamages = multiDamage
        else
            result.selfOtherDamages = multiDamage
        end
         
        table.insert(self.damageTbl,result)
    end

end

function BattleMgr:addExtraDamage(damage,selfFlag)    

    local result = {}
    if selfFlag then
        result.selfdamage  = damage
    else
        result.enemydamage = damage
    end
    table.insert(self.damageTbl,result)

end

function BattleMgr:addMiss()    

    local result = {}
    result.miss = true
    table.insert(self.damageTbl,result)

end

function BattleMgr:saveBuffState(ret, pet, selfFlag)

    for i = 1, #pet.buffCures do
        local cure = BattleAidFunc.normalize(pet.buffCures[i]*pet:getAttribute(Proto.AT_HEALRATE)/1000)

        local val = { critical = false, }
        if (true == selfFlag) then
            val.selfheal = cure
        else
            val.enemyheal = cure
        end  
        table.insert(ret, val)

        pet:getCure(cure)
    end

    for i = 1, #pet.buffDamages do
        local damage = BattleAidFunc.normalize(pet.buffDamages[i])

        if pet.attributes.limitDamage > 0 and damage > pet.attributes.limitDamage then
            if pet.attributes.mustDie then
				damage = damage
			else
				damage = pet.attributes.limitDamage
			end
        end

        if (true == pet.attributes.invincible) then
            damage = 0
        end

        if pet.attributes.ignoreDef then
            damage = BattleAidFunc.normalize(pet.buffDamages[i])
        end

        local val = { critical = false, }
        if (true == selfFlag) then
            val.selfdamage = damage
        else
            val.enemydamage = damage
        end
        table.insert(ret, val)

        pet:getDamage(damage, pet.attributes.ignoreDef)
        self:addToDamageTable(damage,self:getEnemy(pet),pet)

        pet:dispatchBattleEvent(DAMAGE_COMPLETE)
    end

    pet:clearBuffDamages()
    pet:clearBuffCures()
    return ret

end

-- function BattleMgr:saveBuffState(ret, pet, selfFlag)

--     for i = 1, #pet.buffCures do
--         local cure = BattleAidFunc.normalize(pet.buffCures[i])

--         local val = { critical = false, }
--         if (true == selfFlag) then
--             val.selfheal = cure
--             pet:getCure(cure)
--         else
--             val.enemyheal = cure
--             local enemyPet = self:getEnemy(pet)
--             enemyPet:getCure(cure)
--         end
--         table.insert(ret, val)
        
--     end

--     for i = 1, #pet.buffDamages do
--         local damage = BattleAidFunc.normalize(pet.buffDamages[i])

--         if pet.attributes.limitDamage > 0 and damage > pet.attributes.limitDamage then
--             damage = pet.attributes.limitDamage
--         end

--         if (true == pet.attributes.invincible) then
--             damage = 0
--         end

--         if pet.attributes.ignoreDef then
--             damage = BattleAidFunc.normalize(pet.buffDamages[i])
--         end

--         local val = { critical = false, }
--         if (true == selfFlag) then
--             val.selfdamage = damage
--             pet:getDamage(damage, pet.attributes.ignoreDef)
--         else
--             val.enemydamage = damage
--             local enemyPet = self:getEnemy(pet)
--             enemyPet:getDamage(damage,pet.attributes.ignoreDef)  
--         end
--         table.insert(ret, val)
        
--         self:addToDamageTable(damage,self:getEnemy(pet),pet)

--         pet:dispatchBattleEvent(DAMAGE_COMPLETE)
--     end

--     pet:clearBuffDamages()
--     pet:clearBuffCures()
--     return ret

-- end

function BattleMgr:getEnemy(currentPet)
    if currentPet.team.side == TEAM_A then
        return self.teams[TEAM_B].currentPet
    end
    return self.teams[TEAM_A].currentPet
end

function BattleMgr:changeWeather(weather)

    if (weather ~= self.m_curWeather) then
        self.m_preWeather = self.m_curWeather
        self.m_curWeather = weather
        self.attackPet:dispatchBattleEvent(WEATHER_CHANGED)
        self.defencePet:dispatchBattleEvent(WEATHER_CHANGED)
        self.weatherChanged = true
    end

end

function BattleMgr:getCurWeather()

    return self.m_curWeather

end

function BattleMgr:getPreWeather()

    return self.m_preWeather

end

function BattleMgr:getAllWeatherEnums()

    local allWeatherTypes = {   Proto.AWT_NONE,
                                Proto.AWT_HOT, 
                                Proto.AWT_RAIN, 
                                Proto.AWT_WIND,
                                Proto.AWT_HOLE,
                                Proto.AWT_TUNDER,
                                Proto.AWT_SWAMP,
                                Proto.AWT_SUN,
                            }
    return allWeatherTypes

end

function BattleMgr:getPetsInfo(team)

    local petsinfo = {}
    for i = OUTPETS,INPETS do
        petsinfo[i] = {}
        local pets = {}
        if i == OUTPETS then
            pets = self.teams[team].pets
        else
            pets = self.teams[team].assistantPets
        end
        for j=1,#pets do
            local pet = pets[j]
            petsinfo[i][j] = { hp = pet.hp,
                                level = pet.level,
                                pokeID = pet.pokeID,
                                anger = pet.anger,
                                objID = self.petInfo[team][i][j].objID,
                                hpmax = self.petInfo[team][i][j].bloodLimit,
                                atk = self.petInfo[team][i][j].infomation.atk,
                                def = self.petInfo[team][i][j].infomation.def,
                                exp = self.petInfo[team][i][j].infomation.exp,
                                satk = self.petInfo[team][i][j].infomation.satk,
                                sdef = self.petInfo[team][i][j].infomation.sdef,
                                speed = self.petInfo[team][i][j].infomation.speed,
                                skills = self.petInfo[team][i][j].infomation.Skills,
                                paSkills = self.petInfo[team][i][j].infomation.paSkills}
        end
    end
    
    return petsinfo

end

function BattleMgr:getCurrentBattleInfo()

    return {TEAM_A = {energy = self.teams[TEAM_A].energy, pets = self:getPetsInfo(TEAM_A)}, 

            TEAM_B = {energy = self.teams[TEAM_B].energy, pets = self:getPetsInfo(TEAM_B)}, 

            weather = self.m_curWeather}

end

function BattleMgr:logCurrentPetHP(state)

    local hp_PetB = 0
    local PetB = self.teams[TEAM_B].currentPet
    if PetB then
        hp_PetB = PetB.hp
    end
    if state == 0 then
        self.BossHp = hp_PetB
    else
        self.BossHp = self.BossHp - hp_PetB
        if self.BossHp ~= 0 then
            table.insert(self.BossHpChangeTab , self.BossHp)
        end
    end

end

function BattleMgr:getCurrentPetHP()

    if #self.BossHpChangeTab > 0 then
        local hp = self.BossHpChangeTab[1]
        table.remove(self.BossHpChangeTab,1)
        return hp
    else
        return 0
    end

end

function BattleMgr:stopDamageCure(stop)

    if self.teams[TEAM_B].pets[1] then
        self.teams[TEAM_B].pets[1]:stopDamageCure(stop)
    end
    
end

function BattleMgr:setBossPetHP(hp)

    if self.teams[TEAM_B].pets[1] then
        self.teams[TEAM_B].pets[1].hp = hp
    end
    
end

function BattleMgr:getBossPetHP()

    if self.teams[TEAM_B].pets[1] then
        return self.teams[TEAM_B].pets[1].hp
    else
        return 0
    end
    
end

function BattleMgr:selectSkill(team)

    local pet = self.teams[team].currentPet
    if (pet.selectSkillIndex == nil) or (pet.selectSkillIndex == -1)then
        pet:autoSelectSkill()
    end

    self:addSelectSkillRecord(team)

end

function BattleMgr:addSelectSkillRecord(team)

    if self.teams[team].currentPet then
        self:add2CurRecord({showSelectSkill = true, team, self.teams[team].currentPet.selectSkillIndex})
    end

end

function BattleMgr:addToDamageTable(damage,attackPet,defencePet)

    if damage == "kill" then
        local selfKill = false
        if attackPet == defencePet then
            selfKill = true
        end
        if attackPet.team.side == TEAM_A then
            table.insert(self.damageTable,{team = attackPet.team.side,damage = damage,attackIndex = attackPet.index,defenceIndex = defencePet.index,selfKill = selfKill})
        else
            table.insert(self.damageTable,{team = attackPet.team.side,damage = damage,attackIndex = attackPet.index,defenceIndex = defencePet.index,selfKill = selfKill})
        end
    elseif damage > 0 then
        if attackPet.team.side == TEAM_A then
            table.insert(self.damageTable,{team = attackPet.team.side,damage = damage,attackIndex = attackPet.index})
        else
            table.insert(self.damageTable,{team = attackPet.team.side,damage = damage,attackIndex = attackPet.index})
        end
    end

end

function BattleMgr:getDamageTable()

    return self.damageTable

end

return BattleMgr