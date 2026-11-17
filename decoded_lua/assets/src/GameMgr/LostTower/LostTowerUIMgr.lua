local LostTowerUIMgr = {}

LostTowerUIMgr.eventNodePool = nil
LostTowerUIMgr.tileNodePool  = nil

LostTowerUIMgr.mainResName   = nil
LostTowerUIMgr.topResName    = nil
LostTowerUIMgr.topResName_l  = nil
LostTowerUIMgr.topResName_r  = nil
LostTowerUIMgr.centerResName = nil
LostTowerUIMgr.bottomResName = nil

LostTowerUIMgr.stencils     = {}  -- 裁剪节点模板
LostTowerUIMgr.stencilNode  = nil -- 裁剪模板节点
LostTowerUIMgr.clippingNode = nil -- 裁剪节点
LostTowerUIMgr.warFogNode   = nil

LostTowerUIMgr.LtAniTable = {}

LostTowerUIMgr.keys = {}

local globalhandler -- 步数恢复scheduler 
LostTowerUIMgr.stepFlag = false
LostTowerUIMgr.stepRefreshTime = 0

function LostTowerUIMgr.Init()
    LostTowerUIMgr.mainResName   = "LostTower/LostTowerMain.csb"
    LostTowerUIMgr.topResName    = "LostTower/TopBar/TopBar.csb"
    LostTowerUIMgr.topResName_l  = "LostTower/TopBar/TopBar_left.csb"
    LostTowerUIMgr.topResName_r  = "LostTower/TopBar/TopBar_right.csb"
    LostTowerUIMgr.centerResName = "LostTower/LostTowerCenterNew.csb"
    LostTowerUIMgr.bottomResName = "LostTower/BottomBar/bottomBar.csb"
    
    LostTowerUIMgr.stencils     = {}
    LostTowerUIMgr.stencilNode  = nil
    LostTowerUIMgr.clippingNode = nil 
    LostTowerUIMgr.warFogNode   = nil
    
    LostTowerUIMgr.LtAniTable = {}
    
    local keyID = SystemInfo.getGlobalConfigAddInfoByID(47).values
    LostTowerUIMgr.keys = {}
    for i=1, #keyID do
        table.insert(LostTowerUIMgr.keys, {ID = keyID[i], num = 0})
    end

    LostTowerUIMgr.stepFlag = false
    LostTowerUIMgr.stepRefreshTime = CharInfo.getVipInfoByID(CharInfo.getVIPLevel()).lostTowerRecoverTime -- SystemInfo.getGlobalConfigAddInfoByID(32).values[1]
end

function LostTowerUIMgr.addLtAnimation(ani)
    table.insert(LostTowerUIMgr.LtAniTable, ani)
end

--- top bar refresh functions
function LostTowerUIMgr.updateCurrFloor(floor)
    CSResourceMgr.setLabelString(LostTowerUIMgr.topResName_l,{"floor_info_button","curr_floor_n"},floor,"",{r=0,g=0,b=0,a=255})
end
function LostTowerUIMgr.updateBestFloor(floor)
    CSResourceMgr.setLabelString(LostTowerUIMgr.topResName_l,{"floor_info_button","board","best_floor_n"},floor,"",{r=0,g=0,b=0,a=255})
end
function LostTowerUIMgr.updateWeekFloor(floor)
    CSResourceMgr.setLabelString(LostTowerUIMgr.topResName_l,{"floor_info_button","board","weekMaxFloor_n"},floor,"",{r=0,g=0,b=0,a=255})
end
function LostTowerUIMgr.updateStepNumber(number)
    if not CSResourceMgr.getCsbObj(LostTowerUIMgr.topResName) then return end
    
    local max = CharInfo.getVipInfoByID(CharInfo.getVIPLevel()).ltSetpNumber + LostTowerMgr.stepMaxAdditional
    CSResourceMgr.setLabelString(LostTowerUIMgr.topResName,{"step_point_db","step_point_n"},number.."/"..max)
end
function LostTowerUIMgr.updatePoints(points)
    if not CSResourceMgr.getCsbObj(LostTowerUIMgr.topResName) then return end
    CSResourceMgr.setLabelString(LostTowerUIMgr.topResName,{"acc_point_box","acc_point_num"},points,"")
end
function LostTowerUIMgr.pointEffectToTopbar(block,callback)

    local fog = CSResourceMgr.getNodeByName(LostTowerUIMgr.centerResName,"fog")
    local node = display.newSprite("UI/CommonFiles/tower_integral_01.png")
    SceneMgr.getRunningScene:addChild(node)
    node:setGlobalZOrder(CocosModuleMgr.ZORDER_GUIDE)

    local pointbox   = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName,"acc_point_box")
    local pointicon = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName,{"acc_point_box","acc_point_icon"})
    local _x,_y = pointicon:getPosition()

    local b_node = SearchingUIMgr.getBlockNode(block)
    local b_x,b_y = b_node:getPosition()

    local endP = pointbox:convertToWorldSpace(cc.p(_x,_y))  --SearchingUIMgr.getBlockNode(1)
    local startP = fog:getInnerContainer():convertToWorldSpace(cc.p(b_x,b_y))  --SearchingUIMgr.getBlockNode(block)
    local x0,y0 = startP.x, startP.y  --startP:getPosition()
    local x,y = x0+200,y0-150 
    local x2,y2 = endP.x, endP.y  --endP:getPositionX(),endP:getPositionY()+50
    local x1,y1 = x2,y2+20   --x2+20,y2-20 

    print("~~~~~~~~~~~~~~~~~~~~@",startP.x, startP.y)
    print("~~~~~~~~~~~~~~~~~~~~@",endP.x, endP.y)

    node:setPosition(x0,y0)

    local time = 0.6 + 0.01*block  --线性递增

    local action = cc.BezierTo:create(time,{cc.p(x, y), cc.p(x1, y1), cc.p(x2, y2)})  --贝塞尔曲线运动轨迹
    node:runAction(action)
    SceneMgr.getRunningScene:performWithDelay(function()
        node:fadeOut(0.2*time)
    end,0.8*time)
    SceneMgr.getRunningScene:performWithDelay(function()
        if callback then callback() end
        SceneMgr.getRunningScene:removeChild(node)
    end,time)

