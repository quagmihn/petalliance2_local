local PetExploreInfoMgr = {}

PetExploreInfoMgr.RANK_NUM = 4

local resName = ""

function PetExploreInfoMgr.Init()
    print("PetExploreInfoMgr初始化")
    
    resName = "Pet/Explore/ExploreInfo.csb"
end

function PetExploreInfoMgr.show(scene, eid)
    UIStack.push("PetExploreInfoMgr", PetExploreInfoMgr.hide, false)
	local function loadCSB()
		local layer = CSResourceMgr.createRes(scene, resName)
		layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
		CSResourceMgr.setRelativePosition(resName, 320, 480)
		CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)
		
		CSResourceMgr.clickEventBinding(resName, "close", function()
            PetExploreInfoMgr.hide()
		end)
        CSResourceMgr.clickEventBinding(resName, "ok", function()
            PetExploreInfoMgr.hide()
        end)
        CSResourceMgr.setLabelColor(resName, "title", {r=166,g=243,b=255,a=255})
        CSResourceMgr.setLabelString(resName, "title", "idling6", "", {r=37,g=54,b=75,a=255})
        CSResourceMgr.setLabelString(resName, "oktlt", "tips3", "", {r=20,g=51,b=93,a=255}, nil, 150)
        
        CSResourceMgr.setButtonEnabled(resName, "left", false)
        CSResourceMgr.setButtonEnabled(resName, "right", false)
	end
	
	local function playCSB()
        local db = CSResourceMgr.getNodeByName(resName, "db")
        db:setVisible(true)
        CocosModuleMgr.showUIAnimation(db, "down")
        PetExploreInfoMgr.refreshItem(ExploreInfo.getExploreInfoByID(eid).randomAwardIDs)
	end
	
    local funcTable = {loadCSB, playCSB}
    UnblockLoader.load(funcTable, "PetExploreInfoMgr.show")
end

function PetExploreInfoMgr.hide()
    UnblockLoader.cancel("PetExploreInfoMgr.refreshItem")
    UnblockLoader.cancel("PetExploreInfoMgr.show")
    CSResourceMgr.getNodeByName(resName, "pageview"):removeAllPages()
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("PetExploreInfoMgr")
end

function PetExploreInfoMgr.refreshItem(itemVec)
    local pageView = CSResourceMgr.getNodeByName(resName, "pageview")
    if not pageView then
    	return
    end
    pageView:removeAllPages()
    
    local funcTable = {}
    local panelTable = {}
    for i=1, #itemVec do
        local itemID = ExploreInfo.getExploreRandomAwardInfoByID(itemVec[i]).itemID
        if not ItemInfo.getItemInfoById(itemID) then
            break
        end
    
        local row = math.ceil(i/PetExploreInfoMgr.RANK_NUM)
        local rank = i%PetExploreInfoMgr.RANK_NUM
        if rank==0 then
            rank = PetExploreInfoMgr.RANK_NUM
        end
        local panel = nil
        if rank==1 then
            panel = CSResourceMgr.getNodeByName(resName, "panel"):clone()
            table.insert(panelTable, panel)
            pageView:addPage(panel)
        else
            panel = panelTable[row]
        end
        
        local function itemFunc()
            local parent = nil
            if rank==1 then
                panel:setVisible(true)
                parent = CSResourceMgr.seekNodeByName(panel, "item")
            else
                local posxDiff = 125
                parent = CSResourceMgr.seekNodeByName(panel, "item"):clone()
                parent:addTo(panel)
                local posx = parent:getPositionX()
                parent:setPositionX(posx+posxDiff*(rank-1))
            end
            
            local idiban = CSResourceMgr.seekNodeByName(parent, "idiban")
            CSResourceMgr.setSpriteTextureByNode(idiban, ItemInfo.getItemRareBGImage(itemID))
            local name = CSResourceMgr.seekNodeByName(parent, "name")
            CSResourceMgr.setLabelColorByNode(name, {r=195,g=235,b=255,a=255})
            CSResourceMgr.setLabelStringByNode(name, ItemInfo.getItemInfoById(itemID).name, {r=15,g=43,b=70,a=255}, nil, 120)
            local icon = CSResourceMgr.seekNodeByName(parent, "icon")
            CSResourceMgr.setSpriteTextureByNode(icon, ItemInfo.getItemInfoById(itemID).icon)
            CSResourceMgr.clickEventBindingByNode(parent, function()
            	ItemInfoViewMgr.show({id=itemID}, false)
            end)
            parent:setScale(0)
            transition.scaleTo(parent, {scale=1, time=0.2})
        end
        table.insert(funcTable, itemFunc)
    end
    
    UnblockLoader.load(funcTable, "PetExploreInfoMgr.refreshItem")
    
    local pageSize = math.ceil(#itemVec/PetExploreInfoMgr.RANK_NUM)
    local function changePage(page)
        local pageLabel = CSResourceMgr.getNodeByName(resName, "page")
        pageLabel:removeAllChildren()
        local colorStr = "00FF00"
        local richtext = CocosModuleMgr.createRichLabel(pageLabel, CocosModuleMgr.createRichLabelString({
            {color=colorStr, text=page}, {color="FFFFFF", text="/"..pageSize}}), 20, "cuyuan_GBK.ttf", 640, 0, 0)
        richtext:setPosition(-richtext.realWidth/2, richtext.realHeight/2)
    end
    
    if pageSize>1 then
        CSResourceMgr.setButtonEnabled(resName, "right", true)
        
        local curPage = 0
        pageView:addEventListener(function(sender, eventType)
            if curPage==pageView:getCurPageIndex() then
                return
            end
            local index = pageView:getCurPageIndex()
            changePage(index+1)
            if index==0 then
                CSResourceMgr.setButtonEnabled(resName, "left", false)
                CSResourceMgr.setButtonEnabled(resName, "right", true)
            elseif index==pageSize-1 then
                CSResourceMgr.setButtonEnabled(resName, "left", true)
                CSResourceMgr.setButtonEnabled(resName, "right", false)
            else
                CSResourceMgr.setButtonEnabled(resName, "left", true)
                CSResourceMgr.setButtonEnabled(resName, "right", true)
            end
            curPage = index
        end)
        
        CSResourceMgr.clickEventBinding(resName, "left", function()
            local index = pageView:getCurPageIndex()-1
            pageView:scrollToPage(index)
        end, "", 1)
        CSResourceMgr.clickEventBinding(resName, "right", function()
            local index = pageView:getCurPageIndex()+1
            pageView:scrollToPage(index)
        end, "", 1)
    end
    
    changePage(1)
end

return PetExploreInfoMgr