local DialogBoxMgr = {}

DialogBoxMgr.INPUT_EDITBOX_LENTH = 18

local resNameL = ""
local resNameS = ""
local richLabelL = nil
local richLabelS = nil
local tagL = ""
local tagS = ""
local textInput = ""

function DialogBoxMgr.Init()
    print("DialogBoxMgr初始化")
    
    resNameL = "UI/DialogBox/DialogBoxLayer.csb"
    resNameS = "UI/DialogBox/SmallDialogBox.csb"
    richLabelL = nil
    richLabelS = nil
    tagL = ""
    tagS = ""
    textInput = ""
end

---显示大对话框
--@param scene node 当前场景
--@param type int 类型，1为单按钮确认，2为双按钮确认取消
--@param info string 文字内容
--@param func function 双按钮时的确认回调
--@param funcCancel function 双按钮时的取消回调
--@param tag string 标签，可不填
function DialogBoxMgr.showDialogBox(scene, type, info, func, funcCancel, tag)
    DialogBoxMgr.showSmallDialogBox(scene, type, info, func, funcCancel, tag)
    --[[
    tag = tag or ""
    tagL = tag
    func = func or function()
    end
    funcCancel = funcCancel or function()
    end
    scene = scene or SceneMgr.getRunningScene
    info = LuaSqlite.getLanguageByKey(info)
    
    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, resNameL)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_MSGBOX)
        CSResourceMgr.setRelativePosition(resNameL, 320, 480)
        
        local labelMaxWidth = 440
        if CocosModuleMgr.checkIsRichLabelString(info) then
            local tmpNode = CSResourceMgr.getNodeByName(resNameL, {"db", "db_bg", "infolist", "info"})
            local RFontSize = tmpNode:getFontSize()
            richLabelL = CocosModuleMgr.createRichLabel(tmpNode, info, RFontSize, "cuyuan_GBK.ttf", labelMaxWidth, 0, 0, ture)
            CSResourceMgr.setLabelString(resNameL, {"db", "db_bg", "infolist", "info"}, " ", "", nil, -1)
            tmpNode:setTextAreaSize({width = 0, height = richLabelL.realHeight})
            tmpNode:ignoreContentAdaptWithSize(false)
        else
            CSResourceMgr.setLabelColor(resNameL, {"db", "db_bg", "infolist", "info"}, {r=0,g=0,b=0,a=255})
            CSResourceMgr.setLabelString(resNameL, {"db", "db_bg", "infolist", "info"}, info, "", nil, -1)
            CSResourceMgr.setLabelMaxWidth(resNameL, {"db", "db_bg", "infolist", "info"}, labelMaxWidth, "", -1)
        end
        
        CSResourceMgr.setButtonString(resNameL, {"db", "db_bg", "b1"}, "tips3", "", {r=115,g=2,b=54,a=200})
        CSResourceMgr.setButtonString(resNameL, {"db", "db_bg", "b2"}, "tips4", "", {r=2,g=43,b=155,a=200})
        CSResourceMgr.setButtonString(resNameL, {"db", "db_bg", "b3"}, "tips3", "", {r=115,g=2,b=54,a=200})
        
        if type==1 then
            CSResourceMgr.getNodeByName(resNameL, {"db", "db_bg", "b3"}):setVisible(true)
            CSResourceMgr.clickEventBinding(resNameL, {"db", "db_bg", "b3"}, function()
                DialogBoxMgr.hideDialogBox()
            end, "", true)
        elseif type==2 then
            CSResourceMgr.getNodeByName(resNameL, {"db", "db_bg", "b1"}):setVisible(true)
            CSResourceMgr.getNodeByName(resNameL, {"db", "db_bg", "b2"}):setVisible(true)
            CSResourceMgr.clickEventBinding(resNameL, {"db", "db_bg", "b1"}, function()
                DialogBoxMgr.hideDialogBox()
            	func()
            end, "", true)
            CSResourceMgr.clickEventBinding(resNameL, {"db", "db_bg", "b2"}, function()
                DialogBoxMgr.hideDialogBox()
                funcCancel()
            end, "", true)
        end        
    end
    
    local function playCSB()
        local label = CSResourceMgr.getNodeByName(resNameL, {"db", "db_bg", "infolist", "info"})
        if not CocosModuleMgr.checkIsRichLabelString(info) then
            CocosModuleMgr.sharpenLabel(label, 1)
        end
        CSResourceMgr.playAction(resNameL, 0, 10, false)
    end
    
    local funcTable = {loadCSB, playCSB}

    UnblockLoader.load(funcTable, "DialogBoxMgr")
    ]]
