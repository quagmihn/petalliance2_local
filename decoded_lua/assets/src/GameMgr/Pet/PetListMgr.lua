local PetListMgr = {}

PetListMgr.RANK_NUM = 4
PetListMgr.TAB_NUM = 3
--PetListMgr.petCardTemplate = nil
local useunblockloader = true --是否使用携程，方便调试
local keystr = "PetListUI" --objectpool的类型
local BattleFuncMgr = require("src.GameMgr.Battle.BattleFuncMgr")
local resNameP = ""
local resName = ""
local imageRes = ""
local petNodeRes = ""
local petcardres = ""
local panelTable = {}
local petSpriteTable = {}
local struct = {}
local selPetVec = {}
local hideCallback = nil
local updateFlags = {}
local btnClickCallback = nil
local maxPetCount = 6
local tempTab = 1
local petIndexVec = {}
local mapskillInfo = nil
local BattleFuncMgr = require("src.GameMgr.Battle.BattleFuncMgr")
local tabLabelVec = {
    "train63",
    "train64",
    "train65"
}

local moveDiffTable = {
    93,
    93,
    124,
    93,
    93
}

local panelTableTest = {}
local isObjectcachesLoaded = false
PetListMgr.haveGuideStarUp = false

function PetListMgr.Init()
    print("PetListMgr Init!")

    resNameP = "Pet/BasicPetList/NCommonPet.csb"
    resName = "Pet/BasicPetList_2/PetList.csb"
    -- CSResourceMgr.createRes(nil, resName, nil, true)
    imageRes = "UI/CommonFiles/kuang2.png"
    petNodeRes = "Pet/BasicPetList_2/PetListPanelTemplate.csb"
    petcardres  = "Pet/petcards/petcard.csb"
    panelTable = {}
    petSpriteTable = {}
    struct = {}
    selPetVec = {}
    hideCallback = nil
    updateFlags = {}
    btnClickCallback = nil
    maxPetCount = 6
    tempTab = 1
    petIndexVec = {}

    local mapSkillInfoReader = TxtReader.new("Config/MapSkill.txt")
    mapskillInfo = mapSkillInfoReader.init({"id","HandBookID","desc","langID"},1)
    
    --petCardTemplate = CSResourceMgr.createRes(nil,"Pet/BasicPetList_2/BattlePet.csb","petCardTemplate")
   
    local function initobjectcache()

        --local maxnum = CharInfo.get().petpacketnum
        local count = 20
        
        
        CSResourceMgr.createRes(nil, petNodeRes,nil,true)
      
        
        local btn = BattleFuncMgr.createCacheObjectForPetCard(3)
        ObjectPool.add(keystr,btn) 
        
        local function loadListCell()
            local cell = btn:clone()
            ObjectPool.add(keystr,cell)
            print("object pool add petlist")   
        end
        
        local funcTable = {}
  
        for i=1,count do
            
            table.insert(funcTable,loadListCell)
        end    
   
        
        UnblockLoader.load(funcTable, "PetListCache")

    end
    if isObjectcachesLoaded==false then
        initobjectcache()
    	isObjectcachesLoaded = true
    end
    PetListMgr.haveGuideStarUp = false
end

function PetListMgr.setUpdateFlag(key)
    print(key,key,key,key,key,key,key,key,key,key,key)
    updateFlags[key] = true
end

function PetListMgr.getStarPicByStar(starID)
    if starID <= 0 then
        return "Pet/BasicPetList_2/xing/1.png"
    end
    local picID = math.ceil(starID/5)
    return string.format("Pet/BasicPetList_2/xing/%d.png",picID)
end

local function createListCell(pokeArray,resetCallBack)
    local listcell = CSResourceMgr.getNodeByName(petNodeRes,"panel"):clone()
    --
    for i = 1,4 do
        local node = CSResourceMgr.seekNodeByName(listcell,"btn"..i)   
        node:setVisible(false)
    end

    for i = 1,#pokeArray do
        local parent = CSResourceMgr.seekNodeByName(listcell,"btn"..i)
        parent:setVisible(true)
        PetListMgr.createPetCardWithName2(parent,pokeArray[i],resetCallBack)
    end

    return listcell
end

function PetListMgr.preLoad(scene)

end

--scene可以为场景，也可以为任意父节点（可设置pos）
--callback可以为单function，也可以为function组（暂不支持）
function PetListMgr.show(scene, btnCallback, resetCallback, closeCallback, pos, petVec)
    PetListMgr.open(scene, btnCallback, resetCallback, closeCallback, pos, petVec)
end

