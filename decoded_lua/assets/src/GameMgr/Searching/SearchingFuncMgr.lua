--[[
    #方格狀態說明:
        ##第一觸發態，也即未觸發態
        ##第二觸發態，也即中間態，介於觸發與觸發之間，如可推動的石頭第二觸發態則爲可推動狀態
        ##第三觸發態，也即末態，一般爲障礙物消除完畢狀態，
    #方格狀態同時也是map重新進入時取方格資源用，對應狀態有相應的狀態資源
]]--

require("src.framework.cc.utils.bit")


local SearchingFuncMgr = {}

SearchingFuncMgr.advAwards = {}

function SearchingFuncMgr.Init()
end

-- 默认事件回调
local function defaultFunc()
end

--++++++++++++++++    config    ++++++++++++++++++

--switchs which need to reset when floor changes
local SWITCH_RESET_TABLE = {
    "brokengrass",
}

--reset switchs
local function resetAllSwitchs()
    for i=1, LtMapOption.getMapSize() do
        if SearchingMgr.eventInfoTable[i] == SearchingMapMgr.EVENT_SWITCH then
            for k, v in pairs(SWITCH_RESET_TABLE) do
                if SearchingMgr.itemTypeTable[i].name == v then
                    SearchingMgr.eventStateInfoTable[i] = 1
                end
            end
        end
    end
end

---根据目标方格参数更新方格状态
--@param k int 目标方格变化
--@param state int 目标方格变化后状态
function SearchingFuncMgr.update_blockState(k, state, floor)

    floor = floor or SearchingMapMgr.currFloor

    local mapInfoTable = SearchingMapMgr.floorMapInfoTbl["floor"..floor]
    local monsterDefendInfo = SearchingMapMgr.floorMstrDefendTbl["floor"..floor]
    local eventStateInfoTable = SearchingMapMgr.floorEventStateTbl["floor"..floor]
    local eventInfoTable = SearchingMapMgr.floorEventTbl["floor"..floor]

    if mapInfoTable[k] == 2 then
        mapInfoTable[k] = 1
        monsterDefendInfo[k] = 0
        if floor == SearchingMapMgr.currFloor then
            SearchingUIMgr.activeSlab(k)
        end
    elseif mapInfoTable[k] == 1 then
        SearchingMgr.mistHidAt(k)
    end
    
    if state == 0 then
        eventStateInfoTable[k] = 3    --觸發態
        eventInfoTable[k] = SearchingMapMgr.EVENT_VOID
    else
        eventStateInfoTable[k] = state
        if floor == SearchingMapMgr.currFloor then
            SearchingUIMgr.setBlockUI(k, SearchingUIMgr.BLOCK_SIZE)
        end
    end

    if eventStateInfoTable[k] == 3 then
        SearchingMgr.checkGoals(k)
        SearchingMgr.unlockTonari(k)
        if floor == SearchingMapMgr.currFloor then
            SearchingUIMgr.setBlockUI(k, SearchingUIMgr.BLOCK_SIZE)
        end
    end

    if state == 3 and eventInfoTable[k] == SearchingMapMgr.EVENT_OBSTRUCTION then
        SearchingMgr.eventInfoTable[k] = SearchingMapMgr.EVENT_VOID
        SearchingMgr.unlockTonari(k)
    end

    if state == 1 then
        if SearchingMapMgr.OriginalData[2]["floor"..floor][k] == SearchingMapMgr.EVENT_OBSTRUCTION then
            SearchingMgr.eventInfoTable[k] = SearchingMapMgr.OriginalData[2]["floor"..floor][k]
        end
    end

    if eventInfoTable[k] == SearchingMapMgr.EVENT_PICKING and floor == SearchingMapMgr.currFloor then
        SearchingUIMgr.itemDrop(k, 0.5*SearchingUIMgr.BLOCK_HEIGHT, 0.5)
    end

    if SearchingMgr.itemTypeTable[k].isGround and tonumber(SearchingMgr.itemTypeTable[k].isGround) == 1 then
        if floor == SearchingMapMgr.currFloor then
            SearchingUIMgr.resetGroudImg(k)

            local eff = AnimationMgr.getGafObj("Gaf/Searching/water.gaf",k)
            if eff then
                AnimationMgr.removeGafObjectByTag(eff.res,eff.tag)
            end
        end
    end
end

-- 更新方格i对应的target状态
function SearchingFuncMgr.update_all_targerts(i)
    local  strtbl = SearchingMapMgr.floorTargetBlocks["floor"..SearchingMapMgr.currFloor][i]
    if type(strtbl) == "table" then
        local tbl = clone(strtbl[1])
        local x, y = tonumber(tbl[2]), tonumber(tbl[3])
        local firstBlock = LtMapOption.convertToIndex(y, x)

        SearchingMgr.canMove = false
        local scrollview = CSResourceMgr.getNodeByName(SearchingUIMgr.centerResName,"fog")
        DungeonMapMgr.scrollMapWithCellID(scrollview, firstBlock)
        SceneMgr.getRunningScene:performWithDelay(function()
            SearchingMgr.canMove = true
            local floor, block
            for _, var in pairs(strtbl) do
                local tbl = clone(var)
                local x, y = tonumber(tbl[2]), tonumber(tbl[3])
                floor = tonumber(tbl[1])
                block = LtMapOption.convertToIndex(y, x)
                SearchingFuncMgr.update_blockState(block, tonumber(tbl[4]), floor)
            end
        end, 0.25+0.05)
    end
end

local addtionalCheck = nil   -- 附加检查函数，暂时用于引导
local addtionalCallback = nil  -- 方格附加回调

function SearchingFuncMgr.setAddtionalCheck(func)
    addtionalCheck = func
end

function SearchingFuncMgr.clearAddtionalCheck()
	addtionalCheck = nil
end

function SearchingFuncMgr.setAddtionalCallback(func)
    addtionalCallback = func
end

function SearchingFuncMgr.clearAddtionalCallback()
    addtionalCallback = nil
end

---检查指定方格事件，触及事件
--返回false將強制終止人物行走
function SearchingFuncMgr.check_(i)
    if SearchingMgr.ADV_DEBUG then
        print("check at:",i, SearchingMgr.eventInfoTable[i])
    end
    
    local type = SearchingMgr.eventInfoTable[i]
    
    local callback = SearchingFuncMgr.getEventFunc(i)
    
    if type == SearchingMapMgr.EVENT_EXIT then
        if callback then callback(i) end
        return false
    end

    if type == SearchingMapMgr.EVENT_PICKING
    or type == LtEventOption.EVENT_C_AWARDS 
    or type == LtEventOption.EVENT_COLLECTION
    then
        if callback then callback(i) end
        return false
    end
    
    --機關爲未觸發態（即第一觸發態）時進行機關事件處理
    if type == LtEventOption.EVENT_PORTAL
    or type == LtEventOption.EVENT_SWITCH 
    then
        if addtionalCheck then
            if not addtionalCheck(i) then
                if addtionalCallback then addtionalCallback() end
            end
        end
        if callback then callback(i) end
        if SearchingMgr.eventInfoTable[i] == LtEventOption.EVENT_PORTAL then
            return false
        end
        if SearchingMgr.itemTypeTable[i].name == "brokengrass" and SearchingMgr.eventStateInfoTable[i] == 2 then
            return false
        end
    end
    
    if type == LtEventOption.EVENT_TRAP
    or type == LtEventOption.EVENT_HEALPOINT
    or type == LtEventOption.EVENT_BUFF
    then
        if callback then callback(i) end
        return false
    end
    
    if addtionalCheck then
        if not addtionalCheck(i) then
            if addtionalCallback then addtionalCallback() end
            return false
        end
    end
    
    return true

end

function SearchingFuncMgr.showPotentialSkill(parent,pSkill,posx,posy)
    if not parent then
        return nil
    end
    local filename = "Searching/skillEffect.csb"
    local tag = tostring(parent)
    local node = CSResourceMgr.createRes(parent, filename, tag)
    local pet = CSResourceMgr.getNodeByName(filename,"petAva",tag)
    local pos = {x=0,y=0}
    LostTowerUIMgr.showPotentialSkill(pet,pSkill,tag,pos,false)

    CSResourceMgr.playAllFrame(filename, true, tag)
    node:setPosition(posx, posy)
    node:setLocalZOrder(100)
    node:setScale(0.9)
    
    node:performWithDelay(function()
        transition.fadeOut(node, {time = 0.5})
    end, 1.5)
    node:performWithDelay(function()
        CSResourceMgr.removeCSObjectByTag(filename, tag)
    end, 2.0)
end 

---loadstring调用函数
--@param str string 函数名
--@param param int 传入参数
function SearchingFuncMgr.callFuncWithStr(str, param)
    local f = loadstring(str.."("..tostring(param)..")")
    f()
end

--  ####################  picking function  #########################

---拾取物品效果
local function pickingEffect(block, iteminfo, closeCallback)
    local resName = "Searching/GetItemLayer.csb"

    --覆蓋屏蔽層
    local shadow = CSResourceMgr.createRes(SceneMgr.getRunningScene,resName)

    CocosModuleMgr.setRelativePosition(shadow, 320, 480)

    local item = CSResourceMgr.getNodeByName(resName,"item")
    item:setContentSize(104, 138)
    item:setVisible(false)

    local img = SearchingUIMgr.getItemImg(block, 1)
    item:loadTexture(img)
    
    SearchingMgr.canMove = false

    shadow:performWithDelay(function()
        item:setVisible(true)
        CSResourceMgr.playAction(resName, 0, 40, false)
    end, 0.1)

    local effect = CSResourceMgr.getNodeByName(resName,"effect")
    local stars = AnimationMgr.createAni(effect, "Spine/effects/stars.png", SearchingUIMgr.PNG_WIDTH/10, SearchingUIMgr.PNG_HEIGHT/3)
    AnimationMgr.playAni("Spine/effects/stars.png", "animation", true)
    local text = CSResourceMgr.getNodeByName(resName,"Text")
    local desc = iteminfo.desc
    CSResourceMgr.setLabelString(resName, "Text", desc, "", {r=0,g=0,b=0,a=255})

    shadow:performWithDelay(function()
        SearchingMgr.canMove = true
        CSResourceMgr.removeCSObjectByTag(resName)
    end, 1.0)
    CSResourceMgr.clickEventBinding(resName,"shadow",function()  --close directly
        transition.stopTarget(shadow)
        SearchingMgr.canMove = true
        CSResourceMgr.removeCSObjectByTag(resName)
        if closeCallback then closeCallback() end
    end)
    
    GameAudio.playUISound("itemCollect")
    
