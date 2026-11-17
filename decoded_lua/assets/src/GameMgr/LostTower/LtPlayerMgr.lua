local LtPlayerMgr = {}

LtPlayerMgr.playerTag = ""

LtPlayerMgr.playerAniRes  = ""
LtPlayerMgr.playerAniTag = "player-ani"
LtPlayerMgr.playerNode = nil
LtPlayerMgr.playerAniNode = nil

-- 千层塔副本小人缩放比例
LtPlayerMgr.PLAYER_SCALE_X = 0.80
LtPlayerMgr.PLAYER_SCALE_Y = 0.80

local canMove = true
local onMove  = false

local currPosition = 0

LtPlayerMgr.destination = 0
LtPlayerMgr.direction   = 0
 
function LtPlayerMgr.Init()
    canMove = true
    onMove  = false
    currPosition = 0
end

function LtPlayerMgr.isCanMove()
    return canMove
end

function LtPlayerMgr.isOnMove()
    return onMove
end

function LtPlayerMgr.setCurrPosition(pos)
    currPosition = pos
end

function LtPlayerMgr.getCurrPosition()
    return currPosition
end

function LtPlayerMgr.removePlayer()
    AnimationMgr.removeGafObjectByTag(LtPlayerMgr.playerAniRes, "player-ani")
end

function LtPlayerMgr.initPlayer()
    LtPlayerMgr.playerTag = LtMapOption.getMapType().."player"  -- PlayerAnimeMgr.SELF_TAG_STRING

    LtPlayerMgr.playerAniRes  = ""
    LtPlayerMgr.playerNode = nil
    LtPlayerMgr.playerAniNode = nil
    

    LtPlayerMgr.playerNode = SearchingUIMgr.getPlayerNode()
    LtPlayerMgr.playerNode:setContentSize(SearchingUIMgr.BLOCK_WIDTH, SearchingUIMgr.BLOCK_HEIGHT)

    local function setPlayerAni()
        PlayerAnimeMgr.playAni(DungeonPlayerMgr.getPlayerTag(), "idle", true)
    end
    
    currPosition = SearchingMgr.playerCurrPosition

    --去除人物所在位置mist
    local block = currPosition
    if SearchingMgr.mapInfoTable[block] == 2 then
        SearchingMgr.mapInfoTable[block] = 1
        SearchingMgr.monsterDefendInfo[block] = 0
        SearchingUIMgr.activeSlab(block)
    end
    if SearchingMgr.mapInfoTable[block] == 1 then
        SearchingMgr.mistHidAt(block)
    end

    --player位置设置
    local top  = SearchingUIMgr.TOP 
    local left = SearchingUIMgr.LEFT
    local blockwidth = SearchingUIMgr.BLOCK_WIDTH
    local blockheight = SearchingUIMgr.BLOCK_HEIGHT
    local x, y = SearchingUIMgr.getBlockNode(currPosition):getPosition()
    LtPlayerMgr.playerNode:setPosition(x, y)

    --set player zorder
    local zorder = SearchingUIMgr.calcZOrderAt( currPosition, true )  --math.ceil(id/LtMapOption.getMapCols())
    LtPlayerMgr.playerNode:setLocalZOrder( zorder )

    --playerName显示
    local nametext = CharInfo.getNickName()
    local nameLabel = CSResourceMgr.seekNodeByName(LtPlayerMgr.playerNode,"playerName")
    CSResourceMgr.setLabelStringByNode(nameLabel,nametext,nil)
    nameLabel:enableOutline({r=0,g=0,b=0,a=255}, 1)
    nameLabel:setLocalZOrder(99)
    
    --free fall
    SearchingUIMgr.freeFall(LtPlayerMgr.playerNode, 125)

    --player按钮隐藏
    --transition.fadeOut(SearchingMgr.player, {time = 0.01})

    --player动画播放
    local gender = CharInfo.getSex()
    local aniRes = SearchingMapMgr.playerResTbl["ani"][gender]
    if aniRes ~= nil then
        LtPlayerMgr.playerAniRes = aniRes
    else
        LtPlayerMgr.playerAniRes = SearchingMapMgr.playerResTbl["ani"][2]
    end
    
    local playerTag = LtPlayerMgr.playerTag
    LtPlayerMgr.playerAniNode = PlayerAnimeMgr.createPlayer(LtPlayerMgr.playerNode, 
        {gender=CharInfo.getSex(), x=104/2, y=24,skin=CharInfo.getCurfashion()}, playerTag)
    LtPlayerMgr.playerAniNode:setScale(LtPlayerMgr.PLAYER_SCALE_X, LtPlayerMgr.PLAYER_SCALE_Y)

