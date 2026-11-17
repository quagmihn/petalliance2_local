local AnimationMgr = {}

AnimationMgr.ANI_TYPE_ERROR = 0
AnimationMgr.ANI_TYPE_GAF = 1
AnimationMgr.ANI_TYPE_SPINE = 2
AnimationMgr.ANI_TYPE_CSB = 3

AnimationMgr.DEFAULT_GAF_WIDTH = 1136
AnimationMgr.DEFAULT_GAF_HEIGHT = 640

AnimationMgr.AnimationObjTable = {}
AnimationMgr.MotionTable = {}
AnimationMgr.KeyFrameTable = {}

local scheduler = nil

---重新初始化AnimationMgr，用于动态lua调试
function AnimationMgr.Init()
    print("AnimationMgr初始化")    
    AnimationMgr.AnimationObjTable = {}
    AnimationMgr.SchedulerHandleTable = {}
    AnimationMgr.MotionTable = {}
    AnimationMgr.KeyFrameTable = {}
    
    scheduler = require("src.framework.scheduler")
end

---通过tag获取动画Object
--@param resName string 资源名称，例如:gaf动画"123.gaf"/spine动画"123.png"
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function AnimationMgr.getGafObj(resName, tag)
    if not resName then
    	return nil
    end
    tag = tag or ""
    local gafobj = AnimationMgr.AnimationObjTable[resName..tag]
    return gafobj
end

---获取gaf动画的某个动作的持续时间
--@param resName string 资源名称，例如:gaf动画"123.gaf"/spine动画"123.png"
--@param motionName string 动作名称（填在xml配置表中）
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function AnimationMgr.getGafMotionTimeInterval(resName, motionName, tag)
    tag = tag or ""
    
    if AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_GAF then
        local gafobj = AnimationMgr.AnimationObjTable[resName..tag]
        if AnimationMgr.MotionTable[resName..tag]==nil then
            print("获取"..resName..tag.."的动画配置文件失败")
            return 0
        end
        local startF = tonumber(AnimationMgr.MotionTable[resName..tag][motionName][1])
        local endF = tonumber(AnimationMgr.MotionTable[resName..tag][motionName][2])
        local fps = gafobj:getFps()
        local delayTime = (1.00/fps)*(endF - 1 - startF)
        if delayTime < 0 then
            delayTime = 0
        end
        return delayTime
    elseif AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_SPINE then
        print("spine动画暂不支持获取")
        return 0
    end
end

---获取动画Object当前播放的动画
--@param resName string 资源名称，例如:gaf动画"123.gaf"/spine动画"123.png"
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function AnimationMgr.getGafObjCurMotionName(resName, tag)
    tag = tag or ""
    if AnimationMgr.MotionTable[resName..tag] then
        return AnimationMgr.MotionTable[resName..tag]["curAniName"]
    end
    return "null"
end

---播放动画
--@param resName string 资源名称，例如:gaf动画"123.gaf"/spine动画"123.png"
--@param motionName string 动作名称（gaf动画填在xml配置表中）
--@param isLoop bool 是否循环播放
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function AnimationMgr.playAni(resName, motionName, isLoop, tag)
    tag = tag or ""
    local gafobj = AnimationMgr.AnimationObjTable[resName..tag]
    
    if AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_GAF then
        if AnimationMgr.MotionTable[resName..tag]==nil then
            print("获取"..resName..tag.."的动画配置文件失败, 播放gaf动画失败")
            return false
        end
        local startF = tonumber(AnimationMgr.MotionTable[resName..tag][motionName][1])
        local endF = tonumber(AnimationMgr.MotionTable[resName..tag][motionName][2])
        AnimationMgr.playAniFrame(resName, startF, endF, isLoop, tag)
    elseif AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_SPINE then
        gafobj:setToSetupPose()
        gafobj:setAnimation(0, motionName, isLoop)
        AnimationMgr.MotionTable[resName..tag]["curAniInfo"] = {}
    end
    
    AnimationMgr.MotionTable[resName..tag]["curAniName"] = motionName
