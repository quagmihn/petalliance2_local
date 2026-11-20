local PokemonInfo = {}

PokemonInfo.COLOR = {}
PokemonInfo.DARKCOLOR = {}
PokemonInfo.COLOR_16 = {}

local PokemonInfoConfig = nil
local PetSkillInfoConfig = nil
local PetBufferInfoConfig = nil
local PetEvoInfoConfig = nil
local PetStrengthenInfoConfig = nil
local PetAdvanceInfoConfig = nil
local PetStarUpInfoConfig = nil
local YokeInfoConfig = nil
local YokeEffectConfig = nil
local PetFreedomAwardGroupInfoConfig = nil
local PetFreedomAwardInfoConfig = nil
local PetFreedomStarpointInfoConfig = nil
local SkillPlayConfig  = nil
local CapsuleEggInfoConfig = nil
local CapsuleEggAwardInfoConfig = nil
local GeneProbabilityInfoConfig = nil
local GeneInfoConfig = nil
local YokeScoreConfig = nil
local YokeEffectPosConfig = nil
local PetInfoData = {}
local watchRandomPetVec = nil
local PetResetStarInfoConfig = nil
local CustomSkillBookInfoConfig = nil

local startIndex = 0        -- 开始索引
local endIndex = 0          -- 结束索引
local activePets = {}       -- 战斗宠物列表
local unactivePets = {}     -- 未战斗宠物列表
local activeHelperPets = {} -- 援助宠物列表
local unactivePetNum = 0-- 未战斗宠物数量
local activePetsRow = {}
local petArmy = {}
local petHelpArmy = {}

local existPokemon = nil
local curPokemon = 0
local curPokemonSkin = 0

