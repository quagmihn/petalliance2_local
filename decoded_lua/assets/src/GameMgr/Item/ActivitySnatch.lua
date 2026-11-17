local ActivitySnatch    = {}
local snatchPlayersRes  = "Player/Friends/FriendsApplyListView.csb"
local IsGoToSnatch      = false
local snatchItems       = {}
local playerList        = {}
local winnerList        = {}
local itemsNums         = 0
local refreshInfo       = {}
local storeNums         = {}
local NewShopSend = require("src.Net.Send.NewShopSend")
local resName = "Item/snatch/recordListView.csb"

local markPathVec = {
    "Item/snatch/remark2.png",
    "Item/snatch/remark1.png"
}

function ActivitySnatch.setPlayerList(list)
    playerList = list
end

function ActivitySnatch.update(jsStr)
    print(jsStr)
    local cjson = require("cjson")
    local vec = cjson.decode(jsStr) or {}
    table.insert(winnerList, {
        charID = vec.charID,
        name = vec.name,
        fashion = vec.fashion,
        award = vec.award,
        num = vec.num
    })
end

function ActivitySnatch.insertItems(item)
    snatchItems[#snatchItems + 1] = item
end

function ActivitySnatch.setItemsNums(nums)
    itemsNums = nums
end

function ActivitySnatch.setIsGoToSnatch(isBool) 
    IsGoToSnatch = isBool
end

function ActivitySnatch.show()
    
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(SceneMgr.getRunningScene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)

        local rejectBtn = CSResourceMgr.getNodeByName(resName, "rejectBtn")
        CSResourceMgr.setButtonStringByNode(rejectBtn, "activity60", {r=0,g=0,b=0,a=255})
        CSResourceMgr.clickEventBindingByNode(rejectBtn, function ()
            -- ActivitySnatch.goToSnatch()
            CSResourceMgr.removeCSObjectByTag(resName)
        end)

        local bg = CSResourceMgr.getNodeByName(resName, "bg")
        CSResourceMgr.clickEventBindingByNode(bg, function ()
            CSResourceMgr.removeCSObjectByTag(resName)
        end)
        local tips = CSResourceMgr.getNodeByName(resName, "tips")
        local applyList = CSResourceMgr.getNodeByName(resName, "applyList")
        local list = CSResourceMgr.getNodeByName(resName, "list")
        local infoBtn = CSResourceMgr.getNodeByName(resName, "infoBtn")
        local isShow = true
        local function setInfoBtn()
            if isShow then
                CSResourceMgr.clickEventBindingByNode(infoBtn, function()
                    list:removeAllItems()
                    tips:setVisible(false)
                    applyList:setVisible(false)
                    list:setVisible(true)
                    local infoLB = CSResourceMgr.getNodeByName(resName, "infoLB"):clone()
                    list:pushBackCustomItem(infoLB)
                    local richLabelL = CocosModuleMgr.createRichLabel(infoLB, "activity54", 24, "cuyuan_GBK.ttf", 400,nil,nil,nil,true)
                    infoLB:setString(" ")
                    infoLB:setTextAreaSize({width = 0, height = richLabelL.realHeight})
                    infoLB:ignoreContentAdaptWithSize(false)
                    isShow = false
                    setInfoBtn()
                end)
            else
                CSResourceMgr.clickEventBindingByNode(infoBtn, function()
                    tips:setVisible(true)
                    applyList:setVisible(true)
                    list:setVisible(false)
                    isShow = true
                    setInfoBtn()
                end)
            end
        end
        setInfoBtn()

        local function getRankCell(var)
            local parent = CSResourceMgr.getNodeByName(resName, "applyPlayer"):clone()

            local playerName = CSResourceMgr.seekNodeByName(parent, "playerName")
            CSResourceMgr.setLabelColorByNode(playerName, var.charID ~= CharInfo.getCharID() and {r=255,g=255,b=255,a=255} or {r=255,g=252,b=0,a=255})
            CSResourceMgr.setLabelStringByNode(playerName, var.name, {r=3,g=28,b=49,a=255,w=1})
            local level = CSResourceMgr.seekNodeByName(parent, "level")
            CSResourceMgr.setLabelColorByNode(level, {r=255,g=252,b=0,a=255})
            CSResourceMgr.setLabelStringByNode(level, var.charID, {r=0,g=0,b=0,a=255,w=1})
            local cost = CSResourceMgr.seekNodeByName(parent, "cost")
            CSResourceMgr.setLabelStringByNode(cost, var.num or 1)

            local itemInfo = ItemInfo.getAwardElementInfoById(var.award)
            local item = nil
            if itemInfo.elementType == Proto.AET_PET then 
                item = ItemInfo.getPetIconById2(itemInfo.elementID, nil, nil, true)
                CSResourceMgr.seekNodeByName(item,"attr"):hide()
                CSResourceMgr.seekNodeByName(item,"attrBack"):hide()
                CSResourceMgr.seekNodeByName(item,"rare"):hide()
                CSResourceMgr.seekNodeByName(item,"rareBack"):hide()
                
                item:setScale(0.6,0.6)
            elseif itemInfo.elementType == Proto.AET_ITEM then
                item = ItemInfo.getItemIconById(itemInfo.elementID, nil, nil, true) 
                item:setScale(0.6,0.6)
            end

            local itemname = CSResourceMgr.seekNodeByName(item,"name")
            item:addTo(parent)
            item:setPosition(380,58) 
            itemname:setPosition(70,-5)

            CSResourceMgr.clickEventBindingByNode(item, function()
                if itemInfo.elementType == Proto.AET_ITEM then
                    ItemInfoViewMgr.show({id = itemInfo.elementID,type = 1}, false)
                elseif itemInfo.elementType == Proto.AET_PET then
                    PetInfoViewMgr.show(SceneMgr.getRunningScene, itemInfo.elementID)
                end
            end)

            local headIcon = CSResourceMgr.seekNodeByName(parent, "headIcon")
            headIcon:loadTexture(CharInfo.getHeadIcon(var.fashion.curFashion))

            return parent
        end

        local requestRankProcess = 0
        local showSize = 10
        local rankListObj = nil
        local list = CSResourceMgr.getNodeByName(resName, "applyList")
        rankListObj = CSResourceMgr.setCommonListInfo(winnerList, resName, "applyList", "", showSize, nil, function(id, var)
            local cellNode = getRankCell(var)
            cellNode:setVisible(true)
            list:pushBackCustomItem(cellNode)
            cellNode:setScaleY(0)
            transition.scaleTo(cellNode, {scaleY = 1, time = 0.1})
            return cellNode
        end, function(callback)
            local function completeFunc()
                requestRankProcess = requestRankProcess+showSize
                callback()
            end
            local params = {}
            requestRankProcess = 0
            winnerList = {}
            params.startIndex = requestRankProcess
            params.endIndex = requestRankProcess + 9
            NetInterface.sendWithBlock("GC_GetOneMCashShopLog_Ack",function()
                NewShopSend.sendCG_GetOneMCashShopLog_Req(params)
            end, function()
                if rankListObj then
                    rankListObj.setContent(winnerList)
                end
                completeFunc()
            end,function(code)
                TipsMgr.showError(scene, code)
            end)
        end, function(callback)
            local function completeFunc()
                requestRankProcess = requestRankProcess+showSize
                callback()
            end
            local params = {}
            params.startIndex = requestRankProcess
            params.endIndex = requestRankProcess + 9
            NetInterface.sendWithBlock("GC_GetOneMCashShopLog_Ack",function()
                NewShopSend.sendCG_GetOneMCashShopLog_Req(params)
            end, function()
                if rankListObj then
                    rankListObj.setContent(winnerList)
                end
                completeFunc()
            end,function(code)
                TipsMgr.showError(scene, code)
            end)
        end)
    end

    local function playCSB()
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName,"frame"),"down")
    end

    loadCSB()
    playCSB()
