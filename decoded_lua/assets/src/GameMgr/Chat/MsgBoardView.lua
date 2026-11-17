local MsgBoardView = {}

local resName = {}
local resNameA = {}
MsgBoardView.emoji_panel_status = false    --表情容器是否被打开
MsgBoardView.DEFAULT_SHOWMSG_SIZE = 10
local editbox = nil
local curTab = 1
local tabName = {}
local MsgBoardTable = {}
local curadventureInfo = {}
local isChangeTab = false
local sortByNew = true
local orderString = {}
local curPetInfo = {}
local lastMsg = {}

function MsgBoardView.Init()
    resName = "UI/Chat/MsgBoardView.csb"
    resNameA = "UI/Chat/lookPlayerInfoWindow.csb"
    MsgBoardView.emoji_panel_status = false
    editbox = nil
    curTab = 1
    tabName = {"MsgBoard2", "MsgBoard3", "MsgBoard4"}
    MsgBoardTable = {}
    curadventureInfo = {}
    isChangeTab = false
    sortByNew = true
    curPetInfo = {}
    lastMsg = {}

    orderString = {
        [1] = "Pet/Education/c.png",
        [2] = "Pet/Education/b.png",
        [3] = "Pet/Education/a.png",
        [4] = "Pet/Education/s.png",
        [5] = "Pet/Education/2s.png",
        [6] = "Pet/Education/3s.png",
    }
end

--type:1--宠物 2--副本
function MsgBoardView.show(scene,boardType,adventureInfo,petInfo)
    GameAudio.playUISound("messagePopup")

    local function loadCSB()
        if boardType == 1 then
            resName = "UI/Chat/MsgBoardView.csb"
        elseif boardType == 2 then
            resName = "UI/Chat/MsgBoardView2.csb"
        end
        curadventureInfo = adventureInfo

        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320,480)
        curLayer:setVisible(false)
        --...

        editbox = CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resName, "chattab"), "empty", 
        340, 30, 180, 23, 24, TownChatMgr.MAX_WORD_SIZE, "chat9")

        local diff = CocosModuleMgr.getScreenSizeDiff()
        local diban = CSResourceMgr.getNodeByName(resName, "diban")
        local dbsize = diban:getContentSize()
        diban:setContentSize(dbsize.width, dbsize.height+diff)
        local diban2 = CSResourceMgr.getNodeByName(resName, "diban2")
        local db2size = diban2:getContentSize()
        diban2:setContentSize(db2size.width, db2size.height+diff)
        local diban3 = CSResourceMgr.getNodeByName(resName, "diban3")
        local db3size = diban3:getContentSize()
        diban3:setContentSize(db3size.width, db3size.height+diff)
        local diwen = CSResourceMgr.getNodeByName(resName, "diwen")
        local dwsize = diwen:getContentSize()
        diwen:setContentSize(dwsize.width, dwsize.height+diff)
        local movePart = CSResourceMgr.getNodeByName(resName, "movePart")
        local mposy = movePart:getPositionY()
        movePart:setPositionY(mposy+diff)
        local sortMethod = CSResourceMgr.getNodeByName(resName, "sortMethod")
        local sposy = sortMethod:getPositionY()
        sortMethod:setPositionY(sposy+diff)
        local greenBtn = CSResourceMgr.getNodeByName(resName, "greenBtn")
        local gposy = greenBtn:getPositionY()
        greenBtn:setPositionY(gposy+diff)
        local topBtn = CSResourceMgr.getNodeByName(resName, "topBtn")
        local tposy = topBtn:getPositionY()
        topBtn:setPositionY(tposy+diff)
        local NoMsg = CSResourceMgr.getNodeByName(resName, "NoMsg")
        local nposy = NoMsg:getPositionY()
        NoMsg:setPositionY(nposy+diff)
        NoMsg:setVisible(false)

        local title = CSResourceMgr.getNodeByName(resName, "title")
        CSResourceMgr.setLabelColor(resName, "title", {r=160,g=235,b=250,a=255})
        CSResourceMgr.setLabelString(resName, "title", "MsgBoard1", "", {r=37,g=54,b=75,a=255})
        local close = CSResourceMgr.getNodeByName(resName, "close")
        CSResourceMgr.clickEventBindingByNode(close, function()
            MsgBoardView.hide()
        end)
        CSResourceMgr.setButtonEnabled(resName, "greenBtn", false)
        
        CSResourceMgr.setLabelColor(resName, "NoMsgLabel", {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelString(resName, "NoMsgLabel", "MsgBoard5")

        --TOP按钮
        CSResourceMgr.clickEventBindingByNode(topBtn, function()
            if boardType == 1 then
                CSResourceMgr.getNodeByName(resName, "list"):scrollToTop(0.2, true)
            end
            if boardType == 2 then
                CSResourceMgr.getNodeByName(resName, "list"..curTab):scrollToTop(0.2, true)
            end
        end)

        MsgBoardView.emoji_panel_status = false
        --绘文字按钮
        CSResourceMgr.clickEventBinding(resName, "emoji", function()
            if MsgBoardView.emoji_panel_status == false then
                MsgBoardView.showEmojiPanel(true)
                MsgBoardView.emoji_panel_status = true
            else
                MsgBoardView.hideEmojiPanel(true)
                MsgBoardView.emoji_panel_status = false
            end
        end)
        local function isEmojiMax(text)
            local num = 0
            local concent = ChatMsgMgr.chatMessageProcessor("", text, 3)
            local cjson = require("cjson")
            local tbl = cjson.decode(concent)
            for k,v in pairs(tbl) do
                if v.image then
                    num = num + 1
                end
            end
            return num >=3
        end
        local function onClickEmoji(type)
            local cur_text = editbox:getText()
            if not isEmojiMax(cur_text) then
                editbox:setText(cur_text..string.gsub(ChatMsgMgr.emoji_tbl[type], "%%", ""))
            else
                StandardTipsMgr.show(1, "chat16")
            end
        end
        MsgBoardView.bindAllEmojiButtonsEvents(onClickEmoji)

        if boardType == 1 then
            curPetInfo = petInfo
            if sortByNew then
                NetInterface.sendWithBlock("GC_GetMessagesPetByTime_Ack", function()
                        local MessageBoardSend = require("src.Net.Send.MessageBoardSend")
                        MessageBoardSend.sendCG_GetMessagesPetByTime_Req({pokeID = petInfo.pokeID,startIndex = "",num = MsgBoardView.DEFAULT_SHOWMSG_SIZE})
                    end,function()
                        MsgBoardView.setPetMsgBoard(petInfo)
                    end)
            else
                NetInterface.sendWithBlock("GC_GetMessagesPetByApprove_Ack", function()
                        local MessageBoardSend = require("src.Net.Send.MessageBoardSend")
                        MessageBoardSend.sendCG_GetMessagesPetByApprove_Req({pokeID = petInfo.pokeID,tipNum = 2147483647,skipNum = 0,num = MsgBoardView.DEFAULT_SHOWMSG_SIZE})
                    end,function()
                        MsgBoardView.setPetMsgBoard(petInfo)
                    end)
            end
        end
        if boardType == 2 then
            if sortByNew then
                NetInterface.sendWithBlock("GC_GetMessagesFBByTime_Ack", function()
                        local MessageBoardSend = require("src.Net.Send.MessageBoardSend")
                        MessageBoardSend.sendCG_GetMessagesFBByTime_Req({mapID = WorldMapMgr.curMapID,nodeID = WorldMapMgr.curP,diffi = curTab,startIndex = "",num = MsgBoardView.DEFAULT_SHOWMSG_SIZE})
                    end,function()
                        MsgBoardView.setStageMsgBoard(adventureInfo)
                    end)
            else
                NetInterface.sendWithBlock("GC_GetMessagesFBByApprove_Ack", function()
                        local MessageBoardSend = require("src.Net.Send.MessageBoardSend")
                        MessageBoardSend.sendCG_GetMessagesFBByApprove_Req({mapID = WorldMapMgr.curMapID,nodeID = WorldMapMgr.curP,diffi = curTab,tipNum = 2147483647,skipNum = 0,num = MsgBoardView.DEFAULT_SHOWMSG_SIZE})
                    end,function()
                        MsgBoardView.setStageMsgBoard(adventureInfo)
                    end)
            end
        end
    end
        

    local function playCSB()
        CSResourceMgr.getCsbObj(resName):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resName), "down")
    end

    loadCSB()
    playCSB()
    -- local funcTable = {loadCSB, playCSB}
    -- UnblockLoader.load(funcTable, "MsgBoardView")
