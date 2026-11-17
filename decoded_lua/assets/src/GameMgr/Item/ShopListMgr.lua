local ShopListMgr = {}

--list类型为：默认加载一部分元素，滑动到底部时自动加载后续元素

ShopListMgr.DEFAULT_SHOWITEM_SIZE = 10

--商品list标准元素
ShopListMgr.DEFAULT_ITEM_BUTTON_STR = {"example"}                           --商品按钮
ShopListMgr.DEFAULT_ITEM_ICON_STR = {"example", "icon", "spr"}              --商品icon
ShopListMgr.DEFAULT_ITEM_ICONBUTTON_STR = {"example", "icon"}               --商品icon按钮
ShopListMgr.DEFAULT_ITEM_NAME_STR = {"example", "name_db", "name"}          --商品名称
ShopListMgr.DEFAULT_ITEM_PRICE_STR = {"example", "price_ic"}                --商品价格icon
ShopListMgr.DEFAULT_ITEM_PRICE_STR = {"example", "price_ic", "price"}       --商品价格

--商店面板元素
ShopListMgr.DEFAULT_LIST_CLOSE_STR = {"db", "diban", "close"}               --关闭商店
ShopListMgr.DEFAULT_LIST_LIST_STR = {"db", "diban", "list"}                 --商店list
ShopListMgr.DEFAULT_LIST_GOLD_STR = {"db", "diban", "gold", "gsum"}         --持有金币
ShopListMgr.DEFAULT_LIST_CRYSTAL_STR = {"db", "diban", "crystal", "csum"}   --持有点券

local curScene = nil
local curShopList = ""
local curListInfo = {}
local curMaxItemNum = 0
local isLoadingMore = false

function ShopListMgr.Init()
    curScene = nil
    curShopList = ""
    curListInfo = {}
    curMaxItemNum = 0
    isLoadingMore = false
end

---显示商店
--@param scene node 商店面板父节点
--@param resName string 商店的csb资源名称
--@param listInfo table 商品信息
function ShopListMgr.show(scene, resName, listInfo)
    ShopListMgr.hide()
    
    listInfo = {}
    for var=1, 50 do
    	listInfo[var] = {id=var, name="测试商品"..var, price=999+var, res="Item/ItemIcon/qiegao_1-hd.png", sum=99}
    end
    
    --获取玩家G币和C币数量
    local gold = CharInfo.getGCash()
    local crystal = CharInfo.getMCash()
    
    curScene = scene
    curShopList = resName
    curListInfo = listInfo
    curMaxItemNum = 0
    isLoadingMore = false
    
    local function loadCSB()
        CSResourceMgr.createRes(scene, resName):setLocalZOrder(25)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        
        CSResourceMgr.clickEventBinding(resName, ShopListMgr.DEFAULT_LIST_CLOSE_STR, function()
        	ShopListMgr.hide()
        end)
        
        CSResourceMgr.setLabelString(resName, ShopListMgr.DEFAULT_LIST_GOLD_STR, gold, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        CSResourceMgr.setLabelString(resName, ShopListMgr.DEFAULT_LIST_CRYSTAL_STR, crystal, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
    end

    local function playCSB()
        CSResourceMgr.playAllFrame(resName, false)
    end
    
    local function init()
        ShopListMgr.loadMore()
        CSResourceMgr.getNodeByName(curShopList, ShopListMgr.DEFAULT_LIST_LIST_STR):addScrollViewEventListener(function(sender, eventType)
            if eventType==1 then
                ShopListMgr.loadMore()
            end
        end)
    end

    local funcTable = {loadCSB, playCSB, init}

    UnblockLoader.load(funcTable, "ShopListMgr")
end

---关闭商店
function ShopListMgr.hide()
    if curShopList~="" then
        UnblockLoader.cancel("ShopListMgr")
        UnblockLoader.cancel("ShopListMgr-LoadMore")
        CSResourceMgr.getNodeByName(curShopList, ShopListMgr.DEFAULT_LIST_LIST_STR):removeAllItems()
        CSResourceMgr.removeCSObjectByTag(curShopList)
        curShopList = ""
    end
end

---加载更多商品（不需要外部调用）
function ShopListMgr.loadMore()
    if #curListInfo<1 then
        print("商品列表为空")
	    return false
    end
    if isLoadingMore then
        print("商品列表正在加载中")
        return false
    end
    
    isLoadingMore = true
    local fromN = curMaxItemNum + 1
    local toN = curMaxItemNum + ShopListMgr.DEFAULT_SHOWITEM_SIZE
    if curMaxItemNum+ShopListMgr.DEFAULT_SHOWITEM_SIZE>#curListInfo then
        toN = #curListInfo
    end
    
    local funcTable = {}
    for i=fromN, toN do
        local function loadItem()
            local var = curListInfo[i]
            
            CSResourceMgr.setLabelString(curShopList, ShopListMgr.DEFAULT_ITEM_NAME_STR, var.name, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            CSResourceMgr.setLabelString(curShopList, ShopListMgr.DEFAULT_ITEM_PRICE_STR, var.price, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            CSResourceMgr.clickEventBinding(curShopList, ShopListMgr.DEFAULT_ITEM_BUTTON_STR, function()
                local buyStr = CocosModuleMgr.createRichLabelString(
                {{color="FFFFFF", text="这东西很贵的，"}, {image="UI/Chat/Emoji/em04.png", text="口"}, 
                {color="FFFFFF", text="你tm买得起吗！"}, {color="FFFFFF", text="确认购买<"}, 
                {color="FF0000", text="<1>"}, {color="FFFFFF", text=">吗？"}})
                DialogBoxMgr.showSmallDialogBox(curScene, 2, CocosModuleMgr.createStringWithFormat({buyStr, var.name}), function()
                	TipsMgr.show(curScene, "假装购买惹~")
                    BasicMenuMgr.addRedPoint(2)
                end)
            end)
            CSResourceMgr.clickEventBinding(curShopList, ShopListMgr.DEFAULT_ITEM_ICONBUTTON_STR, function()
                ItemInfoViewMgr.show({id = var.id, res = var.res, sum = var.sum, des = ""})
            end)
            CSResourceMgr.setButtonTexture(curShopList, ShopListMgr.DEFAULT_ITEM_ICON_STR, var.res, var.res, var.res)
            local itemBtn = CSResourceMgr.getNodeByName(curShopList, ShopListMgr.DEFAULT_ITEM_BUTTON_STR):clone()
            itemBtn:setVisible(true)
            CSResourceMgr.getNodeByName(curShopList, ShopListMgr.DEFAULT_LIST_LIST_STR):pushBackCustomItem(itemBtn)
            itemBtn:setScaleY(0)
            transition.scaleTo(itemBtn, {scaleY = 1, time = 0.1})
            curMaxItemNum = i
        end
        table.insert(funcTable, loadItem)
    end

    local function finish()
        if curMaxItemNum<#curListInfo then
            isLoadingMore = false
        end
    end
    table.insert(funcTable, finish)

    UnblockLoader.load(funcTable, "ShopListMgr-LoadMore")
end

return ShopListMgr