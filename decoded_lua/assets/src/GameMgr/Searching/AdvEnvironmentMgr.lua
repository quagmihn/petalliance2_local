-- create on 2016-05-11

local AdvEnvironmentMgr = {}

local basePath = ""
local suffix

local _config = {}
local sceneMistHidEffects = {}
local sceneClickEffect = {}

function AdvEnvironmentMgr.Init()
    basePath = ""
    suffix = ".png"
    _config = {
        [1] = "cd/",
        [2] = "ysd/",
        [3] = "sm/",
        [4] = "by/",
        [7] = "sn/",
    }
    sceneMistHidEffects = {
        --[1] = "",
        --[2] = "",
        [3] = "Spine/searching/UI_zhangaiwu.png",
        --[4] = "Spine/searching/UI_zhangaiwu.png",
        --[7] = "Spine/searching/UI_zhangaiwu.png",
    }
    sceneClickEffect = {
        [1] = "Spine/searching/Ui_fubendianjishuye2.png",
        [2] = "Spine/searching/UI_click_shaomo.png", --"Spine/searching/Ui_fubendianjishikuai.png",
        [3] = "Spine/searching/UI_click_shaomo.png",
        [4] = "Spine/searching/UI_click_ice.png",
        [7] = "Spine/searching/UI_click_shaomo.png", --"Spine/searching/UI_click_chengbao.png",
    }
end

function AdvEnvironmentMgr.getCurrentFieldType()
    local ret

    if LtMapOption.getMapType() == "ADVENTURE" then
        local _info = AdventureInfo.getAdventureInfoByID(SearchingMapMgr.currAdventure)
        local floor = SearchingMapMgr.currFloor or 1
        ret = _info.scene[floor] or 1
    elseif LtMapOption.getMapType() == "LOSTTOWER" then
        ret = 2
    end
    
    return ret
end

function AdvEnvironmentMgr.getcurrentWeatherType()
    local ret

    if LtMapOption.getMapType() == "ADVENTURE" then
        local _info = AdventureInfo.getAdventureInfoByID(SearchingMapMgr.currAdventure)
        local floor = SearchingMapMgr.currFloor or 1
        ret = _info.weather[floor] or 1
    elseif LtMapOption.getMapType() == "LOSTTOWER" then
        ret = 5
    end
    
    return ret
end

function AdvEnvironmentMgr.setEnv(type)
    type = type or 1

    if not _config[type] then
        print("ERROR environment param")
        print("~~~~~~~~~~~~~~~~   type",type)
    end

    local _root = _config[type] or _config[1]
    basePath = "Searching/env/".._root
    
    if SearchingMgr.ADV_DEBUG then
        print("The environment base path is:",basePath)
    end
    
    for i = 1, LtMapOption.getMapSize() do
        local etype = SearchingMapMgr.floorEventTbl["floor"..SearchingMapMgr.currFloor][i]
        
        if etype == LtEventOption.EVENT_PICKING
        or etype == SearchingMapMgr.EVENT_SWITCH
        or etype == SearchingMapMgr.EVENT_PORTAL
        or etype == SearchingMapMgr.EVENT_PORTAL
        or etype == SearchingMapMgr.EVENT_OBSTRUCTION
        or etype == SearchingMapMgr.EVENT_EXIT 
        then
            local _info = SearchingMapMgr.floorItemTbl["floor"..SearchingMapMgr.currFloor][i]
            SearchingMapMgr.floorItemTbl["floor"..SearchingMapMgr.currFloor][i].resName = {
                [1] = AdvEnvironmentMgr.makePath(_info.res1),
                [2] = AdvEnvironmentMgr.makePath(_info.res2),
                [3] = AdvEnvironmentMgr.makePath(_info.res3),
            }
        end
        
        if etype == LtEventOption.EVENT_PICKING then
            local _info = SearchingMapMgr.floorItemTbl["floor"..SearchingMapMgr.currFloor][i]
            SearchingMapMgr.floorItemTbl["floor"..SearchingMapMgr.currFloor][i].resName = {
                [1] = AdvEnvironmentMgr.makePath(_info.res1, true),
                [2] = AdvEnvironmentMgr.makePath(_info.res2, true),
                [3] = AdvEnvironmentMgr.makePath(_info.res3, true),
            }
        end
    end
    
    
