local SceneMgr = {}

SceneMgr.SHOW_ERROR = false

SceneMgr.isProcessing = false

--载入模式，1：左端载入，2：右端载入，3：中间载入，99：从上次离开地图的位置载入
SceneMgr.mapEnterType = 3

SceneMgr.mapType = ""
SceneMgr.previousScene = ""
SceneMgr.currentScene = ""
SceneMgr.getRunningScene = nil

local tipsVec = nil

local visbleCount = 0

---重新初始化SceneMgr，用于动态lua调试
function SceneMgr.Init()
    print("SceneMgr初始化")
    SceneMgr.isProcessing = false
    SceneMgr.mapEnterType = 3
    SceneMgr.mapType = ""
    SceneMgr.previousScene = ""
    SceneMgr.currentScene = ""
    SceneMgr.getRunningScene = nil
    
    if tipsVec==nil then
        local LoadingTipsInfo = TxtReader.new("Config/loadingTips.txt")
        tipsVec = LoadingTipsInfo.init({"id", "min", "max", "content"}, 1)
        for key, var in pairs(tipsVec) do
            var.min = tonumber(var.min)
            var.max = tonumber(var.max)
            local dialogVec = lua_string_split(var.content, ",")
            var.tips = {}
            for k=1, #dialogVec do
                if dialogVec[k]~="" then
                    table.insert(var.tips, dialogVec[k])
                end
            end
        end
    end
    
    visbleCount = 0
end

function SceneMgr.initUpdateScene()
    local updateMgr = require("src.GameMgr.Update.UpdateMgr")
    local updateScene = updateMgr:new()
    local transition = display.wrapSceneWithTransition(updateScene, "fade", 0.5)
    display.replaceScene(transition)
end

