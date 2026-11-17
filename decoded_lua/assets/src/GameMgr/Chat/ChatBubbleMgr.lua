local ChatBubbleMgr = {}

ChatBubbleMgr.DEFAULT_CHAT_BUBBLE_SHOWTIME = 6
ChatBubbleMgr.MAX_WIDTH = 230
ChatBubbleMgr.MIN_WIDTH = 60
ChatBubbleMgr.DEFAULT_WIDTH_DIFF = 25
ChatBubbleMgr.DEFAULT_HEIGHT_DIFFRATE = 1.18

ChatBubbleMgr.ChatBubbleTable = {}         --聊天气泡列表

local resNameBack = ""

function ChatBubbleMgr.Init()
    print("ChatBubbleMgr初始化")
    
    ChatBubbleMgr.ChatBubbleTable = {}
    resNameBack = "UI/Chat/chatBackLayer.csb"
end

---城镇聊天
--@param message string 聊天内容
--@param name string 主角说话传nil，其他玩家说话传昵称
--@param charID int 主角说话传nil，其他玩家说话传角色id
function ChatBubbleMgr.showChatBubble(message, name, charID)
    local tPlayer = TownMapMgr.PlayerNameLabel
    if charID~=nil then
        local cid = tonumber(charID)
        if not TownPlayerMgr.PlayerTable[cid] then
        	return
        end
        tPlayer = TownPlayerMgr.PlayerTable[cid][4]
    end
    local tagID = charID or CharInfo.getCharID()

    --if ChatBubbleMgr.ChatBubbleTable[tag]~=nil then
        --ChatBubbleMgr.ChatBubbleTable[tag]:removeFromParent(true)
        tPlayer:removeChildByTag(tagID,true)
    --end

    --local chatBubble = CSResourceMgr.createRes(TownMapMgr.PlayerNameLabel, "Charactor/ChatBubble.csb", tag)
    local richLabel = CocosModuleMgr.createRichLabel(nil, message, 18, "cuyuan_GBK.ttf", ChatBubbleMgr.MAX_WIDTH,0,0,1,true)
    local sizex = richLabel.realWidth+ChatBubbleMgr.DEFAULT_WIDTH_DIFF
    local sizey = richLabel.realHeight*ChatBubbleMgr.DEFAULT_HEIGHT_DIFFRATE+24
    sizey = sizey>ChatBubbleMgr.MIN_WIDTH and sizey or ChatBubbleMgr.MIN_WIDTH
    if richLabel.realWidth+ChatBubbleMgr.DEFAULT_WIDTH_DIFF<ChatBubbleMgr.MIN_WIDTH then
        sizex = ChatBubbleMgr.MIN_WIDTH
    elseif richLabel.realWidth==ChatBubbleMgr.MAX_WIDTH then
        sizex = ChatBubbleMgr.MAX_WIDTH+10
    end
    -- local chatBubble = display.newScale9Sprite("Charactor/ChatBB.png", 0, 0, cc.size(sizex,sizey))
    local chatBubble = CSResourceMgr.createRes(tPlayer, resNameBack, tostring(tagID))
    chatBubble:setTag(tagID)
    -- local chatBubble = CSResourceMgr.getNodeByName(resNameBack,"back"):clone()
    local chatBubbleImage = CSResourceMgr.getNodeByName(resNameBack,"back", tostring(tagID))
    chatBubbleImage:setContentSize(cc.size(sizex,sizey))
    chatBubbleImage:setPosition(sizex/2, 20)
    -- chatBubble:addTo(tPlayer)
    richLabel:addTo(chatBubbleImage)
    richLabel:setPosition(15, sizey-8)
    -- local chatBubbleTail = display.newSprite("Charactor/ChatBB_tail.png")
    -- chatBubbleTail:addTo(chatBubble)
    -- chatBubbleTail:setPosition(sizex/2, 0)
    -- chatBubbleTail:setAnchorPoint(0.5, 1)
    chatBubble:setPosition(75, sizey/2)
    chatBubble:setAnchorPoint(0, 0.5)
    chatBubble:performWithDelay(function()
        transition.fadeOut(chatBubble, {time = 0.5})
        -- transition.fadeOut(chatBubbleTail, {time = 0.5})
        richLabel:removeFromParent(true)
        richLabel = nil
    end, 5.0)
    chatBubble:performWithDelay(function()
        -- chatBubbleTail:removeFromParent(true)
        tPlayer:removeChildByTag(tagID,true)
        --chatBubble:removeFromParent(true)
        --ChatBubbleMgr.ChatBubbleTable[tag] = nil
    end, ChatBubbleMgr.DEFAULT_CHAT_BUBBLE_SHOWTIME)
    --ChatBubbleMgr.ChatBubbleTable[tag] = chatBubble
end

return ChatBubbleMgr