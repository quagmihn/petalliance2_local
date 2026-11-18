local BattleGetPetInfo  = require("src.GameMgr.Battle.BattleGetPetInfo")
local BattleCotroller   = require("src.GameMgr.Battle.BattleCotroller")
local PetFeedViewMgr    = require("src.GameMgr.Pet.PetFeedViewMgr")
local BattleWeather     = require("src.GameMgr.Battle.BattleWeather")
local BattleLangDB      = require("src.GameMgr.Battle.UI.BattleLangDB") 

local BattleCCSB        = {}
BattleCCSB.DOWNEDGE     = {}
BattleCCSB.UPBLOOD      = {}
BattleCCSB.DOWNBLOOD    = {}
BattleCCSB.GROUNDBACK   = {}
BattleCCSB.CARDS        = {}
BattleCCSB.TIME         = {}
BattleCCSB.PVSE         = {}
BattleCCSB.WIN          = {}
BattleCCSB.LOSE         = {}
BattleCCSB.CATCH        = {}
BattleCCSB.MENU         = {}
BattleCCSB.isStopAction = false
---BattleCCSB.GROUNDBACK    zOrder 0 
---BattleCCSB.UPBLOOD       zOrder 8
---BattleCCSB.DOWNBLOOD     zOrder 8
---BattleCCSB.DOWNEDGE      zOrder 9
---BattleCCSB.TIME          zOrder 7
---funcMenu                 zOrder 9
---catchOrderZ              zOrder 7
---winCCSB                  zOrder 10



local numberColor       = {r = 40,g = 40,b = 40, a = 255}    -- 数字色
local nameColor         = {r = 0,g = 0,b = 0, a = 255}       --名字色
local proSkillLineColor = {r = 38,g = 21,b = 0, a = 255}     --技能字描边
local proSkillColor     = {r = 254,g = 243,b = 57, a = 255}  
local autoLineColor     = {r = 89,g = 41,b = 0, a = 255}
local autoColor         = {r = 255,g = 255,b = 41, a = 255}
local continueLineColor = {r = 96,g = 48,b = 5, a = 255}
local continueColor     = {r = 253,g = 224,b = 53, a = 255}
local buffInfoColor     = {r = 161,g = 230,b = 232, a = 255}

local PetStageInfo = {}
--local PetStageInfoData = {}
local downEdgeOrderZ    = 9
local downBloodOrderZ   = 8
local timeOrderZ        = 7
local groundOrderZ      = -1
local upBloodOrderZ     = 8 
local funcMenuOrderZ    = 9
local catchOrderZ       = 7
local winOrderZ         = 10
local stopAuto          = false
local stopQuit          = false
local ballOrder = {2,3,1} 
-- local ballRes   = {
--                     "Item/ItemIcon/ball_normal.png",
--                     "Item/ItemIcon/ball_high.png",
--                     "Item/ItemIcon/ball_top.png"
--                 }
local ballGafRes = {
    {"Gaf/ball/catchB_Ok.gaf","Gaf/ball/catchB_Fail.gaf"},
    {"Gaf/ball/catchOk.gaf","Gaf/ball/catchFail.gaf"},
    {"Gaf/ball/catchG_Ok.gaf","Gaf/ball/catchG_Fail.gaf"},
}
local addBtnRes = "Battle/catch/cwsx_tianjia_nomal_04.png"

BattleCCSB.hpColors          = {
    {r = 255,g = 0,b = 0, a = 255},
    {r = 0,g = 255,b = 12, a = 255}
}

BattleCCSB.showOneSix = 0

function BattleCCSB.init()
    BattleCCSB.DOWNEDGE     = {}
    BattleCCSB.GROUNDBACK   = {}
    BattleCCSB.PETCARDS     = {}
    BattleCCSB.TIME         = {}
    BattleCCSB.DOWNBLOOD    = {}
    BattleCCSB.UPBLOOD      = {}
    BattleCCSB.PVSE         = {}
    BattleCCSB.WIN          = {}
    BattleCCSB.LOSE         = {}
    BattleCCSB.CATCH        = {}
    BattleCCSB.MENU         = {}

    BattleCCSB.isStopAction = false

    BattleCCSB.showOneSix = 0
end

function BattleCCSB.createGroundback(parent)
    BattleCCSB.GROUNDBACK.res        = "Battle/battleScene/backGround.csb"
    BattleCCSB.GROUNDBACK.layer      = CSResourceMgr.createRes(parent,BattleCCSB.GROUNDBACK.res)
    BattleCCSB.GROUNDBACK.bg         = CSResourceMgr.getNodeByName(BattleCCSB.GROUNDBACK.res,"bg")
    BattleCCSB.GROUNDBACK.blackBg    = CSResourceMgr.getNodeByName(BattleCCSB.GROUNDBACK.res,"blackbg")

    BattleCCSB.GROUNDBACK.blackBg:setAnchorPoint(0.5,1)
    BattleCCSB.GROUNDBACK.blackBg:setPosition(320,970)  
    BattleCCSB.GROUNDBACK.bg:setAnchorPoint(1.0,1.0) 
    BattleCCSB.GROUNDBACK.bg:setPosition(640,1048) 
    BattleCCSB.GROUNDBACK.bg:setScale(1.0,1.0)  

    -- CSResourceMgr.setRelativePosition(BattleCCSB.GROUNDBACK.res,320,480) 
    -- CocosModuleMgr.setEdgeDistance(BattleCCSB.GROUNDBACK.layer, nil, nil, 60, nil, false)

    BattleCCSB.GROUNDBACK.layer:setLocalZOrder(groundOrderZ)  
    BattleCCSB.GROUNDBACK.layer:setAnchorPoint(1.0,1.0)
    BattleCCSB.GROUNDBACK.layer:setPosition(display.width,display.height)   
    
    BattleCCSB.GROUNDBACK.blackBg:opacity(0)  
    BattleCCSB.GROUNDBACK.blackBg:setScale(22.5,22.5)    
    local randomBK = 2
    if BattleMapMgr.getField() then 
        randomBK = BattleMapMgr.getField()
    end
    local groundRes = "Battle/backGround/"..randomBK..".png"
    if not BattleFuncMgr.isFileExist(groundRes) then
        groundRes = "Battle/backGround/1.png"
    end
    display.addImageAsync(groundRes,function()
        BattleCCSB.GROUNDBACK.bg:loadTexture(groundRes)
    end)
end

function BattleCCSB.stopQuitBattle()
     stopQuit = true
end

function BattleCCSB.stopAutoBattle(isbool) 
    BattleUIMgr.isAutoFight = isbool

    UserSettings.set({BattleIsAuto = BattleUIMgr.isAutoFight})

    stopAuto = true

end

function BattleCCSB.createFilmUI(parent)
    BattleCCSB.MENU.speed:hide()
    BattleCCSB.MENU.autoLabel:hide()
    BattleCCSB.MENU.pauseBtn:hide()
    BattleCCSB.MENU.auto:hide()
    local jumpText = BattleCCSB.MENU.layer:getChildByName("jump")
    jumpText:hide()
    -- local function createUp()
        local Upres           = "Battle/filmDownEdge/filmUpEdge.csb"
        local Uplayer         = CSResourceMgr.createRes(parent,Upres) 
        CSResourceMgr.setRelativePosition(Upres,320,480)
        CocosModuleMgr.setEdgeDistance(Uplayer, nil, nil, 0, nil, false)
        Uplayer:zorder(10)
    -- end
    -- local function createDown()
        local Downres           = "Battle/filmDownEdge/filmDownEdge.csb"
        local Downlayer         = CSResourceMgr.createRes(parent,Downres) 
        local text              = CSResourceMgr.getNodeByName(Downres,"text")
        local textStr           = LuaSqlite.getLanguageByKey("demoFight1") 
        text:setString(textStr)
        CSResourceMgr.setRelativePosition(Downres,320,480)
        CocosModuleMgr.setEdgeDistance(Downlayer, nil, nil, nil, 30, false)
        Downlayer:zorder(10)
    -- end
end

function BattleCCSB.createFuncMenu(parent)
    BattleCCSB.MENU.res           = "Battle/funcMenu/funcMenu.csb"
    BattleCCSB.MENU.layer         = CSResourceMgr.createRes(parent,BattleCCSB.MENU.res) 

    BattleCCSB.MENU.contiLabel    = CSResourceMgr.getNodeByName(BattleCCSB.MENU.res,"contiLabel")
    BattleCCSB.MENU.autoLabel     = CSResourceMgr.getNodeByName(BattleCCSB.MENU.res,"autoLabel")
    BattleCCSB.MENU.pauseBtn      = CSResourceMgr.getNodeByName(BattleCCSB.MENU.res,"pause")
    BattleCCSB.MENU.speed         = CSResourceMgr.getNodeByName(BattleCCSB.MENU.res,"speed")
    BattleCCSB.MENU.speedExtra    = CSResourceMgr.getNodeByName(BattleCCSB.MENU.res,"speedExtra")
    BattleCCSB.MENU.auto          = CSResourceMgr.getNodeByName(BattleCCSB.MENU.res,"auto")
    BattleCCSB.MENU.continueBtn   = CSResourceMgr.getNodeByName(BattleCCSB.MENU.res,"continue")
    BattleCCSB.MENU.pauseBK       = CSResourceMgr.getNodeByName(BattleCCSB.MENU.res,"pauseBK")
    BattleCCSB.MENU.giveupBtn     = CSResourceMgr.getNodeByName(BattleCCSB.MENU.res,"giveup")
    BattleCCSB.MENU.sure          = CSResourceMgr.getNodeByName(BattleCCSB.MENU.res,"sure")
    BattleCCSB.MENU.isOut         = false

    local jumpText                = CSResourceMgr.getNodeByName(BattleCCSB.MENU.res,"jump")

    local isSpeed   =   UserSettings.get("battSpeed")

    if isSpeed then
        local speed2Str = "Battle/funcMenu/fight_menu_accelerate_x2.png"
        cc.Director:getInstance():getScheduler():setTimeScale(2.0) 
        CSResourceMgr.setButtonTextureByNode(BattleCCSB.MENU.speedExtra,speed2Str,speed2Str,speed2Str)
    end

    BattleCCSB.MENU.jumpRound = display.newTTFLabel({
        font = "cuyuan_GBK.ttf",
        text = 10,
        size = 36, 
        align = cc.TEXT_ALIGN_CENTER, 
        color = display.COLOR_RED
    })
    BattleCCSB.MENU.jumpRound:enableOutline({r = 0,g = 0,b = 0, a = 255}, 2)
    BattleCCSB.MENU.jumpRound:addTo(BattleCCSB.MENU.speed)
    BattleCCSB.MENU.jumpRound:setPosition(33,33)

    local blockBtn = BattleCCSB.MENU.auto:clone()
    CSResourceMgr.setButtonTextureByNode(blockBtn,"empty.png","empty.png","empty.png")
    blockBtn:setScale(10000)
    BattleCCSB.MENU.pauseBK:addChild(blockBtn)

    local surePosX ,surePosY = BattleCCSB.MENU.sure:getPosition()

    local continueRes = {"Battle/funcMenu/fight_menu_skip.png","Battle/funcMenu/fight_menu_stop.png"}

    BattleCCSB.MENU.pauseBK:hide()
    BattleCCSB.MENU.contiLabel:hide()
    BattleCCSB.MENU.continueBtn:hide()
    BattleCCSB.MENU.giveupBtn:hide() 
    BattleCCSB.MENU.autoLabel:enableOutline(autoLineColor, 1) 
    BattleCCSB.MENU.autoLabel:setTextColor(autoColor)
    BattleCCSB.MENU.autoLabel:setString(LuaSqlite.getLanguageByKey("battleword25"))

    jumpText:enableOutline(autoLineColor, 1)
    jumpText:setTextColor(autoColor)
    jumpText:setString(LuaSqlite.getLanguageByKey("battleword26"))

    BattleCCSB.MENU.contiLabel:enableOutline(continueLineColor, 3)
    BattleCCSB.MENU.contiLabel:setTextColor(continueColor)
    BattleCCSB.MENU.contiLabel:setString(LuaSqlite.getLanguageByKey("battleword27"))

    BattleCCSB.MENU.giveupBtn:setTitleText(LuaSqlite.getLanguageByKey("battleword28"))

    BattleCCSB.MENU.speed:setTouchEnabled(false)

    if BattleUIMgr.firstBattle == 1 then
        BattleUIMgr.isAutoFight = false
        UserSettings.set({BattleIsAuto = BattleUIMgr.isAutoFight})

        BattleCCSB.MENU.speed:hide()
        BattleCCSB.MENU.auto:hide()
        BattleCCSB.MENU.pauseBtn:hide()
        BattleCCSB.MENU.autoLabel:hide()
        BattleCCSB.MENU.speedExtra:hide()
        jumpText:hide()
		BattleCCSB.MENU.jumpRound:hide()
    else
        -- if not BattleMapMgr.getIsArena() then
            -- if not BattleUIMgr.isAutoFight then
            --     BattleUIMgr.isAutoFight = false
                
            -- end

        -- elseif BattleMapMgr.getIsArena() then
        --     BattleUIMgr.isAutoFight = false
        --     BattleCCSB.MENU.sure:setScale(0,0)
        --     UserSettings.set({BattleIsAuto = BattleUIMgr.isAutoFight})

        -- else
        if BattleMapMgr.getIsArena() then
            BattleUIMgr.isAutoFight = true
        end

        if  BattlePVPMgr.mIsPVPBattle then
            BattleUIMgr.isAutoFight = false
            jumpText:hide()
            BattleCCSB.MENU.jumpRound:hide()
            BattleCCSB.MENU.auto:hide()
            BattleCCSB.MENU.sure:hide()
            BattleCCSB.MENU.autoLabel:hide() 
        end

    end  

    if not BattleUIMgr.isAutoFight then
        BattleCCSB.MENU.sure:setScale(0,0)
    end

    CocosModuleMgr.setEdgeDistance(BattleCCSB.MENU.layer, nil, 0, 0, nil, false)
    BattleCCSB.MENU.layer:zorder(funcMenuOrderZ)

    if BattleUIMgr.firstBattle == 0 then
        CSResourceMgr.clickEventBindingByNode(BattleCCSB.MENU.speed, function()
            -- if BattleUIMgr.speed < BATTLE_TWO_TIMES_SPEED then
            --     BattleUIMgr.speed = BATTLE_TWO_TIMES_SPEED
            -- else
            --     BattleUIMgr.speed = BATTLE_ONE_TIMES_SPEED
            -- end
            -- BattleUIMgr.checkSpeed() 
            BattleUIMgr:jumpBattle()
        end, 2)
        CSResourceMgr.clickEventBindingByNode(BattleCCSB.MENU.pauseBtn, function()

            BattleUIMgr.pauseBattle()
            BattleCCSB.MENU.layer:zorder(10)
            CSResourceMgr.setButtonTextureByNode(BattleCCSB.MENU.pauseBtn,continueRes[1],continueRes[1],continueRes[1])
            BattleCCSB.MENU.pauseBK:show()
            BattleCCSB.MENU.contiLabel:show()
            BattleCCSB.MENU.continueBtn:show()
            BattleCCSB.MENU.giveupBtn:show()
            CSResourceMgr.playAction(BattleCCSB.MENU.res, 0, 25, false)
        end, 2)
        CSResourceMgr.clickEventBindingByNode(BattleCCSB.MENU.continueBtn, function()
            BattleUIMgr.resumeBattle()
            BattleCCSB.MENU.layer:zorder(funcMenuOrderZ) 
            CSResourceMgr.setButtonTextureByNode(BattleCCSB.MENU.pauseBtn,continueRes[2],continueRes[2],continueRes[2])
            BattleCCSB.MENU.pauseBK:hide()
            BattleCCSB.MENU.contiLabel:hide()
            BattleCCSB.MENU.continueBtn:hide()
            BattleCCSB.MENU.giveupBtn:hide()
        end, 1)
        CSResourceMgr.clickEventBindingByNode(BattleCCSB.MENU.giveupBtn, function()
            if stopQuit then
                StandardTipsMgr.show(1, "tips45") 
                return
            end
            BattleUIMgr.sendCallBK()
            if BattlePVPMgr.mIsPVPBattle then
                BattlePVPMgr.sendLeaveBattleCommand() 
                if BattlePVPMgr.isPVPArenaBattle == PVP_YES_ARENA then
                    BattlePVPMgr.ArenaLoseShow()
                else
                    BattlePVPMgr.endCalcTime()
                    BattleUIMgr.quiteBattle()
                end
            else
                GameAudio.playBattleSound("battleEnd")  
                BattleUIMgr.cleanUIMgr()
                BattleMapMgr.cleanPVPInfo()
                BattlePVPMgr.cleanPVPInfo() 
                SceneMgr.mapEnterType = 99
                BattleCCSB.MENU.isOut = true
                SceneMgr.replaceScene(SceneMgr.getRunningScene, SceneMgr.previousScene)
            end

            if BattleGuide.funcs[GUIDE_FINISH] then 
                BattleGuide.funcs[GUIDE_FINISH]()
                BattleGuide.funcs[GUIDE_FINISH] = nil
            end 
        end, 1)
        CSResourceMgr.clickEventBindingByNode(BattleCCSB.MENU.auto, function()
            if BattleCotroller.getIsRecord() then
                return
            end
            if BattleMapMgr.getIsArena() or BattlePVPMgr.mIsPVPBattle or stopAuto  then 
                StandardTipsMgr.SHOW_MAX_NUM = 20
                TipsMgr.show(scene, "tips46")
                return
            end 
            BattleUIMgr.autoBattle()
            if not BattleUIMgr.isAutoFight then
                transition.stopTarget(BattleCCSB.MENU.sure)
                BattleCCSB.MENU.sure:setPosition(surePosX ,surePosY)
                BattleCCSB.MENU.sure:scaleTo(0.2, 1.0)
                BattleFuncMgr.bubbleButton(BattleCCSB.MENU.sure)
                BattleUIMgr.isAutoFight = true
            else
                transition.stopTarget(BattleCCSB.MENU.sure)
                BattleCCSB.MENU.sure:setPosition(surePosX ,surePosY)
                BattleCCSB.MENU.sure:scaleTo(0.05, 0.0)
                BattleUIMgr.isAutoFight = false
            end
            UserSettings.set({BattleIsAuto = BattleUIMgr.isAutoFight})
        end, 2)
        CSResourceMgr.clickEventBindingByNode(BattleCCSB.MENU.speedExtra, function()
            if isSpeed then
                local speed1Str = "Battle/funcMenu/fight_menu_accelerate_x1.png"
                cc.Director:getInstance():getScheduler():setTimeScale(1.0)
                CSResourceMgr.setButtonTextureByNode(BattleCCSB.MENU.speedExtra,speed1Str,speed1Str,speed1Str) 
                isSpeed = false
            else
                local speed2Str = "Battle/funcMenu/fight_menu_accelerate_x2.png"
                cc.Director:getInstance():getScheduler():setTimeScale(2.0)
                CSResourceMgr.setButtonTextureByNode(BattleCCSB.MENU.speedExtra,speed2Str,speed2Str,speed2Str)
                isSpeed = true
            end
            UserSettings.set({battSpeed = isSpeed}) 
        end, 2)
    end

    local function onTouchBegan(touch, event)
        return true
    end 
    
    local function onTouchEnded(touch, event)
        PetSkillViewMgr.hideBattleSkillInfoPage()
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = BattleCCSB.MENU.layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, BattleCCSB.MENU.layer)
end