end

---播放动画并执行回调
--@param resName string 资源名称，例如:gaf动画"123.gaf"/spine动画"123.png"
--@param motionName string 动作名称（gaf动画填在xml配置表中）
--@param callback function 播放完毕后的回调函数
--@param tag string 标签名，重复创建同一个资源动画时用来区分
--@param doClean bool 播放完是否删除
function AnimationMgr.playAniWithCallback(resName, motionName, callback, tag, doClean)
    tag = tag or ""
    local gafobj = AnimationMgr.AnimationObjTable[resName..tag]
    
    if AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_GAF then
        if AnimationMgr.MotionTable[resName..tag]==nil then
            print("获取"..resName..tag.."的动画配置文件失败, 播放gaf动画失败")
            return false
        end
        local startF = tonumber(AnimationMgr.MotionTable[resName..tag][motionName][1])
        local endF = tonumber(AnimationMgr.MotionTable[resName..tag][motionName][2])
        AnimationMgr.playAniFrameWithCallback(resName, startF, endF, callback, tag)
    elseif AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_SPINE then
        gafobj:setToSetupPose()
        gafobj:setAnimation(0, motionName, false)
        gafobj:registerSpineEventHandler(function()
            gafobj:registerSpineEventHandler(function() end, sp.EventType.ANIMATION_COMPLETE)
            if callback then
                callback()
            end
            if doClean then
                gafobj:performWithDelay(function()
                    AnimationMgr.removeGafObjectByTag(resName, tag)
                end, 0.1)
            end
        end, sp.EventType.ANIMATION_COMPLETE)
        AnimationMgr.MotionTable[resName..tag]["curAniInfo"] = {}
    end
    
    AnimationMgr.MotionTable[resName..tag]["curAniName"] = motionName
end

---播放动画并在特殊帧执行回调
--@param resName string 资源名称，例如:gaf动画"123.gaf"/spine动画"123.png"
--@param motionName string 动作名称（gaf动画填在xml配置表中）
--@param callback function 特殊帧的回调函数（spine动画会得到参数event，可得到event.animation,event.eventData.name）
--@param endCallback function 播放完毕后的回调函数
--@param tag string 标签名，重复创建同一个资源动画时用来区分
--@param doClean bool 播放完是否删除
function AnimationMgr.playAniWithSpCallback(resName, motionName, callback, endCallback, tag, doClean)
    tag = tag or ""
    local gafobj = AnimationMgr.AnimationObjTable[resName..tag]
    
    if AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_GAF then
        local spFrame = tonumber(AnimationMgr.KeyFrameTable[resName..tag][motionName.."_KeyFrame"][1])    
        if spFrame == nil then
            print("特殊帧为空，此次播放无效")
            return false
        end
        if AnimationMgr.MotionTable[resName..tag]==nil then
            print("获取"..resName..tag.."的动画配置文件失败, 播放gaf动画失败")
            return false
        end
        local startF = tonumber(AnimationMgr.MotionTable[resName..tag][motionName][1])
        local endF = tonumber(AnimationMgr.MotionTable[resName..tag][motionName][2])
        AnimationMgr.playAniFrameWithSpCallback(resName, startF, endF, spFrame, callback, endCallback, tag)
    elseif AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_SPINE then
        gafobj:setToSetupPose()
        gafobj:setAnimation(0, motionName, false)
        gafobj:registerSpineEventHandler(function(event)
            gafobj:registerSpineEventHandler(function() end, sp.EventType.ANIMATION_EVENT)
            if callback then
                callback(event)
            end
        end, sp.EventType.ANIMATION_EVENT)
        gafobj:registerSpineEventHandler(function()
            gafobj:registerSpineEventHandler(function() end, sp.EventType.ANIMATION_COMPLETE)
            if endCallback then
                endCallback()
            end
            if doClean then
                gafobj:performWithDelay(function()
                    AnimationMgr.removeGafObjectByTag(resName, tag)
                end, 0.1)
            end
        end, sp.EventType.ANIMATION_COMPLETE)
    end
    AnimationMgr.MotionTable[resName..tag]["curAniName"] = motionName
