local HDTime = require("src.Utils.HDTime")

local regUserName = nil
local regPassword = nil
local preRegData = nil

local userName = nil
local password = nil
local preLoginData = nil
local userID = -1
local userToken = nil
local gameZones = {}

local zoneID = -1
local gateList = {}

local charId = 0
local charList = {}

local preCreateCharData = nil

local myBaseInfo = nil
local realZones = {}

local lastLoginInfo = {}

local function getRegInfo()

	local ret = {}
	ret.username = regUserName
	ret.password = regPassword
	return ret
	
end

g_userID = -1
g_userToken = nil
function setLoginInfo(userID,userToken)
    g_userID = userID
    g_userToken = userToken
    print("set login info:",userID,userToken)
end
    
function getLoginInfo()
    print("get login info:",g_userID,g_userToken)
	local ret = {}
	ret.userID = g_userID
	ret.userToken = g_userToken
	return ret

end

local function getGameZoneCount()

	if gameZones then
		return #gameZones
	else
		return 0
	end

end

local function getGameZoneInfo(idx)

	-- Proto_L_Login_Types parseGameZoneInfo
	if gameZones then
		return gameZones[idx]
	end

end

local function getGameZoneIdx(id)

	for i = 1, #gameZones do
		if (nil ~= gameZones[i] and id == gameZones[i].zoneID) then
			return i
		end
	end
	return -1

end

local function getZoneID()

	return zoneID

end

local function getGateCount()

	if gateList then
		return #gateList
	else
		return 0
	end

end

local function getGateInfo(idx)

	-- Proto_L_Login_Types parseGateServerInfo
	if gateList then
		return gateList[idx]
	end

end

local function getCharID()

    return charId

end

local function getCharCount()

	if charList then
		return #charList
	else
		return 0
	end

end

local function getCharInfo(idx)

	-- Proto_Login_Types parseCharacterBriefInfo
	if charList then
		return charList[idx]
	end

end

local function getMyBaseInfo()

	-- Proto_Login_Types parseCharacterBaseInfo
	return myBaseInfo

end

local function getZoneCount()

	if realZones then
		return #realZones
	else
		return 0
	end

end

local function getZoneInfo(idx)

	-- Proto_Login_Types parseZoneLoginInfo
	if realZones then
		return realZones[idx]
	end

end

local function getLastLoginInfo()

	return lastLoginInfo

end

local function getSupposedZoneId()
	
	local latestId = -1
	-- if ((gameZones ~= {}) and (gameZones ~= nil)) then
	-- 	for i = 1, #gameZones do
	-- 		if gameZones[i].zoneID > latestId then
	-- 			latestId = gameZones[i].zoneID
	-- 		end
	-- 	end
	-- end
	if ((lastLoginInfo == {}) or (lastLoginInfo) == nil) then
		return latestId
	else
		local sameId = -1
		if ((gameZones ~= {}) and (gameZones ~= {})) then
			for i = 1, #gameZones do
				if gameZones[i].zoneID == lastLoginInfo.zone then
					sameId = lastLoginInfo.zone
				end
			end
		end
		if sameId == -1 then
			return latestId
		else
			return sameId
		end
	end
end

----------------------------------------------------

local function init()

	regUserName = nil
	regPassword = nil
	preRegData = nil

	userName = nil
	password = nil
	preLoginData = nil
	userID = -1
	gameZones = {}

	zoneID = -1
	gateList = {}

	charList = {}

	preCreateCharData = nil

	myBaseInfo = nil
	realZones = {}

	lastLoginInfo = {}

end

local function onCL_RegistMember_Req(data)

	regUserName = nil
	regPassword = nil
	preRegData = data

end

local function onLC_RegistMember_Ack(data)

	if (Proto.ErrorL.ERROR_LOGIN_OK == data.code) then
		regUserName = preRegData.username
		regPassword = preRegData.password
	end
	preRegData = nil

end

