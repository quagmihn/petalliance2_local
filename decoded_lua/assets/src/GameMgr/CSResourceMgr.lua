local CSResourceMgr = {}

CSResourceMgr.LANG_FONT = {"cuyuan_GBK.ttf","cuyuan_GBK.ttf","cuyuan_GBK.ttf","cuyuan_GBK.ttf","th.ttf","vn.ttf"}

CSResourceMgr.DEFAULT_CSB_WIDTH = 0
CSResourceMgr.DEFAULT_CSB_HEIGHT = 0

CSResourceMgr.DEFAULT_LABEL_OUTLINE_BORDER = 2
CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS = {r=0,g=0,b=0,a=128}

CSResourceMgr.CSObjIndexedTable = {}
CSResourceMgr.CSObjTable = {}
CSResourceMgr.CSObjTimelineTable = {}
CSResourceMgr.CSNodeCachesTable = {}
CSResourceMgr.CSNodeTmpCachesTable = {}
CSResourceMgr.ButtonFuncTable = {}
CSResourceMgr.ButtonListenerTable = {}
CSResourceMgr.ParticleTable = {}

local CSObjIndex = 0
local scheduler = nil

---重新初始化CSResourceMgr，用于动态lua调试
function CSResourceMgr.Init()
    print("CSResourceMgr初始化")
    CSResourceMgr.CSObjIndexedTable = {}
    CSResourceMgr.CSObjTable = {}
    CSResourceMgr.CSObjTimelineTable = {}
    CSResourceMgr.CSNodeCachesTable = {}
    CSResourceMgr.CSNodeTmpCachesTable = {}
    CSResourceMgr.ButtonFuncTable = {}
    CSResourceMgr.ButtonListenerTable = {}
    CSResourceMgr.ParticleTable = {}
    
    if CONFIG_SCREEN_ORIENTATION=="portrait" then
        CSResourceMgr.DEFAULT_CSB_WIDTH = 640
        CSResourceMgr.DEFAULT_CSB_HEIGHT = 960
    else
        CSResourceMgr.DEFAULT_CSB_WIDTH = 960
        CSResourceMgr.DEFAULT_CSB_HEIGHT = 640
    end
    local size = cc.Director:getInstance():getOpenGLView():getViewPortRect()
    if CONFIG_SCREEN_AUTOSCALE=="FIXED_WIDTH" then
        local rate = size.height/(size.width/CONFIG_SCREEN_WIDTH*CONFIG_SCREEN_HEIGHT)
        CSResourceMgr.DEFAULT_CSB_HEIGHT = math.floor(CONFIG_SCREEN_HEIGHT*rate)
    else
        local rate = size.width/(size.height/CONFIG_SCREEN_HEIGHT*CONFIG_SCREEN_WIDTH)
        CSResourceMgr.DEFAULT_CSB_WIDTH = math.floor(CONFIG_SCREEN_WIDTH*rate)
    end
    
    scheduler = require("src.framework.scheduler")
end

