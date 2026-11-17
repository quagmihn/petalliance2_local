local EduSkillPageMgr = {}

local resName = "Pet/Education/homepage/skillPage.csb"
local resName_xia = "Pet/Education/homepage/skillPage_2.csb"
local resName_main = ""
local resName_lvUp = ""
local resName_exchange = ""

local LABLE_OUTLINE_THICK = 1

local topBar
local centerBar
local bottomBar

local currSel
local IsDescShow = false

local curSkillInfo = {}
local validItemInfoTable = {}
local skill_info_table = {}

local irareString = {}
local objID = 0

local desc_cc = {r=205,g=229,b=255,a=255}

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
    {r=0,g=0,b=0,a=255,w=1},        --1
    {r=255,g=255,b=255,a=255},  --2
    {r=38,g=54,b=76,a=255},     --3
    {r=209,g=138,b=0,a=255,w=1},    --4
    {r=17,g=29,b=39,a=255},     --5
    {r=0,g=0,b=0,a=255,w=2}     --6
}

local attrTitle = {"train72", "train73", "train74", "train75"}--类型、分类、命中、威力

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

function EduSkillPageMgr.Init()
    IsDescShow = false
    skill_info_table = {}
    irareString = {
        [1] = "Pet/Education/b.png",
        [2] = "Pet/Education/a.png",
        [3] = "Pet/Education/s.png",
        [4] = "Pet/Education/2s.png",
    }
    resName_main = "Pet/Education/SkillInfoView.csb"
    resName_lvUp = "Pet/Education/SkillLvUp.csb"
    resName_exchange = "Pet/Education/SkillExchange.csb"
end

--[[
function EduSkillPageMgr.showSkillPage(scene, skillInfo, objid, skillIndex, canLvUp, operable)
    if operable==nil then
        operable = true
    end

    skillInfo = skillInfo or {}
    curSkillInfo = skillInfo
    objID = objid

    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, resName_main)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName_main, 320, 480)
        CSResourceMgr.clickEventBinding(resName_main,"btn_close",function()
            EduSkillPageMgr.hideSkillPage()
        end)
    end

    local function loadUI()
        local skillIcon1    = skillInfo.icon and "Battle/skillIcon/"..skillInfo.icon..".png" or "empty.png"
        local skillName1    = skillInfo.name
        local skillAttr1    = skillInfo.skillAtt
        local skillDesc1    = skillInfo.desc
        local skillType1    = skillInfo.skill_A_Type
        local skillLv1      = (skillInfo.id % 5 == 0) and 5 or (skillInfo.id % 5)
        local skillPower    = skillInfo.power
        local skillHitR     = skillInfo.hitRate or 0 --命中

        local panel         = CSResourceMgr.getNodeByName(resName_main, "btn")
        local panel1        = CSResourceMgr.getNodeByName(resName_main, "panel1")
        local title         = CSResourceMgr.seekNodeByName(panel1, "name")
        -- local skillIcon     = CSResourceMgr.seekNodeByName(panel1, "skill_icon")
        -- local attB          = CSResourceMgr.seekNodeByName(panel1, "att_background")
        -- local attIcon       = CSResourceMgr.seekNodeByName(panel1, "att_icon")
        -- local skillLv       = CSResourceMgr.seekNodeByName(panel1, "skill_lv")
        local skillName     = CSResourceMgr.seekNodeByName(panel1, "skill_name")
        local skillRareTitle= CSResourceMgr.seekNodeByName(panel1, "skill_rare_title")
        local skillRare     = CSResourceMgr.seekNodeByName(panel1, "skill_rare")
        local skillAttTitle = CSResourceMgr.seekNodeByName(panel1, "skill_att_title")
        local skillInfoTitle= CSResourceMgr.seekNodeByName(panel1, "skill_info_title")
        local skillDesc     = CSResourceMgr.seekNodeByName(panel1, "skill_info")
        local btnExchange   = CSResourceMgr.seekNodeByName(panel1, "btn_strength")
        local btnLvUp       = CSResourceMgr.seekNodeByName(panel1, "btn_lvup")
        local skillNode     = CSResourceMgr.seekNodeByName(panel1, "skill_node")

        local PetSkillIconMgr = require("src.GameMgr.Pet.PetSkillIconMgr")
        PetSkillIconMgr.createPetSkillIcon(skillNode, skillInfo)

        -- CSResourceMgr.setSpriteTextureByNode(skillIcon, skillIcon1)
        CSResourceMgr.setSpriteTextureByNode(skillRare, irareString[skillInfo.airpower-1])
        -- CSResourceMgr.setSpriteTextureByNode(attB, "Pet/AttriIcon/small_"..skillAttr1..".png")
        -- CSResourceMgr.setSpriteTextureByNode(attIcon, "Pet/AttriIcon/"..skillAttr1..".png")

        CSResourceMgr.setLabelStringByNode(title, "train45", nil, 1, 264)
        -- CSResourceMgr.setLabelStringByNode(skillLv, "Lv"..skillLv1)
        CSResourceMgr.setLabelStringByNode(skillName, skillName1)
        CSResourceMgr.setLabelStringByNode(skillRareTitle, LuaSqlite.getLanguageByKey("train76")..":", nil, 1, 72)
        CSResourceMgr.setLabelStringByNode(skillAttTitle, "train77", nil, 1, 110)
        CSResourceMgr.setLabelStringByNode(skillInfoTitle, "train78", nil, 1, 110)
        CSResourceMgr.setLabelStringByNode(skillDesc, skillDesc1)

        -- skillLv:enableOutline(outlineColor[1], LABLE_OUTLINE_THICK)
        skillName:enableOutline(outlineColor[1], LABLE_OUTLINE_THICK)

        local sameColorStr1 = {title,skillRareTitle,skillAttTitle,skillInfoTitle}
        for k,v in pairs(sameColorStr1) do
            CSResourceMgr.setLabelColorByNode(v, labelColor[3])
            v:enableOutline(outlineColor[3], LABLE_OUTLINE_THICK)
        end
        local attrText = {"skillType"..skillInfo.skill_A_Type, "skillType"..skillInfo.skill_B_Type, skillHitR, skillPower}
        for i = 1, #attrTitle do
            local labelTitle = CSResourceMgr.seekNodeByName(panel1, "label"..i)
            local text = CSResourceMgr.seekNodeByName(labelTitle, "text")
            CSResourceMgr.setLabelStringByNode(labelTitle, attrTitle[i], nil, 1, 72)
            CSResourceMgr.setLabelStringByNode(text, attrText[i], nil, 1, 86)
            CSResourceMgr.setLabelColorByNode(labelTitle, labelColor[3])
            CSResourceMgr.setLabelColorByNode(text, labelColor[5])
            labelTitle:enableOutline(outlineColor[3], LABLE_OUTLINE_THICK)
            text:enableOutline(outlineColor[1], LABLE_OUTLINE_THICK)
        end

        local petInfo = PokemonInfo.getPetInfoByObjID(objID)
        local info = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
        local itemInfoTable = EduSkillPageMgr.getExchangeSkills(petInfo, skillIndex)
        local canExchange = #itemInfoTable > 0 and skillType1 ~= 7 and skillType1 ~= 8
        CSResourceMgr.setButtonEnabledByNode(btnExchange, canExchange)
        CSResourceMgr.clickEventBindingByNode(btnExchange, function ()
            panel:setVisible(false)
            panel1:setVisible(false)
            EduSkillPageMgr.showExchangePage(scene, skillInfo, objID, skillIndex, function()
                panel:setVisible(true)
                panel1:setVisible(true)
                CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName_main, "panel1"), "down")
            end)
        end)

        canLvUp = (canLvUp == nil) and true or canLvUp
        local mCanLvUp = false
        if skillInfo.id then
            if skillInfo.id ~= 0 then
                if skillInfo.skillPresupposed ~= 0 then--skillPresupposed 下一级ID
                    mCanLvUp = true
                end
            end
        end
        CSResourceMgr.setButtonEnabledByNode(btnLvUp, (canLvUp and mCanLvUp))
        CSResourceMgr.clickEventBindingByNode(btnLvUp, function ()
            panel1:setVisible(false)
            EduSkillPageMgr.showSkillLvUpPage(scene, skillInfo, function ()
                panel1:setVisible(true)
                CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName_main, "panel1"), "down")
            end)
        end)
        if not operable then
            btnExchange:setVisible(false)
            btnLvUp:setVisible(false)
        end
    end

    local function playAction()
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName_main, "panel1"), "down")
    end

    local funcTable = {loadCSB, loadUI, playAction}
    -- UnblockLoader.load(funcTable)
    for i=1,#funcTable do
        funcTable[i]()
    end
end

function EduSkillPageMgr.hideSkillPage()
    CSResourceMgr.removeCSObjectByTag(resName_main)
end

