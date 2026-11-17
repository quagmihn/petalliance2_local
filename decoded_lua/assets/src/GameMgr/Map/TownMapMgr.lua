local TownMapMgr = {}

----地图的宽度必须大于等于960

TownMapMgr.DEFAULT_TMAP_WIDTH = 640             --地图默认宽度
TownMapMgr.DEFAULT_TMAP_HEIGHT = 960            --地图默认高度
TownMapMgr.DEFAULT_TMAP_POSY_DIFF = 0           --地图y轴偏移量
TownMapMgr.DEFAULT_DELIVERY_DISTANCE = 100      --地图两端触发传送默认距离
TownMapMgr.DEFAULT_BUTTON_DISTANCE = 100        --地图中靠近时才能点击的按钮的生效距离
TownMapMgr.DEFAULT_PET_DISTANCE = 120           --宠物距离主人的距离
TownMapMgr.DEFAULT_KEEPMOVING_DISTANCE = 50     --手指拖动移动时手指距离人物小于此长度则移动不响应
TownMapMgr.DEFAULT_PETSPEED_DIFF = 50           --宠物移动速度加成(相对于人物)

TownMapMgr.DEFAULT_CHARACTOR_POSY = 0           --主角纵坐标(楼下赋值)
TownMapMgr.DEFAULT_PET_SCALE = 0.5              --城镇宠物缩放大小

TownMapMgr.DEFAULT_NAMELABEL_POSX = 0           --人物名牌横坐标
TownMapMgr.DEFAULT_PET_NAMELABEL_POSX = 0       --宠物名牌横坐标
TownMapMgr.DEFAULT_NAMELABEL_POSY = 180         --人物名牌纵坐标
TownMapMgr.DEFAULT_PET_NAMELABEL_POSY1 = 150/TownMapMgr.DEFAULT_PET_SCALE     --宠物名牌纵坐标1
TownMapMgr.DEFAULT_PET_NAMELABEL_POSY2 = 200/TownMapMgr.DEFAULT_PET_SCALE     --宠物名牌纵坐标2

TownMapMgr.move_speed = 0               --玩家移动速度
TownMapMgr.Player = nil                 --玩家node
TownMapMgr.PlayerNameLabel = nil        --玩家名字node
TownMapMgr.Pet = nil                    --宠物node
TownMapMgr.Map = nil                    --地图node
TownMapMgr.MapRes = ""                  --地图资源文件
TownMapMgr.MapFront = nil               --地图node
TownMapMgr.MapFrontRes = ""             --地图资源文件
TownMapMgr.MapBack = nil                --地图node
TownMapMgr.MapBackRes = ""              --地图资源文件
TownMapMgr.MapInitPos = 0               --地图载入位置
TownMapMgr.ButtonTable = {}             --地图按钮列表
TownMapMgr.ObstacleTable = {}           --地图障碍物列表
TownMapMgr.RecordsTable = {}            --地图行走记录表（用于返回地图时从上次离开的位置载入）
TownMapMgr.TouchListener = nil          --地图点击监听回调
TownMapMgr.TouchEvent = nil             --地图点击事件参数记录（用于连续点击）
TownMapMgr.TouchEventState = 0          --地图点击事件状态（用于连续点击）
TownMapMgr.TmpClickEventCallback = nil  --地图临时点击事件回调（用于第一类按钮点击）
TownMapMgr.PlayerTransferPosy = nil     --玩家在地图上的y坐标

TownMapMgr.charTagStr = ""
TownMapMgr.charPetTagStr = ""

local nameLabelRes = ""
local charTagStr = ""
local charPetTagStr = ""
local curMapWidth = 0
local mapMoveInfo = {}
local enableHomeSync = true
local lastPlayerPosX = 0
local snapshotPlayerX = 0
local snapshotMapX = 0
--local petNameLabel = nil           --宠物名字node

---重新初始化TownMapMgr，用于动态lua调试
function TownMapMgr.Init()
    print("TownMapMgr初始化")
    TownMapMgr.move_speed = 500
    TownMapMgr.Player = nil
    TownMapMgr.PlayerNameLabel = nil
    TownMapMgr.Pet = nil
    TownMapMgr.Map = nil
    TownMapMgr.MapRes = ""
    TownMapMgr.MapInitPos = 0
    TownMapMgr.ButtonTable = {}
    TownMapMgr.ObstacleTable = {}
    TownMapMgr.RecordsTable = {}
    TownMapMgr.TouchListener = nil
    TownMapMgr.TouchEvent = nil
    TownMapMgr.TouchEventState = 0
    TownMapMgr.TmpClickEventCallback = nil
    
    nameLabelRes = "Charactor/NameLabel.csb"
    charTagStr = PlayerAnimeMgr.SELF_TAG_STRING
    charPetTagStr = PlayerAnimeMgr.SELF_TAG_STRING.."-pet"
    curMapWidth = 0
    mapMoveInfo = {isSending = false, serverPos = 0, clientPos = 0}
    enableHomeSync = true
    lastPlayerPosX = 0
    --petNameLabel = nil
    
    TownMapMgr.charTagStr = charTagStr
    TownMapMgr.charPetTagStr = charPetTagStr
    
    local size = cc.Director:getInstance():getOpenGLView():getViewPortRect()
    local rate = size.width/(size.height/CONFIG_SCREEN_HEIGHT*CONFIG_SCREEN_WIDTH)
    TownMapMgr.DEFAULT_TMAP_WIDTH = math.floor(CONFIG_SCREEN_WIDTH*rate)
    
    snapshotPlayerX = 0
    snapshotMapX = 0
end

---设置主角缩放比例
--@param scale float 缩放比例
function TownMapMgr.setPlayerScale(scale)
    --print("=============setPlayerScale="..tostring(scale))
    PlayerAnimeMgr.setPlayerAniScale(charTagStr, scale)
end

---设置宠物缩放比例
--@param scale float 缩放比例
function TownMapMgr.setPetScale(scale)
    --print("=============setPetScale="..tostring(scale))
    TownMapMgr.DEFAULT_PET_SCALE = scale
end

