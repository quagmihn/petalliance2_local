local LtFuncMgr = {}

LtFuncMgr.EVENT_TYPE_STRING = {
    "picking",           --事件类型1
    "monster",           --事件类型2   
    "obstruction",       --事件类型3
    "exit",              --事件类型4  
    "enterance",         --事件类型5
    "switch",            --事件类型6
    "csm",               --事件类型7 
    "trainer",           --事件类型8
}

LtFuncMgr.FireBlock = 0

function LtFuncMgr.Init()
end

-- ###################   _协议处理_   ###########################

function LtFuncMgr.sendMoveReq(params)

    local newCell = params.newCell
    local successCallback = params.successCallback
    local errorCallback   = params.errorCallback

    local _col, _row = LtMapOption.convertToCoord(newCell)
    NetInterface.send("GC_MOVENEWCELL_ACK", function()
        local LostTowerSend = require("src/Net/Send/LostTowerSend.lua")
        LostTowerSend.sendCG_moveNewCell_Req({ x=_row, y=_col, })
    end, function()
        if successCallback then successCallback() end
    end,function(code)
        if errorCallback then errorCallback(code) end
    end)
    
end

function LtFuncMgr.sendFireReq(params)
    SearchingMgr.canMove = false
    
--    if not NetInterface.isConnect then
--        SearchingMgr.canMove = true
--        return
--    end

    if LostTowerMgr.newCells[1] then
        print("LT_DEBUG_INFO: Delay to avoid duplicated request")
        SceneMgr.getRunningScene:performWithDelay(function()
            LtFuncMgr.sendFireReq(params)
        end,0.5)
        
        return
    end
    
    local fireCell = params.fireCell
    local successCallback = params.successCallback
    local errorCallback   = params.errorCallback
    
    local _col,_row = LtMapOption.convertToCoord(fireCell)
    NetInterface.sendWithBlock("GC_FIREEVENTCELL_ACK", function()
        local LostTowerSend = require("src/Net/Send/LostTowerSend.lua")
        LostTowerSend.sendCG_fireEventCell_Req({ x=_row, y=_col, })
    end, function()
        if successCallback then successCallback() end
        SearchingMgr.canMove = true
    end, function(code)
        if errorCallback then errorCallback(code) end
        SearchingMgr.canMove = true
    end)
    
end

function LtFuncMgr.sendMoneyOpenChest(params)
    SearchingMgr.canMove = false
    
    local fireCell = params.fireCell
    local successCallback = params.successCallback
    local errorCallback   = params.errorCallback

    local _col,_row = LtMapOption.convertToCoord(fireCell)
    NetInterface.sendWithBlock("GC_MONEYOPENCHEST_ACK", function()
        local LostTowerSend = require("src/Net/Send/LostTowerSend.lua")
        LostTowerSend.sendCG_MoneyOpenChest_Req({ x=_row, y=_col, })
    end, function()
        if successCallback then successCallback() end
        SearchingMgr.canMove = true
    end, function(code)
        if errorCallback then errorCallback(code) end
        SearchingMgr.canMove = true
    end)
end

-- ###################  effect functions  ##########################

