local BattleBuffer = {}
BattleBuffer.valueStore = {}

--    BattleBuffer["bufferInfo"]
--    BattleBuffer["me"]
--    BattleBuffer["enemy"]

--自定义状态全局变量创建
function setBuffUtilValue(tag,skillID,Tbl)
    local index = tostring(tag)    
    if not BattleBuffer.valueStore[index] then
        BattleBuffer.valueStore[index] = {}
    end
    if not BattleBuffer.valueStore[index][tostring(skillID)] then
        BattleBuffer.valueStore[index][tostring(skillID)] = {}
    end
    if not Tbl then
        BattleBuffer.valueStore[index][tostring(skillID)] = nil
        return
    end
    for key,var in pairs(Tbl) do
        if not BattleBuffer.valueStore[index][tostring(skillID)][key] then
            BattleBuffer.valueStore[index][tostring(skillID)][key] = var
        end
    end
end

--自定义技能全部变量使用
function getBuffUtilValue(tag,skillID)
    local index = tostring(tag)
    if not BattleBuffer.valueStore[index] then
        printFileLog("技能lua 没有想要数据")
        return nil
    end
    if not BattleBuffer.valueStore[index][tostring(skillID)] then
        printFileLog("技能lua 没有想要数据")
        return nil
    end
    
    return BattleBuffer.valueStore[index][tostring(skillID)]
end

--buff叠加
function isRebuff(buffValue,Buff,param,addValue)
    if Buff.rebuff then
        for key,var in pairs(param) do
            buffValue[key] = buffValue[key] + addValue
        end
    end
    Buff.rebuff = false
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

--self（enemy）activity = 0 （能动）， 1（不能）

--判断是否可以行动
function judgeMove(buffer)
    local canMove = true
    for k,v in pairs(buffer) do
        if buffer.application then
            if buffer.application[1].selfactivity then
                if buffer.application[1].selfactivity == 1 then
                    canMove = false
                end
            end
        end
    end
    return canMove   
end

--没有实际效果的状态
function BattleBuffer.Empty(me,enemy,round,BUFF,timing)
    BattleBuffer["ret"] = nil
end

--灼伤 id=1掉血
function BattleBuffer.FireState(me,enemy,round,BUFF,timing)
    local effectTbl = {}
    local damage    = 0
    if not getBuffUtilValue(me.tag,BUFF.id) then
        setBuffUtilValue(me.tag,BUFF.id,{sum = BUFF.value1})
    end
    isRebuff(getBuffUtilValue(me.tag,BUFF.id),BUFF,{sum = true},BUFF.value1)

    if isbuffon(me,30) == true then--检测对方是否处于格挡(物伤减半)
        damage = getBuffUtilValue(me.tag,BUFF.id).sum/2
    else
        damage = getBuffUtilValue(me.tag,BUFF.id).sum
    end
    table.insert(effectTbl,{selfdamage = math.floor(damage)})
    BattleBuffer["ret"] = effectTbl    
end
--灼烧 id=1清理叠加数据
function BattleBuffer.FireOver(me,enemy,round,BUFF,timing)
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil    
end

--冰冻 id=2几率不能行动
function BattleBuffer.FreezeState(me,enemy,round,BUFF,timing)
	local effectTbl = {}
	if GetRandom.random(0,99) < BUFF.value1 then
		table.insert(effectTbl,{selfactivity = 1})   	
    else
        table.insert(effectTbl,{selfactivity = 0}) 
    end
    BattleBuffer["ret"] = effectTbl    
end

--麻痹 id=3几率不能行动
function BattleBuffer.ParalysisState(me,enemy,round,BUFF,timing)
	local effectTbl = {}
    setBuffUtilValue(me.tag,BUFF.id,{x = me.speed * BUFF.value1/100 , iseffected = false})
    if getBuffUtilValue(me.tag,BUFF.id).iseffected == false then
        getBuffUtilValue(me.tag,BUFF.id).iseffected = true
        me.speed = me.speed - getBuffUtilValue(me.tag,BUFF.id).x
    end
	if timing == ROUND_BefATK and GetRandom.random(0,99) < BUFF.value2 then        
	    table.insert(effectTbl,{selfactivity = 1})
        BattleBuffer["ret"] = effectTbl
    else
        BattleBuffer["ret"] = nil
    end
       