---添加地图、主角
--如果地图分近景远景，mapRes填写近景的csb，远景为mapRes后缀_back的csb，前景为mapRes后缀_front的csb
--远景的图片宽度必须大于等于近景宽度的3/4
--@param scene node 地图的父节点
--@param mapRes string 地图资源csb文件
--@param LeftDeliveryPointCallback function 左传送点的回调函数
--@param RightDeliveryPointCallback function 右传送点的回调函数
--@param ClickEventCallback function 点击地图的回调函数（在人物移动完成后才执行）
function TownMapMgr.createWithRes(scene, mapRes, LeftDeliveryPointCallback, RightDeliveryPointCallback, ClickEventCallback)
    if TownMapMgr.RecordsTable[mapRes]==nil then
    	TownMapMgr.RecordsTable[mapRes] = {}
    end
    local type = SceneMgr.mapEnterType
    print("载入地图"..mapRes..", 入场模式"..type)
    if type == 99 then
    	print("从上次离开地图的位置载入地图")
        if TownMapMgr.RecordsTable[mapRes].haveMoved==false then
            type = TownMapMgr.RecordsTable[mapRes].lastEnterType
            print("上次离开地图时未点击操作移动人物，按上次载入类型载入地图")
        elseif TownMapMgr.RecordsTable[mapRes].haveMoved==nil then
            type = 1
            print("错误：地图首次载入的类型为99，从左端载入地图")
    	end
    end
    
    NpcMgr.clear()
    TownPlayerMgr.clear()
    
    TownMapMgr.ButtonTable = {}
    TownMapMgr.ObstacleTable = {}
    TownMapMgr.TouchListener = nil
    TownMapMgr.TouchEvent = nil
    TownMapMgr.TouchEventState = 0
    TownMapMgr.TmpClickEventCallback = nil
    
    TownChatMgr.addUI(scene)
    TownChatMgr.changeStatus(1)
    
    local mapRes_vec = lua_string_split(mapRes, "/")
    local map_name = string.gsub(mapRes_vec[table.getn(mapRes_vec)], ".csb", "")
    local map_name_plus = map_name.."_back"
    local map_name_front = map_name.."_front"
    local resStrPlus = string.gsub(mapRes, ".csb", "_back.csb")
    local Forest_plus = CSResourceMgr.createRes(scene, resStrPlus)
    local Forest = CSResourceMgr.createRes(scene, mapRes)
    local resStrFront = string.gsub(mapRes, ".csb", "_front.csb")
    local Forest_front = CSResourceMgr.createRes(scene, resStrFront)
    if Forest_plus then
        CocosModuleMgr.setRelativePosition(Forest_plus:getChildByName(map_name_plus), 320, 700)
    end
    if Forest then
        local tmpPy = Forest:getChildByName(map_name):getPositionY()
        CocosModuleMgr.setRelativePosition(Forest:getChildByName(map_name), 320, 700)
        TownMapMgr.DEFAULT_TMAP_POSY_DIFF = Forest:getChildByName(map_name):getPositionY()-tmpPy
        if SceneMgr.currentScene ~= "HomeScene" then 
            TownMapMgr.DEFAULT_CHARACTOR_POSY = 90+TownMapMgr.DEFAULT_TMAP_POSY_DIFF
            local screenSizeDiff = CocosModuleMgr.getScreenSizeDiff()
            if screenSizeDiff<0 then
                TownMapMgr.DEFAULT_CHARACTOR_POSY = TownMapMgr.DEFAULT_CHARACTOR_POSY + screenSizeDiff*0.5
            end
        else
            TownMapMgr.DEFAULT_CHARACTOR_POSY = 20+TownMapMgr.DEFAULT_TMAP_POSY_DIFF
            local screenSizeDiff = CocosModuleMgr.getScreenSizeDiff()
            if screenSizeDiff<0 then
                TownMapMgr.DEFAULT_CHARACTOR_POSY = TownMapMgr.DEFAULT_CHARACTOR_POSY + screenSizeDiff*0.7
            end
        end
    end
    if Forest_front then
        CocosModuleMgr.setRelativePosition(Forest_front:getChildByName(map_name_front), 320, 700)
    end
    CSResourceMgr.playAllFrame(mapRes, true)
    CSResourceMgr.playAllFrame(string.gsub(mapRes, ".csb", "_back.csb"), true)
    CSResourceMgr.playAllFrame(string.gsub(mapRes, ".csb", "_front.csb"), true)
    local fpetid, fpetskin = PokemonInfo.getFollowPokemonID()
    TownMapMgr.Pet = AnimationMgr.createAni(Forest, PokemonInfo.getPokemonResByID(fpetid), 
        TownMapMgr.DEFAULT_TMAP_WIDTH/2-TownMapMgr.DEFAULT_PET_DISTANCE, TownMapMgr.DEFAULT_CHARACTOR_POSY, charPetTagStr)
    TownMapMgr.Player = PlayerAnimeMgr.createPlayer(scene, {gender=CharInfo.getSex(), 
        x=TownMapMgr.DEFAULT_TMAP_WIDTH/2, y=TownMapMgr.DEFAULT_CHARACTOR_POSY, skin=CharInfo.getCurfashion()}, charTagStr)
    TownMapMgr.Pet:setLocalZOrder(2)
    TownMapMgr.Pet:setScale(TownMapMgr.DEFAULT_PET_SCALE, TownMapMgr.DEFAULT_PET_SCALE)
    TownMapMgr.Player:setLocalZOrder(CocosModuleMgr.ZORDER_PLAYER)
    TownMapMgr.Player:setScale(1, 1)
    AnimationMgr.setSkin(TownMapMgr.Pet.res, fpetskin, TownMapMgr.Pet.tag)
    --[[
    petNameLabel = CSResourceMgr.createRes(TownMapMgr.Pet, nameLabelRes, petName)
    CSResourceMgr.setLabelString(nameLabelRes, "name", petName.." ", petName, CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
    local petnamelabel_y = TownMapMgr.DEFAULT_PET_NAMELABEL_POSY1
    if PokemonInfo.getPokemonFigure(petID)==1 then
        petnamelabel_y = TownMapMgr.DEFAULT_PET_NAMELABEL_POSY2
    end
    petNameLabel:setPosition(TownMapMgr.DEFAULT_PET_NAMELABEL_POSX, petnamelabel_y)
    petNameLabel:setScale(1/TownMapMgr.DEFAULT_PET_SCALE, 1/TownMapMgr.DEFAULT_PET_SCALE)
    petNameLabel:setAnchorPoint(0.5, 0.5)
    ]]--
    local myFamilyInfo = FamilyInfo.GetLocalFamilyInfo() or {}
    TownMapMgr.PlayerNameLabel = TownMapMgr.createNameLabel(TownMapMgr.Player, CharInfo.getNickName(), CharInfo.getLevel(), 
        myFamilyInfo.name, TerritorialInfo.getMyStageID())
    TownMapMgr.refreshNameLabel(nil, nil, nil, CharInfo.getArenaRank())
    
    TownMapMgr.Map = Forest
    TownMapMgr.MapRes = mapRes
    TownMapMgr.MapFront = Forest_front
    TownMapMgr.MapFrontRes = resStrFront
    TownMapMgr.MapBack = Forest_plus
    TownMapMgr.MapBackRes = resStrPlus
    local size = Forest:getChildByName(map_name):getContentSize()
    local size_ratex = Forest:getChildByName(map_name):getScaleX()
    local size_ratey = Forest:getChildByName(map_name):getScaleY()
    local map_sizex = size.width*size_ratex
    local map_sizey = size.height*size_ratey
    local initPos = TownMapMgr.DEFAULT_TMAP_WIDTH/2
    local size_plus,size_ratex_plus,size_ratey_plus,map_sizex_plus,map_sizey_plus,initPos_plus
    if Forest_plus~=nil then
        size_plus = Forest_plus:getChildByName(map_name_plus):getContentSize()
        size_ratex_plus = Forest_plus:getChildByName(map_name_plus):getScaleX()
        size_ratey_plus = Forest_plus:getChildByName(map_name_plus):getScaleY()
        map_sizex_plus = size_plus.width*size_ratex_plus
        map_sizey_plus = size_plus.height*size_ratey_plus
        initPos_plus = TownMapMgr.DEFAULT_TMAP_WIDTH/2
    end
    if type == 1 then
    	initPos = map_sizex/2
        if Forest_plus~=nil then
            initPos_plus = map_sizex_plus/2
        end
    elseif type == 2 then
        initPos = TownMapMgr.DEFAULT_TMAP_WIDTH - map_sizex/2
        if Forest_plus~=nil then
            initPos_plus = TownMapMgr.DEFAULT_TMAP_WIDTH - map_sizex_plus/2
        end
        TownMapMgr.Player:setScale(-1, 1)
        TownMapMgr.PlayerNameLabel:setScale(-1, 1)
        TownMapMgr.Pet:setScale(-TownMapMgr.DEFAULT_PET_SCALE, TownMapMgr.DEFAULT_PET_SCALE)
        --petNameLabel:setScale(-1/TownMapMgr.DEFAULT_PET_SCALE, 1/TownMapMgr.DEFAULT_PET_SCALE)
        TownMapMgr.Pet:setPosition(TownMapMgr.DEFAULT_TMAP_WIDTH/2+TownMapMgr.DEFAULT_PET_DISTANCE, TownMapMgr.Pet:getPositionY())
    elseif type == 3 then
        initPos = TownMapMgr.DEFAULT_TMAP_WIDTH/2
        if Forest_plus~=nil then
            initPos_plus = TownMapMgr.DEFAULT_TMAP_WIDTH/2
        end
    else
        initPos = TownMapMgr.RecordsTable[mapRes].initPos
        if Forest_plus~=nil then
            initPos_plus = TownMapMgr.RecordsTable[mapRes].initPos_plus
        end
        TownMapMgr.Player:setPosition(TownMapMgr.RecordsTable[mapRes].playerPos, TownMapMgr.Player:getPositionY())
        TownMapMgr.Pet:setPosition(TownMapMgr.RecordsTable[mapRes].petPos, TownMapMgr.Pet:getPositionY())
        TownMapMgr.Player:setScale(TownMapMgr.RecordsTable[mapRes].playerScaleX, 1)
        TownMapMgr.PlayerNameLabel:setScale(TownMapMgr.RecordsTable[mapRes].playerScaleX, 1)
        TownMapMgr.Pet:setScale(TownMapMgr.RecordsTable[mapRes].petScaleX, TownMapMgr.DEFAULT_PET_SCALE)
        --petNameLabel:setScale(1/TownMapMgr.RecordsTable[mapRes].petScaleX, 1/TownMapMgr.DEFAULT_PET_SCALE)
    end

    --测试
    PlayerAnimeMgr.showWorldPKEffect(TownMapMgr.Player,CharInfo.getVIPLevel(),PlayerAnimeMgr.SELF_TAG_STRING)
    --------

    TownMapMgr.MapInitPos = initPos
    curMapWidth = map_sizex
    CocosModuleMgr.setEdgeDistance(Forest:getChildByName(map_name), nil, nil, 0, nil)
    Forest:getChildByName(map_name):setPosition(initPos,Forest:getChildByName(map_name):getPositionY())
    local map_posx = Forest:getChildByName(map_name):getPositionX()
    if Forest_plus~=nil then
        CocosModuleMgr.setEdgeDistance(Forest_plus:getChildByName(map_name_plus), nil, nil, 0, nil)
        Forest_plus:getChildByName(map_name_plus):setPosition(initPos_plus,Forest_plus:getChildByName(map_name_plus):getPositionY())
    end
    if Forest_front~=nil then
        CocosModuleMgr.setEdgeDistance(Forest_front:getChildByName(map_name_front), nil, nil, 0, nil)
        Forest_front:getChildByName(map_name_front):setPosition(initPos,Forest_front:getChildByName(map_name_front):getPositionY())
        Forest_front:setLocalZOrder(CocosModuleMgr.ZORDER_MAP_FRONT)
    end
    
    if TownMapMgr.RecordsTable[mapRes].haveMoved==nil then
        TownMapMgr.RecordsTable[mapRes].haveMoved=false
    end
    if type~=99 then
        TownMapMgr.RecordsTable[mapRes].lastEnterType=type
    end
    
    --添加地图箭头
    local mapArrowRes = "Spine/effects/maparrow.png"
    local mapArrowPosy = TownMapMgr.DEFAULT_CHARACTOR_POSY-Forest:getChildByName(map_name):getPositionY()+map_sizey/2
    --print(TownMapMgr.DEFAULT_CHARACTOR_POSY, Forest:getChildByName(map_name):getPositionY(), map_sizey/2)
    TownMapMgr.PlayerTransferPosy = mapArrowPosy
    if LeftDeliveryPointCallback then
        local arrowAniLeft = AnimationMgr.createAni(Forest:getChildByName(map_name), mapArrowRes, 0, mapArrowPosy, "left")
        AnimationMgr.playAni(arrowAniLeft.res, "idle", true, arrowAniLeft.tag)
        arrowAniLeft:setScaleX(-1)
    end
    if RightDeliveryPointCallback then
        local arrowAniRight = AnimationMgr.createAni(Forest:getChildByName(map_name), mapArrowRes, map_sizex, mapArrowPosy, "right")
        AnimationMgr.playAni(arrowAniRight.res, "idle", true, arrowAniRight.tag)
    end
    
    local isMoving = false
    PlayerAnimeMgr.playAni(charTagStr, "idle", true)
    AnimationMgr.playAni(TownMapMgr.Pet.res, "idle", true, charPetTagStr)
    local playerAction = nil
    local playerHandlerX = nil
    local mapAction = nil
    local mapHandlerX = nil
    local mapAction_plus = nil
    local mapPlusHandlerX = nil
    local mapAction_front = nil
    local mapFrontHandlerX = nil
    local touchLayer = display.newLayer():addTo(scene)
    touchLayer:setLocalZOrder(CocosModuleMgr.ZORDER_MOVETOUCH)
    touchLayer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    
    local function removeAction(sender)
        if sender then
            transition.removeAction(sender)
        end
    end
    
    local function touchListener(event)
        -- event.phase 的值是：
        -- cc.NODE_TOUCH_TARGETING_PHASE

        -- event.mode 的值是下列之一：
        -- cc.TOUCH_MODE_ONE_BY_ONE 单点触摸
        -- cc.TOUCH_MODE_ALL_AT_ONCE 多点触摸

        -- event.name 的值是下列之一：
        -- began 触摸开始
        -- moved 触摸点移动
        -- ended 触摸结束
        -- cancelled 触摸被取消

        -- 如果是单点触摸：
        -- event.x, event.y 是触摸点位置
        -- event.prevX, event.prevY 是触摸点之前的位置

        -- 如果是多点触摸：
        -- event.points 包含了所有触摸点的信息
        -- event.points = {point, point, ...}
        -- 每一个触摸点的值包含：
        -- point.x, point.y 触摸点的当前位置
        -- point.prevX, point.prevY 触摸点之前的位置
        -- point.id 触摸点 id，用于确定触摸点的变化
        if event.name == "ended" then
            TownMapMgr.TouchEventState = 0
            return true
        end
        if event.name == "cancelled" then
            TownMapMgr.TouchEventState = 0
            return true
        end
        if event.name == "began" or event.name == "moved" then
            --print("touch:"..event.x .."-".. event.y)
            TownMapMgr.TouchEvent = event
            if isMoving then
                if TownMapMgr.TouchEventState==1 then
                    --print("人物正在移动中，本次手指拖动不响应")
                    return true
                else
                    print("人物正在移动中，将中断之前的移动方向，重新移动")
                    removeAction(playerAction)
                    removeAction(mapAction)
                    removeAction(mapAction_plus)
                    removeAction(mapAction_front)
                    playerHandlerX = nil
                    mapHandlerX = nil
                    mapPlusHandlerX = nil
                    mapFrontHandlerX = nil
                    
                    transition.stopTarget(TownMapMgr.Player)
                    transition.stopTarget(TownMapMgr.Pet)
                    AnimationMgr.playAni(TownMapMgr.Pet.res, "idle", true, charPetTagStr)
                    TownMapMgr.TmpClickEventCallback = nil
                    isMoving = false
                end
            end
            TownMapMgr.TouchEventState = 1
            if event.name == "moved" then
                if TownMapMgr.TouchEvent.x < TownMapMgr.Player:getPositionX()+TownMapMgr.DEFAULT_KEEPMOVING_DISTANCE and
                    TownMapMgr.TouchEvent.x > TownMapMgr.Player:getPositionX()-TownMapMgr.DEFAULT_KEEPMOVING_DISTANCE then
                    print("手指拖动距离太短，本次移动不响应")
                    return true
                end
            end
            isMoving = true
            
            --点击脚印效果
            local footPrintRes = "Spine/effects/Ui_jiemiandianji.png"
            local footPrint = AnimationMgr.createAni(scene, footPrintRes, event.x, event.y)
            AnimationMgr.playAniWithCallback(footPrintRes, "animation", nil, nil, true)
            footPrint:setLocalZOrder(CocosModuleMgr.ZORDER_TIPS)
            if SceneMgr.currentScene == "HomeScene" then
                HomeMenuMgr.RemoveChatUI()
            end
            
            -- 在单点触摸模式下：在触摸事件开始时，必须返回 true
            -- 返回 true 表示响应本次触摸事件，并且接收后续状态更新
            
            transition.stopTarget(TownMapMgr.Player)
            
            local move_distance = TownMapMgr.DEFAULT_TMAP_WIDTH/2 - event.x
            local move_time = 1
            local tmp_rate = 1
            if move_distance > 0 then
                tmp_rate = -1
            end
            TownMapMgr.Player:setScale(tmp_rate, 1)
            TownMapMgr.PlayerNameLabel:setScale(tmp_rate, 1)
            move_time = math.abs(move_distance/TownMapMgr.move_speed)
            local map_limitX = (map_sizex-TownMapMgr.DEFAULT_TMAP_WIDTH)/2
            local after_move_pos = Forest:getPositionX()+move_distance+map_posx
            local player_posx = TownMapMgr.Player:getPositionX()
            
            local playerPosxInMap = map_sizex/2-(initPos+Forest:getPositionX())+event.x
            --local arrowRes = "Spine/effects/UI_wupinshanshuo.png"
            --local arrowAni = AnimationMgr.createAni(Forest:getChildByName(map_name), arrowRes, playerPosxInMap, mapArrowPosy, "move")
            --AnimationMgr.playAni(arrowAni.res, "animation", true, arrowAni.tag)
            --print("======移动后人物在地图的位置", playerPosxInMap)
            TownMapMgr.sendSelfPosition(playerPosxInMap)
            TownTreeMgr.setMyPosx(playerPosxInMap)
            
            --检查障碍物后获得地图移动参数
            local function checkMapObstacle(fmove_distance, fmove_time)
                local isBlocked = false
                local tmp_x = Forest:getPositionX()
                local dest = tmp_x+fmove_distance
                local tmp_pos_before = initPos+tmp_x
                local tmp_pos = tmp_pos_before+fmove_distance
                for key, var in pairs(TownMapMgr.ObstacleTable) do
                    if tmp_pos_before>=var.from then    --向右移动
                        if tmp_pos<var.from then
                            if not isBlocked or fmove_distance>var.from-tmp_pos_before then
                                fmove_distance = var.from-tmp_pos_before
                                fmove_time = math.abs(fmove_distance/TownMapMgr.move_speed)
                                isBlocked = true
                                dest = tmp_x+fmove_distance--var.from-map_sizex/2
                                --print(tmp_pos_before, tmp_pos, fmove_distance, var.from, tmp_x, dest)
                            end
                        end
                    elseif tmp_pos_before<=var.to then  --向左移动
                        if tmp_pos>var.to then
                            if not isBlocked or fmove_distance<var.to-tmp_pos_before then
                                fmove_distance = var.to-tmp_pos_before
                                fmove_time = math.abs(fmove_distance/TownMapMgr.move_speed)
                                isBlocked = true
                                dest = tmp_x+fmove_distance--var.to-TownMapMgr.DEFAULT_TMAP_WIDTH/2
                                --print(tmp_pos_before, tmp_pos, fmove_distance, var.to, tmp_x, dest)
                            end
                        end
                    end
                end
                --print("checkMapObstacle", fmove_distance, fmove_time, dest)
                return fmove_distance, fmove_time, dest
            end
            --检查障碍物后获得玩家移动参数
            local function checkPlayerObstacle(fmove_distance, fmove_time)
                local isBlocked = false
                local tmp_x = TownMapMgr.Player:getPositionX()
                local dest = fmove_distance+tmp_x
                local tmp_pos_before = TownMapMgr.DEFAULT_TMAP_WIDTH/2-tmp_x+initPos+Forest:getPositionX()
                local tmp_pos = tmp_pos_before-fmove_distance
                for key, var in pairs(TownMapMgr.ObstacleTable) do
                    if tmp_pos_before>=var.from then    --向右移动
                        if tmp_pos<var.from then
                            if not isBlocked or fmove_distance>var.from-tmp_pos_before then
                                fmove_distance = tmp_pos_before-var.from
                                fmove_time = math.abs(fmove_distance/TownMapMgr.move_speed)
                                isBlocked = true
                                dest = 3*TownMapMgr.DEFAULT_TMAP_WIDTH/2-map_sizex/2-var.from
                                --print(tmp_pos_before, tmp_pos, fmove_distance, var.from, dest, map_sizex)
                            end
                        end
                    elseif tmp_pos_before<=var.to then  --向左移动
                        if tmp_pos>var.to then
                            if not isBlocked or fmove_distance<var.to-tmp_pos_before then
                                fmove_distance = tmp_pos_before-var.to
                                fmove_time = math.abs(fmove_distance/TownMapMgr.move_speed)
                                isBlocked = true
                                dest = TownMapMgr.DEFAULT_TMAP_WIDTH/2+map_sizex/2-var.to
                                --print(tmp_pos_before, tmp_pos, fmove_distance, var.to, dest, map_sizex)
                            end
                        end
                    end
                    local max = 3*TownMapMgr.DEFAULT_TMAP_WIDTH/2-map_sizex/2-var.from
                    local min = TownMapMgr.DEFAULT_TMAP_WIDTH/2+map_sizex/2-var.to
                    if max>TownMapMgr.DEFAULT_TMAP_WIDTH/2 and max<TownMapMgr.DEFAULT_TMAP_WIDTH and dest>max then
                    	dest = max
                    elseif min>0 and min<TownMapMgr.DEFAULT_TMAP_WIDTH/2 and dest<min  then
                    	dest = min
                    end
                    --print("max min:", max, min)
                end
                return fmove_distance, fmove_time, dest
            end
            --地图移动通用方法
            local function moveMap(mmove_distance, mmove_time, destination)
                removeAction(mapAction)
                removeAction(mapAction_plus)
                removeAction(mapAction_front)
                mapHandlerX = destination
                --print("set Map", destination)
                mapAction = transition.moveBy(Forest, {x = mmove_distance, y = 0, time = mmove_time})
                if Forest_plus~=nil then
                    mapPlusHandlerX = Forest_plus:getPositionX()+mmove_distance/2
                    mapAction_plus = transition.moveBy(Forest_plus, {x = mmove_distance/2, y = 0, time = mmove_time})
                end
                if Forest_front~=nil then
                    mapFrontHandlerX = destination
                    mapAction_front = transition.moveBy(Forest_front, {x = mmove_distance, y = 0, time = mmove_time})
                end
            end
            --玩家移动通用方法
            local function movePlayer(mmove_distance, mmove_time, destination)
                removeAction(playerAction)
                playerHandlerX = destination
                --print("set Player", destination)
                playerAction = transition.moveBy(TownMapMgr.Player, {x = mmove_distance, y = 0, time = mmove_time})
            end
            
            if player_posx ~= TownMapMgr.DEFAULT_TMAP_WIDTH/2 then
                ----情况一：先移动人物，后移动背景
                local player_move = event.x - player_posx
                local tmp_rate = -1
                if player_move > 0 then
                    tmp_rate = 1
                end
                TownMapMgr.Player:setScale(tmp_rate, 1)
                TownMapMgr.PlayerNameLabel:setScale(tmp_rate, 1)
                move_time = math.abs(player_move/TownMapMgr.move_speed)
                local function tmpFunc()
                    local player_move_dif = TownMapMgr.DEFAULT_TMAP_WIDTH/2-event.x
                    local player_move_time_dif = math.abs((player_posx-TownMapMgr.DEFAULT_TMAP_WIDTH/2)/TownMapMgr.move_speed)
                    local player_move_time = move_time-player_move_time_dif
                    local dest = 0
                    player_move_dif, player_move_time, dest = checkMapObstacle(player_move_dif, player_move_time)
                    movePlayer(TownMapMgr.DEFAULT_TMAP_WIDTH/2-TownMapMgr.Player:getPositionX(), player_move_time_dif, TownMapMgr.DEFAULT_TMAP_WIDTH/2)
                    TownMapMgr.Player:performWithDelay(function()
                        moveMap(player_move_dif, player_move_time, dest)
                    end, player_move_time_dif)
                end
                if player_posx > TownMapMgr.DEFAULT_TMAP_WIDTH/2 then
                    if event.x > TownMapMgr.DEFAULT_TMAP_WIDTH/2 then
                        local pMove, pTime, dest = checkPlayerObstacle(event.x-TownMapMgr.Player:getPositionX(), move_time)
                        move_time = pTime
                        movePlayer(pMove, pTime, dest)
                    else
                        tmpFunc()
                    end
                else
                    if event.x < TownMapMgr.DEFAULT_TMAP_WIDTH/2 then
                        local pMove, pTime, dest = checkPlayerObstacle(event.x-TownMapMgr.Player:getPositionX(), move_time)
                        move_time = pTime
                        movePlayer(pMove, pTime, dest)
                    else
                        tmpFunc()
                    end
                end
            elseif after_move_pos > map_limitX+TownMapMgr.DEFAULT_TMAP_WIDTH/2 or after_move_pos < -map_limitX+TownMapMgr.DEFAULT_TMAP_WIDTH/2 then
                ----情况二：先移动背景，后移动人物
                local map_move_dif_rate = -1
                if after_move_pos > map_limitX+TownMapMgr.DEFAULT_TMAP_WIDTH/2 then
                    map_move_dif_rate = 1
                end
                local map_move_dif = map_move_dif_rate*(after_move_pos-TownMapMgr.DEFAULT_TMAP_WIDTH/2)-map_limitX
                local map_move_time_dif = (move_distance-map_move_dif_rate*map_move_dif)/move_distance*move_time
                local map_dest = map_move_dif_rate*map_limitX+TownMapMgr.DEFAULT_TMAP_WIDTH/2-map_posx
                local mMove, mTime, mDest = checkMapObstacle(map_dest-Forest:getPositionX(), map_move_time_dif)
                if mMove~=map_dest-Forest:getPositionX() then
                    moveMap(mMove, mTime, mDest)
                else
                    moveMap(map_dest-Forest:getPositionX(), map_move_time_dif, map_dest)
                    TownMapMgr.Player:performWithDelay(function()
                        local pMove, pTime, dest = checkPlayerObstacle(-map_move_dif_rate*map_move_dif, move_time-map_move_time_dif)
                        movePlayer(pMove, pTime, dest)
                    end, map_move_time_dif)
                end
            else
                ----情况三：只移动背景
                local dest = 0
                move_distance, move_time, dest = checkMapObstacle(move_distance, move_time)
                moveMap(move_distance, move_time, dest)
            end
            
            ----切换行走动画与待机动画
            if PlayerAnimeMgr.getPlayerCurMotionName(charTagStr)~="walk" then
                PlayerAnimeMgr.playAni(charTagStr, "walk", true)
            end
            TownMapMgr.Player:performWithDelay(function()
                if SceneMgr.currentScene ~= "HomeScene" then
                    isMoving = false
                    
                    --防卡强行置位
                    if mapHandlerX then
                        Forest:setPositionX(mapHandlerX)
                        mapHandlerX = nil
                    end
                    if mapPlusHandlerX then
                        Forest_plus:setPositionX(mapPlusHandlerX)
                        mapPlusHandlerX = nil
                    end
                    if mapFrontHandlerX then
                        Forest_front:setPositionX(mapFrontHandlerX)
                        mapFrontHandlerX = nil
                    end
                    if playerHandlerX then
                        TownMapMgr.Player:setPositionX(playerHandlerX)
                        playerHandlerX = nil
                    end
                    if initPos+Forest:getPositionX()>map_sizex/2 then
                        Forest:setPositionX(map_sizex/2-initPos)
                    elseif initPos+Forest:getPositionX()<TownMapMgr.DEFAULT_TMAP_WIDTH-map_sizex/2 then
                        Forest:setPositionX(TownMapMgr.DEFAULT_TMAP_WIDTH-map_sizex/2-initPos)
                    end
    
                    TownMapMgr.checkNearButton()
                    
                    if TownMapMgr.Player:getPositionX()<TownMapMgr.DEFAULT_DELIVERY_DISTANCE then
                        if LeftDeliveryPointCallback~=nil then
                            --SceneMgr.mapEnterType = 2
                        	LeftDeliveryPointCallback()
                            print("Left Delivery Point arrive")
                        end
                    elseif TownMapMgr.Player:getPositionX()>TownMapMgr.DEFAULT_TMAP_WIDTH-TownMapMgr.DEFAULT_DELIVERY_DISTANCE then
                        if RightDeliveryPointCallback~=nil then
                            --SceneMgr.mapEnterType = 1
                    		RightDeliveryPointCallback()
                            print("Right Delivery Point arrive")
                    	end
                    end
                    if SceneMgr.isProcessing == true then
                        print("场景正在切换中，人物移动的回调函数不执行")
                        return true
                    end
                    
                    if ClickEventCallback~=nil then
                    	ClickEventCallback()
                    end
                    if TownMapMgr.TmpClickEventCallback~=nil then
                        TownMapMgr.TmpClickEventCallback()
                        TownMapMgr.TmpClickEventCallback = nil
                    end
    
                    TownMapMgr.RecordsTable[mapRes] = {
                        initPos=initPos+Forest:getPositionX(),                          --中景位置
                        playerPos=TownMapMgr.Player:getPositionX(),                     --玩家位置
                        petPos=TownMapMgr.Pet:getPositionX()+Forest:getPositionX(),     --宠物位置
                        playerScaleX=TownMapMgr.Player:getScaleX(),                     --玩家方向
                        petScaleX=TownMapMgr.Pet:getScaleX(),                           --宠物方向
                        haveMoved=true,
                        lastEnterType=type
                    }
                    --print("map pos:"..TownMapMgr.RecordsTable[mapRes].initPos)
                    if Forest_plus~=nil then
                        TownMapMgr.RecordsTable[mapRes].initPos_plus=initPos_plus+Forest_plus:getPositionX()
                    end
                    
                    ----宠物跟随移动
                    local isPetNeedMove = false
                    local petMoveDistance = 0
                    local petMoveTime = 0
                    --print("mapx:"..Forest:getPositionX().." petx:"..TownMapMgr.Pet:getPositionX().." playerx:"..TownMapMgr.Player:getPositionX())
                    if TownMapMgr.Player:getPositionX()-Forest:getPositionX()-TownMapMgr.Pet:getPositionX() > TownMapMgr.DEFAULT_PET_DISTANCE then
                        TownMapMgr.Pet:setScale(TownMapMgr.DEFAULT_PET_SCALE, TownMapMgr.DEFAULT_PET_SCALE)
                        --petNameLabel:setScale(1/TownMapMgr.DEFAULT_PET_SCALE, 1/TownMapMgr.DEFAULT_PET_SCALE)
                        petMoveDistance = TownMapMgr.Player:getPositionX()-Forest:getPositionX()-TownMapMgr.Pet:getPositionX()-TownMapMgr.DEFAULT_PET_DISTANCE
                        petMoveTime = petMoveDistance/(TownMapMgr.move_speed+TownMapMgr.DEFAULT_PETSPEED_DIFF)
                        isPetNeedMove = true
                    elseif TownMapMgr.Player:getPositionX()-Forest:getPositionX()-TownMapMgr.Pet:getPositionX() < -TownMapMgr.DEFAULT_PET_DISTANCE then
                        
                        TownMapMgr.Pet:setScale(-TownMapMgr.DEFAULT_PET_SCALE, TownMapMgr.DEFAULT_PET_SCALE)
                        --petNameLabel:setScale(-1/TownMapMgr.DEFAULT_PET_SCALE, 1/TownMapMgr.DEFAULT_PET_SCALE)
                        petMoveDistance = TownMapMgr.Player:getPositionX()-Forest:getPositionX()-TownMapMgr.Pet:getPositionX()+TownMapMgr.DEFAULT_PET_DISTANCE
                        petMoveTime = -petMoveDistance/(TownMapMgr.move_speed+TownMapMgr.DEFAULT_PETSPEED_DIFF)
                        isPetNeedMove = true
                    end
                    if isPetNeedMove then
                        transition.stopTarget(TownMapMgr.Pet)
                        if AnimationMgr.getGafObjCurMotionName(TownMapMgr.Pet.res, charPetTagStr)~="walk" then
                            AnimationMgr.playAni(TownMapMgr.Pet.res, "walk", true, charPetTagStr)
                        end
                        transition.moveBy(TownMapMgr.Pet, {x = petMoveDistance, y = 0, time = petMoveTime})
                        TownMapMgr.Pet:performWithDelay(function()
                            transition.stopTarget(TownMapMgr.Pet)
                            AnimationMgr.playAni(TownMapMgr.Pet.res, "idle", true, charPetTagStr)
                            TownMapMgr.RecordsTable[mapRes].petPos=TownMapMgr.Pet:getPositionX()+Forest:getPositionX()
                            TownMapMgr.RecordsTable[mapRes].petScaleX=TownMapMgr.Pet:getScaleX()
                        end, petMoveTime)
                    end
                    
                    ----若手指按住，则继续移动
                    if TownMapMgr.TouchEventState == 1 then
                        if TownMapMgr.TouchEvent.x > TownMapMgr.Player:getPositionX()+TownMapMgr.DEFAULT_KEEPMOVING_DISTANCE or
                            TownMapMgr.TouchEvent.x < TownMapMgr.Player:getPositionX()-TownMapMgr.DEFAULT_KEEPMOVING_DISTANCE then
                            touchListener(TownMapMgr.TouchEvent)
                            return true
                        end
                    end
                    transition.stopTarget(TownMapMgr.Player)
                    PlayerAnimeMgr.playAni(charTagStr, "idle", true)
                else
                    TownMapMgr.checkNearButton()

                    if TownMapMgr.Player:getPositionX()<TownMapMgr.DEFAULT_DELIVERY_DISTANCE then
                        if LeftDeliveryPointCallback~=nil then
                            --SceneMgr.mapEnterType = 2
                            LeftDeliveryPointCallback()
                            print("Left Delivery Point arrive")
                        end
                    elseif TownMapMgr.Player:getPositionX()>TownMapMgr.DEFAULT_TMAP_WIDTH-TownMapMgr.DEFAULT_DELIVERY_DISTANCE then
                        if RightDeliveryPointCallback~=nil then
                            --SceneMgr.mapEnterType = 1
                            RightDeliveryPointCallback()
                            print("Right Delivery Point arrive")
                        end
                    end
                    
                    if ClickEventCallback~=nil then
                        ClickEventCallback()
                    end
                    if TownMapMgr.TmpClickEventCallback~=nil then
                        TownMapMgr.TmpClickEventCallback()
                        TownMapMgr.TmpClickEventCallback = nil
                    end
                    
                    ----宠物跟随移动
                    local isPetNeedMove = false
                    local petMoveDistance = 0
                    local petMoveTime = 0
                    --print("mapx:"..Forest:getPositionX().." petx:"..TownMapMgr.Pet:getPositionX().." playerx:"..TownMapMgr.Player:getPositionX())
                    if TownMapMgr.Player:getPositionX()-Forest:getPositionX()-TownMapMgr.Pet:getPositionX() > TownMapMgr.DEFAULT_PET_DISTANCE then
                        TownMapMgr.Pet:setScale(TownMapMgr.DEFAULT_PET_SCALE, TownMapMgr.DEFAULT_PET_SCALE)
                        --petNameLabel:setScale(1/TownMapMgr.DEFAULT_PET_SCALE, 1/TownMapMgr.DEFAULT_PET_SCALE)
                        petMoveDistance = TownMapMgr.Player:getPositionX()-Forest:getPositionX()-TownMapMgr.Pet:getPositionX()-TownMapMgr.DEFAULT_PET_DISTANCE
                        petMoveTime = petMoveDistance/(TownMapMgr.move_speed+TownMapMgr.DEFAULT_PETSPEED_DIFF)
                        isPetNeedMove = true
                    elseif TownMapMgr.Player:getPositionX()-Forest:getPositionX()-TownMapMgr.Pet:getPositionX() < -TownMapMgr.DEFAULT_PET_DISTANCE then

                        TownMapMgr.Pet:setScale(-TownMapMgr.DEFAULT_PET_SCALE, TownMapMgr.DEFAULT_PET_SCALE)
                        --petNameLabel:setScale(-1/TownMapMgr.DEFAULT_PET_SCALE, 1/TownMapMgr.DEFAULT_PET_SCALE)
                        petMoveDistance = TownMapMgr.Player:getPositionX()-Forest:getPositionX()-TownMapMgr.Pet:getPositionX()+TownMapMgr.DEFAULT_PET_DISTANCE
                        petMoveTime = -petMoveDistance/(TownMapMgr.move_speed+TownMapMgr.DEFAULT_PETSPEED_DIFF)
                        isPetNeedMove = true
                    end
                    if isPetNeedMove then
                        transition.stopTarget(TownMapMgr.Pet)
                        if AnimationMgr.getGafObjCurMotionName(TownMapMgr.Pet.res, charPetTagStr)~="walk" then
                            AnimationMgr.playAni(TownMapMgr.Pet.res, "walk", true, charPetTagStr)
                        end
                        transition.moveBy(TownMapMgr.Pet, {x = petMoveDistance, y = 0, time = petMoveTime})
                        TownMapMgr.Pet:performWithDelay(function()
                            transition.stopTarget(TownMapMgr.Pet)
                            AnimationMgr.playAni(TownMapMgr.Pet.res, "idle", true, charPetTagStr)
                            TownMapMgr.RecordsTable[mapRes].petPos=TownMapMgr.Pet:getPositionX()+Forest:getPositionX()
                            TownMapMgr.RecordsTable[mapRes].petScaleX=TownMapMgr.Pet:getScaleX()
                        end, petMoveTime)
                    end
                    
                    transition.stopTarget(TownMapMgr.Player)
                    PlayerAnimeMgr.playAni(charTagStr, "idle", true)
                end
            end, move_time)
            ----切换行走动画与待机动画
            return true
        end
    end
    touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, touchListener)
    TownMapMgr.TouchListener = touchListener
    
    ---每秒检查，隐藏屏幕外的玩家
    local function checkPlayerVisible()
        scene:performWithDelay(function()
            TownPlayerMgr.checkPlayerVisible()
            checkPlayerVisible()
        end, 1)
    end
    checkPlayerVisible()
    
    ---发送一些协议
    if NetInterface.isConnect and CharInfo.getCharID()~=0 then
        NetInterface.sendWithBlock("GC_QuerySelfTerritoryIDInfo_Ack", function()
            local TerritorialSend = require("src.Net.Send.TerritorialSend")
            TerritorialSend.sendCG_QuerySelfTerritoryIDInfo_Req()
        end, function()
            if TerritorialInfo.getMyStageID()~=0 then
                CSResourceMgr.seekNodeByName(TownMapMgr.PlayerNameLabel, "king"):setVisible(true)
            end
            TownMapMgr.sendSelfPosition(map_sizex/2-(initPos+Forest:getPositionX())+TownMapMgr.DEFAULT_TMAP_WIDTH/2)
        end)
    end    
