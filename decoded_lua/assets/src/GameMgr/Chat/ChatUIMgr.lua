local ChatUIMgr = {}

ChatUIMgr.MAX_WORD_SIZE = 128
ChatUIMgr.MAX_LIST_SIZE = 50
ChatUIMgr.MAX_LABEL_WIDTH = 700
ChatUIMgr.MAX_OUTLABEL_LENGTH = 50
ChatUIMgr.DEFAULT_OUTLABEL_SHOWTIME = 5
ChatUIMgr.LABEL_FONT_SIZE = 22          --需要与csb中label字体大小一致

ChatUIMgr.chat_window_open = false      --聊天窗口是否打开
ChatUIMgr.load_finished = false         --聊天UI是否加载完
ChatUIMgr.have_new_message = false      --是否有新消息
ChatUIMgr.status = 0                    --玩家开启或隐藏聊天窗口
ChatUIMgr.chat_table = {}               --历史聊天记录
ChatUIMgr.emoji_panel_status = false    --表情容器是否被打开
ChatUIMgr.send_status = 5               --消息发送目标类型
ChatUIMgr.list_status = 1               --消息分页列表选择类型

ChatUIMgr.emoji_tbl = {}
ChatUIMgr.emoji_path = {}

local type_tbl = {}
local coroutine = nil
local coroutineFunc = nil
local outLabelTable = {}

---重新初始化ChatUIMgr，用于动态lua调试
function ChatUIMgr.Init()
    print("ChatUIMgr初始化")
    ChatUIMgr.chat_window_open = false
    ChatUIMgr.load_finished = false
    ChatUIMgr.have_new_message = false
    ChatUIMgr.status = 0
    ChatUIMgr.chat_table[1] = {}
    ChatUIMgr.chat_table[2] = {}
    ChatUIMgr.chat_table[3] = {}
    ChatUIMgr.chat_table[4] = {}
    ChatUIMgr.chat_table[5] = {}
    ChatUIMgr.emoji_panel_status = false
    ChatUIMgr.send_status = 5
    ChatUIMgr.list_status = 1
    
    ChatUIMgr.emoji_tbl = {
                    "%[em01%]","%[em02%]","%[em03%]","%[em04%]","%[em05%]",
                    "%[em06%]","%[em07%]","%[em08%]","%[em09%]","%[em10%]",
                    "%[em11%]","%[em12%]","%[em13%]","%[em14%]","%[em15%]"
                }
    ChatUIMgr.emoji_path = {
                    "UI/Chat/Emoji/em01.png",
                    "UI/Chat/Emoji/em02.png",
                    "UI/Chat/Emoji/em03.png",
                    "UI/Chat/Emoji/em04.png",
                    "UI/Chat/Emoji/em05.png",
                    "UI/Chat/Emoji/em06.png",
                    "UI/Chat/Emoji/em07.png",
                    "UI/Chat/Emoji/em08.png",
                    "UI/Chat/Emoji/em09.png",
                    "UI/Chat/Emoji/em10.png",
                    "UI/Chat/Emoji/em11.png",
                    "UI/Chat/Emoji/em12.png",
                    "UI/Chat/Emoji/em13.png",
                    "UI/Chat/Emoji/em14.png",
                    "UI/Chat/Emoji/em15.png"
                 }
                 
    type_tbl = {"zonghe", "xitong", "gonghui", "shijie", "fujin"}
    
    coroutine = require("coroutine")
    coroutineFunc = nil
    outLabelTable = {}
end 

