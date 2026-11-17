---战斗功能
require("src.GameMgr.Battle.type_damage")
local BattleFuncMgr = {}
BattleFuncMgr.gafSkillEventTbl = {}
BattleFuncMgr.CCSUILoader   = require("src.framework.cc.uiloader.CCSUILoader") 
local sounds            = {}
local scheduler         = require(cc.PACKAGE_NAME..".scheduler")
local handlerTbl        = {}
local varyColorAction   = {}

function BattleFuncMgr.init() 
    --scheduler = require(cc.PACKAGE_NAME..".scheduler") 
    BattleFuncMgr.gafSkillEventTbl = {}
    sounds = {
        beat = "Music/sound/basicAckSound.m4a",
        skill4Btn = "Music/sound/coreSkill.m4a",
        win = "Music/sound/victory.m4a",
        lose = "Music/sound/lose.m4a",
        "Music/sound/bladeSound.m4a",
        "Music/sound/diceSound.m4a",
        "Music/sound/label_update.m4a",
        "Music/sound/doubleClawSkill.m4a",
        "Music/sound/fireSound.m4a",
        "Music/sound/greenlight.m4a",
        "Music/sound/thunderSound.m4a",
        "Music/sound/waterSound.m4a",
        "Music/sound/windSkill.m4a",
    }

    GameAudio.preLoadBattleSound()
 
end

function BattleFuncMgr.getBattleSounds()
    return sounds
end

function BattleFuncMgr.isFileExist(filePath)
    local isExist = cc.FileUtils:getInstance():isFileExist(filePath)
    return isExist
end

function BattleFuncMgr.preLoadSound()
    for key,var in pairs(sounds) do
        local fileExist = cc.FileUtils:getInstance():isFileExist(var)
        if fileExist then
            audio.preloadSound(var)
        else
            printFileLog(var.."声音文件不存在")
            sounds[key] = nil
        end
    end
end
function BattleFuncMgr.unloadSound()
    for key,var in pairs(sounds) do
        audio.unloadSound(var)
    end
end
---gaf回调事件
--@param string resName
--@param gaf gafObj gafObjctor
--@param function callback 回调函数参数（infomation可以取事件和关键帧,具体事件字段可以打开txt看）
--@param function endCallback 结束回调
--@param bool defaultEvent true为执行默认的回调（全屏震动，宠物受击） false 为不执行默认回调
--@param node nodeObj (如果参数 defaultEvent为false ,请设为nil)默认事件对象表,为true,刚设{Beaten = ,vibration = }
function BattleFuncMgr.skillTriggerEventHandler(resName,gafObj,callback,endCallback,defaultEvent,nodeObjTbl)
    if not gafObj then
        printFileLog("gafObj of skillTriggerEventHandler == nil")
        return nil
    end
    --print("skillTriggerEventHandler ~~~~~~~~~~~~~~~~"..resName.."/n"..debug.traceback())
    local fps = gafObj:getFps()
    if gafObj:getIsAnimationRunning() then
        gafObj:stop()
    end
    gafObj:gotoAndPlay(0)
    gafObj:start()
    if BattleFuncMgr.gafSkillEventTbl[resName] == nil then
        printFileLog("BattleFuncMgr.gafSkillEventTbl["..resName.."]没有存过事件")
        return
    end
    local fps = gafObj:getFps()
    for key,var in pairs(BattleFuncMgr.gafSkillEventTbl[resName]) do
        local delayTime = 0
        if var["gapFrm"] ~= nil then
            delayTime = (1.00/fps)* (var["gapFrm"]+2)
        else
            delayTime = 0
        end
        local keyF = (1.00/fps)*(var["frame"]+2)

        local handlerS = scheduler.performWithDelayGlobal(function()
            if callback ~= nil then
                callback(var)
            end
            if defaultEvent then
                for event,objc in pairs(nodeObjTbl) do
                    if string.find(var["event"],event) ~= nil then
                        -- local isTriggerEv = false
                        if BattleFuncMgr.skillEventFuncTbl()[event] ~= nil then
                            BattleFuncMgr.skillEventFuncTbl()[event](objc,nil,delayTime) 
                            break
                        else
                            printFileLog("BattleFuncMgr.skillEventFuncTbl()没有"..event.."()接口")
                        end

                    end
                end
            end
        end, keyF)
        table.insert(handlerTbl,handlerS)
    end
    local endF = (1.00/fps)*(gafObj:getTotalFrameCount()+2)
    local handlerE = scheduler.performWithDelayGlobal(function()
        if endCallback ~= nil then
            endCallback()
        end
    end,endF)
    table.insert(handlerTbl,handlerE)
end

function BattleFuncMgr.createGafAni(res,parent,anchorX,anchorY,posX,posY)
    local  gafres   = gaf.GAFAsset:create(res)
    local aniWidth = gafres:getSceneWidth()
    local aniheight = gafres:getSceneHeight()
    local   ani    =  gafres:createObject()
    if ani == nil then
        printFileLog(res.."创建GAF  失败")
        return
    end
    ani:addTo(parent)
    ani:setPosition(posX,posY)
    ani:setAnchorPoint(anchorX,anchorY)
    return ani,aniWidth,aniheight
end

function BattleFuncMgr.petBeaten(node)
    transition.moveBy(node,{y = -40,time = 0.05})
    node:performWithDelay(function()
        transition.moveBy(node,{y = 80,time = 0.1})
        node:performWithDelay(function()
            transition.moveBy(node,{y = -80,time = 0.1})
            node:performWithDelay(function()
                transition.moveBy(node,{y = 40,time = 0.05})
            end,0.05)
        end,0.05)
    end,0.05)
end


function BattleFuncMgr.screenVib(node,time)
    local t = 0
    local function keepTime()
        transition.moveBy(node,{y = -5,time = time/3})
        node:performWithDelay(function()
            transition.moveBy(node,{y = 10,time = time/3})
            node:performWithDelay(function()
                transition.moveBy(node,{y = -5,time = time/3})
                -- t = t + 0.15
                -- if t < time then 
                --     keepTime()
                -- end 
            end,time/3)
        end,time/3)
    end
    keepTime()
end

function BattleFuncMgr.skillEventFuncTbl()
    local eventFuncTbl = {}
    eventFuncTbl.EVENT_WOUNDED = BattleFuncMgr.petBeaten
    eventFuncTbl.EVENT_BEATEN  = BattleFuncMgr.petBeaten
    eventFuncTbl.EVENT_SHAKE = BattleFuncMgr.vibrationScene
    return eventFuncTbl
end


---读取gaf动画配置
--@param gafObj gaf对象
--@param name string
--@param isDelete 播完是否删除掉
function BattleFuncMgr.playGafAniWithSequenceAndCallBack(gafObj,motionName,isbool,callback,isDelete)
    local isExist = nil
    if not gafObj then
        printFileLog("gafObj =========== nil")
        return nil
    end
    --print("motionName playGafAniWithSequenceAndCallBack~~~~"..motionName.."/n"..debug.traceback()) 
--    printFileLog("motionName......."..motionName)
    if gafObj:getIsAnimationRunning() then
        gafObj:stop()
    end

    local FrameEnd          = gafObj:getEndFrame(motionName)
    local FrameStart        = gafObj:getStartFrame(motionName)
    local during            = FrameEnd - FrameStart

    local fps               = gafObj:getFps()

    local endF = (1.00/fps)*(during+1)
    local motionIs = gafObj:playSequence(motionName,isbool,true)

    if motionIs then
        gafObj:start()
    else
        return false
    end

    if callback ~= nil then
        local handlerE = scheduler.performWithDelayGlobal(function()
            if callback ~= nil then
                callback()
            end
            if isDelete then
                gafObj:removeFromParent()
            end
        end,endF)
        table.insert(handlerTbl,handlerE)
    end
    return true
end

---伤害数字路线
function BattleFuncMgr.BloodParabola(node,iscritical,speed,delback)
    local time = speed
    local nodePrePosX = node:getPositionX()
    local nodePrePosY = node:getPositionY()
    local nodeCotrPosX = nodePrePosX - 80
    local nodeCotrPosY = nodePrePosY + 160
    local nodeEndPosX = nodePrePosX - 150
    local nodeEndPosY = nodePrePosY-40
    local waitOne = speed - 0.2
    local waitTwo = 0.1
    local orgScale = node:getScaleX()
    if iscritical  then
        time = 0.8
        waitOne = time - 0.4
        node:scaleTo(0.1,orgScale+0.5)
        node:performWithDelay(function()
            node:scaleTo(0.05,orgScale+0.2)
        end, 0.1)
    end
    node:performWithDelay(function()
        if not iscritical then
            node:scaleTo(waitTwo, orgScale-0.3)
        end
        node:performWithDelay(function()
            node:fadeOut(0.1)
        end,waitTwo)
    end, waitOne)
    local ParabolaAct = cc.BezierTo:create(time,{cc.p(nodePrePosX,nodePrePosY),
        cc.p(nodeCotrPosX,nodeCotrPosY),cc.p(nodeEndPosX,nodeEndPosY)})
    -- node:runAction(ParabolaAct)

    local endFun  = nil

    if delback then
        endFun = cc.CallFunc:create(delback)
    end

    node:runAction(transition.sequence({
        ParabolaAct,
        endFun
    }))
    -- node:performWithDelay(function()
    --     local jump = cc.JumpBy:create(0.2, cc.p(-20,0),10, 1)
    --     transition.stopTarget(node)
    --     node:runAction(jump)
    --     node:performWithDelay(function()
    --         node:fadeOut(0.4)
    --     end,0.2)
    -- end,time)
end

-------------------------node缩放--------------------
function BattleFuncMgr.bubbleAction(node,nodeScale,time,orgScale,callBack)
    -- local nodeScaleX = node:getScaleX()
    -- local nodeScaleY = node:getScaleY()
    transition.stopTarget(node)
    local x1 = (orgScale+nodeScale) 
    local y1 = (orgScale+nodeScale)
    local x2 = orgScale 
    local y2 = orgScale
    local callFun = nil
    if callBack then
        callFun = cc.CallFunc:create(callBack)
    end 

    node:runAction(transition.sequence({
        cc.ScaleTo:create(time/2, x1,y1),
        -- cc.ScaleTo:create(time*2/4, x2,y2), 
        cc.ScaleTo:create(time/2, x2,y2),
        callFun
    }))

