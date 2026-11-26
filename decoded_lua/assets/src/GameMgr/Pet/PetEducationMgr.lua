local PetEducationMgr = {}

local resNameBG = ""
local resName_base = ""
local resNameEvoB = ""
local resName_TopLeft = ""
local resName_TopRight = ""
local currLayer

local petInfo = {}

local currTab = 1
local tabName = {}
local tabResName = {}
local tabObjTable = {}
local tabInitFunc = {}

local genderIcon = {}

local orderString = {}--稀有度图片

local attr_color   = cc.c4f(1.0, 1.0, 0, 0.8)
local attr_color_X = cc.c4f(0.06, 0.62, 0.78, 0.38)

local attr_table = {}

local LoaderTag = {}

local spColor = {}
local outlines = {}
local labelColor = {}
local outlineColor = {}
local spriteColor = {}

-- evolution
local cur_polygon_node
local evo_polygon_node

-- yoke
local yokeValues = {}
local yokeRates  = {}
local yokePercent = {}

local layerEvolutionPartA = nil
local layerEvolutionPartB = nil
local sortedEvolutionPets = {}
local selectedEvolutionPetIndex = 1
local trainItemNode = {} --训练node
local pageStatus = 1
local pageStarup = 3
local isFirstEnter = true
local mainPageSkillNode = {}
local menu = nil
PetEducationMgr.addSkills = {}
PetEducationMgr.perFC = 0
PetEducationMgr.closeCallback = nil
PetEducationMgr.btnBodyLockState = false--进化页用
PetEducationMgr.needUpdateSevenDayPetYoke = false--七日活动羁绊数据
PetEducationMgr.iosSendPetEvolution = false
PetEducationMgr.MAX_STAR_LEVEL = 5

local a_idx = {
    "hpx",
    "atk",
    "def",
    "satk",
    "sdef",
    "speed",
}

local b_idx = {
    "ohp",
    "oatk",
    "odef",
    "osatk",
    "osdef",
    "ospeed"
}

PetEducationMgr.LABLE_OUTLINE_THICK = 1

local EnumSkillType = {
    "skillType0",-- "普通",
    "skillType1",-- "奥义",
    "skillType2",-- "特性",
    "skillType3",-- "物理",
    "skillType4",-- "特殊",
    "skillType5",-- "变化",
    "skillType6",-- "被动",
    "skillType7",-- "援助",
    "skillType8",-- "天赋",
}

local skillLvIconTable = {
    "UI/CommonFiles/develop_effect_icon_lv1.png",
    "UI/CommonFiles/develop_effect_icon_lv2.png",
    "UI/CommonFiles/develop_effect_icon_lv3.png",
    "UI/CommonFiles/develop_effect_icon_lv4.png",
    "UI/CommonFiles/develop_effect_icon_lv5.png",
}

local trainBtnTex = {
    "UI/CommonFiles/menu_green_normal_su_03.png",
    "UI/CommonFiles/menu_green_ed_su_03.png",
    "UI/CommonFiles/menu_gray_normal_su_03.png",
    "UI/CommonFiles/menu_yellow_normal_su_06.png",
    "UI/CommonFiles/menu_yellow_ed_su_06.png"
}

local trainBtnIconTex = {
    "UI/CommonFiles/cwsx_tianjia_nomal_03.png",
    "UI/CommonFiles/cwsx_tianjia_ed_03.png",
    "UI/CommonFiles/cwsx_tianjia_gray_03.png",
    "UI/CommonFiles/cwsx_tianjia_nomal_05.png",
    "UI/CommonFiles/cwsx_tianjia_ed_05.png"
}

local passiveSkillBackGroundPath = {
    "UI/CommonFiles/skill_passive_base_blue_01.png",
    "UI/CommonFiles/skill_passive_base_violet_01.png",
    "UI/CommonFiles/skill_passive_base_yellow_01.png",
}

local aidSkillBackGroundPath = {
    "UI/CommonFiles/skill_aid_base_blue_01.png",
    "UI/CommonFiles/skill_aid_base_violet_01.png",
    "UI/CommonFiles/skill_aid_base_yellow_01.png",
}

PetEducationMgr.maxSkillEnergyPath = {
    "UI/CommonFiles/esoteric_skill_anger_01.png",
    "UI/CommonFiles/esoteric_skill_anger_02.png",
    "UI/CommonFiles/esoteric_skill_anger_03.png",
    "UI/CommonFiles/esoteric_skill_anger_04.png",
}

local function largeNumConvert(num)
    local ret
    if num > 1000 then ret = string.format("%.1fk", num/1000) end
    if num > 100000 then ret = string.format("%dm", num/1000000) end
    return ret
end

function PetEducationMgr.Init()
    require("src.GameMgr.Pet.PetEducationMgrA")
    require("src.GameMgr.Pet.PetEducationMgrB")
    require("src.GameMgr.Pet.PetEducationMgrC")
    
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    resName_base = "Pet/Education/PetsEducationNew.csb"
    resNameEvoB = "Pet/Education/EvolutionPageB.csb"
    resName_TopLeft = "Pet/Education/PetsEducationTopLeft.csb"
    resName_TopRight = "Searching/advConfirm/top_right.csb"
    
    petInfo = {}
    
    currTab = 1
    tabName = {"train1", "train2", "train5", "train3", "train49", "train6"}
    tabResName = {
        "Pet/Education/HomePageNew.csb",
        "Pet/Education/UpgradePage.csb",
        "Pet/Education/StarupPage.csb",
        "Pet/Education/EvolutionPageA.csb",
        "Pet/Education/trainPage.csb",
        "Pet/Education/PetchainPageNew.csb",
        "Pet/Education/PetSixDimensions.csb",
    }
    tabInitFunc = {
        PetEducationMgr.homePageInit,
        PetEducationMgr.strengthenPageInit,
        PetEducationMgr.starupPageInit,
        PetEducationMgr.evolutionPageInit,
        PetEducationMgr.trainPageInit,
        PetEducationMgr.petchainInit,
    }
    genderIcon = {
        [1] = "Pet/Education/nan.png",
        [2] = "Pet/Education/nv.png",
    }
    orderString = {
        [1] = "Pet/Education/c.png",
        [2] = "Pet/Education/b.png",
        [3] = "Pet/Education/a.png",
        [4] = "Pet/Education/s.png",
        [5] = "Pet/Education/2s.png",
        [6] = "Pet/Education/3s.png",
    }
    
    LoaderTag = {
        "PetEducationMgr-homePageInit",
        "PetEducationMgr-strengthenPageInit",
        "PetEducationMgr-starupPageInit",
        "PetEducationMgr-evolutionPageInit",
        "PetEducationMgr-trainPageInit",
        "PetEducationMgr-petchainPageInit",
        "PetEducationMgr",
    }

    spColor = {
        {r=255,g=0,b=0,a=255},
        {r=0,g=255,b=0,a=255},
    }

    outlines = {        
        {r=0,g=0,b=0,a=255},  --黑
        
        {r=0,g=0,b=0,a=255},  --黑
        {r=0,g=0,b=0,a=255},  --黑

        {r=0,g=0,b=0,a=255},  --黑
        {r=0,g=0,b=0,a=255},  --黑
        {r=0,g=0,b=0,a=255},  --黑

        {r=255,g=255,b=255,a=255},  --白
        {r=255,g=255,b=255,a=255},  --白
        {r=255,g=255,b=255,a=255},  --白

        {r=255,g=255,b=255,a=255},  --白
        {r=255,g=255,b=255,a=255},  --白
        {r=255,g=255,b=255,a=255},  --白

        {r=29,g=47,b=61,a=255},
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
        {r=60,g=220,b=109,a=255},   --20
        {r=69,g=97,b=118,a=255},    --21
        {r=0,g=255,b=0,a=255},      --22
        {r=217,g=234,b=255,a=255},  --23
    }
    outlineColor = {
        {r=0,g=0,b=0,a=255},
        {r=255,g=255,b=255,a=255},
        {r=38,g=54,b=76,a=255},
        {r=38,g=21,b=0,a=255},
        {r=209,g=138,b=0,a=255},    --5
        {r=10,g=49,b=93,a=255},
        {r=38,g=54,b=76,a=255},
        {r=0,g=0,b=0,a=255,w=1,s=2},--8
        {r=0,g=0,b=0,a=255,w=1,s=1}
    }
    spriteColor = {
        {r=37,g=53,b=69,a=255},
        {r=26,g=38,b=49,a=255},
    }
    
    cur_polygon_node = nil
    evo_polygon_node = nil
    
    -- 羁绊效果参数
    yokeValues  = {0,0,0,0,0,0,}
    yokeRates   = {0,0,0,0,0,0,}
    yokePercent = {0,0,0,0,0,0,}
    
    layerEvolutionPartA = nil
    layerEvolutionPartB = nil
    sortedEvolutionPets = {}
    selectedEvolutionPetIndex = 1
    mainPageSkillNode = {}
    menu = nil
    
    PetEducationMgr.addSkills = {}
    PetEducationMgr.perFC = 0
    PetEducationMgr.closeCallback = nil
    PetEducationMgr.btnBodyLockState = false
    
    PetTrainPointsInfo.init()
    BattleCANI.getpetBody()
end

function PetEducationMgr.getRareIcon(rarePoint)
    return orderString[rarePoint]
end
-- ==========================   Common   =====================================

-- 更新羁绊属性修正参数
local function update_yoke()
    yokeValues = {0,0,0,0,0,0,}
    yokeRates  = {0,0,0,0,0,0,}
    yokePercent = {0,0,0,0,0,0,0,0,0,0,}

    local valueTable = {1,2,3,4,5,6}
    local ratesTable = {12,13,14,15,16,17}--这个已经不用了，id是错的
    -- local percentTable = {7,10,18,9,23,8}--命中，暴击率，暴击伤害，物理减伤，魔法减伤，闪避率
    local percentTable = {7,9,11,12,13,8,15,16,10,14}
    if petInfo.yoke and petInfo.yoke.yokeValues then
        local values = petInfo.yoke.yokeValues
        for i = 1, PetEducationMgr.getTableLength(valueTable) do
            yokeValues[i] = values[valueTable[i]] or 0
        end
        for i = 1, PetEducationMgr.getTableLength(ratesTable) do
            yokeRates[i] = 0
        end
        for i = 1, PetEducationMgr.getTableLength(percentTable) do
            yokePercent[i] = values[percentTable[i]] or 0
        end
    end
end


---
--@param o_info table pet原始属性
local function drawAttrPolygon(drawNode, rateInfo, petInfo, color)
    local center = cc.p(91,102)
    local xfix = 8  -- 20
    local yfix = 9  -- 23

    -- 六边形逆时针方向
    local values = PetEducationMgr.sortPetAttrsForDrawing(rateInfo, petInfo, yokeValues, yokeRates, 1)

    local attBase = {}
    attBase[Proto.AT_HP]    = values[1]
    attBase[Proto.AT_ATK]   = values[2]
    attBase[Proto.AT_SATK]  = values[3]
    attBase[Proto.AT_DEF]   = values[6]
    attBase[Proto.AT_SDEF]  = values[5]
    attBase[Proto.AT_SPEED] = values[4]

    local extraAttr = PetEducationMgr.getExtraAttrsTable(AchievementInfo.getPotentialInfoCount(), attBase)
    values[1] = values[1] + extraAttr[Proto.AT_HP]
    values[2] = values[2] + extraAttr[Proto.AT_ATK]
    values[3] = values[3] + extraAttr[Proto.AT_SATK]
    values[4] = values[4] + extraAttr[Proto.AT_SPEED]
    values[5] = values[5] + extraAttr[Proto.AT_SDEF]
    values[6] = values[6] + extraAttr[Proto.AT_DEF]
    
    local cond = rateInfo.rarePoint > 3
    local max1 = cond and 5996 or 2485
    local max2 = cond and 1966 or 815

    local rate = {
        values[1] / max1, --hp
        values[2] / max2,  --
        values[3] / max2,
        values[4] / max2,
        values[5] / max2,
        values[6] / max2,
    }

    for i = 1, #rate do
        rate[i] = rate[i] > 1 and 1 or rate[i]
    end

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
end

-- 升星刷新
local function updateStars()
    local starNum = petInfo.star
    for i = 1, PetEducationMgr.MAX_STAR_LEVEL do
        local spriteStar = CSResourceMgr.getNodeByName(resName_base, "star"..i)
        if i <= starNum then
            CSResourceMgr.setSpriteTextureByNode(spriteStar, "Pet/Education/xing.png")
        else
            CSResourceMgr.setSpriteTextureByNode(spriteStar, "UI/CommonFiles/xing_null.png")
        end
    end
end

-- 升星特效
function PetEducationMgr.starupEffect(star_pre, callback)
    local star_num = star_pre
    local cx, cy = 68, 9
    local c_index = star_num/2 + 0.5
    local star_bar = CSResourceMgr.getNodeByName(resName_base, "star_bar")

    local end_pos = star_pre%5

    local aniRes = "Gaf/effect/starupEffect.gaf"
    local ani = AnimationMgr.createAni(star_bar, aniRes, cx+25*(end_pos-c_index), 641+cy)
    ani:setGlobalZOrder(100)
    AnimationMgr.playAniWithCallback(aniRes, "do", function()
        AnimationMgr.removeGafObjectByTag(aniRes)
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
        if callback then callback() end
    end)
end

