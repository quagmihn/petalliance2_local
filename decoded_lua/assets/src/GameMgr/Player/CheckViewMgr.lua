local CheckViewMgr = {}
CheckViewMgr.ROW = 4

local resName = ""
local resNameItem = ""
local resNameEfx = ""
local imageRes1 = ""
local imageRes2 = ""
local itemNodes = {}
local signinTabel = {}
local keystr = "CheckView" --objectpool的类型
local isObjectcachesLoaded = false
local idxTable = {}
local repairTimes = 0
local scheduler = require("src.framework.scheduler")

function CheckViewMgr.Init()
    print("CheckViewMgr初始化")

    resName = "Player/Check/CheckView.csb"
    resNameItem = "Player/Check/CommonItem.csb"
    resNameEfx = "Player/Check/AwardEfxView.csb"
    imageRes1 = "UI/CommonFiles/ranking_substrate_copper_su.png"
    imageRes2 = "UI/CommonFiles/ranking_substrate_normal_su.png"
    itemNodes = {}
    signinTabel = {}
    idxTable[31] = 1
    idxTable[30] = 2
    idxTable[29] = 3
    idxTable[28] = 4
    repairTimes = 0

    local function initobjectcache()
        local count = 15
        local csb = CSResourceMgr.createRes(nil, resNameItem)
        if not csb then
            print("[CheckViewMgr] missing CSB:", resNameItem)
            return false
        end
        local item = CSResourceMgr.getNodeByName(resNameItem, "diban")
        if not item then
            print("[CheckViewMgr] missing item node diban:", resNameItem)
            return false
        end
        local listcell = item:clone()
        ObjectPool.add(keystr,listcell) 
        local function loadListCell()
            local cell = listcell:clone()
            ObjectPool.add(keystr,cell)  
            print("ObjectPool add "..keystr) 
        end

        local funcTable = {}

        for i=1,count do
            table.insert(funcTable,loadListCell)
        end    


        UnblockLoader.load(funcTable, UnblockLoader.BACKGROUND_LOADER_TAG)
        return true
    end
    if isObjectcachesLoaded==false then
        isObjectcachesLoaded = initobjectcache() == true
    end
end

function CheckViewMgr.hide()
    if not CSResourceMgr.getCsbObj(resName) then
    	return
    end
    UnblockLoader.cancel("CheckViewMgr")
    -- UnblockLoader.cancel("CheckViewMgr.setCheckItem")
    itemNodes = {}
    -- signinTabel = {}
    local list = CSResourceMgr.getNodeByName(resName, "list")
    list:removeAllItems()
    CSResourceMgr.removeCSObjectByTag(resNameEfx)
	CSResourceMgr.removeCSObjectByTag(resName)
    ObjectPool.reset(keystr)
    GameAudio.playUISound("retract")
    UIStack.pop("CheckViewMgr")
end

function CheckViewMgr.setSigninTabel(vec)
    signinTabel = vec

    if signinTabel then
        if signinTabel.repairTimes then
            repairTimes = signinTabel.repairTimes
        end
        if next(signinTabel) == nil then
            signinTabel.days = {}
            signinTabel.monthDay = 0
        else
            if signinTabel.monthDay then
                signinTabel.monthDay = tonumber(signinTabel.monthDay)%100
            else
                signinTabel.monthDay = 0
            end
        end
    end
end

function CheckViewMgr.show(scene)
    local curTime = CheckViewMgr.getCurTime()
    if signinTabel then
        if signinTabel.days then
            for k,v in pairs(signinTabel.days) do
                if v == curTime.day then
--                    return
                end
            end
        else
            CheckViewMgr.open(scene)
        end
    end
    CheckViewMgr.open(scene)
    -- if not NetInterface.isConnect then
    --     return
    -- end
    -- NetInterface.sendWithBlock("GC_LoadSigninData_Ack", function()
    --     local SigninSend = require("src.Net.Send.SigninSend")
    --     SigninSend.sendCG_LoadSigninData_Req()
    -- end, function()
    --     UIStack.push("CheckViewMgr", CheckViewMgr.hide, false)
    --     CheckViewMgr.open(scene)
    -- end, function(code)
    --     TipsMgr.showError(scene, code)
    -- end)
