local ItemInfo = {}

ItemInfo.COLOR = {}
ItemInfo.COLOR_16 = {}
ItemInfo.AWARD = {}

local ItemInfoConfig = nil
local AwardElementInfoConfig = nil
local ConsumeElementInfoConfig = nil
local FashionItemInfoConfig = nil
local FashionSuitEffectInfoConfig = nil
local DrawingInfoConfig = nil
local ShopReFlashInfoConfig = nil
local MarketInfoConfig = nil --商会、商城
local MonthCardRechargeInfoConfig = nil
local NormalRechargeInfoConfig = nil 
local PetPieceInfoConfig = nil 
local WishingTreeInfoConfig = nil
local PokemonBallInfoConfig = nil


local CharItemInfo = {}
local ItemTypeInfo = nil
local ItemTitleInfo = nil
local ItemGetWayInfo = nil
local FurnitureInfo = {}
local SkillBookInfo = {}
local GachaMayGetInfo = nil

local newItemInfo = {}
local itemInfoData ={}
local resName = "Item/itemicontemplate.csb"
local resNameP = "Item/itemicontemplatemask.csb"
function ItemInfo.Init()
    ItemInfo.COLOR = 
        {
            {r=255,g=255,b=255,a=255},
            {r=120,g=255,b=0,a=255},
            {r=48,g=116,b=255,a=255},
            {r=126,g=0,b=255,a=255},
            {r=255,g=252,b=0,a=255},
            {r=255,g=129,b=0,a=255},
            {r=255,g=0,b=0,a=255},
        }

    ItemInfo.COLOR_16 = 
        {
            "FFFFFF",
            "78FF00",
            "3074FF",
            "7E00FF",
            "FFFC00",
            "FF8100",
            "FF0000",
        }
    ItemInfo.AWARD = 
        {
            [Proto.AET_NONE]            = 0,
            [Proto.AET_GCASH]           = 9998,
            [Proto.AET_MCASH]           = 9999,
            [Proto.AET_ITEM]            = "item",
            [Proto.AET_EXP]             = 9997,
            [Proto.AET_PET]             = "pet",
            [Proto.AET_STRENGTHEN]      = 0,
            [Proto.AET_STARPOINT]       = 0,
            [Proto.AET_WASHSTONE]       = 0,
            [Proto.AET_LOSTTOWERPOINT]  = 0,
            [Proto.AET_ARENAPOINT]      = 9995,
            [Proto.AET_GOLDCOIN]        = 9996,
            [Proto.AET_FAMILYCOIN]      = 0,
            [Proto.AET_ACTIONPOINT]     = 0,
            [Proto.AET_TERRITORYPOINT]  = 9991,
            [Proto.AET_ACTIVITYPOINT]   = 9990,
            [Proto.AET_FAMILYCOIN]      = ScienceInfo.ITEM_ID,
        }
    
    --PerFormanceAnalyzer.Start("ItemInfo.Init()","read Config/Packet.txt")   
    if ItemTypeInfo==nil then
    	ItemTypeInfo = {}
        local ItemTypeInfoReader = TxtReader.new("Config/Packet.txt")
        local ItemTypeData = ItemTypeInfoReader.init({"tid", "info", "title"}, 1)
        ItemTitleInfo = {"bag1"}
        for key, var in pairs(ItemTypeData) do
            local tid = tonumber(var.tid)
            local info = var.info
            local infoVec = lua_string_split(info, ",")
            for k, v in pairs(infoVec) do
                local typeIdx = tonumber(v)
                if typeIdx then
                    ItemTypeInfo[typeIdx] = tid
                end
            end
            table.insert(ItemTitleInfo,var.title)
        end
    end
   -- PerFormanceAnalyzer.End("read Config/Packet.txt")  
    
    --PerFormanceAnalyzer.Start("ItemInfo.Init()","read Config/GetWay.txt")   
    if ItemGetWayInfo==nil then
    	ItemGetWayInfo = {}
        local ItemGetWayInfoReader = TxtReader.new("Config/GetWay.txt")
        local ItemGetWayData = ItemGetWayInfoReader.init({"id", "way1", "param1", "way2", "param2", "way3", "param3",
            "way4", "param4", "way5", "param5", "way6", "param6"}, 1)
        for key, var in pairs(ItemGetWayData) do
            local id = tonumber(var.id)
            ItemGetWayInfo[id] = {}
            for i=1, 6 do
                if var["way"..i] then
                    if tonumber(var["way"..i])~=0 and tonumber(var["way"..i])~=nil then
                        table.insert(ItemGetWayInfo[id], {type=tonumber(var["way"..i]), param=tonumber(var["param"..i])})
                    end
                end
            end
        end
    end
    
     --PerFormanceAnalyzer.End("read Config/GetWay.txt")  

   -- PerFormanceAnalyzer.Start("ItemInfo.Init()","read Config/GachaMayGet.txt")
    if GachaMayGetInfo==nil then
    	GachaMayGetInfo = {}
        local GachaMayGetInfoReader = TxtReader.new("Config/GachaMayGet.txt")
        local GachaMayGetData = GachaMayGetInfoReader.init({"id", "awards"}, 1)
        for key, var in pairs(GachaMayGetData) do
            local id = tonumber(var.id)
            local awardsVec = lua_string_split(var.awards, ",")
            GachaMayGetInfo[id] = {}
            for i=1, 8 do
                table.insert(GachaMayGetInfo[id],awardsVec[i])
            end
        end
    end
    --PerFormanceAnalyzer.End("read Config/GachaMayGet.txt")
    
    --PerFormanceAnalyzer.Start("ItemInfo.Init()","read Config/ItemInfoConfig")
    if ItemInfoConfig==nil then
        ItemInfoConfig = require("src.DatReader.ItemInfoConfig")
        ItemInfoConfig.init()
        
        --[[这段速度奇慢，没有必要
        for var=1, ItemInfoConfig.getEntryCount() do
            local id = ItemInfoConfig.getEntryID(var)
            local data = ItemInfoConfig.readEntryByID(id)
            itemInfoData[id] = data
        end
        ]]
    end
    --PerFormanceAnalyzer.End("read Config/ItemInfoConfig")

    --PerFormanceAnalyzer.Start("ItemInfo.Init()","read Config/AwardElementInfoConfig")
    if AwardElementInfoConfig==nil then
        AwardElementInfoConfig = require("src.DatReader.AwardElementInfoConfig")
        AwardElementInfoConfig.init()
    end
    --PerFormanceAnalyzer.End("read Config/AwardElementInfoConfig")
    
    --PerFormanceAnalyzer.Start("ItemInfo.Init()","read Config/ConsumeElementInfoConfig")
    if ConsumeElementInfoConfig==nil then
        ConsumeElementInfoConfig = require("src.DatReader.ConsumeElementInfoConfig")
        ConsumeElementInfoConfig.init()
    end
    --PerFormanceAnalyzer.End("read Config/ConsumeElementInfoConfig")
    
    
   -- PerFormanceAnalyzer.Start("ItemInfo.Init()","read Config/FashionItemInfoConfig")   
    if FashionItemInfoConfig==nil then
        FashionItemInfoConfig = require("src.DatReader.FashionItemInfoConfig")
        FashionItemInfoConfig.init()
    end
   -- PerFormanceAnalyzer.End("read Config/FashionItemInfoConfig")
    
    if FashionSuitEffectInfoConfig==nil then
        FashionSuitEffectInfoConfig = require("src.DatReader.FashionSuitEffectInfoConfig")
        FashionSuitEffectInfoConfig.init()
    end

    --PerFormanceAnalyzer.Start("ItemInfo.Init()","read Config/DrawingInfoConfig")         
    if DrawingInfoConfig==nil then
        DrawingInfoConfig = require("src.DatReader.DrawingInfoConfig")
        DrawingInfoConfig.init()
    end
   -- PerFormanceAnalyzer.End("read Config/DrawingInfoConfig")
        
   -- PerFormanceAnalyzer.Start("ItemInfo.Init()","read Config/ShopReflashInfoConfig")  
    if ShopReFlashInfoConfig==nil then
        ShopReFlashInfoConfig = require("src.DatReader.ShopReflashInfoConfig")
        ShopReFlashInfoConfig.init()
    end
    --PerFormanceAnalyzer.End("read Config/ShopReflashInfoConfig")    
 
   -- PerFormanceAnalyzer.Start("ItemInfo.Init()","read Config/MarketInfoConfig")     
    if MarketInfoConfig==nil then
        MarketInfoConfig = require("src.DatReader.MarketInfoConfig")
        MarketInfoConfig.init()
    end
    --PerFormanceAnalyzer.End("read Config/MarketInfoConfig")  
    
   -- PerFormanceAnalyzer.Start("ItemInfo.Init()","read Config/MonthCardRechargeInfoConfig")      
    if MonthCardRechargeInfoConfig==nil then
        MonthCardRechargeInfoConfig = require("src.DatReader.MonthCardRechargeInfoConfig")
        MonthCardRechargeInfoConfig.init()
    end
   -- PerFormanceAnalyzer.End("read Config/MonthCardRechargeInfoConfig")  
    
    
   -- PerFormanceAnalyzer.Start("ItemInfo.Init()","read Config/NormalRechargeInfoConfig")    
    if NormalRechargeInfoConfig==nil then
        NormalRechargeInfoConfig = require("src.DatReader.NormalRechargeInfoConfig")
        NormalRechargeInfoConfig.init()
    end
    --PerFormanceAnalyzer.End("read Config/NormalRechargeInfoConfig")  
  
   -- PerFormanceAnalyzer.Start("ItemInfo.Init()","read Config/PetPieceInfoConfig")    
    if PetPieceInfoConfig==nil then
        PetPieceInfoConfig = require("src.DatReader.PetPieceInfoConfig")
        PetPieceInfoConfig.init()
    end
    --PerFormanceAnalyzer.End("read Config/PetPieceInfoConfig") 

    if WishingTreeInfoConfig==nil then
        WishingTreeInfoConfig = require("src.DatReader.WishingTreeInfoConfig")
        WishingTreeInfoConfig.init()
    end

    if PokemonBallInfoConfig==nil then
        PokemonBallInfoConfig = require("src.DatReader.PokemonBallInfoConfig")
        PokemonBallInfoConfig.init()
    end
        
    CharItemInfo = {}
    newItemInfo = {}
    FurnitureInfo = {}
    SkillBookInfo = {}

    CSResourceMgr.createRes(SceneMgr.getRunningScene,resName,"itemicontemplate",true)
    CSResourceMgr.createRes(SceneMgr.getRunningScene,resNameP,"itemicontemplate",true)