---载入聊天面板
--@param scene node 当前场景
function ChatUIMgr.addChatUI(scene)
    if not SystemOptionsMgr.getOption(2) then
        print("玩家设置不打开聊天面板")
	    return false
    end
    if SceneMgr.isProcessing == true then
	    print("场景切换中，ChatUI暂不创建")
	    return false
    end
    local chatLayer = CSResourceMgr.createRes(scene, "UI/Chat/ChatLayer.csb")
    chatLayer:setLocalZOrder(10)
    local sizeRate = CocosModuleMgr.setEdgeDistance(chatLayer, 0, nil, nil, 0, true, 0.5)

    local function onEdit(event, editbox)
        if event == "began" then
            -- 开始输入
        elseif event == "changed" then
            -- 输入框内容发生变化
            if string.len(editbox:getText())>ChatUIMgr.MAX_WORD_SIZE then
                local tmpstr = ChatMsgMgr.SubUTF8String(editbox:getText(), ChatUIMgr.MAX_WORD_SIZE)
                editbox:setText(tmpstr)
            end
        elseif event == "ended" then
            -- 输入结束
        elseif event == "return" then
            -- 从输入框返回
        end
    end
    local editbox = cc.ui.UIInput.new({
        image = "UI/Chat/db_shuru.png",
        listener = onEdit,
        size = cc.size(540*sizeRate, 50*sizeRate),
        x = 405,
        y = 42
    })
    editbox:setPlaceHolder(LuaSqlite.getLanguageByKey("来说两句吧~"))
    editbox:setFont("FZCuYuan-M03", 24*sizeRate)
    editbox:setMaxLength(ChatUIMgr.MAX_WORD_SIZE)
    editbox:setScale(1/sizeRate, 1/sizeRate)
    CSResourceMgr.getNodeByName("UI/Chat/ChatLayer.csb", {"lt_bg"}):addChild(editbox)
    
    
    --表情按钮
    CSResourceMgr.clickEventBinding("UI/Chat/ChatLayer.csb", {"lt_bg", "emoji"}, function()
        if ChatUIMgr.emoji_panel_status == false then
            ChatUIMgr.showEmojiPanel(true)
            ChatUIMgr.emoji_panel_status = true
        else
            ChatUIMgr.hideEmojiPanel(true)
            ChatUIMgr.emoji_panel_status = false
        end
    end)
    local function onClickEmoji(type)
        local cur_text = editbox:getText()
        editbox:setText(cur_text..string.gsub(ChatUIMgr.emoji_tbl[type], "%%", ""))
    end
    ChatUIMgr.bindAllEmojiButtonsEvents(onClickEmoji)
    --打开聊天面板按钮
    CSResourceMgr.clickEventBinding("UI/Chat/ChatLayer.csb", "chat", function()
        ChatUIMgr.showChatUI()
        MiniMapMgr.hideMiniMapUI()
    end, "", true)
    --聊天面板最小化按钮
    CSResourceMgr.clickEventBinding("UI/Chat/ChatLayer.csb", {"lt_bg", "min"}, function()
        ChatUIMgr.hideChatUI()
    end)
    --聊天消息清空按钮
    CSResourceMgr.clickEventBinding("UI/Chat/ChatLayer.csb", {"lt_bg", "del"}, function()
        ChatUIMgr.deleteAllChatMessage()
    end)
    --发送消息按钮
    CSResourceMgr.clickEventBinding("UI/Chat/ChatLayer.csb", {"lt_bg", "send"}, function()
        local charactorName = CharInfo.getNickName()
        
        local text = editbox:getText()
        if text~="" then
            if string.len(text)>ChatUIMgr.MAX_WORD_SIZE then
                TipsMgr.show(scene, "输入字符太长了~")
                editbox:setText("")
                CSResourceMgr.getNodeByName("UI/Chat/ChatLayer.csb", {"lt_bg", "list"}):jumpToBottom()
            else
                editbox:setText("")
                ChatUIMgr.hideEmojiPanel(false)
                
                --[[
                NetInterface.send("ZC_ScreenChat_Brd", function()
                	local ChatSend = require("src.Net.Send.ChatSend")
                    ChatSend.sendCZ_ScreenChat_Req(text)
                end)
                --]]
                
                local str = ChatMsgMgr.chatMessageProcessor(charactorName, text, ChatUIMgr.send_status)
                ChatUIMgr.addChatMessage(str, ChatUIMgr.send_status)
                ChatUIMgr.addOutLabel(charactorName..": "..text, ChatUIMgr.send_status)
                if ChatUIMgr.send_status==5 then
                    local msg = ChatMsgMgr.chatMessageProcessor("", text)
                    if SceneMgr.mapType~="_battle" then
                        ChatBubbleMgr.showChatBubble(msg)
                    end
                end
                
            end
        end
    end)
    --聊天分页切换按钮
    local function tabButtonDisable(type)
        local enable_tbl = {true, true, true, true, true}
        enable_tbl[type] = false
        for var=1, 5 do
            CSResourceMgr.setButtonEnabled("UI/Chat/ChatLayer.csb", {"lt_bg", "Button_"..type_tbl[var]}, enable_tbl[var])
        end
    end
    local function reLoadMsg()
        local clabel = CSResourceMgr.getNodeByName("UI/Chat/ChatLayer.csb", {"lt_bg", "list", "message"}):clone()
        CSResourceMgr.getNodeByName("UI/Chat/ChatLayer.csb", {"lt_bg", "list"}):removeAllItems()
        CSResourceMgr.getNodeByName("UI/Chat/ChatLayer.csb", {"lt_bg", "list"}):pushBackCustomItem(clabel)
        coroutineFunc = coroutine.create(function()
            for tags,message in pairs(ChatUIMgr.chat_table[ChatUIMgr.list_status]) do
                print("cur list name:"..type_tbl[ChatUIMgr.list_status].."\n sum:"..table.getn(ChatUIMgr.chat_table[ChatUIMgr.list_status]))
                ChatUIMgr.addChatMessage(message, ChatUIMgr.list_status, true)
                coroutine.yield()
            end
        end)
        coroutine.resume(coroutineFunc)
    end
    tabButtonDisable(ChatUIMgr.list_status)
    for var=1, 5 do
        CSResourceMgr.clickEventBinding("UI/Chat/ChatLayer.csb", {"lt_bg", "Button_"..type_tbl[var]}, function()
            tabButtonDisable(var)
            ChatUIMgr.list_status = var
            ChatUIMgr.setNewMarkVisibleByType(var, false)
            reLoadMsg()
        end)
    end
    --发送目标切换按钮
    if ChatUIMgr.send_status==5 then
        CSResourceMgr.setSpriteTexture("UI/Chat/ChatLayer.csb", {"lt_bg", "tab"}, "UI/Chat/tab_"..type_tbl[5]..".png")
    elseif ChatUIMgr.send_status==4 then
        CSResourceMgr.setSpriteTexture("UI/Chat/ChatLayer.csb", {"lt_bg", "tab"}, "UI/Chat/tab_"..type_tbl[4]..".png")
    elseif ChatUIMgr.send_status==3 then
        CSResourceMgr.setSpriteTexture("UI/Chat/ChatLayer.csb", {"lt_bg", "tab"}, "UI/Chat/tab_"..type_tbl[3]..".png")
    end
    CSResourceMgr.clickEventBinding("UI/Chat/ChatLayer.csb", {"lt_bg", "Button_tab"}, function()
        if ChatUIMgr.send_status==5 then
            CSResourceMgr.setSpriteTexture("UI/Chat/ChatLayer.csb", {"lt_bg", "tab"}, "UI/Chat/tab_"..type_tbl[4]..".png")
            ChatUIMgr.send_status = 4
        elseif ChatUIMgr.send_status==4 then
            CSResourceMgr.setSpriteTexture("UI/Chat/ChatLayer.csb", {"lt_bg", "tab"}, "UI/Chat/tab_"..type_tbl[3]..".png")
            ChatUIMgr.send_status = 3
        elseif ChatUIMgr.send_status==3 then
            CSResourceMgr.setSpriteTexture("UI/Chat/ChatLayer.csb", {"lt_bg", "tab"}, "UI/Chat/tab_"..type_tbl[5]..".png")
            ChatUIMgr.send_status = 5
        end
    end)
    
    --加载场景时不使用携程加载历史聊天记录
    coroutineFunc = nil
    local clabel = CSResourceMgr.getNodeByName("UI/Chat/ChatLayer.csb", {"lt_bg", "list", "message"}):clone()
    CSResourceMgr.getNodeByName("UI/Chat/ChatLayer.csb", {"lt_bg", "list"}):removeAllItems()
    CSResourceMgr.getNodeByName("UI/Chat/ChatLayer.csb", {"lt_bg", "list"}):pushBackCustomItem(clabel)
    for tags,message in pairs(ChatUIMgr.chat_table[ChatUIMgr.list_status]) do
        print("cur list name:"..type_tbl[ChatUIMgr.list_status].."\n sum:"..table.getn(ChatUIMgr.chat_table[ChatUIMgr.list_status]))
        ChatUIMgr.addChatMessage(message, ChatUIMgr.list_status, true)
    end
    
    ChatUIMgr.chat_window_open = false
    ChatUIMgr.load_finished = true
    ChatUIMgr.emoji_panel_status = false
    ChatUIMgr.setNewMarkVisible(ChatUIMgr.have_new_message)
    print("聊天UI加载完毕")
