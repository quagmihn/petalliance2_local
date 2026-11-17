local AdvStarMgr = {}

AdvStarMgr.STAR_MAX = 3

AdvStarMgr.currAdvMissions = {}

local isMissionShown = true
local resName = "Searching/MissionUI/starBoard.csb"

local starRecord        = 0
local starRecordBstring = "0000"  --二进制字符串星数记录
local starRecordBtable  = {0,0,0,0}
local clearedStarNum    = 0   -- 本次完成星数
local lastClearedNum    = 0   -- 历史完成星数
local lastClearedStars  = {}

---星数记录转换为二进制字符串
local function d2b(x)
    local str = ""
    while x ~= nil and x ~= 0 do
        local i = x % 2
        str = i..str
        x = math.floor(x / 2)
    end
    return str
end

---星数记录转换为二进制形式存储的table
local function d2bt(x)
    local bt = {}
    local num = 0
    while x ~= 0 do
        local i = x % 2
        table.insert(bt,i)  --最低位开始
        x = math.floor(x / 2)
    end
    for i=#bt+1,4 do bt[i]=0 end
    return bt
end

local function bt2b(bt)
    local x = 0
    for i = 1, 3 do
        x = x + bt[i] * 2^(i - 1)
    end
    return x
end

function AdvStarMgr.Init()
    starRecord       = 0
    clearedStarNum   = 0
    lastClearedNum   = 0
    lastClearedStars = {}
    starRecordBstring = "0000"
    
    AdvStarMgr.currAdvMissions = {}
end

function AdvStarMgr.addMissionUI(scene)

    local curLayer = CSResourceMgr.createRes(scene, resName)
    CocosModuleMgr.setRelativePosition(curLayer, 320, 480)
    curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
    
    local adhLabel = CSResourceMgr.getNodeByName(resName,{"db","banner","title"})
    CSResourceMgr.setLabelStringByNode(adhLabel,"advtext1")
    adhLabel:enableOutline({r=153,g=0,b=0,a=255}, 2)
    adhLabel:setTextColor({r=255,g=255,b=204,a=255})
    adhLabel:setFontSize(32)
    
    CSResourceMgr.setLabelString(resName,{"db","tip"},"advtext9")
    
    CSResourceMgr.clickEventBinding(resName,"block",function()
        AdvStarMgr.hideMission()
    end, "", true)
    
    AdvStarMgr.setMission()
    
--    if isMissionShown then
--        AdvStarMgr.showMission()
--    else
--        AdvStarMgr.hideMission()
--    end
    
    -- hide mission board
    isMissionShown = false
    CSResourceMgr.getNodeByName(resName,"db"):setVisible(false)
    CSResourceMgr.getNodeByName(resName,"block"):setVisible(false)
    
end

function AdvStarMgr.getIsShown()
    return isMissionShown
end
function AdvStarMgr.setIsShown(isShown)
    isMissionShown = isShown
end

function AdvStarMgr.showMission()
    UIStack.push("AdvStarMgr",AdvStarMgr.hideMission)

    GameAudio.playUISound("ok")

    isMissionShown = true
    local node = CSResourceMgr.getNodeByName(resName,"db")
    node:setVisible(true)
    CSResourceMgr.getNodeByName(resName,"block"):setVisible(true)
    CocosModuleMgr.showUIAnimation(node, "down")
end
function AdvStarMgr.hideMission()
    UIStack.pop("AdvStarMgr")

    GameAudio.playUISound("back")

    isMissionShown = false
    CSResourceMgr.getNodeByName(resName,"db"):setVisible(false)
    CSResourceMgr.getNodeByName(resName,"block"):setVisible(false)
end
function AdvStarMgr.hideMissionForce()
    isMissionShown = false
    CSResourceMgr.getNodeByName(resName, "msboard"):setPosition(-250,128)
end

function AdvStarMgr.setMission()
    CSResourceMgr.getNodeByName(resName, {"db","diban","msboard","list"}):removeAllItems()

    local mTbl = {
        {name="ゴール", desc=SearchingMapMgr.GoalTable["goal1"].desc},
        {name="ゴール", desc=SearchingMapMgr.GoalTable["goal2"].desc},
        {name="ゴール", desc=SearchingMapMgr.GoalTable["goal3"].desc},
    }

    for key, var in pairs(mTbl) do
        
        if var.desc == nil then 
            print("ADV_ERROR: Check if [Fbmb.txt] is correct")
            break 
        end
        print(var.desc, LuaSqlite.getLanguageByKey(var.desc))
    
        local color = {r=71, g=96, b=103, a=255}
        CSResourceMgr.setLabelString(resName, {"example", "desc"}, var.desc, "", {r=218,g=232,b=232,a=255,w=2})

        local list = CSResourceMgr.getNodeByName(resName, {"db","diban","msboard","list"})
        local item = CSResourceMgr.getNodeByName(resName, "example"):clone()
        local text = CSResourceMgr.seekNodeByName(item, "desc")

        text:setTextColor(color)
        --text:setFontSize(36)  --cocos studio中设置统一字号
        item:setVisible(true)
        CSResourceMgr.getNodeByName(resName, {"db","diban","msboard","list"}):pushBackCustomItem(item)
    end
