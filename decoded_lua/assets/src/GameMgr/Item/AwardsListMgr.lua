local AwardsListMgr = {}

AwardsListMgr.RANK_NUM = 5
AwardsListMgr.MAX_SHOW_NUM = 10

local resName = ""
local shineRes = ""
local aniRes = ""
local closeCallback = nil
local awardsNode = {}
local ccbiTag = 0
local isClosing = false

function AwardsListMgr.Init()
    resName = "Item/awardInfoView.csb"
    shineRes = "Spine/effects/UI_beibaodaojuGet1.png"
    aniRes = "Spine/effects/UI_beibaodaojuGet2.png"
    closeCallback = nil
    awardsNode = {}
    ccbiTag = 23333
    isClosing = false
end

---显示通用奖励列表
--@param scene node 场景
--@param awardsInfo table 奖励json字符串组
function AwardsListMgr.show(scene, awardsInfo)
    closeCallback = nil
    isClosing = false
    if type(awardsInfo)~="table" then
        print("AwardsListMgr.show error, params not table")
    	return
    end
    local AwardsVec = {}
    local tmpAwardsVec = {}
    local function addTmpAward(key, num, petskin)
        if key=="pet" then
            table.insert(AwardsVec, {key, num, petskin})
        else
            if tmpAwardsVec[key] then
                tmpAwardsVec[key] = tmpAwardsVec[key]+num
            else
                tmpAwardsVec[key] = num
            end
        end
    end
    local cjson = require("cjson")
    for key, var in pairs(awardsInfo) do
        if type(var)=="string" then
            print("awards str:", var)
            local j = cjson.decode(var)
            if j.elementType=="item" then
                addTmpAward(j.elementID, j.num)
            elseif j.elementType=="pet" or j.elementType=="equip" then
                addTmpAward(j.elementType, j.elementID)
            else
                addTmpAward(j.elementType, j.num)
            end
        elseif type(var)=="table" then
            if var[1] and var[2] then
                addTmpAward(var[1], var[2], var[3])
            end
        end
    end
    for key, var in pairs(tmpAwardsVec) do
        table.insert(AwardsVec, {key, var})
    end
    if #AwardsVec==0 then
        print("AwardsListMgr.show error, empty")
    	return
    end
    
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setFullScreen(resName)

        CSResourceMgr.clickEventBinding(resName, "ok", function()
            if isClosing then
            	return
            end
            isClosing = true
            local okBtn = CSResourceMgr.getNodeByName(resName, "ok")
            okBtn:setTouchEnabled(false)
            CSResourceMgr.setButtonEnabled(resName, "bg", false)
            AnimationMgr.getGafObj(shineRes):setVisible(false)
            local timeDiff = 0.3
            local aniGet = AnimationMgr.createAni(CSResourceMgr.getNodeByName(resName, "ani"), aniRes, 0, 0)
            aniGet:setScale(1.25)
            AnimationMgr.playAni(aniGet.res, "animation", false, aniGet.tag)
            AnimationMgr.setSpeedRate(aniGet.res, 2, aniGet.tag)
            for var=1, #awardsNode do
                transition.scaleTo(awardsNode[var], {scale = 0.8, time = timeDiff})
                transition.rotateTo(awardsNode[var], {rotate = 90, time = timeDiff})
                CSResourceMgr.seekNodeByName(awardsNode[var], "bigname"):setVisible(false)
                CSResourceMgr.seekNodeByName(awardsNode[var], "name"):setVisible(false)
            end
            aniGet:performWithDelay(function()
                local timeDur = 0.2
                for var=1, #awardsNode do
                    transition.scaleTo(awardsNode[var], {scale = 0, time = timeDur})
                    transition.rotateTo(awardsNode[var], {rotate = 180, time = timeDur})
                    local aniNode = CSResourceMgr.seekNodeByTag(awardsNode[var], ccbiTag)
                    if aniNode then
                        transition.scaleTo(aniNode, {scale = 10, time = timeDur})
                    end
                end
                aniGet:performWithDelay(function()
                    okBtn:setBright(false)
                end, timeDur/2)
                local panel = CSResourceMgr.getNodeByName(resName, "panel")
                transition.moveTo(panel, {x = okBtn:getPositionX(), y = okBtn:getPositionY(), time = timeDur})
                transition.scaleTo(panel, {scale = 0, time = timeDur})
                CSResourceMgr.playAllFrameWithCallback(resName, 1, function()
                    AwardsListMgr.hide()
                end)
            end, timeDiff)
        end, "", 1, "itemInbag")
        CSResourceMgr.clickEventBinding(resName, "bg", function()
            CSResourceMgr.callButtonFunc(resName, "ok")
        end, "", 1, "itemInbag")
        CSResourceMgr.setLabelColor(resName, "tips", {r=160,g=160,b=160,a=255})
        CSResourceMgr.setLabelString(resName, "tips", "tips31", "", {r=0,g=0,b=0,a=255}, nil, 500)
    end
    
    local function addAni()
        local aniBG = AnimationMgr.createAni(CSResourceMgr.getNodeByName(resName, "ani"), shineRes, 0, 0)
        aniBG:setScale(1.25)
        AnimationMgr.playAniWithCallback(aniBG.res, "animation", function()
            transition.fadeOut(aniBG, {time = 1})
        end, aniBG.tag, false)
    end
    
    local function playCSB()
        AwardsListMgr.reset(AwardsVec)
    end

    local funcTable = {loadCSB, addAni, playCSB}

    UnblockLoader.load(funcTable, "AwardsListMgr")