-- 副本名称特效显示
function LtFuncMgr.showAdvName(parent, _advName, _floor, bUseConfig)
    parent = parent or SceneMgr.getRunningScene
    if bUseConfig == nil then
        bUseConfig = true
    end

    local layer = CSResourceMgr.createRes(parent,"Searching/Other/adventureName.csb")
    CocosModuleMgr.setRelativePosition(layer,320,480)
    local nameLabel = CSResourceMgr.getNodeByName("Searching/Other/adventureName.csb","advNameLabel")
    local floorLabel = CSResourceMgr.getNodeByName("Searching/Other/adventureName.csb","floorLabel")
    
    CSResourceMgr.setLabelStringByNode(nameLabel,_advName,CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
    
    local floorText
    if bUseConfig then
        floorText = SearchingMapMgr.fbFloorNameConfig.get(SearchingMapMgr.currAdventure)["f".._floor] or ""
    else
        floorText = "f".._floor
    end
    CSResourceMgr.setLabelStringByNode(floorLabel,floorText,CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)

    nameLabel:setOpacity(0)
    nameLabel:setScaleY(0)
    floorLabel:setOpacity(0)
    floorLabel:setScaleY(0)

    transition.fadeIn(nameLabel, {time = 0.3})
    transition.scaleTo(nameLabel, {scaleY = nameLabel:getScaleX(), time = 0.3})
    transition.fadeIn(floorLabel, {time = 0.3})
    transition.scaleTo(floorLabel, {scaleY = nameLabel:getScaleX(), time = 0.3})

    local eff = AnimationMgr.createAni(layer,"Spine/effects/UI_changjingmingcheng.png",290,660)
    eff:setScale(0.6)
    AnimationMgr.setSpeedRate("Spine/effects/UI_changjingmingcheng.png",0.8)
    AnimationMgr.playAniWithCallback("Spine/effects/UI_changjingmingcheng.png","animation",function()
        transition.fadeOut(nameLabel, {time = 0.5})
        transition.fadeOut(floorLabel, {time = 0.5})
        SceneMgr.getRunningScene:performWithDelay(function()
            AnimationMgr.removeGafObjectByTag("Spine/effects/UI_changjingmingcheng.png")
            CSResourceMgr.removeCSObjectByTag("Searching/Other/adventureName.csb")
        end,0.5)
    end)
end

function LtFuncMgr.pickEffect(block, awardsInfo)
    if type(awardsInfo) ~= "table" then return end
    
    -- check to see if the item is a key
    local function isKey(itemID)
        for key, value in pairs(LostTowerUIMgr.keys) do
            if itemID == value.ID then
                return key
            end
        end
        return 0
    end
    
    local tmpAwardsVec = {}
    local function addTmpAward(key, num)
        if tmpAwardsVec[key] then
            tmpAwardsVec[key] = tmpAwardsVec[key]+num
        else
            tmpAwardsVec[key] = num
        end
    end
    
    local cjson = require("cjson")
    for key, var in pairs(awardsInfo) do
        if type(var)=="string" then
            print("awards str:", var)
            local j = cjson.decode(var)
            if j.elementType=="item" then
                addTmpAward(j.elementID, j.num)
            else
                addTmpAward(j.elementType, j.num)
            end
        elseif type(var)=="table" then
            if var[1] and var[2] then
                addTmpAward(var[1], var[2])
            end
        end
    end
    
    local function action1(id)
        local time = 0
        local offsetX = 0
        local timeStep = 0.3
        
        local sp = display.newSprite(ItemInfo.getItemInfoById(id).icon)
        local _pos = SearchingUIMgr.getBlockNode(block):convertToWorldSpace(cc.p(52,52))
        SceneMgr.getRunningScene:addChild(sp)
        sp:setPosition(_pos.x, _pos.y + 50)
        sp:setGlobalZOrder(CocosModuleMgr.ZORDER_GUIDE)

        local move = cc.MoveBy:create(timeStep,cc.p(0, 150))
        local fade = cc.FadeTo:create(timeStep, 80)  -- cc.FadeIn:create(0.5)

        sp:runAction(fade)
        sp:runAction(move)
        SceneMgr.getRunningScene:performWithDelay(function()
            sp:removeFromParent()
        end,timeStep)
    end
    
    local function action2(id, keyIndex)
        keyIndex = keyIndex or 2
        local timeStep = 0.8
        local keyNode = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_r,{"key_db", "key"..keyIndex})
        print(keyIndex)
    
        local sp = display.newSprite(ItemInfo.getItemInfoById(id).icon)
        local _pos = SearchingUIMgr.getBlockNode(block):convertToWorldSpace(cc.p(52,52))

        SceneMgr.getRunningScene:addChild(sp)
        sp:setPosition(_pos.x, _pos.y)
        sp:setGlobalZOrder(CocosModuleMgr.ZORDER_GUIDE)
        
        local beginP = _pos
        local endP = keyNode:convertToWorldSpace(cc.p(20,20))
        local _points = {
            cc.p(beginP.x - 50, beginP.y + 50 ),  -- control point
            cc.p(endP.x - 50, endP.y + 50),        -- control point
            cc.p(endP.x, endP.y),
        }
        
        local bezier = cc.BezierTo:create(timeStep, _points)
        local scale  = cc.ScaleTo:create(timeStep, 0.5)
        local fade   = cc.FadeIn:create(timeStep)
        
        sp:runAction(fade)
        sp:runAction(scale)
        sp:runAction(bezier)
        
        SceneMgr.getRunningScene:performWithDelay(function()
            LostTowerUIMgr.setKeys(0)
            sp:removeFromParent()
        end, timeStep) 
    end
    
    for id, number in pairs(tmpAwardsVec) do
        local keyID = isKey(id)
        if keyID == 0 then
            action1(id)
        else
            action2(id, keyID)
        end
    end