function BattleCCSB.createUpBlood(parent,petInfo,otherPets) 
    BattleCCSB.UPBLOOD.res          =   "Battle/petStatus/upBlood.csb"
    BattleCCSB.UPBLOOD.layer        = CSResourceMgr.createRes(parent,BattleCCSB.UPBLOOD.res)
    BattleCCSB.UPBLOOD.status       = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,"bloodStatus")
    BattleCCSB.UPBLOOD.bloodStr     = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,{"bloodStatus","bloodStr"})
    BattleCCSB.UPBLOOD.petName      = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,{"bloodStatus","petName"})
    BattleCCSB.UPBLOOD.rare         = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,{"bloodStatus","rare"})
    BattleCCSB.UPBLOOD.bar          = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,{"bloodStatus","petBar"})
    BattleCCSB.UPBLOOD.attri        = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,{"bloodStatus","attri"})
    BattleCCSB.UPBLOOD.buffcir      = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,{"bloodStatus","buffcircle"})
    BattleCCSB.UPBLOOD.buffPic      = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,{"bloodStatus","buffcircle","buffer"})
    BattleCCSB.UPBLOOD.lap          = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,{"bloodStatus","buffcircle","lap"})
    BattleCCSB.UPBLOOD.petPos       = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,"petPos")
    BattleCCSB.UPBLOOD.ballPos      = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,"ballPos")
    BattleCCSB.UPBLOOD.catchTimes   = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,"catchTimes")
    BattleCCSB.UPBLOOD.paSkill      = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,"paSkill")
    BattleCCSB.UPBLOOD.paPic        = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,{"paSkill","paPic"})
    BattleCCSB.UPBLOOD.paStr        = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,{"paSkill","paName"})
    BattleCCSB.UPBLOOD.helpSkill    = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,"helpSkill")
    BattleCCSB.UPBLOOD.helpPic      = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,{"helpSkill","helpPic"})
    BattleCCSB.UPBLOOD.hisSkillDB   = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,"skillDB")
    BattleCCSB.UPBLOOD.hisSkillIcon = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,{"skillDB","skillIcon"})
    BattleCCSB.UPBLOOD.hisSkillName = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,{"skillDB","skillname"})
    BattleCCSB.UPBLOOD.title      = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,"title")
    BattleCCSB.UPBLOOD.buffInfo   = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,{"title","buffInfo"})
    BattleCCSB.UPBLOOD.showBuff   = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,"showBuff")
    BattleCCSB.UPBLOOD.tribuff    = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,"tribuff")
    BattleCCSB.UPBLOOD.skillAtr   = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,{"skillDB","skillAtr"})
    BattleCCSB.UPBLOOD.findPetDB    = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,"findPetDB")
    BattleCCSB.UPBLOOD.findPet      = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,"findPet")
    BattleCCSB.UPBLOOD.guidePet     = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,"guidePet")
    BattleCCSB.UPBLOOD.weaBK        = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,"weaBK")
    BattleCCSB.UPBLOOD.weather      = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,{"weaBK","weather"})
    BattleCCSB.UPBLOOD.hpStr        = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,{"bloodStatus","hpStr"})
    BattleCCSB.UPBLOOD.guideState   = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,"guideState") 
    BattleCCSB.UPBLOOD.weaBtn       = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,"weaBtn") 

    BattleCCSB.UPBLOOD.guidePet:hide() 

    BattleCCSB.UPBLOOD.guideState:setVisible(false)
 
    BattleCCSB.UPBLOOD.weaBK:setScale(0,0)

    BattleCCSB.UPBLOOD.buffInfoTable  = {}

    BattleCCSB.UPBLOOD.passNodes    = {}
    BattleCCSB.UPBLOOD.passTag      = 1

    BattleCCSB.UPBLOOD.hisSkillDB:removeFromParent()
    BattleCCSB.UPBLOOD.hisSkillDB:addTo(parent)
    BattleCCSB.UPBLOOD.hisSkillDB:setAnchorPoint(1.0,0.5)
    BattleCCSB.UPBLOOD.hisSkillDB:zorder(upBloodOrderZ) 
    BattleCCSB.UPBLOOD.hisSkillDB:setPosition(display.width,display.height-120) 

    BattleCCSB.UPBLOOD.paPosX , BattleCCSB.UPBLOOD.paPosY = BattleCCSB.UPBLOOD.helpSkill:getPosition()

    BattleCCSB.UPBLOOD.buffPosX , BattleCCSB.UPBLOOD.buffPosY = BattleCCSB.UPBLOOD.buffcir:getPosition()
    BattleCCSB.UPBLOOD.buffWidth    = 35.28

    BattleCCSB.UPBLOOD.petPosX , BattleCCSB.UPBLOOD.petPosY = BattleCCSB.UPBLOOD.petPos:getPosition()

    BattleCCSB.UPBLOOD.buffcir:setVisible(false)

    BattleCCSB.UPBLOOD.star         = {}
    BattleCCSB.UPBLOOD.enemyBalls   = {}
    BattleCCSB.UPBLOOD.ballLights   = {}

    BattleCCSB.UPBLOOD.hisSkillDB:setScale(0,0)

    BattleCCSB.UPBLOOD.weaBtn:addTouchEventListener(function(sender,state)
        
        if state == 0 then
            BattleCCSB.createWeather()
        elseif state == 2 then
            BattleCCSB.closeWeather()
        elseif state == 3 then 
            BattleCCSB.closeWeather()
        end
    end)

    BattleCCSB.UPBLOOD.showBuff:addTouchEventListener(function(sender,state)
        
        if state == 0 then
            if BattleCCSB.showOneSix == 0 then
                local buffinfo = BattleUIMgr.getBufferSPAndInfo(1)
                BattleUIMgr.pauseBattle()
                BattleCCSB.buffTipsShow(BattleCCSB.UPBLOOD.layer,280,800,buffinfo)
                BattleCCSB.createSixMap(BattleCCSB.UPBLOOD.layer,470,700,1) 
                BattleCCSB.showOneSix = 1
            end
        elseif state == 2 then
            if BattleCCSB.showOneSix == 1 then
                BattleCCSB.closeBuffTips() 
                BattleCCSB.closeSixMap()
                BattleUIMgr.resumeBattle()
                BattleCCSB.showOneSix = 0
            end
        elseif state == 3 then 
            if BattleCCSB.showOneSix == 1 then
                BattleCCSB.closeBuffTips() 
                BattleCCSB.closeSixMap()
                BattleUIMgr.resumeBattle()
                BattleCCSB.showOneSix = 0
            end
        end
    end)
    if not BattleMapMgr.getAdvChallage() and not BattlePVPMgr.mIsPVPBattle then 
        BattleCCSB.UPBLOOD.ballPos:setVisible(false)
        BattleCCSB.UPBLOOD.findPetDB:setVisible(true)
        BattleCCSB.UPBLOOD.findPet:setVisible(true)
        BattleCCSB.UPBLOOD.findPet:setString(BattleLangDB["findPet"])
        if petInfo.skin > 0 then
            BattleCCSB.UPBLOOD.findPet:setString(BattleLangDB["findPetSe"])
            BattleCCSB.UPBLOOD.findPet:setTextColor({r=255,b=19,g=86,a=255})           
        end
        BattleCCSB.UPBLOOD.findPet:enableOutline({r=41,b=1,g=17,a=255}, 2)
    else
        BattleCCSB.UPBLOOD.ballPos:setVisible(true)
        BattleCCSB.UPBLOOD.findPetDB:setVisible(false) 
        BattleCCSB.UPBLOOD.findPet:setVisible(false)
        for i = 1 ,3 do
            BattleCCSB.UPBLOOD.enemyBalls[i] = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,{"ballPos","ball"..i})
            BattleCCSB.UPBLOOD.ballLights[i] = {CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,{"ballPos","select"..i}),false}
            BattleCCSB.UPBLOOD.enemyBalls[i]:hide()
            BattleCCSB.UPBLOOD.ballLights[i][1]:hide()
        end

        for key,var in pairs(otherPets) do
            BattleCCSB.UPBLOOD.enemyBalls[key]:show()
        end
        BattleCCSB.UPBLOOD.enemyBalls[1]:show()
        BattleCCSB.UPBLOOD.ballLights[1][1]:show()
        BattleCCSB.UPBLOOD.ballLights[1][2] = true
    end

    for starID = 1 , 5 do
        BattleCCSB.UPBLOOD.star[starID] = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,{"bloodStatus","star"..starID})
    end

    BattleCCSB.UPBLOOD.rare:setScale(0.48)

    BattleCCSB.UPBLOOD.layer:zorder(upBloodOrderZ)

    BattleCCSB.UPBLOOD.petName:enableOutline(nameColor, 1)



    CSResourceMgr.setFullScreen(BattleCCSB.UPBLOOD.res)
    CocosModuleMgr.setEdgeDistance(BattleCCSB.UPBLOOD.layer, 0, nil, 0, nil, false)

    BattleCCSB.changeBloodStatus(1,petInfo)
end

function BattleCCSB.createDownBlood(parent,petInfo)
    BattleCCSB.DOWNBLOOD.res    = "Battle/petStatus/downBlood.csb"
    BattleCCSB.DOWNBLOOD.layer  = CSResourceMgr.createRes(parent,BattleCCSB.DOWNBLOOD.res)

    BattleCCSB.DOWNBLOOD.status     = CSResourceMgr.getNodeByName(BattleCCSB.DOWNBLOOD.res,"bloodStatus")
    BattleCCSB.DOWNBLOOD.petName    = CSResourceMgr.getNodeByName(BattleCCSB.DOWNBLOOD.res,{"bloodStatus","petName"})
    BattleCCSB.DOWNBLOOD.rare       = CSResourceMgr.getNodeByName(BattleCCSB.DOWNBLOOD.res,{"bloodStatus","rare"})
    BattleCCSB.DOWNBLOOD.bar        = CSResourceMgr.getNodeByName(BattleCCSB.DOWNBLOOD.res,{"bloodStatus","petBar"})
    BattleCCSB.DOWNBLOOD.attri      = CSResourceMgr.getNodeByName(BattleCCSB.DOWNBLOOD.res,{"bloodStatus","attri"})
    BattleCCSB.DOWNBLOOD.petPos     = CSResourceMgr.getNodeByName(BattleCCSB.DOWNBLOOD.res,"petPos")
    BattleCCSB.DOWNBLOOD.buffcir    = CSResourceMgr.getNodeByName(BattleCCSB.DOWNBLOOD.res,{"bloodStatus","buffcircle"})
    BattleCCSB.DOWNBLOOD.buffPic    = CSResourceMgr.getNodeByName(BattleCCSB.DOWNBLOOD.res,{"bloodStatus","buffcircle","buffer"})
    BattleCCSB.DOWNBLOOD.lap        = CSResourceMgr.getNodeByName(BattleCCSB.DOWNBLOOD.res,{"bloodStatus","buffcircle","lap"})
    BattleCCSB.DOWNBLOOD.paSkill    = CSResourceMgr.getNodeByName(BattleCCSB.DOWNBLOOD.res,"paSkill")
    BattleCCSB.DOWNBLOOD.paPic      = CSResourceMgr.getNodeByName(BattleCCSB.DOWNBLOOD.res,{"paSkill","paPic"})
    BattleCCSB.DOWNBLOOD.paStr      = CSResourceMgr.getNodeByName(BattleCCSB.DOWNBLOOD.res,{"paSkill","PaName"})
    BattleCCSB.DOWNBLOOD.helpSkill  = CSResourceMgr.getNodeByName(BattleCCSB.DOWNBLOOD.res,"helpSkill")
    -- BattleCCSB.DOWNBLOOD.helpPic    = CSResourceMgr.getNodeByName(BattleCCSB.DOWNBLOOD.res,{"helpSkill","helpPic"})
    BattleCCSB.DOWNBLOOD.title      = CSResourceMgr.getNodeByName(BattleCCSB.DOWNBLOOD.res,"title")
    BattleCCSB.DOWNBLOOD.buffInfo   = CSResourceMgr.getNodeByName(BattleCCSB.DOWNBLOOD.res,{"title","buffInfo"})
    BattleCCSB.DOWNBLOOD.showBuff   = CSResourceMgr.getNodeByName(BattleCCSB.DOWNBLOOD.res,"showBuff")
    BattleCCSB.DOWNBLOOD.tribuff    = CSResourceMgr.getNodeByName(BattleCCSB.DOWNBLOOD.res,"tribuff")
    BattleCCSB.DOWNBLOOD.guidePet   = CSResourceMgr.getNodeByName(BattleCCSB.DOWNBLOOD.res,"guidePet")
    BattleCCSB.DOWNBLOOD.guideState = CSResourceMgr.getNodeByName(BattleCCSB.DOWNBLOOD.res,"guideState")
    BattleCCSB.DOWNBLOOD.hpStr      = CSResourceMgr.getNodeByName(BattleCCSB.DOWNBLOOD.res,{"bloodStatus","hpStr"})
    BattleCCSB.DOWNBLOOD.passNodes      = {}
    BattleCCSB.DOWNBLOOD.buffInfoTable  = {}
    BattleCCSB.DOWNBLOOD.passTag        = 1
    BattleCCSB.DOWNBLOOD.guidePet:hide()
 
    BattleCCSB.DOWNBLOOD.guideState:setVisible(false)

    BattleCCSB.DOWNBLOOD.paPosX , BattleCCSB.DOWNBLOOD.paPosY = BattleCCSB.DOWNBLOOD.helpSkill:getPosition()

    BattleCCSB.DOWNBLOOD.buffPosX , BattleCCSB.DOWNBLOOD.buffPosY =  BattleCCSB.DOWNBLOOD.buffcir:getPosition()
    BattleCCSB.DOWNBLOOD.buffWidth  = 35.28
    BattleCCSB.DOWNBLOOD.star       = {}

    BattleCCSB.DOWNBLOOD.buffcir:setVisible(false)
    -- BattleCCSB.DOWNBLOOD.buffHeight = BattleCCSB.DOWNBLOOD.buffcir:getContentSize().height

    for starID = 1 , 5 do
        BattleCCSB.DOWNBLOOD.star[starID] = CSResourceMgr.getNodeByName(BattleCCSB.DOWNBLOOD.res,{"bloodStatus","star"..starID})
    end

    BattleCCSB.DOWNBLOOD.rare:setScale(0.48) 

    BattleCCSB.DOWNBLOOD.layer:zorder(downBloodOrderZ)

    BattleCCSB.DOWNBLOOD.petName:enableOutline(nameColor, 1)

