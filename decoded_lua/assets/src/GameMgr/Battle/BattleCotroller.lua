local BattleCotroller 	= {}
local battleMgr 		= nil
local roundFightInfo 	= {}
local currentRecord 	= {}
local totalRecord       = {}
local recordcoper       = {}
local isRecord         	= false
local battleResult      = nil
local recordIndex       = 0
local isCloseRecord     = false
local stepEventName     = nil

BattleCotroller.timeSceNum      = 9
BattleCotroller.petBuffers      = {}
BattleCotroller.battleDetail    = {}
BattleCotroller.isPause         = false
BattleCotroller.bossHP          = nil
BattleCotroller.lastbossHP      = nil
BattleCotroller.TeamB_Damage    = 0
BattleCotroller.TeamA_Damage    = 0
BattleCotroller.noMiss    = false
BattleCotroller.recordNameA = ""
BattleCotroller.recordNameB = ""
BattleCotroller.enterBattleScene = true

function BattleCotroller.init(battle)
    battleMgr 		= battle
    currentRecord   = {}
    BattleCotroller.isPause  = false
    
    recordIndex     = 0
    recordcoper     = totalRecord
    
end 

function BattleCotroller.setstepEventName(strvalue)
    stepEventName = strvalue
end

function BattleCotroller.cleanRecord() 
    totalRecord       = {}
    recordcoper       = {}
    currentRecord     = {}
    recordIndex       = 0
    isRecord        = false
    battleResult    = nil
    BattleCotroller.bossHP          = nil
    BattleCotroller.lastbossHP      = nil
    BattleCotroller.TeamB_Damage    = 0
    BattleCotroller.TeamA_Damage    = 0
    stepEventName = nil

    BattleCotroller.enterBattleScene = true
end

function BattleCotroller.cleanCurrentRecord()
    currentRecord     = {} 
    recordIndex       = 0
end

function BattleCotroller.setIsRecord(isbool)
    isCloseRecord = true
    isRecord        = isbool
    recordIndex     = 0
end

function BattleCotroller.triggerToRecord() 
    isCloseRecord = false
end

function BattleCotroller.cloneRecord()
    recordcoper = clone(totalRecord)
end

function BattleCotroller.setcurrentRecord(record)
    currentRecord = record
end

function BattleCotroller.runPVPBattleData(index)
    totalRecord[index] = clone(BattlePVPMgr.data[index])
    recordcoper[index] = clone(BattlePVPMgr.data[index])
    -- if BattlePVPMgr.dataIndex == index then   
    --     print("BattlePVPMgr.dataIndex............",BattlePVPMgr.dataIndex)
    --     if index ~= 1 then
    --         BattleCotroller.AnimationEnd()  
    --     end   
        
    --     BattlePVPMgr.sendIsCommand  = false
    -- end
end

function BattleCotroller.setBattleResult(result)
    battleResult = result
end

function BattleCotroller.getBattleResult()
    return battleResult
end

function BattleCotroller.setTotalRecord(records,result) 
    totalRecord = clone(records)
    if result then
        battleResult = result
    end
    for key,var in pairs(totalRecord) do  
        for i,j in pairs(var) do
            if j.gameover then
                battleResult    = j[1]
            end
        end
    end
end

function BattleCotroller.setBattleRecords(record,index)
--    table.insert(totalRecord,record)
--    table.insert(recordcoper,record) 
    totalRecord[index] = clone(record)
    recordcoper[index] = record
    isRecord = true
    for key,var in pairs(totalRecord[index]) do   
        if var.gameover then
            local detail    = {}
            battleResult    = var[1]
            detail.result   = var[1]
            -- BattleMapMgr.useCallBK(detail)
        end

    end
end

function BattleCotroller.getIsRecord()
	return isRecord
end

