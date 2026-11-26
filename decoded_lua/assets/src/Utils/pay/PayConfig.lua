--
-- Author: Leon Lee
-- Date: 2016-08-09 
--
--[[
充值配置文件，用来初始化充值的商品信息
--]]
local PayConfig = {}
local payProduct = 
{
        
}

local function genRechargeInfoTable(data,ismonthCard)
    local infoTable = {}
    ismonthCard = ismonthCard or false
    local prefix = "N"
    if ismonthCard == true then 
        prefix = "M" 
        infoTable.zuanshi = data.initMCash
    else
        if data.bonusRate~=0 then 
            infoTable.zuanshi  = data.mCash*data.bonusRate
        else
            infoTable.zuanshi  = data.mCash+data.giftMCash
        end
    end 

    infoTable.productId = prefix..data.id --data.orderName
    if device.platform == "android" then 
        infoTable.price = data.money
    else
        infoTable.price = data.money
    end
    
    local infostr = data.name
    infoTable.productName = infostr
    infoTable.productDesc = infostr
    return infoTable 
end

local function initMonthCardRechargeInfo()
    local monthVec = ItemInfo.getMonthCardRechargeInfoAllId()
    for i = 1,#monthVec do 
        local infoTable = genRechargeInfoTable(monthVec[i],true)
        print("payProduct[monthVec[i].id]:"..monthVec[i].id)
        payProduct[monthVec[i].id] = infoTable
    end
end

local function initNormalRechargeInfo()
    local normalVec = ItemInfo.getNormalRechargeInfoAllId()
    for i = 1,#normalVec do 
        local infoTable = genRechargeInfoTable(normalVec[i])
        print("payProduct[normalVec[i].id]:"..normalVec[i].id)
        payProduct[normalVec[i].id] = infoTable
    end
end




function PayConfig.Init()
   initMonthCardRechargeInfo()
   initNormalRechargeInfo() 
end

function PayConfig.genOrderNo(productId)
    --roleId+timetick+randomnum
    math.newrandomseed()
    local num = math.random(100,999)
    local proidstr = string.upper(tostring(productId))
    local roleidstr = tostring(CharInfo.getCharID())
    local orderno = roleidstr.."_"..proidstr.."_"..tostring(os.time()).."_"..tostring(num)
    
    return orderno  
end

function PayConfig.setPayMask()
    local resName = "Scene/PayMask.csb"
    local tag = ""
    
    local mask = CSResourceMgr.createRes(SceneMgr.getRunningScene, resName, tag)
    mask:setLocalZOrder(CocosModuleMgr.ZORDER_LOADING)
    CSResourceMgr.setRelativePosition(resName, 320, 480, tag)
end
function PayConfig.removePayMask()
    CSResourceMgr.removeCSObjectByTag("Scene/PayMask.csb","")
end

local currentPrice = nil
function PayConfig.pay(id)
    if device.platform == "android" then 
        print("PayConfig.pay:"..id)
        currentPrice = payProduct[id].price
        AndroidFunction.payOnAndroid(payProduct[id])
    end

    if device.platform == "ios" then 
        local pay_channel = 1  -- "com.joygames.mxm.two"  主包默认pay_channel
        local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getBundleIdentifier", nil)
        if ok and ret == "com.alpha.monster2.luotianyi" then 
            pay_channel = 2
        end
    
        local params = {}
        params.gameOrderNO = PayConfig.genOrderNo(payProduct[id].productId)
        params.productId   = payProduct[id].productId
        params.productName = LuaSqlite.getLanguageByKey(payProduct[id].productName)
        params.productDesc = LuaSqlite.getLanguageByKey(payProduct[id].productDesc)
        params.price       = payProduct[id].price  -- 商品价格，单位分
        params.amount      = 1
        params.productExt  = "{\"pay_channel\":\""..pay_channel.."\"}"  -- "cp ext info"

        params.roleId     = tostring(CharInfo.getCharID())
        params.roleLevel  = CharInfo.getLevel()
        params.roleName   = CharInfo.getNickName()
        params.serverId   = tostring(LoginViewMgr.getCurrentWorld()) or "1"
        params.serverName = "serverName"..params.serverId
        
--        iOSFunction.pay(params)
--        iOSFunction.sendPayGenLog(payProduct[id],params.gameOrderNO)
    end
end

-- Private-server checkout uses the original RechargeTestCmd protocol only.
-- The order key is created once per click and reused by any duplicate packet.
-- Automatic reconnect resend stays disabled for this non-repeatable action.
-- No SDK or external receipt is involved.
function PayConfig.payLocal(id, isMonthCard)
    local kind = isMonthCard and "M" or "N"
    local params = {payID = id, appID = "local:"..kind..tostring(id)..":"..
        PayConfig.genOrderNo(kind..tostring(id))}
    NetInterface.sendWithBlock("GC_RechargeTestCmd_Ack", function()
        local VipSend = require("src.Net.Send.VipSend")
        VipSend.sendCG_RechargeTestCmd_Req(params)
    end, function()
        PurchaseViewMgr.showTipMsg(2)
        PurchaseViewMgr.refreshLocalCheckout(isMonthCard)
    end, function(code)
        PurchaseViewMgr.showTipMsg(1)
        print("Local recharge rejected:", code)
    end, nil, false)
end

function PayConfig.onPaySuccess(orderNO,sdkOrderNO)
    --PurchaseViewMgr.showTipMsg(2)
    print("PayConfig.onPaySuccess is:",orderNO,sdkOrderNO,currentPrice)
    local params = {}
    params.orderNO = orderNO
    params.sdkOrderNO = sdkOrderNO
    if orderNO ~= nil and sdkOrderNO~=nil then 
        if device.platform == "android" then 
            print("currentPrice is....................",currentPrice)
            if currentPrice~=nil then 
                AndroidFunction.AdTrackingOnPay({
                    userid = tostring(CharInfo.getCharID()),
                    orderid = tostring(orderNO),
                    amount  = currentPrice,
                    curency = "CNY",
                    paytype      = "androidPay",
                })
            end
        end
        GameLogMgr.OnGameStateChange(GameLogMgr.UserGameState.STATE_PAY_CALLBACK,params)
    else
        if orderNO == nil then print("orderNO is nil") end 
        if sdkOrderNO == nil then print ("sdkOrderNO is nil") end
    end
end

function PayConfig.onPayError(errorcode)
    PurchaseViewMgr.showTipMsg(1)
end



return PayConfig
