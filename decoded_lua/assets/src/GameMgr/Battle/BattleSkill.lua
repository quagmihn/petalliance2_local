local BattleSkill = {}
if IS_SERVER_CODE == nil then
    require("src.GameMgr.Battle.type_damage") 
end
BattleSkill.valueStore = {}
--BattleSkill.attacker.攻击方各属性
--BattleSkill.defencer.防御方各属性
--PokemonInfo.getPokemonInfoByID(BattleSkill.attacker.pokeID).攻击方读种族表的属性，防御方同理

--自定义技能全局变量创建
function setSkillUtilValue(tag,skillID,Tbl)
    local index = tostring(tag)
    if not BattleSkill.valueStore[index] then
        BattleSkill.valueStore[index] = {}
    end
    if not BattleSkill.valueStore[index][tostring(skillID)] then
        BattleSkill.valueStore[index][tostring(skillID)] = {}
    end
    if not Tbl then
        BattleSkill.valueStore[index][tostring(skillID)] = nil
        return
    end
    for key,var in pairs(Tbl) do
        if not BattleSkill.valueStore[index][tostring(skillID)][key] then
            BattleSkill.valueStore[index][tostring(skillID)][key] = var
        end
    end
end

--自定义技能全部变量使用
function getSkillUtilValue(tag,skillID)
    local index = tostring(tag)
    if not BattleSkill.valueStore[index] then
        printFileLog("技能lua 没有想要数据")
        return nil
    end
    if not BattleSkill.valueStore[index][tostring(skillID)] then
        printFileLog("技能lua 没有想要数据")
        return nil
    end
    
    return BattleSkill.valueStore[index][tostring(skillID)]
end

--判断是否处于某状态
function isbuffon(obj,id)
    for k,v in pairs(obj.buffer) do
        if v.buffid == id then
            return true
        end
    end
    return false
end

--命中计算
function CalHitRate(me,enemy,skill)--攻击方，防御方，技能信息  
    local a = me:getAttribute(Proto.AT_RATE) - enemy:getAttribute(Proto.AT_EVD)
    return a
end 
  
--计算是否暴击
function CalIsCritical(Critical,CritResistance,value)--暴击率，暴击抵抗，其他参数
    if GetRandom.random(0,9999) < (Critical - CritResistance + value)*100 then
        return true
    else
        return false
    end
end

--伤害修正比例计算
function CaldamageRate(me,skillElementType,enemy)--攻击方，技能属性，防御方,是否暴击
    local damageRate = me.attributes.damageRateElement
        * math.max(0,110 - enemy.attributes.Tenacity)/100 * GetRandom.random(85,100) /100
    if PokemonInfo.getPokemonInfoByID(me.pokeID).elementAtt1 == skillElementType 
       or PokemonInfo.getPokemonInfoByID(me.pokeID).elementAtt2 == skillElementType then
        damageRate = damageRate * 1.05
    end
    return damageRate
end

--计算伤害
function CalDamage(me,enemy,skill,iscritical)--攻击方，防御方，技能信息，暴击与否

    local damageRate = me.attributes.damageRate

    --计算伤害倍
    if iscritical == true then--暴击加成
        damageRate = damageRate * CaldamageRate(me,skill.info.skillAtt,enemy) * (me:getAttribute(Proto.AT_CRTHURT) / 100 )
    else
        damageRate = damageRate * CaldamageRate(me,skill.info.skillAtt,enemy)
    end

    --判断技能类型物理or特功
    --zhangtonghai disable power
    local damage = 1
    if skill.info.skill_B_Type == 3 then--物攻    
        local skillPower = skill:getPower()
        local def = enemy:getAttribute(Proto.AT_DEF) / (enemy:getAttribute(Proto.AT_DEF) + 500 + 30 * enemy.level)
        def = math.min(def + enemy:getAttribute(Proto.AT_DEFFIX)/100-me:getAttribute(Proto.AT_PENETRATION)/100, 1)
        damage = skillPower /100 * me:getAttribute(Proto.AT_ATK) * (1 - def) * damageRate
        if (IS_SERVER_CODE == nil and BattleLogConfig.skillCalDamageLogFlag == true) then
            printFileLog("CalDamage()", "AT_ATK:" .. me:getAttribute(Proto.AT_ATK), "AT_DEF:" .. enemy:getAttribute(Proto.AT_DEF), 
                "防御减免:" .. def, "技能威力:" .. skillPower, "damageRate:" .. damageRate, "damage:" .. damage)
            printFileLog(string.format("def:%f = 对手物防:%f / 对手物防:%f + 500 + 30 * 对手等级:%f)",def,enemy:getAttribute(Proto.AT_DEF),enemy:getAttribute(Proto.AT_DEF),enemy.level))    
            printFileLog(string.format("damage:%f = 技能威力:%f /100 * 自身物攻:%f * (1 - def:%f) * damageRate:%f)",damage,skillPower,me:getAttribute(Proto.AT_ATK),def,damageRate))
        end
    elseif skill.info.skill_B_Type == 4 then--特功
        local skillPower = skill:getPower()
        local def = enemy:getAttribute(Proto.AT_SDEF) / (enemy:getAttribute(Proto.AT_SDEF) + 500 + 30 * enemy.level)
        def = math.min(def + enemy:getAttribute(Proto.AT_SDEFFIX)/100-me:getAttribute(Proto.AT_SPENETRATION)/100, 1)
        damage = skillPower /100 * me:getAttribute(Proto.AT_SATK) * (1 - def) * damageRate
        if (IS_SERVER_CODE == nil and BattleLogConfig.skillCalDamageLogFlag == true) then
            printFileLog("CalDamage()", "AT_SATK:" .. me:getAttribute(Proto.AT_SATK), "AT_SDEF:" .. enemy:getAttribute(Proto.AT_SDEF), 
               "防御减免:" .. def, "技能威力:" .. skillPower, "damageRate:" .. damageRate, "damage:" .. damage)
            printFileLog(string.format("def:%f = 对手魔防:%f / (对手魔防:%f + 500 + 30 * 对手等级:%f)",def,enemy:getAttribute(Proto.AT_SDEF),enemy:getAttribute(Proto.AT_SDEF),enemy.level))    
            printFileLog(string.format("damage:%f = 技能威力:%f / (100 * 自身魔攻:%f * (1 - def:%f) * damageRate:%f)",damage,skillPower,me:getAttribute(Proto.AT_SATK),def,damageRate))   
        end
    end

    return BattleAidFunc.normalize(damage)
end

function CalCure(me, enemy, skill, isCritical)--攻击方，防御方，技能信息，暴击与否

    local damageRate = me.attributes.damageRate
    if (true == iscritical) then
        damageRate = damageRate * (me:getAttribute(Proto.AT_CRTHURT) / 100 )
    end

    local skillPower = skill.info.power/100
    local cure = damageRate * ((me:getAttribute(Proto.AT_SATK) + me:getAttribute(Proto.AT_ATK))/2) * skillPower 
    cure = cure*me:getAttribute(Proto.AT_HEALRATE)/1000

    if (IS_SERVER_CODE == nil and BattleLogConfig.skillCalDamageLogFlag == true) then
        printFileLog("CalCure()", "AT_SATK:" .. me:getAttribute(Proto.AT_SATK), "技能威力:" .. skillPower, "damageRate:" .. damageRate, "cure:" .. cure)
    end

    return BattleAidFunc.normalize(cure)

end

--buff伤害计算
function CalBuffDamage(me,enemy,power,skilltype)--攻击方，防御方，威力，技能类型
    --计算等级差影响
    local a = me.level - enemy.level
    local damageRate = me.damageRate
    if a > 3 then
        damageRate = damageRate * 1.2
    elseif a > (-4) then
        
    elseif a > (-11) then
        damageRate = damageRate * 0.8
    end  

    --判断技能类型物理or特功
    if skilltype == 3 then--物攻 

        damage = power * me.atk / enemy.def * (me.level * 20 +1000) / 600 * damageRate * (1.6 + me.level*0.04) * GetRandom.random(85,100) /100

    elseif skilltype == 4 then--特功

        damage = power * me.satk / enemy.sdef * (me.level * 20 +1000) / 600 * damageRate * (1.6 + me.level*0.04) * GetRandom.random(85,100) /100

    end

    damage = math.max(1,damage)

    return math.floor(damage)
end

--计算命中率
--CalHitRate(me,enemy,skill)

--计算暴击
--local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,参数)

--伤害修正比例计算
--local damageRate = CaldamageRate(PokemonInfo.getPokemonInfoByID(me.pokeID),skill.skillAtt,PokemonInfo.getPokemonInfoByID(enemy.pokeID))

--计算伤害
--local finaldamage = CalDamage(me,enemy,skill)

--buff伤害计算
--function CalBuffDamage(me,enemy,power,skilltype)3物理，4特殊

--debuff
--(self)enemyBuffer = {id = skill.id ,buffid = 1, key = true, time = 参数 , value1 = 参数 , value2 = 参数.....}

--TipsMgr.show(scene, "000000000000 ")

--selfreplace = 1（可换宠），0（不可换宠）

--self（enemy）size = 0（变小），1（正常），2（变大）

