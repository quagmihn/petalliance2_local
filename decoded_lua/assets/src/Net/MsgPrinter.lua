require("src.Net.Proto.ProtoInclude")

local MSGPRINT_NONE = 0 -- 不输出
local MSGPRINT_ONLYID = 1 -- 只输出协议号
local MSGPRINT_ALL = 2 -- 输出协议内容
local debugLevel = MSGPRINT_ONLYID

local function rcvMsg(msg, tag)

	if (nil == msg) then
		return
	end

	local name = tag or msg.msgID
	if (MSGPRINT_ALL == debugLevel) then
		dumpXP(msg, "[INFO] RcvMsg " .. name)
	elseif (MSGPRINT_ONLYID == debugLevel) then
        if msg.msgID~=Proto.Command.GC_CHAT_NTF then
            print("[INFO] RcvMsg " .. name .. " " .. msg.msgID)
	    end
	end

end

local MsgPrinter = {
	rcvMsg = rcvMsg,
}
return MsgPrinter