--    BattleCCSB.DOWNBLOOD.petLevel:enableOutline(nameColor, 1) 

    CSResourceMgr.setFullScreen(BattleCCSB.DOWNBLOOD.res)
    CocosModuleMgr.setEdgeDistance(BattleCCSB.DOWNBLOOD.layer, nil, 0, nil, 0, false)
    BattleCCSB.DOWNBLOOD.showBuff :addTouchEventListener(function(sender,state) 
        if state == 0 then
            if BattleCCSB.showOneSix == 0 then
                BattleUIMgr.pauseBattle()
                local buffinfo = BattleUIMgr.getBufferSPAndInfo(0)
                BattleCCSB.buffTipsShow(BattleCCSB.DOWNBLOOD.layer,265,620,buffinfo)
                BattleCCSB.createSixMap(BattleCCSB.DOWNBLOOD.layer,500,550,0)
                BattleCCSB.showOneSix = 2
            end
        elseif state == 2 then
            if BattleCCSB.showOneSix == 2 then
                BattleCCSB.closeBuffTips() 
                BattleCCSB.closeSixMap()
                BattleUIMgr.resumeBattle()
                BattleCCSB.showOneSix = 0
            end
        elseif state == 3 then 
            if BattleCCSB.showOneSix == 2 then
                BattleCCSB.closeBuffTips()
                BattleCCSB.closeSixMap()
                BattleUIMgr.resumeBattle()
                BattleCCSB.showOneSix = 0
            end
        end  
    end)

    BattleCCSB.changeBloodStatus(0,petInfo)
end
 
function BattleCCSB.clearPassNodesByPet(petType)
    if petType == TEAM_A then
        for key,var in pairs(BattleCCSB.DOWNBLOOD.passNodes) do
            var[1]:removeFromParent()
        end
        BattleCCSB.DOWNBLOOD.passNodes = {}
    else
        for key,var in pairs(BattleCCSB.UPBLOOD.passNodes) do
            var[1]:removeFromParent()
        end
        BattleCCSB.UPBLOOD.passNodes = {}
    end
end

function BattleCCSB.clearPassNodes()
    for key,var in pairs(BattleCCSB.DOWNBLOOD.passNodes) do
        var[1]:removeFromParent()
    end
    BattleCCSB.DOWNBLOOD.passNodes = {}
    for key,var in pairs(BattleCCSB.UPBLOOD.passNodes) do
        var[1]:removeFromParent()
    end
    BattleCCSB.UPBLOOD.passNodes = {}
end

----@param buffTbl table 显示所有buff信息   例如:{{node,"",""},{node,"",""},.....}
function BattleCCSB.buffTipsShow(parent,posX,posY,buffTbl) 
    local count = #buffTbl
    BattleCCSB.buffTips = {}
    if count == 0 then
        return
    end
    BattleCCSB.closeBuffTips()
    local res = "Battle/showBuffInfo/buffInfo.csb"
    BattleCCSB.buffTips.layer         = CSResourceMgr.createRes(parent, res)
    BattleCCSB.buffTips.list          = BattleCCSB.buffTips.layer:getChildByName("list")
    BattleCCSB.buffTips.sixMap        = nil
    local buffBk        = BattleCCSB.buffTips.layer:getChildByName("buffBK")
    local sp_color      = BattleCCSB.buffTips.layer:getChildByName("color")
    local sp_noColor    = BattleCCSB.buffTips.layer:getChildByName("noColor")
    local sp_lastColor  = BattleCCSB.buffTips.layer:getChildByName("lastColor")
    local text_title    = BattleCCSB.buffTips.layer:getChildByName("title")
    local text_desc     = BattleCCSB.buffTips.layer:getChildByName("desc")
    local buffBKSize    = buffBk:getContentSize()

    local count = #buffTbl
    BattleCCSB.buffTips.list:setScale(0.0,0.0)
    buffBk:setScale(0.0,0.0)
    BattleCCSB.buffTips.list:scaleTo(0.1,1.0)
    buffBk:scaleTo(0.1,1.0)

    BattleCCSB.buffTips.layer:setPosition(posX,posY) 
    BattleCCSB.buffTips.layer:zorder(8)
    BattleCCSB.buffTips.list:setContentSize(492,56*count) 
    sp_color:setVisible(false)
    sp_lastColor:setVisible(false)
    text_title:setVisible(false)
    text_desc:setVisible(false)

    local totalSize = 0
    for i = 1,count do
        local sp = nil
        local title = text_title:clone()
        local desc  = text_desc:clone()
        title:setVisible(true)
        desc:setVisible(true) 
        title:setString(buffTbl[i][2])
        desc:setString(buffTbl[i][3]) 
        CSResourceMgr.setLabelMaxWidthByNode(desc, 220, 0)
        title:setAnchorPoint(0, 1)
        desc:setAnchorPoint(0, 1)
        if i%2 == 1 then
            sp = sp_noColor:clone()
        else
            if i == count then
                sp = sp_lastColor:clone()
                sp:setVisible(true)

            else
                sp = sp_color:clone()
                sp:setVisible(true)
            end
        end
        buffTbl[i][1]:addTo(sp)
        title:addTo(sp)
        desc:addTo(sp)
        sp:setAnchorPoint(0.5, 1)
        local height = title:getContentSize().height + desc:getContentSize().height + 10
        sp:setContentSize(sp:getContentSize().width,height)
        buffTbl[i][1]:setPosition(30,height/2)  
        title:setPosition(65,height-5)
        desc:setPosition(65,height-25) 
        BattleCCSB.buffTips.list:pushBackCustomItem(sp) 
        totalSize = totalSize + height
    end
    buffBk:setContentSize(buffBKSize.width,buffBKSize.height + totalSize - 55)
    -- local sp = createSprite("empty.png") 

       -- node:addTo(sixPos)

    printFileLog("BattleCCSB.buffTips.sixMap....removeFromParent")
end

function BattleCCSB.createSixMap(parent,posX,posY,petType)  
    local petInfoDat = BattleUIMgr.getPetInfo(petType).infomation
    local values    = BattleUIMgr.getSixValue(petType)
    BattleCCSB.sixMap = {}
    BattleCCSB.sixMap.sp = display.newSprite("Battle/showBuffInfo/hexagon.png")
    BattleCCSB.sixMap.sp:setPosition(posX,posY)
    BattleCCSB.sixMap.sp:addTo(parent)
    BattleCCSB.sixMap.sp:zorder(10) 
    local node      = PetEducationMgr.showSixDimensionsTex(BattleCCSB.sixMap.sp,petInfoDat, cc.c4f(1.0, 1.0, 0, 0.8),values)
    node:setPosition(148.5,170) 
end

function BattleCCSB.closeSixMap() 
    if BattleCCSB.sixMap then
        if BattleCCSB.sixMap.sp then
            BattleCCSB.sixMap.sp:removeFromParent()
            BattleCCSB.sixMap = {} 
        end
    end
end

function BattleCCSB.closeBuffTips()  
    if BattleCCSB.buffTips then
        if BattleCCSB.buffTips.sixMap then
            BattleCCSB.buffTips.sixMap:removeFromParent()
            BattleCCSB.buffTips.sixMap = nil 
        end
        if BattleCCSB.buffTips.layer then
            CSResourceMgr.removeListByNode(BattleCCSB.buffTips.list)  
            BattleCCSB.buffTips.layer:removeFromParent() 
            BattleCCSB.buffTips.layer = nil 
        end 
    end
end

function BattleCCSB.buffFontShow(petType,buffName,color,gap) 
    local ccsb = nil 
    local posX = 0
    local posY = 0

    if petType == 1 then
        ccsb = BattleCCSB.UPBLOOD
        posX,posY = ccsb.tribuff:getPosition()
    else
        ccsb = BattleCCSB.DOWNBLOOD
        posX,posY = ccsb.tribuff:getPosition()
    end

    if gap then
        posY = posY + gap 
    end

    local buffCope = ccsb.tribuff:clone()

    local function FuncCall()
        buffCope:removeFromParent()
    end
    local callFun  = cc.CallFunc:create(FuncCall)

    buffCope:setVisible(true)
    buffCope:addTo(ccsb.layer)
    buffCope:setPosition(posX,posY)
    buffCope:setTextColor(color)
    buffCope:setString(buffName)
    buffCope:enableOutline(nameColor, 1.0)
    buffCope:setFontSize(32)
    CocosModuleMgr.sharpenLabel(buffCope, 0.0, nameColor)    

    buffCope:runAction(transition.sequence({
        cc.ScaleTo:create(0.1, 1.3,1.3),
        cc.ScaleTo:create(0.2, 1.0,1.0),
        cc.DelayTime:create(0.3),
        cc.MoveBy:create(0.5, cc.p(0,50)),
        cc.FadeOut:create(0.5),
        callFun
    }))

end

function BattleCCSB.removeBuffInfo(petType)
    if petType == 1 then
        ccsb = BattleCCSB.UPBLOOD
    else
        ccsb = BattleCCSB.DOWNBLOOD
    end
    for key,var in pairs(ccsb.buffInfoTable) do
        var[1]:removeFromParent()
    end
    ccsb.buffInfoTable = {}
end

function BattleCCSB.changeBloodStatus(petType,petInfo)
    local info = BattleCCSB.DOWNBLOOD
    if petType == 1 then
        info = BattleCCSB.UPBLOOD
    end
    local bloodString   = petInfo.blood.."/"..petInfo.bloodLimit
    local bloodPer      = 100*petInfo.blood/petInfo.bloodLimit
    local levelString   = "Lv"..petInfo.level
    local attriRes      = "UI/CommonFiles/"..petInfo.attri1..".png" 
    local rarePoint     = PokemonInfo.getPokemonInfoByID(petInfo.pokeID).rarePoint
    local resBlood      = ""
    local nameSuffix    = "+"..petInfo.stageValue

    if petInfo.stageValue == 0 then
        nameSuffix = ""
    end

    for starID = 1,5 do
        if starID > petInfo.starValue then
            info.star[starID]:hide()
        else
            info.star[starID]:show()
        end
    end

    CSResourceMgr.setSpriteTextureByNode(info.rare, PetEducationMgr.getRareIcon(rarePoint))
    CSResourceMgr.setSpriteTextureByNode(info.attri, attriRes)

    if bloodPer > 50 then
        info.hpStr:setTextColor(BattleCCSB.hpColors[2]) 
    else
        info.hpStr:setTextColor(BattleCCSB.hpColors[1]) 
    end
    info.hpStr:setString(bloodString)

    resBlood = BattleFuncMgr.checkBloodPic(bloodPer)
    info.bar:loadTexture(resBlood)

    info.bar:setPercent(bloodPer+1)
    info.bar:setPercent(bloodPer)

    info.petName:setString(levelString.." "..petInfo.name..nameSuffix)
    CSResourceMgr.setLabelColorByNode(info.petName,PokemonInfo.COLOR[rarePoint])

end



function BattleCCSB.createDownEdge(parent,petInfo)
    BattleCCSB.DOWNEDGE.res            = "Battle/downEdge_A/downEdge.csb"
    if BattleCCSB.DOWNEDGE.layer then
        BattleCCSB.DOWNEDGE.layer:removeFromParent()
        BattleCCSB.DOWNEDGE.layer = nil
    end
    BattleCCSB.DOWNEDGE.layer          = CSResourceMgr.createRes(parent,BattleCCSB.DOWNEDGE.res)
    BattleCCSB.DOWNEDGE.db             = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,"db")
    BattleCCSB.DOWNEDGE.aoyiImage      = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,{"db","pic4"})
    BattleCCSB.DOWNEDGE.aoyiBK         = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,{"db","skillBK"})
    BattleCCSB.DOWNEDGE.starIsShow     = false
    BattleCCSB.DOWNEDGE.Tconsume       = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,{"db","TENE","Tconsume"})
    BattleCCSB.DOWNEDGE.TENE           = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,{"db","TENE"})
    BattleCCSB.DOWNEDGE.anger          = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,{"db","anger"})
    BattleCCSB.DOWNEDGE.powText        = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,{"db","powText"})
    BattleCCSB.DOWNEDGE.powHole        = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,{"db","powHole"})
    BattleCCSB.DOWNEDGE.enerGuide      = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,"enerGuide") 
    BattleCCSB.DOWNEDGE.angerDiban     = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,{"db","angerDiban"})
    BattleCCSB.DOWNEDGE.ENES           = {}
    BattleCCSB.DOWNEDGE.clickEffect    = {}
    BattleCCSB.DOWNEDGE.skillName      = {}
    BattleCCSB.DOWNEDGE.skillAtr       = {}
    BattleCCSB.DOWNEDGE.cardBacks      = {}
    BattleCCSB.DOWNEDGE.attriValue     = {}

    BattleCCSB.DOWNEDGE.energies       = {}

    BattleCCSB.DOWNEDGE.angers         = {}
    BattleCCSB.DOWNEDGE.angersW        = {}
    BattleCCSB.DOWNEDGE.consume        = {}
    BattleCCSB.DOWNEDGE.skillPics      = {}
    BattleCCSB.DOWNEDGE.oilSkillBg     = {}

    BattleCCSB.DOWNEDGE.energiesNum     = 0
    BattleCCSB.DOWNEDGE.angersNum       = 0
    BattleCCSB.DOWNEDGE.angersNumMax    = 0


    -- BattleCCSB.DOWNEDGE.consume[2]     = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,{"db","btn_2","consume2"})
    -- BattleCCSB.DOWNEDGE.consume[3]     = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,{"db","btn_3","consume3"})
    CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,"out"):setString(BattleLangDB["fight"])
    CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,"in"):setString(BattleLangDB["help"]) 

    for indexEnergy = 1 , ENERGY_LIMIT do
        BattleCCSB.DOWNEDGE.energies[indexEnergy] = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,{"db",
                                                    "ener"..indexEnergy})
        BattleCCSB.DOWNEDGE.energies[indexEnergy]:hide()
        BattleCCSB.DOWNEDGE.energies[indexEnergy]:setAnchorPoint(0.0,0.5)  
    end

