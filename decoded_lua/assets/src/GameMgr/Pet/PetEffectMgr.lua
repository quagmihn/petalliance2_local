local PetEffectMgr = {}

PetEffectMgr.HammerEffect = nil

function PetEffectMgr.showTrainEffectA(parent, scaleNode)
	local effAni = AnimationMgr.createAni(parent, "Spine/train/UI_xunlianlogotexiao.png", 
			parent:getContentSize().width/2, parent:getContentSize().height/2, "PetTrainEffA")
	-- effAni:setPosition(effAni:getPositionX()+20, effAni:getPositionY()+50)
	AnimationMgr.playAni(effAni.res, "animation", false, "PetTrainEffA")
	transition.scaleTo(scaleNode,{scale = 2.0,time = 0.12})
	scaleNode:performWithDelay(function()
		transition.scaleTo(scaleNode,{scale = 1.0,time = 0.06})
	end, 0.12)
end

function PetEffectMgr.showTrainEffectB(parent)
	local effAni = AnimationMgr.createAni(parent, "Spine/train/UI_xunliantexiaojindutiao.png", 
			parent:getContentSize().width/2, parent:getContentSize().height/2, "PetTrainEffB")
	-- effAni:setPosition(effAni:getPositionX()+20, effAni:getPositionY()+50)
	AnimationMgr.playAni(effAni.res, "animation", false, "PetTrainEffB")
	AnimationMgr.playAniWithCallback(effAni.res, "Spine/train/UI_xunliantexiaojindutiao.png", function()
		transition.fadeOut(effAni, {time = 1})
	end, "PetTrainEffB", true)
end

function PetEffectMgr.showTrainEffectC(parent)
	local effAni = AnimationMgr.createAni(parent, "Spine/train/UI_xunliantexiao_chongzhi.png", 
			parent:getContentSize().width/2, parent:getContentSize().height/2, "PetTrainEffC")
	-- effAni:setPosition(effAni:getPositionX()+20, effAni:getPositionY()+50)
	AnimationMgr.playAni(effAni.res, "animation", false, "PetTrainEffC")
end

--锤子特效
function PetEffectMgr.showHammerEffect(parent, closeCallback)
	if PetEffectMgr.HammerEffect then
		parent:removeChild(PetEffectMgr.HammerEffect)
		transition.stopTarget(parent)
	end
	PetEffectMgr.HammerEffect = CSResourceMgr.createCCBI(parent, "texture/ui_ds103a.ccbi", 320, 640)
    PetEffectMgr.HammerEffect:setGlobalZOrder(CocosModuleMgr.ZORDER_GUIDE)
    parent:performWithDelay(function()
    	parent:removeChild(PetEffectMgr.HammerEffect)
    	PetEffectMgr.HammerEffect = nil
    	TipsMgr.show(SceneMgr.getRunningScene, "train121")
    	if closeCallback then closeCallback() end
    end, 2.33)
end

function PetEffectMgr.showSkillLvUpEffect(parent, closeCallback)
	local effAni = AnimationMgr.createAni(parent, "Spine/train/UI_skillupdate.png", 
			parent:getContentSize().width/2, parent:getContentSize().height/2, "SkillLvUpEffect")
	AnimationMgr.playAni(effAni.res, "animation", false, "SkillLvUpEffect")
	parent:performWithDelay(function()
	    AnimationMgr.removeGafObjectByTag(effAni.res, "SkillLvUpEffect")
	    if closeCallback then closeCallback() end
	end, 1.9)
end

return PetEffectMgr