end

function LtFuncMgr.flipCard(node, nodebg, param)
    local _scale1 = node:getScaleY()
    local _scale2 = nodebg:getScaleY()
    
    local func1 = function()
        if param.func1 then param.func1() end
        node:setScaleX(1.0*_scale1)
        nodebg:setScaleX(0)
    end
    local Scale1 = cc.ScaleTo:create(0.1, 0, 1*_scale1, 0) 
    local func2 = function()
        if param.func2 then param.func2() end
        node:setScaleX(0)
        transition.scaleTo(nodebg,{time=0.1,scaleX=1.0*_scale2})
        nodebg:performWithDelay(function()
            if param.endFunc then param.endFunc() end
        end,0.1)
    end
    
    node:runAction(transition.sequence({
        cc.CallFunc:create(func1),
        Scale1,
        cc.CallFunc:create(func2),
    }))
end

function LtFuncMgr.transferEffect(id, callback)
    id = id or SearchingMgr.playerCurrPosition
    local eff = AnimationMgr.createAni(SearchingMgr.player, "Spine/effects/Ui_huicheng.png", 52, 52-12, "portalAt"..id)
    AnimationMgr.playAni(eff.res,"animation",false,eff.tag)
    AnimationMgr.setSpeedRate(eff.res,2.0,eff.tag)
    
    SceneMgr.getRunningScene:performWithDelay(function()
        AnimationMgr.removeGafObjectByTag(eff.res, eff.tag)
        if callback then callback() end
    end,1.0)
    
    SearchingMgr.canMove = false
    SearchingMgr.player:performWithDelay(function()
        SearchingMgr.canMove = true
    end,1.0 + 0.5)
end

function LtFuncMgr.resetEffect(callback)
    LostTowerMgr.closeLostTower()
--    transition.fadeOut(SearchingUIMgr.getBlockContainer(), {time = 0.5})
--    SearchingUIMgr.getBlockContainer():performWithDelay(function()
--        LostTowerUIMgr.removeAllAnimation()
--        for i=1, LtMapOption.getMapSize() do
--            SearchingUIMgr.clearBlock(i)
--        end
--
--        LostTowerMgr.sendCreateReq(function()
--            SearchingUIMgr.getBlockContainer():setOpacity(255)
--            LostTowerUIMgr.resetMap()
--        end)
--    end,0.5)
--    SceneMgr.getRunningScene:performWithDelay(function()
        LostTowerUIMgr.removeAllAnimation()
        LostTowerMgr.sendCreateReq(function()
            LostTowerUIMgr.resetMap()
        end)
--    end,0.5)
    SceneMgr.getRunningScene:performWithDelay(function()
        if callback then callback() end
    end,1.0)
end

function LtFuncMgr.defaultFunc()
end

local function canPickAt(i)
    local condition = SearchingMgr.itemTypeTable[i].condition
    if condition then
        if ItemInfo.getCharItemNum(condition) < 1 then
            return false
        end
    end
    return true
end

function LtFuncMgr.pickingFunc(i)
    SearchingUIMgr.TurnToBlock(i)

    if SearchingMgr.eventStateInfoTable[i] ~= 1 then
        if SearchingMgr.eventInfoTable[i] == LtEventOption.EVENT_RANDOMBOX then
            StandardTipsMgr.show(1,"LtTips15")   -- "宝箱已经开启"
        end
        return
    end
    
    local function fire(callback)
        LtFuncMgr.FireBlock = i

        if not NetInterface.isConnect then return end
        LtFuncMgr.sendFireReq({
            fireCell = i,
            successCallback = function()
                if callback then callback() end

                if tonumber(SearchingMgr.itemTypeTable[i].type) == 1 then
                    local propID = SearchingMgr.itemTypeTable[i].id
                    LtPropMgr.pickProp(propID)
                    GameAudio.playUISound("itemCollect")
                end

                SearchingUIMgr.stopAction(i)

                SearchingMgr.eventStateInfoTable[i] = 3
                if SearchingMgr.eventInfoTable[i] == LtEventOption.EVENT_RANDOMBOX then  -- 随机宝箱不消失[有第三态]
                    SearchingUIMgr.initItemUI(i)
                else
                    SearchingUIMgr.clearBlock(i)
                end
            end,
            errorCallback   = function(code)
                LtFuncMgr.FireBlock = 0
            end,
        })
    end
    
