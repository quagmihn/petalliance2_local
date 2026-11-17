--region SevenDayFuBenData.lua
--Date 7日任务的副本的信息
--此文件由[BabeLua]插件自动生成
local SevenDayFuBenData = {}

SevenDayFuBenData.fubenTongGuanData = {}
SevenDayFuBenData.zdfbTongGuanData = {}
SevenDayFuBenData.zdfbCiShuData = {}
SevenDayFuBenData.zdfbYaoQingData = {}
SevenDayFuBenData.jingJiChangData = {}
SevenDayFuBenData.userDengJiData = {}
SevenDayFuBenData.cwFangShengCiShu = {}
SevenDayFuBenData.jiaZuRenWuCiShu = {}
SevenDayFuBenData.daLianMengData = {}
SevenDayFuBenData.suiPianHeChengData = {}
SevenDayFuBenData.chongWuJinHuaData = {}

function SevenDayFuBenData.addUserDengJiData(object)
    table.insert(SevenDayFuBenData.userDengJiData,object)
end

function SevenDayFuBenData.addJingJiChangData(object)
    table.insert(SevenDayFuBenData.jingJiChangData,object)
end

function SevenDayFuBenData.addFuBenTongGuanData(object)
     table.insert(SevenDayFuBenData.fubenTongGuanData,object) 
end

function SevenDayFuBenData.addZDFBTongGuanData(object,zdfubenid)
     table.insert(SevenDayFuBenData.zdfbTongGuanData,{object,zdfubenid})     
end

function SevenDayFuBenData.addZDFBCiShuData(object)
    table.insert(SevenDayFuBenData.zdfbCiShuData,object)
end


function SevenDayFuBenData.addFangShengCWCiShu(object)
    table.insert(SevenDayFuBenData.cwFangShengCiShu,object)
end

function SevenDayFuBenData.addJiaZuRenWuCiShu(times,grade,object)
   
    local info = {times,grade,object}
    table.insert(SevenDayFuBenData.jiaZuRenWuCiShu,info)
end

function SevenDayFuBenData.addDaLianMengData(object)
    table.insert(SevenDayFuBenData.daLianMengData,object)
end

function SevenDayFuBenData.addSuiPianHeChengData(object)
    table.insert(SevenDayFuBenData.suiPianHeChengData,object)
end

function SevenDayFuBenData.addChongWuJinHuaData(object)
    table.insert(SevenDayFuBenData.chongWuJinHuaData,object)
end

function SevenDayFuBenData.addZDFBYaoQingData(object)
    table.insert(SevenDayFuBenData.zdfbYaoQingData,object)
end

function SevenDayFuBenData.updateZDFbYaoQingData()
   for i=1,#SevenDayFuBenData.zdfbYaoQingData do
        TaskWatcherManager.onTaskIsComplete(SevenDayFuBenData.zdfbYaoQingData[i].taskData)       
   end     
end

function SevenDayFuBenData.updateFuBenTongGuan()
    for i = 1,#SevenDayFuBenData.fubenTongGuanData do 
        if SevenDayFuBenData.fubenTongGuanData[i]:canTakeTaskPrize() then 
             print("updateFuBenTongGuan is："..SevenDayFuBenData.fubenTongGuanData[i].taskData.id)
            TaskWatcherManager.onTaskIsComplete(SevenDayFuBenData.fubenTongGuanData[i].taskData)
        end
    end
end

function SevenDayFuBenData.updateZuDuiFbTongGuan(zdfubenid)
    for i = 1,#SevenDayFuBenData.zdfbTongGuanData do 
        if tonumber(SevenDayFuBenData.zdfbTongGuanData[i][2]) == zdfubenid then 
            TaskWatcherManager.onTaskIsComplete(SevenDayFuBenData.zdfbTongGuanData[i][1].taskData)
        end
    end
end

function SevenDayFuBenData.updateZuDuiFbCiShu()
    local addflag = false
    for i =1,#SevenDayFuBenData.zdfbCiShuData do 
        local object = SevenDayFuBenData.zdfbCiShuData[i]
        local keyname = object.taskData.keyName
        print("keyname is ......................" ..keyname)
        if keyname~="" then 
           --[[
            local LoginSend = require("src.Net.Send.LoginSend")
            LoginSend.sendCG_GetCharacterValues_Req({keyname})
            ]]
            SevenDayRedPointManager.onFinishOneTask(object.taskData.openDay,object.taskData.id,keyname)
        end
    end