-----发出judgeNextBattle协议
function BattleCotroller.judgeNextBattle()
    if not BattleUIMgr.showSkillTip or BattleCCSB.MENU.isOut or BattleUIMgr.isJumpBattle then
        print("judgeNextBattle   ~~~~~~")
        return
    end
    
    if #currentRecord <= 0 then
        BattleCotroller.AnimationEnd()  -- 
        return
    end

    if stepEventName then
        if currentRecord[1][stepEventName] then
            table.remove(currentRecord,1)
            stepEventName = nil
            BattleUIMgr.goToContinus() 
            return 
        end
        
    end
    if currentRecord[1].round then
        BattleUIMgr.roundUI(currentRecord[1].round)
    elseif currentRecord[1].petEnter  then

        if #currentRecord[1].pets == 2 then
            BattleUIMgr.enterBattle(0,BattleCANI.PETS.petTable[0][1],false,true)
            BattleUIMgr.enterBattle(1,BattleCANI.PETS.petTable[1][1],false,BattleMapMgr.getAdvChallage(),function()
                BattleCotroller.judgeNextBattle()
            end)
        elseif #currentRecord[1].pets == 1 then
            local petType = currentRecord[1].pets[1]
            local personEnter = BattleMapMgr.getAdvChallage()
            
            if petType == MYPETS then
                personEnter = true
            end 

            BattleUIMgr.enterBattle(petType,BattleCANI.PETS.petTable[petType][1],false,personEnter,function()
                    BattleCotroller.judgeNextBattle()
                end) 
        else

            BattleUIMgr.goToContinus()
        end
    elseif currentRecord[1].selectSkill then

        if BattlePVPMgr.mIsPVPBattle and recordcoper[recordIndex+1] then
            BattleUIMgr.goToContinus()
        elseif (isRecord and not BattlePVPMgr.mIsPVPBattle) then
            BattleUIMgr.goToContinus()
        elseif not BattleMapMgr.getIsArena() then  
            BattleUIMgr.selectSkillShow(currentRecord[1].teamA)
        else
            BattleUIMgr.goToContinus()
        end

    elseif currentRecord[1].energy then
        BattleUIMgr.checkEnergyCounts(currentRecord[1].energy[1],function()
                BattleCotroller.judgeNextBattle()
            end)  
    elseif currentRecord[1].ani then
        BattleUIMgr.petAnimation(currentRecord[1][1],currentRecord[1][2],
                    currentRecord[1][3],currentRecord[1][4],currentRecord[1][5],currentRecord[1][6],currentRecord[1][7])
    elseif currentRecord[1].changePet then
        BattleUIMgr.deleteAllBuffer(currentRecord[1][1])
        BattleUIMgr.exchangePets(currentRecord[1][1],currentRecord[1][2],currentRecord[1][3],currentRecord[1].hp) 
        BattleUIMgr.deleteSelectedSkill(currentRecord[1][1]) 
    elseif currentRecord[1].gameover then
        battleResult = currentRecord[1][1]
        BattleUIMgr.GameOver(currentRecord[1][1],"expShow",true)  
        isRecord = false
    elseif currentRecord[1].checkBuffer then
        BattleUIMgr.checkBuffInfomation(currentRecord[1])
    elseif currentRecord[1].triggeredPassiveSkill then
        BattleUIMgr.checkPassiveSkills(currentRecord[1][1],currentRecord[1][2],currentRecord[1][3]) 
    elseif currentRecord[1].changeWeather  then
        BattleUIMgr.changeWeather(currentRecord[1].changeWeather,true)
    elseif currentRecord[1].buffDamage then
        BattleUIMgr.checkbufferDamage(currentRecord[1][1],currentRecord[1][2])
    elseif currentRecord[1].assistSkill then
        if currentRecord[1][1][1] then
            BattleUIMgr.assistSkillShow(currentRecord[1][1][1].id,currentRecord[1][1][1].skill,
                    currentRecord[1][1][1].side,currentRecord[1][1][1].pokeID)
        else
            BattleUIMgr.goToContinus()
        end
    elseif currentRecord[1].showSelectSkill then
        BattleUIMgr.showSelectSkill(currentRecord[1][1],currentRecord[1][2])
        BattleUIMgr.goToContinus()
    else
        BattleUIMgr.goToContinus()
    end

    table.remove(currentRecord,1)

end

