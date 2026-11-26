local BasicMenuMgr = {}

local resName = ""
local isMenuShow = true
local menuTag = {}
local menuText = {}
local menuColor = {}
local isMenuNew = {}
BasicMenuMgr.NEWMSGNUM = 0
local lockInfo = {}

function BasicMenuMgr.Init()
    print("BasicMenuMgr初始化")
    
    resName = "Charactor/Menu/MainMenu.csb"
    CSResourceMgr.createRes(nil, resName, nil, true)
    
    isMenuShow = true
    menuTag = {"b1", "b2", "b3", "b4", "b5"}
    menuText = {"t1", "t2", "t3", "t4", "t5"}
    menuColor = {{r=95,g=130,b=153,a=255}, {r=255,g=234,b=125,a=255}, {r=255,g=127,b=130,a=255}, 
        {r=164,g=254,b=255,a=255}, {r=192,g=255,b=148,a=255}}
    isMenuNew = {false, false, false, false}
    BasicMenuMgr.NEWMSGNUM = 0
    local lockid = {21004, 21002, 21008, 21007, 21000}
    for var=1, #lockid do
        local val = SystemInfo.getGlobalConfigAddInfoByID(lockid[var]).values[1]
        lockInfo[var] = val
    end
end

function BasicMenuMgr.addBasicMenu(scene)
    local function loadCsb()
        local layer = CSResourceMgr.createRes(scene, resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_BAR)
        CocosModuleMgr.setRelativePosition(layer, 320, 480)
        CocosModuleMgr.setEdgeDistance(layer, nil, nil, nil, 0, false)

        PetListMgr.preLoad(scene)

        local isTouch = false
        local function touchFunc(i)
            local textName = i==5 and "UI/CommonFiles/anniu2.png" or "UI/CommonFiles/anniu5.png"
            CSResourceMgr.setSpriteTexture(resName, "bb"..i, textName)
            local btn = CSResourceMgr.getNodeByName(resName,menuTag[i])
            transition.scaleTo(btn, {scale = i==5 and 1.17 or 1.3, time = 0.1})
            transition.moveBy(btn, {y = 40, time = 0.1})
            isTouch = true
            btn:performWithDelay(function()
                transition.moveBy(btn, {y = -20, time = 0.1})
            end, 0.1)
        end
        local function cancelFunc(i)
            local textName = i==5 and "UI/CommonFiles/anniu1.png" or "UI/CommonFiles/anniu4.png"
            CSResourceMgr.setSpriteTexture(resName, "bb"..i, textName)
            local btn = CSResourceMgr.getNodeByName(resName,menuTag[i])
            transition.scaleTo(btn, {scale = i==5 and 0.9 or 1, time = 0.1})
            if isTouch then 
                transition.moveBy(btn, {y = -20, time = 0.1})
                isTouch = false
            end
        end

        for var=1, #menuText do
            CSResourceMgr.buttonEventBinding(resName, menuTag[var], function()
                touchFunc(var)
            end, function()
                if var==1 then
                    PetFormationMgr.show(scene, function ()
                        BasicMenuMgr.setPetEductionRedPoint()
                    end)
                elseif var==2 then
                    BagViewMgr.request(scene)
                    BasicMenuMgr.hideRedPoint(2)
                elseif var==3 then
                    ExploreViewMgr.show(scene)
                elseif var==4 then
                    FamilyInfo.GoHome()
                    BasicMenuMgr.hideRedPoint(4)
                elseif var==5 then
                    if SceneMgr.currentScene=="MainScene" then
                        SceneMgr.mapEnterType = 99
                        SceneMgr.replaceScene(scene, "TownScene")
                        BasicMenuMgr.setChatRedPoint(false)
                    else
                        SceneMgr.replaceScene(scene, "MainScene")
                    end
                    BasicMenuMgr.hideRedPoint(5)
                end
                if var==4 then
                    GameAudio.playUISound("homeEnter")
                else
                    GameAudio.playUISound("popup")
                end
                cancelFunc(var)
            end, nil, function()
                cancelFunc(var)
            end)
        end
        
        for var=1, #menuText-1 do
            if var ~= 4 then
                CSResourceMgr.setLabelString(resName, menuText[var], "menu"..var, nil, {r=0,g=0,b=0,a=255})
            else
                CSResourceMgr.setLabelString(resName, menuText[var], "menu"..(CharInfo.getFamilyID() == nil and var or 14), 
                    nil, {r=0,g=0,b=0,a=255})
            end
        end
        if SceneMgr.currentScene=="MainScene" then
            CSResourceMgr.setButtonTexture(resName, menuTag[5], "UI/CommonFiles/jincheng_icon.png", 
                "UI/CommonFiles/jincheng_icon.png", "UI/CommonFiles/jincheng_icon.png")
            CSResourceMgr.setLabelString(resName, menuText[5], "menu6", nil, {r=0,g=0,b=0,a=255}, nil, 160)
        else
            CSResourceMgr.setButtonTexture(resName, menuTag[5], "UI/CommonFiles/chucheng_icon.png", 
                "UI/CommonFiles/chucheng_icon.png", "UI/CommonFiles/chucheng_icon0.png")
            CSResourceMgr.setLabelString(resName, menuText[5], "menu5", nil, {r=0,g=0,b=0,a=255}, nil, 160)
        end
        
        if LostTowerInfo.checkLTActivity() and ExploreViewMgr.SHOW_ACTVT_RP then
            isMenuNew[3] = true
        end

        --检测是否添加碎片红点
        if BagViewMgr.ADDREDPOINT then
            BasicMenuMgr.addRedPoint(2,true)
        end
    end
    
    local function playCsb()
        CSResourceMgr.playAction(resName, 0, 10, false)
        for var=1, #menuText do
            if isMenuNew[var]==true then
                BasicMenuMgr.addRedPoint(var, true)
            end
        end
        BasicMenuMgr.checkMapLockInfo()
        local node = CSResourceMgr.getNodeByName(resName,"chatNode")
        TownChatMgr.addChatIcon(node)

        --聊天红点专用！！！
        if BasicMenuMgr.NEWMSGNUM>0 and SceneMgr.currentScene=="MainScene" then
            BasicMenuMgr.NEWMSGNUM = BasicMenuMgr.NEWMSGNUM - 1
            BasicMenuMgr.setChatRedPoint(true)
        end
    end

    local funcTable = {loadCsb, playCsb}
    UnblockLoader.load(funcTable, "BasicMenuMgr.addBasicMenu")
    isMenuShow = true
