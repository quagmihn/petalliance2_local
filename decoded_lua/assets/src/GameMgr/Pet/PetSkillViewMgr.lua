local PetSkillViewMgr = {}

local resName = {}
local resNameBattle = {}

local irareString = {}
local oldSkillInfo = nil

PetSkillViewMgr.closeCallback = nil

local labelColor = {
    {r=255,g=255,b=255,a=255},  --1
    {r=0,g=0,b=0,a=255},        --2
    {r=144,g=238,b=255,a=255},  --3
    {r=112,g=131,b=158,a=255},  --4
    {r=217,g=234,b=255,a=255},  --5
    {r=227,g=233,b=255,a=255},  --6技能升级按钮
    {r=255,g=72,b=0,a=255},     --7红
    {r=255,g=0,b=0,a=255},      --8大红
    {r=0,g=255,b=0,a=255},      --9绿
}

local outlineColor = {
    {r=0,g=0,b=0,a=255,w=1,s=1},
    {r=12,g=27,b=38,a=255,w=1,s=2},
}

-- local attrTitle = {"train72", "train73", "train74", "train75"}--类型、分类、命中、威力
local attrTitle = {"train75","train111","train112","train113"}--威力:、等级:、稀有度:、系别:

PetSkillViewMgr.skillRareTable = {
    [1] = "train143",--B
    [2] = "train144",--A
    [3] = "train145",--S
}

PetSkillViewMgr.skillTypeTable = {
    [0] = "skillType0",--0主动
    [1] = "skillType1",
    [2] = "skillType2",
    [3] = "skillType3",
    [4] = "skillType4",
    [5] = "skillType5",
    [6] = "skillType6",
    [7] = "skillType7",
    [8] = "skillType8",
}

local skillBackGroundPath = {
    "UI/CommonFiles/fight_skill_base_01.png",           --0主动
    "UI/CommonFiles/fight_skill_base_01.png",           --1奥义
    "UI/CommonFiles/fight_skill_base_01.png",           --2特性
    "UI/CommonFiles/fight_skill_base_01.png",           --3物理
    "UI/CommonFiles/fight_skill_base_01.png",           --4魔法
    "UI/CommonFiles/fight_skill_base_01.png",           --5变化
    "UI/CommonFiles/skill_passive_base_nomal.png",      --6被动
    "UI/CommonFiles/skill_aid_base_normal_01.png",      --7援助
    "UI/CommonFiles/fight_assistance_skill_base.png",   --8天赋
}

local skillLvIconTable = {
    "UI/CommonFiles/develop_effect_icon_lv1.png",
    "UI/CommonFiles/develop_effect_icon_lv2.png",
    "UI/CommonFiles/develop_effect_icon_lv3.png",
    "UI/CommonFiles/develop_effect_icon_lv4.png",
    "UI/CommonFiles/develop_effect_icon_lv5.png",
}

function PetSkillViewMgr.Init()
    resName = {
        "Pet/Education/SkillInfoViewNew.csb",
        "Pet/Education/SkillLvUpNew.csb",
        "Pet/Education/SkillExchangeNew.csb",
    }
    resNameBattle = {
        "Pet/Education/BattleSkillInfoViewNew.csb",
    }
    irareString = {
        [0] = "Pet/Education/c.png",
        [1] = "Pet/Education/b.png",
        [2] = "Pet/Education/a.png",
        [3] = "Pet/Education/s.png",
        [4] = "Pet/Education/2s.png",
    }
    PetSkillViewMgr.closeCallback = {}
    oldSkillInfo = nil
end

local function setLabel(label,string,outline,outlinewidth,textColor,maxwidth)
    CSResourceMgr.setLabelColorByNode(label,textColor)
    CSResourceMgr.setLabelStringByNode(label,string,outline)
    if outlinewidth~=nil  then
        label:enableOutline(outline, outlinewidth)
    end

    if maxwidth~=nil then
        CSResourceMgr.setLabelMaxWidthByNode(label,maxwidth)
    end
end

function PetSkillViewMgr.getSkillInfoTableBySkillInfo(skillInfo)
    local skillInfoTable = {}
    skillInfoTable.name  = skillInfo.name
    skillInfoTable.power = skillInfo.power
    skillInfoTable.level = (skillInfo.id % 5 == 0) and 5 or (skillInfo.id % 5)
    skillInfoTable.rare  = irareString[skillInfo.airpower-1]
    skillInfoTable.attr  = "UI/CommonFiles/"..skillInfo.skillAtt..".png"--火、水
    skillInfoTable.typeA = skillInfo.skill_A_Type--技能底板
    skillInfoTable.typeB = skillInfo.skill_B_Type--物理、魔法
    skillInfoTable.desc = skillInfo.desc
    local translation = LuaSqlite.getLanguageByKey(skillInfo.desc)
    if translation == "" or translation == skillInfo.desc then
        local descriptions = {}
        for _, tag in ipairs(skillInfo.tags or {}) do
            local description = skillInfo.des[tag.instance.id]
            if type(description) == "string" and description ~= "" then
                local sourceKey = tag.instance.descs and tag.instance.descs[1]
                if description ~= sourceKey then
                    table.insert(descriptions, description)
                end
            end
        end
        if #descriptions > 0 then skillInfoTable.desc = table.concat(descriptions, "\n") end
    end
    skillInfoTable.cost  = skillInfo.energy--消耗 
    skillInfoTable.icon  = skillInfo.icon and "Battle/skillIcon/"..skillInfo.icon..".png" or "empty.png"
    return skillInfoTable
end