function BattleCotroller.roundStart(skillType,changePetType,witchPet,isManuChangePet)

    if not isRecord and battleMgr then
    	
        if STATE_WAIT_SELECT_SKILL == battleMgr.routineState then
            battleMgr:setPetChange(isManuChangePet,changePetType,witchPet)
            battleMgr:setcurSelectedSkill(0,skillType,true)
            battleMgr:setState(STATE_FIGHT_ONE)
            battleMgr:routine()
            currentRecord   = battleMgr:getCurRecord()
            table.insert(totalRecord,clone(currentRecord))
        else
            printFileLog("battleMgr.routineState...........",battleMgr.routineState) 
            return  
        end 
        if #currentRecord > 0 then
            BattleCotroller.judgeNextBattle()
        end
	    
    else
    	if #recordcoper > 0 then
    		currentRecord = clone(recordcoper[1])
    		table.remove(currentRecord,1)
    	else 
    		return
    	end 
        if #currentRecord > 0 then
            BattleCotroller.judgeNextBattle()
        end
	end 

    
    
end

function BattleCotroller.getCurrentRecords()
    return currentRecord
end

------客户端发出结束协议
function BattleCotroller.AnimationEnd() 

    if not isRecord and battleMgr then
        battleMgr:routine()
    	currentRecord 	= battleMgr:getCurRecord()
        if #currentRecord > 0 then
        	table.insert(totalRecord,clone(currentRecord))
        	BattleCotroller.judgeNextBattle()
        end
    else
    	if #recordcoper > 0 then 
            BattleCotroller.findPVPRecord()
    	end
	end    

end

function BattleCotroller.findPVPRecord()
    if isCloseRecord then
        return
    end
    recordIndex = recordIndex + 1
    BattlePVPMgr.checkCopyRecords()
end

function BattleCotroller.getCurrentRecordCount()
    return #currentRecord
end

function BattleCotroller.isRecordContent()
    if recordcoper[recordIndex] then 
        print("找到  战斗信息index....",recordIndex,BattlePVPMgr.dataIndex)
        currentRecord = clone(recordcoper[recordIndex])
        BattleCotroller.judgeNextBattle()
        BattlePVPMgr.dataIndex = BattlePVPMgr.dataIndex + 1
        return true
    else
        print("没找到  战斗信息index....",recordIndex,BattlePVPMgr.dataIndex)
        return false
    end

end

function BattleCotroller.getCurrentBattle()
    return battleMgr
end

function BattleCotroller.printBattleRecord(currentRecord)
    local temp = currentRecord[1]
    --require("src.Utils.GenUtils").printTable(temp)
    local attackType = temp[1]
    local skillType = temp[2]
    local attackedType = temp[3]
    local attackString = "我方"
    if attackType == 1 then
        attackString = "对方"
    end
    
    if #temp < 4 then
        if temp.changePet == true and BattleLogConfig.changePetLogFlag == true then
            printFileLog(string.format("%s 换宠",attackString))
        end
        return
    end
    
    local damageTable = temp[4][1]   
    local sendAnger = temp[5]
    local sendEnergy = temp[6]
    
    --printFileLog(string.format("%s:使用第%d个技能",attackString,skillType))
    --dumpXP(damageTable,"damage table",5)
    printFileLog("回合结束:")
    for i=1,#damageTable do
        local damageString = ""
        damageInfo = damageTable[i]
        if damageInfo.miss == true then
            damageString = "miss"
            printFileLog(damageString)
        else
            if damageInfo.critical then
                damageString = "暴击! "
            end
            if BattleLogConfig.damageResultLogFlag == true then
                if damageInfo.enemydamage ~= nil then
                    damageString = string.format("\t%s:%s造成%d伤害",BattleCotroller.getCurrentBattle().attackPet.name,damageString,damageInfo.enemydamage)
                    printFileLog(damageString)    
                end
                if damageInfo.selfdamage ~= nil then
                    damageString = string.format("\t%s:%s受到%d伤害",BattleCotroller.getCurrentBattle().attackPet.name,damageString,damageInfo.selfdamage)
                    printFileLog(damageString)    
                end
                if damageInfo.enemyheal ~= nil then
                    damageString = string.format("\t%s:%s对手得到%d治疗",BattleCotroller.getCurrentBattle().attackPet.name,damageString,damageInfo.enemyheal)
                    printFileLog(damageString)    
                end
                if damageInfo.selfheal ~= nil then
                    damageString = string.format("\t%s:%s得到%d治疗",BattleCotroller.getCurrentBattle().attackPet.name,damageString,damageInfo.selfheal)
                    printFileLog(damageString)    
                end
            end    
            if damageInfo.selfBuffer ~= nil and BattleLogConfig.bufferLogFlag == true then
                local skillTagInfo = BattleInfo.getSkillTagInfoByID(damageInfo.selfBuffer.id)
                damageString = string.format("\t%s:获得buff:%s %d回合",BattleCotroller.getCurrentBattle().attackPet.name,skillTagInfo.name,damageInfo.selfBuffer.round)
                printFileLog(damageString)  
            end
            if damageInfo.enemyBuffer ~= nil and BattleLogConfig.bufferLogFlag == true then
                local skillTagInfo = BattleInfo.getSkillTagInfoByID(damageInfo.enemyBuffer.id)
                damageString = string.format("\t%s:对手获得buff:%s %d回合",BattleCotroller.getCurrentBattle().attackPet.name,skillTagInfo.name,damageInfo.enemyBuffer.round)
                printFileLog(damageString)   
            end
        end
        
    end
    if attackType == 0 then
        --printFileLog(string.format("我方怒气:%d 能量:%d\t对方怒气:%d 能量:%d",sendAnger[1],sendEnergy[1],sendAnger[2],sendEnergy[2]))
    else
        --printFileLog(string.format("我方怒气:%d 能量:%d\t对方怒气:%d 能量:%d",sendAnger[2],sendEnergy[2],sendAnger[1],sendEnergy[1]))
    end    