function EduSkillPageMgr.showExchangePage(scene, skillInfo, objID, skillIndex, closeCallback)
    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, resName_exchange)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName_exchange)
        CSResourceMgr.setRelativePosition(resName_exchange, 320, 480)
        CSResourceMgr.clickEventBinding(resName_exchange,"btn_close",function()
            EduSkillPageMgr.hideExchangePage()
            if closeCallback then closeCallback() end
        end,"",true)
    end

    local function setSkillInfoByNode(node, skillInfo, isShowArrow, isUp)
        -- local skillIcon = CSResourceMgr.seekNodeByName(node, "skill_icon")
        -- local attB      = CSResourceMgr.seekNodeByName(node, "att_background")
        -- local attIcon   = CSResourceMgr.seekNodeByName(node, "att_icon")
        local skillName = CSResourceMgr.seekNodeByName(node, "skill_name")
        -- local skillRare = CSResourceMgr.seekNodeByName(node, "skill_rare")
        local skillDesc = CSResourceMgr.seekNodeByName(node, "skill_info")
        local buff      = CSResourceMgr.seekNodeByName(node, "buff")
        local skillNode = CSResourceMgr.seekNodeByName(node, "skill_node")

        local PetSkillIconMgr = require("src.GameMgr.Pet.PetSkillIconMgr")
        PetSkillIconMgr.createPetSkillIcon(skillNode, skillInfo)

        -- CSResourceMgr.setSpriteTextureByNode(skillIcon, "Battle/skillIcon/"..skillInfo.icon..".png")
        -- attB:loadTexture("Pet/AttriIcon/small_"..skillInfo.skillAtt..".png")
        -- attIcon:loadTexture("Pet/AttriIcon/"..skillInfo.skillAtt..".png")
        -- CSResourceMgr.setSpriteTextureByNode(skillRare, irareString[skillInfo.airpower-1])

        CSResourceMgr.setLabelStringByNode(skillName, skillInfo.name, outlineColor[1], 1, 192)
        CSResourceMgr.setLabelStringByNode(skillDesc, skillInfo.desc)
        CSResourceMgr.setLabelColorByNode(skillName, labelColor[5])
        CSResourceMgr.setLabelColorByNode(skillDesc, labelColor[4])
        
        local attrText = {"skillType"..skillInfo.skill_A_Type, "skillType"..skillInfo.skill_B_Type, 
                        (skillInfo.hitRate or 0), skillInfo.power}
        for i = 1, #attrTitle do
            local labelTitle = CSResourceMgr.seekNodeByName(node, "label"..i)
            local text = CSResourceMgr.seekNodeByName(labelTitle, "text")
            labelTitle:enableOutline(outlineColor[3], LABLE_OUTLINE_THICK)
            text:enableOutline(outlineColor[1], LABLE_OUTLINE_THICK)
            CSResourceMgr.setLabelStringByNode(labelTitle, attrTitle[i], nil, 1, 54)
            CSResourceMgr.setLabelStringByNode(text, attrText[i], nil, 1, 54)
            CSResourceMgr.setLabelColorByNode(labelTitle, labelColor[3])
            CSResourceMgr.setLabelColorByNode(text, labelColor[5])
        end
        if isShowArrow then
            CSResourceMgr.setSpriteTextureByNode(buff, isUp and 
                "Pet/Education/homepage/buff1.png" or "Pet/Education/homepage/buff2.png")
            local labelTitle2 = CSResourceMgr.seekNodeByName(node, "label2")
            local labelTitle4 = CSResourceMgr.seekNodeByName(node, "label4")
            local text1 = CSResourceMgr.seekNodeByName(labelTitle2, "text")
            local text2 = CSResourceMgr.seekNodeByName(labelTitle4, "text")
            CSResourceMgr.setLabelColorByNode(text1, labelColor[9])
            CSResourceMgr.setLabelColorByNode(text2, isUp and labelColor[9] or labelColor[8])
        end
    end

    local function setSkillSelected(node, isSelected)
        local itemSel = CSResourceMgr.seekNodeByName(node, "sel")
        itemSel:setVisible(isSelected)
    end

    local function loadUI()
        local panel         = CSResourceMgr.getNodeByName(resName_exchange, "panel")
        local panel1        = CSResourceMgr.getNodeByName(resName_exchange, "panel1")
        local panel2        = CSResourceMgr.getNodeByName(resName_exchange, "panel2")
        local panel3        = CSResourceMgr.getNodeByName(resName_exchange, "panel3")
        local title         = CSResourceMgr.seekNodeByName(panel, "name")

        local noItem1       = CSResourceMgr.seekNodeByName(panel, "noitem1")
        local noItem2       = CSResourceMgr.seekNodeByName(panel, "noitem2")
        local strNoItem1    = CSResourceMgr.seekNodeByName(noItem1, "str_noitem")
        local strNoItem2    = CSResourceMgr.seekNodeByName(noItem2, "str_noitem")
        local btnExchange   = CSResourceMgr.seekNodeByName(panel, "btn_exchange")
        local strExchange   = CSResourceMgr.seekNodeByName(panel, "str_exchange")

        CSResourceMgr.setLabelStringByNode(title, "train46")
        CSResourceMgr.setLabelColorByNode(title, labelColor[3])
        strExchange:enableOutline(outlineColor[6], CSResourceMgr.DEFAULT_LABEL_OUTLINE_BORDER)
        title:enableOutline(outlineColor[1], LABLE_OUTLINE_THICK)
        if not skillInfo.icon then
            noItem1:setVisible(true)
            panel1:setVisible(false)
            CSResourceMgr.setLabelStringByNode(strNoItem1, "train79")
            CSResourceMgr.setLabelColorByNode(strNoItem1, labelColor[3])
            strNoItem1:enableOutline(outlineColor[5], LABLE_OUTLINE_THICK)
            CSResourceMgr.setLabelStringByNode(strExchange, "train80")
            CSResourceMgr.setLabelColorByNode(strExchange, labelColor[1])
            skillInfo.power = 0
        else
            setSkillInfoByNode(panel1, skillInfo, false, false)
            CSResourceMgr.setLabelStringByNode(strExchange, "train81")
            CSResourceMgr.setLabelColorByNode(strExchange, labelColor[6])
        end

        local title2 = CSResourceMgr.seekNodeByName(panel2, "skill_att_title")
        CSResourceMgr.setLabelStringByNode(title2, "train46", nil, 1, 108)
        CSResourceMgr.setLabelColorByNode(title2, labelColor[3])

        local list = CSResourceMgr.seekNodeByName(panel2, "list")
        local item = CSResourceMgr.getNodeByName(resName_exchange, "item")
        local selectedItemIndex = 1
        local petInfo = PokemonInfo.getPetInfoByObjID(objID)
        local pokemonInfo = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
        local itemInfoTable = EduSkillPageMgr.getExchangeSkills(petInfo, skillIndex)
        if #itemInfoTable > 0 then
            local itemNode = {}
            for i = 1, #itemInfoTable do
                itemNode[i] = item:clone()
                itemNode[i]:setVisible(true)

                local itemIcon = CSResourceMgr.seekNodeByName(itemNode[i], "icon")
                local itemName = CSResourceMgr.seekNodeByName(itemNode[i], "name")
                CSResourceMgr.setSpriteTextureByNode(itemIcon, itemInfoTable[i].icon)
                CSResourceMgr.setLabelStringByNode(itemName, itemInfoTable[i].name, nil, nil, 90)
                itemName:enableOutline(outlineColor[1], LABLE_OUTLINE_THICK)
                list:pushBackCustomItem(itemNode[i])
            end
            for i = 1, #itemInfoTable do
                CSResourceMgr.clickEventBindingByNode(itemNode[i], function ()
                    setSkillSelected(itemNode[selectedItemIndex], false)
                    setSkillSelected(itemNode[i], true)
                    selectedItemIndex = i
                    selectedSkillInfo = PokemonInfo.getPetSkillInfoById(itemInfoTable[selectedItemIndex].paramA)
                    setSkillInfoByNode(panel3, selectedSkillInfo, true, (selectedSkillInfo.power > skillInfo.power))
                end)
            end
            setSkillSelected(itemNode[selectedItemIndex], true)
            selectedSkillInfo = PokemonInfo.getPetSkillInfoById(itemInfoTable[selectedItemIndex].paramA)
            setSkillInfoByNode(panel3, selectedSkillInfo, true, (selectedSkillInfo.power > skillInfo.power))
            CSResourceMgr.setButtonEnabledByNode(btnExchange, (#itemInfoTable > 0))
        else
            noItem2:setVisible(true)
            panel2:setVisible(false)
            panel3:setVisible(false)
            btnExchange:setVisible(false)
            strNoItem2:enableOutline(outlineColor[5], LABLE_OUTLINE_THICK)
            CSResourceMgr.setLabelStringByNode(strNoItem2, "train82")
            CSResourceMgr.setLabelColorByNode(strNoItem2, labelColor[3])
            -- CSResourceMgr.setLabelStringByNode(strExchange, "train80")
        end
        CSResourceMgr.clickEventBindingByNode(btnExchange, function ()
            NetInterface.sendWithBlock("GC_PokemonSkillChange_Ack", function()
                local PetEducationSend = require("src.Net.Send.PetEducationSend")
                PetEducationSend.sendCG_PokemonSkillChange_Req({
                    objID = petInfo.objID,
                    skillIndex = skillIndex - 1,
                    itemID = itemInfoTable[selectedItemIndex].id
                    })
                end,
                function ()
                    EduSkillPageMgr.hideExchangePage()
                    CSResourceMgr.removeCSObjectByTag("Pet/Education/homepage/skillPage.csb")
                end,
                function ()
                    DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 1, "train100")
                end)
        end)
    end

    local function playAction()
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName_exchange, "panel"), "down")
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName_exchange, "panel1"), "down")
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName_exchange, "panel2"), "down")
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName_exchange, "panel3"), "down")
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName_exchange, "btn"), "down")
    end

    local funcTable = {loadCSB, loadUI, playAction}
    UnblockLoader.load(funcTable)
    -- for i=1,#funcTable do
    --     funcTable[i]()
    -- end
