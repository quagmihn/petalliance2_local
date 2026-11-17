-- Local/offline replacement for the vendor telemetry module.
-- Keep the methods expected by the Lua callers, but never initialize SDKs or
-- create an HTTP request. ClientInfo remains local game-protocol metadata.
local XFangCunLogSender = {
    FirstMainScene = 0,
    LoginView = 0,
    UpdateStartTime = 0,
    UpdateEndTime = 0,
    UpdateFailTime = 0,
    LoadTimeLogStart = 0,
    GameGuideStart = 0,
    GameGuideEnd = 0,
}

local version = "0.2"
local channel_id = 1

function XFangCunLogSender.setVer(ver)
    version = ver or version
end

function XFangCunLogSender.getVer()
    return version
end

function XFangCunLogSender.Init()
    return
end

function XFangCunLogSender.getAppid()
    return channel_id
end

function XFangCunLogSender.log(operation, datas)
    return
end

function XFangCunLogSender.logActivation()
    return
end

function XFangCunLogSender.LoginUI()
    return
end

function XFangCunLogSender.Identification()
    return
end

function XFangCunLogSender.logLoad()
    return
end

function XFangCunLogSender.Tutorial(params)
    return
end

function XFangCunLogSender.logUpdateStart()
    return
end

function XFangCunLogSender.logUpdateEnd()
    return
end

function XFangCunLogSender.logUpdateFail()
    return
end

function XFangCunLogSender.Install()
    return
end

function XFangCunLogSender.logPayGenerate(params)
    return
end

function XFangCunLogSender.logPayCallBack(params)
    return
end

function XFangCunLogSender.createUserInfoTable()
    return {
        -- GameLogMgr still sends CG_CLIENTINFO_REQ to the local game server.
        -- Keep every Proto_Login.lua string field non-nil while avoiding
        -- device identifiers and vendor SDK calls in this private build.
        ip = "127.0.0.1",
        device_model = "offline",
        os_name = "Android",
        os_ver = "offline",
        mac_addr = "00:00:00:00:00:00",
        udid = "offline-device",
        app_ver = version,
        app_channel = tostring(channel_id),
        network = "offline",
        device_screen = "0x0",
        channel_id = channel_id,
        platform_tag = "local",
        group_id = 0,
    }
end

return XFangCunLogSender
