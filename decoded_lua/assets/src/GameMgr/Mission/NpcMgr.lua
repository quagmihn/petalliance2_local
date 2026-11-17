local NpcMgr = {}

NpcMgr.DEFAULT_SPEED = 400
NpcMgr.DEFAULT_NUMTAG = 90000
NpcMgr.DEFAULT_POSY = 10

local resName = ""
local resNameS = ""
local TownNPCInfo = nil
local titleInfo = {}
local skinInfo = {}
local nameInfo = {}
local posxInfo = {}

local npcVec = {}
local numTag = 0

function NpcMgr.Init()
    resName = "NPC/NPC_board.csb"
    resNameS = "NPC/NPC_searchP.csb"
    if TownNPCInfo==nil then
        TownNPCInfo = TxtReader.new("Config/TownNpc.txt")
        local infoVec = TownNPCInfo.init({"id", "skin", "title", "name", "posx"}, 1)
        for key, var in pairs(infoVec) do
            titleInfo[key] = var.title
            skinInfo[key] = var.skin
            nameInfo[key] = var.name
            posxInfo[key] = tonumber(var.posx) or 0
        end
    end
    --[[
    titleInfo = 
    {
        [1] = "npcnick1",
        [4] = "npcnick4",
        [998] = "npcnick998",
        [999] = "npcnick999",
        
        --家族NPC
        [10000] = "",
        [10001] = "",
        [10002] = "",
        [10003] = "",
        [10004] = "",
        [10005] = "",
        [10006] = "",
        [10007] = "",
        [10008] = "",
    }
    skinInfo = 
    {
        [1] = {1008, 2008, 3008, 5008},
        [4] = {1013, 2013, 3013},
        [998] = {15, 1057, 2057, 3057, 4057, 5057},
        [999] = {15, 1057, 2057, 3057, 4057, 5057},
        
        --家族NPC
        [10000] = {1010, 2010, 3010},
        [10001] = {1005, 2005, 3005},
        [10002] = {1018, 2018, 3018},
        [10003] = {1028, 2028, 3028},
        [10004] = {1024, 2024, 3024},
        [10005] = {1030, 2030, 3030},
        [10006] = {1038, 2038, 3038},
        [10007] = {1037, 2037, 3037},
        [10008] = {1005, 2005, 3005},
    }]]
    
    numTag = NpcMgr.DEFAULT_NUMTAG
    npcVec = {}
end