end

---设置按钮，此按钮当玩家点击时玩家会先向其靠近，再触发回调
--@param btnName string 按钮名称
--@param callback function 点击按钮时执行的函数
function TownMapMgr.setMapButton(btnName, callback)
    local node = CSResourceMgr.getNodeByName(TownMapMgr.MapRes, btnName)
    if node==nil then
        print("设置地图按钮失败，找不到该按钮")
        return false
    end
    CSResourceMgr.clickEventBinding(TownMapMgr.MapRes, btnName, function(sender)
        if not TownMapMgr.TouchListener then
        	return
        end
        if sender~=nil then
            local event = {x = 0, y = 0}
            local x = sender:getTouchEndPosition().x
            local y = sender:getTouchEndPosition().y
            TownMapMgr.TouchListener({name="began", x=x, y=y})
            TownMapMgr.TouchListener({name="ended", x=x, y=y})
        end        
        if TownMapMgr.TmpClickEventCallback==nil then
            TownMapMgr.TmpClickEventCallback = callback
        end
    end, "", true)
    CSResourceMgr.ButtonFuncTable[node] = callback
    return node
end

---设置按钮事件，此按钮必须当玩家靠近时才可以点击并且触发自定义事件
--@param btnName string 按钮名称
--@param callback function 点击按钮时执行的函数
--@param enableCall function （靠近按钮）按钮生效时执行的函数，可填
--@param disableCall function （离开按钮）按钮无效时执行的函数，可填
function TownMapMgr.setMapButtonEvent(btnName, callback, enableCall, disableCall)
    local mapRes = TownMapMgr.MapRes
    local node = CSResourceMgr.getNodeByName(mapRes, btnName)
    if node==nil then
        mapRes = string.gsub(TownMapMgr.MapRes, ".csb", "_front.csb")
        node = CSResourceMgr.getNodeByName(mapRes, btnName)
        if node==nil then
            print("设置地图按钮事件失败，找不到该按钮")
            return false
        end
    end
    node:setTouchEnabled(false)
    node:setBright(false)
    CSResourceMgr.clickEventBinding(mapRes, btnName, function()
        callback()
    end, "", true)
    local size = node:getContentSize()
    local size_ratex = node:getScaleX()
    TownMapMgr.ButtonTable[btnName] = {node, node:getPositionX(), size.width*size_ratex, enableCall, disableCall}
    TownMapMgr.checkNearButton()
    print("设置地图按钮事件成功，按钮横向距离为"..node:getPositionX(), size.width*size_ratex)
    
    if type(btnName)=="string" then
        btnName = btnName.."_p"
    else
        return false
    end
    local particle = CSResourceMgr.getNodeByName(mapRes, btnName)
    if particle==nil then
        return false
    end
    particle:setVisible(false)
    TownMapMgr.ButtonTable[btnName][6] = particle