end

function AwardsListMgr.reset(awardsInfo)    
    local funcTable = {}
    local list = CSResourceMgr.getNodeByName(resName, "panel")
    list:removeAllChildren()
    awardsNode = {}
    local size = list:getContentSize()
    
    local loopNum = #awardsInfo
    if loopNum>AwardsListMgr.MAX_SHOW_NUM then
        loopNum = AwardsListMgr.MAX_SHOW_NUM
    end
    for i=1, loopNum do
        local row = math.ceil(i/AwardsListMgr.RANK_NUM)
        local rank = i%AwardsListMgr.RANK_NUM
        if rank==0 then
            rank = AwardsListMgr.RANK_NUM
        end
        local bagItemInfo = awardsInfo[i]
        table.insert(funcTable, function()
            local parent = nil
            if bagItemInfo[1]=="pet" then
                parent = CSResourceMgr.getNodeByName(resName, "examplep"):clone()
            else
                parent = CSResourceMgr.getNodeByName(resName, "example"):clone()
            end
            parent:addTo(list)
            table.insert(awardsNode, parent)
        end)
        local function itemFunc()
            local parent = awardsNode[i]
            if bagItemInfo[1]=="pet" then
                local petInfo = PokemonInfo.getPokemonInfoByID(bagItemInfo[2])
                local rare = CSResourceMgr.seekNodeByName(parent, "rare")
                CSResourceMgr.setSpriteTextureByNode(rare, PetEducationMgr.getRareIcon(petInfo.rarePoint))
                local diban = CSResourceMgr.seekNodeByName(parent, "button")
                local rareRes = PokemonInfo.getStagePics(nil, petInfo.elementAtt1, petInfo.rarePoint)
                CSResourceMgr.setButtonTextureByNode(diban, rareRes.p1, rareRes.p1, rareRes.p1)
                CSResourceMgr.clickEventBindingByNode(diban, function()
                    GachaViewMgr.playGetAPet(bagItemInfo[2], nil, nil, bagItemInfo[3] or 0)
                end)
                local attr = CSResourceMgr.seekNodeByName(parent, "attr")
                local attriinfo = tonumber(petInfo.elementAtt1)
                CSResourceMgr.setSpriteTextureByNode(attr, "Pet/AttriIcon/"..attriinfo..".png")
                local attrdb = CSResourceMgr.seekNodeByName(parent, "attrdb")
                CSResourceMgr.setSpriteTextureByNode(attrdb, rareRes.p2)
                local sprite = CSResourceMgr.seekNodeByName(parent, "icon")
                CSResourceMgr.setSpriteTextureByNode(sprite, PokemonInfo.getPokemonIconByID(bagItemInfo[2]))
                if loopNum==1 then
                    local nameLabel = CSResourceMgr.seekNodeByName(parent, "bigname")
                    nameLabel:enableOutline({r=0,g=0,b=0,a=255}, 2)
                    nameLabel:setTextColor(PokemonInfo.COLOR[petInfo.rarePoint])
                    CSResourceMgr.setLabelStringByNode(nameLabel, petInfo.name)
                else
                    local nameLabel = CSResourceMgr.seekNodeByName(parent, "name")
                    nameLabel:enableOutline({r=0,g=0,b=0,a=255}, 1)
                    nameLabel:setTextColor(PokemonInfo.COLOR[petInfo.rarePoint])
                    CSResourceMgr.setLabelStringByNode(nameLabel, petInfo.name, nil, nil, 100)
                end
            elseif bagItemInfo[1]=="equip" then
                local itemRes = PetEquipInfo.getEquipQualityBGImage(bagItemInfo[2])
                local info    = PetEquipInfo.getPetEquipInfoById(bagItemInfo[2])
                local diban   = CSResourceMgr.seekNodeByName(parent, "button")
                local icon    = display.newSprite(info.icon)
                diban:setScale(1.2,1.2)
                CSResourceMgr.setButtonTextureByNode(diban, itemRes, itemRes, itemRes)
                icon:addTo(diban)
                icon:setPosition(diban:getContentSize().width/2,diban:getContentSize().height/2)
                local nameLabel = CSResourceMgr.seekNodeByName(parent, "bigname")
                nameLabel:enableOutline({r=0,g=0,b=0,a=255}, 2)
                CSResourceMgr.setLabelStringByNode(nameLabel, info.name)
            else
                if not tonumber(bagItemInfo[1]) then
                    if bagItemInfo[1]=="g_cash" then
                        bagItemInfo[1] = 9998
                    elseif bagItemInfo[1]=="m_cash" then
                        bagItemInfo[1] = 9999
                    elseif bagItemInfo[1]=="exp" then
                        bagItemInfo[1] = 9997
                    elseif bagItemInfo[1]=="goldCoin" then
                        bagItemInfo[1] = 9996
                    elseif bagItemInfo[1]=="arenaScore" then
                        bagItemInfo[1] = 9995
                    end
                end
                local itemInfo = ItemInfo.getItemInfoById(bagItemInfo[1])
                local diban = CSResourceMgr.seekNodeByName(parent, "button")
                local button = ItemInfo.getItemIconById(bagItemInfo[1], bagItemInfo[2])
                --阿杜修改英文版显示
                if LuaSqlite.LANG_TYPE~= 1 then
                    CSResourceMgr.seekNodeByName(parent,"name"):setVisible(false)
                end
                button:addTo(diban)
                button:pos(0, 0)
                CSResourceMgr.buttonEventBindingByNode(button, function()
                    ItemInfoViewMgr.show({id = bagItemInfo[1],  sum = bagItemInfo[2], type = 2}, false)
                end, function()
                    ItemInfoViewMgr.hide()
                end, nil, function()
                    ItemInfoViewMgr.hide()
                end)
                --[[
                local label = CSResourceMgr.seekNodeByName(parent, "num")
                label:enableOutline({r=0,g=0,b=0,a=255}, 1)
                CSResourceMgr.setLabelStringByNode(label, bagItemInfo[2], nil, nil, 100)
                local dibanRes = ItemInfo.getItemRareBGImage(bagItemInfo[1])
                CSResourceMgr.setButtonTextureByNode(diban, dibanRes, dibanRes, dibanRes)
                CSResourceMgr.buttonEventBindingByNode(diban, function()
                    ItemInfoViewMgr.show({id = bagItemInfo[1],  sum = bagItemInfo[2], type = 2}, false)
                end, function()
                	ItemInfoViewMgr.hide()
                end, nil, function()
                    ItemInfoViewMgr.hide()
                end)
                local itype = ItemInfo.getItemType(bagItemInfo[1])
                local sprite = CSResourceMgr.seekNodeByName(parent, "icon")
                if itype==4 then
                    local petPieceInfo = ItemInfo.getPetPieceInfoById(bagItemInfo[1])
                    local icoPath = PokemonInfo.getPokemonIconByID(PokemonInfo.getGeneInfoByID(petPieceInfo.pokeID).petID)
                    CSResourceMgr.setSpriteTextureByNode(sprite, icoPath)
                    local icofra = CSResourceMgr.seekNodeByName(parent, "icofra")
                    icofra:setVisible(true)
                    sprite:setScale(0.7)
                else
                    CSResourceMgr.setSpriteTextureByNode(sprite, itemInfo.icon)
                end]]
                if loopNum==1 then
                    local nameLabel = CSResourceMgr.seekNodeByName(parent, "bigname")
                    nameLabel:enableOutline({r=0,g=0,b=0,a=255}, 2)
                    nameLabel:setTextColor(ItemInfo.COLOR[ItemInfo.getItemInfoById(bagItemInfo[1]).itemRare+1])
                    CSResourceMgr.setLabelStringByNode(nameLabel, itemInfo.name)
                else
                    local nameLabel = CSResourceMgr.seekNodeByName(parent, "name")
                    nameLabel:enableOutline({r=0,g=0,b=0,a=255}, 1)
                    nameLabel:setTextColor(ItemInfo.COLOR[ItemInfo.getItemInfoById(bagItemInfo[1]).itemRare+1])
                    CSResourceMgr.setLabelStringByNode(nameLabel, itemInfo.name, nil, nil, 100)
                end
            end            
            parent:setPosition(size.width/2, size.height/2)
            parent:setVisible(true)
            local diban = CSResourceMgr.seekNodeByName(parent,  "button")
            local iconScale = diban:getScale()
            local aniTime = 0.15
            diban:setScale(0, 0)
            diban:setRotation(180)
            transition.scaleTo(diban, {scale = iconScale, time = aniTime})
            transition.rotateTo(diban, {rotate = 360, time = aniTime})
            local rowSize = math.ceil(loopNum/AwardsListMgr.RANK_NUM)
            local rankSize = 1
            local posy = -size.height
            if rowSize==2 then
            	if row==1 then
            		posy = size.height*3/4
                    rankSize = AwardsListMgr.RANK_NUM
            	elseif row==2 then
            	    posy = size.height/4
                    rankSize = loopNum - AwardsListMgr.RANK_NUM
            	end
            else
                posy = size.height/2
                rankSize = loopNum
            end
            local posx = size.width/AwardsListMgr.RANK_NUM/2 + (rank-1)*size.width/AwardsListMgr.RANK_NUM + 
                (AwardsListMgr.RANK_NUM-rankSize)*size.width/AwardsListMgr.RANK_NUM/2
            transition.moveTo(parent, {x = posx, y = posy, time = aniTime})
            parent:setLocalZOrder(loopNum-i+1)
        end
        table.insert(funcTable, itemFunc)
        table.insert(funcTable, function()
            local parent = CSResourceMgr.seekNodeByName(awardsNode[i], "button")
            local posx = parent:getContentSize().width/2
            local posy = parent:getContentSize().height/2
            local frame = CSResourceMgr.createCCBI(parent, "texture/ui_dc_04a.ccbi", posx, posy)
            local effect = CSResourceMgr.createCCBI(parent, "texture/ui_dc_04b.ccbi", posx, posy)
            effect:setLocalZOrder(-1)
            effect:setTag(ccbiTag)
            if bagItemInfo[1]=="pet" then
            	frame:setScale(1.25)
                effect:setScale(1.25)
            else
                frame:setScale(1.5)
                effect:setScale(1.5)
            end
        end)
    end
    UnblockLoader.load(funcTable, "AwardsListMgr-reset", 0.01)
end

function AwardsListMgr.hide()
    if not CSResourceMgr.getCsbObj(resName) then
    	return
    end
    awardsNode = {}
    UnblockLoader.cancel("AwardsListMgr")
    UnblockLoader.cancel("AwardsListMgr-reset")
    AnimationMgr.removeGafObjectByTag(shineRes)
    AnimationMgr.removeGafObjectByTag(aniRes)
    CSResourceMgr.getNodeByName(resName, "panel"):removeAllChildren()
    CSResourceMgr.removeCSObjectByTag(resName)
    
    if closeCallback then
        closeCallback()
    	closeCallback = nil
    end
end

function AwardsListMgr.setCloseCallback(callback)
    closeCallback = callback
end

function AwardsListMgr.spClose()
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    if not isClosing then
        GameAudio.playUISound("itemInbag")
    end
    CSResourceMgr.callButtonFunc(resName, "ok")
end

return AwardsListMgr