function PokemonInfo.Init()
    PokemonInfo.COLOR = {
        {r=72  ,g=255 ,b=0   ,a=255},
        {r=0   ,g=240 ,b=255 ,a=255},
        {r=255 ,g=67  ,b=248 ,a=255},
        {r=255 ,g=252 ,b=0   ,a=255},
        {r=255 ,g=129 ,b=0   ,a=255},
        {r=255 ,g=0   ,b=0   ,a=255},
    }

    PokemonInfo.DARKCOLOR = {
        {r=36  ,g=128 ,b=0   ,a=255},
        {r=0   ,g=119 ,b=128 ,a=255},
        {r=128 ,g=34  ,b=124 ,a=255},
        {r=128 ,g=125 ,b=0   ,a=255},
        {r=128 ,g=64  ,b=0   ,a=255},
        {r=128 ,g=0   ,b=0   ,a=255},
    }

    PokemonInfo.COLOR_16 = {
        "48FF00",
        "00F0FF",
        "FF43F8",
        "FFFC00",
        "FF8100",
        "FF0000",
    }

    if SkillPlayConfig==nil then
        SkillPlayConfig = require("src.DatReader.SkillPlayConfig")
        SkillPlayConfig.init()
    end

    if PokemonInfoConfig==nil then
        PokemonInfoConfig = require("src.DatReader.PokemonInfoConfig")
        PokemonInfoConfig.init()
        for var=1, PokemonInfoConfig.getEntryCount() do
            local id = PokemonInfoConfig.getEntryID(var)
            local data = PokemonInfoConfig.readEntryByID(id)
            PetInfoData[id] = data
        end
    end

    if PetSkillInfoConfig==nil then
        PetSkillInfoConfig = require("src.DatReader.PetSkillInfoConfig")
        PetSkillInfoConfig.init()
    end

    if PetBufferInfoConfig==nil then
        PetBufferInfoConfig = require("src.DatReader.PetBufferInfoConfig")
        PetBufferInfoConfig.init()
    end

    if PetEvoInfoConfig==nil then
        PetEvoInfoConfig = require("src.DatReader.PetEvoInfoConfig")
        PetEvoInfoConfig.init()
    end

    if PetStrengthenInfoConfig==nil then
        PetStrengthenInfoConfig = require("src.DatReader.PetStrengthenInfoConfig")
        PetStrengthenInfoConfig.init()
    end

    if PetAdvanceInfoConfig==nil then
        PetAdvanceInfoConfig = require("src.DatReader.PetAdvanceInfoConfig")
        PetAdvanceInfoConfig.init()
    end

    if PetStarUpInfoConfig==nil then
        PetStarUpInfoConfig = require("src.DatReader.PetStarUpInfoConfig")
        PetStarUpInfoConfig.init()
    end

    if YokeInfoConfig==nil then
        YokeInfoConfig = require("src.DatReader.YokeInfoConfig")
        YokeInfoConfig.init()
    end

    if YokeEffectConfig==nil then
        YokeEffectConfig = require("src.DatReader.YokeEffectConfig")
        YokeEffectConfig.init()
    end

    if PetFreedomAwardGroupInfoConfig==nil then
        PetFreedomAwardGroupInfoConfig = require("src.DatReader.PetFreedomAwardGroupInfoConfig")
        PetFreedomAwardGroupInfoConfig.init()
    end

    if PetFreedomAwardInfoConfig==nil then
        PetFreedomAwardInfoConfig = require("src.DatReader.PetFreedomAwardInfoConfig")
        PetFreedomAwardInfoConfig.init()
    end

    if PetFreedomStarpointInfoConfig==nil then
        PetFreedomStarpointInfoConfig = require("src.DatReader.PetFreedomStarpointInfoConfig")
        PetFreedomStarpointInfoConfig.init()
    end

    if CapsuleEggInfoConfig==nil then
        CapsuleEggInfoConfig = require("src.DatReader.CapsuleEggInfoConfig")
        CapsuleEggInfoConfig.init()
    end

    if CapsuleEggAwardInfoConfig==nil then
        CapsuleEggAwardInfoConfig = require("src.DatReader.CapsuleEggAwardInfoConfig")
        CapsuleEggAwardInfoConfig.init()
    end

    if GeneProbabilityInfoConfig==nil then
        GeneProbabilityInfoConfig = require("src.DatReader.GeneProbabilityInfoConfig")
        GeneProbabilityInfoConfig.init()
    end

    if GeneInfoConfig==nil then
        GeneInfoConfig = require("src.DatReader.GeneInfoConfig")
        GeneInfoConfig.init()
    end

    if YokeScoreConfig==nil then
        YokeScoreConfig = require("src.DatReader.YokeScoreConfig")
        YokeScoreConfig.init()
    end
    
    if YokeEffectPosConfig==nil then
        YokeEffectPosConfig = require("src.DatReader.YokeEffectPosConfig")
        YokeEffectPosConfig.init()
    end

    if PetResetStarInfoConfig==nil then
        PetResetStarInfoConfig = require("src.DatReader.PetResetStarInfoConfig")
        PetResetStarInfoConfig.init()
    end
    
    if CustomSkillBookInfoConfig==nil then
        CustomSkillBookInfoConfig = require("src.DatReader.CustomSkillBookInfoConfig")
        CustomSkillBookInfoConfig.init()
    end

    startIndex = 0    -- 开始索引
    endIndex = 0      -- 结束索引
    activePets = {}   -- 战斗宠物列表
    unactivePets = {} -- 未战斗宠物列表
    unactivePetNum = 0-- 未战斗宠物数量
    activePetsRow = {}
    activeHelperPets = {}
    petArmy = {}
    petHelpArmy = {}

    if existPokemon==nil then
        existPokemon = {}
        for i=1,155 do
            local petFileName = string.format("Spine/pet/%03d.png", i)
            local fileExist = cc.FileUtils:getInstance():isFileExist(petFileName)
            if fileExist == true then
                table.insert(existPokemon, {id = i, res = petFileName, figure = 0})
            end
        end
        local maxSize = {131, 144, 145, 146, 149}
        for i=1, #maxSize do
            for var=1, #existPokemon do
                if existPokemon[var].id==maxSize[i] then
                    existPokemon[var].figure = 1
                end
            end
        end
    end
    curPokemon = 0
    curPokemonSkin = 0
    
    if watchRandomPetVec==nil then
        local petVec = SystemInfo.getGlobalConfigAddInfoByID(26201).values
        watchRandomPetVec = {}
        watchRandomPetVec.petID = petVec
        watchRandomPetVec.petIcon = {}
        for key, var in pairs(petVec) do
            watchRandomPetVec.petIcon[key] = PokemonInfo.getPokemonIconByID(var)
        end
    end
end

--获取宠物的体形（临时）
function PokemonInfo.getPokemonFigure(id)
    for var=1, #existPokemon do
        if existPokemon[var].id==id then
            return existPokemon[var].figure
        end
    end
    return 0
end

--设置跟随的宠物id和皮肤id
function PokemonInfo.setFollowPokemon(id, skinID)
    if curPokemon==id and curPokemonSkin==skinID then
        return
    end
    curPokemon = id
    curPokemonSkin = skinID
    EmbeddedMapMgr.setCharactorPet(id, skinID)
    TownMapMgr.setCharactorPet(id, skinID)
end

--获取跟随的宠物id和皮肤id
function PokemonInfo.getFollowPokemonID()
    if curPokemon==0 then
        return PokemonInfo.getRandomPokemonID()
    end
    return curPokemon, curPokemonSkin
end

--获取跟随的宠物动画资源
function PokemonInfo.getFollowPokemonRes()
    if curPokemon==0 then
        return PokemonInfo.getRandomPokemonRes()
    end
    return PokemonInfo.getPokemonResByID(curPokemon)
end

--根据ID获取宠物动画资源
function PokemonInfo.getPokemonResByID(id)
    local pinfo = PokemonInfo.getPokemonInfoByID(id)
    if not pinfo then
        return "Spine/pet/default.png"
    end
    local pid = pinfo.fightSkin
    local petFileName = string.format("Spine/pet/%03d.png", pid)
    local fileExist = cc.FileUtils:getInstance():isFileExist(petFileName)
    if fileExist then
        return petFileName
    else
        return "Spine/pet/default.png"
    end
