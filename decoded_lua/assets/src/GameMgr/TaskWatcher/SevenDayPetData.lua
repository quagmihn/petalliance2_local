--region SevenDayPetData.lua
--Date 7日任务的宠物任务信息
--此文件由[BabeLua]插件自动生成
local SevenDayPetData = {}

SevenDayPetData.qiangHuaDataTable = {}
SevenDayPetData.jinengTiHuanTable = {}
SevenDayPetData.jinengXueXiTable = {}
SevenDayPetData.shengXiangDataTable = {}
SevenDayPetData.xunLianChongZhiDataTable = {}
SevenDayPetData.xunLianDataTable = {}

SevenDayPetData.shenghuoJiNengZhiZuoZiSe = {}
SevenDayPetData.shenghuoJiNengShuliang = {}

SevenDayPetData.chongWuJiNengShengJi =  {}
SevenDayPetData.chongWuJiBanCnt =  {}
SevenDayPetData.chongWuJiBanStar =  {}

SevenDayPetData.lostTowerChuanSong = {}
SevenDayPetData.lostTowerChongZhi = {}
SevenDayPetData.lostTowerHuiFu = {}



function SevenDayPetData.addChongWuJiBanCnt(yokeCnt, object)
    local info = {yokeCnt, object}
    table.insert(SevenDayPetData.chongWuJiBanCnt, info)
end

function SevenDayPetData.addChongWuJiBanStar(yokeStar, object)
    local info = {yokeStar, object}
    table.insert(SevenDayPetData.chongWuJiBanStar, info)
end

function SevenDayPetData.addChongWuJiNengShengJi(grade,skilllv,object)
    local info = {grade,skilllv,object}
    table.insert(SevenDayPetData.chongWuJiNengShengJi,info)
end

function SevenDayPetData.addChongWuJiNengShengJi(grade,skilllv,object)
    local info = {grade,skilllv,object}
    table.insert(SevenDayPetData.chongWuJiNengShengJi,info)
end

function SevenDayPetData.addshJiNengZhiZuoZiSe(object)
     table.insert(SevenDayPetData.shenghuoJiNengZhiZuoZiSe,object)   
end

function SevenDayPetData.addShJiNengShuliang(object)
     table.insert(SevenDayPetData.shenghuoJiNengShuliang,object)      
end

function SevenDayPetData.addQiangHuaData(number,qianghueLv,object)
   
    local currentnum = 0
    local info = {number,qianghueLv,object,currentnum}
    table.insert(SevenDayPetData.qiangHuaDataTable,info)

end

function SevenDayPetData.addShengXingData(number,star,object)
    local currentnum = 0
    local info = {number,star,object,currentnum}
    table.insert(SevenDayPetData.shengXiangDataTable,info)

end

function SevenDayPetData.addXunLianData(number,points,object)
    local currentnum = 0
    local info = {number,points,object,currentnum}
    table.insert(SevenDayPetData.xunLianDataTable,info)   
end

function SevenDayPetData.addJinengTiHuan(object)
    table.insert(SevenDayPetData.jinengTiHuanTable,object)
end

function SevenDayPetData.addJinengXueXi(object)
    table.insert(SevenDayPetData.jinengXueXiTable,object)
end

function SevenDayPetData.addXunlianChongZhi(object)
    table.insert(SevenDayPetData.xunLianChongZhiDataTable,object)
end



function SevenDayPetData.addLostTowerChuanSong(object)
    table.insert(SevenDayPetData.lostTowerChuanSong,object)
end

function SevenDayPetData.addLostTowerChongZhi(object)
    table.insert(SevenDayPetData.lostTowerChongZhi,object)
end

function SevenDayPetData.addLostTowerHuiFu(object)
    table.insert(SevenDayPetData.lostTowerHuiFu,object)    
end

