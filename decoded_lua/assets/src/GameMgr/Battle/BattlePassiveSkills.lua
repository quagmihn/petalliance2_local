-- ROUND_START     = 0
-- ROUND_END       = 1
-- ROUND_BefATK    = 2
-- ROUND_AfterATK  = 3
-- ROUND_BefDEF    = 4
-- ROUND_AfterDEF  = 5
-- ROUND_APPEAR    = 6
-- ROUND_DISAPP    = 7
-- ROUND_DEAD      = 8

local BattlePassiveSkills   = {}

function BattlePassiveSkills.init(petType,passiveTbl)
    if type(passiveTbl) ~= "table" then
        printFileLog("passiveTbl 不是 数组")
        return false
    end
    BattlePassiveSkills[petType] = passiveTbl
end
 
function BattlePassiveSkills.healUI(detail)
    local addHp     = detail.addHp
    local addTottal = 0
    if detail.currHp + addHp >  detail.hpmax then
        addHp = detail.hpmax - detail.currHp          
    end 
    addTottal = detail.currHp + addHp        
    --BattleUIMgr.addFightLabel(detail.petType, detail.addHp,false,"add",false,"add")
    BattleUIMgr.addFightLabel({petType = detail.petType, value = detail.addHp, type = "addhp", iscritical = false})
    -- local per = addTottal*100/detail.hpmax

    -- local resBlood = BattleFuncMgr.checkBloodPic(per)
    -- local hpBar    = detail.hpBar

    -- display.addImageAsync(resBlood,function()
    --     hpBar:loadTexture(resBlood)
    --     hpBar:setPercent(per-0.1)
    --     hpBar:setPercent(per)
    -- end)
    BattleUIMgr.checkBloodbarAndBloodNum(detail.petType,addTottal)
    -- detail.hpStr:setString(addTottal.."/"..detail.hpmax) 

    -- TipsMgr.show(SceneMgr.getRunningScene, "触发  加血功能  "..addHp.."血") 
    
end

function BattlePassiveSkills.hurtUI(detail)
    local cutHp     = detail.cutHp
    local cutTottal = 0
    
    cutTottal = detail.currHp - cutHp 
    
    if cutTottal  <  0 then
        cutTottal = 0         
    end 

    -- BattleUIMgr.addFightLabel(detail.petType, detail.cutHp,false,"cut",false,"normal")
    BattleUIMgr.addFightLabel({petType = detail.petType, value = detail.cutHp, type = "normal", iscritical = false})
    -- local per = cutTottal*100/detail.hpmax

    -- local resBlood = BattleFuncMgr.checkBloodPic(per) 
    -- local hpBar    = detail.hpBar

    -- display.addImageAsync(resBlood,function()
    --     hpBar:loadTexture(resBlood)
    --     hpBar:setPercent(per-0.1)
    --     hpBar:setPercent(per)
    -- end) 
    BattleUIMgr.checkBloodbarAndBloodNum(detail.petType,cutTottal)
    -- detail.hpStr:setString(cutTottal.."/"..detail.hpmax)

    -- TipsMgr.show(SceneMgr.getRunningScene, "触发 减血功能  "..detail.cutHp.."血")
end


function addPetHP(detail)

end

return BattlePassiveSkills