end

--根据ID获取宠物背面动画资源
function PokemonInfo.getPokemonResBackByID(id)
    local pinfo = PokemonInfo.getPokemonInfoByID(id)
    if not pinfo then
        return "Spine/pet/defaultb.png"
    end
    local pid = pinfo.fightSkin
    local petFileName = string.format("Spine/pet/%03db.png", pid)
    local fileExist = cc.FileUtils:getInstance():isFileExist(petFileName)
    if fileExist then
        return petFileName
    else
        return "Spine/pet/defaultb.png"
    end
end

--根据ID获取宠物icon
function PokemonInfo.getPokemonIconByID(id)
    local pInfo = PokemonInfo.getPokemonInfoByID(id)
    local fileExist = false
    local petFileName = "Pet/PetIcon/default.png"
    if pInfo then
        local pid = pInfo.icon
        local fileName = string.format("Pet/PetIcon/%d.png", pid)
        fileExist = cc.FileUtils:getInstance():isFileExist(fileName)
        if fileExist then
            petFileName = fileName
        end
    else
        print(id.."宠物id不存在")
    end
    return petFileName
end

--随机获取已制作的宠物动画资源
function PokemonInfo.getRandomPokemonRes()
    local i = GetRandom.random(1, #existPokemon)
    return existPokemon[i].res
end

--随机获取已制作的宠物动画资源的id
function PokemonInfo.getRandomPokemonID()
    local i = GetRandom.random(1, #existPokemon)
    return existPokemon[i].id
end

function PokemonInfo.set(params)
    for var=1, #activePets do
        unactivePets[activePets[var].objID] = activePets[var]
    end
    for var=1, #activeHelperPets do
        unactivePets[activeHelperPets[var].objID] = activeHelperPets[var]
    end

    startIndex = params.startIndex
    endIndex = params.endIndex
    unactivePetNum = params.unactivePetNum
    activePetsRow = params.activePets

    local cjson = require("cjson")
    activePets = {}
    for key, var in pairs(params.activePets) do
        local tbl = cjson.decode(var)
        if tbl then
            PokemonInfo.refreshSciencePower(tbl)
            activePets[key] = tbl
            print("Pet Info:", tbl.objID, tbl.pokeID)
            unactivePets[tbl.objID] = nil
        end        
    end
    PokemonInfo.setFollowPokemon(activePets[1].pokeID, activePets[1].skin)
    print("当前激活宠物数量", #params.activePets)

    activeHelperPets = {}
    for key, var in pairs(params.activeHelperPets) do
        local tbl = cjson.decode(var)
        if tbl then
            PokemonInfo.refreshSciencePower(tbl)
            activeHelperPets[key] = tbl
            unactivePets[tbl.objID] = nil
        end        
    end
    print("当前helperPets宠物数量", #activeHelperPets)

    if params.unactivePets then
        for key, var in pairs(params.unactivePets) do
            local tbl = cjson.decode(var)
            if tbl ~= nil and tbl.objID ~= nil then
                PokemonInfo.refreshSciencePower(tbl)
                unactivePets[tbl.objID] = tbl
                print("Pet Info:", tbl.objID, tbl.pokeID)
            end
        end
    else
        return
    end

    print("当前未激活宠物数量", endIndex)
end

function PokemonInfo.refreshPet(objId, jsStr)
    local cjson = require("cjson")
    local tbl = cjson.decode(jsStr)
    PokemonInfo.refreshSciencePower(tbl)
    --BasicPetListMgr.refresh(tbl)
    PetEducationMgr.refreshPetEducation(tbl)
    for var=1, #activePets do
        if activePets[var].objID==objId then
            activePets[var] = tbl
            return
        end
    end
    for var=1, #activeHelperPets do
        if activeHelperPets[var].objID==objId then
            activeHelperPets[var] = tbl
            return
        end
    end

    local maxPetCount = PetFormationMgr.getMaxPetCount()
    local petArmy = clone(PokemonInfo.getPetArmy(1))
    local petHelpArmy = clone(PokemonInfo.getPetHelpArmy())
    local isNew = unactivePets[objId] == nil
    unactivePets[objId] = tbl

    local isRepeat = false
    for k,v in pairs(petArmy) do
        if PokemonInfo.getPetInfoByObjID(v).pokeID == tbl.pokeID then
            isRepeat = true
        end
    end
    for k,v in pairs(petHelpArmy) do
        if PokemonInfo.getPetInfoByObjID(v).pokeID == tbl.pokeID then
            isRepeat = true
        end
    end
    if not isRepeat then
        if isNew and #petArmy + #petHelpArmy < maxPetCount then
            if #petArmy < 3 then
                table.insert(petArmy, objId)
            else
                table.insert(petHelpArmy, objId)
            end
            NetInterface.sendWithBlock("GC_UpdatePetArmys_Ack", function()
                local PetSend = require("src.Net.Send.PetSend")
                PetSend.sendCG_UpdatePetArmys_Req({petArmys={{armyIndex=1, armyMembers=petArmy,helpArmyMembers = petHelpArmy}}})
            end, function()
                PokemonInfo.applyPrimaryArmy(petArmy, petHelpArmy)
            end, function(code)
                TipsMgr.showError(nil, code)
            end)
        end
    end
    BasicMenuMgr.setPetEductionRedPoint()
end

function PokemonInfo.setPetYokeInfoByObjID(objId, yoke)
    objId = tonumber(objId)
    -- for var=1, #activePets do
    --     if activePets[var].objID==objId then
    --         activePets[var].yoke = (yoke == 0) and {} or yoke
    --         return
    --     end
    -- end
    if unactivePets[objId] then
        unactivePets[objId].yoke = (yoke == 0) and {} or yoke
    else
        print("想羁绊的宠物在出战中")
    end
end

function PokemonInfo.deletePet(objId)
    for var=1, #activePets do
        if activePets[var].objID==objId then
            table.remove(activePets, var)
            return
        end
    end
    for var=1, #activeHelperPets do
        if activeHelperPets[var].objID==objId then
            table.remove(activeHelperPets, var)
            return
        end
    end
    unactivePets[objId] = nil
end

local function isPetMaterial(pokeID)
    return PokemonInfo.getPokemonInfoByID(pokeID).useType == Proto.ePUT_Material
end

function PokemonInfo.isPetMaterial(pokeID)
    return isPetMaterial(pokeID)
end

function PokemonInfo.getAllPets(excludePetMaterial, excludeYokePets)
    excludePetMaterial = excludePetMaterial or false
    excludeYokePets = excludeYokePets or false
    local allPetsArgs = {}
    local function checkValid(info)
        if excludePetMaterial then
            if isPetMaterial(info.pokeID) then
    			return false
    		end
    	end
        if excludeYokePets then
            if PetEducationMgr.isPetYoked(info) then
    			return false
    		end
    	end
    	return true
    end
    for var=1, #activePets do
        if checkValid(activePets[var]) then
            table.insert(allPetsArgs, activePets[var])
        end
    end
    for key, var in pairs(unactivePets) do
        if checkValid(var) then
            table.insert(allPetsArgs, var)
        end
    end
    for key, var in pairs(activeHelperPets) do
        if checkValid(var) then
            table.insert(allPetsArgs, var)
        end
    end
    --print("所有宠物数量：", #allPetsArgs)
    return allPetsArgs
end

function PokemonInfo.getExplorePets()
    local tmpVec = {}
    local allPet = PokemonInfo.getAllPets()
    for var=1, #allPet do
        if allPet[var].inExplore~=1 then
            table.insert(tmpVec, allPet[var])
        end
    end
    --[[
    for key, val in pairs(unactivePets) do
    local flag = true
    for var=1, #petArmy do
    for idx=1, #petArmy[var] do
    if petArmy[var][idx]==val.objID or val.inExplore==1 then
    flag = false
    end
    end
    end
    if flag then
    table.insert(tmpVec, val)
    end
    end]]
    print("当前可挂机宠物数量", #tmpVec)
    return tmpVec
end

function PokemonInfo.getActivePetsRow()
    return activePetsRow
end

function PokemonInfo.getStartIndex()
    return startIndex
end

function PokemonInfo.getEndIndex()
    return endIndex
end

function PokemonInfo.getUnactivePetNum()
    return unactivePetNum
end

function PokemonInfo.getActivePets()
    return activePets
end

function PokemonInfo.getActiveHelperPets()
    return activeHelperPets
end

function PokemonInfo.getActiveHelperPetsByObjID(id)
    for var=1, #activeHelperPets do
        if activeHelperPets[var].objID==id then
            return activeHelperPets[var]
        end
    end
    return nil
end

function PokemonInfo.getUnactivePets()
    return unactivePets
end

function PokemonInfo.getPetInfoByObjID(id)
    for var=1, #activePets do
        if activePets[var].objID==id then
            return activePets[var]
        end
    end
    for var=1, #activeHelperPets do
        if activeHelperPets[var].objID==id then
            return activeHelperPets[var]
        end
    end
    return unactivePets[id]
end

function PokemonInfo.refreshSciencePower(petInfo)
    local function setFc(info)
        local diff = ScienceInfo.getScienceFightPower(info.level)
        local preVal = info.sciencefc or 0
        info.fc = info.fc-preVal+diff
        info.sciencefc = diff
        if info.level>=ScienceInfo.getPetAttrLockLevel() then
            local diff = ScienceInfo.getScienceAttrsTable()[Proto.AT_HP] or 0
            local preVal = info.sciencehpmax or 0
            info.hpmax = info.hpmax-preVal+diff
            info.sciencehpmax = diff
        end
    end
    if petInfo then
        setFc(petInfo)
    	return
    end
    for var=1, #activePets do
        setFc(activePets[var])
    end
    for var=1, #activeHelperPets do
        setFc(activeHelperPets[var])
    end
    for key, var in pairs(unactivePets) do
        setFc(var)
    end
    StatusBarMgr.refreshFightPower(PetFormationMgr.getCurTab())
end

---atk/def/exp/hp/hpmax/level/objID/pokeID/satk/sdef/speed/updateTime(date)
--inExplore=1在挂机
function PokemonInfo.getActivePetsByObjID(idx)
    for var=1, #activePets do
        if activePets[var].objID==idx then
            return activePets[var]
        end
    end
    return nil
end

function PokemonInfo.updateActivePetsWithObjIDs(objIDs)
    if #objIDs ~= #activePets then return end
    local _acitvePets = {}
    for var=1, #objIDs do
        local petInfo = PokemonInfo.getActivePetsByObjID(objIDs[var])
        table.insert(_acitvePets, petInfo)
    end
    activePets = _acitvePets
end

function PokemonInfo.getUnactivePetsByObjID(idx)
    return unactivePets[idx]
end

-- Apply exactly the UIDs sent in a successful formation request. The
-- battle, formation editor and Pet collection share the same Pet objects.
function PokemonInfo.applyPrimaryArmy(members, helpers)
    local owned = {}
    for uid, pet in pairs(unactivePets) do
        owned[uid] = pet
    end
    for _, slots in ipairs({activePets, activeHelperPets}) do
        for _, pet in ipairs(slots) do
            owned[pet.objID] = pet
        end
    end
    local function assign(ids)
        local pets = {}
        for slot, uid in ipairs(ids) do
            local pet = owned[uid]
            if not pet then
                print("[FORMATION] cannot apply unknown or repeated UID", uid)
                return nil
            end
            pets[slot] = pet
            owned[uid] = nil
        end
        return pets
    end

    local nextActive = assign(members)
    local nextHelpers = assign(helpers)
    if not nextActive or not nextHelpers or #nextActive == 0 then
        return false
    end
    petArmy[1], petHelpArmy = members, helpers
    activePets, activeHelperPets, unactivePets = nextActive, nextHelpers, owned
    PokemonInfo.setFollowPokemon(activePets[1].pokeID, activePets[1].skin)
    StatusBarMgr.refreshFightPower(PetFormationMgr.getCurTab())
    return true
end

function PokemonInfo.setPetArmy(val)
    print("pet army info ---- start")
    for var=1, #val do
        print("pet army "..var..":")
        for i=1, #val[var] do
            print(val[var][i])
        end
    end
    print("pet army info ---- end")
    petArmy = val
    StatusBarMgr.refreshFightPower(PetFormationMgr.getCurTab())
end

function PokemonInfo.setHelpArmy(val)
    print("help army info ---- start")
    for var=1, #val do
        print("help army "..var..":")
        print(val[var])
    end
    print("help army info ---- end")
    petHelpArmy = val
    -- StatusBarMgr.refreshFightPower(PetFormationMgr.getCurTab())
end

function PokemonInfo.getPetArmy(idx)
    return petArmy[idx] or {}
end

function PokemonInfo.getPetHelpArmy()
    return petHelpArmy or {}
end

function PokemonInfo.setPetArmyByIdx(idx, objIDs)
    petArmy[idx] = objIDs
end

---获取技能icon路径
--@param skillID int 技能id
function PokemonInfo.getSkillIcon(skillID)
    local skilliconID = PokemonInfo.getPetSkillInfoById(skillID).icon or "nil"
    local iconID = tonumber(skilliconID) or "default"
    local petFileName = "Battle/skillIcon/"..iconID..".png"
    local fileExist = cc.FileUtils:getInstance():isFileExist(petFileName)
    if fileExist then
        return petFileName
    else
        return "Battle/skillIcon/default.png"
    end
end

---获取属性icon图片路径
--@param attriID int 属性id
--@return #2 前面是属性icon,后面是属性icon底板
function PokemonInfo.getAttriPics(attriID)
    return "Pet/AttriIcon/"..attriID..".png", "Pet/AttriIcon/small_"..attriID..".png"
end

---获取品阶图片
function PokemonInfo.getStagePics(stageID, attriinfo, rarePoint)
    local frameRes = "Pet/BasicPetList_2/Stage/"..rarePoint..".png"
    local circleRes = "Pet/AttriIcon/small_"..attriinfo..".png"
    local vec = {p1=frameRes, p2=circleRes}
    return vec
end

---获取宠物战斗力
--@param petInfoVec table 宠物信息组
local function petFightPoint(info)
    if not info then
        return 0
    end
    if (info.fc or 0) > (info.sciencefc or 0) then
        return info.fc
    end

    -- The local server does not send base combat power. Reuse the detail
    -- view's calculation against this pet's current attributes and links.
    local source = info.yoke and info.yoke.yokeValues or {}
    local yokeValues = {}
    for index = 1, 6 do
        yokeValues[index] = source[index] or 0
    end
    return PetEducationMgr.calPetFC(PokemonInfo.getPokemonInfoByID(info.pokeID),
        info, yokeValues, {0,0,0,0,0,0})
end

function PokemonInfo.getFightPoint(petInfoVec)
    local fc = 0
    for _, info in pairs(petInfoVec) do
        fc = fc + petFightPoint(info)
    end
    return fc
end

---获取宠物战斗力
--@param petObjIDVec table 宠物objID组
function PokemonInfo.getFightPointByObjID(petObjIDVec)
    local fc = 0
    for _, id in pairs(petObjIDVec) do
        fc = fc + petFightPoint(PokemonInfo.getPetInfoByObjID(id))
    end
    return fc
end

--[[
data.id=Proto.parsePetID(entry); -- 宠物ID
data.name=Proto.parseLifeNick(entry); -- 宠物昵称
data.useType=Proto.parseDWORD(entry); -- 宠物类型(用途)
data.sexRate=Proto.parseDWORD(entry); -- 宠物性别率
data.fightSkin=Proto.parseString(entry); -- 宠物战斗皮肤
data.icon=Proto.parseString(entry); -- 宠物头像
data.rarePoint=Proto.parseDWORD(entry); -- 宠物稀有度
data.elementAtt1=Proto.parseDWORD(entry); -- 宠物元素属性1
data.elementAtt2=Proto.parseDWORD(entry); -- 宠物元素属性2
data.desc=Proto.parseString(entry); -- 宠物描述
data.petWay=Proto.parseString(entry); -- 宠物足迹
data.lifeRateValue=Proto.parseDWORD(entry); -- 生命种族值
data.atkRateValue=Proto.parseDWORD(entry); -- 物攻种族值
data.defRateValue=Proto.parseDWORD(entry); -- 物防种族值
data.satkRateValue=Proto.parseDWORD(entry); -- 特攻种族值
data.sdefRateValue=Proto.parseDWORD(entry); -- 特防种族值
data.speedRateValue=Proto.parseDWORD(entry); -- 速度种族值
data.yokeVec=Proto.parseVector(entry,Proto.parseWORD); -- 羁绊
data.topLevel=Proto.parseWORD(entry); -- 最高等级
data.skins=Proto.parseVector(entry,Proto.parseSkinInfo); -- 形态组
data.gainParam=Proto.parseDWORD(entry); -- 获取参数
data.eatCost=Proto.parseDWORD(entry); -- 吞噬消耗
--]]
function PokemonInfo.getPokemonInfoByID(id)
    id = tonumber(id)
    return PetInfoData[id]--PokemonInfoConfig.readEntryByID(id)
end

function PokemonInfo.getPokemonInfoAllID()
    local vec = {}
    local vec2 = {}
    for i = 1,18 do
        local datatable = {}
        table.insert(vec2,datatable)
    end
    for var=1, PokemonInfoConfig.getEntryCount() do
        local id = PokemonInfoConfig.getEntryID(var)
        local data = PokemonInfo.getPokemonInfoByID(id)
        if data.icon ~= "0" and data.useType == Proto.ePUT_Fight then
            table.insert(vec, data)
            table.insert(vec2[tonumber(data.elementAtt1)],data)
        end
    end
    return vec,vec2
end
--[[
data.id=Proto.parseDWORD(entry); -- ID
data.name=Proto.parseString(entry); -- 技能名称
data.skillAtt=Proto.parseDWORD(entry); -- 技能属性
data.skill_A_Type=Proto.parseDWORD(entry); -- 技能类型
data.skill_B_Type=Proto.parseDWORD(entry); -- 技能分类
data.skillPresupposed=Proto.parseDWORD(entry); -- 技能预设
data.skillAllTime=Proto.parseDWORD(entry); -- 技能总时间
data.power=Proto.parseDWORD(entry); -- 技能威力
data.airpower=Proto.parseDWORD(entry); -- 技能威力
data.groundpower=Proto.parseDWORD(entry); -- 技能威力
data.hitRate=Proto.parseDWORD(entry); -- 技能命中率
data.pp=Proto.parseDWORD(entry); -- PP
data.energy=Proto.parseDWORD(entry); -- 奥义能量
data.speed=Proto.parseDWORD(entry); -- 指令速度
data.icon=Proto.parseString(entry); -- 技能图标
data.preinstall=Proto.parseString(entry); -- 技能预设
data.effect=Proto.parseString(entry); -- 技能效果
data.parameterA=Proto.parseDWORD(entry); -- 技能参数A
data.parameterB=Proto.parseDWORD(entry); -- 技能参数B
data.parameterC=Proto.parseDWORD(entry); -- 技能参数C
data.parameterD=Proto.parseDWORD(entry); -- 技能参数D
data.parameterE=Proto.parseDWORD(entry); -- 技能参数E
data.desc=Proto.parseString(entry); -- 技能描述
data.upItemType=Proto.parseDWORD(entry); -- 升级道具
data.triggerTypes=Proto.parseString(entry); -- 触发时机
--]]
function PokemonInfo.getPetSkillInfoById(id)
    --return PetSkillInfoConfig.readEntryByID(id)
    return BattleInfo.getSkillInfoByID(id)
end

--[[
Proto.writeDWORD(msg,data.id); -- ID
Proto.writeDWORD(msg,data.myAction); -- 己方动作
Proto.writeDWORD(msg,data.hisAction); -- 对方反应
Proto.writeString(msg,data.readyAni); -- 蓄力动画
Proto.writeString(msg,data.fireAniBg); -- 释放动画底层
Proto.writeString(msg,data.fireAniTop); -- 释放动画顶层
Proto.writeString(msg,data.beAttackedAni); -- 击中动画
Proto.writeString(msg,data.sound); -- 音效
Proto.writefloat(msg,data.aniPos); -- 动画位置
Proto.writefloat(msg,data.bgUD); -- 背上下
Proto.writefloat(msg,data.bgLR); -- 背左右
Proto.writefloat(msg,data.topUD); -- 正上下
Proto.writefloat(msg,data.topLR); -- 正左右
Proto.writefloat(msg,data.firePointUD); -- 弹道打击点上下
Proto.writefloat(msg,data.firePointLR); -- 弹道打击点左右
Proto.writeString(msg,data.typeIcon); -- 类型图标
--]]
function PokemonInfo.getSkillPlayById(id) 
    return SkillPlayConfig.readEntryByID(id) 
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.name=Proto.parseString(entry); -- 名称
data.desc=Proto.parseString(entry); -- 效果描述
data.icon=Proto.parseString(entry); -- 状态图标
data.animation=Proto.parseString(entry); -- 状态动画
data.onlyType=Proto.parseDWORD(entry); -- 唯一性
data.changePetClear=Proto.parseDWORD(entry); -- 换宠解除
data.effect=Proto.parseString(entry); -- 具体效果
--]]
function PokemonInfo.getPetBufferInfoByID(id)
    return PetBufferInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- 宠物种族
data.PetEvoLevelInfoVec=Proto.parseVector(entry,Proto.parsePetEvoLevelInfo); -- 宠物进化时各种可能等级对应的信息
<>
data.level=Proto.parseWORD(entry); -- 进化需要的等级
data.stageCons=Proto.parseVector(entry,Proto.parseDWORD); -- 宠物进化消费
data.EvoRateInfoVec=Proto.parseVector(entry,Proto.parseEvoRateInfo); -- 宠物进化消费
<<>>
data.rate=Proto.parseDWORD(entry); -- 进化概率
data.newRace=Proto.parseDWORD(entry); -- 新种族
data.EvoSkillVec=Proto.parseVector(entry,Proto.parseEvoSkillInfo); -- 可能学会的技能们。。
<<<>>>
data.skillType=Proto.parseDWORD(entry); -- 技能类型
data.skillArrID=Proto.parseDWORD(entry); -- 技能组索引
<<<>>>
<<>>
<>
]]--
function PokemonInfo.getPetEvoInfoByID(id)
    return PetEvoInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- 强化次数
data.consumeType=Proto.parseVector(entry,Proto.parseDWORD); -- 材料
data.consumeCount=Proto.parseDWORD(entry); -- 份数
data.gcash=Proto.parseDWORD(entry); -- 消耗G币
]]--
function PokemonInfo.getPetStrengthenInfo(id)
    return PetStrengthenInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); --