---删除所有csb资源，谨慎调用
function CSResourceMgr.removeAllCSObjects()
    for var=1, #CSResourceMgr.CSObjIndexedTable do
        local tag = CSResourceMgr.CSObjIndexedTable[#CSResourceMgr.CSObjIndexedTable-var+1]
        CSResourceMgr.removeCSObjectByTag(tag)
    end
    --[[
    CSResourceMgr.CSObjTable = {}
    CSResourceMgr.CSObjTimelineTable = {}
    CSResourceMgr.CSNodeCachesTable = {}
    ]]
    CSResourceMgr.CSObjIndexedTable = {}
    CSResourceMgr.CSNodeTmpCachesTable = {}
    CSResourceMgr.ButtonFuncTable = {}
    CSResourceMgr.ButtonListenerTable = {}
end

---删除单个csb资源
--@param resName string 资源名称，例如:"123.csb"
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function CSResourceMgr.removeCSObjectByTag(resName, tag)
    tag = tag or ""
    local csobj = CSResourceMgr.CSObjTable[resName..tag]
    if csobj~=nil then
        local boolRemove = false
        if csobj.setInCaches then
            --print(resName..tag.."将被移出")
            local ret,errMessage = pcall(function()
                transition.stopTarget(csobj)
                csobj:removeFromParent(false)
            end)
            if ret==true then
                --print(resName..tag.."移出成功")
            else
                boolRemove = true
            end
        else
            --print(resName..tag.."将被删除")
            local ret,errMessage = pcall(function()
                transition.stopTarget(CSResourceMgr.CSObjTable[resName..tag])
                CSResourceMgr.CSObjTable[resName..tag]:removeAllChildren()
                CSResourceMgr.CSObjTable[resName..tag]:removeFromParent(true)
            end)
            if ret==true then
                --print(resName..tag.."删除成功")
            else
                print(resName..tag.."删除失败，可能是它的父节点已经被删除")
            end
            boolRemove = true
        end
        if boolRemove then
            CSResourceMgr.CSObjTable[resName..tag] = nil
            CSResourceMgr.CSObjTimelineTable[resName..tag] = nil
            CSResourceMgr.CSNodeCachesTable[resName..tag] = nil
        end
    end
end

---通过tag获取csbObject
--@param resName string 资源名称，例如:"123.csb"
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function CSResourceMgr.getCsbObj(resName, tag)
    tag = tag or ""
    local csbobj = CSResourceMgr.CSObjTable[resName..tag]
    if csbobj and csbobj.setInCaches then
        if not csbobj:getParent() then
    		return nil
    	end
    end
    return csbobj
end

---创建csb资源，并返回这个node
--（csb中的node尽量不要手动remove，不然使用getNodeByName和seekNodeByName找这个node会出错）
--@param scene node 资源的父节点
--@param resName string 资源名称，例如:"123.csb"
--@param tag string 标签名，重复创建同一个资源动画时用来区分。填"default"会自动给一个不重复的标签
--@param useCaches bool 是否写入缓存，永不删除。如果tag填"default"则失效
--@return #node 所创建的csb资源
function CSResourceMgr.createRes(scene, resName, tag, useCaches)
    tag = tag or ""
    local fileExist = cc.FileUtils:getInstance():isFileExist(resName)
    if fileExist == false then
        print(resName.."不存在，创建csb资源失败")
        return nil
    end
    local map = nil
    if tag=="default" then
        useCaches = false
    end
    if CSResourceMgr.CSObjTable[resName..tag] then
        map = CSResourceMgr.CSObjTable[resName..tag]
        local ret,errMessage = pcall(function()
            if map:getParent() then
                map:removeFromParent(false)
                --print(resName..tag.."已创建，将移至指定父节点下")
            end
            map:setVisible(true)
        end)
        if not ret==true then
            map = nil
        end
    end
    if not map then
        map = cc.CSLoader:createNode(resName)
        if not map then
            print(resName.."加载失败，CSLoader返回nil")
            return nil
        end
        if tag=="default" then
            tag = tostring(map)
        end
        if useCaches then
            map:retain()
            map.setInCaches = true
        else
            table.insert(CSResourceMgr.CSObjIndexedTable, resName..tag)
        end
        CSResourceMgr.CSObjTable[resName..tag] = map
        CSResourceMgr.CSNodeCachesTable[resName..tag] = {}
        map.res = resName
        map.tag = tag
    end
    if scene then
        map:addTo(scene, 1, tonumber(tag))
    end    
    return map
end

---设置csb资源坐标，并以多分辨率适配
-- 规定以640*960分辨率制定坐标
--@param resName string 资源名称，例如:"123.csb"
--@param posx int 横坐标
--@param posy int 纵坐标
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function CSResourceMgr.setRelativePosition(resName, posx, posy, tag)
    tag = tag or ""
    local csobj = CSResourceMgr.CSObjTable[resName..tag]
    if csobj == nil then
        print(resName..tag.."还没有被创建，请先使用createRes创建")
        return false
    end
    local size = cc.Director:getInstance():getOpenGLView():getViewPortRect()

    local rate = 1
    if CONFIG_SCREEN_AUTOSCALE=="FIXED_WIDTH" then
        rate = size.height/CSResourceMgr.DEFAULT_CSB_HEIGHT
    else
        rate = size.width/CSResourceMgr.DEFAULT_CSB_WIDTH
    end

    local ratex = posx/DEFAULT_GAME_SCREEN_WIDTH
    local ratey = posy/DEFAULT_GAME_SCREEN_HEIGHT
    local diffx = -size.x/rate
    local diffy = -size.y/rate
    local finalPosx = ratex*(CSResourceMgr.DEFAULT_CSB_WIDTH-diffx*2)+diffx
    local finalPosy = ratey*(CSResourceMgr.DEFAULT_CSB_HEIGHT-diffy*2)+diffy
    csobj:setAnchorPoint(0.5, 0.5)
    csobj:setPosition(finalPosx, finalPosy)
    --print("\nposx="..posx..",posy="..posy..",rate="..rate.."\nscreen rect:{"..size.x..","..size.y..","..size.width..","..size.height
    --    .."}\nratex="..ratex..",ratey="..ratey.." \nfinal pos:"..finalPosx..","..finalPosy
    --    .."\nGAME screen:"..DEFAULT_GAME_SCREEN_WIDTH..","..DEFAULT_GAME_SCREEN_HEIGHT)
end

---设置csb资源在各个分辨率下全屏显示，并显示全部内容
-- 规定以640*960分辨率制作底板(width_make=640, height_make=960)
function CSResourceMgr.setFullScreen(resName, tag)
    tag = tag or ""
    local csobj = CSResourceMgr.CSObjTable[resName..tag]
    if csobj == nil then
        print(resName..tag.."还没有被创建，请先使用createRes创建")
        return false
    end
    
    local width_make = DEFAULT_GAME_SCREEN_WIDTH
    local height_make = DEFAULT_GAME_SCREEN_HEIGHT
    
    CSResourceMgr.setRelativePosition(resName, DEFAULT_GAME_SCREEN_WIDTH/2, DEFAULT_GAME_SCREEN_HEIGHT/2, tag)
    local size = cc.Director:getInstance():getOpenGLView():getViewPortRect()
    local scrR = size.height/size.width
    local defR = height_make/width_make
    if scrR<defR then
        local rate = size.height*width_make/height_make/size.width
        csobj:setScale(rate)
    end
end

---获取屏幕尺寸类型(ipad false, others true)
function CSResourceMgr.getScreenType()
    local width_make = DEFAULT_GAME_SCREEN_WIDTH
    local height_make = DEFAULT_GAME_SCREEN_HEIGHT
    local size = cc.Director:getInstance():getOpenGLView():getViewPortRect()
    local scrR = size.height/size.width
    local defR = height_make/width_make
    if scrR<defR then
        return false
    end
    return true
end

function CSResourceMgr.setFrame(resName, frameidx, tag)
	tag = tag or ""
    local csobj = CSResourceMgr.CSObjTable[resName..tag]
    if csobj == nil then
        print(resName..tag.."还没有被创建，请先使用createRes创建")
        return false
    end
    local tlAct = cc.CSLoader:createTimeline(resName)
    csobj:runAction(tlAct)
    local mapAction = csobj:getActionByTag(tlAct:getTag())
    mapAction:gotoFrameAndPause(frameidx)
end

---播放csb动画的所有帧
--@param resName string 资源名称，例如:"123.csb"
--@param isLoop bool 是否循环播放
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function CSResourceMgr.playAllFrame(resName, isLoop, tag)
    tag = tag or ""
    local csobj = CSResourceMgr.CSObjTable[resName..tag]
    if csobj == nil then
        print(resName..tag.."还没有被创建，请先使用createRes创建")
        return false
    end
    local tlAct = cc.CSLoader:createTimeline(resName)
    csobj:runAction(tlAct)
    local mapAction = csobj:getActionByTag(tlAct:getTag())
    local frameNum = mapAction:getDuration()
    mapAction:gotoFrameAndPlay(0, frameNum, isLoop)
    mapAction:setTimeSpeed(1)
    CSResourceMgr.CSObjTimelineTable[resName..tag] = mapAction
end

---使用帧数区间播放csb动画
--@param resName string 资源名称，例如:"123.csb"
--@param startF int 起始帧
--@param endF int 结束帧
--@param isLoop bool 是否循环播放
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function CSResourceMgr.playAction(resName, startF, endF, isLoop, tag)
    tag = tag or ""
    local csobj = CSResourceMgr.CSObjTable[resName..tag]
    if csobj == nil then
        print(resName..tag.."还没有被创建，请先使用createRes创建")
        return false
    end
    local tlAct = cc.CSLoader:createTimeline(resName)
    if tlAct == nil then
        print(resName..tag.."还没有被创建，请先使用createRes创建")
        return false
    end
    csobj:runAction(tlAct)
    local mapAction = csobj:getActionByTag(tlAct:getTag())
    mapAction:gotoFrameAndPlay(startF, endF, isLoop)
    mapAction:setTimeSpeed(1)
    CSResourceMgr.CSObjTimelineTable[resName..tag] = mapAction
end

---播放csb动画的所有帧并执行回调
--@param resName string 资源名称，例如:"123.csb"
--@param speedRate int 速度倍数，填写1即为原速，填写2即为2倍速
--@param callback function 回调函数
--@param tag string 标签名，重复创建同一个资源动画时用来区分
--@param delaytime float 额外延迟时间
function CSResourceMgr.playAllFrameWithCallback(resName, speedRate, callback, tag, delaytime)
    tag = tag or ""
    delaytime = delaytime or 0
    local csobj = CSResourceMgr.CSObjTable[resName..tag]
    if csobj == nil then
        print(resName..tag.."还没有被创建，请先使用createRes创建")
        return false
    end
    local tlAct = cc.CSLoader:createTimeline(resName)
    csobj:runAction(tlAct)
    local mapAction = csobj:getActionByTag(tlAct:getTag())
    local frameNum = mapAction:getDuration()
    mapAction:gotoFrameAndPlay(0, frameNum, false)
    mapAction:setTimeSpeed(speedRate)
    local delayTime = 1.0/60*frameNum/speedRate+delaytime
    csobj:performWithDelay(function()
        if callback~=nil then
            callback()
        end
    end, delayTime)
    CSResourceMgr.CSObjTimelineTable[resName..tag] = mapAction
end

---使用帧数区间播放csb动画并执行回调
--@param resName string 资源名称，例如:"123.csb"
--@param startF int 起始帧
--@param endF int 结束帧
--@param speedRate int 速度倍数，填写1即为原速，填写2即为2倍速
--@param callback function 回调函数
--@param tag string 标签名，重复创建同一个资源动画时用来区分
--@param delaytime float 额外延迟时间
function CSResourceMgr.playActionWithCallback(resName, startF, endF, speedRate, callback, tag, delaytime)
    tag = tag or ""
    delaytime = delaytime or 0
    local csobj = CSResourceMgr.CSObjTable[resName..tag]
    if csobj == nil then
        print(resName..tag.."还没有被创建，请先使用createRes创建")
        return false
    end
    local tlAct = cc.CSLoader:createTimeline(resName)
    csobj:runAction(tlAct)
    local mapAction = csobj:getActionByTag(tlAct:getTag())
    mapAction:gotoFrameAndPlay(startF, endF, false)
    mapAction:setTimeSpeed(speedRate)
    --mapAction:setLastFrameCallFunc(callback)
    local delayTime = 1.0/60*(endF-startF)/speedRate+delaytime
    csobj:performWithDelay(function()
        if callback~=nil then
            callback()
        end
    end, delayTime)
    CSResourceMgr.CSObjTimelineTable[resName..tag] = mapAction
end

---设置csb动画播放速度
--@param resName string 资源名称，例如:"123.csb"
--@param speedRate int 速度倍数，填写1即为原速，填写2即为2倍速
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function CSResourceMgr.setSpeedRate(resName, speedRate, tag)
    tag = tag or ""
    local mapAction = CSResourceMgr.CSObjTimelineTable[resName..tag]
    if mapAction == nil then
        print(resName..tag.."的动画还没有被播放，请先播放")
        return false
    end
    mapAction:setTimeSpeed(speedRate)
end

---暂停播放csb动画
--@param resName string 资源名称，例如:"123.csb"
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function CSResourceMgr.pauseAction(resName, tag)
    tag = tag or ""
    local mapAction = CSResourceMgr.CSObjTimelineTable[resName..tag]
    if mapAction == nil then
        print(resName..tag.."的动画还没有被播放，请先播放")
        return false
    end
    CSResourceMgr.CSObjTimelineTable[resName..tag]:pause()
end

---恢复播放csb动画
--@param resName string 资源名称，例如:"123.csb"
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function CSResourceMgr.resumeAction(resName, tag)
    tag = tag or ""
    local mapAction = CSResourceMgr.CSObjTimelineTable[resName..tag]
    if mapAction == nil then
        print(resName..tag.."的动画还没有被播放，请先播放")
        return false
    end
    CSResourceMgr.CSObjTimelineTable[resName..tag]:resume()
end

---暂停或恢复播放csb动画
--@param resName string 资源名称，例如:"123.csb"
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function CSResourceMgr.PauseOrResumeAction(resName, tag)
    tag = tag or ""
    local mapAction = CSResourceMgr.CSObjTimelineTable[resName..tag]
    if mapAction == nil then
        print(resName..tag.."的动画还没有被播放，请先播放")
        return false
    end
    if CSResourceMgr.CSObjTimelineTable[resName..tag]:isPlaying() then
    	CSResourceMgr.CSObjTimelineTable[resName..tag]:pause()
    else
        CSResourceMgr.CSObjTimelineTable[resName..tag]:resume()
    end
end

---获取csb资源内的某个node
--@param resName string 资源名称，例如:"123.csb"
--@param cellName string/table/number node名称，在CocosStudio中填写的元件名称，多重节点可以如下传参数{"节点1","节点2","节点3"}
--注意：若cellName为多重节点，节点写完整效率较高，且有元件同名时不容易出错
--@param tag string 标签名，重复创建同一个资源动画时用来区分
--@return #node csb资源内的某个node
function CSResourceMgr.getNodeByName(resName, cellName, tag)
    tag = tag or ""
    local csobj = CSResourceMgr.CSObjTable[resName..tag]
    if csobj == nil then
        print(resName.." tag:"..tag.."资源未创建，获取node失败")
        return nil
    end
    local csnode = CSResourceMgr.CSNodeCachesTable[resName..tag][cellName]
    if csnode then
        return csnode
    end
    
    local node = nil
    if type(cellName)=="string" then
    	node = csobj:getChildByName(cellName)
        if node == nil then
            node = CSResourceMgr.seekNodeByName(csobj, cellName)
            if node == nil then
                print(resName.." "..tag.."的元件"..cellName.."找不到")
            end 
        end
    elseif type(cellName)=="table" then
        node = csobj
        for tags, name in pairs(cellName) do
            node = node:getChildByName(name)
            if node == nil then
                --准确查找找不到就不打Log了
                --print(resName.." "..tag.."的元件"..name.."找不到")
                break
            end 
        end
    elseif type(cellName)=="number" then
        node = csobj:getChildByTag(cellName)
        if node == nil then
            node = CSResourceMgr.seekNodeByTag(csobj, cellName)
            if node == nil then
                print(resName.." "..tag.."的元件"..cellName.."找不到")
            end 
        end
    end
    CSResourceMgr.CSNodeCachesTable[resName..tag][cellName] = node
    return node
end

---以tag搜索获取父节点下某个node
--@param parent node 父节点node
--@param tag number 元件tag
--@return #node csb资源内的某个node
function CSResourceMgr.seekNodeByTag(parent, tag)
    if not parent then
        return
    end

    local function setTable(node)
        local children = node:getChildren()
        for i=1, #children do
            local child = children[i]
            CSResourceMgr.CSNodeTmpCachesTable[parent][child:getTag()] = child
            setTable(child)
        end
    end

    local csnodeVec = CSResourceMgr.CSNodeTmpCachesTable[parent]
    if csnodeVec then
        if not csnodeVec[tag] then
            setTable(parent)
        end
    else
        CSResourceMgr.CSNodeTmpCachesTable[parent] = {}
        setTable(parent)
    end
    return CSResourceMgr.CSNodeTmpCachesTable[parent][tag]
end

---以名字搜索获取父节点下某个node
--@param parent node 父节点node
--@param name string node名称，在CocosStudio中填写的元件名称
--@return #node csb资源内的某个node
function CSResourceMgr.seekNodeByName(parent, name)
    if not parent then
        return
    end
    
    local function setTable(node)
        local children = node:getChildren()
        for i=1, #children do
            local child = children[i]
            CSResourceMgr.CSNodeTmpCachesTable[parent][child:getName()] = child
            setTable(child)
        end
    end
    
    local csnodeVec = CSResourceMgr.CSNodeTmpCachesTable[parent]
    if csnodeVec then
        if not csnodeVec[name] then
            setTable(parent)
        end
    else
        CSResourceMgr.CSNodeTmpCachesTable[parent] = {}
        setTable(parent)
    end
    return CSResourceMgr.CSNodeTmpCachesTable[parent][name]
end

---设置csb资源内Sprite或ImageView的贴图
--@param resName string 资源名称，例如:"123.csb"
--@param cellName string 精灵名称，在CocosStudio中填写的元件名称
--@param filename string 贴图文件的名字
--@param tag string 标签名，重复创建同一个资源动画时用来区分
--@param boolAsync bool 是否异步，不填默认使用
function CSResourceMgr.setSpriteTexture(resName, cellName, filename, tag, boolAsync)
    tag = tag or ""
    local Sprite = CSResourceMgr.getNodeByName(resName, cellName, tag)
    if Sprite==nil then
        print(resName.." "..tag.."的元件找不到，设置csb资源内Sprite的贴图失败")
        return false
    end
    CSResourceMgr.setSpriteTextureByNode(Sprite, filename, boolAsync)
end

---设置csb资源内Sprite或ImageView的贴图
--@param sprite node 精灵元件
--@param filename string 贴图文件的名字
--@param boolAsync bool 是否异步，不填默认使用
function CSResourceMgr.setSpriteTextureByNode(sprite, filename, boolAsync)
    if sprite==nil or filename==nil then
--        print("设置贴图失败")
        return false
    end
    local fileExist = cc.FileUtils:getInstance():isFileExist(filename)
    if fileExist == false then
        print(filename.."不存在，设置贴图失败")
        return false
    end
    if boolAsync==nil then
    	boolAsync = true

    end
    sprite.curTextureFilename = filename
    local function load()
        if sprite.setTexture then
            sprite:setTexture(filename)
        elseif sprite.loadTexture then
            sprite:loadTexture(filename)
        end
    end
    if boolAsync then
        display.addImageAsync(filename, function()
            if sprite and sprite.curTextureFilename==filename then
                load()
            end
        end)
    else
        load()
    end
end

---设置csb资源内Button的贴图
--@param resName string 资源名称，例如:"123.csb"
--@param cellName string 按钮名称，在CocosStudio中填写的元件名称
--@param filenameNormal string 一般时贴图文件的名字
--@param filenamePressed string 按中时贴图文件的名字
--@param filenameDisabled string 禁用时贴图文件的名字
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function CSResourceMgr.setButtonTexture(resName, cellName, filenameNormal, filenamePressed, filenameDisabled, tag)
    tag = tag or ""
    local Button = CSResourceMgr.getNodeByName(resName, cellName, tag)
    if Button==nil then
        print(resName.." "..tag.."的元件找不到，设置csb资源内Button的贴图失败")
        return false
    end
    CSResourceMgr.setButtonTextureByNode(Button, filenameNormal, filenamePressed, filenameDisabled)
end

---设置csb资源内Button的贴图
--@param button node 按钮元件
--@param filenameNormal string 一般时贴图文件的名字
--@param filenamePressed string 按中时贴图文件的名字
--@param filenameDisabled string 禁用时贴图文件的名字
function CSResourceMgr.setButtonTextureByNode(button, filenameNormal, filenamePressed, filenameDisabled)
    if button==nil then
        print("设置Button的贴图失败")
        return false
    end
    if filenameNormal and filenameNormal~="" then
        button:loadTextureNormal(filenameNormal)
    end
    if filenamePressed and filenamePressed~="" then
        button:loadTexturePressed(filenamePressed)
    end
    if filenameDisabled and filenameDisabled~="" then
        button:loadTextureDisabled(filenameDisabled)
    end
end

---设置csb资源内Label的文字颜色（csb资源内创建的Label实际为Text.lua的实例）
--@param resName string 资源名称，例如:"123.csb"
--@param cellName string 文本框名称，在CocosStudio中填写的元件名称
--@param color color 需要设置的文字颜色rgba
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function CSResourceMgr.setLabelColor(resName, cellName, color, tag)
    tag = tag or ""
    local Label = CSResourceMgr.getNodeByName(resName, cellName, tag)
    if Label==nil then
        print(resName.." "..tag.."的元件找不到，设置csb资源内Label的文字颜色失败")
        return false
    end
    CSResourceMgr.setLabelColorByNode(Label, color)
end

---设置csb资源内Label的文字颜色（csb资源内创建的Label实际为Text.lua的实例）
--@param label node 文本框元件
--@param color color 需要设置的文字颜色rgba
function CSResourceMgr.setLabelColorByNode(label, color)
    if label==nil then
        print("设置Label文字颜色失败")
        return false
    end
    label:setColor({r=255,g=255,b=255})
    label:setTextColor(color)
end

---设置csb资源内Label的文字（csb资源内创建的Label实际为Text.lua的实例）
--@param resName string 资源名称，例如:"123.csb"
--@param cellName string 文本框名称，在CocosStudio中填写的元件名称
--@param string string 需要设置的文字，【注意】：默认会去lang表找，不想找在字符串后面加个空格
--@param tag string 标签名，重复创建同一个资源动画时用来区分
--@param outlineColor color 描边颜色，为空则不描边，格式为{r=255,g=255,b=255,a=255,w=2,s=1}
--@param sharpenRate float 清晰度，范围0~1，0最模糊，1最清晰，填写-1可以不锐化。默认1
--@param singleLineWidth int 单行最大宽度，超过就进行宽度压缩（请勿私自改变scaleY）
function CSResourceMgr.setLabelString(resName, cellName, string, tag, outlineColor, sharpenRate, singleLineWidth)
    tag = tag or ""
    local Label = CSResourceMgr.getNodeByName(resName, cellName, tag)
    if Label==nil then
        print(resName.." "..tag.."的元件找不到，设置csb资源内Label的文字失败")
        return false
    end
    CSResourceMgr.setLabelStringByNode(Label, string, outlineColor, sharpenRate, singleLineWidth)
end

---设置csb资源内Label的文字（csb资源内创建的Label实际为Text.lua的实例）
--@param label node 文本框
--@param string string 需要设置的文字，【注意】：默认会去lang表找，不想找在字符串后面加个空格
--@param outlineColor color 描边颜色，为空则不描边，格式为{r=255,g=255,b=255,a=255,w=2,s=1}
--@param sharpenRate float 清晰度，范围0~1，0最模糊，1最清晰，填写-1可以不锐化。默认1
--@param singleLineWidth int 单行最大宽度，超过就进行宽度压缩（请勿私自改变scaleY）
function CSResourceMgr.setLabelStringByNode(label, string, outlineColor, sharpenRate, singleLineWidth)
    if label==nil then
        return false
    end
    label:setFontName(CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1])
    local sizeDiff = LuaSqlite.FONT_SIZE_DIFF[LuaSqlite.LANG_TYPE]
    if sizeDiff then
        if not label.isZoomOuted then
            label:setFontSize(label:getFontSize()-sizeDiff)
            label.isZoomOuted = sizeDiff
        elseif label.isZoomOuted~=sizeDiff then
            label:setFontSize(label:getFontSize()-sizeDiff+label.isZoomOuted)
            label.isZoomOuted = sizeDiff
        end
    else
        if label.isZoomOuted then
            label:setFontSize(label:getFontSize()+label.isZoomOuted)
            label.isZoomOuted = nil
        end
    end
    if outlineColor~=nil then
        label:disableEffect()
        label:enableOutline(outlineColor, outlineColor.w or CSResourceMgr.DEFAULT_LABEL_OUTLINE_BORDER)
        if outlineColor.s==1 then
            label:enableShadow()
        end
    end
    if string then
        label:setString(LuaSqlite.getLanguageByKey(string))
    end
    if not sharpenRate then
        CocosModuleMgr.sharpenLabel(label, 1, outlineColor)
    else
        CocosModuleMgr.sharpenLabel(label, sharpenRate, outlineColor)
    end
    if singleLineWidth then
        label:setScaleX(label:getScaleY())
        local width = label:getContentSize().width*label:getScaleX()
        if width>singleLineWidth then
            local scale = singleLineWidth/width
            label:setScaleX(scale*label:getScaleX())
        end
    end