--拍击（一般的攻击）
function BattleSkill.NormalStrike(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then--判断是否命中
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)--计算是否暴击
        local finaldamage = CalDamage(me,enemy,skill,iscritical)--计算伤害
        table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end  

 --手刀（一次性提高暴击等级的攻击）
function BattleSkill.AddCriticalStrike(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,skill.parameterA)--计算是否暴击
        local finaldamage = CalDamage(me,enemy,skill,iscritical)--计算伤害
        table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end  

--连环巴掌(2~5随机多段攻击)
function BattleSkill.RandomMultiple(me,enemy,round,timing,skill)
    local damageTbl = {}
    local rate = GetRandom.random(0,99)
    local times = 0
    if rate < 34 then
        times = 2
    elseif rate < 67 then
        times = 3
    elseif rate < 84 then
        times = 4
    else
        times = 5
    end
    for i = 1 , times do
        if  GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
            local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)
            local finaldamage = CalDamage(me,enemy,skill,iscritical)
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
        else
            table.insert(damageTbl,{miss = true})
        end
    end
    BattleSkill["ret"] = damageTbl
end  

--火焰拳（击中几率灼伤）
function BattleSkill.FireStrike(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill)  then
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)

        local finaldamage = CalDamage(me,enemy,skill,iscritical)

        if GetRandom.random(0,99) < skill.parameterA then
            local buffdamage = CalBuffDamage(me,enemy,skill.parameterC,3)
            table.insert(damageTbl,{enemydamage = finaldamage , critical = iscritical , 
                enemyBuffer = {id = skill.id ,buffid = 1, key = true, time = skill.parameterB , value1 = buffdamage }})
        else
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
        end
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end 

--急冻拳（击中几率冰冻）
function BattleSkill.FreezeStrike(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)

        local finaldamage = CalDamage(me,enemy,skill,iscritical)

        if GetRandom.random(0,99) < skill.parameterA then
            table.insert(damageTbl,{enemydamage = finaldamage , critical = iscritical , 
                enemyBuffer = {id = skill.id , buffid = 2 , key = true , time = skill.parameterB , value1 = skill.parameterC }})
        else
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
        end
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end  

--雷光拳（击中几率麻痹）
function BattleSkill.ThunderStrike(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)

        local finaldamage = CalDamage(me,enemy,skill,iscritical)

        if GetRandom.random(0,99) < skill.parameterA then
            table.insert(damageTbl,{enemydamage = finaldamage , critical = iscritical , 
                enemyBuffer = {id = skill.id , buffid = 3 , key = true , time = skill.parameterB , value1 = skill.parameterC , value2 = skill.parameterD}})
        else
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
        end
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--闪电光速拳（速度提高伤害，击中几率麻痹）
function BattleSkill.ThunderGSQStrike(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)

        local finaldamage = CalDamage(me,enemy,skill,iscritical)
        if me.speed > enemy.speed then
            finaldamage = math.floor(finaldamage * math.min((me.speed/enemy.speed),2))
        end
        if GetRandom.random(0,99) < skill.parameterA then
            table.insert(damageTbl,{enemydamage = finaldamage , critical = iscritical , 
                enemyBuffer = {id = skill.id , buffid = 3 , key = true , time = skill.parameterB , value1 = skill.parameterC , value2 = skill.parameterD}})
        else
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
        end
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--剪刀断头台（一击必杀技能）
function BattleSkill.KillStrike(me,enemy,round,timing,skill)
    local damageTbl = {}
    if me.level >= enemy.level then
        if GetRandom.random(0,99) < (30 + me.level - enemy.level) then
            table.insert(damageTbl,{enemydamage = enemy.bloodLimit})
        else
            table.insert(damageTbl,{miss = true})
        end
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end  

--剑舞（提升物攻等级）
function BattleSkill.RaiseAtk(me,enemy,round,timing,skill)
    local damageTbl = {}    
    table.insert(damageTbl,{selfBuffer = {id = skill.id , buffid = 22 , key = true , time = skill.parameterA , value1 = skill.parameterB} })
    BattleSkill["ret"] = damageTbl
end  

--固定多段攻击
function BattleSkill.MultipleStrike(me,enemy,round,timing,skill)
    local damageTbl = {}
    for i = 1 , skill.parameterA do
        if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
            local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)
            local finaldamage = CalDamage(me,enemy,skill,iscritical)

            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})      
        else
            table.insert(damageTbl,{miss = true})
        end
    end
    BattleSkill["ret"] = damageTbl 
end 

--绑紧（触发束缚状态的攻击）
function BattleSkill.BoundStrike(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)  
        local finaldamage = CalDamage(me,enemy,skill,iscritical)
        local buffdamage = CalBuffDamage(me,enemy,skill.parameterC,3)
        table.insert(damageTbl,{enemydamage = finaldamage , critical = iscritical,
            enemyBuffer = {id = skill.id , selfreplace = 0 , buffid = 7 , key = true , time = GetRandom.random(skill.parameterA,skill.parameterB),value1=buffdamage}})
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end 

--催眠（概率使敌人睡眠）
function BattleSkill.Sleep(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        table.insert(damageTbl,{enemyBuffer = {id = skill.id , buffid = 6 , key = true , time = GetRandom.random(skill.parameterA,skill.parameterB)} })
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end 

--大爆炸（必定自杀的攻击）
function BattleSkill.SuicideAttack(me,enemy,round,timing,skill)
    local damageTbl = {} 
    table.insert(damageTbl,{selfdamage = me.blood})
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)
        local finaldamage = CalDamage(me,enemy,skill,iscritical)

        table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end 


--践踏
function BattleSkill.TreadOn(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    local x = CalHitRate(me,enemy,skill)

    if isbuffon(enemy,9) == true then
        x = 100
        me.damageRate = me.damageRate * 2
        if GetRandom.random(0,99) < x then
            local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)
            local finaldamage = CalDamage(me,enemy,skill,iscritical)

            if GetRandom.random(0,99) < skill.parameterA then
                table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical,
                    enemyBuffer = {id = skill.id , buffid = 8 , key = true , time = skill.parameterB , value1 = skill.parameterC}})
            else
                table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
            end
        else
            table.insert(damageTbl,{miss = true})
        end
        me.damageRate = me.damageRate / 2
    else
        if GetRandom.random(0,99) < x then
            local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)
            local finaldamage = CalDamage(me,enemy,skill,iscritical)

            if GetRandom.random(0,99) < skill.parameterA then
                table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical,
                    enemyBuffer = {id = skill.id , buffid = 8 , key = true , time = skill.parameterB , value1 = skill.parameterC}})
            else
                table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
            end
        else
            table.insert(damageTbl,{miss = true})
        end
    end

    BattleSkill["ret"] = damageTbl
end 

--铁头功（几率使敌害怕的攻击）
function BattleSkill.FearStrike(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)

        local finaldamage = CalDamage(me,enemy,skill,iscritical)

        if GetRandom.random(0,99) < skill.parameterA then
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical,
                enemyBuffer = {id = skill.id , buffid = 8 , key = true , time = skill.parameterB , value1 = skill.parameterC}})
        else
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
        end
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--飞沙（降低对方命中）
function BattleSkill.ReduceHitrate(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        if isbuffon(enemy,11) == false then
            table.insert(damageTbl,{enemyBuffer = {id = skill.id , buffid = 12 , key = true , time = skill.parameterA , value1 = skill.parameterB} })
        end
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--猛撞（伤敌后按比例伤己的攻击）
function BattleSkill.AutotomyStrike(me,enemy,round,timing,skill)
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)
        local finaldamage = CalDamage(me,enemy,skill,iscritical)

        table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical,
            selfdamage = math.floor(finaldamage * skill.parameterA/skill.parameterB)})
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end 

--摇尾巴（降低对方物理防御等级）
function BattleSkill.ReduceDef(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        if isbuffon(enemy,11) == false then
            table.insert(damageTbl,{enemyBuffer = {id = skill.id , buffid = 15 , key = true , time = skill.parameterA , value1 = skill.parameterB} })
        end
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--飞针（几率使敌中毒的攻击）
function BattleSkill.PoisonStrike(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)
        local finaldamage = CalDamage(me,enemy,skill,iscritical)

        if GetRandom.random(0,99) < skill.parameterA then
            local buffdamage = CalBuffDamage(me,enemy,skill.parameterC,4)
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical,
                enemyBuffer = {id = skill.id , buffid = 4 , key = true , time = skill.parameterB , value1 = buffdamage} })
        else
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
        end
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--固定多段几率中毒的攻击
function BattleSkill.MulPoisonStrike(me,enemy,round,timing,skill)
    local damageTbl = {}
    for i = 1 , skill.parameterA do
        if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
            local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)
            local finaldamage = CalDamage(me,enemy,skill,iscritical)

            if GetRandom.random(0,99) < skill.parameterB then
                local buffdamage = CalBuffDamage(me,enemy,skill.parameterD,4)
                table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical,
                    enemyBuffer = {id = skill.id , buffid = 4 , key = true , time = skill.parameterC , value1 = buffdamage} })
            else
                table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
            end
        else
            table.insert(damageTbl,{miss = true})
        end
    end
    BattleSkill["ret"] = damageTbl 
