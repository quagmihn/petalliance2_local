local BattleCANI 	= {}
BattleCANI.PETS 	= {}
BattleCANI.BALLS    = {}
BattleCANI.EFFECT   = {}
BattleCANI.energy   = nil
BattleCANI.anger    = nil
FOOD_PART = 1
BODY_PART = 2
HEAD_PART = 3

local playerPetParent = nil
local enemyPetParent  = nil
local playerPetPosX = 0
local playerPetPosY = 0
local enemyPetPosX = 0
local enemyPetPosY = 0
local cutInStageRes = {
    "attack_c.png",
    "attack_b.png",
    "attack_a.png",
    "attack_s.png",
    "attack_ss.png"
}

local BattleLangDB      = require("src.GameMgr.Battle.UI.BattleLangDB") 

function BattleCANI.init()
	BattleCANI.PETS    = {}
    BattleCANI.BALLS   = {}
    BattleCANI.EFFECT  = {}
    BattleCANI.oilSkillsFlip = {}
    playerPetParent     = nil
    enemyPetParent      = nil

    BattleCANI.getpetBody()
    -- if not BattleCANI.petbody then
    --     BattleCANI.petbody  = TxtReader.new("Config/petPart.txt")
    --     BattleCANI.petbody.init({"id","foodUD","foodLR","foodLR_B",
    --                     "partUD","partLR","partLR_B",
    --                     "headUD","headLR","headLR_B"}, 1
    --         ,{id=1,foodUD=1,foodUD_B=1,foodLR=1,foodLR_B=1,
    --         partUD=1,partUD_B=1,partLR=1,partLR_B=1,
    --         headUD=1,headUD_B=1,headLR=1,headLR_B=1}) 
    -- end
    BattleLangDB["fight"]   = LuaSqlite.getLanguageByKey("battleword9")    --出战
    BattleLangDB["help"]    = LuaSqlite.getLanguageByKey("battleword10")   --支援
    BattleLangDB["findPet"]     = LuaSqlite.getLanguageByKey("battleword11")   --发现野生精灵
    BattleLangDB["findPetSe"]   = LuaSqlite.getLanguageByKey("battleword12")   --发现稀有精灵
    BattleLangDB["restTimes"]   = LuaSqlite.getLanguageByKey("battleword13")   --剩余次数
    BattleLangDB["own"]         = LuaSqlite.getLanguageByKey("battleword14")   --已拥有
    BattleLangDB["fighting"]    = LuaSqlite.getLanguageByKey("battleword15")   --出战中
    BattleLangDB["rate"]        = LuaSqlite.getLanguageByKey("battleword16")   --几率
    BattleLangDB["wait"]        = LuaSqlite.getLanguageByKey("battleword18")        --等待中
    BattleLangDB["cancel"]      = LuaSqlite.getLanguageByKey("battleword19")        --取消
    BattleLangDB["autoClose"]   = LuaSqlite.getLanguageByKey("battleword20")        --自动战斗关闭
    BattleLangDB["autoOpen"]    = LuaSqlite.getLanguageByKey("battleword21")        --自动战斗开启
    BattleLangDB["noManu"]      = LuaSqlite.getLanguageByKey("battleword22")        --当前不能手动战斗
    BattleLangDB["noenough"]    = LuaSqlite.getLanguageByKey("battleword23")        --球 数量不够
    BattleLangDB["timeLimit"]   = LuaSqlite.getLanguageByKey("battleword24")        --捉宠次数已达上限，不能捉
    BattleLangDB["replay"]      = LuaSqlite.getLanguageByKey("arena59")        --回放
    BattleLangDB["quit"]        = LuaSqlite.getLanguageByKey("arena60")        --退出
end

function BattleCANI.getpetBody()
    if not BattleCANI.petbody then
        BattleCANI.petbody  = TxtReader.new("Config/petPart.txt")
        BattleCANI.petbody.init({"id","foodUD_B","foodUD","foodLR","foodLR_B",
                        "partUD_B","partUD","partLR","partLR_B",
                        "headUD_B","headUD","headLR","headLR_B"}, 1
            ,{id=1,foodUD=1,foodUD_B=1,foodLR=1,foodLR_B=1,
            partUD=1,partUD_B=1,partLR=1,partLR_B=1,
            headUD=1,headUD_B=1,headLR=1,headLR_B=1}) 
    end
end

