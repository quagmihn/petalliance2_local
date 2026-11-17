local SurviveBattleViewMgr = {}

local resName = ""
local resNameBG = ""
SurviveBattleViewMgr.currfloor = 1 
SurviveBattleViewMgr.bossInfo = {}
SurviveBattleViewMgr.usedPets = {}
SurviveBattleViewMgr.maxFloor = 0
SurviveBattleViewMgr.selectedPet = {}
SurviveBattleViewMgr.ROW = 4
SurviveBattleViewMgr.LINE = 6
local labelRoleInfoWidth = 460
local petNodes = {}
local selectedPetIndex = 0
local petNodesPosY = 80
local selectedPetNode = nil
local surviveActiveInfo = nil
local npcNode = nil

local labelColor = {
    {r=254,g=234,b=  0,a=255},
    {r=119,g=204,b=245,a=255},
    {r=225,g=233,b=254,a=255},
    {r=165,g=243,b=255,a=255},
    {r=120,g=146,b=181,a=255},

    {r=255,g=255,b=255,a=255},
    {r=166,g=243,b=253,a=255},
}

local outlineColor = {
    {r=0,g=0,b=0,a=255,w=1,s=1},
    {r=0,g=0,b=0,a=255,w=2,s=1},
    {r=0,g=0,b=0,a=255,w=3,s=1},
}

function SurviveBattleViewMgr.checkIsSurviveBattleActive()
    if SurviveBattleViewMgr.checkIsActive() == true then
        npcNode = NpcMgr.addNPC(101, nil, nil, function ()
            SurviveBattleViewMgr.request()
        end)
    else
        if npcNode ~= nil then
            NpcMgr.moveNPC(npcNode.node)
            npcNode = nil
        end
    end
end

function SurviveBattleViewMgr.Init()
    resName = "Activity/SurviveBattle.csb"
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    SurviveBattleViewMgr.maxFloor = 10
    local value = SystemInfo.getGlobalConfigAddInfoByID(91)
    if value then
        SurviveBattleViewMgr.maxFloor = value.values[1]
    end

    local tabTable, activityParams = ActivityViewMgr.getActivitiesData()
    for k,v in pairs(tabTable) do
        for k1,v1 in pairs(v) do
            if v1.type == ActivityInfo.SurvivalBattleIntro then
                surviveActiveInfo = v1
                break
            end
        end
    end
end

function SurviveBattleViewMgr.hide()
    SurviveBattleViewMgr.hideSelectPetPage()
    UnblockLoader.cancel("SurviveBattleViewMgr")

    AnimationMgr.removeGafObjectByTag("Spine/activity/UI_shengcunzhan.png", "SurviveBattle")

    if PetEducationMgr.getTableLength(SurviveBattleViewMgr.bossInfo) > 0 then
        local pokeID = SurviveBattleViewMgr.bossInfo.pokeID
        local aniRes = PokemonInfo.getPokemonResByID(pokeID)
        AnimationMgr.removeGafObjectByTag(aniRes,"SurviveBattleBoss-"..pokeID)
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end

    CSResourceMgr.removeCSObjectByTag(resName)
    CSResourceMgr.removeCSObjectByTag(resNameBG, "SurviveBattleViewMgr")
    UIStack.pop("SurviveBattleViewMgr")
end

