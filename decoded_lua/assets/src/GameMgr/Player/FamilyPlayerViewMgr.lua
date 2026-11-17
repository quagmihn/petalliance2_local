local FamilyPlayerViewMgr = {}

local resName = ""

function FamilyPlayerViewMgr.Init()
    resName = "Player/Family/FamilyPlayerView.csb"
end

function FamilyPlayerViewMgr.hideUI()
    GameAudio.playUISound("back")
    UnblockLoader.cancel("FamilyPlayerViewMgr")
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("FamilyPlayerViewMgr")
end

local function viewPlayerInfo(charID)
    PersonalCenterMgr.show(SceneMgr.getRunningScene,charID)
end

local function setPlayer2Elder(charID)
    FamilyInfo.ModifyFamilyAccessElder(charID) 
end

local function setPlayer2Master(charID)
    FamilyInfo.ModifyFamilyAccessMaster(charID) 
end

local function setPlayer2Member(charID)
    FamilyInfo.ModifyFamilyAccessMember(charID) 
end

local function kickPlayer(charID, charName)
    FamilyInfo.KickFamilyMember(charID, charName)
end

function FamilyPlayerViewMgr.show(scene, charID, charName)
    --print("@@@@@@@@@@@@@@@@@@@@@@FamilyPlayerViewMgr.show")
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end
    GameAudio.playUISound("ok")
    UIStack.push("FamilyPlayerViewMgr",FamilyPlayerViewMgr.hideUI,false)
    local jobSelf = FamilyInfo.GetJobByMemberID(CharInfo.getCharID())
    local jobChar = FamilyInfo.GetJobByMemberID(charID)
    --print("!!!!!!!FamilyPlayerViewMgr jobSelf="..tostring(jobSelf).." jobChar="..tostring(jobChar))

    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)

        CSResourceMgr.clickEventBinding(resName, "close", function()
            FamilyPlayerViewMgr.hideUI()
        end)
        
        CSResourceMgr.setButtonString(resName, "btn_viewplayer", "family60")
        CSResourceMgr.setButtonString(resName, "btn_setjob", "family61")
        CSResourceMgr.setButtonString(resName, "btn_kick", "family62")
        CSResourceMgr.setButtonString(resName, "btn_addfriend", "friendList11")
        
        CSResourceMgr.clickEventBinding(resName, "btn_viewplayer", function()
            viewPlayerInfo(charID)
            FamilyPlayerViewMgr.hideUI()
        end)
        
        local submenu = CSResourceMgr.getNodeByName(resName, "submenu")
        submenu:setScale(0, 0)
        CSResourceMgr.clickEventBinding(resName, "bg", function()
            if submenu:isVisible() == true then
                if submenu:getScaleX() > 0 then
                    transition.scaleTo(submenu, {scale = 0, time = 0.1})
                else
                    FamilyPlayerViewMgr.hideUI()
                end
            else
                FamilyPlayerViewMgr.hideUI()
            end
        end)
        
        local menu_num = 4
        
        if jobChar <= jobSelf or jobSelf >= FamilyInfo.JobType.Job_Master or charID == CharInfo.getCharID() then
            CSResourceMgr.getNodeByName(resName, "btn_setjob"):setVisible(false)
            menu_num = menu_num - 1
        else
            if jobSelf == FamilyInfo.JobType.Job_Elder then
                CSResourceMgr.setButtonEnabled(resName, "btn_job1", false)
            end
        end
        CSResourceMgr.clickEventBinding(resName, "btn_setjob", function()
            submenu:setVisible(true)
            if submenu:getScaleX() == 0 then
                transition.scaleTo(submenu, {scale = 1, time = 0.1})
            else
                transition.scaleTo(submenu, {scale = 0, time = 0.1})
            end
        end)
        CSResourceMgr.setButtonString(resName, "btn_job1", "family32", nil, {r=0,g=0,b=0,a=255,w=1})
        CSResourceMgr.clickEventBinding(resName, "btn_job1", function()
            setPlayer2Elder(charID)
            FamilyPlayerViewMgr.hideUI()
        end)
        CSResourceMgr.setButtonString(resName, "btn_job2", "family126", nil, {r=0,g=0,b=0,a=255,w=1})
        CSResourceMgr.clickEventBinding(resName, "btn_job2", function()
            setPlayer2Master(charID)
            FamilyPlayerViewMgr.hideUI()
        end)
        CSResourceMgr.setButtonString(resName, "btn_job3", "family127", nil, {r=0,g=0,b=0,a=255,w=1})
        CSResourceMgr.clickEventBinding(resName, "btn_job3", function()
            setPlayer2Member(charID)
            FamilyPlayerViewMgr.hideUI()
        end)
        
        if jobChar <= jobSelf or charID == CharInfo.getCharID() then
            CSResourceMgr.getNodeByName(resName, "btn_kick"):setVisible(false)
            menu_num = menu_num - 1
            if menu_num == 2 then
                CSResourceMgr.getNodeByName(resName, "btn_addfriend"):setPositionY(CSResourceMgr.getNodeByName(resName, "btn_setjob"):getPositionY())
            elseif menu_num == 3 then
                CSResourceMgr.getNodeByName(resName, "btn_addfriend"):setPositionY(CSResourceMgr.getNodeByName(resName, "btn_kick"):getPositionY())
            end
        else
            if menu_num == 3 then
                CSResourceMgr.getNodeByName(resName, "btn_addfriend"):setPositionY(CSResourceMgr.getNodeByName(resName, "btn_kick"):getPositionY())
                CSResourceMgr.getNodeByName(resName, "btn_kick"):setPositionY(CSResourceMgr.getNodeByName(resName, "btn_setjob"):getPositionY())
            end
        end
        CSResourceMgr.clickEventBinding(resName, "btn_kick", function()
            kickPlayer(charID, charName)
            FamilyPlayerViewMgr.hideUI()
        end)
        
        if TownChatMgr.isHaveFriend({friendID = charID}) or charID == CharInfo.getCharID() then
            CSResourceMgr.getNodeByName(resName, "btn_addfriend"):setVisible(false)
            menu_num = menu_num - 1
        end
        CSResourceMgr.clickEventBinding(resName, "btn_addfriend", function()
            FriendsViewMgr.AddFriend(charID)
            FamilyPlayerViewMgr.hideUI()
        end)
        
        if menu_num < 4 then
            local offset = CSResourceMgr.getNodeByName(resName, "btn_setjob"):getContentSize().height
            local space = (CSResourceMgr.getNodeByName(resName, "btn_viewplayer"):getPositionY() - CSResourceMgr.getNodeByName(resName, "btn_setjob"):getPositionY() - offset) * (4 - menu_num)
            local back = CSResourceMgr.getNodeByName(resName, "back")
            local backsize = back:getContentSize()
            back:setContentSize(backsize.width, backsize.height - (4 - menu_num) * offset - space)
            local diban = CSResourceMgr.getNodeByName(resName, "diban")
            local dibansize = diban:getContentSize()
            diban:setContentSize(dibansize.width, dibansize.height - (4 - menu_num) * offset - space)
            local bg = CSResourceMgr.getNodeByName(resName, "bg1")
            local bgsize = bg:getContentSize()
            bg:setContentSize(bgsize.width, bgsize.height - (4 - menu_num) * offset - space)
        end
        
        CSResourceMgr.setLabelString(resName, "txt_title", charName or "", nil, {r=0,g=0,b=0,a=255,w=1})
        --[[
        local name_bg = CSResourceMgr.getNodeByName(resName, "name_bg")
        local name_input = CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resName, "db"), 
        "empty.png", name_bg:getContentSize().width, name_bg:getContentSize().height, name_bg:getPositionX(), name_bg:getPositionY(), 18, 18, "")
        name_input:setColor({r=112,g=131,b=158})
        ]]--
    end

    local function playCSB()
        local node = CSResourceMgr.getNodeByName(resName, "db")
        if node ~= nil then
            node:setVisible(true)
            CocosModuleMgr.showUIAnimation(node, "down")
        end
    end

    local funcTable = {loadCSB, playCSB}

    UnblockLoader.load(funcTable, "FamilyPlayerViewMgr")
end

return FamilyPlayerViewMgr