end

---设置csb资源内Label的最大宽度，超过宽度就换行（csb资源内一般需要设置label的尺寸为自适应）
--@param resName string 资源名称，例如:"123.csb"
--@param cellName string 文本框名称，在CocosStudio中填写的元件名称
--@param width int 最大宽度
--@param tag string 标签名，重复创建同一个资源动画时用来区分
--@param sharpenRate float 清晰度，范围0~1，0最模糊，1最清晰，填写-1可以不锐化
function CSResourceMgr.setLabelMaxWidth(resName, cellName, width, tag, sharpenRate)
    tag = tag or ""
    local Label = CSResourceMgr.getNodeByName(resName, cellName, tag)
    if Label==nil then
        print(resName.." "..tag.."的元件找不到，设置csb资源内Label的最大宽度失败")
        return false
    end
    CSResourceMgr.setLabelMaxWidthByNode(Label, width, sharpenRate)
end

---设置csb资源内Label的最大宽度，超过宽度就换行（csb资源内一般需要设置label的尺寸为自适应）
--@param label node 文本框元件
--@param width int 最大宽度
--@param sharpenRate float 清晰度，范围0~1，0最模糊，1最清晰
function CSResourceMgr.setLabelMaxWidthByNode(label, width, sharpenRate)
    if label==nil then
        print("设置Label最大宽度失败")
        return false
    end
    local rate = label:getScaleX()
    label:setAnchorPoint(0.5, 1)
    if label:getContentSize().width*rate>width then
        label:ignoreContentAdaptWithSize(true)
        label:setTextAreaSize({width = width/rate, height = 0})
        label:ignoreContentAdaptWithSize(false)
        label:setTextAreaSize({width = width/rate, height = label:getContentSize().height})     
    end
    if not sharpenRate then
        CocosModuleMgr.sharpenLabel(label, 1)
    else
        CocosModuleMgr.sharpenLabel(label, sharpenRate)
    end
