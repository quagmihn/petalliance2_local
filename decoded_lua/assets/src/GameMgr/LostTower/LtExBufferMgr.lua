local LtExBufferMgr = {}

local att = {"atk","def","satk","sdef","speed"}

local textColor   = {r=144,g=238,b=255,a=255} 

local bufferTable = {}

function LtExBufferMgr.Init()
    bufferTable = {}
end

function LtExBufferMgr.getBufferTable()
    return bufferTable
end

function LtExBufferMgr.setBuffBeforeBattle()
    local myTemporaryBuffer = {}
    for i = 1, #att do myTemporaryBuffer[att[i]] = {} end
    for i = 1, #bufferTable do
        local buffInfo = bufferTable[i].buffInfo
        local buffType = buffInfo.subType
        
        if buffInfo.type == 1 then
            if not myTemporaryBuffer[att[buffType]].per then
                myTemporaryBuffer[att[buffType]].per = buffInfo.value
            else
                myTemporaryBuffer[att[buffType]].per = myTemporaryBuffer[att[buffType]].per + buffInfo.value
            end
        elseif buffInfo.type == 2 then
            if not myTemporaryBuffer[att[buffType]].val then
                myTemporaryBuffer[att[buffType]].val = buffInfo.value
            else
                myTemporaryBuffer[att[buffType]].val = myTemporaryBuffer[att[buffType]].val + buffInfo.value
            end
        end
    end
    
    for k, v in pairs(myTemporaryBuffer) do
        if v.per then
            local percent = v.per / 100
            BattleMapMgr.setTemporaryBuffer(k,percent,v.val)
        end
    end
    
    return myTemporaryBuffer
end

local function setEffectLabel(label, info, labelMaxWidth)
    if CocosModuleMgr.checkIsRichLabelString(info) then
        label:removeAllChildren()
        CocosModuleMgr.createRichLabel(label, info, label:getFontSize(), "cuyuan_GBK.ttf", labelMaxWidth, 0, -11, nil, false)
    else
        CSResourceMgr.setLabelStringByNode(label,info,nil,nil,labelMaxWidth)
        CSResourceMgr.setLabelColorByNode(label,textColor)
    end
end

function LtExBufferMgr.setBufferTable(data)
    local cjson = require("cjson")

    bufferTable = {}
    for k, v in pairs(data) do
        local vv = cjson.decode(v)
        local info = clone(LostTowerInfo.getExBuffInfoById(vv.eventID)) or {}
        info.stepNumber = vv.stepNumber or 1
        table.insert(bufferTable, {node = nil, buffInfo = info})
    end
end

function LtExBufferMgr.updateBuff(index)
    if index > #bufferTable then return end
    if not CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,"effect_listView") then return end
    
    local info = bufferTable[index].buffInfo

    local list = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,"effect_listView")
    local effect_db = list:getItem(index - 1)
    local label = CSResourceMgr.seekNodeByName(effect_db,"label")
    local str = info.name or ""
    local _string = CocosModuleMgr.createStringWithFormat({str, info.value, info.stepNumber})
    setEffectLabel(label, _string, 540)
end

local function isEffectShown()
    local scaleY = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,"effet_list_db"):getScaleY()
    return scaleY == 1
end

function LtExBufferMgr.getNewBuffEffect(block, callback)
    
end

function LtExBufferMgr.addNewBuff(buffid, index)
    index = index or #bufferTable + 1
    
    local _buffInfo = clone(LostTowerInfo.getExBuffInfoById(buffid))
    
    if not _buffInfo then return end

    local list   = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,"effect_listView")
    local sample = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,"effect_label_db")
    
    local effect_db = sample:clone()
    local label     = CSResourceMgr.seekNodeByName(effect_db,"label")
    local str = _buffInfo.name or ""
    local _string = CocosModuleMgr.createStringWithFormat({str, _buffInfo.value, _buffInfo.stepNumber})
    setEffectLabel(label, _string, 540)
    
    list:insertCustomItem(effect_db, index - 1)   -- list中index以0开头
    
    bufferTable[index] = {node = effect_db, buffInfo = _buffInfo}
    CSResourceMgr.setLabelString(LostTowerUIMgr.topResName_l,{"effect_info_button","effect_n"},#bufferTable)
    
    if not isEffectShown() then CSResourceMgr.callButtonFunc(LostTowerUIMgr.topResName_l, "effect_info_button") end
end

function LtExBufferMgr.removeBuff(index)
    if index > #bufferTable then return end
    
    local list = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,"effect_listView")
    list:removeItem(index - 1)
    table.remove(bufferTable,index)
    CSResourceMgr.setLabelString(LostTowerUIMgr.topResName_l,{"effect_info_button","effect_n"},#bufferTable)
end

function LtExBufferMgr.clearBuffList()
    local list = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,"effect_listView")
    list:removeAllItems()
    bufferTable = {}
    CSResourceMgr.setLabelString(LostTowerUIMgr.topResName_l,{"effect_info_button","effect_n"},#bufferTable)
end

function LtExBufferMgr.initBuffList()
    local list   = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,"effect_listView")
    local sample = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,"effect_label_db")
    
    for i = 1, #bufferTable do
        local info = bufferTable[i].buffInfo

        local effect_db = sample:clone()
        local label     = CSResourceMgr.seekNodeByName(effect_db,"label")
        local str = info.name or ""
        local _string = CocosModuleMgr.createStringWithFormat({str, info.value, info.stepNumber})
        setEffectLabel(label, _string, 540)
        
        bufferTable[i].node = effect_db
        list:insertCustomItem(effect_db, i - 1)   -- list中index以0开头
    end

    CSResourceMgr.setLabelString(LostTowerUIMgr.topResName_l,{"effect_info_button","effect_n"},#bufferTable)
end

function LtExBufferMgr.updateBuffList()
    if not CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,"effect_listView") then return end

    local list = CSResourceMgr.getNodeByName(LostTowerUIMgr.topResName_l,"effect_listView")
    local newTable = {}
    
    for i = 1, #bufferTable do
        bufferTable[i].buffInfo["stepNumber"] = bufferTable[i].buffInfo["stepNumber"] - 1
        if bufferTable[i].buffInfo["stepNumber"] <= 0 then
            list:removeItem(i - 1)
        else
            table.insert(newTable, bufferTable[i])
        end
    end
    bufferTable = newTable
    
    for index = 1, #newTable do
        LtExBufferMgr.updateBuff(index)
    end

    CSResourceMgr.setLabelString(LostTowerUIMgr.topResName_l,{"effect_info_button","effect_n"},#bufferTable)
end

return LtExBufferMgr