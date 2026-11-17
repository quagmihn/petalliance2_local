function PetEducationMgr.showSkillRedPoint(nodeList, petInfo, skillType)
    local battlePets  = PokemonInfo.getPetArmy(PetFormationMgr.getCurTab())
    local helpPets    = PokemonInfo.getPetHelpArmy()
    local isBattlePet = false
    local isHelpPet   = false
    local index = 0
    for k,v in pairs(battlePets) do
        if v == petInfo.objID then
            isBattlePet = true
            break
        end
    end
    if isBattlePet == false then
        for k,v in pairs(helpPets) do
            if v == petInfo.objID then
                isHelpPet = true
                break
            end
        end
    end
    if isBattlePet == false and isHelpPet == false then return end

    if skillType == 1 and isBattlePet == true then
        for i = 1, 4 do
            if i < 4 then
                PetEducationMgr.createRedPoint(nodeList[i], "skill-red-point-"..i, 0.7, 0, 0, 6, -60, -60)
            else
                PetEducationMgr.createRedPoint(nodeList[i], "skill-red-point-"..i, 0.7, 0, 0, 6, -82, -55)
            end

            local skillID = petInfo.skills[i]
            if skillID ~= 0 then
                local skillInfo = PokemonInfo.getPetSkillInfoById(skillID)
                if PetEducationMgr.getSkillCanLvUp(skillInfo) == false then
                    PetEducationMgr.hideRedPoint("skill-red-point-"..i)
                end
            else
                PetEducationMgr.hideRedPoint("skill-red-point-"..i)
            end
        end
    elseif skillType == 2 then
        for i = 1, 5 do
            PetEducationMgr.createRedPoint(nodeList[i], "paSkill-red-point-"..i, 0.7, 0.68, 0.7, 6)

            local isLocked = i > 2 and petInfo.star < ((i - 2) * 2 - 1)
            local skillID = petInfo.paSkills[i]["paSkillID"]
            if skillID ~= 0 and isLocked == false then
                local skillInfo = PokemonInfo.getPetSkillInfoById(skillID)

                if isBattlePet == true then
                    if skillInfo.skill_A_Type == 7 then
                        PetEducationMgr.hideRedPoint("paSkill-red-point-"..i)
                    elseif PetEducationMgr.getSkillCanLvUp(skillInfo) == false then
                        PetEducationMgr.hideRedPoint("paSkill-red-point-"..i)
                    end
                elseif isHelpPet == true then
                    if skillInfo.skill_A_Type ~= 7 then
                        PetEducationMgr.hideRedPoint("paSkill-red-point-"..i)
                    elseif PetEducationMgr.getSkillCanLvUp(skillInfo) == false then
                        PetEducationMgr.hideRedPoint("paSkill-red-point-"..i)
                    end
                end
            else
                PetEducationMgr.hideRedPoint("paSkill-red-point-"..i)
            end
        end
    end
end

function PetEducationMgr.showPetStarUpRedPoint(petInfo)
    PetEducationMgr.setRedPointStateByIndex(3, PetStarUpMgr.getPetCanStarUpByPetInfo(petInfo) == true)
end

function PetEducationMgr.showStarUpRedPointByObjID(objID)
    local objIDList = clone(PokemonInfo.getPetArmy(PetFormationMgr.getCurTab()))
    -- for k,v in pairs(PokemonInfo.getPetHelpArmy()) do
    --     table.insert(objIDList, v)
    -- end
    for k,v in pairs(objIDList) do
        if objID == v then
            local petInfo = PokemonInfo.getPetInfoByObjID(v)
            if PetStarUpMgr.getPetCanStarUpByPetInfo(petInfo) ==  true then
                PetEducationMgr.setRedPointStateByIndex(3, true)
                return
            end
        end
    end
    PetEducationMgr.setRedPointStateByIndex(3, false)
end

--升星红点相关
function PetEducationMgr.getPetCanStarUp()
    local objIDList = clone(PokemonInfo.getPetArmy(PetFormationMgr.getCurTab()))
    -- for k,v in pairs(PokemonInfo.getPetHelpArmy()) do
    --     table.insert(objIDList, v)
    -- end
    for k,v in pairs(objIDList) do
        local petInfo = PokemonInfo.getPetInfoByObjID(v)
        if PetStarUpMgr.getPetCanStarUpByPetInfo(petInfo) ==  true then
            return true
        end
    end
    return false
end

