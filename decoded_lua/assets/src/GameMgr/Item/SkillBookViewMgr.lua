local SkillBookViewMgr = {}

SkillBookViewMgr.TAB_NUM = 5
SkillBookViewMgr.ATTRTAB_NUM = 10
SkillBookViewMgr.ROW = 2

local resName = ""
local resName1 = ""
local resNameItem = ""
local resNameOper = ""
local resNameBook = ""
local resNameTips = ""
local resNameBG = ""
local itemNodes = {}
local HandbookCInfoReader = nil
local HandbookCInfo = nil
local skillBookTable = {}
local skillInfoTable = {}
local foundCount = {}
local talentTable = {}
local aidTable = {}
local curTab = 1
local attrTab = 1
local ownBookTable = {}
local resolveTable = {}
local countTable = {}
local bookNum = {}

local tabLabelVec = {
    "skillBook1",
    "skillBook2",
    "skillBook3",
    "skillBook4",
    "skillBook5"
}

local iconPathVec = {
    "UI/CommonFiles/fight_skill_base_01.png",
    "UI/CommonFiles/fight_skill_base_02.png",
    "UI/CommonFiles/esoteric_skill_base_011.png",
    "UI/CommonFiles/skill_passive_base_nomal_01.png",
    "UI/CommonFiles/skill_aid_base_nomal_01.png"
}

local rareBGVec = {
    "UI/CommonFiles/fight_skill_green.png",
    "UI/CommonFiles/fight_skill_blue.png",
    "UI/CommonFiles/fight_skill_purple.png",
    "UI/CommonFiles/fight_skill_yellow.png",
    "Battle/downEdge_A/skillStage/5.png",
    "Battle/downEdge_A/skillStage/6.png"
}

local rarePathVec = {
    "Pet/Education/c.png",
    "Pet/Education/b.png",
    "Pet/Education/a.png",
    "Pet/Education/s.png",
    "Pet/Education/2s.png",
    "Pet/Education/3s.png"
}

local aidBGVec = {
    "UI/CommonFiles/skill_aid_base_nomal_01.png",
    "UI/CommonFiles/skill_aid_base_blue_01.png",
    "UI/CommonFiles/skill_aid_base_violet_01.png",
    "UI/CommonFiles/skill_aid_base_yellow_01.png",
    "UI/CommonFiles/skill_aid_base_orange_01.png",
}

local passiveBGVec = {
    "UI/CommonFiles/skill_passive_base_nomal_01.png",
    "UI/CommonFiles/skill_passive_base_blue_01.png",
    "UI/CommonFiles/skill_passive_base_violet_01.png",
    "UI/CommonFiles/skill_passive_base_yellow_01.png"
}

local skillAngerVec = {
    "UI/CommonFiles/esoteric_skill_anger_01.png",
    "UI/CommonFiles/esoteric_skill_anger_02.png",
    "UI/CommonFiles/esoteric_skill_anger_03.png",
    "UI/CommonFiles/esoteric_skill_anger_04.png"
}

local classVec = {
    "skillBook6",
    "skillBook7",
    "skillBook8"
}

local attrVec = {0,1,5,10,11,3,12,13,16,18}

function SkillBookViewMgr.UpdateSkillInfo(id)
    table.insert(skillInfoTable,id)
end

function SkillBookViewMgr.Init()
    resName = "Item/Bag/SkillBookView.csb"
    resName1 = "Item/Bag/SkillBookView_2.csb"
    resNameItem = "Item/Bag/SkillBookItem.csb"
    resNameOper = "Item/Bag/SkillBookOperView.csb"
    resNameBook = "Item/InfoTips/SkillBookInfoNew.csb"
    resNameTips = "Item/InfoTips/SkillTipInfo.csb"
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    CSResourceMgr.createRes(nil, resNameItem, nil, true)
    itemNodes = {}
    skillBookTable = {}
    skillInfoTable = {}
    foundCount = {}
    ownBookTable = {}
    resolveTable = {}
    countTable = {}
    bookNum = {}
    curTab = 1
    attrTab = 1
    
    if HandbookCInfoReader==nil then
        HandbookCInfoReader = TxtReader.new("Config/HandbookC.txt")
        HandbookCInfo = HandbookCInfoReader.init({"id", "name", "attr", "type", "class", "rarePoint", "itemId", "icon", 
            "hitMin", "hitMax", "powerMin", "powerMax", "desc", "ownPet", "mapSkill", "energy"}, 1)
    end
end

function SkillBookViewMgr.show(scene)
    if not NetInterface.isConnect then
        return
    end
    NetInterface.sendWithBlock("GC_GetPetSkillWiki_Ack", function()
        local PetSend = require("src.Net.Send.PetSend")
        PetSend.sendCG_GetPetSkillWiki_Req()
    end, nil, function(code)
        TipsMgr.showError(scene, code)
    end)
end

