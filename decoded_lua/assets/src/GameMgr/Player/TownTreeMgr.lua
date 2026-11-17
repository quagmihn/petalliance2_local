local TownTreeMgr = {}

TownTreeMgr.DEFAULT_TREE_DISTANCE = 160

local resName = ""
local treeVec = {}
local myPosx = "null"

function TownTreeMgr.Init()
    resName = "Map/TownMap/wishtree.csb"
    treeVec = {}
    myPosx = "null"
end

function TownTreeMgr.setMyPosx(posx)
	myPosx = posx
end

function TownTreeMgr.initMapTree()
    for key, var in pairs(treeVec) do
        if var.removeTime then
            if var.removeTime>CharInfo.getServerTime() then
                TownTreeMgr.addTree(var.charID, var.treeName, var.playerName, var.treeResName, var.treeLevel, 
                    var.posx, var.clickFunc, var.removeTime)
        	else
        	   TownTreeMgr.removeTree(var.charID)
        	end
        else
            TownTreeMgr.addTree(var.charID, var.treeName, var.playerName, var.treeResName, var.treeLevel, 
                var.posx, var.clickFunc, var.removeTime)
        end
	end
end

---检查能否在当前位置种树
--@return #number 如果能则返回位置，不能则返回nil
function TownTreeMgr.checkMyTreePosx()
    if SceneMgr.currentScene~="TownScene" then
        return nil
    end
    if myPosx=="null" then
        local mapRes_vec = lua_string_split(TownMapMgr.MapFrontRes, "/")
        local map_name = string.gsub(mapRes_vec[table.getn(mapRes_vec)], ".csb", "")
        local map_node = TownMapMgr.MapFront:getChildByName(map_name)
        myPosx = map_node:getContentSize().width/2
    end
    for key, var in pairs(treeVec) do
        if math.abs(myPosx-var.posx)<TownTreeMgr.DEFAULT_TREE_DISTANCE then
            return nil
        end
    end
    return myPosx
end

---种树/刷新树，自己种树前一定要先TownTreeMgr.checkMyTreePosx()
--@param charID number 玩家ID，不填则为自己的ID
--@param treeName string 树名
--@param playerName string 玩家昵称，不填则为自己的昵称
--@param treeResName string 树图片路径
--@param treeLevel number 树等级
--@param posx number 位置，不填则为自己的位置
--@param clickFunc function 点击回调
function TownTreeMgr.addTree(charID, treeName, playerName, treeResName, treeLevel, posx, clickFunc, removeTime)
    charID = charID or CharInfo.getCharID()
    treeName = treeName or ""
    playerName = playerName or CharInfo.getNickName()
    treeResName = treeResName or "empty.png"
    treeLevel = treeLevel or 1
    posx = posx or myPosx
    
    treeVec[charID] = {charID = charID, treeName = treeName, playerName = playerName, treeResName = treeResName,
        treeLevel = treeLevel, posx = posx, clickFunc = clickFunc, removeTime = removeTime,
    }
    if SceneMgr.currentScene~="TownScene" then
    	return true
    end
    
    local csobj = CSResourceMgr.getCsbObj(resName, charID)
    if not csobj then
        local mapRes_vec = lua_string_split(TownMapMgr.MapFrontRes, "/")
        local map_name = string.gsub(mapRes_vec[table.getn(mapRes_vec)], ".csb", "")
        local map_node = TownMapMgr.MapFront:getChildByName(map_name)
        csobj = CSResourceMgr.createRes(map_node, resName, charID)
    end
    transition.stopTarget(csobj)
    csobj:setOpacity(255)
    CSResourceMgr.setSpriteTexture(resName, "image", treeResName, charID)
    CSResourceMgr.setLabelString(resName, "playername", playerName, charID, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 150)
    CSResourceMgr.setLabelColor(resName, "info", {r=250,g=240,b=0,a=255}, charID)
    CSResourceMgr.setLabelString(resName, "info", CocosModuleMgr.createStringWithFormat({"Lv<1> <2>", treeLevel, treeName}),
        charID, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 150)
    CSResourceMgr.clickEventBinding(resName, "button", clickFunc, charID, 3)
    if posx=="null" then
    	posx = 0
    end
    csobj:pos(posx-csobj:getContentSize().width/2, 0)
    csobj:zorder(-1)
    if removeTime then
        local timediff = removeTime - CharInfo.getServerTime()
        if timediff>0 then
            csobj:performWithDelay(function()
                TownTreeMgr.removeTree(charID)
            end, timediff)
        end
    end
    
    return true
end

function TownTreeMgr.removeTree(charID)
    local csobj = CSResourceMgr.getCsbObj(resName, charID)
    if csobj then
        CSResourceMgr.clickEventBinding(resName, "button", function() end, charID)
        local timediff = 1
        transition.fadeOut(csobj, {time = timediff})
        csobj:performWithDelay(function()
            CSResourceMgr.removeCSObjectByTag(resName, charID)
        end, timediff)
	end
	treeVec[charID] = nil
end

function TownTreeMgr.getTreeInfo()
    return treeVec
end

return TownTreeMgr