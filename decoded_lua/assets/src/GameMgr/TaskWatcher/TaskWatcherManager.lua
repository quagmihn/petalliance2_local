--region TaskWatcherManager.lua
--Date 2016.10.6
--此文件由[BabeLua]插件自动生成
--负责管理所有游戏系统的反馈信息，专为7日任务而生
--endregion

local TaskWatcherManager = {}

TaskWatcherManager.TaskType = 
{
     TASK_TYPE_MEIRILIBAO           =   1,
     TASK_TYPE_LEIJICHONGZHI        =   2,
     TASK_TYPE_FUBENTONGGUAN        =   3,  
     TASK_TYPE_ZUDUIFUBEN           =   4,
     TASK_TYPE_ZUDUIFUBENCISHU      =   5,  
     TASK_TYPE_ZDFBYAOQINGHAOYOU    =   6, 
     TASK_TYPE_CHAOZHILIBAO         =   7, 
     TASK_TYPE_JINGJICHANG          =   8, 
     TASK_TYPE_ZHANDOULI            =   9,
     TASK_TYPE_RENWUDENGJI          =   10, 
     TASK_TYPE_LOSTTOWERCENGSHU     =   11,  
     TASK_TYPE_LOSTTOWERCHUANSONG   =   12, 
     TASK_TYPE_LOSTTOWERCHONGZHI    =   13, 
     TASK_TYPE_LOSTTOWERHUIFU       =   14,
     TASK_TYPE_QIANGHUACHONGWU      =   15,
     TASK_TYPE_CHONGWUFANGSHENG     =   16,
     TASK_TYPE_CHONGWUJINENG        =   17, 
     TASK_TYPE_CWJINENGXUEXI        =   18,
     TASK_TYPE_CWJINENGTIHUAN       =   19, 
     TASK_TYPE_JIARUJIAZU           =   20, 
     TASK_TYPE_JIAZURENWU           =   21,    
     TASK_TYPE_JIAZUGONGXIANDU      =   22,
     TASK_TYPE_KUOJIANJIAYUAN       =   23,
     TASK_TYPE_SHJINENGJIESUO       =   24, 
     TASK_TYPE_BAIFANGJIAJU         =   25,   
     TASK_TYPE_CHONGWUSHENGXING     =   26, 
     TASK_TYPE_SUIPIANHECHENG       =   27, 
     TASK_TYPE_CHONGWUJINHUA        =   28,
     TASK_TYPE_DALIANMENG           =   29,  
     TASK_TYPE_CHONGWUXUNLIAN       =   30, 
     TASK_TYPE_CWXUNLIANCHONGZHI    =   31, 
     TASK_TYPE_SHJINENGDENGJI       =   32,    
     TASK_TYPE_SHJINENGZHIZUO       =   33, 
     TASK_TYPE_QIANLISHU            =   34,  
     TASK_TYPE_CWCHENGJIU           =   35, 
     TASK_TYPE_CWSHOUJI             =   36, 
     TASK_TYPE_CWJIBAN              =   37,
     TASK_TYPE_MAPROAD              =   38,
     TASK_TYPE_CWJIBANXINGJI        =   39,

}

TaskWatcherManager.TaskCheckType =
{
    CHECK_TYPE_NONE                     = 1,--不检查
    CHECK_TYPE_CLIENT                   = 2,--客户端检查
    CHECK_TYPE_SERVER_SAVE              = 3,--服务器存盘
    CHECK_TYPE_SERVER_KEY               = 4,--服务器关键字
    CHECK_TYPE_CLIENT_SERVER_KEY        = 5,--客户端+服务器关键字
    CHECK_TYPE_SERVER_SAVE_KEY          = 6,--服务器关键字+服务器存盘
}

TaskWatcherManager.TaskShowType =
{
    SHOW_TYPE_GET                       = 1,    --直接领取
    SHOW_TYPE_MONEY                     = 2,    --购买
    SHOW_TYPE_TIMES                     = 3,    --次数
    SHOW_TYPE_CONDITION_GET            = 4,     --条件获取
}