end

function DialogBoxMgr.hideDialogBox(tag)
    --[[
    if not tag or tag==tagL then
        UnblockLoader.cancel("DialogBoxMgr")
        if richLabelL then
            richLabelL:removeFromParent(true)
            richLabelL = nil
        end
        CSResourceMgr.removeCSObjectByTag(resNameL)
    end
    ]]
end

---显示小对话框
--@param scene node 当前场景
--@param type int 类型，1为单按钮确认，2为双按钮确认取消
--@param info string 文字内容
--@param func function 单按钮确认/双按钮时确认 回调
--@param funcCancel function 双按钮时的取消回调
--@param tag string 标签，可不填
--@param enableClickBgHide bool 允许点击背景关闭界面，可不填
function DialogBoxMgr.showSmallDialogBox(scene, type, info, func, funcCancel, tag, enableClickBgHide)
    UIStack.push("DialogBoxMgr", DialogBoxMgr.hideSmallDialogBox, false)
    tag = tag or ""
    tagS = tag
    richLabelS = nil
    func = func or function()
    end
    funcCancel = funcCancel or function()
    end
    scene = scene or SceneMgr.getRunningScene
    info = LuaSqlite.getLanguageByKey(info)

    local function loadCSB()
        if CSResourceMgr.getCsbObj(resNameS) then
            CSResourceMgr.removeCSObjectByTag(resNameS)
        end
        local layer = CSResourceMgr.createRes(scene, resNameS)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_MSGBOX)
        CSResourceMgr.setRelativePosition(resNameS, 320, 480)
        CSResourceMgr.getNodeByName(resNameS, "bg"):setOpacity(0)
        
        CSResourceMgr.setLabelColor(resNameS, "title", {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelString(resNameS, "title", "tips21", "", {r=15,g=55,b=74,a=255,w=3})

        if enableClickBgHide == nil or enableClickBgHide == true then
            CSResourceMgr.clickEventBinding(resNameS, "bg", function()
                DialogBoxMgr.hideSmallDialogBox()
                if type==1 then
                	func()
                elseif type==2 then
                    funcCancel()
                end
            end)
        end

        local labelMaxWidth = 380
        local labelHeight = 0
        if CocosModuleMgr.checkIsRichLabelString(info) then
            local tmpNode = CSResourceMgr.getNodeByName(resNameS, "info")
            local dibanNode = CSResourceMgr.getNodeByName(resNameS, "diban")
            local RFontSize = tmpNode:getFontSize()
            richLabelS = CocosModuleMgr.createRichLabel(dibanNode, info, RFontSize, "cuyuan_GBK.ttf", labelMaxWidth, 0, 0, nil, true)
            labelHeight = richLabelS.realHeight
            if richLabelS.realWidth>labelMaxWidth then
                richLabelS:setPosition(tmpNode:getPositionX()-labelMaxWidth/2, tmpNode:getPositionY()+labelHeight)
            else
                richLabelS:setPosition(tmpNode:getPositionX()-richLabelS.realWidth/2, tmpNode:getPositionY()+labelHeight)
            end
        else
            CSResourceMgr.setLabelColor(resNameS, "info", {r=149,g=246,b=254,a=255})
            CSResourceMgr.setLabelString(resNameS, "info", info)
            CSResourceMgr.setLabelMaxWidth(resNameS, "info", labelMaxWidth)
            local tmpNode = CSResourceMgr.getNodeByName(resNameS, "info")
            tmpNode:setAnchorPoint(0.5, 1)
            labelHeight = tmpNode:getContentSize().height*tmpNode:getScaleY()
            local lposy = tmpNode:getPositionY()
            tmpNode:setPositionY(lposy+labelHeight)
        end
        
        local title = CSResourceMgr.getNodeByName(resNameS, "title")
        local tposy = title:getPositionY()
        title:setPositionY(tposy+labelHeight)
        local db = CSResourceMgr.getNodeByName(resNameS, "diban")
        local dsize = db:getContentSize()
        db:setContentSize(dsize.width, dsize.height+labelHeight)
        
        --[[
        CSResourceMgr.setButtonString(resNameS, "b1", "tips3", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        CSResourceMgr.setButtonString(resNameS, "b2", "tips4", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        CSResourceMgr.setButtonString(resNameS, "b3", "tips3", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        CSResourceMgr.setButtonStringColor(resNameS, "b1", {r=227,g=233,b=255,a=255})
        CSResourceMgr.setButtonStringColor(resNameS, "b2", {r=227,g=233,b=255,a=255})
        CSResourceMgr.setButtonStringColor(resNameS, "b3", {r=227,g=233,b=255,a=255})
        ]]

        if type==1 then
            CSResourceMgr.getNodeByName(resNameS, "b3"):setVisible(true)
            CSResourceMgr.clickEventBinding(resNameS, "b3", function()
                DialogBoxMgr.hideSmallDialogBox()
                func()
            end)
        elseif type==2 then
            CSResourceMgr.getNodeByName(resNameS, "b1"):setVisible(true)
            CSResourceMgr.getNodeByName(resNameS, "b2"):setVisible(true)
            CSResourceMgr.clickEventBinding(resNameS, "b1", function()
                DialogBoxMgr.hideSmallDialogBox()
                func()
            end)
            CSResourceMgr.clickEventBinding(resNameS, "b2", function()
                DialogBoxMgr.hideSmallDialogBox()
                funcCancel()
            end)
        elseif type==3 then
            local info = CSResourceMgr.getNodeByName(resNameS, "info")
            if info ~= nil then
                info:setPositionY(info:getPositionY() + 32)
            end
            local input_bg = CSResourceMgr.getNodeByName(resNameS, "input_bg")
            if input_bg ~= nil then
                local bgsize = input_bg:getContentSize()
                input_bg:setContentSize(bgsize.width, bgsize.height+labelHeight)
                input_bg:setVisible(true)
            end
            local input = CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resNameS, "db"), 
                "empty.png", input_bg:getContentSize().width - 20, input_bg:getContentSize().height, input_bg:getPositionX() + 10, 
                input_bg:getPositionY(), 24, DialogBoxMgr.INPUT_EDITBOX_LENTH, "")
            CSResourceMgr.getNodeByName(resNameS, "b1"):setVisible(true)
            CSResourceMgr.getNodeByName(resNameS, "b2"):setVisible(true)
            CSResourceMgr.clickEventBinding(resNameS, "b1", function()
                textInput = input:getText()
                DialogBoxMgr.hideSmallDialogBox()
                func()
            end)
            CSResourceMgr.clickEventBinding(resNameS, "b2", function()
                DialogBoxMgr.hideSmallDialogBox()
                funcCancel()
            end)
        end
        GameAudio.playUISound("popup")
    end

    local function playCSB()
        CSResourceMgr.playAction(resNameS, 0, 10, false)
        transition.fadeTo(CSResourceMgr.getNodeByName(resNameS, "bg"), {opacity=128, time=0.5})
    end

    local funcTable = {loadCSB, playCSB}

    UnblockLoader.load(funcTable, "DialogBoxMgr_small")
end

function DialogBoxMgr.hideSmallDialogBox(tag)
    if not tag or tag==tagS then
        UnblockLoader.cancel("DialogBoxMgr_small")
        if richLabelS then
            richLabelS:removeFromParent(true)
            richLabelS = nil
        end
        CSResourceMgr.removeCSObjectByTag(resNameS)
        GameAudio.playUISound("retract")
        UIStack.pop("DialogBoxMgr")
    end
end

function DialogBoxMgr.GetInputText()
    return textInput
end


---显示对话框在最顶层
--@param scene node 当前场景
--@param type int 类型，1为单按钮确认，2为双按钮确认取消
--@param info string 文字内容
--@param func function 单按钮确认/双按钮时确认 回调
--@param funcCancel function 双按钮时的取消回调
--@param tag string 标签，可不填
--@param enableClickBgHide bool 允许点击背景关闭界面，可不填
function DialogBoxMgr.showTopDialogBox(scene, type, info, func, funcCancel, tag, enableClickBgHide)
    tag = tag or ""
    tagS = tag
    richLabelS = nil
    func = func or function()
    end
    funcCancel = funcCancel or function()
    end
    scene = scene or SceneMgr.getRunningScene
    info = LuaSqlite.getLanguageByKey(info)

    local function loadCSB()
        if CSResourceMgr.getCsbObj(resNameS) then
            CSResourceMgr.removeCSObjectByTag(resNameS)
        end
        local layer = CSResourceMgr.createRes(scene, resNameS)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_LOADING)
        CSResourceMgr.setRelativePosition(resNameS, 320, 480)
        CSResourceMgr.getNodeByName(resNameS, "bg"):setOpacity(0)
        
        CSResourceMgr.setLabelColor(resNameS, "title", {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelString(resNameS, "title", "tips21", "", {r=15,g=55,b=74,a=255,w=3})

        if enableClickBgHide == nil or enableClickBgHide == true then
            CSResourceMgr.clickEventBinding(resNameS, "bg", function()
                DialogBoxMgr.hideSmallDialogBox()
                if type==1 then
                	func()
                elseif type==2 then
                    funcCancel()
                end
            end)
        end

        local labelMaxWidth = 380
        local labelHeight = 0
        if CocosModuleMgr.checkIsRichLabelString(info) then
            local tmpNode = CSResourceMgr.getNodeByName(resNameS, "info")
            local dibanNode = CSResourceMgr.getNodeByName(resNameS, "diban")
            local RFontSize = tmpNode:getFontSize()
            richLabelS = CocosModuleMgr.createRichLabel(dibanNode, info, RFontSize, "cuyuan_GBK.ttf", labelMaxWidth, 0, 0, nil, true)
            labelHeight = richLabelS.realHeight
            if richLabelS.realWidth>labelMaxWidth then
                richLabelS:setPosition(tmpNode:getPositionX()-labelMaxWidth/2, tmpNode:getPositionY()+labelHeight)
            else
                richLabelS:setPosition(tmpNode:getPositionX()-richLabelS.realWidth/2, tmpNode:getPositionY()+labelHeight)
            end
        else
            CSResourceMgr.setLabelColor(resNameS, "info", {r=149,g=246,b=254,a=255})
            CSResourceMgr.setLabelString(resNameS, "info", info)
            CSResourceMgr.setLabelMaxWidth(resNameS, "info", labelMaxWidth)
            local tmpNode = CSResourceMgr.getNodeByName(resNameS, "info")
            tmpNode:setAnchorPoint(0.5, 1)
            labelHeight = tmpNode:getContentSize().height*tmpNode:getScaleY()
            local lposy = tmpNode:getPositionY()
            tmpNode:setPositionY(lposy+labelHeight)
        end
        
        local title = CSResourceMgr.getNodeByName(resNameS, "title")
        local tposy = title:getPositionY()
        title:setPositionY(tposy+labelHeight)
        local db = CSResourceMgr.getNodeByName(resNameS, "diban")
        local dsize = db:getContentSize()
        db:setContentSize(dsize.width, dsize.height+labelHeight)
        
        --[[
        CSResourceMgr.setButtonString(resNameS, "b1", "tips3", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        CSResourceMgr.setButtonString(resNameS, "b2", "tips4", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        CSResourceMgr.setButtonString(resNameS, "b3", "tips3", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        CSResourceMgr.setButtonStringColor(resNameS, "b1", {r=227,g=233,b=255,a=255})
        CSResourceMgr.setButtonStringColor(resNameS, "b2", {r=227,g=233,b=255,a=255})
        CSResourceMgr.setButtonStringColor(resNameS, "b3", {r=227,g=233,b=255,a=255})
        ]]

        if type==1 then
            CSResourceMgr.getNodeByName(resNameS, "b3"):setVisible(true)
            CSResourceMgr.clickEventBinding(resNameS, "b3", function()
                DialogBoxMgr.hideSmallDialogBox()
                func()
            end)
        elseif type==2 then
            CSResourceMgr.getNodeByName(resNameS, "b1"):setVisible(true)
            CSResourceMgr.getNodeByName(resNameS, "b2"):setVisible(true)
            CSResourceMgr.clickEventBinding(resNameS, "b1", function()
                DialogBoxMgr.hideSmallDialogBox()
                func()
            end)
            CSResourceMgr.clickEventBinding(resNameS, "b2", function()
                DialogBoxMgr.hideSmallDialogBox()
                funcCancel()
            end)
        elseif type==3 then
            local info = CSResourceMgr.getNodeByName(resNameS, "info")
            if info ~= nil then
                info:setPositionY(info:getPositionY() + 32)
            end
            local input_bg = CSResourceMgr.getNodeByName(resNameS, "input_bg")
            if input_bg ~= nil then
                local bgsize = input_bg:getContentSize()
                input_bg:setContentSize(bgsize.width, bgsize.height+labelHeight)
                input_bg:setVisible(true)
            end
            local input = CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resNameS, "db"), 
                "empty.png", input_bg:getContentSize().width - 20, input_bg:getContentSize().height, input_bg:getPositionX() + 10, 
                input_bg:getPositionY(), 24, DialogBoxMgr.INPUT_EDITBOX_LENTH, "")
            CSResourceMgr.getNodeByName(resNameS, "b1"):setVisible(true)
            CSResourceMgr.getNodeByName(resNameS, "b2"):setVisible(true)
            CSResourceMgr.clickEventBinding(resNameS, "b1", function()
                textInput = input:getText()
                DialogBoxMgr.hideSmallDialogBox()
                func()
            end)
            CSResourceMgr.clickEventBinding(resNameS, "b2", function()
                DialogBoxMgr.hideSmallDialogBox()
                funcCancel()
            end)
        end
        GameAudio.playUISound("popup")
    end

    local function playCSB()
        CSResourceMgr.playAction(resNameS, 0, 10, false)
        transition.fadeTo(CSResourceMgr.getNodeByName(resNameS, "bg"), {opacity=128, time=0.5})
    end

    local funcTable = {loadCSB, playCSB}

    UnblockLoader.load(funcTable, "DialogBoxMgr_top")
end

function DialogBoxMgr.hideTopDialogBox(tag)
    if not tag or tag==tagS then
        UnblockLoader.cancel("DialogBoxMgr_top")
        if richLabelS then
            richLabelS:removeFromParent(true)
            richLabelS = nil
        end
        CSResourceMgr.removeCSObjectByTag(resNameS)
        GameAudio.playUISound("retract")
    end
end

return DialogBoxMgr