end

function BasicMenuMgr.setChatBtnEnable(enabled)
    local node = CSResourceMgr.getNodeByName("UI/Chat/ChatIcon.csb", "chat")
    if node then
        node:setVisible(enabled)
    end
end

function BasicMenuMgr.show()
    if isMenuShow then
    	return 
    end
    CSResourceMgr.playAction(resName, 0, 10, false)
    if SceneMgr.currentScene=="MainScene" then
        BasicMenuMgr.setChatBtnEnable(true)
    end
    isMenuShow = true
end

function BasicMenuMgr.hide()
    if not isMenuShow then
        return 
    end
    if SceneMgr.currentScene=="MainScene" then
        TownChatMgr.changeStatus(2)
    end
    CSResourceMgr.playActionWithCallback(resName, 30, 40, 1, function()
        BasicMenuMgr.setChatBtnEnable(false)
    end, "", 0.1)
    -- CSResourceMgr.playAction(resName, 30, 40, false)
    isMenuShow = false
end

function BasicMenuMgr.setChatRedPoint(enabled)
    if not CSResourceMgr.getCsbObj("UI/Chat/ChatIcon.csb") then
    	return
    end
    local chatNode = CSResourceMgr.getNodeByName("UI/Chat/ChatIcon.csb", "chat")
    local redPoint = CSResourceMgr.seekNodeByName(chatNode, "redPoint")
    local num = CSResourceMgr.seekNodeByName(chatNode, "num")
    if enabled then
        BasicMenuMgr.NEWMSGNUM = BasicMenuMgr.NEWMSGNUM + 1
        if BasicMenuMgr.NEWMSGNUM<100 then
            CSResourceMgr.setLabelStringByNode(num, BasicMenuMgr.NEWMSGNUM)
        else
            CSResourceMgr.setLabelStringByNode(num, "99+")
        end
    else
        BasicMenuMgr.NEWMSGNUM = 0
    end
    redPoint:setVisible(enabled)
