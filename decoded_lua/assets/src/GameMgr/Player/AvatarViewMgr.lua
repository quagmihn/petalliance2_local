local AvatarViewMgr = {}

AvatarViewMgr.TAB_NUM = 6

local resName = ""
local resName1 = ""
local resNameItem = ""
local fashionTabel = {}
local setFashionVec = {}
local curTab = nil
local tempSel = nil
local itemNodes = {}
local tabTable = nil

local tabLabelVec = {
    "fashion0",
    "fashion1",
    "fashion2",
    "fashion3",
    "fashion4",
    "fashion17"
}

local tabTextureVec = {
    "Player/Avatar/tou_2.png",
    "Player/Avatar/shang_2.png",
    "Player/Avatar/xia_2.png",
    "Player/Avatar/bei_2.png",
    "Player/Avatar/wu_2.png",
    "Player/Avatar/face_2.png",
    "Player/Avatar/tou_1.png",
    "Player/Avatar/shang_1.png",
    "Player/Avatar/xia_1.png",
    "Player/Avatar/bei_1.png",
    "Player/Avatar/wu_1.png",
    "Player/Avatar/face_1.png"
}

function AvatarViewMgr.Init()
    print("AvatarViewMgr初始化")

    resName = "Player/Avatar/AvatarView.csb"
    resName1 = "Player/Avatar/AvatarView_2.csb"
    resNameItem = "Player/Avatar/CommonItem.csb"
    CSResourceMgr.createRes(nil, resNameItem, nil, true)
    fashionTabel = {}
    setFashionVec = {}
    curTab = 1
    tempSel = nil
    itemNodes = {}
    
    if not tabTable then
        tabTable = {}
        for i=1,AvatarViewMgr.TAB_NUM do
            tabTable[i] = {}
        end

        local vec = ItemInfo.getFashionItemInfoAllId()
        for k,v in pairs(vec) do
            if math.floor(v.id/1000) == 1 then
                table.insert(tabTable[1],v)
                tabTable[1] = AvatarViewMgr.sortAvatar(tabTable[1])
            elseif math.floor(v.id/1000) == 2 then
                table.insert(tabTable[2],v)
                tabTable[2] = AvatarViewMgr.sortAvatar(tabTable[2])
            elseif math.floor(v.id/1000) == 3 then
                table.insert(tabTable[3],v)
                tabTable[3] = AvatarViewMgr.sortAvatar(tabTable[3])
            elseif math.floor(v.id/1000) == 4 then
                table.insert(tabTable[4],v)
                tabTable[4] = AvatarViewMgr.sortAvatar(tabTable[4])
            elseif math.floor(v.id/1000) == 5 then
                table.insert(tabTable[5],v)
                tabTable[5] = AvatarViewMgr.sortAvatar(tabTable[5])
            else
                table.insert(tabTable[6],v)
                tabTable[6] = AvatarViewMgr.sortAvatar(tabTable[6])
            end
        end
    end
end

function AvatarViewMgr.hide()
    UnblockLoader.cancel("AvatarViewMgr.changeTab")
    itemNodes = {}
    local list = CSResourceMgr.getNodeByName(resName, "list")
    list:removeAllItems()
    PlayerAnimeMgr.removePlayerByTag(PlayerAnimeMgr.COMMON_UI_TAG_STRING,false)
    fashionTabel = {}
	CSResourceMgr.removeCSObjectByTag(resName1)
    CSResourceMgr.removeCSObjectByTag(resName)
    GameAudio.playUISound("retract")
    UIStack.pop("AvatarViewMgr")
end

function AvatarViewMgr.show(scene)
    if not NetInterface.isConnect then
        return
    end
    NetInterface.sendWithBlock("GC_GetFashions_Ack", function()
        local FashionSend = require("src.Net.Send.FashionSend")
        FashionSend.sendCG_GetFashions_Req()
    end, function()
        UIStack.push("AvatarViewMgr", AvatarViewMgr.hide, true)
        AvatarViewMgr.open(scene)
    end, function(code)
        TipsMgr.showError(scene, code)
    end)
end

function AvatarViewMgr.setFashionTabel(vec)
    fashionTabel = vec
end

function AvatarViewMgr.getFashionTabel()
    return fashionTabel
end