function BattleCANI.getPartPos(petType,partType,partInfo)
    local partPosX = 0
    local partPosY = 0
    local rate     = 1.0
    if partType == FOOD_PART then
        if petType == 0 then 
            partPosX = partInfo.foodLR_B
            partPosY = partInfo.foodUD_B
        else
            rate = 0.8
            partPosX = partInfo.foodLR 
            partPosY = partInfo.foodUD*rate
        end
    elseif partType == BODY_PART then
        if petType == 0 then
            partPosX = partInfo.partLR_B 
            partPosY = partInfo.partUD_B*rate
        else
            rate = 0.8
            partPosX = partInfo.partLR*rate    
            partPosY = partInfo.partUD*rate   
        end
        
    elseif partType == HEAD_PART then
        if petType == 0 then
            partPosX = partInfo.headLR_B
            partPosY = partInfo.headUD_B*rate 
        else
            rate = 0.8 
            partPosX = partInfo.headLR  
            partPosY = partInfo.headUD*rate  
        end
        
    else
        if petType == 0 then
            partPosX = partInfo.foodLR_B
            partPosY = partInfo.foodUD_B
        else
            rate = 0.8 
            partPosX = partInfo.foodLR   
            partPosY = partInfo.foodUD*rate  
        end
        
    end
    -- print("======位置偏移："..partType.."("..partPosX..","..partPosY..")")
    return partPosX,partPosY

end

------------------创建宠物spine---------------------------------
function BattleCANI.createPets(parent,petInfo)
    BattleCANI.PETS.enemyPosX = 0
    BattleCANI.PETS.enemyPosY = 0
    BattleCANI.PETS.playerPosX = 0
    BattleCANI.PETS.playerPosY = 0

    BattleCANI.PETS.PET_SIZE_A = 0.8
    BattleCANI.PETS.PET_SIZE_B = 1.0
    
	BattleCANI.PETS.petTable        = {}
    BattleCANI.PETS.skillAnis       = {}
    BattleCANI.PETS.skillAnis[0]    = {}
    BattleCANI.PETS.skillAnis[1]    = {}
    BattleCANI.PETS.petAnis         = {}
    BattleCANI.PETS.petAnis[0]      = {}
    BattleCANI.PETS.petAnis[1]      = {}
    BattleCANI.PETS.focusAnis       = {}
    BattleCANI.PETS.focusAnis[0]    = {}
    BattleCANI.PETS.focusAnis[1]    = {}

    local phoneSize     = cc.Director:getInstance():getOpenGLView():getViewPortRect() 

    local width_make    = DEFAULT_GAME_SCREEN_WIDTH
    local height_make   = DEFAULT_GAME_SCREEN_HEIGHT
    local rate          = 1
    
    local scrR = phoneSize.height/phoneSize.width
    local defR = height_make/width_make

    if scrR<defR then
        rate = phoneSize.height*width_make/height_make/phoneSize.width
    end

    BattleCANI.PETS.playerPosX = 150 
    BattleCANI.PETS.playerPosY = rate * 364  - 15

    BattleCANI.PETS.enemyPosX = DEFAULT_GAME_SCREEN_WIDTH - 150
    BattleCANI.PETS.enemyPosY = display.height - 350 - 15
 
    local testTable = {} 
    testTable[tostring(petInfo[1]["pokeID"])] = 1
    
    for key,var in pairs(petInfo[HISPETS][OUTPETS]) do
        if testTable[tostring(var.pokeID)] then
            testTable[tostring(var.pokeID)] = testTable[tostring(var.pokeID)] + 1
        else
            testTable[tostring(var.pokeID)] = 1
        end 
        local pet = AnimationMgr.createAni(parent, var["res"],
            BattleCANI.PETS.enemyPosX,BattleCANI.PETS.enemyPosY, "EnemyPet"..key)
        AnimationMgr.setSkin(var["res"], var.skin, "EnemyPet"..key)
        pet:setScale(0,0)
        pet:zorder(2)
        BattleCANI.PETS.petAnis[1][key] = {pet,"EnemyPet"..key}
    end

    BattleCANI.PETS.petTable[1] = {BattleCANI.PETS.petAnis[HISPETS][1][1],petInfo[HISPETS][OUTPETS][1]["res"],"EnemyPet1",-1}
    AnimationMgr.playAni(petInfo[HISPETS][OUTPETS][1]["res"], "idle", true, "EnemyPet1")

    local enemypets     = {}
    enemypets["pokeID"] = {}
    enemypets["num"]    = {}

    for key,var in pairs(testTable) do
        table.insert(enemypets["pokeID"], tonumber(key))
        table.insert(enemypets["num"], var)
    end
    
    testTable   = {} 
    testTable[tostring(petInfo[0]["pokeID"])] = 1

    for key,var in pairs(petInfo[MYPETS][OUTPETS]) do
        if testTable[tostring(var.pokeID)] ~= nil then
            testTable[tostring(var.pokeID)] = testTable[tostring(var.pokeID)] +1
        else
            testTable[tostring(var.pokeID)] = 1
        end 
        local pet = AnimationMgr.createAni(parent, var["res"],
            BattleCANI.PETS.playerPosX,BattleCANI.PETS.playerPosY, "playerPet"..key)
        AnimationMgr.setSkin(var["res"], var.skin, "playerPet"..key)
        pet:setScale(0,0)
        pet:zorder(4)
        BattleCANI.PETS.petAnis[MYPETS][key] = {pet,"playerPet"..key}
    end

    BattleCANI.PETS.petTable[MYPETS] = {BattleCANI.PETS.petAnis[MYPETS][1][1],petInfo[MYPETS][OUTPETS][1]["res"],"playerPet1",1}
    AnimationMgr.playAni(petInfo[MYPETS][OUTPETS][1]["res"], "idle", true, "playerPet1")
    local playerPets    = {}
    playerPets["pokeID"] = {}
    playerPets["num"]    = {} 

    for key,var in pairs(testTable) do 
        table.insert(playerPets["pokeID"], tonumber(key))
        table.insert(playerPets["num"], var)
    end
    return playerPets,enemypets
