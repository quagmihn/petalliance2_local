local PVPQuestListMgr = {}

local resName = ""
local resNameDownBar = ""
local resNameBG = ""

local resNameAni = ""

local difficultyString = {}
local raceTable = {}

local resetQuest = 0
local resetIdx = 0

local questSelectTable = {}
local questStateTable = {}

local hyd = 0

function PVPQuestListMgr.Init()

    resName = "Player/ArenaPK/PVPQuestList.csb"
    resNameDownBar = "Player/ArenaPK/PVPQuestDownBar.csb"
    resNameBG = "Pet/Formation/FormationBGNew.csb"

    resNameAni = "Spine/effects/Ui_chongwulingqujiemian.png"

    difficultyString = {
        [1] = "Pet/Education/c.png",
        [2] = "Pet/Education/b.png",
        [3] = "Pet/Education/a.png",
        [4] = "Pet/Education/s.png",
    }

    raceTable[3] = "train194"
    raceTable[5] = "train193"
    raceTable[10] = "train191"
    raceTable[11] = "train192"
    raceTable[12] = "train195"
    raceTable[13] = "train196"
    raceTable[16] = "train197"
    raceTable[18] = "train198"

    resetQuest = 0

    questSelectTable = {}
    questStateTable = {}

    hyd = 0

end

function PVPQuestListMgr.initUIData()

    CSResourceMgr.setLabelString(resName, "txt_title", "pvptasktips1", nil, {r=26,g=37,b=48,a=255,w=1})
    CSResourceMgr.setLabelString(resName, "txt_tips", "pvptasktips3", nil, {r=26,g=37,b=48,a=255,w=1})

    CSResourceMgr.setLabelString(resNameDownBar, "tip", "pvptasktips4", nil, {r=26,g=37,b=48,a=255,w=1})

    local reset = CSResourceMgr.getNodeByName(resNameDownBar, "reset")
    CSResourceMgr.setButtonStringByNode(reset, LuaSqlite.getLanguageByKey("skillReset1"), nil, {r=0,g=0,b=0,a=255,w=1})
    
    local diff = CocosModuleMgr.getScreenSizeDiff()
    if diff < 0 then
        local list = CSResourceMgr.getNodeByName(resName,"list")
        local lsize = list:getContentSize()
        list:setContentSize(lsize.width, lsize.height+diff*2.66)
    end

end

function PVPQuestListMgr.refreshHYD()

    local curArenaLevel = ArenaInfo.getPVPArenaLevel()
    local curArenaInfo = ArenaInfo.getPVPArenaGradeInfoById(curArenaLevel)

    local num1 = hyd*10
    local num2 = curArenaInfo.questPowerAwardNeed*10
    CSResourceMgr.setLabelString(resName, "hydata", num1.."/"..num2, nil, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 100)
    local progressbar = CSResourceMgr.getNodeByName(resName, "progressbar")
    progressbar:setPercent(hyd*100/curArenaInfo.questPowerAwardNeed)

    if hyd == curArenaInfo.questPowerAwardNeed then
        if QuestInfo.getPvpArenaQuestDatas().getPowerAward then
            CSResourceMgr.setButtonEnabled(resName, "apimg3", false)
            AnimationMgr.removeGafObjectByTag(resNameAni, "PVPQuestListMgr")
        else
            if not AnimationMgr.getGafObj(resNameAni, "PVPQuestListMgr") then
                local parent = CSResourceMgr.getNodeByName(resName, "apimg3")
                local ani = AnimationMgr.createAni(parent, resNameAni, 
                    45, 42.5, "PVPQuestListMgr")
                ani:setScale(0.2)
                ani:setLocalZOrder(-1)
                AnimationMgr.playAni(resNameAni, "animation", true, "PVPQuestListMgr")
            end
            CSResourceMgr.clickEventBinding(resName, "apimg3", function()
                NetInterface.sendWithBlock("GC_GetPVPArenaQuestPowerAward_Ack", function()
                    local PVPSend = require("src.Net.Send.PVPSend")
                    PVPSend.sendCG_GetPVPArenaQuestPowerAward_Req()
                end, function()
                    CSResourceMgr.setButtonEnabled(resName, "apimg3", false)
                    AnimationMgr.removeGafObjectByTag(resNameAni, "PVPQuestListMgr")
                    PVPQuestListMgr.refreshData()
                    AwardsListMgr.show(SceneMgr.getRunningScene, {curArenaInfo.questPowerAwards})
                end, function(code)
                    TipsMgr.showError(nil, code)
                end)
                GameAudio.playUISound("itemGet")
            end)
        end
    else
        CSResourceMgr.clickEventBinding(resName, "apimg3", function()
            DropInfoViewMgr.show({curArenaInfo.questPowerAwards}, true)
        end)
    end