function AvatarViewMgr.open(scene) 
    setFashionVec = {}
    curTab = 1

    local function loadCSB()
        local curLayer1 = CSResourceMgr.createRes(scene, resName1)
        curLayer1:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName)
        CSResourceMgr.setFullScreen(resName1)
        CSResourceMgr.setRelativePosition(resName,320,480)
        CSResourceMgr.setRelativePosition(resName1,320,480)
        CocosModuleMgr.setEdgeDistance(curLayer, nil, nil, nil, 0, false)
        CocosModuleMgr.setEdgeDistance(curLayer1, nil, nil, 0, nil, false)

        CSResourceMgr.setLabelColor(resName1,"title",{r=80,g=61,b=35,a=255})
        CSResourceMgr.setLabelString(resName1,"title","fashion5","",{r=221,g=192,b=138,a=255})

        CSResourceMgr.setLabelString(resName1,"attrLB","fashion18")

        AvatarViewMgr.refreshAttr()

        CSResourceMgr.clickEventBinding(resName1, "closeBtn", function()
            AvatarViewMgr.hide()
        end)

        local spriteFrame = CSResourceMgr.getNodeByName(resName, "frame")
        spriteFrame:setLocalZOrder(2)

        local attrBG = CSResourceMgr.getNodeByName(resName, "attrBG")
        attrBG:setLocalZOrder(-1)

        --阿杜修改英文版显示
        if LuaSqlite.LANG_TYPE == 3 then
            for i=1,AvatarViewMgr.TAB_NUM do
                CSResourceMgr.getNodeByName(resName, "tabtext"..i):setVisible(false)
            end
            CSResourceMgr.getNodeByName(resName, "tou"):setPositionX(52)
            CSResourceMgr.getNodeByName(resName, "shang"):setPositionX(52)
            CSResourceMgr.getNodeByName(resName, "xia"):setPositionX(52)
            CSResourceMgr.getNodeByName(resName, "bei"):setPositionX(52)
            CSResourceMgr.getNodeByName(resName, "wu"):setPositionX(52)
            CSResourceMgr.getNodeByName(resName, "biao"):setPositionX(52)
        end

        local function setTabStatus(tabid,enable)
            local tabtext = nil
            local texture = nil
            if tabid == 1 then
                tabtext = CSResourceMgr.getNodeByName(resName, "tabtext1")
                texture = CSResourceMgr.getNodeByName(resName, "tou")
            elseif tabid == 2 then
                tabtext = CSResourceMgr.getNodeByName(resName, "tabtext2")
                texture = CSResourceMgr.getNodeByName(resName, "shang")
            elseif tabid == 3 then
                tabtext = CSResourceMgr.getNodeByName(resName, "tabtext3")
                texture = CSResourceMgr.getNodeByName(resName, "xia")
            elseif tabid == 4 then
                tabtext = CSResourceMgr.getNodeByName(resName, "tabtext4")
                texture = CSResourceMgr.getNodeByName(resName, "bei")
            elseif tabid == 5 then
                tabtext = CSResourceMgr.getNodeByName(resName, "tabtext5")
                texture = CSResourceMgr.getNodeByName(resName, "wu")
            else
                tabtext = CSResourceMgr.getNodeByName(resName, "tabtext6")
                texture = CSResourceMgr.getNodeByName(resName, "biao")
            end
            
            if enable then
                CSResourceMgr.setLabelColorByNode(tabtext, {r=255,g=255,b=255,a=255})
                CSResourceMgr.setLabelStringByNode(tabtext, tabLabelVec[tabid], {r=209,g=138,b=0,a=255})

                local filePath = tabTextureVec[tabid]
                CSResourceMgr.setSpriteTextureByNode(texture,filePath)
            else
                CSResourceMgr.setLabelColorByNode(tabtext, {r=82,g=82,b=82,a=255})
                CSResourceMgr.setLabelStringByNode(tabtext, tabLabelVec[tabid], {r=236,g=236,b=236,a=255})

                local filePath = tabTextureVec[tabid + 6]
                CSResourceMgr.setSpriteTextureByNode(texture,filePath)
            end
        end

        for k,v in pairs(fashionTabel.curFashion) do
            table.insert(setFashionVec,v)
        end
        for var=1, AvatarViewMgr.TAB_NUM do
            setTabStatus(var,false)
        end

        for var=1, AvatarViewMgr.TAB_NUM do
            if var == 1 then
                local spriteTab = CSResourceMgr.getNodeByName(resName, "tab1")
                spriteTab:setLocalZOrder(1)
                local posY = spriteTab:getPositionY()
                spriteTab:setPositionY(posY+3)
                spriteTab:setScale(1.2)
                setTabStatus(var,true)
            end
            local spriteTab = CSResourceMgr.getNodeByName(resName, "tab"..var)
            CSResourceMgr.clickEventBinding(resName, "tab"..var, function()
                GameAudio.playUISound("sheetClick")
                spriteTab:setLocalZOrder(1)
                local posY = spriteTab:getPositionY()
                spriteTab:setPositionY(posY+3)
                spriteTab:setScale(1.2)
                setTabStatus(var,true)
                if curTab ~= var then
                    local spriteTab = CSResourceMgr.getNodeByName(resName, "tab"..curTab)
                    spriteTab:setLocalZOrder(-1)
                    local posY = spriteTab:getPositionY()
                    spriteTab:setPositionY(posY-3)
                    spriteTab:setScale(1)
                    setTabStatus(curTab,false)
                end
                curTab = var
                AvatarViewMgr.changeTab(var)
            end)
        end
        AvatarViewMgr.changeTab(1)

        CSResourceMgr.setButtonString(resName, "saveBtn", "fashion6", "", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setButtonString(resName, "revertBtn", "fashion7", "", {r=0,g=0,b=0,a=255})

        CSResourceMgr.clickEventBinding(resName, "saveBtn", function()
            local isHas = 0
            for k,v in pairs(setFashionVec) do
                for k1,v1 in pairs(fashionTabel.bag) do
                    for k2,v2 in pairs(v1) do
                        if v == v2 then
                            isHas = isHas + 1
                        end
                    end
                end
            end

            local VecCount = 0
            for k,v in pairs(setFashionVec) do
                if v ~= 0 then
                    VecCount = VecCount + 1
                end
            end

            if isHas == VecCount then
                for i=1,6 do
                    if not setFashionVec[i] then
                        setFashionVec[i] = 0
                    end
                end
                NetInterface.sendWithBlock("GC_SetFashions_Ack", function()
                    local FashionSend = require("src.Net.Send.FashionSend")
                    FashionSend.sendCG_SetFashions_Req(setFashionVec)
                end, function()
                    GameAudio.playUISound("success")
                    CharInfo.set({curfashion = setFashionVec})
                    AvatarViewMgr.refreshUI()
                end, function(code)
                    TipsMgr.showError(scene, code)
                end)
            else
                StandardTipsMgr.show(1,"fashion15")
            end
        end)

        CSResourceMgr.clickEventBinding(resName, "revertBtn", function()
            PlayerAnimeMgr.setPlayerSkins(PlayerAnimeMgr.COMMON_UI_TAG_STRING, fashionTabel.curFashion)
            PlayerAnimeMgr.removePlayerByTag(PlayerAnimeMgr.COMMON_UI_TAG_STRING,false)
            AvatarViewMgr.open(SceneMgr.getRunningScene)
        end,nil,nil,"refresh")
    end
    
    local function playCSB()
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName1,"top"),"down")
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName,"bottom"),"up")
        
        local playerAniNode = PlayerAnimeMgr.createPlayer(CSResourceMgr.getNodeByName(resName1,"playerAnime"), {gender=CharInfo.getSex(), 
            skin=CharInfo.getCurfashion()},PlayerAnimeMgr.COMMON_UI_TAG_STRING)
        playerAniNode:setScale(1.5)
    end
    
    loadCSB() 
    playCSB()
end

