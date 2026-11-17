local shachong = {}
shachong.interval1 = 0
shachong.time1 = 0
shachong.warningTime1 = 2

shachong.interval2 = 0
shachong.time2 = 0
shachong.warningTime2 = 3
shachong.skilltab2 = {{25, 26, 27, 
                    31, 32, 33,
                    37, 38, 39,
                    43, 44, 45,
                    50, 51},
                    {37, 38, 39, 40, 41, 42,
                    43, 44, 45, 46, 47, 48,
                    50, 51, 52, 53, 54}}

shachong.interval3 = 0
shachong.time3 = 0

shachong.handle = nil

shachong.anim = {{name = "Gaf/bossEffect/kinfe.gaf",grid = 3}, {name = "Gaf/bossEffect/boom.gaf",grid = 6}, {name = "Gaf/bossEffect/laser.gaf"}}
shachong.motion = {"power", "attack"}

function shachong.AI()

    local function update(dt)  

        shachong.time1 = shachong.time1 + dt
        shachong.time2 = shachong.time2 + dt
        shachong.time3 = shachong.time3 + dt

        shachong.skill1()
        shachong.skill2()
        shachong.skill3()

    end

    shachong.interval1 = 0
    shachong.time1 = 0

    shachong.interval2 = 0
    shachong.time2 = 0

    shachong.interval3 = 0
    shachong.time3 = 0

    shachong.handle = require("framework.scheduler").scheduleUpdateGlobal(update)

end

function shachong.stop()

    require("framework.scheduler").unscheduleGlobal(shachong.handle)

end

function shachong.skill1()

    if shachong.interval1 == 0 then
        shachong.interval1 = GetRandom.random(3,7)
    end

    if shachong.time1 >= shachong.interval1 then
        shachong.time1 = 0
        shachong.interval1 = 0

        local tab = clone(BossMapMgr.getWalkableGridIndex())
        local tabRandom = {}
        if #tab > 10 then
            for i=1,10 do
                local index = GetRandom.random(1,#tab)
                local value = tab[index]
                table.insert(tabRandom, value)
                table.remove(tab, index)
            end
        else
            tabRandom = tab
        end

        local damage = 20

        local skill = {}
        skill.warningTime = shachong.warningTime1
        skill.tabRandom = tabRandom
        skill.damage = damage
        skill.anim = shachong.anim[1]
        skill.motion = shachong.motion[1]
        BossBattleMgr.addBossSkill(skill)
    end

end

function shachong.skill2()

    if shachong.interval2 == 0 then
        shachong.interval2 = GetRandom.random(20,30)
    end

    if shachong.time2 >= shachong.interval2 then
        shachong.time2 = 0
        shachong.interval2 = 0

        local index = GetRandom.random(1,2)
        local damage = 70

        local skill = {}
        skill.warningTime = shachong.warningTime2
        skill.tabRandom = clone(shachong.skilltab2[index])
        if not BossMapMgr.isPlayerOwnerInSecurityRegion(BossMapMgr.getPlayerOwnerBornGridIndex()) then
            table.insert(skill.tabRandom, BossMapMgr.getPlayerOwnerBornGridIndex()[1])
        end
        skill.damage = damage
        skill.anim = shachong.anim[2]
        skill.motion = shachong.motion[1]
        BossBattleMgr.addBossSkill(skill)
    end

end

function shachong.skill3()

    if shachong.interval3 == 0 then
        shachong.interval3 = GetRandom.random(1,3)
    end

    if shachong.time3 >= shachong.interval3 then
        shachong.time3 = 0
        shachong.interval3 = 0

        local index = GetRandom.random(1,100)
        if index > 90 then
            local damage = 5
            local skill = {}
            skill.normalAttack = damage
            skill.anim = shachong.anim[3]
            skill.motion = shachong.motion[2]
            BossBattleMgr.addBossSkill(skill)
        end
        
    end
    
end

return shachong