end

function BattleCotroller.setNoMiss(miss)

    BattleCotroller.noMiss = miss

end

function BattleCotroller.getRecord()
    return clone(totalRecord), clone(battleResult)
end

function BattleCotroller.setRecordName(nameA, nameB)
    BattleCotroller.recordNameA = nameA
    BattleCotroller.recordNameB = nameB
end

function BattleCotroller.shareBattleRecord(callFuc,teamNameB,teamA,teamB,result,record)

    local nameA = CharInfo.getNickName()
    local nameB = ""
    if teamNameB then
        nameB = teamNameB
    else
        nameA = BattleCotroller.recordNameA
        nameB = BattleCotroller.recordNameB
    end

    local dataTeamA, dataTeamB, dataResult, dataRecord
    if teamA and teamB and result and record then
        dataTeamA = teamA
        dataTeamB = teamB
        dataResult = result
        dataRecord = record
    else
        dataTeamA, dataTeamB = BattleMapMgr.getBattlePets()
        dataRecord, dataResult = BattleCotroller.getRecord()
    end

    local function callback(event)

        local request = event.request
        if ("completed" ~= event.name) then
            return
        end

        local code = request:getResponseStatusCode()
        if (200 ~= code) then
            return
        end

        local data = request:getResponseString()
        local dedata = json.decode(data)

        if callFuc then
            callFuc(nameA,nameB,dedata._id,dataResult)
        end

    end

    local data = sz_T2S({nameA = nameA, nameB = nameB, teamA = dataTeamA, teamB = dataTeamB, result = dataResult, record = dataRecord})
    local req = network.createHTTPRequest(callback, "http://192.168.240.1:8080/saveUserShareData", "POST")
    req:setPOSTData(data)
    req:start()

end

function BattleCotroller.getBattleRecord(id)

    local function callback(event)

        local request = event.request
        if ("completed" ~= event.name) then
            return
        end

        local code = request:getResponseStatusCode()
        if (200 ~= code) then
            return
        end

        local data = request:getResponseString()
        local dedata = json.decode(data)

        local readata = loadstring("return "..dedata.data)()

        local TeamA = readata.teamA
        local TeamB = readata.teamB

        local records = readata.record

        local result = readata.result

        BattleCotroller.setRecordName(readata.nameA, readata.nameB)
        BattleMapMgr.setRecordToBattle(TeamA,TeamB,records,result)
    end

    local req = network.createHTTPRequest(callback, "http://192.168.240.1:8080/loadUserShareData?id="..id, "GET")
    req:start()

end

function BattleCotroller.setEnterBattleScene(isEnter)

    BattleCotroller.enterBattleScene = isEnter

end

return BattleCotroller