end

function ActivitySnatch.goToSnatch()
    NetInterface.sendWithBlock("GC_GETONEMCASHSHOP_ACK",function()
        NewShopSend.sendCG_GetOneMCashShop_Req()
    end, function()
        BattlePVPMgr.startCalcTime(function()
            if #snatchItems >= itemsNums then
                BattlePVPMgr.endCalcTime()
                ActivityHalloweenViewMgr.hide()
                ActivitySnatch.openSnatch()
            end
        end,0.01)
    end)
end

function ActivitySnatch.openSnatch()
    UIStack.push("ActivitySnatch", ActivitySnatch.hide, false)
    --HalloweenCapsuleEggView.hideTopInfoBar(false)

	local res 	= "Item/snatch/snatch.csb"
	ActivitySnatch.layer = CSResourceMgr.createRes(SceneMgr.getRunningScene,res)
	local list  = CSResourceMgr.getNodeByName(res,"list")
	local btn   = CSResourceMgr.getNodeByName(res,"btn")
    -- local snatchNodes = {}

	ActivitySnatch.layer:zorder(CocosModuleMgr.ZORDER_WINDOW)

	local function createBtn(buyVal,tottalVal,sendItem,productNum,replenishTime,buyMax,status)
        
        local index   = #storeNums+1
        local num =  string.find(sendItem,"_")
        local IDstr = string.sub(sendItem,1,num-1)
        local itemid    = tonumber(IDstr) 
        local itemInfo = ItemInfo.getAwardElementInfoById(itemid)
		local copyBtn = btn:clone()
        local thingPer      = math.floor(buyVal*100/tottalVal) 
		local percent 		= copyBtn:getChildByName("percent")
		local loadingStr 	= copyBtn:getChildByName("loadingStr")
        local Loading       = copyBtn:getChildByName("Loading")
        local loadDB        = copyBtn:getChildByName("loadDB")
        local store         = copyBtn:getChildByName("store")
        local doneBtn       = copyBtn:getChildByName("done")
        local recordBtn       = copyBtn:getChildByName("record")
        local doneStr1       = LuaSqlite.getLanguageByKey("activity27")
        local doneStr2       = LuaSqlite.getLanguageByKey("activity75")
        local doneStr3       = LuaSqlite.getLanguageByKey("activity76")
        local valueTh       = copyBtn:getChildByName("valueTh")
        local valueThStr    = string.gsub(LuaSqlite.getLanguageByKey("activity25"),"<1>",tottalVal) 
        local storeStr      = string.gsub(LuaSqlite.getLanguageByKey("activity24"),"<1>",productNum) 
        local item          = nil
        local mark          = copyBtn:getChildByName("mark")
        storeNums[index] = productNum

        if playerList.myNum then
            local num = buyMax - playerList.myNum
            if num <= 0 then
                doneBtn:getTitleRenderer():setString(doneStr3)
                CSResourceMgr.setButtonEnabledByNode(doneBtn,false)
            else
                doneBtn:getTitleRenderer():setString(doneStr2)
            end
        else
            doneBtn:getTitleRenderer():setString(doneStr1)
        end

        loadingStr:setTextColor({r=166,b=255,g=243,a=255})
        loadingStr:enableOutline({r=0,b=0,g=0,a=255}, 2) 
        loadingStr:setString(buyVal.."/"..tottalVal)
        Loading:setPercent(thingPer)

        if status ~= 0 and status then
            mark:show()
            mark:zorder(10)
            if status == 1 then
                CSResourceMgr.setSpriteTextureByNode(mark, markPathVec[1])
            elseif status == 2 then
                CSResourceMgr.setSpriteTextureByNode(mark, markPathVec[2])
            end
        end

        if productNum <= 3 then
            store:setTextColor({r=255,g=0,b=0,a=255})
            if productNum <= 0 then
                CSResourceMgr.setButtonEnabledByNode(doneBtn,false)

                Loading:hide()
                percent:hide()
                if replenishTime then
                    local timeStr = CocosModuleMgr.getTimeStr(replenishTime, 7).."."..CocosModuleMgr.getTimeStr(replenishTime, 4).."."..CocosModuleMgr.getTimeStr(replenishTime, 5).." "..CocosModuleMgr.getTimeStr(replenishTime)
                    local str = LuaSqlite.getLanguageByKey("activity61")
                    loadingStr:setString(str..timeStr)
                    loadingStr:setColor({r=255,g=255,b=0,a=255})
                    loadingStr:setScale(0.8)
                end
            end
        end

        if itemInfo.elementType == Proto.AET_PET then 
            item          = ItemInfo.getPetIconById2(itemInfo.elementID, nil, nil, true)
            CSResourceMgr.seekNodeByName(item,"attr"):hide()
            CSResourceMgr.seekNodeByName(item,"attrBack"):hide()
            CSResourceMgr.seekNodeByName(item,"rare"):hide()
            CSResourceMgr.seekNodeByName(item,"rareBack"):hide()
        elseif itemInfo.elementType == Proto.AET_ITEM then
            item          = ItemInfo.getItemIconById(itemInfo.elementID, nil, nil, true) 
        else 
            print("没有奖励") 
            return 
        end
        local itemname      = CSResourceMgr.seekNodeByName(item,"name")
        valueTh:setString(valueThStr)
        store:setString(storeStr) 
        store:zorder(CocosModuleMgr.ZORDER_WINDOW)

        doneBtn:getTitleRenderer():enableOutline({r=0,b=0,g=0,a=255}, 2)

        recordBtn:getTitleRenderer():enableOutline({r=0,b=0,g=0,a=255}, 2)
        local str = LuaSqlite.getLanguageByKey("activity57")
        recordBtn:getTitleRenderer():setString(str) 

        item:addTo(copyBtn)
        item:setPosition(80,91.5) 
        itemname:setPosition(70,-10)
        local snatchNodes = {loadingStr = loadingStr,Loading = Loading,percent = percent,store = store,doneBtn = doneBtn}
        CSResourceMgr.clickEventBindingByNode(item, function ()

            if itemInfo.elementType == Proto.AET_ITEM then
                ItemInfoViewMgr.show({id = itemInfo.elementID,type =  1}, false)
            elseif itemInfo.elementType == Proto.AET_PET then
                PetInfoViewMgr.show(SceneMgr.getRunningScene, itemInfo.elementID)
            end
            
        end) 
        CSResourceMgr.clickEventBindingByNode(recordBtn, function()
            -- if storeNums[index] <= 0 then 
            --     BattleFuncMgr.setNodeGray(doneBtn,false)
            --     return
            -- end
            NetInterface.sendWithBlock("GC_GETONEMCASHSHOPDETAIL_ACK",function()
                NewShopSend.sendCG_GetOneMCashShopDetail_Req({itemID = itemid})
            end, function()
                ActivitySnatch.snatchDetails(itemid,snatchNodes,index,productNum,buyMax,tottalVal)  
            end)
        end,3)
        CSResourceMgr.clickEventBindingByNode(doneBtn, function()
            NetInterface.sendWithBlock("GC_GETONEMCASHSHOPDETAIL_ACK",function()
                NewShopSend.sendCG_GetOneMCashShopDetail_Req({itemID = itemid})
            end, function()
                ActivitySnatch.createBuyOneThing(ActivitySnatch.layer,0,0,itemid,snatchNodes,index,buyMax,tottalVal,playerList.myNum)
            end)
        end,3)
		

		percent:setTextColor({r=251,b=11,g=192,a=255})
		percent:enableOutline({r=0,b=0,g=0,a=255}, 2) 
        percent:setString(thingPer.."%") 
		return copyBtn
	end 

    local bg = CSResourceMgr.getNodeByName(res, "bg")
    CSResourceMgr.clickEventBindingByNode(bg, function ()
        ActivitySnatch.hide()
    end)

    local recordLB = CSResourceMgr.getNodeByName(res, "recordLB")
    CSResourceMgr.setLabelStringByNode(recordLB, "activity74", {r=0,g=0,b=0,a=255})
    local recordBtn = CSResourceMgr.getNodeByName(res, "recordBtn")
    CSResourceMgr.clickEventBindingByNode(recordBtn, function ()
        ActivitySnatch.show()
    end)

	CSResourceMgr.setRelativePosition(res,320,480)

    snatchItems = ActivitySnatch.sortTable(snatchItems)
	-- for key,var in pairs(snatchItems) do
 --           local btns = createBtn(var.buy,var.needBuy,var._id,var.productNum,var.replenishTime,var.buyMax,var.status)
 --           list:pushBackCustomItem(btns)
 --    end
    local function setSnatchItems(index)
        if snatchItems[index] then
            local var = snatchItems[index]
            local opentime = 0
            if var.onlineTime then
                opentime = tonumber(var.onlineTime) or 0
            end
            if CharInfo.getServerTime()>=opentime then
                local num = string.find(var._id,"_")
                local IDstr = string.sub(var._id,1,num-1)
                local itemid = tonumber(IDstr) 
                NetInterface.send("GC_GETONEMCASHSHOPDETAIL_ACK",function()
                    NewShopSend.sendCG_GetOneMCashShopDetail_Req({itemID = itemid})
                end, function()
                    local btns = createBtn(var.buy,var.needBuy,var._id,var.productNum,var.replenishTime,var.buyMax,var.status)
                    list:pushBackCustomItem(btns)
                    setSnatchItems(index+1)
                end)
            else
                setSnatchItems(index+1)
            end
        end
    end
    setSnatchItems(1)
	--CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(res,"bg"), "down") 