end

---设置csb资源内Button的文字
--@param resName string 资源名称，例如:"123.csb"
--@param cellName string 按钮名称，在CocosStudio中填写的元件名称
--@param string string 需要设置的文字，【注意】：默认会去lang表找，不想找在字符串后面加个空格
--@param tag string 标签名，重复创建同一个资源动画时用来区分
--@param outlineColor color 描边颜色，为空则不描边，格式为{r=255,g=255,b=255,a=255,w=2,s=1}
function CSResourceMgr.setButtonString(resName, cellName, string, tag, outlineColor)
    tag = tag or ""
    local Button = CSResourceMgr.getNodeByName(resName, cellName, tag)
    if Button==nil then
        print(resName.." "..tag.."的元件找不到，设置csb资源内Button的文字失败")
        return false
    end
    CSResourceMgr.setButtonStringByNode(Button, string, outlineColor)
end

---设置csb资源内Button的文字
--@param button node 按钮
--@param string string 需要设置的文字，【注意】：默认会去lang表找，不想找在字符串后面加个空格
--@param outlineColor color 描边颜色，为空则不描边，格式为{r=255,g=255,b=255,a=255,w=2,s=1}
function CSResourceMgr.setButtonStringByNode(button, string, outlineColor)
    if button==nil then
        return false
    end
    local Label = button:getTitleRenderer()
    Label:setTTFConfig({fontFilePath = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
   	    fontSize = button:getTitleFontSize(), glyphs = "DYNAMIC"})
    local sizeDiff = LuaSqlite.FONT_SIZE_DIFF[LuaSqlite.LANG_TYPE]
    if sizeDiff then
        if not button.isZoomOuted then
            button:setTitleFontSize(button:getTitleFontSize()-sizeDiff)
            button.isZoomOuted = sizeDiff
        elseif button.isZoomOuted~=sizeDiff then
            button:setTitleFontSize(button:getTitleFontSize()-sizeDiff+button.isZoomOuted)
            button.isZoomOuted = sizeDiff
        end
    else
        if button.isZoomOuted then
            button:setTitleFontSize(button:getTitleFontSize()+button.isZoomOuted)
            button.isZoomOuted = nil
        end
    end
    
    if outlineColor~=nil then
        Label:disableEffect()
        Label:enableOutline(outlineColor, outlineColor.w or CSResourceMgr.DEFAULT_LABEL_OUTLINE_BORDER)
        if outlineColor.s==1 then
            Label:enableShadow()
        end
    end
    
    button:setUnifySizeEnabled(false)
    button:setScale9Enabled(true)
    button:ignoreContentAdaptWithSize(false)
    if string then
        button:setTitleText(LuaSqlite.getLanguageByKey(string))
    end
    
    Label:setScaleX(Label:getScaleY())
    local width = Label:getContentSize().width*Label:getScaleX()*1.2
    local size = button:getContentSize()
    if width>size.width then
        local scale = size.width/width
        Label:setScaleX(scale*Label:getScaleX())
    end
