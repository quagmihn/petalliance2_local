local FamilyInfoMgr = {}

local resName = ""
local confirm = 1
local FamilyIcon = ""
local jobSelf = FamilyInfo.JobType.Job_None

function FamilyInfoMgr.Init()
    resName = "Player/Family/FamilyInfo.csb"
    confirm = 1
    FamilyIcon = ""
    jobSelf = FamilyInfo.JobType.Job_None
end

function FamilyInfoMgr.hideUI()
    UnblockLoader.cancel("FamilyInfoMgr")
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("FamilyInfoMgr")
end

local function initStaticData()
    CSResourceMgr.setLabelString(resName, "txt_title", "family140", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, "style", "family133", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"db", "bg1", "txt_bg1"}, "family50", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"db", "bg2", "txt_bg2"}, "family130", nil, {r=0,g=0,b=0,a=255,w=1})
end

local function quitFamily()
    FamilyInfo.QuitFamily()
end

local function transferFamily()
    --FamilyInfo.CreateFamily(FamilyIcon, CSResourceMgr.getNodeByName(resName, "name_input"):getString(), CSResourceMgr.getNodeByName(resName, "purpose_input"):getString(), CSResourceMgr.getNodeByName(resName, "announcement_input"):getString(), confirm)
    --hideUI()
    FamilyTransListViewMgr.show(SceneMgr.getRunningScene)
end

local function dismissFamily()
    FamilyInfo.DismissFamily()
end

local function modifyFamilyInfo()
    if jobSelf == FamilyInfo.JobType.Job_Leader then
        local purpose_input = CSResourceMgr.getNodeByName(resName, "purpose_input")
        local purpose = SystemInfo.checkShieldString(purpose_input:getString())
        local announcement_input = CSResourceMgr.getNodeByName(resName, "announcement_input")
        local announcement = SystemInfo.checkShieldString(announcement_input:getString())
        local info = {icon = FamilyIcon, purpose = purpose, notice = announcement, needCheckJoin = confirm}
        MyFamilyLstViewMgr.refreshUIBaseData(info)
        local cfg = FamilyInfo.GetLocalFamilyInfo()
        if cfg ~= nil then
            if cfg.icon == nil or cfg.icon ~= FamilyIcon then
                FamilyInfo.ModifyFamilyIcon(FamilyIcon)
            end
            if cfg.needCheckJoin == nil or cfg.needCheckJoin ~= confirm then
                FamilyInfo.ModifyFamilyConfirmStyle(confirm)
            end
            if cfg.purpose == nil or cfg.purpose ~= purpose then
                purpose_input:setString(purpose)
                FamilyInfo.ModifyFamilyPurpose(purpose)
            end
            if cfg.notice == nil or cfg.notice ~= announcement then
                announcement_input:setString(announcement)
                FamilyInfo.ModifyFamilyAnnouncement(announcement)
            end
        end
    elseif jobSelf == FamilyInfo.JobType.Job_Elder then
        local announcement_input = CSResourceMgr.getNodeByName(resName, "announcement_input")
        local announcement = SystemInfo.checkShieldString(announcement_input:getString())
        local info = {notice = announcement}
        MyFamilyLstViewMgr.refreshUIBaseData(info)
        local cfg = FamilyInfo.GetLocalFamilyInfo()
        if cfg ~= nil and (cfg.notice == nil or cfg.notice ~= announcement) then
            announcement_input:setString(announcement)
            FamilyInfo.ModifyFamilyAnnouncement(announcement)
        end
    end
end