end

function ActivitySnatch.refresh(itemInfo)
    refreshInfo = itemInfo
end

function ActivitySnatch.sortTable(vec)
    local vec1 = {}
    local vec2 = {}
    local temp = {}
    for k,v in pairs(vec) do
        if v.productNum ~= 0 then
            table.insert(vec1,v)
        else
            table.insert(vec2,v)
        end
    end

    if #vec1 > 0 then
        for k,v in pairs(vec1) do
            table.insert(temp,v)
        end
    end
    if #vec2 > 0 then
        for k,v in pairs(vec2) do
            table.insert(temp,v)
        end
    end
   
    return temp
end

function ActivitySnatch.hide()
    itemsNums       = 0
    curIndex = 0
    snatchItems     = {}
    playerList      = {}
    winnerList      = {}
    storeNums       = {}
    local ret,errMessage = pcall(function()
        BattlePVPMgr.endCalcTime()
        ActivitySnatch.layer:removeFromParent() 
    end)

    if ret==false then
        BattlePVPMgr.endCalcTime()     
    end
    --HalloweenCapsuleEggView.hideTopInfoBar(true)
    DailogLayer = nil
    UnblockLoader.cancel("CommonList-LoadItem"..resName.."applyList")
    CSResourceMgr.removeCSObjectByTag(snatchPlayersRes)
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("ActivitySnatch")
    
    ActivityHalloweenViewMgr.show(SceneMgr.getRunningScene)
