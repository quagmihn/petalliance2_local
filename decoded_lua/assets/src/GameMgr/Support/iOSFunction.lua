local iOSFunction = {}

local ipInfo = "192.168.240.1:8080/ios/login"
--"192.168.240.1:8080/ios/login" 内网
--"192.168.240.1:80/29/login" 外网

if device.platform == "ios" then
    local ok, ver = luaoc.callStaticMethod("iOSsystemFunc", "getVersion", nil)
    if ok and (tonumber(ver) == 9997 or tonumber(ver) == 9998) then   -- ios内网测试版本
        ipInfo = "192.168.240.1:8080/ios/login"
    end
end
local IAPMgr = require("src.GameMgr.Support.IAPMgr")
--iOSFunction.LOGIN_URL = "http://"..ipInfo.."?userID=<1>&userName=<2>&sdkAccessToken=<3>&platform=ios&appId=30"
iOSFunction.LOGIN_URL = "http://"..ipInfo.."?platform=ios&appId=48&sdkUserId=<1>&sdkAccessToken=<2>&channelId=<3>"
iOSFunction.RECHARGE_URL = "http://192.168.240.1:8080/recharge/30?appId=<1>&serverId=<2>&gameOrderNO=<3>&receipt=<4>"
iOSFunction.GAME_APP_ID  = 30
local StoreLoaded = false
local StoreConnecting = false
local iOSProducts = {}
local currentPayInfo = nil
local channelId  = 45

