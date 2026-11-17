local iceGiant = {}
iceGiant.interval1 = 0
iceGiant.time1 = 0
iceGiant.warningTime1 = 2

iceGiant.interval2 = 0
iceGiant.time2 = 0
iceGiant.warningTime2 = 3
-- iceGiant.skilltab2 = {{25, 26, 27, 
--                     31, 32, 33,
--                     37, 38, 39,
--                     43, 44, 45,
--                     50, 51},
--                     {37, 38, 39, 40, 41, 42,
--                     43, 44, 45, 46, 47, 48,
--                     50, 51, 52, 53, 54}}
iceGiant.skilltab2 = {
                        { 
                            {25, 26, 27},
                            {31, 32, 33},
                            {37, 38, 39, 40, 41, 42},
                            {43, 44, 45, 46, 47, 48},
                            {49, 50, 51, 52, 53, 54}
                        },
                        {
                            {25, 31, 37, 43, 49},
                            {26, 32, 38, 44, 50},
                            {27, 33, 39, 45, 51},
                            {40, 46, 52},
                            {41, 47, 53},
                            {42, 48, 54}
                        }
                     }

iceGiant.interval3 = 0
iceGiant.time3 = 0

iceGiant.handle = nil

iceGiant.anim = {{name = "Gaf/skill/beaten/69.gaf",grid = 3,scale = 0.5,posX = 0,posY = 40}, 
				{name = "Gaf/skill/beaten/306.gaf",grid = 6,scale = 0.5,posX = 0,posY = 0}, 
				-- {name = "Gaf/bossEffect/laser.gaf"}
				{name = "Gaf/skill/spellCast/181.gaf",scale = 1.1,posX = -120,posY = 100}
				} 
iceGiant.motion = {"power", "attack","walk"} 

function iceGiant.AI()

    local function update(dt)  

        iceGiant.time1 = iceGiant.time1 + dt
        iceGiant.time2 = iceGiant.time2 + dt
        iceGiant.time3 = iceGiant.time3 + dt

        iceGiant.skill1()
        iceGiant.skill2()
        iceGiant.skill3()
    end

    iceGiant.interval1 = 0
    iceGiant.time1 = 0

    iceGiant.interval2 = 0
    iceGiant.time2 = 0

    iceGiant.interval3 = 0
    iceGiant.time3 = 0

    iceGiant.handle = require("framework.scheduler").scheduleUpdateGlobal(update)

end

function iceGiant.stop()
	require("framework.scheduler").unscheduleGlobal(iceGiant.handle)
end

function iceGiant.skill1()
	if iceGiant.interval1 == 0 then
        iceGiant.interval1 = GetRandom.random(3,7)
    end

    if iceGiant.time1 >= iceGiant.interval1 then
        iceGiant.time1 = 0
        iceGiant.interval1 = 0

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

        local damage = 30

        local skill = {}
        skill.warningTime = iceGiant.warningTime1
        skill.tabRandom = tabRandom
        skill.damage = damage
        skill.anim = iceGiant.anim[1]
        skill.motion = iceGiant.motion[2]
        BossBattleMgr.addBossSkill(skill)
    end

end

function iceGiant.skill2()
	if iceGiant.interval2 == 0 then
        iceGiant.interval2 = GetRandom.random(5,10)
    end

    if iceGiant.time2 >= iceGiant.interval2 then
        iceGiant.time2 = 0
        iceGiant.interval2 = 0

        local damage = 60
        local skill = {}
        skill.tabRandom   = {}
        skill.warningTime = iceGiant.warningTime2

        local tabs = clone(iceGiant.skilltab2)
        local isHurt = false
        for i = 1,2 do
            local selTab = GetRandom.random(1,#tabs[1])
            local tab = tabs[1][selTab]
            
            if tab[1] == 49  then
                -- table.insert(skill.tabRandom, BossMapMgr.getPlayerOwnerBornGridIndex()[1])
                table.remove(tab,1)
                isHurt = true
                print("isPlayerOwnerInSecurityRegion",BossMapMgr.isPlayerOwnerInSecurityRegion(BossMapMgr.getPlayerOwnerBornGridIndex()))
                if not BossMapMgr.isPlayerOwnerInSecurityRegion(BossMapMgr.getPlayerOwnerBornGridIndex()) then
                    table.insert(skill.tabRandom, BossMapMgr.getPlayerOwnerBornGridIndex()[1])
                end
            end
            for key,var in pairs(tab) do
                table.insert(skill.tabRandom,var)
            end
            table.remove(tabs[1],selTab)
        end

        for i = 1,3 do
            local selTab = GetRandom.random(1,#tabs[2])
            local tab = tabs[2][selTab]
            
            if tab[5] == 49 then
                -- table.insert(skill.tabRandom, BossMapMgr.getPlayerOwnerBornGridIndex()[1]) 
                table.remove(tab,5)
                if false == isHurt and
                    not BossMapMgr.isPlayerOwnerInSecurityRegion(BossMapMgr.getPlayerOwnerBornGridIndex()) then
                    table.insert(skill.tabRandom, BossMapMgr.getPlayerOwnerBornGridIndex()[1])
                end
            end
            for key,var in pairs(tab) do
                table.insert(skill.tabRandom,var)
            end
            table.remove(tabs[2],selTab)
        end

        skill.damage = damage
        skill.anim = iceGiant.anim[2]
        skill.motion = iceGiant.motion[2]
        BossBattleMgr.addBossSkill(skill)
    end

end

function iceGiant.skill3()
	if iceGiant.interval3 == 0 then
		iceGiant.interval3 = GetRandom.random(25,35)
	end

	if iceGiant.time3 >= iceGiant.interval3 then
		iceGiant.time3 = 0
        iceGiant.interval3 = 0 

        local lastTime    = 5
        local lastMaxTime = lastTime - 1
        local damage = 2
        
        for i = 1,lastTime do
        	local skill = {}
        	skill.normalAttack = damage
	        skill.anim     = iceGiant.anim[3]
	        skill.motion   = iceGiant.motion[3]
	        skill.lastTime = lastTime - i
	        skill.lastMaxTime = lastMaxTime
	        BossBattleMgr.addBossSkill(skill)
        end
        
	end

end

return iceGiant