--@param info table local pet info
--@param o_info table pet原始属性
local function showRateAttr()
    local o_info = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
    local text = {"train11","train12","train14","train16","train15","train13",}
    local num  = PetEducationMgr.sortPetAttrsForDrawing(o_info, petInfo, yokeValues, yokeRates)

    local attBase = {}
    attBase[Proto.AT_HP]    = num[1]
    attBase[Proto.AT_ATK]   = num[2]
    attBase[Proto.AT_SATK]  = num[3]
    attBase[Proto.AT_DEF]   = num[6]
    attBase[Proto.AT_SDEF]  = num[5]
    attBase[Proto.AT_SPEED] = num[4]

    local extraAttr = PetEducationMgr.getExtraAttrsTable(AchievementInfo.getPotentialInfoCount(), attBase)
    num[1] = num[1] + extraAttr[Proto.AT_HP]
    num[2] = num[2] + extraAttr[Proto.AT_ATK]
    num[3] = num[3] + extraAttr[Proto.AT_SATK]
    num[4] = num[4] + extraAttr[Proto.AT_SPEED]
    num[5] = num[5] + extraAttr[Proto.AT_SDEF]
    num[6] = num[6] + extraAttr[Proto.AT_DEF]

    -- local diversAttrs = PetEducationMgr.getDiversAttrsTable(petInfo)
    -- local newDiversAttrs = {
    --     [1] = diversAttrs[Proto.AT_HP],
    --     [2] = diversAttrs[Proto.AT_ATK],
    --     [3] = diversAttrs[Proto.AT_SATK],
    --     [4] = diversAttrs[Proto.AT_SPEED],
    --     [5] = diversAttrs[Proto.AT_SDEF],
    --     [6] = diversAttrs[Proto.AT_DEF],
    -- }
    
    local parent = CSResourceMgr.getNodeByName(resName_base, "attrStage")
    CSResourceMgr.setSpriteTextureByNode(parent, "empty.png")
    PetEducationMgr.showSixDimensionsTex(parent, petInfo, attr_color, num)

    -- for i=1,6 do
    --     local a_node = CSResourceMgr.getNodeByName(resName_base,"attr"..i)
    --     local a_num_node = CSResourceMgr.getNodeByName(resName_base,"num"..i)
    --     -- a_node:enableOutline(outlines[1], PetEducationMgr.LABLE_OUTLINE_THICK)
    --     -- a_num_node:enableOutline(outlines[1], PetEducationMgr.LABLE_OUTLINE_THICK)
    --     CSResourceMgr.setLabelStringByNode(a_node, text[i], CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
    --     CSResourceMgr.setLabelStringByNode(a_num_node, num[i], CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
    --     if o_info.rarePoint >= 4 then
    --         CSResourceMgr.setLabelColorByNode(a_node, {r=254,g=243,b=57,a=255})
    --     end
    --     if newDiversAttrs[i] > 0 then
    --         CSResourceMgr.setLabelColorByNode(a_num_node, {r=0,g=255,b=0,a=255})
    --     else
    --         CSResourceMgr.setLabelColorByNode(a_num_node, {r=255,g=255,b=255,a=255})
    --     end
    -- end

    -- local stage = CSResourceMgr.getNodeByName(resName_base,"attrStage")
    
    -- -- attributes polygon
    -- if cur_polygon_node == nil then
    --     cur_polygon_node = cc.NVGDrawNode:create()
    --     stage:addChild(cur_polygon_node)
    -- end
    -- drawAttrPolygon(cur_polygon_node, o_info, petInfo, attr_color)
    
    -- -- order
    local order = o_info.rarePoint or 6
    CSResourceMgr.getNodeByName(resName_base,"orderString"):loadTexture(orderString[order])

    if PetEducationMgr.getResPetByPokeID(petInfo.pokeID) == false then
        updateStars()
    else
        local spriteOrder = CSResourceMgr.getNodeByName(resName_base, "orderString")
        spriteOrder:setPositionY(30)
        for i = 1, PetEducationMgr.MAX_STAR_LEVEL do
            local spriteStar = CSResourceMgr.getNodeByName(resName_base, "star"..i)
            spriteStar:setVisible(false)
        end
    end
    
end

--设置六维图文字数据
function PetEducationMgr.setSixDimensionsAttrs(parent, rarePoint, num, petInfo)
    local text = {"train11","train12","train14","train16","train15","train13",}
    local diversAttrs = PetEducationMgr.getDiversAttrsTable(petInfo)

    local newDiversAttrs = {
        [1] = diversAttrs[Proto.AT_HP],
        [2] = diversAttrs[Proto.AT_ATK],
        [3] = diversAttrs[Proto.AT_SATK],
        [4] = diversAttrs[Proto.AT_SPEED],
        [5] = diversAttrs[Proto.AT_SDEF],
        [6] = diversAttrs[Proto.AT_DEF],
    }

    for i=1,6 do
        local a_node = CSResourceMgr.seekNodeByName(parent, "attr"..i)
        local a_num_node = CSResourceMgr.seekNodeByName(parent, "num"..i)
        a_node:enableOutline(outlines[1], PetEducationMgr.LABLE_OUTLINE_THICK)
        a_num_node:enableOutline(outlines[1], PetEducationMgr.LABLE_OUTLINE_THICK)
        CSResourceMgr.setLabelStringByNode(a_node, text[i],CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        CSResourceMgr.setLabelStringByNode(a_num_node, num[i], CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        if rarePoint >= 4 then
            CSResourceMgr.setLabelColorByNode(a_node, {r=254,g=243,b=57,a=255})
        end
        if newDiversAttrs[i] > 0 then
            CSResourceMgr.setLabelColorByNode(a_num_node, {r=0,g=255,b=0,a=255})
        else
            CSResourceMgr.setLabelColorByNode(a_num_node, {r=255,g=255,b=255,a=255})
        end
    end
end

--创建显示六维图
function PetEducationMgr.showSixDimensionsTex(parent, petInfo, color, sixMainAttrs)
    if parent then parent:removeAllChildren() end

    local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, tabResName[7])
    layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)

    local center = cc.p(91,102)--bgPath.width/2, bgPath.height/2
    local xfix = 8  -- 20
    local yfix = 9  -- 23

    local pokemonInfo = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
    local cond = pokemonInfo.rarePoint > 3
    local max1 = cond and 5996 or 2485
    local max2 = cond and 1966 or 815

    local compareValue1 = PetEducationMgr.getSixDimensionsDrawAttrs(petInfo, pokemonInfo, 1)
    local compareValue2 = PetEducationMgr.getSixDimensionsDrawAttrs(petInfo, pokemonInfo, petInfo.level)
    local compareValue3 = {}

    local drawValues = compareValue1
    local rate = {
        drawValues[1] / max1, --hp
        drawValues[2] / max2,  --
        drawValues[3] / max2,
        drawValues[4] / max2,
        drawValues[5] / max2,
        drawValues[6] / max2,
    }

    if sixMainAttrs ~= nil then
        for i = 1, 6 do
            rate[i] = rate[i] * (sixMainAttrs[i] / compareValue2[i])
            -- rate[i] = rate[i] <= 1 and rate[i] or 1
        end
    end

    for i = 1, 6 do
        rate[i] = rate[i] <= 1 and rate[i] or 1
    end

    local points = {}
    points[1] = cc.p(center.x, center.y+(yfix+(88-yfix)*rate[1]))
    points[2] = cc.p(center.x-(xfix+(76-xfix)*rate[2]), center.y+(yfix/2+(44-yfix/2)*rate[2]))
    points[3] = cc.p(center.x-(xfix+(76-xfix)*rate[3]), center.y-(yfix/2+(44-yfix/2)*rate[3]))
    points[4] = cc.p(center.x, center.y-(yfix+(88-yfix)*rate[4]))
    points[5] = cc.p(center.x+(xfix+(76-xfix)*rate[5]), center.y-(yfix/2+(44-yfix/2)*rate[5]))
    points[6] = cc.p(center.x+(xfix+(76-xfix)*rate[6]), center.y+(yfix/2+(44-yfix/2)*rate[6]))

    local bg = CSResourceMgr.getNodeByName(tabResName[7], "attrStage")
    bgPath = (pokemonInfo.rarePoint >= 4) and "Pet/Education/cwxx_liuwei_s.png" or "Pet/Education/cwxx_liuwei.png"
    -- bgPath = needBG or "empty.png"
    CSResourceMgr.setSpriteTextureByNode(bg, bgPath)

    local drawNode = cc.NVGDrawNode:create()
    bg:addChild(drawNode)

    drawNode:clear()
    drawNode:setColor( color )  --outline
    drawNode:drawSolidPolygon(points, 6, color)

    local node = CSResourceMgr.seekNodeByName(layer, "node")
    node:setPosition(0, 0)
    node:removeFromParent()
    node:addTo(parent)

    local values = sixMainAttrs or compareValue2
    PetEducationMgr.setSixDimensionsAttrs(node, pokemonInfo.rarePoint, values, petInfo)

    CSResourceMgr.removeCSObjectByTag(tabResName[7])
    return node
end

function PetEducationMgr.showPet(id, pInfo)
    if not pInfo then
        petInfo = PokemonInfo.getPetInfoByObjID(id) or {}
    else
        petInfo = pInfo
    end
    local pokeID = petInfo.pokeID or 4
    local info = PokemonInfo.getPokemonInfoByID(pokeID)
    
    -- 计算羁绊参数
    update_yoke()

    local stage = CSResourceMgr.getNodeByName(resName_base,"petStage")
    local textColor    = PokemonInfo.COLOR[info.rarePoint]

    local aniRes = PokemonInfo.getPokemonResByID(pokeID)
    local aniPoint = CSResourceMgr.seekNodeByName(stage,"petAni")
    local aniAni = AnimationMgr.createAni(aniPoint, aniRes, 0, 0, "edu-"..pokeID)
    AnimationMgr.playAni(aniRes,"idle",true,"edu-"..pokeID)
    aniAni:setScale(0.8)    
    local skin = petInfo.skin
    AnimationMgr.setSkin(aniRes, skin, "edu-"..pokeID)

    local petHeight = BattleCANI.petbody.get(pokeID).headUD
    if petHeight > 200 then--200：向上对齐，向下对齐临界点
        local screenHeight = cc.Director:getInstance():getOpenGLView():getViewPortRect().height
        aniPoint:setPositionY(350 - petHeight - 50)--50是头高度
    else
        aniAni:setPositionY(50)
    end

    --types
    local attrIcon1 = info.elementAtt1 ~= 0 and "UI/CommonFiles/"..info.elementAtt1..".png" or "empty.png"
    local attrIcon2 = info.elementAtt2 ~= 0 and "UI/CommonFiles/"..info.elementAtt2..".png" or "empty.png"
    local spirteAttrIcon1 = CSResourceMgr.getNodeByName(resName_base, {"bg","960","petStage","type","att_icon"})
    local spirteAttrIcon2 = CSResourceMgr.getNodeByName(resName_base, {"bg","960","petStage","type2","att_icon"})
    CSResourceMgr.setSpriteTextureByNode(spirteAttrIcon1, attrIcon1)
    CSResourceMgr.setSpriteTextureByNode(spirteAttrIcon2, attrIcon2)
    spirteAttrIcon1:setScale(0.6)
    spirteAttrIcon2:setScale(0.45)
    local spriteType2 = CSResourceMgr.getNodeByName(resName_base, {"bg","960","petStage","type2"})
    spriteType2:setVisible(info.elementAtt2 ~= 0)

    --宠物名字
    local labelName = CSResourceMgr.getNodeByName(resName_base, "p_name_text")
    local name_text = PetEducationMgr.getPetName(petInfo)..(petInfo.Stage ~= 0 and "+"..petInfo.Stage or "")
    CSResourceMgr.setLabelStringByNode(labelName, name_text, outlines[1], nil, 172)
    CSResourceMgr.setLabelColorByNode(labelName, textColor)
    -- CSResourceMgr.seekNodeByName(stage,"p_gender"):loadTexture(genderIcon[1])--性别

    local petLevel = CSResourceMgr.getNodeByName(resName_TopLeft, "p_level", "PetEducationMgr-TopLeft")
    CSResourceMgr.setLabelStringByNode(petLevel, "Lv."..petInfo.level, {r=0,g=0,b=0,a=255,w=1,s=1})

    local labelPower = CSResourceMgr.getNodeByName(resName_base, "power_text")
    local fc = PetEducationMgr.getPetFC(info, petInfo)
    CSResourceMgr.setLabelStringByNode(labelPower, fc, {r=0,g=0,b=0,a=255,w=1,s=2}, 1, 98)
    CSResourceMgr.setLabelColorByNode(labelPower, {r=254,g=243,b=57,a=255,w=1,s=2})

    local spriteAttrBackground = CSResourceMgr.getNodeByName(resName_base, "attrStage")
    local backIcon = (info.rarePoint >= 4) and "Pet/Education/cwxx_liuwei_s.png" or "Pet/Education/cwxx_liuwei.png"
    CSResourceMgr.setSpriteTextureByNode(spriteAttrBackground, backIcon)

    local btnChangeName = CSResourceMgr.getNodeByName(resName_base, "btn_change_name")
    CSResourceMgr.clickEventBindingByNode(btnChangeName, function ()
        PetChangeNameMgr.show(SceneMgr.getRunningScene, id, function ()
            petInfo = PokemonInfo.getPetInfoByObjID(petInfo.objID)--改名之后属性增加刷新数据
            if CSResourceMgr.getCsbObj(tabResName[5]) then
                PetEducationMgr.trainPageInit(false)
            end
        end)
    end)

    showRateAttr()
end

function PetEducationMgr.OnChangeNameSuccess(objID)
    if CSResourceMgr.getCsbObj(resName_base) then
        if petInfo.objID == objID then
            local petInfo = PokemonInfo.getPetInfoByObjID(objID)
            -- local pokeInfo = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
            local labelPetName = CSResourceMgr.getNodeByName(resName_base, "p_name_text")
            local petName = PetEducationMgr.getPetName(petInfo)..(petInfo.Stage ~= 0 and "+"..petInfo.Stage or "")
            CSResourceMgr.setLabelStringByNode(labelPetName, petName, outlines[1], nil, 172)
        end
    end
end

function PetEducationMgr.refreshFCAndSixDimensions(fc, pInfo)
    local labelPower = CSResourceMgr.getNodeByName(resName_base, "power_text")
    CSResourceMgr.setLabelStringByNode(labelPower, fc, {r=0,g=0,b=0,a=255,w=1,s=2}, 1, 98)
    CSResourceMgr.setLabelColorByNode(labelPower, {r=254,g=243,b=57,a=255,w=1,s=2})

    petInfo = pInfo
    showRateAttr()
end

local function hidePet(id)--删除宠物动画用
    petInfo = PokemonInfo.getPetInfoByObjID(id) or {}
    local pokeID = petInfo.pokeID or 4
    local aniRes = PokemonInfo.getPokemonResByID(pokeID)
    AnimationMgr.removeGafObjectByTag(aniRes,"edu-"..pokeID)
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end

--- update 消耗  
local function update_consume(resName, level_need, info, isOverFlow)
    local noRes = false

    local m_bar = CSResourceMgr.getNodeByName(resName,{"Image_2","bottom","cwxx_jinhua2"})
    local bottom_btn = CSResourceMgr.getNodeByName(resName,{"Image_2","bottom","btn_bottom"})
    
    local conInfo = info.stageCons
    local m_num = #conInfo or 4
    local m_sample = CSResourceMgr.seekNodeByName(m_bar,"m_slot")
    local cx, cy = 294, 89  -- m_sample:getPosition()  --center.x & center.y
    local c_index = m_num/2 + 0.5

    for k,v in pairs(m_bar:getChildren()) do
        if v ~= m_sample then m_bar:removeChild(v) end
    end
    
    for i=1, m_num do
        local m_node = m_sample:clone()
        m_node:setVisible(true)

        local ConsumeElementID = conInfo[i]
        local info = ItemInfo.getConsumeElementInfoById(ConsumeElementID)
        
        local icon
        local have
        if info.elementType == 1 then
            icon = "Searching/topBar/jinbi.png"
            have = CharInfo.getGCash()
        elseif info.elementType == 2 then
            icon = "empty.png"
            have = CharInfo.getMCash()
        elseif info.elementType == 3 then
            icon = ItemInfo.getItemInfoById(info.elementID).icon
            have = ItemInfo.getCharItemNum(info.elementID)
        end
        CSResourceMgr.seekNodeByName(m_node,"m_ico"):loadTexture(icon)
--        local sp = CSResourceMgr.seekNodeByName(m_node,"m_ico"
--        CSResourceMgr.setSpriteTextureByNode(sp, icon)
        
        local text = ""
        local con = info.num
        
        have = (have >= con) and con or have
        
        text = have.."/"..con
        if info.elementType == 1 then
            text = con
        end
        
        if ConsumeElementID == 66666 then
            isOverFlow = true
            level_need = 999
            text = "?/?"
        end

        local itemId = 0
        if info.elementType == 1 then
            itemId = 9998
        elseif info.elementType == 2 then
            itemId = 9999
        elseif info.elementType == 3 then
            itemId = info.elementID
        end
        
        local m_num_label = CSResourceMgr.seekNodeByName(m_node,"m_num_have")
        CSResourceMgr.setLabelStringByNode(m_num_label,text,CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        if have < con then
            CSResourceMgr.setLabelColorByNode(m_num_label,{r=255,g=0,b=0,a=255})
            noRes = true
        else
            CSResourceMgr.setLabelColorByNode(m_num_label,{r=255,g=255,b=255,a=255})
        end

        CSResourceMgr.clickEventBindingByNode(m_node,function()
            -- local GetMatsViewMgr = require("src.GameMgr.Pet.GetMatsViewMgr")
            -- GetMatsViewMgr.show(SceneMgr.getRunningScene)
            if itemId ~= 0 then
                ItemInfoViewMgr.show({id = itemId}, false)
            end
        end)

        m_bar:addChild(m_node)
        m_node:setPosition(cx+105*(i-c_index), cy)
    end
    if noRes or petInfo.level < level_need then 
        CSResourceMgr.setButtonEnabledByNode(bottom_btn,false)
    else
        CSResourceMgr.setButtonEnabledByNode(bottom_btn,true)
    end
    m_sample:setVisible(false)

    if isOverFlow then
        -- CSResourceMgr.setLabelString(resName,{"Image_2","bottom","min_level"}, "暂未开放","",{r=0,g=0,b=0,a=255})--to do
    else
        CSResourceMgr.setLabelString(resName,"min_level",
            LuaSqlite.getLanguageByKey("train28").."："..level_need,
            "",{r=0,g=0,b=0,a=255})
    end
    if petInfo.level < level_need then
        CSResourceMgr.setLabelColor(resName,{"Image_2","bottom","min_level"},{r=255,g=0,b=0,a=255})
    else
        CSResourceMgr.setLabelColor(resName,{"Image_2","bottom","min_level"},{r=255,g=255,b=0,a=255})
    end
end

function PetEducationMgr.checkIsFullYoke(petInfo)
    local pokemonInfo  = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
    local info         = PokemonInfo.getPetInfoByObjID(petInfo.objID)
    local yokeTotalNum = 0
    local yokeMineNum  = 0
    local yoke         = pokemonInfo.yokeVec

    for key,var in pairs(yoke) do 
        local yokeInfo = PokemonInfo.getYokeInfoByID(var)
        if yokeInfo.pets then
            for index,pet in pairs(yokeInfo.pets) do
                yokeTotalNum = yokeTotalNum + 1
            end
        end
    end
    if info.yoke and info.yoke.yokeDetail then
        for key,var in pairs(info.yoke.yokeDetail) do
            for k,v in pairs(var) do
                if v ~= 0 then
					local yokeFiveStarInfo = PokemonInfo.getPetInfoByObjID(v)
					if yokeFiveStarInfo.star == 5 then
						yokeMineNum = yokeMineNum+1
					end
                end
            end
        end

    end

    if yokeMineNum >= yokeTotalNum then
        return true 
    else 
        return false
    end
end


function PetEducationMgr.checkYokeHasEquipment(petInfo)
    local pokemonInfo  = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
    local info         = PokemonInfo.getPetInfoByObjID(petInfo.objID)
    local yoke         = pokemonInfo.yokeVec
	local EquipmentNum = 0

    if info.yoke and info.yoke.yokeDetail then
        for key,var in pairs(info.yoke.yokeDetail) do
            for k,v in pairs(var) do
                if v ~= 0 then
					local yokeEquipmentInfo = PokemonInfo.getPetInfoByObjID(v)
					if PetEquipmentMgr.isPetEquiped(yokeEquipmentInfo) then
						EquipmentNum = EquipmentNum + 1
					end
                end
            end
        end

    end

    if EquipmentNum >= 1 then
        return true 
    else 
        return false
    end
end



local function canSwitchTab(tab)

    if tab == 4 then
        local b_infos = PokemonInfo.getPetEvoInfoByID(petInfo.pokeID)
        if not b_infos then
            return false
        end
        --if b_infos.PetEvoLevelInfoVec[selectedEvolutionPetIndex].EvoRateInfoVec[1].newRace >= 20000 and false == PetEducationMgr.checkIsFullYoke(checkIsFullYoke) then
         --   return false
        --end
    end
    if tab == 2 then
        local info = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
        local maxStage = math.floor(info.topLevel / 2)
        local isTopStage = petInfo.Stage >= maxStage
        if isTopStage then return false end
    end
    return true
end

-- show content
local function showTabContent(parent, tab)
    if tabResName[tab] == "" then return end
    if tabObjTable[tab] == nil then
        if canSwitchTab(tab) then
            GameAudio.playUISound("sheetClick")
            PetEducationMgr.hideMax()
            tabObjTable[tab] = CSResourceMgr.createRes(parent, tabResName[tab])
            if tab == 4 then layerEvolutionPartA = tabObjTable[tab] end
            if tabInitFunc[tab] ~= nil then
                tabInitFunc[tab]()
            end
        else
            PetEducationMgr.showMaxWithTab(tab)
        end
    end
end

function PetEducationMgr.showMaxWithTab(tab)
    local str = ""
    if tab == 2 then
        str = "train83"
    elseif tab == 6 then
        str = "train130"

    else
        str = "train84"
        --if tab == 4 then
         --   local b_infos = PokemonInfo.getPetEvoInfoByID(petInfo.pokeID)
         --   if b_infos.PetEvoLevelInfoVec[selectedEvolutionPetIndex].EvoRateInfoVec[1].newRace >= 20000 then
         --       str = "superevo3"
         --   end
        --end
    end
    local layer = CSResourceMgr.createRes(currLayer,"Pet/Education/EducationMax.csb")
    local text = CSResourceMgr.getNodeByName("Pet/Education/EducationMax.csb", "Text")
    CSResourceMgr.setLabelStringByNode(text, str, outlineColor[1])
    CSResourceMgr.setLabelColorByNode(text, {r=166,g=243,b=255,a=255})
end

function PetEducationMgr.hideMax()
    local layer = CSResourceMgr.createRes(currLayer,"Pet/Education/EducationMax.csb")
    layer:setVisible(false)
end

-- hide content
local function hideTabContent(tab)
    if tabResName[tab] == "" then return end
    UnblockLoader.cancel(LoaderTag[tab])
    if tabObjTable[tab] ~= nil then
        local list = CSResourceMgr.getNodeByName(tabResName[tab],"petInfoList")
        if list ~= nil then 
            transition.stopTarget( list )
            list:removeAllItems() 
        end
        CSResourceMgr.removeCSObjectByTag(tabResName[tab])
        CSResourceMgr.removeCSObjectByTag("Pet/Education/common/TopStatusView.csb")
        tabObjTable[tab] = nil
    end
    if evo_polygon_node ~= nil 
    and evo_polygon_node:getParent() ~= nil 
    then
        evo_polygon_node:removeFromParent(true)
        evo_polygon_node = nil
    end
end

local function switchToTab(tab)
    local curr_t = CSResourceMgr.getNodeByName(resName_base,"tab"..currTab)
    local next_t = CSResourceMgr.getNodeByName(resName_base,"tab"..tab)

    local selColor = {r=255,g=250,b=172,a=255}
    local selOutColor = {r=0,g=0,b=0,a=255}
    local unselColor = {r=138,g=107,b=102,a=255}
    local unselOutColor = {r=230,g=230,b=230,a=255}
    local colorGray = {r=82,g=82,b=82,a=255}
    local colorWhite = {r=255,g=255,b=255,a=255}

    curr_t:setScale(1.0,1.0)
    next_t:setScale(1.2,1.2)

    for i = 1, 6 do
        if i < tab then
            CSResourceMgr.getNodeByName(resName_base,"tab"..i):setLocalZOrder(i)
        elseif i > tab then
            CSResourceMgr.getNodeByName(resName_base,"tab"..i):setLocalZOrder(6-i)
        else
            CSResourceMgr.getNodeByName(resName_base,"tab"..tab):setLocalZOrder(7)
        end
    end

    CSResourceMgr.setButtonStringColorByNode(curr_t, colorGray)
    CSResourceMgr.setButtonStringColorByNode(next_t, colorWhite)

    local Label = curr_t:getTitleRenderer()
    Label:enableOutline(unselOutColor, 1)
    Label = next_t:getTitleRenderer()
    Label:enableOutline(selOutColor, 1)

    CSResourceMgr.setButtonEnabledByNode(curr_t,true)
    CSResourceMgr.setButtonEnabledByNode(next_t,false)

    if tab ~= currTab then
        hideTabContent(currTab)
    end
    if tab ~= pageStarup then
        showTabContent(currLayer,tab)
    end
    if currTab == pageStarup then
        PetStarUpMgr.hide()
    elseif currTab == 4 then
        if layerEvolutionPartB ~= nil and CSResourceMgr.getCsbObj(resNameEvoB) then
            layerEvolutionPartB:setVisible(false)
        end
    end
    currTab = tab
end

function PetEducationMgr.show(scene, objid, pageIndex, closeCallback)
    UIStack.push("PetEducationMgr", PetEducationMgr.hide, true)
    PetEducationMgr.closeCallback = closeCallback
    pageIndex = pageIndex or pageStatus
    local function loadCSB()
        local curLayerBG = CSResourceMgr.createRes(scene, resNameBG, "PetEducationMgrMgr")
        curLayerBG:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "PetEducationMgrMgr")
    
        currLayer = CSResourceMgr.createRes(scene, resName_base)
        currLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName_base)
        CSResourceMgr.setRelativePosition(resName_base, 320, 480)
        --CocosModuleMgr.setEdgeDistance(currLayer, nil, nil, 0, nil, false)

        local function setTopLeft()
            local topLeft = CSResourceMgr.createRes(scene, resName_TopLeft, "PetEducationMgr-TopLeft")
            CSResourceMgr.setFullScreen(resName_TopLeft, "PetEducationMgr-TopLeft")
            topLeft:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
            CocosModuleMgr.setEdgeDistance(topLeft, 0, nil, 0, nil, false)
            -- topLeft:setVisible(false)

            local btnMessage = CSResourceMgr.seekNodeByName(topLeft, "mess_btn")
            CSResourceMgr.clickEventBindingByNode(btnMessage, function ()
                MsgBoardView.show(SceneMgr.getRunningScene,1,nil,petInfo)
            end,1)

            local btnBook = CSResourceMgr.getNodeByName(resName_TopLeft, "btn_tujian", "PetEducationMgr-TopLeft")
            local strBook = CSResourceMgr.getNodeByName(resName_TopLeft, "str_tujian", "PetEducationMgr-TopLeft")
            CSResourceMgr.setLabelStringByNode(strBook, "train180", {r=0,g=0,b=0,a=255,w=2}, 1, 72)
            CSResourceMgr.clickEventBindingByNode(btnBook, function ()
                local pokeID = PokemonInfo.getPetInfoByObjID(objid).pokeID
                PetInfoViewMgr.show(SceneMgr.getRunningScene, pokeID)
            end,1)
            
            local btnYoke = CSResourceMgr.getNodeByName(resName_TopLeft, "btn_yoke", "PetEducationMgr-TopLeft")
            local strYoke = CSResourceMgr.getNodeByName(resName_TopLeft, "str_yoke", "PetEducationMgr-TopLeft")
            CSResourceMgr.setLabelStringByNode(strYoke, "train6", {r=0,g=0,b=0,a=255,w=2}, 1, 72)
            CSResourceMgr.clickEventBindingByNode(btnYoke, function ()
                PetEducationMgr.showDelYokeUI(objid, function()
                    btnYoke:hide()
                    strYoke:hide()
                end)
            end, 1)
            
            if PetEducationMgr.isPetYoked(PokemonInfo.getPetInfoByObjID(objid)) then
                btnYoke:show()
                strYoke:show()
            else
                btnYoke:hide()
                strYoke:hide()
            end
        end

        local function setTopRight()
            local topRight = CSResourceMgr.createRes(scene, resName_TopRight, "PetEducationMgr-TopRight")
            CSResourceMgr.setFullScreen(resName_TopRight, "PetEducationMgr-TopRight")
            topRight:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
            CocosModuleMgr.setEdgeDistance(topRight, nil, 0, 0, nil, false)

            local btnClose = CSResourceMgr.seekNodeByName(topRight, "btn_close")
            CSResourceMgr.clickEventBindingByNode(btnClose,function() 
                if currTab == pageStarup then
                    PetStarUpMgr.hide()
                end
                PetEducationMgr.hide()
                -- if closeCallback then
                --     closeCallback()
                -- end
            end)  
        end

        setTopLeft()
        setTopRight()
        
        local objID = objid
        PetEducationMgr.showPet(objID)
        local starter = petInfo
        for _, owned in ipairs(PokemonInfo.getAllPets(true)) do
            if owned.objID < starter.objID then
                starter = owned
            end
        end
        
        local kuang = CSResourceMgr.getNodeByName(resName_base, {"bg","961","kuang"})
        kuang:setLocalZOrder(10)
        for var=1, #tabName do
            CSResourceMgr.clickEventBinding(resName_base, "tab"..var, function()
                if var == pageStarup then
                    PetEducationMgr.hideMax()
                    PetStarUpMgr.show(scene, objID)
                end
                switchToTab(var)
            end)

            local tab = CSResourceMgr.getNodeByName(resName_base, "tab"..var)   
            CSResourceMgr.setButtonString(resName_base,"tab"..var,tabName[var])
            CSResourceMgr.setButtonStringColor(resName_base,"tab"..var,{r=82,g=82,b=82,a=255})
            local Label = tab:getTitleRenderer()
            Label:enableOutline({r=229,g=229,b=229,a=255}, 1)

            if var == 3 then
                local pInfo = starter
                local pokeInfo = PokemonInfo.getPokemonInfoByID(pInfo.pokeID)
                if CharInfo.get().local_freedom ~= true and pInfo.Stage < 5 then
                    tab:setColor({r=70,g=70,b=70,a=255})
                    CSResourceMgr.clickEventBinding(resName_base, "tab"..var, function()
                        local str = CocosModuleMgr.createStringWithFormat({"lwjl1", LuaSqlite.getLanguageByKey(pokeInfo.name)})
                        DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 2, str)
                    end)
                end
            elseif var == 4 then
                local pInfo = starter
                local pokeInfo = PokemonInfo.getPokemonInfoByID(pInfo.pokeID)
                if CharInfo.get().local_freedom ~= true and pInfo.level < 12 then
                    tab:setColor({r=70,g=70,b=70,a=255})
                    CSResourceMgr.clickEventBinding(resName_base, "tab"..var, function()
                        local str = CocosModuleMgr.createStringWithFormat({"lwjl2", LuaSqlite.getLanguageByKey(pokeInfo.name)})
                        DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 2, str)
                    end)
                end
            elseif var == 5 then
                local flag = false
                local needLv = SystemInfo.getGlobalConfigAddInfoByID(24011).values[1]
                if CharInfo.get().local_freedom ~= true and CharInfo.getLevel() < needLv then
                    tab:setColor({r=70,g=70,b=70,a=255})
                    CSResourceMgr.clickEventBinding(resName_base, "tab"..var, function()
                        DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 2, "train98")
                    end)
                end
            elseif var == 6 then
                local flag = false
                local needLv = SystemInfo.getGlobalConfigAddInfoByID(24012).values[1]
                if CharInfo.get().local_freedom ~= true and CharInfo.getLevel() < needLv then
                    tab:setColor({r=70,g=70,b=70,a=255})
                    CSResourceMgr.clickEventBinding(resName_base, "tab"..var, function()
                        DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 2, "train99")
                    end)
                end
            end
        end
        isFirstEnter = true
        switchToTab(pageIndex)

        local setAddPosTable = {
            CSResourceMgr.getNodeByName(resName_base, {"bg", "960"}),
            CSResourceMgr.getNodeByName(resName_base, {"bg", "961"}),
        }
        -- local diff = CocosModuleMgr.getScreenSizeDiff() > 0 and CocosModuleMgr.getScreenSizeDiff() or 0
        local diff = CocosModuleMgr.getScreenSizeDiff() > 0 and CocosModuleMgr.getScreenSizeDiff() or 0
        kuang:setContentSize(kuang:getContentSize().width, kuang:getContentSize().height + diff)
        ViewMgrUtils.vFitSetPos(diff, setAddPosTable)
        ViewMgrUtils.vFitSetPos(-diff, {kuang})

        -- local bg = CSResourceMgr.getNodeByName(resName_base, "bg")
        -- CocosModuleMgr.setEdgeDistance(bg, nil, nil, 0, nil)
        -- CocosModuleMgr.setEdgeDistance(curLayerBG, nil, 0, nil, nil)

        PetEducationMgr.showEducationRedPoint(objID)
    end

    local funcTable = {loadCSB}
    UnblockLoader.load(funcTable, LoaderTag[7])
    -- loadCSB()
