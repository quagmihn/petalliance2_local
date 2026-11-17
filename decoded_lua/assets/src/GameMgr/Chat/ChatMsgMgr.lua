local ChatMsgMgr = {}

ChatMsgMgr.EMOJI_NUM = 25

ChatMsgMgr.emoji_tbl = {}
ChatMsgMgr.emoji_path = {}

function ChatMsgMgr.Init()
    print("ChatMsgMgr初始化")
    
    for var=1, ChatMsgMgr.EMOJI_NUM do
        local emojiID = string.format("%02d", var)
    	ChatMsgMgr.emoji_tbl[var] = "%[em"..emojiID.."%]"
    	ChatMsgMgr.emoji_path[var] = "UI/Chat/Emoji/em"..emojiID..".png"
    end

end

function ChatMsgMgr.addSystemMsg(msg)
    if not ChatUIMgr.load_finished then
        --用聊天室打印调试信息时，暂时禁止未load时添加信息
	    return
    end
    local Pmsg = ChatMsgMgr.chatMessageProcessor("", msg, 2)
    ChatUIMgr.addOutLabel(msg, 2)
    ChatUIMgr.addChatMessage(Pmsg, 2)
end

function ChatMsgMgr.addWorldMsg(name, msg)
    local str = ChatMsgMgr.chatMessageProcessor(name, msg, 4)
    ChatUIMgr.addChatMessage(str, 4)
    ChatUIMgr.addOutLabel(name..": "..msg, 4)
end

function ChatMsgMgr.addNativeMsg(name, msg, charID)
    local str = ChatMsgMgr.chatMessageProcessor(name, msg, 5)
    ChatUIMgr.addChatMessage(str, 5)
    ChatUIMgr.addOutLabel(name..": "..msg, 5)
    local txt = ChatMsgMgr.chatMessageProcessor("", msg)
    if SceneMgr.mapType~="_battle" then
        if name==CharInfo.getNickName() then
            ChatBubbleMgr.showChatBubble(txt)
        else
            ChatBubbleMgr.showChatBubble(txt, name, charID)
        end
    end
end

---分割带中文的字符串
--@param s string 字符串
--@param n int 长度
function ChatMsgMgr.SubUTF8String(s, n)    
    local dropping = string.byte(s, n+1)    
    if not dropping then return s end    
    if dropping >= 128 and dropping < 192 then    
        return ChatMsgMgr.SubUTF8String(s, n-1)    
    end    
    return string.sub(s, 0, n)    
end

---检查字符是否是中文
--@param c string 被检查字符
function ChatMsgMgr.CheckCharChinese(c)
    local dropping = string.byte(c)
    if dropping >= 128 then
    	return true
    end
    return false
end

---聊天内容处理器，生成RichLabel所需要的格式字符串
--@param name string 玩家名称
--@param message string 玩家所说的内容
--@param type int 类型
function ChatMsgMgr.chatMessageProcessor(name, message, type, cupLv)
    if not cupLv then
        cupLv = 0
    end
    local format_str = 
    [[
    [#extra]
    ]]
    local format_text = [[{"color":"#colorInfo","text":"#textInfo"}]]
    local format_image = [[{"image":"#imageInfo","text":"#textInfo"}]]
    local cupImage = [[{"image":"#imageInfo","text":"#textInfo"}]]
    local cupImageStr = ""
    local tab_color = "FFFFFF"

    type = type or 6
    local color_str = [[{"color":"FFFFFF","text":"]]
    if type==4 then
        color_str = [[{"color":"67ED15","text":"]]
        tab_color = "67ED15"
    elseif type==3 then
        color_str = [[{"color":"FFA800","text":"]]
        tab_color = "FFA800"
    elseif type==2 then
        color_str = [[{"color":"FF4200","text":"]]
        tab_color = "FF4200"
    elseif type==5 then
        color_str = [[{"color":"7EABE2","text":"]]
        tab_color = "7EABE2"
    elseif type==6 then
        color_str = [[{"color":"EA00FF","text":"]]
        tab_color = "EA00FF"
    elseif type==7 then  --组队
        color_str = [[{"color":"C4E6FC","text":"]]
        tab_color = "C4E6FC"
    elseif type==8 then  --留言板
        color_str = [[{"color":"C4E6FC","text":"]]
        tab_color = "C4E6FC"
    end

    for tags,info in pairs(ChatMsgMgr.emoji_tbl) do
        message = string.gsub(message, "#ems#"..tags.."#eme#", "")
        message = string.gsub(message, info, "#ems#"..tags.."#eme#")
    end

    if cupLv > 0 and cupLv < 10 then
        local tmp_str = "icon_cup_lv"..cupLv
        local cupImagePath = "UI/CommonFiles/"..tmp_str..".png"
        cupImageStr = string.gsub(cupImage, "#imageInfo", cupImagePath)
        cupImageStr = string.gsub(cupImageStr, "#textInfo", "口")
    end

    message = "#start#"..string.gsub(string.gsub(message, "#ems#", "#end##ems#"),"#eme#","#eme##start#").."#end#"
    local name_str = string.gsub(format_text, "#colorInfo", "F0FF00")
    namePlus = cupLv > 0 and "  "..name..": " or name..": "
    name_str = string.gsub(name_str, "#textInfo", namePlus)
    if type ==2 then
        local tab_str = string.gsub(format_text, "#colorInfo", tab_color)
        tab_str = type~=8 and string.gsub(tab_str, "#textInfo", CocosModuleMgr.createStringWithFormat({"【<1>】", "chat"..type})) or ""
        format_str = string.gsub(format_str, "#extra", tab_str..","..message)
    else
        if name=="" or name==nil then
            format_str = string.gsub(format_str, "#extra", message)
        else
            local tab_str = string.gsub(format_text, "#colorInfo", tab_color)
            tab_str = type~=8 and string.gsub(tab_str, "#textInfo", CocosModuleMgr.createStringWithFormat({"【<1>】", "chat"..type})) or ""
            format_str = cupLv > 0 and string.gsub(format_str, "#extra", tab_str..","..cupImageStr..","..name_str..","..message) or
                                       string.gsub(format_str, "#extra", tab_str..","..name_str..","..message)
        end      
    end


    for tags,info in pairs(ChatMsgMgr.emoji_tbl) do  
        local tmp_str = ChatMsgMgr.emoji_path[tags]
        local str = string.gsub(format_image, "#imageInfo", tmp_str)
        str = string.gsub(str, "#textInfo", "口")
        format_str = string.gsub(format_str, "#ems#"..tags.."#eme#", str..",")
    end

    format_str = string.gsub(format_str, "#start##end#", "")
    format_str = string.gsub(format_str, "#start#", color_str)
    format_str = string.gsub(format_str, "#end#", [["},]])

    format_str = string.gsub(format_str, "},%]", "}%]")

    return format_str 
end

return ChatMsgMgr