end

---设置地图内的障碍物（注意：障碍物的位置请勿设在地图两端及中心的人物的初始点）
--@param btnName string 障碍物名称
function TownMapMgr.setMapObstacle(btnName)
    local node = CSResourceMgr.getNodeByName(TownMapMgr.MapRes, btnName)
    if node==nil  then
        node = CSResourceMgr.getNodeByName(string.gsub(TownMapMgr.MapRes, ".csb", "_front.csb"), btnName)
    end
    if node==nil then
        print("设置地图障碍物失败，找不到障碍物"..btnName)
        return false
    end
    local size = node:getContentSize().width
    local size_ratex = node:getScaleX()
    local anchorx = node:getAnchorPoint().x
    
    local xFrom = (curMapWidth+TownMapMgr.DEFAULT_TMAP_WIDTH)/2-(node:getPositionX()-size*size_ratex*anchorx)
    local xTo = xFrom - size*size_ratex
    TownMapMgr.ObstacleTable[btnName] = {from = xFrom, to = xTo}
    --print("setMapObstacle:"..TownMapMgr.MapInitPos, xFrom, xTo)
end

---删除地图内的障碍物
--@param btnName string 障碍物名称
function TownMapMgr.removeMapObstacle(btnName)
    TownMapMgr.ObstacleTable[btnName] = nil
    local node = CSResourceMgr.getNodeByName(TownMapMgr.MapRes, btnName)
    if node==nil  then
        node = CSResourceMgr.getNodeByName(string.gsub(TownMapMgr.MapRes, ".csb", "_front.csb"), btnName)
    end
    if node==nil then
        print("清除地图障碍物失败，找不到障碍物"..btnName)
        return false
    end
    node:setVisible(false)