end

-------------------------node  延迟 fade in--------------------
function BattleFuncMgr.fadeInWithDelay(node,time,callBack)
    node:opacity(0)
    local callFun = nil
    if callBack then
        callFun = cc.CallFunc:create(callBack)
    end 

    node:runAction(transition.sequence({
        cc.FadeIn:create(time),
        callFun
    }))

end

function BattleFuncMgr.sceneBubble(node,petSize,direction,callBack)
    local x1 = direction*(petSize+0.05)
    local y1 = (petSize+0.05)
    local x2 = direction*(petSize-0.05)
    local y2 = (petSize-0.05)
    local x3 = direction*petSize
    local y3 = petSize
    local callFun = cc.CallFunc:create(callBack)
    node:runAction(transition.sequence({
        cc.ScaleTo:create(0.2, x1,y1),
        cc.ScaleTo:create(0.05, x2,y2),
        cc.ScaleTo:create(0.05, x3,y3),
        callFun
    }))
end

function BattleFuncMgr.petAppearAction(node,time,petSize,direction,callBack)
    local x1 = direction*(petSize+0.2) 
    local y1 = (petSize+0.2)
    local x2 = direction*(petSize-0.2)
    local y2 = (petSize-0.2)
    local x3 = direction*petSize
    local y3 = petSize
    local callFun = cc.CallFunc:create(callBack)
    node:runAction(transition.sequence({
        cc.ScaleTo:create(time/4, x1,y1),
        cc.ScaleTo:create(time*2/4, x2,y2),
        cc.ScaleTo:create(time/4, x3,y3),
        callFun
    }))
end

---持续闪烁 + 回调
function BattleFuncMgr.keepTwinkle(node,time,callBack)
    if time == 0 then
        return
    end
    local callFun = nil
    local blindAct = cc.Blink:create(time,4)

    if callBack ~= nil then
        callFun = cc.CallFunc:create(callBack)
    end
    node:runAction(transition.sequence({
        blindAct,
        callFun
    }))
end
--创建遮罩亮光精灵 带收缩
function BattleFuncMgr.createMaskSprite(parent,maskedRes,maskRes,callback)
    local newSprite     = display.newSprite(maskedRes)
    local newSpriteSize = newSprite:getContentSize()
    local parentSize    = parent:getContentSize()
    local maskSprite    = display.newSprite(maskRes)

    maskSprite:opacity(0)
    newSprite:addTo(parent)
    maskSprite:addTo(newSprite) 
    maskSprite:setPosition(newSpriteSize.width/2,newSpriteSize.height/2)
    newSprite:setPosition(parentSize.width/2,parentSize.height/2)

    local callFun   = nil

    if callback ~= nil then
        callFun = cc.CallFunc:create(callback)
    end

    local scaleExTend     = cc.ScaleTo:create(0.2,1.2, 1.2, 0)
    local spFadeIn        = cc.FadeIn:create(0.1)
    local spFadeOut       = cc.FadeOut:create(0.05)
    -- local firstStep         = cc.Spawn:create(scaleExTend,spFadeIn)
    local scaleRecover    = cc.ScaleTo:create(0.05,1.0, 1.0, 0)

    newSprite:runAction(transition.sequence({
        scaleExTend,
        scaleRecover,
        callFun
    }))

    maskSprite:runAction(transition.sequence({
        spFadeIn,
        cc.DelayTime:create(0.1),
        spFadeOut
    }))

    return newSprite,maskSprite 
end
--node创建遮罩亮光精灵 带收缩
function BattleFuncMgr.createMaskSpriteDetailByNode(node,maskRes,time,gapScale,oraginScale,callback)
    -- local node     = display.newSprite(maskedRes) 
    -- local parentSize    = parent:getContentSize()
    local nodeSize     = node:getContentSize()
    local maskSprite   = display.newSprite(maskRes)
    -- local oraginScale  = node:getScale()
    local finalScale   = oraginScale + gapScale

    maskSprite:opacity(0)
    maskSprite:addTo(node) 
    maskSprite:setPosition(nodeSize.width/2,nodeSize.height/2)
 
    local callFun   = nil
    local function getNode()
        callback(maskSprite) 
    end
    if callback ~= nil then
        callFun = cc.CallFunc:create(getNode)
    end

    local scaleExTend     = cc.ScaleTo:create(time,finalScale, finalScale, 0)
    local spFadeIn        = cc.FadeIn:create(0.1)
    local spFadeOut       = cc.FadeOut:create(0.05)
    -- local firstStep         = cc.Spawn:create(scaleExTend,spFadeIn)
    local scaleRecover    = cc.ScaleTo:create(time,oraginScale, oraginScale, 0)

    node:runAction(transition.sequence({
        scaleExTend,
        scaleRecover,
        callFun
    }))

    maskSprite:runAction(transition.sequence({
        spFadeIn,
        cc.DelayTime:create(0.1),
        spFadeOut
    }))

    return newSprite
end

function BattleFuncMgr.flipNode(node,startFuc,endFuc)
    local scale     =  node:getScale()
    local scaleDown = cc.ScaleTo:create(0.1, 0, 1*scale, 0) 
    local downFuc   = cc.CallFunc:create(startFuc)
    local scaleUp   = cc.ScaleTo:create(0.3, 1*scale, 1*scale, 0)
    local upFuc     = cc.CallFunc:create(endFuc)
    node:runAction(transition.sequence({
        scaleDown,
        downFuc,
        scaleUp,
        upFuc
    })) 
     
end 

function BattleFuncMgr.bubbleRespon(node,time)
    local scaleExTend     = cc.ScaleTo:create(0.1,1.3, 1.1, 0)
    local rotateLeft      = cc.RotateTo:create(0.1,-20)
    local step1           = cc.Spawn:create(scaleExTend,rotateLeft)

    local scaleReduce     = cc.ScaleTo:create(0.08,1.0, 1.0, 0)
    local rotateRight     = cc.RotateTo:create(0.08,0) 
    local step2           = cc.Spawn:create(scaleReduce,rotateRight)

    node:runAction(transition.sequence({
        step1,
        step2
    }))
end
 
function BattleFuncMgr.braveRespon(node,orgX,orgY) 
    transition.stopTarget(node)
    local moveLeft1       = cc.MoveTo:create(0.05,cc.p(orgX-2,orgY+2))
    local recoverLeft1    = cc.MoveTo:create(0.05,cc.p(orgX,orgY))
    local moveRight1      = cc.MoveTo:create(0.05,cc.p(orgX+2,orgY+2))
    local recoverRight1   = cc.MoveTo:create(0.05,cc.p(orgX,orgY))
    local moveLeft2       = cc.MoveTo:create(0.05,cc.p(orgX-2,orgY+2))
    local recoverLeft2    = cc.MoveTo:create(0.05,cc.p(orgX,orgY))
    local moveRight2      = cc.MoveTo:create(0.05,cc.p(orgX+2,orgY+2))
    local recoverRight2   = cc.MoveTo:create(0.05,cc.p(orgX,orgY))

    node:runAction(transition.sequence({
        moveLeft1,
        recoverLeft1,
        moveRight1,
        recoverRight1,
        moveLeft2,
        recoverLeft2,
        moveRight2,
        recoverRight2
    }))
end

function BattleFuncMgr.bubbleButtonTest(node)
   
    local originScaleX = node:getScaleX()
    local originScaleY = node:getScaleY()
    local size = node:getContentSize()
    
    local function zoom1(offset, time, onComplete)
        local x, y = node:getPosition()
        --local size = node:getContentSize()
        -- size.width = 140
        -- size.height = 130

        local scaleX = originScaleX * (size.width + offset) / size.width
        local scaleY = originScaleY * (size.height - offset) / size.height

        transition.moveTo(node, {y = y - offset/2, time = time})
        transition.scaleTo(node, {
            scaleX     = scaleX,
            scaleY     = scaleY,
            time       = time,
            onComplete = onComplete,
        })
    end
    
    local function zoom2(offset,time,onComplete)
        local scaleX = originScaleX * (size.width - offset) / size.width
        local scaleY = originScaleY * (size.height + offset) / size.height
        local x, y = node:getPosition()
        transition.moveTo(node, {y = y + offset/2, time = time})    
        transition.scaleTo(node, {
            scaleX     = scaleX,
            scaleY     = scaleY,
            time       = time,
            onComplete = onComplete,
        })
    end

    local function zoom3(offset, time, onComplete)
        local x, y = node:getPosition()
        -- size.width = 140
        -- size.height = 130

        --transition.moveTo(node, {y = y + offset/2, time = time })
        transition.scaleTo(node, {
            scaleX     = originScaleX,
            scaleY     = originScaleY,
            time       = time,
            onComplete = onComplete,
        })
    end

    zoom1(20, 0.06, function()
        zoom2(20, 0.08, function()
            zoom3(20, 0.1, function()
                --zoom2(20, 0.11, function()
                    --end)
            end)
        end)
    end)
end


function BattleFuncMgr.bubbleButton(node)
    local function zoom1(offset, time, onComplete)
        local x, y = node:getPosition()
        local size = node:getContentSize()
        -- size.width = 140
        -- size.height = 130

        local scaleX = node:getScaleX() * (size.width + offset) / size.width
        local scaleY = node:getScaleY() * (size.height - offset) / size.height

        transition.moveTo(node, {y = y - offset, time = time})
        transition.scaleTo(node, {
            scaleX     = scaleX,
            scaleY     = scaleY,
            time       = time,
            onComplete = onComplete, 
        })
    end
    local function zoom2(offset, time, onComplete)
        local x, y = node:getPosition()
        local size = node:getContentSize()
        -- size.width = 140
        -- size.height = 130

        transition.moveTo(node, {y = y + offset, time = time / 2})
        transition.scaleTo(node, {
            scaleX     = 1.0,
            scaleY     = 1.0,
            time       = time,
            onComplete = onComplete,
        })
    end

    zoom1(40, 0.08, function()
        zoom2(40, 0.09, function()
            zoom1(20, 0.10, function()
                zoom2(20, 0.11, function()
                    end)
            end)
        end)
    end)
