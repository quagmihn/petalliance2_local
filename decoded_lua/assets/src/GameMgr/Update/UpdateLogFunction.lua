--UpdateLogFunction.lua
--Date
--此文件由[BabeLua]插件自动生成

local UpdateLogFunction = {}

function UpdateLogFunction.getYMD()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,YMDStr = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getYMD", args, sig)
	    return YMDStr
    end
    if device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getYMD", nil)
        return ret
    end    
end

function UpdateLogFunction.getYM()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,YMStr = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getYM", args, sig)
	    return YMStr
    end
    if device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getYM", nil)
        return ret
    end
end

function UpdateLogFunction.getYear()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,YearStr = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getYear", args, sig)
	    return YearStr
    end
    if device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getYear", nil)
        return ret
    end
end

function UpdateLogFunction.getMonth()
    if device.platform == "android" then    
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,MonthStr = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getMonth", args, sig)
	    return MonthStr
    end
    if device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getMonth", nil)
        return ret
    end
end

function UpdateLogFunction.getDay()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,DayStr = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getDay", args, sig)
	    return DayStr
    end
    if device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getDay", nil)
        return ret
    end
end

function UpdateLogFunction.getHour()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,HourStr = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getHour", args, sig)
	    return HourStr
    end
    if device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getHour", nil)
        return ret
    end
end

function UpdateLogFunction.getMiniute()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,MiniuteStr = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getMiniute", args, sig)
	    return MiniuteStr
    end
    if device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getMinute", nil)
        return ret
    end
end

function UpdateLogFunction.getWeekOfTheYear()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,WeekOfTheYearStr = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getWeekOfTheYear", args, sig)
	    return WeekOfTheYearStr
    end
    if device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getWeekOfTheYear", nil)
        return ret
    end
end

function UpdateLogFunction.getIpAddress()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,IpAddressStr = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getIpAddress", args, sig)
	    return IpAddressStr
    end
    if device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getIpAddress", nil)
        return ret
    end
end

function UpdateLogFunction.getDeviceModel()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,DeviceModel = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getDeviceModel", args, sig)
	    return DeviceModel
    end
    if device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getDeviceModel", nil)
        return ret
    end
end

function UpdateLogFunction.getOSVer()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,OSVer = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getOSVer", args, sig)
	    return OSVer
    end
    if device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getOSVer", nil)
        return ret
    end
end


function UpdateLogFunction.getMacAddress()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,macAddress = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getMacAddress", args, sig)
	    return macAddress
    end
    if device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getMacAddress", nil)
        return ret
    end
end


function UpdateLogFunction.getUDID()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,UDID = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getUDID", args, sig)
	    return UDID
    end
    if device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getUDID", nil)
        return ret
    end
end

function UpdateLogFunction.getNetworkState()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,networkstate = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getNetworkState", args, sig)
	    return networkstate
    end
    if device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getNetworkState", nil)
        return ret
    end
end

function UpdateLogFunction.getDataLogUrl()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,url = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getDataLogUrl", args, sig)
        return url 
    end
    if device.platform == "ios" then
        return "http://192.168.240.1:8080/telemetry/data"
    end
end

function UpdateLogFunction.getPlatFormTag()
    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,platformtag = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getPlatFormTag", args, sig)
        return platformtag
    --local sig = "(II)I"
    end
    if device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getPlatFormTag", nil)
        return ret
    end
end

function UpdateLogFunction.getChannelId()
    if device.platform == "android" then
        local args = {}
        local sig = "()I"
        local ok,channelid = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getChannelId", args, sig)
        return channelid
    end
    if device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getChannelId", nil)
        return ret
    end
end

function UpdateLogFunction.getPayChannel()
    if device.platform == "android" then
        local args = {}
        local sig = "()I"
        local ok,channelid = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getPayChannel", args, sig)
        return channelid
    end
    if device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getPayChannel", nil)
        return ret
    end
end


return UpdateLogFunction

--endregion