--    if not canPickAt(i) then
--        StandardTipsMgr.show(1,"没有对应道具~")
--        return
--    end

--    LtPropMgr.pickProp(1)
    
    if SearchingMgr.eventInfoTable[i] == LtEventOption.EVENT_RANDOMBOX then
        local condition =SearchingMgr.itemTypeTable[i].condition
        local useKey = false
        for id=1, #LostTowerUIMgr.keys do
            if LostTowerUIMgr.keys[id].ID == condition then
                if ItemInfo.getCharItemNum(condition) > 0 then
                    useKey = true
                    local scene = SceneMgr.getRunningScene
                    local keyID = condition
                    local boxID = SearchingMgr.itemTypeTable[i].id
                    local callback = function()
                        fire(function()
                            LostTowerUIMgr.useKey(id)
                            GameAudio.playUISound("boxOpen")
                        end)
                    end
                    LtOpenBoxView.show(scene, keyID, boxID, callback)
                end
            end
        end
        
        if not useKey then
            local scene = SceneMgr.getRunningScene
            local keyID = condition
            local boxID = SearchingMgr.itemTypeTable[i].id
            local callback = function()
                GameAudio.playUISound("boxOpen")
                
                LtFuncMgr.FireBlock = i
                LtFuncMgr.sendMoneyOpenChest({
                    fireCell = i,
                    successCallback = function()
                        SearchingMgr.eventStateInfoTable[i] = 3
                        SearchingUIMgr.initItemUI(i)
                        SearchingUIMgr.playAction(i, 1)
                    end,
                    errorCallback = function(code)
                        if code == Proto.Error.ERROR_NOTENOUGH_RMB then
                            StandardTipsMgr.show(1,"tips14")
                        end
                    end,
                })
            end
            LtOpenBoxView.show(scene, keyID, boxID, callback, true)
        end
    else
        fire()
    end
end

function LtFuncMgr.random_func(i)
    print("random_func",i)
    if not NetInterface.isConnect then return end
    
    LtFuncMgr.FireBlock = i
    
    LtFuncMgr.sendFireReq({
        fireCell = i,
        successCallback = function()
            SearchingUIMgr.clearBlock(i)
        end,
        errorCallback   = function(code)
            LtFuncMgr.FireBlock = 0
        end,
    })
end

function LtFuncMgr.ob_cuttree_func(i)
    SearchingMgr.canMove = false
    local node = SearchingUIMgr.getBlockNode(i)
    local resName = "Gaf/Searching/cuttree.gaf"
    node:performWithDelay(function()
        SearchingUIMgr.clearBlock(i)
        AnimationMgr.createAni(node, resName, 48, 920, i)
        AnimationMgr.playAniWithCallback(resName,"do",nil,i,true)
        GameAudio.playUISound("actlogging")
    end,0.2)
    node:performWithDelay(function()
        SearchingMgr.canMove = true
        SearchingMgr.eventStateInfoTable[i] = 3
        AnimationMgr.removeGafObjectByTag(resName, i)
        SearchingMgr.eventInfoTable[i] = SearchingMapMgr.EVENT_VOID
        SearchingMgr.itemTypeTable[i]  = {}
        SearchingMgr.unlockTonari(i)
        
        if not NetInterface.isConnect then return end
        LtFuncMgr.sendFireReq({
            fireCell = i,
            successCallback = function() end,
            errorCallback   = function(code) end,
        })
    end, 0.9)
end