end

function ChatUIMgr.remove()
    ChatUIMgr.status = 0
    ChatUIMgr.have_new_message = false 
    ChatUIMgr.deleteAllChatMessage()
    CSResourceMgr.removeCSObjectByTag("UI/Chat/ChatLayer.csb")
end

---检查聊天面板状态，若玩家开启了则继续开启
function ChatUIMgr.checkChatStatus()
    if ChatUIMgr.status == 1 and MiniMapMgr.status ~= 1 then
        if ChatUIMgr.chat_window_open == false then
                CSResourceMgr.playAction("UI/Chat/ChatLayer.csb", 0, 10, false)
                ChatUIMgr.setNewMarkVisible(false)
        end
    else
        ChatUIMgr.status = 0
    end
end

---在聊天List中新增聊天Label
--@param message string 需要为chatMessageProcessor处理后的字符串
--@param type int 聊天消息类型，2系统/3公会/4私聊/5附近
--@param isReload bool 是否是重新load消息
function ChatUIMgr.addChatMessage(message, type, isReload)
    --CSResourceMgr.getNodeByName("UI/Chat/ChatLayer.csb", {"lt_bg", "list"}):getItem(0):setString("test")
    type = type or 1
    isReload = isReload or false
    
    if type<1 or type>5 then
        print("addChatMessage failed. 消息类型错误. 应该为2~5")
    	return false
    end
    
    if isReload == false then
        --判断聊天列表UI是否加载完毕
        if ChatUIMgr.load_finished == false then
            --print("addChatMessage failed. 聊天UI尚未加载")
            if not SystemOptionsMgr.getOption(2) then
                print("玩家设置不打开聊天面板")
                return false
            end
            local scheduler = require("src.framework.scheduler")
            scheduler.performWithDelayGlobal(function()
                --print("2秒后再添加")
                ChatUIMgr.addChatMessage(message, type, false)
            end, 2)
            return false
        end
        --设置new标志
        if ChatUIMgr.status ~= 1 then
            ChatUIMgr.have_new_message = true
        end
        --判断综合列表信息数量是否达到最大
        if table.getn(ChatUIMgr.chat_table[1])+1>ChatUIMgr.MAX_LIST_SIZE then
            table.remove(ChatUIMgr.chat_table[1], 1)
            if ChatUIMgr.list_status==1 then
                CSResourceMgr.getNodeByName("UI/Chat/ChatLayer.csb", {"lt_bg", "list"}):removeItem(1)
            end
        end
        --判断对应列表信息数量是否达到最大
        if type~=1 and table.getn(ChatUIMgr.chat_table[type])+1>ChatUIMgr.MAX_LIST_SIZE then
            table.remove(ChatUIMgr.chat_table[type], 1)
            if ChatUIMgr.list_status==type then
                CSResourceMgr.getNodeByName("UI/Chat/ChatLayer.csb", {"lt_bg", "list"}):removeItem(1)
            end
        end
        --插入信息到table
        table.insert(ChatUIMgr.chat_table[1], message)
        if type~=1 then
            table.insert(ChatUIMgr.chat_table[type], message)
        end
    end
    
    ChatUIMgr.setNewMarkVisible(ChatUIMgr.have_new_message)
    if type~=ChatUIMgr.list_status and ChatUIMgr.list_status~=1 then
        --加个新消息的红点
        ChatUIMgr.setNewMarkVisibleByType(type, true)
    	print("当前选择分页不需要创建label")
    	return false
    end
    
    local label = CSResourceMgr.getNodeByName("UI/Chat/ChatLayer.csb", {"lt_bg", "list", "message"}):clone()
    local richLabel = CocosModuleMgr.createRichLabel(label, message, ChatUIMgr.LABEL_FONT_SIZE, "cuyuan_GBK.ttf", ChatUIMgr.MAX_LABEL_WIDTH)
    label:setString(" ")
    label:setTextAreaSize({width = 0, height = richLabel.realHeight})
    label:ignoreContentAdaptWithSize(false)
    --label:enableOutline({r=0,g=0,b=0,a=64}, 1)
    
    CSResourceMgr.getNodeByName("UI/Chat/ChatLayer.csb", {"lt_bg", "list"}):pushBackCustomItem(label)
    label:performWithDelay(function()
        CSResourceMgr.getNodeByName("UI/Chat/ChatLayer.csb", {"lt_bg", "list"}):jumpToBottom()
    end, 0.5)
    
    if isReload == true and coroutineFunc~=nil then
        label:performWithDelay(function()
            coroutine.resume(coroutineFunc)
        end, 0.01)
    end
    
    print("list size:"..table.getn(ChatUIMgr.chat_table[type])..
    "\nlist height: "..CSResourceMgr.getNodeByName("UI/Chat/ChatLayer.csb", {"lt_bg", "list"}):getInnerContainerSize().height)