function SkillBookViewMgr.open(scene)
    UIStack.push("SkillBookViewMgr", SkillBookViewMgr.hide, true)
    SceneMgr.setMapVisible(false)

    for var=1,5 do
        skillBookTable[var] = {}
        foundCount[var] = {}
        ownBookTable[var] = {}
    end
    for k,v in pairs(HandbookCInfo) do
        table.insert(skillBookTable[tonumber(v.type)],v)
    end

    local pets = PokemonInfo.getAllPets()
    for k,v in pairs(pets) do
        local petSkills = v.skills
        if petSkills[1] ~= 0 then
            local skillInfo = PokemonInfo.getPetSkillInfoById(petSkills[1])
            table.insert(talentTable,skillInfo.groundpower+20000)
        end
    end
    for k,v in pairs(pets) do
        local paSkills = v.paSkills
        for i=1,5 do
            local skillId   = paSkills[i]["paSkillID"]
            local skillType = paSkills[i]["paSkillType"]
            if skillType == 0 and skillId ~= 0 then
                local skillInfo = PokemonInfo.getPetSkillInfoById(skillId)
                table.insert(aidTable,skillInfo.groundpower+20000)
            end
        end
    end

    local count = 0
    for k,v in pairs(skillBookTable[1]) do
        for k1,v1 in pairs(talentTable) do
            if v1 == tonumber(v.itemId) then
                count = count + 1
                table.insert(ownBookTable[1],v)
                break
            end
        end
    end
    foundCount[1] = count
    count = 0
    for k,v in pairs(skillBookTable[5]) do
        for k1,v1 in pairs(aidTable) do
            if v1 == tonumber(v.itemId) then
                count = count + 1
                table.insert(ownBookTable[5],v)
                break
            end
        end
    end
    foundCount[5] = count
    for var=2,4 do
        count = 0
        for k,v in pairs(skillBookTable[var]) do
            for k1,v1 in pairs(skillInfoTable) do
                if v1 == tonumber(v.itemId) then
                    count = count + 1
                    table.insert(ownBookTable[var],v)
                    break
                end
            end
        end
        foundCount[var] = count
    end

    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG, "SkillBookViewMgr")
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "SkillBookViewMgr")
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    end

    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        local curLayer1 = CSResourceMgr.createRes(scene, resName1)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        curLayer1:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.setRelativePosition(resName1, 320, 480)
        curLayer:setVisible(false)
        CocosModuleMgr.setEdgeDistance(curLayer1, nil, nil, 0, nil, false)
        CocosModuleMgr.setEdgeDistance(curLayer, nil, nil, nil, 0, false)

        local diff = CocosModuleMgr.getScreenSizeDiff()
        local background = CSResourceMgr.getNodeByName(resName, "background")
        local bgsize = background:getContentSize()
        background:setContentSize(bgsize.width, bgsize.height+diff)
        local db = CSResourceMgr.getNodeByName(resName, "db")
        local dbsize = db:getContentSize()
        db:setContentSize(dbsize.width, dbsize.height+diff)
        local sortCover = CSResourceMgr.getNodeByName(resName, "sortCover")
        local stsize = sortCover:getContentSize()
        sortCover:setContentSize(stsize.width, stsize.height+diff)
        local list = CSResourceMgr.getNodeByName(resName, "list")
        local ltsize = list:getContentSize()
        list:setContentSize(ltsize.width, ltsize.height+diff)
        local tabs = CSResourceMgr.getNodeByName(resName, "tabs")
        local tposy = tabs:getPositionY()
        tabs:setPositionY(tposy+diff)
        local attrTabs = CSResourceMgr.getNodeByName(resName, "attrTabs")
        local aposy = attrTabs:getPositionY()
        attrTabs:setPositionY(aposy+diff)
        local kuang1 = CSResourceMgr.getNodeByName(resName, "kuang1")
        local k1posy = kuang1:getPositionY()
        kuang1:setPositionY(k1posy+diff)
        local midBar = CSResourceMgr.getNodeByName(resName, "midBar")
        local fposy = midBar:getPositionY()
        midBar:setPositionY(fposy+diff)

        CSResourceMgr.setLabelColor(resName,"title",{r=166,g=243,b=255,a=255})
        CSResourceMgr.setLabelString(resName,"title","skillBook9","",{r=12,g=27,b=38,a=255})
        CSResourceMgr.setLabelColor(resName,"sortTitle",{r=166,g=243,b=255,a=255})
        CSResourceMgr.setLabelString(resName,"sortTitle","train127","",{r=12,g=27,b=38,a=255})
        CSResourceMgr.setLabelColor(resName,"foundLabel",{r=166,g=243,b=255,a=255})
        CSResourceMgr.setLabelString(resName,"foundLabel","skillBook10","",{r=12,g=27,b=38,a=255})
        local stoneCount = ItemInfo.getCharItemNum(10001)
        CSResourceMgr.setLabelColor(resName1,"stoneCnt",{r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelString(resName1,"stoneCnt",stoneCount,"",{r=0,g=0,b=0,a=255})
        local goldCnt = CharInfo.getGCash()
        CSResourceMgr.setLabelColor(resName1,"goldCount",{r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelString(resName1,"goldCount",goldCnt,"",{r=0,g=0,b=0,a=255})
        local diamondCnt = CharInfo.getMCash()
        CSResourceMgr.setLabelColor(resName1,"diamondCount",{r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelString(resName1,"diamondCount",diamondCnt,"",{r=0,g=0,b=0,a=255})

        CSResourceMgr.setLabelColor(resName,"bagLabel",{r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelString(resName,"bagLabel","skillBook30","",{r=0,g=0,b=0,a=255,w=1})
        CSResourceMgr.setButtonString(resName, "resolveBtn", "skillBook31", "", {r=0,g=0,b=0,a=255,w=1})
        CSResourceMgr.setButtonString(resName, "confirmBtn", "skillBook32", "", {r=0,g=0,b=0,a=255,w=1})
        CSResourceMgr.setButtonString(resName, "cancelBtn", "skillBook33", "", {r=0,g=0,b=0,a=255,w=1})

        CSResourceMgr.clickEventBinding(resName, "bagBtn", function()
            SkillBookViewMgr.hide()
            BagViewMgr.request(scene)
        end)

        CSResourceMgr.clickEventBinding(resName1, "closeBtn", function()
            SkillBookViewMgr.hide()
        end)

        local function setTabStatus(tabid,enable)
            local tabtext = CSResourceMgr.getNodeByName(resName, "label"..tabid)
            if enable then
                CSResourceMgr.setLabelColorByNode(tabtext, {r=255,g=255,b=255,a=255})
                CSResourceMgr.setLabelStringByNode(tabtext, tabLabelVec[tabid], {r=209,g=138,b=0,a=255})
            else
                CSResourceMgr.setLabelColorByNode(tabtext, {r=82,g=82,b=82,a=255})
                CSResourceMgr.setLabelStringByNode(tabtext, tabLabelVec[tabid], {r=236,g=236,b=236,a=255})
				if LuaSqlite.LANG_TYPE == 5 then
					tabtext:setFontSize(tabtext:getFontSize()-3)
				end
            end
        end

        for var=1, SkillBookViewMgr.TAB_NUM do
            setTabStatus(var,false)
        end

        for var=1, SkillBookViewMgr.TAB_NUM do
            if var == 1 then
                local spriteTab = CSResourceMgr.getNodeByName(resName, "tab1")
                spriteTab:setLocalZOrder(1)
                spriteTab:setPositionY(3)
                spriteTab:setScale(1.1)
                setTabStatus(var,true)
            end
            local spriteTab = CSResourceMgr.getNodeByName(resName, "tab"..var)
            CSResourceMgr.clickEventBinding(resName, "tab"..var, function()
                spriteTab:setLocalZOrder(1)
                spriteTab:setPositionY(3)
                spriteTab:setScale(1.1)
                setTabStatus(var,true)
                if curTab ~= var then
                    local spriteTab = CSResourceMgr.getNodeByName(resName, "tab"..curTab)
                    spriteTab:setLocalZOrder(-1)
                    spriteTab:setPositionY(0)
                    spriteTab:setScale(1)
                    setTabStatus(curTab,false)
                end
                curTab = var
                local isselected = CSResourceMgr.getNodeByName(resName, "checkbox"):isSelected()
                if isselected then
                    SkillBookViewMgr.changeTab(var,nil,ownBookTable[curTab])
                else
                    SkillBookViewMgr.changeTab(var,nil,nil)
                end
            end)
        end
        SkillBookViewMgr.changeTab(1,nil,ownBookTable[curTab])

        local rareP = nil
        local sortView = CSResourceMgr.getNodeByName(resName, "sortView")
        local function setSortView()
            CSResourceMgr.clickEventBinding(resName, "allBtn", function()
                rareP = nil
                local isselected = CSResourceMgr.getNodeByName(resName, "checkbox"):isSelected()
                if isselected then
                    SkillBookViewMgr.changeTab(curTab,nil,ownBookTable[curTab])
                else
                    SkillBookViewMgr.changeTab(curTab,nil,nil)
                end
                sortView:setVisible(false)
            end)
            CSResourceMgr.clickEventBinding(resName, "cBtn", function()
                rareP = 1
                local isselected = CSResourceMgr.getNodeByName(resName, "checkbox"):isSelected()
                if isselected then
                    SkillBookViewMgr.changeTab(curTab,rareP,ownBookTable[curTab])
                else
                    SkillBookViewMgr.changeTab(curTab,rareP,nil)
                end
                sortView:setVisible(false)
            end)
            CSResourceMgr.clickEventBinding(resName, "bBtn", function()
                rareP = 2
                local isselected = CSResourceMgr.getNodeByName(resName, "checkbox"):isSelected()
                if isselected then
                    SkillBookViewMgr.changeTab(curTab,rareP,ownBookTable[curTab])
                else
                    SkillBookViewMgr.changeTab(curTab,rareP,nil)
                end
                sortView:setVisible(false)
            end)
            CSResourceMgr.clickEventBinding(resName, "aBtn", function()
                rareP = 3
                local isselected = CSResourceMgr.getNodeByName(resName, "checkbox"):isSelected()
                if isselected then
                    SkillBookViewMgr.changeTab(curTab,rareP,ownBookTable[curTab])
                else
                    SkillBookViewMgr.changeTab(curTab,rareP,nil)
                end
                sortView:setVisible(false)
            end)
            CSResourceMgr.clickEventBinding(resName, "sBtn", function()
                rareP = 4
                local isselected = CSResourceMgr.getNodeByName(resName, "checkbox"):isSelected()
                if isselected then
                    SkillBookViewMgr.changeTab(curTab,rareP,ownBookTable[curTab])
                else
                    SkillBookViewMgr.changeTab(curTab,rareP,nil)
                end
                sortView:setVisible(false)
            end)
            CSResourceMgr.clickEventBinding(resName, "ssBtn", function()
                rareP = 5
                local isselected = CSResourceMgr.getNodeByName(resName, "checkbox"):isSelected()
                if isselected then
                    SkillBookViewMgr.changeTab(curTab,rareP,ownBookTable[curTab])
                else
                    SkillBookViewMgr.changeTab(curTab,rareP,nil)
                end
                sortView:setVisible(false)
            end)
            CSResourceMgr.clickEventBinding(resName, "sortCover", function()
                sortView:setVisible(false)
            end)
        end

        CSResourceMgr.clickEventBinding(resName, "sortBtn", function()
            sortView:setVisible(true)
            setSortView()
        end)

        local hasTable = {}
        CSResourceMgr.getNodeByName(resName, "checkbox"):addEventListener(function()
            local isselected = CSResourceMgr.getNodeByName(resName, "checkbox"):isSelected()
            if isselected then
                hasTable = ownBookTable[curTab]
                SkillBookViewMgr.changeTab(curTab,rareP,ownBookTable[curTab])
            else
                hasTable = skillBookTable[curTab]
                SkillBookViewMgr.changeTab(curTab,rareP,skillBookTable[curTab])
            end
        end)

        for var=1, SkillBookViewMgr.ATTRTAB_NUM do
            if var == 1 then
                local spriteTab = CSResourceMgr.getNodeByName(resName, "attrTab1")
                spriteTab:setLocalZOrder(1)
                spriteTab:setPositionX(-8)
                spriteTab:setScale(1.1)
            end
            local spriteTab = CSResourceMgr.getNodeByName(resName, "attrTab"..var)
            CSResourceMgr.clickEventBinding(resName, "attrTab"..var, function()
                spriteTab:setLocalZOrder(1)
                spriteTab:setPositionX(-8)
                spriteTab:setScale(1.1)
                if attrTab ~= var then
                    local spriteTab = CSResourceMgr.getNodeByName(resName, "attrTab"..attrTab)
                    spriteTab:setLocalZOrder(-1)
                    spriteTab:setPositionX(0)
                    spriteTab:setScale(1)
                end
                attrTab = var
                SkillBookViewMgr.changeAttrTab(var,rareP)
            end)
        end
        SkillBookViewMgr.changeAttrTab(1,rareP)

        local tabNum = nil
        CSResourceMgr.clickEventBinding(resName, "resolveBtn", function()
            tabNum = attrTab
            local bottomView = CSResourceMgr.getNodeByName(resName, "bottomView")
            bottomView:setVisible(false)
            local sortBtn = CSResourceMgr.getNodeByName(resName, "sortBtn")
            sortBtn:setVisible(false)
            local resolveView = CSResourceMgr.getNodeByName(resName, "resolveView")
            resolveView:setVisible(true)
            CSResourceMgr.clickEventBinding(resName, "confirmBtn", function()
                bottomView:setVisible(true)
                sortBtn:setVisible(true)
                resolveView:setVisible(false)
                attrTab = tabNum

                if resolveTable then
                    local tempTable = {}
                    for k,v in pairs(resolveTable) do
                        if v.number and v.number ~= 0 then
                            table.insert(tempTable,v)
                        end
                    end
                    local stoneCount = ItemInfo.getCharItemNum(10001)
                    local num = 0
                    for k,v in pairs(countTable) do
                        if type(v) == "number" then
                            num = num + v
                        end
                    end
                    NetInterface.sendWithBlock("GC_ResolvePetSkill_Ack", function()
                        local PetSend = require("src.Net.Send.PetSend")
                        PetSend.sendCG_ResolvePetSkill_Req(tempTable)
                    end, function()
                        resolveTable = {}
                        countTable = {}
                        bookNum = {}
                        if num > 0 then
                            AwardsListMgr.show(SceneMgr.getRunningScene, {{10001,num}})
                        end

                        local stoneCnt = CSResourceMgr.getNodeByName(resName1, "stoneCnt")
                        for i=1,10 do
                            stoneCnt:performWithDelay(function()
                                CSResourceMgr.setLabelStringByNode(stoneCnt,math.floor(stoneCount+num/10*i),{r=0,g=0,b=0,a=255})
                            end,0.1*i)
                        end

                        local isselected = CSResourceMgr.getNodeByName(resName, "checkbox"):isSelected()
                        if isselected then
                            SkillBookViewMgr.changeTab(curTab,rareP,ownBookTable[curTab])
                        else
                            SkillBookViewMgr.changeTab(curTab,rareP)
                        end
                        SkillBookViewMgr.setResolveView(true)
                    end, function(code)
                        TipsMgr.showError(scene, code)
                    end)
                end
            end)
            CSResourceMgr.clickEventBinding(resName, "cancelBtn", function()
                resolveTable = {}
                countTable = {}
                bookNum = {}
                bottomView:setVisible(true)
                sortBtn:setVisible(true)
                resolveView:setVisible(false)
                attrTab = tabNum
                local isselected = CSResourceMgr.getNodeByName(resName, "checkbox"):isSelected()
                if isselected then
                    SkillBookViewMgr.changeTab(curTab,rareP,ownBookTable[curTab])
                else
                    SkillBookViewMgr.changeTab(curTab,rareP)
                end
                SkillBookViewMgr.setResolveView(true)
            end)
            attrTab = 1
            SkillBookViewMgr.changeTab(curTab,nil,ownBookTable[curTab],true)
            SkillBookViewMgr.setResolveView(false)
        end)
    end
    
    local function playCSB()
        CSResourceMgr.getCsbObj(resName):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName,"background"), "up")
    end

    local funcTable = {loadBG, loadCSB, playCSB}
    UnblockLoader.load(funcTable, "SkillBookViewMgr")
end

function SkillBookViewMgr.hide()
    SceneMgr.setMapVisible(true)
    UnblockLoader.cancel("SkillBookViewMgr")
    UnblockLoader.cancel("SkillBookViewMgr.LoadMore")
    itemNodes = {}
    skillBookTable = {}
    skillInfoTable = {}
    foundCount = {}
    talentTable = {}
    aidTable = {}
    resolveTable = {}
    bookNum = {}
    curTab = 1
    attrTab = 1
    CSResourceMgr.removeList(resName, "list")
    CSResourceMgr.removeCSObjectByTag(resNameBG, "SkillBookViewMgr")
    CSResourceMgr.removeCSObjectByTag(resNameTips)
    CSResourceMgr.removeCSObjectByTag(resNameBook)
    CSResourceMgr.removeCSObjectByTag(resNameOper)
    CSResourceMgr.removeCSObjectByTag(resNameItem)
    CSResourceMgr.removeCSObjectByTag(resName1)
    CSResourceMgr.removeCSObjectByTag(resName)
    GameAudio.playUISound("retract")
    HighPerformList.resetAllSchedule()
    UIStack.pop("SkillBookViewMgr")
end

local function loadMore(tabid,sortTable,enable)
    local list = CSResourceMgr.getNodeByName(resName, "list")

    local fromN = 1
    local toN = 14
    if #sortTable < 14 then
        toN = #sortTable
    end

    local funcTable = {}
    local panelNodes = {}
    table.insert(funcTable, function()
        local totalLine = math.ceil(toN/SkillBookViewMgr.ROW)
        local fromLine = math.ceil(fromN/SkillBookViewMgr.ROW)
        local panel = CSResourceMgr.getNodeByName(resName, "panel")
        for i = fromLine, totalLine do
            panelNodes[i] = panel:clone()
            local frame = CSResourceMgr.seekNodeByName(panelNodes[i], "frame")
            frame:setVisible(true)
            frame:setColor({r=25,g=40,b=54})
            list:pushBackCustomItem(panelNodes[i])
        end
    end)

    local diffX = 264
    for index=fromN,toN do
        table.insert(funcTable, function()
            local v = sortTable[index]
            local line = math.ceil(index / SkillBookViewMgr.ROW)
            local row = index % SkillBookViewMgr.ROW == 0 and SkillBookViewMgr.ROW or index % SkillBookViewMgr.ROW
            itemNodes[index] = CSResourceMgr.getNodeByName(resNameItem, "db"):clone()
            itemNodes[index]:addTo(panelNodes[line])
            itemNodes[index]:setPositionX(itemNodes[index]:getPositionX() + (row - 1) * diffX)

            local cover = CSResourceMgr.seekNodeByName(itemNodes[index], "cover")
            cover:setOpacity(80)
            cover:setColor({r=0,g=0,b=0,a=255})
            cover:setVisible(true)

            local statusBG = CSResourceMgr.seekNodeByName(itemNodes[index], "statusBG")
            statusBG:setColor({r=52,g=67,b=86,a=255})
            statusBG:setVisible(false)

            local name = CSResourceMgr.seekNodeByName(itemNodes[index], "name")
            CSResourceMgr.setLabelColorByNode(name, {r=217,g=234,b=255,a=255})
            CSResourceMgr.setLabelStringByNode(name, v.name, {r=17,g=29,b=39,a=255})
            --阿杜修改英文版显示
            if true then
                name:setFontSize(19)
            end

            local status = CSResourceMgr.seekNodeByName(itemNodes[index], "status")
            CSResourceMgr.setLabelColorByNode(status, {r=86,g=102,b=123,a=255})
            CSResourceMgr.setLabelStringByNode(status, "skillBook11", {r=17,g=29,b=39,a=255})

            local rarity = CSResourceMgr.seekNodeByName(itemNodes[index], "rarity")
            CSResourceMgr.setSpriteTextureByNode(rarity, rarePathVec[tonumber(v.rarePoint)])
            rarity:setScale(0.45)

            local rarePoint = tonumber(v.rarePoint)
            if rarePoint > 6 then
                rarePoint = 6
            end

            local rareBG = CSResourceMgr.seekNodeByName(itemNodes[index], "rareBG")
            CSResourceMgr.setSpriteTextureByNode(rareBG, rareBGVec[rarePoint])

            local bookBG = CSResourceMgr.seekNodeByName(itemNodes[index], "bookBG")
            local bookCount = CSResourceMgr.seekNodeByName(itemNodes[index], "bookCount")
            CSResourceMgr.setLabelColorByNode(bookCount, {r=255,g=255,b=255,a=255})
            CSResourceMgr.setLabelStringByNode(bookCount, "x0", {r=0,g=0,b=0,a=255})

            local icon = CSResourceMgr.seekNodeByName(itemNodes[index], "icon")
            local iconBG = CSResourceMgr.seekNodeByName(itemNodes[index], "iconBG")
            local attr = CSResourceMgr.seekNodeByName(itemNodes[index], "attr")
            local rages = CSResourceMgr.seekNodeByName(itemNodes[index], "rages")
            local costBG = CSResourceMgr.seekNodeByName(itemNodes[index], "costBG")
            local cost = CSResourceMgr.seekNodeByName(itemNodes[index], "cost")
            local rage = {}
            rage[1] = CSResourceMgr.seekNodeByName(itemNodes[index], "rage1")
            rage[2] = CSResourceMgr.seekNodeByName(itemNodes[index], "rage2")
            rage[3] = CSResourceMgr.seekNodeByName(itemNodes[index], "rage3")
            rage[4] = CSResourceMgr.seekNodeByName(itemNodes[index], "rage4")
            CSResourceMgr.setSpriteTextureByNode(iconBG, iconPathVec[tabid])

            local iconRes = "Battle/skillIcon/"..tonumber(v.icon)..".png"
            CSResourceMgr.setSpriteTextureByNode(icon, iconRes)

            local circleRes = "UI/CommonFiles/"..tonumber(v.attr)..".png"
            CSResourceMgr.setSpriteTextureByNode(attr, circleRes)

            local typeBG = CSResourceMgr.seekNodeByName(itemNodes[index], "typeBG")
            typeBG:setVisible(true)
            local typeIcon = CSResourceMgr.seekNodeByName(itemNodes[index], "typeIcon")
            typeIcon:setScale(1.05)
            local typeIdx = v.id*10+1
            CSResourceMgr.setSpriteTextureByNode(typeIcon, PokemonInfo.getSkillPlayById(typeIdx).typeIcon)
            local rareFrame = CSResourceMgr.seekNodeByName(itemNodes[index], "rareFrame")
            rareFrame:setPosition(17,142)
            rages:setVisible(false)
            costBG:setVisible(false)
            attr:setPosition(86,142)
            bookBG:setVisible(true)
            if tabid == 1 then
                bookBG:setVisible(false)
                rareBG:setVisible(true)
                iconBG:setScale(1)
                icon:setScale(1.15)
                iconBG:setPosition(54,105)
                icon:setPosition(50.5,106)
                typeBG:setPosition(52,72)
            elseif tabid == 2 then
                rareBG:setVisible(true)
                costBG:setVisible(true)
                iconBG:setScale(1)
                iconBG:setPosition(54,105)
                icon:setPosition(50.5,106)
                icon:setScale(1.15)
                typeBG:setPosition(52,72)
                CSResourceMgr.setLabelColorByNode(cost, {r=255,g=255,b=255,a=255})
                CSResourceMgr.setLabelStringByNode(cost,tonumber(v.energy), {r=0,g=0,b=0,a=255})
            elseif tabid == 3 then
                rareBG:setVisible(false)
                rages:setVisible(true)
                iconBG:setPosition(57,105)
                icon:setPosition(70.5,94)
                icon:setScale(1)
                attr:setPosition(102,124)
                iconBG:setScale(1)
                typeBG:setPosition(105,62)
                rareFrame:setPosition(17,62)
                local rage = CSResourceMgr.seekNodeByName(itemNodes[index], "rage")
                CSResourceMgr.setSpriteTextureByNode(rage, skillAngerVec[tonumber(v.energy)])
            elseif tabid == 4 then
                CSResourceMgr.setSpriteTextureByNode(iconBG, passiveBGVec[rarePoint])
                rareBG:setVisible(false)
                iconBG:setScale(0.9)
                iconBG:setPosition(55,112)
                icon:setPosition(53,112)
                icon:setScale(1.05)
                attr:setPosition(96,152)
                rareFrame:setPosition(18,150)
                typeBG:setVisible(false)
                -- typeBG:setPosition(99,72)
            else
                bookBG:setVisible(false)
                CSResourceMgr.setSpriteTextureByNode(iconBG, aidBGVec[rarePoint])
                rareBG:setVisible(false)
                iconBG:setScale(0.88)
                iconBG:setPosition(55,112)
                icon:setPosition(57,114)
                icon:setScale(1.05)
                attr:setPosition(96,152)
                rareFrame:setPosition(18,150)
                typeBG:setVisible(false)
                -- typeBG:setPosition(99,72)
            end

            if tabid == 1 then
                CSResourceMgr.clickEventBindingByNode(itemNodes[index], function()
                    SkillBookViewMgr.showSkillBookInfo(v,ownCount,tabid,false)
                end)
                for k1,v1 in pairs(talentTable) do
                    if v1 == tonumber(v.itemId) then
                        cover:setVisible(false)
                        CSResourceMgr.setLabelColorByNode(status, {r=217,g=234,b=255,a=255})
                        CSResourceMgr.setLabelStringByNode(status, "skillBook29", {r=17,g=29,b=39,a=255})
                    end
                end
            elseif tabid == 5 then
                CSResourceMgr.clickEventBindingByNode(itemNodes[index], function()
                    SkillBookViewMgr.showSkillBookInfo(v,ownCount,tabid,false)
                end)
                for k1,v1 in pairs(aidTable) do
                    if v1 == tonumber(v.itemId) then
                        cover:setVisible(false)
                        CSResourceMgr.setLabelColorByNode(status, {r=217,g=234,b=255,a=255})
                        CSResourceMgr.setLabelStringByNode(status, "skillBook29", {r=17,g=29,b=39,a=255})
                    end
                end
            else
                CSResourceMgr.clickEventBindingByNode(itemNodes[index], function()
                    SkillBookViewMgr.showSkillBookInfo(v,ownCount,tabid,false)
                end)
                local skillBookInfo = ItemInfo.getSkillBookInfo()
                for k1,v1 in pairs(skillInfoTable) do
                    if v1 == tonumber(v.itemId) then
                        resolveTable[index] = {}
                        countTable[index] = {}
                        if not bookNum[index] then
                            bookNum[index] = 0
                        end
                        cover:setVisible(false)
                        statusBG:setVisible(true)
                        CSResourceMgr.setLabelColorByNode(status, {r=217,g=234,b=255,a=255})
                        CSResourceMgr.setLabelStringByNode(status, "skillBook12", {r=17,g=29,b=39,a=255})

                        local ownCount = 0
                        for k2,v2 in pairs(skillBookInfo) do
                            if v1 == k2 then
                                ownCount = v2
                            end
                        end
                        CSResourceMgr.setLabelColorByNode(bookCount, {r=255,g=255,b=255,a=255})
                        CSResourceMgr.setLabelStringByNode(bookCount, "x"..ownCount, {r=0,g=0,b=0,a=255})
                        
                        CSResourceMgr.clickEventBindingByNode(itemNodes[index], function()
                            SkillBookViewMgr.showSkillBookInfo(v,ownCount,tabid,true)
                        end)

                        local statusView = CSResourceMgr.seekNodeByName(itemNodes[index], "statusView")
                        statusView:setVisible(not enable)
                        local operView = CSResourceMgr.seekNodeByName(itemNodes[index], "operView")
                        operView:setVisible(enable)
                        CSResourceMgr.setButtonEnabledByNode(itemNodes[index], not enable)
                        local gloInfo = SystemInfo.getGlobalConfigAddInfoByID(tonumber(v.rarePoint)+6500)
                        local operCnt = CSResourceMgr.getNodeByName(resName1, "operCnt")
                        local count = 0
                        if countTable then
                            for k,v in pairs(countTable) do
                                if type(v) == "number" then
                                    count = count + v
                                end
                            end
                        end
                        CSResourceMgr.setLabelStringByNode(operCnt,"+"..count,{r=0,g=0,b=0,a=255})
                        operCnt:setColor({r=89,g=242,b=22,a=255})
                        if enable then
                            operCnt:setVisible(true)
                            CSResourceMgr.seekNodeByName(itemNodes[index], "operBG"):setColor({r=36,g=51,b=65})
                            local operCount = CSResourceMgr.seekNodeByName(itemNodes[index], "operCount")
                            local subBtn = CSResourceMgr.seekNodeByName(itemNodes[index], "subBtn")
                            local addBtn = CSResourceMgr.seekNodeByName(itemNodes[index], "addBtn")
                            if ownCount == 0 then
                                CSResourceMgr.setButtonEnabledByNode(addBtn,false)
                            end
                            CSResourceMgr.setButtonEnabledByNode(subBtn,false)
                            
                            CSResourceMgr.clickEventBindingByNode(subBtn, function()
                                if bookNum[index] > 0 then
                                    bookNum[index] = bookNum[index] - 1
                                    CSResourceMgr.setButtonEnabledByNode(addBtn,true)
                                end
                                if bookNum[index] < 1 then
                                    CSResourceMgr.setButtonEnabledByNode(subBtn,false)
                                end
                                countTable[index] = gloInfo.values[1]*bookNum[index]
                                resolveTable[index].SkillBookID = v.itemId
                                resolveTable[index].number = bookNum[index]
                                local count = 0
                                for k,v in pairs(countTable) do
                                    if type(v) == "number" then
                                        count = count + v
                                    end
                                end
                                CSResourceMgr.setLabelStringByNode(operCnt, "+"..count,{r=0,g=0,b=0,a=255})
                                CSResourceMgr.setLabelStringByNode(operCount, bookNum[index])
                            end)
                            CSResourceMgr.clickEventBindingByNode(addBtn, function()
                                if ownCount-bookNum[index] > 0 then
                                    bookNum[index] = bookNum[index] + 1
                                    CSResourceMgr.setButtonEnabledByNode(subBtn,true)
                                end
                                if ownCount-bookNum[index] < 1 then
                                    CSResourceMgr.setButtonEnabledByNode(addBtn,false)
                                end
                                countTable[index] = gloInfo.values[1]*bookNum[index]
                                resolveTable[index].SkillBookID = v.itemId
                                resolveTable[index].number = bookNum[index]
                                local count = 0
                                for k,v in pairs(countTable) do
                                    if type(v) == "number" then
                                        count = count + v
                                    end
                                end
                                CSResourceMgr.setLabelStringByNode(operCnt, "+"..count,{r=0,g=0,b=0,a=255})
                                CSResourceMgr.setLabelStringByNode(operCount, bookNum[index])
                            end)
                        else
                            operCnt:setVisible(false)
                        end
                    end
                end
            end
        end)
    end

    local function setTop()
        list:jumpToTop()
    end
    table.insert(funcTable,setTop)

    local spawncount = 7
    local countperline = 2
    local function listFunc()
        HighPerformList.makeHighPerFormVerticalList(list,spawncount,10,countperline,185,165,sortTable,
        function(item,currentindex)
            
            for j=1,countperline do
                local itemInfo = sortTable[currentindex+j-1]
                local curIndex = (currentindex+j-1)%14
                if curIndex == 0 then
                    curIndex = 14
                end
                if itemInfo == nil or itemNodes[curIndex] == nil then 
                    if itemNodes[curIndex] then
                        itemNodes[curIndex]:setVisible(false)
                    end
                else
                    itemNodes[curIndex]:setVisible(true)
                    local cover = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "cover")
                    cover:setOpacity(80)
                    cover:setColor({r=0,g=0,b=0,a=255})
                    cover:setVisible(true)

                    local statusBG = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "statusBG")
                    statusBG:setColor({r=52,g=67,b=86,a=255})
                    statusBG:setVisible(false)

                    local name = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "name")
                    CSResourceMgr.setLabelColorByNode(name, {r=217,g=234,b=255,a=255})
                    CSResourceMgr.setLabelStringByNode(name, itemInfo.name, {r=17,g=29,b=39,a=255})
                    --阿杜修改英文版显示
                        if true then
                        name:setFontSize(19)
                    end

                    local status = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "status")
                    CSResourceMgr.setLabelColorByNode(status, {r=86,g=102,b=123,a=255})
                    CSResourceMgr.setLabelStringByNode(status, "skillBook11", {r=17,g=29,b=39,a=255})

                    local rarity = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "rarity")
                    CSResourceMgr.setSpriteTextureByNode(rarity, rarePathVec[tonumber(itemInfo.rarePoint)])
                    rarity:setScale(0.45)

                    local rarePoint = tonumber(itemInfo.rarePoint)
                    if rarePoint > 6 then
                        rarePoint = 6
                    end

                    local rareBG = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "rareBG")
                    CSResourceMgr.setSpriteTextureByNode(rareBG, rareBGVec[rarePoint])

                    local bookBG = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "bookBG")
                    local bookCount = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "bookCount")
                    CSResourceMgr.setLabelColorByNode(bookCount, {r=255,g=255,b=255,a=255})
                    CSResourceMgr.setLabelStringByNode(bookCount, "x0", {r=0,g=0,b=0,a=255})

                    local icon = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "icon")
                    local iconBG = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "iconBG")
                    local attr = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "attr")
                    local rages = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "rages")
                    local costBG = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "costBG")
                    local cost = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "cost")
                    local rage = {}
                    rage[1] = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "rage1")
                    rage[2] = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "rage2")
                    rage[3] = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "rage3")
                    rage[4] = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "rage4")
                    CSResourceMgr.setSpriteTextureByNode(iconBG, iconPathVec[tabid])

                    local iconRes = "Battle/skillIcon/"..tonumber(itemInfo.icon)..".png"
                    CSResourceMgr.setSpriteTextureByNode(icon, iconRes)

                    local circleRes = "UI/CommonFiles/"..tonumber(itemInfo.attr)..".png"
                    CSResourceMgr.setSpriteTextureByNode(attr, circleRes)

                    local typeBG = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "typeBG")
                    typeBG:setVisible(true)
                    local typeIcon = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "typeIcon")
                    typeIcon:setScale(1.05)
                    local typeIdx = itemInfo.id*10+1
                    CSResourceMgr.setSpriteTextureByNode(typeIcon, PokemonInfo.getSkillPlayById(typeIdx).typeIcon)
                    local rareFrame = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "rareFrame")
                    rareFrame:setPosition(17,142)
                    rages:setVisible(false)
                    costBG:setVisible(false)
                    attr:setPosition(86,142)
                    bookBG:setVisible(true)
                    if tabid == 1 then
                        bookBG:setVisible(false)
                        rareBG:setVisible(true)
                        iconBG:setScale(1)
                        icon:setScale(1.15)
                        iconBG:setPosition(54,105)
                        icon:setPosition(50.5,106)
                        typeBG:setPosition(52,72)
                    elseif tabid == 2 then
                        rareBG:setVisible(true)
                        costBG:setVisible(true)
                        iconBG:setScale(1)
                        iconBG:setPosition(54,105)
                        icon:setPosition(50.5,106)
                        icon:setScale(1.15)
                        typeBG:setPosition(52,72)
                        CSResourceMgr.setLabelColorByNode(cost, {r=255,g=255,b=255,a=255})
                        CSResourceMgr.setLabelStringByNode(cost,tonumber(itemInfo.energy), {r=0,g=0,b=0,a=255})
                    elseif tabid == 3 then
                        rareBG:setVisible(false)
                        rages:setVisible(true)
                        iconBG:setPosition(57,105)
                        icon:setPosition(70.5,94)
                        icon:setScale(1)
                        attr:setPosition(102,124)
                        iconBG:setScale(1)
                        typeBG:setPosition(105,62)
                        rareFrame:setPosition(17,62)
                        local rage = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "rage")
                        CSResourceMgr.setSpriteTextureByNode(rage, skillAngerVec[tonumber(itemInfo.energy)])
                    elseif tabid == 4 then
                        CSResourceMgr.setSpriteTextureByNode(iconBG, passiveBGVec[rarePoint])
                        rareBG:setVisible(false)
                        iconBG:setScale(0.9)
                        iconBG:setPosition(55,112)
                        icon:setPosition(53,112)
                        icon:setScale(1.05)
                        attr:setPosition(96,152)
                        rareFrame:setPosition(18,150)
                        typeBG:setVisible(false)
                        -- typeBG:setPosition(99,72)
                    else
                        bookBG:setVisible(false)
                        CSResourceMgr.setSpriteTextureByNode(iconBG, aidBGVec[rarePoint])
                        rareBG:setVisible(false)
                        iconBG:setScale(0.88)
                        iconBG:setPosition(55,112)
                        icon:setPosition(57,114)
                        icon:setScale(1.05)
                        attr:setPosition(96,152)
                        rareFrame:setPosition(18,150)
                        typeBG:setVisible(false)
                        -- typeBG:setPosition(99,72)
                    end

                    if tabid == 1 then
                        CSResourceMgr.clickEventBindingByNode(itemNodes[curIndex], function()
                            SkillBookViewMgr.showSkillBookInfo(itemInfo,ownCount,tabid,false)
                        end)
                        for k1,v1 in pairs(talentTable) do
                            if v1 == tonumber(itemInfo.itemId) then
                                cover:setVisible(false)
                                CSResourceMgr.setLabelColorByNode(status, {r=217,g=234,b=255,a=255})
                                CSResourceMgr.setLabelStringByNode(status, "skillBook29", {r=17,g=29,b=39,a=255})
                            end
                        end
                    elseif tabid == 5 then
                        CSResourceMgr.clickEventBindingByNode(itemNodes[curIndex], function()
                            SkillBookViewMgr.showSkillBookInfo(itemInfo,ownCount,tabid,false)
                        end)
                        for k1,v1 in pairs(aidTable) do
                            if v1 == tonumber(itemInfo.itemId) then
                                cover:setVisible(false)
                                CSResourceMgr.setLabelColorByNode(status, {r=217,g=234,b=255,a=255})
                                CSResourceMgr.setLabelStringByNode(status, "skillBook29", {r=17,g=29,b=39,a=255})
                            end
                        end
                    else
                        CSResourceMgr.clickEventBindingByNode(itemNodes[curIndex], function()
                            SkillBookViewMgr.showSkillBookInfo(itemInfo,ownCount,tabid,false)
                        end)
                        local skillBookInfo = ItemInfo.getSkillBookInfo()
                        for k1,v1 in pairs(skillInfoTable) do
                            if v1 == tonumber(itemInfo.itemId) then
                                if not resolveTable[currentindex+j-1] then
                                    resolveTable[currentindex+j-1] = {}
                                    countTable[currentindex+j-1] = {}
                                end
                                if not bookNum[currentindex+j-1] then
                                    bookNum[currentindex+j-1] = 0
                                end
                                cover:setVisible(false)
                                statusBG:setVisible(true)
                                CSResourceMgr.setLabelColorByNode(status, {r=217,g=234,b=255,a=255})
                                CSResourceMgr.setLabelStringByNode(status, "skillBook12", {r=17,g=29,b=39,a=255})

                                local ownCount = 0
                                for k2,v2 in pairs(skillBookInfo) do
                                    if v1 == k2 then
                                        ownCount = v2
                                    end
                                end
                                CSResourceMgr.setLabelColorByNode(bookCount, {r=255,g=255,b=255,a=255})
                                CSResourceMgr.setLabelStringByNode(bookCount, "x"..ownCount, {r=0,g=0,b=0,a=255})
                                
                                CSResourceMgr.clickEventBindingByNode(itemNodes[curIndex], function()
                                    SkillBookViewMgr.showSkillBookInfo(itemInfo,ownCount,tabid,true)
                                end)

                                local statusView = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "statusView")
                                statusView:setVisible(not enable)
                                local operView = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "operView")
                                operView:setVisible(enable)
                                CSResourceMgr.setButtonEnabledByNode(itemNodes[curIndex], not enable)
                                local gloInfo = SystemInfo.getGlobalConfigAddInfoByID(tonumber(itemInfo.rarePoint)+6500)
                                local operCnt = CSResourceMgr.getNodeByName(resName1, "operCnt")
                                local count = 0
                                if countTable then
                                    for k,v in pairs(countTable) do
                                        if type(v) == "number" then
                                            count = count + v
                                        end
                                    end
                                end
                                CSResourceMgr.setLabelStringByNode(operCnt,"+"..count,{r=0,g=0,b=0,a=255})
                                operCnt:setColor({r=89,g=242,b=22,a=255})
                                if enable then
                                    operCnt:setVisible(true)
                                    CSResourceMgr.seekNodeByName(itemNodes[curIndex], "operBG"):setColor({r=36,g=51,b=65})
                                    local operCount = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "operCount")
                                    CSResourceMgr.setLabelStringByNode(operCount, bookNum[currentindex+j-1])
                                    local subBtn = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "subBtn")
                                    local addBtn = CSResourceMgr.seekNodeByName(itemNodes[curIndex], "addBtn")

                                    if ownCount == 0 then
                                        CSResourceMgr.setButtonEnabledByNode(addBtn,false)
                                        CSResourceMgr.setButtonEnabledByNode(subBtn,false)
                                    else
                                        if bookNum[currentindex+j-1] == 0 then
                                            CSResourceMgr.setButtonEnabledByNode(subBtn,false)
                                            CSResourceMgr.setButtonEnabledByNode(addBtn,true)
                                        else
                                            if ownCount-bookNum[currentindex+j-1]>0 then
                                                CSResourceMgr.setButtonEnabledByNode(subBtn,true)
                                                CSResourceMgr.setButtonEnabledByNode(addBtn,true)
                                            else
                                                CSResourceMgr.setButtonEnabledByNode(subBtn,true)
                                                CSResourceMgr.setButtonEnabledByNode(addBtn,false)
                                            end
                                        end
                                    end

                                    CSResourceMgr.clickEventBindingByNode(subBtn, function()
                                        if bookNum[currentindex+j-1] > 0 then
                                            bookNum[currentindex+j-1] = bookNum[currentindex+j-1] - 1
                                            CSResourceMgr.setButtonEnabledByNode(addBtn,true)
                                        end
                                        if bookNum[currentindex+j-1] < 1 then
                                            CSResourceMgr.setButtonEnabledByNode(subBtn,false)
                                        end
                                        countTable[currentindex+j-1] = gloInfo.values[1]*bookNum[currentindex+j-1]
                                        resolveTable[currentindex+j-1].SkillBookID = itemInfo.itemId
                                        resolveTable[currentindex+j-1].number = bookNum[currentindex+j-1]
                                        local count = 0
                                        for k,v in pairs(countTable) do
                                            if type(v) == "number" then
                                                count = count + v
                                            end
                                        end
                                        CSResourceMgr.setLabelStringByNode(operCnt, "+"..count,{r=0,g=0,b=0,a=255})
                                        CSResourceMgr.setLabelStringByNode(operCount, bookNum[currentindex+j-1])
                                    end)
                                    CSResourceMgr.clickEventBindingByNode(addBtn, function()
                                        if ownCount-bookNum[currentindex+j-1] > 0 then
                                            bookNum[currentindex+j-1] = bookNum[currentindex+j-1] + 1
                                            CSResourceMgr.setButtonEnabledByNode(subBtn,true)
                                        end
                                        if ownCount-bookNum[currentindex+j-1] < 1 then
                                            CSResourceMgr.setButtonEnabledByNode(addBtn,false)
                                        end
                                        countTable[currentindex+j-1] = gloInfo.values[1]*bookNum[currentindex+j-1]
                                        resolveTable[currentindex+j-1].SkillBookID = itemInfo.itemId
                                        resolveTable[currentindex+j-1].number = bookNum[currentindex+j-1]
                                        local count = 0
                                        for k,v in pairs(countTable) do
                                            if type(v) == "number" then
                                                count = count + v
                                            end
                                        end
                                        CSResourceMgr.setLabelStringByNode(operCnt, "+"..count,{r=0,g=0,b=0,a=255})
                                        CSResourceMgr.setLabelStringByNode(operCount, bookNum[currentindex+j-1])
                                    end)
                                else
                                    operCnt:setVisible(false)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
    table.insert(funcTable, listFunc)

    UnblockLoader.load(funcTable, "SkillBookViewMgr.LoadMore")