end

function TownMapMgr.checkNearButton()
    local mapRes_vec = lua_string_split(TownMapMgr.MapRes, "/")
    local map_name = string.gsub(mapRes_vec[table.getn(mapRes_vec)], ".csb", "")
    local size_ratex = TownMapMgr.Map:getChildByName(map_name):getScaleX()    
    for tags,table in pairs(TownMapMgr.ButtonTable) do
        local btnPosX = table[2]*size_ratex
        local btnSizeX = table[3]*size_ratex
        local bdistance =  curMapWidth/2-btnPosX+TownMapMgr.Player:getPositionX()-TownMapMgr.MapInitPos
        local minX = bdistance-btnSizeX/2-TownMapMgr.DEFAULT_BUTTON_DISTANCE 
        local maxX = bdistance+btnSizeX/2+TownMapMgr.DEFAULT_BUTTON_DISTANCE 
        if TownMapMgr.Map:getPositionX()<maxX and TownMapMgr.Map:getPositionX()>minX then
            table[1]:setTouchEnabled(true)
            table[1]:setBright(true)
            if table[6]~=nil and table[7] == false then
                table[6]:setVisible(true)
            end
            if table[4]~=nil and table[7] == false then
                table[4]()
            end
            table[7] = true
            print("靠近按钮，按钮在能点击范围内，按钮生效")
        else
            table[1]:setTouchEnabled(false)
            table[1]:setBright(false)
            if table[6]~=nil then
                table[6]:setVisible(false)
            end
            if table[5]~=nil then
                table[5]()
            end
            table[7] = false
        end
    end