end

function LostTowerUIMgr.bezierEffectToTopbar(block,callback,imgpath,targetN)

    imgpath = imgpath or "UI/CommonFiles/tower_integral_01.png"

    local fog = CSResourceMgr.getNodeByName(LostTowerUIMgr.centerResName,"fog")
    local node = display.newSprite(imgpath)
    SceneMgr.getRunningScene:addChild(node)
    node:setGlobalZOrder(CocosModuleMgr.ZORDER_GUIDE)

    local _x,_y = targetN:getPosition()

    local b_node = SearchingUIMgr.getBlockNode(block)
    local b_x,b_y = b_node:getPosition()

    local endP = targetN:getParent():convertToWorldSpace(cc.p(_x,_y))  --SearchingUIMgr.getBlockNode(1)
    local startP = fog:getInnerContainer():convertToWorldSpace(cc.p(b_x,b_y))  --SearchingUIMgr.getBlockNode(block)
    local x0,y0 = startP.x, startP.y  --startP:getPosition()
    local x,y = x0+200,y0-150 
    local x2,y2 = endP.x, endP.y  --endP:getPositionX(),endP:getPositionY()+50
    local x1,y1 = x2,y2+20   --x2+20,y2-20 

    node:setPosition(x0,y0)
    
    local distance = cc.pGetDistance(startP,endP)
    local speed    = 500 + distance
    local time = distance / speed

    local action = cc.BezierTo:create(time,{cc.p(x, y), cc.p(x1, y1), cc.p(x2, y2)})  --贝塞尔曲线运动轨迹
    node:runAction(action)
    SceneMgr.getRunningScene:performWithDelay(function()
        node:fadeOut(0.2*time)
    end,0.8*time)
    SceneMgr.getRunningScene:performWithDelay(function()
        if callback then callback() end
        SceneMgr.getRunningScene:removeChild(node)
    end,time)

end

--- 千层塔步数增加跳动
function LostTowerUIMgr.rollTheStepNumber(scene)
    if LostTowerMgr.previousStepNum < 0 then return end
    if LostTowerMgr.previousStepNum > LostTowerMgr.getStepNumber() then return end
    if not CSResourceMgr.getCsbObj(LostTowerUIMgr.topResName) then return end
    
    if SearchingMgr.eventInfoTable[SearchingMapMgr.battlePos] ~= LtEventOption.EVENT_OTHERTRAINER then -- pvp战斗才有返步数效果
        LostTowerUIMgr.updateStepNumber(LostTowerMgr.getStepNumber())
        return
    end
    
    LostTowerUIMgr.updateStepNumber(LostTowerMgr.previousStepNum)
    
    LostTowerUIMgr.bezierEffectToTopbar(SearchingMapMgr.battlePos,function()
        local k = 0
        local totalTime = 0.5
        local n = LostTowerMgr.getStepNumber() - LostTowerMgr.previousStepNum
        local gap = totalTime / n
    
        for i = LostTowerMgr.previousStepNum, LostTowerMgr.getStepNumber() do
            k = k + 1
            scene:performWithDelay(function()
                LostTowerUIMgr.updateStepNumber(i)
            end, gap*k)
        end
    end,"UI/CommonFiles/tower_icon_steps_46.png",CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName,{"step_point_db","step_point_n"}))
end

--- 千层塔积分增加跳动
function LostTowerUIMgr.rollTheLtPoints(scene)
    if LostTowerMgr.previousPoint < 0 then return end
    if LostTowerMgr.previousPoint > LostTowerMgr.points then return end

    SearchingMgr.canMove = false
    LostTowerUIMgr.pointEffectToTopbar(SearchingMapMgr.battlePos,function()
        if not CSResourceMgr.getCsbObj(LostTowerUIMgr.topResName) then return end
        local label = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName,{"acc_point_box","acc_point_num"})
        CSResourceMgr.setLabelStringByNode(label, LostTowerMgr.previousPoint)
        local k = 0
        local totalTime = 0.5
        local n = LostTowerMgr.points - LostTowerMgr.previousPoint
        local gap = totalTime / n
        for i = LostTowerMgr.previousPoint, LostTowerMgr.points do
            k = k + 1
            scene:performWithDelay(function()
                CSResourceMgr.setLabelStringByNode(label, i)
            end,gap*k)
        end
        --local scaleto_1_1 = cc.ScaleTo:create(0.1*k/2, 1.1)
        --local scaleto_1_0 = cc.ScaleTo:create(0.1*k/2, 1.0)
        --label:runAction(cc.Sequence:create(scaleto_1_1, scaleto_1_0))
        LostTowerMgr.previousPoint = -1

        SearchingMgr.canMove = true
    end)
end

function LostTowerUIMgr.showBattleAwards()
    if not LostTowerMgr.battleAwards then return end

    local awardTable = {}
    local cjson = require("cjson")
    for key, var in pairs(LostTowerMgr.battleAwards) do
        if type(var)=="string" then
            local j = cjson.decode(var)
            if j.elementType=="item" then
                if j.elementID ~= 0 and j.num ~= 0 then
                    table.insert(awardTable, var)
                end
            end
        end
    end
    if #awardTable > 0 then
        GameAudio.playUISound("itemGet")
        AwardsListMgr.show(SceneMgr.getRunningScene, awardTable)
    end
    LostTowerMgr.battleAwards = nil
end