end

---取消之前设置的播放动画完成回调
--@param resName string 资源名称，例如:gaf动画"123.gaf"/spine动画"123.png"
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function AnimationMgr.cancelPlayAniCallback(resName, tag)
    tag = tag or ""
    local gafobj = AnimationMgr.AnimationObjTable[resName..tag]

    if AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_GAF then
        print("取消之前设置的播放动画完成回调，gaf动画暂不支持")
    elseif AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_SPINE then
        gafobj:registerSpineEventHandler(function() end, sp.EventType.ANIMATION_COMPLETE)
    end
end

---暂停播放gaf动画
--@param resName string 资源名称，例如:gaf动画"123.gaf"/spine动画"123.png"
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function AnimationMgr.pauseAni(resName, tag)
    tag = tag or ""
    local gafobj = AnimationMgr.AnimationObjTable[resName..tag]
    AnimationMgr.MotionTable[resName..tag]["curAniInfo"][4] = true
    if AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_GAF then
        gafobj:pauseAnimation()
        scheduler.unscheduleGlobal(AnimationMgr.SchedulerHandleTable[resName..tag])
    elseif AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_SPINE then
        gafobj:pause()
    end
end

---恢复播放gaf动画
--@param resName string 资源名称，例如:gaf动画"123.gaf"/spine动画"123.png"
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function AnimationMgr.resumeAni(resName, tag)
    tag = tag or ""
    local gafobj = AnimationMgr.AnimationObjTable[resName..tag]
    
    if AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_GAF then
        local curFrame = gafobj:getCurrentFrameIndex()
        local startF = AnimationMgr.MotionTable[resName..tag]["curAniInfo"][1]
        local endF = AnimationMgr.MotionTable[resName..tag]["curAniInfo"][2]
        local spFrame = AnimationMgr.MotionTable[resName..tag]["curAniInfo"][6]
        if curFrame > endF then
            curFrame = endF
        end
        local fps = gafobj:getFps()
        local delayTime = (1.00/fps)*(endF - 1 - curFrame)
        if delayTime < 0 then
            delayTime = 0
        end
        AnimationMgr.MotionTable[resName..tag]["curAniInfo"][4] = false
        gafobj:gotoAndPlay(curFrame)
        gafobj:start()
        if spFrame~=nil then
            local spDelayTime = (1.00/fps)*(spFrame - 1 - curFrame)
            if spDelayTime < 0 then
                spDelayTime = 0
            end
            AnimationMgr.SchedulerHandleTable[resName..tag] = scheduler.performWithDelayGlobal(function()
                local callback = AnimationMgr.MotionTable[resName..tag]["curAniInfo"][7]
                if callback~=nil then
                    callback()
                end
            end, spDelayTime) 
        end
        AnimationMgr.SchedulerHandleTable[resName..tag] = scheduler.performWithDelayGlobal(function()
            gafobj:stop()
            local isLoop = AnimationMgr.MotionTable[resName..tag]["curAniInfo"][3]
            if isLoop then
                AnimationMgr.playAniFrame(resName, startF, endF, isLoop, tag)
            end
            local callback = AnimationMgr.MotionTable[resName..tag]["curAniInfo"][5]
            if callback~=nil then
                callback()
            end
        end, delayTime) 
    elseif AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_SPINE then
        AnimationMgr.MotionTable[resName..tag]["curAniInfo"][4] = false
        gafobj:resume()
    end
end