function PetListMgr.open(scene, btnCallback, resetCallback, closeCallback, pos, petVec)
    local tempPets = petVec or PokemonInfo.getAllPets(nil, true)
    local myPets = PetListMgr.sortPetList(tempPets)
    hideCallback = closeCallback

    local function loadCSB()
        --print("PetListMgr resname............"..resName)
        UnblockLoader.cancel("PetListCache")
        local curLayer = CSResourceMgr.createRes(scene, resName)
        CSResourceMgr.getNodeByName(resName,"db"):setVisible(false)
        CSResourceMgr.setFrame(resName, 5)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CocosModuleMgr.setEdgeDistance(curLayer, nil, nil, nil, 0)
    end
    
    local function initCSB()
        local diff = CocosModuleMgr.getScreenSizeDiff()
        local qh_xcd = CSResourceMgr.getNodeByName(resName, "qh_xcd")
        local qhsize = qh_xcd:getContentSize()
        qh_xcd:setContentSize(qhsize.width, qhsize.height+diff)
        local tanchu2 = CSResourceMgr.getNodeByName(resName, "tanchu2")
        local tcsize = tanchu2:getContentSize()
        tanchu2:setContentSize(tcsize.width, tcsize.height+diff)
        local diwen = CSResourceMgr.getNodeByName(resName, "diwen")
        local dwsize = diwen:getContentSize()
        diwen:setContentSize(dwsize.width, dwsize.height+diff)
        local listBG = CSResourceMgr.getNodeByName(resName, "listBG")
        local ltsize = listBG:getContentSize()
        listBG:setContentSize(ltsize.width, ltsize.height+diff)
        local list = CSResourceMgr.getNodeByName(resName, "list")
        local lisize = list:getContentSize()
        list:setContentSize(lisize.width, lisize.height+diff)
        local tabs = CSResourceMgr.getNodeByName(resName, "tabs")
        local fposy = tabs:getPositionY()
        tabs:setPositionY(fposy+diff)
        local topbar = CSResourceMgr.getNodeByName(resName, "topbar")
        local tposy = topbar:getPositionY()
        topbar:setPositionY(tposy+diff)

        local spriteBg = CSResourceMgr.getNodeByName(resName, "qh_xcd")
        spriteBg:setLocalZOrder(-2)

        local function setTabStatus(tabid,enable)
            local tabBtn = CSResourceMgr.getNodeByName(resName, "tab"..tabid)
            
            if enable then
                CSResourceMgr.setButtonStringByNode(tabBtn, tabLabelVec[tabid], {r=89,g=47,b=5,a=255})
                CSResourceMgr.setButtonStringColorByNode(tabBtn, {r=255,g=243,b=227,a=255})
            else
                CSResourceMgr.setButtonStringByNode(tabBtn, tabLabelVec[tabid], {r=10,g=22,b=65,a=255})
                CSResourceMgr.setButtonStringColorByNode(tabBtn, {r=227,g=233,b=255,a=255})
            end
        end

        for var=1, PetListMgr.TAB_NUM do
            setTabStatus(var,false)
        end

        local charLock = CharInfo.get().maplock
        local val = SystemInfo.getGlobalConfigAddInfoByID(21014).values[1]

        for var=1, PetListMgr.TAB_NUM do
            if var == 1 then
                local spriteTab = CSResourceMgr.getNodeByName(resName, "tab1")
                spriteTab:setLocalZOrder(1)
                local fposy = spriteTab:getPositionY()
                spriteTab:setPositionY(fposy+3)
                setTabStatus(var,true)
            end
            local spriteTab = CSResourceMgr.getNodeByName(resName, "tab"..var)
            CSResourceMgr.clickEventBinding(resName, "tab"..var, function()
                GameAudio.playUISound("sheetClick")
                if var == 3 and charLock < val then
                    DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 1, "train126")
                else
                    spriteTab:setLocalZOrder(1)
                    local fposy = spriteTab:getPositionY()
                    spriteTab:setPositionY(fposy+3)
                    setTabStatus(var,true)
                    if tempTab ~= var then
                        local spriteTab = CSResourceMgr.getNodeByName(resName, "tab"..tempTab)
                        spriteTab:setLocalZOrder(0)
                        local fposy = spriteTab:getPositionY()
                        spriteTab:setPositionY(fposy-3)
                        setTabStatus(tempTab,false)
                    end
                    tempTab = var
                    PetListMgr.changeTab(var)
                end
            end)
        end
        
        PetListMgr.changeTab(1, true)

        -- CSResourceMgr.clickEventBinding(resName, "close", function()
        --     PetListMgr.hide()
        -- end)
        -- CSResourceMgr.setButtonString(resName, "close", "train66", "",CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)

        -- CSResourceMgr.setButtonStringColor(resName, "saveBtn", {r=227,g=233,b=255,a=255})
        -- CSResourceMgr.setButtonString(resName, "saveBtn", "保存", "", {r=0,g=0,b=0,a=255})

        CSResourceMgr.setButtonStringColor(resName, "freeBtn", {r=227,g=233,b=255,a=255})
        CSResourceMgr.setButtonString(resName, "freeBtn", "train67", "", {r=0,g=0,b=0,a=255})

        local selPet = PetFormationMgr.getSelPet()
        local helpPet = PetFormationMgr.getHelpPet()
        local tabIsInit = PetFormationMgr.getTabIsInit()
        
        local skillIDs = {}
        for k,v in pairs(mapskillInfo) do
            table.insert(skillIDs,tonumber(v.HandBookID))
        end
        local function checkSKillByID(skillId)
            local vec = {0,0,0}
            local id = math.floor(skillId/10)
            for i=1,#skillIDs do
                if id == skillIDs[i] then
                    vec[i] = 1
                end
            end
            return vec
        end

        local function checkSKillByIdx(skillId,idx)
            local isHas = 0
            local id = math.floor(skillId/10)
            if id == skillIDs[idx] then
                isHas = 1
            end
            return isHas
        end

        local petRareVec = {}
        local function sendProto()
            NetInterface.sendWithBlock("GC_PetFreedom_Ack", function()
                PetFreeListMgr.setIsFreedomPets(true)
                local PetSend = require("src.Net.Send.PetSend")
                PetSend.sendCG_PetFreedom_Req(selPetVec)
            end, function()
                TaskWatcherManager.onChongWuFangSheng()
                PetFreeListMgr.showGetAwards()
                local myPets = PokemonInfo.getAllPets(nil, PetListMgr.isShowYokePets())
                local petVec = PetListMgr.sortPetList(myPets)
                local curTab = PetFormationMgr.getCurTab()
                selPetVec = {}
                petRareVec = {}
                UnblockLoader.cancel("PetListMgr-reset")
                PetListMgr.reset(petVec, nil, function(petInfo)
                    for var=1, #selPet[curTab] do
                        if petInfo.objID==selPet[curTab][var].objID then
                            PetListMgr.setStatusLabel(selPet[curTab][var].objID, true)
                            break
                        end
                    end
                    for var=1, #helpPet[curTab] do
                        if petInfo.objID==helpPet[curTab][var].objID then
                            PetListMgr.setStatusLabel(helpPet[curTab][var].objID, true)
                            break
                        end
                    end
                    if PetEducationMgr.isPetYoked(petInfo) then
                        PetListMgr.setStatusYoke(petInfo.objID, true)
                    end
                end)
                PetFormationMgr.sortAll()
                PetListMgr.changeTab(3)
            end, function(code)
                TipsMgr.showError(scene, code)
            end)
        end

        local isRepeat = false

        CSResourceMgr.clickEventBinding(resName, "freeBtn", function()
            if #selPetVec==0 then
            	return
            end
            if #PokemonInfo.getAllPets() <= 1 then
                DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,1,"train54")
            else
                local needCheck = false
                local checkVec = {0,0,0}
                for k,v in pairs(selPetVec) do
                    local petInfo = PokemonInfo.getPetInfoByObjID(v)
                    for k1,v1 in pairs(petInfo.skills) do
                        if v1 ~= 0 then
                            local vec = checkSKillByID(v1)
                            for i=1,#vec do
                                if vec[i] == 1 then
                                    needCheck = true
                                    checkVec[i] = 1
                                end
                            end
                        end
                    end
                end
                if needCheck then
                    local vec = PokemonInfo.getAllPets()
                    for k,v in pairs(vec) do
                        for k1,v1 in pairs(selPetVec) do
                            if v.objID == v1 then
                                table.remove(vec,k)
                            end
                        end
                    end
                    local isHas = {0,0,0}
                    local checkIdx = {}
                    for k,v in pairs(vec) do
                        for k1,v1 in pairs(v.skills) do
                            if v1 ~= 0 then
                                for var=1,#checkVec do
                                    if checkVec[var] ~= 0 then
                                        table.insert(checkIdx,var)
                                        isHas[var] = isHas[var] + checkSKillByIdx(v1,var)
                                    end
                                end
                            end
                        end
                    end
                    local tipStr = {}
                    for k,v in pairs(mapskillInfo) do
                        table.insert(tipStr,v.langID)
                    end
                    local needTip = false
                    local str = {"","",""}
                    for k,v in pairs(checkIdx) do
                        if isHas[v] == 0 then
                            needTip = true
                            str[v] = tipStr[v]
                        end
                    end
                    if needTip then
                        DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 2, CocosModuleMgr.createStringWithFormat({"train125", str[1],str[2],str[3]}),sendProto)
                    else
                        sendProto()
                    end
                else
                    for k,v in pairs(selPetVec) do
                        local petInfo = PokemonInfo.getPetInfoByObjID(v)
                        local rp = PokemonInfo.getPokemonInfoByID(petInfo.pokeID).rarePoint
                        if rp>2 then
                            DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, "train178", sendProto)
                            return
                        end
                    end
                    sendProto()
                end
            end
        end)
        
        local ylabel = CSResourceMgr.getNodeByName(resName, "yoketips")
        CSResourceMgr.setLabelColorByNode(ylabel, {r=121,g=151,b=179,a=255})
        CSResourceMgr.setLabelStringByNode(ylabel, "train220", nil, nil, 200)

        PetFormationMgr.SORT_ELEMENT = 0
        CSResourceMgr.getNodeByName(resName, "yokeCheckBox"):addEventListener(function()
            local isselected = CSResourceMgr.getNodeByName(resName, "yokeCheckBox"):isSelected()
            PetFormationMgr.sortPet(PetFormationMgr.SORT_ELEMENT)
        end)

        CSResourceMgr.getNodeByName(resName, "CheckBox"):addEventListener(function()
            local myPets = PokemonInfo.getAllPets()
            local selPet = PetFormationMgr.getSelPet()
            local helpPet = PetFormationMgr.getHelpPet()
            local petVec = {}
            for k,v in pairs(selPet[1]) do
                table.insert(petVec,v)
            end
            for k,v in pairs(helpPet[1]) do
                table.insert(petVec,v)
            end
            for key, var in pairs(myPets) do
                for k,v in pairs(petVec) do
                    if var.objID == v.objID then
                        isRepeat = true
                    end
                end
                local rp = PokemonInfo.getPokemonInfoByID(var.pokeID).rarePoint
                if rp<3 and not isRepeat and #petRareVec < 20 and not PetEducationMgr.isPetYoked(var) and var.star==0 
                    and not PetEducationMgr.isPetHasYoke(var) and not PetEquipmentMgr.isPetEquiped(var) then
                    table.insert(petRareVec, var)
                end
                isRepeat = false
            end
            
            local isselected = CSResourceMgr.getNodeByName(resName, "CheckBox"):isSelected()
            selPetVec = {}
            local petfreeVec = {}
            for key, var in pairs(myPets) do
                local pObjID = var.objID
                PetListMgr.setStatus(pObjID, true, false, false, false)
                if isselected then
                    for k, v in pairs(petRareVec) do
                        if v.objID == pObjID and pObjID ~= 1 then
                            PetListMgr.setStatus(pObjID, true, false, true, false)
                            table.insert(selPetVec, pObjID)
                            table.insert(petfreeVec, v.pokeID)
                            break
                        end
                    end
                else
                    petRareVec = {}
                end
            end
            if #petfreeVec>0 then
            	PetFreeListMgr.setAwardsCount(petfreeVec)
            else
                PetFreeListMgr.setAwardsCount(nil, "all")
            end
            local freeCount = 0
            for k,v in pairs(petRareVec) do
                if v.objID ~= 1 then
                    freeCount = freeCount + 1
                end
            end
            CSResourceMgr.setLabelString(resName,"pnum",freeCount.."/20","")
        end)

        CSResourceMgr.clickEventBinding(resName,"pnumEx",function()
            if CharInfo.get().petpacketnum < 200 then
                local price = SystemInfo.getGlobalConfigAddInfoByID(6702).values[1]
                local bagnum = SystemInfo.getGlobalConfigAddInfoByID(6703).values[1]
                
                --阿杜修改英文版显示
                local str = CocosModuleMgr.createStringWithFormat({"bag12", 
                    CocosModuleMgr.createStringWithFormat({"<1><2>", price, "tips17"}), bagnum})
                if LuaSqlite.LANG_TYPE ~= 1 then
                    str = CocosModuleMgr.createStringWithFormat({"bag12", price,bagnum})
                end
                DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, str, function()
                    if price>CharInfo.getMCash() then
                        StandardTipsMgr.show(1, "tips14")
                        return
                    end
                        NetInterface.sendWithBlock("GC_BuyPacket_Ack", function()
                        local ItemSend = require("src.Net.Send.ItemSend")
                        ItemSend.sendCG_BuyPacket_Req(2)
                    end, function()
                        PetListMgr.setBnum()
                    end, function(code)
                        TipsMgr.showError(scene, code)
                    end)
                end)
            else
                DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 1, "train200")
            end
        end)
    end

    local function initPet()
        PetListMgr.reset(myPets, btnCallback, resetCallback)
    end
    
    local function playCSB()
        CSResourceMgr.getNodeByName(resName,"db"):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName,"db"), "up")
    end

    if useunblockloader then
        local funcTable = {loadCSB, initCSB,playCSB,initPet}
        UnblockLoader.load(funcTable, "PetListMgr")
    else
        loadCSB() initCSB() playCSB() initPet()
    end
    --
 
    --
end