function SevenDayPetData.initPetData()
    local sevenDaysActivity = require("src.GameMgr.Item.SevenDaysActivity")

    local qiangHuaLvTable = {}

    local function initQiangHua(v)
        for i = 1,#SevenDayPetData.qiangHuaDataTable do 
            local info = SevenDayPetData.qiangHuaDataTable[i]
            local currentnum = info[4]
            if v~=nil then 
                if v.Stage >=  info[2] then
                    currentnum = currentnum + 1
                    SevenDayPetData.qiangHuaDataTable[i][4]= currentnum
                end
            else
                currentnum = currentnum + 1
                SevenDayPetData.qiangHuaDataTable[i][4]= 0
            end
        end
    end

    local function ShengXing(v)
        for i = 1,#SevenDayPetData.shengXiangDataTable do 
            local info = SevenDayPetData.shengXiangDataTable[i]
            local currentnum = info[4]
            if v~=nil then
                if v.star >=  info[2] then
                    currentnum = currentnum + 1
                    SevenDayPetData.shengXiangDataTable[i][4]= currentnum
                end
            else
                currentnum = currentnum + 1
                SevenDayPetData.shengXiangDataTable[i][4]= 0              
            end
        end
    end

    local dayCount = sevenDaysActivity.getRoleCreateDay()
    if dayCount > 7 then 
        initQiangHua()
        ShengXing()       
    else
        local pets = PokemonInfo.getAllPets()
        for k,v in pairs(pets) do
            initQiangHua(v)
            ShengXing(v)
        end        
    end


    for i = 1,#SevenDayPetData.qiangHuaDataTable do
        SevenDayPetData.qiangHuaDataTable[i][3]:setCurrentNum(SevenDayPetData.qiangHuaDataTable[i][4])
    end

    for i = 1,#SevenDayPetData.shengXiangDataTable do
        SevenDayPetData.shengXiangDataTable[i][3]:setCurrentNum(SevenDayPetData.shengXiangDataTable[i][4])
    end
end

function SevenDayPetData.updateQiangHua(stage)
    for i = 1,#SevenDayPetData.qiangHuaDataTable do 
        if SevenDayPetData.qiangHuaDataTable[i][3]:canTakeTaskPrize() == false then
            local info = SevenDayPetData.qiangHuaDataTable[i]
            local currentnum = info[4]
            if stage >=  info[2] then
                currentnum = currentnum + 1
                SevenDayPetData.qiangHuaDataTable[i][4]= currentnum
                SevenDayPetData.qiangHuaDataTable[i][3]:setCurrentNum(currentnum)
                if SevenDayPetData.qiangHuaDataTable[i][3]:canTakeTaskPrize() then 
                    TaskWatcherManager.onTaskIsComplete(SevenDayPetData.qiangHuaDataTable[i][3].taskData)
                end
            end
        end
    end
end

function SevenDayPetData.updateShengXing(star)
    for i = 1,#SevenDayPetData.shengXiangDataTable do 
        if SevenDayPetData.shengXiangDataTable[i][3]:canTakeTaskPrize() == false then
            local info = SevenDayPetData.shengXiangDataTable[i]
            local currentnum = info[4]
            if star >=  info[2] then
                currentnum = currentnum + 1
                SevenDayPetData.shengXiangDataTable[i][4]= currentnum
                SevenDayPetData.shengXiangDataTable[i][3]:setCurrentNum(currentnum)
                if SevenDayPetData.shengXiangDataTable[i][3]:canTakeTaskPrize() then 
                    TaskWatcherManager.onTaskIsComplete(SevenDayPetData.shengXiangDataTable[i][3].taskData)
                end
            end
        end
    end
end

--SevenDayPetData.lostTowerChuanSong = {}
--SevenDayPetData.lostTowerChongZhi = {}
--SevenDayPetData.lostTowerHuiFu = {}
function SevenDayPetData.updateLostTowerChuanSong()
    for i = 1,#SevenDayPetData.lostTowerChuanSong do 
        TaskWatcherManager.onTaskIsComplete(SevenDayPetData.lostTowerChuanSong[i].taskData)
    end
end

function SevenDayPetData.updateLostTowerHuiFu()
    for i =1,#SevenDayPetData.lostTowerHuiFu do 
        TaskWatcherManager.onTaskIsComplete(SevenDayPetData.lostTowerHuiFu[i].taskData)       
    end
