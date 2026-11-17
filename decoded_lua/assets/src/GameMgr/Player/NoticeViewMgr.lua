local NoticeViewMgr = {}

local resName = ""
local resNameItem = ""
local itemNodes = {}
local bullListInfo = {}
local noticeInfo = {}
local protoIndex = 1

function NoticeViewMgr.Init()
    print("NoticeViewMgr Init")

    resName = "Player/Notice/NoticeView.csb"
    resNameItem = "Player/Notice/NoticeItem.csb"
    CSResourceMgr.createRes(nil, resNameItem, nil, true)
    itemNodes = {}
    bullListInfo = {}
    noticeInfo = {}
    protoIndex = 1
end

function NoticeViewMgr.hide(callback)
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    itemNodes = {}
    bullListInfo = {}
    noticeInfo = {}
    protoIndex = 1
    CSResourceMgr.removeCSObjectByTag(resNameItem)
	CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("NoticeViewMgr")
    if callback then
        callback()
    end
end

function NoticeViewMgr.setBullListInfo(vec)
    bullListInfo = vec
end

function NoticeViewMgr.setNoticeInfo(info)
    table.insert(noticeInfo,info)
end

function NoticeViewMgr.show(scene)
    if GameGuideMgr.checkIsGuiding() then
        return
    end
    if not NetInterface.isConnect then
        return
    end
    local function sendProto(id)
        NetInterface.sendWithBlock("GC_GetBulletin_Ack", function()
            local BulletinSend = require("src.Net.Send.BulletinSend")
            BulletinSend.sendCG_GetBulletin_Req(id)
        end, function()
            if bullListInfo[protoIndex+1] then
                protoIndex = protoIndex+1
                sendProto(bullListInfo[protoIndex].id)
            else
                UIStack.push("NoticeViewMgr", NoticeViewMgr.hide, false)
                NoticeViewMgr.open(scene)
            end
        end, function(code)
            TipsMgr.showError(scene, code)
        end)
    end
    NetInterface.sendWithBlock("GC_ListBulletin_Ack", function()
        local BulletinSend = require("src.Net.Send.BulletinSend")
        BulletinSend.sendCG_ListBulletin_Req()
    end, function()
        if bullListInfo[protoIndex] then
            sendProto(bullListInfo[protoIndex].id)
        else
            return
        end
    end, function(code)
        TipsMgr.showError(scene, code)
    end)
end

function NoticeViewMgr.open(scene) 

    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName)

        CSResourceMgr.setLabelString(resName,"title","notice1","",{r=102,g=0,b=17,a=255})
        
        local startBtn = CSResourceMgr.getNodeByName(resName, "startBtn")
        CSResourceMgr.setButtonStringByNode(startBtn, "notice2", {r=0,g=0,b=0,a=255})
        CSResourceMgr.clickEventBindingByNode(startBtn, function()
            NoticeViewMgr.hide(function()
                CheckViewMgr.show(SceneMgr.getRunningScene)
            end)
        end)

        NoticeViewMgr.setNoticeItem()
    end
    
    local function playCSB()
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName,"db"),"down")
    end
    
    loadCSB() 
    playCSB()
end

function NoticeViewMgr.setNoticeItem()
    local activityPanel = CSResourceMgr.getNodeByName(resName, "activityPanel")
    local list = CSResourceMgr.getNodeByName(resName, "list")
    local list_info = CSResourceMgr.getNodeByName(resName, "list_info")
    list:removeAllItems()

    local function setactivityPanel(info)
        local activityItem = CSResourceMgr.getNodeByName(resName, "activityItem")
        CSResourceMgr.setSpriteTextureByNode(activityItem, info.picture, false)

        local str = string.gsub(info.content,"&quot;","\"")

        local infoDes = CSResourceMgr.getNodeByName(resName, "infoDes"):clone()
        list_info:pushBackCustomItem(infoDes)
        local richLabelL = CocosModuleMgr.createRichLabel(infoDes, str, 24, "cuyuan_GBK.ttf", 600,nil,nil,nil,true)
        infoDes:setString(" ")
        infoDes:setTextAreaSize({width = 0, height = richLabelL.realHeight})
        infoDes:ignoreContentAdaptWithSize(false)

        infoDes:setVisible(false)
        local diff = itemNodes[info.id]:getPositionY()-210
        if diff > 210 then
            diff = 210
        end

        local timeN = 0.3*((210-diff)/210)
        activityItem:setPositionY(diff)
        transition.moveTo(activityItem, {x=0, y=210, time=timeN})

        infoDes:performWithDelay(function()
            infoDes:setVisible(true)
        end,timeN)

        local closeBtn = CSResourceMgr.getNodeByName(resName, "closeBtn")
        CSResourceMgr.clickEventBindingByNode(closeBtn, function()
            list_info:removeAllItems()
            activityPanel:setVisible(false)
            list:setVisible(true)
        end)
    end 

    for k,v in pairs(noticeInfo) do
        itemNodes[v.id] = CSResourceMgr.getNodeByName(resNameItem, "db"):clone()
        list:pushBackCustomItem(itemNodes[v.id])

        CSResourceMgr.setSpriteTextureByNode(itemNodes[v.id], v.picture, false)

        local infoBtn = CSResourceMgr.seekNodeByName(itemNodes[v.id], "infoBtn")
        CSResourceMgr.clickEventBindingByNode(infoBtn, function()
            setactivityPanel(v)
            activityPanel:setVisible(true)
            list:setVisible(false)
        end)
    end
end

return NoticeViewMgr