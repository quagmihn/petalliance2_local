local MailMgr = {}

--list类型为：上拉可更新列表，下拉可加载更多

MailMgr.DEFAULT_MAILCONTENT_OUTLENGTH = 48
MailMgr.DEFAULT_SHOWMAIL_SIZE = 10
MailMgr.DEFAULT_LIST_DRAG_SENSOR = 1

local MailTable = {}
local PersonalMailCount = 0
local SystemMailToken = ""
local hasNewMail = false

local resName = ""
local infoResName = ""
local resNameBG = ""
local mailListObj = nil
local ListNodes = {}
local selMailIDs = {}
local checkButtonFunc = nil
local getAwardsFunc = nil

function MailMgr.Init()
    resName = "Item/Mail/MailMainLayer.csb"
    infoResName = "Item/Mail/MailInfoLayer.csb"
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    mailListObj = nil
    ListNodes = {}
    selMailIDs = {}
    checkButtonFunc = nil
    getAwardsFunc = nil
    
    MailTable = {}
    PersonalMailCount = 0
    SystemMailToken = ""
    hasNewMail = false
end

--_id,content,deadTime,dstID,gCash,items,mCash,sendTime,senderName,title
function MailMgr.update(jsStr)
    --print(jsStr)
    local cjson = require("cjson")
    local j = cjson.decode(jsStr)
    if not j then
        print("Mail json string may too long. Decode failed.")
    	return
    end
    --for key, var in pairs(j) do
    for k=0, MailMgr.DEFAULT_SHOWMAIL_SIZE-1 do
        local var = j[k..""]
        if not var then
        	break
        end
        if type(var._id)=="table" then
        	var._id = var._id["$date"]
        end
        if type(var.deadTime)=="table" then
            var.deadTime = var.deadTime["$numberLong"]
        end
        local flag = true
        if #MailTable>0 then
            if MailTable[#MailTable].id==var._id then
                print("This mail is repeated for check.")
                flag = false
            end
        end
        if flag then
            local remainTime = var.deadTime - CharInfo.getServerTime()
            local days = math.floor(remainTime/86400)
            local hours = math.floor(remainTime%86400/3600)
            local minutes = math.floor((remainTime%86400-3600*hours)/60)
            --print(days, hours, minutes)
            local date = ""
            if days>0 then
                date = days.."D "..hours.."H"
            elseif days==0 then
                date = hours.."H "..minutes.."M"
            end
            local itemVec = {}
            if var.gCash>0 then
                table.insert(itemVec, {9998, var.gCash, 3})
            end
            if var.mCash>0 then
                table.insert(itemVec, {9999, var.mCash, 3})
            end
            local itemStr = lua_string_split(var.items, "% ")
            for var=1, math.floor(#itemStr/3) do
                --print("---------", itemStr[3*var-1], itemStr[3*var])
                local itemID = tonumber(itemStr[3*var-1])
                local itemNum = tonumber(itemStr[3*var])
                local itemType = tonumber(itemStr[3*var-2])
                if itemID and itemType then
                    if itemType==3 then
                        table.insert(itemVec, {itemID, itemNum})
                    elseif itemType==5 then
                        local nVec = lua_string_split(itemStr[3*var], "_")
                        local skin = nVec[2] or 0
                        table.insert(itemVec, {"pet", itemID, skin})
                    else
                        table.insert(itemVec, {ItemInfo.AWARD[itemType], itemNum})
                    end
                end
            end
            local status = 1
            if var.isFetch==true then
                status = 0
            end
            local readStatus = 1
            if var.isRead==true then
                readStatus = 0
            end
            local outDate = false
            if remainTime<=0 then
            	outDate = true
                status = 0
                date = "mail18"
            end
            local contentData = nil
            local ret, errMessage = pcall(function()
                contentData = cjson.decode(var.content)
            end)
            if not contentData then
                contentData = var.content
            end
            if var.isDel~=true then
                table.insert(MailTable, {
                    id      = var._id,
                    content = contentData,
                    time    = var.sendTime,
                    date    = date,
                    name    = var.senderName,
                    info    = var.title,
                    item    = itemVec,
                    gender  = var.gender or 1,
                    status  = status,
                    read    = readStatus,
                    type    = var.type,
                    outdate = outDate,
                })
                if var.type==0 then
                    PersonalMailCount = PersonalMailCount+1
                else
                    SystemMailToken = var._id
                end
            end
            print(var._id,var.content,var.deadTime,var.dstID,var.gCash,var.items,var.mCash,var.senderName,var.title)
        end
    end
end

---加载邮件主面板
function MailMgr.show(scene)
    if CSResourceMgr.getCsbObj(resNameBG, "MailMgr") then
    	return
    end
    UIStack.push("MailMgr", MailMgr.hide, true)
    function checkButtonFunc()
        local boolOpen = true
        if #selMailIDs==0 then
            boolOpen = false
        end
        CSResourceMgr.setButtonEnabled(resName, "delete", boolOpen)
        CSResourceMgr.setButtonEnabled(resName, "clain", boolOpen)
    end
    function getAwardsFunc(mailID)
        local parent = ListNodes[mailID].node
        local gift = CSResourceMgr.seekNodeByName(parent, "gift")
        local date = CSResourceMgr.seekNodeByName(parent, "date")
        local datedb = CSResourceMgr.seekNodeByName(parent, "datedb")
        CSResourceMgr.setButtonEnabledByNode(gift, false)
        date:setVisible(false)
        datedb:setVisible(false)
        MailTable[ListNodes[mailID].index].status = 0
    end
    local function checkMailAwards()
        local mailIndexVec = {}
        for var=1, #selMailIDs do
            if MailTable[selMailIDs[var]].status==1 then
                if #MailTable[selMailIDs[var]].item>0 then
                    table.insert(mailIndexVec, selMailIDs[var])
                end
            end
    	end
        return mailIndexVec
    end
    
    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG, "MailMgr")
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "MailMgr")
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    end
    
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        curLayer:setVisible(false)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        
        local diff = CocosModuleMgr.getScreenSizeDiff()
        local frame = CSResourceMgr.getNodeByName(resName, "frame")
        local fsize = frame:getContentSize()
        frame:setContentSize(fsize.width, fsize.height+diff)
        local db = CSResourceMgr.getNodeByName(resName, "db")
        local dsize = db:getContentSize()
        db:setContentSize(dsize.width, dsize.height+diff)
        local diban = CSResourceMgr.getNodeByName(resName, "diban")
        local dbsize = diban:getContentSize()
        diban:setContentSize(dbsize.width, dbsize.height+diff)
        local title = CSResourceMgr.getNodeByName(resName, "title")
        local tposy = title:getPositionY()
        title:setPositionY(tposy+diff)
        local close = CSResourceMgr.getNodeByName(resName, "close")
        local cposy = close:getPositionY()
        close:setPositionY(cposy+diff)
        local list = CSResourceMgr.getNodeByName(resName, "list")
        local lsize = list:getContentSize()
        list:setContentSize(lsize.width, lsize.height+diff)

        CSResourceMgr.setLabelColor(resName, "title", {r=166,g=243,b=255,a=255})
        CSResourceMgr.setLabelString(resName, "title", "mail1", "", {r=37,g=54,b=75,a=255})
        CSResourceMgr.clickEventBinding(resName, "close", function()
            MailMgr.hide()
        end)
        CSResourceMgr.setLabelColor(resName, "deletetlt", {r=227,g=233,b=255,a=255})
        CSResourceMgr.setLabelString(resName, "deletetlt", "mail3", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS, nil, 160)
        CSResourceMgr.clickEventBinding(resName, "delete", function()
            if #selMailIDs==0 then
        		return
        	end
            local function delAll()
                local function delMail()
                    if #selMailIDs==0 then
                        checkButtonFunc()
                        local boolNeedRefresh = true
                        for key, var in pairs(ListNodes) do
                        	if var then
                                boolNeedRefresh = false
                        		break
                        	end
                        end
                        if boolNeedRefresh then
                            MailMgr.refresh(function()
                                mailListObj.refreshFinished()
                            end)
                        end
                        return
                    end
                    local mailID = MailTable[selMailIDs[1]].id
                    local mailType = MailTable[selMailIDs[1]].type
                    NetInterface.sendWithBlock("GC_DelMail_Ack", function()
                        local MailSend = require("src.Net.Send.MailSend")
                        MailSend.sendCG_DelMail_Req(mailID, mailType)
                    end, function()
                        if mailType==0 then
                            PersonalMailCount = PersonalMailCount-1
                        end
                        table.remove(selMailIDs, 1)
                        if ListNodes[mailID] then
                            local parent = ListNodes[mailID].node
                            parent:removeFromParent(true)
                            ListNodes[mailID] = nil
                            delMail()
                        end
                    end, function(code)
                        TipsMgr.showError(nil, code)
                    end)
                end
                delMail()
            end
            if #checkMailAwards()>0 then
                DialogBoxMgr.showSmallDialogBox(scene, 2, "mail6", function()
                    delAll()
                end)
            else
                delAll()
            end
        end)
        CSResourceMgr.setLabelColor(resName, "claintlt", {r=227,g=233,b=255,a=255})
        CSResourceMgr.setLabelString(resName, "claintlt", "mail4", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS, nil, 160)
        CSResourceMgr.clickEventBinding(resName, "clain", function()
            if #selMailIDs==0 then
                return
            end
            local mailIndexVec = checkMailAwards()
            if #mailIndexVec==0 then
                StandardTipsMgr.show(1, "idling19")
            	return
            end
            local i = 1
            local awardsVec = {}
            local function getMail()
                if i>#mailIndexVec then
                    AwardsListMgr.show(SceneMgr.getRunningScene, awardsVec)
                	return
                end
                local mailID = MailTable[mailIndexVec[i]].id
                local mailType = MailTable[mailIndexVec[i]].type
                NetInterface.sendWithBlock("GC_GetMailAttach_Ack", function()
                    local MailSend = require("src.Net.Send.MailSend")
                    print("收取邮件", mailID, mailType)
                    MailSend.sendCG_GetMailAttach_Req(mailID, mailType)
                end, function()
                    for n=1, #MailTable[mailIndexVec[i]].item do
                        table.insert(awardsVec, MailTable[mailIndexVec[i]].item[n])
                    end
                    getAwardsFunc(mailID)
                    i = i+1
                    getMail()
                end, function(code)
                    AwardsListMgr.show(SceneMgr.getRunningScene, awardsVec)
                    MailMgr.showError(code)
                end)
            end
            getMail()
        end)
        CSResourceMgr.getNodeByName(resName, "selall"):setSelected(false)
        selMailIDs = {}
        checkButtonFunc()
        CSResourceMgr.getNodeByName(resName, "selall"):addEventListener(function()
            local isselected = CSResourceMgr.getNodeByName(resName, "selall"):isSelected()
            for key, var in pairs(ListNodes) do
                local select = CSResourceMgr.seekNodeByName(var.node, "select")
                if isselected then
                    select:setSelected(true)
                    table.insert(selMailIDs, var.index)
                else
                    selMailIDs = {}
                    select:setSelected(false)
                end
            end
            checkButtonFunc()
        end)
        CSResourceMgr.clickEventBinding(resName,"top", function()
            CSResourceMgr.getNodeByName(resName, "list"):scrollToTop(0.2, true)
        end)
    end
    
    local function loadItem()
        mailListObj = CSResourceMgr.setCommonListInfo(MailTable, resName, "list", nil, nil, nil, function(i, var)
            local parent = CSResourceMgr.getNodeByName(resName, "example"):clone()
            ListNodes[var.id] = {node=parent, index=i}
            local date = CSResourceMgr.seekNodeByName(parent, "date")
            CSResourceMgr.setLabelStringByNode(date, var.date)
            date:enableOutline({r=0,g=0,b=0,a=255}, 1)
            date:setLocalZOrder(2)
            local name = CSResourceMgr.seekNodeByName(parent, "name")
            CSResourceMgr.setLabelStringByNode(name, CocosModuleMgr.createStringWithFormat({"mail2", var.name or ""}))
            local info = CSResourceMgr.seekNodeByName(parent, "info")
            CSResourceMgr.setLabelStringByNode(info, var.info)
            info:enableOutline({r=0,g=0,b=0,a=255}, 1)
            info:setLocalZOrder(1)
            local select = CSResourceMgr.seekNodeByName(parent, "select")
            select:setLocalZOrder(1)
            select:addEventListener(function()
                local isselected = select:isSelected()
                if isselected then
                    table.insert(selMailIDs, i)
                else
                    for k, v in pairs(selMailIDs) do
                    	if v==i then
                            table.remove(selMailIDs, k)
                    		break
                    	end
                    end
                end
                checkButtonFunc()
            end)
            select:setSelected(false)
            local framet = CSResourceMgr.seekNodeByName(parent, "framet")
            framet:setColor({r=128,g=161,b=172,a=255})
            local infodb = CSResourceMgr.seekNodeByName(parent, "infodb")
            if var.read==1 then
                infodb:setColor({r=124,g=184,b=202,a=255})
            else
                infodb:setColor({r=171,g=171,b=171,a=255})
            end
            local datedb = CSResourceMgr.seekNodeByName(parent, "datedb")
            datedb:setColor({r=75,g=86,b=78,a=255})
            local icon = CSResourceMgr.seekNodeByName(parent, "icon")
            icon:setLocalZOrder(2)
            icon:setScale(0.8)
            CSResourceMgr.setSpriteTextureByNode(icon, CharInfo.getHeadIcon({1057}))
            local gift = CSResourceMgr.seekNodeByName(parent, "gift")
            if #var.item>0 then
                CSResourceMgr.clickEventBindingByNode(gift, function()
                    NetInterface.sendWithBlock("GC_GetMailAttach_Ack", function()
                        local MailSend = require("src.Net.Send.MailSend")
                        print("收取邮件", var.id, var.type)
                        MailSend.sendCG_GetMailAttach_Req(var.id, var.type)
                    end, function()
                        getAwardsFunc(var.id)
                        AwardsListMgr.show(SceneMgr.getRunningScene, var.item)
                    end, function(code)
                        MailMgr.showError(code)
                    end)
                end, 3)
                if var.status==0 then
                    getAwardsFunc(var.id)
                end
            else
                gift:setVisible(false)
                date:setVisible(false)
                datedb:setVisible(false)
            end
            CSResourceMgr.clickEventBindingByNode(parent, function()
                NetInterface.sendWithBlock("GC_GetMail_Ack", function()
                	local MailSend = require("src.Net.Send.MailSend")
                	MailSend.sendCG_GetMail_Req(var.id, var.type)
                end, function()
                    infodb:setColor({r=171,g=171,b=171,a=255})
                    MailMgr.showMailInfo(i)
                end, function(code)
                	TipsMgr.showError(scene, code)
                end)
            end)
            if var.outdate then
                CSResourceMgr.clickEventBindingByNode(parent, function()
                    MailMgr.showMailInfo(i)
                end)
                parent:setColor({r=171,g=171,b=171})
                date:setVisible(true)
                CSResourceMgr.setLabelColorByNode(date, {r=255,g=0,b=0,a=255})
            end
            
            parent:setVisible(true)
            CSResourceMgr.getNodeByName(resName, "list"):pushBackCustomItem(parent)
            parent:setScaleY(0)
            transition.scaleTo(parent, {scaleY = 1, time = 0.1})
            return parent
        end, function(callback)
            MailMgr.refresh(callback)
        end, function(callback)
            NetInterface.send("GC_GetSomeMails_Ack", function()
                local MailSend = require("src.Net.Send.MailSend")
                MailSend.sendCG_GetSomeMails_Req(SystemMailToken, PersonalMailCount)
            end, function()
                callback()
            end, function(code)
                TipsMgr.showError(nil, code)
            end)
        end)
    end
    
    local function playCSB()
        CSResourceMgr.getCsbObj(resName):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resName), "up", function()
        	--loadItem()
        end)
        loadItem()
    end

    local funcTable = {loadBG, loadCSB, playCSB}

    UnblockLoader.load(funcTable, "MailMgr")
