local PlayerChangeNameMgr = {}

local resName = {}

local labelColor = {
    {r=255,g=255,b=255,a=255},
    {r=144,g=238,b=255,a=255},
}


local outlineColor = {
    {r=0,g=0,b=0,a=255},
    {r=0,g=0,b=0,a=255,w=1,s=1},
    {r=0,g=0,b=0,a=255,w=1,s=2},
}

function PlayerChangeNameMgr.init()
	resName = "Pet/Education/PetChangeName.csb"
end

function PlayerChangeNameMgr.show(scene,callback)
	UIStack.push("PlayerChangeNameMgr", PlayerChangeNameMgr.hide, false)
	local function loadCSB()
		local layer = CSResourceMgr.createRes(scene, resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName)
        CSResourceMgr.setRelativePosition(resName, 320, 480)

        local panel = CSResourceMgr.getNodeByName(resName, "panel")
        panel:setVisible(false)

        local btnClose = CSResourceMgr.getNodeByName(resName, "btn")
        CSResourceMgr.clickEventBindingByNode(btnClose, function ()
            PlayerChangeNameMgr.hide()
            if closeCallback ~= nil then closeCallback() end
        end)
	end
	local function sendChangeNameMsg(nameStr)
		
		NetInterface.sendWithBlock("GC_ChangeName_Ack", function()
            local ItemSend = require("src.Net.Send.ItemSend")
            ItemSend.sendCG_ChangeName_Req({
                nickname = nameStr
                })
            end,
            function ()
            		CSResourceMgr.getNodeByName("Charactor/CharactorLayer.csb","name"):setString(nameStr)
            		DialogBoxMgr.showDialogBox(scene, 1, "editname6")
			 		PetChangeNameMgr.hide()
					if callback then
			    		callback(nameStr)
			    	end
			    	CharInfo.setNickName(nameStr)
            end,
            function ()
                DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 1, "????????")
            end)
	end
	local function loadUI()
        local labelTitle1 = CSResourceMgr.getNodeByName(resName, "title")
        local labelTitle2 = CSResourceMgr.getNodeByName(resName, "title2")
        local labelFree   = CSResourceMgr.getNodeByName(resName, "str_free")
        local labelNum    = CSResourceMgr.getNodeByName(resName, "num")
        local spriteBG    = CSResourceMgr.getNodeByName(resName, "chat_bg")
        local btnChange   = CSResourceMgr.getNodeByName(resName, "btn_change")

        -- local freeCnt = SystemInfo.getGlobalConfigAddInfoByID(26100).values[1]
        local costNum = SystemInfo.getGlobalConfigAddInfoByID(80001).values[1]
        -- local changeCnt = 0
        -- local petInfo = PokemonInfo.getPetInfoByObjID(objID)
        -- if petInfo.personal ~= nil and petInfo.personal.changeTimes ~= nil then
        --     changeCnt = petInfo.personal.changeTimes
        -- end
        -- if changeCnt < freeCnt then
        --     costNum = 0
        -- end

        -- local petName = PetEducationMgr.getPetName(petInfo)

        CSResourceMgr.setLabelStringByNode(labelTitle1, "editname1", outlineColor[3], nil, 500)
        CSResourceMgr.setLabelStringByNode(labelTitle2, "editname2", outlineColor[2], nil, 500)
        -- CSResourceMgr.setLabelStringByNode(labelFree  , "train133", outlineColor[2], nil, 500)
        CSResourceMgr.setLabelStringByNode(labelNum, "x"..costNum, outlineColor[3], nil, 80)

        CSResourceMgr.setLabelColorByNode(labelTitle1, labelColor[2])
        CSResourceMgr.setLabelColorByNode(labelTitle2, labelColor[2])
        -- CSResourceMgr.setLabelColorByNode(labelFree,   labelColor[2])

        labelFree:setVisible(costNum == 0)

        local editbox = CocosModuleMgr.newTextEditor(spriteBG, "empty", 360, 60, 185, 30, 
            TownChatMgr.LABEL_FONT_SIZE+8, TownChatMgr.MAX_WORD_SIZE, "editname3",nil,nil,true)

        CSResourceMgr.clickEventBindingByNode(btnChange, function ()
        	
            if costNum > CharInfo.getMCash() then
                DialogBoxMgr.showDialogBox(scene, 1, "advtips4")--钻石不足
            else
                local nameText = editbox:getText()
	        	if nameText and PlayerChangeNameMgr.checkNameLegal(nameText) then
	        		sendChangeNameMsg(nameText)
	        	end
            end
        end,3)
    end
	local function playAction()
        local panel = CSResourceMgr.getNodeByName(resName, "panel")
        panel:setVisible(true)
        CocosModuleMgr.showUIAnimation(panel, "down")
    end
    local funcTable = {loadCSB, loadUI, playAction}
    for key,var in pairs(funcTable) do
    	var()
    end
end

function PlayerChangeNameMgr.checkNameLegal(name)
    if string.len(name) < 1 then
        DialogBoxMgr.showDialogBox(scene, 1, "editname4")--请输入宠物名字
        return false
    elseif string.len(name) > 14 then
        DialogBoxMgr.showDialogBox(scene, 1, "editname5")--名字长度过长
        return false
    end
    return true
end

function PlayerChangeNameMgr.hide()
    UnblockLoader.cancel("PlayerChangeNameMgr")
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("PlayerChangeNameMgr")
end

return PlayerChangeNameMgr