end

function SevenDayFuBenData.updateFangShengCWCiShu()
    local addflag = false
    for i =1,#SevenDayFuBenData.cwFangShengCiShu do 
        local object = SevenDayFuBenData.cwFangShengCiShu[i]
        local keyname = object.taskData.keyName
        print("keyname is ......................" ..keyname)
        if keyname~="" then
        --[[
            local LoginSend = require("src.Net.Send.LoginSend")
            LoginSend.sendCG_GetCharacterValues_Req({keyname})
            ]]
            SevenDayRedPointManager.onFinishOneTask(object.taskData.openDay,object.taskData.id,keyname)

        end
    end    
end

function SevenDayFuBenData.updateJiaZuRenWuCiShu(grade)
    for i = 1,#SevenDayFuBenData.jiaZuRenWuCiShu do 
        local object = SevenDayFuBenData.jiaZuRenWuCiShu[i][3]
        local taskgrade = SevenDayFuBenData.jiaZuRenWuCiShu[i][2]
        --print("updateJiaZuRenWuCiShu.............",object,taskgrade)
        local keyname = object.taskData.keyName
        if keyname~="" then 
        --[[
            local LoginSend = require("src.Net.Send.LoginSend")
            LoginSend.sendCG_GetCharacterValues_Req({keyname})
]]
            SevenDayRedPointManager.onFinishOneTask(object.taskData.openDay,object.taskData.id,keyname)
        end
    end
end

function SevenDayFuBenData.updateDaLianMengData()
    for i = 1,#SevenDayFuBenData.daLianMengData do
        local object = SevenDayFuBenData.daLianMengData[i]
        local keyname = object.taskData.keyName
        if keyname~="" then
        --[[
            local LoginSend = require("src.Net.Send.LoginSend")
            LoginSend.sendCG_GetCharacterValues_Req({keyname})
]]
            SevenDayRedPointManager.onFinishOneTask(object.taskData.openDay,object.taskData.id,keyname)
        end
    end
end

function SevenDayFuBenData.updateSuiPianHeChengData()
    for i = 1,#SevenDayFuBenData.suiPianHeChengData do
        local object = SevenDayFuBenData.suiPianHeChengData[i]
        local keyname = object.taskData.keyName
        if keyname~="" then
        --[[
            local LoginSend = require("src.Net.Send.LoginSend")
            LoginSend.sendCG_GetCharacterValues_Req({keyname})
            ]]
            SevenDayRedPointManager.onFinishOneTask(object.taskData.openDay,object.taskData.id,keyname)
        end
    end
end

function SevenDayFuBenData.updateChongWuJinHuaData()
    for i = 1,#SevenDayFuBenData.chongWuJinHuaData do
        local object = SevenDayFuBenData.chongWuJinHuaData[i]
        local keyname = object.taskData.keyName
        if keyname~="" then
            --[[
            local LoginSend = require("src.Net.Send.LoginSend")
            LoginSend.sendCG_GetCharacterValues_Req({keyname})
            ]]
            SevenDayRedPointManager.onFinishOneTask(object.taskData.openDay,object.taskData.id,keyname)
        end
    end
end

function SevenDayFuBenData.updateJingJiChangRank()
    for i = 1,#SevenDayFuBenData.jingJiChangData do 
        if SevenDayFuBenData.jingJiChangData[i]:canTakeTaskPrize() then 
            TaskWatcherManager.onTaskIsComplete(SevenDayFuBenData.jingJiChangData[i].taskData) 
        end
    end
end

function SevenDayFuBenData.updateRenWuDengJi()
    for i = 1,#SevenDayFuBenData.userDengJiData do 
        if SevenDayFuBenData.userDengJiData[i]:canTakeTaskPrize() then 
            TaskWatcherManager.onTaskIsComplete(SevenDayFuBenData.userDengJiData[i].taskData)
        end
    end
end

return SevenDayFuBenData


--endregion