end 

----------创建入场球----------------------
function BattleCANI.createPetBalls(parent)
    BattleCANI.BALLS.enterBall = {}
    BattleCANI.BALLS.enterBall[0] = AnimationMgr.createBattlePetAni(parent, "Gaf/ball/ruchang.gaf",
            0,0, "Ball0")
    BattleCANI.BALLS.enterBall[1] = AnimationMgr.createBattlePetAni(parent, "Gaf/ball/ruchang.gaf",
            0,0, "Ball1")
    BattleCANI.BALLS.enterBall[0]:hide()
    BattleCANI.BALLS.enterBall[1]:hide()
       
    -- BattleCANI.BALLS.enterBall[0]:setGLBlend(gl.SRC_ALPHA,gl.ONE)
    -- BattleCANI.BALLS.enterBall[1]:setGLBlend(gl.SRC_ALPHA,gl.ONE)
end

---------创建奥义集中特效----------------
function BattleCANI.createFocusAni(petType,parent,petInfo)
    local PosX = BattleCANI.PETS.playerPosX
    local PosY = BattleCANI.PETS.playerPosY + 80
    if petType == 1 then
        PosX = BattleCANI.PETS.enemyPosX
        PosY = BattleCANI.PETS.enemyPosY + 80
    end
    BattleCANI.PETS.focusAnis[petType] = {}
    local focusID = petInfo["skill"][4].info.skillAtt
    local focusFronRes = "Gaf/skill/proSkill/"..focusID.."_front.gaf"
    local focusBackRes = "Gaf/skill/proSkill/"..focusID.."_back.gaf"
    local focusFrontAni = nil
    if not BattleFuncMgr.isFileExist(focusFronRes) then
        focusFronRes = "Gaf/skill/proSkill/10_front.gaf"
    end
    display.addImageAsync(string.gsub(focusFronRes,"gaf","png"),function()
        focusFrontAni = BattleFuncMgr.createGafAni(focusFronRes,parent,0.5,-0.5,PosX,PosY)
        focusFrontAni:setLocalZOrder(5)
        BattleFuncMgr.playGafAniWithSequenceAndCallBack(focusFrontAni,"EVENT_FOCUS",true)
        table.insert(BattleCANI.PETS.focusAnis[petType],focusFrontAni)
    end)

    if  BattleFuncMgr.isFileExist(focusBackRes) then
        display.addImageAsync(string.gsub(focusBackRes,"gaf","png"),function()
            local focusBackAni = BattleFuncMgr.createGafAni(focusBackRes,parent,0.5,-0.5,PosX,PosY)
            focusBackAni:setLocalZOrder(1)
            BattleFuncMgr.playGafAniWithSequenceAndCallBack(focusBackAni,"EVENT_FOCUS",true)
            table.insert(BattleCANI.PETS.focusAnis[petType],focusBackAni)
        end)
    else
        print("focusBackAni == nil  "..petType)
    end

end

---------------清除奥义集中特效----------------
function BattleCANI.cleanFocus(petType)
    if BattleCANI.PETS.focusAnis[petType] ~= nil then
        for key,var in pairs(BattleCANI.PETS.focusAnis[petType]) do
            var:removeAllChildrenWithCleanup(true)
            var:removeFromParent(true)
        end
        BattleCANI.PETS.focusAnis[petType] = nil
    end
end