end

function MsgBoardView.hide()
    GameAudio.playUISound("messageRetract")
    UnblockLoader.cancel("MsgBoardView")
    UnblockLoader.cancel("CommonList-LoadItem"..resName.."list1")
    UnblockLoader.cancel("CommonList-LoadItem"..resName.."list2")
    UnblockLoader.cancel("CommonList-LoadItem"..resName.."list3")
    UnblockLoader.cancel("CommonList-LoadItem"..resName.."list")
    CSResourceMgr.removeCSObjectByTag(resName)
end

---打开表情容器
--@param doAnimated bool 是否播放动画
function MsgBoardView.showEmojiPanel(doAnimated)
    if MsgBoardView.load_finished == false then
        --print("showEmojiPanel faileded. 聊天UI尚未加载")
        return false
    end
    if MsgBoardView.emoji_panel_status == false then
        CSResourceMgr.playAction(resName, 0, 5, false)
        CSResourceMgr.getNodeByName(resName, "emojipanel"):setVisible(true)
        MsgBoardView.emoji_panel_status = true
    end
end

---隐藏表情容器
--@param doAnimated bool 是否播放动画
function MsgBoardView.hideEmojiPanel(doAnimated)
    if MsgBoardView.load_finished == false then
        --print("hideEmojiPanel failed. 聊天UI尚未加载")
        return false
    end
    if MsgBoardView.emoji_panel_status == true then
        if doAnimated then
            CSResourceMgr.playAction(resName, 20, 25, false)
        else
            CSResourceMgr.getNodeByName(resName, "emojipanel"):setVisible(false)
        end
        MsgBoardView.emoji_panel_status = false
    end
end

---绑定所有表情点击事件
--@param callback function 点击事件回调，并带参数
function MsgBoardView.bindAllEmojiButtonsEvents(callback)
    for var=1, ChatMsgMgr.EMOJI_NUM do
        CSResourceMgr.clickEventBinding(resName, string.format("em%02d",var), function()
            callback(var)
        end)
    end
end