function PetSkillViewMgr.showSkillInfoPage(skillInfo, skillIndex, skillType, objID, closeCallback)--skillType:1.主动 2.被动
    UIStack.push("PetSkillViewMgr.skillPage",PetSkillViewMgr.hideSkillInfoPage,false)
    PetSkillViewMgr.closeCallback[1] = closeCallback
    local sInfo = PetSkillViewMgr.getSkillInfoTableBySkillInfo(skillInfo)
    local panel

    --阿杜修改英文版
    if true then
        resName[1] = "Pet/Education/SkillInfoViewUS.csb"
    end
    local function loadCSB()
        local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, resName[1])
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setFullScreen(resName[1])
        CSResourceMgr.setRelativePosition(resName[1], 320, 480)
        CSResourceMgr.clickEventBinding(resName[1], "btn_close", function()
            PetSkillViewMgr.hideSkillInfoPage()
        end)
        panel = CSResourceMgr.getNodeByName(resName[1], "panel")
        panel:setVisible(false)

        local btn = CSResourceMgr.getNodeByName(resName[1], "btn")
        local diff = CocosModuleMgr.getScreenSizeDiff()
        ViewMgrUtils.vFitStretch(diff, {btn})
    end

    local function loadUI()
        local title     = CSResourceMgr.seekNodeByName(panel, "title")
        local attTitle  = CSResourceMgr.seekNodeByName(panel, "skill_att_title")
        local infoTitle = CSResourceMgr.seekNodeByName(panel, "skill_info_title")
        local skillNode = CSResourceMgr.seekNodeByName(panel, "skill_node")

        PetSkillIconMgr.createPetSkillIcon(skillNode, skillInfo)

        for i = 1, #attrTitle do
            local label = CSResourceMgr.seekNodeByName(panel, "label_"..i)
            if skillType == 2 and i == 1 then
                CSResourceMgr.setLabelStringByNode(label, "triggerTiming", outlineColor[2], nil, 90)
            else
                CSResourceMgr.setLabelStringByNode(label, attrTitle[i], outlineColor[2], nil, 100)
            end
            CSResourceMgr.setLabelColorByNode(label, labelColor[3])
        end

        CSResourceMgr.setLabelStringByNode(title, "train45", {r=0,g=0,b=0,a=255,w=1,s=2}, 1, 264)
        CSResourceMgr.setLabelStringByNode(attTitle, "train77", {r=0,g=0,b=0,a=255,w=1,s=2}, 1, 110)
        CSResourceMgr.setLabelStringByNode(infoTitle, "train78", {r=0,g=0,b=0,a=255,w=1,s=2}, 1, 110)

        CSResourceMgr.setLabelColorByNode(title, labelColor[3])
        CSResourceMgr.setLabelColorByNode(attTitle, labelColor[3])
        CSResourceMgr.setLabelColorByNode(infoTitle, labelColor[3])

        local skillSpriteTable = {skillLvIconTable[sInfo.level], sInfo.rare, sInfo.attr}
        for i = 1, #skillSpriteTable do
            local sprite = CSResourceMgr.seekNodeByName(panel, "sprite_"..i)
            CSResourceMgr.setSpriteTextureByNode(sprite, skillSpriteTable[i])
        end

        local skillName  = CSResourceMgr.seekNodeByName(panel, "skill_name")
        local skillDesc  = CSResourceMgr.seekNodeByName(panel, "skill_desc")
        local skillPower = CSResourceMgr.seekNodeByName(panel, "label_5")

        skillName:setPositionX(sInfo.typeA == 1 and 134 or 124)

        CSResourceMgr.setLabelStringByNode(skillName, sInfo.name, outlineColor[1], nil, 100)
        if skillType == 2 then
            local triggerTimingStr = PetSkillViewMgr.getPaSkillTiming(skillInfo)
            CSResourceMgr.setLabelStringByNode(skillPower, triggerTimingStr, outlineColor[1], nil, 168)
        else
            CSResourceMgr.setLabelStringByNode(skillPower, sInfo.power, outlineColor[1], nil, 168)
        end
        CSResourceMgr.setLabelStringByNode(skillDesc, sInfo.desc)

        CSResourceMgr.setLabelColorByNode(skillPower, labelColor[5])
        CSResourceMgr.setLabelColorByNode(skillDesc, labelColor[5])
    end

    local function loadBtn()
        local btnExchange = CSResourceMgr.seekNodeByName(panel, "btn_exchange")
        local btnLvUp = CSResourceMgr.seekNodeByName(panel, "btn_lvup")
        local strExchange = CSResourceMgr.seekNodeByName(btnExchange, "str")
        CSResourceMgr.setLabelStringByNode(strExchange, "train46", outlineColor[1], nil, 154)

        local btnCanExchange = sInfo.typeA ~= 7 and sInfo.typeA ~= 8 
        local btnEnable = CharInfo.get().local_freedom == true or GameGuideMgr.checkGuideFinishByID(10066)
        CSResourceMgr.setButtonEnabledByNode(btnExchange, btnEnable and btnCanExchange == true)
        CSResourceMgr.setButtonEnabledByNode(btnLvUp, btnEnable)

        local petInfo = PokemonInfo.getPetInfoByObjID(objID)
        local info = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
        local itemInfoTable = skillType == 2 and PetSkillViewMgr.getPaExchangeSkills(petInfo, skillIndex-4) or 
                                                    PetSkillViewMgr.getExchangeSkills(petInfo, skillIndex)
        CSResourceMgr.clickEventBindingByNode(btnExchange, function ()
            PetSkillViewMgr.hideSkillInfoPage()
            PetSkillViewMgr.showSkillExchangePage(skillInfo, skillIndex, skillType, objID)
        end, 3)

        
        local strLvUp = CSResourceMgr.seekNodeByName(btnLvUp, "str")
        CSResourceMgr.setLabelStringByNode(strLvUp, "train47", outlineColor[1], nil, 264)
        local btnLvUpEnable = false
        if skillInfo.id then
            if skillInfo.id ~= 0 then
                if skillInfo.id % 10 ~= 5 then--skillPresupposed 下一级ID
                    btnLvUpEnable = true
                end
            end
        end
        CSResourceMgr.clickEventBindingByNode(btnLvUp, function ()
            if btnLvUpEnable == false then
                DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 1, "train117")
                return
            end
            PetSkillViewMgr.hideSkillInfoPage()
            PetSkillViewMgr.showSkillLvUpPage(skillInfo, skillIndex, skillType, objID, function ()
                local pInfo = PokemonInfo.getPetInfoByObjID(objID)
                local skillID = skillType == 1 and pInfo.skills[skillIndex] or pInfo.paSkills[skillIndex-4]["paSkillID"]
                local sInfo = PokemonInfo.getPetSkillInfoById(skillID)
                PetSkillViewMgr.showSkillInfoPage(sInfo, skillIndex, skillType, objID, closeCallback)
            end)
        end, 3)
        CSResourceMgr.setButtonEnabledByNode(btnLvUp, not PokemonInfo.isPetMaterial(petInfo.pokeID))
    end

    local function loadTipsUI()
        local list = CSResourceMgr.getNodeByName(resName[1], "list")
        -- local index = 1
        skillInfo = PokemonInfo.getPetSkillInfoById(skillInfo.id)
        local skillLv = skillInfo.id % 10
        local tagsTable = PetSkillViewMgr.sortSkillTips(skillInfo)
        -- for k,v in pairs(skillInfo.skillTags) do
        for k,v in pairs(tagsTable) do
            local skillTagInfo = BattleInfo.getSkillTagInfoByID(v.id)
            local node = CSResourceMgr.getNodeByName(resName[1], "attr_node"):clone()
            list:pushBackCustomItem(node)
            local name = CSResourceMgr.seekNodeByName(node, "attr_name")
            CSResourceMgr.setLabelStringByNode(name, skillTagInfo.name, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 108)
            CSResourceMgr.setLabelColorByNode(name, labelColor[5])
            local info = CSResourceMgr.seekNodeByName(node, "attr_info")
            local desc = skillInfo.des[v.id]

            local desc,isLocked = PetSkillViewMgr.getSortedSkillTipsInfo(skillInfo, skillType, v, desc)
            local lColor = isLocked == true and labelColor[8] or labelColor[5]
            setLabel(info,desc,nil,nil,lColor,330)

            info:setAnchorPoint(0, 0.5)
            -- star
            -- local starCnt = skillInfo.skillTags[index].powers[skillLv]
            -- local maxStarCnt = skillInfo.skillTags[index].powers[5]
            local starCnt = v.powers[skillLv]
            local maxStarCnt = v.powers[5]
            for i=1,5 do
                local star = CSResourceMgr.seekNodeByName(node, "star_"..i)
                star:setVisible(maxStarCnt >= i)
                if starCnt >= i then
                    CSResourceMgr.setSpriteTextureByNode(star, "Pet/Education/xing.png")
                end
            end
            -- index = index + 1
        end
    end

    local function playAction()
        panel:setVisible(true)
        CocosModuleMgr.showUIAnimation(panel, "down")
    end

    local funcTable = {loadCSB, loadUI, loadBtn, loadTipsUI, playAction}
    UnblockLoader.load(funcTable, "skillInfoPage")
end

