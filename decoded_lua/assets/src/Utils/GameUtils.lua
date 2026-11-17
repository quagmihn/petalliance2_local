local GenUtils = require("Utils.GenUtils")
local PackInfo = require("Data.PackInfo")

local ItemInfoConfig = require("DatReader.ItemInfoConfig")
local EquipmentInfoConfig = require("DatReader.EquipmentInfoConfig")
ItemInfoConfig.init()
-- EquipmentInfoConfig.init()

------------------------------------------------------------------

local function getPetBattleValue(petBase, equipList)
    local HDBattlePetInfoCal = require("Battle.HDBattlePetInfoCal")
    if not petBase then
        return nil
    end
    if not equipList then
        equipList = {}
    end
    local petinfoCal = HDBattlePetInfoCal.cal( petBase, equipList )
    local petHP = petinfoCal.hp
    local petATT = petinfoCal.ATT
    local petDEF = petinfoCal.DEF
    local petSPD = petinfoCal.SPD
    --战斗力计算
    local petBattleValue = toint( math.max((petHP / 5.5) + petATT + petDEF + petSPD))

    return petBattleValue
end

local function getPetStatusInfo(petID)
    local PetInfo = require("Data.PetInfo")
    local _IllustrationList = PetInfo.getPetIllustrationList()

    for i=1, #_IllustrationList, 1 do 
        if _IllustrationList[i].petID == petID then
            -- GenUtils.printTable(_IllustrationList[i])
            return _IllustrationList[i]
        end
    end
    -- flag
        -- PET_ILLUSTRATION_MEET
        -- PET_ILLUSTRATION_GOT
    -- maxGrade
    return nil
end

local function getAllEquipedItemList()
    return clone( PackInfo.getPackInfoList(Proto.PACKAGE_TYPE_PET_EQUIPMENT) )
end

