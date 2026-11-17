function PetEducationMgr.getTableLength(table)
    local index = 0
    for k,v in pairs(table) do
        index = index + 1
    end
    return index
end

function PetEducationMgr.showDelYokeUI(objid, callback)
	local petinfo = PokemonInfo.getPetInfoByObjID(objid)
    if not PetEducationMgr.isPetYoked(petinfo) then
		return
	end
    local objID = petinfo.yoke.bindTo
    local petInfo = PokemonInfo.getPetInfoByObjID(objID)
    local yokeVec = PokemonInfo.getPokemonInfoByID(petInfo.pokeID).yokeVec
    local delInfo = {}
    local yokeInfo = nil
    for key, var in pairs(yokeVec) do
    	yokeInfo = PokemonInfo.getYokeInfoByID(var)
    	local needYokePetsCnt = PetEducationMgr.getTableLength(yokeInfo.pets)
        for j = 1, needYokePetsCnt do
            local pokeID = yokeInfo.pets[j]
            if pokeID==petinfo.pokeID then
            	delInfo[1] = var
            	delInfo[2] = j-1
            	break
            end
        end
        if delInfo[1] and delInfo[2] then
        	break
        end
    end
    if delInfo[1] and delInfo[2] then
        local function sendMsg()
            NetInterface.sendWithBlock("GC_DELYOKEPET_ACK", function()
                local PetEducationSend = require("src/Net/Send/PetEducationSend.lua")
                PetEducationSend.sendCG_DelYokePet_Req({
                    objID       = objID,
                    yokeID      = delInfo[1],
                    yokeCellID  = delInfo[2],
                })
            end, function()
                PetListMgr.setUpdateFlag("yoke")
                PetListMgr.setBnum()
                if callback then
                	callback()
                end
            end, function(code)
                TipsMgr.showError(nil, code)
            end)
        end
        local resName = "Pet/Education/RemoveYokeView.csb"
        local function closeFunc()
        	CSResourceMgr.removeCSObjectByTag(resName)
            UIStack.pop("RemoveYokeView")
        end
        UIStack.push("RemoveYokeView", closeFunc, false)
        CSResourceMgr.createRes(SceneMgr.getRunningScene, resName):zorder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName, "db"), "down")
        CSResourceMgr.clickEventBinding(resName, "close", closeFunc)
        CSResourceMgr.clickEventBinding(resName, "bg", closeFunc)
        CSResourceMgr.clickEventBinding(resName, "enter", function()
            closeFunc()
            sendMsg()
        end)
        CSResourceMgr.setLabelColor(resName, "title", {r=45,g=192,b=243,a=255})
        CSResourceMgr.setLabelColor(resName, "info1", {r=233,g=244,b=255,a=255})
        CSResourceMgr.setLabelColor(resName, "info2", PokemonInfo.COLOR[yokeInfo.rarePoint])
        CSResourceMgr.setLabelString(resName, "title", "train221", nil, {r=0,g=0,b=0,s=1,w=1,a=255}, nil, 300)
        CSResourceMgr.setLabelString(resName, "info1", "train222", nil, {r=0,g=0,b=0,s=1,w=1,a=255}, nil, 200)
        local yokeStr = CocosModuleMgr.createStringWithFormat({"<1>: <2>", yokeInfo.yokeName, 
            PetEducationMgr.getYokeStrName(petInfo, delInfo[1], petinfo.star, yokeInfo.pets)})
        CSResourceMgr.setLabelString(resName, "info2", yokeStr, nil, {r=0,g=0,b=0,s=1,w=1,a=255}, nil, 200)
        CSResourceMgr.setLabelString(resName, "btext", "train223", nil, {r=0,g=0,b=0,s=1,w=1,a=255}, nil, 200)
        local button = BattleFuncMgr.startCreatePetCard(petInfo, 3, true).button
        button:addTo(CSResourceMgr.getNodeByName(resName, "pet"))
        button:scale(1.4)
        button:pos(0, 0)
    end
end

-- 宠物是否是羁绊宠
function PetEducationMgr.isPetYoked(petInfo)
    if petInfo.yoke then
        if petInfo.yoke.bindTo then
            return true
        end
    end
    return false
end

-- 宠物是否有羁绊宠
function PetEducationMgr.isPetHasYoke(petInfo)
    local isYoke = 0
    if petInfo.yoke then
        if petInfo.yoke.yokeDetail then
            for k,v in pairs(petInfo.yoke.yokeDetail) do
                for k1,v1 in pairs(v) do
                    isYoke = isYoke + 1
                end 
            end
        end
    end
    return isYoke>0
end