end

---更换主角时装
function TownMapMgr.changeAvatar()
    PlayerAnimeMgr.setPlayerSkins(charTagStr, CharInfo.getCurfashion())
end

---更换主角携带宠物
--@param id int 宠物id
function TownMapMgr.setCharactorPet(id, skinid)
    if not CSResourceMgr.getCsbObj(TownMapMgr.MapRes) then
    	return
    end

    local petName = CharInfo.getNickName().."的宠物" --以后有了从PetMgr内获取
    
    local scaleX = TownMapMgr.Pet:getScaleX()
    local posX = TownMapMgr.Pet:getPositionX()
    
    AnimationMgr.removeGafObjectByTag(TownMapMgr.Pet.res, charPetTagStr)
    TownMapMgr.Pet = AnimationMgr.createAni(TownMapMgr.Map, PokemonInfo.getPokemonResByID(id), 
        posX, TownMapMgr.DEFAULT_CHARACTOR_POSY, charPetTagStr)
    AnimationMgr.playAni(TownMapMgr.Pet.res, "idle", true, charPetTagStr)
    AnimationMgr.setSkin(TownMapMgr.Pet.res, skinid, TownMapMgr.Pet.tag)
    
    --[[
    petNameLabel = CSResourceMgr.createRes(TownMapMgr.Pet, nameLabelRes, petName)
    CSResourceMgr.setLabelString(nameLabelRes, "name", petName.." ", petName, CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
    local petnamelabel_y = TownMapMgr.DEFAULT_PET_NAMELABEL_POSY1
    if PokemonInfo.getPokemonFigure(id)==1 then
        petnamelabel_y = TownMapMgr.DEFAULT_PET_NAMELABEL_POSY2
    end
    petNameLabel:setPosition(TownMapMgr.DEFAULT_PET_NAMELABEL_POSX, petnamelabel_y)
    petNameLabel:setAnchorPoint(0.5, 0.5)
    petNameLabel:setScale(1/scaleX, 1/TownMapMgr.DEFAULT_PET_SCALE)
    ]]
    
    TownMapMgr.Pet:setScale(scaleX, TownMapMgr.DEFAULT_PET_SCALE)
    TownMapMgr.Pet:setLocalZOrder(2)
end

---设置主角移动速度
--@param speed int 速度
function TownMapMgr.setCharactorSpeed(speed)
    TownMapMgr.move_speed = speed
end

function TownMapMgr.setVisible(val)
    if not CSResourceMgr.getCsbObj(TownMapMgr.MapRes) then
        return
    end
    PlayerAnimeMgr.getPlayer(charTagStr):setVisible(val)
    local function setVisible(res)
        local layer = CSResourceMgr.getCsbObj(res)
        if layer then
            layer:setVisible(val)
        end
    end
    setVisible(TownMapMgr.MapRes)
    setVisible(string.gsub(TownMapMgr.MapRes, ".csb", "_back.csb"))
    setVisible(string.gsub(TownMapMgr.MapRes, ".csb", "_front.csb"))
end

function TownMapMgr.refreshNameLabel(tag, level, confraternity, rank)
    tag = tag or CharInfo.getNickName()
    if not CSResourceMgr.getCsbObj(nameLabelRes, tag) then
        return
    end
    if level then
        CSResourceMgr.setLabelString(nameLabelRes, "level", level, tag)
	end
    if confraternity then
        CSResourceMgr.setLabelString(nameLabelRes, "confraternity", confraternity.." ", tag, 
            {r=93,g=49,b=24,a=255}, nil, 140)
        local confNodeY = CSResourceMgr.getNodeByName(nameLabelRes, "confraternity", tag):getPositionY()
        local kingNode = CSResourceMgr.getNodeByName(nameLabelRes, "king", tag)
        if confraternity=="" then
            kingNode:setPositionY(confNodeY + 4)
        else
            kingNode:setPositionY(confNodeY + 34)
        end
	end
	if rank then
		if rank==1 then
            CSResourceMgr.setSpriteTexture(nameLabelRes, "namebg", "Charactor/NameBoard_1th.png", tag, false)
            CSResourceMgr.setLabelColor(nameLabelRes, "name", {r=250,g=212,b=2,a=255},tag)
		elseif rank==2 then
            CSResourceMgr.setSpriteTexture(nameLabelRes, "namebg", "Charactor/NameBoard_2th.png", tag, false)
            CSResourceMgr.setLabelColor(nameLabelRes, "name", {r=49,g=214,b=255,a=255},tag)
        elseif rank==3 then
            CSResourceMgr.setSpriteTexture(nameLabelRes, "namebg", "Charactor/NameBoard_3th.png", tag, false)
            CSResourceMgr.setLabelColor(nameLabelRes, "name", {r=255,g=157,b=95,a=255},tag)
        elseif rank>=4 and rank<=10 then
            CSResourceMgr.setSpriteTexture(nameLabelRes, "namebg", "Charactor/NameBoard_other.png", tag, false)
            CSResourceMgr.setLabelColor(nameLabelRes, "name", {r=126,g=222,b=250,a=255},tag)
        else
            CSResourceMgr.setSpriteTexture(nameLabelRes, "namebg", "Charactor/NameBoard.png", tag, false)
            CSResourceMgr.setLabelColor(nameLabelRes, "name", {r=255,g=255,b=255,a=255},tag)
		end
	end
end

function TownMapMgr.createNameLabel(parent, name, level, confraternity, king, tag)
    tag = tag or name

    confraternity = confraternity or ""--LuaSqlite.getLanguageByKey("tips23")
    king = king or 0
    local nameNode = CSResourceMgr.createRes(parent, nameLabelRes, tag)
    CSResourceMgr.setLabelString(nameLabelRes, "name", name.." ", tag, nil, nil, 125)
    CSResourceMgr.setLabelString(nameLabelRes, "level", level, tag)
    CSResourceMgr.setLabelColor(nameLabelRes, "confraternity", {r=255,g=239,b=132,a=255}, tag)
    CSResourceMgr.setLabelString(nameLabelRes, "confraternity", confraternity.." ", tag, {r=93,g=49,b=24,a=255}, nil, 140)
    local kingNode = CSResourceMgr.getNodeByName(nameLabelRes, "king", tag)
    local confNodeY = CSResourceMgr.getNodeByName(nameLabelRes, "confraternity", tag):getPositionY()
    if king==0 then
        kingNode:setVisible(false)
    else
        kingNode:setVisible(true)
    end
    if confraternity=="" then
        kingNode:setPositionY(confNodeY + 4)
    else
        kingNode:setPositionY(confNodeY + 34)
    end
    if SceneMgr.currentScene ~= "HomeScene" or name ~= CharInfo.getNickName() then
        nameNode:setPosition(TownMapMgr.DEFAULT_NAMELABEL_POSX, TownMapMgr.DEFAULT_NAMELABEL_POSY)
    else
        nameNode:setPosition(TownMapMgr.DEFAULT_NAMELABEL_POSX, TownMapMgr.DEFAULT_NAMELABEL_POSY - 50)
    end
    nameNode:setAnchorPoint(0.5, 0.5)
    nameNode:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
    return nameNode
end

function TownMapMgr.sendSelfPosition(posx, mapResFile)
    if SceneMgr.currentScene ~= "HomeScene" then
        if not NetInterface.isConnect or CharInfo.getCharID()==0 then
            return
        end
        mapMoveInfo.clientPos = posx
        mapMoveInfo.clientMap = mapResFile
        if mapMoveInfo.isSending then
        	return
        end
        mapMoveInfo.isSending = true
        mapMoveInfo.serverPos = posx
        local function finishFunc()
            mapMoveInfo.isSending = false
            if mapMoveInfo.serverPos~=mapMoveInfo.clientPos then
                TownMapMgr.sendSelfPosition(mapMoveInfo.clientPos, mapMoveInfo.clientMap)
            end
            if mapMoveInfo.delayFunc then
                transition.removeAction(mapMoveInfo.delayFunc)
            end
            mapMoveInfo.delayFunc = SceneMgr.getRunningScene:performWithDelay(function()
                if mapMoveInfo.clientPos~=-999 and mapMoveInfo.serverPos~=-999 then
                    TownMapMgr.sendSelfPosition(mapMoveInfo.clientPos)
                end
            end, 20)
        end
        NetInterface.send("GC_Chat_Ack", function()
            local cjson = require("cjson")
            local ChatSend = require("src.Net.Send.ChatSend")
            local myFamilyInfo = FamilyInfo.GetLocalFamilyInfo() or {}
            local petid, petskin = PokemonInfo.getFollowPokemonID()
            local str = cjson.encode({mapres = mapResFile or TownMapMgr.MapRes, posx = posx, nickname = CharInfo.getNickName(), 
                playerSkin = CharInfo.getCurfashion(), petID = petid, petSkin = petskin, king = TerritorialInfo.getMyStageID(), 
                level = CharInfo.getLevel(), speed = TownMapMgr.move_speed, confraternity = myFamilyInfo.name,
                petShining = CharInfo.get().petshining, rank=CharInfo.getArenaRank(),vip = CharInfo.getVIPLevel()})
            ChatSend.sendCG_Chat_Req({charID = "", channel = TownChatMgr.GetChannelTable()[6], concent = str})
            --print("TownMapMgr.sendSelfPosition channel", TownChatMgr.GetChannelTable()[6])
        end, function()
            finishFunc()
        end, function()
            finishFunc()
        end)
    else
        if enableHomeSync == true and lastPlayerPosX ~= posx and #HomeInfo.GetLocalPlayerInfo() > 0 then
            enableHomeSync = false
            NetInterface.send("GC_Chat_Ack", function()
                HomeInfo.BroadcastHomePlayerUpdateMsg(tostring(CharInfo.getLevel()), FamilyInfo.GetMyFamilyName(), CharInfo.getNickName(), 
                    PokemonInfo.getFollowPokemonID(), CharInfo.getNickName().."'s pet", posx, 300, CharInfo.getCurfashion())
            end, function()
                enableHomeSync = true
                lastPlayerPosX = posx
            end, function()
                enableHomeSync = true
            end)
        end
    end
end

function TownMapMgr.savePosition()
    snapshotPlayerX = TownMapMgr.Player:getPositionX()
    snapshotMapX = TownMapMgr.Map:getPositionX()
end

function TownMapMgr.resetPosition()
    TownMapMgr.Pet:setPositionX(TownMapMgr.DEFAULT_TMAP_WIDTH/2-TownMapMgr.DEFAULT_PET_DISTANCE)
    TownMapMgr.Player:setPositionX(TownMapMgr.DEFAULT_TMAP_WIDTH/2)
    TownMapMgr.Map:setPositionX(0.0)
end

function TownMapMgr.resetPosition4Snapshot()
    TownMapMgr.Player:setPositionX(snapshotPlayerX-snapshotMapX)
    TownMapMgr.Map:setPositionX(0.0)
end

function TownMapMgr.revertPosition()
    TownMapMgr.Player:setPositionX(snapshotPlayerX)
    TownMapMgr.Map:setPositionX(snapshotMapX)
end

return TownMapMgr