end

---手动清空聊天List
function ChatUIMgr.deleteAllChatMessage()
    if ChatUIMgr.load_finished == false then
        --print("deleteAllChatMessage faileded. 聊天UI尚未加载")
        return false
    end
    local clabel = CSResourceMgr.getNodeByName("UI/Chat/ChatLayer.csb", {"lt_bg", "list", "message"})
    clabel = clabel:clone()
    CSResourceMgr.getNodeByName("UI/Chat/ChatLayer.csb", {"lt_bg", "list"}):removeAllItems()
    CSResourceMgr.getNodeByName("UI/Chat/ChatLayer.csb", {"lt_bg", "list"}):pushBackCustomItem(clabel)
    for var=1, 5 do
        ChatUIMgr.chat_table[var] = {}
        ChatUIMgr.setNewMarkVisibleByType(var, false)
    end    
end

---设置外放聊天信息Label
--@param message string 完整的消息
--@param type int 消息类型
function ChatUIMgr.addOutLabel(message, type)
    if ChatUIMgr.load_finished == false then
        --print("addOutLabel faileded. 聊天UI尚未加载")
        return false
    end
	if type<2 or type>5 then
        print("addOutLabel faileded. 不适用的消息类型")
		return false
	end
    if ChatUIMgr.list_status~=1 and type~=ChatUIMgr.list_status then
        print("addOutLabel faileded. 当前聊天分页过滤了此消息")
        return false
	end
    if string.len(message)>ChatUIMgr.MAX_OUTLABEL_LENGTH then
        message = ChatMsgMgr.SubUTF8String(message, ChatUIMgr.MAX_OUTLABEL_LENGTH).."..."
    end
    local colorTbl = {{r=0,g=0,b=0,a=255}, {r=255,g=30,b=30,a=255}, {r=160,g=240,b=113,a=255}, {r=253,g=245,b=100,a=255}, {r=255,g=255,b=255,a=255}}
    local label = CSResourceMgr.getNodeByName("UI/Chat/ChatLayer.csb", {"chat", "outLabel"})
    transition.stopTarget(label)
    label:setAnchorPoint(0, 0.5)
    label:setTextColor(colorTbl[type])
    CSResourceMgr.setLabelString("UI/Chat/ChatLayer.csb", {"chat", "outLabel"}, message, "", {r=0,g=0,b=0,a=255}, 1)
    local scale = label:getScaleX()
    label:setScale(scale, 0)
    transition.scaleTo(label, {scaleY = scale, time = 0.2})
    label:performWithDelay(function()
        transition.scaleTo(label, {scaleY = 0, time = 0.2})
    end, ChatUIMgr.DEFAULT_OUTLABEL_SHOWTIME)
