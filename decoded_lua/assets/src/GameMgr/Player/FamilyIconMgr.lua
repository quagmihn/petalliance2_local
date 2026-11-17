local FamilyIconMgr = {}

local resName = ""
local clickedIconRes = ""

function FamilyIconMgr.Init()
    resName = "Player/Family/FamilyIcon.csb"
    clickedIconRes = ""
end

function FamilyIconMgr.hideUI()
    UnblockLoader.cancel("FamilyIconMgr.show")
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("FamilyIconMgr")
end

local function initStaticData()
    CSResourceMgr.setLabelString(resName, {"db", "bg1", "txt_bg1"}, "family134", nil, {r=0,g=0,b=0,a=255,w=1})
end

function FamilyIconMgr.show(scene, selIcon, selName, funcClose)
    --print("@@@@@@@@@@@@@@@@@@@@@@FamilyIconMgr.show")
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end
    UIStack.push("FamilyIconMgr",FamilyIconMgr.hideUI,false)
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)

        CSResourceMgr.clickEventBinding(resName, "close", function()
            FamilyIconMgr.hideUI()
            if funcClose ~= nil then
                funcClose()
            end
        end)
        
        initStaticData()
        
        if selName ~= nil then
            CSResourceMgr.getNodeByName(resName, "name"):setString(selName)
        end
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
    
    local function loadIcon()
        if selIcon ~= nil and selIcon ~= "" then
            clickedIconRes = selIcon
            CSResourceMgr.setSpriteTextureByNode(CSResourceMgr.getNodeByName(resName, "icon"), selIcon)
        end
        local iconInfo = FamilyInfo.getIconInfo()
        if iconInfo ~= nil then
            for i=1, #iconInfo do
                local data = iconInfo[i]
                local icdb = CSResourceMgr.getNodeByName(resName, "icdb"..i)
                local icon = CSResourceMgr.getNodeByName(resName, "icon"..i)
                if icdb ~= nil and icon ~= nil then
                    CSResourceMgr.setSpriteTextureByNode(icon, data.res_path)
                    icdb:setVisible(true)
                    CSResourceMgr.clickEventBindingByNode(icdb, function()
                        clickedIconRes = data.res_path
                        CSResourceMgr.setSpriteTextureByNode(CSResourceMgr.getNodeByName(resName, "icon"), data.res_path)
                    end,3)
                end
            end
        end
    end

    local funcTable = {loadCSB, playCSB, loadIcon}

    UnblockLoader.load(funcTable, "FamilyIconMgr")
end

function FamilyIconMgr.getClickedIconRes()
    return clickedIconRes
end

return FamilyIconMgr