------------创建迷雾------------------------
function BattleCANI.createFogEffect(parent,posX,posY,posXX,posYY)
    local res   = "Gaf/effect/fog.gaf"
    local png   = "Gaf/effect/fog.png"
    display.addImageAsync(png,function()
            BattleCANI.fog_1 =  BattleFuncMgr.createGafAni(res,parent,0.5,-0.5,
                    posX,posY)
            BattleCANI.fog_2 = BattleFuncMgr.createGafAni(res,parent,0.5,-0.5,
                    posXX,posYY)

            BattleCANI.fog_1:zorder(6.5)
            BattleCANI.fog_1:gotoAndPlay(0)
            BattleCANI.fog_1:start()
            BattleCANI.fog_1:setLooped(true) 

            BattleCANI.fog_2:zorder(2)
            BattleCANI.fog_2:gotoAndPlay(0)
            BattleCANI.fog_2:start()
            BattleCANI.fog_2:setLooped(true) 
            BattleCANI.fog_2:setScale(-1,1)
        end)
    
end

function BattleCANI.createChaosEffect(team,pokeID,callback)
    local bodyPart   = BattleCANI.petbody.get(pokeID).partUD
    local posX       = BattleCANI.PETS.playerPosX
    local posY       = BattleCANI.PETS.playerPosY + bodyPart

    if team == 1 then
        posX = BattleCANI.PETS.enemyPosX
        posY = BattleCANI.PETS.enemyPosY + bodyPart
    end

    display.addImageAsync("Gaf/skill/beaten/666.png",function()
        local gaf = BattleFuncMgr.createGafAni("Gaf/skill/beaten/666.gaf",
            SceneMgr.getRunningScene,0.5,-0.5,posX,posY)
        local fps = 24*BattleUIMgr.speed
        gaf:setFps(fps)
        gaf:zorder(5)
        gaf:gotoAndPlay(0)
        gaf:start()
        local time = (1.00/fps)*(18+1)
        SceneMgr.getRunningScene:performWithDelay(function()
                if callback then
                    callback()
                end
                gaf:removeFromParent()
            end, time)
    end) 
end

