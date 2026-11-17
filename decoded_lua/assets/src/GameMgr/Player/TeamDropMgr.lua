local TeamDropMgr = {}

local resName = ""
local tag = "TeamDropMgr"
local listVec = {}

function TeamDropMgr.Init()
	resName = "res/Player/Team/TeamDrop.csb"
    listVec = {}
end

function TeamDropMgr.showDrop(curAdvId)
    local boxIDs = TeamMapInfo.getTeamFloorInfoById(curAdvId).awardChestIDs
    local tmpVec = {}
    for var=1, #boxIDs do
        local treasureId = boxIDs[var]
        local dropInfo = TreasureBoxInfo.getTreasureBoxInfoById(treasureId)
        local dropId = dropInfo.awards[1]
        local itemVec = ItemInfo.getAwardElementsItem({dropId}, false)
        for k, v in pairs(itemVec) do
        	tmpVec[v[1]] = true
        end
    end
    local iVec = {}
    for key, var in pairs(tmpVec) do
        table.insert(iVec, {key})
    end
    DropInfoViewMgr.show(iVec)
end

function TeamDropMgr.show(scene, curAdvId)
    UIStack.push(tag, TeamDropMgr.hide, false)
    listVec = {}
    
    local listMaxWidth = 560
    local itemWidth = 92
    local function loadCSB()
    	CSResourceMgr.createRes(scene, resName):zorder(CocosModuleMgr.ZORDER_WINDOW)
    	CSResourceMgr.setRelativePosition(resName, 320, 480)
    	
    	CSResourceMgr.setLabelColor(resName, "title", {r=166,g=243,b=255,a=255})
        CSResourceMgr.setLabelString(resName, "title", "team1", "", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 500)
        CSResourceMgr.clickEventBinding(resName, "bg", function()
        	TeamDropMgr.hide()
        end)
        listMaxWidth = CSResourceMgr.getNodeByName(resName, "list"):getContentSize().width
        itemWidth = CSResourceMgr.getNodeByName(resName, "idb"):getContentSize().width
    	
    	CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName, "db"), "down")
    end
    local funcTable = {loadCSB}
    
    local boxIDs = TeamMapInfo.getTeamFloorInfoById(curAdvId).awardChestIDs
    local posYs = {455, 305, 155}
    for var=1, #boxIDs do
        local treasureId = boxIDs[var]
        local dropInfo = TreasureBoxInfo.getTreasureBoxInfoById(treasureId)
        local dropId = dropInfo.awards[1]
        local itemVec = ItemInfo.getAwardElementsItem({dropId}, false)
        table.insert(funcTable, function()
            local parent = CSResourceMgr.getNodeByName(resName, "example")
            if posYs[var] then
                parent = parent:clone()
                parent:addTo(CSResourceMgr.getNodeByName(resName, "db"))
            else
                return
        	end
        	parent:setPositionY(posYs[var])
            local boxicon = CSResourceMgr.seekNodeByName(parent, "boxicon")
            CSResourceMgr.setSpriteTextureByNode(boxicon, dropInfo.imagePath)
            local name = CSResourceMgr.seekNodeByName(parent, "name")
            CSResourceMgr.setLabelStringByNode(name, dropInfo.name, {r=0,g=0,b=0,a=255,w=2}, nil, 400)
            local list = CSResourceMgr.seekNodeByName(parent, "list")
            table.insert(listVec, list)
            local margin = 15
            list:setItemsMargin(margin)
            local widthI = #itemVec*itemWidth+margin*(#itemVec-1)
            if widthI>0 and widthI<listMaxWidth then
                list:setContentSize(widthI, list:getContentSize().height)
            end
        	parent:show()
        	parent:setScaleY(0)
        	transition.scaleTo(parent, {scale=1, time=0.1})
        end)
        for n=1, #itemVec do
            table.insert(funcTable, function()
                if listVec[var] then
                    local iInfo = itemVec[n]
                    local itemBtn = ItemInfo.getItemIconById(iInfo[1])
                    local idb = CSResourceMgr.getNodeByName(resName, "idb"):clone()
                    idb:show()
                    itemBtn:addTo(idb)
                    itemBtn:pos(idb:getContentSize().width/2, idb:getContentSize().height/2)
                    listVec[var]:pushBackCustomItem(idb)
                    itemBtn:scale(0)
                    itemBtn:setSwallowTouches(false)
                    transition.scaleTo(itemBtn, {scale=0.65, time=0.1})
                    CSResourceMgr.clickEventBindingByNode(itemBtn, function()
                        ItemInfoViewMgr.show({id=iInfo[1]}, false)
                    end, 1)
                end
            end)
        end
    end
    UnblockLoader.load(funcTable, tag)
end

function TeamDropMgr.hide()
    UnblockLoader.cancel(tag)
    for var=1, #listVec do
    	CSResourceMgr.removeListByNode(listVec[var])
    end
    listVec = {}
	CSResourceMgr.removeCSObjectByTag(resName)
	UIStack.pop(tag)
end

return TeamDropMgr