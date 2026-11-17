local baseTimeServer = 0
local baseTimeClient = 0

local TIMEFMT_HMS = 0
local TIMEFMT_MS = 1
local TIMEFMT_S = 2

function onServerCheckTime(time)

	baseTimeServer = time
	baseTimeClient = os.time()

end

function getCurTime()

	local time = os.time() + baseTimeServer - baseTimeClient
	return time

end

function getDateString(time)

	return os.date("%Y-%m-%d %H:%M:%S", time)

end

function getDateTable(time)

	return os.date("*t", time)

end

function getTimeDiff(time, fmt)

	local diff = time - getCurTime()
	if (diff < 0) then
		diff = 0
	end

	return formatTime(diff, fmt)

end

function formatTime(time, fmt)

	local retFmt = fmt or TIMEFMT_HMS
	local ret = {}
	if (TIMEFMT_S == retFmt) then
		ret.sec = time
	elseif (TIMEFMT_MS == retFmt) then
		ret.sec = time % 60
		ret.min = (time - ret.sec) / 60
	else
		ret.sec = time % 60
		time = (time - ret.sec) / 60
		ret.min = time % 60
		ret.hour = (time - ret.min) / 60
	end

	return ret

end

local HDTime = {
	TIMEFMT_HMS = TIMEFMT_HMS,
	TIMEFMT_MS = TIMEFMT_MS,
	TIMEFMT_S = TIMEFMT_S,

	onServerCheckTime = onServerCheckTime,
	getCurTime = getCurTime,
	getDateString = getDateString,
	getDateTable = getDateTable,
	getTimeDiff = getTimeDiff,
	formatTime = formatTime,
}
return HDTime