end


function BattleFuncMgr.fightLabelShow(node,endFuc) 
    
    node:setCascadeOpacityEnabled(true)
    if node.head then
        if LuaSqlite.LANG_TYPE ~= 1 and (node.type == "weak" or node.type == "strong") then
            local scale1 = cc.ScaleTo:create(0.05, 0.86*1.3)
            local scale2 = cc.ScaleTo:create(0.1, 1.18*1.3)
            local scale3 = cc.ScaleTo:create(0.1, 0.89*1.3)
            local scale4 = cc.ScaleTo:create(0.1, 1*1.3)
            local scale5 = cc.ScaleTo:create(0.3, 1*1.3)
            local scale6 = cc.FadeOut:create(0.15)
            local action1 = transition.sequence({
                scale1,scale2,scale3,scale4,scale5,scale6
            })
            local move1 = cc.MoveBy:create(0.05,cc.p(9,49))
            local move2 = cc.MoveBy:create(0.1,cc.p(8,46))
            local move3 = cc.MoveBy:create(0.1,cc.p(23,-11))
            local move4 = cc.MoveBy:create(0.1,cc.p(9,4))
            local move5 = cc.MoveBy:create(0.3,cc.p(0,20))
            local move6 = cc.MoveBy:create(0.15,cc.p(0,13+40))
            local action2 = transition.sequence({
                move1,move2,move3,move4,move5,move6,cc.CallFunc:create(endFuc)
            })
            node.head:runAction(cc.Spawn:create(action1,action2))
        else
            local dis = 1
            if node.type == "weak" then
                dis = -0.4
            end
            node.head:setScale(0.86)
            node.head:setOpacity(0)

            local scale1 = transition.sequence({
                cc.DelayTime:create(0.05),
                cc.CallFunc:create(function()
                    node.head:setOpacity(255)
                end)
            })
            local scale2 = cc.ScaleTo:create(0.1, 1.18)
            local scale3 = cc.ScaleTo:create(0.1, 0.89)
            local scale4 = cc.ScaleTo:create(0.1, 1)
            local scale5 = cc.ScaleTo:create(0.3, 1)
            local scale6 = cc.FadeOut:create(0.15)
            local action1 = transition.sequence({
                scale1,scale2,scale3,scale4,scale5,scale6
            })
            local move1 = cc.MoveBy:create(0,cc.p(50,49))
            local delay1 = cc.DelayTime:create(0.05)
            local move2 = cc.MoveBy:create(0.1,cc.p(0,46))
            local move3 = cc.MoveBy:create(0.1,cc.p(0,-7))
            local move4 = cc.MoveBy:create(0.1,cc.p(0,9*dis))
            local move5 = cc.MoveBy:create(0.3,cc.p(0,16*dis))
            local move6 = cc.MoveBy:create(0.15,cc.p(0,15*dis))
            local action2 = transition.sequence({
                cc.Sequence:create(move1,delay1),move2,move3,move4,move5,move6
            })
            node.head:runAction(cc.Spawn:create(action1,action2))
        end
        
    end
    if node.label then
        node.label:setScale(0.64*1.4)
        local scale1 = cc.ScaleTo:create(0.05, 0.86*1.3)
        local scale2 = cc.ScaleTo:create(0.1, 1.18*1.3)
        local scale3 = cc.ScaleTo:create(0.1, 0.89*1.3)
        local scale4 = cc.ScaleTo:create(0.1, 1*1.3)
        local scale5 = cc.ScaleTo:create(0.3, 1*1.3)
        local scale6 = cc.FadeOut:create(0.15)
        local action1 = transition.sequence({
            scale1,scale2,scale3,scale4,scale5,scale6
        })
        local move1 = cc.MoveBy:create(0.05,cc.p(9,49))
        local move2 = cc.MoveBy:create(0.1,cc.p(8,46))
        local move3 = cc.MoveBy:create(0.1,cc.p(23,-11))
        local move4 = cc.MoveBy:create(0.1,cc.p(9,4))
        local move5 = cc.MoveBy:create(0.3,cc.p(0,20))
        local move6 = cc.MoveBy:create(0.15,cc.p(0,13+40))
        local action2 = transition.sequence({
            move1,move2,move3,move4,move5,move6,cc.CallFunc:create(endFuc)
        })
        node.label:runAction(cc.Spawn:create(action1,action2))
    end

end 




function BattleFuncMgr.findObjc(objcNode,x,y)
    objcNode:setLocalZOrder(100)
    objcNode:moveBy(2.0,2000,0)
    objcNode:performWithDelay(function()
        objcNode:setPosition(x,y)
        objcNode:moveBy(2.0,-2000,0)
    end,2.0)
    objcNode:performWithDelay(function()
        objcNode:setPosition(x,y)
        objcNode:moveBy(2.0,0,2000)
    end,4.0)
    objcNode:performWithDelay(function()
        objcNode:setPosition(x,y)
        objcNode:moveBy(2.0,0,-2000)
    end,6.0)
end

BattleFuncMgr.petcard = nil

---创建对象池的宠物卡片对象
----@param cardType int         1为有血卡  2无血卡 3 有名字卡 ---默认为有名字的卡
function BattleFuncMgr.createCacheObjectForPetCard(cardType)
    local res            =  "Pet/petcards/petcard.csb"
    local csb = CSResourceMgr.createRes(nil,res,nil,true)
    local layerBtn      = csb:getChildByName("btn")
    local isHaveBar     = true
    local isHavePetName = false

    if cardType == 1 then
        CSResourceMgr.setFrame(res, 0)
        layerBtn:setContentSize(92,120)
    elseif cardType == 2 then
        CSResourceMgr.setFrame(res, 1)
        layerBtn:setContentSize(92,108)
        isHaveBar = false
    else
        CSResourceMgr.setFrame(res, 2)
        layerBtn:setContentSize(92,120)
        isHaveBar = false
        isHavePetName = true
    end    
    
    local btn           = layerBtn:clone()
    local petLevel      = btn:getChildByName("level")
    local diban         = btn:getChildByName("diban")
    local icon          = btn:getChildByName("icon")
    local rarei         = btn:getChildByName("rarei")
    local attribution   = btn:getChildByName("attri")
    local petBar        = btn:getChildByName("bar")
    local barBK         = btn:getChildByName("barBK")
    local str           = btn:getChildByName("str")
    local star          = btn:getChildByName("star") 
    local starTable     = {}
    local starPosX,starPosY   = star:getPosition()
    --printFileLog("startPosX,startPosY"..starPosX,starPosY)
    local starSize      = 15

    petLevel:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1) 
    str:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1)

    str:setTextColor({r = 215,g = 216,b = 217, a = 255})

    petLevel:setString("Lv")
    str:setString("")

    rarei:setScale(0.48)
    
    if not isHaveBar then
        barBK:hide()
        petBar:hide()
    end
    
    
    return btn
end

-------创建对象池队形的卡片
--@object layerbtn 对象池卡片按钮对象
--@param petInfo   table        宠信息
--@param cardType  int         1为有血卡  2无血卡 3 有名字卡 ---默认为有名字的卡
--@param isPersonalName bool    是否写个性名字
function BattleFuncMgr.createPetCardWithObjectPool(object,petInfo,cardType,isPersonalName)
    isPersonalName = isPersonalName or true
    local isHaveBar     = true
    local isHavePetName = false

    if cardType == 1 then
    
    elseif cardType == 2 then

        isHaveBar = false
    else
        isHaveBar = false
        isHavePetName = true
    end

    object:removeFromParent(false)
    local btn           = object
    local petLevel      = btn:getChildByName("level")
    local diban         = btn:getChildByName("diban")
    local icon          = btn:getChildByName("icon")
    local rarei         = btn:getChildByName("rarei")
    local attribution   = btn:getChildByName("attri")
    local petBar        = btn:getChildByName("bar")
    local barBK         = btn:getChildByName("barBK")
    local str           = btn:getChildByName("str")
    local star          = btn:getChildByName("star")
    --local starTable     = {}
    local petDatInfo    = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
    local rarePoint     = petDatInfo.rarePoint
    local starPosX,starPosY   = 46,29--star:getPosition()
    --printFileLog("startPosX,startPosY"..starPosX,starPosY)
    local starSize      = 15
    if petInfo.skin then
        if petInfo.skin > 0 then
            petLevel:setColor({r=96,g=255,b=0})
            petLevel:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1)
        else
            petLevel:setColor({r=255,g=255,b=255})
            petLevel:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1) 
        end
    end
    str:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1)

    str:setTextColor({r = 215,g = 216,b = 217, a = 255})

    petLevel:setVisible(true)
    petLevel:setString("Lv"..petInfo.level)
    str:setString("")

    rarei:setScale(0.48)

    if not isHaveBar then
        barBK:hide()
        petBar:hide()
    end

    if petInfo.hp and petInfo.hpmax then
        local cardPer = 100*petInfo.hp/petInfo.hpmax
        petBar:setPercent(cardPer) 
    end
   
    if object.startable == nil then
	
        object.startable = {}
    else
        for i = 2,#object.startable do
            --object.removeChild(object.startable[i])
			printFileLog("removeChild........star "..i)
            object.startable[i]:removeFromParent(true)
        end       
        object.startable = {}
    end  
    
    if petInfo.star == 0 then
        star:hide()
    else
        star:show()
        local x = starPosX - (starSize*petInfo.star - starSize)/2
        star:setPosition(x,starPosY)
        object.startable[1] = star
        local copyStars = petInfo.star-1
        for index = 1,copyStars do
            local copeStar = star:clone()
            object.startable[1+index] = copeStar
            copeStar:addTo(btn)
            copeStar:setPosition(x+index*starSize,starPosY) 
        end
    end
    
    
    --[[
    if petInfo.star > 0 then
        printFileLog("petInfo.star"..petInfo.star)
        local x = starPosX - (starSize*petInfo.star - starSize)/2
        object.startable[1]:setPosition(x,starPosY)
        object.startable[1]:setVisible(true)
        local copyStars = petInfo.star
        for index = 2,copyStars do
            object.startable[index]:setPosition(x+index*starSize,starPosY) 
            object.startable[index]:setVisible(true)
        end  
    
    end      
  ]]
    
    
    --[[
    if petInfo.star == 0 then
        star:hide()
    else
        local x = starPosX - (starSize*3 - starSize)/2
        star:setPosition(x,starPosY)
        starTable[1] = star
        local copyStars = 3-1
        for index = 1,copyStars do
            local copeStar = star:clone()
            starTable[1+index] = copeStar
            copeStar:addTo(btn)
            copeStar:setPosition(x+index*starSize,starPosY) 
        end
    end
    ]]
    


    local petCard = {stars = starTable,str = str,bar = petBar,barBK = barBK,n,button = btn,level = petLevel,rare = rarei,
        attri = attribution,headBK = diban,head = icon}

    local rareRes = BattleFuncMgr.getStagePics(rarePoint) 
    CSResourceMgr.setSpriteTextureByNode(petCard.headBK, rareRes.p1)  
    local attriInfo     = tonumber(PokemonInfo.getPokemonInfoByID(petInfo.pokeID).elementAtt1)
    local attriRes      = "UI/CommonFiles/"..attriInfo..".png" 

    CSResourceMgr.setSpriteTextureByNode(petCard.rare, PetEducationMgr.getRareIcon(rarePoint),false)
    CSResourceMgr.setSpriteTextureByNode(petCard.head, PokemonInfo.getPokemonIconByID(petInfo.pokeID),false)
    CSResourceMgr.setSpriteTextureByNode(petCard.attri, attriRes,false) 

    if isHavePetName then
        local nameStr       = LuaSqlite.getLanguageByKey(petDatInfo.name)
        if isPersonalName then
            nameStr = PetEducationMgr.getPetName(petInfo)
        end
        str:setString(nameStr)
        str:setTextColor(PokemonInfo.COLOR[rarePoint])
    end
    
    local equiped = petCard.button:getChildByName("equiped")
    equiped:hide()

    return petCard
    