function AvatarViewMgr.changeTab(tabid)
    UnblockLoader.cancel("AvatarViewMgr.changeTab")
    for var=1, AvatarViewMgr.TAB_NUM do
        CSResourceMgr.setButtonEnabled(resName, "tab"..var, true)
    end
    CSResourceMgr.setButtonEnabled(resName, "tab"..tabid, false)

    local list = CSResourceMgr.getNodeByName(resName, "list")
    list:removeAllItems()

    local curId = nil
    local funcTable = {}
    local statusVec = {}
    local statusVec1 = {}
    local statusVec2 = {}
    local statusVec3 = {}
    for k,v in pairs(tabTable[tabid]) do
        if v.isHide == 0 then
            for kk,vv in pairs(fashionTabel.curFashion) do
                if tabid == math.floor(vv/1000) then
                    curId = vv
                end
                if tabid == 6 then
                    if 0 == math.floor(vv/1000) then
                        curId = vv
                    end
                end
            end
            if v.id == curId then
                statusVec[k]=v
            else
                local kVec = {}
                local tempVec = {}
                for kk,vv in pairs(fashionTabel.bag) do
                    for k1,v1 in pairs(vv) do
                        if v.id == v1 then
                            statusVec1[k]=v
                            table.insert(kVec,k)
                        else
                            tempVec[k]=v
                        end
                    end
                end
                for k1,v1 in pairs(kVec) do
                    tempVec[v1]=nil
                end
                local fashionInfo = nil
                for k,v in pairs(tempVec) do
                    for k1,v1 in pairs(tabTable) do
                        for k2,v2 in pairs(v1) do
                            if v2.id == v.id then
                                fashionInfo = v2
                            end
                        end
                    end
                    if fashionInfo then
                        local num = 0
                        if tabid ~= 6 then
                            num = ItemInfo.getCharItemNum(tonumber("3"..fashionInfo.id))
                        else
                            num = ItemInfo.getCharItemNum(30000+tonumber(fashionInfo.id))
                        end
                        if num > 0 then
                            statusVec2[k]=v
                        else
                            statusVec3[k]=v
                        end
                    end
                end
            end
        end
    end
    local cloneNode = CSResourceMgr.getNodeByName(resNameItem, "diban")
    tempSel = nil
    for k,v in pairs(statusVec) do
        table.insert(funcTable, function()
            itemNodes[v.id] = cloneNode:clone()
            list:pushBackCustomItem(itemNodes[v.id])

            local attrLabel = CSResourceMgr.seekNodeByName(itemNodes[v.id], "attrLabel")
            if v.petAttributeType ~= 0 then
                local str = CocosModuleMgr.createStringWithFormat({"FashionEffectDesc"..v.petAttributeType, v.petAttributeValue})
                CSResourceMgr.setLabelStringByNode(attrLabel, str)
            end

            if v.suitEffect ~= 0 then
                local suitEffectInfo = ItemInfo.getFashionSuitEffectInfoById(v.suitEffect)
                CSResourceMgr.setLabelStringByNode(attrLabel, suitEffectInfo.summary)
            end

            local infoBtn = CSResourceMgr.seekNodeByName(itemNodes[v.id], "infoBtn")
            infoBtn:setVisible(false)

            local useBtn = CSResourceMgr.seekNodeByName(itemNodes[v.id], "useBtn")
            useBtn:setVisible(false)

            local sel = CSResourceMgr.seekNodeByName(itemNodes[v.id], "sel")
            sel:setVisible(false)

            local cover = CSResourceMgr.seekNodeByName(itemNodes[v.id], "cover")
            cover:setVisible(false)

            local number = CSResourceMgr.seekNodeByName(itemNodes[v.id], "number")
            CSResourceMgr.setLabelColorByNode(number, {r=215,g=224,b=225,a=255})
            CSResourceMgr.setLabelStringByNode(number, "No."..v.id,{r=117,g=121,b=122,a=255})

            local numberBG = CSResourceMgr.seekNodeByName(itemNodes[v.id], "numberBG")
            numberBG:setColor({r=117,g=121,b=122,a=255})

            local name = CSResourceMgr.seekNodeByName(itemNodes[v.id], "name")
            CSResourceMgr.setLabelStringByNode(name, v.name,{r=15,g=43,b=70,a=255})

            local nameBG = CSResourceMgr.seekNodeByName(itemNodes[v.id], "nameBG")
            nameBG:setColor({r=110,g=124,b=134,a=255})

            local icon = CSResourceMgr.seekNodeByName(itemNodes[v.id], "icon")
            local iconRes = v.filePath
            CSResourceMgr.setSpriteTextureByNode(icon, iconRes)
            icon:setScale(1.5)

            local status = CSResourceMgr.seekNodeByName(itemNodes[v.id], "status")
            local statusBG = CSResourceMgr.seekNodeByName(itemNodes[v.id], "statusBG")

            CSResourceMgr.clickEventBindingByNode(itemNodes[v.id], function()
                if tempSel then
                    tempSel:setVisible(false)
                end
                if tabid == 4 or tabid == 5 then
                    if setFashionVec[tabid] ~= v.id then
                        sel:setVisible(true)
                        tempSel = sel
                        setFashionVec[tabid] = v.id
                        PlayerAnimeMgr.setPlayerSkin(PlayerAnimeMgr.COMMON_UI_TAG_STRING, v.id)
                        GameAudio.playUISound("dressTryon")
                    else
                        setFashionVec[tabid] = nil
                        tempSel = nil
                        PlayerAnimeMgr.setPlayerSkins(PlayerAnimeMgr.COMMON_UI_TAG_STRING, setFashionVec)
                    end
                else
                    sel:setVisible(true)
                    tempSel = sel
                    setFashionVec[tabid] = v.id
                    PlayerAnimeMgr.setPlayerSkin(PlayerAnimeMgr.COMMON_UI_TAG_STRING, v.id)
                    GameAudio.playUISound("dressTryon")
                end
            end)
            tempSel = sel
            tempSel:setVisible(true)
            statusBG:setColor({r=254,g=217,b=91,a=255})
            CSResourceMgr.setLabelColorByNode(status, {r=69,g=253,b=5,a=255})
            CSResourceMgr.setLabelStringByNode(status, "fashion13",{r=87,g=71,b=15,a=255})
        end)
    end
    
    for k,v in pairs(statusVec1) do
        table.insert(funcTable, function()
            itemNodes[v.id] = cloneNode:clone()
            list:pushBackCustomItem(itemNodes[v.id])

            local attrLabel = CSResourceMgr.seekNodeByName(itemNodes[v.id], "attrLabel")
            if v.petAttributeType ~= 0 then
                local str = CocosModuleMgr.createStringWithFormat({"FashionEffectDesc"..v.petAttributeType, v.petAttributeValue})
                CSResourceMgr.setLabelStringByNode(attrLabel, str)
            end

            if v.suitEffect ~= 0 then
                local suitEffectInfo = ItemInfo.getFashionSuitEffectInfoById(v.suitEffect)
                CSResourceMgr.setLabelStringByNode(attrLabel, suitEffectInfo.summary)
            end

            local sel = CSResourceMgr.seekNodeByName(itemNodes[v.id], "sel")
            sel:setVisible(false)

            local infoBtn = CSResourceMgr.seekNodeByName(itemNodes[v.id], "infoBtn")
            infoBtn:setVisible(false)

            local useBtn = CSResourceMgr.seekNodeByName(itemNodes[v.id], "useBtn")
            useBtn:setVisible(false)

            local cover = CSResourceMgr.seekNodeByName(itemNodes[v.id], "cover")
            cover:setVisible(false)
            cover:setOpacity(130)
            cover:setColor({r=0,g=0,b=0,a=255})

            local number = CSResourceMgr.seekNodeByName(itemNodes[v.id], "number")
            CSResourceMgr.setLabelColorByNode(number, {r=215,g=224,b=225,a=255})
            CSResourceMgr.setLabelStringByNode(number, "No."..v.id,{r=117,g=121,b=122,a=255})

            local numberBG = CSResourceMgr.seekNodeByName(itemNodes[v.id], "numberBG")
            numberBG:setColor({r=117,g=121,b=122,a=255})

            local name = CSResourceMgr.seekNodeByName(itemNodes[v.id], "name")
            CSResourceMgr.setLabelStringByNode(name, v.name,{r=15,g=43,b=70,a=255})

            local nameBG = CSResourceMgr.seekNodeByName(itemNodes[v.id], "nameBG")
            nameBG:setColor({r=110,g=124,b=134,a=255})

            local icon = CSResourceMgr.seekNodeByName(itemNodes[v.id], "icon")
            local iconRes = v.filePath
            CSResourceMgr.setSpriteTextureByNode(icon, iconRes)
            icon:setScale(1.5)

            local status = CSResourceMgr.seekNodeByName(itemNodes[v.id], "status")
            CSResourceMgr.setLabelColorByNode(status, {r=5,g=221,b=253,a=255})
            CSResourceMgr.setLabelStringByNode(status, "fashion12",{r=6,g=65,b=99,a=255})

            local statusBG = CSResourceMgr.seekNodeByName(itemNodes[v.id], "statusBG")
            statusBG:setColor({r=149,g=219,b=199,a=255})

            CSResourceMgr.clickEventBindingByNode(itemNodes[v.id], function()
                if tempSel then
                    tempSel:setVisible(false)
                end
                if tabid == 4 or tabid == 5 then
                    if setFashionVec[tabid] ~= v.id then
                        sel:setVisible(true)
                        tempSel = sel
                        setFashionVec[tabid] = v.id
                        PlayerAnimeMgr.setPlayerSkin(PlayerAnimeMgr.COMMON_UI_TAG_STRING, v.id)
                        GameAudio.playUISound("dressTryon")
                    else
                        setFashionVec[tabid] = nil
                        tempSel = nil
                        PlayerAnimeMgr.setPlayerSkins(PlayerAnimeMgr.COMMON_UI_TAG_STRING, setFashionVec)
                    end
                else
                    sel:setVisible(true)
                    tempSel = sel
                    setFashionVec[tabid] = v.id
                    PlayerAnimeMgr.setPlayerSkin(PlayerAnimeMgr.COMMON_UI_TAG_STRING, v.id)
                    GameAudio.playUISound("dressTryon")
                end
            end)

            for k1,v1 in pairs(setFashionVec) do
                if v.id == v1 then
                    if tempSel then
                        tempSel:setVisible(false)
                    end
                    sel:setVisible(true)
                    tempSel = sel
                end
            end
        end)
    end

    for k,v in pairs(statusVec2) do
        table.insert(funcTable, function()
            itemNodes[v.id] = cloneNode:clone()
            list:pushBackCustomItem(itemNodes[v.id])

            local attrLabel = CSResourceMgr.seekNodeByName(itemNodes[v.id], "attrLabel")
            if v.petAttributeType ~= 0 then
                local str = CocosModuleMgr.createStringWithFormat({"FashionEffectDesc"..v.petAttributeType, v.petAttributeValue})
                CSResourceMgr.setLabelStringByNode(attrLabel, str)
            end

            if v.suitEffect ~= 0 then
                local suitEffectInfo = ItemInfo.getFashionSuitEffectInfoById(v.suitEffect)
                CSResourceMgr.setLabelStringByNode(attrLabel, suitEffectInfo.summary)
            end

            local sel = CSResourceMgr.seekNodeByName(itemNodes[v.id], "sel")
            sel:setVisible(false)

            local infoBtn = CSResourceMgr.seekNodeByName(itemNodes[v.id], "infoBtn")
            infoBtn:setVisible(false)

            local useBtn = CSResourceMgr.seekNodeByName(itemNodes[v.id], "useBtn")
            useBtn:setVisible(true)
            CSResourceMgr.setButtonStringByNode(useBtn, "fashion14", {r=0,g=0,b=0,a=255})

            local cover = CSResourceMgr.seekNodeByName(itemNodes[v.id], "cover")
            cover:setVisible(false)
            cover:setOpacity(130)
            cover:setColor({r=0,g=0,b=0,a=255})

            local number = CSResourceMgr.seekNodeByName(itemNodes[v.id], "number")
            CSResourceMgr.setLabelColorByNode(number, {r=215,g=224,b=225,a=255})
            CSResourceMgr.setLabelStringByNode(number, "No."..v.id,{r=117,g=121,b=122,a=255})

            local numberBG = CSResourceMgr.seekNodeByName(itemNodes[v.id], "numberBG")
            numberBG:setColor({r=117,g=121,b=122,a=255})

            local name = CSResourceMgr.seekNodeByName(itemNodes[v.id], "name")
            CSResourceMgr.setLabelStringByNode(name, v.name,{r=15,g=43,b=70,a=255})

            local nameBG = CSResourceMgr.seekNodeByName(itemNodes[v.id], "nameBG")
            nameBG:setColor({r=110,g=124,b=134,a=255})

            local icon = CSResourceMgr.seekNodeByName(itemNodes[v.id], "icon")
            local iconRes = v.filePath
            CSResourceMgr.setSpriteTextureByNode(icon, iconRes)
            icon:setScale(1.5)

            local status = CSResourceMgr.seekNodeByName(itemNodes[v.id], "status")
            local statusBG = CSResourceMgr.seekNodeByName(itemNodes[v.id], "statusBG")
            status:setVisible(false)
            statusBG:setVisible(false)

            local fashionInfo = nil
            for k1,v1 in pairs(tabTable) do
                for k2,v2 in pairs(v1) do
                    if v2.id == v.id then
                        fashionInfo = v2
                    end
                end
            end

            -- local effAni = AnimationMgr.createAni(infoBtn, "Spine/effects/UI_shizhuangtishi.png",
            --     infoBtn:getContentSize().width/2, infoBtn:getContentSize().height/2, v.id)
            -- AnimationMgr.playAni(effAni.res, "animation", true, effAni.tag)
            
            CSResourceMgr.clickEventBindingByNode(useBtn, function()
                GameAudio.playUISound("ok")
                if tabid ~= 6 then
                    ItemInfoViewMgr.show({id = tonumber("3"..fashionInfo.id)}, true)
                else
                    ItemInfoViewMgr.show({id = 30000+tonumber(fashionInfo.id)}, true)
                end
            end)

            CSResourceMgr.clickEventBindingByNode(itemNodes[v.id], function()
                if tempSel then
                    tempSel:setVisible(false)
                end
                if tabid == 4 or tabid == 5 then
                    if setFashionVec[tabid] ~= v.id then
                        sel:setVisible(true)
                        tempSel = sel
                        setFashionVec[tabid] = v.id
                        PlayerAnimeMgr.setPlayerSkin(PlayerAnimeMgr.COMMON_UI_TAG_STRING, v.id)
                        GameAudio.playUISound("dressTryon")
                    else
                        setFashionVec[tabid] = nil
                        tempSel = nil
                        PlayerAnimeMgr.setPlayerSkins(PlayerAnimeMgr.COMMON_UI_TAG_STRING, setFashionVec)
                    end
                else
                    sel:setVisible(true)
                    tempSel = sel
                    setFashionVec[tabid] = v.id
                    PlayerAnimeMgr.setPlayerSkin(PlayerAnimeMgr.COMMON_UI_TAG_STRING, v.id)
                    GameAudio.playUISound("dressTryon")
                end
            end)

            for k1,v1 in pairs(setFashionVec) do
                if v.id == v1 then
                    if tempSel then
                        tempSel:setVisible(false)
                    end
                    sel:setVisible(true)
                    tempSel = sel
                end
            end
        end)
    end

    for k,v in pairs(statusVec3) do
        table.insert(funcTable, function()
            itemNodes[v.id] = cloneNode:clone()
            list:pushBackCustomItem(itemNodes[v.id])

            local attrLabel = CSResourceMgr.seekNodeByName(itemNodes[v.id], "attrLabel")
            if v.petAttributeType ~= 0 then
                local str = CocosModuleMgr.createStringWithFormat({"FashionEffectDesc"..v.petAttributeType, v.petAttributeValue})
                CSResourceMgr.setLabelStringByNode(attrLabel, str)
            end

            if v.suitEffect ~= 0 then
                local suitEffectInfo = ItemInfo.getFashionSuitEffectInfoById(v.suitEffect)
                CSResourceMgr.setLabelStringByNode(attrLabel, suitEffectInfo.summary)
            end

            local sel = CSResourceMgr.seekNodeByName(itemNodes[v.id], "sel")
            sel:setVisible(false)

            local infoBtn = CSResourceMgr.seekNodeByName(itemNodes[v.id], "infoBtn")
            infoBtn:setVisible(true)

            local useBtn = CSResourceMgr.seekNodeByName(itemNodes[v.id], "useBtn")
            useBtn:setVisible(false)

            local cover = CSResourceMgr.seekNodeByName(itemNodes[v.id], "cover")
            cover:setVisible(true)
            cover:setOpacity(130)
            cover:setColor({r=0,g=0,b=0,a=255})

            local number = CSResourceMgr.seekNodeByName(itemNodes[v.id], "number")
            CSResourceMgr.setLabelColorByNode(number, {r=215,g=224,b=225,a=255})
            CSResourceMgr.setLabelStringByNode(number, "No."..v.id,{r=117,g=121,b=122,a=255})

            local numberBG = CSResourceMgr.seekNodeByName(itemNodes[v.id], "numberBG")
            numberBG:setColor({r=117,g=121,b=122,a=255})

            local name = CSResourceMgr.seekNodeByName(itemNodes[v.id], "name")
            CSResourceMgr.setLabelStringByNode(name, v.name,{r=15,g=43,b=70,a=255})

            local nameBG = CSResourceMgr.seekNodeByName(itemNodes[v.id], "nameBG")
            nameBG:setColor({r=110,g=124,b=134,a=255})

            local icon = CSResourceMgr.seekNodeByName(itemNodes[v.id], "icon")
            local iconRes = v.filePath
            CSResourceMgr.setSpriteTextureByNode(icon, iconRes)
            icon:setScale(1.5)

            local status = CSResourceMgr.seekNodeByName(itemNodes[v.id], "status")
            CSResourceMgr.setLabelColorByNode(status, {r=255,g=255,b=255,a=255})
            CSResourceMgr.setLabelStringByNode(status, "fashion11",{r=90,g=90,b=90,a=255})

            local statusBG = CSResourceMgr.seekNodeByName(itemNodes[v.id], "statusBG")
            statusBG:setColor({r=163,g=174,b=179,a=255})

            local fashionInfo = nil
            for k1,v1 in pairs(tabTable) do
                for k2,v2 in pairs(v1) do
                    if v2.id == v.id then
                        fashionInfo = v2
                    end
                end
            end
            CSResourceMgr.clickEventBindingByNode(infoBtn, function()
                if tabid ~= 6 then
                    ItemInfoViewMgr.show({id = tonumber("3"..fashionInfo.id)}, false)
                else
                    ItemInfoViewMgr.show({id = 30000+tonumber(fashionInfo.id)}, false)
                end
            end)

            CSResourceMgr.clickEventBindingByNode(itemNodes[v.id], function()
                if tempSel then
                    tempSel:setVisible(false)
                end
                if tabid == 4 or tabid == 5 then
                    if setFashionVec[tabid] ~= v.id then
                        sel:setVisible(true)
                        tempSel = sel
                        setFashionVec[tabid] = v.id
                        PlayerAnimeMgr.setPlayerSkin(PlayerAnimeMgr.COMMON_UI_TAG_STRING, v.id)
                        GameAudio.playUISound("dressTryon")
                    else
                        setFashionVec[tabid] = nil
                        tempSel = nil
                        PlayerAnimeMgr.setPlayerSkins(PlayerAnimeMgr.COMMON_UI_TAG_STRING, setFashionVec)
                    end
                else
                    sel:setVisible(true)
                    tempSel = sel
                    setFashionVec[tabid] = v.id
                    PlayerAnimeMgr.setPlayerSkin(PlayerAnimeMgr.COMMON_UI_TAG_STRING, v.id)
                    GameAudio.playUISound("dressTryon")
                end
            end)

            for k1,v1 in pairs(setFashionVec) do
                if v.id == v1 then
                    if tempSel then
                        tempSel:setVisible(false)
                    end
                    sel:setVisible(true)
                    tempSel = sel
                end
            end
        end)
    end
    UnblockLoader.load(funcTable, "AvatarViewMgr.changeTab")
