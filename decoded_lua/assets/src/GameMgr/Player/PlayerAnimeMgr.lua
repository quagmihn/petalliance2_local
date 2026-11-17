local PlayerAnimeMgr = {}

PlayerAnimeMgr.SELF_TAG_STRING = "I'm charactor, the only key!"
PlayerAnimeMgr.STATUSBAR_TAG_STRING = "StatusBar charactor, the only key!"
PlayerAnimeMgr.WORLDMAP_TAG_STRING = "WorldMap charactor, the only key!"
PlayerAnimeMgr.COMMON_UI_TAG_STRING = "UI avatar, the only key!"

PlayerAnimeMgr.UNBLOCK_LOADER_TAG = "PlayerAnimeMgr.createPlayer"

local function isSelfTag(tag)
    if tag == PlayerAnimeMgr.SELF_TAG_STRING
        or tag == PlayerAnimeMgr.STATUSBAR_TAG_STRING
        or tag == PlayerAnimeMgr.WORLDMAP_TAG_STRING
        or tag == PlayerAnimeMgr.COMMON_UI_TAG_STRING 
        or tag == PlayerAnimeMgr.UNBLOCK_LOADER_TAG 
        or tag == "ADVENTUREplayer" or tag == "LOSTTOWERplayer" then
        return true
    end

    return false
end

--1五官2头部 3上衣 4下装 5背部 6武器 7精灵球
PlayerAnimeMgr.SKIN_PART_NUM = 7
PlayerAnimeMgr.SKIN_CONFIG = {5, 2, 6, 3, 6, 3, 6, 7, 3, 4, 3, 2, 1, 2}
PlayerAnimeMgr.SKIN_INTERVAL = 1000
PlayerAnimeMgr.SCALE_PARAM = 0.7
PlayerAnimeMgr.HIDE_PART = {1, 3, 5, 7, 8, 10}

PlayerAnimeMgr.TEST_FLY = false

PlayerAnimeMgr.playerTable = nil

local MaleResTable = {}
local FemaleResTable = {}

local getResFunc = nil
local checkInCachesFunc = nil
local checkStopWalkingSound = nil
local audioHandle = nil

---重新初始化PlayerAnimeMgr，用于动态lua调试
function PlayerAnimeMgr.Init()
    if PlayerAnimeMgr.playerTable==nil then
        PlayerAnimeMgr.playerTable = {}
    end
    
    FemaleResTable = {
        "Spine/avatar/min_nv_chibang.png",
        "Spine/avatar/min_nv_houfa.png",
        "Spine/avatar/min_nv_wuqi2.png",
        "Spine/avatar/min_nv_houshoubi.png",
        "Spine/avatar/min_nv_wuqi.png",
        "Spine/avatar/min_nv_houshouzhi.png",
        "Spine/avatar/min_nv_wuqi1.png",
        "Spine/avatar/min_nv_jinglingqiu.png",
        "Spine/avatar/min_nv_body2.png",
        "Spine/avatar/min_nv_leg.png",
        "Spine/avatar/min_nv_body.png",
        "Spine/avatar/min_nv_head.png",
        "Spine/avatar/min_nv_wuguan.png",
        "Spine/avatar/min_nv_qianfa.png",
    }
        
    getResFunc = function()
        local resTable = FemaleResTable
        return resTable
    end
    checkInCachesFunc = function(tag)
        --谨慎添加，一旦进缓存永不删除，如果要删除请写:release()
        local pushInCachesTag = 
        {
                PlayerAnimeMgr.SELF_TAG_STRING, 
                PlayerAnimeMgr.STATUSBAR_TAG_STRING, 
                PlayerAnimeMgr.WORLDMAP_TAG_STRING,
                PlayerAnimeMgr.COMMON_UI_TAG_STRING,
        }
        for var=1, #pushInCachesTag do
            if pushInCachesTag[var] == tag then
        		return true
        	end
        end
        return false
    end
    checkStopWalkingSound = function(player)
        player.isWalking = false
        if audioHandle then
            local needStopSound = true
            for key, var in pairs(PlayerAnimeMgr.playerTable) do
                if var.isWalking and isSelfTag(key) then
                    needStopSound = false
                    break
                end
            end
            if needStopSound then
                print("PlayerAnimeMgr: 停止跑步声音")
                audio.stopSound(audioHandle)
                audioHandle = nil
            end                    
        end
    end
    PlayerAnimeMgr.createPlayer(nil, {}, PlayerAnimeMgr.COMMON_UI_TAG_STRING)
    
    if audioHandle then
        audio.stopSound(audioHandle)
    end
    audioHandle = nil
end

