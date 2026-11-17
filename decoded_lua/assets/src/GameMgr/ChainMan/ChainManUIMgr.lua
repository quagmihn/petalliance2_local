local ChainManUIMgr = class("ChainManUIMgr")
local resBk  	= "Pet/Formation/FormationBGNew.csb"
local res    	= "ChainMan/ChainManLayer.csb"
local scene  	= nil
local editBox 	= nil
local restCountstr = ""
local orderNumStr  = ""
local effAni = nil

function ChainManUIMgr.hide()
	CSResourceMgr.removeCSObjectByTag(resBk)
	CSResourceMgr.removeCSObjectByTag(res)
	StatusBarMgr.hideTopInfoBar()
end

function ChainManUIMgr.show(scene)
	local layer = nil
	local orderOwnCount = ItemInfo.getCharItemNum(9986)
	if nil == orderOwnCount then
		orderOwnCount = 0
	end
	local function loadDB()
		local layerDB = CSResourceMgr.createRes(scene,resBk)
		CocosModuleMgr.setRelativePosition(layerDB,320,480)
		layerDB:zorder(CocosModuleMgr.ZORDER_CHAT) 
	end
	local function loadCSB()
		layer = CSResourceMgr.createRes(scene,res)

		CocosModuleMgr.setRelativePosition(layer,320,480)
		CocosModuleMgr.setEdgeDistance(layer, nil, nil, 5, nil, false) 
		layer:zorder(CocosModuleMgr.ZORDER_CHAT)

		local diff 		   = CocosModuleMgr.getScreenSizeDiff()
		local itemPos      = CSResourceMgr.getNodeByName(res,"itemPos")
		local inputChain   = CSResourceMgr.getNodeByName(res,"inputChain")--inputOrder
		local npcPos       = CSResourceMgr.getNodeByName(res,"npc")
		local help         = CSResourceMgr.getNodeByName(res,"help")

		local title        = CSResourceMgr.getNodeByName(res,"title")
		local dialogTxt    = CSResourceMgr.getNodeByName(res,"dialogTxt")
		local rewardStr    = CSResourceMgr.getNodeByName(res,"rewardStr")	
		local downPart     = CSResourceMgr.getNodeByName(res,"downPart")
		local dialog       = CSResourceMgr.getNodeByName(res,"dialog")
		local editBG       = CSResourceMgr.getNodeByName(res,"editBG")
		
		local rewardItem  = ItemInfo.getItemIconById(9985,1) 

		rewardItem:addTo(itemPos)
		rewardItem:setPosition(10,10)
		rewardItem:setScale(0.6,0.6)

		CSResourceMgr.clickEventBindingByNode(rewardItem, function()
				ItemInfoViewMgr.show({id = 9985,type=1},false)
			end)

		resetLabelStr(title,false,{r=175,g=241,b=255,a=255},{r=31,g=56,b=78,a=255},1)
		resetLabelStr(dialogTxt,false)
		resetLabelStr(rewardStr,false,nil,{r=0,g=0,b=0,a=255},1)
		resetLabelStr(inputChain,false)

		if -1*diff < 0 then
			dialog:setPositionY(dialog:getPositionY()-diff/2) 
		end
		downPart:setPositionY(-1*diff)
		itemPos:setPositionY((dialog:getPositionY() + (-1*diff + 386))/2)
		local npcRes = "Spine/npc/em16.png"
		local npcAni = AnimationMgr.createAni(npcPos, npcRes, 
            30, -50)
		npcAni:setScale(-0.7,0.7)
		AnimationMgr.playAni(npcRes, "kaixin", true) 
		effAni = AnimationMgr.createAni(itemPos, "Spine/effects/Ui_chongwulingqujiemian.png", 
            10, 10 ,"BlockChain")
        effAni:setLocalZOrder(-1)
        effAni:setScale(0.5) 
        AnimationMgr.playAni(effAni.res, "animation", true, "BlockChain")
        dialogTxt:setString(dialogTxt:getString())
        CSResourceMgr.setLabelMaxWidthByNode(dialogTxt, 260)
        dialogTxt:setAnchorPoint(0,1)
		StatusBarMgr.showTopInfoBar(function()
			effAni:removeFromParent(true) 
             ChainManUIMgr.hide()
        end,1)

		editBox = CocosModuleMgr.newTextEditor(editBG,"empty.png",400,36,200,18,24,9999,"",1,function()         
            local data = tostring(editBox:getText())
            if data then
				print("---------AndroidFunction.DoBlockChain(data)-------")
            	AndroidFunction.DoBlockChain(data)
        	end
        	editBox:setText(data) 
        end)
		editBox:setText("")
		CSResourceMgr.clickEventBindingByNode(help, function()
				DialogBoxMgr.showSmallDialogBox(scene,1,"chain5",function()             
                    end,nil,nil,true)
			end)
	end
	local function Animation()
		CocosModuleMgr.showUIAnimation(layer, "down")
	end
	local funcTable = {loadDB,loadCSB,Animation}
	for key,var in pairs(funcTable) do
		var()
	end
	local function playCSB()
        CSResourceMgr.getCsbObj(res):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(res), "up", function()
        	--loadItem()
        end)
        loadItem()
    end
end 

return ChainManUIMgr