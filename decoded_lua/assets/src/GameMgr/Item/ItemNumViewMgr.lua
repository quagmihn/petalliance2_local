local ItemNumViewMgr = {}

local resName = ""
local editBox = nil

function ItemNumViewMgr.Init()
    resName = "Item/InfoTips/SellView.csb"
    editBox = nil
end

---物品信息
--e.g. {id = id, sum = num}
--e.g. {id = id, sum = num, title = title, award = ScienceInfo.ITEM_ID, richtext = "", max = max, price = price}
function ItemNumViewMgr.show(info, callback)
    local scene = SceneMgr.getRunningScene
    if (info.sum or 0)<=0 then
        StandardTipsMgr.show(1, "train120")
        return
    end
    UIStack.push("ItemNumViewMgr", ItemNumViewMgr.hide, false)
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)

        local selNum = 1
        local iteminfo = ItemInfo.getItemInfoById(info.id)
        local gprice = iteminfo.reclaimPrice or 0
        local price = info.price or gprice
        local aid = info.award or 9998
        
        CSResourceMgr.setLabelColor(resName, "title", {r=166,g=243,b=255,a=255})
        CSResourceMgr.setLabelString(resName, "title", info.title or "iteminfo8", "", {r=37,g=54,b=75,a=255})

        CSResourceMgr.setLabelString(resName, "name", iteminfo.name, "", {r=0,g=0,b=0,a=255}, nil, 300)
        CSResourceMgr.setLabelColor(resName, "name", {r=55,g=178,b=219,a=255})

        CSResourceMgr.setSpriteTexture(resName, "icdb", ItemInfo.getItemRareBGImage(info.id))
        CSResourceMgr.setSpriteTexture(resName, "icon", iteminfo.icon)
        
        local sumLabel = CSResourceMgr.getNodeByName(resName, "num")
        CSResourceMgr.setLabelString(resName, "num", "x"..info.sum, "", nil, nil, 100)
        sumLabel:enableOutline({r=0,g=0,b=0,a=255}, 1)

        if info.richtext then
            CocosModuleMgr.createRichLabel(CSResourceMgr.getNodeByName(resName, "db"), info.richtext, 20, "cuyuan_GBK.ttf", 250, 240, 620)
        else
            local usetip = CSResourceMgr.getNodeByName(resName, "usetip")
            CSResourceMgr.setLabelString(resName, "usetip", "iteminfo1", "", nil, nil, 300)
            CSResourceMgr.setLabelColor(resName, "usetip", {r=217,g=234,b=255,a=255})
            usetip:enableOutline({r=0,g=0,b=0,a=255}, 1)
        end
        
        local numtitle = CSResourceMgr.getNodeByName(resName, "info")
        CSResourceMgr.setLabelString(resName, "info", "iteminfo7", "", nil, nil, 100)
        CSResourceMgr.setLabelColor(resName, "info", {r=144,g=238,b=255,a=255})
        numtitle:enableOutline({r=38,g=54,b=76,a=255}, 1)
        
        local maxBtn = CSResourceMgr.getNodeByName(resName, "maxBtn")
        CSResourceMgr.setButtonStringByNode(maxBtn, "MAX", {r=45,g=62,b=1,a=255})
        CSResourceMgr.setButtonStringColorByNode(maxBtn, {r=255,g=255,b=255,a=255})

        local strVec = {"iteminfo9", "iteminfo10", "iteminfo11"}
        local widthVec = {90, 90, 130}
        local ainfo = ItemInfo.getItemInfoById(aid)
        for var=1, #strVec do
            CSResourceMgr.setLabelString(resName, "title"..var, strVec[var], "", nil, nil, widthVec[var])
            CSResourceMgr.setLabelColor(resName, "title"..var, {r=144,g=238,b=255,a=255})
            CSResourceMgr.setLabelColor(resName, "gold"..var, {r=144,g=238,b=255,a=255})
            CSResourceMgr.getNodeByName(resName, "gb"..var):scale(0.5)
            CSResourceMgr.setSpriteTexture(resName, "gb"..var, ainfo.icon)
        end
        CSResourceMgr.getNodeByName(resName, "title3"):setPositionX(180)
        CSResourceMgr.setLabelString(resName, "title3", CocosModuleMgr.createStringWithFormat({"science11", ainfo.name}), 
            "", nil, nil, widthVec[3])
        
        CSResourceMgr.setLabelString(resName, "gold1", price, "", nil, nil, 180)
        
        local function checkMoneyFunc(sellnum)
            if not sellnum then
            	return
            end
            local numstring = ""
            if aid==9998 then
                numstring = CocosModuleMgr.getNumberString(CharInfo.getGCash())
            elseif aid==ScienceInfo.ITEM_ID then
                numstring = CocosModuleMgr.getNumberString(ScienceInfo.getSciencePoint())
            end
            CSResourceMgr.setLabelString(resName, "gold3", numstring, "", nil, nil, 170)
            CSResourceMgr.setLabelString(resName, "gold2", CocosModuleMgr.getNumberString(price*sellnum), "", nil, nil, 180)
        end

        CSResourceMgr.clickEventBindingByNode(maxBtn, function()
            local max = info.max or info.sum
            local sum = math.min(info.sum, max)
            editBox:setText(tostring(sum))
            selNum = sum
            checkMoneyFunc(selNum)
        end)
        
        editBox = CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resName, "edit"), "UI/CommonFiles/chat_text_box_su.png", 
            150, 36, 0, 0, 24, 32, "", 2, function()
                selNum = tonumber(editBox:getText())
                if selNum then
                    if selNum>info.sum then
                        selNum = info.sum
                    elseif selNum<=0 then
                        selNum = 1
                    end
                else
                    selNum = 1
                end
                editBox:setText(selNum.."")
                checkMoneyFunc(selNum)
            end)
        editBox:setText(selNum.."")
        checkMoneyFunc(selNum)
        
        --[[
        local slider = CSResourceMgr.getNodeByName(resName, "slider")
        slider:setPercent(selNum/info.sum*100)
        slider:addEventListener(function(sender, state)
            selNum = math.ceil(info.sum*slider:getPercent()/100)
            CSResourceMgr.setLabelString(resName, "num", selNum, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            local per = selNum/info.sum*100
            slider:setPercent(per)
        end)
        CSResourceMgr.setLabelString(resName, "num", selNum, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        CSResourceMgr.clickEventBinding(resName, "minus", function()
        	if selNum>0 then
                selNum = selNum - 1
                CSResourceMgr.setLabelString(resName, "num", selNum, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
                local per = selNum/info.sum*100
                slider:setPercent(per)
        	end
        end)
        CSResourceMgr.clickEventBinding(resName, "plus", function()
            if selNum<info.sum then
                selNum = selNum + 1
                CSResourceMgr.setLabelString(resName, "num", selNum, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
                local per = selNum/info.sum*100
                slider:setPercent(per)
            end
        end)
        ]]

        CSResourceMgr.setButtonString(resName, "sell", "tips3", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        CSResourceMgr.clickEventBinding(resName, "sell", function()
            if selNum>0 then
                if callback then
                    callback(selNum)
                end
            end
            ItemNumViewMgr.hide()
        end)
        CSResourceMgr.clickEventBinding(resName, "close", function()
            ItemNumViewMgr.hide()
        end)

        CSResourceMgr.clickEventBinding(resName, "bg", function()
            ItemNumViewMgr.hide()
        end)
    end

    local function playCSB()
        local db = CSResourceMgr.getNodeByName(resName, "db")
        db:setVisible(true)
        CocosModuleMgr.showUIAnimation(db, "down")
    end

    local funcTable = {loadCSB, playCSB}
    UnblockLoader.load(funcTable, "ItemNumViewMgr")
end

function ItemNumViewMgr.hide()
    UnblockLoader.cancel("ItemNumViewMgr")
    CSResourceMgr.playActionWithCallback(resName, 50, 55, 1, function()
        CSResourceMgr.removeCSObjectByTag(resName)
        editBox = nil
        UIStack.pop("ItemNumViewMgr")
    end)
end

return ItemNumViewMgr