---暂停或恢复播放动画
--@param resName string 资源名称，例如:gaf动画"123.gaf"/spine动画"123.png"
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function AnimationMgr.PauseOrResumeAni(resName, tag)
    tag = tag or ""
    local isPaused = AnimationMgr.MotionTable[resName..tag]["curAniInfo"][4]
    if isPaused then
        AnimationMgr.resumeAni(resName, tag)
    else
        AnimationMgr.pauseAni(resName, tag)
    end
end

---使用帧数区间播放gaf动画，一般情况下请勿外部调用
--@param resName string 资源名称，例如:gaf动画"123.gaf"/spine动画"123.png"
--@param startF int 起始帧
--@param endF int 结束帧
--@param isLoop bool 是否循环播放
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function AnimationMgr.playAniFrame(resName, startF, endF, isLoop, tag)
    tag = tag or ""
    local gafobj = AnimationMgr.AnimationObjTable[resName..tag]
    if gafobj == nil then
        print(resName..tag.."还没有被创建，无法播放动画")
    	return false
    end
    
    if AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_GAF then
        AnimationMgr.MotionTable[resName..tag]["curAniInfo"] = {startF, endF, isLoop, false}
        if gafobj:getIsAnimationRunning() then
            gafobj:stop()
        end
        if AnimationMgr.SchedulerHandleTable[resName..tag]~=nil then
            scheduler.unscheduleGlobal(AnimationMgr.SchedulerHandleTable[resName..tag])
        end
        gafobj:gotoAndPlay(startF-1)
        gafobj:start()
        local fps = gafobj:getFps()
        local delayTime = (1.00/fps)*(endF - startF)
        AnimationMgr.SchedulerHandleTable[resName..tag] = scheduler.performWithDelayGlobal(function()
            gafobj:stop()
            if isLoop then
                AnimationMgr.playAniFrame(resName, startF, endF, isLoop, tag)
            end
        end, delayTime)
        return true
    elseif AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_SPINE then
        print("spine动画不适用帧数区间播放")
        return true
    end
end

---使用帧数区间播放gaf动画并执行回调，一般情况下请勿外部调用
--@param resName string 资源名称，例如:gaf动画"123.gaf"/spine动画"123.png"
--@param startF int 起始帧
--@param endF int 结束帧
--@param callback function 回调函数
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function AnimationMgr.playAniFrameWithCallback(resName, startF, endF, callback, tag)
    tag = tag or ""
    local gafobj = AnimationMgr.AnimationObjTable[resName..tag]
    if gafobj == nil then
        print(resName..tag.."还没有被创建，无法播放动画")
        return false
    end
    
    if AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_GAF then
        AnimationMgr.MotionTable[resName..tag]["curAniInfo"] = {startF, endF, false, false, callback}
        if gafobj:getIsAnimationRunning() then
            gafobj:stop()
        end
        if AnimationMgr.SchedulerHandleTable[resName..tag]~=nil then
            scheduler.unscheduleGlobal(AnimationMgr.SchedulerHandleTable[resName..tag])
        end
        gafobj:gotoAndPlay(startF-1)
        gafobj:start()
        local fps = gafobj:getFps()
        local delayTime = (1.00/fps)*(endF - startF)
        AnimationMgr.SchedulerHandleTable[resName..tag] = scheduler.performWithDelayGlobal(function()
            gafobj:stop()
            if callback~=nil then
                callback()
            end
        end, delayTime)
        return true
    elseif AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_SPINE then
        print("spine动画不适用帧数区间播放")
        return true
    end
end

