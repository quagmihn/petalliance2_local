local Animation3DMgr = {}

Animation3DMgr.AnimationObjTable = {}
Animation3DMgr.MotionTable = {}

function Animation3DMgr.Init()
    print("Animation3DMgr初始化")
    
    Animation3DMgr.AnimationObjTable = {}
    Animation3DMgr.MotionTable = {}
end

---创建3d动画，并返回这个node
-- 规定以960*640分辨率制定坐标
--@param scene node 动画的父节点
--@param resName string 资源名称
--@param posx int 横坐标位置
--@param posy int 纵坐标位置
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function Animation3DMgr.createAni(scene, resName, posx, posy, tag)
    tag = tag or ""
    local fileExist = cc.FileUtils:getInstance():isFileExist(resName)
    if fileExist == false then
        print(resName.."不存在，创建3d动画失败")
        return nil
    end
    if Animation3DMgr.AnimationObjTable[resName..tag]~=nil then
        print(resName..tag.."已存在，将删除它重新创建")
        local ret,errMessage = pcall(function()
            transition.stopTarget(Animation3DMgr.AnimationObjTable[resName..tag])
            Animation3DMgr.AnimationObjTable[resName..tag]:removeAllChildren()
            Animation3DMgr.AnimationObjTable[resName..tag]:removeFromParent(true)
            Animation3DMgr.AnimationObjTable[resName..tag] = nil
            Animation3DMgr.MotionTable[resName..tag] = nil
        end)
        if ret==true then
            print(resName..tag.."删除成功")
        else
            print(resName..tag.."删除失败，可能是它的父节点已经被删除")
        end
    end
    
    --添加动态模型
    local spt = cc.Sprite3D:create(resName)
    spt:setScale(1)
    spt:setPosition(posx, posy)
    scene:addChild(spt)

    --创建3D动画
--    local animation = cc.Animation3D:create(resName)
--    local animate = cc.Animate3D:create(animation)
--    Animation3DMgr.MotionTable[resName..tag] = animate
    
--    local ani1 = cc.ScaleTo:create(1, 1.2)
--    local ani2 = cc.ScaleTo:create(1, 0.8)
--    local seq = cc.Sequence:create(ani1, ani2)
--    spt:runAction(cc.RepeatForever:create(seq))
    
    Animation3DMgr.AnimationObjTable[resName..tag] = spt
    
    return spt
end

---创建3d动画并且播放所有帧，并返回这个node
--@param scene node 动画的父节点
--@param resName string 资源名称
--@param posx int 横坐标位置
--@param posy int 纵坐标位置
--@param isLoop bool 是否循环播放
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function Animation3DMgr.createAniAndPlay(scene, resName, posx, posy, isLoop, tag)
    tag = tag or ""
    local fileExist = cc.FileUtils:getInstance():isFileExist(resName)
    if fileExist == false then
        print(resName.."不存在，创建3d动画失败")
        return nil
    end
    if Animation3DMgr.AnimationObjTable[resName..tag]~=nil then
        print(resName..tag.."已存在，将删除它重新创建")
        local ret,errMessage = pcall(function()
            transition.stopTarget(Animation3DMgr.AnimationObjTable[resName..tag])
            Animation3DMgr.AnimationObjTable[resName..tag]:removeAllChildren()
            Animation3DMgr.AnimationObjTable[resName..tag]:removeFromParent(true)
            Animation3DMgr.AnimationObjTable[resName..tag] = nil
            Animation3DMgr.MotionTable[resName..tag] = nil
        end)
        if ret==true then
            print(resName..tag.."删除成功")
        else
            print(resName..tag.."删除失败，可能是它的父节点已经被删除")
        end
    end
    --添加动态模型
    local spt = cc.Sprite3D:create(resName)
    spt:setScale(1)
    spt:setPosition(posx, posy)
    scene:addChild(spt)

    --创建3D动画
    local animation = cc.Animation3D:create(resName)
    local animate = cc.Animate3D:create(animation)
    if isLoop then
        spt:runAction(cc.RepeatForever:create(animate))
    else
        spt:runAction(animate)
    end
    Animation3DMgr.MotionTable[resName..tag] = animate
    Animation3DMgr.AnimationObjTable[resName..tag] = spt
    
    return spt
end

---播放3d动画
--@param resName string 资源名称
--@param motionName string 动作名称（填在xml配置表中）
--@param isLoop bool 是否循环播放
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function Animation3DMgr.playAni(resName, motionName, isLoop, tag)
    tag = tag or ""
end

---删除单个3d动画
--@param resName string 资源名称
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function Animation3DMgr.removeObjectByTag(resName, tag)
    tag = tag or ""
    if Animation3DMgr.AnimationObjTable[resName..tag]~=nil then
        print(resName..tag.."将被删除")
        local ret,errMessage = pcall(function()
            transition.stopTarget(Animation3DMgr.AnimationObjTable[resName..tag])
            Animation3DMgr.AnimationObjTable[resName..tag]:removeAllChildren()
            Animation3DMgr.AnimationObjTable[resName..tag]:removeFromParent(true)
        end)
        if ret==true then
            print(resName..tag.."删除成功")
        else
            print(resName..tag.."删除失败，可能是它的父节点已经被删除")
        end
        Animation3DMgr.AnimationObjTable[resName..tag] = nil
        Animation3DMgr.MotionTable[resName..tag] = nil
    end
end

---删除所有3d动画，谨慎调用
function Animation3DMgr.removeAllObjects()
    for tag, gafobj in pairs(Animation3DMgr.AnimationObjTable) do
        if gafobj~=nil then
            print("remove 3d obj name:"..tag)
            local ret,errMessage = pcall(function()
                transition.stopTarget(gafobj)
                gafobj:removeAllChildrenWithCleanup(true)
                gafobj:removeFromParentWithCleanup(true)
            end)
            if ret==true then
                print(tag.."删除成功")
            else
                print(tag.."删除失败，可能是它的父节点已经被删除")
            end
        end
        Animation3DMgr.AnimationObjTable[tag] = nil
    end
    Animation3DMgr.AnimationObjTable = {}
    Animation3DMgr.MotionTable = {}
end

return Animation3DMgr