function PetSkillViewMgr.showSkillExchangePage(skillInfo, skillIndex, skillType, objID, closeCallback)
    UIStack.push("PetSkillViewMgr.skillExchangePage",PetSkillViewMgr.hideSkillExchangePage,false)
    PetSkillViewMgr.closeCallback[3] = closeCallback
    local panel,skillNode2,selectedSkillInfo,cloneNode
    local function loadCSB()
        local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, resName[3])
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setFullScreen(resName[3])
        CSResourceMgr.setRelativePosition(resName[3], 320, 480)
        CSResourceMgr.clickEventBinding(resName[3], "btn_close", function()
            PetSkillViewMgr.hideSkillExchangePage()
        end)
        panel = CSResourceMgr.getNodeByName(resName[3], "panel")
        panel:setVisible(false)

        local btn = CSResourceMgr.getNodeByName(resName[3], "btn")
        local diff = CocosModuleMgr.getScreenSizeDiff()
        ViewMgrUtils.vFitStretch(diff, {btn})
    end

    local function showTipInfo(parentNode, node, index, string, isRed)
        local btnTips = CSResourceMgr.getNodeByName(resName[3], "tips")
        cloneNode = CSResourceMgr.getNodeByName(resName[3], "tips1"):clone()
        local str = CSResourceMgr.seekNodeByName(cloneNode, "str")
        local up = CSResourceMgr.seekNodeByName(cloneNode, "up")
        local child = CSResourceMgr.seekNodeByName(parentNode, "child")
        local tipsBG = CSResourceMgr.getNodeByName(resName[3], "tips")

        local pos = child:convertToWorldSpace(cc.p(node:getPositionX(), node:getPositionY()))
        cloneNode:addTo(SceneMgr.getRunningScene)
        cloneNode:setPosition(pos.x, pos.y + 30)
        local idx = index % 3 == 0 and 3 or index % 3
        up:setPositionX(100 - (idx - 1) * 100)
        btnTips:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        cloneNode:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)

        btnTips:setVisible(true)
        cloneNode:setVisible(true)
        CSResourceMgr.setLabelStringByNode(str, string, {r=0,g=0,b=0,a=255,w=1,s=1})
        CSResourceMgr.setLabelColorByNode(str, isRed == true and {r=255,g=0,b=0,a=255} or {r=217,g=234,b=255,a=255})
    end

    local function destroyTipInfo(node)
        local btnTips = CSResourceMgr.getNodeByName(resName[3], "tips")
        if btnTips:isVisible() == true then
            cloneNode:removeFromParent()
            btnTips:setVisible(false)
        end
    end

    local function hideAllTips(node)
        for i=1,5 do
            CSResourceMgr.seekNodeByName(node, "btn_node"..i):setVisible(false)
        end
    end

    local function loadTipsUI(node, skillInfo)
        hideAllTips(node)
        local skillLv = skillInfo.id % 10
        -- for i=1, PetEducationMgr.getTableLength(skillInfo.tags) do
        local tagsTable = PetSkillViewMgr.sortSkillTips(skillInfo)
        for i=1, PetEducationMgr.getTableLength(tagsTable) do
            local v = tagsTable[i]
            local skillTagInfo = BattleInfo.getSkillTagInfoByID(v.id)
            local btnNode = CSResourceMgr.seekNodeByName(node, "btn_node"..i)
            local name = CSResourceMgr.seekNodeByName(btnNode, "attr_name")
            CSResourceMgr.setLabelStringByNode(name, skillTagInfo.name, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 108)
            btnNode:setVisible(true)
            CSResourceMgr.buttonEventBindingByNode(btnNode, function ()
                local desc = skillInfo.des[v.id]
                local desc,isLocked = PetSkillViewMgr.getSortedSkillTipsInfo(skillInfo, skillType, v, desc)
                showTipInfo(node, btnNode, i, desc, isLocked == true)
            end, function ()
                destroyTipInfo(btnNode)
            end, function ()
            end, function ()
                destroyTipInfo(btnNode)
            end, true)
            -- star
            -- local starCnt = skillInfo.skillTags[i].powers[skillLv]
            -- local maxStarCnt = skillInfo.skillTags[i].powers[5]
            local starCnt = v.powers[skillLv]
            local maxStarCnt = v.powers[5]
            for i=1,5 do
                local star = CSResourceMgr.seekNodeByName(btnNode, "star_"..i)
                star:setVisible(maxStarCnt >= i)
                if starCnt >= i then
                    CSResourceMgr.setSpriteTextureByNode(star, "Pet/Education/xing.png")
                end
            end
        end
    end

    local function setCardBySkillInfo(node, skillInfo)
        local sInfo = PetEducationMgr.getTableLength(skillInfo) > 0 and PetSkillViewMgr.getSkillInfoTableBySkillInfo(skillInfo) or {}
        local length = PetEducationMgr.getTableLength(skillInfo)
        if length == 0 then
            local child = CSResourceMgr.seekNodeByName(node, "child")
            local empty = CSResourceMgr.seekNodeByName(node, "empty")
            local strEmpty = CSResourceMgr.seekNodeByName(empty, "t1")
            for i = 1, 3 do
                local e = CSResourceMgr.seekNodeByName(empty, "e"..i)
                e:setColor({r=35,g=49,b=65})
            end
            CSResourceMgr.setLabelStringByNode(strEmpty, "train118", outlineColor[1])
            CSResourceMgr.setLabelColorByNode(strEmpty, {r=77,g=96,b=123,a=255})
            child:setVisible(false)
            empty:setVisible(true)
            return
        end
        local attTitle  = CSResourceMgr.seekNodeByName(node, "skill_att_title")
        CSResourceMgr.setLabelStringByNode(attTitle, "train77", {r=0,g=0,b=0,a=255,w=1,s=2}, 1, 110)
        CSResourceMgr.setLabelColorByNode(attTitle, labelColor[3])

        local skillNode = CSResourceMgr.seekNodeByName(node, "skill_node")
        PetSkillIconMgr.createPetSkillIcon(skillNode, skillInfo)

        for i = 1, #attrTitle do
            local label = CSResourceMgr.seekNodeByName(node, "label_"..i)
            -- local label = CSResourceMgr.seekNodeByName(panel, "label_"..i)
            if skillType == 2 and i == 1 then
                CSResourceMgr.setLabelStringByNode(label, "triggerTiming", outlineColor[2], nil, 90)
            else
                CSResourceMgr.setLabelStringByNode(label, attrTitle[i], outlineColor[2], nil, 100)
            end
            CSResourceMgr.setLabelColorByNode(label, labelColor[3])
        end

        local skillSpriteTable = {skillLvIconTable[sInfo.level], sInfo.rare, sInfo.attr}
        for i = 1, #skillSpriteTable do
            local sprite = CSResourceMgr.seekNodeByName(node, "sprite_"..i)
            CSResourceMgr.setSpriteTextureByNode(sprite, skillSpriteTable[i])
        end

        local skillName  = CSResourceMgr.seekNodeByName(node, "skill_name")
        local skillPower = CSResourceMgr.seekNodeByName(node, "label_5")
        local background5 = CSResourceMgr.seekNodeByName(node, "background_5")
        CSResourceMgr.setLabelStringByNode(skillName, sInfo.name, outlineColor[1], nil, 100)
        if skillType == 2 then
            local triggerTimingStr = PetSkillViewMgr.getPaSkillTiming(skillInfo)
            CSResourceMgr.setLabelStringByNode(skillPower, triggerTimingStr, outlineColor[1], nil, 168)
        else
            CSResourceMgr.setLabelStringByNode(skillPower, sInfo.power, outlineColor[1], nil, 168)
        end
        CSResourceMgr.setLabelColorByNode(skillPower, labelColor[5])
        background5:setColor({r=17,g=29,b=39,a=255})
        background5:setOpacity(102)

        skillName:setPositionX(sInfo.typeA == 1 and 89 or 74)

        loadTipsUI(node, skillInfo)
    end

    local function loadUIA()
        local length = PetEducationMgr.getTableLength(skillInfo)
        local strTitle = length == 0 and "train179" or "train46"
        
        local title = CSResourceMgr.seekNodeByName(panel, "title")
        CSResourceMgr.setLabelStringByNode(title, strTitle, {r=0,g=0,b=0,a=255,w=1,s=2}, nil, 264)
        CSResourceMgr.setLabelColorByNode(title, labelColor[3])

        local infoTitle = CSResourceMgr.seekNodeByName(panel, "skill_info_title")
        CSResourceMgr.setLabelStringByNode(infoTitle, strTitle, {r=0,g=0,b=0,a=255,w=1,s=2}, nil, 110)
        CSResourceMgr.setLabelColorByNode(infoTitle, labelColor[3])

        local skillNode1 = CSResourceMgr.seekNodeByName(panel, "node1")
        local node2 = CSResourceMgr.seekNodeByName(panel, "node2")
        -- node2:removeAllChildren()
        skillNode2 = skillNode1:clone()
        skillNode2:setPosition(270,308)
        skillNode2:addTo(node2)

        setCardBySkillInfo(skillNode1, skillInfo)
        oldSkillInfo = skillInfo

        local btnExchange = CSResourceMgr.seekNodeByName(panel, "btn_exchange")
        local strExchange = CSResourceMgr.seekNodeByName(btnExchange, "str")
        CSResourceMgr.setLabelStringByNode(strExchange, strTitle, outlineColor[1])
    end

    local function setSkillSelected(node, visible)
        local spriteLight = CSResourceMgr.seekNodeByName(node, "select")
        spriteLight:setVisible(visible)
    end

    local function setBtnExchange(objID, itemID, sInfo)
        local btnExchange = CSResourceMgr.seekNodeByName(panel, "btn_exchange")
        CSResourceMgr.clickEventBindingByNode(btnExchange, function ()
            NetInterface.sendWithBlock("GC_PokemonSkillChange_Ack", function()
                local PetEducationSend = require("src.Net.Send.PetEducationSend")
                PetEducationSend.sendCG_PokemonSkillChange_Req({
                    objID = objID,
                    skillIndex = skillIndex - 1,
                    itemID = itemID
                    })
                end,
                function ()
                    PetSkillViewMgr.hideSkillExchangePage()
                    TipsMgr.show(SceneMgr.getRunningScene, "train138")
                    PetSkillViewMgr.showSkillInfoPage(sInfo, skillIndex, skillType, objID)
                    if oldSkillInfo == nil or PetEducationMgr.getTableLength(oldSkillInfo) == 0 then
                        TaskWatcherManager.saveChongWuJinengState("cwjinengxuexi")
                    else
                        TaskWatcherManager.saveChongWuJinengState("cwjinengtihuan")
                    end
                end,
                function ()
                    DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 1, "train139")
                end)
        end)
    end

    local function loadUIB()
        local list = CSResourceMgr.seekNodeByName(panel, "list")
        local item = CSResourceMgr.seekNodeByName(panel, "item")
        local selectedItemIndex = 1
        local petInfo = PokemonInfo.getPetInfoByObjID(objID)
        local pokemonInfo = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
        local sInfo = PetEducationMgr.getTableLength(skillInfo) > 0 and PetSkillViewMgr.getSkillInfoTableBySkillInfo(skillInfo) or {}
        local itemInfoTable = skillType == 2 and PetSkillViewMgr.getPaExchangeSkills(petInfo, skillIndex-4) or 
                                                    PetSkillViewMgr.getExchangeSkills(petInfo, skillIndex)
        if #itemInfoTable > 0 then
            local itemNode = {}
            for i = 1, #itemInfoTable do
                itemNode[i] = item:clone()
                itemNode[i]:setVisible(true)

                local itemIcon = CSResourceMgr.seekNodeByName(itemNode[i], "icon")
                local itemName = CSResourceMgr.seekNodeByName(itemNode[i], "name")
                local itemNum  = CSResourceMgr.seekNodeByName(itemNode[i], "num")
                local bg = CSResourceMgr.seekNodeByName(itemNode[i], "bg")
                local num = PetSkillViewMgr.getSkillBookNumByID(itemInfoTable[i].id)
                CSResourceMgr.setSpriteTextureByNode(bg, ItemInfo.getItemRareBGImage(itemInfoTable[i].id))
                CSResourceMgr.setSpriteTextureByNode(itemIcon, itemInfoTable[i].icon)
                CSResourceMgr.setLabelStringByNode(itemName, itemInfoTable[i].name, outlineColor[1], nil, 90)
                CSResourceMgr.setLabelStringByNode(itemNum, num, outlineColor[1])
                list:pushBackCustomItem(itemNode[i])
                
                if itemInfoTable[i].paramB and itemInfoTable[i].paramB~=0 then
                    local star = display.newSprite("UI/CommonFiles/skillbook_star.png")
                    star:addTo(itemNode[i])
                    star:scale(1.3)
                    star:pos(30, 28)
                end
            end
            for i = 1, #itemInfoTable do
                CSResourceMgr.clickEventBindingByNode(itemNode[i], function ()
                    setSkillSelected(itemNode[selectedItemIndex], false)
                    setSkillSelected(itemNode[i], true)
                    selectedItemIndex = i
                    selectedSkillInfo = PokemonInfo.getPetSkillInfoById(itemInfoTable[selectedItemIndex].paramA)
                    setCardBySkillInfo(skillNode2, selectedSkillInfo)
                    setBtnExchange(objID, itemInfoTable[selectedItemIndex].id, selectedSkillInfo)
                end)
            end
            setSkillSelected(itemNode[selectedItemIndex], true)
            selectedSkillInfo = PokemonInfo.getPetSkillInfoById(itemInfoTable[selectedItemIndex].paramA)
            -- CSResourceMgr.setButtonEnabledByNode(btnExchange, (#itemInfoTable > 0))
            setCardBySkillInfo(skillNode2, selectedSkillInfo)
            setBtnExchange(objID, itemInfoTable[selectedItemIndex].id, selectedSkillInfo)
        else
            local strNothing = CSResourceMgr.seekNodeByName(panel, "str_nothing")
            local btnExchange = CSResourceMgr.seekNodeByName(panel, "btn_exchange")
            CSResourceMgr.setButtonEnabledByNode(btnExchange, false)

            local strDialog = ""
            if skillType == 1 then--主动
                local strSkillType = LuaSqlite.getLanguageByKey(PetSkillViewMgr.skillTypeTable[0])
                strDialog = CocosModuleMgr.createStringWithFormat({"train82", strSkillType})
            elseif skillType == 2 then--被动
                local petInfo = PokemonInfo.getPetInfoByObjID(objID)
                local strSkillType = LuaSqlite.getLanguageByKey(PetSkillViewMgr.skillRareTable[petInfo.paSkills[skillIndex-4]["paSkillType"]])
                strDialog = CocosModuleMgr.createStringWithFormat({"train82", strSkillType})
            end
            setLabel(strNothing, strDialog, {r=12,g=27,b=38,a=255,s=1,w=1}, nil, labelColor[3], 480)
            strNothing:setAnchorPoint(0.5, 0.5)
            -- CSResourceMgr.setLabelStringByNode(strNothing, strDialog, {r=12,g=27,b=38,a=255,s=1,w=1})
            -- CSResourceMgr.setLabelColorByNode(strNothing, labelColor[3])
            setCardBySkillInfo(skillNode2, {})
        end
    end

    local function playAction()
        panel:setVisible(true)
        CocosModuleMgr.showUIAnimation(panel, "down")
    end

    local funcTable = {loadCSB, loadUIA, loadUIB, playAction}
    UnblockLoader.load(funcTable, "skillExchangePage")
end

function PetSkillViewMgr.showSkillLvUpPage(skillInfo, skillIndex, skillType, objID, closeCallback)
    UIStack.push("PetSkillViewMgr.skillLvUpPage",PetSkillViewMgr.hideSkillLvUpPage,false)
    PetSkillViewMgr.closeCallback[2] = closeCallback
    local nextSkillInfo = PokemonInfo.getPetSkillInfoById(skillInfo.id+1)
    local sInfo = PetSkillViewMgr.getSkillInfoTableBySkillInfo(nextSkillInfo)
    local panel

    --阿杜修改英文版
    if true then
        resName[2] = "Pet/Education/SkillLvUpUS.csb"
    end
    local function loadCSB()
        local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, resName[2])
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setFullScreen(resName[2])
        CSResourceMgr.setRelativePosition(resName[2], 320, 480)
        CSResourceMgr.clickEventBinding(resName[2], "btn_close", function()
            PetSkillViewMgr.hideSkillLvUpPage()
        end)
        panel = CSResourceMgr.getNodeByName(resName[2], "panel")
        panel:setVisible(false)

        local btn = CSResourceMgr.getNodeByName(resName[2], "btn")
        local diff = CocosModuleMgr.getScreenSizeDiff()
        ViewMgrUtils.vFitStretch(diff, {btn})
    end

    local function loadUI()
        local title     = CSResourceMgr.seekNodeByName(panel, "title")
        local attTitle  = CSResourceMgr.seekNodeByName(panel, "skill_att_title")
        local infoTitle = CSResourceMgr.seekNodeByName(panel, "skill_info_title")
        local skillNode = CSResourceMgr.seekNodeByName(panel, "skill_node")

        PetSkillIconMgr.createPetSkillIcon(skillNode, nextSkillInfo)

        for i = 1, #attrTitle do
            local label = CSResourceMgr.seekNodeByName(panel, "label_"..i)
            if skillType == 2 and i == 1 then
                CSResourceMgr.setLabelStringByNode(label, "triggerTiming", outlineColor[2], nil, 90)
            else
                CSResourceMgr.setLabelStringByNode(label, attrTitle[i], outlineColor[2], nil, 100)
            end
            CSResourceMgr.setLabelColorByNode(label, labelColor[3])
        end

        CSResourceMgr.setLabelStringByNode(title, "train47", {r=0,g=0,b=0,a=255,w=1,s=2}, 1, 264)
        CSResourceMgr.setLabelStringByNode(attTitle, "train77", {r=0,g=0,b=0,a=255,w=1,s=2}, 1, 110)
        CSResourceMgr.setLabelStringByNode(infoTitle, "train78", {r=0,g=0,b=0,a=255,w=1,s=2}, 1, 110)

        CSResourceMgr.setLabelColorByNode(title, labelColor[3])
        CSResourceMgr.setLabelColorByNode(attTitle, labelColor[3])
        CSResourceMgr.setLabelColorByNode(infoTitle, labelColor[3])

        local skillSpriteTable = {skillLvIconTable[sInfo.level], sInfo.rare, sInfo.attr}
        for i = 1, #skillSpriteTable do
            local sprite = CSResourceMgr.seekNodeByName(panel, "sprite_"..i)
            CSResourceMgr.setSpriteTextureByNode(sprite, skillSpriteTable[i])
        end

        local skillName  = CSResourceMgr.seekNodeByName(panel, "skill_name")
        local skillDesc  = CSResourceMgr.seekNodeByName(panel, "skill_desc")
        local skillPower = CSResourceMgr.seekNodeByName(panel, "label_5")
        local buff1      = CSResourceMgr.seekNodeByName(panel, "buff1")
        CSResourceMgr.setLabelStringByNode(skillName, sInfo.name, outlineColor[1], nil, 100)
        CSResourceMgr.setLabelStringByNode(skillDesc, sInfo.desc)

        skillName:setPositionX(sInfo.typeA == 1 and 134 or 119)
        buff1:setVisible(skillInfo.power < nextSkillInfo.power)

        if skillType == 2 then
            local triggerTimingStr = PetSkillViewMgr.getPaSkillTiming(nextSkillInfo)
            CSResourceMgr.setLabelStringByNode(skillPower, triggerTimingStr, outlineColor[1], nil, 168)
            CSResourceMgr.setSpriteTextureByNode(buff1, "empty.png")
        else
            CSResourceMgr.setLabelStringByNode(skillPower, sInfo.power, outlineColor[1], nil, 168)
            CSResourceMgr.setLabelColorByNode(skillPower, (skillInfo.power < nextSkillInfo.power) and {r=48,g=224,b=44,a=255} or {r=217,g=234,b=255,a=255})
            CSResourceMgr.setSpriteTextureByNode(buff1, "UI/CommonFiles/buff1.png")
            buff1:setPositionX(skillPower:getPositionX() + skillPower:getContentSize().width + 20)
        end
        CSResourceMgr.setLabelColorByNode(skillPower, labelColor[5])
        CSResourceMgr.setLabelColorByNode(skillDesc, labelColor[5])
    end

    local function loadBtn()
        local needRes = CSResourceMgr.seekNodeByName(panel, "str_need_res")
        local node1   = CSResourceMgr.seekNodeByName(panel, "node_res1")
        local node2   = CSResourceMgr.seekNodeByName(panel, "node_res2")
        local resNum1 = CSResourceMgr.seekNodeByName(panel, "str_need_res_count1")
        local resNum2 = CSResourceMgr.seekNodeByName(panel, "str_need_res_count2")

        local needSkillBook = sInfo.typeA ~= 7 and sInfo.typeA ~= 8--天赋援助技能不需要技能书

        local needSkillBookNum1 = 0
        local haveSkillBookNum2 = 0
        local itemID2 = 10001--技能碎片ID
        local itemCount = ItemInfo.getCharItemNum(itemID2)--表里读的需要技能碎片数量
        local needItemNum1 = SystemInfo.getGlobalConfigAddInfoByID(6400+sInfo.level-1).values[1]--需要技能碎片数量
        local needItemNum2 = SystemInfo.getGlobalConfigAddInfoByID(6550+skillInfo.airpower).values[1]
        local needItemNum = needItemNum1 * needItemNum2 * (needSkillBook == true and 1 or 2)--天赋、援助技能技能碎片消耗 * 2

        for i = 1, 2 do
            if needSkillBook == true or (needSkillBook == false and i ~= 1) then
                local itemid = i == 1 and skillInfo.upItemType or itemID2
                local itemNode = ItemInfo.getItemIconById(itemid, nil)
                itemNode:setPosition(0, 0)
                itemNode:removeFromParent()
                itemNode:addTo(i == 1 and node1 or node2)
                itemNode:setScale(0.8)

                local itemID = skillInfo.upItemType--技能书ID
                needSkillBookNum1 = SystemInfo.getGlobalConfigAddInfoByID(6450+sInfo.level-1).values[1]--需要技能书数量
                haveSkillBookNum2 = PetSkillViewMgr.getSkillBookNumByID(itemID)
                CSResourceMgr.setLabelStringByNode(resNum1, haveSkillBookNum2.."/"..needSkillBookNum1, outlineColor[1], nil, 106)
                CSResourceMgr.setLabelColorByNode(resNum1, (haveSkillBookNum2 >= needSkillBookNum1) and labelColor[1] or labelColor[7])

                CSResourceMgr.buttonEventBindingByNode(itemNode, function ()
                    ItemInfoViewMgr.show({id = itemid}, false)
                end, function ()
                    ItemInfoViewMgr.hide()
                end, function ()
                end, function ()
                    ItemInfoViewMgr.hide()
                end, true)
            elseif needSkillBook == false and i == 1 then
                -- node2:setPositionX(i == 1 and 112 or 174)
                -- resNum2:setPositionX(i == 1 and 112 or 174)
                node2:setPositionX(112)
                resNum2:setPositionX(112)
                node1:setVisible(false)
                resNum1:setVisible(false)
            end
        end

        CSResourceMgr.setLabelStringByNode(needRes, LuaSqlite.getLanguageByKey("train27").."：")
        CSResourceMgr.setLabelStringByNode(resNum2, itemCount.."/"..needItemNum, outlineColor[1], nil, 106)

        CSResourceMgr.setLabelColorByNode(needRes, labelColor[3])
        CSResourceMgr.setLabelColorByNode(resNum2, (itemCount >= needItemNum) and labelColor[1] or labelColor[7])

        local btnLvUp = CSResourceMgr.seekNodeByName(panel, "btn_lvup")
        local strLvUp = CSResourceMgr.seekNodeByName(btnLvUp, "str")
        CSResourceMgr.setLabelStringByNode(strLvUp, "train119", outlineColor[1], nil, 154)
        
        local btnLvUpEnable = false
        if needSkillBook == true then
            btnLvUpEnable = (itemCount >= needItemNum) and (haveSkillBookNum2 >= needSkillBookNum1)
        elseif needSkillBook == false then
            btnLvUpEnable = itemCount >= needItemNum
        end

        CSResourceMgr.clickEventBindingByNode(btnLvUp, function ()
            if btnLvUpEnable == false then
                -- DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 1, "train120")
                StandardTipsMgr.show(1, "train120")
                return
            end
            NetInterface.sendWithBlock("GC_POKEMONSKILLLEVELUP_ACK", function()
                local PetEducationSend = require("src.Net.Send.PetEducationSend")
                PetEducationSend.sendCG_PokemonSkillLevelUp_Req({
                    objID = objID,
                    skillIndex = skillIndex - 1
                    })
                    end,
                    function ()
                        GameAudio.playUISound("skillLevelup")
                        CSResourceMgr.setButtonEnabledByNode(btnLvUp, false)
                        -- PetEffectMgr.showHammerEffect(panel, function ()
                        PetEffectMgr.showSkillLvUpEffect(panel, function ()
                            PetSkillViewMgr.hideSkillLvUpPage()
                        end)

                        local params = {}
                        params.objID = objID
                        params.skillID = skillInfo.id
                        params.skillLv = sInfo.level
                        params.skillRare = skillInfo.airpower
                        TaskWatcherManager.saveCWJiNengShengJiState(params)
                    end,
                    function (code)
                        print("failed PokemonSkillLevelUp! code : ",code)
                    end)
        end, 3)
    end

    local function loadTipsUI()
        local list = CSResourceMgr.getNodeByName(resName[2], "list")
        local nowSkillInfo = PokemonInfo.getPetSkillInfoById(skillInfo.id)
        local nowSkillLv = nowSkillInfo.id % 10
        skillInfo = PokemonInfo.getPetSkillInfoById(skillInfo.id + 1)
        local skillLv = skillInfo.id % 10
        local tagsTable = PetSkillViewMgr.sortSkillTips(skillInfo)
        for k,v in pairs(tagsTable) do
            local skillTagInfo = BattleInfo.getSkillTagInfoByID(v.id)
            local node = CSResourceMgr.getNodeByName(resName[2], "attr_node"):clone()
            list:pushBackCustomItem(node)
            local name = CSResourceMgr.seekNodeByName(node, "attr_name")
            CSResourceMgr.setLabelStringByNode(name, skillTagInfo.name, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 108)
            CSResourceMgr.setLabelColorByNode(name, labelColor[5])
            local info = CSResourceMgr.seekNodeByName(node, "attr_info")
            local desc = skillInfo.des[v.id]

            local desc,isLocked = PetSkillViewMgr.getSortedSkillTipsInfo(skillInfo, skillType, v, desc)
            local lColor = isLocked == true and labelColor[8] or labelColor[5]
            setLabel(info,desc,nil,nil,lColor,330)

            info:setAnchorPoint(0, 0.5)
            -- star
            local starCnt = v.powers[skillLv]
            local maxStarCnt = v.powers[5]
            for i=1,5 do
                local star = CSResourceMgr.seekNodeByName(node, "star_"..i)
                star:setVisible(maxStarCnt >= i)
                if starCnt >= i then
                    CSResourceMgr.setSpriteTextureByNode(star, "Pet/Education/xing.png")
                end
            end
            local index = 1
            for k1,v1 in pairs(skillInfo.skillTags) do
                if v1.id == v.id then
                    break
                end
                index = index + 1
            end
            local buff = CSResourceMgr.seekNodeByName(node, "buff2")
            local nowSkillStarCnt = nowSkillInfo.skillTags[index].powers[nowSkillLv]
            buff:setVisible(starCnt > nowSkillStarCnt)
            CSResourceMgr.setSpriteTextureByNode(buff, "UI/CommonFiles/buff1.png")
        end
    end

    local function playAction()
        panel:setVisible(true)
        CocosModuleMgr.showUIAnimation(panel, "down")
    end

    local funcTable = {loadCSB, loadUI, loadBtn, loadTipsUI, playAction}
    UnblockLoader.load(funcTable, "skillLvUpPage")
end

function PetSkillViewMgr.hideSkillInfoPage()
    UnblockLoader.cancel("skillInfoPage")
    CSResourceMgr.removeCSObjectByTag(resName[1])
    UIStack.pop("PetSkillViewMgr.skillPage")
    if PetSkillViewMgr.closeCallback[1] ~= nil then
        PetSkillViewMgr.closeCallback[1]()
        PetSkillViewMgr.closeCallback[1] = nil
    end
end

function PetSkillViewMgr.hideSkillExchangePage()
    UnblockLoader.cancel("skillExchangePage")
    CSResourceMgr.removeCSObjectByTag(resName[3])
    UIStack.pop("PetSkillViewMgr.skillExchangePage")
    if PetSkillViewMgr.closeCallback[3] ~= nil then
        PetSkillViewMgr.closeCallback[3]()
        PetSkillViewMgr.closeCallback[3] = nil
    end
end

function PetSkillViewMgr.hideSkillLvUpPage()
    UnblockLoader.cancel("skillLvUpPage")
    CSResourceMgr.removeCSObjectByTag(resName[2])
    UIStack.pop("PetSkillViewMgr.skillLvUpPage")
    if PetSkillViewMgr.closeCallback[2] ~= nil then
        PetSkillViewMgr.closeCallback[2]()
        PetSkillViewMgr.closeCallback[2] = nil
    end
end

function PetSkillViewMgr.hideBattleSkillInfoPage()
    CSResourceMgr.removeCSObjectByTag(resNameBattle[1])
end

function PetSkillViewMgr.hideConciseSkillInfoPage()
    CSResourceMgr.removeCSObjectByTag(resNameBattle[1])
    UIStack.pop("PetSkillViewMgr.conciseSkillInfo")
end

function PetSkillViewMgr.showBattleSkillInfoPage(skillInfo)
    local sInfo = PetSkillViewMgr.getSkillInfoTableBySkillInfo(skillInfo)
    local panel

    --阿杜修改英文版
    -- if true then
    --     resNameBattle[1] = "Pet/Education/BattleSkillInfoViewUS.csb"
    -- end
    local function loadCSB()
        local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameBattle[1])
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setFullScreen(resNameBattle[1])
        CSResourceMgr.setRelativePosition(resNameBattle[1], 320, 480)
        panel = CSResourceMgr.getNodeByName(resNameBattle[1], "panel")
        panel:setVisible(false)

        local btn = CSResourceMgr.getNodeByName(resNameBattle[1], "btn")
        local diff = CocosModuleMgr.getScreenSizeDiff()
        ViewMgrUtils.vFitStretch(diff, {btn})
    end

    local function loadUI()
        local title     = CSResourceMgr.seekNodeByName(panel, "title")
        local attTitle  = CSResourceMgr.seekNodeByName(panel, "skill_att_title")
        local infoTitle = CSResourceMgr.seekNodeByName(panel, "skill_info_title")
        local skillNode = CSResourceMgr.seekNodeByName(panel, "skill_node")

        PetSkillIconMgr.createPetSkillIcon(skillNode, skillInfo)

        for i = 1, #attrTitle do
            local label = CSResourceMgr.seekNodeByName(panel, "label_"..i)
            CSResourceMgr.setLabelStringByNode(label, attrTitle[i], outlineColor[2], nil, 100)
            CSResourceMgr.setLabelColorByNode(label, labelColor[3])
        end

        CSResourceMgr.setLabelStringByNode(title, "train45", {r=0,g=0,b=0,a=255,w=1,s=2}, 1, 264)
        CSResourceMgr.setLabelStringByNode(attTitle, "train77", {r=0,g=0,b=0,a=255,w=1,s=2}, 1, 110)
        CSResourceMgr.setLabelStringByNode(infoTitle, "train78", {r=0,g=0,b=0,a=255,w=1,s=2}, 1, 110)

        CSResourceMgr.setLabelColorByNode(title, labelColor[3])
        CSResourceMgr.setLabelColorByNode(attTitle, labelColor[3])
        CSResourceMgr.setLabelColorByNode(infoTitle, labelColor[3])

        local skillSpriteTable = {skillLvIconTable[sInfo.level], sInfo.rare, sInfo.attr}
        for i = 1, #skillSpriteTable do
            local sprite = CSResourceMgr.seekNodeByName(panel, "sprite_"..i)
            CSResourceMgr.setSpriteTextureByNode(sprite, skillSpriteTable[i])
        end

        local skillName  = CSResourceMgr.seekNodeByName(panel, "skill_name")
        local skillDesc  = CSResourceMgr.seekNodeByName(panel, "skill_desc")
        local skillPower = CSResourceMgr.seekNodeByName(panel, "label_5")

        skillName:setPositionX(sInfo.typeA == 1 and 134 or 119)

        CSResourceMgr.setLabelStringByNode(skillName, sInfo.name, outlineColor[1], nil, 100)
        CSResourceMgr.setLabelStringByNode(skillPower, sInfo.power, outlineColor[1], nil, 168)
        CSResourceMgr.setLabelStringByNode(skillDesc, sInfo.desc)

        CSResourceMgr.setLabelColorByNode(skillPower, labelColor[5])
        CSResourceMgr.setLabelColorByNode(skillDesc, labelColor[5])
    end

    local function loadTipsUI()
        local list = CSResourceMgr.getNodeByName(resNameBattle[1], "list")
        local index = 1
        skillInfo = PokemonInfo.getPetSkillInfoById(skillInfo.id)
        local skillLv = skillInfo.id % 10
        local tagsTable = PetSkillViewMgr.sortSkillTips(skillInfo)
        -- for k,v in pairs(skillInfo.skillTags) do
        for k,v in pairs(tagsTable) do
            local skillTagInfo = BattleInfo.getSkillTagInfoByID(v.id)
            local node = CSResourceMgr.getNodeByName(resNameBattle[1], "attr_node"):clone()
            list:pushBackCustomItem(node)
            local name = CSResourceMgr.seekNodeByName(node, "attr_name")
            CSResourceMgr.setLabelStringByNode(name, skillTagInfo.name, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 108)
            CSResourceMgr.setLabelColorByNode(name, labelColor[5])
            local info = CSResourceMgr.seekNodeByName(node, "attr_info")
            local desc = skillInfo.des[v.id]

            local desc,isLocked = PetSkillViewMgr.getSortedSkillTipsInfo(skillInfo, 1, v, desc)
            local lColor = isLocked == true and labelColor[8] or labelColor[5]
            setLabel(info,desc,nil,nil,lColor,330)

            info:setAnchorPoint(0, 0.5)
            -- star
            -- local starCnt = skillInfo.skillTags[index].powers[skillLv]
            -- local maxStarCnt = skillInfo.skillTags[index].powers[5]
            local starCnt = v.powers[skillLv]
            local maxStarCnt = v.powers[5]
            for i=1,5 do
                local star = CSResourceMgr.seekNodeByName(node, "star_"..i)
                star:setVisible(maxStarCnt >= i)
                if starCnt >= i then
                    CSResourceMgr.setSpriteTextureByNode(star, "Pet/Education/xing.png")
                end
            end
            index = index + 1
        end
    end

    local function playAction()
        panel:setVisible(true)
        -- CocosModuleMgr.showUIAnimation(panel, "down")
    end

    local funcTable = {loadCSB, loadUI, loadTipsUI, playAction}
    UnblockLoader.load(funcTable)