---------------创建宠物技能--------------------
function BattleCANI.createPetSkill(petType,skillType,petInfo,parent,isMove,callback)
    local movePos     = 0
    local hisType     = 0

    -- if isMove then
        if petType == 1 then
            movePos = -30
            hisType = 0
        else
            movePos = 30
            hisType = 1
        end
    -- end

    local mybody    = BattleCANI.petbody.get(petInfo[petType]["pokeID"])
    local hisbody   = BattleCANI.petbody.get(petInfo[hisType]["pokeID"])

    local skillInfo = petInfo[petType]["skill"][skillType]
    local skillID = tostring(skillInfo.id)
    local tbl = {}
    local gapRelease = 50
    -- local gapY = BattleCCSB.UPBLOOD.layer:getPositionY() - BattleCCSB.DOWNBLOOD.layer:getPositionY() 

    local myBodyPosX,myBodyPosY     =  BattleCANI.getPartPos(petType,skillInfo.partA,mybody)
    local hisBodyPosX,hisBodyPosY   =  BattleCANI.getPartPos(hisType,skillInfo.partB,hisbody)
     

    local myPosX    = BattleCANI.PETS.enemyPosX  + skillInfo.ALR - myBodyPosX
    local myPosY    = BattleCANI.PETS.enemyPosY  + skillInfo.Aupdown + myBodyPosY
    local hisPosX   = BattleCANI.PETS.playerPosX + skillInfo.triX + hisBodyPosX
    local hisPosY   = BattleCANI.PETS.playerPosY + skillInfo.triY + hisBodyPosY
    local orderZ    = 6
    local skillIndex   = 0


    if petType == 0 then 
        gapRelease = 0
        myPosX    = BattleCANI.PETS.playerPosX + skillInfo.BLR + myBodyPosX
        myPosY    = BattleCANI.PETS.playerPosY + skillInfo.Bupdown + myBodyPosY
        hisPosX   = BattleCANI.PETS.enemyPosX + skillInfo.triX - hisBodyPosX
        hisPosY   = BattleCANI.PETS.enemyPosY + skillInfo.triY + hisBodyPosY

    end
    if not skillInfo.scale then
        skillInfo.scale = 1.3
    end
 --    print("====我的技能BattleCANI.PETS位置：（"..BattleCANI.PETS.playerPosX..","..BattleCANI.PETS.playerPosY..")")
 --    print("====敌人的技能BattleCANI.PETS位置：（"..BattleCANI.PETS.enemyPosX..","..BattleCANI.PETS.enemyPosY..")")
	-- print("====我的技能movePos位置：（"..movePos..")")
	-- print("====我的技能skillInfo位置：（"..skillInfo.BLR..","..skillInfo.Bupdown..")")
 --    print("====我的技能位置：（"..myPosX..","..myPosY..")")
    if skillInfo["res1"] ~= "" then
        skillIndex = skillIndex + 1
        local res1Index = skillIndex
        display.addImageAsync(string.gsub(skillInfo["res1"],"gaf","png"), function()
            
            local   ani1,aniWidth,aniHeight = BattleFuncMgr.createGafAni(skillInfo["res1"],parent,0.5,-0.5,myPosX,myPosY)
            ani1:zorder(orderZ)
            local anchorY = aniHeight/ani1:getContentSize().height
            ani1:setAnchorPoint(0.5,-1*anchorY) 
            ani1:setScale(skillInfo.scale,skillInfo.scale)
            -- table.insert(tbl,{ani1,skillInfo["res1"]})

            tbl[res1Index] = {ani1,skillInfo["res1"]}

            BattleCANI.PETS.skillAnis[petType][skillID] = tbl

            if res1Index == 1 then
                callback()
            end
            
        end)
    end 

    if skillInfo["res2"] ~= "" then
        skillIndex = skillIndex + 1
        local res2Index = skillIndex
 
        display.addImageAsync(string.gsub(skillInfo["res2"],"gaf","png"), function()

            local  ani2,aniWidth = BattleFuncMgr.createGafAni(skillInfo["res2"],parent,0,-0.5,myPosX,myPosY)
            orderZ = 6
            if petType == 0 then
                orderZ = 3
            end
            ani2:zorder(orderZ) 

            local ani2GapX = math.abs(hisPosX - myPosX)
            local ani2GapY = math.abs(hisPosY - myPosY)
            local orgTan = ani2GapY/ani2GapX
            local circle = math.deg(math.atan(orgTan))  
            local chageLen = math.sqrt(math.pow(ani2GapX,2) + math.pow(ani2GapY,2))
            local ancle = 0 
            local rate = 1
            if petType == 1 then 
                ancle = 180
                rate = -1
            end
            ani2:setScale(chageLen/aniWidth,rate*skillInfo.scale) 
            
            ani2:rotation(-1*circle+ancle)
            -- table.insert(tbl,{ani2,skillInfo["res2"]})
            tbl[res2Index] = {ani2,skillInfo["res2"]}

            BattleCANI.PETS.skillAnis[petType][skillID] = tbl

            if res2Index == 1 then
                callback()
            end
        end)
    end

    if skillInfo["res3"]~= "" then
        skillIndex = skillIndex + 1
        local res3Index = skillIndex

        display.addImageAsync(string.gsub(skillInfo["res3"],"gaf","png"), function()
            local  ani2,aniWidth = BattleFuncMgr.createGafAni(skillInfo["res3"],parent,0,-0.5,myPosX,myPosY)
            orderZ = 6
            ani2:zorder(orderZ)
            local ani2GapX = math.abs(hisPosX - myPosX)
            local ani2GapY = math.abs(hisPosY - myPosY)
            local orgTan = ani2GapY/ani2GapX
            local circle = math.deg(math.atan(orgTan))
            local chageLen = math.sqrt(math.pow(ani2GapX,2) + math.pow(ani2GapY,2))
            local ancle = 0
            local rate = 1

            if petType == 1 then
                ancle = 180
                rate = -1
            end

            ani2:setScale(chageLen/aniWidth,rate*skillInfo.scale)  

            ani2:rotation(-1*circle+ancle)
            -- table.insert(tbl,{ani2,skillInfo["res3"]})
            tbl[res3Index] = {ani2,skillInfo["res3"]}

            BattleCANI.PETS.skillAnis[petType][skillID] = tbl

            if res3Index == 1 then
                callback()
            end
        end)
    end

    if skillInfo["res"]~= "" then 
        if petType == 0 then 
            hisPosX   = hisPosX + skillInfo.BLR
            hisPosY   = hisPosY + skillInfo.Bupdown
        else
            hisPosX   = hisPosX + skillInfo.ALR
            hisPosY   = hisPosY + skillInfo.Aupdown
        end
        skillIndex = skillIndex + 1
        local resIndex = skillIndex
        display.addImageAsync(string.gsub(skillInfo["res"],"gaf","png"), function() 
            orderZ = 6
            local   ani,aniWidth,aniHeight = BattleFuncMgr.createGafAni(skillInfo["res"],parent,0.5,-1.0,hisPosX,hisPosY)
            ani:zorder(orderZ)
            local anchorY = aniHeight/ani:getContentSize().height
            ani:setAnchorPoint(0.5,-1*anchorY)

            ani:setScale(skillInfo.scale,skillInfo.scale) 
            -- table.insert(tbl,{ani,skillInfo["res"]}) 
            tbl[resIndex] = {ani,skillInfo["res"]}

            BattleCANI.PETS.skillAnis[petType][skillID] = tbl
            if resIndex == 1 then
                callback()
            end
        end)
    end
    
end



