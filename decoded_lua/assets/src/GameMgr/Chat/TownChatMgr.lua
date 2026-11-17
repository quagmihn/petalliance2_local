local TownChatMgr = {}

TownChatMgr.MAX_WORD_SIZE = 100
TownChatMgr.MAX_NAME_SIZE = 64
TownChatMgr.MAX_LIST_SIZE = 20            --聊天最大条数
TownChatMgr.MAX_LABEL_WIDTH = 640
TownChatMgr.LABEL_FONT_SIZE = 20
TownChatMgr.EMOJI_NUM = 25

TownChatMgr.load_finished = false         --是否加载完
TownChatMgr.chat_table = {}               --历史聊天记录
TownChatMgr.chatName_table = {}           --历史聊天人名记录
TownChatMgr.send_status = 0               --消息发送目标类型
TownChatMgr.list_status = 0               --消息分页列表选择类型
TownChatMgr.emoji_panel_status = false    --表情容器是否被打开
TownChatMgr.share_table = {}              --历史分享记录

local resName = ""
local resNameA = ""
local resNameB = ""
local resNameC = ""
local resNameD = ""
local resNameE = ""
local tab_string = {}
local tab_color = {}
local pathPre = ""
local pathDex = ""
local editbox = nil
local editbox_p = nil
local editbox_m = nil

local coroutine = nil
local coroutineFunc = nil
local reLoadMsg = nil

local tabColor = {}
local tabOutLineColor = {}

local isInMain = true

local channelTable = {}
local mChatName = ""
local mChatAddList = {}
local channelIndex = 1
local currentChannel = ""

local blackNameListTable = {}
local blackMaxNum = 0
local allFriendTable = {}

local petNodes = {}
local labelTable = {}
local buttonTable = {}
local worldChatTimeTable = {}

local isShowChat = false
local chatViewPosY = 0
local voiceDiff = 0

local startVoiceTime = 0
local endVoiceTime = 0

local voiceInfoTable = {}
local voiceCacheTable = {}
local isQueryOver = true
local curVoiceKey = ""
local curVoiceSprite = nil
local curVoiceLength = 0
local isRecording = false

local listInnerSize = {}
local listSize = {}
local listPosY = 0
local teamBackSize = {}
local exitTeamBattle = false
local mChatID = ""
local msgListFontSize = nil

local newMsgInfoTbl = {}

local rechargeTotal = 0

function TownChatMgr.Init()
    print("TownChatMgr初始化")
    
    TownChatMgr.load_finished = false         
    TownChatMgr.chat_table = {}      
    TownChatMgr.chat_table[1] = {}
    TownChatMgr.chat_table[2] = {}
    TownChatMgr.chat_table[3] = {}
    TownChatMgr.chat_table[4] = {}
    TownChatMgr.chat_table[5] = {}
    TownChatMgr.chat_table[6] = {}
    TownChatMgr.chat_table[7] = {}      
    TownChatMgr.chatName_table = {}      
    TownChatMgr.chatName_table[1] = {}
    TownChatMgr.chatName_table[2] = {}
    TownChatMgr.chatName_table[3] = {}
    TownChatMgr.chatName_table[4] = {}
    TownChatMgr.chatName_table[5] = {}
    TownChatMgr.chatName_table[6] = {}
    TownChatMgr.chatName_table[7] = {}    
    TownChatMgr.share_table = {}      
    TownChatMgr.share_table[1] = {}
    TownChatMgr.share_table[2] = {}
    TownChatMgr.share_table[3] = {}
    TownChatMgr.share_table[4] = {}
    TownChatMgr.share_table[5] = {}
    TownChatMgr.share_table[6] = {}  
    TownChatMgr.share_table[7] = {}   
    TownChatMgr.send_status = UserSettings.get("sendTag", 8) or 6
    TownChatMgr.list_status = UserSettings.get("listTag", 8) or 3
    TownChatMgr.emoji_panel_status = false
    if TownChatMgr.send_status == 7 then 
        TownChatMgr.send_status = 6
    end
    if TownChatMgr.list_status == 7 then 
        TownChatMgr.list_status = 6
    end
    
    resName = "UI/Chat/TownChatLayer.csb"
    resNameA = "UI/Chat/lookPlayerInfoWindowPlus.csb"
    resNameB = "UI/Chat/BlackNameListView.csb"
    resNameC = "UI/Chat/PetShare.csb"
    resNameD = "UI/Chat/ChatIcon.csb"
    resNameE = "UI/Chat/VoiceLayer.csb"
    tab_string = {"zonghe", "xitong", "shijie", "jiazu", "siliao", "fujin","zudui"}
    tab_color = {{r=255,g=113,b=0,a=255}, {r=255,g=66,b=0,a=255}, {r=255,g=219,b=0,a=255},
                {r=103,g=237,b=21,a=255}, {r=126,g=171,b=226,a=255}, {r=234,g=0,b=255,a=255},{r=196,g=230,b=252,a=255}}
    pathPre = "UI/Chat/tab_"
    pathDex = ".png"

    coroutine = require("coroutine")
    coroutineFunc = nil

    tabColor = {{r=255,g=255,b=255,a=255},{r=82,g=82,b=82,a=255}}
    tabOutLineColor = {{r=209,g=138,b=0,a=255},{r=229,g=229,b=229,a=255}}
    isInMain = true
    channelTable = {"待定", "待定", "world", "family", "", "zhucheng_","team_"}

    mChatAddList = {}
    channelIndex = 1
    currentChannel = "{}"

    blackNameListTable = UserSettings.get("blacknamelist", 8) or {}
    blackMaxNum = 0
    allFriendTable = {}

    petNodes = {}
    labelTable = {}
    buttonTable = {}
    worldChatTimeTable = {}
    isShowChat = false
    chatViewPosY = 0
    
    if not reLoadMsg then
        editbox = nil
        editbox_p = nil
        editbox_m = nil
        TownChatMgr.loadUI()
    end
    voiceDiff = 0
    startVoiceTime = 0
    endVoiceTime = 0
    voiceInfoTable = {}
    voiceCacheTable = {}
    isQueryOver = true
    curVoiceKey = ""
    curVoiceSprite = nil
    curVoiceLength = 0
    isRecording = false

    mChatID = ""
    
    if msgListFontSize==nil then
    	msgListFontSize = TownChatMgr.LABEL_FONT_SIZE+6
    	if CSResourceMgr.getScreenType()==false then
            msgListFontSize = msgListFontSize/2
    	end
    end

    newMsgInfoTbl = {}
end

local function composeVoiceName(charID)   
    if device.platform == "ios" then
        return charID.."_"..(os.clock()*1000)..".caf"
    else
        return charID.."_"..(os.clock()*1000)..".m4a"
    end
end

function TownChatMgr.setVisible(val)
    local function setVisible(res)
        local layer = CSResourceMgr.getCsbObj(res)
        if layer then
            layer:setVisible(val)
        end
    end
    setVisible(resName)
end

function TownChatMgr.addUI(scene)
    local layer = CSResourceMgr.createRes(scene or SceneMgr.getRunningScene, resName)
    layer:setLocalZOrder(CocosModuleMgr.ZORDER_BOARD)
    local diff, edgeDiff = TownChatMgr.getScreenSizeDiff()
    CocosModuleMgr.setRelativePosition(layer, 320, 480)
    CocosModuleMgr.setEdgeDistance(layer, nil, nil, nil, edgeDiff)
    voiceDiff = 0
    if exitTeamBattle then
        TownChatMgr.teamBattleChat(false)
        exitTeamBattle = false
    end

    editbox:setPlaceHolder(LuaSqlite.getLanguageByKey("chat9"))
    editbox_p:setPlaceHolder(LuaSqlite.getLanguageByKey("chat8"))
    editbox_m:setPlaceHolder(LuaSqlite.getLanguageByKey("chat9"))
    editbox_p:setText("")
    for key, var in pairs(tab_string) do
        local btn = CSResourceMgr.getNodeByName(resName, "btn_"..var)
        local label = CSResourceMgr.getNodeByName(resName, "label_"..var)
        if var == tab_string[TownChatMgr.list_status] then
            CSResourceMgr.setLabelStringByNode(label, "chat"..key, tabOutLineColor[1])
        else
            CSResourceMgr.setLabelStringByNode(label, "chat"..key, tabOutLineColor[2])
        end
    end
    TownChatMgr.send_status = TownChatMgr.list_status
    TownChatMgr.changeSendStatus(TownChatMgr.send_status)
    
    isInMain = SceneMgr.currentScene=="MainScene"
    local familyID = CharInfo.getFamilyID()
    if familyID ~= nil then
        channelTable[4] = "family_"..tostring(familyID)
    end

    if SceneMgr.currentScene == "HomeScene" then
        TownChatMgr.changeHomeTabName()
    end
    --进入私聊频道
    if SceneMgr.currentScene == "TownScene" then
        if not TeamInfo.getInfo(TeamInfo.KEY_TEAMID) then
            channelIndex = channelIndex - 1
            TownChatMgr.changeChannel()
        end
    end

    isShowChat = true
    chatViewPosY = 0
    curVoiceSprite = nil
    worldChatTimeTable = {}
    
    FriendsViewMgr.getAllFriendToChat()
    TownChatMgr.load_finished = true

    for k,v in pairs(newMsgInfoTbl) do
        if TownChatMgr.send_status~= k then
            TownChatMgr.setNewMarkVisibleByType(k, true)
        end
    end
    newMsgInfoTbl = {}
end