end

---获取csb资源内Button的文字
--@param resName string 资源名称，例如:"123.csb"
--@param cellName string 按钮名称，在CocosStudio中填写的元件名称
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function CSResourceMgr.getButtonString(resName, cellName, tag)
    tag = tag or ""
    local Button = CSResourceMgr.getNodeByName(resName, cellName, tag)
    if Button==nil then
        print(resName.." "..tag.."的元件找不到，获取csb资源内Button的文字失败")
        return ""
    end
    return CSResourceMgr.getButtonStringByNode(Button)
end

---获取csb资源内Button的文字
--@param button node 按钮
function CSResourceMgr.getButtonStringByNode(button)
    if button==nil then
        return ""
    end
    return button:getTitleText()
end

---设置csb资源内Button的文字颜色
--@param resName string 资源名称，例如:"123.csb"
--@param cellName string 按钮名称，在CocosStudio中填写的元件名称
--@param color color 颜色，格式为{r=255,g=255,b=255,a=255}
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function CSResourceMgr.setButtonStringColor(resName, cellName, color, tag)
    tag = tag or ""
    local Button = CSResourceMgr.getNodeByName(resName, cellName, tag)
    if Button==nil then
        print(resName.." "..tag.."的元件找不到，设置csb资源内Button的文字失败")
        return false
    end
    CSResourceMgr.setButtonStringColorByNode(Button, color)
end

---设置csb资源内Button的文字颜色
--@param button node 按钮
--@param color color 颜色，格式为{r=255,g=255,b=255,a=255}
function CSResourceMgr.setButtonStringColorByNode(button, color)
    if button==nil then
        return false
    end
    local Label = button:getTitleRenderer()
    if color~=nil then
        Label:setTextColor(color)
    end
end

---设置csb资源内Button的文字大小
--@param resName string 资源名称，例如:"123.csb"
--@param cellName string 按钮名称，在CocosStudio中填写的元件名称
--@param size int 字体大小
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function CSResourceMgr.setButtonStringSize(resName, cellName, size, tag)
    tag = tag or ""
    local Button = CSResourceMgr.getNodeByName(resName, cellName, tag)
    if Button==nil then
        print(resName.." "..tag.."的元件找不到，设置csb资源内Button的文字失败")
        return false
    end
    CSResourceMgr.setButtonStringSizeByNode(Button, size)
end

---设置csb资源内Button的文字颜色
--@param button node 按钮
--@param size int 字体大小
function CSResourceMgr.setButtonStringSizeByNode(button, size)
    if button==nil then
        return false
    end
    local Label = button:getTitleRenderer()
    if size~=nil then
        Label:setFontSize(size)
    end
end

---设置csb资源内Button是否可以点击
--@param resName string 资源名称，例如:"123.csb"
--@param cellName string 按钮名称，在CocosStudio中填写的元件名称
--@param boolEnable bool 是否可以点击
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function CSResourceMgr.setButtonEnabled(resName, cellName, boolEnable, tag)
    tag = tag or ""
    local Button = CSResourceMgr.getNodeByName(resName, cellName, tag)
    if Button==nil then
        print(resName.." "..tag.."的元件找不到，设置button是否可点击失败")
        return false
    end
    CSResourceMgr.setButtonEnabledByNode(Button, boolEnable)
end

---设置csb资源内Button是否可以点击
--@param button node 按钮
--@param boolEnable bool 是否可以点击
function CSResourceMgr.setButtonEnabledByNode(button, boolEnable)
    if button==nil then
        return false
    end
    button:setTouchEnabled(boolEnable)
    button:setBright(boolEnable)
end

