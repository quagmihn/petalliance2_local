local ExploreViewMgr = {}

ExploreViewMgr.SHOW_ACTVT_RP = true

local resName = ""
local redFlag = {}

function ExploreViewMgr.Init()
    ExploreViewMgr.SHOW_ACTVT_RP = true

    resName = "Player/ExploreMain.csb"
    redFlag = {false, false}    
end

function ExploreViewMgr.show(scene)
    UIStack.push("ExploreViewMgr", ExploreViewMgr.hide, false)
    local function loadCsb()
        local layer = CSResourceMgr.createRes(scene, resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CocosModuleMgr.setRelativePosition(layer, 320, 480)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)
        
        if LostTowerInfo.checkLTActivity() then
            if not ExploreViewMgr.hasRedPoint() then
                BasicMenuMgr.hideRedPoint(3)
            end
            ExploreViewMgr.SHOW_ACTVT_RP = false
            CSResourceMgr.setSpriteTexture(resName, "hot2", CocosModuleMgr.getWordImage("qiancengta_huodong.png"))
        end
        
        CSResourceMgr.setLabelColor(resName, "title", {r=166,g=243,b=255,a=255})
        CSResourceMgr.setLabelString(resName, "title", "menu7", "", {r=37,g=54,b=75,a=255})
        
        local nameStr = {"menu8", "menu9", "expedition1"}
        local lockStr = {"menu10", "menu11", "expedition0"}
		local ExpeditionLevelStr = {"expeditionLevelShow1", "expeditionLevelShow2", "expeditionLevelShow3", "expeditionLevelShow4", "expeditionLevelShow5", "expeditionLevelShow6"}
        local lockInfo = {SystemInfo.getGlobalConfigAddInfoByID(21008).values[1], 
            WorldMapInfo.getLockInfoByID(1)[60],1}
        for var=1, #nameStr do
            CSResourceMgr.setLabelColor(resName, "text"..var, {r=251,g=240,b=215,a=255})
            CSResourceMgr.setLabelString(resName, "text"..var, nameStr[var], "", {r=80,g=61,b=35,a=255,w=1}, nil, 140)
            CSResourceMgr.clickEventBinding(resName, "b"..var, function()
                ExploreViewMgr.hide()
            	if var==1 then
            		PetExploreMgr.request(scene)
            	elseif var==2 then
                    LostTowerMgr.sendCreateReq(function()
                        SceneMgr.replaceScene(SceneMgr.getRunningScene, "LostTowerScene")
                    end)
                elseif var==3 then
                    NetInterface.sendWithBlock("GC_GetServerTime_Ack", function()
                        local LoginSend = require("src.Net.Send.LoginSend")
                        LoginSend.sendCG_GetServerTime_Req() 
                    end, function()
                        
                        local maxLevel  = CharInfo.getFinishExpeditionLevel()
                        local currLevel = CharInfo.getCurrentExpeditionLevel()
                        if maxLevel == nil then
                            maxLevel = 0
                        end

                        if currLevel == nil then
                            currLevel = 0
                        end

                        if not expeditionalViewMgr.checkExpeditionOverDate() then 
                            if not expeditionalViewMgr.checkExpeditionFinishTime() then 
                                maxLevel = -1
                            end
                            if maxLevel == currLevel then
                                expeditionalViewMgr.OpenChooseTypesUI(SceneMgr.getRunningScene)  
                            else
                                expeditionalViewMgr.enterExpedition(currLevel)
                            end
                            expeditionalViewMgr.refresh = false
                        else
                            expeditionalViewMgr.refresh = true
                            expeditionalViewMgr.OpenChooseTypesUI(SceneMgr.getRunningScene)
                        end

                    end, function(code)
                        
                        TipsMgr.showError(nil, code)
                    end)
                    
                    --远征入口
            	end
            end, "", 2)
            if CharInfo.get().maplock>=lockInfo[var] then
                if var==1 then
                    local curNum = nil
                    local function refreshFunc()
                        local tmpNum = ExploreInfo.getCurAwardsItemNum()
                        --print("explore bag num:", curNum, tmpNum)
                    	if curNum~=tmpNum then
                    	    curNum = tmpNum
                            CSResourceMgr.setLabelString(resName, "info"..var, CocosModuleMgr.createStringWithFormat({
                                "menu12", curNum, CharInfo.get().explorepacketnum}), "", nil, nil, 180)
                    	end
                        CSResourceMgr.getCsbObj(resName):performWithDelay(function()
                            refreshFunc()
                        end, 1)
                    end
                    refreshFunc()
                elseif var==2 then
                    local curNum = nil
                    local function refreshFunc()
                        local tmpNum = LostTowerInfo.getCurrentStepNumber()
                        --print("losttower step num:", curNum, tmpNum)
                        if curNum~=tmpNum then
                            curNum = tmpNum
                            CSResourceMgr.setLabelString(resName, "info"..var, CocosModuleMgr.createStringWithFormat({
                                "menu13", curNum}), "", nil, nil, 180)
                        end
                        CSResourceMgr.getCsbObj(resName):performWithDelay(function()
                            refreshFunc()
                        end, 1)
                    end
                    refreshFunc()
                elseif var==3 then
				    if CharInfo.getLevel() >= SystemInfo.getGlobalConfigAddInfoByID(63002).values[1] then 
                        CSResourceMgr.setButtonEnabled(resName, "b"..var, false)
                        NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
                        local LoginSend = require("src.Net.Send.LoginSend")
                        LoginSend.sendCG_GetCharacterValues_Req({"finishExpeditionLevel","finishExpeditionTime",
                            "currentExpeditionLevel","expeditionCreateTime"}) 
                        end, function()
                                CSResourceMgr.setButtonEnabled(resName, "b"..var, true)   
        						local curNum = nil
                                local tmpNum = CharInfo.getCurrentExpeditionLevel()
                                if tmpNum == nil or expeditionalViewMgr.checkExpeditionOverDate() then
                                    curNum = 6
                                    CSResourceMgr.setLabelString(resName, "info"..var,ExpeditionLevelStr[curNum], "", nil, nil, 180)
                                else
                                    curNum = tmpNum
                                    CSResourceMgr.setLabelString(resName, "info"..var,ExpeditionLevelStr[curNum], "", nil, nil, 180)
                                end
                            end, function(code)
                            
                            TipsMgr.showError(nil, code)
                        end)
					else
						CSResourceMgr.setButtonEnabled(resName, "b"..var, false)
						--CSResourceMgr.getNodeByName(resName, "infodb"..var):setVisible(false)
						CSResourceMgr.getNodeByName(resName, "b"..var):setColor({r=100,g=100,b=100})
						CSResourceMgr.setLabelString(resName, "lock"..var, lockStr[var], "", {r=0,g=0,b=0,a=255,w=1}, nil, 200)
					end
                end
            else
                CSResourceMgr.setButtonEnabled(resName, "b"..var, false)
                --CSResourceMgr.getNodeByName(resName, "infodb"..var):setVisible(false)
                CSResourceMgr.getNodeByName(resName, "b"..var):setColor({r=100,g=100,b=100})
                CSResourceMgr.setLabelString(resName, "lock"..var, lockStr[var], "", {r=0,g=0,b=0,a=255,w=1}, nil, 200)
            end
            if redFlag[var] then
                CSResourceMgr.getNodeByName(resName, "red"..var):setVisible(true)
            end
        end

        CSResourceMgr.clickEventBinding(resName, "bg", function()
            ExploreViewMgr.hide()
        end)
    end

    local function playCsb()
        local db = CSResourceMgr.getNodeByName(resName, "db")
        db:setVisible(true)
        CocosModuleMgr.showUIAnimation(db, "down")
    end

    local funcTable = {loadCsb, playCsb}
    UnblockLoader.load(funcTable, "ExploreViewMgr.show")