end 

--嚎叫（降低对方物理攻击）
function BattleSkill.ReduceAtk(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        if isbuffon(enemy,11) == false then
            table.insert(damageTbl,{enemyBuffer = {id = skill.id , buffid = 18  , time = skill.parameterA , value1 = skill.parameterB} })
        end
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--吼叫（降低对方物理攻击）
function BattleSkill.ReduceAtk2(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if isbuffon(enemy,11) == false then
        table.insert(damageTbl,{enemyBuffer = {id = skill.id , buffid = 18  , time = skill.parameterA , value1 = skill.parameterB} })
    end
    BattleSkill["ret"] = damageTbl
end

--音爆（固伤攻击）
function BattleSkill.StableDmgStrike(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        table.insert(damageTbl,{enemydamage = skill.parameterA,critical = false})
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--超声波（概率使敌人混乱）
function BattleSkill.Chaos(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        table.insert(damageTbl,{enemyBuffer = {tag= me.tag, id = skill.id , buffid = 10 , key = true , 
            time = skill.parameterA, value1 = skill.parameterC , value2 = skill.parameterD} })
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end 

--溶解液（几率降敌特防的攻击）
function BattleSkill.Solution(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)
        local finaldamage = CalDamage(me,enemy,skill,iscritical)

        if GetRandom.random(0,99) < skill.parameterA then
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical , 
                enemyBuffer = {id = skill.id , buffid = 16 , key = true , time = skill.parameterB , value1 = skill.parameterC} })
        end       
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--白雾（使自身能力不会降低）
function BattleSkill.WhiteSmog(me,enemy,round,timing,skill)
    local damageTbl = {}
    table.insert(damageTbl,{selfBuffer = {id = skill.id , buffid = 11 , key = true , time = skill.parameterA} })
    BattleSkill["ret"] = damageTbl
end 

--幻象光（概率是敌人混乱的攻击）
function BattleSkill.ChaosStrike(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)
        local finaldamage = CalDamage(me,enemy,skill,iscritical)

        if GetRandom.random(0,99) < skill.parameterA then
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical,
                enemyBuffer = {tag = me.tag, id = skill.id , buffid = 10 , key = true , time = skill.parameterB , 
                value1 = skill.parameterC, value2 = skill.parameterD} })
        else
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
        end
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--泡沫光线（几率降低速度等级的攻击）
function BattleSkill.FoamRay(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    local iseffected = false
    for i = 1 , skill.parameterA do
        if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
            local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)
            local finaldamage = CalDamage(me,enemy,skill,iscritical)

            if isbuffon(enemy,11) == false and iseffected == false then
                iseffected = true
                table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical,
                    enemyBuffer = {id = skill.id , buffid = 17 , key = true , time = skill.parameterB , value1 = skill.parameterC} })
            else
                table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
            end
        else
            table.insert(damageTbl,{miss = true})
        end
    end
    BattleSkill["ret"] = damageTbl
end

--极光束（几率降低物攻等级的攻击）
function BattleSkill.ReduceAtkStrike(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)
        local finaldamage = CalDamage(me,enemy,skill,iscritical)

        if GetRandom.random(0,99) < skill.parameterA and isbuffon(enemy,11) == false then
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical,
                enemyBuffer = {id = skill.id , buffid = 18 , key = true , time = skill.parameterB , value1 = skill.parameterC} })
        else
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
        end
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--强力光线（造成昏迷，使敌方下一次无法攻击）
function BattleSkill.ComaStrike(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)
        local finaldamage = CalDamage(me,enemy,skill,iscritical)

        if GetRandom.random(0,99) < skill.parameterA then
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical,
                enemyBuffer = {id = skill.id , buffid = 20 , key = true , time = skill.parameterB} })
        end
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--地球上投（根据自身等级造成固伤）
function BattleSkill.OnEarth(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        table.insert(damageTbl,{enemydamage = me.level,critical = false})  
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--吸收（按伤害比例恢复生命的攻击）
function BattleSkill.AbsorbStrike(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)
        local finaldamage = CalDamage(me,enemy,skill,iscritical)

        table.insert(damageTbl,{enemydamage = finaldamage , critical = iscritical , selfheal = math.floor(finaldamage*skill.parameterA/100*me.healRate)})
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--寄生种子
function BattleSkill.LeechSeed(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        table.insert(damageTbl,{enemyBuffer = {tag = me.tag,id = skill.id , buffid = 13 , key = true , time = skill.parameterA , value1 = skill.parameterB}})  
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--生长
function BattleSkill.Growth(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    table.insert(damageTbl,{selfBuffer = {id = skill.id , buffid = 21 , key = true , time = skill.parameterA , value1 = skill.parameterB}})
    BattleSkill["ret"] = damageTbl
end

--毒粉（几率中毒）
function BattleSkill.Poison(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        local buffdamage = CalBuffDamage(me,enemy,skill.parameterB,4)
        table.insert(damageTbl,{enemyBuffer = {tag = me.tag, id = skill.id , buffid = 4 , key = true , time = skill.parameterA , value1 = buffdamage}})  
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--麻痹粉（几率麻痹）
function BattleSkill.Paralysis(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        table.insert(damageTbl,{enemyBuffer = {id = skill.id , buffid = 3 , key = true , time = skill.parameterA , value1 = skill.parameterB ,
            value2 = skill.parameterC}})  
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--吐丝（几率减速度等级）
function BattleSkill.ReduceSpd(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        if isbuffon(enemy,11) == false then
            table.insert(damageTbl,{enemyBuffer = {id = skill.id , buffid = 17 , key = true , time = skill.parameterA , value1 = skill.parameterB}})  
        end
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--猛毒粉（几率中猛毒）
function BattleSkill.BadlyPoison(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        local buffdamage = CalBuffDamage(me,enemy,skill.parameterB,4)
        table.insert(damageTbl,{enemyBuffer = {id = skill.id , buffid = 5 , key = true , time = skill.parameterA , value1 = buffdamage}})  
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--幻象术（几率减特防等级的攻击）
function BattleSkill.ReduceSatkStrike(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)
        local finaldamage = CalDamage(me,enemy,skill,iscritical)

        if GetRandom.random(0,99) < skill.parameterA and isbuffon(enemy,11) == false then
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical,
                enemyBuffer = {id = skill.id , buffid = 19 , key = true , time = skill.parameterB , value1 = skill.parameterC}})
        end
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--高速移动（提高速度等级）
function BattleSkill.RaiseSpd(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    table.insert(damageTbl,{selfBuffer = {id = skill.id , buffid = 26 , key = true , time = skill.parameterA , value1 = skill.parameterB}})
    BattleSkill["ret"] = damageTbl
end


--影子分身(提高闪避)
function BattleSkill.RaiseDoge(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    table.insert(damageTbl,{selfBuffer = {id = skill.id , buffid = 27 , key = true , time = skill.parameterA , value1 = skill.parameterB}})
    BattleSkill["ret"] = damageTbl
end

--自我复原(回血)
function BattleSkill.Recover(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    table.insert(damageTbl,{selfheal = math.floor(me.bloodLimit * skill.parameterA/100 * me.healRate)})
    BattleSkill["ret"] = damageTbl
end

--硬邦邦（提高自身物理防御等级）
function BattleSkill.RaiseDef(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    table.insert(damageTbl,{selfBuffer = {id = skill.id , buffid = 23 , key = true , time = skill.parameterA , value1 = skill.parameterB}})
    BattleSkill["ret"] = damageTbl
end

--缩小
function BattleSkill.Small(me,enemy,round,timing,skill) 
    local damageTbl = {}
    me.Dodge = me.Dodge + skill.parameterB
    table.insert(damageTbl,{selfBuffer = {id = skill.id ,selfsize = 0 , buffid = 9 , key = true , time = skill.parameterA , value1 = skill.parameterB}})
    BattleSkill["ret"] = damageTbl
end

--光墙
function BattleSkill.LightScreen(me,enemy,round,timing,skill) 
    local damageTbl = {}
    table.insert(damageTbl,{selfBuffer = {id = skill.id , buffid = 14 , key = true , time = skill.parameterA , value1 = skill.parameterB}})
    BattleSkill["ret"] = damageTbl
end

--黑雾
function BattleSkill.BlackSmog(me,enemy,round,timing,skill) 
    local damageTbl = {}
    
    BattleSkill["ret"] = damageTbl
end

--格挡
function BattleSkill.Parry(me,enemy,round,timing,skill) 
    local damageTbl = {}
    table.insert(damageTbl,{selfBuffer = {id = skill.id , buffid = 30 , key = true , time = skill.parameterA , value1 = skill.parameterB}})
    BattleSkill["ret"] = damageTbl
end

--集气（提高自身暴击等级）
function BattleSkill.RaiseCritical(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    table.insert(damageTbl,{selfBuffer = {id = skill.id , buffid = 31 , key = true , time = skill.parameterA , value1 = skill.parameterB}})
    BattleSkill["ret"] = damageTbl
end

--纠缠（概率降低速度的攻击）
function BattleSkill.ReduceSpdStrike(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)
        local finaldamage = CalDamage(me,enemy,skill,iscritical)

        if GetRandom.random(0,99) < skill.parameterA and isbuffon(enemy,11) == false then
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical,
                enemyBuffer = {id = skill.id , buffid = 17 , key = true , time = skill.parameterB , value1 = skill.parameterC}})
        else
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
        end
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--瞬间失忆（提高自身特殊防御等级）
function BattleSkill.RaiseSdef(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    table.insert(damageTbl,{selfBuffer = {id = skill.id , buffid = 16 , key = true , time = skill.parameterA , value1 = skill.parameterB}})
    BattleSkill["ret"] = damageTbl
end

--食梦
function BattleSkill.DreamEater(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)
        local finaldamage = CalDamage(me,enemy,skill,iscritical)
        if isbuffon(enemy,6) == true then
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical,selfheal = math.floor(finaldamage*skill.parameterA/100 * me.healRate)})
        else
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
        end
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--三角攻击
function BattleSkill.TriAttack(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)
        local finaldamage = CalDamage(me,enemy,skill,iscritical)

        if GetRandom.random(0,99) < skill.parameterA then
            local x = GetRandom.random(0,99)
            if x < 33 then
                table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical,
                    enemyBuffer = {id = skill.id , buffid = 3 , key = true , time = skill.parameterB , value1 = skill.parameterC,
                    value2 = 25} })
            elseif x < 66 then
                table.insert(damageTbl,{enemydamage = finaldamage , critical = iscritical , 
                    enemyBuffer = {id = skill.id , buffid = 1 , key = true , time = skill.parameterB , value1 = skill.parameterD} })
            else
                table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical,
                    enemyBuffer = {id = skill.id , buffid = 2 , key = true , time = skill.parameterB , value1 = skill.parameterE} })
            end
        else
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
        end
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end 

--愤怒之牙
function BattleSkill.SuperFang(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        if enemy.blood == 1 then
            table.insert(damageTbl,{enemydamage = 1,critical = false})
        else
            table.insert(damageTbl,{enemydamage = math.floor(enemy.blood * skill.parameterA/100 * (1 - enemy.Tenacity/100)),critical = false})
        end  
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--火焰踢
function BattleSkill.BlazeKick(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        local iscritical = CalIsCritical(me.Critical , enemy.CritResistance , skill.parameterA)
        local finaldamage = CalDamage(me,enemy,skill,iscritical)

        if GetRandom.random(0,99) < skill.parameterB then     
            local buffdamage = CalBuffDamage(me,enemy,skill.parameterD,3)
            table.insert(damageTbl,{enemydamage = finaldamage , critical = iscritical , 
                enemyBuffer = {id = skill.id , buffid = 1 , key = true, time = skill.parameterC , value1 = buffdamage} })
        else
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
        end
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--精神提升
function BattleSkill.PsychoBoost(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        local iscritical = CalIsCritical(me.Critical , enemy.CritResistance , 0)
        local finaldamage = CalDamage(me,enemy,skill,iscritical)

        table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical ,
            enemyBuffer = {id = skill.id , buffid = 24 , key = true, time = skill.parameterA , value1 = skill.parameterB} })
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end 

--大地之力
function BattleSkill.EarthPower(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        local iscritical = CalIsCritical(me.Critical , enemy.CritResistance , 0)
        local finaldamage = CalDamage(me,enemy,skill,iscritical)

        if GetRandom.random(0,99) < skill.parameterA and isbuffon(enemy,11) == false then
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical,
                enemyBuffer = {id = skill.id , buffid = 16 , key = true, time = skill.parameterB , value1 = skill.parameterC}})
        else
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
        end
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--飞叶快刀
function BattleSkill.LeafStrike(me,enemy,round,timing,skill)
	local damageTbl = {} 
	for i = 1 , skill.parameterA do
		if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
			local iscritical = CalIsCritical(me.Critical , enemy.CritResistance , 0)
            local finaldamage = CalDamage(me,enemy,skill,iscritical)
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
		else
			table.insert(damageTbl,{miss = true})
		end
	end
    BattleSkill["ret"] = damageTbl
end

--梆梆炸弹
function BattleSkill.MeHPStrike(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then--判断是否命中
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)--计算是否暴击
        local finaldamage = CalDamage(me,enemy,skill,iscritical)--计算伤害
        finaldamage = math.floor(finaldamage + me.bloodLimit * skill.parameterA/100)
        table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end  

--声波冲击
function BattleSkill.VoiceAttackStrike(me,enemy,round,timing,skill)
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        local iscritical = CalIsCritical(me.Critical , enemy.CritResistance , 0)
        local finaldamage = CalDamage(me,enemy,skill,iscritical)

        if GetRandom.random(0,99) < skill.parameterA then
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical,
                enemyBuffer = {id = skill.id , buffid = 18 , key = true, time = skill.parameterB , value1 = skill.parameterC}})
        else
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
        end     
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--意念头槌
function BattleSkill.HeadAttackStrike(me,enemy,round,timing,skill)
    local damageTbl = {} 
        if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
            local iscritical = CalIsCritical(me.Critical , enemy.CritResistance , 0)
            local finaldamage = CalDamage(me,enemy,skill,iscritical)
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical,
                enemyBuffer = {id = skill.id , buffid = 16 , key = true, time = skill.parameterA , value1 = skill.parameterB }})
        else
            table.insert(damageTbl,{miss = true})
        end
    BattleSkill["ret"] = damageTbl