function iOSFunction.Init()
    StoreLoaded = false
    StoreConnecting = false

    local port = 80
    local sur  = "portalsdk"
    -- if iOSFunction.isReviewVer() then  
    --     port = 82
    --     sur  = "debug"
    -- end
    print("iOSFunction.Init gai",iOSFunction.getBundleIdentifier()) 
    if iOSFunction.getBundleIdentifier() == "com.fangcun.mxm2.china" then
        iOSProducts = 
        {
            [21]  = "com.fangcun.mxm2.china.diam60",
            [22]  = "com.fangcun.mxm2.china.diam300double",
            [23]  = "com.fangcun.mxm2.china.diam300",
            [24]  = "com.fangcun.mxm2.china.diam980",
            [25]  = "com.fangcun.mxm2.china.diam1980double",
            [26]  = "com.fangcun.mxm2.china.diam1980",
            [27]  = "com.fangcun.mxm2.china.diam3280",
            [28]  = "com.fangcun.mxm2.china.diam6480double",
            [29]  = "com.fangcun.mxm2.china.diam6480",

            [201] = "com.fangcun.mxm2.china.diamMpass",
        }
    elseif iOSFunction.getBundleIdentifier() == "zBmU.wOu.rMkbl0.NJwS" then
        channelId = 45
        ipInfo = "192.168.240.1:8080/ios/login"
        iOSFunction.LOGIN_URL = "http://"..ipInfo.."?platform=ios&channelId="..channelId.."&appId=30&sdkUserId=<1>&sdkAccessToken=<2>&sdkAppId=<3>"
        iOSFunction.RECHARGE_URL = "http://192.168.240.1:8080/recharge/30?appId=<1>&serverId=<2>&gameOrderNO=<3>&receipt=<4>"
        iOSProducts = 
        {
            [21]  = "zBmU.wOu.rMkbl0.NJwS_6",
            [22]  = "zBmU.wOu.rMkbl0.NJwS.sc_30",
            [23]  = "zBmU.wOu.rMkbl0.NJwS_30",
            [24]  = "zBmU.wOu.rMkbl0.NJwS_98",
            [25]  = "zBmU.wOu.rMkbl0.NJwS.sc_198",
            [26]  = "zBmU.wOu.rMkbl0.NJwS_198",
            [27]  = "zBmU.wOu.rMkbl0.NJwS_328",
            [28]  = "zBmU.wOu.rMkbl0.NJwS.sc_648",
            [29]  = "zBmU.wOu.rMkbl0.NJwS_648",

            [201] = "zBmU.wOu.rMkbl0.NJwS_25",
        }
    elseif iOSFunction.getBundleIdentifier() == "rlaBsv.seaqsM.gcBzen.mjS" then
        channelId = 45
        ipInfo = "192.168.240.1:8080/ios/login"
        iOSFunction.LOGIN_URL = "http://"..ipInfo.."?platform=ios&channelId="..channelId.."&appId=30&sdkUserId=<1>&sdkAccessToken=<2>&sdkAppId=<3>"
        iOSFunction.RECHARGE_URL = "http://192.168.240.1:8080/recharge/30?appId=<1>&serverId=<2>&gameOrderNO=<3>&receipt=<4>"
        iOSProducts = 
        {
            [21]  = "rlaBsv.seaqsM.gcBzen.mjS_6",
            [22]  = "rlaBsv.seaqsM.gcBzen.mjS.sc_30",
            [23]  = "rlaBsv.seaqsM.gcBzen.mjS_30",
            [24]  = "rlaBsv.seaqsM.gcBzen.mjS_98",
            [25]  = "rlaBsv.seaqsM.gcBzen.mjS.sc_198",
            [26]  = "rlaBsv.seaqsM.gcBzen.mjS_198",
            [27]  = "rlaBsv.seaqsM.gcBzen.mjS_328",
            [28]  = "rlaBsv.seaqsM.gcBzen.mjS.sc_648",
            [29]  = "rlaBsv.seaqsM.gcBzen.mjS_648",

            [201] = "rlaBsv.seaqsM.gcBzen.mjS_25",
        }
    elseif iOSFunction.getBundleIdentifier() == "com.HuanXiangChongWuJingLing1" then
        channelId = 44
        ipInfo = "192.168.240.1:8080/ios/login"
        iOSFunction.LOGIN_URL = "http://"..ipInfo.."?platform=ios&appId=30&sdkUserId=<1>&sdkAccessToken=<2>&sdkAppId=<3>"
        iOSFunction.RECHARGE_URL = "http://192.168.240.1:8080/recharge/30?appId=<1>&serverId=<2>&gameOrderNO=<3>&receipt=<4>"
        iOSProducts = 
        {
        	-- [21]  = "N10",
         --    [22]  = "N2",
         --    [23]  = "N3",
         --    [24]  = "N4",
         --    [25]  = "N5",
         --    [26]  = "N6",
         --    [27]  = "N7",
         --    [28]  = "N8",
         --    [29]  = "N9",

         --    [201] = "M10001",
            [21]  = "com.jxx.HuanXiangChongWuJingLing1_356_6",
            [22]  = "com.jxx.HuanXiangChongWuJingLing1lb_356_30",
            [23]  = "com.jxx.HuanXiangChongWuJingLing1_356_30",
            [24]  = "com.jxx.HuanXiangChongWuJingLing1_356_98",
            [25]  = "com.jxx.HuanXiangChongWuJingLing1lb_356_198",
            [26]  = "com.jxx.HuanXiangChongWuJingLing1_356_198",
            [27]  = "com.jxx.HuanXiangChongWuJingLing1_356_328",
            [28]  = "com.jxx.HuanXiangChongWuJingLing1lb_356_648",
            [29]  = "com.jxx.HuanXiangChongWuJingLing1_356_648",

            [201] = "com.jxx.HuanXiangChongWuJingLing1_356_25",
        }
    elseif iOSFunction.getBundleIdentifier() == "com.KouDaiJingLingWuYu" then
        channelId = 47
        ipInfo = "192.168.240.1:8080/ios/login"
        iOSFunction.LOGIN_URL = "http://"..ipInfo.."?platform=ios&appId=30&sdkUserId=<1>&sdkAccessToken=<2>&sdkAppId=<3>"
        iOSFunction.RECHARGE_URL = "http://192.168.240.1:8080/recharge/30?appId=<1>&serverId=<2>&gameOrderNO=<3>&receipt=<4>"
        iOSProducts = 
        {
            [21]  = "com.jxx.KouDaiJingLingWuYu_354_6",
            [22]  = "com.jxx.KouDaiJingLingWuYulb_354_30",
            [23]  = "com.jxx.KouDaiJingLingWuYu_354_30",
            [24]  = "com.jxx.KouDaiJingLingWuYu_354_98",
            [25]  = "com.jxx.KouDaiJingLingWuYulb_354_198",
            [26]  = "com.jxx.KouDaiJingLingWuYu_354_198",
            [27]  = "com.jxx.KouDaiJingLingWuYu_354_328",
            [28]  = "com.jxx.KouDaiJingLingWuYulb_354_648",
            [29]  = "com.jxx.KouDaiJingLingWuYu_354_648",

            [201] = "com.jxx.KouDaiJingLingWuYu_354_25",
        }
    elseif iOSFunction.getBundleIdentifier() == "com.QiKaJingLingDuiJue" then
        channelId = 48
        ipInfo = "192.168.240.1:8080/ios/login"
        iOSFunction.LOGIN_URL = "http://"..ipInfo.."?platform=ios&appId=30&sdkUserId=<1>&sdkAccessToken=<2>&sdkAppId=<3>"
        iOSFunction.RECHARGE_URL = "http://192.168.240.1:8080/recharge/30?appId=<1>&serverId=<2>&gameOrderNO=<3>&receipt=<4>"
        iOSProducts = 
        {
            [21]  = "com.jxx.QiKaJingLingDuiJue_315_6",
            [22]  = "com.jxx.QiKaJingLingDuiJuelb_315_30",
            [23]  = "com.jxx.QiKaJingLingDuiJue_315_30",
            [24]  = "com.jxx.QiKaJingLingDuiJue_315_98",
            [25]  = "com.jxx.QiKaJingLingDuiJuelb_315_198",
            [26]  = "com.jxx.QiKaJingLingDuiJue_315_198",
            [27]  = "com.jxx.QiKaJingLingDuiJue_315_328",
            [28]  = "com.jxx.QiKaJingLingDuiJuelb_315_648",
            [29]  = "com.jxx.QiKaJingLingDuiJue_315_648",

            [201] = "com.jxx.QiKaJingLingDuiJue_315_25",
        }
    end
    --临时设置

    currentPayInfo = nil
