local HDKey = {}

local sharedUserDefault = CCUserDefault:sharedUserDefault()

local DEFAULT_UID = "DEFAULT_UID"
local DEFAULT_PSWD = "DEFAULT_PSWD"

local UID = "UID"
local PSWD = "PSWD"
local REM = "REM"
local AUTOATTACK = "AUTOATTACK"


local function readSavedUID()

	return sharedUserDefault:getStringForKey(UID, DEFAULT_UID)

end

local function readSavedPSWD()

	return sharedUserDefault:getStringForKey(PSWD, DEFAULT_PSWD)

end

local function readAutoAttack()

	return sharedUserDefault:getBoolForKey(AUTOATTACK, false)

end

local function readRemOption()
	
	return sharedUserDefault:getBoolForKey(REM, false)

end

----------------------------------------------------------------

local function logUID(uid)

	sharedUserDefault:setStringForKey(UID, uid)
	sharedUserDefault:flush()

end

local function logPSWD(pswd)

	sharedUserDefault:setStringForKey(PSWD, pswd)
	sharedUserDefault:flush()

end

local function autoAttack(autoattack)

	sharedUserDefault:setBoolForKey(AUTOATTACK, autoattack)
	sharedUserDefault:flush()

end

local function eraseLoginInfo()

	sharedUserDefault:setStringForKey(UID, DEFAULT_UID)
	sharedUserDefault:setStringForKey(PSWD, DEFAULT_PSWD)
	sharedUserDefault:flush()

end

local function writeRemOption(bool)

	if (bool == true) or (bool == false) then
		sharedUserDefault:setBoolForKey(REM, bool)
		sharedUserDefault:flush()
	else
		sharedUserDefault:flush()
	end

end


HDKey = {
	DEFAULT_UID = DEFAULT_UID,
	DEFAULT_PSWD = DEFAULT_PSWD,

	readSavedUID = readSavedUID,
	readSavedPSWD = readSavedPSWD,
	readRemOption = readRemOption,
	readAutoAttack = readAutoAttack,

	logUID = logUID,
	logPSWD = logPSWD,
	autoAttack = autoAttack,
	eraseLoginInfo = eraseLoginInfo,
	writeRemOption = writeRemOption,
}

return HDKey