--    for indexAnger = 1 , 4 do
--        BattleCCSB.DOWNEDGE.angers[indexAnger] = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,{"angerDb",
--            "anger_"..indexAnger})
--        BattleCCSB.DOWNEDGE.angers[indexAnger]:hide() 
--    end

    for i = 2,3 do 
        BattleCCSB.DOWNEDGE.consume[i] = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,{"db","btn_"..i,"consume"..i})
        BattleCCSB.DOWNEDGE.ENES[i] = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,{"db","btn_"..i,"ENE"..i}) 
        BattleCCSB.DOWNEDGE.oilSkillBg[i]  = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,{"db","skillBG_"..i})
        BattleCCSB.DOWNEDGE.ENES[i]:zorder(7)
        BattleCCSB.DOWNEDGE.consume[i]:zorder(8)
    end
    
    BattleCCSB.DOWNEDGE.skillBtn = {}
    
    for skBtnIndex = 1,3 do
        BattleCCSB.DOWNEDGE.skillName[skBtnIndex] = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,{"db","btn_"..skBtnIndex,"skill_name"..skBtnIndex})
        BattleCCSB.DOWNEDGE.skillName[skBtnIndex]:enableOutline(nameColor, 2)
        BattleCCSB.DOWNEDGE.skillBtn[skBtnIndex]    = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,{"db","btn_"..skBtnIndex})
        BattleCCSB.DOWNEDGE.attriValue[skBtnIndex]  = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,{"db","btn_"..skBtnIndex,"value"..skBtnIndex})
        BattleCCSB.DOWNEDGE.skillAtr[skBtnIndex]    = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,{"db","jk"..skBtnIndex,"skillAtr"..skBtnIndex})
        BattleCCSB.DOWNEDGE.clickEffect[skBtnIndex] = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,{"db","jk"..skBtnIndex})
        BattleCCSB.DOWNEDGE.skillPics[skBtnIndex]   = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,{"db","jk"..skBtnIndex,"pic"..skBtnIndex})
        BattleCCSB.DOWNEDGE.skillAtr[skBtnIndex]:zorder(2)
    end
    
    BattleCCSB.DOWNEDGE.skillName[4] = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,{"db","s_4","skill_name4"})
    BattleCCSB.DOWNEDGE.skillBtn[4]  = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,{"db","s_4"})
    BattleCCSB.DOWNEDGE.skillName[4]:enableOutline(proSkillLineColor, 2)
    BattleCCSB.DOWNEDGE.skillName[4]:setTextColor(proSkillColor)
    BattleCCSB.DOWNEDGE.skillAtr[4] = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,{"db","s_4","skillAtr4"})
    BattleCCSB.DOWNEDGE.attriValue[4] = CSResourceMgr.getNodeByName(BattleCCSB.DOWNEDGE.res,{"db","value4"}) 
    BattleCCSB.DOWNEDGE.aoyiImage:zorder(1)
    BattleCCSB.DOWNEDGE.aoyiBK:zorder(1.5)
    BattleCCSB.DOWNEDGE.skillBtn[4]:zorder(3)
    BattleCCSB.DOWNEDGE.attriValue[4]:zorder(6)

    BattleCCSB.DOWNEDGE.consume[2]:enableOutline(proSkillLineColor, 2)
    BattleCCSB.DOWNEDGE.consume[3]:enableOutline(proSkillLineColor, 2)
    BattleCCSB.DOWNEDGE.Tconsume:enableOutline(proSkillLineColor, 2)
    BattleCCSB.DOWNEDGE.Tconsume:setString(BattleCCSB.DOWNEDGE.energiesNum)

    CSResourceMgr.setFullScreen(BattleCCSB.DOWNEDGE.res)
    CocosModuleMgr.setEdgeDistance(BattleCCSB.DOWNEDGE.layer, nil, nil, nil, 0, false)

    BattleCCSB.DOWNEDGE.layer:setLocalZOrder(downEdgeOrderZ)

    BattleCCSB.setSkillIcons(petInfo)
end

function BattleCCSB.createWeather()
    local weaValue = BattleUIMgr.getWeather()
    if weaValue > 0 then
        local res  = "Battle/weather/showWeather.csb" 
        BattleCCSB.weather = CSResourceMgr.createRes(SceneMgr.getRunningScene,res)
        local title     = CSResourceMgr.getNodeByName(res,"title")
        local content   = CSResourceMgr.getNodeByName(res,"content")
        local db        = CSResourceMgr.getNodeByName(res,"db") 
        local image     = CSResourceMgr.getNodeByName(res,{"db","image"}) 
        local db_width  = 354
        local db_height = 126 
        local weaRes    = "Battle/weather/showInfo/"..weaValue..".png"
        local titleStr  = BattleWeather.weatherInfo[weaValue][1]
        local contentStr  = BattleWeather.weatherInfo[weaValue][2]  
        
        title:setString(LuaSqlite.getLanguageByKey(titleStr)) 
        content:setString(LuaSqlite.getLanguageByKey(contentStr))
        CSResourceMgr.setSpriteTextureByNode(image, weaRes)
        BattleCCSB.weather:zorder(8)
        BattleCCSB.weather:setPosition(display.cx,display.cy+150) 
        local content_width = content:getContentSize().width
        if content_width > 220 then
            db:setContentSize(db_width + content_width - 220,db_height)
        end
    end

end

function BattleCCSB.closeWeather()
    if BattleCCSB.weather then
        BattleCCSB.weather:removeFromParent()
        BattleCCSB.weather = nil
    end
end

function BattleCCSB.setSkillIcons(petInfo)
    --技能按钮事件
    local isPressOver = false

    local function selectSkill(skillName,skillType)
            for i = 1,4 do
                if i == skillType then
                    BattleUIMgr.setSkillSelect(i,true)
                else
                    BattleUIMgr.setSkillSelect(i,false)
                end
            end
    end
    for i=1, 4 do
        CSResourceMgr.buttonEventBindingByNodeXP(BattleCCSB.DOWNEDGE.skillBtn[i], function()
        end, function()
            isPressOver = true 

                local skillnode = nil

                if i == 4 then
                    BattleFuncMgr.bubbleAction(BattleCCSB.DOWNEDGE.aoyiImage,0.15,0.1,1.5,callBack) 
                    BattleFuncMgr.bubbleAction(BattleCCSB.DOWNEDGE.aoyiBK,0.15,0.1,1.0,callBack)  
                    
                    if not BattleCCSB.isStopAction or BattleCotroller.isPause or not BattleCCSB.TIME.canAutoPress then
                        return
                    end

                    if BattleCCSB.DOWNEDGE.angersNum < BattleCCSB.DOWNEDGE.angersNumMax then 
                        StandardTipsMgr.show(1, "tips43")
                        return false
                    end 
                    
                    audio.playSound(BattleFuncMgr.getBattleSounds()["skill4Btn"],false)
                    BattleCANI.createSKillLight(BattleCCSB.DOWNEDGE.aoyiImage,35,35)
                    BattleCANI.createSkillEffect(BattleCCSB.DOWNEDGE.aoyiImage)
                    BattleCANI.skillLight:setScale(0.8,0.8)  
                else
                    BattleFuncMgr.bubbleAction(BattleCCSB.DOWNEDGE.clickEffect[i],0.1,0.1,1.0,callBack)
                    if not BattleCCSB.isStopAction or BattleCotroller.isPause or not BattleCCSB.TIME.canAutoPress then
                        return
                    end

                    if BattleCCSB.DOWNEDGE.energiesNum < petInfo["skill"][i].energy then
                        StandardTipsMgr.show(1, "tips44")
                        return false
                    end
                    
                    BattleCANI.createSKillLight(BattleCCSB.DOWNEDGE.clickEffect[i],60.7,63.8)  
                    BattleCANI.createSkillEffect(BattleCCSB.DOWNEDGE.clickEffect[i])
                end
                -- BattleFuncMgr.bubbleButtonTest(BattleCCSB.DOWNEDGE.skillBtn[i])       
                BattleUIMgr.selectSkill(i,true) 
                BattleCCSB.TIME.isOverTime = true
                BattleCCSB.TIME.canAutoPress = false
                BattleUIMgr.setStopAction(false)
                selectSkill(petInfo["skill"][i]["name"],i)

                BattleUIMgr.sendRoundInfo(i,0,-1,false)
                -- if not BattlePVPMgr.mIsPVPBattle then
                --     BattleCotroller.roundStart(i,0,-1,false)
                -- else
                --     BattlePVPMgr.sendBattleCommand(0,i,0)
                -- end
        end, nil, function()
            PetSkillViewMgr.hideBattleSkillInfoPage()
        end, false, nil, function()
            if BattleUIMgr.showSkillTip then
                PetSkillViewMgr.showBattleSkillInfoPage(petInfo.skill[i].info)
            end 
        end)
    end 
    local angerPowerRes = {
            "empty.png",
            "Battle/downEdge_A/share_skill_grid_base_2.png",
            "Battle/downEdge_A/share_skill_grid_base_3.png",
            "Battle/downEdge_A/share_skill_grid_base_4.png"
        }
    local angerRes = {
            {"empty.png","empty.png"}, 
            {"Battle/downEdge_A/meaning_skill_power_2_a.png","meaning_fight_skill_power_2.png"},
            {"Battle/downEdge_A/meaning_skill_power_3_a.png","Battle/downEdge_A/meaning_skill_power_3_b.png",
                    "Battle/downEdge_A/meaning_fight_skill_power_3.png"},
            {"Battle/downEdge_A/meaning_skill_power_4_a.png","Battle/downEdge_A/meaning_skill_power_4_b.png",
                "Battle/downEdge_A/meaning_skill_power_4_c.png","Battle/downEdge_A/meaning_fight_skill_power_4.png"}
        } 

    for key,var in pairs(petInfo["skill"]) do
        if var ~= 0 then
            
            local airpower = var.info.airpower
            BattleCCSB.DOWNEDGE.skillName[key]:setString(var["name"])
            BattleCCSB.DOWNEDGE.skillName[key]:setTextColor(PokemonInfo.COLOR[airpower])

            local skillIconStr ="Battle/skillIcon/"..var.info.icon..".png"
            if not BattleFuncMgr.isFileExist(skillIconStr) then
                skillIconStr = "Battle/skillIcon/default.png" 
            end
            BattleFuncMgr.setLabelLenByNode(BattleCCSB.DOWNEDGE.skillName[key],100)

            local valueRes = BattleUIMgr.attributeStateRes(var.id)
            
            if not valueRes then
                valueRes = "empty.png" 
            end 

            CSResourceMgr.setSpriteTextureByNode(BattleCCSB.DOWNEDGE.attriValue[key], valueRes)  

            local atr_sp = BattleCCSB.DOWNEDGE.skillAtr[key]:getChildByName("atr"..key) 
            CSResourceMgr.setSpriteTextureByNode(atr_sp, var.icon)

            if key == 4 then
                BattleCCSB.DOWNEDGE.angerDiban:show() 
                BattleCCSB.DOWNEDGE.anger:show() 
                BattleCCSB.DOWNEDGE.aoyiBK:show() 
                BattleCCSB.DOWNEDGE.powHole:show() 
                BattleCCSB.DOWNEDGE.attriValue[key]:show() 
                BattleCCSB.DOWNEDGE.skillAtr[key]:show()
                BattleCCSB.DOWNEDGE.aoyiImage:show()
                BattleCCSB.DOWNEDGE.skillBtn[key]:show()
                BattleCCSB.DOWNEDGE.powText:show()
                BattleCCSB.DOWNEDGE.angersNum = petInfo.anger or 0
                BattleCCSB.DOWNEDGE.angersNumMax = petInfo.angerMax
                if BattleCCSB.DOWNEDGE.angersNumMax > 4 then
                    BattleCCSB.DOWNEDGE.angersNumMax = 4
                end 

                CSResourceMgr.setSpriteTextureByNode(BattleCCSB.DOWNEDGE.aoyiImage, skillIconStr)
                
                if angerPowerRes[var.energy] then
                    CSResourceMgr.setSpriteTextureByNode(BattleCCSB.DOWNEDGE.powHole,
                        angerPowerRes[var.energy]) 
                end
                BattleUIMgr.setAnger(BattleCCSB.DOWNEDGE.angersNum)

            else
                CSResourceMgr.setSpriteTextureByNode(BattleCCSB.DOWNEDGE.clickEffect[key],
                    "Battle/downEdge_A/skillStage/"..airpower..".png")
                BattleCCSB.DOWNEDGE.clickEffect[key]:show()
                
                local valueX,valueY = BattleCCSB.DOWNEDGE.attriValue[key]:getPosition()
                local valueSize  = BattleCCSB.DOWNEDGE.attriValue[key]:getContentSize()
                local nameSize   = BattleCCSB.DOWNEDGE.skillName[key]:getContentSize()
                local nameScaleX = BattleCCSB.DOWNEDGE.skillName[key]:getScaleX()
                local nameSizeX  = BattleCCSB.DOWNEDGE.skillName[key]:getPosition()

                valueX = nameSizeX + nameSize.width*nameScaleX/2 + 17
                BattleCCSB.DOWNEDGE.attriValue[key]:setPosition(valueX,valueY)
                printFileLog("valueSize.."..sz_T2S(valueSize)..",nameSize.."..sz_T2S(nameSize)..",valueSize.."..nameSizeX) 

                if key ~= 1 then
                    BattleCCSB.DOWNEDGE.consume[key]:setString(var.energy)
                    BattleCCSB.DOWNEDGE.oilSkillBg[key]:show()
                    BattleCCSB.DOWNEDGE.skillBtn[key]:show() 
                end

                if key == 2 then
                    GUIDE_ENERGY_MAX_2 = var.energy
                end
                
                display.addImageAsync(skillIconStr,function()
                    CSResourceMgr.setSpriteTexture(BattleCCSB.DOWNEDGE.res, {"db","jk"..key,"pic"..key}, skillIconStr)
                end)
            end 
            
        else
            if key == 4 then 
                BattleCCSB.DOWNEDGE.angerDiban:hide()
                BattleCCSB.DOWNEDGE.anger:hide()
                BattleCCSB.DOWNEDGE.aoyiBK:hide() 
                -- BattleCCSB.DOWNEDGE.powHole:hide()
                BattleCCSB.DOWNEDGE.aoyiImage:hide()
                BattleCCSB.DOWNEDGE.skillAtr[key]:hide()
                BattleCCSB.DOWNEDGE.attriValue[key]:hide()  
                BattleCCSB.DOWNEDGE.powText:hide()
                BattleUIMgr.setAnger(0) 
                BattleCCSB.DOWNEDGE.angersNum       = 0 
                BattleCCSB.DOWNEDGE.angersNumMax    = 0
                BattleCCSB.DOWNEDGE.skillBtn[key]:hide()
                CSResourceMgr.setSpriteTextureByNode(BattleCCSB.DOWNEDGE.powHole,
                        "Battle/downEdge_A/share_skill_grid_base_0.png") 
                if  BattleCANI.aoyiEffectZ then
                    BattleCANI.aoyiEffectZ:removeFromParent()
                    BattleCANI.aoyiEffectZ = nil
                    BattleCANI.aoyiEffectB:removeFromParent() 
                    BattleCANI.aoyiEffectB = nil
                end 
            else
                BattleCCSB.DOWNEDGE.clickEffect[key]:hide()
                if key ~= 1 then
                    BattleCCSB.DOWNEDGE.oilSkillBg[key]:hide()
                    BattleCCSB.DOWNEDGE.skillBtn[key]:hide()
                end
            end
        end
             
    end