end


local function sendReceipt(urlStr, callback_)
    local function callback(event)
        local ok = (event.name == "completed")
        local request = event.request
        if event.name then print("request event.name = " .. event.name) end
        if not ok then
            if request:getErrorMessage()~="" then
                print("请求失败 "..request:getErrorMessage())
            end
            return
        end
        local code = request:getResponseStatusCode()
        if code ~= 200 then
            print("请求错误，代码 "..request:getResponseStatusCode())
            return
        end
        if callback_ then callback_() end
    end
    
    local request = network.createHTTPRequest(callback, urlStr, "GET")
    request:setTimeout(10)
    request:start()
end

function iOSFunction.isReviewVer()
    if device.platform ~= "ios" then return end

    local ver = iOSFunction.getVersion()
    local updateMgr = require("src.GameMgr.Update.UpdateMgr")
    print("current ver, revierw ver", ver, updateMgr.reviewVer)
    if ver == updateMgr.reviewVer then 
        return true 
    end
    
    return false
end

function iOSFunction.goToAppStore()
    QuestInfo.commentBeginTime = CharInfo.getServerTime()
    UserSettings.set({commentBeginTime = CharInfo.getServerTime()}, 15)  -- 评论开始时间存本地
    
    if device.platform ~= "ios" then return end

    --local alreadyGoToAppStore = UserSettings.get("alreadyGoToAppStore", 15)
    --if alreadyGoToAppStore == 1 then return end

    local _appID = 1126014282
    luaoc.callStaticMethod("iOSsystemFunc", "goToAppStore", {appID = _appID})
    
    --UserSettings.set({alreadyGoToAppStore = 1}, 15)
end

function iOSFunction.checkPlatform()
    if device.platform == "ios" then
		return true
	end
	return false
end

