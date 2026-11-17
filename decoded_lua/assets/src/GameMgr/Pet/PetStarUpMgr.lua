local PetStarUpMgr = {}

local resName = ""
local resNameC = ""
local needPetNode = {}
local selectedPetIndex = 0
local selectedPetsInfo = {}
local needCostPetCount = 0
local skillNode = {}
local needPetNameP = ""
local needPetIconP = ""
PetStarUpMgr.haveResCount = 0
PetStarUpMgr.needResCount = 0
PetStarUpMgr.needStageLv  = 0
PetStarUpMgr.perStage     = 0
PetStarUpMgr.LABLE_OUTLINE_THICK = 1
PetStarUpMgr.NORMAL_SKILL_COUNT = 4
PetStarUpMgr.MAX_SKILL_COUNT = 5
local textColor = {
    {r=4,g=189,b=230,a=255},    --蓝色1
    {r=212,g=101,b=236,a=255},  --紫色2
    {r=255,g=252,b=0,a=255},    --黄色3
    {r=255,g=249,b=159,a=255},  --米黄4
    {r=0,g=255,b=16,a=255},     --绿色5
    {r=255,g=0,b=0,a=255},      --红色6
    {r=0,g=0,b=0,a=255},        --黑色7
    {r=255,g=255,b=255,a=255},  --白色8
    {r=204,g=84,b=5,a=255},     --橙色9
    {r=7,g=205,b=255,a=255},    --淡蓝10
    {r=254,g=243,b=57,a=255},   --11
    {r=144,g=238,b=255,a=255},  --12
    {r=227,g=233,b=255,a=255},  --13
}
local skillColor = {
    {r=255,g=255,b=255,a=255},
    {r=0,g=0,b=0,a=255},
    {r=26,g=37,b=48,a=255},
    {r=144,g=238,b=255,a=255},  --被动技4
    {r=60,g=220,b=109,a=255},   --援助技5
    {r=205,g=229,b=255,a=255},  --解锁技能6
    {r=80,g=97,b=115,a=255},    --未解锁技能7
    {r=212,g=212,b=212,a=255},  --未解锁提示8
    {r=97,g=119,b=138,a=255},      --9
    {r=77,g=77,b=77,a=255},     --10
}
local paSkillColor = {9,1,5,2}
local outlineColor = {
    {r=0,g=0,b=0,a=255},
    {r=255,g=255,b=255,a=255},
    {r=209,g=138,b=0,a=255},
    {r=38,g=54,b=76,a=255},
}
local starText = {
    "1","2","3","4","5",
}
local skillBackGroundPath = {
    "UI/CommonFiles/fight_skill_base_01.png",
    "UI/CommonFiles/fight_skill_base_gray.png",
    "UI/CommonFiles/fight_assistance_skill_base.png",
    "UI/CommonFiles/fight_assistance_skill_base_gray.png",
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
    "UI/CommonFiles/skill_aid_base_orange_01.png",
}

local irareString = {
    [0] = "Pet/Education/c.png",
    [1] = "Pet/Education/b.png",
    [2] = "Pet/Education/a.png",
    [3] = "Pet/Education/s.png",
    [4] = "Pet/Education/2s.png",
}

function PetStarUpMgr.Init()
    print("PetStarUpMgr初始化")
    resName = "Pet/Education/StarupPageNew.csb"
    resNameC = "Pet/Education/StarupPageNewC.csb"
    needPetNode = {}
    selectedPetIndex = 0
    selectedPetsInfo = {}
    needCostPetCount = 0
    PetStarUpMgr.haveResCount = 0
    PetStarUpMgr.needResCount = 0
    PetStarUpMgr.needStageLv  = 0
    PetStarUpMgr.perStage     = 0
end