end

---获取玩家道具信息
function ItemInfo.getCharItemInfo()
    return CharItemInfo
end

---获取玩家道具数量
--@param id int 道具id
function ItemInfo.getCharItemNum(id)
    if CharItemInfo[id] then
        return CharItemInfo[id]
    end
	return 0
end

function ItemInfo.useItemCallback(itemid, sum)
    local itemtype = ItemInfo.getItemInfoById(itemid).itemType
    if itemtype==22 then
    	AvatarViewMgr.refreshUI()
    end
end

function ItemInfo.updateCharItemInfobyItemId(ItemIdVec)
    for var = 1,#ItemIdVec do 
        local iID = tonumber(ItemIdVec[var].itemID) 
        local iNum = tonumber(ItemIdVec[var].num) 
        CharItemInfo[iID] = iNum
        print("人物道具刷新id="..iID ..",num="..iNum)
        BagViewMgr.update(iID, iNum)
    end

    PetFeedViewMgr.refreshExpItem()
    BasicMenuMgr.setPetEductionRedPoint()
end

function ItemInfo.updateCharItemInfo(ItemInfoVec, boolNew)
    local cjson = require("cjson")
    local showTipsFunc = {}
    local isBall = false
    for var=1, #ItemInfoVec do
        local tbl = cjson.decode(ItemInfoVec[var])
        if tbl.itemID and tbl.num then
            local iID = tonumber(tbl.itemID)
            local iNum = tonumber(tbl.num)
            local tmpNum = CharItemInfo[iID]
            CharItemInfo[iID] = iNum
            print("人物道具刷新id="..tbl.itemID..",num="..tbl.num)
            
            if boolNew then
                local newFunc = function(addnum)
                    local flag = true
                    for var=1, #newItemInfo do
                        if newItemInfo[var]==iID then
                            flag = false
                            break
                        end
                    end
                    if flag then
                        table.insert(newItemInfo, iID)
                    end
                    --BasicMenuMgr.addRedPoint(2)
                    --[[
                    table.insert(showTipsFunc, function()
                        TipsMgr.show(nil, CocosModuleMgr.createStringWithFormat({"tips18", ItemInfo.getItemInfoById(iID).name,
                            ItemInfo.COLOR_16[ItemInfo.getItemInfoById(iID).itemRare+1], addnum}))
                    end)]]
                end
                
                if tmpNum then
                    if tmpNum<iNum then
                        newFunc(iNum-tmpNum)
                    end
                else
                    newFunc(iNum)
                end
                
                if isBall==false then
                    if iWatchConnectivity.checkIsBall(iID) then
                        isBall = true
                    end
                end
            end
            
            BagViewMgr.update(tbl.itemID, tbl.num)
        end
    end
    if #showTipsFunc>0 then
        --UnblockLoader.load(showTipsFunc)
    end
    if isBall then
    	iWatchConnectivity.saveItemData()
    end
    PetFeedViewMgr.refreshExpItem()
    BasicMenuMgr.setPetEductionRedPoint()