---使用帧数区间播放gaf动画并在特殊帧执行回调，一般情况下请勿外部调用
--@param resName string 资源名称，例如:gaf动画"123.gaf"/spine动画"123.png"
--@param startF int 起始帧
--@param endF int 结束帧
--@param spFrame int 特殊帧
--@param callback function 特殊帧的回调函数
--@param endCallback function 播放结束时的回调函数
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function AnimationMgr.playAniFrameWithSpCallback(resName, startF, endF, spFrame, callback, endCallback, tag)
    tag = tag or ""
    if spFrame == nil then
        print("特殊帧为空，此次播放无效")
        return false
    end
    local gafobj = AnimationMgr.AnimationObjTable[resName..tag]
    if gafobj == nil then
        print(resName..tag.."还没有被创建，无法播放动画")
        return false
    end
    
    if AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_GAF then
        AnimationMgr.MotionTable[resName..tag]["curAniInfo"] = {startF, endF, false, false, endCallback, spFrame, callback}
        if gafobj:getIsAnimationRunning() then
            gafobj:stop()
        end
        if AnimationMgr.SchedulerHandleTable[resName..tag]~=nil then
            scheduler.unscheduleGlobal(AnimationMgr.SchedulerHandleTable[resName..tag])
        end
        gafobj:gotoAndPlay(startF-1)
        gafobj:start()
        local fps = gafobj:getFps()
        local delayTime = (1.00/fps)*(endF - startF)
        local spDelayTime = (1.00/fps)*(spFrame - startF)
        AnimationMgr.SchedulerHandleTable[resName..tag] = scheduler.performWithDelayGlobal(function()
            if callback~=nil then
                callback()
            end
        end, spDelayTime)  
        AnimationMgr.SchedulerHandleTable[resName..tag] = scheduler.performWithDelayGlobal(function()
            gafobj:stop()
            if endCallback~=nil then
                endCallback()
            end
        end, delayTime)
        return true
    elseif AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_SPINE then
        print("spine动画不适用帧数区间播放")
        return true
    end
end

---设置动画的播放速度
--@param resName string 资源名称，例如:gaf动画"123.gaf"/spine动画"123.png"
--@param speedRate int 速度倍数，填写1即为原速，填写2即为2倍速
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function AnimationMgr.setSpeedRate(resName, speedRate, tag)
    tag = tag or ""
    local gafobj = AnimationMgr.AnimationObjTable[resName..tag]
    if AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_GAF then
        gafobj:setFps(24*speedRate)
        AnimationMgr.pauseAni(resName, tag)
        AnimationMgr.resumeAni(resName, tag)
    elseif AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_SPINE then
        gafobj:setTimeScale(speedRate)
    end
end

---设置动画皮肤，只支持spine动画
--@param resName string 资源名称，例如:spine动画"123.png"
--@param skinName string 皮肤名称（如果是宠物，不填则为0）
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function AnimationMgr.setSkin(resName, skinName, tag)
    tag = tag or ""
    local gafobj = AnimationMgr.AnimationObjTable[resName..tag]
    if AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_SPINE then
        if string.sub(resName, 1, 10)=="Spine/pet/" then
        	skinName = skinName or 0
        end
        if skinName then
            gafobj:setSkin(skinName)
            gafobj:setToSetupPose()
        end
    end
end