end

-------创建所有卡片后请调用结束 BattleFuncMgr.endCreatePetCard()
--@param petInfo   table        宠信息
--@param cardType  int         1为有血卡  2无血卡 3 有名字卡 ---默认为有名字的卡]
--@param isPersonalName bool    是否写个性名字
function BattleFuncMgr.startCreatePetCard(petInfo,cardType,isPersonalName)  
    local petCard = {}
    local res            =  "Pet/petcards/petcard.csb"
    if not BattleFuncMgr.petcard then 
        BattleFuncMgr.petcard = CSResourceMgr.createRes(nil,res)
    end

    local layerBtn      = BattleFuncMgr.petcard:getChildByName("btn")
    local isHaveBar     = true
    local isHavePetName = false

    if cardType == 1 then
        CSResourceMgr.setFrame(res, 0)
        layerBtn:setContentSize(92,120)
    elseif cardType == 2 then
        CSResourceMgr.setFrame(res, 1)
        layerBtn:setContentSize(92,108)
        isHaveBar = false
    else
        CSResourceMgr.setFrame(res, 2)
        layerBtn:setContentSize(92,120)
        isHaveBar = false
        isHavePetName = true
    end

    local btn           = layerBtn:clone()
    local petLevel      = btn:getChildByName("level")
    local diban         = btn:getChildByName("diban")
    local icon          = btn:getChildByName("icon")
    local rarei         = btn:getChildByName("rarei")
    local attribution   = btn:getChildByName("attri")
    local petBar        = btn:getChildByName("bar")
    local barBK         = btn:getChildByName("barBK")
    local str           = btn:getChildByName("str")
    local star          = btn:getChildByName("star") 
    local starTable     = {}
    local petDatInfo    = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
    local rarePoint     = petDatInfo.rarePoint
    local starPosX,starPosY   = star:getPosition()
    --printFileLog("startPosX,startPosY"..starPosX,starPosY)
    local starSize      = 15
        
    petLevel:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1) 
    str:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1)

    str:setTextColor({r = 215,g = 216,b = 217, a = 255})

    petLevel:setString("Lv"..petInfo.level)
    str:setString("")

    rarei:setScale(0.48)
    
    if not isHaveBar then
        barBK:hide()
        petBar:hide()
    end

    if petInfo.hp and petInfo.hpmax then
        local cardPer = 100*petInfo.hp/petInfo.hpmax
        petBar:setPercent(cardPer) 
    end

    if petInfo.star == 0 then
        star:hide()
    else
        local x = starPosX - (starSize*petInfo.star - starSize)/2
        star:setPosition(x,starPosY)
        starTable[1] = star
        local copyStars = petInfo.star-1
        for index = 1,copyStars do
            local copeStar = star:clone()
            starTable[1+index] = copeStar
            copeStar:addTo(btn)
            copeStar:setPosition(x+index*starSize,starPosY) 
        end
    end

    petCard = {stars = starTable,str = str,bar = petBar,barBK = barBK,node = layer,button = btn,level = petLevel,rare = rarei,
                attriBK = attridiban,attri = attribution,headBK = diban,head = icon,rarePoint = rarePoint} 
    
    local rareRes = BattleFuncMgr.getStagePics(rarePoint) 
    CSResourceMgr.setSpriteTextureByNode(petCard.headBK, rareRes.p1)  
    local attriInfo     = tonumber(PokemonInfo.getPokemonInfoByID(petInfo.pokeID).elementAtt1)
    local attriRes      = "UI/CommonFiles/"..attriInfo..".png" 

    CSResourceMgr.setSpriteTextureByNode(petCard.rare, PetEducationMgr.getRareIcon(rarePoint))
    CSResourceMgr.setSpriteTextureByNode(petCard.head, PokemonInfo.getPokemonIconByID(petInfo.pokeID))
    CSResourceMgr.setSpriteTextureByNode(petCard.attri, attriRes) 
    petCard.button.stars = starTable 
    if isHavePetName then
        local nameStr       = LuaSqlite.getLanguageByKey(petDatInfo.name)
        str:setTextColor(PokemonInfo.COLOR[rarePoint])
        if isPersonalName then
            nameStr = PetEducationMgr.getPetName(petInfo)
        end
        str:setString(nameStr)
    end

    return petCard
end

-------创建所有卡片后请调用结束 BattleFuncMgr.endCreatePetCard()
--@param petDataInfo   table        通过客户端的宠物信息显示宠物，参考图鉴，没有等级
--@param changebtn btn 宠物按钮元素,不为nil表示更新按钮的内容
function BattleFuncMgr.startCreatePetHandBookData(petDataInfo,changebtn)  
    local petCard = {}
    local isHaveBar     = false
    local isHavePetName = true
    local btn = nil
    if changebtn == nil then 
        local res            =  "Pet/petcards/petcard.csb"
        if not BattleFuncMgr.petcard then 
            BattleFuncMgr.petcard = CSResourceMgr.createRes(nil,res)
        end

        local layerBtn      = BattleFuncMgr.petcard:getChildByName("btn")
        btn           = layerBtn:clone()  
        CSResourceMgr.setFrame(res, 2)
        layerBtn:setContentSize(92,120) 
    else
    
        btn = changebtn 
    end

    local petLevel      = btn:getChildByName("level")
    local diban         = btn:getChildByName("diban")
    local icon          = btn:getChildByName("icon")
    local rarei         = btn:getChildByName("rarei")
    local attribution   = btn:getChildByName("attri")
    local petBar        = btn:getChildByName("bar")
    local barBK         = btn:getChildByName("barBK")
    local str           = btn:getChildByName("str")
    local star          = btn:getChildByName("star") 
    local starTable     = {}
    local petDatInfo    = petDataInfo
    local rarePoint     = petDatInfo.rarePoint
    local starPosX,starPosY   = star:getPosition()
    local starSize      = 15


    
    petLevel:setVisible(false)
    rarei:setScale(0.48)

    if not isHaveBar then
        barBK:hide()
        petBar:hide()
    end
	star:hide()
   
    petCard = {stars = starTable,str = str,bar = petBar,barBK = barBK,n,button = btn,level = petLevel,rare = rarei,
        attri = attribution,headBK = diban,head = icon}

    local rareRes = BattleFuncMgr.getStagePics(rarePoint) 
    CSResourceMgr.setSpriteTextureByNode(petCard.headBK, rareRes.p1)  
    local attriInfo     = tonumber(petDatInfo.elementAtt1)
    local attriRes      = "UI/CommonFiles/"..attriInfo..".png" 

    CSResourceMgr.setSpriteTextureByNode(petCard.rare, PetEducationMgr.getRareIcon(rarePoint))
    --printFileLog("petDataInfo icon"..petDatInfo.icon)
    
    local petFileName = string.format("Pet/PetIcon/%d.png", petDatInfo.icon)
    CSResourceMgr.setSpriteTextureByNode(petCard.head, petFileName)
    CSResourceMgr.setSpriteTextureByNode(petCard.attri, attriRes) 

    if isHavePetName then
        local nameStr       = LuaSqlite.getLanguageByKey(petDatInfo.name)
        str:setString(nameStr)
        str:setPositionY(23)
        str:setTextColor(PokemonInfo.COLOR[rarePoint])
    end
    
    CSResourceMgr.setButtonTextureByNode(btn,"empty.png","empty.png","empty.png")

    return petCard
end

-- function BattleFuncMgr.createSprite(parent,posX,posY)
--     local spRes = "Battle/downEdge_A/die.png"
--     local sp    = 
--     display.addImageAsync(spRes,function()
                
--         end)
-- end

function BattleFuncMgr.endCreatePetCard()
    if BattleFuncMgr.petcard then
        BattleFuncMgr.petcard:removeFromParent()
        BattleFuncMgr.petcard = nil
    end
end

