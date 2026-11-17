local OvertimeListener = {}

OvertimeListener.DEFAULT_WAIT_TIME = 20

local scheduler = require("src.framework.scheduler")
local HandleTable = {}
local FuncTable = {}
local tipsStr = ""
local tagsStr = ""

function OvertimeListener.Init()
    print("OvertimeListener初始化")
    
    for key, var in pairs(HandleTable) do
        scheduler.unscheduleGlobal(var)
    end
    HandleTable = {}
    FuncTable = {}
    tipsStr = "操作超时了，是否重试？"
    tagsStr = "Default"
end

---带超时监听的执行方法
--@param func function 执行函数
--@param tag string 执行函数标签，不填则默认"Default"
--@param tips string 超时提示文字，不填则默认"操作超时了，是否重试？"，且如果填了overtimeFunc可以不填tips
--@param overtimeFunc function 超时后自动执行的函数，不填则询问是否重试
function OvertimeListener.start(func, tag, tips, overtimeFunc,waitTime)
	if waitTime == nil then
		waitTime = OvertimeListener.DEFAULT_WAIT_TIME
	end
    tag = tag or tagsStr
    tips = tips or tipsStr
    if HandleTable[tag] ~= nil then
        OvertimeListener.cancel(tag, true)
        print("连续发2次请求,取消之前的请求:",tag)
        print(debug.traceback("", 2))
    end
    local overtimeProcess = function()
        if TOUCH_PIPELINE_DIAGNOSTICS then
            print(string.format("[TOUCH_DIAG] overtime tag=%s timeout_seconds=%s scene=%s loading_visible=%s",
                tostring(tag), tostring(waitTime), tostring(SceneMgr.currentScene), tostring(LoadingView.isLoadingViewShow)))
        end
        local scene = SceneMgr.getRunningScene
        if overtimeFunc then
            overtimeFunc()
        else
            DialogBoxMgr.showSmallDialogBox(scene, 2, tips, function()
                OvertimeListener.start(func, tag, tips)
            end, function()
                LoginViewMgr.gameReInit()
            end, tag)
        end
    end
    HandleTable[tag] = scheduler.performWithDelayGlobal(function()
        LoadingView.hide()
        overtimeProcess()
    end, waitTime)
    FuncTable[tag] = func
    local ret,errMessage = pcall(function()
        func()
    end)
    if ret==false then
        print("call function failed in OvertimeListener.start:",errMessage)
        print(debug.traceback("", 2))
        overtimeProcess()
    end
end

---取消带超时监听的执行方法
--@param tag string 执行函数标签，不填则默认"Default"
--@param cleanUp bool 是否清空方法，默认不清空，清空则无法使用OvertimeListener.restart方法
function OvertimeListener.cancel(tag, cleanUp)
    tag = tag or tagsStr
    DialogBoxMgr.hideSmallDialogBox(tag)
    if HandleTable[tag]~=nil then
        scheduler.unscheduleGlobal(HandleTable[tag])
        HandleTable[tag] = nil
    end
    if cleanUp==true then
    	FuncTable[tag] = nil
    end
end

---按照标签重新开始带超时监听的执行方法
--@param tips string 超时提示文字，不填则默认"操作超时了，是否重试？"
--@param tag string 执行函数标签，不填则默认"Default"
function OvertimeListener.restart(tips, tag)
    tag = tag or tagsStr
    tips = tips or tipsStr
    OvertimeListener.cancel(tag)
    LoadingView.hide()
    local scene = SceneMgr.getRunningScene
    DialogBoxMgr.showSmallDialogBox(scene, 2, tips, function()
        OvertimeListener.start(FuncTable[tag], tag)
    end, function()
        LoginViewMgr.gameReInit()
    end, tag)
end

return OvertimeListener