end

function PetSkillViewMgr.showConciseSkillInfo(skillInfo, skillType, hideCloseBtn, iteminfo)--skillType:1.主动 2.被动
    UIStack.push("PetSkillViewMgr.conciseSkillInfo",PetSkillViewMgr.hideConciseSkillInfoPage,false)
    local sInfo = PetSkillViewMgr.getSkillInfoTableBySkillInfo(skillInfo)
    local panel

    --阿杜修改英文版
    if true then
        resNameBattle[1] = "Pet/Education/BattleSkillInfoViewUS.csb"
    end
    local function loadCSB()
        local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameBattle[1])
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setFullScreen(resNameBattle[1])
        CSResourceMgr.setRelativePosition(resNameBattle[1], 320, 480)
        panel = CSResourceMgr.getNodeByName(resNameBattle[1], "panel")
        panel:setVisible(false)
        
        if iteminfo then
            if iteminfo.paramB and iteminfo.paramB~=0 then
                local posy = panel:getPositionY()
                panel:setPositionY(posy+30)
                local resNameEx = "Pet/Education/BattleSkillExtend.csb"
                local layerEx = CSResourceMgr.createRes(panel, resNameEx)
        		layerEx:pos(320, 225)
        		layerEx:setAnchorPoint(0.5, 1)
                CSResourceMgr.setLabelString(resNameEx, "etitle", "skillBook46", nil, 
                    CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS, nil, 100)
                if iteminfo.paramC==1 then
                    CSResourceMgr.setLabelString(resNameEx, "text", "skillBook45")
                end
                local esPetsVec = PokemonInfo.getCustomSkillBookInfoById(iteminfo.paramB).petIDs
                for var=1, #esPetsVec do
                    local icon = ItemInfo.getPetIconById(esPetsVec[var], var.."skillinfo")
                    icon:addTo(layerEx)
                    icon:pos(250+100*(var-1), 20)
                end
        	end
        end

        if not hideCloseBtn then
            local btnClose = CSResourceMgr.getNodeByName(resNameBattle[1], "btn_close")
            btnClose:setVisible(true)
            CSResourceMgr.clickEventBindingByNode(btnClose, function ()
                PetSkillViewMgr.hideConciseSkillInfoPage()
            end)
        end

        local btn = CSResourceMgr.getNodeByName(resNameBattle[1], "btn")
        local diff = CocosModuleMgr.getScreenSizeDiff()
        ViewMgrUtils.vFitStretch(diff, {btn})
    end

    local function loadUI()
        local title     = CSResourceMgr.seekNodeByName(panel, "title")
        local attTitle  = CSResourceMgr.seekNodeByName(panel, "skill_att_title")
        local infoTitle = CSResourceMgr.seekNodeByName(panel, "skill_info_title")
        local skillNode = CSResourceMgr.seekNodeByName(panel, "skill_node")

        PetSkillIconMgr.createPetSkillIcon(skillNode, skillInfo)

        for i = 1, #attrTitle do
            local label = CSResourceMgr.seekNodeByName(panel, "label_"..i)
            if skillType == 2 and i == 1 then
                CSResourceMgr.setLabelStringByNode(label, "triggerTiming", outlineColor[2], nil, 90)
            else
                CSResourceMgr.setLabelStringByNode(label, attrTitle[i], outlineColor[2], nil, 100)
            end
            CSResourceMgr.setLabelColorByNode(label, labelColor[3])
        end

        CSResourceMgr.setLabelStringByNode(title, "train45", {r=0,g=0,b=0,a=255,w=1,s=2}, 1, 264)
        CSResourceMgr.setLabelStringByNode(attTitle, "train77", {r=0,g=0,b=0,a=255,w=1,s=2}, 1, 110)
        CSResourceMgr.setLabelStringByNode(infoTitle, "train78", {r=0,g=0,b=0,a=255,w=1,s=2}, 1, 110)

        CSResourceMgr.setLabelColorByNode(title, labelColor[3])
        CSResourceMgr.setLabelColorByNode(attTitle, labelColor[3])
        CSResourceMgr.setLabelColorByNode(infoTitle, labelColor[3])

        local skillSpriteTable = {skillLvIconTable[sInfo.level], sInfo.rare, sInfo.attr}
        for i = 1, #skillSpriteTable do
            local sprite = CSResourceMgr.seekNodeByName(panel, "sprite_"..i)
            CSResourceMgr.setSpriteTextureByNode(sprite, skillSpriteTable[i])
        end

        local skillName  = CSResourceMgr.seekNodeByName(panel, "skill_name")
        local skillDesc  = CSResourceMgr.seekNodeByName(panel, "skill_desc")
        local skillPower = CSResourceMgr.seekNodeByName(panel, "label_5")

        skillName:setPositionX(sInfo.typeA == 1 and 134 or 119)

        CSResourceMgr.setLabelStringByNode(skillName, sInfo.name, outlineColor[1], nil, 100)
        if skillType == 2 then
            local triggerTimingStr = PetSkillViewMgr.getPaSkillTiming(skillInfo)
            CSResourceMgr.setLabelStringByNode(skillPower, triggerTimingStr, outlineColor[1], nil, 168)
        else
            CSResourceMgr.setLabelStringByNode(skillPower, sInfo.power, outlineColor[1], nil, 168)
        end
        CSResourceMgr.setLabelStringByNode(skillDesc, sInfo.desc)

        CSResourceMgr.setLabelColorByNode(skillPower, labelColor[5])
        CSResourceMgr.setLabelColorByNode(skillDesc, labelColor[5])
    end

    local function loadTipsUI()
        local list = CSResourceMgr.getNodeByName(resNameBattle[1], "list")
        local index = 1
        skillInfo = PokemonInfo.getPetSkillInfoById(skillInfo.id)
        local skillLv = skillInfo.id % 10
        local tagsTable = PetSkillViewMgr.sortSkillTips(skillInfo)
        -- for k,v in pairs(skillInfo.skillTags) do
        for k,v in pairs(tagsTable) do
            local skillTagInfo = BattleInfo.getSkillTagInfoByID(v.id)
            local node = CSResourceMgr.getNodeByName(resNameBattle[1], "attr_node"):clone()
            list:pushBackCustomItem(node)
            local name = CSResourceMgr.seekNodeByName(node, "attr_name")
            CSResourceMgr.setLabelStringByNode(name, skillTagInfo.name, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 108)
            CSResourceMgr.setLabelColorByNode(name, labelColor[5])
            local info = CSResourceMgr.seekNodeByName(node, "attr_info")
            local desc = skillInfo.des[v.id]

            local desc,isLocked = PetSkillViewMgr.getSortedSkillTipsInfo(skillInfo, skillType, v, desc)
            local lColor = isLocked == true and labelColor[8] or labelColor[5]
            setLabel(info,desc,nil,nil,lColor,330)

            info:setAnchorPoint(0, 0.5)
            -- star
            -- local starCnt = skillInfo.skillTags[index].powers[skillLv]
            -- local maxStarCnt = skillInfo.skillTags[index].powers[5]
            local starCnt = v.powers[skillLv]
            local maxStarCnt = v.powers[5]
            for i=1,5 do
                local star = CSResourceMgr.seekNodeByName(node, "star_"..i)
                star:setVisible(maxStarCnt >= i)
                if starCnt >= i then
                    CSResourceMgr.setSpriteTextureByNode(star, "Pet/Education/xing.png")
                end
            end
            index = index + 1
        end
    end

    local function playAction()
        panel:setVisible(true)
        CocosModuleMgr.showUIAnimation(panel, "down")
    end

    local funcTable = {loadCSB, loadUI, loadTipsUI, playAction}
    UnblockLoader.load(funcTable)
