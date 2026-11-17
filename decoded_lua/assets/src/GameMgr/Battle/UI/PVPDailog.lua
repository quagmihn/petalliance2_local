--
-- Author: Weijun Chen
-- Date: 2016-08-02 21:09:56
local PVPDailog 		= {}
local DailogLayer 		= nil
local DailogRes     	= "Battle/PVPDailog/pvpDailog.csb" 
local DailogZorder  	= 20
local my_Tag        	= "PVP_me"
local his_Tag       	= "PVP_him"
PVPDailog.isOver 	    = true 
PVPDailog.reportLayer        = nil
PVPDailog.reportFont         = nil
local opponentNickName  = ""

function PVPDailog.getOpponentNickName()
	return opponentNickName
end

function PVPDailog.show(opponentInfo)
	PVPDailog.hide() 
		DailogLayer  = CSResourceMgr.createRes(SceneMgr.getRunningScene, DailogRes)
		local button = CSResourceMgr.getNodeByName(DailogRes, "cancel") 
		local blue   = CSResourceMgr.getNodeByName(DailogRes, "blue") 
		local red    = CSResourceMgr.getNodeByName(DailogRes, "red") 
		local wait   = CSResourceMgr.getNodeByName(DailogRes, "wait") 
		local my_family = FamilyInfo.GetLocalFamilyInfo() 
		local my_name               = CharInfo.getNickName()
		local my_levelStr           = "Lv."..CharInfo.getLevel()
		local waitFont = LuaSqlite.getLanguageByKey("battleword18")
		local waitString = {waitFont..".",waitFont.."..",waitFont.."..."}
		local sp_res    = "UI/CommonFiles/player_head_frame.png"
		local my_sp     = display.newSprite(sp_res)
		local my_pAni   = PlayerAnimeMgr.createPlayer(nil, {skin=CharInfo.getCurfashion()},my_Tag)
		local index       = 0

		PlayerAnimeMgr.playerTable[my_Tag].spineobj[1]:setVisible(false)
        PlayerAnimeMgr.playerTable[my_Tag].spineobj[3]:setVisible(false)
        PlayerAnimeMgr.playerTable[my_Tag].spineobj[5]:setVisible(false)
        PlayerAnimeMgr.playerTable[my_Tag].spineobj[7]:setVisible(false)
        PlayerAnimeMgr.playerTable[my_Tag].spineobj[9]:setVisible(false)

		BattlePVPMgr.startCalcTime(function() 
				index = index%3 + 1
				local ret,errMessage = pcall(function()
					wait:setString(waitString[index])
		        end)
				if not ret then
					BattlePVPMgr.endCalcTime()
				end
			end,1.0)
		if my_family then
			local family_sp = display.newSprite(my_family.icon)
			local my_familyName 		= my_family.name
			print("my_family........",sz_T2S(my_family)) 
			local my_familyNameNode 	= display.newTTFLabel({
		        font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
		        text = my_familyName,
		        size = 24, 
		        align = cc.TEXT_ALIGN_CENTER, 
		        color = cc.c3b(255, 237, 0)
		    })
		    my_familyNameNode:enableOutline({r = 0,g = 0,b = 0, a = 255}, 2)
		    local familyName_size = my_familyNameNode:getContentSize()
			my_familyNameNode:addTo(my_sp)
			my_familyNameNode:setPosition(70,185) 
			family_sp:addTo(my_sp)
			family_sp:setScale(0.5,0.5)
			family_sp:setPosition(70 - familyName_size.width/2 - 15,185)  
		end
	    local my_levelNode 	= display.newTTFLabel({
	        font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
	        text = my_levelStr,
	        size = 24, 
	        align = cc.TEXT_ALIGN_CENTER, 
	        color = cc.c3b(255, 237, 0)
	    })
	    my_levelNode:enableOutline({r = 0,g = 0,b = 0, a = 255}, 2)
	    local my_nameNode    = display.newTTFLabel({
	        font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
	        text = my_name,
	        size = 24, 
	        align = cc.TEXT_ALIGN_CENTER, 
	        color = cc.c3b(255, 255, 255)
	    })
	    my_nameNode:enableOutline({r = 0,g = 0,b = 0, a = 255}, 2)
		my_sp:addTo(blue)
		my_sp:setPosition(150, 85)

		my_levelNode:addTo(my_sp)
		my_nameNode:addTo(my_sp)

		my_nameNode:setPosition(70,155) 
		my_levelNode:setPosition(70,10)

		local my_clip = CocosModuleMgr.maskSprite(my_sp, my_pAni, 
		    "Charactor/charcircle.png", {x=-5, y=140}) 
		my_pAni:setScale(1.2)
		my_clip:setPosition(72, -49)  
		my_clip:setScale(0.9,0.9)

		local his_fashion 			= opponentInfo.fashion.curFashion
		local his_familyName 		= opponentInfo.familyName
		local his_name              = opponentInfo.nickname
		local his_levelStr          = "Lv."..opponentInfo.level
		local his_sp     		= display.newSprite(sp_res)
		local his_pAni   		= PlayerAnimeMgr.createPlayer(nil, {skin=his_fashion},his_Tag)

		PlayerAnimeMgr.playerTable[his_Tag].spineobj[1]:setVisible(false)
        PlayerAnimeMgr.playerTable[his_Tag].spineobj[3]:setVisible(false)
        PlayerAnimeMgr.playerTable[his_Tag].spineobj[5]:setVisible(false)
        PlayerAnimeMgr.playerTable[his_Tag].spineobj[7]:setVisible(false)
        PlayerAnimeMgr.playerTable[his_Tag].spineobj[9]:setVisible(false)

		opponentNickName = his_name

		if not his_familyName then
			his_familyName = ""
		end

		if his_familyName ~= "" then
			local his_familyNameNode 	= display.newTTFLabel({
		        font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
		        text = his_familyName,
		        size = 24, 
		        align = cc.TEXT_ALIGN_CENTER, 
		        color = cc.c3b(255, 237, 0)
		    })
			his_familyNameNode:addTo(his_sp)
			his_familyNameNode:setPosition(70,185) 
			his_familyNameNode:enableOutline({r = 0,g = 0,b = 0, a = 255}, 2)
		end

	    local his_levelNode 	= display.newTTFLabel({
	        font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
	        text = his_levelStr,
	        size = 24, 
	        align = cc.TEXT_ALIGN_CENTER, 
	        color = cc.c3b(255, 237, 0)
	    })
	    his_levelNode:enableOutline({r = 0,g = 0,b = 0, a = 255}, 2)
	    local his_nameNode      = display.newTTFLabel({
	        font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
	        text = his_name,
	        size = 24, 
	        align = cc.TEXT_ALIGN_CENTER, 
	        color = cc.c3b(255, 255, 255)
	    })
	    his_nameNode:enableOutline({r = 0,g = 0,b = 0, a = 255}, 2)
		his_sp:addTo(red)
		his_sp:setPosition(210, 85)

		his_levelNode:addTo(his_sp)
		his_nameNode:addTo(his_sp) 

		his_nameNode:setPosition(70,155) 
		his_levelNode:setPosition(70,10)

		local his_clip = CocosModuleMgr.maskSprite(his_sp, his_pAni, 
		    "Charactor/charcircle.png", {x=-3, y=140})
		his_pAni:setScale(-1.2,1.2)
		his_clip:setPosition(69, -49)  
		his_clip:setScale(0.9,0.9)

		DailogLayer:zorder(DailogZorder)

		local buttonLable = button:getTitleRenderer()
		CSResourceMgr.setButtonStringByNode(button)
		buttonLable:setString(LuaSqlite.getLanguageByKey("battleword19")) 
		CSResourceMgr.clickEventBindingByNode(button, function()
				PVPDailog.hide()
				BattlePVPMgr.checkPlayerIsinBattle() 
			end, 3)
		CSResourceMgr.setRelativePosition(DailogRes, 320, 480) 

	
