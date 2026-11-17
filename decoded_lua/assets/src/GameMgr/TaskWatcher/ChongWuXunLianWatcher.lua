--region ChongWuXunLianWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local ChongWuXunLianWatcher = class("ChongWuXunLianWatcher",TaskWatcherBase)

function ChongWuXunLianWatcher:ctor(taskData)
    ChongWuXunLianWatcher.super.ctor(self,taskData,"ChongWuXunLianWatcher")
    self.btaskComplete = false
    SevenDayPetData.addXunLianData(self.taskData.needCondition[2],self.taskData.needCondition[3],self)
end

function ChongWuXunLianWatcher:getConditionFromServerKeyWords(params)
 
    local teamAdvNum =  self.taskData.needCondition[3]
    local keyname = (self.taskData.keyName)
    local serverAdvNum = tonumber(TaskWatcherManager.sevenDaysQuestPrizeTable[keyname])
       --print("ChongWuXunLianWatcher:getConditionFromServerKeyWords:",teamAdvNum,keyname,TaskWatcherManager.sevenDaysQuestPrizeTable[keyname])
    self.currentnum = serverAdvNum
    if type(serverAdvNum) == "number" then 
        if serverAdvNum >=teamAdvNum then 
            self.btaskComplete = true
        else
            self.btaskComplete = false
        end
    else 
        self.btaskComplete = false
    end       
end

function ChongWuXunLianWatcher:getConditionFromOtherSystem(params)
    --params.type,params.petnum,params.point
    --print("ChongWuXunLianWatcher:getConditionFromOtherSystem")
    local pets = PokemonInfo.getAllPets()
    local count = 0
    self.currentnum = count
    if params.type == 1 then
	    for k,v in pairs(pets) do
	    	local curPoints = v.hpx + v.atk + v.def + v.satk + v.sdef + v.speed
	    	count = count + curPoints
            self.currentnum  = count
	    	if count >= params.point then
	    		return true
	    	end
	    end
	elseif params.type == 2 then
		for k,v in pairs(pets) do
	    	local curPoints = v.hpx + v.atk + v.def + v.satk + v.sdef + v.speed
	    	if curPoints >= params.point then
	    		count = count + 1
	    	end
            self.currentnum  = count
	    	if count >= params.petnum then
	    		return true
	    	end
	    end
	end

    return false
end

--直接去宠物列表界面
function ChongWuXunLianWatcher:goToProcess()
	UIStack.closeAllUI()
	PetFormationMgr.show(SceneMgr.getRunningScene)
end

function ChongWuXunLianWatcher:canTakeTaskPrize()
    --if self.taskData.keyName~="" then 
     self:getConditionFromServerKeyWords()
    --else
       -- self:getConditionFromOtherSystem()
    --end
    return self.btaskComplete
end

--直接去宠物列表界面
function ChongWuXunLianWatcher:goToProcess()
	UIStack.closeAllUI()
	PetFormationMgr.show(SceneMgr.getRunningScene)
end

return ChongWuXunLianWatcher


--endregion