-- 获取羁绊数据
function PetEducationMgr.getYokeParamsTable(info)
    local values  = {0,0,0,0,0,0,}
    local rates   = {0,0,0,0,0,0,}
    local yokePer = {0,0,0,0,0,0,}

    local valueTable = {1,2,3,4,5,6}
    local ratesTable = {12,13,14,15,16,17}
    local percentTable = {8,9,11,12,13,8}
    if info.yoke and info.yoke.yokeValues then
        local value = info.yoke.yokeValues
        for i = 1, PetEducationMgr.getTableLength(valueTable) do
            values[i] = value[valueTable[i]]
        end
        for i = 1, PetEducationMgr.getTableLength(ratesTable) do
            rates[i] = 0
        end
        for i = 1, PetEducationMgr.getTableLength(percentTable) do
            yokePer[i] = value[percentTable[i]]
        end
    end
    return {values=values,rates=rates,yokePer=yokePer}
end

function PetEducationMgr.getPetWithOutYoke(petList)
    local petsTable = {}
    for k,v in pairs(petList) do
        --[[
        if (not v.yoke) or (not v.yoke.bindTo and not v.yoke.yokeDetail) or (v.yoke.yokeDetail and PetEducationMgr.getTableLength(v.yoke.yokeDetail) == 0) then
        -- if (v.yoke and v.yoke.bindTo and (v.yoke.bindTo == petInfo.objID)) then

        -- elseif v.pokeID == needPokeID then
        --     table.insert(petsTable, v)
        -- end
        if v.level >= CharInfo.getLevel() * 0.5 then
            table.insert(petsTable, v)
            end
        end
        ]]
        if v.level >= CharInfo.getLevel()*0.5 then
            table.insert(petsTable, v)
        end
    end
    return petsTable
end

function PetEducationMgr.getResPetByPokeID(pokeID)
    local pokeInfo = PokemonInfo.getPokemonInfoByID(pokeID)
    return pokeInfo.useType == 1
end

function PetEducationMgr.getSkillCanLvUp(skillInfo)
    local level = (skillInfo.id % 5 == 0) and 5 or (skillInfo.id % 5)
    if level == 5 then
        return false
    end
    local nextSkillInfo = PokemonInfo.getPetSkillInfoById(skillInfo.id+1)
    local needSkillBook = nextSkillInfo.skill_A_Type ~= 7 and nextSkillInfo.skill_A_Type ~= 8--天赋援助技能不需要技能书
    local needSkillBookNum1 = 0
    local haveSkillBookNum2 = 0

    local itemID = skillInfo.upItemType--技能书ID
    needSkillBookNum1 = SystemInfo.getGlobalConfigAddInfoByID(6450+level).values[1]--需要技能书数量
    haveSkillBookNum2 = PetSkillViewMgr.getSkillBookNumByID(itemID)

    local itemID2 = 10001--技能碎片ID
    local itemCount = ItemInfo.getCharItemNum(itemID2)--表里读的需要技能碎片数量
    local needItemNum1 = SystemInfo.getGlobalConfigAddInfoByID(6400+level).values[1]--需要技能碎片数量
    local needItemNum2 = SystemInfo.getGlobalConfigAddInfoByID(6550+skillInfo.airpower).values[1]
    local needItemNum = needItemNum1 * needItemNum2 * (needSkillBook == true and 1 or 2)--天赋、援助技能技能碎片消耗 * 2

    local btnLvUpEnable = false
    if needSkillBook == true then
        btnLvUpEnable = (itemCount >= needItemNum) and (haveSkillBookNum2 >= needSkillBookNum1)
    elseif needSkillBook == false then
        btnLvUpEnable = itemCount >= needItemNum
    end
    return btnLvUpEnable
end

function PetEducationMgr.showEvolutionRedPointByObjID(objID)
    local objIDList = clone(PokemonInfo.getPetArmy(PetFormationMgr.getCurTab()))
    -- for k,v in pairs(PokemonInfo.getPetHelpArmy()) do
    --     table.insert(objIDList, v)
    -- end
    for k,v in pairs(objIDList) do
        if objID == v then
            local petInfo = PokemonInfo.getPetInfoByObjID(v)
            if PetEducationMgr.getPetCanEvolution(petInfo) == true then
                PetEducationMgr.setRedPointStateByIndex(4, true)
                return
            end
        end
    end
    PetEducationMgr.setRedPointStateByIndex(4, false)
end