end

function AvatarViewMgr.refreshUI()
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    NetInterface.sendWithBlock("GC_GetFashions_Ack", function()
        local FashionSend = require("src.Net.Send.FashionSend")
        FashionSend.sendCG_GetFashions_Req()
    end, function()
        AvatarViewMgr.changeTab(curTab)
        AvatarViewMgr.refreshAttr()
    end, function(code)
        TipsMgr.showError(nil, code)
    end)
end

function AvatarViewMgr.checkTable(table)
    local count = 0
    for k,v in pairs(table) do
        if v ~= 0 then
            count = count + 1
        end
    end
    return count
end

function AvatarViewMgr.refreshAttr()
    -- local globalInfo = {SystemInfo.getGlobalConfigAddInfoByID(44).values[1],SystemInfo.getGlobalConfigAddInfoByID(45).values[1],SystemInfo.getGlobalConfigAddInfoByID(46).values[1]}
    -- globalInfo[2] = globalInfo[2] - globalInfo[1]
    -- globalInfo[3] = globalInfo[3] - globalInfo[2] - globalInfo[1]
    -- for i=1,3 do
    --     CSResourceMgr.setLabelColor(resName,"attrLabel"..i,{r=255,g=255,b=255,a=255})
    --     CSResourceMgr.setLabelString(resName,"attrLabel"..i,CocosModuleMgr.createStringWithFormat({"fashion8", i+2}))

    --     CSResourceMgr.setLabelColor(resName,"attr"..i,{r=112,g=110,b=110,a=255})
    --     CSResourceMgr.setLabelString(resName,"attr"..i,CocosModuleMgr.createStringWithFormat({"fashion9", globalInfo[i]}))
    --     if i > 1 then
    --         CSResourceMgr.setLabelString(resName,"attr"..i,CocosModuleMgr.createStringWithFormat({"fashion10", globalInfo[i]}))
    --     end
    -- end

    -- local count = AvatarViewMgr.checkTable(fashionTabel.curFashion)

    -- if count == 3 then
    --     CSResourceMgr.setLabelColor(resName,"attr1",{r=255,g=252,b=0,a=255})
    --     CSResourceMgr.setLabelString(resName,"attr1",CocosModuleMgr.createStringWithFormat({"fashion9", globalInfo[1]}))
    -- elseif count == 4 then
    --     for i=1,2 do
    --         CSResourceMgr.setLabelColor(resName,"attr"..i,{r=255,g=252,b=0,a=255})
    --         CSResourceMgr.setLabelString(resName,"attr"..i,CocosModuleMgr.createStringWithFormat({"fashion9", globalInfo[i]}))
    --         if i > 1 then
    --             CSResourceMgr.setLabelString(resName,"attr"..i,CocosModuleMgr.createStringWithFormat({"fashion10", globalInfo[i]}))
    --         end
    --     end
    -- elseif count == 5 then
    --     for i=1,3 do
    --         CSResourceMgr.setLabelColor(resName,"attr"..i,{r=255,g=252,b=0,a=255})
    --         CSResourceMgr.setLabelString(resName,"attr"..i,CocosModuleMgr.createStringWithFormat({"fashion9", globalInfo[i]}))
    --         if i > 1 then
    --             CSResourceMgr.setLabelString(resName,"attr"..i,CocosModuleMgr.createStringWithFormat({"fashion10", globalInfo[i]}))
    --         end
    --     end
    -- end
    local attrDB = CSResourceMgr.getNodeByName(resName1, "attrDB")
    local attr1 = CSResourceMgr.getNodeByName(resName1, "attr1")
    local attr2 = CSResourceMgr.getNodeByName(resName1, "attr2")
    local index = 0
    local suitTable = {0,0,0}
    local suitInfoTable = {nil,nil,nil}

    local isShow = {false,false}
    for k,v in pairs(fashionTabel.curFashion) do
        if v ~= 0 then
            local fashionInfo = ItemInfo.getFashionItemInfoById(v)
            if fashionInfo then
                if fashionInfo.petAttributeType ~= 0 then
                    index = index + 1
                    local str = CocosModuleMgr.createStringWithFormat({"FashionEffectDesc"..fashionInfo.petAttributeType, 
                        fashionInfo.petAttributeValue})
                    CSResourceMgr.setLabelString(resName1, "attr"..index, str)
                    if math.floor(fashionInfo.id/1000) == 4 then
                        isShow[1] = true
                    elseif math.floor(fashionInfo.id/1000) == 5 then
                        isShow[2] = true
                    end
                end

                if fashionInfo.suitEffect ~= 0 then
                    suitInfoTable[math.floor(fashionInfo.id/1000)] = ItemInfo.getFashionSuitEffectInfoById(fashionInfo.suitEffect)
                    suitTable[math.floor(fashionInfo.id/1000)] = fashionInfo.suitEffect
                end
            end
        end
    end
    if index == 0 then
        attr1:setVisible(false)
        attr2:setVisible(false)
        attrDB:setContentSize(150,70)
    elseif index == 1 then
        attr1:setVisible(true)
        attr2:setVisible(false)
        attrDB:setContentSize(150,70)
    elseif index == 2 then
        attr1:setVisible(true)
        attr2:setVisible(true)
        attrDB:setContentSize(150,100)
    end
    CSResourceMgr.getNodeByName(resName1, "bei"):setVisible(isShow[1])
    CSResourceMgr.getNodeByName(resName1, "wu"):setVisible(isShow[2])

    for var=1,3 do
        CSResourceMgr.getNodeByName(resName1, "tou"..var):setVisible(false)
        CSResourceMgr.getNodeByName(resName1, "shang"..var):setVisible(false)
        CSResourceMgr.getNodeByName(resName1, "xia"..var):setVisible(false)
        CSResourceMgr.getNodeByName(resName1, "efxNode"..var):setVisible(false)
        CSResourceMgr.setLabelString(resName1,"efx"..var, " ")
    end

    if suitTable[1] == suitTable[2] then
        if suitTable[1] == suitTable[3] then
            -- 123
            if suitTable[1] ~= 0 then
                CSResourceMgr.getNodeByName(resName1, "tou1"):setVisible(true)
                CSResourceMgr.getNodeByName(resName1, "shang1"):setVisible(true)
                CSResourceMgr.getNodeByName(resName1, "xia1"):setVisible(true)
                CSResourceMgr.getNodeByName(resName1, "efxNode1"):setVisible(true)

                local str1 = CocosModuleMgr.createStringWithFormat({"suit1", "3"})
                local str2 = CocosModuleMgr.createStringWithFormat({suitInfoTable[1].des, suitInfoTable[1].effectValues[3]})
                CSResourceMgr.setLabelString(resName1,"efx1", str1..str2)

                CSResourceMgr.setLabelString(resName1,"efxLB1", suitInfoTable[1].name)
            end
        else
            -- 12\3
            if suitTable[1] ~= 0 then
                if suitTable[3] ~= 0 then
                    CSResourceMgr.getNodeByName(resName1, "tou1"):setVisible(true)
                    CSResourceMgr.getNodeByName(resName1, "shang1"):setVisible(true)
                    CSResourceMgr.getNodeByName(resName1, "xia2"):setVisible(true)
                    CSResourceMgr.getNodeByName(resName1, "efxNode1"):setVisible(true)
                    CSResourceMgr.getNodeByName(resName1, "efxNode2"):setVisible(true)

                    local str1 = CocosModuleMgr.createStringWithFormat({"suit1", "2"})
                    local str2 = CocosModuleMgr.createStringWithFormat({suitInfoTable[1].des, suitInfoTable[1].effectValues[2]})
                    CSResourceMgr.setLabelString(resName1,"efx1", str1..str2)

                    str1 = CocosModuleMgr.createStringWithFormat({"suit1", "1"})
                    str2 = CocosModuleMgr.createStringWithFormat({suitInfoTable[3].des, suitInfoTable[3].effectValues[1]})
                    CSResourceMgr.setLabelString(resName1,"efx2", str1..str2)

                    CSResourceMgr.setLabelString(resName1,"efxLB1", suitInfoTable[1].name)
                    CSResourceMgr.setLabelString(resName1,"efxLB2", suitInfoTable[3].name)
                else
                    CSResourceMgr.getNodeByName(resName1, "tou1"):setVisible(true)
                    CSResourceMgr.getNodeByName(resName1, "shang1"):setVisible(true)
                    CSResourceMgr.getNodeByName(resName1, "efxNode1"):setVisible(true)

                    local str1 = CocosModuleMgr.createStringWithFormat({"suit1", "2"})
                    local str2 = CocosModuleMgr.createStringWithFormat({suitInfoTable[1].des, suitInfoTable[1].effectValues[2]})
                    CSResourceMgr.setLabelString(resName1,"efx1", str1..str2)

                    CSResourceMgr.setLabelString(resName1,"efxLB1", suitInfoTable[1].name)
                end
            else
                CSResourceMgr.getNodeByName(resName1, "xia1"):setVisible(true)
                CSResourceMgr.getNodeByName(resName1, "efxNode1"):setVisible(true)

                local str1 = CocosModuleMgr.createStringWithFormat({"suit1", "1"})
                local str2 = CocosModuleMgr.createStringWithFormat({suitInfoTable[3].des, suitInfoTable[3].effectValues[1]})
                CSResourceMgr.setLabelString(resName1,"efx1", str1..str2)

                CSResourceMgr.setLabelString(resName1,"efxLB1", suitInfoTable[3].name)
            end
        end
    else
        if suitTable[1] == suitTable[3] then
            -- 13\2
            if suitTable[1] ~= 0 then
                if suitTable[2] ~= 0 then
                    CSResourceMgr.getNodeByName(resName1, "tou1"):setVisible(true)
                    CSResourceMgr.getNodeByName(resName1, "shang2"):setVisible(true)
                    CSResourceMgr.getNodeByName(resName1, "xia1"):setVisible(true)
                    CSResourceMgr.getNodeByName(resName1, "efxNode1"):setVisible(true)
                    CSResourceMgr.getNodeByName(resName1, "efxNode2"):setVisible(true)

                    local str1 = CocosModuleMgr.createStringWithFormat({"suit1", "2"})
                    local str2 = CocosModuleMgr.createStringWithFormat({suitInfoTable[1].des, suitInfoTable[1].effectValues[2]})
                    CSResourceMgr.setLabelString(resName1,"efx1", str1..str2)

                    str1 = CocosModuleMgr.createStringWithFormat({"suit1", "1"})
                    str2 = CocosModuleMgr.createStringWithFormat({suitInfoTable[2].des, suitInfoTable[2].effectValues[1]})
                    CSResourceMgr.setLabelString(resName1,"efx2", str1..str2)

                    CSResourceMgr.setLabelString(resName1,"efxLB1", suitInfoTable[1].name)
                    CSResourceMgr.setLabelString(resName1,"efxLB2", suitInfoTable[2].name)
                else
                    CSResourceMgr.getNodeByName(resName1, "tou1"):setVisible(true)
                    CSResourceMgr.getNodeByName(resName1, "xia1"):setVisible(true)
                    CSResourceMgr.getNodeByName(resName1, "efxNode1"):setVisible(true)

                    local str1 = CocosModuleMgr.createStringWithFormat({"suit1", "2"})
                    local str2 = CocosModuleMgr.createStringWithFormat({suitInfoTable[1].des, suitInfoTable[1].effectValues[2]})
                    CSResourceMgr.setLabelString(resName1,"efx1", str1..str2)

                    CSResourceMgr.setLabelString(resName1,"efxLB1", suitInfoTable[1].name)
                end
            else
                CSResourceMgr.getNodeByName(resName1, "shang1"):setVisible(true)
                CSResourceMgr.getNodeByName(resName1, "efxNode1"):setVisible(true)

                local str1 = CocosModuleMgr.createStringWithFormat({"suit1", "1"})
                local str2 = CocosModuleMgr.createStringWithFormat({suitInfoTable[2].des, suitInfoTable[2].effectValues[1]})
                CSResourceMgr.setLabelString(resName1,"efx1", str1..str2)

                CSResourceMgr.setLabelString(resName1,"efxLB1", suitInfoTable[2].name)
            end
        else
            if suitTable[2] == suitTable[3] then
                if suitTable[2] ~= 0 then
                -- 1\23
                    if suitTable[1] ~= 0 then
                        CSResourceMgr.getNodeByName(resName1, "tou1"):setVisible(true)
                        CSResourceMgr.getNodeByName(resName1, "shang2"):setVisible(true)
                        CSResourceMgr.getNodeByName(resName1, "xia2"):setVisible(true)
                        CSResourceMgr.getNodeByName(resName1, "efxNode1"):setVisible(true)
                        CSResourceMgr.getNodeByName(resName1, "efxNode2"):setVisible(true)

                        local str1 = CocosModuleMgr.createStringWithFormat({"suit1", "1"})
                        local str2 = CocosModuleMgr.createStringWithFormat({suitInfoTable[1].des, suitInfoTable[1].effectValues[1]})
                        CSResourceMgr.setLabelString(resName1,"efx1", str1..str2)

                        str1 = CocosModuleMgr.createStringWithFormat({"suit1", "2"})
                        str2 = CocosModuleMgr.createStringWithFormat({suitInfoTable[2].des, suitInfoTable[2].effectValues[2]})
                        CSResourceMgr.setLabelString(resName1,"efx2", str1..str2)

                        CSResourceMgr.setLabelString(resName1,"efxLB1", suitInfoTable[1].name)
                        CSResourceMgr.setLabelString(resName1,"efxLB2", suitInfoTable[2].name)
                    else
                        CSResourceMgr.getNodeByName(resName1, "shang1"):setVisible(true)
                        CSResourceMgr.getNodeByName(resName1, "xia1"):setVisible(true)
                        CSResourceMgr.getNodeByName(resName1, "efxNode1"):setVisible(true)

                        local str1 = CocosModuleMgr.createStringWithFormat({"suit1", "2"})
                        local str2 = CocosModuleMgr.createStringWithFormat({suitInfoTable[2].des, suitInfoTable[2].effectValues[2]})
                        CSResourceMgr.setLabelString(resName1,"efx1", str1..str2)

                        CSResourceMgr.setLabelString(resName1,"efxLB1", suitInfoTable[2].name)
                    end
                else
                    CSResourceMgr.getNodeByName(resName1, "tou1"):setVisible(true)
                    CSResourceMgr.getNodeByName(resName1, "efxNode1"):setVisible(true)

                    local str1 = CocosModuleMgr.createStringWithFormat({"suit1", "1"})
                    local str2 = CocosModuleMgr.createStringWithFormat({suitInfoTable[1].des, suitInfoTable[1].effectValues[1]})
                    CSResourceMgr.setLabelString(resName1,"efx1", str1..str2)

                    CSResourceMgr.setLabelString(resName1,"efxLB1", suitInfoTable[1].name)
                end
            else
                -- 1\2\3
                if suitTable[1] ~= 0 and suitTable[2] ~= 0 and suitTable[3] ~= 0 then
                    CSResourceMgr.getNodeByName(resName1, "tou1"):setVisible(true)
                    CSResourceMgr.getNodeByName(resName1, "shang2"):setVisible(true)
                    CSResourceMgr.getNodeByName(resName1, "xia3"):setVisible(true)
                    CSResourceMgr.getNodeByName(resName1, "efxNode1"):setVisible(true)
                    CSResourceMgr.getNodeByName(resName1, "efxNode2"):setVisible(true)
                    CSResourceMgr.getNodeByName(resName1, "efxNode3"):setVisible(true)

                    local str1 = CocosModuleMgr.createStringWithFormat({"suit1", "1"})
                    local str2 = CocosModuleMgr.createStringWithFormat({suitInfoTable[1].des, suitInfoTable[1].effectValues[1]})
                    CSResourceMgr.setLabelString(resName1,"efx1", str1..str2)

                    str2 = CocosModuleMgr.createStringWithFormat({suitInfoTable[2].des, suitInfoTable[2].effectValues[1]})
                    CSResourceMgr.setLabelString(resName1,"efx2", str1..str2)

                    str2 = CocosModuleMgr.createStringWithFormat({suitInfoTable[3].des, suitInfoTable[3].effectValues[1]})
                    CSResourceMgr.setLabelString(resName1,"efx3", str1..str2)

                    CSResourceMgr.setLabelString(resName1,"efxLB1", suitInfoTable[1].name)
                    CSResourceMgr.setLabelString(resName1,"efxLB2", suitInfoTable[2].name)
                    CSResourceMgr.setLabelString(resName1,"efxLB3", suitInfoTable[3].name)
                else
                    if suitTable[1] == 0 then
                        CSResourceMgr.getNodeByName(resName1, "shang1"):setVisible(true)
                        CSResourceMgr.getNodeByName(resName1, "xia2"):setVisible(true)
                        CSResourceMgr.getNodeByName(resName1, "efxNode1"):setVisible(true)
                        CSResourceMgr.getNodeByName(resName1, "efxNode2"):setVisible(true)

                        local str1 = CocosModuleMgr.createStringWithFormat({"suit1", "1"})
                        local str2 = CocosModuleMgr.createStringWithFormat({suitInfoTable[2].des, suitInfoTable[2].effectValues[1]})
                        CSResourceMgr.setLabelString(resName1,"efx1", str1..str2)

                        str2 = CocosModuleMgr.createStringWithFormat({suitInfoTable[3].des, suitInfoTable[3].effectValues[1]})
                        CSResourceMgr.setLabelString(resName1,"efx2", str1..str2)

                        CSResourceMgr.setLabelString(resName1,"efxLB1", suitInfoTable[2].name)
                        CSResourceMgr.setLabelString(resName1,"efxLB2", suitInfoTable[3].name)
                    elseif suitTable[2] == 0 then
                        CSResourceMgr.getNodeByName(resName1, "tou1"):setVisible(true)
                        CSResourceMgr.getNodeByName(resName1, "xia2"):setVisible(true)
                        CSResourceMgr.getNodeByName(resName1, "efxNode1"):setVisible(true)
                        CSResourceMgr.getNodeByName(resName1, "efxNode2"):setVisible(true)

                        local str1 = CocosModuleMgr.createStringWithFormat({"suit1", "1"})
                        local str2 = CocosModuleMgr.createStringWithFormat({suitInfoTable[1].des, suitInfoTable[1].effectValues[1]})
                        CSResourceMgr.setLabelString(resName1,"efx1", str1..str2)

                        str2 = CocosModuleMgr.createStringWithFormat({suitInfoTable[3].des, suitInfoTable[3].effectValues[1]})
                        CSResourceMgr.setLabelString(resName1,"efx2", str1..str2)

                        CSResourceMgr.setLabelString(resName1,"efxLB1", suitInfoTable[1].name)
                        CSResourceMgr.setLabelString(resName1,"efxLB2", suitInfoTable[3].name)
                    else
                        CSResourceMgr.getNodeByName(resName1, "tou1"):setVisible(true)
                        CSResourceMgr.getNodeByName(resName1, "shang2"):setVisible(true)
                        CSResourceMgr.getNodeByName(resName1, "efxNode1"):setVisible(true)
                        CSResourceMgr.getNodeByName(resName1, "efxNode2"):setVisible(true)

                        local str1 = CocosModuleMgr.createStringWithFormat({"suit1", "1"})
                        local str2 = CocosModuleMgr.createStringWithFormat({suitInfoTable[1].des, suitInfoTable[1].effectValues[1]})
                        CSResourceMgr.setLabelString(resName1,"efx1", str1..str2)

                        str2 = CocosModuleMgr.createStringWithFormat({suitInfoTable[2].des, suitInfoTable[2].effectValues[1]})
                        CSResourceMgr.setLabelString(resName1,"efx2", str1..str2)

                        CSResourceMgr.setLabelString(resName1,"efxLB1", suitInfoTable[1].name)
                        CSResourceMgr.setLabelString(resName1,"efxLB2", suitInfoTable[2].name)
                    end
                end
            end
        end
    end
