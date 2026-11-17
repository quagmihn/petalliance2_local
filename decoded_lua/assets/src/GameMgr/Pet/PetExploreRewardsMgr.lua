local PetExploreRewardsMgr = {}

PetExploreRewardsMgr.RANK_NUM = 4

local resName = ""
local closeCallback = nil

function PetExploreRewardsMgr.Init()
    print("PetExploreRewardsMgr初始化")
    
    resName = "Pet/Explore/ExploreRewards.csb"
    closeCallback = nil
end

function PetExploreRewardsMgr.show(scene, callback)
    closeCallback = callback
    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, resName)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        
        CSResourceMgr.setLabelColor(resName, "title", {r=166,g=243,b=255,a=255})
        CSResourceMgr.setLabelString(resName, "title", "idling8", "", {r=37,g=54,b=75,a=255})
        CSResourceMgr.setButtonString(resName, "ok", "idling9", "", {r=20,g=51,b=93,a=255})
        
        CSResourceMgr.clickEventBinding(resName, "ok", function()
            NetInterface.sendWithBlock("GC_EndExplore_Ack", function()
                local ExploreSend = require("src.Net.Send.ExploreSend")
                ExploreSend.sendCG_EndExplore_Req({exploreIndex = ExploreInfo.get().exploreID})
            end, function()
                PetExploreRewardsMgr.hide(true)
            end, function(code)
                TipsMgr.showError(scene, code)
            end)
        end)
        CSResourceMgr.clickEventBinding(resName, "bg", function()
            PetExploreRewardsMgr.hide(false)
        end)
        CSResourceMgr.clickEventBinding(resName, "add", function()
            local buyID = CharInfo.get().explorepacketnum+1
            local cost = ExploreInfo.getExplorePacketBuyCostStr(buyID)
            DialogBoxMgr.showSmallDialogBox(scene, 2, CocosModuleMgr.createStringWithFormat({"idling14", cost}), function()
                if ExploreInfo.getExplorePacketBuyInfoByID(buyID).gcash>CharInfo.getGCash() then
                    TipsMgr.show(scene, "tips13")
                	return
                end
                if ExploreInfo.getExplorePacketBuyInfoByID(buyID).mcash>CharInfo.getMCash() then
                    TipsMgr.show(scene, "tips14")
                    return
                end
                
                NetInterface.sendWithBlock("GC_BuyExplorePacket_Ack", function()
                	local ExploreSend = require("src.Net.Send.ExploreSend")
                	ExploreSend.sendCG_BuyExplorePacket_Req()
                end, function()
                    PetExploreMgr.refreshServerTime(true)
                    PetExploreRewardsMgr.refreshItem()
                end, function(code)
                	TipsMgr.showError(scene, code)
                end)
            end)
        end)
    end

    local function playCSB()
        CSResourceMgr.playActionWithCallback(resName, 0, 5, 1, function()
            PetExploreRewardsMgr.refreshItem()
        end)
    end

    local funcTable = {loadCSB, playCSB}
    UnblockLoader.load(funcTable, "PetExploreRewardsMgr.show")
end

function PetExploreRewardsMgr.hide(boolEnd)
    UnblockLoader.cancel("PetExploreRewardsMgr.refreshItem")
    UnblockLoader.cancel("PetExploreRewardsMgr.show")
    CSResourceMgr.playActionWithCallback(resName, 40, 45, 1, function()
        CSResourceMgr.getNodeByName(resName, "listview"):removeAllItems()
        CSResourceMgr.removeCSObjectByTag(resName)
        if closeCallback and boolEnd then
            closeCallback()
            closeCallback = nil
        end
    end)
end

function PetExploreRewardsMgr.refreshItem()
    local list = CSResourceMgr.getNodeByName(resName, "listview")
    if not list then
        return 
    end
    list:removeAllItems()
    local bagSize = CSResourceMgr.getNodeByName(resName, "size")
    bagSize:removeAllChildren()

    local items = {}
    for key, var in pairs(ExploreInfo.get().events) do
        if var.time<=CharInfo.getServerTime() and #items<CharInfo.get().explorepacketnum  then
            table.insert(items, {id=var.item, num=var.count})
            print("add awards time:", var.time)
        end
    end
    print("item size", #items)
    
    local colorStr = "FF0000"
    if #items<CharInfo.get().explorepacketnum then
        colorStr = "00FF00"
    end
    local richtext = CocosModuleMgr.createRichLabel(bagSize, CocosModuleMgr.createRichLabelString({
        {color=colorStr, text=#items}, {color="FFFFFF", text="/"..CharInfo.get().explorepacketnum}}), 20, "cuyuan_GBK.ttf", 640, 0, 0)
    richtext:setPosition(-richtext.realWidth/2, richtext.realHeight/2)
    
    local funcTable = {}
    local panelTable = {}
    for i=1, #items do
        local row = math.ceil(i/PetExploreRewardsMgr.RANK_NUM)
        local rank = i%PetExploreRewardsMgr.RANK_NUM
        if rank==0 then
            rank = PetExploreRewardsMgr.RANK_NUM
        end
        local panel = nil
        if rank==1 then
            panel = CSResourceMgr.getNodeByName(resName, "panel"):clone()
            table.insert(panelTable, panel)
            list:pushBackCustomItem(panel)
            list:performWithDelay(function()
                list:jumpToTop()
            end, 0.1)
        end
        
        local bagItemInfo = items[i]
        local function itemFunc()
            local parent = nil
            if rank==1 then
                parent = CSResourceMgr.seekNodeByName(panel, "item")
            else
                panel = panelTable[row]
                parent = CSResourceMgr.seekNodeByName(panel, "item"):clone()
                parent:addTo(panel)
                local posx = parent:getPositionX()
                parent:setPositionX(posx+(rank-1)*96)
            end
            panel:setVisible(true)
            local label = CSResourceMgr.seekNodeByName(parent, "num")
            if bagItemInfo.num==1 then
                CSResourceMgr.setLabelStringByNode(label, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            else
                CSResourceMgr.setLabelStringByNode(label, bagItemInfo.num, CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            end
            local sprite = CSResourceMgr.seekNodeByName(parent, "icon")
            local iconpath = ItemInfo.getItemInfoById(bagItemInfo.id).icon
            CSResourceMgr.setSpriteTextureByNode(sprite, iconpath)
            CSResourceMgr.clickEventBindingByNode(parent, function()
                ItemInfoViewMgr.show({id = bagItemInfo.id, sum = bagItemInfo.num}, false)
            end)
            parent:setScale(0, 0)
            parent:setRotation(180)
            transition.scaleTo(parent, {scale = 1, time = 0.2})
            transition.rotateTo(parent, {rotate = 360, time = 0.2})
        end
        table.insert(funcTable, itemFunc)
        --itemFunc()
    end
    
    UnblockLoader.load(funcTable, "PetExploreRewardsMgr.refreshItem", 0.01)
end

return PetExploreRewardsMgr