end

function MailMgr.refresh(callback)
    OvertimeListener.cancel(string.upper("GC_GetSomeMails_Ack"), true)
    NetInterface.send("GC_GetSomeMails_Ack", function()
        local node = CSResourceMgr.getNodeByName(resName, "selall")
        if not node then
        	return
        end
        node:setSelected(false)
        for var=1, #MailTable do
            table.remove(MailTable, 1)
        end
        PersonalMailCount = 0
        SystemMailToken = ""
        ListNodes = {}
        selMailIDs = {}
        checkButtonFunc()
        local MailSend = require("src.Net.Send.MailSend")
        MailSend.sendCG_GetSomeMails_Req(SystemMailToken, PersonalMailCount)
    end, function()
        if #MailTable==0 then
            TipsMgr.show(nil, "mail5")
        end
        --mailListObj.setContent(MailTable)
        if callback then
            callback()
        end
    end, function(code)
        TipsMgr.showError(nil, code)
    end)
end

---关闭邮件主面板
function MailMgr.hide()
    if not CSResourceMgr.getCsbObj(resName) then
    	return
    end
    ListNodes = {}
    UnblockLoader.cancel("MailMgr")
    UnblockLoader.cancel("CommonList-LoadItem"..resName.."list")
    UnblockLoader.cancel("MailMgr-ShowMailInfo")
    CSResourceMgr.removeList(resName, "list")
    CSResourceMgr.removeCSObjectByTag(resName)
    CSResourceMgr.removeCSObjectByTag(resNameBG, "MailMgr")
    GameAudio.playUISound("retract")
    UIStack.pop("MailMgr")
    
    NetInterface.sendWithBlock("GC_CheckUnReadMail_Ack",function()
        local MailSend = require("src.Net.Send.MailSend")
        MailSend.sendCG_CheckUnReadMail_Req()
    end)