end

function CheckViewMgr.open(scene) 

    UnblockLoader.cancel(UnblockLoader.BACKGROUND_LOADER_TAG)
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName)

        local TipsPage = CSResourceMgr.getNodeByName(resName, "TipsPage")

        local cover = CSResourceMgr.getNodeByName(resName, "cover")
        cover:setLocalZOrder(-10)

        CSResourceMgr.setLabelColor(resName,"title",{r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelString(resName,"title","notice3","",{r=194,g=144,b=71,a=255})

        CSResourceMgr.setLabelColor(resName,"title1",{r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelString(resName,"title1","train199","",{r=194,g=144,b=71,a=255})

        CSResourceMgr.setButtonStringColor(resName, "tipBtn", {r=255,g=255,b=255,a=255})
        CSResourceMgr.setButtonString(resName, "tipBtn", "notice4", "", {r=62,g=124,b=0,a=255})

        CSResourceMgr.setLabelColor(resName,"totalCount",{r=144,g=238,b=255,a=255})
        if signinTabel then
            CSResourceMgr.setLabelString(resName,"totalCount",CocosModuleMgr.createStringWithFormat({"notice5", #signinTabel.days}))
        else
            CSResourceMgr.setLabelString(resName,"totalCount",CocosModuleMgr.createStringWithFormat({"notice5", 0}))
        end

        CSResourceMgr.setLabelColor(resName,"tipInfo",{r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelString(resName,"tipInfo","signin1", "", {r=0,g=0,b=0,a=255})

        CSResourceMgr.clickEventBinding(resName, "tipBtn", function()
            GameAudio.playUISound("popup")
            TipsPage:setVisible(true)
        end)

        CSResourceMgr.clickEventBinding(resName, "closeTipBtn", function()
            GameAudio.playUISound("retract")
            TipsPage:setVisible(false)
        end)

        CSResourceMgr.clickEventBinding(resName, "closeBtn", function()
            CheckViewMgr.hide()
        end)
        
        CheckViewMgr.setCheckItem(CheckViewMgr.getCurTime())
    end
    
    local function playCSB()
    --[[
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName,"ts_dit2"),"down",function()
            CheckViewMgr.setCheckItem(CheckViewMgr.getCurTime())
           
         
        end)]]
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName,"ts_dit2"),"down")
    end
    
    --loadCSB()
    --playCSB()
    
    UnblockLoader.load({loadCSB, playCSB}, "CheckViewMgr")
end

function CheckViewMgr.setCheckItem(curTime)
    CSResourceMgr.createRes(CSResourceMgr.getCsbObj(resName), resNameItem):setPositionX(-1000)
    local list = CSResourceMgr.getNodeByName(resName, "list")
    list:removeAllItems()

    local funcTable = {}
    local vec = CharInfo.getSigninInfoAllId()
    local panelNodes = {}
    table.insert(funcTable, function()
        local totalLine = math.ceil(curTime.totalday / CheckViewMgr.ROW)
        local panel = CSResourceMgr.getNodeByName(resName, "panel")
        for i = 1, totalLine do
            panelNodes[i] = panel:clone()
            list:pushBackCustomItem(panelNodes[i])
        end
        -- list:performWithDelay(function()
        --     list:jumpToTop()
        -- end, 0.1)
    end)

    local index = 1
    local diffX = 135
    local startX = 62
    local checkCount = 0
    for k,v in pairs(vec) do
        table.insert(funcTable, function()
            if index <= curTime.totalday then
                --PerFormanceAnalyzer.Start("checkviewouter","showcheck"..k)
                local line = math.ceil(index / CheckViewMgr.ROW)
                local row = index % CheckViewMgr.ROW == 0 and CheckViewMgr.ROW or index % CheckViewMgr.ROW
                --PerFormanceAnalyzer.Start("showcheck"..k,"clone"..k)
                
                local returnObjectArray = ObjectPool.getObjectFromPool(keystr,1)
                itemNodes[index] = returnObjectArray[1]--CSResourceMgr.getNodeByName(resNameItem, "diban"):clone()
                --PerFormanceAnalyzer.End("clone"..k)
                itemNodes[index]:addTo(panelNodes[line])
                --itemNodes[index]:setPositionX(itemNodes[index]:getPositionX() + (row - 1) * diffX)
                itemNodes[index]:setPositionX(startX + (row - 1) * diffX)
                
                --PerFormanceAnalyzer.Start("showcheck"..k,"other"..k)
                local cover = CSResourceMgr.seekNodeByName(itemNodes[index], "cover")
                cover:setOpacity(130)
                cover:setColor({r=0,g=0,b=0,a=255})
                cover:setVisible(false)
        
                local sel = CSResourceMgr.seekNodeByName(itemNodes[index], "sel")
                sel:setVisible(false)
        
                local buqianBG = CSResourceMgr.seekNodeByName(itemNodes[index], "buqianBG")
                buqianBG:setVisible(false)

                local buqianLabel = CSResourceMgr.seekNodeByName(itemNodes[index], "buqianLabel")
                CSResourceMgr.setLabelStringByNode(buqianLabel,"notice9")

                local vipLabel = CSResourceMgr.seekNodeByName(itemNodes[index], "vipLabel")
                local vipBG = CSResourceMgr.seekNodeByName(itemNodes[index], "vipBG")
                if v.vipRate.rate == 1 then
                    vipBG:setVisible(false)
                    vipLabel:setVisible(false)
                else
                    CSResourceMgr.setLabelColorByNode(vipLabel, {r=255,g=255,b=255,a=255})
                    CSResourceMgr.setLabelStringByNode(vipLabel, CocosModuleMgr.createStringWithFormat({"notice6", v.vipRate.vipLevel}))
                end
        
                local count = CSResourceMgr.seekNodeByName(itemNodes[index], "count")
                CSResourceMgr.setLabelColorByNode(count, {r=255,g=255,b=255,a=255})
                CSResourceMgr.setLabelStringByNode(count, "X"..v.awards[idxTable[curTime.totalday]].num,{r=0,g=0,b=0,a=255})
        
                local dayLabel = CSResourceMgr.seekNodeByName(itemNodes[index], "dayLabel")
                CSResourceMgr.setLabelColorByNode(dayLabel, {r=255,g=255,b=255,a=255})
                CSResourceMgr.setLabelStringByNode(dayLabel, CocosModuleMgr.createStringWithFormat({"notice7", v.id}))
        
                local dayBG = CSResourceMgr.seekNodeByName(itemNodes[index], "dayBG")
                dayBG:setColor({r=104,g=139,b=151,a=255})
        
                local icon = CSResourceMgr.seekNodeByName(itemNodes[index], "icon")
                local mask = CSResourceMgr.seekNodeByName(itemNodes[index], "mask")
                local awardInfo = ItemInfo.getAwardElementInfoById(v.awards[idxTable[curTime.totalday]].type)
                local itemInfo = {}

                if awardInfo.elementType == 1 then
                    itemInfo = ItemInfo.getItemInfoById(9998)
                elseif awardInfo.elementType == 2 then
                    itemInfo = ItemInfo.getItemInfoById(9999)
                else
                    local awardType = ItemInfo.getItemType(awardInfo.elementID)
                    if awardType == 4 then
                        local petPieceInfo = ItemInfo.getPetPieceInfoById(awardInfo.elementID)
                        local pokemonInfo = PokemonInfo.getPokemonInfoByID(PokemonInfo.getGeneInfoByID(petPieceInfo.pokeID).petID)
                        itemInfo.icon =  "Pet/PetIcon/"..pokemonInfo.icon..".png"
                        icon:setScale(0.7)
                        mask:setVisible(true)
                    else
                        itemInfo = ItemInfo.getItemInfoById(awardInfo.elementID)
                    end
                end
                CSResourceMgr.setSpriteTextureByNode(icon, itemInfo.icon)
        
                
                if not signinTabel then
                    if v.id == 1 then
                        CSResourceMgr.setButtonTextureByNode(itemNodes[index],imageRes1,imageRes1,imageRes1)
                        dayBG:setColor({r=177,g=90,b=13,a=255})

                        CSResourceMgr.clickEventBindingByNode(itemNodes[index], function()
                            NetInterface.sendWithBlock("GC_Signin_Ack", function()
                                local SigninSend = require("src.Net.Send.SigninSend")
                                SigninSend.sendCG_Signin_Req()
                            end, function()
                                if CSResourceMgr.getCsbObj(resName) then
                                    GameAudio.playUISound("signin")
                                    StatusBarMgr.hideRedPoint(9)
                                    CheckViewMgr.createAwardEfx(v)
                                    sel:setVisible(true)
                                    cover:setVisible(true)
                                    dayBG:setColor({r=104,g=139,b=151,a=255})
                                    CSResourceMgr.setButtonTextureByNode(itemNodes[k],imageRes2,imageRes2,imageRes2)
                                    CheckViewMgr.setSignButton(itemNodes[k],1)

                                    signinTabel = {}
                                    signinTabel.days = {}
                                    signinTabel.monthDay = curTime.day
                                    table.insert(signinTabel.days,1)

                                    checkCount = checkCount + 1
                                    if signinTabel then
                                        CSResourceMgr.setLabelString(resName,"totalCount",CocosModuleMgr.createStringWithFormat({"notice5", #signinTabel.days}))
                                    else
                                        CSResourceMgr.setLabelString(resName,"totalCount",CocosModuleMgr.createStringWithFormat({"notice5", checkCount}))
                                    end
                                end
                            end, function(code)
                                TipsMgr.showError(nil, code)
                            end)
                        end,1)
                    elseif v.id > 1 then
                        CheckViewMgr.setSignButton(itemNodes[index],2)
                    end
                else
                    if v.id == curTime.day then
                        CSResourceMgr.setButtonTextureByNode(itemNodes[index],imageRes1,imageRes1,imageRes1)
                        dayBG:setColor({r=177,g=90,b=13,a=255})


                        CSResourceMgr.clickEventBindingByNode(itemNodes[index], function()
                            NetInterface.sendWithBlock("GC_Signin_Ack", function()
                                local SigninSend = require("src.Net.Send.SigninSend")
                                SigninSend.sendCG_Signin_Req()
                            end, function()
                                if CSResourceMgr.getCsbObj(resName) then
                                    GameAudio.playUISound("signin")
                                    StatusBarMgr.hideRedPoint(9)
                                    CheckViewMgr.createAwardEfx(v)
                                    sel:setVisible(true)
                                    cover:setVisible(true)
                                    dayBG:setColor({r=104,g=139,b=151,a=255})
                                    CSResourceMgr.setButtonTextureByNode(itemNodes[k],imageRes2,imageRes2,imageRes2)
                                    CheckViewMgr.setSignButton(itemNodes[k],1)

                                    table.insert(signinTabel.days,curTime.day)

                                    checkCount = checkCount + 1
                                    if signinTabel then
                                        CSResourceMgr.setLabelString(resName,"totalCount",CocosModuleMgr.createStringWithFormat({"notice5", #signinTabel.days}))
                                    else
                                        CSResourceMgr.setLabelString(resName,"totalCount",CocosModuleMgr.createStringWithFormat({"notice5", checkCount}))
                                    end
                                end
                            end, function(code)
                                TipsMgr.showError(nil, code)
                            end)
                        end,1)
                    elseif v.id < curTime.day then
                        cover:setVisible(true)
                        buqianBG:setVisible(true)
                        CSResourceMgr.clickEventBindingByNode(itemNodes[index], function()
                            local vipInfo = CharInfo.getVipInfoByID(CharInfo.getVIPLevel())
                            if vipInfo.repairTimes > repairTimes then
                                local SigninRepairCostInfo = CharInfo.getSigninRepairCostInfoById(repairTimes+1)
                                DialogBoxMgr.showSmallDialogBox(scene, 2, CocosModuleMgr.createStringWithFormat({"notice8", SigninRepairCostInfo.cost}), function()
                                    if SigninRepairCostInfo.cost>CharInfo.getMCash() then
                                        StandardTipsMgr.show(1, "tips14")
                                        return
                                    end
                                    NetInterface.sendWithBlock("GC_SigninRepair_Ack", function()
                                        local SigninSend = require("src.Net.Send.SigninSend")
                                        SigninSend.sendCG_SigninRepair_Req(v.id)
                                    end, function()
                                        if CSResourceMgr.getCsbObj(resName) then
                                            GameAudio.playUISound("signin")
                                            CheckViewMgr.createAwardEfx(v)
                                            buqianBG:setVisible(false)
                                            sel:setVisible(true)
                                            CheckViewMgr.setSignButton(itemNodes[k],1)
                                            repairTimes = repairTimes + 1
                                            checkCount = checkCount + 1
                                            if signinTabel then
                                                CSResourceMgr.setLabelString(resName,"totalCount",CocosModuleMgr.createStringWithFormat({"notice5", #signinTabel.days}))
                                            else
                                                CSResourceMgr.setLabelString(resName,"totalCount",CocosModuleMgr.createStringWithFormat({"notice5", checkCount}))
                                            end
                                        end
                                    end, function(code)
                                        TipsMgr.showError(scene, code)
                                    end)
                                end)
                            else
                                StandardTipsMgr.show(1, "signin4")
                            end
                        end,1)
                    elseif v.id > curTime.day then
                        CheckViewMgr.setSignButton(itemNodes[index],2)
                    end
                end

                if signinTabel then
                    for k1,v1 in pairs(signinTabel.days) do
                        CheckViewMgr.setSignButton(itemNodes[v1],1)
                        if v.id == v1 then
                            cover:setVisible(true)
                            sel:setVisible(true)
                            buqianBG:setVisible(false)
                            dayBG:setColor({r=104,g=139,b=151,a=255})
                            CSResourceMgr.setButtonTextureByNode(itemNodes[index],imageRes2,imageRes2,imageRes2)
                        end
                    end
                end

                itemNodes[index]:setScale(0)
                transition.scaleTo(itemNodes[index], {scale=1, time=0.2})

                index = index + 1
                --PerFormanceAnalyzer.End("other"..k)
                --PerFormanceAnalyzer.End("showcheck"..k)
            end
        end)
    end

    table.insert(funcTable, function()
        if curTime.day then
            if curTime.day > 16 then
                list:performWithDelay(function()
                    list:jumpToBottom()
                end, 0)
            end
        end
    end)

    --PerFormanceAnalyzer.Start("root","checkviewouter")
    
    for k,v in pairs(funcTable) do
        v()
    end
      
    --UnblockLoader.load(funcTable, "CheckViewMgr.setCheckItem",0.05)
    --PerFormanceAnalyzer.End("checkviewouter")
end

function CheckViewMgr.createAwardEfx(signInfo)
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    local curEfx = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameEfx)
    curEfx:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
    CSResourceMgr.setFullScreen(resNameEfx)
    CSResourceMgr.playActionWithCallback(resNameEfx, 0, 5, 1, nil)
    local hud = CSResourceMgr.getNodeByName(resNameEfx, "lightEfx")
    local ani = cc.RepeatForever:create(cc.RotateBy:create(1.5, 180))
    hud:runAction(ani)

    local number = 0
    local curTime = CheckViewMgr.getCurTime()
    local vipInfo = CharInfo.getVipInfoByID(CharInfo.getVIPLevel())
    if vipInfo.viplevel < signInfo.vipRate.vipLevel then
        number = signInfo.awards[idxTable[curTime.totalday]].num
    else
        number = signInfo.awards[idxTable[curTime.totalday]].num*signInfo.vipRate.rate
    end
    local count = CSResourceMgr.getNodeByName(resNameEfx, "count")
    CSResourceMgr.setLabelColorByNode(count, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(count, "X"..number,{r=0,g=0,b=0,a=255})

    local icon = CSResourceMgr.getNodeByName(resNameEfx, "icon")
    local mask = CSResourceMgr.getNodeByName(resNameEfx, "mask")
    local awardInfo = ItemInfo.getAwardElementInfoById(signInfo.awards[idxTable[curTime.totalday]].type)
    local itemInfo = {}
    if awardInfo.elementType == 1 then
        itemInfo = ItemInfo.getItemInfoById(9998)
    elseif awardInfo.elementType == 2 then
        itemInfo = ItemInfo.getItemInfoById(9999)
    else
        local awardType = ItemInfo.getItemType(awardInfo.elementID)
        if awardType == 4 then
            local petPieceInfo = ItemInfo.getPetPieceInfoById(awardInfo.elementID)
            local pokemonInfo = PokemonInfo.getPokemonInfoByID(PokemonInfo.getGeneInfoByID(petPieceInfo.pokeID).petID)
            itemInfo.icon =  "Pet/PetIcon/"..pokemonInfo.icon..".png"
            icon:setScale(0.7)
            mask:setVisible(true)
        else
            itemInfo = ItemInfo.getItemInfoById(awardInfo.elementID)
        end
    end
    CSResourceMgr.setSpriteTextureByNode(icon, itemInfo.icon)

    local cover = CSResourceMgr.getNodeByName(resNameEfx, "cover")
    CSResourceMgr.clickEventBindingByNode(cover, function()
        CSResourceMgr.removeCSObjectByTag(resNameEfx)
    end)

    curEfx:performWithDelay(function()
        CSResourceMgr.removeCSObjectByTag(resNameEfx)
    end, 5)
end

function CheckViewMgr.setSignButton(itemNode,index)
    if index == 1 then
        CSResourceMgr.clickEventBindingByNode(itemNode, function()
            StandardTipsMgr.show(1, "signin2")
        end,1)
    else
        CSResourceMgr.clickEventBindingByNode(itemNode, function()
            StandardTipsMgr.show(1, "signin3")
        end,1)
    end
end

function CheckViewMgr.getCurTime()
    local time = CharInfo.getServerTime() + CharInfo.getServerTimeZone()
    local serverTime = CharInfo.getServerTime()
    local isToday = 21600 > time%86400
    local curDay = tonumber(CocosModuleMgr.getTimeStr(serverTime, 5))
    local curTime = {}
    if signinTabel then
        if signinTabel.monthDay == 0 then
            if isToday then
                curTime.day = curDay-1
            else
                curTime.day = curDay
            end
        else
            if isToday then
                curTime.day = curDay - signinTabel.monthDay
            else
                curTime.day = curDay - signinTabel.monthDay + 1 --当月第几天
            end
        end
    else
        if isToday then
            curTime.day = curDay-1
        else
            curTime.day = curDay
        end
    end
    curTime.totalday = tonumber(os.date("%d",os.time({year=CocosModuleMgr.getTimeStr(serverTime, 7),month=CocosModuleMgr.getTimeStr(serverTime, 4)+1,day=0}))) --当月总天数
    return curTime
end

function CheckViewMgr.setRedPoint()
    local time = CharInfo.getServerTime() + CharInfo.getServerTimeZone()
    local isToday = 21600 > time%86400
    local timeM = nil
    if isToday then
        timeM = 21600 - time%86400
    else
        timeM = 86400 + 21600 - time%86400
    end
    scheduler.performWithDelayGlobal(function()
        StatusBarMgr.hideRedPoint(9)
    end, timeM)

    local curTime = CheckViewMgr.getCurTime()
    local isSigned = false
    if signinTabel and signinTabel.days then
        for k,v in pairs(signinTabel.days) do
            if v == curTime.day then
                isSigned = true
            end
        end
    end
    if isSigned then
        StatusBarMgr.hideRedPoint(9)
    else
        StatusBarMgr.addRedPoint(9)
    end
end

return CheckViewMgr