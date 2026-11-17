local itemDescViewMgr = {}

local resName = "Searching/Common/itemInfoLayer.csb"

function itemDescViewMgr.Init()
    print("itemDescViewMgr初始化")
end

function itemDescViewMgr.show(info)
    local scene = SceneMgr.getRunningScene
    local curLayer

    local function loadCSB()
        curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder( SearchingUIMgr.ZORDER_COVER_SHADOW )
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        curLayer:setVisible(false)

        local itemName = CSResourceMgr.getNodeByName("Searching/Common/itemInfoLayer.csb","itemName")
        local itemDesc = CSResourceMgr.getNodeByName("Searching/Common/itemInfoLayer.csb","itemDesc")
        CSResourceMgr.setLabelString("Searching/Common/itemInfoLayer.csb","itemName",info.name,"",{r=0,g=0,b=0,a=255})
        CSResourceMgr.setLabelString("Searching/Common/itemInfoLayer.csb","itemDesc",info.desc,"",{r=0,g=0,b=0,a=255})

        CSResourceMgr.clickEventBinding(resName, "db", function()
            itemDescViewMgr.hide()
        end)
    end

    local function playCSB()
        curLayer:setVisible(true)
        CSResourceMgr.playAction(resName, 0, 5, false)
    end

    local funcTable = {loadCSB, playCSB}

    UnblockLoader.load(funcTable)
end

function itemDescViewMgr.hide()   
    CSResourceMgr.removeCSObjectByTag(resName) 
end

return itemDescViewMgr