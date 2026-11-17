local PetInfoViewMgr = {}

local resName = ""
local resNameDownBar = ""
local cur_polygon_node = nil
local orderString = {}
local skillRareBGPath = {}
local skillHelperPath = {}
local skillPassivePath = {}
local levelString = {}
local petEvoInfo = nil
local aniPetRes = nil
local aniPetTag = nil

function PetInfoViewMgr.Init()
    print("PetInfoViewMgr初始化")
    
    resName = "Pet/PetInfoView.csb"
    resNameDownBar = "Pet/PetInfoDownBar.csb"
    cur_polygon_node = nil
    orderString = {
        [1] = "Pet/Education/c.png",
        [2] = "Pet/Education/b.png",
        [3] = "Pet/Education/a.png",
        [4] = "Pet/Education/s.png",
        [5] = "Pet/Education/2s.png",
        [6] = "Pet/Education/3s.png",
    }
    skillRareBGPath = {
        "UI/CommonFiles/fight_skill_green.png",
        "UI/CommonFiles/fight_skill_blue.png",
        "UI/CommonFiles/fight_skill_purple.png",
        "UI/CommonFiles/fight_skill_yellow.png",
    }
    skillHelperPath = {
        "UI/CommonFiles/skill_aid_base_nomal_01.png",
        "UI/CommonFiles/skill_aid_base_blue_01.png",
        "UI/CommonFiles/skill_aid_base_violet_01.png",
        "UI/CommonFiles/skill_aid_base_yellow_01.png",
        "UI/CommonFiles/skill_aid_base_orange_01.png",
    }
    skillPassivePath = {
        "UI/CommonFiles/skill_passive_base_nomal_01.png",
        "UI/CommonFiles/skill_passive_base_blue_01.png",
        "UI/CommonFiles/skill_passive_base_violet_01.png",
        "UI/CommonFiles/skill_passive_base_yellow_01.png",
    }
    
    levelString = {
        [1] = "train108",
        [2] = "petBook112",
        [3] = "petBook113",
        [4] = "petBook114",
    }
    
    if petEvoInfo==nil then
        petEvoInfo = {}
        local petEvoInfoReader = TxtReader.new("Config/PetEvo.txt")
        local petEvoInfoData = petEvoInfoReader.init({"id", "evo_before", "evo_after"}, 1)
        for key, var in pairs(petEvoInfoData) do
            local id = tonumber(var.id)
            petEvoInfo[id] = {evo_before=(var["evo_before"]), evo_after=(var["evo_after"])}
        end
        --print("@@@@@@@@@@@@@@@@@petEvoInfo="..sz_T2S(petEvoInfo))
    end
    
    aniPetRes = nil
    aniPetTag = nil
end

local function initStaticData()
    CSResourceMgr.setLabelString(resName, {"bg","960","title"}, "petBook101", nil, {r=0,g=0,b=0,a=255,w=1})
    
    CSResourceMgr.setButtonString(resName, {"bg","960","tab1"}, "petBook115", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setButtonString(resName, {"bg","960","tab2"}, "petBook116", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setButtonString(resName, {"bg","960","tab3"}, "petBook117", nil, {r=0,g=0,b=0,a=255,w=1})
    
    CSResourceMgr.setLabelString(resName, {"bg","960","diban_skill1","txt1"}, "skillBook1", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"bg","960","diban_skill1","txt2"}, LuaSqlite.getLanguageByKey("skillBook2")..1, nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"bg","960","diban_skill1","txt3"}, LuaSqlite.getLanguageByKey("skillBook2")..2, nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"bg","960","diban_skill1","txt4"}, "skillBook3", nil, {r=0,g=0,b=0,a=255,w=1})
    
    --CSResourceMgr.setLabelString(resName, {"bg","960","diban2","skill2","skill2Title"}, "petBook103", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"bg","960","diban_evo","chart","prelabel"}, "petBook104", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"bg","960","diban_evo","chart","nextlabel"}, "petBook105", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setButtonString(resNameDownBar, "get", "petBook106", nil, {r=0,g=0,b=0,a=255,w=1})
    
    local diff = CocosModuleMgr.getScreenSizeDiff()
    if diff < 0 then
        local diban_skill = CSResourceMgr.getNodeByName(resName, {"bg","960","diban_skill1"})
        local list = CSResourceMgr.seekNodeByName(diban_skill,"list")
        local lsize = list:getContentSize()
        list:setContentSize(lsize.width, lsize.height+diff*2.66)
        
        local diban_skill = CSResourceMgr.getNodeByName(resName, {"bg","960","diban_skill2"})
        local list = CSResourceMgr.seekNodeByName(diban_skill,"list")
        local lsize = list:getContentSize()
        list:setContentSize(lsize.width, lsize.height+diff*2.66)
    end
end

function PetInfoViewMgr.hideUI()
    GameAudio.playUISound("back")
    UnblockLoader.cancel("PetInfoViewMgr.show")
    CSResourceMgr.removeCSObjectByTag(resName)
    CSResourceMgr.removeCSObjectByTag(resNameDownBar)
    AchievementListMgr.setVisible(true)
    PetHandBook.setVisible(true)
    GachaViewMgr.setVisible(true)
    UIStack.pop("PetInfoViewMgr")
end

local function commentMessage(petID)
    MsgBoardView.show(SceneMgr.getRunningScene,1,nil,{pokeID = petID})
end

local function showGetUI(petID)
    PetGetViewMgr.show(SceneMgr.getRunningScene, petID)
end