end

function EduSkillPageMgr.hideExchangePage()
    CSResourceMgr.removeCSObjectByTag(resName_exchange)
end

--- 技能交换
function EduSkillPageMgr.showRePage(scene,skillInfo,objID,closeCallback)
    
end

function EduSkillPageMgr.hideRePage()
    local resName = "Pet/Education/homepage/skillPage_Chg.csb"
    EduSkillPageMgr.Init()
    CSResourceMgr.removeCSObjectByTag(resName)
end

--- 技能升级界面
function EduSkillPageMgr.showSkillLvUpPage(scene, curPetSkillInfo, closeCallback)
    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, resName_lvUp)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName_lvUp)
        CSResourceMgr.setRelativePosition(resName_lvUp, 320, 480)

        CSResourceMgr.clickEventBinding(resName_lvUp,"btn_close",function()
            EduSkillPageMgr.hideLvUpPage()
            if closeCallback then closeCallback() end
        end, "", true)
    end

    local function loadUI()
        local preinstall    = curPetSkillInfo.preinstall
        local skillInfo     = PokemonInfo.getPetSkillInfoById(preinstall)
        local skillIcon1    = skillInfo.icon and "Battle/skillIcon/"..skillInfo.icon..".png" or "empty.png"
        local skillName1    = skillInfo.name
        local skillAttr1    = skillInfo.skillAtt
        local skillDesc1    = skillInfo.desc
        local skillType1    = skillInfo.skill_A_Type
        local skillLv1      = (curPetSkillInfo.id % 5 == 0) and 5 or (curPetSkillInfo.id % 5)
        local curPower      = curSkillInfo.power
        local skillPower    = skillInfo.power
        local skillHitR     = skillInfo.hitRate or 0 --命中
        local itemID        = curSkillInfo.upItemType
        local itemCount     = ItemInfo.getCharItemNum(itemID)
        local itemInfo      = ItemInfo.getItemInfoById(itemID)

        local panel1        = CSResourceMgr.getNodeByName(resName_lvUp, "panel1")
        local panel2        = CSResourceMgr.getNodeByName(resName_lvUp, "panel2")
        local title         = CSResourceMgr.seekNodeByName(panel1, "name")
        -- local skillIcon     = CSResourceMgr.seekNodeByName(panel1, "skill_icon")
        -- local attB          = CSResourceMgr.seekNodeByName(panel1, "att_background")
        -- local attIcon       = CSResourceMgr.seekNodeByName(panel1, "att_icon")
        -- local skillLv       = CSResourceMgr.seekNodeByName(panel1, "skill_lv")
        local skillName     = CSResourceMgr.seekNodeByName(panel1, "skill_name")
        local skillRareTitle= CSResourceMgr.seekNodeByName(panel1, "skill_rare_title")
        local skillRare     = CSResourceMgr.seekNodeByName(panel1, "skill_rare")
        local skillAttTitle = CSResourceMgr.seekNodeByName(panel1, "skill_att_title")
        local skillInfoTitle= CSResourceMgr.seekNodeByName(panel1, "skill_info_title")
        local skillDesc     = CSResourceMgr.seekNodeByName(panel1, "skill_info")
        local skillNode     = CSResourceMgr.seekNodeByName(panel1, "skill_node")

        local PetSkillIconMgr = require("src.GameMgr.Pet.PetSkillIconMgr")
        PetSkillIconMgr.createPetSkillIcon(skillNode, skillInfo)

        -- CSResourceMgr.setSpriteTextureByNode(skillIcon, skillIcon1)
        CSResourceMgr.setSpriteTextureByNode(skillRare, irareString[skillInfo.airpower-1])
        -- attB:loadTexture("Pet/AttriIcon/small_"..skillAttr1..".png")
        -- attIcon:loadTexture("Pet/AttriIcon/"..skillAttr1..".png")

        CSResourceMgr.setLabelStringByNode(title, "train47")
        -- CSResourceMgr.setLabelStringByNode(skillLv, "Lv"..skillLv1, outlineColor[1])
        CSResourceMgr.setLabelStringByNode(skillName, skillName1, outlineColor[1], 1, 264)
        CSResourceMgr.setLabelStringByNode(skillRareTitle, LuaSqlite.getLanguageByKey("train76")..":", nil, 1, 72)
        CSResourceMgr.setLabelStringByNode(skillAttTitle, "train77", nil, 1, 110)
        CSResourceMgr.setLabelStringByNode(skillInfoTitle, "train78", nil, 1, 110)
        CSResourceMgr.setLabelStringByNode(skillDesc, skillDesc1)

        local sameColorStr1 = {title,skillRareTitle,skillAttTitle,skillInfoTitle}
        for k,v in pairs(sameColorStr1) do
            CSResourceMgr.setLabelColorByNode(v, labelColor[3])
            v:enableOutline(outlineColor[3], LABLE_OUTLINE_THICK)
        end
        local attrText = {"skillType"..skillInfo.skill_A_Type, "skillType"..skillInfo.skill_B_Type, skillHitR, curPower}
        for i = 1, #attrTitle do
            local labelTitle = CSResourceMgr.seekNodeByName(panel1, "label"..i)
            local text = CSResourceMgr.seekNodeByName(labelTitle, "text")
            CSResourceMgr.setLabelStringByNode(labelTitle, attrTitle[i], nil, 1, 72)
            CSResourceMgr.setLabelStringByNode(text, attrText[i], nil, 1, 86)
            CSResourceMgr.setLabelColorByNode(labelTitle, labelColor[3])
            CSResourceMgr.setLabelColorByNode(text, labelColor[5])
            labelTitle:enableOutline(outlineColor[3], LABLE_OUTLINE_THICK)
            text:enableOutline(outlineColor[1], LABLE_OUTLINE_THICK)
            if i == 4 then
                local text2 = CSResourceMgr.seekNodeByName(labelTitle, "text2")
                local buff  = CSResourceMgr.seekNodeByName(labelTitle, "buff")
                local powerChange = skillPower - curPower
                CSResourceMgr.setLabelStringByNode(text2, "+"..powerChange, nil, 1, 52)
                CSResourceMgr.setLabelColorByNode(text2, (powerChange > 0) and labelColor[9] or labelColor[8])
                CSResourceMgr.setSpriteTextureByNode(buff, (powerChange > 0) and 
                    "Pet/Education/homepage/buff1.png" or "Pet/Education/homepage/buff2.png")
                text2:setPositionX(text:getPositionX() + text:getContentSize().width + 2)
                buff:setPositionX(text2:getPositionX() + text2:getContentSize().width + 20)
            end
        end

        local labelNeedResTitle = CSResourceMgr.seekNodeByName(panel2, "res_need_name")
        local labelStrengthen   = CSResourceMgr.seekNodeByName(panel2, "str_stength")
        local btnStrengthen     = CSResourceMgr.seekNodeByName(panel2, "btn_strength")
        CSResourceMgr.setLabelStringByNode(labelNeedResTitle, "train27", outlineColor[4], 1, 168)
        CSResourceMgr.setLabelStringByNode(labelStrengthen,   "train47")
        CSResourceMgr.setLabelColorByNode(labelStrengthen,    labelColor[6])
        labelStrengthen:enableOutline(outlineColor[6], CSResourceMgr.DEFAULT_LABEL_OUTLINE_BORDER)

        if skillLv1 == 5 then --技能已MAX
            return
        end
        local needItemNum1 = SystemInfo.getGlobalConfigAddInfoByID(6400+skillLv1).values[1]--需要技能书数量
        local needItemNum2 = SystemInfo.getGlobalConfigAddInfoByID(6550+skillInfo.airpower).values[1]
        local needItemNum = needItemNum1 * needItemNum2
        local haveEnoughRes = (itemCount >= needItemNum)
        CSResourceMgr.setButtonEnabledByNode(btnStrengthen, haveEnoughRes)
        CSResourceMgr.clickEventBindingByNode(btnStrengthen, function ()
            local index = 1
            local petInfo = PokemonInfo.getPetInfoByObjID(objID)
            for i=1,#petInfo.skills do
                if petInfo.skills[i] == curSkillInfo.id then
                    break
                end
                index = index + 1
            end
            NetInterface.sendWithBlock("GC_POKEMONSKILLLEVELUP_ACK", function()
                local PetEducationSend = require("src.Net.Send.PetEducationSend")
                PetEducationSend.sendCG_PokemonSkillLevelUp_Req({
                    objID = petInfo.objID,
                    skillIndex = index - 1
                    })
                    end,
                    function ()
                        EduSkillPageMgr.hideLvUpPage()
                        EduSkillPageMgr.hideSkillPage()
                        CSResourceMgr.removeCSObjectByTag(resName_lvUp)
                        CSResourceMgr.removeCSObjectByTag(resName)
                    end,
                    function (code)
                        print("failed PokemonSkillLevelUp! code : ",code)
                    end)
        end)

        local btnRes = CSResourceMgr.seekNodeByName(panel2, "btn_res")
        local resIcon = CSResourceMgr.seekNodeByName(btnRes, "res_icon")
        local resNum = CSResourceMgr.seekNodeByName(btnRes, "res_num")
        local spriteBG = ItemInfo.getItemRareBGImage(itemID)
        CSResourceMgr.setSpriteTextureByNode(resIcon, itemInfo.icon)
        CSResourceMgr.setButtonTextureByNode(btnRes, spriteBG, spriteBG, spriteBG)
        CSResourceMgr.setLabelStringByNode(resNum, itemCount.."/"..needItemNum)
        CSResourceMgr.setLabelColorByNode(resNum, (itemCount >= needItemNum) and labelColor[1] or labelColor[7])
        resNum:enableOutline(outlineColor[1], LABLE_OUTLINE_THICK)
        btnRes:setVisible(true)
        CSResourceMgr.clickEventBindingByNode(btnRes, function ()
            ItemInfoViewMgr.show({id = itemInfo.id}, false)
        end, 3)
    end

    local function playAction()
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName_lvUp, "panel1"), "down")
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName_lvUp, "panel2"), "down")
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName_lvUp, "btn"), "down")
    end

    local funcTable = {loadCSB, loadUI, playAction}
    UnblockLoader.load(funcTable)
    -- for i = 1, #funcTable do
    --     funcTable[i]()
    -- end
