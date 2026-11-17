local DropInfoViewMgr = {}

local resName = ""

function DropInfoViewMgr.Init()
	resName = "Item/awardPreView.csb"
end

function DropInfoViewMgr.isShown()
	if CSResourceMgr.getCsbObj(resName) then
		return true
	else
	    return false
	end
end

---用掉落表id显示可获得奖励列表
--@param dropID number 掉落表id
function DropInfoViewMgr.showWithDropID(dropID)
    local awardElementVec = AdventureInfo.getDropInfoByID(dropID).reNumber
    DropInfoViewMgr.showWithAwardElements(awardElementVec)
end

---用奖励元素组显示可获得奖励列表
--@param awardElementVec table 奖励元素id组
--@param showNum bool 是否显示数量，默认显示
function DropInfoViewMgr.showWithAwardElements(awardElementVec, showNum)
    if type(awardElementVec)~="table" then
        print("DropInfoViewMgr.showWithAwardElements failed. parameter not table")
        return
    end
    local itemVec = ItemInfo.getAwardElementsItem(awardElementVec, showNum)
    DropInfoViewMgr.show(itemVec)
end

---用物品组显示可获得奖励列表
--@param itemVec table 物品组，比如{{1,99}, {2,99}, {"pet1", 1}}
function DropInfoViewMgr.show(itemVec, notShowTitle)
    if type(itemVec)~="table" then
        print("DropInfoViewMgr.show failed. parameter not table")
    	return
    end
    UIStack.push("DropInfoViewMgr", DropInfoViewMgr.hide, false)
    local funcTable = {}
	local function loadCSB()
		CSResourceMgr.createRes(SceneMgr.getRunningScene, resName):setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
		CSResourceMgr.setRelativePosition(resName, 320, 480)
		
		CSResourceMgr.clickEventBinding(resName, "close", function()
            DropInfoViewMgr.hide()
		end)
        CSResourceMgr.setLabelColor(resName, "title", {r=214,g=245,b=251,a=255})
        CSResourceMgr.setLabelString(resName, "title", "tips19", "", {r=26,g=37,b=48,a=255})
        CSResourceMgr.setLabelColor(resName, "info", {r=255,g=168,b=0,a=255})
        --修改英文版
        if LuaSqlite.LANG_TYPE ~= 1 and CSResourceMgr.getCsbObj("Player/MissionList.csb") then
            CSResourceMgr.setLabelString(resName, "info", "", "", {r=0,g=0,b=0,a=255,w=1})
        else
            if notShowTitle then
                CSResourceMgr.setLabelString(resName, "info", "", "", {r=0,g=0,b=0,a=255,w=1})
            else
                CSResourceMgr.setLabelString(resName, "info", "tips32", "", {r=0,g=0,b=0,a=255,w=1})
            end
        end
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)
        
        local scale = 0.75
        local list = CSResourceMgr.getNodeByName(resName, "list")
        local lsize = list:getContentSize()
        list:setContentSize(lsize.width/scale, lsize.height/scale)
        list:setScale(scale)
	end
    table.insert(funcTable, loadCSB)
    table.insert(funcTable, function()
        local node = CSResourceMgr.getNodeByName(resName, "db")
        node:setVisible(true)
        CocosModuleMgr.showUIAnimation(node, "down")
    end)
    for var=1, #itemVec do
        table.insert(funcTable, function()
            local parent = nil
            if itemVec[var][1]=="pet" then
                parent = ItemInfo.getItemIconById(1)
                CSResourceMgr.clickEventBindingByNode(parent, function()
                    GachaViewMgr.playGetAPet(itemVec[var][2])
                end)
                local petInfo = PokemonInfo.getPokemonInfoByID(itemVec[var][2])
                local btnRes = ItemInfo.getItemRareBGImage(nil, petInfo.rarePoint)
                CSResourceMgr.setButtonTextureByNode(parent, btnRes, btnRes, btnRes)
                local sprite = CSResourceMgr.seekNodeByName(parent, "s")
                CSResourceMgr.setSpriteTextureByNode(sprite, PokemonInfo.getPokemonIconByID(itemVec[var][2]))
                sprite:setScale(1.2)
            else
                parent = ItemInfo.getItemIconById(itemVec[var][1], itemVec[var][2])
                --[[
                CSResourceMgr.buttonEventBindingByNode(parent, function()
                ItemInfoViewMgr.show({id = itemVec[var][1],  sum = itemVec[var][2], type = 2}, false)
                end, function()
                ItemInfoViewMgr.hide()
                end, nil, function()
                ItemInfoViewMgr.hide()
                end)]]
                CSResourceMgr.clickEventBindingByNode(parent, function()
                    ItemInfoViewMgr.show({id = itemVec[var][1],  sum = itemVec[var][2]}, false)
                end)
            end
            CSResourceMgr.getNodeByName(resName, "list"):pushBackCustomItem(parent)
            parent:setScale(0)
            transition.scaleTo(parent, {scale=1, time=0.2})
        end)
    end
    UnblockLoader.load(funcTable, "DropInfoViewMgr.show")
end

function DropInfoViewMgr.hide()
    UnblockLoader.cancel("DropInfoViewMgr.show")
	CSResourceMgr.removeList(resName, "list")
	CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("DropInfoViewMgr")
end

return DropInfoViewMgr