function LostTowerUIMgr.setStepRefreshTime()
    local refreshStep = CharInfo.getVipInfoByID(CharInfo.getVIPLevel()).lostTowerRecoverTime -- SystemInfo.getGlobalConfigAddInfoByID(32).values[1] -- 刷新时间间隔 [秒]
    local stepNumMax  = CharInfo.getVipInfoByID(CharInfo.getVIPLevel()).ltSetpNumber + LostTowerMgr.stepMaxAdditional  -- 可移动步数上限
    
    local timeLabel_t = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName,{"step_point_db","step_refreshTime_t"})
    
    local function check()
        if LostTowerMgr.getStepNumber() >= stepNumMax then
            timeLabel_t:setPositionX(180)
            CSResourceMgr.setLabelString(LostTowerUIMgr.topResName,{"step_point_db","step_refreshTime_t"},"LtText6")
            CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName,{"step_point_db","step_timeLabel"}):setVisible(false)
        else
            timeLabel_t:setPositionX(140)
            CSResourceMgr.setLabelString(LostTowerUIMgr.topResName,{"step_point_db","step_refreshTime_t"},"LtText5")
            CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName,{"step_point_db","step_timeLabel"}):setVisible(true)
        end
    end
    check()
    
    local function refresh()
        local passTime = CharInfo.getServerTime() - LostTowerMgr.stepRefreshTime

        LostTowerMgr.stepAdded = math.floor( passTime/refreshStep )
        if LostTowerMgr.stepNumber >= stepNumMax then
            LostTowerMgr.stepAdded = 0
        else
            if LostTowerMgr.stepNumber + LostTowerMgr.stepAdded >= stepNumMax then
                LostTowerMgr.stepAdded = stepNumMax - LostTowerMgr.stepNumber
            end
        end
        LostTowerUIMgr.updateStepNumber(LostTowerMgr.getStepNumber())
        
        local CountDownSeconds = refreshStep - (passTime % refreshStep)
        local timeLabel = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName,{"step_point_db","step_timeLabel"})
        CocosModuleMgr.setTimeLabelCountDown(timeLabel, CountDownSeconds, function()
            refresh()
        end,function(second)
            check()
        end)
    end

    if LostTowerMgr.stepRefreshTime then
        refresh()
        if LostTowerMgr.previousStepNum >= 0 and LostTowerMgr.previousStepNum < LostTowerMgr.getStepNumber() and SceneMgr.previousScene == "BattleScene" then   -- 战斗获得步数
            if SearchingMapMgr.battlePos and SearchingMgr.eventInfoTable[SearchingMapMgr.battlePos] == LtEventOption.EVENT_OTHERTRAINER then -- pvp战斗才有返步数效果
                if SearchingMapMgr.battleResult == PLAYER_WIN then
                    LostTowerUIMgr.updateStepNumber(LostTowerMgr.previousStepNum)
                end
            end
        end
    end
    
    local scheduler = require("framework.scheduler")
    if globalhandler then
        scheduler.unscheduleGlobal(globalhandler)
    end
    globalhandler =  scheduler.scheduleUpdateGlobal(function()
        if LostTowerUIMgr.stepFlag then
            local timeLabel = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName,{"step_point_db","step_timeLabel"})
            CocosModuleMgr.setTimeLabelCountDown(timeLabel, refreshStep, function()
                refresh()
            end,function(second)
                check()
            end)
            LostTowerUIMgr.stepFlag = false
        end
    end)
end

---
--@param type number 0:全部设置 1:1号钥匙 2:2号钥匙 3:3号钥匙
function LostTowerUIMgr.setKeys(type)
    local keys = {}
    if type == 0 then
        for i=1, #LostTowerUIMgr.keys do
            keys[i] = i
            LostTowerUIMgr.keys[i].num = ItemInfo.getCharItemNum(LostTowerUIMgr.keys[i].ID)
        end
    elseif type == 1 then keys = {1}
    elseif type == 2 then keys = {2}
    elseif type == 3 then keys = {3}
    end
    
    for i=1, #keys do
        local id = keys[i]
        local label = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_r,{"key_db","key"..id,"key_n"..id})
        CSResourceMgr.setLabelStringByNode(label,LostTowerUIMgr.keys[id].num)
    end
end

function LostTowerUIMgr.useKey(id)
    if LostTowerUIMgr.keys[id].num - 1 < 0 then return end
    LostTowerUIMgr.keys[id].num = LostTowerUIMgr.keys[id].num - 1
    LostTowerUIMgr.setKeys(id)
end

function LostTowerUIMgr.refreshTop()
    LostTowerUIMgr.updateCurrFloor(LostTowerMgr.currentFloor)
    LostTowerUIMgr.updateWeekFloor(LostTowerMgr.weekMaxFloor)
    LostTowerUIMgr.updateBestFloor(LostTowerMgr.maxFloor)
    LostTowerUIMgr.updatePoints(LostTowerMgr.points)
    LostTowerUIMgr.setKeys(0)
    LostTowerUIMgr.setStepRefreshTime()
    -- LostTowerUIMgr.updateStepNumber(LostTowerMgr.getStepNumber())
end

