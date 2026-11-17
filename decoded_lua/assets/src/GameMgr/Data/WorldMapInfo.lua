local WorldMapInfo = {}

WorldMapInfo.POINT_TYPE_EMPTY = 0
WorldMapInfo.POINT_TYPE_TOWN = 1
WorldMapInfo.POINT_TYPE_STAGE = 2
WorldMapInfo.POINT_TYPE_EXPLORE = 3
WorldMapInfo.POINT_TYPE_TRANSFER = 4
WorldMapInfo.POINT_TYPE_TEAM = 5
WorldMapInfo.POINT_TYPE_BOSS = 6
WorldMapInfo.POINT_TYPE_INVISIBLE = 9

local mapInfoTable = nil
local routeTable = {}
local bgInfoTable = {}
local townTable = {}
local searchTable = {}
local exploreTable = {}
local eventTable = {}
local transferTable = {}
local teamTable = {}
local bossTable = {}
local invisibleTable = {}
local lockTable = {}
local lockAdvTable = {}
local pointTable = {}
local EventInfo = {}
local mapNodeIconTable = {}
local mapNPCTable = {}
local lockIDsVec = {}

function WorldMapInfo.Init()
    if mapInfoTable==nil then
        mapInfoTable = {}
        teamTable = {}
        bossTable = {}
        local LineInfo = TxtReader.new("Config/map_list.txt")
        local LineData = LineInfo.init({"mapid", "name", "res", "info", "mapResPath", "mapPosX", "mapPosY", "unlockID"}, 1)
        for key, var in pairs(LineData) do
            local mapid = tonumber(var.mapid)
            local mapinfo = var.info
            local infoVec = lua_string_split(mapinfo, ",")
            mapInfoTable[mapid] = {name=var.name, res=var.res, mapResPath = var.mapResPath, mapPosX = var.mapPosX, 
                mapPosY = var.mapPosY, unlockID = var.unlockID}
            routeTable[mapid] = {}
            townTable[mapid] = {}
            searchTable[mapid] = {}
            exploreTable[mapid] = {}
            eventTable[mapid] = {}
            transferTable[mapid] = {}
            invisibleTable[mapid] = {}
            lockTable[mapid] = {}
            bgInfoTable[mapid] = {}
            pointTable[mapid] = {}
            for idx = 1, #infoVec do
                local idVec = lua_string_split(infoVec[idx], "-")
                if #idVec==2 then
                    table.insert(routeTable[mapid], {tonumber(idVec[1]), tonumber(idVec[2])})
                end
            end
        end
        
        local MapInfo = TxtReader.new("Config/map_node.txt")
        local MapData = MapInfo.init({"mapid", "pid", "ptype", "pparam", "showmapid", "lockid", "pname", "pevent", "icon"})
        for key, var in pairs(MapData) do
            local mapid = tonumber(var.mapid)
            local pid = tonumber(var.pid)
            local ptype = tonumber(var.ptype)
            local pparam = var.pparam
            local showmapid = tonumber(var.showmapid)
            local pname = var.pname
            local lockIndex = tonumber(var.lockid)
            local iconPath = ""
            if var.icon then
            	iconPath = "Map/WorldMap/icon/"..var.icon..".png"
            end
            if lockIndex then
                if not lockIDsVec[lockIndex] then
                	lockIDsVec[lockIndex] = {}
                end
                table.insert(lockIDsVec[lockIndex], {mapid=mapid, pid=pid})
            end            
            bgInfoTable[mapid][pid] = showmapid
            if ptype==WorldMapInfo.POINT_TYPE_TOWN then
                townTable[mapid][pid] = {id=pid, info=pparam}
            elseif ptype==WorldMapInfo.POINT_TYPE_STAGE then
                local avID = tonumber(pparam)
                lockAdvTable[avID] = lockIndex
                searchTable[mapid][pid] = {id=pid, info=avID}
                mapNodeIconTable[tonumber(pparam)] = iconPath
            elseif ptype==WorldMapInfo.POINT_TYPE_EXPLORE then
                exploreTable[mapid][pid] = {id=pid, info=tonumber(pparam)}
            elseif ptype==WorldMapInfo.POINT_TYPE_TRANSFER then
                local transferInfoVec = lua_string_split(pparam, "-")
                local mID = 1
                if transferInfoVec[1] then
                    mID = tonumber(transferInfoVec[1]) or 1
                end
                local pID = 1
                if transferInfoVec[2] then
                    pID = tonumber(transferInfoVec[2]) or 1
                end
                transferTable[mapid][pid] = {id=pid, info=mID, param=pID}
            elseif ptype==WorldMapInfo.POINT_TYPE_TEAM then
                teamTable[mapid] = {pid=pid, level=mapid*10, aid=tonumber(pparam), name=pname, lock=lockIndex, icon=iconPath}
            elseif ptype==WorldMapInfo.POINT_TYPE_BOSS then
                bossTable[mapid] = {pid=pid, name=pname}
            elseif ptype==WorldMapInfo.POINT_TYPE_INVISIBLE then
                invisibleTable[mapid][pid] = {id=pid, info={}}
            elseif ptype==WorldMapInfo.POINT_TYPE_EMPTY then
                if var.pevent~=nil then
                    local pevent = lua_string_split(var.pevent, ",")
                    eventTable[mapid][pid] = {id=pid, info=pevent}
                else
                    eventTable[mapid][pid] = {id=pid, info={}}
                end
            end
            lockTable[mapid][pid] = lockIndex
            pointTable[mapid][pid] = {type=ptype, name=pname, param=tonumber(pparam)}
        end

        EventInfo = TxtReader.new("Config/map_event.txt")
        EventInfo.init({"id", "type", "name", "awards", "weight", "emoji"}, 1, {id=1, type=1, weight=1, emoji=1})

        mapNPCTable = TxtReader.new("Config/map_npc.txt")
        mapNPCTable.init({"id", "key", "name", "npc1", "pet1", "npc2", "pet2"}, 2, {id=1, key=1})
    end
