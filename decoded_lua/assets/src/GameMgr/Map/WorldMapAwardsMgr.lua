local WorldMapAwardsMgr = {}

WorldMapAwardsMgr.MAX_BOX_NUM = 3
WorldMapAwardsMgr.MAPINFO_STR = "msa_"
WorldMapAwardsMgr.ADVINFO_STR = "aaw_"

WorldMapAwardsMgr.IS_LOGIN = false

local resName = ""
local reqVec = {}
local boxVec = {}

function WorldMapAwardsMgr.Init()
    WorldMapAwardsMgr.IS_LOGIN = false
	resName = "Map/WorldMap/MapProgress.csb"
    reqVec = {}
    boxVec = {}
end

function WorldMapAwardsMgr.setRequestVec(vec)
	reqVec = vec
end

function WorldMapAwardsMgr.addUI(scene)
	local layer = CSResourceMgr.createRes(scene, resName)
	layer:zorder(CocosModuleMgr.ZORDER_BAR)
	CocosModuleMgr.setEdgeDistance(layer, 0, nil, 400, nil)
	
    WorldMapAwardsMgr.refresh()
    WorldMapAwardsMgr.requestData()    
end

function WorldMapAwardsMgr.requestData(callback)
    if WorldMapAwardsMgr.IS_LOGIN then
    	return
    end
    if #reqVec>0 then
        NetInterface.send("GC_GetCharacterValues_Ack", function()
            local LoginSend = require("src.Net.Send.LoginSend")
            LoginSend.sendCG_GetCharacterValues_Req(reqVec)
        end, function()        
            local tmpInfo = {}
            for k=1, #reqVec do
                local val = CharInfo.get()[reqVec[k]]
                local cmpStr1 = string.sub(reqVec[k], 1, string.len(WorldMapAwardsMgr.MAPINFO_STR))
                local cmpStr2 = string.sub(reqVec[k], 1, string.len(WorldMapAwardsMgr.ADVINFO_STR))
                if cmpStr1==WorldMapAwardsMgr.MAPINFO_STR then
                    local idStr = string.gsub(reqVec[k], WorldMapAwardsMgr.MAPINFO_STR, "")
                    local boxID = tonumber(idStr)
                    table.insert(tmpInfo, {id=boxID, val=val})
                elseif cmpStr2==WorldMapAwardsMgr.ADVINFO_STR then
                    if not val or val == 0 then
                        local idStr = string.gsub(reqVec[k], WorldMapAwardsMgr.ADVINFO_STR, "")
                        WorldMapMgr.showFloatAwards(tonumber(idStr))
                    end
                end
            end
            WorldMapAwardsMgr.show(tmpInfo)
            if callback then
            	callback()
            end
        end)
    end
end
	
function WorldMapAwardsMgr.refresh()
    if not CSResourceMgr.getCsbObj(resName) then
    	return
    end
    local resButton = {"Map/WorldMap/world_box1.png", "Map/WorldMap/world_box2.png", "Map/WorldMap/world_box3.png"}	
    local boxInfos = AdventureInfo.getMapStarAwarByMapID(WorldMapMgr.curMapID)
    local curNum, totalNum = TeamInfo.getLockInfo(WorldMapMgr.curMapID)
    local percent = 0
    boxVec = {}
    for var=1, #boxInfos do
        local info = boxInfos[var]        
        local starNode = CSResourceMgr.getNodeByName(resName, "xing"..var)
        local button = CSResourceMgr.getNodeByName(resName, "b"..var)
        boxVec[info.id] = {button, starNode}
        if info.needStar>curNum then
            boxVec[info.id][3] = false
            starNode:setOpacity(128)
            button:setOpacity(128)
            CSResourceMgr.setLabelString(resName, "t"..var, curNum.."/"..info.needStar, nil, {r=86,g=46,b=21,a=255,w=2}, nil, 150)
            CSResourceMgr.setButtonTextureByNode(button, resButton[2], resButton[2], resButton[2])
            CSResourceMgr.clickEventBindingByNode(button, function()
                local awardsVec = info.awardElements
                local awardsNumVec = info.awardElementNums
                local itemVec = {}
                for n=1, #awardsVec do
                    local aInfo = WorldMapAwardsMgr.getAwardsInfo(awardsVec[n], awardsNumVec[n])
                    table.insert(itemVec, aInfo)
                end
                DropInfoViewMgr.show(itemVec)
            end, 1)
        else
            boxVec[info.id][3] = true
            starNode:setOpacity(255)
            button:setOpacity(255)
            CSResourceMgr.setLabelString(resName, "t"..var, info.needStar.."/"..info.needStar, nil, {r=86,g=46,b=21,a=255,w=2}, nil, 150)
            CSResourceMgr.setButtonTextureByNode(button, resButton[1], resButton[1], resButton[3])
            CSResourceMgr.clickEventBindingByNode(button, function()
                NetInterface.sendWithBlock("GC_GetMapStarAward_Ack", function()
                    local AdventureSend = require("src.Net.Send.AdventureSend")
                    AdventureSend.sendCG_GetMapStarAward_Req({tID=info.id})
                end, function()
                    CSResourceMgr.setButtonEnabledByNode(button, false)
                    transition.stopTarget(button)
                    button:setRotation(0)
                    button:setOpacity(128)
                end, function(code)
                    TipsMgr.showError(nil, code)
                end)
            end, 1)
            percent = (var-1)*50
        end        
    end
    for var=#boxInfos+1, WorldMapAwardsMgr.MAX_BOX_NUM do
        local starNode = CSResourceMgr.getNodeByName(resName, "xing"..var)
        local button = CSResourceMgr.getNodeByName(resName, "b"..var)
        starNode:hide()
        button:hide()
    end
    CocosModuleMgr.setLoadingBarPercent(CSResourceMgr.getNodeByName(resName, "progress"), percent, 1)