--每种方法的检查方式
TaskWatcherManager.TaskShowArray = 
{
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_GET,--TASK_TYPE_MEIRILIBAO     
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_TIMES,--TASK_TYPE_LEIJICHONGZHI  
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_CONDITION_GET,--TASK_TYPE_FUBENTONGGUAN  
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_CONDITION_GET,--TASK_TYPE_ZUDUIFUBEN     
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_TIMES,--TASK_TYPE_ZUDUIFUBENCISHU
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_TIMES,--TASK_TYPE_ZDFBYAOQINGHAOY
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_MONEY,--TASK_TYPE_CHAOZHILIBAO   
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_CONDITION_GET,--TASK_TYPE_JINGJICHANG    
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_CONDITION_GET,--TASK_TYPE_ZHANDOULI      
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_CONDITION_GET,--TASK_TYPE_RENWUDENGJI    
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_CONDITION_GET,--TASK_TYPE_LOSTTOWERCENGSH
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_CONDITION_GET,--TASK_TYPE_LOSTTOWERCHUANS
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_CONDITION_GET,--TASK_TYPE_LOSTTOWERCHONGZ
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_CONDITION_GET,--TASK_TYPE_LOSTTOWERHUIFU 
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_TIMES,--TASK_TYPE_QIANGHUACHONGWU
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_TIMES,--TASK_TYPE_CHONGWUFANGSHEN
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_TIMES,--TASK_TYPE_CHONGWUJINENG  
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_CONDITION_GET,--TASK_TYPE_CWJINENGXUEXI  
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_CONDITION_GET,--TASK_TYPE_CWJINENGTIHUAN 
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_CONDITION_GET,--TASK_TYPE_JIARUJIAZU     
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_TIMES,--TASK_TYPE_JIAZURENWU     
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_TIMES,--TASK_TYPE_JIAZUGONGXIANDU
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_TIMES,--TASK_TYPE_KUOJIANJIAYUAN 
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_TIMES,--TASK_TYPE_SHJINENGJIESUO 
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_TIMES,--TASK_TYPE_BAIFANGJIAJU   
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_TIMES,--TASK_TYPE_CHONGWUSHENGXIN
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_TIMES,--TASK_TYPE_SUIPIANHECHENG 
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_TIMES,--TASK_TYPE_CHONGWUJINHUA  
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_TIMES,--TASK_TYPE_DALIANMENG     
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_TIMES,--TASK_TYPE_CHONGWUXUNLIAN 
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_CONDITION_GET,--TASK_TYPE_CWXUNLIANCHONGZ
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_CONDITION_GET,--TASK_TYPE_SHJINENGDENGJI 
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_TIMES,--TASK_TYPE_SHJINENGZHIZUO 
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_TIMES,--TASK_TYPE_QIANLISHU      
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_TIMES,--TASK_TYPE_CWCHENGJIU     
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_TIMES,--TASK_TYPE_CWSHOUJI       
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_TIMES,--TASK_TYPE_CWJIBAN        
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_CONDITION_GET,--TASK_TYPE_MAPROAD        
    TaskWatcherManager.TaskCheckType.SHOW_TYPE_TIMES,--TASK_TYPE_CWJIBANXINGJI  
}

--每种方法的检查方式
TaskWatcherManager.TaskCheckArray = 
{
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_NONE,--TASK_TYPE_MEIRILIBAO     
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_CLIENT,--TASK_TYPE_LEIJICHONGZHI  
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_CLIENT,--TASK_TYPE_FUBENTONGGUAN  
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_SERVER_SAVE,--TASK_TYPE_ZUDUIFUBEN     
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_SERVER_KEY,--TASK_TYPE_ZUDUIFUBENCISHU
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_SERVER_SAVE,--TASK_TYPE_ZDFBYAOQINGHAOY
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_NONE,--TASK_TYPE_CHAOZHILIBAO   
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_CLIENT,--TASK_TYPE_JINGJICHANG    
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_CLIENT,--TASK_TYPE_ZHANDOULI      
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_CLIENT,--TASK_TYPE_RENWUDENGJI    
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_CLIENT,--TASK_TYPE_LOSTTOWERCENGSH
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_SERVER_SAVE,--TASK_TYPE_LOSTTOWERCHUANS
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_SERVER_SAVE,--TASK_TYPE_LOSTTOWERCHONGZ
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_SERVER_SAVE,--TASK_TYPE_LOSTTOWERHUIFU 
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_CLIENT,--TASK_TYPE_QIANGHUACHONGWU
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_SERVER_KEY,--TASK_TYPE_CHONGWUFANGSHEN
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_CLIENT,--TASK_TYPE_CHONGWUJINENG  
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_SERVER_KEY,--TASK_TYPE_CWJINENGXUEXI  
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_SERVER_SAVE,--TASK_TYPE_CWJINENGTIHUAN 
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_CLIENT,--TASK_TYPE_JIARUJIAZU     
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_SERVER_KEY,--TASK_TYPE_JIAZURENWU     
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_CLIENT,--TASK_TYPE_JIAZUGONGXIANDU
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_CLIENT,--TASK_TYPE_KUOJIANJIAYUAN 
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_CLIENT,--TASK_TYPE_SHJINENGJIESUO 
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_CLIENT,--TASK_TYPE_BAIFANGJIAJU   
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_CLIENT,--TASK_TYPE_CHONGWUSHENGXIN
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_SERVER_KEY,--TASK_TYPE_SUIPIANHECHENG 
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_SERVER_KEY,--TASK_TYPE_CHONGWUJINHUA  
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_SERVER_KEY,--TASK_TYPE_DALIANMENG     
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_SERVER_KEY,--TASK_TYPE_CHONGWUXUNLIAN 
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_SERVER_SAVE,--TASK_TYPE_CWXUNLIANCHONGZ
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_CLIENT,--TASK_TYPE_SHJINENGDENGJI 
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_SERVER_KEY,--TASK_TYPE_SHJINENGZHIZUO 
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_CLIENT,--TASK_TYPE_QIANLISHU      
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_CLIENT,--TASK_TYPE_CWCHENGJIU     
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_CLIENT,--TASK_TYPE_CWSHOUJI       
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_SERVER_SAVE,--TASK_TYPE_CWJIBAN        
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_CLIENT,--TASK_TYPE_MAPROAD        
    TaskWatcherManager.TaskCheckType.CHECK_TYPE_SERVER_SAVE,--TASK_TYPE_CWJIBANXINGJI  
}