end

function PetEducationMgr.hide()
    if layerEvolutionPartB then
        layerEvolutionPartB:setVisible(false)
    end
    if menu then
        menu:setVisible(false)
    end
    for i=1,#tabName do
        tabObjTable[i] = nil
    end
    layerEvolutionPartA = nil
    layerEvolutionPartB = nil
    sortedEvolutionPets = {}
    selectedEvolutionPetIndex = 1
    cur_polygon_node = nil
    evo_polygon_node = nil
    mainPageSkillNode = {}
    menu = nil
    PetEducationMgr.addSkills = {}
    PetEducationMgr.perFC = 0
    for k,v in pairs(LoaderTag) do
        UnblockLoader.cancel("resNameEvoB")
        UnblockLoader.cancel(tabResName[1])
        UnblockLoader.cancel("strengthenPageList")
        UnblockLoader.cancel(v)
    end
    if currTab == 3 then
        PetStarUpMgr.hide()
    end
    currTab = 1
    CSResourceMgr.removeCSObjectByTag(resName_base)
    CSResourceMgr.removeCSObjectByTag(resNameBG, "PetEducationMgrMgr")
    CSResourceMgr.removeCSObjectByTag(resName_TopLeft, "PetEducationMgr-TopLeft")
    CSResourceMgr.removeCSObjectByTag(resName_TopRight, "PetEducationMgr-TopRight")
    -- PetEducationMgr.hideAllRedPoint()
    for i=1,#tabResName do
        CSResourceMgr.removeCSObjectByTag(tabResName[i], LoaderTag[i])
    end
    if PetEducationMgr.closeCallback then
        PetEducationMgr.closeCallback()
    end
    PetEducationMgr.closeCallback = nil
    
    UIStack.pop("PetEducationMgr")
end

function PetEducationMgr.homePageInit()
    --tab 1
    local function loadLayer()
        local layer1 = CSResourceMgr.getNodeByName(tabResName[1], {"Image_2","petInfoList"})
        local layer2 = CSResourceMgr.getNodeByName(tabResName[1], "Image_2")
        local layer3 = CSResourceMgr.getNodeByName(tabResName[1], "bottom")
        layer1:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        layer2:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        layer3:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        layer1:setOpacity(0)
        layer2:setOpacity(0)
        layer3:setOpacity(0)

        local labelFreed = CSResourceMgr.getNodeByName(tabResName[1], "feedlabel")
        CSResourceMgr.setLabelColorByNode(labelFreed, labelColor[10], {r=0,g=0,b=0,a=255,w=1,s=2})
        if PetEducationMgr.getResPetByPokeID(petInfo.pokeID) then
            CSResourceMgr.setLabelStringByNode(labelFreed, "train216", outlines[1])
        else
            CSResourceMgr.setLabelStringByNode(labelFreed, "train50", outlines[1])
        end
        
        local btnFeed = CSResourceMgr.getNodeByName(tabResName[1],"feedBtn")
        CSResourceMgr.setButtonEnabledByNode(btnFeed, PetEducationMgr.getResPetByPokeID(petInfo.pokeID) == false)
        CSResourceMgr.clickEventBindingByNode(btnFeed,function()
            PetEducationMgr.perFC = petInfo.fc
            -- local PetFeedViewMgr = require("src.GameMgr.Pet.PetFeedViewMgr")
            -- PetFeedViewMgr.Init()
            PetFeedViewMgr.show(SceneMgr.getRunningScene, petInfo, function()
                if CSResourceMgr.getCsbObj(resName_base) then
                    petInfo = PokemonInfo.getPetInfoByObjID(petInfo.objID)
                    PetEducationMgr.showPet(petInfo.objID)
                    PetEducationMgr.refreshMainPageExp(petInfo)
                    PetEducationMgr.refreshMainPageAtts(tabResName[1], petInfo)
                    PetEducationMgr.refreshMainPageSkills(petInfo)
                    -- PetListMgr.refresh(PokemonInfo.getPetInfoByObjID(petInfo.objID))
                end

                if PetEducationMgr.perFC < petInfo.fc then
                    PetFCEffectMgr.show(SceneMgr.getRunningScene, PetEducationMgr.perFC, petInfo.fc)
                end

                if petInfo.level >= 12 and GameGuideMgr.checkGuideFinishByID(10018) == false then
                    local tab = CSResourceMgr.getNodeByName(resName_base, "tab4")
                    tab:setColor({r=255,g=255,b=255,a=255})
                    CSResourceMgr.clickEventBindingByNode(tab, function()
                        switchToTab(4)
                    end)
                    GameGuideMgr.firstEvolution()
                end
            end)
        end, 3)

        local stretchTable = {
            CSResourceMgr.getNodeByName(tabResName[1], "background1"),
            CSResourceMgr.getNodeByName(tabResName[1], "background2"),
            CSResourceMgr.getNodeByName(tabResName[1], "background3"),
            CSResourceMgr.getNodeByName(tabResName[1], "petInfoList")
        }
        local diff = CocosModuleMgr.getScreenSizeDiff() > 0 and CocosModuleMgr.getScreenSizeDiff() or 0
        ViewMgrUtils.vFitSetPos(-diff, {layer2, layer3})
        ViewMgrUtils.vFitStretch(diff, stretchTable)
        
        transition.fadeIn(layer1, {time=0.5})
        transition.fadeIn(layer2, {time=0.5})
        transition.fadeIn(layer3, {time=0.5})
    end

    local function loadMainInfo()
        petInfo = PokemonInfo.getPetInfoByObjID(petInfo.objID)
        PetEducationMgr.refreshMainPageExp(petInfo)
        PetEducationMgr.refreshMainPageAtts(tabResName[1], petInfo)
        PetEducationMgr.refreshMainPageSkills(petInfo)
        local setAddPosTable = {
            CSResourceMgr.getNodeByName(tabResName[1], {"Image_2","background_mainAtt"}),
            CSResourceMgr.getNodeByName(tabResName[1], {"Image_2","background_DeputyAtt"})
        }
        local diff = CocosModuleMgr.getScreenSizeDiff() > 0 and CocosModuleMgr.getScreenSizeDiff() or 0
        ViewMgrUtils.vFitSetPos(diff * 2, setAddPosTable)
    end

    local function playCSB()
        if isFirstEnter then
            -- CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(tabResName[1], "content"), "up")
            -- CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(tabResName[1], "Image_2"), "up")
            -- CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(tabResName[1], "bottom"),  "up")
            isFirstEnter = false
        end
    end

    local funcTable = {loadLayer, loadMainInfo, playCSB}
    UnblockLoader.load(funcTable, LoaderTag[1], 0.01)
    -- for i=1,#funcTable do
    --     funcTable[i]()
    -- end
end

function PetEducationMgr.refreshMainPageAtts(resName, petInfo, showAdd, nextPetInfo, listName, contentName)
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    update_yoke()
    PetEducationMgr.setAttriCells(resName, listName, contentName, petInfo, yokeValues, yokeRates, yokePercent, 
        spriteColor, labelColor, outlineColor, showAdd, nextPetInfo)
end

function PetEducationMgr.refreshEvolutionPageAtts(resName, petInfo, pokeID, showAdd, nextPetInfo)
    update_yoke()
    PetEducationMgr.setEvoAttriCells(resName, petInfo, pokeID, yokeValues, yokeRates, yokePercent, 
        spriteColor, labelColor, outlineColor, showAdd, nextPetInfo)
end

function PetEducationMgr.refreshMainPageExp(petInfo)
    local curLevel      = petInfo.level
    local pokemonInfo   = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
    local rarePoint     = pokemonInfo.rarePoint
    local maxLevel      = pokemonInfo.topLevel
    local expNode       = CSResourceMgr.getNodeByName(tabResName[1], {"bottom","expBar"})
    local expBar        = CSResourceMgr.seekNodeByName(expNode, "exp_icon")
    local expName       = CSResourceMgr.seekNodeByName(expNode, "exp_name")
    local expText       = CSResourceMgr.seekNodeByName(expNode, "exp_text")
    local expLvLeft     = CSResourceMgr.seekNodeByName(expNode, "exp_lv_left")
    local expLvRight    = CSResourceMgr.seekNodeByName(expNode, "exp_lv_right")

    CSResourceMgr.setLabelStringByNode(expName, "train19", {r=0,g=0,b=0,a=255,w=1,s=2})
    CSResourceMgr.setLabelColorByNode(expName, labelColor[5])
    CSResourceMgr.setLabelStringByNode(expLvLeft, "Lv."..curLevel)
    CSResourceMgr.setLabelColorByNode(expLvLeft, (curLevel < maxLevel) and labelColor[1] or labelColor[5], {r=0,g=0,b=0,a=255,w=1,s=2})
    CSResourceMgr.setLabelStringByNode(expLvRight, "/"..maxLevel, {r=0,g=0,b=0,a=255,w=1,s=2})
    CSResourceMgr.setLabelColorByNode(expLvRight, labelColor[5])
    expLvRight:setPositionX(expLvLeft:getPositionX() + expLvLeft:getBoundingBox().width)
    expLvRight:enableOutline(outlines[1], PetEducationMgr.LABLE_OUTLINE_THICK)
    
    local curLvExpNeed  = (curLevel == 1) and 0 or ExperienceInfo.getExperienceInfoByID(curLevel-1).petExpVec[rarePoint]
    local nextLvExpNeed = ExperienceInfo.getExperienceInfoByID(curLevel).petExpVec[rarePoint]
    local percent       = (petInfo.exp - curLvExpNeed) * 100 / (nextLvExpNeed - curLvExpNeed)
    if percent < 0 then percent = 0 end
    percent = string.format("%.1f",percent)
    expBar:setPercent(percent)
    local curExp = (petInfo.exp - curLvExpNeed).."/"..(nextLvExpNeed - curLvExpNeed)
    CSResourceMgr.setLabelStringByNode(expText, curExp, {r=0,g=0,b=0,a=255,w=1,s=2})

    local lableMainAttName = CSResourceMgr.getNodeByName(tabResName[1], {"Image_2","background_mainAtt","currLevel"})
    local labelDeputyAttName = CSResourceMgr.getNodeByName(tabResName[1], {"Image_2","background_DeputyAtt","nextLevel"})
    CSResourceMgr.setLabelStringByNode(lableMainAttName, "train36", nil, 1, 96)--主属性
    CSResourceMgr.setLabelStringByNode(labelDeputyAttName, "train37", nil, 1, 96)--副属性
    CSResourceMgr.setLabelColorByNode(lableMainAttName, labelColor[5])
    CSResourceMgr.setLabelColorByNode(labelDeputyAttName, labelColor[4])
end

function PetEducationMgr.refreshMainPageSingleSkill(objID, newSkillID, skillIndex)
    local i = skillIndex + 1
    local skillNode  = CSResourceMgr.getNodeByName(tabResName[1], {"bottom","skill_"..i})
    local skillName = CSResourceMgr.getNodeByName(tabResName[1], {"bottom","skill_name"..i})
    local skillInfo = PokemonInfo.getPetSkillInfoById(newSkillID)
    if skillInfo.skill_A_Type == Proto.eST_Passive or skillInfo.skill_A_Type == Proto.eST_Assist then
        return
    end
    CSResourceMgr.setLabelStringByNode(skillName, skillInfo.name, {r=0,g=0,b=0,a=255,w=1,s=2})
    CSResourceMgr.setLabelColorByNode(skillName, i ~= 4 and PokemonInfo.COLOR[skillInfo.airpower] or {r=255,g=240,b=0,a=255,w=1,s=1})
    local node = PetSkillIconMgr.createPetSkillIcon(skillNode, skillInfo, 2)
    node:setPositionX(6)
    CSResourceMgr.clickEventBindingByNode(node, function ()
        PetSkillViewMgr.showSkillInfoPage(skillInfo, i, 1, objID, closeCallback)
    end, 3)
    mainPageSkillNode[i] = node
    if i == 4 then
        -- local maxSkillEnergy = CSResourceMgr.getNodeByName(tabResName[1], {"bottom","max_skill_energy"})
        local maxSkillEnergy = CSResourceMgr.getNodeByName(tabResName[1], {"bottom","background12"})
        CSResourceMgr.setSpriteTextureByNode(maxSkillEnergy, PetEducationMgr.maxSkillEnergyPath[skillInfo.energy])
        if skillInfo.energy > 0 then
            maxSkillEnergy:setVisible(true)
            maxSkillEnergy:setScale(1.43)
        end
        local spriteTypeBG = CSResourceMgr.getNodeByName(tabResName[1], {"bottom","skill_type_bg"})
        local spriteType = CSResourceMgr.seekNodeByName(spriteTypeBG, "skill_type")
        spriteTypeBG:setVisible(true)
        local typeIcon = PokemonInfo.getSkillPlayById(skillInfo.id).typeIcon
        CSResourceMgr.setSpriteTextureByNode(spriteType, typeIcon)
        local spriteLv = CSResourceMgr.getNodeByName(tabResName[1], {"bottom","max_skill_lv"})
        local skillLevel = (skillInfo.id % 5 == 0) and 5 or skillInfo.id % 5
        CSResourceMgr.setSpriteTextureByNode(spriteLv, PetSkillIconMgr.skillLvIconTable[skillLevel])
    end
    local nodeList = {}
    for i = 1, 4 do
        nodeList[i] = CSResourceMgr.getNodeByName(tabResName[1], {"bottom","skill_"..i})
    end
    petInfo.skills[i] = newSkillID
    PetEducationMgr.showSkillRedPoint(nodeList, petInfo, 1)
end