function SurviveBattleViewMgr.request()
    if not NetInterface.isConnect then
        return
    end
    local function requestBossInfo()
        local scene = SceneMgr.getRunningScene
        NetInterface.sendWithBlock("GC_GetSurvivalBattleData_Ack", function()
            local ActivitySend = require("src.Net.Send.ActivitySend")
            ActivitySend.sendCG_GetSurvivalBattleData_Req()
        end, function()
            local timePoints = SystemInfo.getGlobalConfigAddInfoByID(89).values
            local offsetTime = 3600 * timePoints[1]
            local dayDiff = CocosModuleMgr.getDayTimeDiff(CharInfo.GetSurvivalBattleTime(), CharInfo.getServerTime(), offsetTime)
            if dayDiff ~= 0 then
                SurviveBattleViewMgr.usedPets = {}
            end
            if PetEducationMgr.getTableLength(SurviveBattleViewMgr.bossInfo) > 0 then
                if SurviveBattleViewMgr.bossInfo.personal then
                    SurviveBattleViewMgr.bossInfo.personal.name = nil
                end
                SurviveBattleViewMgr.show(scene)
            end
        end, function(code)
            TipsMgr.showError(scene, code)
        end)
    end

    local function requestSurviveBattleFloor()
        NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
            local LoginSend = require("src.Net.Send.LoginSend")
            LoginSend.sendCG_GetCharacterValues_Req({
                "survivalBattleFloor",
                "survivalBattleTime",
                "getSurvivalTime"})
        end, function()
            SurviveBattleViewMgr.currfloor = CharInfo.getSurvivalBattleFloor()

            local timePoints = SystemInfo.getGlobalConfigAddInfoByID(89).values
            local offsetTime = 3600 * timePoints[1]
            local dayDiff = CocosModuleMgr.getDayTimeDiff(CharInfo.getSurvivalTime(), CharInfo.getServerTime(), offsetTime)
            if dayDiff == 0 then
                if SurviveBattleViewMgr.currfloor > SurviveBattleViewMgr.maxFloor then
                    SurviveBattleViewMgr.show(SceneMgr.getRunningScene)
                else
                    requestBossInfo()
                end
            else
                SurviveBattleViewMgr.currfloor = 1
                requestBossInfo()
            end
        end, function(code)
            -- StandardTipsMgr.show(1,"getPetEquip failed code="..code)
        end)
    end
    requestSurviveBattleFloor()
end

function SurviveBattleViewMgr.request2()
    SceneMgr.getRunningScene:performWithDelay(function ()
        SurviveBattleViewMgr.request()
    end, 0.3)
end

