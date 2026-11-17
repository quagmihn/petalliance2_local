local MapSeekerMgr = {}

MapSeekerMgr.SeekFunc = nil

function MapSeekerMgr.Init()
    print("MapSeekerMgr初始化")
    
    MapSeekerMgr.SeekFunc = nil
end

---自动寻路
--@param cName string 目标场景
--@param sName string 目标建筑在CocosStudio中填写的元件名称
--@param callback function 寻路完成后的回调
--@param imdCallback function 立刻执行的回调(如果不在目标地图，会在切换到目标地图后执行)
function MapSeekerMgr.autoSeekPath(cName, sName, callback, imdCallback)
    MapSeekerMgr.SeekFunc = nil
    local function seek()
        if imdCallback then
        	imdCallback()
        end
        local node = CSResourceMgr.getNodeByName(TownMapMgr.MapRes, sName)
        if node==nil then
            print(TownMapMgr.MapRes, sName.."目标找不到")
            return false
        end
        local posx = node:getPositionX()
        local mapRes_vec = lua_string_split(TownMapMgr.MapRes, "/")
        local map_name = string.gsub(mapRes_vec[#mapRes_vec], ".csb", "")
        local map_posx = TownMapMgr.Map:getPositionX()
        local size = TownMapMgr.Map:getChildByName(map_name):getContentSize()
        local size_ratex = TownMapMgr.Map:getChildByName(map_name):getScaleX() 
        local map_sizex = size.width*size_ratex
        local movex = posx*size_ratex-map_sizex/2+map_posx+TownMapMgr.MapInitPos
        TownMapMgr.TouchListener({name="began", x=movex, y=-300})
        TownMapMgr.TouchListener({name="ended", x=movex, y=-300})
        TownMapMgr.TmpClickEventCallback = callback
        MapSeekerMgr.SeekFunc = nil
    end
    if SceneMgr.currentScene~=cName then
        local scene = SceneMgr.getRunningScene
        SceneMgr.mapEnterType = 99
        SceneMgr.replaceScene(scene, cName)
        MapSeekerMgr.SeekFunc = seek
    else
        seek()
    end
end

---安全的设置场景切换回调
function MapSeekerMgr.setSeekFunc(callback)
    if MapSeekerMgr.SeekFunc then
        local tmpFunc = MapSeekerMgr.SeekFunc
        MapSeekerMgr.SeekFunc = function()
            tmpFunc()
            callback()
        end
    else
        MapSeekerMgr.SeekFunc = function()
            callback()
        end
    end
end

---触发场景切换回调
function MapSeekerMgr.callSeekFunc()
    if MapSeekerMgr.SeekFunc~=nil then
        print("执行场景切换回调")
        local tmpFunc = MapSeekerMgr.SeekFunc
		MapSeekerMgr.SeekFunc()
        --若MapSeekerMgr.SeekFunc没有被重新赋值，则置空
        if tmpFunc==MapSeekerMgr.SeekFunc then
            MapSeekerMgr.SeekFunc = nil
		end
	end
end

---取消自动寻路
function MapSeekerMgr.cancelAutoSeekPath()
    local movex = TownMapMgr.Player:getPositionX()
    TownMapMgr.TouchListener({name="began", x=movex, y=-300})
    TownMapMgr.TouchListener({name="ended", x=movex, y=-300})
    MapSeekerMgr.SeekFunc = nil
    TownMapMgr.TmpClickEventCallback = nil
end

return MapSeekerMgr