local FamilyNpcManagerViewMgr = {}

local resName = ""

function FamilyNpcManagerViewMgr.Init()
    resName = "Player/Family/FamilyNpcManagerView.csb"
end

local function initStaticData()
    CSResourceMgr.setLabelString(resName, "txt_title", "home015", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, "txt1", "family64", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, "txt2", "family143", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, "txt3", "family144", nil, {r=0,g=0,b=0,a=255,w=1})
    local extra = CSResourceMgr.getNodeByName(resName, "txt_extra")
    CSResourceMgr.setLabelMaxWidthByNode(extra, 390)
    extra:setString(LuaSqlite.getLanguageByKey("family146"))
    CSResourceMgr.setButtonString(resName, "btn_gohome", "menu4", "", {r=0,g=0,b=0,a=255,w=1})
end

function FamilyNpcManagerViewMgr.initDynamicData(info)
    if info ~= nil and CSResourceMgr.getCsbObj(resName) then
        local familyLevel = (info.familyLevel or 1)
        CSResourceMgr.setLabelString(resName, "name", CocosModuleMgr.createStringWithFormat({"family71", familyLevel}), nil, {r=0,g=0,b=0,a=255,w=1})
        
        if familyLevel < FamilyDataInfo.getFamilyLevelInfoTotal() then
            CSResourceMgr.getNodeByName(resName, "upgrade_node"):setVisible(true)
            local devotePoint = info.devote or 0
            local num1 = CSResourceMgr.getNodeByName(resName, "num1")
            CSResourceMgr.setLabelStringByNode(num1, devotePoint, {r=0,g=0,b=0,a=255,w=1})
            local slash = CSResourceMgr.getNodeByName(resName, "slash")
            CSResourceMgr.setLabelStringByNode(slash, "/", {r=0,g=0,b=0,a=255,w=1})
            local num2 = CSResourceMgr.getNodeByName(resName, "num2")
            CSResourceMgr.setLabelStringByNode(num2, FamilyDataInfo.getFamilyLevelInfoById(familyLevel).familyCoin, {r=0,g=0,b=0,a=255,w=1})
            if devotePoint < FamilyDataInfo.getFamilyLevelInfoById(familyLevel).familyCoin then
                CSResourceMgr.setLabelColorByNode(num1,{r=255,g=0,b=0,a=255})
            end
            local bar = CSResourceMgr.getNodeByName(resName, {"db", "upgrade_node", "bar"})
            bar:setPercent(devotePoint/FamilyDataInfo.getFamilyLevelInfoById(familyLevel).familyCoin * 100.0)
        end
        
        CSResourceMgr.setLabelString(resName, "txt_add1", CocosModuleMgr.createStringWithFormat({"family145", FamilyDataInfo.getFamilyDevoteBufferInfoById(familyLevel).bufferRate/100}))
        if familyLevel < FamilyDataInfo.getFamilyLevelInfoTotal() then
            CSResourceMgr.setLabelString(resName, "txt_add2", CocosModuleMgr.createStringWithFormat({"family145", FamilyDataInfo.getFamilyDevoteBufferInfoById(familyLevel + 1).bufferRate/100}))
        else
            CSResourceMgr.getNodeByName(resName, "txt3"):setVisible(false)
            CSResourceMgr.getNodeByName(resName, "txt_add2"):setVisible(false)
        end
    end
end

function FamilyNpcManagerViewMgr.hideUI()
    --UnblockLoader.cancel("FamilyNpcManagerViewMgr")
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("FamilyNpcManagerViewMgr")
end

local function goOwnerFloor()
    GameAudio.playUISound("homeEnter")
    FurnitureViewMgr.goSpecifyFloor(CharInfo.getCharID())
end

function FamilyNpcManagerViewMgr.show(scene)
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end
    UIStack.push("FamilyNpcManagerViewMgr",FamilyNpcManagerViewMgr.hideUI,false)
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)

        CSResourceMgr.clickEventBinding(resName, "bg", function()
            FamilyNpcManagerViewMgr.hideUI()
        end)

        CSResourceMgr.clickEventBinding(resName, "close", function()
            FamilyNpcManagerViewMgr.hideUI()
        end)

        CSResourceMgr.clickEventBinding(resName, "btn_gohome", function()
            FamilyNpcManagerViewMgr.hideUI()
            goOwnerFloor()
        end)
        
        initStaticData()
        
        --initDynamicData()
    end

    local function playCSB()
        local node = CSResourceMgr.getNodeByName(resName, "db")
        if node ~= nil then
            node:setVisible(true)
            CocosModuleMgr.showUIAnimation(node, "down")
        end
    end

    --local funcTable = {loadCSB, playCSB}
    loadCSB()
    playCSB()
    
    FamilyInfo.QueryMyFamily()

    --UnblockLoader.load(funcTable, "FamilyNpcManagerViewMgr")
end

return FamilyNpcManagerViewMgr