function BattleFuncMgr.createSkillButton(parent,skillID,tag)
    local skillBtn       = {}
    local res            =  "UI/skillIcon/skill.csb" 
    local layer          =  CSResourceMgr.createRes(nil,res,tag)
    local button         =  CSResourceMgr.getNodeByName(res,"btn",tag)
    local button4        =  CSResourceMgr.getNodeByName(res,"btn4",tag)
    local rare           =  CSResourceMgr.getNodeByName(res,"rare",tag)
    local pic            =  CSResourceMgr.getNodeByName(res,"pic",tag)
    local skillBK        =  CSResourceMgr.getNodeByName(res,"skillBK",tag)
    local skillName      =  CSResourceMgr.getNodeByName(res,"skillName",tag)
    local consume        =  CSResourceMgr.getNodeByName(res,"consume",tag)
    local oil            =  CSResourceMgr.getNodeByName(res,"oil",tag)
    local skillInfo      =  PokemonInfo.getPetSkillInfoById(skillID)
    local skill4name     =  CSResourceMgr.getNodeByName(res,"skill4name",tag)
    local skill4BK       =  CSResourceMgr.getNodeByName(res,"skill4BK",tag)
    local pic4           =  CSResourceMgr.getNodeByName(res,"pic4",tag)

    local iconID = skillInfo.icon

    local skillRes = "Battle/skillIcon/"..iconID..".png"  
    local name     = LuaSqlite.getLanguageByKey(skillInfo.name) 
    

    CSResourceMgr.setFrame(res, 0,tag)
    local skillBKRes = "Battle/downEdge_A/fight_skill_base_01.png"
    if skillInfo.skill_A_Type == 8 then
        consume:hide()
        oil:hide() 
        CSResourceMgr.setSpriteTextureByNode(skillBK, skillBKRes)
    elseif skillInfo.skill_A_Type == 1 then
        CSResourceMgr.setFrame(res, 1,tag)
        
        skill4name:enableOutline({r = 38,g = 21,b = 0, a = 255} , 2)
        skill4name:setString(name)
        skill4name:setTextColor({r = 254,g = 243,b = 57, a = 255}) 
        CSResourceMgr.setSpriteTextureByNode(pic4, skillRes) 

        skillBtn = {button = button4,rare = rare,pic = pic4,
            skillName = skill4name,consume = consume,skillBK = skill4BK}
        skillBtn.button:removeFromParent()
        skillBtn.button:addTo(parent)
        return skillBtn
    else
        skillBKRes =  "Battle/downEdge_A/fight_skill_base_02.png"
        CSResourceMgr.setSpriteTextureByNode(skillBK, skillBKRes) 
        consume:enableOutline({r = 38,g = 21,b = 0, a = 255} , 2)
        consume:setString(skillInfo.energy)
    end
    local airpower = skillInfo.airpower

    if airpower < 1 then 
        airpower = 1
    end

    CSResourceMgr.setSpriteTextureByNode(pic, skillRes)
    skillName:setString(name)
    skillName:setTextColor(PokemonInfo.COLOR[airpower])

    skillBtn = {button = button,rare = rare,pic = pic,
        skillName = skillName,consume = consume,skillBK = skillBK,pic4 = pic4,skill4BK = skill4BK,skill4name = skill4name}
    skillBtn.button:removeFromParent()
    skillBtn.button:addTo(parent)
    return skillBtn
end

--@param petInfo   table        宠信息
--@param tag       int/string   标签   剩下的血量
--@param cardType  bool         true为名字卡片  false为血条卡片
function BattleFuncMgr.createPetCardWithBlood_older(petInfo,tag,cardType)
    tag = tag or ""

    local petCard = {}
    local res            =  "Pet/BasicPetList_2/BattlePet.csb"
    local layer         = CSResourceMgr.createRes(nil,res,tag)
    local btn           = CSResourceMgr.getNodeByName(res,"btn",tag)
    local petLevel      = CSResourceMgr.getNodeByName(res,{"btn","diban","level"},tag)
    local diban         = CSResourceMgr.getNodeByName(res,{"btn","diban"},tag)
    local icon          = CSResourceMgr.getNodeByName(res,{"btn","diban","icon"},tag)
    local rarei         = CSResourceMgr.getNodeByName(res,{"btn","rareidiban","rarei"},tag)
    local attridiban    = CSResourceMgr.getNodeByName(res,{"btn","attridiban"},tag)
    local attribution   = CSResourceMgr.getNodeByName(res,{"btn","attridiban","attri"},tag)
    local petBar        = CSResourceMgr.getNodeByName(res,{"btn","bar"},tag)
    local namenode      = CSResourceMgr.getNodeByName(res,{"btn","petName"},tag)
    local starTable     = {}
    local rarePoint     = PokemonInfo.getPokemonInfoByID(petInfo.pokeID).rarePoint

    for index = 1 ,5 do
        starTable[index] = CSResourceMgr.getNodeByName(res,{"btn","star"..index},tag)
    end
        
    petLevel:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1) 

    petLevel:setString("Lv"..petInfo.level)

    rarei:setScale(0.48)
    
    if cardType then
        petBar:setVisible(false)
        CSResourceMgr.getNodeByName(res,{"btn","hpBK"},tag):setVisible(false)
        CSResourceMgr.getNodeByName(res,{"btn","hp"},tag):setVisible(false)
        CSResourceMgr.getNodeByName(res,{"btn","barBK"},tag):setVisible(false)
        -- local nameStyle     = PetEducationMgr.getNameStyleByStage(rarePoint)
        local nameStr       = LuaSqlite.getLanguageByKey(PokemonInfo.getPokemonInfoByID(petInfo.pokeID).name)
        namenode:setString(nameStr)
        CSResourceMgr.setLabelColorByNode(namenode,PokemonInfo.COLOR[rarePoint])
        namenode:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1) 
    else
        namenode:setVisible(false)
        local cardPer = 100*petInfo.hp/petInfo.hpmax
        petBar:setPercent(cardPer) 
    end

    btn:removeFromParent()

    petCard = {star = starTable,bar = petBar,node = layer,button = btn,level = petLevel,rare = rarei,attriBK = attridiban,attri = attribution,headBK = diban,head = icon}
    
    -- if petInfo.Stage then
    local rareRes = "Pet/BasicPetList_2/Stage/"..rarePoint..".png"
    CSResourceMgr.setSpriteTextureByNode(petCard.headBK, rareRes)  
    -- end
    local attriInfo = tonumber(PokemonInfo.getPokemonInfoByID(petInfo.pokeID).elementAtt1)
    local attriRes = "Pet/AttriIcon/"..attriInfo..".png"
    local attrCirRes = "Pet/AttriIcon/small_"..attriInfo..".png"
    

    --设置星星位置的偏移量 add by lyx
    local unitdiff = petCard.star[1]:getContentSize().width/2
    local k = 1.5 --偏移系数
    local starcnt = tonumber(petInfo.star)
    if starcnt >= 3 and starcnt <5 then k = 1.8 end
    local alldiff = 0
    local movediff = 0
    if starcnt~=5 then
        alldiff = petCard.star[1]:getContentSize().width*k
        movediff= alldiff-(starcnt-1)*unitdiff
    end
    --设置星星位置偏移量结束
    
    for starID = 1,5 do
        if starID > starcnt then
            petCard.star[starID]:hide()
        else
            petCard.star[starID]:show()
            
            local originx = petCard.star[starID]:getPositionX();
            petCard.star[starID]:setPositionX(originx+movediff)
        end
    end
    

    CSResourceMgr.setSpriteTextureByNode(petCard.rare, PetEducationMgr.getRareIcon(rarePoint))
    CSResourceMgr.setSpriteTextureByNode(petCard.head, PokemonInfo.getPokemonIconByID(petInfo.pokeID))
    CSResourceMgr.setSpriteTextureByNode(petCard.attriBK, attrCirRes)
    CSResourceMgr.setSpriteTextureByNode(petCard.attri, attriRes)


    return petCard
end

function BattleFuncMgr.enterSceneShow(node,callback)
    node:setScale(3,3)
    transition.scaleTo(node, {scaleX = 0.8, scaleY = 0.8, time = 1/8,
        onComplete = function()
            node:scaleTo(1/12,0.8)
            transition.scaleTo(node, {scaleX = 1.2, scaleY = 1.2, time = 1/12,
                onComplete = function() 
                        transition.scaleTo(node, {scaleX = 1.0, scaleY = 1.0, time = 1/12,
                        onComplete = function() 
                                if callback then
                                    callback()
                                end
                            end,easing = "sineIn"}) 
                    end,easing = "sineIn"}) 
                end,easing = "sineIn"}) 
end

function BattleFuncMgr.enterJumpShow(node)
    local time = 0
    local jump_1 = cc.JumpBy:create(0.4,cc.p(0,0),300,1)
    local fadeIn = cc.FadeTo:create(0.2,255)
    local fadeSeq = cc.Sequence:create(cc.DelayTime:create(0.2),fadeIn)
    local spawn   = cc.Spawn:create(jump_1,fadeSeq)
    local jump_2  = cc.JumpBy:create(0.2,cc.p(0,0),100,1)
    local jump_3  = cc.JumpBy:create(0.2,cc.p(0,0),50,1)
    local jump_4  = cc.JumpBy:create(0.2,cc.p(0,0),10,1)

    local tottalSe = cc.Sequence:create(spawn,jump_2,jump_3,jump_4)
    node:runAction(tottalSe) 
        
end

--上下振动
--@param node 振动的对象
function BattleFuncMgr.upDownVibrationAni(node)
    transition.moveBy(node,{y = -40,time = 0.05})
    node:performWithDelay(function()
        transition.moveBy(node,{y = 80,time = 0.1})
        node:performWithDelay(function()
            transition.moveBy(node,{y = -80,time = 0.1})
            node:performWithDelay(function()
                transition.moveBy(node,{y = 40,time = 0.05})
            end,0.05)
        end,0.05)
    end,0.05)
end

function BattleFuncMgr.getStagePics(rareID)
    -- local info = PokemonInfo.getPetStageInfoData(stageID)
    local frameRes = "Pet/petcards/stage/"..rareID..".png"
    local circleRes = "Pet/BasicPetList_2/Attr/q"..rareID..".png"
    local vec = {p1=frameRes, p2=circleRes}
    return vec
end

function BattleFuncMgr.checkBloodPic(per)
    local resBlood = ""
    if per>75 then 
        resBlood = "Battle/petStatus/UI/fight_article_blood_green.png"
    elseif per>50 then
        resBlood = "Battle/petStatus/UI/fight_article_blood_green.png"
    else
        resBlood = "Battle/petStatus/UI/fight_article_blood_red.png" 
    end
    return resBlood
end