end

local function compareSkillGroundpower(petInfo, groundpower)
    for k,v in pairs(petInfo.skills) do
        if v ~= 0 then
            local sInfo = PokemonInfo.getPetSkillInfoById(v)
            if sInfo.groundpower == groundpower then
                return false
            end
        end
    end
    return true
end

function PetSkillViewMgr.getValidSkills(petInfo, elementAtt1, elementAtt2)
    local ret = {}
    -- local charItemInfo = ItemInfo.getCharItemInfo()
    local charItemInfo = ItemInfo.getSkillBookInfo()
    for k,v in pairs(charItemInfo) do
        local itemInfo = ItemInfo.getItemInfoById(k)
        -- if itemInfo.itemType == 1 then  -- 1:技能卡
            local skillInfo = PokemonInfo.getPetSkillInfoById(itemInfo.paramA)
            if skillInfo.skillAtt == elementAtt1 or skillInfo.skillAtt == elementAtt2 or skillInfo.skillAtt == 1 then
                if compareSkillGroundpower(petInfo, skillInfo.groundpower) then
                    table.insert(ret,itemInfo)
                end
            end
        -- end
    end
    return ret
end

function PetSkillViewMgr.getExchangeSkills(petInfo, skillIndex)
    local groundpowerList = {}
    for k,v in pairs(petInfo.skills) do
        if v ~= 0 then
            local gp = PokemonInfo.getPetSkillInfoById(v).groundpower
            table.insert(groundpowerList, gp)
        end
    end
    local equipedSkillID = petInfo.skills[skillIndex]
    local equipedSkillInfo = {id=-1, groundpower=-1}
    if equipedSkillID and equipedSkillID ~= 0 then
        equipedSkillInfo = PokemonInfo.getPetSkillInfoById(equipedSkillID)
    end

    local pokeID = petInfo.pokeID
    local pokemonInfo = PokemonInfo.getPokemonInfoByID(pokeID)
    local elementAtt1 = pokemonInfo.elementAtt1
    local elementAtt2 = pokemonInfo.elementAtt2
    local skillItems = {}
    local charItemInfo = ItemInfo.getSkillBookInfo()--拥有技能书

    for k,v in pairs(charItemInfo) do
        if v ~= 0 then
            local itemInfo = ItemInfo.getItemInfoById(k)
            local skillInfo = PokemonInfo.getPetSkillInfoById(itemInfo.paramA)
            local isSp, isFit = false, false
            if itemInfo.paramB and itemInfo.paramB~=0 then
                isSp = true
                local esPetsVec = PokemonInfo.getCustomSkillBookInfoById(itemInfo.paramB).petIDs
                for n=1, #esPetsVec do
                    if pokeID==esPetsVec[n] then
                        isFit = true
                		break
                	end
                end
            end
            local function checkValid()
                local canExchange = true
                for k1,v1 in pairs(groundpowerList) do--唯一性
                    if skillInfo.groundpower == v1 and (math.floor(equipedSkillInfo.id/10) == math.floor(skillInfo.id/10)
                        or equipedSkillInfo.groundpower ~= v1) then
                        canExchange = false
                        break
                    end
                end
                if canExchange == true then
                    if isFit then
                        table.insert(skillItems, 1, itemInfo)
                    else
                        table.insert(skillItems, itemInfo)
                    end
                end
            end
            if not isSp or isFit then
                if skillInfo.skillAtt == elementAtt1 or skillInfo.skillAtt == elementAtt2 or skillInfo.skillAtt == 1 or isFit then
                    if equipedSkillID and equipedSkillID ~= 0 then
                        if equipedSkillInfo.skill_A_Type == skillInfo.skill_A_Type then
                            -- if equipedSkillInfo.skill_A_Type == skillInfo.skill_A_Type or skillInfo.skill_A_Type == 0 then
                            checkValid()
                        end
                    else
                        if skillIndex == 4 then
                            if skillInfo.skill_A_Type == 1 then--1是奥义
                                checkValid()
                            end
                        else
                            if skillInfo.skill_A_Type == 0 then--0是主动
                                checkValid()
                            end
                        end
                    end
                end
            end
        end
    end
    return skillItems
