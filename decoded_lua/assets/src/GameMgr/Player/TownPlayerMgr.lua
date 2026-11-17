local TownPlayerMgr = {}

TownPlayerMgr.MAX_NUM = SystemOptionsMgr.DEFAULT_PLAYER_NUM
TownPlayerMgr.SHOW_PET = "show"

TownPlayerMgr.PLAPER_SCALE = 0.96          --其他玩家缩放尺寸
TownPlayerMgr.PLAYER_POSY = 20             --其他玩家纵坐标
TownPlayerMgr.PLAYER_MAX_POSY = 200        --其他玩家随机最大Z值

TownPlayerMgr.PlayerTable = {}             --其他玩家列表
TownPlayerMgr.PlayerPetTable = {}          --其他玩家的宠物列表

local num = 0
local nameLabelRes = ""

function TownPlayerMgr.Init()
    TownPlayerMgr.MAX_NUM = UserSettings.get("townMaxPlayerNum", 4) or SystemOptionsMgr.DEFAULT_PLAYER_NUM
    local showVal = UserSettings.get("showPlayerPet", 4)
    if showVal=="show" or showVal==nil then
        TownPlayerMgr.SHOW_PET = "show"
    else
        TownPlayerMgr.SHOW_PET = "hide"
    end
    
    TownPlayerMgr.PlayerTable = {}
    TownPlayerMgr.PlayerPetTable = {}
    num = 0
    
    nameLabelRes = "Charactor/NameLabel.csb"
end

function TownPlayerMgr.clear()
    TownPlayerMgr.PlayerTable = {}
    TownPlayerMgr.PlayerPetTable = {}
    num = 0
end

function TownPlayerMgr.setPetVisible(boolVisible)
    if not CSResourceMgr.getCsbObj(TownMapMgr.MapRes) then
		return
	end
    for key, var in pairs(TownPlayerMgr.PlayerPetTable) do
		var[1]:setVisible(boolVisible)
	end
end

---删除其他玩家
--@param charID auto 玩家id
function TownPlayerMgr.removePlayer(charID)
    charID = tonumber(charID)
    if TownPlayerMgr.PlayerTable[charID]~=nil then
        num = num - 1
        PlayerAnimeMgr.removePlayerByTag(charID)
    else
        print(charID.."不在当前地图上，删除失败")
    end
    
    if TownPlayerMgr.PlayerPetTable[charID]~=nil then
        AnimationMgr.removeGafObjectByTag(TownPlayerMgr.PlayerPetTable[charID][3], charID)
    else
        print(charID.."的宠物不在当前地图上，删除失败")
    end
    
    TownPlayerMgr.PlayerTable[charID] = nil
    TownPlayerMgr.PlayerPetTable[charID] = nil
end