function PetEducationMgr.showPetFeedRedPoint(petInfo)--喂食红点显示
    PetEducationMgr.setRedPointStateByIndex(1, PetFeedViewMgr.getPetCanLvUp(petInfo) == true)
end

--养成主页红点显示
function PetEducationMgr.showFeedRedPointByObjID(objID)
    local objIDList = clone(PokemonInfo.getPetArmy(PetFormationMgr.getCurTab()))
    -- for k,v in pairs(PokemonInfo.getPetHelpArmy()) do
    --     table.insert(objIDList, v)
    -- end
    for k,v in pairs(objIDList) do
        if objID == v then
            local petInfo = PokemonInfo.getPetInfoByObjID(v)
            if PetFeedViewMgr.getPetCanLvUp(petInfo) ==  true then
                PetEducationMgr.setRedPointStateByIndex(1, true)
                return
            end
        end
    end
    PetEducationMgr.setRedPointStateByIndex(1, false)
end

--喂食红点相关
function PetEducationMgr.getPetCanFeed()--有没有可喂食的宠物
    local objIDList = clone(PokemonInfo.getPetArmy(PetFormationMgr.getCurTab()))
    -- for k,v in pairs(PokemonInfo.getPetHelpArmy()) do
    --     table.insert(objIDList, v)
    -- end
    for k,v in pairs(objIDList) do
        local petInfo = PokemonInfo.getPetInfoByObjID(v)
        if PetFeedViewMgr.getPetCanLvUp(petInfo) ==  true then
            return true
        end
    end
    return false
end

local redPointNameTable = {} --红点缓存
function PetEducationMgr.createRedPoint(node, tag, scale, rateX, rateY, localZorder, posX, posY)
    if node == nil then
        return
    end
    if not posX then posX = 0 end
    if not posY then posY = 0 end
    local res = "UI/Effect/redPoint.csb"
    local size = 128
    local redPoint = CSResourceMgr.createRes(node, res, tag)

    local size = node:getContentSize()

    redPoint:setAnchorPoint(0.5, 0.5)
    redPoint:setPosition(size.width * rateX + posX, size.height * rateY + posY)
    redPoint:setScale(scale and scale or 1)
    if localZorder then
        redPoint:setLocalZOrder(localZorder)
    end

    table.insert(redPointNameTable,tag)
end

function PetEducationMgr.removeRedPoint(tag)
    local res = "UI/Effect/redPoint.csb"
    local redPoint = CSResourceMgr.getCsbObj(res, tag)
    if redPoint then
        CSResourceMgr.removeCSObjectByTag(res, tag)
    end
end

function PetEducationMgr.hideRedPoint(tag)
    local res = "UI/Effect/redPoint.csb"
    local redPoint = CSResourceMgr.getCsbObj(res, tag)
    if redPoint then
        redPoint:setVisible(false)
    end
end

function PetEducationMgr.hideAllRedPoint()
    local res = "UI/Effect/redPoint.csb"
    for i = 1,#redPointNameTable do 
        local redPoint = CSResourceMgr.getCsbObj(res, tag)--redPointNameTable[i])
        if redPoint then
            redPoint:setVisible(false)
        end
    end
    redPointNameTable = {}
end

function PetEducationMgr.getRedPointStateByPetInfo(petInfo)--PetListMgr里显示宠物红点
    local petInfos = clone(PokemonInfo.getPetArmy(PetFormationMgr.getCurTab()))
    -- for k,v in pairs(PokemonInfo.getPetHelpArmy()) do
    --     table.insert(petInfos, v)
    -- end
    for k,v in pairs(petInfos) do
        if petInfo.objID == v then
            if PetFeedViewMgr.getPetCanLvUp(petInfo) == true then
                return true
            end
            if PetEducationMgr.getPetCanStrength(petInfo) == true then
                return true
            end
            if PetStarUpMgr.getPetCanStarUpByPetInfo(petInfo) == true then
                return true
            end
            if PetEducationMgr.getPetCanEvolution(petInfo) == true then
                return true
            end
        end
    end
    return false
end

function PetEducationMgr.showStrengthRedPointByPetInfo(petInfo)
    PetEducationMgr.setRedPointStateByIndex(2, PetEducationMgr.getPetCanStrength(petInfo) == true)
end

function PetEducationMgr.showEvolutionRedPointByPetInfo(petInfo)
    PetEducationMgr.setRedPointStateByIndex(4, PetEducationMgr.getPetCanEvolution(petInfo) == true)