--    LtPlayerMgr.playerAniNode = AnimationMgr.createAni(LtPlayerMgr.playerNode, LtPlayerMgr.playerAniRes, 55, 810, "player-ani")
--    LtPlayerMgr.playerAniNode:setScale(0.9, 0.9)

    if SearchingMgr.isAdventureEnd() then
        --player enter effect
        local effectRes = "Gaf/Searching/enterEffect.gaf"
        local fog_node = SearchingUIMgr.getBlockContainer()
        local x,y = SearchingUIMgr.getBlockNode(currPosition):getPosition()
        local enterEffect = AnimationMgr.createAni(fog_node, effectRes, x, y+630)
        enterEffect:setLocalZOrder(-1)

        SearchingMgr.canMove = false
        AnimationMgr.playAniWithCallback(effectRes,"do", function()
            fog_node:removeChild(enterEffect)
        end)
        LtPlayerMgr.playerNode:performWithDelay(function()
            setPlayerAni()
            SearchingUIMgr.playerEnter(0.4,LtPlayerMgr.playerNode)
        end,0.2)
    else
        setPlayerAni()
    end

    LtPlayerMgr.playerNode:addTouchEventListener(function(sender, state)
        if SearchingMgr.onmove then return end
        if state == 3 then
            PlayerAnimeMgr.playAni(DungeonPlayerMgr.getPlayerTag(), "idle", true)
        elseif state == 2 then
            PlayerAnimeMgr.playAni(DungeonPlayerMgr.getPlayerTag(), "idle", true)
        elseif state == 0 then
            PlayerAnimeMgr.playAni(DungeonPlayerMgr.getPlayerTag(), "fly", true)
        end
    end)
    
    SearchingMgr.player = LtPlayerMgr.playerNode
    SearchingUIMgr.playerAni = LtPlayerMgr.playerAniNode
    SearchingMapMgr.playerRes = LtPlayerMgr.playerAniRes
end

---
--@param p num player_position
--@param t num direction_position
--@param type num idle_or_walk
function LtPlayerMgr.setPlayerAni(p,t,type)
end

function LtPlayerMgr.moveWithCallback(i, callback)
    if not canMove then
        return
    end
    
    if i == currPosition then
        return
    end
    
end

function LtPlayerMgr.getRecoverParamFromFashion()
    local tbl = {}
    local _string = CharInfo.getCurfashion()
    
    if type(_string) == "string" then
        _string = string.gsub(_string, "%[", "")
        _string = string.gsub(_string, "%]", "")
        tbl = string.split(_string, ",")
    elseif type(_string) == "table" then
        tbl = _string
    end 
    local systemID = {0,0,44,45,46}
    
    local fashionNum = 0
    for i = 1, #tbl do
        if tonumber(tbl[i]) ~= 0 then fashionNum = fashionNum + 1 end
    end

    print("~~~~~~~~~~~~~~~  recoverFromFashion  ~~~~~~~~~~~~~~~", CharInfo.getCurfashion(), _string, #tbl, fashionNum)
    
    local id = systemID[fashionNum] or 0
    if id == 0 then 
        return 0 
    else
        return SystemInfo.getGlobalConfigAddInfoByID(id).values[1]
    end
end

function LtPlayerMgr.recoverFromFashion(objID, hp)
    local recoverPercent = LtPlayerMgr.getRecoverParamFromFashion()
    
    -- 检查服装解锁等级
    local checkLevel = SystemInfo.getGlobalConfigAddInfoByID(21012).values[1]
    if CharInfo.getLevel() < checkLevel then 
        return hp 
    end
    
    if recoverPercent <= 0 then 
        return hp
    end
    
    local function playRecoverEffect(node, tag)
        if not node then return end
        
        if SceneMgr.currentScene == "SearchingScene" or SceneMgr.currentScene == "LostTowerScene" then
            local eff = AnimationMgr.createAni(node,"Spine/effects/Ui_chongwuhuixue.png",49,85,tag)
            AnimationMgr.playAniWithCallback(eff.res, "animation", nil, eff.tag, true)
        end
    end
    
    local function getPetNode(objid)
        if LtMapOption.getMapType() == "ADVENTURE" then
            for index, _objID in pairs(AdvPetsMgr.ObjIDs()) do
                if objid == _objID then
                    return AdvPetsMgr.getPetNodes()[index]
                end
            end
        elseif LtMapOption.getMapType() == "LOSTTOWER" then
            for index, _objID in pairs(LtPetsMgr.LtArmy) do
                if objid == _objID then
                    return LtPetsMgr.LtArmyPetNodes[index]
                end
            end
        end
    end
    
    local tmpFuncTable = {}
    for i=1, #hp do
        if hp[i] > 0 then
            local hpmax = PokemonInfo.getPetInfoByObjID(objID[i]).hpmax
            hp[i] = hp[i]  + math.floor(hpmax * recoverPercent / 100)
            if hp[i] >= hpmax then
                hp[i] = hpmax
            end
            table.insert(tmpFuncTable, function()
                SceneMgr.getRunningScene:performWithDelay(function()
                    playRecoverEffect(getPetNode(objID[i]), LtMapOption.getMapType().."ArmyPet"..i)
                end,0.1)
            end)
        end
    end
    
    local tmpFunc
    if MapSeekerMgr.SeekFunc then tmpFunc = MapSeekerMgr.SeekFunc end
    
    MapSeekerMgr.SeekFunc = function()
        if tmpFunc then tmpFunc() end
        
        for i = 1, #tmpFuncTable do
            tmpFuncTable[i]()
        end
    end
    
    return hp
end

return LtPlayerMgr