---在当前横版地图场景内添加NPC
--@param id int TownNpc表的id
--@param name string NPC的名字，不填则读TownNpc表id对应的名字
--@param posx number NPC的x坐标，不填则读TownNpc表id对应的x坐标
--@param clickFunc function 点击回调
function NpcMgr.addNPC(id, name, posx, clickFunc, posy, scale, showNick, skin, tag, title, offsetY)

    if not TownMapMgr.PlayerTransferPosy then
    	return
    end
    
    tag = tag or ""
    name = name or nameInfo[id]
    posx = posx or posxInfo[id]

    if npcVec[name..tag] then
        npcVec[name..tag].node:setVisible(true)
        if posy ~= nil then
            local diff = CocosModuleMgr.getScreenSizeDiff()
            npcVec[name..tag].node:setPositionY(posy+(diff<0 and TownMapMgr.PlayerTransferPosy * 0.43 or 0))
        end
        return npcVec[name..tag]
    end
    local mapRes_vec = lua_string_split(TownMapMgr.MapRes, "/")
    local map_name = string.gsub(mapRes_vec[table.getn(mapRes_vec)], ".csb", "")
    local map_node = TownMapMgr.Map:getChildByName(map_name)
    
    numTag = numTag + 1
    if numTag>NpcMgr.DEFAULT_NUMTAG+10000 then
        numTag = NpcMgr.DEFAULT_NUMTAG
    end
    local searchTag = numTag
    
    local npcSearchP = CSResourceMgr.createRes(map_node, resNameS, searchTag)
    npcSearchP:setPosition(posx-100, NpcMgr.DEFAULT_POSY+TownMapMgr.PlayerTransferPosy)
    local npcBoard = CSResourceMgr.createRes(map_node, resName, name..tag)
    local diff = CocosModuleMgr.getScreenSizeDiff()
    npcBoard:setPosition(posx, posy == nil and NpcMgr.DEFAULT_POSY+TownMapMgr.PlayerTransferPosy or posy+(diff<0 and TownMapMgr.PlayerTransferPosy * 0.43 or 0))
    local randomRage = TownPlayerMgr.PLAYER_MAX_POSY - TownMapMgr.PlayerTransferPosy
    if randomRage>=0 then
        npcBoard:setLocalZOrder((randomRage+1)*2+1)
    end
    if skin and type(skin) == "table" then
        skinInfo[id] = skin
    end
    local npcAni = PlayerAnimeMgr.createPlayer(npcBoard, {x=50, y=offsetY or 0, skin = skinInfo[id]}, "NpcMgr.addNPC"..name..tag)
    scale = scale or 1
    npcAni:setScale(-1 * scale, scale)
    npcAni:setLocalZOrder(-1)
    CSResourceMgr.setLabelColor(resName, "name", {r=12,g=250,b=255,a=255}, name..tag)
    CSResourceMgr.setLabelString(resName, "name", name, name..tag, {r=0,g=0,b=0,a=255,w=1})
    if showNick == nil or showNick == true then
        CSResourceMgr.setLabelColor(resName, "nick", {r=255,g=253,b=0,a=255}, name..tag)
        CSResourceMgr.setLabelString(resName, "nick", title or titleInfo[id] or "", name..tag, {r=0,g=0,b=0,a=255,w=1})
        CSResourceMgr.getNodeByName(resName, "nick", name..tag):setVisible(true)
    else
        CSResourceMgr.getNodeByName(resName, "nick", name..tag):setVisible(false)
    end
    
    CSResourceMgr.clickEventBinding(resName, "press", function()
    	if clickFunc then
    		clickFunc()
    	end
    end, name..tag)
    --[[
    local function setColor(color)
        local vec = PlayerAnimeMgr.playerTable[npcAni.tag].spineobj
        for key, var in pairs(vec) do
            var:setColor(color)
        end
    end
    CSResourceMgr.buttonEventBinding(resName, "press", function()
        setColor({r=128,g=128,b=128})
    end, function()
        setColor({r=255,g=255,b=255})
        if clickFunc then
            clickFunc()
        end
    end, nil, function()
        setColor({r=255,g=255,b=255})
    end, name..tag)]]
    local pressBtn = CSResourceMgr.getNodeByName(resName, "press", name..tag)
    npcVec[name..tag] = {btn=pressBtn, ani=npcAni, srh=searchTag, node=npcBoard}
    return npcVec[name..tag]
end

function NpcMgr.getNPC(name)
    return npcVec[name]
end

function NpcMgr.moveNPC(name, distance, callback)
    if not npcVec[name] then
		return
	end
	local movetime = math.abs(distance/NpcMgr.DEFAULT_SPEED)
	if distance>0 then
		npcVec[name].ani:setScaleX(1)
	elseif distance<0 then
        npcVec[name].ani:setScaleX(-1)
	end
    transition.moveBy(npcVec[name].node, {x=distance, time=movetime})
    PlayerAnimeMgr.playAni(npcVec[name].ani.tag, "walk", true)
    npcVec[name].ani:performWithDelay(function()
        PlayerAnimeMgr.playAni(npcVec[name].ani.tag, "idle", true)
        if callback then
        	callback()
        end
    end, movetime)
end

function NpcMgr.clear()
    npcVec = {}
end

function NpcMgr.addMood(name, type)
    CocosModuleMgr.showMood(npcVec[name].ani, type, 0, 150, true)
end

function NpcMgr.setAllVisible(bVisible)
    for k,v in pairs(npcVec) do
        v.node:setVisible(bVisible)
    end
end

return NpcMgr