end

function ActivitySnatch.createBuyOneThing(parent,posX,posY,itemid,nodes,index,buyMax,tottalVal,myNum)
    local res   = "Item/snatch/buyThing.csb"
    local layer = CSResourceMgr.createRes(parent,res)
    -- local downBtn = CSResourceMgr.getNodeByName(res, "downBtn")
    local upBtn   = CSResourceMgr.getNodeByName(res, "upBtn")
    local  sure   = CSResourceMgr.getNodeByName(res, "true")
    local close   = CSResourceMgr.getNodeByName(res, "close")
    local tittle  = CSResourceMgr.getNodeByName(res, "tittle")
    local upText  = CSResourceMgr.getNodeByName(res, "upText")
    local tips    = CSResourceMgr.getNodeByName(res, "tips")
    local buyTips    = CSResourceMgr.getNodeByName(res, "buyTips")
    local maxBtn = CSResourceMgr.getNodeByName(res, "maxBtn")

    CSResourceMgr.setButtonStringByNode(maxBtn, "MAX", {r=0,g=0,b=0,a=255})

    local totalBuy = math.floor(buyMax*100/tottalVal)
    tips:setString(CocosModuleMgr.createStringWithFormat({"activity58",totalBuy}))

    if myNum then
        local num = buyMax - myNum
        if num < 0 then
            num = 0
        end
        buyTips:setString(CocosModuleMgr.createStringWithFormat({"activity62",num}))
    else
        buyTips:setString(CocosModuleMgr.createStringWithFormat({"activity62",buyMax}))
    end
    -- local downText= CSResourceMgr.getNodeByName(res, "downText")
    local upBox   = nil
    upText:setString(LuaSqlite.getLanguageByKey("lifeSkill063"))
    -- downText:setString(LuaSqlite.getLanguageByKey("lifeSkill063"))
    upBtn:getTitleRenderer():setString(1)
    -- downBtn:getTitleRenderer():setString(1)
    upBox = CocosModuleMgr.newTextEditor(upBtn, "empty.png", 
        186, 46, 93, 23, TownChatMgr.LABEL_FONT_SIZE+8, TownChatMgr.MAX_WORD_SIZE, "", 2,function()

            local value = tonumber(upBox:getText())
            upBox:setText("")
            if value then
                if value > CharInfo.getMCash() then 
                    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,1,"advtips4",function()   
                    end)
                    return
                end

                if value and value >= 1 then
                    upBtn:getTitleRenderer():setString(value)
                    -- downBtn:getTitleRenderer():setString(value)
                end
            end

        end)
    layer:zorder(100)
    layer:setPosition(posX,posY)

    CSResourceMgr.clickEventBindingByNode(maxBtn, function()
        local num = buyMax
        if myNum then
            num = buyMax - myNum
        end
        upBtn:getTitleRenderer():setString(num)
    end)

    -- downBtn:getTitleRenderer():setString() 
    sure:getTitleRenderer():enableOutline({r = 0,g = 0,b = 0, a = 255}, 1)
    CSResourceMgr.clickEventBindingByNode(sure, function() 
            local buyNum = tonumber(upBtn:getTitleRenderer():getString())
            buyMoney = buyNum + (myNum or 0)
            
            if buyNum > CharInfo.getMCash() then 
                DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,1,"advtips4",function()   
                end)
                return
            end

            if buyMoney > buyMax then
                DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,1,"activity59",function()   
                end)
                return
            else
                NetInterface.sendWithBlock("GC_BUYONEMCASHSHOP_ACK", function()
                    NewShopSend.sendCG_BuyOneMCashShop_Req({itemID = itemid,buyNum = buyNum})
                end,function() 
                    local thingPer = math.floor(100*refreshInfo.buy/refreshInfo.needBuy)
                    local buy      = refreshInfo.buy
                    local needBuy  = refreshInfo.needBuy
                    if thingPer >= 100 or refreshInfo.productNum <= 0 then
                        thingPer = 0
                        buy      = 0
                        refreshInfo.productNum = refreshInfo.productNum-1
                    end
                    
                    storeNums[index] = refreshInfo.productNum
                    local productNumstr = string.gsub(LuaSqlite.getLanguageByKey("activity24"),"<1>",refreshInfo.productNum)
                    nodes.store:setString(productNumstr)
                    nodes.Loading:setPercent(thingPer) 
                    nodes.loadingStr:setString(buy.."/"..needBuy)
                    nodes.percent:setString(thingPer.."%")
                    buyMoney = buyNum + (myNum or 0)
                    if buyMoney >= buyMax then
                        if thingPer == 0 then
                            CSResourceMgr.setButtonStringByNode(nodes.doneBtn, "activity27", {r=0,g=0,b=0,a=255})
                            if refreshInfo.productNum <= 0 then
                                CSResourceMgr.setButtonEnabledByNode(nodes.doneBtn,false)
                            end
                            if refreshInfo.productNum <= 3 then
                                nodes.store:setTextColor({r=255,g=0,b=0,a=255})
                            end
                        else
                            CSResourceMgr.setButtonStringByNode(nodes.doneBtn, "activity76", {r=0,g=0,b=0,a=255})
                            CSResourceMgr.setButtonEnabledByNode(nodes.doneBtn,false)
                        end
                    else
                        CSResourceMgr.setButtonStringByNode(nodes.doneBtn, "activity75", {r=0,g=0,b=0,a=255})
                    end
                    layer:removeFromParent()
                    CSResourceMgr.removeCSObjectByTag(snatchPlayersRes)
                end,function(code)
                    TipsMgr.showError(scene, code)
                end) 
            end
    end,3)

    CSResourceMgr.clickEventBindingByNode(close, function() 
        layer:removeFromParent()
    end,3)
    tittle:enableOutline({r = 38,g = 54,b = 76, a = 255}, 3)
    tittle:setTextColor({r = 144,g = 238,b = 255, a = 255})
    CocosModuleMgr.showUIAnimation(layer, "down")