end

function ItemInfo.getNewItem()
    return newItemInfo
end

--获取物品分页类型
function ItemInfo.getItemType(id)
    if not ItemInfo.getItemInfoById(id) then
    	return nil
    end
    local itype = tonumber(ItemInfo.getItemInfoById(id).itemType)
    return ItemTypeInfo[itype]
end

--获取物品分页标题
function ItemInfo.getAllTitle()
    return ItemTitleInfo
end

---获取物品获得方式Item/GetWay/1-5.png
--var[i].type 
--1副本 WorldMapMgr.searchAdventureNode(var[i].param)
--2活动副本 
--3放生 
--4挂机 PetExploreMgr.request(scene, var[i].param)
--5商店
--6千层塔，参数0
--7领地争夺，参数（副本编号）
--8扭蛋，参数0
--9生活技能，参数（对应页签）
--var[i].param 对应参数
function ItemInfo.getItemGetWay(id)
	local var = ItemGetWayInfo[id] or {}
	print("当前物品获取方式size", #var)
	return var
end

function ItemInfo.getGachaMayGetInfo()
    return GachaMayGetInfo
end

---获取物品品级底框资源
--@param id number 物品id
--@param rareId number 物品品级，若填此项则直接返回对应资源，不再根据物品id获取品级
function ItemInfo.getItemRareBGImage(id, rareId)
    if rareId then
        return "Item/ItemRare/"..rareId..".png"
    end
    if not tonumber(id) then
        return "Item/ItemRare/0.png"
    end
    local rare = ItemInfo.getItemInfoById(id).itemRare
    return "Item/ItemRare/"..rare..".png"
end

--[[
data.id=Proto.parseDWORD(entry); -- 道具类型ID
data.itemType=Proto.parseDWORD(entry); -- 道具种类
data.itemTypeID=Proto.parseDWORD(entry); -- 类型ID
data.name=Proto.parseString(entry); -- 名称
data.desc=Proto.parseString(entry); -- 描述
data.icon=Proto.parseString(entry); -- 图标
data.reclaimPrice=Proto.parseDWORD(entry); -- 道具回收价格
data.itemRare=Proto.parseDWORD(entry); -- 稀有度
data.bindType=Proto.parseBYTE(entry); -- 绑定类型
data.bUse=Proto.parseBYTE(entry); -- 能否使用
data.effectName=Proto.parseString(entry); -- 道具参数效果名
data.paramA=Proto.parseDWORD(entry); -- 道具效果参数A
data.paramB=Proto.parseDWORD(entry); -- 道具效果参数B
data.paramC=Proto.parseDWORD(entry); -- 道具效果参数C
data.paramD=Proto.parseDWORD(entry); -- 道具效果参数D
data.paramE=Proto.parseDWORD(entry); -- 道具效果参数E
--id=9996 银币; id=9997 经验; id=9998 金币; id=9999 钻石
--]]
function ItemInfo.getItemInfoById(id)
    id = tonumber(id)
    --return itemInfoData[id]
    
    --local t1 = os.clock()
    local iteminfo = itemInfoData[id] 
    --local t2 = os.clock()
    if iteminfo == nil then
        iteminfo = ItemInfoConfig.readEntryByID(id) --测试下来并不慢
        itemInfoData[id] = iteminfo
    end
    --print("getItemInfoById id:"..id.." take time:"..t2-t1)
    return iteminfo
end

--[[
function ItemInfo.getAllItemInfo() --这个函数问题太大,会非常慢,所以我注释掉了
    local vec = {}
    for var=1, ItemInfoConfig.getEntryCount() do
        local id = ItemInfoConfig.getEntryID(var)
        table.insert(vec, ItemInfo.getItemInfoById(id))
    end
    return vec
end
]]

--[[
data.id=Proto.parseDWORD(entry); -- 
data.elementType=Proto.parseDWORD(entry); -- 
data.elementID=Proto.parseDWORD(entry); -- 
--]]
function ItemInfo.getAwardElementInfoById(id)
    return AwardElementInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- 
data.c=Proto.parseVector(entry,Proto.parseDWORD); -- 
data.b=Proto.parseVector(entry,Proto.parseDWORD); -- 
data.a=Proto.parseVector(entry,Proto.parseDWORD); -- 
data.s=Proto.parseVector(entry,Proto.parseDWORD); -- 
--]]

