BattleBufferUI = {}
BUFF_EFFECT_POISON  = {26,246,16}       -- 绿色(中毒)
BUFF_EFFECT_FREEZE  = {30,73,247}       -- 蓝色(冰冻)
BUFF_EFFECT_FIRE    = {255,0,125}       -- 红色(灼烧)
BUFF_EFFECT_PALSY   = {255,255,40}      -- 黄色(麻痹)
BUFF_EFFECT_SLEEP   = {100,100,100}     -- 灰色(睡眠)
BUFF_EFFECT_BOUND   = {74,255,255}      -- 棕色(束缚)
BUFF_EFFECT_AFRAID  = {128,0,255}       -- 紫色(退缩)
BUFF_EFFECT_RAIN    = {192,192,192}     -- 灰色(白雾)
BUFF_EFFECT_WALL    = {255,255,128}     -- 淡黄(光墙)
BUFF_EFFECT_PARRY   = {128,0,0}         -- 棕色(格挡)

local effect 	  = {}
local bufferTxt   = nil
local maxbuff 	  = 36
local buffColor   = {}

FIRE   		= 1
FREEZE 		= 2
PALSY  		= 3
POISON 		= 4
POISONER 	= 5
SLEEP  		= 6
BOUND 		= 7
AFRAID      = 8
SMALL       = 9
CONFUSION   = 10
RAIN   		= 11
BLIND   	= 12
SEED  		= 13
WALL   		= 14
INDEFENCE   = 15
DEMAGIC     = 16
DESPEED     = 17
WEAK        = 18
MOONY       = 19
COMA   		= 20
GROUND      = 21
BLADE   	= 22
IRON   		= 23
FOCUS   	= 24
INMAGIC     = 25
INSPEED     = 26
DODGE   	= 27
DEDODGE     = 28
EAGLEEYE    = 29
PARRY       = 30
LUCK    	= 31
UNLUCK      = 32
POISONTOOTH = 33
MIX_A   	= 34
MIX_B   	= 35
MIX_C   	= 36


function BattleBufferUI.init()
    BattleBufferUI.buffGafs 	= {}
    BattleBufferUI.buffGafs[0] 	= {}
    BattleBufferUI.buffGafs[1] 	= {} 
    effect[FIRE]   		= 		BUFF_EFFECT_FIRE					-- 1
    effect[FREEZE] 		=  		BUFF_EFFECT_FREEZE					-- 2
    effect[PALSY]		=  		BUFF_EFFECT_PALSY					-- 3
    effect[POISON]		=		BUFF_EFFECT_POISON					-- 4
    effect[POISONER] 	=		BUFF_EFFECT_POISON					-- 5
    effect[SLEEP]		=		BUFF_EFFECT_SLEEP					-- 6
    effect[BOUND]		=		BUFF_EFFECT_BOUND					-- 7
    effect[AFRAID]  	=		BUFF_EFFECT_AFRAID					-- 8
    effect[SMALL] 		=		BUFF_EFFECT_AFRAID				    -- 9
    effect[CONFUSION]	=		BUFF_EFFECT_AFRAID					-- 10
    effect[RAIN]		=		BUFF_EFFECT_RAIN					-- 11
    effect[BLIND]		=		BUFF_EFFECT_AFRAID					-- 12
    effect[SEED]		=		BUFF_EFFECT_PARRY					-- 13
    effect[WALL]		=		BUFF_EFFECT_WALL					-- 14
    effect[INDEFENCE]	=		BUFF_EFFECT_RAIN					-- 15
    effect[DEMAGIC]		=		BUFF_EFFECT_RAIN					-- 16
    effect[DESPEED]		=		BUFF_EFFECT_RAIN					-- 17
    effect[WEAK]		=		BUFF_EFFECT_RAIN					-- 18
    effect[MOONY]		=		BUFF_EFFECT_RAIN					-- 19
    effect[COMA]		=		BUFF_EFFECT_RAIN					-- 20
    effect[GROUND]		=		BUFF_EFFECT_WALL					-- 21
    effect[BLADE]		=		BUFF_EFFECT_WALL					-- 22
    effect[IRON]		=		BUFF_EFFECT_WALL					-- 23
    effect[FOCUS]		=		BUFF_EFFECT_WALL					-- 24
    effect[INMAGIC]		=		BUFF_EFFECT_WALL					-- 25
    effect[INSPEED]		=		BUFF_EFFECT_WALL					-- 26
    effect[DODGE]		=		BUFF_EFFECT_WALL					-- 27
    effect[DEDODGE]		=		BUFF_EFFECT_RAIN					-- 28
    effect[EAGLEEYE]	=		BUFF_EFFECT_WALL					-- 29
    effect[PARRY]		=		BUFF_EFFECT_PARRY 					-- 30
    effect[LUCK]		=		BUFF_EFFECT_WALL					-- 31
    effect[UNLUCK]		=		BUFF_EFFECT_RAIN					-- 32
    effect[POISONTOOTH]	=		BUFF_EFFECT_WALL					-- 33
    effect[MIX_A]		=		BUFF_EFFECT_WALL					-- 34
    effect[MIX_B]		=		BUFF_EFFECT_WALL					-- 35
    effect[MIX_C]		=		BUFF_EFFECT_WALL					-- 36

    if not bufferTxt then
        bufferTxt   = TxtReader.new("Config/buff.txt")
        bufferTxt.init({"id","part","posY","posX","exFront","frontX",
            "frontY","exBack","backX","backY","red","green","blue"}, 1
            ,{id=1,part=1,posX=1,posY=1,frontX=1,frontY=1,backX=1,backY=1,red=1,green=1,blue=1})
    end
    