---战斗时创建动画，并返回这个node（spine动画此函数功能等同AnimationMgr.createAni）
-- 规定以960*640分辨率制定坐标
--@param scene node 动画的父节点，填nil则不加在任何节点上，后续自行add
--@param resName string 资源名称，例如:gaf动画"123.gaf"/spine动画"123.png" 
--@param posx int 横坐标位置，
--@param posy int 纵坐标位置
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function AnimationMgr.createBattlePetAni(scene, resName, posx, posy, tag) 
    tag = tag or ""
    local fileExist = cc.FileUtils:getInstance():isFileExist(resName)
    if fileExist == false then
        print(resName.."不存在，创建gaf动画失败")
        return nil
    end
    
    if AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_GAF then
        if AnimationMgr.AnimationObjTable[resName..tag]~=nil then
            print(resName..tag.."已存在，将删除它重新创建")
            local ret,errMessage = pcall(function()
                if AnimationMgr.SchedulerHandleTable[resName..tag]~=nil then
                    scheduler.unscheduleGlobal(AnimationMgr.SchedulerHandleTable[resName..tag])
                end
                transition.stopTarget(AnimationMgr.AnimationObjTable[resName..tag])
                AnimationMgr.AnimationObjTable[resName..tag]:removeAllChildren()
                AnimationMgr.AnimationObjTable[resName..tag]:removeFromParent(true)
                AnimationMgr.AnimationObjTable[resName..tag] = nil
            end)
            if ret==true then
                print(resName..tag.."删除成功")
            else
                print(resName..tag.."删除失败，可能是它的父节点已经被删除")
            end
        end
        local gafres = gaf.GAFAsset:create(resName)
        print("GAF INFO:" .. resName .. " width:" .. gafres:getSceneWidth() .. " height:" .. gafres:getSceneHeight())
        local gafobj = gafres:createObject()
        gafobj:setAnchorPoint(0.5, -0.82)   
        gafobj:setContentSize(AnimationMgr.DEFAULT_GAF_WIDTH, AnimationMgr.DEFAULT_GAF_HEIGHT)
        gafobj:setPosition(posx, posy)
        if scene then
            gafobj:addTo(scene)
        end
        AnimationMgr.AnimationObjTable[resName..tag] = gafobj
        AnimationMgr.MotionTable[resName..tag] = {}
        AnimationMgr.KeyFrameTable[resName..tag] = {}
        AnimationMgr.loadAniInfo(resName, tag)
        print("GAF OBJ INFO:" .. resName .. " width:" .. gafobj:getContentSize().width .. " height:" .. gafobj:getContentSize().height)
        return gafobj
    elseif AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_SPINE then
        return AnimationMgr.createAni(scene, resName, posx, posy, tag)
    end
    return nil
end

---创建动画，并返回这个node
-- 规定以960*640分辨率制定坐标
--@param scene node 动画的父节点，填nil则不加在任何节点上，后续自行add
--@param resName string 资源名称，例如:gaf动画"123.gaf"/spine动画"123.png"
--@param posx int 横坐标位置
--@param posy int 纵坐标位置
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function AnimationMgr.createAni(scene, resName, posx, posy, tag)
    tag = tag or ""
    local fileExist = cc.FileUtils:getInstance():isFileExist(resName)
    if fileExist == false then
        print(resName.."不存在，创建动画失败")
        return nil
    end
    
    if AnimationMgr.AnimationObjTable[resName..tag]~=nil then
        print(resName..tag.."已存在，将删除它重新创建")
        AnimationMgr.removeGafObjectByTag(resName..tag)
    end
    
    if AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_GAF then
        local gafres = gaf.GAFAsset:create(resName)
        print("GAF INFO:" .. resName .. " width:" .. gafres:getSceneWidth() .. " height:" .. gafres:getSceneHeight())
        local gafobj = gafres:createObject()
        gafobj:setAnchorPoint(0.5, 0.5)
        gafobj:setContentSize(AnimationMgr.DEFAULT_GAF_WIDTH, AnimationMgr.DEFAULT_GAF_HEIGHT)
        gafobj:setPosition(posx, posy)
        if scene then
            gafobj:addTo(scene)
        end
        AnimationMgr.AnimationObjTable[resName..tag] = gafobj
        AnimationMgr.MotionTable[resName..tag] = {}
        AnimationMgr.KeyFrameTable[resName..tag] = {}
        AnimationMgr.loadAniInfo(resName, tag)
        print("GAF OBJ INFO:" .. resName .. " width:" .. gafobj:getContentSize().width .. " height:" .. gafobj:getContentSize().height)
        gafobj.res = resName
        gafobj.tag = tag
        return gafobj
    elseif AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_SPINE then
        local resJson = string.gsub(resName, ".png", ".json")
        local resAtlas = string.gsub(resName, ".png", ".atlas")
        local resSkel = string.gsub(resName, ".png", ".skel")
        local boolJson = cc.FileUtils:getInstance():isFileExist(resJson)
        local boolSkel = cc.FileUtils:getInstance():isFileExist(resSkel)
        if (not boolJson and not boolSkel) or not cc.FileUtils:getInstance():isFileExist(resAtlas) then
            print(resJson.." or "..resSkel.." or "..resAtlas.."不存在，创建动画失败")
        	return nil
        end
        local resFile = resJson
        if boolSkel then
            resFile = resSkel
        end
        local spineObj = sp.SkeletonAnimation:create(resFile, resAtlas, 1)
        spineObj:setPosition(posx, posy)
        if scene then
            spineObj:addTo(scene)
        end
        AnimationMgr.AnimationObjTable[resName..tag] = spineObj
        AnimationMgr.MotionTable[resName..tag] = {}
        spineObj.res = resName
        spineObj.tag = tag
        return spineObj
    end
    return nil