end

--name, res
function WorldMapInfo.getWorldMapInfoByID(mapid)
	return mapInfoTable[mapid]
end

function WorldMapInfo.getRouteInfoByID(mapid)
	return routeTable[mapid]
end

function WorldMapInfo.getEmbeddedMapID(mapid, pid)
    return bgInfoTable[mapid][pid]
end

function WorldMapInfo.getTownInfoByID(mapid)
    return townTable[mapid]
end

function WorldMapInfo.getSearchInfo()
    return searchTable
end

function WorldMapInfo.getSearchInfoByID(mapid)
	return searchTable[mapid]
end

function WorldMapInfo.getExploreInfoByID(mapid)
    return exploreTable[mapid]
end

function WorldMapInfo.getMapEventInfoByID(mapid)
    return eventTable[mapid]
end

function WorldMapInfo.getTransferInfoByID(mapid)
    return transferTable[mapid]
end

function WorldMapInfo.getTeamMapInfo()
	return teamTable
end

function WorldMapInfo.getBossMapPoint(mapid)
    if not bossTable[mapid] then
        print("此大地图没有boss节点， 地图id"..mapid)
    	return nil
    end
	return bossTable[mapid].pid
end

function WorldMapInfo.getBossMapPointName(mapid)
    if not bossTable[mapid] then
        return ""
    end
    return bossTable[mapid].name
end

function WorldMapInfo.getInvisibleInfoByID(mapid)
    return invisibleTable[mapid]
end

function WorldMapInfo.getLockInfoByID(mapid)
	return lockTable[mapid]
end

function WorldMapInfo.getLockInfoByAdvID(advID)
    return lockAdvTable[advID]
end

function WorldMapInfo.getPointInfo(mapid)
    return pointTable[mapid]
end

function WorldMapInfo.getPointInfoByID(mapid, pid)
	return pointTable[mapid][pid]
end

function WorldMapInfo.getPointNameByID(mapid, pid)
    return pointTable[mapid][pid].name
end

function WorldMapInfo.getEventInfoByID(eid)
    return EventInfo.get(eid)
end

function WorldMapInfo.getMapIDandMapPointByLockID(lockid)
    if lockid==nil then
        return lockIDsVec
    end
	return lockIDsVec[tonumber(lockid)]
end

function WorldMapInfo.getAdventureIcon(aid)
    if not aid then
        local tmpvec = mapNodeIconTable
        return tmpvec
    end
    return mapNodeIconTable[aid] or "empty.png"
end

function WorldMapInfo.getWorldNum()
    return #mapInfoTable
end

function WorldMapInfo.getCurNpcInfo(qid)
	return mapNPCTable.get(qid)
end

function WorldMapInfo.getTeamSpineAniRes(mapid)
    return TeamMapInfo.getTeamFloorInfoById(teamTable[mapid].aid).animationRes
end

function WorldMapInfo.getWorldSpineAniRes(mapid)
	local res = 
	{
            [1] = 
            {
                {res="Spine/world/1/UI_bird01.png", pos={x=690, y=1260}},
                {res="Spine/world/1/UI_bird02.png", pos={x=1385, y=2965}},
                {res="Spine/world/1/UI_bird3.png", pos={x=1600, y=2575}},
                {res="Spine/world/1/UI_boat01.png", pos={x=550, y=540}},
                {res="Spine/world/1/UI_boat02.png", pos={x=770, y=2090}},
                {res="Spine/world/1/UI_fish.png", pos={x=690, y=3000}},
                {res="Spine/world/1/UI_shark01.png", pos={x=880, y=3260}},
                {res="Spine/world/1/UI_shark02.png", pos={x=665, y=2865}},
                {res="Spine/world/1/UI_shark02.png", pos={x=1970, y=1860}},
            },
	}
	return res[mapid] or {}
end

function WorldMapInfo.checkMapPointFinished(mapid, pid)
	local lockIdx = lockTable[mapid][pid]
    if CharInfo.get().maplock>lockIdx then
		return true
	end
	return false
end

return WorldMapInfo