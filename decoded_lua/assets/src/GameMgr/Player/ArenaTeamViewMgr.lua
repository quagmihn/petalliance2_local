local ArenaTeamViewMgr = {}

local resName = ""
ArenaTeamViewMgr.TAB_NUM = 5
local outlineColor = {
    {r=0,g=0,b=0,a=255}
}

function ArenaTeamViewMgr.Init()
    print("ArenaTeamViewMgr初始化")
    
    resName = "Player/Arena/ChangeTeamNew.csb"
end

---显示调整编队
--@param scene node 场景
--@param curTeamID int 当前选择的编队，1~5
--@param type int 攻击0，防御1
function ArenaTeamViewMgr.show(scene, curTeamID, type)
	local function loadCSB()
        CSResourceMgr.createRes(scene, resName):setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        
        CSResourceMgr.setLabelString(resName, "atk_name", "arena26")
        local atkName = CSResourceMgr.getNodeByName(resName,"atk_name")
        atkName:enableOutline(outlineColor[1], ArenaViewMgr.LABLE_OUTLINE_THICK)
        
        CSResourceMgr.clickEventBinding(resName, "bg", function()
        	ArenaTeamViewMgr.hide()
        end)
        CSResourceMgr.setLabelString(resName, "save_lb", "arena19", "", {r=0,g=0,b=0,a=255})
        CSResourceMgr.clickEventBinding(resName, "save", function()
            local pageView = CSResourceMgr.getNodeByName(resName, "pageview")
            local index = pageView:getCurPageIndex()+1
            if #PokemonInfo.getPetArmy(index)==0 then
                DialogBoxMgr.showSmallDialogBox(scene, 1, "arena24")
                return
            end
            local function refresh()
                ArenaViewMgr.refreshPets(index)
                ArenaTeamViewMgr.hide()
            end
            if type==0 then
                ArenaInfo.update({armyID=index})
                refresh()
            else
                NetInterface.sendWithBlock("GC_ChangeArenaPetObjIDs_Ack", function()
                	local ArenaSend = require("src.Net.Send.ArenaSend")
                    ArenaSend.sendCG_ChangeArenaPetObjIDs_Req(index)
                end, function()
                    ArenaInfo.update({teamID=index})
                    refresh()
                end, function(code)
                    TipsMgr.showError(scene, code)
                end)
            end
        end, "", 2)
	end
	
	local function setPets()
        local pageView = CSResourceMgr.getNodeByName(resName, "pageview")
        pageView:scrollToPage(curTeamID-1)
	
	    local panelVec = {}
        panelVec[1] = CSResourceMgr.getNodeByName(resName, "panel")
        for var=2, PetFormationMgr.TEAM_NUM do
            local panel = CSResourceMgr.getNodeByName(resName, "panel"):clone()
            pageView:addPage(panel)
            panelVec[var] = panel
		end
		
        local petDiffx = 90
        local petDiffy = 10
        for i=1, PetFormationMgr.TEAM_NUM do
            local info = PokemonInfo.getPetArmy(i)
            for var=1, #info do
                local objID = info[var]
                local petInfo = PokemonInfo.getPetInfoByObjID(objID)
                local parent = CSResourceMgr.seekNodeByName(panelVec[i], "petdiban")
                local pNode = PetListMgr.createPetNode(petInfo, var+10)
                local cloneNode = pNode.node
                cloneNode:addTo(parent)
                cloneNode:setPositionX(cloneNode:getPositionX()+petDiffx*(var-1))
                cloneNode:setPositionY(cloneNode:getPositionY()+petDiffy)
                cloneNode:setScale(0.7)
                
                parent:setCascadeOpacityEnabled(true)
                parent:setOpacity(0)
                parent:setVisible(true)
                transition.fadeIn(parent, {time=0.3})
            end
		end

        local curTab = 1
        local function changeTab(tabid)
            CSResourceMgr.getNodeByName(resName, "tab"..curTab):setLocalZOrder(0)
            CSResourceMgr.setLabelString(resName, "tabtext"..curTab, CocosModuleMgr.createStringWithFormat({"arena2",curTab}), "", {r=255,g=255,b=255,a=255})
            CSResourceMgr.setLabelColor(resName, "tabtext"..curTab, {r=82,g=82,b=82,a=255})
            CSResourceMgr.setButtonEnabled(resName, "tab"..curTab, true)
            local spriteTab = CSResourceMgr.getNodeByName(resName, "tab"..curTab)
            spriteTab:setPositionY(614)
            spriteTab:setScale(1)
            curTab = tabid
            CSResourceMgr.getNodeByName(resName, "tab"..tabid):setLocalZOrder(1)
            CSResourceMgr.setLabelString(resName, "tabtext"..tabid, CocosModuleMgr.createStringWithFormat({"arena2",tabid}), "", {r=210,g=138,b=2,a=255})
            CSResourceMgr.setLabelColor(resName, "tabtext"..tabid, {r=255,g=255,b=255,a=255})
            CSResourceMgr.setButtonEnabled(resName, "tab"..tabid, false)
            pageView:scrollToPage(tabid-1)
            local spriteTab = CSResourceMgr.getNodeByName(resName, "tab"..tabid)
            spriteTab:setPositionY(618)
            spriteTab:setScale(1.2)
            
            local fp = 0
            local info = PokemonInfo.getPetArmy(curTab)
            for var=1, #info do
                local objID = info[var]
                local petInfo = PokemonInfo.getPetInfoByObjID(objID)
                fp = fp + PokemonInfo.getFightPoint({petInfo})
            end
            CSResourceMgr.setLabelString(resName, "atk_num", fp)
            local atnNum = CSResourceMgr.getNodeByName(resName,"atk_num")
            atnNum:enableOutline(outlineColor[1], ArenaViewMgr.LABLE_OUTLINE_THICK)

        end

        for var=1, ArenaTeamViewMgr.TAB_NUM do
            if var == curTab then
                CSResourceMgr.getNodeByName(resName, "tab"..var):setLocalZOrder(1)
                CSResourceMgr.setLabelString(resName, "tabtext"..var, CocosModuleMgr.createStringWithFormat({"arena2",var}), "", {r=210,g=138,b=2,a=255})
                CSResourceMgr.setLabelColor(resName, "tabtext"..var, {r=255,g=255,b=255,a=255})
                CSResourceMgr.setButtonEnabled(resName, "tab"..var, false)
                local spriteTab = CSResourceMgr.getNodeByName(resName, "tab"..var)
                spriteTab:setPositionY(618)
                spriteTab:setScale(1.2)
            else
                CSResourceMgr.getNodeByName(resName, "tab"..var):setLocalZOrder(0)
                CSResourceMgr.setLabelString(resName, "tabtext"..var, CocosModuleMgr.createStringWithFormat({"arena2",var}), "", {r=255,g=255,b=255,a=255})
                CSResourceMgr.setLabelColor(resName, "tabtext"..var, {r=82,g=82,b=82,a=255})
            end
            CSResourceMgr.clickEventBinding(resName, "tab"..var, function()
                changeTab(var)
            end)
        end
        changeTab(1)
	end
	
	local function playCSB()
		CSResourceMgr.playAction(resName, 0, 5, false)
	end
    local funcTable = {loadCSB, setPets, playCSB}
    -- loadCSB()
    -- setPets()
    -- playCSB()
    UnblockLoader.load(funcTable, "ArenaTeamViewMgr")
end

function ArenaTeamViewMgr.hide()
    CSResourceMgr.playActionWithCallback(resName, 50, 55, 1, function()
        UnblockLoader.cancel("ArenaTeamViewMgr")
        CSResourceMgr.getNodeByName(resName, "pageview"):removeAllPages()
        CSResourceMgr.removeCSObjectByTag(resName)
    end)
end

return ArenaTeamViewMgr