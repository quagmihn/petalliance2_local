local NetLog = {}
local HDOS = require("src.Utils.HDOS")

local logHandle = nil
local platforms = {
	["windows"] = true,
	["android"] = true,
	["ios"] = true,
}

function NetLog.init()

	if (nil ~= platforms[device.platform]) then
        local path = CONFIG_STORE_PATH .. "NetLog/"
		HDOS.mkdir(path)

		local logFile = path .. "NetLog_" .. os.date("%Y_%m_%d_%H_%M_%S", os.time()) .. ".txt"
		logHandle = io.open(logFile, "w")
	end

end

function NetLog.log(txt)

	if (nil ~= platforms[device.platform] and nil ~= logHandle) then
		logHandle:write(os.date("%Y-%m-%d %H:%M:%S  ", os.time()))
		logHandle:write(txt .. "\n")
		logHandle:flush()
	end
    --ChatMsgMgr.addSystemMsg(ChatMsgMgr.SubUTF8String(txt, 32).."...")

end

return NetLog