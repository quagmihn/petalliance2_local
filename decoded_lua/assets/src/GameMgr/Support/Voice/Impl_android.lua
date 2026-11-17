local Impl = {}

function Impl.internalCreate(protokey,voiceRoot)
	local args = {protokey,voiceRoot}
	local sig = "(Ljava/lang/String;Ljava/lang/String;)V"
	local ok = luaj.callStaticMethod("com/fangcun/voice/VoiceManagerWrapper", "create", args, sig)
	if not ok then
		printError("call create voice manager method error !")
	end
end

function Impl.startRecording(unique_name)
    local args = {unique_name, "voiceMgr_onStartRecordingFailed"}
    local sig = "(Ljava/lang/String;Ljava/lang/String;)V"
    local ok = luaj.callStaticMethod("com/fangcun/voice/VoiceManagerWrapper", "startRecording", args, sig)
    if not ok then
        printError("startRecording invalid call")
    end
end

function Impl.stopRecording()
	local args = {"voiceMgr_onRecordingStopped","voiceMgr_onRecordingStoppedFailed"}
    local sig = "(Ljava/lang/String;Ljava/lang/String;)V"
    local ok = luaj.callStaticMethod("com/fangcun/voice/VoiceManagerWrapper", "stopRecording", args, sig)
    if not ok then
        printError("stopRecording invalid call")
    end
end

function Impl.cancelRecording()
	local args = {"voiceMgr_onRecordingCancelled"}
    local sig = "(Ljava/lang/String;)V"
    local ok = luaj.callStaticMethod("com/fangcun/voice/VoiceManagerWrapper", "cancelRecording", args, sig)
    if not ok then
        printError("cancelRecording invalid call")
    end
end

function Impl.postVoice(filePath)
	local args = {VoiceServerConfig.saveURL, filePath, "voiceMgr_onPostVoiceComplete", "voiceMgr_onPostVoiceFailed"}
    local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
    local ok = luaj.callStaticMethod("com/fangcun/voice/VoiceManagerWrapper", "postVoice", args, sig)
    if not ok then
        printError("post voice invalid call")
    end
end

function Impl.queryVoice(date, id, cache_uname)
	local args = {VoiceServerConfig.queryURL, date, id, cache_uname, "voiceMgr_onQueryVoiceSuccess", "voiceMgr_onQuertVoiceFailed"}
    local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
    local ok = luaj.callStaticMethod("com/fangcun/voice/VoiceManagerWrapper", "queryVoice", args, sig)
    if not ok then
        printError("query voice invalid call")
    end
end

function Impl.destroy()
	local args = {}
	local sig = "()V"
	local ok = luaj.callStaticMethod("com/fangcun/voice/VoiceManagerWrapper", "destroy", args, sig)
	if not ok then
		printError("call destroy voice manager method error !")
	end
end

return Impl;