---只许调用一次！
function TownChatMgr.loadUI()
    local chatLayer = CSResourceMgr.createRes(nil, resName, nil, true)

    editbox = CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resName, "diban"), "empty", 
        320, 45, 288, 437, TownChatMgr.LABEL_FONT_SIZE+6, TownChatMgr.MAX_WORD_SIZE, "chat9")
    editbox_p = CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resName, "diban"), "empty", 
        120, 45, 185, 437, TownChatMgr.LABEL_FONT_SIZE+6, TownChatMgr.MAX_NAME_SIZE, "chat8")
    editbox_m = CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resName, "diban"), "UI/CommonFiles/chat_text_box_su.png", 
        200, 50, 365, 437, TownChatMgr.LABEL_FONT_SIZE+6, TownChatMgr.MAX_WORD_SIZE, "chat9")
    editbox_p:setVisible(false)
    editbox_m:setVisible(false)
    local chattab = CSResourceMgr.getNodeByName(resName,"chattab")
    chattab:setContentSize(390, 50)
    chattab:setPositionX(270)

    local MBtn = CSResourceMgr.getNodeByName(resName,"MBtn")
    MBtn:setLocalZOrder(3)    

    CSResourceMgr.getNodeByName(resName, "yellowLine"):setLocalZOrder(3)
    CSResourceMgr.getNodeByName(resName, "lt_bg"):setLocalZOrder(1.1)
    CSResourceMgr.getNodeByName(resName, "lt_huawen"):setLocalZOrder(1.2)
    CSResourceMgr.getNodeByName(resName, "emoji"):setLocalZOrder(3.5)

    blackMaxNum = SystemInfo.getGlobalConfigAddInfoByID(38).values[1]
    local blackNum = CSResourceMgr.getNodeByName(resName,"num")
    CSResourceMgr.setLabelColorByNode(blackNum, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(blackNum,TownChatMgr.getTableCount(blackNameListTable).."/"..blackMaxNum, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.getNodeByName(resName, "list"):setLocalZOrder(2)

    TownChatMgr.emoji_panel_status = false

    --语音聊天按钮
    local voiceBtn = CSResourceMgr.getNodeByName(resName, "voiceBtn")
    TownChatMgr.setVoiceChatBtnEvent(voiceBtn)

    --进入私聊频道
    if TownMapMgr.MapRes ~= "Map/TownMap/home_01.csb" and currentChannel == "{}" and CharInfo.getCharID()~=0 then
        channelIndex = channelIndex - 1
        TownChatMgr.changeChannel()
    end
    
    --发送按钮
    CSResourceMgr.clickEventBinding(resName, "send", function()
		if CharInfo.get().recharge.totalMoney == nil then 
			rechargeTotal = 0
		else
			rechargeTotal = CharInfo.get().recharge.totalMoney
		end
		if (TownChatMgr.send_status==3 or TownChatMgr.send_status==6 or TownChatMgr.send_status==5 )and rechargeTotal < 100 then
            StandardTipsMgr.show(1, "CantSendMsg1")
            return
        end
        local charactorName = CharInfo.getNickName()
        local text = editbox:getText()
        local text_p = editbox_p:getText()
        local text_m = editbox_m:getText()
        local textTable = {textType = "text",concent = "",cupLv = CharInfo.get().pvparenagrade or 0}
        local cjson = require("cjson")

        --世界发言间隔5分钟10条
        if TownChatMgr.send_status==3 and text~="" then
            if #worldChatTimeTable<3 then
                table.insert(worldChatTimeTable,CharInfo.getServerTime())
            elseif CharInfo.getServerTime()-(worldChatTimeTable[1] or 0)>15 and #worldChatTimeTable==3 then
                table.remove(worldChatTimeTable, 1)
                table.insert(worldChatTimeTable,CharInfo.getServerTime())
            else
                StandardTipsMgr.show(1, "CantSendMsg4")
                return
            end
        end
        if text~="" and TownChatMgr.send_status==7 then
            editbox:setText("")
            TownChatMgr.hideEmojiPanel(false)

            textTable.concent = text
            local str = json.encode(textTable)

            local teamID = TeamInfo.getInfo(TeamInfo.KEY_TEAMID)
            if teamID then
                NetInterface.sendWithBlock("GC_Chat_Ack", function()                
                    local ChatSend = require("src.Net.Send.ChatSend")
                    ChatSend.sendCG_Chat_Req({charID = "",channel = channelTable[TownChatMgr.send_status],concent =str})
                end)
            else
                StandardTipsMgr.show(1, "TeamInvite12")
            end
        elseif text~="" and TownChatMgr.send_status~=5 then
            editbox:setText("")
            TownChatMgr.hideEmojiPanel(false)

            textTable.concent = text
            local str = json.encode(textTable)

            if TownChatMgr.send_status==4 then
                local familyID = CharInfo.getFamilyID()
                if familyID ~= nil then
                    channelTable[TownChatMgr.send_status] = "family_"..tostring(familyID)
                else
                    StandardTipsMgr.show(1, "CantSendMsg3")
                    print("没有家族")
                    return
                end
            end

            NetInterface.sendWithBlock("GC_Chat_Ack", function()
                local ChatSend = require("src.Net.Send.ChatSend")
                if SceneMgr.currentScene == "HomeScene" and TownChatMgr.send_status == 6 then
                    ChatSend.sendCG_Chat_Req({charID = "",channel = "Home_"..tostring(HomeInfo.GetCurrentHomeCharID() == 0 
                        and "yard_"..(CharInfo.getFamilyID() or 0) or HomeInfo.GetCurrentHomeCharID()),concent =str})
                else
                    ChatSend.sendCG_Chat_Req({charID = "",channel = channelTable[TownChatMgr.send_status],concent =str})
                end
            end)
        elseif TownChatMgr.send_status==5 and text_m~="" then
            if text_p=="" then
                StandardTipsMgr.show(1, "CantSendMsg2")
                return
            end

            editbox_m:setText("")
            TownChatMgr.hideEmojiPanel(false)

            textTable.concent = text_m
            local str = json.encode(textTable)

            NetInterface.sendWithBlock("GC_Chat_Ack", function()
                local ChatSend = require("src.Net.Send.ChatSend")
                ChatSend.sendCG_Chat_Req({charID = mChatID,channel = "",concent =str})
            end)
            mChatName = text_p
        end
    end)
    --黑名单按钮
    CSResourceMgr.clickEventBinding(resName, "black", function()
        TownChatMgr.showBlackNameList()
    end)
	--绘文字按钮
	CSResourceMgr.clickEventBinding(resName, "emoji", function()
        if TownChatMgr.emoji_panel_status == false then
            TownChatMgr.showEmojiPanel(true)
            TownChatMgr.emoji_panel_status = true
        else
            TownChatMgr.hideEmojiPanel(true)
            TownChatMgr.emoji_panel_status = false
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
        if TownChatMgr.send_status~=5 then
            local cur_text = editbox:getText()
            if not isEmojiMax(cur_text) then
                editbox:setText(cur_text..string.gsub(ChatMsgMgr.emoji_tbl[type], "%%", ""))
            else
                StandardTipsMgr.show(1, "chat16")
            end
        else
            local cur_text = editbox_m:getText()
            if not isEmojiMax(cur_text) then
                editbox_m:setText(cur_text..string.gsub(ChatMsgMgr.emoji_tbl[type], "%%", ""))
            else
                StandardTipsMgr.show(1, "chat16")
            end
        end
    end
    TownChatMgr.bindAllEmojiButtonsEvents(onClickEmoji)

    reLoadMsg = function()
        CSResourceMgr.removeList(resName, "list")
        -- coroutineFunc = coroutine.create(function()
            for var=1, #TownChatMgr.chat_table[TownChatMgr.list_status] do
                TownChatMgr.addChatMessage(TownChatMgr.chat_table[TownChatMgr.list_status][var], TownChatMgr.list_status, true,TownChatMgr.chatName_table[TownChatMgr.list_status][var],TownChatMgr.share_table[TownChatMgr.list_status][var])
                -- coroutine.yield()
            end
        -- end)
        -- coroutine.resume(coroutineFunc)
    end

    for key, var in pairs(tab_string) do
        local btn = CSResourceMgr.getNodeByName(resName, "btn_"..var)
        local label = CSResourceMgr.getNodeByName(resName, "label_"..var)
        if var == tab_string[TownChatMgr.list_status] then
            CSResourceMgr.setLabelStringByNode(label, "chat"..key, tabOutLineColor[1])
            CSResourceMgr.setLabelColorByNode(label, tabColor[1])
        else
            CSResourceMgr.setLabelStringByNode(label, "chat"..key, tabOutLineColor[2])
            CSResourceMgr.setLabelColorByNode(label, tabColor[2])
        end
        btn:addTouchEventListener(function(sender, state)
            if state==0 then
            	-- sender:setLocalZOrder(1)
             --    sender:setScale(1.2)
             --    sender:setPositionY(385.5)
            elseif state==2 then
                TownChatMgr.changeTab(key)
            elseif state==3 then
                sender:setLocalZOrder(0)
                sender:setScale(1)
                sender:setPositionY(378.5)
            end
        end)
	end
    TownChatMgr.send_status = TownChatMgr.list_status
    TownChatMgr.changeSendStatus(TownChatMgr.send_status)
	TownChatMgr.tabButtonDisable(TownChatMgr.list_status)
    
    --新的屏幕适配方案
    local diff, edgeDiff = TownChatMgr.getScreenSizeDiff()
    local list = CSResourceMgr.getNodeByName(resName, "list")
    local lsize = list:getInnerContainerSize()
    list:setContentSize({width=lsize.width, height=lsize.height+diff-20})

    local teamChatBack = CSResourceMgr.getNodeByName(resName, "teamChatBack")
    local tsize = teamChatBack:getContentSize()
    teamChatBack:setContentSize({width=tsize.width, height=tsize.height+diff-20})

    listInnerSize = list:getInnerContainerSize()
    listSize = list:getContentSize()
    teamBackSize = teamChatBack:getContentSize()
    listPosY = list:getPositionY()
end

function TownChatMgr.removeUI()
    local clayer = CSResourceMgr.getCsbObj(resName)
    if clayer then
        CSResourceMgr.removeList(resName, "list")
        CSResourceMgr.removeCSObjectByTag(resName)
    end
    if isInMain then
        BasicMenuMgr.setChatBtnEnable(true)
    end
    isShowChat = false
    TownChatMgr.load_finished = false
end

function TownChatMgr.getScreenSizeDiff()
	local diff = CocosModuleMgr.getScreenSizeDiff()
    local curDiff = 1136-960
    if diff>curDiff then
        diff = 0
    else
        diff = (diff-curDiff)*0.75
    end
    local edgeDiff = 30
    if diff<0 then
        edgeDiff = edgeDiff+diff
    end
    return diff, edgeDiff
end

function TownChatMgr.deleteAllChatMessage()
    if TownChatMgr.load_finished == false then
        --print("deleteAllChatMessage failed. 聊天UI尚未加载")
        return false
    end
    local clabel = CSResourceMgr.getNodeByName(resName, "message")
    clabel = clabel:clone()
    CSResourceMgr.removeList(resName, "list")
    CSResourceMgr.getNodeByName(resName, "list"):pushBackCustomItem(clabel)
    for var=1, 6 do
        TownChatMgr.chat_table[var] = {}
        TownChatMgr.chatName_table[var] = {}
    end  
end

function TownChatMgr.changeStatus(status)
    local clayer = CSResourceMgr.getCsbObj(resName)
    if not clayer then
    	return
    end
    local list = CSResourceMgr.getNodeByName(resName, "list")
    if status==1 then
        reLoadMsg()
    else
        TownChatMgr.hideEmojiPanel(false)
        clayer:setPositionX(0)
        transition.moveTo(clayer, {y=-506, time=0.2})
        list:performWithDelay(function()
            TownChatMgr.removeUI()
        end, 0.2)
    end
end

---在聊天List中新增聊天Label
--@param message string 需要为chatMessageProcessor处理后的字符串
--@param type int 聊天消息类型，2系统/3世界/4公会/5私聊/6附近/7组队
--@param isReload bool 是否是重新load消息
function TownChatMgr.addChatMessage(message, type, isReload , nameInfo, shareTbl)
    type = type or 3
    isReload = isReload or false

    shareTbl = shareTbl or false

    if type<1 or type>7 then
        print("addChatMessage failed. 消息类型错误. 应该为2~6")
        return false
    end

    local list = CSResourceMgr.getNodeByName(resName, "list")
    
    if isReload == false then
        --判断综合列表信息数量是否达到最大
        if #TownChatMgr.chat_table[1]+1>TownChatMgr.MAX_LIST_SIZE then
            table.remove(TownChatMgr.chat_table[1], 1)
            table.remove(TownChatMgr.chatName_table[1], 1)
            table.remove(TownChatMgr.share_table[1], 1)
            if TownChatMgr.list_status==1 and list then
                list:removeItem(TownChatMgr.MAX_LIST_SIZE)
            end
        end
        --判断对应列表信息数量是否达到最大
        if type~=1 and #TownChatMgr.chat_table[type]+1>TownChatMgr.MAX_LIST_SIZE then
            table.remove(TownChatMgr.chat_table[type], 1)
            table.remove(TownChatMgr.chatName_table[type], 1)
            table.remove(TownChatMgr.share_table[type], 1)
            if TownChatMgr.list_status==type and list then
                list:removeItem(TownChatMgr.MAX_LIST_SIZE)
            end
        end
        --插入信息到table
        table.insert(TownChatMgr.chat_table[1], message)
        table.insert(TownChatMgr.chatName_table[1], nameInfo)
        table.insert(TownChatMgr.share_table[1], shareTbl)
        if type~=1 then
            table.insert(TownChatMgr.chat_table[type], message)
            table.insert(TownChatMgr.chatName_table[type], nameInfo)
            table.insert(TownChatMgr.share_table[type], shareTbl)
        end
        if not isShowChat then
            if type==7 or SceneMgr.currentScene~="TeamCopyMapScene" then
                BasicMenuMgr.setChatRedPoint(true)
            end
        end
        --判断聊天列表UI是否加载完毕
        if TownChatMgr.load_finished == false then
            newMsgInfoTbl[type] = true
            BasicMenuMgr.NEWMSGNUM = BasicMenuMgr.NEWMSGNUM + 1
            return false
        end
    end
    
    if type~=TownChatMgr.list_status and TownChatMgr.list_status~=1 then
        --加个新消息的红点
        TownChatMgr.setNewMarkVisibleByType(type, true)
        print("当前选择分页不需要创建label")
        return false
    end

    if list then
        local label = CSResourceMgr.getNodeByName(resName, "message"):clone()
        local richLabel = CocosModuleMgr.createRichLabel(label, message, msgListFontSize, "cuyuan_GBK.ttf", TownChatMgr.MAX_LABEL_WIDTH,nil,nil,nil,true)
        label:setString(" ")
        label:setTextAreaSize({width = 0, height = richLabel.realHeight})
        label:ignoreContentAdaptWithSize(false)
        local messageBtn = CSResourceMgr.seekNodeByName(label,"messageBtn")
        local mposy = messageBtn:getPositionY()
        local nameLen = 0

        local rate = 1
        local diffS = -3
        if CSResourceMgr.getScreenType()==false then
            rate = 2
            diffS = 3
        end

        --私聊名字长度加长
        if type ~= 5 then
            nameLen = (string.len(nameInfo.name)+string.utf8len(nameInfo.name))/2+1
        else
            nameLen = (string.len(CocosModuleMgr.createStringWithFormat({"chat11", nameInfo.name}))+string.utf8len(CocosModuleMgr.createStringWithFormat({"chat11", nameInfo.name})))/2
        end
        nameLen = nameLen + 1     
        messageBtn:setContentSize(cc.size(nameLen*13/rate, 30/rate))
        messageBtn:setPosition(100/rate,mposy+richLabel.realHeight-26/rate)
        -- if type ~= 2 then
        if type ~= 2 and nameInfo.id~=CharInfo.getCharID() then
            CSResourceMgr.clickEventBindingByNode(messageBtn,function()
                TownChatMgr.showPlayerInfoWindow(nameInfo)
            end)
        end

        if shareTbl then
            local shareBtn = CSResourceMgr.seekNodeByName(label,"messageBtn2")
            local shareLabel = CSResourceMgr.seekNodeByName(label,"shareLabel")
            local shareRate = CSResourceMgr.seekNodeByName(label, "rateIcon")
            shareBtn:setVisible(true)
            local textShare = ""
            local shareColor = {}
            if shareTbl.textType == "item" then
                local itemInfo = ItemInfo.getItemInfoById(shareTbl.itemInfo.id)
                local itemName = itemInfo.name
                shareColor = ItemInfo.COLOR[itemInfo.itemRare+1]
                textShare = CocosModuleMgr.createStringWithFormat({"【<1>】", itemName})
                CSResourceMgr.clickEventBindingByNode(shareBtn,function()
                            ItemInfoViewMgr.show(shareTbl.itemInfo,false)
                        end)
            elseif shareTbl.textType == "pet" then
                local pokemonInfo = PokemonInfo.getPokemonInfoByID(shareTbl.petInfo.pokeID)
                local petName = ""
                if LuaSqlite.getLanguageByKey(pokemonInfo.name)==shareTbl.petInfo.personName then
                    petName = shareTbl.petInfo.personName
                else
                    petName = LuaSqlite.getLanguageByKey(pokemonInfo.name).."·"..shareTbl.petInfo.personName
                end
                shareColor = PokemonInfo.COLOR[pokemonInfo.rarePoint]
                textShare = CocosModuleMgr.createStringWithFormat({"【<1>】", petName}) 
                    CSResourceMgr.clickEventBindingByNode(shareBtn,function()
                        PetShareDetail.show(shareTbl.petInfo)
                    end)

                local rateIcon = CocosModuleMgr.getWordImage("bz_epic.png")
                CSResourceMgr.setSpriteTextureByNode(shareRate, rateIcon)
                shareRate:setVisible(shareTbl.petInfo.skin ~= 0)
            elseif shareTbl.textType == "voice" then
                CSResourceMgr.setButtonTextureByNode(shareBtn, "UI/CommonFiles/chat_bubble_voice_su_01.png", "UI/CommonFiles/chat_bubble_voice_su_01.png", "UI/CommonFiles/chat_bubble_voice_su_01.png")
                shareBtn:setCapInsets({x = 36,y = 0,width = 9,height = 0})
                local voiceSprite = display.newSprite("UI/CommonFiles/chat_bubble_voice_talking_03.png")
                voiceSprite:addTo(shareBtn)
                voiceSprite:setPosition(24,15)
                local posY = mposy-diffS
                CSResourceMgr.clickEventBindingByNode(shareBtn,function()
                    if isQueryOver then
                        if curVoiceSprite then
                            TownChatMgr.stopVoiceAni(curVoiceSprite)
                        end
                        curVoiceSprite = voiceSprite
                        curVoiceLength = shareTbl.voiceInfo.voiceInfoTable.voiceLength
                        curVoiceKey = shareTbl.voiceInfo.date.."_"..shareTbl.voiceInfo.id
                        if shareTbl.voiceInfo.charID == CharInfo.getCharID() then
                            TownChatMgr.playVoice(shareTbl.voiceInfo.voiceInfoTable.voiceCachePath)
                        elseif voiceCacheTable[curVoiceKey] then
                            TownChatMgr.playVoice(voiceCacheTable[curVoiceKey])
                        else
                            VoiceManager.queryVoice(shareTbl.voiceInfo.date , shareTbl.voiceInfo.id,composeVoiceName(shareTbl.voiceInfo.charID))
                            isQueryOver = false        
                        end
                        transition.moveTo(shareBtn, {time = 0.1, y = posY-5})
                        shareBtn:performWithDelay(function()
                            transition.moveTo(shareBtn, {time = 0.1, y = posY})
                        end,0.1)
                        transition.moveTo(shareLabel, {time = 0.1, y = posY-5})
                        shareLabel:performWithDelay(function()
                            transition.moveTo(shareLabel, {time = 0.1, y = posY})
                        end,0.1)
                    end
                end)   
            elseif shareTbl.textType == "battle" then
                shareColor = {r=244,g=255,b=0,a=255}
                textShare = CocosModuleMgr.createStringWithFormat({"【<1>】", shareTbl.battleInfo.nameA.." VS "..shareTbl.battleInfo.nameB}) 
                --显示谁获胜
                if shareTbl.battleInfo.result == 1 then
                    textShare = textShare..shareTbl.battleInfo.nameA..LuaSqlite.getLanguageByKey("chat18")
                else
                    textShare = textShare..shareTbl.battleInfo.nameB..LuaSqlite.getLanguageByKey("chat18")
                end
                
                CSResourceMgr.clickEventBindingByNode(shareBtn,function()
                    --请求录像
                    BattleCotroller.getBattleRecord(shareTbl.battleInfo.battleId)
                end)        
            end
            shareLabel:setFontSize(msgListFontSize)
            local shareLen = (string.len(textShare)+string.utf8len(textShare))/2

            local listWidth = list:getContentSize().width
            CSResourceMgr.setLabelStringByNode(shareLabel, textShare, {r=0,g=0,b=0,a=255},nil,(listWidth-richLabel.realWidth))
            CSResourceMgr.setLabelColorByNode(shareLabel, shareColor)
            shareBtn:setContentSize(shareLabel:getContentSize().width, shareLabel:getContentSize().height)

            local voiceTime = 0
            if shareTbl.textType == "voice" then
                local voiceWidth = 50+9*shareTbl.voiceInfo.voiceInfoTable.voiceLength
                shareBtn:setContentSize(voiceWidth, 30)
                shareBtn:setScale(1/rate)
                CSResourceMgr.setLabelStringByNode(shareLabel, shareTbl.voiceInfo.voiceInfoTable.voiceLength.."'", {r=0,g=0,b=0,a=255})
                voiceTime = (shareBtn:getContentSize().width/2)/rate
            end
            shareBtn:setPosition(richLabel.realWidth,mposy-diffS)
            shareLabel:setPosition(richLabel.realWidth+voiceTime,mposy-diffS)
            shareRate:setPosition(shareLabel:getPositionX() + shareLabel:getContentSize().width + 98 * 0.5 - 15, 18/rate)
            shareRate:setScale(1/rate)
        end

        list:insertCustomItem(label, 0)
        if not isReload then
            label:performWithDelay(function()
                list:jumpToTop()
            end, 0.5)
        end

        if isReload and coroutineFunc~=nil then
            label:performWithDelay(function()
                coroutine.resume(coroutineFunc)
            end, 0.01)
        end
    end
end

---设置分页新消息红点
--@param type int 分页类型
--@param visible bool 是否显示分页新消息红点
function TownChatMgr.setNewMarkVisibleByType(type, visible)
    if TownChatMgr.load_finished == false then
        --print("setNewMarkVisibleByType failed. 聊天UI尚未加载")
        return false
    end
    if type==1 then
        for var=2,6 do
            TownChatMgr.setNewMarkVisibleByType(var, false)
        end
        return
    end
    local newMark = CSResourceMgr.getNodeByName(resName, "red_point_"..tab_string[type])
    if newMark~=nil then
        newMark:setVisible(visible)
    end
end

---打开表情容器
--@param doAnimated bool 是否播放动画
function TownChatMgr.showEmojiPanel(doAnimated)
    if TownChatMgr.load_finished == false then
        --print("showEmojiPanel faileded. 聊天UI尚未加载")
        return false
    end
    if TownChatMgr.emoji_panel_status == false then
        CSResourceMgr.playAction(resName, 0, 5, false)
        CSResourceMgr.getNodeByName(resName, "emojipanel"):setVisible(true)
        TownChatMgr.emoji_panel_status = true
        local shareLabelMain = CSResourceMgr.getNodeByName(resName,"shareLabelMain")
        CSResourceMgr.setLabelColorByNode(shareLabelMain, {r=255,g=224,b=1,a=255})
        CSResourceMgr.setLabelStringByNode(shareLabelMain, "TownShare0")
        local buttonPet = CSResourceMgr.getNodeByName(resName,"Button1")
        CSResourceMgr.setButtonStringColorByNode(buttonPet, {r=255,g=249,b=190,a=255})
        CSResourceMgr.setButtonStringByNode(buttonPet, "TownShare1", {r=81,g=63,b=13,a=255})
        local buttonItem = CSResourceMgr.getNodeByName(resName,"Button2")
        CSResourceMgr.setButtonStringColorByNode(buttonItem, {r=255,g=249,b=190,a=255})
        CSResourceMgr.setButtonStringByNode(buttonItem, "TownShare2", {r=81,g=63,b=13,a=255})
        local buttonSkillBook = CSResourceMgr.getNodeByName(resName,"Button3")
        CSResourceMgr.setButtonStringColorByNode(buttonSkillBook, {r=255,g=249,b=190,a=255})
        CSResourceMgr.setButtonStringByNode(buttonSkillBook, "TownShare3", {r=81,g=63,b=13,a=255})
        GameAudio.playUISound("popup")
        CSResourceMgr.clickEventBindingByNode(buttonPet, function()
            TownChatMgr.showSharePets()
        end)
        CSResourceMgr.clickEventBindingByNode(buttonItem, function()
            TownChatMgr.showShareItems()
        end)
        CSResourceMgr.clickEventBindingByNode(buttonSkillBook, function()
            TownChatMgr.showShareSkillBooks()
        end)
    end
end

---隐藏表情容器
--@param doAnimated bool 是否播放动画
function TownChatMgr.hideEmojiPanel(doAnimated)
    if TownChatMgr.load_finished == false then
        --print("hideEmojiPanel failed. 聊天UI尚未加载")
        return false
    end
    if TownChatMgr.emoji_panel_status == true then
        if doAnimated then
            CSResourceMgr.playAction(resName, 20, 25, false)
        else
            CSResourceMgr.getNodeByName(resName, "emojipanel"):setVisible(false)
        end
        TownChatMgr.emoji_panel_status = false
        GameAudio.playUISound("retract")
    end
end

---切换到私聊
--@param name string 私聊玩家名
function TownChatMgr.tabPChat(name)
    CSResourceMgr.setButtonStringColor(resName, "tabbtn", tab_color[5])
    CSResourceMgr.setButtonString(resName, "tabbtn", 
        ChatMsgMgr.SubUTF8String(LuaSqlite.getLanguageByKey("chat5"), LuaSqlite.LANG_TYPE ~= 1 and 1 or 3), "", {r=0,g=0,b=0,a=255})
    TownChatMgr.send_status = 5
    editbox_p:setVisible(true)
    editbox_m:setVisible(true)
    editbox:setVisible(false)
    editbox_p:setText(name)
    local chattab = CSResourceMgr.getNodeByName(resName,"chattab")
    chattab:setContentSize(190, 50)
    chattab:setPositionX(170)
end

---绑定所有表情点击事件
--@param callback function 点击事件回调，并带参数
function TownChatMgr.bindAllEmojiButtonsEvents(callback)
    for var=1, ChatMsgMgr.EMOJI_NUM do
        CSResourceMgr.clickEventBinding(resName, string.format("em%02d",var), function()
            callback(var)
        end)
    end
end

function TownChatMgr.refreshTabsColor()
    for key, var in pairs(tab_string) do
        local btn = CSResourceMgr.getNodeByName(resName, "btn_"..var)
        local label = CSResourceMgr.getNodeByName(resName, "label_"..var)
        if var == tab_string[TownChatMgr.list_status] then
            CSResourceMgr.setLabelStringByNode(label, "chat"..key, tabOutLineColor[1])
            CSResourceMgr.setLabelColorByNode(label, tabColor[1])
            if SceneMgr.currentScene == "HomeScene" and var == tab_string[6] then
                CSResourceMgr.setLabelStringByNode(label, "chat14", tabOutLineColor[1])
            end
        else
            CSResourceMgr.setLabelStringByNode(label, "chat"..key, tabOutLineColor[2])
            CSResourceMgr.setLabelColorByNode(label, tabColor[2])
            if SceneMgr.currentScene == "HomeScene" and var == tab_string[6] then
                CSResourceMgr.setLabelStringByNode(label, "chat14", tabOutLineColor[2])
            end
        end
    end
end

function TownChatMgr.OpenPlayerList()
    local lastPlayerIndex = nil
    local playerList = CSResourceMgr.getNodeByName(resName,"playerList")
    local playerListBlack = CSResourceMgr.getNodeByName(resName,"playerListBlack")
    playerList:setLocalZOrder(5)
    playerListBlack:setLocalZOrder(4)
    playerListBlack:setVisible(true)
    playerList:setVisible(true)
    CSResourceMgr.playAction(resName, 40, 45, false)
    local list = CSResourceMgr.getNodeByName(resName,"playersList")

    local function closePlayerList()
        CSResourceMgr.playActionWithCallback(resName, 60, 65, 1, function()
            playerList:setVisible(false)
            playerListBlack:setVisible(false)
            if list then
                list:removeAllItems()
            end
        end, "", 0.1)
    end

    CSResourceMgr.clickEventBinding(resName, "Button_close", function()
        closePlayerList()
    end)


    local function setPlayer(nameInfo)
        local player = CSResourceMgr.getNodeByName(resName, "player"):clone()
        player:setVisible(true)
        local playerName = CSResourceMgr.seekNodeByName(player, "playerName")
        CSResourceMgr.setLabelColorByNode(playerName, {r=217,g=234,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(playerName, nameInfo.name, {r=17,g=17,b=16,a=255})
        list:pushBackCustomItem(player)

        CSResourceMgr.clickEventBindingByNode(player, function()
            mChatID = nameInfo.id
            CSResourceMgr.setButtonTextureByNode(player, "UI/CommonFiles/tower_transfer_label_selected_su.png", 
                 "UI/CommonFiles/tower_transfer_label_selected_su.png",  "UI/CommonFiles/tower_transfer_label_selected_su.png")
            CSResourceMgr.setLabelColorByNode(playerName, {r=255,g=252,b=0,a=255})
            editbox_p:setText(nameInfo.name)
            player:performWithDelay(function()
                closePlayerList()
            end,0.2)
            
        end)
    end
    for k,v in pairs(mChatAddList) do
        setPlayer(v)
    end

    for k,v in pairs(allFriendTable) do
        if not mChatAddList[v.friendID] then
            setPlayer({name = v.name,id = v.friendID})
        end
    end
end

function TownChatMgr.setAllFriendTable(mChatFriendTable)
    allFriendTable = mChatFriendTable
end

function TownChatMgr.isHaveFriend(friendInfo)
    for k,v in pairs(allFriendTable) do
        if v.friendID == friendInfo.friendID then
            return true
        end
    end
    return false
end

function TownChatMgr.showPlayerInfoWindow(nameInfo)
    local function loadCSB()
        local page = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameA)
        page:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resNameA, 320,480)

        local title = CSResourceMgr.getNodeByName(resNameA,"title")
        CSResourceMgr.setLabelColorByNode(title, {r=160,g=235,b=250,a=255})
        CSResourceMgr.setLabelStringByNode(title, nameInfo.name, {r=37,g=54,b=75,a=255})

        CSResourceMgr.clickEventBinding(resNameA,"close",function()
            UnblockLoader.cancel("TownChatMgr.showPlayerInfoWindow")
            CSResourceMgr.removeCSObjectByTag(resNameA)
        end)

        local buttonList = {}
        for i=1,7 do
            buttonList[i] = CSResourceMgr.getNodeByName(resNameA,"Button"..i)
            CSResourceMgr.setButtonStringColorByNode(buttonList[i], {r=227,g=233,b=255,a=255})
            CSResourceMgr.setButtonStringByNode(buttonList[i], "playerInfo"..i, {r=0,g=0,b=0,a=255})
        end

        --查看信息按钮
        CSResourceMgr.clickEventBindingByNode(buttonList[1],function()
            PersonalCenterMgr.show(SceneMgr.getRunningScene,nameInfo.id)
            UnblockLoader.cancel("TownChatMgr.showPlayerInfoWindow")
            CSResourceMgr.removeCSObjectByTag(resNameA)
            end)

        --添加好友按钮
        local friendInfo = {friendID = nameInfo.id}
        local addFriendNeedLv = SystemInfo.getGlobalConfigAddInfoByID(21006).values[1]
        if TownChatMgr.isHaveFriend(friendInfo) or CharInfo.getLevel()<addFriendNeedLv then
            CSResourceMgr.setButtonEnabledByNode(buttonList[2], false)
        else
            CSResourceMgr.clickEventBindingByNode(buttonList[2],function()
                FriendsViewMgr.AddFriend(nameInfo.id)
                UnblockLoader.cancel("TownChatMgr.showPlayerInfoWindow")
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
                    HomeInfo.SendInviteEnterHome(nameInfo.id)
                    --print("---------playerInfo.friendID="..tostring(playerNameIdTable[name]))
                end,function()
                        StandardTipsMgr.show(0, "chat12")
                    end)
            end
            UnblockLoader.cancel("TownChatMgr.showPlayerInfoWindow")
            CSResourceMgr.removeCSObjectByTag(resNameA)
        end)

        --邀请家族按钮
        if CharInfo.getFamilyID() then
            CSResourceMgr.clickEventBindingByNode(buttonList[4],function()
                if CharInfo.getFamilyID() == nil or FamilyInfo.GetLocalFamilyInfo() == nil then
                    StandardTipsMgr.show(1, "family10")
                else
                    NetInterface.sendWithBlock("GC_GetFriendDetail_Ack", function()
                        local ChatUserSend = require("src.Net.Send.ChatUserSend")
                        ChatUserSend.sendCG_GetFriendDetail_Req({friendID = nameInfo.id})
                        end,function()
                            local detail = FamilyInfo.GetLastQueryMemberDetailInfo()
                            --print("#############detail="..sz_T2S(detail))
                            if detail ~= nil and detail.nickname == nameInfo.name then
                                if detail.level < SystemInfo.getGlobalConfigAddInfoByID(24005).values[1] then
                                    StandardTipsMgr.show(1, "family12")
                                else
                                    StandardTipsMgr.show(0, "chat12")
                                    FamilyInfo.SendInviteEnterFamily(nameInfo.id)
                                end
                            else
                            StandardTipsMgr.show(1, "family10")
                            end
                        end,function()
                        StandardTipsMgr.show(1, "family10")
                        end)
                end
                UnblockLoader.cancel("TownChatMgr.showPlayerInfoWindow")
                CSResourceMgr.removeCSObjectByTag(resNameA)
            end)
        else
            CSResourceMgr.setButtonEnabledByNode(buttonList[4], false)
        end

        --设为私聊按钮
        CSResourceMgr.clickEventBindingByNode(buttonList[5],function()
            TownChatMgr.setOneChat(nameInfo)
            UnblockLoader.cancel("TownChatMgr.showPlayerInfoWindow")
            CSResourceMgr.removeCSObjectByTag(resNameA)
        end)

        --邀请组队按钮
        local teamID = TeamInfo.getInfo(TeamInfo.KEY_TEAMID)
        if teamID then
            local isCaptain = TeamInfo.getInfo(TeamInfo.KEY_LEADERID)==CharInfo.getCharID()
            if isCaptain then
                CSResourceMgr.clickEventBindingByNode(buttonList[6],function()
                    NetInterface.sendWithBlock("GC_InviteTeamMember_Ack", function()
                        local TeamSend = require("src.Net.Send.TeamSend")
                        TeamSend.sendCG_InviteTeamMember_Req({charID = nameInfo.id})
                        end,function()
                            StandardTipsMgr.show(0, "TeamInvite5")
                        end,function(code)
                            if code == Proto.Error.ERROR_NOTEAM then
                                StandardTipsMgr.show(1, "TeamInvite12")
                            end
                        end)   
                    UnblockLoader.cancel("TownChatMgr.showPlayerInfoWindow")
                    CSResourceMgr.removeCSObjectByTag(resNameA)
                end)
            else
                CSResourceMgr.setButtonEnabledByNode(buttonList[6],false)
            end
        else
            CSResourceMgr.setButtonEnabledByNode(buttonList[6],false)
        end

        --屏蔽按钮
        CSResourceMgr.clickEventBindingByNode(buttonList[7],function()
            TownChatMgr.blockPeople(nameInfo)
            UnblockLoader.cancel("TownChatMgr.showPlayerInfoWindow")
            CSResourceMgr.removeCSObjectByTag(resNameA)
        end)
    end
    local function playCSB()
        CSResourceMgr.playAction(resNameA, 0, 5, false)
    end
    
    local funcTable = {loadCSB, playCSB}
    UnblockLoader.load(funcTable, "TownChatMgr.showPlayerInfoWindow")
end

function TownChatMgr.showBlackNameList()
    local function loadCSB()
        local page = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameB)
        page:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resNameB, 320,480)

        local diff = CocosModuleMgr.getScreenSizeDiff()
        local frame = CSResourceMgr.getNodeByName(resNameB,"frame")
        local fposy = frame:getPositionY()
        frame:setPositionY(fposy-diff)

        local title = CSResourceMgr.getNodeByName(resNameB,"title")
        CSResourceMgr.setLabelColorByNode(title, {r=160,g=235,b=250,a=255})
        CSResourceMgr.setLabelStringByNode(title, "BlackName0", {r=37,g=54,b=75,a=255})

        CSResourceMgr.clickEventBinding(resNameB,"close",function()
            UnblockLoader.cancel("TownChatMgr.showBlackNameList")
            CSResourceMgr.removeCSObjectByTag(resNameB)
        end)
        local list = CSResourceMgr.getNodeByName(resNameB,"blackList")

        CSResourceMgr.setButtonStringColor(resNameB, "close", {r=227,g=233,b=255,a=255})
        CSResourceMgr.setButtonString(resNameB, "close", "BlackName1", "", {r=0,g=0,b=0,a=255})
    end
    local function playCSB()
        CSResourceMgr.playActionWithCallback(resNameB, 0, 5, 1, function()
            TownChatMgr.showBlackPlayers()
        end, "", 0.1)
    end
    local funcTable = {loadCSB,playCSB}
    UnblockLoader.load(funcTable, "TownChatMgr.showBlackNameList")