end

function PetSkillViewMgr.getPaExchangeSkills(petInfo, skillIndex)
    local groundpowerList = {}
    for k,v in pairs(petInfo.paSkills) do
        if v["paSkillID"] and v["paSkillID"] ~= 0 then
            local gp = PokemonInfo.getPetSkillInfoById(v["paSkillID"]).groundpower
            table.insert(groundpowerList, gp)
        end
    end
    local equipedSkillInfo = {id=-1, groundpower=-1}
    local equipedSkillID = petInfo.paSkills[skillIndex]["paSkillID"]
    local equipedSkillType = petInfo.paSkills[skillIndex]["paSkillType"]
    if equipedSkillID ~= 0 then
        equipedSkillInfo = PokemonInfo.getPetSkillInfoById(equipedSkillID)
    end

    local pokeID = petInfo.pokeID
    local pokemonInfo = PokemonInfo.getPokemonInfoByID(pokeID)
    local elementAtt1 = pokemonInfo.elementAtt1
    local elementAtt2 = pokemonInfo.elementAtt2
    local skillItems = {}
    local charItemInfo = ItemInfo.getSkillBookInfo()--拥有技能书
    for k,v in pairs(charItemInfo) do
        if v ~= 0 then
            local itemInfo = ItemInfo.getItemInfoById(k)
            local skillInfo = PokemonInfo.getPetSkillInfoById(itemInfo.paramA)
            local isSp, isFit = false, false
            if itemInfo.paramB and itemInfo.paramB~=0 then
                isSp = true
                local esPetsVec = PokemonInfo.getCustomSkillBookInfoById(itemInfo.paramB).petIDs
                for n=1, #esPetsVec do
                    if pokeID==esPetsVec[n] then
                        isFit = true
                        break
                    end
                end
            end
            local function checkValid()
                local canExchange = true
                for k1,v1 in pairs(groundpowerList) do--唯一性
                    if skillInfo.groundpower == v1 and (math.floor(equipedSkillInfo.id/10) == math.floor(skillInfo.id/10)
                        or equipedSkillInfo.groundpower ~= v1) then
                        canExchange = false
                        break
                    end
                end
                if canExchange == true then
                    if isFit then
                        table.insert(skillItems, 1, itemInfo)
                    else
                        table.insert(skillItems, itemInfo)
                    end
                end
            end
            if not isSp or isFit then
                if skillInfo.skillAtt == elementAtt1 or skillInfo.skillAtt == elementAtt2 or skillInfo.skillAtt == 1 or isFit then
                    if equipedSkillID and equipedSkillID ~= 0 then
                        if equipedSkillInfo.skill_A_Type == skillInfo.skill_A_Type then--类型匹配(主动、被动)
                            if equipedSkillType == skillInfo.airpower - 1 then
                                checkValid()
                            end
                        end
                    else
                        if skillInfo.skill_A_Type == 6 then
                            if equipedSkillType == skillInfo.airpower - 1 then--稀有度
                                checkValid()
                            end
                        end
                    end
                end
            end
        end
    end
    return skillItems