function ItemInfo.getPokemonBallInfoById(id)
    return PokemonBallInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- 
data.elementType=Proto.parseDWORD(entry); -- 
data.elementID=Proto.parseDWORD(entry); -- 
data.num=Proto.parseDWORD(entry); -- 
]]--
function ItemInfo.getConsumeElementInfoById(id)
    return ConsumeElementInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- 道具类型
data.sex=Proto.parseBYTE(entry); -- 时装性别
data.name=Proto.parseString(entry); -- 时装名称
data.filePath=Proto.parseString(entry); -- 时装文件路径
]]
function ItemInfo.getFashionItemInfoById(id)
    return FashionItemInfoConfig.readEntryByID(id)
end

function ItemInfo.getFashionItemInfoAllId()
    local vec = {}
    for var=1, FashionItemInfoConfig.getEntryCount() do
        local id = FashionItemInfoConfig.getEntryID(var)
        table.insert(vec, ItemInfo.getFashionItemInfoById(id))
    end
    return vec
end

--[[
data.id=Proto.parseDWORD(entry); -- ID、主表能读到的信息
data.name=Proto.parseString(entry); -- 套装名称
data.summary=Proto.parseString(entry); -- 概述、放在时装上面的空位
data.des=Proto.parseString(entry); -- 详细描述
data.oneEffect=Proto.parseDWORD(entry); -- 一件套效果
data.twoEffect=Proto.parseDWORD(entry); -- 二件套
data.threeEffect=Proto.parseDWORD(entry); -- 三件套
data.effectValues=Proto.parseVector(entry,Proto.parseDWORD); -- 参数、就是传进套装详细描述里的参数，会有三个，几件套就传第几个
]]
function ItemInfo.getFashionSuitEffectInfoById(id)
    return FashionSuitEffectInfoConfig.readEntryByID(id)
