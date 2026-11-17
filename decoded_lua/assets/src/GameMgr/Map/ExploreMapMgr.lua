local ExploreMapMgr = {}

ExploreMapMgr.PLAYER_POSX = 320
ExploreMapMgr.PLAYER_POSY = 320
ExploreMapMgr.BALL_POSX_DIFF = 30
ExploreMapMgr.BALL_POSY_DIFF = 60
ExploreMapMgr.PET_POSY = 150
ExploreMapMgr.HIT_POS_DIFF = 80

local mapCommonRes = ""
local mapCommonBackRes = ""
local tag = ""

function ExploreMapMgr.Init()
    mapCommonRes = "Map/EmbeddedMap/default.csb"
    mapCommonBackRes = "Map/EmbeddedMap/default_back.csb"
    tag = "ExploreMapMgr"
end

function ExploreMapMgr.show(scene)
    local petNodes = {}

    local mapRes = EmbeddedMapMgr.getMapResByID(GetRandom.random(1, 10))
    local parent = display.newSprite("empty.png")
    parent:addTo(scene)
    parent:setLocalZOrder(CocosModuleMgr.ZORDER_WORLDMAP)
    parent:scale(1)
    local mapPosx = 320
    local mapScale = 2
    CocosModuleMgr.setRelativePosition(parent, mapPosx, 480)
    CocosModuleMgr.setEdgeDistance(parent, nil, nil, nil, 0, false)
    
    local function mapInitFunc(resName, useCoroutine)
        local mapTbl = {}
        local mapParamTbl = {}
        local clipMapTbl = {}

        local funcTbl = {}

        local function initMap(resName, tag, i, csbRes)
            local mapobj = CSResourceMgr.createRes(nil, csbRes, tag)
            CSResourceMgr.setSpriteTexture(csbRes, "default", resName, tag, false)
            --CSResourceMgr.getNodeByName(mapCommonRes, "default", tag):setColor({r=111,g=111,b=111})
            mapTbl[i] = mapobj

            if mapobj then
                local var = mapobj
                local key = i
                var:setPosition(-var:getContentSize().width/2, 0)
                local oringinPosx = var:getPositionX()
                local oringinPosy = var:getPositionY()
                if key%2==0 then
                    local size = CSResourceMgr.getNodeByName(csbRes, "default", tag):getContentSize()
                    local posx = var:getPositionX()
                    var:setPositionX(posx+size.width)
                end

                local clip = var
                var:addTo(parent)
                CSResourceMgr.getNodeByName(csbRes, "block", tag):setVisible(false)

                if key<=4 then
                    clip:setLocalZOrder(CocosModuleMgr.ZORDER_MAP_BACK)
                else
                    clip:setLocalZOrder(CocosModuleMgr.ZORDER_MAP_FRONT)
                end

                clipMapTbl[key] = clip
                var:setOpacity(0)
                var:scale(mapScale)
            end
        end

        mapParamTbl = 
            {
                {string.gsub(resName, ".png", "_back.png"), resName.."back1", mapCommonBackRes},
                {string.gsub(resName, ".png", "_back.png"), resName.."back2", mapCommonBackRes},
                {resName, resName.."1", mapCommonRes},
                {resName, resName.."2", mapCommonRes},
                {string.gsub(resName, ".png", "_front.png"), resName.."front1", mapCommonRes},
                {string.gsub(resName, ".png", "_front.png"), resName.."front2", mapCommonRes}
            }

        for key, var in pairs(mapParamTbl) do
            local function tmpInit()
                initMap(var[1], var[2], key, var[3])
            end
            table.insert(funcTbl, tmpInit)
        end

        local function fadeIn()
            for key, var in pairs(mapTbl) do
                if var then
                    transition.fadeIn(var, {time=0.5})
                end
            end
        end
        table.insert(funcTbl, fadeIn)

        if useCoroutine then
            UnblockLoader.load(funcTbl, "ExploreMapMgr-mapInitFunc")
        else
            for key, var in pairs(funcTbl) do
                var()
            end
        end
    end

    mapInitFunc(mapRes)
    
    --二维码
    local resName = "Charactor/QRCode.csb"
    local hitNum = 0
    local serverName = GameLogMgr.roleInfo.serverName
    local QRNode = CSResourceMgr.createRes(scene, resName)
    QRNode:zorder(CocosModuleMgr.ZORDER_LOADING)
    CocosModuleMgr.setEdgeDistance(QRNode, 0, nil, 0, nil)
    CSResourceMgr.setSpriteTexture(resName, "qrcode", CocosModuleMgr.getWordImage("dl_qrcode.png"), nil, false)
    CSResourceMgr.setLabelString(resName, "info", CocosModuleMgr.createStringWithFormat({"服务器：<1>\n昵称：<2>\n击中数：<3>",
        serverName, CharInfo.getNickName(), hitNum}), nil, {r=0,g=0,b=0,a=255,s=1,w=1})
    
    --天气效果
    local curWeatherType = GetRandom.randomWithProbability({80, 20})
    EmbeddedMapMgr.addWeatherEffect(parent, curWeatherType, tag, mapScale)
    
    --小人动画
    local player = PlayerAnimeMgr.createPlayer(parent, {skin=CharInfo.getCurfashion()}, tag, false, false)
    PlayerAnimeMgr.setPlayerAniScale(tag, 1)
    player:pos(ExploreMapMgr.PLAYER_POSX-mapPosx, ExploreMapMgr.PLAYER_POSY)
    player:zorder(CocosModuleMgr.ZORDER_CHARACTOR)
    
    --点击屏幕抛投精灵球
    local isThrowing = false
    local touchLayer = display.newLayer():addTo(scene)
    touchLayer:setLocalZOrder(CocosModuleMgr.ZORDER_MOVETOUCH)
    touchLayer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    local function touchListener(event)
        if event.name == "ended" then
            return true
        end
        if event.name == "cancelled" then
            return true
        end
        if event.name == "began" or event.name == "moved" then
            if isThrowing then
            	return true
            end
            isThrowing = true
            local ballPosx = 0
            if event.x>ExploreMapMgr.PLAYER_POSX then
                player:setScaleX(1)
                ballPosx = ExploreMapMgr.BALL_POSX_DIFF
            else
                player:setScaleX(-1)
                ballPosx = -ExploreMapMgr.BALL_POSX_DIFF
            end
            PlayerAnimeMgr.playAniWithCallback(tag, "attack", function()
            	PlayerAnimeMgr.playAni(tag, "idle", true)            	
            	isThrowing = false
            end)
            local delayTime = 0.4
            scene:performWithDelay(function()
                local ball = display.newSprite("Item/ItemIcon/ball_normal.png")
                local moveTime = 0.3
                ball:scale(0.3)
                ball:addTo(parent)
                ball:zorder(CocosModuleMgr.ZORDER_CHARACTOR)
                ball:pos(ballPosx, ExploreMapMgr.PLAYER_POSY+ExploreMapMgr.BALL_POSY_DIFF)
                local ballPosy = 0
                local ballTerminalX = event.x-mapPosx
                if event.y>ExploreMapMgr.PLAYER_POSY then
                    ballPosy = ExploreMapMgr.PLAYER_POSY
                elseif event.y<ExploreMapMgr.PET_POSY then
                    ballPosy = ExploreMapMgr.PET_POSY
                else
                    ballPosy = event.y
                end
                transition.moveTo(ball, {x=ballTerminalX, y=ballPosy, time=moveTime})
                transition.scaleTo(ball, {scale=0.5, time=moveTime})
                transition.rotateTo(ball, {rotate=180, time=moveTime})
                scene:performWithDelay(function()
                    ball:removeFromParent(true)
                    for key, var in pairs(petNodes) do
                        local diff = math.abs(var:getPositionX()-ballTerminalX)
                        if diff<ExploreMapMgr.HIT_POS_DIFF then
                    		AnimationMgr.playAniWithCallback(var.res, "hurt", function()                                
                    			AnimationMgr.playAni(var.res, "walk", true, var.tag)
                                AnimationMgr.setSpeedRate(var.res, 0.75, var.tag)
                    		end, var.tag)
                            AnimationMgr.setSpeedRate(var.res, 1, var.tag)
                            hitNum = hitNum + 1
                            CSResourceMgr.setLabelString(resName, "info", CocosModuleMgr.createStringWithFormat(
                                {"服务器：<1>\n昵称：<2>\n击中数：<3>", serverName, CharInfo.getNickName(), hitNum}),
                                nil, {r=0,g=0,b=0,a=255,s=1,w=1})
                    	end
                    end
                end, moveTime)
            end, delayTime)
            return true
        end
    end
    touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, touchListener)
    
    --宠物行走
    local function addPet()
    	local petID = PokemonInfo.getRandomPokemonID()
        local petRes = PokemonInfo.getPokemonResByID(petID)
        local petObj = AnimationMgr.createAni(parent, petRes, ExploreMapMgr.PLAYER_POSX*2, ExploreMapMgr.PET_POSY, tag..os.time())
        petNodes[petObj.tag] = petObj
        petObj:setScale(-0.75, 0.75)
        petObj:zorder(CocosModuleMgr.ZORDER_MAP_FRONT)        
        AnimationMgr.playAni(petObj.res, "walk", true, petObj.tag)
        AnimationMgr.setSpeedRate(petObj.res, 0.75, petObj.tag)
        AnimationMgr.setSkin(petObj.res, 0, petObj.tag)
        local moveTime = GetRandom.random(8, 12)
        transition.moveTo(petObj, {x=-ExploreMapMgr.PLAYER_POSX*2, time=moveTime})
        scene:performWithDelay(function()
            petNodes[petObj.tag] = nil
            AnimationMgr.removeGafObjectByTag(petObj.res, petObj.tag)            
        end, moveTime)
        scene:performWithDelay(function()
            addPet()
        end, 4)
    end
    addPet()
end

return ExploreMapMgr