local function onLC_PlatformLogin_Ack(data)

	if (Proto.ErrorL.ERROR_LOGIN_OK == data.code) then
		userName = data.username
		password = data.password
		userID = data.userID
		gameZones = data.zones
	end

end

local function onCL_SelectZone_Req(id)

	zoneID = id

end

local function onLC_SelectZone_Ack(data)
    assert(false)
end

local function onGC_Login_Ack(data)

	if (Proto.Error.ERROR_OK == data.code) then
		charList = data.chars
	end

end

local function onMC_CreateChar_Ack(data)
	
    if (Proto.Error.ERROR_OK == data.code.value) then
        charId = data.charID
    end

end

local function onCM_CreateCharacter_Req(data)

	preCreateCharData = data

end

local function onMC_CreateCharacter_Ack(data)

	if (Proto.Error.ERROR_OK == data.code) then
		local charInfo = {
				characterID = data.charID,
				nickname = preCreateCharData.nickname,
				gender = preCreateCharData.gender,
				icon = preCreateCharData.iconID,
				level = 0,
				birthday = 0,
			}
		charList[#charList + 1] = charInfo
	end
	preCreateCharData = nil

end

local function onMC_SelectCharacter_Ack(data)

	if (Proto.Error.ERROR_OK == data.code) then
		myBaseInfo = data.baseInfo
		realZones = data.zones
	end

end

local function onGC_EnterZone_Ack(data)

	if (Proto.Error.ERROR_OK == data.code) then
		myBaseInfo = data.baseInfo
		HDTime.onServerCheckTime(data.serverTime)
	end

end

local function onZC_UpdateCash_Ntf(data)

	myBaseInfo.g_cash = data.gCash
	myBaseInfo.m_cash = data.mCash

end

local function onZC_UpdateLevel_Ntf(data)

	myBaseInfo.level = data.level
	myBaseInfo.exp = data.exp

end

local function onLC_LastLoginInfo_Ntf(data)

	lastLoginInfo = data

end

local GenInfo = {
	getRegInfo = getRegInfo,
	getLoginInfo = getLoginInfo,
	getGameZoneCount = getGameZoneCount,
	getGameZoneInfo = getGameZoneInfo,
	getGameZoneIdx = getGameZoneIdx,
	getZoneID = getZoneID,
	getGateCount = getGateCount,
	getGateInfo = getGateInfo,
	getCharCount = getCharCount,
	getCharID = getCharID,
	getCharInfo = getCharInfo,
	getMyBaseInfo = getMyBaseInfo,
	getZoneCount = getZoneCount,
	getZoneInfo = getZoneInfo,
	getLastLoginInfo = getLastLoginInfo,
	getSupposedZoneId = getSupposedZoneId,
	
	init = init,

	onCL_RegistMember_Req = onCL_RegistMember_Req,
	onLC_RegistMember_Ack = onLC_RegistMember_Ack,
	onCL_Login_Req = onCL_Login_Req,
	onLC_Login_Ack = onLC_Login_Ack,
	onLC_PlatformLogin_Ack = onLC_PlatformLogin_Ack,
	onCL_SelectZone_Req = onCL_SelectZone_Req,
	onLC_SelectZone_Ack = onLC_SelectZone_Ack,

	onGC_Login_Ack = onGC_Login_Ack,
	onMC_CreateChar_Ack = onMC_CreateChar_Ack,
	onCM_CreateCharacter_Req = onCM_CreateCharacter_Req,
	onMC_CreateCharacter_Ack = onMC_CreateCharacter_Ack,
	onMC_SelectCharacter_Ack = onMC_SelectCharacter_Ack,
	onGC_EnterZone_Ack = onGC_EnterZone_Ack,
	onLC_LastLoginInfo_Ntf = onLC_LastLoginInfo_Ntf,

	onZC_UpdateCash_Ntf = onZC_UpdateCash_Ntf,
	onZC_UpdateLevel_Ntf = onZC_UpdateLevel_Ntf,
}
return GenInfo