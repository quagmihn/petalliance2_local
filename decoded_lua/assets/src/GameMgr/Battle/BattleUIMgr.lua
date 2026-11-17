require("src.GameMgr.Battle.type_damage")
BAR_LIMIT_TIME  = 0.5
PLAYER_WIN      = 1
PLAYER_LOSE     = 0
PLAYER_EQUAL    = 2
BATTLE_ONE_TIMES_SPEED = 1.4
BATTLE_TWO_TIMES_SPEED = 1.7
BATTLE_BALL_OUT_SPEED  = 0.6
PET_ANIMATION_SPEED    = 1.7

local CCSUILoader   	= require("src.framework.cc.uiloader.CCSUILoader")
local BattleWeather     = require("src.GameMgr.Battle.BattleWeather")
local BattleLangDB      = require("src.GameMgr.Battle.UI.BattleLangDB") 
require("src.GameMgr.Battle.UI.actionStyle")
local BattleUIMgr       = {}
  
local petInfo       = nil
local pets   		= nil
local balls 		= nil
local downEdge      = nil
local downBlood     = nil
local upBlood       = nil
local scene         = nil
local groundBack    = nil
local cards     	= nil
local battleLabel   = nil
local battleLabelBM = nil
local battleTime    = nil
local battleMgr     = nil
local playerIsWin	= false
local helpPetID     = -1
local preSkill      = -1
local timeSceNum    = 9
local timePercent   = 0
local fightNumNode  = {}
local round         = 1 
local weather       = 0 
local energyNum     = 0

local currPetInfo   = {}
local currPetID     = {}
local currHpRes     = {}
local scheduler = require(cc.PACKAGE_NAME..".scheduler")

BattleUIMgr.isAutoFight     = false
BattleUIMgr.firstBattle     = 0
BattleUIMgr.speed           = BATTLE_TWO_TIMES_SPEED
BattleUIMgr.ballNum         = {}
BattleUIMgr.isProfouSkill   = false
BattleUIMgr.canFight        = true
BattleUIMgr.showSkillTip    = true
BattleUIMgr.isJumpBattle    = false

-------------需要调整的数据--------------
-------------Boss Battle音效初始化-------------------------
BattleUIMgr.SkillSoundEffect = {}
BattleUIMgr.SkillSoundEffect["Gaf/bossEffect/kinfe.gaf"] = "bossdici"
BattleUIMgr.SkillSoundEffect["Gaf/bossEffect/boom.gaf"] = "bossfire"
BattleUIMgr.SkillSoundEffect["Gaf/bossEffect/laser.gaf"] = "bossjiguang"

-------初始化----------------
function BattleUIMgr.Init(battle,info,parent)
    BattleCotroller.petBuffers[0]  = {}
    BattleCotroller.petBuffers[1]  = {}
    BattleCotroller.battleDetail   = {}
    
    fightNumNode = {}
    preSkill        = -1
    round           = 1
    weather         = 0
    energyNum       = 0
    BattleUIMgr.isProfouSkill = false
    playerIsWin     = false
    ---------------------------------------------------------
    BattleCCSB.init()
    BattleCANI.init()
    BattleFuncMgr.init()
    BattleBufferUI.init()

    petInfo 		     = info
    currPetID[TEAM_A]    = 1
    currPetID[TEAM_B]    = 1 
    currPetInfo[TEAM_A]  = petInfo[TEAM_A][OUTPETS][1]
    currPetInfo[TEAM_B]  = petInfo[TEAM_B][OUTPETS][1] 
    scene 			= parent
    battleMgr       = battle
    downEdge   		= BattleCCSB.DOWNEDGE
    downBlood 	    = BattleCCSB.DOWNBLOOD
    upBlood         = BattleCCSB.UPBLOOD
    groundBack  	= BattleCCSB.GROUNDBACK
    cards 			= BattleCCSB.CARDS
    battleTime      = BattleCCSB.TIME
    pets			= BattleCANI.PETS
    balls 			= BattleCANI.BALLS
    battleLabel     = BattleLabelAtlas.BATTLELABEL
    battleLabelBM   = BattleLabelAtlas.BMFONT 
    BattleUIMgr.speed 		= UserSettings.get("BattleSpeed") or BATTLE_TWO_TIMES_SPEED
    -- BattleUIMgr.speed       = BATTLE_TWO_TIMES_SPEED 
    BattleUIMgr.isAutoFight = UserSettings.get("BattleIsAuto") or false

    BattleCotroller.isPause         = false
    BattleUIMgr.isJumpBattle  = false

    ---------------------------------------------------------------------------
    CocosModuleMgr.addTouchEffect(scene)  

    if BattleMapMgr.getWeather() then
        weather = BattleMapMgr.getWeather()
    end

    BattleUIMgr.showSkillTip = true
    
    currHpRes[TEAM_A] = ""
    currHpRes[TEAM_B] = ""

    BattleUIMgr.jumpRound  = false
end

function BattleUIMgr.getWeather()
    return weather
end

function BattleUIMgr.getPetInfo(team)
    return currPetInfo[team]
end

-------加入战斗UI----------------------------
function BattleUIMgr.addUI()
    local funTbl = {}

    local function loadCSB()
        BattleCCSB.createDownEdge(scene,currPetInfo[0])

        BattleCCSB.createDownBlood(scene,currPetInfo[0])

        BattleCCSB.createGroundback(scene)  

        BattleCCSB.createUpBlood(scene,currPetInfo[1],petInfo[HISPETS][OUTPETS])

		BattleCCSB.createTime(scene,battleLabel)
        BattleCCSB.createFuncMenu(scene)  

        BattleCCSB.createPetCards(petInfo[MYPETS][OUTPETS],petInfo[MYPETS][INPETS])
        
    end
    
    local function loadPets()
        BattleCotroller.battleDetail.me,BattleCotroller.battleDetail.enemy = BattleCANI.createPets(scene,petInfo)

        table.insert(pets.petTable[1],upBlood.bar)
        table.insert(pets.petTable[1],"EnemyBloodStr")
        table.insert(pets.petTable[1],1) 
        table.insert(pets.petTable[0],downBlood.bar)  
        table.insert(pets.petTable[0],"playerBloodStr")
        table.insert(pets.petTable[0],0)

        BattleCANI.createPetBalls(scene)
        BattleUIMgr.LoadSkillEvent()
        BattleCotroller.triggerToRecord()  
        if BattlePVPMgr.mIsPVPBattle or BattleMapMgr.getIsArena() then
            BattleCotroller.findPVPRecord()
        else
            if BattleMapMgr.getBattleSceneInfo().boss then
                BattleCotroller.setstepEventName("petEnter")
                BattleUIMgr.showBossEffect(callback)
            else
                if BattleMapMgr.getIsFilm() then
                    BattleUIMgr.playBattleFilm() 
                end
                BattleCotroller.judgeNextBattle() 
            end
        end 

        local randomWea = GetRandom.random(1,100)

        if randomWea < 50 then 
            BattleCANI.createFogEffect(scene,display.cx,BattleCANI.PETS.playerPosY-50,display.cx,BattleCANI.PETS.enemyPosY + 230)
        end

    end

    local function testBattle()
        loadCSB()
        loadPets()
        
    end

    testBattle()
    BattleUIMgr.changeWeather(weather) 
    
end
-----------载入技能事件------------------------
function BattleUIMgr.LoadSkillEvent()
    local BattleGetPetInfo = require("src.GameMgr.Battle.BattleGetPetInfo")
    local skillData = BattleGetPetInfo.getSkillData()
    for i = 0, 1 do
        for key,var in pairs(skillData[i]) do
            local res = nil
            local res1 = nil
            local res2 = nil
            if var["res1"] ~= "" then
                BattleFuncMgr.setGafFrameAndEvent(var["res1"])
            end
            if var["res2"] ~= "" then
                BattleFuncMgr.setGafFrameAndEvent(var["res2"])
            end
            if var["res3"] ~= "" then
                BattleFuncMgr.setGafFrameAndEvent(var["res3"])
            end
            if var["res"] ~= "" then
                BattleFuncMgr.setGafFrameAndEvent(var["res"])
            end
        end
    end
end

function BattleUIMgr.showSkill(skillType)

    local skillPanel = display.newSprite("Battle/petStatus/UI/fight_opponent_skill_base.png")
    skillPanel:setScale(0)
    skillPanel:setAnchorPoint(cc.p(1,0.5))
    skillPanel:addTo(scene) 
    skillPanel:zorder(10)
    skillPanel:setPosition(cc.p(0,600))

    local exTend   = cc.ScaleTo:create(0.1,-1.0,1.0,0)
    local recover  = cc.ScaleTo:create(0.1,0.0,0.0,0)
    local wait     = cc.DelayTime:create(1.5)
    local sequence = cc.Sequence:create(exTend,wait,recover,cc.CallFunc:create(function()
            skillPanel:removeFromParent()
        end)) 
    local name     = currPetInfo[0]["skill"][skillType].name
    local level    = currPetInfo[0]["skill"][skillType].id%10
    local nameStr  = name.." "..level
    local skillIconStr ="Battle/skillIcon/"..currPetInfo[0]["skill"][skillType].info.icon..".png"
    if not BattleFuncMgr.isFileExist(skillIconStr) then
        skillIconStr = "Battle/skillIcon/default.png"
    end

    local skillName = display.newTTFLabel({
        font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
        text = nameStr,
        size = 20, 
        align = cc.TEXT_ALIGN_CENTER, 
        color = display.COLOR_WHITE
    })

    skillName:setPosition(cc.p(120,32))
    skillName:setScaleX(-1)
    skillPanel:addChild(skillName)

    local skillIcon = display.newSprite(skillIconStr)
    skillIcon:setPosition(cc.p(33,31))
    skillIcon:setScale(-0.6,0.6)
    skillPanel:addChild(skillIcon)

    local petIconBg = display.newSprite("Battle/petStatus/dengjiquan.png")
    petIconBg:setPosition(cc.p(8,20))
    petIconBg:setScale(0.8)
    skillPanel:addChild(petIconBg)

    local petIcon = display.newSprite(currPetInfo[0]["skill"][skillType].icon)
    petIcon:setScale(0.8)
    petIcon:setPosition(cc.p(8,20))
    skillPanel:addChild(petIcon)
 
    skillPanel:runAction(sequence)
end

function BattleUIMgr.showHisSkill(skillType) 
    local exTend   = cc.ScaleTo:create(0.1,1.0,1.0,0)
    local recover  = cc.ScaleTo:create(0.1,0.0,0.0,0)
    local wait     = cc.DelayTime:create(1.5)
    local sequence = cc.Sequence:create(exTend,wait,recover) 
    local name     = currPetInfo[1]["skill"][skillType].name
    local level    = currPetInfo[1]["skill"][skillType].id%10
    local nameStr  = name.." "..level 
    local skillIconStr ="Battle/skillIcon/"..currPetInfo[1]["skill"][skillType].info.icon..".png"
    if not BattleFuncMgr.isFileExist(skillIconStr) then
        skillIconStr = "Battle/skillIcon/default.png"
    end
    local atr_sp = upBlood.skillAtr:getChildByName("atr")
 
    CSResourceMgr.setSpriteTextureByNode(atr_sp, currPetInfo[1]["skill"][skillType].icon)
    upBlood.hisSkillName:setString(nameStr)
    CSResourceMgr.setSpriteTextureByNode(upBlood.hisSkillIcon, skillIconStr)
    upBlood.hisSkillDB:runAction(sequence)
end

function BattleUIMgr.checkSpecialDamage(attack,defend,damageTable,skillID,callback)
    if damageTable.chaos then
        BattleUIMgr.showDamage(defend, damageTable[1], damageTable[2],damageTable[3],damageTable[4],skillID)
        BattleCANI.createChaosEffect(attack,currPetInfo[attack].pokeID,callback) 
        AnimationMgr.playAniWithSpCallback(pets.petTable[attack][2], "hurt",nil, function() 
            AnimationMgr.playAni(pets.petTable[attack][2], "idle", true, pets.petTable[attack][3]) 
        end, pets.petTable[attack][3], false)  

        return true
    end
end

---function 播放宠物动画
--@param attackType     攻击宠物类型
--@param skillType      第几个技能
--@param attackedType   被攻击宠物类型
--@param damageTbl      伤害表
--@param anger          已方愤怒值表现
--@param energy         已方能量值表现
function BattleUIMgr.petAnimation(attackType,skillType,attackedType,damageTbl,anger,energy,sixValues)
    local Res1 = pets.petTable[attackType][2]
    local Res2 = pets.petTable[attackedType][2]
    local Pet1 = pets.petTable[attackType][1]
    local Pet2 = pets.petTable[attackedType][1]
    local Tag1 = pets.petTable[attackType][3]
    local Tag2 = pets.petTable[attackedType][3]
    local rate = pets.petTable[attackType][4]
    local buffID        = -1
    local actTime       = 0
    local isOverAction  = false
    local isOverEffect  = false

    BattleUIMgr.setStopAction(false) 

    Pet1:zorder(4)
    Pet2:zorder(2) 

    if sixValues then
        BattleUIMgr.setSixValue(sixValues[1],sixValues[2])
    end

    local function AniComplete()
        if BattleUIMgr.isJumpBattle or BattleCCSB.MENU.isOut then
            return
        end
        currPetInfo[attackType]["blood"]    = damageTbl[4]
        currPetInfo[attackedType]["blood"]  = damageTbl[3]
        AnimationMgr.playAni(Res1, "idle", true, Tag1)
        AnimationMgr.playAni(Res2, "idle", true, Tag2)
        BattleUIMgr.checkSpeed()
        BattleCANI.cleanFocus(attackType)

        local dieTime = 1.0/BattleUIMgr.speed 

        BattleCCSB.GROUNDBACK.blackBg:fadeOut(0.05) 
        
        if currPetInfo[0]["skill"][4] ~= 0  then 
            BattleUIMgr.setAnger(anger[attackedType+1])
        end
        if attackType == 0 then
            if BattleCANI.skillLight then
                BattleCANI.skillLight:removeFromParent()
            end
            BattleCANI.skillLight = nil
        end
        BattleUIMgr.checkEnergyCounts(energy[attackedType+1])
        
        BattleUIMgr.checkPetIsDead()
        pets.petTable[0][1]:performWithDelay(function()
            BattleCotroller.judgeNextBattle()

        end,dieTime)
    end

    if skillType == 5 then
        BattleFuncMgr.upDownVibrationAni(Pet1)
        local Color     = {r=11,g=221,b=247,a=255} 
        if damageTbl[4] > 0 then
            BattleCCSB.buffFontShow(attackType,LuaSqlite.getLanguageByKey("battleword29"),Color)
        end 
        pets.petTable[0][1]:performWithDelay(function()
            AniComplete()
        end,0.2/BattleUIMgr.speed)
        return
    end   

    local petSkill = currPetInfo[attackType]["skill"][skillType]
    local aniSkillID = tonumber(petSkill["id"])
    local skillAtt = petSkill.info.skillAtt 

    if BattleUIMgr.checkSpecialDamage(attackType,attackedType,damageTbl,aniSkillID,AniComplete) then

        return
    end

    if attackType == 0 then
        if skillType ~= 4 then
            BattleFuncMgr.setNodeGray(downEdge.skillPics[skillType],true)   
        else
            BattleFuncMgr.setNodeGray(downEdge.aoyiImage,true) 
        end
        BattleUIMgr.playSkillShow(0, skillType)
    else
        BattleUIMgr.playSkillShow(1, skillType)
    end

    local function damageLogic()
        if BattleCotroller.bossHP then
            print("BattleCotroller.TeamA_Damage..........",BattleCotroller.TeamA_Damage) 
               
            if attackedType == 1 then
                local summDamage = 0
                local damages = damageTbl[1]
                for key,var in pairs(damages) do
                    if var.enemydamage then
                        summDamage = summDamage + var.enemydamage
                    end
                end
                BattleCotroller.bossHP = BattleCotroller.bossHP - summDamage
                if BattleCotroller.bossHP < 0 then
                    BattleCotroller.bossHP = 0
                end
                damageTbl[3] = BattleCotroller.bossHP
            elseif attackType == 1 then
                damageTbl[4] = BattleCotroller.bossHP 
            end
            BattleCotroller.TeamA_Damage = 0 
            print("BattleCotroller.bossHP............",BattleCotroller.bossHP)  
        end
        BattleUIMgr.showDamage(attackedType, damageTbl[1], damageTbl[2],damageTbl[3],damageTbl[4],aniSkillID)
    end

    local function skillFinishLogic()
        AniComplete()
        for key,var in pairs(pets.skillAnis[attackType][tostring(aniSkillID)]) do
            var[1]:removeFromParent()
        end
        pets.skillAnis[attackType][tostring(aniSkillID)] = nil
    end

    local function connectSkills(key)
        if not pets.skillAnis[attackType][tostring(aniSkillID)][key] then
            return
        end

        local skillResName = pets.skillAnis[attackType][tostring(aniSkillID)][key][2]
        local isFaultEvt = true
        local influNode = {EVENT_WOUNDED = nil,EVENT_SHAKE = scene,EVENT_BEATEN = Pet2}
        local gafObjc = pets.skillAnis[attackType][tostring(aniSkillID)][key][1]

        if key < #pets.skillAnis[attackType][tostring(aniSkillID)]  then
            isFaultEvt = false
            influNode = nil
        end

        gafObjc:show() 
        gafObjc:setFps(24*BattleUIMgr.speed)  
        -- gafObjc:setFps(3)

        if AnimationMgr.getAniType(skillResName) == AnimationMgr.ANI_TYPE_GAF then
            BattleFuncMgr.skillTriggerEventHandler(skillResName,gafObjc,function(info)
                if BattleUIMgr.isJumpBattle or BattleCCSB.MENU.isOut then
                    return
                end
                if info.event == "EVENT_CAST" then
                    local nextKey = key +1
                    connectSkills(nextKey) 
                end 
                if string.find(info.event,"EVENT_EXBEATEN")  then 
                    BattleCANI.createBeatenGafs(attackedType,currPetInfo[attackedType]["pokeID"],scene,1)
                end
                if string.find(info.event,"EVENT_BEATEN")  then 
                    AnimationMgr.playAniWithSpCallback(Res2, "hurt",nil, function() 
                            AnimationMgr.playAni(Res2, "idle", true, Tag2) 
                        end, Tag2, false)

                    BattleFuncMgr.nodeBeatenColor(attackedType,pets.petTable[attackedType][1],{255,0,125})

                    if petSkill.beatSound ~= "" then
                        local num = GetRandom.random(1,3)
                        local exStr = ".m4a"
                        if device.platform=="windows" then
                            exStr = ".mp3"
                        end 
                        local soundRes = "Music/sound/"..petSkill.beatSound..num..exStr
                        GameAudio.playSound(soundRes) 
                    end

                    if attackedType == 0 then
                        BattleFuncMgr.braveRespon(BattleCCSB.CARDS.outCard[currPetID[0]]["button"],
                        BattleCCSB.CARDS.cardPos[currPetID[0]][1],BattleCCSB.CARDS.cardPos[currPetID[0]][2]) 
                    end
                end
                if string.find(info.event,"EVENT_WOUNDED")  then
                    damageLogic() 
                end
            end,
            function()
                isOverEffect = true
                pets.skillAnis[attackType][tostring(aniSkillID)][key][1]:hide()
                pets.skillAnis[attackType][tostring(aniSkillID)][key][1]:stop()
                if key == #pets.skillAnis[attackType][tostring(aniSkillID)] then      
                    if isOverAction and isOverEffect then
                        skillFinishLogic()
                    end 
                else
                    gafObjc:hide()
                end
            end,
            isFaultEvt,influNode)
        end
    end 
    --开始播放奥义技能
    local function applyImportSkill()
        if BattleCCSB.MENU.isOut then 
            return
        end
        local isAttack = false 
        Pet1:performWithDelay(function()
            if BattleCCSB.MENU.isOut then 
                return
            end 
            local icon = PokemonInfo.getPokemonInfoByID(currPetInfo[attackType].pokeID).fightSkin
            BattleCANI.createCutIn(downEdge.layer,icon,currPetInfo[attackType].skin,petSkill.info.airpower,function() 
                    actionStyle:runActionStyle(Pet1,attackType,petSkill.selfAct,function() 
                            -- audio.playSound(petSkill["sound"],false)
                            GameAudio.playSound(petSkill["sound"]) 
                            local startAni = 1
                            connectSkills(startAni)
                    end,function()
                        isOverAction = true
                        print("applyImportSkill.....isOverAction......",isOverAction)
                        print("applyImportSkill.....isOverEffect......",isOverEffect)
                        if isOverAction and isOverEffect then
                            skillFinishLogic()
                        end
                    end) 
                end)
            
        end, 0.08/BattleUIMgr.speed) 
    end
    --开始播放普通技能
    local function applyCommonSkill() 
        if BattleCCSB.MENU.isOut then 
            return
        end
        actTime = 0.08/BattleUIMgr.speed

        Pet1:performWithDelay(function()
                if not BattleCCSB.MENU.isOut then 
                    actionStyle:runActionStyle(Pet1,attackType,petSkill.selfAct,function()   
                                -- audio.playSound(petSkill["sound"],false)
                                GameAudio.playSound(petSkill["sound"]) 
                                local startAni = 1
                                connectSkills(startAni)
                        end,function()
                            isOverAction = true
                            if isOverAction and isOverEffect then
                                skillFinishLogic()
                            end
                        end)
                end
            end, 0.5) 
    end
 
    local function useSkill()
        if skillType == 4 then
            BattleCANI.createPetSkill(attackType,skillType,currPetInfo,scene,false,applyImportSkill)
            BattleCCSB.GROUNDBACK.blackBg:fadeIn(0.2)
        else 
            BattleCANI.createPetSkill(attackType,skillType,currPetInfo,scene,true,applyCommonSkill)
        end
    end
     
    if skillType > 1 and skillType < 4 then 
        BattleCANI.createOilSkillEffect(Pet1,currPetInfo[attackType]["pokeID"])
    end

    useSkill()