function iOSFunction.LoadProducts(scene, loadCallback)
    local serverTbl = {}
    serverTbl.serverId = tostring(LoginViewMgr.getCurrentWorld())
    serverTbl.roleId = tostring(CharInfo.getCharID())
    serverTbl.roleName = CharInfo.getNickName()
    luaoc.callStaticMethod("SdkInterface", "saveServerWithSid", serverTbl)
    loadCallback()
    --[[
    if  iOSFunction.getBundleIdentifier() == "com.fangcun.mxm2.china" then
        IAPMgr.missingOrderRequest()
        CharInfo.getNickName()

        if not iOSFunction.checkPlatform() then
            return
        end
        local Store = require("src.framework.cc.sdk.Store")
        if not StoreLoaded then
            local function storeCallback(sender, transaction)
                local payInfo = currentPayInfo or {}

                local info_ = IAPMgr.getIAPData(transaction.transaction.transactionIdentifier)
                if info_ and info_ ~= "nil" then
                    payInfo.gameOrderNO = info_.gameOrderNO
                    payInfo.serverId    = info_.serverId
                    payInfo.charID      = info_.charID
                else
                    payInfo.charID = CharInfo.getCharID()
                end

                if StoreConnecting then
                    if transaction.transaction.state == "purchased" then

                        TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"purchased."}))

                        IAPMgr.saveIAPData(payInfo.gameOrderNO, payInfo.charID, payInfo.serverId, transaction.transaction.transactionIdentifier, crypto.encodeBase64(transaction.transaction.receipt))

                        local urlStr = CocosModuleMgr.createStringWithFormat({iOSFunction.RECHARGE_URL, iOSFunction.GAME_APP_ID, payInfo.serverId, payInfo.gameOrderNO, crypto.encodeBase64(transaction.transaction.receipt)})

                        sendReceipt(urlStr, function()
                            print("游戏服发钻石。。。")
                            print("finish transaction...")
                            currentPayInfo = nil
                            IAPMgr.clearIAPData(transaction.transaction.transactionIdentifier)
                        end)


                    elseif transaction.transaction.state == "cancelled" then
                        TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"user cancelled..."}))
                    else
                        TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"transaction failed..."}))
                    end
                    LoadingView.hide()
                    StoreConnecting = false
                    Store.finishTransaction(transaction.transaction)
                    else
                    print("store disconnecting...")
                    if transaction and transaction.transaction then
                        Store.finishTransaction(transaction.transaction)
                    end
                end
            end
            print("init CCStore...")

            Store.init(handler(scene, storeCallback))

        -- if iOSFunction.isReviewVer() then
        --     Store.setReceiptVerifyMode(cc.CCStoreReceiptVerifyModeDevice, true)
        -- else
        --     Store.setReceiptVerifyMode(cc.CCStoreReceiptVerifyModeDevice, false)
        -- end

            local function loadProducts(sender, products)
                LoadingView.hide()
                loadCallback(products)
                StoreLoaded = true
            end

            local productsTable = {}
            for _, pID in pairs(iOSProducts) do
                table.insert(productsTable, pID)
            end

            Store.loadProducts(productsTable, handler(scene, loadProducts))
            LoadingView.show(scene)
        else
            loadCallback()
        end
        ]]
        --loadCallback()
    --end
end

-- function iOSFunction.LoadProducts(scene, loadCallback)
--     if not iOSFunction.checkPlatform() then
--     	return
--     end
--     local Store = require("src.framework.cc.sdk.Store")
--     if not StoreLoaded then
--         local function storeCallback(sender, transaction)
--             if StoreConnecting then
--                 if transaction.transaction.state == "purchased" then
--                     TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"商品购买成功~"}))
--                     Store.finishTransaction(transaction.transaction)
--                 elseif transaction.transaction.state == "cancelled" then
--                     TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"用户取消购买~"}))
--                 else
--                     TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"商品购买失败~"}))
--                 end
--                 LoadingView.hide()
--                 StoreConnecting = false
--             end
--         end
--         Store.init(handler(scene, storeCallback))
--         local function loadProducts(sender, products)
--             LoadingView.hide()
--             loadCallback(products)
--             StoreLoaded = true
--         end
--         Store.loadProducts(iOSProducts, handler(scene, loadProducts))
--         LoadingView.show(scene)
--     else
--         loadCallback()
--     end
-- end



function iOSFunction.Test()
    if not iOSFunction.checkPlatform() then
        return
    end

    luaoc.callStaticMethod("iOSsystemFunc", "testFunc", {})
end