end

function SevenDayPetData.updateLostTowerChongZhi()
    for i = 1,#SevenDayPetData.lostTowerChongZhi do 
        TaskWatcherManager.onTaskIsComplete(SevenDayPetData.lostTowerChongZhi[i].taskData)   
    end
end



function SevenDayPetData.updateJiNengTiHuan()
    for i = 1,#SevenDayPetData.jinengTiHuanTable do    
        TaskWatcherManager.onTaskIsComplete(SevenDayPetData.jinengTiHuanTable[i].taskData)       
    end      
end

function SevenDayPetData.updateJiNengXueXi()
    for i = 1,#SevenDayPetData.jinengXueXiTable do    
        TaskWatcherManager.onTaskIsComplete(SevenDayPetData.jinengXueXiTable[i].taskData)       
    end    
end

function SevenDayPetData.xunlianChongZhi()
    for i = 1,#SevenDayPetData.xunLianChongZhiDataTable do    
        TaskWatcherManager.onTaskIsComplete(SevenDayPetData.xunLianChongZhiDataTable[i].taskData)       
    end    
end

function SevenDayPetData.updateXunLian()
    for i = 1,#SevenDayPetData.xunLianDataTable do    
    --[[
        if SevenDayPetData.xunLianDataTable[i][3]:canTakeTaskPrize() then 
            TaskWatcherManager.onTaskIsComplete(SevenDayPetData.xunLianDataTable[i][3].taskData)
        end      
]]
       local object = SevenDayPetData.xunLianDataTable[i][3]
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

function SevenDayPetData.updateZiSeZhiZuo()
    for i = 1,#SevenDayPetData.shenghuoJiNengZhiZuoZiSe do    
        if SevenDayPetData.shenghuoJiNengZhiZuoZiSe[i]:canTakeTaskPrize() then 
            TaskWatcherManager.onTaskIsComplete(SevenDayPetData.shenghuoJiNengZhiZuoZiSe[i].taskData)
        end      
    end     
end

function SevenDayPetData.updateShJinengShuliang()
    for i = 1,#SevenDayPetData.shenghuoJiNengShuliang do
        
        local object = SevenDayPetData.shenghuoJiNengShuliang[i]
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
        --[[
        if SevenDayPetData.shenghuoJiNengShuliang[i]:canTakeTaskPrize() then 
            TaskWatcherManager.onTaskIsComplete(SevenDayPetData.shenghuoJiNengShuliang[i].taskData)
        end  
        ]]       
end

function SevenDayPetData.updateChongWuJiNengShengJi(grade,skilllv)
    for i= 1,#SevenDayPetData.chongWuJiNengShengJi do 
        local targetGrade = SevenDayPetData.chongWuJiNengShengJi[i][1]
        local targetLevel = SevenDayPetData.chongWuJiNengShengJi[i][2]
        if targetGrade == grade and skilllv >=targetLevel then 
            TaskWatcherManager.onTaskIsComplete(SevenDayPetData.chongWuJiNengShengJi[i][3].taskData)
        end
    end
end

function SevenDayPetData.updateChongWuJiBanCnt(yokeCnt)
    for i= 1,#SevenDayPetData.chongWuJiBanCnt do 
        local targetYokeCnt = SevenDayPetData.chongWuJiBanCnt[i][1]
        if targetYokeCnt >= yokeCnt then 
            TaskWatcherManager.onTaskIsComplete(SevenDayPetData.chongWuJiBanCnt[i][2].taskData)
        end
    end
end

function SevenDayPetData.updateChongWuJiBanStar(yokeStar)
    for i= 1,#SevenDayPetData.chongWuJiBanStar do 
        local targetYokeStar = SevenDayPetData.chongWuJiBanStar[i][1]
        if targetYokeStar <= yokeStar then
            TaskWatcherManager.onTaskIsComplete(SevenDayPetData.chongWuJiBanStar[i][2].taskData)
        end
    end
end

return SevenDayPetData



--endregion