end

function PVPQuestListMgr.refreshData()

    PVPQuestListMgr.refreshPvpArenaCoin()
    PVPQuestListMgr.refreshGold()
    PVPQuestListMgr.refreshDiamond()
        
end

function PVPQuestListMgr.refreshPvpArenaCoin()

    if CSResourceMgr.getCsbObj(resName) then
        local devote = CSResourceMgr.getNodeByName(resName, "txt_devote")
        CSResourceMgr.setLabelStringByNode(devote, CharInfo.getPvpArenaCoin(), {r=0,g=0,b=0,a=255,w=1})
    end

end

function PVPQuestListMgr.refreshGold()

    if CSResourceMgr.getCsbObj(resName) then
        local gold = CSResourceMgr.getNodeByName(resName, "txt_gold")
        CSResourceMgr.setLabelStringByNode(gold, CharInfo.getGCash())
    end

end

function PVPQuestListMgr.refreshDiamond()

    if CSResourceMgr.getCsbObj(resName) then
        local diamond = CSResourceMgr.getNodeByName(resName, "txt_diamond")
        CSResourceMgr.setLabelStringByNode(diamond, CharInfo.getMCash())
    end

end

function PVPQuestListMgr.hideUI()
    UnblockLoader.cancel("PVPQuestListMgr")
    CSResourceMgr.removeCSObjectByTag(resName)
    CSResourceMgr.removeCSObjectByTag(resNameDownBar)
    CSResourceMgr.removeCSObjectByTag(resNameBG, "PVPQuestListMgr")
    AnimationMgr.removeGafObjectByTag(resNameAni, "PVPQuestListMgr")
    UIStack.pop("PVPQuestListMgr")
end

function PVPQuestListMgr.show(scene)
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end
    UIStack.push("PVPQuestListMgr",PVPQuestListMgr.hideUI,true)
    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG, "PVPQuestListMgr")
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "PVPQuestListMgr")
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    end
    
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CocosModuleMgr.setEdgeDistance(curLayer, 0, nil, 0, nil, false)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)
        
        curLayer = CSResourceMgr.createRes(scene, resNameDownBar)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CocosModuleMgr.setEdgeDistance(curLayer, 0, nil, nil, 0, false)
        curLayer:setVisible(false)
        
        CSResourceMgr.clickEventBinding(resName, "close", function()
            PVPQuestListMgr.hideUI()
        end)
        
        CSResourceMgr.clickEventBinding(resNameDownBar, "reset", function()
            PVPQuestListMgr.reset()
        end)
        
        PVPQuestListMgr.initUIData()

        PVPQuestListMgr.refreshData()
        
        CSResourceMgr.clickEventBinding(resName, "btn_gold", function()
            ExchangeViewMgr.show(scene,ExchangeViewMgr.GCASHTYPE)
        end)
        
        CSResourceMgr.clickEventBinding(resName, "btn_diamond", function()
            PurchaseViewMgr.show(scene)
        end)

        CSResourceMgr.setLabelColor(resName, "hytitle", {r=166,g=243,b=255,a=255})
        CSResourceMgr.setLabelString(resName, "hytitle", "mission9", nil, {r=12,g=27,b=38,a=255,w=1,s=1}, nil, 120)

    end
    
    local function playCSB()
        local node = CSResourceMgr.getNodeByName(resName, "db")
        if node ~= nil then
            node:setVisible(true)
            CocosModuleMgr.showUIAnimation(node, "down")
        end
        
        CSResourceMgr.getCsbObj(resNameDownBar):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resNameDownBar), "up")
    end
    
    loadBG()
    loadCSB()
    playCSB()

    resetIdx = 0

    PVPQuestListMgr.getPVPArenaQuests()

end

function PVPQuestListMgr.getPVPArenaQuests()

    NetInterface.sendWithBlock("GC_GetMYPVPArenaQuests_Ack", function()
        local PVPSend = require("src.Net.Send.PVPSend")
        PVPSend.sendCG_GetMYPVPArenaQuests_Req()
    end, function()
        resetQuest = 0
        resetIdx  = 0
        CSResourceMgr.setButtonEnabled(resNameDownBar, "reset", false)
        PVPQuestListMgr.createList()
    end, function(code)
        CSResourceMgr.setButtonEnabled(resNameDownBar, "reset", true)
        TipsMgr.showError(nil, code)
    end)

end

