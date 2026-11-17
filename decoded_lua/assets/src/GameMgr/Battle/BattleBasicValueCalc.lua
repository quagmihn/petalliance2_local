local BattleBasicValueCalc = {}
--@param info 宠物信息表
--@param effortValue 星数--默认为0
--@param personalValue 生命训练次数--默认为0
--@param equipValue 生命装备修正值--默认为0
--@param talentValue 生命羁绊修正值--默认为0
--@param equipRate 生命装备修正比率--默认为0
--@param talentRate 生命羁绊修正比率--默认为0
--@param classRate 强化次数--默认为0
--@param level 等级  calcHp,calcAct,calcDef,calcSpeAct,calcSpeDef,calcSpeed 
--@param skin 皮肤参数--读表计算值后传进来
--@param science 科技加成数值
function BattleBasicValueCalc.calcHp(info,effortValue,personalValue,equipValue,talentValue,equipRate,talentRate,classRate,level,skin,science) 
    local raceHP = info.lifeRateValue * (1 + skin/100)
    local BaseNum = raceHP + raceHP / 12 * level + personalValue * 3 + raceHP * 3 / 40 * classRate
    local AddNum = equipValue + talentValue
    local AddRate = 1 + effortValue * SystemInfo.getGlobalConfigAddInfoByID(12000).values[1] / 100 + talentRate / 100 + equipRate / 100
    local life = BaseNum * AddRate * (2.5 + 4.5 * level / 50) + AddNum
    life = math.floor(life)
    life = life + (science or 0)
    return life
end 
--@param info 宠物信息表
--@param effortValue 星数
--@param personalValue 物攻训练次数  
--@param equipValue 物攻装备修正值
--@param talentValue 物攻羁绊修正值
--@param equipRate 物攻装备修正比率
--@param talentRate 物攻羁绊修正比率
--@param classRate 强化次数
--@param level 等级
--@param skin 皮肤参数--读表计算值后传进来
--@param science 科技加成数值
function BattleBasicValueCalc.calcAct(info,effortValue,personalValue,equipValue,talentValue,equipRate,talentRate,classRate,level,skin,science)
    local raceATK = info.atkRateValue * (1 + skin/100)
    local BaseNum = raceATK + raceATK / 12 * level + personalValue * 3 + raceATK * 3 / 40 * classRate
    local AddNum = equipValue + talentValue
    local AddRate = 1 + effortValue * SystemInfo.getGlobalConfigAddInfoByID(12000).values[1] / 100 + talentRate / 100 + equipRate / 100
    local atk = BaseNum * AddRate + AddNum
    atk = math.floor(atk)
    atk = atk + (science or 0)
    return atk
end
--@param info 宠物信息表
--@param effortValue 星数
--@param personalValue 物防训练次数
--@param equipValue 物防装备修正值
--@param talentValue 物防羁绊修正值
--@param equipRate 物防装备修正比率
--@param talentRate 物防羁绊修正比率
--@param classRate 强化次数
--@param level 等级
--@param skin 皮肤参数--读表计算值后传进来
--@param science 科技加成数值
function BattleBasicValueCalc.calcDef(info,effortValue,personalValue,equipValue,talentValue,equipRate,talentRate,classRate,level,skin,science)
    local raceDEF = info.defRateValue * (1 + skin/100)
    local BaseNum = raceDEF  + raceDEF / 12 * level + personalValue * 3 + raceDEF * 3 / 40 * classRate
    local AddNum = equipValue + talentValue
    local AddRate = 1 + effortValue * SystemInfo.getGlobalConfigAddInfoByID(12000).values[1] / 100 + talentRate / 100 + equipRate / 100
    local def = BaseNum * AddRate + AddNum
    def = math.floor(def)
    def = def + (science or 0)
    return def
end
--@param info 宠物信息表
--@param effortValue 星数
--@param personalValue 特功训练次数
--@param equipValue 特功装备修正值
--@param talentValue 特功羁绊修正值
--@param equipRate 特功装备修正比率
--@param talentRate 特功羁绊修正比率
--@param classRate 强化次数
--@param level 等级
--@param skin 皮肤参数--读表计算值后传进来
--@param science 科技加成数值
function BattleBasicValueCalc.calcSpeAct(info,effortValue,personalValue,equipValue,talentValue,equipRate,talentRate,classRate,level,skin,science)
    local raceSATK = info.satkRateValue * (1 + skin/100)
    local BaseNum = raceSATK + raceSATK / 12 * level + personalValue * 3 + raceSATK * 3 / 40 * classRate
    local AddNum = equipValue + talentValue
    local AddRate = 1 + effortValue * SystemInfo.getGlobalConfigAddInfoByID(12000).values[1] / 100 + talentRate / 100 + equipRate / 100
    local satk = BaseNum * AddRate + AddNum
    satk = math.floor(satk)
    satk = satk + (science or 0)
    return satk