end

--火龙三连击 
function BattleSkill.FireDragonHit(me,enemy,round,timing,skill)
    local damageTbl = {}
    local Attack = 0

    for i = 1 , skill.parameterA do
        Attack = Attack + 1
        if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
            local iscritical = CalIsCritical(me.Critical , enemy.CritResistance , 0)
            if Attack == skill.parameterA then
                iscritical = true
            end
            local finaldamage = CalDamage(me,enemy,skill,iscritical)
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})     
        else
            table.insert(damageTbl,{miss = true})
        end
    end
    BattleSkill["ret"] = damageTbl
end 

-- 毒牙
function BattleSkill.TeeAttackStrike(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then 
        local iscritical = CalIsCritical(me.Critical , enemy.CritResistance , 0)
        local finaldamage = CalDamage(me,enemy,skill,iscritical)
        if GetRandom.random(0,99) < skill.parameterA then
            local buffdamage = CalBuffDamage(me,enemy,skill.parameterC,4)
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical,
                enemyBuffer = {id = skill.id , buffid = 33 , key = true , time = skill.parameterB,value1 = buffdamage ,value2 =skill.parameterD} })
        else
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
        end
    else
        table.insert(damageTbl,{miss = true})
    end 
    BattleSkill["ret"] = damageTbl
end

--绝对防御
function BattleSkill.TotalDefence(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < skill.parameterA then
        table.insert(damageTbl,{selfBuffer = {id = skill.id , buffid = 34 , key = true , time = skill.parameterB,value1 = skill.parameterC}})
    else
        table.insert(damageTbl,{selfBuffer = {id = skill.id , buffid = 34 , key = true , time = skill.parameterB,value1 = skill.parameterC},
                enemyBuffer = {id = skill.id , buffid = 36 , key = true , time = skill.parameterB,value1 = skill.parameterD}})
    end
    BattleSkill["ret"] = damageTbl
end

--禁锢
function BattleSkill.JinGuStrike(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then 
        local iscritical = CalIsCritical(me.Critical , enemy.CritResistance , 0)
        local finaldamage = CalDamage(me,enemy,skill,iscritical)

        if GetRandom.random(0,99) < skill.parameterA then
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical,
                enemyBuffer = {id = skill.id , buffid = 17 , key = true , time = skill.parameterB , value1= skill.parameterC} })
        else
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
        end
    else
        table.insert(damageTbl,{miss = true})
    end
end

--十万伏特（击中几率麻痹）
function BattleSkill.Thunderbolt(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        local iscritical = CalIsCritical(me.Critical , enemy.CritResistance , 0)
        local finaldamage = CalDamage(me,enemy,skill,iscritical)

        if GetRandom.random(0,99) < skill.parameterA then
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical,
                enemyBuffer = {id = skill.id , buffid = 35 , key = true , time = skill.parameterB,value1 = skill.parameterC,value2 =skill.parameterD,
                value3 = skill.parameterE}})
        else
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
        end
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--飞天煞
function BattleSkill.ChashStrikeSpecial(me,enemy,round,timing,skill)
	local damageTbl = {} 
		if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
			local iscritical = CalIsCritical(me.Critical , enemy.CritResistance , skill.parameterA)
            local finaldamage = CalDamage(me,enemy,skill,iscritical)
			if iscritical == true and GetRandom.random(0,99) < skill.parameterB then
				table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical,selfheal = math.floor(me.bloodLimit*skill.parameterC/100) })
			else
				table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
			end
            
		else
			table.insert(damageTbl,{miss = true})
		end 
    BattleSkill["ret"] = damageTbl
end

