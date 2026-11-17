local TrainStoneMgr = {}

TrainStoneMgr.MAIN_VIEW_HEIGHT = 650
TrainStoneMgr.LIST_MIN_HEIGHT = 200
TrainStoneMgr.ITEM_RANK_NUM = 3
TrainStoneMgr.ITEM_SYN_NUM = 3

local resNameBG = ""
local resNameA = ""
local resNameB = ""
local curTab = 1
local curItemTab = {1, 1}
local itemNodes = {}

function TrainStoneMgr.Init()
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    resNameA = "Item/Stone/TrainStoneUpside.csb"
    resNameB = "Item/Stone/TrainStonrDownside.csb"
    curTab = 1
    curItemTab = {1, 1}
    itemNodes = {}
end

function TrainStoneMgr.show(scene)
    local needLv = SystemInfo.getGlobalConfigAddInfoByID(24011).values[1]
    if CharInfo.getLevel() < needLv then
        DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 2, "train98")
        return
    end
    if CSResourceMgr.getCsbObj(resNameA) and CSResourceMgr.getCsbObj(resNameB) then
        return
    end
    UIStack.push("TrainStoneMgr", TrainStoneMgr.hide, true)
    
    local editBox = nil
    local selItem = {}
    local selItemNodes = {}
    local maxNum = 0
    local selNum = 0
    local itemTabString = {"bag1", "iteminfo37", "iteminfo38", "iteminfo39", "iteminfo40"}
    local tabString = {"PetPiece1", "iteminfo36"}
    local screenDiff = 1136-960-CocosModuleMgr.getScreenSizeDiff()
    local itemIDs = {
        {130, 131, 132, 133, 134, 135,},
        {136, 137, 138, 139, 140, 141,},
        {142, 143, 144, 145, 146, 147,},
        {148, 149, 150, 151, 152, 153,},
    }
    
    local function getItemIndex(itemid)
        local index1 = 1
        local index2 = 1
        for var=1, #itemIDs do
            index1 = var
            local boolC = false
            for v=1, #itemIDs[var] do
                if itemIDs[var][v]==itemid then
    				index2 = v
    				boolC = true
    				break
    			end
    		end
    		if boolC then
    			break
    		end
    	end
        return index1, index2
    end
    
    local function initItem(parent, button, itemid)
        local num = ItemInfo.getCharItemNum(itemid)
        local posx = button:getPositionX()
        local posy = button:getPositionY()
        local iBtn = ItemInfo.getItemIconById(itemid, num)
        iBtn:addTo(parent)
        iBtn:pos(posx, posy)
        itemNodes[itemid] = {iBtn, button}
        TrainStoneMgr.refreshItem(itemid, num)
        iBtn:scale(0)
        transition.scaleTo(iBtn, {scale=0.75, time=0.1})
        CSResourceMgr.clickEventBindingByNode(button, function()
            selNum = 0
        	if curTab==1 then
                CSResourceMgr.callButtonFunc(resNameA, "cancel")
                selItem[1] = itemid
                maxNum = math.floor(ItemInfo.getCharItemNum(selItem[1])/TrainStoneMgr.ITEM_SYN_NUM)
                local index1, index2 = getItemIndex(itemid)
                print(index1, index2, "ssssssss")
                local iInfo = ItemInfo.getItemInfoById(itemIDs[index1+1][index2])
                CSResourceMgr.setSpriteTexture(resNameA, "bigicon", iInfo.icon)
                CSResourceMgr.setLabelColor(resNameA, "bigname", ItemInfo.COLOR[iInfo.itemRare+1])
                CSResourceMgr.setLabelString(resNameA, "bigname", iInfo.name, "", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 250)
                local function addShowIcon(index)
                    local parent = CSResourceMgr.getNodeByName(resNameA, "sicondb"..index)
                    local iNode = ItemInfo.getItemIconById(itemid)
                    iNode:addTo(parent)
                    iNode:pos(parent:getContentSize().width/2, parent:getContentSize().height/2)
                    iNode:scale(0.6)
                    selItemNodes[index] = iNode
                end
                if maxNum>0 then
                    for var=1, TrainStoneMgr.ITEM_SYN_NUM do
                        addShowIcon(var)
                	end
                	selNum = 1
                    CSResourceMgr.setLabelString(resNameA, "bignum", "x"..selNum, "", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 100)
                    CSResourceMgr.getNodeByName(resNameA, "bigicon"):setColor({r=255,g=255,b=255})
                else
                    for var=1, ItemInfo.getCharItemNum(selItem[1]) do
                        addShowIcon(var)
                    end
                    selNum = 0
                    CSResourceMgr.setLabelString(resNameA, "bignum", "x"..selNum, "", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 100)
                    CSResourceMgr.getNodeByName(resNameA, "bigicon"):setColor({r=77,g=77,b=77})
                end
            elseif curTab==2 then
                if #selItem>=2 then
                    StandardTipsMgr.show(1, "iteminfo47")
                	return
                end
                maxNum = 0
                if selItem[1] then
                    local index1, index2 = getItemIndex(selItem[1])
                    local nIndex1, nIndex2 = getItemIndex(itemid)
                    if index1~=nIndex1 then
                        StandardTipsMgr.show(1, "iteminfo48")
                    	return
                    end
                end
                table.insert(selItem, itemid)
                local parent = CSResourceMgr.getNodeByName(resNameA, "licondb"..#selItem)
                local iNode = ItemInfo.getItemIconById(itemid)
                iNode:addTo(parent)
                iNode:pos(parent:getContentSize().width/2, parent:getContentSize().height/2)
                iNode:scale(0.85)
                selItemNodes[#selItem] = iNode
                if #selItem==2 then
                    maxNum = ItemInfo.getCharItemNum(selItem[1])
                    if maxNum>ItemInfo.getCharItemNum(selItem[2]) then
                        maxNum = ItemInfo.getCharItemNum(selItem[2])
                	end
                    if selItem[1]==selItem[2] then
                		maxNum = math.floor(maxNum/2)
                	end
                end
        	end
        	if maxNum>0 then
                CSResourceMgr.setButtonEnabled(resNameA, "minus", true)
                CSResourceMgr.setButtonEnabled(resNameA, "plus", true)
                CSResourceMgr.setButtonEnabled(resNameA, "max", true)
                CSResourceMgr.setButtonEnabled(resNameA, "ok", true)
                selNum = 1
                CSResourceMgr.setLabelString(resNameA, "enum", selNum)
                CSResourceMgr.setLabelString(resNameA, "money", selNum*9999)
        	end
            CSResourceMgr.setButtonEnabled(resNameA, "cancel", true)
            CSResourceMgr.getNodeByName(resNameA, "idbinfostr"):hide()
            CSResourceMgr.getNodeByName(resNameA, "idbinfodb"):hide()
        end)
    end
    
    local function checkItemTab(tabid)
        curItemTab[curTab] = tabid

        if curTab==1 then
            local bNode = CSResourceMgr.getNodeByName(resNameB, "ab"..tabid)
            for v=1, #itemTabString-1 do
                local sNode = CSResourceMgr.getNodeByName(resNameB, "ab"..v)
                sNode:hide()
            end
            bNode:show()
        elseif curTab==2 then
            local bNode = CSResourceMgr.getNodeByName(resNameB, "bb"..tabid)
            for v=1, #itemTabString do
                local sNode = CSResourceMgr.getNodeByName(resNameB, "bb"..v)
                sNode:hide()
            end
            bNode:show()
        end
        
        itemNodes = {}
        UnblockLoader.cancel("TrainStoneMgr.checkItemTab")
        CSResourceMgr.removeList(resNameB, "list")
        local curItemIDs = {}
        if tabid==1 then
        	if curTab==1 then
                for var=1, #itemTabString-2 do
                    for v=1, #itemIDs[var] do
                        table.insert(curItemIDs, itemIDs[var][v])
        			end
        		end
            elseif curTab==2 then
                for var=1, #itemTabString-1 do
                    for v=1, #itemIDs[var] do
                        table.insert(curItemIDs, itemIDs[var][v])
                    end
                end
        	end
        else
            curItemIDs = itemIDs[tabid-1]
        end
        local funcTable = {}
        local panelVec = {}
        for var=1, #curItemIDs do
            local row = math.ceil(var/TrainStoneMgr.ITEM_RANK_NUM)
            local rank = var%TrainStoneMgr.ITEM_RANK_NUM
            if rank==0 then
                rank = TrainStoneMgr.ITEM_RANK_NUM
            end
            if rank==1 then
                table.insert(funcTable, function()
                    local parent = CSResourceMgr.getNodeByName(resNameB, "example"):clone()
                    CSResourceMgr.getNodeByName(resNameB, "list"):pushBackCustomItem(parent)
                    parent:show()
                    table.insert(panelVec, parent)
                end)
            end
            table.insert(funcTable, function()
                local pNode = CSResourceMgr.seekNodeByName(panelVec[row], "ibtn"..rank)
                pNode:zorder(1)
                pNode:show()
                initItem(panelVec[row], pNode, curItemIDs[var])
                local itemInfo = ItemInfo.getItemInfoById(curItemIDs[var])
                local itemName = CSResourceMgr.seekNodeByName(panelVec[row], "iname"..rank)
                itemName:show()
                CSResourceMgr.setLabelColorByNode(itemName, ItemInfo.COLOR[itemInfo.itemRare+1])
                CSResourceMgr.setLabelStringByNode(itemName, itemInfo.name, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 150)
            end)
        end
        
        UnblockLoader.load(funcTable, "TrainStoneMgr.checkItemTab")
    end
    
    local function checkTab(tabid)
    	curTab = tabid
        
        CSResourceMgr.callButtonFunc(resNameA, "cancel")
        CSResourceMgr.setLabelString(resNameA, "oktitle", tabString[tabid], "", {r=0,g=0,b=0,a=255,s=1,w=1}, nil, 90)
        local node1 = CSResourceMgr.getNodeByName(resNameB, "node1")
        local nodeb1 = CSResourceMgr.getNodeByName(resNameB, "nodeb1")
        local node2 = CSResourceMgr.getNodeByName(resNameB, "node2")
        local nodeb2 = CSResourceMgr.getNodeByName(resNameB, "nodeb2")
        local nodea1 = CSResourceMgr.getNodeByName(resNameA, "node1")
        local nodea2 = CSResourceMgr.getNodeByName(resNameA, "node2")
        local colorVec = {{r=255,g=243,b=227,a=255}, {r=227,g=233,b=255,a=255}}
        if tabid==1 then
            CSResourceMgr.setLabelString(resNameA, "idbinfostr", "iteminfo42", "", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 600)
            node1:show()
            nodea1:show()
            nodeb1:show()
            node2:hide()
            nodea2:hide()
            nodeb2:hide()
            CSResourceMgr.setButtonEnabled(resNameA, "tab1", false)
            CSResourceMgr.setButtonEnabled(resNameA, "tab2", true)
            CSResourceMgr.setButtonStringColor(resNameA, "tab1", colorVec[1])
            CSResourceMgr.setButtonStringColor(resNameA, "tab2", colorVec[2])
        elseif tabid==2 then
            CSResourceMgr.setLabelString(resNameA, "idbinfostr", "iteminfo43", "", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 600)
            node2:show()
            nodea2:show()
            nodeb2:show()
            node1:hide()
            nodea1:hide()
            nodeb1:hide()
            CSResourceMgr.setButtonEnabled(resNameA, "tab1", true)
            CSResourceMgr.setButtonEnabled(resNameA, "tab2", false)
            CSResourceMgr.setButtonStringColor(resNameA, "tab1", colorVec[2])
            CSResourceMgr.setButtonStringColor(resNameA, "tab2", colorVec[1])
        end
        
        local circle = CSResourceMgr.getNodeByName(resNameA, "idb")
        local posyVec = {220, 300}
        if posyVec[tabid] then
            transition.stopTarget(circle)
            transition.moveTo(circle, {y=posyVec[tabid], time=0.1})
        end
        
        checkItemTab(curItemTab[curTab])
    end
    
    scene = scene or SceneMgr.getRunningScene
    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG, "TrainStoneMgr")
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "TrainStoneMgr")
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    end
    
    local function loadCSBA()
        local layerTop = CSResourceMgr.createRes(scene, resNameA)
        layerTop:zorder(CocosModuleMgr.ZORDER_WINDOW)
        CocosModuleMgr.setRelativePosition(layerTop, 320, 480)
        CocosModuleMgr.setEdgeDistance(layerTop, nil, nil, 65, nil)
        
        if screenDiff>TrainStoneMgr.LIST_MIN_HEIGHT then
            local yDiff = screenDiff-TrainStoneMgr.LIST_MIN_HEIGHT
            local rate = (TrainStoneMgr.MAIN_VIEW_HEIGHT-yDiff)/TrainStoneMgr.MAIN_VIEW_HEIGHT
            layerTop:scale(rate)
            local posy = layerTop:getPositionY()
            layerTop:setPositionY(posy+TrainStoneMgr.MAIN_VIEW_HEIGHT*(1-rate)*0.75)
        end
        
        CocosModuleMgr.showUIAnimation(layerTop, "down")
    end
    
    local function loadCSBB()
        local layerDown = CSResourceMgr.createRes(scene, resNameB)
        layerDown:zorder(CocosModuleMgr.ZORDER_WINDOW)
        CocosModuleMgr.setRelativePosition(layerDown, 320, 480)
        CocosModuleMgr.setEdgeDistance(layerDown, nil, nil, nil, 0)
        
        if screenDiff>TrainStoneMgr.LIST_MIN_HEIGHT then
            screenDiff = TrainStoneMgr.LIST_MIN_HEIGHT
        end
        local list = CSResourceMgr.getNodeByName(resNameB, "list")
        local lsize = list:getContentSize()
        list:setContentSize(lsize.width, lsize.height-screenDiff)
        local listdb = CSResourceMgr.getNodeByName(resNameB, "listdb")
        local ldbsize = listdb:getContentSize()
        listdb:setContentSize(ldbsize.width, ldbsize.height-screenDiff)

        CocosModuleMgr.showUIAnimation(layerDown, "up")
    end
    
    local function loadFinish()
        StatusBarMgr.showTopInfoBar(function()
            TrainStoneMgr.hide()
        end)
        
        --[[
        editBox =  CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resNameA, "edb"), "empty.png", 90, 40, 50, 20, 24, 50,
            "", 2, function()
            end)
        editBox:setText("0")
        ]]
        CSResourceMgr.setButtonString(resNameA, "max", "iteminfo41", "", {r=0,g=0,b=0,a=255,s=1,w=1})
        CSResourceMgr.setButtonString(resNameA, "cancel", "tips4", "", {r=0,g=0,b=0,a=255,s=1,w=1})
        CSResourceMgr.setLabelString(resNameA, "money", "0", "", {r=0,g=0,b=0,a=255,s=1,w=1}, nil, 140)
        CSResourceMgr.setLabelString(resNameA, "enum", selNum, "", {r=0,g=0,b=0,a=255,s=1,w=1}, nil, 100)
        CSResourceMgr.setLabelColor(resNameA, "idbinfostr", {r=0,g=240,b=255,a=255})
        
        CSResourceMgr.clickEventBinding(resNameA, "cancel", function()
            CSResourceMgr.setButtonEnabled(resNameA, "minus", false)
            CSResourceMgr.setButtonEnabled(resNameA, "plus", false)
            CSResourceMgr.setButtonEnabled(resNameA, "max", false)
            CSResourceMgr.setButtonEnabled(resNameA, "ok", false)
            CSResourceMgr.setButtonEnabled(resNameA, "cancel", false)
            CSResourceMgr.getNodeByName(resNameA, "idbinfostr"):show()
            CSResourceMgr.getNodeByName(resNameA, "idbinfodb"):show()
            for key, var in pairs(selItem) do
                TrainStoneMgr.refreshItem(var)
            end
            selItem = {}
            for key, var in pairs(selItemNodes) do
            	var:removeFromParent(true)
            end
            selItemNodes = {}
            selNum = 0
            CSResourceMgr.setLabelString(resNameA, "enum", selNum)
            CSResourceMgr.setLabelString(resNameA, "money", selNum*9999)
            CSResourceMgr.setLabelString(resNameA, "bigname", "")
            CSResourceMgr.setLabelString(resNameA, "bignum", "")
            CSResourceMgr.setSpriteTexture(resNameA, "bigicon", "empty.png")
        end)
        CSResourceMgr.clickEventBinding(resNameA, "ok", function()
        	if curTab==1 then
                if not selItem[1] then
        	    	return
        	    end
                local index1, index2 = getItemIndex(selItem[1])
        	    local iInfo = ItemInfo.getItemInfoById(itemIDs[index1+1][index2])
                DialogBoxMgr.showSmallDialogBox(scene, 2, CocosModuleMgr.createStringWithFormat({"iteminfo45", selNum, 
                    ItemInfo.COLOR_16[iInfo.itemRare+1], iInfo.name}), function()

                end)
        	elseif curTab==2 then
                DialogBoxMgr.showSmallDialogBox(scene, 2, "iteminfo46", function()
                	
                end)
        	end
        end)
        CSResourceMgr.clickEventBinding(resNameA, "minus", function()
            if selNum>1 then
                selNum = selNum-1
                CSResourceMgr.setLabelString(resNameA, "enum", selNum)
                CSResourceMgr.setLabelString(resNameA, "money", selNum*9999)
                CSResourceMgr.setLabelString(resNameA, "bignum", "x"..selNum, "", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 100)
            end
        end)
        CSResourceMgr.clickEventBinding(resNameA, "plus", function()
            if selNum<maxNum then
                selNum = selNum+1
                CSResourceMgr.setLabelString(resNameA, "enum", selNum)
                CSResourceMgr.setLabelString(resNameA, "money", selNum*9999)
                CSResourceMgr.setLabelString(resNameA, "bignum", "x"..selNum, "", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 100)
            end
        end)
        CSResourceMgr.clickEventBinding(resNameA, "max", function()
            selNum = maxNum
            CSResourceMgr.setLabelString(resNameA, "enum", selNum)
            CSResourceMgr.setLabelString(resNameA, "money", selNum*9999)
            CSResourceMgr.setLabelString(resNameA, "bignum", "x"..selNum, "", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 100)
        end)
        
        for var=1, #tabString do
        	CSResourceMgr.setButtonString(resNameA, "tab"..var, tabString[var], "", {r=0,g=0,b=0,a=128,s=1,w=1})
        	CSResourceMgr.clickEventBinding(resNameA, "tab"..var, function()
        		checkTab(var)
        	end)
        end
        
        for var=1, #itemTabString-1 do
            CSResourceMgr.setButtonString(resNameB, "atab"..var, itemTabString[var], "", {r=0,g=0,b=0,a=128,w=2})
            local bNode = CSResourceMgr.getNodeByName(resNameB, "ab"..var)
            CSResourceMgr.buttonEventBinding(resNameB, "atab"..var, function()
            	bNode:show()
            end, function()
                checkItemTab(var)
            end, nil, function()
            	bNode:hide()
            end)
        end
        for var=1, #itemTabString do
            CSResourceMgr.setButtonString(resNameB, "btab"..var, itemTabString[var], "", {r=0,g=0,b=0,a=128,w=2})
            local bNode = CSResourceMgr.getNodeByName(resNameB, "bb"..var)
            CSResourceMgr.buttonEventBinding(resNameB, "btab"..var, function()
                bNode:show()
            end, function()
                checkItemTab(var)
            end, nil, function()
                bNode:hide()
            end)
        end
        
        checkTab(curTab)
    end    
    
    local funcTable = {loadBG, loadCSBA, loadCSBB, loadFinish}
    UnblockLoader.load(funcTable, "TrainStoneMgr.show")