function BattleFuncMgr.catchPetAction(node,time,acType)
    local x1 = -1.5
    local y1 = 1.5
    local x2 = -1.0
    local y2 = 1.0
    local x3 = -1.3 
    local y3 = 1.3
    if acType == 0 then
        node:runAction(transition.sequence({
            cc.ScaleTo:create(time/4, x1,y1),
            cc.ScaleTo:create(time/4, x2,y2),
            cc.ScaleTo:create(time*2/4, x3,y3)
        }))
    else
        node:runAction(transition.sequence({
            cc.ScaleTo:create(time/6, x1,y1),
            cc.ScaleTo:create(time/6, x2,y2),
            cc.ScaleTo:create(time/6, x3,y3),
            cc.ScaleTo:create(time/6, x1,y1),
            cc.ScaleTo:create(time/6, x2,y2),
            cc.ScaleTo:create(time/6, x3,y3)
        }))
    end
end

function BattleFuncMgr.setNodeGray(node,isGray)
    local red = 255
    local green = 255
    local blue = 255
    if not isGray then
        red = 100
        green = 100
        blue = 100
    end
    -- transition.stopTarget(node)
    local actionExam = cc.TintTo:create(0.1,red,green,blue)
    node:runAction(actionExam)
end

function BattleFuncMgr.setNodeColor(node,red,green,blue)
    local nodeColor = cc.TintTo:create(0.1,red,green,blue)
    node:runAction(nodeColor)
end

-- isbool 是否循环播放
function BattleFuncMgr.nodeVaryColor(petType,node,color)
    --恢复颜色
    -- local red   = 255
    -- local green = 255
    -- local blue  = 255
    --改变颜色
    local redChange     = color[1]
    local greenChange   = color[2] 
    local blueChange    = color[3]
    
    -- local colorW = cc.TintTo:create(0.05,red,green,blue)
    local colorG = cc.TintTo:create(0.3,redChange,greenChange,blueChange)
    -- local colorC = cc.TintTo:create(0.05,red,green,blue) 
   
    -- local SequenceAction = cc.Sequence:create(colorG)
    if varyColorAction[petType] then
        transition.removeAction(varyColorAction[petType])
        varyColorAction[petType] = nil
    end

    -- varyColorAction[petType] = transition.execute(node,cc.RepeatForever:create(SequenceAction)) 
    varyColorAction[petType] = transition.execute(node,colorG) 
    
end

function BattleFuncMgr.nodeBeatenColor(petType,node,color)
    if  varyColorAction[petType] then 
        return
    end
    local red   = 255
    local green = 255
    local blue  = 255
    --改变颜色
    local redChange     = color[1]
    local greenChange   = color[2]
    local blueChange    = color[3]
    
    local colorW = cc.TintTo:create(0.05,red,green,blue)
    local colorG = cc.TintTo:create(0.25,redChange,greenChange,blueChange)
    local colorC = cc.TintTo:create(0.05,red,green,blue)

    local SequenceAction = cc.Sequence:create(colorG,colorC)
    -- if varyColorAction then
    --     transition.removeAction(varyColorAction)
    --     varyColorAction = nil
    -- end
    -- varyColorAction = transition.execute(node,SequenceAction) 

    transition.execute(node,SequenceAction)

end

function BattleFuncMgr.removeVaryColor(petType,node)
    if varyColorAction[petType] then
        transition.removeAction(varyColorAction[petType])
        varyColorAction[petType] = nil
        BattleFuncMgr.setNodeGray(node,true)
        node:opacity(255)
    end
end

function BattleFuncMgr.richFontString(parent,label,str)
    local labelMaxWidth = 500
    local RFontSize = label:getFontSize()
    local richLabelS = CocosModuleMgr.createRichLabel(parent, str, RFontSize, "cuyuan_GBK.ttf", labelMaxWidth)
    richLabelS:zorder(10)
    richLabelS:setAnchorPoint(0,0.5)
    if richLabelS.realWidth>labelMaxWidth then
        richLabelS:setPosition(label:getPositionX(), label:getPositionY())
    else
        richLabelS:setPosition(label:getPositionX(), label:getPositionY())
    end
    return richLabelS
end

---BattleFuncMgr.pressButtonMenu 按钮
---@param
function BattleFuncMgr.pressButtonMenu(btn,menuTbl)
    local contSize = btn:getContentSize()
    local posX = contSize.width/2
    local posY = contSize.height/2
    if #menuTbl > 4 then
        printFileLog("超出菜单上限")
        return
    end
    for key,var in pairs(menuTbl) do
        if not var["menu"]:getParent() then
            var["menu"]:addTo(btn)
        end
        var["menu"]:setScale(0.0,0.0)
        if key == 1 then
            posY =  contSize.height
            var["menu"]:setAnchorPoint(0.5,0)
        elseif key == 2 then
            posX = 0
            var["menu"]:setAnchorPoint(1.0,0.5)
        elseif key == 3 then
            posY = 0
            var["menu"]:setAnchorPoint(0.5,1.0)
        elseif key == 4 then
            posX = contSize.width
            var["menu"]:setAnchorPoint(0.0,0.5)
        end
        var["menu"]:setPosition(posX,posY)
    end
    local isScale = false
    btn:addTouchEventListener(function(sender,state)
        local moveY = btn:getTouchMovePosition().y
        local gapY = moveY - btn:getTouchBeganPosition().y
        local moveX = btn:getTouchMovePosition().x
        local gapX = moveX - btn:getTouchBeganPosition().x

        local function triggerMenu(isFinish)
            local function selectedEvent(index)
                if isFinish then
                    menuTbl[index]["menu"]:performWithDelay(function()
                        menuTbl[index]["callback"]()
                    end, 0.1)
                else
                    BattleFuncMgr.setNodeGray(menuTbl[index]["menu"],true)

                    if isScale then
                        menuTbl[index]["menu"]:setScale(1.2,1.2)
                    end
                end
            end
            if moveX < 0 or moveX > contSize.width or moveY < 0 or moveY > contSize.height then
                isScale = true
                if math.abs(gapY) > math.abs(gapX) then
                    if gapY > 0 then
                        if menuTbl[1] ~= nil then
                            selectedEvent(1)
                        end
                    elseif gapY < 0 then
                        if menuTbl[3] ~= nil then
                            selectedEvent(3)
                        end
                    end
                elseif math.abs(gapY) < math.abs(gapX) then
                    if gapX < 0 then
                        if menuTbl[2] ~= nil then
                            selectedEvent(2)
                        end
                    elseif gapX > 0 then
                        if menuTbl[4] ~= nil then
                            selectedEvent(4)
                        end
                    end
                end
            else
                isScale = false
            end
        end
        if state == 0 then
            isScale = true
            for key,var in pairs(menuTbl) do
                BattleFuncMgr.setNodeGray(var["menu"],false)
                var["menu"]:scaleTo(0.1,1.0)
            end
            BattleFuncMgr.bubbleButton(btn)
        elseif state == 1 then
            for key,var in pairs(menuTbl) do
                BattleFuncMgr.setNodeGray(var["menu"],false)
                var["menu"]:scaleTo(0.1,1.0)
            end
            triggerMenu(false)
        elseif state == 2 then
            btn:performWithDelay(function()
                for key,var in pairs(menuTbl) do
                    var["menu"]:scaleTo(0.05,0.0)
                end
            end,0.1)

        elseif state == 3 then
            triggerMenu(true)
            
            btn:performWithDelay(function()
                for key,var in pairs(menuTbl) do
                    var["menu"]:performWithDelay(function()
                        var["menu"]:scaleTo(0.05,1.1)
                        var["menu"]:performWithDelay(function()
                            transition.scaleTo(var["menu"],{scaleX = 0,scaleY = 1.0,time = 0.1})
                        end,0.05)
                    end, 0.08)
                end
            end,0.1)
        end
    end)
end

function BattleFuncMgr.DragButtonEvent(btn,callBack)
    local posX = btn:getPositionX()
    local posY = btn:getPositionY()
    local contSize = btn:getContentSize()

    btn:addTouchEventListener(function(sender,state)
        local moveX = btn:getTouchMovePosition().x
        local moveY = btn:getTouchMovePosition().y
        local gapY = moveY - btn:getTouchBeganPosition().y
        if state == 1 then
            if gapY > 0 and gapY <= 50 then
                btn:setPosition(posX,posY+gapY)
            end
        elseif state == 2 then
            if gapY >= 50 then
                callBack()
            end
            btn:moveTo(0.2,posX,posY)
        elseif state == 3 then
            if gapY >= 50 then
                callBack()
            end
            btn:moveTo(0.2,posX,posY)
        end
    end)
    btn:setPressedActionEnabled(true)
end

---读取Gaf,txt关键帧
-------------------------------
--@param
--@return
function BattleFuncMgr.setGafFrameAndEvent(resName)
    local fileName = string.gsub(resName, ".gaf", ".txt")
    local fileExist = cc.FileUtils:getInstance():isFileExist(fileName)
    if fileExist == false  then
        printFileLog(fileName.." 不存在")
        return
    end
    if BattleFuncMgr.gafSkillEventTbl[resName] ~= nil then
        return
    end
    BattleFuncMgr.gafSkillEventTbl[resName] = {}
    local filePath = cc.FileUtils:getInstance():fullPathForFilename(fileName)
    local rfile = cc.FileUtils:getInstance():getStringFromFile(filePath)
    local striTable = lua_string_split(string.gsub(rfile, "\r", ""), "\n")
    local numStr = nil
    for row,line in pairs(striTable) do
        if line~="" then
            local strTbl = lua_string_split(line, ",")
            local numPos = string.find(strTbl[2],"%d")
            local isAgain = false
            if string.find(strTbl[2],"%d") ~= nil then
                if table.getn(BattleFuncMgr.gafSkillEventTbl[resName]) ~= 0 then
                    for key,var in pairs(BattleFuncMgr.gafSkillEventTbl[resName]) do
                        if string.sub(var["event"],1,numPos) == string.sub(strTbl[2],1,numPos) then
                            local keyFrame = tonumber(strTbl[1])
                            BattleFuncMgr.gafSkillEventTbl[resName][key].gapFrm =  keyFrame - var["frame"]
                            isAgain = true
                            break
                        end
                    end
                end
            end

            if isAgain == false then
                local addTbl = {frame = tonumber(strTbl[1]), event = strTbl[2]}
                table.insert(BattleFuncMgr.gafSkillEventTbl[resName],addTbl)
            end
            --            local keyPos = string.find(line,"label")
            --            if keyPos == nil then
            --                printFileLog(line)
            --                printFileLog("没有事件")
            --            else
            --                printFileLog("有字符串"..keyPos)
            --                local event = string.sub(line,keyPos+7,-4)
            --                _,_, numStr = string.find(line,"(%d+%d)")
            --                printFileLog(sz_T2S(numStr))
            --                printFileLog("event = "..sz_T2S(event))
            --            end
        end
    end

