-- create on 2016-05-05

local LtStepAddView = {}

local config = {
    title = {
        textColor = {
            {r=144,g=238,b=255,a=255},
        },
        outlineColor = {r=0,g=0,b=0,a=255,w=1},
    },
    label_t = {
        textColor = {
            {r=254,g=243,b=57,a=255},
        },
        outlineColor = {r=0,g=0,b=0,a=255,w=1},
        width = 160,
    },
    label_n = {
        textColor = {
            {r=255,g=255,b=255,a=255},
        },
        outlineColor = {r=0,g=0,b=0,a=255,w=1},
        width = 48,
    },
    label_added = {
        textColor = {
            {r=184,g=255,b=47,a=255},
        },
        outlineColor = {r=0,g=0,b=0,a=255,w=1},
        width = 73,
    },
    m_num = {
        textColor = {
            {r=255,g=255,b=255,a=255},
            {r=255,g=72,b=0,a=255},
        },
        outlineColor = {r=0,g=0,b=0,a=255,w=1},
    },
    add_num = {
        textColor = {
            {r=247,g=253,b=254,a=255},
        },
        outlineColor = {r=0,g=0,b=0,a=255,w=1},
    },
}

local resName = "LostTower/Others/LtStepAddView.csb"
local tag     = "LtStepAddView"

local Layer
local itemNodes = {}

local actionItems = {}

local actionAdded = 0

local function refreshResultArea()
    local _label = CSResourceMgr.getNodeByName(resName, {"tc_d","tc_d2","label_added"},tag)
    CSResourceMgr.setLabelStringByNode(_label, "+"..actionAdded)
end

local function refreshNode(node, info)
    if not node then return end

    local numLabel = CSResourceMgr.seekNodeByName(node, "m_num")
    if info.num - info.useNum > 0 then
        CSResourceMgr.seekNodeByName(node, "gray"):setVisible(false)
        CSResourceMgr.setLabelColorByNode(numLabel, config["m_num"].textColor[1])
    else
        CSResourceMgr.seekNodeByName(node, "gray"):setVisible(true)
        CSResourceMgr.setLabelColorByNode(numLabel, config["m_num"].textColor[2])
    end
    CSResourceMgr.setLabelStringByNode(numLabel, info.num - info.useNum, config["m_num"].outlineColor)
end

local function initNode(node, info)
    if not node then return end

    local itemID = info.id
    local itemInfo = ItemInfo.getItemInfoById(itemID)

    local nameLabel = CSResourceMgr.seekNodeByName(node, "m_name")
    CSResourceMgr.setLabelColorByNode(nameLabel, ItemInfo.COLOR[itemInfo.itemRare+1])
    CSResourceMgr.setLabelStringByNode(nameLabel, itemInfo.name, config["m_num"].outlineColor)

    local numLabel = CSResourceMgr.seekNodeByName(node, "m_num")
    if info.num - info.useNum > 0 then
        CSResourceMgr.seekNodeByName(node, "gray"):setVisible(false)
        CSResourceMgr.setLabelColorByNode(numLabel, config["m_num"].textColor[1])
    else
        CSResourceMgr.seekNodeByName(node, "gray"):setVisible(true)
        CSResourceMgr.setLabelColorByNode(numLabel, config["m_num"].textColor[2])
    end
    CSResourceMgr.setLabelStringByNode(numLabel, info.num - info.useNum, config["m_num"].outlineColor)

    local itemDB = CSResourceMgr.seekNodeByName(node, "m_slot")
    local dbTexture = ItemInfo.getItemRareBGImage(itemID)
    itemDB:loadTexture(dbTexture)

    local iconTex = CSResourceMgr.seekNodeByName(node, "m_icon")
    iconTex:loadTexture(itemInfo.icon)
    iconTex:setScale(0.6)

    local addNumLabel = CSResourceMgr.seekNodeByName(node, "add_num")
    local text = LuaSqlite.getLanguageByKey("LtText4").."+"..itemInfo.paramA
    CSResourceMgr.setLabelColorByNode(addNumLabel, config["add_num"].textColor[1])
    CSResourceMgr.setLabelStringByNode(addNumLabel, text, config["add_num"].outlineColor,nil,64)

    CSResourceMgr.clickEventBindingByNode(node, function ()
        if info.num - info.useNum > 0 then
            info.useNum = info.useNum + 1
            actionAdded = actionAdded + itemInfo.paramA
            
            refreshNode(node, info)
            refreshResultArea()
        end
    end)
end