function LostTowerUIMgr.setTop(scene)
    local topBar = CSResourceMgr.createRes(scene, LostTowerUIMgr.topResName)
    CSResourceMgr.setFullScreen(LostTowerUIMgr.topResName)
    CocosModuleMgr.setEdgeDistance(topBar, nil, nil, 0, nil, false)
    topBar:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)

    local topBar_l = CSResourceMgr.createRes(scene, LostTowerUIMgr.topResName_l)
    CSResourceMgr.setFullScreen(LostTowerUIMgr.topResName_l)
    CocosModuleMgr.setEdgeDistance(topBar_l, 0, nil, 0, nil, false)
    topBar_l:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)

    local topBar_r = CSResourceMgr.createRes(scene, LostTowerUIMgr.topResName_r)
    CSResourceMgr.setFullScreen(LostTowerUIMgr.topResName_r)
    CocosModuleMgr.setEdgeDistance(topBar_r, nil, 0, 0, nil, false)
    topBar_r:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
    
    -- 当前层/最高层/效果
    local c0 = {r=0,g=0,b=0,a=255}
    local c1 = {r=144,g=238,b=255,a=255}
    local curr_flo_t = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,{"floor_info_button","curr_floor_t"})
    local week_flo_t = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,{"floor_info_button","board","weekMaxFloor_t"})
    local best_flo_t = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,{"floor_info_button","board","best_floor_t"})
    CSResourceMgr.setLabelColorByNode(curr_flo_t,c1)
    CSResourceMgr.setLabelColorByNode(week_flo_t,c1)
    CSResourceMgr.setLabelColorByNode(best_flo_t,c1)
    CSResourceMgr.setLabelColor(LostTowerUIMgr.topResName_l,{"effect_info_button","effect_t"},c1)
    CSResourceMgr.setLabelStringByNode(curr_flo_t,"LtText1",nil,nil,90)
    CSResourceMgr.setLabelStringByNode(week_flo_t,"LtText7",nil,nil,120)
    CSResourceMgr.setLabelStringByNode(best_flo_t,"LtText2",nil,nil,120)
    curr_flo_t:enableOutline(c0,1)
    week_flo_t:enableOutline(c0,1)
    best_flo_t:enableOutline(c0,1)
    CSResourceMgr.setLabelString(LostTowerUIMgr.topResName_l,{"effect_info_button","effect_t"},"LtText3","",c0,nil,42)
    CSResourceMgr.setLabelString(LostTowerUIMgr.topResName_l,{"effect_info_button","effect_n"},0,"",c0)

    CSResourceMgr.setLabelString(LostTowerUIMgr.topResName_l,{"floor_info_button","curr_floor_n"},LostTowerMgr.currentFloor,"",c0)
    CSResourceMgr.setLabelColor(LostTowerUIMgr.topResName_l,{"floor_info_button","board","weekMaxFloor_n"},{r=255,g=252,b=0,a=255})
    CSResourceMgr.setLabelString(LostTowerUIMgr.topResName_l,{"floor_info_button","board","weekMaxFloor_n"},LostTowerMgr.weekMaxFloor,"",c0)
    CSResourceMgr.setLabelColor(LostTowerUIMgr.topResName_l,{"floor_info_button","board","best_floor_n"},{r=255,g=252,b=0,a=255})
    CSResourceMgr.setLabelString(LostTowerUIMgr.topResName_l,{"floor_info_button","board","best_floor_n"},LostTowerMgr.maxFloor,"",c0)
    
    -- 当前层/最高层 == 数字座标调整
--    CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName,{"floor_info_large","curr_floor_n"}):setPosition(39 + 8 + curr_flo_t:getContentSize().width, curr_flo_t:getPositionY())
--    CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName,{"floor_info_large","best_floor_n"}):setPosition(39 + 8 + best_flo_t:getContentSize().width, best_flo_t:getPositionY())
    
    -- 剩余步数
    local c2 = {r=221,g=192,b=138,a=255}
    local c3 = {r=80,g=61,b=35,a=255}    -- title字体颜色/数字outline
    local c4 = {r=251,g=240,b=215,a=255} -- 数字 textColor
    CSResourceMgr.setLabelColor(LostTowerUIMgr.topResName,{"step_point_db","step_point_t"},c3)
    CSResourceMgr.setLabelString(LostTowerUIMgr.topResName,{"step_point_db","step_point_t"},"LtText4","",c2,nil,56) -- "步数："
    CSResourceMgr.setLabelColor(LostTowerUIMgr.topResName,{"step_point_db","step_point_n"},c4)
    CSResourceMgr.setLabelString(LostTowerUIMgr.topResName,{"step_point_db","step_point_n"},"","",c3,nil,94)
    
    CSResourceMgr.clickEventBinding(LostTowerUIMgr.topResName, {"step_point_db","add_btn"}, function()
        LtStepAddView.show(nil, function(result)
        end)
    end,"",true)
    
    -- 步数刷新时间
    CSResourceMgr.setLabelString(LostTowerUIMgr.topResName,{"step_point_db","step_refreshTime_t"},"LtText5","",{r=0,g=0,b=0,a=255,w=1},nil,126)
    LostTowerUIMgr.setStepRefreshTime()
    
    -- 成就点
    CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName,"acc_point_box"):setCascadeColorEnabled(false)  -- 设置颜色不影响子节点
    if LostTowerMgr.previousPoint >= 0 and LostTowerMgr.previousPoint < LostTowerMgr.points then   -- 战斗获得积分
        CSResourceMgr.setLabelString(LostTowerUIMgr.topResName,{"acc_point_box","acc_point_num"},LostTowerMgr.previousPoint,"")
    else
        CSResourceMgr.setLabelString(LostTowerUIMgr.topResName,{"acc_point_box","acc_point_num"},LostTowerMgr.points,"")
    end

    CSResourceMgr.clickEventBinding(LostTowerUIMgr.topResName_r, "close", function()
        if SearchingMgr.eventInfoTable[SearchingMgr.playerCurrPosition] == LtEventOption.EVENT_PORTAL then
            print("####### still transfer while losttower is closing")
            print("####### current player position is", SearchingMgr.playerCurrPosition)
            LtFuncMgr.sendTransferReq(SearchingMgr.playerCurrPosition)
        end
    
        transition.stopTarget(SceneMgr.getRunningScene)
        LostTowerUIMgr.hide()
        LostTowerMgr.closeLostTower()
        LostTowerUIMgr.removeAllAnimation()
        
        CSResourceMgr.removeCSObjectByTag(LostTowerUIMgr.mainResName)
        CSResourceMgr.removeCSObjectByTag(LostTowerUIMgr.topResName)
        CSResourceMgr.removeCSObjectByTag(LostTowerUIMgr.topResName_l)
        CSResourceMgr.removeCSObjectByTag(LostTowerUIMgr.topResName_r)
        CSResourceMgr.removeCSObjectByTag(LostTowerUIMgr.centerResName)
        CSResourceMgr.removeCSObjectByTag(LostTowerUIMgr.bottomResName)
        SceneMgr.replaceScene(scene, "MainScene")
    end)
    
    local function reLocEffectInfo(offsetY)
        local effect_button  = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l, "effect_info_button")
        local effect_list_db = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,"effet_list_db")
        local effect_list    = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,"effect_listView")
        transition.moveBy(effect_button,{y=offsetY,time=0.1})
        transition.moveBy(effect_list_db,{y=offsetY,time=0.1})
        transition.moveBy(effect_list,{y=offsetY,time=0.1})
    end
    
    local isFloorInfoShown = false
    CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,{"floor_info_button","board"}):setLocalZOrder(-1)
    CSResourceMgr.clickEventBinding(LostTowerUIMgr.topResName_l, "floor_info_button", function()
        local info_board = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,"floor_info_board")
        local infos = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,{"floor_info_button","board"})
        if isFloorInfoShown then
            CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,{"floor_info_button","floor_info_pulldown"}):setRotation(270)
            transition.scaleTo(info_board,{scaleX=0.0,time=0.1})
            transition.scaleTo(infos,{scaleY=0.0,time=0.1})
            isFloorInfoShown = false
            reLocEffectInfo(60)
        else
            CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,{"floor_info_button","floor_info_pulldown"}):setRotation(0)
            transition.scaleTo(info_board,{scaleX=1.0,time=0.1})
            transition.scaleTo(infos,{scaleY=1.0,time=0.1})
            isFloorInfoShown = true
            reLocEffectInfo(-60)
        end
    end)
    
    local isEffectShown = false
    CSResourceMgr.clickEventBinding(LostTowerUIMgr.topResName_l, "effect_info_button", function()
        local list_db = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,"effet_list_db")
        local listview = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,"effect_listView")
        if isEffectShown then
            CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,{"effect_info_button","effect_pulldown"}):setRotation(270)
            transition.scaleTo(list_db,{scaleY=0.0,time=0.1})
            transition.scaleTo(listview,{scaleY=0.0,time=0.1})
            isEffectShown = false
        else
            CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,{"effect_info_button","effect_pulldown"}):setRotation(0)
            transition.scaleTo(list_db,{scaleY=1.0,time=0.1})
            transition.scaleTo(listview,{scaleY=1.0,time=0.1})
            isEffectShown = true
        end
    end)

    LostTowerUIMgr.setKeys(0)
    
    CSResourceMgr.clickEventBinding(LostTowerUIMgr.topResName_r,"previewBtn",function()
        LtChangeFloorView.show(SceneMgr.getRunningScene, LostTowerMgr.currentFloor,nil,nil,2)
    end,"",1)
    
    local pSkillNode = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_r,"pSkillNode")
    local skill, level = AchievementListMgr.getSkillUpInfo("lostTower")
    if skill then
        local pSkill = {info = skill, level = level}
        LostTowerUIMgr.showPotentialSkill(pSkillNode,pSkill,"lostTower",{x=-40,y=0},true)
        
        CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName,{"acc_point_box","potentialBuff"}):setVisible(true)
        CSResourceMgr.setLabelColor(LostTowerUIMgr.topResName,{"acc_point_box","acc_point_num"},{r=147,g=254,b=6,a=255})
    end
