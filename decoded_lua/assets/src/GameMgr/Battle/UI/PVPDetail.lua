local PVPDetail 		= {}
local DailogLayer 		= nil
local DailogRes     	= "Battle/PVPDetail/pvpDetail.csb" 
local DailogZorder  	= 20000
local my_Tag        	= "PVP_detail_me"
local his_Tag       	= "PVP_detail_him"
local layer_BK 			= nil
local tag               = "PVP_detail_grade"

function PVPDetail.show(opponentInfo)

	local res = "Pet/Formation/FormationBGNew.csb"
    layer_BK = CSResourceMgr.createRes(SceneMgr.getRunningScene, res, nil)
    CSResourceMgr.setRelativePosition(res, 320, 480, nil)
    layer_BK:zorder(19000)

	DailogLayer = CSResourceMgr.createRes(SceneMgr.getRunningScene, DailogRes)
	local bg = CSResourceMgr.getNodeByName(DailogRes, "Image_1") 

    local gradeBg = display.newSprite("UI/CommonFiles/cup_frame_medal_gold_01.png")
    gradeBg:addTo(bg)
    gradeBg:setPosition(320, 640)

    local gradeBg2 = display.newSprite("UI/CommonFiles/frame_title_ribbon_orange_su_02.png")
    gradeBg2:addTo(bg)
    gradeBg2:setPosition(320, 510)

    local curArenaPoint = ArenaInfo.getPVPArenaPoint()
    local curArenaLevel = ArenaInfo.getPVPArenaLevel()
    local curArenaInfo = ArenaInfo.getPVPArenaGradeInfoById(curArenaLevel)

    local grade_name = display.newTTFLabel({
        font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
        text = LuaSqlite.getLanguageByKey(curArenaInfo.gradeName),
        size = 26, 
        align = cc.TEXT_ALIGN_CENTER, 
        color = cc.c3b(255, 255, 255)
    })
    grade_name:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1)
    grade_name:addTo(bg)
    grade_name:setPosition(320,524)

    local pAni = AnimationMgr.createAni(gradeBg, PokemonInfo.getPokemonResByID(curArenaInfo.watchPet), 250, 90, tag)
    AnimationMgr.playAni(pAni.res, "idle", true, pAni.tag)
    AnimationMgr.setSkin(pAni.res, 0, pAni.tag)
    pAni:scale(0)
    local scaleFinal = 1
    if curArenaLevel>=6 then
        scaleFinal = 0.8
    end
    local sequence = transition.sequence({
        cc.ScaleTo:create(0.15, 1.3*scaleFinal),
        cc.ScaleTo:create(0.05, 0.9*scaleFinal),
        cc.ScaleTo:create(0.05, 1.1*scaleFinal),
        cc.ScaleTo:create(0.05, 1.0*scaleFinal),
    })
    pAni:runAction(sequence)

    local size = gradeBg:getContentSize()
    local sAni = AnimationMgr.createAni(gradeBg, "Spine/effects/Ui_zhandoujiesuanguangxiao.png", size.width/2, size.height/2, tag)
    AnimationMgr.playAni(sAni.res, "animation", true, sAni.tag)
    sAni:scale(0.8)
    sAni:zorder(-1)

    local my_grade = display.newSprite("UI/CommonFiles/icon_cup_lv"..curArenaLevel..".png")
    my_grade:addTo(bg)
    my_grade:setPosition(70,340)

	local my_nameNode = display.newTTFLabel({
        font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
        text = CharInfo.getNickName(),
        size = 22, 
        align = cc.TEXT_ALIGN_CENTER, 
        color = cc.c3b(255, 255, 255)
    })
    my_nameNode:enableOutline({r = 0,g = 0,b = 0, a = 255}, 2)
    my_nameNode:addTo(bg)
    my_nameNode:setPosition(180,340)

	local my_sp = display.newSprite("UI/CommonFiles/player_head_frame.png")
	my_sp:addTo(bg)
	my_sp:setPosition(150, 210)

	local my_pAni = PlayerAnimeMgr.createPlayer(nil, {skin=CharInfo.getCurfashion()},my_Tag)

	PlayerAnimeMgr.playerTable[my_Tag].spineobj[1]:setVisible(false)
    PlayerAnimeMgr.playerTable[my_Tag].spineobj[3]:setVisible(false)
    PlayerAnimeMgr.playerTable[my_Tag].spineobj[5]:setVisible(false)
    PlayerAnimeMgr.playerTable[my_Tag].spineobj[7]:setVisible(false)
    PlayerAnimeMgr.playerTable[my_Tag].spineobj[9]:setVisible(false)

    local my_clip = CocosModuleMgr.maskSprite(my_sp, my_pAni, 
        "Charactor/charcircle.png", {x=-5, y=140}) 
    my_pAni:setScale(1.2)
    my_clip:setPosition(72, -49)  
    my_clip:setScale(0.9,0.9)

    local my_levelNode 	= display.newTTFLabel({
        font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
        text = "Lv."..CharInfo.getLevel(),
        size = 24, 
        align = cc.TEXT_ALIGN_CENTER, 
        color = cc.c3b(255, 255, 255)
    })
    my_levelNode:enableOutline({r = 0,g = 0,b = 0, a = 255}, 2)
	my_levelNode:addTo(bg)
	my_levelNode:setPosition(85,270)

	local my_vip = display.newSprite("UI/CommonFiles/share_calligraphy_vip.png")
	my_vip:addTo(bg)
	my_vip:setPosition(200,160)

	local my_vip_num = display.newTTFLabel({
        font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
        text = CharInfo.getVIPLevel()-1,
        size = 30, 
        align = cc.TEXT_ALIGN_CENTER, 
        color = cc.c3b(255, 252, 0)
    })
	my_vip_num:addTo(bg)
	my_vip_num:setPosition(240,160)

    local my_score = display.newTTFLabel({
        font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
        text = CocosModuleMgr.createStringWithFormat({"arenapk3", curArenaPoint}),
        size = 30, 
        align = cc.TEXT_ALIGN_CENTER, 
        color = cc.c3b(255, 252, 0)
    })
    my_score:addTo(bg)
    my_score:setPosition(150,80)

    local his_grade = display.newSprite("UI/CommonFiles/icon_cup_lv"..opponentInfo.grade..".png")
    his_grade:addTo(bg)
    his_grade:setPosition(70+340,340)

	local his_nameNode = display.newTTFLabel({
        font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
        text = opponentInfo.nickname,
        size = 22, 
        align = cc.TEXT_ALIGN_CENTER, 
        color = cc.c3b(255, 255, 255)
    })
    his_nameNode:enableOutline({r = 0,g = 0,b = 0, a = 255}, 2)
    his_nameNode:addTo(bg)
    his_nameNode:setPosition(180+340,340)

	local his_sp = display.newSprite("UI/CommonFiles/player_head_frame.png")
	his_sp:addTo(bg)
	his_sp:setPosition(150+340, 210)

	local his_pAni = PlayerAnimeMgr.createPlayer(nil, {skin=opponentInfo.fashion.curFashion},his_Tag)

	PlayerAnimeMgr.playerTable[his_Tag].spineobj[1]:setVisible(false)
  	PlayerAnimeMgr.playerTable[his_Tag].spineobj[3]:setVisible(false)
  	PlayerAnimeMgr.playerTable[his_Tag].spineobj[5]:setVisible(false)
  	PlayerAnimeMgr.playerTable[his_Tag].spineobj[7]:setVisible(false)
  	PlayerAnimeMgr.playerTable[his_Tag].spineobj[9]:setVisible(false)

    local his_clip = CocosModuleMgr.maskSprite(his_sp, his_pAni, 
        "Charactor/charcircle.png", {x=-3, y=140})
    his_pAni:setScale(-1.2,1.2)
    his_clip:setPosition(69, -49)  
    his_clip:setScale(0.9,0.9)

  	local his_levelNode = display.newTTFLabel({
        font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
        text = "Lv."..opponentInfo.level,
        size = 24, 
        align = cc.TEXT_ALIGN_CENTER, 
        color = cc.c3b(255, 255, 255)
    })
    his_levelNode:enableOutline({r = 0,g = 0,b = 0, a = 255}, 2)
	his_levelNode:addTo(bg)
	his_levelNode:setPosition(85+340,270)

	-- local his_vip = display.newSprite("UI/CommonFiles/share_calligraphy_vip.png")
	-- his_vip:addTo(bg)
	-- his_vip:setPosition(200+340,160)

	-- local his_vip_num = display.newTTFLabel({
 --        font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
 --        text = CharInfo.getVIPLevel()-1,
 --        size = 30, 
 --        align = cc.TEXT_ALIGN_CENTER, 
 --        color = cc.c3b(255, 252, 0)
 --    })
	-- his_vip_num:addTo(bg)
	-- his_vip_num:setPosition(240+340,160)

    local his_score = display.newTTFLabel({
        font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
        text = CocosModuleMgr.createStringWithFormat({"arenapk3", opponentInfo.point}),
        size = 30, 
        align = cc.TEXT_ALIGN_CENTER, 
        color = cc.c3b(255, 252, 0)
    })
    his_score:addTo(bg)
    his_score:setPosition(150+340,80)

	DailogLayer:zorder(DailogZorder)

	CSResourceMgr.setRelativePosition(DailogRes, 320, 480)

    DailogLayer:performWithDelay(function()
        SceneMgr.replaceScene(SceneMgr.getRunningScene,"BattleScene")
    end, 1)
	
end

return PVPDetail