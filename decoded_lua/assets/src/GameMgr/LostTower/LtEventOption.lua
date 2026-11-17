local LtEventOption = {}

LtEventOption.EVENT_VOID          = 0  --空事件
LtEventOption.EVENT_PICKING       = 1  --拾取事件
LtEventOption.EVENT_MONSTER       = 2  --野怪战斗事件
LtEventOption.EVENT_OBSTRUCTION   = 3  --障碍事件
LtEventOption.EVENT_EXIT          = 4  --出口事件
LtEventOption.EVENT_ENTERANCE     = 5  --入口事件
LtEventOption.EVENT_SWITCH        = 6  --机关(开关)事件
LtEventOption.EVENT_PORTAL        = 7  --传送门事件
LtEventOption.EVENT_TRAINER       = 8  --训练师战斗

LtEventOption.EVENT_BUFF          = 9  --属性变化
LtEventOption.EVENT_RANDOMBOX     = 10 --随机宝箱
LtEventOption.EVENT_HEALPOINT     = 11 --恢复点
LtEventOption.EVENT_SPECIAL       = 12 --特殊效果
LtEventOption.EVENT_NPC           = 13 --稀有NPC
LtEventOption.EVENT_RANDOM        = 14 --随机事件
LtEventOption.EVENT_C_AWARDS      = 15 --固定奖励
LtEventOption.EVENT_OTHERTRAINER  = 16 --PVP战斗
LtEventOption.EVENT_LTBOSS        = 17 --boss战斗
LtEventOption.EVENT_TRAP          = 18 --陷阱
LtEventOption.EVENT_COLLECTION    = 19 --采集
LtEventOption.EVENT_BILLBOARD     = 20 --告示牌
LtEventOption.EVENT_DISPOSABLE    = 21 --一次性事件
LtEventOption.EVENT_ADV_NPC       = 22 --副本NPC

LtEventOption.EVENT_ON_GROUND = {
    [LtEventOption.EVENT_SWITCH]     = true,
    [LtEventOption.EVENT_TRAP]       = true,
}

-- 触发后不消失的事件
LtEventOption.EVENT_DONT_DISAPEAR = {
    [LtEventOption.EVENT_LTBOSS]     = true,
    [LtEventOption.EVENT_RANDOMBOX]  = true,
    [LtEventOption.EVENT_COLLECTION] = true,
}

LtEventOption.EVENT_TYPE_STRING = {
    "picking",           --事件类型1
    "monster",           --事件类型2
    "obstruction",       --事件类型3
    "exit",              --事件类型4
    "enterance",         --事件类型5
    "switch",            --事件类型6
    "csm",               --事件类型7 
    "trainer",           --事件类型8
    [9]  = "buff",       --BUFF事件      
    [10] = "randombox",  --随机宝箱
    [11] = "healpoint",  --恢复点
    [14] = "random",     --随机事件
    [15] = "c_awards",   --固定奖励
    [17] = "boss",       --BOSS战斗
    [18] = "trap",       --陷阱事件
    [19] = "collection", --采集事件
    [20] = "billboard",  --告示牌事件
    [22] = "npc",        --副本npc事件
}

LtEventOption.EVENT_CONFIG = {
    [LtEventOption.EVENT_OBSTRUCTION] = {
        _fields = {"id", "name", "type", "cond", "resName"},
        _types  = {
            [1] = "kbs",
            [2] = "cuttree",
            [3] = "water",
            [4] = "water",
            [5] = "stone",
            [6] = "",
            [7] = "",
            [8] = "keng",
            [9] = "stonepush",
        },
    },
    
    [LtEventOption.EVENT_BILLBOARD] = {
        _fields = {"id","desc","resName"},
    },
}