end

function BattleBufferUI.petBufferShow(pet,resID,buffid,petType,petID)
    if resID then 
        local buffRes = "Gaf/buffer/"..resID..".png"
        BattleBufferUI.createBuffGaf(petType,resID,buffid,buffRes,petID)
    end
    
end 

function BattleBufferUI.createBuffGaf(petType,resID,buffid,buffRes,petID) 
    local foodPart      = 1
    local bodyPart      = 2
    local headPart      = 3
    local bufferPos     = bufferTxt.get(resID) 
    local partPosInfo   = BattleCANI.petbody.get(petID)
    local partPosX      = 0
    local partPosY      = 0

    if not bufferPos or not partPosInfo then
        printFileLog(" #      无法显示 buffer  Gaf         #######")
        return
    end

--    printFileLog("bufferPos..createBuffGaf..."..sz_T2S(bufferPos)) 

    if bufferPos.part == foodPart then
        if petType == 0 then
            partPosX = partPosInfo.foodLR_B
        else
            partPosX = partPosInfo.foodLR     
        end
        partPosY = partPosInfo.foodUD
    elseif bufferPos.part == bodyPart then  
        if petType == 0 then
            partPosX = partPosInfo.partLR_B 
        else
            partPosX = partPosInfo.partLR         
        end
        partPosY = partPosInfo.partUD
    elseif bufferPos.part == headPart then
        if petType == 0 then
            partPosX = partPosInfo.headLR_B
        else
            partPosX = partPosInfo.headLR   
        end
        partPosY = partPosInfo.headUD
    end

    local posX = bufferPos.posX + partPosX
    local posY = bufferPos.posY + partPosY
    local exFrPosX = 0
    local exFrPosY = 0
    local exBaPosX = 0
    local exBaPosY = 0 
    if bufferPos.frontX then
        exFrPosX = BattleCANI.PETS.enemyPosX + bufferPos.frontX
        exFrPosY = BattleCANI.PETS.enemyPosY + bufferPos.frontY
        exBaPosX = BattleCANI.PETS.enemyPosX + bufferPos.backX
        exBaPosY = BattleCANI.PETS.enemyPosY + bufferPos.backY
    end
    if petType == 0 then 
        -- posX = BattleCANI.PETS.playerPosX + (bufferPos.posX + partPosX)*BattleCANI.PETS.PET_SIZE_A
        -- posY = BattleCANI.PETS.playerPosY + (bufferPos.posY + partPosY)*BattleCANI.PETS.PET_SIZE_B 
        posX = bufferPos.posX + partPosX
        exFrPosX = BattleCANI.PETS.playerPosX + bufferPos.frontX
        exFrPosY = BattleCANI.PETS.playerPosY + bufferPos.frontY
        exBaPosX = BattleCANI.PETS.playerPosX + bufferPos.backX
        exBaPosY = BattleCANI.PETS.playerPosY + bufferPos.backY
    end 



    BattleBufferUI.createExternalBuffer(petType,bufferPos.exFront,bufferPos.exBack,exFrPosX,exFrPosY,exBaPosX,exBaPosY)

    BattleFuncMgr.nodeVaryColor(petType,BattleCANI.PETS.petTable[petType][1],{bufferPos.red,bufferPos.green,bufferPos.blue}) 
    -- BattleFuncMgr.setNodeColor(BattleCANI.PETS.petTable[petType][1],bufferPos.red,bufferPos.green,bufferPos.blue)
 
    local buffGaf = string.gsub(buffRes,".png",".gaf") 