function PetEducationMgr.refreshMainPageSkills(petInfo)
    local function setNodesVisible(nodeTable, show)
        for k,v in pairs(nodeTable) do
            v:setVisible(show)
        end
    end
    for i=1,#petInfo.skills do
        local skillNode  = CSResourceMgr.getNodeByName(tabResName[1], {"bottom","skill_"..i})
        local skillName = CSResourceMgr.getNodeByName(tabResName[1], {"bottom","skill_name"..i})
        if petInfo.skills[i] ~= 0 then
            local skillInfo = PokemonInfo.getPetSkillInfoById(petInfo.skills[i])
            CSResourceMgr.setLabelStringByNode(skillName, skillInfo.name, {r=0,g=0,b=0,a=255,w=1,s=2}, nil, 130)
            -- CSResourceMgr.setLabelColorByNode(skillName, i ~= 4 and PokemonInfo.COLOR[skillInfo.airpower] or {r=255,g=240,b=0,a=255,w=1,s=1})
            CSResourceMgr.setLabelColorByNode(skillName, PokemonInfo.COLOR[skillInfo.airpower])
            local node = PetSkillIconMgr.createPetSkillIcon(skillNode, skillInfo, 2)
            node:setPositionX(i == 4 and 6 or 4)
            --if PetEducationMgr.getResPetByPokeID(petInfo.pokeID) == false then
                CSResourceMgr.clickEventBindingByNode(node, function ()
                    PetSkillViewMgr.showSkillInfoPage(skillInfo, i, 1, petInfo.objID)
                end, 3)
            --end
            if i == 4 then
                -- print(skillInfo.energy)
                -- local maxSkillEnergy = CSResourceMgr.getNodeByName(tabResName[1], {"bottom","max_skill_energy"})
                local maxSkillEnergy = CSResourceMgr.getNodeByName(tabResName[1], {"bottom","background12"})
                CSResourceMgr.setSpriteTextureByNode(maxSkillEnergy, PetEducationMgr.maxSkillEnergyPath[skillInfo.energy])
                if skillInfo.energy > 0 then
                    maxSkillEnergy:setVisible(true)
                    maxSkillEnergy:setScale(1.43)
                end
                local spriteTypeBG = CSResourceMgr.getNodeByName(tabResName[1], {"bottom","skill_type_bg"})
                local spriteType = CSResourceMgr.seekNodeByName(spriteTypeBG, "skill_type")
                spriteTypeBG:setVisible(true)
                local typeIcon = PokemonInfo.getSkillPlayById(skillInfo.id).typeIcon
                CSResourceMgr.setSpriteTextureByNode(spriteType, typeIcon)
                local spriteLv = CSResourceMgr.getNodeByName(tabResName[1], {"bottom","max_skill_lv"})
                local skillLevel = (skillInfo.id % 5 == 0) and 5 or skillInfo.id % 5
                CSResourceMgr.setSpriteTextureByNode(spriteLv, PetSkillIconMgr.skillLvIconTable[skillLevel])
            end
            mainPageSkillNode[i] = node
        else
            CSResourceMgr.setLabelStringByNode(skillName, "train96", {r=0,g=0,b=0,a=255,w=1,s=2}, nil, 130)
            CSResourceMgr.setLabelColorByNode(skillName, {r=102,g=102,b=102,a=255})
            local skillInfo = {}
            local node = PetSkillIconMgr.createPetSkillIconEmpty(skillNode)
            node:setPositionX(6)
            if PetEducationMgr.getResPetByPokeID(petInfo.pokeID) == false then
                CSResourceMgr.clickEventBindingByNode(node, function ()
                    PetSkillViewMgr.showSkillExchangePage(skillInfo, i, 1, petInfo.objID)
                end, 3)
            end
            mainPageSkillNode[i] = node
        end
    end

    local nodeList = {}
    for i = 1, 4 do
        nodeList[i] = CSResourceMgr.getNodeByName(tabResName[1], {"bottom","skill_"..i})
    end
    if PetEducationMgr.getResPetByPokeID(petInfo.pokeID) == false then
        PetEducationMgr.showSkillRedPoint(nodeList, petInfo, 1)
    end
end

function PetEducationMgr.getMainPageSkillNodeByIndex(index)
    return mainPageSkillNode[index]
end

--needMove自适应偏移
function PetEducationMgr.trainPageInit(needMove)
    --tab 5
    local resName = tabResName[5]

    local calc_func = {
        BattleBasicValueCalc.calcHp    ,
        BattleBasicValueCalc.calcAct   ,
        BattleBasicValueCalc.calcDef   ,
        BattleBasicValueCalc.calcSpeAct,
        BattleBasicValueCalc.calcSpeDef,
        BattleBasicValueCalc.calcSpeed ,
    }
    
    local attrIconTable = {
        "UI/CommonFiles/develop_icon_hp_01.png",
        "UI/CommonFiles/develop_icon_atk_01.png",
        "UI/CommonFiles/develop_icon_def_01.png",
        "UI/CommonFiles/develop_icon_mag_01.png",
        "UI/CommonFiles/develop_icon_res_01.png",
        "UI/CommonFiles/develop_icon_sep_01.png",
    }

    local attrNameTable = {"train11","train12","train13","train14","train15","train16"}

    -- needMove = needMove or nil
    if needMove == nil then
        local panel = CSResourceMgr.getNodeByName(tabResName[5], "panel")
        local expBar = CSResourceMgr.getNodeByName(tabResName[5], "total_bar")
        local btnReset = CSResourceMgr.getNodeByName(tabResName[5], "reset_btn")
        local background3 = CSResourceMgr.seekNodeByName(panel, "background3")
        local gold = CSResourceMgr.getNodeByName(tabResName[5], "gold")
        local costTitle = CSResourceMgr.getNodeByName(tabResName[5], "cost_title")
        local costIcon = CSResourceMgr.getNodeByName(tabResName[5], "cost_icon")
        local costNum = CSResourceMgr.getNodeByName(tabResName[5], "cost_num")
        local background4 = CSResourceMgr.getNodeByName(tabResName[5], "background4")
        local list = CSResourceMgr.seekNodeByName(panel, "list")
        local diff = CocosModuleMgr.getScreenSizeDiff() > 0 and CocosModuleMgr.getScreenSizeDiff() or 0
        panel.btnLimt = btnReset:clone()
        panel.btnLimtIcon = CSResourceMgr.seekNodeByName(panel.btnLimt, "icon")
        panel.btnLimtStr  = CSResourceMgr.seekNodeByName(panel.btnLimt, "str_reset")
        panel.btnLimtIcon:removeFromParent() 
        panel.btnLimtStr:setPosition(85,45)
		CSResourceMgr.setLabelStringByNode( panel.btnLimtStr,"train217",{r=0,g=0,b=0,a=255}, 1 ,500)
--       panel.btnLimtStr:setString(LuaSqlite.getLanguageByKey("train217")) 
        panel.btnLimtStr:setAnchorPoint(0.5,0.5)
        panel.btnLimtStr:enableOutline({r=0,g=0,b=0,a=255}, 1)
        panel.btnLimt:addTo(panel)
        panel.btnLimt:setPosition(516,140) 
        panel.btnLimt:setAnchorPoint(0.5,0.5)
        panel.btnLimt:zorder(10)
        btnReset:setScale(0.8,0.8)
        panel.btnLimt:setScale(0.8,0.8)
        btnReset:setPositionY(btnReset:getPositionY()-25) 
        ViewMgrUtils.vFitSetPos(diff, {panel})
        ViewMgrUtils.vFitSetPos(-diff*2, {expBar,btnReset,background3,gold,costTitle,costIcon,costNum,background4,panel.btnLimt})
        ViewMgrUtils.vFitStretch(diff, {list})
    end

    local function loadUI()
        PetEducationMgr.perFC = petInfo.fc
        PetEducationMgr.refreshTrainGold(petInfo)
        PetEducationMgr.refreshTrainTopBar(attrIconTable, attrNameTable, petInfo)
        PetEducationMgr.refreshTrainItems(attrIconTable, attrNameTable, petInfo)
    end

    local funcTable = {loadUI}
    UnblockLoader.load(funcTable, LoaderTag[5], 0.05)
end

function PetEducationMgr.refreshTrainGold(petInfo)
    if not petInfo["oall"] then
        petInfo["oall"] = 0
    end
    local labelGold         = CSResourceMgr.getNodeByName(tabResName[5], "label_gold")
    local labelCostTitle    = CSResourceMgr.getNodeByName(tabResName[5], "cost_title")
    local spriteIcon        = CSResourceMgr.getNodeByName(tabResName[5], "cost_icon")
    local labelCostNum      = CSResourceMgr.getNodeByName(tabResName[5], "cost_num")
    local btnResAdd         = CSResourceMgr.getNodeByName(tabResName[5], "btn_gold")
    local tattolLimPoints   = SystemInfo.getGlobalConfigAddInfoByID(70002).values[1]
    local curPoints = petInfo.hpx + petInfo.atk + petInfo.def + petInfo.satk + petInfo.sdef + petInfo.speed
    local maxPoints = petInfo.maxStreng + petInfo["oall"]*tattolLimPoints

    labelCostTitle:setVisible(curPoints < maxPoints)
    spriteIcon:setVisible(curPoints < maxPoints)
    labelCostNum:setVisible(curPoints < maxPoints)

    CSResourceMgr.setLabelStringByNode(labelGold, CharInfo.getGCash(), {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 140)
    if curPoints < maxPoints then
        local resCost = PokemonInfo.getPetStrengthenInfo(curPoints+ 1).gcash
        CSResourceMgr.setLabelStringByNode(labelCostTitle, "train160", {r=0,g=0,b=0,a=255,w=1,s=1})
        CSResourceMgr.setLabelStringByNode(labelCostNum, resCost, {r=0,g=0,b=0,a=255,w=1,s=1})
        CSResourceMgr.setLabelColorByNode(labelCostTitle, {r=166,g=243,b=255,a=255})
    end

    CSResourceMgr.clickEventBindingByNode(btnResAdd, function ()
        ExchangeViewMgr.show(SceneMgr.getRunningScene, ExchangeViewMgr.GCASHTYPE)
    end)
end

function PetEducationMgr.refreshTrainTopBar(attrIconTable, attrNameTable, petInfo)
    if not petInfo["oall"] then
        petInfo["oall"] = 0
    end
    local panel = CSResourceMgr.getNodeByName(tabResName[5], "panel")
    local totalBar = CSResourceMgr.seekNodeByName(panel, "total_bar")
    local bar = CSResourceMgr.seekNodeByName(totalBar, "bar")
    local title = CSResourceMgr.seekNodeByName(totalBar, "title")
    local left = CSResourceMgr.seekNodeByName(totalBar, "left")
    local right = CSResourceMgr.seekNodeByName(totalBar, "right")
    local btnReset = CSResourceMgr.seekNodeByName(panel, "reset_btn")
    local strReset = CSResourceMgr.seekNodeByName(btnReset, "str_reset")
    local bg = CSResourceMgr.seekNodeByName(totalBar, "background")

    local curPoints = petInfo.hpx + petInfo.atk + petInfo.def + petInfo.satk + petInfo.sdef + petInfo.speed
    local PointsLimValue = SystemInfo.getGlobalConfigAddInfoByID(70002).values[1]
    local maxPoints = petInfo.maxStreng + petInfo["oall"]*PointsLimValue

    bar:setPercent((maxPoints - curPoints) / maxPoints * 100)

    -- panel.btnLimt:setPosition(516,140) 
    -- panel.btnLimt:setScale(0.8,0.8)
    CSResourceMgr.setLabelStringByNode(title, "train85", {r=0,g=0,b=0,a=255,w=1,s=1})
    CSResourceMgr.setLabelStringByNode(left, (maxPoints-curPoints), {r=0,g=0,b=0,a=255,w=1,s=1})
    CSResourceMgr.setLabelStringByNode(right, "/"..maxPoints, {r=0,g=0,b=0,a=255,w=1,s=1})
    CSResourceMgr.setLabelStringByNode(strReset, "train22", {r=0,g=0,b=0,a=255,w=1,s=2})

    CSResourceMgr.setLabelColorByNode(title, labelColor[1])
    CSResourceMgr.setLabelColorByNode(right, labelColor[5])
    CSResourceMgr.setLabelColorByNode(strReset, labelColor[1])

    if PetEducationMgr.getPetIsModify(petInfo) == true then
        CSResourceMgr.setLabelColorByNode(right, labelColor[22])
    end

    left:setPositionX(right:getPositionX() - right:getBoundingBox().width)

    if petInfo["oall"] >= #PetTrainPointsInfo.getTattolPointsExtraTable() then
        CSResourceMgr.setButtonEnabledByNode(panel.btnLimt,false)
        BattleFuncMgr.setNodeGray(panel.btnLimt,false) 
    end
    --add by lyx 
    local function calcReturnGCash()
        local points = curPoints
        local rescost = 0
        while(points>0) 
        do
            rescost = rescost+PokemonInfo.getPetStrengthenInfo(points).gcash
            points = points -1
        end

        return math.floor(rescost*0.6)
    end 
    CSResourceMgr.clickEventBindingByNode(panel.btnLimt,function()
            local level = petInfo["oall"] + 1
            local itemNum , itemID = PetTrainPointsInfo.getTattolPointsExtraValue(level)
            local ownItemNum =  ItemInfo.getCharItemNum(itemID)
            local str = LuaSqlite.getLanguageByKey("train219") 
            local restTimes = #PetTrainPointsInfo.getTattolPointsExtraTable() - petInfo["oall"]
            str = string.gsub(str,"<1>",PointsLimValue) 
            str = string.gsub(str,"<2>",restTimes)
            petTrainLimitMaterialView.show(str,{itemID},{itemNum},{ownItemNum},function() 
                    NetInterface.sendWithBlock("GC_PetStrengOverflow_Ack", function()
                        local PetEducationSend = require("src.Net.Send.PetEducationSend")
                        PetEducationSend.sendCG_PetStrengOverflow_Req({petObjID = petInfo.objID,
                            oName = "oall"}) 
                    end, function()
                        petInfo["oall"] = level
                        local curP = petInfo.hpx + petInfo.atk + petInfo.def + petInfo.satk + petInfo.sdef + petInfo.speed
                        local maxP = petInfo.maxStreng + level*PointsLimValue
                        CSResourceMgr.setLabelStringByNode(left, (maxP-curP), {r=0,g=0,b=0,a=255,w=1,s=1})
                        CSResourceMgr.setLabelStringByNode(right, "/"..maxP, {r=0,g=0,b=0,a=255,w=1,s=1})
                        left:setPositionX(right:getPositionX() - right:getBoundingBox().width)
                        bar:setPercent((maxP - curP) / maxP * 100)
                        petTrainLimitMaterialView:hide()
                        if petInfo["oall"] >= #PetTrainPointsInfo.getTattolPointsExtraTable() then
                            CSResourceMgr.setButtonEnabledByNode(panel.btnLimt,false)
                            BattleFuncMgr.setNodeGray(panel.btnLimt,false) 
                        end
                    end, function(code) 
                        
                    end) 
                    
                end) 
            -- DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,2,"train219",function()
            -- end,function() end,nil,false)
        end)
    ----------------------------------------------------------------------------------
    CSResourceMgr.setButtonEnabledByNode(btnReset, curPoints > 0)
    CSResourceMgr.clickEventBindingByNode(btnReset, function ()
        local value = SystemInfo.getGlobalConfigAddInfoByID(8).values[1]
        local str = CocosModuleMgr.createStringWithFormat({"train171", value,calcReturnGCash()})
        DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 2, str, function()
            if CharInfo.getMCash() < value then
                StandardTipsMgr.show(1, "tips14")--钻石不足
            else
                NetInterface.sendWithBlock("GC_RESETPETSTRENG_ACK", function()
                    local PetEducationSend = require("src/Net/Send/PetEducationSend.lua")
                    PetEducationSend.sendCG_ResetPetStreng_Req({
                        petObjID = petInfo.objID,
                    })
                end, function()
                    local addPoints = {
                        hpx   = 0,
                        atk   = 0,
                        def   = 0,
                        satk  = 0,
                        sdef  = 0,
                        speed = 0,
                    }
                    for i = 1, #a_idx do
                        petInfo[a_idx[i]] = addPoints[a_idx[i]]
                        -- PetEducationMgr.refreshSingleTrainItem(i, attrIconTable, attrNameTable, tempInfo)
                    end
                    PetEducationMgr.showPet(petInfo.objID, petInfo)
                    PetEducationMgr.refreshTrainGold(petInfo)
                    PetEducationMgr.refreshTrainTopBar(attrIconTable, attrNameTable, petInfo)
                    PetEducationMgr.refreshTrainItems(attrIconTable, attrNameTable, petInfo)
                    PetEffectMgr.showTrainEffectC(bg)
                    local pokeInfo = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
                    PetEducationMgr.perFC = PetEducationMgr.getPetFC(pokeInfo, petInfo)

                    TaskWatcherManager.saveChongwuXunLianState("cwxunlianchongzhi")
                end)
            end
        end)
    end)
end