end

function ItemInfo.getFashionSuitEffectInfoAllId()
    local vec = {}
    for var=1, FashionSuitEffectInfoConfig.getEntryCount() do
        local id = FashionSuitEffectInfoConfig.getEntryID(var)
        table.insert(vec, ItemInfo.getFashionSuitEffectInfoById(id))
    end
    return vec
end
--[[    
data.id=Proto.parseint(entry); -- ID
data.money=Proto.parseint(entry); -- 充值金额
data.days=Proto.parseint(entry); -- 有效天数
data.mCashPerDay=Proto.parseint(entry); -- 每天元玉数
data.initMCash=Proto.parseint(entry); -- 初始元玉销
data.orderName = Proto.parseString(entry) -- 订单号
]]
function ItemInfo.getMonthCardRechargeInfoById(id)
    return MonthCardRechargeInfoConfig.readEntryByID(id)
end

function ItemInfo.getMonthCardRechargeInfoAllId()
    local vec = {}
    for var=1, MonthCardRechargeInfoConfig.getEntryCount() do
        local id = MonthCardRechargeInfoConfig.getEntryID(var)
        table.insert(vec, ItemInfo.getMonthCardRechargeInfoById(id))
    end
    return vec
end

--[[
data.id=Proto.parseint(entry); -- ID
data.money=Proto.parseint(entry); -- 充值金额
data.mCash=Proto.parseint(entry); -- 元玉
data.giftMCash=Proto.parseint(entry); -- 赠送元玉
data.bonusRate=Proto.parseint(entry); -- 翻倍倍数
data.bonusCD=Proto.parseint(entry); -- 翻倍CD(分)
]]
function ItemInfo.getNormalRechargeInfoById(id)
    return NormalRechargeInfoConfig.readEntryByID(id)
end

function ItemInfo.getNormalRechargeInfoAllId()
    local vec = {}
    for var=1, NormalRechargeInfoConfig.getEntryCount() do
        local id = NormalRechargeInfoConfig.getEntryID(var)
        table.insert(vec, ItemInfo.getNormalRechargeInfoById(id))
    end
    return vec
end

--[[
data.id=Proto.parseDWORD(entry); -- 图纸ID
data.name=Proto.parseString(entry); -- 名称
data.itemID=Proto.parseDWORD(entry); -- 物品表图纸ID
data.currencyType=Proto.parseBYTE(entry); -- 货币类型
data.price=Proto.parseDWORD(entry); -- 售价
data.description=Proto.parseString(entry); -- 说明
data.drawingType=Proto.parseString(entry); -- 分类
data.career=Proto.parseBYTE(entry); -- 需求职业
data.level=Proto.parseBYTE(entry); -- 需求等级
data.exp=Proto.parseDWORD(entry); -- 获得经验
data.costs=Proto.parseVector(entry,Proto.parseDWORD); -- 消耗材料
data.awards=Proto.parseVector(entry,Proto.parseDWORD); -- 获取奖励
]]
function ItemInfo.getDrawingInfoById(id)
    return DrawingInfoConfig.readEntryByID(id)
end

function ItemInfo.getDrawingInfoAllId()
    local vec = {}
    for var=1, DrawingInfoConfig.getEntryCount() do
        local id = DrawingInfoConfig.getEntryID(var)
        table.insert(vec, ItemInfo.getDrawingInfoById(id))
    end
    return vec    
end

function ItemInfo.updateCharFurnitureInfo(FurnitureInfoVec, boolNew)
    local cjson = require("cjson")
    local showTipsFunc = {}
    for var=1, #FurnitureInfoVec do
        local tbl = cjson.decode(FurnitureInfoVec[var])
        if tbl.itemID then
            local iID = tonumber(tbl.itemID)
            local iNum = 0
            if tbl.isDelete then
                iNum = -1
                CharItemInfo[iID][tonumber(tbl.objID)] = nil
                FurnitureInfo[iID][tonumber(tbl.objID)] = nil
            else
                iNum = 1
                if not CharItemInfo[iID] then
                    CharItemInfo[iID] = {}
                end
                CharItemInfo[iID][tonumber(tbl.objID)] = {}
                CharItemInfo[iID][tonumber(tbl.objID)].num = iNum
                CharItemInfo[iID][tonumber(tbl.objID)].isBind = tbl.isBind
                if not FurnitureInfo[iID] then
                    FurnitureInfo[iID] = {}
                end
                FurnitureInfo[iID][tonumber(tbl.objID)] = {}
                FurnitureInfo[iID][tonumber(tbl.objID)].num = iNum
                FurnitureInfo[iID][tonumber(tbl.objID)].isBind = tbl.isBind
                print("人物家具刷新id="..tbl.itemID)
                
                if boolNew then
                    local newFunc = function(addnum)
                        local flag = true
                        for var=1, #newItemInfo do
                            if newItemInfo[var]==iID then
                                flag = false
                                break
                            end
                        end
                        if flag then
                            table.insert(newItemInfo, iID)
                        end
                        BasicMenuMgr.addRedPoint(2)
                        table.insert(showTipsFunc, function()
                            TipsMgr.show(nil, CocosModuleMgr.createStringWithFormat({"tips18", ItemInfo.getItemInfoById(iID).name,
                                ItemInfo.COLOR_16[ItemInfo.getItemInfoById(iID).itemRare+1], addnum}))
                        end)
                    end              
                    newFunc(iNum)
                end
            end
            BagViewMgr.update(tbl.itemID, iNum)
            if SceneMgr.currentScene == "HomeScene" then
                FurnitureViewMgr.update(tbl.itemID, iNum)
            end
        end
    end
    if #showTipsFunc>0 then
        --UnblockLoader.load(showTipsFunc)
    end
