
--[[
这是一个UI栈，为了记录UI界面的次序
]]
local UIStack = {}

--[[
local UIObject = 
{
    objectInstanc = nil, --UI实例
    uiName = nil,   --UI名称
}
]]
local uiObjectList = {}
local uiNodeList = {}
local fullScreenCount = 0


local function hideUINode(isFullScreen,uiname)
    local list1 = {}
    
    if isFullScreen then
        local children = SceneMgr.getRunningScene:getChildren()
        for key, var in pairs(children) do
            if var:getLocalZOrder()==CocosModuleMgr.ZORDER_WINDOW and var:isVisible() then
                var:setVisible(false)
                table.insert(list1,var)
            end
        end
    end
    
    uiNodeList[uiname] = list1
end

--[[
local function restoreHideUINode(uiname)
    local num = #uiNodeList
    if num >0 then
        local list = uiNodeList[num]
        for k,v in pairs(list) do 
            v:setVisible(true)
        end
        table.remove(uiNodeList,num)
    end
    
end
]]
local function restoreHideUINode(uiname,iserror)
    if iserror == true then 
        uiNodeList = {}
        return
    end
    local list = uiNodeList[uiname]
    if list~=nil then 
         for k,v in pairs(list) do 
           
             pcall(function()
                v:setVisible(true)
            end)
        end    
        uiNodeList[uiname] = nil   
    end    
end

function UIStack.reSortUIStack(uiname)
    for i=1,#uiObjectList do 
        if uiObjectList[i].uiName == uiname then 
            restoreHideUINode(uiname,true)
            if uiObjectList[i].isFullScreen == true then 
                
                fullScreenCount = fullScreenCount-1
                if fullScreenCount <=0 then
                    fullScreenCount = 0
                    SceneMgr.setMapVisible(true)
                else
                    SceneMgr.setMapVisible(false)
                end
            end
            uiObjectList[i] = nil
            break
        end
    end

    local tempObjectList = {}
    for i = 1,#uiObjectList do 
        if uiObjectList[i]~=nil then 
            table.insert(tempObjectList,uiObjectList[i])
        end
    end

    uiObjectList = tempObjectList
    SceneMgr.setMapVisible(true)
    fullScreenCount =0
end
---把UI推入堆栈
--@param uiname string ui的名称
--@param closecallback function 关闭函数
--@param isFullScreen 是否全屏
function UIStack.push(uiname,closecallback,isFullScreen)
    local uiobject = {}
    print("uiname & is fullscreen"..uiname,isFullScreen)
    local stackNum = #uiObjectList
    if stackNum > 0 then --判断栈顶，不能重复入栈
        if uiObjectList[stackNum].uiName==uiname then --如果栈顶名字相同，不准入栈
            return
        end
    end
    if TeamViewMgr.isTeamViewOpen() and isFullScreen then
        TeamViewMgr.hide()
        print("准备打开其他全屏界面，现在关闭组队界面。如果已经在队伍中，会出现bug，请保护不要打开。")
    	return
    end
    uiobject.objectInstanc = closecallback
    uiobject.uiName = uiname
    uiobject.isFullScreen = isFullScreen
    table.insert(uiObjectList,uiobject)
    hideUINode(isFullScreen,uiname)
    if isFullScreen then 
        SceneMgr.setMapVisible(false)
        fullScreenCount = fullScreenCount+1
    end
end

---把UI弹出堆栈
function UIStack.pop(uiname)
    local stackNum = #uiObjectList
    print("uistack args name is "..uiname)
    if stackNum > 0 then
        
        --print("界面名称"..uiObjectList[stackNum].uiName)
        --uiObjectList[stackNum].objectInstanc.hide()
        if uiObjectList[stackNum].uiName~=uiname then --异常，走特殊处理
            print("uistack not mismatch args name is "..uiname.."-stack name is "..uiObjectList[stackNum].uiName)
            --UIStack.closeAllUI()
             UIStack.reSortUIStack(uiname)
        else
            restoreHideUINode(uiname)
            if uiObjectList[stackNum].isFullScreen == true then
                
                fullScreenCount = fullScreenCount-1
                if fullScreenCount <=0 then
                    fullScreenCount = 0
                    SceneMgr.setMapVisible(true)
                else
                    SceneMgr.setMapVisible(false)
                end
            end
            table.remove(uiObjectList,stackNum)
            
        end
    else
        
        print("界面堆栈没有了，弹出退出")
        --restoreHideUINode()
        SceneMgr.setMapVisible(true)
        fullScreenCount = 0
    end
end

function UIStack.Init()
    uiObjectList = {}
    uiNodeList = {}
    fullScreenCount = 0
end

local function exitGame()
    if device.platform == "android" then 
        AndroidFunction.exitApp()         
    end 

    if device.platform == "windows" then 
        StandardTipsMgr.show(0,"windows不让退，继续测试")
    end    
end

function UIStack.onBackMenu() --android回退按钮
    if GameGuideMgr.checkIsGuiding() == true or LoadingView.isLoadingViewShow == true then --如果在新手引导中，不回退
        if device.platform == "android" then 
            if AndroidFunction.isUseSdkExit() == 1 then  --sdk退出
                AndroidFunction.sdkExit()
            else
                AndroidFunction.eixtGameDialogue()
                --[[
                DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene,2,"你真的要走了吗？",function() 
                    ExitGameViewMgr.show(SceneMgr.getRunningScene,exitGame)
                end
                
                )]]                
            end
        end
        return
    end
    
    local stackNum = #uiObjectList
    if stackNum > 0 then
        print("界面名称"..uiObjectList[stackNum].uiName)
        uiObjectList[stackNum].objectInstanc()
        
        --table.remove(uiObjectList,stackNum)
    else
        if device.platform == "windows" then 
            DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene,2,"你真的要走了吗？",function() 
                ExitGameViewMgr.show(SceneMgr.getRunningScene,exitGame)
            end
            )
        end

        if device.platform == "android" then 
            if AndroidFunction.isUseSdkExit() == 1 then  --sdk退出
                AndroidFunction.sdkExit()
            else
                AndroidFunction.eixtGameDialogue()
                --[[
                DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene,2,"你真的要走了吗？",function() 
                    ExitGameViewMgr.show(SceneMgr.getRunningScene,exitGame)
                end
                
                )]]                
            end
        end
        print("界面堆栈没有了，弹出退出")
    end   
end

---关闭所有的UI
function UIStack.closeAllUI()
    local stackNum = #uiObjectList
    while stackNum > 0 do
        uiObjectList[stackNum].objectInstanc() 
        stackNum = stackNum - 1
    end
    --[[
    for k,v in pairs(uiObjectList) do
        v.objectInstanc()
    end
    ]]

    SceneMgr.setMapVisible(true)
    uiObjectList = {}
    uiNodeList = {}
    fullScreenCount = 0
end

---检查是否打开界面
--@param uiname string ui的关键字

function UIStack.isUIOpen(uiname)
    for k,v in pairs(uiObjectList) do
        if v.uiName == uiname then
            return true
        end
    end
    
    return false
end





return UIStack