---绑定csb资源内按钮的点击事件
--@param resName string 资源名称，例如:"123.csb"
--@param cellName string 按钮名称，在CocosStudio中填写的元件名称
--@param callback function 点击按钮时执行的函数
--@param tag string 标签名，重复创建同一个资源动画时用来区分
--@param clickEffectType int 开启点击效果（1点击按钮放大/2点击按钮下偏/3小按钮果冻效果）
--@param clickSound string 点击音效key
function CSResourceMgr.clickEventBinding(resName, cellName, callback, tag, clickEffectType, clickSound)
    tag = tag or ""
    local Button = CSResourceMgr.getNodeByName(resName, cellName, tag)
    if Button==nil then
        print(resName.." "..tag.."的元件找不到，设置按钮事件失败")
        return false
    end
    CSResourceMgr.clickEventBindingByNode(Button, callback, clickEffectType, clickSound)
end

---绑定csb资源内按钮的点击事件
--@param button node 按钮
--@param callback function 点击按钮时执行的函数
--@param clickEffectType int 开启点击效果（1点击按钮放大/2点击按钮下偏/3小按钮果冻效果）
--@param clickSound string 点击音效key
function CSResourceMgr.clickEventBindingByNode(button, callback, clickEffectType, clickSound)
    if button==nil then
        return false
    end

    --此段代码用来记录按钮动画的原始变量
    button.originX,button.originY = button:getPosition()
    button.originScaleX = button:getScaleX() 
    button.originScaleY = button:getScaleY()
    button.originSize = button:getContentSize()
    
    if callback~=CSResourceMgr.ButtonFuncTable[button] then
        CSResourceMgr.ButtonFuncTable[button] = callback
    end
    button.clickType = clickEffectType
    local posy = button:getPositionY()
    button:addTouchEventListener(function(sender, state)
        if TOUCH_PIPELINE_DIAGNOSTICS then
            local name = sender.name or (sender.getName and sender:getName()) or tostring(sender)
            local zOrder = sender.getLocalZOrder and sender:getLocalZOrder() or "?"
            local enabled = sender.isTouchEnabled and tostring(sender:isTouchEnabled()) or "?"
            print(string.format("[TOUCH_DIAG] button_state node=%s state=%s z=%s enabled=%s scene=%s",
                tostring(name), tostring(state), tostring(zOrder), tostring(enabled), tostring(SceneMgr.currentScene)))
        end
        if state == 3 then
            if clickEffectType==2 then
                sender:setPositionY(posy)
            end
            if clickEffectType==3 then
                local function zoom2(offset,time,onComplete)
                    local x, y = sender:getPosition()                
                    local scaleX = sender.originScaleX * (sender.originSize.width -offset) / sender.originSize.width
                    local scaleY = sender.originScaleY * (sender.originSize.height +offset) / sender.originSize.height
                    transition.moveTo(sender, {y = y + offset/2, time = time})    
                    transition.scaleTo(sender, {
                        scaleX     = scaleX,
                        scaleY     = scaleY,
                        time       = time,
                        onComplete = onComplete,
                    })
                end
                local function zoom3(offset, time, onComplete)
                    local x, y = sender:getPosition()
                    transition.scaleTo(sender, {
                        scaleX     = sender.originScaleX,
                        scaleY     = sender.originScaleY,
                        time       = time,
                        onComplete = onComplete,
                    })
                end
                local realoffset = 0.13*sender.originSize.width
                zoom2(realoffset, 0.08, function()
                    zoom3(realoffset, 0.1, function()
                    end)
                end)
            end
        elseif state == 2 then
            if TOUCH_PIPELINE_DIAGNOSTICS then
                print(string.format("[TOUCH_DIAG] button_callback_enter node=%s", tostring(sender.name or sender)))
            end
            callback(sender)
            if TOUCH_PIPELINE_DIAGNOSTICS then
                print(string.format("[TOUCH_DIAG] button_callback_exit node=%s", tostring(sender.name or sender)))
            end
            if CSResourceMgr.ButtonListenerTable[button] then
            	local tmpFunc = CSResourceMgr.ButtonListenerTable[button]
            	CSResourceMgr.ButtonListenerTable[button] = nil
            	tmpFunc()
            end
            if clickEffectType==2 then
                sender:setPositionY(posy)
            end
            if clickEffectType==3 then
                local function zoom2(offset,time,onComplete)
                    local x, y = sender:getPosition()                
                    local scaleX = sender.originScaleX * (sender.originSize.width -offset) / sender.originSize.width
                    local scaleY = sender.originScaleY * (sender.originSize.height +offset) / sender.originSize.height
                    transition.moveTo(sender, {y = y + offset/2, time = time})    
                    transition.scaleTo(sender, {
                        scaleX     = scaleX,
                        scaleY     = scaleY,
                        time       = time,
                        onComplete = onComplete,
                    })
                end
                local function zoom3(offset, time, onComplete)
                    local x, y = sender:getPosition()
                    transition.scaleTo(sender, {
                        scaleX     = sender.originScaleX,
                        scaleY     = sender.originScaleY,
                        time       = time,
                        onComplete = onComplete,
                    })
                end
                local realoffset = 0.13*sender.originSize.width
                zoom2(realoffset, 0.08, function()
                    zoom3(realoffset, 0.1, function()
                    end)
                end)
            end
            if clickSound then
                GameAudio.playUISound(clickSound)
            else
                if clickEffectType == 3 then
                    GameAudio.playUISound("select2")
                else
                    GameAudio.playSound(GameAudio.DEFAULT_BUTTON_SOUND)
                end
            end
        elseif state == 0 then
            if clickEffectType==2 then
                sender:setPositionY(posy-5)
            end
            if clickEffectType == 3 then
                --先恢复原来的位置和缩放
                sender:setScale(sender.originScaleX,sender.originScaleY)
                sender:setPosition(sender.originX,sender.originY)
                --然后开始执行动画1
                local function zoom1(offset, time,onComplete)
                    local x, y = sender:getPosition()
                    local scaleX = sender.originScaleX * (sender.originSize.width + offset) / sender.originSize.width
                    local scaleY = sender.originScaleY * (sender.originSize.height - offset) / sender.originSize.height
                    transition.moveTo(sender, {y = y - offset/2, time = time})
                    transition.scaleTo(sender, {
                        scaleX     = scaleX,
                        scaleY     = scaleY,
                        time       = time,
                        onComplete = onComplete,
                    })
                end
                local realoffset = 0.13*sender.originSize.width
                zoom1(realoffset,0.06,function() end)
            end
        end
    end)
    if clickEffectType==1 or clickEffectType==true then
        button:setPressedActionEnabled(true)
    end
end

---绑定csb资源内按钮的触摸事件
--@param resName string 资源名称，例如:"123.csb"
--@param cellName string 按钮名称，在CocosStudio中填写的元件名称
--@param callback function 碰触按钮时执行的函数（手指或鼠标未松开即执行）
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function CSResourceMgr.touchEventBinding(resName, cellName, callback, tag)
    tag = tag or ""
    local Button = CSResourceMgr.getNodeByName(resName, cellName, tag)
    if Button==nil then
        print(resName.." "..tag.."的元件找不到，设置按钮事件失败")
        return false
    end
    CSResourceMgr.touchEventBindingByNode(Button, callback)
end

---绑定csb资源内按钮的触摸事件
--@param button node 按钮
--@param callback function 碰触按钮时执行的函数（手指或鼠标未松开即执行）
function CSResourceMgr.touchEventBindingByNode(button, callback)
    if button==nil then
        return false
    end
    button:addTouchEventListener(function(sender, state)
        if state == 0 then
            callback(sender)
        end
    end)
end