TaskWatcherManager.redPointData = {} --红点数据
TaskWatcherManager.sevenDaysQuestPrizeTable= {} --7天领奖表,0表示未领取，1表示领取,并且包含服务器保存的字段数据
TaskWatcherManager.completeTaskContent = ""
TaskWatcherManager.completeTaskTable = {} --完成任务的table
TaskWatcherManager.completeTaskKeyStr = "sevenDayCompleteTask"--完成任务列表1,2,3,4按id排序

TaskWatcherManager.lifeskillInfo = nil

TaskWatcherManager.tabIndex = {
    
}

TaskWatcherManager.allSevenDayTaskInfo = {} --保存所有7日活动

local sevenDaysActivity = require("src.GameMgr.Item.SevenDaysActivity")
function TaskWatcherManager.init()


end

function TaskWatcherManager.requestGetTaskPrizeInfo(callback)
    SevenDayPetData.initPetData()
    TaskWatcherManager.completeTaskContent = "" 
    TaskWatcherManager.completeTaskTable = {}  

    local function getSevenDaysQuestPrizeTable()
        local requestTable = {}
        for k,v in pairs(TaskWatcherManager.sevenDaysQuestPrizeTable) do 
            table.insert(requestTable,k)
        end    
        NetInterface.send("GC_GetCharacterValues_Ack", function()
            local LoginSend = require("src.Net.Send.LoginSend")
            LoginSend.sendCG_GetCharacterValues_Req(requestTable) --petPacketNum
        end, function()
            SevenDayRedPointManager.initRedPointDataList()
            if callback then
            	callback()
            end
        end, function(code)
        end)    
        --[[
         for i = 1,#TaskWatcherManager.allSevenDayTaskInfo do 
            local taskid = TaskWatcherManager.allSevenDayTaskInfo[i].id
            if TaskWatcherManager.completeTaskTable[taskid] == 1 then 
                 print("addRedPointData init.................. id is："..data.id)
                 TaskWatcherManager.addRedPointData(data)                
            end
         end
         ]]
    end
    NetInterface.send("MC_ReadInfo_Ack", function()
            local LoginSend = require("src.Net.Send.LoginSend")
            LoginSend.sendCM_ReadInfo_Req(TaskWatcherManager.completeTaskKeyStr)
        end,
        function()
            TaskWatcherManager.completeTaskContent = CharInfo.getCurReadContent()
            if TaskWatcherManager.completeTaskContent ~="" then 
                local res = string.split(TaskWatcherManager.completeTaskContent, ",")
                for i = 1,#res do 
                    TaskWatcherManager.completeTaskTable[tonumber(res[i])] = 1
                end
            end
            print("TaskWatcherManager.completeTaskContent......................"..TaskWatcherManager.completeTaskContent)
            getSevenDaysQuestPrizeTable()
        end,function(code)
            getSevenDaysQuestPrizeTable()
        end
        )

    NetInterface.send("GC_GetLifeSkillData_Ack", function()
            local lifeSkillSend =  require("src.Net.Send.LifeSkillSend")
            lifeSkillSend.sendCG_GetLifeSkillData_Req()
        end,
        function()
            local data = CharInfo.getLifeSkillInfo()
            local cjson = require("cjson")
            TaskWatcherManager.lifeskillInfo = cjson.decode(data)
            if TaskWatcherManager.lifeskillInfo == nil then 
                local  lifeskillInfo = {}
                lifeskillInfo.level = 0
                lifeskillInfo.exp = 0
                TaskWatcherManager.lifeskillInfo = lifeskillInfo
            else
                TaskWatcherManager.lifeskillInfo.level = TaskWatcherManager.lifeskillInfo.level or 1
                TaskWatcherManager.lifeskillInfo.exp = TaskWatcherManager.lifeskillInfo.exp or 0
            end

            print("TaskWatcherManager.lifeskillInfo.level is ...................."..TaskWatcherManager.lifeskillInfo.level)
        end,function(code)
         
        end
        )