end

function PetEducationMgr.showStrengthRedPointByObjID(objID)
    local objIDList = clone(PokemonInfo.getPetArmy(PetFormationMgr.getCurTab()))
    -- for k,v in pairs(PokemonInfo.getPetHelpArmy()) do
    --     table.insert(objIDList, v)
    -- end
    for k,v in pairs(objIDList) do
        if objID == v then
            local petInfo = PokemonInfo.getPetInfoByObjID(v)
            if PetEducationMgr.getPetCanStrength(petInfo) == true then
                PetEducationMgr.setRedPointStateByIndex(2, true)
                return
            end
        end
    end
    PetEducationMgr.setRedPointStateByIndex(2, false)
end

function PetEducationMgr.getPetCanEvolution(petInfo)
    local evoInfo = PokemonInfo.getPetEvoInfoByID(petInfo.pokeID)
    if not evoInfo then
        return false
    end

    if evoInfo.PetEvoLevelInfoVec[1].EvoRateInfoVec[1].newRace >= 20000 then
        if false == PetEducationMgr.checkIsFullYoke(petInfo) then
            return false
        end
        if petInfo.star < 5 then
            return false
        end
    end

    for k,v in pairs(evoInfo.PetEvoLevelInfoVec) do
        local canEvo = true
        local needLevel = v.level
        local lvEnough = needLevel <= petInfo.level
        local stageCons = v.stageCons
        local isResEnough = true
        for k1,v1 in pairs(stageCons) do
            local have = 0
            local elementInfo = ItemInfo.getConsumeElementInfoById(v1)
            local needNum = elementInfo.num
            local elementID = elementInfo.elementID
            if elementInfo.elementType == 1 then
                have = CharInfo.getGCash()
            elseif elementInfo.elementType == 2 then
                have = CharInfo.getMCash()
            elseif elementInfo.elementType == 3 then
                have = ItemInfo.getCharItemNum(elementInfo.elementID)
            end
            if (have < needNum) or (petInfo.level < needLevel) then
                canEvo = false
            end
        end
        if canEvo == true then
            return true
        end
    end
    return false
end

function PetEducationMgr.showPetEvolutionChangeSkillUI(petInfo, addSkills, idx)
    local EduSkillPageMgr = require("src.GameMgr.Pet.EduSkillPageMgr")
    EduSkillPageMgr.Init()
    local function closeCallback()
        if idx ~= PetEducationMgr.getTableLength(addSkills) then
            petInfo = PokemonInfo.getPetInfoByObjID(petInfo.objID)
            PetEducationMgr.showPetEvolutionChangeSkillUI(petInfo, addSkills, idx + 1, closeCallback)
        else
            NetInterface.sendWithBlock("GC_CLEAREVOSKILLS_ACK", function()
                local PetEducationSend = require("src/Net/Send/PetEducationSend.lua")
                PetEducationSend.sendCG_ClearEvoSkills_Req({
                    objID = petInfo.objID,
                })
            end)
        end
    end
    if #addSkills < 1 then
        return
    end

    local index = 1
    local skillType = addSkills[idx].skillType
    if skillType == 0 or skillType == 1 or skillType == 8 then
        for k,v in pairs(petInfo.skills) do
            if v ~= 0 then
                index = index + 1
            end
        end
        index = 5
        if index == 5 then
            EduSkillPageMgr.showSkillExchangeUIAfterEvolution(petInfo, addSkills, idx, closeCallback)
        end
    else
        index = 5
        for k,v in pairs(petInfo.paSkills) do
            if v["paSkillID"] and v["paSkillID"] ~= 0 then
                index = index + 1
            end
        end
        index = 10
        if index == 10 then
            EduSkillPageMgr.showSkillExchangeUIAfterEvolution(petInfo, addSkills, idx, closeCallback)
        end
    end
end

function PetEducationMgr.setAttriTips(item, btn, index, color, ocolor, type)
    local stringVec = {
        "train146", "train147", "train148", "train149", "train150", "train151", nil, nil, nil, nil,
        "train152", "train153", "train154", "train155", "train156", "train157", "train227", "train228", "train229", "train231",
    }
    if not stringVec[index] then
    	return
    end
    CSResourceMgr.buttonEventBindingByNode(btn, function ()
        local strName = stringVec[index]
        TipsViewMgr.show(SceneMgr.getRunningScene, item, btn, strName, color, ocolor, 0, 20, type)
    end, function ()
        TipsViewMgr.hide()
    end, function ()
    end, function ()
        TipsViewMgr.hide()
    end, true)