end

function AdvEnvironmentMgr.initEnvironmentParams(type)
    type = type or AdvEnvironmentMgr.getCurrentFieldType()

    if not _config[type] then
        print("ERROR environment param")
        print("~~~~~~~~~~~~~~~~   type",type)
    end
    
    local _root = _config[type] or _config[1]
    
    basePath = "Searching/env/".._root

    --场景迷雾设定
    SearchingMapMgr.fogRes = {
        active = basePath.."blockbg.png",
        locked = {
            common  = basePath.."blockbgX.png",
            monster = basePath.."blockbgX2.png",
        }
    }
end

function AdvEnvironmentMgr.getPrepath()
    return basePath
end

function AdvEnvironmentMgr.getPrepathWithCode(code)
    local _root = _config[code] or _config[1]
    return "Searching/env/".._root
end

function AdvEnvironmentMgr.makePath(str, isGetFromCommon)
    if not str or str == "nil" or str == "" then
        return "Searching/empty.png"
    end
    
    if isGetFromCommon then
        return "Searching/env/Common/"..str..suffix
    end
    
    return basePath..str..suffix
end

--- 根据场景id以及文件名获取文件路径
function AdvEnvironmentMgr.getFilePathWithParam(sceneCode, filename, isGetFromCommon)
    if not _config[sceneCode] then
        print("ERROR environment param")
        print("~~~~~~~~~~~~~~~~   type",sceneCode)
    end
    
    local _root = _config[sceneCode] or _config[1]
    local prefix = "Searching/env/".._root

    if not filename or filename == "nil" or filename == "" then
        return "Searching/empty.png"
    end

    if isGetFromCommon then
        return "Searching/env/Common/"..filename..suffix
    end

    return prefix..filename..suffix
end

function AdvEnvironmentMgr.playSceneMistHidEffect(code, block)
    if LtMapOption.getMapType() ~= "ADVENTURE" then return end  -- 关卡副本中才有点击特效
    
    local node = SearchingUIMgr.getBlockNode(block)
    if code == 1 or code == 2 then
        AnimationMgr.createAni(node, "Gaf/Searching/tansuo_shuiye.gaf", 55, 950, block)
        AnimationMgr.playAni("Gaf/Searching/tansuo_shuiye.gaf", "do", true, block)
        AnimationMgr.playAniWithCallback("Gaf/Searching/tansuo_shuiye.gaf", "do", function()
            AnimationMgr.removeGafObjectByTag("Gaf/Searching/tansuo_shuiye.gaf", block)
        end, block, true)
    else
        if not sceneMistHidEffects[code] then code = 3 end
        local effAni = AnimationMgr.createAni(node, sceneMistHidEffects[code], 
            node:getContentSize().width/2, node:getContentSize().height/2, block)
        AnimationMgr.playAniWithCallback(effAni.res, "animation", nil, block, true)
    end
end

function AdvEnvironmentMgr.playSceneClickEffect(code,block)
    if LtMapOption.getMapType() ~= "ADVENTURE" then return end  -- 关卡副本中才有点击特效
    if not sceneClickEffect[code] then return end
    if SearchingMgr.mapInfoTable[block] ~= 0 then return end
    if SearchingMgr.eventInfoTable[block] ~= LtEventOption.EVENT_VOID then return end  -- 非空地不播放

    local tbl = SearchingMapMgr.floorTargetBlocks["floor"..SearchingMapMgr.currFloor][block]
    if type(tbl) ~= "string" then return end
    
    local node = SearchingUIMgr.getBlockNode(block)
    local effAni = AnimationMgr.createAni(node, sceneClickEffect[code], 
        node:getContentSize().width/2, node:getContentSize().height/2, block)
    AnimationMgr.playAniWithCallback(effAni.res, "animation", nil, block, true)
end

return AdvEnvironmentMgr