end

function SearchingFuncMgr.showAdvAwards(awardsInfo, callback)
    if not awardsInfo then 
        if callback then callback() end
        return
    end
    
    AwardsListMgr.show(SceneMgr.getRunningScene, awardsInfo)
    if callback then callback() end
end

local function addToPickingRecord(record, info, count)
    if info.type == "1" then  -- 副本道具
        table.insert(record, {type = info.type, info = info})
    else
        for k, v in pairs(record) do
            if v.type == info.type then
                v.count = v.count + count
                return
            end
        end
        table.insert(record, {type = info.type, count = count})
    end
end

---拾取事件
function SearchingFuncMgr.pickingFuncAt(i)
    if LtMapOption.getMapType() == "LOSTTOWER" then
        LtFuncMgr.pickingFunc(i)
        return
    end

    SearchingUIMgr.TurnToBlock(i)
    
    if SearchingMgr.eventStateInfoTable[i] ~= 1 then
        print("ADV_DEBUG_INFO:", "可能已经拾取")
        return
    end
    
    local eventInfo = SearchingMgr.itemTypeTable[i]
    
    local function __canPick()
        if eventInfo.type == "6" then -- 需要拾取条件
            local cond = SearchingMgr.itemTypeTable[i].cond  --消除条件, type::string
            local skillIDs = {}
            for k,v in pairs(cond) do
                if v[1] == "0" then
                    table.insert(skillIDs,tonumber(v[2]))
                end
            end
            
            local m_pet, h_pet = AdvPetsMgr.getCurrMyPets()
            local pets = {
                m_pet = m_pet, 
                h_pet = h_pet,
            }
        
            if not AdvPetsMgr.useSkill(pets, skillIDs) then
                local skill, level = AchievementListMgr.getSkillUpInfo("tool")
                
                if skill then
                    local pSkill = {info = skill, level = level}
                    SearchingFuncMgr.showPotentialSkill(SearchingMgr.player,pSkill,-20,90)
                else
                    local desc = "advtips2"
                    local scene = SceneMgr.getRunningScene
                    require("src.GameMgr.Searching.SkillMissingView").show(scene, 10*skillIDs[1]+1)
    
                    return false
                end
            end
        end
        
        return true
    end
    
    --获取事件描述
    local desc = LuaSqlite.getLanguageByKey(SearchingMgr.itemTypeTable[i].desc)
    
    local function successCallback()
        --拾取物品效果
        pickingEffect(i, SearchingMgr.itemTypeTable[i],function()
            SearchingMgr.eventStateInfoTable[i] = 3
            SearchingMgr.checkGoals(i)    --檢查函數更新顯示
            SearchingUIMgr.clearBlock(i)  --重新綁定底板事件
        end)

        --道具栏添加道具
        if SearchingMgr.itemTypeTable[i].type == "1" then  --道具
            local icon = "Searching/env/Common/"..SearchingMgr.itemTypeTable[i].res1..".png"
            local index = #SearchingMapMgr.allItems + 1
            local propMgr = require("src.GameMgr.Searching.propMgr")
            propMgr.addProp(index,icon,SearchingMgr.itemTypeTable[i])
        elseif SearchingMgr.itemTypeTable[i].type == "2" then  --金币
            SearchingMapMgr.currCoinNum = SearchingMapMgr.currCoinNum + 1
            local coinNum = CSResourceMgr.getNodeByName("Searching/topBar/topBar.csb","coinNum")
            if coinNum then coinNum:setString("X"..tostring(SearchingMapMgr.currCoinNum)) end
        elseif SearchingMgr.itemTypeTable[i].type == "3" then  --宝箱
            SearchingMapMgr.currGainNum = SearchingMapMgr.currGainNum + 1
            local gainNum = CSResourceMgr.getNodeByName("Searching/topBar/topBar.csb","gainNum")
            if gainNum then gainNum:setString("X"..tostring(SearchingMapMgr.currGainNum)) end
        end
        
        addToPickingRecord(SearchingMapMgr.pickingRecord[SearchingMapMgr.currFloor], SearchingMgr.itemTypeTable[i], 1)
        
        -- 更新一次性事件触发记录
        LtEventOption.updateDispEventRecord(i)

        SceneMgr.getRunningScene:performWithDelay(function()
            SearchingMgr.eventStateInfoTable[i] = 3
            SearchingMgr.checkGoals(i)    --檢查函數更新顯示
            SearchingUIMgr.clearBlock(i)  --重新綁定底板事件
        end, 1.0)
    end
    
    local function __send()
        if NetInterface.isConnect then
            NetInterface.sendWithBlock("GC_GETADVENTUREAWARD_ACK",function()
                local col, row = LtMapOption.convertToCoord(i)
                local AdventureSend = require("src/Net/Send/AdventureSend.lua")
                print("coord:",row,col)
                AdventureSend.sendCG_GetAdventureAward_Req({floor=SearchingMapMgr.currFloor,field=col,row=row})
            end,function()
                successCallback()
            end)
        end
    end
    
    if __canPick() then
        if not SearchingMgr.itemTypeTable[i].picked then
            __send()
        else
            SearchingMgr.eventStateInfoTable[i] = 3
            SearchingMgr.checkGoals(i)    --檢查函數更新顯示
            SearchingUIMgr.clearBlock(i)  --重新綁定底板事件
        end
    end
    
end

---随机事件
function SearchingFuncMgr.randomFuncAt(i)
    if LtMapOption.getMapType() == "LOSTTOWER" then
        LtFuncMgr.random_func(i)
        return
    end
end

function SearchingFuncMgr.battle_monsterFunc_onClick_At(i)
    if LtMapOption.getMapType() == "LOSTTOWER" and not LostTowerMgr.hasEnoughSteps(LostTowerMgr.currentFloor) then
        StandardTipsMgr.show(1, "LtTips24")   -- "步数不够"
        return
    end

    if LtMapOption.getMapType() == "ADVENTURE" and SearchingMgr.isFailed then print("battle failed in fuben.") return end
    
    SearchingUIMgr.TurnToBlock(i)

    local id = SearchingMgr.itemTypeTable[i].monsterID

    local battleType, battleTypeSubID
    if LtMapOption.getMapType() == "ADVENTURE" then
        battleType = Proto.BTT_ADVENTURE_MONSTER
        battleTypeSubID = 0
    else
        battleType = Proto.BTT_LOSTTOWER_MONSTER
        local c,r = LtMapOption.convertToCoord(i)
        battleTypeSubID = bit.blshift(r, 4) + c
        print("r, c, r_lsh_4, bTypeSubID:",r,c,bit.blshift(r, 4),battleTypeSubID)
    end
    
    local name = "野生"
    local battleInfo = {
        name=name, 
        pets={id,},
        sceneID = SearchingMapMgr.sceneID["floor"..SearchingMapMgr.currFloor][i],
        type = battleType,
        battleTypeSubID = battleTypeSubID,
        callback = function(detail)
            SearchingMapMgr.battleResult = detail.result
            if detail.result ~= PLAYER_WIN then return end  -- 0:失败 1:胜利 2:平局
            
            detail.me.hp = LtPlayerMgr.recoverFromFashion(detail.me.objID, detail.me.hp)

            LtPetsMgr.petsAfterBattle, _ = LtPetsMgr.handleHpAfterBattle(detail.me.objID, detail.me.hp)
            
            if LtMapOption.getMapType() == "ADVENTURE" then
                -- 筛选出战斗一次性事件
                local tmpTable = {}
                for i = 1, SearchingMgr.floors do
                    tmpTable[i] = {}
                end
                for block, events in pairs(SearchingMapMgr.firedDisposableEvents[SearchingMapMgr.currFloor]) do
                    print(SearchingMapMgr.currFloor, i, block)
                    if i == block then
                        table.insert(tmpTable[SearchingMapMgr.currFloor], events)
                    end
                end
                
                LtEventOption.fireDisposableEvent(SearchingMapMgr.currAdventure, tmpTable, function()
                    BattleMapMgr.sendGameOver(detail.result,detail.me)
                    SearchingMapMgr.disposableFireFlag = false
                    if SearchingMapMgr.firedDisposableEvents[SearchingMapMgr.currFloor]
                    and SearchingMapMgr.firedDisposableEvents[SearchingMapMgr.currFloor][i]
                    then
                        SearchingMapMgr.firedDisposableEvents[SearchingMapMgr.currFloor][i].fireFlag = false
                    end
                    -- SearchingMapMgr.clearDispEvents()
                end)
            elseif LtMapOption.getMapType() == "LOSTTOWER" then
                BattleMapMgr.sendGameOver(detail.result,detail.me)
                local _col,_row = LtMapOption.convertToCoord(i)
                NetInterface.sendWithBlock("GC_FIREEVENTCELL_ACK", function()
                    local LostTowerSend = require("src/Net/Send/LostTowerSend.lua")
                    LostTowerSend.sendCG_fireEventCell_Req({ x=_row, y=_col, })
                end, function()
                end)
            end
        end,
    }

    if SearchingMgr.itemTypeTable[i].clear and LtMapOption.getMapType() == "ADVENTURE" then
        SearchingMgr.battle_win_at(i)
    else
        SearchingMgr.enterBattleAt(i, {false, battleInfo})
    end
end

