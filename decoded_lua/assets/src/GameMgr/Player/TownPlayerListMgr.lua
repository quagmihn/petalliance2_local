local TownPlayerListMgr = {}

local resName = ""
local nearbyList = {}
local friendsList = {}
local nlistObj = nil
local flistObj = nil

function TownPlayerListMgr.Init()
	resName = "Player/TownPlayerListLayer.csb"
    for var=1, 50 do
        local id = var+100
        nearbyList[var] = {name="机器人"..var, icon="Pet/PicIcon/"..id..".png", level=99, info="我要成为世界第一"}
    end
    for var=1, 50 do
        local id = var+200
        friendsList[var] = {name="好盆友"..var, icon="Pet/PicIcon/"..id..".png", level=99, info="旁边一栏都是傻逼"}
        if var>2 then
        	friendsList[var].status = false
        else
            friendsList[var].status = true
        end
    end
end

function TownPlayerListMgr.addUI(board)
    local plistLayer = CSResourceMgr.createRes(board, resName)

    CSResourceMgr.setLabelString(resName, "ntitle", "附近玩家列表", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
    CSResourceMgr.setLabelString(resName, "ftitle", "好友列表", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
    
    nlistObj = CSResourceMgr.setCommonListInfo({}, resName, "nlist", "", nil, nil, function(id, var)
        local info = var.info
        CSResourceMgr.setLabelString(resName, "nname", "Lv."..var.level.." "..var.name, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        CSResourceMgr.setLabelString(resName, "ninfo", info, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        CSResourceMgr.clickEventBinding(resName, "nadd", function(sender)
            TipsMgr.show(nil, "假装添加好友惹~")
            sender:setTouchEnabled(false)
            sender:setBright(false)
            sender:setVisible(false)
        end)
        CSResourceMgr.clickEventBinding(resName, "nexample", function(sender)
            PlayerInfoViewMgr.show(SceneMgr.getRunningScene, {})
        end)
        CSResourceMgr.setButtonTexture(resName, "nicon", var.icon, var.icon, var.icon)
        CSResourceMgr.getNodeByName(resName, "nicon"):setScale(0.5)
        local Btn = CSResourceMgr.getNodeByName(resName, "nexample"):clone()
        Btn:setVisible(true)
        CSResourceMgr.getNodeByName(resName, "nlist"):pushBackCustomItem(Btn)
        Btn:setScaleY(0)
        transition.scaleTo(Btn, {scaleY = 1, time = 0.1})
        return Btn
    end, function(callback)
        plistLayer:performWithDelay(function()
            TownPlayerListMgr.nrefreshFinished()
            callback()
        end, 1)
    end, function(callback)
        plistLayer:performWithDelay(function()
            TownPlayerListMgr.nrequestFinished()
            callback()
        end, 1)
    end)
    
    flistObj = CSResourceMgr.setCommonListInfo({}, resName, "flist", "", nil, nil, function(id, var)
        local info = var.info
        CSResourceMgr.setLabelString(resName, "fname", "Lv."..var.level.." "..var.name, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        CSResourceMgr.setLabelString(resName, "finfo", var.info, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        CSResourceMgr.clickEventBinding(resName, "fexample", function(sender)
            PlayerInfoViewMgr.show(SceneMgr.getRunningScene, {})
        end)
        CSResourceMgr.setButtonTexture(resName, "ficon", var.icon, var.icon, var.icon)
        CSResourceMgr.getNodeByName(resName, "ficon"):setScale(0.5)
        CSResourceMgr.setButtonEnabled(resName, "fstatus", var.status)
        local Btn = CSResourceMgr.getNodeByName(resName, "fexample"):clone()
        Btn:setVisible(true)
        CSResourceMgr.getNodeByName(resName, "flist"):pushBackCustomItem(Btn)
        Btn:setScaleY(0)
        transition.scaleTo(Btn, {scaleY = 1, time = 0.1})
        return Btn
    end, function()
        plistLayer:performWithDelay(function()
            TownPlayerListMgr.frefreshFinished()
        end, 1)
    end, function()
        plistLayer:performWithDelay(function()
            TownPlayerListMgr.frequestFinished()
        end, 1)
    end)

    --根据屏幕分辨率设置列表高度
    local rect = cc.Director:getInstance():getOpenGLView():getViewPortRect()
    local rectW = rect.width+rect.x*2
    local rectH = rect.height+rect.y*2
    local rate = rectH/rectW
    local b_posy = TownMapBoardMgr.BoardPosy
    local nlist = CSResourceMgr.getNodeByName(resName, "nlist")
    local flist = CSResourceMgr.getNodeByName(resName, "flist")
    local lsize = nlist:getInnerContainerSize()
    local listH = b_posy+400*(rate-1)-105  --105为运算差值:105=((500-listPosy)+45)
    if listH>600 then
    	listH = 600
    end
    nlist:setContentSize({width=lsize.width, height=listH})
    flist:setContentSize({width=lsize.width, height=listH})
    
    CSResourceMgr.clickEventBinding(resName, "ntop", function()
        nlist:scrollToTop(0.2, true)
    end)
    CSResourceMgr.clickEventBinding(resName, "ftop", function()
        flist:scrollToTop(0.2, true)
    end)

    plistLayer:setPositionX(-640)
end

function TownPlayerListMgr.removeUI()
    UnblockLoader.cancel("CommonList-LoadItem"..resName.."nlist")
    UnblockLoader.cancel("CommonList-LoadItem"..resName.."flist")
    CSResourceMgr.getNodeByName(resName, "nlist"):removeAllItems()
    CSResourceMgr.getNodeByName(resName, "flist"):removeAllItems()
    CSResourceMgr.removeCSObjectByTag(resName)
end

function TownPlayerListMgr.changeStatus(status)
    local clayer = CSResourceMgr.getCsbObj(resName)    
    if not clayer then
    	return
    end
    if status==3 then
        clayer:setPositionX(640)
        transition.moveTo(clayer, {x=0, time=0.2})
    else
        clayer:setPositionX(0)
        transition.moveTo(clayer, {x=-640, time=0.2})
        clayer:performWithDelay(function()
            TownPlayerListMgr.removeUI()
        end, 0.2)
    end
end

function TownPlayerListMgr.nrefreshFinished()
    nlistObj.setContent(nearbyList)
end

function TownPlayerListMgr.nrequestFinished()
end

function TownPlayerListMgr.frefreshFinished()
    flistObj.setContent(friendsList)
end

function TownPlayerListMgr.frequestFinished()
end

return TownPlayerListMgr