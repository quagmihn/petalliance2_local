local MultiItemBoxView = class("MultiItemBoxView")
MultiItemBoxView.SelectableAwardInfo = nil

function MultiItemBoxView:ctor(info,callback)
	local layer = nil
	local function loadCSB()
	    local resName = "Item/multiItemBox.csb"
	    layer = CSResourceMgr.createRes(SceneMgr.getRunningScene,resName)
	    CocosModuleMgr.setRelativePosition(layer,320,480)
	    layer:zorder(CocosModuleMgr.ZORDER_FLOAT) 
	    local list      = CSResourceMgr.getNodeByName(resName,"list")
	    local titleStr  = CSResourceMgr.getNodeByName(resName,"titleStr")
	    local sure      = CSResourceMgr.getNodeByName(resName,"sure")
	    local close     = CSResourceMgr.getNodeByName(resName,"close")
	    local item      = CSResourceMgr.getNodeByName(resName,"item")
	    local selectStr = CSResourceMgr.getNodeByName(resName,"selectStr")

	    local items     = {}
	    local resSel = "Battle/funcMenu/fight_auto_form.png"
	    local selSp  = nil

	    resetLabelStr(titleStr,false,{r=255,g=234,b=0,a=255},{r=0,g=0,b=0,a=255},1)
	    resetLabelStr(sure,true,nil,{r=0,g=0,b=0,a=255},1)
	    resetLabelStr(selectStr,false)

	    if nil == MultiItemBoxView.SelectableAwardInfo then
		    MultiItemBoxView.SelectableAwardInfo = require("src.DatReader.SelectableAwardInfoConfig")
		    MultiItemBoxView.SelectableAwardInfo.init()
		end
	    local iteminfo = ItemInfo.getItemInfoById(info.id)
	    local SelectableAwardInfo = MultiItemBoxView.SelectableAwardInfo.readEntryByID(iteminfo.paramA)

	    
	    for key,var in pairs(SelectableAwardInfo.elements) do
	        local element = ItemInfo.getAwardElementInfoById(var)
	        local itemID  = element.elementID
	        if element.elementType ==3 then
	            
	            items[key] = ItemInfo.getItemIconById(itemID,SelectableAwardInfo.nums[key])
	        elseif element.elementType==5 then
	        	itemID = PokemonInfo.getGeneInfoByID(element.elementID).petID
	            items[key]  = ItemInfo.getPetIconById2(itemID, SelectableAwardInfo.nums[key], 
	                        nil, nil, nil)
	        else
	            itemID = ItemInfo.AWARD[element.elementType]
	            items[key] = ItemInfo.getItemIconById(itemID,SelectableAwardInfo.nums[key])
	        end

	        items[key].sel = false
	        items[key].num = SelectableAwardInfo.nums[key]
	        items[key].name = SelectableAwardInfo.name

	        CSResourceMgr.buttonEventBindingByNodeXP(items[key], function()
	        end, function()
	            if false == items[key].sel then
	                if nil ~= selSp then
	                    items[selSp.id].sel = false
	                    selSp.node:removeFromParent(true) 
	                end
	                selSp = {}
	                selSp.node = display.newSprite(resSel)
	                selSp.node:addTo(items[key])
	                selSp.element = element
	                selSp.itemID  = itemID
	                selSp.id = key
	                selSp.num = SelectableAwardInfo.nums[key]
	        		selSp.name = SelectableAwardInfo.name
	        		selSp.itemInfo = ItemInfo.getItemInfoById(itemID) 
	                selSp.node:zorder(10)
	                selSp.node:setPosition(120,20) 
	                items[key].sel = true
	            else
	                selSp.node:removeFromParent(true)
	                selSp = nil
	                items[key].sel = false
	            end
	        end, nil, function()
	        end, false, nil, function()

            		if element.elementType ~= 5 then
            			ItemInfoViewMgr.show({id = itemID,type = 1}, false)
            		else
            			PetInfoViewMgr.show(SceneMgr.getRunningScene, itemID,function()

            				end)
            		end

	        end)

	    end
	    local nums = #items
	    local col = math.ceil(nums/3)
	    local itemDB = {}
	    local posY = 85.50
	    local posX = {[0]=421.50,[1]=94.00,[2]=256.50}
	    for i = 1,col do
	        itemDB[i] = item:clone()
	        list:pushBackCustomItem(itemDB[i])
	    end

	    for key,var in pairs(items) do
	        var:addTo(itemDB[math.ceil(key/3)])
	        var:setPosition(posX[key%3],posY)
	    end

	    CSResourceMgr.clickEventBindingByNode(close, function()
	            CSResourceMgr.removeCSObjectByTag(resName)
	        end, 1)

	    CSResourceMgr.clickEventBindingByNode(sure, function()
	    	if nil == selSp then
	    		print("请选择道具")
	    		return
	    	end
	    	if callback then
	    		callback()
	    	end
	    	CSResourceMgr.removeCSObjectByTag(resName)
	    	NetInterface.sendWithBlock("GC_UseItem_Ack", function()
                    print("MultiItemBoxView:item:", info.id, "num:",selSp.id-1)
                    local ItemSend = require("src.Net.Send.ItemSend")
                    ItemSend.sendCG_UseItem_Req({itemID=info.id, targetNum=selSp.id-1, targetStr="", chest=true, useNum=selSp.num})
                end, function()
                    print("使用单个物品成功")
                    -- StandardTipsMgr.show(0, "iteminfo30")
                    local rewardInfo = {}
                    local award = {}
                    local cjson = require("cjson")
                    rewardInfo.aID = 1
                    rewardInfo.num = selSp.num
                    rewardInfo.elementID = selSp.itemID
                    rewardInfo.elementType = "item"
                    if nil ~= selSp.itemInfo and Proto.IC_EQUIP == selSp.itemInfo.itemType then
                    	info.elementType = "equip"
                    else
	                    if selSp.element.elementType==5 then
							rewardInfo.elementType = "pet"
						end
					end
					award[1] = cjson.encode(rewardInfo)
					AwardsListMgr.show(SceneMgr.getRunningScene,award)
                end, function(code)
                    TreeInfoView.isOpenBox = false
                    if code==Proto.Error.ERROR_FASHION_EXIST then
                        StandardTipsMgr.show(1, "fashiontip1")
                    elseif code==Proto.Error.ERROR_TREE_ALREADY_EXIST then
                        StandardTipsMgr.show(1, "TreeInfo10")
                    elseif code==-1 then
                        ItemInfo.reqItemNum({info.id})
                    else
                        TipsMgr.showError(scene, code)
                    end
                end,nil,false)

	        end, 1)
	end


	local function Animation()
	    CocosModuleMgr.showUIAnimation(layer, "down")
	end
	loadCSB()
	Animation()
end

return MultiItemBoxView