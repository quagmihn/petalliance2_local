local BagViewMgr = {}

BagViewMgr.RANK_NUM = 4

local curTab = 1

local resName = ""
local resNameBG = ""
local tabName = {}
local bagInfo = {}
local labelTable = {}
local buttonTable = {}
local panelTable = {}
local orderString = {}
local lastSelItem = nil
local itemInfoRareTable = {} --用来解决性能问题
local bagItems = {}
local itemPanels = {}
BagViewMgr.INGUIDE = false
BagViewMgr.ADDREDPOINT = false

local localItemNum = 0
local reSized = false

local indexTable = {}

local isLoaded = false

function BagViewMgr.Init()
    resName = "Item/Bag/BagView.csb"
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    CSResourceMgr.createRes(nil, resName, nil, true)
    tabName = {"bag14", "bag14", "bag14", "bag14","bag14"}
    bagInfo = {}
    curTab = 1
    labelTable = {}
    buttonTable = {}
    panelTable = {}
    lastSelItem = nil

    orderString = {
        [1] = "Pet/Education/c.png",
        [2] = "Pet/Education/b.png",
        [3] = "Pet/Education/a.png",
        [4] = "Pet/Education/s.png",
        [5] = "Pet/Education/2s.png",
        [6] = "Pet/Education/3s.png",
    }
    bagItems = {}
    bagItems[1] = {}
    bagItems[2] = {}
    bagItems[3] = {}
    bagItems[4] = {}
    bagItems[5] = {}
    itemPanels = {}

    indexTable = {}
    localItemNum = 0

    BagViewMgr.INGUIDE = false
    BagViewMgr.ADDREDPOINT = false

    isLoaded = false
end

function BagViewMgr.refreshItemInfo()
    --从itemMgr中获取背包物品信息
    local bagItemInfo = ItemInfo.getCharItemInfo()

    local itemNum = 0
    for var=1, #tabName-1 do
        bagInfo[var] = {}
    end
    for key, var in pairs(bagItemInfo) do
        local iteminfo = ItemInfo.getItemInfoById(key)
        if iteminfo then
            itemInfoRareTable[key] = iteminfo.itemRare
            local itemtid = ItemInfo.getItemType(key)
            if type(var) ~= "number" then
                for k,v in pairs(var) do
                    if itemtid then
                        table.insert(bagInfo[itemtid+1], {key, v.num, v.isBind,k})
                    end
                    itemNum = itemNum + 1
                end
            elseif var>0 then
                if itemtid then
                    table.insert(bagInfo[itemtid+1], {key, var})
                end
                itemNum = itemNum + 1
            end
        end		
    end
    for i=2,#tabName-1 do
        bagInfo[i] = BagViewMgr.sortBagItems(bagInfo[i])
        for k,v in pairs(bagInfo[i]) do
            table.insert(bagInfo[1], v)
        end
    end
    if not bagInfo[5] then
        bagInfo[5] = {}
    end
    bagInfo[5] = BagViewMgr.sortPetPiece(bagInfo[5])

    localItemNum = itemNum

    return itemNum
end

function BagViewMgr.request(scene)
    BagViewMgr.show(scene)
end