function PetListMgr.changeTab(tabid, isFirst)
    for var=1, PetListMgr.TAB_NUM do
        CSResourceMgr.setButtonEnabled(resName, "tab"..var, true)
    end
    CSResourceMgr.setButtonEnabled(resName, "tab"..tabid, false)

    local tips = CSResourceMgr.getNodeByName(resName, "tips")
    tips:setLocalZOrder(3)

    local CheckBox = CSResourceMgr.getNodeByName(resName, "CheckBox")
    CheckBox:setLocalZOrder(4)
    
    local yokeCheckBox = CSResourceMgr.getNodeByName(resName, "yokeCheckBox")
    if tabid==1 then
        yokeCheckBox:show()
    else
        yokeCheckBox:hide()
    end

    local selPet = PetFormationMgr.getSelPet()
    local helpPet = PetFormationMgr.getHelpPet()
    local curTab = PetFormationMgr.getCurTab()
    local tabIsInit = PetFormationMgr.getTabIsInit()
    local curTeamButton,curTeamPetInfo = PetFormationMgr.getCurTeamInfo()

    local myPets = PokemonInfo.getAllPets(nil, PetListMgr.isShowYokePets())
    for k,v in pairs(myPets) do
        PetListMgr.setStatus(v.objID, true, false, false, false)
    end
    
    if tabid == 2 then
        for var=1, #selPet[curTab] do
            PetListMgr.setStatusLabel(selPet[curTab][var].objID, false)
            PetListMgr.setStatus(selPet[curTab][var].objID, true, true, false, false)
        end

        for var=1, #helpPet[curTab] do
            PetListMgr.setStatusLabel(helpPet[curTab][var].objID, false)
            PetListMgr.setStatus(helpPet[curTab][var].objID, true, true, false, false)
        end

        for key, var in pairs(curTeamPetInfo) do
            PetFormationMgr.dragEventBinding(curTeamButton[key], curTeamPetInfo[key])
        end

        for k,v in pairs(myPets) do
            if v.yoke then
                if v.yoke.bindTo then
                    PetListMgr.setStatusYoke(v.objID,true)
                end
            end
        end
    else
        local isChange = false
        local petVec = PokemonInfo.getPetArmy(PetFormationMgr.getCurTab())
        local petHelpVec = PokemonInfo.getPetHelpArmy()
        if #petVec == #selPet[curTab] and #petHelpVec == #helpPet[curTab] then
            for var=1, #selPet[curTab] do
                if petVec[var] ~= selPet[curTab][var].objID then
                    isChange = true
                end
            end
            for var=1, #helpPet[curTab] do
                if petHelpVec[var] ~= helpPet[curTab][var].objID then
                    isChange = true
                end
            end
        else
            isChange = true
        end
        if isChange then
            PetListMgr.savePetTeam()
        end
        -- for var=1, PetFormationMgr.TEAM_NUM do
        --     tabIsInit[var] = false
        --     for n=1, #selPet[var] do
        --         table.remove(selPet[var], 1)
        --     end
        --     local petArmy = PokemonInfo.getPetArmy(var)
        --     for n=1, #petArmy do
        --         table.insert(selPet[var], PokemonInfo.getPetInfoByObjID(petArmy[n]))
        --     end
        -- end
        if #selPet[curTab] == 0 then
            for var=1, #selPet[curTab] do
                PetListMgr.setStatusLabel(selPet[curTab][var].objID, false)
            end
        else
            for var=1, #selPet[curTab] do
                PetListMgr.setStatusLabel(selPet[curTab][var].objID, true)
            end
        end
        if #helpPet[curTab] == 0 then
            for var=1, #helpPet[curTab] do
                PetListMgr.setStatusLabel(helpPet[curTab][var].objID, false)
            end
        else
            for var=1, #helpPet[curTab] do
                PetListMgr.setStatusLabel(helpPet[curTab][var].objID, true)
            end
        end
        for var=1, #selPet[curTab] do
            PetListMgr.setStatus(selPet[curTab][var].objID, true, false, false, false)
        end
        for var=1, #helpPet[curTab] do
            PetListMgr.setStatus(helpPet[curTab][var].objID, true, false, false, false)
        end
        PetFormationMgr.changeTab(PetFormationMgr.getCurTab())
        
        local curTeamButton,curTeamPetInfo = PetFormationMgr.getCurTeamInfo()
        for var=1, #selPet[curTab] do
            CSResourceMgr.clickEventBindingByNode(curTeamButton[var], function()
                PetEducationMgr.show(SceneMgr.getRunningScene, curTeamPetInfo[var].objID, 1, function()
                    PetListMgr.refresh(PokemonInfo.getPetInfoByObjID(curTeamPetInfo[var].objID))
                end)
            end)
        end
        if #helpPet[curTab] > 0 then
            for var=1, #helpPet[curTab] do
                CSResourceMgr.clickEventBindingByNode(curTeamButton[var+#selPet[curTab]], function()
                    PetEducationMgr.show(SceneMgr.getRunningScene, curTeamPetInfo[var+#selPet[curTab]].objID, 1, function()
                        PetListMgr.refresh(PokemonInfo.getPetInfoByObjID(curTeamPetInfo[var+#selPet[curTab]].objID))
                    end)
                end)
            end
        end
        for k,v in pairs(myPets) do
            if v.yoke then
                if v.yoke.bindTo then
                    PetListMgr.setStatusYoke(v.objID,true)
                end
            end
        end
    end

    if tabid == 1 then
        PetFreeListMgr.hide()
        if not isFirst then
            PetFormationMgr.moveView(810,0)
            PetListMgr.moveView(0)
        end
        PetListMgr.setBnum()

        CSResourceMgr.getNodeByName(resName, "freeBtn"):setVisible(false)
        -- CSResourceMgr.getNodeByName(resName, "saveBtn"):setVisible(false)
        CSResourceMgr.getNodeByName(resName, "CheckBox"):setVisible(false)
        CSResourceMgr.getNodeByName(resName, "pnumEx"):setVisible(true)
        
        PetListMgr.changePetClickCallback(function(petInfo)
            PetEducationMgr.show(SceneMgr.getRunningScene, petInfo.objID, 1, function()
                PetListMgr.refresh(PokemonInfo.getPetInfoByObjID(petInfo.objID))
            end)
        end)

        local label = CSResourceMgr.getNodeByName(resName,"tips")
        label:setPositionX(32)
        CSResourceMgr.setLabelColorByNode(label,{r=121,g=151,b=179,a=255})
        CSResourceMgr.setLabelStringByNode(label,"train55")
    elseif tabid == 2 then
        PetFreeListMgr.hide()
        PetFormationMgr.moveView(810,0)
        PetListMgr.moveView(0)
        CSResourceMgr.getNodeByName(resName, "freeBtn"):setVisible(false)
        -- CSResourceMgr.getNodeByName(resName, "saveBtn"):setVisible(false)
        CSResourceMgr.getNodeByName(resName, "CheckBox"):setVisible(false)
        CSResourceMgr.getNodeByName(resName, "pnumEx"):setVisible(false)

        PetListMgr.setPnum()

        PetFormationMgr.setFightPower(PokemonInfo.getFightPoint(selPet[curTab]))

        PetListMgr.changePetClickCallback(function(petInfo)
            local resName = "Pet/Formation/FormationView.csb"
            local selPet = PetFormationMgr.getSelPet()
            local helpPet = PetFormationMgr.getHelpPet()
            local tabNode = PetFormationMgr.getTabNode()
            local helpNode = PetFormationMgr.getHelpNode()
            local curTab = PetFormationMgr.getCurTab()
            
            --下阵
            for var=1, #selPet[curTab] do
                if selPet[curTab][var].objID==petInfo.objID then
                    if #selPet[curTab] > 1 then
                        CSResourceMgr.removeCSObjectByTag(tabNode[curTab][var].res, tabNode[curTab][var].tag)
                        table.remove(selPet[curTab], var)
                        table.remove(tabNode[curTab], var)
                        struct[petInfo.objID] = nil
                        curTeamButton[var] = nil
                        curTeamPetInfo[var] = nil
                        for i=var, #tabNode[curTab] do
                            curTeamButton[i] = curTeamButton[i+1]
                        end
                        for i=var, #tabNode[curTab] do
                            curTeamPetInfo[i] = curTeamPetInfo[i+1]
                        end
                        for i=#tabNode[curTab]+1,PetFormationMgr.MAX_PET_NUM do
                            curTeamButton[i] = nil
                        end
                        for i=#tabNode[curTab]+1,PetFormationMgr.MAX_PET_NUM do
                            curTeamPetInfo[i] = nil
                        end
                        PetListMgr.setStatus(petInfo.objID, true, false, false, false)

                        local moveFlag = false
                        for i=var, #selPet[curTab] do
                            transition.moveBy(tabNode[curTab][i], {x=-moveDiffTable[i], time=0.2})
                            tabNode[curTab][i]:setTouchEnabled(false)
                            moveFlag = true
                        end
                        local function setPlusTag()
                            CSResourceMgr.setSpriteTexture(resName, "teamdb"..#tabNode[curTab]+1, "empty.png")
                            for i=(#tabNode[curTab]+1),PetFormationMgr.MAX_PET_NUM do
                                CSResourceMgr.setSpriteTexture(resName, "teamdb"..i, imageRes)
                            end
                        end
                        if moveFlag then
                            CSResourceMgr.getCsbObj(resName):performWithDelay(function()
                                setPlusTag()
                                PetFormationMgr.setFightPower(PokemonInfo.getFightPoint(selPet[curTab]))
                                for i=var, #selPet[curTab] do
                                    tabNode[curTab][i]:setTouchEnabled(true)
                                end
                            end, 0.2)
                        else
                            setPlusTag()
                            PetFormationMgr.setFightPower(PokemonInfo.getFightPoint(selPet[curTab]))
                        end
                    else
                        DialogBoxMgr.showSmallDialogBox(nil, 1, "train53")
                        curTeamButton[1]:setPosition(curTeamButton[1]:getContentSize().width/1.68, curTeamButton[1]:getContentSize().height/1.32)
                    end
                    return
                end
            end
            for var=1, #helpPet[curTab] do
                if helpPet[curTab][var].objID==petInfo.objID then
                    CSResourceMgr.removeCSObjectByTag(helpNode[curTab][var].res, helpNode[curTab][var].tag)
                    table.remove(helpPet[curTab], var)
                    table.remove(helpNode[curTab], var)
                    struct[petInfo.objID] = nil
                    curTeamButton[var+PetFormationMgr.MAX_PET_NUM] = nil
                    curTeamPetInfo[var+PetFormationMgr.MAX_PET_NUM] = nil
                    for i=var, #helpNode[curTab] do
                        curTeamButton[i+PetFormationMgr.MAX_PET_NUM] = curTeamButton[i+PetFormationMgr.MAX_PET_NUM+1]
                    end
                    for i=var, #helpNode[curTab] do
                        curTeamPetInfo[i+PetFormationMgr.MAX_PET_NUM] = curTeamPetInfo[i+PetFormationMgr.MAX_PET_NUM+1]
                    end
                    for i=#helpNode[curTab]+1,PetFormationMgr.MAX_PET_NUM*2 do
                        curTeamButton[i+PetFormationMgr.MAX_PET_NUM] = nil
                    end
                    for i=#helpNode[curTab]+1,PetFormationMgr.MAX_PET_NUM*2 do
                        curTeamPetInfo[i+PetFormationMgr.MAX_PET_NUM] = nil
                    end
                    PetListMgr.setStatus(petInfo.objID, true, false, false, false)

                    local moveFlag = false
                    for i=var, #helpPet[curTab] do
                        transition.moveBy(helpNode[curTab][i], {x=-moveDiffTable[i], time=0.2})
                        helpNode[curTab][i]:setTouchEnabled(false)
                        moveFlag = true
                    end
                    local function setPlusTag()
                        CSResourceMgr.setSpriteTexture(resName, "teamdb"..#helpNode[curTab]+PetFormationMgr.MAX_PET_NUM+1, "empty.png")
                        for i=(#helpNode[curTab]+1),PetFormationMgr.MAX_PET_NUM do
                            CSResourceMgr.setSpriteTexture(resName, "teamdb"..i+PetFormationMgr.MAX_PET_NUM, imageRes)
                        end
                    end
                    if moveFlag then
                        CSResourceMgr.getCsbObj(resName):performWithDelay(function()
                            setPlusTag()
                            for i=var, #helpPet[curTab] do
                                helpNode[curTab][i]:setTouchEnabled(true)
                            end
                        end, 0.2)
                    else
                        setPlusTag()
                    end
                    return
                end
            end
            
            local function addBattlePet()
                if #tabNode[curTab]<PetFormationMgr.SEL_PET_NUM or #helpNode[curTab]<PetFormationMgr.HELP_PET_NUM then
                    local tmpNode = helpNode
                    local addNum = PetFormationMgr.MAX_PET_NUM
                    if #tabNode[curTab]<PetFormationMgr.SEL_PET_NUM then
                        tmpNode = tabNode
                        addNum = 0
                    end
                    if #tabNode[curTab]<PetFormationMgr.SEL_PET_NUM-1 then
                        for i=(#tabNode[curTab]+1),PetFormationMgr.MAX_PET_NUM do
                            CSResourceMgr.setSpriteTexture(resName, "teamdb"..i, imageRes)
                        end
                    end
                    if #helpNode[curTab]<PetFormationMgr.HELP_PET_NUM-1 then
                        for i=(#helpNode[curTab]+1),PetFormationMgr.MAX_PET_NUM do
                            CSResourceMgr.setSpriteTexture(resName, "teamdb"..i+PetFormationMgr.MAX_PET_NUM, imageRes)
                        end
                    end
                    CSResourceMgr.setSpriteTexture(resName, "teamdb"..#tmpNode[curTab]+1+addNum, "empty.png")
                    local pNode = PetListMgr.createPetNode(petInfo, curTab)
                    pNode.node:addTo(CSResourceMgr.getNodeByName(resName, "teamdb"..#tmpNode[curTab]+1+addNum))
                    pNode.node:setPosition(0, 0)
                    pNode.node:setAnchorPoint(0, 0)
                    tmpNode[curTab][#tmpNode[curTab]+1] = pNode.node
                    if #selPet[curTab]<PetFormationMgr.SEL_PET_NUM then
                        selPet[curTab][#selPet[curTab]+1] = petInfo
                    else
                        helpPet[curTab][#helpPet[curTab]+1] = petInfo
                    end
                    PetListMgr.setStatus(petInfo.objID, true, true, false, false)
                    PetFormationMgr.dragEventBinding(pNode.button, petInfo)
                    curTeamButton[#tmpNode[curTab]+addNum] = pNode.button
                    curTeamPetInfo[#tmpNode[curTab]+addNum] = petInfo
                    local effAni = AnimationMgr.createAni(tmpNode[curTab][#tmpNode[curTab]], "Spine/effects/skeleton.png", 
                        tmpNode[curTab][#tmpNode[curTab]]:getContentSize().width/2.5, tmpNode[curTab][#tmpNode[curTab]]:getContentSize().height/2.5)
                    effAni:setLocalZOrder(-1)
                    AnimationMgr.playAniWithCallback(effAni.res, "animation", nil, effAni.tag, true)
                    PetFormationMgr.setFightPower(PokemonInfo.getFightPoint(selPet[curTab]))
                else
                    StandardTipsMgr.show(1, "petmenu15")
                end
            end
            --上阵
            if PetEducationMgr.isPetYoked(petInfo) then
                StandardTipsMgr.show(1, "train128")
            else
                local isRepeat = false
                for k,v in pairs(selPet[curTab]) do
                    if v.pokeID == petInfo.pokeID then
                        isRepeat = true
                    end
                end
                for k,v in pairs(helpPet[curTab]) do
                    if v.pokeID == petInfo.pokeID then
                        isRepeat = true
                    end
                end
                if isRepeat then
                    StandardTipsMgr.show(1, "tips59")
                else
                    addBattlePet()
                end
            end
        end)

        local label = CSResourceMgr.getNodeByName(resName,"tips")
        label:setPositionX(32)
        CSResourceMgr.setLabelColorByNode(label,{r=121,g=151,b=179,a=255})
        CSResourceMgr.setLabelStringByNode(label,"train56")
    else
        CSResourceMgr.getNodeByName(resName, "CheckBox"):setSelected(false)
        PetFormationMgr.moveView(1050,200)
        PetListMgr.moveView(190)
        
        PetFreeListMgr.show(SceneMgr.getRunningScene)

        -- CSResourceMgr.getNodeByName(resName, "saveBtn"):setVisible(false)
        CSResourceMgr.getNodeByName(resName, "freeBtn"):setVisible(true)
        CSResourceMgr.getNodeByName(resName, "CheckBox"):setVisible(true)
        CSResourceMgr.getNodeByName(resName, "pnumEx"):setVisible(false)

        selPetVec = {}
        CSResourceMgr.setLabelString(resName, "pnum", "0/20", "")
        
        PetListMgr.changePetClickCallback(function(petInfo)
            local petVec = PokemonInfo.getPetArmy(PetFormationMgr.getCurTab())
            local petHelpArmy = PokemonInfo.getPetHelpArmy()
            for k,v in pairs(petHelpArmy) do
                table.insert(petVec,v)
            end
            for k,v in pairs(petVec) do
                if v == petInfo.objID then
                    StandardTipsMgr.show(1, "train57")
                    return
                end
            end
            if petInfo.objID == 1 then
                StandardTipsMgr.show(1, "train97")
                return
            end
            
            if PetEquipmentMgr.isPetEquiped(petInfo) then
                StandardTipsMgr.show(1, "PetEquip58")
            	return
            end

            local isSel = false
            for var=1, #selPetVec do
                if selPetVec[var] == petInfo.objID then
                    table.remove(selPetVec, var)
                    isSel = true
                    break
                end
            end

            -- local rp = PokemonInfo.getPokemonInfoByID(petInfo.pokeID).rarePoint
            local count = PokemonInfo.getPetFreedomAwardInfoByID(petInfo.pokeID)
            if isSel then
                PetListMgr.setStatus(petInfo.objID, true, false, false, false)
                PetFreeListMgr.setAwardsCount(nil, {petInfo.pokeID})
            elseif #selPetVec < 20 then
                if PetEducationMgr.isPetYoked(petInfo) or PetEducationMgr.isPetHasYoke(petInfo) then
                    StandardTipsMgr.show(1, "train128")
                else
                    table.insert(selPetVec, petInfo.objID)
                    PetListMgr.setStatus(petInfo.objID, true, false, true, false)
                    PetFreeListMgr.setAwardsCount({petInfo.pokeID})
                end
            else
                StandardTipsMgr.show(1, "train129")
            end
            CSResourceMgr.setLabelString(resName, "pnum", #selPetVec.."/20","")
        end)

        local label = CSResourceMgr.getNodeByName(resName,"tips")
        label:setPositionX(80)
        CSResourceMgr.setLabelColorByNode(label,{r=121,g=151,b=179,a=255})
        CSResourceMgr.setLabelStringByNode(label,"train58")
    end
end

function PetListMgr.moveView(offset)
    transition.moveTo(CSResourceMgr.getNodeByName(resName,"db"), {y=offset, time=0.2})
end

function PetListMgr.hide()
    UnblockLoader.cancel("PetListMgr-reset")
    UnblockLoader.cancel("PetListMgr")
    petIndexVec = {}
    CSResourceMgr.removeList(resName, "list")
    for var=1, #panelTable do
        panelTable[var]:removeAllChildren(true)
    end
    panelTable = {}
    petSpriteTable = {}
    struct = {}

    CSResourceMgr.removeCSObjectByTag(resName)
  --  PetListMgr.petCardTemplate = nil
    PetEducationMgr.hideAllRedPoint()
    tempTab = 1
    if hideCallback then
        hideCallback()
        hideCallback = nil
    end
    StatusBarMgr.refreshFightPower(PetFormationMgr.getCurTab())
    ObjectPool.reset(keystr)
    HighPerformList.resetAllSchedule()
end

function PetListMgr.getPetListNode(objID)
    return petSpriteTable[objID]
end

function PetListMgr.selPetVec()
    return selPetVec
end

function PetListMgr.getstructNode(objID)
    if struct[objID] then
        return struct[objID]
    end
    return nil
end

function PetListMgr.refresh(petInfo)
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    
    local petObjIDVec = {}
    local selPet = PetFormationMgr.getSelPet()
    local curTab = PetFormationMgr.getCurTab()
    for var=1, #selPet[curTab] do
        table.insert(petObjIDVec,selPet[curTab][var].objID)
    end
    PetFormationMgr.setFightPower(PokemonInfo.getFightPointByObjID(petObjIDVec))

    if PetListMgr.getPetListNode(petInfo.objID) then
        local node1 = PetListMgr.getPetListNode(petInfo.objID).node
        local level1 = PetListMgr.getPetListNode(petInfo.objID).level
        CSResourceMgr.setLabelStringByNode(level1,"Lv."..petInfo.level)
    end
   
    --[[
    local star1 = CSResourceMgr.seekNodeByName(node1, "star1")
    local unitdiff = star1:getContentSize().width/2
    local k = 1.5
    local starcnt = tonumber(petInfo.star)
    if starcnt >= 3 and starcnt <5 then k = 1.8 end
    local alldiff = 0
    local movediff = 0
    if starcnt~=5 then
        alldiff = star1:getContentSize().width*k
        movediff= alldiff-(starcnt-1)*unitdiff
    end
    for starID = 1,5 do
        local starSp = CSResourceMgr.seekNodeByName(node1, "star"..starID)
        if starID > starcnt then
            starSp:setVisible(false)
        else
            starSp:setVisible(true)
            local originx = starPosVec[starID]
            starSp:setPositionX(originx+movediff)
        end
    end
    ]]
    if PetEducationMgr.getRedPointStateByPetInfo(petInfo) == true then
        PetEducationMgr.createRedPoint(node1, "plt_red_point"..petInfo.objID, 0.8, 0.7, 0.7,6)
    else
        PetEducationMgr.hideRedPoint("plt_red_point"..petInfo.objID)
    end
    
    if PetListMgr.getstructNode(petInfo.objID) then
        local node2 = PetListMgr.getstructNode(petInfo.objID).node
        if CSResourceMgr.seekNodeByName(node2,"level") then
            local level2 = CSResourceMgr.seekNodeByName(node2,"level")
            CSResourceMgr.setLabelStringByNode(level2,"Lv."..petInfo.level)
        end
        local sprite = CSResourceMgr.seekNodeByName(node2, "icon")
        CSResourceMgr.setSpriteTextureByNode(sprite, PokemonInfo.getPokemonIconByID(petInfo.pokeID))
        local stage = CSResourceMgr.seekNodeByName(node2, "diban")
        local attriinfo = tonumber(PokemonInfo.getPokemonInfoByID(petInfo.pokeID).elementAtt1)
        local rarePoint = PokemonInfo.getPokemonInfoByID(petInfo.pokeID).rarePoint
        if petInfo.Stage then
            local pvec = PokemonInfo.getStagePics(petInfo.Stage,attriinfo,rarePoint)    
            CSResourceMgr.setButtonTextureByNode(stage,pvec.p1,pvec.p1,pvec.p1)
        end
        local rarei  = CSResourceMgr.seekNodeByName(node2,"rarei")
        CSResourceMgr.setSpriteTextureByNode(rarei, PetEducationMgr.getRareIcon(rarePoint))

        local starCount = tonumber(petInfo.star)
        for var=1, starCount do
            local starSp = CSResourceMgr.seekNodeByName(node2, "star"..var)
            starSp:setVisible(true)
            starSp:setLocalZOrder(1)
            if starCount == 1 then
                starSp:setPositionX(40)
            elseif starCount == 2 then
                if var == 1 then
                    starSp:setPositionX(30)
                else
                    starSp:setPositionX(50)
                end
            elseif starCount == 3 then
                if var == 1 then
                    starSp:setPositionX(20)
                elseif var == 2 then
                    starSp:setPositionX(40)
                else
                    starSp:setPositionX(60)
                end
            elseif starCount == 4 then
                if var == 1 then
                    starSp:setPositionX(16)
                elseif var == 2 then
                    starSp:setPositionX(32)
                elseif var == 3 then
                    starSp:setPositionX(48)
                else
                    starSp:setPositionX(64)
                end
            else
                if var == 1 then
                    starSp:setPositionX(8)
                elseif var == 2 then
                    starSp:setPositionX(24)
                elseif var == 3 then
                    starSp:setPositionX(40)
                elseif var == 4 then
                    starSp:setPositionX(56)
                else
                    starSp:setPositionX(72)
                end
            end
        end
    end
    
   local isRefresh = false --是否重置的标志
 
   if petSpriteTable[petInfo.objID] then
   
       if updateFlags["rare"] then
           isRefresh = true
           --local rarePoint = PokemonInfo.getPokemonInfoByID(petInfo.pokeID).rarePoint
           --CSResourceMgr.setSpriteTextureByNode(petSpriteTable[petInfo.objID].rare, PetEducationMgr.getRareIcon(rarePoint))
       end
       if updateFlags["icon"] then
          isRefresh = true
          -- CSResourceMgr.setSpriteTextureByNode(petSpriteTable[petInfo.objID].icon, PokemonInfo.getPokemonIconByID(petInfo.pokeID))
       end
       -- stage
       if updateFlags["stage"] then
           isRefresh = true
           --local pvec = getStagePics(petInfo.Stage)
           --local attridb = CSResourceMgr.seekNodeByName(petSpriteTable[petInfo.objID].node, "attridiban")
           --CSResourceMgr.setSpriteTextureByNode(petSpriteTable[petInfo.objID].stage, pvec.p1)
           --CSResourceMgr.setSpriteTextureByNode(attridb, pvec.p2)
       end
       -- level
       if updateFlags["level"] then
           isRefresh = true
           --CSResourceMgr.setLabelStringByNode(petSpriteTable[petInfo.objID].level,"Lv."..petInfo.level)
       end
       -- attr
       if updateFlags["attr"] then
           isRefresh = true
       end
       
       -- star
       if updateFlags["star"] then
           isRefresh = true
       end
       -- name
       if updateFlags["name"] then
           isRefresh = true
        --[[
           local label = petSpriteTable[petInfo.objID].name
           local nameStyle = PetEducationMgr.getNameStyleByStage(petInfo.Stage)
           local p_name = LuaSqlite.getLanguageByKey( PokemonInfo.getPokemonInfoByID(petInfo.pokeID).name )
           CSResourceMgr.setLabelColorByNode(label,nameStyle.color)
           CSResourceMgr.setLabelStringByNode(label,p_name..nameStyle.suffix,nameStyle.outline)
           ]]
       end
       if updateFlags["changeName"] then
            local changeName = PetEducationMgr.getPetName(petInfo)
            if PetListMgr.getPetListNode(petInfo.objID) then
                local name = PetListMgr.getPetListNode(petInfo.objID).name
                CSResourceMgr.setLabelStringByNode(name,changeName)
            end
       end

       if updateFlags["yoke"] then
            isRefresh = true
            PetListMgr.setBnum()
       end
       
       if isRefresh == true then
            local myPets = PokemonInfo.getAllPets(nil, PetListMgr.isShowYokePets())
            local petVec = PetListMgr.sortPetList(myPets)
            local selPet = PetFormationMgr.getSelPet()
            local helpPet = PetFormationMgr.getHelpPet()
            local curTab = PetFormationMgr.getCurTab()
            UnblockLoader.cancel("PetListMgr-reset")
            PetListMgr.reset(petVec, nil, function(petInfo)
                for var=1, #selPet[curTab] do
                    if petInfo.objID==selPet[curTab][var].objID then
                        PetListMgr.setStatusLabel(selPet[curTab][var].objID, true)
                        break
                    end
                end
                for var=1, #helpPet[curTab] do
                    if petInfo.objID==helpPet[curTab][var].objID then
                        PetListMgr.setStatusLabel(helpPet[curTab][var].objID, true)
                        break
                    end
                end
                if PetEducationMgr.isPetYoked(petInfo) then
                    PetListMgr.setStatusYoke(petInfo.objID, true)
                end
                PetFormationMgr.sortAll()
            end)
       end
     
   end
    updateFlags = {}
end

function PetListMgr.setStatus(objID, enable, sel, x, dark )
    if petSpriteTable[objID] then
        CSResourceMgr.setButtonEnabledByNode(petSpriteTable[objID].node, enable)
        petSpriteTable[objID].sel:setVisible(sel)
        petSpriteTable[objID].x:setVisible(x)
        --CSResourceMgr.seekNodeByName(petSpriteTable[objID].node, "sel"):setVisible(sel)
        --CSResourceMgr.seekNodeByName(petSpriteTable[objID].node, "x"):setVisible(x)
        
        -- if dark then
        --     petSpriteTable[objID].icon:setColor({r=100,g=100,b=100})
        -- else
        --     petSpriteTable[objID].icon:setColor({r=255,g=255,b=255})
        -- end
    end
end

function PetListMgr.setStatusLabel(objID,enable)
    if petSpriteTable[objID] then
        local x,y = petSpriteTable[objID].statusLabel:getPosition()
        petSpriteTable[objID].statusLabel:setVisible(enable)
        CSResourceMgr.setLabelStringByNode(petSpriteTable[objID].statusLabel, "train68",{r=0,g=0,b=0,a=255})
  
        CSResourceMgr.setLabelColorByNode(petSpriteTable[objID].statusLabel,{r=2,g=210,b=255,a=255})
    end
end

function PetListMgr.setStatusYoke(objID,enable)
    if petSpriteTable[objID] then
        local x,y = petSpriteTable[objID].statusLabel:getPosition()
        petSpriteTable[objID].statusLabel:setVisible(enable)
        CSResourceMgr.setLabelStringByNode(petSpriteTable[objID].statusLabel, "train173",{r=0,g=0,b=0,a=255})
  
        CSResourceMgr.setLabelColorByNode(petSpriteTable[objID].statusLabel,{r=255,g=246,b=0,a=255})
    end
end



function PetListMgr.reset(myPets, btnCallback, resetCallback)
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    if btnCallback then
        btnClickCallback = btnCallback
    end
    local list = CSResourceMgr.getNodeByName(resName, "list")
    list:removeAllItems()
    panelTable = {}
    petSpriteTable = {}
    ObjectPool.reset(keystr)
    
    local allnum = #myPets
    local index = 0
    local listCellArray = {}
    while allnum > 0 do

        local testPokeArray = {}
        for i = 1,4 do

            index = index+1
            allnum = allnum-1
            table.insert(testPokeArray,myPets[index])

            if allnum == 0 then table.insert(listCellArray,testPokeArray) break end
            if i == 4 then 
                table.insert(listCellArray,testPokeArray) 
            end
        end

    end
    --begin highperforme list init
     local spawncount = 5
     local countperline = 4
    local funcTable = {}
    for i = 1, #listCellArray do
        if i > spawncount then break end
        local pokeArray = listCellArray[i]
        local listcell = nil

        table.insert(funcTable, function()
            --local time1 = os.clock()
            listcell = CSResourceMgr.getNodeByName(petNodeRes, "panel"):clone()
            
			
            --local returnObjectArray = ObjectPool.getObjectFromPool(keystr,1)
            --listcell = returnObjectArray[1]
            list:pushBackCustomItem(listcell)
            listcell:setVisible(false)
           -- local time2 = os.clock()
            
           -- print("create list cell time:"..time2-time1)
        end)
 
        
        table.insert(funcTable, function()
            listcell.params = {}
            for i = 1,4 do
                local node = CSResourceMgr.seekNodeByName(listcell,"btn"..i)   
                node:setVisible(false)
            end
            for j = 1, #pokeArray do
                table.insert(petIndexVec,pokeArray[j].objID)
                --local time1 = os.clock()
                local parent = CSResourceMgr.seekNodeByName(listcell, "btn"..j)
                parent:setVisible(true)
                
                local returnObjectArray = ObjectPool.getObjectFromPool(keystr,1)
                local object = returnObjectArray[1]
                PetListMgr.createPetCardWithName2(parent, pokeArray[j], resetCallback,object)

                local armyList = PokemonInfo.getPetArmy(PetFormationMgr.getCurTab())
                local helpArmyList = PokemonInfo.getPetHelpArmy()
                local petLength = PetEducationMgr.getTableLength(armyList) + PetEducationMgr.getTableLength(helpArmyList)
                listcell.params[j] = {object,pokeArray[j].objID}
                --print(listcell.params[j][2])
                if j < petLength then
                    if PetEducationMgr.getRedPointStateByPetInfo(pokeArray[j]) == true then
                        PetEducationMgr.createRedPoint(object, "plt_red_point"..pokeArray[j].objID, 0.8, 0.7, 0.7,6)
                    else
                        PetEducationMgr.hideRedPoint("plt_red_point"..pokeArray[j].objID)
                    end
                end
               -- local time2 = os.clock()
               -- print("create pet  time:"..time2-time1)               
            end
        end)
        table.insert(funcTable, function()
            --listcell:setScaleY(0)
            listcell:setVisible(true)
            --transition.scaleTo(listcell, {scale=1.0, time=0.1})
        end)
    end
    if PetListMgr.haveGuideStarUp == true then
        GameGuideMgr.starUpCallBack()
    end

    local function funcTable2()
       --print("listCellArray count is............................"..#listCellArray)
       if #listCellArray > spawncount then 
            HighPerformList.makeHighPerFormVerticalList(list,spawncount,0,countperline,200,180,myPets,
            
            function(item,currentindex)
                for j = 1,countperline do
                    local parent = CSResourceMgr.seekNodeByName(item, "btn"..j)
                    if myPets[currentindex+j-1] == nil then 
                        parent:setVisible(false)
                    else
                        parent:setVisible(true)
                        local object = item.params[j][1]
                        PetListMgr.createPetCardWithName2(parent, myPets[currentindex+j-1], resetCallback, object)
    
                        local armyList = PokemonInfo.getPetArmy(PetFormationMgr.getCurTab())
                        local helpArmyList = PokemonInfo.getPetHelpArmy()
                        local petLength = PetEducationMgr.getTableLength(armyList) + PetEducationMgr.getTableLength(helpArmyList)
                     
                        PetEducationMgr.hideRedPoint("plt_red_point"..item.params[j][2])
                        petSpriteTable[item.params[j][2]] = nil
                        if tempTab == 3 then
                            for index = 1 ,#selPetVec do 
                                if myPets[currentindex+j-1].objID == selPetVec[index] then 
                                    PetListMgr.setStatus(myPets[currentindex+j-1].objID, true, false, true)
                                    break
                                end
                                PetListMgr.setStatus(myPets[currentindex+j-1].objID, true, false, false)   
                            end
                        elseif tempTab == 2 then
                            local selPet = PetFormationMgr.getSelPet()
                            local helpPet = PetFormationMgr.getHelpPet()
                            local curTab = PetFormationMgr.getCurTab()

                            for index = 1 ,#selPet[curTab] do 
                                 --print("selPet[index].objID & myPets[currentindex+j-1].objID:",selPet[curTab][index].objID,myPets[currentindex+j-1].objID)
                                if myPets[currentindex+j-1].objID == selPet[curTab][index].objID then 
                                    PetListMgr.setStatus(myPets[currentindex+j-1].objID, true, true, false)
                                    PetListMgr.setStatusLabel(myPets[currentindex+j-1].objID, false)
                                    break
                                end
                            end
                            for index = 1 ,#helpPet[curTab] do 
                                if myPets[currentindex+j-1].objID == helpPet[curTab][index].objID then 
                                    PetListMgr.setStatus(myPets[currentindex+j-1].objID, true, true, false)
                                    PetListMgr.setStatusLabel(myPets[currentindex+j-1].objID, false)
                                    break
                                end           
                            end
                        end

                        if j < petLength then
                            if PetEducationMgr.getRedPointStateByPetInfo(myPets[currentindex+j-1]) == true then
                                PetEducationMgr.createRedPoint(object, "plt_red_point"..myPets[currentindex+j-1].objID, 0.8, 0.7, 0.7,6)
                            else
                                PetEducationMgr.hideRedPoint("plt_red_point"..myPets[currentindex+j-1].objID)
                            end
                        end

                        item.params[j][2] = myPets[currentindex+j-1].objID
                    end
                end
            end
            )
       end 
    end

    table.insert(funcTable,funcTable2)

    if useunblockloader then
        UnblockLoader.load(funcTable, "PetListMgr-reset")
    else
        for i = 1,#funcTable do
            funcTable[i]()
        end
    
    end
end

function PetListMgr.changePetClickCallback(callback)
    btnClickCallback = callback
end

function PetListMgr.CheckPetIdxVec(objID)
    for k,v in pairs(petIndexVec) do
        if v == objID then
            return k
        end
    end
    return 0
end

---创建图鉴的节点
function PetListMgr.createHandBookPetNode(info,tag,parent)
    if parent == nil then
        parent = CSResourceMgr.createRes(nil, "Pet/BasicPetList/NCommonPet_3.csb", info.id..tag)
    end
    local rarePoint = info.rarePoint
    local rarei  = CSResourceMgr.seekNodeByName(parent,"rarei")
    rarei:setScale(0.48)
    CSResourceMgr.setSpriteTextureByNode(rarei, PetEducationMgr.getRareIcon(rarePoint))
	local rareidiban = CSResourceMgr.seekNodeByName(parent, "rareidiban")
	
    local sprite = CSResourceMgr.seekNodeByName(parent, "icon")
    CSResourceMgr.setSpriteTextureByNode(sprite, PokemonInfo.getPokemonIconByID(info.id))
    local attri = CSResourceMgr.seekNodeByName(parent, "attri")
    local attriinfo = tonumber(info.elementAtt1)
    local attridiban = CSResourceMgr.seekNodeByName(parent, "attridiban")

    CSResourceMgr.setSpriteTextureByNode(attri, "Pet/AttriIcon/"..attriinfo..".png")
  
    local pvec = PokemonInfo.getStagePics(nil,attriinfo,rarePoint)
    local attridb = CSResourceMgr.seekNodeByName(parent, "attridiban")
    CSResourceMgr.setSpriteTextureByNode(attridb,pvec.p2)
    --CSResourceMgr.setSpriteTextureByNode(parent,pvec.p1)
    CSResourceMgr.setButtonTextureByNode(parent,pvec.p1,pvec.p1,pvec.p1)

    
    local nametextlabel = CSResourceMgr.seekNodeByName(parent,"petName")
    local nameStr       = LuaSqlite.getLanguageByKey(info.name)
    nametextlabel:setString(nameStr)
    CSResourceMgr.setLabelColorByNode(nametextlabel,PokemonInfo.COLOR[info.rarePoint])
    --nametextlabel:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1) 
        
    local petNode = {node=parent, button=parent, icon=sprite,rareicon = rareidiban,attricon = attridiban,rarei = rarei,attri = attri,name = nametextlabel}
    return petNode

end
function PetListMgr.createPetNodeByPokeId(info,tag)
   
    local function printInfo(info)
        for k,v in pairs(info) do
            if type(v) == "table" then
                printInfo(v)
            else
                print("k:"..k.." v:"..v)
            end
        end
    end
    
    --printInfo(info)
    tag = tag or ""
    local parent = CSResourceMgr.createRes(nil, resNameP, info.pokeID..tag)
    if info.star then
        local starCount = tonumber(info.star)
        for var=1, starCount do
            local starSp = CSResourceMgr.seekNodeByName(parent, "star"..var)
            starSp:setVisible(true)
            starSp:setLocalZOrder(1)
            if starCount == 1 then
                starSp:setPositionX(40)
            elseif starCount == 2 then
                if var == 1 then
                    starSp:setPositionX(30)
                else
                    starSp:setPositionX(50)
                end
            elseif starCount == 3 then
                if var == 1 then
                    starSp:setPositionX(20)
                elseif var == 2 then
                    starSp:setPositionX(40)
                else
                    starSp:setPositionX(60)
                end
            elseif starCount == 4 then
                if var == 1 then
                    starSp:setPositionX(22)
                elseif var == 2 then
                    starSp:setPositionX(34)
                elseif var == 3 then
                    starSp:setPositionX(46)
                else
                    starSp:setPositionX(58)
                end
            else
                if var == 1 then
                    starSp:setPositionX(8)
                elseif var == 2 then
                    starSp:setPositionX(24)
                elseif var == 3 then
                    starSp:setPositionX(40)
                elseif var == 4 then
                    starSp:setPositionX(56)
                else
                    starSp:setPositionX(72)
                end
            end
        end
    end
    
    local level = CSResourceMgr.seekNodeByName(parent, "level")
    CSResourceMgr.setLabelStringByNode(level, "Lv."..info.level, {r=0,g=0,b=0,a=255})
    
    local levelbar = CSResourceMgr.seekNodeByName(parent, "levelbar")
    local rarePoint = PokemonInfo.getPokemonInfoByID(info.pokeID).rarePoint
    local rarei  = CSResourceMgr.seekNodeByName(parent,"rarei")
    rarei:setScale(0.48)
    CSResourceMgr.setSpriteTextureByNode(rarei, PetEducationMgr.getRareIcon(rarePoint))

    local sprite = CSResourceMgr.seekNodeByName(parent, "icon")
    CSResourceMgr.setSpriteTextureByNode(sprite, PokemonInfo.getPokemonIconByID(info.pokeID))
    local attri = CSResourceMgr.seekNodeByName(parent, "attri")
    local attriInfo = tonumber(PokemonInfo.getPokemonInfoByID(info.pokeID).elementAtt1)
    CSResourceMgr.setSpriteTextureByNode(attri, "Pet/AttriIcon/"..attriInfo..".png")
    local stage = CSResourceMgr.seekNodeByName(parent, "diban")
    local attridb = CSResourceMgr.seekNodeByName(parent, "attridiban")


    if info.Stage then
        local pvec = PokemonInfo.getStagePics(info.Stage,attriInfo,rarePoint)    
        CSResourceMgr.setButtonTextureByNode(stage,pvec.p1,pvec.p1,pvec.p1)
        CSResourceMgr.setSpriteTextureByNode(attridb, pvec.p2)
        if pvec.p3 then
            local satgeFrame = display.newSprite(pvec.p3)
            satgeFrame:addTo(stage)
            satgeFrame:setPosition(stage:getContentSize().width/2, stage:getContentSize().height/2)
        end
    end
    local petNode = {node=parent, button=stage, levelbar=levelbar ,level=level, icon=sprite, stage=stage, rarei=rarei}
    return petNode

end


--创建名字卡片,这段代码是抄陈伟俊的

function PetListMgr.createPetCardWithName2(btn,petInfo,resetCallBack,object)
  
  
    --local petCard = BattleFuncMgr.startCreatePetCard(petInfo,3)
    --BattleFuncMgr.endCreatePetCard()
   
    local petCard = BattleFuncMgr.createPetCardWithObjectPool(object,petInfo,3,true)
    local size = btn:getContentSize()

    btn:addChild(petCard.button)
    petCard.button:setPosition(size.width/2,size.height/2+3)
    petCard.button:setScale(1.35)
    local selIcon       = CSResourceMgr.seekNodeByName(btn,"sel")
    local xIcon         = CSResourceMgr.seekNodeByName(btn,"x")
    local statusLabel   = CSResourceMgr.seekNodeByName(btn,"statusLabel")
    statusLabel:setVisible(false)
    selIcon:setVisible(false)
    xIcon:setVisible(false)
    statusLabel:setLocalZOrder(3)
    selIcon:setLocalZOrder(5)
    xIcon:setLocalZOrder(5)
    
    -- init info
    
    petSpriteTable[petInfo.objID] = {star =petCard.star ,node=petCard.button, statusLabel = statusLabel,rare = petCard.rare, stage=petInfo.Stage, level=petCard.level, icon=petCard.head, attri=petCard.attri, name=petCard.str,sel = selIcon,x=xIcon,headBK = petCard.diban,attriBK = petCard.attridiban}
    --print("set petSpriteTable petinfo " ..tostring(petInfo.objID))
    CSResourceMgr.clickEventBindingByNode(petCard.button, function()
        if btnClickCallback then
            btnClickCallback(petInfo)
        end
    end,3)

    petCard.button:setSwallowTouches(true)

    if resetCallBack then
        resetCallBack(petInfo)
    end


    if PetEducationMgr.getRedPointStateByPetInfo(petInfo) == true then
        PetEducationMgr.createRedPoint(petCard.button, "plt_red_point"..petInfo.objID, 0.8, 0.7, 0.7,6)
    else
        PetEducationMgr.hideRedPoint("plt_red_point"..petInfo.objID)
    end
    
    local equiped = petCard.button:getChildByName("equiped")
    equiped:setVisible(PetEquipmentMgr.isPetEquiped(petInfo))
    
    --[[
    local rareRes = "Pet/BasicPetList_2/Stage/"..rarePoint..".png"
    CSResourceMgr.setSpriteTextureByNode(petCard.headBK, rareRes)  
  
   -- local t1 = os.clock()
    local attriInfo = tonumber(PokemonInfo.getPokemonInfoByID(petInfo.pokeID).elementAtt1)
    local attriRes = "Pet/AttriIcon/"..attriInfo..".png"
    local attrCirRes = "Pet/AttriIcon/small_"..attriInfo..".png"
   -- local t2 = os.clock()
    
   -- print("attriInfo take time:"..t2-t1)

    --local t1 = os.clock()
    --设置星星位置的偏移量 add by lyx
    local unitdiff = petCard.star[1]:getContentSize().width/2
    local k = 1.5 --偏移系数
    local starcnt = tonumber(petInfo.star)
    if starcnt >= 3 and starcnt <5 then k = 1.8 end
    local alldiff = 0
    local movediff = 0
    if starcnt~=5 then
        alldiff = petCard.star[1]:getContentSize().width*k
        movediff= alldiff-(starcnt-1)*unitdiff
    end
    --设置星星位置偏移量结束
    
    for starID = 1,5 do
        if starID > starcnt then
            petCard.star[starID]:hide()
        else
            petCard.star[starID]:show()
            
            local originx = starPosVec[starID]--petCard.star[starID]:getPositionX();
            petCard.star[starID]:setPositionX(originx+movediff)
        end
    end
   -- local t2 = os.clock()
   -- print("star moove take time:"..t2-t1)
    
   -- local t1 = os.clock()   
  
    CSResourceMgr.setSpriteTextureByNode(petCard.rare, PetEducationMgr.getRareIcon(rarePoint))
    CSResourceMgr.setSpriteTextureByNode(petCard.head, PokemonInfo.getPokemonIconByID(petInfo.pokeID))
    CSResourceMgr.setSpriteTextureByNode(petCard.attriBK, attrCirRes)
    CSResourceMgr.setSpriteTextureByNode(petCard.attri, attriRes)
   
    
   -- local t2 = os.clock()
   -- print("setSpriteTextureByNode take time:"..t2-t1)
]]
    return petCard	
end

function PetListMgr.createPetNode(info, tag , isFb)
    local petInfo = PokemonInfo.getPetInfoByObjID(info.objID)
    return PetListMgr.createPetNodeWithInfo(petInfo, tag , isFb)
end

--{objID="test", pokeID=1}
function PetListMgr.createPetNodeWithInfo(petInfo, tag , isFb)
    tag = tag or ""
    
    local parent = CSResourceMgr.createRes(nil, resNameP, petInfo.objID..tag)
    if petInfo.star then
        local starCount = tonumber(petInfo.star)
        for var=1, starCount do
            local starSp = CSResourceMgr.seekNodeByName(parent, "star"..var)
            starSp:setVisible(true)
            starSp:setLocalZOrder(1)
            if starCount == 1 then
                starSp:setPositionX(40)
            elseif starCount == 2 then
                if var == 1 then
                    starSp:setPositionX(30)
                else
                    starSp:setPositionX(50)
                end
            elseif starCount == 3 then
                if var == 1 then
                    starSp:setPositionX(20)
                elseif var == 2 then
                    starSp:setPositionX(40)
                else
                    starSp:setPositionX(60)
                end
            elseif starCount == 4 then
                if var == 1 then
                    starSp:setPositionX(16)
                elseif var == 2 then
                    starSp:setPositionX(32)
                elseif var == 3 then
                    starSp:setPositionX(48)
                else
                    starSp:setPositionX(64)
                end
            else
                if var == 1 then
                    starSp:setPositionX(8)
                elseif var == 2 then
                    starSp:setPositionX(24)
                elseif var == 3 then
                    starSp:setPositionX(40)
                elseif var == 4 then
                    starSp:setPositionX(56)
                else
                    starSp:setPositionX(72)
                end
            end
        end
    end
    
    local rarePoint = PokemonInfo.getPokemonInfoByID(petInfo.pokeID).rarePoint
    local rarei  = CSResourceMgr.seekNodeByName(parent,"rarei")
    rarei:setScale(0.48)    
    CSResourceMgr.setSpriteTextureByNode(rarei, PetEducationMgr.getRareIcon(rarePoint)) 
    local level = CSResourceMgr.seekNodeByName(parent, "level")
    local levelbar = CSResourceMgr.seekNodeByName(parent, "levelbar")
    if petInfo.level then        
        CSResourceMgr.setLabelStringByNode(level, "Lv."..petInfo.level,{r=0,g=0,b=0,a=255},-1,45)        
        local preExp = ExperienceInfo.getExperienceInfoByID(petInfo.level-1).petExpVec[rarePoint]
        local levelpercent = (petInfo.exp-preExp)*100/
            (ExperienceInfo.getExperienceInfoByID(petInfo.level).petExpVec[rarePoint]-preExp)
        levelbar:setPercent(levelpercent)
    else
        level:hide()
        levelbar:hide()
    end
    
    local sprite = CSResourceMgr.seekNodeByName(parent, "icon")
    sprite:setScale(0.68)
    CSResourceMgr.setSpriteTextureByNode(sprite, PokemonInfo.getPokemonIconByID(petInfo.pokeID))
    local attri = CSResourceMgr.seekNodeByName(parent, "attri")
    attri:setScale(0.5)
    local attriinfo = tonumber(PokemonInfo.getPokemonInfoByID(petInfo.pokeID).elementAtt1)
    CSResourceMgr.setSpriteTextureByNode(attri, "UI/CommonFiles/"..attriinfo..".png")
    local button = CSResourceMgr.seekNodeByName(parent, "diban")
    local pvec = PokemonInfo.getStagePics(petInfo.Stage, attriinfo, rarePoint)    
    CSResourceMgr.setButtonTextureByNode(button, pvec.p1, pvec.p1, pvec.p1)
    if not isFb then
        struct[petInfo.objID] = {node=parent, button=button, levelbar=levelbar ,level=level, node=parent, icon=sprite}
    end

    return (isFb and {node=parent, button=button, levelbar=levelbar ,level=level, node=parent, icon=sprite} or struct[petInfo.objID])
end

function PetListMgr.createPetNodeByPetInfo(petInfo, tag ,isFb)
    tag = tag or ""
    
    local parent = CSResourceMgr.createRes(nil, resNameP, petInfo.objID..tag)
    if petInfo.star then
        local starCount = tonumber(petInfo.star)
        for var=1, starCount do
            local starSp = CSResourceMgr.seekNodeByName(parent, "star"..var)
            starSp:setVisible(true)
            starSp:setLocalZOrder(1)
            if starCount == 1 then
                starSp:setPositionX(40)
            elseif starCount == 2 then
                if var == 1 then
                    starSp:setPositionX(30)
                else
                    starSp:setPositionX(50)
                end
            elseif starCount == 3 then
                if var == 1 then
                    starSp:setPositionX(20)
                elseif var == 2 then
                    starSp:setPositionX(40)
                else
                    starSp:setPositionX(60)
                end
            elseif starCount == 4 then
                if var == 1 then
                    starSp:setPositionX(10)
                elseif var == 2 then
                    starSp:setPositionX(30)
                elseif var == 3 then
                    starSp:setPositionX(50)
                else
                    starSp:setPositionX(70)
                end
            else
                if var == 1 then
                    starSp:setPositionX(8)
                elseif var == 2 then
                    starSp:setPositionX(24)
                elseif var == 3 then
                    starSp:setPositionX(40)
                elseif var == 4 then
                    starSp:setPositionX(56)
                else
                    starSp:setPositionX(72)
                end
            end
        end
    end
    local level = CSResourceMgr.seekNodeByName(parent, "level")
    CSResourceMgr.setLabelStringByNode(level, "Lv."..petInfo.level,{r=0,g=0,b=0,a=255},-1,45)
    local levelbar = CSResourceMgr.seekNodeByName(parent, "levelbar")
    local rarePoint = PokemonInfo.getPokemonInfoByID(petInfo.pokeID).rarePoint
    local rarei  = CSResourceMgr.seekNodeByName(parent,"rarei")
    rarei:setScale(0.48)
    
    CSResourceMgr.setSpriteTextureByNode(rarei, PetEducationMgr.getRareIcon(rarePoint))
 
    local preExp = ExperienceInfo.getExperienceInfoByID(petInfo.level-1).petExpVec[rarePoint]
    local levelpercent = (petInfo.exp-preExp)*100/
        (ExperienceInfo.getExperienceInfoByID(petInfo.level).petExpVec[rarePoint]-preExp)
    levelbar:setPercent(levelpercent)
    local sprite = CSResourceMgr.seekNodeByName(parent, "icon")
    sprite:setScale(0.68)
    CSResourceMgr.setSpriteTextureByNode(sprite, PokemonInfo.getPokemonIconByID(petInfo.pokeID))
    local attri = CSResourceMgr.seekNodeByName(parent, "attri")
    attri:setScale(0.5)
    local attriinfo = tonumber(PokemonInfo.getPokemonInfoByID(petInfo.pokeID).elementAtt1)
    CSResourceMgr.setSpriteTextureByNode(attri, "UI/CommonFiles/"..attriinfo..".png")
    local stage = CSResourceMgr.seekNodeByName(parent, "diban")
    local attridb = CSResourceMgr.seekNodeByName(parent, "attridiban")
    
    if petInfo.Stage then
        local pvec = PokemonInfo.getStagePics(petInfo.Stage,attriinfo,rarePoint)    
        CSResourceMgr.setButtonTextureByNode(stage,pvec.p1,pvec.p1,pvec.p1)
        CSResourceMgr.setSpriteTextureByNode(attridb, pvec.p2)
        if pvec.p3 then
            local satgeFrame = display.newSprite(pvec.p3)
            satgeFrame:addTo(stage)
            satgeFrame:setPosition(stage:getContentSize().width/2, stage:getContentSize().height/2)
        end
    end
    local button = CSResourceMgr.seekNodeByName(parent, "diban")
    if not isFb then
        struct[petInfo.objID] = {node=parent, button=button, levelbar=levelbar ,level=level, node=parent, icon=sprite}
    end

    return (isFb and {node=parent, button=button, levelbar=levelbar ,level=level, node=parent, icon=sprite} or struct[petInfo.objID])
end

function PetListMgr.getTempTab()
    return tempTab
end

function PetListMgr.isPetInBattle(petInfo)
    local curPets = PokemonInfo.getPetArmy(PetFormationMgr.getCurTab())
    for k,v in pairs(curPets) do
        if petInfo.objID == v then
            return true
        end
    end
    return false
end

function PetListMgr.isPetInYoke(petInfo)
    if petInfo.yoke then
        if petInfo.yoke.bindTo then
            return true
        end
    end
    return false
end

function PetListMgr.isPetInHelp(petInfo)
    local curPets = PokemonInfo.getPetHelpArmy()
    for k,v in pairs(curPets) do
        if petInfo.objID == v then
            return true
        end
    end
    return false
end

-- 排序规则：已出战>品阶>等级>星级>宠物ID
function PetListMgr.sortPetList(pets)
    local tempPets = {}
    for k,v in pairs(pets) do
        v.rarePoint = PokemonInfo.getPokemonInfoByID(v.pokeID).rarePoint
        tempPets[#tempPets + 1] = v
    end

    table.sort(tempPets, function(a, b)
        local aRare = a.rarePoint
        local bRare = b.rarePoint
        local aInBattle = PetListMgr.isPetInBattle(a)
        local bInBattle = PetListMgr.isPetInBattle(b)
        if aInBattle ~= bInBattle then
            return aInBattle
        else
            local aInHelp = PetListMgr.isPetInHelp(a)
            local bInHelp = PetListMgr.isPetInHelp(b)
            if aInHelp ~= bInHelp then
                return aInHelp
            else
                local aInYoke = PetListMgr.isPetInYoke(a)
                local bInYoke = PetListMgr.isPetInYoke(b)
                if aInYoke ~= bInYoke then
                    return aInYoke
                else
                    if aRare ~= bRare then
                        return aRare > bRare
                    else
                        if a.level ~= b.level then
                            return a.level > b.level
                        else
                            local aStar = tonumber(a.star)
                            local bStar = tonumber(b.star)
                            if aStar ~= bStar then
                                return aStar > bStar
                            else
                                return a.pokeID > b.pokeID
                            end
                        end
                    end
                end
            end
        end
    end)
   
    return tempPets
end

function PetListMgr.setPnum()
    local myPets = PokemonInfo.getAllPets(nil, true)
    local petVec = PokemonInfo.getPetArmy(PetFormationMgr.getCurTab())
    --print("resName2................"..resName)
    if CSResourceMgr.getCsbObj(resName) then
        CSResourceMgr.setLabelString(resName, "pnum", #petVec.."/"..#myPets, "")
    end
end

function PetListMgr.setBnum()
    local myPets = PokemonInfo.getAllPets(nil, true)
    local pnum_max = CharInfo.get().petpacketnum + (CharInfo.get().furniturecomputervaluerate or 0)
    CSResourceMgr.setLabelString(resName, "pnum", #myPets.."/"..pnum_max, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
end


--@param petInfo   table        宠信息
--@param tag       int/string   标签   剩下的血量
--@param cardType  bool         true为名字卡片  false为血条卡片
function PetListMgr.createPetCardWithName(petInfo,tag,cardType)
    tag = tag or ""
    cardType = cardType or true
    local petCard = {}
    local res            =  "Pet/BasicPetList/NCommonPet_2.csb"
    local layer         = CSResourceMgr.createRes(nil,res,tag)
    local btn           = CSResourceMgr.getNodeByName(res,"btn",tag)
    local petLevel      = CSResourceMgr.getNodeByName(res,{"btn","diban","level"},tag)
    local diban         = CSResourceMgr.getNodeByName(res,{"btn","diban"},tag)
    local icon          = CSResourceMgr.getNodeByName(res,{"btn","diban","icon"},tag)
    local rarei         = CSResourceMgr.getNodeByName(res,{"btn","rareidiban","rarei"},tag)
    local attridiban    = CSResourceMgr.getNodeByName(res,{"btn","attridiban"},tag)
    local attribution   = CSResourceMgr.getNodeByName(res,{"btn","attridiban","attri"},tag)
    local petBar        = CSResourceMgr.getNodeByName(res,{"btn","bar"},tag)
    local namenode      = CSResourceMgr.getNodeByName(res,{"btn","petName"},tag)
    local starTable     = {}
    local rarePoint     = PokemonInfo.getPokemonInfoByID(petInfo.pokeID).rarePoint

    for index = 1 ,5 do
        starTable[index] = CSResourceMgr.getNodeByName(res,{"btn","star"..index},tag)
    end
        
    petLevel:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1) 

    petLevel:setString("Lv "..petInfo.level)

    rarei:setScale(0.48)
    
    if cardType then
        petBar:setVisible(false)
        CSResourceMgr.getNodeByName(res,{"btn","hpBK"},tag):setVisible(false)
        CSResourceMgr.getNodeByName(res,{"btn","hp"},tag):setVisible(false)
        CSResourceMgr.getNodeByName(res,{"btn","barBK"},tag):setVisible(false)
        -- local nameStyle     = PetEducationMgr.getNameStyleByStage(rarePoint)
        local nameStr       = LuaSqlite.getLanguageByKey(PokemonInfo.getPokemonInfoByID(petInfo.pokeID).name)
        namenode:setString(nameStr)
        CSResourceMgr.setLabelColorByNode(namenode,PokemonInfo.COLOR[rarePoint])
        namenode:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1) 
    else
        namenode:setVisible(false)
        local cardPer = 100*petInfo.hp/petInfo.hpmax
        petBar:setPercent(cardPer) 
    end

    btn:removeFromParent()

    petCard = {star = starTable,bar = petBar,node = layer,button = btn,level = petLevel,rare = rarei,attriBK = attridiban,attri = attribution,headBK = diban,head = icon}
    
    -- if petInfo.Stage then
    local rareRes = BattleFuncMgr.getStagePics(rarePoint) 
    CSResourceMgr.setSpriteTextureByNode(petCard.headBK, rareRes.p1)  
    -- end
    local attriInfo = tonumber(PokemonInfo.getPokemonInfoByID(petInfo.pokeID).elementAtt1)
    local attriRes = "Pet/AttriIcon/"..attriInfo..".png"
    local attrCirRes = "Pet/AttriIcon/small_"..attriInfo..".png"
    

    --设置星星位置的偏移量 add by lyx
    local unitdiff = petCard.star[1]:getContentSize().width/2
    local k = 1.5 --偏移系数
    local starcnt = tonumber(petInfo.star)
    if starcnt >= 3 and starcnt <5 then k = 1.8 end
    local alldiff = 0
    local movediff = 0
    if starcnt~=5 then
        alldiff = petCard.star[1]:getContentSize().width*k
        movediff= alldiff-(starcnt-1)*unitdiff
    end
    --设置星星位置偏移量结束
    
    for starID = 1,5 do
        if starID > starcnt then
            petCard.star[starID]:hide()
        else
            petCard.star[starID]:show()
            
            local originx = petCard.star[starID]:getPositionX();
            petCard.star[starID]:setPositionX(originx+movediff)
        end
    end
    

    CSResourceMgr.setSpriteTextureByNode(petCard.rare, PetEducationMgr.getRareIcon(rarePoint))
    CSResourceMgr.setSpriteTextureByNode(petCard.head, PokemonInfo.getPokemonIconByID(petInfo.pokeID))
    CSResourceMgr.setSpriteTextureByNode(petCard.attriBK, attrCirRes)
    CSResourceMgr.setSpriteTextureByNode(petCard.attri, attriRes)
    
    return petCard
end

function PetListMgr.savePetTeam(isClose)
    TaskWatcherManager.saveChangeArmyTeam()
    local selPet = PetFormationMgr.getSelPet()
    local helpPet = PetFormationMgr.getHelpPet()
    local tabIsInit = PetFormationMgr.getTabIsInit()
    local amryVec = {}
    for var=1, PetFormationMgr.TEAM_NUM do
        if tabIsInit[var] then
            local objidVec = {}
            local helpidVec = {}
            for i=1, #selPet[var] do
                objidVec[i] = selPet[var][i].objID
            end
            if #helpPet[var] > 0 then
                for i=1, #helpPet[var] do
                    helpidVec[i] = helpPet[var][i].objID
                end
            end
            local tmpVec = {armyIndex=var, armyMembers=objidVec,helpArmyMembers = helpidVec}
            table.insert(amryVec, tmpVec)
        end
    end
    if #amryVec[PetFormationMgr.getCurTab()].armyMembers > 0 then 
        NetInterface.sendWithBlock("GC_UpdatePetArmys_Ack", function()
            local PetSend = require("src.Net.Send.PetSend")
            PetSend.sendCG_UpdatePetArmys_Req({petArmys=amryVec})
        end, function()
            local unactivePets = PokemonInfo.getUnactivePets()
            local armyVecObjID = {}
            local helpVecObjID = {}
            for var=1, PetFormationMgr.TEAM_NUM do
                local objidVec = {}
                for i=1, #selPet[var] do
                    objidVec[i] = selPet[var][i].objID
                end
                armyVecObjID[var] = objidVec
                PokemonInfo.setPetArmy(armyVecObjID)
                if #helpPet[var] > 0 then
                    local helpidVec = {}
                    for i=1, #helpPet[var] do
                        helpidVec[i] = helpPet[var][i].objID
                        table.filter(unactivePets, function(v, k)
                           return v.objID ~= helpPet[var][i].objID
                        end)
                    end
                    helpVecObjID = helpidVec
                end
                PokemonInfo.setHelpArmy(helpVecObjID)
            end
            if not isClose then
                local myPets = PokemonInfo.getAllPets(nil, PetListMgr.isShowYokePets())
                local petVec = PetListMgr.sortPetList(myPets)
                local curTab = PetFormationMgr.getCurTab()
                UnblockLoader.cancel("PetListMgr-reset")
                PetListMgr.reset(petVec, nil,  function(petinfo)
                    for var=1, #selPet[curTab] do
                        if selPet[curTab][var].objID==petinfo.objID then
                            PetListMgr.setStatusLabel(selPet[curTab][var].objID, true)
                            break
                        end
                    end
                    for var=1, #helpPet[curTab] do
                        if helpPet[curTab][var].objID==petinfo.objID then
                            PetListMgr.setStatusLabel(helpPet[curTab][var].objID, true)
                            break
                        end
                    end
                    if PetEducationMgr.isPetYoked(petinfo) then
                        PetListMgr.setStatusYoke(petinfo.objID,true)
                    end
                end)
            end
        end, function(code)
            TipsMgr.showError(nil, code)
        end)
    end
end

function PetListMgr.setResVisible(enable)
    local csbObj = CSResourceMgr.getCsbObj(resName)
    if csbObj then
        csbObj:setVisible(enable)
    end
end

function PetListMgr.isShowYokePets()
    if CSResourceMgr.getCsbObj(resName) then
        return not CSResourceMgr.getNodeByName(resName, "yokeCheckBox"):isSelected()
    end
    return false
end

return PetListMgr