function iOSFunction.isTraditionalChinese()
    local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "isTraditionalChinese", nil)
    if ok then
        print("SystemFunction.isTraditionalChinese", ret)
        if ret==0 then
            return true
        else
            return false
        end
    else
        print("SystemFunction.isTraditionalChinese error")
        return false
    end
end

function iOSFunction.registerLocalNotification(time, timezone, title, message, key, type)
    luaoc.callStaticMethod("iOSsystemFunc", "registerLocalNotification", {time=time, timezone=timezone, title=title, message=message,
        key=key, type=type})
end

function iOSFunction.cancelLocalNotificationWithKey(key)
    luaoc.callStaticMethod("iOSsystemFunc", "cancelLocalNotificationWithKey", {key=key})
end

function iOSFunction.getYMD()
    local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getYMD", nil)
    return ret
end

function iOSFunction.getYM()
    local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getYM", nil)
    return ret
end

function iOSFunction.getYear()
    local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getYear", nil)
    return ret
end

function iOSFunction.getMonth()
    local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getMonth", nil)
    return ret
end

function iOSFunction.getDay()
    local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getDay", nil)
    return ret
end

function iOSFunction.getHour()
    local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getHour", nil)
    return ret
end

function iOSFunction.getMinute()
    local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getMinute", nil)
    return ret
end

function iOSFunction.getWeekOfTheYear()
    local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getWeekOfTheYear", nil)
    return ret
end


function iOSFunction.getIpAddress()
    local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getIpAddress", nil)
    return ret
end

function iOSFunction.getDeviceModel()
    local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getDeviceModel", nil)
    return ret
end

function iOSFunction.getOSVer()
    local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getOSVer", nil)
    return ret
end


function iOSFunction.getMacAddress()
    local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getMacAddress", nil)
    return ret
end


function iOSFunction.getUDID()
    local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getUDID", nil)
    return ret
end

function iOSFunction.getNetworkState()
    local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getNetworkState", nil)
    return ret
end

function iOSFunction.getDataLogUrl()
--    local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getDataLogUrl", nil)
--    return ret
    return "http://192.168.240.1:8080/telemetry/data"
end

function iOSFunction.getPlatFormTag()
    local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getPlatFormTag", nil)
    return ret
end

function iOSFunction.getBundleIdentifier()
    if not iOSFunction.checkPlatform() then
        return false
    end

    local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getBundleIdentifier", nil)
    return ret
end

function iOSFunction.getChannelId()
    --local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getChannelId", nil)
    local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getBundleIdentifier", nil)
    
    local channelId = 1
    if ok and ret then
        if ret == "com.joygames.mxm.two" then
            channelId = 1
        elseif ret == "com.alpha.monster2.luotianyi" then
            channelId = 2
        elseif ret == "com.joygames.monster" then
            channelId = 3
        elseif ret == "com.joygames.monsterworld" then
            channelId = 4
        end
    end

    return channelId
end

function iOSFunction.getVersion()
    local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getVersion", nil)
    print("iOSFunction.getVersion()", ret)
    
    if ok then return tonumber(ret) end
end

function iOSFunction.addSkipButton()
    local size = cc.Director:getInstance():getOpenGLView():getViewPortRect()
    luaoc.callStaticMethod("iOSsystemFunc", "addSkipButton",{x=0,y=0,width=70,height=70,callback=globalSkipVideoPlay})
end

function iOSFunction.delSkipButton()
    luaoc.callStaticMethod("iOSsystemFunc", "delSkipButton",nil)
end

function iOSFunction.showWebPage(url,horizonalScroll,verticalScroll)
    local params = {}
    params.url = url
    params.horizonalScroll = "true"
    params.verticalScroll = "true"
    if not horizonalScroll then params.horizonalScroll = "false" end
    if not verticalScroll then params.verticalScroll = "false" end
    luaoc.callStaticMethod("iOSsystemFunc", "showWebPage",params)
end