---将时装信息转化成一个格式化table
--@param skinInfo string/table 服装信息
function PlayerAnimeMgr.skinInfoTransfer(skinInfo)
    if type(skinInfo)=="string" then
        local skinStr = skinInfo
        local skinStr = string.gsub(skinStr, "\\n", "")
        local skinStr = string.gsub(skinStr, "\"", "")
        local skinStr = string.gsub(skinStr, "%[", "")
        local skinStr = string.gsub(skinStr, "%]", "")
        local skinVec = lua_string_split(skinStr, ",")
        local skinSortVec = {}
        for key, var in pairs(skinVec) do
            local skID = tonumber(var)
            if skID then
                local index = math.ceil(skID/PlayerAnimeMgr.SKIN_INTERVAL)
                skinSortVec[index] = skID
            end
        end
        skinInfo = skinSortVec
    elseif type(skinInfo)=="table" then
        local skinVec = skinInfo
        local skinSortVec = {}
        for key, var in pairs(skinVec) do
            local skID = tonumber(var)
            if skID then
                local index = math.ceil(skID/PlayerAnimeMgr.SKIN_INTERVAL)
                skinSortVec[index] = skID
            end
        end
        skinInfo = skinSortVec
    else
        print("皮肤信息错误，错误参数类型:"..type(skinInfo))
        return {}
    end
    if skinInfo[1]==nil then
    	skinInfo[1] = 1
    end
    if skinInfo[7]==nil then
        skinInfo[7] = 6001
    end
    skinInfo[1] = string.format("%04d", skinInfo[1])
    return skinInfo
end

function PlayerAnimeMgr.checkSameSkin(skin1, skin2)
	local skinInfo1 = PlayerAnimeMgr.skinInfoTransfer(skin1)
    local skinInfo2 = PlayerAnimeMgr.skinInfoTransfer(skin2)
    local flag = true
    for var=1, PlayerAnimeMgr.SKIN_PART_NUM do
        if skinInfo1[var]~=skinInfo2[var] then
            flag = false
    		break
    	end
    end
    return flag
end

function PlayerAnimeMgr.showWorldPKEffect(node,vipLv,tag)
    if nil == node or nil == vipLv then
        print("showWorldPKEffect node or vipLv == nil")
        return 
    end
    local vipInfo = CharInfo.getVipInfoByID(vipLv)
    if nil == vipInfo or vipInfo.effect == ""then
        print("vipLv",vipLv,"表为=========nil")
        return
    else
        print("showWorldPKEffect动画字段",vipLv,vipInfo.effect)
    end
    local effAniRes = "Spine/effects/warenaEffect.png"
    local ScaleSizeX = node:getScaleX()
    local ScaleSizeY = node:getScaleY()
    local effAni = AnimationMgr.createAni(node, effAniRes, 
    0, 0,tag)
    AnimationMgr.playAni(effAniRes, vipInfo.effect, true,tag)
    effAni:zorder(CocosModuleMgr.ZORDER_LOADING)
    -- effAni:setScale(ScaleSizeX,ScaleSizeY)
    return effAni
end

---创建玩家动画
--@param parent node 父节点
--@param params table 参数，包括{x, y, skin}
--@param tag string 标签，存储标识
--@param useUnblockLoader bool 是否使用携程加载，默认不使用
--@param useMoreIdleAni bool 待机时是否随机其他动作，默认使用
function PlayerAnimeMgr.createPlayer(parent, params, tag, useUnblockLoader, useMoreIdleAni)
    tag = tag or ""
    local useCaches = false
    if PlayerAnimeMgr.playerTable[tag] then
        print(tag.."玩家动画已存在，此次创建使用缓存")
        useCaches = PlayerAnimeMgr.removePlayerByTag(tag, false)
    end
    params.x = params.x or 0
    params.y = params.y or 0
    params.gender = params.gender or 0
    params.skin = params.skin or {}
    params.skin = PlayerAnimeMgr.skinInfoTransfer(params.skin)
    
    local player = nil
    if useCaches then
        player = PlayerAnimeMgr.playerTable[tag].node
        player:setVisible(true)
        player:setScale(1)
        PlayerAnimeMgr.setPlayerAniScale(tag, PlayerAnimeMgr.SCALE_PARAM)
        transition.stopTarget(player)
        PlayerAnimeMgr.setPlayerSkins(tag, params.skin)
        
        PlayerAnimeMgr.playerTable[tag].parent = parent
        PlayerAnimeMgr.playerTable[tag].x = params.x 
        PlayerAnimeMgr.playerTable[tag].y = params.y
        PlayerAnimeMgr.playAni(tag, "idle", true)
    else
        player = display.newSprite("empty.png")
        
        PlayerAnimeMgr.playerTable[tag] = {node=player, spineobj={}, skin=params.skin, x=params.x, y=params.y, 
            parent=parent, completed=false}
        local boolCaches = checkInCachesFunc(tag)
        if boolCaches==true then
        	player:retain()
        end

        local resTable = getResFunc()
        local funcTable = {}
        for var=1, #resTable do
            table.insert(funcTable, function()
                local obj = AnimationMgr.createAni(player, resTable[var], 0, 0, tag)
                if obj then
                    obj:setScale(PlayerAnimeMgr.SCALE_PARAM, PlayerAnimeMgr.SCALE_PARAM)
                    obj:setSkin(params.skin[PlayerAnimeMgr.SKIN_CONFIG[var]])
                    obj:setLocalZOrder(var)
                    obj:setVisible(false)
                    obj.setInCaches = boolCaches
                    table.insert(PlayerAnimeMgr.playerTable[tag].spineobj, obj)
                else
                    print("PlayerAnimeMgr: skipping unavailable avatar part", resTable[var])
                end
            end)
        end
        table.insert(funcTable, function()
            PlayerAnimeMgr.playerTable[tag].completed = true
            if PlayerAnimeMgr.playerTable[tag].aniName==nil then
                PlayerAnimeMgr.playAni(tag, "idle", true)
            end
            for var=1, #PlayerAnimeMgr.playerTable[tag].spineobj do
                PlayerAnimeMgr.playerTable[tag].spineobj[var]:setVisible(true)
            end
        end)
        if useUnblockLoader then
            UnblockLoader.load(funcTable, PlayerAnimeMgr.UNBLOCK_LOADER_TAG..tag)
        else
            for var=1, #funcTable do
                funcTable[var]()
            end    
        end
        player:setCascadeOpacityEnabled(true)
        player.tag = tag
    end
    
    if parent then 
        player:addTo(parent)
    end
    player:setPosition(params.x, params.y)
    
    if useMoreIdleAni==nil then
    	useMoreIdleAni = true
    end
    PlayerAnimeMgr.playerTable[tag].idlemore = useMoreIdleAni
    
    return player