function SurviveBattleViewMgr.show(scene)
    UIStack.push("SurviveBattleViewMgr", SurviveBattleViewMgr.hide, true)

    local function loadCSB()
        local curLayerBG = CSResourceMgr.createRes(scene, resNameBG, "SurviveBattleViewMgr")
        curLayerBG:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "SurviveBattleViewMgr")

        local layer = CSResourceMgr.createRes(scene, resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName)
        CSResourceMgr.setRelativePosition(resName, 320, 480)

        local btnBG = CSResourceMgr.getNodeByName(resName, "btn_bg1")
        btnBG:setVisible(false)

        local btnClose = CSResourceMgr.getNodeByName(resName, "btn_close")
        CSResourceMgr.clickEventBindingByNode(btnClose,function() 
            SurviveBattleViewMgr.hide()
        end)

        local panel = CSResourceMgr.getNodeByName(resName, "panel")
        panel:setVisible(false)
    end

    local function loadUI()
        -- local atmosphere1    = CSResourceMgr.getNodeByName(resName, "pic_icon1")
        -- local atmosphere2    = CSResourceMgr.getNodeByName(resName, "pic_icon2")
        -- CSResourceMgr.setSpriteTextureByNode(atmosphere1, ActivityShopViewMgr.AtmospherePath[1])
        -- CSResourceMgr.setSpriteTextureByNode(atmosphere2, ActivityShopViewMgr.AtmospherePath[2])
        
        local btnClose       = CSResourceMgr.getNodeByName(resName, "btn_close")
        local labelTitle     = CSResourceMgr.getNodeByName(resName, "txt_title")
        local labelTimeTitle = CSResourceMgr.getNodeByName(resName, "txt_time_tilte")
        local btnRole        = CSResourceMgr.getNodeByName(resName, "btn_role")
        local labelRole      = CSResourceMgr.seekNodeByName(btnRole, "txt_role")
        local labelFloor     = CSResourceMgr.getNodeByName(resName, "txt_floor")
        local labelResTitle  = CSResourceMgr.getNodeByName(resName, "txt_res_title")
        local spriteRes      = CSResourceMgr.getNodeByName(resName, "pic_res")
        local labelRes       = CSResourceMgr.getNodeByName(resName, "txt_res")
        local labelDesc      = CSResourceMgr.getNodeByName(resName, "txt_desc")
        local maxFloor       = CSResourceMgr.getNodeByName(resName, "max_floor")
        local spriteFloor    = CSResourceMgr.seekNodeByName(maxFloor, "pic_floor")
        local labelMaxFloor  = CSResourceMgr.seekNodeByName(maxFloor, "txt_max_floor")
        local spriteBoss     = CSResourceMgr.getNodeByName(resName, "pic_boss")
        local btnChallenge   = CSResourceMgr.getNodeByName(resName, "btn_challenge")
        local labelChallenge = CSResourceMgr.seekNodeByName(btnChallenge, "txt_challenge")
        local spriteRole     = CSResourceMgr.getNodeByName(resName, "pic_b6")
        local labelRoleInfo  = CSResourceMgr.seekNodeByName(spriteRole, "txt_role_info")
        local btnCloseRole   = CSResourceMgr.seekNodeByName(spriteRole, "btn_close_role")
        local labelCloseRole = CSResourceMgr.seekNodeByName(btnCloseRole, "txt_close_role")
        local spriteBg5      = CSResourceMgr.getNodeByName(resName, "pic_bg5")
        local spriteFC       = CSResourceMgr.getNodeByName(resName, "pic_atk")
        local labelFC        = CSResourceMgr.getNodeByName(resName, "txt_atk")

        local strFloor = CocosModuleMgr.createStringWithFormat({"activity85", SurviveBattleViewMgr.currfloor})
        CSResourceMgr.setLabelStringByNode(labelTitle, "activity82", outlineColor[1])
        CSResourceMgr.setLabelStringByNode(labelTimeTitle, "activity83", outlineColor[1])
        CSResourceMgr.setLabelStringByNode(labelRole, "activity84", outlineColor[1])
        CSResourceMgr.setLabelStringByNode(labelFloor, strFloor, nil)
        CSResourceMgr.setLabelStringByNode(labelResTitle, "activity86", outlineColor[1])
        CSResourceMgr.setLabelStringByNode(labelChallenge, "activity87", outlineColor[1])
        CSResourceMgr.setLabelStringByNode(labelDesc, "activity88", outlineColor[1])
        CSResourceMgr.setLabelStringByNode(labelCloseRole, "activity89", outlineColor[1])
        CSResourceMgr.setLabelStringByNode(labelMaxFloor, "activity90", outlineColor[1])

        CSResourceMgr.setLabelColorByNode(labelTitle,       labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelTimeTitle,   labelColor[2])
        CSResourceMgr.setLabelColorByNode(labelRole,        labelColor[3])
        CSResourceMgr.setLabelColorByNode(labelFloor,       labelColor[4])
        CSResourceMgr.setLabelColorByNode(labelResTitle,    labelColor[4])
        CSResourceMgr.setLabelColorByNode(labelRes,         labelColor[4])
        CSResourceMgr.setLabelColorByNode(labelChallenge,   labelColor[6])
        CSResourceMgr.setLabelColorByNode(labelDesc,        labelColor[5])
        CSResourceMgr.setLabelColorByNode(labelCloseRole,   labelColor[6])
        CSResourceMgr.setLabelColorByNode(labelMaxFloor,    labelColor[7])

        local str = "activity91"
        CSResourceMgr.clickEventBindingByNode(btnRole, function ()
            local richLabel = CocosModuleMgr.createRichLabel(labelRoleInfo, str, 24, "cuyuan_GBK.ttf", labelRoleInfoWidth)
            richLabel:setAnchorPoint(0, 1)
            richLabel:setPositionY(0)
            spriteRole:setVisible(true)
            btnClose:setVisible(false)
        end)

        CSResourceMgr.clickEventBindingByNode(btnCloseRole, function ()
            spriteRole:setVisible(false)
            btnClose:setVisible(true)
        end)

        CSResourceMgr.clickEventBindingByNode(btnChallenge, function ()
            if SurviveBattleViewMgr.checkIsActive() == false then
                StandardTipsMgr.show(1, "activity92")
            else
                SurviveBattleViewMgr.showSelectPetPage()
            end
        end)

        local function setAnimationNodesVisible(visible)
            labelFloor:setVisible(visible)
            labelResTitle:setVisible(visible)
            spriteRes:setVisible(visible)
            labelRes:setVisible(visible)
            spriteBg5:setVisible(visible)
            btnChallenge:setVisible(visible)
            spriteFC:setVisible(visible)
            labelFC:setVisible(visible)
        end
        if SurviveBattleViewMgr.currfloor > SurviveBattleViewMgr.maxFloor then--max
            maxFloor:setVisible(true)
            setAnimationNodesVisible(false)
        else
            spriteBoss:setPositionY(406)
            maxFloor:setVisible(false)
            setAnimationNodesVisible(true)
            local pokeID = SurviveBattleViewMgr.bossInfo.pokeID
            local aniRes = PokemonInfo.getPokemonResByID(pokeID)
            local aniAni = AnimationMgr.createAni(spriteBoss, aniRes, 0, 0, "SurviveBattleBoss-"..pokeID)
            AnimationMgr.playAni(aniRes, "idle", true, "SurviveBattleBoss-"..pokeID)
            aniAni:setScale(0.8)
            local skin = SurviveBattleViewMgr.bossInfo.skin
            AnimationMgr.setSkin(aniRes, skin, "SurviveBattleBoss-"..pokeID)

            local awardInfo = ActivityInfo.getSurvivalBattleAwardInfoById(SurviveBattleViewMgr.currfloor)
            local awardList = awardInfo.awardList[1]--itemID,count
            local num = awardList.count
            CSResourceMgr.setLabelStringByNode(labelRes, num, outlineColor[1])

            CSResourceMgr.setLabelStringByNode(labelFC, SurviveBattleViewMgr.bossInfo.fc, outlineColor[1])
        end

        SurviveBattleViewMgr.setTimeLeft()
        SurviveBattleViewMgr.playEffect(spriteBg5)
    end

    local function playAction()
        local panel = CSResourceMgr.getNodeByName(resName, "panel")
        panel:setVisible(true)
        CocosModuleMgr.showUIAnimation(panel, "down")
    end

    local funcTable = {loadCSB, loadUI, playAction}
    UnblockLoader.load(funcTable, "PetEatPetViewMgr")
