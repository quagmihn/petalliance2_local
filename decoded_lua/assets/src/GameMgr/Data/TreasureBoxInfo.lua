local TreasureBoxInfo = {}

local treasureBoxInfoConfig = nil
local myTreasureBoxData = {}
local myTreasureBoxBuyData = nil
local isRequesting = false

local scheduler = require("src.framework.scheduler")
local treasureBoxTimeHandler = nil

local isTreasureBoxSended = false

function TreasureBoxInfo.Init()
    if treasureBoxInfoConfig==nil then
        treasureBoxInfoConfig = require("src.DatReader.TreasureBoxInfoConfig")
        treasureBoxInfoConfig.init()
    end
    myTreasureBoxData = {}
    myTreasureBoxBuyData = nil
    isRequesting = false
    
    if treasureBoxTimeHandler then
        scheduler.unscheduleGlobal(treasureBoxTimeHandler)
        treasureBoxTimeHandler = nil
    end
    
    isTreasureBoxSended = false
end

--[[
data.id=Proto.parseDWORD(entry); -- 宝箱ID
data.name=Proto.parseString(entry); -- 名称
data.imagePath=Proto.parseString(entry); -- 图片路径
data.CD=Proto.parseDWORD(entry); -- 开启时间
data.speedSeconds=Proto.parseVector(entry,Proto.parseWORD); -- 加速
data.awards=Proto.parseVector(entry,Proto.parseDWORD); -- 随机奖励
]]
function TreasureBoxInfo.getTreasureBoxInfoById(id)
    return treasureBoxInfoConfig.readEntryByID(id)
end

function TreasureBoxInfo.GetTreasureBoxData(callback)
    if isRequesting then
    	return
    end
    local LoginSend = require("src.Net.Send.LoginSend")
    local TreasureBoxSend = require("src.Net.Send.TreasureBoxSend")
    local function sendReq()
        NetInterface.send("GC_GETTREASUREBOXDATA_ACK", function()
            TreasureBoxSend.sendCG_GetTreasureBoxData_Req()
        end,function()
            myTreasureBoxBuyData = CharInfo.get().treasureboxbuy
            isRequesting = false
            if callback then
                callback()
            end
        end, function(code)
            isRequesting = false
            StandardTipsMgr.show(1,"GetTreasureBoxData failed code="..code)
        end)
    end
    if isTreasureBoxSended then
        sendReq()
    else
        NetInterface.send("GC_GetCharacterValues_Ack", function()
            isRequesting = true
            LoginSend.sendCG_GetCharacterValues_Req({"treasureBoxBuy"})
        end, function()
            isTreasureBoxSended = true
            sendReq()
        end, function(code)
            isRequesting = false
            TipsMgr.showError(nil, code)
        end)
    end
    
end

---time, type
function TreasureBoxInfo.getMyTreasureBoxData()
    --myTreasureBoxData = {{type=2,}, {type=1, time=CharInfo.getServerTime()-600}}
	return myTreasureBoxData
end

function TreasureBoxInfo.setMyTreasureBoxData(vec)
    if vec then
        myTreasureBoxData = vec
    end
end

function TreasureBoxInfo.addTodayBuyTimes()
    local count = TreasureBoxInfo.getTodayBuyTimes()+1
    myTreasureBoxBuyData = {count=count, time=CharInfo.getServerTime()}
end

function TreasureBoxInfo.getTodayBuyTimes()
    if myTreasureBoxBuyData then
        print("TreasureBoxInfo.getTodayBuyTimes", myTreasureBoxBuyData.time, myTreasureBoxBuyData.count)
        local dayDiff = CocosModuleMgr.getDayTimeDiff(myTreasureBoxBuyData.time, CharInfo.getServerTime())
        if dayDiff==0 then
            return myTreasureBoxBuyData.count
        end
    	return 0
    end
    return 0
end

function TreasureBoxInfo.checkRedPoint()
    if treasureBoxTimeHandler then
        scheduler.unscheduleGlobal(treasureBoxTimeHandler)
    end
    local timediff = nil
    for key, var in pairs(myTreasureBoxData) do
    	if var.time then
    		timediff = var.time-CharInfo.getServerTime()
    	end
    end
    if not timediff then
        StatusBarMgr.hideRedPoint(9)
    	return
    end
    print(timediff.."秒后，组队宝箱可领...")
    if timediff<0 then
        StatusBarMgr.addRedPoint(9)
    else
        StatusBarMgr.hideRedPoint(9)
        treasureBoxTimeHandler = scheduler.performWithDelayGlobal(function()
            StatusBarMgr.addRedPoint(9)
        end, timediff)
    end
end

return TreasureBoxInfo