local function updatePetAni(petID)
    --宠物动画
    if aniPetRes ~= nil then
        AnimationMgr.removeGafObjectByTag(aniPetRes, aniPetTag)
    end
    aniPetRes = PokemonInfo.getPokemonResByID(petID)
    aniPetTag = "Pet_Evolution_"..petID
    local petAniNode = CSResourceMgr.getNodeByName(resName, "petAni")
    local aniRes = AnimationMgr.createAni(petAniNode, aniPetRes, 0, 0, aniPetTag)
    aniRes:setScale(0.65)
    AnimationMgr.playAni(aniPetRes, "idle", true, aniPetTag)
    AnimationMgr.setSkin(aniPetRes, 0, aniPetTag)
end

local function updatePetInfo(petID)
    --宠物名字
    local petInfo = PokemonInfo.getPokemonInfoByID(petID)
    CSResourceMgr.setLabelString(resName,"p_attack",BattleBasicValueCalc.calcFC(1, petInfo.lifeRateValue, petInfo.atkRateValue, petInfo.defRateValue, petInfo.satkRateValue, petInfo.sdefRateValue, petInfo.speedRateValue),nil,{r=0,g=0,b=0,a=255})
    local textColor = PokemonInfo.COLOR[petInfo.rarePoint]
    CSResourceMgr.getNodeByName(resName,"p_name_text"):setTextColor(textColor)
    local name_text = LuaSqlite.getLanguageByKey(petInfo.name)
    CSResourceMgr.setLabelString(resName,"p_name_text",name_text,nil,{r=0,g=0,b=0,a=255})
    --s_types
    local s_type = CSResourceMgr.getNodeByName(resName,{"bg","960","diban1","petStage","s_type"})
    s_type:setVisible(petInfo.elementAtt2 ~= 0)
    if petInfo.elementAtt2 ~= 0 then
        --CSResourceMgr.seekNodeByName(s_type,"att_background"):loadTexture("Pet/AttriIcon/small_"..petInfo.elementAtt2..".png")
        local ic = CSResourceMgr.seekNodeByName(s_type,"att_icon")
        ic:loadTexture("UI/CommonFiles/"..petInfo.elementAtt2..".png")
        ic:setScale(0.48)
    end
    --types
    local icon1 = "UI/CommonFiles/"..petInfo.elementAtt1..".png"
    --local icon2 = "Pet/AttriIcon/small_"..petInfo.elementAtt1..".png"
    CSResourceMgr.getNodeByName(resName,{"bg","960","diban1","petStage","type","att_icon"}):loadTexture(icon1)
    --CSResourceMgr.getNodeByName(resName,{"bg","960","diban1","petStage","type","att_background"}):loadTexture(icon2)
    
    CSResourceMgr.getNodeByName(resName,"orderString"):loadTexture(orderString[petInfo.rarePoint])
end