end

function PetSkillViewMgr.getSkillBookNumByID(id)
    local charItemInfo = ItemInfo.getSkillBookInfo()
    return charItemInfo[id] or 0
end

function PetSkillViewMgr.sortSkillTips(skillInfo)
    local tags = {}
    local skillLv = skillInfo.id % 10
    local unlockLv = 0
    for k,v in pairs(skillInfo.skillTags) do
        for j = 1, 5 do
            if v.powers[j] > 0 then
                unlockLv = j
                break
            end
        end
        local isLocked = unlockLv > skillLv
        if isLocked == false then
            table.insert(tags, v)
        end
    end

    for k,v in pairs(skillInfo.skillTags) do
        for j = 1, 5 do
            if v.powers[j] > 0 then
                unlockLv = j
                break
            end
        end
        local isLocked = unlockLv > skillLv
        if isLocked == true then
            table.insert(tags, v)
        end
    end
    return tags
end

function PetSkillViewMgr.getSkillTipsInfo(skillInfo, skillType, index, desc)
    local skillLv = skillInfo.id % 10

    local descA = ""
    if skillType == 2 then
        descA = PetSkillViewMgr.getPaSkillTiming(skillInfo)
    end

    local unlockLv = 0
    for j = 1, 5 do
        if skillInfo.skillTags[index].powers[j] > 0 then
            unlockLv = j
            break
        end
    end
    local isLocked = unlockLv > skillLv
    local desc = isLocked and CocosModuleMgr.createStringWithFormat({"train124", unlockLv}) or descA..desc
    return desc, isLocked