end

---创建动画并且播放所有帧，并返回这个node（spine动画此函数功能等同AnimationMgr.createAni）
--@param scene node 动画的父节点，填nil则不加在任何节点上，后续自行add
--@param resName string 资源名称，例如:gaf动画"123.gaf"/spine动画"123.png"
--@param posx int 横坐标位置
--@param posy int 纵坐标位置
--@param isLoop bool 是否循环播放
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function AnimationMgr.createAniAndPlay(scene, resName, posx, posy, isLoop, tag)
    tag = tag or ""
    local fileExist = cc.FileUtils:getInstance():isFileExist(resName)
    if fileExist == false then
        print(resName.."不存在，创建动画失败")
        return nil
    end
    
    if AnimationMgr.AnimationObjTable[resName..tag]~=nil then
        print(resName..tag.."已存在，将删除它重新创建")
        local ret,errMessage = pcall(function()
            if AnimationMgr.SchedulerHandleTable[resName..tag]~=nil then
                scheduler.unscheduleGlobal(AnimationMgr.SchedulerHandleTable[resName..tag])
            end
            transition.stopTarget(AnimationMgr.AnimationObjTable[resName..tag])
            AnimationMgr.AnimationObjTable[resName..tag]:removeAllChildren()
            AnimationMgr.AnimationObjTable[resName..tag]:removeFromParent(true)
            AnimationMgr.AnimationObjTable[resName..tag] = nil
        end)
        if ret==true then
            print(resName..tag.."删除成功")
        else
            print(resName..tag.."删除失败，可能是它的父节点已经被删除")
        end
    end
    
    if AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_GAF then
        local gafres = gaf.GAFAsset:create(resName)
        print("GAF INFO:" .. resName .. " width:" .. gafres:getSceneWidth() .. " height:" .. gafres:getSceneHeight())
        local gafobj = gafres:createObjectAndRun(isLoop)
        gafobj:setAnchorPoint(0.5, 0.5)
        gafobj:setContentSize(AnimationMgr.DEFAULT_GAF_WIDTH, AnimationMgr.DEFAULT_GAF_HEIGHT)
        gafobj:setPosition(posx, posy)
        if scene then
            gafobj:addTo(scene)
        end
        AnimationMgr.AnimationObjTable[resName..tag] = gafobj
        gafobj.res = resName
        gafobj.tag = tag
        return gafobj
    elseif AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_SPINE then
        return AnimationMgr.createAni(scene, resName, posx, posy, tag)
    end
    return nil
end

---按资源名称判断动画类别
--@param resName string 资源名称，例如:gaf动画"123.gaf"/spine动画"123.png"
--@return #int 类别
function AnimationMgr.getAniType(resName)
    local type = string.sub(resName, -4, -1)
    if type==".gaf" then
        return AnimationMgr.ANI_TYPE_GAF
    elseif type==".png" then
        return AnimationMgr.ANI_TYPE_SPINE
    elseif type==".csb" then
        return AnimationMgr.ANI_TYPE_CSB
    end
    return AnimationMgr.ANI_TYPE_ERROR
end