end

function SurviveBattleViewMgr.setTimeLeft()
    local labelTime = CSResourceMgr.getNodeByName(resName, "txt_time")
    local loginTime = CharInfo.getServerTime()
    local lastTime = surviveActiveInfo.beginTime + surviveActiveInfo.lastTime
    local isPlat = true

    if platform ~= "windows" then
        if surviveActiveInfo.plat ~= "all" then
            if surviveActiveInfo.plat ~= platform then
                isPlat = false
            end
        end
    end
    if loginTime <= lastTime and loginTime >= surviveActiveInfo.beginTime and isPlat then
        local timeVec,str = ActivityHalloweenViewMgr.turnTimeDiff(lastTime)
        local t = 0
        if #timeVec > 1 then
            t = tonumber(timeVec[1]) * 10 + tonumber(timeVec[2])
        else
            t = tonumber(timeVec[1])
        end
        CSResourceMgr.setLabelStringByNode(labelTime, t.." "..str, outlineColor[1])
        CSResourceMgr.setLabelColorByNode(labelTime, labelColor[1])
		if LuaSqlite.LANG_TYPE == 6 then
			labelTime:setPositionX(labelTime:getPositionX()+65)
		end
    end
end

function SurviveBattleViewMgr.checkIsActive()
    if not surviveActiveInfo or not surviveActiveInfo.beginTime or not surviveActiveInfo.lastTime then
        return false
    end
    local loginTime = CharInfo.getServerTime()
    local lastTime = surviveActiveInfo.beginTime + surviveActiveInfo.lastTime
    local isPlat = true

    if platform ~= "windows" then
        if surviveActiveInfo.plat ~= "all" then
            if surviveActiveInfo.plat ~= platform then
                isPlat = false
            end
        end
    end
    if loginTime <= lastTime and loginTime >= surviveActiveInfo.beginTime and isPlat then
        return true
    end
    return false
end