function PetEducationMgr.refreshSingleTrainItem(index, attrIconTable, attrNameTable, petInfo) 
    if not petInfo["oall"] then
        petInfo["oall"] = 0
    end
    local tattolLimPoints   = SystemInfo.getGlobalConfigAddInfoByID(70002).values[1]
    local attrIcon      = attrIconTable[index]
    local attrName      = attrNameTable[index]
    local attrLeft      = petInfo[a_idx[index]]
    local attrRight     = ExperienceInfo.getExperienceInfoByID(petInfo.level).petSingleAttrStrengthenMax

    local isMax         = attrRight == petInfo[a_idx[index]]
    local curPoints     = petInfo.hpx + petInfo.atk + petInfo.def + petInfo.satk + petInfo.sdef + petInfo.speed
    local maxPoints     = petInfo.maxStreng+petInfo["oall"]*tattolLimPoints
    local hasPoint      = curPoints < maxPoints
    local node          = trainItemNode[index]
    local bg2           = CSResourceMgr.seekNodeByName(node, "c_background2")
    local bg3           = CSResourceMgr.seekNodeByName(node, "c_background3")
    local vAttrIcon     = CSResourceMgr.seekNodeByName(node, "c_icon1")
    local vAttrName     = CSResourceMgr.seekNodeByName(node, "c_name")
    local vAttrBar      = CSResourceMgr.seekNodeByName(node, "c_bar")
    local vBtnAttrAdd   = CSResourceMgr.seekNodeByName(node, "c_btn_add")
    local vBtnAttrAddT  = CSResourceMgr.seekNodeByName(node, "c_btn_add_icon")
    local vResLeft      = CSResourceMgr.seekNodeByName(node, "c_res_left")
    local vResRight     = CSResourceMgr.seekNodeByName(node, "c_res_right")
    local labelMax      = CSResourceMgr.seekNodeByName(node, "c_max")
    
    local trainUsedTimes = petInfo[b_idx[index]]
    local limitPoints       = SystemInfo.getGlobalConfigAddInfoByID(70003).values[1]
    

    if not petInfo[b_idx[index]] then
        petInfo[b_idx[index]] = 0
    end
    attrRight = attrRight + petInfo[b_idx[index]]*limitPoints
    if attrLeft == attrRight then
        labelMax:setVisible(true)
        CSResourceMgr.setLabelStringByNode(labelMax, "MAX!", {r=0,g=0,b=0,a=255,w=1,s=1})
        CSResourceMgr.setLabelColorByNode(labelMax,  {r=255,g=144,b=0,a=255})
    else
        labelMax:setVisible(false)
    end
    CSResourceMgr.setSpriteTextureByNode(vAttrIcon, attrIcon)

    CSResourceMgr.setLabelStringByNode(vAttrName, attrName, {r=0,g=0,b=0,a=255,w=1}, nil, 80)
    CSResourceMgr.setLabelStringByNode(vResLeft, attrLeft, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 56)
    CSResourceMgr.setLabelStringByNode(vResRight, "/"..attrRight, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 56)

    CSResourceMgr.setLabelColorByNode(vAttrName,  {r=151,g=190,b=220,a=255})
    CSResourceMgr.setLabelColorByNode(vResLeft,   (attrLeft == attrRight) and labelColor[5] or labelColor[1])
    CSResourceMgr.setLabelColorByNode(vResRight,  labelColor[5])
    vAttrBar:setPercent(attrLeft / attrRight * 100)
    vResLeft:setPositionX(vResRight:getPositionX() - 2)

    if attrLeft == attrRight then
        -- CSResourceMgr.setButtonTextureByNode(vBtnAttrAdd, trainBtnTex[2], trainBtnTex[2], trainBtnTex[2])
        -- CSResourceMgr.setButtonTextureByNode(vBtnAttrAdd, trainBtnTex[4], trainBtnTex[5], trainBtnTex[5])
        -- CSResourceMgr.setSpriteTextureByNode(vBtnAttrAddT, trainBtnIconTex[2]) 
        -- CSResourceMgr.setSpriteTextureByNode(vBtnAttrAddT, trainBtnIconTex[4]) 
        -- CSResourceMgr.setButtonEnabledByNode(vBtnAttrAdd, false)
    -- elseif hasPoint == false then--resRight > resLeft or hasPoint == false then
    --     CSResourceMgr.setSpriteTextureByNode(vBtnAttrAddT, trainBtnIconTex[3]) 
    --     CSResourceMgr.setButtonEnabledByNode(vBtnAttrAdd, false)
        if petInfo[b_idx[index]] >= #PetTrainPointsInfo.getAttPointsExtraTable(index) then
            CSResourceMgr.setSpriteTextureByNode(vBtnAttrAddT, trainBtnIconTex[3])
            CSResourceMgr.setButtonEnabledByNode(vBtnAttrAdd, false)
        else
            CSResourceMgr.setSpriteTextureByNode(vBtnAttrAddT, trainBtnIconTex[4])
            CSResourceMgr.setButtonTextureByNode(vBtnAttrAdd, trainBtnTex[4], trainBtnTex[5], trainBtnTex[5])
        end

    else
        CSResourceMgr.setButtonTextureByNode(vBtnAttrAdd, trainBtnTex[1], trainBtnTex[2], trainBtnTex[3])
        CSResourceMgr.setSpriteTextureByNode(vBtnAttrAddT, trainBtnIconTex[1])
        CSResourceMgr.setButtonEnabledByNode(vBtnAttrAdd, true)
    end
    CSResourceMgr.clickEventBindingByNode(vBtnAttrAdd, function ()
        local resCost = PokemonInfo.getPetStrengthenInfo(curPoints+ 1).gcash
        local restTimes   = #PetTrainPointsInfo.getAttPointsExtraTable(index) - petInfo[b_idx[index]] 
        attrLeft  = petInfo[a_idx[index]]
        attrRight     = ExperienceInfo.getExperienceInfoByID(petInfo.level).petSingleAttrStrengthenMax + petInfo[b_idx[index]]*limitPoints
        if attrLeft == attrRight then
            local level = petInfo[b_idx[index]] + 1
            local str = LuaSqlite.getLanguageByKey("train218") 
            local itemNum , itemID = PetTrainPointsInfo.getAttPointsExtraValue(index,level)
            local ownItemNum =  ItemInfo.getCharItemNum(itemID)
            str = string.gsub(str,"<1>",limitPoints) 
            str = string.gsub(str,"<2>",restTimes)
            petTrainLimitMaterialView.show(str,{itemID},{itemNum},{ownItemNum},function() 
                    NetInterface.sendWithBlock("GC_PetStrengOverflow_Ack", function()
                        local PetEducationSend = require("src.Net.Send.PetEducationSend")
                        PetEducationSend.sendCG_PetStrengOverflow_Req({petObjID = petInfo.objID,
                            oName = b_idx[index]}) 
                    end, function()
                        petInfo[b_idx[index]] = level
                        PetEducationMgr.refreshSingleTrainItem(index, attrIconTable, attrNameTable, petInfo)
                        petTrainLimitMaterialView.hide()
                    end, function(code) 
                        
                    end) 
                    
                end)
            -- DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 2, str,function() 
                    
            --     end) 

            return 
        end
        local curP     = petInfo.hpx + petInfo.atk + petInfo.def + petInfo.satk + petInfo.sdef + petInfo.speed
        local maxP     = petInfo.maxStreng+petInfo["oall"]*tattolLimPoints
        hasPoint = curP < maxP
        if hasPoint == false then
            DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 2, "train170")
        elseif hasPoint and CharInfo.getGCash() < resCost then
            StandardTipsMgr.show(1, "train172")
        else
            local function refreshTrainPointsAfterTrain()
                petInfo[a_idx[index]] = petInfo[a_idx[index]] + PetEducationMgr.trainTimes
                PetEducationMgr.showPet(petInfo.objID)
                PetEducationMgr.refreshTrainGold(petInfo)
                PetEducationMgr.refreshTrainTopBar(attrIconTable, attrNameTable, petInfo)

                curPoints = petInfo.hpx + petInfo.atk + petInfo.def + petInfo.satk + petInfo.sdef + petInfo.speed
                local maxPoints = petInfo.maxStreng+petInfo["oall"]*tattolLimPoints
                local hasPoint = curPoints < maxPoints
                -- if hasPoint == true then
                --     PetEducationMgr.refreshSingleTrainItem(index, attrIconTable, attrNameTable, petInfo)
                -- else
                --     for i=1,#attrIconTable do
                --         PetEducationMgr.refreshSingleTrainItem(i, attrIconTable, attrNameTable, petInfo)
                --     end
                -- end
                for i=1,#attrIconTable do
                    PetEducationMgr.refreshSingleTrainItem(i, attrIconTable, attrNameTable, petInfo)
                end

                PetEffectMgr.showTrainEffectA(bg2, vAttrIcon)
                if petInfo[a_idx[index]] == ExperienceInfo.getExperienceInfoByID(petInfo.level).petSingleAttrStrengthenMax then
                    PetEffectMgr.showTrainEffectB(bg3)
                end

                local pokemonInfo = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
                local fc = PetEducationMgr.getPetFC(pokemonInfo, petInfo)
                if PetEducationMgr.perFC < fc then
                    PetFCEffectMgr.show(SceneMgr.getRunningScene, PetEducationMgr.perFC, fc)
                    PetEducationMgr.perFC = fc
                    PetEducationMgr.refreshFCAndSixDimensions(fc, petInfo)
                end

                local params = {}
                params.objID = petInfo.objID
                params.points = curPoints
                TaskWatcherManager.saveCWXunLianState(params)
            end

            PetQuickTrainViewMgr.show(SceneMgr.getRunningScene, petInfo.objID, curP, maxP, attrLeft,
            attrRight, index, function ()
                refreshTrainPointsAfterTrain()
            end)
        end
    end)
end

function PetEducationMgr.setTrainTimes(trainTimes)
    PetEducationMgr.trainTimes = trainTimes
end

function PetEducationMgr.refreshTrainItems(attrIconTable, attrNameTable, petInfo)
    local panel     = CSResourceMgr.getNodeByName(tabResName[5], "panel")
    local list      = CSResourceMgr.seekNodeByName(panel, "list")
    local parent    = CSResourceMgr.getNodeByName(tabResName[5], "child")
    local item      = CSResourceMgr.seekNodeByName(parent, "c_1")
    local diffX = 306
    local panelRow = 2
    local panelNodes = {}
    for k,v in pairs(list:getChildren()) do
        if v ~= item then list:removeChild(v) end
    end
    for i = 1, 3 do
        panelNodes[i] = parent:clone()
        panelNodes[i]:addTo(list)
        panelNodes[i]:setVisible(true)
        local b4 = CSResourceMgr.seekNodeByName(panelNodes[i], "c_background4")
        if i == 3 then
            b4:setVisible(false)
        else
            b4:setColor({r=50,g=96,b=131,a=255})
        end
    end
    local index = 1
    for i = 1, 6 do
        local line = math.ceil(index / panelRow)
        local row = (index % panelRow == 0) and panelRow or index % panelRow

        trainItemNode[i] = item:clone()
        trainItemNode[i]:setVisible(true)
        trainItemNode[i]:setPositionX(trainItemNode[i]:getPositionX() + (row - 1) * diffX)
        trainItemNode[i]:addTo(panelNodes[line])

        PetEducationMgr.refreshSingleTrainItem(i, attrIconTable, attrNameTable, petInfo)

        index = index + 1
    end
end

function PetEducationMgr.evolutionPageInit()
    --tab 4
    local function loadLayerA()
        local panel1 = CSResourceMgr.getNodeByName(tabResName[4], "panel_1")
        local panel2 = CSResourceMgr.getNodeByName(tabResName[4], "panel_2")
        local bottom = CSResourceMgr.getNodeByName(tabResName[4], "bottom")
        panel1:setOpacity(0)
        panel2:setOpacity(0)
        -- local background1 = CSResourceMgr.seekNodeByName(panel1, "background_1")
        -- local background2 = CSResourceMgr.seekNodeByName(panel1, "background_2")
        -- local background3 = CSResourceMgr.seekNodeByName(panel1, "background_3")
        -- local background4 = CSResourceMgr.seekNodeByName(panel1, "background_4")
        -- local background5 = CSResourceMgr.seekNodeByName(panel2, "background_5")
        local petAni      = CSResourceMgr.seekNodeByName(panel1, "pet_ani")
        local arrowLeft   = CSResourceMgr.seekNodeByName(panel2, "arrow_left")
        local arrowLeftL  = CSResourceMgr.seekNodeByName(panel2, "arrow_left_light")
        local arrowMid    = CSResourceMgr.seekNodeByName(panel2, "arrow_mid")
        local arrowMidL   = CSResourceMgr.seekNodeByName(panel2, "arrow_mid_light")
        local arrowRight  = CSResourceMgr.seekNodeByName(panel2, "arrow_right")
        local arrowRightL = CSResourceMgr.seekNodeByName(panel2, "arrow_right_light")
        local bg          = CSResourceMgr.seekNodeByName(panel2, "bg")
        local pet1        = CSResourceMgr.seekNodeByName(panel2, "pet_1")
        local pet2        = CSResourceMgr.seekNodeByName(panel2, "pet_2")
        local pet3        = CSResourceMgr.seekNodeByName(panel2, "pet_3")
        local diff = CocosModuleMgr.getScreenSizeDiff() > 0 and CocosModuleMgr.getScreenSizeDiff() or 0
        petAni:setScale(0.6+diff/600)
        ViewMgrUtils.vFitSetPos(diff, {panel1})
        ViewMgrUtils.vFitSetPos(-diff, {bottom,petAni,pet1,pet2,pet3})
        -- ViewMgrUtils.hFitStretch(diff, {background3,background4})
        -- ViewMgrUtils.vFitStretch(diff, {background1,background2,background4})
        ViewMgrUtils.vFitSetPos(-diff, {arrowLeft,arrowLeftL,arrowMid,arrowMidL,arrowRight,arrowRightL})
        ViewMgrUtils.vFitStretch(diff*0.5, {arrowLeft,arrowLeftL,arrowMid,arrowMidL,arrowRight,arrowRightL,bg})
        transition.fadeIn(panel1, {time=0.5})
        transition.fadeIn(panel2, {time=0.5})
    end

    local function loadLayerB()
        layerEvolutionPartB = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameEvoB)
        layerEvolutionPartB:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resNameEvoB)
        CSResourceMgr.setRelativePosition(resNameEvoB, 320, 480)
        -- layerEvolutionPartB:setOpacity(0)
        PetEducationMgr.showEvolutionPartB(petInfo)
        layerEvolutionPartB:setVisible(false)
        -- transition.fadeIn(layer, {time=0.5})

        local bottom            = CSResourceMgr.getNodeByName(resNameEvoB, "bottom")
        local Image_2           = CSResourceMgr.getNodeByName(resNameEvoB, "Image_2")
        -- local background1       = CSResourceMgr.seekNodeByName(Image_2, "background1")
        -- local background2       = CSResourceMgr.seekNodeByName(Image_2, "background2")
        local background3       = CSResourceMgr.seekNodeByName(Image_2, "background3")
        -- local background4       = CSResourceMgr.seekNodeByName(Image_2, "background4")
        local parent            = CSResourceMgr.seekNodeByName(Image_2, "petInfoList")
        local petBackground     = CSResourceMgr.seekNodeByName(Image_2, "pet_background")
        local petIcon           = CSResourceMgr.seekNodeByName(Image_2, "pet_icon")
        local petName           = CSResourceMgr.seekNodeByName(Image_2, "pet_name")
        local btnBack           = CSResourceMgr.seekNodeByName(Image_2, "btn_back")
        local mainAtt           = CSResourceMgr.seekNodeByName(Image_2, "background_mainAtt")
        local deputyAtt         = CSResourceMgr.seekNodeByName(Image_2, "background_DeputyAtt")

        local diff = CocosModuleMgr.getScreenSizeDiff() > 0 and CocosModuleMgr.getScreenSizeDiff() or 0
        ViewMgrUtils.vFitSetPos(-diff, {bottom})
        ViewMgrUtils.vFitSetPos(diff,  {background3,parent,petBackground,petIcon,petName,btnBack,mainAtt,deputyAtt})
        ViewMgrUtils.vFitStretch(diff, {background3,parent})
    end

    local function loadUI()
        PetEducationMgr.refreshEvolutionTopPage(petInfo)
        PetEducationMgr.refreshEvolutionBottomPage(petInfo)
        PetEducationMgr.selectPetByIndex(1, 1)
    end

    local funcTable = {loadLayerA, loadLayerB, loadUI}
    UnblockLoader.load(funcTable, LoaderTag[4],0.05)
end

function PetEducationMgr.getPetFC(pokemonInfo, petInfo)
    return PetEducationMgr.calPetFC(pokemonInfo, petInfo, yokeValues, yokeRates)
end

function PetEducationMgr.setPetAniAndAttr(petInfo)
    local panel1        = CSResourceMgr.getNodeByName(tabResName[4], "panel_1")
    local spriteRare    = CSResourceMgr.seekNodeByName(panel1, "pet_rare")
    local spriteAtt11   = CSResourceMgr.seekNodeByName(panel1, "type_slot_1")
    local spriteAtt12   = CSResourceMgr.seekNodeByName(spriteAtt11, "type_ico")
    local spriteAtt21   = CSResourceMgr.seekNodeByName(panel1, "type_slot_2")
    local spriteAtt22   = CSResourceMgr.seekNodeByName(spriteAtt21, "type_ico")
    local labelPower    = CSResourceMgr.seekNodeByName(panel1, "power_num")
    -- local petAni        = CSResourceMgr.seekNodeByName(panel1, "pet_ani")

    local evoInfo           = PokemonInfo.getPetEvoInfoByID(petInfo.pokeID)
    local evoLvInfo         = evoInfo.PetEvoLevelInfoVec[selectedEvolutionPetIndex]
    local showPetPokeId     = evoLvInfo.EvoRateInfoVec[1].newRace
    local pokemonInfo       = PokemonInfo.getPokemonInfoByID(showPetPokeId)
    local rarePoint         = pokemonInfo.rarePoint
    local power             = PetEducationMgr.getPetFC(pokemonInfo, petInfo)

    spriteAtt21:setVisible(pokemonInfo.elementAtt2 ~= 0)
    spriteAtt11:loadTexture("Pet/AttriIcon/small_"..pokemonInfo.elementAtt1..".png")
    spriteAtt12:loadTexture("Pet/AttriIcon/"..pokemonInfo.elementAtt1..".png")
    if pokemonInfo.elementAtt2 ~= 0 then
        spriteAtt21:loadTexture("Pet/AttriIcon/small_"..pokemonInfo.elementAtt2..".png")
        spriteAtt22:loadTexture("Pet/AttriIcon/"..pokemonInfo.elementAtt2..".png")
    end
    local order = pokemonInfo.rarePoint or 6
    spriteRare:loadTexture(orderString[order])
    CSResourceMgr.setLabelStringByNode(labelPower, power, nil, 1, 100)
end

function PetEducationMgr.setEvolutionPetAni(petInfo, skinNum)
    local evoInfo           = PokemonInfo.getPetEvoInfoByID(petInfo.pokeID)
    local evoLvInfo         = evoInfo.PetEvoLevelInfoVec[selectedEvolutionPetIndex]
    local showPetPokeId     = evoLvInfo.EvoRateInfoVec[1].newRace

    local panel1 = CSResourceMgr.getNodeByName(tabResName[4], "panel_1")
    local petAni = CSResourceMgr.seekNodeByName(panel1, "pet_ani")
    local petRes = PokemonInfo.getPokemonResByID(showPetPokeId)
    local aniRes = AnimationMgr.createAni(petAni, petRes, 0, 0, "Pet_Evolution_"..showPetPokeId)
    AnimationMgr.playAni(petRes, "idle", true, "Pet_Evolution_"..showPetPokeId)
    aniRes:setScale(0.8)

    local skin = 0
    if petInfo.skin ~= 0 then
        skin = skinNum
    end
    AnimationMgr.setSkin(petRes, skin, "Pet_Evolution_"..showPetPokeId)
end

function PetEducationMgr.refreshEvolutionTopPage(petInfo)
    local pokemonInfo   = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
    local panel1        = CSResourceMgr.getNodeByName(tabResName[4], "panel_1")
    local panel2        = CSResourceMgr.getNodeByName(tabResName[4], "panel_2")
    local labelRare     = CSResourceMgr.seekNodeByName(panel1, "pet_rare_title")
    local labelAtt      = CSResourceMgr.seekNodeByName(panel1, "pet_attr_title")
    local labelPower    = CSResourceMgr.seekNodeByName(panel1, "power_num")
    local btnPetInfo    = CSResourceMgr.seekNodeByName(panel1, "btn_pet_info")
    -- local labelPetInfo  = CSResourceMgr.seekNodeByName(btnPetInfo, "pet_info")

    labelRare:enableOutline   (outlineColor[1], PetEducationMgr.LABLE_OUTLINE_THICK)
    labelAtt:enableOutline    (outlineColor[1], PetEducationMgr.LABLE_OUTLINE_THICK)
    -- labelPetInfo:enableOutline(outlineColor[6], CSResourceMgr.DEFAULT_LABEL_OUTLINE_BORDER)
    labelPower:enableOutline  (outlineColor[1], PetEducationMgr.LABLE_OUTLINE_THICK)    

    local strRare = LuaSqlite.getLanguageByKey("train76").."："
    local strAtt = LuaSqlite.getLanguageByKey("train86").."："
    CSResourceMgr.setLabelStringByNode(labelRare,    strRare, nil, 1, 78)
    CSResourceMgr.setLabelStringByNode(labelAtt,     strAtt, nil, 1, 72)
    -- CSResourceMgr.setLabelStringByNode(labelPetInfo, "train87", nil, 1, 82)

    CSResourceMgr.setLabelColorByNode(labelRare,    labelColor[15])
    CSResourceMgr.setLabelColorByNode(labelAtt,     labelColor[15])
    -- CSResourceMgr.setLabelColorByNode(labelPetInfo, labelColor[16])
    CSResourceMgr.setLabelColorByNode(labelPower,   labelColor[5])

    local evoInfo  = PokemonInfo.getPetEvoInfoByID(petInfo.pokeID)
    local evoCount = #evoInfo.PetEvoLevelInfoVec
    PetEducationMgr.sortEvolutionPets(evoCount)
    PetEducationMgr.showEvolutionPets(evoCount)
    local lastSelectedPetIndex = 1
    local index = 1
    for k,v in pairs(evoInfo.PetEvoLevelInfoVec) do
        local btnPet        = sortedEvolutionPets[(index-1)*3+1]
        local spritelight   = CSResourceMgr.seekNodeByName(btnPet, "light")
        local background    = CSResourceMgr.seekNodeByName(btnPet, "background")
        local spriteIcon    = CSResourceMgr.seekNodeByName(btnPet, "pet_icon")
        local labelName     = CSResourceMgr.seekNodeByName(btnPet, "pet_name")
        local nextPokeID    = v.EvoRateInfoVec[1].newRace
        local pInfo         = PokemonInfo.getPokemonInfoByID(nextPokeID)
        local icon          = pInfo.icon
        local name          = pInfo.name
        local rarePoint     = pInfo.rarePoint
        local petNameColor  = PokemonInfo.COLOR[rarePoint]

        btnPet:setVisible(true)
        CSResourceMgr.setSpriteTextureByNode(background, "Pet/petcards/stage/"..rarePoint..".png")
        CSResourceMgr.setSpriteTextureByNode(spriteIcon, "Pet/PetIcon/"..icon..".png")
        CSResourceMgr.setLabelStringByNode(labelName, name, nil, 1, 80)
        CSResourceMgr.setLabelColorByNode(labelName, petNameColor)
        labelName:enableOutline(outlineColor[1], PetEducationMgr.LABLE_OUTLINE_THICK)

        CSResourceMgr.clickEventBindingByNode(btnPet, function ()
            if lastSelectedPetIndex == k then return end
            -- 点击宠物
            local evoInfo = PokemonInfo.getPetEvoInfoByID(petInfo.pokeID)
            local evoLvInfo = evoInfo.PetEvoLevelInfoVec[lastSelectedPetIndex]
            local lastPetPokeID = evoLvInfo.EvoRateInfoVec[1].newRace
            local aniRes = PokemonInfo.getPokemonResByID(lastPetPokeID)
            AnimationMgr.removeGafObjectByTag(aniRes,"Pet_Evolution_"..lastPetPokeID)
            cc.Director:getInstance():getTextureCache():removeUnusedTextures()

            PetEducationMgr.selectPetByIndex(lastSelectedPetIndex, k)
            PetEducationMgr.setPetAniAndAttr(petInfo)
            PetEducationMgr.setEvolutionPetAni(petInfo, 0)
            PetEducationMgr.refreshEvolutionBottomPage(petInfo)
            lastSelectedPetIndex = k
            print("click pet")
        end)
        index = index + 1
    end
    PetEducationMgr.setPetAniAndAttr(petInfo)
    PetEducationMgr.setEvolutionPetInfoBtn(petInfo)
    PetEducationMgr.setEvolutionPetAni(petInfo, 0)

    PetEducationMgr.btnBodyLockState = false
    PetEducationMgr.setEvolutionBtnLock(panel1)
    local costDiamon = SystemInfo.getGlobalConfigAddInfoByID(6302).values[1]
    local btnLock = CSResourceMgr.seekNodeByName(panel1, "btn_lock")
    CSResourceMgr.clickEventBindingByNode(btnLock, function ()
        local function changeLockState()
            if PetEducationMgr.btnBodyLockState == true then
                PetEducationMgr.btnBodyLockState = false
                PetEducationMgr.setEvolutionPetAni(petInfo, 0)
                PetEducationMgr.setEvolutionBtnLock(panel1)
            else
                if costDiamon > CharInfo.getMCash() then
                    StandardTipsMgr.show(1, "tips14")--钻石不足
                else
                    PetEducationMgr.btnBodyLockState = true

                    local evoInfo           = PokemonInfo.getPetEvoInfoByID(petInfo.pokeID)
                    local evoLvInfo         = evoInfo.PetEvoLevelInfoVec[selectedEvolutionPetIndex]
                    local showPetPokeId     = evoLvInfo.EvoRateInfoVec[1].newRace

                    local skinID = PetEducationMgr.getEvolutionSkinID(petInfo, showPetPokeId)
                    PetEducationMgr.setEvolutionPetAni(petInfo, skinID)
                    PetEducationMgr.setEvolutionBtnLock(panel1)
                end
            end
        end
        if PetEducationMgr.btnBodyLockState == false then
            local value = SystemInfo.getGlobalConfigAddInfoByID(6302).values[1]
            local str = CocosModuleMgr.createStringWithFormat({"train142", value})
            DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 2, str, function ()
                changeLockState()
            end)
        else
            changeLockState()
        end
    end)