end
---function 换宠函数
--@param petType int  对方换宠为1，已方换宠为0
--@param index int 第几个宠换上
function BattleUIMgr.exchangePets(petType,index,sixValues,hp)

    local petPosX   = 0
    local petPosY   = 0
    local petParent = nil
    local Pet       = pets.petTable[petType][1]
    local Rate      = 1
    local buffers   = {}

    BattleUIMgr.setStopAction(false)
    BattleBufferUI.cleanAllPetBuffGaf(petType)

    -- BattleCCSB.clearPassNodes()
    BattleCCSB.clearPassNodesByPet(petType)
    if hp then
        currPetInfo[petType]["blood"] = hp  
    end

    if sixValues then
        BattleUIMgr.setSixValue(sixValues[1],sixValues[2])
    end

    if petType == 0 then
        if  BattleCANI.skillLight then
            BattleCANI.skillLight:removeFromParent()
            BattleCANI.skillLight = nil
        end 
        petPosX = pets.playerPosX
        petPosY = pets.playerPosY
    else
        petPosX = pets.enemyPosX
        petPosY = pets.enemyPosY
    end

    local function changePet()
        printFileLog("第几个宠换上......",index)
        local newPets       = {}
        local preName       = currPetInfo[petType]["name"]
        local newPetBar     = pets.petTable[petType][5] 
        local orgPetID      = currPetID[petType]
        petInfo[petType][OUTPETS][orgPetID] = currPetInfo[petType]
        local newPetTag     = pets.petAnis[petType][index][2]

        BattleUIMgr.cleanBuffer(petType)

        if petType == 0 then

            BattleCCSB.setPetCard(currPetInfo[petType],index,orgPetID)
        else
            Rate  = -1
            if BattleMapMgr.getAdvChallage() then
                for key,var in pairs(upBlood.ballLights) do
                    if var[2] == true then
                        upBlood.ballLights[key][2] = false
                        upBlood.ballLights[key][1]:hide()
                        upBlood.ballLights[index][1]:show()
                        upBlood.ballLights[index][2] = true
                        if currPetInfo[petType]["blood"] <= 0 then
                            BattleFuncMgr.setNodeGray(upBlood.enemyBalls[key],false)
                        end
                        break
                    end
                end 
                
            end
        end

        currPetInfo[petType].buffer = {}
        currPetInfo[petType]        = petInfo[petType][OUTPETS][index]
        currPetID[petType]          = index

        newPets = clone(pets.petTable[petType][7])

        Pet = pets.petAnis[petType][index][1]
        Pet:setPosition(petPosX,petPosY) 
        AnimationMgr.playAni(currPetInfo[petType]["res"], "idle", true, newPetTag)

        BattleCCSB.changeBloodStatus(petType,currPetInfo[petType])

        pets.petTable[petType] = {Pet,currPetInfo[petType]["res"],newPetTag,Rate,newPetBar,
            newPetBloodStr,newPets,color = petColor}

        if petType == 1 then
            BattleUIMgr.enterBattle(petType,Pet,true,BattleMapMgr.getAdvChallage())
            for key,var in pairs(currPetInfo[0]["skill"]) do
                if var ~= 0 then
                    local valueRes = BattleUIMgr.attributeStateRes(var["id"])
                    CSResourceMgr.setSpriteTextureByNode(downEdge.attriValue[key], valueRes)
                end
            end
        else
            preSkill = -1
            BattleCCSB.setSkillIcons(currPetInfo[0],battleMgr)
            BattleUIMgr.enterBattle(petType,Pet,true,true)
        end

        BattleUIMgr.checkSpeed() 
        cards.isbuffreplace = false
    end

    Pet:scaleTo(0.5/BattleUIMgr.speed, 0)
    BattleFuncMgr.keepTwinkle(Pet,0.5/BattleUIMgr.speed,changePet)
end

function BattleUIMgr.checkBloodbarAndBloodNum(petType, bloodNum)
    
    if BattleCCSB.MENU.isOut then
         return
     end

    local info          = nil

    if petType == 0 then
        info = downBlood
    else
        info = upBlood
    end

    local lastPer       = bloodNum*100/currPetInfo[petType]["bloodLimit"]
    local hpString      = bloodNum.."/"..currPetInfo[petType]["bloodLimit"]
    local resBlood      = ""

    if info then 
        resBlood = BattleFuncMgr.checkBloodPic(lastPer)
          
        if lastPer > 50 then
            info.hpStr:setTextColor(BattleCCSB.hpColors[2]) 
        else
            info.hpStr:setTextColor(BattleCCSB.hpColors[1]) 
        end
     
        info.hpStr:setString(hpString) 

        display.addImageAsync(resBlood,function()
            if currHpRes[petType] ~= resBlood then
                currHpRes[petType] = resBlood
                pets.petTable[petType][5]:loadTexture(resBlood)
            end 
            pets.petTable[petType][5]:setPercent(lastPer-20)
            pets.petTable[petType][5]:setPercent(lastPer)
        end)
    end

end
---检查宠物是否死亡
function BattleUIMgr.checkPetIsDead()
    if currPetInfo[0]["blood"] <= 0 then
        BattleFuncMgr.actiBeatenStyle(pets.petTable[0][1],1,1,BattleUIMgr.speed)
        BattleBufferUI.cleanAllPetBuffGaf(0) 
        GameAudio.playBattleSound("petdie")
        BattleUIMgr.deleteSelectedSkill(0)
    else
        transition.scaleTo(pets.petTable[0][1], {scaleX = pets.petTable[0][4]*BattleCANI.PETS.PET_SIZE_B,
            scaleY = BattleCANI.PETS.PET_SIZE_B}) 
    end

    if currPetInfo[1]["blood"] <= 0 then 
        BattleFuncMgr.actiBeatenStyle(pets.petTable[1][1],-1,1,BattleUIMgr.speed)
        BattleBufferUI.cleanAllPetBuffGaf(1) 
        GameAudio.playBattleSound("petdie") 
        BattleUIMgr.deleteSelectedSkill(1)
    else
        transition.scaleTo(pets.petTable[1][1], {scaleX = pets.petTable[1][4]*BattleCANI.PETS.PET_SIZE_A,
            scaleY = BattleCANI.PETS.PET_SIZE_A})
    end
end

---显示伤害
function BattleUIMgr.showDamage(petType, value, times,emBloodNum,selfBloodNum,skillID)
    local isboolTime    = false
    local anoType       = 1

    if petType == 1 then
        anoType = 0
    end

    BattleUIMgr.checkBloodbarAndBloodNum(petType, emBloodNum)
    BattleUIMgr.checkBloodbarAndBloodNum(anoType, selfBloodNum)
    local ismiss  = true
    local damageCounts  = 1

    local iscritical  = false

    local labelStr   = BattleUIMgr.fightLabelStateRes(skillID,currPetInfo[petType].pokeID)  
    for var,v in pairs(value) do
        if value[var]["selfdamage"] ~=nil then
            pets.petTable[petType][1]:performWithDelay(function()
                iscritical = false
                if getBattleBoolean(value[var]["critical"]) then
                    iscritical = true
                end
                
                if getBattleBoolean(value[var]["weak"]) then
                    labelStr = "normal"
                end
				BattleUIMgr.addFightLabel({petType = anoType, value = getBattleNumber(value[var]["selfdamage"]), type = labelStr, iscritical = iscritical})
            
            end, 0.1*(var-1))
        end

        if value[var]["enemyBuffer"] ~= nil then
            pets.petTable[petType][1]:performWithDelay(function()
                if not BattleUIMgr.showSkillTip or BattleCCSB.MENU.isOut then
                    print("战斗结束通知   ~~~~~~") 
                    return
                end
               
            end, 0.2*(var-1))  

            ismiss = false 
        end

        if value[var]["selfBuffer"] ~= nil then 
            pets.petTable[petType][1]:performWithDelay(function()
                if not BattleUIMgr.showSkillTip or BattleCCSB.MENU.isOut then
                    print("战斗结束通知   ~~~~~~")
                    return
                end

                BattleUIMgr.addBufState(anoType,value[var]["selfBuffer"],true,30*((var-1)%2))

            end, 0.2*(var-1))

            ismiss = false
        end

        if value[var]["selfheal"] ~= nil then
            iscritical = false
            local addLabel = "add"
			 BattleUIMgr.addFightLabel({petType = anoType, value = getBattleNumber(value[var]["selfheal"]), type = "addhp", iscritical = iscritical})
        
        end

        if value[var]["enemyheal"] ~= nil then
            iscritical = false
            local addLabel = "add"
			 BattleUIMgr.addFightLabel({petType = petType, value = getBattleNumber(value[var]["enemyheal"]), type = "addhp", iscritical = iscritical})
        end

        if value[var]["enemydamage"] ~= nil then
            ismiss = false
            iscritical = false

            if getBattleBoolean(value[var]["critical"]) then
                iscritical = true
            end

            if getBattleBoolean(value[var]["weak"]) then
                labelStr = "normal"
            end

            pets.petTable[petType][1]:performWithDelay(function() 
                BattleUIMgr.addFightLabel({petType = petType, value = getBattleNumber(value[var]["enemydamage"]), type = labelStr, iscritical = iscritical})
            end, 0.2*(damageCounts-1))
            damageCounts = damageCounts + 1 
        end

        if value[var]["enemyOtherDamages"] ~= nil then

            local damageParam = {petType = petType, value = getBattleNumber(value[var]["enemyOtherDamages"]),
                type = "normal", iscritical = false,parent = downEdge.db,zorder = 10}
            BattleUIMgr.otherPetsDamagesShow(damageParam)
        end

        if value[var]["enemyOtherHeals"] ~= nil then 
            local damageParam = {petType = petType, value = getBattleNumber(value[var]["enemyOtherHeals"]),
                type = "addhp", iscritical = false,parent = downEdge.db,zorder = 10}
            BattleUIMgr.otherPetsDamagesShow(damageParam)
        end

        if value[var]["selfOtherHeals"] ~= nil then 
            local damageParam = {petType = anoType, value = getBattleNumber(value[var]["selfOtherHeals"]),
                type = "addhp", iscritical = false,parent = downEdge.db,zorder = 10}
            BattleUIMgr.otherPetsDamagesShow(damageParam)
        end

        if value[var]["selfOtherDamages"] ~= nil then 
            local damageParam = {petType = anoType, value = getBattleNumber(value[var]["selfOtherDamages"]),
                type = "normal", iscritical = false,parent = downEdge.db,zorder = 10}
            BattleUIMgr.otherPetsDamagesShow(damageParam)
        end

        if value[var]["weather"] then 
            BattleUIMgr.changeWeather(value[var]["weather"])
        end

        if value[var]["miss"] then
			BattleUIMgr.addFightLabel({petType = petType, type = "miss"})
        end
    end 

end


function BattleUIMgr.verticalBattle()

end

function BattleUIMgr.testUI()
    local damageParam = {petType = petType, value = 100,
                type = "normal", iscritical = false,parent = downEdge.db,zorder = 10}
    BattleUIMgr.otherPetsDamagesShow(damageParam) 
end

function BattleUIMgr.addFightLabel(param) 

    local head = nil
    local label = nil
    local param = clone(param)

    local function runLabel()  
        local node = display.newNode()
        node.type = param.type
        if label then
            for i=1,math.floor(math.log10(param.value) + 1) do
                local sprite = label:getChildByTag(i-1)
                if i == 2 then
                    sprite:setPositionY(sprite:getPositionY()-4)
                end
                sprite:setPositionX(sprite:getPositionX()-8*(i-1))
            end
        end
        if head and label then
            head:setPositionX(-label:getContentSize().width*1.3/2)
            node:addChild(head)
            label:setPositionX(head:getContentSize().width/2)
            node:addChild(label)
            node.head = head
            node.label = label
        elseif head then
            node:addChild(head)
            node.head = head            
        elseif label then
            node:addChild(label)
            node.label = label
        end

        if param.parent then
            node:addTo(param.parent)
        else
            node:addTo(scene)
        end
        
        if param.zorder then
            node:zorder(param.zorder)
        else
            node:zorder(BMFONT_ZORDER)
        end

        local xpos = 0
        local ypos = 0
        if param.posX and param.posY then
            xpos = param.posX
            ypos = param.posY 
        else
            if param.petType == 1 then
                xpos = pets.enemyPosX
                ypos = pets.enemyPosY + 100
            else
                xpos = pets.playerPosX
                ypos = pets.playerPosY + 100
            end
        end
        node:setPosition(xpos,ypos)

        if param.type == "addhp" then
            BattleFuncMgr.fightLabelAddHpShow(node,function()
                node:removeFromParent()
            end)
        elseif param.type == "miss" then
            BattleFuncMgr.fightLabelMissShow(node,function()
                node:removeFromParent()
            end)
        elseif param.iscritical then
            BattleFuncMgr.fightLabelCriticalShow(node,function()
                node:removeFromParent()
            end)
        else
            BattleFuncMgr.fightLabelShow(node,function()
                node:removeFromParent()
            end)
        end
    end 

    if param.type == "addhp" then
        display.addImageAsync("Battle/battleLabel/battle_number_return_0.png",function()
            label = cc.LabelBMFont:create(param.value,"Battle/battleLabel/battle_number_return.fnt")
            runLabel()
        end)
    elseif param.iscritical then
        display.addImageAsync(CocosModuleMgr.getWordImage("zd_baoji.png"),function()
            display.addImageAsync("Battle/battleLabel/battle_number_crit_0.png",function()
                head = display.newSprite(CocosModuleMgr.getWordImage("zd_baoji.png"))
                label = cc.LabelBMFont:create(param.value,"Battle/battleLabel/battle_number_crit.fnt")
                runLabel()
            end)
        end)
    elseif param.type == "normal" then
        display.addImageAsync("Battle/battleLabel/battle_number_crit_0.png",function()
                label = cc.LabelBMFont:create(param.value,"Battle/battleLabel/battle_number_crit.fnt")
                runLabel()
            end)
        
    elseif param.type == "strong" then
        display.addImageAsync("Battle/battleLabel/battle_number_restraint_0.png",function()
                display.addImageAsync(CocosModuleMgr.getWordImage("strong.png"),function()
                        head = display.newSprite(CocosModuleMgr.getWordImage("strong.png"))
                        label = cc.LabelBMFont:create(param.value,"Battle/battleLabel/battle_number_restraint.fnt")
                        runLabel()
                    end)
            end)
    elseif param.type == "weak" then
        display.addImageAsync("Battle/battleLabel/battle_number_restrainted_0.png",function()
                display.addImageAsync(CocosModuleMgr.getWordImage("weak.png"),function()
                    head = display.newSprite(CocosModuleMgr.getWordImage("weak.png"))
                    label = cc.LabelBMFont:create(param.value,"Battle/battleLabel/battle_number_restrainted.fnt")
                    runLabel()
                end)
            end)
    elseif param.type == "miss" then
        display.addImageAsync("Battle/miss.png",function()
            head = display.newSprite("Battle/miss.png")
            runLabel()
        end)
    else
        display.addImageAsync("Battle/battleLabel/battle_number_crit_0.png",function()
            label = cc.LabelBMFont:create(param.value,"Battle/battleLabel/battle_number_crit.fnt")
            runLabel()
        end)
    end
    
    
end