end

function TownChatMgr.showBlackPlayers()
    local showBlackPlayerTable = {}
    local list = CSResourceMgr.getNodeByName(resNameB,"blackList")
    local blackNum = CSResourceMgr.getNodeByName(resNameB,"num")
    CSResourceMgr.setLabelColorByNode(blackNum, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(blackNum,TownChatMgr.getTableCount(blackNameListTable).."/"..blackMaxNum, {r=0,g=0,b=0,a=255,w=1})
    local function setBlackPlayer(v)
        local player = CSResourceMgr.getNodeByName(resNameB, "blackPlayer"):clone()
        player:setVisible(true)
        local playerName = CSResourceMgr.seekNodeByName(player, "playerName")
        CSResourceMgr.setLabelColorByNode(playerName, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(playerName,v.name, {r=5,g=48,b=84,a=255,w=1})
        local back = CSResourceMgr.seekNodeByName(player, "back")
        back:setColor({r=148,g=169,b=175})
        list:pushBackCustomItem(player)
        local removeBtn = CSResourceMgr.seekNodeByName(player, "removeBtn")
        CSResourceMgr.clickEventBindingByNode(removeBtn,function()
            blackNameListTable[v.id..""] = nil
            local mainBlackNum = CSResourceMgr.getNodeByName(resName,"num")
            CSResourceMgr.setLabelStringByNode(mainBlackNum,TownChatMgr.getTableCount(blackNameListTable).."/"..blackMaxNum, {r=0,g=0,b=0,a=255,w=1})
            UserSettings.set({blacknamelist = blackNameListTable}, 8)
            list:removeAllItems()
            TownChatMgr.showBlackPlayers()
        end)
        CSResourceMgr.setButtonStringColorByNode(removeBtn, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setButtonStringByNode(removeBtn, "BlackName2", {r=62,g=77,b=27,a=255,w=1})
        player:setScaleY(0)
        transition.scaleTo(player, {scale=1, time=0.2})
    end

    for k,v in pairs(blackNameListTable) do
        table.insert(showBlackPlayerTable,function()
             setBlackPlayer(v)
        end)
    end

    UnblockLoader.load(showBlackPlayerTable, "TownChatMgr.showBlackPlayers")
end

function TownChatMgr.addUIInMain()
    TownChatMgr.addUI()
    CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resName), "up")
    if SceneMgr.currentScene=="MainScene" then
        WorldMapAwardsMgr.setVisibleEx(false)
    end
end

function TownChatMgr.onMessageNtf(channel,name,concent,charIDTo,charIDFrom)
    if blackNameListTable[charIDFrom] or blackNameListTable[charIDTo] then
        return
    end

    local isHomeChannel = false
    if string.sub(channel, 1, 5) == "Home_" then
        isHomeChannel = true
    end

    local state = 0
    if channel == channelTable[3] then
        state = 3
    elseif string.sub(channel, 1, 7) == "family_" then
        state = 4
    elseif channel == channelTable[5] then
        state = 5
    elseif channel == channelTable[6] or isHomeChannel then
        state = 6
    elseif channel == channelTable[7] then
        state = 7
    end

    local nameInfo = {name = name,id = tonumber(charIDFrom)}
    if state==5 and charIDTo ~= tostring(CharInfo.getCharID()) then
        nameInfo.name = mChatName
    end

    local cjson = require("cjson")
    local tbl = cjson.decode(concent)
    tbl.charID = charIDFrom
    if tbl.nickname and tbl.posx and tbl.mapres then
        --是城镇玩家移动信息
        TownPlayerMgr.addPlayerWithRes(tbl)
    	return
    elseif tbl.startP and tbl.endP and tbl.mapid then
        --是地图玩家移动信息
        WorldPlayerMgr.addPlayer(tbl)
        return
    end
    local text = ""
    local textShare = ""
    if tbl.textType == "text" then
        text = tbl.concent
    elseif tbl.textType == "battleResult" then
        TownChatMgr.battleEndResult(tbl.winner,tbl.loser,tbl.cupLv)
        return
    else
        text = ""
    end

    if text~="" and state~=5 then
        local str = ChatMsgMgr.chatMessageProcessor(name, text, state, tbl.cupLv)
        TownChatMgr.addChatMessage(str, state,false,nameInfo)
        if isHomeChannel == false then
            if state==6 and SceneMgr.currentScene~="MainScene" then
                local msg = ChatMsgMgr.chatMessageProcessor("", text, state, tbl.cupLv)
                if SceneMgr.currentScene == "TownScene" or  SceneMgr.currentScene == "LabScene" or SceneMgr.currentScene == "StarScene"
                    or SceneMgr.currentScene == "HomeScene" then
                    if charIDFrom == tostring(CharInfo.getCharID()) then
                        ChatBubbleMgr.showChatBubble(msg)
                    else
                        ChatBubbleMgr.showChatBubble(msg, name, charIDFrom)
                    end
                end
            end
        else
            local msg = ChatMsgMgr.chatMessageProcessor("", text, state, tbl.cupLv)
            if SceneMgr.currentScene == "TownScene" or  SceneMgr.currentScene == "LabScene" or SceneMgr.currentScene == "StarScene"
                or SceneMgr.currentScene == "HomeScene" then
                if charIDFrom == tostring(CharInfo.getCharID()) then
                    ChatBubbleMgr.showChatBubble(msg)
                else
                    ChatBubbleMgr.showChatBubble(msg, name, charIDFrom)
                end
            end
        end
        DebugInfoMgr.debugChat(text)
    elseif text~="" and state==5 then
        if charIDTo == tostring(CharInfo.getCharID()) then
            local str = ChatMsgMgr.chatMessageProcessor(CocosModuleMgr.createStringWithFormat({"chat11", name}), 
            text, state, tbl.cupLv)
            TownChatMgr.addChatMessage(str, state,false,nameInfo)
        else
            local str = ChatMsgMgr.chatMessageProcessor(CocosModuleMgr.createStringWithFormat({"chat10", mChatName}), 
            text, state, tbl.cupLv)
            TownChatMgr.addChatMessage(str, state,false,nameInfo)
        end
    else
        if state~=5 then
            local str = ChatMsgMgr.chatMessageProcessor(name, text, state, tbl.cupLv)
            TownChatMgr.addChatMessage(str, state,false,nameInfo,tbl)
        else
            if charIDTo == tostring(CharInfo.getCharID()) then
                local str = ChatMsgMgr.chatMessageProcessor(CocosModuleMgr.createStringWithFormat({"chat11", name}), 
                text, state, tbl.cupLv)
                TownChatMgr.addChatMessage(str, state,false,nameInfo,tbl)
            else
                local str = ChatMsgMgr.chatMessageProcessor(CocosModuleMgr.createStringWithFormat({"chat10", mChatName}), 
                text, state, tbl.cupLv)
                TownChatMgr.addChatMessage(str, state,false,nameInfo,tbl)
            end
        end
    end
end

--发送目标切换按钮
function TownChatMgr.changeSendStatus(status)
    if status == 3 then
        CSResourceMgr.getNodeByName(resName,"voiceBtn"):setVisible(false)
    else
        CSResourceMgr.getNodeByName(resName,"voiceBtn"):setVisible(true)
    end
    CSResourceMgr.setButtonStringColor(resName, "tabbtn", tab_color[status])
    CSResourceMgr.setButtonString(resName, "tabbtn", 
        ChatMsgMgr.SubUTF8String(LuaSqlite.getLanguageByKey("chat"..status), LuaSqlite.LANG_TYPE ~= 1 and 1 or 3), "", {r=0,g=0,b=0,a=255})
    if SceneMgr.currentScene == "HomeScene" and TownChatMgr.list_status == 6 then
        CSResourceMgr.setButtonString(resName, "tabbtn", 
            ChatMsgMgr.SubUTF8String(LuaSqlite.getLanguageByKey("chat14"), LuaSqlite.LANG_TYPE ~= 1 and 1 or 3), "", {r=0,g=0,b=0,a=255})
    end
    if TownChatMgr.list_status == 4 then
        CSResourceMgr.setButtonString(resName, "tabbtn", 
            ChatMsgMgr.SubUTF8String(LuaSqlite.getLanguageByKey("chat15"), LuaSqlite.LANG_TYPE ~= 1 and 1 or 3), "", {r=0,g=0,b=0,a=255})
    end

    local MBtn = CSResourceMgr.getNodeByName(resName,"MBtn")

    local chattab = CSResourceMgr.getNodeByName(resName,"chattab")
    if TownChatMgr.send_status==5 then
        editbox_p:setVisible(true)
        editbox_m:setVisible(true)
        editbox:setVisible(false)
        chattab:setContentSize(190, 50)
        chattab:setPositionX(170)
        -- editbox_p:setText("")
        MBtn:setVisible(true)
        CSResourceMgr.clickEventBindingByNode(MBtn, function()
            TownChatMgr.hideEmojiPanel(false)
            TownChatMgr.OpenPlayerList()
        end)
    else
        editbox_p:setVisible(false)
        editbox_m:setVisible(false)
        editbox:setVisible(true)
        if status == 3 then
            chattab:setContentSize(440, 50)
            chattab:setPositionX(295)
            editbox:setContentSize(375,45)
            editbox:setPosition(315,437)
        else
            chattab:setContentSize(390, 50)
            chattab:setPositionX(270)
            editbox:setContentSize(320,45)
            editbox:setPosition(288,437)
        end
        MBtn:setVisible(false)
        CSResourceMgr.clickEventBindingByNode(MBtn, function()
        end)
    end
end

--分页切换按钮
function TownChatMgr.tabButtonDisable(type)
    local enable_tbl = {true, true, true, true, true, true,true}
    enable_tbl[type] = false
    for var=1, #enable_tbl do
        CSResourceMgr.setButtonEnabled(resName, "btn_"..tab_string[var], enable_tbl[var])
        local btn = CSResourceMgr.getNodeByName(resName, "btn_"..tab_string[var])
        if enable_tbl[var] then
            btn:setLocalZOrder(0)
            btn:setScale(1)
            btn:setPositionY(378.5)
        else
            btn:setLocalZOrder(2)
            btn:setScale(1.1)
            btn:setPositionY(383.5)
        end
    end
end

function TownChatMgr.changeTab(key)
    GameAudio.playUISound("sheetClick")
    TownChatMgr.tabButtonDisable(key)
    TownChatMgr.list_status = key
    UserSettings.set({listTag = TownChatMgr.list_status}, 8)
    TownChatMgr.setNewMarkVisibleByType(key, false)
    reLoadMsg()
    TownChatMgr.refreshTabsColor()
    TownChatMgr.send_status = TownChatMgr.list_status
    TownChatMgr.changeSendStatus(TownChatMgr.send_status)
    UserSettings.set({sendTag = TownChatMgr.send_status}, 8)
    curVoiceSprite = nil
end

--进入频道
function TownChatMgr.changeChannel(callback)
    if not NetInterface.isConnect or CharInfo.getCharID()==0 then
            return
        end
    channelIndex = channelIndex + 1
    channelTable[6] = "zhucheng_"..channelIndex
    print(channelTable[6])
    NetInterface.sendWithBlock("GC_ChangeChannel_Ack", function()
        local ChatSend = require("src.Net.Send.ChatSend")
        ChatSend.sendCG_ChangeChannel_Req({channel = channelTable[6],data = "{}"})
        currentChannel = channelTable[6]
    end, function()
    	if callback then
    		callback()
    	end
    end, function(code)
        if callback then
            callback()
        end
        if code == Proto.Error.ERROR_CHANNEL_MAX then
            TownChatMgr.changeChannel()
        else
            TipsMgr.showError(nil, code)
        end
    end) 
end

function TownChatMgr.getTableCount(table)
    local i = 0
    for k,v in pairs(table) do
        i = i + 1
    end
    return i
end

function TownChatMgr.showSharePets()
    local function close()
        UnblockLoader.cancel("TownChatMgr.showSharePets")
        CSResourceMgr.removeList(resNameC, "list")
        CSResourceMgr.removeCSObjectByTag(resNameC)
        GameAudio.playUISound("retract")
        HighPerformList.resetAllSchedule()
    end
    local function loadCSB()
        local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameC)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameC, 320, 480)
        layer:setVisible(false)

        local title = CSResourceMgr.getNodeByName(resNameC,"title")
        CSResourceMgr.setLabelColorByNode(title, {r=160,g=235,b=250,a=255})
        CSResourceMgr.setLabelStringByNode(title, "TownShare4", {r=37,g=54,b=75,a=255})
        CSResourceMgr.clickEventBinding(resNameC,"close",function()
            close()
        end)
    end
    local function loadPetList()
        local allpets = PetListMgr.sortPetList(PokemonInfo.getAllPets())
        local list = CSResourceMgr.getNodeByName(resNameC, {"db","list"})
        local panel = CSResourceMgr.getNodeByName(resNameC, {"panel"})
        local item = CSResourceMgr.getNodeByName(resNameC, {"panel","btn"})
        local totalLine = math.ceil(#allpets / PetCommonListViewMgr.ROW)
        local diffX = 124
        local panelNodes = {}

        local function petFunc(parent,row,v,index)
            -- local petNode = BattleFuncMgr.createPetCardWithBlood_older(v,"CommonListPet"..index,true)
            local petNode = BattleFuncMgr.startCreatePetCard(v,3,true)
            petNodes[index] = petNode.button
            petNodes[index]:setVisible(false)
            petNodes[index]:setScale(1.35, 1.35)
            petNodes[index]:addTo(parent)
            petNodes[index]:setPositionX(petNodes[index]:getPositionX() + (row - 1) * diffX + 72)
            petNodes[index]:setPositionY(90)
            CSResourceMgr.clickEventBindingByNode(petNodes[index], function ()
				if CharInfo.get().recharge.totalMoney == nil then 
					rechargeTotal = 0
				else
					rechargeTotal = CharInfo.get().recharge.totalMoney
				end
				if (TownChatMgr.send_status==3 or TownChatMgr.send_status==6 or TownChatMgr.send_status==5 )and rechargeTotal < 100 then
					StandardTipsMgr.show(1, "CantSendMsg1")
					return
				end
                --世界发言间隔5分钟10条
                if TownChatMgr.send_status==3 then
                    if #worldChatTimeTable<3 then
                        table.insert(worldChatTimeTable,CharInfo.getServerTime())
                    elseif CharInfo.getServerTime()-(worldChatTimeTable[1] or 0)>15 and #worldChatTimeTable==3 then
                        table.remove(worldChatTimeTable, 1)
                        table.insert(worldChatTimeTable,CharInfo.getServerTime())
                    else
                        StandardTipsMgr.show(1, "CantSendMsg4")
                        return
                    end
                end
                v.personName = PetEducationMgr.getPetName(v)
                local textTable = {textType = "pet",petInfo = v,cupLv = CharInfo.get().pvparenagrade or 0}
                local cjson = require("cjson")
                local str = json.encode(textTable)
                local text_p = editbox_p:getText()
                TownChatMgr.hideEmojiPanel(false)
                if TownChatMgr.send_status~=5 then
                    if TownChatMgr.send_status==4 then
                        local familyID = CharInfo.getFamilyID()
                        if familyID ~= nil then
                            channelTable[TownChatMgr.send_status] = "family_"..tostring(familyID)
                        else
                            StandardTipsMgr.show(1, "CantSendMsg3")
                            print("没有家族")
                            close()
                            return
                        end
                    end
                    NetInterface.sendWithBlock("GC_Chat_Ack", function()
                        local ChatSend = require("src.Net.Send.ChatSend")
                        ChatSend.sendCG_Chat_Req({charID = "",channel = channelTable[TownChatMgr.send_status],concent =str})
                        end)
                elseif TownChatMgr.send_status==5 then
                    if text_p=="" then
                        StandardTipsMgr.show(1, "CantSendMsg2")
                        return
                    end
                    NetInterface.sendWithBlock("GC_Chat_Ack", function()
                        local ChatSend = require("src.Net.Send.ChatSend")
                        ChatSend.sendCG_Chat_Req({charID = mChatID,channel = "",concent =str})
                        end)
                    mChatName = text_p
                end
                close()
            end,3)
            petNodes[index]:setVisible(true)
            petNodes[index]:setScale(1.35)
        end

        local spawncount = 4
        local countperline = 4
        local allnum = countperline*spawncount
        if totalLine>spawncount then
            totalLine=spawncount 
        end
        for i = 1, totalLine do
            panelNodes[i] = panel:clone()
            local back = CSResourceMgr.seekNodeByName(panelNodes[i], "back")
            back:setVisible(true)
            back:setColor({r=23,g=46,b=59})
            list:pushBackCustomItem(panelNodes[i]) 
        end
        local index = 1
        for k,v in pairs(allpets) do
            if index>allnum then break end
            local line = math.ceil(index / PetCommonListViewMgr.ROW)
            local row = index % PetCommonListViewMgr.ROW == 0 and PetCommonListViewMgr.ROW or index % PetCommonListViewMgr.ROW
            petFunc(panelNodes[line],row,v,index)
            index = index + 1
        end
        HighPerformList.makeHighPerFormVerticalList(list,spawncount,0,countperline,190,180,allpets,
                function(item,currentindex)
                    item:removeAllChildren()
                    for j=1,countperline do 
                        local petInfo = allpets[currentindex+j-1]
                        if petInfo then 
                            petFunc(item,j,petInfo,currentindex)
                        end
                    end
                    BattleFuncMgr.endCreatePetCard()
                end)  

        if totalLine < 3 then
            for i=1,3-totalLine do
                local panelClone = panel:clone()
                local back = CSResourceMgr.seekNodeByName(panelClone, "back")
                back:setVisible(true)
                back:setColor({r=23,g=46,b=59})
                list:pushBackCustomItem(panelClone) 
            end
        end
        BattleFuncMgr.endCreatePetCard()
    end
    function loadListAction()
        CSResourceMgr.getCsbObj(resNameC):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resNameC, "db"), "down")
        GameAudio.playUISound("popup")
    end
    local funcTable = {loadCSB, loadPetList, loadListAction}
    UnblockLoader.load(funcTable,"TownChatMgr.showSharePets")