local function resetItems(items)
    local list   = CSResourceMgr.getNodeByName(resName, {"tc_d","tc_d2","listview"},tag)
    local parent = CSResourceMgr.getNodeByName(resName, "tc_k",tag)
    
    local funcTable = {}
    
    for i = 1, #items do
        table.insert(funcTable, function()
            itemNodes[i] = parent:clone()
            initNode(itemNodes[i], items[i])
            list:pushBackCustomItem(itemNodes[i])

            itemNodes[i]:setVisible(false)
            itemNodes[i]:setScale(0.95)
            list:performWithDelay(function()
                local scale1 = cc.ScaleTo:create(0.1, 1.05)
                local scale2 = cc.ScaleTo:create(0.1, 1.0)
                itemNodes[i]:setVisible(true)
                itemNodes[i]:runAction(cc.Sequence:create(scale1, scale2))
            end,0.05*(i-1))
        end)
    end
    
--    UnblockLoader.load(funcTable,"LtStepAddView-resetItems")

    for i=1, #funcTable do funcTable[i]() end
end

local function sendReq(_callback)
    local ItemSend = require("src.Net.Send.ItemSend")
    
    local function send(i)
        if i > #actionItems then
            if _callback then _callback() end
            return
        end
        
        if actionItems[i].useNum <= 0 then
            send(i + 1)
        else
            NetInterface.sendWithBlock("GC_UseItem_Ack", function()
                ItemSend.sendCG_UseItem_Req({
                    itemID = actionItems[i].id,
                    targetNum = 0,
                    targetStr = "",
                    useNum = actionItems[i].useNum,
                })
            end, function()
                send(i + 1)
            end,function(code)
            end)
        end
    end
    
    send(1)

end

function LtStepAddView.Init()
end

function LtStepAddView.show(scene, successCallback)
    UIStack.push("LtStepAddView",LtStepAddView.hide)
    GameAudio.playUISound("popup")

    scene = scene or SceneMgr.getRunningScene
    
    local function loadCSB()
        Layer =  CSResourceMgr.createRes(scene,resName,tag)
        CSResourceMgr.setRelativePosition(resName, 320, 480, tag)
        Layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        
        local _label = CSResourceMgr.getNodeByName(resName, {"tc_d","title"},tag)
        CSResourceMgr.setLabelColorByNode(_label, config["title"].textColor[1])
        CSResourceMgr.setLabelStringByNode(_label, "LtText61", config["title"].outlineColor)
        
        local cellNameTable = {"label_t","label_n","label_added"}
        local textTable     = {"LtText62",LostTowerMgr.getStepNumber(),"+"..0}
        for index, _cellName in pairs(cellNameTable) do
            local _label = CSResourceMgr.getNodeByName(resName, {"tc_d","tc_d2",_cellName},tag)
            CSResourceMgr.setLabelColorByNode(_label, config[_cellName].textColor[1])
            CSResourceMgr.setLabelStringByNode(_label, textTable[index], config[_cellName].outlineColor,nil,config[_cellName].width)
        end
        
        CSResourceMgr.setButtonString(resName, {"tc_d", "confirm"}, "LtYes",tag) -- "确定"        
    end
    
    local function init()
        local itemID = SystemInfo.getGlobalConfigAddInfoByID(52).values
        
        for i = 1, #itemID do
            local _num = ItemInfo.getCharItemNum(itemID[i])
            table.insert(actionItems, {id = itemID[i], num = _num,  useNum = 0})
        end
    
        resetItems(actionItems)
    end
    
    local function playAction()
        local board = CSResourceMgr.getNodeByName(resName, "tc_d", tag)
        board:setOpacity(255)
        CocosModuleMgr.showUIAnimation(board, "down")

        local fade = cc.FadeTo:create(0.2, 180)  -- 70%
        CSResourceMgr.getNodeByName(resName, "block", tag):runAction(fade)
    end
    
    local function bindEvent()
        CSResourceMgr.clickEventBinding(resName,{"tc_d", "close"},function()
            LtStepAddView.hide()
        end,tag)

        CSResourceMgr.clickEventBinding(resName,{"tc_d", "confirm"},function()
            sendReq(function()
                if successCallback then
                    successCallback(actionAdded)
                end
                LtStepAddView.hide()
            end)
        end,tag)
    end
    
    local funcTable = {loadCSB, init, playAction, bindEvent}
    
--    UnblockLoader.load(funcTable,"LtStepAddView-show")
    
    for i=1, #funcTable do funcTable[i]() end
        
end

function LtStepAddView.hide()
    UIStack.pop("LtStepAddView")
    GameAudio.playUISound("retract")

    itemNodes = {}
    actionItems = {}
    actionAdded = 0
    CSResourceMgr.removeCSObjectByTag(resName,tag)
end

return LtStepAddView