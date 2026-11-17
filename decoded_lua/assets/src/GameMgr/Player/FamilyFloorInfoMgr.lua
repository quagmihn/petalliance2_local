local FamilyFloorInfoMgr = {}

local resName = ""

function FamilyFloorInfoMgr.Init()
    resName = "Player/Family/FamilyFloorInfo.csb"
end

function FamilyFloorInfoMgr.hideUI()
    UnblockLoader.cancel("FamilyFloorInfoMgr")
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("FamilyFloorInfoMgr")
end

local function initStaticData()
    CSResourceMgr.setLabelString(resName, "txt_maintitle", "home018", nil, {r=0,g=0,b=0,a=255,w=2})
    CSResourceMgr.setButtonString(resName, "btn_close", "family45", nil, {r=0,g=0,b=0,a=255,w=1})
end

local function initDynamicData()
    local sortMembers = HomeInfo.getAllSortedFamilyMembers()
    if sortMembers ~= nil then
        --print("FamilyFloorInfoMgr sortMembers=",sz_T2S(sortMembers))
        local list = CSResourceMgr.getNodeByName(resName,"list1")
        list:removeAllItems()
        
        local funcTable = {}
        UnblockLoader.cancel("FamilyFloorInfoMgr")
        for i=1, #sortMembers do
            table.insert(funcTable,function()
                local floor = CSResourceMgr.getNodeByName(resName,"btn_listexample"):clone()
                
                local floor_bg = CSResourceMgr.seekNodeByName(floor, "pic_namebg")
                floor_bg:setColor({r=33,g=61,b=82})
                floor_bg:setOpacity(128)
                
                local floor_name = CSResourceMgr.seekNodeByName(floor, "txt_playername")
                CSResourceMgr.setLabelStringByNode(floor_name, sortMembers[i].name, {r=0,g=0,b=0,a=255,w=1})
                
                local pic = CSResourceMgr.seekNodeByName(floor,"pic_headicon")
                local fashionInfo = ItemInfo.getFashionItemInfoById(sortMembers[i].fashion.curFashion[1])
                pic:loadTexture(fashionInfo.filePath)
                
                local floor_lv = CSResourceMgr.seekNodeByName(floor, "txt_playerlv")
                CSResourceMgr.setLabelStringByNode(floor_lv, "Lv"..sortMembers[i].level, {r=0,g=0,b=0,a=255,w=1})
                
                local floor_devote = CSResourceMgr.seekNodeByName(floor, "txt_devote")
                CSResourceMgr.setLabelStringByNode(floor_devote, CocosModuleMgr.createStringWithFormat({"family35", i}))
                
                local percent = FamilyDataInfo.getFamilyDevoteBufferInfoById(#sortMembers - i + 1).bufferRate/100
                local floor_percent = CSResourceMgr.seekNodeByName(floor,"txt_percent")
                CSResourceMgr.setLabelStringByNode(floor_percent, "+"..CocosModuleMgr.createStringWithFormat({"home013", percent}),{r =0,g=0,b=0,a=255,w=1})
                
                local floor_txt = CSResourceMgr.seekNodeByName(floor,"txt_floor")
                CSResourceMgr.setLabelStringByNode(floor_txt, (#sortMembers - i + 1).."F",{r =0,g=0,b=0,a=255,w=2})
                
                CSResourceMgr.clickEventBindingByNode(floor,function()
                    FamilyFloorInfoMgr.hideUI()
                    FurnitureViewMgr.goSpecifyFloor(sortMembers[i].charID)
                end)
                
                floor:setVisible(true)
                floor:setScaleY(0)
                list:pushBackCustomItem(floor)
                transition.scaleTo(floor,{scale=1.0,time = 0.1})
            end)
        end
        
        local info = FamilyInfo.GetLocalFamilyInfo()
        if info then
            table.insert(funcTable,function()
                local floor = CSResourceMgr.getNodeByName(resName,"btn_listexample"):clone()
                
                local floor_bg = CSResourceMgr.seekNodeByName(floor, "pic_namebg")
                floor_bg:setColor({r=33,g=61,b=82})
                floor_bg:setOpacity(128)
                
                local floor_name = CSResourceMgr.seekNodeByName(floor, "txt_playername")
                CSResourceMgr.setLabelStringByNode(floor_name, "family112", {r=0,g=0,b=0,a=255,w=1})
                
                local pic = CSResourceMgr.seekNodeByName(floor,"pic_headicon")
                CSResourceMgr.setSpriteTextureByNode(pic, info.icon)
                
                local floor_lv = CSResourceMgr.seekNodeByName(floor, "txt_playerlv")
                CSResourceMgr.setLabelStringByNode(floor_lv, "Lv"..(info.familyLevel or 1), {r=0,g=0,b=0,a=255,w=1})
                
                CSResourceMgr.seekNodeByName(floor, "txt_devote"):setVisible(false)
                CSResourceMgr.seekNodeByName(floor, "pic_attack"):setVisible(false)
                CSResourceMgr.seekNodeByName(floor, "txt_percent"):setVisible(false)
                local floor_txt = CSResourceMgr.seekNodeByName(floor,"txt_floor")
                CSResourceMgr.setLabelStringByNode(floor_txt, "B1",{r =0,g=0,b=0,a=255,w=2})
                
                CSResourceMgr.clickEventBindingByNode(floor,function()
                    FamilyFloorInfoMgr.hideUI()
                    FurnitureViewMgr.goSpecifyFloor(0)
                end)
    
                floor:setVisible(true)
                floor:setScaleY(0)
                list:pushBackCustomItem(floor)
                transition.scaleTo(floor,{scale=1.0,time = 0.1})
            end)
        end
        
        UnblockLoader.load(funcTable, "FamilyFloorInfoMgr")
    end
end

function FamilyFloorInfoMgr.show(scene)
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end
    UIStack.push("FamilyFloorInfoMgr",FamilyFloorInfoMgr.hideUI,false)
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)
        
        CSResourceMgr.clickEventBinding(resName, "bg", function()
            FamilyFloorInfoMgr.hideUI()
        end)
        
        CSResourceMgr.clickEventBinding(resName, "btn_close", function()
            FamilyFloorInfoMgr.hideUI()
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
end

return FamilyFloorInfoMgr