function SurviveBattleViewMgr.getCurrMyPets()
    local ret = {}
    local helpRet = {}
    local scienceValue = ScienceInfo.getScienceAttrsTable()
    for k,v in pairs(PokemonInfo.getPetArmy(PetFormationMgr.getCurTab())) do
        local petInfo = clone(PokemonInfo.getPetInfoByObjID(v))
        petInfo.hp = petInfo.hpmax
        table.insert(ret, petInfo)
    end
    for k,v in pairs(PokemonInfo.getPetHelpArmy()) do
        local petInfo = PokemonInfo.getPetInfoByObjID(v)
        table.insert(helpRet, petInfo)
    end
    return ret, helpRet
end

function SurviveBattleViewMgr.getBattlePets()
    local ret = {}
    local helpRet = {}
    table.insert(ret, SurviveBattleViewMgr.selectedPet)
    return ret, helpRet
end

function SurviveBattleViewMgr.getEnemyPets()
    local ret = {}
    local helpRet = {}
    table.insert(ret, SurviveBattleViewMgr.bossInfo)
    return ret, helpRet
end

function SurviveBattleViewMgr.sendSurviveBattleResult(dmg, objID)
    if SurviveBattleViewMgr.checkIsActive() == false then
        StandardTipsMgr.show(1, "activity92")
        return
    end
    NetInterface.sendWithBlock("GC_SurvivalBattleEnd_Ack", function()
        local ActivitySend = require("src.Net.Send.ActivitySend")
        ActivitySend.sendCG_SurvivalBattleEnd_Req({
            damage = dmg,
            usePetID = objID,
        })
    end, function()
        SurviveBattleViewMgr.selectedPet = {}
        selectedPetIndex = 0
        selectedPetNode = nil
        MapSeekerMgr.setSeekFunc(SurviveBattleViewMgr.request2)
    end, function(code)
        print("GC_SurvivalBattleEnd_Ack error code : ", code)
    end)
end

function SurviveBattleViewMgr.playEffect(parent)
    local effAni = AnimationMgr.createAni(parent, "Spine/activity/UI_shengcunzhan.png", 
            parent:getContentSize().width/2, parent:getContentSize().height/2, "SurviveBattle")
    effAni:setPosition(effAni:getPositionX(), effAni:getPositionY())
    AnimationMgr.playAni(effAni.res, "animation", true, "SurviveBattle")
end

--选择出战宠
function SurviveBattleViewMgr.hideSelectPetPage()
    UnblockLoader.cancel("SurviveBattleViewMgr_SelectPetPage")

    SurviveBattleViewMgr.selectedPet = {}
    selectedPetIndex = 0
    selectedPetNode = nil
    local panel2 = CSResourceMgr.getNodeByName(resName, "panel_2")
    panel2:setVisible(false)
    local btnBG2 = CSResourceMgr.getNodeByName(resName, "btn_bg2")
    btnBG2:setVisible(false)

    UIStack.pop("SurviveBattleViewMgr_SelectPetPage")
end