end

function EduSkillPageMgr.hideLvUpPage()
    CSResourceMgr.removeCSObjectByTag(resName_lvUp)
end

function EduSkillPageMgr.getAllSkill()   -- 获取背包中所有道具
    local charItemInfo = ItemInfo.getCharItemInfo()
    for k,v in pairs(charItemInfo) do
        local i_info = ItemInfo.getItemInfoById(k)
        if i_info.itemType == 1 then  -- 1:技能卡
            table.insert(skill_info_table,i_info)
        end
    end
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

function EduSkillPageMgr.getValidSkills(petInfo, elementAtt1, elementAtt2)
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

function EduSkillPageMgr.getExchangeSkills(petInfo, skillIndex)
    local groundpowerList = {}
    for k,v in pairs(petInfo.skills) do
        if v ~= 0 then
            local gp = PokemonInfo.getPetSkillInfoById(v).groundpower
            table.insert(groundpowerList, gp)
        end
    end
    local equipedSkillID = petInfo.skills[skillIndex]
    local equipedSkillInfo = {}
    if equipedSkillID and equipedSkillID ~= 0 then
        equipedSkillInfo = PokemonInfo.getPetSkillInfoById(equipedSkillID)
    end

    local index = 1
    local pokeID = petInfo.pokeID
    local pokemonInfo = PokemonInfo.getPokemonInfoByID(pokeID)
    local elementAtt1 = pokemonInfo.elementAtt1
    local elementAtt2 = pokemonInfo.elementAtt2
    local skillItems = {}
    local charItemInfo = ItemInfo.getSkillBookInfo()--拥有技能书
    for k,v in pairs(charItemInfo) do
        local itemInfo = ItemInfo.getItemInfoById(k)
        local skillInfo = PokemonInfo.getPetSkillInfoById(itemInfo.paramA)
        if skillInfo.skillAtt == elementAtt1 or skillInfo.skillAtt == elementAtt2 or skillInfo.skillAtt == 1 then
            if equipedSkillID and equipedSkillID ~= 0 then
                if equipedSkillInfo.skill_A_Type == skillInfo.skill_A_Type then
                    local canExchange = true
                    for k1,v1 in pairs(groundpowerList) do
                        if skillInfo.groundpower == v1 then
                            canExchange = false
                            break
                        end
                    end
                    if canExchange == true then
                        table.insert(skillItems, itemInfo)
                    end
                end
            else
                if skillIndex == 4 then
                    if skillInfo.skill_A_Type == 1 then--1是奥义
                        local canExchange = true
                        for k1,v1 in pairs(groundpowerList) do
                            if skillInfo.groundpower == v1 then
                                canExchange = false
                                break
                            end
                        end
                        if canExchange == true then
                            table.insert(skillItems, itemInfo)
                        end
                    end
                else
                    if skillInfo.skill_A_Type == 0 then--0是主动
                        local canExchange = true
                        for k1,v1 in pairs(groundpowerList) do
                            if skillInfo.groundpower == v1 then
                                canExchange = false
                                break
                            end
                        end
                        if canExchange == true then
                            table.insert(skillItems, itemInfo)
                        end
                    end
                end
            end
        end
    end
    return skillItems
end

--被动技能
function EduSkillPageMgr.showPaSkillPage(scene, skillInfo, objid, skillIndex)
    skillInfo = skillInfo or {}
    curSkillInfo = skillInfo
    objID = objid

    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, resName_main)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName_main, 320, 480)
        CSResourceMgr.clickEventBinding(resName_main,"btn_close",function()
            EduSkillPageMgr.hideSkillPage()
        end)
    end

    local function loadUI()
        local skillIcon1    = skillInfo.icon and "Battle/skillIcon/"..skillInfo.icon..".png" or "empty.png"
        local skillName1    = skillInfo.name
        local skillAttr1    = skillInfo.skillAtt
        local skillDesc1    = skillInfo.desc
        local skillType1    = skillInfo.skill_A_Type
        local skillLv1      = (skillInfo.id % 5 == 0) and 5 or (skillInfo.id % 5)
        local skillPower    = skillInfo.power
        local skillHitR     = skillInfo.hitRate or 0 --命中

        local panel         = CSResourceMgr.getNodeByName(resName_main, "btn")
        local panel1        = CSResourceMgr.getNodeByName(resName_main, "panel1")
        local title         = CSResourceMgr.seekNodeByName(panel1, "name")
        -- local skillIcon     = CSResourceMgr.seekNodeByName(panel1, "skill_icon")
        -- local attB          = CSResourceMgr.seekNodeByName(panel1, "att_background")
        -- local attIcon       = CSResourceMgr.seekNodeByName(panel1, "att_icon")
        -- local skillLv       = CSResourceMgr.seekNodeByName(panel1, "skill_lv")
        local skillName     = CSResourceMgr.seekNodeByName(panel1, "skill_name")
        local skillRareTitle= CSResourceMgr.seekNodeByName(panel1, "skill_rare_title")
        local skillRare     = CSResourceMgr.seekNodeByName(panel1, "skill_rare")
        local skillAttTitle = CSResourceMgr.seekNodeByName(panel1, "skill_att_title")
        local skillInfoTitle= CSResourceMgr.seekNodeByName(panel1, "skill_info_title")
        local skillDesc     = CSResourceMgr.seekNodeByName(panel1, "skill_info")
        local btnExchange   = CSResourceMgr.seekNodeByName(panel1, "btn_strength")
        local btnLvUp       = CSResourceMgr.seekNodeByName(panel1, "btn_lvup")
        local skillNode     = CSResourceMgr.seekNodeByName(panel1, "skill_node")

        local PetSkillIconMgr = require("src.GameMgr.Pet.PetSkillIconMgr")
        PetSkillIconMgr.createPetSkillIcon(skillNode, skillInfo)

        -- CSResourceMgr.setSpriteTextureByNode(skillIcon, skillIcon1)
        CSResourceMgr.setSpriteTextureByNode(skillRare, irareString[skillInfo.airpower-1])
        -- CSResourceMgr.setSpriteTextureByNode(attB, "Pet/AttriIcon/small_"..skillAttr1..".png")
        -- CSResourceMgr.setSpriteTextureByNode(attIcon, "Pet/AttriIcon/"..skillAttr1..".png")

        CSResourceMgr.setLabelStringByNode(title, "train45", nil, 1, 264)
        -- CSResourceMgr.setLabelStringByNode(skillLv, "Lv"..skillLv1)
        CSResourceMgr.setLabelStringByNode(skillName, skillName1)
        CSResourceMgr.setLabelStringByNode(skillRareTitle, LuaSqlite.getLanguageByKey("train76")..":", nil, 1, 72)
        CSResourceMgr.setLabelStringByNode(skillAttTitle, "train77", nil, 1, 110)
        CSResourceMgr.setLabelStringByNode(skillInfoTitle, "train78", nil, 1, 110)
        CSResourceMgr.setLabelStringByNode(skillDesc, skillDesc1)

        -- skillLv:enableOutline(outlineColor[1], LABLE_OUTLINE_THICK)
        skillName:enableOutline(outlineColor[1], LABLE_OUTLINE_THICK)

        local sameColorStr1 = {title,skillRareTitle,skillAttTitle,skillInfoTitle}
        for k,v in pairs(sameColorStr1) do
            CSResourceMgr.setLabelColorByNode(v, labelColor[3])
            v:enableOutline(outlineColor[3], LABLE_OUTLINE_THICK)
        end
        local attrText = {"skillType"..skillInfo.skill_A_Type, "skillType"..skillInfo.skill_B_Type, skillHitR, skillPower}
        for i = 1, #attrTitle do
            local labelTitle = CSResourceMgr.seekNodeByName(panel1, "label"..i)
            local text = CSResourceMgr.seekNodeByName(labelTitle, "text")
            CSResourceMgr.setLabelStringByNode(labelTitle, attrTitle[i], nil, 1, 72)
            CSResourceMgr.setLabelStringByNode(text, attrText[i], nil, 1, 86)
            CSResourceMgr.setLabelColorByNode(labelTitle, labelColor[3])
            CSResourceMgr.setLabelColorByNode(text, labelColor[5])
            labelTitle:enableOutline(outlineColor[3], LABLE_OUTLINE_THICK)
            text:enableOutline(outlineColor[1], LABLE_OUTLINE_THICK)
        end

        local petInfo = PokemonInfo.getPetInfoByObjID(objID)
        local info = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
        local itemInfoTable = EduSkillPageMgr.getPaExchangeSkills(petInfo, skillIndex)
        local canExchange = #itemInfoTable > 0 and skillType1 ~= 7 and skillType1 ~= 8
        CSResourceMgr.setButtonEnabledByNode(btnExchange, canExchange)
        CSResourceMgr.clickEventBindingByNode(btnExchange, function ()
            panel:setVisible(false)
            panel1:setVisible(false)
            EduSkillPageMgr.showPaExchangePage(scene, skillInfo, objID, skillIndex, function()
                panel:setVisible(true)
                panel1:setVisible(true)
                CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName_main, "panel1"), "down")
            end)
        end)

        local mCanLvUp = false
        if skillInfo.id then
            if skillInfo.id ~= 0 then
                if skillInfo.skillPresupposed ~= 0 then--skillPresupposed 下一级ID
                    mCanLvUp = true
                end
            end
        end
        CSResourceMgr.setButtonEnabledByNode(btnLvUp, mCanLvUp)
        CSResourceMgr.clickEventBindingByNode(btnLvUp, function ()
            panel1:setVisible(false)
            EduSkillPageMgr.showPaSkillLvUpPage(scene, skillInfo, function ()
                panel1:setVisible(true)
                CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName_main, "panel1"), "down")
            end)
        end)
    end

    local function playAction()
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName_main, "panel1"), "down")
    end

    local funcTable = {loadCSB, loadUI, playAction}
    -- UnblockLoader.load(funcTable)
    for i=1,#funcTable do
        funcTable[i]()
    end