end

function TownChatMgr.showShareItems()
    local itemNum = BagViewMgr.refreshItemInfo()
    local function close()
        UnblockLoader.cancel("TownChatMgr.showShareItems")
        CSResourceMgr.removeList(resNameC, "list")
        CSResourceMgr.removeCSObjectByTag(resNameC)
        GameAudio.playUISound("retract")
        HighPerformList.resetAllSchedule()
    end

    local function loadCSB()
        local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameC)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameC, 320, 480)
        layer:setVisible(false)

        local title = CSResourceMgr.getNodeByName(resNameC,"title")
        CSResourceMgr.setLabelColorByNode(title, {r=160,g=235,b=250,a=255})
        CSResourceMgr.setLabelStringByNode(title, "TownShare5", {r=37,g=54,b=75,a=255})
        CSResourceMgr.clickEventBinding(resNameC,"close",function()
            close()
        end)
    end
    local function loadItemList()
        labelTable = {}
        buttonTable = {}
        local panelTable = {}
        local list = CSResourceMgr.getNodeByName(resNameC, "list")
        CSResourceMgr.removeListByNode(list)
        local bagInfo = BagViewMgr.getBagInfo()
        local allBagInfo = bagInfo[1]

        local function itemFunc(parent,rank,bagItemInfo,i)
            local label = CSResourceMgr.seekNodeByName(parent, "l"..rank)
            if bagItemInfo[2]==1 then
                CSResourceMgr.setLabelStringByNode(label, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            elseif bagItemInfo[2]>999 then
                CSResourceMgr.setLabelStringByNode(label, "999+", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            else
                CSResourceMgr.setLabelStringByNode(label, bagItemInfo[2], CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            end
            labelTable[bagItemInfo[1]] = label
            local sprite = CSResourceMgr.seekNodeByName(parent, "s"..rank)
            local iconpath = ItemInfo.getItemInfoById(bagItemInfo[1]).icon
            CSResourceMgr.setButtonTextureByNode(sprite, iconpath, iconpath, iconpath)
            sprite:setScale(1)
            -- sprite:setScale(0, 0)
            -- sprite:setRotation(180)
            -- transition.scaleTo(sprite, {scale = 1, time = 0.2})
            -- transition.rotateTo(sprite, {rotate = 360, time = 0.2})
            local diban = CSResourceMgr.seekNodeByName(parent, "b"..rank)
            local btnRes = ItemInfo.getItemRareBGImage(bagItemInfo[1])
            CSResourceMgr.setButtonTextureByNode(diban, btnRes, btnRes, btnRes)
            CSResourceMgr.clickEventBindingByNode(diban, function()
				if (TownChatMgr.send_status==3 or TownChatMgr.send_status==6 or TownChatMgr.send_status==5 )and rechargeTotal < 100 then
                    StandardTipsMgr.show(1, "CantSendMsg1")
                    return
                end
                --世界发言间隔5分钟10条
                if TownChatMgr.send_status==3 then
                    if #worldChatTimeTable<3 then
                        table.insert(worldChatTimeTable,CharInfo.getServerTime())
                    elseif CharInfo.getServerTime()-(worldChatTimeTable[1] or 0)>15 and #worldChatTimeTable==3 then
                        table.remove(worldChatTimeTable, 1)
                        table.insert(worldChatTimeTable,CharInfo.getServerTime())
                    else
                        StandardTipsMgr.show(1, "CantSendMsg4")
                        return
                    end
                end
                local textTable = {textType = "item",itemInfo = {id = bagItemInfo[1],sum = bagItemInfo[2]},cupLv = CharInfo.get().pvparenagrade or 0}
                local cjson = require("cjson")
                local str = json.encode(textTable)
                local text_p = editbox_p:getText()
                TownChatMgr.hideEmojiPanel(false)
                if TownChatMgr.send_status~=5 then
                    if TownChatMgr.send_status==4 then
                        local familyID = CharInfo.getFamilyID()
                        if familyID ~= nil then
                            channelTable[TownChatMgr.send_status] = "family_"..tostring(familyID)
                        else
                            StandardTipsMgr.show(1, "CantSendMsg3")
                            print("没有家族")
                            close()
                            return
                        end
                    end
                    NetInterface.sendWithBlock("GC_Chat_Ack", function()
                        local ChatSend = require("src.Net.Send.ChatSend")
                        ChatSend.sendCG_Chat_Req({charID = "",channel = channelTable[TownChatMgr.send_status],concent =str})
                        end)
                elseif TownChatMgr.send_status==5 then
                    if text_p=="" then
                        StandardTipsMgr.show(1, "CantSendMsg2")
                        return
                    end
                    NetInterface.sendWithBlock("GC_Chat_Ack", function()
                        local ChatSend = require("src.Net.Send.ChatSend")
                        ChatSend.sendCG_Chat_Req({charID = mChatID,channel = "",concent =str})
                        end)
                    mChatName = text_p
                end
                close()
            end,3)

            -- diban:setScale(0, 0)
            diban:setVisible(true)
            -- transition.scaleTo(diban, {scale = 1, time = 0.1})
            buttonTable[bagItemInfo[1]] = diban
        end

        local spawncount = 6
        local countperline = 5
        local allnum = countperline*spawncount
        for i=1, #allBagInfo do
            if i>allnum then break end
            local row = math.ceil(i/5)
            local rank = i%5
            if rank==0 then
                rank = 5
            end
            if rank==1 then
                local panel = CSResourceMgr.getNodeByName(resNameC, "panel2"):clone()
                local back = CSResourceMgr.seekNodeByName(panel, "back")
                back:setVisible(true)
                back:setColor({r=23,g=46,b=59})
                table.insert(panelTable, panel)
                list:pushBackCustomItem(panel)
                list:performWithDelay(function()
                    list:jumpToTop()
                end, 0.1)
            end
            local bagItemInfo = allBagInfo[i]

            itemFunc(panelTable[row],rank,bagItemInfo,i)
        end

        local spawncount = 6
        local countperline = 5
        HighPerformList.makeHighPerFormVerticalList(list,spawncount,10,countperline,110,100,allBagInfo,
                function(item,currentindex)
                    for j=1,countperline do 
                        local bagItemInfo = allBagInfo[currentindex+j-1]
                        local diban = CSResourceMgr.seekNodeByName(item, "b"..j)
                        if bagItemInfo == nil then 
                            diban:setVisible(false)
                        else
                            diban:setVisible(true)
                            itemFunc(item,j,bagItemInfo,currentindex)
                        end
                    end
                end) 

        local maxRow = math.ceil(#allBagInfo/5)
        if maxRow < 4 then
            for i=1,4-maxRow do
                local panel = CSResourceMgr.getNodeByName(resNameC, "panel2"):clone()
                local back = CSResourceMgr.seekNodeByName(panel, "back")
                back:setVisible(true)
                back:setColor({r=23,g=46,b=59})
                list:pushBackCustomItem(panel)
                list:performWithDelay(function()
                    list:jumpToTop()
                end, 0.1)
            end
        end  
    end
    local function loadAction()
        CSResourceMgr.getCsbObj(resNameC):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resNameC, "db"), "down")
        GameAudio.playUISound("popup")
    end
    local funcTable = {loadCSB, loadItemList, loadAction}
    UnblockLoader.load(funcTable,"TownChatMgr.showShareItems")
end

-- 排序规则：分页>品质>ID
function BagViewMgr.sortSkillBook(skillBooks)
    table.sort(skillBooks, function(a, b)
        local aID = a[1]
        local bID = b[1]
       local aRare = ItemInfo.getItemInfoById(a[1]).itemRare
       local bRare = ItemInfo.getItemInfoById(b[1]).itemRare
        if aRare ~= bRare then
            return aRare > bRare
        else
            if aID ~= bID then
                return bID > aID
            end
        end
    end)
    return skillBooks
end

function TownChatMgr.showShareSkillBooks()
    local skillBookInfo = ItemInfo.getSkillBookInfo()
    local skillBookTable = {}
    for k,v in pairs(skillBookInfo) do
        if v~=0 then
            table.insert(skillBookTable,{k,v})
        end
    end
    skillBookTable = BagViewMgr.sortSkillBook(skillBookTable)
    local function close()
        UnblockLoader.cancel("TownChatMgr.showShareSkillBooks")
        CSResourceMgr.removeList(resNameC, "list")
        CSResourceMgr.removeCSObjectByTag(resNameC)
        GameAudio.playUISound("retract")
        HighPerformList.resetAllSchedule()
    end

    local function loadCSB()
        local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameC)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameC, 320, 480)
        layer:setVisible(false)

        local title = CSResourceMgr.getNodeByName(resNameC,"title")
        CSResourceMgr.setLabelColorByNode(title, {r=160,g=235,b=250,a=255})
        CSResourceMgr.setLabelStringByNode(title, "TownShare6", {r=37,g=54,b=75,a=255})
        CSResourceMgr.clickEventBinding(resNameC,"close",function()
            close()
        end)
    end
    local function loadItemList()
        labelTable = {}
        buttonTable = {}
        local panelTable = {}
        local list = CSResourceMgr.getNodeByName(resNameC, "list")
        CSResourceMgr.removeListByNode(list)

        local function itemFunc(parent,rank,bagItemInfo,i)
            local label = CSResourceMgr.seekNodeByName(parent, "l"..rank)
            if bagItemInfo[2]==1 then
                CSResourceMgr.setLabelStringByNode(label, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            elseif bagItemInfo[2]>999 then
                CSResourceMgr.setLabelStringByNode(label, "999+", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            else
                CSResourceMgr.setLabelStringByNode(label, bagItemInfo[2], CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            end
            labelTable[bagItemInfo[1]] = label
            local sprite = CSResourceMgr.seekNodeByName(parent, "s"..rank)
            local iconpath = ItemInfo.getItemInfoById(bagItemInfo[1]).icon
            CSResourceMgr.setButtonTextureByNode(sprite, iconpath, iconpath, iconpath)
            sprite:setScale(1)
            -- sprite:setScale(0, 0)
            -- sprite:setRotation(180)
            -- transition.scaleTo(sprite, {scale = 1, time = 0.2})
            -- transition.rotateTo(sprite, {rotate = 360, time = 0.2})
            local diban = CSResourceMgr.seekNodeByName(parent, "b"..rank)
            local btnRes = ItemInfo.getItemRareBGImage(bagItemInfo[1])
            CSResourceMgr.setButtonTextureByNode(diban, btnRes, btnRes, btnRes)
            CSResourceMgr.longtouchEventBindingByNode(diban, function()
                ItemInfoViewMgr.show({id = bagItemInfo[1], sum = bagItemInfo[2],type = 1,objID = 0},false)
            end,function()
				if (TownChatMgr.send_status==3 or TownChatMgr.send_status==6 or TownChatMgr.send_status==5 )and rechargeTotal < 100 then
                    StandardTipsMgr.show(1, "CantSendMsg1")
                    return
                end
                --世界发言间隔5分钟10条
                if TownChatMgr.send_status==3 then
                    if #worldChatTimeTable<3 then
                        table.insert(worldChatTimeTable,CharInfo.getServerTime())
                    elseif CharInfo.getServerTime()-(worldChatTimeTable[1] or 0)>15 and #worldChatTimeTable==3 then
                        table.remove(worldChatTimeTable, 1)
                        table.insert(worldChatTimeTable,CharInfo.getServerTime())
                    else
                        StandardTipsMgr.show(1, "CantSendMsg4")
                        return
                    end
                end
                local textTable = {textType = "item",itemInfo = {id = bagItemInfo[1],sum = bagItemInfo[2]},cupLv = CharInfo.get().pvparenagrade or 0}
                local cjson = require("cjson")
                local str = json.encode(textTable)
                local text_p = editbox_p:getText()
                TownChatMgr.hideEmojiPanel(false)
                if TownChatMgr.send_status~=5 then
                    if TownChatMgr.send_status==4 then
                        local familyID = CharInfo.getFamilyID()
                        if familyID ~= nil then
                            channelTable[TownChatMgr.send_status] = "family_"..tostring(familyID)
                        else
                            StandardTipsMgr.show(1, "CantSendMsg3")
                            print("没有家族")
                            close()
                            return
                        end
                    end
                    NetInterface.sendWithBlock("GC_Chat_Ack", function()
                        local ChatSend = require("src.Net.Send.ChatSend")
                        ChatSend.sendCG_Chat_Req({charID = "",channel = channelTable[TownChatMgr.send_status],concent =str})
                        end)
                elseif TownChatMgr.send_status==5 then
                    if text_p=="" then
                        StandardTipsMgr.show(1, "CantSendMsg2")
                        return
                    end
                    NetInterface.sendWithBlock("GC_Chat_Ack", function()
                        local ChatSend = require("src.Net.Send.ChatSend")
                        ChatSend.sendCG_Chat_Req({charID = mChatID,channel = "",concent =str})
                        end)
                    mChatName = text_p
                end
                close()
            end)

            -- diban:setScale(0, 0)
            diban:setVisible(true)
            -- transition.scaleTo(diban, {scale = 1, time = 0.1})
            buttonTable[bagItemInfo[1]] = diban
        end

        local spawncount = 6
        local countperline = 5
        local allnum = countperline*spawncount
        for i=1, #skillBookTable do
            if i>allnum then break end
            local row = math.ceil(i/5)
            local rank = i%5
            if rank==0 then
                rank = 5
            end
            if rank==1 then
                local panel = CSResourceMgr.getNodeByName(resNameC, "panel2"):clone()
                local back = CSResourceMgr.seekNodeByName(panel, "back")
                back:setVisible(true)
                back:setColor({r=23,g=46,b=59})
                table.insert(panelTable, panel)
                list:pushBackCustomItem(panel)
                list:performWithDelay(function()
                    list:jumpToTop()
                end, 0.1)
            end

            local bagItemInfo = skillBookTable[i]

            itemFunc(panelTable[row],rank,bagItemInfo,i)
        end

        local spawncount = 6
        local countperline = 5
        HighPerformList.makeHighPerFormVerticalList(list,spawncount,10,countperline,110,100,skillBookTable,
                function(item,currentindex)
                    for j=1,countperline do 
                        local bagItemInfo = skillBookTable[currentindex+j-1]
                        local diban = CSResourceMgr.seekNodeByName(item, "b"..j)
                        if bagItemInfo == nil then 
                            diban:setVisible(false)
                        else
                            diban:setVisible(true)
                            itemFunc(item,j,bagItemInfo,currentindex)
                        end
                    end
                end) 

        local maxRow = math.ceil(#skillBookTable/5)
        if maxRow < 4 then
            for i=1,4-maxRow do
                local panel = CSResourceMgr.getNodeByName(resNameC, "panel2"):clone()
                local back = CSResourceMgr.seekNodeByName(panel, "back")
                back:setVisible(true)
                back:setColor({r=23,g=46,b=59})
                list:pushBackCustomItem(panel)
                list:performWithDelay(function()
                    list:jumpToTop()
                end, 0.1)
            end
        end  
    end
    local function loadAction()
        CSResourceMgr.getCsbObj(resNameC):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resNameC, "db"), "down")
        GameAudio.playUISound("popup")
    end
    local funcTable = {loadCSB, loadItemList, loadAction}
    UnblockLoader.load(funcTable,"TownChatMgr.showShareSkillBooks")
end

function TownChatMgr.GetChannelTable()
    return channelTable
end

function TownChatMgr.GetCurrentChannel()
    return currentChannel
end

function TownChatMgr.showChatView(show)
    local clayer = CSResourceMgr.getCsbObj(resName)
    if not clayer then
        return
    end
    if show then
        if isShowChat then
            return
        end
        GameAudio.playUISound("messagePopup")
        clayer:setPositionY(chatViewPosY)
        CocosModuleMgr.showUIAnimation(clayer, "up")
        if isInMain then
            BasicMenuMgr.setChatBtnEnable(false)
        end
        isShowChat = true
    elseif isShowChat then
        GameAudio.playUISound("messageRetract")
        TownChatMgr.hideEmojiPanel(false)
        chatViewPosY = clayer:getPositionY()
        transition.moveTo(clayer, {y=-506, time=0.2})
        if isInMain then
            BasicMenuMgr.setChatBtnEnable(true)
        end
        isShowChat = false
    end
    if SceneMgr.currentScene=="MainScene" then
        WorldMapAwardsMgr.setVisibleEx(not show)
    end
end

function TownChatMgr.setOneChat(nameInfo)
    if not mChatAddList[nameInfo.id] then 
        mChatAddList[nameInfo.id] = nameInfo
    end
    mChatID = nameInfo.id
    TownChatMgr.changeTab(5)
    editbox_p:setText(nameInfo.name)
end

function TownChatMgr.blockPeople(nameInfo)
    if not blackNameListTable[nameInfo.id..""] then 
        blackNameListTable[nameInfo.id..""] = nameInfo
    end
    local mainBlackNum = CSResourceMgr.getNodeByName(resName,"num")
    CSResourceMgr.setLabelStringByNode(mainBlackNum,TownChatMgr.getTableCount(blackNameListTable).."/"..blackMaxNum, {r=0,g=0,b=0,a=255,w=1})
    UserSettings.set({blacknamelist = blackNameListTable}, 8)
end

function TownChatMgr.isTeamChat(bool)
    if bool then
        CSResourceMgr.getNodeByName(resName, "btn_"..tab_string[7]):setVisible(true)
        CSResourceMgr.getNodeByName(resName, "btn_"..tab_string[6]):setVisible(false)
        TownChatMgr.changeTab(7)
        local teamID = TeamInfo.getInfo(TeamInfo.KEY_TEAMID)
        if teamID then
            channelTable[7] = "team_"..teamID
            NetInterface.sendWithBlock("GC_ChangeChannel_Ack", function()
                local ChatSend = require("src.Net.Send.ChatSend")
                ChatSend.sendCG_ChangeChannel_Req({channel = channelTable[7],data = "{}"})
            end)
        end
    else
        channelTable[7] = "team_"
        CSResourceMgr.getNodeByName(resName, "btn_"..tab_string[7]):setVisible(false)
        CSResourceMgr.getNodeByName(resName, "btn_"..tab_string[6]):setVisible(true)
        if TownChatMgr.send_status==7 then
            TownChatMgr.changeTab(6)
        end
        NetInterface.sendWithBlock("GC_ChangeChannel_Ack", function()
            local ChatSend = require("src.Net.Send.ChatSend")
            ChatSend.sendCG_ChangeChannel_Req({channel = channelTable[6],data = "{}"})
        end)
    end
end

function TownChatMgr.teamBattleChat(bool)
    local clayer = CSResourceMgr.getCsbObj(resName)
    if not clayer then
        return
    end
    local list = CSResourceMgr.getNodeByName(resName, "list")
    local teamChatBack = CSResourceMgr.getNodeByName(resName, "teamChatBack")
    local diff, edgeDiff = TownChatMgr.getScreenSizeDiff()
    if bool then
        list:setTouchEnabled(false)
        teamChatBack:setVisible(true)
        local send_diban = CSResourceMgr.getNodeByName(resName, "send_diban")
        transition.moveTo(list, {y=send_diban:getPositionY()+send_diban:getContentSize().height/2+listSize.height/2,time=0})
        transition.moveTo(teamChatBack, {y=send_diban:getPositionY()+send_diban:getContentSize().height/2+listSize.height/2,time=0})
        transition.moveBy(clayer, {y=-listSize.height-46+94, time=0})
        TownChatMgr.setVoiceDiff(-listSize.height-46+94)
        list:setContentSize({width=listInnerSize.width, height=listInnerSize.height/2})
        teamChatBack:setContentSize({width=teamBackSize.width, height=teamBackSize.height/2})
        battleChatMode = true
    else
        list:setTouchEnabled(true)
        teamChatBack:setVisible(false)
        CocosModuleMgr.setEdgeDistance(clayer, nil, nil, nil, edgeDiff)
        local lt_bg = CSResourceMgr.getNodeByName(resName, "lt_bg")
        transition.moveTo(list, {y=listPosY,time=0})
        transition.moveTo(teamChatBack, {y=lt_bg:getPositionY()+listSize.height/4,time=0}) 
        list:setContentSize({width=listInnerSize.width, height=listInnerSize.height})
        teamChatBack:setContentSize({width=teamBackSize.width, height=teamBackSize.height})
        TownChatMgr.setVoiceDiff(0)
    end
end

function TownChatMgr.showBattleChat(show)
    local clayer = CSResourceMgr.getCsbObj(resName)
    if not clayer then
        return
    end
    local list = CSResourceMgr.getNodeByName(resName, "list")
    if show then
        transition.moveBy(clayer, {y=list:getContentSize().height+28, time=0.2})
        isShowChat = true
    elseif isShowChat then
        transition.moveBy(clayer, {y=-list:getContentSize().height-28, time=0.2})
        isShowChat = false
        list:jumpToTop()
    end
end

function TownChatMgr.addChatIcon(node,fbType)--fbType: 1:组队副本 2:家族副本
    local page = CSResourceMgr.createRes(node, resNameD)
    CSResourceMgr.setRelativePosition(resNameD, 320,480)
    CocosModuleMgr.setEdgeDistance(page, nil, nil, nil, 0)

    if SceneMgr.currentScene=="TownScene" or SceneMgr.currentScene=="LabScene" or SceneMgr.currentScene == "StarScene" then
        BasicMenuMgr.setChatBtnEnable(false)
        isShowChat = true
    else
        BasicMenuMgr.setChatBtnEnable(true)
        isShowChat = false
    end

    CSResourceMgr.clickEventBinding(resNameD, "chat", function()
        if not fbType then
            if not CSResourceMgr.getCsbObj("UI/Chat/TownChatLayer.csb") then
                TownChatMgr.addUIInMain()
                TownChatMgr.changeStatus(1)
                GameAudio.playUISound("messagePopup")
            else
                TownChatMgr.showChatView(true)
            end
        elseif fbType == 1 then
            if not CSResourceMgr.getCsbObj("UI/Chat/TownChatLayer.csb") then
                TownChatMgr.addUIInMain()
                TownChatMgr.changeStatus(1)
                TownChatMgr.changeTab(7)
                GameAudio.playUISound("messagePopup")
                TownChatMgr.teamBattleChat(true)
            else
                TownChatMgr.showBattleChat(true)
            end
        end
        BasicMenuMgr.setChatBtnEnable(false)
        BasicMenuMgr.setChatRedPoint(false)
    end, "", 1)
end

function TownChatMgr.changeSceneChannel()
    if SceneMgr.currentScene~="HomeScene" then
        local teamID = TeamInfo.getInfo(TeamInfo.KEY_TEAMID)
        if teamID then
            channelTable[7] = "team_"..teamID
            NetInterface.sendWithBlock("GC_ChangeChannel_Ack", function()
                local ChatSend = require("src.Net.Send.ChatSend")
                ChatSend.sendCG_ChangeChannel_Req({channel = channelTable[7],data = "{}"})
            end)
        else
            channelIndex = channelIndex - 1
            TownChatMgr.changeChannel()
        end
    end
end

function TownChatMgr.changeHomeTabName()
    local btn = CSResourceMgr.getNodeByName(resName, "btn_fujin")
    local label = CSResourceMgr.getNodeByName(resName, "label_fujin")
    CSResourceMgr.setLabelStringByNode(label, "chat14")
    if TownChatMgr.list_status == 6 then
        CSResourceMgr.setButtonString(resName, "tabbtn", 
            ChatMsgMgr.SubUTF8String(LuaSqlite.getLanguageByKey("chat14"), LuaSqlite.LANG_TYPE ~= 1 and 1 or 3), "", {r=0,g=0,b=0,a=255})
    end
end

function TownChatMgr.voiceTouchFunc()
    isRecording = true
    if CSResourceMgr.getCsbObj(resNameE) then
        CSResourceMgr.getNodeByName(resNameE,"diban"):setVisible(true)
    else
        local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameE)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_BOARD)
        local diff, edgeDiff = TownChatMgr.getScreenSizeDiff()
        CocosModuleMgr.setRelativePosition(layer, 320, 600+diff)

        local effect = CSResourceMgr.getNodeByName(resNameE,"effect")
        local sequence = transition.sequence({
                    cc.ScaleTo:create(1,1.5),
                    cc.ScaleTo:create(0,1)
                })
        local ani = cc.RepeatForever:create(sequence)
        effect:runAction(ani)
    end
    local label = CSResourceMgr.getNodeByName(resNameE,"label")
    CSResourceMgr.setLabelStringByNode(label, "VoiceChat1", {r=0,g=0,b=0,a=255,w=1,s=1})
    CSResourceMgr.setLabelColorByNode(label, {r=134,g=248,b=251,a=255})
    CSResourceMgr.getNodeByName(resNameE,"back"):setColor({r=3,g=25,b=48,a=255})
    CSResourceMgr.getNodeByName(resNameE,"Voice"):loadTexture("UI/CommonFiles/frame_icon_voice_talking.png")
    CSResourceMgr.getNodeByName(resNameE,"effect"):setVisible(true)

    startVoiceTime = os.clock()
    VoiceManager.startRecording(composeVoiceName(CharInfo.getCharID()))
    audio.pauseMusic()

    local time = 0
    local function refresh()
        label:performWithDelay(function()
            time = time + 1
            if time >= 29 then
                TownChatMgr.onVoiceBtnPress(false)
                VoiceManager.stopRecording()
                CSResourceMgr.getNodeByName(resNameE,"diban"):setVisible(false)
                isRecording = false
                audio.resumeMusic()    
            else
                refresh()
            end
        end,1)
    end
    refresh()
    TownChatMgr.onVoiceBtnPress(true)