function PetEducationMgr.getPetCanStrength(petInfo)
    local pokemonInfo = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
    local maxStage    = math.floor(pokemonInfo.topLevel / 2)
    if petInfo.Stage < maxStage then--可以强化
        local petRp = pokemonInfo.elementAtt1
        local advanceInfo = PokemonInfo.getPetAdvanceInfo(petInfo.Stage+1)
        local itemTable = advanceInfo.stageCons[petRp]
        local needLv = (petInfo.Stage + 1) * 2
        local haveEnoughRes = true
        local index = 1
        for k,v in pairs(itemTable.costs) do
            local consumeInfo = ItemInfo.getConsumeElementInfoById(v)
            local itemId = consumeInfo.elementID
            local needResCount = consumeInfo.num
            local haveResCount = 0
            local strNeedRes = tostring(needResCount)
            if consumeInfo.elementType == 1 then
                haveResCount = CharInfo.getGCash()
            elseif consumeInfo.elementType == 2 then
                haveResCount = CharInfo.getMCash()
            elseif consumeInfo.elementType == 3 then
                local itemInfo = ItemInfo.getItemInfoById(itemId)
                haveResCount = ItemInfo.getCharItemNum(itemId)
            end
--            CSResourceMgr.setButtonTextureByNode(node, background, background, background)
--            CSResourceMgr.setSpriteTextureByNode(spriteIcon, iconPath)
--            CSResourceMgr.setLabelStringByNode(labelRes, strNeedRes, nil, 1, 80)
            if (needLv > petInfo.level) or (needResCount > haveResCount) then
                return false
            end
        end
    else
        return false
    end
    return true
end

function PetEducationMgr.getEvolutionSkinID(petInfo, nextPokeID)
    local attrType, attrValue = PetEducationMgr.getDiversificationAttrs(petInfo)
    local pokeInfo = PokemonInfo.getPokemonInfoByID(nextPokeID)
    for k,v in pairs(pokeInfo.skins) do
        if v.attribType == attrType then
            return k
        end
    end
    return 0
end

function PetEducationMgr.getDiversificationAttrs(petInfo)--多样化属性，返回 属性，值
    local attrTable = PetEducationMgr.getPetSkinAttrs(petInfo.pokeID, petInfo.skin)
    if attrTable ~= 0 then
        return attrTable.attribType, attrTable.attribValue
    end
    return 0, 0
end

function PetEducationMgr.getPetIsModify(petInfo)
    if petInfo.personal ~= nil and petInfo.personal.isModify ~= nil then
        return petInfo.personal.isModify
    end
    return false
end

function PetEducationMgr.sendTaskWatcherYoke(objID)
    local params = PetEducationMgr.getYokeTable(objID)
    if PetEducationMgr.getTableLength(params) > 0 then
        TaskWatcherManager.saveChongwuJiBanState(params.yokeCnt)
        TaskWatcherManager.saveCWJibanXingJiState(params.yokeStarCnt)
    end
end

function PetEducationMgr.updateSevenDayPetYoke(objID)
    if PetEducationMgr.needUpdateSevenDayPetYoke == true then
        PetEducationMgr.needUpdateSevenDayPetYoke = false
        -- PetEducationMgr.sendTaskWatcherYoke(objID)
        local petInfo = PokemonInfo.getPetInfoByObjID(objID)
        if petInfo.yoke and petInfo.yoke.bindTo then
            PetEducationMgr.sendTaskWatcherYoke(petInfo.yoke.bindTo)
        else
            PetEducationMgr.sendTaskWatcherYoke(objID)
        end
    end
end

function PetEducationMgr.getPetName(petInfo)
    if petInfo.personal ~= nil and petInfo.personal.name ~= nil then
        return petInfo.personal.name
    else
        local pokeInfo = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
        return LuaSqlite.getLanguageByKey(pokeInfo.name)
    end
    return ""
end

function PetEducationMgr.getPetSkinAttrs(pokeID, skin)
    if skin == 0 then
        return 0
    end
    local pokeInfo = PokemonInfo.getPokemonInfoByID(pokeID)
    if pokeInfo.skins[skin] ~= nil then
        return pokeInfo.skins[skin]
    end
    return 0
end

--下一级所需要的宠物星级
function PetEducationMgr.getNextYokeNeedStars(petInfo, yokeID, needYokePetsCnt)
    local nextStarCnt  = 0
    local yokedPetCnt  = 0
    local yokedPetStar = {}
    if petInfo.yoke and petInfo.yoke.yokeDetail and petInfo.yoke.yokeDetail[tostring(yokeID)] then
        for k,v in pairs(petInfo.yoke.yokeDetail[tostring(yokeID)]) do
            if v ~= 0 then
                local objID = PetEducationMgr.getYokedPetObjID(petInfo, yokeID, k)
                local yokedPetInfo = PokemonInfo.getPetInfoByObjID(objID)
                yokedPetStar[objID] = yokedPetInfo.star
                yokedPetCnt = yokedPetCnt + 1
            end
        end
    end
    if yokedPetCnt == needYokePetsCnt then
        nextStarCnt = 5
        for k,v in pairs(yokedPetStar) do
            if v < nextStarCnt then
                nextStarCnt = v
            end
        end
    end
    return nextStarCnt + 1
