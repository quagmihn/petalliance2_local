local ConfraListViewMgr = {}

ConfraListViewMgr.DEFAULT_SHOWITEM_SIZE = 5
ConfraListViewMgr.DEFAULT_PAGEITEM_SIZE = 20

local curResName = ""
local curScene = nil
local isLoadingMore = false
local canLoadMore = false
local curMaxItemNum = 0
local currentPageIndex = 0
local previousPageIndex = 0
local confraternityInfo = nil

function ConfraListViewMgr.Init()
    print("ConfraListViewMgr初始化")

    curResName = ""
    curScene = nil
    isLoadingMore = false
    canLoadMore = false
    curMaxItemNum = 0
    currentPageIndex = 0
    previousPageIndex = 0
    confraternityInfo = {}
end

function ConfraListViewMgr.show(scene)

    isLoadingMore = false
    canLoadMore = false
    curMaxItemNum = 0
    currentPageIndex = 0
    previousPageIndex = 0
    curResName = "Confraternity/ConfraternityMainView.csb"
    curScene = scene

    for var=1, 500 do
        local playerArgs = {}
        for i=1, 15-math.floor(var/100) do
            playerArgs[i] = {name="sb"..var..i, level=99, icon="Pet/PicIcon/001.png", res="Gaf/pet/002-lukaliou.gaf"}
        end
        confraternityInfo[var] = {name="测试公会"..var, level=99-math.floor(var/5), player=playerArgs, desc="测试描述"..var.."韩寒会画画后悔画韩红韩寒会画画后悔画韩红韩寒会画画后悔画韩红"}
    end

    local pageTotolNum = math.ceil(500/ConfraListViewMgr.DEFAULT_PAGEITEM_SIZE)

    local function loadCSB()
        CSResourceMgr.createRes(scene, curResName):setLocalZOrder(25)
        CSResourceMgr.setRelativePosition(curResName, 320, 480)

        local function setPageLabel(page)
            CSResourceMgr.setLabelString(curResName, {"db", "diban", "page"}, CocosModuleMgr.createStringWithFormat({"<1>/<2>", page, pageTotolNum}), "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        end
        setPageLabel(1)
        local pageView = CSResourceMgr.getNodeByName(curResName, {"db", "diban", "pageview"})
        CSResourceMgr.clickEventBinding(curResName, {"db", "diban", "close"}, function()
            ConfraListViewMgr.hide()
        end)
        CSResourceMgr.clickEventBinding(curResName, {"db", "diban", "left"}, function()
            local index = pageView:getCurPageIndex()
            pageView:scrollToPage(index-1)
            setPageLabel(index)
            if index-1==0 then
                CSResourceMgr.setButtonEnabled(curResName, {"db", "diban", "left"}, false)
            end
            CSResourceMgr.setButtonEnabled(curResName, {"db", "diban", "right"}, true)
        end)
        CSResourceMgr.clickEventBinding(curResName, {"db", "diban", "right"}, function()
            local index = pageView:getCurPageIndex()
            pageView:scrollToPage(index+1)
            setPageLabel(index+2)
            if index+1==pageTotolNum-1 then
                CSResourceMgr.setButtonEnabled(curResName, {"db", "diban", "right"}, false)
            end
            CSResourceMgr.setButtonEnabled(curResName, {"db", "diban", "left"}, true)
        end)
        CSResourceMgr.setLabelString(curResName, {"db", "diban", "title_diban", "title"}, "公会列表", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        CSResourceMgr.getNodeByName(curResName, {"db", "diban", "pageview", "panel", "listview"}):addScrollViewEventListener(function(sender, eventType)
            if eventType==1 then
                ConfraListViewMgr.loadMoreItemsRequest()
            end
        end)
        for var=1, pageTotolNum do
            local panel = CSResourceMgr.getNodeByName(curResName, {"db", "diban", "pageview", "panel"}):clone()
            pageView:addPage(panel)
        end
        CSResourceMgr.getNodeByName(curResName, {"db", "diban", "pageview"}):addEventListener(function(sender, eventType)
            local index = pageView:getCurPageIndex()
            if index~=currentPageIndex then                
                UnblockLoader.cancel("ConfraListViewMgr-loadMoreItems"..currentPageIndex)
                ConfraListViewMgr.clearListItemsByPage(currentPageIndex)
                previousPageIndex = currentPageIndex
                currentPageIndex = index
                curMaxItemNum = currentPageIndex*ConfraListViewMgr.DEFAULT_PAGEITEM_SIZE
                isLoadingMore = false
                ConfraListViewMgr.loadMoreItemsRequest()
            end
        end)
        CSResourceMgr.setButtonEnabled(curResName, {"db", "diban", "left"}, false)
    end

    local function playCSB()
        CSResourceMgr.playAllFrame(curResName, false)
    end

    local function loadItem()
        ConfraListViewMgr.loadMoreItemsRequest()
    end

    local funcTable = {loadCSB, playCSB, loadItem}

    UnblockLoader.load(funcTable, "ConfraListViewMgr")
end

function ConfraListViewMgr.hide()
    UnblockLoader.cancel("ConfraListViewMgr")
    UnblockLoader.cancel("ConfraListViewMgr-loadMoreItems"..currentPageIndex)
    ConfraListViewMgr.clearListItemsByPage(currentPageIndex)
    CSResourceMgr.getNodeByName(curResName, {"db", "diban", "pageview"}):removeAllPages()
    CSResourceMgr.removeCSObjectByTag(curResName)
end

function ConfraListViewMgr.clearListItemsByPage(pageIndex)
    local listView = CSResourceMgr.getNodeByName(curResName, {"db", "diban", "pageview"}):getPage(pageIndex):getChildByName("listview")
    listView:removeAllItems()
end

function ConfraListViewMgr.loadMoreItemsRequest()
    if isLoadingMore then
        return false
    end
    local pageIndex = currentPageIndex
    if (pageIndex+1)*ConfraListViewMgr.DEFAULT_PAGEITEM_SIZE==curMaxItemNum then
        return false
    end

    isLoadingMore = true
    local listView = CSResourceMgr.getNodeByName(curResName, {"db", "diban", "pageview"}):getPage(pageIndex):getChildByName("listview")

    CSResourceMgr.setLabelString(curResName, "tip", "正在请求列表...", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
    local label = CSResourceMgr.getNodeByName(curResName, "tip"):clone()
    label:setVisible(true)
    local hud = label:getChildByName("hud")
    local ani = cc.RepeatForever:create(cc.RotateBy:create(1.5, 180))
    local posy = label:getContentSize().height/2
    hud:setPositionY(posy)
    hud:runAction(ani)
    listView:pushBackCustomItem(label)
    label:performWithDelay(function()
        listView:jumpToBottom()
    end, 0.2)

    --发服务器请求，我先假装1秒后收到回复
    CSResourceMgr.getCsbObj(curResName):performWithDelay(function()
        canLoadMore = true
        ConfraListViewMgr.loadMoreItems()
    end, 0.5)
end

function ConfraListViewMgr.loadMoreItems()
    local pageIndex = currentPageIndex
    local listView = CSResourceMgr.getNodeByName(curResName, {"db", "diban", "pageview"}):getPage(pageIndex):getChildByName("listview")

    local funcTable = {}
    local formN = curMaxItemNum+1
    local toN = curMaxItemNum+ConfraListViewMgr.DEFAULT_SHOWITEM_SIZE
    if toN>#confraternityInfo then
        toN = #confraternityInfo
    end
    listView:removeItem(curMaxItemNum-pageIndex*ConfraListViewMgr.DEFAULT_PAGEITEM_SIZE)
    for i=formN, toN do
        local function loadItem()
            local var = confraternityInfo[i]
            CSResourceMgr.setLabelString(curResName, {"example", "flag", "rank"}, i, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            CSResourceMgr.setLabelString(curResName, {"example", "info", "name"}, var.name, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            CSResourceMgr.setLabelString(curResName, {"example", "info", "sinfo"}, CocosModuleMgr.createStringWithFormat({"家族等级：<1>   家族人数：<2>", var.level, #var.player}), "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)

            CSResourceMgr.clickEventBinding(curResName, {"example", "example_bg"}, function(sender)
                ConfraInfoViewMgr.show(curScene, var)
            end)
            CSResourceMgr.clickEventBinding(curResName, {"example", "detail"}, function(sender)
                DialogBoxMgr.showSmallDialogBox(curScene, 2, CocosModuleMgr.createStringWithFormat({"确认申请加入<<1>>吗？", var.name}),function()
                	TipsMgr.show(curScene, "假装申请惹~")
                end)
            end)
            local citem = CSResourceMgr.getNodeByName(curResName, {"example"}):clone()
            citem:setVisible(true)
            listView:pushBackCustomItem(citem)
            citem:setScaleY(0)
            transition.scaleTo(citem, {scaleY = 1, time = 0.1})
            curMaxItemNum = i
        end
        table.insert(funcTable, loadItem)
    end

    local function finish()
        isLoadingMore = false
    end
    table.insert(funcTable, finish)

    UnblockLoader.load(funcTable, "ConfraListViewMgr-loadMoreItems"..currentPageIndex)
end

return ConfraListViewMgr