end
--麻痹效果结束 id=3
function BattleBuffer.ParalysisOver(me,enemy,round,BUFF,timing)
    me.speed = me.speed + getBuffUtilValue(me.tag,BUFF.id).x
	setBuffUtilValue(me.tag,BUFF.id,nil)  
    BattleBuffer["ret"] = nil 
end

--中毒 id=4掉血
function BattleBuffer.PoisonState(me,enemy,round,BUFF,timing)
	local effectTbl = {}
    local damage = 0
    if not getBuffUtilValue(me.tag,BUFF.id) then
        setBuffUtilValue(me.tag,BUFF.id,{sum = BUFF.value1})
    end
    isRebuff(getBuffUtilValue(me.tag,BUFF.id),BUFF,{sum = true},BUFF.value1)

    if isbuffon(me,14) == true then--检测对方是否处于光墙(法伤减半)
        damage = getBuffUtilValue(me.tag,BUFF.id).sum /2
    else
        damage = getBuffUtilValue(me.tag,BUFF.id).sum
    end
	table.insert(effectTbl,{selfdamage = math.floor(damage)})
    BattleBuffer["ret"] = effectTbl    
end
--中毒 id=4清理叠加数据
function BattleBuffer.PoisonOver(me,enemy,round,BUFF,timing)
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil    
end

--猛毒 id=5掉血越来越多
function BattleBuffer.BadlyPoisonState(me,enemy,round,BUFF,timing)
	local effectTbl = {}
    setBuffUtilValue(me.tag,BUFF.id,{count = 0})
    getSkillUtilValue(me.tag,BUFF.id).count = getSkillUtilValue(me.tag,BUFF.id).count + 1
	local damage = BUFF.value1 * getSkillUtilValue(me.tag,BUFF.id).count
    if isbuffon(me,14) == true then--检测对方是否处于光墙(法伤减半)
        damage = damage /2
    end
	table.insert(effectTbl,{selfdamage = math.floor(damage)})
    BattleBuffer["ret"] = effectTbl    
end
--猛毒效果结束 id=5
function BattleBuffer.BadlyPoisonOver(me,enemy,round,BUFF,timing)
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil
end

--睡眠 id=6不能行动
function BattleBuffer.SleepState(me,enemy,round,BUFF,timing)
	local effectTbl = {}
	table.insert(effectTbl,{selfactivity = 1})
    BattleBuffer["ret"] = effectTbl    
end

--束缚 id=7掉血
function BattleBuffer.BoundState(me,enemy,round,BUFF,timing)
	local effectTbl = {}
    local damage = 0
    if not getBuffUtilValue(me.tag,BUFF.id) then
        setBuffUtilValue(me.tag,BUFF.id,{sum = BUFF.value1})
    end
    isRebuff(getBuffUtilValue(me.tag,BUFF.id),BUFF,{sum = true},BUFF.value1)

    if isbuffon(me,30) == true then--检测对方是否处于格挡(物伤减半)
        damage = getBuffUtilValue(me.tag,BUFF.id).sum/2
    else
        damage = getBuffUtilValue(me.tag,BUFF.id).sum
    end
    table.insert(effectTbl,{selfdamage = math.floor(damage)})
    BattleBuffer["ret"] = effectTbl    
end
--束缚结束 id=7
function BattleBuffer.BoundOver(me,enemy,round,BUFF,timing)
    local effectTbl = {}
    setBuffUtilValue(me.tag,BUFF.id,nil)
    table.insert(effectTbl,{selfreplace = 1})
    BattleBuffer["ret"] = effectTbl    
end

--退缩 id=8不能行动
function BattleBuffer.CowerState(me,enemy,round,BUFF,timing)
	local effectTbl = {}
    if GetRandom.random(0,99) < BUFF.value1 then
        table.insert(effectTbl,{selfactivity = 1})
        BattleBuffer["ret"] = effectTbl
    else
        BattleBuffer["ret"] = nil
    end
end

   
--缩小状态结束 id=9
function BattleBuffer.SmallOver(me,enemy,round,BUFF,timing)
    local effectTbl = {}
    me.Dodge = me.Dodge - BUFF.value1
    table.insert(effectTbl,{selfsize = 1})
    BattleBuffer["ret"] = effectTbl    
end