end

function PetEducationMgr.setAttriCells(resName, listName, contentName, petInfo, yokeValues, yokeRates, yokePercent, 
    spriteColor, labelColor, outlineColor, showAdd, nextPetInfo)
    local mainAttrName = {"train11","train12","train14","train13","train15","train16","","","",""}
    local deputyAttrName = {"train140","train38","train41","train105","train106","train39","train224","train225","train226","train230"}
    local pokemonInfo = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
    local petAttrs = PetEducationMgr.sortPetAttrsForCommon(pokemonInfo, petInfo, yokeValues, yokeRates)
    local attrNum, attPotentialValue = PetEducationMgr.calPetAttrsFull(petAttrs, pokemonInfo, petInfo, yokePercent)
    print(sz_T2S(attrNum))
    print(sz_T2S(attPotentialValue))
    
    showAdd = showAdd or false
    listName = listName or {"Image_2","petInfoList"}
    contentName = contentName or "content"

    local list              = CSResourceMgr.getNodeByName(resName, listName)
    local parent            = CSResourceMgr.getNodeByName(resName, contentName)
    
    local skinValue = PetEducationMgr.getDiversAttrsTable(petInfo)  --宠物皮肤加成
    local sortSkinTable = {
        skinValue[Proto.AT_HP],
        skinValue[Proto.AT_ATK],
        skinValue[Proto.AT_SATK],
        skinValue[Proto.AT_DEF],
        skinValue[Proto.AT_SDEF],
        skinValue[Proto.AT_SPEED],
    }
    
    local funcTable = {}
    --list:removeAllItems()
    for i = 1, #mainAttrName do
        table.insert(funcTable, function()
            list:performWithDelay(function()
                local item = list:getItems()[i]
                if not item then
                    item = parent:clone()
                    item:setVisible(true)
                    list:pushBackCustomItem(item)
                end

                local attrNameLeft  = CSResourceMgr.seekNodeByName(item, "attr_text")
                local attrNumLeft   = CSResourceMgr.seekNodeByName(item, "attr_num")
                local attrAddLeft   = CSResourceMgr.seekNodeByName(item, "attr_add_num")
                local attrNameRight = CSResourceMgr.seekNodeByName(item, "next_attr_text")
                local attrNumRight  = CSResourceMgr.seekNodeByName(item, "next_attr_num")
                local attrAddRight  = CSResourceMgr.seekNodeByName(item, "next_attr_add_num")
                local background1   = CSResourceMgr.seekNodeByName(item, "att_background_1")
                local background2   = CSResourceMgr.seekNodeByName(item, "att_background_2")
                local background3   = CSResourceMgr.seekNodeByName(item, "att_background_3")
                local background4   = CSResourceMgr.seekNodeByName(item, "att_background_4")
                local attrArrow     = CSResourceMgr.seekNodeByName(item, "att_arrow")
                local attrUpArrow   = CSResourceMgr.seekNodeByName(item, "attr_up_arrow")

                local btnName1 = CSResourceMgr.seekNodeByName(item, "btn_name1")
                local btnName2 = CSResourceMgr.seekNodeByName(item, "btn_name2")
                PetEducationMgr.setAttriTips(item, btnName1, i, labelColor[23], outlineColor[9], 1)
                PetEducationMgr.setAttriTips(item, btnName2, i+#mainAttrName, labelColor[23], outlineColor[9], 3)

                local skinVal = sortSkinTable[i] or 0
                local hasSkin = skinVal > 0
                attrArrow:setVisible(i > 3 and i < 7)
                attrUpArrow:setVisible(hasSkin == true)
                attrUpArrow:setScale(1.2)

                item:setColor(spriteColor[1])
                background1:setColor(spriteColor[2])
                background2:setColor(spriteColor[2])
                background3:setColor(spriteColor[2])
                background4:setColor(spriteColor[2])

                CSResourceMgr.setLabelStringByNode(attrNameLeft,    mainAttrName[i]  , nil, 1, 88)
                local attrNum1 = attrNum[i]
                if attrNum1 and attPotentialValue[i] then
                    if attPotentialValue[i] > 0 then
                        CSResourceMgr.setLabelStringByNode(attrNumLeft, attrNum1, nil, 1, 88)
                        CSResourceMgr.setLabelStringByNode(attrAddLeft, "+"..attPotentialValue[i], nil, 1, 88)
                        local width = attrAddLeft:getBoundingBox().width * 0.5
                        local addWidth = attrNumLeft:getBoundingBox().width * 0.5
                        attrNumLeft:setPositionX(background2:getPositionX() - width)
                        attrAddLeft:setPositionX(attrNumLeft:getPositionX() + addWidth)
                    else
                        CSResourceMgr.setLabelStringByNode(attrNumLeft, attrNum1, nil, 1, 88)
                    end
                end

                CSResourceMgr.setLabelStringByNode(attrNameRight, deputyAttrName[i], nil, 1, 88)
                local attrNum2 = attrNum[#mainAttrName+i]
                if attrNum2 and attPotentialValue[#mainAttrName+i] then
                    if attPotentialValue[#mainAttrName+i] > 0 then
                        CSResourceMgr.setLabelStringByNode(attrNumRight, attrNum2.."%", nil, 1, 88)
                        CSResourceMgr.setLabelStringByNode(attrAddRight, "+"..attPotentialValue[#mainAttrName+i].."%", nil, 1, 88)
                        local width = attrAddRight:getBoundingBox().width * 0.5
                        local addWidth = attrNumRight:getBoundingBox().width * 0.5
                        attrNumRight:setPositionX(background4:getPositionX() - width)
                        attrAddRight:setPositionX(attrNumRight:getPositionX() + addWidth)
                    else
                        attrNum2 = attrNum2.."%"
                        CSResourceMgr.setLabelStringByNode(attrNumRight, attrNum2, nil, 1, 88)
                    end
                end
                
                CSResourceMgr.setLabelColorByNode(attrNameLeft,     hasSkin == true and labelColor[22] or labelColor[5])
                CSResourceMgr.setLabelColorByNode(attrNumLeft,      hasSkin == true and labelColor[22] or labelColor[5])
                CSResourceMgr.setLabelColorByNode(attrNameRight,    labelColor[4])
                CSResourceMgr.setLabelColorByNode(attrNumRight,     labelColor[4])
                CSResourceMgr.setLabelColorByNode(attrAddLeft,      labelColor[22])
                CSResourceMgr.setLabelColorByNode(attrAddRight,     labelColor[22])

                if showAdd then
                    local nextPetAttrs = PetEducationMgr.sortPetAttrsForCommon(pokemonInfo, nextPetInfo, yokeValues, yokeRates)
                    -- local curPoints = petInfo.hpx + petInfo.atk + petInfo.def + petInfo.satk + petInfo.sdef + petInfo.speed
                    local nextAttrNum = PetEducationMgr.calPetAttrsFull(nextPetAttrs, pokemonInfo, petInfo, yokePercent)
                    local attrAdd = CSResourceMgr.seekNodeByName(item, "attr_add")
                    local nextAttAdd = CSResourceMgr.seekNodeByName(item, "next_attr_add")
                    if nextAttrNum[i] and attrNum[i] then
                    	CSResourceMgr.setLabelStringByNode(attrAdd, "+"..(nextAttrNum[i] - attrNum[i]))
                    end
                    if nextAttrNum[#mainAttrName+i] and attrNum[#mainAttrName+i] then
                    	CSResourceMgr.setLabelStringByNode(nextAttAdd, "+"..(nextAttrNum[#mainAttrName+i] - attrNum[#mainAttrName+i]).."%")
                    end
                    CSResourceMgr.setLabelColorByNode(attrAdd, labelColor[20])
                    CSResourceMgr.setLabelColorByNode(nextAttAdd, labelColor[20])
                end
                item:setScaleY(0)
                transition.scaleTo(item, {scale=1, time=0.1})
            end,0.02*i)
        end)
    end
    UnblockLoader.load(funcTable, resName)
end

function PetEducationMgr.setEvoAttriCells(resName, petInfo, pokeID, yokeValues, yokeRates, yokePercent, 
    spriteColor, labelColor, outlineColor, showAdd, nextPetInfo)
    showAdd = showAdd or false
    local mainAttrName      = {"train11","train12","train14","train13","train15","train16",}
    local deputyAttrName    = {"train140","train38","train41","train105","train106","train39"}
    local list              = CSResourceMgr.getNodeByName(resName, {"Image_2","petInfoList"})
    local parent            = CSResourceMgr.getNodeByName(resName, "content")
    local pokemonInfo       = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
    parent:setVisible(false)

    local petAttrs = PetEducationMgr.sortPetAttrsForCommon(pokemonInfo, petInfo, yokeValues, yokeRates)
    -- local curPoints = petInfo.hpx + petInfo.atk + petInfo.def + petInfo.satk + petInfo.sdef + petInfo.speed
    local attrNum = PetEducationMgr.calPetAttrsEx(petAttrs, pokemonInfo, petInfo, yokePercent)
    local funcTable = {}
    list:removeAllItems()
    for i = 1, #mainAttrName do
        table.insert(funcTable, function()
            list:performWithDelay(function()
                local item = parent:clone()
                item:setVisible(true)

                local attrNameLeft  = CSResourceMgr.seekNodeByName(item, "attr_text")
                local attrNumLeft   = CSResourceMgr.seekNodeByName(item, "attr_num")
                local attrNameRight = CSResourceMgr.seekNodeByName(item, "next_attr_text")
                local attrNumRight  = CSResourceMgr.seekNodeByName(item, "next_attr_num")
                local background1   = CSResourceMgr.seekNodeByName(item, "att_background_1")
                local background2   = CSResourceMgr.seekNodeByName(item, "att_background_2")
                local background3   = CSResourceMgr.seekNodeByName(item, "att_background_3")
                local background4   = CSResourceMgr.seekNodeByName(item, "att_background_4")
                local attrArrow     = CSResourceMgr.seekNodeByName(item, "att_arrow")

                attrArrow:setVisible(i > 3)

                item:setColor(spriteColor[1])
                background1:setColor(spriteColor[2])
                background2:setColor(spriteColor[2])
                background3:setColor(spriteColor[2])
                background4:setColor(spriteColor[2])

                CSResourceMgr.setLabelStringByNode(attrNameLeft,    mainAttrName[i]  , nil, 1, 88)
                local attrNum1 = attrNum[i]
                CSResourceMgr.setLabelStringByNode(attrNumLeft, attrNum1, nil, 1, 88)
                CSResourceMgr.setLabelStringByNode(attrNameRight, deputyAttrName[i], nil, 1, 88)
                local attrNum2 = attrNum[6+i]
                CSResourceMgr.setLabelStringByNode(attrNumRight, attrNum2, nil, 1, 88)

                CSResourceMgr.setLabelColorByNode(attrNameLeft,     labelColor[5])
                CSResourceMgr.setLabelColorByNode(attrNumLeft,      labelColor[5])
                CSResourceMgr.setLabelColorByNode(attrNameRight,    labelColor[4])
                CSResourceMgr.setLabelColorByNode(attrNumRight,     labelColor[4])

                if showAdd then
                    pokemonInfo = PokemonInfo.getPokemonInfoByID(pokeID)
                    local nextPetAttrs = PetEducationMgr.sortPetAttrsForCommon(pokemonInfo, nextPetInfo, yokeValues, yokeRates)
                    -- local curPoints = petInfo.hpx + petInfo.atk + petInfo.def + petInfo.satk + petInfo.sdef + petInfo.speed
                    local nextAttrNum = PetEducationMgr.calPetAttrsEx(nextPetAttrs, pokemonInfo, petInfo, yokePercent)
                    local strFuHao1 = nextAttrNum[i] - attrNum[i] >= 0 and "+" or ""
                    local strFuHao2 = nextAttrNum[6+i] - attrNum[6+i] >= 0 and "+" or ""
                    local attrAdd = CSResourceMgr.seekNodeByName(item, "attr_add")
                    local nextAttAdd = CSResourceMgr.seekNodeByName(item, "next_attr_add")
                    CSResourceMgr.setLabelStringByNode(attrAdd, strFuHao1..(nextAttrNum[i] - attrNum[i]))
                    CSResourceMgr.setLabelStringByNode(nextAttAdd, strFuHao2..(nextAttrNum[6+i] - attrNum[6+i]).."%")
                    CSResourceMgr.setLabelColorByNode(attrAdd, labelColor[20])
                    CSResourceMgr.setLabelColorByNode(nextAttAdd, labelColor[20])
                end
                list:pushBackCustomItem(item)
                item:setVisible(true)
                item:setScaleY(0)
                transition.scaleTo(item, {scale=1, time=0.1})
            end,0.02*i)
        end)
    end
    UnblockLoader.load(funcTable, resName)
end