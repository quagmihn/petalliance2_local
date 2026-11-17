local TreeInfoView = {}

local resName = {}
local resNameA = {}
local treesData = {}
local compoundPetInfo = {}
TreeInfoView.isOpenBox = false

function TreeInfoView.Init()
    resName = "Player/Tree/TreeInfoView.csb"
    resNameA = "Player/Tree/TreeAwardInfoView.csb"
    treesData = {}
    compoundPetInfo = {}
    TreeInfoView.isOpenBox = false
end

function TreeInfoView.show(treeData)
    if CSResourceMgr.getCsbObj(resName) then
        return
    end
    local scene = SceneMgr.getRunningScene
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320,480)
        curLayer:setVisible(false)

        CSResourceMgr.clickEventBinding(resName, "close", function()
            TreeInfoView.hide()
        end)

        TreeInfoView.reset(treeData)

        --许愿树钻石上限设置
        TreeInfoView.setTreeTimeInfo()
    end

    local function playCSB()
        CSResourceMgr.getCsbObj(resName):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resName), "down")
    end

    local funcTable = {loadCSB, playCSB}
    UnblockLoader.load(funcTable, "TreeInfoView")
end

function TreeInfoView.hide()
    UnblockLoader.cancel("TreeInfoView")
    CSResourceMgr.removeCSObjectByTag(resName)
end

