-- 宠物养成消耗二级弹窗

local EduConsViewMgr = {}

local resName = "Pet/Education/common/consumePage.csb"

local list

local consumeItems = {}

local a_idx = {
    "hpx",
    "atk",
    "def",
    "satk",
    "sdef",
    "speed",
}

function EduConsViewMgr.Init()
end

function EduConsViewMgr.show(scene, info, callback)
    print("ssssshow")
    for k, v in pairs(info) do
        print(k, v)
        for kk, vv in pairs(v) do
            print(kk,vv)
        end
    end

    local curLayer
    local function loadCSB()
        curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(25)
        curLayer:setVisible(false)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.clickEventBinding(resName,"close",function()
            EduConsViewMgr.hide()
        end)
        
        list = CSResourceMgr.getNodeByName(resName,"conList")
        local sample = CSResourceMgr.getNodeByName(resName,"tc_k")

        local g_cons = 0
        local m_cons = 0
        
        for k,v in pairs(info) do
            for kk,vv in pairs(v) do
                local i_info = ItemInfo.getItemInfoById( vv.elementID )
                local item = sample:clone()
                
                -- update g cash
                g_cons = g_cons + vv.gcash
                
                local i_name = CSResourceMgr.seekNodeByName(item,"m_name")
                CSResourceMgr.setLabelColorByNode(i_name,{r=255,g=255,b=255,a=255})
                CSResourceMgr.setLabelStringByNode(i_name,i_info.name,{r=0,g=0,b=0,a=255})

                CSResourceMgr.seekNodeByName(item,"m_icon"):loadTexture(i_info.icon)

                local i_num = CSResourceMgr.seekNodeByName(item,"m_num")
                CSResourceMgr.setLabelStringByNode(i_num,"x"..vv.num,{r=0,g=0,b=0,a=255})
                
                list:pushBackCustomItem(item)
            end
        end
        
        CSResourceMgr.setLabelColor(resName,{"tc_d","tc_d2","G_num"},{r=255,g=255,b=0,a=255})
        CSResourceMgr.setLabelString(resName,{"tc_d","tc_d2","G_num"},"消耗："..g_cons,"",{r=0,g=0,b=0,a=255})
        CSResourceMgr.setLabelColor(resName,{"tc_d","tc_d2","M_num"},{r=255,g=255,b=0,a=255})
        CSResourceMgr.setLabelString(resName,{"tc_d","tc_d2","M_num"},"消耗："..m_cons,"",{r=0,g=0,b=0,a=255})
        
        CSResourceMgr.clickEventBinding(resName,"confirm",function()
            callback()
            EduConsViewMgr.hide()
        end)
        CSResourceMgr.setButtonString(resName,"confirm","train24","",CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
    end
    
    local function playCSB()
        curLayer:setVisible(true)
        CSResourceMgr.playAction(resName,0,5)
    end
    
    local funcTable = {loadCSB, playCSB}
    
    UnblockLoader.load(funcTable)
end

function EduConsViewMgr.hide()
    list:removeAllItems()
    CSResourceMgr.removeCSObjectByTag(resName)
end

return EduConsViewMgr