end

function PlayerAnimeMgr.playAni(tag, aniName, isLoop)
    tag = tag or ""
    if PlayerAnimeMgr.playerTable[tag] then
        local function playAni()
            local resTable = getResFunc()
            if aniName=="walk" and PlayerAnimeMgr.TEST_FLY then
                aniName = "fly"
            end
            --人物跑步声音
            if aniName=="walk" then
                PlayerAnimeMgr.playerTable[tag].isWalking = true
                if not audioHandle and isSelfTag(tag) then
                    audioHandle = GameAudio.playUISound("run", true)
                end
            else
                checkStopWalkingSound(PlayerAnimeMgr.playerTable[tag])
            end
            PlayerAnimeMgr.playerTable[tag].aniName = aniName
            for var=1, #resTable do
                AnimationMgr.playAni(resTable[var], aniName, isLoop, tag)
                --[[
                --待机播放其他动画代码
                AnimationMgr.cancelPlayAniCallback(resTable[var], tag)
                if aniName=="idle" and PlayerAnimeMgr.playerTable[tag].idlemore then
                    local playNum = 1
                    local function playIdle()
                        local randomIndex = 1
                        local aniVec = {"idle", "idle"}
                        if playNum%7==0 then
                            randomIndex = 2
                        end
                        AnimationMgr.playAniWithCallback(resTable[var], aniVec[randomIndex], playIdle, tag, false)
                        playNum = playNum+1
                        if playNum>1000 then
                        	playNum = 1
                        end
                    end
                    AnimationMgr.playAniWithCallback(resTable[var], aniName, playIdle, tag, false)
                else
                    AnimationMgr.playAni(resTable[var], aniName, isLoop, tag)
                end]]
            end
        end
        if not PlayerAnimeMgr.playerTable[tag].completed then
        	UnblockLoader.addCallback(PlayerAnimeMgr.UNBLOCK_LOADER_TAG..tag, function()
                playAni()
        	end)
        else
            playAni()
        end
    end
end

function PlayerAnimeMgr.playAniWithCallback(tag, aniName, callback)
    tag = tag or ""
    if PlayerAnimeMgr.playerTable[tag] then
        local function playAni()
            local resTable = getResFunc()
            PlayerAnimeMgr.playerTable[tag].aniName = aniName
            for var=1, #resTable do
                AnimationMgr.cancelPlayAniCallback(resTable[var], tag)
                local aniFinishCall = nil
                if var==1 then
                    aniFinishCall = callback
                end
                AnimationMgr.playAniWithCallback(resTable[var], aniName, aniFinishCall, tag, false)
            end
        end
        if not PlayerAnimeMgr.playerTable[tag].completed then
            UnblockLoader.addCallback(PlayerAnimeMgr.UNBLOCK_LOADER_TAG..tag, function()
                playAni()
            end)
        else
            playAni()
        end
    end
end

function PlayerAnimeMgr.getPlayer(tag)
    tag = tag or ""
    if PlayerAnimeMgr.playerTable[tag] then
        if PlayerAnimeMgr.playerTable[tag].spineobj then
            return PlayerAnimeMgr.playerTable[tag].node
    	end
    end
    return nil
