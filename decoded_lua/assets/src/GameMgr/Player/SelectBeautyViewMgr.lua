local SelectBeautyViewMgr = {}


local resName = ""
local resNameA = ""
local resNameB = ""
local resNameC = ""
local resNameD = ""
local resNameE = ""
local resNameF = ""
local resNameG = ""
local resNameBG = {}
local playerTag = ""
local petTag = ""
local avatarTypeNum = 5
local lastAvatarBtn = nil
local fashionTabel = nil
local avtName = {}
local aviconRes = {}
local uiStatus = 1
local lastAvatarList = nil
local lastClothBtn = nil
local skinVec = nil
local curPetID = nil
local curSceneID = nil
local petNodes = {}
local rulePartIndex = 0
local fashionShowRuleInfo = {}
local curPetObjId = nil
local playerFashionInfos = {}
local playerID = nil
local allFriendTable = {}
local curPlayerInfo = {}
local likePoint = 0
local likePointUpdateTime = 0
local likeList = {}
local revertSkinVec = nil
local revertPetObj = nil
local revertPetID = nil
local revertSceneID = nil
local rankInfo = {}
local canSave = true

local labelColor = {
    {r=0,g=0,b=0,a=255},
    {r=255,g=252,b=0,a=255},
    {r=166,g=243,b=255,a=255},
    {r=255,g=243,b=227,a=255},
    {r=227,g=233,b=255,a=255},--5
    {r=108,g=122,b=144,a=255},
    {r=196,g=230,b=252,a=255},
    {r=144,g=161,b=176,a=255},
}

local outlineColor = {
    {r=0,g=0,b=0,a=255},
    {r=0,g=0,b=0,a=255,w=1,s=1},
    {r=0,g=0,b=0,a=255,w=1,s=2},
    {r=89,g=47,b=5,a=255,w=1,s=2},
    {r=10,g=22,b=65,a=255,w=1,s=2},--5
    {r=194,g=86,b=71,a=255,s=2},
}

function SelectBeautyViewMgr.Init()
    print("SelectBeautyViewMgr初始化")

    resName = "Player/SelectBeautyView.csb"
    resNameA = "UI/Chat/lookPlayerInfoWindow.csb"
    resNameB = "Player/awardPreview.csb"
    resNameC = "UI/Chat/PetShare.csb"
    resNameD = "Player/SelectingView.csb"
    resNameE = "Player/BeautyRankView.csb"
    resNameF = "Player/SingleBeautyLayer.csb"
    resNameG = "Player/Friends/FriendsListView.csb"
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    playerTag = PlayerAnimeMgr.COMMON_UI_TAG_STRING
    petTag = "SelectBeautyViewMgr2"
    lastAvatarBtn = nil
    fashionTabel = nil
    lastAvatarList = nil
    petNodes = {}
    fashionShowRuleInfo = {}
    rulePartIndex = 0
    playerFashionInfos = {}
    playerID = nil
    allFriendTable = {}
    curPlayerInfo = {}
    likePoint = 0
    likePointUpdateTime = 0
    likeList = {}
    avtName = {"beautyAvatarName1", "beautyAvatarName2", "beautyAvatarName3", "beautyAvatarName4", "beautyAvatarName5"}
    aviconRes = {"Player/Avatar/tou_2.png", "Player/Avatar/shang_2.png", "Player/Avatar/xia_2.png", "Player/Avatar/bei_2.png", "Player/Avatar/wu_2.png"}
    revertSkinVec = nil
    revertPetObj = nil
    revertPetID = nil
    revertSceneID = nil
    rankInfo = {}
end