end

function WorldMapAwardsMgr.show(info)
    if not info then
    	return
    end
	if CSResourceMgr.getCsbObj(resName) then
		CSResourceMgr.playAllFrame(resName, false)
        for var=1, #info do
            local vec = info[var]
            if boxVec[vec.id] then
                if boxVec[vec.id][3] then
                    if vec.val then
                        CSResourceMgr.setButtonEnabledByNode(boxVec[vec.id][1], false)
                        boxVec[vec.id][1]:setOpacity(128)
                        boxVec[vec.id][2]:setOpacity(128)
                    else
                        CSResourceMgr.setButtonEnabledByNode(boxVec[vec.id][1], true)
                        boxVec[vec.id][1]:setOpacity(255)
                        boxVec[vec.id][2]:setOpacity(255)
                        local sequence = transition.sequence({
                            cc.RotateBy:create(0.1, 20),
                            cc.RotateBy:create(0.1, -40),
                            cc.RotateBy:create(0.1, 30),
                            cc.RotateBy:create(0.1, -20),
                            cc.RotateBy:create(0.1, 10),
                        })
                        local ani = cc.RepeatForever:create(sequence)
                        transition.stopTarget(boxVec[vec.id][1])
                        boxVec[vec.id][1]:runAction(ani)
                    end
                end                
            end
        end
	end	
end

function WorldMapAwardsMgr.setVisible(val)
    local function setVisible(res)
        local layer = CSResourceMgr.getCsbObj(res)
        if layer then
            layer:setVisible(val)
        end
    end
    setVisible(resName)
end

function WorldMapAwardsMgr.setVisibleEx(val)
    local function setVisible(res)
        local layer = CSResourceMgr.getCsbObj(res)
        if layer then
            if val then
            	layer:setOpacity(255)
            else
                layer:setOpacity(0)
            end
            for var=1, WorldMapAwardsMgr.MAX_BOX_NUM do
                local starNode = CSResourceMgr.getNodeByName(resName, "xing"..var)
                local button = CSResourceMgr.getNodeByName(resName, "b"..var)
                if starNode:isVisible() then
                    button:setVisible(val)
                end                
            end            
        end
    end
    setVisible(resName)
end

function WorldMapAwardsMgr.getAwardsInfo(eid, num)
    local rInfo = ItemInfo.getAwardElementInfoById(eid)
    if not rInfo then
        print("error! 奖励元素表中没有此元素id", eid)
    	return {1, 1}
    end
    local rType = rInfo.elementType
    local rID = rInfo.elementID
    if rType==3 then
        return {rID, num}
    elseif rType==5 then
        return {"pet", rID}
    else
        return {ItemInfo.AWARD[rType], num}
    end
end

return WorldMapAwardsMgr