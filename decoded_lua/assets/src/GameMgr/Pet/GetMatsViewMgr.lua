-- 宠物养成获取材料二级弹窗
local GetMatsViewMgr = {}

local resName = "Pet/Education/common/getMatsPage.csb"

local list

function GetMatsViewMgr.Init()
end

function GetMatsViewMgr.show(scene, info)
    local curLayer
    local function loadCSB()
        curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(25)
        curLayer:setVisible(false)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.clickEventBinding(resName,"close",function()
            GetMatsViewMgr.hide()
        end)

        list = CSResourceMgr.getNodeByName(resName,"list")
        local sample = CSResourceMgr.getNodeByName(resName,"sample")
        
        for i=1,6 do
            local item = sample:clone()
            
            CSResourceMgr.clickEventBindingByNode(item,function()
                print("item"..i)
            end)
            
            CSResourceMgr.clickEventBindingByNode(CSResourceMgr.seekNodeByName(item, "go"),function()
                print("go"..i)
            end, true)
            
            list:pushBackCustomItem(item)
        end
        
    end

    local function playCSB()
        curLayer:setVisible(true)
        CSResourceMgr.playAction(resName,0,5)
    end

    local funcTable = {loadCSB, playCSB}

    UnblockLoader.load(funcTable)
end

function GetMatsViewMgr.hide()
    list:removeAllItems()
    CSResourceMgr.removeCSObjectByTag(resName)
end

return GetMatsViewMgr