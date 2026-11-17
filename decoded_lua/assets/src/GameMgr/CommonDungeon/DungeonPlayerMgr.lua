local DungeonPlayerMgr = {}

local playerCurrPos = 1

local playerTag = ""

function DungeonPlayerMgr.Init()
end

function DungeonPlayerMgr.getPlayerTag() 
    if LtMapOption.getMapType() == "ADVENTURE" then
        return SearchingUIMgr.playerTag
    elseif LtMapOption.getMapType() == "LOSTTOWER" then
        return LtPlayerMgr.playerTag
    else
        return PlayerAnimeMgr.SELF_TAG_STRING
    end
end

function DungeonPlayerMgr.initPlayer()

    playerTag = DungeonPlayerMgr.getPlayerTag()

    local playerNode = SearchingUIMgr.getPlayerNode()

    local function setPlayerAni()
        PlayerAnimeMgr.playAni(playerTag, "idle", true)
    end

    playerCurrPos = SearchingMgr.playerCurrPosition

    --去除人物所在位置mist
    local block = playerCurrPos
    if SearchingMgr.mapInfoTable[block] == 2 then
        SearchingMgr.mapInfoTable[block] = 1
        SearchingMgr.monsterDefendInfo[block] = 0
        SearchingUIMgr.activeSlab(block)
    end
    if SearchingMgr.mapInfoTable[block] == 1 then
        SearchingMgr.mistHidAt(block)
    end

    --player位置设置
    local x, y = SearchingUIMgr.getBlockNode(playerCurrPos):getPosition()
    playerNode:setPosition(x, y)

    --set player zorder
    local zorder = SearchingUIMgr.calcZOrderAt( playerCurrPos, true )  --math.ceil(id/LtMapOption.getMapCols())
    playerNode:setLocalZOrder( zorder )

    --playerName显示
    local nametext = CharInfo.getNickName()
    local nameLabel = CSResourceMgr.seekNodeByName(playerNode,"playerName")
    CSResourceMgr.setLabelStringByNode(nameLabel,nametext,nil)
    nameLabel:enableOutline({r=0,g=0,b=0,a=255}, 1)
    nameLabel:setLocalZOrder(99)

    local playerAniNode = PlayerAnimeMgr.createPlayer(playerNode, 
        {gender=CharInfo.getSex(), x=104/2, y=24,skin=CharInfo.getCurfashion()}, playerTag)
    playerAniNode:setScale(LtPlayerMgr.PLAYER_SCALE_X, LtPlayerMgr.PLAYER_SCALE_Y)

    if SearchingMgr.isAdventureEnd() then
        --player enter effect
        local effectRes = "Gaf/Searching/enterEffect.gaf"
        local fog_node = SearchingUIMgr.getBlockContainer()
        local x,y = SearchingUIMgr.getBlockNode(playerCurrPos):getPosition()
        local enterEffect = AnimationMgr.createAni(fog_node, effectRes, x, y+630)
        enterEffect:setLocalZOrder(-1)

        SearchingMgr.canMove = false
        AnimationMgr.playAniWithCallback(effectRes,"do", function()
            fog_node:removeChild(enterEffect)
        end)
        playerNode:performWithDelay(function()
            setPlayerAni()
        end,0.2)
    else
        setPlayerAni()
    end

    SearchingMgr.player = playerNode
    SearchingUIMgr.playerAni = playerAniNode

end

function DungeonPlayerMgr.checkPlayerAction(nextID, movetime)
    if DungeonMapMgr.playerUpdateFlag then
        local px, py = SearchingUIMgr.getBlockNode(SearchingMgr.playerCurrPosition):getPosition()
        local movex, movey = SearchingUIMgr.getBlockNode(nextID):getPosition()
        transition.moveBy(SearchingMgr.player, {x=movex-px, y=movey-py, time=movetime})
    end
    SearchingUIMgr.TurnToBlock(nextID)
    if PlayerAnimeMgr.getPlayerCurMotionName(DungeonPlayerMgr.getPlayerTag()) ~= "walk" then
        PlayerAnimeMgr.playAni(DungeonPlayerMgr.getPlayerTag(), "walk", true)
    end
end

return DungeonPlayerMgr