--AOF: appId, appKey, channelId, channelName, isDebug
function iOSFunction.initSdk(params, listener)
    params.listener = listener or function(key, jsonStr)
    	print("AOF Sdk listener, ", key)
        local cjson = require("cjson")
        local NetMgr = require("src.Net.NetMgr")
        local tbl = cjson.decode(jsonStr)
        if tbl then
        	for key, var in pairs(tbl) do
        		print("info:", key, var)
        	end
        end
        if key=="InitSuccess" then
        elseif key=="InitError" then
            StandardTipsMgr.show(1, "AF SDK init Failed!")
        elseif key=="LoginSuccess" then
            LoadingView.show(SceneMgr.getRunningScene)
            local function callback(event)
                local ok = (event.name == "completed")
                local request = event.request
                if event.name then print("request event.name = " .. event.name) end
                if not ok then
                    print("login fc callback not ok: "..request:getErrorMessage())
                    return
                end
                LoadingView.hide()
                local code = request:getResponseStatusCode()
                if code ~= 200 then
                    print("login fc callback error: "..request:getErrorMessage(),code)
                    TipsMgr.showError(nil, code)
                    return
                end
                local responseString = request:getResponseString()
                print("login fc responseString: "..responseString)
                local userToken = cjson.decode(responseString)
                if not userToken or userToken.message~="success" then
                    StandardTipsMgr.show(1, "Login error!")
                	return
                end
                userToken.userId = userToken.username
                AllSDKManager.FangCun.userid_token = userToken
                NetMgr.getServerList()
            end
            local sdkAppId = tbl.sdkAppId or 21
            --"http://"..ipInfo.."?platform=ios&appId=48&sdkUserId=<1>&sdkAccessToken=<2>&channelId=<3>"
            local urlStr = CocosModuleMgr.createStringWithFormat({iOSFunction.LOGIN_URL, tbl.ParamUserId,
                tbl.ParamToken,tbl.channelId})
            urlStr = string.gsub(urlStr, "+", "%%2B")
            local request = network.createHTTPRequest(callback, urlStr, "POST")
            print("Login Url:POST"..urlStr)
            request:setTimeout(10)
            request:start()
        elseif key=="LoginCancel" then
            print("LoginCancel========")
            globalReloginGame()
        elseif key=="LoginError" then
        elseif key=="PaySuccess" then
            if currentPayInfo then
                iOSFunction.AdTrackingOnPay({
                    account = tostring(CharInfo.getCharID()),
                    orderId = currentPayInfo.gameOrderNO,
                    amount  = currentPayInfo.price,
                    currencyType = "CNY",
                    payType      = "iosPay",
                })
                TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"transaction PaySuccess..."}))
                LoadingView.hide()
                StoreConnecting = false
--                local orderNO = IOSGameOrderNO  -- 方寸订单号
--                local sdkOrderNO = ""          -- 卓游订单号
--                PayConfig.onPaySuccess(orderNO,sdkOrderNO)
                --print("支付PaySuccess ~~~~~~~~",tbl.code ,tbl.msg)
                currentPayInfo = nil
            end
        elseif key=="PayError" then
            TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"transaction PayError..."}))
            LoadingView.hide()
            StoreConnecting = false
        elseif key=="DebugVersion" then
            LoginViewMgr.DEBUG_MODE = true
            NetMgr.IS_SERVERLIST_PUBLISH = nil
        end
    end
    luaoc.callStaticMethod("SdkInterface", "init", params)
    iOSFunction.getVersion()
end

function iOSFunction.login()
    luaoc.callStaticMethod("SdkInterface", "login", nil)
end

function iOSFunction.logout()
    luaoc.callStaticMethod("SdkInterface", "logout", nil)
end

--AOF: gameOrderNO, productId, productName, productDesc, (i)price, productExt, 
--(i)amount, roleId, (i)roleLevel, roleName, serverId, serverName
function iOSFunction.pay(params)
    --print("iospay===========",sz_T2S(params))
    currentPayInfo = params

end

local function urlEncode(s)  
     s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)  
    return string.gsub(s, " ", "+")  
end 