end

function PetEducationMgr.refreshEvolutionBottomPage(petInfo)
    local bottom      = CSResourceMgr.getNodeByName(tabResName[4], "bottom")
    local needResName = CSResourceMgr.seekNodeByName(bottom, "res_need_name")
    local needResLv   = CSResourceMgr.seekNodeByName(bottom, "res_need_lv")
    local needResLvR  = CSResourceMgr.seekNodeByName(bottom, "res_need_lv_label")
    local labelEvolut = CSResourceMgr.seekNodeByName(bottom, "str_stength")
    local parent      = CSResourceMgr.seekNodeByName(bottom, "res_background3")
    local item        = CSResourceMgr.seekNodeByName(bottom, "btn_res")
    local resCount    = CSResourceMgr.seekNodeByName(bottom, "res_count")
    local btnResAdd   = CSResourceMgr.seekNodeByName(bottom, "res_btn_add")
    
    local evoInfo     = PokemonInfo.getPetEvoInfoByID(petInfo.pokeID)
    local needLevel   = evoInfo.PetEvoLevelInfoVec[selectedEvolutionPetIndex].level
    local needLvColor = (needLevel <= petInfo.level) and labelColor[14] or labelColor[19]

    CSResourceMgr.setLabelStringByNode(needResName, "train27")
    CSResourceMgr.setLabelStringByNode(needResLv,   LuaSqlite.getLanguageByKey("train88").."：")
    CSResourceMgr.setLabelStringByNode(needResLvR,  needLevel)
    CSResourceMgr.setLabelStringByNode(labelEvolut, "train3", {r=0,g=0,b=0,a=255,w=1,s=1})
    CSResourceMgr.setLabelStringByNode(resCount, CharInfo.getGCash(), {r=0,g=0,b=0,a=255,w=1,s=1})

    CSResourceMgr.setLabelColorByNode(needResName, labelColor[14])
    CSResourceMgr.setLabelColorByNode(needResLv,   labelColor[14])
    CSResourceMgr.setLabelColorByNode(needResLvR,  needLvColor)
    CSResourceMgr.setLabelColorByNode(labelEvolut, labelColor[10])

	if evoInfo.PetEvoLevelInfoVec[selectedEvolutionPetIndex].EvoRateInfoVec[1].newRace >= 20000 then
		CSResourceMgr.setLabelStringByNode(needResName, "superevo6")
		needResName:setPositionX(needResName:getPositionX() + 100)
    end
    needResLv:setPositionX(needResLvR:getPositionX() - needResLvR:getBoundingBox().width)

    PetEducationMgr.showEvolutionRes(evoInfo, needLevel <= petInfo.level)

    CSResourceMgr.clickEventBindingByNode(btnResAdd, function ()
        ExchangeViewMgr.show(SceneMgr.getRunningScene, ExchangeViewMgr.GCASHTYPE)
    end)
end

function PetEducationMgr.sortEvolutionPets(evoCount)
    local panel2      = CSResourceMgr.getNodeByName(tabResName[4], "panel_2")
    local btnPet1     = CSResourceMgr.seekNodeByName(panel2, "pet_1")
    local btnPet2     = CSResourceMgr.seekNodeByName(panel2, "pet_2")
    local btnPet3     = CSResourceMgr.seekNodeByName(panel2, "pet_3")
    local arrowLeft   = CSResourceMgr.seekNodeByName(panel2, "arrow_left")
    local arrowLeftL  = CSResourceMgr.seekNodeByName(panel2, "arrow_left_light")
    local arrowMid    = CSResourceMgr.seekNodeByName(panel2, "arrow_mid")
    local arrowMidL   = CSResourceMgr.seekNodeByName(panel2, "arrow_mid_light")
    local arrowRight  = CSResourceMgr.seekNodeByName(panel2, "arrow_right")
    local arrowRightL = CSResourceMgr.seekNodeByName(panel2, "arrow_right_light")
    if evoCount == 1 then
        sortedEvolutionPets = {btnPet2,arrowMid,arrowMidL}
    elseif evoCount == 2 then
        sortedEvolutionPets = {btnPet1,arrowLeft,arrowLeftL, btnPet3,arrowRight,arrowRightL}
    elseif evoCount == 3 then
        sortedEvolutionPets = {btnPet1,arrowLeft,arrowLeftL, btnPet2,arrowMid,arrowMidL, btnPet3,arrowRight,arrowRightL}
    end
    for i = 1, evoCount do
        for j = 1, 2 do
            sortedEvolutionPets[(i-1)*3+j]:setVisible(true)
        end
    end
end

function PetEducationMgr.showEvolutionPets(evoCount)
    for i = 1, evoCount do
        for j = 1, 2 do
            sortedEvolutionPets[(i-1)*3+j]:setVisible(true)
        end
    end
end

function PetEducationMgr.setEvolutionBtnLock(node)
    local sprite1 = CSResourceMgr.seekNodeByName(node, "lock_icon1")
    local sprite2 = CSResourceMgr.seekNodeByName(node, "lock_icon2")
    local sprite3 = CSResourceMgr.seekNodeByName(node, "lock_icon3")
    local label   = CSResourceMgr.seekNodeByName(node, "lock_str")

    sprite1:setVisible(PetEducationMgr.btnBodyLockState == true)
    sprite2:setVisible(PetEducationMgr.btnBodyLockState == true)
    local posX = PetEducationMgr.btnBodyLockState == true and 150 or 8
    sprite3:setPositionX(posX)
    local lockColor = PetEducationMgr.btnBodyLockState == true and labelColor[1] or labelColor[21]
    CSResourceMgr.setLabelStringByNode(label, "train141", outlineColor[8], nil, 108)
    CSResourceMgr.setLabelColorByNode(label, lockColor)

    local spriteDiamon = CSResourceMgr.seekNodeByName(node, "diamon_icon")
    local labelDiamon  = CSResourceMgr.seekNodeByName(node, "diamon_cost1")
    local costDiamon = SystemInfo.getGlobalConfigAddInfoByID(6302).values[1]
    CSResourceMgr.setLabelStringByNode(labelDiamon, "x"..costDiamon, outlineColor[8])
    CSResourceMgr.setLabelColorByNode(labelDiamon, lockColor)
    local diamonColor = PetEducationMgr.btnBodyLockState == true and {r=255,g=255,b=255,a=255} or {r=123,g=123,b=123,a=123}
    spriteDiamon:setColor(diamonColor)
end

function PetEducationMgr.selectPetByIndex(lastSelectedPetIndex, index)
    sortedEvolutionPets[(lastSelectedPetIndex-1)*3+3]:setVisible(false)
    sortedEvolutionPets[(index-1)*3+3]:setVisible(true)
    CSResourceMgr.seekNodeByName(sortedEvolutionPets[(lastSelectedPetIndex-1)*3+1], "light"):setVisible(false)
    CSResourceMgr.seekNodeByName(sortedEvolutionPets[(index-1)*3+1], "light"):setVisible(true)

    CSResourceMgr.seekNodeByName(sortedEvolutionPets[(lastSelectedPetIndex-1)*3+1], "btn_pet_info"):setVisible(false)
    CSResourceMgr.seekNodeByName(sortedEvolutionPets[(index-1)*3+1], "btn_pet_info"):setVisible(true)
    local diff = CocosModuleMgr.getScreenSizeDiff() * 0.5 > 0 and CocosModuleMgr.getScreenSizeDiff() * 0.5 or 0
    sortedEvolutionPets[(lastSelectedPetIndex-1)*3+1]:setPositionY(344-diff)
    sortedEvolutionPets[(index-1)*3+1]:setPositionY(392-diff)
    selectedEvolutionPetIndex = index
end

function PetEducationMgr.setEvolutionPetInfoBtn(petInfo)
    for i=1,#sortedEvolutionPets do
        local btn = CSResourceMgr.seekNodeByName(sortedEvolutionPets[(i-1)*3+1], "btn_pet_info")
        local str = CSResourceMgr.seekNodeByName(btn, "pet_info")
        CSResourceMgr.setLabelStringByNode(str, "train87", {r=0,g=0,b=0,a=255,w=1})
        CSResourceMgr.clickEventBindingByNode(btn, function ()
            layerEvolutionPartA:setVisible(false)
            PetEducationMgr.showEvolutionPartB(petInfo)
        end)
    end
end