end

---获取玩家家具信息
function ItemInfo.getFurnitureInfo()
    return FurnitureInfo
end

function ItemInfo.getFurnitureNumByID(id)
    local num = 0
    if FurnitureInfo[id] then
        for k,v in pairs(FurnitureInfo[id]) do
            if v then
                num = num + 1
            end
        end
    end
    return num
end

function ItemInfo.isSofaExist()
    for k,v in pairs(FurnitureInfo) do
        if FurnitureViewMgr.GetFurnitureType(k) == Proto.FT_SOFA then
            for key,val in pairs(FurnitureInfo[k]) do
                if val then
                    return true
                end
            end
        end
    end
    return false
end

--[[
data.id=Proto.parseDWORD(entry); -- 类型id
data.reflashDetail=Proto.parseVector(entry,Proto.parseReflashDetail); -- 刷新详细信息列表
    Proto.writeDWORD(msg,data.count); -- 刷新次数
    Proto.writeDWORD(msg,data.consume); -- 消耗
    
--]]
function ItemInfo.getShopReFlashInfoById(id)
    return ShopReFlashInfoConfig.readEntryByID(id)
end

--[[

data.id=Proto.parseDWORD(entry); -- 
data.itemID=Proto.parseDWORD(entry); -- 
data.marketType=Proto.parseDWORD(entry); -- 
data.subType=Proto.parseDWORD(entry); -- 
data.subTypeName=Proto.parseString(entry); -- 
data.coinType=Proto.parseDWORD(entry); -- 
data.num=Proto.parseDWORD(entry); -- 
data.buyMax=Proto.parseDWORD(entry); -- 
--]]
function ItemInfo.getMarketInfoById(id)
    return MarketInfoConfig.readEntryByID(id)
end


function ItemInfo.getAllMarketInfo()
    local vec = {}
    for var=1, MarketInfoConfig.getEntryCount() do
        local id = MarketInfoConfig.getEntryID(var)
        table.insert(vec, ItemInfo.getMarketInfoById(id))
    end
    return vec      
end

function ItemInfo.updateCharSkillBookInfoById(SkillBookIdVec)
    for var = 1,#SkillBookIdVec do 
        local iID = tonumber(SkillBookIdVec[var].itemID) 
        local iNum = tonumber(SkillBookIdVec[var].num) 
        SkillBookInfo[iID] = iNum
        print("人物技能道具刷新1id="..iID..",num="..iNum)
        AuctionMgrNew.updateAuctionItem(iID,true)
 
    end
end
function ItemInfo.updateCharSkillBookInfo(SkillBooksInfoVec, boolNew)
    local cjson = require("cjson")
    for var=1, #SkillBooksInfoVec do
        local tbl = cjson.decode(SkillBooksInfoVec[var])
        if tbl.itemID and tbl.num then
            local iID = tonumber(tbl.itemID)
            local iNum = tonumber(tbl.num)
            local tmpNum = SkillBookInfo[iID]
            SkillBookInfo[iID] = iNum
            print("人物技能道具刷新2id="..tbl.itemID..",num="..tbl.num)
            AuctionMgrNew.updateAuctionItem(iID,true)
       
        end
    end
end

---获取玩家技能背包
function ItemInfo.getSkillBookInfo()
    return SkillBookInfo
end

-- data.id=Proto.parseDWORD(entry); -- ID
-- data.name=Proto.parseString(entry); -- 名称
-- data.grade=Proto.parseString(entry); -- 品阶
-- data.icon=Proto.parseDWORD(entry); -- icon
-- data.num=Proto.parseDWORD(entry); -- 合成数量
-- data.pokeID=Proto.parseDWORD(entry); -- 目标ID
-- data.describe=Proto.parseString(entry); -- 描述
function ItemInfo.getPetPieceInfoById(id)
    return PetPieceInfoConfig.readEntryByID(id)
