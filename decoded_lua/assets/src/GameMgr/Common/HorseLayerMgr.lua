local HorseLayerMgr = {}

local resName = ""
local messageTable = {}
local speed = 30
local haveHorse = false
local lastTime = 0
local curMessagePos = 1

function HorseLayerMgr.Init()
    print("HorseLayerMgr初始化")
    resName = "Charactor/horseView.csb"
    messageTable = {}
    haveHorse = false
    lastTime = nil
    curMessagePos = 1
end

function HorseLayerMgr.showMsg()
    local scene = SceneMgr.getRunningScene
    if not CSResourceMgr.getCsbObj(resName) then
        local diff = CocosModuleMgr.getScreenSizeDiff()
        local layer = CSResourceMgr.createRes(scene, resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_MSGBOX)
        if diff < 0 then 
            diff = 0
        end
        CSResourceMgr.setRelativePosition(resName, 320, 430+diff)

        CSResourceMgr.getNodeByName(resName,"Up"):setOpacity(0)

        haveHorse = "hide"

        HorseLayerMgr.playMsg(1)
    elseif haveHorse == "hide" then
        HorseLayerMgr.playMsg(1)
    end
end

function HorseLayerMgr.addMsg(message)
    local findPos = true
    for i=curMessagePos,#messageTable do
        if messageTable[i][2] then
            curMessagePos = i
            findPos = false
            break
        end
    end
    if findPos then
        curMessagePos = #messageTable + 1
    end
    table.insert(messageTable, curMessagePos, {message,false})
    HorseLayerMgr.showMsg()
end

function HorseLayerMgr.addMsg2(message)
    local begin, finish = string.find(message, "%b{}")
    if begin and finish then
        local rep = string.sub(message, begin, finish)
        local id = string.sub(message, begin+1, finish-1)
        local petData = PokemonInfo.getPokemonInfoByID(tonumber(id))
        local name = petData.name
        local rank = ""
        if petData.rarePoint == 4 then
            rank = LuaSqlite.LANG_TYPE ~= 1 and "S " or "S"
        elseif petData.rarePoint == 5 then
            rank = LuaSqlite.LANG_TYPE ~= 1 and "SS " or "SS"
        end
        message = string.gsub(message, rep, rank..LuaSqlite.getLanguageByKey(name))
        table.insert(messageTable, {message,true})
        HorseLayerMgr.showMsg()
    end
    begin, finish = string.find(message, "%b[]")
    if begin and finish then
        local rep = string.sub(message, begin, finish)
        local id = string.sub(message, begin+1, finish-1)
        local itemInfo = ItemInfo.getItemInfoById(tonumber(id))
        local name = itemInfo.name
        message = string.gsub(message, id, LuaSqlite.getLanguageByKey(name))
        table.insert(messageTable, {message,true})
        HorseLayerMgr.showMsg()
    end
end

function HorseLayerMgr.playMsg(i)
    local Panel = CSResourceMgr.getNodeByName(resName,"Panel")
    local Up = CSResourceMgr.getNodeByName(resName,"Up")
    if haveHorse and haveHorse == "hide" then
        transition.fadeIn(Up, {time = 0.1})
        haveHorse = "show"
    end

    local label = CSResourceMgr.getNodeByName(resName,"label"):clone()
    label:addTo(Panel)
    label:setPosition(640, 22.5)
    label:setString(messageTable[i][1])
    curMessagePos = i+1
    CSResourceMgr.setLabelColorByNode(label, {r=255,g=226,b=0,a=255})
    label:setFontSize(20)
    local width = label:getContentSize().width
    local time = width/speed
    transition.moveTo(label, {x = -width, time = time})
    label:performWithDelay(function()
        if messageTable[i+1] then
            HorseLayerMgr.playMsg(i+1)
        else
            messageTable = {}
            haveHorse = "hide"
            transition.fadeOut(Up, {time = 0.1})
            curMessagePos = 1
        end
    end,time+1)
end

return HorseLayerMgr