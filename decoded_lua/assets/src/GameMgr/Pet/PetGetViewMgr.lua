local PetGetViewMgr = {}

local resName = ""

function PetGetViewMgr.Init()
    resName = "Pet/PetGetView.csb"
end

function PetGetViewMgr.hideUI()
    UnblockLoader.cancel("PetGetViewMgr")
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("PetGetViewMgr")
end

local function initStaticData()
    CSResourceMgr.setLabelString(resName, "txt_title", "petBook106", nil, {r=0,g=0,b=0,a=255,w=1})
end

function PetGetViewMgr.show(scene, petID)
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end
    UIStack.push("PetGetViewMgr",PetGetViewMgr.hideUI,false)
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)

        CSResourceMgr.clickEventBinding(resName, "close", function()
            PetGetViewMgr.hideUI()
        end)
        
        initStaticData()
        
        local list = CSResourceMgr.getNodeByName(resName,"list")
        list:removeAllItems()
        --获得途径
        local getwayInfo = ItemInfo.getItemGetWay(PokemonInfo.getPokemonInfoByID(petID).gainParam)
        local getwayStr = {"iteminfo18", "iteminfo19", "iteminfo20", "iteminfo21", "iteminfo22", "iteminfo24",
            "iteminfo25", "iteminfo26", "iteminfo34", "iteminfo27", "iteminfo35", "iteminfo49", "iteminfo50"}
        --print("#####PetGetViewMgr petID=",38000 + petID," getwayInfo=",sz_T2S(getwayInfo))
        for i=1, #getwayInfo do
            local node = CSResourceMgr.getNodeByName(resName,"btn"):clone()
            local icon =  CSResourceMgr.seekNodeByName(node, "icon")
            local gInfo = getwayInfo[i]
            icon:setScale(0.5)
            CSResourceMgr.setSpriteTextureByNode(icon, "Item/GetWay/"..gInfo.type..".png")
            CSResourceMgr.setButtonStringByNode(node, getwayStr[gInfo.type], {r=11,g=17,b=67,a=255,w=2})
            if gInfo.type==1 or gInfo.type==4 then
                if gInfo.param~=0 then
                    local tab = math.ceil(gInfo.param / 10000)
                    CSResourceMgr.setButtonStringByNode(node, "fbgetway"..gInfo.param, {r=11,g=17,b=67,a=255,w=2})
                    if not ItemInfoViewMgr.isStageOpen(gInfo.param, tab) then
                        CSResourceMgr.setButtonStringColorByNode(node, {r=87,g=87,b=87,a=255})
                    end
                end
            end
            if gInfo.type == 2 then
                local textShare = CocosModuleMgr.createStringWithFormat({getwayStr[gInfo.type], gInfo.param})
                CSResourceMgr.setButtonStringByNode(node, textShare, {r=11,g=17,b=67,a=255,w=2})
            end
            if gInfo.type==5 then
                if gInfo.param==1 then
                    CSResourceMgr.setButtonStringByNode(node, "iteminfo33", {r=11,g=17,b=67,a=255,w=2})
                elseif gInfo.param==2 then
                    CSResourceMgr.setButtonStringByNode(node, "iteminfo32", {r=11,g=17,b=67,a=255,w=2})
                end
            end
            node:setVisible(true)
            
            CSResourceMgr.buttonEventBindingByNode(node, function(sender)
                CSResourceMgr.setButtonStringColorByNode(node, {r=255,g=252,b=0,a=255})
            end, function(sender)
                if gInfo.type==1 or gInfo.type==4 then
                    if gInfo.param~=0 then
                        local tab = math.ceil(gInfo.param / 10000)
                        if not ItemInfoViewMgr.isStageOpen(gInfo.param, tab) then
                            StandardTipsMgr.show(1, "tips22")
                            CSResourceMgr.setButtonStringColorByNode(node, {r=87,g=87,b=87,a=255})
                            return
                        end
                    end
                end
                PetGetViewMgr.hideUI()
                if gInfo.type==1 then
                    if gInfo.param~=0 then
                        local adventureInfo = AdventureInfo.getAdventureInfoByID(gInfo.param)
                        local tab = math.ceil(gInfo.param / 10000)
                        WorldMapMgr.searchAdventureNode(gInfo.param,tab)
                    else
                        PetGetViewMgr.closeCurUI(function()
                            WorldMapMgr.searchAdventureNode(WorldMapMgr.curAID)
                        end)
                    end
                elseif gInfo.type==2 then
                    PetGetViewMgr.closeCurUI(function()
                        LostTowerMgr.sendCreateReq(function()
                            SceneMgr.replaceScene(SceneMgr.getRunningScene, "LostTowerScene")
                        end)
                    end)
                elseif gInfo.type==3 then
                    PetGetViewMgr.closeCurUI(function()
                        PetFormationMgr.show(scene)
                    end)
                elseif gInfo.type==4 then
                    if gInfo.param~=0 then
                        PetGetViewMgr.closeCurUI(function()
                            PetExploreMgr.request(scene, gInfo.param)
                        end)
                    else
                        local curExploreID = WorldMapMgr.curAID>=5 and WorldMapMgr.curAID or 5
                        PetGetViewMgr.closeCurUI(function()
                            PetExploreMgr.request(scene, curExploreID)
                        end)
                    end
                elseif gInfo.type==5 then
                    if gInfo.param == 0 then
                        TipsMgr.show(scene, "bag15")
                    elseif gInfo.param == 1 then
                        PetGetViewMgr.closeCurUI(function()
                            MapSeekerMgr.autoSeekPath("TownScene", "b7")
                        end)
                    elseif gInfo.param == 2 then
                        LtExchangeViewMgr.callLTShop()
                    end
                elseif gInfo.type==6 then
                    PetGetViewMgr.closeCurUI(function()
                        GachaViewMgr.show(scene)
                    end)
                elseif gInfo.type==7 then
                    PetGetViewMgr.closeCurUI(function()
                        CheckViewMgr.show(scene)
                    end)
                elseif gInfo.type==8 then
                    PetGetViewMgr.closeCurUI(function()
                        MissionListMgr.show(scene, 2)
                    end)
                elseif gInfo.type==9 then
                    PetGetViewMgr.closeCurUI(function()
                        MapSeekerMgr.autoSeekPath("TownScene", "b5",function()
                            AuctionMgrNew.request(SceneMgr.getRunningScene)
                        end)
                    end)
                elseif gInfo.type==10 then
                    PetGetViewMgr.closeCurUI(function()
                        MapSeekerMgr.autoSeekPath("TownScene", "b3",function()
                            LifeSkillSelViewMgr.request(SceneMgr.getRunningScene)
                        end)
                    end)
                elseif gInfo.type==11 then
                    PetGetViewMgr.closeCurUI(function()
                        MissionListMgr.show(scene, 3)
                    end)
                elseif gInfo.type==12 then
                    PetGetViewMgr.closeCurUI(function()
                        MapSeekerMgr.autoSeekPath("TownScene", "b8")
                    end)
                end
            end, nil, function(sender)
                if gInfo.type==1 or gInfo.type==4 then
                    if gInfo.param~=0 then
                        local tab = math.ceil(gInfo.param / 10000)
                        if not ItemInfoViewMgr.isStageOpen(gInfo.param, tab) then
                            CSResourceMgr.setButtonStringColorByNode(node, {r=87,g=87,b=87,a=255})
                        else
                            CSResourceMgr.setButtonStringColorByNode(node, {r=227,g=233,b=255,a=255})
                        end
                    else
                        CSResourceMgr.setButtonStringColorByNode(node, {r=227,g=233,b=255,a=255})
                    end
                else
                    CSResourceMgr.setButtonStringColorByNode(node, {r=227,g=233,b=255,a=255})
                end
            end)
            
            list:pushBackCustomItem(node)
        end
    end
    
    local function playCSB()
        local node = CSResourceMgr.getNodeByName(resName, "db")
        if node ~= nil then
            node:setVisible(true)
            CocosModuleMgr.showUIAnimation(node, "down")
        end
    end
    
    local funcTable = {loadCSB, playCSB}

    UnblockLoader.load(funcTable, "PetGetViewMgr")
end

function PetGetViewMgr.closeCurUI(callback)
    UIStack.closeAllUI()
    if callback then
        callback()
    end
end

return PetGetViewMgr