function PetStarUpMgr.show(scene, objID)
    print("PetStarUpMgr.show()")
    -- ViewMgrUtils.WrapViewMgr(PetStarUpMgr)
    local curSelectSkillIndex = 0
    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, resName)
        local layerC = CSResourceMgr.createRes(scene, resNameC)
        CSResourceMgr.setFullScreen(resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        layer:setOpacity(0)
        CSResourceMgr.setFullScreen(resNameC)
        layerC:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        layerC:setOpacity(0)

        local setPosTable = {
            CSResourceMgr.getNodeByName(resName, "panel_1"),
            CSResourceMgr.getNodeByName(resName, {"panel_2","background_1"}),
            layerC,
        }
        local setDefPosTable = {
            CSResourceMgr.getNodeByName(resName, "panel_3"),
        }
        local stretchTable = {
            CSResourceMgr.getNodeByName(resName, {"panel_2","background_1"}),
        }
        local diff = CocosModuleMgr.getScreenSizeDiff() > 0 and CocosModuleMgr.getScreenSizeDiff() or 0
        ViewMgrUtils.vFitSetPos(diff,  setPosTable)
        ViewMgrUtils.vFitSetPos(-diff, setDefPosTable)
        ViewMgrUtils.vFitStretch(diff, stretchTable)

        transition.fadeIn(layer,  {time=0.5})
        transition.fadeIn(layerC, {time=0.5})
    end
    local function setPanelVisible(visible)
        for i=1,3 do
            local panelA = CSResourceMgr.getNodeByName(resName, "panel_"..i)
            panelA:setVisible(visible)
        end
        local panelB = CSResourceMgr.getNodeByName(resNameC, "panel")
        panelB:setVisible(visible)
    end
    local function loadUI()
        local spriteSkillIcon = {}
        local backgroundSkill = {}
        local spriteSelectIcon = {}
        local labelSkillName = {}
        local spriteAddSkill = {}
        local btnSkill = {}
        local petInfo = PokemonInfo.getPetInfoByObjID(objID)
        local petStarupInfo = PokemonInfo.getPetStarUpInfoByID(petInfo.pokeID)
        -- local petSkills = petInfo.skills--主动技能
        local paSkills = petInfo.paSkills--被动技能
        local sortedSkillBackground = {}
        local helpSkillComeOut = false
        local helpSkillIndex = 0
        local sortedSkillIndex = {}
        local function SetSkillInfo()
            PetStarUpMgr.refreshSkills(petInfo)
            -- local background = CSResourceMgr.getNodeByName(resNameC, "panel")
            -- PetStarUpMgr.addPosNode(background)
        end
        local function SetAttAddInfo()
            local petStars = petInfo.star
            local attAddNum = SystemInfo.getGlobalConfigAddInfoByID(12000).values[1]

            local blockAttLeft = CSResourceMgr.getNodeByName(resName, "att_left")
            blockAttLeft:setPositionX(140)

            local bgLeft = CSResourceMgr.seekNodeByName(blockAttLeft, "now_background")
            local blockAttRight = CSResourceMgr.getNodeByName(resName, "att_rigth")

            local labelNow = CSResourceMgr.getNodeByName(resName, "now_label")
            CSResourceMgr.setLabelStringByNode(labelNow, "train33", nil, 1, 168)
            CSResourceMgr.setLabelColorByNode(labelNow, textColor[10])
            labelNow:enableOutline(outlineColor[1], PetStarUpMgr.LABLE_OUTLINE_THICK)
            -- labelNow:setPositionX(100)

            local labelAttAddLeft1 = CSResourceMgr.getNodeByName(resName, "att_add_left1")
            CSResourceMgr.setLabelStringByNode(labelAttAddLeft1, "train35", nil, 1, 144)
            CSResourceMgr.setLabelColorByNode(labelAttAddLeft1, textColor[8])
            labelAttAddLeft1:enableOutline(outlineColor[1], PetStarUpMgr.LABLE_OUTLINE_THICK)

            local labelAttAddRight1 = CSResourceMgr.getNodeByName(resName, "att_add_right1")
            CSResourceMgr.setLabelStringByNode(labelAttAddRight1, "+"..attAddNum*petStars.."%")
            CSResourceMgr.setLabelColorByNode(labelAttAddRight1, textColor[11])
            labelAttAddRight1:enableOutline(outlineColor[1], PetStarUpMgr.LABLE_OUTLINE_THICK)

            local labelNext = CSResourceMgr.getNodeByName(resName, "next_label")
            CSResourceMgr.setLabelStringByNode(labelNext, "train34", nil, 1, 168)
            CSResourceMgr.setLabelColorByNode(labelNext, textColor[10])
            labelNext:enableOutline(outlineColor[1], PetStarUpMgr.LABLE_OUTLINE_THICK)
            
            local labelAttAddLeft2 = CSResourceMgr.getNodeByName(resName, "att_add_left2")
            CSResourceMgr.setLabelStringByNode(labelAttAddLeft2, "train35", nil, 1, 144)
            CSResourceMgr.setLabelColorByNode(labelAttAddLeft2, textColor[8])
            labelAttAddLeft2:enableOutline(outlineColor[1], PetStarUpMgr.LABLE_OUTLINE_THICK)

            local labelAttAddRight2 = CSResourceMgr.getNodeByName(resName, "att_add_right2")
            CSResourceMgr.setLabelStringByNode(labelAttAddRight2, "+"..attAddNum*(petStars+1).."%")
            CSResourceMgr.setLabelColorByNode(labelAttAddRight2, textColor[11])
            labelAttAddRight2:enableOutline(outlineColor[1], PetStarUpMgr.LABLE_OUTLINE_THICK)

            if petStars == PetStarUpMgr.MAX_SKILL_COUNT or PetEducationMgr.getResPetByPokeID(petInfo.pokeID) == true then
                local spriteArrow= CSResourceMgr.getNodeByName(resName, "arrow")
                spriteArrow:setVisible(false)
                labelNext:setVisible(false)
                labelAttAddLeft2:setVisible(false)
                labelAttAddRight2:setVisible(false)
                blockAttLeft:setPositionX(335)
                blockAttRight:setVisible(false)
                CSResourceMgr.setLabelStringByNode(labelNow, "train44")
            end

            if PetEducationMgr.getResPetByPokeID(petInfo.pokeID) == true then
                blockAttLeft:setPositionY(260)
                bgLeft:setVisible(false)
                labelAttAddLeft1:setVisible(false)
                labelAttAddRight1:setVisible(false)
            end
        end
        local function SetNeedPetList()
            local bottom        = CSResourceMgr.getNodeByName(resName, {"panel_3","bottom"})
            local title         = CSResourceMgr.seekNodeByName(bottom, "res_need_name")
            local needLv        = CSResourceMgr.seekNodeByName(bottom, "res_need_lv")
            local needLvR       = CSResourceMgr.seekNodeByName(bottom, "res_need_lv_label")
            local btnStarup     = CSResourceMgr.seekNodeByName(bottom, "btn_strength")
            local strStrength   = CSResourceMgr.seekNodeByName(bottom, "str_stength")
            local resCount      = CSResourceMgr.seekNodeByName(bottom, "res_count")

            local resTable = {
                CSResourceMgr.seekNodeByName(bottom, "background11"),
                CSResourceMgr.seekNodeByName(bottom, "res_background1"),
                CSResourceMgr.seekNodeByName(bottom, "res_btn_add"),
                CSResourceMgr.seekNodeByName(bottom, "res_count"),
            }
            for k,v in pairs(resTable) do
                v:setVisible(false)
            end

            CSResourceMgr.setLabelStringByNode(title, "train27")
            CSResourceMgr.setLabelStringByNode(strStrength, "train5", {r=0,g=0,b=0,a=255,w=1,s=1})
            CSResourceMgr.setLabelStringByNode(resCount, CharInfo.getGCash(), {r=0,g=0,b=0,a=255,w=1,s=1})
            CSResourceMgr.setLabelColorByNode(title, textColor[12])
            CSResourceMgr.setLabelColorByNode(strStrength, textColor[13])

            PetStarUpMgr.setBtnBGEnable(false)
            local maxStar = petStarupInfo.maxStar
            if petInfo.star == maxStar then
                CSResourceMgr.setButtonEnabledByNode(btnStarup, false)
                return
            end
            local havePetCount  = 0
            local needStrength  = petStarupInfo.limit[petInfo.star+1]
            local needPetID     = petStarupInfo.costPet[petInfo.star+1]
            local needPetCount  = petStarupInfo.num2[petInfo.star+1]
            local needPetInfo   = PokemonInfo.getPokemonInfoByID(needPetID)
            local needPetIcon   = needPetInfo.icon
            local needPetName   = needPetInfo.name
            local needPetQuality= needPetInfo.rarePoint
            needCostPetCount    = needPetCount
            local petNameColor  = PokemonInfo.COLOR[needPetQuality]
            needPetNameP = needPetName
            needPetIconP = needPetIcon

            PetStarUpMgr.needStageLv  = needStrength
            PetStarUpMgr.perStage     = petInfo.Stage

            CSResourceMgr.setLabelStringByNode(needLv, "train95")
            CSResourceMgr.setLabelStringByNode(needLvR, "+"..needStrength)
            CSResourceMgr.setLabelColorByNode(needLv, textColor[12])
            CSResourceMgr.setLabelColorByNode(needLvR, (petInfo.Stage >= needStrength) and skillColor[1] or textColor[6])
            needLv:setPositionX(needLvR:getPositionX() - needLvR:getContentSize().width - 2)

            local enable = (needPetCount <= PetStarUpMgr.getTableLength(selectedPetsInfo)) and (petInfo.Stage >= needStrength)
            CSResourceMgr.setButtonEnabledByNode(btnStarup, enable)
            CSResourceMgr.clickEventBindingByNode(btnStarup, function ()
                local sendPetObjIDTable = {}
                for k,v in pairs(selectedPetsInfo) do
                    table.insert(sendPetObjIDTable, v.objID)
                end
                PetEducationMgr.perFC = petInfo.fc
                NetInterface.sendWithBlock("GC_PETSTARUP_ACK", function()
                    local PetEducationSend = require("src/Net/Send/PetEducationSend.lua")
                    PetEducationSend.sendCG_PetStarUp_Req({
                        petObjID = petInfo.objID,
                        costPetObjIDs = sendPetObjIDTable
                        })
                    end,function ()
                        PetStarUpMgr.setBtnCloseEnable(false)
                        PetStarUpMgr.setBtnBGEnable(true)
                        local function starUpCallBack()
                            PetListMgr.setUpdateFlag("rare")
                            GameAudio.playUISound("success")
                            -- print("star up success!")
                            PetStarUpMgr.Init()
                            PetStarUpMgr.show(scene, objID)
                            PetEducationMgr.starupEffect(petInfo.star, PetEducationMgr.showPet(objID))
                            PetEducationMgr.setBGVisible(false)
                            setPanelVisible(false)
                            PetStarupEffectMgr.show(SceneMgr.getRunningScene, petInfo.pokeID, petInfo.star + 1, function()
                                PetEducationMgr.setBGVisible(true)
                                PetEducationMgr.showPet(petInfo.objID)
                                setPanelVisible(true)
                                SceneMgr.getRunningScene:performWithDelay(function()
                                    PetStarUpMgr.setBtnCloseEnable(true)
                                    PetStarUpMgr.setBtnBGEnable(false)
                                    local pInfo = PokemonInfo.getPetInfoByObjID(objID)
                                    if PetEducationMgr.perFC < pInfo.fc then
                                        PetFCEffectMgr.show(SceneMgr.getRunningScene, PetEducationMgr.perFC, pInfo.fc)
                                    end
                                end, 1.3)
                            end)
                        end
                        PetStarUpMgr.playStarUpEffect(starUpCallBack)

                        local params = {}
                        params.objID = petInfo.objID
                        params.stars = petInfo.star + 1
                        TaskWatcherManager.saveCWShengXingState(params)

                        if petInfo.yoke and petInfo.yoke.bindTo then
                            PetEducationMgr.needUpdateSevenDayPetYoke = true
                        end
                    end,function ()
                        print("faild in star up!")
                    end)
            end)

            local panel = CSResourceMgr.seekNodeByName(bottom, "res_background4")
            local diban = CSResourceMgr.seekNodeByName(bottom, "btn_res")
            for k,v in pairs(panel:getChildren()) do
                panel:removeChild(v)
            end

            local needResID = petStarupInfo.costItem[petInfo.star+1]
            local needResCount = petStarupInfo.num1[petInfo.star+1]
            local haveResCount = ItemInfo.getCharItemNum(needResID)
            local itemInfo = ItemInfo.getItemInfoById(needResID)

            local showItemCount = needPetCount + 1
            needPetNode = {}
            for i = 1, showItemCount do
                needPetNode[i] = diban:clone()
                needPetNode[i]:addTo(panel)
                needPetNode[i]:setVisible(true)
                if showItemCount % 2 ~= 0 then--奇数
                    needPetNode[i]:setPosition(300 + ((i - 1) - (showItemCount - 1) / 2) * 100, 52)
                else
                    needPetNode[i]:setPosition(300 + ((i - (showItemCount / 2)) * 100 - 60), 52)
                end
                needPetNode[i]:setScale(0.85)
                local background= CSResourceMgr.seekNodeByName(needPetNode[i], "pet_background")
                local petIcon   = CSResourceMgr.seekNodeByName(needPetNode[i], "res_icon")
                local petName   = CSResourceMgr.seekNodeByName(needPetNode[i], "res_num")
                local petAdd    = CSResourceMgr.seekNodeByName(needPetNode[i], "res_add")

                if i == 1 then
                    petIcon:setVisible(true)
                    -- petIcon:setScale(0.8)
                    petAdd:setVisible(false)
                    -- CSResourceMgr.setSpriteTextureByNode(petIcon, itemInfo.icon)

                    local iNode = ItemInfo.getItemIconById(needResID, nil)
                    CSResourceMgr.setButtonTextureByNode(needPetNode[i], "empty.png","empty.png","empty.png")
                    iNode:setPosition(0, 0)
                    iNode:removeFromParent()
                    iNode:addTo(petIcon)
                    iNode:setScale(needPetNode[i]:getContentSize().width / iNode:getContentSize().width)

                    CSResourceMgr.setLabelStringByNode(petName, haveResCount.."/"..needResCount)
                    CSResourceMgr.setLabelColorByNode(petName, (haveResCount >= needResCount) and textColor[8] or textColor[6])
                    petName:enableOutline(outlineColor[1], PetStarUpMgr.LABLE_OUTLINE_THICK)
                    CSResourceMgr.clickEventBindingByNode(iNode, function ()
                        ItemInfoViewMgr.show({id = needResID}, false)
                    end)
                    PetStarUpMgr.haveResCount = haveResCount
                    PetStarUpMgr.needResCount = needResCount
                else
                    petIcon:setVisible(true)
                    petIcon:setColor({r=77,g=77,b=77})
                    petIcon:setScale(0.84)
                    local iconPath = "Pet/petcards/stage/"..needPetQuality..".png"
                    CSResourceMgr.setButtonTextureByNode(needPetNode[i], "empty.png", "empty.png", "empty.png")
                    CSResourceMgr.setSpriteTextureByNode(background, iconPath)
                    CSResourceMgr.setSpriteTextureByNode(petIcon, "Pet/PetIcon/"..needPetIcon..".png")
                    petAdd:setVisible(true)
                    CSResourceMgr.setLabelStringByNode(petName, needPetInfo.name)
                    CSResourceMgr.setLabelColorByNode(petName, petNameColor)
                    petName:enableOutline(outlineColor[1], PetStarUpMgr.LABLE_OUTLINE_THICK)
                    CSResourceMgr.clickEventBindingByNode(needPetNode[i], function ()
                        local conformTable = PetStarUpMgr.getCanStarUpPets(needPetID, petInfo.objID)
                        local conformLength = PetStarUpMgr.getTableLength(conformTable)
                        if conformLength > 0 then
                            if PetStarUpMgr.getTableLength(selectedPetsInfo) >= conformLength and selectedPetsInfo[i] == nil then
                                PetGetViewMgr.show(scene, needPetID)
                            else
                                selectedPetIndex = i
                                PetCommonListViewMgr.show(scene, petInfo, needPetID, selectedPetsInfo, selectedPetsInfo[selectedPetIndex])
                            end
                        else
                            PetGetViewMgr.show(scene, needPetID)
                        end
                    end)
                end
            end
        end

        local function loadBtn()
            local btnReset = CSResourceMgr.getNodeByName(resName, {"panel_3","btn_reset"})
            local strReset = CSResourceMgr.seekNodeByName(btnReset, "reset")
            CSResourceMgr.setButtonEnabledByNode(btnReset, petInfo.star ~= 0 and PetEducationMgr.getResPetByPokeID(petInfo.pokeID) == false)
            CSResourceMgr.setLabelStringByNode(strReset, "train22", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 80)
            CSResourceMgr.clickEventBindingByNode(btnReset, function ()
                PetStarupResetViewMgr.show(scene, objID, function ()
                    petInfo = PokemonInfo.getPetInfoByObjID(objID)
                    SetSkillInfo()
                    SetAttAddInfo()
                    SetNeedPetList()
                    loadBtn()
                end)
            end)
        end
        loadBtn()
        SetSkillInfo()
        SetAttAddInfo()
        SetNeedPetList()
    end

    local funcTable = {loadCSB, loadUI}
    UnblockLoader.load(funcTable,"PetStarUpMgr")
    -- local diff = CocosModuleMgr.getScreenSizeDiff()
    -- ViewMgrUtils.AutoFit(PetStarUpMgr,-diff)
end

function PetStarUpMgr.setBtnCloseEnable(enable)
    local btnClose = CSResourceMgr.getNodeByName("Searching/advConfirm/top_right.csb", "btn_close", "PetEducationMgr-TopRight")
    CSResourceMgr.setButtonEnabledByNode(btnClose, enable)
end

function PetStarUpMgr.setBtnBGEnable(enable)
    local btnBG = CSResourceMgr.getNodeByName(resNameC, "btn_bg")
    if btnBG then
        btnBG:setVisible(enable)
    end
end

function PetStarUpMgr.getCanStarUpPets(needPetID, objID)
    local conformTable = {}
    local petTable = PokemonInfo.getUnactivePets()
    for k,v in pairs(petTable) do
        if (v.pokeID == needPetID) and (v.objID ~= objID) and v.objID ~= 1 then
            if (not v.yoke) or (not v.yoke.bindTo and not v.yoke.yokeDetail) or (v.yoke.yokeDetail and PetEducationMgr.getTableLength(v.yoke.yokeDetail) == 0) then
                table.insert(conformTable, v)
            end
        end
    end
    local resPetList = PetStarUpMgr.getStarUpResList(needPetID)
    for k,v in pairs(petTable) do
        for k1,v1 in pairs(resPetList) do
            if v.pokeID == v1 then
                table.insert(conformTable, v)
            end
        end
    end
    return conformTable
end

function PetStarUpMgr.playStarUpEffect(callBack)
    local gap = 0.15
    for i=1,#needPetNode do
        needPetNode[i]:performWithDelay(function ()
            PetStarupEffectMgr.showStarUpLightEffect(needPetNode[i])
            GameAudio.playUISound("itemClear")
        end, i * gap)
    end
    SceneMgr.getRunningScene:performWithDelay(function ()
        if callBack then callBack() end
    end, (#needPetNode + 1) * gap + 0.5 - gap)
end

function PetStarUpMgr.onSelectCostPet(stage, petInfo)
    local petIcon   = CSResourceMgr.seekNodeByName(needPetNode[selectedPetIndex], "res_icon")
    local petAdd    = CSResourceMgr.seekNodeByName(needPetNode[selectedPetIndex], "res_add")
    local btnStarup = CSResourceMgr.getNodeByName(resName, {"panel_3","bottom","panel","btn_strength"})
    local petName   = CSResourceMgr.seekNodeByName(needPetNode[selectedPetIndex], "res_num")
    local result = false
    if not petInfo or PetStarUpMgr.getTableLength(petInfo) == 0 then
        selectedPetsInfo[selectedPetIndex] = nil
        petIcon:setColor({r=77,g=77,b=77})
        petAdd:setVisible(true)
        CSResourceMgr.setLabelStringByNode(petName, needPetNameP)
        CSResourceMgr.setSpriteTextureByNode(petIcon, "Pet/PetIcon/"..needPetIconP..".png")
    else
        selectedPetsInfo[selectedPetIndex] = petInfo
        local pInfo = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
        CSResourceMgr.setSpriteTextureByNode(petIcon, "Pet/PetIcon/"..pInfo.icon..".png")
        petIcon:setColor({r=255,g=255,b=255})
        petAdd:setVisible(false)
        CSResourceMgr.setLabelStringByNode(petName, pInfo.name)

        result = PetStarUpMgr.getTableLength(selectedPetsInfo) == needCostPetCount and 
            PetStarUpMgr.haveResCount >= PetStarUpMgr.needResCount and 
            PetStarUpMgr.perStage >= PetStarUpMgr.needStageLv
    end
    CSResourceMgr.setButtonEnabledByNode(btnStarup, result)
end

function PetStarUpMgr.refreshSkills(petInfo)
    local petInfo       = PokemonInfo.getPetInfoByObjID(petInfo.objID)
    local petStarupInfo = PokemonInfo.getPetStarUpInfoByID(petInfo.pokeID)
    local paSkills      = petInfo.paSkills--被动技能
    local petStars      = petInfo.star

    local list = CSResourceMgr.getNodeByName(resNameC, {"panel","list"})
    local item = CSResourceMgr.getNodeByName(resNameC, {"panel","btn_skill"})
    for k,v in pairs(list:getChildren()) do
        list:removeChild(v)
    end
    for i = 1, PetStarUpMgr.MAX_SKILL_COUNT do
        skillNode[i] = item:clone()
        skillNode[i]:setVisible(true)
        skillNode[i]:setPosition(skillNode[i]:getPositionX() + (i - 1) * 115 - 16, 60)
        skillNode[i]:addTo(list)
        
        local skillId   = paSkills[i]["paSkillID"]
        local skillType = paSkills[i]["paSkillType"]
        local isLocked  = (i > 2 and petStars < ((i - 2) * 2 - 1)) or PetEducationMgr.getResPetByPokeID(petInfo.pokeID) == true
        local isEmpty   = skillId == 0
        local strLock   = PetEducationMgr.getResPetByPokeID(petInfo.pokeID) == true and "" or CocosModuleMgr.createStringWithFormat({"train43", (i - 2) * 2 - 1})
        PetStarUpMgr.refreshSingleSkill(skillNode[i], isLocked, isEmpty, strLock, skillType, skillId, petInfo.objID, i)
    end
    list:setLocalZOrder(1)

    PetEducationMgr.showSkillRedPoint(skillNode, petInfo, 2)
end

function PetStarUpMgr.refreshSingleSkill(node, isLocked, isEmpty, strLock, skillType, skillId, objID, skillIndex)
    local spriteIcon    = CSResourceMgr.seekNodeByName(node, "skill_icon")
    local labelName     = CSResourceMgr.seekNodeByName(node, "skill_name")
    local spriteLock    = CSResourceMgr.seekNodeByName(node, "skill_lock")
    local labelLock     = CSResourceMgr.seekNodeByName(spriteLock, "str_lock")
    local spriteQuan    = CSResourceMgr.seekNodeByName(node, "skill_quan")
    local spriteRare    = CSResourceMgr.seekNodeByName(node, "skill_rare")
    local spriteDiban   = CSResourceMgr.seekNodeByName(node, "background")
    local labelType     = CSResourceMgr.seekNodeByName(node, "skill_type")
    local spriteBG      = CSResourceMgr.seekNodeByName(node, "skill_bg")
    local spriteType1   = CSResourceMgr.seekNodeByName(node, "skill_type1")
    local spriteLv      = CSResourceMgr.seekNodeByName(node, "skill_lv")
    local spriteType2   = CSResourceMgr.seekNodeByName(node, "skill_type2")
    local skillInfo     = (skillId == 0) and {} or PokemonInfo.getPetSkillInfoById(skillId)
    local skillIcon     = skillInfo.icon
    local skillName     = isEmpty and "train96" or skillInfo.name
    local skillRare     = skillInfo.airpower
    local typeIcon      = (skillId == 0) and {} or PokemonInfo.getSkillPlayById(skillId).typeIcon

    if skillType == 0 and skillRare == nil then
        --skillType == 0是援助技能,其他代表槽位稀有度
        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "援助技能没有配")
    end

    spriteLock:setVisible(isLocked)

    labelLock:enableOutline(outlineColor[1], PetStarUpMgr.LABLE_OUTLINE_THICK)
    CSResourceMgr.setLabelStringByNode(labelLock, strLock, nil, 1, 80)
    CSResourceMgr.setLabelColorByNode(labelLock, skillColor[8])

    labelName:enableOutline((isLocked or isEmpty) and outlineColor[1] or outlineColor[4], PetStarUpMgr.LABLE_OUTLINE_THICK)
    CSResourceMgr.setLabelStringByNode(labelName, skillName, nil, 1, 90)
    CSResourceMgr.setLabelColorByNode(labelName, (isLocked or isEmpty) and skillColor[7] or skillColor[6])

    CSResourceMgr.setSpriteTextureByNode(spriteIcon, isEmpty and "empty.png" or "Battle/skillIcon/"..skillIcon..".png")
    CSResourceMgr.setSpriteTextureByNode(spriteRare, irareString[(skillType == 0) and (skillRare - 1) or skillType])
    spriteDiban:setColor(skillColor[9])
    spriteDiban:setOpacity(102)
    spriteRare:setScale(0.5)
    spriteRare:setColor(isLocked and skillColor[10] or skillColor[1])
    node:setColor(isLocked and {r=88,g=88,b=88,a=255} or skillColor[1])
    spriteIcon:setColor(isLocked and {r=88,g=88,b=88,a=255} or skillColor[1])
    spriteBG:setColor(isLocked and {r=88,g=88,b=88,a=255} or skillColor[1])
    spriteIcon:setPositionX(skillType == 0 and 58 or 54)
    spriteIcon:setPositionY(skillType == 0 and 57 or 56)

    if skillId ~= 0 then
        local skillLv = (skillInfo.id % 5 == 0) and 5 or skillInfo.id % 5
        CSResourceMgr.setSpriteTextureByNode(spriteType1, typeIcon)
        CSResourceMgr.setSpriteTextureByNode(spriteType2, "UI/CommonFiles/"..skillInfo.skillAtt..".png")
        CSResourceMgr.setSpriteTextureByNode(spriteLv, PetSkillIconMgr.skillLvIconTable[skillLv])
        spriteType1:setColor(isLocked and {r=88,g=88,b=88,a=255} or skillColor[1])
        spriteType2:setColor(isLocked and {r=88,g=88,b=88,a=255} or skillColor[1])
        spriteLv:setColor(isLocked and {r=88,g=88,b=88,a=255} or skillColor[1])
    end

    CSResourceMgr.setLabelStringByNode(labelType, (skillType ~= 0) and "skillType6" or "skillType7", {r=0,g=0,b=0,a=255,w=1,s=1}, 1, 82)
    CSResourceMgr.setLabelColorByNode(labelType, (skillType ~= 0) and skillColor[4] or skillColor[5])
    local iconPath = ""
    local posX_1 = 51
    local posX_2 = 55
    if skillType == 0 then--援助
        iconPath = aidSkillBackGroundPath[skillRare - 1]
    else
        iconPath = passiveSkillBackGroundPath[skillType]
    end
    CSResourceMgr.setSpriteTextureByNode(spriteBG, iconPath)
    CSResourceMgr.setButtonTextureByNode(node, iconPath, iconPath, iconPath)

    -- CSResourceMgr.setButtonEnabledByNode(node, not isLocked)
    local petInfo = PokemonInfo.getPetInfoByObjID(objID)
    if PetEducationMgr.getResPetByPokeID(petInfo.pokeID) == false then
        CSResourceMgr.clickEventBindingByNode(node, function ()
            if isLocked == true then
                if isEmpty == false then
                    PetSkillViewMgr.showConciseSkillInfo(skillInfo, 2)
                end
            else
                if not isEmpty then
                    PetSkillViewMgr.showSkillInfoPage(skillInfo, skillIndex + 4, 2, objID)
                else
                    PetSkillViewMgr.showSkillExchangePage(skillInfo, skillIndex + 4, 2, objID)
                end
            end
        end)
    end
end

function PetStarUpMgr.OnSkillUpdate(data)
    local objID = data.objID
    local skillIndex = data.skillIndex + 1 - 4
    local newSkillID = data.newSkillID

    local petInfo       = PokemonInfo.getPetInfoByObjID(objID)
    local petStarupInfo = PokemonInfo.getPetStarUpInfoByID(petInfo.pokeID)
    local paSkills      = petInfo.paSkills--被动技能
    local petStars      = petInfo.star

    local skillId   = newSkillID
    local skillType = paSkills[skillIndex]["paSkillType"]
    local isLocked  = skillIndex > 2 and petStars < ((skillIndex - 2) * 2 - 1)
    local isEmpty   = skillId == 0
    local strLock   = CocosModuleMgr.createStringWithFormat({"train43", (skillIndex - 2) * 2 - 1})
    PetStarUpMgr.refreshSingleSkill(skillNode[skillIndex], isLocked, isEmpty, strLock, skillType, skillId, objID, skillIndex)

    petInfo.paSkills[skillIndex]["paSkillID"] = skillId
    PetEducationMgr.showSkillRedPoint(skillNode, petInfo, 2)
end

function PetStarUpMgr.getNeedPetNodeByIndex(index)
    return needPetNode[index]
end

function PetStarUpMgr.getTableLength(table)
    local index = 0
    for k,v in pairs(table) do
        index = index + 1
    end
    return index
end

function PetStarUpMgr.hide()
    UnblockLoader.cancel("PetStarUpMgr")

    needPetNode = {}
    selectedPetIndex = 0
    selectedPetsInfo = {}
    needCostPetCount = 0

    PetStarUpMgr.haveResCount = 0
    PetStarUpMgr.needResCount = 0
    PetStarUpMgr.needStageLv  = 0
    PetStarUpMgr.perStage     = 0

    needPetNameP = ""

    CSResourceMgr.removeCSObjectByTag(resName)
    CSResourceMgr.removeCSObjectByTag(resNameC)
end

function PetStarUpMgr.getSkillNodeByIndex(index)
    return skillNode[index]
end

function PetStarUpMgr.getPetCanStarUpByPetInfo(petInfo)
    local petStarupInfo = PokemonInfo.getPetStarUpInfoByID(petInfo.pokeID)
    local maxStar      = petStarupInfo.maxStar

    if petInfo.star == maxStar then
        return false
    end

    local needPetCount = petStarupInfo.num2[petInfo.star+1]

    local needResID    = petStarupInfo.costItem[petInfo.star+1]
    local needResCount = petStarupInfo.num1[petInfo.star+1]
    local haveResCount = ItemInfo.getCharItemNum(needResID)
    local needPetID    = petStarupInfo.costPet[petInfo.star+1]

    local needStrength  = petStarupInfo.limit[petInfo.star+1]

    if haveResCount < needResCount then
        return false
    end

    if petInfo.Stage < needStrength then
        return false
    end

    -- local petsTable = PokemonInfo.getAllPets()
    local petsTable = PokemonInfo.getUnactivePets()
    local index = 0
    for k,v in pairs(petsTable) do
        if (not v.yoke) or (not v.yoke.bindTo and not v.yoke.yokeDetail) or (v.yoke.yokeDetail and PetEducationMgr.getTableLength(v.yoke.yokeDetail) == 0) then
            if v.pokeID == needPetID then
                index = index + 1
                if index >= needPetCount then
                    return true
                end
            end
        end
    end
    return false
end

function PetStarUpMgr.getStarUpResList(pokeID)
    local petStarupInfo = PokemonInfo.getPetStarUpInfoByID(pokeID)
    local resList = {}
    local needResList = petStarupInfo.costPetComm
    for k,v in pairs(needResList) do
        table.insert(resList, v)
    end
    return resList
end

return PetStarUpMgr