end

function EduSkillPageMgr.showPaExchangePage(scene, skillInfo, objID, skillIndex, closeCallback)
    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, resName_exchange)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName_exchange)
        CSResourceMgr.setRelativePosition(resName_exchange, 320, 480)
        CSResourceMgr.clickEventBinding(resName_exchange,"btn_close",function()
            EduSkillPageMgr.hideExchangePage()
            if closeCallback then closeCallback() end
        end,"",true)
    end

    local function setSkillInfoByNode(node, skillInfo, isShowArrow, isUp)
        -- local skillIcon = CSResourceMgr.seekNodeByName(node, "skill_icon")
        -- local attB      = CSResourceMgr.seekNodeByName(node, "att_background")
        -- local attIcon   = CSResourceMgr.seekNodeByName(node, "att_icon")
        local skillName = CSResourceMgr.seekNodeByName(node, "skill_name")
        -- local skillRare = CSResourceMgr.seekNodeByName(node, "skill_rare")
        local skillDesc = CSResourceMgr.seekNodeByName(node, "skill_info")
        local buff      = CSResourceMgr.seekNodeByName(node, "buff")
        local skillNode = CSResourceMgr.seekNodeByName(node, "skill_node")

        local PetSkillIconMgr = require("src.GameMgr.Pet.PetSkillIconMgr")
        PetSkillIconMgr.createPetSkillIcon(skillNode, skillInfo)

        -- CSResourceMgr.setSpriteTextureByNode(skillIcon, "Battle/skillIcon/"..skillInfo.icon..".png")
        -- attB:loadTexture("Pet/AttriIcon/small_"..skillInfo.skillAtt..".png")
        -- attIcon:loadTexture("Pet/AttriIcon/"..skillInfo.skillAtt..".png")
        -- CSResourceMgr.setSpriteTextureByNode(skillRare, irareString[skillInfo.airpower-1])

        CSResourceMgr.setLabelStringByNode(skillName, skillInfo.name, outlineColor[1], 1, 192)
        CSResourceMgr.setLabelStringByNode(skillDesc, skillInfo.desc)
        CSResourceMgr.setLabelColorByNode(skillName, labelColor[5])
        CSResourceMgr.setLabelColorByNode(skillDesc, labelColor[4])
        
        local attrText = {"skillType"..skillInfo.skill_A_Type, "skillType"..skillInfo.skill_B_Type, 
                        (skillInfo.hitRate or 0), skillInfo.power}
        for i = 1, #attrTitle do
            local labelTitle = CSResourceMgr.seekNodeByName(node, "label"..i)
            local text = CSResourceMgr.seekNodeByName(labelTitle, "text")
            labelTitle:enableOutline(outlineColor[3], LABLE_OUTLINE_THICK)
            text:enableOutline(outlineColor[1], LABLE_OUTLINE_THICK)
            CSResourceMgr.setLabelStringByNode(labelTitle, attrTitle[i], nil, 1, 54)
            CSResourceMgr.setLabelStringByNode(text, attrText[i], nil, 1, 54)
            CSResourceMgr.setLabelColorByNode(labelTitle, labelColor[3])
            CSResourceMgr.setLabelColorByNode(text, labelColor[5])
        end
        if isShowArrow then
            CSResourceMgr.setSpriteTextureByNode(buff, isUp and 
                "Pet/Education/homepage/buff1.png" or "Pet/Education/homepage/buff2.png")
            local labelTitle2 = CSResourceMgr.seekNodeByName(node, "label2")
            local labelTitle4 = CSResourceMgr.seekNodeByName(node, "label4")
            local text1 = CSResourceMgr.seekNodeByName(labelTitle2, "text")
            local text2 = CSResourceMgr.seekNodeByName(labelTitle4, "text")
            CSResourceMgr.setLabelColorByNode(text1, labelColor[9])
            CSResourceMgr.setLabelColorByNode(text2, isUp and labelColor[9] or labelColor[8])
        end
    end

    local function setSkillSelected(node, isSelected)
        local itemSel = CSResourceMgr.seekNodeByName(node, "sel")
        itemSel:setVisible(isSelected)
    end

    local function loadUI()
        local panel         = CSResourceMgr.getNodeByName(resName_exchange, "panel")
        local panel1        = CSResourceMgr.getNodeByName(resName_exchange, "panel1")
        local panel2        = CSResourceMgr.getNodeByName(resName_exchange, "panel2")
        local panel3        = CSResourceMgr.getNodeByName(resName_exchange, "panel3")
        local title         = CSResourceMgr.seekNodeByName(panel, "name")

        local noItem1       = CSResourceMgr.seekNodeByName(panel, "noitem1")
        local noItem2       = CSResourceMgr.seekNodeByName(panel, "noitem2")
        local strNoItem1    = CSResourceMgr.seekNodeByName(noItem1, "str_noitem")
        local strNoItem2    = CSResourceMgr.seekNodeByName(noItem2, "str_noitem")
        local btnExchange   = CSResourceMgr.seekNodeByName(panel, "btn_exchange")
        local strExchange   = CSResourceMgr.seekNodeByName(panel, "str_exchange")

        CSResourceMgr.setLabelStringByNode(title, "train46")
        CSResourceMgr.setLabelColorByNode(title, labelColor[3])
        strExchange:enableOutline(outlineColor[6], CSResourceMgr.DEFAULT_LABEL_OUTLINE_BORDER)
        title:enableOutline(outlineColor[1], LABLE_OUTLINE_THICK)
        if not skillInfo.icon then
            noItem1:setVisible(true)
            panel1:setVisible(false)
            CSResourceMgr.setLabelStringByNode(strNoItem1, "train79")
            CSResourceMgr.setLabelColorByNode(strNoItem1, labelColor[3])
            strNoItem1:enableOutline(outlineColor[5], LABLE_OUTLINE_THICK)
            CSResourceMgr.setLabelStringByNode(strExchange, "train80")
            CSResourceMgr.setLabelColorByNode(strExchange, labelColor[1])
            skillInfo.power = 0
        else
            setSkillInfoByNode(panel1, skillInfo, false, false)
            CSResourceMgr.setLabelStringByNode(strExchange, "train81")
            CSResourceMgr.setLabelColorByNode(strExchange, labelColor[6])
        end

        local title2 = CSResourceMgr.seekNodeByName(panel2, "skill_att_title")
        CSResourceMgr.setLabelStringByNode(title2, "train46", nil, 1, 108)
        CSResourceMgr.setLabelColorByNode(title2, labelColor[3])

        local list = CSResourceMgr.seekNodeByName(panel2, "list")
        local item = CSResourceMgr.getNodeByName(resName_exchange, "item")
        local selectedItemIndex = 1
        local petInfo = PokemonInfo.getPetInfoByObjID(objID)
        local pokemonInfo = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
        local itemInfoTable = EduSkillPageMgr.getPaExchangeSkills(petInfo, skillIndex)
        if #itemInfoTable > 0 then
            local itemNode = {}
            for i = 1, #itemInfoTable do
                itemNode[i] = item:clone()
                itemNode[i]:setVisible(true)

                local itemIcon = CSResourceMgr.seekNodeByName(itemNode[i], "icon")
                local itemName = CSResourceMgr.seekNodeByName(itemNode[i], "name")
                CSResourceMgr.setSpriteTextureByNode(itemIcon, itemInfoTable[i].icon)
                CSResourceMgr.setLabelStringByNode(itemName, itemInfoTable[i].name, nil, nil, 90)
                itemName:enableOutline(outlineColor[1], LABLE_OUTLINE_THICK)
                list:pushBackCustomItem(itemNode[i])
            end
            for i = 1, #itemInfoTable do
                CSResourceMgr.clickEventBindingByNode(itemNode[i], function ()
                    setSkillSelected(itemNode[selectedItemIndex], false)
                    setSkillSelected(itemNode[i], true)
                    selectedItemIndex = i
                    selectedSkillInfo = PokemonInfo.getPetSkillInfoById(itemInfoTable[selectedItemIndex].paramA)
                    setSkillInfoByNode(panel3, selectedSkillInfo, true, (selectedSkillInfo.power > skillInfo.power))
                end)
            end
            setSkillSelected(itemNode[selectedItemIndex], true)
            selectedSkillInfo = PokemonInfo.getPetSkillInfoById(itemInfoTable[selectedItemIndex].paramA)
            setSkillInfoByNode(panel3, selectedSkillInfo, true, (selectedSkillInfo.power > skillInfo.power))
            CSResourceMgr.setButtonEnabledByNode(btnExchange, (#itemInfoTable > 0))
        else
            noItem2:setVisible(true)
            panel2:setVisible(false)
            panel3:setVisible(false)
            btnExchange:setVisible(false)
            strNoItem2:enableOutline(outlineColor[5], LABLE_OUTLINE_THICK)
            CSResourceMgr.setLabelStringByNode(strNoItem2, "train82")
            CSResourceMgr.setLabelColorByNode(strNoItem2, labelColor[3])
        end
        CSResourceMgr.clickEventBindingByNode(btnExchange, function ()
            print(""..skillIndex - 1)
            NetInterface.sendWithBlock("GC_PokemonSkillChange_Ack", function()
                local PetEducationSend = require("src.Net.Send.PetEducationSend")
                PetEducationSend.sendCG_PokemonSkillChange_Req({
                    objID = petInfo.objID,
                    skillIndex = skillIndex - 1 + 4,
                    itemID = itemInfoTable[selectedItemIndex].id
                    })
                end,
                function ()
                    EduSkillPageMgr.hideExchangePage()
                    CSResourceMgr.removeCSObjectByTag("Pet/Education/homepage/skillPage.csb")
                end,
                function ()
                    DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 1, "train100")
                end)
        end)
    end

    local function playAction()
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName_exchange, "panel"), "down")
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName_exchange, "panel1"), "down")
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName_exchange, "panel2"), "down")
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName_exchange, "panel3"), "down")
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName_exchange, "btn"), "down")
    end

    local funcTable = {loadCSB, loadUI, playAction}
    -- UnblockLoader.load(funcTable)
    for i=1,#funcTable do
        funcTable[i]()
    end
