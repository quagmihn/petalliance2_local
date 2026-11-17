--vesion number 1.0
--@client side ExitGameViewMgr.lua
--[[
这个文件是退出游戏界面
--]]
--script writer Leon Lee
--creation time 2016-7-13

local ExitGameViewMgr = {}
--翻译
local trans_exitgame = "tips55"--退出游戏文字

--数据层


---------------------------------我是分割线------------------------------------
--ui初始化信息
local resNameExitGame =  "" --列表UI资源

local fontInfo = {--该界面所有的文本格式信息，用于界面设置
    txt_exit ={
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =91,g=104,b=150,a=255},
        outline_color = {r =38,g=54,b=76,a=255},
        text = trans_exitgame
    },
    
    
 }
 
 
---------------------------------我是分割线------------------------------------
---设置label的字体
local function setLabel(label,string,outline,outlinewidth,textColor,maxwidth)

    CSResourceMgr.setLabelColorByNode(label,textColor)
    CSResourceMgr.setLabelStringByNode(label,string,nil)
    if outlinewidth~=nil  then
        label:enableOutline(outline, outlinewidth)
    end

    if maxwidth~=nil then
        CSResourceMgr.setLabelMaxWidthByNode(label,maxwidth)
    end
end

local function hideUI()
    CSResourceMgr.removeCSObjectByTag(resNameExitGame)
end

local function addUI(scene,callback)

    local function loadCSB()
    
        local csbUI = CSResourceMgr.createRes(scene,resNameExitGame)
        csbUI:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameExitGame, 320, 480)  
        
        local txt_exit = CSResourceMgr.getNodeByName(resNameExitGame,"txt_exit")
        setLabel(txt_exit,fontInfo.txt_exit.text,fontInfo.txt_exit.outline_color,fontInfo.txt_exit.outline_width,fontInfo.txt_exit.font_color)
        csbUI:performWithDelay(function() 
            hideUI() 
            
            if callback~=nil then
                callback() 
            end
            end,1.5)
    end
    
    local function playCSB()
        GameAudio.playUISound("popup")
        local db = CSResourceMgr.getNodeByName(resNameExitGame,"db")
        db:setVisible(true)
      
        --CSResourceMgr.getNodeByName(resNameFilterPopup,"btn_close"):setVisible(true)
        CocosModuleMgr.showUIAnimation(db,"down")
        
    end
    
    loadCSB()
    --playCSB()
end

local function addUI2(scene,callback,desc,timesec)

    local function loadCSB()
    
        local csbUI = CSResourceMgr.createRes(scene,resNameExitGame)
        csbUI:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameExitGame, 320, 480)  
        
        local txt_exit = CSResourceMgr.getNodeByName(resNameExitGame,"txt_exit")
        setLabel(txt_exit,desc,fontInfo.txt_exit.outline_color,fontInfo.txt_exit.outline_width,fontInfo.txt_exit.font_color)
        csbUI:performWithDelay(function() 
            hideUI() 
            if callback~=nil then
                callback() 
            end
            end,timesec)
    end
    
    local function playCSB()
        GameAudio.playUISound("popup")
        local db = CSResourceMgr.getNodeByName(resNameExitGame,"db")
        db:setVisible(true)
      
        --CSResourceMgr.getNodeByName(resNameFilterPopup,"btn_close"):setVisible(true)
        CocosModuleMgr.showUIAnimation(db,"down")
        
    end
    
    loadCSB()
    --playCSB()
end



---------------------------------我是分割线------------------------------------
function ExitGameViewMgr.Init()
    resNameExitGame = "Player/exitgame.csb" 
end


function ExitGameViewMgr.show(scene,callback)
    scene = scene or SceneMgr.getRunningScene
    addUI(scene,callback)
end


function ExitGameViewMgr.show(scene,callback,desc,timesec)
    scene = scene or SceneMgr.getRunningScene
    addUI2(scene,callback,desc,timesec)
end


return ExitGameViewMgr