function SurviveBattleViewMgr.showSelectPetPage()
    UIStack.push("SurviveBattleViewMgr_SelectPetPage", SurviveBattleViewMgr.hideSelectPetPage, false)

    local panel2 = CSResourceMgr.getNodeByName(resName, "panel_2")
    local btnBG2 = CSResourceMgr.getNodeByName(resName, "btn_bg2")
    local function loadCSB()
        local btnClose = CSResourceMgr.getNodeByName(resName, "btn_close2")
        CSResourceMgr.clickEventBindingByNode(btnClose, function() 
            SurviveBattleViewMgr.hideSelectPetPage()
        end)
        panel2:setVisible(false)
        btnBG2:setVisible(true)
    end

    local function getPetList()
        local petList = {}
        local tempPetList = {}
        local allPets = clone(PetListMgr.sortPetList(PokemonInfo.getAllPets()))
        for k,v in pairs(allPets) do
            v.hp = v.hpmax
            if v.level >= CharInfo.getLevel() * 0.5 then
                v.haveBattle = false
                for k1,v1 in pairs(SurviveBattleViewMgr.usedPets) do
                    if v.objID == v1 then
                        v.haveBattle = true
                    end
                end
                table.insert(tempPetList, v)
            end
        end
        for k,v in pairs(tempPetList) do
            if v.haveBattle == false then
                table.insert(petList, v)
            end
        end
        for k,v in pairs(tempPetList) do
            if v.haveBattle == true then
                table.insert(petList, v)
            end
        end
        return petList
    end

    local function loadPetList()
        local list = CSResourceMgr.getNodeByName(resName, "list")
        local panel = CSResourceMgr.getNodeByName(resName, "parent")
        local hook = CSResourceMgr.getNodeByName(resName, {"parent","hook"})
        local black = CSResourceMgr.getNodeByName(resName, {"parent","pic_black"})
        local fc = CSResourceMgr.getNodeByName(resName, {"parent","pic_fc"})
        local showPets = getPetList()
        local totalLine = math.ceil(#showPets / SurviveBattleViewMgr.ROW)
        local showCnt = SurviveBattleViewMgr.ROW * SurviveBattleViewMgr.LINE
        local showLine = math.min(SurviveBattleViewMgr.LINE, totalLine)
        local diffX = 124
        local panelNodes = {}
        list:removeAllItems()
        for i = 1, showLine do
            panelNodes[i] = panel:clone()
            list:pushBackCustomItem(panelNodes[i])
        end
        local index = 1
        for k,v in pairs(showPets) do
            if index > showCnt then break end
            local line = math.ceil(index / SurviveBattleViewMgr.ROW)
            local row = index % SurviveBattleViewMgr.ROW == 0 and SurviveBattleViewMgr.ROW or index % SurviveBattleViewMgr.ROW
            local petNode = BattleFuncMgr.startCreatePetCard(v, 3, true)

            if v.skin ~= 0 then
                CSResourceMgr.setLabelColorByNode(petNode.level, {r=96,g=255,b=0,a=255})
            end
            petNodes[index] = petNode.button
            petNodes[index]:setVisible(true)
            petNodes[index]:setScale(1.3, 1.3)
            petNodes[index]:addTo(panelNodes[line])
            petNodes[index]:setPosition(petNodes[index]:getPositionX() + (row - 1) * diffX + 72, petNodesPosY)

            petNodes[index].sel = hook:clone()
            petNodes[index].sel:addTo(petNodes[index])
            petNodes[index].sel:setPosition(70,105)
            petNodes[index].sel:setScale(0.9)

            petNodes[index].black = black:clone()
            petNodes[index].black:addTo(petNodes[index])
            petNodes[index].black:setPosition(45,75)
            -- petNodes[index].black:setScale(1.1)
            petNodes[index].black:setColor({r=0,g=0,b=0})
            petNodes[index].black:setOpacity(153)
            petNodes[index].black:setVisible(v.haveBattle)
            petNodes[index].black:setContentSize(94, 136)
            petNodes[index].black:setLocalZOrder(2)

            petNodes[index].fc = fc:clone()
            petNodes[index].fc:addTo(petNodes[index])
            petNodes[index].fc:setPosition(30,130)
            petNodes[index].fc:setVisible(true)

            local labelFC = CSResourceMgr.seekNodeByName(petNodes[index].fc, "txt_fc")
            CSResourceMgr.setLabelStringByNode(labelFC, v.fc, outlineColor[1])

            if not panelNodes[line].button then
                panelNodes[line].button = {}
            end
            panelNodes[line].button[row] = petNodes[index]

            CSResourceMgr.clickEventBindingByNode(petNodes[index], function ()
                if v.haveBattle == true then
                    StandardTipsMgr.show(1, "activity93")
                else
                    if selectedPetNode then
                        selectedPetNode.sel:setVisible(false)
                    end
                    panelNodes[line].button[row].sel:setVisible(true)
                    selectedPetNode = panelNodes[line].button[row]
                    SurviveBattleViewMgr.selectedPet = v
                end
            end, 3)
            index = index + 1
        end
        BattleFuncMgr.endCreatePetCard()

        HighPerformList.makeHighPerFormVerticalList(list, SurviveBattleViewMgr.LINE, 0, SurviveBattleViewMgr.ROW, 200, 190, showPets,
            function(item, currentIndex)
                local row = currentIndex % SurviveBattleViewMgr.ROW == 0 and SurviveBattleViewMgr.ROW or currentIndex % SurviveBattleViewMgr.ROW
                for i=1,SurviveBattleViewMgr.ROW do
                    if currentIndex + i - 1 <= #showPets then--防止越界
                        item.button[i]:setVisible(true)
                        PetCommonListViewMgr.updateCard(showPets[currentIndex+i-1], item.button[i])
                        item.button[i].sel:setVisible(currentIndex + i - 1 == selectedPetIndex)
                        item.button[i].black:setVisible(showPets[currentIndex+i-1].haveBattle)

                        local labelFC = CSResourceMgr.seekNodeByName(item.button[i].fc, "txt_fc")
                        CSResourceMgr.setLabelStringByNode(labelFC, showPets[currentIndex+i-1].fc, outlineColor[1])
                    else
                        item.button[i]:setVisible(false)
                    end
                    CSResourceMgr.clickEventBindingByNode(item.button[i], function ()
                        if showPets[currentIndex+i-1].haveBattle == true then
                            StandardTipsMgr.show(1, "activity93")
                        else
                            if selectedPetNode then
                                selectedPetNode.sel:setVisible(false)
                            end
                            item.button[i].sel:setVisible(true)
                            selectedPetIndex = currentIndex + i - 1
                            selectedPetNode = item.button[i]
                            SurviveBattleViewMgr.selectedPet = showPets[currentIndex+i-1]
                        end
                    end,3)
                end
            end)
    end

    local function loadUI()
        local labelTitle = CSResourceMgr.getNodeByName(resName, "txt_battle_title")
        local labelDesc = CSResourceMgr.getNodeByName(resName, "txt_information")
        local btnBattle = CSResourceMgr.getNodeByName(resName, "btn_battle")
        local labelBattle = CSResourceMgr.getNodeByName(resName, "txt_battle")

        CSResourceMgr.setLabelStringByNode(labelTitle, "activity94", outlineColor[1])
        CSResourceMgr.setLabelStringByNode(labelDesc, "activity95", outlineColor[1])
        CSResourceMgr.setLabelStringByNode(labelBattle, "activity96", outlineColor[1])

        CSResourceMgr.setLabelColorByNode(labelTitle, labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelDesc, labelColor[5])
        CSResourceMgr.setLabelColorByNode(labelBattle, labelColor[6])

        CSResourceMgr.clickEventBindingByNode(btnBattle, function ()
            if PetEducationMgr.getTableLength(SurviveBattleViewMgr.selectedPet) > 0 then
                local myPets = {}
                local enemyPets = {}
                myPets[OUTPETS], myPets[INPETS] = SurviveBattleViewMgr.getBattlePets()
                enemyPets[OUTPETS], enemyPets[INPETS] = SurviveBattleViewMgr.getEnemyPets()
                BattleMapMgr.setArenaBattle(myPets, enemyPets, function(detail)
                    if detail.result == nil then
                        SurviveBattleViewMgr.sendSurviveBattleResult(0, SurviveBattleViewMgr.selectedPet.objID)
                    elseif detail.result == PLAYER_WIN then
                        SurviveBattleViewMgr.sendSurviveBattleResult(SurviveBattleViewMgr.bossInfo.hp - detail.enemy.hp[1], SurviveBattleViewMgr.selectedPet.objID)
                    else
                        -- MapSeekerMgr.setSeekFunc(SurviveBattleViewMgr.request)
                        SurviveBattleViewMgr.sendSurviveBattleResult(SurviveBattleViewMgr.bossInfo.hp - detail.enemy.hp[1], SurviveBattleViewMgr.selectedPet.objID)
                    end
                end)
                BattleCotroller.setEnterBattleScene(false)
            else
                --请先选择出战宠物
                StandardTipsMgr.show(1, "activity97")
            end
        end)
    end

    local function playAction()
        panel2:setVisible(true)
        CocosModuleMgr.showUIAnimation(panel2, "down")
    end

    local funcTable = {loadCSB, loadPetList, loadUI, playAction}
    UnblockLoader.load(funcTable, "SurviveBattleViewMgr_SelectPetPage")
end

return SurviveBattleViewMgr