---添加其他玩家
--@param params table 玩家信息，格式为
--{charID=, playerSkin="", level="", confraternity="", nickname="", petID="", petSkin="", petname="", posx=, speed=}
--@param charID auto 玩家id
--@param mapres string 地图资源路径
--@param playerSkin string 玩家皮肤信息
--@param nickname string 玩家的昵称信息
--@param level string 玩家等级
--@param confraternity string 玩家所属公会
--@param petID string 玩家携带宠物id
--@param petSkin string 玩家携带宠物皮肤
--@param petname string 玩家携带宠物的昵称信息
--@param posx int 玩家相对地图的初始位置
--@param speed int 玩家的移动速度
function TownPlayerMgr.addPlayerWithRes(params)
    params.charID = tonumber(params.charID)
    if not params.charID or SceneMgr.isProcessing then
    	print("添加玩家失败，玩家id不正确或场景切换中")
    	return
    end
    if num>=TownPlayerMgr.MAX_NUM and TownPlayerMgr.PlayerTable[params.charID]==nil then
    	return
    end
    if params.mapres~=TownMapMgr.MapRes or not CSResourceMgr.getCsbObj(params.mapres) or params.charID==CharInfo.getCharID()
        or not TownMapMgr.PlayerTransferPosy then
    	return
    end
    if params.posx==-999 then
        TownPlayerMgr.removePlayer(params.charID)
    	return
    end
    
    local randomRage = TownPlayerMgr.PLAYER_MAX_POSY - TownMapMgr.PlayerTransferPosy
    local randomZ = GetRandom.random(0, randomRage)
    params.speed = params.speed or 500
    local sizeRate = TownPlayerMgr.PLAPER_SCALE
    local mapRes_vec = lua_string_split(TownMapMgr.MapRes, "/")
    local map_name = string.gsub(mapRes_vec[table.getn(mapRes_vec)], ".csb", "")
    local map_node = TownMapMgr.Map:getChildByName(map_name)
    local map_posx = TownMapMgr.Map:getChildByName(map_name):getPositionX()
    local petRes = PokemonInfo.getPokemonResByID(params.petID)
    local posY
    if params.posY == nil then
        posY = TownPlayerMgr.PLAYER_POSY+randomZ+TownMapMgr.PlayerTransferPosy
    else
        posY = params.posY
    end
    
    local function createPet(petPosy)
        petPosy = petPosy or posY
        local petZ = petPosy-TownPlayerMgr.PLAYER_POSY-TownMapMgr.PlayerTransferPosy
        local tPet
        if params.mapNode == nil then
            tPet = AnimationMgr.createAni(map_node, petRes, 
                params.posx-TownMapMgr.DEFAULT_PET_DISTANCE*sizeRate, petPosy, params.charID)
        else
            tPet = AnimationMgr.createAni(params.mapNode, petRes, 
                params.posx-TownMapMgr.DEFAULT_PET_DISTANCE*sizeRate, petPosy, params.charID)
        end
        AnimationMgr.playAni(petRes, "idle", true, params.charID)
        tPet:setScale(sizeRate*TownMapMgr.DEFAULT_PET_SCALE, sizeRate*TownMapMgr.DEFAULT_PET_SCALE)
        if params.playerZOrder == nil then
            tPet:setLocalZOrder((randomRage-petZ+1)*2 - 1)
        else
            tPet:setLocalZOrder(params.playerZOrder - 1)
        end
        AnimationMgr.setSkin(tPet.res, params.petSkin, tPet.tag)
        --[[
        local pnamelabel = CSResourceMgr.createRes(tPet, nameLabelRes, params.petname)
        CSResourceMgr.setLabelString(nameLabelRes, "name", params.petname.." ", params.petname, CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        CSResourceMgr.setLabelColor(nameLabelRes, "name", TownPlayerMgr.LABEL_COLOR, params.petname)
        local petnamelabel_y = TownMapMgr.DEFAULT_PET_NAMELABEL_POSY1
        if PokemonInfo.getPokemonFigure(params.petID)==1 then
        petnamelabel_y = TownMapMgr.DEFAULT_PET_NAMELABEL_POSY2
        end
        pnamelabel:setPosition(TownMapMgr.DEFAULT_PET_NAMELABEL_POSX, petnamelabel_y)
        pnamelabel:setAnchorPoint(0.5, 0.5)
        pnamelabel:setScale(1/TownMapMgr.DEFAULT_PET_SCALE, 1/TownMapMgr.DEFAULT_PET_SCALE)
        ]]
        TownPlayerMgr.PlayerPetTable[params.charID] = {tPet, params.speed+TownMapMgr.DEFAULT_PETSPEED_DIFF, petRes, "null", 
            sizeRate*TownMapMgr.DEFAULT_PET_SCALE}
        if TownPlayerMgr.SHOW_PET~="show" then
        	tPet:setVisible(false)
        end
        if params.petShining then
            CocosModuleMgr.lightenNode(tPet, tonumber(params.petShining))
        end
    end
    
    if TownPlayerMgr.PlayerTable[params.charID] then
        --玩家已经创建
        local cjson = require("cjson") 
        params.playerSkin = cjson.encode(params.playerSkin)
        local curInfo = TownPlayerMgr.PlayerTable[params.charID][7]
        TownPlayerMgr.PlayerTable[params.charID][7] = params
        --print("----", curInfo.playerSkin, params.playerSkin)
        if curInfo.playerSkin~=params.playerSkin then
            PlayerAnimeMgr.setPlayerSkins(params.charID, params.playerSkin)
        end
        --print("----", curInfo.petID, params.petID)
        if curInfo.petID~=params.petID or curInfo.petSkin~=params.petSkin then
            local prePetAni = AnimationMgr.getGafObj(PokemonInfo.getPokemonResByID(curInfo.petID), params.charID)
            local prePetAniPosy = nil
            if prePetAni then
                prePetAniPosy = prePetAni:getPositionY()
            end
            AnimationMgr.removeGafObjectByTag(PokemonInfo.getPokemonResByID(curInfo.petID), params.charID)
            createPet(prePetAniPosy)
        end
        if curInfo.level~=params.level then
            TownMapMgr.refreshNameLabel(params.charID, params.level, nil, nil)
        end
        if curInfo.confraternity~=params.confraternity then
            TownMapMgr.refreshNameLabel(params.charID, nil, params.confraternity, nil)
            if curInfo.posx==params.posx then
                params.posx = curInfo.posx+1
                print(curInfo.posx, TownPlayerMgr.PlayerTable[params.charID][7].posx)
            end
        end
        if curInfo.posx~=params.posx then
            TownPlayerMgr.makePlayerMove(params.charID, params.posx)
        end
        if curInfo.rank~=params.rank then
            TownMapMgr.refreshNameLabel(params.charID, nil, nil, params.rank)
        end
    	return
    end
    
    createPet()
    
    local tPlayer
    if params.mapNode == nil then
        tPlayer = PlayerAnimeMgr.createPlayer(map_node, 
            {x=params.posx, y=posY, skin=params.playerSkin}, params.charID, true)
    else
        tPlayer = PlayerAnimeMgr.createPlayer(params.mapNode, 
            {x=params.posx, y=posY, skin=params.playerSkin}, params.charID, true)
    end
    local pscale
    if params.playerScale == nil then
        pscale = sizeRate
    else
        pscale = sizeRate * params.playerScale
    end
    tPlayer:setScale(pscale, pscale)
    --测试
    PlayerAnimeMgr.showWorldPKEffect(tPlayer,params.vip,params.charID)
    --------------
    if params.playerZOrder == nil then
        tPlayer:setLocalZOrder((randomRage-randomZ+1)*2)
    else
        tPlayer:setLocalZOrder(params.playerZOrder)
    end
    
    local namelabel = TownMapMgr.createNameLabel(tPlayer, params.nickname, params.level, params.confraternity,
        params.king, params.charID)
    TownMapMgr.refreshNameLabel(params.charID, nil, nil, params.rank)
    TownPlayerMgr.PlayerTable[params.charID] = {tPlayer, params.speed, "null", namelabel, pscale, false, params}
    print("添加玩家成功. 昵称:"..params.nickname..", 初始位置:"..params.posx, "当前玩家数量:"..num+1)
    
    --添加点击该玩家出现关于他的操作列表
    PlayerOperationMgr.rigist(params)
    num = num + 1
end

---废弃接口！设置其他玩家随机移动
--@param tag string 玩家的昵称信息
--@param isLoop bool 是否循环本次随机的移动
function TownPlayerMgr.makePlayerRandomMove(nickname, isLoop)
    --[[
    local tag = nickname
    if not TownPlayerMgr.PlayerTable[tag] then
    	return false
    end
    local tPlayer = TownPlayerMgr.PlayerTable[tag][1]
    local posx = tPlayer:getPositionX()
    local mapRes_vec = lua_string_split(TownMapMgr.MapRes, "/")
    local map_name = string.gsub(mapRes_vec[table.getn(mapRes_vec)], ".csb", "")
    local map_posx = TownMapMgr.Map:getChildByName(map_name):getPositionX()
    local size = TownMapMgr.Map:getChildByName(map_name):getContentSize()
    local size_ratex = TownMapMgr.Map:getChildByName(map_name):getScaleX()
    local curMapWidth = size.width*size_ratex
    
    math.randomseed(tostring(os.time()):reverse():sub(1, 6)) 
    local moveDifXLeft = -curMapWidth/2 + map_posx - posx
    local moveDifXRight = curMapWidth + moveDifXLeft
    if moveDifXLeft > 0 or moveDifXRight < 0 then
        print("玩家初始坐标不在地图上，创建玩家随机移动失败")
        return false
    end
    local moveDifX = math.random(moveDifXLeft+TownMapMgr.DEFAULT_DELIVERY_DISTANCE, moveDifXLeft*0.1)
    if moveDifXLeft+moveDifXRight>0 then
        moveDifX = math.random(moveDifXRight*0.1, moveDifXRight-TownMapMgr.DEFAULT_DELIVERY_DISTANCE)
    end
    print("随机移动开始. 玩家昵称:"..tag..", 移动距离:"..moveDifX..", 可移动区间:"..moveDifXLeft.."~"..moveDifXRight)
    TownPlayerMgr.makePlayerMove(tag, moveDifX, isLoop)
    ]]
end

---设置其他玩家移动
--@param charID int 玩家id
--@param posx int 横向pos
function TownPlayerMgr.makePlayerMove(charID, posx)
    local tag = tonumber(charID)
    if TownPlayerMgr.PlayerTable[tag]==nil or TownPlayerMgr.PlayerTable[tag][1] == nil then
        print(tag.."该玩家尚未被加载到地图上")
        return false
    end
    if TownPlayerMgr.PlayerPetTable[tag]==nil or TownPlayerMgr.PlayerPetTable[tag][1] == nil then
        print(tag.."该玩家的尚未被加载到地图上")
        return false
    end
    local tPlayer = TownPlayerMgr.PlayerTable[tag][1]
    local speed = TownPlayerMgr.PlayerTable[tag][2]
    local namelabel = TownPlayerMgr.PlayerTable[tag][4]
    local sizeRate = TownPlayerMgr.PlayerTable[tag][5]
    
    local tPet = TownPlayerMgr.PlayerPetTable[tag][1]
    local pspeed = TownPlayerMgr.PlayerPetTable[tag][2]
    local petRes = TownPlayerMgr.PlayerPetTable[tag][3]
    --local pnamelabel = TownPlayerMgr.PlayerPetTable[tag][4]
    local psizeRate = TownPlayerMgr.PlayerPetTable[tag][5]
    
    local move_time = 1
    local pmove_time = 0
    local moveDifX = posx-tPlayer:getPositionX()
    if moveDifX > 0 then
        tPlayer:setScale(sizeRate, sizeRate)
        namelabel:setScale(1, 1)
        move_time = moveDifX/speed
    else
        tPlayer:setScale(-sizeRate, sizeRate)
        namelabel:setScale(-1, 1)
        move_time = -moveDifX/speed
    end
    local pDistance = posx-tPet:getPositionX()
    local pmoveDifX = 0
    if math.abs(pDistance)>TownMapMgr.DEFAULT_PET_DISTANCE then
        if pDistance>0 then
            pmoveDifX = pDistance - TownMapMgr.DEFAULT_PET_DISTANCE*sizeRate
            pmove_time = pmoveDifX/pspeed
        else
            pmoveDifX = pDistance + TownMapMgr.DEFAULT_PET_DISTANCE*sizeRate
            pmove_time = -pmoveDifX/pspeed
        end
    end
    
    transition.stopTarget(tPlayer)
    PlayerAnimeMgr.playAni(tag, "walk", true)
    transition.moveTo(tPlayer, {x = posx, time = move_time})
    transition.stopTarget(tPet)
    AnimationMgr.playAni(petRes, "idle", true, tag)
    
    tPlayer:performWithDelay(function()
        transition.stopTarget(tPlayer)
        if SceneMgr.isProcessing == true then
            print("场景正在切换中，其他玩家移动的回调函数不执行")
            return false
        end
        PlayerAnimeMgr.playAni(tag, "idle", true)
        if pmove_time>0 then
            if pmoveDifX>0 then
                tPet:setScale(psizeRate, psizeRate)
                --pnamelabel:setScale(1/TownMapMgr.DEFAULT_PET_SCALE, 1/TownMapMgr.DEFAULT_PET_SCALE)
            else
                tPet:setScale(-psizeRate, psizeRate)
                --pnamelabel:setScale(-1/TownMapMgr.DEFAULT_PET_SCALE, 1/TownMapMgr.DEFAULT_PET_SCALE)
            end
            AnimationMgr.playAni(petRes, "walk", true, tag)
            transition.moveBy(tPet, {x = pmoveDifX, y = 0, time = pmove_time})
            tPet:performWithDelay(function()
                transition.stopTarget(tPet)
                AnimationMgr.playAni(petRes, "idle", true, tag)
            end, pmove_time)
        end
    end, move_time)
end

function TownPlayerMgr.checkPlayerVisible()
    for key, var in pairs(TownPlayerMgr.PlayerTable) do
        local ret, errMessage = pcall(function()
            local playerNode = var[1]
            local pos = playerNode:getParent():convertToWorldSpace(cc.p(playerNode:getPositionX(), playerNode:getPositionY()))
            --print(key, pos.x, pos.y)
            if pos.x>-100 and pos.x<TownMapMgr.DEFAULT_TMAP_WIDTH+100 then
                playerNode:show()
                if TownPlayerMgr.SHOW_PET=="show" then
                    TownPlayerMgr.PlayerPetTable[key][1]:show()
                end
            else
                playerNode:hide()
                TownPlayerMgr.PlayerPetTable[key][1]:hide()
            end
        end)
	end
end

return TownPlayerMgr