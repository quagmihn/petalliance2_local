local CreateFamilyMgr = {}

local resName = ""
local confirm = 1
local FamilyIcon = ""
local rechargeTotal = 0
function CreateFamilyMgr.Init()
    resName = "Player/Family/CreateFamily.csb"
    confirm = 1
    FamilyIcon = FamilyInfo.getIconInfo()[1].res_path
end

function CreateFamilyMgr.hideUI()
    GameAudio.playUISound("back")
    UnblockLoader.cancel("CreateFamilyMgr.show")
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("CreateFamilyMgr")
end

local function createFamily(familyName)
    --local FamilyName = CSResourceMgr.getNodeByName(resName, "name_input"):getString()
	if  CharInfo.get().recharge == nil then 
		rechargeTotal = 0
	else
		rechargeTotal = CharInfo.get().recharge.totalMoney
	end
	if familyName == "" then
        StandardTipsMgr.show(1,"family17")
	elseif rechargeTotal < 1 then
		StandardTipsMgr.show(1,"family153")
    else
        local purpose_input = CSResourceMgr.getNodeByName(resName, "purpose_input")
        local purpose = SystemInfo.checkShieldString(purpose_input:getString())
        purpose_input:setString(purpose)
        local announcement_input = CSResourceMgr.getNodeByName(resName, "announcement_input")
        local announcement = SystemInfo.checkShieldString(announcement_input:getString())
        announcement_input:setString(announcement)
        FamilyInfo.CreateFamily(FamilyIcon, familyName, purpose, announcement, confirm)
        CreateFamilyMgr.hideUI()
    end
end

local function initStaticData()
    CSResourceMgr.setLabelString(resName, "txt_title", "family25", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, "style", "family133", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, "txt_style", "family2", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"db", "bg1", "txt_bg1"}, "family50", nil, {r=0,g=0,b=0,a=255,w=1},nil,110)
    local purpose_input = CSResourceMgr.getNodeByName(resName, "purpose_input")
    purpose_input:setPlaceHolder(LuaSqlite.getLanguageByKey("family131"))
    CSResourceMgr.setLabelString(resName, {"db", "bg2", "txt_bg2"}, "family130", nil, {r=0,g=0,b=0,a=255,w=1},nil,110)
    local announcement_input = CSResourceMgr.getNodeByName(resName, "announcement_input")
    announcement_input:setPlaceHolder(LuaSqlite.getLanguageByKey("family132"))
end

function CreateFamilyMgr.show(scene)
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end
    UIStack.push("CreateFamilyMgr",CreateFamilyMgr.hideUI,false)
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)
        
        CSResourceMgr.setSpriteTextureByNode(CSResourceMgr.getNodeByName(resName, "icon"), FamilyIcon)
        
        local input_bg = CSResourceMgr.getNodeByName(resName, "name_bg")
        local input = CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resName, "db"), 
            "empty.png", input_bg:getContentSize().width - 20, input_bg:getContentSize().height, input_bg:getPositionX() + 10, input_bg:getPositionY(), 24, 18, "family110")
        
        CSResourceMgr.clickEventBinding(resName, "close", function()
            CreateFamilyMgr.hideUI()
        end)
        
        initStaticData()
        
        CSResourceMgr.clickEventBinding(resName, "btn_create", function()
            if input:getText() ~= "" then
                createFamily(input:getText())
            else
                StandardTipsMgr.show(1,"family120")
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
            FamilyIconMgr.show(SceneMgr.getRunningScene, FamilyIcon, input:getText(), function()
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

    UnblockLoader.load(funcTable, "CreateFamilyMgr")
end

return CreateFamilyMgr