end

function TaskWatcherManager.processGetTaskPrizeInfo(key,v)
    print("key is............ v is.................",key,v)
    if TaskWatcherManager.sevenDaysQuestPrizeTable[key] ~=nil then 
        if v== "null" then v = 0 end
        TaskWatcherManager.sevenDaysQuestPrizeTable[key] = v
    end

    --[[
    if key == "petstrnum" then 
        SevenDayPetData.updateXunLian()
    end
    ]]

    --[[
    if key == "lifeskillproductnum" then 
        SevenDayPetData.updateShJinengShuliang()
    end
    ]]
end

function TaskWatcherManager.setUserGetPriceSuccess(taskid)
    local keystr = "seven"..taskid
    if TaskWatcherManager.sevenDaysQuestPrizeTable[keystr] ~=nil then
        TaskWatcherManager.sevenDaysQuestPrizeTable[keystr] = 1

    else
        print("setUserGetPriceSuccess keystr is error......................",keystr)       
    end
end

function TaskWatcherManager.checkTaskProgress(data)
    local taskType = data.sevenQuestType
    if(TaskWatcherManager.TaskCheckArray[taskType] == TaskWatcherManager.TaskCheckType.CHECK_TYPE_CLIENT ) then
        --print("checkTaskProgress..........................",data.objectInst:getTaskTypeName())
        data.objectInst:getConditionFromOtherSystem()
        local ret = data.objectInst:getCurrentNum()
       --print("checkTaskProgress result is..........................",ret)
       return ret
    end

    if(TaskWatcherManager.TaskCheckArray[taskType] == TaskWatcherManager.TaskCheckType.CHECK_TYPE_SERVER_KEY ) then
        print("checkTaskProgress..........................",data.objectInst:getTaskTypeName())
        data.objectInst:getConditionFromServerKeyWords()
        local ret = data.objectInst:getCurrentNum()
        print("checkTaskProgress result is..........................",ret)
       return ret
    end
    print("checkTaskProgress..........................",TaskWatcherManager.TaskCheckArray[taskType],data.sevenQuestType)
    return "sssssss"
end

function TaskWatcherManager.checkTaskComplete(data)
    return data.objectInst:canTakeTaskPrize()
end

--领到奖励时的服务器回调
function TaskWatcherManager.onGetPrizeFromServer(data,dayindex)
    local key = "seven"..data.id
    TaskWatcherManager.sevenDaysQuestPrizeTable[key]  = 1
    SevenDayRedPointManager.onGetOneTaskPrize(dayindex,data.id)
    SevenDaysActivity.refreshRedPoint()
--[[
    local str = tostring(data.id)
    if TaskWatcherManager.completeTaskContent == "" then     
        TaskWatcherManager.completeTaskContent = TaskWatcherManager.completeTaskContent..str
    else
        TaskWatcherManager.completeTaskContent = TaskWatcherManager.completeTaskContent..","..str
    end

    TaskWatcherManager.completeTaskTable[data.id] = 1 --完成任务的table

    NetInterface.send("MC_ChangeInfo_Ack", function()
        local LoginSend = require("src.Net.Send.LoginSend")
        LoginSend.sendCM_ChangeInfo_Req({key=TaskWatcherManager.completeTaskKeyStr, content= TaskWatcherManager.completeTaskContent})
    end, function()

    end)
    ]]
end

--任务完成的回调
function TaskWatcherManager.onTaskIsComplete(data)
    if TaskWatcherManager.completeTaskTable[data.id]  == 1 then 
        print("TaskWatcherManager.onTaskIsComplete already 1 is："..data.id)
        return
    end
    local str = tostring(data.id)
    if TaskWatcherManager.completeTaskContent == "" then     
        TaskWatcherManager.completeTaskContent = TaskWatcherManager.completeTaskContent..str
    else
        TaskWatcherManager.completeTaskContent = TaskWatcherManager.completeTaskContent..","..str
    end

    TaskWatcherManager.completeTaskTable[data.id] = 1 --完成任务的table
    --print("addRedPointData.................. id is："..data.id)
    --TaskWatcherManager.addRedPointData(data)
    SevenDayRedPointManager.onFinishOneTask(data.openDay,data.id)
    NetInterface.send("MC_ChangeInfo_Ack", function()
        local LoginSend = require("src.Net.Send.LoginSend")
        LoginSend.sendCM_ChangeInfo_Req({key=TaskWatcherManager.completeTaskKeyStr, content= TaskWatcherManager.completeTaskContent})
    end, function()
        
    end)    