------------创建技能触发特效--------------
function BattleCANI.createSKillLight(parent,posX,posY)
    local res = "Spine/effects/Ui_xiaojinengtishi.png"
    if  BattleCANI.skillLight then
        BattleCANI.skillLight:removeFromParent()
        BattleCANI.skillLight = nil
    end 
    -- display.addImageAsync(res,function()
        BattleCANI.skillLight = AnimationMgr.createAni(parent,res,
            posX,posY)
        BattleCANI.skillLight:zorder(5)
        AnimationMgr.playAni(res, "animation", true)
    -- end) 
    BattleCANI.skillLight:setScale(0.85,0.85)  
    BattleCANI.skillLight:zorder(1)
    GameAudio.playBattleSound("skillClick")
        
end

function BattleCANI.createSkillRelease(parent,posX,posY)

    local res = "Spine/effects/Ui_jinengtubiaodianji.png"
    
    -- display.addImageAsync(res,function()
        local spi = AnimationMgr.createAni(parent,res,
            posX,posY)
        spi:zorder(5)
        AnimationMgr.playAniWithCallback(res, "animation", nil, "", true) 
    -- end) 
    -- spi:setScale(0.85,0.85)
    spi:zorder(9) 

end

function BattleCANI.killPetCardHead(parent,posX,posY,callback)
    local res = "Spine/effects/Ui_zhandoujiesuanshouji.png"

    local spi = AnimationMgr.createAni(parent,res,
            posX,posY)
    spi:setScale(1.3,1.3) 
    AnimationMgr.playAniWithCallback(res, "animation", function()
            if callback then
                callback()
            end
        end, "", true)  

    spi:zorder(9) 
end

---@param effectType 0 为蓝  1为红
function BattleCANI.doubleKillEffect(parent,posX,posY,effectType)
    local res = "Spine/effects/Ui_zhandoujiesuanlan.png"
    if effectType == 1 then
        res = "Spine/effects/Ui_zhandoujiesuanhong.png"
    end  
    local spi = AnimationMgr.createAni(parent,res,
            posX,posY)
    
    AnimationMgr.playAni(res, "animation", true)
    spi:zorder(-1) 
end

function BattleCANI.bossAppear(callback)

    display.addImageAsync("Gaf/effect/BOSSappear.png",function() 
        local ani = BattleFuncMgr.createGafAni("Gaf/effect/BOSSappear.gaf",
            SceneMgr.getRunningScene,0.5,-0.5,display.cx,display.cy+300)
        ani:zorder(10)
        ani:setScale(2.0,2.0)  
        BattleFuncMgr.bossVibrationScene(SceneMgr.getRunningScene,function()
                if BattleCCSB.MENU.isOut then
                    return
                end
                BattleFuncMgr.bossVibrationScene(SceneMgr.getRunningScene,function()
                    if BattleCCSB.MENU.isOut then
                        return
                    end
                    BattleFuncMgr.bossVibrationScene(SceneMgr.getRunningScene,function()
                    end) 
                end)
            end)
        BattleFuncMgr.playGafAniWithSequenceAndCallBack(ani,"Play",false,callback,true) 
    end)

end

function BattleCANI.bossBroundBack(callback)
    display.addImageAsync("Gaf/effect/BOSSGK.png",function() 
        if BattleCCSB.MENU.isOut then
            return
        end
        local ani = BattleFuncMgr.createGafAni("Gaf/effect/BOSSGK.gaf",
            SceneMgr.getRunningScene,0.5,-0.5,display.cx,display.cy)
        ani:zorder(11)

        BattleFuncMgr.playGafAniWithSequenceAndCallBack(ani,"Play",false,function()
                BattleFuncMgr.playGafAniWithSequenceAndCallBack(ani,"Play",false,function()
                        BattleFuncMgr.playGafAniWithSequenceAndCallBack(ani,"Play",false,function()
                            if callback then
                                callback()
                            end
                        end,true) 
                    end) 
            end) 
    end)
end

