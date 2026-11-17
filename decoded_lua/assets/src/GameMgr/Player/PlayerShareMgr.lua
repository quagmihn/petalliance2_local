local PlayerShareMgr = {}

PlayerShareMgr.DEBUG_MODE = false

local resNameUp = ""
local resNameDown = ""
local resNameList = ""
local tag = ""
local tags = ""

local awardsVec = {}
local awardsList = {}
local awardsDayTimes = 0
local levelAwards = nil
local purchasePercent = 0

function PlayerShareMgr.Init()
	resNameUp = "Charactor/QRCodeUpside.csb"
	resNameDown = "Charactor/QRCodeDownside.csb"
    resNameList = "Charactor/QRCodeRewardList.csb"
    tag = "PlayerShareMgr"
    tags = "PlayerShareMgrList"
    
    if levelAwards==nil then
        awardsVec = SystemInfo.getGlobalConfigAddInfoByID(40001).values
        awardsList = SystemInfo.getGlobalConfigAddInfoByID(40002).values
        awardsDayTimes = SystemInfo.getGlobalConfigAddInfoByID(40003).values[1]
        purchasePercent = SystemInfo.getGlobalConfigAddInfoByID(41001).values[1]
        levelAwards = {}
        local function readAwards(var)
            local values = SystemInfo.getGlobalConfigAddInfoByID(var+1)
            if values then
                local vec = values.values
                table.insert(levelAwards, {level=vec[1], awards={}})
                for v=2, #vec do
                    table.insert(levelAwards[#levelAwards].awards, vec[v])
                end
                readAwards(var+1)
            end            
        end
        readAwards(43000)
    end    
end

function PlayerShareMgr.show(scene)
    NetInterface.send("GC_GetCharacterValues_Ack", function()
        local LoginSend = require("src.Net.Send.LoginSend")
        LoginSend.sendCG_GetCharacterValues_Req({"userCode", "conUserCode"})
    end, function()
        if CharInfo.get().usercode then
            print("PlayerShareMgr my:", CharInfo.get().usercode)
        end
        if CharInfo.get().conusercode then
            print("PlayerShareMgr other:", CharInfo.get().conusercode)
        end        
        PlayerShareMgr.open(scene)
    end)
end

function PlayerShareMgr.open(scene)
    UIStack.push(tag, PlayerShareMgr.hide, true)
    
    scene = scene or SceneMgr.getRunningScene
    local layerA, layerB
    local editBox = nil
    local curTab = nil
    local setTab = nil
    
    local function loadCSB()
    	layerA = CSResourceMgr.createRes(scene, resNameUp)
    	CSResourceMgr.setRelativePosition(resNameUp, 320, 480)
    	layerA:zorder(CocosModuleMgr.ZORDER_WINDOW)
    	CocosModuleMgr.setEdgeDistance(layerA, nil, nil, 0, nil)
    	layerA:hide()
    	
        layerB = CSResourceMgr.createRes(scene, resNameDown)
        CSResourceMgr.setRelativePosition(resNameDown, 320, 480)
        layerB:zorder(CocosModuleMgr.ZORDER_WINDOW)
        CocosModuleMgr.setEdgeDistance(layerB, nil, nil, nil, 0)
        layerB:hide()
        
        if PlayerShareMgr.DEBUG_MODE then
            editBox = CocosModuleMgr.newTextEditor(layerB, "UI/CommonFiles/chat_text_box_su.png", 500, 80, 320, 750, 24, 128, 
                "QRCODE", nil, function()
                    if curTab==1 then
                        local key = editBox:getText()
                        print("扫描成功：", key)
                        setTab(2)
                        NetInterface.sendWithBlock("GC_CheckUserCode_Ack", function()
                            local LoginSend = require("src.Net.Send.LoginSend")
                            LoginSend.sendCG_CheckUserCode_Req(key)
                        end, function()
                            CSResourceMgr.setButtonEnabled(resNameDown, "b2", false)
                            TipsMgr.show(nil, "qrcode6")
                        end, function(code)
                            TipsMgr.showError(nil, code)
                        end)
                    end
                end, false)
        end        
    	
        CSResourceMgr.setLabelString(resNameDown, "info", "qrcode5", nil, {r=0,g=0,b=0,a=255,s=1,w=1})
        CSResourceMgr.setButtonString(resNameDown, "b1", "qrcode1", nil, {r=0,g=0,b=0,a=255,s=1,w=1})
        CSResourceMgr.setSpriteTexture(resNameDown, "logo", CocosModuleMgr.getWordImage("pokemonlogo.png"))
        CSResourceMgr.setSpriteTexture(resNameDown, "qrcode", QRCodeMgr.getQRCode(CharInfo.get().usercode))
        CSResourceMgr.getNodeByName(resNameDown, "qrcode"):scale(2.5)
        CSResourceMgr.clickEventBinding(resNameUp, "close", function()
        	PlayerShareMgr.hide()
        end)
        CSResourceMgr.clickEventBinding(resNameDown, "b1", function()
            PlayerShareMgr.showAwardsList(scene)
        end)
        CSResourceMgr.setButtonTexture(resNameUp, "block", "point.png", "point.png", "point.png")
        CSResourceMgr.getNodeByName(resNameUp, "block"):zorder(-1)
        if CharInfo.get().conusercode==nil or CharInfo.get().conusercode=="" then
        	CSResourceMgr.setButtonEnabled(resNameDown, "b2", true)
        else
            CSResourceMgr.setButtonEnabled(resNameDown, "b2", false)
        end        
        
        function setTab(tabid)
            if curTab==tabid then
            	return
            end
            curTab = tabid
        	if tabid==1 then
        	    local function setCamera()
        	        if device.platform == "android" then
                        CSResourceMgr.getNodeByName(resNameDown, "s1"):show()
                        CSResourceMgr.getNodeByName(resNameDown, "logo"):hide()
        	        else
                        CSResourceMgr.getNodeByName(resNameDown, "s2"):hide()
                        CSResourceMgr.getNodeByName(resNameDown, "s1"):show()
                    end
                    QRCodeMgr.scanQRCode(function(key)
                        print("扫描成功：", key)
                        setTab(2)
                        NetInterface.sendWithBlock("GC_CheckUserCode_Ack", function()
                        	local LoginSend = require("src.Net.Send.LoginSend")
                        	LoginSend.sendCG_CheckUserCode_Req(key)
                        end, function()
                            CSResourceMgr.setButtonEnabled(resNameDown, "b2", false)
                            TipsMgr.show(nil, "qrcode6")
                        end, function(code)
                        	TipsMgr.showError(nil, code)
                        end)
                    end)
                    
                    CSResourceMgr.clickEventBinding(resNameDown, "b2", function()
                        setTab(2)
                    end)
                    
					CSResourceMgr.clickEventBinding(resNameDown, "b3", function()
                        setTab(3)
                    end)
					
                    if device.platform == "android" then
                        CSResourceMgr.clickEventBinding(resNameDown, "b2", function()
                            setCamera()
                        end)
                    else
                        CSResourceMgr.setButtonString(resNameDown, "b2", "qrcode4", nil, {r=0,g=0,b=0,a=255,s=1,w=1})
                        CSResourceMgr.getNodeByName(resNameUp, "shade"):show()
                        CSResourceMgr.setButtonEnabled(resNameDown, "b1", false)                  
                    end                   

                    if PlayerShareMgr.DEBUG_MODE and editBox then
                        editBox:setText("")
                    end
        	    end                
                UnblockLoader.load({function()
                    CocosModuleMgr.setScreenTouch(false)
                end, setCamera, function()
                    CocosModuleMgr.setScreenTouch(true)
                end}, tag.."setTab")
        	elseif tabid==2 then
                CSResourceMgr.getNodeByName(resNameDown, "s1"):hide()
                CSResourceMgr.getNodeByName(resNameDown, "s2"):show()
                QRCodeMgr.quitScanQRCode()
                CSResourceMgr.clickEventBinding(resNameDown, "b2", function()
                	setTab(1)
                end)
				CSResourceMgr.clickEventBinding(resNameDown, "b3", function()
                	setTab(3)
                end)
                CSResourceMgr.setButtonString(resNameDown, "b2", "qrcode2", nil, {r=0,g=0,b=0,a=255,s=1,w=1})
                CSResourceMgr.setButtonString(resNameDown, "b3", "qrcode13", nil, {r=0,g=0,b=0,a=255,s=1,w=1})
                CSResourceMgr.getNodeByName(resNameUp, "shade"):hide()
                CSResourceMgr.setButtonEnabled(resNameDown, "b1", true)
				CSResourceMgr.setButtonEnabled(resNameDown, "b3", true)
                if PlayerShareMgr.DEBUG_MODE and editBox then
                    editBox:setText(CharInfo.get().usercode)
                end
			elseif tabid==3 then
				local function setCamera()
        	        if device.platform == "android" then
                        CSResourceMgr.getNodeByName(resNameDown, "s1"):show()
                        CSResourceMgr.getNodeByName(resNameDown, "logo"):hide()
        	        else
                        CSResourceMgr.getNodeByName(resNameDown, "s2"):hide()
                        CSResourceMgr.getNodeByName(resNameDown, "s1"):show()
                    end                                                                                                                                                   
                    QRCodeMgr.scanQRCode(function(key)
                        print("扫描成功：", key)
                        setTab(2)
                        NetInterface.sendWithBlock("GC_NewAccountBindOldRoleID_Ack", function()
                        	local LoginSend = require("src.Net.Send.LoginSend")
                        	LoginSend.sendCG_NewAccountBindOldRoleID_Req(key)
                        end, function()
                            CSResourceMgr.setButtonEnabled(resNameDown, "b3", false)
                            TipsMgr.show(nil, "qrcode12")
                        end, function(code)
                        	TipsMgr.showError(nil, code)
                        end)
                    end)
                    
                    CSResourceMgr.clickEventBinding(resNameDown, "b2", function()
                        setTab(2)
                    end)
                    
					CSResourceMgr.clickEventBinding(resNameDown, "b3", function()
                        setTab(3)
                    end)
					
                                                                                                                    

                    if PlayerShareMgr.DEBUG_MODE and editBox then
                        editBox:setText("")
                    end
        	    end                
                UnblockLoader.load({function()
                    CocosModuleMgr.setScreenTouch(false)
                end, setCamera, function()
                    CocosModuleMgr.setScreenTouch(true)
                end}, tag.."setTab")
        	end        	
        end
        setTab(2)
        
        local itemVec = PlayerShareMgr.getItemVec(awardsVec)
        local wDiff = 100
        local pDiff = (640-wDiff*2)/#itemVec
        for var=1, #itemVec do
        	local iInfo = itemVec[var]
        	local node = ItemInfo.getItemIconById(iInfo[1], iInfo[2])
            node:addTo(CSResourceMgr.getNodeByName(resNameDown, "s1"))
            node:pos(wDiff+pDiff/2+(var-1)*pDiff, 60)
            node:scale(0.6)
        end
    end
    
    local function playAni()
        layerA:show()
        layerB:show()
        CocosModuleMgr.showUIAnimation(layerA, "up")
        CocosModuleMgr.showUIAnimation(layerB, "down")
    end
    
    local funcTable = {loadCSB, playAni}
    UnblockLoader.load(funcTable, tag)
end

function PlayerShareMgr.hide()
    UnblockLoader.cancel(tag)
    QRCodeMgr.quitScanQRCode()
	CSResourceMgr.removeCSObjectByTag(resNameUp)
	CSResourceMgr.removeCSObjectByTag(resNameDown)
	UIStack.pop(tag)
end

function PlayerShareMgr.showAwardsList(scene)
    UIStack.push(tags, PlayerShareMgr.hideAwardsList, false)
    scene = scene or SceneMgr.getRunningScene
    
    local function loadCSB()
    	local layer = CSResourceMgr.createRes(scene, resNameList)
    	layer:zorder(CocosModuleMgr.ZORDER_WINDOW)
    	CSResourceMgr.setFullScreen(resNameList)
    	
        local title = CSResourceMgr.getNodeByName(resNameList, "title")
        CSResourceMgr.setLabelStringByNode(title, "qrcode7", {r=0,g=0,b=0,a=255,w=1,s=2}, nil, 250)
        CSResourceMgr.setLabelColorByNode(title, {r=255,g=234,b=0,a=255})
        local btn_close = CSResourceMgr.getNodeByName(resNameList, "btn_close")
        CSResourceMgr.clickEventBindingByNode(btn_close, function()
            PlayerShareMgr.hideAwardsList()
        end)
        local btn = CSResourceMgr.getNodeByName(resNameList, "btn")
        CSResourceMgr.clickEventBindingByNode(btn, function()
            PlayerShareMgr.hideAwardsList()
        end)
    	
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resNameList, "panel_1"), "up")
    end
    
    local funcTable = {loadCSB}
    local content = {
        {title=CocosModuleMgr.createStringWithFormat({"qrcode8", awardsDayTimes}), item=PlayerShareMgr.getItemVec(awardsList)},
        {title="qrcode9", text=CocosModuleMgr.createStringWithFormat({"qrcode10", purchasePercent.."%%"})},
    }
    for var=1, #levelAwards do
        local level = levelAwards[var].level
        local itemVec = PlayerShareMgr.getItemVec(levelAwards[var].awards)
        table.insert(content, {title=CocosModuleMgr.createStringWithFormat({"qrcode11", level}), item=itemVec})
    end
    for var=1, #content do
    	local info = content[var]
    	table.insert(funcTable, function()
            local list = CSResourceMgr.getNodeByName(resNameList, "list")
            local reward = CSResourceMgr.getNodeByName(resNameList, "reward")
            local parent = reward:clone()
            list:pushBackCustomItem(parent)
            local bg1 = CSResourceMgr.seekNodeByName(parent, "bg1")
            bg1:setColor({r=24,g=44,b=58,a=255})
            local bg2 = CSResourceMgr.seekNodeByName(parent, "bg2")
            local reward_title = CSResourceMgr.seekNodeByName(parent, "reward_title")
            CSResourceMgr.setLabelStringByNode(reward_title, info.title, nil, nil, 500)
            CSResourceMgr.setLabelColorByNode(reward_title, {r=255,g=234,b=0,a=255,w=1,w=2})
            if info.text then
                local newLabel = reward_title:clone()
                newLabel:addTo(parent)
                newLabel:pos(60, 58)
                CSResourceMgr.setLabelStringByNode(newLabel, info.text)
                CSResourceMgr.setLabelMaxWidthByNode(newLabel, 400)
                newLabel:setAnchorPoint(0, 0.5)
            elseif info.item then
                for var=1, #info.item do
                    local iInfo = info.item[var]
                    local node = ItemInfo.getItemIconById(iInfo[1], iInfo[2])
                    node:addTo(parent)
                    node:pos(100+(var-1)*120, 58)
                    node:scale(0.6)
                    CSResourceMgr.clickEventBindingByNode(node, function()
                        ItemInfoViewMgr.show({id=iInfo[1], sum=iInfo[2]}, false)
                    end, 3)
                end
            end
            parent:setScaleY(0)
            parent:show()
            transition.scaleTo(parent, {scale=1, time=0.1})
    	end)
    end
    
    UnblockLoader.load(funcTable, tags)
end

function PlayerShareMgr.hideAwardsList()
    UnblockLoader.cancel(tags)
    CSResourceMgr.removeList(resNameList, "list")
    CSResourceMgr.removeCSObjectByTag(resNameList)
    UIStack.pop(tags)
end

function PlayerShareMgr.getItemVec(avec)
    local itemVec = {}
    local itemNum = math.floor(#avec/2)
    for var=1, itemNum do
        local rInfo = ItemInfo.getAwardElementInfoById(avec[var*2-1])
        local rType = rInfo.elementType
        local rID = rInfo.elementID
        local rNum = avec[var*2]
        if rType==3 then
            table.insert(itemVec, {rID, rNum})
        elseif rType==5 then
            print("二维码奖励不许填宠物！")
        else
            table.insert(itemVec, {ItemInfo.AWARD[rType], rNum})
        end
    end
    return itemVec
end

return PlayerShareMgr