--奥术三连击
function BattleSkill.IQStrike(me,enemy,round,timing,skill)
    local damageTbl = {}
    setSkillUtilValue(me.tag,skill.id,{iseffected = false , sdef = enemy.sdef * skill.parameterB/100})
    for i = 1 , 3 do
        if  GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
            local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)
            if  GetRandom.random(0,99)< skill.parameterA then
                enemy.sdef = enemy.sdef - sdef
                getSkillUtilValue(me.tag,skill.id).iseffected = true
            end
            local finaldamage = CalDamage(me,enemy,skill,iscritical)
            if  getSkillUtilValue(me.tag,skill.id).iseffected == true then
                enemy.sdef = enemy.sdef + sdef
                getSkillUtilValue(me.tag,skill.id).iseffected = false
            end
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
        else
            table.insert(damageTbl,{miss = true})
        end
    end
    BattleSkill["ret"] = damageTbl
end

--激发潜能--血换速度与闪避
function BattleSkill.AddDodgeHp(me,enemy,round,timing,skill)
    local damageTbl = {}
    table.insert(damageTbl,{selfdamage = math.floor(me.bloodLimit*skill.parameterA/100),
        selfBuffer = {id = skill.id , buffid = 37 , key = true , time = skill.parameterB , value1=me.speed*skill.parameterC/100 , value2=skill.parameterD}})
    BattleSkill["ret"] = damageTbl
end

--竭力打击
function BattleSkill.JieliStrike(me,enemy,round,timing,skill)
    local damageTbl = {}
    if  GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,80)
        me.atk = me.atk * (1 + skill.parameterA/100)
        local finaldamage = CalDamage(me,enemy,skill,iscritical)
        me.atk = me.atk / (1 + skill.parameterA/100)
        table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical,
            selfBuffer = {id = skill.id , buffid = 18 , key = true , time = skill.parameterB , value1 = skill.parameterC}})
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--破甲一击
function BattleSkill.PojiaStrike(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then--判断是否命中
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,skill.parameterA)--计算是否暴击
        enemy.def = enemy.def/2
        local finaldamage = CalDamage(me,enemy,skill,iscritical)--计算伤害
        enemy.def = enemy.def*2
        table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--怒气护体
function BattleSkill.DefenceCriStrike(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then--判断是否命中
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)--计算是否暴击
        local finaldamage = CalDamage(me,enemy,skill,iscritical)--计算伤害
        table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical,
            selfBuffer = {id = skill.id , buffid = 38 , key = true , time = skill.parameterA , value1 = skill.parameterB}})
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--光速拳
function BattleSkill.GSQStrike(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then--判断是否命中
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)--计算是否暴击
        local finaldamage = CalDamage(me,enemy,skill,iscritical)--计算伤害
        if me.speed > enemy.speed then
            finaldamage = math.floor(finaldamage * math.min((me.speed/enemy.speed),2))
        end
        table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--春意盎然（提高特攻攻击）
function BattleSkill.RaiseSatkStrikeF(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then--判断是否命中
        me.satk = me.satk * (1 + skill.parameterA/100)
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)--计算是否暴击
        local finaldamage = CalDamage(me,enemy,skill,iscritical)--计算伤害
        table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
    else
        me.satk = me.satk * (1 + skill.parameterA/100)
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end 

--花之舞（多段攻击，概率混乱）
function BattleSkill.FlowerDance(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    local x = false
    for i = 1 , skill.parameterA do
        if  GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then
            local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)
            local finaldamage = CalDamage(me,enemy,skill,iscritical)
            if x == false and GetRandom.random(0,99) < skill.parameterB then
                x = true
                table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical , 
                    enemyBuffer = {tag = me.tag, id = skill.id , buffid = 10 ,key = true ,time = skill.parameterC , value1 = skill.parameterD
                    , value2 = skill.parameterE}})
            else
                table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
            end
        else
            table.insert(damageTbl,{miss = true})
        end
    end
    BattleSkill["ret"] = damageTbl
end 

--高速星星（必中攻击）
function BattleSkill.FastStars(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)
    local finaldamage = CalDamage(me,enemy,skill,iscritical)
    table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
    BattleSkill["ret"] = damageTbl
end 

--月读（攻击概率获得提高魔攻buff）
function BattleSkill.RaiseSatkStrike(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then--判断是否命中
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)--计算是否暴击
        local finaldamage = CalDamage(me,enemy,skill,iscritical)--计算伤害
        if GetRandom.random(0,99) < skill.parameterA then
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical , 
                    enemyBuffer = {id = skill.id , buffid = 24 ,key = true ,time = skill.parameterB, value1 = skill.parameterC}})
        else 
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
        end
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--真月读（攻击有几率提高魔攻与暴击率）
function BattleSkill.zhenyuedu(me,enemy,round,timing,skill) 
    local damageTbl = {} 
    if GetRandom.random(0,99) < CalHitRate(me,enemy,skill) then--判断是否命中
        local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,0)--计算是否暴击
        local finaldamage = CalDamage(me,enemy,skill,iscritical)--计算伤害
        if GetRandom.random(0,99) < skill.parameterA then
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical , 
                    enemyBuffer = {id = skill.id , buffid = 40 ,key = true ,time = skill.parameterB, value1 = skill.parameterC
                    , value2 = skill.parameterD}})
        else 
            table.insert(damageTbl,{enemydamage = finaldamage,critical = iscritical})
        end
    else
        table.insert(damageTbl,{miss = true})
    end
    BattleSkill["ret"] = damageTbl
end

--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~我是被动技能的分割线~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]]
--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~我是被动技能的分割线~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]]
--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~我是被动技能的分割线~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]]
--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~我是被动技能的分割线~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]]
--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~我是被动技能的分割线~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]]
--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~我是被动技能的分割线~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]]
--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~我是被动技能的分割线~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]]
--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~我是被动技能的分割线~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]]
--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~我是被动技能的分割线~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]]
--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~我是被动技能的分割线~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]]
--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~我是被动技能的分割线~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]]
--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~我是被动技能的分割线~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]]
--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~我是被动技能的分割线~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]]
--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~我是被动技能的分割线~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]]
--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~我是被动技能的分割线~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~]]

--回血被动
function BattleSkill.HealPerRound(me,enemy,round,timing,skill)
    local damageTbl = {}
    table.insert(damageTbl,{true , selfheal = math.floor(me.bloodLimit * skill.parameterA /100 * me.healRate) })
    BattleSkill["ret"] = damageTbl
end