function BagViewMgr.show(scene)
    UIStack.push("BagViewMgr",BagViewMgr.hide,true)
    lastSelItem = nil
    local itemNum = BagViewMgr.refreshItemInfo()

    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG, "BagViewMgr")
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "BagViewMgr")
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    end

    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        curLayer:setVisible(false)

        --...
        CSResourceMgr.setLabelString(resName, "skillBoolLabel", "skillBookLabel1", "", {r=0,g=0,b=0,a=255,w=1,s=1})
        CSResourceMgr.setLabelColor(resName, "skillBoolLabel", {r=255,g=255,b=255,a=255})
        CSResourceMgr.clickEventBinding(resName, "skillBook", function()
            BagViewMgr.hide()
            SkillBookViewMgr.show(scene)
            GameAudio.playUISound("ok")
        end)

        local diff = CocosModuleMgr.getScreenSizeDiff()
        if not reSized then
            local diban = CSResourceMgr.getNodeByName(resName, "ts_dit3")
            local dbsize = diban:getContentSize()
            diban:setContentSize(dbsize.width, dbsize.height+diff)
            local list = CSResourceMgr.getNodeByName(resName, "list")
            local lsize = list:getContentSize()
            list:setContentSize(lsize.width, lsize.height+diff)
            local lposy = list:getPositionY()
            list:setPositionY(lposy-diff/2)   
            local title = CSResourceMgr.getNodeByName(resName, "title")
            local tposy = title:getPositionY()
            title:setPositionY(tposy+diff/2)   
            local didang = CSResourceMgr.getNodeByName(resName, "bb_di2")
            local dposy = didang:getPositionY()
            didang:setPositionY(dposy+diff/2)   
            local skillBook = CSResourceMgr.getNodeByName(resName, "skillBook")
            local sposy = skillBook:getPositionY()
            skillBook:setPositionY(sposy+diff/2)   
            local tabs = CSResourceMgr.getNodeByName(resName, "tabs")
            local tposy = tabs:getPositionY()
            tabs:setPositionY(tposy-diff)
        	reSized = true
        end
        
        -- CSResourceMgr.setLabelString(resName, "bagsize", CocosModuleMgr.createStringWithFormat({"<1>/<2>", itemNum, 
        --     CharInfo.get().itempacketnum}))
        -- local bagSize = CSResourceMgr.getNodeByName(resName, "bagsize")
        -- bagSize:removeAllChildren()
        -- local richtext = CocosModuleMgr.createRichLabel(bagSize, CocosModuleMgr.createRichLabelString({{color="00FF00", text=itemNum},
        --     {color="FFFFFF", text="/"..CharInfo.get().itempacketnum}}), 20, "cuyuan_GBK.ttf", 640, 0, 0)
        local bagSizeOne = CSResourceMgr.getNodeByName(resName, "bagsize1")
        bagSizeOne:removeAllChildren()
        CSResourceMgr.setLabelColor(resName, "bagsize1", {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelString(resName, "bagsize1", itemNum, "", {r=0,g=0,b=0,a=255,w=1,s=1})

        local bagSizeTwo = CSResourceMgr.getNodeByName(resName, "bagsize2")
        bagSizeTwo:removeAllChildren()
        CSResourceMgr.setLabelColor(resName, "bagsize2", {r=254,g=243,b=57,a=255})
        CSResourceMgr.setLabelString(resName, "bagsize2", "/"..CharInfo.get().itempacketnum+(CharInfo.get().furnituresuitcasevaluerate or 0), "", {r=0,g=0,b=0,a=255,w=1,s=1})
        -- CSResourceMgr.setLabelColor(resName, "bagsize", {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelString(resName, "title", "menu2", "", {r=26,g=37,b=48,a=255,s=1})
        CSResourceMgr.setLabelColor(resName, "title", {r=214,g=245,b=251,a=255})
        -- CSResourceMgr.setButtonString(resName, "expandbag", "bag6", "", {r=0,g=126,b=162,a=255})
        CSResourceMgr.clickEventBinding(resName, "expandbag", function()
            local price = SystemInfo.getGlobalConfigAddInfoByID(6602).values[1]
            local bagnum = SystemInfo.getGlobalConfigAddInfoByID(6603).values[1]
            if price>CharInfo.getMCash() then
            	TipsMgr.show(scene, "tips14")
            	return
            end

            --阿杜修改英文版显示
            local str = CocosModuleMgr.createStringWithFormat({"bag12", 
                CocosModuleMgr.createStringWithFormat({"<1><2>", price, "tips17"}), bagnum})
            if LuaSqlite.LANG_TYPE ~= 1 then
                str = CocosModuleMgr.createStringWithFormat({"bag12", price,bagnum})
            end
        	DialogBoxMgr.showSmallDialogBox(scene, 2, str, function()
                NetInterface.sendWithBlock("GC_BuyPacket_Ack", function()
                	local ItemSend = require("src.Net.Send.ItemSend")
                	ItemSend.sendCG_BuyPacket_Req(1)
                end, function()
                        GameAudio.playUISound("success")
                        local bagSizeOne = CSResourceMgr.getNodeByName(resName, "bagsize1")
                        bagSizeOne:removeAllChildren()
                        CSResourceMgr.setLabelColor(resName, "bagsize1", {r=255,g=255,b=255,a=255})
                        CSResourceMgr.setLabelString(resName, "bagsize1", itemNum, "", {r=0,g=0,b=0,a=255})

                        local bagSizeTwo = CSResourceMgr.getNodeByName(resName, "bagsize2")
                        bagSizeTwo:removeAllChildren()
                        CSResourceMgr.setLabelColor(resName, "bagsize2", {r=254,g=243,b=57,a=255})
                        CSResourceMgr.setLabelString(resName, "bagsize2", "/"..CharInfo.get().itempacketnum+(CharInfo.get().furnituresuitcasevaluerate or 0), "", {r=0,g=0,b=0,a=255})
                    -- CSResourceMgr.setLabelString(resName, "bagsize", CocosModuleMgr.createStringWithFormat({"<1>/<2>", 
                    --     itemNum, CharInfo.get().itempacketnum}))
                    -- local richtext = CocosModuleMgr.createRichLabel(bagSize, CocosModuleMgr.createRichLabelString({{color="00FF00", text=itemNum},
                    --     {color="FFFFFF", text="/"..CharInfo.get().itempacketnum}}), 20, "cuyuan_GBK.ttf", 640, 0, 0)

                end, function(code)
                	TipsMgr.showError(scene, code)
                end)
        	end)
        end,"",1)

        tabName = ItemInfo.getAllTitle()
        
        local selColor = {r=255,g=255,b=255,a=255}
        local selOutColor = {r=44,g=69,b=87,a=255}
        local unselColor = {r=255,g=255,b=255,a=255}
        local unselOutColor = {r=76,g=110,b=130,a=255}
        for var=1, #tabName do
        	CSResourceMgr.clickEventBinding(resName, "tab"..var, function()
                GameAudio.playUISound("sheetClick")
                lastSelItem = nil
                CSResourceMgr.setButtonEnabled(resName, "tab"..curTab, true)
                CSResourceMgr.setLabelColor(resName, "tabt"..curTab, unselColor)
                CSResourceMgr.setLabelString(resName, "tabt"..curTab, tabName[curTab],"",unselOutColor)
                CSResourceMgr.getNodeByName(resName, "tabt"..curTab):setPositionY(25)
                local tabbtn = CSResourceMgr.getNodeByName(resName, "tab"..curTab)
                tabbtn:setPositionY(98+diff)
                tabbtn:setScale(1, 1)
                tabbtn:setLocalZOrder(1)
                CSResourceMgr.getNodeByName(resName, "icon"..curTab):setScale(1,1)
                CSResourceMgr.getNodeByName(resName, "arrows"..curTab):setVisible(false)
                curTab = var
                CSResourceMgr.setButtonEnabled(resName, "tab"..curTab, false)
                CSResourceMgr.setLabelColor(resName, "tabt"..curTab, selColor)
                CSResourceMgr.setLabelString(resName, "tabt"..curTab, tabName[curTab],"",selOutColor)
                CSResourceMgr.getNodeByName(resName, "tabt"..curTab):setPositionY(22)
                local curtabbtn = CSResourceMgr.getNodeByName(resName, "tab"..curTab)
                curtabbtn:setPositionY(103+diff)
                curtabbtn:setScale(1.1, 1.1)
                curtabbtn:setLocalZOrder(2)
                CSResourceMgr.getNodeByName(resName, "icon"..curTab):setScale(1.3,1.3)
                CSResourceMgr.getNodeByName(resName, "arrows"..curTab):setVisible(true)
                --CSResourceMgr.getNodeByName(resName, "tabnew"..curTab):setVisible(false)
                UnblockLoader.cancel("BagViewMgr-reset")
                BagViewMgr.reset()

                --隐藏碎片红点
                if var == 5 and BagViewMgr.ADDREDPOINT then
                    local tab5 = CSResourceMgr.getNodeByName(resName, "tab5")
                    CSResourceMgr.seekNodeByName(tab5,"redPoint"):setVisible(false)
                    BagViewMgr.ADDREDPOINT = false
                end
        	end)
            CSResourceMgr.setLabelColor(resName, "tabt"..var, unselColor)
            CSResourceMgr.setLabelString(resName, "tabt"..var, tabName[var],"",unselOutColor)
            CSResourceMgr.getNodeByName(resName, "tabt"..var):setPositionY(25)
            CSResourceMgr.setButtonEnabled(resName, "tab"..var, true)
            local tabbtn = CSResourceMgr.getNodeByName(resName, "tab"..var)
            tabbtn:setPositionY(98+diff)
            tabbtn:setScale(1, 1)
            tabbtn:setLocalZOrder(1)
            CSResourceMgr.getNodeByName(resName, "icon"..var):setScale(1,1)
            CSResourceMgr.getNodeByName(resName, "arrows"..var):setVisible(false)
            --CSResourceMgr.setLabelString(resName, "tabnum"..var, #bagInfo[var], "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        end
        CSResourceMgr.setLabelColor(resName, "tabt"..curTab, selColor)
        CSResourceMgr.setLabelString(resName, "tabt"..curTab, tabName[curTab],"",selOutColor)
        CSResourceMgr.getNodeByName(resName, "tabt"..curTab):setPositionY(22)
        CSResourceMgr.setButtonEnabled(resName, "tab"..curTab, false)
        local curtabbtn = CSResourceMgr.getNodeByName(resName, "tab"..curTab)
        curtabbtn:setPositionY(103+diff)
        curtabbtn:setScale(1.1, 1.1)
        curtabbtn:setLocalZOrder(2)
        CSResourceMgr.getNodeByName(resName, "icon"..curTab):setScale(1.3,1.3)
        CSResourceMgr.getNodeByName(resName, "arrows"..curTab):setVisible(true)
        --CSResourceMgr.getNodeByName(resName, "tabnew"..curTab):setVisible(false)
        
        -- CSResourceMgr.getNodeByName(resName, "title_diban"):setVisible(CSResourceMgr.getScreenType())
        
        --...
        for i=1,5 do
            if i >#tabName then
                CSResourceMgr.getNodeByName(resName, "tab"..i):setVisible(false)
            end
        end

        --检测是否添加碎片红点
        if curTab == 5 then
            BagViewMgr.ADDREDPOINT = false
        elseif BagViewMgr.ADDREDPOINT then
            local tab5 = CSResourceMgr.getNodeByName(resName, "tab5")
            CSResourceMgr.seekNodeByName(tab5,"redPoint"):setVisible(true)
        end

        isLoaded = true
    end
    
    local function playCSB()
        CSResourceMgr.getCsbObj(resName):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resName), "up")
        StatusBarMgr.showTopInfoBar(function()
            BagViewMgr.hide()
        end)
    end
    
    local function initBagItem()
        BagViewMgr.reset()
    end
    -- loadBG()
    -- loadCSB()
    -- playCSB()
    -- initBagItem()

    local funcTable = {loadBG, loadCSB, initBagItem, playCSB}

    UnblockLoader.load(funcTable, "BagViewMgr")
end

function BagViewMgr.hide()
    UIStack.pop("BagViewMgr")

    --碎片红点用
    if BagViewMgr.ADDREDPOINT then
        BasicMenuMgr.addRedPoint(2,true)
    end
    StatusBarMgr.hideTopInfoBar()
    UnblockLoader.cancel("BagViewMgr")
    UnblockLoader.cancel("BagViewMgr-reset")
    labelTable = {}
    buttonTable = {}
    indexTable = {}
    lastSelItem = nil
    BagViewMgr.remove()
    CSResourceMgr.removeCSObjectByTag(resName)
    CSResourceMgr.removeCSObjectByTag(resNameBG, "BagViewMgr")
    GameAudio.playUISound("retract")
    HighPerformList.resetAllSchedule()
    isLoaded = false
end

function BagViewMgr.update(id, num, noReset)

    AuctionMgrNew.updateAuctionItem(id)
    if not isLoaded then
        return
    end
    local itemNum = localItemNum
    if curTab~=5 then
        itemNum = BagViewMgr.refreshItemInfo()
    end
    if not labelTable[id] then
        if not noReset then
            BagViewMgr.reset()
        end
        return
    end
	if num<=0 then  
        -- CSResourceMgr.setLabelString(resName, "bagsize", CocosModuleMgr.createStringWithFormat({"<1>/<2>", 
        --     itemNum, CharInfo.get().itempacketnum}))
        local bagSizeOne = CSResourceMgr.getNodeByName(resName, "bagsize1")
        bagSizeOne:removeAllChildren()
        CSResourceMgr.setLabelColor(resName, "bagsize1", {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelString(resName, "bagsize1", itemNum, "", {r=0,g=0,b=0,a=255})

        local bagSizeTwo = CSResourceMgr.getNodeByName(resName, "bagsize2")
        bagSizeTwo:removeAllChildren()
        CSResourceMgr.setLabelColor(resName, "bagsize2", {r=254,g=243,b=57,a=255})
        CSResourceMgr.setLabelString(resName, "bagsize2", "/"..CharInfo.get().itempacketnum+(CharInfo.get().furnituresuitcasevaluerate or 0), "", {r=0,g=0,b=0,a=255})
        -- local richtext = CocosModuleMgr.createRichLabel(bagSize, CocosModuleMgr.createRichLabelString({{color="00FF00", text=itemNum},
        --     {color="FFFFFF", text="/"..CharInfo.get().itempacketnum}}), 20, "cuyuan_GBK.ttf", 640)
        BagViewMgr.reset()
        return
	end
	local label = labelTable[id]
	if label then
        if num==1 then
            CSResourceMgr.setLabelStringByNode(label, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        elseif num>999 then
            CSResourceMgr.setLabelStringByNode(label, "999+", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        else
            CSResourceMgr.setLabelStringByNode(label, num, CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        end
        local itemBtn = label:getParent()
        if itemBtn then
            CSResourceMgr.clickEventBindingByNode(itemBtn, function()
                CocosModuleMgr.hideShiningToNode(itemBtn)
                ItemInfoViewMgr.show({id = id, sum = num,type = 1,objID = 0})
                if lastSelItem then
                    CSResourceMgr.seekNodeByName(lastSelItem, "light"):setVisible(false)
                end
                CSResourceMgr.seekNodeByName(itemBtn,"light"):setVisible(true)
                lastSelItem = itemBtn
            end, 3)
        end
        if curTab == 5 then
            CSResourceMgr.seekNodeByName(itemBtn,"redPoint"):setVisible(BagViewMgr.checkPieceEnough({id, num}))
        end
	end
end

function BagViewMgr.remove()
	panelTable = {}
    CSResourceMgr.removeList(resName, "list")
end

function BagViewMgr.reset()
    labelTable = {}
    buttonTable = {}
    lastSelItem = nil
    local funcTable = {}
    BagViewMgr.remove()
    local list = CSResourceMgr.getNodeByName(resName, "list")

    bagItems = {}
    bagItems[1] = {}
    bagItems[2] = {}
    bagItems[3] = {}
    bagItems[4] = {}
    bagItems[5] = {}
    itemPanels = {}
    UnblockLoader.cancel("BagViewMgr-reset")

    local function itemFunc(parent,rank,bagItemInfo,i)
        local label = CSResourceMgr.seekNodeByName(parent, "l"..rank)
        if bagItemInfo[2]==1 then
            CSResourceMgr.setLabelStringByNode(label, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        elseif bagItemInfo[2]>999 then
            CSResourceMgr.setLabelStringByNode(label, "999+", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        else
            CSResourceMgr.setLabelStringByNode(label, bagItemInfo[2], CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        end

        --界面刷新BUG改动
        if curTab~=5 then
            if indexTable[i-32] then
                labelTable[indexTable[i-32]] = nil
                indexTable[i-32] = nil
            elseif indexTable[i+32] then
                labelTable[indexTable[i+32]] = nil
                indexTable[i+32] = nil
            end
            labelTable[bagItemInfo[1]] = label
            indexTable[i] = bagItemInfo[1]
        else
            labelTable[bagItemInfo[1]] = label
        end
        --[[
        if bagItemInfo[2]>=99 then --达到数量上限
            label:setTextColor({r=255,g=201,b=101,a=255})                    
        else
            label:setTextColor({r=255,g=255,b=255,a=255})
        end
        --]]
        local diban = CSResourceMgr.seekNodeByName(parent, "b"..rank)
        local sprite = CSResourceMgr.seekNodeByName(parent, "s"..rank)
        local iconpath = ItemInfo.getItemInfoById(bagItemInfo[1]).icon
        local btnRes = ItemInfo.getItemRareBGImage(bagItemInfo[1])
        bagItems[curTab][i] = diban

        local petPieceInfo = {}
        local pokemonInfo = {}
        if curTab == 5 then
            petPieceInfo = ItemInfo.getPetPieceInfoById(bagItemInfo[1])
            pokemonInfo = PokemonInfo.getPokemonInfoByID(PokemonInfo.getGeneInfoByID(petPieceInfo.pokeID).petID)
            local name = CSResourceMgr.seekNodeByName(diban,"name")
            CSResourceMgr.setLabelStringByNode(name, petPieceInfo.name, CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS,nil,144)
            CSResourceMgr.setLabelColorByNode(name,PokemonInfo.COLOR[pokemonInfo.rarePoint])
            iconpath =  "Pet/PetIcon/"..pokemonInfo.icon..".png"
            CSResourceMgr.seekNodeByName(diban, "mask"):setScale(0.9,0.9)
            local icon1 = "UI/CommonFiles/"..pokemonInfo.elementAtt1..".png"
            -- local icon2 = "Pet/AttriIcon/small_"..pokemonInfo.elementAtt1..".png"
            CSResourceMgr.seekNodeByName(diban,"attr"):loadTexture(icon1)
            CSResourceMgr.seekNodeByName(diban,"attr"):setScale(0.5)
            -- CSResourceMgr.seekNodeByName(diban,"attrBack"):loadTexture(icon2)
            CSResourceMgr.seekNodeByName(diban,"rare"):loadTexture(orderString[pokemonInfo.rarePoint])
        end

        CSResourceMgr.setButtonTextureByNode(sprite, iconpath, iconpath, iconpath)
        sprite:setScale(curTab ~= 5 and 1.4 or 1.2)
        -- sprite:setScale(0, 0)
        -- sprite:setRotation(180)
        -- transition.scaleTo(sprite, {scale = curTab ~= 5 and 1.4 or 1.2, time = 0.2})
        -- transition.rotateTo(sprite, {rotate = 360, time = 0.2})

        CSResourceMgr.setButtonTextureByNode(diban, btnRes, btnRes, btnRes)
        CSResourceMgr.clickEventBindingByNode(diban, function()
            local newTip = CSResourceMgr.seekNodeByName(parent, "n"..rank)
            CocosModuleMgr.hideShiningToNode(newTip)
            if bagItemInfo[1] == 11100 then
                BattleManualMgr.show(SceneMgr.getRunningScene)
            else
                ItemInfoViewMgr.show({id = bagItemInfo[1], sum = bagItemInfo[2],type = 1,objID = bagItemInfo[4] or 0})
            end
            if lastSelItem then
                CSResourceMgr.seekNodeByName(lastSelItem, "light"):setVisible(false)
            end
            CSResourceMgr.seekNodeByName(diban, "light"):setVisible(true)
            lastSelItem = diban
        end,3)

        -- diban:setScale(0, 0)
        diban:setVisible(true)
        -- transition.scaleTo(diban, {scale = 1, time = 0.1})
        buttonTable[bagItemInfo[1]] = diban
        
        for key, var in pairs(ItemInfo.getNewItem()) do
            if var==bagItemInfo[1] then
                local newTip = CSResourceMgr.seekNodeByName(parent, "n"..rank)
                CocosModuleMgr.showShiningToNode(newTip, 1)
                table.remove(ItemInfo.getNewItem(), key)
            end
        end
        --local nameLabel = CSResourceMgr.seekNodeByName(parent, "n"..rank)
        --CSResourceMgr.setLabelStringByNode(nameLabel, itemInfo[bagItemInfo[1]].name)
        --nameLabel:setTextColor({r=0,g=0,b=0,a=255})

        if curTab == 5 then
            CSResourceMgr.seekNodeByName(diban,"redPoint"):setVisible(BagViewMgr.checkPieceEnough(bagItemInfo))
        end
    end

    local spawncount = curTab==5 and 7 or 8
    local countperline = 4
    local allnum = countperline*spawncount
    for i=1, #bagInfo[curTab] do
        if i>allnum then break end
        local row = math.ceil(i/BagViewMgr.RANK_NUM)
        local rank = i%BagViewMgr.RANK_NUM
        if rank==0 then
            rank = BagViewMgr.RANK_NUM
        end
        if rank==1 then
            local panelName = curTab ~= 5 and "panel" or "panel2" 
            local panel = CSResourceMgr.getNodeByName(resName, panelName):clone()
            table.insert(panelTable, panel)
            list:pushBackCustomItem(panel)
            itemPanels[row] = panel
    	end
        local bagItemInfo = bagInfo[curTab][i]

        -- table.insert(funcTable, itemFunc)
        itemFunc(panelTable[row],rank,bagItemInfo,i)
    end 

    -- UnblockLoader.load(funcTable, "BagViewMgr-reset")

    HighPerformList.makeHighPerFormVerticalList(list,spawncount,0,countperline,curTab==5 and 190 or 160,curTab==5 and 180 or 150,bagInfo[curTab],
            function(item,currentindex)
                
                for j=1,countperline do 
                    local bagItemInfo = bagInfo[curTab][currentindex+j-1]
                    local diban = CSResourceMgr.seekNodeByName(item, "b"..j)
                    if bagItemInfo == nil then 
                        diban:setVisible(false)
                    else
                        diban:setVisible(true)
                        itemFunc(item,j,bagItemInfo,currentindex)
                    end

                end
            end)    
end

function BagViewMgr.checkPieceEnough(bagItemInfo)
    local petPieceInfo = ItemInfo.getPetPieceInfoById(bagItemInfo[1])
    return bagItemInfo[2]>=petPieceInfo.num
end

function BagViewMgr.getItemButton(itemID)
    return buttonTable[itemID]
end

-- 排序规则：分页>品质>ID
function BagViewMgr.sortBagItems(bagInfos)
    table.sort(bagInfos, function(a, b)
        local aID = a[1]
        local bID = b[1]
		local aRare = itemInfoRareTable[aID]
		local bRare = itemInfoRareTable[bID]
		
       -- local aRare = ItemInfo.getItemInfoById(a[1]).itemRare
       -- local bRare = ItemInfo.getItemInfoById(b[1]).itemRare
        if aRare ~= bRare then
            return aRare > bRare
        else
            if aID ~= bID then
                return bID > aID
            end
        end
    end)
    return bagInfos
end

function BagViewMgr.sortPetPiece(bagInfos)
    for k,v in pairs(bagInfos) do
        if v[2] == 0 then
            table.remove(bagInfos,k)
        end
    end
    local bagInfo = bagInfos
    local rareInfo = {}
    for key, var in pairs(bagInfo) do
        local petPieceInfo = ItemInfo.getPetPieceInfoById(var[1])
        if petPieceInfo then
            local pokemonInfo = PokemonInfo.getPokemonInfoByID(PokemonInfo.getGeneInfoByID(petPieceInfo.pokeID).petID)
            rareInfo[var[1]] = pokemonInfo.rarePoint
        else
            print(var[1], "宠物碎片找不到")
        end
    end
    table.sort(bagInfo, function(a, b)
        local aRare = rareInfo[a[1]]
        local bRare = rareInfo[b[1]]
        if BagViewMgr.INGUIDE then
            if a[1] == 38007 then
                return true
            elseif b[1] == 38007 then
                return false
            elseif aRare ~= bRare then
                return aRare > bRare
            end
        else
            if aRare ~= bRare then
                return aRare > bRare
            end
        end
    end)

    return bagInfo
end

function BagViewMgr.getBagInfo()
    return bagInfo
end

function BagViewMgr.setVisible(visible)
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    if visible == false then
        StatusBarMgr.hideTopInfoBar()
    else
        StatusBarMgr.showTopInfoBar(function()
            BagViewMgr.hide()
        end)
    end
end

function BagViewMgr.addPetPiece(jsStr)
    if not bagInfo[5] then
        bagInfo[5] = {}
    end
    local cjson = require("cjson")
    local isAddRedPoint = false
    for k,v in pairs(jsStr) do
        local var = cjson.decode(v) or {}
        --print("PetEquipmentMgr.addPetEquipment................................................",var.itemID, var.num)
        if PetEquipmentMgr.addPetEquipment(var.itemID, var.num)~=true then 
            local havePiece = BagViewMgr.isHavePetPiece(var.itemID)
            if havePiece then
                bagInfo[5][havePiece][2] = var.num
            else
                table.insert(bagInfo[5], {var.itemID, var.num})
            end
            BagViewMgr.update(var.itemID, var.num, true)

            if isAddRedPoint == false then 
                 --加碎片红点用
                if BagViewMgr.checkPieceEnough({var.itemID, var.num}) then
                    BagViewMgr.ADDREDPOINT = true
                    BasicMenuMgr.addRedPoint(2, true)
                    isAddRedPoint = true
                end

            end
        end

    end

    --[[
    --加碎片红点用
    for k,v in pairs(jsStr) do
        local var = cjson.decode(v) or {}
        if BagViewMgr.checkPieceEnough({var.itemID, var.num}) then
            BagViewMgr.ADDREDPOINT = true
            BasicMenuMgr.addRedPoint(2, true)
            break
        end
    end
    ]]
end

function BagViewMgr.isHavePetPiece(id)
    for k,v in pairs(bagInfo[5]) do
        if v[1] == id then
            return k
        end
    end
    return false
end

function BagViewMgr.syncItemInfoWithServer()
    NetInterface.send("GC_GetItemPacket_Ack", function()
        local ItemSend = require("src.Net.Send.ItemSend")
        ItemSend.sendCG_GetItemPacket_Req()
    end)
end

function BagViewMgr.getItemNum(itemID)
    BagViewMgr.refreshItemInfo()
    for i=1,#bagInfo[1] do
        if bagInfo[1][i][1]==itemID then
            return bagInfo[1][i][2]
        end
    end
    return 0
end

function BagViewMgr.getPieceNum(pieceID)
    BagViewMgr.refreshItemInfo()
    for i=1,#bagInfo[5] do
        if bagInfo[5][i][1]==pieceID then
            return bagInfo[5][i][2]
        end
    end
    return 0
end

function BagViewMgr.getCurTab()
    return curTab
end

return BagViewMgr