end

function LostTowerUIMgr.clearMap()
    LostTowerUIMgr.removeAllAnimation()
    for i=1, LtMapOption.getMapSize() do
        SearchingUIMgr.clearBlock(i)
    end
end

--- 刷新地图
function LostTowerUIMgr.resetMap()

    local scene = SceneMgr.getRunningScene

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

    LostTowerUIMgr.tileNodePool.pushAll()
    LostTowerUIMgr.eventNodePool.pushAll()

    --中间方格UI
    local LtMapNodeMgr = require("src.GameMgr.LostTower.LtMapNodeMgr")
    LtMapNodeMgr.CreateMapWithSize(scene,LostTowerUIMgr.centerResName)

    local sceneID = LostTowerMgr.LtMapData[1]["sceneID"]
    local code = LostTowerInfo.getLostTowerMapInfoById(sceneID)["lostTowerList"][1]["terrRes"]
    AdvEnvironmentMgr.initEnvironmentParams(code)

    LostTowerMgr.createMap()
    local function initSlab()
        local groundRes = AdvEnvironmentMgr.makePath("dz1")
        
        for i=1, LtMapOption.getMapSize() do
            local etype = SearchingMgr.eventInfoTable[i]
            local b_node = LtMapNodeMgr.getBlockNode(i)
            local zorder = SearchingUIMgr.calcZOrderAt(i)
            b_node:setLocalZOrder( zorder ) --物品Z軸
            
            local g_node = LtMapNodeMgr.getGroundNode(i)
            local img = groundRes  -- "Searching/env/ysd/dz1.png"
            CSResourceMgr.setButtonTextureByNode(g_node,  img,  img,  img)
            
            --已經解鎖迷霧
            if 0 == SearchingMgr.mapInfoTable[i] then
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
    end
    
    initSlab()
    LtPlayerMgr.initPlayer()
    LostTowerUIMgr.refreshTop()
    LtWarFogMgr.initWarFog(LostTowerMgr.movedCells)
    LtWarFogMgr.refreshWarFog(LostTowerMgr.movedCells, SearchingMgr.playerCurrPosition)
    
    local id = SearchingMgr.playerCurrPosition
    local floor = SearchingMapMgr.currFloor
    SearchingUIMgr.transferPlayerTo(id, floor)

    local scrollview = CSResourceMgr.getNodeByName(LostTowerUIMgr.centerResName,"fog")
    DungeonMapMgr.scrollMapWithCellID(scrollview, SearchingMgr.playerCurrPosition)
end

function LostTowerUIMgr.scrollMapTo(block,time)
    time = time or 0.25
    
    local playerNode = SearchingUIMgr.getPlayerNode()
    playerNode:setVisible(false)
    playerNode:performWithDelay(function()
        playerNode:setVisible(true)
        local x, y = SearchingUIMgr.getBlockNode(block):getPosition()
        playerNode:setPosition(x, y)
        local zorder = SearchingUIMgr.calcZOrderAt( block, true )
        playerNode:setLocalZOrder( zorder )
    end, 0.25)
end

--- 生成战争迷雾
function LostTowerUIMgr.setWarFog()
    LtWarFogMgr.initWarFog(LostTowerMgr.movedCells)
    LtWarFogMgr.refreshWarFog(LostTowerMgr.movedCells, SearchingMgr.playerCurrPosition)
    