function BattleCANI.skillIconFlip(skillIndex,isUse) 
    if not isUse then
        BattleCCSB.DOWNEDGE.clickEffect[skillIndex]:hide()
        if not BattleCANI.oilSkillsFlip[skillIndex] then
            display.addImageAsync("Gaf/effect/flipSkill.png",function() 
--                    BattleCCSB.DOWNEDGE.oilSkillBg[skillIndex]:show()
                    BattleCANI.oilSkillsFlip[skillIndex] = BattleFuncMgr.createGafAni("Gaf/effect/flipSkill.gaf",
                        BattleCCSB.DOWNEDGE.oilSkillBg[skillIndex],0.5,-0.5,60,62) 
                        BattleCANI.oilSkillsFlip[skillIndex]:setFps(18) 
                    BattleFuncMgr.playGafAniWithSequenceAndCallBack(BattleCANI.oilSkillsFlip[skillIndex],
                        "showBack",false,function()
                                 
                            end)
                end) 
        end
    else   
        if BattleCANI.oilSkillsFlip[skillIndex] then
            BattleFuncMgr.playGafAniWithSequenceAndCallBack(BattleCANI.oilSkillsFlip[skillIndex],
                "showFront",false,function()
                        if BattleUIMgr.getPetInfo(0).skill[skillIndex] ~= 0 then
                            BattleCCSB.DOWNEDGE.clickEffect[skillIndex]:show()
                            BattleCCSB.DOWNEDGE.clickEffect[skillIndex]:setScale(0.92,0.92)
                            BattleCCSB.DOWNEDGE.clickEffect[skillIndex]:scaleTo(0.1, 1.0)
                        end
                        BattleFuncMgr.playGafAniWithSequenceAndCallBack(BattleCANI.oilSkillsFlip[skillIndex],
                            "blink",false,function()
                                    if BattleCANI.oilSkillsFlip[skillIndex] then
                                        BattleCANI.oilSkillsFlip[skillIndex]:removeFromParent()
                                        BattleCANI.oilSkillsFlip[skillIndex] = nil
                                    end
                                end)   
                    end)
        end
    end
end

------------创建消耗油技能 触发宠物身上的特效--------------
function BattleCANI.createOilSkillEffect(parent,pokeID)
    -- local PosX = BattleCANI.PETS.playerPosX - 20
    -- local PosY = BattleCANI.PETS.playerPosY + 60
    -- if petType == 1 then
    --     PosX = BattleCANI.PETS.enemyPosX -20
    --     PosY = BattleCANI.PETS.enemyPosY + 60
    -- end
    local posY = BattleCANI.petbody.get(pokeID).partUD_B
    display.addImageAsync("Gaf/effect/oilSkill.png",function()
            local gaf = BattleFuncMgr.createGafAni("Gaf/effect/oilSkill.gaf",parent,0.5,-0.5,
                -20,posY)
            -- gaf:zorder(5)
            BattleFuncMgr.playGafAniWithSequenceAndCallBack(gaf,"EVENT_CAST",false,function()
                    if BattleUIMgr.isJumpBattle or BattleCCSB.MENU.isOut then
                        return
                    end  
                    gaf:removeFromParent() 
                end)
        end)
    
end

------------创建cutin.gaf--------------
function BattleCANI.createCutIn(parent,icon,skin,stage,callback)
    if not skin then
        skin = 0
    end
    local petRes = "Battle/cutIn/poke"..icon.."_"..skin..".png"
    if not BattleFuncMgr.isFileExist(petRes) then
        petRes = "empty.png" 
    end

    display.addImageAsync(petRes,function() 
            display.addImageAsync("Gaf/effect/cutin.png",function() 
                GameAudio.playBattleSound("skillCard")
                local gaf = BattleFuncMgr.createGafAni("Gaf/effect/cutin.gaf",parent,0.5,-0.5,
                    360,600)
                
                local attackRes = CocosModuleMgr.getWordImage(cutInStageRes[stage])

                if attackRes then
                    gaf:replaceTextureByKey("attack", attackRes)
                end

                gaf:zorder(9) 
                gaf:replaceTextureByKey("head", petRes)   
                gaf:replaceTextureByKey("head1", petRes)  
                gaf:replaceTextureByKey("head2", petRes) 
                gaf:replaceTextureByKey("head3", petRes)
                
                
                BattleFuncMgr.playGafAniWithSequenceAndCallBack(gaf,"play",false,function()
                        if callback then
                            callback()
                        end
                        gaf:removeFromParent() 
                    end)
            end)
        end)
    
end

------------创建消耗油技能 触发宠物身上的特效--------------
function BattleCANI.createSkillEffect(parent)
    local res   = "Spine/effects/Ui_jinengshifatishi.png"
    local parentSize = parent:getContentSize() 
    local spine =  AnimationMgr.createAni(parent, res, parentSize.width/2, parentSize.height/2)
    spine:zorder(3)

    AnimationMgr.playAniWithSpCallback(res, "animation",nil, nil, nil, true) 
    
end

---------------创建AOYI触发特效-----------
function BattleCANI.createAoyiEffect(parent,posX,posY) 
    local resB = "Spine/effects/Ui_zhandoujiemianhuoyan_beimian.png"
    local resZ = "Spine/effects/Ui_zhandoujiemianhuoyan_zhengmian.png"
    if  BattleCANI.aoyiEffectZ then
        BattleCANI.aoyiEffectZ:removeFromParent()
        BattleCANI.aoyiEffectZ = nil
        BattleCANI.aoyiEffectB:removeFromParent()
        BattleCANI.aoyiEffectB = nil
    end 

    BattleCANI.aoyiEffectZ = AnimationMgr.createAni(parent,resZ, 
        posX,posY)
    BattleCANI.aoyiEffectZ:zorder(2)
    AnimationMgr.playAni(resZ, "animation", true)   

    BattleCANI.aoyiEffectB = AnimationMgr.createAni(parent,resB,
        posX,posY)
    BattleCANI.aoyiEffectB:zorder(0)
    AnimationMgr.playAni(resB, "animation", true)   