--混乱 id=10概率自残
function BattleBuffer.ChaosState(me,enemy,round,BUFF,timing)
    local effectTbl = {}
    if judgeMove(me.buffer) and GetRandom.random(0,99) < BUFF.value1 then
        local damage = CalBuffDamage(me,enemy,BUFF.value2,3)
        if isbuffon(me,30) == true then--检测对方是否处于格挡(物伤减半)
            damage = damage/2
        end
        table.insert(effectTbl,{selfdamage = math.floor(damage) , selfactivity = 1})
        BattleBuffer["ret"] = effectTbl 
    else
        BattleBuffer["ret"] = nil
    end
end

--致盲 id=12降低命中
function BattleBuffer.ReduceHitrateState(me,enemy,round,BUFF,timing)
    if not getBuffUtilValue(me.tag,BUFF.id) then
        setBuffUtilValue(me.tag,BUFF.id,{count = 1})
        me.HitRate = me.HitRate - BUFF.value1
    end
    if BUFF.rebuff then
        me.HitRate = me.HitRate + BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
        getBuffUtilValue(me.tag,BUFF.id).count = getBuffUtilValue(me.tag,BUFF.id).count + 1
        me.HitRate = me.HitRate - BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
    end
    BattleBuffer["ret"] = nil   
end
--致盲结束 id=12还原命中
function BattleBuffer.ReduceHitrateOver(me,enemy,round,BUFF,timing)
    me.HitRate = me.HitRate + BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil   
end

--寄生种子 id=13
function BattleBuffer.LeechSeedState(me,enemy,round,BUFF,timing)
    local effectTbl = {}
    local x = math.floor(me.bloodLimit * BUFF.value1/100)
    table.insert(effectTbl,{selfdamage = x , enemyheal = math.floor(x * enemy.healRate)})
    BattleBuffer["ret"] = effectTbl    
end

--破甲 id=15降低物防
function BattleBuffer.ReduceDefState(me,enemy,round,BUFF,timing)
    if not getBuffUtilValue(me.tag,BUFF.id) then
        setBuffUtilValue(me.tag,BUFF.id,{x = me.def * BUFF.value1/100 , count = 1})
        me.def = me.def - getBuffUtilValue(me.tag,BUFF.id).x
    end
    if BUFF.rebuff then
        me.def = me.def + getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
        getBuffUtilValue(me.tag,BUFF.id).count = getBuffUtilValue(me.tag,BUFF.id).count + 1
        me.def = me.def - getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
    end
    BattleBuffer["ret"] = nil   
end
--破甲结束 id=15还原物防
function BattleBuffer.ReduceDefOver(me,enemy,round,BUFF,timing)
    me.def = me.def + getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil   
end

--破魔 id=16降低魔防
function BattleBuffer.ReduceSdefState(me,enemy,round,BUFF,timing)
    if not getBuffUtilValue(me.tag,BUFF.id) then
        setBuffUtilValue(me.tag,BUFF.id,{x = me.sdef * BUFF.value1/100 , count = 1})
        me.sdef = me.sdef - getBuffUtilValue(me.tag,BUFF.id).x
    end
    if BUFF.rebuff then
        me.sdef = me.sdef + getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
        getBuffUtilValue(me.tag,BUFF.id).count = getBuffUtilValue(me.tag,BUFF.id).count + 1
        me.sdef = me.sdef - getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
    end
    BattleBuffer["ret"] = nil   
end
--破魔结束 id=16还原魔防
function BattleBuffer.ReduceSdefOver(me,enemy,round,BUFF,timing)
    me.sdef = me.sdef + getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil   
end

--缓速 id=17降低速度
function BattleBuffer.ReduceSpdState(me,enemy,round,BUFF,timing)
    if not getBuffUtilValue(me.tag,BUFF.id) then
        setBuffUtilValue(me.tag,BUFF.id,{x = me.speed * BUFF.value1/100 , count = 1})
        me.speed = me.speed - getBuffUtilValue(me.tag,BUFF.id).x
    end
    if BUFF.rebuff then
        me.speed = me.speed + getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
        getBuffUtilValue(me.tag,BUFF.id).count = getBuffUtilValue(me.tag,BUFF.id).count + 1
        me.speed = me.speed - getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
    end
    BattleBuffer["ret"] = nil  
end
--缓速结束 id=17还原速度
function BattleBuffer.ReduceSpdOver(me,enemy,round,BUFF,timing)
    me.speed = me.speed + getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil  
end