end

function TownChatMgr.setVoiceDiff(diff)
    voiceDiff = diff
end

function TownChatMgr.voiceDragFunc(btn,sender)
    if not isRecording then
        return
    end
    local diff, edgeDiff = TownChatMgr.getScreenSizeDiff()
    local x = sender:getTouchMovePosition().x
    local y = sender:getTouchMovePosition().y
    local posX = btn:getPositionX()
    local posY = btn:getPositionY()+edgeDiff+voiceDiff
    local width = btn:getContentSize().width
    local height = btn:getContentSize().height
    if x>(posX+width/2) or (x<posX-width/2) or y>(posY+height/2) or y<(posY-height/2) then
        local label = CSResourceMgr.getNodeByName(resNameE,"label")
        CSResourceMgr.setLabelStringByNode(label, "VoiceChat2", {r=0,g=0,b=0,a=255,w=1,s=1})
        CSResourceMgr.setLabelColorByNode(label, {r=255,g=255,b=255,a=255})
        CSResourceMgr.getNodeByName(resNameE,"back"):setColor({r=193,g=40,b=20,a=255})
        CSResourceMgr.getNodeByName(resNameE,"Voice"):loadTexture("UI/CommonFiles/frame_icon_voice_cancel.png")
        CSResourceMgr.getNodeByName(resNameE,"effect"):setVisible(false)
    else
        local label = CSResourceMgr.getNodeByName(resNameE,"label")
        CSResourceMgr.setLabelStringByNode(label, "VoiceChat1", {r=0,g=0,b=0,a=255,w=1,s=1})
        CSResourceMgr.setLabelColorByNode(label, {r=134,g=248,b=251,a=255})
        CSResourceMgr.getNodeByName(resNameE,"back"):setColor({r=3,g=25,b=48,a=255})
        CSResourceMgr.getNodeByName(resNameE,"Voice"):loadTexture("UI/CommonFiles/frame_icon_voice_talking.png")
        CSResourceMgr.getNodeByName(resNameE,"effect"):setVisible(true)
    end
