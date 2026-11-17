local PetShareDetail = {}

local resName = {}
local orderString = {}
local skillColor = {}
local skillBackGroundPath = {}
local starText = {}
local irareString = {}
local labelColor = {}
local outlineColor = {}
local yokeValues = {}
local yokeRates  = {}

function PetShareDetail.Init()
    resName = "UI/Chat/PetShareDetail.csb"

    orderString = {
        [1] = "Pet/Education/c.png",
        [2] = "Pet/Education/b.png",
        [3] = "Pet/Education/a.png",
        [4] = "Pet/Education/s.png",
        [5] = "Pet/Education/2s.png",
        [6] = "Pet/Education/3s.png",
    }
    skillColor = {
        {r=255,g=255,b=255,a=255},
        {r=0,g=0,b=0,a=255},
        {r=26,g=37,b=48,a=255},
        {r=144,g=238,b=255,a=255},  --被动技4
        {r=60,g=220,b=109,a=255},   --援助技5
        {r=205,g=229,b=255,a=255},  --解锁技能6
        {r=80,g=97,b=115,a=255},    --未解锁技能7
        {r=212,g=212,b=212,a=255},  --未解锁提示8
        {r=9,g=20,b=31,a=255},      --9
        {r=77,g=77,b=77,a=255},     --10
    }
    labelColor = {
        {r=255,g=255,b=255,a=255},
        {r=255,g=249,b=159,a=255},
        {r=242,g=244,b=37,a=255},
        {r=129,g=233,b=249,a=255},
        {r=254,g=243,b=57,a=255},   --淡黄5
        {r=255,g=255,b=255,a=255},
        {r=170,g=170,b=170,a=255},
        {r=205,g=229,b=255,a=255},
        {r=0,g=0,b=0,a=255},
        {r=227,g=233,b=255,a=255},  --喂食10
        {r=205,g=229,b=255,a=255},  --技能名
        {r=80,g=97,b=115,a=255},    --点击替换
        {r=60,g=220,b=109,a=255},   --强化下一级
        {r=144,g=238,b=255,a=255},  --14
        {r=144,g=238,b=255,a=255},  --15
        {r=227,g=233,b=255,a=255},  --16
        {r=255,g=72,b=0,a=255},     --17
        {r=248,g=67,b=4,a=255},     --18
        {r=255,g=0,b=0,a=255},      --19
    }
    skillBackGroundPath[1] = {
        "UI/CommonFiles/skill_passive_base_nomal_01.png",
        "UI/CommonFiles/skill_passive_base_blue_01.png",
        "UI/CommonFiles/skill_passive_base_violet_01.png",
        "UI/CommonFiles/skill_passive_base_yellow_01.png",
    }
    skillBackGroundPath[2] = {
        "UI/CommonFiles/skill_aid_base_nomal_01.png",
        "UI/CommonFiles/skill_aid_base_blue_01.png",
        "UI/CommonFiles/skill_aid_base_violet_01.png",
        "UI/CommonFiles/skill_aid_base_yellow_01.png",
    }
    skillBackGroundPath[3] = {
        "UI/CommonFiles/fight_skill_green.png",
        "UI/CommonFiles/fight_skill_blue.png",
        "UI/CommonFiles/fight_skill_purple.png",
        "UI/CommonFiles/fight_skill_yellow.png",
        "Battle/downEdge_A/skillStage/5.png",
        "Battle/downEdge_A/skillStage/6.png",
    }
    starText = {
        "1","2","3","4","5",
    }
    irareString = {
        "Pet/Education/b.png",
        "Pet/Education/a.png",
        "Pet/Education/s.png",
        "Pet/Education/2s.png",
    }
    outlineColor = {
        {r=0,g=0,b=0,a=255},
        {r=255,g=255,b=255,a=255},
        {r=38,g=54,b=76,a=255},
        {r=38,g=21,b=0,a=255},
        {r=209,g=138,b=0,a=255},    --5
        {r=10,g=49,b=93,a=255},
        {r=38,g=54,b=76,a=255},
    }
    yokeValues = {0,0,0,0,0,0}
    yokeRates  = {0,0,0,0,0,0}
end