--虚弱 id=18降低物攻
function BattleBuffer.ReduceAtkState(me,enemy,round,BUFF,timing)
    if not getBuffUtilValue(me.tag,BUFF.id) then
        setBuffUtilValue(me.tag,BUFF.id,{x = me.atk * BUFF.value1/100 , count = 1})
        me.atk = me.atk - getBuffUtilValue(me.tag,BUFF.id).x
    end
    if BUFF.rebuff then
        me.atk = me.atk + getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
        getBuffUtilValue(me.tag,BUFF.id).count = getBuffUtilValue(me.tag,BUFF.id).count + 1
        me.atk = me.atk - getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
    end
    BattleBuffer["ret"] = nil  
end
--虚弱结束 id=18还原物攻
function BattleBuffer.ReduceAtkOver(me,enemy,round,BUFF,timing)
    me.atk = me.atk + getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil  
end

--恍惚 id=19降低魔攻
function BattleBuffer.ReduceSatkState(me,enemy,round,BUFF,timing)
    if not getBuffUtilValue(me.tag,BUFF.id) then
        setBuffUtilValue(me.tag,BUFF.id,{x = me.satk * BUFF.value1/100 , count = 1})
        me.satk = me.satk - getBuffUtilValue(me.tag,BUFF.id).x
    end
    if BUFF.rebuff then
        me.satk = me.satk + getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
        getBuffUtilValue(me.tag,BUFF.id).count = getBuffUtilValue(me.tag,BUFF.id).count + 1
        me.satk = me.satk - getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
    end
    BattleBuffer["ret"] = nil  
end
--恍惚结束 id=19还原魔攻
function BattleBuffer.ReduceSatkOver(me,enemy,round,BUFF,timing)
    me.satk = me.satk + getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil  
end

--昏迷 id=20无法行动
function BattleBuffer.ComaState(me,enemy,round,BUFF,timing)
    local effectTbl = {}
    table.insert(effectTbl,{selfactivity = 1})
    BattleBuffer["ret"] = effectTbl
end

--生长 id=21提高物魔双攻
function BattleBuffer.GrowthState(me,enemy,round,BUFF,timing)
    if not getBuffUtilValue(me.tag,BUFF.id) then
        setBuffUtilValue(me.tag,BUFF.id,{addatk = me.atk * BUFF.value1/100 , addsatk = me.satk * BUFF.value1/100 , count = 1})
        me.atk = me.atk + getBuffUtilValue(me.tag,BUFF.id).addatk
        me.satk = me.satk + getBuffUtilValue(me.tag,BUFF.id).addsatk
    end
    if BUFF.rebuff then
        me.atk = me.atk - getBuffUtilValue(me.tag,BUFF.id).addatk * getBuffUtilValue(me.tag,BUFF.id).count
        me.satk = me.satk - getBuffUtilValue(me.tag,BUFF.id).addsatk * getBuffUtilValue(me.tag,BUFF.id).count
        getBuffUtilValue(me.tag,BUFF.id).count = getBuffUtilValue(me.tag,BUFF.id).count + 1
        me.atk = me.atk + getBuffUtilValue(me.tag,BUFF.id).addatk * getBuffUtilValue(me.tag,BUFF.id).count
        me.satk = me.satk + getBuffUtilValue(me.tag,BUFF.id).addsatk * getBuffUtilValue(me.tag,BUFF.id).count
    end
    BattleBuffer["ret"] = nil  
end
--生长结束 id=21还原双攻
function BattleBuffer.GrowthOver(me,enemy,round,BUFF,timing)
    me.atk = me.atk - getBuffUtilValue(me.tag,BUFF.id).addatk * getBuffUtilValue(me.tag,BUFF.id).count
    me.satk = me.satk - getBuffUtilValue(me.tag,BUFF.id).addsatk * getBuffUtilValue(me.tag,BUFF.id).count
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil  
end

--利刃 id=22提高物攻
function BattleBuffer.RaiseAtkState(me,enemy,round,BUFF,timing)
    if not getBuffUtilValue(me.tag,BUFF.id) then
        setBuffUtilValue(me.tag,BUFF.id,{x = me.atk * BUFF.value1/100 , count = 1})
        me.atk = me.atk + getBuffUtilValue(me.tag,BUFF.id).x
    end
    if BUFF.rebuff then
        me.atk = me.atk - getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
        getBuffUtilValue(me.tag,BUFF.id).count = getBuffUtilValue(me.tag,BUFF.id).count + 1
        me.atk = me.atk + getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
    end
    BattleBuffer["ret"] = nil  