end

function ActivitySnatch.snatchDetails(itemid,nodes,index,productNum,buyMax,tottalVal)
    local funcTable = {}
    local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene,snatchPlayersRes)
    local list  = CSResourceMgr.getNodeByName(snatchPlayersRes, "applyList")
    local close = CSResourceMgr.getNodeByName(snatchPlayersRes, "close")
    local bg    = CSResourceMgr.getNodeByName(snatchPlayersRes, "bg")
    local frame = CSResourceMgr.getNodeByName(snatchPlayersRes, "frame")
    local applyList    = CSResourceMgr.getNodeByName(snatchPlayersRes, "applyList")
    local tenPeopleStr = LuaSqlite.getLanguageByKey("activity28")
    local pepoleStr     = string.gsub(LuaSqlite.getLanguageByKey("activity26"),"<1>",playerList.charNum) 

    close:hide()
    CSResourceMgr.setRelativePosition(snatchPlayersRes,320,480)
    layer:pos(layer:getPositionX()+320, layer:getPositionY()+480)
    CSResourceMgr.playAction(snatchPlayersRes, 0, 5, false)  
    layer:zorder(CocosModuleMgr.ZORDER_WINDOW)

    local tenPeopleLabel     = display.newTTFLabel({
                font = "cuyuan_GBK.ttf",
                text = tenPeopleStr,
                size = 24, 
                align = cc.TEXT_ALIGN_CENTER, 
                color = cc.c3b(166, 243, 255)
            })
    tenPeopleLabel:enableOutline({r = 0,g = 0,b = 0, a = 255}, 3)
    tenPeopleLabel:addTo(frame)
    tenPeopleLabel:setPosition(45,605)
    tenPeopleLabel:setAnchorPoint(0,0.5)
    tenPeopleLabel:zorder(CocosModuleMgr.ZORDER_WINDOW)

    local tottalPerson = display.newTTFLabel({
                font = "cuyuan_GBK.ttf",
                text = pepoleStr,
                size = 24, 
                align = cc.TEXT_ALIGN_CENTER,  
                color = cc.c3b(166, 243, 255)
            })

    tottalPerson:enableOutline({r = 0,g = 0,b = 0, a = 255}, 3)
    tottalPerson:addTo(frame)
    tottalPerson:setPosition(480,604)
    tottalPerson:setAnchorPoint(1,0.5)
    tottalPerson:zorder(CocosModuleMgr.ZORDER_WINDOW)
    -- CSResourceMgr.setLabelMaxWidthByNode(tottalPerson, 400) 

    if tottalPerson:getContentSize().width>200 then
        local rate = 200/tottalPerson:getContentSize().width
        tottalPerson:setScale(rate,rate)    
    end

    CSResourceMgr.clickEventBindingByNode(bg, function()
            layer:removeFromParent() 
        end)

    local function setApplyPlayer(playerInfo)
        local inCashStr    = string.gsub(LuaSqlite.getLanguageByKey("activity29"),"<1>",playerInfo.cash) 
        local player = CSResourceMgr.getNodeByName(snatchPlayersRes, "applyPlayer"):clone()
        player:setVisible(true)
        local playerName = CSResourceMgr.seekNodeByName(player, "playerName")
        CSResourceMgr.setLabelColorByNode(playerName, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(playerName,playerInfo.name, {r=5,g=48,b=84,a=255})
        playerName:enableOutline({r=5,g=48,b=84,a=255}, 1)
        local back = CSResourceMgr.seekNodeByName(player, "back")
        back:setColor({r=148,g=169,b=175})
        local back2 = CSResourceMgr.seekNodeByName(player, "back2")
        back2:setColor({r=88,g=105,b=110})
        local level = CSResourceMgr.seekNodeByName(player, "level")
        CSResourceMgr.setLabelColorByNode(level, {r=255,g=252,b=0,a=255})
        CSResourceMgr.setLabelStringByNode(level,"ID:"..playerInfo.id, {r=5,g=48,b=84,a=255})
        local falseBtn = CSResourceMgr.seekNodeByName(player,"falseBtn")
        falseBtn:hide()
        -- CSResourceMgr.setButtonStringByNode(falseBtn, "friendList5", {r=62,g=77,b=27,a=255})
        -- CSResourceMgr.setButtonStringColorByNode(falseBtn, {r=255,g=255,b=255,a=255})
        -- falseBtn:getTitleRenderer():enableOutline({r=62,g=77,b=27,a=255}, 1)
        local trueBtn = CSResourceMgr.seekNodeByName(player,"trueBtn")
        trueBtn:hide() 
        -- CSResourceMgr.setButtonStringByNode(trueBtn, "friendList6", {r=77,g=35,b=27,a=255})
        -- CSResourceMgr.setButtonStringColorByNode(trueBtn, {r=255,g=255,b=255,a=255})
        -- trueBtn:getTitleRenderer():enableOutline({r=77,g=35,b=27,a=255}, 1)
        
        local back2     = CSResourceMgr.seekNodeByName(player,"back2")
        back2:setContentSize(180,30)
        back2:setAnchorPoint(0,0.5)
        back2:setPosition(83.43,46.73)

        local inCashLabel     = display.newTTFLabel({
                font = "cuyuan_GBK.ttf",
                text = inCashStr,
                size = 24, 
                align = cc.TEXT_ALIGN_CENTER, 
                color = cc.c3b(88, 105, 110) 
            })
        -- inCashLabel:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1)
        inCashLabel:addTo(player)
        inCashLabel:setPosition(270,25)
        inCashLabel:setAnchorPoint(0,0.5)
        inCashLabel:zorder(CocosModuleMgr.ZORDER_WINDOW)


        if playerInfo.fashion then
            local headIcon = CSResourceMgr.seekNodeByName(player, "headIcon")
            headIcon:loadTexture(CharInfo.getHeadIcon(playerInfo.fashion.curFashion))
            -- headIcon:setScale(1.2)
        end

        
        list:pushBackCustomItem(player)
        player:setScaleY(0)
        transition.scaleTo(player, {scale=1, time=0.2})
    end

    local rejectBtn = CSResourceMgr.getNodeByName(snatchPlayersRes,"rejectBtn")
    rejectBtn:getTitleRenderer():enableOutline({r=77,g=35,b=27,a=255}, 1)
    rejectBtn:getTitleRenderer():setString(LuaSqlite.getLanguageByKey("lifeSkill063"))

    if productNum <= 0 then
        CSResourceMgr.setButtonEnabledByNode(rejectBtn,false)
    end
    CSResourceMgr.clickEventBindingByNode(rejectBtn, function() 
            ActivitySnatch.createBuyOneThing(layer,-320,-480,itemid,nodes,index,buyMax,tottalVal,playerList.myNum)
            
        end)
    if playerList.charList then
        for key,var in pairs(playerList.charList) do              
            local playInfo = {}
            playInfo.name       = var.name
            playInfo.id         = var.charID
            playInfo.cash       = var.num
            playInfo.fashion    = var.fashion
            table.insert(funcTable,function()
                setApplyPlayer(playInfo)
            end)        
        end 
    end
    UnblockLoader.load(funcTable,"oneBuyPlayerList") 

end

return ActivitySnatch