data.name=Proto.parseString(entry); --
data.topStage=Proto.parseDWORD(entry); --
data.stages=Proto.parseVector(entry,Proto.parseStageCons); --
<>
data.stageCons=Proto.parseVector(entry,Proto.parseDWORD); -- 宠物进阶消费
<>
]]--
function PokemonInfo.getPetAdvanceInfo(id)
    return PetAdvanceInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.yokeType=Proto.parseWORD(entry); -- 羁绊类型
data.effectVec=Proto.parseVector(entry,Proto.parseWORD); -- 效果们
data.yokeArgsVec=Proto.parseVector(entry,Proto.parseYokeArgs); -- 条件参数们
<>
Proto.writeDWORD(msg,data.needID); -- 需求参数
Proto.writeDWORD(msg,data.arg1); -- 参数1
Proto.writeDWORD(msg,data.arg2); -- 参数2
<>
]]--
function PokemonInfo.getYokeInfoByID(id)
    return YokeInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.type=Proto.parseWORD(entry); -- 类型
data.arg=Proto.parseDWORD(entry); -- 参数
]]--
function PokemonInfo.getYokeEffectByID(id)
    return YokeEffectConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- 星级
data.starexp=Proto.parseDWORD(entry); -- 总经验
data.starpoint=Proto.parseDWORD(entry); -- 升星附加值
]]
function PokemonInfo.getPetStarUpInfoByID(id)
    if id == 0 then
        return {id=0,starexp=0,starpoint=0,}
    end
    return PetStarUpInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.rarity=Proto.parseDWORD(entry); -- 宠物稀有度