end

--------------------------------
-- 获取宠物奖励icon
-- @param id int 宠物pokeid
-- @param tag string 标签用于区分
function ItemInfo.getPetIconById(id, tag)
    tag = tag or ""
    local petNode = PetListMgr.createPetNodeWithInfo({objID="ItemInfo.getPetIconById"..tag, pokeID=id}, tag).button
    petNode:removeFromParent()
    return petNode
end

--------------------------------
-- 获取道具icon
-- @param id int 道具ID
-- @param num int 道具数量，不显示传nil
-- @param color 道具数量颜色，不改变颜色不填
-- @param showname bool 是否显示名字
-- @param shownumlimit bool 是否让数字添加上限999+
-- @return Button 返回道具icon的button
function ItemInfo.getItemIconById(id, num, color, showname, shownumlimit)
    local csb = nil
    local itemtype = ItemInfo.getItemType(id)
    id = tonumber(id)
    
    local orderString = {
        [1] = "Pet/Education/c.png",
        [2] = "Pet/Education/b.png",
        [3] = "Pet/Education/a.png",
        [4] = "Pet/Education/s.png",
        [5] = "Pet/Education/2s.png",
        [6] = "Pet/Education/3s.png",
    }
    local parent = nil
    local iconpath = nil
    if itemtype ~= 4 then
        csb =  CSResourceMgr.createRes(SceneMgr.getRunningScene,resName,"itemicontemplate")
        local iteminfo = ItemInfo.getItemInfoById(id)
        iconpath = iteminfo.icon
    	parent = CSResourceMgr.seekNodeByName(csb,"b"):clone()
        local itemname = CSResourceMgr.seekNodeByName(parent,"name")
        if showname then
            CSResourceMgr.setLabelColorByNode(itemname, ItemInfo.COLOR[iteminfo.itemRare+1])
            CSResourceMgr.setLabelStringByNode(itemname, iteminfo.name, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 150)
        end
        if iteminfo.itemType == 1 and iteminfo.paramB and iteminfo.paramB~=0 then
            local star = display.newSprite("UI/CommonFiles/skillbook_star.png")
            star:addTo(parent)
            star:scale(1.5)
            star:pos(30, 28)
        end
    else
        csb =  CSResourceMgr.createRes(SceneMgr.getRunningScene,resNameP,"itemicontemplate")    
     	parent = CSResourceMgr.seekNodeByName(csb,"b2"):clone()   
		local petPieceInfo = ItemInfo.getPetPieceInfoById(id)
		local pokemonInfo = PokemonInfo.getPokemonInfoByID(PokemonInfo.getGeneInfoByID(petPieceInfo.pokeID).petID)
		local name = CSResourceMgr.seekNodeByName(parent,"name")
        CSResourceMgr.setLabelStringByNode(name, petPieceInfo.name, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 150)
		--CSResourceMgr.setLabelStringByNode(name, petPieceInfo.name, CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS,nil,144)
		CSResourceMgr.setLabelColorByNode(name, PokemonInfo.COLOR[pokemonInfo.rarePoint])
        if showname then 
		    name:setVisible(true)
        else
            name:setVisible(false)
        end
        iconpath = PokemonInfo.getPokemonIconByID(PokemonInfo.getGeneInfoByID(petPieceInfo.pokeID).petID)
		CSResourceMgr.seekNodeByName(parent, "mask"):setScale(0.9,0.9)
		local icon1 = "Pet/AttriIcon/"..pokemonInfo.elementAtt1..".png"
		local icon2 = "Pet/AttriIcon/small_"..pokemonInfo.elementAtt1..".png"
		CSResourceMgr.seekNodeByName(parent,"attr"):loadTexture(icon1)
		CSResourceMgr.seekNodeByName(parent,"attrBack"):loadTexture(icon2)
		CSResourceMgr.seekNodeByName(parent,"rare"):loadTexture(orderString[pokemonInfo.rarePoint])		
    end
	
	local sprite = CSResourceMgr.seekNodeByName(parent, "s")
	CSResourceMgr.setSpriteTextureByNode(sprite, iconpath)
	local btnRes = ItemInfo.getItemRareBGImage(id)
    CSResourceMgr.setButtonTextureByNode(parent, btnRes, btnRes, btnRes)
   
    if itemtype == 4 then
        sprite:setScale(1.2)
    else
        sprite:setScale(1.4)        
    end
    
    if num~=nil then
        local label = CSResourceMgr.seekNodeByName(parent, "l")
        local numstr = tostring(num)
        if shownumlimit == true then 
            if num >=999 then numstr = "999+" end
        end
        CSResourceMgr.setLabelStringByNode(label, numstr, CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS, nil, 120)
        if color~= nil then 
            CSResourceMgr.setLabelColorByNode(label,color)
        end
    end
    return parent