---訓練師戰鬥
function SearchingFuncMgr.battle_trainerFunc_At(i)

    if AdvCharMgr.getTrainerByPos(i) then return end

    local tag = "trainerAni"..i
    local skin = string.split(SearchingMgr.itemTypeTable[i].figure, ",")

    for k,v in pairs(skin) do
        print("~~~~~~~~~~~~~~fashions:", k, v)
    end

    local trainerAni = PlayerAnimeMgr.createPlayer(nil, {x=104/2, y=104/2, skin=skin}, tag)
    trainerAni:setScale(LtPlayerMgr.PLAYER_SCALE_X, LtPlayerMgr.PLAYER_SCALE_Y)

    local char = AdvCharMgr.create({
        floor   = SearchingMapMgr.currFloor,
        pos     = i,
        res     = "",
        aniNode = trainerAni,
    })
    AdvCharMgr.addTrainer(char)
    
end

---PVP战斗
function SearchingFuncMgr.battle_pvpTrainerFunc(i)
    if AdvCharMgr.getTrainerByPos(i) then return end
    
    local node = SearchingUIMgr.getBlockNode(i)
    SearchingUIMgr.hideBlock(i)
    
    if not SearchingMgr.itemTypeTable[i].data then
        SearchingUIMgr.clearBlock(i)
        return 
    end

    local tag = "trainerAni"..i
    local name = SearchingMgr.itemTypeTable[i].data.nickname
    local skin = SearchingMgr.itemTypeTable[i].data.fashion or {}
    
    local trainerAni = PlayerAnimeMgr.createPlayer(nil, 
        {gender=CharInfo.getSex(), x=104/2, y=104/2, skin=skin.curFashion}, tag)
    trainerAni:setScale(LtPlayerMgr.PLAYER_SCALE_X, LtPlayerMgr.PLAYER_SCALE_Y)
    local char = AdvCharMgr.create({
        floor   = SearchingMapMgr.currFloor,
        name    = name,
        pos     = i,
        res     = "",
        aniNode = trainerAni,
    })
    AdvCharMgr.addTrainer(char)
end

---boss战斗
function SearchingFuncMgr.battle_bossFunc(i)
    if LtMapOption.getMapType() ~= "LOSTTOWER" then return end
    
    SearchingUIMgr.TurnToBlock(i)
    
    local function checkNewRecordingPoint(bossPos)
        if SearchingMgr.eventInfoTable[bossPos] ~= LtEventOption.EVENT_LTBOSS then return end

        if LostTowerMgr.currentFloor % 5 == 0 then
            if LostTowerMgr.currentFloor + 1 <= LostTowerMgr.recordingPoint then return end
            LostTowerMgr.recordingPoint = LostTowerMgr.currentFloor + 1
            DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,1,"LtTips12") -- "成功击败守关者，开启新的传送点"
        end
    end
    
    if SearchingMgr.eventStateInfoTable[i] == 3 then
        SearchingMgr.moveWithCallback(i, function()
            local floorLimited = SystemInfo.getGlobalConfigAddInfoByID(50001).values[1]
            if LostTowerMgr.currentFloor + 1 > floorLimited then
                StandardTipsMgr.show(1,"lostTip1")
                return
            end
        
            LtChangeFloorView.show(SceneMgr.getRunningScene, LostTowerMgr.currentFloor + 1, function()
                GameAudio.playUISound("mapGo")
                LtFuncMgr.transferEffect(SearchingMgr.playerCurrPosition, function()
                    SearchingFuncMgr.exitFuncAt(i)
                end)
            end)
        end)
    else
        local function battle_with_boss()
            if not LostTowerMgr.hasEnoughSteps(LostTowerMgr.currentFloor) then  -- boss战进入时需要体力
                StandardTipsMgr.show(1, "LtTips24")   -- "步数不够"
                return
            end
        
            local trainerInfo = {
                name         = LuaSqlite.getLanguageByKey(SearchingMgr.itemTypeTable[i].groupCode),
                pets         = SearchingMgr.itemTypeTable[i].pokemons,
                seniorFigure = SearchingMgr.itemTypeTable[i].seniorFigure,
                sceneID      = SearchingMapMgr.sceneID["floor"..SearchingMapMgr.currFloor][i],
                type         = Proto.BTT_LOSTTOWER_BOSS,
                GroupID      = SearchingMgr.itemTypeTable[i].id,
                callback     = function(detail)
                    SearchingMapMgr.battleResult = detail.result
                    if detail.result ~= PLAYER_WIN then return end  -- 0:失败 1:胜利 2:平局

                    detail.me.hp = LtPlayerMgr.recoverFromFashion(detail.me.objID, detail.me.hp)

                    LtPetsMgr.petsAfterBattle, _ = LtPetsMgr.handleHpAfterBattle(detail.me.objID, detail.me.hp)

                    checkNewRecordingPoint(i)

                    BattleMapMgr.sendGameOver(detail.result,detail.me)
                end,
            }
            SearchingMgr.enterBattleAt(i, {true, trainerInfo})
        end
        if SearchingMgr.checkPlayer(i) then  --玩家在训练师旁边主动挑战
            LostTowerMgr.sendRecoverStepReq(function()
                battle_with_boss()
            end)
            return
        else
            SearchingMgr.moveWithCallback(i, function()
                LostTowerMgr.sendRecoverStepReq(function()
                    battle_with_boss()
                end)
            end)
        end
    end
end

function SearchingFuncMgr.battle_trainerFunc_onClick_At(i)
    
end


--++++++++++++++++++++++++++++++++++OBSTRUCTION+++++++++++++++++++++++++++++++++++++++

function SearchingFuncMgr.ob_defaultFunc_At(i)
    print("##############   执行障碍物默认函数")
--    local desc = SearchingMgr.itemTypeTable[i].desc
--
--    SearchingUIMgr.TurnToBlock(i)
--    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,1,desc,nil,nil,nil,false)
end

function SearchingFuncMgr.ob_waterFunc_onClick_At(i)
    SearchingUIMgr.TurnToBlock(i)
    print("水流")
end

function SearchingFuncMgr.ob_waterFunc_onCheck_At(i)
    SearchingUIMgr.TurnToBlock(i)
    print("水流")
end

function SearchingFuncMgr.ob_kbs_onClick_At(i)
    local desc = SearchingMgr.itemTypeTable[i].desc

    SearchingUIMgr.TurnToBlock(i)
    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,1,desc,nil,nil,nil,false)
end

-- 填土坑
local function coverPit(t, tName, i)
    SearchingUIMgr.resetGroudImg(t)   --重置底板[填上]
    SearchingMgr.eventInfoTable[t] = SearchingMapMgr.EVENT_VOID      --解鎖後狀態
    SearchingMgr.eventStateInfoTable[t] = 3    --觸發態
    SearchingMgr.itemTypeTable[t] = {}
    SearchingMgr.unlockTonari(t)        --石头解除移动后方格障碍[填坑]

    --目标坑的下方BLOCK，资源变为上边缘坑
    local col, row = LtMapOption.convertToCoord(t)
    local t_below = LtMapOption.convertToIndex(col,row+1)
    if t_below ~= nil then
        local _name = SearchingMgr.itemTypeTable[t_below].name or ""
        if SearchingMgr.eventInfoTable[t_below] == SearchingMapMgr.EVENT_OBSTRUCTION 
            and string.find(_name,tName) 
        then
            local resRoot = string.sub(SearchingMgr.itemTypeTable[t_below].res1, 1, -2)
            SearchingMgr.itemTypeTable[t_below].resName[1] = AdvEnvironmentMgr.makePath(resRoot)

            SearchingUIMgr.initItemUI(t_below)
        end
    end
    SearchingUIMgr.blockClickEvent(t, function()
        SearchingMgr.blockClickedEvent(t)
    end)

    if LtMapOption.getMapType() == "LOSTTOWER" then
        if not NetInterface.isConnect then return end

        local iCol, iRow = LtMapOption.convertToCoord(i)
        local tCol, tRow = LtMapOption.convertToCoord(t)
        NetInterface.sendWithBlock("GC_FIREEVENTCELL_ACK", function()
            local LostTowerSend = require("src/Net/Send/LostTowerSend.lua")
            LostTowerSend.sendCG_fireEventCell_Req({ x=iRow, y=iCol, })
        end, function()
            NetInterface.sendWithBlock("GC_FIREEVENTCELL_ACK", function()
                local LostTowerSend = require("src/Net/Send/LostTowerSend.lua")
                LostTowerSend.sendCG_fireEventCell_Req({ x=tRow, y=tCol, })
            end, function()
            end)
        end)
    end
end

-- 碾碎地刺
local function eraseSpike(i, t)
    LtEventOption.createEvent(t)
    SearchingMgr.lockTonari(t)
    SearchingMgr.eventStateInfoTable[t] = 1

    if LtMapOption.getMapType() == "LOSTTOWER" then
        local bx, by = LtMapOption.convertToCoord(i)
        local tx, ty = LtMapOption.convertToCoord(t)
        NetInterface.sendWithBlock("GC_MOVEOBSTACLE_ACK",function()
            local LostTowerSend = require("src/Net/Send/LostTowerSend.lua")
            LostTowerSend.sendCG_MoveObstacle_Req({
                fromPos = {x = by, y = bx},
                toPos   = {x = ty, y = tx},
            })
        end ,function()
        end,function(code)
            TipsMgr.showError(nil, code)
        end)
    end
end