end

---更换时装接口
--@param tag string 创建player时的tag
--@param skinID int 时装id
function PlayerAnimeMgr.setPlayerSkin(tag, skinID)
    tag = tag or ""
    local partIdx = math.ceil(skinID/PlayerAnimeMgr.SKIN_INTERVAL)
    print("change avatar", partIdx, skinID)
    if PlayerAnimeMgr.playerTable[tag] then
        for var=1, #PlayerAnimeMgr.playerTable[tag].spineobj do
        	if partIdx==PlayerAnimeMgr.SKIN_CONFIG[var] then
                local obj = PlayerAnimeMgr.playerTable[tag].spineobj[var]
                local skinStr = string.format("%04d", skinID)
                obj:setSkin(skinStr)
                obj:setToSetupPose()
                PlayerAnimeMgr.playerTable[tag].skin[partIdx] = skinID
            end
        end
    end
end

---更换整套时装接口
--@param tag string 创建player时的tag
--@param skinStr string/table 时装信息
function PlayerAnimeMgr.setPlayerSkins(tag, skinStr)
    if not PlayerAnimeMgr.playerTable[tag] then
    	return
    end
    if PlayerAnimeMgr.checkSameSkin(PlayerAnimeMgr.playerTable[tag].skin, skinStr) then
    	return
    end
    local skinVec = PlayerAnimeMgr.skinInfoTransfer(skinStr)
    for var=1, #PlayerAnimeMgr.playerTable[tag].spineobj do
        local partIdx = PlayerAnimeMgr.SKIN_CONFIG[var]
        local skinID = skinVec[partIdx]
        local obj = PlayerAnimeMgr.playerTable[tag].spineobj[var]
        obj:setSkin(skinID)
        obj:setToSetupPose()
        PlayerAnimeMgr.playerTable[tag].skin[partIdx] = skinID
    end
end

function PlayerAnimeMgr.getPlayerCurMotionName(tag)
    tag = tag or ""
    if PlayerAnimeMgr.playerTable[tag] then
        local actionName = PlayerAnimeMgr.playerTable[tag].aniName or ""
        if actionName=="fly" and PlayerAnimeMgr.TEST_FLY then
        	actionName = "walk"
        end
        return actionName
    end
    return nil
end

function PlayerAnimeMgr.setPlayerAniScale(tag, scale)
    tag = tag or ""
    if PlayerAnimeMgr.playerTable[tag] then
        for key, var in pairs(PlayerAnimeMgr.playerTable[tag].spineobj) do
            var:setScale(scale)
        end
    end
end

function PlayerAnimeMgr.removeAllPlayer()
    for key, var in pairs(PlayerAnimeMgr.playerTable) do
        if checkInCachesFunc(key) then
            PlayerAnimeMgr.removePlayerByTag(key, false)
        else
            PlayerAnimeMgr.removePlayerByTag(key)
        end
	end
	--PlayerAnimeMgr.playerTable = {}
end

---移出人物动画
--@param tag string 人物标签
--@param boolCleanUp bool 是否彻底删除，默认彻底删除（加入缓存请填false）
function PlayerAnimeMgr.removePlayerByTag(tag, boolCleanUp)
    tag = tag or ""
    if boolCleanUp==nil then
    	boolCleanUp = true
    end
    local result = true
    if PlayerAnimeMgr.playerTable[tag] then
        checkStopWalkingSound(PlayerAnimeMgr.playerTable[tag])
        if boolCleanUp then
            UnblockLoader.cancel(PlayerAnimeMgr.UNBLOCK_LOADER_TAG..tag)
            local resTable = getResFunc()
            for var=1, #resTable do
                AnimationMgr.removeGafObjectByTag(resTable[var], tag)
            end
            if PlayerAnimeMgr.playerTable[tag].node then
                local ret,errMessage = pcall(function()
                    PlayerAnimeMgr.playerTable[tag].node:removeAllChildren()
                    PlayerAnimeMgr.playerTable[tag].node:removeFromParent(true)
                end)
                if ret==false then
                    print("玩家tag:"..tag.."删除失败，可能是它的父节点已经被删除")
                    result = false
                end
            end
            PlayerAnimeMgr.playerTable[tag] = nil
        else
            if PlayerAnimeMgr.playerTable[tag].node then
                local ret,errMessage = pcall(function()
                    PlayerAnimeMgr.playerTable[tag].node:removeFromParent(false)
                end)
                if ret==false then
                    print("玩家tag:"..tag.."缓存失败，可能是它的父节点已经被删除")
                    PlayerAnimeMgr.playerTable[tag] = nil
                    result = false
                end
            end
        end
    end
    return result
end

return PlayerAnimeMgr