end

function SkillBookViewMgr.changeTab(tabid,rareP,hasTable,enable)
    for var=1, SkillBookViewMgr.TAB_NUM do
        CSResourceMgr.setButtonEnabled(resName, "tab"..var, true)
    end
    CSResourceMgr.setButtonEnabled(resName, "tab"..tabid, false)

    local resolveBtn = CSResourceMgr.getNodeByName(resName, "resolveBtn")
    local hasLabel = CSResourceMgr.getNodeByName(resName, "hasLabel")
    CSResourceMgr.setLabelColorByNode(hasLabel, {r=255,g=255,b=255,a=255})
    if tabid == 1 or tabid == 5 then
        resolveBtn:setVisible(false)
        CSResourceMgr.setLabelStringByNode(hasLabel, "skillBook40")
    else
        resolveBtn:setVisible(true)
        CSResourceMgr.setLabelStringByNode(hasLabel, "skillBook41")
    end

    CSResourceMgr.setLabelColor(resName,"foundCnt",{r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelString(resName,"foundCnt",foundCount[tabid],"",{r=0,g=0,b=0,a=255})

    local list = CSResourceMgr.getNodeByName(resName, "list")
    list:removeAllItems()
    

    local sortTable = {}
    local rareTabel = {}
    if not hasTable then
        hasTable = skillBookTable[curTab]
    end

    if rareP then
        for k,v in pairs(hasTable) do
            if tonumber(v.rarePoint) == rareP then
                table.insert(rareTabel,v)
            end
        end
    else
        rareTabel = hasTable
    end
    if attrTab == 1 then
        sortTable = rareTabel
    else
        for k,v in pairs(rareTabel) do
            if tonumber(v.attr) == attrVec[attrTab] then
                table.insert(sortTable,v)
            end
        end
    end

    UnblockLoader.cancel("SkillBookViewMgr.LoadMore")
    loadMore(tabid,sortTable,enable)
end

function SkillBookViewMgr.setResolveView(enable)
    local checkbox = CSResourceMgr.getNodeByName(resName, "checkbox")
    checkbox:setTouchEnabled(enable)
    for var=1,SkillBookViewMgr.TAB_NUM do
        if var ~= curTab then
            local btn = CSResourceMgr.getNodeByName(resName, "tab"..var)
            btn:setTouchEnabled(enable)
            if enable then
                btn:setColor({r=255,g=255,b=255})
            else
                btn:setColor({r=107,g=107,b=107})
            end
        end
    end
    for var=1,SkillBookViewMgr.ATTRTAB_NUM do
        local btn = CSResourceMgr.getNodeByName(resName, "attrTab"..var)
        local icon = CSResourceMgr.getNodeByName(resName, "icon"..var)
        local icon1 = CSResourceMgr.getNodeByName(resName, "icon0"..var)
        if var ~= attrTab then
            CSResourceMgr.setButtonEnabledByNode(btn, true)
            btn:setTouchEnabled(enable)
            btn:setLocalZOrder(-1)
            btn:setPositionX(0)
            btn:setScale(1)
            icon:setVisible(false)
            icon1:setVisible(true)
            if enable then
                btn:setColor({r=255,g=255,b=255})
            else
                btn:setColor({r=107,g=107,b=107})
            end
        else
            CSResourceMgr.setButtonEnabledByNode(btn, false)
            icon:setVisible(true)
            icon1:setVisible(false)
            btn:setLocalZOrder(1)
            btn:setPositionX(-8)
            btn:setScale(1.1)
            btn:setColor({r=255,g=255,b=255})
        end
    end
end

function SkillBookViewMgr.changeAttrTab(tabid,rareP)
    for var=1, SkillBookViewMgr.ATTRTAB_NUM do
        CSResourceMgr.setButtonEnabled(resName, "attrTab"..var, true)
        local icon = CSResourceMgr.getNodeByName(resName, "icon"..var)
        local icon1 = CSResourceMgr.getNodeByName(resName, "icon0"..var)
        icon:setVisible(false)
        icon1:setVisible(true)
    end
    CSResourceMgr.setButtonEnabled(resName, "attrTab"..tabid, false)
    local icon = CSResourceMgr.getNodeByName(resName, "icon"..tabid)
    local icon1 = CSResourceMgr.getNodeByName(resName, "icon0"..tabid)
    icon:setVisible(true)
    icon1:setVisible(false)
    local isselected = CSResourceMgr.getNodeByName(resName, "checkbox"):isSelected()
    if isselected then
        SkillBookViewMgr.changeTab(curTab,rareP,ownBookTable[curTab])
    else
        SkillBookViewMgr.changeTab(curTab,rareP,nil)
    end
end

function SkillBookViewMgr.showSkillTipInfo(info)
    local curEfx = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameTips)
    curEfx:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
    CSResourceMgr.setFullScreen(resNameTips)
    CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resNameTips,"db"),"down")

    local bg = CSResourceMgr.getNodeByName(resNameTips, "bg")
    CSResourceMgr.clickEventBindingByNode(bg, function()
        CSResourceMgr.removeCSObjectByTag(resNameTips)
    end)

    local close = CSResourceMgr.getNodeByName(resNameTips, "close")
    CSResourceMgr.clickEventBindingByNode(close, function()
        CSResourceMgr.removeCSObjectByTag(resNameTips)
    end)

    local getwayInfo = ItemInfo.getItemGetWay(info.itemId)
    local getwayStr = {"iteminfo18", "iteminfo19", "iteminfo20", "iteminfo21", "iteminfo22", "iteminfo24",
            "iteminfo25", "iteminfo26", "iteminfo27"}
    local loopSize = #getwayInfo
    if loopSize>4 then
        loopSize = 4
    end
    for var=1, loopSize do
        local gInfo = getwayInfo[var]
        CSResourceMgr.getNodeByName(resName, "getwayicon"..var):setScale(0.5)
        CSResourceMgr.setSpriteTexture(resName, "getwayicon"..var, "Item/GetWay/"..gInfo.type..".png")
        local nameLabel = CSResourceMgr.getNodeByName(resName, "getwayname"..var)
        CSResourceMgr.setLabelColor(resName, "getwayname"..var, {r=217,g=234,b=255,a=255})
        CSResourceMgr.setLabelString(resName, "getwayname"..var, getwayStr[gInfo.type], "", nil, nil, 200)
        nameLabel:enableOutline({r=0,g=0,b=0,a=255}, 1)
        if info.type==1 then
            CSResourceMgr.clickEventBinding(resName, "getway"..var, function()
                SkillBookViewMgr.hide()
                if gInfo.type==1 then
                    WorldMapMgr.searchAdventureNode(gInfo.param)
                elseif gInfo.type==2 then
                    TipsMgr.show(scene, "哪有活动副本啊？")
                elseif gInfo.type==3 then
                    PetFormationMgr.show(scene)
                elseif gInfo.type==4 then
                    PetExploreMgr.request(scene, gInfo.param)
                elseif gInfo.type==5 then
                    TipsMgr.show(scene, "哪有商店啊？")
                elseif gInfo.type==6 then
                    TipsMgr.show(scene, "哪有千层塔准备界面？")
                elseif gInfo.type==7 then
                    WorldMapMgr.searchAdventureNode(gInfo.param, 4)
                elseif gInfo.type==8 then
                    GachaViewMgr.show(scene)
                elseif gInfo.type==9 then
                    TipsMgr.show(scene, "哪有生活技能？")
                end
            end)
        end
    end

    local title = CSResourceMgr.getNodeByName(resNameTips, "title")
    CSResourceMgr.setLabelColorByNode(title, {r=166,g=243,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(title, "skillBook13", {r=12,g=27,b=38,a=255})

    local rareLabel = CSResourceMgr.getNodeByName(resNameTips, "rareLabel")
    CSResourceMgr.setLabelColorByNode(rareLabel, {r=144,g=238,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(rareLabel, "skillBook14", {r=38,g=54,b=76,a=255})

    local typeLabel = CSResourceMgr.getNodeByName(resNameTips, "typeLabel")
    CSResourceMgr.setLabelColorByNode(typeLabel, {r=144,g=238,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(typeLabel, "skillBook15", {r=38,g=54,b=76,a=255})

    local hitLabel = CSResourceMgr.getNodeByName(resNameTips, "hitLabel")
    CSResourceMgr.setLabelColorByNode(hitLabel, {r=144,g=238,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(hitLabel, "skillBook16", {r=38,g=54,b=76,a=255})

    local classLabel = CSResourceMgr.getNodeByName(resNameTips, "classLabel")
    CSResourceMgr.setLabelColorByNode(classLabel, {r=144,g=238,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(classLabel, "skillBook17", {r=38,g=54,b=76,a=255})

    local powerLabel = CSResourceMgr.getNodeByName(resNameTips, "powerLabel")
    CSResourceMgr.setLabelColorByNode(powerLabel, {r=144,g=238,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(powerLabel, "skillBook18", {r=38,g=54,b=76,a=255})

    local infotitle = CSResourceMgr.getNodeByName(resNameTips, "infotitle")
    CSResourceMgr.setLabelColorByNode(infotitle, {r=144,g=238,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(infotitle, "skillBook19", {r=38,g=54,b=76,a=255})

    local tiptitle = CSResourceMgr.getNodeByName(resNameTips, "tiptitle")
    CSResourceMgr.setLabelColorByNode(tiptitle, {r=144,g=238,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(tiptitle, "skillBook20", {r=38,g=54,b=76,a=255})

    local icon = CSResourceMgr.getNodeByName(resNameTips, "icon")
    local iconRes = "Battle/skillIcon/"..tonumber(info.icon)..".png"
    CSResourceMgr.setSpriteTextureByNode(icon, iconRes)

    local attrBG = CSResourceMgr.getNodeByName(resNameTips, "attrBG")
    local attr = CSResourceMgr.getNodeByName(resNameTips, "attr")
    local frameRes = "Pet/AttriIcon/small_"..tonumber(info.attr)..".png"
    local circleRes = "Pet/AttriIcon/"..tonumber(info.attr)..".png"
    CSResourceMgr.setSpriteTextureByNode(attrBG, frameRes)
    CSResourceMgr.setSpriteTextureByNode(attr, circleRes)

    local rareIcon = CSResourceMgr.getNodeByName(resNameTips, "rareIcon")
    CSResourceMgr.setSpriteTextureByNode(rareIcon, rarePathVec[tonumber(info.rarePoint)])

    local name = CSResourceMgr.getNodeByName(resNameTips, "name")
    CSResourceMgr.setLabelColorByNode(name, {r=217,g=234,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(name, info.name, {r=17,g=29,b=39,a=255})

    local typeL = CSResourceMgr.getNodeByName(resNameTips, "typeL")
    CSResourceMgr.setLabelColorByNode(typeL, {r=217,g=234,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(typeL, tabLabelVec[tonumber(info.type)], {r=17,g=29,b=39,a=255})

    local class = CSResourceMgr.getNodeByName(resNameTips, "class")
    CSResourceMgr.setLabelColorByNode(class, {r=217,g=234,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(class, classVec[tonumber(info.class)-2], {r=17,g=29,b=39,a=255})

    local hit = CSResourceMgr.getNodeByName(resNameTips, "hit")
    CSResourceMgr.setLabelColorByNode(hit, {r=217,g=234,b=255,a=255})
    if tonumber(info.hitMin) ~= tonumber(info.hitMax) then
        CSResourceMgr.setLabelStringByNode(hit, info.hitMin.."("..info.hitMax..")", {r=17,g=29,b=39,a=255})
    else
        CSResourceMgr.setLabelStringByNode(hit, info.hitMin, {r=17,g=29,b=39,a=255})
    end

    local power = CSResourceMgr.getNodeByName(resNameTips, "power")
    CSResourceMgr.setLabelColorByNode(power, {r=217,g=234,b=255,a=255})
    if tonumber(info.powerMin) ~= tonumber(info.powerMax) then
        CSResourceMgr.setLabelStringByNode(power, info.powerMin.."("..info.powerMax..")", {r=17,g=29,b=39,a=255})
    else
        CSResourceMgr.setLabelStringByNode(power, info.powerMin, {r=17,g=29,b=39,a=255})
    end

    local tipInfo = CSResourceMgr.getNodeByName(resNameTips, "tipInfo")
    CSResourceMgr.setLabelColorByNode(tipInfo, {r=112,g=131,b=158,a=255})
    CSResourceMgr.setLabelStringByNode(tipInfo, info.desc)
end

function SkillBookViewMgr.showSkillBookInfo(info,num,tabid,isOper)
    local function setLabel(label,string,outline,outlinewidth,textColor,maxwidth)
        CSResourceMgr.setLabelColorByNode(label,textColor)
        CSResourceMgr.setLabelStringByNode(label,string,nil)
        if outlinewidth~=nil  then
            label:enableOutline(outline, outlinewidth)
        end

        if maxwidth~=nil then
            CSResourceMgr.setLabelMaxWidthByNode(label,maxwidth)
        end
    end
    --阿杜修改英文版
    if true then
        resNameBook = "Item/InfoTips/SkillBookInfoUS.csb"
    end

    local curEfx = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameBook)
    curEfx:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
    CSResourceMgr.setFullScreen(resNameBook)
    local panel = CSResourceMgr.getNodeByName(resNameBook,"panel")
    CocosModuleMgr.showUIAnimation(panel,"down")

    local resolveBtn = CSResourceMgr.getNodeByName(resNameBook, "resolveBtn")
    local upBtn = CSResourceMgr.getNodeByName(resNameBook, "upBtn")
    CSResourceMgr.setButtonString(resNameBook, "resolveBtn", "skillBook44", "", {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setButtonString(resNameBook, "upBtn", "skillBook43", "", {r=0,g=0,b=0,a=255,w=1})
    if isOper then
        CSResourceMgr.clickEventBindingByNode(resolveBtn, function()
            SkillBookViewMgr.showSkillBookOperView(info,num,true,tabid)
            CSResourceMgr.removeCSObjectByTag(resNameBook)
        end)
    else
        resolveBtn:setVisible(false)
        upBtn:setPositionX(320)
    end

    local bg = CSResourceMgr.getNodeByName(resNameBook, "bg")
    CSResourceMgr.clickEventBindingByNode(bg, function()
        CSResourceMgr.removeCSObjectByTag(resNameBook)
    end)

    local closeBtn = CSResourceMgr.getNodeByName(resNameBook, "closeBtn")
    CSResourceMgr.clickEventBindingByNode(closeBtn, function()
        CSResourceMgr.removeCSObjectByTag(resNameBook)
    end)

    local title = CSResourceMgr.getNodeByName(resNameBook, "title")
    CSResourceMgr.setLabelColorByNode(title, {r=166,g=243,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(title, "skillBook13", {r=12,g=27,b=38,a=255})

    local name = CSResourceMgr.getNodeByName(resNameBook, "name")
    CSResourceMgr.setLabelColorByNode(name, {r=217,g=234,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(name, info.name, {r=17,g=29,b=39,a=255})

    local tipInfo = CSResourceMgr.getNodeByName(resNameBook, "desc")
    CSResourceMgr.setLabelStringByNode(tipInfo, info.desc)

    local attr = CSResourceMgr.getNodeByName(resNameBook, "attr")
    local circleRes = "UI/CommonFiles/"..tonumber(info.attr)..".png"
    CSResourceMgr.setSpriteTextureByNode(attr, circleRes)

    local rareIcon = CSResourceMgr.getNodeByName(resNameBook, "rare")
    CSResourceMgr.setSpriteTextureByNode(rareIcon, rarePathVec[tonumber(info.rarePoint)])

    local infot3 = CSResourceMgr.getNodeByName(resNameBook, "infot3")
    CSResourceMgr.setLabelColorByNode(infot3, {r=144,g=238,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(infot3, "skillBook42", {r=38,g=54,b=76,a=255})

    local infot4 = CSResourceMgr.getNodeByName(resNameBook, "infot4")
    CSResourceMgr.setLabelColorByNode(infot4, {r=144,g=238,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(infot4, "skillBook14", {r=38,g=54,b=76,a=255})

    local infot5 = CSResourceMgr.getNodeByName(resNameBook, "infot5")
    CSResourceMgr.setLabelColorByNode(infot5, {r=144,g=238,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(infot5, "skillBook36", {r=38,g=54,b=76,a=255})

    local infotitle = CSResourceMgr.getNodeByName(resNameBook, "infotitle")
    CSResourceMgr.setLabelColorByNode(infotitle, {r=144,g=238,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(infotitle, "skillBook19", {r=38,g=54,b=76,a=255})

    local desctitle = CSResourceMgr.getNodeByName(resNameBook, "desctitle")
    CSResourceMgr.setLabelColorByNode(desctitle, {r=144,g=238,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(desctitle, "skillBook20", {r=38,g=54,b=76,a=255})

    --阿杜修改英文版显示
    if true then
        CSResourceMgr.getNodeByName(resNameBook, "bg1"):setContentSize(200,34)
        infotitle:setPositionX(100)
        CSResourceMgr.getNodeByName(resNameBook, "bg2"):setContentSize(200,34)
        desctitle:setPositionX(100)
    end

    local lvCount = 1
    local function changeInfo()
        local list = CSResourceMgr.getNodeByName(resNameBook, "list")
        list:removeAllItems()
        
        local id = tonumber(info.id) * 10 + lvCount
        local skillInfo = BattleInfo.getSkillInfoByID(id)

        local cost = CSResourceMgr.getNodeByName(resNameBook, "cost")
        CSResourceMgr.setSpriteTextureByNode(cost, PetSkillIconMgr.skillLvIconTable[lvCount])

        if tabid == 4 or tabid == 5 then
            local infot1 = CSResourceMgr.getNodeByName(resNameBook, "infot1")
            CSResourceMgr.setLabelColorByNode(infot1, {r=144,g=238,b=255,a=255})
            CSResourceMgr.setLabelStringByNode(infot1, "triggerTiming", {r=38,g=54,b=76,a=255},nil,100)

            local str = PetSkillViewMgr.getPaSkillTiming(skillInfo)
            local typeL = CSResourceMgr.getNodeByName(resNameBook, "info1")
            typeL:setPositionX(infot1:getPositionX()+infot1:getContentSize().width)
            CSResourceMgr.setLabelColorByNode(typeL, {r=217,g=234,b=255,a=255})
            CSResourceMgr.setLabelStringByNode(typeL, str, {r=17,g=29,b=39,a=255},nil,168)
        else
            local infot1 = CSResourceMgr.getNodeByName(resNameBook, "infot1")
            CSResourceMgr.setLabelColorByNode(infot1, {r=144,g=238,b=255,a=255})
            CSResourceMgr.setLabelStringByNode(infot1, "skillBook18", {r=38,g=54,b=76,a=255})

            local typeL = CSResourceMgr.getNodeByName(resNameBook, "info1")
            typeL:setPositionX(infot1:getPositionX()+infot1:getContentSize().width)
            CSResourceMgr.setLabelColorByNode(typeL, {r=217,g=234,b=255,a=255})
            CSResourceMgr.setLabelStringByNode(typeL, skillInfo.power, {r=17,g=29,b=39,a=255})
        end

        local icon = CSResourceMgr.getNodeByName(resNameBook, "icon")
        local iconBtn = PetSkillIconMgr.createPetSkillIcon(icon,skillInfo,1)

        local skillType = 1
        if tabid == 4 or tabid == 5 then
            skillType = 2
        end
        local index = 1
        for k,v in pairs(skillInfo.skillTags) do
            local skillTagInfo = BattleInfo.getSkillTagInfoByID(v.id)
            local attr_node = CSResourceMgr.getNodeByName(resNameBook, "attr_node"):clone()
            list:pushBackCustomItem(attr_node)
            local attr_name = CSResourceMgr.seekNodeByName(attr_node, "attr_name")
            CSResourceMgr.setLabelStringByNode(attr_name, skillTagInfo.name)
            local attr_info = CSResourceMgr.seekNodeByName(attr_node, "attr_info")
            local desc,isLocked = PetSkillViewMgr.getSortedSkillTipsInfo(skillInfo, skillType, v, skillInfo.des[v.id])
            local lColor = isLocked == true and {r=255,g=0,b=0,a=255} or {r=217,g=234,b=255,a=255}
            setLabel(attr_info,desc,nil,nil,lColor,330)
            attr_info:setAnchorPoint(0, 0.5)
            local starCnt = skillInfo.skillTags[index].powers[lvCount]
            local maxStarCnt = skillInfo.skillTags[index].powers[5]
            for i=1,maxStarCnt do
                local star = CSResourceMgr.seekNodeByName(attr_node, "star_"..i)
                CSResourceMgr.setSpriteTextureByNode(star, "UI/CommonFiles/xing_null.png")
            end
            for i=1,starCnt do
                local star = CSResourceMgr.seekNodeByName(attr_node, "star_"..i)
                CSResourceMgr.setSpriteTextureByNode(star, "Pet/Education/xing.png")
            end       

            index = index + 1
        end
    end

    changeInfo()
    CSResourceMgr.clickEventBindingByNode(upBtn, function()
        if lvCount < 5 then
            lvCount = lvCount + 1
        else
            lvCount = 1
        end
        changeInfo()
    end)
end

function SkillBookViewMgr.showSkillBookOperView(info,num,enable,tabid)
    local curEfx = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameOper)
    curEfx:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
    CSResourceMgr.setFullScreen(resNameOper)
    CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resNameOper,"background"),"down")

    local cover = CSResourceMgr.getNodeByName(resNameOper, "cover")
    CSResourceMgr.clickEventBindingByNode(cover, function()
        CSResourceMgr.removeCSObjectByTag(resNameOper)
    end)

    local closeBtn = CSResourceMgr.getNodeByName(resNameOper, "closeBtn")
    CSResourceMgr.clickEventBindingByNode(closeBtn, function()
        CSResourceMgr.removeCSObjectByTag(resNameOper)
    end)

    local title = CSResourceMgr.getNodeByName(resNameOper, "title")
    CSResourceMgr.setLabelColorByNode(title, {r=166,g=243,b=255,a=255})

    local atitle = CSResourceMgr.getNodeByName(resNameOper, "atitle")
    CSResourceMgr.setLabelColorByNode(atitle, {r=144,g=238,b=255,a=255})

    local name = CSResourceMgr.getNodeByName(resNameOper, "name")
    CSResourceMgr.setLabelColorByNode(name, {r=217,g=234,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(name, info.name, {r=17,g=29,b=39,a=255})

    local countLabel = CSResourceMgr.getNodeByName(resNameOper, "countLabel")
    CSResourceMgr.setLabelStringByNode(countLabel, "recharge39", {r=0,g=0,b=0,a=255})

    local ownCount = CSResourceMgr.getNodeByName(resNameOper, "ownCount")
    CSResourceMgr.setLabelColorByNode(ownCount, {r=217,g=234,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(ownCount, "x"..num, {r=17,g=29,b=39,a=255})

    local stoneCount = ItemInfo.getCharItemNum(10001)
    CSResourceMgr.setLabelColor(resName1,"stoneCnt",{r=255,g=255,b=255,a=255})

    local icon = CSResourceMgr.getNodeByName(resNameOper, "icon")
    local iconBtn = ItemInfo.getItemIconById(info.itemId,nil)
    iconBtn:addTo(icon)
    iconBtn:setPosition(0,0)
    iconBtn:setScale(0.72)

    local selNum = 0
    local function checkStoneFunc(sellnum,enable)
        if not sellnum then
            return
        end
        local gloInfo = 0
        if enable then
            gloInfo = SystemInfo.getGlobalConfigAddInfoByID(tonumber(info.rarePoint)+6500)
        else
            gloInfo = SystemInfo.getGlobalConfigAddInfoByID(tonumber(info.rarePoint)+6550)
        end
        local aCount = CSResourceMgr.getNodeByName(resNameOper, "aCount")
        CSResourceMgr.setLabelStringByNode(aCount, gloInfo.values[1]*sellnum,{r=0,g=0,b=0,a=255})
    end

    local tips = CSResourceMgr.getNodeByName(resNameOper, "tips")
    CSResourceMgr.setLabelColorByNode(tips, {r=143,g=176,b=217,a=255})
    CSResourceMgr.setLabelStringByNode(tips, "skillBook21", {r=18,g=33,b=45,a=255})

    local aName = CSResourceMgr.getNodeByName(resNameOper, "aName")
    CSResourceMgr.setLabelColorByNode(aName, {r=217,g=234,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(aName, "skillBook22", {r=17,g=29,b=39,a=255})

    local params = {}
    local operBtn = CSResourceMgr.getNodeByName(resNameOper, "operBtn")
    CSResourceMgr.setButtonStringColorByNode(operBtn, {r=217,g=234,b=255,a=255})
    local maxBtn = CSResourceMgr.getNodeByName(resNameOper, "maxBtn")
    CSResourceMgr.setButtonStringColorByNode(maxBtn, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setButtonStringByNode(maxBtn, "MAX", {r=45,g=62,b=1,a=255})
    if enable then
        params[1] = {}
        params[1].SkillBookID = tonumber(info.itemId)
        tips:setVisible(true)
        CSResourceMgr.setLabelStringByNode(title, "skillBook23", {r=12,g=27,b=38,a=255})
        CSResourceMgr.setLabelStringByNode(atitle, "skillBook24", {r=38,g=54,b=76,a=255})
        CSResourceMgr.setButtonStringByNode(operBtn, "skillBook25", {r=17,g=29,b=39,a=255})

        editBox = CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resNameOper, "edit"), "UI/CommonFiles/chat_text_box_su.png", 
            120, 40, 0, 0, 32, 32, "", 2, function()
                selNum = tonumber(editBox:getText())
                if selNum then
                    if selNum > num then
                        selNum = num
                    end
                else
                    selNum = 1
                end
                editBox:setText(selNum.."")
                checkStoneFunc(selNum,true)
            end)
        editBox:setText(selNum.."")
        checkStoneFunc(selNum,true)

        CSResourceMgr.clickEventBindingByNode(maxBtn, function()
            editBox:setText(num)
            selNum = num
            checkStoneFunc(selNum,true)
        end)

        CSResourceMgr.clickEventBindingByNode(operBtn, function()
            params[1].number = selNum
            if params[1].number and params[1].number <= num and params[1].number ~= 0 then
                NetInterface.sendWithBlock("GC_ResolvePetSkill_Ack", function()
                    local PetSend = require("src.Net.Send.PetSend")
                    PetSend.sendCG_ResolvePetSkill_Req(params)
                end, function()
                    local gloInfo = SystemInfo.getGlobalConfigAddInfoByID(tonumber(info.rarePoint)+6500)
                    AwardsListMgr.show(SceneMgr.getRunningScene, {{10001,gloInfo.values[1]*params[1].number}})
                    CSResourceMgr.setLabelString(resName1,"stoneCnt",stoneCount + gloInfo.values[1]*params[1].number,"",{r=0,g=0,b=0,a=255})
                    local isselected = CSResourceMgr.getNodeByName(resName, "checkbox"):isSelected()
                    if isselected then
                        SkillBookViewMgr.changeTab(tabid,nil,ownBookTable[tabid])
                    else
                        SkillBookViewMgr.changeTab(tabid,nil,nil)
                    end
                    CSResourceMgr.removeCSObjectByTag(resNameOper)
                end, function(code)
                    TipsMgr.showError(scene, code)
                end)
            else
                StandardTipsMgr.show(1, "skillBook37")
                CSResourceMgr.removeCSObjectByTag(resNameOper)
            end
        end)
    else
        params.id = tonumber(info.itemId)
        tips:setVisible(false)
        CSResourceMgr.setLabelStringByNode(title, "skillBook26", {r=12,g=27,b=38,a=255})
        CSResourceMgr.setLabelStringByNode(atitle, "skillBook27", {r=38,g=54,b=76,a=255})
        CSResourceMgr.setButtonStringByNode(operBtn, "skillBook28", {r=17,g=29,b=39,a=255})

        editBox = CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resNameOper, "edit"), "UI/CommonFiles/chat_text_box_su.png", 
            120, 40, 0, 0, 32, 32, "", 2, function()
                selNum = tonumber(editBox:getText())
                editBox:setText(selNum.."")
                checkStoneFunc(selNum,false)
            end)
        editBox:setText(selNum.."")
        checkStoneFunc(selNum,false)

        local gloInfo = SystemInfo.getGlobalConfigAddInfoByID(tonumber(info.rarePoint)+6550)
        CSResourceMgr.clickEventBindingByNode(maxBtn, function()
            local operNum = math.floor(stoneCount/gloInfo.values[1])
            editBox:setText(operNum)
            selNum = operNum
            checkStoneFunc(selNum,false)
        end)

        CSResourceMgr.clickEventBindingByNode(operBtn, function()
            params.num = selNum
            if params.num and gloInfo.values[1]*params.num <= stoneCount and params.num ~= 0 then
                NetInterface.sendWithBlock("GC_CompoundPetSkill_Ack", function()
                    local PetSend = require("src.Net.Send.PetSend")
                    PetSend.sendCG_CompoundPetSkill_Req(params)
                end, function()
                    StandardTipsMgr.show(0, "skillBook38")
                    CSResourceMgr.setLabelString(resName1,"stoneCnt",stoneCount-gloInfo.values[1]*params.num,"",{r=0,g=0,b=0,a=255})
                    local isselected = CSResourceMgr.getNodeByName(resName, "checkbox"):isSelected()
                    if isselected then
                        SkillBookViewMgr.changeTab(tabid,nil,ownBookTable[tabid])
                    else
                        SkillBookViewMgr.changeTab(tabid,nil,nil)
                    end
                    CSResourceMgr.removeCSObjectByTag(resNameOper)
                end, function(code)
                    TipsMgr.showError(scene, code)
                end)
            else
                StandardTipsMgr.show(1, "skillBook39")
                CSResourceMgr.removeCSObjectByTag(resNameOper)
            end 
        end)
    end
end

return SkillBookViewMgr