local Store = require("src.framework.cc.sdk.Store")

local IAPMgr = {}

local plist_tag = 16

IAPMgr.lastPurchaseTime = nil
IAPMgr.currentPayInfo = nil

function IAPMgr.Init()
    IAPMgr.lastPurchaseTime = nil
    IAPMgr.currentPayInfo = nil
end

function IAPMgr.getIAPData(transactionIdentifier)
    if type(transactionIdentifier) ~= "string" then
        printError("iOSFunction.getIAPData() - invalid transactionIdentifier")
        return
    end

    return UserSettings.get(transactionIdentifier, plist_tag)
end

function IAPMgr.saveIAPData(gameOrderNO, charID, serverId, transactionIdentifier, receipt)
    if type(transactionIdentifier) ~= "string" then
        print(transactionIdentifier, type(transactionIdentifier))
        printError("iOSFunction.saveIAPData() - invalid transactionIdentifier")
        return false
    end

    local data = UserSettings.get(transactionIdentifier, plist_tag)
    if data and data ~= "nil" then
        print("transaction exist!")
        return false
    end

    data = {}
    data[transactionIdentifier] = {
        charID      = charID,
        serverId    = serverId,
        gameOrderNO = gameOrderNO,
        receipt     = receipt,
    }

    UserSettings.set(data, plist_tag)

    return true
end

function IAPMgr.clearIAPData(transactionIdentifier)
    if type(transactionIdentifier) ~= "string" then
        printError("iOSFunction.clearIAPData() - invalid transactionIdentifier")
        return
    end

    local data = UserSettings.get(transactionIdentifier, plist_tag)

    if not data then
        return false
    end

    local valPlist = cc.FileUtils:getInstance():getValueMapFromFile(UserSettings.getFullPath(plist_tag))
    for key, var in pairs(valPlist) do
        if key == transactionIdentifier then
            valPlist[key] = nil
        end
    end

    cc.FileUtils:getInstance():writeToFile(valPlist, UserSettings.getFullPath(plist_tag))

    return true
end

function IAPMgr.setCurrentPayInfo(info)
    if type(info) ~= "table" then
        printError("IAPMgr.setCurrentPayInfo() - invalid payinfo")
        return false
    end

    IAPMgr.currentPayInfo = info

    return true
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


function IAPMgr.missingOrderRequest()
    local payInfos = UserSettings.getAll(plist_tag)

    if not payInfos then
        printError("iOSFunction.missingOrderRequest() - payInfos is nil")
        return
    end
    
    if type(payInfos) ~= "table" then
        printError("iOSFunction.missingOrderRequest() - invalid payInfos")
        return
    end

    for transactionIdentifier, payInfo in pairs(payInfos) do
        print("transactionIdentifier is",transactionIdentifier, payInfo)
        if payInfo ~= "nil" then
            local urlStr = CocosModuleMgr.createStringWithFormat({iOSFunction.RECHARGE_URL, iOSFunction.GAME_APP_ID, payInfo.serverId, payInfo.gameOrderNO, payInfo.receipt})
            sendReceipt(urlStr, function()
                print("missing order request done.")
                IAPMgr.clearIAPData(transactionIdentifier)
            end)
        else
            IAPMgr.clearIAPData(transactionIdentifier)
        end
    end
end

return IAPMgr