local function getPetEquipedItemList(pet)
    if not pet or not pet.pos then
        return {}
    end
    local items = {}
    local _packEquipList = getAllEquipedItemList()
    for i=1, #_packEquipList, 1 do
        local equip = _packEquipList[i]
        if pet.pos == equip.ownerID then
            items[#items+1] = clone(equip)
        end
    end
    return items
end

local function getPetEquipedItemByType(pet, screenType)
    --Proto.EQUIPMENT_TYPE_WEAPON
    --Proto.EQUIPMENT_TYPE_ARMOR
    if not pet or not pet.pos then
        return nil
    end
    local item = nil
    local list = getPetEquipedItemList(pet)
    for k,equip in pairs(list) do
        local equipInfo = EquipmentInfoConfig.readEntryByID(equip.itemID)
        if screenType == equipInfo.type then
            item = clone(equip)
            break
        end
    end
    return item
end

local function getPetEquipedItemBySlot(pet, slot)
    if not pet or not pet.pos then
        return nil
    end
    local item = nil
    local list = getPetEquipedItemList(pet)
    for k,equip in pairs(list) do
        if slot == equip.pos then
            item = clone(equip)
            break
        end
    end
    return item
end

local function getOtherPetEquipedItemList(pet, screenType)
    local list = {}
    local _packEquipList = getAllEquipedItemList()
    for i=1, #_packEquipList, 1 do
        local equip = _packEquipList[i]
        if pet.pos ~= equip.ownerID then
            local equipInfo = EquipmentInfoConfig.readEntryByID(equip.itemID)
            if screenType == equipInfo.type then
                list[#list+1] = clone(equip)
            end
        end
    end
    return list
end
    
local function getMyBagEquipmentList(screenType)
    --Proto.EQUIPMENT_TYPE_WEAPON
    --Proto.EQUIPMENT_TYPE_ARMOR
    local list = {}
    local _packBagList = PackInfo.getPackInfoList(Proto.PACKAGE_TYPE_NORMAL)
    table.sort( _packBagList, function(a,b) return a.pos<b.pos end )

    for i = 1, #_packBagList, 1 do 
        local info = ItemInfoConfig.readEntryByID(_packBagList[i].itemID)
        if info.type == Proto.ITEM_TYPE_EQUIPMENT then
            if screenType then
                local equipInfo = EquipmentInfoConfig.readEntryByID(info.id)
                if equipInfo.type == screenType then
                    list[#list+1] = clone( _packBagList[i] )
                end
            else
                list[#list+1] = clone( _packBagList[i] )
            end
        end
    end
    return list
end

local function getPetDataFromEquipedOwnerID(ownerID)
    local myPetList = PackInfo.getPackInfoList(Proto.PACKAGE_TYPE_PET)
    for i=1, #myPetList, 1 do
        local pet = myPetList[i]
        if ownerID == pet.pos then
            return pet
        end
    end
    return nil
end

local function getStringRaceList( raceList )
    local str = ""
    if #raceList>0 then
        for i=1, #raceList, 1 do
            local race = raceList[i]
            if i>1 then
                str = str.."、"
            end
            if race == Proto.PET_RACE_EARTH then
                str = str.."地"
            elseif race == Proto.PET_RACE_WIND then
                str = str.."风"
            elseif race == Proto.PET_RACE_FIRE then
                str = str.."火"
            elseif race == Proto.PET_RACE_WATER then
                str = str.."水"
            end
        end
    else
        str = "无"
    end
    return str
end

local function getStringEquipOwner(equip)
    local obj = {}
    local function objReturner(name)
        if name then
            obj.str = "（装备于"..name.."）"
            obj.color = ccc3(255, 168, 0)
        else
            obj.str = "（未装备）"
            obj.color = ccc3(160, 160, 160)
        end
        return obj
    end

    if equip then
        local ownerID = equip.ownerID
        local PetRaceInfoConfig = require("DatReader.PetRaceInfoConfig")
        PetRaceInfoConfig.init()

        if ownerID>0 then
            local pet = getPetDataFromEquipedOwnerID(ownerID)
            local petInfo = PetRaceInfoConfig.readEntryByID(pet.itemID)
            return objReturner(petInfo.name)
        end
    end
    return objReturner()
end

local function getAvailableQuestList()
    local list = {}
    local QuestInfo = require("Data.QuestInfo")
    local QuestInfoConfig = require("DatReader.QuestInfoConfig")
    QuestInfoConfig.init()

    for i=1, QuestInfo.getQuestCount(), 1 do
        local quest = clone( QuestInfo.getQuestDetail(i) )
        local info = QuestInfoConfig.readEntryByID(quest.questID)

        if info.type == Proto.QUEST_TYPE_EVERYDAY then
            if GenUtils.getDistanceDaysToNow(quest.updateTime)>0 then
                if info.parentID~=0 then
                    local parentInfo = QuestInfoConfig.readEntryByID(info.parentID)
                    if parentInfo.resetType == Proto.QUEST_RESET_TYPE_DAY then
                        quest.status = Proto.QUEST_STATUS_STANDBY
                    end
                end
            end
        end
        if quest.status == Proto.QUEST_STATUS_NORMAL then
            list[#list+1] = quest
        end
    end

    return list 
end

local function checkIsMeetConditions(limitList, notiDialog, notiStr)
    local GenInfo = require("Data.GenInfo")
    local function showWaring(str)
        if notiDialog then
            local t = notiStr or str
            notiDialog:openDialog("Notification", {
                text = t,
            })
        end
    end

    if limitList.playerLevel and GenInfo.getMyBaseInfo(1).level < limitList.playerLevel then  --角色等级
        showWaring("角色等级需要达到"..limitList.playerLevel)
        return false
    elseif limitList.gCash and GenInfo.getMyBaseInfo().g_cash < limitList.gCash then
        showWaring("金币不足")
        return false
    elseif limitList.mCash and GenInfo.getMyBaseInfo().m_cash < limitList.mCash then
        showWaring("M币不足")
        return false
    end

    return true
end

local function getPetExpInfoByExp(num,quality)
    local obj = {
        level = 1,
        expPercent = 0,
    }

    local SpriteExpInfoConfig = require("DatReader.SpriteExpInfoConfig")
    SpriteExpInfoConfig.init()
    local level = SpriteExpInfoConfig.readEntryByID(quality)

    if num >= level.expList[#level.expList].exp then
        obj.level = level.expList[#level.expList].level
        obj.expPercent = 100
    elseif num <= level.expList[1].exp then
        obj.level = level.expList[1].level
        obj.expPercent = 0
    else
        local info = nil
        for i=2,#level.expList do
            info = level.expList[i]
            if num < info.exp then
                obj.level = level.expList[i-1].level
                local curBaseExp = level.expList[i-1].exp
                local nextBaseExp = info.exp
                obj.expPercent = (num-curBaseExp)/(nextBaseExp-curBaseExp)*100 --1~100百分比
                break
            end
        end
    end

    return obj
end

local function getPlayerExpInfoByExp(num)
    local obj = {
        level = 1,
        expPercent = 0,
    }

    local PlayerExpInfoConfig = require("DatReader.AdventureExpInfoConfig")
    PlayerExpInfoConfig.init()
        
    for i=1,PlayerExpInfoConfig.getEntryCount() do
        local currentPlayerInfo = PlayerExpInfoConfig.readEntry(i)
        if num < currentPlayerInfo.exp then
            if i == 1 then
                obj.level = 1
                obj.expPercent = 1
            else
                obj.level = currentPlayerInfo.id
                local curBaseExp = PlayerExpInfoConfig.readEntry(i-1).exp
                local nextBaseExp = currentPlayerInfo.exp
                obj.expPercent = (num-curBaseExp)/(currentPlayerInfo.exp-curBaseExp)*100 --1~100百分比
            end
            break
        elseif num >= currentPlayerInfo.exp and i == PlayerExpInfoConfig.getEntryCount() then
            obj.level = currentPlayerInfo.id
            obj.expPercent = 100
            break
        end
    end

    return obj
end

local function getMyItemAmountByID(itemID)
    local myItemBag = PackInfo.getPackInfoList(Proto.PACKAGE_TYPE_NORMAL)
    local amount = 0
    for k,item in ipairs(myItemBag) do
        if item.itemID==itemID then
            dumpXP(item)
            amount = amount+item.count
        end
    end
    return amount
end

------------------------------------------------------------------------------------------
local GameUtils = {
    getPetBattleValue = getPetBattleValue,  --获取战斗力
    getPetStatusInfo = getPetStatusInfo,    --获取宠物图鉴中的状态信息
    getAllEquipedItemList = getAllEquipedItemList,  --获取所有宠物装备在身上的装备
    getPetEquipedItemByType = getPetEquipedItemByType,  --获取宠物装备（通过装备的类型）
    getPetEquipedItemBySlot = getPetEquipedItemBySlot,  --获取宠物装备（通过装备的位置）
    getPetEquipedItemList = getPetEquipedItemList,  --获取宠物装备组
    getOtherPetEquipedItemList = getOtherPetEquipedItemList,    --获取其他宠物的已装备列表
    getMyBagEquipmentList = getMyBagEquipmentList,  --获取我的背包中的装备
    getPetDataFromEquipedOwnerID = getPetDataFromEquipedOwnerID, --根据装备上的所属ID返回对应的宠物信息
    getStringRaceList = getStringRaceList,  --返回装备的种族限制字符串
    getStringEquipOwner = getStringEquipOwner,  --获取装备拥有者的文字描述和颜色
    getAvailableQuestList = getAvailableQuestList,  --获取当前状态下可用的任务
    checkIsMeetConditions = checkIsMeetConditions,  --判断是否满足规定的条件
    getPetExpInfoByExp = getPetExpInfoByExp,    --获取精灵等级
    getPlayerExpInfoByExp = getPlayerExpInfoByExp, --获取角色等级
    getMyItemAmountByID = getMyItemAmountByID,  --获取背包内的道具数量
}



return GameUtils