end

function TownChatMgr.voiceCancelFunc()
    if not isRecording then
        return
    end
    TownChatMgr.onVoiceBtnPress(false)
    CSResourceMgr.getNodeByName(resNameE,"diban"):setVisible(false)
    VoiceManager.cancelRecording()
    transition.stopTarget(CSResourceMgr.getNodeByName(resNameE,"label"))
    isRecording = false
    audio.resumeMusic()
end

function TownChatMgr.voiceClickFunc()
    if not isRecording then
        return
    end
    TownChatMgr.onVoiceBtnPress(false)
    endVoiceTime = os.clock()
    CSResourceMgr.getNodeByName(resNameE,"diban"):setVisible(false)
    if endVoiceTime - startVoiceTime >= 1 then
        VoiceManager.stopRecording()
        transition.stopTarget(CSResourceMgr.getNodeByName(resNameE,"label"))
    else
        VoiceManager.cancelRecording()
        StandardTipsMgr.show(1, "VoiceChat3")
        transition.stopTarget(CSResourceMgr.getNodeByName(resNameE,"label"))
    end
    audio.resumeMusic()
    isRecording = false
end

function TownChatMgr.postVoiceToServer(voiceLength,voiceCachePath)
    print("TownChatMgr.postVoiceToServer",voiceLength,voiceCachePath)
    voiceInfoTable = {voiceLength = math.ceil(voiceLength/1000),voiceCachePath = voiceCachePath}
    VoiceManager.postVoice(voiceCachePath)
