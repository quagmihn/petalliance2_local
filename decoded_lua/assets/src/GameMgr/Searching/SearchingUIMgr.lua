--created on 2015-07-23

local SearchingUIMgr = {}

SearchingUIMgr.tileNodePool = {}
SearchingUIMgr.eventNodePool = {}

SearchingUIMgr.advAniTable = {}

SearchingUIMgr.playerTag = ""

SearchingUIMgr.PLAYER_ZORDER = 21

SearchingUIMgr.ZORDER_OBSTRUCTION_CAVE_BASE = 0
SearchingUIMgr.ZORDER_GROUND_BASE           = 0
SearchingUIMgr.ZORDER_SWITCH_BASE           = 0
SearchingUIMgr.ZORDER_ITEMS_BASE            = 0
SearchingUIMgr.ZORDER_CHAR_BASE             = 0
SearchingUIMgr.ZORDER_MONSTER_BASE          = 0
SearchingUIMgr.ZORDER_OBSTRUCTION_HILL_BASE = 0
SearchingUIMgr.ZORDER_COVER_SHADOW          = 999

SearchingUIMgr.BLOCK_WIDTH  = 104   --方格大小
SearchingUIMgr.BLOCK_HEIGHT = 104   --方格大小
SearchingUIMgr.PNG_WIDTH    = 104   --圖片大小
SearchingUIMgr.PNG_HEIGHT   = 138   --圖片大小
SearchingUIMgr.LEFT         = 60  --105    --左上方格座標
SearchingUIMgr.TOP          = 624+52 --900   --左上方格座標
SearchingUIMgr.mapBoardFix  = 0
SearchingUIMgr.BLOCK_SIZE = {w=SearchingUIMgr.BLOCK_WIDTH,h=SearchingUIMgr.BLOCK_HEIGHT}
SearchingUIMgr.PNG_SIZE   = {w=SearchingUIMgr.PNG_WIDTH,h=SearchingUIMgr.PNG_HEIGHT}

--player action
SearchingUIMgr.FALL = false

--人物方向  front：1 back：2 left:3 right:4
SearchingUIMgr.palyerDirection = 1

SearchingUIMgr.missionShown = true

local centerResName = "Searching/centerBlockNew.csb"
local bottomResName = "Searching/bottomBar/bottomBar.csb"
local topResName    = "Searching/topBar/topBar.csb"

SearchingUIMgr.centerResName = centerResName
SearchingUIMgr.bottomResName = bottomResName
SearchingUIMgr.topResName    = topResName

--场景路径前/后缀
local envPrePath
local imgSuffix = ".png"

local _blocks  = {}   --block节点table
local _grounds = {}   --ground节点table

local monsterAniTable = {}  --动画资源总table

--adv_confirm数据
local TEAM_MAX    = 4
local currTeamIdx = 1  --当前队伍索引

--+++++++++++++    utils    --------------------------------------
---目标方格字符串分割
--@param string string 目标字符串
--@param format string 分割单元格式，例:(%d,%d,%d,%d)
--@return #table 目标字符串分割为对应table
local function stringSep(string, format, separator)
    if string == nil then return nil  end
    separator = separator or nil
    local str = clone(string)
    if str == "0" then 
        return "0"     --设为nil保存到plist时出错，未判nil 
    end
    local result = {}
    local startP = 1
    local endP = 0
    local destStr = ""
    while destStr ~= nil do
        startP, endP, destStr = string.find(str,format,endP+1)
        table.insert(result, destStr)
    end
    return result
end

---引导中button附加事件添加，其他情况下慎用（未写清除函式）
function SearchingUIMgr.btnAdditionalFunc(button, callback)
    if button==nil then
        return false
    end
    button:addTouchEventListener(function(sender, state)
        if state == 2 then
            CSResourceMgr.ButtonFuncTable[button](sender)
            if callback then
                callback()
            end
        end
    end)
end

function SearchingUIMgr.Init()
    print("SearchingUIMgr.Init()")
    SearchingUIMgr.FALL = false
    currTeamIdx = 1
    _blocks = {}
    _grounds = {}
end

function SearchingUIMgr.clear()
    _blocks = {}
    _grounds = {}
end

---获取block底板
function SearchingUIMgr.getBlockContainer()
    local res = ""
    if LtMapOption.getMapType() == "ADVENTURE" then
        res = centerResName
    elseif LtMapOption.getMapType() == "LOSTTOWER" then
        res = LostTowerUIMgr.centerResName
    else
        res = require("src.GameMgr.CommonDungeon.DungeonMapMgr").centerResName
    end
    return CSResourceMgr.getNodeByName(res,"fog")
end

---获取ground底板
function SearchingUIMgr.getGroundContainer()
    local res = ""
    if LtMapOption.getMapType() == "ADVENTURE" then
        res = centerResName
    elseif LtMapOption.getMapType() == "LOSTTOWER" then
        res = LostTowerUIMgr.centerResName
    else
        res = require("src.GameMgr.CommonDungeon.DungeonMapMgr").centerResName
    end
    return CSResourceMgr.getNodeByName(res,"ground")
end

---獲取block節點
function SearchingUIMgr.getBlockNode(i)
    if LtMapOption.getMapType() == "ADVENTURE" then
        return _blocks[i]
    elseif LtMapOption.getMapType() == "LOSTTOWER" then
        return LtMapNodeMgr.getBlockNode(i)
    else
        return LtMapNodeMgr.getBlockNode(i)
    end
end

---获取ground节点
function SearchingUIMgr.getGroundNode(i)
    if LtMapOption.getMapType() == "ADVENTURE" then
        return _grounds[i]
    elseif LtMapOption.getMapType() == "LOSTTOWER" then
        return LtMapNodeMgr.getGroundNode(i)
    else
        return LtMapNodeMgr.getGroundNode(i)
    end
end

---獲取player節點
function SearchingUIMgr.getPlayerNode()
    local res = ""
    if LtMapOption.getMapType() == "ADVENTURE" then
        res = centerResName
    elseif LtMapOption.getMapType() == "LOSTTOWER" then
        res = LostTowerUIMgr.centerResName
    else
        res = require("src.GameMgr.CommonDungeon.DungeonMapMgr").centerResName
    end
    return CSResourceMgr.getNodeByName(res,"player")
end

---设定block图片
function SearchingUIMgr.setBlockImg(block, filenameNormal,filenamePressed,filenameDisabled)
    local b_node = SearchingUIMgr.getBlockNode(block)
    local icon = CSResourceMgr.seekNodeByName(b_node,"b_icon")
    icon:removeAllChildren()
--    CSResourceMgr.setButtonTextureByNode(b_node,filenameNormal,filenamePressed,filenameDisabled)
    CSResourceMgr.seekNodeByName(b_node,"b_icon"):loadTexture(filenameNormal)
--    local sp = CSResourceMgr.seekNodeByName(b_node,"b_icon")
--    CSResourceMgr.setSpriteTextureByNode(sp,filenameNormal)
end

function SearchingUIMgr.setGroundImg(block, filenameNormal,filenamePressed,filenameDisabled)
    local g_node = SearchingUIMgr.getGroundNode(block)
    CSResourceMgr.setButtonTextureByNode(g_node,filenameNormal,filenamePressed,filenameDisabled)
end

-- 

function SearchingUIMgr.getBaseZOrder(i, isPlayerZOrder)
    local etype = SearchingMgr.eventInfoTable[i]

    local ret = math.ceil(i/LtMapOption.getMapCols()) * 4 - 3
    
    if LtMapOption.getMapType() == "ADVENTURE" then
        if etype == LtEventOption.EVENT_VOID then
            ret = 0
        end
    
        if etype == SearchingMapMgr.EVENT_MONSTER
        or etype == SearchingMapMgr.EVENT_TRAINER 
        or etype == LtEventOption.EVENT_LTBOSS 
        or etype == LtEventOption.EVENT_OTHERTRAINER   
        or etype == LtEventOption.EVENT_C_AWARDS
        or etype == SearchingMapMgr.EVENT_EXIT
        or etype == SearchingMapMgr.EVENT_OBSTRUCTION 
        or etype == LtEventOption.EVENT_ADV_NPC
        then
            ret = math.ceil(i/LtMapOption.getMapCols()) * 4
        end
        
        if isPlayerZOrder then 
            ret = math.ceil(i/LtMapOption.getMapCols()) * 4
        end
    elseif LtMapOption.getMapType() == "LOSTTOWER" then
        if isPlayerZOrder then 
            ret = math.ceil(i/LtMapOption.getMapCols()) * 4
        end
    end
    
    return ret
end

---calc zorder
function SearchingUIMgr.calcZOrderAt(i, isPlayerZOrder)
    isPlayerZOrder = isPlayerZOrder or false
    local etype = SearchingMgr.eventInfoTable[i]
    local zorder = SearchingUIMgr.getBaseZOrder(i, isPlayerZOrder)
    local zorder_added = LtWarFogMgr.getAdditionalZOrder(i)
    
    return zorder + zorder_added
end

---get current player zorder
function SearchingUIMgr.getCurrPlayerZOrder()
    return SearchingUIMgr.calcZOrderAt( SearchingMgr.playerCurrPosition, true )
end

---绑定block点击事件
function SearchingUIMgr.blockClickEvent(block, callback)
    local b_node = SearchingUIMgr.getBlockNode(block)
    CSResourceMgr.clickEventBindingByNode(b_node,function(sender, state)
        callback()
    end)
end

---设置地形资源
local function getGroundInfo()
    local groundInfo       = TxtReader.new("Config/dizhuanRes.txt")
    groundInfo.init({"id", "name", "res"}, 1)
    return groundInfo
end

function SearchingUIMgr.setEnv(type)
    if type == 1 then type = "cd/"
    elseif type == 2 then type = "ysd/"
    elseif type == 3 then type = "sm/"
    elseif type == 4 then type = "by/"
    end
    envPrePath = "Searching/env/"..type
    print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",envPrePath)