end

function BattleCCSB.createPetCards(PetsOfOut,PetsOfIn)  
    BattleCCSB.CARDS.outCard        = {} 
    BattleCCSB.CARDS.inCard        = {}
    BattleCCSB.CARDS.res            =  "Pet/petcards/petcard.csb" 
    BattleCCSB.CARDS.isChangePet    = false
    BattleCCSB.CARDS.isbuffreplace  = false 
    
    BattleCCSB.CARDS.cardPos = { 
        {109.83,73.82},
        {210.29,73.82},
        {310.74,73.82}
    }

    ------------这部分准备删掉 
    local outPos   = {
            {109.83,73.82},
            {210.29,73.82},
            {310.74,73.82}
        }
    local inPos   = {
        {429.77,67.46},
        {527.82,67.46},
        {625.88,67.46}
    }
    -----------------------
    BattleFuncMgr.petcard = nil
    for key,var in pairs(PetsOfOut) do
        local newPetInfo    = {}
        BattleCCSB.CARDS.outCard[key] = {}
        newPetInfo.hp       = var.blood
        newPetInfo.hpmax    = var.bloodLimit 
        newPetInfo.Stage    = var.stageValue
        newPetInfo.star     = var.starValue
        newPetInfo.level    = var.level
        newPetInfo.pokeID    = var.pokeID
        BattleCCSB.CARDS.outCard[key] = BattleFuncMgr.startCreatePetCard(newPetInfo,1) 
        BattleCCSB.CARDS.outCard[key].button:addTo(BattleCCSB.DOWNEDGE.db)
        BattleCCSB.CARDS.outCard[key].button:zorder(4)
        BattleCCSB.CARDS.outCard[key].button:setPosition(outPos[key][1],outPos[key][2])
        BattleCCSB.CARDS.outCard[key].exp   = var.exp
        BattleCCSB.CARDS.outCard[key].lvNum = var.level
        if key == 1 then
            BattleCCSB.CARDS.outCard[key].barBK:hide()
            BattleCCSB.CARDS.outCard[key].bar:hide()
            for key,var in pairs(BattleCCSB.CARDS.outCard[key].stars) do
                var:hide()
            end
            BattleCCSB.CARDS.outCard[key].str:setString(BattleLangDB["fighting"])
        end

        local function changePetFuc()

            if BattleMapMgr.getIsArena() then
                StandardTipsMgr.SHOW_MAX_NUM = 20
                TipsMgr.show(scene, "当前不能手动换宠")
                return
            end

            if BattleCCSB.CARDS.isbuffreplace then
                StandardTipsMgr.SHOW_MAX_NUM = 20
                TipsMgr.show(scene, "当前buff状态不能换宠")
                return
            end
                print("changePetFuc~~~~~~~~~~~~",BattleCCSB.TIME.canAutoPress)
                if not BattleCCSB.TIME.canAutoPress then
                    return
                end
                
                if BattleUIMgr.isAutoFight then
                    DialogBoxMgr.showSmallDialogBox(scene, 1, "tips47", function()
                        end, function()end)
                    return
                end

                if BattleCCSB.CARDS.outCard[key]["bar"]:getPercent() <= 0 then
                    BattleCCSB.CARDS.outCard[key]["button"]:setTouchEnabled(false)
                end
                BattleCCSB.TIME.isOverTime = true
                BattleCCSB.TIME.canAutoPress = false

                if BattleUIMgr.isAutoFight == false then
                    BattleUIMgr.setStopAction(false)
                    
                    BattleUIMgr.sendRoundInfo(6,0,key,true)
                    -- if not BattlePVPMgr.mIsPVPBattle then
                    --     BattleCotroller.roundStart(6,0,key,true)
                    -- else
                    --     BattlePVPMgr.sendBattleCommand(0,6,key)
                    -- end
                end
                BattleCCSB.CARDS.isChangePet = true
        end
        if newPetInfo.hp > 0 then
            CSResourceMgr.clickEventBindingByNode(BattleCCSB.CARDS.outCard[key]["button"], function()
                    BattleFuncMgr.bubbleButton(BattleCCSB.CARDS.outCard[key]["button"])
                    changePetFuc() 
            end, 1)
        else  
            -- BattleFuncMgr.setNodeGray(BattleCCSB.CARDS.outCard[key]["button"],false) 
            BattleCCSB.CARDS.outCard[key].button:setTouchEnabled(false)
            BattleFuncMgr.setNodeGray(BattleCCSB.CARDS.outCard[key].head,false)
            local spRes = "Battle/downEdge_A/die.png"
                
            display.addImageAsync(spRes,function()
                    local sp = display.newSprite(spRes) 
                    sp:addTo(BattleCCSB.CARDS.outCard[key].button)
                    sp:zorder(10)
                    sp:setPosition(47,88) 
                end)
        end
    end 

    for key,var in pairs(PetsOfIn) do
        local newPetInfo    = {}
        BattleCCSB.CARDS.inCard[key] = {}
        newPetInfo.hp       = var.blood
        newPetInfo.hpmax    = var.bloodLimit
        newPetInfo.Stage    = var.stageValue
        newPetInfo.star     = var.starValue
        newPetInfo.level    = var.level
        newPetInfo.pokeID    = var.pokeID
        BattleCCSB.CARDS.inCard[key] = BattleFuncMgr.startCreatePetCard(newPetInfo,2)
        BattleCCSB.CARDS.inCard[key].button:addTo(BattleCCSB.DOWNEDGE.db)
        BattleCCSB.CARDS.inCard[key].button:zorder(4)
        BattleCCSB.CARDS.inCard[key].button:setPosition(inPos[key][1],inPos[key][2])
    end
    
    BattleFuncMgr.endCreatePetCard()
 
   BattleUIMgr.setStopAction(false)
end
---设置卡牌属性
--@petInfo    宠物信息
--@cardIndex  换上宠的卡片
function BattleCCSB.setPetCard(petInfo,cardIndex,preIndex)
    local cardInfo = BattleCCSB.CARDS.outCard[cardIndex]
    local precardInfo = BattleCCSB.CARDS.outCard[preIndex]
    local rarePoint = PokemonInfo.getPokemonInfoByID(petInfo.pokeID).rarePoint
    local rareRes = BattleFuncMgr.getStagePics(rarePoint)

    CSResourceMgr.setSpriteTextureByNode(precardInfo.headBK, rareRes.p1)

    -- local attriRes = "Pet/AttriIcon/"..petInfo.attri1..".png"
    -- local attrCirRes = "Pet/AttriIcon/small_"..petInfo.attri1..".png"
    local cardPer = 100*petInfo.blood/petInfo.bloodLimit

    cardInfo.barBK:hide() 
    cardInfo.bar:hide()
    precardInfo.barBK:show()
    precardInfo.bar:show()
    for key,var in pairs(cardInfo.stars) do
        var:hide()
    end
    for key,var in pairs(precardInfo.stars) do
        var:show()
    end
    cardInfo.str:setString(BattleLangDB["fighting"])
    precardInfo.str:setString("") 

    if cardPer <= 0 then
        precardInfo.button:setTouchEnabled(false)
        BattleFuncMgr.setNodeGray(precardInfo.head,false)
        local spRes = "Battle/downEdge_A/die.png"
        
        display.addImageAsync(spRes,function()
                local sp = display.newSprite(spRes)
                sp:addTo(precardInfo.button)
                sp:zorder(10)
                sp:setPosition(47,88) 
            end)
    end
    
    cardInfo.button:setTouchEnabled(false)

    precardInfo.bar:setPercent(cardPer)
end
---------设置战斗立绘
function BattleCCSB.createPVSE(parent,petInfo,otherPets)
    BattleCCSB.PVSE.res   = "Battle/PVSE.csb"
    BattleCCSB.PVSE.layer = CSResourceMgr.createRes(parent,BattleCCSB.PVSE.res)
    BattleCCSB.PVSE.bar   = CSResourceMgr.getNodeByName(BattleCCSB.PVSE.res,"resLoadingBar")

    BattleCCSB.PVSE.bar:hide()
    CSResourceMgr.getNodeByName(BattleCCSB.PVSE.res,"resloadBG"):hide()

    CSResourceMgr.setRelativePosition(BattleCCSB.PVSE.res , 320, 480)

    CSResourceMgr.setSpriteTexture(BattleCCSB.PVSE.res,"role1",CharInfo.getCharVerticalImg())
    CSResourceMgr.setSpriteTexture(BattleCCSB.PVSE.res,"role2",BattleMapMgr.getseniorFigure())

    local playerPetTotal = {}
    local enemyPetTotal = {}

    playerPetTotal[1] = petInfo[0]
    enemyPetTotal[1]  = petInfo[1]

    for key,var in pairs(otherPets["playerPets"]) do
        table.insert(playerPetTotal,var)
    end

    for key,var in pairs(otherPets["enemyPets"]) do
        table.insert(enemyPetTotal,var)
    end

    for key,var in pairs(playerPetTotal) do
        local ball = CSResourceMgr.getNodeByName(BattleCCSB.PVSE.res,"pB"..key)
        ball:show()
        CSResourceMgr.setSpriteTexture(BattleCCSB.PVSE.res, "pB"..key, playerPetTotal[key]["icon"][1])
    end

    for key,var in pairs(enemyPetTotal) do
        local ball = CSResourceMgr.getNodeByName(BattleCCSB.PVSE.res,"eB"..key)
        ball:show()
    end

    BattleCCSB.PVSE.layer:fadeIn(0.4)
    BattleCCSB.PVSE.layer:zorder(8)

    CSResourceMgr.playActionWithCallback(BattleCCSB.PVSE.res,0,50, 1.0,
        function()
            BattleFuncMgr.vibrationScene(parent)
            CSResourceMgr.playActionWithCallback(BattleCCSB.PVSE.res,51,70, 1.0,
                function()
                    BattleUIMgr.addUI()
                end,"")
        end
        , "")
end

function BattleCCSB.createTime(parent,label)
    BattleCCSB.TIME.res         = "Battle/PVPTime/PVPtime.csb"
    BattleCCSB.TIME.layer       = CSResourceMgr.createRes(parent,BattleCCSB.TIME.res)
    BattleCCSB.TIME.labelPos    = CSResourceMgr.getNodeByName(BattleCCSB.TIME.res,"labelPos")
    local pic                   = CSResourceMgr.getNodeByName(BattleCCSB.TIME.res,"pic")
    local picRes                = CocosModuleMgr.getWordImage("zd_huihe2.png")
    pic:setTexture(picRes)
    BattleCCSB.TIME.handle      = nil

    BattleCCSB.TIME.canAutoPress = false
    BattleCCSB.TIME.isOverTime = true

    CSResourceMgr.setRelativePosition(BattleCCSB.TIME.res, 320, 540)

    BattleCCSB.TIME.layer:hide()

    BattleCCSB.TIME.layer:setLocalZOrder(timeOrderZ)

    local  roundPos = CSResourceMgr.getNodeByName(BattleCCSB.TIME.res,"roundNum")
    local  timePos  = CSResourceMgr.getNodeByName(BattleCCSB.TIME.res,"timeNum")
    
    local  timeSpri = display.newSprite("Battle/PVPTime/zd_daojishi0002.png")
    BattleCCSB.TIME.progressTime = cc.ProgressTimer:create(timeSpri)
    BattleCCSB.TIME.progressTime:setTag(cc.PROGRESS_TIMER_TYPE_RADIAL)
    BattleCCSB.TIME.progressTime:setReverseDirection(true)
    BattleCCSB.TIME.progressTime:zorder(2)
    BattleCCSB.TIME.progressTime:addTo(timePos)
    BattleCCSB.TIME.progressTime:setPosition(10,8)
    BattleCCSB.TIME.progressTime:setPercentage(100)

    local filePath = cc.FileUtils:getInstance():fullPathForFilename(label["roundNum"][1])
    BattleCCSB.TIME.roundNum = BattleFuncMgr.CCSUILoader:createLabelAtlas({
        stringValue = 1,
        charMapFileData = {path = filePath},
        itemWidth = label["roundNum"][2],
        itemHeight = label["roundNum"][3],
        startCharMap = label["roundNum"][4],
        x = 10,
        y = 10,
        ignoreSize = true})
    BattleCCSB.TIME.roundNum:addTo(roundPos)
    BattleCCSB.TIME.roundNumX = BattleCCSB.TIME.roundNum:getPositionX()
    BattleCCSB.TIME.roundNumY = BattleCCSB.TIME.roundNum:getPositionY()
    filePath = cc.FileUtils:getInstance():fullPathForFilename(label["timeNum"][1])
    BattleCCSB.TIME.timeNum = BattleFuncMgr.CCSUILoader:createLabelAtlas({
        stringValue = 9,
        charMapFileData = {path = filePath},
        itemWidth = label["timeNum"][2],
        itemHeight = label["timeNum"][3],
        startCharMap = label["timeNum"][4],
        x = 10,
        y = 10,
        ignoreSize = true})
    BattleCCSB.TIME.timeNum:zorder(1)
    BattleCCSB.TIME.timeNum:addTo(timePos)

    return BattleCCSB.TIME.layer
end

function BattleCCSB.createGameLose(parent)
    local AdvFailedView = require("src.GameMgr.Searching.AdvFailedView")
    local loseType = 1
    if SceneMgr.previousScene == "TeamCopyMapScene" then
        loseType = 2
    end
    AdvFailedView.show(parent,loseType)
    local resName = "Searching/Summary/PlayerFailedView.csb"
    local starBar =  CSResourceMgr.getNodeByName(resName,"star_bar","") 
    starBar:hide()
    BattleCCSB.MENU.isOut = true
    local function BtnBinding()
        CSResourceMgr.setButtonString(resName, "retry", BattleLangDB["replay"], "")
        CSResourceMgr.clickEventBinding(resName,"retry",function()
            audio.stopAllSounds()
            BattleUIMgr.cleanUIMgr()
            BattleCCSB.stopAutoBattle()
            CSResourceMgr.removeCSObjectByTag(resName, "") 
            BattleUIMgr.startRecord() 
            AdvFailedView.hide()
        end,"")

        CSResourceMgr.clickEventBinding(resName,"exit",function()
            BattleUIMgr.cleanUIMgr()
            AdvFailedView.hide()
            CSResourceMgr.removeCSObjectByTag(resName, "") 
            SceneMgr.replaceScene(parent, SceneMgr.previousScene)  
        end,"")

    end

    UnblockLoader.addCallback("AdvFailedView-show", BtnBinding)
end