--宠物留言板
function MsgBoardView.setPetMsgBoard(petInfo)
    local diff = CocosModuleMgr.getScreenSizeDiff()
    local list = CSResourceMgr.getNodeByName(resName, "list")
    local lsize = list:getContentSize()
    list:setContentSize(lsize.width, lsize.height+diff)

    local pokemonInfo = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
    local name = CSResourceMgr.getNodeByName(resName, "name")
    CSResourceMgr.setLabelColorByNode(name,PokemonInfo.COLOR[pokemonInfo.rarePoint])
    CSResourceMgr.setLabelStringByNode(name, pokemonInfo.name)
    local attrLabel = CSResourceMgr.getNodeByName(resName, "attrLabel")
    CSResourceMgr.setLabelColorByNode(attrLabel,{r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(attrLabel, "MsgBoard6")
    local headIcon = CSResourceMgr.getNodeByName(resName, "headIcon")
    CSResourceMgr.setSpriteTextureByNode(headIcon, "Pet/PetIcon/"..pokemonInfo.icon..".png")
    headIcon:setScale(0.9,0.9)
    CSResourceMgr.getNodeByName(resName,"petHead"):loadTexture("Pet/BasicPetList_2/Stage/"..pokemonInfo.rarePoint..".png")
    CSResourceMgr.getNodeByName(resName,"rareIcon"):loadTexture(orderString[pokemonInfo.rarePoint])
    local icon1 = "Pet/AttriIcon/"..pokemonInfo.elementAtt1..".png"
    local icon2 = "Pet/AttriIcon/small_"..pokemonInfo.elementAtt1..".png"
    CSResourceMgr.getNodeByName(resName,"attrIcon"):loadTexture(icon1)
    CSResourceMgr.getNodeByName(resName,"attrBack"):loadTexture(icon2)

    --阿杜修改英文版显示
    local posX = attrLabel:getPositionX()
    local width = attrLabel:getContentSize().width
    CSResourceMgr.getNodeByName(resName,"attrBack"):setPositionX(posX+width+20)

    CSResourceMgr.getNodeByName(resName, "NoMsg"):setVisible(#MsgBoardTable==0)
    MsgBoardView.setPetMsg()

    local sendBtn = CSResourceMgr.getNodeByName(resName, "send")
    CSResourceMgr.clickEventBindingByNode(sendBtn, function()
        local content = editbox:getText()
        if content~= "" then
            NetInterface.sendWithBlock("GC_PostMessagePet_Ack", function()
                    local MessageBoardSend = require("src.Net.Send.MessageBoardSend")
                    MessageBoardSend.sendCG_PostMessagePet_Req({sContent = content,pokeID = petInfo.pokeID})
                end,function()
                isChangeTab = true
                    MsgBoardView.refreshPet()
                end)
            editbox:setText("")
        end
    end)
    local sortMethod = CSResourceMgr.getNodeByName(resName, "sortMethod")
    CSResourceMgr.setButtonStringByNode(sortMethod, sortByNew and "NEW" or "HOT", {r=0,g=0,b=0,a=255})
    CSResourceMgr.setButtonStringColorByNode(sortMethod, {r=227,g=233,b=255,a=255})
    CSResourceMgr.clickEventBindingByNode(sortMethod, function()
        sortByNew = not sortByNew
        isChangeTab = true
        MsgBoardView.refreshPet()
        CSResourceMgr.setButtonStringByNode(sortMethod, sortByNew and "NEW" or "HOT", {r=0,g=0,b=0,a=255})
        end,1)
end

--关卡留言板
function MsgBoardView.setStageMsgBoard(adventureInfo)
    local diff = CocosModuleMgr.getScreenSizeDiff()
    local list1 = CSResourceMgr.getNodeByName(resName, "list1")
    local l1size = list1:getContentSize()
    list1:setContentSize(l1size.width, l1size.height+diff)
    local list2 = CSResourceMgr.getNodeByName(resName, "list2")
    local l2size = list2:getContentSize()
    list2:setContentSize(l2size.width, l2size.height+diff)
    local list3 = CSResourceMgr.getNodeByName(resName, "list3")
    local l3size = list3:getContentSize()
    list3:setContentSize(l3size.width, l3size.height+diff)

    local stageName = CSResourceMgr.getNodeByName(resName, "stageName")
    CSResourceMgr.setLabelColorByNode(stageName, {r=166,g=243,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(stageName, adventureInfo.name)
    local headIcon = CSResourceMgr.getNodeByName(resName, "headIcon")
    local pparam = 0
    for k,v in pairs(WorldMapInfo.getSearchInfoByID(WorldMapMgr.curMapID)) do
        if v.id == WorldMapMgr.curP then
            pparam = v.info
        end
    end
    CSResourceMgr.setSpriteTextureByNode(headIcon, WorldMapInfo.getAdventureIcon(pparam))
    headIcon:setScale(0.6,0.6)

    local selColor = {r=255,g=255,b=255,a=255}
    local selOutColor = {r=209,g=138,b=0,a=255}
    local unselColor = {r=82,g=82,b=82,a=255}
    local unselOutColor = {r=236,g=236,b=236,a=0}

    --根据副本难度数量显示分页个数
    for i=1,3 do
        CSResourceMgr.getNodeByName(resName, "tab"..i):setVisible(false)
    end
    for i=1,adventureInfo.diffcultType do
        CSResourceMgr.getNodeByName(resName, "tab"..i):setVisible(true)
    end
    for var=1, adventureInfo.diffcultType do
        CSResourceMgr.clickEventBinding(resName, "tab"..var, function()
            CSResourceMgr.setButtonEnabled(resName, "tab"..curTab, true)
            CSResourceMgr.getNodeByName(resName, "list"..curTab):setVisible(false)
            CSResourceMgr.setButtonStringColor(resName, "tab"..curTab, unselColor)
            CSResourceMgr.setButtonString(resName, "tab"..curTab, tabName[curTab],"",unselOutColor)
            local tabbtn = CSResourceMgr.getNodeByName(resName, "tab"..curTab)
            UnblockLoader.cancel("CommonList-LoadItem"..resName.."list"..curTab)
            tabbtn:setPositionY(813+diff)
            tabbtn:setScale(1, 1)
            tabbtn:setLocalZOrder(1)
            curTab = var
            CSResourceMgr.setButtonEnabled(resName, "tab"..curTab, false)
            CSResourceMgr.getNodeByName(resName, "list"..curTab):setVisible(true)
            CSResourceMgr.setButtonStringColor(resName, "tab"..curTab, selColor)
            CSResourceMgr.setButtonString(resName, "tab"..curTab, tabName[curTab],"",selOutColor)
            local curtabbtn = CSResourceMgr.getNodeByName(resName, "tab"..curTab)
            curtabbtn:setPositionY(818+diff)
            curtabbtn:setScale(1.1, 1.1)
            curtabbtn:setLocalZOrder(2)
            isChangeTab = true
            MsgBoardView.refreshStage()
        end)
        CSResourceMgr.setButtonStringColor(resName, "tab"..var, unselColor)
        CSResourceMgr.setButtonString(resName, "tab"..var, tabName[var],"",unselOutColor)
        local tabbtn = CSResourceMgr.getNodeByName(resName, "tab"..var)
        tabbtn:setPositionY(813+diff)
        tabbtn:setScale(1, 1)
        tabbtn:setLocalZOrder(1)
    end
    CSResourceMgr.setButtonStringColor(resName, "tab"..curTab, selColor)
    CSResourceMgr.setButtonString(resName, "tab"..curTab, tabName[curTab],"",selOutColor)
    CSResourceMgr.setButtonEnabled(resName, "tab"..curTab, false)
    CSResourceMgr.getNodeByName(resName, "list"..curTab):setVisible(true)
    local curtabbtn = CSResourceMgr.getNodeByName(resName, "tab"..curTab)
    curtabbtn:setPositionY(818+diff)
    curtabbtn:setScale(1.1, 1.1)
    curtabbtn:setLocalZOrder(2)

    CSResourceMgr.getNodeByName(resName, "NoMsg"):setVisible(#MsgBoardTable==0)
    MsgBoardView.setStageMsg()

    local sendBtn = CSResourceMgr.getNodeByName(resName, "send")
    CSResourceMgr.clickEventBindingByNode(sendBtn, function()
        local content = editbox:getText()
        if content~= "" then
            NetInterface.sendWithBlock("GC_PostMessageFB_Ack", function()
                    local MessageBoardSend = require("src.Net.Send.MessageBoardSend")
                    MessageBoardSend.sendCG_PostMessageFB_Req({sContent = content,mapID = WorldMapMgr.curMapID,nodeID = WorldMapMgr.curP,diffi = curTab})
                end,function()
                isChangeTab = true
                    MsgBoardView.refreshStage()
                end)
            editbox:setText("")
        end
    end)
    local sortMethod = CSResourceMgr.getNodeByName(resName, "sortMethod")
    CSResourceMgr.setButtonStringByNode(sortMethod, sortByNew and "NEW" or "HOT", {r=0,g=0,b=0,a=255})
    CSResourceMgr.setButtonStringColorByNode(sortMethod, {r=227,g=233,b=255,a=255})
    CSResourceMgr.clickEventBindingByNode(sortMethod, function()
        UnblockLoader.cancel("CommonList-LoadItem"..resName.."list"..curTab)
        sortByNew = not sortByNew
        isChangeTab = true
        MsgBoardView.refreshStage()
        CSResourceMgr.setButtonStringByNode(sortMethod, sortByNew and "NEW" or "HOT", {r=0,g=0,b=0,a=255})
        end,1)
end

function MsgBoardView.setStageMsg()
    local function setZanAndCai(parent,isZan,isCai,var)
        local zanColor = isZan and {r=255,g=255,b=255,a=255} or {r=88,g=88,b=88,a=255}
        local caiColor = isCai and {r=255,g=255,b=255,a=255} or {r=88,g=88,b=88,a=255}
        local zanLabelColor = isZan and {r=248,g=76,b=29,a=255} or {r=88,g=88,b=88,a=255}
        local caiLabelColor = isCai and {r=79,g=192,b=248,a=255} or {r=88,g=88,b=88,a=255}
        CSResourceMgr.seekNodeByName(parent, "zanBack"):setColor(zanColor)
        CSResourceMgr.seekNodeByName(parent, "zanIcon"):setColor(zanColor)
        CSResourceMgr.seekNodeByName(parent, "zanNum"):setColor(zanLabelColor)
        CSResourceMgr.seekNodeByName(parent, "caiBack"):setColor(caiColor)
        CSResourceMgr.seekNodeByName(parent, "caiIcon"):setColor(caiColor)
        CSResourceMgr.seekNodeByName(parent, "caiNum"):setColor(caiLabelColor)
        local zanNum = CSResourceMgr.seekNodeByName(parent, "zanNum")
        local caiNum = CSResourceMgr.seekNodeByName(parent, "caiNum")
        local zanBtn = CSResourceMgr.seekNodeByName(parent, "zanBtn")
        CSResourceMgr.clickEventBindingByNode(zanBtn, function()
            NetInterface.sendWithBlock("GC_PostApproveFB_Ack", function()
                    local MessageBoardSend = require("src.Net.Send.MessageBoardSend")
                    MessageBoardSend.sendCG_PostApproveFB_Req({sCommentID = var.id,bApprove = 1})
                end,function()
                    if isCai then
                        CSResourceMgr.setLabelStringByNode(caiNum, var.disapproveNum-1) 
                        var.disapproveNum = var.disapproveNum - 1
                    end
                    CSResourceMgr.setLabelStringByNode(zanNum, var.approveNum+1) 
                    var.approveNum = var.approveNum + 1
                    setZanAndCai(parent,true,false,var)      
                end,function(code)
                        TipsMgr.showError(nil, code)
                    end)
        end, 1)
        local caiBtn = CSResourceMgr.seekNodeByName(parent, "caiBtn")
        CSResourceMgr.clickEventBindingByNode(caiBtn, function()
            NetInterface.sendWithBlock("GC_PostApproveFB_Ack", function()
                    local MessageBoardSend = require("src.Net.Send.MessageBoardSend")
                    MessageBoardSend.sendCG_PostApproveFB_Req({sCommentID = var.id,bApprove = 0})
                end,function()
                    if isZan then
                        CSResourceMgr.setLabelStringByNode(zanNum, var.approveNum-1) 
                        var.approveNum = var.approveNum - 1
                    end
                    CSResourceMgr.setLabelStringByNode(caiNum, var.disapproveNum+1) 
                    var.disapproveNum = var.disapproveNum+1
                    setZanAndCai(parent,false,true,var)  
                end,function(code)
                        TipsMgr.showError(nil, code)
                    end)
        end, 1)
        CSResourceMgr.setButtonEnabledByNode(zanBtn, not isZan)
        CSResourceMgr.setButtonEnabledByNode(caiBtn, not isCai)
    end
    local msgList = CSResourceMgr.setCommonListInfo(MsgBoardTable, resName, "list"..curTab, "", nil, nil, function(i, var)
            local parent = CSResourceMgr.getNodeByName(resName, "MsgMain"):clone()
            local dateTbl = string.split(var.id, "T")
            parent:setVisible(true)
            CSResourceMgr.getNodeByName(resName, "list"..curTab):pushBackCustomItem(parent)
            local level = CSResourceMgr.seekNodeByName(parent, "level")
            CSResourceMgr.setLabelColorByNode(level, {r=255,g=252,b=0,a=255})
            CSResourceMgr.setLabelStringByNode(level, "Lv."..var.ownerInfo.Level, {r=0,g=0,b=0,a=255,w=1})
            local playerName = CSResourceMgr.seekNodeByName(parent, "playerName")
            CSResourceMgr.setLabelColorByNode(playerName, var.ownerInfo.charID ~= CharInfo.getCharID() and {r=255,g=255,b=255,a=255} or {r=255,g=252,b=0,a=255})
            CSResourceMgr.setLabelStringByNode(playerName, var.ownerInfo.nickname, {r=3,g=28,b=49,a=255,w=1})
            local familyName = CSResourceMgr.seekNodeByName(parent, "familyName")
            CSResourceMgr.setLabelColorByNode(familyName, {r=255,g=252,b=0,a=255})
            CSResourceMgr.setLabelStringByNode(familyName, var.ownerInfo.familyName or "", {r=0,g=0,b=0,a=255,w=1})
            local time = CSResourceMgr.seekNodeByName(parent, "time")
            CSResourceMgr.setLabelColorByNode(time, {r=144,g=238,b=255,a=255})
            CSResourceMgr.setLabelStringByNode(time, dateTbl[1], {r=0,g=0,b=0,a=255,w=1})
            
            local message = CSResourceMgr.seekNodeByName(parent, "message")
            var.content = ChatMsgMgr.chatMessageProcessor("", var.content, 8)
            --阿杜修改英文版显示
            local fontSize = LuaSqlite.LANG_TYPE~= 1 and 20 or 18
            local richLabel = CocosModuleMgr.createRichLabel(message, var.content, fontSize, "cuyuan_GBK.ttf", 510,nil,nil,nil,true)
            message:setString(" ")
            message:setTextAreaSize({width = 0, height = richLabel.realHeight})
            message:ignoreContentAdaptWithSize(false)

            local headBtn = CSResourceMgr.seekNodeByName(parent, "headBack")
            CSResourceMgr.clickEventBindingByNode(headBtn,function()
                if var.ownerInfo.charID ~= CharInfo.getCharID() then
                    MsgBoardView.showPlayerInfoWindow(var.ownerInfo)
                end
            end)
            
            CSResourceMgr.seekNodeByName(parent, "diban4"):setColor({r=36,g=51,b=65,a=255})
            CSResourceMgr.seekNodeByName(parent, "zanNumBack"):setColor({r=23,g=35,b=48,a=255})
            CSResourceMgr.seekNodeByName(parent, "caiNumBack"):setColor({r=23,g=35,b=48,a=255})
            CSResourceMgr.seekNodeByName(parent, "line"):setColor({r=72,g=88,b=103,a=255})
            local bApprove = false
            local bDisApprove = false
            if var.bApprove~=nil then
                bApprove = var.bApprove == true
                bDisApprove = var.bApprove == false
            end
            setZanAndCai(parent,bApprove,bDisApprove,var)
            local zanNum = CSResourceMgr.seekNodeByName(parent, "zanNum")
            CSResourceMgr.setLabelStringByNode(zanNum, var.approveNum)
            local caiNum = CSResourceMgr.seekNodeByName(parent, "caiNum")
            CSResourceMgr.setLabelStringByNode(caiNum, var.disapproveNum)
            lastMsg = var
            return parent
        end,function(callback)
            MsgBoardView.refreshStage(callback)
        end,function(callback)
            if sortByNew then
                NetInterface.sendWithBlock("GC_GetMessagesFBByTime_Ack", function()
                        local MessageBoardSend = require("src.Net.Send.MessageBoardSend")
                        MessageBoardSend.sendCG_GetMessagesFBByTime_Req({mapID = WorldMapMgr.curMapID,nodeID = WorldMapMgr.curP,diffi = curTab,startIndex = lastMsg.id,num = MsgBoardView.DEFAULT_SHOWMSG_SIZE})
                    end, function()
                    callback()
                    end, function(code)
                        TipsMgr.showError(nil, code)
                    end)
            else
                NetInterface.sendWithBlock("GC_GetMessagesFBByApprove_Ack", function()
                        local skipNum = 0
                        for k,v in pairs(MsgBoardTable) do
                            if v.approveNum == lastMsg.approveNum then
                                skipNum = skipNum + 1
                            end
                        end
                        local MessageBoardSend = require("src.Net.Send.MessageBoardSend")
                        MessageBoardSend.sendCG_GetMessagesFBByApprove_Req({mapID = WorldMapMgr.curMapID,nodeID = WorldMapMgr.curP,diffi = curTab,tipNum = lastMsg.approveNum,skipNum = skipNum,num = MsgBoardView.DEFAULT_SHOWMSG_SIZE})
                    end,function()
                    callback()
                    end, function(code)
                        TipsMgr.showError(nil, code)
                    end)
            end
    end)
end

function MsgBoardView.showPlayerInfoWindow(playerInfo)
    local function loadCSB()
        local infoWindow = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameA)
        infoWindow:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resNameA, 320, 480, infoWindow.tag)

        local title = CSResourceMgr.getNodeByName(resNameA,"title")
        CSResourceMgr.setLabelColorByNode(title, {r=160,g=235,b=250,a=255})
        CSResourceMgr.setLabelStringByNode(title,playerInfo.nickname , {r=37,g=54,b=75,a=255})

        CSResourceMgr.clickEventBinding(resNameA,"close",function()
            UnblockLoader.cancel("MsgBoardView.showPlayerInfoWindow")
            CSResourceMgr.removeCSObjectByTag(resNameA)
        end)

        local buttonList = {}
        for i=1,5 do
            buttonList[i] = CSResourceMgr.getNodeByName(resNameA,"Button"..i)
            CSResourceMgr.setButtonStringColorByNode(buttonList[i], {r=227,g=233,b=255,a=255})
            CSResourceMgr.setButtonStringByNode(buttonList[i], "MsgBoardPlayer"..i, {r=0,g=0,b=0,a=255})
        end

        --查看好友按钮
        CSResourceMgr.clickEventBindingByNode(buttonList[1],function()
            PersonalCenterMgr.show(SceneMgr.getRunningScene,playerInfo.charID)
            UnblockLoader.cancel("MsgBoardView.showPlayerInfoWindow")
            CSResourceMgr.removeCSObjectByTag(resNameA)
        end)

        --添加好友按钮
        local friendInfo = {friendID = tonumber(playerInfo.charID)}
        local addFriendNeedLv = SystemInfo.getGlobalConfigAddInfoByID(21006).values[1]
        if TownChatMgr.isHaveFriend(friendInfo) or CharInfo.getLevel()<addFriendNeedLv then
            CSResourceMgr.setButtonEnabledByNode(buttonList[2], false)
        else
            CSResourceMgr.clickEventBindingByNode(buttonList[2],function()
                FriendsViewMgr.AddFriend(playerInfo.charID)
                UnblockLoader.cancel("MsgBoardView.showPlayerInfoWindow")
                CSResourceMgr.removeCSObjectByTag(resNameA)
            end)
        end
        
        --邀请家园按钮
        CSResourceMgr.clickEventBindingByNode(buttonList[3],function()
            if HomeInfo.IsCurrentHomeGuestNumReachMax() then
                DialogBoxMgr.showSmallDialogBox(self, 1, "home005")
            else
                NetInterface.sendWithBlock("GC_Chat_Ack", function()
                    --HomeInfo.SetCurrentHomeCharID(CharInfo.getCharID())
                    HomeInfo.SendInviteEnterHome(playerInfo.charID)
                    --print("---------playerInfo.friendID="..tostring(playerInfo.friendID))
                end)
            end
            UnblockLoader.cancel("MsgBoardView.showPlayerInfoWindow")
            CSResourceMgr.removeCSObjectByTag(resNameA)
        end)

        --邀请家族按钮
        if CharInfo.getFamilyID() then
            CSResourceMgr.clickEventBindingByNode(buttonList[4],function()
                if CharInfo.getFamilyID() == nil or FamilyInfo.GetLocalFamilyInfo() == nil then
                    StandardTipsMgr.show(1, "family10")
                elseif playerInfo.Level < SystemInfo.getGlobalConfigAddInfoByID(24005).values[1] then
                    StandardTipsMgr.show(1, "family12")
                else
                    NetInterface.sendWithBlock("GC_Chat_Ack", function()
                        --HomeInfo.SetCurrentHomeCharID(CharInfo.getCharID())
                        FamilyInfo.SendInviteEnterFamily(playerInfo.charID)
                        --print("---------playerInfo.friendID="..tostring(playerInfo.friendID))
                    end)
                end
                UnblockLoader.cancel("MsgBoardView.showPlayerInfoWindow")
                CSResourceMgr.removeCSObjectByTag(resNameA)
            end)
        else
            CSResourceMgr.setButtonEnabledByNode(buttonList[4], false)
        end

        --举报按钮
        CSResourceMgr.clickEventBindingByNode(buttonList[5],function()
            TipsMgr.show(nil, "MsgBoardPlayer6")
        end)
    end
    local function playCSB()
        CSResourceMgr.playAction(resNameA, 0, 5, false)
    end

    local funcTable = {loadCSB, playCSB}
    UnblockLoader.load(funcTable, "MsgBoardView.showPlayerInfoWindow")
end

function MsgBoardView.setPetMsg()
    local function setZanAndCai(parent,isZan,isCai,var)
        local zanColor = isZan and {r=255,g=255,b=255,a=255} or {r=88,g=88,b=88,a=255}
        local caiColor = isCai and {r=255,g=255,b=255,a=255} or {r=88,g=88,b=88,a=255}
        local zanLabelColor = isZan and {r=248,g=76,b=29,a=255} or {r=88,g=88,b=88,a=255}
        local caiLabelColor = isCai and {r=79,g=192,b=248,a=255} or {r=88,g=88,b=88,a=255}
        CSResourceMgr.seekNodeByName(parent, "zanBack"):setColor(zanColor)
        CSResourceMgr.seekNodeByName(parent, "zanIcon"):setColor(zanColor)
        CSResourceMgr.seekNodeByName(parent, "zanNum"):setColor(zanLabelColor)
        CSResourceMgr.seekNodeByName(parent, "caiBack"):setColor(caiColor)
        CSResourceMgr.seekNodeByName(parent, "caiIcon"):setColor(caiColor)
        CSResourceMgr.seekNodeByName(parent, "caiNum"):setColor(caiLabelColor)
        local zanNum = CSResourceMgr.seekNodeByName(parent, "zanNum")
        local caiNum = CSResourceMgr.seekNodeByName(parent, "caiNum")
        local zanBtn = CSResourceMgr.seekNodeByName(parent, "zanBtn")
        CSResourceMgr.clickEventBindingByNode(zanBtn, function()
            NetInterface.sendWithBlock("GC_PostApprovePet_Ack", function()
                    local MessageBoardSend = require("src.Net.Send.MessageBoardSend")
                    MessageBoardSend.sendCG_PostApprovePet_Req({sCommentID = var.id,bApprove = 1})
                end,function()
                    if isCai then
                        CSResourceMgr.setLabelStringByNode(caiNum, var.disapproveNum-1)
                        var.disapproveNum = var.disapproveNum-1
                    end
                    CSResourceMgr.setLabelStringByNode(zanNum, var.approveNum+1)
                    var.approveNum = var.approveNum + 1
                    setZanAndCai(parent,true,false,var)
                end, function(code)
                        TipsMgr.showError(nil, code)
                    end)
        end, 1)
        local caiBtn = CSResourceMgr.seekNodeByName(parent, "caiBtn")
        CSResourceMgr.clickEventBindingByNode(caiBtn, function()
            NetInterface.sendWithBlock("GC_PostApprovePet_Ack", function()
                    local MessageBoardSend = require("src.Net.Send.MessageBoardSend")
                    MessageBoardSend.sendCG_PostApprovePet_Req({sCommentID = var.id,bApprove = 0})
                end,function()
                    if isZan then
                        CSResourceMgr.setLabelStringByNode(zanNum, var.approveNum-1)  
                        var.approveNum = var.approveNum-1
                    end
                    CSResourceMgr.setLabelStringByNode(caiNum, var.disapproveNum+1)
                    var.disapproveNum = var.disapproveNum+1
                    setZanAndCai(parent,false,true,var)   
                end, function(code)
                        TipsMgr.showError(nil, code)
                    end)
        end, 1)
        CSResourceMgr.setButtonEnabledByNode(zanBtn, not isZan)
        CSResourceMgr.setButtonEnabledByNode(caiBtn, not isCai)
    end
    local msgList = CSResourceMgr.setCommonListInfo(MsgBoardTable, resName, "list", "", nil, nil, function(i, var)
            local parent = CSResourceMgr.getNodeByName(resName, "MsgMain"):clone()
            local dateTbl = string.split(var.id, "T")
            parent:setVisible(true)
            CSResourceMgr.getNodeByName(resName, "list"):pushBackCustomItem(parent)
            local level = CSResourceMgr.seekNodeByName(parent, "level")
            CSResourceMgr.setLabelColorByNode(level, {r=255,g=252,b=0,a=255})
            CSResourceMgr.setLabelStringByNode(level, "Lv."..var.ownerInfo.Level, {r=0,g=0,b=0,a=255,w=1})
            local playerName = CSResourceMgr.seekNodeByName(parent, "playerName")
            CSResourceMgr.setLabelColorByNode(playerName, var.ownerInfo.charID ~= CharInfo.getCharID() and {r=255,g=255,b=255,a=255} or {r=255,g=252,b=0,a=255})
            CSResourceMgr.setLabelStringByNode(playerName, var.ownerInfo.nickname, {r=3,g=28,b=49,a=255,w=1})
            local familyName = CSResourceMgr.seekNodeByName(parent, "familyName")
            CSResourceMgr.setLabelColorByNode(familyName, {r=255,g=252,b=0,a=255})
            CSResourceMgr.setLabelStringByNode(familyName, var.ownerInfo.familyName or "", {r=0,g=0,b=0,a=255,w=1})
            local time = CSResourceMgr.seekNodeByName(parent, "time")
            CSResourceMgr.setLabelColorByNode(time, {r=144,g=238,b=255,a=255})
            CSResourceMgr.setLabelStringByNode(time, dateTbl[1], {r=0,g=0,b=0,a=255,w=1})

            local message = CSResourceMgr.seekNodeByName(parent, "message")
            var.content = ChatMsgMgr.chatMessageProcessor("", var.content, 8)
            --阿杜修改英文版显示
            local fontSize = LuaSqlite.LANG_TYPE~= 1 and 20 or 18
            local richLabel = CocosModuleMgr.createRichLabel(message, var.content, fontSize, "cuyuan_GBK.ttf", 510,nil,nil,nil,true)
            message:setString(" ")
            message:setTextAreaSize({width = 0, height = richLabel.realHeight})
            message:ignoreContentAdaptWithSize(false)

            local headBtn = CSResourceMgr.seekNodeByName(parent, "headBack")
            CSResourceMgr.clickEventBindingByNode(headBtn,function()
                if var.ownerInfo.charID ~= CharInfo.getCharID() then
                    MsgBoardView.showPlayerInfoWindow(var.ownerInfo)
                end
            end)

            CSResourceMgr.seekNodeByName(parent, "diban4"):setColor({r=36,g=51,b=65,a=255})
            CSResourceMgr.seekNodeByName(parent, "zanNumBack"):setColor({r=23,g=35,b=48,a=255})
            CSResourceMgr.seekNodeByName(parent, "caiNumBack"):setColor({r=23,g=35,b=48,a=255})
            CSResourceMgr.seekNodeByName(parent, "line"):setColor({r=72,g=88,b=103,a=255})
            local bApprove = false
            local bDisApprove = false
            if var.bApprove~=nil then
                bApprove = var.bApprove == true
                bDisApprove = var.bApprove == false
            end
            setZanAndCai(parent,bApprove,bDisApprove,var)
            local zanNum = CSResourceMgr.seekNodeByName(parent, "zanNum")
            CSResourceMgr.setLabelStringByNode(zanNum, var.approveNum)
            local caiNum = CSResourceMgr.seekNodeByName(parent, "caiNum")
            CSResourceMgr.setLabelStringByNode(caiNum, var.disapproveNum)
            lastMsg = var
            return parent
        end,function(callback)
            MsgBoardView.refreshPet(callback)
        end,function(callback)
            if sortByNew then
                NetInterface.sendWithBlock("GC_GetMessagesPetByTime_Ack", function()
                        local MessageBoardSend = require("src.Net.Send.MessageBoardSend")
                        MessageBoardSend.sendCG_GetMessagesPetByTime_Req({pokeID = curPetInfo.pokeID,startIndex = lastMsg.id,num = MsgBoardView.DEFAULT_SHOWMSG_SIZE})
                    end, function()
                    callback()
                    end, function(code)
                        TipsMgr.showError(nil, code)
                    end)
            else
                NetInterface.sendWithBlock("GC_GetMessagesPetByApprove_Ack", function()
                        local skipNum = 0
                        for k,v in pairs(MsgBoardTable) do
                            if v.approveNum == lastMsg.approveNum then
                                skipNum = skipNum + 1
                            end
                        end
                        local MessageBoardSend = require("src.Net.Send.MessageBoardSend")
                        MessageBoardSend.sendCG_GetMessagesPetByApprove_Req({pokeID = curPetInfo.pokeID,tipNum = lastMsg.approveNum,skipNum = skipNum,num = MsgBoardView.DEFAULT_SHOWMSG_SIZE})
                    end,function()
                    callback()
                    end, function(code)
                        TipsMgr.showError(nil, code)
                    end)
            end
    end)
end

function MsgBoardView.refreshStage(callback)
    if sortByNew then
        NetInterface.sendWithBlock("GC_GetMessagesFBByTime_Ack", function()
                for var=1, #MsgBoardTable do
                    table.remove(MsgBoardTable, 1)
                end
                local MessageBoardSend = require("src.Net.Send.MessageBoardSend")
                MessageBoardSend.sendCG_GetMessagesFBByTime_Req({mapID = WorldMapMgr.curMapID,nodeID = WorldMapMgr.curP,diffi = curTab,startIndex = "",num = MsgBoardView.DEFAULT_SHOWMSG_SIZE})
            end, function()
            CSResourceMgr.getNodeByName(resName, "NoMsg"):setVisible(#MsgBoardTable==0)
            if isChangeTab then
                MsgBoardView.setStageMsg()
                isChangeTab = false
            end
            if callback then
                callback()
            end
        end, function(code)
            TipsMgr.showError(nil, code)
        end)
    else
        NetInterface.sendWithBlock("GC_GetMessagesFBByApprove_Ack", function()
                for var=1, #MsgBoardTable do
                    table.remove(MsgBoardTable, 1)
                end
                local MessageBoardSend = require("src.Net.Send.MessageBoardSend")
                MessageBoardSend.sendCG_GetMessagesFBByApprove_Req({mapID = WorldMapMgr.curMapID,nodeID = WorldMapMgr.curP,diffi = curTab,tipNum = 2147483647,skipNum = 0,num = MsgBoardView.DEFAULT_SHOWMSG_SIZE})
            end, function()
            CSResourceMgr.getNodeByName(resName, "NoMsg"):setVisible(#MsgBoardTable==0)
            if isChangeTab then
                MsgBoardView.setStageMsg()
                isChangeTab = false
            end
            if callback then
                callback()
            end
        end, function(code)
            TipsMgr.showError(nil, code)
        end)
    end
end

function MsgBoardView.refreshPet(callback)
    if sortByNew then
        NetInterface.sendWithBlock("GC_GetMessagesPetByTime_Ack", function()
                for var=1, #MsgBoardTable do
                    table.remove(MsgBoardTable, 1)
                end
                local MessageBoardSend = require("src.Net.Send.MessageBoardSend")
                MessageBoardSend.sendCG_GetMessagesPetByTime_Req({pokeID = curPetInfo.pokeID,startIndex = "",num = MsgBoardView.DEFAULT_SHOWMSG_SIZE})
            end, function()
            CSResourceMgr.getNodeByName(resName, "NoMsg"):setVisible(#MsgBoardTable==0)
            if isChangeTab then
                MsgBoardView.setPetMsg()
                isChangeTab = false
            end
            if callback then
                callback()
            end
        end, function(code)
            TipsMgr.showError(nil, code)
        end)
    else
        NetInterface.sendWithBlock("GC_GetMessagesPetByApprove_Ack", function()
                for var=1, #MsgBoardTable do
                    table.remove(MsgBoardTable, 1)
                end
                local MessageBoardSend = require("src.Net.Send.MessageBoardSend")
                MessageBoardSend.sendCG_GetMessagesPetByApprove_Req({pokeID = curPetInfo.pokeID,tipNum = 2147483647,skipNum = 0,num = MsgBoardView.DEFAULT_SHOWMSG_SIZE})
            end, function()
            CSResourceMgr.getNodeByName(resName, "NoMsg"):setVisible(#MsgBoardTable==0)
            if isChangeTab then
                MsgBoardView.setPetMsg()
                isChangeTab = false
            end
            if callback then
                callback()
            end
        end, function(code)
            TipsMgr.showError(nil, code)
        end)
    end
end

function MsgBoardView.update(jsStr)
    print(jsStr)
    local cjson = require("cjson")
    local j = cjson.decode(jsStr) or {}
    --for key, var in pairs(j) do
    for k=1, MsgBoardView.DEFAULT_SHOWMSG_SIZE do
        local var = j[k]
        if not var then
            break
        end
        if type(var._id)=="table" then
            var._id = var._id["$date"]
        end
        table.insert(MsgBoardTable, {
            id            = var._id,
            bApprove      = var.bApprove,
            ownerInfo     = var.ownerInfo,
            content       = var.content,
            fbID          = fbID,
            approveNum    = var.approveNum,
            disapproveNum = var.disapproveNum,
        })
    end
end

return MsgBoardView