end
---cutIn
function BattleFuncMgr.cutInLogic(node,callBack)
    node:show()
    node:performWithDelay(function()
        node:scaleTo(0.05,1.1)
        node:performWithDelay(function()
            node:performWithDelay(function()
                node:scaleTo(0.05,0.3)
                node:performWithDelay(function()
                    node:scaleTo(0.1,1.0)
                    node:fadeOut(0.1)
                    node:performWithDelay(function()
                        callBack()
                    end, 0.1)
                end,0.05)
            end,0.05)
        end,0.05)
    end,1.0)
end

-- function BattleFuncMgr.moveScreenCenter(node,time)
--     local parent = node:getParent()
--     local organPosX , organPosY = node:getPosition()
--     local nodeWorldPos = parent:convertToWorldSpaceAR(cc.p(organPosX,organPosY))
--     local parentSize = parent:getContentSize()
--     local nodeInWorkX = node:getPositionX() + parent:getPositionX() - parentSize.width/2
--     local nodeInWorkY = node:getPositionY() + parent:getPositionY() - parentSize.height/2
--     local nodeGapX = display.cx - nodeWorldPos.x + parentSize.width/2
--     local nodeGapY = display.cy - nodeWorldPos.y + parentSize.height/2

--     parent:moveBy(time,nodeGapX,nodeGapY)
--     return nodeGapX,nodeGapY
-- end

-- function BattleFuncMgr.getNodeCenterPos(node)
--     local parent = node:getParent()
--     local organPosX , organPosY = node:getPosition()
--     local nodeWorldPos = parent:convertToWorldSpaceAR(cc.p(organPosX,organPosY))
--     local parentSize = parent:getContentSize()
--     --    local nodeInWorkX = node:getPositionX() + parent:getPositionX() - parentSize.width/2
--     --    local nodeInWorkY = node:getPositionY() + parent:getPositionY() - parentSize.height/2
--     local nodeGapX = display.cx - nodeWorldPos.x + parentSize.width/2
--     local nodeGapY = display.cy - nodeWorldPos.y + parentSize.height/2

--     --    nodeGapX = nodeGapX + organPosX
--     --    nodeGapY = nodeGapY + organPosY
--     return nodeGapX,nodeGapY
-- end

function BattleFuncMgr.setNodePosFrontStr(label,node,str)
    local levelStr = str
    label:setAnchorPoint(1.0,0.5)
    label:setString(levelStr)
    local labelX = label:getPositionX()
    local labelY = label:getPositionY()
    local lableSize = label:getContentSize()
    node:setAnchorPoint(1.0,0.5)
    local nodePosX = labelX-lableSize.width
    node:setPosition(nodePosX,labelY)

end
---字板的显示
---------------------------
--@param
--@return
function BattleFuncMgr.showLabel(message,num,atker,defenser)
    local downEdgeRes = "Battle/battleScene/downEdge.csb"
    local label = CSResourceMgr.getNodeByName(downEdgeRes, "label1")
    if not label then
        return
    end
    transition.stopTarget(label)
    CSResourceMgr.setLabelString(downEdgeRes, "label1", message)
    CSResourceMgr.setLabelColor(downEdgeRes, "label1",{r=0,g=0,b=0,a=255})
    CSResourceMgr.setLabelMaxWidth(downEdgeRes, "label1", 480)
    label:setAnchorPoint(0, 1)
    label:setString("")
    local curString = message
    local curStringProcess = 0
    local curStringLen = 0

    local function getUpdateStr(process)
        curStringLen = curStringLen + 1
        local tmpstr = ChatMsgMgr.SubUTF8String(curString, curStringLen)
        --printFileLog("getUpdateStr:"..tmpstr..",len:"..string.utf8len(tmpstr)..",pro:"..process)
        if process>string.utf8len(tmpstr) then
            return getUpdateStr(process)
        else
            return tmpstr
        end
    end

    local function updateLabel(label)
        if curStringProcess>=string.utf8len(curString) then
            transition.stopTarget(label)
            return
        end
        label:performWithDelay(function()
            curStringProcess = curStringProcess + 1
            local tmpstr = getUpdateStr(curStringProcess)
            label:setString(tmpstr)
            updateLabel(label)
        end, TownMapBoardMgr.DEFAULT_LABEL_UPDATE_TIME)
    end
    if num == 0 then
        local atkerLB = CSResourceMgr.getNodeByName(downEdgeRes, "txAtker")
        local defenserLB = CSResourceMgr.getNodeByName(downEdgeRes, "txFenser")
        local messageLB =  CSResourceMgr.getNodeByName(downEdgeRes, "decriLaber")
        curString = atker
        updateLabel(atkerLB)
        local count = string.utf8len(curString)
        messageLB:performWithDelay(function()
            curStringProcess = 0
            curStringLen = 0
            curString = message
            updateLabel(messageLB)
            count = string.utf8len(curString)
            if defenser ~= "" then
                defenserLB:performWithDelay(function()
                    curStringProcess = 0
                    curStringLen = 0
                    curString = defenser
                    updateLabel(defenserLB)
                end,count*TownMapBoardMgr.DEFAULT_LABEL_UPDATE_TIME+TownMapBoardMgr.DEFAULT_LABEL_UPDATE_TIME)
            end
        end,count*TownMapBoardMgr.DEFAULT_LABEL_UPDATE_TIME+TownMapBoardMgr.DEFAULT_LABEL_UPDATE_TIME)
    else
    --        updateLabel(label)
    end
    label:setLocalZOrder(50)
end

function BattleFuncMgr.cleanHandles()
    for key,var in pairs(handlerTbl) do
        if var ~= nil then
            scheduler.unscheduleGlobal(var)
            handlerTbl[key] = nil
        end
    end
end

---设置宠物受击方式
--@param acType 0闪避,1死亡,2受击
--0抖动 1击退（缩小调整位置，造成一种立体的远离效果）2拉伸（上下）3变红拉伸（上下）4变蓝不动 5变黄抖动 6挤压缩小
function BattleFuncMgr.actiBeatenStyle(pet,rate,actType,speedRate)
    local time = 0.2
    if actType == 0 then
        local pet1AttcPosX = 30
        transition.moveBy(pet,{x = -1*pet1AttcPosX,time = 0.08/speedRate})
        pet:performWithDelay(function()
            transition.moveBy(pet,{x = pet1AttcPosX,time = 0.4/speedRate})
        end,0.08/speedRate)
        time = 0.48/speedRate
    elseif actType == 1 then
        transition.scaleTo(pet,{scaleY = 1.2,time = 0.2/speedRate})
        pet:performWithDelay(function()
            pet:opacity(100)
            pet:scaleTo(0.3/speedRate,0)
            pet:moveBy(0.4/speedRate, 0, -50)
            pet:performWithDelay(function()
                pet:opacity(255)
                pet:moveBy(0.05, 0, 50)
            end,0.3/speedRate)
        end,0.2/speedRate)
        time = 0.6
    elseif actType == 2 then
        
    end
    return time
end

function BattleFuncMgr.getAttributeStateValue(skillID,petID)
    local skillAttrit = PokemonInfo.getPetSkillInfoById(skillID).skillAtt
    local petAttriFirst = PokemonInfo.getPokemonInfoByID(petID).elementAtt1
    local petAttriSce = PokemonInfo.getPokemonInfoByID(petID).elementAtt2
    return  ELEMENT_GRAMS[skillAttrit][petAttriFirst] * ELEMENT_GRAMS[skillAttrit][petAttriSce]
end

function BattleFuncMgr.fightLabelAddHpShow(node,endFuc)

    node:setCascadeOpacityEnabled(true)
    node:setScale(1.3)
    local move     = cc.MoveBy:create(0.45,cc.p(0,150))
    local wait     = cc.DelayTime:create(0.3)
    local fade      = cc.FadeOut:create(0.15)
    local endFuc    = cc.CallFunc:create(endFuc) 

    node:runAction(transition.sequence({
        cc.Spawn:create(move,cc.Sequence:create(wait,fade)),
        endFuc
    })) 

end

function BattleFuncMgr.fightLabelCriticalShow(node,endFuc)

    node:setCascadeOpacityEnabled(true)
    if node.head then
        node.head:setOpacity(0)
        local scale1 = transition.sequence({
            cc.DelayTime:create(0.1),
            cc.CallFunc:create(function()
                node.head:setOpacity(255)
                node.head:setScale(1.04)
            end)
        })
        local scale2 = cc.ScaleTo:create(0.1, 1.3)
        local scale3 = cc.ScaleTo:create(0.3, 1.5)
        local scale4 = cc.FadeOut:create(0.2)
        local action1 = transition.sequence({
            scale1,scale2,scale3,scale4
        })
        local move1 = cc.DelayTime:create(0.1)
        local move2 = cc.MoveBy:create(0.0,cc.p(20,10))
        local move3 = cc.MoveBy:create(0.3,cc.p(0,0))
        local move4 = cc.MoveBy:create(0.2,cc.p(0,0))
        local action2 = transition.sequence({
            move1,move2,move3,move4
        })
        node.head:runAction(cc.Spawn:create(action1,action2))
    end
    if node.label then
        node.label:setScale(0.4*1.3)
        node.label:setOpacity(255/2)
        local scale1 = cc.ScaleTo:create(0.1, 2.5*1.3)
        local alpha1 = cc.FadeIn:create(0.1)
        local scale2 = cc.ScaleTo:create(0.1, 1.1*1.3)
        local scale3 = cc.ScaleTo:create(0.3, 1.12*1.3)
        local scale4 = cc.ScaleTo:create(0.2, 0.93*1.3)
        local alpha4 = cc.FadeOut:create(0.2)
        local action1 = transition.sequence({
            cc.Spawn:create(scale1,alpha1),scale2,scale3,cc.Spawn:create(scale4,alpha4)
        })
        local move1 = cc.MoveBy:create(0.1,cc.p(0,0))
        local move2 = cc.MoveBy:create(0.1,cc.p(0,0))
        local move3 = cc.MoveBy:create(0.3,cc.p(0,0))
        local move4 = cc.MoveBy:create(0.2,cc.p(0,0))
        local action2 = transition.sequence({
            move1,move2,move3,move4,cc.CallFunc:create(endFuc)
        })
        node.label:runAction(cc.Spawn:create(action1,action2))
    end