data.skill_s=Proto.parseDWORD(entry); -- 技能碎片
data.dreamCash=Proto.parseDWORD(entry); -- 梦想币
data.wishCash=Proto.parseDWORD(entry); -- 心愿币
data.scienceItem=Proto.parseDWORD(entry); -- 
data.scienceItemNum=Proto.parseVector(entry,Proto.parseDWORD); -- 
]]
function PokemonInfo.getPetFreedomAwardInfoByID(id)
    return PetFreedomAwardInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.name=Proto.parseVector(entry,Proto.parsePetAwardGroupInfo); -- 奖励组
]]
function PokemonInfo.getPetFreedomAwardGroupInfoByID(id)
    return PetFreedomAwardGroupInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- 星数
data.Fvalue=Proto.parseVector(entry,Proto.parseDWORD); -- 附加值
]]
function PokemonInfo.getPetFreedomStarpointInfoByID(id)
    return PetFreedomStarpointInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- 扭蛋类型
data.normalEggAwardIndex=Proto.parseWORD(entry); -- 每次扭蛋奖励组项
data.OneEggCons=Proto.parseDWORD(entry); -- 扭一次消费
data.tenEggCons=Proto.parseDWORD(entry); -- 扭十次消费
data.expELem=Proto.parseDWORD(entry); -- 经验药水奖励元素经验药水奖励元素
data.freeTimes=Proto.parseDWORD(entry); -- 每日免费次数
data.CD=Proto.parseDWORD(entry); -- 免费扭蛋的冷却时间
data.firstEggAwardIndex=Proto.parseWORD(entry); -- 首抽奖励组项
data.firstTenEggAwardIndex=Proto.parseWORD(entry); -- 首次十连奖励组项
data.normalTenEggAwardIndex=Proto.parseWORD(entry); -- 普通十连奖励组项
data.tenTimesEggAwardIndex=Proto.parseWORD(entry); -- 十次内必出奖励组项
data.vipLevel=Proto.parseWORD(entry); -- VIP等级限制
data.wishName=Proto.parseString(entry); -- 心愿名称
data.wishValuePer=Proto.parseDWORD(entry); -- 心愿单次附加值
data.wishCost=Proto.parseDWORD(entry); -- 心愿附加值消耗
data.wishAwards=Proto.parseDWORD(entry); -- 附加值可用时，奖池
data.wishAwardsCount=Proto.parseDWORD(entry); -- 可选个数
data.dreamName=Proto.parseString(entry); -- 梦想
data.dreamValuePer=Proto.parseDWORD(entry); -- 梦想单次附加值
data.dreamCost=Proto.parseDWORD(entry); -- 梦想消耗
data.dreamAwards=Proto.parseDWORD(entry); -- 梦想奖池
data.dreamAwardsCount=Proto.parseDWORD(entry); -- 可选个数
]]
function PokemonInfo.getCapsuleEggInfoByID(id)
    return CapsuleEggInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- 奖励组的索引