end
--利刃结束 id=22还原物攻
function BattleBuffer.RaiseAtkOver(me,enemy,round,BUFF,timing)
    me.atk = me.atk - getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil  
end

--铁壁 id=23提高物防
function BattleBuffer.RaiseDefState(me,enemy,round,BUFF,timing)
    if not getBuffUtilValue(me.tag,BUFF.id) then
        setBuffUtilValue(me.tag,BUFF.id,{x = me.def * BUFF.value1/100 , count = 1})
        me.def = me.def + getBuffUtilValue(me.tag,BUFF.id).x
    end
    if BUFF.rebuff then
        me.def = me.def - getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
        getBuffUtilValue(me.tag,BUFF.id).count = getBuffUtilValue(me.tag,BUFF.id).count + 1
        me.def = me.def + getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
    end
    BattleBuffer["ret"] = nil  
end
--铁壁结束 id=23还原物防
function BattleBuffer.RaiseDefOver(me,enemy,round,BUFF,timing)
    me.def = me.def - getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil  
end

--集中 id=24提高魔攻
function BattleBuffer.RaiseSatkState(me,enemy,round,BUFF,timing)
    if not getBuffUtilValue(me.tag,BUFF.id) then
        setBuffUtilValue(me.tag,BUFF.id,{x = me.satk * BUFF.value1/100 , count = 1})
        me.satk = me.satk + getBuffUtilValue(me.tag,BUFF.id).x
    end
    if BUFF.rebuff then
        me.satk = me.satk - getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
        getBuffUtilValue(me.tag,BUFF.id).count = getBuffUtilValue(me.tag,BUFF.id).count + 1
        me.satk = me.satk + getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
    end
    BattleBuffer["ret"] = nil  
end
--集中结束 id=24还原魔攻
function BattleBuffer.RaiseSatkOver(me,enemy,round,BUFF,timing)
    me.satk = me.satk - getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil  
end

--抗魔 id=25提高魔防
function BattleBuffer.RaiseSdefState(me,enemy,round,BUFF,timing)
    if not getBuffUtilValue(me.tag,BUFF.id) then
        setBuffUtilValue(me.tag,BUFF.id,{x = me.sdef * BUFF.value1/100 , count = 1})
        me.sdef = me.sdef + getBuffUtilValue(me.tag,BUFF.id).x
    end
    if BUFF.rebuff then
        me.sdef = me.sdef - getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
        getBuffUtilValue(me.tag,BUFF.id).count = getBuffUtilValue(me.tag,BUFF.id).count + 1
        me.sdef = me.sdef + getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
    end
    BattleBuffer["ret"] = nil  
end
--抗魔结束 id=25还原魔防
function BattleBuffer.RaiseSdefOver(me,enemy,round,BUFF,timing)
    me.sdef = me.sdef - getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil  
end

--神行 id=26提高速度
function BattleBuffer.RaiseSpdState(me,enemy,round,BUFF,timing)
    if not getBuffUtilValue(me.tag,BUFF.id) then
        setBuffUtilValue(me.tag,BUFF.id,{x = me.speed * BUFF.value1/100 , count = 1})
        me.speed = me.speed + getBuffUtilValue(me.tag,BUFF.id).x
    end
    if BUFF.rebuff then
        me.speed = me.speed - getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
        getBuffUtilValue(me.tag,BUFF.id).count = getBuffUtilValue(me.tag,BUFF.id).count + 1
        me.speed = me.speed + getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
    end
    BattleBuffer["ret"] = nil  
end
--神行结束 id=26还原速度
function BattleBuffer.RaiseSpdOver(me,enemy,round,BUFF,timing)
    me.speed = me.speed - getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil  
end

--闪避 id=27提高闪避
function BattleBuffer.RaiseDogeState(me,enemy,round,BUFF,timing)
    if not getBuffUtilValue(me.tag,BUFF.id) then
        setBuffUtilValue(me.tag,BUFF.id,{count = 1})
        me.Dodge = me.Dodge + BUFF.value1
    end
    if BUFF.rebuff then
        me.Dodge = me.Dodge - BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
        getBuffUtilValue(me.tag,BUFF.id).count = getBuffUtilValue(me.tag,BUFF.id).count + 1
        me.Dodge = me.Dodge + BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
    end
    BattleBuffer["ret"] = nil  
end
--闪避结束 id=27还原闪避
function BattleBuffer.RaiseDogeOver(me,enemy,round,BUFF,timing)
    me.Dodge = me.Dodge - BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil  
