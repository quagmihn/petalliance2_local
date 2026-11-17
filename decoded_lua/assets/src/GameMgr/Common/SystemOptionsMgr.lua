local SystemOptionsMgr = {}

SystemOptionsMgr.DEFAULT_PLAYER_NUM = 10
SystemOptionsMgr.MAX_PLAYER_NUM = 50
SystemOptionsMgr.PUSH_KEY_VALUES = {"ExploreInfo", "GachaViewMgr", "ActionValueMax", "LostTowerStep", "SavePower", "TeamChest"}
SystemOptionsMgr.PUSH_SETTINGS = {}

local curScene = nil
local SettingMenu = {}
local resName = ""
local resNameA = ""
local curSettings = {}
local editbox = nil
local reSized = false
local curFrameInterval = 1/60.0 


function SystemOptionsMgr.setCurrentFps(val)
    cc.Director:getInstance():setAnimationInterval(val)
end

function SystemOptionsMgr.restoreCurrentFps()
    cc.Director:getInstance():setAnimationInterval(curFrameInterval)
end
--------------------------------
---设置省电模式
-- @function setPowerSavingMode 切换省电模式
-- @param val bool true --省电 --false不省电
function SystemOptionsMgr.setPowerSavingMode(val)
    curFrameInterval = 1/60.0
    if val == true then 
        curFrameInterval = 1/35.0 
    else
        curFrameInterval = 1/40.0
    end
    cc.Director:getInstance():setAnimationInterval(curFrameInterval)
end

function SystemOptionsMgr.Init()
    print("SystemOptionsMgr初始化")
    
    local settingVal = UserSettings.get("userPushSettings", 4)
    if settingVal==nil then
        for var=1, #SystemOptionsMgr.PUSH_KEY_VALUES do
            if var == 5 then 
                SystemOptionsMgr.PUSH_SETTINGS[var] = "close"
            else
                SystemOptionsMgr.PUSH_SETTINGS[var] = "open"
            end
        end
    else
        SystemOptionsMgr.PUSH_SETTINGS = settingVal
    end
    
    if SystemOptionsMgr.PUSH_SETTINGS[5] == "open" then
        SystemOptionsMgr.setPowerSavingMode(true)
    else
        SystemOptionsMgr.setPowerSavingMode(false)
    end
    
    curScene = nil
    SettingMenu = {"CharStatusBar", "ChatLayer", "MissionGuide", "MiniMap", "Music", "Sound"}
    resName = "UI/Settings/SettingViewNew.csb"
    CSResourceMgr.createRes(nil, resName, nil, true)
    resNameA = "UI/Settings/GiftCodeView.csb"
    curSettings = {}
    editbox = nil
end