end

function TownChatMgr.setVoiceChatMsg(date, id)
    print("TownChatMgr.setVoiceChatMsg",date,id)
	if (TownChatMgr.send_status==3 or TownChatMgr.send_status==6 or TownChatMgr.send_status==5 )and rechargeTotal < 100 then
        StandardTipsMgr.show(1, "CantSendMsg1")
        return
    end
    local charactorName = CharInfo.getNickName()
    local text_p = editbox_p:getText()
    local textTable = {textType = "voice",concent = "",voiceInfo = {charID = CharInfo.getCharID(),date = date,id = id,voiceInfoTable = voiceInfoTable},cupLv = CharInfo.get().pvparenagrade or 0}
    local cjson = require("cjson")

    --世界发言间隔5分钟10条
    if TownChatMgr.send_status==3 then
        if #worldChatTimeTable<3 then
            table.insert(worldChatTimeTable,CharInfo.getServerTime())
        elseif CharInfo.getServerTime()-(worldChatTimeTable[1] or 0)>15 and #worldChatTimeTable==3 then
            table.remove(worldChatTimeTable, 1)
            table.insert(worldChatTimeTable,CharInfo.getServerTime())
        else
            StandardTipsMgr.show(1, "CantSendMsg4")
            return
        end
    end
    if TownChatMgr.send_status==7 then
        TownChatMgr.hideEmojiPanel(false)

        local str = json.encode(textTable)

        local teamID = TeamInfo.getInfo(TeamInfo.KEY_TEAMID)
        if teamID then
            NetInterface.sendWithBlock("GC_Chat_Ack", function()                
                local ChatSend = require("src.Net.Send.ChatSend")
                ChatSend.sendCG_Chat_Req({charID = "",channel = channelTable[TownChatMgr.send_status],concent =str})
            end)
        else
            StandardTipsMgr.show(1, "TeamInvite12")
        end
    elseif TownChatMgr.send_status~=5 then
        TownChatMgr.hideEmojiPanel(false)

        local str = json.encode(textTable)

        if TownChatMgr.send_status==4 then
            local familyID = CharInfo.getFamilyID()
            if familyID ~= nil then
                channelTable[TownChatMgr.send_status] = "family_"..tostring(familyID)
            else
                StandardTipsMgr.show(1, "CantSendMsg3")
                print("没有家族")
                return
            end
        end

        NetInterface.sendWithBlock("GC_Chat_Ack", function()
            local ChatSend = require("src.Net.Send.ChatSend")
            if SceneMgr.currentScene == "HomeScene" and TownChatMgr.send_status == 6 then
                ChatSend.sendCG_Chat_Req({charID = "",channel = "Home_"..tostring(HomeInfo.GetCurrentHomeCharID() == 0 
                    and "yard_"..(CharInfo.getFamilyID() or 0) or HomeInfo.GetCurrentHomeCharID()),concent =str})
            else
                ChatSend.sendCG_Chat_Req({charID = "",channel = channelTable[TownChatMgr.send_status],concent =str})
            end
        end)
    elseif TownChatMgr.send_status==5 then
        if text_p=="" then
            StandardTipsMgr.show(1, "CantSendMsg2")
            return
        end

        TownChatMgr.hideEmojiPanel(false)

        local str = json.encode(textTable)

        NetInterface.sendWithBlock("GC_Chat_Ack", function()
            local ChatSend = require("src.Net.Send.ChatSend")
            ChatSend.sendCG_Chat_Req({charID = mChatID,channel = "",concent =str})
        end)
        mChatName = text_p
    end