function PetShareDetail.show(petInfo)
    if CSResourceMgr.getCsbObj(resName) then
        return
    end
    local scene = SceneMgr.getRunningScene
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName)
        CSResourceMgr.setRelativePosition(resName, 320,480)
        curLayer:setVisible(false)
        --...
        --宠物星数
        local function updateStars()
            local star_num = (petInfo.star < 5) and petInfo.star or 5
            local star_bar = CSResourceMgr.getNodeByName(resName, "star_bar")

            for i=1, star_num do
                local star_ico = CSResourceMgr.seekNodeByName(star_bar,"star"..i)
                CSResourceMgr.setSpriteTextureByNode(star_ico, "Pet/Education/xing.png")
            end
        end
        --第二行技能2
        local function refreshSingleSkill(node, isLocked, isEmpty, strLock, skillType, skillId, objID)
            local spriteIcon    = CSResourceMgr.seekNodeByName(node, "icon_Copy")
            local labelName     = CSResourceMgr.seekNodeByName(node, "skillName_Copy")
            local spriteLock    = CSResourceMgr.seekNodeByName(node, "lock_Copy")
            local labelLock     = CSResourceMgr.seekNodeByName(spriteLock, "lockLabel_Copy")
            local spriteDiban   = CSResourceMgr.seekNodeByName(node, "skillLevel_Copy")
            local spriteRare    = CSResourceMgr.seekNodeByName(spriteDiban, "skillLevelIcon_Copy")
            local labelType     = CSResourceMgr.seekNodeByName(node, "label_Copy")
            local skillInfo     = (skillId == 0) and {} or PokemonInfo.getPetSkillInfoById(skillId)
            local skillIcon     = skillInfo.icon
            local skillName     = isEmpty and "" or skillInfo.name--to do:点击替换
            local skillRare     = skillInfo.airpower or 2
            local btn           = CSResourceMgr.seekNodeByName(node, "beidongjineng_Copy")

            spriteLock:setVisible(isLocked)

            CSResourceMgr.setLabelStringByNode(labelLock, strLock)
            CSResourceMgr.setLabelColorByNode(labelLock, skillColor[8])
            labelLock:enableOutline({r=0,g=0,b=0,a=255}, 1)

            CSResourceMgr.setLabelStringByNode(labelName, skillName)
            CSResourceMgr.setLabelColorByNode(labelName, (isLocked or isEmpty) and skillColor[7] or skillColor[6])
            labelName:enableOutline((isLocked or isEmpty) and {r=0,g=0,b=0,a=255} or outlineColor[4], 1)

            CSResourceMgr.setSpriteTextureByNode(spriteIcon, isEmpty and "" or "Battle/skillIcon/"..skillIcon..".png")
            CSResourceMgr.setSpriteTextureByNode(spriteRare, irareString[(skillType == 0) and (skillRare - 1) or skillType])
            spriteRare:setScale(0.5)
            spriteDiban:setColor(isLocked and skillColor[10] or skillColor[1])
            btn:setColor(isLocked and skillColor[10] or skillColor[1])
            spriteIcon:setColor(isLocked and skillColor[10] or skillColor[1])

            CSResourceMgr.setLabelStringByNode(labelType, (skillType ~= 0) and "skillType6" or "skillType7")
            CSResourceMgr.setLabelColorByNode(labelType, (skillType ~= 0) and skillColor[4] or skillColor[5])
            labelType:enableOutline({r=0,g=0,b=0,a=255}, 1)
            local iconPath = ""
            if skillType == 0 then
                iconPath = skillBackGroundPath[2]
            else
                iconPath = skillBackGroundPath[1]
            end
            CSResourceMgr.setButtonTextureByNode(btn, iconPath[skillInfo.airpower],iconPath[skillInfo.airpower],iconPath[skillInfo.airpower])

            CSResourceMgr.clickEventBindingByNode(btn, function ()
                if not isEmpty then
                    PetSkillViewMgr.showConciseSkillInfo(skillInfo, 2)
                end
            end)
        end
        --第二行技能
        local function refreshSkills(petInfo)
            local petStarupInfo = PokemonInfo.getPetStarUpInfoByID(petInfo.pokeID)
            local paSkills      = petInfo.paSkills--被动技能
            local petStars      = petInfo.star

            for i = 1, 5 do
                local node = CSResourceMgr.getNodeByName(resName,"beidongjinengAll_Copy_"..i)

                local skillId   = paSkills[i]["paSkillID"]
                local skillType = paSkills[i]["paSkillType"]
                local isLocked  = i > 2 and petStars < ((i - 2) * 2 - 1)
                local isEmpty   = skillId == 0
                local strLock   = CocosModuleMgr.createStringWithFormat({"train43", starText[i]})
                refreshSingleSkill(node, isLocked, isEmpty, strLock, skillType, skillId, petInfo.objID)
            end
        end
        --第一行技能
        local function refreshMainPageSkills(petInfo)
            local index = 1
            for k,v in pairs(petInfo.skills) do
                local skillNode = CSResourceMgr.getNodeByName(resName, "jineng"..index)
                local skillName = CSResourceMgr.seekNodeByName(skillNode, "jineng"..index.."Name")
                local skillIcon = CSResourceMgr.seekNodeByName(skillNode, "jineng"..index.."Icon")
                if v ~= 0 then
                    local skillInfo = PokemonInfo.getPetSkillInfoById(v)
                    local skillLv = (skillInfo.id % 5 == 0) and 5 or skillInfo.id % 5
                    local labelSkillName = skillInfo.name
                    local spriteSkillIcon = "Battle/skillIcon/"..skillInfo.icon..".png"
                    CSResourceMgr.setLabelColorByNode(skillName, (index == 4) and labelColor[5] or labelColor[11])
                    CSResourceMgr.setLabelStringByNode(skillName, labelSkillName, (index == 4) and outlineColor[4] or outlineColor[3])
                    skillIcon:loadTexture(spriteSkillIcon)
                    if index == 4 then
                        skillIcon:setScale(10/7)
                        local anger = CSResourceMgr.getNodeByName(resName, "anger")
                        CSResourceMgr.setSpriteTextureByNode(anger, "UI/CommonFiles/esoteric_skill_anger_0"..skillInfo.energy..".png")
                        -- local attrBack = CSResourceMgr.seekNodeByName(skillNode, "attrBack")
                        -- CSResourceMgr.setSpriteTextureByNode(attrBack, "Pet/AttriIcon/small_"..skillInfo.skillAtt..".png")
                    end
                    if (index ~= 1) and (index ~= 4) then
                        local background = skillBackGroundPath[3][skillInfo.airpower]
                        CSResourceMgr.setButtonTextureByNode(skillNode, background, background, background)
                        local energyNum = CSResourceMgr.seekNodeByName(skillNode, "energyNum")
                        CSResourceMgr.setLabelStringByNode(energyNum, skillInfo.energy,{r=0,g=0,b=0,a=255,w=1,s=1})
                        CSResourceMgr.setLabelColorByNode(energyNum, {r=255,g=255,b=255,a=255})
                    end
                    if index == 1 then
                        local background = skillBackGroundPath[3][skillInfo.airpower]
                        CSResourceMgr.setButtonTextureByNode(skillNode, background, background, background)
                    end
                    CSResourceMgr.clickEventBindingByNode(skillNode, function()
                        PetSkillViewMgr.showConciseSkillInfo(skillInfo, 1)
                    end, 3)
                    local attr = CSResourceMgr.seekNodeByName(skillNode, "attr")
                    CSResourceMgr.setSpriteTextureByNode(attr, "UI/CommonFiles/"..skillInfo.skillAtt..".png")
                    local lv = CSResourceMgr.seekNodeByName(skillNode, "lv")
                    CSResourceMgr.setSpriteTextureByNode(lv, "UI/CommonFiles/develop_effect_icon_lv"..skillLv..".png")
                    local skillTypePath = ""
                    if skillInfo.skill_B_Type == 3 then
                        skillTypePath = "UI/CommonFiles/develop_icon_atk_01.png"
                    elseif skillInfo.skill_B_Type == 4 then
                        skillTypePath = "UI/CommonFiles/develop_icon_mag_01.png"
                    else
                        skillTypePath = "UI/CommonFiles/develop_icon_buff_add_01.png"
                    end
                    local skillType = CSResourceMgr.seekNodeByName(skillNode, "type"..index)
                    CSResourceMgr.setSpriteTextureByNode(skillType, skillTypePath)
                else
                    CSResourceMgr.seekNodeByName(skillNode, "info"):setVisible(false)
                    if index == 4 then
                        CSResourceMgr.getNodeByName(resName, "typeBackBig"):setVisible(false)
                    end
                    skillNode:setVisible((index ~= 4))
                    local labelSkillName = ""
                    CSResourceMgr.setLabelColorByNode(skillName, (index == 4) and labelColor[5] or labelColor[12])
                    CSResourceMgr.setLabelStringByNode(skillName, labelSkillName, outlineColor[1])
                    skillIcon:loadTexture("empty.png")
                    if (index ~= 1) and (index ~= 4) then
                        local background = "empty.png"
                        CSResourceMgr.setButtonTextureByNode(skillNode, background, background, background)
                    end
                end
                index = index + 1
            end
        end
        --六星图
        -- local function drawAttrPolygon(drawNode, rateInfo, petInfo, color)
        --     local center = cc.p(91,102)
        --     local xfix = 8  -- 20
        --     local yfix = 9  -- 23
            
        --     local rateValueMax = 2000
            
        --     -- 六边形逆时针方向
        --     local values = {
        --         BattleBasicValueCalc.calcHp    (rateInfo,petInfo.star,petInfo.hpx,  0,yokeValues[1],0,yokeRates[1],petInfo.Stage,1),
        --         BattleBasicValueCalc.calcAct   (rateInfo,petInfo.star,petInfo.atk,  0,yokeValues[2],0,yokeRates[2],petInfo.Stage,1),
        --         BattleBasicValueCalc.calcDef   (rateInfo,petInfo.star,petInfo.def,  0,yokeValues[3],0,yokeRates[3],petInfo.Stage,1),
        --         BattleBasicValueCalc.calcSpeAct(rateInfo,petInfo.star,petInfo.satk, 0,yokeValues[4],0,yokeRates[4],petInfo.Stage,1),
        --         BattleBasicValueCalc.calcSpeDef(rateInfo,petInfo.star,petInfo.sdef, 0,yokeValues[5],0,yokeRates[5],petInfo.Stage,1),
        --         BattleBasicValueCalc.calcSpeed (rateInfo,petInfo.star,petInfo.speed,0,yokeValues[6],0,yokeRates[6],petInfo.Stage,1),
        --     }
            
        --     local cond = rateInfo.rarePoint > 3
        --     local max1 = cond and 7195 or 4165
        --     local max2 = cond and 2359 or 1365
            
        --     local rate = {
        --         values[1] / max1, --hp
        --         values[2] / max2,  --
        --         values[3] / max2,
        --         values[4] / max2,
        --         values[5] / max2,
        --         values[6] / max2,
        --     }

        --     local points = {}
        --     points[1] = cc.p(center.x, center.y+(yfix+(88-yfix)*rate[1]))
        --     points[2] = cc.p(center.x-(xfix+(76-xfix)*rate[2]), center.y+(yfix/2+(44-yfix/2)*rate[2]))
        --     points[3] = cc.p(center.x-(xfix+(76-xfix)*rate[3]), center.y-(yfix/2+(44-yfix/2)*rate[3]))
        --     points[4] = cc.p(center.x, center.y-(yfix+(88-yfix)*rate[4]))
        --     points[5] = cc.p(center.x+(xfix+(76-xfix)*rate[5]), center.y-(yfix/2+(44-yfix/2)*rate[5]))
        --     points[6] = cc.p(center.x+(xfix+(76-xfix)*rate[6]), center.y+(yfix/2+(44-yfix/2)*rate[6]))
        --     drawNode:clear()
        --     drawNode:setColor( color )  --outline
        --     drawNode:drawSolidPolygon(points, 6, color)
        -- end
        -- local function update_yoke(petInfo)
        --     yokeValues = {0,0,0,0,0,0}
        --     yokeRates  = {0,0,0,0,0,0}
        --     if petInfo.yoke and petInfo.yoke.yokeIDs then   -- 已激活羁绊id
        --         for k,v in pairs(petInfo.yoke.yokeIDs) do
        --             local yokeInfo = PokemonInfo.getYokeInfoByID(v)
        --             if yokeInfo then
        --                 for k,v in pairs(yokeInfo.effectVec) do
        --                     local effectInfo = PokemonInfo.getYokeEffectByID(v)
        --                     if effectInfo.type >= 0 and effectInfo.type <= 6 then
        --                         yokeValues[effectInfo.type] = yokeValues[effectInfo.type] + effectInfo.arg
        --                     elseif effectInfo.type >= 11 and effectInfo.type <= 16 then
        --                         yokeRates[effectInfo.type-10] = yokeRates[effectInfo.type-10] + effectInfo.arg
        --                     end
        --                 end
        --             end
        --         end
        --     end
        -- end
        local pokemonInfo = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
        local title = CSResourceMgr.getNodeByName(resName, "title")
        CSResourceMgr.setLabelColor(resName, "title", {r=160,g=235,b=250,a=255})
        CSResourceMgr.setLabelString(resName, "title", "petDetailInfo1", "", {r=37,g=54,b=75,a=255})
        local power_text = CSResourceMgr.getNodeByName(resName, "power_text")
        CSResourceMgr.setLabelColor(resName, "power_text", {r=254,g=243,b=57,a=255})
        CSResourceMgr.setLabelString(resName, "power_text", petInfo.fc, "", {r=0,g=0,b=0,a=255,w=1,s=1})
        local petLevel = CSResourceMgr.getNodeByName(resName, "p_level")
        CSResourceMgr.setLabelStringByNode(petLevel, "Lv."..petInfo.level,{r=0,g=0,b=0,a=255,w=1,s=1})
        CSResourceMgr.setLabelColorByNode(petLevel, {r=255,g=255,b=255,a=255})
        local skillTitle = CSResourceMgr.getNodeByName(resName, "skillTitle")
        CSResourceMgr.setLabelStringByNode(skillTitle, "petDetailInfo2", {r=0,g=0,b=0,a=255,w=1,s=1})
        CSResourceMgr.setLabelColorByNode(skillTitle, {r=255,g=255,b=255,a=255})
        local skill2Title = CSResourceMgr.getNodeByName(resName, "skill2Title")
        CSResourceMgr.setLabelStringByNode(skill2Title, "petDetailInfo3", {r=0,g=0,b=0,a=255,w=1,s=1})
        CSResourceMgr.setLabelColorByNode(skill2Title, {r=255,g=255,b=255,a=255})
        CSResourceMgr.getNodeByName(resName,"orderString"):loadTexture(orderString[pokemonInfo.rarePoint])
        updateStars()
        refreshSkills(petInfo)
        refreshMainPageSkills(petInfo)
        --六星图设置
        -- update_yoke(petInfo)
        -- yokeValues = PetEducationMgr.getYokeParamByObjID(petInfo).values
        -- yokeRates = PetEducationMgr.getYokeParamByObjID(petInfo).rates
        -- local text = {"train11","train12","train14","train16","train15","train13",}
        -- local num  = {
        --     BattleBasicValueCalc.calcHp    (pokemonInfo,petInfo.star,petInfo.hpx,  0,yokeValues[1],0,yokeRates[1],petInfo.Stage,petInfo.level),-- * 100  / (7950),
        --     BattleBasicValueCalc.calcAct   (pokemonInfo,petInfo.star,petInfo.atk,  0,yokeValues[2],0,yokeRates[2],petInfo.Stage,petInfo.level),-- * 100  / (3569),
        --     BattleBasicValueCalc.calcSpeAct(pokemonInfo,petInfo.star,petInfo.satk, 0,yokeValues[3],0,yokeRates[3],petInfo.Stage,petInfo.level),-- * 100  / (3569),
        --     BattleBasicValueCalc.calcSpeed (pokemonInfo,petInfo.star,petInfo.speed,0,yokeValues[4],0,yokeRates[4],petInfo.Stage,petInfo.level),-- * 100  / (2995),
        --     BattleBasicValueCalc.calcSpeDef(pokemonInfo,petInfo.star,petInfo.sdef, 0,yokeValues[5],0,yokeRates[5],petInfo.Stage,petInfo.level),-- * 100  / (3159),
        --     BattleBasicValueCalc.calcDef   (pokemonInfo,petInfo.star,petInfo.def,  0,yokeValues[6],0,yokeRates[6],petInfo.Stage,petInfo.level),-- * 100  / (3159),
        -- }
        local stage = CSResourceMgr.getNodeByName(resName,"attrStageNode")
        local sixDimensionsTex = PetEducationMgr.showSixDimensionsTex(stage, petInfo, cc.c4f(1.0, 1.0, 0, 0.8))
        -- for i=1,6 do
        --     local a_node = CSResourceMgr.getNodeByName(resName,"attr"..i)
        --     local a_num_node = CSResourceMgr.getNodeByName(resName,"num"..i)
        --     CSResourceMgr.setLabelStringByNode(a_node,text[i],CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        --     CSResourceMgr.setLabelStringByNode(a_num_node,num[i],CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        --     a_node:enableOutline({r=0,g=0,b=0,a=255}, 1)
        --     a_num_node:enableOutline({r=0,g=0,b=0,a=255}, 1)
        -- end
        -- local stage = CSResourceMgr.getNodeByName(resName,"attrStage")
        -- local backIcon = (pokemonInfo.rarePoint >= 4) and "Pet/Education/cwxx_liuwei_s.png" or "Pet/Education/cwxx_liuwei.png"
        -- CSResourceMgr.setSpriteTextureByNode(stage, backIcon)
        -- local cur_polygon_node = cc.NVGDrawNode:create()
        -- stage:addChild(cur_polygon_node)
        -- drawAttrPolygon(cur_polygon_node, pokemonInfo, petInfo, cc.c4f(1.0, 1.0, 0, 0.8))
        --宠物名字
        local textColor = PokemonInfo.COLOR[pokemonInfo.rarePoint]
        CSResourceMgr.getNodeByName(resName,"p_name_text"):setTextColor(textColor)
        local name_text = LuaSqlite.getLanguageByKey(petInfo.personName)..(petInfo.Stage ~= 0 and "+"..petInfo.Stage or "")
        CSResourceMgr.setLabelString(resName,"p_name_text",name_text,nil,{r=0,g=0,b=0,a=255})
        --types
        local icon1 = "UI/CommonFiles/"..pokemonInfo.elementAtt1..".png"
        local att_icon = CSResourceMgr.getNodeByName(resName,{"bg","960","diban1","petStage","type","att_icon"})
        -- local icon2 = "Pet/AttriIcon/small_"..pokemonInfo.elementAtt1..".png"
        att_icon:loadTexture(icon1)
        att_icon:setScale(0.7)
        -- CSResourceMgr.getNodeByName(resName,{"bg","960","diban1","petStage","type","att_background"}):loadTexture(icon2)
        if pokemonInfo.elementAtt2~=0 then
            local icon2 = "UI/CommonFiles/"..pokemonInfo.elementAtt2..".png"
            local att_icon2 = CSResourceMgr.getNodeByName(resName,{"bg","960","diban1","petStage","type","att_background2","att_icon2"})
            att_icon2:loadTexture(icon2)
            att_icon2:setScale(0.5)
            CSResourceMgr.getNodeByName(resName,{"bg","960","diban1","petStage","type","att_background2"}):setVisible(true)
        end
        --宠物动画
        local petRes = PokemonInfo.getPokemonResByID(petInfo.pokeID)
        local petAni = CSResourceMgr.getNodeByName(resName, "petAni")
        local aniRes = AnimationMgr.createAni(petAni, petRes, 0, 0, "Pet_Evolution_"..petInfo.pokeID)
        AnimationMgr.playAni(petRes, "idle", true, "Pet_Evolution_"..petInfo.pokeID)
        AnimationMgr.setSkin(aniRes.res, petInfo.skin, aniRes.tag)

        CSResourceMgr.clickEventBinding(resName, "black", function()
            PetShareDetail.hide()
        end)
    end

    local function playCSB()
        CSResourceMgr.getCsbObj(resName):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resName), "down")
    end

    local funcTable = {loadCSB, playCSB}
    UnblockLoader.load(funcTable, "PetShareDetail")
end

function PetShareDetail.hide()
    UnblockLoader.cancel("PetShareDetail")
    CSResourceMgr.removeCSObjectByTag(resName)
end



return PetShareDetail