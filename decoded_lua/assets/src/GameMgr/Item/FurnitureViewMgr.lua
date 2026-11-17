local FurnitureViewMgr = {}

FurnitureViewMgr.RANK_NUM = 6
FurnitureViewMgr.ROOM_WIDTH = 600
FurnitureViewMgr.GRID_WIDTH = 60
FurnitureViewMgr.START_X = 170
FurnitureViewMgr.PLACEABLE_BASELINE = 500
FurnitureViewMgr.BASELINE = 554
-- ----------------------------------------NeighborHome
FurnitureViewMgr.HIGHER_NEIGHBOR_BASELINE = 874
FurnitureViewMgr.LOWER_NEIGHBOR_BASELINE = 234

FurnitureViewMgr.NPC_SCALE = 0.8

local curTab = 1

local sceneName = ""
local resName = ""
local resNameBG = ""
local tabName = {}
local bagInfo = {}
local labelTable = {}
local firstFurniture = nil
local furnitureTable = {}
local BlockInfo = {}
local spritePlaceableArea = {}
local spriteRed = {}
local spriteBlue = {}
local ExpandLevel = 1
local PackageItemNum = 0
local FixedFurnitureNameTable = {}
local FixedFurnitureCountTable = {}
-- ----------------------------------------NeighborHome
local HigherNeighborFixedFurnitureNameTable = {}
local LowerNeighborFixedFurnitureNameTable = {}

local furnituresPool = {}
local NPC_LOCATION = {MANAGER = 350,QUEST = 530,DONATE = 950,SHOP = 1130,COPY = 1550,RESERVE1 = 1730,RESERVE2 = 2230,RESERVE3 = 2410}

function FurnitureViewMgr.Init()
    sceneName = "Map/TownMap/home_01.csb"
    resName = "Item/Bag/FurnitureView.csb"
    resNameBG = "Pet/Formation/FormationBG.csb"
    tabName = {"bag14", "bag14", "bag14", "bag14"}
    bagInfo = {}
    curTab = 1
    labelTable = {}
    firstFurniture = nil
    furnitureTable = {}
    BlockInfo = {}
    spritePlaceableArea = {}
    spriteRed = {}
    spriteBlue = {}
    ExpandLevel = 1
    PackageItemNum = 0
    FixedFurnitureNameTable = {"door_2", "tablet_2", "light_2_", "floor_3_", "floor_4_", "wall_2_"}
    FixedFurnitureCountTable = {1, 1, 4, 18, 18, 24}
    -- ----------------------------------------NeighborHome
    HigherNeighborFixedFurnitureNameTable = {"door_1", "tablet_1", "light_1_", "floor_1_", "floor_2_", "wall_1_"}
    LowerNeighborFixedFurnitureNameTable = {"door_3", "tablet_3", "light_3_", "", "floor_5_", "wall_3_"}
    
    furnituresPool = {}
    
    local diff = CocosModuleMgr.getScreenSizeDiff()
    FurnitureViewMgr.PLACEABLE_BASELINE = 500-- + (diff<0 and diff*2.66 or 0)
    FurnitureViewMgr.BASELINE = 554-- + (diff<0 and diff*2.66 or 0)
    FurnitureViewMgr.HIGHER_NEIGHBOR_BASELINE = 874-- + (diff<0 and diff*2.66 or 0)
    FurnitureViewMgr.LOWER_NEIGHBOR_BASELINE = 234-- + (diff<0 and diff*2.66 or 0)
end

function FurnitureViewMgr.refreshItemInfo()
    --从itemMgr中获取背包物品信息
    local bagItemInfo = ItemInfo.getCharItemInfo()

    local itemNum = 0
    for var=1, #tabName do
        bagInfo[var] = {}
    end
    for key, var in pairs(bagItemInfo) do
        local iteminfo = ItemInfo.getItemInfoById(key)
        local itemtid = ItemInfo.getItemType(key)
        if type(var) ~= "number" then
            --print("FurnitureItemInfo:"..sz_T2S(var).."\n")
            for objID,v in pairs(var) do
                if itemtid then
                    table.insert(bagInfo[itemtid+1], {key, v.num, v.isBand, objID})
                end
                table.insert(bagInfo[1], {key, v.num, v.isBand, objID})
                itemNum = itemNum + 1
            end
        elseif var>0 then
            --[[
            if itemtid then
                table.insert(bagInfo[itemtid+1], {key, var})
            end
            table.insert(bagInfo[1], {key, var})
            ]]--
            itemNum = itemNum + 1
        end
    end
    return itemNum
end

function FurnitureViewMgr.IsOpen()
    if CSResourceMgr.getCsbObj(resName) then
        return true
    end
    return false
end

function FurnitureViewMgr.request(scene)
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end
    GameAudio.playUISound("ok")
    FurnitureViewMgr.show(scene)
end

function FurnitureViewMgr.show(scene)
    --SceneMgr.setMapVisible(false)
    UIStack.push("FurnitureViewMgr",FurnitureViewMgr.finish,false)
    local itemNum = FurnitureViewMgr.refreshItemInfo()
    PackageItemNum = itemNum

    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG, "FurnitureViewMgr")
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "FurnitureViewMgr")
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    end

    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        curLayer:setVisible(false)

        --...
        CSResourceMgr.clickEventBinding(resName, "close", function()
            FurnitureViewMgr.hide()
        end)
        
        CSResourceMgr.clickEventBinding(resName, "finish", function()
            FurnitureViewMgr.finish()
        end)

        local diff = CocosModuleMgr.getScreenSizeDiff()
        local diban = CSResourceMgr.getNodeByName(resName, "ts_dit3")
        local dbsize = diban:getContentSize()
        diban:setContentSize(dbsize.width, dbsize.height+diff)
        local diban2 = CSResourceMgr.getNodeByName(resName, "bb_di4")
        local dbsize2 = diban2:getContentSize()
        diban2:setContentSize(dbsize2.width, dbsize2.height+(diff>0 and diff or diff*0.7))
        if diff < 0 then
            local y = diban2:getPositionY()
            diban2:setPositionY(y - diff*0.1)
            local list = CSResourceMgr.seekNodeByName(diban2,"list")
            y = list:getPositionY()
            list:setPositionY(y + diff*0.12)
            local lsize = list:getContentSize()
            list:setContentSize(lsize.width, lsize.height+diff*0.5)
        else
            local list = CSResourceMgr.getNodeByName(resName, "list")
            local lsize = list:getContentSize()
            list:setContentSize(lsize.width, lsize.height+diff)
        end
        local diban3 = CSResourceMgr.getNodeByName(resName, "ts_dit2")
        local dbsize3 = diban3:getContentSize()
        diban3:setContentSize(dbsize3.width, dbsize3.height+diff)
        --local title = CSResourceMgr.getNodeByName(resName, "title")
        --local tposy = title:getPositionY()
        --title:setPositionY(tposy+diff/2)
        local bar = CSResourceMgr.getNodeByName(resName, "bar")
        local bposy = bar:getPositionY()
        bar:setPositionY(bposy+diff/2)   
        --local close = CSResourceMgr.getNodeByName(resName, "close")
        --local cposy = close:getPositionY()
        --close:setPositionY(cposy+diff/2)
        local finish = CSResourceMgr.getNodeByName(resName, "finish")
        local fposy = finish:getPositionY()
        finish:setPositionY(fposy-diff/2)   
        CSResourceMgr.setButtonStringByNode(finish, "family148", {r=0,g=0,b=0,a=255,w=1})
        --local didang = CSResourceMgr.getNodeByName(resName, "bb_didang")
        --local dposy = didang:getPositionY()
        --didang:setPositionY(dposy-diff/2)   


        -- CSResourceMgr.setLabelString(resName, "bagsize", CocosModuleMgr.createStringWithFormat({"<1>/<2>", itemNum, 
        --     CharInfo.get().itempacketnum}))
        -- local bagSize = CSResourceMgr.getNodeByName(resName, "bagsize")
        -- bagSize:removeAllChildren()
        -- local richtext = CocosModuleMgr.createRichLabel(bagSize, CocosModuleMgr.createRichLabelString({{color="00FF00", text=itemNum},
        --     {color="FFFFFF", text="/"..CharInfo.get().itempacketnum}}), 20, "cuyuan_GBK.ttf", 640, 0, 0)
        --local bagSizeOne = CSResourceMgr.getNodeByName(resName, "bagsize1")
        --bagSizeOne:removeAllChildren()
        --CSResourceMgr.setLabelColor(resName, "bagsize1", {r=98,g=254,b=3,a=255})
        --CSResourceMgr.setLabelString(resName, "bagsize1", itemNum)

        --local bagSizeTwo = CSResourceMgr.getNodeByName(resName, "bagsize2")
        --bagSizeTwo:removeAllChildren()
        --CSResourceMgr.setLabelColor(resName, "bagsize2", {r=255,g=255,b=255,a=255})
        --CSResourceMgr.setLabelString(resName, "bagsize2", "/"..CharInfo.get().itempacketnum)
        -- CSResourceMgr.setLabelColor(resName, "bagsize", {r=255,g=255,b=255,a=255})
        --CSResourceMgr.setLabelString(resName, "title", "menu2", "", {r=38,g=54,b=76,a=255})
        --CSResourceMgr.setLabelColor(resName, "title", {r=166,g=243,b=255,a=255})
        --CSResourceMgr.setLabelString(resName, "expandbag_title", "bag5", "", {r=0,g=0,b=0,a=255})
        -- CSResourceMgr.setButtonString(resName, "expandbag", "bag6", "", {r=0,g=126,b=162,a=255})
        --[[
        CSResourceMgr.clickEventBinding(resName, "expandbag", function()
            local price = SystemInfo.getGlobalConfigAddInfoByID(6602).values[1]
            local bagnum = SystemInfo.getGlobalConfigAddInfoByID(6603).values[1]
            if price>CharInfo.getMCash() then
                TipsMgr.show(scene, "tips14")
                return
            end
            DialogBoxMgr.showSmallDialogBox(scene, 2, CocosModuleMgr.createStringWithFormat({"bag12", 
                CocosModuleMgr.createStringWithFormat({"<1><2>", price, "tips17"}), bagnum}), function()
                NetInterface.sendWithBlock("GC_BuyPacket_Ack", function()
                    local ItemSend = require("src.Net.Send.ItemSend")
                    ItemSend.sendCG_BuyPacket_Req(1)
                end, function()
                    local bagSizeOne = CSResourceMgr.getNodeByName(resName, "bagsize1")
                    bagSizeOne:removeAllChildren()
                    CSResourceMgr.setLabelColor(resName, "bagsize1", {r=98,g=254,b=3,a=255})
                    CSResourceMgr.setLabelString(resName, "bagsize1", itemNum)

                    local bagSizeTwo = CSResourceMgr.getNodeByName(resName, "bagsize2")
                    bagSizeTwo:removeAllChildren()
                    CSResourceMgr.setLabelColor(resName, "bagsize2", {r=255,g=255,b=255,a=255})
                    CSResourceMgr.setLabelString(resName, "bagsize2", "/"..CharInfo.get().itempacketnum)
                    -- CSResourceMgr.setLabelString(resName, "bagsize", CocosModuleMgr.createStringWithFormat({"<1>/<2>", 
                    --     itemNum, CharInfo.get().itempacketnum}))
                    -- local richtext = CocosModuleMgr.createRichLabel(bagSize, CocosModuleMgr.createRichLabelString({{color="00FF00", text=itemNum},
                    --     {color="FFFFFF", text="/"..CharInfo.get().itempacketnum}}), 20, "cuyuan_GBK.ttf", 640, 0, 0)

                end, function(code)
                    TipsMgr.showError(scene, code)
                end)
                end)
        end)
        ]]--

        --[[
        tabName = ItemInfo.getAllTitle()

        local selColor = {r=255,g=255,b=255,a=255}
        local selOutColor = {r=209,g=138,b=0,a=255}
        local unselColor = {r=82,g=82,b=82,a=255}
        local unselOutColor = {r=255,g=255,b=255,a=0}
        for var=1, #tabName do
            CSResourceMgr.clickEventBinding(resName, "tab"..var, function()
                CSResourceMgr.setButtonEnabled(resName, "tab"..curTab, true)
                CSResourceMgr.setLabelColor(resName, "tabt"..curTab, unselColor)
                CSResourceMgr.setLabelString(resName, "tabt"..curTab, tabName[curTab],"",unselOutColor)
                local tabbtn = CSResourceMgr.getNodeByName(resName, "tab"..curTab)
                tabbtn:setPositionY(818+diff)
                tabbtn:setScale(1, 1)
                tabbtn:setLocalZOrder(1)
                curTab = var
                CSResourceMgr.setButtonEnabled(resName, "tab"..curTab, false)
                CSResourceMgr.setLabelColor(resName, "tabt"..curTab, selColor)
                CSResourceMgr.setLabelString(resName, "tabt"..curTab, tabName[curTab],"",selOutColor)
                local curtabbtn = CSResourceMgr.getNodeByName(resName, "tab"..curTab)
                curtabbtn:setPositionY(826+diff)
                curtabbtn:setScale(1.25, 1.25)
                curtabbtn:setLocalZOrder(2)
                --CSResourceMgr.getNodeByName(resName, "tabnew"..curTab):setVisible(false)
                UnblockLoader.cancel("FurnitureViewMgr-reset")
                FurnitureViewMgr.reset()
            end)
            CSResourceMgr.setLabelColor(resName, "tabt"..var, unselColor)
            CSResourceMgr.setLabelString(resName, "tabt"..var, tabName[var],"",unselOutColor)
            local tabbtn = CSResourceMgr.getNodeByName(resName, "tab"..var)
            tabbtn:setPositionY(818+diff)
            tabbtn:setScale(1, 1)
            tabbtn:setLocalZOrder(1)
            --CSResourceMgr.setLabelString(resName, "tabnum"..var, #bagInfo[var], "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        end
        CSResourceMgr.setLabelColor(resName, "tabt"..curTab, selColor)
        CSResourceMgr.setLabelString(resName, "tabt"..curTab, tabName[curTab],"",selOutColor)
        CSResourceMgr.setButtonEnabled(resName, "tab"..curTab, false)
        local curtabbtn = CSResourceMgr.getNodeByName(resName, "tab"..curTab)
        curtabbtn:setPositionY(826+diff)
        curtabbtn:setScale(1.25, 1.25)
        curtabbtn:setLocalZOrder(2)
        --CSResourceMgr.getNodeByName(resName, "tabnew"..curTab):setVisible(false)

        -- CSResourceMgr.getNodeByName(resName, "title_diban"):setVisible(CSResourceMgr.getScreenType())

        --...
        for i=1,5 do
            if i >#tabName then
                CSResourceMgr.getNodeByName(resName, "tab"..i):setVisible(false)
            end
        end
        
        for i=1,5 do
            CSResourceMgr.getNodeByName(resName, "tab"..i):setVisible(false)
        end
        ]]--
    end

    local function playCSB()
        CSResourceMgr.getCsbObj(resName):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resName), "up")
    end

    local function initBagItem()
        FurnitureViewMgr.reset()
    end
    
    local function showPlaceableArea()
        FurnitureViewMgr.ShowPlaceableArea(true)
    end

    local funcTable = {loadCSB, playCSB, initBagItem, showPlaceableArea}

    UnblockLoader.load(funcTable, "FurnitureViewMgr")
