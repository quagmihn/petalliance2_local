local AdvCharMgr = {}

--副本训练师数量，默认为1，即玩家自身
AdvCharMgr.trainerNum = 1
local TRAINERS = {}

local _STATE = {
    idle     = 0,
    walk     = 1,
    attack   = 2,
    onAttack = 3,
    wander   = 4,
}

local _TYPE = {
    self    = 1,  -- 己方
    enemy   = 2,  -- 敌方
    neutral = 3,  -- 中立
}

local _ACTION_TYPE = {
    stand = 1,
    move  = 2,
}


local TRAINER_MODE 

local TRAINER_MODE_DEFAULT = 1
local TRAINER_WATCHING = false   --警戒模式[player在视野范围却又障碍时]
local TRAINER_PATROL   = false   --巡逻模式

local PatrolPath = "2-7-12-17-22"
local pathArr = {2,7,12,17,22}
local rePathArr = {22,17,12,7,2}

function AdvCharMgr.Init()
    print("AdvCharMgr.init()")
--    local path = string.split(PatrolPath, "-")
--    local rePath = clone(path)
--    for i=1, math.floor(#rePath/2) do
--        rePath[i],rePath[#rePath+1-i] = rePath[#rePath+1-i],rePath[i]
--    end
end

function AdvCharMgr.addTrainer(char)
    TRAINERS[char.info.pos] = char
--    table.insert(TRAINERS, char)
end

function AdvCharMgr.getTrainers()
    return TRAINERS
end

function AdvCharMgr.getTrainerByTag(tag)
    for _,v in pairs(TRAINERS) do
        if v.info.nodeTag == tag then
            return v
        end
    end
    return nil
end

function AdvCharMgr.getTrainerByPos(pos)
    if not pos then return nil end
    
    return TRAINERS[pos]
end

function AdvCharMgr.clearTrainers()
    for _,v in pairs(TRAINERS) do
        if v.info.handle then
            local scheduler = require("framework.scheduler")
            scheduler.unscheduleGlobal(v.info.handle)
            v.info.handle = nil
        end
        AdvCharMgr.clearTrainerVision(v)
        PlayerAnimeMgr.removePlayerByTag(v.info.aniNode.tag)
        v.info.node:removeFromParent()
    end
    TRAINERS = {}
end

function AdvCharMgr.cleatTranerTable()
    for _,v in pairs(TRAINERS) do
        v = nil
    end
    TRAINERS = {}
end

function AdvCharMgr.resetTrainers()
    -- 训练师删除动画
    PlayerAnimeMgr.removeAllPlayer()
    
    -- 删除定时器
    for _,v in pairs(TRAINERS) do
        if v.info.handle then
            local scheduler = require("framework.scheduler")
            scheduler.unscheduleGlobal(v.info.handle)
            v.info.handle = nil
        end

        if LtMapOption.getMapType() == "LOSTTOWER" then
            AnimationMgr.removeGafObjectByTag(v.info.res, v.info.aniTag)
            --CSResourceMgr.removeCSObjectByTag("Searching/charNode.csb","trainer"..v.info.pos)
        end
        --v.info.node:removeFromParent()
    end
    TRAINERS = {}
end

function AdvCharMgr.removeTrainer(char)
    if not char then return end

    local info = char.info
    local block = info.pos
    AnimationMgr.removeGafObjectByTag(info.res, info.aniTag)
    info.node:removeFromParent(true)
    TRAINERS[info.pos] = nil
    
    SearchingUIMgr.clearBlock(info.pos)
end

function AdvCharMgr.getFlagWithCountry(country)
    country = country or 1
    return "LostTower/PVP_Flags/"..country..".png"
end

function AdvCharMgr.createFlagNode(parent, country, x, y, scale)
    local texture = AdvCharMgr.getFlagWithCountry(country)
    
    local back = display.newSprite("LostTower/PVP_Flags/back.png")
    local sp = display.newSprite(texture)
    sp:addTo(back)
    sp:setPosition(19, 31)
    back:addTo(parent)
    back:setPosition(x, y)
    back:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
    back:setScale(scale)
    back:setAnchorPoint(0.5,0)
    
    return sp
end

-- //  AI 逻辑部分

local function getDistance(node0, node1)
    local x0, y0 = node0:getPosition()
    local x1, y1 = node1:getPosition()
    
    return cc.pGetDistance(cc.p(x0, y0),cc.p(x1, y1))
end

local function getDistanceSQ(node0, node1)
    local x0, y0 = node0:getPosition()
    local x1, y1 = node1:getPosition()
    local x, y = x1-x0, y1-y0

    return x*x + y*y
end

local function getAngle(char, node)
    local x0, y0 = char.info.node:getPosition()
    local x1, y1 = node:getPosition()

    local p1 = cc.p(char.info.direction.c, -char.info.direction.r)
    local p2 = cc.p(x1 - x0, y1 - y0)   -- origin
    
    return 360 * cc.pGetAngle(p1, p2) / (2 * math.pi)
end

-- 检查训练师是否即将步入
function AdvCharMgr.willTrainerStepIn(char, id)
    if id == char.info.pos then return true end
    
    if id == char.info.nextStep and getDistanceSQ(char.info.node, SearchingUIMgr.getBlockNode(char.info.pos)) >= 0 then
        return true
    end
    
    return false
end

function AdvCharMgr.checkCollision(char)
end

---检查trainer视野范围内是否有玩家经过，返回boolean
function AdvCharMgr.checkFront(char, checkPos)
end

local function stopPlayer()
    transition.stopTarget(SearchingMgr.player)
    
    local x, y = SearchingUIMgr.getBlockNode(SearchingMgr.playerCurrPosition):getPosition()
    SearchingMgr.player:setPosition(x, y)
end

local stepTime = 0.5

-- 先刷新所有训练师位置信息
function AdvCharMgr.upadateAll(dt)
    if dt % ( 60 * stepTime) == 0  then
        local tmpTable = {}
        for k, char in pairs(TRAINERS) do
            if char.state == _STATE["wander"] then
                if char.info.nextStep then
                    AdvCharMgr.updateAfterMove(char, char.info.nextStep)
                end
            end
            tmpTable[char.info.pos] = char
        end
        TRAINERS = tmpTable
    end
end

function AdvCharMgr.update(char, dt)
    local state = char.state

    if state == _STATE["idle"] then
    end
    if state == _STATE["walk"] then
    end
    if state == _STATE["attack"] then
        if char.info.nextStep then
            AdvCharMgr.Attack(char)
        end
    end
    if state == _STATE["onAttack"] then
        if char.info.nextStep then
            if getDistanceSQ(SearchingMgr.player, SearchingUIMgr.getBlockNode(char.info.nextStep)) < 400 then
                SearchingMgr.onbattle = true
                
                for k, v in pairs(TRAINERS) do
                    AdvCharMgr.cancelWatching(v)
                end
                AdvCharMgr.enterBattle(char)
            end
        else
            local angle = getAngle(char, SearchingMgr.player)
            if getDistanceSQ(char.info.node, SearchingMgr.player) == 10816 and angle > -45 and angle < 45 then
                char.info.nextStep = SearchingMgr.playerCurrPosition
            end
        end
    end
    if state == _STATE["wander"] then
        
        if char.info.nextStep then
            local angle = getAngle(char, SearchingMgr.player)
            if getDistanceSQ(SearchingMgr.player, SearchingUIMgr.getBlockNode(char.info.nextStep)) < 10816 and angle > -45 and angle < 45 then
                char.state = _STATE["attack"]
            end
        end

        if dt % ( 60 * stepTime) == 0  then
            if char.info.nextStep then
                if not SearchingMgr.onbattle then
                    local zorder = SearchingUIMgr.calcZOrderAt( char.info.pos )
                    char.info.node:setLocalZOrder( zorder )
                    AdvCharMgr.setTrainerVision(char)
                    
                    local col, row = LtMapOption.convertToCoord(char.info.nextStep)
                    
                    if LtMapOption.isReachable(col, row) then
                        local px, py = SearchingUIMgr.getBlockNode(char.info.pos):getPosition()
                        local tx, ty = SearchingUIMgr.getBlockNode(char.info.nextStep):getPosition()
                        
                        AdvCharMgr.turnTo(char, char.info.nextStep)
                        transition.moveBy(char.info.node, {x=tx-px, y=ty-py, time=stepTime})
                    else
                        char.info.nextStep = nil
                    end
                end
            else
                
            end
        end
        
    end
    
end

-- //

local function setSpeed(char, speed)
    char.info.speed = speed
    char.info.stepTime = SearchingUIMgr.BLOCK_WIDTH / speed
end

--- 千层塔显示训练师钥匙掉落
local function showDropKey(char, keyID)
    if not char or not keyID then return end
    
    local parent = char.info.node
    local _itemInfo = ItemInfo.getItemInfoById(keyID) or {}
    local imgPath = _itemInfo.icon or ""
    if not cc.FileUtils:getInstance():isFileExist(imgPath) then return end
    
    local spKey  = display.newSprite(imgPath)
    parent:addChild(spKey)
    spKey:setPosition(104-30,30)
    spKey:setScale(40 / spKey:getContentSize().width)
end

--- 千层塔显示步数掉落
local function showStepNode(char)
    if not char then return end

    local parent = char.info.node
    local imgPath = "UI/CommonFiles/tower_icon_steps_46.png"
    if not cc.FileUtils:getInstance():isFileExist(imgPath) then return end

    local spStepN  = display.newSprite(imgPath)
    parent:addChild(spStepN)
    spStepN:setPosition(104-20,45)
    spStepN:setScale(40 / spStepN:getContentSize().width)
    spStepN:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
end

function AdvCharMgr.create(info,board)
    local char = {}
    
    --添加节点node
    board = board or SearchingUIMgr.getBlockContainer()
    local trainerNode = SearchingUIMgr.getPlayerNode():clone()
    trainerNode:addTo(board)
    trainerNode:setVisible(true)
    trainerNode:setContentSize(SearchingUIMgr.BLOCK_WIDTH, SearchingUIMgr.BLOCK_HEIGHT)
    
    local charNode = trainerNode  --CSResourceMgr.seekNodeByName(trainerNode,"player")
    
    --设置节点位置
    local x, y = SearchingUIMgr.getBlockNode(info.pos):getPosition()
    trainerNode:setPosition(x, y)
    local zorder = SearchingUIMgr.calcZOrderAt( info.pos )  --math.ceil(info.pos/LtMapOption.getMapCols())
    trainerNode:setLocalZOrder( zorder )
    
    --设置train信息
    char.info = clone(info)
    char.info.node = trainerNode
    char.info.nodeTag = "trainer"..info.pos
    char.info.clear = false
    
    char.info.tag        = SearchingMgr.itemTypeTable[char.info.pos].tag  -- original position
    char.info.clear      = SearchingMgr.itemTypeTable[char.info.pos].clear
    char.info.autoAttack = SearchingMgr.itemTypeTable[char.info.pos].autoAttack
    
    --移动相关
    char.info.nextStep = char.info.pos
    AdvCharMgr.Idle(char)
    setSpeed(char, 208)
    
    
    local block = char.info.pos
    if SearchingMgr.mapInfoTable[block] == 2 then
        SearchingMgr.mapInfoTable[block] = 1
        SearchingMgr.monsterDefendInfo[block] = 0
        SearchingUIMgr.activeSlab(block)
    end
    if SearchingMgr.mapInfoTable[block] == 1 then
        SearchingMgr.mistHidAt(block)
    end

    -- 小人方向
    char.info.vision = 2
    char.info.visionAni = {}
    char.info.direction = LtMapOption.DIR_PARAMS[SearchingMgr.itemTypeTable[block].dir]
    
    --trainer动画
    local x, y = char.info.node:getPosition()
    local aniTag = "trainerAni"..info.pos
    if not char.info.aniNode then
        local trainerAni = AnimationMgr.createAni(charNode, char.info.res, 104/2, 816, aniTag)
        trainerAni:setScale(0.9, 0.9)
        --AnimationMgr.setSpeedRate(char.info.res ,1.0, aniTag)    --设置播放速度
        
        AdvCharMgr.setDirection(char, char.info.direction)
        
        char.info.aniNode = trainerAni
        char.info.aniTag = aniTag
    else
        char.info.aniNode:addTo(charNode)
        char.info.aniNode:setPosition(104/2, 24)
        char.info.aniTag = aniTag
        if SearchingMgr.eventStateInfoTable[block] == 3 then  -- 战败态
            PlayerAnimeMgr.playAni(char.info.aniTag,"death",true)
        else
            PlayerAnimeMgr.playAni(char.info.aniTag,"idle",true)
        end
        AdvCharMgr.setDirection(char, char.info.direction)
    end

    --trainer名称显示
    if SearchingMgr.eventInfoTable[block] == LtEventOption.EVENT_OTHERTRAINER then
        CSResourceMgr.seekNodeByName(charNode, "playerName"):setVisible(false)
        local data = SearchingMgr.itemTypeTable[block].data or {}
        
        local nickName = data.nickname or ""
        local tag = nickName..block
        local _node = TownMapMgr.createNameLabel(char.info.node, data.nickname or "", data.Level, data.famailyName, 0, tag)
        _node:setPosition(52, 160)
        
        local x, y = 10, 10
        if data.country then
            -- AdvCharMgr.createFlagNode(char.info.node, data.country + 1, x, y, 1.0)
        end
        
        local fPoint = data.fightPoint
        if fPoint then
            local banner = CSResourceMgr.seekNodeByName(char.info.node,"banner")
            local label  = CSResourceMgr.seekNodeByName(banner,"fPoint")
            CSResourceMgr.setLabelStringByNode(label,fPoint,nil,nil,60)
            banner:setVisible(true)
            banner:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        else
            CSResourceMgr.seekNodeByName(char.info.node,"banner"):setVisible(false)
        end
        
        showStepNode(char)
    else
        local nameLabel = CSResourceMgr.seekNodeByName(charNode, "playerName")
        if not info.name then
            info.name = LuaSqlite.getLanguageByKey(SearchingMgr.itemTypeTable[info.pos].groupCode)
        end
        CSResourceMgr.setLabelStringByNode(nameLabel, info.name)
        nameLabel:setTextColor({r=255,g=255,b=0,a=255})
        nameLabel:enableOutline({r=0,g=0,b=0,a=255},1)
        nameLabel:setLocalZOrder(99)
    end
    
    if LtMapOption.getMapType() == "LOSTTOWER" and SearchingMgr.eventInfoTable[block] == LtEventOption.EVENT_TRAINER then
        local dropID = SearchingMgr.itemTypeTable[block].dropID
        if dropID then
            local dropInfo = LostTowerInfo.getLostTowerDropInfoById(dropID) or {}
            local dropList = dropInfo.dropList or {}
            if dropList[1] then
                local keyID = dropList[1].itemID
                showDropKey(char, keyID)
            end
        end
    end
    
    -- set trainer vision
    if SearchingMgr.eventStateInfoTable[block] == 1  -- 训练师警戒态
    --and SearchingMgr.itemTypeTable[block].autoAttack == 1
    then
        AdvCharMgr.setTrainerVision(char)
    end
    
    --定时器句柄
    char.info.handle = nil
    
    --绑定点击事件
    AdvCharMgr.clickEvent( char )
    
    --if AdvCharMgr.check(char) then AdvCharMgr.battle_(char) end
    --生成时检查[诞生于迷雾]    #set警戒  2015-11-17
    if not SearchingMgr.isFailed
    and SearchingMgr.eventStateInfoTable[block] == 1        -- 未触发
    and SearchingMgr.itemTypeTable[block].autoAttack == 1  -- 主动出击
    then
        if AdvCharMgr.isInFront(char,3) then
            AdvCharMgr.setWatching(char)
        end
        
        local PatrolDirs = SearchingMgr.itemTypeTable[char.info.pos].patrol
        if #PatrolDirs > 0 then
            char.info.patrolPath = PatrolDirs
            AdvCharMgr.Wander(char)
            AdvCharMgr.setWatching(char)
            
            --AdvCharMgr.patrolWithDirs(char, PatrolDirs)
        end
    end

    return char
end

function AdvCharMgr.createNpc(info)
    local char = {}
    local block = info.pos

    --添加节点node
    local board = SearchingUIMgr.getBlockContainer()
    local trainerNode = SearchingUIMgr.getPlayerNode():clone()
    trainerNode:addTo(board)
    trainerNode:setVisible(true)
    trainerNode:setContentSize(SearchingUIMgr.BLOCK_WIDTH, SearchingUIMgr.BLOCK_HEIGHT)

    local charNode = trainerNode  --CSResourceMgr.seekNodeByName(trainerNode,"player")
    
    --设置节点位置
    local x, y = SearchingUIMgr.getBlockNode(info.pos):getPosition()
    trainerNode:setPosition(x, y)
    local zorder = SearchingUIMgr.calcZOrderAt( info.pos )  --math.ceil(info.pos/LtMapOption.getMapCols())
    trainerNode:setLocalZOrder( zorder )

    --设置train信息
    char.info = clone(info)
    char.info.node = trainerNode
    char.info.nodeTag = "trainer"..info.pos
    
    if SearchingMgr.mapInfoTable[block] == 2 then
        SearchingMgr.mapInfoTable[block] = 1
        SearchingMgr.monsterDefendInfo[block] = 0
        SearchingUIMgr.activeSlab(block)
    end
    if SearchingMgr.mapInfoTable[block] == 1 then
        SearchingMgr.mistHidAt(block)
    end

    -- 小人方向
    local _dir = SearchingMgr.itemTypeTable[block].direction or 1
    char.info.direction = LtMapOption.DIR_PARAMS[tonumber(_dir)]

    --trainer动画
    local aniTag = "trainerAni"..block
    local skin = string.split(SearchingMgr.itemTypeTable[block].figure, ",")
    local trainerAni = PlayerAnimeMgr.createPlayer(charNode, {x=104/2, y=24, skin=skin}, aniTag)
    trainerAni:setScale(LtPlayerMgr.PLAYER_SCALE_X, LtPlayerMgr.PLAYER_SCALE_Y)
    char.info.aniNode = trainerAni
    char.info.aniNode:setPosition(104/2, 24)
    char.info.aniTag = aniTag

    AdvCharMgr.Idle(char)
    AdvCharMgr.setDirection(char, char.info.direction)

    --trainer名称显示
    local nameLabel = CSResourceMgr.seekNodeByName(charNode, "playerName")
    if not info.name then
        info.name = LuaSqlite.getLanguageByKey(SearchingMgr.itemTypeTable[info.pos].npcname)
    end
    CSResourceMgr.setLabelStringByNode(nameLabel, info.name)
    nameLabel:setTextColor({r=255,g=255,b=0,a=255})
    nameLabel:enableOutline({r=0,g=0,b=0,a=255},1)
    nameLabel:setLocalZOrder(99)
    
    AdvCharMgr.bindClickEvent(char,function()
        if SearchingMgr.onbattle then  return end
        if not SearchingMgr.canMove then return end

        --移动中，点击取消行动
        if SearchingMgr.onmove and SearchingMgr.canMove then
            if char.info.pos ~= SearchingMgr.destination then
                SearchingMgr.cancelMove = true  --移动取消标志 
                SearchingMgr.cancelAt = char.info.pos
            end
            return
        end
    
        local funcType = tonumber(SearchingMgr.itemTypeTable[block].funcType)
        local func = SearchingFuncMgr.getEventFunc(block, funcType)
        if func then 
            if not SearchingMgr.checkPlayer(char.info.pos) then
                SearchingMgr.moveWithCallback(char.info.pos, function()
                    func(block)
                end)
            else
                func(block)
            end
        end
    end)
    
    -- 任务标记
    AdvCharMgr.updateTaskNpcState(char)

    return char
end

function AdvCharMgr.updateTaskNpcState(char)
    if char.info.floor ~= SearchingMapMgr.currFloor then return end

    local block = char.info.pos
    
    if tonumber(SearchingMgr.itemTypeTable[block].funcType) ~= 1 then return end  -- 限定任务NPC
    
    local mID = tonumber(SearchingMgr.itemTypeTable[block].param1)
    if mID then
        if AdvStarMgr.getRecordByMissionID(mID) then   -- 任务完成
            if not AdvStarMgr.currAdvMissions[mID] then return end
            
            if AdvStarMgr.currAdvMissions[mID] == 0 then  -- 任务未提交
                AdvCharMgr.setEmoji(char,8)
            end
            if AdvStarMgr.currAdvMissions[mID] == 1 then  -- 完成并提交
                AdvCharMgr.clearEmoji(char)
            end
        else
            AdvCharMgr.setEmoji(char,1)
        end
    end
end

function AdvCharMgr.clearTrainerVision(char)
    if char.info.visionAni then
        for k, ani in pairs(char.info.visionAni) do
            if ani.res and ani.tag then
                AnimationMgr.removeGafObjectByTag(ani.res, ani.tag)
            end
        end
        char.info.visionAni = {}
    end
end

function AdvCharMgr.setTrainerVision(char)
    if LtMapOption.getMapType() ~= "ADVENTURE" then return end
    if SearchingMgr.eventInfoTable[char.info.pos] ~= LtEventOption.EVENT_TRAINER then return end
    if SearchingMgr.eventStateInfoTable[char.info.pos] == 3 then return end
    --AdvCharMgr.clearTrainerVision(char) -- clear last

    local block = char.info.pos
    local vision = 2
    local _col, _row = LtMapOption.convertToCoord(block)
    local direction = char.info.direction

    local isDisappear = SearchingMgr.itemTypeTable[block].disappear or 0
    local isAutoAttack = SearchingMgr.itemTypeTable[block].autoAttack or 0
    
    if isAutoAttack ~= 1 then
        vision = 0
    end
    
    local aniRes = "Spine/effects/Ui_qiancengtafuben.png"
    if isDisappear == 1 then
        aniRes = "Spine/effects/Ui_qiancengtafuben_lan.png"
    end
    
    local function setVision(_pos, i)
        local parent = SearchingUIMgr.getBlockContainer()
        local resName = aniRes  -- "Spine/effects/Ui_qiancengtafuben.png"
        local tag = char.info.nodeTag..i
        local charPos = char.info.pos
        local posX, posY = SearchingUIMgr.getBlockNode(charPos):getPosition()
        posX = posX + 104 * i * direction.c
        posY = posY - 104 * i * direction.r

        if AnimationMgr.getGafObj(resName,tag) then
            AnimationMgr.getGafObj(resName,tag):setVisible(true)
            AnimationMgr.getGafObj(resName,tag):setPosition(posX, posY)
            AnimationMgr.getGafObj(resName,tag):setLocalZOrder(math.ceil(_pos/LtMapOption.getMapCols()) * 4 - 3 + 1)
            return
        end

        local effAni = AnimationMgr.createAni(parent, resName, posX, posY, tag)
        AnimationMgr.playAni(effAni.res,"animation",true,effAni.tag)
        effAni:setScale(0.95)

        local zorder = math.ceil(_pos/LtMapOption.getMapCols()) * 4 - 3 + 1
        effAni:setLocalZOrder(zorder)
        
        table.insert(char.info.visionAni, effAni)
    end
    
    -- char.info.visionAni = {}
    setVision(block, 0)
    for i = 1, vision do
        local col, row = _col + i*direction.c, _row + i*direction.r

        if not LtMapOption.isReachable(col,row) then 
            for k = i, vision do
                local _resName = aniRes  -- "Spine/effects/Ui_qiancengtafuben.png"
                local _tag = char.info.nodeTag..k
                if AnimationMgr.getGafObj(_resName,_tag) then
                    AnimationMgr.getGafObj(_resName,_tag):setVisible(false)
                end
            end
            break 
        end
        
        local pos = LtMapOption.convertToIndex(col, row)
        setVision(pos, i)
    end
end

---更新char位置信息
function AdvCharMgr.updateAfterMove(char, to)
    if char.info.pos == to then
        local _dirs = SearchingMgr.itemTypeTable[to].patrol
        char.info.nextStep = LtMapOption.getNeighbour(to, _dirs[1])
        return
    end

    local from = char.info.pos
    char.info.dir = to-char.info.pos
    char.info.pos = to
    
    SearchingMgr.eventInfoTable[to] = SearchingMgr.eventInfoTable[from]
    SearchingMapMgr.sceneID["floor"..SearchingMapMgr.currFloor][to] =     --sceneID将作参传入战斗，需更新
        clone(SearchingMapMgr.sceneID["floor"..SearchingMapMgr.currFloor][from])

    SearchingMgr.eventInfoTable[from] = SearchingMapMgr.EVENT_VOID
    
    local tmpTable = SearchingMgr.itemTypeTable[to]
    SearchingMgr.itemTypeTable[to] = SearchingMgr.itemTypeTable[from]
    SearchingMgr.itemTypeTable[from]  = tmpTable

    -- 更新巡逻路径    
    local _dirs = SearchingMgr.itemTypeTable[to].patrol
    if _dirs and #_dirs > 0 then
        table.insert(_dirs, _dirs[1])
        table.remove(_dirs, 1)
        
        local col, row = LtMapOption.convertToCoord(to)
        local param = LtMapOption.DIR_PARAMS[_dirs[1]]
        char.info.nextStep = LtMapOption.getNeighbour(to, _dirs[1])
    end
    
    return from, to
end

-- ###########################   训练师动画           ####################################

---char转向
function AdvCharMgr.turnTo(char, i)
    local col, row = LtMapOption.convertToCoord(i)
    
    if not LtMapOption.isReachable(col, row) then
        return
    end
    
    local _col, _row = LtMapOption.convertToCoord(char.info.pos)
    
    local direction = {}
    local offset_c = col - _col
    local offset_r = row - _row
    direction.c = (offset_c ~= 0) and offset_c / math.abs(offset_c) or 0
    direction.r = (offset_r ~= 0) and offset_r / math.abs(offset_r) or 0
    
    local curScalex = math.abs(char.info.aniNode:getScaleX())
    local curScaley = math.abs(char.info.aniNode:getScaleY())
    if direction.c >= 0 then
        char.info.aniNode:setScaleX(curScalex)  -- 动画默认为右
    else
        char.info.aniNode:setScaleX(-curScalex)
    end
    
    if direction.c ~= char.info.direction.c or direction.r ~= char.info.direction.r then
        char.info.direction = direction
        AdvCharMgr.setTrainerVision(char)
    end
end

-- 设置小人朝向
function AdvCharMgr.setDirection(char, _dir)

    if _dir.c ~= char.info.direction.c or _dir.r ~= char.info.direction.r then
        char.info.direction = _dir
    end
    
    local direction = _dir
    local curScalex = math.abs(char.info.aniNode:getScaleX())
    local curScaley = math.abs(char.info.aniNode:getScaleY())
    if direction.c >= 0 then
        char.info.aniNode:setScaleX(curScalex)  -- 动画默认为右
    else
        char.info.aniNode:setScaleX(-curScalex)
    end

end

function AdvCharMgr.Idle(char)
    if char.state ~= _STATE.idle then
        PlayerAnimeMgr.playAni(char.info.aniTag,"idle",true)
        char.state = _STATE.idle
    end
end

function AdvCharMgr.Walk(char)
    if PlayerAnimeMgr.getPlayerCurMotionName(char.info.aniTag) ~= "walk" then
        PlayerAnimeMgr.playAni(char.info.aniTag,"walk",true)
    end
    char.state = _STATE.walk
end

function AdvCharMgr.Attack(char)
    transition.stopTarget(char.info.node)
    PlayerAnimeMgr.playAni(char.info.aniTag,"idle",true)
    char.state = _STATE.onAttack
    
    SearchingMgr.onbattle = true
end

function AdvCharMgr.Wander(char)
    PlayerAnimeMgr.playAni(char.info.aniTag,"walk",true)
    char.state = _STATE.wander
end

---方向参数进行行走(one step)
function AdvCharMgr.stepTo(char, dir, movetime)

    -- 1 2 3 4  ---  上下左右
    local col,row = LtMapOption.convertToCoord(char.info.pos)
    local k
    local param = dir
    
    if LtMapOption.isReachable(col+param.c,row+param.r) then
        k = LtMapOption.convertToIndex(col+param.c,row+param.r)
    end
    
    if k ~= nil then
        AdvCharMgr.turnTo(char, k)
        SearchingUIMgr.StepTo(char, k, movetime)
        char.info.node:performWithDelay(function()
            local from, to = AdvCharMgr.updateAfterMove(char, k)
            TRAINERS[from]  = nil
            TRAINERS[to]    = char
        end,movetime)
        
        return true
    end
    
    return false
end

---目标方格参数进行行走
function AdvCharMgr.stepToBlock(char, i, movetime)
    local col, row = LtMapOption.convertToCoord(i)

    if LtMapOption.isReachable(col, row) then
        if i == SearchingMgr.playerCurrPosition then return false end
        
        --設置trainer朝向
        AdvCharMgr.turnTo(char,i)
        AdvCharMgr.stepTo(char, char.info.direction, movetime)
        return true
    end
   
    return false
end

---检查trainer视野范围内是否有玩家经过，返回boolean
function AdvCharMgr.approachTile(char, playerPos)
    local pos = char.info.pos
    if SearchingMgr.mapInfoTable[pos] ~= 0 or SearchingMgr.eventStateInfoTable[pos] ~= 1 then
        return nil
    end
    local col, row = LtMapOption.convertToCoord(pos)
    local direction = char.info.direction
    if not direction or (char.info.vision or 0) < 2 then
        return nil
    end
    if char.info.rejectedPosition then
        if playerPos == char.info.rejectedPosition then return nil end
        char.info.rejectedPosition = nil
    end
    if LtMapOption.convertToIndex(col + 2 * direction.c, row + 2 * direction.r) ~= playerPos then
        return nil
    end
    local nextCol, nextRow = col + direction.c, row + direction.r
    local step = LtMapOption.convertToIndex(nextCol, nextRow)
    if not step or not LtMapOption.isReachable(nextCol, nextRow)
        or SearchingMgr.eventInfoTable[step] ~= LtEventOption.EVENT_VOID or TRAINERS[step] then
        return nil
    end
    return step
end

function AdvCharMgr.check(char, checkPos)
    checkPos = checkPos or SearchingMgr.playerCurrPosition
    if LtMapOption.getMapType() == "ADVENTURE" then
        return not SearchingMgr.onbattle and AdvCharMgr.approachTile(char, checkPos) ~= nil
    end
    if SearchingMgr.eventStateInfoTable[char.info.pos] == 3 then   --挑战完成，不再挑战
        return false
    end
    if SearchingMgr.mapInfoTable[char.info.pos] ~= 0 then  --迷雾未揭开
        return false
    end

    local col,row = LtMapOption.convertToCoord(char.info.pos)
    local direction = char.info.direction
    local p1 = LtMapOption.convertToIndex(col+1*direction.c, row+1*direction.r)
    local p2 = LtMapOption.convertToIndex(col+2*direction.c, row+2*direction.r)
    
    --if p1 and p1 == checkPos then return true end
    if p1 then
        if getDistanceSQ(SearchingUIMgr.getBlockNode(p1),SearchingUIMgr.getBlockNode(checkPos)) < 400 then
            return true
        end
    end
    
    if p2 then
        local col, row = LtMapOption.convertToCoord(p1)
        if LtMapOption.isReachable(col, row) then  --check to see if trainer can walk to player
            if getDistanceSQ(SearchingUIMgr.getBlockNode(p2),SearchingUIMgr.getBlockNode(checkPos)) < 400 then
                return true
            end
            --if p2 == checkPos then
            --    return true
            --end
        end
    end
    
    return false
    
end

---设置训练师气泡表情
function AdvCharMgr.setEmoji(char, emojiID)
    AdvCharMgr.clearEmoji(char)

    emojiID = emojiID or 1

    local smood = CocosModuleMgr.showMood(char.info.node, emojiID, -20, 110, false)
    if smood then
        smood:setScale(0.6, 0.6)
        smood:setLocalZOrder(101)
        char.smood = smood
    end
end

---删除训练师气泡表情
function AdvCharMgr.clearEmoji(char)
    if char.smood then
        char.smood:removeFromParent()
        char.smood = nil
    end
end



function AdvCharMgr.activate(char)
    if LtMapOption.getMapType() ~= "ADVENTURE" then return end
    if SearchingMgr.eventInfoTable[char.info.pos] ~= LtEventOption.EVENT_TRAINER then return end
    if SearchingMgr.eventStateInfoTable[char.info.pos] == 3 then return end

    local block = char.info.pos

    -- set trainer vision
    if SearchingMgr.eventStateInfoTable[block] == 1 then  -- 训练师警戒态
        AdvCharMgr.setTrainerVision(char)
    end

    char.info.handle = nil

    --绑定点击事件
    AdvCharMgr.clickEvent( char )

    if not SearchingMgr.isFailed
        and SearchingMgr.eventStateInfoTable[block] == 1        -- 未触发
        and SearchingMgr.itemTypeTable[block].autoAttack == 1  -- 主动出击
    then
        local PatrolDirs = SearchingMgr.itemTypeTable[char.info.pos].patrol
        if #PatrolDirs > 0 then
            AdvCharMgr.Wander(char)
            AdvCharMgr.setWatching(char)
        end
    end
end

function AdvCharMgr.activateAllTrainer()
    for _, char in pairs(TRAINERS) do
        char.info.nextStep = char.info.pos
        AdvCharMgr.activate(char)
    end
end

function AdvCharMgr.activateTrainersWhileNoBattle(char)
    local isDisappear = SearchingMgr.itemTypeTable[char.info.pos].disappear
    if isDisappear == 1 then
        SceneMgr.getRunningScene():performWithDelay(function()
            AdvCharMgr.activateAllTrainer()
        end,0.5)
    else
        AdvCharMgr.activateAllTrainer()
    end
end

function AdvCharMgr.enterBattle(char)

    AdvCharMgr.setEmoji(char, 1)

    if SearchingMgr.eventInfoTable[char.info.pos] == LtEventOption.EVENT_OTHERTRAINER then  -- 千层塔PVP战斗
        local myPets = {}
        myPets[OUTPETS], myPets[INPETS] = LtPetsMgr.getCurrMyPets()

        local enemyPets = {}
        local enemyAllPets = SearchingMgr.itemTypeTable[char.info.pos].data.pets or {}
        local enemyMainArmy = SearchingMgr.itemTypeTable[char.info.pos].data.activityPokemonIDs or {}
        local enemyHelpAymy = SearchingMgr.itemTypeTable[char.info.pos].data.activityHelperPokemonIDs or {}

        enemyPets[OUTPETS] = {}
        for i = 1, #enemyMainArmy do
            local objID = enemyMainArmy[i]
            table.insert(enemyPets[OUTPETS], enemyAllPets[objID])
        end

        enemyPets[INPETS] = {}
        for i = 1, #enemyHelpAymy do
            local objID = enemyHelpAymy[i]
            table.insert(enemyPets[INPETS], enemyAllPets[objID])
        end
        
        LostTowerUIMgr.removeAllAnimation()
        LtExBufferMgr.setBuffBeforeBattle()
        SearchingMapMgr.battlePos = char.info.pos
        BattleMapMgr.setArenaBattle(myPets,enemyPets,function(detail)
            SearchingMapMgr.battleResult = detail.result
            if detail.result ~= PLAYER_WIN then return end -- 0:失败 1:胜利 2:平局

            detail.me.hp = LtPlayerMgr.recoverFromFashion(detail.me.objID, detail.me.hp)

            local battleDetails = {}
            LtPetsMgr.petsAfterBattle, battleDetails = LtPetsMgr.handleHpAfterBattle(detail.me.objID, detail.me.hp)

            NetInterface.sendWithBlock("GC_LOSTTOWERPVPBATTLEEND_ACK",function()
                local LostTowerSend = require("src.Net.Send.LostTowerSend")
                LostTowerSend.sendCG_LostTowerPVPBattleEnd_Req({
                    isWin = detail.result,
                    battleDetails = battleDetails,
                })
            end,function()
            end,function(code) 
            end)
        end)
        return
    end

    local battleType
    if LtMapOption.getMapType() == "ADVENTURE" then
        battleType = Proto.BTT_ADVENTURE_MONSTER_MAN_GROUP
    elseif LtMapOption.getMapType() == "LOSTTOWER" then
        battleType = Proto.BTT_LOSTTOWER_MONSTER_MAN_GROUP
    end
    local pets = SearchingMgr.itemTypeTable[char.info.pos].pokemons
    local trainerInfo = {
        name = LuaSqlite.getLanguageByKey(SearchingMgr.itemTypeTable[char.info.pos].groupCode),
        pets = SearchingMgr.itemTypeTable[char.info.pos].pokemons,
        seniorFigure = SearchingMgr.itemTypeTable[char.info.pos].seniorFigure,
        sceneID = SearchingMapMgr.sceneID["floor"..SearchingMapMgr.currFloor][char.info.pos],
        type = battleType,
        GroupID = SearchingMgr.itemTypeTable[char.info.pos].id,
        callback = function(detail)
            SearchingMapMgr.battleResult = detail.result
            if detail.result ~= PLAYER_WIN then return end  -- 0:失败 1:胜利 2:平局

            detail.me.hp = LtPlayerMgr.recoverFromFashion(detail.me.objID, detail.me.hp)

            if LtMapOption.getMapType() == "ADVENTURE" then
                -- 更新一次性事件触发记录
                LtEventOption.updateDispEventRecord(char.info.pos)
            elseif LtMapOption.getMapType() == "LOSTTOWER" then
                LtPetsMgr.petsAfterBattle, _ = LtPetsMgr.handleHpAfterBattle(detail.me.objID, detail.me.hp)
            end

            BattleMapMgr.sendGameOver(detail.result,detail.me)
        end,
    }
    if not char.info.clear then
        SearchingMgr.enterBattleAt(char.info.pos,{true, trainerInfo})
    else
        SearchingMgr.battle_win_at(char.info.pos)
        AdvCharMgr.clearTrainerVision(char)
        AdvCharMgr.clearEmoji(char)
        
        AdvCharMgr.activateTrainersWhileNoBattle(char)
    end

end

---trainer與玩家進行戰鬥
function AdvCharMgr.battle_(char)
    if SearchingMgr.onbattle then
        print("duplicate battle")
        return 
    end  --to avoid duplicate battle
    if SearchingMgr.eventStateInfoTable[char.info.pos] == 3 then
        return
    end
    local adventure = LtMapOption.getMapType() == "ADVENTURE"
    local approach
    if adventure and not SearchingMgr.checkPlayer(char.info.pos) then
        approach = AdvCharMgr.approachTile(char, SearchingMgr.playerCurrPosition)
        if not approach then return end
    end
    print("battle!!!")
    SearchingUIMgr.TurnToBlock(char.info.pos)
    SearchingMgr.onbattle = true
    SearchingMgr.canMove = false
    
    AdvCharMgr.Attack(char)
    
    for k, v in pairs(TRAINERS) do
        AdvCharMgr.cancelWatching(v)
    end

    AdvCharMgr.setEmoji(char, 1)

    local currP = 1
    local movetime = 0.5
    
    local ppos = char.info.pos

    local col, row = LtMapOption.convertToCoord(char.info.pos)
    local direction = char.info.direction
    local path = {char.info.pos}
    if adventure then
        if approach then table.insert(path, approach) end
    else
        for i = 1, char.info.vision do
            local p = LtMapOption.convertToIndex(col + i * direction.c, row + i * direction.r)
            if p and p ~= SearchingMgr.playerCurrPosition then
                table.insert(path, p)
            else
                break
            end
        end
        table.insert(path, SearchingMgr.playerCurrPosition)
    end
    
    local function step()
        if currP == #path or SearchingMgr.checkPlayer(path[currP]) then
            --couple worship XXD
            SearchingUIMgr.TurnToBlock(path[currP])
            AdvCharMgr.turnTo(char,SearchingMgr.playerCurrPosition)
            
            --目標方格更新
            local  strtbl = SearchingMapMgr.floorTargetBlocks["floor"..SearchingMapMgr.currFloor][ppos]
            if type(strtbl) == "table" then
                for _, var in pairs(strtbl) do
                    local tbl = clone(var)
                    print(tbl[1]..tbl[2]..tbl[3]..tbl[4])
                    local x, y = tonumber(tbl[2]), tonumber(tbl[3])
                    local block = LtMapOption.convertToIndex(y, x)
                    SearchingFuncMgr.update_blockState(block, tonumber(tbl[4]),tonumber(tbl[1]))
                end
            end

            SearchingMgr.eventStateInfoTable[path[currP]] = 2 --战斗触发
            
            SceneMgr.getRunningScene():performWithDelay(function()
                
                -- 千层塔PVP战斗
                if SearchingMgr.eventInfoTable[char.info.pos] == LtEventOption.EVENT_OTHERTRAINER then
                    local myPets = {}
                    myPets[OUTPETS], myPets[INPETS] = LtPetsMgr.getCurrMyPets()
                    
                    local enemyPets = {}
                    local enemyAllPets = SearchingMgr.itemTypeTable[char.info.pos].data.pets or {}
                    local enemyMainArmy = SearchingMgr.itemTypeTable[char.info.pos].data.activityPokemonIDs or {}
                    local enemyHelpAymy = SearchingMgr.itemTypeTable[char.info.pos].data.activityHelperPokemonIDs or {}
                    
                    enemyPets[OUTPETS] = {}
                    for i = 1, #enemyMainArmy do
                        local objID = enemyMainArmy[i]
                        table.insert(enemyPets[OUTPETS], enemyAllPets[objID])
                    end
                    
                    enemyPets[INPETS] = {}
                    for i = 1, #enemyHelpAymy do
                        local objID = enemyHelpAymy[i]
                        table.insert(enemyPets[INPETS], enemyAllPets[objID])
                    end
                    
                    LostTowerUIMgr.removeAllAnimation()
                    LtExBufferMgr.setBuffBeforeBattle()
                    SearchingMapMgr.battlePos = char.info.pos
                    BattleMapMgr.setArenaBattle(myPets,enemyPets,function(detail)
                        SearchingMapMgr.battleResult = detail.result
                        if detail.result ~= PLAYER_WIN then return end -- 0:失败 1:胜利 2:平局

                        detail.me.hp = LtPlayerMgr.recoverFromFashion(detail.me.objID, detail.me.hp)
                        
                        local battleDetails = {}
                        LtPetsMgr.petsAfterBattle, battleDetails = LtPetsMgr.handleHpAfterBattle(detail.me.objID, detail.me.hp)
                        
                        NetInterface.sendWithBlock("GC_LOSTTOWERPVPBATTLEEND_ACK",function()
                            local LostTowerSend = require("src.Net.Send.LostTowerSend")
                            LostTowerSend.sendCG_LostTowerPVPBattleEnd_Req({
                                isWin = detail.result,
                                battleDetails = battleDetails,
                            })
                        end,function()
                            local _col,_row = LtMapOption.convertToCoord(char.info.pos)
                            NetInterface.sendWithBlock("GC_FIREEVENTCELL_ACK", function()
                                local LostTowerSend = require("src/Net/Send/LostTowerSend.lua")
                                LostTowerSend.sendCG_fireEventCell_Req({ x=_row, y=_col, })
                            end, function()
                            end)
                        end,function(code) 
                        end)
                    end)
                    return
                end
                
                local battleType
                if LtMapOption.getMapType() == "ADVENTURE" then
                    battleType = Proto.BTT_ADVENTURE_MONSTER_MAN_GROUP
                elseif LtMapOption.getMapType() == "LOSTTOWER" then
                    battleType = Proto.BTT_LOSTTOWER_MONSTER_MAN_GROUP
                end
                local pets = SearchingMgr.itemTypeTable[char.info.pos].pokemons
                local trainerInfo = {
                    name = LuaSqlite.getLanguageByKey(SearchingMgr.itemTypeTable[char.info.pos].groupCode),
                    pets = SearchingMgr.itemTypeTable[char.info.pos].pokemons,
                    seniorFigure = SearchingMgr.itemTypeTable[char.info.pos].seniorFigure,
                    sceneID = SearchingMapMgr.sceneID["floor"..SearchingMapMgr.currFloor][char.info.pos],
                    type = battleType,
                    GroupID = SearchingMgr.itemTypeTable[char.info.pos].id,
                    callback = function(detail)
                        SearchingMapMgr.battleResult = detail.result
                        if detail.result ~= PLAYER_WIN then return end  -- 0:失败 1:胜利 2:平局

                        detail.me.hp = LtPlayerMgr.recoverFromFashion(detail.me.objID, detail.me.hp)
                        
                        if LtMapOption.getMapType() == "ADVENTURE" then
                            -- 更新一次性事件触发记录
                            LtEventOption.updateDispEventRecord(char.info.pos)
                        elseif LtMapOption.getMapType() == "LOSTTOWER" then
                            LtPetsMgr.petsAfterBattle, _ = LtPetsMgr.handleHpAfterBattle(detail.me.objID, detail.me.hp)
                        end
                        
                        BattleMapMgr.sendGameOver(detail.result,detail.me)
                    end,
                }
                if not char.info.clear then
                    SearchingMgr.enterBattleAt(char.info.pos,{true, trainerInfo})
                else
                    SearchingMgr.battle_win_at(char.info.pos)
                    AdvCharMgr.clearTrainerVision(char)
                    AdvCharMgr.clearEmoji(char)
                    
                    AdvCharMgr.activateTrainersWhileNoBattle(char)
                end
                
            end, movetime)

            return
        else
            currP = currP + 1
            if not AdvCharMgr.stepToBlock(char, path[currP], movetime) then
                AdvCharMgr.recoverRejectedBattle(char.info.pos)
                return
            end
            char.info.node:performWithDelay(function()
                SearchingMgr.unlock4TrainerMovedOrFailed(path[currP-1])
                SearchingMgr.Lock_monsterAt(path[currP])
                step()
            end,movetime)
        end
    end
    
    step()
    
end

function AdvCharMgr.recoverRejectedBattle(pos)
    SearchingMgr.onbattle = false
    SearchingMgr.onmove = false
    SearchingMgr.canMove = true
    if SearchingMgr.eventStateInfoTable[pos] == 2 then
        SearchingMgr.eventStateInfoTable[pos] = 1
    end
    local char = TRAINERS[pos]
    if char then
        char.info.rejectedPosition = SearchingMgr.playerCurrPosition
        AdvCharMgr.clearEmoji(char)
        AdvCharMgr.Idle(char)
        AdvCharMgr.activateAllTrainer()
    end
end

function AdvCharMgr.clickEvent(char)

    -- 巡逻训练师需要靠近点击
    if char.state == _STATE["wander"] and not SearchingMgr.checkPlayer(char.info.pos) then
        return
    end
    
    -- 初始点击函数
    if SearchingMgr.itemTypeTable[char.info.pos].eventFunc then
        CSResourceMgr.clickEventBindingByNode(char.info.node, function(sender, state)
            if not SearchingMgr.itemTypeTable[char.info.pos].eventFunc then return end
            
            if SearchingMgr.checkPlayer(char.info.pos) then
                SearchingMgr.itemTypeTable[char.info.pos].eventFunc()
                SearchingMgr.itemTypeTable[char.info.pos].eventFunc = nil
                return
            else
                SearchingMgr.moveWithCallback(char.info.pos, function()
                    SearchingMgr.itemTypeTable[char.info.pos].eventFunc()
                    SearchingMgr.itemTypeTable[char.info.pos].eventFunc = nil
                end)
            end
        end)
        return
    end

    local function battle_with_trainer(char)
        if LtMapOption.getMapType() == "LOSTTOWER" then
            if not LostTowerMgr.haveAlivePets() then  -- 没有活着的宠无法进战斗
                return
            end 

            if not LostTowerMgr.hasEnoughSteps(LostTowerMgr.currentFloor) then
                StandardTipsMgr.show(1, "LtTips24")   -- "步数不够"
                return
            end
        end
    
        AdvCharMgr.cancelWatching(char)
        AdvCharMgr.turnTo(char,SearchingMgr.playerCurrPosition)
        AdvCharMgr.battle_(char)
    end

    CSResourceMgr.clickEventBindingByNode(char.info.node, function(sender, state)
        if SearchingMgr.onbattle then  return end
        if not SearchingMgr.canMove then return end

        --移动中，点击取消行动
        if SearchingMgr.onmove and SearchingMgr.canMove then
            if char.info.pos ~= SearchingMgr.destination then
                SearchingMgr.cancelMove = true  --移动取消标志 
                SearchingMgr.cancelAt = char.info.pos
            end
            return
        end

        if SearchingMgr.eventStateInfoTable[char.info.pos] == 3 and not SearchingMgr.onbattle then
            return
        end
        
        if SearchingMgr.checkPlayer(char.info.pos) then  --玩家在训练师旁边主动挑战
            battle_with_trainer(char)
            return
        else
            if char.state == _STATE["wander"] then  -- 巡逻训练师不前往
                return
            end
        
            SearchingMgr.moveWithCallback(char.info.pos, function()
                battle_with_trainer(char)
            end)
        end
    end)
end

function AdvCharMgr.bindClickEvent(char, callback)
    CSResourceMgr.clickEventBindingByNode(char.info.node, function(sender, state)
        if callback then callback() end
    end)
end

---副本引导中战斗调用，训练师
function AdvCharMgr.tutorialBattle(char, _callback)
    if SearchingMgr.onbattle then return end
    if SearchingMgr.eventStateInfoTable[char.info.pos] == 3 then
        return
    end
    
    SearchingMgr.onbattle = true
    SearchingMgr.canMove = false
    
    AdvCharMgr.setEmoji(char, 1)
    SearchingUIMgr.TurnToBlock(char.info.pos)
    
    SearchingMgr.eventStateInfoTable[char.info.pos] = 2
    
    local battleType = Proto.BTT_ADVENTURE_MONSTER_MAN_GROUP
    local pets = SearchingMgr.itemTypeTable[char.info.pos].pokemons
    local trainerInfo = {
        name = LuaSqlite.getLanguageByKey(SearchingMgr.itemTypeTable[char.info.pos].groupCode),
        pets = SearchingMgr.itemTypeTable[char.info.pos].pokemons,
        seniorFigure = SearchingMgr.itemTypeTable[char.info.pos].seniorFigure,
        sceneID = SearchingMapMgr.sceneID["floor"..SearchingMapMgr.currFloor][char.info.pos],
        type = battleType,
        GroupID = SearchingMgr.itemTypeTable[char.info.pos].id,
        callback = function(detail)
            SearchingMapMgr.battleResult = detail.result
            if detail.result ~= PLAYER_WIN then return end  -- 0:失败 1:胜利 2:平局
            
            detail.me.hp = LtPlayerMgr.recoverFromFashion(detail.me.objID, detail.me.hp)

            BattleMapMgr.sendGameOver(detail.result,detail.me)
            
            if _callback then _callback() end
        end,
    }
    SearchingMgr.enterBattleAt(char.info.pos,{true, trainerInfo})
end

---检查是否战斗    (暂时为引导中使用)
function AdvCharMgr.checkIfBattle()
    for _,var in pairs( TRAINERS ) do
        if var.info.floor == SearchingMapMgr.currFloor then
            if SearchingMgr.itemTypeTable[var.info.pos].autoAttack == 1 then  --主动出击
                if SearchingMgr.eventStateInfoTable[var.info.pos] == 1 then  --未触发状态
                    if AdvCharMgr.check(var) then
                        AdvCharMgr.cancelWatching(var)  --cancel watching to avoid duplicate battle
                        SearchingUIMgr.TurnToBlock(var.info.pos)
                        print("AdvCharMgr.checkIfBattle()")
                        AdvCharMgr.battle_(var)
                        return
                    end
                end
            end
        end
    end
end

---check to see if player in front of trainer [ ignore all obstractions ]
--@param char table char 
--@param vision int trainer_s_visual_field 
--@param isIgnoreOB boolean ignore_obstruction_flag
function AdvCharMgr.isInFront(char, vision, isIgnoreOB)
    vision = vision or LtMapOption.getMapRows()
    isIgnoreOB = isIgnoreOB or true
    local col, row = LtMapOption.convertToCoord(char.info.pos)
    local direction = char.info.direction
    local p = {}
    
    for i=1, vision do
        local p1 = LtMapOption.convertToIndex(col+i*direction.c, row+i*direction.r)
        if p1 then 
            if p1 == SearchingMgr.playerCurrPosition then return true end
        else
            break
        end
    end
    
    return false
    
end

---訓練師呈攻擊趨勢，watching
function AdvCharMgr.setWatching(char)
    if SearchingMgr.onbattle then return end
    if char.info.handle ~= nil then return end
    local scheduler = require("framework.scheduler")
    
    TRAINER_WATCHING = true
    
    local function watching()
        if SceneMgr.currentScene ~= "SearchingScene" then  -- 不在关卡中不执行训练师监听
            if char.info.handle then
                local scheduler = require("framework.scheduler")
                scheduler.unscheduleGlobal(char.info.handle)
                char.info.handle = nil
            end
            return
        end
    
        if SearchingMgr.isFloorChanged() or SearchingMgr.isAdventureEnd() then
            AdvCharMgr.cancelWatching(char)
        end
--        if not SearchingMgr.canMove then return end  --to avoid duplicate checking
        if AdvCharMgr.check(char) then
            print("watching func")

            local x, y = SearchingUIMgr.getBlockNode(SearchingMgr.playerCurrPosition):getPosition()
            SearchingMgr.player:setPosition(x, y)
            transition.stopTarget(SearchingMgr.player)
            PlayerAnimeMgr.playAni(DungeonPlayerMgr.getPlayerTag(), "idle", true)
            
            for k, v in pairs(TRAINERS) do
                AdvCharMgr.cancelWatching(v)
            end
            
            AdvCharMgr.battle_(char)
        end
    end

    --AI监听器
    char.info.handle = scheduler.scheduleGlobal(watching, 0.01)    --指定时间间隔内调用
end 

---訓練師取消警戒
function AdvCharMgr.cancelWatching(char)
    if char.info.handle then
        local scheduler = require("framework.scheduler")
        scheduler.unscheduleGlobal(char.info.handle)
        char.info.handle = nil
        
        transition.stopTarget(char.info.node)
        AdvCharMgr.Idle(char)
        
        local x, y = SearchingUIMgr.getBlockNode(char.info.pos):getPosition()
        char.info.node:setPosition(x, y)
        local zorder = SearchingUIMgr.calcZOrderAt( char.info.pos )
        char.info.node:setLocalZOrder( zorder )
        
        AdvCharMgr.clearTrainerVision(char)
    end
end

return AdvCharMgr
