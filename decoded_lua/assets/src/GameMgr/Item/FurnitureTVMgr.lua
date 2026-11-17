local FurnitureTVMgr = {}

local resName = ""
local refreshTimes = 0
local maxTimes = 0

function FurnitureTVMgr.Init()
    resName = "Item/Bag/FurnitureTV.csb"
    refreshTimes = 0
    maxTimes = 0
end

function FurnitureTVMgr.hideUI()
    UnblockLoader.cancel("FurnitureTVMgr")
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("FurnitureTVMgr")
end

local function verify()
    NetInterface.sendWithBlock("GC_REFRESHMAPNODEEVENT_ACK", function()
        local AdventureSend = require("src/Net/Send/AdventureSend.lua")
        AdventureSend.sendCG_RefreshMapNodeEvent_Req()
    end,function()
        StandardTipsMgr.show(0,"home007")
    end, function(code)
        if code == Proto.Error.ERROR_NO_MORE_REFRESH_TIMES then
            StandardTipsMgr.show(1,"LtTips11")
        end
    end)
end

function FurnitureTVMgr.setRefreshTimes(times)
    if times ~= nil then
        refreshTimes = times
        if CSResourceMgr.getCsbObj(resName) then
            CSResourceMgr.setLabelString(resName, "txt_refresh", CocosModuleMgr.createStringWithFormat({"home006", refreshTimes, maxTimes}))
            CSResourceMgr.setButtonEnabled(resName, "btn_verify", refreshTimes < maxTimes)
        end
    end
end

function FurnitureTVMgr.setMaxTimes(times)
    if times ~= nil then
        maxTimes = times
    end
end

function FurnitureTVMgr.show(scene)
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end
    UIStack.push("FurnitureTVMgr",FurnitureTVMgr.hideUI,false)
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)
        
        CSResourceMgr.clickEventBinding(resName, "bg", function()
            FurnitureTVMgr.hideUI()
            end)
        
        CSResourceMgr.clickEventBinding(resName, "close", function()
            FurnitureTVMgr.hideUI()
        end)
        
        CSResourceMgr.clickEventBinding(resName, "btn_verify", function()
            verify()
        end)
        
        CSResourceMgr.setLabelString(resName, "txt_refresh", CocosModuleMgr.createStringWithFormat({"home006", refreshTimes, maxTimes}), nil, {r=0,g=0,b=0,a=255,w=2})
        local verify = CSResourceMgr.getNodeByName(resName, "btn_verify")
        CSResourceMgr.setButtonStringByNode(verify, "home008", {r=62,g=77,b=27,a=255,w=2})
        CSResourceMgr.setButtonEnabledByNode(verify, refreshTimes < maxTimes)
    end
    
    local function playCSB()
        local node = CSResourceMgr.getNodeByName(resName, "db")
        if node ~= nil then
            node:setVisible(true)
            CocosModuleMgr.showUIAnimation(node, "down")
        end
    end
    
    local funcTable = {loadCSB, playCSB}

    UnblockLoader.load(funcTable, "FurnitureTVMgr")
end

return FurnitureTVMgr