end

function EduSkillPageMgr.showPaSkillLvUpPage(scene, curPetSkillInfo, closeCallback)
    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, resName_lvUp)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName_lvUp)
        CSResourceMgr.setRelativePosition(resName_lvUp, 320, 480)

        CSResourceMgr.clickEventBinding(resName_lvUp,"btn_close",function()
            EduSkillPageMgr.hideLvUpPage()
            if closeCallback then closeCallback() end
        end, "", true)
    end

    local function loadUI()
        local preinstall    = curPetSkillInfo.preinstall
        print("curPetSkillInfo id : ",curPetSkillInfo.id)
        print("preinstall id : ",preinstall)
        local skillInfo     = PokemonInfo.getPetSkillInfoById(preinstall)
        local skillIcon1    = skillInfo.icon and "Battle/skillIcon/"..skillInfo.icon..".png" or "empty.png"
        local skillName1    = skillInfo.name
        local skillAttr1    = skillInfo.skillAtt
        local skillDesc1    = skillInfo.desc
        local skillType1    = skillInfo.skill_A_Type
        local skillLv1      = (curPetSkillInfo.id % 5 == 0) and 5 or (curPetSkillInfo.id % 5)
        local curPower      = curSkillInfo.power
        local skillPower    = skillInfo.power
        local skillHitR     = skillInfo.hitRate or 0 --命中
        local itemID        = curSkillInfo.upItemType
        local itemCount     = ItemInfo.getCharItemNum(itemID)
        local itemInfo      = ItemInfo.getItemInfoById(itemID)

        local panel1        = CSResourceMgr.getNodeByName(resName_lvUp, "panel1")
        local panel2        = CSResourceMgr.getNodeByName(resName_lvUp, "panel2")
        local title         = CSResourceMgr.seekNodeByName(panel1, "name")
        -- local skillIcon     = CSResourceMgr.seekNodeByName(panel1, "skill_icon")
        -- local attB          = CSResourceMgr.seekNodeByName(panel1, "att_background")
        -- local attIcon       = CSResourceMgr.seekNodeByName(panel1, "att_icon")
        -- local skillLv       = CSResourceMgr.seekNodeByName(panel1, "skill_lv")
        local skillName     = CSResourceMgr.seekNodeByName(panel1, "skill_name")
        local skillRareTitle= CSResourceMgr.seekNodeByName(panel1, "skill_rare_title")
        local skillRare     = CSResourceMgr.seekNodeByName(panel1, "skill_rare")
        local skillAttTitle = CSResourceMgr.seekNodeByName(panel1, "skill_att_title")
        local skillInfoTitle= CSResourceMgr.seekNodeByName(panel1, "skill_info_title")
        local skillDesc     = CSResourceMgr.seekNodeByName(panel1, "skill_info")
        local skillNode     = CSResourceMgr.seekNodeByName(panel1, "skill_node")

        local PetSkillIconMgr = require("src.GameMgr.Pet.PetSkillIconMgr")
        PetSkillIconMgr.createPetSkillIcon(skillNode, skillInfo)

        -- CSResourceMgr.setSpriteTextureByNode(skillIcon, skillIcon1)
        CSResourceMgr.setSpriteTextureByNode(skillRare, irareString[skillInfo.airpower-1])
        -- attB:loadTexture("Pet/AttriIcon/small_"..skillAttr1..".png")
        -- attIcon:loadTexture("Pet/AttriIcon/"..skillAttr1..".png")

        CSResourceMgr.setLabelStringByNode(title, "train47")
        -- CSResourceMgr.setLabelStringByNode(skillLv, "Lv"..skillLv1, outlineColor[1])
        CSResourceMgr.setLabelStringByNode(skillName, skillName1, outlineColor[1], 1, 264)
        CSResourceMgr.setLabelStringByNode(skillRareTitle, LuaSqlite.getLanguageByKey("train76")..":", nil, 1, 72)
        CSResourceMgr.setLabelStringByNode(skillAttTitle, "train77", nil, 1, 110)
        CSResourceMgr.setLabelStringByNode(skillInfoTitle, "train78", nil, 1, 110)
        CSResourceMgr.setLabelStringByNode(skillDesc, skillDesc1)

        local sameColorStr1 = {title,skillRareTitle,skillAttTitle,skillInfoTitle}
        for k,v in pairs(sameColorStr1) do
            CSResourceMgr.setLabelColorByNode(v, labelColor[3])
            v:enableOutline(outlineColor[3], LABLE_OUTLINE_THICK)
        end
        local attrText = {"skillType"..skillInfo.skill_A_Type, "skillType"..skillInfo.skill_B_Type, skillHitR, curPower}
        for i = 1, #attrTitle do
            local labelTitle = CSResourceMgr.seekNodeByName(panel1, "label"..i)
            local text = CSResourceMgr.seekNodeByName(labelTitle, "text")
            CSResourceMgr.setLabelStringByNode(labelTitle, attrTitle[i], nil, 1, 72)
            CSResourceMgr.setLabelStringByNode(text, attrText[i], nil, 1, 86)
            CSResourceMgr.setLabelColorByNode(labelTitle, labelColor[3])
            CSResourceMgr.setLabelColorByNode(text, labelColor[5])
            labelTitle:enableOutline(outlineColor[3], LABLE_OUTLINE_THICK)
            text:enableOutline(outlineColor[1], LABLE_OUTLINE_THICK)
            if i == 4 then
                local text2 = CSResourceMgr.seekNodeByName(labelTitle, "text2")
                local buff  = CSResourceMgr.seekNodeByName(labelTitle, "buff")
                local powerChange = skillPower - curPower
                CSResourceMgr.setLabelStringByNode(text2, "+"..powerChange, nil, 1, 52)
                CSResourceMgr.setLabelColorByNode(text2, (powerChange > 0) and labelColor[9] or labelColor[8])
                CSResourceMgr.setSpriteTextureByNode(buff, (powerChange > 0) and 
                    "Pet/Education/homepage/buff1.png" or "Pet/Education/homepage/buff2.png")
                text2:setPositionX(text:getPositionX() + text:getContentSize().width + 2)
                buff:setPositionX(text2:getPositionX() + text2:getContentSize().width + 20)
            end
        end

        local labelNeedResTitle = CSResourceMgr.seekNodeByName(panel2, "res_need_name")
        local labelStrengthen   = CSResourceMgr.seekNodeByName(panel2, "str_stength")
        local btnStrengthen     = CSResourceMgr.seekNodeByName(panel2, "btn_strength")
        CSResourceMgr.setLabelStringByNode(labelNeedResTitle, "train27", outlineColor[4], 1, 168)
        CSResourceMgr.setLabelStringByNode(labelStrengthen,   "train47")
        CSResourceMgr.setLabelColorByNode(labelStrengthen,    labelColor[6])
        labelStrengthen:enableOutline(outlineColor[6], CSResourceMgr.DEFAULT_LABEL_OUTLINE_BORDER)

        if skillLv1 == 5 then --技能已MAX
            return
        end
        local needItemNum1 = SystemInfo.getGlobalConfigAddInfoByID(6400+skillLv1).values[1]--需要技能书数量
        local needItemNum2 = SystemInfo.getGlobalConfigAddInfoByID(6550+skillInfo.airpower).values[1]
        local needItemNum = needItemNum1 * needItemNum2
        local haveEnoughRes = (itemCount >= needItemNum)
        CSResourceMgr.setButtonEnabledByNode(btnStrengthen, haveEnoughRes)
        CSResourceMgr.clickEventBindingByNode(btnStrengthen, function ()
            local index = 1
            local petInfo = PokemonInfo.getPetInfoByObjID(objID)
            for i=1,#petInfo.paSkills do
                if petInfo.paSkills[i]["paSkillID"] == curSkillInfo.id then
                    break
                end
                index = index + 1
            end
            NetInterface.sendWithBlock("GC_POKEMONSKILLLEVELUP_ACK", function()
                local PetEducationSend = require("src.Net.Send.PetEducationSend")
                PetEducationSend.sendCG_PokemonSkillLevelUp_Req({
                    objID = petInfo.objID,
                    skillIndex = index - 1 + 4
                    })
                    end,
                    function ()
                        EduSkillPageMgr.hideLvUpPage()
                        EduSkillPageMgr.hideSkillPage()
                        CSResourceMgr.removeCSObjectByTag(resName_lvUp)
                        CSResourceMgr.removeCSObjectByTag(resName)
                    end,
                    function ()
                        print("failed PokemonSkillLevelUp!")
                    end)
        end)

        local btnRes = CSResourceMgr.seekNodeByName(panel2, "btn_res")
        local resIcon = CSResourceMgr.seekNodeByName(btnRes, "res_icon")
        local resNum = CSResourceMgr.seekNodeByName(btnRes, "res_num")
        local spriteBG = ItemInfo.getItemRareBGImage(itemID)
        CSResourceMgr.setSpriteTextureByNode(resIcon, itemInfo.icon)
        CSResourceMgr.setButtonTextureByNode(btnRes, spriteBG, spriteBG, spriteBG)
        CSResourceMgr.setLabelStringByNode(resNum, itemCount.."/"..needItemNum)
        CSResourceMgr.setLabelColorByNode(resNum, (itemCount >= needItemNum) and labelColor[1] or labelColor[7])
        resNum:enableOutline(outlineColor[1], LABLE_OUTLINE_THICK)
        btnRes:setVisible(true)
        CSResourceMgr.clickEventBindingByNode(btnRes, function ()
            ItemInfoViewMgr.show({id = itemInfo.id}, false)
        end, 3)
    end

    local function playAction()
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName_lvUp, "panel1"), "down")
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName_lvUp, "panel2"), "down")
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName_lvUp, "btn"), "down")
    end

    local funcTable = {loadCSB, loadUI, playAction}
    UnblockLoader.load(funcTable)
    -- for i = 1, #funcTable do
    --     funcTable[i]()
    -- end