end

---打开聊天面板
function ChatUIMgr.showChatUI()
    if ChatUIMgr.load_finished == false then
        --print("showChatUI faileded. 聊天UI尚未加载")
    	return false
    end
    if ChatUIMgr.status ~= 1 then
        CSResourceMgr.playAction("UI/Chat/ChatLayer.csb", 0, 10, false)
        ChatUIMgr.have_new_message = false
        ChatUIMgr.setNewMarkVisible(ChatUIMgr.have_new_message)
        ChatUIMgr.status = 1
        ChatUIMgr.chat_window_open = true
    end
end

---最小化聊天面板
function ChatUIMgr.hideChatUI()
    if ChatUIMgr.load_finished == false then
        --print("hideChatUI failed. 聊天UI尚未加载")
        return false
    end
    if ChatUIMgr.status ~= 0 then
        CSResourceMgr.playAction("UI/Chat/ChatLayer.csb", 70, 80, false)
        ChatUIMgr.status = 0
        ChatUIMgr.emoji_panel_status = false
        ChatUIMgr.chat_window_open = false
    end
end

---打开表情容器
--@param doAnimated bool 是否播放动画
function ChatUIMgr.showEmojiPanel(doAnimated)
    if ChatUIMgr.load_finished == false then
        --print("showEmojiPanel faileded. 聊天UI尚未加载")
        return false
    end
    if ChatUIMgr.emoji_panel_status == false then
        CSResourceMgr.playAction("UI/Chat/ChatLayer.csb", 25, 30, false)
        CSResourceMgr.getNodeByName("UI/Chat/ChatLayer.csb", {"lt_bg", "emoji", "emoji_panel"}):setVisible(true)
        ChatUIMgr.emoji_panel_status = true
    end
