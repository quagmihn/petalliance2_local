local Impl = {}

function Impl.internalCreate(protokey,voiceRoot)
    luaoc.callStaticMethod("VoiceManagerWrapper", "create", {key=protokey, root=voiceRoot})
end

function Impl.startRecording(unique_name)
    luaoc.callStaticMethod("VoiceManagerWrapper", "startRecording", {name=unique_name, errorcall=voiceMgr_onStartRecordingFailed})
end

function Impl.stopRecording()
    luaoc.callStaticMethod("VoiceManagerWrapper", "stopRecording", {callback=voiceMgr_onRecordingStopped, 
        errorcall=voiceMgr_onRecordingStoppedFailed})
end

function Impl.cancelRecording()
    luaoc.callStaticMethod("VoiceManagerWrapper", "cancelRecording", {callback=voiceMgr_onRecordingCancelled})
end

function Impl.postVoice(filePath)
    luaoc.callStaticMethod("VoiceManagerWrapper", "postVoice", {url=VoiceServerConfig.saveURL, path=filePath, 
        callback=voiceMgr_onPostVoiceComplete, errorcall=voiceMgr_onPostVoiceFailed})
end

function Impl.queryVoice(date, id, cache_uname)
    luaoc.callStaticMethod("VoiceManagerWrapper", "queryVoice", {url=VoiceServerConfig.queryURL, date=date, id=id, name=cache_uname, 
        callback=voiceMgr_onQueryVoiceSuccess, errorcall=voiceMgr_onQuertVoiceFailed})
end

function Impl.destroy()
    luaoc.callStaticMethod("VoiceManagerWrapper", "destroy", nil)
end

return Impl