function SelectBeautyViewMgr.show(scene)
    UIStack.push("SelectBeautyViewMgr",SelectBeautyViewMgr.hide,true)
    uiStatus = 1
    skinVec = nil
    curPetID = nil
    curSceneID = nil
    curPetObjId = nil
    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CocosModuleMgr.setEdgeDistance(layer, nil, nil, nil, 0)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)
        CSResourceMgr.getNodeByName(resName, "top"):setVisible(false)
        --...
        local diff = CocosModuleMgr.getScreenSizeDiff()
        local beijing = CSResourceMgr.getNodeByName(resName, "beijing")
        local bsize = beijing:getContentSize()
        beijing:setContentSize(bsize.width, bsize.height+diff)
        local top = CSResourceMgr.getNodeByName(resName, "top")
        local tposy = top:getPositionY()
        top:setPositionY(tposy+diff)   
        local middle = CSResourceMgr.getNodeByName(resName, "middle")
        local mposy = middle:getPositionY()
        middle:setPositionY(mposy+diff/2)   
        local node = CSResourceMgr.getNodeByName(resName, "node")
        local nposy = node:getPositionY()
        node:setPositionY(nposy+diff)  
        local db_Select = CSResourceMgr.getNodeByName(resName, "db_Select")
        local titleBack = CSResourceMgr.seekNodeByName(db_Select, "titleBack")
        local tposy = titleBack:getPositionY()
        titleBack:setPositionY(tposy+diff)  
        local closeBtn = CSResourceMgr.seekNodeByName(db_Select, "closeBtn")
        local cposy = closeBtn:getPositionY()
        closeBtn:setPositionY(cposy+diff)   
        CSResourceMgr.clickEventBinding(resName, "close", function()
            SelectBeautyViewMgr.hide()
        end)
        local title = CSResourceMgr.seekNodeByName(top,"title")
        CSResourceMgr.setLabelStringByNode(title, "SelectBeauty4", {r=73,g=45,b=0,a=255})
        CSResourceMgr.setLabelColorByNode(title, {r=255,g=208,b=73,a=255})
        local zhutiLabel = CSResourceMgr.seekNodeByName(top,"zhutiLabel")
        CSResourceMgr.setLabelStringByNode(zhutiLabel, "SelectBeauty0", {r=0,g=0,b=0,a=255,w=1})
        CSResourceMgr.setLabelColorByNode(zhutiLabel, {r=241,g=175,b=255,a=255})
        for i=1,3 do
            local label = CSResourceMgr.seekNodeByName(top,"label"..i)
            CSResourceMgr.setLabelStringByNode(label, "SelectBeauty"..i)
            CSResourceMgr.setLabelColorByNode(label, {r=144,g=238,b=255,a=255})
        end
        for i=1,3 do
            local num = CSResourceMgr.seekNodeByName(top,"num"..i)
            CSResourceMgr.setLabelStringByNode(num, "")
            CSResourceMgr.setLabelColorByNode(num, {r=255,g=252,b=0,a=255})
        end
        local buttonStr = {"SelectBeauty29","SelectBeauty6","SelectBeauty30","SelectBeauty15"}
        for i=1,4 do
            local button = CSResourceMgr.getNodeByName(resName,"button"..i)
            CSResourceMgr.setButtonStringByNode(button, buttonStr[i], {r=0,g=0,b=0,a=255,w=1,s=1})
            CSResourceMgr.setButtonStringColorByNode(button, {r=255,g=255,b=255,a=255})
        end
        local changePetBtn = CSResourceMgr.getNodeByName(resName,"changePetBtn")
        CSResourceMgr.setButtonStringByNode(changePetBtn, "SelectBeauty7", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setButtonStringColorByNode(changePetBtn, {r=227,g=233,b=255,a=255})
        local changePlayerBtn = CSResourceMgr.getNodeByName(resName,"changePlayerBtn")
        CSResourceMgr.setButtonStringByNode(changePlayerBtn, "SelectBeauty8", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setButtonStringColorByNode(changePlayerBtn, {r=227,g=233,b=255,a=255})    
        local confirmBtn = CSResourceMgr.getNodeByName(resName,"confirmBtn")
        CSResourceMgr.setButtonStringByNode(confirmBtn, "SelectBeauty11", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setButtonStringColorByNode(confirmBtn, {r=227,g=233,b=255,a=255})  
        local revertBtn = CSResourceMgr.getNodeByName(resName,"revertBtn")
        CSResourceMgr.setButtonStringByNode(revertBtn, "SelectBeauty22", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setButtonStringColorByNode(revertBtn, {r=227,g=233,b=255,a=255})  
        local changeBG = CSResourceMgr.getNodeByName(resName,"changeBG")
        CSResourceMgr.setButtonStringByNode(changeBG, "SelectBeauty25", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setButtonStringColorByNode(changeBG, {r=255,g=255,b=255,a=255,w=1,s=1})  
        local changeBtn = CSResourceMgr.getNodeByName(resName,"changeBtn")
        CSResourceMgr.setButtonStringByNode(changeBtn, "SelectBeauty31", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setButtonStringColorByNode(changeBtn, {r=255,g=255,b=255,a=255,w=1,s=1})  
        local label1 = CSResourceMgr.getNodeByName(resName,"label1")
        CSResourceMgr.setLabelStringByNode(label1, "SelectBeauty26", {r=0,g=0,b=0,a=255,w=1})
        CSResourceMgr.setLabelColorByNode(label1, {r=255,g=255,b=255,a=255,w=1,s=1})
        local actTime = CSResourceMgr.getNodeByName(resName,"actTime")
        CSResourceMgr.setLabelStringByNode(actTime, "SelectBeauty33", {r=0,g=0,b=0,a=255,w=1})
        CSResourceMgr.setLabelColorByNode(actTime, {r=255,g=255,b=255,a=255,w=1,s=1})

        NetInterface.sendWithBlock("GC_TakeFashionShowRankAward_Ack", function()
            local FashionShowSend = require("src.Net.Send.FashionShowSend")
            FashionShowSend.sendCG_TakeFashionShowRankAward_Req()
            end)

        NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
            local LoginSend = require("src.Net.Send.LoginSend")
            LoginSend.sendCG_GetCharacterValues_Req({"likePoint","likePointUpdateTime"})
            end,function()
                likePoint = CharInfo.get().likepoint or 10
                likePointUpdateTime = CharInfo.get().likepointupdatetime or 0
                SelectBeautyViewMgr.setLikePointRefreshTime()
            end)

        NetInterface.sendWithBlock("GC_GetLikeList_Ack", function()
            local FashionShowSend = require("src.Net.Send.FashionShowSend")
            FashionShowSend.sendCG_GetLikeList_Req()
            end)

        local function setTopThreePlayer()
            if #rankInfo>0 then
                for i=1,(#rankInfo>3 and 3 or #rankInfo)do
                    local player = CSResourceMgr.seekNodeByName(middle,"player"..i)
                    local info = rankInfo[i]
                    local headIcon = CSResourceMgr.seekNodeByName(player,"headIcon")
                    if info.fashions then
                        CSResourceMgr.setSpriteTextureByNode(headIcon, CharInfo.getHeadIcon(info.fashions))
                        headIcon:setScale(2)
                    end
                    local zanLabel = CSResourceMgr.seekNodeByName(player,"zanLabel")
                    CSResourceMgr.setLabelStringByNode(zanLabel, "SelectBeauty27", {r=0,g=0,b=0,a=255,w=1})
                    CSResourceMgr.setLabelColorByNode(zanLabel, {r=232,g=168,b=245,a=255})
                    local zanNum = CSResourceMgr.seekNodeByName(player,"zanNum")
                    CSResourceMgr.setLabelStringByNode(zanNum, info.point, {r=0,g=0,b=0,a=255,w=1,s=1})
                    CSResourceMgr.setLabelColorByNode(zanNum, {r=255,g=255,b=255,a=255})
                    local name = CSResourceMgr.seekNodeByName(player,"name")
                    CSResourceMgr.setLabelStringByNode(name, info.nickName, {r=0,g=0,b=0,a=255,w=1,s=1})
                    CSResourceMgr.setLabelColorByNode(name, {r=255,g=255,b=255,a=255})
                    local rank = CSResourceMgr.seekNodeByName(player,"rank")
                    local rankNum = SelectBeautyViewMgr.getRankNum(info,rankInfo)
                    CSResourceMgr.setLabelStringByNode(rank, "SelectBeauty28"..rankNum, {r=0,g=0,b=0,a=255,w=1,s=1})
                    CSResourceMgr.setLabelColorByNode(rank, {r=255,g=220,b=9,a=255})
                end
            end
        end

        NetInterface.sendWithBlock("GC_GetFashionShowRank_Ack", function()
            local FashionShowSend = require("src.Net.Send.FashionShowSend")
            FashionShowSend.sendCG_GetFashionShowRank_Req()
            end,function()
                setTopThreePlayer()
            end)

        local buttonList = {}
        local buttonStr = {"SelectBeauty12","SelectBeauty6","SelectBeauty13","SelectBeauty24","SelectBeauty32","SelectBeauty10"}
        for i=1,6 do
            local bottom = CSResourceMgr.getNodeByName(resName,"bottom")
            local btn = CSResourceMgr.seekNodeByName(bottom,"btn"..i)
            buttonList[i] = btn
            CSResourceMgr.setButtonStringByNode(btn, buttonStr[i], {r=0,g=0,b=0,a=255})
            CSResourceMgr.setButtonStringColorByNode(btn, {r=255,g=255,b=255,a=255,s=1,w=1})            
        end

        --我当评委按钮
        CSResourceMgr.clickEventBindingByNode(buttonList[1],function()
            NetInterface.sendWithBlock("GC_GetFashionShowPeopers_Ack", function()
                local FashionShowSend = require("src.Net.Send.FashionShowSend")
                FashionShowSend.sendCG_GetFashionShowPeopers_Req()
                end)
        end)

        --我要参赛按钮
        CSResourceMgr.clickEventBindingByNode(buttonList[2],function()
            CSResourceMgr.getNodeByName(resName,"bottom"):setVisible(false)
            CSResourceMgr.getNodeByName(resName,"middle"):setVisible(false)
            CSResourceMgr.getNodeByName(resName,"myFashion"):setVisible(true)
        end)

        --排行榜单按钮
        CSResourceMgr.clickEventBindingByNode(buttonList[3],function()
            SelectBeautyViewMgr.showWorldRank()
        end)

        --支持好友按钮
        CSResourceMgr.clickEventBindingByNode(buttonList[4],function()
            SelectBeautyViewMgr.showFriendView()
        end)

        --比赛规则按钮
        CSResourceMgr.clickEventBindingByNode(buttonList[5],function()
            
        end)

        --奖励预览按钮
        CSResourceMgr.clickEventBindingByNode(buttonList[6],function()
            SelectBeautyViewMgr.setAwardPreview()
        end)

        --返回
        CSResourceMgr.clickEventBinding(resName,"button1", function()  
            CSResourceMgr.getNodeByName(resName,"bottom"):setVisible(true)
            CSResourceMgr.getNodeByName(resName,"middle"):setVisible(true)
            CSResourceMgr.getNodeByName(resName,"myFashion"):setVisible(false)
        end)  

        --保存形象
        CSResourceMgr.clickEventBinding(resName,"button2", function()  
            DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, "SelectBeauty20", function()
                if curPetObjId and PokemonInfo.getPetInfoByObjID(curPetObjId) and PokemonInfo.getPokemonInfoByID(PokemonInfo.getPetInfoByObjID(curPetObjId).pokeID).elementAtt1 == fashionShowRuleInfo.petType then  
                    NetInterface.sendWithBlock("GC_SaveFashionShow_Ack", function()
                        local FashionShowSend = require("src.Net.Send.FashionShowSend")
                        FashionShowSend.sendCG_SaveFashionShow_Req({fashions = skinVec,petObjID = curPetObjId,sceneID = curSceneID})
                        end,function()
                            CSResourceMgr.setLabelString(resName,"num1", "SelectBeauty23")
                            CSResourceMgr.setLabelString(resName,"num2", "0")
                            GameAudio.playUISound("success")
                            StandardTipsMgr.show(0, "SelectBeauty17")
                        end)
                else
                    StandardTipsMgr.show(1, "SelectBeauty18")
                end
            end)
        end)  

        --更改按钮
        CSResourceMgr.clickEventBinding(resName,"changeBtn", function()  
            revertSkinVec = {}
            for k,v in pairs(skinVec) do
                table.insert(revertSkinVec,v)
            end
            revertPetObj = curPetObjId
            revertPetID = curPetID
            revertSceneID = curSceneID
            CSResourceMgr.getNodeByName(resName,"changePetBtn"):setVisible(true)
            CSResourceMgr.getNodeByName(resName,"changePlayerBtn"):setVisible(true)
            CSResourceMgr.getNodeByName(resName,"changeBtn"):setVisible(false)
            CSResourceMgr.getNodeByName(resName,"button1"):setVisible(false)
            CSResourceMgr.getNodeByName(resName,"button2"):setVisible(false)
            CSResourceMgr.getNodeByName(resName,"confirmBtn"):setVisible(true)
            CSResourceMgr.getNodeByName(resName,"revertBtn"):setVisible(true)
            CSResourceMgr.getNodeByName(resName,"changeBG"):setVisible(true)
        end)  

        --更改场景按钮
        local mapIndex = 1
        CSResourceMgr.clickEventBinding(resName,"changeBG", function()  
            local map = CSResourceMgr.getNodeByName(resName,"map")
            if mapIndex<6 then
                mapIndex = mapIndex + 1
                if mapIndex == curSceneID then
                    mapIndex = mapIndex + 1
                end
                map:loadTexture("Map/EmbeddedMap/map_"..mapIndex..".png")
            else
                mapIndex = 1
                if mapIndex == curSceneID then
                    mapIndex = mapIndex + 1
                end
                map:loadTexture("Map/EmbeddedMap/map_"..mapIndex..".png")
            end
            curSceneID = mapIndex
        end)  

        fashionShowRuleInfo = CharInfo.getFashionShowRuleInfoById(1)
        NetInterface.sendWithBlock("GC_GetFashions_Ack", function()
            local FashionSend = require("src.Net.Send.FashionSend")
            FashionSend.sendCG_GetFashions_Req()
        end,function()
            fashionTabel = AvatarViewMgr.getFashionTabel()
            playerID = CharInfo.getCharID()
            NetInterface.sendWithBlock("GC_GetSingleFashionShow_Ack", function()
                local FashionShowSend = require("src.Net.Send.FashionShowSend")
                FashionShowSend.sendCG_GetSingleFashionShow_Req({charID = playerID})
                end)
        end,function(code)
            TipsMgr.showError(scene, code)
        end)
    end
    
    local function playCSB()
        local node1 = CSResourceMgr.getNodeByName(resName, "db")
        node1:setVisible(true)
        CocosModuleMgr.showUIAnimation(node1, "up")
        local node2 = CSResourceMgr.getNodeByName(resName, "top")
        node2:setVisible(true)
        CocosModuleMgr.showUIAnimation(node2, "down")
    end
    
    local funcTable = {loadCSB, playCSB}
    UnblockLoader.load(funcTable, "SelectBeautyViewMgr.show")
end

function SelectBeautyViewMgr.reset()
    local petAndPlayer = CSResourceMgr.getNodeByName(resName,"petAndPlayer")
    local sel = CSResourceMgr.getNodeByName(resName,"sel")
    CSResourceMgr.clickEventBinding(resName,"changePetBtn", function()
            GameAudio.playUISound("ok")
            SelectBeautyViewMgr.showSharePets()
        end)

    CSResourceMgr.clickEventBinding(resName,"changePlayerBtn", function()
        CSResourceMgr.getNodeByName(resName,"changePetBtn"):setVisible(false)
        CSResourceMgr.getNodeByName(resName,"changePlayerBtn"):setVisible(false)
        canSave = false
        GameAudio.playUISound("ok")

        local player = CSResourceMgr.seekNodeByName(petAndPlayer,"playerAni")
        local pet = CSResourceMgr.seekNodeByName(petAndPlayer,"petAni")
        transition.fadeOut(pet, {time=0.5})
        transition.moveTo(player, {time = 0.5, x = 300 ,y = 355})
        transition.scaleTo(player, {scale=4/3, time=0.5})
        -- CSResourceMgr.seekNodeByName(petAndPlayer,"changePetBtn"):setVisible(false)
        -- CSResourceMgr.seekNodeByName(petAndPlayer,"changePlayerBtn"):setVisible(false)
        petAndPlayer:performWithDelay(function()
            sel:setVisible(true)
            if lastClothBtn then
                CSResourceMgr.setButtonEnabledByNode(lastClothBtn, true)
                CSResourceMgr.seekNodeByName(lastClothBtn,"icondb"):setVisible(false)
            end
            if lastAvatarList then
                lastAvatarList:setVisible(false)
            end
            if lastAvatarBtn then
                CSResourceMgr.setButtonEnabledByNode(lastAvatarBtn, true)
            end
            lastAvatarBtn = nil
            lastAvatarList = nil
            lastClothBtn = nil
            canSave = true
            end,0.5)
    end)

    CSResourceMgr.clickEventBinding(resName,"confirmBtn", function()
        if canSave then
            GameAudio.playUISound("dress")
            -- CSResourceMgr.seekNodeByName(petAndPlayer,"changePetBtn"):setVisible(true)
            -- CSResourceMgr.seekNodeByName(petAndPlayer,"changePlayerBtn"):setVisible(true)
            sel:setVisible(false)
            local player = CSResourceMgr.seekNodeByName(petAndPlayer,"playerAni")
            local pet = CSResourceMgr.seekNodeByName(petAndPlayer,"petAni")
            transition.fadeIn(pet, {time=0.5})
            transition.moveTo(player, {time = 0.5, x = 450 ,y = 320})
            transition.scaleTo(player, {scale=1, time=0.5})
            if uiStatus==2 then
                CSResourceMgr.playAction(resName, 30, 35, false)
                uiStatus = 1
            end
            CSResourceMgr.getNodeByName(resName,"changePetBtn"):setVisible(false)
            CSResourceMgr.getNodeByName(resName,"changePlayerBtn"):setVisible(false)
            CSResourceMgr.getNodeByName(resName,"changeBtn"):setVisible(true)
            CSResourceMgr.getNodeByName(resName,"button1"):setVisible(true)
            CSResourceMgr.getNodeByName(resName,"button2"):setVisible(true)
            CSResourceMgr.getNodeByName(resName,"confirmBtn"):setVisible(false)
            CSResourceMgr.getNodeByName(resName,"revertBtn"):setVisible(false)
            CSResourceMgr.getNodeByName(resName,"changeBG"):setVisible(false)
        end
    end)

    CSResourceMgr.clickEventBinding(resName,"revertBtn", function()
        GameAudio.playUISound("refresh")
        skinVec = {}
        for k,v in pairs(revertSkinVec) do
            table.insert(skinVec,v)
        end
        PlayerAnimeMgr.setPlayerSkins(playerTag, skinVec)
        if curPetObjId ~= revertPetObj or curPetID ~= revertPetID or curSceneID ~= revertSceneID then
            local res = PokemonInfo.getPokemonResByID(curPetID)
            curSceneID = revertSceneID
            curPetID = revertPetID
            curPetObjId = revertPetObj
            AnimationMgr.removeGafObjectByTag(res, petTag)
            res = PokemonInfo.getPokemonResByID(curPetID)
            local petAniBack = CSResourceMgr.getNodeByName(resName, "petAni")
            local petIcon = AnimationMgr.createAni(petAniBack, res, petAniBack:getContentSize().width/2, petAniBack:getContentSize().height/2,petTag)
            AnimationMgr.playAni(petIcon.res, "idle", true, petTag)
            local petInfo = PokemonInfo.getPetInfoByObjID(curPetObjId)
            AnimationMgr.setSkin(petIcon.res, petInfo and petInfo.skin or 0, petIcon.tag)
            local map = CSResourceMgr.getNodeByName(resName,"map")
            map:loadTexture("Map/EmbeddedMap/map_"..curSceneID..".png")
        end
        if uiStatus==2 then
            CSResourceMgr.playAction(resName, 30, 35, false)
            uiStatus = 1
        end 
        if lastClothBtn then
            CSResourceMgr.setButtonEnabledByNode(lastClothBtn, true)
            CSResourceMgr.seekNodeByName(lastClothBtn,"icondb"):setVisible(false)
        end
        if lastAvatarList then
            lastAvatarList:setVisible(false)
        end
        if lastAvatarBtn then
            CSResourceMgr.setButtonEnabledByNode(lastAvatarBtn, true)
        end
        lastAvatarBtn = nil
        lastAvatarList = nil
        lastClothBtn = nil
    end)

    local function addSkinEffect()
        local particle = CSResourceMgr.createParticle(PlayerAnimeMgr.getPlayer(playerTag), "UI/Login/setskin.plist", 0, 0)
        particle:setScale(0.5)
        particle:setLocalZOrder(10)
    end

    for var=1, avatarTypeNum do
        local avatarBtn = CSResourceMgr.getNodeByName(resName, "avatar"..var)
        CSResourceMgr.clickEventBindingByNode(avatarBtn, function()
            if lastAvatarBtn then
                CSResourceMgr.setButtonEnabledByNode(lastAvatarBtn, true)
            end
            CSResourceMgr.setButtonEnabledByNode(avatarBtn, false)
            lastAvatarBtn = avatarBtn
            
            CSResourceMgr.setLabelString(resName, "avtitle", avtName[var], "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS, nil, 80)
            CSResourceMgr.setSpriteTexture(resName, "avtitleicon", aviconRes[var])
            local fashionBag = fashionTabel.bag or {}
            local list = CSResourceMgr.getNodeByName(resName, "list"..var)
            list:removeAllItems()
            if not fashionBag[tostring(var-1)] then
                fashionBag[tostring(var-1)] = {}
            end
            if lastAvatarList then
                lastAvatarList:setVisible(false)
            end
            if var==rulePartIndex then
                local parent = CSResourceMgr.getNodeByName(resName, "example"):clone()
                list:pushBackCustomItem(parent)
                parent:setVisible(true)
                local iconRes = ItemInfo.getFashionItemInfoById(fashionShowRuleInfo.fashionID).filePath
                local icon = CSResourceMgr.seekNodeByName(parent, "icon")
                CSResourceMgr.setSpriteTextureByNode(icon, iconRes)
                list:setVisible(true)
                lastAvatarList = list  
                local selbtn = CSResourceMgr.seekNodeByName(parent, "selbtn")  
                CSResourceMgr.setButtonEnabledByNode(selbtn, false) 
                CSResourceMgr.seekNodeByName(selbtn,"icondb"):setVisible(true)
                CSResourceMgr.seekNodeByName(selbtn,"ruleBack"):setVisible(true)
                local rulelabel = CSResourceMgr.seekNodeByName(selbtn,"rulelabel")
                CSResourceMgr.setLabelColorByNode(rulelabel, {r=255,g=252,b=0,a=255})
                CSResourceMgr.setLabelStringByNode(rulelabel, "SelectBeauty21", {r=0,g=0,b=0,a=255,w=1,s=1})
            else
                for k,v in pairs(fashionBag[tostring(var-1)]) do
                    local parent = CSResourceMgr.getNodeByName(resName, "example"):clone()
                    list:pushBackCustomItem(parent)
                    parent:setVisible(true)
                    local iconRes = ItemInfo.getFashionItemInfoById(v).filePath
                    local icon = CSResourceMgr.seekNodeByName(parent, "icon")
                    CSResourceMgr.setSpriteTextureByNode(icon, iconRes)
                    list:setVisible(true)
                    lastAvatarList = list
                    local selbtn = CSResourceMgr.seekNodeByName(parent, "selbtn")
                    if v == skinVec[var] then
                        lastClothBtn = selbtn
                        CSResourceMgr.setButtonEnabledByNode(selbtn, var==4 or var==5)
                        CSResourceMgr.seekNodeByName(selbtn,"icondb"):setVisible(true)
                    end
                    CSResourceMgr.clickEventBindingByNode(selbtn, function()
                        GameAudio.playUISound("dressTryon")
                        if (var==4 or var==5) and v == skinVec[var] then
                            skinVec[var] = 0
                            PlayerAnimeMgr.setPlayerSkins(playerTag, skinVec)
                            if lastClothBtn then
                                CSResourceMgr.setButtonEnabledByNode(lastClothBtn, true)
                                CSResourceMgr.seekNodeByName(lastClothBtn,"icondb"):setVisible(false)
                            end
                            lastClothBtn = nil
                        else
                            PlayerAnimeMgr.setPlayerSkin(playerTag, v)
                            skinVec[var] = v
                            if lastClothBtn then
                                CSResourceMgr.setButtonEnabledByNode(lastClothBtn, true)
                                CSResourceMgr.seekNodeByName(lastClothBtn,"icondb"):setVisible(false)
                            end
                            CSResourceMgr.setButtonEnabledByNode(selbtn, var==4 or var==5)
                            CSResourceMgr.seekNodeByName(selbtn,"icondb"):setVisible(true)
                            lastClothBtn = selbtn
                            addSkinEffect()
                        end
                    end)                        
                end
            end
            if uiStatus==1 then
                CSResourceMgr.playAction(resName, 0, 5, false)
            end
            uiStatus = 2
        end)
    end
end

function SelectBeautyViewMgr.hide()
    UIStack.pop("SelectBeautyViewMgr")
    UnblockLoader.cancel("SelectBeautyViewMgr.show")
    lastAvatarBtn = nil
    lastAvatarList = nil
    lastClothBtn = nil
    playerFashionInfos = {}
    playerID = nil
    allFriendTable = {}
    curPlayerInfo = {}
    likePoint = 0
    likeList = {}
    rulePartIndex = 0
    rankInfo = {}
    for var=1, avatarTypeNum do
        local list = CSResourceMgr.getNodeByName(resName, "list"..var)
        list:removeAllItems()
    end
    CSResourceMgr.removeParticle("UI/Login/setskin.plist")
    AnimationMgr.removeGafObjectByTag(resName, petTag)
    PlayerAnimeMgr.removePlayerByTag(playerTag, false)
    CSResourceMgr.removeCSObjectByTag(resName)
end

function SelectBeautyViewMgr.showSharePets()
    UIStack.push("SelectBeautyViewMgr.showSharePets",function()
        UIStack.pop("SelectBeautyViewMgr.showSharePets")
        UnblockLoader.cancel("SelectBeautyViewMgr.showSharePets")
        UnblockLoader.cancel("loadPetList")
        CSResourceMgr.getNodeByName(resNameC, "list"):removeAllItems()
        CSResourceMgr.removeCSObjectByTag(resNameC)
    end,false)
    local function close()
        UIStack.pop("SelectBeautyViewMgr.showSharePets")
        UnblockLoader.cancel("SelectBeautyViewMgr.showSharePets")
        UnblockLoader.cancel("loadPetList")
        CSResourceMgr.getNodeByName(resNameC, "list"):removeAllItems()
        CSResourceMgr.removeCSObjectByTag(resNameC)
    end
    local function loadCSB()
        local node = CSResourceMgr.getNodeByName(resName,"node")
        local layer = CSResourceMgr.createRes(node, resNameC)
        node:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        local diff = CocosModuleMgr.getScreenSizeDiff()
        CSResourceMgr.setRelativePosition(resNameC, 0, -diff/2)
        layer:setVisible(false)

        local title = CSResourceMgr.getNodeByName(resNameC,"title")
        CSResourceMgr.setLabelColorByNode(title, {r=160,g=235,b=250,a=255})
        CSResourceMgr.setLabelStringByNode(title, "SelectBeauty9", {r=37,g=54,b=75,a=255})
        CSResourceMgr.clickEventBinding(resNameC,"close",function()
            close()
        end)
    end
    local function loadPetList()
        local funcTable = {}
        local attrPets = SelectBeautyViewMgr.pickAttriPet(PokemonInfo.getAllPets(),fashionShowRuleInfo.petType)
        local allpets = PetListMgr.sortPetList(attrPets)
        local list = CSResourceMgr.getNodeByName(resNameC, {"db","list"})
        local panel = CSResourceMgr.getNodeByName(resNameC, {"panel"})
        local item = CSResourceMgr.getNodeByName(resNameC, {"panel","btn"})
        local totalLine = math.ceil(#allpets / PetCommonListViewMgr.ROW)
        local diffX = 124
        local panelNodes = {}
        for i = 1, totalLine do
            table.insert(funcTable,function()
                panelNodes[i] = panel:clone()
                local back = CSResourceMgr.seekNodeByName(panelNodes[i], "back")
                back:setVisible(true)
                back:setColor({r=23,g=46,b=59})
                list:pushBackCustomItem(panelNodes[i]) 
            end)
        end
        local index = 1
        for k,v in pairs(allpets) do
            table.insert(funcTable,function()
                local line = math.ceil(index / PetCommonListViewMgr.ROW)
                local row = index % PetCommonListViewMgr.ROW == 0 and PetCommonListViewMgr.ROW or index % PetCommonListViewMgr.ROW
                -- local petNode = BattleFuncMgr.createPetCardWithBlood_older(v,"CommonListPet"..index,true)
                local petNode = BattleFuncMgr.startCreatePetCard(v,3,true)
                petNodes[index] = petNode.button
                petNodes[index]:setVisible(false)
                petNodes[index]:setScale(1.35, 1.35)
                petNodes[index]:addTo(panelNodes[line])
                petNodes[index]:setPositionX(petNodes[index]:getPositionX() + (row - 1) * diffX + 72)
                petNodes[index]:setPositionY(90)
                CSResourceMgr.clickEventBindingByNode(petNodes[index], function ()
                    local res = PokemonInfo.getPokemonResByID(curPetID)
                    curPetID = v.pokeID
                    curPetObjId = v.objID
                    AnimationMgr.removeGafObjectByTag(res, petTag)
                    res = PokemonInfo.getPokemonResByID(curPetID)
                    local petAniBack = CSResourceMgr.getNodeByName(resName, "petAni")
                    local petIcon = AnimationMgr.createAni(petAniBack, res, petAniBack:getContentSize().width/2, petAniBack:getContentSize().height/2,petTag)
                    AnimationMgr.playAni(petIcon.res, "idle", true, petTag)
                    local petInfo = PokemonInfo.getPetInfoByObjID(curPetObjId)
                    AnimationMgr.setSkin(petIcon.res, petInfo and petInfo.skin or 0, petIcon.tag)
                    close()
                    StandardTipsMgr.show(0, "SelectBeauty19")
                end,3)
                petNodes[index]:setVisible(true)
                petNodes[index]:setScale(0, 0)
                transition.scaleTo(petNodes[index], {scale=1.35, time=0.2})
                index = index + 1
            end)
        end
        if totalLine < 3 then
            for i=1,3-totalLine do
                table.insert(funcTable,function()
                    local panelClone = panel:clone()
                    local back = CSResourceMgr.seekNodeByName(panelClone, "back")
                    back:setVisible(true)
                    back:setColor({r=23,g=46,b=59})
                    list:pushBackCustomItem(panelClone) 
                end)
            end
        end
        table.insert(funcTable,function()
            BattleFuncMgr.endCreatePetCard()
            end)
        UnblockLoader.load(funcTable,"loadPetList")
    end
    function loadShareAction()
        CSResourceMgr.getCsbObj(resNameC):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resNameC, "db"), "down")
    end
    local funcTable = {loadCSB, loadPetList, loadShareAction}
    UnblockLoader.load(funcTable,"SelectBeautyViewMgr.showSharePets")
end

function SelectBeautyViewMgr.setAwardPreview()
    UIStack.push("SelectBeautyViewMgr.setAwardPreview",function()
        UIStack.pop("SelectBeautyViewMgr.setAwardPreview")
        GameAudio.playUISound("retract")
        UnblockLoader.cancel("SelectBeautyViewMgr.setAwardPreview")
        UnblockLoader.cancel("SelectBeautyViewMgr.setAwardPreview2")
        CSResourceMgr.removeCSObjectByTag(resNameB)
    end,false)
    local showAwardTable = {}
    local awardPanels = {}
    local function loadCSB()
        local node = CSResourceMgr.getNodeByName(resName, "node")
        local page = CSResourceMgr.createRes(node, resNameB)
        CSResourceMgr.setRelativePosition(resNameB, 0, 0)

        CSResourceMgr.clickEventBinding(resNameB, "close", function()
            UIStack.pop("SelectBeautyViewMgr.setAwardPreview")
            GameAudio.playUISound("retract")
            UnblockLoader.cancel("SelectBeautyViewMgr.setAwardPreview")
            UnblockLoader.cancel("SelectBeautyViewMgr.setAwardPreview2")
            CSResourceMgr.removeCSObjectByTag(resNameB)
        end)
        CSResourceMgr.setLabelColor(resNameB, "title", {r=160,g=235,b=250,a=255})
        CSResourceMgr.setLabelString(resNameB, "title", "SelectBeauty10", "", {r=37,g=54,b=75,a=255})

        local allAwardListID = CharInfo.getFashionShowAwardInfoAllId()
        local list = CSResourceMgr.getNodeByName(resNameB, "list")
        list:removeAllItems()
        for k,v in pairs(allAwardListID) do
            table.insert(showAwardTable,function()
                local line = CSResourceMgr.getNodeByName(resNameB, "line")
                local parent = line:clone()
                awardPanels[k] = parent
                list:pushBackCustomItem(parent)
                parent:setVisible(false)
                local rankBack = CSResourceMgr.seekNodeByName(parent, "rankBack")
                if k <=3 then
                    rankBack:setColor({r=255,g=162,b=0,a=255})
                else
                    rankBack:setColor({r=26,g=144,b=183,a=255})
                end
                local rankLabel = CSResourceMgr.seekNodeByName(parent, "rankLabel")
                CSResourceMgr.setLabelStringByNode(rankLabel, "rankLabel"..k, {r=0,g=0,b=0,a=255,w=1})
                CSResourceMgr.setLabelColorByNode(rankLabel, {r=255,g=255,b=255,a=255})
                local i = 1
                for kk,vv in pairs(v.awardList) do
                    local item = CSResourceMgr.seekNodeByName(parent, "item"..i)
                    i = i + 1
                    local itemInfo = ItemInfo.getItemInfoById(vv.itemID)
                    local itemIcon = CSResourceMgr.seekNodeByName(item, "itemIcon")
                    CSResourceMgr.setSpriteTextureByNode(itemIcon, itemInfo.icon)
                    local itemNum = CSResourceMgr.seekNodeByName(item, "itemNum")
                    CSResourceMgr.setLabelStringByNode(itemNum, vv.itemCount, {r=0,g=0,b=0,a=255})
                    CSResourceMgr.setLabelColorByNode(itemNum, {r=255,g=255,b=255,a=255})
                    CSResourceMgr.setButtonTextureByNode(item, ItemInfo.getItemRareBGImage(vv.itemID), ItemInfo.getItemRareBGImage(vv.itemID), ItemInfo.getItemRareBGImage(vv.itemID))
                    CSResourceMgr.clickEventBindingByNode(item, function()
                        ItemInfoViewMgr.show({id = vv.itemID, vv.itemCount, type = 1}, false)
                    end, 3)
                    parent:performWithDelay(function()
                        item:setScale(0,0)
                        item:setVisible(true)
                        transition.scaleTo(item, {scale=1, time=0.2})
                    end,0.2)
                end
                awardPanels[k]:setVisible(true)
                awardPanels[k]:setScaleX(0)
                transition.scaleTo(awardPanels[k], {scale=1, time=0.2})
            end)
        end
        UnblockLoader.load(showAwardTable, "SelectBeautyViewMgr.setAwardPreview2")
    end

    local function playCSB()
        CSResourceMgr.playAction(resNameB, 0, 5, false)
    end

    local funcTable = {loadCSB, playCSB}

    UnblockLoader.load(funcTable, "SelectBeautyViewMgr.setAwardPreview")
end

function SelectBeautyViewMgr.pickAttriPet(allpets,attr)
    local attriPets = {}
    for k,v in pairs(allpets) do
        local attr2 = PokemonInfo.getPokemonInfoByID(v.pokeID).elementAtt1
        if attr2 == attr then
            table.insert(attriPets,v)
        end
    end
    attriPets = PetListMgr.sortPetList(attriPets)
    return attriPets
end

function SelectBeautyViewMgr.setFashionShow(info)
    info.sceneID = info.sceneID or 1
    if playerID ~= CharInfo.getCharID() then
        if info.petID == 0 then
            StandardTipsMgr.show(1, "SelectBeauty14")
        else
            info.id = curPlayerInfo.friendID
            info.nickName = curPlayerInfo.name
            SelectBeautyViewMgr.showSingleBeauty(info)
        end
        playerFashionInfos[playerID] = info
        return
    else
        playerFashionInfos[playerID] = info
    end
    CSResourceMgr.setLabelString(resName, "num1", info.rank)
    CSResourceMgr.setLabelString(resName, "num2", info.point)
    CSResourceMgr.setLabelString(resName, "num3", likePoint.."/10")
    local playerAniBack = CSResourceMgr.getNodeByName(resName, "playerAni")
    local params = {}
    local charSex = CharInfo.getSex()
    skinVec = fashionTabel.curFashion
    for k,v in pairs(info.fashions) do
        skinVec[k] = v
    end

    --if拥有限定时装
    rulePartIndex = math.floor(fashionShowRuleInfo.fashionID/1000)
    skinVec[rulePartIndex] = fashionShowRuleInfo.fashionID

    params.skin = skinVec
    params.gender = charSex
    local anime = PlayerAnimeMgr.createPlayer(playerAniBack, params, playerTag, true)
    anime:setScale(1.5)

    local attrPets = SelectBeautyViewMgr.pickAttriPet(PokemonInfo.getAllPets(),fashionShowRuleInfo.petType)
    if info.petObjID~=0 then
        curPetObjId = info.petObjID
        curPetID = info.petID
        local res = PokemonInfo.getPokemonResByID(curPetID)
        local petAniBack = CSResourceMgr.getNodeByName(resName, "petAni")
        local petIcon = AnimationMgr.createAni(petAniBack, res, petAniBack:getContentSize().width/2, petAniBack:getContentSize().height/2,petTag)
        AnimationMgr.playAni(petIcon.res, "idle", true, petTag)
        local petInfo = PokemonInfo.getPetInfoByObjID(curPetObjId)
        AnimationMgr.setSkin(petIcon.res, petInfo and petInfo.skin or 0, petIcon.tag)
    elseif attrPets[1] then
        curPetObjId = attrPets[1].objID
        curPetID = PokemonInfo.getPetInfoByObjID(curPetObjId).pokeID
        local res = PokemonInfo.getPokemonResByID(curPetID)
        local petAniBack = CSResourceMgr.getNodeByName(resName, "petAni")
        local petIcon = AnimationMgr.createAni(petAniBack, res, petAniBack:getContentSize().width/2, petAniBack:getContentSize().height/2,petTag)
        AnimationMgr.playAni(petIcon.res, "idle", true, petTag)
        local petInfo = PokemonInfo.getPetInfoByObjID(curPetObjId)
        AnimationMgr.setSkin(petIcon.res, petInfo and petInfo.skin or 0, petIcon.tag)
    end
    curSceneID = info.sceneID
    local map = CSResourceMgr.getNodeByName(resName,"map")
    map:loadTexture("Map/EmbeddedMap/map_"..curSceneID..".png")

    SelectBeautyViewMgr.reset()
end

function SelectBeautyViewMgr.showSelecting(fashionShow)
    local function closeSelect()
        UIStack.pop("SelectBeautyViewMgr.showSelecting")
        GameAudio.playUISound("retract")
        CSResourceMgr.removeCSObjectByTag(resNameD)
        local list = CSResourceMgr.getNodeByName(resNameD, "list")
        CSResourceMgr.removeListByNode(list)
        CSResourceMgr.getNodeByName(resName, "top"):setVisible(true)
        CSResourceMgr.getNodeByName(resName, "middle"):setVisible(true)
        CSResourceMgr.getNodeByName(resName, "bottom"):setVisible(true)
        CSResourceMgr.getNodeByName(resName, "db_Select"):setVisible(false)
    end
    UIStack.push("SelectBeautyViewMgr.showSelecting",function()
        closeSelect()
    end,false)

    CSResourceMgr.getNodeByName(resName, "top"):setVisible(false)
    CSResourceMgr.getNodeByName(resName, "middle"):setVisible(false)
    CSResourceMgr.getNodeByName(resName, "bottom"):setVisible(false)
    CSResourceMgr.getNodeByName(resName, "db_Select"):setVisible(true)

    local diff = CocosModuleMgr.getScreenSizeDiff()
    local function loadCSB()
        local node = CSResourceMgr.getNodeByName(resName, "node")
        local page = CSResourceMgr.createRes(node, resNameD)
        CSResourceMgr.setRelativePosition(resNameD, 0, 0)

        local db_Select = CSResourceMgr.getNodeByName(resName, "db_Select")
        local closeBtn = CSResourceMgr.seekNodeByName(db_Select, "closeBtn")
        CSResourceMgr.clickEventBindingByNode(closeBtn, function()
            closeSelect()
        end)
        local awardBtn = CSResourceMgr.seekNodeByName(db_Select,"button3")
        CSResourceMgr.clickEventBindingByNode(awardBtn, function()
            --评委奖励
            end)
        local refreshBtn = CSResourceMgr.seekNodeByName(db_Select,"button4")
        CSResourceMgr.clickEventBindingByNode(refreshBtn, function()
            GameAudio.playUISound("shoprefresh")
            NetInterface.sendWithBlock("GC_GetFashionShowPeopers_Ack", function()
                local FashionShowSend = require("src.Net.Send.FashionShowSend")
                FashionShowSend.sendCG_GetFashionShowPeopers_Req()
                end)
            end)

        local title = CSResourceMgr.seekNodeByName(db_Select,"title")
        CSResourceMgr.setLabelStringByNode(title, "SelectBeauty34", {r=73,g=45,b=0,a=255})
        CSResourceMgr.setLabelColorByNode(title, {r=255,g=208,b=73,a=255})

        SelectBeautyViewMgr.refreshPeoples(fashionShow)
    end

    loadCSB()
end

function SelectBeautyViewMgr.refreshPeoples(fashionShow)
    local list = CSResourceMgr.getNodeByName(resNameD, "list")
    CSResourceMgr.removeListByNode(list)
    local index = 1
    local compare = CSResourceMgr.getNodeByName(resNameD, "compare"):clone()
    list:pushBackCustomItem(compare) 
    compare:setVisible(true)
    local buttons = {}
    for k,v in pairs(fashionShow) do
        local card = CSResourceMgr.seekNodeByName(compare,"card"..k.."Back")

        for i=1,2 do
            CSResourceMgr.seekNodeByName(card,"back"..i):setColor({r=55,g=66,b=112,a=255})
        end
        CSResourceMgr.seekNodeByName(compare,"Image_545"):setColor({r=45,g=14,b=72,a=255})

        local playerName = CSResourceMgr.seekNodeByName(card,"playerName")
        CSResourceMgr.setLabelStringByNode(playerName, v.nickName, {r=0,g=0,b=0,a=255,w=1,s=1})
        CSResourceMgr.setLabelColorByNode(playerName, {r=255,g=255,b=255,a=255})

        local playerID = CSResourceMgr.seekNodeByName(card,"IDNum")
        CSResourceMgr.setLabelStringByNode(playerID, v.charID, {r=0,g=0,b=0,a=255,w=1})
        CSResourceMgr.setLabelColorByNode(playerID, {r=156,g=255,b=255,a=255})

        local playerLike = CSResourceMgr.seekNodeByName(card,"zanNum")
        CSResourceMgr.setLabelStringByNode(playerLike, v.point, {r=0,g=0,b=0,a=255,w=1})
        CSResourceMgr.setLabelColorByNode(playerLike, {r=251,g=247,b=8,a=255})

        local zanBtn = CSResourceMgr.seekNodeByName(card,"zanBtn")
        buttons[k] = zanBtn
        CSResourceMgr.clickEventBindingByNode(zanBtn, function()
            if likePoint<=0 then
                StandardTipsMgr.show(1, "SelectBeauty16")
            else
                NetInterface.sendWithBlock("GC_LikeFashionShow_Ack", function()
                    local FashionShowSend = require("src.Net.Send.FashionShowSend")
                    FashionShowSend.sendCG_LikeFashionShow_Req({charID = v.charID})
                    end,function()
                        CSResourceMgr.setLabelStringByNode(playerLike, v.point+1, {r=0,g=0,b=0,a=255,w=1})
                        for k,v in pairs(buttons) do
                            CSResourceMgr.setButtonEnabledByNode(v, false)
                        end
                        local addZan = CSResourceMgr.seekNodeByName(card,"addZan")
                        addZan:setVisible(true)
                        transition.moveBy(addZan, {y = 50, time = 0.5})
                        transition.fadeOut(addZan, {time = 0.5})
                        if likePoint == 10 then
                            likepointupdatetime = CharInfo.getServerTime()
                        end
                        likePoint = likePoint - 1
                        CSResourceMgr.setLabelString(resName, "num3", likePoint.."/10")
                        compare:performWithDelay(function()
                            NetInterface.sendWithBlock("GC_GetFashionShowPeopers_Ack", function()
                                local FashionShowSend = require("src.Net.Send.FashionShowSend")
                                FashionShowSend.sendCG_GetFashionShowPeopers_Req()
                                end)
                        end ,0.5)
                    end)
            end
        end, 3)

        local player = CSResourceMgr.seekNodeByName(card,"playerAni")
        local pet = CSResourceMgr.seekNodeByName(card,"petAni")
        local res = PokemonInfo.getPokemonResByID(v.petID)
        local petIcon = AnimationMgr.createAni(pet, res, pet:getContentSize().width/2, pet:getContentSize().height/2,"pet"..index)
        AnimationMgr.playAni(petIcon.res, "idle", true, "pet"..index)
        petIcon:setScale(0.5)
        local params = {}
        params.skin = v.fashions
        params.gender = CharInfo.getSex()
        local anime = PlayerAnimeMgr.createPlayer(player, params, "player"..index, true)
        anime:setScale(1)

        local map = CSResourceMgr.seekNodeByName(card,"map")
        map:loadTexture("Map/EmbeddedMap/map_"..v.sceneID..".png")

        index = index + 1
    end
end

function SelectBeautyViewMgr.showWorldRank()
    UIStack.push("SelectBeautyViewMgr.showWorldRank",function()
        UIStack.pop("SelectBeautyViewMgr.showWorldRank")
        GameAudio.playUISound("retract")
        StatusBarMgr.hideTopInfoBar()
        UnblockLoader.cancel("SelectBeautyViewMgr.showWorldRank")
        UnblockLoader.cancel("SelectBeautyViewMgr.setWorldRankPeoples")
        local list = CSResourceMgr.getNodeByName(resNameE, "list")
        CSResourceMgr.removeListByNode(list)
        CSResourceMgr.removeCSObjectByTag(resNameE)
        CSResourceMgr.removeCSObjectByTag(resNameBG)
    end,false)

    local diff = CocosModuleMgr.getScreenSizeDiff()
    local node = CSResourceMgr.getNodeByName(resName, "node")
    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(node, resNameBG)
        CSResourceMgr.setRelativePosition(resNameBG, 0, -diff/2)
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    end
    local function loadCSB()
        local page = CSResourceMgr.createRes(node, resNameE)
        CSResourceMgr.setRelativePosition(resNameE, 0, 0)
        page:setVisible(false)

        CSResourceMgr.setLabelColor(resNameE, "title", {r=160,g=235,b=250,a=255})
        CSResourceMgr.setLabelString(resNameE, "title", "SelectBeauty13", "", {r=37,g=54,b=75,a=255})

        local function refreshRankPlayerSelfInfo()
            local selfFashion = playerFashionInfos[CharInfo.getCharID()]
            local rankNum = SelectBeautyViewMgr.getRankNum(selfFashion,rankInfo)

            local panel1     = CSResourceMgr.getNodeByName(resNameE, "panel_1")
            local labelName  = CSResourceMgr.seekNodeByName(panel1, "char_name")
            local labelVip   = CSResourceMgr.seekNodeByName(panel1, "vip_level")
            local labelLv    = CSResourceMgr.seekNodeByName(panel1, "char_level")
            local labelTitle = CSResourceMgr.seekNodeByName(panel1, "rank_title")
            local labelRank  = CSResourceMgr.seekNodeByName(panel1, "rank_num")
            local spriteIcon = CSResourceMgr.seekNodeByName(panel1, "char_icon")

            local vipLv = CharInfo.getVipInfoByID(CharInfo.getVIPLevel()).viplevel

            CSResourceMgr.setLabelStringByNode(labelName, CharInfo.getNickName(), outlineColor[3], nil, 161)
            CSResourceMgr.setLabelStringByNode(labelVip, vipLv, outlineColor[3])
            CSResourceMgr.setLabelStringByNode(labelLv, "Lv."..CharInfo.getLevel(), outlineColor[3])
            CSResourceMgr.setLabelStringByNode(labelTitle, "arena7", outlineColor[2], nil, 160)
            CSResourceMgr.setLabelStringByNode(labelRank, rankNum, outlineColor[1], nil, 138)

            CSResourceMgr.setLabelColorByNode(labelName,  labelColor[2])
            CSResourceMgr.setLabelColorByNode(labelVip,   labelColor[2])
            CSResourceMgr.setLabelColorByNode(labelTitle, labelColor[3])

            CSResourceMgr.setSpriteTextureByNode(spriteIcon, CharInfo.getHeadIcon(selfFashion.fashions))
            spriteIcon:setScale(1.5)
            spriteIcon:setPositionY(69)
        end
        refreshRankPlayerSelfInfo()
    end

    local function close()
        UIStack.pop("SelectBeautyViewMgr.showWorldRank")
        GameAudio.playUISound("retract")
        StatusBarMgr.hideTopInfoBar()
        UnblockLoader.cancel("SelectBeautyViewMgr.showWorldRank")
        UnblockLoader.cancel("SelectBeautyViewMgr.setWorldRankPeoples")
        local list = CSResourceMgr.getNodeByName(resNameE, "list")
        CSResourceMgr.removeListByNode(list)
        CSResourceMgr.removeCSObjectByTag(resNameE)
        CSResourceMgr.removeCSObjectByTag(resNameBG)
    end

    local function playCSB()
        CSResourceMgr.getCsbObj(resNameE):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resNameE), "up")
        SelectBeautyViewMgr.setWorldRankPeoples(rankInfo)
        StatusBarMgr.showTopInfoBar(function()
            close()
        end)
    end

    local funcTable = {loadBG,loadCSB, playCSB}

    UnblockLoader.load(funcTable, "SelectBeautyViewMgr.showWorldRank")
end

function SelectBeautyViewMgr.setWorldRankInfo(info)
    rankInfo = info
end

function SelectBeautyViewMgr.setWorldRankPeoples(rankInfo)
    local funcTable = {}
    CSResourceMgr.setLabelString(resNameE, "title1", "arena28", "", {r=194,g=86,b=71,a=255})
    CSResourceMgr.setLabelString(resNameE, "rank_title", "arena27", "", {r=38,g=54,b=76,a=255})
    local list = CSResourceMgr.getNodeByName(resNameE, "list")
    CSResourceMgr.removeListByNode(list)

    local diff = CocosModuleMgr.getScreenSizeDiff()
    local lsize = list:getContentSize()
    list:setContentSize(lsize.width, lsize.height+diff)
    local diban = CSResourceMgr.getNodeByName(resNameE, "bg3")
    local dbsize = diban:getContentSize()
    diban:setContentSize(dbsize.width, dbsize.height+diff)

    --此处借鉴罗伟竞技场排行榜代码
    local function setSingleRankItem(node, playerInfo,rank)
        local rankNum = rank
        local faimly = playerInfo.faimly or nil
        -- local gender = playerInfo.gender ~= 0 and "Charactor/Head/ditu_nv.png" or "Charactor/Head/ditu_nan.png"
        local diban = CSResourceMgr.seekNodeByName(node, "player_diban")
        local bg11 = CSResourceMgr.seekNodeByName(node, "bg11")
        local bg21 = CSResourceMgr.seekNodeByName(node, "bg21")
        local bg14 = CSResourceMgr.seekNodeByName(node, "bg14")
        local fmbg = CSResourceMgr.seekNodeByName(node, "family_bg")
        local rankTex = CSResourceMgr.seekNodeByName(node, "rank_num_sprite")
        local rankLab = CSResourceMgr.seekNodeByName(node, "rank_num_label")
        local playerIcon = CSResourceMgr.seekNodeByName(node, "player_icon")
        local vip = CSResourceMgr.seekNodeByName(node, "player_vip")
        local playerLv = CSResourceMgr.seekNodeByName(node, "player_level")
        local playerName = CSResourceMgr.seekNodeByName(node, "player_name")
        local fc = CSResourceMgr.seekNodeByName(node, "fc")
        local familyNode = CSResourceMgr.seekNodeByName(node, "family")
        local btnDir = CSResourceMgr.seekNodeByName(node, "btn_info")

        if rankNum <= 3 then
            rankLab:setVisible(false)
            CSResourceMgr.setSpriteTextureByNode(rankTex, ArenaViewMgr.PlayerRankNumTex[rankNum])
        else
            rankTex:setVisible(false)
            CSResourceMgr.setLabelStringByNode(rankLab, rankNum, outlineColor[3])
            CSResourceMgr.setLabelColorByNode(rankLab, labelColor[3])
        end

        CSResourceMgr.setSpriteTextureByNode(playerIcon, CharInfo.getHeadIcon(playerInfo.fashions))
        playerIcon:setScale(1.3)

        if rankNum > 3 then rankNum = 4 end
        CSResourceMgr.setSpriteTextureByNode(diban, ArenaViewMgr.PlayerRankBackgroudTex[rankNum])
        bg11:setColor(ArenaViewMgr.BGTexColor1[rankNum])
        bg21:setColor(ArenaViewMgr.BGTexColor2[rankNum])
        bg14:setColor(ArenaViewMgr.BGTexColor3[rankNum])
        fmbg:setColor(ArenaViewMgr.BGTexColor2[rankNum])
        local vipLv = CharInfo.getVipInfoByID(playerInfo.vipLevel).viplevel
        CSResourceMgr.setLabelStringByNode(vip, vipLv, outlineColor[2])
        CSResourceMgr.setLabelStringByNode(playerLv, "Lv."..playerInfo.level)
        CSResourceMgr.setLabelStringByNode(playerName, playerInfo.nickName, outlineColor[2], nil, 198)
        CSResourceMgr.setLabelStringByNode(fc, playerInfo.point, outlineColor[2], nil, 112)

        CSResourceMgr.setLabelColorByNode(vip, labelColor[2])
        CSResourceMgr.setLabelColorByNode(playerLv, ArenaViewMgr.PlayerLvColor[rankNum])

        if faimly then

        else
            familyNode:setVisible(false)
        end

        CSResourceMgr.clickEventBindingByNode(node,function()
            SelectBeautyViewMgr.showSingleBeauty(playerInfo,true)
        end)

        list:pushBackCustomItem(node)
    end

    for k,v in pairs(rankInfo) do
        if k <=20 then
            table.insert(funcTable,function()
                local rank = SelectBeautyViewMgr.getRankNum(v,rankInfo)
                local parent = CSResourceMgr.getNodeByName(resNameE, "btn_item"):clone()
                parent:setVisible(true)
                setSingleRankItem(parent,v,rank)
            end)
        end
    end 

    UnblockLoader.load(funcTable, "SelectBeautyViewMgr.setWorldRankPeoples")
end

function SelectBeautyViewMgr.getRankNum(singleInfo,rankInfo)
    local rank = 1
    for k,v in pairs(rankInfo) do
        if v.point>singleInfo.point then
            rank = rank + 1
        end
    end
    return rank
end

function SelectBeautyViewMgr.showSingleBeauty(info,inRank)
    UIStack.push("SelectBeautyViewMgr.showSingleBeauty",function()
        UIStack.pop("SelectBeautyViewMgr.showSingleBeauty")
        if petObj then
            AnimationMgr.removeGafObjectByTag(petObj.res, "singlePet")
        end
        PlayerAnimeMgr.removePlayerByTag("singlePlayer", true)
        UnblockLoader.cancel("SelectBeautyViewMgr.showSingleBeauty")
        CSResourceMgr.removeCSObjectByTag(resNameF)
    end,false)
    local function loadCSB()
        local node = CSResourceMgr.getNodeByName(resName, "node")
        local page = CSResourceMgr.createRes(node, resNameF)
        page:setVisible(false)

        local petObj = nil
        local function close()
            UIStack.pop("SelectBeautyViewMgr.showSingleBeauty")
            if petObj then
                AnimationMgr.removeGafObjectByTag(petObj.res, "singlePet")
            end
            PlayerAnimeMgr.removePlayerByTag("singlePlayer", true)
            UnblockLoader.cancel("SelectBeautyViewMgr.showSingleBeauty")
            CSResourceMgr.removeCSObjectByTag(resNameF)
        end

        CSResourceMgr.clickEventBinding(resNameF, "bg", function()
            close()
        end)

        local card = CSResourceMgr.getNodeByName(resNameF,"cardBack")

        local playerName = CSResourceMgr.seekNodeByName(card,"playerName")
        CSResourceMgr.setLabelStringByNode(playerName, info.nickName, {r=0,g=0,b=0,a=255,w=1})
        CSResourceMgr.setLabelColorByNode(playerName, {r=196,g=230,b=252,a=255})

        local playerID = CSResourceMgr.seekNodeByName(card,"IDNum")
        CSResourceMgr.setLabelStringByNode(playerID, info.id, {r=0,g=0,b=0,a=255,w=1})
        CSResourceMgr.setLabelColorByNode(playerID, {r=156,g=255,b=255,a=255})

        local playerLike = CSResourceMgr.seekNodeByName(card,"zanNum")
        CSResourceMgr.setLabelStringByNode(playerLike, info.point, {r=0,g=0,b=0,a=255,w=1})
        CSResourceMgr.setLabelColorByNode(playerLike, {r=251,g=247,b=8,a=255})

        local zanBtn = CSResourceMgr.seekNodeByName(card,"zanBtn")
        if likeList[info.id] then
            CSResourceMgr.setButtonEnabledByNode(zanBtn, false)
        end
        if inRank then
            zanBtn:setVisible(false)
        end
        CSResourceMgr.clickEventBindingByNode(zanBtn, function()
            if likePoint<=0 then
                StandardTipsMgr.show(1, "SelectBeauty16")
            else
                NetInterface.sendWithBlock("GC_LikeFashionShow_Ack", function()
                    local FashionShowSend = require("src.Net.Send.FashionShowSend")
                    FashionShowSend.sendCG_LikeFashionShow_Req({charID = info.id})
                    end,function()
                        CSResourceMgr.setLabelStringByNode(playerLike, info.point+1, {r=0,g=0,b=0,a=255,w=1})
                        CSResourceMgr.setButtonEnabledByNode(zanBtn, false)
                        local addZan = CSResourceMgr.seekNodeByName(card,"addZan")
                        addZan:setVisible(true)
                        transition.moveBy(addZan, {y = 50, time = 0.5})
                        transition.fadeOut(addZan, {time = 0.5})
                        if likePoint == 10 then
                            likepointupdatetime = CharInfo.getServerTime()
                        end
                        likePoint = likePoint - 1
                        CSResourceMgr.setLabelString(resName, "num3", likePoint.."/10")
                        likeList[info.id] = info.id
                        if CSResourceMgr.getCsbObj(resNameE) then
                            NetInterface.sendWithBlock("GC_GetFashionShowRank_Ack", function()
                                local FashionShowSend = require("src.Net.Send.FashionShowSend")
                                FashionShowSend.sendCG_GetFashionShowRank_Req()
                                end)
                        end
                    end)
            end
        end, 3)

        local player = CSResourceMgr.seekNodeByName(card,"playerAni")
        local pet = CSResourceMgr.seekNodeByName(card,"petAni")
        local res = PokemonInfo.getPokemonResByID(info.petID)
        petObj = AnimationMgr.createAni(pet, res, pet:getContentSize().width/2, pet:getContentSize().height/2,"singlePet")
        AnimationMgr.playAni(petObj.res, "idle", true, "singlePet")
        petObj:setScale(0.5)
        local params = {}
        params.skin = info.fashions
        params.gender = CharInfo.getSex()
        local anime = PlayerAnimeMgr.createPlayer(player, params, "singlePlayer", true)
        anime:setScale(1)

    end

    local function playCSB()
        CSResourceMgr.getCsbObj(resNameF):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resNameF), "up")
    end

    local funcTable = {loadCSB, playCSB}

    UnblockLoader.load(funcTable, "SelectBeautyViewMgr.showSingleBeauty")
end

function SelectBeautyViewMgr.showFriendView()
    UIStack.push("SelectBeautyViewMgr.showFriendView",function()
        UIStack.pop("SelectBeautyViewMgr.showFriendView")
        GameAudio.playUISound("retract")
        StatusBarMgr.hideTopInfoBar()
        UnblockLoader.cancel("SelectBeautyViewMgr.showFriendView")
        UnblockLoader.cancel("SelectBeautyViewMgr.resetAllFriendInfo")
        CSResourceMgr.removeCSObjectByTag(resNameG)
        CSResourceMgr.removeCSObjectByTag(resNameBG)
        allFriendTable = {}
        local list = CSResourceMgr.getNodeByName(resNameG, "friendList")
        CSResourceMgr.removeListByNode(list)
    end,false)

    local diff = CocosModuleMgr.getScreenSizeDiff()
    local node = CSResourceMgr.getNodeByName(resName, "node")
    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(node, resNameBG)
        CSResourceMgr.setRelativePosition(resNameBG, 0, -diff/2)
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    end
    local function loadCSB()
        local page = CSResourceMgr.createRes(node, resNameG)
        CSResourceMgr.setRelativePosition(resNameG, 0, -diff/2)
        page:setVisible(false)

        local frame = CSResourceMgr.getNodeByName(resNameG, "frame")
        local fsize = frame:getContentSize()
        frame:setContentSize(fsize.width, fsize.height+diff)
        local title = CSResourceMgr.getNodeByName(resNameG, "title")
        local tposy = title:getPositionY()
        title:setPositionY(tposy+diff)   
        local back2 = CSResourceMgr.getNodeByName(resNameG,"back2")
        local b2size = back2:getContentSize()
        back2:setContentSize(b2size.width, b2size.height+diff)  
        local playerMax = CSResourceMgr.getNodeByName(resNameG, "playerMax")
        local pposy = playerMax:getPositionY()
        playerMax:setPositionY(pposy+diff)   
        local list = CSResourceMgr.getNodeByName(resNameG,"friendList")
        local lsize = list:getContentSize()
        list:setContentSize(lsize.width, lsize.height+diff)
        local node = CSResourceMgr.getNodeByName(resNameG,"node")
        local nposy = node:getPositionY()
        node:setPositionY(nposy+diff) 
        local line1 = CSResourceMgr.getNodeByName(resNameG,"line1")
        local lineposy = line1:getPositionY()
        line1:setPositionY(lineposy+diff) 
        CSResourceMgr.getNodeByName(resNameG,"back1"):setVisible(false)
        CSResourceMgr.getNodeByName(resNameG,"friendValueMax"):setVisible(false)
        CSResourceMgr.getNodeByName(resNameG,"tab1"):setVisible(false)
        CSResourceMgr.getNodeByName(resNameG,"tab2"):setVisible(false)
        CSResourceMgr.getNodeByName(resNameG,"searchBtn"):setVisible(false)
        CSResourceMgr.getNodeByName(resNameG,"applyBtn"):setVisible(false)
        list:setVisible(true)
        NetInterface.sendWithBlock("GC_GetMyFriends_Ack", function()
            local ChatUserSend = require("src.Net.Send.ChatUserSend")
            ChatUserSend.sendCG_GetMyFriends_Req()
            end)
        local title = CSResourceMgr.getNodeByName(resNameG,"title")
        CSResourceMgr.setLabelColorByNode(title, {r=160,g=235,b=250,a=255})
        CSResourceMgr.setLabelStringByNode(title,"friendList0" , {r=37,g=54,b=75,a=255})
    end

    local function close()
        UIStack.pop("SelectBeautyViewMgr.showFriendView")
        GameAudio.playUISound("retract")
        StatusBarMgr.hideTopInfoBar()
        UnblockLoader.cancel("SelectBeautyViewMgr.showFriendView")
        UnblockLoader.cancel("SelectBeautyViewMgr.resetAllFriendInfo")
        CSResourceMgr.removeCSObjectByTag(resNameG)
        CSResourceMgr.removeCSObjectByTag(resNameBG)
        allFriendTable = {}
        local list = CSResourceMgr.getNodeByName(resNameG, "friendList")
        CSResourceMgr.removeListByNode(list)
    end

    local function playCSB()
        CSResourceMgr.getCsbObj(resNameG):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resNameG), "up")
        StatusBarMgr.showTopInfoBar(function()
            close()
        end)
    end

    local funcTable = {loadBG,loadCSB, playCSB}

    UnblockLoader.load(funcTable, "SelectBeautyViewMgr.showFriendView")