function TreeInfoView.reset(treeData)
    local wishingTreeInfo = ItemInfo.getWishingTreeInfoById(treeData.treeIndex)
    if not wishingTreeInfo then
        return
    end
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end

    CSResourceMgr.setLabelColor(resName, "title", {r=160,g=235,b=250,a=255})
    CSResourceMgr.setLabelString(resName, "title", wishingTreeInfo.name, "", {r=37,g=54,b=75,a=255})
    local lookAwardBtn = CSResourceMgr.getNodeByName(resName, "lookAwardBtn")
    CSResourceMgr.setButtonStringByNode(lookAwardBtn, "TreeInfo1", {r=0,g=0,b=0,a=255,w=1,s=1})
    CSResourceMgr.setButtonStringColorByNode(lookAwardBtn, {r=255,g=255,b=255,a=255})
    local hopeBtn = CSResourceMgr.getNodeByName(resName, "hopeBtn")
    CSResourceMgr.setButtonStringByNode(hopeBtn, "TreeInfo2", {r=0,g=0,b=0,a=255,w=1,s=1})
    CSResourceMgr.setButtonStringColorByNode(hopeBtn, {r=255,g=255,b=255,a=255})
    local playerNameLabel = CSResourceMgr.getNodeByName(resName, "playerNameLabel")
    CSResourceMgr.setLabelColorByNode(playerNameLabel, {r=144,g=238,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(playerNameLabel, "TreeInfo3", {r=0,g=0,b=0,a=255,w=1,s=1})
    local playerName = CSResourceMgr.getNodeByName(resName, "playerName")
    CSResourceMgr.setLabelColorByNode(playerName, treeData.id == CharInfo.getCharID() and {r=255,g=240,b=0,a=255} or {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(playerName, treeData.ownerName, {r=0,g=0,b=0,a=255,w=1,s=1})
    local expLabel = CSResourceMgr.getNodeByName(resName, "expLabel")
    CSResourceMgr.setLabelColorByNode(expLabel, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(expLabel, "TreeInfo12", {r=0,g=0,b=0,a=255,w=1,s=1})
    local expValue = CSResourceMgr.getNodeByName(resName, "expValue")
    CSResourceMgr.setLabelColorByNode(expValue, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(expValue, treeData.exp.."/"..wishingTreeInfo.levelInfos[treeData.level].wishCount, {r=0,g=0,b=0,a=255,w=1,s=1})
    local lv1 = CSResourceMgr.getNodeByName(resName, "lv1")
    CSResourceMgr.setLabelColorByNode(lv1, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(lv1, "Lv."..treeData.level, {r=0,g=0,b=0,a=255,w=1,s=1})
    local lv2 = CSResourceMgr.getNodeByName(resName, "lv2")
    CSResourceMgr.setLabelColorByNode(lv2, {r=255,g=240,b=0,a=255})
    CSResourceMgr.setLabelStringByNode(lv2, "/"..#wishingTreeInfo.levelInfos, {r=0,g=0,b=0,a=255,w=1,s=1})
    local tip = CSResourceMgr.getNodeByName(resName, "tip")
    CSResourceMgr.setLabelColorByNode(tip, {r=123,g=148,b=185,a=255})
    CSResourceMgr.setLabelStringByNode(tip, "TreeInfo4", {r=0,g=0,b=0,a=255,w=1,s=1})
    local label = CSResourceMgr.getNodeByName(resName, "label")
    CSResourceMgr.setLabelColorByNode(label, {r=144,g=238,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(label, "TreeInfo5", {r=0,g=0,b=0,a=255,w=1,s=1})
    local time = CSResourceMgr.getNodeByName(resName, "time")
    CSResourceMgr.setLabelColorByNode(time, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(time, "", {r=0,g=0,b=0,a=255,w=1,s=1})
    local awardLabel = CSResourceMgr.getNodeByName(resName, "awardLabel")
    CSResourceMgr.setLabelColorByNode(awardLabel, {r=144,g=238,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(awardLabel, "TreeInfo6", {r=0,g=0,b=0,a=255,w=1,s=1})
    local expBar = CSResourceMgr.getNodeByName(resName, "expBar")
    expBar:setPercent(treeData.exp*100/wishingTreeInfo.levelInfos[treeData.level].wishCount)   
    if treeData.id == CharInfo.getCharID() then
        local second = treeData.plantTime+wishingTreeInfo.ripeTime-CharInfo.getServerTime()
        second = second>=0 and second or 0
        CocosModuleMgr.setTimeLabelCountDown(time, second,function()
            CSResourceMgr.setButtonEnabledByNode(hopeBtn, false)
        end) 
        CSResourceMgr.getNodeByName(resName, "OKTime"):setVisible(true)
    else
        tip:setVisible(true)
    end
    if treeData.isPrayed == 1 then
        CSResourceMgr.setButtonEnabledByNode(hopeBtn, false)
    end

    local awardVecs = wishingTreeInfo.levelInfos[treeData.level].ripeAward
    local list = CSResourceMgr.getNodeByName(resName, "list")
    CSResourceMgr.removeListByNode(list)
    for i=1,#awardVecs do
        local item = CSResourceMgr.getNodeByName(resName, "item"):clone()
        item:setVisible(true)
        list:pushBackCustomItem(item) 
        local itemIcon = CSResourceMgr.seekNodeByName(item, "itemIcon")
        local itemNum = CSResourceMgr.seekNodeByName(item, "itemNum")
        CSResourceMgr.setLabelColorByNode(itemNum, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(itemNum, awardVecs[i].num, {r=0,g=0,b=0,a=255},nil,60)
        if awardVecs[i].type == 1 then
            CSResourceMgr.setSpriteTextureByNode(itemIcon, "UI/CommonFiles/icon_jinbi.png")
            CSResourceMgr.clickEventBindingByNode(item, function()
                ItemInfoViewMgr.show({id = 9998, awardVecs[i].num, type = 1}, false)
            end, 1)
        elseif awardVecs[i].type == 2 then
            CSResourceMgr.setSpriteTextureByNode(itemIcon, "UI/CommonFiles/ico_lanzuan.png")
            CSResourceMgr.clickEventBindingByNode(item, function()
                ItemInfoViewMgr.show({id = 9999, awardVecs[i].num, type = 1}, false)
            end, 1)
        else
            local awardElementInfo = ItemInfo.getAwardElementInfoById(tonumber(awardVecs[i].type))
            local itemInfo = ItemInfo.getItemInfoById(awardElementInfo.elementID)
            local itemType = ItemInfo.getItemType(awardElementInfo.elementID)
            local btnRes = ItemInfo.getItemRareBGImage(awardElementInfo.elementID)
            if itemType==4 then
                local petPieceInfo = ItemInfo.getPetPieceInfoById(awardElementInfo.elementID)
                local pokemonInfo = PokemonInfo.getPokemonInfoByID(PokemonInfo.getGeneInfoByID(petPieceInfo.pokeID).petID)
                awardIconPath =  "Pet/PetIcon/"..pokemonInfo.icon..".png"
                CSResourceMgr.seekNodeByName(item, "mask"):setVisible(true)
                itemIcon:setScale(1.1,1.1)
            else
                awardIconPath =itemInfo.icon
            end
            CSResourceMgr.setButtonTextureByNode(item, btnRes,btnRes,btnRes)
            CSResourceMgr.setSpriteTextureByNode(itemIcon, awardIconPath)
            CSResourceMgr.clickEventBindingByNode(item, function()
                ItemInfoViewMgr.show({id = itemInfo.id, awardVecs[i].num, type = 1}, false)
            end, 1)
        end
    end

    CSResourceMgr.clickEventBindingByNode(lookAwardBtn, function()
        TreeInfoView.showAwardInfoView(treeData)
    end)

    CSResourceMgr.clickEventBindingByNode(hopeBtn, function()
        NetInterface.send("GC_PrayToTree_Ack", function()
                local WishingTreeSend = require("src.Net.Send.WishingTreeSend")
                WishingTreeSend.sendCG_PrayToTree_Req({treeID = treeData.id})
            end,function()
                --许愿树钻石上限设置
                TreeInfoView.setTreeTimeInfo()
                CSResourceMgr.setButtonEnabledByNode(hopeBtn, false)
                treeData.isPrayed = 1
            end,function(code)
                if code == Proto.Error.ERROR_TREE_ALREADY_PRAY then
                       StandardTipsMgr.show(1,"TreeInfo9")
                end
            end)
    end)
end

function TreeInfoView.showAwards(data)
    local cjson = require("cjson") 
    local awardInfos = {}
    for kk,vv in pairs(data) do
        print(vv)
        local tbl = cjson.decode(vv)
        if tbl.elementType=="pet" then
            local petID = 0
            local petNum = tbl.elementID
        else
            local itemID = 0
            if tbl.elementType=="g_cash" then
                itemID = 9998
            elseif tbl.elementType=="m_cash" then
                itemID = 9999
            elseif tbl.elementType=="item" then
                itemID = tbl.elementID
            end
            local itemNum = tbl.num
            table.insert(awardInfos,{itemID,itemNum})
        end
    end
    local function showGetPet()
        for k,v in pairs(compoundPetInfo) do
            GachaViewMgr.playGetAPet(v.pokeID, v, function ()
                showGetPet()
            end)
            table.remove(compoundPetInfo, 1)
            if #compoundPetInfo == 0 then
                TreeInfoView.isOpenBox = false
            end
            return
        end
    end
    if #awardInfos>0 then
        AwardsListMgr.show(SceneMgr.getRunningScene, awardInfos)
    end
    if #compoundPetInfo == 0 then
        TreeInfoView.isOpenBox = false
    else
        showGetPet()
    end
end

function TreeInfoView.setCompoundPetInfo(jsStr)
    if TreeInfoView.isOpenBox then
        local cjson = require("cjson")
        local tbl = cjson.decode(jsStr)
        table.insert(compoundPetInfo, tbl)
    end
end

function TreeInfoView.resetCompoundPetInfo()
    TreeInfoView.isOpenBox = true
    compoundPetInfo = {}
end

function TreeInfoView.setTreesData(data)
    treesData = data
    for k,v in pairs(treesData) do
        v["_id"] = v.treeID
        TreeInfoView.plantTree(v)
        for kk,vv in pairs(v) do
            print("vdsxvdfxvf",kk,vv)
        end
    end
end

function TreeInfoView.plantTree(treeData,isNew)
    print("plant success")
    if isNew then
        table.insert(treesData,treeData)
    end
    treeData.id = treeData["_id"]
    local wishingTreeInfo = ItemInfo.getWishingTreeInfoById(treeData.treeIndex)
    if not wishingTreeInfo then
        return
    end
    local removeTime = treeData.plantTime+wishingTreeInfo.ripeTime
    TownTreeMgr.addTree(treeData.id, wishingTreeInfo.name, treeData.ownerName, "Item/wishTree/xys"..tostring(treeData.treeIndex+2)..".png", treeData.level, tonumber(treeData.targetStr), function()
        TreeInfoView.show(treeData)
    end,removeTime)
end

function TreeInfoView.showAwardInfoView(treeData)
    if CSResourceMgr.getCsbObj(resNameA) then
        return
    end
    local scene = SceneMgr.getRunningScene
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resNameA)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameA, 320,480)
        curLayer:setVisible(false)

        CSResourceMgr.clickEventBinding(resNameA, "close", function()
            local list = CSResourceMgr.getNodeByName(resNameA, "list")
            CSResourceMgr.removeListByNode(list)
            UnblockLoader.cancel("TreeInfoView.showAwardInfoView")
            UnblockLoader.cancel("TreeInfoView.setAwardInfo")
            CSResourceMgr.removeCSObjectByTag(resNameA)
        end)
        
        TreeInfoView.setAwardInfo(treeData)
    end

    local function playCSB()
        CSResourceMgr.getCsbObj(resNameA):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resNameA), "down")
    end

    local funcTable = {loadCSB, playCSB}
    UnblockLoader.load(funcTable, "TreeInfoView.showAwardInfoView")
end

function TreeInfoView.setAwardInfo(treeData)
    local funcTable = {}
    local list = CSResourceMgr.getNodeByName(resNameA, "list")
    CSResourceMgr.removeListByNode(list)
    local wishingTreeInfo = ItemInfo.getWishingTreeInfoById(treeData.treeIndex)
    CSResourceMgr.setLabelColor(resNameA, "title", {r=160,g=235,b=250,a=255})
    CSResourceMgr.setLabelString(resNameA, "title", wishingTreeInfo.name, "", {r=37,g=54,b=75,a=255})
    local label = CSResourceMgr.getNodeByName(resNameA, "tips")
    local richLabel = CocosModuleMgr.createRichLabel(label, CocosModuleMgr.createStringWithFormat({"TreeInfo7",
        tostring(treeData.treeIndex),wishingTreeInfo.name}), 22, "cuyuan_GBK.ttf", TownChatMgr.MAX_LABEL_WIDTH,nil,nil,nil,true)
    label:setString(" ")
    label:setTextAreaSize({width = 0, height = richLabel.realHeight})
    label:ignoreContentAdaptWithSize(false)

    for i=1,#wishingTreeInfo.levelInfos do
        local awardPanel = CSResourceMgr.getNodeByName(resNameA, "awardPanel"):clone()
        awardPanel:setVisible(true)
        list:pushBackCustomItem(awardPanel) 
        CSResourceMgr.seekNodeByName(awardPanel,"descBack"):setColor({r=5,g=23,b=43,a=255})
        local awardVecs = wishingTreeInfo.levelInfos[i].ripeAward
        local awardList = CSResourceMgr.seekNodeByName(awardPanel, "awardList")
        CSResourceMgr.removeListByNode(awardList)
        local label = CSResourceMgr.seekNodeByName(awardPanel, "desc")
        local richLabel = CocosModuleMgr.createRichLabel(label, CocosModuleMgr.createStringWithFormat({"TreeInfo8",
            tostring(i),tostring(wishingTreeInfo.levelInfos[i].wishCount)}), 24, "cuyuan_GBK.ttf", TownChatMgr.MAX_LABEL_WIDTH,nil,nil,nil,true)
        label:setString(" ")
        label:setTextAreaSize({width = 0, height = richLabel.realHeight})
        label:ignoreContentAdaptWithSize(false)

        for i=1,#awardVecs do
            table.insert(funcTable,function()
                local item = CSResourceMgr.getNodeByName(resNameA, "item"):clone()
                item:setVisible(true)
                awardList:pushBackCustomItem(item) 
                local itemIcon = CSResourceMgr.seekNodeByName(item, "itemIcon")
                local itemNum = CSResourceMgr.seekNodeByName(item, "itemNum")
                CSResourceMgr.setLabelColorByNode(itemNum, {r=255,g=255,b=255,a=255})
                CSResourceMgr.setLabelStringByNode(itemNum, awardVecs[i].num, {r=0,g=0,b=0,a=255},nil,60)
                if awardVecs[i].type == 1 then
                    CSResourceMgr.setSpriteTextureByNode(itemIcon, "UI/CommonFiles/icon_jinbi.png")
                    CSResourceMgr.clickEventBindingByNode(item, function()
                        ItemInfoViewMgr.show({id = 9998, awardVecs[i].num, type = 1}, false)
                    end, 1)
                elseif awardVecs[i].type == 2 then
                    CSResourceMgr.setSpriteTextureByNode(itemIcon, "UI/CommonFiles/ico_lanzuan.png")
                    CSResourceMgr.clickEventBindingByNode(item, function()
                        ItemInfoViewMgr.show({id = 9999, awardVecs[i].num, type = 1}, false)
                    end, 1)
                else
                    local awardElementInfo = ItemInfo.getAwardElementInfoById(tonumber(awardVecs[i].type))
                    local itemInfo = ItemInfo.getItemInfoById(awardElementInfo.elementID)
                    local itemType = ItemInfo.getItemType(awardElementInfo.elementID)
                    local btnRes = ItemInfo.getItemRareBGImage(awardElementInfo.elementID)
                    if itemType==4 then
                        local petPieceInfo = ItemInfo.getPetPieceInfoById(awardElementInfo.elementID)
                        local pokemonInfo = PokemonInfo.getPokemonInfoByID(PokemonInfo.getGeneInfoByID(petPieceInfo.pokeID).petID)
                        awardIconPath =  "Pet/PetIcon/"..pokemonInfo.icon..".png"
                        CSResourceMgr.seekNodeByName(item, "mask"):setVisible(true)
                        itemIcon:setScale(1.1,1.1)
                    else
                        awardIconPath =itemInfo.icon
                    end
                    CSResourceMgr.setButtonTextureByNode(item, btnRes,btnRes,btnRes)
                    CSResourceMgr.setSpriteTextureByNode(itemIcon, awardIconPath)
                    CSResourceMgr.clickEventBindingByNode(item, function()
                        ItemInfoViewMgr.show({id = itemInfo.id, awardVecs[i].num, type = 1}, false)
                    end, 1)
                end
                item:setScale(0)
                item:scaleTo(0.1,1)
            end)
        end
    end
    UnblockLoader.load(funcTable, "TreeInfoView.setAwardInfo")
end

function TreeInfoView.addTreeExp(treeID)
    local expValue = nil
    local lv1 = nil
    local expBar = nil
    if CSResourceMgr.getCsbObj(resName) then
        expValue = CSResourceMgr.getNodeByName(resName, "expValue")
        lv1 = CSResourceMgr.getNodeByName(resName, "lv1")
        expBar = CSResourceMgr.getNodeByName(resName, "expBar")   
    end
    for k,v in pairs(treesData) do
        if v.id == treeID then
            local wishingTreeInfo = ItemInfo.getWishingTreeInfoById(v.treeIndex)
            if not wishingTreeInfo then
                return
            end
            if v.exp+1<wishingTreeInfo.levelInfos[v.level].wishCount then
                v.exp = v.exp + 1
            elseif v.exp+1==wishingTreeInfo.levelInfos[v.level].wishCount then
                if v.level == #wishingTreeInfo.levelInfos then
                    v.exp = v.exp + 1
                else 
                    v.exp = 0
                    v.level = v.level + 1
                    if CSResourceMgr.getCsbObj(resName) then
                        CSResourceMgr.setLabelStringByNode(lv1, "Lv."..v.level, {r=0,g=0,b=0,a=255,w=1,s=1})
                    end
                    TreeInfoView.reset(v)
                end
            end
            if CSResourceMgr.getCsbObj(resName) then
                CSResourceMgr.setLabelStringByNode(expValue, v.exp.."/"..wishingTreeInfo.levelInfos[v.level].wishCount, {r=0,g=0,b=0,a=255,w=1,s=1})
                expBar:setPercent(v.exp*100/wishingTreeInfo.levelInfos[v.level].wishCount)
            end
        end
    end
end

function TreeInfoView.removeTreeData(treeID)
    for k,v in pairs(treesData) do
        if v.id == treeID then
            v = nil
        end
    end
end

function TreeInfoView.setTreeTimeInfo()
    local function set()
        local treeTimeInfo = CharInfo.get()["wishingtree"] or {timeLast = 0,mCash = 0}
        local mcashNumLB = CSResourceMgr.getNodeByName(resName, "mcashNumLB")

        local lastDay = math.floor((treeTimeInfo.timeLast+CharInfo.getServerTimeZone())/86400)
        local lastSec = (treeTimeInfo.timeLast+CharInfo.getServerTimeZone())%86400
        local today = math.floor((CharInfo.getServerTime()+CharInfo.getServerTimeZone())/86400)
        local daySec = (CharInfo.getServerTime()+CharInfo.getServerTimeZone())%86400
        print(lastDay,lastSec,today,daySec,treeTimeInfo.mCash)
        local curNum = 0

        if today>lastDay then
            if today-lastDay>1 then
                curNum = 0
            else
                if daySec<21600 and lastSec>21600 then
                    curNum = treeTimeInfo.mCash
                else
                    curNum = 0
                end
            end
        elseif today==lastDay then
            if daySec>21600 and lastSec<21600 then
                curNum = 0
            else
                curNum = treeTimeInfo.mCash
            end
        end

        mcashNumLB:removeAllChildren()
        local maxNum = SystemInfo.getGlobalConfigAddInfoByID(79).values[1]
        local richLabel = CocosModuleMgr.createRichLabel(mcashNumLB, CocosModuleMgr.createStringWithFormat({"TreeInfo13", curNum,maxNum}), 
            24, "cuyuan_GBK.ttf", TownChatMgr.MAX_LABEL_WIDTH,nil,-15,nil,true)       
    end


    NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
        local LoginSend = require("src.Net.Send.LoginSend")
        LoginSend.sendCG_GetCharacterValues_Req({"wishingTree"})
    end,function()
        set()
    end)
end

--刷新城镇里的树
function TreeInfoView.refreshTownTree()
    if SceneMgr.currentScene == "TownScene" then
        for k,v in pairs(treesData) do
            TownTreeMgr.removeTree(v.id)
            v = nil
        end
        NetInterface.send("GC_GetWishingTreesData_Ack", function()
            local WishingTreeSend = require("src.Net.Send.WishingTreeSend")
            WishingTreeSend.sendCG_GetWishingTreesData_Req()
        end)
    end
end

return TreeInfoView