end

function TownChatMgr.setVoiceChatBtnEvent(btn)
    btn:addTouchEventListener(function(sender, state)
        if state == 0 then
            TownChatMgr.voiceTouchFunc()
        elseif state == 1 then
            TownChatMgr.voiceDragFunc(btn,sender)
        elseif state == 2 then
            TownChatMgr.voiceClickFunc()
        elseif state == 3 then
            TownChatMgr.voiceCancelFunc()
        end
    end)
end

function TownChatMgr.playVoice(cachedFilePath)
    if device.platform == "windows" then
        StandardTipsMgr.show(1, "Windows system not support")
        return
    end
    audio.stopAllSounds()
    audio.pauseMusic()
    audio.playSound(cachedFilePath,false)
    TownChatMgr.playVoiceAni(1)
    curVoiceSprite:performWithDelay(function()
        audio.resumeMusic()
        TownChatMgr.stopVoiceAni(curVoiceSprite)
    end,curVoiceLength)
end

function TownChatMgr.setVoiceCacheTable(path)
    voiceCacheTable[curVoiceKey] = path
    TownChatMgr.playVoice(path)
end

function TownChatMgr.isQueryOver(success)
    isQueryOver = true
    if not success then
        audio.resumeMusic()
    end
end

function TownChatMgr.playVoiceAni(index)
    local nextIndex = 0
    curVoiceSprite:performWithDelay(function()
        CSResourceMgr.setSpriteTextureByNode(curVoiceSprite, "UI/CommonFiles/chat_bubble_voice_talking_0"..index..".png")
        if index == 3 then
            nextIndex = 1
        else
            nextIndex = index + 1
        end
        TownChatMgr.playVoiceAni(nextIndex)
    end,0.5)
end

function TownChatMgr.stopVoiceAni(sprite)
    if not sprite then
        return
    end
    transition.stopTarget(sprite)
    CSResourceMgr.setSpriteTextureByNode(sprite, "UI/CommonFiles/chat_bubble_voice_talking_03.png")
    curVoiceSprite = nil
end

function TownChatMgr.setExitTeamBattle()
    exitTeamBattle = true
end

function TownChatMgr.onVoiceBtnPress(bool)
    if bool then
        CSResourceMgr.getNodeByName(resName,"voiceBlock"):setGlobalZOrder(CocosModuleMgr.ZORDER_CHAT)
        CSResourceMgr.getNodeByName(resName,"voiceBtn"):setGlobalZOrder(CocosModuleMgr.ZORDER_CHAT)
        CSResourceMgr.getNodeByName(resName,"voiceBlock"):setVisible(true)
    else
        CSResourceMgr.getNodeByName(resName,"voiceBlock"):setGlobalZOrder(0)
        CSResourceMgr.getNodeByName(resName,"voiceBtn"):setGlobalZOrder(0)
        CSResourceMgr.getNodeByName(resName,"voiceBlock"):setVisible(false)
    end
end

function TownChatMgr.sendBattleEndResult(winner,loser)
    local textTable = {textType = "battleResult",winner = winner,loser = loser,cupLv = CharInfo.get().pvparenagrade or 0}
    local cjson = require("cjson")
    local str = json.encode(textTable)
    NetInterface.sendWithBlock("GC_Chat_Ack", function()
        local ChatSend = require("src.Net.Send.ChatSend")
        ChatSend.sendCG_Chat_Req({charID = "",channel = channelTable[6],concent =str})
    end)
end

function TownChatMgr.battleEndResult(winner,loser)
    local message = ChatMsgMgr.chatMessageProcessor("",CocosModuleMgr.createStringWithFormat({"chat17", winner,loser}), 2)
    TownChatMgr.addChatMessage(message, 6, false , {name = ""})
end

--result:1--A WIN  0--B WIN
function TownChatMgr.shareBattleToChat(nameA,nameB,id,result)
    if #worldChatTimeTable<3 then
        table.insert(worldChatTimeTable,CharInfo.getServerTime())
    elseif CharInfo.getServerTime()-(worldChatTimeTable[1] or 0)>15 and #worldChatTimeTable==3 then
        table.remove(worldChatTimeTable, 1)
        table.insert(worldChatTimeTable,CharInfo.getServerTime())
    else
        StandardTipsMgr.show(1, "CantSendMsg4")
        ArenaRecordMgr.isShareBattle = false
        return
    end
    local textTable = {textType = "battle",battleInfo = {battleId = id,nameA = nameA,nameB = nameB,result = result},cupLv = CharInfo.get().pvparenagrade or 0}
    local cjson = require("cjson")
    local str = json.encode(textTable)
    NetInterface.sendWithBlock("GC_Chat_Ack", function()
        local ChatSend = require("src.Net.Send.ChatSend")
        ChatSend.sendCG_Chat_Req({charID = "",channel = channelTable[3],concent =str})
    end,function()
        StandardTipsMgr.show(0, "egg33")
    end)
    ArenaRecordMgr.isShareBattle = false
end

--boss战结束消息
function TownChatMgr.bossBattleEnd()
    local message = ChatMsgMgr.chatMessageProcessor("",LuaSqlite.getLanguageByKey("worldnotice1"), 2)
    TownChatMgr.addChatMessage(message, 3, false , {name = ""})
end

return TownChatMgr