end

function ItemInfo.getWishingTreeInfoById(id)
    return WishingTreeInfoConfig.readEntryByID(id)
end

---request item num from server
function ItemInfo.reqItemNum(itemsidVec)
    NetInterface.sendWithBlock("GC_QuerySomeItems_Ack",function()
        local params = {}
        params.itemIDs =  itemsidVec
        local ItemSend = require("src.Net.Send.ItemSend")
        ItemSend.sendCG_QuerySomeItems_Req(params)
    end,function()
        ItemInfoViewMgr.refreshItemNum(itemsidVec[1])
    end
    )
end

---用奖池id组获取物品列表
--@param awardElementVec table 奖池组
--@param needNum bool 是否需要获取数量，默认获取
function ItemInfo.getAwardElementsItem(awardElementVec, needNum)
    if needNum==nil then
    	needNum = true
    end
    local itemVec = {}
    for key, var in pairs(awardElementVec) do
        local eInfo = AdventureInfo.getRewardInfoByID(var)
        if eInfo==nil then
            print("ItemInfo.getAwardElementsItem error", key, var)
        else
            local eVec = eInfo.element
            local nVec = eInfo.nReward
            for n=1, #eVec do
                local rNum = nil
                if needNum then
                    rNum = nVec[n]
                end
                local rInfo = ItemInfo.getAwardElementInfoById(eVec[n])
                local rType = rInfo.elementType
                local rID = rInfo.elementID
                if rType==3 then
                    table.insert(itemVec, {rID, rNum})
                elseif rType==5 then
                    for idx=1, rNum do
                        table.insert(itemVec, {"pet", rID})
                    end
                else
                    table.insert(itemVec, {ItemInfo.AWARD[rType], rNum})
                end
            end
        end
    end
    return itemVec
end

--------------------------------
-- 获取宠物icon
-- @param id int 宠物ID
-- @param num int 道具数量，不显示传nil
-- @param color 道具数量颜色，不改变颜色不填
-- @param showname bool 是否显示名字
-- @param shownumlimit bool 是否让数字添加上限999+
-- @return Button 返回道具icon的button
function ItemInfo.getPetIconById2(id, num, color, showname, shownumlimit)
    local csb = nil
    id = tonumber(id)
    
    local orderString = {
        [1] = "Pet/Education/c.png",
        [2] = "Pet/Education/b.png",
        [3] = "Pet/Education/a.png",
        [4] = "Pet/Education/s.png",
        [5] = "Pet/Education/2s.png",
        [6] = "Pet/Education/3s.png",
    }
    local parent = nil
    local iconpath = nil

    csb =  CSResourceMgr.createRes(SceneMgr.getRunningScene,resNameP,"itemicontemplate")    
    parent = CSResourceMgr.seekNodeByName(csb,"b2"):clone()   
	local pokemonInfo = PokemonInfo.getPokemonInfoByID(id)
	local name = CSResourceMgr.seekNodeByName(parent,"name")
    CSResourceMgr.setLabelStringByNode(name, pokemonInfo.name, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 150)
	--CSResourceMgr.setLabelStringByNode(name, petPieceInfo.name, CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS,nil,144)
	CSResourceMgr.setLabelColorByNode(name, PokemonInfo.COLOR[pokemonInfo.rarePoint])
    if showname then 
		name:setVisible(true)
    else
        name:setVisible(false)
    end
    iconpath = PokemonInfo.getPokemonIconByID(id)
	CSResourceMgr.seekNodeByName(parent, "mask"):setVisible(false)
	local icon1 = "Pet/AttriIcon/"..pokemonInfo.elementAtt1..".png"
	local icon2 = "Pet/AttriIcon/small_"..pokemonInfo.elementAtt1..".png"
	CSResourceMgr.seekNodeByName(parent,"attr"):loadTexture(icon1)
	CSResourceMgr.seekNodeByName(parent,"attrBack"):loadTexture(icon2)
	CSResourceMgr.seekNodeByName(parent,"rare"):loadTexture(orderString[pokemonInfo.rarePoint])		
   
	
	local sprite = CSResourceMgr.seekNodeByName(parent, "s")
	CSResourceMgr.setSpriteTextureByNode(sprite, iconpath)
	local btnRes = ItemInfo.getItemRareBGImage(id,pokemonInfo.rarePoint)
    CSResourceMgr.setButtonTextureByNode(parent, btnRes, btnRes, btnRes)
    sprite:setScale(1.2)
    if num~=nil then
        local label = CSResourceMgr.seekNodeByName(parent, "l")
        local numstr = tostring(num)
        if shownumlimit == true then 
            if num >=999 then numstr = "999+" end
        end
        CSResourceMgr.setLabelStringByNode(label, numstr, CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS, nil, 120)
        if color~= nil then 
            CSResourceMgr.setLabelColorByNode(label,color)
        end
    end
    return parent
end

return ItemInfo