end

---------------创建受击特效-----------
function BattleCANI.createBeatenGafs(petType,pokeID,parent,skillAtt) 
    local posX    = BattleCANI.PETS.enemyPosX - BattleCANI.petbody.get(pokeID).partLR + 30
    local posY    = BattleCANI.PETS.enemyPosY + BattleCANI.petbody.get(pokeID).partUD
    if petType == 0 then
        posX = BattleCANI.PETS.playerPosX + BattleCANI.petbody.get(pokeID).partLR_B + 15
        posY = BattleCANI.PETS.playerPosY + BattleCANI.petbody.get(pokeID).partUD_B
    end
    -- if BattleCANI.beatAni then
    --     BattleCANI.beatAni:removeFromParent()
    -- end

    -- BattleCANI.beatAni = CSResourceMgr.createCCBI(parent, 
    --                 "texture/ui_dc_23.ccbi", posX, posY)
    -- BattleCANI.beatAni:zorder(5) 
    -- BattleCANI.beatAni:setScale(1.5,1.5)
    
    local res = "Gaf/skill/comBeaten/"..skillAtt..".gaf"
    
    -- if BattleFuncMgr.isFileExist(res) then
        display.addImageAsync(string.gsub(res,"gaf","png"),function()
            if BattleCANI.beatAni then
                BattleCANI.beatAni:show() 
                BattleCANI.beatAni:setPosition(posX,posY)
                BattleFuncMgr.playGafAniWithSequenceAndCallBack(BattleCANI.beatAni,"EVENT_PLAY",false,
                    function() 
                        BattleCANI.beatAni:hide()
                    end)
                return
            end  
            if not BattleUIMgr.showSkillTip or BattleCCSB.MENU.isOut then
                return
            end
            BattleCANI.beatAni = BattleFuncMgr.createGafAni(res,parent,0.5,-0.5,posX,posY)
            BattleCANI.beatAni:zorder(5)
            BattleCANI.beatAni:setScale(1.5,1.5)
            BattleFuncMgr.playGafAniWithSequenceAndCallBack(BattleCANI.beatAni,"EVENT_PLAY",false,
            function() 
                BattleCANI.beatAni:hide()
            end)
            audio.playSound(BattleFuncMgr.getBattleSounds()["beat"],false)
        end)
    -- end      

end

function BattleCANI.cleanANI()

    if BattleCANI.energy then
        BattleCANI.energy:removeFromParent()
        BattleCANI.energy = nil
    end
    
    if BattleCANI.fog_1 then
        BattleCANI.fog_1:removeFromParent()
        BattleCANI.fog_1 = nil
    end

    if BattleCANI.fog_2 then
        BattleCANI.fog_2:removeFromParent()
        BattleCANI.fog_2 = nil
    end

    if BattleCANI.anger then
        BattleCANI.anger:removeFromParent()
        BattleCANI.anger = nil
    end

    if  BattleCANI.skillLight then
        BattleCANI.skillLight:removeFromParent()
        BattleCANI.skillLight = nil
    end 

    if  BattleCANI.aoyiEffectZ then
        BattleCANI.aoyiEffectZ:removeFromParent()
        BattleCANI.aoyiEffectZ = nil
        BattleCANI.aoyiEffectB:removeFromParent()
        BattleCANI.aoyiEffectB = nil
    end 

    for skillIndex = 2, 3 do
        if BattleCANI.oilSkillsFlip[skillIndex] then
            BattleCANI.oilSkillsFlip[skillIndex]:removeFromParent()
            BattleCANI.oilSkillsFlip[skillIndex] = nil
        end
    end

    for petType = 0,1 do
        for key,var in pairs(BattleCANI.PETS.petAnis[petType]) do
            var[1]:removeFromParent()
        end
         
        for key,var in pairs(BattleCANI.PETS.skillAnis[petType]) do
            if var ~= nil then
                for k,v in pairs(var) do
                    v[1]:removeFromParent()
                end
            end
        end
    end

    BattleCANI.PETS.petAnis[0] = {}
    BattleCANI.PETS.petAnis[1] = {}
    BattleCANI.PETS.skillAnis[0] = {}
    BattleCANI.PETS.skillAnis[1] = {}
end

return BattleCANI