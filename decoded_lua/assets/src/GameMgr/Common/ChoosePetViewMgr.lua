local ChoosePetViewMgr = {}

ChoosePetViewMgr.POS = {{x=320,y=135}, {x=100,y=195}, {x=540,y=195}}
ChoosePetViewMgr.MOVE_DIFF = 220
ChoosePetViewMgr.SCALE_SIZE = {1.2, 0.8, 0.7}

local resName = {}
local petAni = {}
local spRes = {}
local plistRes = ""

function ChoosePetViewMgr.Init()
	resName = {"UI/Login/ChoosePetDB.csb", "UI/Login/ChoosePet.csb"}
    petAni = {}
    spRes = {"Spine/effects/Ui_chongwulingqu_1.png", "Spine/effects/Ui_chongwulingqu_2.png"}
    plistRes = "Spine/effects/Ui_chongwulingqu_1.plist"
end

function ChoosePetViewMgr.addUI(scene)
    local curPetIndex = 1
    spRes[2] = CocosModuleMgr.getWordImage("Ui_chongwulingqu_2.png")

    CSResourceMgr.createRes(scene, resName[1]):setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
	CSResourceMgr.setRelativePosition(resName[1], 320, 480)
	
    CSResourceMgr.createRes(scene, resName[2]):setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
    CSResourceMgr.setFullScreen(resName[2])
    
    AnimationMgr.createAni(CSResourceMgr.getNodeByName(resName[2], "finalpet"), spRes[1], 0, 100):setScale(1.3)
    AnimationMgr.playAni(spRes[1], "animation", true)
    AnimationMgr.createAni(CSResourceMgr.getNodeByName(resName[2], "finaltitle"), spRes[2], -20, 0)
    AnimationMgr.playAni(spRes[2], "animation", true)
    CSResourceMgr.createParticle(CSResourceMgr.getNodeByName(resName[2], "finalpet"), plistRes, 0, 100)
    
    for var=1, #resName do
        local csobj = CSResourceMgr.getCsbObj(resName[var])
        if csobj then
            csobj:setVisible(false)
        end
    end
    
    for var=1, #GameGuideMgr.PET do
        petAni[var] = AnimationMgr.createAni(CSResourceMgr.getNodeByName(resName[2], "pet"..var), 
            PokemonInfo.getPokemonResByID(GameGuideMgr.PET[var]), 0, 0, "ChoosePetViewMgr")
        AnimationMgr.playAni(petAni[var].res, "idle", true, petAni[var].tag)
        AnimationMgr.setSkin(petAni[var].res, 0, petAni[var].tag)
        petAni[var]:setScale(0.8)
        local petattrRes = PokemonInfo.getAttriPics(PokemonInfo.getPokemonInfoByID(GameGuideMgr.PET[var]).elementAtt1)
        CSResourceMgr.setSpriteTexture(resName[2], "petattr"..var, petattrRes)
    end
    CSResourceMgr.getNodeByName(resName[2], "petdb1"):setScale(ChoosePetViewMgr.SCALE_SIZE[1])
    CSResourceMgr.getNodeByName(resName[2], "petdb2"):setScale(ChoosePetViewMgr.SCALE_SIZE[2])
    CSResourceMgr.getNodeByName(resName[2], "petdb3"):setScale(ChoosePetViewMgr.SCALE_SIZE[2])
    
    local boolAnimating = false
    local function moveFunc(diff, boolAnimated)
        boolAnimated = boolAnimated or false
        if diff>ChoosePetViewMgr.MOVE_DIFF then
            diff = ChoosePetViewMgr.MOVE_DIFF
        elseif diff<-ChoosePetViewMgr.MOVE_DIFF then
            diff = -ChoosePetViewMgr.MOVE_DIFF
        end
        local percent = diff/ChoosePetViewMgr.MOVE_DIFF
        local rate = (1-(math.abs(0.5-math.abs(percent))/0.5))
        local curPetPos = ChoosePetViewMgr.POS[1]
        local posx = (ChoosePetViewMgr.POS[2].x-ChoosePetViewMgr.POS[3].x)*percent
        local posy = (ChoosePetViewMgr.POS[1].y-ChoosePetViewMgr.POS[2].y)*percent
        local posyBack = (ChoosePetViewMgr.POS[2].y-ChoosePetViewMgr.POS[1].y)*rate
        local scaleSide = ChoosePetViewMgr.SCALE_SIZE[1]-(ChoosePetViewMgr.SCALE_SIZE[1]-ChoosePetViewMgr.SCALE_SIZE[2])*(1-math.abs(percent))
        local scaleBack = ChoosePetViewMgr.SCALE_SIZE[2]-(ChoosePetViewMgr.SCALE_SIZE[2]-ChoosePetViewMgr.SCALE_SIZE[3])*rate
        
        local function moveTo(node, x, y, scale)
            if boolAnimated then
                boolAnimating = true
                transition.stopTarget(node)
        		transition.moveTo(node, {x=x, y=y, time=0.2})
        		if scale then
        			transition.scaleTo(node, {scale=scale, time=0.2})
        		end
                node:performWithDelay(function()
                    boolAnimating = false
                end, 0.2)
        	else
                if x then
                    node:setPositionX(x)
                end
                if y then
                    node:setPositionY(y)
                end
                if scale then
                	node:setScale(scale)
                end
        	end
        end
        
        local MiddlePet = CSResourceMgr.getNodeByName(resName[2], "petdb"..curPetIndex)
        local MiddleScale = ChoosePetViewMgr.SCALE_SIZE[1]-(ChoosePetViewMgr.SCALE_SIZE[1]-ChoosePetViewMgr.SCALE_SIZE[2])*math.abs(percent)
        moveTo(MiddlePet, curPetPos.x+diff, curPetPos.y+math.abs(posy), MiddleScale)
        
        local leftPetPos = ChoosePetViewMgr.POS[2]
        local leftPetIndex = curPetIndex+1
        if leftPetIndex>#GameGuideMgr.PET then
        	leftPetIndex = 1
        end
        local LeftPet = CSResourceMgr.getNodeByName(resName[2], "petdb"..leftPetIndex)
        if diff<0 then
            moveTo(LeftPet, leftPetPos.x+posx, leftPetPos.y+posyBack, scaleBack)
        else
            moveTo(LeftPet, leftPetPos.x+diff, leftPetPos.y+posy, scaleSide)
        end
        
        local rightPetPos = ChoosePetViewMgr.POS[3]
        local rightPetIndex = curPetIndex-1
        if rightPetIndex<1 then
        	rightPetIndex = #GameGuideMgr.PET
        end
        local RightPet = CSResourceMgr.getNodeByName(resName[2], "petdb"..rightPetIndex)
        if diff<0 then
            moveTo(RightPet, rightPetPos.x+diff, rightPetPos.y-posy, scaleSide)
        else
            moveTo(RightPet, rightPetPos.x+posx, rightPetPos.y+posyBack, scaleBack)
        end
        
        if diff>0 then
        	LeftPet:setLocalZOrder(2)
        	MiddlePet:setLocalZOrder(1)
        	RightPet:setLocalZOrder(0)
        elseif diff~=0 then
            RightPet:setLocalZOrder(2)
            MiddlePet:setLocalZOrder(1)
            LeftPet:setLocalZOrder(0)
        end
    end
    
    local function cancelFunc(sender)
        if sender~=nil then
            local bx = sender:getTouchBeganPosition().x
            local x = sender:getTouchMovePosition().x
            local diff = x-bx
            --print(diff, bx, x)
            if math.abs(diff)<ChoosePetViewMgr.MOVE_DIFF/2 then
            	moveFunc(0, true)
            else
                if diff>0 then
                    CSResourceMgr.callButtonFunc(resName[2], "turnright")
                else
                    CSResourceMgr.callButtonFunc(resName[2], "turnleft")
                end
            end
        end
    end
    
    local function changePet(index)
        local petid = GameGuideMgr.PET[index]
        if petAni[4] then
            AnimationMgr.removeGafObjectByTag(petAni[4].res, petAni[4].tag)
        end
        petAni[4] = AnimationMgr.createAni(CSResourceMgr.getNodeByName(resName[2], "finalpet"), 
            PokemonInfo.getPokemonResByID(petid+2), 0, 0, "ChoosePetViewMgr")
        AnimationMgr.playAni(petAni[4].res, "idle", true, petAni[4].tag)
        AnimationMgr.setSkin(petAni[4].res, 0, petAni[4].tag)
        petAni[4]:setScale(1.1)
        local petinfo = PokemonInfo.getPokemonInfoByID(petid)
        CSResourceMgr.setLabelString(resName[2], "name", petinfo.name)
        CSResourceMgr.getNodeByName(resName[2], "name"):enableOutline({r=0,g=0,b=0,a=255}, 1)
        CSResourceMgr.setLabelString(resName[2], "desc", petinfo.desc)
        CSResourceMgr.setLabelMaxWidth(resName[2], "desc", 500)
    end
    
    changePet(curPetIndex)
    CSResourceMgr.getNodeByName(resName[2], "turnleft"):setLocalZOrder(3)
    CSResourceMgr.clickEventBinding(resName[2], "turnleft", function()
        if boolAnimating then
        	return
        end
        moveFunc(-ChoosePetViewMgr.MOVE_DIFF, true)
        curPetIndex = curPetIndex-1
        if curPetIndex<1 then
            curPetIndex = #GameGuideMgr.PET
        end
        changePet(curPetIndex)
    end, "", 1, "petchange")
    CSResourceMgr.getNodeByName(resName[2], "turnright"):setLocalZOrder(3)
    CSResourceMgr.clickEventBinding(resName[2], "turnright", function()
        if boolAnimating then
        	return
        end
        moveFunc(ChoosePetViewMgr.MOVE_DIFF, true)
        curPetIndex = curPetIndex+1
        if curPetIndex>#GameGuideMgr.PET then
            curPetIndex = 1
        end
        changePet(curPetIndex)
    end, "", 1, "petchange")
    
    local isDragging = false
    CSResourceMgr.buttonEventBinding(resName[2], "move", function()
    	--touch
        isDragging = false
    end, function(sender)
    	--click
        if isDragging then
            cancelFunc(sender)
    	end
    end, function(sender)
    	--drag
        if boolAnimating then
            return
        end
        if sender~=nil then
            local bx = sender:getTouchBeganPosition().x
            local x = sender:getTouchMovePosition().x
            isDragging = true
            moveFunc(x-bx)
        end
    end, function(sender)
    	--cancel
        if isDragging then
            cancelFunc(sender)
    	end
    end)
    CSResourceMgr.setButtonString(resName[2], "ok", "tips3", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
    CSResourceMgr.clickEventBinding(resName[2], "ok", function()
        if NetInterface.isConnect then
            NetInterface.sendWithBlock("MC_CreateChar_Ack", function()
                local LoginSend = require("src.Net.Send.LoginSend")
                LoginSend.sendCM_CreateChar_Req({name=CharInfo.getNickName(), gender=CharInfo.getSex(), world=LoginViewMgr.getCurrentWorld(),
                    cullPet=GameGuideMgr.PET[curPetIndex], initFashionInfos=CharInfo.getCurfashion()})
            end, function()
                ChoosePetViewMgr.hide()
                local GenInfo = require("src.Data.GenInfo")
                LoginViewMgr.checkIn(GenInfo.getCharID(), true)
            end, function(code)
                TipsMgr.showError(nil, code)
            end)
        else
            ChoosePetViewMgr.hide()
            GameGuideMgr.firstPet()
        end
    end)
end

function ChoosePetViewMgr.show()
    for var=1, #resName do
    	local csobj = CSResourceMgr.getCsbObj(resName[var])
    	if csobj then
    		csobj:setVisible(true)
    	end
    end
end

function ChoosePetViewMgr.hide()
    for var=1, #spRes do
        AnimationMgr.removeGafObjectByTag(spRes[var])
    end
    CSResourceMgr.removeParticle(plistRes)
    for var=1, #petAni do
    	AnimationMgr.removeGafObjectByTag(petAni[var].res, petAni[var].tag)
    end
    petAni = {}
	for var=1, #resName do
		CSResourceMgr.removeCSObjectByTag(resName[var])
	end
end

return ChoosePetViewMgr