end

--场景晃动
--@param node 振动的对象
function BattleFuncMgr.vibrationScene(node,callback)
    local posY  = {7,5,6,9,6,5}  
    local time  = 0.04
    local index = 1

    local move1 = cc.MoveTo:create(time, cc.p(0,posY[1]))
    local move2 = cc.MoveTo:create(time, cc.p(0,-1*posY[1]))
    local callfunc = nil
    if callback then
        callfunc = cc.CallFunc:create(callback)
    end
    transition.stopTarget(node) 
    local jump1 = cc.JumpTo:create(time,cc.p(0,0),posY[1],1)
    local jump2 = cc.JumpTo:create(time,cc.p(0,0),-1*posY[1],1)
    local jump3 = cc.JumpTo:create(time,cc.p(0,0),posY[2],1)
    local jump4 = cc.JumpTo:create(time,cc.p(0,0),-1*posY[2],1)
    local jump5 = cc.JumpTo:create(time,cc.p(0,0),posY[3],1)
    local jump6 = cc.JumpTo:create(time,cc.p(0,0),-1*posY[3],1)
    local jump7 = cc.JumpTo:create(time,cc.p(0,0),posY[4],1)
    local jump8 = cc.JumpTo:create(time,cc.p(0,0),-1*posY[4],1)
    local jump9 = cc.JumpTo:create(time,cc.p(0,0),posY[5],1)
    local jump10 = cc.JumpTo:create(time,cc.p(0,0),-1*posY[5],1)
    local jump11 = cc.JumpTo:create(time,cc.p(0,0),posY[6],1)
    local jump12 = cc.JumpTo:create(time,cc.p(0,0),-1*posY[6],1)  


    local action = transition.sequence({
            jump1,jump2,jump3,jump4,jump5,jump6,jump7,jump8,jump9,jump10,jump11,jump12,callfunc
        })
    node:runAction(action)


end

--场景晃动
--@param node 振动的对象
function BattleFuncMgr.bossVibrationScene(node,callback)
    local posY  = {20,15,15,13,10,15}   
    local time  = 0.04
    local index = 1

    local move1 = cc.MoveTo:create(time, cc.p(0,posY[1]))
    local move2 = cc.MoveTo:create(time, cc.p(0,-1*posY[1]))
    local callfunc = nil
    if callback then
        callfunc = cc.CallFunc:create(callback)
    end
    transition.stopTarget(node) 
    local jump1 = cc.JumpTo:create(time,cc.p(0,0),posY[1],1)
    local jump2 = cc.JumpTo:create(time,cc.p(0,0),-1*posY[1],1)
    local jump3 = cc.JumpTo:create(time,cc.p(0,0),posY[2],1)
    local jump4 = cc.JumpTo:create(time,cc.p(0,0),-1*posY[2],1)
    local jump5 = cc.JumpTo:create(time,cc.p(0,0),posY[3],1)
    local jump6 = cc.JumpTo:create(time,cc.p(0,0),-1*posY[3],1)
    local jump7 = cc.JumpTo:create(time,cc.p(0,0),posY[4],1)
    local jump8 = cc.JumpTo:create(time,cc.p(0,0),-1*posY[4],1)
    local jump9 = cc.JumpTo:create(time,cc.p(0,0),posY[5],1)
    local jump10 = cc.JumpTo:create(time,cc.p(0,0),-1*posY[5],1)
    local jump11 = cc.JumpTo:create(time,cc.p(0,0),posY[6],1)
    local jump12 = cc.JumpTo:create(time,cc.p(0,0),-1*posY[6],1)  


    local action = transition.sequence({
            jump1,jump2,jump3,jump4,jump5,jump6,jump7,jump8,jump9,jump10,jump11,jump12,callfunc
        })
    node:runAction(action)


end

function BattleFuncMgr.shakeScreen(node,callback)

    local posY  = {20,15,15,13,10,15}   
    local time  = 0.04

    transition.stopTarget(node) 
    local jump1 = cc.JumpBy:create(time,cc.p(0,0),posY[1],1)
    local jump2 = cc.JumpBy:create(time,cc.p(0,0),-1*posY[1],1)
    local jump3 = cc.JumpBy:create(time,cc.p(0,0),posY[2],1)
    local jump4 = cc.JumpBy:create(time,cc.p(0,0),-1*posY[2],1)
    local jump5 = cc.JumpBy:create(time,cc.p(0,0),posY[3],1)
    local jump6 = cc.JumpBy:create(time,cc.p(0,0),-1*posY[3],1)
    local jump7 = cc.JumpBy:create(time,cc.p(0,0),posY[4],1)
    local jump8 = cc.JumpBy:create(time,cc.p(0,0),-1*posY[4],1)
    local jump9 = cc.JumpBy:create(time,cc.p(0,0),posY[5],1)
    local jump10 = cc.JumpBy:create(time,cc.p(0,0),-1*posY[5],1)
    local jump11 = cc.JumpBy:create(time,cc.p(0,0),posY[6],1)
    local jump12 = cc.JumpBy:create(time,cc.p(0,0),-1*posY[6],1)
    local x, y = BossMapMgr.getRootNodeXY()
    local jump13 = cc.MoveTo:create(time,cc.p(x, y))

    local action = transition.sequence({
        jump1,jump2,jump3,jump4,jump5,jump6,jump7,jump8,jump9,jump10,jump11,jump12,jump13
        })
    node:runAction(action)

    local bg = display.newSprite("Battle/worldboss/red.png")
    bg:setScale(10)
    bg:setPosition(display.cx,display.cy)
    bg:addTo(SceneMgr.getRunningScene)
    bg:zorder(10)
    bg:runAction(transition.sequence({
        cc.FadeOut:create(0.05),
        cc.FadeIn:create(0.05),
        cc.FadeOut:create(0.05),
        cc.CallFunc:create(function()
            bg:removeFromParent()
        end)
    }))

end

function BattleFuncMgr.fightLabelMissShow(node,endFuc)

    node:setCascadeOpacityEnabled(true)
    local move     = cc.MoveBy:create(0.15,cc.p(0,70))
    local scale1     = cc.ScaleTo:create(0.15, 2)
    local scale2     = cc.ScaleTo:create(0.15, 1)
    local fade      = cc.FadeOut:create(0.4)
    local endFuc    = cc.CallFunc:create(endFuc) 

    node:runAction(transition.sequence({
        cc.Spawn:create(move,scale1),
        scale2,
        fade,
        endFuc
    }))

end 
---设置宠物攻击方式
--@param acType 0不动型    1后退前冲型  2前冲后退型  3原地转圈型 4右移返回型
--5上下颤动型 6缩小放大型 7放大缩小型 8左右移动型 9左右晃动型 10压缩拉伸型
function BattleFuncMgr.actionStyle(pet,rate,actType,isFinish,speed)
    local time = 1.0/speed
    local pet1AttcPosX = 30
    local pet1AttcPosY = 30

    if isFinish then
        transition.moveBy(pet,{x = -rate*pet1AttcPosX,y = -rate*pet1AttcPosY,time = 0.1/speed})
    else
        transition.moveBy(pet,{x = rate*pet1AttcPosX,y = rate*pet1AttcPosY,time = 0.1/speed}) 
    end
    return time
end

function BattleFuncMgr.setSkillIcon(node,skillInfo)
    local skillIconStr ="Battle/skillIcon/"..skillInfo.icon..".png"
    if not BattleFuncMgr.isFileExist(skillIconStr) then
        skillIconStr = "Battle/skillIcon/default.png"
    end
    CSResourceMgr.setSpriteTextureByNode(node, skillIconStr)
end

function BattleFuncMgr.setLabelLenByNode(label,widthLen)
    if widthLen then
        label:setScaleX(label:getScaleY())
        local width = label:getContentSize().width*label:getScaleX()
        if width>widthLen then
            local scale = widthLen/width
            label:setScaleX(scale*label:getScaleX())
        end
    end
end

function sz_T2S(_t)
    if type(_t) == "number" then
        return "" .. _t
    elseif type(_t) == "string" then
        return '"' .. _t .. '"'
    elseif type(_t) == "boolean" then
        if _t == true then
            return "true"
        else
            return "false"
        end
    end
    local szRet = "{"
    function doT2S(_i, _v)
        if "number" == type(_i) then
            szRet = szRet .. "[" .. _i .. "] = "
            if "number" == type(_v) then
                szRet = szRet .. _v .. ","
            elseif "string" == type(_v) then
                szRet = szRet .. '"' .. _v .. '"' .. ","
            elseif "boolean" == type(_v) then
                if _v == true then
                    szRet = szRet .. "true" .. ","
                else
                    szRet = szRet .. "false" .. ","
                end
            elseif "table" == type(_v) then
                szRet = szRet .. sz_T2S(_v) .. ","
            else
                szRet = szRet .. "nil,"
            end
        elseif "string" == type(_i) then
            szRet = szRet .. '["' .. _i .. '"] = '
            if "number" == type(_v) then
                szRet = szRet .. _v .. ","
            elseif "string" == type(_v) then
                szRet = szRet .. '"' .. _v .. '"' .. ","
            elseif "boolean" == type(_v) then
                if _v == true then
                    szRet = szRet .. "true" .. ","
                else
                    szRet = szRet .. "false" .. ","
                end
            elseif "table" == type(_v) then
                szRet = szRet .. sz_T2S(_v) .. ","
            else
                szRet = szRet .. "nil,"
            end
        end
    end
    table.foreach(_t, doT2S)
    szRet = szRet .. "}"
    return szRet
end
return BattleFuncMgr