end

function TaskWatcherManager.isPrizeAlreadyGet(taskid)
    local keystr = "seven"..taskid
    local val = TaskWatcherManager.sevenDaysQuestPrizeTable[keystr]
    if val == 1 then 
        return true

    else
        return false
    end

end



function TaskWatcherManager.addRedPointData(data)
    --TaskWatcherManager.redPointData[data.id] = data
    --TaskWatcherManager.showRedPoint(data)
end


function TaskWatcherManager.removeRedPointData(data)
    TaskWatcherManager.redPointData[data.id] = nil  
end
local SevenDaysActivity = require("src.GameMgr.Item.SevenDaysActivity")
function TaskWatcherManager.showRedPoint(data)
    --是否天数到期
    local createDays = SevenDaysActivity.getRoleCreateDay()
    local openDay = data.openDay
   print("createDays,openDay is："..createDays,tonumber(openDay))
    if createDays <= tonumber(openDay) then 
        --定位位置,显示红点
         local redpointindex = SevenDaysActivity.getQuestTagIndex(data.questTabTag)
         table.insert( TaskWatcherManager.tabIndex[tonumber(openDay)],redpointindex)
         StatusBarMgr.addRedPoint(6)
    end
 
end

function TaskWatcherManager.showAllRedPoint()
    

    for i = 1,7 do 
        TaskWatcherManager.tabIndex[i]={}
    end
     --[[
    for k,v in pairs(TaskWatcherManager.redPointData) do 
        if v~=nil then 
            TaskWatcherManager.showRedPoint(v)
        end    
    end 
    ]]
end