---绑定csb资源内按钮的拖拽事件
--@param resName string 资源名称，例如:"123.csb"
--@param cellName string 按钮名称，在CocosStudio中填写的元件名称
--@param callback function 拖拽按钮时执行的函数（拖拽时会一直执行）
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function CSResourceMgr.dragEventBinding(resName, cellName, callback, tag)
    tag = tag or ""
    local Button = CSResourceMgr.getNodeByName(resName, cellName, tag)
    if Button==nil then
        print(resName.." "..tag.."的元件找不到，设置按钮事件失败")
        return false
    end
    CSResourceMgr.dragEventBindingByNode(Button, callback)
end

---绑定csb资源内按钮的拖拽事件
--@param button node 按钮
--@param callback function 拖拽按钮时执行的函数（拖拽时会一直执行）
function CSResourceMgr.dragEventBindingByNode(button, callback)
    if button==nil then
        return false
    end
    button:addTouchEventListener(function(sender, state)
        if state == 1 then
            callback(sender)
        end
    end)
end

---绑定csb资源内按钮的长按事件
--@param resName string 资源名称，例如:"123.csb"
--@param cellName string 按钮名称，在CocosStudio中填写的元件名称
--@param langtouchFunc function 长按事件
--@param clickFunc function 点击事件
--@param tag string 标签名，重复创建同一个资源动画时用来区分
--@param clickSound string 点击音效key
function CSResourceMgr.longtouchEventBinding(resName, cellName, langtouchFunc, clickFunc, tag, clickSound)
    tag = tag or ""
    local Button = CSResourceMgr.getNodeByName(resName, cellName, tag)
    if Button==nil then
        print(resName.." "..tag.."的元件找不到，设置按钮事件失败")
        return false
    end
    CSResourceMgr.longtouchEventBindingByNode(Button, langtouchFunc, clickFunc, clickSound)
end

---绑定csb资源内按钮的长按事件
--@param button node 按钮
--@param langtouchFunc function 长按事件
--@param clickFunc function 点击事件
--@param clickSound string 点击音效key
function CSResourceMgr.longtouchEventBindingByNode(button, langtouchFunc, clickFunc, clickSound)
    if button==nil then
        return false
    end
    button:addTouchEventListener(function(sender, state)
        if state == 3 then
            button.longTouch = false
            transition.stopTarget(button)
        elseif state == 2 then
            if button.longTouch~=true then
                if clickFunc then
                    clickFunc(sender)
                end
                if clickSound then
                    GameAudio.playUISound(clickSound)
                else
                    GameAudio.playSound(GameAudio.DEFAULT_BUTTON_SOUND)
                end
            end
            button.longTouch = false
            transition.stopTarget(button)
        elseif state == 0 then
            button:performWithDelay(function()
                if langtouchFunc then
                    langtouchFunc(sender)
                    button.longTouch = true
                end
            end, 0.5)
        end
    end)
end

---绑定csb资源内的按钮事件
--@param resName string 资源名称，例如:"123.csb"
--@param cellName string 按钮名称，在CocosStudio中填写的元件名称
--@param touchFunc function 触摸按钮时执行的函数
--@param clickFunc function 点击按钮时执行的函数
--@param dragFunc function 拖动按钮时执行的函数
--@param cancelFunc function 取消按钮时执行的函数
--@param tag string 标签名，重复创建同一个资源动画时用来区分
--@param boolClickEffect bool 是否开启点击效果（常态和点击态相同的按钮建议开启）
--@param clickSound string 点击音效key
function CSResourceMgr.buttonEventBinding(resName, cellName, touchFunc, clickFunc, dragFunc, cancelFunc, tag, boolClickEffect, clickSound)
    tag = tag or ""
    local Button = CSResourceMgr.getNodeByName(resName, cellName, tag)
    if Button==nil then
        print(resName.." "..tag.."的元件找不到，设置按钮事件失败")
        return false
    end
    CSResourceMgr.buttonEventBindingByNode(Button, touchFunc, clickFunc, dragFunc, cancelFunc, boolClickEffect, clickSound)
end

---绑定csb资源内的按钮事件
--@param button node 按钮
--@param touchFunc function 触摸按钮时执行的函数
--@param clickFunc function 点击按钮时执行的函数
--@param dragFunc function 拖动按钮时执行的函数
--@param cancelFunc function 取消按钮时执行的函数
--@param boolClickEffect bool 是否开启点击效果（常态和点击态相同的按钮建议开启）
--@param clickSound string 点击音效key
function CSResourceMgr.buttonEventBindingByNode(button, touchFunc, clickFunc, dragFunc, cancelFunc, boolClickEffect, clickSound)
    if button==nil then
        return false
    end
    CSResourceMgr.ButtonFuncTable[button] = clickFunc
    button:addTouchEventListener(function(sender, state)
        if state == 3 then
            if cancelFunc then
                cancelFunc(sender)
            end
        elseif state == 2 then
            if clickFunc then
                clickFunc(sender)
            end
            if CSResourceMgr.ButtonListenerTable[button] then
                local tmpFunc = CSResourceMgr.ButtonListenerTable[button]
                CSResourceMgr.ButtonListenerTable[button] = nil
                tmpFunc()
            end
            if clickSound then
                GameAudio.playUISound(clickSound)
            else
                GameAudio.playSound(GameAudio.DEFAULT_BUTTON_SOUND)
            end
        elseif state == 1 then
            if dragFunc then
                dragFunc(sender)
            end
        elseif state == 0 then
            if touchFunc then
                touchFunc(sender)
            end
        end
    end)
    if boolClickEffect==true then
        button:setPressedActionEnabled(true)
    end
end

function CSResourceMgr.buttonEventBindingByNodeXP(button, touchFunc, clickFunc, dragFunc, cancelFunc, boolClickEffect, clickSound, longTouchFunc)
    if button==nil then
        return false
    end
    CSResourceMgr.ButtonFuncTable[button] = clickFunc
    button:addTouchEventListener(function(sender, state)
        if state == 3 then
            button.longTouch = false
            if cancelFunc then
                cancelFunc(sender)
                if button.longHandle then
                    button:stopAction(button.longHandle)
                    button.longHandle = nil
                end
            end
        elseif state == 2 then
            if cancelFunc then
                cancelFunc(sender)
                if button.longHandle then
                    button:stopAction(button.longHandle)
                    button.longHandle = nil
                end
            end
            if button.longTouch and clickFunc then
                clickFunc(sender)
            end
            button.longTouch = false
            if CSResourceMgr.ButtonListenerTable[button] then
                local tmpFunc = CSResourceMgr.ButtonListenerTable[button]
                CSResourceMgr.ButtonListenerTable[button] = nil
                tmpFunc()
            end
            if clickSound then
                GameAudio.playUISound(clickSound)
            else
                GameAudio.playSound(GameAudio.DEFAULT_BUTTON_SOUND)
            end
        elseif state == 1 then
            if dragFunc then
                dragFunc(sender)
            end
        elseif state == 0 then
            button.longHandle = nil
            if touchFunc then
                touchFunc(sender)
            end
            button.longTouch = true
            button.longHandle = button:performWithDelay(function()
                if button.longTouch and longTouchFunc then
                    longTouchFunc(sender)
                    button.longTouch = false
                end
            end, 0.5)
        end
    end)
    if boolClickEffect==true then
        button:setPressedActionEnabled(true)
    end
end

---手动调用触发按钮所注册的事件（暂时只支持点击事件）
--@param resName string 资源名称，例如:"123.csb"
--@param cellName string 按钮名称，在CocosStudio中填写的元件名称
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function CSResourceMgr.callButtonFunc(resName, cellName, tag)
    tag = tag or ""
    local node = CSResourceMgr.getNodeByName(resName, cellName, tag)
    if node==nil then
        print(resName.." "..tag.."的元件找不到，触发按钮事件失败")
        return false
    end
    if CSResourceMgr.ButtonFuncTable[node]~=nil then
        CSResourceMgr.ButtonFuncTable[node]()
        if CSResourceMgr.ButtonListenerTable[node] then
            CSResourceMgr.ButtonListenerTable[node]()
            CSResourceMgr.ButtonListenerTable[node] = nil
        end
	end