function PetEducationMgr.showEvolutionRes(evoInfo, lvEnough)
    local stageCons = evoInfo.PetEvoLevelInfoVec[selectedEvolutionPetIndex].stageCons
    local bottom    = CSResourceMgr.getNodeByName(tabResName[4], "bottom")
    -- local bottom    = CSResourceMgr.seekNodeByName(panel2, "bottom")
    local parent    = CSResourceMgr.seekNodeByName(bottom, "res_background4")
    local item      = CSResourceMgr.seekNodeByName(bottom, "btn_res")
    local btnEvolut = CSResourceMgr.seekNodeByName(bottom, "btn_strength")
    local labelEvolut = CSResourceMgr.seekNodeByName(bottom, "str_stength")
    for k,v in pairs(parent:getChildren()) do
        parent:removeChild(v)
    end
    local isResEnough = true
    local index = 1
    for k,v in pairs(stageCons) do
        local node = item:clone()
        node:setVisible(true)
        node:addTo(parent)
        if #stageCons % 2 ~= 0 then--奇数
            node:setPosition(300 + ((index - 1) - (#stageCons - 1) / 2) * 100, 52)
        else
            node:setPosition(300 + ((index - (#stageCons / 2)) * 100 - 60), 52)
        end
        node:setScale(0.85)

        local spriteIcon = CSResourceMgr.seekNodeByName(node, "res_icon")
        local spriteAdd  = CSResourceMgr.seekNodeByName(node, "res_add")
        local labelNum   = CSResourceMgr.seekNodeByName(node, "res_num")
        local icon,have,strCount
        local elementInfo = ItemInfo.getConsumeElementInfoById(v)
        local needNum = elementInfo.num
        local elementID = elementInfo.elementID
        local background = ItemInfo.getItemRareBGImage((elementID == 0) and {} or elementID)
        if elementInfo.elementType == 1 then
            icon = "Searching/topBar/jinbi.png"
            have = CharInfo.getGCash()
            elementID = 9998
            strCount = needNum
        elseif elementInfo.elementType == 2 then
            icon = "empty.png"
            have = CharInfo.getMCash()
            elementID = 9999
            strCount = have.."/"..needNum
        elseif elementInfo.elementType == 3 then
            icon = ItemInfo.getItemInfoById(elementInfo.elementID).icon
            have = ItemInfo.getCharItemNum(elementInfo.elementID)
            strCount = have.."/"..needNum
        end
        spriteAdd:setVisible(false)
        -- CSResourceMgr.setSpriteTextureByNode(spriteIcon, icon)

        local iNode = ItemInfo.getItemIconById(elementID, nil)
        CSResourceMgr.setButtonTextureByNode(node, "empty.png","empty.png","empty.png")
        iNode:setPosition(0, 0)
        iNode:removeFromParent()
        iNode:addTo(spriteIcon)
        iNode:setScale(node:getContentSize().width / iNode:getContentSize().width)

        CSResourceMgr.setLabelStringByNode(labelNum, strCount, nil, 1, 80)
        CSResourceMgr.setLabelColorByNode(labelNum, (have >= needNum) and labelColor[1] or labelColor[17])
        CSResourceMgr.setButtonTextureByNode(node, background, background, background)
        labelNum:enableOutline(outlineColor[1])
        if have < needNum then isResEnough = false end
        CSResourceMgr.clickEventBindingByNode(iNode, function ()
            ItemInfoViewMgr.show({id = elementID}, false)
        end)

        index = index + 1
    end

    if evoInfo.PetEvoLevelInfoVec[selectedEvolutionPetIndex].EvoRateInfoVec[1].newRace >= 20000 then
        CSResourceMgr.setLabelStringByNode(labelEvolut,"superevo1")
		if true == PetEducationMgr.getPetCanEvolution(petInfo) then
			CSResourceMgr.setButtonEnabledByNode(btnEvolut, true)
		else
			CSResourceMgr.setButtonEnabledByNode(btnEvolut, false)
        end 
    else
		CSResourceMgr.setButtonEnabledByNode(btnEvolut, (isResEnough and lvEnough))
	end
    CSResourceMgr.clickEventBindingByNode(btnEvolut, function ()
        local function update(pid, preID)
            PetEducationMgr.showPet(petInfo.objID)
            if preID ~= nil then
                local aniRes = PokemonInfo.getPokemonResByID(preID)
                AnimationMgr.removeGafObjectByTag(aniRes, "edu-"..preID)
            end
            local aniRes = PokemonInfo.getPokemonResByID(pid)
            AnimationMgr.removeGafObjectByTag(aniRes, "Pet_Evolution_"..pid)
            cc.Director:getInstance():getTextureCache():removeUnusedTextures()
        end

        local function sendEvolution(isSuperEvo)
            PetEducationMgr.perFC = petInfo.fc
            local proName = "GC_EVOLUTIONPET_ACK"
            local PetEducationSend = require("src/Net/Send/PetEducationSend.lua")
            local sendFuc = PetEducationSend.sendCG_EvolutionPet_Req
            if isSuperEvo then
                proName = "GC_SuperEvolutionPet_Ack"
                sendFuc = PetEducationSend.sendCG_SuperEvolutionPet_Req
            end

            NetInterface.sendWithBlock(proName, function()
                sendFuc({
                    objID  = petInfo.objID, -- 请求进化的宠物ID
                    choice = selectedEvolutionPetIndex,
                    bProtectSkin = PetEducationMgr.btnBodyLockState == false and 0 or 1
                })
            end, function()
                GameAudio.playUISound("success")
                selectedEvolutionPetIndex = 1
        --        local yingcangrenwuID = SystemInfo.getGlobalConfigAddInfoByID(30000).values[1]
        --        QuestInfo.sendQuestFinished(yingcangrenwuID)
                local petID = PokemonInfo.getPetInfoByObjID(petInfo.objID).pokeID
                local pInfo = PokemonInfo.getPetInfoByObjID(petInfo.objID)
                PetHandBook.addPetToHandBook(petID)--进化后图鉴添加宠物
                PetEvolutionEffectMgr.show(petInfo.pokeID, petID, petInfo.skin, pInfo.skin, petInfo)
                update(petID, petInfo.pokeID)
                petInfo = PokemonInfo.getPetInfoByObjID(petInfo.objID)
                PetEducationMgr.setWorldFollowPet(petInfo.objID, petID, petInfo.skin)
                switchToTab(1)
                PetListMgr.setUpdateFlag("icon")
                PetListMgr.setUpdateFlag("name")
                PetListMgr.setUpdateFlag("attr")
                PetListMgr.setUpdateFlag("rare")

                local pokeInfo = PokemonInfo.getPokemonInfoByID(petID)
                local params = {}
                params.objID = petInfo.objID
                params.rarePoint = pokeInfo.rarePoint
                TaskWatcherManager.savePetJingHuaState(params)
                end,function(code)
                    -- print("code........",code) ---------ERROR_NOTENOUGH_RMB  
                TipsMgr.showError(nil, code)
                end)
        end


        if evoInfo.PetEvoLevelInfoVec[selectedEvolutionPetIndex].EvoRateInfoVec[1].newRace >= 20000 then
            DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, "superevo4", function ()
                    if petInfo.star < 5 then
                        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "superevo2")
                        return 
                    end
                    if false == PetEducationMgr.checkIsFullYoke(petInfo) then
                        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "superevo3")
                        return 
                    end
					if true == PetEducationMgr.checkYokeHasEquipment(petInfo) then
                        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "superevo7")
                    return 
                    end
                    sendEvolution(true)
                end)
            
        else
            if petInfo.yoke and petInfo.yoke.bindTo then
                DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "train176")

            elseif PetEducationMgr.btnBodyLockState == false and petInfo.skin > 0 then
                DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, "train181", function ()
                    sendEvolution()
                end)
            else
                sendEvolution()
            end
        end
    end)
end

function PetEducationMgr.showEvolutionPartB(petInfo)
    layerEvolutionPartB:setVisible(true)
    local evoInfo           = PokemonInfo.getPetEvoInfoByID(petInfo.pokeID)
    local evoLvInfo         = evoInfo.PetEvoLevelInfoVec[selectedEvolutionPetIndex]
    local showPetInfo       = PokemonInfo.getPetInfoByObjID(petInfo.objID)
    local showPetPokeId     = evoLvInfo.EvoRateInfoVec[1].newRace
    PetEducationMgr.refreshEvolutionPageAtts(resNameEvoB, petInfo, showPetPokeId, true, showPetInfo)
    local showPetPokeInfo   = PokemonInfo.getPokemonInfoByID(showPetPokeId)
    local showPetIcon       = showPetPokeInfo.icon
    local showPetQuality    = showPetPokeInfo.rarePoint
    local showPetName       = showPetPokeInfo.name

    local Image_2           = CSResourceMgr.getNodeByName(resNameEvoB, "Image_2")
    -- local background1       = CSResourceMgr.seekNodeByName(Image_2, "background1")
    -- local background2       = CSResourceMgr.seekNodeByName(Image_2, "background2")
    local background3       = CSResourceMgr.seekNodeByName(Image_2, "background3")
    -- local background4       = CSResourceMgr.seekNodeByName(Image_2, "background4")
    local parent            = CSResourceMgr.seekNodeByName(Image_2, "petInfoList")
    local petBackground     = CSResourceMgr.seekNodeByName(Image_2, "pet_background")
    local petIcon           = CSResourceMgr.seekNodeByName(Image_2, "pet_icon")
    local petName           = CSResourceMgr.seekNodeByName(Image_2, "pet_name")
    local btnBack           = CSResourceMgr.seekNodeByName(Image_2, "btn_back")
    local labelBack         = CSResourceMgr.seekNodeByName(btnBack, "str_back")
    local lableMainAttName  = CSResourceMgr.seekNodeByName(Image_2, "currLevel")
    local labelDeputyAttName= CSResourceMgr.seekNodeByName(Image_2, "nextLevel")
    CSResourceMgr.setLabelStringByNode(lableMainAttName,   "train36", nil, 1, 96)
    CSResourceMgr.setLabelStringByNode(labelDeputyAttName, "train37", nil, 1, 96)
    CSResourceMgr.setLabelColorByNode(lableMainAttName,   labelColor[5])
    CSResourceMgr.setLabelColorByNode(labelDeputyAttName, labelColor[4])

    CSResourceMgr.setSpriteTextureByNode(petBackground, "Pet/petcards/stage/"..showPetQuality..".png")
    CSResourceMgr.setSpriteTextureByNode(petIcon, "Pet/PetIcon/"..showPetIcon..".png")
    CSResourceMgr.setLabelStringByNode(labelBack, "train89")
    CSResourceMgr.setLabelStringByNode(petName, showPetName, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelColorByNode(labelBack, labelColor[16])
    CSResourceMgr.setLabelColorByNode(petName, PokemonInfo.COLOR[showPetPokeInfo.rarePoint])
    labelBack:enableOutline(outlineColor[6], CSResourceMgr.DEFAULT_LABEL_OUTLINE_BORDER)
    CSResourceMgr.clickEventBindingByNode(btnBack, function ()
        layerEvolutionPartA:setVisible(true)
        layerEvolutionPartB:setVisible(false)
    end, 2)
    
    local bottom = CSResourceMgr.getNodeByName(resNameEvoB, "bottom")
    local title  = CSResourceMgr.seekNodeByName(bottom, "new_skill_title")
    CSResourceMgr.setLabelStringByNode(title, "train90")
    CSResourceMgr.setLabelColorByNode(title, {r=255,g=168,b=0,a=255,w=1,s=1})
    local parent = CSResourceMgr.seekNodeByName(bottom, "background6")
    local item = CSResourceMgr.seekNodeByName(bottom, "new_skill")
    for k,v in pairs(parent:getChildren()) do
        parent:removeChild(v)
    end

    local skillType  = evoLvInfo.EvoRateInfoVec[1].EvoSkillVec[1].skillType  --技能类型
    local skillArrID = evoLvInfo.EvoRateInfoVec[1].EvoSkillVec[1].skillArrID --技能组
    local geneProbabilityInfo = PokemonInfo.getGeneProbabilityInfoByID(skillArrID)
    local geneGroup = geneProbabilityInfo.geneGroup
    local maxSkillLength = (#geneGroup > 5) and 5 or #geneGroup
    local index = 1
    local diffX = 120
    for k,v in pairs(geneGroup) do
        if index > 5 then return end
        local skillId = v.prob_skillID
        if skillId ~= 0 then
            local node = item:clone()
            node:setVisible(true)
            node:addTo(parent)
            if maxSkillLength % 2 ~= 0 then--奇数
                node:setPosition(320 + ((index - 1) - (maxSkillLength - 1) / 2) * diffX, 58)
            else
                node:setPosition(320 + ((index - (maxSkillLength / 2)) * diffX - 60), 58)
            end
        
            local skillInfo  = PokemonInfo.getPetSkillInfoById(skillId)
            local skillIcon  = CSResourceMgr.seekNodeByName(node, "s_ico")
            local skillName  = CSResourceMgr.seekNodeByName(node, "s_name")
            local skillNameB = CSResourceMgr.seekNodeByName(node, "new_skill_background2")
            local skillTypeN = CSResourceMgr.seekNodeByName(node, "s_type")
            local skillBG    = CSResourceMgr.seekNodeByName(node, "new_skill_background1")
            local skillRare  = skillInfo.airpower or 5
            -- CSResourceMgr.setSpriteTextureByNode(skillIcon, "Battle/skillIcon/"..skillInfo.icon..".png")
            -- if skillType == 0 then--主动
            --     iconPath = "Battle/downEdge_A/fight_skill_base_02.png"
            -- elseif skillType == 1 then
            --     iconPath = "Battle/downEdge_A/fight_skill_base_01.png" 
            -- elseif skillType == 7 then
            --     iconPath = aidSkillBackGroundPath[skillRare - 1]
            -- elseif skillType == 6 then
            --     iconPath = passiveSkillBackGroundPath[skillType]
            -- end
            -- CSResourceMgr.setSpriteTextureByNode(skillBG, iconPath)
            CSResourceMgr.setSpriteTextureByNode(skillBG, "empty.png")
            local iNode = PetSkillIconMgr.createPetSkillIcon(skillBG, skillInfo)
            CSResourceMgr.setLabelStringByNode(skillName, skillInfo.name, {r=38,g=54,b=76,a=255,w=1,s=1})
            CSResourceMgr.setLabelColorByNode(skillName, {r=205,g=229,b=255,a=255})
            skillNameB:setColor({r=40,g=68,b=90,a=255})
            skillNameB:setOpacity(102)
            CSResourceMgr.setLabelStringByNode(skillTypeN, EnumSkillType[skillType+1])
            CSResourceMgr.setLabelColorByNode(skillTypeN, labelColor[15])
            skillTypeN:enableOutline(outlineColor[1], PetEducationMgr.LABLE_OUTLINE_THICK)

            index = index + 1
        end
    end
end

function PetEducationMgr.strengthenPageInit()
    --tab 2
    local function loadCSB()
        local panel1 = CSResourceMgr.getNodeByName(tabResName[2], "panel_1")
        local panel2 = CSResourceMgr.getNodeByName(tabResName[2], "panel_2")
        panel1:setOpacity(0)
        panel2:setOpacity(0)
        local stretchTable = {
            CSResourceMgr.getNodeByName(tabResName[2], {"panel_1","background1"}),
            CSResourceMgr.getNodeByName(tabResName[2], {"panel_1","background2"}),
            CSResourceMgr.getNodeByName(tabResName[2], {"panel_1","background3"}),
            CSResourceMgr.getNodeByName(tabResName[2], {"panel_1","petInfoList"}),
        }
        local diff = CocosModuleMgr.getScreenSizeDiff() > 0 and CocosModuleMgr.getScreenSizeDiff() or 0
        ViewMgrUtils.vFitSetPos(-diff, {panel1})
        ViewMgrUtils.vFitSetPos(diff, {panel2})
        ViewMgrUtils.vFitStretch(diff, stretchTable)

        transition.fadeIn(panel1, {time=0.5})
        transition.fadeIn(panel2, {time=0.5})
    end

    loadCSB()
    PetEducationMgr.refreshStrengthPage(petInfo)
end

function PetEducationMgr.refreshStrengthPage(petInfo, showAttrAdd)
    local pokemonInfo   = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
    local petNameColor  = PokemonInfo.COLOR[pokemonInfo.rarePoint]
    local strStage      = petInfo.Stage ~= 0 and "+"..petInfo.Stage or ""
    local maxStage      = math.floor(pokemonInfo.topLevel / 2)
    
    local labelCurName  = LuaSqlite.getLanguageByKey(pokemonInfo.name)..strStage
    local curName       = CSResourceMgr.getNodeByName(tabResName[2], {"panel_2","curName"})
    CSResourceMgr.setLabelColorByNode(curName, petNameColor)
    CSResourceMgr.setLabelStringByNode(curName, labelCurName, outlines[1], 1, 180)

    if petInfo.Stage < maxStage then--可以强化
        PetEducationMgr.setStrengthenNode(petInfo, pokemonInfo, showAttrAdd)
    else--MAX显示
        local panel1 = CSResourceMgr.getNodeByName(tabResName[2], "panel_1")
        local panel2 = CSResourceMgr.getNodeByName(tabResName[2], "panel_2")
        panel1:setVisible(false)
        panel2:setVisible(false)
        PetEducationMgr.showMaxWithTab(2)
        return
    end

    local petRp = pokemonInfo.elementAtt1--rarePoint
    local advanceInfo = PokemonInfo.getPetAdvanceInfo(petInfo.Stage+1)
    local itemTable = advanceInfo.stageCons[petRp]
    local needLevel = (petInfo.Stage + 1) * 2
    local petLevel = petInfo.level
    local maxPetCanStangeLevel = pokemonInfo.topLevel

    local haveEnoughRes = true
    local parent = CSResourceMgr.getNodeByName(tabResName[2], {"panel_1","bottom","panel","res_background4"})
    local itemNode = CSResourceMgr.getNodeByName(tabResName[2], {"panel_1","bottom","panel","btn_res"})
    for k,v in pairs(parent:getChildren()) do
        if v ~= itemNode then parent:removeChild(v) end
    end
    local index = 1
    for k,v in pairs(itemTable.costs) do
        local node = itemNode:clone()
        node:setVisible(true)
        node:addTo(parent)
        if #itemTable.costs % 2 ~= 0 then--奇数
            node:setPosition(300 + ((index - 1) - (#itemTable.costs - 1) / 2) * 100, 52)
        else
            node:setPosition(300 + ((index - (#itemTable.costs / 2)) * 100 - 60), 52)
        end
        node:setScale(0.85)

        local spriteIcon = CSResourceMgr.seekNodeByName(node, "res_icon")
        local labelRes = CSResourceMgr.seekNodeByName(node, "res_num")
        local consumeInfo = ItemInfo.getConsumeElementInfoById(v)
        local itemId = consumeInfo.elementID
        local itemInfo = ItemInfo.getItemInfoById(itemId)
        local background = ItemInfo.getItemRareBGImage((itemId == 0) and {} or itemId)
        local iconPath = "empty.png"
        local needResCount = consumeInfo.num
        local haveResCount = 0
        local strNeedRes = tostring(needResCount)
        if consumeInfo.elementType == 1 then
            iconPath = "Searching/topBar/jinbi.png"
            haveResCount = CharInfo.getGCash()
            itemId = 9998
            -- spriteIcon:setScale(1.6)
        elseif consumeInfo.elementType == 2 then
            haveResCount = CharInfo.getMCash()
            strNeedRes = haveResCount.."/"..needResCount
            itemId = 9999
        elseif consumeInfo.elementType == 3 then
            iconPath = itemInfo.icon
            haveResCount = ItemInfo.getCharItemNum(itemId)
            strNeedRes = haveResCount.."/"..needResCount
        end
        -- print("iconPath                : "..iconPath)
        -- CSResourceMgr.setButtonTextureByNode(node, background, background, background)
        -- CSResourceMgr.setSpriteTextureByNode(spriteIcon, iconPath)
        local iNode = ItemInfo.getItemIconById(itemId, nil)
        CSResourceMgr.setButtonTextureByNode(node, "empty.png","empty.png","empty.png")
        iNode:setPosition(0, 0)
        iNode:removeFromParent()
        iNode:addTo(spriteIcon)
        iNode:setScale(node:getContentSize().width / iNode:getContentSize().width)

        CSResourceMgr.setLabelStringByNode(labelRes, strNeedRes, nil, 1, 80)
        if needResCount > haveResCount then
            haveEnoughRes = false
            CSResourceMgr.setLabelColorByNode(labelRes, (haveResCount >= needResCount) and spColor[1] or labelColor[17])
            labelRes:enableOutline(outlines[1], PetEducationMgr.LABLE_OUTLINE_THICK)
        else
            CSResourceMgr.setLabelColorByNode(labelRes, labelColor[1])
            labelRes:enableOutline(outlines[13], PetEducationMgr.LABLE_OUTLINE_THICK)
        end
        CSResourceMgr.clickEventBindingByNode(iNode, function ()
            if itemId ~= 0 then
                ItemInfoViewMgr.show({id = itemId}, false)
            end
        end)
        index = index + 1
    end

    local labelResCount     = CSResourceMgr.getNodeByName(tabResName[2], {"panel_1", "bottom","panel","res_count"})
    local labelNeedResTitle = CSResourceMgr.getNodeByName(tabResName[2], {"panel_1", "bottom","panel","res_need_name"})
    local LabelNeedStrengLv = CSResourceMgr.getNodeByName(tabResName[2], {"panel_1", "bottom","panel","res_need_lv"})
    local LabelNeedLv       = CSResourceMgr.getNodeByName(tabResName[2], {"panel_1", "bottom","panel","res_need_lv_label"})
    local labelStrengthen   = CSResourceMgr.getNodeByName(tabResName[2], {"panel_1", "bottom","panel","btn_strength","str_stength"})
    local btnResAdd         = CSResourceMgr.getNodeByName(tabResName[2], {"panel_1", "bottom","panel","res_btn_add"})
    local btnStrengthen     = CSResourceMgr.getNodeByName(tabResName[2], {"panel_1", "bottom","panel","btn_strength"})
    local needLevelColor    = needLevel <= petInfo.level and labelColor[14] or spColor[1]

    CSResourceMgr.setLabelStringByNode(labelResCount, CharInfo.getGCash(), {r=0,g=0,b=0,a=0,w=1,s=1}, 1, 126)
    CSResourceMgr.setLabelStringByNode(labelNeedResTitle, LuaSqlite.getLanguageByKey("train27"), nil, 1, 240)
    CSResourceMgr.setLabelStringByNode(LabelNeedStrengLv, LuaSqlite.getLanguageByKey("train28").."：")
    CSResourceMgr.setLabelStringByNode(LabelNeedLv, needLevel)
    CSResourceMgr.setLabelStringByNode(labelStrengthen, "train2", {r=0,g=0,b=0,a=255,w=1,s=2})

    LabelNeedStrengLv:setPositionX(LabelNeedLv:getPositionX() - LabelNeedLv:getBoundingBox().width)

    CSResourceMgr.setLabelColorByNode(labelResCount,     labelColor[1])
    CSResourceMgr.setLabelColorByNode(labelNeedResTitle, labelColor[14])
    CSResourceMgr.setLabelColorByNode(LabelNeedStrengLv, labelColor[14])
    CSResourceMgr.setLabelColorByNode(LabelNeedLv,       needLevelColor)
    CSResourceMgr.setLabelColorByNode(labelStrengthen,   labelColor[10])

    CSResourceMgr.clickEventBindingByNode(btnResAdd, function ()
        ExchangeViewMgr.show(SceneMgr.getRunningScene, ExchangeViewMgr.GCASHTYPE)
    end)

    local btnStrengthenEnable = haveEnoughRes and petInfo.Stage<maxStage and needLevel<=petLevel
    CSResourceMgr.setButtonEnabledByNode(btnStrengthen, btnStrengthenEnable and PetEducationMgr.getResPetByPokeID(petInfo.pokeID) == false)
    CSResourceMgr.clickEventBindingByNode(btnStrengthen, function ()
        petInfo = PokemonInfo.getPetInfoByObjID(petInfo.objID)
        PetEducationMgr.perFC = petInfo.fc
        print("send PokemonAdvaStageLevel req")
        NetInterface.sendWithBlock("GC_POKEMONADVASTAGELEVEL_ACK", function()
            local PetEducationSend = require("src/Net/Send/PetEducationSend.lua")
            PetEducationSend.sendCG_PokemonAdvaStageLevel_Req({
                objID = petInfo.objID,
            })
        end, function()
            print("PokemonAdvaStageLevel ack success")
            GameAudio.playUISound("success")
            local parent = CSResourceMgr.getNodeByName(resName_base,"p_name")
            local effAni = AnimationMgr.createAni(parent, "Spine/effects/Ui_chongwushengji.png", 
                    parent:getContentSize().width/2, parent:getContentSize().height/2, "PetStrength")
            effAni:setPosition(effAni:getPositionX()+20, effAni:getPositionY()+50)
            AnimationMgr.playAni(effAni.res, "animation", false, "PetStrength")

            petInfo.Stage = petInfo.Stage + 1
            PetEducationMgr.refreshStrengthPage(petInfo, true)
            PetEducationMgr.showPet(petInfo.objID)

            local pInfo = PokemonInfo.getPetInfoByObjID(petInfo.objID)
            if PetEducationMgr.perFC < pInfo.fc then
                PetFCEffectMgr.show(SceneMgr.getRunningScene, PetEducationMgr.perFC, pInfo.fc)
            end

            PetListMgr.setUpdateFlag("stage")
            PetListMgr.setUpdateFlag("name")

            if petInfo.Stage == 5 and GameGuideMgr.checkGuideFinishByID(10023) == false then
                local tab = CSResourceMgr.getNodeByName(resName_base, "tab3")
                tab:setColor({r=255,g=255,b=255,a=255})
                CSResourceMgr.clickEventBindingByNode(tab, function()
                    PetStarUpMgr.show(SceneMgr.getRunningScene, petInfo.objID)
                    switchToTab(3)
                end)
                GameGuideMgr.firstStarUp()
            end

            local params = {}
            params.objID = petInfo.objID
            params.Stage = petInfo.Stage
            TaskWatcherManager.saveCWQiangHuaState(params)

            if petInfo.yoke and petInfo.yoke.bindTo then
                PetEducationMgr.needUpdateSevenDayPetYoke = true
            end
        end
        , function()
            -- 强化失败
        end)
    end)
end

function PetEducationMgr.refreshGCash()
    if CSResourceMgr.getCsbObj(resName_base) then
        if CSResourceMgr.getCsbObj(tabResName[2]) then
            local labelResCount = CSResourceMgr.getNodeByName(tabResName[2], {"panel_1", "bottom","panel","res_count"})
            CSResourceMgr.setLabelStringByNode(labelResCount, CharInfo.getGCash(), {r=0,g=0,b=0,a=0,w=1,s=1}, 1, 126)
            PetEducationMgr.refreshStrengthPage(petInfo)
        elseif CSResourceMgr.getCsbObj(tabResName[5]) then
            local labelGold = CSResourceMgr.getNodeByName(tabResName[5], "label_gold")
            CSResourceMgr.setLabelStringByNode(labelGold, CharInfo.getGCash(), {r=0,g=0,b=0,a=0,w=1,s=1}, 1, 126)
        elseif CSResourceMgr.getCsbObj(tabResName[4]) then
            local bottom = CSResourceMgr.getNodeByName(tabResName[4], "bottom")
            local resCount = CSResourceMgr.seekNodeByName(bottom, "res_count")
            CSResourceMgr.setLabelStringByNode(resCount, CharInfo.getGCash(), {r=0,g=0,b=0,a=0,w=1,s=1}, 1, 126)
            PetEducationMgr.refreshEvolutionBottomPage(petInfo)
        end
    end
end

function PetEducationMgr.setStrengthenNode(petInfo, pokemonInfo, showAttrAdd)
    local attrTitle     = {"train11","train12","train13","train14","train15","train16",}
    local list          = CSResourceMgr.getNodeByName(tabResName[2], {"panel_1","petInfoList"})
    local parent        = CSResourceMgr.getNodeByName(tabResName[2], "attr")
    local nextName      = CSResourceMgr.getNodeByName(tabResName[2], {"panel_2","nextName"})
    local strNextStage  = petInfo.Stage and "+"..petInfo.Stage + 1 or 1
    local labelNextName = LuaSqlite.getLanguageByKey(pokemonInfo.name)..strNextStage
    local petNameColor  = PokemonInfo.COLOR[pokemonInfo.rarePoint]
    CSResourceMgr.setLabelStringByNode(nextName, labelNextName, outlines[1], 1, 180)
    CSResourceMgr.setLabelColorByNode(nextName, petNameColor)
    local num1 = PetEducationMgr.calPetAttrs(pokemonInfo, petInfo, yokeValues, yokeRates)
    local num2 = PetEducationMgr.calPetAttrs(pokemonInfo, petInfo, yokeValues, yokeRates, nil, petInfo.Stage+1)
    
    local funcTable = {}
    local showSize = 6
    if list then
        list:removeAllItems()
    end
    for i = 1, #attrTitle do
        table.insert(funcTable, function()
            list:performWithDelay(function()
                local item = parent:clone()
                local background1    = CSResourceMgr.seekNodeByName(item, "att_background_1")
                local background2    = CSResourceMgr.seekNodeByName(item, "att_background_2")
                local background3    = CSResourceMgr.seekNodeByName(item, "att_background_3")
                local labelAttrTitle = CSResourceMgr.seekNodeByName(item, "attr_text")
                local labelCurAttr   = CSResourceMgr.seekNodeByName(item, "attr_num")
                local labelNextAttr  = CSResourceMgr.seekNodeByName(item, "next_attr_num")

                item:setColor(spriteColor[1])
                background1:setColor(spriteColor[2])
                background2:setColor(spriteColor[2])
                background3:setColor(spriteColor[2])

                CSResourceMgr.setLabelStringByNode(labelAttrTitle,  attrTitle[i] , nil, 1, 90)
                CSResourceMgr.setLabelStringByNode(labelCurAttr,    num1[i]      , nil, 1, 129)
                CSResourceMgr.setLabelStringByNode(labelNextAttr,   num2[i]      , nil, 1, 129)
                CSResourceMgr.setLabelColorByNode(labelAttrTitle,   labelColor[5])
                CSResourceMgr.setLabelColorByNode(labelCurAttr,     labelColor[5])
                CSResourceMgr.setLabelColorByNode(labelNextAttr,    labelColor[13])

                list:pushBackCustomItem(item)
                item:setVisible(true)
                item:setScaleY(0)
                transition.scaleTo(item, {scale=1, time=0.1})

                if showAttrAdd and (showAttrAdd == true) and (petInfo.Stage < math.floor(pokemonInfo.topLevel / 2)) then
                    local addNum1 = PetEducationMgr.calPetAttrs(pokemonInfo, petInfo, yokeValues, yokeRates, nil, petInfo.Stage-1)
                    local addNum2 = PetEducationMgr.calPetAttrs(pokemonInfo, petInfo, yokeValues, yokeRates)

                    local textNode = CSResourceMgr.seekNodeByName(item, "content")
                    textNode:setPositionY(20)
                    local scale1    = cc.ScaleBy:create(0.15, 2)
                    local scale2    = cc.ScaleBy:create(0.1, 0.5)
                    local action1   = cc.MoveBy:create(0.1, cc.p(0, 0))
                    local action2   = cc.MoveBy:create(0.5, cc.p(0, 10))
                    local fade2     = cc.FadeOut:create(1.1)
                    CSResourceMgr.setLabelStringByNode(textNode, "+"..addNum2[i]-addNum1[i])
                    CSResourceMgr.setLabelColorByNode(textNode, labelColor[13])
                    textNode:runAction(cc.Sequence:create(scale1,scale2,action1,action2))
                    textNode:runAction(fade2)
                end
            end,0.02*i)
        end)
    end
    UnblockLoader.load(funcTable, "strengthenPageList")
end

function PetEducationMgr.starupPageInit()
    --tab 3
end

function PetEducationMgr.getStarNodeByStarLv(starLevel)
    return CSResourceMgr.getNodeByName(resName_base, "star"..starLevel)
end

function PetEducationMgr.getStarUpEffectNode()
    return CSResourceMgr.getNodeByName(resName_base, "starNode")
end

--羁绊
function PetEducationMgr.petchainInit()
    --tab 6
    local funcTable = {PetEducationMgr.refreshFetters}
    UnblockLoader.load(funcTable, LoaderTag[6])

    local list = CSResourceMgr.getNodeByName(tabResName[6], "list")
    local bg = CSResourceMgr.getNodeByName(tabResName[6], "bg")
    local diff = CocosModuleMgr.getScreenSizeDiff() > 0 and CocosModuleMgr.getScreenSizeDiff() or 0
    ViewMgrUtils.vFitSetPos(diff, {list})
    ViewMgrUtils.vFitStretch(diff, {list})
    ViewMgrUtils.vFitSetPos(-diff, {bg})
end

--羁绊菜单(点击已绑定羁绊的宠物调出)
function PetEducationMgr.showYokeMenu(mainPetObjID, yokedPetObjID, parent, node, openPetYokeViewFunc)
    local menuParent = CSResourceMgr.getNodeByName(tabResName[6], "menu")
    menu = menuParent:clone()
    local btn = CSResourceMgr.getNodeByName(tabResName[6], "btn")
    local btnEducation   = CSResourceMgr.seekNodeByName(menu, "btnEducation")
    local btnExchange    = CSResourceMgr.seekNodeByName(menu, "btnExchange")
    local labelEducation = CSResourceMgr.seekNodeByName(btnEducation, "str")
    local labelExchange  = CSResourceMgr.seekNodeByName(btnExchange,  "str")
    CSResourceMgr.setLabelStringByNode(labelEducation, "train162", {r=0,g=0,b=0,a=255,w=1,s=1})
    CSResourceMgr.setLabelStringByNode(labelExchange,  "train163", {r=0,g=0,b=0,a=255,w=1,s=1})

    menu:removeFromParent()
    menu:addTo(SceneMgr.getRunningScene)
    local function setMenuState(visible)
        menu:setVisible(visible)
        btn:setVisible(visible)
    end
    setMenuState(true)
    local size = cc.Director:getInstance():getOpenGLView():getViewPortRect()
    local worldPos = parent:convertToWorldSpace(cc.p(node:getPositionX(), node:getPositionY() - 110))

    menu:setPosition(worldPos.x, worldPos.y)
    menu:zorder(100)
    CSResourceMgr.clickEventBindingByNode(btnEducation, function ()
        setMenuState(false)
        PetQuickViewMgr.show(SceneMgr.getRunningScene, yokedPetObjID, function ()
            PetEducationMgr.showPet(mainPetObjID)
            PetEducationMgr.refreshFetters()
        end)
    end)
    CSResourceMgr.clickEventBindingByNode(btnExchange, function ()
        setMenuState(false)
        openPetYokeViewFunc()
    end)
    CSResourceMgr.clickEventBindingByNode(btn, function ()
        setMenuState(false)
    end)
end


function PetEducationMgr.refreshFetters()
    local petInfo      = PokemonInfo.getPetInfoByObjID(petInfo.objID)
    local list         = CSResourceMgr.getNodeByName(tabResName[6], "list")
    local btn          = CSResourceMgr.getNodeByName(tabResName[6], "btn")
    local bg           = CSResourceMgr.getNodeByName(tabResName[6], "bg")
    local panel1       = CSResourceMgr.getNodeByName(tabResName[6], "panel1")
    local item         = CSResourceMgr.getNodeByName(tabResName[6], "pet_info")
    list:removeAllItems()
    btn:setVisible(false)

    local panelNode1 = {}
    local index = 1
    local pokeID       = petInfo.pokeID
    local pokemonInfo  = PokemonInfo.getPokemonInfoByID(pokeID)
    local yokeVec      = pokemonInfo.yokeVec--羁绊列表

    for k,v in pairs(yokeVec) do
        panelNode1[index] = panel1:clone()
        panelNode1[index]:setVisible(true)
        list:pushBackCustomItem(panelNode1[index])

        local background2 = CSResourceMgr.seekNodeByName(panelNode1[index], "background2")
        local background3 = CSResourceMgr.seekNodeByName(panelNode1[index], "background3")
        local background4 = CSResourceMgr.seekNodeByName(panelNode1[index], "background4")
        local labelNext   = CSResourceMgr.seekNodeByName(panelNode1[index], "label_next")
        local labelMax    = CSResourceMgr.seekNodeByName(panelNode1[index], "label_max")
        local labelTop    = CSResourceMgr.seekNodeByName(panelNode1[index], "label_top")
        local labelTopR   = CSResourceMgr.seekNodeByName(panelNode1[index], "label_top_right")
        local labelBottom = CSResourceMgr.seekNodeByName(panelNode1[index], "label_bottom")
        local spriteStar  = CSResourceMgr.seekNodeByName(panelNode1[index], "need_star")
        local labelUnlockLv = CSResourceMgr.seekNodeByName(panelNode1[index], "unlock_lv")

        local starUnlockLv = SystemInfo.getGlobalConfigAddInfoByID(74).values[1]
        local unlockUpNum  = SystemInfo.getGlobalConfigAddInfoByID(74).values[2]
        local isLocked = math.floor((petInfo.level - starUnlockLv) / unlockUpNum) + 1 < index
        local unlockLv = (index - 1) * unlockUpNum + starUnlockLv
        local lockText = CocosModuleMgr.createStringWithFormat({"train183", unlockLv})
        labelUnlockLv:setVisible(isLocked == true)
        CSResourceMgr.setLabelStringByNode(labelUnlockLv, lockText, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 90)
        CSResourceMgr.setLabelColorByNode(labelUnlockLv, {r=87,g=126,b=165,a=255})

        background3:setColor({r=5,g=23,b=43,a=255})
        background4:setColor({r=17,g=35,b=54,a=255})
        background2:setOpacity(204)
        background3:setOpacity(230)
        background4:setOpacity(230)

        local yokeInfo = PokemonInfo.getYokeInfoByID(v)--pets,yokeName,attribType,rarePoint
        local list2 = CSResourceMgr.seekNodeByName(panelNode1[index], "list2")
        local diffX = 120
        local diffY = 120
        local petPos = 1
        local needYokePetsCnt = PetEducationMgr.getTableLength(yokeInfo.pets)
        for j = 1, needYokePetsCnt do
            local v1 = yokeInfo.pets[j]
            local itemNode = item:clone()
            itemNode:clone()
            itemNode:setVisible(true)

            local petDiban = CSResourceMgr.seekNodeByName(itemNode, "pet_diban")
            local petIcon  = CSResourceMgr.seekNodeByName(itemNode, "pet_icon")
            local petAdd   = CSResourceMgr.seekNodeByName(itemNode, "pet_add")
            local petName  = CSResourceMgr.seekNodeByName(itemNode, "pet_name")
            local petStar  = CSResourceMgr.seekNodeByName(itemNode, "pet_star")

            local needPokeInfo = PokemonInfo.getPokemonInfoByID(v1)
            local needRare     = needPokeInfo.rarePoint
            local needIcon    = PokemonInfo.getPokemonIconByID(v1)
            local needName    = LuaSqlite.getLanguageByKey(needPokeInfo.name)
            local isYoked = PetEducationMgr.getPetHasYoke(petInfo, v, j)
            local nameC   = isYoked and PokemonInfo.COLOR[needRare] or PokemonInfo.DARKCOLOR[needRare]
            local needStarCnt = 0

            local yokedPetObjID = 0
            if isYoked == true then--绑定的宠物名字和星数
                yokedPetObjID = PetEducationMgr.getYokedPetObjID(petInfo, v, j)
                local yokedPetInfo = PokemonInfo.getPetInfoByObjID(yokedPetObjID)
                needName = PetEducationMgr.getPetName(yokedPetInfo)
                needStarCnt = yokedPetInfo.star
            end
            
            local diffX    = 18
            local starPosX = petStar:getPositionX()
            local midIndex = needStarCnt / 2 + 0.5

            for i = 1, needStarCnt do
                local starNode = petStar:clone()
                starNode:addTo(itemNode)
                starNode:setPositionX(diffX * (i-midIndex) + starPosX)
                starNode:setVisible(true)
            end

            petAdd:setVisible(not isYoked)
            petIcon:setColor(isYoked and {r=255,g=255,b=255,a=255} or {r=77,g=77,b=77,a=255})
            petDiban:setColor(isYoked and {r=255,g=255,b=255,a=255} or {r=77,g=77,b=77,a=255})
            CSResourceMgr.setSpriteTextureByNode(petDiban, "Pet/petcards/stage/"..needRare..".png")
            CSResourceMgr.setSpriteTextureByNode(petIcon,  needIcon)
            CSResourceMgr.setLabelStringByNode(petName, needName, {r=0,g=0,b=0,a=255,w=1,s=1})
            CSResourceMgr.setLabelColorByNode(petName, nameC)

            local diffX2 = 140
            itemNode:addTo(list2)
            itemNode:setPosition(80 + diffX2 * (petPos - 1), 82)

            local function showPetYokeView()
                PetCommonListViewMgr.showPetYokeList(SceneMgr.getRunningScene, petInfo, v1, v, j-1, isYoked)
            end
            CSResourceMgr.clickEventBindingByNode(itemNode, function ()
                if isLocked == true then
                    StandardTipsMgr.show(1, "train184") 
                else
                    local petInfo = PokemonInfo.getPetInfoByObjID(petInfo.objID)
                    if petInfo.yoke and petInfo.yoke.bindTo then
                        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "train174")
                    else
                        if isYoked == true then
                            PetEducationMgr.showYokeMenu(petInfo.objID, yokedPetObjID, list2, itemNode, showPetYokeView)
                        else
                            local showPets = PetCommonListViewMgr.getYokePetTable(petInfo, v1, v, j-1, isYoked)
                            if PetEducationMgr.getTableLength(showPets) <= 0 then
                                PetGetViewMgr.show(SceneMgr.getRunningScene, v1)
                            else
                                PetCommonListViewMgr.showPetYokeList(SceneMgr.getRunningScene, petInfo, v1, v, j-1, isYoked)
                            end
                        end
                    end
                end
            end, 3)
            petPos = petPos + 1
        end

        local isYokeActive = PetEducationMgr.getPetYokeCnt(petInfo, v, yokeInfo.pets) == needYokePetsCnt
        CSResourceMgr.setLabelStringByNode(labelBottom, "train164", {r=0,g=0,b=0,a=255,w=1,s=1})
        CSResourceMgr.setLabelColorByNode(labelBottom, {r=87,g=126,b=165,a=255})

        --下一级星数
        local curPetStarCnt = PetEducationMgr.getNextYokeNeedStars(petInfo, v, needYokePetsCnt) - 1
        local nextYokeNeedStarCnt = PetEducationMgr.getNextYokeNeedStars(petInfo, v, needYokePetsCnt)
        local isMax = nextYokeNeedStarCnt > 5
        nextYokeNeedStarCnt = isMax == true and nextYokeNeedStarCnt - 1 or nextYokeNeedStarCnt
        if isMax == false then
            for i = 1, nextYokeNeedStarCnt do
                local starNode = spriteStar:clone()
                starNode:addTo(panelNode1[index])
                starNode:setPositionX(labelBottom:getPositionX() + labelBottom:getBoundingBox().width + 20 * (i-1) + 20)
                starNode:setVisible(true)
            end
        end
        local nowYokeAttrs = PetEducationMgr.getYokeStrName(petInfo, v, curPetStarCnt, yokeInfo.pets)
        local nextYokeAttrs = isMax == true and "train175" or LuaSqlite.getLanguageByKey("train165")..PetEducationMgr.getYokeStrName(petInfo, v, nextYokeNeedStarCnt, yokeInfo.pets)
        local yokeTitleColor = isYokeActive == true and PokemonInfo.COLOR[yokeInfo.rarePoint] or PokemonInfo.DARKCOLOR[yokeInfo.rarePoint]
        CSResourceMgr.setLabelStringByNode(labelTop, LuaSqlite.getLanguageByKey(yokeInfo.yokeName).."：", {r=0,g=0,b=0,a=255,w=1,s=1})
        CSResourceMgr.setLabelStringByNode(labelTopR, nowYokeAttrs)
        CSResourceMgr.setLabelStringByNode(labelNext, nextYokeAttrs)
        CSResourceMgr.setLabelStringByNode(labelMax, LuaSqlite.getLanguageByKey("train214")..PetEducationMgr.getYokeStrName(petInfo, v, 5, yokeInfo.pets))
        CSResourceMgr.setLabelColorByNode(labelTop, PokemonInfo.COLOR[yokeInfo.rarePoint])
        CSResourceMgr.setLabelColorByNode(labelTopR, yokeTitleColor)
        CSResourceMgr.setLabelColorByNode(labelNext, isMax == true and labelColor[5] or {r=87,g=126,b=165,a=255})
        CSResourceMgr.setLabelColorByNode(labelMax, labelColor[5])
        labelNext:setPositionX(isMax == true and 280 or 30)
        labelMax:setVisible(isMax ~= true)
        labelTopR:setPositionX(labelTop:getPositionX() + labelTop:getBoundingBox().width)
        labelBottom:setVisible(isMax ~= true)

        index = index + 1
    end
    if index == 1 then
        list:setVisible(false)
        bg:setVisible(false)
        PetEducationMgr.showMaxWithTab(6)
    end
end

function PetEducationMgr.sendAddYokePet(objID, yokeID, yokeCellID, assistObjID)
    NetInterface.sendWithBlock("GC_ADDYOKEPET_ACK", function()
        local PetEducationSend = require("src/Net/Send/PetEducationSend.lua")
        PetEducationSend.sendCG_AddYokePet_Req({
            objID       = objID,
            yokeID      = yokeID,
            yokeCellID  = yokeCellID,
            assistObjID = assistObjID,
        })
    end, function()
        GameAudio.playUISound("success")
        PetEducationMgr.showPet(petInfo.objID)
        PetEducationMgr.showEvolutionRedPointByPetInfo(petInfo)
        -- DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,1,"绑定羁绊成功")
    end, function()
        -- DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,1,"绑定羁绊错误")
    end)
end

function PetEducationMgr.sendDelYokePet(objID, yokeID, yokeCellID)
    NetInterface.sendWithBlock("GC_DELYOKEPET_ACK", function()
        local PetEducationSend = require("src/Net/Send/PetEducationSend.lua")
        PetEducationSend.sendCG_DelYokePet_Req({
            objID       = objID,
            yokeID      = yokeID,
            yokeCellID  = yokeCellID,
        })
    end, function()
        PetEducationMgr.showPet(petInfo.objID)
        PetEducationMgr.refreshFetters()
        PetListMgr.setUpdateFlag("yoke")
        PetEducationMgr.showEvolutionRedPointByPetInfo(petInfo)
        -- DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,1,"删除羁绊成功")
    end, function()
        -- DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,1,"删除羁绊错误")
    end)
end

function PetEducationMgr.sendChangeYokePet(objID, yokeID, yokeCellID, assistObjID)
    NetInterface.sendWithBlock("GC_CHANGEYOKEPET_ACK", function()
        local PetEducationSend = require("src/Net/Send/PetEducationSend.lua")
        PetEducationSend.sendCG_ChangeYokePet_Req({
            objID       = objID,
            yokeID      = yokeID,
            yokeCellID  = yokeCellID,
            assistObjID = assistObjID,
        })
    end, function()
        -- DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,1,"更换羁绊成功")
    end, function()
        -- DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,1,"更换羁绊错误")
    end)
end

function PetEducationMgr.updatePetYokeInfo(petsYoke)
    local cjson = require("cjson")
    local tbl = cjson.decode(petsYoke)
    for k,v in pairs(tbl) do
        PokemonInfo.setPetYokeInfoByObjID(k, v)
    end
    PetEducationMgr.showPet(petInfo.objID)
    PetEducationMgr.refreshFetters()
    PetListMgr.setUpdateFlag("yoke")
end

function PetEducationMgr.refreshPetEducation(tbl)
    local baseLayer = CSResourceMgr.getCsbObj(resName_base)
    if tbl.objID ~= petInfo.objID then return end
    if baseLayer then
        local objIDList = clone(PokemonInfo.getPetArmy(PetFormationMgr.getCurTab()))
        -- for k,v in pairs(PokemonInfo.getPetHelpArmy()) do
        --     table.insert(objIDList, v)
        -- end
        for k,v in pairs(objIDList) do
            if tbl.objID == v then
                PetEducationMgr.showStrengthRedPointByPetInfo(tbl)
                PetEducationMgr.showEvolutionRedPointByPetInfo(tbl)
                PetEducationMgr.showPetFeedRedPoint(tbl)
                PetEducationMgr.showPetStarUpRedPoint(tbl)
                return
            end
        end
    end
end

function PetEducationMgr.setBGVisible(visible)
    local bg = CSResourceMgr.getNodeByName(resName_base, "bg")
    bg:setVisible(visible)
end

function PetEducationMgr.showEducationRedPoint()--打开养成显示
    if CSResourceMgr.getCsbObj("Pet/Education/PetsEducationNew.csb") then
        local objID = petInfo.objID
        PetEducationMgr.showStrengthRedPointByObjID(objID)
        PetEducationMgr.showEvolutionRedPointByObjID(objID)
        PetEducationMgr.showFeedRedPointByObjID(objID)
        PetEducationMgr.showStarUpRedPointByObjID(objID)
    end
end

function PetEducationMgr.setRedPointStateByIndex(index, state)
    local parent = CSResourceMgr.getNodeByName(resName_base, "tab"..index)
    local redPoint = CSResourceMgr.seekNodeByName(parent, "redPoint")
    redPoint:setVisible(state)
end

function PetEducationMgr.refreshUIAfterCallBack()
    if petInfo and CSResourceMgr.getCsbObj(resName_base) then
        if CSResourceMgr.getCsbObj(tabResName[2]) then
            PetEducationMgr.refreshStrengthPage(petInfo)
        elseif CSResourceMgr.getCsbObj(tabResName[4]) then
            PetEducationMgr.refreshEvolutionBottomPage(petInfo)
        end
        PetQuickViewMgr.refreshUI()
    end
end

return PetEducationMgr