end

function EduSkillPageMgr.getPaExchangeSkills(petInfo, skillIndex)
    local groundpowerList = {}
    for k,v in pairs(petInfo.paSkills) do
        if v["paSkillID"] and v["paSkillID"] ~= 0 then
            local gp = PokemonInfo.getPetSkillInfoById(v["paSkillID"]).groundpower
            table.insert(groundpowerList, gp)
        end
    end
    local equipedSkillInfo = {}
    local equipedSkillID = petInfo.paSkills[skillIndex]["paSkillID"]
    local equipedSkillType = petInfo.paSkills[skillIndex]["paSkillType"]
    if equipedSkillID ~= 0 then
        equipedSkillInfo = PokemonInfo.getPetSkillInfoById(equipedSkillID)
    end

    local index = 1
    local pokeID = petInfo.pokeID
    local pokemonInfo = PokemonInfo.getPokemonInfoByID(pokeID)
    local elementAtt1 = pokemonInfo.elementAtt1
    local elementAtt2 = pokemonInfo.elementAtt2
    local skillItems = {}
    local charItemInfo = ItemInfo.getSkillBookInfo()--拥有技能书
    for k,v in pairs(charItemInfo) do
        local itemInfo = ItemInfo.getItemInfoById(k)
        local skillInfo = PokemonInfo.getPetSkillInfoById(itemInfo.paramA)
        if skillInfo.skillAtt == elementAtt1 or skillInfo.skillAtt == elementAtt2 or skillInfo.skillAtt == 1 then
            if equipedSkillID and equipedSkillID ~= 0 then
                if equipedSkillInfo.skill_A_Type == skillInfo.skill_A_Type then--类型匹配(主动、被动)
                    if equipedSkillInfo.airpower == skillInfo.airpower then
                        local canExchange = true
                        for k1,v1 in pairs(groundpowerList) do
                            if skillInfo.groundpower == v1 then
                                canExchange = false
                                break
                            end
                        end
                        if canExchange == true then
                            table.insert(skillItems, itemInfo)
                        end
                    end
                end
            else
                if skillInfo.skill_A_Type == 6 then
                    if equipedSkillType == skillInfo.airpower then--稀有度
                        local canExchange = true
                        for k1,v1 in pairs(groundpowerList) do
                            if skillInfo.groundpower == v1 then
                                canExchange = false
                                break
                            end
                        end
                        if canExchange == true then
                            table.insert(skillItems, itemInfo)
                        end
                    end
                end
            end
        end
    end
    return skillItems
end
]]