end

---隐藏表情容器
--@param doAnimated bool 是否播放动画
function ChatUIMgr.hideEmojiPanel(doAnimated)
    if ChatUIMgr.load_finished == false then
        --print("hideEmojiPanel failed. 聊天UI尚未加载")
        return false
    end
    if ChatUIMgr.emoji_panel_status == true then
        if doAnimated then
            CSResourceMgr.playAction("UI/Chat/ChatLayer.csb", 50, 55, false)
        else
            CSResourceMgr.getNodeByName("UI/Chat/ChatLayer.csb", {"lt_bg", "emoji", "emoji_panel"}):setVisible(false)
        end
        ChatUIMgr.emoji_panel_status = false
    end
end

---设置分页新消息红点
--@param type int 分页类型
--@param visible bool 是否显示分页新消息红点
function ChatUIMgr.setNewMarkVisibleByType(type, visible)
    if ChatUIMgr.load_finished == false then
        --print("setNewMarkVisibleByType failed. 聊天UI尚未加载")
        return false
    end
    if type==1 then
    	for var=2,5 do
            ChatUIMgr.setNewMarkVisibleByType(var, false)
    	end
    	return
    end
    local newMark = CSResourceMgr.getNodeByName("UI/Chat/ChatLayer.csb", {"lt_bg", "Button_"..type_tbl[type], "red_point_"..type_tbl[type]})
    if newMark~=nil then
        newMark:setVisible(visible)
    end
end

---设置新消息红点
--@param visible bool 是否显示新消息红点
function ChatUIMgr.setNewMarkVisible(visible)
    if ChatUIMgr.load_finished == false then
        --print("setNewMarkVisible failed. 聊天UI尚未加载")
        return false
    end
    local newMark = CSResourceMgr.getNodeByName("UI/Chat/ChatLayer.csb", {"chat", "new"})
    if newMark~=nil then
        newMark:setVisible(visible)
    end
end

---绑定所有表情点击事件
--@param callback function 点击事件回调，并带参数
function ChatUIMgr.bindAllEmojiButtonsEvents(callback)
    for var=1, 15 do
        CSResourceMgr.clickEventBinding("UI/Chat/ChatLayer.csb", {"lt_bg", "emoji", "emoji_panel", string.format("em%02d",var)}, function()
            callback(var)
        end)
    end
end

return ChatUIMgr