---障碍物[可推动石块]
function SearchingFuncMgr.ob_stoneFunc_onPush_At(i)
    SearchingUIMgr.TurnToBlock(i)
    
    if LtMapOption.getMapType() == "LOSTTOWER" then
        if LostTowerMgr.getStepNumber() - 1 < 0 then  -- 千层塔推石头时需要体力
            StandardTipsMgr.show(1, "LtTips19")   -- "没有步数了"
            return
        end
    end

    ---检查stone是否可以移动
    local function canmove(col, row)
        local _t = LtMapOption.convertToIndex(col,row)

        if SearchingMgr.mapInfoTable[_t] ~= 0 then
            return false
        end

        if SearchingMgr.eventInfoTable[_t] ~= SearchingMapMgr.EVENT_VOID then
            return false
        end

        for key,var in pairs( AdvCharMgr.getTrainers() ) do
            if AdvCharMgr.willTrainerStepIn(var, _t) then
                return false
            end
        end

        return true
    end

    local function getTargetBlock(playerPos, boxPos, _targetName)
        local pCol, pRow = LtMapOption.convertToCoord(playerPos)
        local bCol, bRow = LtMapOption.convertToCoord(boxPos)

        local offset_c = bCol - pCol
        local offset_r = bRow - pRow

        local tCol, tRow

        local k = LtMapOption.convertToIndex(bCol + offset_c, bRow + offset_r)
        if k then
            local _name = SearchingMgr.itemTypeTable[k].name or ""
            if canmove(bCol + offset_c, bRow + offset_r) 
                or string.find(_name, _targetName[1])
                or string.find(_name, _targetName[2]) 
            then
                tCol, tRow = bCol + offset_c, bRow + offset_r
            else
                DialogBoxMgr.showSmallDialogBox(SearchingUIMgr.sc, 1, "advtips7")  -- "换个方向试试"
            end
        end

        return tCol, tRow
    end

    local targetName = {"keng", "thorn"}

    if not SearchingMgr.checkPlayer(i) then
        DialogBoxMgr.showSmallDialogBox(SearchingUIMgr.sc, 1, "advtips8") -- "靠近才能推动石头"
        return
    end

    local tx, ty = getTargetBlock(SearchingMgr.playerCurrPosition, i, targetName)

    if tx and ty then  --具备移动条件
        local t = LtMapOption.convertToIndex(tx, ty)

        --添加block外的node作移动用，移动完删除
        local x, y = SearchingUIMgr.getBlockNode(i):getPosition()

        --隐藏原方格图片
        SearchingUIMgr.hideBlock(i)

        --引入block外node
        local board = SearchingUIMgr.getBlockContainer()
        local stone = CSResourceMgr.createRes(board,"Searching/Node.csb",i)
        stone:setPosition(x, y)
        stone:setLocalZOrder(SearchingUIMgr.calcZOrderAt(i, true))
        local img = SearchingUIMgr.getItemImg(i, 1)
        CSResourceMgr.setButtonTexture("Searching/Node.csb", "stone",  img,  img,  img, i)
        CSResourceMgr.getNodeByName("Searching/Node.csb", "stone", i):setContentSize(SearchingUIMgr.PNG_WIDTH, SearchingUIMgr.PNG_HEIGHT)

        --石头以及角色动作
        local movetime_stone = 0.4
        SearchingMgr.canMove = false  -- player cant move
        local pPosX, pPosY = SearchingUIMgr.getBlockNode(SearchingMgr.playerCurrPosition):getPosition()
        local bPosX, bPosY = SearchingUIMgr.getBlockNode(i):getPosition()
        transition.moveBy(SearchingMgr.player,{x=(bPosX-pPosX)/8,y=(bPosY-pPosY)/8,time=0.1})   --人物動作
        SceneMgr.getRunningScene:performWithDelay(function()
            local movex, movey = SearchingUIMgr.getBlockNode(t):getPosition()
            transition.moveBy(SearchingMgr.player,{x=(pPosX-bPosX)/8,y=(pPosY-bPosY)/8,time=0.1})
            transition.moveTo(stone, {x = movex, y = movey, time = movetime_stone})   --石頭移動
            GameAudio.playUISound("push")
        end,0.1)
        SearchingMgr.player:performWithDelay(function()
            --  刷新训练师视野
            for _, char in pairs(AdvCharMgr.getTrainers()) do
                AdvCharMgr.setTrainerVision(char)
            end

            -- SearchingUIMgr.StepTo(nil,i,0.4)
            SearchingUIMgr.playerStepTo(i, 0.4)
            SearchingMgr.player:performWithDelay(function()
                SearchingMgr.canMove = true
                SearchingMgr.checkIfBattleAfterMove()
            end,0.4)
        end,movetime_stone+0.1)

        stone:performWithDelay(function()
            stone:setLocalZOrder(SearchingUIMgr.calcZOrderAt(t, true))
            -- stone:setLocalZOrder(SearchingUIMgr.getBlockNode(t):getLocalZOrder())
        end, 0.1+movetime_stone/2)
        
        local obName = SearchingMgr.itemTypeTable[t].name or ""
        if SearchingMgr.eventInfoTable[t] ~= LtEventOption.EVENT_VOID then  -- SearchingMgr.itemTypeTable[t].name and SearchingMgr.eventStateInfoTable[t] ~= 3 then
            if string.find(obName,targetName[1]) then   --填坑
                stone:performWithDelay(function()
                    SearchingUIMgr.delNode(i)
                    coverPit(t, targetName[1], i)
                end, movetime_stone+0.1)
        end
        if string.find(obName,targetName[2]) then  --抹刺
            SearchingMgr.eventInfoTable[t] = SearchingMapMgr.EVENT_OBSTRUCTION
            SearchingMgr.itemTypeTable[t]  = clone(SearchingMgr.itemTypeTable[i])
            stone:performWithDelay(function()
                SearchingUIMgr.delNode(i)
                eraseSpike(i, t, movetime_stone)
            end, movetime_stone+0.1)
        end
        else  --移动，未填坑
            SearchingMgr.eventInfoTable[t] = SearchingMapMgr.EVENT_OBSTRUCTION
            SearchingMgr.itemTypeTable[t]  = clone(SearchingMgr.itemTypeTable[i])
            stone:performWithDelay(function()
                SearchingUIMgr.delNode(i)
                LtEventOption.createEvent(t)
                SearchingMgr.lockTonari(t)
                SearchingMgr.eventStateInfoTable[t] = 1
            end, movetime_stone+0.1)

            if LtMapOption.getMapType() == "LOSTTOWER" then
                local bx, by = LtMapOption.convertToCoord(i)
                NetInterface.sendWithBlock("GC_MOVEOBSTACLE_ACK",function()
                    local LostTowerSend = require("src/Net/Send/LostTowerSend.lua")
                    LostTowerSend.sendCG_MoveObstacle_Req({
                        fromPos = {x = by, y = bx},
                        toPos   = {x = ty, y = tx},
                    })
                end ,function()
                end,function(code)
                    TipsMgr.showError(nil, code)
                end)
            end
        end

        SearchingMgr.eventInfoTable[i] = SearchingMapMgr.EVENT_VOID
        SearchingMgr.itemTypeTable[i]  = {id="#", name="empty",}
        SearchingMgr.unlockTonari(i)    --石頭移動解鎖原有方格周圍方格
        SearchingUIMgr.blockClickEvent(i, function()
            SearchingMgr.blockClickedEvent(i)
        end)

    end

end

function SearchingFuncMgr.ob_stoneFunc_At(i)
    SearchingUIMgr.TurnToBlock(i)
end

function SearchingFuncMgr.ob_stoneFunc_onClick_At(i)

    local locked = true
    if SearchingMgr.itemTypeTable[i].name == "stone2" and not locked then  --可破坏岩石
        if SearchingMgr.checkPlayer(i) then
            if SearchingMgr.eventStateInfoTable[i] ~= 2 then   --stone事件第二觸發狀態爲可推動狀態
                return
            end
    else
        return
    end

    SearchingUIMgr.clearBlock(i)
    SearchingMgr.eventInfoTable[i] = SearchingMapMgr.EVENT_VOID
    SearchingMgr.itemTypeTable[i]  = {}
    SearchingMgr.unlockTonari(i)    --石頭移動解鎖原有方格周圍方格
    end

end

---障碍物，树
function SearchingFuncMgr.ob_tree_onClick_At(i)

    SearchingUIMgr.TurnToBlock(i)

    if LtMapOption.getMapType() == "LOSTTOWER" then
        LtFuncMgr.ob_cuttree_func(i)
        return
    end

    if not SearchingMgr.checkPlayer(i) then
        return
    end

    local cond = SearchingMgr.itemTypeTable[i].cond  --消除条件, type::string
    local skillIDs = {}
    for k,v in pairs(cond) do
        if v[1] == "0" then
            table.insert(skillIDs,tonumber(v[2]))
        end
    end

    local m_pet, h_pet = AdvPetsMgr.getCurrMyPets()
    local pets = {
        m_pet = m_pet, 
        h_pet = h_pet,
    }

    if not AdvPetsMgr.useSkill(pets, skillIDs) then
        local skill, level = AchievementListMgr.getSkillUpInfo("tool")
        if skill then
            local pSkill = {info = skill, level = level}
            SearchingFuncMgr.showPotentialSkill(SearchingMgr.player,pSkill,-20,90)
        else
            local desc = "advtips1"
            local scene = SceneMgr.getRunningScene
            require("src.GameMgr.Searching.SkillMissingView").show(scene, 10*skillIDs[1]+1)
            return
        end
    end

    SearchingMgr.canMove = false

    local node = SearchingUIMgr.getBlockNode(i)
    
    local name = SearchingMgr.itemTypeTable[i].name or ""
    local resName = "Gaf/Searching/"..name..".gaf"
    node:performWithDelay(function()
        SearchingUIMgr.hideBlock(i)  --clearBlock将会清除block信息
        AnimationMgr.createAni(node, resName, 48, 920, i)
        AnimationMgr.playAniWithCallback(resName,"do",nil,i,true)
        if name == "cuttree" then GameAudio.playUISound("actlogging") end
    end,0.2)
    node:performWithDelay(function()
        SearchingMgr.canMove = true
        SearchingMgr.eventStateInfoTable[i] = 3
        SearchingMgr.checkGoals(i)
        AnimationMgr.removeGafObjectByTag(resName, i)
        SearchingMgr.eventInfoTable[i] = SearchingMapMgr.EVENT_VOID
        SearchingMgr.itemTypeTable[i]  = {}
        SearchingMgr.unlockTonari(i)

        --  刷新训练师视野
        for _, char in pairs(AdvCharMgr.getTrainers()) do
            AdvCharMgr.setTrainerVision(char)
            
            if AdvCharMgr.isInFront(char,3) 
            and SearchingMgr.eventStateInfoTable[char.info.pos] == 1
            and SearchingMgr.itemTypeTable[char.info.pos].autoAttack == 1 then
                AdvCharMgr.setWatching(char)
            end
        end
    end, 0.9)