end

function AdvStarMgr.getCrowne(i)
    local clearedNum = AdvStarMgr.getClearedStarNum()
    
    local resName = "Searching/MissionUI/starBoard.csb"
    local items = CSResourceMgr.getNodeByName(resName, {"db","diban","msboard","list"}):getItems()
    
    local val = items[i]
    val:loadTexture("UI/CommonFiles/ranking_substrate_gold_su.png")
    CSResourceMgr.seekNodeByName(val,"star"):loadTexture("Searching/Common/cj_xing0001.png")
    CSResourceMgr.seekNodeByName(val,"clearFlag"):setVisible(true)
    CSResourceMgr.seekNodeByName(val,"db1"):setColor({r=211,g=156,b=5,a=255})

    local label = CSResourceMgr.seekNodeByName(val,"desc")
    label:setTextColor({r=255,g=255,b=255,a=255})
    label:enableOutline({r=128,g=71,b=23,a=255},2)
    
    local star = CSResourceMgr.getNodeByName(SearchingUIMgr.topResName,"star"..clearedNum)
    star:setVisible(true)
    star:setOpacity(255)  --实亮
end

function AdvStarMgr.loseCrowne(i)
    local clearedNum = AdvStarMgr.getClearedStarNum()

    local resName = "Searching/MissionUI/starBoard.csb"
    local items = CSResourceMgr.getNodeByName(resName, {"db","diban","msboard","list"}):getItems()
    
    
    local lastClearedStars = AdvStarMgr.getLastClearedStars()
    if lastClearedStars[i] then
        CSResourceMgr.seekNodeByName(items[i],"star"):loadTexture("Searching/Common/cj_xing0001.png")
    else
        CSResourceMgr.seekNodeByName(items[i],"star"):loadTexture("Searching/Common/cj_xing0002.png")
    end
    CSResourceMgr.seekNodeByName(items[i],"clearFlag"):setVisible(false)
    items[i]:loadTexture("UI/CommonFiles/ranking_substrate_normal_su.png")
    CSResourceMgr.seekNodeByName(items[i],"db1"):setColor({r=128,g=161,b=172,a=255})
    
    local label = CSResourceMgr.seekNodeByName(items[i],"desc")
    label:setTextColor({r=71, g=96, b=103, a=255})
    label:enableOutline({r=218,g=232,b=232,a=255},2)
    
    local star = CSResourceMgr.getNodeByName(SearchingUIMgr.topResName,"star"..(clearedNum+1))
    star:setVisible(false)
    star:setOpacity(255)  --实亮
    
    local bt = d2bt(AdvStarMgr.getStarRecord())
    bt[i] = 0 
    AdvStarMgr.setStarRecords(bt2b(bt))
end

function AdvStarMgr.refreshMissionUI()
    local items = CSResourceMgr.getNodeByName(resName, {"db","diban","msboard","list"}):getItems()
    
    for i = 1, AdvStarMgr.STAR_MAX do
        CSResourceMgr.getNodeByName(SearchingUIMgr.topResName,"star"..i):setVisible(false)
    end
    local lastClearedStars = AdvStarMgr.getLastClearedStars()
    for i=1, #lastClearedStars do
        if lastClearedStars[i] then
            CSResourceMgr.seekNodeByName(items[i],"star"):loadTexture("Searching/Common/cj_xing0001.png")
        else
            CSResourceMgr.seekNodeByName(items[i],"star"):loadTexture("Searching/Common/cj_xing0002.png")
        end
    end
    for i=1, AdvStarMgr.STAR_MAX do
        CSResourceMgr.seekNodeByName(items[i],"clearFlag"):setVisible(false)
        items[i]:loadTexture("UI/CommonFiles/ranking_substrate_normal_su.png")
        CSResourceMgr.seekNodeByName(items[i],"db1"):setColor({r=128,g=161,b=172,a=255})
        local label = CSResourceMgr.seekNodeByName(items[i],"desc")
        label:setTextColor({r=71, g=96, b=103, a=255})
        label:enableOutline({r=218,g=232,b=232,a=255},2)
    end

    local starNum = 0
    
    local _advId = SearchingMapMgr.currAdventure
    local starRecord = (AdventureInfo.getFinishedByID(_advId) ~= nil) and AdventureInfo.getFinishedByID(_advId).star or 0
    AdvStarMgr.setStars({},starRecord,nil,nil)
    
    for key, val in pairs(items) do
        if SearchingMapMgr.GoalTable["goal"..key].clear then
            if not val.clear_b then AdvStarMgr.setStarRecordByKey(key) end
            AdvStarMgr.updateClearedStarNum(1)
        
            starNum = starNum + 1
            local star = CSResourceMgr.getNodeByName(SearchingUIMgr.topResName,"star"..starNum)
            star:setVisible(true)
            star:setOpacity(255)  --实亮

            val:loadTexture("UI/CommonFiles/ranking_substrate_gold_su.png")
            CSResourceMgr.seekNodeByName(val,"star"):loadTexture("Searching/Common/cj_xing0001.png")
            CSResourceMgr.seekNodeByName(val,"clearFlag"):setVisible(true)
            CSResourceMgr.seekNodeByName(val,"db1"):setColor({r=211,g=156,b=5,a=255})

            local label = CSResourceMgr.seekNodeByName(val,"desc")
            label:setTextColor({r=255,g=255,b=255,a=255})
            label:enableOutline({r=128,g=71,b=23,a=255},2)
        end
    end