function FamilyInfoMgr.RefreshByFamilyCfg(cfg)
    if cfg ~= nil and CSResourceMgr.getCsbObj(resName) then
        jobSelf = FamilyInfo.GetJobByMemberID(CharInfo.getCharID())
        
        if cfg.icon ~= nil and cfg.icon ~= "" then
            FamilyIcon = cfg.icon
            CSResourceMgr.setSpriteTextureByNode(CSResourceMgr.getNodeByName(resName, "icon"), cfg.icon)
        end
        CSResourceMgr.setButtonEnabled(resName, "icdb", jobSelf == FamilyInfo.JobType.Job_Leader)
        
        if cfg.name ~= nil then
            CSResourceMgr.getNodeByName(resName, "name"):setString(cfg.name)
        end
        
        if cfg.needCheckJoin ~= nil then
            if cfg.needCheckJoin == 0 then
                CSResourceMgr.getNodeByName(resName, "txt_style"):setString(LuaSqlite.getLanguageByKey("family1"))
            else
                CSResourceMgr.getNodeByName(resName, "txt_style"):setString(LuaSqlite.getLanguageByKey("family2"))
            end
        end
        if jobSelf ~= FamilyInfo.JobType.Job_Leader then
            CSResourceMgr.setLabelColor(resName, "txt_style", {r=217,g=234,b=255,a=255})
        end
        CSResourceMgr.getNodeByName(resName, "btn_style"):setVisible(jobSelf == FamilyInfo.JobType.Job_Leader)
        CSResourceMgr.getNodeByName(resName, "Image_arrow"):setVisible(jobSelf == FamilyInfo.JobType.Job_Leader)
        
        local purpose = CSResourceMgr.getNodeByName(resName, "purpose_input")
        if cfg.purpose ~= nil then
            purpose:setString(cfg.purpose)
        end
        purpose:setTouchAreaEnabled(not (jobSelf == FamilyInfo.JobType.Job_Leader))
        local announcement = CSResourceMgr.getNodeByName(resName, "announcement_input")
        if cfg.notice ~= nil then
            announcement:setString(cfg.notice)
        end
        announcement:setTouchAreaEnabled(not (jobSelf == FamilyInfo.JobType.Job_Leader or jobSelf == FamilyInfo.JobType.Job_Elder))
        
        if jobSelf == FamilyInfo.JobType.Job_Leader then
            if cfg.memberCount ~= nil and cfg.memberCount <= 1 then
                CSResourceMgr.setButtonString(resName, "btn_quit", LuaSqlite.getLanguageByKey("family6"))
            else
                CSResourceMgr.setButtonString(resName, "btn_quit", LuaSqlite.getLanguageByKey("family7"))
            end
        else
            CSResourceMgr.setButtonString(resName, "btn_quit", LuaSqlite.getLanguageByKey("family5"))
        end
    end
end

function FamilyInfoMgr.show(scene)
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end
    UIStack.push("FamilyInfoMgr",FamilyInfoMgr.hideUI,false)
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)
        
        CSResourceMgr.clickEventBinding(resName, "close", function()
            modifyFamilyInfo()
            FamilyInfoMgr.hideUI()
        end)
        
        initStaticData()
        
        CSResourceMgr.clickEventBinding(resName, "btn_quit", function()
            local txt = CSResourceMgr.getButtonString(resName, "btn_quit")
            FamilyInfoMgr.hideUI()
            if txt == LuaSqlite.getLanguageByKey("family5") then
                DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, "family121", function()
                    quitFamily()
                end)
            elseif txt == LuaSqlite.getLanguageByKey("family6") then
                dismissFamily()
            else
                transferFamily()
            end
        end)
        
        CSResourceMgr.clickEventBinding(resName, "btn_style", function()
            local node = CSResourceMgr.getNodeByName(resName, "txt_style")
            confirm = (confirm + 1)%2
            if confirm == 0 then
                node:setString(LuaSqlite.getLanguageByKey("family1"))
            else
                node:setString(LuaSqlite.getLanguageByKey("family2"))
            end
        end)
        
        CSResourceMgr.clickEventBinding(resName, "icdb", function()
            FamilyIconMgr.show(SceneMgr.getRunningScene, FamilyIcon, CSResourceMgr.getNodeByName(resName, "name"):getString(), function()
                FamilyIcon = FamilyIconMgr.getClickedIconRes()
                if FamilyIcon ~= "" then
                    CSResourceMgr.setSpriteTextureByNode(CSResourceMgr.getNodeByName(resName, "icon"), FamilyIcon)
                end
            end)
        end)
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

    UnblockLoader.load(funcTable, "FamilyInfoMgr")
    
    if CharInfo.getFamilyID() ~= nil then
        local info = FamilyInfo.GetLocalFamilyInfo()
        if info == nil then
            FamilyInfo.QueryMyFamily()
        else
            FamilyInfoMgr.RefreshByFamilyCfg(info)
        end
    end
end

return FamilyInfoMgr