--    CSResourceMgr.getNodeByName(LostTowerUIMgr.centerResName,{"ScrollView","warFog"}):setVisible(false)

--    local shadow = CSResourceMgr.getNodeByName(LostTowerUIMgr.centerResName,{"ScrollView","warFog"})
--    shadow:removeFromParent()
--
--    LostTowerUIMgr.stencilNode = cc.Node:create()
--    local stencil = LostTowerUIMgr.stencilNode
--    
--    LostTowerUIMgr.clippingNode = cc.ClippingNode:create(stencil)
--    LostTowerUIMgr.clippingNode:addChild(shadow)
--    LostTowerUIMgr.clippingNode:setStencil(stencil)
--    LostTowerUIMgr.clippingNode:setInverted(true)
--    LostTowerUIMgr.clippingNode:setAlphaThreshold(0.9)
--    LostTowerUIMgr.clippingNode:setAnchorPoint(0,0)
--    LostTowerUIMgr.clippingNode:setPosition(0,0)
--    CSResourceMgr.getNodeByName(LostTowerUIMgr.centerResName,"ScrollView"):addChild(LostTowerUIMgr.clippingNode)
    
end

--- 显示指定方格战争迷雾
function LostTowerUIMgr.showWarFogAt(i)
    
end

--- 去除指定方格的战争迷雾
function LostTowerUIMgr.hideWarFogAt(i)
--    local x, y = SearchingUIMgr.getBlockNode(i):getPosition()
--    local node = display.newSprite("Searching/ban.png")
--    table.insert(LostTowerUIMgr.stencils,{node = node, pos = {x = x, y = y,},})
--    
--    LostTowerUIMgr.stencilNode:addChild(node)
--    node:setPosition(x, y + 24)
end

function LostTowerUIMgr.showNearBy()
--    local x, y = SearchingUIMgr.getBlockNode(SearchingMgr.playerCurrPosition):getPosition()
--    
--    LostTowerUIMgr.stencilNode:removeAllChildren()
--    LostTowerUIMgr.stencils = {}
--    
--    local vision = 2
--    for i = -vision, vision do
--        for k = -vision, vision do
--            if math.abs(i) + math.abs(k) <= vision then
--                local node = display.newSprite("Searching/ban.png")
--                table.insert(LostTowerUIMgr.stencils,{node = node, pos = {x = x + 104*i, y = y + 104*k,},})
--                LostTowerUIMgr.stencilNode:addChild(node)
--                node:setPosition(x + 104*i, y + 104*k + 22)
--            end
--        end
--    end
end

function LostTowerUIMgr.setCenter(scene)
end

function LostTowerUIMgr.setBottom(scene)
    local bottomBar = CSResourceMgr.createRes(scene, LostTowerUIMgr.bottomResName)
    CSResourceMgr.setFullScreen(LostTowerUIMgr.bottomResName)
    CocosModuleMgr.setEdgeDistance(bottomBar, nil, nil, nil, 0, false)
    bottomBar:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
    
    local c0 = {r=0,g=0,b=0,a=255}

    local isMenuShown = false
    local function hideMenu()
        CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,"block"):setVisible(false)
        CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,"menu_db"):setScaleY(0.0)
        CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,{"targets","menuicon"}):setScaleY(-1.0)
        isMenuShown = false

        GameAudio.playUISound("retract")
        UIStack.pop("LT-Menu")
    end
    local function showMenu()
        CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,"block"):setVisible(true)
        local menu = CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,"menu_db")
        transition.scaleTo(menu, {scaleY = 1, time = 0.02})
        CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,{"targets","menuicon"}):setScaleY(1.0)
        isMenuShown = true
        
        GameAudio.playUISound("popup")
        UIStack.push("LT-Menu",hideMenu)
    end
    
    CSResourceMgr.clickEventBinding(LostTowerUIMgr.bottomResName, "targets", function()  -- menu
        if isMenuShown then
            hideMenu()
        else
            showMenu()
        end
    end)
    CSResourceMgr.setLabelString(LostTowerUIMgr.bottomResName,{"targets","tagText"},"LtBtn1","",c0)
	if LuaSqlite.LANG_TYPE == 6 or 4 then --越南、印尼版缩小千层塔“功能”的字体大小
		CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,"targets"):setPositionX(CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,"targets"):getPositionX()+5)
		CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,"menu_db"):setPositionX(CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,"menu_db"):getPositionX()+5)
		CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,{"targets","tagText"}):setFontSize(CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,{"targets","tagText"}):getFontSize()-6)
    end
	CSResourceMgr.clickEventBinding(LostTowerUIMgr.bottomResName,"block",function()
        if isMenuShown then
            hideMenu()
        end
    end)
    
    CSResourceMgr.clickEventBinding(LostTowerUIMgr.bottomResName, "package", function()  -- reset
        LtResetViewMgr.show(SceneMgr.getRunningScene)
    end,"",true)
    CSResourceMgr.setLabelString(LostTowerUIMgr.bottomResName,{"package","packText"},"LtBtn2","",c0)

    local petList = CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,"petQue")
    local circle = CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,"light_square")
    local pet_num = #LtPetsMgr.LtArmy
    local help_pet_num = #LtPetsMgr.LtHelpArmy
    
    local m_label = CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName, {"mainPets", "m_pet_label"})
    local h_label = CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName, {"helpPets", "h_pet_label"})
    CSResourceMgr.setLabelStringByNode(m_label,"train107")
    CSResourceMgr.setLabelStringByNode(h_label,"train108")
    
    -- 当前解锁宠物数量
    local maxPetCount = PetFormationMgr.getMaxPetCount()
    
    -- 宠物卡片空槽
    LtPetsMgr.LtEmptyPetNodes = {}
    for i = 1, 6 do
        local emptyNode = CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,"emptyPet"):clone()
        petList:addChild(emptyNode)
        if i <= 3 then
            emptyNode:setPosition(55+98*(i-1), 2)
        else
            emptyNode:setPosition(320+55+98*(i-3-1), 2)
        end
        
        local lockTexture = CSResourceMgr.seekNodeByName(emptyNode,"locked")
        lockTexture:setVisible(i > maxPetCount)
        
        CSResourceMgr.clickEventBindingByNode(emptyNode,function(sender)
            local _i = 1
            for k,v in pairs(LtPetsMgr.LtEmptyPetNodes) do
                if v == sender then
                    _i = k
                end
            end
            
            if _i > maxPetCount then return end
            
            circle:setVisible(true)
            if _i <= 3 then
                circle:setContentSize(96, 118)
                circle:setPosition(55+98*(_i-1),2)
            else
                circle:setContentSize(98, 118)
                circle:setPosition(320+55+98*(_i-3-1),2)
            end
            LtPickPetViewMgr.show(CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,"petPickingOrder"),_i,0)
        end)
        table.insert(LtPetsMgr.LtEmptyPetNodes, emptyNode)
    end
    

    local BattleFuncMgr = require("src.GameMgr.Battle.BattleFuncMgr")
    
    -- 宠物卡片
    LtPetsMgr.LtArmyPetNodes = {}
    for i=1, pet_num do
        local petInfo = clone( PokemonInfo.getPetInfoByObjID(LtPetsMgr.LtArmy[i]) )
        petInfo.hp = LtPetsMgr.getHpByObjID(LtPetsMgr.LtArmy[i])
        
        local p
        if i <= 3 then
            p = BattleFuncMgr.startCreatePetCard(petInfo, 1)
            p.button:setPosition(55+98*(i-1),2)
        else
            p = BattleFuncMgr.startCreatePetCard(petInfo, 2)
            p.button:setPosition(320+55+98*(i-3-1),2)
        end
        petList:addChild(p.button)
        p.button:setAnchorPoint(0.5,0.0)
        
        if petInfo.hp <= 0 then
            p.button:setColor({r=130,g=130,b=130,a=255})
        end

        LtPickPetViewMgr.bindPetNodeEvent(p.button)
        
        CSResourceMgr.setButtonEnabledByNode(LtPetsMgr.LtEmptyPetNodes[i], false)
        
        table.insert(LtPetsMgr.LtArmyPetNodes, p.button)
    end
    
    LtPetsMgr.LtHelpArmyNodes = {}
    for i=1, help_pet_num do
        local petInfo = clone( PokemonInfo.getPetInfoByObjID(LtPetsMgr.LtHelpArmy[i]) )
        petInfo.hp = LtPetsMgr.getHpByObjID(LtPetsMgr.LtHelpArmy[i])
        
        local p
        p = BattleFuncMgr.startCreatePetCard(petInfo, 2)
        p.button:setPosition(320+55+98*(i-1),2)
        LtPickPetViewMgr.setHelpPetCard(p.button)
        
        petList:addChild(p.button)
        p.button:setAnchorPoint(0.5,0.0)

        if petInfo.hp <= 0 then
            p.button:setColor({r=130,g=130,b=130,a=255})
        end

        LtPickPetViewMgr.bindPetNodeEvent(p.button)

        CSResourceMgr.setButtonEnabledByNode(LtPetsMgr.LtEmptyPetNodes[3+i], false)

        table.insert(LtPetsMgr.LtHelpArmyNodes, p.button)
    end
    
    circle:removeFromParent()
    petList:addChild(circle)
    
    BattleFuncMgr.endCreatePetCard()
    