--配置表
--可達區域配置
--消除迷霧，行走時用
LtEventOption.reachable = {
    [LtEventOption.EVENT_VOID]       = true,    --空事件
    [LtEventOption.EVENT_PICKING]    = true,    --items
    [LtEventOption.EVENT_SWITCH]     = true,    --機關
    [LtEventOption.EVENT_PORTAL]     = true,
    [LtEventOption.EVENT_ENTERANCE]  = true,    --入口
    [LtEventOption.EVENT_C_AWARDS]   = true,    --固定奖励
    [LtEventOption.EVENT_TRAP]       = true,    --陷阱
    -- [LtEventOption.EVENT_COLLECTION] = true,    --采集事件

    [LtEventOption.EVENT_HEALPOINT]  = true,    --恢复点
    [LtEventOption.EVENT_BUFF]       = true,    --buff
}

LtEventOption.BATTLE_EVENT = {
    LtEventOption.EVENT_MONSTER,
    LtEventOption.EVENT_TRAINER,
    LtEventOption.EVENT_OTHERTRAINER,
    LtEventOption.EVENT_LTBOSS,
}

--配置表读取用
local fogInfo         --("Config/adventure/fogRes.txt")
local itemsInfo       --("Config/adventure/Aditems.txt")
local obstructionInfo --("Config/adventure/obstruction.txt")
local goalsInfo       --("Config/adventure/Fbmb.txt")
local billboardInfo
local fbpickupInfo

local switchInfo
local teleportInfo

local fbnpcInfo

local isTxtInited = false

---txt配置表数据初始
local function initTxtData()
    goalsInfo       = TxtReader.new("Config/Fbmb.txt")
    fogInfo         = TxtReader.new("Config/fogRes.txt")
    itemsInfo       = TxtReader.new("Config/Aditems.txt")
    obstructionInfo = TxtReader.new("Config/obstruction.txt")
    billboardInfo   = TxtReader.new("Config/billboard.txt")
    fbpickupInfo    = TxtReader.new("Config/fbpickup.txt")
    switchInfo      = TxtReader.new("Config/switch.txt")
    teleportInfo    = TxtReader.new("Config/teleport.txt")
    fbnpcInfo       = TxtReader.new("Config/fbnpc.txt")
    
    
    fogInfo.init({"id", "resName"}, 1)
    goalsInfo.init({"id", "adId", "desc", "eType", "eId", "arg"}, 1)
    itemsInfo.init({"id", "name", "type", "desc", "resName", "target"}, 1)
    obstructionInfo.init({"id","name","type","desc","res1","res2","res3","aniRes","canpass","isGround","clickEffect","cond","target"},1)
    billboardInfo.init({"id","name","type","desc","res1","res2","res3","aniRes","canpass","isGround","clickEffect","cond","target"},1)
    fbpickupInfo.init({"id","name","type","desc","res1","res2","res3","openAni","canpass","isGround","clickEffect","cond","target"},1)
    switchInfo.init({"id","name","type","desc","res1","res2","res3","aniRes","canpass","isGround","clickEffect","opcond","target"},1)
    teleportInfo.init({"id","name","type","desc","res1","res2","res3","aniRes","canpass","isGround","clickEffect","cond","target"},1)
    fbnpcInfo.init({"id","name","npcname","figure","dialog1","dialog2","funcType","param1","param2","direction","disappear"},1)
    
end

LtEventOption.eventAniTable = {}

function LtEventOption.Init()
    if isTxtInited==false then
        initTxtData()
    	isTxtInited = true
    end
end

function LtEventOption.getTxtData()
    return { 
        fogInfo         = fogInfo,
        itemsInfo       = itemsInfo,
        obstructionInfo = obstructionInfo,
        goalsInfo       = goalsInfo, 
        billboardInfo   = billboardInfo,
        fbpickupInfo    = fbpickupInfo,
        switchInfo      = switchInfo,
        teleportInfo    = teleportInfo,
        fbnpcInfo       = fbnpcInfo,
    }
end