end

--迟钝 id=28降低闪避
function BattleBuffer.ReduceDogeState(me,enemy,round,BUFF,timing)
    if not getBuffUtilValue(me.tag,BUFF.id) then
        setBuffUtilValue(me.tag,BUFF.id,{count = 1})
        me.Dodge = me.Dodge - BUFF.value1
    end
    if BUFF.rebuff then
        me.Dodge = me.Dodge + BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
        getBuffUtilValue(me.tag,BUFF.id).count = getBuffUtilValue(me.tag,BUFF.id).count + 1
        me.Dodge = me.Dodge - BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
    end
    BattleBuffer["ret"] = nil  
end
--迟钝结束 id=28还原闪避
function BattleBuffer.ReduceDogeOver(me,enemy,round,BUFF,timing)
    me.Dodge = me.Dodge - BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil  
end

--鹰眼 id=29提高命中
function BattleBuffer.RaiseHitrateState(me,enemy,round,BUFF,timing)
    if not getBuffUtilValue(me.tag,BUFF.id) then
        setBuffUtilValue(me.tag,BUFF.id,{count = 1})
        me.HitRate = me.HitRate + BUFF.value1
    end
    if BUFF.rebuff then
        me.HitRate = me.HitRate - BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
        getBuffUtilValue(me.tag,BUFF.id).count = getBuffUtilValue(me.tag,BUFF.id).count + 1
        me.HitRate = me.HitRate + BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
    end
    BattleBuffer["ret"] = nil   
end
--鹰眼结束 id=29还原命中
function BattleBuffer.RaiseHitrateOver(me,enemy,round,BUFF,timing)
    me.HitRate = me.HitRate + BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil   
end

--好运 id=31提高暴击
function BattleBuffer.RaiseCriticalState(me,enemy,round,BUFF,timing)
    if not getBuffUtilValue(me.tag,BUFF.id) then
        setBuffUtilValue(me.tag,BUFF.id,{count = 1})
        me.Critical = me.Critical + BUFF.value1
    end
    if BUFF.rebuff then
        me.Critical = me.Critical - BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
        getBuffUtilValue(me.tag,BUFF.id).count = getBuffUtilValue(me.tag,BUFF.id).count + 1
        me.Critical = me.Critical + BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
    end
    BattleBuffer["ret"] = nil   
end
--好运结束 id=31还原暴击
function BattleBuffer.RaiseCriticalOver(me,enemy,round,BUFF,timing)
    me.Critical = me.Critical - BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil   
end

--厄运 id=32降低暴击
function BattleBuffer.ReduceCriticalState(me,enemy,round,BUFF,timing)
    if not getBuffUtilValue(me.tag,BUFF.id) then
        setBuffUtilValue(me.tag,BUFF.id,{count = 1})
        me.Critical = me.Critical - BUFF.value1
    end
    if BUFF.rebuff then
        me.Critical = me.Critical + BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
        getBuffUtilValue(me.tag,BUFF.id).count = getBuffUtilValue(me.tag,BUFF.id).count + 1
        me.Critical = me.Critical - BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
    end
    BattleBuffer["ret"] = nil   
end
--厄运结束 id=32还原暴击
function BattleBuffer.ReduceCriticalOver(me,enemy,round,BUFF,timing)
    me.Critical = me.Critical + BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil   
end

--毒牙 id = 33 中毒+降低特功
function BattleBuffer.TeeAttackState(me,enemy,round,BUFF,timing)
    local effectTbl = {}
    setBuffUtilValue(me.tag,BUFF.id,{x = me.satk * BUFF.value2/100 , iseffected = false})
    if getBuffUtilValue(me.tag,BUFF.id).iseffected == false then
        getBuffUtilValue(me.tag,BUFF.id).iseffected = true
        me.satk = me.satk - getBuffUtilValue(me.tag,BUFF.id).x
    end
    if isbuffon(me,14) == true then--检测对方是否处于光墙(法伤减半)
        local damage = BUFF.value1 /2
    else
        local damage = BUFF.value1
    end
    table.insert(effectTbl,{selfdamage = math.floor(damage)})
    BattleBuffer["ret"] = effectTbl
end
--毒牙结束 id = 33 还原特功
function BattleBuffer.TeeAttackOver(me,enemy,round,BUFF,timing)
    me.satk = me.satk + getBuffUtilValue(me.tag,BUFF.id).x
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil   
end

