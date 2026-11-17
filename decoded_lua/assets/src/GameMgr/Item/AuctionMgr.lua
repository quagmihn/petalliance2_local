local AuctionMgr = {}

AuctionMgr.DEFAULT_PAGEITEM_SIZE = 6
AuctionMgr.DEFAULT_LISTITEM_SIZE = 3
AuctionMgr.DEFAULT_INPUTSTR_SIZE = 32
AuctionMgr.DEFAULT_BROWSEPAGE_BUFFER_SIZE = 3

local resName = ""
local prePage = 0
local curPage = 0
local curScene = nil
local itemInfo = {}
local isLoaded = {}

function AuctionMgr.Init()
    resName = "Item/Auction/AuctionMainView.csb"
    prePage = 0
    curPage = 0
    curScene = nil
    itemInfo = {}
    isLoaded = {}
end

---打开拍卖行
function AuctionMgr.show(scene)
    curScene = scene
    prePage = 0
    curPage = 0
    itemInfo = {}
    isLoaded = {}

    local function loadCSB()
        CSResourceMgr.createRes(scene, resName):setLocalZOrder(25)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.clickEventBinding(resName, "close", function()
            AuctionMgr.hide()
        end)
        local pageView = CSResourceMgr.getNodeByName(resName, {"db", "diban", "pageview"})
        pageView:addEventListener(function(sender, eventType)
            local index = pageView:getCurPageIndex()
            if index~=curPage then
                prePage = curPage
                curPage = index
                AuctionMgr.checkTurnPageButton(curPage)
                AuctionMgr.loadItem(curPage)
            end
        end)
        CSResourceMgr.clickEventBinding(resName, {"db", "diban", "left"}, function()
            local index = pageView:getCurPageIndex()
            pageView:scrollToPage(index-1)
            AuctionMgr.checkTurnPageButton(index-1)
        end)
        CSResourceMgr.clickEventBinding(resName, {"db", "diban", "right"}, function()
            local index = pageView:getCurPageIndex()
            pageView:scrollToPage(index+1)
            AuctionMgr.checkTurnPageButton(index+1)
        end)
        
        local editbox = CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resName, {"db", "diban", "searchbar"}), "UI/Chat/db_shuru.png", 250, 50, 125, 271, 24, AuctionMgr.DEFAULT_INPUTSTR_SIZE, "请输入物品名")
        
        CSResourceMgr.setButtonString(resName, {"db", "diban", "searchbar", "search"}, "搜索")
        CSResourceMgr.clickEventBinding(resName, {"db", "diban", "searchbar", "search"}, function()
            AuctionMgr.search(editbox:getText())
            editbox:setText("")
        end, "", true)
        CSResourceMgr.setLabelString(resName, {"db", "diban", "titlediban", "title"}, "口袋商城", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        AuctionMgr.clear()
    end

    local function playCSB()
        CSResourceMgr.playAction(resName, 0, 5, false)
    end
    
    local funcTable = {loadCSB, playCSB}
    UnblockLoader.load(funcTable, "AuctionMgr")
end

---关闭拍卖行
function AuctionMgr.hide()
    UnblockLoader.cancel("AuctionMgr")
    UnblockLoader.cancel("AuctionMgr-loadItem"..curPage)
    AuctionMgr.clear()
	CSResourceMgr.removeCSObjectByTag(resName)
end

---清空列表中所有商品
function AuctionMgr.clear()
    local pageView = CSResourceMgr.getNodeByName(resName, {"db", "diban", "pageview"})
    pageView:scrollToPage(0)
    CSResourceMgr.setButtonEnabled(resName, {"db", "diban", "left"}, false)
    CSResourceMgr.setButtonEnabled(resName, {"db", "diban", "right"}, false)
    CSResourceMgr.setLabelString(resName,{"db", "diban", "page"}, "")
    local pageTotal = math.ceil(#itemInfo/AuctionMgr.DEFAULT_PAGEITEM_SIZE)
    local funcTable = {}
    for var=1, pageTotal do
        pageView:getPage(var-1):getChildByName("list1"):removeAllItems()
        pageView:getPage(var-1):getChildByName("list2"):removeAllItems()
    end
    pageView:removeAllPages()
end

---搜索商品
--@param itemName string 商品名
function AuctionMgr.search(itemName)
    --商品数据归零
    UnblockLoader.cancel("AuctionMgr-loadItem"..curPage)
    AuctionMgr.clear()
    itemInfo = {}
    isLoaded = {}
    --显示tips提示
    AuctionMgr.setTips("正在搜索商品...", true)
    --禁用搜索按钮
    CSResourceMgr.setButtonEnabled(resName, {"db", "diban", "searchbar", "search"}, false)
    
    --发服务器请求，我先假装1秒后收到回复
    for var=1, 100 do
    	itemInfo[var] = {name="腊八粥 - 补脑饮品", icon="Item/ItemIcon/labazhou-hd.png", price=9999+var, sum=var}
    end
    
    CSResourceMgr.getCsbObj(resName):performWithDelay(function()
        --根据新商品信息重置
        local pageTotal = math.ceil(#itemInfo/AuctionMgr.DEFAULT_PAGEITEM_SIZE)
        local pageView = CSResourceMgr.getNodeByName(resName, {"db", "diban", "pageview"})
        for var=1, pageTotal do
            local panel = CSResourceMgr.getNodeByName(resName, {"panel"}):clone()
            pageView:addPage(panel)
        end
        if pageTotal>1 then
            CSResourceMgr.setButtonEnabled(resName, {"db", "diban", "right"}, true)
        end
        AuctionMgr.checkTurnPageButton(0)
        --隐藏tips提示
        AuctionMgr.setTips("", false)
        --恢复搜索按钮
        CSResourceMgr.setButtonEnabled(resName, {"db", "diban", "searchbar", "search"}, true)
        --加载初始页
        AuctionMgr.loadItem(0)
    end, 0.5)
end

---加载当页商品
--@param page int 页数（0开始）
function AuctionMgr.loadItem(page)
    if isLoaded[page]==true then
	    return false
    end
    local fromN = page*AuctionMgr.DEFAULT_PAGEITEM_SIZE+1
    local toN = (page+1)*AuctionMgr.DEFAULT_PAGEITEM_SIZE
    if toN > #itemInfo then
    	toN = #itemInfo
    end
    local curPageView = CSResourceMgr.getNodeByName(resName, {"db", "diban", "pageview"}):getPage(page)
    if curPageView==nil then
    	return false
    end
    local list1 = curPageView:getChildByName("list1")
    local list2 = curPageView:getChildByName("list2")
    local function setItem(var)
        CSResourceMgr.setLabelString(resName, {"example", "price"}, itemInfo[var].price)
        CSResourceMgr.setLabelString(resName, {"example", "name"}, itemInfo[var].name)
        CSResourceMgr.setLabelString(resName, {"example", "sum"}, itemInfo[var].sum)
        CSResourceMgr.setButtonString(resName, {"example", "buy"}, "购买")
        CSResourceMgr.setButtonTexture(resName, {"example", "icon"}, itemInfo[var].icon, itemInfo[var].icon, itemInfo[var].icon)
        CSResourceMgr.clickEventBinding(resName, {"example", "buy"}, function()
            DialogBoxMgr.showSmallDialogBox(curScene, 2, CocosModuleMgr.createStringWithFormat({"确认支付<1>金币拍下<<2>>吗？", itemInfo[var].price, itemInfo[var].name}), function()
            	TipsMgr.show(curScene, "假装拍下惹，正在为您发货~")
            end)
        end)
        CSResourceMgr.clickEventBinding(resName, {"example", "select"}, function()
            ItemInfoViewMgr.show({id=1, sum=itemInfo[var].sum})
        end)
    end
    local funcTable = {}
    for var=fromN, fromN+2 do
        local function addItem()
            setItem(var)
            local item = CSResourceMgr.getNodeByName(resName, "example"):clone()
            item:setVisible(true)
            list1:pushBackCustomItem(item)
            item:setScaleY(0)
            transition.scaleTo(item, {scaleY = 1, time = 0.1})
        end
        table.insert(funcTable, addItem)
    end
    for var=fromN+3, toN do
        local function addItem()
            setItem(var)
            local item = CSResourceMgr.getNodeByName(resName, "example"):clone()
            item:setVisible(true)
            list2:pushBackCustomItem(item)
            item:setScaleY(0)
            transition.scaleTo(item, {scaleY = 1, time = 0.1})
        end
        table.insert(funcTable, addItem)
    end
    local function finish()
        isLoaded[page] = true
        local pageView = CSResourceMgr.getNodeByName(resName, {"db", "diban", "pageview"})
        local delPage1 = pageView:getPage(page+AuctionMgr.DEFAULT_BROWSEPAGE_BUFFER_SIZE)
        if delPage1 then
        	delPage1:getChildByName("list1"):removeAllItems()
        	delPage1:getChildByName("list2"):removeAllItems()
        	isLoaded[page+AuctionMgr.DEFAULT_BROWSEPAGE_BUFFER_SIZE] = false
        end
        local delPage2 = pageView:getPage(page-AuctionMgr.DEFAULT_BROWSEPAGE_BUFFER_SIZE)
        if delPage2 then
            delPage2:getChildByName("list1"):removeAllItems()
            delPage2:getChildByName("list2"):removeAllItems()
            isLoaded[page-AuctionMgr.DEFAULT_BROWSEPAGE_BUFFER_SIZE] = false
        end
    end
    table.insert(funcTable, finish)

    UnblockLoader.load(funcTable, "AuctionMgr-loadItem"..page)
end

---检查翻页相关UI
--@param page int 页数（0开始）
function AuctionMgr.checkTurnPageButton(page)
    local pageTotal = math.ceil(#itemInfo/AuctionMgr.DEFAULT_PAGEITEM_SIZE)
    if page==0 then
        CSResourceMgr.setButtonEnabled(resName, {"db", "diban", "left"}, false)
    else
        CSResourceMgr.setButtonEnabled(resName, {"db", "diban", "left"}, true)
    end
    if page==pageTotal-1 then
        CSResourceMgr.setButtonEnabled(resName, {"db", "diban", "right"}, false)
    else
        CSResourceMgr.setButtonEnabled(resName, {"db", "diban", "right"}, true)
    end
    CSResourceMgr.setLabelString(resName,{"db", "diban", "page"}, CocosModuleMgr.createStringWithFormat({"<1>/<2>", page+1, pageTotal}), "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
end

---设置拍卖行提示语
--@param string string 提示语
--@param showHud bool 是否显示loading圈
function AuctionMgr.setTips(string, showHud)
    CSResourceMgr.setLabelString(resName, {"db", "diban", "tips"}, string)
    local label = CSResourceMgr.getNodeByName(resName, {"db", "diban", "tips"})
    local hud = CSResourceMgr.getNodeByName(resName, {"db", "diban", "tips", "hud"})
    label:setVisible(true)
    if showHud then
        local ani = cc.RepeatForever:create(cc.RotateBy:create(1.5, 180))
        local posy = label:getContentSize().height/2
        hud:setVisible(true)
        hud:setPositionY(posy)
        hud:runAction(ani)
    else
        hud:setVisible(false)
        transition.stopTarget(hud)
    end
end

return AuctionMgr