--- 千层塔获取事件资源
function LtEventOption.getEventRes(type, subType, eventData)
    local ret
    
    if type == LtEventOption.EVENT_ENTERANCE then
        ret = {id="0", name="empty", resName={"empty.png","empty.png","empty.png"},}
    elseif type == LtEventOption.EVENT_VOID then
        if subType == 0 then
            ret = {id="0", name="empty", resName={"empty.png","empty.png","empty.png"},}
        else
            if LtMapOption.getMapType() == "LOSTTOWER" then
                local _info = clone(LostTowerInfo.getEmptyEventInfoById(subType)) or {}
                _info.resName = {
                    _info.terrainRes,
                    _info.terrainRes,
                    _info.terrainRes,
                }
                _info.aniRes = _info.animationEffects or ""
                ret = _info
            end
        end
    elseif type == LtEventOption.EVENT_PICKING then
        local _info = clone(LostTowerInfo.getPickUpItemInfoById(subType)) or {}
        _info.resName = {
            _info.path,
            _info.path,
            _info.path,
        }
        _info.type = 1
        ret = _info
    elseif type == LtEventOption.EVENT_MONSTER then
        if LtMapOption.getMapType() == "ADVENTURE" then
            ret = clone(AdventureInfo.getMonstrosityInfoByID(subType))
        elseif LtMapOption.getMapType() == "LOSTTOWER" then
            ret = clone(LostTowerInfo.getLostTowerMonsterInfoById(subType))
        end
        
        ret.monsterID = subType
    elseif type == LtEventOption.EVENT_TRAINER then
        if LtMapOption.getMapType() == "ADVENTURE" then
            ret = clone(AdventureInfo.getMonsterGroupManInfoByID(subType))
        elseif LtMapOption.getMapType() == "LOSTTOWER" then
            ret = clone(LostTowerInfo.getLostTowerMonsterManGroupInfoById(subType))
        end
    elseif type == LtEventOption.EVENT_SWITCH then
        local _info = clone(switchInfo.get(subType)) or {}

        _info.name = _info.desc
        _info.resName = {
            [1] = AdvEnvironmentMgr.makePath(_info.res1),
            [2] = AdvEnvironmentMgr.makePath(_info.res2),
            [3] = AdvEnvironmentMgr.makePath(_info.res3),
        }

        ret = _info
    elseif type == LtEventOption.EVENT_PORTAL then
        local transferInfo = LostTowerInfo.getTransferDoorInfoById(subType)
        ret = {
            id = transferInfo.id,
            name = "transferDoor",
            target = {},
            aniRes  = transferInfo.path,
            resName = {
                "empty.png",  -- transferInfo.path,
                "empty.png",  -- transferInfo.path,
                "empty.png",  -- transferInfo.path,
            },
        }
    elseif type == LtEventOption.EVENT_OBSTRUCTION then
        local obInfo = LostTowerInfo.getObstacleInfoById(subType) or {}
        
        ret = {
            id = obInfo.id,
            name = LtEventOption.EVENT_CONFIG[type]._types[obInfo.id],
            desc = obInfo.desc or "",
            type = obInfo.type,
            resName = {
                obInfo.path,
                obInfo.path,
                obInfo.path,
            },
            aniRes = obInfo.flashEffect,    -- 动画资源
            cond = obInfo.conditionList,
        }
    elseif type == LtEventOption.EVENT_EXIT then
        local _info = clone(itemsInfo.get(subType))

        local _t = SearchingMapMgr.getResFromStr(_info.resName)
        for key = 1, #_t do
            if _t[key] == "chukou" then _t[key] = "exit" end
            _t[key] = AdvEnvironmentMgr.makePath(_t[key])
        end

        ret = {
            id      = _info.id,
            name    = _info.name,
            resName = _t,
        }
    elseif type == LtEventOption.EVENT_BUFF then
        local bInfo = LostTowerInfo.getExBuffInfoById(subType)
        ret = {
            id      = subType, 
            name    = bInfo.name or "",
            resName = {
                bInfo.res,
                bInfo.res,
                bInfo.res,
            },
        }
    elseif type == LtEventOption.EVENT_RANDOMBOX then
        local randomChestInfo = LostTowerInfo.getRandomChestInfoById(subType)
        if randomChestInfo then
            ret = {
                id        = randomChestInfo.id,
                name      = "randombox",
                resName   = {randomChestInfo.openBeforPath,nil,randomChestInfo.openAfterPath},
                typeRes   = randomChestInfo.typeRes or "",
                condition = randomChestInfo.openCondition,
            }
        end
    elseif type == LtEventOption.EVENT_HEALPOINT then
        local recoverEffectInfo = LostTowerInfo.getRecoverEffectInfoById(subType)
        
        ret = {
            id      = recoverEffectInfo.id,
            name    = "HEALPOINT",
            type    = recoverEffectInfo.type,
            value   = recoverEffectInfo.value,
            resName = {
                recoverEffectInfo.expressionRes,
                recoverEffectInfo.expressionRes,
                recoverEffectInfo.expressionRes,
            },
        }
    elseif type == LtEventOption.EVENT_C_AWARDS then
        if subType ~= 0 then
            local S_AwardInfo = LostTowerInfo.getStationaryAwardInfoById(subType)
            local icon
            if S_AwardInfo then
                local awardID = LostTowerInfo.getStationaryAwardInfoById(subType).awardID
                local itemID  = LostTowerInfo.getLostTowerAwardInfoById(awardID).itemID
                icon    = ItemInfo.getItemInfoById(itemID).icon
            else
                icon = ""
            end
            ret = {id = "", name = "", resName = {icon, icon, icon}, }
        end
    elseif type == LtEventOption.EVENT_RANDOM then
        ret = {id="#RANDOM", name="randoms", resName = "switch,switch,switch",}
    elseif type == LtEventOption.EVENT_OTHERTRAINER then
        ret = clone(LostTowerInfo.getLostTowerBossInfoById(1))
        if eventData then
            ret.data = eventData
            ret.disappear = 1
        end
    elseif type == LtEventOption.EVENT_LTBOSS then
        ret = clone(LostTowerInfo.getLostTowerBossInfoById(subType))
        ret.resName = {
            [1] = AdvEnvironmentMgr.makePath("exit"),
            [2] = AdvEnvironmentMgr.makePath("exit"),
            [3] = AdvEnvironmentMgr.makePath("exit"),
        }
    elseif type == LtEventOption.EVENT_TRAP then
        ret = {
            id      = "#TRAP", 
            name    = "traps", 
            resName = {
                [1] = AdvEnvironmentMgr.makePath("thorn1"),
                [2] = AdvEnvironmentMgr.makePath("thorn1"),
                [3] = AdvEnvironmentMgr.makePath("thorn1"),
            },
        }
    elseif type == LtEventOption.EVENT_COLLECTION then
        local _info = LostTowerInfo.getCollectionInfoById(subType) or {}
        
        ret = { 
            id="#COLLECTION", 
            name="collections", 
            resName = {
                _info.beforeRes or "",
                _info.beforeRes or "",
                _info.afterRes  or "",
            },
            needLevel = _info.needLevel or 1,
        }
    elseif type == LtEventOption.EVENT_BILLBOARD then
    end
    
    return ret