--绝对防御+ id = 34提高物防
function BattleBuffer.TotalDefenceState1(me,enemy,round,BUFF,timing)
    if not getBuffUtilValue(me.tag,BUFF.id) then
        setBuffUtilValue(me.tag,BUFF.id,{x = me.def * BUFF.value1/100 , count = 1})
        me.def = me.def + getBuffUtilValue(me.tag,BUFF.id).x
    end
    if BUFF.rebuff then
        me.def = me.def - getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
        getBuffUtilValue(me.tag,BUFF.id).count = getBuffUtilValue(me.tag,BUFF.id).count + 1
        me.def = me.def + getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
    end
    BattleBuffer["ret"] = nil  
end
--绝对防御+ id = 34还原物防
function BattleBuffer.TotalDefenceOver1(me,enemy,round,BUFF,timing)
    me.def = me.def - getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil  
end

--十万伏特 id = 35 减速+减特防
function BattleBuffer.ThunderboltState(me,enemy,round,BUFF,timing)
    local effectTbl = {}
    setBuffUtilValue(me.tag,BUFF.id,{x = me.speed * BUFF.value1/100 ,sdef = me.sdef * BUFF.value3/100 , iseffected = false})
    if getBuffUtilValue(me.tag,BUFF.id).iseffected == false then
        getBuffUtilValue(me.tag,BUFF.id).iseffected = true
        me.speed = me.speed - getBuffUtilValue(me.tag,BUFF.id).x
        me.sdef = me.sdef - getBuffUtilValue(me.tag,BUFF.id).sdef
    end
    if timing == ROUND_BefATK and GetRandom.random(0,99) < BUFF.value2 then        
        table.insert(effectTbl,{selfactivity = 1})
    else
        table.insert(effectTbl,{selfactivity = 0}) 
    end
    BattleBuffer["ret"] = effectTbl
end
--十万伏特结束 id = 35 还原减速+减特防
function BattleBuffer.ThunderboltOver(me,enemy,round,BUFF,timing)
    me.speed = me.speed + getBuffUtilValue(me.tag,BUFF.id).x
    me.sdef = me.sdef + getBuffUtilValue(me.tag,BUFF.id).sdef
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil
end

--绝对防御- id=36降低物魔双攻
function BattleBuffer.TotalDefenceState2(me,enemy,round,BUFF,timing)
    if not getBuffUtilValue(me.tag,BUFF.id) then
        setBuffUtilValue(me.tag,BUFF.id,{addatk = me.atk * BUFF.value1/100 , addsatk = me.satk * BUFF.value1/100, count = 1})
        me.atk = me.atk - getBuffUtilValue(me.tag,BUFF.id).addatk
        me.satk = me.satk - getBuffUtilValue(me.tag,BUFF.id).addsatk
    end
    if BUFF.rebuff then
        me.atk = me.atk + getBuffUtilValue(me.tag,BUFF.id).addatk * getBuffUtilValue(me.tag,BUFF.id).count
        me.satk = me.satk + getBuffUtilValue(me.tag,BUFF.id).addsatk * getBuffUtilValue(me.tag,BUFF.id).count
        getBuffUtilValue(me.tag,BUFF.id).count = getBuffUtilValue(me.tag,BUFF.id).count + 1
        me.atk = me.atk - getBuffUtilValue(me.tag,BUFF.id).addatk * getBuffUtilValue(me.tag,BUFF.id).count
        me.satk = me.satk - getBuffUtilValue(me.tag,BUFF.id).addsatk * getBuffUtilValue(me.tag,BUFF.id).count
    end
    BattleBuffer["ret"] = nil  
end
--绝对防御- id=36还原双攻
function BattleBuffer.TotalDefenceOver2(me,enemy,round,BUFF,timing)
    me.atk = me.atk + getBuffUtilValue(me.tag,BUFF.id).addatk * getBuffUtilValue(me.tag,BUFF.id).count
    me.satk = me.satk + getBuffUtilValue(me.tag,BUFF.id).addsatk * getBuffUtilValue(me.tag,BUFF.id).count
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil  
end

