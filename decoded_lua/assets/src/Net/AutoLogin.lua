local AutoLogin = {}

local autoFlag = false

function AutoLogin.setAutoFlag(flag)

	autoFlag = flag

end

function AutoLogin.getAutoFlag()

	return autoFlag

end

return AutoLogin