end

--获取属性文字
function PetEducationMgr.getYokeStrName(petInfo, pokeID, starsCnt, needYokePets)
    local yokeInfo  = PokemonInfo.getYokeInfoByID(pokeID)
    local score     = PetEducationMgr.getPetYokeScore(starsCnt, needYokePets)
    -- local needYokePetsCnt = PetEducationMgr.getTableLength(needYokePets)
    -- for i = 1, needYokePetsCnt do
    --     score = score + PetEducationMgr.getPetYokeScore(starsCnt, needYokePets)
    -- end
    local effectPosInfo = PokemonInfo.getYokeEffectPosByID(yokeInfo.attribType)
    local value = PokemonInfo.getYokeEffectByID(score).effectValues[effectPosInfo.pos]
    local preciseValue = PetEducationMgr.GetPreciseDecimal(value, 2)
    local strName = LuaSqlite.getLanguageByKey(effectPosInfo.name).."+"..preciseValue
    return strName
end

--获得绑定的宠物的objID。   yokeID羁绊ID, pos羁绊位置
function PetEducationMgr.getYokedPetObjID(petInfo, yokeID, pos)
    if petInfo.yoke and petInfo.yoke.yokeDetail and petInfo.yoke.yokeDetail[tostring(yokeID)] then
        return petInfo.yoke.yokeDetail[tostring(yokeID)][pos]
    end
    return 0
end

--宠物是否有羁绊
function PetEducationMgr.getPetHasYoke(petInfo, yokeID, pos)
    if petInfo.yoke and petInfo.yoke.yokeDetail and petInfo.yoke.yokeDetail[tostring(yokeID)] then
        if petInfo.yoke.yokeDetail[tostring(yokeID)][pos] ~= 0 then
            return true
        end
    end
    return false
end

--宠物已羁绊宠物数量
function PetEducationMgr.getPetYokeCnt(petInfo, yokeID, needYokePets)
    local yokeCnt = 0
    if petInfo.yoke and petInfo.yoke.yokeDetail and petInfo.yoke.yokeDetail[tostring(yokeID)] then
        for i = 1, PetEducationMgr.getTableLength(needYokePets) do
            if petInfo.yoke.yokeDetail[tostring(yokeID)][i] ~= 0 then
                yokeCnt = yokeCnt + 1
            end
        end
    end
    return yokeCnt
end

--羁绊宠物得分（算属性用）
function PetEducationMgr.getPetYokeScore(starCnt, needYokePets)
    local score = 0
    for k,v in pairs(needYokePets) do
        local pokeInfo = PokemonInfo.getPokemonInfoByID(v)
        local curScore = PokemonInfo.getYokeScoreInfoByID(pokeInfo.rarePoint).scores[starCnt+1]
        score = score + curScore
    end
    return score
end

function PetEducationMgr.checkPetEvolutionS(pokeID)
    local pokeInfo = PokemonInfo.getPokemonInfoByID(pokeID)
    if pokeInfo.rarePoint >= 4 then
        return true
    end
    return false
end

function PetEducationMgr.setWorldFollowPet(objID, petID, skinID)
    local objId = PokemonInfo.getPetArmy(PetFormationMgr.getCurTab())[1]
    if objId == objID then
        PokemonInfo.setFollowPokemon(petID, skinID)
    end
end

function PetEducationMgr.GetPreciseDecimal(nNum, n)--保留N位小数
    local precise = 10 ^ n
    local newNum = math.floor(nNum * precise) / precise
    return newNum
end

function PetEducationMgr.getYokeTable(objID)--七日活动用
    local petInfo     = PokemonInfo.getPetInfoByObjID(objID)
    local pokemonInfo = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
    local yokeVec     = pokemonInfo.yokeVec--羁绊列表
    local yokeCnt     = 0
    local yokeStarCnt = 0
    local yokeTable   = {}
    for k,v in pairs(yokeVec) do
        local yokeInfo = PokemonInfo.getYokeInfoByID(v)--pets,yokeName,attribType,rarePoint
        local needYokePetsCnt = PetEducationMgr.getTableLength(yokeInfo.pets)
        local isYokeActive = PetEducationMgr.getPetYokeCnt(petInfo, v, yokeInfo.pets) == needYokePetsCnt
        if isYokeActive == true then
            local curPetStarCnt = PetEducationMgr.getNextYokeNeedStars(petInfo, v, needYokePetsCnt) - 1
            yokeCnt = yokeCnt + 1
            yokeStarCnt = math.max(yokeStarCnt, curPetStarCnt)
        end
    end
    if yokeCnt > 0 then
        yokeTable.objID = objID
        yokeTable.yokeCnt = yokeCnt
        yokeTable.yokeStarCnt = yokeStarCnt
    end
    return yokeTable
end