--    LtPropMgr.resetAllProps()
    
    LtExBufferMgr.initBuffList()

    LtPropMgr.setPickedProps()
    
    LostTowerUIMgr.setMenuButton()
end

function LostTowerUIMgr.showPotentialSkill(parent, pSkill, tag, pos, showDB)
    if not parent then return end

    local resName = "LostTower/Others/potentialSkill.csb"
    
    local sp = CSResourceMgr.createRes(parent,resName,tag)
    sp:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
    local skill = CSResourceMgr.getNodeByName(resName,"skill",tag)
    if pos then
        skill:setPosition(pos.x, pos.y)
    end

    if pSkill.info then
        CSResourceMgr.getNodeByName(resName, "skill", tag):setVisible(true)
        local icon = CSResourceMgr.getNodeByName(resName, "skillicon", tag)
        local iconRes = "Battle/skillIcon/"..pSkill.info.icon
        icon:setScale(0.5)
        CSResourceMgr.setSpriteTextureByNode(icon, iconRes)
        CSResourceMgr.clickEventBinding(resName, "skill", function()
            AchievementListMgr.showSkillInfo(pSkill.info, false, false, nil)
        end, tag, 3)
        local skillLv = CSResourceMgr.getNodeByName(resName, "skilllevel", tag)
        CSResourceMgr.setLabelColorByNode(skillLv, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(skillLv, "Lv"..pSkill.level, {r=0,g=0,b=0,a=255})
        
        CSResourceMgr.getNodeByName(resName, "skdb", tag):setVisible(showDB)
        CSResourceMgr.setButtonEnabled(resName,"skill",showDB,tag)
    else
        CSResourceMgr.getNodeByName(resName, "skill"):setVisible(false)
    end
end

function LostTowerUIMgr.removeAllAnimation()
    SearchingUIMgr.removeAllMonsterAni()
    --AdvCharMgr.resetTrainers()

    PlayerAnimeMgr.removeAllPlayer()
    
    for _,v in pairs(AdvCharMgr.getTrainers()) do
        if v.info.handle then
            local scheduler = require("framework.scheduler")
            scheduler.unscheduleGlobal(v.info.handle)
            v.info.handle = nil
        end
        v.info.node:removeFromParent()
    end
    AdvCharMgr.cleatTranerTable()
    
--    LtPlayerMgr.removePlayer()
--    AnimationMgr.removeGafObjectByTag("Gaf/Searching/exit.gaf","exit-ani")

    for i = 1, #LostTowerUIMgr.LtAniTable do
        local obj = LostTowerUIMgr.LtAniTable[i]
        -- print(obj.res, obj.tag)
        if obj.res then
            AnimationMgr.removeGafObjectByTag(obj.res, obj.tag)
        end
    end
    LostTowerUIMgr.LtAniTable = {}
    
    LtEventOption.removeAllEventAni()
    
    LtWarFogMgr.clear()
    
    LtPropMgr.removeShadowNode()
end

function LostTowerUIMgr.AddUI(scene)
    local advNodePool = require("src.GameMgr.Searching.advNodePool")

    LostTowerUIMgr.eventNodePool = advNodePool.create()
    LostTowerUIMgr.tileNodePool  = advNodePool.create()

    local LtMapNodeMgr = require("src.GameMgr.LostTower.LtMapNodeMgr")
    LtMapNodeMgr.CreateMapWithSize(scene,LostTowerUIMgr.centerResName)

    local function initSlab()
        local groundRes = AdvEnvironmentMgr.makePath("dz1")
    
        for i=1, LtMapOption.getMapSize() do
            local etype = SearchingMgr.eventInfoTable[i]
            local b_node = LtMapNodeMgr.getBlockNode(i)
            local zorder = SearchingUIMgr.calcZOrderAt(i)
            b_node:setLocalZOrder( zorder ) --物品Z軸
            
            local g_node = LtMapNodeMgr.getGroundNode(i)
            local img = groundRes  -- "Searching/env/ysd/dz1.png"
            CSResourceMgr.setButtonTextureByNode(g_node,  img,  img,  img)
            
            local b_node = LtMapNodeMgr.getBlockNode(i)
            local img_b = "Searching/empty.png"
            CSResourceMgr.setButtonTextureByNode(b_node, img_b, img_b, img_b)
            
            if 0 == SearchingMgr.mapInfoTable[i] then
                LtEventOption.createEvent(i)
            end
            if 1 == SearchingMgr.mapInfoTable[i] then
            end
            if SearchingMgr.mapInfoTable[i] == 2 then
                if SearchingMgr.monsterDefendInfo[i] > 0 then 
                    SearchingUIMgr.monsterLock(i)
                else
                    SearchingUIMgr.coverSlab(i)
                end
            end
        end
    end
    
    initSlab()

    LostTowerUIMgr.setTop(scene)
    
    LostTowerUIMgr.setCenter(scene)

    LostTowerUIMgr.setBottom(scene)

    LtPlayerMgr.initPlayer()
    
    LostTowerUIMgr.setWarFog()
    LostTowerUIMgr.showNearBy()
    
    local scrollview = CSResourceMgr.getNodeByName(LostTowerUIMgr.centerResName,"fog")
    DungeonMapMgr.scrollMapWithCellID(scrollview, SearchingMgr.playerCurrPosition)
end

function LostTowerUIMgr.hide()
    if globalhandler then
        local scheduler = require("framework.scheduler")
        scheduler.unscheduleGlobal(globalhandler)
    end
end

--- 功能菜单按钮设置
function LostTowerUIMgr.setMenuButton()
    local c0 = {r=0,g=0,b=0,a=255}
    local c1 = {r=254,g=250,b=175,a=255}
    
    local strings = {
        "LtMenu1",
        "LtMenu2",
        "LtMenu3",
        "LtMenu4",
    }
    for i=1, #strings do
        local cellName = {"menu_db","menu"..i,"menu_t"..i}
        CSResourceMgr.setLabelColor(LostTowerUIMgr.bottomResName,cellName,c1)
        CSResourceMgr.setLabelString(LostTowerUIMgr.bottomResName,cellName,strings[i],"",c0,nil,80)
        
        CSResourceMgr.clickEventBinding(LostTowerUIMgr.bottomResName,{"menu_db","menu"..i},function()
            print("menu"..i)
            if i == 1 then     -- heal
                LtHealViewMgr.show(SceneMgr.getRunningScene)
            elseif i == 2 then -- transfer
                if LostTowerMgr.recordingPoint == 1 then
                    StandardTipsMgr.show(1, "LtTips21")  -- "尚未开通任何传送点"
                    return
                end
                LtTransferViewMgr.show(SceneMgr.getRunningScene)
            elseif i == 3 then -- rank
                if not NetInterface.isConnect then return end
                NetInterface.sendWithBlock("GC_QUERYFLOORRANK_ACK",function()
                    local LostTowerSend = require("src.Net.Send.LostTowerSend")
                    LostTowerSend.sendCG_QueryFloorRank_Req()
                end,function()
                    NetInterface.sendWithBlock("GC_QUERYPOINTRANK_ACK",function()
                        local LostTowerSend = require("src.Net.Send.LostTowerSend")
                        LostTowerSend.sendCG_QueryPointRank_Req()
                    end,function()
                        LtRankingViewMgr.showNew(SceneMgr.getRunningScene)
                    end,function(code)
                    end)
                end,function(code)
                end)
            elseif i == 4 then -- shop
--                if not NetInterface.isConnect then return end
--                NetInterface.sendWithBlock("GC_GETSHOP_ACK",function()
--                    local CommonShopSend = require("src.Net.Send.CommonShopSend")
--                    CommonShopSend.sendCG_getShop_Req({type = 3,})
--                end,function()
--                    local offsetTime = 3600 * 24  --SystemInfo.getGlobalConfigAddInfoByID(33).values[1]
--                    local dayDiff = CocosModuleMgr.getDayTimeDiff(LtExchangeViewMgr.shopResetTime, CharInfo.getServerTime(), offsetTime)
--                    if dayDiff ~= 0 then
--                        NetInterface.sendWithBlock("GC_RESETSHOP_ACK",function()
--                            local CommonShopSend = require("src.Net.Send.CommonShopSend")
--                            CommonShopSend.sendCG_ResetShop_Req({type = 3,})
--                        end,function()
--                            LtExchangeViewMgr.shopResetTime = CharInfo.getServerTime()
--                            LtExchangeViewMgr.show(SceneMgr.getRunningScene)
--                        end)
--                    elseif dayDiff == 0 then
--                        LtExchangeViewMgr.show(SceneMgr.getRunningScene)
--                    end
--                end,function()
--                end)
                LtExchangeViewMgr.callLTShop()
            end
        end,"",2)
    end
end

return LostTowerUIMgr