function iOSFunction.BuyItem(scene, id)
    print("iOSFunction.BuyItem() - id:",id)
    -- if true then
    --     return
    -- end
    
    if not iOSFunction.checkPlatform() then
        return
    end

    
    if StoreConnecting then
        TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"当前正在购买中，请稍候再试~"}))
        return
    end
    --if iOSFunction.getBundleIdentifier() == "com.fangcun.mxm2.china" then
    --    local Store = require("src.framework.cc.sdk.Store")
    --    if false == iOSFunction.isReviewVer() then
    --        Store.setReceiptVerifyMode(cc.CCStoreReceiptVerifyModeNone, false)
    --    end
    --    Store.purchase(iOSProducts[id])
	--	LoadingView.show(scene)
    --	StoreConnecting = true
    --else
    --    local pay_channel = 30
        --currentPayInfo.productId = iOSProducts[id] 
        --print("currentPayInfo===",sz_T2S(currentPayInfo))
        local cjson = require("cjson")
        local extable = {gameOrderNO=currentPayInfo.gameOrderNO,Amount=currentPayInfo.amount}

        currentPayInfo.productExt = tostring(cjson.encode(extable))
        --print("currentPayInfo.productExt",currentPayInfo.productExt)
        currentPayInfo.productExt = crypto.encodeBase64(currentPayInfo.productExt)
        --crypto.encodeBase64(transaction.transaction.receipt)
        -- currentPayInfo.productExt  = "{\"cpOrderID\":\""..currentPayInfo.gameOrderNO.."\"}"
        currentPayInfo.productExt = urlEncode(currentPayInfo.productExt)
        luaoc.callStaticMethod("SdkInterface", "pay", currentPayInfo)
    --end

    
        
end

function iOSFunction.setRoleInfo(info)
    if type(info.gcash) ~= "number" or device.platform ~= "ios" then
        return
    end
    if info.levelup then
        info.levelup = 1
    else
        info.levelup = 0
    end

    --info.roleName = CharInfo.getNickName() or "test"
    info.vipLevel = CharInfo.getVIPLevel() or 0
    luaoc.callStaticMethod("SdkInterface", "setRoleInfo", info)
end

function iOSFunction.sendPayGenLog(productData,orderno)
    print("orderno & price:"..orderno,productData.price)
    currentPayInfo.amount = productData.price
    local params = {}
    params.zuanshi = productData.zuanshi
    params.cash = productData.price
    params.sn_cp = orderno
    params.create_time = GameLogMgr.roleInfo.roleCreateTime
    local totalmoney = 0 
    if CharInfo.get().recharge then
        totalmoney = CharInfo.get().recharge.totalMoney or 0
    end
    params.total_pay = totalmoney
    GameLogMgr.OnGameStateChange(GameLogMgr.UserGameState.STATE_PAY_GENERATE,params)
end

-- function iOSFunction.sendPayGenLog(productData,orderno)
--     print("orderno & price:"..orderno,productData.price)

--     local params = {}
--     params.zuanshi = productData.zuanshi
--     params.cash = productData.price
--     params.sn_cp = orderno
--     params.create_time = GameLogMgr.roleInfo.roleCreateTime
--     local totalmoney = 0 
--     if CharInfo.get().recharge then
--         totalmoney = CharInfo.get().recharge.totalMoney or 0
--     end
--     params.total_pay = totalmoney
--     GameLogMgr.OnGameStateChange(GameLogMgr.UserGameState.STATE_PAY_GENERATE,params)
-- end

-- //*************************   AdTrackingSDK functions   *********************************
-- appId, channelId
function iOSFunction.AdTrackingInit(parameters)
    luaoc.callStaticMethod("SdkInterface", "AdTrackingInit", parameters)
end

-- account
function iOSFunction.AdTrackingOnRegister(parameters)
    luaoc.callStaticMethod("SdkInterface", "AdTrackingOnRegister", parameters)
end

-- account
function iOSFunction.AdTrackingOnLogin(parameters)
    luaoc.callStaticMethod("SdkInterface", "AdTrackingOnLogin", parameters)
end

-- name
function iOSFunction.AdTrackingOnCreateRole(parameters)
    luaoc.callStaticMethod("SdkInterface", "AdTrackingOnCreateRole", parameters)
end

-- account, orderId, (i)amount, currencyType, payType
function iOSFunction.AdTrackingOnPay(parameters)
    luaoc.callStaticMethod("SdkInterface", "AdTrackingOnPay", parameters)
end

return iOSFunction