end

function LtEventOption.removeAllEventAni()
    for key, value in pairs(LtEventOption.eventAniTable) do
        if value.res and value.tag then
            AnimationMgr.removeGafObjectByTag(value.res, value.tag)
        end
    end
    LtEventOption.eventAniTable = {}
end

--- 创建事件
function LtEventOption.createEvent(block)
    local eventType = SearchingMgr.eventInfoTable[block]
    
    if SearchingMgr.ADV_DEBUG then
        print("创建一个事件  ~~~~~~~~~~~~~~~~~~~~~  ", block,eventType)
    end
    
    if eventType == LtEventOption.EVENT_VOID or eventType == LtEventOption.EVENT_ENTERANCE then   --空事件/入口
        -- cocos studio 控件需要开启九宫格固定尺寸
        SearchingUIMgr.hideBlock(block)
        SearchingUIMgr.setBlockUI(block, SearchingUIMgr.BLOCK_SIZE)
    elseif eventType == LtEventOption.EVENT_MONSTER then       --monster
        local mType = 1
        SearchingMgr.createMonster(mType, block, block)
    elseif eventType == LtEventOption.EVENT_TRAINER then       --trainer
        SearchingMgr.createTrainer(block)
    elseif eventType == LtEventOption.EVENT_PICKING then       --items
        SearchingMgr.createItem(block)
        local btn = SearchingUIMgr.getBlockNode(block)
        local icon = CSResourceMgr.seekNodeByName(btn, "b_icon")
        local effAni = AnimationMgr.createAni(icon, "Spine/effects/UI_wupinshanshuo.png", 
            icon:getContentSize().width/2, btn:getContentSize().height/2, block)
        AnimationMgr.playAni(effAni.res, "animation", true, effAni.tag)
        
        table.insert(LtEventOption.eventAniTable, effAni)
    elseif eventType == LtEventOption.EVENT_OBSTRUCTION then   --obstruction
        SearchingMgr.createItem(block)
    elseif eventType == LtEventOption.EVENT_SWITCH then        --機關
        SearchingMgr.createItem(block)
    elseif eventType == LtEventOption.EVENT_PORTAL then        --PORTAL
        SearchingMgr.createItem(block)
    elseif eventType == LtEventOption.EVENT_EXIT then          --出口
        SearchingMgr.createItem(block)
        local exitRes = "Gaf/Searching/exit.gaf"    --路径大小写严格注意
        local node = SearchingUIMgr.getGroundNode(block) -- 57, 828
        local node1 = SearchingUIMgr.getBlockNode(block)   -- 53, 802
        local icon = CSResourceMgr.seekNodeByName(node1, "b_icon")
        local exitAni = AnimationMgr.createAni(icon, exitRes, 53, 802,"exit-ani")
        exitAni:setScale(0.85, 0.85)
        AnimationMgr.playAni(exitRes , "do", true, "exit-ani")
        
        table.insert(LtEventOption.eventAniTable, exitAni)
    elseif eventType == LtEventOption.EVENT_BUFF then        --buff事件
        SearchingMgr.createItem(block)
    elseif eventType == LtEventOption.EVENT_RANDOMBOX then   --随机宝箱
        SearchingMgr.createItem(block)
    elseif eventType == LtEventOption.EVENT_HEALPOINT then   --恢复点
        SearchingMgr.createItem(block)
    elseif eventType == LtEventOption.EVENT_RANDOM then      --随机事件
        SearchingMgr.createItem(block)
    elseif eventType == LtEventOption.EVENT_C_AWARDS then    --固定奖励
        SearchingMgr.createItem(block)
    elseif eventType == LtEventOption.EVENT_OTHERTRAINER then
        SearchingFuncMgr.battle_pvpTrainerFunc(block)
    elseif eventType == LtEventOption.EVENT_LTBOSS then      --BOSS战斗
        --SearchingMgr.createTrainer(block)
        SearchingMgr.createItem(block)

        local node1 = SearchingUIMgr.getBlockNode(block)   -- 53, 802
        local icon = CSResourceMgr.seekNodeByName(node1, "b_icon")
        if SearchingMgr.eventStateInfoTable[block] == 3 then
            local exitRes = "Gaf/Searching/exit.gaf"    --路径大小写严格注意
            local exitAni = AnimationMgr.createAni(icon, exitRes, 53, 802,"exit-ani")
            exitAni:setScale(0.85, 0.85)
            AnimationMgr.playAni(exitRes , "do", true, "exit-ani")
            
            LostTowerUIMgr.addLtAnimation(exitAni)
        else
            local evilRes = "LostTower/LTAni/8.gaf"
            local ani = AnimationMgr.createAni(icon,evilRes,52,450,"exit-evil-ani")
            AnimationMgr.playAni(evilRes , "do", true, "exit-evil-ani")
            
            LostTowerUIMgr.addLtAnimation(ani)
        end
    elseif eventType == LtEventOption.EVENT_TRAP then        --陷阱事件
        SearchingMgr.createItem(block)
    elseif eventType == LtEventOption.EVENT_COLLECTION then  --采集事件
        SearchingMgr.createItem(block)
    elseif eventType == LtEventOption.EVENT_BILLBOARD then   --告示牌
        SearchingMgr.createItem(block)
    elseif eventType == LtEventOption.EVENT_ADV_NPC then
        SearchingMgr.createNpc(block)
    else    --未定義事件類型
        print("ADV_DEBUG_INFO:事件类型未定义")
    end

    local zorder = SearchingUIMgr.calcZOrderAt(block)  --math.ceil(block/LtMapOption.getMapCols())
    SearchingUIMgr.getBlockNode(block):setLocalZOrder( zorder ) --物品Z軸
    