end

---机关门
function SearchingFuncMgr.ob_doorFunc_onClick_At(i)
    print(SearchingMgr.itemTypeTable[i].name)
end



--  ##############   _机关_    #################

function SearchingFuncMgr.sw_defaultFunc_At(i)
end

function SearchingFuncMgr.switchFunc_onCheck_At(i)
    if SearchingMgr.eventInfoTable[i] ~= SearchingMapMgr.EVENT_SWITCH then return end
    if SearchingMgr.eventStateInfoTable[i] ~= 1 then return end

    local  strtbl = SearchingMapMgr.floorTargetBlocks["floor"..SearchingMapMgr.currFloor][i]
    if type(strtbl) == "table" then
        local tbl = clone(strtbl[1])
        local x, y = tonumber(tbl[2]), tonumber(tbl[3])
        local firstBlock = LtMapOption.convertToIndex(y, x)
        
        SearchingMgr.canMove = false
        local scrollview = CSResourceMgr.getNodeByName(SearchingUIMgr.centerResName,"fog")
        DungeonMapMgr.scrollMapWithCellID(scrollview, firstBlock)
        SceneMgr.getRunningScene:performWithDelay(function()
            SearchingMgr.canMove = true
            local floor, block
            for _, var in pairs(strtbl) do
                local tbl = clone(var)
                local x, y = tonumber(tbl[2]), tonumber(tbl[3])
                floor = tonumber(tbl[1])
                block = LtMapOption.convertToIndex(y, x)
                SearchingFuncMgr.update_blockState(block, tonumber(tbl[4]), floor)
            end
        end, 0.25+0.05)
    end
    
    --本层机关方格更新
    SearchingMgr.eventStateInfoTable[i] = 3     
    SearchingUIMgr.setBlockUI(i, SearchingUIMgr.BLOCK_SIZE)
    SearchingMgr.checkGoals(i)
end

---机关[只可走一次]  //broken grass
function SearchingFuncMgr.sw_steponceFunc_onCheck_At(i)
    print("steponce[brokengrass]")
    
    if SearchingMgr.eventInfoTable[i] ~= SearchingMapMgr.EVENT_SWITCH then
        print("ADV_DEBUG_INFO: eventType error")
        return
    end
    if SearchingMgr.mapInfoTable[i] ~= 0 then
        print("ADV_DEBUG_INFO: Mist exists")
        return
    end
    
    --角色掉入陷阱，重置所有steponce状态为未触发态
    local function resetAllSteponce()
        for i=1, LtMapOption.getMapSize() do
            if SearchingMgr.eventInfoTable[i] == SearchingMapMgr.EVENT_SWITCH then
                if SearchingMgr.itemTypeTable[i].name == "brokengrass" then  --brokengrass
                    SearchingMgr.eventStateInfoTable[i] = 1
                end
            end
        end
    end
    
    --检查是否全部触发
    local function checkFull()
        for k=1, LtMapOption.getMapSize() do
            if SearchingMgr.eventInfoTable[k] == SearchingMapMgr.EVENT_SWITCH then
                if SearchingMgr.itemTypeTable[k].name == "brokengrass" then  --brokengrass
                    if SearchingMgr.eventStateInfoTable[k] ~= 3 then
                        return false
                    end
                end
            end
        end
        return true
    end
    
    local function fallEffect()
        transition.scaleTo(SearchingMgr.player, {scale=0.3, time=0.5})
--        SearchingMgr.player:performWithDelay(function()
--            SearchingMgr.player:setScale(1.0)
--        end,0.5)
    end
    
    --陷阱, 掉落
    local function fall()
        local  strtbl = SearchingMapMgr.floorTargetBlocks["floor"..SearchingMapMgr.currFloor][i]
        if strtbl ~= nil then
            local tbl = strtbl[1]
            local x, y = tonumber(tbl[2]), tonumber(tbl[3])
            -- local block = LtMapOption.convertToIndex(y, x)

            local _floor = tonumber(tbl[1])
            local max_col = SearchingMapMgr.floorSize[_floor].cols
            local max_row = SearchingMapMgr.floorSize[_floor].rows
            local block = max_col*(x-1)+y
            
            SearchingUIMgr.transferPlayerTo(block,tonumber(tbl[1]))
        else
            print("ADV_DEBUG_INFO: target not found")
        end
    end
    
    --all steponce clear 效果
    local function clearEffect()
        local  strtbl = SearchingMapMgr.floorTargetBlocks["floor"..SearchingMapMgr.currFloor][i]
        if type(strtbl) == "table" then
            for key,value in pairs(strtbl) do
                if tonumber(value[4]) ~= 0 then  --[目标状态变化为0，传送]
                    local x, y = tonumber(value[2]), tonumber(value[3])
                    local block = LtMapOption.convertToIndex(y, x)
                    if tonumber(value[1]) == SearchingMapMgr.currFloor then SearchingUIMgr.TurnToBlock(block) end
                    local blink = cc.Blink:create(0.8, 5)  --blink
                    local node = SearchingUIMgr.getBlockNode(block)
                    node:runAction(blink)
                    node:performWithDelay(function()
                        -- SearchingFuncMgr.update_blockState(block, tonumber(value[4]))
                        SearchingUIMgr.clearBlock(block)
                    end,0.8)
                end
            end
        end
    end
    
    --未触发态 -> 触发态
    if SearchingMgr.eventStateInfoTable[i] == 1 then
        print("step once")
        SearchingMgr.eventStateInfoTable[i] = 3  -- 检查目标时，检查状态3
        SearchingUIMgr.initItemUI(i)
        if checkFull() then
            print("clear")
            clearEffect()
        else
        end
        
    --陷阱态[经过多于一次] Error
    elseif SearchingMgr.eventStateInfoTable[i] == 2 then
        print("ADV_DEBUG_INFO: Error, can't reach a steponce three times")
        
    --触发态[经过一次] -> 掉落
    elseif SearchingMgr.eventStateInfoTable[i] == 3 then
        print("step once again, fall")
        SearchingUIMgr.FALL = true  --下落标志
        SearchingMgr.fellFlag = true
        SearchingMgr.canMove = false
        SearchingMgr.eventStateInfoTable[i] = 2
        SearchingUIMgr.initItemUI(i)
        fallEffect()
        SceneMgr.getRunningScene:performWithDelay(function()
            resetAllSteponce()  -- 重置
            fall()              -- 掉落
        end,0.4)
    end
    
    SearchingMgr.checkGoals(i)
end

---smooth floor
function SearchingFuncMgr.sw_smoothfloorFunc_onCheck_At(i)
    if SearchingMgr.eventStateInfoTable[i] == 3 then return end 

    local sw_name = "ice"
    local dir = SearchingMgr.player_dir
    local next = i + dir
    
--    print("__dir__, __next__", dir,next)

    local function isSmoothFloor(id)
        if SearchingMgr.eventInfoTable[id] ~= SearchingMapMgr.EVENT_SWITCH then return false end
        if SearchingMgr.itemTypeTable[id].name ~= sw_name then return false end
        return true
    end
    
    --check that if player can slip to next
    local function check()
        local x, y = LtMapOption.convertToCoord(next)
        
        --check to see if the next pos is reachable
        if not LtMapOption.isReachable(x,y) then
            return false
        end
        if dir == 1 or dir == -1 then
            if math.ceil(i/LtMapOption.getMapCols()) ~= math.ceil(next/LtMapOption.getMapCols()) then  -- different row >> off board
                return false
            end
        end
        
        return true 
    end
    
    if SearchingMgr.eventInfoTable[i] == SearchingMapMgr.EVENT_SWITCH and SearchingMgr.itemTypeTable[i].name == sw_name then
        if check() then
            print("__event__, __name__", SearchingMgr.eventInfoTable[next], SearchingMgr.itemTypeTable[next].name)
            
            local movetime = 0.25
            SearchingMgr.canMove = false
            SearchingUIMgr.playerSlipTo(LtMapOption.getDirection(i, next))
            SceneMgr.getRunningScene:performWithDelay(function()
                local zorder = SearchingUIMgr.calcZOrderAt( next, true )
                SearchingMgr.player:setLocalZOrder( zorder )
            end,movetime/2)
            SceneMgr.getRunningScene:performWithDelay(function()
                SearchingMgr.canMove = true
                SearchingFuncMgr.check_(next)
                if not isSmoothFloor(next) then
                    SearchingMgr.checkIfBattleAfterMove()
                end
            end,movetime)
        end
    else
    end

end

--++++++++++++++++++++++    trap    ++++++++++++++++++++++++

---陷阱伤害通用处理
local function dealDamage(callback)

    local objid = AdvPetsMgr.ObjIDs()[1]  --PokemonInfo.getPetArmy(AdvPetsMgr.getCurrTeam())[1]
    local petInfo = PokemonInfo.getPetInfoByObjID(objid)
    local damage = math.ceil(petInfo.hpmax/10)
    AdvPetsMgr.updateInjuriedPet(objid, damage)
    
    local pNode = AdvPetsMgr.pNodes()[1]
    AdvPetsMgr.injuryEffect(pNode, objid, callback)
    
--    AdvPetsMgr.sufferInjuries(callback)
end

---grassy marsh [filled with miasma that would poison pets]
function SearchingFuncMgr.sw_marshFunc_onCheck_At(i)

    local debuff_type

    local function poisonPets()
    end
    
end

