local PetFreeListMgr = {}

PetFreeListMgr.ITEM1 = 10001
PetFreeListMgr.ITEM2 = 9993
PetFreeListMgr.ITEM3 = 9992

local resName = ""
local itemVec = {}
local pageNodes = {}
local awardsItem = {}
local curIndex = 1
local isFreedom = false

function PetFreeListMgr.Init()
    resName = "Pet/Formation/FreeListView.csb"
    itemVec = {}
    pageNodes = {}
    awardsItem = {}
    curIndex = 1
    isFreedom = false
end

local function checkPages()
    for var=1, #pageNodes do
        pageNodes[var]:hide()
    end
    if pageNodes[curIndex] then
        pageNodes[curIndex]:show()
    end
    local b1 = CSResourceMgr.getNodeByName(resName, "leftBtn")
    local b2 = CSResourceMgr.getNodeByName(resName, "rightBtn")
    b1:show()
    b2:show()
    if curIndex<=1 then
    	b1:hide()
    end
    if curIndex>=#pageNodes then
    	b2:hide()
    end
end

function PetFreeListMgr.hide()
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
	CSResourceMgr.removeCSObjectByTag(resName)
    isFreedom = false
end

function PetFreeListMgr.show(scene)
    itemVec = {}
    pageNodes = {}
    awardsItem = {}
    curIndex = 1
    isFreedom = false
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName)
        CocosModuleMgr.setEdgeDistance(curLayer, nil, nil, nil, 0)

        CSResourceMgr.setLabelColor(resName,"title_award",{r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelString(resName,"title_award","train70","",{r=209,g=138,b=0,a=255})
        
        CSResourceMgr.getNodeByName(resName, "bg_award1"):hide()
        CSResourceMgr.getNodeByName(resName, "bg_award2"):hide()
        
        CSResourceMgr.clickEventBinding(resName, "leftBtn", function()
            if curIndex<=1 then
        		return
        	end
            curIndex = curIndex-1
            checkPages()
        end, nil, 1)
        CSResourceMgr.clickEventBinding(resName, "rightBtn", function()
            if curIndex>=#pageNodes then
            	return
            end
            curIndex = curIndex+1
            checkPages()
        end, nil, 1)
    end
    
    local function playCSB()
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName,"awards"),"up")
    end
    
    loadCSB()
    playCSB()
end

function PetFreeListMgr.setAwardsCount(addPetVec, delPetVec)
    local function itemChange(id, mindiff, maxdiff)
        if not id or not mindiff then
        	return
        end
        if not itemVec[id] then
    		itemVec[id] = {0, 0}
    	end
        itemVec[id][1] = itemVec[id][1]+mindiff
        itemVec[id][2] = itemVec[id][2]+(maxdiff or mindiff)
    end
    if addPetVec then
        for key, var in pairs(addPetVec) do
            local count = PokemonInfo.getPetFreedomAwardInfoByID(var)
            itemChange(PetFreeListMgr.ITEM1, count.skill_s)
            itemChange(PetFreeListMgr.ITEM2, count.dreamCash)
            itemChange(PetFreeListMgr.ITEM3, count.wishCash)
            if count.scienceItem and count.scienceItemNum then
                itemChange(count.scienceItem, count.scienceItemNum[1] or 0, count.scienceItemNum[2] or 0)
            end
    	end
    end
    if delPetVec then
        if type(delPetVec)=="table" then
            for key, var in pairs(delPetVec) do
                local count = PokemonInfo.getPetFreedomAwardInfoByID(var)
                itemChange(PetFreeListMgr.ITEM1, -count.skill_s)
                itemChange(PetFreeListMgr.ITEM2, -count.dreamCash)
                itemChange(PetFreeListMgr.ITEM3, -count.wishCash)
                if count.scienceItem and count.scienceItemNum then
                    itemChange(count.scienceItem, (count.scienceItemNum[1] or 0)*-1, (count.scienceItemNum[2] or 0)*-1)
                end
            end
        else
            itemVec = {}
        end
    end
    
    local index = 0
    local pageItemPosx = {105, 225, 345, 465}
    for var=1, #pageNodes do
        pageNodes[var]:removeAllChildren()
    end
    local sortItemVec = {}
    for key, var in pairs(itemVec) do
    	table.insert(sortItemVec, {key, var})
    end
    table.sort(sortItemVec, function(a, b)
        return a[1]>b[1]
    end)
    for n=1, #sortItemVec do
        local key = sortItemVec[n][1]
        local var = sortItemVec[n][2]
    	if var[1]>=0 and var[2]>0 then
    	    local itemNode = ItemInfo.getItemIconById(key, nil, nil, true)
            itemNode:scale(0.7)
            local label = CSResourceMgr.seekNodeByName(itemNode, "l")
            local numStr = tostring(var[1])
    		if var[1]~=var[2] then
                numStr = var[1].."~"..var[2]
    		end
            CSResourceMgr.setLabelStringByNode(label, "x"..numStr, CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS, nil, 120)
            CSResourceMgr.buttonEventBindingByNode(itemNode, function()
                ItemInfoViewMgr.show({id = key, type = 2}, false)
            end, function()
                ItemInfoViewMgr.hide()
            end, nil, function()
                ItemInfoViewMgr.hide()
            end)
            index = index+1
            local pageIndex = math.ceil(index/#pageItemPosx)
            if not pageNodes[pageIndex] then
            	pageNodes[pageIndex] = display.newSprite("empty.png")
                pageNodes[pageIndex]:addTo(CSResourceMgr.getNodeByName(resName, "awards"))
                pageNodes[pageIndex]:pos(0, 0)
            end
            itemNode:addTo(pageNodes[pageIndex])
            itemNode:pos(pageItemPosx[index-(pageIndex-1)*#pageItemPosx], 80)
    	end
    end
    for var=math.ceil(index/#pageItemPosx)+1, #pageNodes do
        pageNodes[var]:removeFromParent(true)
        pageNodes[var] = nil
    end
    if curIndex>#pageNodes then
    	curIndex = 1
    end
    checkPages()
end

function PetFreeListMgr.addAwardsItem(vec)
    if isFreedom then
        local cjson = require("cjson")
        for var=1, #vec do
            local tbl = cjson.decode(vec[var])
            local id = tonumber(tbl.itemID)
            local num = tonumber(tbl.num)
            if id and num then
                table.insert(awardsItem, {id, num-ItemInfo.getCharItemNum(id)})
            end
        end
    end
end

function PetFreeListMgr.showGetAwards()
    AwardsListMgr.show(SceneMgr.getRunningScene, awardsItem)
    PetFreeListMgr.setIsFreedomPets(false)
end

function PetFreeListMgr.setIsFreedomPets(val)
    awardsItem = {}
    isFreedom = val
end

return PetFreeListMgr