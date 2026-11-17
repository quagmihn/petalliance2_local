local ActivityInterface = {}


---请求购买成长基金
--@param aId int 活动id
--@param successCallBack function 成功回调
--@param failCallBack(code) function 购买失败的回调
function ActivityInterface.buyGrowthFund(aId,successCallBack,failCallBack)
    NetInterface.sendWithBlock("GC_BuyGrowthFund_Ack",function()
        local ActivitySend = require("src.Net.Send.ActivitySend") 
        ActivitySend.sendCG_BuyGrowthFund_Req(aId)
    end,
    function()
        if successCallBack~=nil then 
            successCallBack()
        end
    end,
    function(code)
        StandardTipsMgr.show(1, "error code:"..code)
        TipsMgr.showError(nil, code)
        if failCallBack~=nil then
            failCallBack(code)
        end
    end)
end

---请求领取成长基金
--@param level int 
--@param successCallBack function 成功回调
--@param failCallBack(code) function 购买失败的回调
function ActivityInterface.fetchGrowthFundAwards(level,successCallBack,failCallBack)
    NetInterface.sendWithBlock("GC_FetchGrowthFundAwards_Ack",function()
        local ActivitySend = require("src.Net.Send.ActivitySend") 
        ActivitySend.sendCG_FetchGrowthFundAwards_Req(level)
    end,
    function()
        if successCallBack~=nil then 
            successCallBack()
        end
    end,
    function(code)
        StandardTipsMgr.show(1, "error code:"..code)
        TipsMgr.showError(nil, code)
        if failCallBack~=nil then
            failCallBack(code)
        end
    end)    
end

---请求领取充值奖励
--@param aId int 活动id
--@param mCash int 充值额度
--@param successCallBack function 成功回调
--@param failCallBack(code) function 购买失败的回调
function ActivityInterface.fetchRechargeAwards(aId,mCash,successCallBack,failCallBack)
    NetInterface.sendWithBlock("GC_FetchRechargeAwards_Ack",function()
        local ActivitySend = require("src.Net.Send.ActivitySend") 
        local params = {}
        params.aID = aId
        params.mCash = mCash
        ActivitySend.sendCG_FetchRechargeAwards_Req(params)
    end,
    function()
        if successCallBack~=nil then 
            successCallBack()
        end
    end,
    function(code)
        StandardTipsMgr.show(1, "error code:"..code)
        TipsMgr.showError(nil, code)
        if failCallBack~=nil then
            failCallBack(code)
        end
    end)    
end


---请求领取消费奖励
--@param aId int 活动id
--@param mCash int 充值额度
--@param successCallBack function 成功回调
--@param failCallBack(code) function 购买失败的回调
function ActivityInterface.fetchConsumeAwards(aId,mCash,successCallBack,failCallBack)
    NetInterface.sendWithBlock("GC_FetchConsumeAwards_Ack",function()
        local ActivitySend = require("src.Net.Send.ActivitySend") 
        local params = {}
        params.aID = aId
        params.mCash = mCash
        ActivitySend.sendCG_FetchConsumeAwards_Req(params)
    end,
    function()
        if successCallBack~=nil then 
            successCallBack()
        end
    end,
    function(code)
        StandardTipsMgr.show(1, "error code:"..code)
        TipsMgr.showError(nil, code)
        if failCallBack~=nil then
            failCallBack(code)
        end
    end)    
end


---把字符串用固定的符号分割
--@param srcString string 源字符串
--@param separator string 分割的字符串符号
--@return returnstr string 最后返回的字符串符号
function ActivityInterface.addStringSeprator(srcString,separator)
    local strString = srcString
    local returnstr = ""
   
    
    for i=1,#strString do 
        local linkstr = string.sub(strString,i,i)
        if i ~= #strString then 
            returnstr = (returnstr..linkstr..separator)
        else
            returnstr = (returnstr..linkstr)
        end
    end
    
    return returnstr
end

---把字符串一个个切割变成table
--@param srcString string 源字符串
--@return returnstrTable string 最后返回切割后的字符串的table
function ActivityInterface.changeStrToTable(srcString)
    local strString = srcString
    local returnstrTable={}
    
    for i=1,#strString do 
        local linkstr = string.sub(strString,i,i)
        table.insert(returnstrTable,linkstr)
    end
    
    return returnstrTable
end

---判断日期是否有效(当日有效，不当日无效)
--@param yday number 一种日期格式
function ActivityInterface.getDayDiff(yday)
    local dinfo = tonumber(yday)
    if yday==nil then
    	return -1
    end
    local year = string.sub(dinfo, 1, 4)
    local month = string.sub(dinfo, 5, 6)
    local day = string.sub(dinfo, 7, 8)
    local hour = string.sub(dinfo, 9, 10)

    local sec = os.time({day=day, month=month, year=year, hour=hour, minute=30, second=0})
    local tsec = sec+CocosModuleMgr.getLocalTimeZone()-CharInfo.getServerTimeZone()
    local daydiff = CocosModuleMgr.getDayTimeDiff(tsec, CharInfo.getServerTime())
    return daydiff
end

return ActivityInterface