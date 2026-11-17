actionStyle = class("actionStyle")
NEAR_ATTACK = 0 
FAR_ATTACK  = 1


function actionStyle:runActionStyle(pet,myType,style,attackFunc,endFunc)
	if style == NEAR_ATTACK then
		self:nearActionStyle(pet,myType,attackFunc,endFunc)
	elseif style == FAR_ATTACK then
		actionStyle:farActionStyle(pet,myType,attackFunc,endFunc)
	end
end

function actionStyle:farActionStyle(pet,myType,attackFunc,endFunc)
	local attackerRes 	= BattleCANI.PETS.petTable[myType][2]
	local attackerTag 	= BattleCANI.PETS.petTable[myType][3]
	local isAttack      = false

	AnimationMgr.playAniWithSpCallback(attackerRes, "attack", function(event) 
                if event.eventData.name == "attackAft" then
                	if attackFunc then
                		attackFunc()
                		isAttack = true
                	end
                end 
            end, function()
            		if BattleUIMgr.isJumpBattle or BattleCCSB.MENU.isOut then
			            return
			        end
                    if attackFunc and not isAttack then
                		attackFunc()
                	end

                    if endFunc then
                    	endFunc()
                    end

                    AnimationMgr.playAni(attackerRes, "idle", true, attackerTag)
                end, attackerTag, false) 
end

function actionStyle:nearActionStyle(pet,myType,attackFunc,endFunc)
	local attackcall 	= nil
	local hisType  		= TEAM_B
	local myPos 		= {BattleCANI.PETS.playerPosX,BattleCANI.PETS.playerPosY}
	local hisPos 		= {BattleCANI.PETS.enemyPosX-75,BattleCANI.PETS.enemyPosY-100}
	local petSize   	= BattleCANI.PETS.PET_SIZE_A + 0.1
	local rePetSize 	= BattleCANI.PETS.PET_SIZE_B
	local attackerRes 	= BattleCANI.PETS.petTable[myType][2]
	local attackerTag 	= BattleCANI.PETS.petTable[myType][3]
	local isAttack      = false
	local rate      	= 1
	pet:zorder(7)  

	if myType == TEAM_B then
		hisType 	= TEAM_A
		petSize 	= BattleCANI.PETS.PET_SIZE_B - 0.1 
		rePetSize 	= BattleCANI.PETS.PET_SIZE_A
		myPos 		= {BattleCANI.PETS.enemyPosX,BattleCANI.PETS.enemyPosY}
		hisPos 		= {BattleCANI.PETS.playerPosX+100,BattleCANI.PETS.playerPosY+100}
		pet:zorder(1)
		rate = -1
	end

	local move_to   	= cc.MoveTo:create(0.3/BattleUIMgr.speed,cc.p(hisPos[1],hisPos[2]))
	local scale_to  	= cc.ScaleTo:create(0.3/BattleUIMgr.speed, rate*petSize, petSize, 0)
	local spawn     	= cc.Spawn:create(move_to,scale_to) 
	local scale_back  	= cc.ScaleTo:create(0.3/BattleUIMgr.speed, rate*rePetSize, rePetSize, 0)
	local move_back 	= cc.MoveTo:create(0.3/BattleUIMgr.speed,cc.p(myPos[1],myPos[2])) 
	local spawn_back    = cc.Spawn:create(scale_back,move_back)
 
	local function callfunc()
		AnimationMgr.playAniWithSpCallback(attackerRes, "attack", function(event) 
                if event.eventData.name == "attackAft" then
                	if attackFunc then
                		attackFunc()
                		isAttack = true
                	end
                end
            end, function() 
            		if BattleUIMgr.isJumpBattle or BattleCCSB.MENU.isOut then
			            return
			        end
                    pet:moveTo(0.3/BattleUIMgr.speed,myPos[1],myPos[2])
                    transition.scaleTo(pet, {scaleX = rate*rePetSize,scaleY = rePetSize,
                    	time = 0.3/BattleUIMgr.speed,onComplete = function()
                    			pet:zorder(4)
                    			if endFunc then
			                    	endFunc()
			                    end
                    		end})
                
                    if attackFunc and not isAttack then
				        attackFunc() 
				    end

                    AnimationMgr.playAni(attackerRes, "idle", true, attackerTag)
                end, attackerTag, false)  
	end

	attackcall = cc.CallFunc:create(callfunc)
	pet:runAction(transition.sequence({
	    spawn,
	    attackcall        
	}))

end

return actionStyle