function SystemOptionsMgr.show(scene)
    if CSResourceMgr.getCsbObj(resName) then
        return
    end
    curScene = scene
    curSettings = {}
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(25)
        curLayer:setVisible(false)
        CSResourceMgr.setFullScreen(resName)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CocosModuleMgr.setEdgeDistance(curLayer, nil, nil, nil, 0)

        if not reSized then
            local diff = CocosModuleMgr.getScreenSizeDiff()/2
            if diff < 0 then
                diff = 0
            end
            local db = CSResourceMgr.getNodeByName(resName, "diban")
            local dsize = db:getContentSize()
            db:setContentSize(dsize.width, dsize.height+diff)
            local title = CSResourceMgr.getNodeByName(resName, "title")
            local tposy = title:getPositionY()
            title:setPositionY(tposy+diff/2)     
            local close = CSResourceMgr.getNodeByName(resName, "close")
            local cposy = close:getPositionY()
            close:setPositionY(cposy+diff/2)
            local p1 = CSResourceMgr.getNodeByName(resName, "part1")
            local p1posy = p1:getPositionY()
            p1:setPositionY(p1posy+diff)
            local p2 = CSResourceMgr.getNodeByName(resName, "part2")
            local p2posy = p2:getPositionY()
            p2:setPositionY(p2posy+diff)
            local p3 = CSResourceMgr.getNodeByName(resName, "part3")
            local p3posy = p3:getPositionY()
            p3:setPositionY(p3posy+diff)
            local p4 = CSResourceMgr.getNodeByName(resName, "part4")
            local p4posy = p4:getPositionY()
            p4:setPositionY(p4posy+diff)
            local languageDiban = CSResourceMgr.getNodeByName(resName,"languageDiban")
            local lposy = languageDiban:getPositionY()
            languageDiban:setPositionY(lposy+diff/2) 
        	reSized = true
        end

        CSResourceMgr.setLabelColor(resName, "title", {r=160,g=235,b=250,a=255})
        CSResourceMgr.setLabelString(resName, "title", "SystemOption0", "", {r=37,g=54,b=75,a=255})

        local part1 = CSResourceMgr.getNodeByName(resName, "part1")
        local part1Title = CSResourceMgr.seekNodeByName(part1, "title1")
        CSResourceMgr.setLabelColorByNode(part1Title, {r=82,g=82,b=82,a=255})
        CSResourceMgr.setLabelStringByNode(part1Title, "SystemOption1", {r=236,g=236,b=236,a=255})
        local peopleNum = CSResourceMgr.seekNodeByName(part1, "peopleNum")
        CSResourceMgr.setLabelColorByNode(peopleNum, {r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(peopleNum, "SystemOption5", {r=0,g=0,b=0,a=255,w=1})
        local peopleNumSlider = CSResourceMgr.seekNodeByName(part1, "peopleNumSlider")
        peopleNumSlider:setPercent(math.floor((TownPlayerMgr.MAX_NUM-10)/(SystemOptionsMgr.MAX_PLAYER_NUM-10)*100))
        local Num = CSResourceMgr.seekNodeByName(part1, "Num")
        CSResourceMgr.setLabelColorByNode(Num, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(Num, TownPlayerMgr.MAX_NUM)
        local lookPetLabel = CSResourceMgr.seekNodeByName(part1, "lookPetLabel")
        CSResourceMgr.setLabelColorByNode(lookPetLabel, {r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(lookPetLabel, "SystemOption6", {r=0,g=0,b=0,a=255,w=1})
        peopleNumSlider:addEventListener(function(sender, state)
            local pNum = math.floor(peopleNumSlider:getPercent()/100*(SystemOptionsMgr.MAX_PLAYER_NUM-10))+10
            CSResourceMgr.setLabelStringByNode(Num, pNum)
            --显示人数
            curSettings.townMaxPlayerNum = pNum
            TownPlayerMgr.MAX_NUM = pNum
        end)
        if TownPlayerMgr.SHOW_PET=="show" then
            CSResourceMgr.seekNodeByName(part1, "lookPet"):setSelected(true)
        else
            CSResourceMgr.seekNodeByName(part1, "lookPet"):setSelected(false)
        end
        CSResourceMgr.seekNodeByName(part1, "lookPet"):addEventListener(function()
            local isselected = CSResourceMgr.seekNodeByName(part1, "lookPet"):isSelected()
            if isselected then
                print("显示宠物")
                GameAudio.playUISound("select1")
                TownPlayerMgr.SHOW_PET = "show"
                TownPlayerMgr.setPetVisible(true)
                curSettings.showPlayerPet = TownPlayerMgr.SHOW_PET
            else
                print("不显示宠物")
                GameAudio.playUISound("select1")
                TownPlayerMgr.SHOW_PET = "hide"
                TownPlayerMgr.setPetVisible(false)
                curSettings.showPlayerPet = TownPlayerMgr.SHOW_PET
            end
        end)

        local part2 = CSResourceMgr.getNodeByName(resName, "part2")
        local part2Title = CSResourceMgr.seekNodeByName(part2, "title2")
        CSResourceMgr.setLabelColorByNode(part2Title, {r=82,g=82,b=82,a=255})
        CSResourceMgr.setLabelStringByNode(part2Title, "SystemOption2", {r=236,g=236,b=236,a=255})
        local music = CSResourceMgr.seekNodeByName(part2, "music")
        CSResourceMgr.setLabelColorByNode(music, {r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(music, "SystemOption7", {r=0,g=0,b=0,a=255,w=1})
        local sfx = CSResourceMgr.seekNodeByName(part2, "sfx")
        CSResourceMgr.setLabelColorByNode(sfx, {r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(sfx, "SystemOption8", {r=0,g=0,b=0,a=255,w=1})
        local musicBack = CSResourceMgr.seekNodeByName(part2, "musicBack")
        local musicNumSlider = CSResourceMgr.seekNodeByName(musicBack, "musicNumSlider")
        local musicVol = UserSettings.get("musicVol", 4) or GameAudio.DEFAULT_MUSIC_VOLUME
        musicNumSlider:setPercent(musicVol)
        local Num2 = CSResourceMgr.seekNodeByName(musicBack, "Num")
        CSResourceMgr.setLabelColorByNode(Num2, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(Num2, musicNumSlider:getPercent().."%")
        local sfxBack = CSResourceMgr.seekNodeByName(part2, "sfxBack")
        local sfxNumSlider = CSResourceMgr.seekNodeByName(sfxBack, "sfxNumSlider")
        local soundVol = UserSettings.get("soundVol", 4) or GameAudio.DEFAULT_SOUND_VOLUME
        sfxNumSlider:setPercent(soundVol)
        local Num3 = CSResourceMgr.seekNodeByName(sfxBack, "Num")
        CSResourceMgr.setLabelColorByNode(Num3, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(Num3, sfxNumSlider:getPercent().."%")
        musicNumSlider:addEventListener(function(sender, state)
            CSResourceMgr.setLabelStringByNode(Num2, musicNumSlider:getPercent().."%")
            --音乐
            curSettings.musicVol = musicNumSlider:getPercent()
            GameAudio.setMusicVolume(musicNumSlider:getPercent())
        end)
        sfxNumSlider:addEventListener(function(sender, state)
            CSResourceMgr.setLabelStringByNode(Num3, sfxNumSlider:getPercent().."%")
            --音效
            curSettings.soundVol = sfxNumSlider:getPercent()
            GameAudio.setSoundsVolume(sfxNumSlider:getPercent())
        end)

        local filename = UserSettings.get("language", 4) or LuaSqlite.getDeviceLanguage()
        local langInfo = LuaSqlite.getLangInfoData()
        local langName = ""
        for key, var in pairs(langInfo) do
            if var.fileName==filename then
                langName = var.lang
        		break
        	end
        end
        local part3 = CSResourceMgr.getNodeByName(resName, "part3")
        local languageLabel = CSResourceMgr.seekNodeByName(part3, "languageLabel")
        CSResourceMgr.setLabelColorByNode(languageLabel, {r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(languageLabel, "SystemOption9", {r=0,g=0,b=0,a=255,w=1})
        local langOption = CSResourceMgr.seekNodeByName(part3, "langOption")
        CSResourceMgr.setLabelColorByNode(langOption, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(langOption, langName, {r=48,g=49,b=50,a=255,w=1})

        local language = CSResourceMgr.seekNodeByName(part3, "language")
        local languageBtn = CSResourceMgr.seekNodeByName(language, "back")
        CSResourceMgr.clickEventBindingByNode(languageBtn, function()
            GameAudio.playUISound("ok")
            SystemOptionsMgr.OpenLangList()
        end)

        local part4 = CSResourceMgr.getNodeByName(resName, "part4")
        local part4Title = CSResourceMgr.seekNodeByName(part4, "title4")
        CSResourceMgr.setLabelColorByNode(part4Title, {r=82,g=82,b=82,a=255})
        CSResourceMgr.setLabelStringByNode(part4Title, "SystemOption4", {r=236,g=236,b=236,a=255})
        for i=1, #SystemOptionsMgr.PUSH_KEY_VALUES do
            local b = CSResourceMgr.seekNodeByName(part4, "b")
            local infoLabel_Copy = CSResourceMgr.seekNodeByName(b, "infoLabel_Copy_"..i)
            infoLabel_Copy:setVisible(true)
            CSResourceMgr.setLabelColorByNode(infoLabel_Copy, {r=144,g=238,b=255,a=255})
            CSResourceMgr.setLabelStringByNode(infoLabel_Copy, "MainSetting"..i, {r=0,g=0,b=0,a=255,w=1},nil,150)
            --推送开关
            local info_Copy = CSResourceMgr.seekNodeByName(b, "info_Copy_"..i)
            if SystemOptionsMgr.PUSH_SETTINGS[i]=="open" then
                info_Copy:setSelected(true)
            else
                info_Copy:setSelected(false)
            end
            info_Copy:setVisible(true)
            info_Copy:addEventListener(function()
                local isselected = info_Copy:isSelected()
                if isselected then
                    print("YES"..i)
                    GameAudio.playUISound("select1")
                    SystemOptionsMgr.PUSH_SETTINGS[i] = "open"
                    curSettings.userPushSettings = SystemOptionsMgr.PUSH_SETTINGS
                    if i == 5 then 
                        SystemOptionsMgr.setPowerSavingMode(true)
                    end
                else
                    print("NO"..i)
                    GameAudio.playUISound("select1")
                    SystemOptionsMgr.PUSH_SETTINGS[i] = "close"
                    curSettings.userPushSettings = SystemOptionsMgr.PUSH_SETTINGS
                    if i == 5 then
                        SystemOptionsMgr.setPowerSavingMode(false)
                    else
                        BaseFunction.cancelLocalNotificationWithKey(i)
                    end
                end
            end)
        end

        for i=1, 2 do
            local button = CSResourceMgr.getNodeByName(resName, "Button"..i)
            CSResourceMgr.setButtonStringByNode(button, "SystemOption"..(10+i), {r=0,g=0,b=0,a=255})
            CSResourceMgr.setButtonStringColorByNode(button, {r=227,g=233,b=255,a=255})
        end

        CSResourceMgr.clickEventBinding(resName, "Button1", function()
            GameAudio.playUISound("ok")
            DialogBoxMgr.showSmallDialogBox(scene, 2, "login39", function()
                UserSettings.set(curSettings, 4)
                LoginViewMgr.gameReInit()
            end)
        end)
        CSResourceMgr.clickEventBinding(resName, "Button2", function()
            GameAudio.playUISound("ok")
            SystemOptionsMgr.showGiftCodeView(scene)
        end)

        CSResourceMgr.clickEventBinding(resName, "close", function()
            SystemOptionsMgr.hide()
        end)

        --IOS审核时，隐藏礼品码
        if device.platform == "ios" and iOSFunction.isReviewVer() then
            CSResourceMgr.getNodeByName(resName, "Button1"):setPositionX(303.5)
            CSResourceMgr.getNodeByName(resName, "Button2"):setVisible(false)
        end
            
        if device.platform == "ios" then
            -- ios 审核隐藏语言切换
            local part3 = CSResourceMgr.getNodeByName(resName, "part3")
            CSResourceMgr.seekNodeByName(part3, "languageLabel"):setVisible(false)
            CSResourceMgr.seekNodeByName(part3, "langOption"):setVisible(false)
            CSResourceMgr.seekNodeByName(part3, "language"):setVisible(false)
        end
    end

    local function playCSB()
        CSResourceMgr.getCsbObj(resName):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resName), "up")
    end
    local funcTable = {loadCSB, playCSB}

    UnblockLoader.load(funcTable, "SystemOptionsMgr")
end

function SystemOptionsMgr.OpenLangList()
    local list = CSResourceMgr.getNodeByName(resName,"list")
    local languageDiban = CSResourceMgr.getNodeByName(resName,"languageDiban")
    local languageBack = CSResourceMgr.getNodeByName(resName,"languageBack")
    languageDiban:setLocalZOrder(5)
    languageBack:setLocalZOrder(4)
    languageDiban:setVisible(true)
    languageBack:setVisible(true)
    languageDiban:setScale(0,0)
    transition.scaleTo(languageDiban, {scale = 1, time = 0.1})

    local function closeLangList()
        transition.scaleTo(languageDiban, {scale = 0, time = 0.1})
        languageDiban:performWithDelay(function()
            languageDiban:setVisible(false)
            languageBack:setVisible(false)
            if list then
                list:removeAllItems()
            end
        end,0.1)
    end

    CSResourceMgr.clickEventBinding(resName, "languageBack", function()
        closeLangList()
    end)

    local langInfoData = LuaSqlite.getLangInfoData()

    local function setLang(name, filename)
        local lang = CSResourceMgr.getNodeByName(resName, "lang"):clone()
        lang:setVisible(true)
        CSResourceMgr.setButtonStringColorByNode(lang, {r=217,g=234,b=255,a=255})
        CSResourceMgr.setButtonStringByNode(lang, name, {r=17,g=17,b=16,a=255})
        list:pushBackCustomItem(lang)

        CSResourceMgr.clickEventBindingByNode(lang, function()
            CSResourceMgr.setButtonTextureByNode(lang, "UI/CommonFiles/tower_transfer_label_selected_su.png", 
                 "UI/CommonFiles/tower_transfer_label_selected_su.png",  "UI/CommonFiles/tower_transfer_label_selected_su.png")
            CSResourceMgr.setButtonStringColorByNode(lang, {r=255,g=252,b=0,a=255})
            lang:performWithDelay(function()
                closeLangList()
            end,0.2)
            --切换语言
            DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, CocosModuleMgr.createStringWithFormat({"login36", name}), function()
                curSettings.language = filename
                UserSettings.set(curSettings, 4)
                LoginViewMgr.gameReInit()
            end)
        end)
    end
    for k,v in pairs(langInfoData) do
        setLang(v.lang, v.fileName)
    end
end

function SystemOptionsMgr.showGiftCodeView(scene)
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resNameA)
        curLayer:setLocalZOrder(26)
        CSResourceMgr.setRelativePosition(resNameA, 320, 480)

        local title = CSResourceMgr.getNodeByName(resNameA, "title")
        CSResourceMgr.setLabelColorByNode(title, {r=255,g=255,b=83,a=255})
        CSResourceMgr.setLabelStringByNode(title, "GiftCode0", {r=114,g=28,b=11,a=255})
        local Button_Cancel = CSResourceMgr.getNodeByName(resNameA, "Button_Cancel")
        CSResourceMgr.setButtonStringColorByNode(Button_Cancel, {r=227,g=233,b=255,a=255})
        CSResourceMgr.setButtonStringByNode(Button_Cancel, "GiftCode1", {r=0,g=0,b=0,a=255})
        local Button_Confirm = CSResourceMgr.getNodeByName(resNameA, "Button_Confirm")
        CSResourceMgr.setButtonStringColorByNode(Button_Confirm, {r=227,g=233,b=255,a=255})
        CSResourceMgr.setButtonStringByNode(Button_Confirm, "GiftCode2", {r=0,g=0,b=0,a=255})
        local tipsLabel = CSResourceMgr.getNodeByName(resNameA, "tipsLabel")
        CSResourceMgr.setLabelColorByNode(tipsLabel, {r=132,g=160,b=201,a=255})
        CSResourceMgr.setLabelStringByNode(tipsLabel, "GiftCode7", {r=0,g=0,b=0,a=255,w=1})

        editbox = CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resNameA, "diban"), "empty", 
            350, 30, 260, 193, TownChatMgr.LABEL_FONT_SIZE+4, TownChatMgr.MAX_WORD_SIZE, "GiftCode3",nil,nil,false)

        CSResourceMgr.clickEventBindingByNode(Button_Cancel, function()
            GameAudio.playUISound("back")
            UnblockLoader.cancel("SystemOptionsMgr.showGiftCodeView")
            CSResourceMgr.removeCSObjectByTag(resNameA)
        end)
        CSResourceMgr.clickEventBindingByNode(Button_Confirm, function()
            local text = editbox:getText()
            if text ~= "" then
                NetInterface.sendWithBlock("GC_UseActivateCode_Ack", function()
                    local ActivateCodeSend = require("src.Net.Send.ActivateCodeSend")
                    ActivateCodeSend.sendCG_UseActivateCode_Req({strCode = text})
                end,function()
                    GameAudio.playUISound("success")
                    TipsMgr.show(scene, "GiftCode4")
                    UnblockLoader.cancel("SystemOptionsMgr.showGiftCodeView")
                    CSResourceMgr.removeCSObjectByTag(resNameA)
                end,function(code)
                    editbox:setText("")
                    if code == Proto.Error.ERROR_ACTIVATE_CODE_USED then
                        StandardTipsMgr.show(1, "GiftCode5")
                    elseif code == Proto.Error.ERROR_INVALID_ACTIVATE_CODE then
                        StandardTipsMgr.show(1, "GiftCode6")
                    elseif code == Proto.Error.ERROR_ACTIVATE_CODE_LIMIT then
                        StandardTipsMgr.show(1, "GiftCode8")
                    elseif code == Proto.Error.ERROR_ACTIVATE_CODE_CHANNEL then
                        StandardTipsMgr.show(1, "GiftCode9")
                    end
                end)
            end
        end)
    end

    local function playCSB()
        CSResourceMgr.playAction(resNameA, 0, 5, false)
    end
    local funcTable = {loadCSB, playCSB}

    UnblockLoader.load(funcTable, "SystemOptionsMgr.showGiftCodeView")
end

function SystemOptionsMgr.hide()
    UserSettings.set(curSettings, 4)
    curSettings = {}
    UnblockLoader.cancel("SystemOptionsMgr")
    CSResourceMgr.removeCSObjectByTag(resName)
    GameAudio.playUISound("retract")
end

--1.CharStatusBar 2.ChatLayer 3.MissionGuide 4.MiniMap 5.Music 6.Sound
function SystemOptionsMgr.setOption(type, boolVal)
    local tbl = {}
    tbl[SettingMenu[type]] = boolVal
    UserSettings.set(tbl, 4)
end

function SystemOptionsMgr.getOption(type)
    local isOpen = UserSettings.get(SettingMenu[type], 4)
    if type==1 then
        if isOpen==nil then
            isOpen = false
        end
    else
        if isOpen==nil then
            isOpen = true
        end
    end
    return isOpen
end

return SystemOptionsMgr