---spikeweed [deal damage to all pets]
function SearchingFuncMgr.sw_spikeweedFunc_onCheck_At(i)
    if LtMapOption.getMapType() == "LOSTTOWER" then
        LtFuncMgr.trap_default(i)
        return
    end
    local debuff_type
    
    local function passOver()
    end
    
    local function playerhit()
        local blink = cc.Blink:create(0.5, 5)  --blink
        local node = SearchingMgr.player
        node:setVisible(true)
        node:runAction(blink)
        
        GameAudio.playUISound("trap")
    end
    
    local function spikeEffect()
        SearchingMgr.eventStateInfoTable[i] = 3
        SearchingUIMgr.initItemUI(i)
        playerhit()

        SearchingMgr.checkGoals(i)
    end

    dealDamage()
    spikeEffect()
        
end

---trap::quick_sand
function SearchingFuncMgr.sw_quicksandFunc_onCheck_At(i)

    local debuff_type
    
    local function fallEffect()
        transition.scaleTo(SearchingMgr.player, {scale=0.3, time=0.5})
    end

    --陷阱, 掉落
    local function fall()
        local  strtbl = SearchingMapMgr.floorTargetBlocks["floor"..SearchingMapMgr.currFloor][i]
        if type(strtbl) == "table" then
            local tbl = strtbl[1]
            local x, y = tonumber(tbl[2]), tonumber(tbl[3])
            -- local block = LtMapOption.convertToIndex(y, x)

            local _floor = tonumber(tbl[1])
            local max_col = SearchingMapMgr.floorSize[_floor].cols
            local max_row = SearchingMapMgr.floorSize[_floor].rows
            local block = max_col*(x-1)+y
            
            SearchingUIMgr.transferPlayerTo(block,tonumber(tbl[1]))
        else
            print("ADV_DEBUG_INFO: target not found")
        end
    end
    
    if SearchingMgr.eventStateInfoTable[i] == 1 then
        SearchingMgr.eventStateInfoTable[i] = 3
        local imgName = SearchingMgr.itemTypeTable[i].resName[3]
        local gaf = "Gaf/Searching/"..imgName..".gaf"
        if gaf ~= nil and cc.FileUtils:getInstance():isFileExist(gaf) then
            SearchingUIMgr.hideBlock(i)
            AnimationMgr.createAni(SearchingUIMgr.getBlockNode(i), gaf, 53, 900, i)
            AnimationMgr.playAni(gaf, "do", true, i)
            AnimationMgr.setSpeedRate(gaf ,1.0, i)    --设置播放速度
        end
    end
    
    SearchingMgr.canMove = false
    fallEffect()
    dealDamage(function()
        SearchingMgr.player:performWithDelay(function()
            fall()              -- 掉落
        end,0.4)
        SearchingMgr.player:performWithDelay(function()
            SearchingMgr.canMove = true
        end,0.5)
    end)
    
end

---机关[开启对应的门]
function SearchingFuncMgr.sw_redFunc_onCheck_At(i)
end

---方向机关
function SearchingFuncMgr.arrowFunc_onCheck_At(i)
    if SearchingMgr.eventStateInfoTable[i] == 3 then return end 
    
    local sw_name = string.sub(SearchingMgr.itemTypeTable[i].name,1,-2)
    local tag_sw_name = "arrow"
    local dir = tonumber(string.sub(SearchingMgr.itemTypeTable[i].name,-1,-1))
    
    if type(dir) ~= "number" then
        print("Error param, direction is not valid")
        return
    end

    local next = LtMapOption.getNeighbour(i, dir)

    local function isTargetSwitch(id)
        if SearchingMgr.eventInfoTable[id] ~= SearchingMapMgr.EVENT_SWITCH then return false end
        if sw_name ~= tag_sw_name then return false end
        return true
    end

    --check that if player can slip to next
    local function check()
        if not next then return false end
        
        local x, y = LtMapOption.convertToCoord(next)

        --check to see if the next pos is reachable
        if not LtMapOption.isReachable(x,y) then
            return false
        end

        return true 
    end
    
    local function shouldStop(_block, _dir)
        local _next = LtMapOption.getNeighbour(_block, _dir)
    
        if not _next then return 1 end
        
        local x, y = LtMapOption.convertToCoord(_next)
        if not LtMapOption.isReachable(x,y) then
            return 1
        end
        
        if tonumber(SearchingMgr.itemTypeTable[_next].type) == 5 then  -- 方向机关
            return 2
        end
        
        return 0
    end
    
    local function slipUntilStop(_block, _dir, movetime, stopCallback)
        local stopFlag = shouldStop(_block,_dir)
        if stopFlag == 1 then
            if stopCallback then stopCallback(_block, stopFlag) end
            return
        end
        
        local _next = LtMapOption.getNeighbour(_block, _dir)
        SearchingUIMgr.playerSlipTo(_dir)
        SearchingMgr.player:performWithDelay(function()
            local zorder = SearchingUIMgr.calcZOrderAt( _next, true )
            SearchingMgr.player:setLocalZOrder( zorder )
        end,movetime/2)
        
        SearchingMgr.player:performWithDelay(function()
            if stopFlag == 2 then
                if stopCallback then stopCallback(_next, stopFlag) end
                return
            end
            slipUntilStop(_next, _dir, movetime, stopCallback)
        end,movetime)
    end

    if SearchingMgr.eventInfoTable[i] == SearchingMapMgr.EVENT_SWITCH and sw_name == tag_sw_name then
        if check() then
            local movetime = 0.25
            SearchingMgr.canMove = false
            slipUntilStop(i, dir, movetime, function(block, stopFlag)
                SearchingMgr.canMove = true
                SearchingFuncMgr.check_(block)
                SearchingMgr.checkIfBattleAfterMove()
            end)
        end
    end
end

-- 对应方格转换事件
function SearchingFuncMgr.sw_convertEvent(i)
    if SearchingMgr.eventStateInfoTable[i] == 3 then return end
    
    local sw_name = SearchingMgr.itemTypeTable[i].name
    
    local function checkFull()
        for k=1, LtMapOption.getMapSize() do
            if SearchingMgr.eventInfoTable[k] == SearchingMapMgr.EVENT_SWITCH then
                if SearchingMgr.itemTypeTable[k].name == sw_name then
                    if SearchingMgr.eventStateInfoTable[k] ~= 3 then
                        return false
                    end
                end
            end
        end
        return true
    end

    local Readers = LtEventOption.getTxtData()
    
    local tagBlocks    = {}
    local tagEventType
    local tagSubType

    local  strtbl = SearchingMapMgr.floorTargetBlocks["floor"..SearchingMapMgr.currFloor][i]
    if type(strtbl) == "table" then
        for _, var in pairs(strtbl) do
            local tbl = clone(var)
            local x, y = tonumber(tbl[2]), tonumber(tbl[3])
            local block = LtMapOption.convertToIndex(y, x)
            table.insert(tagBlocks, block)
        end
    end
    
    if #tagBlocks == 0 then return end

    SearchingMgr.eventStateInfoTable[i] = 3  
    SearchingUIMgr.setBlockUI(i, SearchingUIMgr.BLOCK_SIZE)
    SearchingMgr.checkGoals(i)  
    
    -- 机关未踩满时候返回
    if not checkFull() then return end

    local tagString = SearchingMgr.itemTypeTable[i].target or ""
    local tbl = string.split(tagString,",")
    tagEventType, tagSubType = tonumber(tbl[1]), tonumber(tbl[2])

    for i = 1, #tagBlocks do
        -- to do something
        local _block = tagBlocks[i]
        local char = AdvCharMgr.getTrainerByPos(_block)
        if char then 
            AdvCharMgr.clearTrainerVision(char)
            AdvCharMgr.removeTrainer(char)
        else
            SearchingUIMgr.clearBlock(_block)
        end

        SearchingMgr.eventInfoTable[_block] = tagEventType
        SearchingMgr.itemTypeTable[_block]  = SearchingMapMgr.getEventRes(tagEventType, tagSubType)

        LtEventOption.createEvent(_block)
    end
end


---传送门[传送到指定位置]
function SearchingFuncMgr.portalFunc_onCheck_At(i)
    print(">>>>>>>>>>>>>>>>  csm  <<<<<<<<<<<<<<<<<")
    
    if LtMapOption.getMapType() == "LOSTTOWER" then
        LtFuncMgr.portalFunc(i)
        return
    end
    
    local  strtbl = SearchingMapMgr.floorTargetBlocks["floor"..SearchingMapMgr.currFloor][i]
    if type(strtbl) == "table" then
        local tbl = strtbl[1]
        local x, y = tonumber(tbl[2]), tonumber(tbl[3])

        local _floor = tonumber(tbl[1])
        local max_col = SearchingMapMgr.floorSize[_floor].cols
        local max_row = SearchingMapMgr.floorSize[_floor].rows
        local block = max_col*(x-1)+y
        
        -- effect
        local eff = AnimationMgr.createAni(SearchingMgr.player, "Spine/effects/Ui_huicheng.png", 52, 52-12, "portalAt"..SearchingMgr.playerCurrPosition)
        AnimationMgr.playAniWithCallback(eff.res,"animation",nil,eff.tag,true)
        
        AnimationMgr.setSpeedRate(eff.res,2.0,eff.tag)
        
        -- 传送切换楼层时，重置当前层机关
        if _floor ~= SearchingMapMgr.currFloor then
            resetAllSwitchs()  --reset switchs
        end

        SearchingMgr.canMove = false
        SceneMgr.getRunningScene:performWithDelay(function()
            if tonumber(tbl[1]) ~= SearchingMapMgr.currFloor then
                GameAudio.playUISound("mapGo")
            end

            local tmp = SearchingMgr.eventStateInfoTable[i]
            SearchingMgr.eventStateInfoTable[i] = 3     --临时觸發態，星级目标检查
            SearchingMgr.checkGoals(i)
            SearchingMgr.eventStateInfoTable[i] = tmp   --恢复触发状态，以转换传送门形态
            
            if _floor == SearchingMapMgr.currFloor then
                local scrollview = CSResourceMgr.getNodeByName(SearchingUIMgr.centerResName,"fog")
                DungeonMapMgr.scrollMapWithCellID(scrollview, block)
                SceneMgr.getRunningScene:performWithDelay(function()
                    SearchingMgr.canMove = true
                end, 0.25+0.05)
            end
            
            SearchingUIMgr.transferPlayerTo(block,tonumber(tbl[1]),function()
                -- SearchingMgr.canMove = true
            end)
        end,1.0)
    else
        print("target block not found")
    end