end

function PetSkillViewMgr.getSortedSkillTipsInfo(skillInfo, skillType, skillTags, desc)
    local skillLv = skillInfo.id % 10

    local descA = ""
    if skillType == 2 then
        local triggerRates = skillInfo.triggerRates[skillLv] == nil and "" or skillInfo.triggerRates[skillLv].."%%"
        descA = CocosModuleMgr.createStringWithFormat({skillInfo.triggerCondition2, triggerRates})
    end
    -- desc = skillType == 1 and desc or descA

    local unlockLv = 0
    for j = 1, 5 do
        if skillTags.powers[j] > 0 then
        -- if skillInfo.skillTags[index].powers[j] > 0 then
            unlockLv = j
            break
        end
    end
    local isLocked = unlockLv > skillLv
    local desc = isLocked and CocosModuleMgr.createStringWithFormat({"train124", unlockLv}) or descA..(desc or "")
    return desc, isLocked
end

function PetSkillViewMgr.getPaSkillTiming(skillInfo)
    local skillLv = skillInfo.id % 10
    local triggerRates = skillInfo.triggerRates[skillLv] == nil and "" or skillInfo.triggerRates[skillLv].."%%"
    local str = CocosModuleMgr.createStringWithFormat({skillInfo.triggerCondition, triggerRates})
    return str
end

function PetSkillViewMgr.getSevenActivePetSkillFinished(needPetCnt, needSkillRare, needSkillLv)
    local finishedPetCnt = 0
    local allPetInfo = PokemonInfo.getAllPets()
    for k,v in pairs(allPetInfo) do
        for k1,v1 in pairs(v.skills) do
            if v1 ~= 0 then
                local skillInfo = PokemonInfo.getPetSkillInfoById(v1)
                if skillInfo.airpower == needSkillRare and v1 % 10 >= needSkillLv then
                    finishedPetCnt = finishedPetCnt + 1
                    if finishedPetCnt >= needPetCnt then
                        return true
                    end
                    break
                end
            end
        end
        for k1,v1 in pairs(v.paSkills) do
            if v1["paSkillID"] and v1["paSkillID"] ~= 0 then
                local skillInfo = PokemonInfo.getPetSkillInfoById(v1)
                if skillInfo.airpower == needSkillRare and v1 % 10 >= needSkillLv then
                    finishedPetCnt = finishedPetCnt + 1
                    if finishedPetCnt >= needPetCnt then
                        return true
                    end
                    break
                end
            end
        end
    end
    return false
end

return PetSkillViewMgr