end

function TrainStoneMgr.hide()
    StatusBarMgr.hideTopInfoBar()
    UnblockLoader.cancel("TrainStoneMgr.checkItemTab")
    UnblockLoader.cancel("TrainStoneMgr.show")
    itemNodes = {}
    CSResourceMgr.removeCSObjectByTag(resNameBG, "TrainStoneMgr")
    CSResourceMgr.removeList(resNameB, "list")
    CSResourceMgr.removeCSObjectByTag(resNameA)
    CSResourceMgr.removeCSObjectByTag(resNameB)
    GameAudio.playUISound("retract")
    UIStack.pop("TrainStoneMgr")
end

function TrainStoneMgr.refreshItem(itemid, num)
    if not CSResourceMgr.getCsbObj(resNameB) then
		return
	end
    if itemNodes[itemid] then
        num = num or ItemInfo.getCharItemNum(itemid)
        local sprite = CSResourceMgr.seekNodeByName(itemNodes[itemid][1], "s")
        local label = CSResourceMgr.seekNodeByName(itemNodes[itemid][1], "l")
        if num<=0 then
            itemNodes[itemid][1]:setColor({r=77,g=77,b=77})
            sprite:setColor({r=77,g=77,b=77})
            CSResourceMgr.setButtonEnabledByNode(itemNodes[itemid][2], false)
            label:hide()
        else
            itemNodes[itemid][1]:setColor({r=255,g=255,b=255})
            sprite:setColor({r=255,g=255,b=255})
            CSResourceMgr.setButtonEnabledByNode(itemNodes[itemid][2], true)
            CSResourceMgr.setLabelStringByNode(label, num, CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS, nil, 120)
            label:show()
        end
	end
end

return TrainStoneMgr