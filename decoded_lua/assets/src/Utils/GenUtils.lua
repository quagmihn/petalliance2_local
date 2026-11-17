local GenUtils = {}

function GenUtils.printTable(tb, tag, limit)

    tag = tag or "Table"
    if (type(tb) == "table") then
        GenUtils.printTableImp(tag .. ": ", tb, 0, limit)
    else
    	print(tag, ": ", tb)
    end

end

function GenUtils.printTableImp(key, val, deep, limit)

    if (nil ~= limit and deep > limit) then
        return
    end

	local blank = ""
    for i = 1, deep do
        blank = blank .. "  "
    end

    if (type(val) == "table") then
        if ("class" == key and nil ~= val.__cname) then
            print(blank .. key .. " = " .. val.__cname)
        else
            print(blank .. key .. " = ")
            for k, v in pairs(val) do
                GenUtils.printTableImp(k, v, deep + 1, limit)
            end
        end
    elseif (type(val) == "userdata") then
        print(blank .. key .. " = " .. tolua.type(val))
    elseif (type(val) == "function") then
        print(blank .. key .. " = function")
    elseif (type(val) == "boolean") then
        if (val) then
            print(blank .. key .. " = true")
        else
            print(blank .. key .. " = false")
        end
    else
        print(blank .. key .. " = " .. val)
    end

end

function GenUtils.creatEnum(tbl) 
    
    if type(tbl) ~= "table" then
        return nil
    end

    local ret = {} 
    for i, v in ipairs(tbl) do 
        ret[v] = i 
    end 
    return ret

end

function GenUtils.splitString(str, splitter)

    local ret = {}
    splitter = splitter or ","

    local i = 0
    while true do
        local pos = string.find(str, splitter, i + 1)
        if nil == pos then
            table.insert(ret, string.sub(str, i + 1))
            break
        end
        table.insert(ret, string.sub(str, i + 1, pos - 1));
        i = pos;
    end

    return ret;

end

function GenUtils.sleep(second)

    require("socket")
    socket.select(nil, nil, second)

end


-----yhq方法华丽分割线-----

function GenUtils.initPreloadTextureCache()
    local function PA( path )
        HDPreloadTextureCache:sharedPreloadTextureCache():preloadImage(path)
    end
    
    local arr = {
        "dialogs/general/diban.png",    --大地板
        "general/transparent.png",  --空图片
        "dialogs/petcompose/xuanzechongwukuang.png", --选择宠物框
        "dialogs/pethandbook/shu.png", --图鉴中的书
        "dialogs/general/zuo.png",  --左底板
        "dialogs/general/you.png",  --右底板
        "dialogs/general/kuang.png", --九宫格notice底框
        "petinfo/petportrait/border.png", --精灵头像金边
    }
    for i=1, #arr, 1 do
        PA(arr[i])
    end
end

--获取年、月、日
function GenUtils.getDateStringByYMD(dateTime)
    local date = require("Utils.HDTime").getDateTable(dateTime)
    return date.year.."-"..date.month.."-"..date.wday
end

function GenUtils.getStringByPropertyID(propertyID)
    local arr = {"攻击","生命","防御","魔力","速度","暴击","格挡","闪避","属性ID最大值"}
    return arr[propertyID+1]
end 

function GenUtils.getPackItemCount(itemID, packageType)
    local count = 0
    pi = require("Data.PackInfo").getPackInfoList(packageType)
    for i=1, #pi, 1 do
        if pi[i].itemID == itemID then
            count = count + pi[i].count
        end
    end
    return count
end

--设置经验条的动画
    --bar：   经验条的实例
    --newPer：最后停留的百分比
    --skipLv：提升的等级段数量
function GenUtils.setBarLoopAction(bar, newPer, skipLv)
    local curPer = bar:getPercent()
    local actionList = {}
    actionList[1] = "seq"
    for i=1, skipLv, 1 do
        -- print("add"..i)
        actionList[#actionList+1] = { "call", function() bar:setPercent(100, true) end }
        local delay = 2
        if i==1 then
            delay = 2*(100-curPer)/100
        end
        actionList[#actionList+1] = { "delay", delay }  
        actionList[#actionList+1] = { "call", function() bar:setPercent(0, false) end }
    end
    actionList[#actionList+1] =  { "call", function() bar:setPercent(newPer, true) end }
    local action = require("Utils.ActionBuilder").build(actionList)
    bar:runAction(action)
end

function GenUtils.checkIsCashEnough(cashType, num)  --parseCharacterBaseInfo
    --Proto.COST_TYPE_G
    --Proto.COST_TYPE_M
    --Proto.COST_TYPE_CREDIT_CARD
    local GenInfo = require("Data.GenInfo")
    local cash
    if  cashType==Proto.COST_TYPE_G then
        cash = GenInfo.getMyBaseInfo().g_cash
    elseif cashType==Proto.COST_TYPE_M then
        cash = GenInfo.getMyBaseInfo().m_cash
    end

    if cash and cash<num then
        return false
    end
    return true
end

function GenUtils.setImgGreyState(obj)
    -- local scale = obj:getScale()
    -- local visible = obj:isVisible()
    -- local zOrder = obj:getZOrder()

    -- local oldHadSp = obj
    -- local newHeadSp = CCGraySprite:createWithTexture(oldHadSp:getTexture(),oldHadSp:getTextureRect())
    -- newHeadSp:setPosition(obj:getPosition())
    -- newHeadSp:setAnchorPoint(obj:getAnchorPoint())

    -- if obj:getParent() ~= nil then
    --     obj:getParent():addChild(newHeadSp,1000000000)
    --     obj:removeFromParent()
    --     obj = newHeadSp
    -- end

    -- newHeadSp:setVisible(visible)
    -- newHeadSp:setScale(scale)
    -- newHeadSp:setZOrder(zOrder)
    obj:setShaderProgram(GenUtils.getGreyShaderProgram())
end

function GenUtils.getGreyShaderProgram()

    if g_grayProgram == nil then
        local sp = CCSprite:create("general/1x1.png")
        local spgrey = CCGraySprite:createWithTexture(sp:getTexture(),sp:getTextureRect())
        g_grayProgram = spgrey:getShaderProgram()
        g_grayProgram:retain()
    end

    return g_grayProgram

end


--改变数组中的位置
function GenUtils.changeChildAt(list, needChangeIdx, newIdx)
    if needChangeIdx>newIdx then
        local t = list[needChangeIdx]
        for i=needChangeIdx, newIdx+1, -1 do
            list[i] = list[i-1]
        end
        list[newIdx] = t
    elseif needChangeIdx<newIdx then
        local t = list[needChangeIdx]
        for i=needChangeIdx, newIdx-1, 1 do
            list[i] = list[i+1]
        end
        list[newIdx] = t
    end
end

--获取通用的界面DELAY时间
function GenUtils.getDialogDelay()
    return 0.4
end

--连接数组
function GenUtils.concatTable(a, b)
    local list = {}
    for i=1, #a, 1 do
        list[#list+1] = clone(a[i])
    end
    for i=1, #b, 1 do
        list[#list+1] = clone(b[i])
    end
    return list 
end

--获取距离两个时间的天数差
function GenUtils.getDistanceDaysToNow(lastTime)
    local HDTime = require("Utils.HDTime")

    if not lastTime then
        return 0 
    end
    local curDay = math.floor( HDTime.getCurTime()/24/3600 )
    local lastDay = math.floor( lastTime/24/3600 )

    return curDay-lastDay
end

return GenUtils