data.awardInfoVec=Proto.parseVector(entry,Proto.parseCapsuleEggRateAward); -- 奖励及概率的数组
]]
function PokemonInfo.getCapsuleEggAwardInfoByID(id)
    return CapsuleEggAwardInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- 宠物种族
data.geneGroup=Proto.parseVector(entry,Proto.parsePetGeneGroupInfo); -- 技能组
<>
data.prob=Proto.parseDWORD(entry); -- 概率
data.prob_skillID=Proto.parseDWORD(entry); -- 技能ID
<>
]]
function PokemonInfo.getGeneProbabilityInfoByID(id)
    return GeneProbabilityInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.petID=Proto.parseDWORD(entry); -- 宠物ID
data.skill_1=Proto.parseDWORD(entry); -- 技能1
data.skill_2=Proto.parseDWORD(entry); -- 技能2
data.skill_3=Proto.parseDWORD(entry); -- 技能23
data.profound=Proto.parseDWORD(entry); -- 奥义
data.passiveSkills=Proto.parseVector(entry,Proto.parsePassiveSkillInfo); -- 被动技能
]]
function PokemonInfo.getGeneInfoByID(id)
    return GeneInfoConfig.readEntryByID(id)
end

function PokemonInfo.getGeneInfoCount()
    return GeneInfoConfig.getEntryCount()
end

function PokemonInfo.getGeneInfoByIndex(idx)
    return GeneInfoConfig.readEntry(idx)
end

--[[
data.id=Proto.parseDWORD(entry); -- 积分
data.scores=Proto.parseVector(entry,Proto.parseDWORD); -- 星级积分
]]
function PokemonInfo.getYokeScoreInfoByID(id)
    return YokeScoreConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- 积分
data.effectValues=Proto.parseVector(entry,Proto.parsefloat); -- 属性值组
]]
function PokemonInfo.getYokeEffectPosByID(id)
    return YokeEffectPosConfig.readEntryByID(id)
end

function PokemonInfo.getWatchRandomPetVec()
    return watchRandomPetVec or {}
end

function PokemonInfo.getPetResetStarInfoById(id)
    return PetResetStarInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- 
data.petIDs=Proto.parseVector(entry,Proto.parseDWORD); -- 
]]
function PokemonInfo.getCustomSkillBookInfoById(id)
    return CustomSkillBookInfoConfig.readEntryByID(id)
end

return PokemonInfo