--战神领域（登场时概率增加命中）
function BattleSkill.PasRaiseHitrateF(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        me.HitRate = me.HitRate + skill.parameterB
        table.insert(damageTbl,{true})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--天怒（登场时概率增加魔攻）
function BattleSkill.PasRaiseSatkF(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        me.satk = me.satk * (1 + skill.parameterB / 100)
        table.insert(damageTbl,{true})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--刀枪不入（防御概率临时加物防）
function BattleSkill.PasRaiseDefT(me,enemy,round,timing,skill)
    local damageTbl = {}
    
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if timing == ROUND_BefDEF and GetRandom.random(0,99) < skill.parameterA then
        getSkillUtilValue(me.tag,skill.id).iseffected = true
        me.def = me.def * (1 + skill.parameterB/100)
        
        table.insert(damageTbl,{true})
    elseif timing == ROUND_AfterDEF and getSkillUtilValue(me.tag,skill.id).iseffected == true then
        getSkillUtilValue(me.tag,skill.id).iseffected = false
        me.def = me.def / (1 + skill.parameterB/100)
        table.insert(damageTbl,{false})
        
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--不屈（防御概率临时加魔防）
function BattleSkill.PasRaiseSdefT(me,enemy,round,timing,skill)
    local damageTbl = {}
 
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if timing == ROUND_BefDEF and GetRandom.random(0,99) < skill.parameterA then
        getSkillUtilValue(me.tag,skill.id).iseffected = true
        me.sdef = me.sdef * (1 + skill.parameterB/100)
        
        table.insert(damageTbl,{true})
    elseif timing == ROUND_AfterDEF and getSkillUtilValue(me.tag,skill.id).iseffected == true then
        getSkillUtilValue(me.tag,skill.id).iseffected = false
        me.sdef = me.sdef / (1 + skill.parameterB/100)
       
        table.insert(damageTbl,{false})
    else

        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--血性狂暴（登场概率增加物攻）
function BattleSkill.PasRaiseAtkF(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        me.atk = me.atk * (1 + skill.parameterB / 100)
        table.insert(damageTbl,{true})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--石化皮肤(登场时增加物防)
function BattleSkill.PasRaiseDefF(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        me.def = me.def * (1 + skill.parameterB / 100)
        table.insert(damageTbl,{true})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--一鼓作气（根据HP临时加速）
function BattleSkill.PasRaiseSpdHP(me,enemy,round,timing,skill)
    local damageTbl = {}    
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if me.blood >= (me.bloodLimit*skill.parameterA/100) then
        if getSkillUtilValue(me.tag,skill.id).iseffected == false then
            getSkillUtilValue(me.tag,skill.id).iseffected = true
            me.speed = me.speed * (1 + skill.parameterB / 100)
            table.insert(damageTbl,{true})
        else
            table.insert(damageTbl,{true})
        end
    else
        if getSkillUtilValue(me.tag,skill.id).iseffected == true then
            me.speed = me.speed / (1 + skill.parameterB / 100)
            getSkillUtilValue(me.tag,skill.id).iseffected = false
            table.insert(damageTbl,{false})
        else
            table.insert(damageTbl,{false})
        end
    end
    BattleSkill["ret"] = damageTbl
end

--下马威（登场移除对方生命值）
function BattleSkill.PasXiamawei(me,enemy,round,timing,skill)
    local damageTbl = {}
    table.insert(damageTbl,{true, enemydamage = math.floor(enemy.bloodLimit*skill.parameterA/100)})
    BattleSkill["ret"] = damageTbl
end

--重生（死亡时概率复活）
function BattleSkill.PasZhashi(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        me.blood = math.floor(me.bloodLimit * skill.parameterB / 100)
        table.insert(damageTbl,{true})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--树皮护甲(根据HP加物防)
function BattleSkill.PasRaiseDefHP(me,enemy,round,timing,skill)
    local damageTbl = {}
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if me.blood >= (me.bloodLimit*skill.parameterA/100) then
        if getSkillUtilValue(me.tag,skill.id).iseffected == false then
            getSkillUtilValue(me.tag,skill.id).iseffected = true
            me.def = me.def * (1 + skill.parameterB / 100)
            table.insert(damageTbl,{true})
        else
            table.insert(damageTbl,{false})
        end
    else
        if getSkillUtilValue(me.tag,skill.id).iseffected == true then
            me.def = me.def / (1 + skill.parameterB / 100)
            getSkillUtilValue(me.tag,skill.id).iseffected = false
            table.insert(damageTbl,{false})
        else
            table.insert(damageTbl,{false})
        end
    end
    BattleSkill["ret"] = damageTbl
end

--粘液陷阱（概率减少对方速度）
function BattleSkill.PasRandomSlow(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        table.insert(damageTbl,{true,enemyBuffer = {id = skill.id ,buffid = 17, key = true, time = skill.parameterB , value1 = skill.parameterC}})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--光合作用（概率回血）
function BattleSkill.PasHealSelf(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        local x = math.floor(me.bloodLimit*skill.parameterB/100*me.healRate)
        table.insert(damageTbl,{true, selfheal = math.floor(me.bloodLimit*skill.parameterB/100*me.healRate)})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--自然守卫(登场概率加双防)
function BattleSkill.PasRaiseDDF(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        me.def = me.def * (1 + skill.parameterB / 100)
        me.sdef = me.sdef * (1 + skill.parameterB / 100)
        table.insert(damageTbl,{true})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--增加物防
function BattleSkill.HaloADDdef(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        me.def = me.def * (1 + skill.parameterB / 100)
        table.insert(damageTbl,{true})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--增加魔防
function BattleSkill.HaloADDsdef(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        me.sdef = me.sdef * (1 + skill.parameterB / 100)
        table.insert(damageTbl,{true})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--增加物攻
function BattleSkill.HaloADDatk(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        me.atk = me.atk * (1 + skill.parameterB / 100)
        table.insert(damageTbl,{true})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--增加魔攻
function BattleSkill.HaloADDsatk(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        me.satk = me.satk * (1 + skill.parameterB / 100)
        table.insert(damageTbl,{true})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--增加速度
function BattleSkill.HaloADDspeed(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        me.speed = me.speed * (1 + skill.parameterB / 100)
        table.insert(damageTbl,{true})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--增加命中率
function BattleSkill.HaloADDHitRate(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        me.HitRate = me.HitRate + skill.parameterB
        table.insert(damageTbl,{true})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--增加回避
function BattleSkill.HaloADDDodge(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        me.Dodge = me.Dodge + skill.parameterB
        table.insert(damageTbl,{true})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--增加暴击
function BattleSkill.HaloADDCSdamageRate(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        me.CSdamageRate = me.CSdamageRate + skill.parameterB
        table.insert(damageTbl,{true})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--增加登场血量
function BattleSkill.HaloADDHp(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        me.bloodLimit = me.bloodLimit * (1 + skill.parameterB / 100)
        me.blood = me.blood * (1 + skill.parameterB / 100)
        table.insert(damageTbl,{true})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--增加最大血量
function BattleSkill.HaloADDbloodLimit(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        me.blood = me.blood + me.bloodLimit * skill.parameterB / 100
        table.insert(damageTbl,{true})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--增加当前血量
function BattleSkill.HaloADDblood(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        me.blood = me.blood + math.floor(me.blood * skill.parameterB / 100)
        table.insert(damageTbl,{true})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--减少最大血量
function BattleSkill.HaloCUTbloodLimit(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        enemy.blood = enemy.blood - math.floor(enemy.bloodLimit * skill.parameterB / 100)
        table.insert(damageTbl,{true})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--减少当前血量
function BattleSkill.HaloCUTblood(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        enemy.blood = enemy.blood - enemy.blood * skill.parameterB / 100
        table.insert(damageTbl,{true})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--减少速度
function BattleSkill.HaloCUTspeed(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        enemy.speed = enemy.speed - enemy.speed * skill.parameterB / 100
        table.insert(damageTbl,{true})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

-----------------条件触发技能---------------------------------

--自己生命低于A增加物防
function BattleSkill.ConditionADDdef(me,enemy,round,timing,skill)
    local damageTbl = {}    
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if me.blood <= (me.bloodLimit*skill.parameterA/100) then
        if getSkillUtilValue(me.tag,skill.id).iseffected == false then
            getSkillUtilValue(me.tag,skill.id).iseffected = true
            me.def = me.def * (1 + skill.parameterB / 100)
            table.insert(damageTbl,{true})
        else
            table.insert(damageTbl,{false})
        end
    else
        if getSkillUtilValue(me.tag,skill.id).iseffected == true then
            me.def = me.def / (1 + skill.parameterB / 100)
            getSkillUtilValue(me.tag,skill.id).iseffected = false
            table.insert(damageTbl,{false})
        else
            table.insert(damageTbl,{false})
        end
    end
    BattleSkill["ret"] = damageTbl
end

--自己生命低于A增加魔防
function BattleSkill.ConditionADDsdef(me,enemy,round,timing,skill)
    local damageTbl = {}    
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if me.blood <= (me.bloodLimit*skill.parameterA/100) then
        if getSkillUtilValue(me.tag,skill.id).iseffected == false then
            getSkillUtilValue(me.tag,skill.id).iseffected = true
            me.sdef = me.sdef * (1 + skill.parameterB / 100)
            table.insert(damageTbl,{true})
        else
            table.insert(damageTbl,{false})
        end
    else
        if getSkillUtilValue(me.tag,skill.id).iseffected == true then
            me.sdef = me.sdef / (1 + skill.parameterB / 100)
            getSkillUtilValue(me.tag,skill.id).iseffected = false
            table.insert(damageTbl,{false})
        else
            table.insert(damageTbl,{false})
        end
    end
    BattleSkill["ret"] = damageTbl
end

--自己生命不低于A增加魔防
function BattleSkill.ConditionADDsdefL(me,enemy,round,timing,skill)
    local damageTbl = {}    
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if me.blood >= (me.bloodLimit*skill.parameterA/100) then
        if getSkillUtilValue(me.tag,skill.id).iseffected == false then
            getSkillUtilValue(me.tag,skill.id).iseffected = true
            me.sdef = me.sdef * (1 + skill.parameterB / 100)
            table.insert(damageTbl,{true})
        else
            table.insert(damageTbl,{false})
        end
    else
        if getSkillUtilValue(me.tag,skill.id).iseffected == true then
            me.sdef = me.sdef / (1 + skill.parameterB / 100)
            getSkillUtilValue(me.tag,skill.id).iseffected = false
            table.insert(damageTbl,{false})
        else
            table.insert(damageTbl,{false})
        end
    end
    BattleSkill["ret"] = damageTbl
end

--自己生命低于A增加速度
function BattleSkill.ConditionADDspeed(me,enemy,round,timing,skill)
    local damageTbl = {}    
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if me.blood <= (me.bloodLimit*skill.parameterA/100) then
        if getSkillUtilValue(me.tag,skill.id).iseffected == false then
            getSkillUtilValue(me.tag,skill.id).iseffected = true
            me.speed = me.speed * (1 + skill.parameterB / 100)
            table.insert(damageTbl,{true})
        else
            table.insert(damageTbl,{false})
        end
    else
        if getSkillUtilValue(me.tag,skill.id).iseffected == true then
            me.speed = me.speed / (1 + skill.parameterB / 100)
            getSkillUtilValue(me.tag,skill.id).iseffected = false
            table.insert(damageTbl,{false})
        else
            table.insert(damageTbl,{false})
        end
    end
    BattleSkill["ret"] = damageTbl
end

--自己生命低于A增加物攻
function BattleSkill.ConditionADDatk(me,enemy,round,timing,skill)
    local damageTbl = {}    
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if me.blood <= (me.bloodLimit*skill.parameterA/100) then
        if getSkillUtilValue(me.tag,skill.id).iseffected == false then
            getSkillUtilValue(me.tag,skill.id).iseffected = true
            me.atk = me.atk * (1 + skill.parameterB / 100)
            table.insert(damageTbl,{true})
        else
            table.insert(damageTbl,{false})
        end
    else
        if getSkillUtilValue(me.tag,skill.id).iseffected == true then
            me.atk = me.atk / (1 + skill.parameterB / 100)
            getSkillUtilValue(me.tag,skill.id).iseffected = false
            table.insert(damageTbl,{false})
        else
            table.insert(damageTbl,{false})
        end
    end
    BattleSkill["ret"] = damageTbl
end

--自己生命低于A增加魔攻
function BattleSkill.ConditionADDsatk(me,enemy,round,timing,skill)
    local damageTbl = {}    
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if me.blood <= (me.bloodLimit*skill.parameterA/100) then
        if getSkillUtilValue(me.tag,skill.id).iseffected == false then
            getSkillUtilValue(me.tag,skill.id).iseffected = true
            me.satk = me.satk * (1 + skill.parameterB / 100)
            table.insert(damageTbl,{true})
        else
            table.insert(damageTbl,{false})
        end
    else
        if getSkillUtilValue(me.tag,skill.id).iseffected == true then
            me.satk = me.satk / (1 + skill.parameterB / 100)
            getSkillUtilValue(me.tag,skill.id).iseffected = false
            table.insert(damageTbl,{false})
        else
            table.insert(damageTbl,{false})
        end
    end
    BattleSkill["ret"] = damageTbl
end

--自己生命不低于A增加魔攻
function BattleSkill.ConditionADDsatkL(me,enemy,round,timing,skill)
    local damageTbl = {}    
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if me.blood >= (me.bloodLimit*skill.parameterA/100) then
        if getSkillUtilValue(me.tag,skill.id).iseffected == false then
            getSkillUtilValue(me.tag,skill.id).iseffected = true
            me.satk = me.satk * (1 + skill.parameterB / 100)
            table.insert(damageTbl,{true})
        else
            table.insert(damageTbl,{false})
        end
    else
        if getSkillUtilValue(me.tag,skill.id).iseffected == true then
            me.satk = me.satk / (1 + skill.parameterB / 100)
            getSkillUtilValue(me.tag,skill.id).iseffected = false
            table.insert(damageTbl,{false})
        else
            table.insert(damageTbl,{false})
        end
    end
    BattleSkill["ret"] = damageTbl
end

--敌人生命低于A减少速度
function BattleSkill.ConditionCUTspeed(me,enemy,round,timing,skill)
    local damageTbl = {}    
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if enemy.blood <= (enemy.bloodLimit*skill.parameterA/100) then
        if getSkillUtilValue(me.tag,skill.id).iseffected == false then
            getSkillUtilValue(me.tag,skill.id).iseffected = true
            enemy.speed = enemy.speed * (1 - skill.parameterB / 100)
            table.insert(damageTbl,{true})
        else
            table.insert(damageTbl,{false})
        end
    else
        if getSkillUtilValue(me.tag,skill.id).iseffected == true then
            enemy.speed = enemy.speed / (1 - skill.parameterB / 100)
            getSkillUtilValue(me.tag,skill.id).iseffected = false
            table.insert(damageTbl,{false})
        else
            table.insert(damageTbl,{false})
        end
    end
    BattleSkill["ret"] = damageTbl
end

--敌人生命低于A增加速度
function BattleSkill.ConditionADDspeed(me,enemy,round,timing,skill)
    local damageTbl = {}    
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if enemy.blood <= (enemy.bloodLimit*skill.parameterA/100) then
        if getSkillUtilValue(me.tag,skill.id).iseffected == false then
            getSkillUtilValue(me.tag,skill.id).iseffected = true
            me.speed = me.speed * (1 + skill.parameterB / 100)
            table.insert(damageTbl,{true})
        else
            table.insert(damageTbl,{false})
        end
    else
        if getSkillUtilValue(me.tag,skill.id).iseffected == true then
            me.speed = me.speed / (1 + skill.parameterB / 100)
            getSkillUtilValue(me.tag,skill.id).iseffected = false
            table.insert(damageTbl,{false})
        else
            table.insert(damageTbl,{false})
        end
    end
    BattleSkill["ret"] = damageTbl
end

--敌人生命低于A减少物防
function BattleSkill.ConditionCUTdef(me,enemy,round,timing,skill)
    local damageTbl = {}    
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if enemy.blood <= (enemy.bloodLimit*skill.parameterA/100) then
        if getSkillUtilValue(me.tag,skill.id).iseffected == false then
            getSkillUtilValue(me.tag,skill.id).iseffected = true
            enemy.def = enemy.def * (1 - skill.parameterB / 100)
            table.insert(damageTbl,{true})
        else
            table.insert(damageTbl,{false})
        end
    else
        if getSkillUtilValue(me.tag,skill.id).iseffected == true then
            enemy.def = enemy.def / (1 - skill.parameterB / 100)
            getSkillUtilValue(me.tag,skill.id).iseffected = false
            table.insert(damageTbl,{false})
        else
            table.insert(damageTbl,{false})
        end
    end
    BattleSkill["ret"] = damageTbl
end

-----------------概率触发技能---------------------------------

--攻击时增加物攻
function BattleSkill.ProbGADDatk(me,enemy,round,timing,skill)
    local damageTbl = {}
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if timing == ROUND_BefATK and GetRandom.random(0,99) < skill.parameterA then
        getSkillUtilValue(me.tag,skill.id).iseffected = true
        me.atk = me.atk * (1 + skill.parameterB/100)
        table.insert(damageTbl,{true})
    elseif timing == ROUND_AfterATK and getSkillUtilValue(me.tag,skill.id).iseffected == true then
        getSkillUtilValue(me.tag,skill.id).iseffected = false
        me.atk = me.atk / (1 + skill.parameterB/100)
        table.insert(damageTbl,{false})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--攻击时增加魔攻
function BattleSkill.ProbGADDsatk(me,enemy,round,timing,skill)
    local damageTbl = {}
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if timing == ROUND_BefATK and GetRandom.random(0,99) < skill.parameterA then
        getSkillUtilValue(me.tag,skill.id).iseffected = true
        me.satk = me.satk * (1 + skill.parameterB/100)
        table.insert(damageTbl,{true})
    elseif timing == ROUND_AfterATK and getSkillUtilValue(me.tag,skill.id).iseffected == true then
        getSkillUtilValue(me.tag,skill.id).iseffected = false
        me.satk = me.satk / (1 + skill.parameterB/100)
        table.insert(damageTbl,{false})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--攻击时增加暴击
function BattleSkill.ProbGADDCSdamageRate(me,enemy,round,timing,skill)
    local damageTbl = {}
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if timing == ROUND_BefATK and GetRandom.random(0,99) < skill.parameterA then
        getSkillUtilValue(me.tag,skill.id).iseffected = true
        me.CSdamageRate = me.CSdamageRate + skill.parameterB
        table.insert(damageTbl,{true})
    elseif timing == ROUND_AfterATK and getSkillUtilValue(me.tag,skill.id).iseffected == true then
        getSkillUtilValue(me.tag,skill.id).iseffected = false
        me.CSdamageRate = me.CSdamageRate - skill.parameterB
        table.insert(damageTbl,{false})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--攻击时增加双攻
function BattleSkill.ProbGADDdoubleatk(me,enemy,round,timing,skill)
    local damageTbl = {}
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if timing == ROUND_BefATK and GetRandom.random(0,99) < skill.parameterA then
        getSkillUtilValue(me.tag,skill.id).iseffected = true
        me.atk = me.atk * (1 + skill.parameterB/100)
        me.satk = me.satk * (1 + skill.parameterC/100)
        table.insert(damageTbl,{true})
    elseif timing == ROUND_AfterATK and getSkillUtilValue(me.tag,skill.id).iseffected == true then
        getSkillUtilValue(me.tag,skill.id).iseffected = false
        me.atk = me.atk / (1 + skill.parameterB/100)
        me.satk = me.satk / (1 + skill.parameterC/100)
        table.insert(damageTbl,{false})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--攻击时降低双防
function BattleSkill.ProbGCUTdoubledef(me,enemy,round,timing,skill)
    local damageTbl = {}
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if timing == ROUND_BefATK and GetRandom.random(0,99) < skill.parameterA then
        getSkillUtilValue(me.tag,skill.id).iseffected = true
        enemy.def = enemy.def * (1 - skill.parameterB/100)
        enemy.sdef = enemy.sdef * (1 - skill.parameterC/100)
        table.insert(damageTbl,{true})
    elseif timing == ROUND_AfterATK and getSkillUtilValue(me.tag,skill.id).iseffected == true then
        getSkillUtilValue(me.tag,skill.id).iseffected = false
        enemy.def = enemy.def / (1 - skill.parameterB/100)
        enemy.sdef = enemy.sdef / (1 - skill.parameterC/100)
        table.insert(damageTbl,{false})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--对方获得麻痹DEBUFF
function BattleSkill.ProbGetMdebuff(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        table.insert(damageTbl,{true,enemyBuffer = {id = skill.id ,buffid = 3, key = true, time = skill.parameterB , value1 = skill.parameterC , value2 = skill.parameterD}})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--对方获得冰冻DEBUFF
function BattleSkill.ProbGetBDdebuff(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        table.insert(damageTbl,{true,enemyBuffer = {id = skill.id ,buffid = 2, key = true, time = skill.parameterB , value1 = skill.parameterC}})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--对方获得灼伤DEBUFF
function BattleSkill.ProbGetZHSdebuff(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        table.insert(damageTbl,{true,enemyBuffer = {id = skill.id ,buffid = 1, key = true, time = skill.parameterB , value1 = skill.parameterC}})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--对方获得缓速DEBUFF
function BattleSkill.ProbGetHSdebuff(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        table.insert(damageTbl,{true,enemyBuffer = {id = skill.id ,buffid = 17, key = true, time = skill.parameterB , value1 = skill.parameterC}})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--对方获得眩晕DEBUFF
function BattleSkill.ProbGetHMdebuff(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        table.insert(damageTbl,{true,enemyBuffer = {id = skill.id ,buffid = 20, key = true, time = skill.parameterB}})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--对方获得混乱DEBUFF
function BattleSkill.ProbGetHLdebuff(me,enemy,round,timing,skill)
    local damageTbl = {}
    if GetRandom.random(0,99) < skill.parameterA then
        table.insert(damageTbl,{true,enemyBuffer = {id = skill.id ,buffid = 10, key = true, time = skill.parameterB , value1 = skill.parameterC , value2 = skill.parameterD}})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--防御时增加魔防
function BattleSkill.ProbFADDsdef(me,enemy,round,timing,skill)
    local damageTbl = {}
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if timing == ROUND_BefDEF and GetRandom.random(0,99) < skill.parameterA then
        getSkillUtilValue(me.tag,skill.id).iseffected = true
        me.sdef = me.sdef * (1 + skill.parameterB/100)
        table.insert(damageTbl,{true})
    elseif timing == ROUND_AfterDEF and getSkillUtilValue(me.tag,skill.id).iseffected == true then
        getSkillUtilValue(me.tag,skill.id).iseffected = false
        me.sdef = me.sdef / (1 + skill.parameterB/100)
        table.insert(damageTbl,{false})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--防御时增加物防
function BattleSkill.ProbFADDdef(me,enemy,round,timing,skill)
    local damageTbl = {}
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if timing == ROUND_BefDEF and GetRandom.random(0,99) < skill.parameterA then
        getSkillUtilValue(me.tag,skill.id).iseffected = true
        me.def = me.def * (1 + skill.parameterB/100)
        table.insert(damageTbl,{true})
    elseif timing == ROUND_AfterDEF and getSkillUtilValue(me.tag,skill.id).iseffected == true then
        getSkillUtilValue(me.tag,skill.id).iseffected = false
        me.def = me.def / (1 + skill.parameterB/100)
        table.insert(damageTbl,{false})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--防御时增加双防
function BattleSkill.ProbFADDdoubledef(me,enemy,round,timing,skill)
    local damageTbl = {}
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if timing == ROUND_BefDEF and GetRandom.random(0,99) < skill.parameterA then
        getSkillUtilValue(me.tag,skill.id).iseffected = true
        me.def = me.def * (1 + skill.parameterB/100)
        me.sdef = me.sdef * (1 + skill.parameterC/100)
        table.insert(damageTbl,{true})
    elseif timing == ROUND_AfterDEF and getSkillUtilValue(me.tag,skill.id).iseffected == true then
        getSkillUtilValue(me.tag,skill.id).iseffected = false
        me.def = me.def / (1 + skill.parameterB/100)
        me.sdef = me.sdef / (1 + skill.parameterC/100)
        table.insert(damageTbl,{false})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--防御时增加魔攻
function BattleSkill.ProbFADDsatk(me,enemy,round,timing,skill)
    local damageTbl = {}
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if timing == ROUND_BefDEF and GetRandom.random(0,99) < skill.parameterA then
        getSkillUtilValue(me.tag,skill.id).iseffected = true
        me.satk = me.satk * (1 + skill.parameterB/100)
        table.insert(damageTbl,{true})
    elseif timing == ROUND_AfterDEF and getSkillUtilValue(me.tag,skill.id).iseffected == true then
        getSkillUtilValue(me.tag,skill.id).iseffected = false
        me.satk = me.satk / (1 + skill.parameterB/100)
        table.insert(damageTbl,{false})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--防御时增加物攻
function BattleSkill.ProbFADDatk(me,enemy,round,timing,skill)
    local damageTbl = {}
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if timing == ROUND_BefDEF and GetRandom.random(0,99) < skill.parameterA then
        getSkillUtilValue(me.tag,skill.id).iseffected = true
        me.atk = me.atk * (1 + skill.parameterB/100)
        table.insert(damageTbl,{true})
    elseif timing == ROUND_AfterDEF and getSkillUtilValue(me.tag,skill.id).iseffected == true then
        getSkillUtilValue(me.tag,skill.id).iseffected = false
        me.atk = me.atk / (1 + skill.parameterB/100)
        table.insert(damageTbl,{false})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--防御时增加双攻
function BattleSkill.ProbFADDdoubleatk(me,enemy,round,timing,skill)
    local damageTbl = {}
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if timing == ROUND_BefDEF and GetRandom.random(0,99) < skill.parameterA then
        getSkillUtilValue(me.tag,skill.id).iseffected = true
        me.atk = me.atk * (1 + skill.parameterB/100)
        me.satk = me.satk * (1 + skill.parameterC/100)
        table.insert(damageTbl,{true})
    elseif timing == ROUND_AfterDEF and getSkillUtilValue(me.tag,skill.id).iseffected == true then
        getSkillUtilValue(me.tag,skill.id).iseffected = false
        me.atk = me.atk / (1 + skill.parameterB/100)
        me.satk = me.satk / (1 + skill.parameterC/100)
        table.insert(damageTbl,{false})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--防御时增加回避
function BattleSkill.ProbFADDDodge(me,enemy,round,timing,skill)
    local damageTbl = {}
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if timing == ROUND_BefDEF and GetRandom.random(0,99) < skill.parameterA then
        getSkillUtilValue(me.tag,skill.id).iseffected = true
        me.Dodge = me.Dodge + skill.parameterB
        table.insert(damageTbl,{true})
    elseif timing == ROUND_AfterDEF and getSkillUtilValue(me.tag,skill.id).iseffected == true then
        getSkillUtilValue(me.tag,skill.id).iseffected = false
        me.Dodge = me.Dodge - skill.parameterB
        table.insert(damageTbl,{false})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--防御时增加速度
function BattleSkill.ProbFADDspeed(me,enemy,round,timing,skill)
    local damageTbl = {}
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if timing == ROUND_BefDEF and GetRandom.random(0,99) < skill.parameterA then
        getSkillUtilValue(me.tag,skill.id).iseffected = true
        me.speed = me.speed * (1 + skill.parameterB/100)
        table.insert(damageTbl,{true})
    elseif timing == ROUND_AfterDEF and getSkillUtilValue(me.tag,skill.id).iseffected == true then
        getSkillUtilValue(me.tag,skill.id).iseffected = false
        me.speed = me.speed / (1 + skill.parameterB/100)
        table.insert(damageTbl,{false})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--防御时减少双攻
function BattleSkill.ProbFADDdoubleatk(me,enemy,round,timing,skill)
    local damageTbl = {}
    setSkillUtilValue(me.tag,skill.id,{iseffected = false})
    if timing == ROUND_BefDEF and GetRandom.random(0,99) < skill.parameterA then
        getSkillUtilValue(me.tag,skill.id).iseffected = true
        enemy.atk = enemy.atk * (1 - skill.parameterB/100)
        enemy.satk = enemy.satk * (1 - skill.parameterC/100)
        table.insert(damageTbl,{true})
    elseif timing == ROUND_AfterDEF and getSkillUtilValue(me.tag,skill.id).iseffected == true then
        getSkillUtilValue(me.tag,skill.id).iseffected = false
        enemy.atk = enemy.atk / (1 - skill.parameterB/100)
        enemy.satk = enemy.satk / (1 - skill.parameterC/100)
        table.insert(damageTbl,{false})
    else
        table.insert(damageTbl,{false})
    end
    BattleSkill["ret"] = damageTbl
end

--计算命中率
--CalHitRate(me,enemy,skill)

--计算暴击
--local iscritical = CalIsCritical(me.Critical,enemy.CritResistance,参数)

--伤害修正比例计算
--local damageRate = CaldamageRate(PokemonInfo.getPokemonInfoByID(me.pokeID),skill.skillAtt,PokemonInfo.getPokemonInfoByID(enemy.pokeID))

--计算伤害
--local finaldamage = CalDamage(me,enemy,skill)

--debuff
--(self)enemyBuffer = {id = skill.id ,buffid = 1, key = true, time = 参数 , value = {参数}}

--被动技能返还值，第一个返还字段true则弹出提示，false则不弹提示

--TipsMgr.show(scene, "000000000000 ")

--selfreplace = 1（可换宠），0（不可换宠）

--self（enemy）size = 0（变小），1（正常），2（变大）
return BattleSkill