end

---更新成就UI
function AdvStarMgr.updateMissionUI(initFlag)
    initFlag = initFlag or false
    local resName = "Searching/MissionUI/starBoard.csb"
    local items = CSResourceMgr.getNodeByName(resName, {"db","diban","msboard","list"}):getItems()
    local starNum = 0 
    local clearedNum = AdvStarMgr.getClearedStarNum()
    local img = "Searching/Common/tn_x0001.png"   --亮态

    if initFlag then
        for key, val in pairs(SearchingMapMgr.GoalTable) do
            local _goal = tonumber(val.goal)
            if _goal <= 0 then
                if val.count <= math.abs(_goal) then
                    if not val.clear then
                        val.clear = true
                        if not val.clear_b then AdvStarMgr.setStarRecordByKey(key) end
                        AdvStarMgr.updateClearedStarNum(1)
                    end
                end
            end
        end
    
        local lastClearedStars = AdvStarMgr.getLastClearedStars()
        for i=1, #lastClearedStars do
            if lastClearedStars[i] then
                CSResourceMgr.seekNodeByName(items[i],"star"):loadTexture("Searching/Common/cj_xing0001.png")
            end
        end
        for i=1, AdvStarMgr.STAR_MAX do
            CSResourceMgr.seekNodeByName(items[i],"clearFlag"):setVisible(false)
            items[i]:loadTexture("UI/CommonFiles/ranking_substrate_normal_su.png")
            CSResourceMgr.seekNodeByName(items[i],"db1"):setColor({r=128,g=161,b=172,a=255})
        end
    end

    for key, val in pairs(items) do
        if SearchingMapMgr.GoalTable["goal"..key] and SearchingMapMgr.GoalTable["goal"..key].clear then
            starNum = starNum + 1
            local star = CSResourceMgr.getNodeByName(SearchingUIMgr.topResName,"star"..starNum)
            star:setVisible(true)
            star:setOpacity(255)  --实亮
            --topbar星星效果
            if starNum == clearedNum and not initFlag then   --最新一颗星才有动效, 初始化时无动效
                local scaleto_1_2 = cc.ScaleTo:create(0.1, 1.2)
                local scaleto_1_0 = cc.ScaleTo:create(0.1, 1.0)
                star:runAction(cc.Sequence:create(scaleto_1_2, scaleto_1_0))
            end
            
            val:loadTexture("UI/CommonFiles/ranking_substrate_gold_su.png")
            CSResourceMgr.seekNodeByName(val,"star"):loadTexture("Searching/Common/cj_xing0001.png")
            CSResourceMgr.seekNodeByName(val,"clearFlag"):setVisible(true)
            CSResourceMgr.seekNodeByName(val,"db1"):setColor({r=211,g=156,b=5,a=255})
            
            local label = CSResourceMgr.seekNodeByName(val,"desc")
            label:setTextColor({r=255,g=255,b=255,a=255})
            label:enableOutline({r=128,g=71,b=23,a=255},2)
        end
    end
end


--++++++++++    TOPBAR    ++++++++++++++

---return last cleared star num
function AdvStarMgr.getLastClearedNum()
    return lastClearedNum
end

function AdvStarMgr.getLastClearedStars()
    return lastClearedStars
end

---return the cleared star num of this time
function AdvStarMgr.getClearedStarNum()
    return clearedStarNum
end

function AdvStarMgr.updateClearedStarNum(added)
    clearedStarNum = clearedStarNum + added