function BattleUIMgr.otherPetsDamagesShow(damageParam)
    if damageParam.petType == TEAM_A then
        for key,var in pairs(BattleCCSB.CARDS.outCard) do
            if key ~= currPetID[TEAM_A] and petInfo[TEAM_A][OUTPETS][key].blood > 0 then
                local blood = 0
                if damageParam.type == "addhp" then
                    blood = petInfo[TEAM_A][OUTPETS][key].blood+damageParam.value
                else
                    blood = petInfo[TEAM_A][OUTPETS][key].blood-damageParam.value
                end
                if blood <= 0 then
                    blood = 0
                    var.button:setTouchEnabled(false)
                    BattleFuncMgr.setNodeGray(var.head,false)
                    local spRes = "Battle/downEdge_A/die.png"
                    
                    display.addImageAsync(spRes,function()
                            local sp = display.newSprite(spRes)
                            sp:addTo(var.button)
                            sp:zorder(10)
                            sp:setPosition(47,88) 
                        end)
                end
                if blood > petInfo[TEAM_A][OUTPETS][key].bloodLimit then
                    blood = petInfo[TEAM_A][OUTPETS][key].bloodLimit
                end
                var.bar:setPercent(blood*100/petInfo[TEAM_A][OUTPETS][key].bloodLimit)
                local btnPosX,btnPosY = var.button:getPosition()
                damageParam.posX = btnPosX
                damageParam.posY = btnPosY
                
                BattleUIMgr.addFightLabel(damageParam) 
            end
        end
    end
 
    for key,var in pairs(petInfo[damageParam.petType][OUTPETS]) do
        if key ~= currPetID[damageParam.petType] then
            if damageParam.type == "addhp" then
                if petInfo[damageParam.petType][OUTPETS][key].blood > 0 then
                    petInfo[damageParam.petType][OUTPETS][key].blood = petInfo[damageParam.petType][OUTPETS][key].blood + damageParam.value
                    if petInfo[damageParam.petType][OUTPETS][key].blood > petInfo[damageParam.petType][OUTPETS][key].bloodLimit then
                        petInfo[damageParam.petType][OUTPETS][key].blood = petInfo[damageParam.petType][OUTPETS][key].bloodLimit
                    end
                end
            elseif damageParam.type == "normal" then
                petInfo[damageParam.petType][OUTPETS][key].blood = petInfo[damageParam.petType][OUTPETS][key].blood - damageParam.value
                if petInfo[damageParam.petType][OUTPETS][key].blood < 0 then
                    petInfo[damageParam.petType][OUTPETS][key].blood = 0
                end
            end
        end
    end
    
end

function getBattleNumber(v)
    if v == nil then
        return 0
    end
    return v
end

function getBattleBoolean(v) 
    if v == nil then
        return false
    end
    return v
end

function BattleUIMgr.setAnger(anger) 
    if currPetInfo[0]["skill"][4] == 0 then
        return
    end
    local angerRes = {
            {"empty.png","empty.png"}, 
            {"Battle/downEdge_A/meaning_skill_power_2_a.png","Battle/downEdge_A/meaning_fight_skill_power_2.png"},
            {"Battle/downEdge_A/meaning_skill_power_3_a.png","Battle/downEdge_A/meaning_skill_power_3_b.png",
                    "Battle/downEdge_A/meaning_fight_skill_power_3.png"},
            {"Battle/downEdge_A/meaning_skill_power_4_a.png","Battle/downEdge_A/meaning_skill_power_4_b.png",
                "Battle/downEdge_A/meaning_skill_power_4_c.png","Battle/downEdge_A/meaning_fight_skill_power_4.png"}
        } 

    if anger > BattleCCSB.DOWNEDGE.angersNumMax then
        anger = BattleCCSB.DOWNEDGE.angersNumMax
    end 
    downEdge.angersNum = anger
    currPetInfo[0].anger   = anger
    angerRes[0] = {"empty.png"}  
    downEdge.powText:setString(anger.."/"..downEdge.angersNumMax) 
    if not angerRes[downEdge.angersNumMax][anger] then 
        angerRes[downEdge.angersNumMax][anger] = "empty.png"
    end

    CSResourceMgr.setSpriteTextureByNode(downEdge.anger, angerRes[downEdge.angersNumMax][anger])
    -- for angerIndex = 1,downEdge.angersNumMax do
    --     if angerIndex <= anger then
    --         downEdge.angers[angerIndex]:show()
    --     else
    --         downEdge.angers[angerIndex]:hide()
    --     end
    -- end

    if currPetInfo[0].anger >= downEdge.angersNumMax then

        BattleCANI.createAoyiEffect(downEdge.db,624.32,214.71)

        display.addImageAsync("Battle/downEdge_A/skillBK_1.png",function()
             CSResourceMgr.setSpriteTextureByNode(downEdge.aoyiBK, "Battle/downEdge_A/skillBK_1.png")
            end)
        downEdge.anger:show()
        if downEdge.angersNumMax == 0 then
            downEdge.anger:hide()
            return
        end
        -- CSResourceMgr.setSpriteTextureByNode(downEdge.anger, 
        --     "Battle/downEdge_A/skill_base_anger_frame_full_light_"..anger..".png")
    else
        CSResourceMgr.setSpriteTextureByNode(downEdge.aoyiBK, "Battle/downEdge_A/skillBK.png")
        if  BattleCANI.aoyiEffectZ then
            BattleCANI.aoyiEffectZ:removeFromParent()
            BattleCANI.aoyiEffectZ = nil
            BattleCANI.aoyiEffectB:removeFromParent() 
            BattleCANI.aoyiEffectB = nil
        end 
    end

end

