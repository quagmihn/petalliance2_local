local HomeMenuMgr = {}

local resName = ""
local isMenuShow = true
local menuTag = {}
local menuText = {}
local menuString = {}
local isMenuNew = {}
local newMsgNum = 0
local IsInGameGuide = false

function HomeMenuMgr.Init()
    print("HomeMenuMgr初始化")
    
    resName = "Charactor/Menu/HomeMenu.csb"
    isMenuShow = true
    menuTag = {"BtnFamily", "BtnLayout", "BtnExpand", "BtnLife", "BtnExit", "BtnHome"}
    menuText = {"TextFamily", "TextLayout", "TextExpand", "TextLife", "TextExit", "TextHome"}
    menuString = {"menu14", "family123", "family124", "bag4", "family125", "menu4"}
    isMenuNew = {false, false, false, false, false, false}
    newMsgNum = 0
    IsInGameGuide = false
end

function HomeMenuMgr.SetInGameGuide(isInGameGuide)
    IsInGameGuide = isInGameGuide
end

function HomeMenuMgr.RemoveChatUI()
    TownChatMgr.showChatView(false)
    BasicMenuMgr.setChatBtnEnable(true)
end

function HomeMenuMgr.addBasicMenu(scene)
    local function loadCsb()
        local layer = CSResourceMgr.createRes(scene, resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_BAR)
        CocosModuleMgr.setRelativePosition(layer, 320, 480)
        CocosModuleMgr.setEdgeDistance(layer, nil, nil, nil, 0, false)
        
        CSResourceMgr.clickEventBinding(resName, menuTag[1], function()
            if CharInfo.getFamilyID() == nil then --没家族
                FamilyListViewMgr.show(scene)
            else --有家族
                MyFamilyLstViewMgr.show(scene)
            end
        end, "", true)
        local unlockLevel = SystemInfo.getGlobalConfigAddInfoByID(24005).values[1]
        CSResourceMgr.setButtonEnabled(resName, menuTag[1], CharInfo.getLevel() >= unlockLevel)
        
        
        CSResourceMgr.clickEventBinding(resName, menuTag[2], function()
            if HomeInfo.GetCurrentHomeCharID() == CharInfo.getCharID() then
                FurnitureViewMgr.request(scene)
            end
        end, "", true)
        CSResourceMgr.getNodeByName(resName, menuTag[2]):getParent():setVisible(HomeInfo.GetCurrentHomeCharID() == CharInfo.getCharID())
        
        
        CSResourceMgr.clickEventBinding(resName, menuTag[3], function()
            if HomeInfo.GetCurrentHomeCharID() == CharInfo.getCharID() then
                if FurnitureViewMgr.GetOwnerExpandLevel() < 4 then
                    local cost = SystemInfo.getGlobalConfigAddInfoByID(51).values[FurnitureViewMgr.GetOwnerExpandLevel()]
                    --阿杜修改英文版显示
                    local str = CocosModuleMgr.createStringWithFormat({"home001", 
                        CocosModuleMgr.createStringWithFormat({"<1><2>", cost, "tips17"})})
                    if LuaSqlite.LANG_TYPE ~= 1 then
                        str = CocosModuleMgr.createStringWithFormat({"home001", cost})
                    end
                    DialogBoxMgr.showSmallDialogBox(self, 2, str, function()
                        GameAudio.playUISound("success")
                        if cost <= CharInfo.getMCash() then
                            HomeInfo.BuyHome()
                        else
                            StandardTipsMgr.show(1, "egg27")
                        end
                    end)
                else
                    StandardTipsMgr.show(1, "home002")
                end
            end
        end, "", true)
        CSResourceMgr.getNodeByName(resName, menuTag[3]):getParent():setVisible(HomeInfo.GetCurrentHomeCharID() == CharInfo.getCharID())
        
        CSResourceMgr.clickEventBinding(resName, menuTag[4], function()
            LifeSkillSelViewMgr.request(scene)
        end, "", true)
        
        CSResourceMgr.clickEventBinding(resName, menuTag[5], function()
            GameAudio.playUISound("homeEnd")
            if IsInGameGuide ~= true then
                --SceneMgr.mapEnterType = 99
                SceneMgr.replaceScene(self, "MainScene")
            else
                SceneMgr.mapEnterType = 99
                SceneMgr.replaceScene(self, "TownScene")
                IsInGameGuide = false
            end
            TownMapMgr.setPetScale(0.5)
            TownMapMgr.setPlayerScale(0.7)
            TownMapMgr.Pet:setLocalZOrder(CocosModuleMgr.ZORDER_PLAYER)
            TownMapMgr.Pet:setScale(TownMapMgr.DEFAULT_PET_SCALE, TownMapMgr.DEFAULT_PET_SCALE)
            TownMapMgr.Player:setLocalZOrder(CocosModuleMgr.ZORDER_PLAYER)
        end, "", true)
        
        CSResourceMgr.clickEventBinding(resName, menuTag[6], function()
            GameAudio.playUISound("homeEnter")
            TownMapMgr.resetPosition()
            FurnitureViewMgr.goSpecifyFloor(CharInfo.getCharID())
        end, "", true)
        CSResourceMgr.getNodeByName(resName, menuTag[6]):getParent():setVisible(HomeInfo.GetCurrentHomeCharID() ~= CharInfo.getCharID())
        
        local chatBubble = CSResourceMgr.getNodeByName(resName, "chat")
        TownChatMgr.addChatIcon(chatBubble)
    end
    
    local function playCsb()
        CSResourceMgr.playAction(resName, 0, 10, false)
        for var=1, #menuText do
            if isMenuNew[var]==true then
                BasicMenuMgr.addRedPoint(var)
            end
        end
    end
    
    local function InitMenuButton()
        for var=1, #menuText do
            CSResourceMgr.getNodeByName(resName, menuTag[var]):setScale(0.9)
            CSResourceMgr.getNodeByName(resName, menuText[var]):setScale(0.8)
            CSResourceMgr.setLabelString(resName, menuText[var], menuString[var], nil, {r=0,g=0,b=0,a=255,w=2})
        end
    end
    
    local funcTable = {loadCsb, playCsb, InitMenuButton}
    UnblockLoader.load(funcTable, "HomeMenuMgr.addBasicMenu")
    isMenuShow = true
end

function HomeMenuMgr.resetMenu()
    CSResourceMgr.getNodeByName(resName, menuTag[2]):getParent():setVisible(HomeInfo.GetCurrentHomeCharID() == CharInfo.getCharID())
    CSResourceMgr.getNodeByName(resName, menuTag[3]):getParent():setVisible(HomeInfo.GetCurrentHomeCharID() == CharInfo.getCharID())
    CSResourceMgr.getNodeByName(resName, menuTag[6]):getParent():setVisible(HomeInfo.GetCurrentHomeCharID() ~= CharInfo.getCharID())
end

function HomeMenuMgr.showFlash(callback1, callback2)
    local flash = CSResourceMgr.getNodeByName(resName, "flash")
    flash:setVisible(true)
    flash:setOpacity(255)
    flash:performWithDelay(function()
        if callback1 then callback1() end
        transition.fadeOut(flash, {time=0.1})
        flash:performWithDelay(function()
            flash:setVisible(false)
            if callback2 then callback2() end
        end,0.1)
    end,0.2)
end

function HomeMenuMgr.setVisible(val)
    local function setVisible(res)
        local layer = CSResourceMgr.getCsbObj(res)
        if layer then
            layer:setVisible(val)
        end
    end
    setVisible(resName)
end

return HomeMenuMgr