end

function SearchingUIMgr.initEnvironmentParams()
    local env = AdvEnvironmentMgr.getCurrentFieldType()
    if env == 1 then env = "cd/"
    elseif env == 2 then env = "ysd/"
    elseif env == 3 then env = "sm/"
    elseif env == 4 then env = "by/"
    else
    end
    envPrePath = "Searching/env/"..env

    --场景迷雾设定
    SearchingMapMgr.fogRes = {
        active = envPrePath.."blockbg.png",
        locked = {
            common  = envPrePath.."blockbgX.png",
            monster = envPrePath.."blockbgX2.png",
        }
    }
end

---添加UI
function SearchingUIMgr.addUI(scene)
    local advNodePool = require("src.GameMgr.Searching.advNodePool")
    
    SearchingUIMgr.eventNodePool = advNodePool.create()
    SearchingUIMgr.tileNodePool  = advNodePool.create()

    SearchingUIMgr.sc = scene
    
    --底板
--    local bgBoardImg = envPrePath.."background_0.png"
--    local bgBoard  = CSResourceMgr.createRes(scene, "Searching/MainBoard.csb")
--    CSResourceMgr.getNodeByName("Searching/MainBoard.csb","bg"):loadTexture(bgBoardImg)
--    CocosModuleMgr.setRelativePosition(bgBoard, 320, 480)
    
    --中间方格UI
    SearchingUIMgr.setCenterBlock(scene)
    
    --顶部UI
    SearchingUIMgr.setTopBar(scene)
    
    --底部UI
    SearchingUIMgr.setBottomBar(scene)

    --玩家UI設定
    SearchingUIMgr.initPlayer()
    
    --迷雾或者事件UI渲染
    SearchingUIMgr.initSlab()
    
    --道具栏初始化
    local propMgr = require("src.GameMgr.Searching.propMgr")
    propMgr.setAllProp()
    
    --星级目标提醒
    AdvStarMgr.addMissionUI(scene)
    AdvStarMgr.updateMissionUI(true)
    
    scene:performWithDelay(function()
        if SceneMgr.previousScene == "BattleScene" then return end
        local _advName = AdventureInfo.getAdventureInfoByID(SearchingMapMgr.currAdventure).name
        LtFuncMgr.showAdvName(scene, _advName, SearchingMapMgr.currFloor)
    end,0.3)
    
end

--++++++++++++++++++++++++++++++++++人物UI+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function SearchingUIMgr.initPlayer()
    SearchingUIMgr.playerTag = LtMapOption.getMapType().."player"  -- PlayerAnimeMgr.SELF_TAG_STRING
    
    SearchingMgr.player = SearchingUIMgr.getPlayerNode()
    SearchingMgr.player:setContentSize(SearchingUIMgr.BLOCK_WIDTH, SearchingUIMgr.BLOCK_HEIGHT)
    SearchingMgr.player:setScale(1.0)
    
    local function setPlayerAni()
        PlayerAnimeMgr.playAni(DungeonPlayerMgr.getPlayerTag(), "idle", true)
    end

    --去除人物所在位置mist
    local block = SearchingMgr.playerCurrPosition
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
    local x, y = SearchingUIMgr.getBlockNode(block):getPosition()
    SearchingMgr.player:setPosition(x, y)
    
    --set player zorder
    local zorder = SearchingUIMgr.calcZOrderAt( SearchingMgr.playerCurrPosition, true )  --math.ceil(id/LtMapOption.getMapCols())
    SearchingMgr.player:setLocalZOrder( zorder )
    
    --playerName显示
    local nametext = CharInfo.getNickName()
    local nameLabel = CSResourceMgr.getNodeByName(centerResName,"playerName")
    CSResourceMgr.setLabelColorByNode(nameLabel,{r=141,g=217,b=219,a=255})
    CSResourceMgr.setLabelStringByNode(nameLabel,nametext,{r=0,g=0,b=0,a=255,w=1})
    nameLabel:setLocalZOrder(99)
    
    --free fall
    SearchingUIMgr.freeFall(SearchingMgr.player, 125)
    
    --player动画播放
    local aniRes = SearchingMapMgr.playerResTbl["ani"][CharInfo.getSex()]
    if aniRes ~= nil then
        SearchingMapMgr.playerRes = aniRes
    else
        SearchingMapMgr.playerRes = SearchingMapMgr.playerResTbl["ani"][2]
    end

    local playerTag = SearchingUIMgr.playerTag
    SearchingUIMgr.playerAni = PlayerAnimeMgr.createPlayer(SearchingMgr.player, 
        {gender=CharInfo.getSex(), x=104/2, y=24,skin=CharInfo.getCurfashion()}, playerTag)
    SearchingUIMgr.playerAni:setScale(LtPlayerMgr.PLAYER_SCALE_X, LtPlayerMgr.PLAYER_SCALE_Y)
    
    if SearchingMgr.isAdventureEnd() then
        --player enter effect
        local effectRes = "Gaf/Searching/enterEffect.gaf"
        local fog_node = SearchingUIMgr.getBlockContainer()
        local x,y = SearchingUIMgr.getBlockNode(SearchingMgr.playerCurrPosition):getPosition()
        local enterEffect = AnimationMgr.createAni(fog_node, effectRes, x, y+630)
        enterEffect:setLocalZOrder(-1)
        
        SearchingMgr.canMove = false
        AnimationMgr.playAniWithCallback(effectRes,"do", function()
            fog_node:removeChild(enterEffect)
        end)
        SearchingMgr.player:setVisible(false)
        SearchingMgr.player:performWithDelay(function()
            setPlayerAni()
            SearchingUIMgr.playerEnter(0.4)
            SearchingMgr.player:setVisible(true)
        end,0.2)
    else
        setPlayerAni()
    end
    
    SearchingMgr.player:addTouchEventListener(function(sender, state)
        if SearchingMgr.onmove then return end
        if state == 3 then
            PlayerAnimeMgr.playAni(DungeonPlayerMgr.getPlayerTag(), "idle", true)
        elseif state == 2 then
            PlayerAnimeMgr.playAni(DungeonPlayerMgr.getPlayerTag(), "idle", true)
        elseif state == 0 then
            PlayerAnimeMgr.playAni(DungeonPlayerMgr.getPlayerTag(), "fly", true)
        end
    end)
    
    local scrollview = CSResourceMgr.getNodeByName(SearchingUIMgr.centerResName,"fog")
    DungeonMapMgr.scrollMapWithCellID(scrollview, SearchingMgr.playerCurrPosition)
    
end

---player转向方格i
function SearchingUIMgr.TurnToBlock(i)
    if i == SearchingMgr.playerCurrPosition then return end
    SearchingMgr.player_dir = i - SearchingMgr.playerCurrPosition  -- 方向参数改变方案
    
    local col, row = LtMapOption.convertToCoord(SearchingMgr.playerCurrPosition)
    local _col, _row = LtMapOption.convertToCoord(i)
    
    local direction = {}
    local offset_c = _col - col
    local offset_r = _row - row
    direction.c = (offset_c ~= 0) and offset_c / math.abs(offset_c) or 0
    direction.r = (offset_r ~= 0) and offset_r / math.abs(offset_r) or 0

    local curScalex = math.abs(SearchingUIMgr.playerAni:getScaleX())
    local curScaley = math.abs(SearchingUIMgr.playerAni:getScaleY())
    if direction.c >= 0 then
        SearchingUIMgr.playerAni:setScaleX(curScalex)  -- 动画默认为右
    else
        SearchingUIMgr.playerAni:setScaleX(-curScalex)
    end
    
    -- PlayerAnimeMgr.playAni(DungeonPlayerMgr.getPlayerTag(), "idle", true)
end

function SearchingUIMgr.StepTo(char, i, movetime, callback)
    if i < 1 or i > LtMapOption.getMapSize() then
        print("ADV_DEBUG_ERROR: Invalid block id...")
        return
    end

    local is_palyer = false
    
    --charinfo传入nil时，player为移动对象
    if char == nil then
        char = {}
        char.info = {}
        char.info.direction = {}
        char.info.res = SearchingMapMgr.playerRes
        char.info.pos = SearchingMgr.playerCurrPosition
        char.info.aniNode = SearchingUIMgr.playerAni
        char.info.aniTag = "player-ani"
        char.info.node = SearchingMgr.player
        SearchingMgr.onmove = true
        is_palyer = true
    end

    local px, py = SearchingUIMgr.getBlockNode(char.info.pos):getPosition()
    local tx, ty = SearchingUIMgr.getBlockNode(i):getPosition()
    
    AdvCharMgr.turnTo(char,i)
    AdvCharMgr.Walk(char)
    transition.moveBy(char.info.node, {x=tx-px, y=ty-py, time=movetime})
    
    if is_palyer then
        PlayerAnimeMgr.playAni(DungeonPlayerMgr.getPlayerTag(), "walk", true)
        SearchingMgr.player:performWithDelay(function()
            local zorder = SearchingUIMgr.calcZOrderAt( i, true )
            SearchingMgr.player:setLocalZOrder( zorder )
        end, movetime / 2)
    else        
        SearchingMgr.player:performWithDelay(function()
            local zorder = math.ceil(i/LtMapOption.getMapCols()) * 4  -- SearchingUIMgr.calcZOrderAt( id, true )
            char.info.node:setLocalZOrder( zorder )
        end, movetime / 2)
    end
    
    char.info.node:performWithDelay(function()
        AdvCharMgr.Idle(char)
        
        --移动节点为player时
        if is_palyer then
            if LtMapOption.getMapType() == "LOSTTOWER" then
                LostTowerMgr.LtMovedCallback(i)
            end
            char.info.pos = i
            SearchingMgr.onmove = false
            SearchingMgr.playerCurrPosition = i
            PlayerAnimeMgr.playAni(DungeonPlayerMgr.getPlayerTag(), "idle", true)
        end
        
        if callback then callback() end
    end, movetime)
    