end

function BasicMenuMgr.addRedPoint(type, boolFirst)
    if isMenuNew[type]==true and not boolFirst then
    	return
    end
    local button = CSResourceMgr.getNodeByName(resName, menuTag[type])
    if button then
        if button:isTouchEnabled() or (BagViewMgr.ADDREDPOINT and type == 2) then
            isMenuNew[type] = true
            CocosModuleMgr.showShiningToNode(button, 4)
        end
    end
end

function BasicMenuMgr.hideRedPoint(type)
    isMenuNew[type] = false
    CocosModuleMgr.hideShiningToNode(CSResourceMgr.getNodeByName(resName, menuTag[type]))
end

function BasicMenuMgr.checkMapLockInfo(boolAnimate)
    if not CSResourceMgr.getCsbObj(resName) then
    	return
    end
    if boolAnimate==nil then
    	boolAnimate = false
    end
    for var=1, #lockInfo do
        local charLock = CharInfo.get().maplock
        if var==4 then
            charLock = CharInfo.getLevel()
        end
        --print("BasicMenuMgr.checkMapLockInfo", charLock, lockInfo[var])
        local accessible = CharInfo.get().local_freedom == true or charLock >= lockInfo[var]
        if accessible then
            if boolAnimate then
                --CocosModuleMgr.showUnlockAnimation(CSResourceMgr.getNodeByName(resName, menuTag[var]))
            else
                local textName = var==5 and "UI/CommonFiles/anniu1.png" or "UI/CommonFiles/anniu4.png"
                CSResourceMgr.setButtonEnabled(resName, menuTag[var], true)
                CSResourceMgr.setSpriteTexture(resName, "bb"..var, textName)
            end
            CSResourceMgr.getNodeByName(resName, menuText[var]):setVisible(true)
        else
            local textName = var==5 and "UI/CommonFiles/anniu3.png" or "UI/CommonFiles/anniu6.png"
            CSResourceMgr.setButtonEnabled(resName, menuTag[var], false)
            CSResourceMgr.setSpriteTexture(resName, "bb"..var, textName)
            CSResourceMgr.getNodeByName(resName, menuText[var]):setVisible(false)
        end
        --新加解锁TIPS
        local btn = CSResourceMgr.getNodeByName(resName,menuTag[var])
        local tipsBtn = CSResourceMgr.seekNodeByName(btn,"UnLockTipsBtn")
        tipsBtn:setVisible(not accessible)
        CSResourceMgr.clickEventBindingByNode(tipsBtn, function()
            DialogBoxMgr.showSmallDialogBox(self, 1, LuaSqlite.getLanguageByKey("unlockTips10"..var))
        end)
    end
end

function BasicMenuMgr.setVisible(val)
    local function setVisible(res)
        local layer = CSResourceMgr.getCsbObj(res)
        if layer then
            layer:setVisible(val)
        end
    end
    setVisible(resName)
end

function BasicMenuMgr.setPetEductionRedPoint()
    if CSResourceMgr.getCsbObj(resName) == nil then
        return
    end
    local armyObjIDs = clone(PokemonInfo.getPetArmy(PetFormationMgr.getCurTab()))
    for k,v in pairs(PokemonInfo.getPetHelpArmy()) do
        table.insert(armyObjIDs, v)
    end
    for k,v in pairs(armyObjIDs) do
        local petInfo = PokemonInfo.getPetInfoByObjID(v)
        if PetEducationMgr.getRedPointStateByPetInfo(petInfo) == true then
            BasicMenuMgr.addRedPoint(1, true)
            return
        end
    end
    BasicMenuMgr.hideRedPoint(1)
end

return BasicMenuMgr