---场景切换
--@param curScene node 当前场景，一般传self
--@param sceneName string 场景的名称，例如要加载MainScene.lua就填"MainScene"
--@param typeStr string Loading界面csb的后缀
--@param callback function 场景切换后的回调
function SceneMgr.replaceScene(curScene, sceneName, typeStr, callback)
    print("开始加载新场景"..sceneName)
    if SceneMgr.isProcessing == true then
        print("当前有场景正在加载，"..sceneName.."被取消加载")
	    return false
    end
    if sceneName==nil or sceneName=="" then
        print("场景名称为空，被取消加载")
        return false
    end
    typeStr = typeStr or ""
    curScene = curScene or cc.Director:getInstance():getRunningScene()
    SceneMgr.mapType = typeStr
    
    visbleCount = 0
    SceneMgr.isProcessing = true
    ChatUIMgr.load_finished = false
    TownChatMgr.load_finished = false 
    ChatBubbleMgr.ChatBubbleTable = {}
    CocosModuleMgr.effectTable = {}
    CocosModuleMgr.loadingbarTable = {}
    SceneMgr.previousScene = SceneMgr.currentScene
    SceneMgr.currentScene = sceneName
    
    local resName = ""
    if typeStr=="" then
        resName = "Scene/LoadingLayer"..GetRandom.random(1, 3)..".csb"
    else
        resName = "Scene/LoadingLayer"..typeStr..".csb"
    end
    
    local layer = CSResourceMgr.createRes(curScene, resName)
    layer:setLocalZOrder(CocosModuleMgr.ZORDER_LOADING)
    CSResourceMgr.setRelativePosition(resName, 320, 480)
    CSResourceMgr.setLabelString(resName, "Text", "tips30", "", {r=0,g=0,b=0,a=255,w=1}, nil, 300)
    CSResourceMgr.setLabelColor(resName, "Tips", {r=182,g=252,b=255,a=255})
    if tipsVec then
        local tips = nil
        for key, var in pairs(tipsVec) do
            tips = var.tips
            if var.min<=CharInfo.getLevel() and var.max>=CharInfo.getLevel() then
                break
            end
        end
        if tips then
            if #tips>0 then
                CSResourceMgr.setLabelString(resName, "Tips", tips[GetRandom.random(1, #tips)])
            end
        end
    end
    CSResourceMgr.setLabelMaxWidth(resName, "Tips", 600)
    CSResourceMgr.getNodeByName(resName, "Tips"):setAnchorPoint(0.5, 0.5)
    layer:setOpacity(0)
    transition.fadeIn(layer, {time=0.2})
    CSResourceMgr.getNodeByName(resName, "LoadingBar"):setPercent(0)
    CocosModuleMgr.setLoadingBarPercent(CSResourceMgr.getNodeByName(resName, "LoadingBar"), 100, 20)
    layer:performWithDelay(function()
        UnblockLoader.clean()
        UIStack.Init()
        transition.stopTarget(curScene)
        CSResourceMgr.removeAllParticle()
        PlayerAnimeMgr.removeAllPlayer()
        AnimationMgr.removeAllGafObjects()
        Animation3DMgr.removeAllObjects()
        CSResourceMgr.removeAllCSObjects()
        curScene:removeAllChildren()

        local function replaceFunc()
            local secondScene = require("src.app.scenes."..sceneName)
            local nextScene = secondScene:new()
            local transition = display.wrapSceneWithTransition(nextScene, "fade", 0)
            display.replaceScene(transition)
            SceneMgr.getRunningScene = nextScene
            if callback then
                callback()
            end
            SceneMgr.isProcessing = false
        end
        if SceneMgr.SHOW_ERROR then
            replaceFunc()
        else
            local ret,errMessage = pcall(function()
                replaceFunc()
            end)
            if not ret==true then
                SceneMgr.isProcessing = false
                SceneMgr.replaceScene(SceneMgr.getRunningScene, SceneMgr.previousScene, nil, function()
                    StandardTipsMgr.show(1, "Scene Error!")
                end)
            end
        end
    end, 0.3)
end

---场景缓存清空，在加载到新场景时使用
--@param curScene node 当前场景，一般传self
function SceneMgr.clearScene(curScene)
    MapSeekerMgr.callSeekFunc()
    
    if NetInterface.isClientClosed then
        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "login27", function()
            LoginViewMgr.gameReInit()
        end)
    end

    if LoginViewMgr.isKickByServer == 1 then
      
        local function backToLoginView()
            LoginViewMgr.gameReInit()
        end
        ExitGameViewMgr.show(SceneMgr.getRunningSecne,backToLoginView,"login40",6)
    end
    --[[
    curScene:performWithDelay(function()
        display.removeUnusedSpriteFrames()
    end, 1.0)
    ]]
    
    
    --刷新时间，可以稍微弥补scheduler计时器在UI加载时停住的误差
    CharInfo.setServerTime(CharInfo.getServerTime())
        
    local curTexMem = tonumber(display.getCachedTextureInfo())
    local luaMen = collectgarbage("count")
    print("curTexMem & luaMen is......"..curTexMem,luaMen)
   -- if curTexMem > 130000000 then -- 释放内存
        --display.removeUnusedSpriteFrames()
        --curScene:performWithDelay(function()
        --display.removeUnusedSpriteFrames()
        --end, 1.0)
    --else
        --display.clearMemory()
        --collectgarbage("collect")   --释放lua内存
    --end
    display.removeUnusedSpriteFrames()
    if luaMen > 40000 then 
        collectgarbage("collect")
    end
    ObjectPool.resetAll()
    HighPerformList.resetAllSchedule()
    --if curTexMem > 90000000 then -- 释放内存
        --display.removeUnusedSpriteFrames()
        --[[
        curScene:performWithDelay(function()
        display.removeUnusedSpriteFrames()
    end, 1.0)
    ]]
    --else
      --  display.clearMemory()
        --collectgarbage("collect")   --释放lua内存
   -- end
    
    
end

function SceneMgr.onSceneExit(curScene)

    --[[
  local curTexMem = tonumber(display.getCachedTextureInfo())
    --local luaMen = collectgarbage("count")

    local curTexMem = tonumber(display.getCachedTextureInfo())
    print("curTexMem is......"..curTexMem)
    if curTexMem > 120000000 then -- 释放内存
        print("clearMemory...................................")
        display.clearMemory()
    end
    ]]
end

---隐藏或显示地图背景
--@param boolVisible bool 是否可见
function SceneMgr.setMapVisible(boolVisible)
    --[[
    if boolVisible then
        visbleCount = visbleCount + 1
    else
        visbleCount = visbleCount - 1
    end
    if visbleCount>=0 then
    	boolVisible = true
    else
        boolVisible = false
    end
    print("SceneMgr.setMapVisible ", visbleCount)
    ]]
    WorldMapMgr.setVisible(boolVisible)
    WorldMapAwardsMgr.setVisible(boolVisible)
    EmbeddedMapMgr.setVisible(boolVisible)
    TownMapMgr.setVisible(boolVisible)
    TownChatMgr.setVisible(boolVisible)
    StatusBarMgr.setVisible(boolVisible)
    BasicMenuMgr.setVisible(boolVisible)
    HomeMenuMgr.setVisible(boolVisible)
end

---测试用，别调用
function SceneMgr.closeAllWindow()
    local children = SceneMgr.getRunningScene:getChildren()
    for key, var in pairs(children) do
        if var:getLocalZOrder()==CocosModuleMgr.ZORDER_WINDOW then
            var:setVisible(false)
        end
    end
    SceneMgr.setMapVisible(true)
    StatusBarMgr.hideTopInfoBar()
end

return SceneMgr