---读取gaf动画配置
--@param resName string 资源名称，例如:gaf动画"123.gaf"/spine动画"123.png"
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function AnimationMgr.loadAniInfo(resName, tag)
    tag = tag or ""
    local filename = string.gsub(resName, ".gaf", ".xml")
    local fileExist = cc.FileUtils:getInstance():isFileExist(filename)
    if fileExist == false then
        print(filename.."不存在，将不能按动作名字播放动画")
    	return false
    end
    local filePath = cc.FileUtils:getInstance():fullPathForFilename(filename)
    local rfile = cc.FileUtils:getInstance():getStringFromFile(filePath)
    local stable = lua_string_split(string.gsub(rfile, "\r", ""), "\n")
    for tags,line in pairs(stable) do
        if line~="" then
            local info = lua_string_split(line, ":")
            local i = string.find(info[1],"KeyFrame")
            if i == nil then
                local frame = lua_string_split(info[2], ",")
                AnimationMgr.MotionTable[resName..tag][info[1]] = {frame[1], frame[2]}
            else
                AnimationMgr.KeyFrameTable[resName..tag][info[1]] = {info[2]}
            end
        end
    end
    return true
end

---删除单个动画
--@param resName string 资源名称，例如:gaf动画"123.gaf"/spine动画"123.png"
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function AnimationMgr.removeGafObjectByTag(resName, tag)
    tag = tag or ""
    local aniObj = AnimationMgr.AnimationObjTable[resName..tag]
    if aniObj~=nil then
        local function removeFunc()
            --print(resName..tag.."将被删除")
            local ret, errMessage = pcall(function()
                if AnimationMgr.SchedulerHandleTable[resName..tag]~=nil then
                    scheduler.unscheduleGlobal(AnimationMgr.SchedulerHandleTable[resName..tag])
                end
                transition.stopTarget(aniObj)
                aniObj:removeAllChildren()
                aniObj:removeFromParent(true)
            end)
            if ret==true then
                --print(resName..tag.."删除成功")
            else
                print(resName..tag.."删除失败，可能是它的父节点已经被删除")
            end
            AnimationMgr.AnimationObjTable[resName..tag] = nil
            AnimationMgr.SchedulerHandleTable[resName..tag] = nil
            AnimationMgr.MotionTable[resName..tag] = nil
        end
        if not aniObj.setInCaches then
            removeFunc()
        end
        --[[
        if AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_GAF then
            removeFunc()
        elseif AnimationMgr.getAniType(resName)==AnimationMgr.ANI_TYPE_SPINE then
            SceneMgr.getRunningScene:performWithDelay(function()
                removeFunc()
            end, 0.1)
        end
        --]]
    end
end

---删除所有动画，谨慎调用
function AnimationMgr.removeAllGafObjects()
    for tag, gafobj in pairs(AnimationMgr.AnimationObjTable) do
        AnimationMgr.removeGafObjectByTag(tag)
    end
    --[[
    AnimationMgr.AnimationObjTable = {}
    AnimationMgr.SchedulerHandleTable = {}
    AnimationMgr.MotionTable = {}
    ]]
end

-------------------------------------------------------  
-- 参数:待分割的字符串,分割字符  
-- 返回:子串表.(含有空串)  
function lua_string_split(str, split_char)
    if str==nil then
    	return {}
    end
    local sub_str_tab = {};  

    while (true) do          
        local pos = string.find(str, split_char);    
        if (not pos) then              
            local size_t = table.getn(sub_str_tab)  
            table.insert(sub_str_tab,size_t+1,str);  
            break;    
        end  

        local sub_str = string.sub(str, 1, pos - 1);                
        local size_t = table.getn(sub_str_tab)  
        table.insert(sub_str_tab,size_t+1,sub_str);  
        local t = string.len(str);  
        str = string.sub(str, pos + 1, t);     
    end      
    return sub_str_tab;
end 

return AnimationMgr