end

function LtEventOption.updateDispEventRecord(i)
    if not SearchingMapMgr.firedDisposableEvents[SearchingMapMgr.currFloor] 
    or not SearchingMapMgr.firedDisposableEvents[SearchingMapMgr.currFloor][i] 
    then
        return
    end

    local _info = SearchingMapMgr.firedDisposableEvents[SearchingMapMgr.currFloor][i]
    if _info.state and _info.state == 0 then
        _info.state = 1
        SearchingMapMgr.firedDisposableEvents[SearchingMapMgr.currFloor][i].fireFlag = true
    end
end

--- 触发一次性事件
function LtEventOption.fireDisposableEvent(advID, firedEvents, callback)

    local finishedInfo = AdventureInfo.getFinishedByID(advID)
    
    if not firedEvents or #firedEvents == 0 then
        if callback then callback() end
        return
    end
    
    local function send(_advID, _events, _callback)
        if #_events == 0 then 
            if callback then callback() end
            return
        end
        
        NetInterface.sendWithBlock("GC_FIREADVENTUREEVENT_ACK",function()
            local AdventureSend = require("src.Net.Send.AdventureSend")
            AdventureSend.sendCG_FireAdventureEvent_Req({
                adventureID = _advID,
                events = _events,
            })
        end,function()
            if _callback then _callback() end
        end,function(code)
            if _callback then _callback() end
            -- SearchingFuncMgr.forceQuitWhileError()
        end)
    end


    local finished = AdventureInfo.getFinishedByID(advID)
    finished["advID"] = advID
    if not finished["hasEvent"] or type(finished["hasEvent"]) ~= "table" then
        finished["hasEvent"] = {}
    end
    
    local tmpHashMap = {}
    for i = 1, SearchingMgr.floors do
        for k, v in pairs(firedEvents[i]) do
            if v.state == 1 then
                tmpHashMap[v.eventID] = true
            end
        end
    end
    
    local isFinished = {}
    for k, v in pairs(finished["hasEvent"]) do
        isFinished[v] = true
    end
    
    local sendList = {}
    for i = 1, SearchingMgr.floors do
        for k, v in pairs(firedEvents[i]) do
            local flag = false
--            if tmpHashMap[v.condID] then
--                if v.state ~= 1 then
--                    flag = true
--                end
--            else
--                if v.fireFlag then
--                    if v.condID == 0 or tmpHashMap[v.condID] then
--                        flag = true
--                    end
--                end
--            end
            
            if v.condID == 0 then  -- 无触发ID
                if v.fireFlag then flag = true end
            else
                if tmpHashMap[v.condID] then
                    flag = true
                end
            end
            
            if flag and not isFinished[v.eventID] then
                table.insert(sendList, v.eventID)
                table.insert(finished["hasEvent"], v.eventID)
            end
        end
    end
    
    for k,v in pairs(sendList) do
        print("############################",k,v)
    end
    
    send(advID, sendList, function()
        AdventureInfo.setFinished({ finished, }) 
        if callback then callback() end
    end)
    
end

return LtEventOption