local function UpdateRadar(petID, attribType, attribValue)
    --六星图设置
    local function radarSetting(petInfo, attribType, attribValue)
        local text = {"train11","train12","train14","train16","train15","train13",}
        local num  = {
            petInfo.lifeRateValue,
            petInfo.atkRateValue,
            petInfo.satkRateValue,
            petInfo.speedRateValue,
            petInfo.sdefRateValue,
            petInfo.defRateValue,
        }
        
        if attribType > 0 then
            if attribType == 1 then
                num[1] = num[1] + math.ceil(num[1] * (attribValue/100.0))
            elseif attribType == 2 then
                num[2] = num[2] + math.ceil(num[2] * (attribValue/100.0))
            elseif attribType == 3 then
                num[6] = num[6] + math.ceil(num[6] * (attribValue/100.0))
            elseif attribType == 4 then
                num[3] = num[3] + math.ceil(num[3] * (attribValue/100.0))
            elseif attribType == 5 then
                num[5] = num[5] + math.ceil(num[5] * (attribValue/100.0))
            elseif attribType == 6 then
                num[4] = num[4] + math.ceil(num[4] * (attribValue/100.0))
            end
        end
        
        for i=1,6 do
            local a_node = CSResourceMgr.getNodeByName(resName,"attr"..i)
            local a_num_node = CSResourceMgr.getNodeByName(resName,"num"..i)
            CSResourceMgr.setLabelStringByNode(a_node,text[i],CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            CSResourceMgr.setLabelStringByNode(a_num_node,num[i],CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            if (i == 1 and attribType == 1) or (i == 2 and attribType == 2) or 
               (i == 3 and attribType == 4) or (i == 4 and attribType == 6) or 
               (i == 5 and attribType == 5) or (i == 6 and attribType == 3) then
                CSResourceMgr.setLabelColorByNode(a_num_node, {r=60,g=220,b=109,a=255})
            else
                CSResourceMgr.setLabelColorByNode(a_num_node, {r=255,g=255,b=255,a=255})
            end
            a_node:enableOutline({r=0,g=0,b=0,a=255}, 1)
            a_num_node:enableOutline({r=0,g=0,b=0,a=255}, 1)
        end
    end
    --六星图
    local function drawAttrPolygon(drawNode, petInfo, color, attribType, attribValue)
        local center = cc.p(91,102)
        local xfix = 8  -- 20
        local yfix = 9  -- 23

        -- 六边形逆时针方向
        local values = {
            petInfo.lifeRateValue,
            petInfo.atkRateValue,
            petInfo.satkRateValue,
            petInfo.speedRateValue,
            petInfo.sdefRateValue,
            petInfo.defRateValue,
        }
        
        if attribType > 0 then
            if attribType == 1 then
                values[1] = values[1] + math.ceil(values[1] * (attribValue/100.0))
            elseif attribType == 2 then
                values[2] = values[2] + math.ceil(values[2] * (attribValue/100.0))
            elseif attribType == 3 then
                values[6] = values[6] + math.ceil(values[6] * (attribValue/100.0))
            elseif attribType == 4 then
                values[3] = values[3] + math.ceil(values[3] * (attribValue/100.0))
            elseif attribType == 5 then
                values[5] = values[5] + math.ceil(values[5] * (attribValue/100.0))
            elseif attribType == 6 then
                values[4] = values[4] + math.ceil(values[4] * (attribValue/100.0))
            end
        end

        local cond = petInfo.rarePoint > 3
        local max = cond and 272 or 115

        local rate = {
            values[1] < max and values[1] / max or 1.0, --hp
            values[2] < max and values[2] / max or 1.0,  --
            values[3] < max and values[3] / max or 1.0,
            values[4] < max and values[4] / max or 1.0,
            values[5] < max and values[5] / max or 1.0,
            values[6] < max and values[6] / max or 1.0,
        }
        --print("==========radar rate=",sz_T2S(rate))

        local points = {}
        points[1] = cc.p(center.x, center.y+(yfix+(88-yfix)*rate[1]))
        points[2] = cc.p(center.x-(xfix+(76-xfix)*rate[2]), center.y+(yfix/2+(44-yfix/2)*rate[2]))
        points[3] = cc.p(center.x-(xfix+(76-xfix)*rate[3]), center.y-(yfix/2+(44-yfix/2)*rate[3]))
        points[4] = cc.p(center.x, center.y-(yfix+(88-yfix)*rate[4]))
        points[5] = cc.p(center.x+(xfix+(76-xfix)*rate[5]), center.y-(yfix/2+(44-yfix/2)*rate[5]))
        points[6] = cc.p(center.x+(xfix+(76-xfix)*rate[6]), center.y+(yfix/2+(44-yfix/2)*rate[6]))
        drawNode:clear()
        drawNode:setColor( color )  --outline
        drawNode:drawSolidPolygon(points, 6, color)
        --print("==========radar points=",sz_T2S(points))
    end

    local petInfo = PokemonInfo.getPokemonInfoByID(petID)
    local stage = CSResourceMgr.getNodeByName(resName,"attrStage")
    local backIcon = (petInfo.rarePoint >= 4) and "Pet/Education/cwxx_liuwei_s.png" or "Pet/Education/cwxx_liuwei.png"
    CSResourceMgr.setSpriteTextureByNode(stage, backIcon)
    if cur_polygon_node ~= nil then
        stage:removeChild(cur_polygon_node)
    end
    cur_polygon_node = cc.NVGDrawNode:create()
    stage:addChild(cur_polygon_node)
    drawAttrPolygon(cur_polygon_node, petInfo, cc.c4f(1.0, 1.0, 0, 0.8), attribType, attribValue)
    radarSetting(petInfo, attribType, attribValue)
end

local function showBookPanel(bookPanel, visible)
    if bookPanel then
        bookPanel:setVisible(visible)
    end
end

local function toggleBookPanel(bookPanel)
    if bookPanel then
        local isVisible = bookPanel:isVisible()
        showBookPanel(bookPanel, not isVisible)
    end 
end

local function getStateUnit(petID, attribType, attribValue, stateIndex)
    local state = CSResourceMgr.getNodeByName(resName,"stateComponent"):clone()
    CSResourceMgr.setButtonStringByNode(state, "petBook"..attribType, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.clickEventBindingByNode(state,function()
        local bookPanel = CSResourceMgr.getNodeByName(resName, {"bg","960","diban1","handbook","panel"})
        --transition.scaleTo(bookPanel, {scale = 0, time = 0.1})
        showBookPanel(bookPanel, false)
        if aniPetRes and aniPetTag then
            AnimationMgr.setSkin(aniPetRes, stateIndex, aniPetTag)
            UpdateRadar(petID, attribType, attribValue)
        end
    end)
    state:setVisible(true)
    return state
end

local function updatePetBook(petID)
    local list = CSResourceMgr.getNodeByName(resName, {"bg","960","diban1","handbook","panel","list"})
    if list then
        list:removeAllItems()
        local state = getStateUnit(petID, 0, 0, 0)
        list:pushBackCustomItem(state)
        local petInfo = PokemonInfo.getPokemonInfoByID(petID)
        for i=1, #petInfo.skins do
            state = getStateUnit(petID, petInfo.skins[i].attribType, petInfo.skins[i].attribValue, i)
            list:pushBackCustomItem(state)
        end
    end
end

local function updateGiftAndHelperSkills(petID)
    local count = PokemonInfo.getGeneInfoCount()
    --print("------------updateGiftSkills count=",count)
    --[[
    for i=1, 4 do
        local giftSkill = CSResourceMgr.getNodeByName(resName,"tianfujineng"..i)
        giftSkill:setVisible(false)
        --local icon = CSResourceMgr.seekNodeByName(giftSkill,"icon")
        --CSResourceMgr.setSpriteTextureByNode(icon, "empty.png")
        --local name = CSResourceMgr.seekNodeByName(giftSkill,"name")
        --CSResourceMgr.setLabelStringByNode(name, " ")
        --local attr_bg = CSResourceMgr.seekNodeByName(giftSkill,"attr_bg")
        --CSResourceMgr.setSpriteTextureByNode(attr_bg, "Pet/BasicPetList_2/dengjiquan.png")
        --local att_icon = CSResourceMgr.seekNodeByName(giftSkill,"att_icon")
        --CSResourceMgr.setSpriteTextureByNode(att_icon, "empty.png")
        --CSResourceMgr.setButtonEnabledByNode(giftSkill, false)
        
        local helperSkill = CSResourceMgr.getNodeByName(resName,"yuanzhujineng"..i)
        helperSkill:setVisible(false)
        --icon = CSResourceMgr.seekNodeByName(helperSkill,"icon")
        --CSResourceMgr.setSpriteTextureByNode(icon, "empty.png")
        --name = CSResourceMgr.seekNodeByName(helperSkill,"name")
        --CSResourceMgr.setLabelStringByNode(name, " ")
        --attr_bg = CSResourceMgr.seekNodeByName(helperSkill,"attr_bg")
        --CSResourceMgr.setSpriteTextureByNode(attr_bg, "Pet/BasicPetList_2/dengjiquan.png")
        --att_icon = CSResourceMgr.seekNodeByName(helperSkill,"att_icon")
        --CSResourceMgr.setSpriteTextureByNode(att_icon, "empty.png")
        --CSResourceMgr.setButtonEnabledByNode(helperSkill, false)
    end
    ]]
    
    for idx=1, count do
        local geneInfo = PokemonInfo.getGeneInfoByIndex(idx)
        if geneInfo ~= nil and geneInfo.petID == petID and geneInfo.petID == geneInfo.id then
            --initiative skills
            local initiativeSkillTbl = {}
            local maxSkillNum = 0
            local diban_skill1 = CSResourceMgr.getNodeByName(resName, {"bg","960","diban_skill1"})
            local skill_1 = {}
            local geneProbabilityInfo = PokemonInfo.getGeneProbabilityInfoByID(geneInfo.skill_1)
            if #geneProbabilityInfo.geneGroup > maxSkillNum then
                maxSkillNum = #geneProbabilityInfo.geneGroup
            end
            for i=1, #geneProbabilityInfo.geneGroup do
                local skillInfo = PokemonInfo.getPetSkillInfoById(geneProbabilityInfo.geneGroup[i].prob_skillID)
                if not skillInfo then
                    skillInfo = 0
                end
                table.insert(skill_1, skillInfo)
            end
            table.insert(initiativeSkillTbl, skill_1)
            
            local skill_2 = {}
            local geneProbabilityInfo = PokemonInfo.getGeneProbabilityInfoByID(geneInfo.skill_2)
            if #geneProbabilityInfo.geneGroup > maxSkillNum then
                maxSkillNum = #geneProbabilityInfo.geneGroup
            end
            for i=1, #geneProbabilityInfo.geneGroup do
                local skillInfo = PokemonInfo.getPetSkillInfoById(geneProbabilityInfo.geneGroup[i].prob_skillID)
                if not skillInfo then
                    skillInfo = 0
                end
                table.insert(skill_2, skillInfo)
            end
            table.insert(initiativeSkillTbl, skill_2)
            
            local skill_3 = {}
            local geneProbabilityInfo = PokemonInfo.getGeneProbabilityInfoByID(geneInfo.skill_3)
            if #geneProbabilityInfo.geneGroup > maxSkillNum then
                maxSkillNum = #geneProbabilityInfo.geneGroup
            end
            for i=1, #geneProbabilityInfo.geneGroup do
                local skillInfo = PokemonInfo.getPetSkillInfoById(geneProbabilityInfo.geneGroup[i].prob_skillID)
                if not skillInfo then
                    skillInfo = 0
                end
                table.insert(skill_3, skillInfo)
            end
            table.insert(initiativeSkillTbl, skill_3)
            
            local profound = {}
            local geneProbabilityInfo = PokemonInfo.getGeneProbabilityInfoByID(geneInfo.profound)
            if #geneProbabilityInfo.geneGroup > maxSkillNum then
                maxSkillNum = #geneProbabilityInfo.geneGroup
            end
            for i=1, #geneProbabilityInfo.geneGroup do
                local skillInfo = PokemonInfo.getPetSkillInfoById(geneProbabilityInfo.geneGroup[i].prob_skillID)
                if not skillInfo then
                    skillInfo = 0
                end
                table.insert(profound, skillInfo)
            end
            table.insert(initiativeSkillTbl, profound)
            
            local list = CSResourceMgr.seekNodeByName(diban_skill1,"list")
            list:removeAllItems()
            for i=1, maxSkillNum do
                local skillComponent = CSResourceMgr.getNodeByName(resName,"skill1"):clone()
                for j=1, 4 do
                    --for k=1, maxSkillNum do
                        local empty = CSResourceMgr.seekNodeByName(skillComponent, "empty"..j)
                        local skill = CSResourceMgr.seekNodeByName(skillComponent, "tianfujineng"..j)
                        local skillInfo = initiativeSkillTbl[j][i]
                        if skillInfo ~= nil then
                            if type(skillInfo) == "table" then
                                local icon = CSResourceMgr.seekNodeByName(skill,"icon")
                                local name = CSResourceMgr.seekNodeByName(skill,"name")
                                local name_bg = CSResourceMgr.seekNodeByName(skill, "name_bg")
                                local type_icon = CSResourceMgr.seekNodeByName(skill,"type_icon")
                                local level_icon = CSResourceMgr.seekNodeByName(skill,"level_icon")
                                local attr_icon = CSResourceMgr.seekNodeByName(skill,"attr_icon")
                                local cost_bg, cost_txt
                                if j<=3 then
                                    cost_bg = CSResourceMgr.seekNodeByName(skill,"cost_bg")
                                    cost_txt = CSResourceMgr.seekNodeByName(skill,"cost_txt")
                                else
                                    cost_bg = CSResourceMgr.seekNodeByName(skill,"bar")
                                end
                                if j<=3 then
                                    CSResourceMgr.setButtonTextureByNode(skill, PetSkillIconMgr.skillRareBGPath[skillInfo.airpower], PetSkillIconMgr.skillRareBGPath[skillInfo.airpower], PetSkillIconMgr.skillRareBGPath[skillInfo.airpower])
                                end
                                CSResourceMgr.setSpriteTextureByNode(icon, "Battle/skillIcon/"..skillInfo.icon..".png")
                                icon:setScale(1.1, 1.1)
                                CSResourceMgr.setLabelStringByNode(name, skillInfo.name, {r=0,g=0,b=0,a=255,w=1}, nil, 130)
                                CSResourceMgr.setLabelColorByNode(name, PokemonInfo.COLOR[skillInfo.airpower])
                                name_bg:setColor({r=27,g=43,b=65})
                                CSResourceMgr.setSpriteTextureByNode(type_icon, PokemonInfo.getSkillPlayById(skillInfo.id).typeIcon)
                                CSResourceMgr.setSpriteTextureByNode(level_icon, orderString[skillInfo.airpower])
                                level_icon:setScale(0.48)
                                CSResourceMgr.setSpriteTextureByNode(attr_icon, "UI/CommonFiles/"..skillInfo.skillAtt..".png")
                                if skillInfo.energy > 0 then
                                    if j<=3 then
                                        cost_bg:setVisible(true)
                                        CSResourceMgr.setLabelStringByNode(cost_txt, skillInfo.energy, {r=86,g=55,b=4,a=255,w=1})
                                        cost_txt:setVisible(true)
                                    else
                                        CSResourceMgr.setSpriteTextureByNode(cost_bg, "UI/CommonFiles/esoteric_skill_anger_0"..skillInfo.energy..".png")
                                    end
                                else
                                    if j<=3 then
                                        cost_bg:setVisible(false)
                                        cost_txt:setVisible(false)
                                    else
                                        cost_bg:setVisible(false)
                                    end
                                end
                                empty:setVisible(false)
                                skill:setVisible(true)
                                CSResourceMgr.clickEventBindingByNode(skill, function()
                                    PetSkillViewMgr.showConciseSkillInfo(skillInfo, 1)
                                end)
                            else
                                empty:setVisible(true)
                                skill:setVisible(false)
                            end
                        else
                            empty:setVisible(false)
                            skill:setVisible(false)
                        end
                    --end
                end
                skillComponent:setVisible(true)
                list:pushBackCustomItem(skillComponent)
            end
            
            --passive skills
            local passiveSkillTbl = {}
            local maxSkillNum = 0
            local diban_skill2 = CSResourceMgr.getNodeByName(resName, {"bg","960","diban_skill2"})
            for passiveSkillIdx=1, #geneInfo.passiveSkills do
                local skill = {}
                local geneProbabilityInfo = PokemonInfo.getGeneProbabilityInfoByID(geneInfo.passiveSkills[passiveSkillIdx].passiveSkillID)
                local passiveSkillType = geneInfo.passiveSkills[passiveSkillIdx].passiveSkillType
                local txt_level = CSResourceMgr.seekNodeByName(diban_skill2, "txt"..passiveSkillIdx)
                CSResourceMgr.setLabelStringByNode(txt_level, levelString[passiveSkillType + 1], {r=0,g=0,b=0,a=255,w=1})
                if passiveSkillType == Proto.HELPER_PASSIVE_SKILL then
                    CSResourceMgr.setLabelColorByNode(txt_level, {r=60,g=220,b=109,a=255})
                else
                    CSResourceMgr.setLabelColorByNode(txt_level, {r=56,g=126,b=185,a=255})
                end
                --print("--passive skills",passiveSkillType)
                if #geneProbabilityInfo.geneGroup > maxSkillNum then
                    maxSkillNum = #geneProbabilityInfo.geneGroup
                end
                for i=1, #geneProbabilityInfo.geneGroup do
                    local skillInfo = PokemonInfo.getPetSkillInfoById(geneProbabilityInfo.geneGroup[i].prob_skillID)
                    if skillInfo then
                        skillInfo.type = passiveSkillType
                    else
                        skillInfo = 0
                    end
                    table.insert(skill, skillInfo)
                end
                table.insert(passiveSkillTbl, skill)
            end
            
            local list = CSResourceMgr.seekNodeByName(diban_skill2,"list")
            list:removeAllItems()
            for i=1, maxSkillNum do
                local skillComponent = CSResourceMgr.getNodeByName(resName,"skill2"):clone()
                for j=1, 5 do
                    --for k=1, maxSkillNum do
                        local empty = CSResourceMgr.seekNodeByName(skillComponent, "empty"..j)
                        local skill = CSResourceMgr.seekNodeByName(skillComponent, "yuanzhujineng"..j)
                        local skillInfo = passiveSkillTbl[j][i]
                        if skillInfo ~= nil then
                            if type(skillInfo) == "table" then
                                local icon = CSResourceMgr.seekNodeByName(skill,"icon")
                                local name = CSResourceMgr.seekNodeByName(skill,"name")
                                local name_bg = CSResourceMgr.seekNodeByName(skill, "name_bg")
                                local type_icon = CSResourceMgr.seekNodeByName(skill,"type_icon")
                                local level_icon = CSResourceMgr.seekNodeByName(skill,"level_icon")
                                local attr_icon = CSResourceMgr.seekNodeByName(skill,"attr_icon")
                                if skillInfo.type == Proto.HELPER_PASSIVE_SKILL then
                                    CSResourceMgr.setButtonTextureByNode(skill, skillHelperPath[skillInfo.airpower], skillHelperPath[skillInfo.airpower], skillHelperPath[skillInfo.airpower])
                                else
                                    CSResourceMgr.setButtonTextureByNode(skill, skillPassivePath[skillInfo.airpower], skillPassivePath[skillInfo.airpower], skillPassivePath[skillInfo.airpower])
                                end
                                CSResourceMgr.setSpriteTextureByNode(icon, "Battle/skillIcon/"..skillInfo.icon..".png")
                                icon:setScale(1.1, 1.1)
                                local x, y = icon:getPosition()
                                if skillInfo.skill_A_Type == Proto.eST_Assist then
                                    icon:setPosition(x+3, y+2)
                                else
                                    icon:setPosition(x-1, y+1)
                                end
                                CSResourceMgr.setLabelStringByNode(name, skillInfo.name, {r=0,g=0,b=0,a=255,w=1}, nil, 110)
                                CSResourceMgr.setLabelColorByNode(name, PokemonInfo.COLOR[skillInfo.airpower])
                                name_bg:setColor({r=27,g=43,b=65})
                                CSResourceMgr.setSpriteTextureByNode(type_icon, PokemonInfo.getSkillPlayById(skillInfo.id).typeIcon)
                                CSResourceMgr.setSpriteTextureByNode(level_icon, orderString[skillInfo.airpower])
                                level_icon:setScale(0.48)
                                CSResourceMgr.setSpriteTextureByNode(attr_icon, "UI/CommonFiles/"..skillInfo.skillAtt..".png")
                                empty:setVisible(false)
                                skill:setVisible(true)
                                CSResourceMgr.clickEventBindingByNode(skill, function()
                                    PetSkillViewMgr.showConciseSkillInfo(skillInfo, 2)
                                end)
                            else
                                empty:setVisible(true)
                                skill:setVisible(false)
                            end
                        else
                            empty:setVisible(false)
                            skill:setVisible(false)
                        end
                    --end
                end
                skillComponent:setVisible(true)
                list:pushBackCustomItem(skillComponent)
            end
            --print("------------updateGiftSkills geneProbabilityInfo.geneGroup=",sz_T2S(geneProbabilityInfo.geneGroup))
            --[[
            for i=1, #geneProbabilityInfo.geneGroup do
                local giftSkill = CSResourceMgr.getNodeByName(resName,"tianfujineng"..i)
                local icon = CSResourceMgr.seekNodeByName(giftSkill,"icon")
                local name = CSResourceMgr.seekNodeByName(giftSkill,"name")
                local type_icon = CSResourceMgr.seekNodeByName(giftSkill,"type_icon")
                local level_icon = CSResourceMgr.seekNodeByName(giftSkill,"level_icon")
                local attr_icon = CSResourceMgr.seekNodeByName(giftSkill,"attr_icon")
                local skillInfo = PokemonInfo.getPetSkillInfoById(geneProbabilityInfo.geneGroup[i].prob_skillID)
                if skillInfo ~= nil then
                    CSResourceMgr.setButtonTextureByNode(giftSkill, skillRareBGPath[skillInfo.airpower], skillRareBGPath[skillInfo.airpower], skillRareBGPath[skillInfo.airpower])
                    CSResourceMgr.setSpriteTextureByNode(icon, "Battle/skillIcon/"..skillInfo.icon..".png")
                    CSResourceMgr.setLabelStringByNode(name, skillInfo.name)
                    CSResourceMgr.setLabelColorByNode(name, PokemonInfo.COLOR[skillInfo.airpower])
                    --local attric, attricdb = PokemonInfo.getAttriPics(skillInfo.skillAtt)
                    --CSResourceMgr.setSpriteTextureByNode(att_icon, attric)
                    --CSResourceMgr.setSpriteTextureByNode(attr_bg, attricdb)
                    --print("==========skillInfo.id=",skillInfo.id)
                    CSResourceMgr.setSpriteTextureByNode(type_icon, PokemonInfo.getSkillPlayById(skillInfo.id).typeIcon)
                    CSResourceMgr.setSpriteTextureByNode(level_icon, orderString[skillInfo.airpower])
                    level_icon:setScale(0.48)
                    CSResourceMgr.setSpriteTextureByNode(attr_icon, "UI/CommonFiles/"..skillInfo.skillAtt..".png")
                    giftSkill.skillInfo = skillInfo
                    giftSkill.petID = petID
                    --CSResourceMgr.setButtonEnabledByNode(giftSkill, true)
                    giftSkill:setVisible(true)
                end
            end
            --helper skills
            for passiveSkillIdx=1, #geneInfo.passiveSkills do
                if geneInfo.passiveSkills[passiveSkillIdx].passiveSkillType  == Proto.HELPER_PASSIVE_SKILL then
                    geneProbabilityInfo = PokemonInfo.getGeneProbabilityInfoByID(geneInfo.passiveSkills[passiveSkillIdx].passiveSkillID)
                    for i=1, #geneProbabilityInfo.geneGroup do
                        local helperSkill = CSResourceMgr.getNodeByName(resName,"yuanzhujineng"..i)
                        local icon = CSResourceMgr.seekNodeByName(helperSkill,"icon")
                        local name = CSResourceMgr.seekNodeByName(helperSkill,"name")
                        local type_icon = CSResourceMgr.seekNodeByName(helperSkill,"type_icon")
                        local level_icon = CSResourceMgr.seekNodeByName(helperSkill,"level_icon")
                        local attr_icon = CSResourceMgr.seekNodeByName(helperSkill,"attr_icon")
                        local skillInfo = PokemonInfo.getPetSkillInfoById(geneProbabilityInfo.geneGroup[i].prob_skillID)
                        if skillInfo ~= nil then
                            CSResourceMgr.setButtonTextureByNode(helperSkill, skillHelperPath[skillInfo.airpower], skillHelperPath[skillInfo.airpower], skillHelperPath[skillInfo.airpower])
                            CSResourceMgr.setSpriteTextureByNode(icon, "Battle/skillIcon/"..skillInfo.icon..".png")
                            CSResourceMgr.setLabelStringByNode(name, skillInfo.name)
                            CSResourceMgr.setLabelColorByNode(name, PokemonInfo.COLOR[skillInfo.airpower])
                            --local attric, attricdb = PokemonInfo.getAttriPics(skillInfo.skillAtt)
                            --CSResourceMgr.setSpriteTextureByNode(att_icon, attric)
                            --CSResourceMgr.setSpriteTextureByNode(attr_bg, attricdb)
                            CSResourceMgr.setSpriteTextureByNode(type_icon, PokemonInfo.getSkillPlayById(skillInfo.id).typeIcon)
                            CSResourceMgr.setSpriteTextureByNode(level_icon, orderString[skillInfo.airpower])
                            level_icon:setScale(0.48)
                            CSResourceMgr.setSpriteTextureByNode(attr_icon, "UI/CommonFiles/"..skillInfo.skillAtt..".png")
                            helperSkill.skillInfo = skillInfo
                            helperSkill.petID = petID
                            --CSResourceMgr.setButtonEnabledByNode(helperSkill, true)
                            helperSkill:setVisible(true)
                        end
                    end
                    return
                end
            end
            ]]
            return
        end
    end
end

local function setPetEvo(btn, petID)
    local icon = CSResourceMgr.seekNodeByName(btn,"icon")
    local name = CSResourceMgr.seekNodeByName(btn,"name")
    --local level_bg = CSResourceMgr.seekNodeByName(btn,"level")
    local level_icon = CSResourceMgr.seekNodeByName(btn,"levelicon")
    --local attr_bg = CSResourceMgr.seekNodeByName(btn,"attr_bg")
    local attr_icon = CSResourceMgr.seekNodeByName(btn,"att_icon")
    
    local rarePoint = PokemonInfo.getPokemonInfoByID(petID).rarePoint
    local rareRes = BattleFuncMgr.getStagePics(rarePoint)
    CSResourceMgr.setButtonTextureByNode(btn, rareRes.p1, rareRes.p1, rareRes.p1)
    CSResourceMgr.setSpriteTextureByNode(icon, PokemonInfo.getPokemonIconByID(petID))
    CSResourceMgr.setLabelStringByNode(name, LuaSqlite.getLanguageByKey(PokemonInfo.getPokemonInfoByID(petID).name), {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelColorByNode(name,PokemonInfo.COLOR[rarePoint])
    local fn = PetEducationMgr.getRareIcon(rarePoint)
    CSResourceMgr.setSpriteTextureByNode(level_icon, PetEducationMgr.getRareIcon(rarePoint))
    level_icon:setScale(0.48)
    local attriInfo = tonumber(PokemonInfo.getPokemonInfoByID(petID).elementAtt1)
    local attriRes = "UI/CommonFiles/"..attriInfo..".png"
    --local attrCirRes = "Pet/AttriIcon/small_"..attriInfo..".png"
    --CSResourceMgr.setSpriteTextureByNode(attr_bg, attrCirRes)
    CSResourceMgr.setSpriteTextureByNode(attr_icon, attriRes)
    btn:setVisible(true)
    btn.petID = petID
    CSResourceMgr.clickEventBindingByNode(btn, function()
        --PetInfoViewMgr.UpdatePetEvo(btn.petID)
        updatePetAni(btn.petID)

        updatePetInfo(btn.petID)
        
        updatePetBook(btn.petID)

        UpdateRadar(btn.petID, 0, 0)

        updateGiftAndHelperSkills(btn.petID)

        PetInfoViewMgr.UpdatePetEvo(btn.petID)
    end)
end

function PetInfoViewMgr.UpdatePetEvo(petID)
    --print("ffffffffffffffffffffff petID=",petID)
    local evoInfo = petEvoInfo[petID]
    if evoInfo ~= nil then
        if evoInfo.evo_before ~= nil then
            local tbl = string.split(evoInfo.evo_before, ",")
            if #tbl > 0 and tonumber(tbl[1]) > 0 then
                setPetEvo(CSResourceMgr.getNodeByName(resName,"pet_pre"), tonumber(tbl[1]))
            else
                CSResourceMgr.getNodeByName(resName,"pet_pre"):setVisible(false)
            end 
        end
        if evoInfo.evo_after ~= nil then
            local tbl = string.split(evoInfo.evo_after, ",")
            if #tbl > 0 then
                for i=1,3 do
                    if i <= #tbl and tonumber(tbl[i]) > 0 then
                        setPetEvo(CSResourceMgr.getNodeByName(resName,"pet_next"..i), tonumber(tbl[i]))
                    else
                        CSResourceMgr.getNodeByName(resName,"pet_next"..i):setVisible(false)
                    end
                end
            end
        end
    end
end

function PetInfoViewMgr.show(scene, petID, closeCallBack)
    --print("------------PetInfoViewMgr.show petID=",petID)
    PetHandBook.setVisible(false)
    GachaViewMgr.setVisible(false)
    AchievementListMgr.setVisible(false)
    if CSResourceMgr.getCsbObj(resName) or petID == nil then
        return  
    end
    
    UIStack.push("PetInfoViewMgr",PetInfoViewMgr.hideUI,false)
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        --CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.setFullScreen(resName)
        CocosModuleMgr.setEdgeDistance(curLayer, nil, nil, 20, nil, false)
        curLayer:setVisible(false)
        
        curLayer = CSResourceMgr.createRes(scene, resNameDownBar)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CocosModuleMgr.setEdgeDistance(curLayer, 0, nil, nil, 0, false)
        curLayer:setVisible(false)

        CSResourceMgr.clickEventBinding(resName, "btn_close", function()
            PetInfoViewMgr.hideUI()
            if closeCallBack then closeCallBack() end
        end)
        
        CSResourceMgr.clickEventBinding(resName, "message", function()
            commentMessage(petID)
        end, nil, 1)
        
        CSResourceMgr.clickEventBinding(resNameDownBar, "get", function()
            showGetUI(petID)
        end)
        --[[
        for i=1, 4 do
            local giftSkill = CSResourceMgr.getNodeByName(resName,"tianfujineng"..i)
            CSResourceMgr.clickEventBindingByNode(giftSkill, function()
                PetSkillViewMgr.showConciseSkillInfo(giftSkill.skillInfo, 1)
            end)
            
            local helperSkill = CSResourceMgr.getNodeByName(resName,"yuanzhujineng"..i)
            CSResourceMgr.clickEventBindingByNode(helperSkill, function()
                PetSkillViewMgr.showConciseSkillInfo(helperSkill.skillInfo, 2)
            end)
        end
        ]]
        initStaticData()
        
        updatePetAni(petID)
        
        updatePetInfo(petID)
        
        updatePetBook(petID)
        
        UpdateRadar(petID, 0, 0)
        
        updateGiftAndHelperSkills(petID)
        
        PetInfoViewMgr.UpdatePetEvo(petID)
        
        local book = CSResourceMgr.getNodeByName(resName, {"bg","960","diban1","handbook"})
        local bookPanel = CSResourceMgr.seekNodeByName(book, "panel")
        --bookPanel:setScale(0, 0)
        showBookPanel(bookPanel, false)
        CSResourceMgr.clickEventBindingByNode(book, function()
            --[[
            if bookPanel:getScaleX() > 0 then
                transition.scaleTo(bookPanel, {scale = 0, time = 0.1})
            else
                transition.scaleTo(bookPanel, {scale = 1, time = 0.1})
            end
            ]]
            toggleBookPanel(bookPanel)
        end, 1)
        
        CSResourceMgr.clickEventBinding(resName, "bg", function()
            --[[
            if bookPanel:getScaleX() > 0 then
                transition.scaleTo(bookPanel, {scale = 0, time = 0.1})
            end
            ]]
            showBookPanel(bookPanel, false)
        end)
        
        local tab1 = CSResourceMgr.getNodeByName(resName, {"bg","960","tab1"})
        local tab2 = CSResourceMgr.getNodeByName(resName, {"bg","960","tab2"})
        local tab3 = CSResourceMgr.getNodeByName(resName, {"bg","960","tab3"})
        CSResourceMgr.clickEventBindingByNode(tab1, function()
            CSResourceMgr.setButtonTextureByNode(tab1, "UI/CommonFiles/share_paging_05.png", "UI/CommonFiles/share_paging_05.png", "UI/CommonFiles/share_paging_unchecked_05.png")
            CSResourceMgr.setButtonTextureByNode(tab2, "UI/CommonFiles/share_paging_unchecked_05.png", "UI/CommonFiles/share_paging_05.png", "UI/CommonFiles/share_paging_unchecked_05.png")
            CSResourceMgr.setButtonTextureByNode(tab3, "UI/CommonFiles/share_paging_unchecked_05.png", "UI/CommonFiles/share_paging_05.png", "UI/CommonFiles/share_paging_unchecked_05.png")
            CSResourceMgr.getNodeByName(resName, {"bg","960","diban_skill1"}):setVisible(true)
            CSResourceMgr.getNodeByName(resName, {"bg","960","diban_skill2"}):setVisible(false)
            CSResourceMgr.getNodeByName(resName, {"bg","960","diban_evo"}):setVisible(false)
        end)
        
        CSResourceMgr.clickEventBindingByNode(tab2, function()
            CSResourceMgr.setButtonTextureByNode(tab1, "UI/CommonFiles/share_paging_unchecked_05.png", "UI/CommonFiles/share_paging_05.png", "UI/CommonFiles/share_paging_unchecked_05.png")
            CSResourceMgr.setButtonTextureByNode(tab2, "UI/CommonFiles/share_paging_05.png", "UI/CommonFiles/share_paging_05.png", "UI/CommonFiles/share_paging_unchecked_05.png")
            CSResourceMgr.setButtonTextureByNode(tab3, "UI/CommonFiles/share_paging_unchecked_05.png", "UI/CommonFiles/share_paging_05.png", "UI/CommonFiles/share_paging_unchecked_05.png")
            CSResourceMgr.getNodeByName(resName, {"bg","960","diban_skill1"}):setVisible(false)
            CSResourceMgr.getNodeByName(resName, {"bg","960","diban_skill2"}):setVisible(true)
            CSResourceMgr.getNodeByName(resName, {"bg","960","diban_evo"}):setVisible(false)
        end)
        
        CSResourceMgr.clickEventBindingByNode(tab3, function()
            CSResourceMgr.setButtonTextureByNode(tab1, "UI/CommonFiles/share_paging_unchecked_05.png", "UI/CommonFiles/share_paging_05.png", "UI/CommonFiles/share_paging_unchecked_05.png")
            CSResourceMgr.setButtonTextureByNode(tab2, "UI/CommonFiles/share_paging_unchecked_05.png", "UI/CommonFiles/share_paging_05.png", "UI/CommonFiles/share_paging_unchecked_05.png")
            CSResourceMgr.setButtonTextureByNode(tab3, "UI/CommonFiles/share_paging_05.png", "UI/CommonFiles/share_paging_05.png", "UI/CommonFiles/share_paging_unchecked_05.png")
            CSResourceMgr.getNodeByName(resName, {"bg","960","diban_skill1"}):setVisible(false)
            CSResourceMgr.getNodeByName(resName, {"bg","960","diban_skill2"}):setVisible(false)
            CSResourceMgr.getNodeByName(resName, {"bg","960","diban_evo"}):setVisible(true)
        end)
    end
    
    local function playCSB()
        CSResourceMgr.getCsbObj(resName):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resName), "down")
        
        CSResourceMgr.getCsbObj(resNameDownBar):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resNameDownBar), "up")
    end
    
    local funcTable = {loadCSB, playCSB}
    
    UnblockLoader.load(funcTable, "PetInfoViewMgr.show")
end

return PetInfoViewMgr