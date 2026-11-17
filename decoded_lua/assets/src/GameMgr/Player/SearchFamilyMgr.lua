local SearchFamilyMgr = {}

local resName = ""
local input = nil

function SearchFamilyMgr.Init()
    resName = "Player/Family/SearchFamily.csb"
    input = nil
end

function SearchFamilyMgr.hideUI()
    GameAudio.playUISound("back")
    UnblockLoader.cancel("SearchFamilyMgr.show")
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("SearchFamilyMgr")
end

local function initStaticData()
    CSResourceMgr.setLabelString(resName, "txt_title", "family26", nil, {r=0,g=0,b=0,a=255,w=2})
    CSResourceMgr.setButtonString(resName, "btn_join", "family149", nil, {r=0,g=0,b=0,a=255,w=1})
end

local function searchFamily(id)
    FamilyInfo.QueryFamily(id)
    --FamilyInfo.QueryMyFamily()
end

local function joinFamily(id)
    if CharInfo.getFamilyID() ~= nil then
        StandardTipsMgr.show(1,"family3")
    else
        FamilyInfo.JoinFamily(id)
    end
end

function SearchFamilyMgr.Refresh(cfg)
    if cfg ~= nil and CSResourceMgr.getCsbObj(resName) then
        CSResourceMgr.getNodeByName(resName, "info"):setVisible(true)
        if cfg.icon ~= nil and cfg.icon ~= "" then
            CSResourceMgr.setSpriteTextureByNode(CSResourceMgr.getNodeByName(resName, "icon"), cfg.icon)
        end
        if cfg.name ~= nil then
            CSResourceMgr.getNodeByName(resName, "txt_family"):setString(cfg.name)
        end
        if cfg.needCheckJoin ~= nil then
            if cfg.needCheckJoin == 0 then
                CSResourceMgr.getNodeByName(resName, "txt_style"):setString(LuaSqlite.getLanguageByKey("family1"))
            else
                CSResourceMgr.getNodeByName(resName, "txt_style"):setString(LuaSqlite.getLanguageByKey("family2"))
            end
        end
        if cfg.memberCount ~= nil then
            CSResourceMgr.getNodeByName(resName, "txt_num"):setString(tostring(cfg.memberCount).."/"..tostring(30 + (cfg.familyLevel or 1)*4))
        end
        if cfg.fight ~= nil then
            CSResourceMgr.getNodeByName(resName, "txt_fight"):setString(tostring(cfg.fight))
        end
        if cfg.purpose ~= nil then
            CSResourceMgr.getNodeByName(resName, "txt_purpose"):setString(cfg.purpose)
        end
        if cfg.notice ~= nil then
            CSResourceMgr.getNodeByName(resName, "txt_announcement"):setString(cfg.notice)
        end
    end
end

function SearchFamilyMgr.show(scene)
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end
    UIStack.push("SearchFamilyMgr",SearchFamilyMgr.hideUI,false)
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)
        
        local input_bg = CSResourceMgr.getNodeByName(resName, "input_bg")
        input = CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resName, "db"), 
            "empty.png", input_bg:getContentSize().width, input_bg:getContentSize().height, input_bg:getPositionX(), input_bg:getPositionY(), 24, 10, "family150", nil, function()
                local txt = input:getText()
                if txt~="" and (not tonumber(txt) or tonumber(txt) < 0) then
                    input:setText("")
                    StandardTipsMgr.show(1,"friendList26")
                end
            end)
            
        CSResourceMgr.clickEventBinding(resName, "close", function()
            SearchFamilyMgr.hideUI()
        end)
        
        CSResourceMgr.clickEventBinding(resName, "btn_search", function()
            local id = input:getText()
            if id == "" then
                StandardTipsMgr.show(1, "family13")
            else
                --if tonumber(id) then
                    searchFamily(tonumber(id))
                --else
                --    StandardTipsMgr.show(1,"friendList26")
                --end
            end
        end, "", true)
        
        CSResourceMgr.clickEventBinding(resName, "btn_join", function()
            joinFamily(tonumber(input:getText()))
            SearchFamilyMgr.hideUI()
        end)
        --[[
        local name_bg = CSResourceMgr.getNodeByName(resName, "name_bg")
        local name_input = CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resName, "db"), 
            "empty.png", name_bg:getContentSize().width, name_bg:getContentSize().height, name_bg:getPositionX(), name_bg:getPositionY(), 18, 18, "")
        name_input:setColor({r=112,g=131,b=158})
        ]]--
        
        initStaticData()
    end
    
    local function playCSB()
        local node = CSResourceMgr.getNodeByName(resName, "db")
        if node ~= nil then
            node:setVisible(true)
            CocosModuleMgr.showUIAnimation(node, "down")
        end
    end
    
    local funcTable = {loadCSB, playCSB}

    UnblockLoader.load(funcTable, "SearchFamilyMgr")
end

return SearchFamilyMgr