end

---额外添加按钮点击事件回调，只执行一次
--@param button node 按钮
--@param callback function 回调方法
function CSResourceMgr.addButtonListener(button, callback)
    if not button then
    	return
    end
    if not CSResourceMgr.ButtonFuncTable[button] then
    	CSResourceMgr.clickEventBindingByNode(button, function() end)
    end
    CSResourceMgr.ButtonListenerTable[button] = callback
end

---设置通用滑动列表信息，并支持上拉刷新/下拉加载
--csb内元件命名规则：
--列表拖动提示label命名dragtip，子元件箭头命名dir
--列表加载提示label命名loadtip，子元件菊花圈命名hud
--@param contentTable table 列表内容
--@param resName string csb资源名
--@param listName string list元件名字
--@param resNameTag string tag名，默认为空
--@param showSize int 单次加载项数，默认为10
--@param sensor int 顶部和底部拉扯灵敏度，默认为1
--@param loadItemFunc function 加载项回调函数带参数id和var包含列表单项内容信息，请返回列表单项元素node
--@param refreshItemFunc function 请求刷新列表函数，带参数callback请完成后调用
--@param requestItemFunc function 请求加载更多函数，带参数callback请完成后调用
--@return #table 返回内容object，常用方法如下
--object.getContent()
--object.setContent()
--object.refreshFinished()
--object.requestFinished()
function CSResourceMgr.setCommonListInfo(contentTable, resName, listName, resNameTag, showSize, sensor, loadItemFunc, refreshItemFunc, requestItemFunc)
    local object = require("src.GameMgr.Support.CommonList").new({
        resName = resName,
        listName = listName,
        contentTable = contentTable,
        resNameTag = resNameTag,
        showSize = showSize,
        sensor = sensor,
        loadItemFunc = loadItemFunc,
        refreshItemFunc = refreshItemFunc,
        requestItemFunc = requestItemFunc
    })
    return object
end

---优化删除列表元素
--@param resName string csb资源名
--@param listName string list元件名字
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function CSResourceMgr.removeList(resName, listName, tag)
    tag = tag or ""
    local node = CSResourceMgr.getNodeByName(resName, listName, tag)
    if node==nil then
        print(resName.." "..tag.."的元件找不到，优化删除列表元素失败")
        return false
    end
    CSResourceMgr.removeListByNode(node)
end

---优化删除列表元素
--@param listObj node list控件对象
function CSResourceMgr.removeListByNode(listObj)
    if listObj==nil then
        return false
    end
    local vec = listObj:getItems()
    local newVec = {}
    for key, var in pairs(vec) do
        var:removeFromParent(false)
        var:retain()
        var:setVisible(false)
        table.insert(newVec, var)
    end
    listObj:removeAllItems()
    local function releaseFunc()
        if newVec[1] then
            newVec[1]:release()
            table.remove(newVec, 1)
            scheduler.performWithDelayGlobal(function()
                releaseFunc()
            end, 1)
        end
    end
    releaseFunc()
end

---优化删除翻页容器元素
--@param resName string csb资源名
--@param pageViewName string pageview元件名字
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function CSResourceMgr.removePage(resName, pageViewName, tag)
    tag = tag or ""
    local node = CSResourceMgr.getNodeByName(resName, pageViewName, tag)
    if node==nil then
        print(resName.." "..tag.."的元件找不到，优化删除翻页容器元素失败")
        return false
    end
    CSResourceMgr.removePageByNode(node)
end

---优化删除翻页容器元素
--@param pageViewObj node pageview控件对象
function CSResourceMgr.removePageByNode(pageViewObj)
    if pageViewObj==nil then
        return false
    end
    local vec = pageViewObj:getPages()
    local newVec = {}
    for key, var in pairs(vec) do
        var:removeFromParent(false)
        var:retain()
        var:setVisible(false)
        table.insert(newVec, var)
    end
    pageViewObj:removeAllPages()
    local function releaseFunc()
        if newVec[1] then
            newVec[1]:release()
            table.remove(newVec, 1)
            scheduler.performWithDelayGlobal(function()
                releaseFunc()
            end, 1)
        end
    end
    releaseFunc()
end

---创建粒子特效（方法setPositionType:cc.POSITION_TYPE_FREE,cc.POSITION_TYPE_RELATIVE,cc.POSITION_TYPE_GROUPED）
--@param parent node 资源的父节点
--@param resName string 资源名称，例如:"123.plist"
--@param posx int 横坐标，默认0
--@param posy int 纵坐标，默认0
--@param tag string 标签名，重复创建同一个资源动画时用来区分
--@return #node 所创建的粒子资源
function CSResourceMgr.createParticle(parent, resName, posx, posy, tag)
    tag = tag or ""
    if CSResourceMgr.ParticleTable[resName..tag]~=nil then
        CSResourceMgr.removeParticle(resName, tag)
    end
    local particle = cc.ParticleSystemQuad:create(resName)
    particle:addTo(parent)
    particle:setPosition(posx or 0, posy or 0)
    CSResourceMgr.ParticleTable[resName..tag] = particle
    particle.res = resName
    particle.tag = tag
    return particle
end

---删除粒子特效
--@param resName string 资源名称，例如:"123.plist"
--@param tag string 标签名，重复创建同一个资源动画时用来区分
function CSResourceMgr.removeParticle(resName, tag)
    tag = tag or ""
    if CSResourceMgr.ParticleTable[resName..tag]~=nil then
        local ret,errMessage = pcall(function()
            transition.stopTarget(CSResourceMgr.ParticleTable[resName..tag])
            CSResourceMgr.ParticleTable[resName..tag]:removeAllChildren()
            CSResourceMgr.ParticleTable[resName..tag]:removeFromParent(true)
        end)
        if ret==true then
        --print(resName..tag.."删除成功")
        else
            print(resName..tag.."删除失败，可能是它的父节点已经被删除")
        end
        CSResourceMgr.ParticleTable[resName..tag] = nil
    end
end

---删除所有粒子资源，谨慎调用
function CSResourceMgr.removeAllParticle()
    for tag, var in pairs(CSResourceMgr.ParticleTable) do
        CSResourceMgr.removeParticle(tag)
    end
    CSResourceMgr.ParticleTable = {}
end

---加载ccbi接口
--@param parent node 资源的父节点
--@param resName string 资源名称，例如:"texture/123.ccbi"
--@param posx int 横坐标，默认0
--@param posy int 纵坐标，默认0
--@return #node 所创建的ccbiNode
function CSResourceMgr.createCCBI(parent, resName, posx, posy)
    local proxy = cc.CCBProxy:create()
    local node = CCBReaderLoad(resName, proxy)
    if parent then
    	node:addTo(parent)
    end
    node:setPosition(posx or 0, posy or 0)
    return node
end

---获取ccbi内的所有粒子node
--@param ccbiNode node 所创建的ccbiNode
--@return #table 粒子node的table
function CSResourceMgr.getCCBIParticle(ccbiNode)
	local vec = {}
	local function getNode(parent)
		local children = parent:getChildren()
        for key, var in pairs(children) do
            if var.setPositionType then
				table.insert(vec, var)
			end
            getNode(var)
		end
	end
    getNode(ccbiNode)
    return vec
end

return CSResourceMgr
