local TownMapBoardMgr = {}

TownMapBoardMgr.DEFAULT_LABEL_UPDATE_TIME = 0.05

TownMapBoardMgr.BoardStatus = 0              --地图当前操作面板种类
TownMapBoardMgr.BoardPosy = 0                --地图当前操作面板纵坐标

local mapBoardRes = ""
local tagStr = {}

function TownMapBoardMgr.Init()
    print("TownMapBoardMgr初始化")
    
    TownMapBoardMgr.BoardStatus = 1--UserSettings.get("boardStatus", 9) or 0
    TownMapBoardMgr.BoardPosy = 0
    
    mapBoardRes = "Map/TownMap/Board/BoardLayer.csb"
    tagStr = {"main", "chat", "task", "friends"}
end

function TownMapBoardMgr.addUI(scene)
    local mapBoard = CSResourceMgr.createRes(scene, mapBoardRes)
    mapBoard:setLocalZOrder(CocosModuleMgr.ZORDER_BOARD)
    CocosModuleMgr.setRelativePosition(mapBoard, 320, 150)
    TownMapBoardMgr.BoardPosy = mapBoard:getPositionY()
    
    local function changeFunc(status)
        TownMapBoardMgr.BoardStatus = status
        TownMapBoardMgr.setRedPoint(status, false)
        if status==0 then
            mapBoard:performWithDelay(function()
                CSResourceMgr.getNodeByName(mapBoardRes, "tips"):setVisible(true)
            end, 0.2)
        else
            CSResourceMgr.getNodeByName(mapBoardRes, "tips"):setVisible(false)
        end

        if status==1 then
            TownChatMgr.addUI(mapBoard)
        elseif status==2 then
            TownMissionMgr.addUI(mapBoard)
        elseif status==3 then
            TownPlayerListMgr.addUI(mapBoard)
        end

        UserSettings.set({boardStatus=TownMapBoardMgr.BoardStatus}, 9)
        TownChatMgr.changeStatus(TownMapBoardMgr.BoardStatus)
        TownMissionMgr.changeStatus(TownMapBoardMgr.BoardStatus)
        TownPlayerListMgr.changeStatus(TownMapBoardMgr.BoardStatus)

        for key, var in pairs(tagStr) do
            CSResourceMgr.setButtonEnabled(mapBoardRes, var, true)
        end
        CSResourceMgr.setButtonEnabled(mapBoardRes, tagStr[status+1], false)
    end
    
    for key, var in pairs(tagStr) do
        CSResourceMgr.clickEventBinding(mapBoardRes, var, function()
            changeFunc(key-1)
        end)
        TownMapBoardMgr.setRedPoint(key-1, false)
    end
    
    changeFunc(TownMapBoardMgr.BoardStatus)
    
    local message = ""--"Tips：常磐市的道馆馆主使用的是地面系的神奇宝贝。今天的任务是韩寒会画画后悔画韩红，呵你一脸泥麻痹。"
    TownMapBoardMgr.setLabel(message)
    
    return mapBoard
end

function TownMapBoardMgr.setRedPoint(status, boolVisible)
    CSResourceMgr.getNodeByName(mapBoardRes, tagStr[status+1].."_red"):setVisible(boolVisible)
end

function TownMapBoardMgr.setLabel(message)
    if TownMapBoardMgr.BoardStatus~=0 then
        TownMapBoardMgr.setRedPoint(0, true)
    end

    local label = CSResourceMgr.getNodeByName(mapBoardRes, "tips")
    if not label then
    	return
    end
    transition.stopTarget(label)
    CSResourceMgr.setLabelString(mapBoardRes, "tips", message)
    CSResourceMgr.setLabelMaxWidth(mapBoardRes, "tips", 580)
    label:setAnchorPoint(0, 1)
    label:setString("")
    
    local curString = message
    local curStringProcess = 0
    local curStringLen = 0
    
    local function getUpdateStr(process)
        curStringLen = curStringLen + 1
        local tmpstr = ChatMsgMgr.SubUTF8String(curString, curStringLen)
        --print("getUpdateStr:"..tmpstr..",len:"..string.utf8len(tmpstr)..",pro:"..process)
        if process>string.utf8len(tmpstr) then
            return getUpdateStr(process)
        else
            return tmpstr
        end
    end
    
    local function updateLabel(label)
        if curStringProcess>=string.utf8len(curString) then
            transition.stopTarget(label)
            return
        end
        label:performWithDelay(function()
            curStringProcess = curStringProcess + 1
            local tmpstr = getUpdateStr(curStringProcess)
            --print("updateLabel:"..tmpstr)
            label:setString(tmpstr)
            updateLabel(label)
        end, TownMapBoardMgr.DEFAULT_LABEL_UPDATE_TIME) 
    end
    
    updateLabel(label)
end

function TownMapBoardMgr.setVisible(val)
    local function setVisible(res)
        local layer = CSResourceMgr.getCsbObj(res)
        if layer then
            layer:setVisible(val)
        end
    end
    setVisible(mapBoardRes)
end

return TownMapBoardMgr