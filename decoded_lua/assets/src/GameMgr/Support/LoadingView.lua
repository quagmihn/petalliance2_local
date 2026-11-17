local LoadingView = {}

local tag = ""
local resName = ""
local resNameBlock = ""
local loadingResSpine = ""
local scheduler = nil
local handle = nil
LoadingView.isLoadingViewShow = false

function LoadingView.Init()
    print("LoadingView初始化")
    
    tag = "LoadingView"
    resName = "Scene/ProgressHud.csb"
    resNameBlock = "Scene/CommonMask.csb"
    loadingResSpine = "Spine/effects/loading.png"
    scheduler = require("src.framework.scheduler")
    handle = nil
    LoadingView.isLoadingViewShow = false
end

function LoadingView.show(scene)
    if TOUCH_PIPELINE_DIAGNOSTICS then
        print(string.format("[TOUCH_DIAG] loading_overlay action=show scene=%s was_visible=%s pending_hide=%s",
            tostring(SceneMgr.currentScene), tostring(LoadingView.isLoadingViewShow), tostring(handle ~= nil)))
    end
    loadingResSpine = CocosModuleMgr.getWordImage("loading.png")
    if handle then
        scheduler.unscheduleGlobal(handle)
    end
    scene = scene or SceneMgr.getRunningScene
    if not CSResourceMgr.getCsbObj(resName, tag) then
        CSResourceMgr.createRes(scene, resName, tag):setLocalZOrder(CocosModuleMgr.ZORDER_HUD)
        CSResourceMgr.setRelativePosition(resName, 320, 480, tag)
        
        ---[[下面这段因为改了新的spine动画，所以被我修改了 by leon lee
        local csb = CSResourceMgr.getCsbObj(resName, tag)
        CSResourceMgr.seekNodeByName(csb,"loading_diban"):setVisible(false)
        CSResourceMgr.seekNodeByName(csb,"hud"):setVisible(false)
        local size = csb:getContentSize()
        local aniBG = AnimationMgr.createAni( CSResourceMgr.getCsbObj(resName, tag), loadingResSpine, size.width/2, size.height/2)
        aniBG:setScale(0.85)
        AnimationMgr.playAni(aniBG.res, "animation", true)
        
        --CSResourceMgr.playAllFrame(resName, true, tag)
        ---]]
    end
    if not CSResourceMgr.getCsbObj(resNameBlock, tag) then
        CSResourceMgr.createRes(scene, resNameBlock, tag):setLocalZOrder(CocosModuleMgr.ZORDER_HUD)
        CSResourceMgr.setRelativePosition(resNameBlock, 320, 480, tag)
    end

    LoadingView.isLoadingViewShow = true
end

function LoadingView.hide()
    if TOUCH_PIPELINE_DIAGNOSTICS then
        print(string.format("[TOUCH_DIAG] loading_overlay action=hide scene=%s was_visible=%s",
            tostring(SceneMgr.currentScene), tostring(LoadingView.isLoadingViewShow)))
    end
    AnimationMgr.removeGafObjectByTag(loadingResSpine)
    CSResourceMgr.removeCSObjectByTag(resName, tag)
    --为了收发多条网络消息时，loadingView能够持续禁止屏幕点击，延迟0.1秒释放
    handle = scheduler.performWithDelayGlobal(function()
        CSResourceMgr.removeCSObjectByTag(resNameBlock, tag)
        handle = nil
        if TOUCH_PIPELINE_DIAGNOSTICS then
            print(string.format("[TOUCH_DIAG] loading_overlay mask_removed scene=%s", tostring(SceneMgr.currentScene)))
        end
    end, 0.1)

    LoadingView.isLoadingViewShow = false
end

return LoadingView