function BattleCCSB.createSummary(expValue,petInfo,typeStr,tottalDamages,damageMax,result,canChange)  
    local light = nil
    local exp1  = nil
    local exp2  = nil
    local exp3  = nil
    local spi   = nil
    local BK    = nil
    local pos   = {}
    local layer_BK      = nil
    local isShare       = false
    local expPotential = BattleCCSB.createHunterPotential("exp")
    local AtlasStr = "exp"
    local winAni   = nil

    BattleCCSB.MENU.isOut = true

    if expPotential then
        AtlasStr = "exp_green"
    end

    if result ~= PLAYER_WIN then
        expValue = 0
    end

    local function createBK()
        local res   = "Pet/Formation/FormationBGNew.csb"
        layer_BK = CSResourceMgr.createRes(SceneMgr.getRunningScene, res, nil)
        CSResourceMgr.setRelativePosition(res, 320, 480, nil)
        layer_BK:zorder(winOrderZ)
    end

    GameAudio.playBattleSound("win")

    local function upDateNum(str,value,addvalue,tottalValue,isAdd,callBack,bar)

        if BattleCCSB.WIN.stop or isShare then
            return
        end
        local addStr = "" 
        if isAdd then
            addStr = "/"
            GameAudio.playBattleSound("resultNum") 
        end 
        value = value + addvalue
        if bar then
            bar:setPercent(value*100/damageMax)  
        end
        if value >= tottalValue then
            value = tottalValue
            str:setString(addStr..value)
            if callBack then
                callBack()
            end 
            return
        end
        str:setString(addStr..value)
        str:performWithDelay(function()
                upDateNum(str,value,addvalue,tottalValue,isAdd,callBack,bar)
            end, 0.001) 
        
    end

    local layerPosX,layerPosY = nil,nil
    local win,winBK,BK = nil,nil,nil
    local function moveBackLayer(node,callback)
        if layerPosX then
            transition.moveTo(node,{ x = layerPosX, y = layerPosY,time = 0.3,
                    onComplete = function()
                        if callback then
                            callback()
                        end
                    end
                })
        end
    end

    local function createDetails()
        local res   = "Battle/summer_A/summer.csb"
        local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, res, nil)
        -- local wordTex       = CocosModuleMgr.getWordImage("adventureLose.png")
        local wordTex       = CocosModuleMgr.getWordImage("adventureWin.png")
        local cards             = {} 
        local damagePets        = {}
        local copyDamagePets    = {}   
        local expStr        = LuaSqlite.getLanguageByKey("advtips14")
        local expBtnStr     = LuaSqlite.getLanguageByKey("advtips10")
        local damageBtnStr  = LuaSqlite.getLanguageByKey("advtips11")
        local shareBtnStr   = LuaSqlite.getLanguageByKey("battleword17")
        local teamA_db     = CSResourceMgr.getNodeByName(res,{"BK","teamA_db"})
        local teamB_db     = CSResourceMgr.getNodeByName(res,{"BK","teamA_db","teamB_db"})
        local pet_TeamA    = CSResourceMgr.getNodeByName(res,"headPosA")
        local pet_TeamB    = CSResourceMgr.getNodeByName(res,"headPosB")
        local summBtn      = CSResourceMgr.getNodeByName(res,"summBtn")
        local BK           = CSResourceMgr.getNodeByName(res,"BK")
        local g_head       = CSResourceMgr.getNodeByName(res,"g_head")
        local scoreBK      = CSResourceMgr.getNodeByName(res,"scoreBK")
        local scorePic     = CSResourceMgr.getNodeByName(res,"scorePic")
        local score        = CSResourceMgr.getNodeByName(res,"score") 
        local share        = CSResourceMgr.getNodeByName(res,"realShare")

        local teamA_PosX = 59
        local teamB_PosX = 253
        local speed      = 2
        local isRunDamage   = false
        local isFirstDamage = false
        local isFirstExp    = false
        local teamPosY = {
                    228,
                    134,
                    39
                }
        win       = CSResourceMgr.getNodeByName(res,"win")
        
        scoreBK:hide()
        scorePic:hide()
        score:hide()
        CSResourceMgr.setSpriteTextureByNode(scorePic, CocosModuleMgr.getWordImage("jifen.png")) 

        damagePets[TEAM_A] = {}
        damagePets[TEAM_B] = {}   

        CSResourceMgr.setRelativePosition(res, 320, 470, nil)
        layerPosX,layerPosY = layer:getPosition()

        g_head:setScale(0.0,0.0)
        win:setScale(0,0)

        summBtn:setTitleText("")
        local summLabel = display.newTTFLabel({
                font = "cuyuan_GBK.ttf",
                text = damageBtnStr,
                size = 24,
                align= cc.TEXT_ALIGN_CENTER,
                color = display.COLOR_WHITE
            }) 
        summLabel:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1)
        summLabel:addTo(summBtn)
        summLabel:setPosition(75,30)

 

        local shareLabel = display.newTTFLabel({
                font = "cuyuan_GBK.ttf",
                text = shareBtnStr,
                size = 24,
                align= cc.TEXT_ALIGN_CENTER,
                color = display.COLOR_WHITE
            }) 
        shareLabel:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1)
        shareLabel:addTo(share)
        shareLabel:setPosition(100,30) 

        layer:setPosition(layerPosX,layerPosY+100)

        exp1  = CSResourceMgr.getNodeByName(res,"exp1")
        exp2  = CSResourceMgr.getNodeByName(res,"exp2")
        exp3  = CSResourceMgr.getNodeByName(res,"exp3")
        BK    = CSResourceMgr.getNodeByName(res,"BK")

        for key,var in pairs(BattleCCSB.CARDS.outCard) do
            BattleCCSB.CARDS.outCard[key].barBK:show()
            BattleCCSB.CARDS.outCard[key].bar:show() 
            for key,var in pairs(BattleCCSB.CARDS.outCard[key].stars) do
                var:show()
            end
            BattleCCSB.CARDS.outCard[key].str:setString("")
            cards[key] = BattleCCSB.CARDS.outCard[key].button:clone()
            cards[key]:addTo(BK) 
        end

        teamA_db:hide()

        local function setPet(team,petInfo,index) 
            local team_pet = {}
            local parent    = pet_TeamA
            local barStr    = "loadingBar_1"
            local headStr   = "head_1"
            local damageStr = "damage_1"
            local headBKStr = "headBK_1"
            local posX      = teamA_PosX
            local team_db   = teamA_db
            local starStr   = "star_1"
            local rareiStr  = "rarePoint_1"
            local waitRes   = CocosModuleMgr.getWordImage("jiesuan_daizhan.png") 
            local wait_posX ,wait_posY = 228,40 

            if team == TEAM_B then
                parent      = pet_TeamB
                barStr      = "loadingBar_2"
                headStr     = "head_2"
                damageStr   = "damage_2"
                starStr     = "star_2"
                posX        = teamB_PosX
                team_db     = teamB_db
                rareiStr    = "rarePoint_2"
                headBKStr   = "headBK_2"
                
                wait_posX ,wait_posY = -180,40
            end
            team_pet.node    = parent:clone()
            team_pet.bar     = team_pet.node:getChildByName(barStr)
            team_pet.head    = team_pet.node:getChildByName(headStr)
            team_pet.damage  = team_pet.node:getChildByName(damageStr)
            team_pet.star    = team_pet.node:getChildByName(starStr)
            team_pet.rarei   = team_pet.node:getChildByName(rareiStr)
            team_pet.headBK  = team_pet.node:getChildByName(headBKStr)
            team_pet.damageValue = 0 
            team_pet.killPets    = 0 
            local starPosX,starPosY = team_pet.star:getPosition()
            if index ~= 1 then
                team_pet.wait_sp     = display.newSprite(waitRes) 
                team_pet.wait_sp:addTo(team_pet.node) 
                team_pet.wait_sp:setPosition(wait_posX,wait_posY)
            end

            team_pet.node:addTo(team_db) 
            team_pet.node:setPosition(posX,teamPosY[index])
            team_pet.node:hide()
            team_pet.bar:setPercent(0)
            team_pet.damage:setString(0) 

            local rareRes = BattleFuncMgr.getStagePics(petInfo.rarePoint) 
            CSResourceMgr.setSpriteTextureByNode(team_pet.headBK, rareRes.p1) 

            CSResourceMgr.setSpriteTextureByNode(team_pet.rarei, 
                PetEducationMgr.getRareIcon(petInfo.rarePoint))

            team_pet.headRes = PokemonInfo.getPokemonIconByID(petInfo.pokeID)
            CSResourceMgr.setSpriteTextureByNode(team_pet.head, team_pet.headRes)
            if petInfo.starValue == 0 then
                team_pet.star:hide()
            else 
                local x = starPosX - (15*petInfo.starValue - 15)/2
                team_pet.star:setPosition(x,starPosY)
                local copyStars = petInfo.starValue-1
                for starIndex = 1,copyStars do
                    local copeStar = team_pet.star:clone()
                    copeStar:addTo(team_pet.node) 
                    copeStar:setPosition(x+starIndex*15,starPosY) 
                end
            end

            return team_pet
        end

        
        for key,var in pairs(petInfo[TEAM_A]) do
            damagePets[TEAM_A][key] = setPet(TEAM_A,var,key)
        end

        for key,var in pairs(petInfo[TEAM_B]) do 
            damagePets[TEAM_B][key] = setPet(TEAM_B,var,key)
        end
        
        BattleCCSB.WIN.stop = false
        pos = {
            {110,210,exp1},
            {320,210,exp2},
            {530,210,exp3} 
        }
        if #BattleCCSB.CARDS.outCard < 3 then 
            pos = {
                {640/(#BattleCCSB.CARDS.outCard+1),210,exp1},
                {640*2/(#BattleCCSB.CARDS.outCard+1),210,exp2}
            }
        end 
        exp1:setVisible(false) 
        exp2:setVisible(false)
        exp3:setVisible(false)

        exp1:setString(expStr) 
        exp2:setString(expStr)
        exp3:setString(expStr)

        layer:zorder(winOrderZ+ 1)

        local function resultShow()
            if result ~= PLAYER_WIN then
                win:setScale(1.0,1.0)
                wordTex       = CocosModuleMgr.getWordImage("adventureLose.png")
                g_head:scaleTo(0.1, 1) 
                if BattleCCSB.WIN.stop or isShare then
                    return
                end 
                BattleFuncMgr.enterJumpShow(win)
            else           
                if winAni then
                    return 
                end
                local winRes = CocosModuleMgr.getWordImage("Ui_zhandoujiesuan.png") 
                winAni = AnimationMgr.createAni(layer, winRes, 
                    320, 805)
                AnimationMgr.playAni(winRes, "animation", true)
                winAni:zorder(-1) 
            end
            win:loadTexture(wordTex)
        end

        local function arenaShow()
            for key,var in pairs(cards) do
                if var.expNum then
                    var.expNum:hide()
                end
                var:hide()
                pos[key][3]:setVisible(false)
            end
            scoreBK:show()
            scorePic:show()
            score:show()
            BK:setContentSize(640,216)
            moveBackLayer(layer,resultShow)
            
            local everyGrade  = BattlePVPMgr.geteveryArenaGrade()
            local organGrade  = BattlePVPMgr.getpvpArenaGrade()
            
            if everyGrade then 
                local lastGrade   = organGrade + everyGrade
                if everyGrade > 0  then
                    local gradeFont = display.newTTFLabel({
                                font  = "cuyuan_GBK.ttf",
                                text  = "",
                                color = cc.c3b(255,204,0), 
                                align = cc.TEXT_ALIGN_CENTER,
                                size  = 40
                            })
                    gradeFont:enableOutline({r=113,g=65,b=27,a=255},2)
                    gradeFont:addTo(layer) 
                    gradeFont:setPosition(320,240)
                    gradeFont:zorder(2)
                    gradeFont:enableShadow() 
                    local gradeStr =ArenaInfo.getPVPArenaGradeInfoById(lastGrade).gradeName
                    gradeStr = LuaSqlite.getLanguageByKey(gradeStr) 
                    local str=string.gsub(LuaSqlite.getLanguageByKey("arenapk12"),"<1>",gradeStr)
                    gradeFont:setString(str)
                    local effAniRes    = "Spine/arena/UI_JJCshengjie.png"
                    local effAni = AnimationMgr.createAni(layer, effAniRes, 
                            320, 240, "arena_shengjie") 
                    effAni:zorder(1)
                    AnimationMgr.playAniWithCallback(effAniRes, "animation", function()
                        -- transition.fadeOut(effAni, {time = 1}) 
                    end, "arena_shengjie", true)  
                elseif everyGrade < 0  then
                    local gradeFont = display.newTTFLabel({
                                font  = "cuyuan_GBK.ttf",
                                text  = "",
                                color = cc.c3b(214,214,214), 
                                align = cc.TEXT_ALIGN_CENTER,
                                size  = 40
                            })
                    gradeFont:enableOutline({r=113,g=65,b=27,a=255},2)
                    gradeFont:addTo(layer) 
                    gradeFont:setPosition(320,240)
                    gradeFont:zorder(2)
                    gradeFont:enableShadow() 
                    local gradeStr =ArenaInfo.getPVPArenaGradeInfoById(lastGrade).gradeName 
                    local str=string.gsub(LuaSqlite.getLanguageByKey("arenapk14"),"<1>",gradeStr)
                    gradeFont:setString(str)
                end
            end

            score:enableOutline({r=0,g=33,b=154,a=255},2)
            score:setTextColor({r=0,g=255,b=252,a=255})  
            score:enableShadow()  
            score:setString(BattlePVPMgr.getpvpArenaPoints())

            local everyPoints = BattlePVPMgr.geteveryArenaPoints()
            if everyPoints then
                if  everyPoints > 0  then
                    local scoreFont = display.newTTFLabel({
                            font  = "cuyuan_GBK.ttf",
                            text  = "+"..everyPoints,
                            color = cc.c3b(138,255,0), 
                            align = cc.TEXT_ALIGN_CENTER,
                            size  = 45
                        })  
                    local scoreSize = score:getContentSize()
                    local scorePosX,scorePosY = score:getPosition()
                    scoreFont:addTo(BK) 
                    scoreFont:setAnchorPoint(0,0.5)
                    scoreFont:setPosition(scorePosX+scoreSize.width+10,scorePosY)
                    scoreFont:enableShadow() 
                elseif everyPoints < 0 then
                    local scoreFont = display.newTTFLabel({
                            font  = "cuyuan_GBK.ttf",
                            text  = everyPoints,
                            color = cc.c3b(255,0,0), 
                            align = cc.TEXT_ALIGN_CENTER,
                            size  = 45
                        })
                    local scoreSize = score:getContentSize()
                    local scorePosX,scorePosY = score:getPosition()
                    scoreFont:addTo(BK) 
                    scoreFont:setAnchorPoint(0,0.5)
                    scoreFont:setPosition(scorePosX+scoreSize.width+10,scorePosY)
                    scoreFont:enableShadow() 
                end
            end

        end

        local function runDamage(index)
            if not tottalDamages[index] then
                moveBackLayer(layer,resultShow)
                return  
            end
            local damagePets_P = copyDamagePets[tottalDamages[index].team][tottalDamages[index].attackIndex]
            if damagePets_P.wait_sp then 
                damagePets_P.wait_sp:hide() 
            end
            if type(tottalDamages[index].damage) == "number" then
                local previousVa = damagePets_P.damageValue

                damagePets_P.damageValue = damagePets_P.damageValue + tottalDamages[index].damage
                local gap = damagePets_P.damageValue - previousVa
                local per = damagePets_P.damageValue*100/damageMax
                local numSpeed      = math.ceil(speed/40 * gap )
                
                upDateNum(damagePets_P.damage,previousVa,numSpeed,damagePets_P.damageValue,false,function() 
                        index = index + 1
                        runDamage(index)
                    end,damagePets_P.bar) 

                -- CocosModuleMgr.setLoadingBarPercent(damagePets_P.bar, per, 3, nil)
                if gap <= 0 then
                    return
                end
            elseif type(tottalDamages[index].damage) == "string" then
                damagePets_P.killPets = damagePets_P.killPets + 1
                local head_Sp = display.newFilteredSprite(damagePets_P.headRes, "BRIGHTNESS",{0.4}) 
                head_Sp:addTo(damagePets_P.head)  
                local sp_Size = head_Sp:getContentSize()
                head_Sp:setPosition(sp_Size.width/2,sp_Size.height/2)
                local team = TEAM_A
                local killEffectX = -97

                if tottalDamages[index].team == 0 then
                    team = TEAM_B 
                    killEffectX = 132
                end 
                local deadPet = copyDamagePets[team][tottalDamages[index].defenceIndex]
                local function deadShow()
                    if BattleCCSB.WIN.stop or isShare then
                        return
                    end
                    if deadPet.wait_sp then 
                        deadPet.wait_sp:hide()  
                    end 
                    head_Sp:removeFromParent()
                        if damagePets_P.killPets > 1 then
                            
                            local kill_posX ,kill_posY = 228,40 
                            local sp = nil
                            if damagePets_P.kill_sp then 
                                sp = damagePets_P.kill_sp
                            end
                            if tottalDamages[index].team == TEAM_B then 
                                kill_posX ,kill_posY = -180,40
                            end
                            if isRunDamage then
                                local skillSoundStr = "doubleKill"
                                if damagePets_P.killPets == 3 then
                                    skillSoundStr = "tripleKill"
                                end 
                                GameAudio.playBattleSound(skillSoundStr)
                            end   
                            damagePets_P.kill_sp = display.newSprite(CocosModuleMgr.getWordImage("kill_"..damagePets_P.killPets..".png"))
                            damagePets_P.kill_sp:addTo(damagePets_P.node)
                            damagePets_P.kill_sp:setPosition(kill_posX,kill_posY)
                            BattleFuncMgr.enterSceneShow(damagePets_P.kill_sp,function()
                                    if sp then
                                        sp:removeFromParent()
                                    end
                                end)
                            BattleCANI.doubleKillEffect(damagePets_P.node,killEffectX,85,tottalDamages[index].team)
                        end 
                        local dead = display.newSprite(CocosModuleMgr.getWordImage("jiesuan_siwang.png")) 
                        
                        dead:addTo(deadPet.node) 
                        dead:setPosition(10,50)  
                        dead:setRotation(-40)
                        BattleFuncMgr.setNodeGray(deadPet.head,false) 
                        index = index + 1
                        runDamage(index)
                end
                if isRunDamage then
                    GameAudio.playBattleSound("monsterDie")  
                    BattleCANI.killPetCardHead(deadPet.node,20,20)
                    BattleFuncMgr.vibrationScene(SceneMgr.getRunningScene,function()
                        deadShow()
                    end)
                else
                    deadShow()
                end
                
            end
        end

        local function damageShow() 
            isRunDamage = true
            teamA_db:show()
            summLabel:setString(expBtnStr)
            for key,var in pairs(cards) do
                if var.expNum then
                    var.expNum:hide()
                end
                var:hide()
                pos[key][3]:setVisible(false)
            end

            if not isFirstDamage then
                for key,var in pairs(copyDamagePets) do 
                    for k,v in pairs(var) do 
                        if v.dead then          
                            v.node:removeFromParent()
                        end
                        if v.kill_sp then
                            v.kill_sp:removeFromParent()
                        end
                    end
                end
                local damageIndex = 1
                copyDamagePets = clone(damagePets)
                
                exp1:setVisible(false)
                exp2:setVisible(false)
                exp3:setVisible(false)
                for key,var in pairs(copyDamagePets[TEAM_A]) do
                    var.node:show()
                    if var.wait_sp then 
                        var.wait_sp:show() 
                    end
                    var.bar:setPercent(0)
                end
                for key,var in pairs(copyDamagePets[TEAM_B]) do
                    var.node:show()
                    if var.wait_sp then 
                        var.wait_sp:show() 
                    end
                    var.bar:setPercent(0)
                end

                BattleFuncMgr.enterSceneShow(BK,function() 
                        if tottalDamages then
                            runDamage(1)
                        end
                    end)
                isFirstDamage = true
            end
        end
        
        local function expShow()    
            isRunDamage = false
            summLabel:setString(damageBtnStr)
            teamA_db:hide()

            if not isFirstExp then
                isFirstExp = true
                exp1:setVisible(false)
                exp2:setVisible(false)
                exp3:setVisible(false) 
                local filePath = cc.FileUtils:getInstance():fullPathForFilename(BattleLabelAtlas.BATTLELABEL[AtlasStr][1])
                for key,var in pairs(BattleCCSB.CARDS.outCard) do
                    local level  = cards[key]:getChildByName("level")
                    local bar    = cards[key]:getChildByName("bar")
                    local cardIndex = key
                    local levelNum  = BattleCCSB.CARDS.outCard[key].lvNum

                    bar:loadTexture("Battle/summer_A/fight_article_blood_blue.png") 

                    local rarePoint = BattleCCSB.CARDS.outCard[key].rarePoint
                    local lastLv,lastExp,isFullLevel =  PetFeedViewMgr.commonTryFeed(levelNum, BattleCCSB.CARDS.outCard[key].exp, 
                            expValue,rarePoint)
                    
                    local orgPer = 0
                    if lastLv > 0 then
                        bar:setPercent(orgPer)
                    else
                        local befExpMax = ExperienceInfo.getExperienceInfoByID(levelNum).petExpVec[rarePoint]
                            - ExperienceInfo.getExperienceInfoByID(levelNum-1).petExpVec[rarePoint]
                        local currExp  = BattleCCSB.CARDS.outCard[key].exp 
                            - ExperienceInfo.getExperienceInfoByID(levelNum-1).petExpVec[rarePoint]
                        orgPer = currExp*100/befExpMax 
                        bar:setPercent(orgPer) 
                    end
                    levelNum = levelNum + lastLv
                    local maxexp = ExperienceInfo.getExperienceInfoByID(levelNum).petExpVec[rarePoint]
                        - ExperienceInfo.getExperienceInfoByID(levelNum-1).petExpVec[rarePoint]
                        
                    local per = lastExp*100/maxexp

                    level:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1) 
                    level:setString("Lv"..levelNum) 
                    cards[key]:setPosition(-200,pos[key][2])
                    cards[key]:show()
                    cards[key]:setScale(1.7,1.7)
                    BattleFuncMgr.setNodeGray(cards[key],true)
                    pos[key][3]:setVisible(true) 
                    local strValue = "/0"

                    cards[key].expNum = BattleFuncMgr.CCSUILoader:createLabelAtlas({
                        stringValue = strValue,
                        charMapFileData = {path = filePath},
                        itemWidth = BattleLabelAtlas.BATTLELABEL[AtlasStr][2],
                        itemHeight = BattleLabelAtlas.BATTLELABEL[AtlasStr][3],
                        startCharMap = BattleLabelAtlas.BATTLELABEL[AtlasStr][4],
                        x = 10,
                        y = 10,
                        ignoreSize = true})
                    cards[key].expNum:addTo(BK)
                    cards[key].expNum:setPosition(-200,80) 
                    SceneMgr.getRunningScene:performWithDelay(function()
                            if BattleCCSB.WIN.stop or isShare then
                                return
                            end
                            local expPosX,expPosY = pos[cardIndex][3]:getPosition()
                            cards[cardIndex]:moveTo(0.2, pos[cardIndex][1], pos[cardIndex][2])
                            cards[cardIndex].expNum:moveTo(0.2, pos[cardIndex][1], 80)
                            pos[cardIndex][3]:moveTo(0.2, pos[cardIndex][1], expPosY)
                            local perValue  = math.ceil(expValue/30)  
                            local perAdd    = math.ceil((per - orgPer)/30)
                            SceneMgr.getRunningScene:performWithDelay(function()
                                if BattleCCSB.WIN.stop or isShare then
                                    return
                                end 
                                upDateNum(cards[cardIndex].expNum,0,perValue,expValue,true)  
                                CocosModuleMgr.setLoadingBarPercent(bar, per, perAdd, nil)
                            end, 0.2)
                        end, 0.2*(key-1)) 
                
                end
                moveBackLayer(layer,resultShow) 
            else
                for key,var in pairs(cards) do
                    var.expNum:show()
                    var:show()
                    pos[key][3]:setVisible(true)
                end 
            end
        end
        if BattlePVPMgr.isPVPArenaBattle == PVP_YES_ARENA then
            arenaShow() 
        elseif typeStr == "damageShow" then 
            damageShow()
        else
            expShow()
        end
        local quiteLabel = CSResourceMgr.getNodeByName(res, "quite"):getTitleRenderer()
        quiteLabel:enableOutline({r=0,g=0,b=0,a=255}, 1)
        quiteLabel:setString(BattleLangDB["quit"])
        CSResourceMgr.clickEventBinding(res, "quite", function() 
            BattleCCSB.WIN.stop = true
            if expPotential then
                expPotential:removeFromParent()
            end
            if winAni then
                winAni:removeFromParent()
            end
            BattleUIMgr.cleanUIMgr()
            BattleMapMgr.cleanPVPInfo()
            layer:removeFromParent()
            layer_BK:removeFromParent()
            SceneMgr.mapEnterType = 99
            SceneMgr.replaceScene(parent, SceneMgr.previousScene)
			
            if BattleGuide.funcs[GUIDE_FINISH] then
                BattleGuide.funcs[GUIDE_FINISH]()
                BattleGuide.funcs[GUIDE_FINISH] = nil
            end
            BattleMapMgr.setNewExp(0)
        end, "", 3)

        local shareLabel = CSResourceMgr.getNodeByName(res, "share"):getTitleRenderer()
        shareLabel:enableOutline({r=0,g=0,b=0,a=255}, 1)
        shareLabel:setString(BattleLangDB["replay"])
        CSResourceMgr.clickEventBinding(res, "share", function()
            BattleCCSB.WIN.stop = true 
            isShare = true
            audio.stopAllSounds() 
            if expPotential then
                expPotential:removeFromParent()
            end
            if winAni then
                winAni:removeFromParent()
            end
            BattleUIMgr.cleanUIMgr() 
            BattleCotroller.bossHP          = nil
            BattleCotroller.lastbossHP      = nil
            layer:removeFromParent()
            layer_BK:removeFromParent()
            display.removeUnusedSpriteFrames()
            BattleCCSB.stopAutoBattle()
            BattleUIMgr.startRecord()
        end,"", 3)
        if not BattleMapMgr.getCanShareBattle() then
            share:hide()
        end
        CSResourceMgr.clickEventBinding(res, "realShare", function()
            BattleCotroller.shareBattleRecord(TownChatMgr.shareBattleToChat)
        end,"", 3)
        -- CocosModuleMgr.showUIAnimation(layer, "up", nil)
        if canChange then
            CSResourceMgr.clickEventBindingByNode(summBtn, function()
                if typeStr == "damageShow" then
                    expShow() 
                    typeStr = "expShow"
                else
                    damageShow()
                    typeStr = "damageShow"
                end
            end, 3)
        else
            summBtn:hide()
        end
    end

    local funcs = {}
    funcs[1] = createBK 
    funcs[2] = createDetails
    UnblockLoader.load(funcs, "battleOver") 
end


 
function BattleCCSB.createAddButton(node)
    display.addImageAsync(addBtnRes,function() 
            local parentPosX,parentPosY = node:getPosition() 
 
            if BattleCCSB.CATCH.add_Sp then
                BattleCCSB.CATCH.add_Sp:removeFromParent()
                BattleCCSB.CATCH.add_Sp = nil
            end
            BattleCCSB.CATCH.add_Sp = display.newSprite(addBtnRes)
            BattleCCSB.CATCH.add_Sp:pos(parentPosX+70,parentPosY+30) 
            BattleCCSB.CATCH.add_Sp:addTo(BattleCCSB.CATCH.layer)
            BattleCCSB.CATCH.add_Sp:zorder(10) 
        end)
end

function BattleCCSB.createHunterPotential(key)
    local potential,levelNum = AchievementListMgr.getSkillUpInfo(key) 
    if potential then
        local db       = display.newSprite("Battle/catch/potential_frame_su.png")
        local db_size  = db:getContentSize()
        local aid_base      = display.newSprite("UI/CommonFiles/skill_aid_base_green_01.png")
        local aid_base_size = aid_base:getContentSize()
        local skillIcon     = display.newSprite("Battle/skillIcon/"..potential.icon)

        db:addTo(SceneMgr.getRunningScene)
        db:setPosition(display.cx*2,display.cy*2-40)
            
        db:setAnchorPoint(1.0,0.5)
        db:zorder(20)
            
        aid_base:addTo(db)
        aid_base:setScale(0.5,0.5)
            
        aid_base:setPosition(0,db_size.height/2)
            
        skillIcon:addTo(aid_base)
        skillIcon:setPosition(aid_base_size.width/2,aid_base_size.height/2)

        local level = display.newTTFLabel({
            font = "cuyuan_GBK.ttf",
            text = "Lv"..levelNum,
            size = 18, 
            align = cc.TEXT_ALIGN_CENTER, 
            color = display.COLOR_WHITE
        })

        level:addTo(db)
        level:setPosition(0,0) 
        level:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1)
        return db
    else
        return nil
    end

    return true
end
function BattleCCSB.checkIsFullBag()
    local num = CharInfo.get().itempacketnum+(CharInfo.get().furnituresuitcasevaluerate or 0)
    if BagViewMgr.refreshItemInfo() >= num then
        return true
    else
        return false
    end
end


function BattleCCSB.createCatchUI(parent,petInfo)

    BattleCCSB.MENU.pauseBtn:setTouchEnabled(false)
    BattleCCSB.MENU.auto:setTouchEnabled(false)
    BattleCCSB.MENU.speed:setTouchEnabled(false)
    BattleCCSB.DOWNEDGE.layer:hide()
    BattleCCSB.DOWNBLOOD.status:hide()
    BattleCCSB.UPBLOOD.status:hide()
    BattleCCSB.UPBLOOD.ballPos:hide()
    BattleCCSB.MENU.layer:hide()
    BattleCCSB.UPBLOOD.catchTimes:setVisible(true)
    BattleCCSB.GROUNDBACK.blackBg:fadeIn(0.5)

    BattleCCSB.createHunterPotential("hunter")

    BattleCCSB.CATCH.res    = "Battle/catch/catchDown.csb"
    BattleCCSB.CATCH.layer  = CSResourceMgr.createRes(parent, BattleCCSB.CATCH.res)
    BattleCCSB.CATCH.giveup = CSResourceMgr.getNodeByName(BattleCCSB.CATCH.res,"giveup")
    BattleCCSB.CATCH.rareDB = CSResourceMgr.getNodeByName(BattleCCSB.CATCH.res,"rareDB")
    BattleCCSB.CATCH.ballName = {}

    BattleCCSB.CATCH.ballName[1] = CSResourceMgr.getNodeByName(BattleCCSB.CATCH.res,"ballName1")
    BattleCCSB.CATCH.ballName[2] = CSResourceMgr.getNodeByName(BattleCCSB.CATCH.res,"ballName2")
    BattleCCSB.CATCH.ballName[3] = CSResourceMgr.getNodeByName(BattleCCSB.CATCH.res,"ballName3")

    CSResourceMgr.setSpriteTextureByNode(BattleCCSB.CATCH.ballName[1],
         CocosModuleMgr.getWordImage("bz_ball1.png")) 
    CSResourceMgr.setSpriteTextureByNode(BattleCCSB.CATCH.ballName[2],
         CocosModuleMgr.getWordImage("bz_ball2.png"))
    CSResourceMgr.setSpriteTextureByNode(BattleCCSB.CATCH.ballName[3],
         CocosModuleMgr.getWordImage("bz_ball3.png"))
    -- BattleCCSB.CATCH.rare   = CSResourceMgr.getNodeByName(BattleCCSB.CATCH.res,"rare") 
    BattleCCSB.CATCH.ball   = {}
    BattleCCSB.CATCH.num    = {}
    BattleCCSB.CATCH.gafBallRes     = {}
    BattleCCSB.CATCH.addBtn         = {}
    BattleCCSB.CATCH.rateStr        = {}
    BattleCCSB.CATCH.catchRate      = {}
    BattleCCSB.CATCH.clickDB        = {}
    BattleCCSB.CATCH.addcatchRate   = 0
    BattleCCSB.CATCH.ballCatchTimes = 1
    BattleCCSB.CATCH.layer:zorder(catchOrderZ)
    BattleCCSB.CATCH.rareDB:hide()
    -- BattleCCSB.CATCH.rare:hide()

    CocosModuleMgr.setEdgeDistance(BattleCCSB.CATCH.layer, 0, nil, nil, 0, false)

    local increaseCatch = 0
    if PurchaseViewMgr.getMonthCardInfo() then
        increaseCatch = 1
    end
    local catchRateAddCount = CharInfo.get().catchrateaddcount or 0
    BattleCCSB.CATCH.tottalCapture     = petInfo[1]["monster"]["capture"] + increaseCatch
    BattleCCSB.CATCH.captureNum        = BattleCCSB.CATCH.tottalCapture
    local selectedBalls     = {false,false,false} 
    local ballRarePoint     = {"c","b","a","s","ss"}
    local petRarePoint      = ballRarePoint[petInfo[1].rarePoint]

    if not petRarePoint then
        petRarePoint = "c"
    end

    if catchRateAddCount>0 then
        BattleCCSB.UPBLOOD.catchTimes:setAnchorPoint(0.5, 1)
        BattleCCSB.UPBLOOD.catchTimes:setString(BattleLangDB["restTimes"]..BattleCCSB.CATCH.captureNum.."/"..BattleCCSB.CATCH.tottalCapture..
            "\n"..CocosModuleMgr.createStringWithFormat({"activity72", catchRateAddCount}))
    else
        BattleCCSB.UPBLOOD.catchTimes:setString(BattleLangDB["restTimes"]..BattleCCSB.CATCH.captureNum.."/"..BattleCCSB.CATCH.tottalCapture)
    end 

    local function setSelect(i,isBool) 
        -- local ballBtn = ""
        if isBool then
            CocosModuleMgr.setScreenTouch(false)

            local PVESend = require("src.Net.Send.PVESend")
            NetInterface.sendWithBlock("GC_PVEPOKEMONCATCH_ACK", function()
                PVESend.sendCG_PVEPokemonCatch_Req({pokemonID = BattleMapMgr.getCanCatchPet(),itemID = ballOrder[i]})
            end, nil, nil, nil, false)
            BattleCCSB.CATCH.clickDB[i]:show()
            -- ballBtn = "Battle/catch/bz_di2.png"
            -- CSResourceMgr.setButtonTextureByNode(BattleCCSB.CATCH.ball[i],ballBtn,ballBtn,ballBtn)
        else
            BattleCCSB.CATCH.clickDB[i]:hide()
            -- ballBtn = "Battle/catch/bz_di.png"
            -- CSResourceMgr.setButtonTextureByNode(BattleCCSB.CATCH.ball[i],ballBtn,ballBtn,ballBtn)
        end
    end
    BattleCCSB.CATCH.add = CSResourceMgr.getNodeByName("Battle/catch/catchDown.csb",{"catchBall3","add"})
    BattleCCSB.CATCH.up_Sp = {}
    
    for i = 1,3 do 
        BattleCCSB.CATCH.ball[i]    = CSResourceMgr.getNodeByName("Battle/catch/catchDown.csb","catchBall"..i)
        BattleCCSB.CATCH.num[i]     = CSResourceMgr.getNodeByName("Battle/catch/catchDown.csb","ballNum"..i)
        BattleCCSB.CATCH.rateStr[i] = CSResourceMgr.getNodeByName("Battle/catch/catchDown.csb","catchRate"..i)
        BattleCCSB.CATCH.clickDB[i] = CSResourceMgr.getNodeByName("Battle/catch/catchDown.csb","clickDB"..i)

        if catchRateAddCount>0 then
            BattleCCSB.CATCH.rateStr[i]:setTextColor({r = 148,g = 254,b = 6,a=238})
            
            local strSize = BattleCCSB.CATCH.rateStr[i]:getContentSize()
            BattleCCSB.CATCH.up_Sp[i] = display.newSprite("Battle/catch/potential_buff_01.png")
            BattleCCSB.CATCH.up_Sp[i]:addTo(BattleCCSB.CATCH.rateStr[i])
            BattleCCSB.CATCH.up_Sp[i]:setPosition(strSize.width+10,strSize.height/2)
        else
            BattleCCSB.CATCH.rateStr[i]:setTextColor({r = 158,g = 185,b = 232,a=255})
        end
        BattleCCSB.CATCH.rateStr[i]:enableOutline({r = 0,g = 0,b = 0,a=255}, 1) 
        BattleCCSB.CATCH.clickDB[i]:hide()

        BattleUIMgr.ballNum[i]      = ItemInfo.getCharItemNum(ballOrder[i])

        local children  = BattleCCSB.CATCH.ball[i]:getChildren()
        -- local nameSpri  = CSResourceMgr.getNodeByName("Battle/catch/catchDown.csb","ballName"..i)
        -- local ballSpri  = CSResourceMgr.getNodeByName("Battle/catch/catchDown.csb","bz_jlq"..i)
        -- CSResourceMgr.setSpriteTextureByNode(nameSpri, "Words/Battle/bz_ball"..i..".png")
        -- CSResourceMgr.setSpriteTextureByNode(ballSpri, ballRes[i])
        -- ballSpri:setScale(1.25,1.25)
        local rateInfo = ItemInfo.getPokemonBallInfoById(ballOrder[i])
        BattleCCSB.CATCH.catchRate[i] = rateInfo[petRarePoint][1] 
        BattleCCSB.CATCH.catchRate[i] = math.floor(BattleCCSB.CATCH.catchRate[i])
        if BattleCCSB.CATCH.catchRate[i] > 100 then 
            BattleCCSB.CATCH.catchRate[i] = 100 
        end

        if i == 3 then 
            if BattleUIMgr.ballNum[i] <= 0 then
                BattleCCSB.CATCH.add:show()
            else
                BattleCCSB.CATCH.add:hide()
            end 
        end

        if catchRateAddCount>0 then
            BattleCCSB.CATCH.rateStr[i]:setString(BattleCCSB.CATCH.catchRate[i]+ActivityViewMgr.getCatchPetValue().value.."%"..BattleLangDB["rate"])
        else
            BattleCCSB.CATCH.rateStr[i]:setString(BattleCCSB.CATCH.catchRate[i].."%"..BattleLangDB["rate"])
        end        
        BattleCCSB.CATCH.num[i]:setString("X"..BattleUIMgr.ballNum[i])
        BattleCCSB.CATCH.num[i]:enableOutline({r = 0,g = 0,b = 0,a = 255}, 1) 
        CSResourceMgr.clickEventBindingByNode(BattleCCSB.CATCH.ball[i],function()
            BattleFuncMgr.bubbleButton(BattleCCSB.CATCH.ball[i])
            if i == 3 then
                if BattleUIMgr.ballNum[i] <= 0 then
                    if not BattleCCSB.checkIsFullBag() then
                        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,2,"advtips9",function()             
                                NetInterface.sendWithBlock("GC_BUYMARKETITEM_ACK", function()
                                    local MarketSend = require("src.Net.Send.MarketSend")
                                    MarketSend.sendCG_BuyMarketItem_Req({marketInfoID = 201,num = 1})
                                end,function() 
                                    -- CSResourceMgr.setLabelString("Battle/catch/catchDown.csb","ballNum"..BattleUIMgr.ballID, 
                                    -- "X1","",nil,0)
                                    BattleCCSB.CATCH.add:hide() 
                                    BattleCCSB.CATCH.num[i]:setString("X1")
                                    BattleUIMgr.ballNum[i] = 1
                                    -- BattleCCSB.CATCH.add_Sp:removeFromParent()
                                    -- BattleCCSB.CATCH.add_Sp = nil
                                end,function(code)
                                    -- print("code........",code) ---------ERROR_NOTENOUGH_RMB
                                   if Proto.Error.ERROR_NOTENOUGH_RMB == code then  
                                        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,2,"advtips4",function()             
                                    
                                        end,nil,nil,false)
                                   end 
                                end)
                            end,nil,nil,false)
                         
                    else
                        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,1,"idling20",function()             
                                
                            end)
                    end
                    return
                end
            end

            if BattleUIMgr.ballNum[i] <= 0 then
                StandardTipsMgr.show(1, BattleLangDB["noenough"]) 
                return
            end
            BattleCCSB.CATCH.captureNum = BattleCCSB.CATCH.captureNum - 1
            if BattleCCSB.CATCH.captureNum < 0 then
                StandardTipsMgr.show(1, BattleLangDB["timeLimit"])
                BattleCCSB.CATCH.captureNum = 0
                return
            end

            BattleCCSB.CATCH.ballCatchTimes = BattleCCSB.CATCH.ballCatchTimes + 1

            BattleCCSB.CATCH.gafBallRes = ballGafRes[i]
            BattleCCSB.setCatchButtonEnabled(false)
            
            local catchCount = CharInfo.get().catchrateaddcount or 0
            if catchCount>0 then
                catchCount = catchCount-1
                BattleCCSB.UPBLOOD.catchTimes:setString(BattleLangDB["restTimes"]..BattleCCSB.CATCH.captureNum.."/"..BattleCCSB.CATCH.tottalCapture..
                    "\n"..CocosModuleMgr.createStringWithFormat({"activity72", catchCount}))
            else
                BattleCCSB.UPBLOOD.catchTimes:setString(BattleLangDB["restTimes"]..BattleCCSB.CATCH.captureNum.."/"..BattleCCSB.CATCH.tottalCapture)
            end

            BattleUIMgr.ballID = i
            for index = 1,3 do
                if index ~= i then
                    setSelect(index,false)
                    selectedBalls[index] = false
                end
            end
            if selectedBalls[i] then
                selectedBalls[i] = false
            else
                selectedBalls[i] = true
            end

            setSelect(i,true)
        end,1)
    end
    local giveupStr = LuaSqlite.getLanguageByKey("advtext14")
    local giveupTTF = display.newTTFLabel({
            font = "cuyuan_GBK.ttf",
            text = giveupStr,
            size = 32,
            align = cc.TEXT_ALIGN_CENTER,
            color = display.COLOR_WHITE
        })
    giveupTTF:enableOutline({r=0,g=0,b=0}, 2)  
    giveupTTF:addTo(BattleCCSB.CATCH.giveup)
    giveupTTF:setPosition(100,40) 

    CSResourceMgr.clickEventBindingByNode(BattleCCSB.CATCH.giveup, function()
        BattleFuncMgr.bubbleButton(BattleCCSB.CATCH.giveup)
        BattleCCSB.CATCH.giveup:setTouchEnabled(false)
        for i = 1,3 do
            BattleCCSB.CATCH.ball[i]:setTouchEnabled(false)
        end
        BattleUIMgr.winShow(PLAYER_WIN)
        CocosModuleMgr.setScreenTouch(true) 
    end,1)
    -- if BattleUIMgr.ballNum[1] == 0 and BattleUIMgr.ballNum[2] == 0 and BattleUIMgr.ballNum[3] == 0 then
    --     BattleCCSB.CATCH.giveup:setTouchEnabled(false)
    --     for i = 1,3 do
    --         BattleCCSB.CATCH.ball[i]:setTouchEnabled(false)
    --     end
    --     BattleUIMgr.winShow(PLAYER_WIN)
    --     CocosModuleMgr.setScreenTouch(true)
    -- else  
        if  BattleUIMgr.firstBattle == 2 then 
            NpcDialogueMgr.show(25, function()
                CocosModuleMgr.setButtonGuide(BattleCCSB.CATCH.ball[1],2.5,nil)
            end)
        end
    -- end
