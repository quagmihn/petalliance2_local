local PetExploreMgr = {}

PetExploreMgr.PET_NUM = 6
PetExploreMgr.DEFAULT_PACKET_NUM = 5
PetExploreMgr.ICON_PATH = "Map/WorldMap/icon/"
PetExploreMgr.UNSELPAGE_SCALE = 0.7
PetExploreMgr.SELPAGE_SCALE = 0.9

PetExploreMgr.MAX_LABEL_WIDTH = 620
PetExploreMgr.LABEL_FONT_SIZE = 20

local resNameBG = ""
local resNameA = ""
local resNameB = ""
local resNameC = ""
local resNameD = ""

local curPage = 0
local curAwardSize = 0
local isWeatherLoaded = false
local runingPetNode = {}
local selPetObjIDs = {}
local panelTable = {}
local awardsTable = {}
local timeLabel = nil

local isBagInited = false
local isRequesting = false
local tmpInfo = {}
local curMapInfo = {}

function PetExploreMgr.Init()
    print("PetExploreMgr初始化")
	
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    resNameA = "Pet/Explore/ExploreUIA.csb"
    resNameB = "Pet/Explore/ExploreUIB.csb"
    resNameC = "Pet/Explore/ExploreUIC.csb"
    resNameD = "Pet/Explore/ExploreUID.csb"
    
    curPage = 0
    curAwardSize = 0
    isWeatherLoaded = false
    runingPetNode = {}
    selPetObjIDs = {}
    panelTable = {}
    awardsTable = {}
    timeLabel = nil
    
    isBagInited = false
    isRequesting = false
    tmpInfo = {}
    curMapInfo = {}
end

function PetExploreMgr.request(scene, pIndex)
    pIndex = GameGuideMgr.EXPLORE_ID or pIndex
    if not NetInterface.isConnect then
        return
    end
    local function request()
        NetInterface.sendWithBlock("GC_QuerySelfTerritoryIDInfo_Ack", function()
            local TerritorialSend = require("src.Net.Send.TerritorialSend")
            TerritorialSend.sendCG_QuerySelfTerritoryIDInfo_Req()
        end, function()
            PetExploreMgr.show(scene, pIndex)
        end, function(code)
            TipsMgr.showError(scene, code)
        end)
    end
    request()
end

