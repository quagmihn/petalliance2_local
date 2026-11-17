local CopyMapLoadingMgr = {}

local resName = ""
local resNameBlock = ""
local loadingResSpine = ""

function CopyMapLoadingMgr.Init()
    print("CopyMapLoadingMgr初始化")
    
    resName = "Scene/ProgressHud.csb"
    resNameBlock = "Scene/CommonMask.csb"
    loadingResSpine = "Spine/effects/loading.png"
end

function CopyMapLoadingMgr.hide(tag, hideCallback)
    tag = tag or "CopyMapLoading"
    if TOUCH_PIPELINE_DIAGNOSTICS then
        print(string.format("[TOUCH_DIAG] copy_loading action=hide tag=%s scene=%s", tostring(tag), tostring(SceneMgr.currentScene)))
    end
    if CSResourceMgr.getCsbObj(resName, tag) then
        AnimationMgr.removeGafObjectByTag(loadingResSpine, tag)
        CSResourceMgr.removeCSObjectByTag(resName, tag)
        CSResourceMgr.removeCSObjectByTag(resNameBlock, tag)
        if hideCallback then hideCallback() end
    end
end

function CopyMapLoadingMgr.show(scene, timeSeconds, tag, hideCallback)
    loadingResSpine = CocosModuleMgr.getWordImage("loading.png")
    scene = scene or SceneMgr.getRunningScene
    timeSeconds = timeSeconds or 0.1
    tag = tag or "CopyMapLoading"
    if TOUCH_PIPELINE_DIAGNOSTICS then
        print(string.format("[TOUCH_DIAG] copy_loading action=show tag=%s scene=%s delay=%s",
            tostring(tag), tostring(SceneMgr.currentScene), tostring(timeSeconds)))
    end
    if not CSResourceMgr.getCsbObj(resName, tag) then
        local csb = CSResourceMgr.createRes(scene, resName, tag)
        csb:setLocalZOrder(CocosModuleMgr.ZORDER_HUD)
        CSResourceMgr.setRelativePosition(resName, 320, 480, tag)
        
        CSResourceMgr.seekNodeByName(csb,"loading_diban"):setVisible(false)
        CSResourceMgr.seekNodeByName(csb,"hud"):setVisible(false)
        local size = csb:getContentSize()
        local aniBG = AnimationMgr.createAni( csb, loadingResSpine, size.width/2, size.height/2, tag)
        aniBG:setScale(0.85)
        AnimationMgr.playAni(aniBG.res, "animation", true, tag)
    end
    
    if not CSResourceMgr.getCsbObj(resNameBlock, tag) then
        CSResourceMgr.createRes(scene, resNameBlock, tag):setLocalZOrder(CocosModuleMgr.ZORDER_HUD)
        CSResourceMgr.setRelativePosition(resNameBlock, 320, 480, tag)
    end
    
    scene:performWithDelay(function()
        CopyMapLoadingMgr.hide(tag, hideCallback)
    end, timeSeconds)
end

function CopyMapLoadingMgr.isOpen(tag)
    if CSResourceMgr.getCsbObj(resName, tag) then
        return true
    end
    return false
end

return CopyMapLoadingMgr