end

function BattleCCSB.setCatchButtonEnabled(isbool)
    for i = 1,3 do
        BattleCCSB.CATCH.ball[i]:setTouchEnabled(isbool)
        BattleFuncMgr.setNodeGray(BattleCCSB.CATCH.ball[i],isbool)
    end
    BattleCCSB.CATCH.giveup:setTouchEnabled(isbool) 
    BattleFuncMgr.setNodeGray(BattleCCSB.CATCH.giveup,isbool)
end

function BattleCCSB.loadingBattle(parent)
    local  timeSpri = display.newSprite("Battle/battleScene/resLoading.png")
    local BattleLoadRes       = require("src.GameMgr.Battle.BattleLoadRes")
    
    local battleProgress = cc.ProgressTimer:create(timeSpri) 
    battleProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR) 
    battleProgress:addTo(parent)
    battleProgress:setPosition(display.cx,display.cy)
    battleProgress:setMidpoint(cc.p(0,0.5)) 
    battleProgress:setBarChangeRate(cc.p(1,0))
    battleProgress:zorder(100)
    battleProgress:setPercentage(0)

    local curTime = 0 
    local curPer = 0
    local tattolTimes = #BattleLoadRes.reses
    local addper = 100/tattolTimes
    for resID = 1 , #BattleLoadRes.reses do
        display.addImageAsync(BattleLoadRes.reses[resID],function()
                curPer = curPer + addper
                curTime = curTime + 1
                battleProgress:setPercentage(curPer)
                if curTime == tattolTimes then
                    battleProgress:setPercentage(100)
                    battleProgress:removeFromParent()
                    BattleUIMgr.addUI()
                end
            end) 
    end