--激发潜能 id=37提高速度与闪避
function BattleBuffer.SpdAndDodgeState(me,enemy,round,BUFF,timing)
    if not getBuffUtilValue(me.tag,BUFF.id) then
        setBuffUtilValue(me.tag,BUFF.id,{count = 1})
        me.speed = me.speed + BUFF.value1
        me.Dodge = me.Dodge + BUFF.value2
    end
    if BUFF.rebuff then
        me.speed = me.speed - BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
        me.Dodge = me.Dodge - BUFF.value2 * getBuffUtilValue(me.tag,BUFF.id).count
        getBuffUtilValue(me.tag,BUFF.id).count = getBuffUtilValue(me.tag,BUFF.id).count + 1
        me.speed = me.speed + BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
        me.Dodge = me.Dodge + BUFF.value2 * getBuffUtilValue(me.tag,BUFF.id).count
    end
    BattleBuffer["ret"] = nil   
end
--激发潜能结束 id=37还原速度与闪避
function BattleBuffer.SpdAndDodgeOver(me,enemy,round,BUFF,timing)
    me.speed = me.speed - BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
    me.Dodge = me.Dodge - BUFF.value2 * getBuffUtilValue(me.tag,BUFF.id).count
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil   
end

--抵抗 id=38提高暴击抵抗
function BattleBuffer.RaiseCriRState(me,enemy,round,BUFF,timing)
    if not getBuffUtilValue(me.tag,BUFF.id) then
        setBuffUtilValue(me.tag,BUFF.id,{count = 1})
        me.CritResistance = me.CritResistance + BUFF.value1
    end
    if BUFF.rebuff then
        me.CritResistance = me.CritResistance - BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
        getBuffUtilValue(me.tag,BUFF.id).count = getBuffUtilValue(me.tag,BUFF.id).count + 1
        me.CritResistance = me.CritResistance + BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
    end
    BattleBuffer["ret"] = nil   
end
--抵抗结束 id=38还原暴击抵抗
function BattleBuffer.RaiseCriROver(me,enemy,round,BUFF,timing)
    me.CritResistance = me.CritResistance - BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil   
end

--脆弱 id=39降低暴击抵抗
function BattleBuffer.ReduceCriRState(me,enemy,round,BUFF,timing)
    if not getBuffUtilValue(me.tag,BUFF.id) then
        setBuffUtilValue(me.tag,BUFF.id,{count = 1})
        me.CritResistance = me.CritResistance - BUFF.value1
    end
    if BUFF.rebuff then
        me.CritResistance = me.CritResistance + BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
        getBuffUtilValue(me.tag,BUFF.id).count = getBuffUtilValue(me.tag,BUFF.id).count + 1
        me.CritResistance = me.CritResistance - BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
    end
    BattleBuffer["ret"] = nil   
end
--脆弱结束 id=39还原暴击抵抗
function BattleBuffer.ReduceCriROver(me,enemy,round,BUFF,timing)
    me.CritResistance = me.CritResistance + BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil   
end

--真月读 id=40提高魔攻与暴击率
function BattleBuffer.zhenyueduState(me,enemy,round,BUFF,timing)
    if not getBuffUtilValue(me.tag,BUFF.id) then
        setBuffUtilValue(me.tag,BUFF.id,{x = me.satk * BUFF.value1/100 ,count = 1})
        me.satk = me.satk + getBuffUtilValue(me.tag,BUFF.id).x
        me.Critical = me.Critical + BUFF.value1
    end
    if BUFF.rebuff then
        me.satk = me.satk - getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
        me.Critical = me.Critical - BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
        getBuffUtilValue(me.tag,BUFF.id).count = getBuffUtilValue(me.tag,BUFF.id).count + 1
        me.satk = me.satk + getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
        me.Critical = me.Critical + BUFF.value1 * getBuffUtilValue(me.tag,BUFF.id).count
    end
    BattleBuffer["ret"] = nil   
end
--真月读 id=40还原魔攻与暴击率
function BattleBuffer.zhenyueduOver(me,enemy,round,BUFF,timing)
    me.satk = me.satk - getBuffUtilValue(me.tag,BUFF.id).x * getBuffUtilValue(me.tag,BUFF.id).count
    me.Critical = me.Critical - BUFF.value2 * getBuffUtilValue(me.tag,BUFF.id).count
    setBuffUtilValue(me.tag,BUFF.id,nil)
    BattleBuffer["ret"] = nil   
end

--setBuffUtilValue(me.tag,BUFF.id,nil)  清空创建的参数

--BattleBuffer["ret"] = nil  无参数返还时

--TipsMgr.show(scene, "000000000000 ")

--selfreplace = 1（可换宠），0（不可换宠）

--self（enemy）size = 0（变小），1（正常），2（变大）

return BattleBuffer
