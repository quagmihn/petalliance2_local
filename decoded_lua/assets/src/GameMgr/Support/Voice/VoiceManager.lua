local VoiceManager = {}
require("src.GameMgr.Support.Voice.VoiceServerConfig")

VoiceManager._currentPlatform = nil

local function registFunctions(platform)
    local file = "src.GameMgr.Support.Voice.Impl_"..platform
    local implTable = require(file)
    local mt = getmetatable(VoiceManager)
    if mt == nil then
        setmetatable(VoiceManager,{})
        mt = getmetatable(VoiceManager)
    end
    mt.__index = function(t,k)
        local ret = rawget(t,k)
        if ret ~= nil then
            return ret
        else
            assert(implTable[k], "invail call function : "..k)
            return implTable[k]
        end 
    end
end

function VoiceManager.Init()
	VoiceManager._create()
end

function VoiceManager._create()
    local platform = device.platform
    assert(platform == "windows" or platform == "android" or platform == "ios", "no impl voice platform :"..platform)
    registFunctions(platform)
    local voiceRoot = string.sub(CONFIG_STORE_PATH,1,-1)
    VoiceManager.internalCreate(VoiceServerConfig.PROTOKEY,voiceRoot)
    VoiceManager._currentPlatform = platform
end


function voiceMgr_onStartRecordingFailed(errCode)
	print("voiceMgr_onStartRecordingFailed.errCode",errCode)
end

function voiceMgr_onRecordingStopped(parContent)
	local pars = string.split(parContent,",")
    local length = pars[1]
    local cachePath = pars[2]
    TownChatMgr.postVoiceToServer(length,cachePath)
end

function voiceMgr_onRecordingStoppedFailed()
    
end

function voiceMgr_onRecordingCancelled()
	
end

function voiceMgr_onPostVoiceComplete(parContent)
	local pars = string.split(parContent,",")
    local date = pars[1]
    local id = pars[2]
    TownChatMgr.setVoiceChatMsg(date, id)
end

function voiceMgr_onPostVoiceFailed(errorMsg)
	StandardTipsMgr.show(1, "VoiceCode1")
end

function voiceMgr_onQueryVoiceSuccess(parContent)
    local pars = string.split(parContent,",")
    local length = pars[1]
    local cachePath = pars[2]
	print("voiceMgr_onQueryVoiceSuccess.cachedFilePath",cachePath)
    TownChatMgr.setVoiceCacheTable(cachePath)
    TownChatMgr.isQueryOver(true)
end

function voiceMgr_onQuertVoiceFailed(errorMsg)
	TownChatMgr.isQueryOver(false)
end


return VoiceManager