end

function BattleCCSB.cleanCSB()
    stopAuto          = false
    stopQuit          = false

    if BattleCCSB.TIME.progressTime then
        BattleCCSB.TIME.progressTime:removeFromParent()
        BattleCCSB.TIME.progressTime = nil
    end

    BattleCCSB.closeWeather()
    BattleCCSB.closeSixMap() 
    BattleCCSB.closeBuffTips()

    if BattleCCSB.TIME.roundNum then
        BattleCCSB.TIME.roundNum:removeFromParent()
        BattleCCSB.TIME.roundNum = nil
    end

    -- if BattleCCSB.CATCH.add_Sp then
    --     BattleCCSB.CATCH.add_Sp:removeFromParent()
    --     BattleCCSB.CATCH.add_Sp = nil
    -- end

    if BattleCCSB.CATCH.rarePoint then
        BattleCCSB.CATCH.rarePoint:removeFromParent()
        BattleCCSB.CATCH.rarePoint = nil
    end

    if BattleCCSB.CATCH.xiyou then
        BattleCCSB.CATCH.xiyou:removeFromParent()
        BattleCCSB.CATCH.xiyou = nil
    end

    if BattleCCSB.TIME.timeNum then
        BattleCCSB.TIME.timeNum:removeFromParent()
        BattleCCSB.TIME.timeNum = nil
    end

    if BattleCCSB.TIME.res then
        CSResourceMgr.removeCSObjectByTag(BattleCCSB.TIME.res)
    end
    if BattleCCSB.PVSE.res then
        CSResourceMgr.removeCSObjectByTag(BattleCCSB.PVSE.res)
    end
    if BattleCCSB.DOWNBLOOD.res then
        CSResourceMgr.removeCSObjectByTag(BattleCCSB.DOWNBLOOD.res)
    end
    if BattleCCSB.UPBLOOD.res then
        CSResourceMgr.removeCSObjectByTag(BattleCCSB.UPBLOOD.res)
    end
    if BattleCCSB.CATCH.res then
        CSResourceMgr.removeCSObjectByTag(BattleCCSB.CATCH.res)
    end
 
    
    BattleCCSB.TIME         = {}
    BattleCCSB.PVSE         = {}
    BattleCCSB.DOWNBLOOD    = {}
    BattleCCSB.UPBLOOD      = {}
    BattleCCSB.CATCH        = {}

end

return BattleCCSB