function BattleUIMgr.checkEnergyCounts(energy,callback)
    
    local originNum = energyNum
    downEdge.energiesNum = energy 
    energyNum = energy

    if energy < 6 then
        if BattleCANI.energy then
            BattleCANI.energy:removeFromParent()
            BattleCANI.energy = nil
        end
    end 

    if originNum == downEdge.energiesNum then
        pets.petTable[0][1]:performWithDelay(function()
                if callback then  
                    callback()
                end
            end, 0.01/BattleUIMgr.speed)
        
        return
    end 

    local function bubbleAction(node,callback_2,callback_1)
        local bubbleTime = 0.08/BattleUIMgr.speed
        local scaleX1 = cc.ScaleTo:create(bubbleTime,1.3,1.0) 
        local scaleX2 = cc.ScaleTo:create(bubbleTime,0.8,1.0)
        local scaleX3 = cc.ScaleTo:create(bubbleTime,1.0,1.0) 
        local callFunc  = nil
        local callFunc1 = nil
        if callback_2 then
            callFunc    = cc.CallFunc:create(callback_2)
            callFunc1   = cc.CallFunc:create(callback_1)
        end
        local sequenceX = cc.Sequence:create(scaleX1,callFunc,scaleX2,scaleX3,callFunc1)
        node:runAction(sequenceX)
    end

    local function updateEnergy(enerIndex)
        if enerIndex > energyNum then 
            return
        end 
        if BattleCCSB.DOWNEDGE.energies[enerIndex] then
            BattleCCSB.DOWNEDGE.energies[enerIndex]:opacity(255)
            BattleCCSB.DOWNEDGE.energies[enerIndex]:show()
            local filter_Sp = display.newFilteredSprite("Battle/downEdge_A/skill_consume_lattice_2.png", "BRIGHTNESS",{0.7}) 
            filter_Sp:addTo(BattleCCSB.DOWNEDGE.energies[enerIndex]) 
            local sp_Size = filter_Sp:getContentSize()
            filter_Sp:setPosition(sp_Size.width/2,sp_Size.height/2)
            BattleCCSB.DOWNEDGE.energies[enerIndex]:setScale(0.5,1.0)
            bubbleAction(BattleCCSB.DOWNEDGE.energies[enerIndex],function()
                    filter_Sp:removeFromParent() 
                end,function()
                        if BattleCCSB.MENU.isOut then  
                            return
                        end
                        enerIndex = enerIndex + 1
                        if enerIndex <= energy then
                            if enerIndex >= 6 then
                                local enerRes = "Spine/effects/Ui_nengliangtiao_quan.png"
                                BattleCANI.energy = AnimationMgr.createBattlePetAni(downEdge.db, enerRes,
                                    165,175.52)
                                BattleCANI.energy:zorder(10) 
                                AnimationMgr.playAni(enerRes, "animation", true)                        
                            end 
                            
                            downEdge.Tconsume:setString(enerIndex)  
                            updateEnergy(enerIndex)
                        else
                            if callback then
                                callback()
                            end
                        end
                    end)
        end     
    end

    local function closeEner(node)
        node:opacity(255)
        node:hide()
        -- node:setScale(1.0,1.0)
    end

    local cutEnerID = 1
    local copeID    = 1
    local enerTables = {}
    local enerCopys  = {}
    local function cutEnergy()
        transition.scaleTo(enerTables[cutEnerID], {
            scaleX     = 0,
            scaleY     = 1.0,
            time       = 0.2/BattleUIMgr.speed,
            onComplete = function()
                closeEner(enerTables[cutEnerID]) 
                cutEnerID = cutEnerID - 1
                if cutEnerID ~= 0 then
                    cutEnergy()
                else
                    if callback then
                        callback()
                    end
                end
            end,
        })
        

    end
 
    local function copesAction()
        if copeID == 0 then
            for key,var in pairs(enerCopys) do
                var:removeFromParent() 
            end
            return
        end

        local moveDown  = cc.MoveBy:create(0.1/BattleUIMgr.speed,cc.p(0,-50))
        local fadeOut   = cc.FadeOut:create(0.1/BattleUIMgr.speed)
        local callFunc  = cc.CallFunc:create(copesAction)
        
        local deLayTime = cc.DelayTime:create(0.1/BattleUIMgr.speed) 
        local sequence  = cc.Sequence:create(deLayTime,callFunc)

        local spawnTo   = cc.Spawn:create(moveDown,fadeOut,sequence)
        
        enerCopys[copeID]:runAction(spawnTo) 
        copeID = copeID - 1
    end

    if originNum > energy then         
        downEdge.Tconsume:setString(energy)
        for enerIndex = energy + 1,originNum do
            if BattleCCSB.DOWNEDGE.energies[enerIndex] then
                local posX,posY = BattleCCSB.DOWNEDGE.energies[enerIndex]:getPosition()
                local cope = BattleCCSB.DOWNEDGE.energies[enerIndex]:clone()
                cope:addTo(downEdge.db)
                cope:setPosition(posX,posY)
                cope:zorder(8)
                BattleCCSB.DOWNEDGE.energies[enerIndex]:opacity(100)
                enerTables[#enerTables+1] = BattleCCSB.DOWNEDGE.energies[enerIndex]
                enerCopys[#enerCopys+1]  = cope
            end
        end
        cutEnerID = #enerTables
        copeID    = cutEnerID
        cutEnergy()
        copesAction() 

    else
        updateEnergy(originNum+1)      
    end
      
end


function BattleUIMgr.roundUI(round)

    battleTime.layer:show()
    battleTime.labelPos:hide()
    GameAudio.playBattleSound("round")
    battleTime.roundNum:setString(round)
    CSResourceMgr.playActionWithCallback("Battle/PVPTime/PVPtime.csb", 1, 60, 0.8, function()
        end)

    local oilRes    = "Battle/downEdge_A/icon_skill_consume_yellow_01.png" 
    if BattleCotroller.lastbossHP then
        BattleCotroller.bossHP  = BattleCotroller.lastbossHP
    end

    display.addImageAsync(oilRes,function()
            local oils = {}
            for i = 1,2 do
                oils[i] = display.newSprite(oilRes) 
                oils[i]:addTo(scene)
                oils[i]:setPosition(display.cx-25+(i-1)*60,display.cy+130)
                oils[i]:zorder(9)
                oils[i]:setScale(1.2,1.2)
            end
            local function MoveOver1()
                BattleFuncMgr.bubbleRespon(downEdge.TENE)
                local num = energyNum + 1
                if num > ENERGY_LIMIT then
                    num = ENERGY_LIMIT
                end
                downEdge.Tconsume:setString(num) 
            end

            local function MoveOver2()  
                local incrEner = energyNum + 2
                if incrEner > ENERGY_LIMIT then
                    incrEner = ENERGY_LIMIT
                    downEdge.energiesNum = ENERGY_LIMIT
                end
                if BattleGuide.funcs[GUIDE_FIRST] then
                    BattleUIMgr.checkEnergyCounts(incrEner,function() 
                        BattleGuide.funcs[GUIDE_FIRST]()
                    end) 
                else
                    BattleUIMgr.checkEnergyCounts(incrEner,function() 
                        BattleCotroller.judgeNextBattle()
                    end)
                end
                
                BattleFuncMgr.bubbleRespon(downEdge.TENE)
                downEdge.Tconsume:setString(energyNum) 
                oils[1]:removeFromParent()
                oils[2]:removeFromParent()
            end

            local moveToEner1 = cc.MoveTo:create(0.2,cc.p(25,204))
            local scale1      = cc.ScaleTo:create(0.3,0,0)
            local spawn1      = cc.Spawn:create(moveToEner1,scale1) 
            local callFun1    = cc.CallFunc:create(MoveOver1)

            local moveToEner2 = cc.MoveTo:create(0.2,cc.p(25,204))
            local scale2      = cc.ScaleTo:create(0.3,0,0) 
            local spawn2      = cc.Spawn:create(moveToEner2,scale2)
            local callFun2    = cc.CallFunc:create(MoveOver2) 

            oils[1]:runAction(transition.sequence({
                cc.DelayTime:create(0.2),
                spawn1,
                callFun1
            }))
            oils[2]:runAction(transition.sequence({
                cc.DelayTime:create(0.4),
                spawn2,
                callFun2
            })) 
        end)  
   if BattleUIMgr.firstBattle ~= 1 then
       if round <= 3 and CharInfo.getVIPLevel() < 4 and not BattleCotroller.getIsRecord() then 
           BattleCCSB.MENU.jumpRound:setString(4-round) 
           BattleCCSB.MENU.jumpRound:setVisible(true)
           BattleCCSB.MENU.speed:setTouchEnabled(true)
           BattleFuncMgr.setNodeGray(BattleCCSB.MENU.speed,true) 
           BattleUIMgr.jumpRound = false
       else
           BattleCCSB.MENU.jumpRound:setVisible(false) 
           BattleCCSB.MENU.speed:setTouchEnabled(true)
           BattleFuncMgr.setNodeGray(BattleCCSB.MENU.speed,true) 
           BattleUIMgr.jumpRound = true
       end
       if  BattlePVPMgr.mIsPVPBattle then
           BattleCCSB.MENU.jumpRound:hide()
           BattleCCSB.MENU.speed:hide()
       end
   end

end

function BattleUIMgr.selectSkillShow(canSelect)
    battleTime.isOverTime   = false
    if BattleGuide.funcs[GUIDE_SECOND] then 
        BattleCCSB.TIME.canAutoPress = true
        BattleUIMgr.setStopAction(true)
        BattleGuide.funcs[GUIDE_SECOND]()
    else
        if BattleUIMgr.isAutoFight  then
            BattleCCSB.TIME.canAutoPress = false
            pets.petTable[0][1]:performWithDelay(function()
                    BattleUIMgr.forceUseSkill()
                end, 0.01/BattleUIMgr.speed)

        else
            -- if BattleCotroller.getCurrentRecordCount() <= 1 then
                if canSelect then
                    timePercent           = 100
                    timeSceNum   = 9

                    battleTime.canAutoPress = true
                    if UserSettings.get("battSpeed") then
                        cc.Director:getInstance():getScheduler():setTimeScale(2.0)
                    else
                        cc.Director:getInstance():getScheduler():setTimeScale(1.0)
                    end
                    battleTime.labelPos:show()
                    battleTime.layer:show() 
                    battleTime.timeNum:setString(tostring(timeSceNum))
                    battleTime.progressTime:setPercentage(timePercent)
                    BattleUIMgr.upDateTime()
                    BattleUIMgr.setStopAction(true)
                else
                    if BattlePVPMgr.mIsPVPBattle then
                        BattleUIMgr.setStopAction(true)
                        BattlePVPMgr.sendBattleCommand(0,1,0) 
                    end
                end
            -- else
            --     BattleUIMgr.goToContinus()
            -- end
        end
    end

end

function BattleUIMgr.sendRoundInfo(skillIndex,changePetType,changeIndex,isManner)
    battleTime.layer:hide()
    if not BattlePVPMgr.mIsPVPBattle then
        BattleCotroller.roundStart(skillIndex,changePetType,changeIndex,isManner)
    else
        BattlePVPMgr.sendBattleCommand(0,skillIndex,changeIndex)
        if skillIndex > 0 and skillIndex <= 4 then
            BattleUIMgr.showSelectSkill(0, skillIndex)
        end
    end
end

---强制使用技能
function BattleUIMgr.forceUseSkill()

    battleTime.isOverTime   = true
    for i = 1,3 do
        BattleFuncMgr.setNodeGray(downEdge.skillPics[i],false)
    end 
    BattleFuncMgr.setNodeGray(downEdge.aoyiImage,false)
    battleTime.layer:hide()
    BattleUIMgr.sendRoundInfo(-1,0,-1,false)
end


---更新时间进度条
function BattleUIMgr.upDateTime()

    if battleTime.handle then
        scheduler.unscheduleGlobal(battleTime.handle)
        battleTime.handle = nil
    end

    battleTime.handle = scheduler.scheduleGlobal(function() 
            if BattleCCSB.MENU.isOut or SceneMgr.currentScene ~= "BattleScene" then 
                scheduler.unscheduleGlobal(battleTime.handle)
                battleTime.handle = nil
                return
            end

            if BattleCotroller.isPause 
                or not BattleUIMgr.showSkillTip  
                or battleTime.isOverTime then  
                if battleTime.handle then       
                    scheduler.unscheduleGlobal(battleTime.handle)
                    battleTime.handle = nil
                    if battleTime.layer then 
                        battleTime.layer:hide()
                    end
                end
                return 
            end
            -- if battleTime.isOverTime == true  then

            --     battleTime.layer:hide()
            --     if battleTime.handle then
            --         scheduler.unscheduleGlobal(battleTime.handle)
            --         battleTime.handle = nil
            --     end
            --     return 
            -- end

            timePercent = timePercent - 10/4 
            battleTime.progressTime:setPercentage(timePercent)
                
            if timePercent <= 0 then
                timePercent = 100
                timeSceNum= timeSceNum- 1

                if timeSceNum < 1 then 
                    battleTime.isOverTime = true
                    if battleTime.handle then 
                        scheduler.unscheduleGlobal(battleTime.handle)
                        battleTime.handle = nil
                    end
                    battleTime.canAutoPress = false
                    BattleUIMgr.forceUseSkill()
                    return
                end
                GameAudio.playBattleSound("countdownFinish")
                battleTime.timeNum:scaleTo(0.1,1.2)
                battleTime.timeNum:performWithDelay(function()
                    battleTime.timeNum:scaleTo(0.05,1.0)
                end,0.1)
                battleTime.timeNum:setString(tostring(timeSceNum))
            end
        end,0.01)
end

function BattleUIMgr.deleteBufferIcon(petType,buffer)
 
    local key = tostring(buffer.id) 

    if BattleCotroller.petBuffers[petType][key] then
        BattleCotroller.petBuffers[petType][key].sprite:removeFromParent()
        BattleCotroller.petBuffers[petType][key] = nil
    end

    BattleUIMgr.checkBufferState(petType)
end

function BattleUIMgr.checkBuffInfomation(buffInfos) 
    local mybuffs   = buffInfos[1]
    local hisbuffs  = buffInfos[2] 
 
    if buffInfos[3] then 
        BattleUIMgr.setSixValue(buffInfos[3][1],buffInfos[3][2])
    end

    BattleBufferUI.cleanAllPetBuffGaf(0)
    BattleBufferUI.cleanAllPetBuffGaf(1)

    for key,var in pairs(BattleCotroller.petBuffers[0]) do
        var.sprite:removeFromParent()
    end

    for key,var in pairs(BattleCotroller.petBuffers[1]) do
        var.sprite:removeFromParent()
    end

    BattleCotroller.petBuffers[0] = {} 
    BattleCotroller.petBuffers[1] = {}

    for key , var in pairs(mybuffs) do
        BattleUIMgr.addBufState(0,var,false) 
    end

    for key , var in pairs(hisbuffs) do
        BattleUIMgr.addBufState(1,var,false)
    end


    BattleUIMgr.checkBufferState(0)
    BattleUIMgr.checkBufferState(1)

    pets.petTable[0][1]:performWithDelay(function()
            BattleCotroller.judgeNextBattle()
        end, 0.02/BattleUIMgr.speed)
end

---改变天气UI和特效
function BattleUIMgr.changeWeather(value,ischeck)

    if value == 0 then
        upBlood.weaBK:scaleTo(0.1,0)
    else
        upBlood.weaBK:scaleTo(0.1,1.0)
        local weaRes = "Battle/weather/icon/"..value..".png"
        if not BattleFuncMgr.isFileExist(weaRes) then
            weaRes = "Battle/weather/icon/1.png"
        end
        CSResourceMgr.setSpriteTextureByNode(upBlood.weather, weaRes)
    end
    BattleWeather.createWeather(scene,value)
    weather = value

    if ischeck  then
        pets.petTable[0][1]:performWithDelay(function()
            BattleCotroller.judgeNextBattle()
        end, 0.02/BattleUIMgr.speed)
    end

end

function BattleUIMgr.deleteAllBuffer(petType) 
    for key,var in pairs(BattleCotroller.petBuffers[petType]) do
        var.sprite:removeFromParent()
        BattleCotroller.petBuffers[petType][key] = nil
    end
    BattleUIMgr.checkBufferState(petType)
end

function BattleUIMgr.checkBufferState(petType)
    local posID         = 0
    local bufferInfo    = nil
    local isEmpty       = true

    if petType == 1 then
        bufferInfo      = upBlood
    else 
        bufferInfo      = downBlood
    end

    for key,var in pairs(BattleCotroller.petBuffers[petType]) do
        posID = posID + 1
        var.sprite:setPosition(bufferInfo.buffPosX+(posID-1)*bufferInfo.buffWidth,bufferInfo.buffPosY)
        isEmpty = false 
    end

    if isEmpty then
        BattleFuncMgr.removeVaryColor(petType,pets.petTable[petType][1]) 
    end
end

function BattleUIMgr.addBufState(petType,buffer,isCheck,gap)
    local bufferInfo    = nil 
    local petsize       = pets.PET_SIZE_A
    local rate          = 1
    local skillID       = buffer.skillID

    local skillInfo     = clone(BattleInfo.getSkillInfoByID(skillID))
    local buffName      = LuaSqlite.getLanguageByKey(buffer.name)
    local buffGafID     = buffer.effect  

    if petType == 1 then
        bufferInfo      = upBlood
        rate            = -1
    else
        petsize         = pets.PET_SIZE_B
        bufferInfo      = downBlood
    end

    local key = skillID*10000+buffer.id

        if not BattleCotroller.petBuffers[petType][key] then
            BattleCotroller.petBuffers[petType][key] = {}
        else
            BattleCotroller.petBuffers[petType][key].sprite:removeFromParent() 
            BattleCotroller.petBuffers[petType][key] = {}
        end
        
        local buffCirRes    = "Battle/state/state_0.png"
        local buffColor     = {r=11,g=221,b=247,a=255}
        
        local buffRes       = "Battle/skillIcon/"..skillInfo.icon..".png"

        if  buffer.isBuff then 
            buffCirRes    = "Battle/state/state_1.png"
        end
 
        local copyBuff      = bufferInfo.buffcir:clone()
        local buffPic       = copyBuff:getChildByName("buffer")
        copyBuff:addTo(bufferInfo.status)
        local pokeID = currPetInfo[petType].pokeID
        BattleBufferUI.petBufferShow(pets.petTable[petType][1],buffGafID,key,petType,pokeID)  
        CSResourceMgr.setSpriteTextureByNode(copyBuff, buffCirRes)   
        CSResourceMgr.setSpriteTextureByNode(buffPic, buffRes)  
        copyBuff:setVisible(true) 


        BattleCotroller.petBuffers[petType][key] = buffer
        BattleCotroller.petBuffers[petType][key].sprite = copyBuff

        if buffer.round then
            local lap = copyBuff:getChildByName("lap")  
            lap:setVisible(true)
            lap:setString(buffer.round)
            lap:setScale(2.5,2.5) 
            lap:enableOutline({r=29,g=29,b=28,a=255}, 1)
            lap:setTextColor({r=253,g=213,b=2,a=255})
        end
        BattleUIMgr.checkBufferState(petType)
        if isCheck then
            
            BattleCCSB.buffFontShow(petType,buffName,buffColor,gap)
        end 

end

function BattleUIMgr.getBufferSPAndInfo(petType)
    local buffInfo = {}

    for key,var in pairs(BattleCotroller.petBuffers[petType]) do
        local skillInfo = BattleInfo.getSkillInfoByID(var.skillID)
        local desc = skillInfo.des[var.id]

        local name  =  LuaSqlite.getLanguageByKey(var.name) 
        table.insert(buffInfo,{var.sprite:clone(),name..":",desc})
    end

    return buffInfo
end

function BattleUIMgr.showBufferEffect(buffer)
    local petType = buffer.petType
    local petsize    = pets.PET_SIZE_B
    local rate       = 1

    if petType == 1 then
        petsize     = pets.PET_SIZE_A
        rate        = -1
    end
    if buffer.over then 
        -- BattleBufferUI.effectBuffer(petType,buffer.buffid,false)  
        BattleBufferUI.cleanPetBuffGaf(petType,buffer.id)  
        BattleUIMgr.deleteBufferIcon(petType,buffer)
        transition.stopTarget(pets.petTable[petType][1])
        BattleFuncMgr.setNodeGray(pets.petTable[petType][1],true)
        pets.petTable[petType][1]:opacity(255)
        if type(buffer.over) == "table" then
            if buffer.over[1].selfsize then
                transition.scaleTo(pets.petTable[petType][1],{scaleX = rate*petsize,scaleY = petsize,time = 0.1})
            end
        end

        return
    end

    local buffGaf = nil  

    for key,var in pairs(BattleBufferUI.buffGafs[petType]) do
        if var[2] == buffer.id then
            BattleBufferUI.effectBuffer(petType,buffer.id,true) 
        end
    end

    BattleUIMgr.applyLogicUI(petType,buffer.buff[1])

end

function BattleUIMgr.checkbufferDamage(myDamages,hisDamages)

    for key,var in pairs(myDamages) do
        BattleUIMgr.applyLogicUI(TEAM_A,var)
    end

    for key,var in pairs(hisDamages) do
        BattleUIMgr.applyLogicUI(TEAM_B,var)
    end

    BattleUIMgr.goToContinus()
end

function BattleUIMgr.applyLogicUI(petType,value)
    local addBlood = 0
    local cutBlood = 0
    local anoType   = 1
    local petsize   = pets.PET_SIZE_B
    local status    = nil
    local anoStatus = nil 

    if petType == TEAM_B then
        status      = upBlood
        anoType     = TEAM_A
        anoStatus   = downBlood
    else
        status      = downBlood
        anoStatus   = upBlood
    end


    local info = {hpBar = pets.petTable[petType][5],currHp = currPetInfo[petType]["blood"],hpmax = currPetInfo[petType].bloodLimit,
        petType = petType,addHp = addBlood,cutHp = cutBlood,hpStr = status.hpStr}

    if value then
        -----------------------------自己数据
        if value.selfdamage ~= nil then
            info.cutHp = value.selfdamage

            BattlePassiveSkills.hurtUI(info)

            currPetInfo[petType]["blood"] = currPetInfo[petType]["blood"] - info.cutHp
            if currPetInfo[petType]["blood"] < 0 then
                currPetInfo[petType]["blood"] = 0
            end
        end

        if value.selfheal ~= nil then
            info.addHp = value.selfheal
            BattlePassiveSkills.healUI(info)

            currPetInfo[petType]["blood"] = currPetInfo[petType]["blood"] + info.addHp
            if currPetInfo[petType]["blood"] > currPetInfo[petType]["bloodLimit"] then
                currPetInfo[petType]["blood"] = currPetInfo[petType]["bloodLimit"]
            end
        end

        ---------------------------------对方数据

        info.petType    = anoType
        info.hpBar      = pets.petTable[anoType][5]
        info.currHp     = currPetInfo[anoType]["blood"]
        info.hpStr      = anoStatus.hpStr

        if value.enemydamage ~= nil then
            info.cutHp      = value.enemydamage

            BattlePassiveSkills.hurtUI(info)
            currPetInfo[anoType]["blood"] = currPetInfo[anoType]["blood"] - info.cutHp
            if currPetInfo[anoType]["blood"] < 0 then
                currPetInfo[anoType]["blood"] = 0
            end
        end

        if value.enemyheal ~= nil then
            info.addHp      = value.enemyheal

            BattlePassiveSkills.healUI(info)
            currPetInfo[anoType]["blood"] = currPetInfo[anoType]["blood"] + info.addHp
            if currPetInfo[anoType]["blood"] > currPetInfo[anoType]["bloodLimit"] then
                currPetInfo[anoType]["blood"] = currPetInfo[anoType]["bloodLimit"]
            end
        end
    end
    
    BattleUIMgr.checkPetIsDead()
    
end

function BattleUIMgr.selectSkill(i,isbool)
    if isbool then
        preSkill = i      
    end
end

----------进入游戏动画------------------------------------
function BattleUIMgr.enterBattle(petType,pet,isbool,isPerson,callback)
    local direction = 1
    local petSize   = pets.PET_SIZE_B
    local ballPosX 	= pets.playerPosX
    local ballPosY 	= pets.playerPosY - 120
    if petType == 1 then
        direction 	= -1
        petSize   	= pets.PET_SIZE_A
        ballPosX 	= pets.enemyPosX
        ballPosY 	= pets.enemyPosY - 170
    end
    local dropTime = 0
    local outTime  = AnimationMgr.getGafMotionTimeInterval("Gaf/ball/ruchang.gaf", "out", "Ball"..petType)
    balls.enterBall[petType]:show()
    balls.enterBall[petType]:setPosition(ballPosX,ballPosY)
    balls.enterBall[petType]:setScale(direction,1)

    BattleUIMgr.checkSpeed() 
    GameAudio.playBattleSound("petborn")  
    if isPerson then
        dropTime   = AnimationMgr.getGafMotionTimeInterval("Gaf/ball/ruchang.gaf", "drop", "Ball"..petType)
        AnimationMgr.playAni( "Gaf/ball/ruchang.gaf", "drop", false, "Ball"..petType)
    end

    pets.petTable[0][1]:performWithDelay(function()
        if not BattleUIMgr.showSkillTip or BattleCCSB.MENU.isOut then
            return
        end
        if isPerson then
            AnimationMgr.playAni( "Gaf/ball/ruchang.gaf", "out", false, "Ball"..petType)
        end

        BattleFuncMgr.petAppearAction(pet,outTime,petSize,direction,function()
            balls.enterBall[petType]:hide()
            if callback then
                callback()
            end
            if isbool then
                BattleCotroller.judgeNextBattle()  
            end
        end)
    end,dropTime)
end
---------无法行动设置---------------------------------
function BattleUIMgr.setStopAction(isbool)
    BattleCCSB.isStopAction = isbool
    local function judgeNodeGray(skillID,node,energy)
        if skillID == 4 then
            if BattleCCSB.DOWNEDGE.angersNum < BattleCCSB.DOWNEDGE.angersNumMax then
                BattleFuncMgr.setNodeGray(node,false)
            else
                BattleFuncMgr.setNodeGray(node,isbool) 
            end
        else
            if downEdge.energiesNum < energy then
                BattleFuncMgr.setNodeGray(node,false)
                if skillID ~= 1 then
                    BattleCANI.skillIconFlip(skillID,false)
                end

            else 
                if skillID ~= 1 then
                    BattleCANI.skillIconFlip(skillID,true)
                end
                BattleFuncMgr.setNodeGray(node,isbool)
            end 
        end    
    end

    for i = 1,4 do
        if downEdge.skillBtn[i] ~= nil then

            if currPetInfo[0]["skill"][i] ~= 0 then 
                local skillNode  = nil
                if i ~= 4 then
                    skillNode = BattleCCSB.DOWNEDGE.clickEffect[i]:getChildByName("pic"..i)
                else
                    skillNode = downEdge.aoyiImage
                end
                judgeNodeGray(i,skillNode,currPetInfo[0]["skill"][i].energy)      
            end

                -- downEdge.skillBtn[i]:setTouchEnabled(isbool)    
        end
    end

    for key,var in pairs(BattleCCSB.CARDS.outCard) do
        if key == currPetID[MYPETS] or var.bar:getPercent() <= 0 then
            var.button:setTouchEnabled(false)
            BattleFuncMgr.setNodeGray(var.button,false)
        else
            if var.bar:getPercent() > 0 then
                var.button:setTouchEnabled(isbool)
                BattleFuncMgr.setNodeGray(var.button,isbool)
            end
        end
        
    end
end
------------检测游戏速度-----------------------
function BattleUIMgr.checkSpeed() 
    local  speedRes = ""
    if BattleUIMgr.speed <= BATTLE_ONE_TIMES_SPEED then
        speedRes = "Battle/funcMenu/speed_1.png"
    else
        speedRes = "Battle/funcMenu/speed_2.png"
    end

    CSResourceMgr.setButtonTextureByNode(BattleCCSB.MENU.speed,speedRes,speedRes,speedRes)
    UserSettings.set({BattleSpeed = BattleUIMgr.speed})
    AnimationMgr.setSpeedRate(pets.petTable[0][2], PET_ANIMATION_SPEED, pets.petTable[0][3])
    AnimationMgr.setSpeedRate(pets.petTable[1][2], PET_ANIMATION_SPEED, pets.petTable[1][3])
    for petType = 0,1 do
        if balls.enterBall[petType] then
            balls.enterBall[petType]:setFps(24*BattleUIMgr.speed*BATTLE_BALL_OUT_SPEED)
        end

        for key,var in pairs(BattleBufferUI.buffGafs[petType]) do
            var[1]:setFps(24*BattleUIMgr.speed)
        end
    end
    
end
------------自动战斗设置-----------------------
function BattleUIMgr.autoBattle()
    if not BattleMapMgr.getIsArena() then
        if BattleUIMgr.isAutoFight then
            --            battleTime.layer:show()
            TipsMgr.show(scene, BattleLangDB["autoClose"])
            battleTime.canAutoPress = false
        else
            battleTime.layer:hide()
            TipsMgr.show(scene, BattleLangDB["autoOpen"])
            if battleTime.canAutoPress then
                BattleUIMgr.forceUseSkill()
                battleTime.canAutoPress = false
            end
            battleTime.isOverTime = true
        end
    else
        TipsMgr.show(scene, BattleLangDB["noManu"])
    end
end
------------暂停游戏--------------------
function BattleUIMgr.pauseBattle()
    if not BattlePVPMgr.mIsPVPBattle then
        AnimationMgr.pauseAni(pets.petTable[0][2], pets.petTable[0][3])
        AnimationMgr.pauseAni(pets.petTable[1][2], pets.petTable[1][3])
        transition.pauseTarget(pets.petTable[0][1])
        transition.pauseTarget(pets.petTable[1][1])
        BattleCotroller.isPause = true
        BattleUIMgr.setStopAction(false)
    end
end
------------恢复游戏--------------------
function BattleUIMgr.resumeBattle()
    if not BattlePVPMgr.mIsPVPBattle then
        AnimationMgr.resumeAni(pets.petTable[0][2], pets.petTable[0][3])
        AnimationMgr.resumeAni(pets.petTable[1][2], pets.petTable[1][3])
        transition.resumeTarget(pets.petTable[0][1])
        transition.resumeTarget(pets.petTable[1][1])

        BattleCotroller.isPause = false 

        if not battleTime.isOverTime then
            if battleTime.layer then 
                battleTime.layer:show()
            end
            BattleUIMgr.upDateTime()   
            BattleUIMgr.setStopAction(true)
        end
    end
end
------------选择技能--------------------
function BattleUIMgr.setSkillSelect(id,isbool)
    local btnStr = ""
    if isbool then
        preSkill = id
    end
end

function BattleUIMgr.getIsPlayerWin()
    return playerIsWin
end

function BattleUIMgr.winShow(result)  
    if BattleMapMgr.getisGoSummary() then
        local isOver = false
        BattlePVPMgr.startCalcTime(function()
                if isOver then
                    BattlePVPMgr.endCalcTime()
                    return 
                end 
                BattleUIMgr.quiteBattle()
                isOver = true
            end,1.0)
    else
        local canChange = true
        
        local winType = "expShow"

        if BattleUIMgr.isJumpBattle then
            winType = "damageShow"
        end 

        if BattleMapMgr.getIsArena() or BattlePVPMgr.mIsPVPBattle then
            winType = "expShow"
            canChange = false
        end 

       -- pets.petTable[1][1]:performWithDelay(function()
                local exp = BattleMapMgr.getNewExp()
                local sendPetInfo = {} 
                sendPetInfo[TEAM_A] = petInfo[TEAM_A][OUTPETS]
                sendPetInfo[TEAM_B] = petInfo[TEAM_B][OUTPETS]
                local damageTable = {}
                local damageMax   = 0
                print("battleMgr~~~~~~~~~~~~~~~",battleMgr)  
                if battleMgr then
                    local damageTeam_A = 0
                    local damageTeam_B = 0 
                    damageTable = battleMgr:getDamageTable()
                    for key,var in pairs(damageTable) do 
                        if type(var.damage) == "number" then
                              if var.team == 0 then
                                  damageTeam_A = var.damage + damageTeam_A
                              else
                                  damageTeam_B = var.damage + damageTeam_B
                              end
                        end
                    end
                    
                    if damageTeam_B > damageTeam_A then
                        damageMax = damageTeam_B 
                    else
                        damageMax = damageTeam_A 
                    end
                else
                    --todo
                end
                BattleCCSB.createSummary(exp,sendPetInfo,winType,damageTable,damageMax,result,canChange)
           -- end, 0.1)   
    end
end

function BattleUIMgr.gameOverEqual() 
    BattleCCSB.createGameLose(scene)
end

function BattleUIMgr.gameEnemyWin()
    BattleCCSB.createGameLose(scene)
end

function BattleUIMgr.sendCallBK(result) 
        if result then
            BattleCotroller.battleDetail.result         = result
        end
        BattleCotroller.battleDetail.me.hp       = {}
        BattleCotroller.battleDetail.me.objID    = {}
        BattleCotroller.battleDetail.enemy.hp    = {}
        BattleCotroller.battleDetail.enemy.objID = {}

        if BattleCotroller.getCurrentBattle() then
            BattleCotroller.battleDetail.myDamage = BattleCotroller.getCurrentBattle().totalDamageA
            BattleCotroller.battleDetail.hisDamage = BattleCotroller.getCurrentBattle().totalDamageB
        end

        -- for key,var in pairs(petInfo[MYPETS][OUTPETS]) do
        --     table.insert(BattleCotroller.battleDetail.me.hp,var.blood)
        --     table.insert(BattleCotroller.battleDetail.me.objID,var.objID)
        -- end

        if BattleCotroller.getCurrentBattle() then
            local pets = BattleCotroller.getCurrentBattle().teams[TEAM_A].pets
            for key,var in pairs(pets) do
                var:resetHp()
                if var.hp < 0 then
                    var.hp = 0
                end
                table.insert(BattleCotroller.battleDetail.me.hp,var.hp)
                table.insert(BattleCotroller.battleDetail.me.objID,var.objID)
            end
        else
            for key,var in pairs(petInfo[MYPETS][OUTPETS]) do
                if var.blood > 0 then
                    local minHp = math.ceil(var.bloodLimit/10000)
                    if var.blood < minHp then
                        var.blood = minHp
                    end
                elseif var.blood < 0 then
                    var.blood = 0
                end
                table.insert(BattleCotroller.battleDetail.me.hp,var.blood)
                table.insert(BattleCotroller.battleDetail.me.objID,var.objID)
            end
        end

        for key,var in pairs(petInfo[HISPETS][OUTPETS]) do
            if var.blood > 0 then
                local minHp = math.ceil(var.bloodLimit/10000)
                if var.blood < minHp then
                    var.blood = minHp
                end
            elseif var.blood < 0 then
                var.blood = 0
            end
            table.insert(BattleCotroller.battleDetail.enemy.hp,var.blood)
            table.insert(BattleCotroller.battleDetail.enemy.objID,var.objID)
        end
--        printFileLog("#HP#数量:",#BattleCotroller.battleDetail.me.hp)
--        printFileLog("#objID#数量:",#BattleCotroller.battleDetail.me.objID)  
--        printFileLog("BattleCotroller.battleDetail.me.hp.."..sz_T2S(BattleCotroller.battleDetail.me.hp))
--        printFileLog("BattleCotroller.battleDetail.me.objID.."..sz_T2S(BattleCotroller.battleDetail.me.objID))
        BattleMapMgr.useCallBK(BattleCotroller.battleDetail) 
end

function BattleUIMgr.GameOver(result,winType,canChange) 
    -- if BattleMapMgr.getIsCommonBattle() and not BattleCotroller.getIsRecord() then
    BattleCCSB.clearPassNodes()
    BattleUIMgr.showSkillTip = false
    battleTime.isOverTime   = true
    PetSkillViewMgr.hideBattleSkillInfoPage()
    BattleCCSB.UPBLOOD.showBuff:setTouchEnabled(false)
    BattleCCSB.DOWNBLOOD.showBuff:setTouchEnabled(false)
    battleTime.layer:hide()
    cc.Director:getInstance():getScheduler():setTimeScale(1.0) 
    -- if BattlePVPMgr.mIsPVPBattle then
    --     BattlePVPMgr.sendLeaveBattleCommand()
    -- end

    if not BattleCotroller.getIsRecord() or BattlePVPMgr.mIsPVPBattle then
        BattleUIMgr.sendCallBK(result) 
        if result == PLAYER_WIN then
            if BattleMapMgr.getIsCommonBattle() and not BattlePVPMgr.mIsPVPBattle then
                QuestInfo.checkProcessBeatMonster(BattleCotroller.battleDetail)
            end
        end      
    else
        if BattleMapMgr.getIsArena() then
            BattleMapMgr.useCallBK(BattleCotroller.battleDetail)
        end      
    end

    for skBtnIndex = 1,4 do
        BattleCCSB.DOWNEDGE.skillBtn[skBtnIndex]:setTouchEnabled(false)
    end
    print("BattleUIMgr.GameOver~~~~~~~~~~~~~~~~",result)   
    if result == PLAYER_WIN then
        playerIsWin = true
        if BattleMapMgr.getCanCatchPet() ~= 0 then
            BattleUIMgr.deleteSelectedSkill(0)
            BattleUIMgr.deleteSelectedSkill(1)
            -- BattleUIMgr.catchPet() 
        else
            local lastDialog = BattleMapMgr.getlastDialog()
            if lastDialog ~= "" then
                BattleMapMgr.showBattleDialogs(lastDialog,function()
                        BattleUIMgr.winShow(result)
                    end)
            else
                if BattlePVPMgr.isPVPArenaBattle == PVP_YES_ARENA then
                    BattlePVPMgr.ArenaWinShow()
                else
                    BattleUIMgr.winShow(result)
                end
            end
            BattleMapMgr.cleanPVPInfo()
            BattlePVPMgr.cleanPVPInfo()
        end

    else 
        BattleUIMgr.cleanUIMgr()
        playerIsWin = false
        if BattlePVPMgr.isPVPArenaBattle == PVP_NO_ARENA then
            if not BattlePVPMgr.mIsPVPBattle then
                BattleUIMgr.winShow(result)
            else
                BattleCCSB.createGameLose(scene) 
            end
        else
            BattlePVPMgr.ArenaLoseShow()
        end
        BattleMapMgr.cleanPVPInfo() 
        BattlePVPMgr.cleanPVPInfo()
        --todo
        -- if SceneMgr.previousScene ~= "SearchingScene" then
        --     BattleCCSB.createGameLose(scene)
        -- else
        --     SceneMgr.mapEnterType = 99
        --     SceneMgr.replaceScene(scene, SceneMgr.previousScene)
        -- end
    
    end 

    if BattleCANI.anger then
        BattleCANI.anger:removeFromParent()
        BattleCANI.anger = nil
    end
end

function BattleUIMgr.catchPetPoccessing(pet,catchState,addcatchRate)
    local ballOrder = {2,3,1} 
    local function setButtonEnable(btnBool)
        for i = 1,3 do
            BattleCCSB.CATCH.ball[i]:setTouchEnabled(btnBool) 
        end
    end

    local function createWinShow()
        BattleUIMgr.winShow(PLAYER_WIN)
    end

    if catchState == 1 then      
        display.addImageAsync(string.gsub(BattleCCSB.CATCH.gafBallRes[1],"gaf","png"),function()
            GameAudio.playBattleSound("petcatchSuccess") 
            balls.gaf = AnimationMgr.createBattlePetAni(scene,BattleCCSB.CATCH.gafBallRes[1],display.cx,display.cy-20)
            balls.gaf:zorder(8)
            AnimationMgr.playAniFrameWithCallback(BattleCCSB.CATCH.gafBallRes[1], 1,8,function()
                BattleFuncMgr.catchPetAction(pet,7/24,0) 
                AnimationMgr.playAniFrameWithCallback(BattleCCSB.CATCH.gafBallRes[1],9,21,function()
                    BattleFuncMgr.catchPetAction(pet,4/24,0)
                    AnimationMgr.playAniFrameWithCallback(BattleCCSB.CATCH.gafBallRes[1],22,26,function()
                        pet:scaleTo(0.2,0)
                        AnimationMgr.playAniFrameWithCallback(BattleCCSB.CATCH.gafBallRes[1],27,30,function()
                            AnimationMgr.playAniFrameWithCallback(BattleCCSB.CATCH.gafBallRes[1],31,122,function()
                                scene:performWithDelay(function()
                                    CocosModuleMgr.setScreenTouch(true)
                                    BattleCCSB.setCatchButtonEnabled(false)
                                    BattleCCSB.CATCH.giveup:setTouchEnabled(false)
                                    local enemyPets = BattleMapMgr.getEnemyPets()

                                    GachaViewMgr.playGetAPet(currPetInfo[1]["pokeID"],enemyPets[1],createWinShow)
                                    balls.gaf:removeFromParent() 
                                end,1.5) 
                            end)
                        end)
                    end)
                end)
            end)

        end)

    else
        if BattleUIMgr.ballID == 3 then
            if BattleUIMgr.ballNum[BattleUIMgr.ballID] <= 0 then 
                BattleCCSB.CATCH.add:show()
            else
                BattleCCSB.CATCH.add:hide()
            end
        end

        if BattleCCSB.CATCH.up_Sp then
            for key,var in pairs(BattleCCSB.CATCH.up_Sp) do
                var:removeFromParent()
            end
        end

        BattleCCSB.CATCH.up_Sp = {}

        display.addImageAsync(string.gsub(BattleCCSB.CATCH.gafBallRes[2],"gaf","png"),function()
            GameAudio.playBattleSound("petcatchfail") 
            balls.gaf = AnimationMgr.createBattlePetAni(scene,BattleCCSB.CATCH.gafBallRes[2],display.cx,display.cy-20)
            balls.gaf:zorder(8)
            AnimationMgr.playAniFrameWithCallback(BattleCCSB.CATCH.gafBallRes[2], 1,8,function()
                BattleFuncMgr.catchPetAction(pet,7/24,0)
                AnimationMgr.playAniFrameWithCallback(BattleCCSB.CATCH.gafBallRes[2],9,21,function()
                    BattleFuncMgr.catchPetAction(pet,4/24,0)
                    AnimationMgr.playAniFrameWithCallback(BattleCCSB.CATCH.gafBallRes[2],22,26,function()
                        pet:scaleTo(8/24,0)
                        AnimationMgr.playAniFrameWithCallback(BattleCCSB.CATCH.gafBallRes[2],27,30,function()
                            AnimationMgr.playAniFrameWithCallback(BattleCCSB.CATCH.gafBallRes[2],31,87,function()
                                BattleFuncMgr.catchPetAction(pet,3/24,0)
                                AnimationMgr.playAniFrameWithCallback(BattleCCSB.CATCH.gafBallRes[2],88,96,function()
                                    if catchState == 2 then
                                        BattleCCSB.setCatchButtonEnabled(true)
                                        for i = 1 ,3 do
                                            -- BattleCCSB.CATCH.catchRate[i] = (addcatchRate + ItemInfo.getItemInfoById(ballOrder[i]).paramA) * petInfo[TEAM_B][OUTPETS][1]["monster"]["catchRate"]/100
                                            local catchRate = addcatchRate + BattleCCSB.CATCH.catchRate[i]
                                            local catchRateAddCount = CharInfo.get().catchrateaddcount or 0
                                            if catchRateAddCount>0 then
                                                catchRate = catchRate+ActivityViewMgr.getCatchPetValue().value
                                            end
                                            if catchRate > 100 then
                                                catchRate = 100
                                            end
                                            catchRate = math.floor(catchRate)
                                            BattleCCSB.CATCH.rateStr[i]:setString(catchRate.."%"..BattleLangDB["rate"])
											if  LuaSqlite.LANG_TYPE == 5 then
												BattleCCSB.CATCH.rateStr[i]:setString(BattleLangDB["rate"]..catchRate.."%")
											end
                                            BattleCCSB.CATCH.rateStr[i]:setTextColor({r = 148,g = 254,b = 6,a=238})

                                            local strSize = BattleCCSB.CATCH.rateStr[i]:getContentSize()
                                            BattleCCSB.CATCH.up_Sp[i] = display.newSprite("Battle/catch/potential_buff_01.png")
                                            BattleCCSB.CATCH.up_Sp[i]:addTo(BattleCCSB.CATCH.rateStr[i])
                                            BattleCCSB.CATCH.up_Sp[i]:setPosition(strSize.width+10,strSize.height/2)
                                            local ccbiName = LuaSqlite.LANG_TYPE == 1 and "ui_dc_19.ccbi" or "ui_dc_24.ccbi"
                                            local up_ccbi = CSResourceMgr.createCCBI(BattleCCSB.CATCH.rateStr[i], 
                                                    CocosModuleMgr.getWordImage(ccbiName), strSize.width/2, strSize.height/2-100)
                                            up_ccbi:performWithDelay(function() 
                                                    up_ccbi:removeFromParent()
                                                end, 1.0) 
                                        end
                                    else
                                        BattleCCSB.CATCH.giveup:setTouchEnabled(false) 
                                        BattleUIMgr.winShow(PLAYER_WIN)
                                        
                                    end 
                                    balls.gaf:removeFromParent()
                                    CocosModuleMgr.setScreenTouch(true)

                                end)
                            end)
                        end)
                    end)
                end)
            end)
        end)
    end
end

function BattleUIMgr.setCatchPetName()
    local rarePoint     = PokemonInfo.getPokemonInfoByID(currPetInfo[1].pokeID).rarePoint
    local nameColor     = PokemonInfo.COLOR[rarePoint]
    local nameStr       = currPetInfo[1].name 
    local nameTTF       = display.newTTFLabel({
            font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
            text = nameStr,
            size = 32,
            align = cc.TEXT_ALIGN_CENTER,
            color = cc.c3b(nameColor.r, nameColor.g, nameColor.b) 
        })

    CSResourceMgr.setLabelColorByNode(catchPetName,PokemonInfo.COLOR[rarePoint])
    nameTTF:addTo(BattleCCSB.CATCH.layer) 
    nameTTF:enableOutline({r=0,g=0,b=0}, 1)
    nameTTF:zorder(10)
    nameTTF:setPosition(300,390)
    local nameSize = nameTTF:getContentSize()
    local rarePointPosX = 300 + nameSize.width/2 + 30
    BattleCCSB.CATCH.rarePoint = display.newSprite(PetEducationMgr.getRareIcon(rarePoint))
    BattleCCSB.CATCH.rarePoint:addTo(BattleCCSB.CATCH.layer)
    BattleCCSB.CATCH.rarePoint:setPosition(rarePointPosX,393) 
    BattleCCSB.CATCH.rarePoint:zorder(10)
    if currPetInfo[1].skin then
        if currPetInfo[1].skin > 0 then
            BattleCCSB.CATCH.rareDB:show() 
            local rareRes = CocosModuleMgr.getWordImage("UI_xiyouyinzhang.png")
            BattleCCSB.CATCH.xiyou = AnimationMgr.createAni(BattleCCSB.CATCH.layer, rareRes, 
                515, 568)
            BattleCCSB.CATCH.xiyou:zorder(10) 
            AnimationMgr.playAniWithSpCallback(rareRes, "diaoluo",nil, nil, nil, false)
            local function rarePlayAni()
                AnimationMgr.playAni(rareRes, "saoguang", true) 
            end
            local callFuc = cc.CallFunc:create(rarePlayAni)
            local sequence = cc.Sequence:create(cc.DelayTime:create(49/30),callFuc) 
            BattleCCSB.CATCH.xiyou:runAction(sequence)
        end
    end

end

function BattleUIMgr.catchPet()
    pets.petTable[0][1]:hide()
    BattleBufferUI.cleanAllPetBuffGaf(0)
    BattleBufferUI.cleanAllPetBuffGaf(1)
    --  balls.ok    = AnimationMgr.createBattlePetAni(scene,"Gaf/ball/catchOk.gaf",display.cx,display.cy-20)
    --  balls.lose  = AnimationMgr.createBattlePetAni(scene,"Gaf/ball/catchFail.gaf",display.cx,display.cy-20)
    BattleCCSB.createCatchUI(scene,currPetInfo)

    --  balls.ok:zorder(5)
    --  balls.lose:zorder(5)

    --  balls.ok:hide()
    --  balls.lose:hide()

    BattleUIMgr.setCatchPetName()

    pets.catchedMonster = pets.petTable[1][1]

    transition.stopTarget(pets.petTable[1][1])
    BattleFuncMgr.setNodeGray(pets.petTable[1][1],true)
    pets.petTable[1][1]:opacity(255)

    pets.catchedMonster:show()
    pets.catchedMonster:setPosition(display.cx,display.cy+50)
    -- local rarePoint = PokemonInfo.getPokemonInfoByID(currPetInfo[TEAM_B].pokeID).rarePoint

    CocosModuleMgr.setScreenTouch(false)
    transition.scaleTo(pets.catchedMonster, {scaleX = 0.8*-1,scaleY = 0.8, time = 0.08})
    pets.petTable[0][1]:performWithDelay(function()
        transition.scaleTo(pets.catchedMonster, {scaleX = 1*-1.3,scaleY = 1.3, time = 0.08})
        pets.petTable[0][1]:performWithDelay(function()
            CocosModuleMgr.setScreenTouch(true)
        end, 0.08)
    end, 0.08)

end

function BattleUIMgr.getcatchedMonster()
    return pets.catchedMonster
end

function BattleUIMgr.cleanBuffer(petType)
    local bufferInfo = {}
    bufferInfo = downBlood

    if petType == 1 then
        bufferInfo = upBlood
    end  
    if BattleCotroller.petBuffers[petType] then
        for key,var in pairs(BattleCotroller.petBuffers[petType]) do
            if var.sprite then
                var.sprite:removeFromParent(true)
            end
            BattleCotroller.petBuffers[petType][key] = nil
        end
        BattleBufferUI.cleanAllPetBuffGaf(petType)
    end  
    BattleCotroller.petBuffers[petType] = {}

end

function BattleUIMgr.setSixValue(mySixValue,hisSixValue)
    currPetInfo[MYPETS].bloodLimit = mySixValue[1]
    currPetInfo[MYPETS].atk        = mySixValue[2]
    currPetInfo[MYPETS].satk       = mySixValue[4]
    currPetInfo[MYPETS].speed      = mySixValue[6]
    currPetInfo[MYPETS].sdef       = mySixValue[5]
    currPetInfo[MYPETS].def        = mySixValue[3]

    if currPetInfo[MYPETS].blood > currPetInfo[MYPETS].bloodLimit then
        currPetInfo[MYPETS].blood = currPetInfo[MYPETS].bloodLimit
    end

    currPetInfo[HISPETS].bloodLimit = hisSixValue[1]
    currPetInfo[HISPETS].atk        = hisSixValue[2]
    currPetInfo[HISPETS].satk       = hisSixValue[4]
    currPetInfo[HISPETS].speed      = hisSixValue[6]
    currPetInfo[HISPETS].sdef       = hisSixValue[5]
    currPetInfo[HISPETS].def        = hisSixValue[3]

    if currPetInfo[HISPETS].blood > currPetInfo[HISPETS].bloodLimit then
        currPetInfo[HISPETS].blood = currPetInfo[HISPETS].bloodLimit
    end
end

function BattleUIMgr.getSixValue(petType)
    --values={calcHp,calcAct,calcSpeAct,calcSpeed,calcSpeDef,calcDef}
    local pokeID = 0
    pokeID = currPetInfo[petType].pokeID
    local value = {
        BattleAidFunc.normalize(currPetInfo[petType].bloodLimit),
        BattleAidFunc.normalize(currPetInfo[petType].atk),
        BattleAidFunc.normalize(currPetInfo[petType].satk),
        BattleAidFunc.normalize(currPetInfo[petType].speed),
        BattleAidFunc.normalize(currPetInfo[petType].sdef),
        BattleAidFunc.normalize(currPetInfo[petType].def),
    }
    return value,pokeID
end

function BattleUIMgr.showPassiveSkills(myPassives,hisPassives,sixValues)
    
    local rate          = 1
    local orderZ        = 3 

    if sixValues then 
        BattleUIMgr.setSixValue(sixValues[1],sixValues[2])
    end

    for key,var in pairs(downBlood.passNodes) do
        var[1]:removeFromParent()
    end

    downBlood.passNodes = {}

    for key,var in pairs(myPassives) do
        local passInfo      = downBlood
        local paCope        = nil
        local paRes = "Battle/skillIcon/"..var.icon..".png"
        local name = LuaSqlite.getLanguageByKey(var.name)
        
        local posX = passInfo.paPosX
        local posY = passInfo.paPosY + rate*40*(key-1)
        display.addImageAsync(paRes,function()
                
                paCope = passInfo.paSkill:clone()

                local pic       = paCope:getChildByName("paPic")  
                local nameStr   = paCope:getChildByName("PaName") 

                CSResourceMgr.setSpriteTextureByNode(pic, paRes)
                nameStr:setString(name)
                BattleFuncMgr.setLabelLenByNode(nameStr,100) 

                paCope:addTo(passInfo.layer)
                paCope:zorder(orderZ)
                paCope:setPosition(posX,posY)
                paCope:setVisible(true)
                paCope:setScale(0,0)

                passInfo.passNodes[#passInfo.passNodes + 1] = {paCope,var.id}
                paCope:performWithDelay(function()
                    if paCope then
                        paCope:scaleTo(0.2,1.2)
                    end
                end, 0.1*(key-1))
            end)
    end 

    rate = -1

    for key,var in pairs(upBlood.passNodes) do
        var[1]:removeFromParent()
    end
    upBlood.passNodes = {}

    for key,var in pairs(hisPassives) do
        local passInfo = upBlood
        local paRes = "Battle/skillIcon/"..var.icon..".png" 
        local name = LuaSqlite.getLanguageByKey(var.name)
        local posX = passInfo.paPosX
        local posY = passInfo.paPosY + rate*40*(key-1)
        display.addImageAsync(paRes,function()
                local paCope = passInfo.paSkill:clone()
                local pic       = paCope:getChildByName("paPic")  
                local nameStr   = paCope:getChildByName("paName")  
                CSResourceMgr.setSpriteTextureByNode(pic, paRes)
                nameStr:setString(name)
                BattleFuncMgr.setLabelLenByNode(nameStr,100) 

                paCope:addTo(passInfo.layer)
                paCope:zorder(orderZ)
                paCope:setPosition(posX,posY)
                paCope:setVisible(true)
                paCope:setScale(0,0)
                
                passInfo.passNodes[#passInfo.passNodes + 1] = {paCope,var.id}
                paCope:performWithDelay(function()
                    if paCope then 
                        paCope:scaleTo(0.2,1.2)
                    end
                end, 0.1*(key-1))
            end)
    end

    pets.petTable[0][1]:performWithDelay(function()     
        BattleCotroller.judgeNextBattle()
    end, 0.1/BattleUIMgr.speed)
end

function BattleUIMgr.checkPassiveSkills(myPassives,hisPassives,sixValues)
    local node = 1
    local id   = 2
    local orderZ        = 3

    if sixValues then 
        BattleUIMgr.setSixValue(sixValues[1],sixValues[2])
    end

    for key,var in pairs(downBlood.passNodes) do
        local isExist = false
        for k,v in pairs(myPassives) do
            if var[id] == v.id then
                isExist = true
            end
        end
        if not isExist then
            var[node]:removeFromParent()
            table.remove(downBlood.passNodes,key) 
        end
    end

    for key,var in pairs(downBlood.passNodes) do
        var[node]:moveTo(0.1,downBlood.paPosX,downBlood.paPosY + 48*(key-1) + 35) 
    end
    for key,var in pairs(myPassives) do
        local isExist = false
        for k,v in pairs(downBlood.passNodes) do
            if v[id] == var.id then
                isExist = true
            end
        end
        if not isExist then
            local passInfo      = downBlood
            local paCope        = nil
            local paRes = "Battle/skillIcon/"..var.icon..".png"
            local name = LuaSqlite.getLanguageByKey(var.name).." "..var.id%10
            
            display.addImageAsync(paRes,function()
                    if not BattleUIMgr.showSkillTip or BattleCCSB.MENU.isOut then
                        return
                    end
                    paCope = passInfo.paSkill:clone()
                    local btn = ccui.Button:create("empty.png","empty.png")
                    btn:setScale9Enabled(true)
                    btn:setContentSize(cc.size(148, 35))

                    btn:setPosition(cc.p(75,25))
                    btn:addTo(paCope)

                    CSResourceMgr.buttonEventBindingByNodeXP(btn, nil, nil, nil, function()
                        PetSkillViewMgr.hideConciseSkillInfoPage()
                    end, false, nil, function()
                        if BattleUIMgr.showSkillTip then
                            local skillInfo = PokemonInfo.getPetSkillInfoById(var.id)
                            PetSkillViewMgr.showConciseSkillInfo(skillInfo, 2, true)
                        end 
                    end)

                    local pic       = paCope:getChildByName("paPic")  
                    local nameStr   = paCope:getChildByName("PaName") 
                    CSResourceMgr.setSpriteTextureByNode(pic, paRes)
                    nameStr:setString(name)
                    BattleFuncMgr.setLabelLenByNode(nameStr,100) 
                    local posX = passInfo.paPosX
                    local posY = passInfo.paPosY + 48*(#downBlood.passNodes) + 35
                    paCope:addTo(passInfo.layer)
                    paCope:zorder(orderZ)
                    paCope:setPosition(posX,posY)
                    paCope:setVisible(true)
                    paCope:setScale(0,0)
                    paCope:setAnchorPoint(1.0,0) 

                    passInfo.passNodes[#passInfo.passNodes + 1] = {paCope,var.id}
                    paCope:performWithDelay(function()
                        if paCope then
                            paCope:scaleTo(0.2,1.2)
                        end
                    end, 0.1*(key-1))
                end)
        end 
    end

    for key,var in pairs(upBlood.passNodes) do
        local isExist = false
        for k,v in pairs(hisPassives) do
            if var[id] == v.id then
                isExist = true
            end
        end
        if not isExist then
            var[node]:removeFromParent()
            table.remove(upBlood.passNodes,key)
        end
    end

    for key,var in pairs(upBlood.passNodes) do
        var[node]:moveTo(0.1,upBlood.paPosX,upBlood.paPosY + -48*(key-1))
    end

    for key,var in pairs(hisPassives) do
        local isExist = false
        for k,v in pairs(upBlood.passNodes) do
            if v[id] == var.id then
                isExist = true
            end
        end
        if not isExist then
            local passInfo      = upBlood
            local paCope        = nil
            local paRes = "Battle/skillIcon/"..var.icon..".png"
            local name = LuaSqlite.getLanguageByKey(var.name).." "..var.id%10
            
            
            display.addImageAsync(paRes,function()
                    if not BattleUIMgr.showSkillTip or BattleCCSB.MENU.isOut then
                        return
                    end
                    
                    paCope = passInfo.paSkill:clone()

                    local btn = ccui.Button:create("empty.png","empty.png")
                    btn:setScale9Enabled(true)
                    btn:setContentSize(cc.size(148, 35))

                    btn:setPosition(cc.p(75,25))
                    btn:addTo(paCope)

                    CSResourceMgr.buttonEventBindingByNodeXP(btn, nil, nil, nil, function()
                        PetSkillViewMgr.hideConciseSkillInfoPage()
                    end, false, nil, function()
                        if BattleUIMgr.showSkillTip then
                            local skillInfo = PokemonInfo.getPetSkillInfoById(var.id)
                            PetSkillViewMgr.showConciseSkillInfo(skillInfo, 2, true)
                        end 
                    end)

                    local pic       = paCope:getChildByName("paPic")  
                    local nameStr   = paCope:getChildByName("paName") 
                    CSResourceMgr.setSpriteTextureByNode(pic, paRes)      
                    nameStr:setString(name)
                    BattleFuncMgr.setLabelLenByNode(nameStr,100) 

                    local posX = passInfo.paPosX
                    local posY = passInfo.paPosY + -48*(#passInfo.passNodes)
                    paCope:addTo(passInfo.layer)
                    paCope:zorder(orderZ)
                    paCope:setPosition(posX,posY)
                    paCope:setVisible(true)
                    paCope:setScale(0,0)

                    passInfo.passNodes[#passInfo.passNodes + 1] = {paCope,var.id}
                    paCope:performWithDelay(function()
                        if paCope then
                            paCope:scaleTo(0.2,1.2)
                        end
                    end, 0.1*(key-1))
                end)
        end 
    end

    pets.petTable[0][1]:performWithDelay(function()     
        BattleCotroller.judgeNextBattle()
    end, 0.1/BattleUIMgr.speed)

end

function BattleUIMgr.attributeStateRes(mySkillID)
    if PokemonInfo.getPetSkillInfoById(mySkillID).skill_B_Type == 5 then
        return nil
    end
    local attriValue = BattleFuncMgr.getAttributeStateValue(mySkillID,currPetInfo[1].pokeID)
    local res = ""
    if attriValue >= 1.3 then
        res = "Battle/downEdge_A/arrow2.png"
    elseif attriValue >= 1.1 then
        res = "Battle/downEdge_A/arrow2.png"
    elseif attriValue >= 1 then 
        res = "empty.png" 
    elseif attriValue >= 0.8 then
        res = "Battle/downEdge_A/arrow.png"
    else
        res = "Battle/downEdge_A/arrow.png"
    end
    return res
end

function BattleUIMgr.fightLabelStateRes(SkillID,pokeID)
    
    local attriValue = BattleFuncMgr.getAttributeStateValue(SkillID,pokeID)
    local string = ""
    if attriValue >= 1.3 then
        string = "strong"
    elseif attriValue >= 1.1 then
        string = "strong"
    elseif attriValue >= 1 then
        string = "normal" 
    elseif attriValue >= 0.8 then
        string = "weak"
    else
        string = "weak"
    end
    return string
end



function BattleUIMgr.goToContinus()
    pets.petTable[0][1]:performWithDelay(function()
            BattleCotroller.judgeNextBattle()
        end, 0.01/BattleUIMgr.speed)
end

function BattleUIMgr.startRecord()
    BattleCotroller.cloneRecord()
    BattleCotroller.setIsRecord(true)
    BattleMapMgr.enterBattleUI()
end

function BattleUIMgr.cleanUIMgr() 
    BattleFuncMgr.cleanHandles()
    energyNum = 0
    BattleUIMgr.canFight = true

    downBlood   = nil
    upBlood     = nil

    BattleUIMgr.cleanBuffer(0) 
    BattleUIMgr.cleanBuffer(1)
    
    BattleSkill.valueStore  = {}
    BattleBuffer.valueStore = {}
    if  BattleUIMgr.firstBattle ~= 0 then
        BattleUIMgr.firstBattle = 0
    end

    for key,var in pairs(BattleGuide.funcs) do    
        if key ~= GUIDE_FINISH then
            BattleGuide.funcs[key] = nil
        end
    end
    if BattleCANI.beatAni then
        BattleCANI.beatAni:removeFromParent() 
        BattleCANI.beatAni = nil
    end
    BattleCCSB.TIME.isOverTime = true
    BattleUIMgr.isAutoFight = false
    BattleCANI.cleanANI()
    BattleCCSB.cleanCSB()
    BattleWeather.cleanWeather()
end

function BattleUIMgr.assistSkillShow(id,skill,side,pokeID)

     if side == TEAM_B then
        BattleUIMgr.assistSkillShowB(id,skill,side,pokeID)
        return
    end 

    local toself = true
    local skillInfo = BattleInfo.getSkillInfoByID(skill.id)
    for i = 1,#skillInfo.tags do
        for j = 1,#skillInfo.tags[i].instance.tags do
            if "有害" == skillInfo.tags[i].instance.tags[j] then
                toself = false
            end
        end
    end

    for key,var in pairs(BattleCCSB.CARDS.inCard) do             
        if key == id then
            local sequence = transition.sequence({
                cc.RotateBy:create(0.1, -10),
                cc.RotateBy:create(0.2, 20),
                cc.RotateBy:create(0.1, -10),
                cc.ScaleTo:create(0.1, 1.45),
                cc.ScaleTo:create(0.1, 0.9),
                cc.ScaleTo:create(0.1, 1.15),
                cc.ScaleTo:create(0.1, 1),
            })
            var.button:runAction(sequence)

            local pos = var.button:convertToWorldSpace(cc.p(0,0))
            pos.x = pos.x + var.button:getContentSize().width/2
            pos.y = pos.y + var.button:getContentSize().height/2

            local effect4 = CSResourceMgr.createCCBI(SceneMgr.getRunningScene, "texture/ui_dc_14.ccbi", pos.x, pos.y)
            effect4:zorder(10)

            effect4:runAction(transition.sequence({
                cc.DelayTime:create(0.4),
                cc.CallFunc:create(function()
                    local endPos
                    
                    if toself then
                        local posheight = BattleCANI.petbody.get(skill.pokeID_A).partUD_B
                        endPos = cc.p(BattleCANI.PETS.playerPosX,BattleCANI.PETS.playerPosY+posheight)
                    else
                        local posheight = BattleCANI.petbody.get(skill.pokeID_B).partUD_B
                        endPos = cc.p(BattleCANI.PETS.enemyPosX,BattleCANI.PETS.enemyPosY+posheight)
                    end

                    local posx1 = pos.x + (endPos.x-pos.x)/4
                    local posy1 = pos.y + (endPos.y-pos.y)/4

                    local posx2 = pos.x + (endPos.x-pos.x)*3/4
                    local posy2 = pos.y + (endPos.y-pos.y)*3/4

                    local points = {
                        cc.p(posx1-100,posy1),
                        cc.p(posx2-100, posy2),
                        cc.p(endPos.x, endPos.y),
                    }

                    local points2 = {
                        cc.p(posx1+100,posy1),
                        cc.p(posx2+100, posy2),
                        cc.p(endPos.x, endPos.y),
                    }

                    local effectname = "texture/ui_dc_12b.ccbi"
                    if toself then
                        effectname = "texture/ui_dc_12r.ccbi"
                    end

                    local effect = CSResourceMgr.createCCBI(SceneMgr.getRunningScene, effectname, pos.x, pos.y)
                    effect:zorder(10)

                    local effect2 = CSResourceMgr.createCCBI(SceneMgr.getRunningScene, effectname, pos.x, pos.y)
                    effect2:zorder(10)
                    effect2:runAction(transition.sequence({
                        cc.BezierTo:create(0.4, points2),
                        cc.CallFunc:create(function()
                            effect2:removeFromParent()

                            local effect3 = CSResourceMgr.createCCBI(SceneMgr.getRunningScene, "texture/ui_dc_13.ccbi", endPos.x, endPos.y)
                            effect3:zorder(10)
                            effect3:setScale(1.2)
                            effect3:runAction(transition.sequence({
                                cc.DelayTime:create(0.4),
                                cc.CallFunc:create(function()
                                    effect3:removeFromParent()
                                end)}))
                        end)}))
                    --effect2:runAction(cc.BezierTo:create(0.4, points2))

                    local sequence2 = transition.sequence({
                        cc.BezierTo:create(0.8, points),
                        cc.CallFunc:create(function()
                            effect:removeFromParent()
                            -- effect2:stop()
                            -- effect2:removeFromParent()

                            local effect3 = CSResourceMgr.createCCBI(SceneMgr.getRunningScene, "texture/ui_dc_13.ccbi", endPos.x, endPos.y)
                            effect3:zorder(10)
                            effect3:setScale(1.2)
                            effect3:runAction(transition.sequence({
                                cc.DelayTime:create(0.4),
                                cc.CallFunc:create(function()
                                    effect3:removeFromParent()
                                end)}))
                            display.addImageAsync("Gaf/skill/helpEffect.png",function()
                                    local ani = BattleFuncMgr.createGafAni("Gaf/skill/helpEffect.gaf",SceneMgr.getRunningScene,0.5,-0.5,display.cx,display.cy-50)
                                    ani:zorder(10)
                                    if not toself then
                                        ani:setPosition(cc.p(display.cx,display.cy+300))
                                    end
                                    local function removeani()
                                        BattleCotroller.judgeNextBattle()
                                        ani:removeFromParent()
                                    end
                                    BattleFuncMgr.playGafAniWithSequenceAndCallBack(ani,"paly",false,removeani)
                                    local guang = ani:getObjectByName("guangshu_Add")

                                    local petDatInfo    = PokemonInfo.getPokemonInfoByID(pokeID)
                                    local rarePoint     = petDatInfo.rarePoint
                                    local rareRes = BattleFuncMgr.getStagePics(rarePoint)

                                    local petIconBg = display.newScale9Sprite(rareRes.p1, 250, 12, cc.size(40, 40))
                                    guang:addChild(petIconBg)

                                    local petIcon = display.newSprite("Pet/PetIcon/"..petDatInfo.icon..".png")
                                    petIcon:setPosition(cc.p(250,12))
                                    petIcon:setScale(0.3)
                                    guang:addChild(petIcon)
                                    
                                    local skillName = display.newTTFLabel({
                                        font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
                                        text = LuaSqlite.getLanguageByKey(skill.name),
                                        size = 18, 
                                        align = cc.TEXT_ALIGN_CENTER, 
                                        color = display.COLOR_WHITE
                                    })
                                    skillName:setAnchorPoint(cc.p(0,0.5))

                                    skillName:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1)

                                    skillName:setPosition(cc.p(280,11))
                                    guang:addChild(skillName)
                                end)
                            
                        
                        end),
                    })
                    effect:runAction(sequence2)
                end
            )}))
        end
    end

end

function BattleUIMgr.assistSkillShowB(id,skill,side,pokeID)

    local toself = true
    local skillInfo = BattleInfo.getSkillInfoByID(skill.id)
    for i = 1,#skillInfo.tags do
        for j = 1,#skillInfo.tags[i].instance.tags do
            if "有害" == skillInfo.tags[i].instance.tags[j] then
                toself = false
            end
        end
    end

    display.addImageAsync("Gaf/skill/helpEffect_B.png",function()
        local ani = BattleFuncMgr.createGafAni("Gaf/skill/helpEffect_B.gaf",SceneMgr.getRunningScene,0.5,-0.5,display.cx,display.cy-50)
        ani:zorder(10)
        if toself then
            ani:setPosition(cc.p(display.cx,display.cy+300))
        end
        local function removeani()
            BattleCotroller.judgeNextBattle()
            ani:removeFromParent()
        end
        BattleFuncMgr.playGafAniWithSequenceAndCallBack(ani,"paly",false,removeani)
        local guang = ani:getObjectByName("guangshu_Add")

        local petDatInfo    = PokemonInfo.getPokemonInfoByID(pokeID)
        local rarePoint     = petDatInfo.rarePoint
        local rareRes = BattleFuncMgr.getStagePics(rarePoint)

        local petIconBg = display.newScale9Sprite(rareRes.p1, 280, 12, cc.size(40, 40))
        guang:addChild(petIconBg)

        local petIcon = display.newSprite("Pet/PetIcon/"..pokeID..".png")
        petIcon:setPosition(cc.p(280,12))
        petIcon:setScale(0.3)
        guang:addChild(petIcon)
        
        local skillName = display.newTTFLabel({
            font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
            text = LuaSqlite.getLanguageByKey(skill.name),
            size = 18, 
            align = cc.TEXT_ALIGN_CENTER, 
            color = display.COLOR_WHITE
        })
        skillName:setAnchorPoint(cc.p(0,0.5))
        skillName:setScaleX(-1)

        skillName:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1)

        skillName:setPosition(cc.p(250,11))
        guang:addChild(skillName)
    end)

end

function BattleUIMgr.quiteBattle()
    if SceneMgr.currentScene ~= "BattleScene" then
        return
    end
    BattleCCSB.MENU.isOut = true
    BattleUIMgr.sendCallBK()
    BattleUIMgr.cleanUIMgr() 
    BattleMapMgr.cleanPVPInfo()
    BattlePVPMgr.cleanPVPInfo() 
    SceneMgr.mapEnterType = 99
    SceneMgr.replaceScene(SceneMgr.getRunningScene, SceneMgr.previousScene)
end

function BattleUIMgr.cleanBattleInfo()
    if SceneMgr.currentScene ~= "BattleScene" then
        return
    end
    BattleCCSB.MENU.isOut = true
    BattleUIMgr.sendCallBK()
    BattleUIMgr.cleanUIMgr() 
    BattleMapMgr.cleanPVPInfo()
    BattlePVPMgr.cleanPVPInfo() 
end

function BattleUIMgr:jumpBattle() 
    print("BattleUIMgr.showSkillTip.........",BattleUIMgr.showSkillTip)
    print("BattleCCSB.MENU.isOut.........",BattleCCSB.MENU.isOut) 
    if BattleCotroller.getIsRecord() and not BattleCotroller.getBattleResult() then
        return
    end
     if not BattleUIMgr.showSkillTip or BattleCCSB.MENU.isOut then
        print("战斗结束通知   ~~~~~~")
         return
     end

     if BattlePVPMgr.mIsPVPBattle  then
         return
     end 
     if not BattleUIMgr.jumpRound then
        StandardTipsMgr.show(1, "JumpBattle")
        return
     end
    BattleCotroller.cleanCurrentRecord()
    BattleUIMgr.isJumpBattle = true
    local result = nil
    local damageTable = nil
    if not BattleCotroller.getIsRecord() then
        result = battleMgr:jumpBattle()
        BattleCotroller.setBattleResult(result)
        local records = battleMgr:getTotalRecord() 
        BattleCotroller.setTotalRecord(records)

        -- if BattleCotroller.getCurrentBattle() then
        --     local pets = BattleCotroller.getCurrentBattle().teams[TEAM_A].pets
        --     for key,var in pairs(pets) do
        --         var:resetHp()
        --     end
        -- end

        local petOrder = battleMgr:getBattleHpResult() 
        for key,var in pairs(petInfo[MYPETS][OUTPETS]) do
            petInfo[MYPETS][OUTPETS][key].blood = petOrder[1][var.objID] 
        end

        for key,var in pairs(petInfo[HISPETS][OUTPETS]) do
            petInfo[HISPETS][OUTPETS][key].blood = petOrder[2][var.objID] 
        end

        damageTable = battleMgr:getDamageTable()
    else
        result = BattleCotroller.getBattleResult()
        if battleMgr then
            damageTable = battleMgr:getDamageTable()
        end
    end

    BattleCotroller.isPause = true  
    BattleCCSB.MENU.isOut = true   
     
    if result then
        if not damageTable or #damageTable <= 0 then
            BattleUIMgr.GameOver(result,"expShow",false) 
        else
            BattleUIMgr.GameOver(result,"damageShow",true)
        end
    end
    
end

function BattleUIMgr.playSkillShow(idx, skillType)

    local pos = cc.p(60,display.cy+35)
    if idx == 1 then
        pos = cc.p(display.width-60,display.height-128)
    end

    local node = nil
    if idx == 0 then
        if not scene.skillNodeA then
            BattleUIMgr.showSelectSkill(idx, skillType)
        end
        node = scene.skillNodeA
    else
        if not scene.skillNodeB or scene.skillNodeB.hide then
            BattleUIMgr.showSelectSkill(idx, skillType)
        end
        node = scene.skillNodeB
    end
    node:setVisible(true)
    
    node:runAction(cc.Sequence:create({
        cc.ScaleTo:create(0.1,1.2),
        cc.ScaleTo:create(0.1,1),
        cc.CallFunc:create(function()
            local skillPanel = display.newSprite("Battle/skillStage/fight_opponent_skill_base.png")
            skillPanel:setScale(0)
            if idx == 1 then
                skillPanel:setAnchorPoint(cc.p(1,0.5))
            else
                skillPanel:setAnchorPoint(cc.p(0,0.5))
            end
            skillPanel:addTo(scene) 
            skillPanel:zorder(5)
            skillPanel:setPosition(pos)

            local name     = currPetInfo[idx]["skill"][skillType].name
            local level    = currPetInfo[idx]["skill"][skillType].id%10
            local skillName = display.newTTFLabel({
                font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
                text = name.." "..level,
                size = 20, 
                align = cc.TEXT_ALIGN_CENTER, 
                color = display.COLOR_WHITE
            })

            skillName:setPosition(cc.p(94,25))
            skillPanel:addChild(skillName)

            local effect2 = CSResourceMgr.createCCBI(scene, "texture/ui_dc_20b.ccbi", pos.x, pos.y)
            effect2:zorder(9)
            effect2:runAction(cc.Sequence:create({
                cc.DelayTime:create(0.4),
                cc.CallFunc:create(function()
                    effect2:removeFromParent() 
                end)}))

            skillPanel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,1.0,1.0,0),
                cc.DelayTime:create(1.0),cc.CallFunc:create(function()
                    if idx == 0 then
                        node = scene.skillNodeA
                    else
                        node = scene.skillNodeB
                    end
                    if node then
                        node:runAction(cc.Sequence:create({
                            cc.FadeOut:create(0.1),
                            cc.CallFunc:create(function()
                                if idx == 0 then
                                    if scene.skillNodeA then
                                        scene.skillNodeA:removeFromParent()
                                        scene.skillNodeA = nil
                                    end
                                else
                                    if scene.skillNodeB then
                                        scene.skillNodeB:removeFromParent()
                                        scene.skillNodeB = nil
                                    end
                                end 
                            end)}))
                    end

                    skillPanel:runAction(cc.Sequence:create({
                        cc.FadeOut:create(0.1),
                        cc.CallFunc:create(function()
                            skillPanel:removeFromParent() 
                        end)}))
                end)))
        end)}))

end

function BattleUIMgr.showSelectSkill(idx, skillType, hide)

    if skillType > 4 then
        return
    end

    local pos = cc.p(60,display.cy+35)
    if idx == 1 then
        pos = cc.p(display.width-60,display.height-128)
    end

    local node = display.newNode()
    node:addTo(scene)
    node:zorder(6)
    node:setPosition(pos)
    node:setCascadeOpacityEnabled(true)

    if idx == 0 then
        if scene.skillNodeA then
            scene.skillNodeA:stopAllActions()
            scene.skillNodeA:removeFromParent()
        end
        scene.skillNodeA = node

        if scene.skillNodeB then
            scene.skillNodeB:setVisible(true)
        end
    else
        if scene.skillNodeB then
            scene.skillNodeB:stopAllActions()
            scene.skillNodeB:removeFromParent()
        end
        scene.skillNodeB = node
        if not hide then
            scene.skillNodeB:setVisible(false)
        end
        local delayTime = GetRandom.random(50,300)/100
        scene.skillNodeB:performWithDelay(function()
            if scene.skillNodeB then
                scene.skillNodeB:setVisible(true)
            end
        end, delayTime)
    end

    local skillIconStr ="Battle/skillIcon/"..currPetInfo[idx]["skill"][skillType].info.icon..".png"
    if hide then
        skillIconStr ="Battle/skillIcon/wenhao.png"
        if idx == 1 then
            scene.skillNodeB.hide = true
        end
    end
    if not BattleFuncMgr.isFileExist(skillIconStr) then
        skillIconStr = "Battle/skillIcon/default.png"
    end

    local airpower = currPetInfo[idx]["skill"][skillType].info.airpower
    local skillQuan = display.newSprite("Battle/skillStage/"..airpower..".png")
    skillQuan:setPosition(cc.p(0,0))
    skillQuan:setScale(0.84,0.84)
    node:addChild(skillQuan)

    local skillIcon = display.newSprite(skillIconStr)
    skillIcon:setPosition(cc.p(0,0))
    skillIcon:setScale(0.7,0.7)
    node:addChild(skillIcon)

    if not hide then
        local petIconBg = display.newSprite("Battle/petStatus/dengjiquan.png")
        petIconBg:setPosition(cc.p(0,-13))
        petIconBg:setScale(0.6)
        node:addChild(petIconBg)

        local petIcon = display.newSprite(currPetInfo[idx]["skill"][skillType].icon)
        petIcon:setScale(0.6)
        petIcon:setPosition(cc.p(0,-13))
        node:addChild(petIcon)
    end

end

function BattleUIMgr.deleteSelectedSkill(idx) 
    
    if idx == 0 then
        if scene.skillNodeA then
            scene.skillNodeA:stopAllActions()
            scene.skillNodeA:removeFromParent()
            scene.skillNodeA = nil
        end
    else
        if scene.skillNodeB then
            scene.skillNodeB:stopAllActions()
            scene.skillNodeB:removeFromParent()
            scene.skillNodeB = nil
        end
    end

end

function BattleUIMgr.playBattleFilm() 
    -- scene:moveTo(0.15,0,-75)
    pets.enemyPosY  = pets.enemyPosY - 75
    pets.playerPosY = pets.playerPosY - 75
    pets.petTable[1][1]:moveBy(0.15, 0, -75)
    pets.petTable[0][1]:setPosition(pets.playerPosX,pets.playerPosY)
    BattleCCSB.GROUNDBACK.layer:moveBy(0.15, 0, -75)
    BattleCCSB.MENU.layer:moveBy(0.15, 0, -75)
    BattleCCSB.UPBLOOD.layer:moveBy(0.15, 0, -75)
    BattleCCSB.DOWNBLOOD.layer:moveBy(0.15, 0, -75)
    BattleCCSB.DOWNEDGE.layer:hide()

    BattleCCSB.createFilmUI(scene) 

end

function BattleUIMgr.showBossEffect(callback) 
    -- local callfuc = cc.CallFunc:create(callback)
    local r = 2.0
    pets.petTable[1][1]:setPosition(display.cx,display.cy-200)
    local bossScale = pets.PET_SIZE_A+r-1

    BattleCCSB.DOWNBLOOD.layer:fadeOut(0.2)
    BattleCCSB.UPBLOOD.layer:fadeOut(0.2)
    BattleCCSB.DOWNEDGE.layer:hide()

    BattleCCSB.MENU.speed:hide()
    BattleCCSB.MENU.autoLabel:hide()
    BattleCCSB.MENU.pauseBtn:hide()
    BattleCCSB.MENU.auto:hide()
    local jumpText = BattleCCSB.MENU.layer:getChildByName("jump")
    jumpText:hide()
    for skillIndex = 2, 3 do
        if BattleCANI.oilSkillsFlip[skillIndex] then
            BattleCANI.oilSkillsFlip[skillIndex]:hide()
        end
    end
    local function teamAenterBattle()
        for skillIndex = 2, 3 do
            if BattleCANI.oilSkillsFlip[skillIndex] then
                BattleCANI.oilSkillsFlip[skillIndex]:show()
            end
        end
        
        BattleCCSB.DOWNBLOOD.layer:fadeIn(0.2) 
        BattleCCSB.UPBLOOD.layer:fadeIn(0.2)
        -- BattleCCSB.DOWNEDGE.layer:show() 
        if BattleMapMgr.getIsFilm() then
            BattleUIMgr.playBattleFilm()
        else
            BattleCCSB.MENU.autoLabel:show()
            BattleCCSB.MENU.pauseBtn:show() 
            BattleCCSB.MENU.auto:show()
            BattleCCSB.DOWNEDGE.layer:show() 
        end

        BattleUIMgr.enterBattle(0,pets.petTable[0][1],false,true,nil) 
        BattleCANI.bossBroundBack(function()
                BattleCotroller.judgeNextBattle() 
            end)
    end

    transition.scaleTo(BattleCCSB.GROUNDBACK.layer,{scaleX = r,
        scaleY = r,time = 0.15,
        onComplete = function()
            local bossScaleTo = cc.ScaleTo:create(14/24, -1*bossScale,bossScale)
            local appearSequence = cc.Sequence:create(cc.DelayTime:create(22/24),bossScaleTo)

            pets.petTable[1][1]:runAction(appearSequence)
            local black = display.newScale9Sprite("point.png")
            black:setContentSize(cc.size(640, 1136))
            black:addTo(scene)
            black:setPosition(320,480)
            black:opacity(150)
            black:zorder(0) 
            BattleCANI.bossAppear(function()
                    pets.petTable[1][1]:moveTo(0.15, pets.enemyPosX, pets.enemyPosY) 
                    transition.scaleTo(pets.petTable[1][1],{scaleX = -1*pets.PET_SIZE_A,scaleY =  pets.PET_SIZE_A,time = 0.15})
                    BattleCCSB.GROUNDBACK.layer:scaleTo(0.15,1.0)
                    black:removeFromParent(true)
                    local callfunc = cc.CallFunc:create(teamAenterBattle)
                    local sequence = cc.Sequence:create(cc.DelayTime:create(0.15),callfunc)
                    pets.petTable[0][1]:runAction(sequence)
                end)
            
        end})

end

function BattleUIMgr.showTeammateDamage(fashionInfo, name, damage)
    
    if BattleCCSB.MENU.isOut then 
        return
    end
    
    local dashow = 1
    if not scene.dashow1 then
        scene.dashow1 = 1
        dashow = 0
    elseif not scene.dashow2 then
        scene.dashow2 = 1
        dashow = 1
    else
        return
    end

    local node = display.newNode()
    node:addTo(scene)
    node:zorder(6)
    node:setPosition(cc.p(-180,display.height-260-dashow*80))
    node:setCascadeOpacityEnabled(true)

    local bg = display.newSprite("Battle/fight_teammate_info_base.png")
    bg:setPosition(cc.p(0,0))
    node:addChild(bg)

    local headIcon = display.newSprite(CharInfo.getHeadIcon(fashionInfo))
    headIcon:setPosition(cc.p(-145,5))
    headIcon:setScale(0.65)
    node:addChild(headIcon)

    local name = display.newTTFLabel({
        font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
        text = name,
        size = 18, 
        align = cc.TEXT_ALIGN_CENTER, 
        color = display.COLOR_WHITE
    })
    name:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1)
    name:setPosition(cc.p(-40,32))
    node:addChild(name)

    local des = display.newTTFLabel({
        font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
        text = LuaSqlite.getLanguageByKey("strongatk"),
        size = 18, 
        align = cc.TEXT_ALIGN_CENTER, 
        color = cc.c3b(255, 192, 0)
    })
    des:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1)
    des:setPosition(cc.p(19,-3))
    node:addChild(des)

    local damage = display.newTTFLabel({
        font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
        text = damage,
        size = 22, 
        align = cc.TEXT_ALIGN_CENTER, 
        color = cc.c3b(255, 61, 1)
    })
    damage:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1)
    damage:setPosition(cc.p(66,-3))
    node:addChild(damage)

    node:runAction(cc.Sequence:create({
        cc.MoveBy:create(0.1,cc.p(372,0)),
        cc.MoveBy:create(0.1,cc.p(-12,0)),
        cc.DelayTime:create(0.8),
        cc.FadeOut:create(0.3),
        cc.CallFunc:create(function()
            node:removeFromParent()
            if dashow == 0 then
                scene.dashow1 = nil
            else
                scene.dashow2 = nil
            end
        end)}))
end

function BattleUIMgr.showBossBattleDamage(parent, damage, state, restraint)

    local head = nil
    local label = nil

    local function runLabel()  
        local node = display.newNode()
        if state == 1 then
            node.type = "normal"
        elseif state == 2 then
            node.type = "strong"
        elseif state == 3 then
            node.type = "weak"
        end
        if label then
            for i=1,math.floor(math.log10(damage) + 1) do
                local sprite = label:getChildByTag(i-1)
                if i == 2 then
                    sprite:setPositionY(sprite:getPositionY()-4)
                end
                sprite:setPositionX(sprite:getPositionX()-8*(i-1))
            end
        end
        if head and label then
            head:setPositionX(-label:getContentSize().width*1.3/2)
            node:addChild(head)
            label:setPositionX(head:getContentSize().width/2)
            node:addChild(label)
            node.head = head
            node.label = label          
        elseif label then
            node:addChild(label)
            node.label = label
        end

        node:addTo(parent)
        node:setPositionY(75)
        node:setScale(-0.6, 0.6)
        
        node:zorder(BMFONT_ZORDER)

        BattleFuncMgr.fightLabelShow(node,function()
            node:removeFromParent()
        end)
    end

    if state == 1 then
        display.addImageAsync("Battle/battleLabel/battle_number_crit_0.png",function()
                label = cc.LabelBMFont:create(damage,"Battle/battleLabel/battle_number_crit.fnt")
                runLabel()
            end)
    elseif state == 2 then
        display.addImageAsync("Battle/battleLabel/battle_number_restraint_0.png",function()
                display.addImageAsync(CocosModuleMgr.getWordImage("strong.png"),function()
                        head = display.newSprite(CocosModuleMgr.getWordImage("strong.png"))
                        label = cc.LabelBMFont:create(damage,"Battle/battleLabel/battle_number_restraint.fnt")
                        runLabel()
                    end)
            end)
    else
        display.addImageAsync("Battle/battleLabel/battle_number_restrainted_0.png",function()
                display.addImageAsync(CocosModuleMgr.getWordImage("weak.png"),function()
                    head = display.newSprite(CocosModuleMgr.getWordImage("weak.png"))
                    label = cc.LabelBMFont:create(damage,"Battle/battleLabel/battle_number_restrainted.fnt")
                    runLabel()
                end)
            end)
    end

    if restraint > 1 then
        BattleUIMgr.playComboEffect(restraint)
    end

end

function BattleUIMgr.showBossAttackDamage(node,damage,endFunc)
    local label = display.newTTFLabel({
        font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
        text = "-"..damage,
        size = 40, 
        align = cc.TEXT_ALIGN_CENTER, 
        color = cc.c3b(255, 61, 1)
    })
    label:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1)
    label:setPosition(cc.p(50,150))
    label:setGlobalZOrder(100)
    node:addChild(label)

    local move     = cc.MoveBy:create(0.85,cc.p(0,150))
    local wait     = cc.DelayTime:create(0.5)
    local fade      = cc.FadeOut:create(0.35)

    label:runAction(transition.sequence({
        cc.Spawn:create(move,cc.Sequence:create(wait,fade)), cc.CallFunc:create(function()
            label:removeFromParent()
            if endFunc then
                endFunc()
            end
        end)
    }))

    if node then
        node:runAction(transition.sequence({
            cc.CallFunc:create(function()
                if PlayerAnimeMgr.playerTable["copy_player_"..node:getTag()] then
                    local vec = PlayerAnimeMgr.playerTable["copy_player_"..node:getTag()].spineobj
                    for key, var in pairs(vec) do
                        var:setColor({r=255,g=188,b=188})
                    end
                end
            end),
            cc.DelayTime:create(0.6),
            cc.CallFunc:create(function()
                if PlayerAnimeMgr.playerTable["copy_player_"..node:getTag()] then
                    local vec = PlayerAnimeMgr.playerTable["copy_player_"..node:getTag()].spineobj
                    for key, var in pairs(vec) do
                        var:setColor({r=255,g=255,b=255})
                    end
                end
            end),
            cc.DelayTime:create(0.1),
            cc.CallFunc:create(function()
                if PlayerAnimeMgr.playerTable["copy_player_"..node:getTag()] then
                    local vec = PlayerAnimeMgr.playerTable["copy_player_"..node:getTag()].spineobj
                    for key, var in pairs(vec) do
                        var:setColor({r=255,g=188,b=188})
                    end
                end
            end),
            cc.DelayTime:create(0.6),
            cc.CallFunc:create(function()
                if PlayerAnimeMgr.playerTable["copy_player_"..node:getTag()] then
                    local vec = PlayerAnimeMgr.playerTable["copy_player_"..node:getTag()].spineobj
                    for key, var in pairs(vec) do
                        var:setColor({r=255,g=255,b=255})
                    end
                end
            end),
            cc.DelayTime:create(0.1),
            cc.CallFunc:create(function()
                if PlayerAnimeMgr.playerTable["copy_player_"..node:getTag()] then
                    local vec = PlayerAnimeMgr.playerTable["copy_player_"..node:getTag()].spineobj
                    for key, var in pairs(vec) do
                        var:setColor({r=255,g=188,b=188})
                    end
                end
            end),
            cc.DelayTime:create(0.6),
            cc.CallFunc:create(function()
                if PlayerAnimeMgr.playerTable["copy_player_"..node:getTag()] then
                    local vec = PlayerAnimeMgr.playerTable["copy_player_"..node:getTag()].spineobj
                    for key, var in pairs(vec) do
                        var:setColor({r=255,g=255,b=255})
                    end
                end
            end),
        }))
    end

end

function BattleUIMgr.playBall(state, index)

    if index == nil then
        return
    end

    local res = {"Gaf/bossEffect/cast_red.gaf", "Gaf/bossEffect/cast_green.gaf", "Gaf/bossEffect/cast_blue.gaf"}

    local node = BossMapMgr.getBossNode()
    local posx = display.cx - 180
    posx = posx + index*96
    BattleUIMgr.ballCastAnim = BattleFuncMgr.createGafAni(res[state],node:getParent(),0.5,-0.5,posx,200)
    BattleUIMgr.ballCastAnim:zorder(1000)
    BattleFuncMgr.playGafAniWithSequenceAndCallBack(BattleUIMgr.ballCastAnim,"Play",false)

    local layer = CSResourceMgr.createRes(node:getParent(), "Scene/CommonShade.csb", "BattleUIMgr.playBall")
    layer:zorder(999)
    CSResourceMgr.setButtonEnabled(layer.res, "mask", false, layer.tag)
    CSResourceMgr.getNodeByName(layer.res, "mask", layer.tag):setOpacity(155)
    local action = transition.sequence({
        cc.FadeIn:create(0.5),
        cc.DelayTime:create(0.5),
        cc.FadeOut:create(0.5),
        cc.CallFunc:create(function()
            CSResourceMgr.removeCSObjectByTag(layer.res, layer.tag)
        end)
    })
    layer:runAction(action)
end

function BattleUIMgr.cancelBall()

    if BattleUIMgr.ballCastAnim then
        BattleUIMgr.ballCastAnim:removeFromParent()
        BattleUIMgr.ballCastAnim = nil
    end

end

function BattleUIMgr.playBallSucess(state, index, callFuc)

    BattleUIMgr.cancelBall()

    if index == nil then
        return
    end
    local resTable =  {"texture/gw_d0102a.ccbi","texture/gw_d0103a.ccbi","texture/gw_d0101a.ccbi"}
    --local resTable2 =  {"texture/gw_d0102b.ccbi","texture/gw_d0103b.ccbi","texture/gw_d0101b.ccbi"}
    local resTable2 =  {"texture/gw_d0105b.ccbi","texture/gw_d0104b.ccbi","texture/gw_d0106b.ccbi"}
    local res = resTable[state]
    local res2 = resTable2[state]

    local node = BossMapMgr.getBossNode()

    local pos = {x = node:getPositionX(),y = node:getPositionY()+200}

    local posx = display.cx - 180
    posx = posx + index*96
    local effect = CSResourceMgr.createCCBI(node:getParent(), res, posx, 200)
    effect:setScale(1.5)
    effect:zorder(1000)

    effect:runAction(transition.sequence({
        cc.MoveTo:create(0.2, pos),
        cc.CallFunc:create(function()
            effect:removeFromParent()

            if node then
                node:runAction(transition.sequence({
                    cc.CallFunc:create(function()
                        CocosModuleMgr.lightenNode(node, 1)
                    end),
                    cc.DelayTime:create(0.2),
                    cc.CallFunc:create(function()
                        CocosModuleMgr.lightenNode(node, 0)
                    end)}))
            end

            local effect2 = CSResourceMgr.createCCBI(node:getParent(), res2, pos.x, pos.y)
            effect2:setScale(1.5)
            effect2:zorder(100)
            effect2:runAction(transition.sequence({
                cc.DelayTime:create(0.4),
                cc.CallFunc:create(function()
                    effect2:removeFromParent()
                    if callFuc then
                        callFuc()
                    end 
                end
            )}))
        end
    )}))

end

function BattleUIMgr.playBallFail(state, index)

    BattleUIMgr.cancelBall()

    if index == nil then
        return
    end

    local res = {"Gaf/bossEffect/fail_red.gaf", "Gaf/bossEffect/fail_green.gaf", "Gaf/bossEffect/fail_blue.gaf"}

    local node = BossMapMgr.getBossNode()

    local posx = display.cx - 27 - 180
    posx = posx + index*96
    local ani = BattleFuncMgr.createGafAni(res[state],node:getParent(),0.5,-0.5,posx,135)
    ani:zorder(1000)
    BattleFuncMgr.playGafAniWithSequenceAndCallBack(ani,"Play",false)

    ani:runAction(transition.sequence({
        cc.DelayTime:create(0.4),
        cc.CallFunc:create(function()
            ani:removeFromParent()
        end
    )}))

end

function BattleUIMgr.playPlayerBall(node)
    local nodeBoss = BossMapMgr.getBossNode()
    if not nodeBoss then
        return
    end
    
    local pos = {x = node:getPositionX(),y = node:getPositionY()}
    local endPos = {x = nodeBoss:getPositionX(),y = nodeBoss:getPositionY()+200}

    local idx = GetRandom.random(1,3)
    local resTable =  {"texture/gw_d0104a.ccbi","texture/gw_d0105a.ccbi","texture/gw_d0106a.ccbi"}
    local resTable2 =  {"texture/gw_d0104b.ccbi","texture/gw_d0105b.ccbi","texture/gw_d0106b.ccbi"}
    local res = resTable[idx]
    local res2 = resTable2[idx]

    local effect = CSResourceMgr.createCCBI(node:getParent(), res, pos.x, pos.y)
    effect:zorder(100)

    local dis = math.sqrt((endPos.x-pos.x)*(endPos.x-pos.x) + (endPos.y-pos.y)*(endPos.y-pos.y))

    effect:runAction(transition.sequence({
        cc.MoveTo:create(dis/1000, endPos),
        cc.CallFunc:create(function()
            effect:removeFromParent()
            if SceneMgr.currentScene == "BossMapScene" then
                nodeBoss:runAction(transition.sequence({
                    cc.CallFunc:create(function()
                        CocosModuleMgr.lightenNode(nodeBoss, 1)
                    end),
                    cc.DelayTime:create(0.2),
                    cc.CallFunc:create(function()
                        CocosModuleMgr.lightenNode(nodeBoss, 0)
                    end)}))
            end
            local effect2 = CSResourceMgr.createCCBI(node:getParent(), res2, endPos.x, endPos.y)
            effect2:zorder(100)
            effect2:runAction(transition.sequence({
                cc.DelayTime:create(0.4),
                cc.CallFunc:create(function()
                    effect2:removeFromParent()
                end
            )}))
        end
    )}))

end

function BattleUIMgr.addBossEffect(anim, node, isBoss)

    local pos = cc.p(100,-20)
    local addNode = node
    local skillScale = anim.scale or 1 
    if anim.grid then
        addNode = node:getParent():getParent()
        pos = cc.p(node:getPositionX()+node:getParent():getPositionX()+node:getParent():getParent():getPositionX(),
            node:getPositionY()+node:getParent():getPositionY()+node:getParent():getParent():getPositionY())
    end
    BattleFuncMgr.setGafFrameAndEvent(anim.name)

    pos.x = pos.x + (anim.posX or 0)
    pos.y = pos.y + (anim.posY or 0)

    local gafObjc = BattleFuncMgr.createGafAni(anim.name,addNode,0.5,-0.5,pos.x,pos.y)
    if not anim.grid then
        gafObjc:setScaleX(-1*skillScale)
    else
        gafObjc:setScaleX(skillScale)
    end
    gafObjc:setScaleY(skillScale)
    gafObjc:setLocalZOrder(100)
    gafObjc:setVisible(false)
    if node.anim == nil then
        node.anim = {}
    end
    node.anim[anim.name] = gafObjc
    
end

function BattleUIMgr.playBossEffect(res, node, callQuick, callFuc)
    if BattleUIMgr.SkillSoundEffect[res] then
        GameAudio.playBattleSound(BattleUIMgr.SkillSoundEffect[res])
    end
    local gafObjc = node.anim[res]
    gafObjc:setVisible(true)
    gafObjc:performWithDelay(function()
        if callQuick then
            callQuick()
        end
    end,0.1)
    BattleFuncMgr.skillTriggerEventHandler(res,gafObjc,function(info)
        if BossBattleMgr.shake then
            local rootNode = BossMapMgr.getMapRootNode()
            if rootNode then
                BattleFuncMgr.shakeScreen(rootNode)
            end
            BossBattleMgr.shake = false
        end
    end,
    function()
        if SceneMgr.currentScene == "BossMapScene" then
            gafObjc:setVisible(false)
        end
        if callFuc then
            callFuc()
        end
    end)
    
end

function BattleUIMgr.playBossEffectByLoop(res,node,callFuc,isbool,lastTime)
    if BattleUIMgr.SkillSoundEffect[res] then
        GameAudio.playBattleSound(BattleUIMgr.SkillSoundEffect[res])
    end
    local gafObjc = node.anim[res]

    if not isbool then
        gafObjc:performWithDelay(function()
            if callFuc then
                callFuc()
            end
            if lastTime <= 0 then
                gafObjc:stop()
                gafObjc:setVisible(false)
            end
        end,1.0)
        return 
    end
    
    gafObjc:start()
    gafObjc:gotoAndPlay(0)
    gafObjc:setVisible(true)
    gafObjc:setLooped(true)
    gafObjc:performWithDelay(function()
        if callFuc then
            callFuc()
        end
        if lastTime <= 0 then
            gafObjc:stop()
            gafObjc:setVisible(false)
        end
    end,1.0)
end

function BattleUIMgr.addBossSceneEffect(res, node, pos, zorder)

    local ani = BattleFuncMgr.createGafAni(res,node,0.5,-0.5,pos.x,pos.y)
    if zorder then
        ani:zorder(zorder)
    end
    BattleFuncMgr.playGafAniWithSequenceAndCallBack(ani,"Play",true)

end

function BattleUIMgr.playComboEffect(restraint)

    local nodeBoss = BossMapMgr.getBossNode()
    if not nodeBoss then
        return
    end

    local combo = restraint - 1
    local node = display.newNode()
    node:addTo(nodeBoss)
    node:setPosition(200,170)
    node:zorder(10)
    node:setScale(-0.7,0.7)
    local bg = display.newSprite("Battle/worldboss/combo.png")
    bg:addTo(node)
    bg:setScale(0)
    if combo > 10 then
        local num1 = math.floor(combo/10)
        local num2 = combo%10
        local numbg1 = display.newSprite("Battle/worldboss/"..num1..".png")
        numbg1:addTo(bg)
        numbg1:setPositionX(175+68/2)
        numbg1:setPositionY(50)
        local numbg2 = display.newSprite("Battle/worldboss/"..num2..".png")
        numbg2:addTo(bg)
        numbg2:setPositionX(175+68/2+68)
        numbg2:setPositionY(60)
    else
        local numbg = display.newSprite("Battle/worldboss/"..combo..".png")
        numbg:addTo(bg)
        numbg:setPositionX(175+68/2)
        numbg:setPositionY(50)
    end

    bg:runAction(transition.sequence({
        cc.ScaleTo:create(0.15,1.4,1.4,0),
        cc.ScaleTo:create(0.1,1.0,1.0,0),
        cc.DelayTime:create(0.4)}))

    local bg2 = display.newSprite("Battle/worldboss/lianxu.png")
    bg2:addTo(node)
    bg2:setPositionY(-64/2-36/2)
    bg2:setScale(0)

    local value = 1.5+combo*0.5
    local value2 = math.floor(value)
    local value3 = (value*10)%10
    if value3 == 5 then
        if value2 > 10 then
            local num1 = math.floor(value2/10)
            local num2 = value2%10
            local numbg1 = display.newSprite("Battle/worldboss/0"..num1..".png")
            numbg1:addTo(bg2)
            numbg1:setPositionX(108/2+24/2+49)
            numbg1:setPositionY(64/2-36/2+15)
            local numbg2 = display.newSprite("Battle/worldboss/0"..num2..".png")
            numbg2:addTo(bg2)
            numbg2:setPositionX(108/2+24/2+24+49)
            numbg2:setPositionY(64/2-36/2+19)
            local numbg3 = display.newSprite("Battle/worldboss/biaodian.png")
            numbg3:addTo(bg2)
            numbg3:setPositionX(108/2+24/2+24*2+49-5)
            numbg3:setPositionY(64/2-36/2+23)
            local numbg4 = display.newSprite("Battle/worldboss/0"..value3..".png")
            numbg4:addTo(bg2)
            numbg4:setPositionX(108/2+24/2+24*3+49-10)
            numbg4:setPositionY(64/2-36/2+27)
        else
            local numbg = display.newSprite("Battle/worldboss/0"..value2..".png")
            numbg:addTo(bg2)
            numbg:setPositionX(108/2+24/2+49)
            numbg:setPositionY(64/2-36/2+15)
            local numbg3 = display.newSprite("Battle/worldboss/biaodian.png")
            numbg3:addTo(bg2)
            numbg3:setPositionX(108/2+24/2+24+49-5)
            numbg3:setPositionY(64/2-36/2+19)
            local numbg4 = display.newSprite("Battle/worldboss/0"..value3..".png")
            numbg4:addTo(bg2)
            numbg4:setPositionX(108/2+24/2+24*2+49-10)
            numbg4:setPositionY(64/2-36/2+23)
        end
    else
        if value2 > 10 then
            local num1 = math.floor(value2/10)
            local num2 = value2%10
            local numbg1 = display.newSprite("Battle/worldboss/0"..num1..".png")
            numbg1:addTo(bg2)
            numbg1:setPositionX(108/2+24/2+49)
            numbg1:setPositionY(64/2-36/2+15)
            local numbg2 = display.newSprite("Battle/worldboss/0"..num2..".png")
            numbg2:addTo(bg2)
            numbg2:setPositionX(108/2+24/2+24+49)
            numbg2:setPositionY(64/2-36/2+19)
        else
            local numbg = display.newSprite("Battle/worldboss/0"..value2..".png")
            numbg:addTo(bg2)
            numbg:setPositionX(108/2+24/2+49)
            numbg:setPositionY(64/2-36/2+15)
        end
    end

    bg2:runAction(transition.sequence({
        cc.DelayTime:create(0.2),
        cc.ScaleTo:create(0.15,1.4,1.4,0),
        cc.ScaleTo:create(0.1,1.0,1.0,0),
        cc.DelayTime:create(0.4),
        cc.CallFunc:create(function()
           node:removeFromParent()
        end)}))

end

return BattleUIMgr