function EduSkillPageMgr.showSkillExchangeUIAfterEvolution(petInfo, addSkills, idx, closeCallback)--宠物进化后技能替换
    local res_1 = "Pet/Education/SkillExchange2.csb"
    local res_2 = "Pet/Education/SkillExchange3.csb"

    local function getSimilarSkillBySkillID()
        local similarSkillTable = {}        
        local skillType = addSkills[idx].skillType
        local skillID = addSkills[idx].skillArrID

        table.insert(similarSkillTable, skillID)

        if skillType == 0 or skillType == 1 or skillType == 8 then--主动、奥义、天赋
            for k,v in pairs(petInfo.skills) do
                if v ~= 0 then
                    local sInfo = PokemonInfo.getPetSkillInfoById(v)
                    if sInfo.skill_A_Type == skillType then
                        table.insert(similarSkillTable, v)
                    end
                end
            end
        else
            --如果有槽位没有的技能，策划是傻子
            local paSkillPosType = addSkills[idx].skillPosType
            for k,v in pairs(petInfo.paSkills) do
                if v["paSkillType"] == paSkillPosType then
                    table.insert(similarSkillTable, v["paSkillID"])
                end
            end
        end
        return similarSkillTable
    end

    local canExchangeSkillCnt = #getSimilarSkillBySkillID()
    local res = canExchangeSkillCnt <= 2 and res_1 or res_2
    local power = {}
    local nowSkillID = 0

    local function hideSkillExchangeUIAfterEvolution()
        UnblockLoader.cancel("SkillExchangeUIAfterEvolution")
        CSResourceMgr.removeCSObjectByTag(res)
    end
    local function GetSkillIndexBySkillID(skillID)
        local index = 0
        for k,v in pairs(petInfo.skills) do
            if v == skillID then
                return index
            end
            index = index + 1
        end
        for k,v in pairs(petInfo.paSkills) do
            if v["paSkillID"] and v["paSkillID"] == skillID then
                return index
            end
            index = index + 1
        end
        return index
    end
    local function loadCSB()
        local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, res)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(res)
        CSResourceMgr.setRelativePosition(res, 320, 480)
        local btnClose = CSResourceMgr.getNodeByName(res, {"panel","btn_close"})
        CSResourceMgr.clickEventBindingByNode(btnClose, function()
            hideSkillExchangeUIAfterEvolution()
            if closeCallback then closeCallback() end
        end)
        local title    = CSResourceMgr.getNodeByName(res, {"panel","name"})
        local attTitle = CSResourceMgr.getNodeByName(res, {"panel2","background3","skill_att_title"})
        local attDesc  = CSResourceMgr.getNodeByName(res, {"panel2","background4","desc"})
        title:enableOutline(outlineColor[3], LABLE_OUTLINE_THICK)

        CSResourceMgr.setLabelStringByNode(title, "train46")
        CSResourceMgr.setLabelStringByNode(attTitle, "train77", nil, 1, 108)
        CSResourceMgr.setLabelStringByNode(attDesc, "train101", nil, 1, 436)

        CSResourceMgr.setLabelColorByNode(title, labelColor[3])
        CSResourceMgr.setLabelColorByNode(attTitle, labelColor[3])
        CSResourceMgr.setLabelColorByNode(attDesc, labelColor[3])
    end
    local function setSkillInfoByID(node, skillID, pos)--pos:从上到下，第几个位置
        local skillInfo = PokemonInfo.getPetSkillInfoById(skillID)
        local skillNode = CSResourceMgr.seekNodeByName(node, "skill_node")
        local skillName = CSResourceMgr.seekNodeByName(node, "skill_name_s")
        local skillDesc = CSResourceMgr.seekNodeByName(node, "skill_info")
        local skillNew  = CSResourceMgr.seekNodeByName(node, "new")
        power[pos]      = skillInfo.power

        PetSkillIconMgr.createPetSkillIcon(skillNode, skillInfo)
        if pos == 1 then
            CSResourceMgr.setSpriteTextureByNode(skillNew, CocosModuleMgr.getWordImage("label_new.png"))
        end

        skillName:enableOutline(outlineColor[1], LABLE_OUTLINE_THICK)
        CSResourceMgr.setLabelStringByNode(skillName, skillInfo.name)
        CSResourceMgr.setLabelStringByNode(skillDesc, skillInfo.desc)
        CSResourceMgr.setLabelColorByNode(skillName, labelColor[5])

        local attrText = {"skillType"..skillInfo.skill_A_Type, "skillType"..skillInfo.skill_B_Type, 
                        (skillInfo.hitRate or 0), skillInfo.power}
        for i = 1, #attrTitle do
            local labelTitle = CSResourceMgr.seekNodeByName(node, "label"..i)
            local text = CSResourceMgr.seekNodeByName(labelTitle, "text")
            text:enableOutline(outlineColor[1], LABLE_OUTLINE_THICK)
            CSResourceMgr.setLabelStringByNode(labelTitle, attrTitle[i], nil, 1, 54)
            CSResourceMgr.setLabelStringByNode(text, attrText[i], nil, 1, 54)
            CSResourceMgr.setLabelColorByNode(labelTitle, labelColor[3])
            CSResourceMgr.setLabelColorByNode(text, labelColor[5])
        end
        if pos > 1 then
            local buff = CSResourceMgr.seekNodeByName(node, "buff")
            if power[pos] == power[1] then
                buff:setVisible(false)
            else
                local isUp = power[pos] > power[1]
                CSResourceMgr.setSpriteTextureByNode(buff, isUp and 
                    "Pet/Education/homepage/buff1.png" or "Pet/Education/homepage/buff2.png")
                local label4 = CSResourceMgr.seekNodeByName(node, "label4")
                local text4 = CSResourceMgr.seekNodeByName(label4, "text")
                CSResourceMgr.setLabelColorByNode(text4, isUp and labelColor[9] or labelColor[8])
            end
            local btnExchange = CSResourceMgr.seekNodeByName(node, "btn_exchange")
            local strExchange = CSResourceMgr.seekNodeByName(node, "str_exchange")
            strExchange:enableOutline(outlineColor[1], LABLE_OUTLINE_THICK)
            CSResourceMgr.setLabelStringByNode(strExchange, "train81")
            CSResourceMgr.setLabelColorByNode(strExchange, labelColor[6])
            CSResourceMgr.clickEventBindingByNode(btnExchange, function ()
                local sIndex = GetSkillIndexBySkillID(skillID)
                NetInterface.sendWithBlock("GC_CHANGEPETEVOSKILL_ACK", function()
                    local PetEducationSend = require("src.Net.Send.PetEducationSend")
                    PetEducationSend.sendCG_ChangePetEvoSkill_Req({
                        petObjID = petInfo.objID,
                        skillIndex = sIndex,
                        skillID = addSkills[idx].skillArrID
                        })
                    end,
                    function ()
                        hideSkillExchangeUIAfterEvolution()
                        if closeCallback then
                            closeCallback()
                        end
                    end,
                    function ()
                        DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 1, "train100")
                    end)
            end)
        end
    end
    local function showUI()
        local canExchangeSkillIDs = getSimilarSkillBySkillID()
        for i=1,#canExchangeSkillIDs do
            local node = CSResourceMgr.getNodeByName(res, "panel"..(i * 2 - 1))
            setSkillInfoByID(node, canExchangeSkillIDs[i], i)
        end
    end
    local function playAction()
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(res, "panel"), "down")
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(res, "panel1"), "down")
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(res, "panel2"), "down")
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(res, "panel3"), "down")
        if canExchangeSkillCnt > 2 then
            CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(res, "panel5"), "down")
        end
    end
    local funcTable = {loadCSB, showUI, playAction}
    UnblockLoader.load(funcTable, "SkillExchangeUIAfterEvolution")
end

--宠物图鉴
function EduSkillPageMgr.showAtlasSkillPage(scene, skillInfo)
    skillInfo = skillInfo or {}
    curSkillInfo = skillInfo

    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, resName_main)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName_main, 320, 480)
        CSResourceMgr.clickEventBinding(resName_main,"btn_close",function()
            EduSkillPageMgr.hideAtlasSkillPage()
        end)
    end

    local function loadUI()
        local skillIcon1    = skillInfo.icon and "Battle/skillIcon/"..skillInfo.icon..".png" or "empty.png"
        local skillName1    = skillInfo.name
        local skillAttr1    = skillInfo.skillAtt
        local skillDesc1    = skillInfo.desc
        local skillType1    = skillInfo.skill_A_Type
        local skillLv1      = (skillInfo.id % 5 == 0) and 5 or (skillInfo.id % 5)
        local skillPower    = skillInfo.power
        local skillHitR     = skillInfo.hitRate or 0 --命中

        local panel         = CSResourceMgr.getNodeByName(resName_main, "btn")
        local panel1        = CSResourceMgr.getNodeByName(resName_main, "panel1")
        local title         = CSResourceMgr.seekNodeByName(panel1, "name")
        local skillName     = CSResourceMgr.seekNodeByName(panel1, "skill_name")
        local skillRareTitle= CSResourceMgr.seekNodeByName(panel1, "skill_rare_title")
        local skillRare     = CSResourceMgr.seekNodeByName(panel1, "skill_rare")
        local skillAttTitle = CSResourceMgr.seekNodeByName(panel1, "skill_att_title")
        local skillInfoTitle= CSResourceMgr.seekNodeByName(panel1, "skill_info_title")
        local skillDesc     = CSResourceMgr.seekNodeByName(panel1, "skill_info")
        local btnExchange   = CSResourceMgr.seekNodeByName(panel1, "btn_strength")
        local btnLvUp       = CSResourceMgr.seekNodeByName(panel1, "btn_lvup")
        local skillNode     = CSResourceMgr.seekNodeByName(panel1, "skill_node")

        local PetSkillIconMgr = require("src.GameMgr.Pet.PetSkillIconMgr")
        PetSkillIconMgr.createPetSkillIcon(skillNode, skillInfo)

        CSResourceMgr.setSpriteTextureByNode(skillRare, irareString[skillInfo.airpower-1])

        CSResourceMgr.setLabelStringByNode(title, "train45", nil, 1, 264)
        CSResourceMgr.setLabelStringByNode(skillName, skillName1)
        CSResourceMgr.setLabelStringByNode(skillRareTitle, LuaSqlite.getLanguageByKey("train76")..":", nil, 1, 72)
        CSResourceMgr.setLabelStringByNode(skillAttTitle, "train77", nil, 1, 110)
        CSResourceMgr.setLabelStringByNode(skillInfoTitle, "train78", nil, 1, 110)
        CSResourceMgr.setLabelStringByNode(skillDesc, skillDesc1)

        skillName:enableOutline(outlineColor[1], LABLE_OUTLINE_THICK)

        local sameColorStr1 = {title,skillRareTitle,skillAttTitle,skillInfoTitle}
        for k,v in pairs(sameColorStr1) do
            CSResourceMgr.setLabelColorByNode(v, labelColor[3])
            v:enableOutline(outlineColor[3], LABLE_OUTLINE_THICK)
        end
        local attrText = {"skillType"..skillInfo.skill_A_Type, "skillType"..skillInfo.skill_B_Type, skillHitR, skillPower}
        for i = 1, #attrTitle do
            local labelTitle = CSResourceMgr.seekNodeByName(panel1, "label"..i)
            local text = CSResourceMgr.seekNodeByName(labelTitle, "text")
            CSResourceMgr.setLabelStringByNode(labelTitle, attrTitle[i], nil, 1, 72)
            CSResourceMgr.setLabelStringByNode(text, attrText[i], nil, 1, 86)
            CSResourceMgr.setLabelColorByNode(labelTitle, labelColor[3])
            CSResourceMgr.setLabelColorByNode(text, labelColor[5])
            labelTitle:enableOutline(outlineColor[3], LABLE_OUTLINE_THICK)
            text:enableOutline(outlineColor[1], LABLE_OUTLINE_THICK)
        end
        btnExchange:setVisible(false)
        btnLvUp:setVisible(false)
    end

    local function playAction()
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName_main, "panel1"), "down")
    end

    local funcTable = {loadCSB, loadUI, playAction}
    UnblockLoader.load(funcTable)
    -- for i=1,#funcTable do
    --     funcTable[i]()
    -- end
end

function EduSkillPageMgr.hideAtlasSkillPage()
    CSResourceMgr.removeCSObjectByTag(resName_main)
end

return EduSkillPageMgr