end

function FurnitureViewMgr.hide()
    --SceneMgr.setMapVisible(true)
    UnblockLoader.cancel("FurnitureViewMgr")
    UnblockLoader.cancel("FurnitureViewMgr-reset")
    labelTable = {}
    firstFurniture = nil
    --furnitureTable = {}
    --spriteRed = {}
    --spriteBlue = {}
    CSResourceMgr.getNodeByName(resName, "list"):removeAllItems()
    CSResourceMgr.removeCSObjectByTag(resName)
    CSResourceMgr.removeCSObjectByTag(resNameBG, "FurnitureViewMgr")
end

function FurnitureViewMgr.finish()
    GameAudio.playUISound("success")
    local furniture = FurnitureViewMgr.GetFurnitureByIndex(-1)
    if furniture ~= nil then
        FurnitureViewMgr.RemoveFurnitureFromMap(furniture)
    end
    FurnitureViewMgr.hide()
    FurnitureViewMgr.ShowPlaceableArea(false)
    UIStack.pop("FurnitureViewMgr")
end

function FurnitureViewMgr.update(id, num)
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    if true then
        local itemNum = FurnitureViewMgr.refreshItemInfo()
        PackageItemNum = itemNum
        -- CSResourceMgr.setLabelString(resName, "bagsize", CocosModuleMgr.createStringWithFormat({"<1>/<2>", 
        --     itemNum, CharInfo.get().itempacketnum}))
        --local bagSizeOne = CSResourceMgr.getNodeByName(resName, "bagsize1")
        --bagSizeOne:removeAllChildren()
        --CSResourceMgr.setLabelColor(resName, "bagsize1", {r=98,g=254,b=3,a=255})
        --CSResourceMgr.setLabelString(resName, "bagsize1", itemNum)

        --local bagSizeTwo = CSResourceMgr.getNodeByName(resName, "bagsize2")
        --bagSizeTwo:removeAllChildren()
        --CSResourceMgr.setLabelColor(resName, "bagsize2", {r=255,g=255,b=255,a=255})
        --CSResourceMgr.setLabelString(resName, "bagsize2", "/"..CharInfo.get().itempacketnum)
        -- local richtext = CocosModuleMgr.createRichLabel(bagSize, CocosModuleMgr.createRichLabelString({{color="00FF00", text=itemNum},
        --     {color="FFFFFF", text="/"..CharInfo.get().itempacketnum}}), 20, "cuyuan_GBK.ttf", 640)
        UnblockLoader.cancel("FurnitureViewMgr-reset")
        FurnitureViewMgr.reset()
        return
    end
    --[[
    local label = labelTable[id]
    if label then
        if num==1 then
            CSResourceMgr.setLabelStringByNode(label, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        elseif num>999 then
            CSResourceMgr.setLabelStringByNode(label, "999+", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        else
            CSResourceMgr.setLabelStringByNode(label, num, CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        end
    end
    ]]--
end

function FurnitureViewMgr.InitBlockInfo()
    BlockInfo = {}
    for var=1, FurnitureViewMgr.ROOM_WIDTH/FurnitureViewMgr.GRID_WIDTH - 1 do
        table.insert(BlockInfo, false)
    end
end

function FurnitureViewMgr.InitExpandLevel()
    ExpandLevel = 1
end

function FurnitureViewMgr.InitPlaceableArea(id)
    spritePlaceableArea = {}
    local startX = FurnitureViewMgr.START_X
    local FurnitureName,FurnitureWidth,FurnitureAnchor_x,FurnitureAnchor_y,FurnitureRespath = HomeInfo.getFurnitureInfoByID(id)
    local sprite = nil
    for var=1, FurnitureViewMgr.ROOM_WIDTH/FurnitureViewMgr.GRID_WIDTH - 1 do
        --print("@@@@@@@@@@@@@@@@@@@@@@@@@var="..tostring(var))
        sprite = display.newSprite(FurnitureRespath)
        if sprite ~= nil then
            sprite:setVisible(false)
            sprite:addTo(CSResourceMgr.getNodeByName(sceneName, {"home_01","middle_home","wall_2_1","bindNode"}))
            sprite:setPosition(startX + (var - 1) * FurnitureViewMgr.GRID_WIDTH, FurnitureViewMgr.PLACEABLE_BASELINE)
            sprite:setAnchorPoint(FurnitureAnchor_x, FurnitureAnchor_y)
            sprite:setLocalZOrder(CocosModuleMgr.ZORDER_WORLDMAP)
            table.insert(spritePlaceableArea,sprite)
            --print("@@@@@@@@@@@@@@@@@@@@@@@@@FurnitureRespath="..FurnitureRespath.."FurnitureAnchor_x="..tostring(FurnitureAnchor_x))
        end
    end
end

function FurnitureViewMgr.ExpandPlaceableArea(id)
    local startX = spritePlaceableArea[#spritePlaceableArea]:getPositionX()
    --print("@@@@@@@@@@@@@@@@@@@@@@@@@startX="..tostring(startX))
    local FurnitureName,FurnitureWidth,FurnitureAnchor_x,FurnitureAnchor_y,FurnitureRespath = HomeInfo.getFurnitureInfoByID(id)
    local sprite = nil
    for var=1, FurnitureViewMgr.ROOM_WIDTH/FurnitureViewMgr.GRID_WIDTH do
        sprite = display.newSprite(FurnitureRespath)
        if sprite ~= nil then
            sprite:setVisible(false)
            sprite:addTo(CSResourceMgr.getNodeByName(sceneName, {"home_01","middle_home","wall_2_1","bindNode"}))
            sprite:setPosition(startX + var * FurnitureViewMgr.GRID_WIDTH, FurnitureViewMgr.PLACEABLE_BASELINE)
            sprite:setAnchorPoint(FurnitureAnchor_x, FurnitureAnchor_y)
            sprite:setLocalZOrder(CocosModuleMgr.ZORDER_WORLDMAP)
            table.insert(spritePlaceableArea,sprite)
            --print("@@@@@@@@@@@@@@@@@@@@@@@@@FurnitureRespath="..FurnitureRespath.."FurnitureAnchor_x="..tostring(FurnitureAnchor_x))
        end
    end
end

function FurnitureViewMgr.ExpandBlockInfo()
    for var=1, FurnitureViewMgr.ROOM_WIDTH/FurnitureViewMgr.GRID_WIDTH do
        table.insert(BlockInfo, false)
    end
end

function FurnitureViewMgr.ExpandScene()
    for i=1, 3 do
        local wall = CSResourceMgr.getNodeByName(sceneName, "blockwall_2_"..tostring(i))
        if wall:isVisible() == true then
            wall:setVisible(false)
            return
        end
    end
end

function FurnitureViewMgr.SetHomeName(name)
    if name ~= nil then
        CSResourceMgr.setButtonString(sceneName, FixedFurnitureNameTable[2], name, nil, {r=0,g=0,b=0,a=255,w=1})
    end
end

function FurnitureViewMgr.ShowPlaceableArea(bShow)
    for k, v in pairs(spritePlaceableArea) do
        if v ~= nil then
            v:setVisible(bShow)
        end
    end
end

function FurnitureViewMgr.InitBlueRedSprite()
    spriteRed = {}
    spriteBlue = {}
    local RedName,RedWidth,RedAnchor_x,RedAnchor_y,RedRespath = HomeInfo.getFurnitureInfoByID(1)
    local BlueName,BlueWidth,BlueAnchor_x,BlueAnchor_y,BlueRespath = HomeInfo.getFurnitureInfoByID(2)
    for i=1, 4 do
        sprite = display.newSprite(RedRespath)
        sprite:setVisible(false)
        sprite:addTo(CSResourceMgr.getNodeByName(sceneName, {"home_01","middle_home","wall_2_1","bindNode"}))
        sprite:setAnchorPoint(RedAnchor_x, RedAnchor_y)
        sprite:setLocalZOrder(CocosModuleMgr.ZORDER_MAP_BACK)
        table.insert(spriteRed,sprite)

        sprite = display.newSprite(BlueRespath)
        sprite:setVisible(false)
        sprite:addTo(CSResourceMgr.getNodeByName(sceneName, {"home_01","middle_home","wall_2_1","bindNode"}))
        sprite:setAnchorPoint(BlueAnchor_x, BlueAnchor_y)
        sprite:setLocalZOrder(CocosModuleMgr.ZORDER_MAP_BACK)
        table.insert(spriteBlue,sprite)
    end
end

local function getFurnitureFromPool(bindNode)
    --print("==========getFurnitureFromPool size=",#furnituresPool)
    if bindNode then
        for i=1, #furnituresPool do
            if furnituresPool[i].bUsed == false then
                furnituresPool[i]:retain()
                furnituresPool[i]:removeFromParent(false)
                furnituresPool[i]:addTo(bindNode)
                furnituresPool[i].bUsed = true
                furnituresPool[i]:setVisible(true)
                return furnituresPool[i]
            end
        end
        local furniture = CSResourceMgr.getNodeByName(sceneName, "furniture"):clone()
        furniture:addTo(bindNode)
        furniture.bUsed = true
        table.insert(furnituresPool, furniture)
        return furniture
    else
        return nil
    end
end

local function freeFurniture(furniture)
    --print("==========freeFurniture size=",#furnituresPool)
    if furniture ~= nil then
        furniture:setTag(-1000000)
        furniture.bUsed = false
        furniture:setVisible(false)
    end
end

local function freeAllFurnitures()
    for i=1, #furnituresPool do
        local furniture = furnituresPool[i]
        if furniture.bUsed == true then
            freeFurniture(furniture)
        end
    end
end

function FurnitureViewMgr.clearFurnituresPool()
    furnituresPool = {}
end

function FurnitureViewMgr.ShowFurnitureByIndex(id, objID, Index, type)
    local startX = FurnitureViewMgr.START_X
    local FurnitureName,FurnitureWidth,FurnitureAnchor_x,FurnitureAnchor_y,FurnitureRespath = HomeInfo.getFurnitureInfoByID(id)
    local posX, posY
    if Index == -1 then
        posX = math.abs(TownMapMgr.Map:getPositionX()) + TownMapMgr.DEFAULT_TMAP_WIDTH/2
        posY = FurnitureViewMgr.BASELINE - 30
    else
        posX = startX + Index * FurnitureViewMgr.GRID_WIDTH + FurnitureWidth * FurnitureViewMgr.GRID_WIDTH
        posY = FurnitureViewMgr.BASELINE
    end
    
    local furniture = getFurnitureFromPool(CSResourceMgr.getNodeByName(sceneName, {"home_01","middle_home","wall_2_1","bindNode"}))
    if furniture ~= nil then
        furniture:setTag(objID)
        CSResourceMgr.setButtonTextureByNode(furniture, FurnitureRespath, FurnitureRespath, FurnitureRespath)
        --furniture:addTo(TownMapMgr.Map)
        furniture:setPosition(posX, posY)
        furniture:setAnchorPoint(FurnitureAnchor_x, FurnitureAnchor_y)
        furniture:setLocalZOrder(CocosModuleMgr.ZORDER_GUIDE - 4)
        
        table.insert(furnitureTable,{id = id, tag = objID, idx = Index, width = FurnitureWidth, objID = objID})
        --print("############insert furniture index="..tostring(Index))
        
        local isDragging = false
        CSResourceMgr.buttonEventBindingByNode(furniture, function(sender)
            --touch
            --print("!!!!!!!!!!Touch")
            if sender~=nil and CSResourceMgr.getCsbObj(resName) ~= nil then
                local furniture = FurnitureViewMgr.GetFurnitureByIndex(-1)
                if furniture ~= nil and furniture ~= sender then
                    --print("=========RemoveFurniture -1")
                    FurnitureViewMgr.RemoveFurnitureFromMap(furniture)
                end
                local x = sender:getTouchBeganPosition().x
                isDragging = false
                FurnitureViewMgr.RefreshBlockInfo(sender)
                FurnitureViewMgr.moveFurniture(sender, x, FurnitureWidth)
            end
        end, function(sender)
            --print("!!!!!!!!!!Click")
            --click
            --if isDragging then
            --    cancelFunc(sender)
            --end
            if sender~=nil and HomeInfo.GetCurrentHomeCharID() == CharInfo.getCharID() then
                if CSResourceMgr.getCsbObj(resName) ~= nil then
                    local furniture = FurnitureViewMgr.GetFurnitureByIndex(-1)
                    if furniture ~= nil and furniture ~= sender then
                        --print("=========RemoveFurniture -1")
                        FurnitureViewMgr.RemoveFurnitureFromMap(furniture)
                    end
                    local x = sender:getTouchEndPosition().x
                    isDragging = false
                    FurnitureViewMgr.stopFurniture(sender, x, FurnitureWidth)
                elseif type == Proto.FT_TV then
                    FurnitureTVMgr.show(SceneMgr.getRunningScene)
                elseif type == Proto.FT_WARDROBE then
                    AvatarViewMgr.show(SceneMgr.getRunningScene)
                elseif type == Proto.FT_SOFA then
                    FurnitureSofaMgr.show(SceneMgr.getRunningScene, id)
                else
                    ItemInfoViewMgr.show({id = id, type = 1, objID = objID}, false)
                end
            end
            FurnitureViewMgr.ShowBlueSpriteByIndex(false)
            FurnitureViewMgr.ShowRedSpriteByIndex(false)
        end, function(sender)
            --drag
            --if boolAnimating then
            --    return
            --end
            if sender~=nil and CSResourceMgr.getCsbObj(resName) ~= nil then
                local furniture = FurnitureViewMgr.GetFurnitureByIndex(-1)
                if furniture ~= nil and furniture ~= sender then
                    --print("=========RemoveFurniture -1")
                    FurnitureViewMgr.RemoveFurnitureFromMap(furniture)
                end
                --local bx = sender:getTouchBeganPosition().x
                local x = sender:getTouchMovePosition().x
                if isDragging == false then
                    isDragging = true
                    --FurnitureViewMgr.RefreshBlockInfo(sender)
                end
                FurnitureViewMgr.moveFurniture(sender, x, FurnitureWidth)
                --print("@@@@@@@@@@@@@@@@@@x="..tostring(x))
            end
        end, function(sender)
            --print("!!!!!!!!!!Cancel")
            --cancel
            --if isDragging then
            --    cancelFunc(sender)
            --end
            if sender~=nil and CSResourceMgr.getCsbObj(resName) ~= nil then
                local furniture = FurnitureViewMgr.GetFurnitureByIndex(-1)
                if furniture ~= nil and furniture ~= sender then
                    --print("=========RemoveFurniture -1")
                    FurnitureViewMgr.RemoveFurnitureFromMap(furniture)
                end
                local x = sender:getTouchEndPosition().x
                isDragging = false
                FurnitureViewMgr.stopFurniture(sender, x, FurnitureWidth)
            end
            FurnitureViewMgr.ShowBlueSpriteByIndex(false)
            FurnitureViewMgr.ShowRedSpriteByIndex(false)
        end)
    end
    --[[
    local posX = math.abs(TownMapMgr.Map:getPositionX()) + TownMapMgr.DEFAULT_TMAP_WIDTH/2--TownMapMgr.Pet:getPositionX()
   -- print("$$$$$$$$$$$$$$$$$$$$$$$posX="..tostring(posX))
    local FurnitureName,FurnitureWidth,FurnitureAnchor_x,FurnitureAnchor_y,FurnitureRespath = HomeInfo.getFurnitureInfoByID(id)
    local sprite = nil
    sprite = display.newSprite(FurnitureRespath)
    if sprite ~= nil then
        sprite:addTo(TownMapMgr.Map)
        sprite:setPosition(posX, 570)
        sprite:setAnchorPoint(FurnitureAnchor_x, FurnitureAnchor_y)
        sprite:setLocalZOrder(CocosModuleMgr.ZORDER_MAP_BACK)
        --print("@@@@@@@@@@@@@@@@@@@@@@@@@FurnitureRespath="..FurnitureRespath.."FurnitureAnchor_x="..tostring(FurnitureAnchor_x))
    end
    ]]--
    return furniture
end

function FurnitureViewMgr.ShowBlueSpriteByIndex(bShow, idx, width)
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    
    local startX = FurnitureViewMgr.START_X
    if bShow == false then
        for i=1, #spriteBlue do
            if spriteBlue[i] ~= nil then
                spriteBlue[i]:setVisible(false)
            end
        end
    else
        for i=1, #spriteBlue do
            if spriteBlue[i] ~= nil then
                if i <= width then
                    spriteBlue[i]:setPosition(startX + (idx - 1 + i - 1) * FurnitureViewMgr.GRID_WIDTH, FurnitureViewMgr.PLACEABLE_BASELINE)
                    spriteBlue[i]:setVisible(true)
                else
                    spriteBlue[i]:setVisible(false)
                end
            end
        end
    end
end

function FurnitureViewMgr.ShowRedSpriteByIndex(bShow, idx, width)
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    
    local startX = FurnitureViewMgr.START_X
    if bShow == false then
        for i=1, #spriteRed do
            if spriteRed[i] ~= nil then
                spriteRed[i]:setVisible(false)
            end
        end
    else
        for i=1, #spriteRed do
            if spriteRed[i] ~= nil then
                if i <= width then
                    spriteRed[i]:setPosition(startX + (idx - 1 + i - 1) * FurnitureViewMgr.GRID_WIDTH, FurnitureViewMgr.PLACEABLE_BASELINE)
                    spriteRed[i]:setVisible(true)
                else
                    spriteRed[i]:setVisible(false)
                end
            end
        end
    end
end

function FurnitureViewMgr.moveFurniture(furniture, x, width)
    local startX = FurnitureViewMgr.START_X
    if furniture ~= nil then
        local ValidIdx = 1
        furniture:setPosition(math.abs(TownMapMgr.Map:getPositionX()) + x + furniture:getContentSize().width/2, FurnitureViewMgr.BASELINE)
        furniture:setLocalZOrder(CocosModuleMgr.ZORDER_GUIDE - 4)
        for i=1, FurnitureViewMgr.ROOM_WIDTH/FurnitureViewMgr.GRID_WIDTH * ExpandLevel - 1 do
            if math.abs(TownMapMgr.Map:getPositionX()) + x >= startX + i * FurnitureViewMgr.GRID_WIDTH then
                ValidIdx = i
            end
        end
        local IsBlocked = FurnitureViewMgr.IsFurnitureBlockedByIndex(ValidIdx, width)
        if IsBlocked == false then
            FurnitureViewMgr.ShowBlueSpriteByIndex(true, ValidIdx, width)
            FurnitureViewMgr.ShowRedSpriteByIndex(false)
        else
            FurnitureViewMgr.ShowRedSpriteByIndex(true, ValidIdx, width)
            FurnitureViewMgr.ShowBlueSpriteByIndex(false)
        end
    end
end

function FurnitureViewMgr.RefreshBlockInfo(furniture)
    print("##########Refresh Block Info furnitureTable.size="..tostring(#furnitureTable))
    for i=1, #BlockInfo do
        BlockInfo[i] = false
    end
    
    for i=1, #furnitureTable do
        if furnitureTable[i].tag ~= furniture:getTag() and furnitureTable[i].idx ~= -1 then
            for j=1, furnitureTable[i].width do
                BlockInfo[furnitureTable[i].idx + j - 1] = true
                print("##########Refresh Block Info index="..tostring(furnitureTable[i].idx + j - 1).." is blocked")
            end
        end
    end
    return false
end

function FurnitureViewMgr.IsFurnitureBlockedByIndex(idx, width)
    for i=1, width do
        if (idx + i -1) > #BlockInfo or BlockInfo[idx + i -1] == true then
            return true
        end
    end
    return false
end

function FurnitureViewMgr.RemoveFurnitureFromMap(furniture)
    print("##########Remove Furniture.tag="..tostring(furniture:getTag()))
    local idx = FurnitureViewMgr.GetIndexOfFurnitureByTag(furniture:getTag())
    if idx ~= -1 then
        if furnitureTable[idx].idx ~= -1 then
            HomeInfo.SetHomeInfo("", 0, 0, furnitureTable[idx].objID, 0, 0)
        end
        table.remove(furnitureTable, idx)
        --print("##########After Remove Furniture.size="..tostring(#furnitureTable))
        --print(sz_T2S(furnitureTable))
    end
    --TownMapMgr.Map:removeChildByTag(furniture:getTag(), true)
    freeFurniture(furniture)
end

function FurnitureViewMgr.GetFurnitureByIndex(idx)
    if idx >= -1 then
        for i=1, #furnitureTable do
            if idx == furnitureTable[i].idx then
                return CSResourceMgr.getNodeByName(sceneName, {"home_01","middle_home","wall_2_1","bindNode"}):getChildByTag(furnitureTable[i].tag)
            end
        end
    end
    return nil
end

function FurnitureViewMgr.GetFurnitureForGuide()
    for i=1, #furnitureTable do
        if furnitureTable[i].idx > 0 then
            return CSResourceMgr.getNodeByName(sceneName, {"home_01","middle_home","wall_2_1","bindNode"}):getChildByTag(furnitureTable[i].tag)
        end
    end
    return nil
end

function FurnitureViewMgr.IsFurnitureExistByIndex(idx)
    for i=1, #furnitureTable do
        if idx == furnitureTable[i].idx then
            return i
        end
    end
    return nil
end

function FurnitureViewMgr.SetFurnitureNewObjIDByIndex(idx,new_ObjID)
    for i=1, #furnitureTable do
        if idx == furnitureTable[i].idx then
            furnitureTable[i].tag = new_ObjID
            --local old = furnitureTable[i].objID
            --print("%%%%%%%%%%%SetFurnitureNewObjIDByIndex old value="..tostring(old).." new value="..tostring(new_ObjID))
            furnitureTable[i].objID = new_ObjID
            return
        end
    end
end

function FurnitureViewMgr.SortFurniture()
    print("##########Sort Furniture")
    for i=1, #BlockInfo do
        local furniture = FurnitureViewMgr.GetFurnitureByIndex(i)
        if furniture ~= nil then
            furniture:setLocalZOrder(i)
        end
    end
end

function FurnitureViewMgr.ShowFixedFurniture(FurnitureType, id, objID, Index, NeighborLayer)
    local FurnitureName,FurnitureWidth,FurnitureAnchor_x,FurnitureAnchor_y,FurnitureRespath = HomeInfo.getFurnitureInfoByID(id)
    local tbl
    if NeighborLayer == nil then
        tbl = FixedFurnitureNameTable
    elseif NeighborLayer == 1 then
        tbl = HigherNeighborFixedFurnitureNameTable
    elseif  NeighborLayer == 2 then
        tbl = LowerNeighborFixedFurnitureNameTable
    end
    if FurnitureType == Proto.FT_DOOR then
        local FixedNode = CSResourceMgr.getNodeByName(sceneName, tbl[1])
        CSResourceMgr.setSpriteTextureByNode(FixedNode, FurnitureRespath)
    elseif FurnitureType == Proto.FT_DOORBOARD then
        local FixedNode = CSResourceMgr.getNodeByName(sceneName, tbl[2])
        CSResourceMgr.setButtonTextureByNode(FixedNode, FurnitureRespath, FurnitureRespath, FurnitureRespath)
    elseif FurnitureType == Proto.FT_LAMP then
        for i=1, FixedFurnitureCountTable[3] do
            local FixedNode = CSResourceMgr.getNodeByName(sceneName, tbl[3]..tostring(i))
            if FixedNode ~= nil then
                --local PosX,PosY = FixedNode:getPosition()
                --print("###########PosX="..tostring(PosX).." PosY="..tostring(PosY))
                CSResourceMgr.setSpriteTextureByNode(FixedNode, FurnitureRespath)
            end
        end
    elseif FurnitureType == Proto.FT_ROOT and (NeighborLayer == nil or NeighborLayer ~= 2) then
        for i=1, FixedFurnitureCountTable[4] do
            local FixedNode = CSResourceMgr.getNodeByName(sceneName, tbl[4]..tostring(i))
            if FixedNode ~= nil then
                if i == 1 then
                    CSResourceMgr.setSpriteTextureByNode(FixedNode, FurnitureRespath.."1.png")
                else
                    CSResourceMgr.setSpriteTextureByNode(FixedNode, FurnitureRespath.."2.png")
                end
            end
        end
    elseif FurnitureType == Proto.FT_FLOOR then
        for i=1, FixedFurnitureCountTable[5] do
            local FixedNode = CSResourceMgr.getNodeByName(sceneName, tbl[5]..tostring(i))
            if FixedNode ~= nil then
                if i == 1 then
                    CSResourceMgr.setSpriteTextureByNode(FixedNode, FurnitureRespath.."1.png")
                else
                    CSResourceMgr.setSpriteTextureByNode(FixedNode, FurnitureRespath.."2.png")
                end
            end
        end
    elseif FurnitureType == Proto.FT_WALLPAPER then
        for i=1, FixedFurnitureCountTable[6] do
            local FixedNode = CSResourceMgr.getNodeByName(sceneName, tbl[6]..tostring(i))
            if FixedNode ~= nil then
                if i < 3 then
                    CSResourceMgr.setSpriteTextureByNode(FixedNode, FurnitureRespath..tostring(i)..".png")
                elseif i == FixedFurnitureCountTable[6] then
                    CSResourceMgr.setSpriteTextureByNode(FixedNode, FurnitureRespath.."5.png")
                else
                    CSResourceMgr.setSpriteTextureByNode(FixedNode, FurnitureRespath.."3.png")
                end
            end
        end
    end
    return FurnitureWidth
end

local function resetFixedFurniture(NeighborLayer)
    local tbl
    if NeighborLayer == nil then
        tbl = FixedFurnitureNameTable
    elseif NeighborLayer == 1 then
        tbl = HigherNeighborFixedFurnitureNameTable
    elseif  NeighborLayer == 2 then
        tbl = LowerNeighborFixedFurnitureNameTable
    end
    
    --DOOR
    local FixedNode = CSResourceMgr.getNodeByName(sceneName, tbl[1])
    CSResourceMgr.setSpriteTextureByNode(FixedNode, "UI/CommonFiles/men.png")
    --DOORBOARD
    FixedNode = CSResourceMgr.getNodeByName(sceneName, tbl[2])
    CSResourceMgr.setButtonTextureByNode(FixedNode, "UI/CommonFiles/menpai.png", "UI/CommonFiles/menpai.png", "UI/CommonFiles/menpai.png")
    CSResourceMgr.setButtonStringByNode(FixedNode, "", {r=0,g=0,b=0,a=255,w=1})
    --LAMP
    for i=1, FixedFurnitureCountTable[3] do
        FixedNode = CSResourceMgr.getNodeByName(sceneName, tbl[3]..tostring(i))
        if FixedNode ~= nil then
            --local PosX,PosY = FixedNode:getPosition()
            --print("###########PosX="..tostring(PosX).." PosY="..tostring(PosY))
            CSResourceMgr.setSpriteTextureByNode(FixedNode, "UI/CommonFiles/deng.png")
        end
    end
    --ROOT
    if NeighborLayer == nil or NeighborLayer ~= 2 then
        for i=1, FixedFurnitureCountTable[4] do
            FixedNode = CSResourceMgr.getNodeByName(sceneName, tbl[4]..tostring(i))
            if FixedNode ~= nil then
                if i == 1 then
                    CSResourceMgr.setSpriteTextureByNode(FixedNode, "UI/CommonFiles/fangding1.png")
                else
                    CSResourceMgr.setSpriteTextureByNode(FixedNode, "UI/CommonFiles/fangding2.png")
                end
                
                if NeighborLayer == nil then
                    FixedNode:setVisible(true)
                end
            end
        end
    end
    --FLOOR
    for i=1, FixedFurnitureCountTable[5] do
        FixedNode = CSResourceMgr.getNodeByName(sceneName, tbl[5]..tostring(i))
        if FixedNode ~= nil then
            if i == 1 then
                CSResourceMgr.setSpriteTextureByNode(FixedNode, "UI/CommonFiles/diban1.png")
            else
                CSResourceMgr.setSpriteTextureByNode(FixedNode, "UI/CommonFiles/diban2.png")
            end
        end
    end
    --WALLPAPER
    for i=1, FixedFurnitureCountTable[6] do
        FixedNode = CSResourceMgr.getNodeByName(sceneName, tbl[6]..tostring(i))
        if FixedNode ~= nil then
            if i < 3 then
                CSResourceMgr.setSpriteTextureByNode(FixedNode, "UI/CommonFiles/qiang_bizhi"..tostring(i)..".png")
            elseif i == FixedFurnitureCountTable[6] then
                CSResourceMgr.setSpriteTextureByNode(FixedNode, "UI/CommonFiles/qiang_yinying.png")
            else
                CSResourceMgr.setSpriteTextureByNode(FixedNode, "UI/CommonFiles/qiang_bizhi3.png")
            end
        end
    end
    --blockwall
    for i=1, 3 do
        local wall
        if NeighborLayer == 1 then
            wall = CSResourceMgr.getNodeByName(sceneName, "blockwall_1_"..tostring(i))
        elseif NeighborLayer == 2 then
            wall = CSResourceMgr.getNodeByName(sceneName, "blockwall_3_"..tostring(i))
        else
            wall = CSResourceMgr.getNodeByName(sceneName, "blockwall_2_"..tostring(i))
        end
        wall:setVisible(true)
    end
end

local function setFamilyYardFixedFurniture(NeighborLayer)
    local tbl
    if NeighborLayer == nil then
        tbl = FixedFurnitureNameTable
    elseif NeighborLayer == 1 then
        tbl = HigherNeighborFixedFurnitureNameTable
    elseif  NeighborLayer == 2 then
        tbl = LowerNeighborFixedFurnitureNameTable
    end
    local FixedNode
    --FLOOR
    for i=1, FixedFurnitureCountTable[5] do
        FixedNode = CSResourceMgr.getNodeByName(sceneName, tbl[5]..tostring(i))
        if FixedNode ~= nil then
            if i == 1 then
                CSResourceMgr.setSpriteTextureByNode(FixedNode, "Furniture/Floor/floorWood_1.png")
            else
                CSResourceMgr.setSpriteTextureByNode(FixedNode, "Furniture/Floor/floorWood_2.png")
            end
        end
    end
    --WALLPAPER
    for i=1, FixedFurnitureCountTable[6] do
        FixedNode = CSResourceMgr.getNodeByName(sceneName, tbl[6]..tostring(i))
        if FixedNode ~= nil then
            if i < 3 then
                CSResourceMgr.setSpriteTextureByNode(FixedNode, "Furniture/Wallpaper/wallpaperWhite_"..tostring(i)..".png")
            elseif i == FixedFurnitureCountTable[6] then
                CSResourceMgr.setSpriteTextureByNode(FixedNode, "Furniture/Wallpaper/wallpaperWhite_5.png")
            else
                CSResourceMgr.setSpriteTextureByNode(FixedNode, "Furniture/Wallpaper/wallpaperWhite_3.png")
            end
        end
    end
end

function FurnitureViewMgr.ShowFixedFurnitureFromServer(FurnitureType, id, objID, Index)
    local FurnitureWidth = FurnitureViewMgr.ShowFixedFurniture(FurnitureType, id, objID, Index)
    table.insert(furnitureTable,{id = id, tag = objID, idx = Index, width = FurnitureWidth, objID = objID})
end

function FurnitureViewMgr.ShowFixedFurnitureFromPlayer(FurnitureType, id, objID, Index)
    local FurnitureWidth = FurnitureViewMgr.ShowFixedFurniture(FurnitureType, id, objID, Index)
    
    local idx = FurnitureViewMgr.IsFurnitureExistByIndex(Index)
    if idx ~= nil then
        local delID = furnitureTable[idx].objID
        furnitureTable[idx].tag = objID
        furnitureTable[idx].objID = objID
        furnitureTable[idx].width = FurnitureWidth
        HomeInfo.SetHomeInfo("", objID, Index, delID, 0, 0)
    else
        table.insert(furnitureTable,{id = id, tag = objID, idx = Index, width = FurnitureWidth, objID = objID})
        HomeInfo.SetHomeInfo("", objID, Index, 0, 0, 0)
    end
end

function FurnitureViewMgr.GetFurnitureType(id)
    local itemData = ItemInfo.getItemInfoById(id) 
    if itemData ~= nil then
        return itemData.paramA
    end
    return Proto.FT_NONE
end

function FurnitureViewMgr.stopFurniture(furniture, x, width)
    local startX = FurnitureViewMgr.START_X
    if furniture ~= nil then
        if math.abs(TownMapMgr.Map:getPositionX()) + x < startX + FurnitureViewMgr.GRID_WIDTH
        or math.abs(TownMapMgr.Map:getPositionX()) + x > startX + FurnitureViewMgr.ROOM_WIDTH * ExpandLevel then
            local idx = FurnitureViewMgr.GetIndexOfFurnitureByTag(furniture:getTag())
            if PackageItemNum < CharInfo.get().itempacketnum or idx == -1 or furnitureTable[idx].idx == -1 then
                FurnitureViewMgr.RemoveFurnitureFromMap(furniture)
            else
                furniture:setPosition(startX + furnitureTable[idx].idx * FurnitureViewMgr.GRID_WIDTH + width * FurnitureViewMgr.GRID_WIDTH, FurnitureViewMgr.BASELINE)
                StandardTipsMgr.show(1, "idling20")
            end
        else 
            local ValidIdx = 1
            for i=1, FurnitureViewMgr.ROOM_WIDTH/FurnitureViewMgr.GRID_WIDTH * ExpandLevel - 1 do
                if math.abs(TownMapMgr.Map:getPositionX()) + x >= startX + i * FurnitureViewMgr.GRID_WIDTH then
                    ValidIdx = i
                end
            end
            local IsBlocked = FurnitureViewMgr.IsFurnitureBlockedByIndex(ValidIdx, width)
            if IsBlocked == true then
                local idx = FurnitureViewMgr.GetIndexOfFurnitureByTag(furniture:getTag())
                if PackageItemNum < CharInfo.get().itempacketnum or idx == -1 or furnitureTable[idx].idx == -1 then
                    FurnitureViewMgr.RemoveFurnitureFromMap(furniture)
                else
                    furniture:setPosition(startX + furnitureTable[idx].idx * FurnitureViewMgr.GRID_WIDTH + width * FurnitureViewMgr.GRID_WIDTH, FurnitureViewMgr.BASELINE)
                    StandardTipsMgr.show(1, "idling20")
                end
            else
                local idx = FurnitureViewMgr.GetIndexOfFurnitureByTag(furniture:getTag())
                if idx ~= -1 and furnitureTable[idx].idx ~= ValidIdx then
                    if furnitureTable[idx].idx == -1 then
                        HomeInfo.SetHomeInfo("", furnitureTable[idx].objID, ValidIdx, 0, 0, 0)
                    else
                        HomeInfo.SetHomeInfo("", 0, 0, 0, furnitureTable[idx].objID, ValidIdx)
                    end
                    furnitureTable[idx].idx = ValidIdx
                end
                furniture:setPosition(startX + ValidIdx * FurnitureViewMgr.GRID_WIDTH + width * FurnitureViewMgr.GRID_WIDTH, FurnitureViewMgr.BASELINE)
                --FurnitureViewMgr.ShowBlueSpriteByIndex(true, ValidIdx, width)
                FurnitureViewMgr.SortFurniture()
            end
        end
    end
end

function FurnitureViewMgr.GetIndexOfFurnitureByTag(tag)
    for i=1, #furnitureTable do
        if furnitureTable[i].tag == tag then
            return i
        end
    end
    return -1
end

function FurnitureViewMgr.EmptyFurnitureTable()
    for k, v in pairs(furnitureTable) do
        local furniture = CSResourceMgr.getNodeByName(sceneName, {"home_01","middle_home","wall_2_1","bindNode"}):getChildByTag(v.tag)
        if furniture then
            freeFurniture(furniture)
        end
        --table.remove(furnitureTable, k)
    end
    furnitureTable = {}
end

function FurnitureViewMgr.SetExpandLevel(level)
    if level >= 1 and level <= 4 then
        --print("########SetExpandLevel level="..tostring(level))
        if level > ExpandLevel then
            for i=1, level - ExpandLevel do
                FurnitureViewMgr.ExpandPlaceableArea(3)
                FurnitureViewMgr.ExpandBlockInfo()
                FurnitureViewMgr.ExpandScene()
            end
        end
        ExpandLevel = level
    end
end

function FurnitureViewMgr.GetOwnerExpandLevel()
    local home = HomeInfo.GetLocalHomeInfo()
    if home then
        return home.level or 1
    end
    return 1
end

function FurnitureViewMgr.reset()
    labelTable = {}
    firstFurniture = nil
    local funcTable = {}
    local panelTable = {}
    local list = CSResourceMgr.getNodeByName(resName, "list")
    list:removeAllItems()

    for i=1, #bagInfo[curTab] do
        local row = math.ceil(i/FurnitureViewMgr.RANK_NUM)
        local rank = i%FurnitureViewMgr.RANK_NUM
        if rank==0 then
            rank = FurnitureViewMgr.RANK_NUM
        end
        if rank==1 then
            table.insert(funcTable, function()
                local panel = CSResourceMgr.getNodeByName(resName, "panel"):clone()
                table.insert(panelTable, panel)
                list:pushBackCustomItem(panel)
                --list:performWithDelay(function()
                --    list:jumpToTop()
                --end, 0.1)
            end)
        end
        local bagItemInfo = bagInfo[curTab][i]
        local function itemFunc()
            local parent = panelTable[row]
            local label = CSResourceMgr.seekNodeByName(parent, "l"..rank)
            --[[
            if bagItemInfo[2]==1 then
                CSResourceMgr.setLabelStringByNode(label, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            elseif bagItemInfo[2]>999 then
                CSResourceMgr.setLabelStringByNode(label, "999+", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            else
                CSResourceMgr.setLabelStringByNode(label, bagItemInfo[2], CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            end
            ]]--
            labelTable[bagItemInfo[1]] = label
            --[[
            if bagItemInfo[2]>=99 then --达到数量上限
            label:setTextColor({r=255,g=201,b=101,a=255})                    
            else
            label:setTextColor({r=255,g=255,b=255,a=255})
            end
            --]]
            local sprite = CSResourceMgr.seekNodeByName(parent, "s"..rank)
            local iconpath = ItemInfo.getItemInfoById(bagItemInfo[1]).icon
            CSResourceMgr.setButtonTextureByNode(sprite, iconpath, iconpath, iconpath)
            sprite:setScale(0, 0)
            sprite:setRotation(180)
            transition.scaleTo(sprite, {scale = 1, time = 0.2})
            transition.rotateTo(sprite, {rotate = 360, time = 0.2})
            local diban = CSResourceMgr.seekNodeByName(parent, "b"..rank)
            local btnRes = ItemInfo.getItemRareBGImage(bagItemInfo[1])
            --[[
            if bagItemInfo[1] == 37009 then
                CSResourceMgr.setButtonTextureByNode(diban, "Item/ItemRare/0.png", "Item/ItemRare/0.png", "Item/ItemRare/0.png")
            end
            ]]--
            CSResourceMgr.setButtonTextureByNode(diban, btnRes, btnRes, btnRes)
            CSResourceMgr.clickEventBindingByNode(diban, function()
                --CocosModuleMgr.hideShiningToNode(diban)
                --ItemInfoViewMgr.show({id = bagItemInfo[1], sum = bagItemInfo[2]})
                --print("###################id="..tostring(bagItemInfo[1]))
                local furniture = FurnitureViewMgr.GetFurnitureByIndex(-1)
                if furniture ~= nil then
                    FurnitureViewMgr.RemoveFurnitureFromMap(furniture)
                end
                local FurnitureType = FurnitureViewMgr.GetFurnitureType(bagItemInfo[1])
                if FurnitureType == Proto.FT_DOOR then
                    FurnitureViewMgr.ShowFixedFurnitureFromPlayer(FurnitureType, bagItemInfo[1], bagItemInfo[4], -2)
                elseif FurnitureType == Proto.FT_DOORBOARD then
                    FurnitureViewMgr.ShowFixedFurnitureFromPlayer(FurnitureType, bagItemInfo[1], bagItemInfo[4], -3)
                elseif FurnitureType == Proto.FT_LAMP then
                    FurnitureViewMgr.ShowFixedFurnitureFromPlayer(FurnitureType, bagItemInfo[1], bagItemInfo[4], -4)
                elseif FurnitureType == Proto.FT_ROOT then
                    FurnitureViewMgr.ShowFixedFurnitureFromPlayer(FurnitureType, bagItemInfo[1], bagItemInfo[4], -5)
                elseif FurnitureType == Proto.FT_FLOOR then
                    FurnitureViewMgr.ShowFixedFurnitureFromPlayer(FurnitureType, bagItemInfo[1], bagItemInfo[4], -6)
                elseif FurnitureType == Proto.FT_WALLPAPER then
                    FurnitureViewMgr.ShowFixedFurnitureFromPlayer(FurnitureType, bagItemInfo[1], bagItemInfo[4], -7)
                else
                    furniture = FurnitureViewMgr.ShowFurnitureByIndex(bagItemInfo[1], bagItemInfo[4], -1, FurnitureType)
                    if furniture ~= nil then
                        FurnitureViewMgr.RefreshBlockInfo(furniture)
                        --try to find valid pos
                        local startX = FurnitureViewMgr.START_X
                        local viewLeftX = math.abs(TownMapMgr.Map:getPositionX())
                        local FurnitureName,FurnitureWidth,FurnitureAnchor_x,FurnitureAnchor_y,FurnitureRespath = HomeInfo.getFurnitureInfoByID(bagItemInfo[1])
                        for i=1, FurnitureViewMgr.ROOM_WIDTH/FurnitureViewMgr.GRID_WIDTH * ExpandLevel - 1 do
                            if startX + i * FurnitureViewMgr.GRID_WIDTH >= viewLeftX and startX + i * FurnitureViewMgr.GRID_WIDTH < CONFIG_SCREEN_WIDTH + viewLeftX then
                                local IsBlocked = FurnitureViewMgr.IsFurnitureBlockedByIndex(i, FurnitureWidth)
                                if not IsBlocked then
                                    FurnitureViewMgr.stopFurniture(furniture, startX + i * FurnitureViewMgr.GRID_WIDTH + FurnitureViewMgr.GRID_WIDTH / 2 - viewLeftX, FurnitureWidth)
                                    break
                                end
                            end
                        end
                    end
                end
            end,3)

            diban:setScale(0, 0)
            diban:setVisible(true)
            transition.scaleTo(diban, {scale = 1, time = 0.1})
            if firstFurniture == nil and FurnitureViewMgr.GetFurnitureType(bagItemInfo[1]) == Proto.FT_SOFA then
                firstFurniture = diban
            end

            for key, var in pairs(ItemInfo.getNewItem()) do
                if var==bagItemInfo[1] then
                    CocosModuleMgr.showShiningToNode(diban, 1)
                    table.remove(ItemInfo.getNewItem(), key)
                end
            end
            --local nameLabel = CSResourceMgr.seekNodeByName(parent, "n"..rank)
            --CSResourceMgr.setLabelStringByNode(nameLabel, itemInfo[bagItemInfo[1]].name)
            --nameLabel:setTextColor({r=0,g=0,b=0,a=255})
        end
        table.insert(funcTable, itemFunc)
        --itemFunc()
    end
    UnblockLoader.load(funcTable, "FurnitureViewMgr-reset")
end

function FurnitureViewMgr.getFirstFurniture()
    return firstFurniture
end

function FurnitureViewMgr.ShowHigherNeighborHomeInfo(home)
    CSResourceMgr.getNodeByName(sceneName, "higher_home"):setVisible(true)
    --hide middle root
    for i=1, FixedFurnitureCountTable[4] do
        local FixedNode = CSResourceMgr.getNodeByName(sceneName, FixedFurnitureNameTable[4]..tostring(i))
        if FixedNode ~= nil then
            FixedNode:setVisible(false)
        end
    end
    --show home info
    if home.level ~= nil then
        for i=1, home.level - 1 do
            local wall = CSResourceMgr.getNodeByName(sceneName, "blockwall_1_"..tostring(i))
            if wall:isVisible() == true then
                wall:setVisible(false)
            end
        end
    end
    
    if home.homeName ~= nil then
        CSResourceMgr.setButtonString(sceneName, HigherNeighborFixedFurnitureNameTable[2], home.homeName, nil, {r=0,g=0,b=0,a=255,w=1})
    end
    
    if home.furnitures ~= nil then
        for k,v in pairs(home.furnitures) do
            local objID = tonumber(k)
            local itemID = v.itemID
            local Index = v.otherParam["Index"]
            local FurnitureType = FurnitureViewMgr.GetFurnitureType(itemID)
            if FurnitureType == Proto.FT_DOOR or FurnitureType == Proto.FT_DOORBOARD or FurnitureType == Proto.FT_LAMP or 
                FurnitureType == Proto.FT_ROOT or FurnitureType == Proto.FT_FLOOR or FurnitureType == Proto.FT_WALLPAPER then
                FurnitureViewMgr.ShowFixedFurniture(FurnitureType, itemID, objID, Index, 1)
            else
                local startX = FurnitureViewMgr.START_X
                local FurnitureName,FurnitureWidth,FurnitureAnchor_x,FurnitureAnchor_y,FurnitureRespath = HomeInfo.getFurnitureInfoByID(itemID)
                local posX, posY
                posX = startX + Index * FurnitureViewMgr.GRID_WIDTH + FurnitureWidth * FurnitureViewMgr.GRID_WIDTH
                posY = FurnitureViewMgr.HIGHER_NEIGHBOR_BASELINE
                
                local furniture = getFurnitureFromPool(CSResourceMgr.getNodeByName(sceneName, {"home_01","higher_home","wall_1_1","bindNode"}))
                if furniture ~= nil then
                    furniture:setTag(1000000 + Index)
                    CSResourceMgr.setButtonTextureByNode(furniture, FurnitureRespath, FurnitureRespath, FurnitureRespath)
                    --furniture:addTo(TownMapMgr.Map)
                    furniture:setPosition(posX, posY)
                    furniture:setAnchorPoint(FurnitureAnchor_x, FurnitureAnchor_y)
                    furniture:setLocalZOrder(Index)
                end
            end
        end
    end
end

function FurnitureViewMgr.ShowLowerNeighborHomeInfo(home)
    CSResourceMgr.getNodeByName(sceneName, "lower_home"):setVisible(true)
    --show home info
    if home.level ~= nil then
        for i=1, home.level - 1 do
            local wall = CSResourceMgr.getNodeByName(sceneName, "blockwall_3_"..tostring(i))
            if wall:isVisible() == true then
                wall:setVisible(false)
            end
        end
    end
    
    if home.homeName ~= nil then
        CSResourceMgr.setButtonString(sceneName, LowerNeighborFixedFurnitureNameTable[2], home.homeName, nil, {r=0,g=0,b=0,a=255,w=1})
    end
    
    if home.furnitures ~= nil then
        for k,v in pairs(home.furnitures) do
            local objID = tonumber(k)
            local itemID = v.itemID
            local Index = v.otherParam["Index"]
            local FurnitureType = FurnitureViewMgr.GetFurnitureType(itemID)
            if FurnitureType == Proto.FT_DOOR or FurnitureType == Proto.FT_DOORBOARD or FurnitureType == Proto.FT_LAMP or 
                FurnitureType == Proto.FT_ROOT or FurnitureType == Proto.FT_FLOOR or FurnitureType == Proto.FT_WALLPAPER then
                FurnitureViewMgr.ShowFixedFurniture(FurnitureType, itemID, objID, Index, 2)
            else
                local startX = FurnitureViewMgr.START_X
                local FurnitureName,FurnitureWidth,FurnitureAnchor_x,FurnitureAnchor_y,FurnitureRespath = HomeInfo.getFurnitureInfoByID(itemID)
                local posX, posY
                posX = startX + Index * FurnitureViewMgr.GRID_WIDTH + FurnitureWidth * FurnitureViewMgr.GRID_WIDTH
                posY = FurnitureViewMgr.LOWER_NEIGHBOR_BASELINE

                local furniture = getFurnitureFromPool(CSResourceMgr.getNodeByName(sceneName, {"home_01","lower_home","wall_3_1","bindNode"}))
                if furniture ~= nil then
                    furniture:setTag(2000000 + Index)
                    CSResourceMgr.setButtonTextureByNode(furniture, FurnitureRespath, FurnitureRespath, FurnitureRespath)
                    --furniture:addTo(TownMapMgr.Map)
                    furniture:setPosition(posX, posY)
                    furniture:setAnchorPoint(FurnitureAnchor_x, FurnitureAnchor_y)
                    furniture:setLocalZOrder(Index)
                end
            end
        end
    end
end

function FurnitureViewMgr.updateElevatorInfo(currentFloor, enableUp, enableDown)
    if SceneMgr.currentScene == "HomeScene" then
        if currentFloor ~= "" then
            CSResourceMgr.setButtonString(sceneName, "elevator_floor", currentFloor, nil, {r=0,g=0,b=0,a=255,w=1})
        end
        CSResourceMgr.setButtonEnabled(sceneName, "elevator_up", enableUp)
        CSResourceMgr.setButtonEnabled(sceneName, "elevator_down", enableDown)
    end
end

function FurnitureViewMgr.setHigherHomeVisible(bVisible)
    if SceneMgr.currentScene == "HomeScene" then
        CSResourceMgr.getNodeByName(sceneName, "higher_home"):setVisible(bVisible)
    end
end

function FurnitureViewMgr.setLowerHomeVisible(bVisible)
    if SceneMgr.currentScene == "HomeScene" then
        CSResourceMgr.getNodeByName(sceneName, "lower_home"):setVisible(bVisible)
    end
end

function FurnitureViewMgr.setHigherNeighborHomeName(name)
    CSResourceMgr.setButtonString(sceneName, HigherNeighborFixedFurnitureNameTable[2], name, nil, {r=0,g=0,b=0,a=255,w=1})
end

function FurnitureViewMgr.setLowerNeighborHomeName(name)
    CSResourceMgr.setButtonString(sceneName, LowerNeighborFixedFurnitureNameTable[2], name, nil, {r=0,g=0,b=0,a=255,w=1})
end

function FurnitureViewMgr.upStairs()
    freeAllFurnitures()
    resetFixedFurniture()
    resetFixedFurniture(1)
    resetFixedFurniture(2)
    --CSResourceMgr.getNodeByName(sceneName, "higher_home"):setVisible(false)
    --CSResourceMgr.getNodeByName(sceneName, "lower_home"):setVisible(false)
    NpcMgr.setAllVisible(false)
    
    HomeInfo.upStairs()
end

function FurnitureViewMgr.downStairs()
    freeAllFurnitures()
    resetFixedFurniture()
    resetFixedFurniture(1)
    resetFixedFurniture(2)
    --CSResourceMgr.getNodeByName(sceneName, "higher_home"):setVisible(false)
    --CSResourceMgr.getNodeByName(sceneName, "lower_home"):setVisible(false)
    NpcMgr.setAllVisible(false)
    
    HomeInfo.downStairs()
end

function FurnitureViewMgr.goSpecifyFloor(floorCharID)
    if FurnitureViewMgr.IsOpen() == false then
        CSResourceMgr.setButtonEnabled(sceneName, "elevator_up", false)
        CSResourceMgr.setButtonEnabled(sceneName, "elevator_down", false)
        
        freeAllFurnitures()
        resetFixedFurniture()
        resetFixedFurniture(1)
        resetFixedFurniture(2)
        --CSResourceMgr.getNodeByName(sceneName, "higher_home"):setVisible(false)
        --CSResourceMgr.getNodeByName(sceneName, "lower_home"):setVisible(false)
        NpcMgr.setAllVisible(false)
        
        if SceneMgr.currentScene == "HomeScene" then
            HomeInfo.BroadcastHomePlayerLeaveMsg(CharInfo.getNickName())
        end
        
        HomeInfo.SetCurrentHomeCharID(floorCharID)
        HomeMenuMgr.resetMenu()
        HomeInfo.ClearLocalPlayerInfo()
        HomeInfo.GetHomeInfo(false)
        HomeInfo.GetNeighborHomeInfo()

        local ChatSend = require("src.Net.Send.ChatSend")
        ChatSend.sendCG_ChangeChannel_Req({channel = "Home_"..tostring(HomeInfo.GetCurrentHomeCharID() == 0 and "yard_"..(CharInfo.getFamilyID() or 0) or HomeInfo.GetCurrentHomeCharID()),data = "{}"})

        HomeInfo.BroadcastHomePlayerUpdateMsg(tostring(CharInfo.getLevel()), FamilyInfo.GetMyFamilyName(), CharInfo.getNickName(), PokemonInfo.getFollowPokemonID(), CharInfo.getNickName().."的宠物", 260, 300, CharInfo.getCurfashion())
    end
end

local function calcOpenLevel(familyLevel)
    return 4
    --[[
    if familyLevel < 2 then
        return 1
    elseif familyLevel < 4 then
        return 2
    elseif familyLevel < 7 then
        return 3
    else
        return 4
    end
    ]]
end

local function showFamilyNpcManagerUI()
    --print("showFamilyNpcManagerUI")
    if FurnitureViewMgr.IsOpen() == false and HomeInfo.GetCurrentHomeCharID() == 0 then
        FamilyNpcManagerViewMgr.show(SceneMgr.getRunningScene)
    end
end

local function showFamilyNpcQuestUI()
    --print("showFamilyNpcQuestUI")
    if FurnitureViewMgr.IsOpen() == false and HomeInfo.GetCurrentHomeCharID() == 0 then
        FamilyQuestListMgr.show(SceneMgr.getRunningScene)
    end
end

local function showFamilyNpcDonateUI()
    if CharInfo.getFamilyID() ~= nil then
        local info = FamilyInfo.GetLocalFamilyInfo()
        local familyLevel = info.familyLevel or 1
        if familyLevel >= 2 then
            FamilyDonateMgr.show(SceneMgr.getRunningScene)
        end
    end
end

local function showFamilyNpcSignUI()
    if CharInfo.getFamilyID() ~= nil then
        -- local info = FamilyInfo.GetLocalFamilyInfo()
        -- local familyLevel = info.familyLevel or 1
        -- if familyLevel >= 2 then
        --     FamilyDonateMgr.show(SceneMgr.getRunningScene)
        -- end
        FamilySignView.new(SceneMgr.getRunningScene)
    end
end

local function showFamilyNpcShopUI()
    if CharInfo.getFamilyID() ~= nil then
        local info = FamilyInfo.GetLocalFamilyInfo()
        local familyLevel = info.familyLevel or 1
        if familyLevel >= 3 then
            FamilyShopMgr.show(SceneMgr.getRunningScene)
        end
    end
end

local function showFamilyNpcCopyUI()
    --FamilyCopyMgr.show(SceneMgr.getRunningScene)
end

local function showFamilyNpcReserve1()
end

local function showFamilyNpcReserve2()
end

local function showFamilyNpcReserve3()
end

local function npcBattleCallback(detail)
    if detail ~= nil and detail.me then
        detail.result = detail.result or PLAYER_LOSE
        BattleMapMgr.sendGameOver(detail.result,detail.me)
    end
end

local function showFamilyPatrolNpcBattle()
    local questID = CharInfo.getFamilyQuestID() or 0
    if questID > 0 then
        local questType = QuestInfo.getFamilyQuestInfoById(questID).familyQuestType
        local familyQuestOK = CharInfo.getFamilyQuestOK() or 0
        local familyQuestFailedTime = tonumber(CharInfo.getFamilyQuestFailedTime() or 0)
        if questType == Proto.FQT_PATROL and CharInfo.getFamilyID() ~= nil and familyQuestOK == 0 and CharInfo.getServerTime() < familyQuestFailedTime then
            local info = {true,{type = Proto.BTT_FAMILYQUEST_PATROL, callback = npcBattleCallback}}
            BattleMapMgr.sendReBattleServe(info)
        else
            StandardTipsMgr.show(1,"family83")
        end
    else
        StandardTipsMgr.show(1,"family83")
    end
end

function FurnitureViewMgr.setLower2FamilyYard(level, name)
    CSResourceMgr.getNodeByName(sceneName, "lower_home"):setVisible(true)
    
    setFamilyYardFixedFurniture(2)
    
    if level ~= nil then
        level = calcOpenLevel(level)
        for i=1, level - 1 do
            local wall = CSResourceMgr.getNodeByName(sceneName, "blockwall_3_"..tostring(i))
            if wall:isVisible() == true then
                wall:setVisible(false)
            end
        end
    end

    if name ~= nil then
        CSResourceMgr.setButtonString(sceneName, LowerNeighborFixedFurnitureNameTable[2], name, nil, {r=0,g=0,b=0,a=255,w=1})
    end
    
    --NpcMgr.addNPC(10000, LuaSqlite.getLanguageByKey("home015"), NPC_LOCATION.MANAGER, showFamilyNpcManagerUI, TownMapMgr.DEFAULT_TMAP_POSY_DIFF - 300, FurnitureViewMgr.NPC_SCALE, false)

    --NpcMgr.addNPC(10001, LuaSqlite.getLanguageByKey("home016"), NPC_LOCATION.QUEST, showFamilyNpcQuestUI, TownMapMgr.DEFAULT_TMAP_POSY_DIFF - 300, FurnitureViewMgr.NPC_SCALE, false)
end

function FurnitureViewMgr.setMiddle2FamilyYard(level, name)
    setFamilyYardFixedFurniture()
    
    if level ~= nil then
        level = calcOpenLevel(level)
        for i=1, level - 1 do
            local wall = CSResourceMgr.getNodeByName(sceneName, "blockwall_2_"..tostring(i))
            if wall:isVisible() == true then
                wall:setVisible(false)
            end
        end
    end

    if name ~= nil then
        CSResourceMgr.setButtonString(sceneName, FixedFurnitureNameTable[2], name, nil, {r=0,g=0,b=0,a=255,w=1})
    end
    
    local posY = TownMapMgr.DEFAULT_TMAP_POSY_DIFF
    local diff = CocosModuleMgr.getScreenSizeDiff()
    --print("************diff=",diff)
    if diff > 0.0 and diff < 100.0 then
        posY = posY + diff * 1.26
    end
    NpcMgr.addNPC(10000, LuaSqlite.getLanguageByKey("home015"), NPC_LOCATION.MANAGER, showFamilyNpcManagerUI, posY, FurnitureViewMgr.NPC_SCALE, false, nil, nil, nil, 20)
    
    NpcMgr.addNPC(10001, LuaSqlite.getLanguageByKey("home016"), NPC_LOCATION.QUEST, showFamilyNpcQuestUI, posY, FurnitureViewMgr.NPC_SCALE, false, nil, nil, nil, 20)
    
    FurnitureViewMgr.checkFamilyDonateNPC(posY)
    
    FurnitureViewMgr.checkFamilyShopNPC(posY)
    
    FurnitureViewMgr.checkFamilyCopyNPC(posY)
    
    FurnitureViewMgr.checkFamilyReserve1(posY)
    
    FurnitureViewMgr.checkFamilyReserve2(posY)
    
    FurnitureViewMgr.checkFamilyReserve3(posY)
    
    FurnitureViewMgr.checkRandomQuestNPC(CharInfo.getFamilyQuestID() or 0, posY)
end

function FurnitureViewMgr.upgradeFamilyYard(level)
    if SceneMgr.currentScene == "HomeScene" and CharInfo.getFamilyID() ~= nil and HomeInfo.GetCurrentHomeCharID() == 0 and level ~= nil then
        level = calcOpenLevel(level)
        for i=1, level - 1 do
            local wall = CSResourceMgr.getNodeByName(sceneName, "blockwall_2_"..tostring(i))
            if wall:isVisible() == true then
                wall:setVisible(false)
            end
        end
    end
end

function FurnitureViewMgr.checkRandomQuestNPC(questID, posY)
    if questID > 0 and SceneMgr.currentScene == "HomeScene" then
        local questType = QuestInfo.getFamilyQuestInfoById(questID).familyQuestType
        if questType == Proto.FQT_PATROL and CharInfo.getFamilyID() ~= nil and HomeInfo.GetCurrentHomeCharID() == 0 then
            local info = FamilyInfo.GetLocalFamilyInfo()
            local familyQuestOK = CharInfo.getFamilyQuestOK() or 0          --1:成功 0:失败
            local familyQuestFailedTime = tonumber(CharInfo.getFamilyQuestFailedTime() or 0)
            --print("========checkRandomQuestNPC",familyQuestOK,familyQuestFailedTime)
            if info ~= nil and familyQuestOK == 0 and CharInfo.getServerTime() < familyQuestFailedTime then
                local level = calcOpenLevel(info.familyLevel or 1)
                local idx = GetRandom.random(1,(level - 1) * FurnitureViewMgr.ROOM_WIDTH/FurnitureViewMgr.GRID_WIDTH + (FurnitureViewMgr.ROOM_WIDTH/FurnitureViewMgr.GRID_WIDTH - 1))
                local NpcID = QuestInfo.getFamilyQuestInfoById(questID).params[1]
                local figure = AdventureInfo.getMonsterGroupManInfoByID(NpcID).figure
                local tbl = string.split(figure, ",")
                local skin = {}
                for k, v in pairs(tbl) do
                    skin[k] = tonumber(v)
                end
                --print("==========checkRandomQuestNPC skin=",sz_T2S(skin))
                NpcMgr.addNPC(10008, LuaSqlite.getLanguageByKey(AdventureInfo.getMonsterGroupManInfoByID(NpcID).groupCode), FurnitureViewMgr.START_X + (idx - 0.5) * FurnitureViewMgr.GRID_WIDTH, showFamilyPatrolNpcBattle, posY - 20, FurnitureViewMgr.NPC_SCALE * 0.9, false, skin, nil, nil, 20)
            end
        end
    end
end

function FurnitureViewMgr.checkFamilyDonateNPC(posY)
    if CharInfo.getFamilyID() ~= nil then
        local info = FamilyInfo.GetLocalFamilyInfo()
        local familyLevel = info.familyLevel or 1
        NpcMgr.addNPC(10002, LuaSqlite.getLanguageByKey("familySignIn1"), NPC_LOCATION.DONATE, showFamilyNpcSignUI, posY, FurnitureViewMgr.NPC_SCALE, true, nil, nil, nil, 20)
    end
   
end

function FurnitureViewMgr.checkFamilyShopNPC(posY)
    if CharInfo.getFamilyID() ~= nil then
        local info = FamilyInfo.GetLocalFamilyInfo()
        local familyLevel = info.familyLevel or 1
        NpcMgr.addNPC(10003, LuaSqlite.getLanguageByKey("iteminfo22"), NPC_LOCATION.SHOP, showFamilyNpcShopUI, posY, FurnitureViewMgr.NPC_SCALE, true, nil, nil, familyLevel<3 and CocosModuleMgr.createStringWithFormat({"home020", 3}) or nil, 20)
    end
end

function FurnitureViewMgr.checkFamilyCopyNPC(posY)
    if CharInfo.getFamilyID() ~= nil then
        local info = FamilyInfo.GetLocalFamilyInfo()
        local familyLevel = info.familyLevel or 1
        --if familyLevel >= 3 then
        NpcMgr.addNPC(10004, LuaSqlite.getLanguageByKey("family93"), NPC_LOCATION.COPY, showFamilyNpcDonateUI, posY, FurnitureViewMgr.NPC_SCALE, true, nil, "10004", familyLevel<2 and CocosModuleMgr.createStringWithFormat({"home020", 2}) or nil, 20)
        --end
    end
end

function FurnitureViewMgr.checkFamilyReserve1(posY)
    if CharInfo.getFamilyID() ~= nil then
        local info = FamilyInfo.GetLocalFamilyInfo()
        local familyLevel = info.familyLevel or 1
        --if familyLevel >= 3 then
        NpcMgr.addNPC(10005, LuaSqlite.getLanguageByKey("lwjl3"), NPC_LOCATION.RESERVE1, showFamilyNpcReserve1, posY, FurnitureViewMgr.NPC_SCALE, false, nil, "10005", nil, 20)
        --end
    end
end

function FurnitureViewMgr.checkFamilyReserve2(posY)
    if CharInfo.getFamilyID() ~= nil then
        local info = FamilyInfo.GetLocalFamilyInfo()
        local familyLevel = info.familyLevel or 1
        --if familyLevel >= 3 then
        NpcMgr.addNPC(10006, LuaSqlite.getLanguageByKey("lwjl3"), NPC_LOCATION.RESERVE2, showFamilyNpcReserve2, posY, FurnitureViewMgr.NPC_SCALE, false, nil, "10006", nil, 20)
        --end
    end
end

function FurnitureViewMgr.checkFamilyReserve3(posY)
    if CharInfo.getFamilyID() ~= nil then
        local info = FamilyInfo.GetLocalFamilyInfo()
        local familyLevel = info.familyLevel or 1
        --if familyLevel >= 3 then
        NpcMgr.addNPC(10007, LuaSqlite.getLanguageByKey("lwjl3"), NPC_LOCATION.RESERVE3, showFamilyNpcReserve3, posY, FurnitureViewMgr.NPC_SCALE, false, nil, "10007", nil, 20)
        --end
    end
end

function FurnitureViewMgr.snapShot()
    TownMapMgr.savePosition()
    TownMapMgr.resetPosition4Snapshot()
    local rootNode = CSResourceMgr.getNodeByName(sceneName, "home_01")
    local width = rootNode:getContentSize().width
    local height = rootNode:getContentSize().height
    local diff = CocosModuleMgr.getScreenSizeDiff()
    local isSuccess = CocosModuleMgr.renderNodeToFile(TownMapMgr.Map, TownMapMgr.Player, "snapshot.jpg", width, height, width / 2, 30 - (diff<0 and diff*2.66 or 0), width, 298)
    HomeMenuMgr.showFlash(function()
        TownMapMgr.revertPosition()
    end, function()
        if isSuccess then
            StandardTipsMgr.show(0,LuaSqlite.getLanguageByKey("family119")..":"..cc.FileUtils:getInstance():getWritablePath())
        end
    end)
end

return FurnitureViewMgr