--region LostTowerChuanSongWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local LostTowerChuanSongWatcher = class("LostTowerChuanSongWatcher",TaskWatcherBase)

function LostTowerChuanSongWatcher:ctor(taskData)
    LostTowerChuanSongWatcher.super.ctor(self,taskData,"LostTowerChuanSongWatcher")
    self.btaskComplete = false
    SevenDayPetData.addLostTowerChuanSong(self)
end

function LostTowerChuanSongWatcher:getConditionFromServerSaveparams(params)
   if TaskWatcherManager.completeTaskTable[self.taskData.id] == nil then 
        self.btaskComplete = false
   else
        self.btaskComplete = true
   end     
end

function LostTowerChuanSongWatcher:canTakeTaskPrize()
    self:getConditionFromServerSaveparams()
    return self.btaskComplete
end


return LostTowerChuanSongWatcher


--endregion