end

function SearchingFuncMgr.bullionFunc_onClick_At(i)
end

local function hideBillboard(parent, callback)
    local M1 = cc.MoveBy:create(0.05,cc.p(0, 50))
    local M2 = cc.MoveBy:create(0.15,cc.p(0, -900))
    
    parent:runAction(cc.Sequence:create(M1,M2))
    
    parent:performWithDelay(function()
        parent:runAction(cc.FadeOut:create(0.05))
        parent:performWithDelay(function()
            if callback then callback() end
        end, 0.05)
    end, 0.15)
end

local function showBillboard(desc)
    local resName = "Searching/Other/BillboardView.csb"
    local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, resName)
    CSResourceMgr.setRelativePosition(resName, 320, 480)
    layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
    
    local titleLabel = CSResourceMgr.getNodeByName(resName, {"billboard", "title"})
    CSResourceMgr.setLabelColorByNode(titleLabel, {r=114,g=78,b=41,a=255})
    CSResourceMgr.setLabelStringByNode(titleLabel, "tips21")
    
    local descLabel = CSResourceMgr.getNodeByName(resName, {"billboard", "desc"})
    CSResourceMgr.setLabelColorByNode(descLabel, {r=114,g=78,b=41,a=255})
    CSResourceMgr.setLabelStringByNode(descLabel, desc)
    
    local billboard = CSResourceMgr.getNodeByName(resName, "billboard")
    
    billboard:setRotation(30)
    local R1 = cc.RotateTo:create(0.22, -3)
    local R2 = cc.RotateTo:create(0.11, 0)
    billboard:runAction(cc.Sequence:create(R1,R2))
    
    local flag = false
    CSResourceMgr.clickEventBinding(resName, "block", function()
        if not flag then
            transition.stopTarget(billboard)
            billboard:setRotation(0)
            hideBillboard(billboard, function()
                CSResourceMgr.removeCSObjectByTag(resName)
            end)
            
            flag = true
        end
    end)
    
end

-- ############  billboard function  ##############

function SearchingFuncMgr.ob_billboardFunc_onClick_At(i)
    SearchingUIMgr.TurnToBlock(i)
    local desc = LuaSqlite.getLanguageByKey(SearchingMgr.itemTypeTable[i].desc)
    --DialogBoxMgr.showSmallDialogBox(SearchingUIMgr.sc, 1, desc, nil, nil, nil, false)
    showBillboard(desc)
end

function SearchingFuncMgr.enteranceFuncAt(i)
    SearchingMgr.blockClickedEvent(i)
end

-- 结束副本返回错误码1时，直接返回大地图
function SearchingFuncMgr.forceQuitWhileError()
    AdvCharMgr.resetTrainers()
    SearchingMgr.closeAdventure()
    SearchingMgr.UN_SCH_GLOBAL_CHECK()
    
    if not SearchingMgr.isFailed then
        if SearchingMapMgr.firstAdventure then
            SearchingMapMgr.firstAdventure = false
        end
    
        if SearchingMapMgr.guideCallback ~= nil then
            SearchingMapMgr.guideCallback()
            SearchingMapMgr.guideCallback = nil
        end
    end

    SceneMgr.replaceScene(SceneMgr.getRunningScene, "MainScene")
end

---副本挑战成功
function SearchingFuncMgr.exitFuncAt(i)
    if not NetInterface.isConnect then return end

    if LtMapOption.getMapType() == "LOSTTOWER" then
        LtFuncMgr.exitFunc(i)
        return
    end

    SearchingUIMgr.TurnToBlock(i)
    
    SearchingMgr.eventStateInfoTable[i] = 3
    SearchingMgr.checkGoals(i)
    
    local function send(_callback)
        local _charinfo = clone( CharInfo.get() )
        NetInterface.sendWithBlock("GC_FINISHADVENTURE_ACK", 
        function()
            local AdventureSend = require("src/Net/Send/AdventureSend.lua")
            local starRecord = AdvStarMgr.getStarRecord() + 8   -- dungeon clear, set top digit "1"
            AdventureSend.sendCG_FinishAdventure_Req({star=starRecord,})
        end, 
        function()
            SearchingMgr.canMove = false
            SearchingMgr.floorClear = true
            SearchingMgr.dungeonClear = true
            SearchingMapMgr.currFloor = 1
            require("src.GameMgr.Searching.AdvClearView").show(SceneMgr.getRunningScene, _charinfo)
            
            TaskWatcherManager.passOneStage({adventureID = SearchingMapMgr.currAdventure})
        end, 
        function(code)
            TipsMgr.showError(nil,code)
            SearchingFuncMgr.forceQuitWhileError()
        end)
    end
    
    if NetInterface.isConnect then
        LtEventOption.fireDisposableEvent(SearchingMapMgr.currAdventure, SearchingMapMgr.firedDisposableEvents, function()
            send()
            SearchingMapMgr.disposableFireFlag = false
            SearchingMapMgr.clearDispEvents()
        end)
    end

end

function SearchingFuncMgr.buffCommonFunc(i)
    if LtMapOption.getMapType() == "LOSTTOWER" then
        LtFuncMgr.buffCommonFunc(i)
        return
    end
end

function SearchingFuncMgr.collectionFunc(i)
    if LtMapOption.getMapType() == "LOSTTOWER" then
        LtFuncMgr.collectionFunc(i)
        return
    end
end

function SearchingFuncMgr.healPointFuncAt(i)
    if LtMapOption.getMapType() == "LOSTTOWER" then
        LtFuncMgr.healPointFuncAt(i)
        return
    end
end

--  ######################  NPC functions  #######################

function SearchingFuncMgr.checkNpcMission()
end

function SearchingFuncMgr.takeNpcTask(_mID)
    if not _mID then return end
    local _mission = AdvStarMgr.currAdvMissions[_mID]

    if not _mission then
        AdvStarMgr.currAdvMissions[_mID] = 0
    end
end

function SearchingFuncMgr.handInNpcTask(i, _mID, _callback)
    if not NetInterface.isConnect then return end
    if not _mID then
        if _callback then _callback() end
        return 
    end

    local _mission = AdvStarMgr.currAdvMissions[_mID]
    if not _mission or _mission == 1 then return end  -- 没有任务或任务已经提交

    NetInterface.sendWithBlock("GC_GETADVENTUREAWARD_ACK", function()
        local col, row = LtMapOption.convertToCoord(i)
        local AdventureSend = require("src/Net/Send/AdventureSend.lua")
        AdventureSend.sendCG_GetAdventureAward_Req({floor=SearchingMapMgr.currFloor,field=col,row=row})
    end,function()
        AdvStarMgr.currAdvMissions[_mID] = 1
        if _callback then _callback() end
    end)
end

local function showDialogs(_dialogs, _callback)
    local dialogID = string.split(_dialogs, ",")
    
    local function talkTalk(i)
        if i <= #dialogID then
            NpcDialogueMgr.show(dialogID[i],function()
                talkTalk(i + 1)
            end)
        else
            if _callback then _callback() end
        end
    end

    talkTalk(1)
end

local npcFunction = {
    -- 任务npc
    [1] = function(i)
        local params = {
            mID     = tonumber(SearchingMgr.itemTypeTable[i].param1),
            dialog1 = SearchingMgr.itemTypeTable[i].dialog1,
            dialog2 = SearchingMgr.itemTypeTable[i].dialog2,
            disappear = tonumber(SearchingMgr.itemTypeTable[i].disappear) or 1,
        }
        
        SearchingUIMgr.TurnToBlock(i)
        AdvCharMgr.turnTo(AdvCharMgr.getTrainerByPos(i), SearchingMgr.playerCurrPosition)
        
        if AdvStarMgr.getRecordByMissionID(params.mID) then
            if not AdvStarMgr.currAdvMissions[params.mID] then
                AdvStarMgr.currAdvMissions[params.mID] = 0
            end
            showDialogs(params.dialog2,function()
                local function f()
                    SearchingMgr.eventStateInfoTable[i] = 3
                    SearchingMgr.checkGoals(i)

                    AdvCharMgr.updateTaskNpcState(AdvCharMgr.getTrainerByPos(i))

                    if params.disappear == 1 then
                        local char = AdvCharMgr.getTrainerByPos(i)
                        AdvCharMgr.removeTrainer(char)
                        SearchingUIMgr.clearBlock(i)
                        SearchingMgr.unlockTonari(i)
                    end
                    
                    SearchingFuncMgr.update_all_targerts(i)
                end
            
                if SearchingMgr.itemTypeTable[i].clear then
                    f()
                else
                    SearchingFuncMgr.handInNpcTask(i, params["mID"], function()
                        SearchingFuncMgr.showAdvAwards(SearchingFuncMgr.advAwards, function()
                            SearchingFuncMgr.advAwards = nil
                        end)
                        f()
                    end)
                end
            end)
        else
            showDialogs(params.dialog1, function()
                SearchingFuncMgr.takeNpcTask(params["mID"])
                AdvCharMgr.updateTaskNpcState(AdvCharMgr.getTrainerByPos(i))
            end)
        end
    end,
    -- 普通对话
    [2] = function(i)
        local params = {
            dialog1 = SearchingMgr.itemTypeTable[i].dialog1,
            disappear = tonumber(SearchingMgr.itemTypeTable[i].disappear) or 1,
        }
        SearchingUIMgr.TurnToBlock(i)
        AdvCharMgr.turnTo(AdvCharMgr.getTrainerByPos(i), SearchingMgr.playerCurrPosition)
        showDialogs(params.dialog1,function()
            if SearchingMgr.eventStateInfoTable[i] == 3 then return end
        
            SearchingMgr.eventStateInfoTable[i] = 3
            SearchingMgr.checkGoals(i)
        
            if params.disappear == 1 then
                local char = AdvCharMgr.getTrainerByPos(i)
                AdvCharMgr.removeTrainer(char)
                SearchingUIMgr.clearBlock(i)
                SearchingMgr.unlockTonari(i)
            end
            NetInterface.sendWithBlock("GC_GETADVENTUREAWARD_ACK", function()
                local col, row = LtMapOption.convertToCoord(i)
                local AdventureSend = require("src/Net/Send/AdventureSend.lua")
                AdventureSend.sendCG_GetAdventureAward_Req({floor=SearchingMapMgr.currFloor,field=col,row=row})
            end,function()
                SearchingFuncMgr.showAdvAwards(SearchingFuncMgr.advAwards, function()
                    SearchingFuncMgr.advAwards = nil
                end)
            end)
            
            SearchingFuncMgr.update_all_targerts(i)
        end)
    end,
    -- npc商人
    [3] = function(i)
        local scene = SceneMgr.getRunningScene
        local data = SearchingMapMgr.adventureShopData
        SearchingUIMgr.TurnToBlock(i)
        AdvCharMgr.turnTo(AdvCharMgr.getTrainerByPos(i), SearchingMgr.playerCurrPosition)
        require("src.GameMgr.Searching.advNpcShopMgr").show(scene, data, function()
            print("close npc shop...")
        end)
    end
} 