end

function SearchingUIMgr.playerStepTo(id, movetime, callback)

    local is_palyer = true
    local node = SearchingMgr.player
    local currPos = SearchingMgr.playerCurrPosition

    SearchingMgr.onmove = true
    DungeonMapMgr.checkScroll(id)
    DungeonPlayerMgr.checkPlayerAction(id, movetime)
    
    node:performWithDelay(function()
        local zorder = SearchingUIMgr.calcZOrderAt( id, true )
        node:setLocalZOrder( zorder )
    end, movetime / 2)
    
    node:performWithDelay(function()
        SearchingMgr.onmove = false
        SearchingMgr.playerCurrPosition = id
        PlayerAnimeMgr.playAni(DungeonPlayerMgr.getPlayerTag(), "idle", true)
        
        if LtMapOption.getMapType() == "LOSTTOWER" then
            LostTowerMgr.LtMovedCallback(id)
        end

        local zorder = SearchingUIMgr.calcZOrderAt( id, is_palyer )
        node:setLocalZOrder( zorder )

        if callback then callback() end
    end, movetime)
    
end

--人物传送
---@function [parent=#src.GameMgr.Searching.SearchingUIMgr] transferPlayerTo
--@param i int player传送目标位置
--@param floor int 目标位置所在层[2015-11-04]
function SearchingUIMgr.transferPlayerTo(i, floor, callback)
    floor = floor or SearchingMapMgr.currFloor
    
    if floor == SearchingMapMgr.currFloor then
        if SearchingMgr.mapInfoTable[i] == 2 then
            SearchingMgr.mapInfoTable[i] = 1
            SearchingMgr.monsterDefendInfo[i] = 0
            SearchingUIMgr.activeSlab(i)
        end
        if SearchingMgr.mapInfoTable[i] == 1 then
            SearchingMgr.mistHidAt(i)
        end
        local x, y = SearchingUIMgr.getBlockNode(i):getPosition()
        SearchingMgr.player:setPosition(x, y)
        SearchingMgr.playerCurrPosition = i

        if callback then callback() end
    else
        if floor > SearchingMgr.floors then 
            print("ADV_DEBUG: ERROR, Floor overflow, check map floors defined in [AdventureInfo.dat]")
            return
        end
        
        print("传回第"..floor.."层")
        
        --出本层前结算伤害
        AdvPetsMgr.dealDamages(function()
            require("src.GameMgr.Searching.propMgr").removeShadow()
            AdvCharMgr.clearTrainers()
            SearchingMapMgr.currFloor = floor
            SearchingMgr.floorClear = true
            SearchingMapMgr.floorEnterance["floor"..SearchingMapMgr.currFloor] = i  --player传送目标点
            SceneMgr.replaceScene(SceneMgr.getRunningScene,"SearchingScene")
            
--            SearchingUIMgr.resetMap()

            if callback then callback() end
        end)
    end
    
    SearchingMgr.player:setLocalZOrder(SearchingUIMgr.calcZOrderAt(i, true))
end

--++++++++++++++++++++++++++++++++++迷霧層UI+++++++++++++++++++++++++++++++++++++++++++++++++++++++

---初始化迷雾
function SearchingUIMgr.initSlab()
    
    for i=1, LtMapOption.getMapSize() do
        local etype = SearchingMgr.eventInfoTable[i]
        local b_node = SearchingUIMgr.getBlockNode(i)
        local zorder = SearchingUIMgr.calcZOrderAt(i)  --math.ceil(i/LtMapOption.getMapCols())
        b_node:setLocalZOrder( zorder ) --物品Z軸
        --已經解鎖迷霧
        if 0 == SearchingMgr.mapInfoTable[i] then
            local col, row = LtMapOption.convertToCoord(i)
            if LtMapOption.isReachable(col, row) then
                SearchingMgr.unlockTonari(i)
            end
            LtEventOption.createEvent(i)
        end
        --可解鎖迷霧
        if 1 == SearchingMgr.mapInfoTable[i] then
            --迷雾UI默认为可解锁状态
        end
        --封鎖狀態迷霧
        if SearchingMgr.mapInfoTable[i] == 2 then
            if SearchingMgr.monsterDefendInfo[i] > 0 then 
                SearchingUIMgr.monsterLock(i)
            else
                SearchingUIMgr.coverSlab(i)
            end
        end
    end
    
--    DungeonMapMgr.reLocateNodes(SearchingMgr.playerCurrPosition)
end

---设置迷雾不可探索
function SearchingUIMgr.coverSlab(i)
    local b_node = SearchingUIMgr.getBlockNode(i)
    local g_node = SearchingUIMgr.getGroundNode(i)
    CSResourceMgr.setButtonEnabledByNode(b_node,false)
    CSResourceMgr.setButtonEnabledByNode(g_node,false)
    CSResourceMgr.seekNodeByName(b_node,"b_icon"):loadTexture(SearchingMapMgr.fogRes["locked"]["common"])
end

---激活迷雾可探索
function SearchingUIMgr.activeSlab(tag)
    local b_node = SearchingUIMgr.getBlockNode(tag)
    local g_node = SearchingUIMgr.getGroundNode(tag)
    CSResourceMgr.setButtonEnabledByNode(b_node,true)
    CSResourceMgr.setButtonEnabledByNode(g_node,true)
    CSResourceMgr.seekNodeByName(b_node,"b_icon"):loadTexture(SearchingMapMgr.fogRes["active"])
end

---迷雾消除
function SearchingUIMgr.hideSlab(i)
    local btn = SearchingUIMgr.getBlockNode(i)
    
    if 0 == SearchingMgr.eventInfoTable[i]
    or SearchingMgr.eventInfoTable[i] == SearchingMapMgr.EVENT_ENTERANCE
    then
        SearchingUIMgr.hideBlock(i)
    end
    
    print("hideSlab("..i..")")
    --入口时，player所在方格不播放解锁迷雾动画
    if i ~= SearchingMgr.playerCurrPosition then
        AdvEnvironmentMgr.playSceneMistHidEffect(AdvEnvironmentMgr.getCurrentFieldType(), i)
        GameAudio.playUISound("blockRefresh")
    end
    
end

---删除迷雾层[暂未使用]
function SearchingUIMgr.delSlab(tag)
    print("delSlab("..tag..")")
    local b_node = SearchingUIMgr.getBlockNode(tag)
    b_node:removeAllChildren()
    b_node:removeFromParent(true)
end

---del additional node
function SearchingUIMgr.delNode(tag)
    CSResourceMgr.getNodeByName("Searching/Node.csb", "stone", tag):removeAllChildren()
    CSResourceMgr.getNodeByName("Searching/Node.csb", "stone", tag):removeFromParent(true)
end

---隱藏block button
function SearchingUIMgr.hideBlock(i)
    local b_node = SearchingUIMgr.getBlockNode(i)
    local img = "Searching/empty.png"
    CSResourceMgr.setButtonTextureByNode(b_node, img, img, img)
    CSResourceMgr.seekNodeByName(b_node, "b_icon"):loadTexture(img)
    b_node:setContentSize(SearchingUIMgr.BLOCK_WIDTH, SearchingUIMgr.BLOCK_HEIGHT)
end

---清空block,还原默认点击事件
function SearchingUIMgr.clearBlock(i)

    SearchingUIMgr.stopAction(i)

    local _b = SearchingUIMgr.getBlockNode(i)
    local icon = CSResourceMgr.seekNodeByName(_b, "b_icon")
    icon:removeAllChildren()

    SearchingUIMgr.hideBlock(i)
    SearchingMgr.mapInfoTable[i] = 0
    SearchingMgr.itemTypeTable[i] = {}
    SearchingMgr.eventInfoTable[i] = LtEventOption.EVENT_VOID
    SearchingUIMgr.blockClickEvent(i, function()
        SearchingMgr.blockClickedEvent(i)
    end)
    
end

---monster封鎖迷霧
function SearchingUIMgr.monsterLock(tag)
    local b_node = SearchingUIMgr.getBlockNode(tag)
    
--    local img_active = SearchingMapMgr.fogRes["active"]
--    local img_locked = SearchingMapMgr.fogRes["locked"]["monster"]
--    SearchingUIMgr.setBlockImg(tag,  img_active, img_active, img_locked)
    
    CSResourceMgr.setButtonEnabledByNode(b_node,false)
    CSResourceMgr.seekNodeByName(b_node,"b_icon"):loadTexture(SearchingMapMgr.fogRes["locked"]["monster"])
end

--+++++++++++++++++++++++++++++++++++事件層UI+++++++++++++++++++++++++++++++++++++++++++++++++++++++

---清空block点击事件
function SearchingUIMgr.resetClickEventAt(block)
    SearchingUIMgr.blockClickEvent(block, function()
        SearchingMgr.blockClickedEvent(block)
    end)
end

---设置装饰物品Z值 [如，花朵之类]
--block 定为 SearchingMgr.playerCurrPosition
function SearchingUIMgr.setOrnamentZorder(block, isAllBelow)
    if tonumber(SearchingMgr.itemTypeTable[block].type) ~= 1 then return end
    
    local zorder = SearchingUIMgr.calcZOrderAt(block,true)
    --math.ceil(block/LtMapOption.getMapCols())   --SearchingUIMgr.PLAYER_ZORDER 
    
    local resName = clone(SearchingMgr.itemTypeTable[block].resName)
    local eventstate = SearchingMgr.eventStateInfoTable[block]
    
    if resName == nil then return end
    
    local tbl = SearchingMapMgr.floorTargetBlocks["floor"..SearchingMapMgr.currFloor][block]
    if type(tbl) == "table" then
        for key, var in pairs(tbl) do

            local tbl = var
            
            local res = SearchingMgr.itemTypeTable[block]["res1"]
            local img = "Searching/spine/"..res..tbl[4]..".png"
            
            if cc.FileUtils:getInstance():isFileExist(img) then
            
                local ani = AnimationMgr.getGafObj(img,block..tbl[2]..tbl[3])
                ani:setLocalZOrder(zorder + 1)
                
                local yFix = tonumber(tbl[3])
                local d = 30   --中间值
                
                if yFix <= d then
                    ani:setLocalZOrder(zorder + 1)
                end
                
                if yFix > d then
                    ani:setLocalZOrder(zorder - 1)
                end
                
                if isAllBelow then
                    ani:setLocalZOrder(zorder - 1)
                end
                
            end
            
        end
    end
end


function SearchingUIMgr.resetGroudImg(block)

    local groundInfo = getGroundInfo()
    local groundResId = SearchingMapMgr.floorEnvTable["floor"..SearchingMapMgr.currFloor][block]["terrRes"]
    local groundRes = string.split(groundInfo.get(groundResId).res, ",")

    local groundImg = AdvEnvironmentMgr.makePath("dz"..groundResId)
    
    local g_node = SearchingUIMgr.getGroundNode(block)
    g_node:setContentSize(114, 145)
    CSResourceMgr.setButtonTextureByNode(g_node,  groundImg,  groundImg,  groundImg)

    SearchingUIMgr.hideBlock(block)
    
end


---初始化事件方格UI
--@param block int 方格編號
--@param resName table 圖片資源table
--@param size table 方格大小
function SearchingUIMgr.setBlockUI(block, size)
    size = size or SearchingUIMgr.BLOCK_SIZE
    local node = SearchingUIMgr.getBlockNode(block)
    local resName = clone(SearchingMgr.itemTypeTable[block].resName)
    local eventstate = SearchingMgr.eventStateInfoTable[block]
    
    if resName == nil then
        resName = {"empty","empty","empty",}
    else
        if resName[eventstate] == nil or resName[eventstate] == "nil" then
            resName[eventstate] = "empty"
        end
    end
    local img = SearchingUIMgr.getItemImg(block)
    
    if cc.FileUtils:getInstance():isFileExist(img) then
        SearchingUIMgr.getBlockNode(block):setContentSize(size.w, size.h)
        SearchingUIMgr.setBlockImg(block,  img,  img, img)
    end
    if SearchingMgr.eventInfoTable[block] == SearchingMapMgr.EVENT_VOID and tonumber(SearchingMgr.itemTypeTable[block].type) == 1 then
        local xFix,yFix
        local tbl = SearchingMapMgr.floorTargetBlocks["floor"..SearchingMapMgr.currFloor][block]
        if type(tbl) == "table" then
            for key, var in pairs(tbl) do
                xFix, yFix = size.w*(tonumber(var[2])-50)/100, size.h*(tonumber(var[3]-50))/100    --50为中轴线
                local res = SearchingMgr.itemTypeTable[block]["res1"]
                img = "Searching/spine/"..res..var[4]..".png"
                
                local x, y = SearchingUIMgr.getBlockNode(block):getPosition()
                local hua = AnimationMgr.createAni(CSResourceMgr.getNodeByName(centerResName,"fog"), img, x+xFix, y+yFix, block..var[2]..var[3])
                local zorder = SearchingUIMgr.calcZOrderAt(block) --math.ceil(block/LtMapOption.getMapCols())
                AnimationMgr.playAni(img, "idle", true, block..var[2]..var[3])
                hua:setLocalZOrder( zorder ) --物品Z軸
            end
        end
    end
    
end


---方格点击事件
function SearchingUIMgr.bindBlockEvent(block, callback)

    local eType = SearchingMgr.eventInfoTable[block]
    local b_node = SearchingUIMgr.getBlockNode(block)
    
    CSResourceMgr.clickEventBindingByNode(b_node,function(sender, state)
        local btn = SearchingUIMgr.getGroundNode(block)
        local effAni = AnimationMgr.createAni(btn, "Spine/effects/UI-fubendianji.png", 
            btn:getContentSize().width/2, 12+btn:getContentSize().height/2, block)
        AnimationMgr.playAniWithCallback(effAni.res, "animation", nil, block, true)
        
        AdvEnvironmentMgr.playSceneClickEffect(AdvEnvironmentMgr.getCurrentFieldType(),block)

        callback()

        local beginFlag = "************************  SearchingUIMgr.bindBlockEvent  **************************"
        local endFlag   = "******************************       End       ************************************"
        SearchingMgr.printAllInfo(beginFlag,endFlag)
    end)
    
end


---初始化训练师UI [废弃你，可怜的代码]
function SearchingUIMgr.initTrainerUI(block)
    local node = SearchingUIMgr.getBlockNode(block)
    SearchingUIMgr.hideBlock(block)
    local AIFunc = SearchingFuncMgr.getEventFunc(block)
    AIFunc(block)
end


function SearchingUIMgr.removeAllMonsterAni()
    print("removeAllMonsterAni")
    for key, value in pairs(monsterAniTable) do
        -- print(value.res, value.tag)
        if value.res and value.tag then
            AnimationMgr.removeGafObjectByTag(value.res, value.tag)
        end
    end
    monsterAniTable = {}
end



---初始化MonsterUI
--@param MonsterType int Monster类型
--@param img string 图片资源
function SearchingUIMgr.initMonsterUI(MonsterType,block, tag)
    print("Init Monster UI")
    local b_node = SearchingUIMgr.getBlockNode(block)
    local blockX, blockY = b_node:getPosition()
    
    local petnumber = SearchingMgr.itemTypeTable[block].petnumber
    local resName = PokemonInfo.getPokemonResByID(petnumber)
    
    if 1 == MonsterType then   --小怪
        SearchingUIMgr.hideBlock(block)
    
        if SearchingMgr.eventStateInfoTable[block] == 3 then return end
        
        local floor = SearchingMapMgr.currFloor
        if LtMapOption.getMapType() == "ADVENTURE" and SearchingMapMgr.firedDisposableEvents[floor] and SearchingMapMgr.firedDisposableEvents[floor][block] then
            local ani = AnimationMgr.createAni(b_node, "Spine/pet/default.png", SearchingUIMgr.BLOCK_WIDTH/2, SearchingUIMgr.BLOCK_HEIGHT/2-10, block)
            AnimationMgr.playAni("Spine/pet/default.png", "idle", true, block)
            b_node:setContentSize(SearchingUIMgr.PNG_WIDTH, SearchingUIMgr.PNG_HEIGHT)
            ani:setScale(0.4)
            table.insert(monsterAniTable, ani)
            local label = CSResourceMgr.getNodeByName(centerResName,{"fog","player","playerName"}):clone()
            CSResourceMgr.setLabelStringByNode(label,"???",CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            ani:addChild(label)
            label:setScale(3.0*label:getScaleX())
            label:setPosition(0,180)
        else
            local ani = AnimationMgr.createAni(b_node, resName, SearchingUIMgr.BLOCK_WIDTH/2, SearchingUIMgr.BLOCK_HEIGHT/2-10, block)
            AnimationMgr.playAni(resName, "idle", true, block)
            
            local skinid = SearchingMgr.itemTypeTable[block].specialState or 0
            AnimationMgr.setSkin(resName, skinid, ani.tag)
            
            b_node:setContentSize(SearchingUIMgr.PNG_WIDTH, SearchingUIMgr.PNG_HEIGHT)
            ani:setScale(0.4)
            table.insert(monsterAniTable, ani)
        end
        
        
        SearchingUIMgr.bindBlockEvent(block,function()
            if SearchingMgr.onmove and SearchingMgr.canMove then
                if block ~= SearchingMgr.destination then
                    SearchingMgr.cancelMove = true  --移动取消标志 
                    SearchingMgr.cancelAt = block
                end
                return
            end
            SearchingMgr.moveWithCallback(block, function()
                local func = SearchingFuncMgr.getEventFunc(block)
                if func then func(block) end
            end)
        end)
    end
end


---获取事件表现图片/动画
function SearchingUIMgr.getItemImg(block, EventState)
    EventState = EventState or SearchingMgr.eventStateInfoTable[block]
    
    local img = "Searching/empty.png"  -- default
    local resNameTbl = SearchingMgr.itemTypeTable[block].resName
    if not resNameTbl then
        return img
    end
    if not resNameTbl[EventState] or resNameTbl[EventState] == "nil" then
        return img
    end
    
    if type(resNameTbl) == "string" then
        
    end
    
    if type(resNameTbl) == "table" then
        return resNameTbl[EventState]
    end

    return img
end



---初始化itemUI，綁定事件
--@param itemType int item类型
function SearchingUIMgr.initItemUI(block)
    if SearchingMgr.ADV_DEBUG then
        print("Init Item UI at  "..block)
    end
    
    local blockBtn = SearchingUIMgr.getBlockNode(block)
    local resTbl = SearchingMgr.itemTypeTable[block].resName
    if resTbl == nil then
        print(SearchingMgr.itemTypeTable[block].name)
        print(SearchingMgr.itemTypeTable[block].resName)
        print("ADV_DEBUG_INFO:"..block.."   没有图片....")
        return 
    end
    
    local img = SearchingUIMgr.getItemImg(block)
    if not cc.FileUtils:getInstance():isFileExist(img) then
        print("TEXTURE NOT FOUND:",img)
    else
        SearchingUIMgr.setBlockImg(block,  img,  img, img)
    end
    
    local isGround = SearchingMgr.itemTypeTable[block].isGround
    isGround = isGround or "0"
    
    -- check if it's the ground
    if tonumber(isGround) == 1 then
        if SearchingMgr.eventInfoTable[block] == LtEventOption.EVENT_SWITCH or SearchingMgr.eventInfoTable[block] == LtEventOption.EVENT_OBSTRUCTION then
            SearchingUIMgr.hideBlock(block)
            local ground = SearchingUIMgr.getGroundNode(block)
            ground:setContentSize(114, 145)
            local img = SearchingUIMgr.getItemImg(block)
            CSResourceMgr.setButtonTextureByNode(ground,  img,  img,  img)
        end
    end
    
    -- check if it's animation
    local aniRes = SearchingMgr.itemTypeTable[block].aniRes
    if aniRes and cc.FileUtils:getInstance():isFileExist(aniRes) then   -- LtMapOption.getMapType() == "ADVENTURE" and 
        SearchingUIMgr.hideBlock(block)
        
        local _x = SearchingUIMgr.BLOCK_WIDTH/2
        local _y = SearchingUIMgr.BLOCK_HEIGHT/2 - 30

        local ani = AnimationMgr.createAni(blockBtn, aniRes, _x, _y, block)
        AnimationMgr.playAni(aniRes, "animation", true, block)

        table.insert(monsterAniTable, ani)
    end
    
    if img ~= nil then
        
        --water
        if SearchingMgr.itemTypeTable[block].name == "water" 
        or SearchingMgr.itemTypeTable[block].name == "waterone"  
        or SearchingMgr.itemTypeTable[block].name == "watertwo" then
            SearchingUIMgr.hideBlock(block)
            local g_node = SearchingUIMgr.getGroundNode(block)
            g_node:setContentSize(114, 145)
            local img = SearchingUIMgr.getItemImg(block)
            CSResourceMgr.setButtonTextureByNode(g_node,  img,  img,  img)
            
            local ani = AnimationMgr.createAni(g_node, "Gaf/Searching/water.gaf", 568, 466, block)
            AnimationMgr.playAni("Gaf/Searching/water.gaf", "do", true, block)
            AnimationMgr.setSpeedRate("Gaf/Searching/water.gaf" ,0.6, block)    --设置播放速度

            table.insert(monsterAniTable, ani)
        end
        
        --石坑
        if SearchingMgr.itemTypeTable[block].name == "keng"
        or SearchingMgr.itemTypeTable[block].name == "keng1" 
        or SearchingMgr.itemTypeTable[block].name == "keng2" then
            SearchingUIMgr.hideBlock(block)
            local ground = SearchingUIMgr.getGroundNode(block)
            ground:setContentSize(114, 145)
            local img = SearchingUIMgr.getItemImg(block)
            CSResourceMgr.setButtonTextureByNode(ground,  img,  img,  img)
        end
        
        -- 冰面
--        if SearchingMgr.itemTypeTable[block].name == "ice" then
--            SearchingUIMgr.hideBlock(block)
--            local ground = SearchingUIMgr.getGroundNode(block)
--            ground:setContentSize(114, 145)
--            local img = SearchingUIMgr.getItemImg(block)
--            CSResourceMgr.setButtonTextureByNode(ground,  img,  img,  img)
--        end

--        if LtMapOption.getMapType() == "LOSTTOWER" and SearchingMgr.itemTypeTable[block].name == "kbs" then
--            SearchingUIMgr.hideBlock(block)
--            local aniResName = "Spine/searching/damingxiong.png"  -- "Spine/searching/kabishou.png"
--            local _x = SearchingUIMgr.BLOCK_WIDTH/2
--            local _y = SearchingUIMgr.BLOCK_HEIGHT/2 - 30
--            
--            local ani = AnimationMgr.createAni(blockBtn, aniResName, _x, _y, block)
--            AnimationMgr.playAni(aniResName, "animation", true, block)
--
--            table.insert(monsterAniTable, ani)
--        end
        
--        if SearchingMgr.itemTypeTable[block].name == "csm" then
--            SearchingUIMgr.hideBlock(block)
--            local ccb = CSResourceMgr.createCCBI(blockBtn,"texture/ui_dc_06b.ccbi",52,32)
--            ccb:setScale(0.66)
--        end
        
    end

    blockBtn:setContentSize(SearchingUIMgr.BLOCK_WIDTH, SearchingUIMgr.BLOCK_HEIGHT)
    
    if LtMapOption.getMapType() == "ADVENTURE" then
        local b_node = SearchingUIMgr.getBlockNode(block)
        local b_icon = CSResourceMgr.seekNodeByName(b_node,"b_icon")
        
        if SearchingMgr.itemTypeTable[block].picked then
            b_icon:setOpacity(188)
        else
            b_icon:setOpacity(255)
        end
    end

end


--- 播放item 动作
-- @param block number 方格ID
-- @param type number 1:浮动
function SearchingUIMgr.playAction(block, type)

    type = type or 1
    local _f = SearchingUIMgr.getBlockNode(block)
    local icon = CSResourceMgr.seekNodeByName(_f,"b_icon")
    icon:removeAllChildren()
    
    transition.stopTarget(icon)
    
    if SearchingMgr.eventInfoTable[block] == LtEventOption.EVENT_C_AWARDS
    or SearchingMgr.eventInfoTable[block] == LtEventOption.EVENT_BUFF 
    then
        icon:setPositionY(80)
        local move1 = cc.MoveBy:create(0.5,cc.p(0, 6))
        local move2 = cc.MoveBy:create(0.5,cc.p(0,-6))
        local action = cc.RepeatForever:create(cc.Sequence:create(move1, move2))
        icon:runAction(action)
        
        local sp = display.newSprite("UI/CommonFiles/losttower_item_shadow.png")
        SearchingUIMgr.getGroundNode(block):addChild(sp)
        sp:setPosition(57,67)
        sp:setOpacity(200)
        sp:setScale(0.8)
        local scale1 = cc.ScaleTo:create(0.5, 0.7)
        local scale2 = cc.ScaleTo:create(0.5, 0.8)
        sp:runAction(cc.RepeatForever:create(cc.Sequence:create(scale1, scale2)))
    end
    if SearchingMgr.eventInfoTable[block] == LtEventOption.EVENT_RANDOMBOX then
        local sp = display.newSprite("UI/CommonFiles/losttower_item_shadow.png")
        SearchingUIMgr.getGroundNode(block):addChild(sp)
        sp:setPosition(57,64)
        sp:setOpacity(200)
        
        if SearchingMgr.eventStateInfoTable[block] == 3 then return end
        
        local typeRes = SearchingMgr.itemTypeTable[block].typeRes or "empty.png"
        if typeRes and not cc.FileUtils:getInstance():isFileExist(typeRes) then return end
        local sp = display.newSprite(typeRes)
        local f = SearchingUIMgr.getBlockNode(block)
        local icon = CSResourceMgr.seekNodeByName(f,"b_icon")
        icon:addChild(sp)
        sp:setPosition(icon:getContentSize().width / 2,80)
        sp:setScale(42 / sp:getContentSize().width)
    end
    
end


function SearchingUIMgr.stopAction(block)
    local _f = SearchingUIMgr.getBlockNode(block)
    local icon = CSResourceMgr.seekNodeByName(_f,"b_icon")
    transition.stopTarget(icon)
    icon:setPosition(52, 52)
    SearchingUIMgr.getGroundNode(block):removeAllChildren()
end


---机关激活物品掉落
function SearchingUIMgr.itemDrop(block, height, duration) 
    local actionUp = cc.JumpBy:create(duration, cc.p(0,0), height, 1)  
    local actionDown = actionUp:reverse()-- 相反操作  

    -- 执行actionTo动作  
    SearchingUIMgr.getBlockNode(block):runAction(actionDown)  
end


local tipTag = 1

---显示tips
function SearchingUIMgr.showTips(scene, string, x, y)
    local resName = "UI/Common/Tips.csb"
    scene = scene or SceneMgr.getRunningScene
    x = x or 320
    y = y or 800

    if tipTag>255 then
        if not CSResourceMgr.getCsbObj(resName,tipTag) then
            tipTag = 1
        end
    end
    tipTag = tipTag + 1
    local tipsLayer = CSResourceMgr.createRes(scene, resName, tipTag)
    CSResourceMgr.setRelativePosition(resName, x, y, tipTag)
    tipsLayer:setLocalZOrder(98)

    CSResourceMgr.setLabelString(resName, {"tipbg", "tips"}, LuaSqlite.getLanguageByKey(string), tipTag, CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
    CSResourceMgr.playAction(resName, 0, 20, false, tipTag)

    local function tipsDisappear(tag)
        local node = CSResourceMgr.getCsbObj(resName, tag)
        node:performWithDelay(function()
            transition.fadeOut(node, {time = 0.5})
            tipsLayer:performWithDelay(function()
                CSResourceMgr.removeCSObjectByTag(resName, tag)
            end, 0.5)
        end, 2)
    end

    tipsDisappear(tipTag)

    local function tipsMoving(tag)
        local node = CSResourceMgr.getCsbObj(resName, tag)
        if node then
            transition.moveBy(node, {y=50, time=0.1})
            tipsMoving(tag-1)
        end
    end

    tipsMoving(tipTag-1)
end

--+++++++++++++++++++++++++++界面UI功能++++++++++++++++++++++++++++++


local function addItemDesc(parent,itemInfo)

    local itemInfoBoard = CSResourceMgr.createRes(parent, "Searching/Common/itemInfoLayer.csb")
    itemInfoBoard:setPosition(100,240)
    CSResourceMgr.playAction("Searching/Common/itemInfoLayer.csb",0,15,false)

    local itemName = CSResourceMgr.getNodeByName("Searching/Common/itemInfoLayer.csb","itemName")
    local itemDesc = CSResourceMgr.getNodeByName("Searching/Common/itemInfoLayer.csb","itemDesc")
    CSResourceMgr.setLabelString("Searching/Common/itemInfoLayer.csb","itemName",itemInfo.name,"",{r=0,g=0,b=0,a=255})
    CSResourceMgr.setLabelString("Searching/Common/itemInfoLayer.csb","itemDesc",itemInfo.desc,"",{r=0,g=0,b=0,a=255})

    CSResourceMgr.clickEventBinding("Searching/Common/itemInfoLayer.csb","db",function()
        CSResourceMgr.playAction("Searching/Common/itemInfoLayer.csb",25,40,false)
        transition.fadeOut(itemInfoBoard, {time = 0.2})
        itemInfoBoard:performWithDelay(function()
            itemInfoBoard:removeAllChildren()
            itemInfoBoard:removeFromParent(true)
        end,0.2)
    end)

    --显示道具描述
end

local function isTabOpen(aid, tabid)
    aid = aid % 10000
    
    if tabid == 1 then
        return true
    elseif tabid == 2 then
        if AdvStarMgr.checkClearFlag(aid) then return true end  -- 普通关卡完成精英页签开启
    elseif tabid == 3 then
        if AdvStarMgr.checkClearFlag(aid + 10000) then return true end  -- 精英关卡完成英雄页签开启
    end
    
    return false
end

---打开探索界面
--@param scene scene 打开的场景
--@param currAdv int 副本的id
--@param curTab int 切换的tab
--@param callback function 界面打开后的回调
function SearchingUIMgr.addAdvConfirmUI(scene, currAdv, curTab, callback)
    
    curTab = curTab or math.ceil(currAdv/10000)
    currAdv = currAdv % 10000
    
    if curTab ~= 4 then
        if not isTabOpen(currAdv, curTab) then
            StandardTipsMgr.show(1, "tips22")
            return
        end
    else
        if not AdvStarMgr.checkClearFlag(currAdv) then
            StandardTipsMgr.show(1, "tips22")
            return
        end
    end
    
    AdvConfirmMgrNew.show(scene, currAdv, curTab, callback)

end


--- setCenterBlock
function SearchingUIMgr.setCenterBlock(scene)
    local centerBlock = CSResourceMgr.getCsbObj(centerResName)
    
    if not centerBlock then
        centerBlock = CSResourceMgr.createRes(scene, centerResName)
        CSResourceMgr.setFullScreen(centerResName)

        SearchingUIMgr.eventNodePool.init(
            CSResourceMgr.getNodeByName(centerResName, "fog"),
            CSResourceMgr.getNodeByName(centerResName, "blockSample")
        )
        SearchingUIMgr.tileNodePool.init(
            CSResourceMgr.getNodeByName(centerResName, "fog"),
            CSResourceMgr.getNodeByName(centerResName, "groundSample")
        )
    end
    
    local kuang = CSResourceMgr.getNodeByName(centerResName,"kuang")
    
    local prePath = AdvEnvironmentMgr.getPrepath()
    
    -- 临时处理, 没有资源  TODO
--    if LtMapOption.getMapSize() > 30 then
--        kuang:loadTexture("empty.png")  --(envPrePath.."kuang.png")
--    else
--        kuang:loadTexture(prePath.."kuang.png")
--    end
    
    kuang:loadTexture("empty.png")
    
    local top  = SearchingUIMgr.TOP
    local left = SearchingUIMgr.LEFT
    local blockwidth = SearchingUIMgr.BLOCK_WIDTH
    local blockheight = SearchingUIMgr.BLOCK_HEIGHT
    
    local function set()
    
        _blocks = {}
        _grounds = {}

        local f = CSResourceMgr.seekNodeByName(centerBlock,"fog")
        f:setBounceEnabled(false)
        
        local GRID_WIDTH = 104
        local mapWidth  = LtMapOption.getMapCols()
        local mapHeight = LtMapOption.getMapRows()
        f:setInnerContainerSize({width = mapWidth*GRID_WIDTH, height = mapHeight*GRID_WIDTH})
--        f:setBounceEnabled(false)
        
--        if LtMapOption.getMapSize() > 30 then
            DungeonMapMgr.setBackground(f, (3-1)*mapWidth+3)
            DungeonMapMgr.setFrame(f, (3-1)*mapWidth+3)
--        end
        
        --迷雾/地砖位置调整
        f:setPosition(60, 185+40+624)
        
        --迷雾资源
        local block_active = SearchingMapMgr.fogRes["active"]
        local block_locked = SearchingMapMgr.fogRes["locked"]["common"]
        
        local cols = LtMapOption.getMapCols()
        local rows = LtMapOption.getMapRows()
        local mapSize = LtMapOption.getMapSize()
        for i=1, LtMapOption.getMapSize() do

            --地砖资源
            local groundResId = SearchingMapMgr.floorEnvTable["floor"..SearchingMapMgr.currFloor][i]["terrRes"]
            local groundImg = prePath.."dz"..groundResId..imgSuffix
            local groundImgX = prePath.."dz"..groundResId.."_l"..imgSuffix

            local g_ = SearchingUIMgr.tileNodePool.pop()  -- g_sample:clone()
            -- g_:addTo(f)
            g_:setLocalZOrder(math.ceil(i/cols)-rows-1)
            g_:setContentSize(114, 145)
            g_:setPosition(blockwidth/2+blockwidth*((i-1)%cols), (mapHeight*GRID_WIDTH+52-blockheight*math.ceil(i/cols)))
            CSResourceMgr.setButtonTextureByNode(g_,  groundImg,  groundImg,  groundImgX)
            CSResourceMgr.setButtonEnabledByNode(g_, true)
            table.insert(_grounds, g_)
            
            local f_ = SearchingUIMgr.eventNodePool.pop()   -- f_sample:clone()
            -- f_:addTo(f)
            f_:setContentSize(104, 104)
            f_:setPosition(blockwidth/2+blockwidth*((i-1)%cols), mapHeight*GRID_WIDTH+15+52-(blockheight*math.ceil(i/cols)))
            CSResourceMgr.seekNodeByName(f_, "b_icon"):loadTexture(block_active)
            CSResourceMgr.setButtonEnabledByNode(f_, true)
            table.insert(_blocks, f_)

            SearchingUIMgr.blockClickEvent(i, function()
                SearchingMgr.blockClickedEvent(i)
            end)
            
        end
        
    end
    
    set()
    
end


---@function 设置副本内顶部UI
function SearchingUIMgr.setTopBar(scene)
    local resName = topResName
    
    local topBar = CSResourceMgr.createRes(scene, topResName)
    CSResourceMgr.setFullScreen(topResName)
    CocosModuleMgr.setEdgeDistance(topBar, nil, nil, 0, nil, false)

    --成就星数
    for i = 1, 3 do
        local star = CSResourceMgr.getNodeByName(topResName,"star"..i)
        star:setVisible(false)      --默认灰态
    end
    
    local gainNum = CSResourceMgr.getNodeByName(resName,"gainNum")
    local coinNum = CSResourceMgr.getNodeByName(resName,"coinNum")
    local outline = {r=0,g=0,b=0,a=255}
    local textColor = {r=255,g=255,b=204,a=255}
    
    CSResourceMgr.setLabelColorByNode(gainNum,textColor)
    CSResourceMgr.setLabelColorByNode(coinNum,textColor)
    CSResourceMgr.setLabelStringByNode(gainNum,"X"..SearchingMapMgr.currGainNum,outline)
    CSResourceMgr.setLabelStringByNode(coinNum,"X"..SearchingMapMgr.currCoinNum,outline)
    
    CSResourceMgr.clickEventBinding(topResName,"stars",function()
        AdvStarMgr.showMission()
    end)

    -- giveup-btn
    CSResourceMgr.clickEventBinding(topResName,"giveup",function()
--        DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 2, "advtext15", function() -- "确定放弃？"
--            SearchingMgr.leaveAdventure()
--        
--            SearchingMgr.UN_SCH_GLOBAL_CHECK()
--            SearchingMgr.dungeonClear = true
--            SearchingMgr.floorClear = true
--            SearchingMapMgr.currFloor = 1
--            SearchingMapMgr.floorMapInfoTbl = {}
--            SearchingMapMgr.floorEventTbl = {}
--            SearchingMapMgr.floorEventStateTbl = {}
--            SearchingMapMgr.floorItemTbl = {}
--            SearchingMapMgr.floorMstrDefendTbl = {}
--            SearchingMapMgr.floorTargetBlocks = {}
--            SearchingMapMgr.floorEnterance = {}
--            SearchingMapMgr.floorExit = {}
--            SearchingMgr.adventure_failed(function()
--                SceneMgr.replaceScene(SceneMgr.getRunningScene, "MainScene")
--            end)
--        end)
        advResetView.show()
    end, nil, true)
    CSResourceMgr.clickEventBinding(topResName,"giveup_db",function()
        advResetView.show()
    end)
    CSResourceMgr.setLabelString(resName,"giveup_t","advtext19",nil,nil,nil,48) -- "放弃"
    if not SearchingMgr.canGiveUp then
        BattleCCSB.stopQuitBattle()
        CSResourceMgr.setButtonEnabled(SearchingUIMgr.topResName,{"db","giveup"},false)
        CSResourceMgr.setButtonEnabled(SearchingUIMgr.topResName,{"db","giveup_db"},false)
    end
    
end


---@function 设置副本内部底部UI
function SearchingUIMgr.setBottomBar(scene)
    local resName = bottomResName
    local bottomBar = CSResourceMgr.createRes(scene, bottomResName)
    CSResourceMgr.setFullScreen(bottomResName)
    CocosModuleMgr.setEdgeDistance(bottomBar, nil, nil, nil, 0, false)
    bottomBar:setLocalZOrder(CocosModuleMgr.ZORDER_BAR)
    
    local outline = {r=0,g=0,b=0,a=255,w=1}
    local textColor = {r=255,g=255,b=255,a=255}
    
    local tagText = "advtext1"
    local targets  = CSResourceMgr.getNodeByName(bottomResName,"tagText")
    CSResourceMgr.setLabelColorByNode(targets,textColor)
    CSResourceMgr.setLabelStringByNode(targets,tagText,outline,nil,100)
    
    local packText = "advtext2"
    local package  = CSResourceMgr.getNodeByName(bottomResName,"liuyanText")
    CSResourceMgr.setLabelColorByNode(package,textColor)
    CSResourceMgr.setLabelStringByNode(package,packText,outline,nil,100)
    
    CSResourceMgr.clickEventBinding(bottomResName,"targets",function()
        AdvStarMgr.showMission()
    end, "", true)
    
    CSResourceMgr.clickEventBinding(bottomResName,"liuyan",function()
        local adventureInfo = AdventureInfo.getAdventureInfoByID(SearchingMapMgr.currAdventure)
        MsgBoardView.show(scene,2,adventureInfo)
    end, "", true)
    
    local m_label = CSResourceMgr.getNodeByName(bottomResName, {"mainPets", "m_pet_label"})
    local h_label = CSResourceMgr.getNodeByName(bottomResName, {"helpPets", "h_pet_label"})
    CSResourceMgr.setLabelStringByNode(m_label,"train107")
    CSResourceMgr.setLabelStringByNode(h_label,"train108")
    
    -- 宠物栏位lock
    local maxPetCount = PetFormationMgr.getMaxPetCount()
    
    local currSelect   --拖拽item
    local pNodes  = {}  --pet节点table
    local petObjIDs = {}

    local petList = CSResourceMgr.getNodeByName(resName,"petQue")
    
    local emptyNode_sample = CSResourceMgr.getNodeByName(resName,"emptyPet")
    AdvPetsMgr.emptyNodes = {}
    for i = 1, 3 do
        local emptyNode = emptyNode_sample:clone()
        petList:addChild(emptyNode)
        emptyNode:setPosition(55+98*(i-1),62)
        table.insert(AdvPetsMgr.emptyNodes, emptyNode)
    end
    local emptyTex = "Searching/bottomBar/pet_empty_2.png"
    CSResourceMgr.setButtonTextureByNode(emptyNode_sample,emptyTex,emptyTex,emptyTex)
    emptyNode_sample:setContentSize(98,108)
    for i = 1, 3 do
        local emptyNode = emptyNode_sample:clone()
        petList:addChild(emptyNode)
        emptyNode:setPosition(320+55+98*(i-1),56)
        table.insert(AdvPetsMgr.emptyNodes, emptyNode)
    end
    
--    local nodeSize = {
--        {w = 96, h = 118},
--        {w = 98, h = 108},
--    }
--    for i = 1, 6 do
--        local emptyNode = emptyNode_sample:clone()
--        petList:addChild(emptyNode)
--        emptyNode:setContentSize(nodeSize[math.ceil(i / 3)].w, nodeSize[math.ceil(i / 3)].h)
--        
--        if i <= 3 then
--            emptyNode:setPosition(55+98*(i-1),62)
--        else
--            local emptyTex = "Searching/bottomBar/pet_empty_2.png"
--            CSResourceMgr.setButtonTextureByNode(emptyNode,emptyTex,emptyTex,emptyTex)
--            emptyNode:setPosition(320+55+98*(i-3-1),56)
--        end
--        
--        local lockTexture = CSResourceMgr.seekNodeByName(emptyNode,"lockTex")
--        lockTexture:setVisible(i > maxPetCount)
--        lockTexture:setPosition(emptyNode:getContentSize().width / 2, emptyNode:getContentSize().height / 2)
--        
--        table.insert(AdvPetsMgr.emptyNodes, emptyNode)
--    end
    
    local function bindPnodeEvent(p)
        --拖拽交换
        local isChange = false
        local px
        local py = 2
        local pxOffset  --the offset between node position and cursor pos

        p:addTouchEventListener(function(sender, state)
            for i=1,#AdvPetsMgr.advArmyPetNodes do
                if AdvPetsMgr.advArmyPetNodes[i] == p then
                    currSelect = i
                end
            end
            for i=1,#AdvPetsMgr.advHelpArmyNodes do
                if AdvPetsMgr.advHelpArmyNodes[i] == p then
                    currSelect = i + 3 
                end
            end
            
            pNodes    = AdvPetsMgr.getPetNodes()
            petObjIDs = AdvPetsMgr.ObjIDs()

            -- 后面的宠只是站着吆呼哦~
            if currSelect > 3 then return end
            
            local hpbar = CSResourceMgr.seekNodeByName(p, "bar")
            if hpbar:getPercent() <= 0 then
                return
            end

            if state == 0 then  --press
                if isChange then   --移動時不響應
                    return 
                end

                isChange = true
                px = p:getPositionX()
                pxOffset = px - p:getTouchBeganPosition().x
            end
            if state == 1 then  --move
                local pos = p:getTouchMovePosition()
                p:setPosition(pos.x + pxOffset,py)
                p:setLocalZOrder(21)
            end
            if state == 2 then  --hold and move [cancel]
                isChange = true
                p:setTouchEnabled(false)
                local tagX
                for i=1, #AdvPetsMgr.emptyNodes do
                    local tmpNode
                    if i <= 3 then
                        tmpNode = AdvPetsMgr.advArmyPetNodes[i]
                    elseif i>= 4 then
                        tmpNode = AdvPetsMgr.advHelpArmyNodes[i-3]
                    end
                
                    if tmpNode and i ~= currSelect then
                        local t = AdvPetsMgr.emptyNodes[i]:getPositionX()-p:getPositionX()
                        if (t>=0 and t<50) or (t<=0 and t>-50) then
                            --cant change army while moving
                            if SearchingMgr.onmove then
                                print("cant change army while moving")
                                break
                            end

                            -- 后面的宠只是站着吆呼哦~
                            if i > 3 then break end
                            
                            local hpbar = CSResourceMgr.seekNodeByName(tmpNode, "bar")
                            if i <= 3 and hpbar:getPercent() <= 0 and currSelect <= 3 then
                                break
                            end
                            if i >= 4 and hpbar:getPercent() <= 0 then
                                break
                            end

                            if currSelect <= 3 and i >= 4 then
                                LtPickPetViewMgr.resizePetNode(AdvPetsMgr.advArmyPetNodes[currSelect],2)
                                LtPickPetViewMgr.resizePetNode(AdvPetsMgr.advHelpArmyNodes[i-3],1)

                                tagX = AdvPetsMgr.advHelpArmyNodes[i-3]:getPositionX()
                                AdvPetsMgr.advHelpArmyNodes[i-3]:setPosition(px,py)
                                AdvPetsMgr.advHelpArmyNodes[i-3],AdvPetsMgr.advArmyPetNodes[currSelect] = p,AdvPetsMgr.advHelpArmyNodes[i-3]
                                AdvPetsMgr.advHelpArmy[i-3],AdvPetsMgr.advArmy[currSelect] = AdvPetsMgr.advArmy[currSelect],AdvPetsMgr.advHelpArmy[i-3]
                            elseif currSelect >= 4 and i <= 3 then
                                LtPickPetViewMgr.resizePetNode(AdvPetsMgr.advHelpArmyNodes[currSelect-3],1)
                                LtPickPetViewMgr.resizePetNode(AdvPetsMgr.advArmyPetNodes[i],2)

                                tagX = AdvPetsMgr.advArmyPetNodes[i]:getPositionX()
                                AdvPetsMgr.advArmyPetNodes[i]:setPosition(px,py)
                                AdvPetsMgr.advArmyPetNodes[i],AdvPetsMgr.advHelpArmyNodes[currSelect-3] = p,AdvPetsMgr.advArmyPetNodes[i]
                                AdvPetsMgr.advArmy[i],AdvPetsMgr.advHelpArmy[currSelect-3] = AdvPetsMgr.advHelpArmy[currSelect-3],AdvPetsMgr.advArmy[i]
                            elseif currSelect <= 3 and i <= 3 then
                                tagX = AdvPetsMgr.advArmyPetNodes[i]:getPositionX()
                                AdvPetsMgr.advArmyPetNodes[i]:setPosition(px,py)
                                AdvPetsMgr.advArmyPetNodes[i],AdvPetsMgr.advArmyPetNodes[currSelect] = p,AdvPetsMgr.advArmyPetNodes[i]
                                AdvPetsMgr.advArmy[i],AdvPetsMgr.advArmy[currSelect] = AdvPetsMgr.advArmy[currSelect],AdvPetsMgr.advArmy[i]
                            elseif currSelect >= 4 and i >= 4 then
                                tagX = AdvPetsMgr.advHelpArmyNodes[i-3]:getPositionX()
                                AdvPetsMgr.advHelpArmyNodes[i-3]:setPosition(px,py)
                                AdvPetsMgr.advHelpArmyNodes[i-3],AdvPetsMgr.advHelpArmyNodes[currSelect-3] = p,AdvPetsMgr.advHelpArmyNodes[i-3]
                                AdvPetsMgr.advHelpArmy[i-3],AdvPetsMgr.advHelpArmy[currSelect-3] = AdvPetsMgr.advHelpArmy[currSelect-3],AdvPetsMgr.advHelpArmy[i-3]
                            end
                            
                            if currSelect >= 4 then
                                AdvPetsMgr.readjustForChangeArmy(currSelect - 3)
                            end
                        end
                    end
                end
                
                
                local dt
                if tagX ~= nil then
                    dt = 0.1 + 0.0002*math.abs(p:getPositionX() - tagX)
                    transition.moveTo(p,{x=tagX,y=py,time=dt})
                else
                    dt = 0.1 + 0.0002*math.abs(p:getPositionX() - px)
                    transition.moveTo(p,{x=px,y=py,time=dt})
                end
                p:performWithDelay(function()
                    isChange = false
                    p:setTouchEnabled(true)
                end,dt)
                p:setLocalZOrder(20)
            end
            if state == 3 then --hold
                p:setTouchEnabled(false)
                local dt = 0.1 + 0.0002*math.abs(p:getPositionX() - px)
                transition.moveTo(p,{x=px,y=py,time=dt})
                p:performWithDelay(function()
                    isChange = false
                    p:setTouchEnabled(true)
                end,dt)
                p:setLocalZOrder(20)
            end
        end)
    end
    
    local BattleFuncMgr = require("src.GameMgr.Battle.BattleFuncMgr")
    
    AdvPetsMgr.advArmyPetNodes = {}
    for k=1, #AdvPetsMgr.advArmy do
        local petInfo = clone( PokemonInfo.getPetInfoByObjID(AdvPetsMgr.advArmy[k]) )
        
        local pSample
        pSample = BattleFuncMgr.startCreatePetCard(petInfo, 1)
        petList:addChild(pSample.button)
        pSample.button:setAnchorPoint(0.5,0.0)
        pSample.button:setPosition(55+98*(k-1),2)
        
        if petInfo.hp <= 0 then
            pSample.button:setColor({r=130,g=130,b=130,a=255})
        else
            pSample.button:setColor({r=255,g=255,b=255,a=255})
        end
        
        local p = pSample.button
        
        bindPnodeEvent(p)
        
        table.insert(AdvPetsMgr.advArmyPetNodes,p)
        p:setLocalZOrder(20)
    end
    
    AdvPetsMgr.advHelpArmyNodes = {}
    for k=1, #AdvPetsMgr.advHelpArmy do
        local petInfo = clone( PokemonInfo.getPetInfoByObjID(AdvPetsMgr.advHelpArmy[k]) )

        local pSample
        pSample = BattleFuncMgr.startCreatePetCard(petInfo, 2)
        petList:addChild(pSample.button)
        pSample.button:setAnchorPoint(0.5,0.0)
        pSample.button:setPosition(320+55+98*(k-1),2)

        if petInfo.hp <= 0 then
            pSample.button:setColor({r=130,g=130,b=130,a=255})
        else
            pSample.button:setColor({r=255,g=255,b=255,a=255})
        end

        local p = pSample.button

        bindPnodeEvent(p)

        table.insert(AdvPetsMgr.advHelpArmyNodes, p)
        p:setLocalZOrder(20)
    end
    
    BattleFuncMgr.endCreatePetCard()
    
    AdvPetsMgr.setPetNodes(pNodes)
    
end

-- TODO  ###################

function SearchingUIMgr.clearMap()
    LtEventOption.removeAllEventAni()
    SearchingUIMgr.removeAllMonsterAni()
end

function SearchingUIMgr.createFloor(floorData)
    
end

function SearchingUIMgr.resetMap()
    SearchingUIMgr.clearMap()

    SearchingMapMgr.setCurrFloorSize(SearchingMapMgr.currAdvInfo, SearchingMapMgr.currFloor)
    SearchingMgr.initMapInfo()

    local scene = SceneMgr.getRunningScene

--    if LtMapOption.getMapSize() > 30 then
        for _, items in pairs(DungeonMapMgr.backgroundItems) do
            for _, item in pairs(items) do
                item:removeFromParent()
            end
        end
        DungeonMapMgr.backgroundItems = {}
        
        for _, items in pairs(DungeonMapMgr.frameItems) do
            for _, item in pairs(items) do
                item:removeFromParent()
            end
        end
        DungeonMapMgr.frameItems = {}
--    end
    
    SearchingUIMgr.tileNodePool.pushAll()
    SearchingUIMgr.eventNodePool.pushAll()

    --中间方格UI
    SearchingUIMgr.setCenterBlock(scene)

    --玩家UI設定
    transition.stopTarget(SearchingMgr.player)
    SearchingUIMgr.initPlayer()

    --迷雾或者事件UI渲染
    SearchingUIMgr.initSlab()
end

---场景虚化效果
function SearchingUIMgr.sceneBlur(parent, zorder)
    print("sceneBlur")
    
    zorder = zorder or 10
    
    local sp
    local fileName
    local function afterCapture(succeed, outputFile)
        if succeed then
            sp = display.newFilteredSprite(outputFile, {"GAUSSIAN_VBLUR", "GAUSSIAN_HBLUR"}, {{3}, {3}})
            parent:addChild(sp)
            sp:setLocalZOrder(zorder)
            sp:setPosition(320, 480)
            sp:setScale(1.0) -- 显示缩放
            fileName = outputFile
        else
            print("capture screen failed!")
        end
    end

    fileName = "screen.png"
    display.captureScreen(afterCapture, fileName)
    
    return sp
    
end

--+++++++++++++++++++++++     动效设计            +++++++++++++++++++++++++++

---星星动效
function SearchingUIMgr.starEffectOnTopbar(starPos,block,callback)

    local fog = CSResourceMgr.getNodeByName(centerResName,"fog")
    local node = CSResourceMgr.createRes(SceneMgr.getRunningScene,"Searching/Node.csb",block)
    local icon = CSResourceMgr.seekNodeByName(node,"stone")
    CSResourceMgr.setButtonTextureByNode(icon,"Searching/topBar/xing2.png","","")
    icon:setContentSize(46,46)
    node:setLocalZOrder(99)
    
    local stardb   = CSResourceMgr.getNodeByName(SearchingUIMgr.topResName,{"db","stars"})
    local star = CSResourceMgr.getNodeByName(SearchingUIMgr.topResName,{"db","stars","star"..starPos})
    local _x,_y = star:getPosition()
    
    local b_node = SearchingUIMgr.getBlockNode(block)
    local b_x,b_y = b_node:getPosition()

    local endP = stardb:convertToWorldSpace(cc.p(_x,_y))  --SearchingUIMgr.getBlockNode(1)
    local startP = fog:getInnerContainer():convertToWorldSpace(cc.p(b_x,b_y))  --SearchingUIMgr.getBlockNode(block)
    local x0,y0 = startP.x, startP.y  --startP:getPosition()
    local x,y = x0+200,y0-150 
    local x2,y2 = endP.x, endP.y  --endP:getPositionX(),endP:getPositionY()+50
    local x1,y1 = x2,y2+20   --x2+20,y2-20 

    node:setPosition(x0,y0)
    
    local distance = cc.pGetDistance(startP, endP)

--    print("~~~~~~~~~~~~~~~~~~~~@",startP.x, startP.y)
--    print("~~~~~~~~~~~~~~~~~~~~@",endP.x, endP.y)
--    print("~~~~~~~~~~~~~~~~~~~~@",distance)

    -- local time = 0.5 + 0.01*(distance / 100)
    
    local time = 0.15 + 0.01*distance/15
    
    local action = cc.BezierTo:create(time,{cc.p(x, y), cc.p(x1, y1), cc.p(x2, y2)})  --贝塞尔曲线运动轨迹
    node:runAction(action)
    node:setGlobalZOrder(CocosModuleMgr.ZORDER_GUIDE)
    node:performWithDelay(function()
        node:fadeOut(0.2*time)
    end,0.8*time)
    node:performWithDelay(function()
        callback()
        CSResourceMgr.removeCSObjectByTag("Searching/Node.csb",block)
    end,time)
    
end

---player enter effect
function SearchingUIMgr.playerEnter(duration,node)
    node = node or SearchingMgr.player
    node:setScale(0.4, 0.4)
    local actionUp = cc.JumpBy:create(duration, cc.p(0,0), 60, 1) 
    node:runAction(actionUp)
    transition.scaleTo(node, {scale = 1, time = duration})
    node:performWithDelay(function()
        SearchingMgr.canMove = true
    end,duration)
end

---Free Fall
--@param node node freeFall作用节点
--@param pos position node原始位置
--@param height int freefall下落高度
function SearchingUIMgr.freeFall(node, height)
    if not SearchingUIMgr.FALL then return end
    
    SearchingUIMgr.FALL = false
    
    local x,y = node:getPosition()
    local hh = height
    local h = y + height
    local dt = 0.005
    local duration = 10 * math.sqrt(hh/5)  -- 10 精度
    
    SearchingMgr.canMove = false
    SearchingMgr.player:setPosition(x, h)
    for i=1,duration do
        SearchingMgr.player:performWithDelay(function()
            local t = 0.1*i
            h = y + height - 0.5*10*t*t
            SearchingMgr.player:setPosition(x, h)
        end,dt*(i-1))
    end
    SearchingMgr.player:performWithDelay(function()
        SearchingMgr.canMove = true
        SearchingMgr.player:setPosition(x, y)
    end,dt*duration)
end

---move
--
function SearchingUIMgr.playerMoveTo(block, movetime)
    local node = SearchingMgr.player
    local tagNode = SearchingUIMgr.getBlockNode(block)
    local px, py = SearchingUIMgr.getBlockNode(SearchingMgr.playerCurrPosition):getPosition()
    local tx, ty = tagNode:getPosition()
    transition.moveBy(SearchingMgr.player, {x=tx-px, y=ty-py, time=movetime})
    SearchingMgr.playerCurrPosition = block
end

---slip
--
function SearchingUIMgr.playerSlipTo(dir)
    
    if PlayerAnimeMgr.getPlayerCurMotionName(DungeonPlayerMgr.getPlayerTag()) ~= "idle" then
        PlayerAnimeMgr.playAni(DungeonPlayerMgr.getPlayerTag(), "idle", true)
    end

    local node = SearchingMgr.player
    local pos = SearchingMgr.playerCurrPosition
    local nextpos = LtMapOption.getNeighbour(pos, dir)
    
    -- check to see if the event type of nextpos is [ smooth floor ]
    local function check()
        if not nextpos then return end
        return true
    end
    
    local function slip()
        print("sliping", nextpos)
        local x, y = LtMapOption.convertToCoord(nextpos)
        
        if not check() then
            return
        end
        
        if not LtMapOption.isReachable(x,y) then
            print("not isReachable:", nextpos)
            return
        end

        DungeonMapMgr.checkScroll(nextpos)
        SearchingUIMgr.playerMoveTo(nextpos,0.25)
    end
    
    slip()
    
end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


return SearchingUIMgr
