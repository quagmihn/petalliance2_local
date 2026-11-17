local WorldPlayerMgr = {}

WorldPlayerMgr.MAX_NUM = 20

local num = 0

function WorldPlayerMgr.Init()
	num = 0
end

function WorldPlayerMgr.clear()
	num = 0
end

---同步大地图人物信息
--@param params table 信息格式如下
--charID, mapid, startP, endP, nickname, playerSkin, petID, king, level
function WorldPlayerMgr.addPlayer(params)
    params.charID = tonumber(params.charID)
    if not params.charID or SceneMgr.isProcessing then
        print("添加玩家失败，玩家id不正确或场景切换中")
        return
    end
    if num>=WorldPlayerMgr.MAX_NUM then
    	return
    end
    if SceneMgr.currentScene~="MainScene" or WorldMapMgr.curMapID~=params.mapid or params.charID==CharInfo.getCharID() then
    	return
    end
    if PlayerAnimeMgr.getPlayer(params.charID) then
    	return
    end
    local resName = WorldMapInfo.getWorldMapInfoByID(WorldMapMgr.curMapID).res
    local routeResult = WorldMapMgr.searchRoute(params.endP, params.startP)
    if not routeResult then
    	return
    end
    local curPointNode = CSResourceMgr.getNodeByName(resName, "p"..params.startP)
    local parent = curPointNode:getParent()
    local Player = PlayerAnimeMgr.createPlayer(parent, {x=curPointNode:getPositionX(), y=curPointNode:getPositionY(), 
        skin=params.playerSkin}, params.charID, true)
    Player:setLocalZOrder(5)
    Player:setScale(WorldMapMgr.PLAYER_SCALE)
    
    local curP = params.startP
    local function moveto(rTable)
        local id = rTable[1]
        local curMapButton = CSResourceMgr.getNodeByName(resName, "p"..curP)
        local terMapButton = CSResourceMgr.getNodeByName(resName, "p"..id)
        curP = id
        local curPosx = curMapButton:getPositionX()
        local terPosx = terMapButton:getPositionX()
        local curPosy = curMapButton:getPositionY()
        local terPosy = terMapButton:getPositionY()
        local charHeadGaf = Player
        local curScalex = math.abs(charHeadGaf:getScaleX())
        local curScaley = math.abs(charHeadGaf:getScaleY())
        if terPosx-curPosx<0 then
            charHeadGaf:setScale(-curScalex, curScaley)
        else
            charHeadGaf:setScale(curScalex, curScaley)
        end
        local distance = math.sqrt(math.pow(terPosx-curPosx, 2)+math.pow(terPosy-curPosy, 2))
        local movetime = distance/WorldMapMgr.DEFAULT_MOVE_SPEED
        transition.moveBy(charHeadGaf, {x=terPosx-curPosx, y=terPosy-curPosy, time=movetime})

        PlayerAnimeMgr.playAni(params.charID, "walk", true)
        Player:performWithDelay(function()
            table.remove(rTable, 1)
            if #rTable>0 then
                moveto(rTable)
            else
                --移动完成
                PlayerAnimeMgr.playAni(params.charID, "idle", true)
                transition.fadeOut(Player, {time=1})
                local shineAni = AnimationMgr.createAni(parent, "Spine/effects/Ui_huicheng.png", terPosx, terPosy, params.charID)
                shineAni:setLocalZOrder(5)
                shineAni:setScale(0.5)
                AnimationMgr.playAniWithCallback(shineAni.res, "animation", nil, shineAni.tag, true)
                Player:performWithDelay(function()
                    PlayerAnimeMgr.removePlayerByTag(params.charID)
                    num = num - 1
                end, 1)
            end
        end, movetime)
    end
    moveto(routeResult)
    PlayerAnimeMgr.playAni(params.charID, "walk", true)
    num = num + 1
end

return WorldPlayerMgr