function PetExploreMgr.show(scene, pIndex)
    if CSResourceMgr.getCsbObj(resNameA) and CSResourceMgr.getCsbObj(resNameB) and CSResourceMgr.getCsbObj(resNameC) then
    	return
    end
    
    UIStack.push("PetExploreMgr", PetExploreMgr.hide, true)
    
    isWeatherLoaded = false
    isBagInited = false
    curAwardSize = 0
    runingPetNode = {}
    panelTable = {}
    awardsTable = {}
    curMapInfo = {}
    
    local eInfoVec = ExploreInfo.getExploreInfoData()
    local infoVec = {}
    local worldInfoVec = {}
    local pathStr = PetExploreMgr.ICON_PATH
    for key, var in pairs(eInfoVec) do
        local exploreID = tonumber(var.aid)
        local eData = ExploreInfo.getExploreInfoByID(exploreID)
        table.insert(infoVec, {id=exploreID, name=var.name, icon=pathStr..var.icon, disicon=pathStr..var.iconl, world=eData.worldID})
        if not worldInfoVec[eData.worldID] then
        	worldInfoVec[eData.worldID] = {}
        end
        table.insert(worldInfoVec[eData.worldID], {name=var.name, index=#infoVec-1, id=exploreID})
        local starNum, starMax = AdvStarMgr.getWorldMapStarNum(exploreID)
        if starNum>=eData.needStar then
        	tmpInfo[exploreID] = 1
        else
            tmpInfo[exploreID] = 2
        end
    end
    --[[
    table.sort(infoVec, function(a, b)
    	return a.id<b.id
    end)]]
    local curExploringID = ExploreInfo.get().exploreID
    if curExploringID then
        tmpInfo[curExploringID] = 0
    end
    curPage = 0
    if pIndex then
        for var=1, #infoVec do
            if pIndex==infoVec[var].id then
                curPage = var-1
                break
            end
        end
    elseif curExploringID then
        for var=1, #infoVec do
            if ExploreInfo.get().exploreID==infoVec[var].id then
                curPage = var-1
                break
            end
        end
    end
    local explorePets = PokemonInfo.getPetArmy(1)
    if explorePets then
        selPetObjIDs = {}
        for key, var in pairs(explorePets) do
            table.insert(selPetObjIDs, var)
        end
    end
    
    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG, "PetExploreMgr")
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "PetExploreMgr")
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    end

	local function loadCSBA()
        local layerA = CSResourceMgr.createRes(scene, resNameA)
        layerA:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameA, 320, 480)
        CocosModuleMgr.setEdgeDistance(layerA, nil, nil, 0, nil)
        
        CSResourceMgr.clickEventBinding(resNameA, "close", function()
            PetExploreMgr.hide()
        end)
        
        local name = CSResourceMgr.getNodeByName(resNameA, "name")
        CSResourceMgr.setLabelColorByNode(name, {r=0,g=215,b=253,a=255})
        local tips = CSResourceMgr.getNodeByName(resNameA, "tips")
        CSResourceMgr.setLabelColorByNode(tips, {r=255,g=252,b=0,a=255})
        CSResourceMgr.setLabelStringByNode(tips, "idling1", {r=0,g=0,b=0,a=255}, nil, 180)
        CSResourceMgr.getNodeByName(resNameA, "imagedb"):scale(PetExploreMgr.SELPAGE_SCALE)
        
        CocosModuleMgr.showUIAnimation(layerA, "down")
	end
	
	local function loadCSBD()
        local layerD = CSResourceMgr.createRes(scene, resNameD)
        layerD:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameD, 320, 480)
        CocosModuleMgr.setEdgeDistance(layerD, nil, nil, 0, nil)
        
        local worldMapNodes = {}
        local curSelWorldMapID = nil
        local curSelAdventureNode = nil
        CSResourceMgr.getNodeByName(resNameD, "maplistdb"):hide()
        CSResourceMgr.setLabelColor(resNameD, "listtitle", {r=96,g=129,b=140,a=255})
        CSResourceMgr.setLabelString(resNameD, "listtitle", "idling22", "", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 140)
        CSResourceMgr.setLabelString(resNameD, "droptitle", "idling6", "", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 140)
        CSResourceMgr.clickEventBinding(resNameD, "cancel", function()
            UnblockLoader.cancel("PetExploreMgr.show-loadIcon")
            CSResourceMgr.getNodeByName(resNameD, "maplistdb"):hide()
            CSResourceMgr.removeList(resNameD, "maplist")
            if curSelWorldMapID then
                CSResourceMgr.setLabelColorByNode(worldMapNodes[curSelWorldMapID].title, {r=217,g=234,b=255,a=255})
                CSResourceMgr.setButtonEnabledByNode(worldMapNodes[curSelWorldMapID].button, true)
            end
            curSelWorldMapID = nil
            curSelAdventureNode = nil
        end)
        
        local list = CSResourceMgr.getNodeByName(resNameD, "list")
        local mapList = CSResourceMgr.getNodeByName(resNameD, "maplist")
        for var=1, WorldMapInfo.getWorldNum() do
        	local parent = CSResourceMgr.getNodeByName(resNameD, "example1"):clone()
            local wInfo = WorldMapInfo.getWorldMapInfoByID(var)
            local maptitle = CSResourceMgr.seekNodeByName(parent, "maptitle")
            CSResourceMgr.setLabelStringByNode(maptitle, wInfo.name, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 130)
			if LuaSqlite.LANG_TYPE == 6 then
				maptitle:setFontSize(maptitle:getFontSize()-3)
			end
            local mapbtn = CSResourceMgr.seekNodeByName(parent, "mapbtn")
            local lock = CSResourceMgr.seekNodeByName(parent, "lock")
            local lockID = tonumber(wInfo.unlockID) or 0
            if CharInfo.get().maplock<lockID then
                CSResourceMgr.setLabelColorByNode(maptitle, {r=124,g=136,b=142,a=255})
            	lock:show()
            	mapbtn:hide()
            else
                CSResourceMgr.setLabelColorByNode(maptitle, {r=217,g=234,b=255,a=255})
                lock:hide()
                mapbtn:show()
                worldMapNodes[var] = {button=mapbtn,  title=maptitle}
                CSResourceMgr.clickEventBindingByNode(mapbtn, function()
                    CSResourceMgr.callButtonFunc(resNameD, "cancel")
                	curSelWorldMapID = var
                    CSResourceMgr.setLabelColorByNode(maptitle, {r=255,g=252,b=0,a=255})
                    CSResourceMgr.setButtonEnabledByNode(mapbtn, false)
                    
                    CSResourceMgr.getNodeByName(resNameD, "maplistdb"):show()
                    local funcVec = {}
                    worldInfoVec[var] = worldInfoVec[var] or {}
                    for v=1, #worldInfoVec[var] do
                        table.insert(funcVec, function()
                            local pInfo = worldInfoVec[var][v]
                        	local cloneNode = CSResourceMgr.getNodeByName(resNameD, "example2"):clone()
                            local ftitle = CSResourceMgr.seekNodeByName(cloneNode, "ftitle")
                            CSResourceMgr.setLabelStringByNode(ftitle, pInfo.name, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 130)
							if LuaSqlite.LANG_TYPE == 6 then
								ftitle:setFontSize(ftitle:getFontSize()-3)
							end
                            local fbtn = CSResourceMgr.seekNodeByName(cloneNode, "fbtn")
                            if tmpInfo[pInfo.id]==2 then
                                CSResourceMgr.setLabelColorByNode(ftitle, {r=170,g=169,b=169,a=255})
                                fbtn:hide()
                            else
                                CSResourceMgr.setLabelColorByNode(ftitle, {r=252,g=239,b=178,a=255})
                                fbtn:show()
                                CSResourceMgr.clickEventBindingByNode(fbtn, function()
                                    curPage = pInfo.index
                                    PetExploreMgr.changeMap(pInfo.id)
                                    --CSResourceMgr.callButtonFunc(resNameD, "cancel")
                                    if curSelAdventureNode then
                                        CSResourceMgr.setLabelColorByNode(curSelAdventureNode[1], {r=252,g=239,b=178,a=255})
                                        CSResourceMgr.setButtonEnabledByNode(curSelAdventureNode[2], true)
                                    end
                                    curSelAdventureNode = {ftitle, fbtn}
                                    CSResourceMgr.setLabelColorByNode(ftitle, {r=255,g=252,b=0,a=255})
                                    CSResourceMgr.setButtonEnabledByNode(fbtn, false)
                                end)
                            end
                            if pInfo.index==curPage then
                                CSResourceMgr.setLabelColorByNode(ftitle, {r=255,g=252,b=0,a=255})
                                CSResourceMgr.setButtonEnabledByNode(fbtn, false)
                                curSelAdventureNode = {ftitle, fbtn}
                            end
                            if tmpInfo[pInfo.id]==0 then
                                local finfo = CSResourceMgr.seekNodeByName(cloneNode, "finfo")
                                CSResourceMgr.setLabelColorByNode(finfo, {r=132,g=255,b=0,a=255})
                                CSResourceMgr.setLabelStringByNode(finfo, "idling1", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 100)
                                finfo:show()
                            end
                            cloneNode:setScaleY(0)
                            transition.scaleTo(cloneNode, {scale=1, time=0.1})
                            cloneNode:show()
                            mapList:pushBackCustomItem(cloneNode)
                        end)
                    end
                    UnblockLoader.load(funcVec, "PetExploreMgr.show-loadIcon")
                end)
            end
            --parent:setScaleY(0)
            --transition.scaleTo(parent, {scale=1, time=0.1})
            parent:show()
            list:pushBackCustomItem(parent)
        end
        
        CocosModuleMgr.showUIAnimation(layerD, "down")
	end
	
    local function loadCSBB()
        local layerB = CSResourceMgr.createRes(scene, resNameB)
        layerB:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameB, 320, 480)
        CocosModuleMgr.setEdgeDistance(layerB, nil, nil, nil, 0)
        
        CSResourceMgr.getNodeByName(resNameB, "ma1"):setLocalZOrder(CocosModuleMgr.ZORDER_MAP_BACK)
        CSResourceMgr.getNodeByName(resNameB, "mb1"):setLocalZOrder(CocosModuleMgr.ZORDER_MAP_BACK)
        CSResourceMgr.getNodeByName(resNameB, "ma2"):setLocalZOrder(CocosModuleMgr.ZORDER_PLAYER)
        CSResourceMgr.getNodeByName(resNameB, "mb2"):setLocalZOrder(CocosModuleMgr.ZORDER_PLAYER)
        CSResourceMgr.getNodeByName(resNameB, "petdb"):setLocalZOrder(CocosModuleMgr.ZORDER_CHARACTOR)
        CSResourceMgr.getNodeByName(resNameB, "emydb"):setLocalZOrder(CocosModuleMgr.ZORDER_CHARACTOR)
        CSResourceMgr.getNodeByName(resNameB, "ma3"):setLocalZOrder(CocosModuleMgr.ZORDER_MAP_FRONT)
        CSResourceMgr.getNodeByName(resNameB, "mb3"):setLocalZOrder(CocosModuleMgr.ZORDER_MAP_FRONT)
        
        CocosModuleMgr.showUIAnimation(layerB, "up")
    end
    
    local function loadCSBC()
        local layerC = CSResourceMgr.createRes(scene, resNameC)
        layerC:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameC, 320, 480)
        
        function PetExploreMgr.refreshBagNum()
            local events = ExploreInfo.get().events
            CSResourceMgr.setLabelString(resNameC, "bagnum", #events.."/"..CharInfo.get().explorepacketnum, "", nil, nil, 100)
            if #events>=CharInfo.get().explorepacketnum then
                CSResourceMgr.setLabelString(resNameC, "time", "idling20")
                CSResourceMgr.getNodeByName(resNameC, "progress"):setPercent(100)
                CocosModuleMgr.showShiningToNode(CSResourceMgr.getNodeByName(resNameC, "getaward"), 4)
            else
                CocosModuleMgr.hideShiningToNode(CSResourceMgr.getNodeByName(resNameC, "getaward"))
                ExploreViewMgr.hideRedPoint(1)
            end
        end
        PetExploreMgr.refreshBagNum()
        
        CSResourceMgr.setLabelColor(resNameC, "awtext", {r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelString(resNameC, "awtext", "idling4", "", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setLabelString(resNameC, "starttitle", "idling3", "", {r=1,g=11,b=58,a=255}, nil, 120)
        CSResourceMgr.setLabelString(resNameC, "gnum", "", "", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setLabelString(resNameC, "enum", "", "", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setLabelColor(resNameC, "bagnum", {r=0,g=255,b=90,a=255})
        CSResourceMgr.setLabelColor(resNameC, "bagtitle", {r=165,g=208,b=255,a=255})
        CSResourceMgr.setLabelString(resNameC, "bagtitle", "menu2", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS, nil, 200)
        CSResourceMgr.setLabelString(resNameC, "bosstitle", "stageboss13", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS, nil, 80)
        CSResourceMgr.setLabelString(resNameC, "buffinfo", "idling18", "", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 400)
        CSResourceMgr.getNodeByName(resNameC, "buffinfo"):zorder(1)
        CSResourceMgr.setLabelString(resNameC, "time", "", "", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setLabelString(resNameC, "awardtitle", "idling9", "", {r=0,g=0,b=0,a=255}, nil, 80)
        CSResourceMgr.getNodeByName(resNameC, "bagnum"):setLocalZOrder(2)
        CSResourceMgr.getNodeByName(resNameC, "addbag"):setLocalZOrder(2)
        CSResourceMgr.getNodeByName(resNameC, "bagdb"):setLocalZOrder(2)
        CSResourceMgr.getNodeByName(resNameC, "panel"):setAnchorPoint(0.5, 0.5)
        
        CSResourceMgr.clickEventBinding(resNameC, "addbag", function()
            local buyID = CharInfo.get().explorepacketnum+1
            if not ExploreInfo.getExplorePacketBuyInfoByID(buyID) then
                TipsMgr.show(scene, "idling21")
                return
            end
            local cost = ExploreInfo.getExplorePacketBuyCostStr(buyID)
            local costStr = ""
            if cost=="" then
                costStr = "idling26"
            else
                --阿杜修改英文版显示
                if LuaSqlite.LANG_TYPE ==1 then
                    costStr = CocosModuleMgr.createStringWithFormat({"idling14", cost})
                else
                    costStr = cost
                end
            end
            DialogBoxMgr.showSmallDialogBox(scene, 2, costStr, function()
                if ExploreInfo.getExplorePacketBuyInfoByID(buyID).gcash>CharInfo.getGCash() then
                    StandardTipsMgr.show(1, "tips13")
                    return
                end
                if ExploreInfo.getExplorePacketBuyInfoByID(buyID).mcash>CharInfo.getMCash() then
                    StandardTipsMgr.show(1, "tips14")
                    return
                end

                NetInterface.sendWithBlock("GC_BuyExplorePacket_Ack", function()
                    local ExploreSend = require("src.Net.Send.ExploreSend")
                    ExploreSend.sendCG_BuyExplorePacket_Req()
                end, function()
                    GameAudio.playUISound("success")
                    PetExploreMgr.refreshServerTime()
                    PetExploreMgr.refreshAwards(true)
                end, function(code)
                    TipsMgr.showError(scene, code)
                end)
            end)
        end)
        CSResourceMgr.clickEventBinding(resNameC, "getaward", function(sender)
            CocosModuleMgr.hideShiningToNode(sender)
            if #ExploreInfo.get().events==0 then
                StandardTipsMgr.show(1, "idling19")
                return
            end
            local items = ExploreInfo.get().events
            local awards = {}
            for key, var in pairs(items) do
                table.insert(awards, {var.item, var.count})
            end
            NetInterface.sendWithBlock("GC_EndExplore_Ack", function()
                local ExploreSend = require("src.Net.Send.ExploreSend")
                ExploreSend.sendCG_EndExplore_Req({exploreIndex = ExploreInfo.get().exploreID})
            end, function()
                PetExploreMgr.refreshServerTime()
                PetExploreMgr.refreshAwards()
                AwardsListMgr.show(scene, awards)
            end, function(code)
                TipsMgr.showError(scene, code)
            end)
        end, "", 3)
        CSResourceMgr.setButtonEnabled(resNameC, "start", false)
        CSResourceMgr.clickEventBinding(resNameC, "start", function()
            if tmpInfo[infoVec[curPage+1].id]==2 then
                DialogBoxMgr.showSmallDialogBox(scene, 2, CocosModuleMgr.createStringWithFormat({"idling17", 
                    infoVec[curPage+1].name}), function()
                    PetExploreMgr.hide()
                    WorldMapMgr.searchAdventureNode(infoVec[curPage+1].id)
                    end)
            else
                if #selPetObjIDs==0 then
                    DialogBoxMgr.showSmallDialogBox(scene, 1, "idling11")
                    return
                end
                local function exploreFunc()
                    CSResourceMgr.callButtonFunc(resNameD, "cancel")
                    local boolFirst = true
                    if ExploreInfo.get().exploreID then
                    	boolFirst = false
                    end
                    NetInterface.sendWithBlock("GC_Explore_Ack", function()
                        local ExploreSend = require("src.Net.Send.ExploreSend")
                        print("sendCG_Explore_Req:")
                        print(" exploreIndex", infoVec[curPage+1].id)
                        print(" difficulty", "0")
                        print(" option", "0")
                        print(" petObjIDs size", #selPetObjIDs)
                        ExploreSend.sendCG_Explore_Req({
                            exploreIndex = infoVec[curPage+1].id,
                            difficulty = 0,
                            option = 0,
                            petObjIDs = selPetObjIDs,
                        })
                    end, function()
                        tmpInfo[infoVec[curPage+1].id] = 0
                        PetExploreMgr.changeMap(infoVec[curPage+1].id)
                        if not boolFirst then
                            TipsMgr.show(scene, "idling25")
                        end
                    end, function(code)
                        TipsMgr.showError(scene, code)
                    end)
                end
                if ExploreInfo.get().exploreID then
                    for var=1, #infoVec do
                        if tmpInfo[infoVec[var].id]==0 then
                            tmpInfo[infoVec[var].id] = 1
                        end
                    end
                    exploreFunc()
                else
                    exploreFunc()
                end
            end
        end, "", 3)
        
        --根据屏幕分辨率设置列表高度
        local list = CSResourceMgr.getNodeByName(resNameC, "list")
        local listdb = CSResourceMgr.getNodeByName(resNameC, "diban")
        local lsize = list:getContentSize()
        local lbsize = listdb:getContentSize()
        local hdiff = CocosModuleMgr.getScreenSizeDiff()
        listdb:setContentSize({width=lbsize.width, height=lbsize.height+hdiff})
        list:setContentSize({width=lsize.width, height=lsize.height+hdiff})
        local upnodes = CSResourceMgr.getNodeByName(resNameC, "upnodes")
        local upPosy = upnodes:getPositionY()
        upnodes:setPositionY(upPosy+hdiff)
        local bossnodes = CSResourceMgr.getNodeByName(resNameC, "bossdiban")
        local bsPosy = bossnodes:getPositionY()
        bossnodes:setPositionY(bsPosy+hdiff)
        local buffinfo = CSResourceMgr.getNodeByName(resNameC, "buffinfo")
        local bfPosy = buffinfo:getPositionY()
        buffinfo:setPositionY(bfPosy+hdiff)
        
        CocosModuleMgr.showUIAnimation(layerC, "up")
    end
    
    local funcTable = {loadBG, loadCSBA, loadCSBD, loadCSBB, loadCSBC, function()
        PetExploreMgr.changeMap(infoVec[curPage+1].id)
    end}
    UnblockLoader.load(funcTable, "PetExploreMgr.show")
end

function PetExploreMgr.hide()
    PetExploreMgr.hideRuningPet()
    UnblockLoader.cancel("PetExploreMgr.refreshAwards")
    UnblockLoader.cancel("PetExploreMgr.refreshDropInfo")
    UnblockLoader.cancel("PetExploreMgr.show-loadMap")
    UnblockLoader.cancel("PetExploreMgr.show-loadIcon")
    UnblockLoader.cancel("PetExploreMgr.show")
    CSResourceMgr.removePage(resNameA, "page")
    CSResourceMgr.removeList(resNameC, "list")
    EmbeddedMapMgr.removeWeatherEffect(nil, "PetExploreMgr.show-loadMap")
    CSResourceMgr.removeCSObjectByTag(resNameBG, "PetExploreMgr")
    CSResourceMgr.removeCSObjectByTag(resNameA)
    CSResourceMgr.removeCSObjectByTag(resNameB)
    CSResourceMgr.removeCSObjectByTag(resNameC)
    CSResourceMgr.removeCSObjectByTag(resNameD)
    GameAudio.playUISound("retract")
    UIStack.pop("PetExploreMgr")
end

function PetExploreMgr.changeMap(id)
    if curMapInfo.id==id and curMapInfo.status==tmpInfo[id] then
    	return
    end
    --0挂机中  1没有挂机中 2未解锁
    if tmpInfo[id]==0 then
        CSResourceMgr.setButtonEnabled(resNameC, "start", false)
        CSResourceMgr.getNodeByName(resNameA, "tips"):show()
    else
        CSResourceMgr.setButtonEnabled(resNameC, "start", true)
        CSResourceMgr.getNodeByName(resNameA, "tips"):hide()
    end
    curMapInfo = {id=id, status=tmpInfo[id]}
    
    local curExploreInfo = ExploreInfo.getExploreInfoByID(id)
    local icon = CSResourceMgr.getNodeByName(resNameA, "icon")
    local name = CSResourceMgr.getNodeByName(resNameA, "name")
    if tmpInfo[id]==2 then
        CSResourceMgr.setSpriteTextureByNode(icon, PetExploreMgr.ICON_PATH..ExploreInfo.getExploreInfoDataByID(id).iconl)
        CSResourceMgr.setLabelColorByNode(name, {r=220,g=217,b=217,a=255})
        CSResourceMgr.setLabelStringByNode(name, "idling2", {r=0,g=0,b=0,a=255}, nil, 200)
        CSResourceMgr.setButtonTexture(resNameC, "start", "Pet/Explore/jiesuo.png", "Pet/Explore/jiesuo2.png", "Pet/Explore/jiesuo2.png")
        CSResourceMgr.setLabelString(resNameC, "starttitle", "idling16", nil, nil, nil, 120)
        CSResourceMgr.setLabelString(resNameC, "gnum", "-/-")
        CSResourceMgr.setLabelString(resNameC, "enum", "-/-")
    else
        CSResourceMgr.setSpriteTextureByNode(icon, PetExploreMgr.ICON_PATH..ExploreInfo.getExploreInfoDataByID(id).icon)
        CSResourceMgr.setLabelColorByNode(name, {r=0,g=215,b=253,a=255})
        local curExName = ExploreInfo.getExploreInfoDataByID(id).name
        CSResourceMgr.setLabelStringByNode(name, curExName, {r=0,g=0,b=0,a=255}, nil, 200)
        CSResourceMgr.setButtonTexture(resNameC, "start", "Pet/Explore/tansuo.png", "Pet/Explore/tansuo2.png", "Pet/Explore/tansuo1.png")
        CSResourceMgr.setLabelString(resNameC, "starttitle", "idling3", nil, nil, nil, 120)
        CSResourceMgr.setLabelString(resNameC, "gnum", CocosModuleMgr.createStringWithFormat({"<1>/<2>s", 
            curExploreInfo.normalMoney, curExploreInfo.normalAwardTime}))
        CSResourceMgr.setLabelString(resNameC, "enum", CocosModuleMgr.createStringWithFormat({"1/<1>s", 
            curExploreInfo.randomAwardTime}))
    end    
    if id==TerritorialInfo.getMyStageID() or TerritorialInfo.getFamilyTerritorialInfo()[id] then
        CSResourceMgr.setLabelColor(resNameC, "awtext", {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelString(resNameC, "awtext", "idling4", "", {r=194,g=114,b=71,a=255})
        CSResourceMgr.getNodeByName(resNameC, "bossdiban"):show()
        CSResourceMgr.getNodeByName(resNameC, "upflag"):show()
        CSResourceMgr.getNodeByName(resNameC, "buffinfo"):hide()
        CSResourceMgr.setSpriteTexture(resNameC, "upflag", "UI/CommonFiles/buff_yellow.png")
        CSResourceMgr.setLabelString(resNameC, "enum", CocosModuleMgr.createStringWithFormat({"1/<1>s", 
            curExploreInfo.territorialTime}))
        if id~=TerritorialInfo.getMyStageID() and TerritorialInfo.getFamilyTerritorialInfo()[id] then
        	CSResourceMgr.getNodeByName(resNameC, "buffinfo"):show()
            CSResourceMgr.setSpriteTexture(resNameC, "upflag", "UI/CommonFiles/buff1.png")
            CSResourceMgr.setLabelString(resNameC, "enum", CocosModuleMgr.createStringWithFormat({"1/<1>s", 
                curExploreInfo.familyTime}))
        end
    else
        CSResourceMgr.setLabelColor(resNameC, "awtext", {r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelString(resNameC, "awtext", "idling4", "", {r=0,g=0,b=0,a=255})
        CSResourceMgr.getNodeByName(resNameC, "bossdiban"):hide()
        CSResourceMgr.getNodeByName(resNameC, "upflag"):hide()
        CSResourceMgr.getNodeByName(resNameC, "buffinfo"):hide()
    end

    UnblockLoader.cancel("PetExploreMgr.show-loadMap")
    local loadMapFunc = {function()
        local emyNode = CSResourceMgr.getNodeByName(resNameB, "emydb")
        transition.stopTarget(emyNode)
        emyNode:removeAllChildren()
        emyNode:setPosition(640, 100)
    	for var=1, 3 do
            CSResourceMgr.setSpriteTexture(resNameB, "ma"..var, "empty.png")
            CSResourceMgr.setSpriteTexture(resNameB, "mb"..var, "empty.png")
            local node1 = CSResourceMgr.getNodeByName(resNameB, "ma"..var)
            local node2 = CSResourceMgr.getNodeByName(resNameB, "mb"..var)
            transition.stopTarget(node1)
            transition.stopTarget(node2)
            node1:setPositionX(0)
            node2:setPositionX(640)
    	end
    end}
    local mapResVec = 
        {
        ExploreInfo.getExploreInfoDataByID(id).mapb or "nil", 
        ExploreInfo.getExploreInfoDataByID(id).map or "nil", 
        ExploreInfo.getExploreInfoDataByID(id).mapf or "nil", 
        }
    for var=1, #mapResVec do
        if mapResVec[var]~="nil" then
            table.insert(loadMapFunc, function()
                local node1 = CSResourceMgr.getNodeByName(resNameB, "ma"..var)
                local node2 = CSResourceMgr.getNodeByName(resNameB, "mb"..var)
                CSResourceMgr.setSpriteTexture(resNameB, "ma"..var, mapResVec[var], nil, false)
                CSResourceMgr.setSpriteTexture(resNameB, "mb"..var, mapResVec[var], nil, false)
                node1:setOpacity(0)
                node2:setOpacity(0)
                transition.fadeIn(node1, {time=0.3})
                transition.fadeIn(node2, {time=0.3})
            end)
    	end
    end
    if not isWeatherLoaded then
        table.insert(loadMapFunc, function()
            EmbeddedMapMgr.addWeatherEffect(CSResourceMgr.getNodeByName(resNameB, "parent"), nil, "PetExploreMgr.show-loadMap")
            isWeatherLoaded = true
        end)
    end
    PetExploreMgr.hideRuningPet()
    if tmpInfo[id]==0 then
        table.insert(loadMapFunc, function()
            local mapTbl = 
                {
                    CSResourceMgr.getNodeByName(resNameB, "ma1"),
                    CSResourceMgr.getNodeByName(resNameB, "mb1"),
                    CSResourceMgr.getNodeByName(resNameB, "ma2"),
                    CSResourceMgr.getNodeByName(resNameB, "mb2"),
                    CSResourceMgr.getNodeByName(resNameB, "ma3"),
                    CSResourceMgr.getNodeByName(resNameB, "mb3"),
                }
            local diffRate = 0.6
            local speedTbl = 
                {
                    EmbeddedMapMgr.DEFAULT_SPEED*diffRate, 
                    EmbeddedMapMgr.DEFAULT_SPEED*diffRate, 
                    EmbeddedMapMgr.DEFAULT_SPEED, 
                    EmbeddedMapMgr.DEFAULT_SPEED, 
                    EmbeddedMapMgr.DEFAULT_SPEED/diffRate, 
                    EmbeddedMapMgr.DEFAULT_SPEED/diffRate
                }
            local emyNode = CSResourceMgr.getNodeByName(resNameB, "emydb")
            for key, var in pairs(mapTbl) do
                if var then
                    local size = var:getContentSize()
                    local time = size.width/speedTbl[key]
                    local posx = var:getPositionX()
                    local sequence = transition.sequence({
                        cc.MoveBy:create(time, cc.p(-size.width, 0)),
                        cc.CallFunc:create(function()
                            var:setPositionX(posx)
                        end),
                    })
                    local action = cc.RepeatForever:create(sequence)
                    var:runAction(action)
                end
            end
            local moveDiff = 480
            local time = moveDiff/speedTbl[3]
            local bposx = emyNode:getPositionX()
            local bposy = emyNode:getPositionY()
            local sequence = transition.sequence({
                cc.CallFunc:create(function()
                    emyNode:setScale(1)
                    emyNode:setPosition(bposx, bposy)
                    emyNode:setRotation(0)
                    local ani = AnimationMgr.createAni(emyNode, PokemonInfo.getRandomPokemonRes(), 0, -40, "emy"..os.time())
                    ani:setScale(-TownMapMgr.DEFAULT_PET_SCALE, TownMapMgr.DEFAULT_PET_SCALE)
                    AnimationMgr.playAni(ani.res, "idle", true, ani.tag)
                    emyNode:performWithDelay(function()
                        AnimationMgr.removeGafObjectByTag(ani.res, ani.tag)
                        --when remove animation obj we need remove its texuture to avoid memory leak
                        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
                    end, time*2)
                    AnimationMgr.setSkin(ani.res, 0, ani.tag)
                end),
                cc.MoveBy:create(time, cc.p(-moveDiff, 0)),
                cc.CallFunc:create(function()
                    local rand = GetRandom.random(1, 2)
                    local scale = 0
                    local movePosy = GetRandom.random(220,300)
                    if rand==1 then
                        scale = 4
                        movePosy = -GetRandom.random(0,100)
                    end
                    transition.moveBy(emyNode, {time=time/3, x=moveDiff, y=movePosy})
                    transition.scaleTo(emyNode, {time=time/2, scale=scale})
                    transition.rotateTo(emyNode, {time=time/5, rotate=180})
                    
                    local aniNode = CSResourceMgr.getNodeByName(resNameB, "gbiani")
                    aniNode:setVisible(true)
                    aniNode:setOpacity(255)
                    aniNode:setScale(1)
                    aniNode:setPosition(500, 100)
                    transition.moveBy(aniNode, {time=time/2, y=400})
                    transition.fadeOut(aniNode, {time=time/2})
                    
                    GameAudio.playUISound("coinGet")
                end),
                cc.DelayTime:create(time),
            })
            local action = cc.RepeatForever:create(sequence)
            emyNode:runAction(action)
        end)
        
        local petNodeParent = CSResourceMgr.getNodeByName(resNameB, "petdb")
        local startPosx = 100
        local tmpPosxDiff = 100
        local explorePets = selPetObjIDs
        for var=1, #explorePets do
            table.insert(loadMapFunc, function()
                local petInfo = PokemonInfo.getPetInfoByObjID(explorePets[var])
                local petRes = PokemonInfo.getPokemonResByID(petInfo.pokeID)
                local petAni = AnimationMgr.createAni(petNodeParent, petRes, startPosx-(var-1)*tmpPosxDiff, -40, explorePets[var].."run")
                AnimationMgr.playAni(petAni.res, "walk", true, petAni.tag)
                AnimationMgr.setSkin(petAni.res, petInfo.skin, petAni.tag)
                petAni:setScale(0)
                transition.scaleTo(petAni, {time=0.2, scale=TownMapMgr.DEFAULT_PET_SCALE})
                table.insert(runingPetNode, petAni)
            end)
        end
    end
    if not isBagInited then
        local lineSize = math.ceil(CharInfo.get().explorepacketnum/PetExploreMgr.DEFAULT_PACKET_NUM)
        local lastNum = CharInfo.get().explorepacketnum%PetExploreMgr.DEFAULT_PACKET_NUM
        if lastNum==0 then
            lastNum = PetExploreMgr.DEFAULT_PACKET_NUM
        end
        for i=1, lineSize do
            local function itemFunc()
                local list = CSResourceMgr.getNodeByName(resNameC, "list")
                local panel = CSResourceMgr.getNodeByName(resNameC, "panel"):clone()
                panelTable[i] = panel
                list:pushBackCustomItem(panel)
                local loopNum = PetExploreMgr.DEFAULT_PACKET_NUM
                if i==lineSize then
                    loopNum = lastNum
                end
                for var=1, loopNum do
                    CSResourceMgr.seekNodeByName(panel, "db"..var):show()
                end
                panel:show()
                panel:setScale(1, 0)
                transition.scaleTo(panel, {scale = 1, time = 0.2})
            end
            table.insert(loadMapFunc, itemFunc)
        end
        table.insert(loadMapFunc, function()
            isBagInited = true
        end)
    end
    table.insert(loadMapFunc, function()
        PetExploreMgr.refreshDropInfo(id)
        PetExploreMgr.refreshGold()
        PetExploreMgr.refreshServerTime()
        PetExploreMgr.refreshAwards()
    end)
    UnblockLoader.load(loadMapFunc, "PetExploreMgr.show-loadMap")
end

function PetExploreMgr.hideRuningPet()
	for var=1, #runingPetNode do
        AnimationMgr.removeGafObjectByTag(runingPetNode[var].res, runingPetNode[var].tag)
    end
    runingPetNode = {}
end

function PetExploreMgr.refreshDropInfo(id)
    UnblockLoader.cancel("PetExploreMgr.refreshDropInfo")
    CSResourceMgr.removeList(resNameD, "droplist")
    local aVec = ExploreInfo.getExploreInfoByID(id).randomAwardIDs
    local rankSize = 2
    local funcTable = {}
    local panelVec = {}
    local itemIDs = {}
    for n=1, #aVec do
        local itemID = ExploreInfo.getExploreRandomAwardInfoByID(aVec[n]).itemID
        itemIDs[itemID] = true
    end
    local index = 0
    for key, var in pairs(itemIDs) do
        index = index+1
        local row = math.ceil(index/rankSize)
        local itemID = key
        local rank = index%rankSize
        if rank==0 then
            rank = rankSize
        end
        if rank==1 then
            table.insert(funcTable, function()
                local parent = CSResourceMgr.getNodeByName(resNameD, "example3"):clone()
                CSResourceMgr.getNodeByName(resNameD, "droplist"):pushBackCustomItem(parent)
                parent:show()
                parent:setScaleY(0)
                transition.scaleTo(parent, {scale=1, time=0.1})
                table.insert(panelVec, parent)
            end)
        end
        table.insert(funcTable, function()
            local iNode = ItemInfo.getItemIconById(itemID)
            iNode:scale(0.5)
            iNode:addTo(panelVec[row])
            local pSize = panelVec[row]:getContentSize()
            iNode:pos(pSize.width/rankSize/2*(rank*2-1), pSize.height/2)
            CSResourceMgr.clickEventBindingByNode(iNode, function()
                ItemInfoViewMgr.show({id = itemID}, false)
            end, 3)
        end)
    end
    UnblockLoader.load(funcTable, "PetExploreMgr.refreshDropInfo")
end

function PetExploreMgr.refreshAwards(boolBuyPacket)
    if not ExploreInfo.get().exploreID then
        return
    end
    local list = CSResourceMgr.getNodeByName(resNameC, "list")
    if not list then
        return 
    end
    PetExploreMgr.refreshBagNum()
    local items = ExploreInfo.get().events
    local startIdx = 1
    local endIdx = #items
    if curAwardSize>#items then
        startIdx = 1
        endIdx = CharInfo.get().explorepacketnum
        print("PetExploreMgr.refreshAwards 收取所有物品")
    elseif curAwardSize==#items then
        if boolBuyPacket then
            startIdx = CharInfo.get().explorepacketnum-1
            endIdx = CharInfo.get().explorepacketnum
            print("PetExploreMgr.refreshAwards 扩展背包")
        else
            print("PetExploreMgr.refreshAwards 背包栏没有发生变化")
            return
        end
    else
        startIdx = curAwardSize+1
        CSResourceMgr.playAllFrame(resNameC, false)
        print("PetExploreMgr.refreshAwards 获得新物品")
        GameAudio.playUISound("itemGet")
    end
    curAwardSize = #items
    
    local funcTable = {}
    for i=startIdx, endIdx do
        local row = math.ceil(i/PetExploreMgr.DEFAULT_PACKET_NUM)
        local rank = i%PetExploreMgr.DEFAULT_PACKET_NUM
        if rank==0 then
            rank = PetExploreMgr.DEFAULT_PACKET_NUM
        end
        if rank==1 and not panelTable[row] then
            table.insert(funcTable, function()
                local panel = CSResourceMgr.getNodeByName(resNameC, "panel"):clone()
                panelTable[row] = panel
                list:pushBackCustomItem(panel)
                panel:show()
                panel:setScale(1, 0)
                transition.scaleTo(panel, {scale = 1, time = 0.2})
            end)
        end

        local bagItemInfo = {}
        if items[i] then
        	bagItemInfo = {id=items[i].item, num=items[i].count}
        end
        local function itemFunc()
            local parent = nil
            local panel = panelTable[row]
            local egNode = CSResourceMgr.seekNodeByName(panel, "db"..rank)
            if bagItemInfo.id then
                if not awardsTable[i] then
                    egNode:setVisible(false)
                    awardsTable[i] = ItemInfo.getItemIconById(bagItemInfo.id, bagItemInfo.num)
                    awardsTable[i]:addTo(panel)
                    awardsTable[i]:pos(egNode:getPositionX(), egNode:getPositionY())
                    awardsTable[i]:performWithDelay(function()
                        CSResourceMgr.clickEventBindingByNode(awardsTable[i], function()
                            ItemInfoViewMgr.show({id = bagItemInfo.id, sum = bagItemInfo.num}, false)
                        end, 3)
                    end, 1)
                    transition.scaleTo(awardsTable[i], {scale = 0.85, time = 0.2})
                end
            else
                egNode:setVisible(true)
                if awardsTable[i] then
                	awardsTable[i]:removeFromParent(true)
                	awardsTable[i] = nil
                end
            end
        end
        table.insert(funcTable, itemFunc)
    end
    UnblockLoader.load(funcTable, "PetExploreMgr.refreshAwards")
end

function PetExploreMgr.refreshGold()
    local curLayer = CSResourceMgr.getCsbObj(resNameB)
    if curLayer then
        local gcoin = CSResourceMgr.getNodeByName(resNameB, "gnum_")
        gcoin:removeAllChildren()
        local gold = CharInfo.getGCash()
        local labelGold = CocosModuleMgr.createAtlasLabel(gold, "UI/Atlas/hompage18x14.png", 14, 18, "/", -1)
        labelGold:addTo(gcoin)
        labelGold:setPosition(0, 0)
    end
end

function PetExploreMgr.refreshServerTime()
    local eInfo = ExploreInfo.get()
    if not eInfo.exploreID then
        return
    end
    if CSResourceMgr.getCsbObj(resNameC) then
        timeLabel = CSResourceMgr.getNodeByName(resNameC, "time")
    else
        timeLabel = nil
    end
    if timeLabel then
        if #eInfo.events>=CharInfo.get().explorepacketnum then
            return
        end
        local processbar = CSResourceMgr.getNodeByName(resNameC, "progress")
        local timeInterval = ExploreInfo.getExploreInfoByID(eInfo.exploreID).randomAwardTime
        local function refresh(time)
            if CSResourceMgr.getCsbObj(resNameC) then
                if time<=0 then
                    CSResourceMgr.getCsbObj(resNameC):performWithDelay(function()
                        PetExploreMgr.refreshServerTime()
                    end, 1)
                    return
                end
                CocosModuleMgr.setTimeLabelCountDown(timeLabel, time, function()
                    PetExploreMgr.refreshServerTime()
                end, function(sec)
                    processbar:setPercent(sec*100/timeInterval)
                end)
            end
        end
        
        local second = eInfo.nextGetAwardTime-CharInfo.getServerTime()
        refresh(second)
        if second<=0 then
            if not isRequesting then
                NetInterface.send("GC_GetExploreData_Ack", function()
                    isRequesting = true
                    local ExploreSend = require("src.Net.Send.ExploreSend")
                    ExploreSend.sendCG_GetExploreData_Req()
                end, function()
                    isRequesting = false
                    PetExploreMgr.refreshAwards()
                    refresh(ExploreInfo.get().nextGetAwardTime-CharInfo.getServerTime())
                end, function(code)
                    TipsMgr.showError(nil, code)
                end)
            end
        end
        print("------refreshServerTime nextGetAwardTime", second, eInfo.nextGetAwardTime, CharInfo.getServerTime())
    end
end

return PetExploreMgr