end

function PVPDailog.waitOpponentShow()

	-- PVPDailog.reportLayer = display.newScale9Sprite("UI/CommonFiles/tishikuang_dengdai.png", 0, 0, cc.size(590, 64))
	local pos  = BattleCCSB.TIME.labelPos:convertToWorldSpace(cc.p(0,0))
	local posY =  pos.y + 55 
	PVPDailog.reportLayer = display.newSprite("UI/CommonFiles/tishikuang_dengdai.png")
	PVPDailog.reportLayer:setScale(590/100,1.0)
	PVPDailog.reportLayer:addTo(SceneMgr.getRunningScene)
	PVPDailog.reportLayer:setPosition(0,posY)
	PVPDailog.reportLayer:zorder(10)


	local reportStr = LuaSqlite.getLanguageByKey("train177")
	PVPDailog.reportFont      = display.newTTFLabel({
	            font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
	            text = reportStr,
	            size = 24, 
	            align = cc.TEXT_ALIGN_CENTER, 
	            color = cc.c3b(166, 243, 255)
	        })
	
	PVPDailog.reportFont:enableOutline({r = 1,g = 11,b = 25, a = 255}, 1)
	PVPDailog.reportFont:addTo(SceneMgr.getRunningScene)
	PVPDailog.reportFont:setPosition(0,posY) 
	PVPDailog.reportFont:zorder(11)
 
	PVPDailog.reportLayer:moveTo(0.1,320,posY)
	PVPDailog.reportFont:moveTo(0.1,320,posY)

end

function PVPDailog.waitOpponentHide()
	if PVPDailog.reportLayer then
		PVPDailog.reportLayer:removeFromParent()
		PVPDailog.reportFont:removeFromParent()
		PVPDailog.reportFont  = nil
		PVPDailog.reportLayer = nil
		
	end
end

function PVPDailog.hide() 
	if DailogLayer then
		local ret,errMessage = pcall(function()
			BattlePVPMgr.endCalcTime()
			PlayerAnimeMgr.removePlayerByTag(my_Tag, true)
			PlayerAnimeMgr.removePlayerByTag(his_Tag, true)
            DailogLayer:removeFromParent(false)  
        end)
	    if ret==false then
	    	BattlePVPMgr.endCalcTime() 
	        
	    end
	    DailogLayer = nil
	end
end

return PVPDailog