end

--@param info 宠物信息表
--@param effortValue 星数
--@param personalValue 特防训练次数
--@param equipValue 特防装备修正值
--@param talentValue 特防羁绊修正值
--@param equipRate 特防装备修正比率
--@param talentRate 特防羁绊修正比率
--@param classRate 强化次数
--@param level 等级
--@param skin 皮肤参数--读表计算值后传进来
--@param science 科技加成数值
function BattleBasicValueCalc.calcSpeDef(info,effortValue,personalValue,equipValue,talentValue,equipRate,talentRate,classRate,level,skin,science)
    local raceSDEF = info.sdefRateValue * (1 + skin/100)
    local BaseNum = raceSDEF + raceSDEF /12 * level + personalValue * 3 + raceSDEF * 3 / 40 * classRate
    local AddNum = equipValue + talentValue
    local AddRate = 1 + effortValue * SystemInfo.getGlobalConfigAddInfoByID(12000).values[1] / 100 + talentRate / 100 + equipRate / 100
    local sdef = BaseNum * AddRate + AddNum
    sdef = math.floor(sdef)
    sdef = sdef + (science or 0)
    return sdef
end 

--@param info 宠物信息表
--@param effortValue 星数
--@param personalValue 速度训练次数
--@param equipValue 速度装备修正值
--@param talentValue 速度羁绊修正值
--@param equipRate 速度装备修正比率
--@param talentRate 速度羁绊修正比率
--@param classRate 强化次数
--@param level 等级
--@param skin 皮肤参数--读表计算值后传进来
--@param science 科技加成数值
function BattleBasicValueCalc.calcSpeed(info,effortValue,personalValue,equipValue,talentValue,equipRate,talentRate,classRate,level,skin,science)
    local raceSPD = info.speedRateValue * (1 + skin/100)
    local BaseNum = raceSPD + raceSPD / 12 * level + personalValue * 3 + raceSPD * 3 / 40 * classRate
    local AddNum = equipValue + talentValue
    local AddRate = 1 + effortValue * SystemInfo.getGlobalConfigAddInfoByID(12000).values[1] / 100 + talentRate / 100 + equipRate / 100
    local speed = BaseNum * AddRate + AddNum
    speed = math.floor(speed)
    speed = speed + (science or 0)
    return speed
end

--@param level 等级
--life 上面计算出来的生命值
--atk 上面计算出来的物攻
--def 上面计算出来的物防
--satk 上面计算出来的特功
--sdef 上面计算出来的特防
--spd 上面计算出来的速度
function BattleBasicValueCalc.calcFC(level,life,atk,def,satk,sdef,spd)--计算战斗力
    local FC = life / (2.5 + 4.5 * level / 50) + atk + def + satk + sdef + spd
    return math.floor(FC)
end

--info              宠物信息表
--physicalAtkTimes  物攻强化次数
--specialAtkTimes   特功强化次数
--@param talentValue 暴击伤害羁绊修正值
--@param science 科技加成数值
function BattleBasicValueCalc.calcDamageRate(info, physicalAtkTimes, specialAtkTimes , talentValue, science)--暴击倍率
    -- CSdamageRate = (物攻种族值+特功种族值+物攻强化次数*2+特功强化次数*2)*0.175+15 + 各功能附加值（目前还没有）
    local damageRate = 200 + talentValue
    -- return math.floor(damageRate)
    damageRate = damageRate + (science or 0)
    return PetEducationMgr.GetPreciseDecimal(damageRate, 2)
end

--@param talentValue 暴击率羁绊修正值
--@param science 科技加成数值
function BattleBasicValueCalc.calcCritical(talentValue, science)--暴击率
    -- Critical = 5 + 各功能附加值（目前还没有）
    local critical = 5 + talentValue
    -- return math.floor(critical)
    critical = critical + (science or 0)
    return PetEducationMgr.GetPreciseDecimal(critical, 2)
end