end

---all star clear, set
function AdvStarMgr.setStarRecords(record)
    starRecord = record or 0
    starRecordBstring = d2b(starRecord)
    starRecordBtable = d2bt(starRecord)
end

---星数记录获取  ，二进制数存储
function AdvStarMgr.getStarRecord()
    return starRecord
end

---设置星数二进制字符串
function AdvStarMgr.setStarRecordBstring(_string)
    starRecordBstring = _string
end

---获取星数二进制字符串
function AdvStarMgr.getStarRecordBstring()
    return starRecordBstring
end

---星数二进制table获取
function AdvStarMgr.getStarRecordBtable()
    return starRecordBtable
end

---star clear, set
function AdvStarMgr.setStarRecordByKey(key)
    local i = tonumber(string.sub(key,-1))
    if string.sub(starRecordBstring, -i, -i) ~= "1" then
        starRecord = starRecord + math.ldexp(1.0, i-1)
        starRecordBstring = d2b(starRecord)
    end

    print("AdvStarMgr.setStarRecord:", starRecord)
    print("AdvStarMgr.starRecordBstring:", starRecordBstring)

end

---获取指定任务完成情况
function AdvStarMgr.getRecordByKey(key)
    print(starRecordBstring)
    if string.sub(starRecordBstring, -key, -key) == "1" then  --1为成就完成
        return true
    end
    return false
end

--- 副本目标完成情况，包括以前完成的
function AdvStarMgr.getRecordByMissionID(id)
    for _, v in pairs(SearchingMapMgr.GoalTable) do
        if id == v.mID and (v.clear or v.clear_b) then
            return true
        end
    end
    return false
end

---副本确认弹窗，根据记录设置星数
--@param stars table star节点table
--@param img string star亮态图片
--@param imgX string star灰态图片
function AdvStarMgr.setStars(stars,starRecord,img,imgX)
    print("setstars", starRecord)
    
    AdvStarMgr.Init()
    
    --星级显示
    local bString = d2b(starRecord)
    local bTable  = d2bt(starRecord)
    local goalNum = 3  --总星数
    local _starNum = 0  --星星数
    lastClearedStars = {}
    for k=1, goalNum do
        if string.sub(bString, -k, -k) == "1" then  --1为成就完成
            _starNum = _starNum + 1
            lastClearedStars[k] = true
            if img then stars[_starNum]:loadTexture(img) end
        else
            lastClearedStars[k] = false
        end
    end
    for kk=_starNum+1, goalNum do
        if imgX then stars[kk]:loadTexture(imgX) end
    end
    --init
    lastClearedNum = _starNum
    clearedStarNum = 0 --_starNum
end

--- 根据记录计算星数
function AdvStarMgr.calcStarNum(record)
    local bString = d2b(record)
    local _starNum = 0  --星星数
    for k=1, AdvStarMgr.STAR_MAX do
        if string.sub(bString, -k, -k) == "1" then  --1为成就完成
            _starNum = _starNum + 1
        end
    end
    return _starNum
end

--- 通过副本ID获取完成星数
function AdvStarMgr.getStarNumByID(id)

    local goalNum = 3  --总星数
    
    local function calc(_id)
        local star = AdventureInfo.getFinishedByID(_id).star
        --print("~~~~~~~~~~~~~~~~~~~~~~~  getStarNumByID",_id,star)
        --星级显示
        local bString = d2b(star)
        local _starNum = 0  --星星数
        for k=1, goalNum do
            if string.sub(bString, -k, -k) == "1" then  --1为成就完成
                _starNum = _starNum + 1
            end
        end
        return _starNum
    end
    
    return calc(id)
end

--- 大地图或者取关卡星数 [id填普通关卡id]
function AdvStarMgr.getWorldMapStarNum(id)

    local advInfo = AdventureInfo.getAdventureInfoByID(id)
    if not advInfo then return end
    
    local id_prefix = {0, 10000, 20000}
    
    local config = {
        [1] = {1},
        [2] = {1,1},
        [3] = {1,1,1},
    }
    
    local difficultType = advInfo.diffcultType or 1
    
    local starNum = 0
    for i = 1, difficultType do
        local _id = id + id_prefix[i]
        local star = AdventureInfo.getFinishedByID(_id).star
        local bt = d2bt(star)
        
        if bt[4] == 1 then starNum = starNum + config[difficultType][i] end
    end
    
    return starNum, difficultType
    
end

--- 检查副本完成标记
function AdvStarMgr.checkClearFlag(id)
    local star = AdventureInfo.getFinishedByID(id).star
    local bt = d2bt(star)
    if bt[4] == 1 then return true end
    return false
end


return AdvStarMgr