--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local SevenDayRedPointManager = {}

SevenDayRedPointManager.redPointDataList = {} 

local function isSevneDaysEnd() --7天活动的显示边界
    local dayCount = SevenDaysActivity.getRoleCreateDay()
    if dayCount <8 then 
        return false
    else 
        return true
    end
end

local function isOpenDayInTime(dayindex) --时间是否在7天活动的天数内
      local dayCount = SevenDaysActivity.getRoleCreateDay()  
      if dayindex<=dayCount then 
          return true 
      else 
          return false
      end
end

local function isAlreadyGetPrize(dataid)
    local key = "seven"..dataid
    --print("isAlreadyGetPrize key is ......................."..key)
    if TaskWatcherManager.sevenDaysQuestPrizeTable[key]  == 1 then 
        --("sevenDaysQuestPrizeTable complete key is ......................."..key)
        return true 
    else 
        return false
    end

end

function SevenDayRedPointManager.Init()
    SevenDayRedPointManager.redPointDataList = {} 
    for i = 1,7 do 
       SevenDayRedPointManager.redPointDataList[i] = {} 
    end
end
function SevenDayRedPointManager.initRedPointDataList()
    for i = 1,7 do 
       SevenDayRedPointManager.redPointDataList[i] = {} 
    end
    if isSevneDaysEnd() == true then return end



    for j = 1,#TaskWatcherManager.allSevenDayTaskInfo do 
        local obj = TaskWatcherManager.allSevenDayTaskInfo[j]
      
        if isAlreadyGetPrize(obj.taskData.id) == false then 
            if obj:canTakeTaskPrize() == true then 
                --print("obj:canTakeTaskPrize() openday and id is:",obj.taskData.openDay,obj.taskData.id)
                table.insert(SevenDayRedPointManager.redPointDataList[obj.taskData.openDay],obj.taskData.id)
            end
        end
       
    end

    if ActivityViewMgr.getRedPointIsShow() == false then 
        local days = SevenDayRedPointManager.getShowDaysRedPoint()
        local bShowRed = false 
        for i=1,7 do 
            if days[i] == 1 then 
                bShowRed = true 
                break
            end
        end
        if bShowRed then 
            StatusBarMgr.addRedPoint(6)
        else 
            StatusBarMgr.hideRedPoint(6)
        end
    end
end

function SevenDayRedPointManager.removeActivityRedPoint() --请求消除活动红点
    if isSevneDaysEnd() == true then 
        StatusBarMgr.hideRedPoint(6)
        return
    end

    local bShowSevenDaysRedPoint =  false
    for i = 1,7 do 
        if isOpenDayInTime(i) == false then 
            break
        end

        if SevenDayRedPointManager.redPointDataList[i]~=nil then 
            if #SevenDayRedPointManager.redPointDataList[i] >0 then 
                bShowSevenDaysRedPoint = true 
                break
            end
        end
    end

    if bShowSevenDaysRedPoint == false then
        StatusBarMgr.hideRedPoint(6)
    end
end

function SevenDayRedPointManager.showSevenDayRedPoint()
    if isSevneDaysEnd() == true then return end
    local bShowSevenDaysRedPoint =  false
    for i = 1,7 do 
        if isOpenDayInTime(i) == false then 
            break
        end
        if SevenDayRedPointManager.redPointDataList[i]~= nil then 
            if #SevenDayRedPointManager.redPointDataList[i] >0 then 
                bShowSevenDaysRedPoint = true 
                break
            end
        end
    end

    if bShowSevenDaysRedPoint then 
        StatusBarMgr.addRedPoint(6)
        ActivityViewMgr.setSevenDayRedPoint(true)

    else
        if ActivityViewMgr.getRedPointIsShow() == false then 
            StatusBarMgr.hideRedPoint(6)
        end
        ActivityViewMgr.setSevenDayRedPoint(false)
    end
end

function SevenDayRedPointManager.getShowDaysRedPoint()
    local days = {}
    if isSevneDaysEnd() == true then return days end
    for i = 1,7 do 
        if isOpenDayInTime(i) == false then 
            break
        end
        if SevenDayRedPointManager.redPointDataList[i]~=nil then
            if #SevenDayRedPointManager.redPointDataList[i] >0 then 
                days[i] = 1
            end
        end
    end   
    
    return days 
end

function SevenDayRedPointManager.getShowTabRedPoint(dayindex,taskid)
    local bComplete = false
    if isSevneDaysEnd() == true then return bComplete end
    if isOpenDayInTime(dayindex) == false then 
        return
    end
    for i = 1,#SevenDayRedPointManager.redPointDataList[dayindex] do 
        if SevenDayRedPointManager.redPointDataList[dayindex][i] == taskid then 
            bComplete = true
            break
        end
    end

    return bComplete
end

function SevenDayRedPointManager.onGetOneTaskPrize(dayindex,taskid)
    local bFind = false
    for i = 1,#SevenDayRedPointManager.redPointDataList[dayindex] do 
        if SevenDayRedPointManager.redPointDataList[dayindex][i] == taskid then 
            table.remove(SevenDayRedPointManager.redPointDataList[dayindex],i)
            bFind = true
            print("onGetOneTaskPrize sucess remove  dayindex & taskid",dayindex,taskid)
            break
        end
    end
    if bFind == false then  --not find is not correct
        printError("onGetOneTaskPrize is error not find dayindex & taskid",dayindex,taskid)
    end


end

function SevenDayRedPointManager.onFinishOneTask(dayindex,taskid,keyname)
    local function processFinishOneTask()
        local bAlreadyHave = false
        if isAlreadyGetPrize(taskid) == true then 
            return
        end

        for i = 1,#SevenDayRedPointManager.redPointDataList[dayindex] do 
            if SevenDayRedPointManager.redPointDataList[dayindex][i] == taskid then 
                print("onFinishOneTask already have  dayindex & taskid",dayindex,taskid)
                bAlreadyHave = true
                break
            end
        end

        if bAlreadyHave == false then
            table.insert(SevenDayRedPointManager.redPointDataList[dayindex],taskid) 
            print("onFinishOneTask insert table  dayindex & taskid",dayindex,taskid)
        end

        if ActivityViewMgr.getRedPointIsShow() == false then 
            local days = SevenDayRedPointManager.getShowDaysRedPoint()
            local bShowRed = false 
            for i=1,7 do 
                if days[i] == 1 then 
                    bShowRed = true 
                    break
                end
            end
            if bShowRed then 
                StatusBarMgr.addRedPoint(6)
            else 
                StatusBarMgr.hideRedPoint(6)
            end
        end
    end

    if keyname~= nil then 
        NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
            local LoginSend = require("src.Net.Send.LoginSend")
            LoginSend.sendCG_GetCharacterValues_Req({keyname})
        end,function()
            processFinishOneTask()
        end)
    else
            processFinishOneTask()        
    end
end

return SevenDayRedPointManager


--endregion
