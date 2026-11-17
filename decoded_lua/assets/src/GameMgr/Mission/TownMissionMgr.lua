local TownMissionMgr = {}

local resName = ""

function TownMissionMgr.Init()
    print("TownMissionMgr初始化")
    
    resName = "UI/Mission/TownMissionLayer.csb"
end

function TownMissionMgr.addUI(board)
    local missionLayer = CSResourceMgr.createRes(board, resName)
    
    CSResourceMgr.setLabelString(resName, "mstitle", "任务列表", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
    
    --根据屏幕分辨率设置列表高度
    local rect = cc.Director:getInstance():getOpenGLView():getViewPortRect()
    local rectW = rect.width+rect.x*2
    local rectH = rect.height+rect.y*2
    local rate = rectH/rectW
    local b_posy = TownMapBoardMgr.BoardPosy
    local list = CSResourceMgr.getNodeByName(resName, "list")
    local lsize = list:getInnerContainerSize()
    local listH = b_posy+400*(rate-1)-95  --95为运算差值:95=((500-listPosy)+45)
    list:setContentSize({width=lsize.width, height=listH})
    
    missionLayer:setPositionX(-640)
end

function TownMissionMgr.reset()
    CSResourceMgr.getNodeByName(resName, "list"):removeAllItems()

    local mTbl = QuestInfo.getCurQuestInfos()
    --测试数据
    table.insert(mTbl, mTbl[1])
    table.insert(mTbl, mTbl[1])
    table.insert(mTbl, mTbl[1])
    table.insert(mTbl, mTbl[1])
    table.insert(mTbl, mTbl[1])
    table.insert(mTbl, mTbl[1])
    table.insert(mTbl, mTbl[1])
    if #mTbl==0 then
        print("当前没有任务，不创建任务UI")
        return false
    end
    local funcTable = {}
    for key, var in pairs(mTbl) do
        local function loadListItem()
            local color = {r=255, g=255, b=255, a=255}
            if var.type == Proto.QUEST_TYPE_MAIN then
                color = {r=255, g=240, b=0, a=255}
            elseif var.type == Proto.QUEST_TYPE_SUB then
                color = {r=0, g=222, b=255, a=255}
            elseif var.type == Proto.QUEST_TYPE_EVERYDAY then
                color = {r=18, g=255, b=0, a=255}
            end
            --为了测试，设置暂时先这么写
            CSResourceMgr.setButtonTexture(resName, "icon", "Pet/PicIcon/239.png", "Pet/PicIcon/239.png", "Pet/PicIcon/239.png")
            CSResourceMgr.setLabelString(resName, "title", var.name, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            CSResourceMgr.setLabelString(resName, "desc", var.desc..var.desc..var.desc, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            CSResourceMgr.setLabelMaxWidth(resName, "desc", 250)
            CSResourceMgr.clickEventBinding(resName, "example", function()
                var.map = "TownScene"
                var.button = "gym"
                MapSeekerMgr.autoSeekPath(var.map, var.button, function()
                    CSResourceMgr.callButtonFunc(TownMapMgr.MapRes, var.button)
                end)
            end)
            local item = CSResourceMgr.getNodeByName(resName, "example"):clone()
            CSResourceMgr.seekNodeByName(item, "title"):setTextColor(color)
            item:setVisible(true)
            CSResourceMgr.getNodeByName(resName, "list"):pushBackCustomItem(item)
            item:setScaleY(0)
            transition.scaleTo(item, {scaleY = 1, time = 0.1})
            if var.strongType=="1" then
            --CocosModuleMgr.setButtonGuide(item)
            end
        end        
        table.insert(funcTable, loadListItem)
    end
    UnblockLoader.load(funcTable, "TownMissionMgr-reset")
end

function TownMissionMgr.removeUI()
    UnblockLoader.cancel("TownMissionMgr-reset")
    CSResourceMgr.getNodeByName(resName, "list"):removeAllItems()
    CSResourceMgr.removeCSObjectByTag(resName)
end

function TownMissionMgr.changeStatus(status)
    local clayer = CSResourceMgr.getCsbObj(resName)
    if not clayer then
    	return
    end
    if status==2 then
        clayer:setPositionX(640)
        transition.moveTo(clayer, {x=0, time=0.2})
        clayer:performWithDelay(function()
            TownMissionMgr.reset()
        end, 0.5)
    else
        clayer:setPositionX(0)
        transition.moveTo(clayer, {x=-640, time=0.2})
        clayer:performWithDelay(function()
            TownMissionMgr.removeUI()
        end, 0.2)
    end
end

return TownMissionMgr