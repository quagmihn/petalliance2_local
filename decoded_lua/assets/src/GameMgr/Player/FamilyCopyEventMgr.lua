local FamilyCopyEventMgr = {}

local resName = ""

function FamilyCopyEventMgr.Init()
    resName = "Player/Family/FamilyCopyEvent.csb"
end

function FamilyCopyEventMgr.hideUI()
    GameAudio.playUISound("retract")
    UnblockLoader.cancel("FamilyCopyEventMgr")
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("FamilyCopyEventMgr")
end

local function initStaticData()
    CSResourceMgr.setLabelString(resName, "txt_maintitle", "family92", nil, {r=0,g=0,b=0,a=255,w=2})
end

local function initCell(event)
    local members = FamilyInfo.GetLocalFamilyMembersInfo()
    if members ~= nil then
        local member = members[tostring(event.charID)]
        if member ~= nil then
            local log = CSResourceMgr.getNodeByName(resName,"btn_listexample"):clone()
            local name = CSResourceMgr.seekNodeByName(log, "txt_playername")
            CSResourceMgr.setLabelStringByNode(name, member.name, {r=0,g=0,b=0,a=255,w=1})
            
            local txtTime = CSResourceMgr.seekNodeByName(log, "txt_time")
            CSResourceMgr.setLabelStringByNode(txtTime, CocosModuleMgr.getTimeStr(event.time, 4).."-"..CocosModuleMgr.getTimeStr(event.time, 5).."  "..CocosModuleMgr.getTimeStr(event.time), {r=0,g=0,b=0,a=255,w=1})
            
            local txtLog = CSResourceMgr.seekNodeByName(log, "txt_log")
            local strFloor = CocosModuleMgr.createStringWithFormat({"family103", event.floor + 1})
            local strAction = ""
            if event.action == 0 then
                strAction = LuaSqlite.getLanguageByKey("family104")
            elseif event.action == 1 then
                if event.eventType == Proto.FDET_PVE then
                    strAction = LuaSqlite.getLanguageByKey("family105")
                elseif event.eventType == Proto.FDET_RANDOMCHEST then
                    strAction = LuaSqlite.getLanguageByKey("family107")
                elseif event.eventType == Proto.FDET_ATTRIBUTECHANGE then
                    strAction = LuaSqlite.getLanguageByKey("family108")
                end
            elseif event.action == 2 then
                strAction = LuaSqlite.getLanguageByKey("family106")
            end
            local strObjectName = ""
            if event.eventType == Proto.FDET_PVE then
                local petID = FamilyDataInfo.getFamilyMonsterInfoById(event.eventID).petnumber
                local petInfo = PokemonInfo.getPokemonInfoByID(petID)
                strObjectName = LuaSqlite.getLanguageByKey(petInfo.name)
            elseif event.eventType == Proto.FDET_RANDOMCHEST then
                strObjectName = LuaSqlite.getLanguageByKey(FamilyDataInfo.getFamilyRandomChestInfoById(event.eventID).display)
            elseif event.eventType == Proto.FDET_ATTRIBUTECHANGE then
                strObjectName = LuaSqlite.getLanguageByKey(FamilyDataInfo.getFamilyAttributeChangeInfoById(event.eventID).display)
            end
            txtLog:setString(strFloor..strAction..strObjectName)
            
            local pic = CSResourceMgr.seekNodeByName(log,"pic_headicon")
            local fashionInfo = ItemInfo.getFashionItemInfoById(member.fashion.curFashion[1])
            pic:loadTexture(fashionInfo.filePath)
            
            local lv = CSResourceMgr.seekNodeByName(log, "txt_playerlv")
            CSResourceMgr.setLabelStringByNode(lv, "Lv"..member.level, {r=0,g=0,b=0,a=255,w=1})
            lv:setVisible(true)
            
            return log
        end
    end
    return nil
end

function FamilyCopyEventMgr.createList(eventLog)
    if CSResourceMgr.getCsbObj(resName) and eventLog ~= nil and #eventLog > 0 then
        local list = CSResourceMgr.getNodeByName(resName,"list1")
        list:removeAllItems()

        local funcTable = {}
        UnblockLoader.cancel("FamilyCopyEventMgr")
        for i=1,#eventLog do
            table.insert(funcTable,function()
                local event = eventLog[i]
                local cell = initCell(event)
                if cell ~= nil then
                    cell:setVisible(true)
                    cell:setScaleY(0)
                    list:pushBackCustomItem(cell)
                    transition.scaleTo(cell,{scale=1.0,time = 0.1})
                end
            end)
        end
        UnblockLoader.load(funcTable, "FamilyCopyEventMgr")
    end
end

function FamilyCopyEventMgr.show(scene)
    if CSResourceMgr.getCsbObj(resName) or CharInfo.getFamilyID() == nil then
        return  
    end
    GameAudio.playUISound("popup")
    UIStack.push("FamilyCopyEventMgr",FamilyCopyEventMgr.hideUI,false)
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)

        CSResourceMgr.clickEventBinding(resName, "bg", function()
            FamilyCopyEventMgr.hideUI()
        end)

        CSResourceMgr.clickEventBinding(resName, "close", function()
            FamilyCopyEventMgr.hideUI()
        end)

        initStaticData()
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
    
    FamilyInfo.GetFamilyEventLog()
end

return FamilyCopyEventMgr