--info              宠物信息表
--speedTimes        速度强化次数
--@param talentValue 闪避率羁绊修正值
--@param skin 皮肤参数--读表计算值后传进来
--@param science 科技加成数值
function BattleBasicValueCalc.calcDodge(info, speedTimes, talentValue, skin, science)--闪避
    -- Dodge = (速度种族值+速度强化次数*2)/24 + 各功能附加值（目前还没有）
    local raceSPD = info.speedRateValue * (1 + skin/100)
    local Dodge = math.max(((raceSPD + speedTimes * 0.27) / 16 - 1) , 0 ) + talentValue
    -- return math.floor(Dodge)
    Dodge = (Dodge + (science or 0))/2
    return PetEducationMgr.GetPreciseDecimal(Dodge, 2)
end

--info              宠物信息表
--lifeTimes         生命强化次数
--specialDefTimes   魔防强化次数
--physicalDefTimes  物防强化次数
function BattleBasicValueCalc.calcTenacity(info, lifeTimes, specialDefTimes, physicalDefTimes)--韧性
    -- Tenacity = (生命种族值 + 特防种族值 + 物防种族值 + 生命强化次数*2 + 魔防强化次数*2 + 物防强化次数*2)/35 + 各功能附加值（目前还没有）
    --local Tenacity = (info.lifeRateValue + info.sdefRateValue + info.defRateValue + lifeTimes * 2 + specialDefTimes * 2 + physicalDefTimes * 2) / 35
    local Tenacity = 10
    return math.floor(Tenacity)
end

--physicalDR 物防
--level      宠物等级
--@param talentValue 物理减伤羁绊修正值
--@param science 科技加成数值
function BattleBasicValueCalc.calcPhysicalDamageReduction(physicalDR, level, talentValue, science)--物理减伤
    local val = physicalDR / (physicalDR + 500 + 30 * level) + talentValue
    -- return val
    val = val + (science or 0)/100
    return PetEducationMgr.GetPreciseDecimal(val, 2)
end

--MagicDR 魔防
--level   宠物等级
--@param talentValue 魔法减伤羁绊修正值
--@param science 科技加成数值
function BattleBasicValueCalc.calcMagicDamageReduction(MagicDR, level, talentValue, science)--魔法减伤
    local val = MagicDR / (MagicDR + 500 + 30 * level) + talentValue
    -- return val
    val = val + (science or 0)/100
    return PetEducationMgr.GetPreciseDecimal(val, 2)
end

--@param talentValue 命中率羁绊修正值
--@param science 科技加成数值
function BattleBasicValueCalc.calcHitRate(talentValue, science)--命中率
    local val = 95 + (talentValue or 0)
    -- return val
    val = val + (science or 0)
    return PetEducationMgr.GetPreciseDecimal(val, 2)
end

--@param talentValue 治疗比率羁绊修正值
--@param science 科技加成数值
function BattleBasicValueCalc.calchealRate(talentValue, science)--治疗修正比率
    local val = 1000 + (talentValue or 0)*10
    -- return val
    val = val + (science or 0)*10
    return PetEducationMgr.GetPreciseDecimal(val, 2)
end

--@param talentValue 物理减伤羁绊修正值
--@param science 科技加成数值
function BattleBasicValueCalc.calPDRexvalue(talentValue, science)--物理减伤羁绊修正值，以防以后有其他增加项，先这么写
    local val = (talentValue or 0)
    val = val + (science or 0)
    return PetEducationMgr.GetPreciseDecimal(val, 2)
end

--@param talentValue 魔法减伤羁绊修正值
--@param science 科技加成数值
function BattleBasicValueCalc.calMDRexvalue(talentValue, science)--魔法减伤羁绊修正值，以防以后有其他增加项，先这么写
    local val = (talentValue or 0)
    val = val + (science or 0)
    return PetEducationMgr.GetPreciseDecimal(val, 2)
end

--@param talentValue 暴击抵抗羁绊修正值
--@param science 科技加成数值
function BattleBasicValueCalc.calcResistance(talentValue, science)--暴击抵抗
    local val = (talentValue or 0)
    val = val + (science or 0)
    return PetEducationMgr.GetPreciseDecimal(val, 2)
end

--@param talentValue 物理穿透羁绊修正值
--@param science 科技加成数值
function BattleBasicValueCalc.calcPhysicalPenetration(talentValue, science)--物理穿透
    local val = (talentValue or 0)
    val = val + (science or 0)
    return PetEducationMgr.GetPreciseDecimal(val, 2)
end

--@param talentValue 魔法穿透羁绊修正值
--@param science 科技加成数值
function BattleBasicValueCalc.calcMagicPenetration(talentValue, science)--魔法穿透
    local val = (talentValue or 0)
    val = val + (science or 0)
    return PetEducationMgr.GetPreciseDecimal(val, 2)
end

return BattleBasicValueCalc