end

---显示邮件内容（不需要外部调用）
--@param id int 邮件id，即MailTable的数组下标
function MailMgr.showMailInfo(id)
    UIStack.push("MailInfo", MailMgr.hideMailInfo, false)
    local function loadCSB()
        local MailInfo = CSResourceMgr.createRes(SceneMgr.getRunningScene, infoResName)
        MailInfo:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(infoResName, 320, 480)
        CSResourceMgr.getNodeByName(infoResName, "db"):setVisible(false)
        
        CSResourceMgr.setLabelString(infoResName, "title", MailTable[id].info, "", {r=37,g=54,b=75,a=255}, nil, 600)
        CSResourceMgr.setLabelColor(infoResName, "title", {r=166,g=243,b=255,a=255})
        local contentStr = ""
        if type(MailTable[id].content)=="table" then
            if MailTable[id].content[1]=="mail23" then
                local itemName = ItemInfo.getItemInfoById(MailTable[id].content[2]).name
                contentStr = CocosModuleMgr.createStringWithFormat({"mail23", itemName})
            else
                contentStr = CocosModuleMgr.createStringWithFormat(MailTable[id].content)
            end            
        elseif type(MailTable[id].content)=="string" then
            contentStr = MailTable[id].content
        end
        if CocosModuleMgr.checkIsRichLabelString(contentStr) then
            local infoLabel = CSResourceMgr.getNodeByName(infoResName, "info")
            infoLabel.boolRich = true
            local richtext = CocosModuleMgr.createRichLabel(infoLabel, contentStr, infoLabel:getFontSize(), "cuyuan_GBK.ttf", 390, 0, 0)
            richtext:setPosition(-richtext.realWidth/2, richtext.realHeight)
            infoLabel:setString(" ")
            infoLabel:setTextAreaSize({width = 0, height = richtext.realHeight})
            infoLabel:ignoreContentAdaptWithSize(false)
        else
            CSResourceMgr.setLabelString(infoResName, "info", contentStr, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS, -1)
            CSResourceMgr.setLabelMaxWidth(infoResName, "info", 400, "", -1)
            CSResourceMgr.setLabelColor(infoResName, "info", {r=218,g=226,b=255,a=255})
        end        
        
        CSResourceMgr.setLabelString(infoResName, "closetlt", "tips3", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS, nil, 140)
        local timeStr = lua_string_split(MailTable[id].id, "%.")[1] or ""
        timeStr = string.gsub(timeStr, "T", " ")
        CSResourceMgr.setLabelString(infoResName, "sendtime", timeStr, "", {r=0,g=0,b=0,a=255,s=1,w=1}, nil, 400)
        
        CSResourceMgr.clickEventBinding(infoResName, "bg", function()
            MailMgr.hideMailInfo()
        end)
        CSResourceMgr.clickEventBinding(infoResName, "close", function()
            if #MailTable[id].item==0 or MailTable[id].status==0 then
                MailMgr.hideMailInfo()
            	return
            end
            NetInterface.sendWithBlock("GC_GetMailAttach_Ack", function()
                local MailSend = require("src.Net.Send.MailSend")
                print("收取邮件", MailTable[id].id, MailTable[id].type)
                MailSend.sendCG_GetMailAttach_Req(MailTable[id].id, MailTable[id].type)
            end, function()
                getAwardsFunc(MailTable[id].id)
                AwardsListMgr.show(SceneMgr.getRunningScene, MailTable[id].item)
                MailMgr.hideMailInfo()
            end, function(code)
                MailMgr.showError(code)
            end)
        end)
    end

    local function playCSB()
        local label = CSResourceMgr.getNodeByName(infoResName, "info")
        if not label.boolRich then
            CocosModuleMgr.sharpenLabel(label, 1)
        end        
        CSResourceMgr.getNodeByName(infoResName, "db"):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(infoResName, "db"), "up")
        local function showItem()
            local iteminfoFunc = {}
            for key, var in ipairs(MailTable[id].item) do
                local function addGift()
                    local itemId = var[1]
                    local itemNum = var[2]
                    local parent = nil
                    local itemInfo = {}
                    local icon = nil
                    if itemId=="pet" then
                        itemInfo = PokemonInfo.getPokemonInfoByID(itemNum)
                        parent = CSResourceMgr.getNodeByName(infoResName, "examplep"):clone()
                        icon = CSResourceMgr.seekNodeByName(parent, "icon")
                        CSResourceMgr.setSpriteTextureByNode(icon, PokemonInfo.getPokemonIconByID(itemNum))
                        local icdb = CSResourceMgr.seekNodeByName(parent, "icdb")
                        local rareRes = PokemonInfo.getStagePics(nil, itemInfo.elementAtt1, itemInfo.rarePoint)
                        CSResourceMgr.setButtonTextureByNode(icdb, rareRes.p1, rareRes.p1, rareRes.p1)
                        CSResourceMgr.clickEventBindingByNode(icdb, function()
                            print("No showing pet.")
                        end, 3)
                    else
                        itemInfo = ItemInfo.getItemInfoById(itemId)
                        parent = CSResourceMgr.getNodeByName(infoResName, "example"):clone()
                        local ibtn = ItemInfo.getItemIconById(itemId, itemNum)
                        ibtn:addTo(CSResourceMgr.seekNodeByName(parent, "icdb"))
                        ibtn:pos(0, 0)
                        ibtn:scale(0.65)
                        CSResourceMgr.clickEventBindingByNode(ibtn, function()
                            ItemInfoViewMgr.show({id = itemId, sum = itemNum}, false)
                        end, 3)
                        icon = CSResourceMgr.seekNodeByName(ibtn, "s")
                    end
                    local iname = CSResourceMgr.seekNodeByName(parent, "iname")
                    CSResourceMgr.setLabelColorByNode(iname, {r=95,g=215,b=255,a=255})
                    CSResourceMgr.setLabelStringByNode(iname, itemInfo.name, 
                        CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS, nil, 100)
                    iname:setLocalZOrder(1)
                    if MailTable[id].status==0 then
                        icon:setColor({r=77,g=77,b=77})
                    end
                    parent:setVisible(true)
                    parent:setScale(0, 0)
                    transition.scaleTo(parent, {scale = 1, time = 0.1})
                    CSResourceMgr.getNodeByName(infoResName, "giftlist"):pushBackCustomItem(parent)
                end
                table.insert(iteminfoFunc, addGift)
            end
            UnblockLoader.load(iteminfoFunc, "MailMgr-ShowMailInfoItem")
        end
        showItem()
    end
    
    local funcTable = {loadCSB, playCSB}
    UnblockLoader.load(funcTable, "MailMgr-ShowMailInfo")
