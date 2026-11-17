local ItemInfoViewMgr = {}

local resName = ""
local resNameVec = {}
local orderString = {}
local playPetAniTag = ""
local petWiki ={}
local lastItemNum = 0
local curItemType = 0
local compoundPetInfo = nil
ItemInfoViewMgr.isInGetWay = false

function ItemInfoViewMgr.Init()
    resName = ""
    resNameVec = {"Item/InfoTips/ObjectInfo.csb", "Item/InfoTips/MaterialInfo.csb", "Item/InfoTips/EquipInfo.csb",
        "Item/InfoTips/SkillInfo.csb"}
    playPetAniTag = ""

    orderString = {
        [1] = "Pet/Education/c.png",
        [2] = "Pet/Education/b.png",
        [3] = "Pet/Education/a.png",
        [4] = "Pet/Education/s.png",
        [5] = "Pet/Education/2s.png",
        [6] = "Pet/Education/3s.png",
    }
    petWiki ={}
    lastItemNum = 0
    curItemType = 0
    compoundPetInfo = nil
end

local stackFlag = true --是否入堆栈的标志
---显示物品信息
--@param info table 物品信息，e.g. {id = id, sum = num, type = 1,objID = objID}
--id=9997 经验; id=9998 金币; id=9999 钻石
--id 物品id; sum 物品数量,可不填(装备填强化等级); type 弹出框类型,1点击2长按,不填则默认1(长按代码自行处理)
--@param operable bool 是否可操作(出售或使用),不填则默认可操作
function ItemInfoViewMgr.show(info, operable)

    local iteminfo = ItemInfo.getItemInfoById(info.id)
    curItemType = iteminfo.itemType
    if iteminfo.itemType == 1 then---技能书显示技能书接口
        local skillInfo = PokemonInfo.getPetSkillInfoById(iteminfo.paramA)
        if skillInfo.skill_A_Type==0 or skillInfo.skill_A_Type==1 or skillInfo.skill_A_Type==8 then
            PetSkillViewMgr.showConciseSkillInfo(skillInfo, 1, nil, iteminfo)
            return
        elseif skillInfo.skill_A_Type==6 or skillInfo.skill_A_Type==7 then
            PetSkillViewMgr.showConciseSkillInfo(skillInfo, 2, nil, iteminfo)
            return
        end
    end

    if iteminfo.itemType == 26 then --equip
        PetEquipmentEvaluateMgr.show(SceneMgr.getRunningScene,{info.id},true)
        return 
    end


    if info.type == 2 then stackFlag = false end
    
    if stackFlag then  
        UIStack.push("ItemInfoViewMgr",ItemInfoViewMgr.hide,false)
    end

    local scene = SceneMgr.getRunningScene
    if operable==nil then
    	operable = true
    end
    info.type = info.type or 1
    info.id = tonumber(info.id)
    if not info.id then
    	return
    end
    print("ItemInfoViewMgr.show", info.id)
    local itemType = ItemInfo.getItemType(info.id)  --1是道具2是材料3是装备4是碎片
    resName = resNameVec[1]
    --[[道具专用信息面板
    if itemType==3 then
        resName = resNameVec[3]
    end]]
    if operable==false then
        resName = resNameVec[2]
    end

    petWiki = PetHandBook.getPetWikiInfoLst()

    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)

        if info.type==1 then
            CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)
        elseif info.type==2 then
            local function hideNode(cellName)
        		local node = CSResourceMgr.getNodeByName(resName, cellName)
        		if node then
        			node:setVisible(false)
        		end
        	end
            hideNode("back")
            hideNode("close")
            hideNode("sell")
            hideNode("use")
            CSResourceMgr.getNodeByName(resName, "bg"):setOpacity(0)
        end
        
        local iteminfo = ItemInfo.getItemInfoById(info.id)
        
        CSResourceMgr.setLabelString(resName, "name", iteminfo.name, "", {r=0,g=0,b=0,a=255}, nil, 300)
        CSResourceMgr.setLabelColor(resName, "name", {r=55,g=178,b=219,a=255})
        
        CSResourceMgr.setLabelString(resName, "info", iteminfo.desc)
        CSResourceMgr.setLabelColor(resName, "info", {r=112,g=131,b=158,a=255})
        CSResourceMgr.setLabelMaxWidth(resName, "info", 440)
        
        CSResourceMgr.setSpriteTexture(resName, "icdb", ItemInfo.getItemRareBGImage(info.id))
        CSResourceMgr.setSpriteTexture(resName, "icon", iteminfo.icon)
        
        local usetip = CSResourceMgr.getNodeByName(resName, "usetip")
        local usestatus = ""
        if Proto.FT_BIND_USE==iteminfo.bindType then
            usestatus = "iteminfo1"
            --if operable and 使用了 then usestatus = "iteminfo29" end
        elseif Proto.BT_BIND_OBTAIN==iteminfo.bindType then
            if operable then
                usestatus = "iteminfo29"
            else
                --阿杜修改英文版显示
                usestatus = LuaSqlite.LANG_TYPE==1 and "iteminfo28" or ""
            end
        end
        CSResourceMgr.setLabelString(resName, "usetip", usestatus, "", nil, nil, 300)
        CSResourceMgr.setLabelColor(resName, "usetip", {r=217,g=234,b=255,a=255})
        usetip:enableOutline({r=0,g=0,b=0,a=255}, 1)
        
        if info.sum then
            local plusStr = "x"
            --装备显示LV
            -- if itemType==3 then
            --     plusStr = "Lv"
            -- end
            local sumLabel = CSResourceMgr.getNodeByName(resName, "num")
            CSResourceMgr.setLabelString(resName, "num", plusStr..info.sum, "", nil, nil, 100)
            sumLabel:enableOutline({r=0,g=0,b=0,a=255}, 1)
        end
        
        if itemType==1 then
            CSResourceMgr.setLabelColor(resName, "infotitle", {r=144,g=238,b=255,a=255})
            CSResourceMgr.setLabelString(resName, "infotitle", "iteminfo4", "", nil, nil, 120)
        elseif itemType==2 then
            CSResourceMgr.setLabelColor(resName, "infotitle", {r=144,g=238,b=255,a=255})
            CSResourceMgr.setLabelString(resName, "infotitle", "iteminfo5", "", nil, nil, 120)
        elseif itemType==3 then
            CSResourceMgr.setLabelColor(resName, "infotitle", {r=144,g=238,b=255,a=255})
            CSResourceMgr.setLabelString(resName, "infotitle", "iteminfo3", "", nil, nil, 120)
            if operable==true then
                CSResourceMgr.setLabelColor(resName, "desctitle", {r=144,g=238,b=255,a=255})
                CSResourceMgr.setLabelString(resName, "desctitle", "iteminfo2", "", nil, nil, 120)
                --显示属性
            end
        elseif itemType==4 then
            CSResourceMgr.setLabelColor(resName, "infotitle", {r=144,g=238,b=255,a=255})
            CSResourceMgr.setLabelString(resName, "infotitle", "iteminfo4", "", nil, nil, 120)
        end
        
        --获得途径
        CSResourceMgr.setLabelColor(resName, "getwaytitle", {r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelString(resName, "getwaytitle", "iteminfo6", "", nil, nil, 120)
        local getwayInfo = ItemInfo.getItemGetWay(info.id)
        local getwayStr = {"iteminfo18", "iteminfo19", "iteminfo20", "iteminfo21", "iteminfo22", "iteminfo24",
            "iteminfo25", "iteminfo26","iteminfo34","iteminfo27","iteminfo35","iteminfo49","iteminfo50"}
        local loopSize = #getwayInfo
        local list = CSResourceMgr.getNodeByName(resName, "getWayList")
        if list then
            list:removeAllItems()
        end
        for var=1, loopSize do
            local gInfo = getwayInfo[var]
            local parent = CSResourceMgr.getNodeByName(resName, "getway"):clone()
            local getwayicon =  CSResourceMgr.seekNodeByName(parent, "getwayicon")
            getwayicon:setScale(0.5)
            CSResourceMgr.setSpriteTextureByNode(getwayicon, "Item/GetWay/"..gInfo.type..".png")
            local nameLabel = CSResourceMgr.seekNodeByName(parent, "getwayname")
            CSResourceMgr.setLabelColorByNode(nameLabel, {r=217,g=234,b=255,a=255})
            CSResourceMgr.setLabelStringByNode(nameLabel, getwayStr[gInfo.type], nil, nil, 200)
            nameLabel:enableOutline({r=0,g=0,b=0,a=255}, 1)
            parent:setVisible(true)
            list:pushBackCustomItem(parent)
            local charLock = CharInfo.get().maplock

            local function disableGetWay()
                parent:setColor({r=121,g=121,b=121,a=255})
                CSResourceMgr.setButtonEnabledByNode(parent, false)
                getwayicon:setColor({r=121,g=121,b=121,a=255})
                nameLabel:setColor({r=128,g=128,b=128,a=255})
                nameLabel:enableOutline({r=0,g=0,b=0,a=255},1)                
            end

            if gInfo.type==1 or gInfo.type==4 then
                if gInfo.param~=0 then
                    local adventureInfo = AdventureInfo.getAdventureInfoByID(gInfo.param)
                    local tab = math.ceil(gInfo.param / 10000)
                    CSResourceMgr.setLabelStringByNode(nameLabel, LuaSqlite.getLanguageByKey(adventureInfo.name)..LuaSqlite.getLanguageByKey("fbhard"..tab), nil, nil, 200)
                    if not ItemInfoViewMgr.isStageOpen(gInfo.param, tab) then
                        CSResourceMgr.setLabelColorByNode(nameLabel, {r=87,g=87,b=87,a=255})
                    end
                end
            end
            if gInfo.type==9 then
                if gInfo.param~=0 then
                    CSResourceMgr.setLabelStringByNode(nameLabel,"exchange0"..tostring(21+gInfo.param), nil, nil, 200)
                end
            end
            if gInfo.type == 2 then
                textShare = CocosModuleMgr.createStringWithFormat({getwayStr[gInfo.type], gInfo.param})
                CSResourceMgr.setLabelStringByNode(nameLabel, textShare, nil, nil, 200)
            end
            if gInfo.type==5 then
                if gInfo.param==1 then
                    CSResourceMgr.setLabelStringByNode(nameLabel, "iteminfo33", nil, nil, 200)
                    if CharInfo.getLevel()<SystemInfo.getGlobalConfigAddInfoByID(24002).values[1] then
                        disableGetWay()
                    end
                elseif gInfo.param==2 then
                    CSResourceMgr.setLabelStringByNode(nameLabel, "iteminfo32", nil, nil, 200)
                    local unlockID = SystemInfo.getGlobalConfigAddInfoByID(25000).values[1]
                    if charLock<unlockID then
                        disableGetWay()
                    end
                end
            end

            if info.type==1 then
                --类型0：无，1：一般副本，2：迷失之塔，3：放生，4：探索，5：商店（1、竞技场商店、2、千层塔商店6:扭蛋，7:签到,8:每日任务,9:交易所(1、逛摊、2、商会、3商城),10:生活馆（1、时装、2家具、3、装潢）,11:家具(1、家族任务)
                CSResourceMgr.clickEventBindingByNode(parent, function()
                    if TeamInfo.getInfo(TeamInfo.KEY_TEAMID) then
                        StandardTipsMgr.show(1, "team45")
                        return
                    end
                    if gInfo.type==1 then
                        if gInfo.param~=0 then
                            local tab = math.ceil(gInfo.param / 10000)
                            if not ItemInfoViewMgr.isStageOpen(gInfo.param, tab) then
                                StandardTipsMgr.show(1, "tips22")
                                return
                            end
                        end
                    end
                    ItemInfoViewMgr.hide()
                    print("------getway:", gInfo.type, gInfo.param)
                    if gInfo.type==1 then
                        if gInfo.param~=0 then
                            local adventureInfo = AdventureInfo.getAdventureInfoByID(gInfo.param)
							local tab = math.ceil(gInfo.param / 10000)
                            AdvConfirmMgrNew.showForGetWay(SceneMgr.getRunningScene, gInfo.param%10000, tab)
                        else
                            ItemInfoViewMgr.closeCurUI(function() 
                                   WorldMapMgr.searchAdventureNode(WorldMapMgr.curAID)
                            end)
                            
                        end
                    elseif gInfo.type==2 then
                        ItemInfoViewMgr.closeCurUI(function()
                            LostTowerMgr.sendCreateReq(function()
                                SceneMgr.replaceScene(SceneMgr.getRunningScene, "LostTowerScene")
                            end)
                        end)
                    elseif gInfo.type==3 then
                        ItemInfoViewMgr.closeCurUI(function()
                            PetFormationMgr.show(scene)
                            end)
                        
                    elseif gInfo.type==4 then
                        if gInfo.param~=0 then
                            ItemInfoViewMgr.closeCurUI(function()
                                PetExploreMgr.request(scene, gInfo.param)
                            end
                            )
                        else
                            local curExploreID = WorldMapMgr.curAID>=5 and WorldMapMgr.curAID or 5
                            ItemInfoViewMgr.closeCurUI(function()
                                PetExploreMgr.request(scene, curExploreID)
                            end
                            )
                        end
                    elseif gInfo.type==5 then
                        if gInfo.param == 0 then
                            TipsMgr.show(scene, "bag15")
                        elseif gInfo.param == 1 then
                            ItemInfoViewMgr.closeCurUI(function()
                                MapSeekerMgr.autoSeekPath("TownScene", "b7")
                            end)
                        elseif gInfo.param == 2 then
                            LtExchangeViewMgr.callLTShop()
                        end
                    elseif gInfo.type==6 then
                           ItemInfoViewMgr.closeCurUI(function()
                                GachaViewMgr.show(scene)
                            end)                        
                        
                    elseif gInfo.type==7 then
                        
                           ItemInfoViewMgr.closeCurUI(function()
                                CheckViewMgr.show(scene)
                            end)  
                    elseif gInfo.type==8 then
                           ItemInfoViewMgr.closeCurUI(function()
                                MissionListMgr.show(scene, 2)
                            end)
                        
                    elseif gInfo.type==9 then
                        ItemInfoViewMgr.closeCurUI(function()
                            MapSeekerMgr.autoSeekPath("TownScene", "b5",function()
                                AuctionMgrNew.request(SceneMgr.getRunningScene)
                            end)
                        end)
                    elseif gInfo.type==10 then
                        ItemInfoViewMgr.closeCurUI(function()
                            MapSeekerMgr.autoSeekPath("TownScene", "b3",function()
                                LifeSkillSelViewMgr.request(SceneMgr.getRunningScene)
                            end)
                        end)
                    elseif gInfo.type==11 then
                           ItemInfoViewMgr.closeCurUI(function()
                                MissionListMgr.show(scene, 3)
                            end)
                    elseif gInfo.type==12 then
                           ItemInfoViewMgr.closeCurUI(function()
                                MapSeekerMgr.autoSeekPath("TownScene", "b8")
                            end)      
                   elseif gInfo.type==13 then
                        DialogBoxMgr.showSmallDialogBox(scene, 1, "iteminfo51")
                    end
                end)
            end
        end
        
        if operable==true then
            CSResourceMgr.setButtonString(resName, "sell", "bag7", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            CSResourceMgr.setButtonString(resName, "use", "bag8", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            CSResourceMgr.setButtonString(resName, "useTen", "bag16", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)

            --使用十次专用
            if iteminfo.itemType==8 or iteminfo.itemType==18 or iteminfo.itemType==24 then
                if info.sum>=10 then
                    CSResourceMgr.getNodeByName(resName, "sell"):setPositionX(170)
                    CSResourceMgr.getNodeByName(resName, "use"):setPositionX(470)
                    CSResourceMgr.getNodeByName(resName, "useTen"):setVisible(true)
                    CSResourceMgr.clickEventBinding(resName, "useTen", function()
                        local targetStr = ""
                        if iteminfo.itemType==18 then
                            TreeInfoView.resetCompoundPetInfo()
                        end
                        NetInterface.sendWithBlock("GC_UseItem_Ack", function()
                            --print("use exp package: \npet:", sender.objID, "item:", info.id, "num:", 1)
                            local ItemSend = require("src.Net.Send.ItemSend")
                            ItemSend.sendCG_UseItem_Req({itemID=info.id, targetNum=0, targetStr=targetStr, useNum=10})
                        end, function()
                            print("使用十个物品成功")
                            StandardTipsMgr.show(0, "iteminfo30")
                        end, function(code)
                            TreeInfoView.isOpenBox = false
                            if code==Proto.Error.ERROR_FASHION_EXIST then
                                StandardTipsMgr.show(1, "fashiontip1")
                            elseif code==Proto.Error.ERROR_TREE_ALREADY_EXIST then
                                StandardTipsMgr.show(1, "TreeInfo10")
                            elseif code==-1 then
                                lastItemNum = info.sum
                                ItemInfo.reqItemNum({info.id})
                            else
                                TipsMgr.showError(scene, code)
                            end
                        end,nil,false)
                        ItemInfoViewMgr.hide() 
                    end)
                end
            end

            if iteminfo.bUse==0 then
                CSResourceMgr.getNodeByName(resName, "sell"):setPositionX(320)
            	CSResourceMgr.getNodeByName(resName, "use"):setVisible(false)
                CSResourceMgr.getNodeByName(resName, "useTen"):setVisible(false)
            end
            CSResourceMgr.clickEventBinding(resName, "sell", function()
                ItemNumViewMgr.show(info,function(selNum)
                        NetInterface.sendWithBlock("GC_SellItem_Ack", function()
                            local ItemSend = require("src.Net.Send.ItemSend")
                            ItemSend.sendCG_SellItem_Req({itemID=info.id, objID=info.objID, num=selNum})
                        end,function()
                            GameAudio.playUISound("itemSell")
                            TipsMgr.show(scene, "iteminfo31")
                        end,function(code)
                            if code==-1 then
                                lastItemNum = info.sum
                                ItemInfo.reqItemNum({info.id})
                            else
                                TipsMgr.showError(scene, code)
                            end
                    end,nil,false)
                end)
                ItemInfoViewMgr.hide()
            end)
            CSResourceMgr.clickEventBinding(resName, "use", function()

                if iteminfo.itemType == Proto.IC_SELECTABLEBOX then
                    local MultiItemBoxView = require("src.GameMgr.Item.MultiItemBoxView")
                    MultiItemBoxView.new(info,function()
                            ItemInfoViewMgr.closeCurUI()

                        end)
                    return 
                end
                if iteminfo.itemType==19 then
                    -- BagViewMgr.hide()
                    ItemInfoViewMgr.closeCurUI(function()
                        PetFormationMgr.show(scene)
                    end)
                                      
                    --[[
                    PetListMgr.show(scene, function(sender)
                        PetEducationMgr.show(SceneMgr.getRunningScene, sender.objID, 1, function()
                            PetListMgr.refresh(PokemonInfo.getPetInfoByObjID(sender.objID))
                        end)
                    end)
                    ]]  
                else
                    --TipsMgr.show(scene, "假装发使用物品协议")
                    local targetStr = ""
                    if iteminfo.itemType==25 then
                        if SceneMgr.currentScene=="TownScene" then
                            local posX = TownTreeMgr.checkMyTreePosx()
                            if posX then
                                targetStr = tostring(posX)
                            else
                                StandardTipsMgr.show(1, "TreeInfo14")
                                return
                            end
                        else
                            StandardTipsMgr.show(1, "TreeInfo11")
                            return
                        end
                    end
                    if iteminfo.itemType==18 then
                        TreeInfoView.resetCompoundPetInfo()
                    end
                    NetInterface.sendWithBlock("GC_UseItem_Ack", function()
                        --print("use exp package: \npet:", sender.objID, "item:", info.id, "num:", 1)
                        local ItemSend = require("src.Net.Send.ItemSend")
                        ItemSend.sendCG_UseItem_Req({itemID=info.id, targetNum=0, targetStr=targetStr, useNum=1})
                    end, function()
                        print("使用单个物品成功")
                        StandardTipsMgr.show(0, "iteminfo30")
                    end, function(code)
                        TreeInfoView.isOpenBox = false
                        if code==Proto.Error.ERROR_FASHION_EXIST then
                            StandardTipsMgr.show(1, "fashiontip1")
                        elseif code==Proto.Error.ERROR_TREE_ALREADY_EXIST then
                            StandardTipsMgr.show(1, "TreeInfo10")
                        elseif code==-1 then
                            lastItemNum = info.sum
                            ItemInfo.reqItemNum({info.id})
                        else
                            TipsMgr.showError(scene, code)
                        end
                    end,nil,false)
                    ItemInfoViewMgr.hide()
                end     
            end)
        end

        if itemType==4 then
            if operable == true then
                CSResourceMgr.getNodeByName(resName, "sell"):setVisible(false)
                CSResourceMgr.getNodeByName(resName, "use"):setPositionX(320)
                CSResourceMgr.setButtonString(resName, "use", "PetPiece1", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            end
            CSResourceMgr.getNodeByName(resName, "usetip"):setVisible(false)
            local petpiece = CSResourceMgr.getNodeByName(resName, "petpiece")
            petpiece:setVisible(true)
            local petPieceInfo = ItemInfo.getPetPieceInfoById(info.id)
            local pokemonInfo = PokemonInfo.getPokemonInfoByID(PokemonInfo.getGeneInfoByID(petPieceInfo.pokeID).petID)
            local icon1 = "Pet/AttriIcon/"..pokemonInfo.elementAtt1..".png"
            local icon2 = "Pet/AttriIcon/small_"..pokemonInfo.elementAtt1..".png"
            CSResourceMgr.seekNodeByName(petpiece,"attr"):loadTexture(icon1)
            CSResourceMgr.seekNodeByName(petpiece,"attrBack"):loadTexture(icon2)
            CSResourceMgr.seekNodeByName(petpiece,"rare"):loadTexture(orderString[pokemonInfo.rarePoint])
            local iconpath =  "Pet/PetIcon/"..pokemonInfo.icon..".png"
            local icon = CSResourceMgr.getNodeByName(resName,"icon")
            CSResourceMgr.setSpriteTextureByNode(icon, iconpath)
            icon:setScale(0.7,0.7)
            local jindu = CSResourceMgr.getNodeByName(resName, "jindu")
            CSResourceMgr.setLabelStringByNode(jindu, "PetPiece3", {r=0,g=0,b=0,a=255,w=1})
            CSResourceMgr.setLabelColorByNode(jindu, {r=217,g=234,b=255,a=255})
            if not info.sum then
                info.sum = BagViewMgr.getPieceNum(info.id)
            end
            local lableWidth = jindu:getContentSize().width
            local lablePosX = jindu:getPositionX()
            local numColor = info.sum>=petPieceInfo.num and {r=144,g=255,b=0,a=255} or {r=255,g=78,b=0,a=255}
            local jinduNum1 = CSResourceMgr.getNodeByName(resName, "jinduNum1")
            CSResourceMgr.setLabelStringByNode(jinduNum1, info.sum, {r=0,g=0,b=0,a=255,w=1})
            CSResourceMgr.setLabelColorByNode(jinduNum1, numColor)
            jinduNum1:setPositionX(lablePosX+lableWidth)
            local lableWidth2 = jinduNum1:getContentSize().width
            local jinduNum2 = CSResourceMgr.getNodeByName(resName, "jinduNum2")
            CSResourceMgr.setLabelStringByNode(jinduNum2, "/"..petPieceInfo.num, {r=0,g=0,b=0,a=255,w=1})
            CSResourceMgr.setLabelColorByNode(jinduNum2, {r=217,g=234,b=255,a=255})
            jinduNum2:setPositionX(lablePosX+lableWidth+lableWidth2)

            if info.sum>=petPieceInfo.num then
                CSResourceMgr.clickEventBinding(resName, "use", function()
                    compoundPetInfo = nil
                    NetInterface.sendWithBlock("GC_CompoundPetPiece_Ack", function()
                        local PetSend = require("src.Net.Send.PetSend")
                        PetSend.sendCG_CompoundPetPiece_Req({PetPieceID = info.id})
                        end, function()
                            petWiki[PokemonInfo.getGeneInfoByID(petPieceInfo.pokeID).petID] = PokemonInfo.getGeneInfoByID(petPieceInfo.pokeID).petID
                            local diban = CSResourceMgr.getNodeByName(resName,"db")
                            local effAni = AnimationMgr.createAni(diban, "Spine/effects/UI_suipianhecheng.png", 
                                diban:getContentSize().width/2, diban:getContentSize().height/2)
                            AnimationMgr.playAni(effAni.res, "animation", true, effAni.tag)
                            playPetAniTag = effAni.tag
                            effAni:setLocalZOrder(10)
                            local diff = CocosModuleMgr.getScreenSizeDiff()
                            local esize = effAni:getContentSize()
                            effAni:setContentSize(esize.width, esize.height+diff)
                            BagViewMgr.update(info.id, info.sum-petPieceInfo.num)
                            GameAudio.playUISound("petPieces") 
                            TaskWatcherManager.saveChongWuHeChengState({rarePoint = pokemonInfo.rarePoint})
                            diban:performWithDelay(function()
                                ItemInfoViewMgr.hide()
                                GachaViewMgr.playGetAPet(PokemonInfo.getGeneInfoByID(petPieceInfo.pokeID).petID,compoundPetInfo)
                                end,0.7)
                        end,function(code)
                            TipsMgr.showError(scene, code)
                        end)
                    end)
            else
                CSResourceMgr.setButtonTexture(resName, "use", "UI/CommonFiles/menu_gray_normal_su_01.png", "UI/CommonFiles/menu_gray_normal_su_01.png", "UI/CommonFiles/menu_gray_normal_su_01.png")
                CSResourceMgr.clickEventBinding(resName, "use", function()
                    StandardTipsMgr.show(1, "PetPiece4")
                    end)
            end
        end
        
        CSResourceMgr.clickEventBinding(resName, "bg", function()
            ItemInfoViewMgr.hide()
        end)
        CSResourceMgr.clickEventBinding(resName, "close", function()
            ItemInfoViewMgr.hide()
        end)
    end

    local function playCSB()
        if info.type==1 then
            local db = CSResourceMgr.getNodeByName(resName, "db")
            db:setVisible(true)
            CocosModuleMgr.showUIAnimation(db, "down")
        end
    end
    local funcTable = {loadCSB, playCSB}
    UnblockLoader.load(funcTable, "ItemInfoViewMgr")
end

function ItemInfoViewMgr.closeCurUI(callback)
    --[[
    if UIStack.isUIOpen("BagViewMgr") then
        BagViewMgr.hide()    
    end
  
    if CSResourceMgr.getCsbObj("Item/Bag/BagView.csb") then
        BagViewMgr.hide()
    end
    
    if CSResourceMgr.getCsbObj("Pet/Formation/FormationView.csb") then
        PetStarUpMgr.hide()
        PetEducationMgr.hide()
        PetFormationMgr.hide()
    end
    if CSResourceMgr.getCsbObj("Item/Gacha/gachaListView.csb") then
        GachaViewMgr.hide()
    end
    ]]

    UIStack.closeAllUI()
    if callback then
        callback()
    end
end

function ItemInfoViewMgr.hide()
    if curItemType == 1 then
        PetSkillViewMgr.hideConciseSkillInfoPage()
        curItemType = 0
        return
    end
    GameAudio.playUISound("back")   
    PetHandBook.SetPetWikiInfo(petWiki)
    if playPetAniTag~="" then
        AnimationMgr.removeGafObjectByTag(playPetAniTag)
    end
    local list = CSResourceMgr.getNodeByName(resName, "getWayList")
    if list then
        list:removeAllItems()
    end
    lastItemNum = 0
    UnblockLoader.cancel("ItemInfoViewMgr")
    for var=1, 3 do
        CSResourceMgr.removeCSObjectByTag(resNameVec[var])
    end

    if stackFlag == true then 
        UIStack.pop("ItemInfoViewMgr")
    else
        stackFlag = false
    end
end

---显示技能信息(长按代码自行处理)
--@param info table 物品信息，e.g. {id = id, level = level}
--id 技能id; level 技能等级
function ItemInfoViewMgr.showSkill(info)
    local scene = SceneMgr.getRunningScene
    info.id = tonumber(info.id)
    if not info.id then
        return
    end
    local resName = resNameVec[4]
    
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        --CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)
        
        CSResourceMgr.clickEventBinding(resName, "bg", function()
            ItemInfoViewMgr.hideSkill()
        end)
        
        local skillinfo = PokemonInfo.getPetSkillInfoById(info.id)
        
        if info.level then
            local sumLabel = CSResourceMgr.getNodeByName(resName, "num")
            CSResourceMgr.setLabelString(resName, "num", "Lv"..info.level, "", nil, nil, 100)
            sumLabel:enableOutline({r=0,g=0,b=0,a=255}, 1)
        end
        
        CSResourceMgr.setLabelString(resName, "name", skillinfo.name, "", {r=0,g=0,b=0,a=255}, nil, 300)
        --CSResourceMgr.setLabelColor(resName, "name", {r=55,g=178,b=219,a=255})

        CSResourceMgr.setLabelString(resName, "desc", skillinfo.desc)
        CSResourceMgr.setLabelColor(resName, "desc", {r=112,g=131,b=158,a=255})
        CSResourceMgr.setLabelMaxWidth(resName, "desc", 440)
        
        CSResourceMgr.setLabelColor(resName, "infotitle", {r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelString(resName, "infotitle", "iteminfo12", "", nil, nil, 120)
        CSResourceMgr.setLabelColor(resName, "desctitle", {r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelString(resName, "desctitle", "iteminfo13", "", nil, nil, 120)
        
        local usetip = CSResourceMgr.getNodeByName(resName, "usetip")
        CSResourceMgr.setLabelString(resName, "usetip", "iteminfo23", "", nil, nil, 100)
        CSResourceMgr.setLabelColor(resName, "usetip", {r=144,g=238,b=255,a=255})
        usetip:enableOutline({r=38,g=54,b=76,a=255}, 1)
        
        local infoStr = {"iteminfo14", "iteminfo15", "iteminfo16", "iteminfo17"}
        local conetentStr = {"skillType"..skillinfo.skill_A_Type, skillinfo.hitRate, "skillType"..skillinfo.skill_B_Type, skillinfo.power}
        for var=1, #infoStr do
            local infot = CSResourceMgr.getNodeByName(resName, "infot"..var)
            CSResourceMgr.setLabelStringByNode(infot, infoStr[var], nil, nil, 70)
            CSResourceMgr.setLabelColorByNode(infot, {r=144,g=238,b=255,a=255})
            infot:enableOutline({r=38,g=54,b=76,a=255}, 1)
            local infol = CSResourceMgr.getNodeByName(resName, "info"..var)
            if tonumber(conetentStr[var])==0 then
            	conetentStr[var] = "--"
            end
            CSResourceMgr.setLabelStringByNode(infol, conetentStr[var], nil, nil, 70)
            CSResourceMgr.setLabelColorByNode(infol, {r=217,g=234,b=255,a=255})
            infol:enableOutline({r=0,g=0,b=0,a=255}, 1)
        end
        
        CSResourceMgr.setSpriteTexture(resName, "icon", PokemonInfo.getSkillIcon(info.id))
        CSResourceMgr.setSpriteTexture(resName, "level", PetEducationMgr.getRareIcon(skillinfo.airpower))
        local attric, attricdb = PokemonInfo.getAttriPics(skillinfo.skillAtt)
        CSResourceMgr.setSpriteTexture(resName, "attr", attric)
        CSResourceMgr.setSpriteTexture(resName, "attrdb", attricdb)
    end
    
    local function playCSB()
        --[[
        local db = CSResourceMgr.getNodeByName(resName, "db")
        db:setVisible(true)
        CocosModuleMgr.showUIAnimation(db, "down")
        ]]
    end
    
    local funcTable = {loadCSB, playCSB}
    UnblockLoader.load(funcTable, "ItemInfoViewMgr.Skill")
end

function ItemInfoViewMgr.hideSkill()
    UnblockLoader.cancel("ItemInfoViewMgr.Skill")
    CSResourceMgr.removeCSObjectByTag(resNameVec[4])
end

function ItemInfoViewMgr.refreshItemNum(id)
    if lastItemNum == 0 then
        return
    end
    if ItemInfo.getCharItemNum(id) ~= lastItemNum then
        BagViewMgr.update(id, ItemInfo.getCharItemNum(id))
        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "tips42")
        lastItemNum = 0
        BagViewMgr.syncItemInfoWithServer()
    end
end

function ItemInfoViewMgr.setCompoundPetInfo(jsStr)
    local cjson = require("cjson")
    local tbl = cjson.decode(jsStr)
    compoundPetInfo = tbl
end


function ItemInfoViewMgr.isStageOpen(aid, tab)
    tab = tab or math.ceil(aid / 10000)
    for key, var in pairs(WorldMapInfo.getSearchInfo()) do
        local mapid = key
        for pointID, info in pairs(var) do
            local pid = aid%10000
            if pid==info.info then
                local level = WorldMapInfo.getLockInfoByID(mapid)[info.id]
                print("已找到相应副本，解锁要求：", level, "aid:", aid, "tab:", tab)
                if level then
                    if level>CharInfo.get().maplock then
                        return false
                    end
                end
            end
        end
    end
    if tab == 2 then
        if AdvStarMgr.checkClearFlag(aid-10000) then 
            return true 
        else
            return false
        end  -- 普通关卡完成精英页签开启
    elseif tab == 3 then
        if AdvStarMgr.checkClearFlag(aid-10000) then 
            return true 
        else
            return false
        end  -- 精英关卡完成英雄页签开启
    end
    return true
end

return ItemInfoViewMgr