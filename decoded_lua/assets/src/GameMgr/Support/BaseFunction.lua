local BaseFunction = {}

local scheduler = nil

function BaseFunction.Init()
    print("BaseFunction初始化")
    
    scheduler = require("src.framework.scheduler")
end

function BaseFunction.onEnterBackground()
    --TipsMgr.show(nil, CocosModuleMgr.createRichLabelString({{color="FFFFFF", text="游戏进入"}, {color="FF2A2A", text="后台"}}))
end

function BaseFunction.onEnterForeground()
    local function checkTime()
        if CharInfo.getCharID()~=0 then
            local function send()
                NetInterface.sendWithBlock("GC_GetServerTime_Ack", function()
                    local LoginSend = require("src.Net.Send.LoginSend")
                    LoginSend.sendCG_GetServerTime_Req()
                end, function()
                    iWatchConnectivity.checkCatchPet()
                    TeamInfo.checkTeamStatus()
                    TeamInfo.checkTeamMapStatus()
                    TreeInfoView.refreshTownTree()
                    WorldBossInfo.checkBossMapStatus()
                end, function()
                    send()
                end, 1)
            end
            send()
        end
    end
    local function checkVideo()
        if CocosModuleMgr.VideoPlayer then
            if device.platform == "android" then
                CocosModuleMgr.VideoPlayer:play()
            else
                CocosModuleMgr.VideoPlayer:resume()
            end
        end
    end
    
    if device.platform == "android" then
        scheduler.performWithDelayGlobal(function()
            checkTime()
            checkVideo()
        end, 0.5)
    else
        scheduler.performWithDelayGlobal(function()
            checkTime()
            checkVideo()
        end, 0.5)
    end    
    
    --TipsMgr.show(nil, CocosModuleMgr.createRichLabelString({{color="FFFFFF", text="游戏返回"}, {color="BBFF25", text="前台"}}))
end

function BaseFunction.isTraditionalChinese()
    if device.platform == "ios" then
        return iOSFunction.isTraditionalChinese()
    elseif device.platform == "android" then
        return AndroidFunction.isTraditionalChinese()
    end
end

---注册本地推送
--时间方案： 1.time=os.time()+x, timezone=nil;以手机时间为基准的时间方案
--          2.time=CharInfo.getServerTime()+x, timezone=CharInfo.getServerTimeZone();以服务器时间为基准的时间方案
--@param time int 推送时间(since1970的秒数)
--@param timezone int 推送时区，不填则默认为手机的时区
--@param title string 推送显示的内容
--@param message string 推送的详细消息，ios一般看不到，可以不填
--@param key int 推送标识，填SystemOptionsMgr.PUSH_KEY_VALUES的index
--@param ptype int 推送类型，0为不重复，1为每日重复
function BaseFunction.registerLocalNotification(time, timezone, title, message, key, ptype)
    if type(key)=="number" then
        if SystemOptionsMgr.PUSH_SETTINGS[key]~="open" then
            print("推送标识 index:"..key, "设置不开启")
            return
        end
    end
    print("注册推送，推送标识index:"..key)
    timezone = timezone or "Default"
    title = title or ""
    message = message or ""
    ptype = ptype or 0
    title = LuaSqlite.getLanguageByKey(title)
    message = LuaSqlite.getLanguageByKey(message)
    local tag = SystemOptionsMgr.PUSH_KEY_VALUES[key] or key
    if device.platform == "ios" then
        iOSFunction.registerLocalNotification(time, timezone, title, message, tag, ptype)
    elseif device.platform == "android" then
        AndroidFunction.registerLocalNotification(time, timezone, title, message, tag, ptype)
    end
end

---取消本地推送
--@param key int 推送标识，填SystemOptionsMgr.PUSH_KEY_VALUES的index
function BaseFunction.cancelLocalNotificationWithKey(key)
    local tag = SystemOptionsMgr.PUSH_KEY_VALUES[key] or key
    if device.platform == "ios" then
        iOSFunction.cancelLocalNotificationWithKey(tag)
    elseif device.platform == "android" then
        AndroidFunction.cancelLocalNotificationWithKey(tag)
    end
end

return BaseFunction