end

function ExploreViewMgr.hide()
    UnblockLoader.cancel("ExploreViewMgr.show")
	CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("ExploreViewMgr")
end

function ExploreViewMgr.hasRedPoint()
    local flag = false
    for var=1, #redFlag do
        if redFlag[var] then
            flag = true
            break
        end
    end
    return flag
end

---添加红点
--@param type int 1挂机寻宝，2迷失之塔
function ExploreViewMgr.addRedPoint(type)
    local flag = ExploreViewMgr.hasRedPoint()
    redFlag[type] = true
    local redNode = CSResourceMgr.getNodeByName(resName, "red"..type)
    if redNode then
        redNode:setVisible(true)
    end
    if not flag then
        BasicMenuMgr.addRedPoint(3)
    end
end

---取消红点
--@param type int 1挂机寻宝，2迷失之塔
function ExploreViewMgr.hideRedPoint(type)
    redFlag[type] = false
    local redNode = CSResourceMgr.getNodeByName(resName, "red"..type)
    if redNode then
    	redNode:setVisible(false)
    end
    local flag = ExploreViewMgr.hasRedPoint()
    if not flag then
        if LostTowerInfo.checkLTActivity() then
            if not ExploreViewMgr.SHOW_ACTVT_RP then
                BasicMenuMgr.hideRedPoint(3)
        	end
        else
            BasicMenuMgr.hideRedPoint(3)
        end        
    end
end

return ExploreViewMgr