function LtFuncMgr.exitFunc(i)
    NetInterface.sendWithBlock("GC_CHANGEFLOOR_ACK", function()
        local LostTowerSend = require("src/Net/Send/LostTowerSend.lua")
        LostTowerSend.sendCG_ChangeFloor_Req({ floor=1, })
    end, function()
        LtFuncMgr.resetEffect(function()
            require("src.GameMgr.LostTower.LTGuideMgr").SecondGuide(function()
            end)
        end)
        
        TaskWatcherManager.lostTowerGoToNextFloor({nextFloor = LostTowerMgr.currentFloor + 1})
    end)
end

function LtFuncMgr.trap_default(i)
    local _col, _row = LtMapOption.convertToCoord(i)
    NetInterface.sendWithBlock("GC_ONTRAP_ACK", function()
        local LostTowerSend = require("src.Net.Send.LostTowerSend")
        LostTowerSend.sendCG_onTrap_Req({
            position = {x = _row, y = _col,},
        })
    end, function()
        GameAudio.playUISound("trap")
        print("SSSSSSSSSSSSSSSSSSSS")
    end,function(code)
    end)
end

function LtFuncMgr.sendTransferReq(i, callback)
    if LtMapOption.getMapType() ~= "LOSTTOWER" then return end
    if SearchingMgr.eventInfoTable[i] ~= LtEventOption.EVENT_PORTAL then return end

    local _col,_row = LtMapOption.convertToCoord(i)
    NetInterface.sendWithBlock("GC_ENTERTRANSFERDOOR_ACK", function()
        local LostTowerSend = require("src/Net/Send/LostTowerSend.lua")
        LostTowerSend.sendCG_EnterTransferDoor_Req({ x=_row, y=_col, })
    end,function()
        if callback then callback() end
    end)
end

function LtFuncMgr.portalFunc(i)
    LtFuncMgr.transferEffect(i)
    SearchingMgr.canMove = false
    SceneMgr.getRunningScene:performWithDelay(function()
        local _col,_row = LtMapOption.convertToCoord(i)
        NetInterface.sendWithBlock("GC_ENTERTRANSFERDOOR_ACK", function()
            local LostTowerSend = require("src/Net/Send/LostTowerSend.lua")
            LostTowerSend.sendCG_EnterTransferDoor_Req({ x=_row, y=_col, })
        end,function()
            SearchingMgr.canMove = true
        end)
    end,0.5)
end

function LtFuncMgr.buffCommonFunc(i)
    if SearchingMgr.eventStateInfoTable[i] == 3 then
        return
    end

    if not NetInterface.isConnect then return end
    LtFuncMgr.sendFireReq({
        fireCell = i,
        successCallback = function()
            SearchingMgr.eventStateInfoTable[i] = 3
            
            local buffid = SearchingMgr.itemTypeTable[i].id
            LtExBufferMgr.addNewBuff(buffid)
            GameAudio.playUISound("starCollect")
            
            SearchingUIMgr.clearBlock(i)
        end,
        errorCallback   = function(code)
        end,
    })
end

function LtFuncMgr.collectionFunc(i)
    SearchingUIMgr.TurnToBlock(i)

    if SearchingMgr.eventStateInfoTable[i] == 3 then
        StandardTipsMgr.show(1,"LtTips14")   -- "该矿点已采集"
        return
    end

    if not NetInterface.isConnect then return end
    
    local function __canCollection(_callback)
        local needLevel = SearchingMgr.itemTypeTable[i].needLevel
        
        local careerLevel = CharInfo.get().lifeskilllevel
        
        if not careerLevel then return false end
        
        if careerLevel < needLevel then
            StandardTipsMgr.show(1, CocosModuleMgr.createStringWithFormat({"LtTips13", needLevel}))  -- 生活技能未达<1>级
            return false
        end
        
        return true
    end
    
    local function __effect(_callback)
        local parent = SearchingUIMgr.getBlockNode(i)

        local eff = AnimationMgr.createAni(parent,"Gaf/effect/collectionEffect.gaf",540,500)
        AnimationMgr.playAni("Gaf/effect/collectionEffect.gaf","do",true)
        GameAudio.playUISound("actmining")
        
        SearchingMgr.canMove = false
        SceneMgr.getRunningScene:performWithDelay(function()
            SearchingMgr.canMove = true
            AnimationMgr.removeGafObjectByTag(eff.res,eff.tag)
            if _callback then _callback() end
        end,2.0)
        