end

---关闭邮件内容（不需要外部调用）
function MailMgr.hideMailInfo()
    if not CSResourceMgr.getCsbObj(infoResName) then
        return
    end
    UnblockLoader.cancel("MailMgr-ShowMailInfo")
    UnblockLoader.cancel("MailMgr-ShowMailInfoItem")
    CSResourceMgr.getNodeByName(infoResName, "giftlist"):removeAllItems()
    CSResourceMgr.removeCSObjectByTag(infoResName)
    UIStack.pop("MailInfo")
end

function MailMgr.showError(code)
	if code==422 then
	   StandardTipsMgr.show(1, "mail20")
	elseif code==123 then
        StandardTipsMgr.show(1, "mail19")
	else
	   TipsMgr.showError(nil, code)
	end
end

function MailMgr.newMailNotify(boolShowTips)
    if boolShowTips==nil then
    	boolShowTips = true
    end
    if boolShowTips then
        TipsMgr.show(nil, "mail7")
        GameAudio.playUISound("signin")
    end
    MailMgr.setHasNewMail(true)
end

function MailMgr.getHasNewMail()
    return hasNewMail
end

function MailMgr.setHasNewMail(val)
    hasNewMail = val
    local mailNode = CSResourceMgr.getNodeByName("Map/TownMap/town_01.csb", "b1")
    if val then
        if not CSResourceMgr.getCsbObj(resName) then            
            if mailNode then
                CocosModuleMgr.showShiningToNode(mailNode, 4)
            end
        end
        StatusBarMgr.addRedPoint(10)
    else
        if mailNode then
            CocosModuleMgr.hideShiningToNode(mailNode)
        end
        StatusBarMgr.hideRedPoint(10)
    end
end

return MailMgr