function PVPQuestListMgr.questSelect(key)

    local canSelect = false
    for i=1,#questStateTable do
        if questStateTable[i][1] == key and not questStateTable[i][2] then
            canSelect = true
            break
        end
    end

    if canSelect then
        for i=1,#questStateTable do
            if questStateTable[i][1] == key then
                resetIdx = i
                resetQuest = key
                questSelectTable[i]:setVisible(true)
                CSResourceMgr.setButtonEnabled(resNameDownBar, "reset", true)
            else
                questSelectTable[i]:setVisible(false)
            end
        end
    end

end

function PVPQuestListMgr.createList(questID, questAwards)

    if CSResourceMgr.getCsbObj(resName) then

        resetQuest = 0
        questSelectTable = {}
        questStateTable = {}

        CSResourceMgr.setButtonEnabled(resNameDownBar, "reset", false)

        local list = CSResourceMgr.getNodeByName(resName,"list")
        list:removeAllItems()
        
        local funcTable = {}
        UnblockLoader.cancel("PVPQuestListMgr")

        local missionData = QuestInfo.getPvpArenaQuestDatas()
        local quests = missionData.quests
        local processes = missionData.processes

        hyd = 0
        local index = 0
        for key, var in pairs(quests) do
            table.insert(funcTable,function()
                index = index + 1
                local quest = CSResourceMgr.getNodeByName(resName,"btn_quest"):clone()
                for var=1, 2 do
                    local quest_bg = CSResourceMgr.seekNodeByName(quest, "quest_bg"..(2*(var-1)+1))
                    quest_bg:setColor({r=81,g=112,b=137})
                end

                local quest_select = CSResourceMgr.seekNodeByName(quest, "quest_bg")
                quest_select:setVisible(false)

                table.insert(questSelectTable, quest_select)
                table.insert(questStateTable, {key, var})
                -- if resetQuest == 0 and not var and resetIdx == 0 then
                --     resetQuest = key
                --     quest_select:setVisible(true)
                --     CSResourceMgr.setButtonEnabled(resNameDownBar, "reset", true)
                -- end

                if resetIdx == index and not var then
                    resetQuest = key
                    quest_select:setVisible(true)
                    CSResourceMgr.setButtonEnabled(resNameDownBar, "reset", true)
                end

                CSResourceMgr.clickEventBindingByNode(quest,function()
                    PVPQuestListMgr.questSelect(key)
                end)

                local questInfo = QuestInfo.getPVPArenaQuestInfoById(key)

                local quest_name = CSResourceMgr.seekNodeByName(quest, "quest_name")
                CSResourceMgr.setLabelStringByNode(quest_name, questInfo.title, {r=17,g=27,b=38,a=255,w=1})

                local quest_desc = CSResourceMgr.seekNodeByName(quest, "quest_desc")
                if questInfo.questType == "departmentpet" then
                    local desc = CocosModuleMgr.createStringWithFormat({questInfo.desc, raceTable[questInfo.param1]})
                    CSResourceMgr.setLabelStringByNode(quest_desc, desc, nil, nil, 290)
                else
                    local desc = CocosModuleMgr.createStringWithFormat({questInfo.desc, questInfo.param1})
                    CSResourceMgr.setLabelStringByNode(quest_desc, desc, nil, nil, 290)
                end
                CSResourceMgr.setLabelColorByNode(quest_desc, {r=71,g=96,b=103,a=255})

                local quest_btnbg = CSResourceMgr.seekNodeByName(quest, "quest_btnbg")

                local quest_btn_recv = CSResourceMgr.seekNodeByName(quest, "quest_btn_recv")
                CSResourceMgr.setButtonStringByNode(quest_btn_recv, "mission6", {r=36,g=98,b=5,a=255,w=2})

                local flag = CSResourceMgr.seekNodeByName(quest, "quest_flag")
                local flagtext = CSResourceMgr.seekNodeByName(quest, "quest_flag_text")
                
                local quest_difficulty = CSResourceMgr.seekNodeByName(quest, "quest_difficulty")
                CSResourceMgr.setSpriteTextureByNode(quest_difficulty, difficultyString[questInfo.questClass])
                
                local quest_devote = CSResourceMgr.seekNodeByName(quest, "quest_devote")
                CSResourceMgr.setLabelStringByNode(quest_devote,  questInfo.rewardElement[2], {r=0,g=0,b=0,a=255,w=1})

                local process = CSResourceMgr.seekNodeByName(quest, "process")

                local pbar = CSResourceMgr.seekNodeByName(quest, "pbar")

                local curProcess = 0
                local needProcess = 1
                if questInfo.questType ~= "departmentpet" and questInfo.questType ~= "roundwin_once" then
                    needProcess = questInfo.param1
                end
                if processes then
                    if questInfo.questType == "killpet" then
                        curProcess = processes.killpet
                    elseif questInfo.questType == "releaseskill" then
                        curProcess = processes.releaseskill
                    elseif questInfo.questType == "win" then
                        curProcess = processes.win
                    elseif questInfo.questType == "roundwin_once" then
                        needProcess = questInfo.param1
                        curProcess = processes.roundwin_once or (needProcess + 1) 
                        if curProcess <= needProcess then
                            curProcess = 1
                            needProcess = 1
                        else
                            curProcess = 0
                            needProcess = 1
                        end
                    elseif questInfo.questType == "damage" then
                        curProcess = processes.damage
                    elseif questInfo.questType == "crit" then
                        curProcess = processes.crit
                    elseif questInfo.questType == "dodge" then
                        curProcess = processes.dodge
                    elseif questInfo.questType == "restore" then
                        curProcess = processes.restore
                    elseif questInfo.questType == "damage_once" then
                        curProcess = processes.damage_once
                    elseif questInfo.questType == "crit_once" then
                        curProcess = processes.crit_once
                    elseif questInfo.questType == "dodge_once" then
                        curProcess = processes.dodge_once
                    elseif questInfo.questType == "restore_once" then
                        curProcess = processes.restore_once
                    elseif questInfo.questType == "departmentpet" then
                        curProcess = processes.departmentpet
                    end
                    if curProcess == nil then
                        curProcess = 0
                    end
                end
                if curProcess > needProcess then
                    curProcess = needProcess
                end

                if var then
                    quest_btnbg:setVisible(false)
                    quest_btn_recv:setVisible(false)
                    flag:setVisible(true)
                    flagtext:setVisible(true)
                    CSResourceMgr.setLabelStringByNode(flagtext, "mission7", {r=194,g=27,b=27,a=255,w=3}, nil, 120)

                    CSResourceMgr.setLabelStringByNode(process, needProcess.."/"..needProcess, 
                        {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 120)
                    pbar:setPercent(100)

                    hyd = hyd + 1
                else
                    if curProcess == needProcess then
                        quest_btnbg:setVisible(true)
                        quest_btn_recv:setVisible(true)
                        flag:setVisible(false)
                        flagtext:setVisible(false)
                    else
                        quest_btnbg:setVisible(false)
                        quest_btn_recv:setVisible(false)
                        flag:setVisible(false)
                        flagtext:setVisible(true)
                        CSResourceMgr.setLabelStringByNode(flagtext, "mission11", {r=26,g=37,b=48,a=255,w=2}, nil, 120)
                    end

                    CSResourceMgr.setLabelStringByNode(process, curProcess.."/"..needProcess, 
                        {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 120)
                    pbar:setPercent(curProcess*100/needProcess)
                end

                CSResourceMgr.clickEventBindingByNode(quest_btn_recv,function()
                    NetInterface.sendWithBlock("GC_CommitPVPArenaQuest_Ack", function()
                        local PVPSend = require("src.Net.Send.PVPSend")
                        PVPSend.sendCG_CommitPVPArenaQuest_Req(key)
                    end, function()
                        PVPQuestListMgr.getPVPArenaQuests()
                        PVPQuestListMgr.refreshPvpArenaCoin()
                    end, function(code)
                        TipsMgr.showError(nil, code)
                    end)
                    GameAudio.playUISound("reward")
                end)

                quest:setVisible(true)
                quest:setScaleY(0)
                list:pushBackCustomItem(quest)
                transition.scaleTo(quest,{scale=1.0,time = 0.1})
            end)
        end

        table.insert(funcTable, PVPQuestListMgr.refreshHYD)

        UnblockLoader.load(funcTable,"PVPQuestListMgr")

    end
end

function PVPQuestListMgr.reset()
    if resetQuest == 0 then
        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1,"pvptasktips18", function()
                
            end)
        return 
    end
    if resetQuest ~= 0 then
        local questInfo = QuestInfo.getPVPArenaQuestInfoById(resetQuest)
        local MCashCost = SystemInfo.getGlobalConfigAddInfoByID(62001).values[1]
        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, CocosModuleMgr.createStringWithFormat({"pvptasktips5", MCashCost, questInfo.title}), function()
            NetInterface.sendWithBlock("GC_ResetPVPArenaQuest_Ack", function()
                local PVPSend = require("src.Net.Send.PVPSend")
                PVPSend.sendCG_ResetPVPArenaQuest_Req(resetQuest)
            end, function()
                PVPQuestListMgr.getPVPArenaQuests()
            end, function(code)
                TipsMgr.showError(nil, code)
            end, nil, false)
        end,function()
        end)
    end

end

return PVPQuestListMgr