--    printFileLog("加入buffres.."..buffRes)
    if BattleFuncMgr.isFileExist(buffGaf) then
        display.addImageAsync(buffRes, function()   
            local buff = BattleFuncMgr.createGafAni(buffGaf,BattleCANI.PETS.petTable[petType][1],0.5,-1.0,posX,posY)
            buff:zorder(6)
            table.insert(BattleBufferUI.buffGafs[petType], {buff,buffid})
            BattleFuncMgr.playGafAniWithSequenceAndCallBack(buff,"normal",true,nil) 
        end)
    end
end

function BattleBufferUI.createExternalBuffer(petType,FRes,BRes,FposX,FposY,BposX,BposY)
    if FRes ~= "" then
        printFileLog("#createExternalBuffer..FRes..",FRes)
        local frontRes = "Gaf/buffer/external/front/"..FRes..".png"
        display.addImageAsync(frontRes, function()  
            frontRes =  "Gaf/buffer/external/front/"..FRes..".gaf"
            local buff = BattleFuncMgr.createGafAni(frontRes,SceneMgr.getRunningScene,0.5,-0.5,FposX,FposY)
            buff:zorder(5) --6
            table.insert(BattleBufferUI.buffGafs[petType], {buff,buffid})
            BattleFuncMgr.playGafAniWithSequenceAndCallBack(buff,"normal",true,nil) 
        end)
    end

    if BRes ~= "" then
        printFileLog("#createExternalBuffer..BRes..",BRes) 
        local backRes = "Gaf/buffer/external/back/"..BRes..".png"
        display.addImageAsync(backRes, function()   
            backRes = "Gaf/buffer/external/back/"..BRes..".gaf"
            local buff = BattleFuncMgr.createGafAni(backRes,SceneMgr.getRunningScene,0.5,-0.5,BposX,BposY)
            buff:zorder(1)--1
            table.insert(BattleBufferUI.buffGafs[petType], {buff,buffid}) 
            BattleFuncMgr.playGafAniWithSequenceAndCallBack(buff,"normal",true,nil) 
        end)
    end
end

function BattleBufferUI.effectBuffer(petType,buffid,isbool)

    for key,var in pairs(BattleBufferUI.buffGafs[petType]) do
        if var[2] == buffid then
            local isEffect = BattleFuncMgr.playGafAniWithSequenceAndCallBack(var[1],"effect",false,function()
                
                if BattleBufferUI.buffGafs[petType][key] then
                    var[1]:stop()
                    var[1]:setFrame(-1)
                    BattleFuncMgr.playGafAniWithSequenceAndCallBack(var[1],"normal",true,nil)
                end
            end)
            if not isEffect then 
                BattleFuncMgr.playGafAniWithSequenceAndCallBack(var[1],"normal",true,nil)
            end  

        end

    end
end

function BattleBufferUI.cleanPetBuffGaf(petType,skillid) 
    -- printFileLog("cleanPetBuffGafBefore...."..sz_T2S(BattleBufferUI.buffGafs[petType]))

    table.filter(BattleBufferUI.buffGafs[petType], function(v, k)
        if v[2] == skillid then
            v[1]:removeFromParent()
            BattleBufferUI.buffGafs[petType][k] = nil
            return false
        else
            return true
        end
    end) 
    -- printFileLog("cleanPetBuffGafafter...."..sz_T2S(BattleBufferUI.buffGafs[petType]))
end

function BattleBufferUI.cleanAllPetBuffGaf(petType)
    if BattleBufferUI.buffGafs[petType] then
        table.filter(BattleBufferUI.buffGafs[petType], function(v, k)
            v[1]:removeFromParent()
            BattleBufferUI.buffGafs[petType][k] = nil
            return false
        end)
        BattleBufferUI.buffGafs[petType] = {}
    end
end

function BattleBufferUI.hidePetBuffGaf(petType)
    for key,var in pairs(BattleBufferUI.buffGafs[petType]) do
        var[1]:hide()
    end
end

function BattleBufferUI.showPetBuffGaf(petType)
    for key,var in pairs(BattleBufferUI.buffGafs[petType]) do
        var[1]:show()
    end
end

function BattleBufferUI.showPetColor(pet,red,green,blue)

end

return BattleBufferUI