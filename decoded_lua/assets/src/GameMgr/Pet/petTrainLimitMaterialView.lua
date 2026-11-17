local petTrainLimitMaterialView = {}
local resName = "Pet/Education/PetStarupReset.csb"
function petTrainLimitMaterialView.hide()
    UnblockLoader.cancel("petTrainLimitMaterialView")
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("petTrainLimitMaterialView")
end

function petTrainLimitMaterialView.show(titleStr,itemTbl,numTbl,ownNumTbl,callBack)
    UIStack.push("petTrainLimitMaterialView", petTrainLimitMaterialView.hide, false)

    local function loadCSB()
        local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName)
        CSResourceMgr.setRelativePosition(resName, 320, 480)

        local panel = CSResourceMgr.getNodeByName(resName, "panel")
        panel:setVisible(false)

        local btnClose = CSResourceMgr.getNodeByName(resName, "btn_close")
        CSResourceMgr.clickEventBindingByNode(btnClose, function ()
            petTrainLimitMaterialView.hide()
        end)
    end

    local function loadUI()
        local labelTitle    = CSResourceMgr.getNodeByName(resName, "title")
        local btnCancel     = CSResourceMgr.getNodeByName(resName, "btn_cancel")
        local btnSure       = CSResourceMgr.getNodeByName(resName, "btn_sure")
        local strCancel     = CSResourceMgr.getNodeByName(resName, "str_cancel")
        local strSure       = CSResourceMgr.getNodeByName(resName, "str_sure")
        local parent        = CSResourceMgr.getNodeByName(resName, "background_5")

        local petInfo = PokemonInfo.getPetInfoByObjID(objID)

        -- local str = CocosModuleMgr.createStringWithFormat({"train208", diamondCost})
        local isSure = true
      
        CSResourceMgr.setLabelStringByNode(strCancel, "tips4", nil, nil, 105)
        CSResourceMgr.setLabelStringByNode(strSure, "tips3", nil, nil, 105)
      
        CSResourceMgr.setLabelColorByNode(strCancel, {r=217,g=234,b=255,a=255})
        CSResourceMgr.setLabelColorByNode(strSure, {r=217,g=234,b=255,a=255})

        
        CSResourceMgr.setLabelStringByNode(labelTitle, titleStr, nil, nil, 422)
        CSResourceMgr.setLabelColorByNode(labelTitle, {r=217,g=234,b=255,a=255})

        for k,v in pairs(parent:getChildren()) do
            parent:removeChild(v)
        end
        for key,var in pairs(itemTbl) do 
            
            local itemNode = ItemInfo.getItemIconById(var, numTbl[key])
            local label    = CSResourceMgr.seekNodeByName(itemNode, "l")
            local ownColor = cc.c3b(255, 255, 255)
            local isBool   =  ownNumTbl[key] < numTbl[key]
            itemNode:addTo(parent)
            itemNode:setPosition((#itemTbl - 1) * 130 + 223, 50)
            itemNode:setScale(0.8)
            label:setAnchorPoint(0.0,0.5)
            if isBool then 
                ownColor = cc.c3b(255, 0, 0)
            end
            if isSure and isBool then
                isSure = false
            end
            local ownText    = display.newTTFLabel({
                    font = "cuyuan_GBK.ttf",
                    text = ownNumTbl[key],
                    size = 30, 
                    align = cc.TEXT_ALIGN_CENTER, 
                    color = ownColor
                })
            ownText:setAnchorPoint(1.0,0.5)
            ownText:enableOutline({r = 0,g = 0,b = 0, a = 255},2)
            ownText:addTo(itemNode)
            ownText:setPosition(100,15)
            label:setPosition(100,15)
            ownText:zorder(10)  
            label:setString("/"..numTbl[key])
            CSResourceMgr.clickEventBindingByNode(itemNode, function ()
                ItemInfoViewMgr.show({id = var}, false)
            end)
        end
        
        if not isSure then
            CSResourceMgr.setButtonEnabledByNode(btnSure,false)
            BattleFuncMgr.setNodeGray(btnSure,false) 
        end
        CSResourceMgr.clickEventBindingByNode(btnCancel, function ()
            petTrainLimitMaterialView.hide()
        end)

        CSResourceMgr.clickEventBindingByNode(btnSure, function ()
            if callBack then
                callBack()
            end 
        end)
    end

    local function playAction()
        local panel = CSResourceMgr.getNodeByName(resName, "panel")
        panel:setVisible(true)
        CocosModuleMgr.showUIAnimation(panel, "down")
    end

    local funcTable = {loadCSB, loadUI, playAction}
    UnblockLoader.load(funcTable, "petTrainLimitMaterialView") 
end

return petTrainLimitMaterialView