--        local hoe = display.newSprite("UI/CommonFiles/icon_caiji.png")
--
--        local timep = 0.3
--        
--        parent:addChild(hoe)
--        hoe:setScale(0.6)
--        hoe:setAnchorPoint(1.0,0.0)
--        hoe:setRotation(10)
--        hoe:setPosition(80, 62)
--        hoe:setLocalZOrder(100)
--
--        local R1 = cc.RotateTo:create(0.01, -20)
--        local R2 = cc.RotateTo:create(0.09, -20)
--        local R3 = cc.RotateTo:create(0.6, 30)
--
--        hoe:runAction(cc.RepeatForever:create(cc.Sequence:create(R1,R2,R3)))
--        
--        SearchingMgr.canMove = false
--        hoe:performWithDelay(function()
--            parent:removeChild(hoe)
--            SearchingMgr.canMove = true
--            if _callback then _callback() end
--        end,1.6)
    end
    
    local function __fireBlock()
        LtFuncMgr.FireBlock = i
        
        LtFuncMgr.sendFireReq({
            fireCell = i,
            successCallback = function()
                SceneMgr.getRunningScene:performWithDelay(function()
                    --SearchingUIMgr.clearBlock(i)
                    
                    SearchingMgr.eventStateInfoTable[i] = 3
                    SearchingUIMgr.initItemUI(i)
                end, 0.5)
            end,
            errorCallback   = function(code)
                LtFuncMgr.FireBlock = 0
            end,
        })
    end
    
    if __canCollection() then
        __effect(function()
            __fireBlock()
        end)
    end
    
end

function LtFuncMgr.healPointFuncAt(i)
    if SearchingMgr.eventStateInfoTable[i] == 3 then
        return
    end

    if not NetInterface.isConnect then return end

    LtFuncMgr.FireBlock = i
    
    local recoverEffectInfo = SearchingMgr.itemTypeTable[i]
        
    local pets = {}
    for i = 1, #LtPetsMgr.LtArmy do
        local objID = LtPetsMgr.LtArmy[i]
        
        local petInfo = PokemonInfo.getPetInfoByObjID(objID)
        local hpmax = petInfo.hpmax
        
        if LtPetsMgr.getHpByObjID(objID) > 0 then
            local hp = LtPetsMgr.getHpByObjID(objID)
            if recoverEffectInfo.type == 1 then  -- 百分比
                hp = math.floor(hpmax * recoverEffectInfo.value / 100) + hp
            end
            if recoverEffectInfo.type == 2 then  -- 数值
                hp = hp + recoverEffectInfo.value
            end
            if hp > hpmax then hp = hpmax end
            
            table.insert(pets,{objID = objID, hp = hp})
        end
    end
    
    SearchingMgr.canMove = false
    
    LtFuncMgr.sendFireReq({
        fireCell = i,
        successCallback = function()
            SearchingMgr.canMove = true

            LtPetsMgr.reocverArmyPets(3, pets)
            SceneMgr.getRunningScene:performWithDelay(function()
                SearchingUIMgr.clearBlock(i)
            end, 0.5)
        end,
        errorCallback   = function(code)
            LtFuncMgr.FireBlock = 0
        end,
    })
end

---函数配置，在函数定义之后，绑定函数时用
-- {name = ... ,}     name爲配置表中物品名稱
LtFuncMgr.eventFuncDef = {
    void        = {},
    picking     = LtFuncMgr.pickingFunc,
    monster     = {},
    obstruction = {},
    exit        = LtFuncMgr.defaultFunc,
    enterance   = LtFuncMgr.defaultFunc,
    switch      = {},
    csm         = {},
    trainer     = {},
}

--- getEventFunc
-- @param block num block-id
function LtFuncMgr.getEventFunc(block)
    local eType = SearchingMgr.eventInfoTable[block]
    local func = LtFuncMgr.eventFuncDef[LtFuncMgr.EVENT_TYPE_STRING[eType]]
    local callback = nil

    if type(func) == "function" then
        callback = func
    elseif type(func) == "table" then
        callback = func[SearchingMgr.itemTypeTable[block].name]
    end

    --解迷雾callback
    if SearchingMgr.mapInfoTable[block] == 1 then
        callback = SearchingMgr.mistHidAt 
    end

    return callback
end

return LtFuncMgr