end

function AvatarViewMgr.sortAvatar(vec)
    table.sort(vec, function(a, b)
        local aIdx = nil
        local bIdx = nil
        local isHas = true
        if a.order then
            aIdx = a.order
        else
            isHas = false
        end
        if b.order then
            bIdx = b.order
        else
            isHas = false
        end
        if isHas then
            if aIdx ~= bIdx then
                return aIdx < bIdx
            end
        end
    end)
   
    return vec
end

function AvatarViewMgr.getFashionSkills()
    -- NetInterface.sendWithBlock("GC_GetFashions_Ack", function()
    --     local FashionSend = require("src.Net.Send.FashionSend")
    --     FashionSend.sendCG_GetFashions_Req()
    -- end, function()
    --     local vec = {}
    --     for k,v in pairs(fashionTabel.curFashion) do
    --         local fashionInfo = ItemInfo.getFashionItemInfoById(v)
    --         if fashionInfo.petAttributeType ~= 0 then
    --             table.insert(vec,fashionInfo.skillID)
    --         end
    --     end
    --     return vec
    -- end, function(code)
    --     TipsMgr.showError(scene, code)
    -- end)
    local vec = {}
    local suitTab = {}
    local fashionVec = PlayerAnimeMgr.skinInfoTransfer(CharInfo.getCurfashion())
    for k,v in pairs(fashionVec) do
        local fashionInfo = ItemInfo.getFashionItemInfoById(v)
        if fashionInfo then
            if fashionInfo.petAttributeType ~= 0 then
                table.insert(vec,fashionInfo.skillID)
            end
            if fashionInfo.suitEffect ~= 0 then
                if suitTab[fashionInfo.suitEffect] then
                    suitTab[fashionInfo.suitEffect] = suitTab[fashionInfo.suitEffect] + 1
                else
                    suitTab[fashionInfo.suitEffect] = 1
                end
            end
        end
    end
    if next(suitTab) then
        for key,value in pairs(suitTab) do
            local entry = ItemInfo.getFashionSuitEffectInfoById(key)
            if value == 1 then
                table.insert(vec,entry.oneEffect*10+1)
            elseif value == 2 then
                table.insert(vec,entry.twoEffect*10+1)
            elseif value == 3 then
                table.insert(vec,entry.threeEffect*10+1)
            end
        end
    end

    return vec
end

return AvatarViewMgr 