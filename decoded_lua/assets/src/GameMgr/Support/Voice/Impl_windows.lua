local Impl = {}

Impl._currentRecordName = nil

function Impl.internalCreate(protokey,voiceRoot)
   print("windows voice manager create! root directory "..voiceRoot)
end

function Impl.startRecording(unique_name)
	assert(Impl._currentRecordName == nil)
	print("windows voice manager start recording !")
	Impl._currentRecordName = unique_name
end

function Impl.stopRecording()
	print("windows voice manager stop recording !")
	voiceMgr_onRecordingStopped("0,2,voices/"..Impl._currentRecordName)
	Impl._currentRecordName = nil
end

function Impl.cancelRecording()
	print("windows voice manager cancel recording !")
	Impl._currentRecordName = nil
end

function Impl.postVoice(filePath)
	print("windows voice manager post recording to "..VoiceServerConfig.saveURL.."!")
	voiceMgr_onPostVoiceComplete("2016-8-10,25sdf154de5w8")
end

function Impl.queryVoice(date, id, cache_uname)
	print("windows voice manager query recording ! date "..date.." id "..id.." from url :"..VoiceServerConfig.queryURL)
	voiceMgr_onQueryVoiceSuccess("voices/"..cache_uname)
end

function Impl.destroy()

end

return Impl