end

function SelectBeautyViewMgr.resetAllFriendInfo()
    local funcTable = {}
    local list = CSResourceMgr.getNodeByName(resNameG, "friendList")
    local function setFriend(playerInfo)
        local friend = CSResourceMgr.getNodeByName(resNameG, "friend"):clone()
        friend:setVisible(true)
        local playerName = CSResourceMgr.seekNodeByName(friend, "playerName")
        CSResourceMgr.setLabelColorByNode(playerName, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(playerName,playerInfo.name, {r=5,g=48,b=84,a=255})
        local level = CSResourceMgr.seekNodeByName(friend, "Lv")
        CSResourceMgr.setLabelColorByNode(level, {r=255,g=252,b=0,a=255})
        CSResourceMgr.setLabelStringByNode(level,"Lv"..playerInfo.level, {r=0,g=0,b=0,a=255})
        local likeNum = CSResourceMgr.seekNodeByName(friend, "likeNum")
        CSResourceMgr.setLabelColorByNode(likeNum, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(likeNum,playerInfo.friendPoint)
        local attackNum = CSResourceMgr.seekNodeByName(friend, "attackNum")
        CSResourceMgr.setLabelColorByNode(attackNum, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(attackNum,playerInfo.fightPoint)
        local lastTimeLabel = CSResourceMgr.seekNodeByName(friend, "lastTimeLabel")
        CSResourceMgr.setLabelColorByNode(lastTimeLabel, {r=71,g=96,b=103,a=255})
        CSResourceMgr.setLabelStringByNode(lastTimeLabel,"friendList4")
        local time = CSResourceMgr.seekNodeByName(friend, "time")
        CSResourceMgr.setLabelColorByNode(time, {r=71,g=96,b=103,a=255})
        CSResourceMgr.setLabelStringByNode(time,"1天前")
        if playerInfo.familyName and playerInfo.familyName~="" then
            local familyName = CSResourceMgr.seekNodeByName(friend, "familyName")
            CSResourceMgr.setLabelColorByNode(familyName, {r=255,g=255,b=255,a=255})
            CSResourceMgr.setLabelStringByNode(familyName,playerInfo.familyName,{r=0,g=0,b=0,a=255,w=1,s=1})
            CSResourceMgr.seekNodeByName(friend, "familyIcon"):loadTexture("Confraternity/icon_qizhi1_hz.png")
        else
            CSResourceMgr.seekNodeByName(friend, "familyBack"):setVisible(false)
        end

        CSResourceMgr.clickEventBindingByNode(friend,function()
            playerID = playerInfo.friendID
            curPlayerInfo = playerInfo
            NetInterface.sendWithBlock("GC_GetSingleFashionShow_Ack", function()
                local FashionShowSend = require("src.Net.Send.FashionShowSend")
                FashionShowSend.sendCG_GetSingleFashionShow_Req({charID = playerInfo.friendID})
                end)
        end)

        local likeBtn = CSResourceMgr.seekNodeByName(friend, "likeBtn")
        local likeIcon = CSResourceMgr.seekNodeByName(friend, "likeIcon")
 
        CSResourceMgr.seekNodeByName(friend, "back"):setColor({r=67,g=85,b=100})
        CSResourceMgr.seekNodeByName(friend, "headBack"):setColor({r=128,g=161,b=172})
        CSResourceMgr.seekNodeByName(friend, "zanBack"):setColor({r=128,g=161,b=172})
        CSResourceMgr.seekNodeByName(friend, "likeBack"):setColor({r=71,g=96,b=103})
        CSResourceMgr.seekNodeByName(friend, "attackBack"):setColor({r=71,g=96,b=103})
        CSResourceMgr.seekNodeByName(friend, "familyBack"):setColor({r=185,g=200,b=205})
        list:pushBackCustomItem(friend)

        friend:setScaleY(0)
        transition.scaleTo(friend, {scale=1, time=0.2})
    end

    for k,v in pairs(allFriendTable) do
        if v.inFashionShow and v.inFashionShow==1 then
            table.insert(funcTable,function()
                setFriend(v)
            end)
        end
    end

    UnblockLoader.load(funcTable, "SelectBeautyViewMgr.resetAllFriendInfo")
end

function SelectBeautyViewMgr.setAllFriendTable(friendTable)
    for k,v in pairs(friendTable) do
        local cjson = require("cjson")
        local friendInfo = cjson.decode(v)
        if friendInfo.needConfirm ~= 1 then
            table.insert(allFriendTable,friendInfo)
        end
    end
    if CSResourceMgr.getCsbObj(resNameG) then
        SelectBeautyViewMgr.resetAllFriendInfo()
    end
end

function SelectBeautyViewMgr.setLikeList(likeListS)
    local cjson = require("cjson")
    local likeListTable = cjson.decode(likeListS) or {}
    for k,v in pairs(likeListTable) do
        likeList[v.charID] = v.charID
    end
end

function SelectBeautyViewMgr.setLikePointRefreshTime()
    local refreshStep = SystemInfo.getGlobalConfigAddInfoByID(49).values[1] -- 刷新时间间隔 [秒]
    local stepNumMax  = SystemInfo.getGlobalConfigAddInfoByID(48).values[1]  -- 可移动步数上限
    
    local function refresh()
        local passTime = CharInfo.getServerTime() - likePointUpdateTime
        local stepAdded = math.floor( passTime/refreshStep )
        if likePoint >= stepNumMax then
            stepAdded = 0
            likePoint = stepNumMax
        else
            if likePoint + stepAdded >= stepNumMax then
                stepAdded = stepNumMax - likePoint
            end
        end
        likePoint = likePoint + stepAdded
        if stepAdded>0 then
            likePointUpdateTime = CharInfo.getServerTime()
        end
        CSResourceMgr.setLabelString(resName, "num3", likePoint.."/10")
        
        local CountDownSeconds = refreshStep - (passTime % refreshStep)
        local top = CSResourceMgr.getNodeByName(resName, "top")
        top:performWithDelay(function()
            refresh()
            end,CountDownSeconds)
    end

    if likePoint~= stepNumMax then
        refresh()
    end
end

return SelectBeautyViewMgr