---函数配置，在函数定义之后，绑定函数时用
-- {name = ... ,}     name爲配置表中物品名稱
SearchingFuncMgr.eventFuncDef = {
    void        = {},
    picking     = SearchingFuncMgr.pickingFuncAt,
    monster     = SearchingFuncMgr.battle_monsterFunc_onClick_At,
    obstruction = {
        default     = SearchingFuncMgr.ob_defaultFunc_At,
        water       = SearchingFuncMgr.ob_waterFunc_onClick_At,
        waterone    = SearchingFuncMgr.ob_waterFunc_onClick_At,
        watertwo    = SearchingFuncMgr.ob_waterFunc_onClick_At,
        stone       = SearchingFuncMgr.ob_stoneFunc_At,
        stone2      = SearchingFuncMgr.ob_stoneFunc_onClick_At,
        
        -- 4:道具解除障碍
        kbs         = SearchingFuncMgr.ob_kbs_onClick_At,
        fire        = SearchingFuncMgr.ob_kbs_onClick_At,
        
        -- 5:技能解除障碍
        tree        = SearchingFuncMgr.ob_tree_onClick_At,
        cuttree     = SearchingFuncMgr.ob_tree_onClick_At,
        
        -- 8:推石头
        stonepush   = SearchingFuncMgr.ob_stoneFunc_onPush_At,
        
        reddoor     = SearchingFuncMgr.ob_doorFunc_onClick_At,
        bluedoor    = SearchingFuncMgr.ob_doorFunc_onClick_At,
        closedoor   = SearchingFuncMgr.ob_doorFunc_onClick_At,
        keng        = defaultFunc,
        keng1       = defaultFunc,
        keng2       = defaultFunc,
        
        -- 根据功能类型区分
        [1]         = defaultFunc,
        [2]         = SearchingFuncMgr.ob_defaultFunc_At,       -- 显示描述
        [3]         = SearchingFuncMgr.ob_defaultFunc_At,       -- 显示描述
        [4]         = SearchingFuncMgr.ob_kbs_onClick_At,       -- 道具解除
        [5]         = SearchingFuncMgr.ob_tree_onClick_At,      -- 技能解除
        [6]         = SearchingFuncMgr.ob_defaultFunc_At,       -- 显示描述
        [7]         = SearchingFuncMgr.ob_defaultFunc_At,       -- 显示描述
        [8]         = SearchingFuncMgr.ob_stoneFunc_onPush_At,  -- 推石头
        
    },
    enterance   = SearchingFuncMgr.enteranceFuncAt,
    exit        = SearchingFuncMgr.exitFuncAt,
    switch      = {
        default     = SearchingFuncMgr.sw_defaultFunc_At,
        arrow       = SearchingFuncMgr.arrowFunc_onCheck_At,
        switch      = SearchingFuncMgr.switchFunc_onCheck_At,
        bullion     = SearchingFuncMgr.bullionFunc_onClick_At,
        redswitch   = SearchingFuncMgr.switchFunc_onCheck_At,
        blueswitch  = SearchingFuncMgr.switchFunc_onCheck_At,
        brokengrass = SearchingFuncMgr.sw_steponceFunc_onCheck_At, 
        smoothfloor = SearchingFuncMgr.sw_smoothfloorFunc_onCheck_At,
        
        --traps
        marsh       = SearchingFuncMgr.sw_marshFunc_onCheck_At,
        thorn       = SearchingFuncMgr.sw_spikeweedFunc_onCheck_At,
        liusha      = SearchingFuncMgr.sw_quicksandFunc_onCheck_At,
        
        ice         = SearchingFuncMgr.sw_smoothfloorFunc_onCheck_At,
        
        -- 根据功能类型获取函数
        [1]         = SearchingFuncMgr.switchFunc_onCheck_At,         -- 按钮机关
        [2]         = SearchingFuncMgr.sw_spikeweedFunc_onCheck_At,   -- 地刺机关
        [3]         = SearchingFuncMgr.sw_steponceFunc_onCheck_At,    -- 破碎草地
        [4]         = SearchingFuncMgr.sw_smoothfloorFunc_onCheck_At, -- 光滑地面
        [5]         = SearchingFuncMgr.arrowFunc_onCheck_At,          -- 强制箭头
        [6]         = SearchingFuncMgr.sw_quicksandFunc_onCheck_At,   -- 流沙机关
        [7]         = SearchingFuncMgr.sw_convertEvent,               -- 事件转换
        
    },
    csm         = SearchingFuncMgr.portalFunc_onCheck_At,
    trainer     = SearchingFuncMgr.battle_trainerFunc_At,
    randombox   = SearchingFuncMgr.pickingFuncAt,
    healpoint   = SearchingFuncMgr.healPointFuncAt,
    random      = SearchingFuncMgr.randomFuncAt,
    c_awards    = SearchingFuncMgr.pickingFuncAt,
    boss        = SearchingFuncMgr.battle_bossFunc,
    trap        = SearchingFuncMgr.sw_spikeweedFunc_onCheck_At,
    buff        = SearchingFuncMgr.buffCommonFunc,
    collection  = SearchingFuncMgr.collectionFunc,
    billboard   = SearchingFuncMgr.ob_billboardFunc_onClick_At,
    npc         = {
        npcFunction[1],
        npcFunction[2],
        npcFunction[3],
    }
}

--- getEventFunc
-- @param block num block-id
function SearchingFuncMgr.getEventFunc(block, subType)
    subType = subType or SearchingMgr.itemTypeTable[block].name
    
    if SearchingMgr.eventInfoTable[block] == LtEventOption.EVENT_SWITCH then
        subType = tonumber(SearchingMgr.itemTypeTable[block].type)
    end
    
    if SearchingMgr.eventInfoTable[block] == LtEventOption.EVENT_OBSTRUCTION then
        subType = tonumber(SearchingMgr.itemTypeTable[block].type)
    end
    
    if SearchingMgr.eventInfoTable[block] == LtEventOption.EVENT_ADV_NPC then
        subType = tonumber(SearchingMgr.itemTypeTable[block].funcType)
    end

    local eType = SearchingMgr.eventInfoTable[block]
    local func = SearchingFuncMgr.eventFuncDef[LtEventOption.EVENT_TYPE_STRING[eType]]
    local callback = nil
    
    if type(func) == "function" then
        callback = func
        
        if not callback then callback = defaultFunc end
    elseif type(func) == "table" then
        local index = subType
        callback = func[index]
    
        if not callback then callback = func["default"] end
    end
    
    -- 训练师事件回调绑定于训练师节点
    if SearchingMgr.eventInfoTable[block] == LtEventOption.EVENT_TRAINER then
        callback = defaultFunc
    end

    --解迷雾callback
    if SearchingMgr.mapInfoTable[block] == 1 then
        callback = SearchingMgr.mistHidAt 
    end
    
    local retFunc = function(i)
        if not callback then return end
    
        if 0 == SearchingMapMgr.disposablePoint then  -- 副本无一次性事件
            callback(i)
            return
        end
        
        --方格非一次性事件
        if not SearchingMapMgr.firedDisposableEvents[SearchingMapMgr.currFloor] 
        or not SearchingMapMgr.firedDisposableEvents[SearchingMapMgr.currFloor][i] 
        then
            callback(i)
            return
        end
        
        -- 战斗事件在结束时触发
        if SearchingMgr.eventInfoTable[i] == LtEventOption.EVENT_TRAINER then
            callback(i)
            return
        end
        
        if SearchingMgr.eventInfoTable[i] == LtEventOption.EVENT_ADV_NPC then
            local funcType = tonumber(SearchingMgr.itemTypeTable[i].funcType)
            if funcType == 1 then  -- 任务NPC，任务完成时触发
                local mID = tonumber(SearchingMgr.itemTypeTable[i].param1)
                if not AdvStarMgr.getRecordByMissionID(mID) then
                    callback(i)
                    return
                end
            end
        end
        
        -- 拾取事件在拾取完成后触发
        if SearchingMgr.eventInfoTable[i] == LtEventOption.EVENT_PICKING then
            callback(i)
            return
        end
        
        SearchingMapMgr.disposableFireFlag = true  -- 一次性事件触发标记
        
        LtEventOption.updateDispEventRecord(i)
                
        callback(i)
    end

    return retFunc
end


return SearchingFuncMgr