function TaskWatcherManager.createTaskObject(data)
    local objectInstance = nil
    print("data.sevenQuestType is .........................................."..data.sevenQuestType)
    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_MEIRILIBAO then 
        local objectClass = require("src.GameMgr.TaskWatcher.MeiRiLiBaoWatcher")
        data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = - 100
        objectInstance = objectClass.new(data)
        --TaskWatcherManager.addRedPointData(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())
    end

    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_LEIJICHONGZHI      then
        local objectClass = require("src.GameMgr.TaskWatcher.LeiJiChongZhiWatcher")
            
        data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = tonumber(data.needCondition[1])
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())
    end
    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_FUBENTONGGUAN      then
        local objectClass = require("src.GameMgr.TaskWatcher.FubenTongGuanWatcher")
        data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = - 100
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())
    end

    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_ZUDUIFUBEN         then
        local objectClass = require("src.GameMgr.TaskWatcher.ZuDuiFuBenWatcher")
        data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = -100      
        objectInstance = objectClass.new(data)
        SevenDayFuBenData.addZDFBTongGuanData(objectInstance,data.needCondition[1]) --写在这里才合理 减少耦合
        print("object name is............................................:"..objectInstance:getTaskTypeName())
    end

    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_ZUDUIFUBENCISHU    then
        local objectClass = require("src.GameMgr.TaskWatcher.ZuDuiFuBenCiShuWatcher")
        data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = tonumber(data.needCondition[1]) 
        objectInstance = objectClass.new(data)
        SevenDayFuBenData.addZDFBCiShuData(objectInstance)
        print("object name is............................................:"..objectInstance:getTaskTypeName(),data.numberMax)       
    end

    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_ZDFBYAOQINGHAOYOU  then
        local objectClass = require("src.GameMgr.TaskWatcher.ZDFubenYaoQingHaoYouWatcher")
        data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = -100 
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())       
    end

    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_CHAOZHILIBAO       then
        
        local objectClass = require("src.GameMgr.TaskWatcher.ChaoZhiLiBaoWatcher")
        data.oldMoney = tonumber(data.needCondition[1])
        data.useMoney = tonumber(data.needCondition[2])
        data.numberMax = -100 
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName(),data.id,data.oldMoney,data.useMoney)     
    end

    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_JINGJICHANG        then
        data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = -100 
        local objectClass = require("src.GameMgr.TaskWatcher.JingJiChangWatcher")
        objectInstance = objectClass.new(data)
        SevenDayFuBenData.addJingJiChangData(objectInstance)
        print("object name is............................................:"..objectInstance:getTaskTypeName())         
    end

    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_ZHANDOULI          then
        data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = -100 
        local objectClass = require("src.GameMgr.TaskWatcher.ZhanDouLiWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())     
    end

    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_RENWUDENGJI        then
        data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = -100 
        local objectClass = require("src.GameMgr.TaskWatcher.RenWuDengJiWatcher")
        objectInstance = objectClass.new(data)
        SevenDayFuBenData.addUserDengJiData(objectInstance)
        print("object name is............................................:"..objectInstance:getTaskTypeName())     
    end
    
    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_LOSTTOWERCENGSHU   then
        data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = -100 
        local objectClass = require("src.GameMgr.TaskWatcher.LostTowerCengShuWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())  
    end
    
    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_LOSTTOWERCHUANSONG  then
        data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = -100 
        local objectClass = require("src.GameMgr.TaskWatcher.LostTowerChuanSongWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())  
    end
    
    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_LOSTTOWERCHONGZHI  then
        data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = -100 
        local objectClass = require("src.GameMgr.TaskWatcher.LostTowerChongZhiWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())     
    end
    
    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_LOSTTOWERHUIFU     then
        data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = -100 
        local objectClass = require("src.GameMgr.TaskWatcher.LostTowerHuiFuWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())       
    end
    
    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_QIANGHUACHONGWU    then
        data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = tonumber(data.needCondition[1]) 
        local objectClass = require("src.GameMgr.TaskWatcher.QiangHuaChongWuWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())       
    end
    
    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_CHONGWUFANGSHENG   then
        data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = tonumber(data.needCondition[1])
        local objectClass = require("src.GameMgr.TaskWatcher.ChongWuFangShengWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())     
    end
    
    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_CHONGWUJINENG      then
        data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = -100
        local objectClass = require("src.GameMgr.TaskWatcher.ChongWuJiNengWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())         
    end
    
    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_CWJINENGXUEXI      then
        data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = -100--tonumber(data.needCondition[2])        
        local objectClass = require("src.GameMgr.TaskWatcher.CWJiNengXueXiWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())     
    end

    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_CWJINENGTIHUAN     then
        data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = -100--tonumber(data.needCondition[2])  
        local objectClass = require("src.GameMgr.TaskWatcher.CWJiNengTiHuanWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())      
    end
    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_JIARUJIAZU         then
        data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = -100 
        local objectClass = require("src.GameMgr.TaskWatcher.JiaRuJiaZuWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())     
    end
    
    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_JIAZURENWU         then
        data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = tonumber(data.needCondition[1])        
        local objectClass = require("src.GameMgr.TaskWatcher.JiaZuRenWuWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())         
    end
    
    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_JIAZUGONGXIANDU    then
        data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = tonumber(data.needCondition[1])  
        local objectClass = require("src.GameMgr.TaskWatcher.JiaZuGongXianDuWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())       
    end
    
    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_KUOJIANJIAYUAN     then
        data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = -100        
        local objectClass = require("src.GameMgr.TaskWatcher.KuoJianJiaYuanWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())      
    end
    
    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_SHJINENGJIESUO     then
        data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = tonumber(data.needCondition[1]) 
         local objectClass = require("src.GameMgr.TaskWatcher.SHJiNengJieSuoWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())   
    end

    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_BAIFANGJIAJU       then
         data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = tonumber(data.needCondition[1])        
       local objectClass = require("src.GameMgr.TaskWatcher.BaiFangJiaJuWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())       
    end

    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_CHONGWUSHENGXING   then
         data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = tonumber(data.needCondition[1])       
       local objectClass = require("src.GameMgr.TaskWatcher.ChongWuShengXingWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())     
    end

    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_SUIPIANHECHENG     then
         data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = tonumber(data.needCondition[1])  
       local objectClass = require("src.GameMgr.TaskWatcher.SuiPianHeChengWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())        
    end
    
    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_CHONGWUJINHUA      then

         data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = tonumber(data.needCondition[1])  
       local objectClass = require("src.GameMgr.TaskWatcher.ChongWuJinHuaWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())      
    end

    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_DALIANMENG         then
         data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = tonumber(data.needCondition[2])  
       local objectClass = require("src.GameMgr.TaskWatcher.DaLianMengWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())    
    end
    
    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_CHONGWUXUNLIAN     then
         data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = tonumber(data.needCondition[3])  
       local objectClass = require("src.GameMgr.TaskWatcher.ChongWuXunLianWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())        
    end
    
    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_CWXUNLIANCHONGZHI  then
         data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = -100  
       local objectClass = require("src.GameMgr.TaskWatcher.ChongWuXunLianChongZhiWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())     
    end
    
    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_SHJINENGDENGJI     then
         data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = -100 
       local objectClass = require("src.GameMgr.TaskWatcher.SHJiNengDengJiWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())       
    end
    
    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_SHJINENGZHIZUO     then
         data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = tonumber(data.needCondition[1])        
       local objectClass = require("src.GameMgr.TaskWatcher.SHJiNengZhiZhuoWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())       
    end
    
    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_QIANLISHU          then
         data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = tonumber(data.needCondition[1])
       local objectClass = require("src.GameMgr.TaskWatcher.QianLiShuWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())              
    end
    
    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_CWCHENGJIU         then
         data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = tonumber(data.needCondition[1])
       local objectClass = require("src.GameMgr.TaskWatcher.CWChengJiuWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())            
    end
    
    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_CWSHOUJI           then
         data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = tonumber(data.needCondition[1])
       local objectClass = require("src.GameMgr.TaskWatcher.CWShouJiWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())      
    end
    
    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_CWJIBAN            then
         data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = -100--tonumber(data.needCondition[1])
       local objectClass = require("src.GameMgr.TaskWatcher.CWJiBanWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())      
    end
    
    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_MAPROAD            then
         data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = -100        
       local objectClass = require("src.GameMgr.TaskWatcher.MapRoadWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())       
    end
    
    if data.sevenQuestType == TaskWatcherManager.TaskType.TASK_TYPE_CWJIBANXINGJI      then
         data.oldMoney = -100
        data.useMoney = -100
        data.numberMax = -100--tonumber(data.needCondition[1])  
       local objectClass = require("src.GameMgr.TaskWatcher.CWJiBanXingJiWatcher")
        objectInstance = objectClass.new(data)
        print("object name is............................................:"..objectInstance:getTaskTypeName())     
    end

    table.insert(TaskWatcherManager.allSevenDayTaskInfo,objectInstance)
    return objectInstance

end


--组队副本关键字：和好友完成-"zdfbfriend",通过第一章-"zdfbpass_1"，通关第二章-"zdfbpass_2" 以此类推
function TaskWatcherManager.saveZuduiResultState(savekeyname, successCallback)
    if savekeyname == "zdfbfriend" then 
        SevenDayFuBenData.updateZDFbYaoQingData()
    else
        if savekeyname == "zdfbpass_1" then 
            SevenDayFuBenData.updateZuDuiFbTongGuan(1)
        end

        if savekeyname == "zdfbpass_2" then 
            SevenDayFuBenData.updateZuDuiFbTongGuan(2)
        end

        if savekeyname == "zdfbpass_3" then 
            SevenDayFuBenData.updateZuDuiFbTongGuan(3)
        end

        if savekeyname == "zdfbpass_4" then 
            SevenDayFuBenData.updateZuDuiFbTongGuan(4)
        end

        SevenDayFuBenData.updateZuDuiFbCiShu()

    end

     if successCallback then successCallback() end
--[[
    NetInterface.send("MC_ChangeInfo_Ack", function()
        local LoginSend = require("src.Net.Send.LoginSend")
        LoginSend.sendCM_ChangeInfo_Req({key=savekeyname, content="1"})
    end, function()
        if successCallback then successCallback() end
    end)
    ]]
end

--迷失之塔关键字:传送-"losttowerchuansong",重置-"losttowerchongzhi",恢复-"losttowerhuifu"
function TaskWatcherManager.saveLostTowerResultState(savekeyname)

    if savekeyname == "losttowerchuansong" then 
        SevenDayPetData.updateLostTowerChuanSong()
    end

    if savekeyname == "losttowerchongzhi" then 
        SevenDayPetData.updateLostTowerChongZhi()
    end

    if savekeyname == "losttowerhuifu" then 
        SevenDayPetData.updateLostTowerHuiFu()
    end

    --[[
    local LoginSend = require("src.Net.Send.LoginSend")
    LoginSend.sendCM_ChangeInfo_Req({key=savekeyname, content="1"})
    ]]
end


--宠物技能关键字:宠物学习了技能-"cwjinengxuexi" 宠物替换了技能-"cwjinengtihuan"
function TaskWatcherManager.saveChongWuJinengState(savekeyname)
    --[[
    local LoginSend = require("src.Net.Send.LoginSend")
    LoginSend.sendCM_ChangeInfo_Req({key=savekeyname, content="1"})
    ]]
    if savekeyname == "cwjinengtihuan" then 
        SevenDayPetData.updateJiNengTiHuan()
    else
        SevenDayPetData.updateJiNengXueXi()
    end
end

--宠物训练关键字：宠物训练点数重置-"cwxunlianchongzhi"
function TaskWatcherManager.saveChongwuXunLianState(savekeyname)
    SevenDayPetData.xunlianChongZhi()
    --[[
    local LoginSend = require("src.Net.Send.LoginSend")
    LoginSend.sendCM_ChangeInfo_Req({key=savekeyname, content="1"})
    ]]
end

--生活技能关键字：制作一件紫色物品-"shjnzhizuo_1_4"
function TaskWatcherManager.saveShenghuoJiNengState(params)
 --params is item id
 --[[
   local iteminfo = ItemInfo.getItemInfoById(params)
   if iteminfo.itemRare == 3 then 
        SevenDayPetData.updateZiSeZhiZuo()
   end
   ]]
   SevenDayPetData.updateShJinengShuliang()


end

--params.yokeCnt
--params.yokeStar
--宠物羁绊关键字:只数_达到羁绊的数量：cujiban_1_1 
function TaskWatcherManager.saveChongwuJiBanState(params)
    SevenDayPetData.updateChongWuJiBanCnt(params)
end

--成功升级一项羁绊宠物队列达二星:只数_达到羁绊的数量_需求达到的星级： cujibanstar_2_1_2
function TaskWatcherManager.saveCWJibanXingJiState(params)
    SevenDayPetData.updateChongWuJiBanStar(params)
end

--params.objID
--params.Stage强化等级
function TaskWatcherManager.saveCWQiangHuaState(params)
    SevenDayPetData.updateQiangHua(params.Stage)
end

--params.objID
--params.stars星级
function TaskWatcherManager.saveCWShengXingState(params)
    SevenDayPetData.updateShengXing(params.stars)
end

--params.objID
--params.points强化点数（总共）
function TaskWatcherManager.saveCWXunLianState(params)
    SevenDayPetData.updateXunLian()       
end

--关卡过关通知
function TaskWatcherManager.passOneStage(params)
    print("##############################", params.adventureID)
    SevenDayFuBenData.updateFuBenTongGuan()
end

function TaskWatcherManager.onChongZhiChenggong(params)

end

--params.topRank（最高名次）
function TaskWatcherManager.onJingJiChangClose(params)
    print("JingJiChangClose...........................")
    SevenDayFuBenData.updateJingJiChangRank()
end

function TaskWatcherManager.onPassXiaoJieDian(params)
--params里面传小姐点信息，注释一下
       SevenDayFuBenData.updateFuBenTongGuan()
end

--玩家等级上升
function TaskWatcherManager.onUserLevelUp(params)
    SevenDayFuBenData.updateRenWuDengJi()
end


--洪晓峰
function TaskWatcherManager.lostTowerGoToNextFloor(params)
--params里面注释一下
    print("##################################",params.nextFloor)

end

--params.objID
--params.skillID 技能ID
--params.skillLv 技能等级
--params.skillRare 技能品阶(1:C 2:B 3:A类推)
function TaskWatcherManager.saveCWJiNengShengJiState(params)
    SevenDayPetData.updateChongWuJiNengShengJi(params.skillRare,params.skillLv)
end

--玩家加入家族时调用
function TaskWatcherManager.saveJoinFamilyState(params)

end

--玩家接家族任务时调用，params里要有任务等级(questLevel)
function TaskWatcherManager.saveAcceptFamilyQuestState(params)
    SevenDayFuBenData.updateJiaZuRenWuCiShu(params.questLevel)
end


--玩家家族贡献点增加的时候调用,params最好传一个当前贡献度(devotePoint)
function TaskWatcherManager.saveJZGongXianDianChangeState(params)


end

--玩家家园扩建成功的时候调用
function TaskWatcherManager.saveJiaYuanKuoJIanState(params)

end

--摆放家具的时候调用，params可给出当前摆放的家具数量(furnitureNum)
function TaskWatcherManager.savePutANewFurniture(params)

end

--获得生活技能物品的时候调用
function TaskWatcherManager.saveGetNewLifeSkillItemsState(params)

end


--合成宠物时调用
function TaskWatcherManager.saveChongWuHeChengState(params)
    --params.rarePoint宠物品阶 
    print("params.rarePoint:",params.rarePoint)
    SevenDayFuBenData.updateSuiPianHeChengData()
end

--大联盟界面关闭
function TaskWatcherManager.saveDaLianMengCloseState(params)
    SevenDayFuBenData.updateDaLianMengData()
end


--生活馆关闭时调用，检查生活等级
function TaskWatcherManager.saveLifeSkillClostState(params)
    --params.level
end


--生活馆制作出道具后回调
function TaskWatcherManager.saveLifeSkillItemMakeState(params)
    --params.itemRare 道具品阶段
    --计算制作总共的数量
end


--点亮一项潜力点时的回调
function TaskWatcherManager.saveAddOneQianLiDian(params)

end

--完成一项宠物成就时回调
function TaskWatcherManager.saveCompleteCWChengjiu(params)
    
end

--params.objID
--params.rarePoint宠物稀有度
--宠物进化时的回调
function TaskWatcherManager.savePetJingHuaState(params)
    SevenDayFuBenData.updateChongWuJinHuaData()
end

--宠物编队成功后的回调，返回当前的战斗力
function TaskWatcherManager.saveChangeArmyTeam(params)

end


function TaskWatcherManager.onLifeSkillLVChange(level)
    TaskWatcherManager.lifeskillInfo.level = level
end

function TaskWatcherManager.onChongWuFangSheng()
    SevenDayFuBenData.updateFangShengCWCiShu()
end



return TaskWatcherManager