local FamilyLogViewMgr = {}

local resName = ""
local difficultyString = {}

function FamilyLogViewMgr.Init()
    resName = "Player/Family/FamilyLogView.csb"
    difficultyString = {
        [1] = "C",
        [2] = "B",
        [3] = "A",
        [4] = "S",
    }
end

function FamilyLogViewMgr.hideUI()
    GameAudio.playUISound("retract")
    UnblockLoader.cancel("FamilyLogViewMgr")
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("FamilyLogViewMgr")
end

local function initStaticData()
    CSResourceMgr.setLabelString(resName, "txt_maintitle", "family72", nil, {r=0,g=0,b=0,a=255,w=2})
    CSResourceMgr.setButtonString(resName, "btn_close", "family45", nil, {r=0,g=0,b=0,a=255,w=1})
end

local function initCell(logInfo, type)
    local color, logStr
    if type == 0 then
        color = {r=255,g=252,b=0,a=255}
        logStr = "family91"
    elseif type == 1 then
        color = {r=161,g=241,b=6,a=255}
        logStr = "family89"
    else
        color = {r=241,g=111,b=6,a=255}
        logStr = "family90"
    end
    
    local members = FamilyInfo.GetLocalFamilyMembersInfo()
    if members ~= nil then
        local member = members[tostring(logInfo.charID)]
        if member ~= nil then
            local log = CSResourceMgr.getNodeByName(resName,"btn_listexample"):clone()
            local name = CSResourceMgr.seekNodeByName(log, "txt_playername")
            CSResourceMgr.setLabelStringByNode(name, member.name, {r=0,g=0,b=0,a=255,w=1})
            
            local txtTime = CSResourceMgr.seekNodeByName(log, "txt_time")
            CSResourceMgr.setLabelStringByNode(txtTime, CocosModuleMgr.getTimeStr(logInfo.t, 4).."-"..CocosModuleMgr.getTimeStr(logInfo.t, 5).."  "..CocosModuleMgr.getTimeStr(logInfo.t), {r=0,g=0,b=0,a=255,w=1})
            
            local txtLog = CSResourceMgr.seekNodeByName(log, "txt_log")
            CSResourceMgr.setLabelColorByNode(txtLog, color)
            local questInfo = QuestInfo.getFamilyQuestInfoById(logInfo.familyQuestID)
            --阿杜修改英文版显示
            CSResourceMgr.setLabelMaxWidthByNode(txtLog, 370)
            CSResourceMgr.setLabelStringByNode(txtLog, CocosModuleMgr.createStringWithFormat({logStr, difficultyString[questInfo.classType], questInfo.name}), {r=0,g=0,b=0,a=255,w=1})
            
            local pic = CSResourceMgr.seekNodeByName(log,"pic_headicon")
            local fashionInfo = ItemInfo.getFashionItemInfoById(member.fashion.curFashion[1])
            pic:loadTexture(fashionInfo.filePath)
            
            return log
        end
    end
    return nil
end

function FamilyLogViewMgr.createList(questLog)
    if CSResourceMgr.getCsbObj(resName) and questLog ~= nil and #questLog > 0 then
        local list = CSResourceMgr.getNodeByName(resName,"list1")
        list:removeAllItems()
        
        local funcTable = {}
        UnblockLoader.cancel("FamilyLogViewMgr")
        for i=#questLog,1,-1 do
            table.insert(funcTable,function()
                local log = questLog[i]
                local cell
                if log.isApply == 1 then
                    cell = initCell(log, 0)
                elseif log.familyQuestOK == 1 then
                    cell = initCell(log, 1)
                else
                    cell = initCell(log, 2)
                end
                if cell ~= nil then
                    cell:setVisible(true)
                    cell:setScaleY(0)
                    list:pushBackCustomItem(cell)
                    transition.scaleTo(cell,{scale=1.0,time = 0.1})
                end
            end)
        end
        UnblockLoader.load(funcTable, "FamilyLogViewMgr")
    end
end

local function initDynamicData()
end

function FamilyLogViewMgr.show(scene)
    if CSResourceMgr.getCsbObj(resName) or CharInfo.getFamilyID() == nil then
        return
    end
    GameAudio.playUISound("popup")
    UIStack.push("FamilyLogViewMgr",FamilyLogViewMgr.hideUI,false)
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)

        CSResourceMgr.clickEventBinding(resName, "bg", function()
            FamilyLogViewMgr.hideUI()
        end)

        CSResourceMgr.clickEventBinding(resName, "btn_close", function()
            FamilyLogViewMgr.hideUI()
        end)

        initStaticData()
        
        initDynamicData()
    end
    
    local function playCSB()
        local node = CSResourceMgr.getNodeByName(resName, "db")
        if node ~= nil then
            node:setVisible(true)
            CocosModuleMgr.showUIAnimation(node, "down")
        end
    end
    
    loadCSB()
    playCSB()
    
    FamilyInfo.QueryMyFamily()
end

return FamilyLogViewMgr