local AchievementListMgr = {}


local resName = ""
local resNameBG = ""
local resNameA = ""
local resNameB = ""
local resNameC = ""
local resNameD = ""
local resNameE = ""
local resNameTop = ""
local scrollViewRes = {}
local achieveList = {}
local achievementList = {}
local achievements = {}
local achievementsB = {}
local finishList = {}
local posList = {}
local achievementListCopy = nil
local isWaitCheck = false
local isSend = false
local redPointNum = 0
local redPointNum2 = 0
local curTab = 1
local tabBLoad = false
local tabALoad = false
local tabCLoad = false
local orderString = {}
local curTreeTab = 1
local skillTable = {}
local finishSkillTable = {}
local finishPetAchieve = {}
local grayColor = {}  
local treeBLoad = false
local treeALoad = false
local treeCLoad = false
local isReadSkillInfo = false
local PotentialInfoConfig = require("src.DatReader.PotentialInfoConfig")
local achievementpoint = 0
local countFieldNameTable = nil
local isHavePokeInfoLst = nil

function AchievementListMgr.Init()
    print("AchievementListMgr初始化")
    
    resName = "Player/AchievementList.csb"
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    resNameA = "Player/AchievementTabA.csb"
    resNameB = "Player/AchievementTabB.csb"
    resNameC = "Player/AchievementTabC.csb"
    resNameD = "Player/AchieveSkillInfoView.csb"
    resNameE = "Player/achieveSkillReset.csb"
    resNameTop = "Player/AchieveTopInfoLayer.csb"
    scrollViewRes = {"Player/AchievementTabCScrollView1.csb","Player/AchievementTabCScrollView2.csb","Player/AchievementTabCScrollView3.csb"}
    achieveList = {"achieveList1","achieveList2","achieveList3","achieveList4","achieveList5"}
    achievementList = {}
    achievements = {}
    achievementsB = {}
    achievementListCopy = nil
    isSend = false
    redPointNum = 0
    redPointNum2 = 0
    curTab = 1
    curTreeTab = 1
    tabBLoad = false
    tabALoad = false
    tabCLoad = false
    skillTable = {}
    skillTable[1] = {}
    skillTable[2] = {}
    skillTable[3] = {}
    finishSkillTable = {}
    finishSkillTable[1] = {}
    finishSkillTable[2] = {}
    finishSkillTable[3] = {}
    finishPetAchieve = {}
    grayColor = {r=88,g=88,b=88,a=255}
    treeBLoad = false
    treeALoad = false
    treeCLoad = false
    isReadSkillInfo = false

    orderString = {
        [1] = "Pet/Education/c.png",
        [2] = "Pet/Education/b.png",
        [3] = "Pet/Education/a.png",
        [4] = "Pet/Education/s.png",
        [5] = "Pet/Education/2s.png",
        [6] = "Pet/Education/3s.png",
    }
    achievementpoint = 0
    countFieldNameTable = nil
end

function AchievementListMgr.show(scene,tab)
    UIStack.push("AchievementListMgr",AchievementListMgr.hide,true)
    redPointNum = 0
    redPointNum2 = 0
    achievementList = {}
    achievements = {}
    achievementsB = {}
    curTab = tab or 1
    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG)
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480)
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    end

    local function LoadTopBar()
        if CSResourceMgr.getCsbObj(resNameTop) then
            return
        end
        local top = CSResourceMgr.createRes(scene, resNameTop)
        top:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CocosModuleMgr.setEdgeDistance(top, 0, nil, 0, nil)
        CSResourceMgr.setLabelString(resNameTop, "achieveNum", "", "", nil, -1)
        CSResourceMgr.setLabelString(resNameTop, "gcoin", CharInfo.getGCash(), "", nil, -1,100)
        CSResourceMgr.setLabelString(resNameTop, "mcoin", CharInfo.getMCash(), "", nil, -1,100)
        CSResourceMgr.setLabelColor(resNameTop, "achieveNum", {r=190,g=221,b=245,a=255})
        CSResourceMgr.setLabelColor(resNameTop, "gcoin", {r=190,g=221,b=245,a=255})
        CSResourceMgr.setLabelColor(resNameTop, "mcoin", {r=190,g=221,b=245,a=255})
        CSResourceMgr.getNodeByName(resNameTop, "up"):setVisible(false)
        CSResourceMgr.clickEventBinding(resNameTop, "close", function()
            AchievementListMgr.hide()
        end)
        CSResourceMgr.clickEventBinding(resNameTop, "add_gcoin", function()
            ExchangeViewMgr.show(scene,ExchangeViewMgr.GCASHTYPE)
        end)
        CSResourceMgr.clickEventBinding(resNameTop, "add_mcoin", function()
            PurchaseViewMgr.show(scene,AchievementListMgr.hide)
        end)
    end
    
    local function loadCSB()
        AchievementListMgr.requestInfo()

        local layer = CSResourceMgr.createRes(scene, resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        layer:setVisible(false)
        CocosModuleMgr.setEdgeDistance(layer, nil, nil, nil, 0)
        
        local diff = CocosModuleMgr.getScreenSizeDiff()
        local frame = CSResourceMgr.getNodeByName(resName, "frame")
        local fsize = frame:getContentSize()
        frame:setContentSize(fsize.width, fsize.height+diff)
        local title = CSResourceMgr.getNodeByName(resName, "title")
        local tposy = title:getPositionY()
        title:setPositionY(tposy+diff)     
        local tabs = CSResourceMgr.getNodeByName(resName, "tabs")
        local tposy = tabs:getPositionY()
        tabs:setPositionY(tposy+diff)   
        local line = CSResourceMgr.getNodeByName(resName, "line")
        local lposy = line:getPositionY()
        line:setPositionY(lposy+diff)   
        local zhendiban1 = CSResourceMgr.getNodeByName(resName, "zhendiban1")
        local zhendiban1size = zhendiban1:getContentSize()
        zhendiban1:setContentSize(zhendiban1size.width, zhendiban1size.height+diff)
        local zhendiban2 = CSResourceMgr.getNodeByName(resName, "zhendiban2")
        local zhendiban2size = zhendiban2:getContentSize()
        zhendiban2:setContentSize(zhendiban2size.width, zhendiban2size.height+diff)
        local zhendiban3 = CSResourceMgr.getNodeByName(resName, "zhendiban3")
        local zhendiban3size = zhendiban3:getContentSize()
        zhendiban3:setContentSize(zhendiban3size.width, zhendiban3size.height+diff)
        CSResourceMgr.setLabelColor(resName, "title", {r=160,g=235,b=250,a=255})
        CSResourceMgr.setLabelString(resName, "title", "achieveList1", "", {r=37,g=54,b=75,a=255})

        local potentialUnlockLv = SystemInfo.getGlobalConfigAddInfoByID(21016).values[1]

        NetInterface.sendWithBlock("GC_GetPokemonAchievements_Ack", function()
            local AchievementSend = require("src.Net.Send.AchievementSend")
            AchievementSend.sendCG_GetPokemonAchievements_Req()
            end)

        local selColor = {r=255,g=255,b=255,a=255}
        local selOutColor = {r=0,g=0,b=0,a=255,w=1}
        local unselColor = {r=82,g=82,b=82,a=255}
        local unselOutColor = {r=236,g=236,b=236,a=0}
        local tabName = {"achieveList7", "achieveList8","achieveList9"}
        for var=1, 3 do
            CSResourceMgr.clickEventBinding(resName, "tab"..var, function()
                GameAudio.playUISound("sheetClick")
                if var == 3 and potentialUnlockLv>CharInfo.getLevel() then
                    StandardTipsMgr.show(1, "train188")
                    return
                end
                CSResourceMgr.setButtonEnabled(resName, "tab"..curTab, true)
                CSResourceMgr.getNodeByName(resName, "zhendiban"..curTab):setVisible(false)
                CSResourceMgr.setButtonStringColor(resName, "tab"..curTab, unselColor)
                CSResourceMgr.setButtonString(resName, "tab"..curTab, tabName[curTab],"",unselOutColor)
                local tabbtn = CSResourceMgr.getNodeByName(resName, "tab"..curTab)
                tabbtn:setPositionY(0)
                tabbtn:setScale(1, 1)
                tabbtn:setLocalZOrder(1)
                curTab = var
                CSResourceMgr.setButtonEnabled(resName, "tab"..curTab, false)
                CSResourceMgr.getNodeByName(resName, "zhendiban"..curTab):setVisible(true)
                CSResourceMgr.setButtonStringColor(resName, "tab"..curTab, selColor)
                CSResourceMgr.setButtonString(resName, "tab"..curTab, tabName[curTab],"",selOutColor)
                local curtabbtn = CSResourceMgr.getNodeByName(resName, "tab"..curTab)
                curtabbtn:setPositionY(5)
                curtabbtn:setScale(1.1, 1.1)
                curtabbtn:setLocalZOrder(2)
                if var == 1 and not tabALoad then
                    NetInterface.sendWithBlock("GC_GetAchievements_Ack", function()
                        local AchievementSend = require("src.Net.Send.AchievementSend")
                        AchievementSend.sendCG_GetAchievements_Req()
                        end,function()
                            tabALoad = true
                        end)
                end
                if var == 2 and not tabBLoad then
                    AchievementListMgr.resetTabB()
                    tabBLoad = true
                end
                if var == 3 and not tabCLoad then
                    if not isReadSkillInfo then
                        NetInterface.sendWithBlock("GC_GetPotentials_Ack", function()
                            local AchievementSend = require("src.Net.Send.AchievementSend")
                            AchievementSend.sendCG_GetPotentials_Req()
                            end,function()
                                tabCLoad = true
                            end)
                    else
                        AchievementListMgr.resetTabC()
                        tabCLoad = true
                    end
                end
            end)
            CSResourceMgr.setButtonStringColor(resName, "tab"..var, unselColor)
            CSResourceMgr.setButtonString(resName, "tab"..var, tabName[var],"",unselOutColor)
            local tabbtn = CSResourceMgr.getNodeByName(resName, "tab"..var)
            tabbtn:setPositionY(0)
            tabbtn:setScale(1, 1)
            tabbtn:setLocalZOrder(1)
        end
        CSResourceMgr.setButtonStringColor(resName, "tab"..curTab, selColor)
        CSResourceMgr.setButtonString(resName, "tab"..curTab, tabName[curTab],"",selOutColor)
        CSResourceMgr.setButtonEnabled(resName, "tab"..curTab, false)
        CSResourceMgr.getNodeByName(resName, "zhendiban"..curTab):setVisible(true)
        local curtabbtn = CSResourceMgr.getNodeByName(resName, "tab"..curTab)
        curtabbtn:setPositionY(5)
        curtabbtn:setScale(1.1, 1.1)
        curtabbtn:setLocalZOrder(2)  
    end
    
    local function playCSB()
        CSResourceMgr.getCsbObj(resName):setVisible(true)

        NetInterface.sendWithBlock("GC_GetAchievements_Ack", function()
            local AchievementSend = require("src.Net.Send.AchievementSend")
            AchievementSend.sendCG_GetAchievements_Req()
            end,function()
                tabALoad = true
            end)
        AchievementListMgr.checkPetRedPoint()

        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resName), "up")
        AchievementListMgr.enableTopBar(true)
    end

    local funcTable = {loadBG, LoadTopBar, loadCSB, playCSB}
    UnblockLoader.load(funcTable, "AchievementListMgr.show")
end

function AchievementListMgr.reset(achievementList)
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    local parent = CSResourceMgr.getNodeByName(resName, "zhendiban1")
    local function loadCSB()
        local layer = CSResourceMgr.createRes(parent, resNameA)
        
        local diff = CocosModuleMgr.getScreenSizeDiff()
        local list = CSResourceMgr.getNodeByName(resNameA, "ListView")
        local lsize = list:getContentSize()
        list:setContentSize(lsize.width, lsize.height+diff)
    end
    local funcTable = {loadCSB}

    local charInfo = CharInfo.get()
    local function setAchievement(parent,achievementInfo,curIndex,curAchievementId,listIndex,needWait)
        local biaoti = CSResourceMgr.seekNodeByName(parent,"biaoti")
        CSResourceMgr.setLabelColorByNode(biaoti, {r=255,g=240,b=0,a=255})
        CSResourceMgr.setLabelStringByNode(biaoti, achievementInfo.name, {r=17,g=27,b=38,a=255,w=1,s=1})
        local miaoshu = CSResourceMgr.seekNodeByName(parent,"miaoshu")
        CSResourceMgr.setLabelColorByNode(miaoshu, {r=71,g=96,b=103,a=255})
        CSResourceMgr.setLabelStringByNode(miaoshu, achievementInfo.desc)
        local jinduwenzi = CSResourceMgr.seekNodeByName(parent,"jinduwenzi")
        CSResourceMgr.setLabelColorByNode(jinduwenzi, {r=255,g=255,b=255,a=255})
        -- CSResourceMgr.setLabelStringByNode(jinduwenzi, curIndex.."/5", {r=0,g=0,b=0,a=255})  
        local lingquwenzi = CSResourceMgr.seekNodeByName(parent,"lingquwenzi")
        CSResourceMgr.setLabelColorByNode(lingquwenzi, {r=255,g=255,b=255,a=255})
        local jindubiaoti = CSResourceMgr.seekNodeByName(parent,"jindubiaoti")
        CSResourceMgr.setLabelColorByNode(jindubiaoti, {r=166,g=243,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(jindubiaoti, "achieveList2", {r=12,g=27,b=38,a=255,w=1,s=1})
        for i=1,3 do
            CSResourceMgr.seekNodeByName(parent,"d"..i):setColor({r=81,g=112,b=137,a=255})
        end  
        CSResourceMgr.seekNodeByName(parent,"d4"):setColor({r=128,g=161,b=172,a=255})
        local slider = CSResourceMgr.seekNodeByName(parent, "jindutiao")
        -- slider:setPercent(curIndex*100/5)       
        local lingqu = CSResourceMgr.seekNodeByName(parent, "lingqu")
        local yidacheng = CSResourceMgr.seekNodeByName(parent, "yidacheng")
        yidacheng:loadTexture(CocosModuleMgr.getWordImage("rw_yiwancheng.png"))

        local jiangli1Num = CSResourceMgr.seekNodeByName(parent,"jiangli1Num") 
        local jiangli2Num = CSResourceMgr.seekNodeByName(parent,"jiangli2Num") 
        local waitTime = needWait and 0.8 or 0
        parent:performWithDelay(function()
            CSResourceMgr.setLabelColorByNode(jiangli1Num, {r=255,g=252,b=0,a=255})
            CSResourceMgr.setLabelStringByNode(jiangli1Num, "x"..achievementInfo.point, {r=0,g=0,b=0,a=255,w=1,s=1})
            CSResourceMgr.setLabelColorByNode(jiangli2Num, {r=255,g=255,b=255,a=255})
            CSResourceMgr.setLabelStringByNode(jiangli2Num, "x"..achievementInfo.mcash, {r=0,g=0,b=0,a=255,w=1,s=1})
            end,waitTime)
        local jiangliOne = CSResourceMgr.seekNodeByName(parent,"jiangli1") 
        local jiangliTwo = CSResourceMgr.seekNodeByName(parent,"jiangli2") 
        local function finish()
            transition.moveBy(jiangliOne, {y=50, time=0.8})
            transition.fadeOut(jiangliOne, {time=0.8})
            transition.moveBy(jiangliTwo, {y=50, time=0.8})
            transition.fadeOut(jiangliTwo, {time=0.8})
            transition.fadeOut(jiangli1Num, {time=0.8})
            transition.fadeOut(jiangli2Num, {time=0.8})
            parent:performWithDelay(function()
                transition.moveTo(jiangliOne, {x=-319, y=-77, time=0})
                transition.moveTo(jiangliTwo, {x=-188, y=-77, time=0})
                if curIndex+1 < 5 then 
                    jiangliOne:fadeIn(0)
                    jiangliTwo:fadeIn(0)
                    jiangli1Num:fadeIn(0)
                    jiangli2Num:fadeIn(0)                
                end
            end,0.8)
        end

        local xingOne = CSResourceMgr.seekNodeByName(parent,"xing1")  
        local xingTwo = CSResourceMgr.seekNodeByName(parent,"xing2") 
        local xingThree = CSResourceMgr.seekNodeByName(parent,"xing3") 
        if curIndex>=1 and  curIndex<3 then
            xingOne:setVisible(true)
        elseif curIndex>=3 and  curIndex<5 then
            xingOne:setVisible(true)
            xingThree:setVisible(true)
        elseif curIndex>=5 then
            xingOne:setVisible(true)
            xingTwo:setVisible(true)
            xingThree:setVisible(true)
            if not needWait then
                jiangliOne:setVisible(false)
                jiangliTwo:setVisible(false)
            end
        end

        achievementpoint = charInfo["achievementpoint"] or 0
        CSResourceMgr.setLabelString(resNameTop, "achieveNum", achievementpoint)

        if curIndex == 5 then
            CSResourceMgr.seekNodeByName(parent,"d1"):setVisible(false)
            CSResourceMgr.seekNodeByName(parent,"d2"):setVisible(false)
            CSResourceMgr.seekNodeByName(parent,"lingquBack"):setVisible(false)
            lingqu:setVisible(false)
            yidacheng:setVisible(true)
            local needValue = achievementInfo.num
            CSResourceMgr.setLabelStringByNode(jinduwenzi, needValue.."/"..needValue, {r=0,g=0,b=0,a=255,w=1,s=1},nil,185)  
            slider:setPercent(1*100)  
        else
            lingqu:setVisible(true)
            yidacheng:setVisible(false)
            local curValue = charInfo[achievementInfo.countFieldName] or 0
            if achievementInfo.countFieldName == "zldj1" then
                curValue = StatusBarMgr.getTotalFightPoint(PetFormationMgr.getCurTab())
            elseif achievementInfo.countFieldName == "hdsj" then
                curValue = FriendsViewMgr.getFriendNum()
            end
            local needValue = achievementInfo.num
            CSResourceMgr.setLabelStringByNode(jinduwenzi, curValue.."/"..needValue, {r=0,g=0,b=0,a=255,w=1,s=1},nil,185) 
            local sliderValue = curValue*100/needValue
            slider:setPercent(sliderValue>100 and 100 or sliderValue)   
            if curValue<needValue then 
                CSResourceMgr.setButtonEnabledByNode(lingqu, false)
                CSResourceMgr.setLabelStringByNode(lingquwenzi, "achieveList3", {r=63,g=63,b=63,a=255,w=1,s=1})
            else
                redPointNum = redPointNum + 1
                CSResourceMgr.setButtonEnabledByNode(lingqu, true)
                CSResourceMgr.setLabelStringByNode(lingquwenzi, "achieveList3", {r=36,g=98,b=5,a=255,w=1,s=1})
                CSResourceMgr.clickEventBindingByNode(lingqu, function()
                    NetInterface.sendWithBlock("GC_FinishAchievement_Ack", function()
                    local AchievementSend = require("src.Net.Send.AchievementSend")
                    AchievementSend.sendCG_FinishAchievement_Req({achievementID = curAchievementId})
                    end,function()
                        GameAudio.playUISound("reward")
                        finish()
                        NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
                            local LoginSend = require("src.Net.Send.LoginSend")
                            LoginSend.sendCG_GetCharacterValues_Req({"achievementPoint"})
                            end)
                        redPointNum = redPointNum - 1
                        CSResourceMgr.getNodeByName(resName,"redPoint1"):setVisible(redPointNum>0)
                        if curIndex+1 < 5 then
                            local achievementInfo = AchievementInfo.getAchievementInfoById(curAchievementId+1)
                            setAchievement(parent,achievementInfo,curIndex+1,curAchievementId+1,listIndex,true)
                        else
                            local achievementInfo = AchievementInfo.getAchievementInfoById(curAchievementId)
                            setAchievement(parent,achievementInfo,curIndex+1,curAchievementId,listIndex,true)
                        end
                        if achievementListCopy then
                            achievementListCopy[listIndex][curIndex] = curAchievementId
                        end
                        TipsMgr.show(scene, "achieveList6")
                    end)
                end)
            end
        end
    end
    

    local finishTable = {}
    local cantTakeTable = {}
    local lingquTable = {}
    local achievementListInfo = AchievementInfo.getClientAchievementListInfo()

    for k,achievementIds in pairs(achievementListInfo) do
        if not achievementList[k] then
            achievementList[k] = {}
        end
        local curIndex = #achievementList[k] 
        local curAchievementId = 0
        if curIndex < 5 then
            curAchievementId = achievementIds[curIndex+1]
        else
            curAchievementId = achievementIds[curIndex]
        end
        local achievementInfo = AchievementInfo.getAchievementInfoById(curAchievementId)
        local charInfo = CharInfo.get()
        local curValue = charInfo[achievementInfo.countFieldName] or 0
        if achievementInfo.countFieldName == "zldj1" then
            curValue = StatusBarMgr.getTotalFightPoint(PetFormationMgr.getCurTab())
        elseif achievementInfo.countFieldName == "hdsj" then
            curValue = FriendsViewMgr.getFriendNum()
        end
        local needValue = achievementInfo.num
        if achievementInfo.isVisable==1 then
            if curIndex == 5 then
                table.insert(finishTable,function()
                    local list = CSResourceMgr.getNodeByName(resNameA, "ListView")
                    achievements[k] = CSResourceMgr.getNodeByName(resNameA, "cj"):clone()
                    achievements[k]:setCascadeOpacityEnabled(true)
                    list:pushBackCustomItem(achievements[k])
                    achievements[k]:setVisible(true)
                    achievements[k]:setScaleY(0)
                    transition.scaleTo(achievements[k], {scale=1, time=0.2})
                    setAchievement(achievements[k],achievementInfo,curIndex,curAchievementId,k,false)
                    end)
            elseif curValue<needValue then 
                table.insert(cantTakeTable,function()
                    local list = CSResourceMgr.getNodeByName(resNameA, "ListView")
                    achievements[k] = CSResourceMgr.getNodeByName(resNameA, "cj"):clone()
                    achievements[k]:setCascadeOpacityEnabled(true)
                    list:pushBackCustomItem(achievements[k])
                    achievements[k]:setVisible(true)
                    achievements[k]:setScaleY(0)
                    transition.scaleTo(achievements[k], {scale=1, time=0.2})
                    setAchievement(achievements[k],achievementInfo,curIndex,curAchievementId,k,false)
                    end)
            else
                table.insert(lingquTable,function()
                    local list = CSResourceMgr.getNodeByName(resNameA, "ListView")
                    achievements[k] = CSResourceMgr.getNodeByName(resNameA, "cj"):clone()
                    achievements[k]:setCascadeOpacityEnabled(true)
                    list:pushBackCustomItem(achievements[k])
                    achievements[k]:setVisible(true)
                    achievements[k]:setScaleY(0)
                    transition.scaleTo(achievements[k], {scale=1, time=0.2})
                    setAchievement(achievements[k],achievementInfo,curIndex,curAchievementId,k,false)
                    end)
            end
        end
    end

    for k,v in pairs(finishTable) do
        table.insert(funcTable,v)
    end

    for k,v in pairs(lingquTable) do
        table.insert(funcTable,v)
    end

    for k,v in pairs(cantTakeTable) do
        table.insert(funcTable,v)
    end

    CSResourceMgr.getNodeByName(resName,"redPoint1"):setVisible(#lingquTable>0)

    UnblockLoader.load(funcTable, "AchievementListMgr.showB")
end

function AchievementListMgr.resetTabB()
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    isHavePokeInfoLst = AchievementListMgr.initPokeMonDataInfo()
    local parent = CSResourceMgr.getNodeByName(resName, "zhendiban2")
    local function loadCSB()
        local layer = CSResourceMgr.createRes(parent, resNameB)
        
        local diff = CocosModuleMgr.getScreenSizeDiff()
        local list = CSResourceMgr.getNodeByName(resNameB, "ListView")
        local lsize = list:getContentSize()
        list:setContentSize(lsize.width, lsize.height+diff)
    end
    local funcTable = {loadCSB}

    local function setButtonGray(parent)
        parent:setColor(grayColor)
        CSResourceMgr.seekNodeByName(parent,"petIcon"):setColor(grayColor)
        -- CSResourceMgr.seekNodeByName(parent,"attrBack"):setColor(grayColor)
        CSResourceMgr.seekNodeByName(parent,"attr"):setColor(grayColor)
        -- CSResourceMgr.seekNodeByName(parent,"rareBack"):setColor(grayColor)
        CSResourceMgr.seekNodeByName(parent,"rare"):setColor(grayColor)
        -- CSResourceMgr.seekNodeByName(parent,"name"):setColor(grayColor)
    end

    local function setAchievement(parent,pokemonAchievementInfo)
        local isFinish = AchievementListMgr.isFinishPetAchieve(pokemonAchievementInfo.id)
        local biaoti = CSResourceMgr.seekNodeByName(parent,"biaoti")
        CSResourceMgr.setLabelColorByNode(biaoti, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(biaoti, pokemonAchievementInfo.name, {r=0,g=0,b=0,a=255,w=1,s=1})
        local jiangliwenzi = CSResourceMgr.seekNodeByName(parent,"jiangliwenzi")  
        CSResourceMgr.setLabelColorByNode(jiangliwenzi, {r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(jiangliwenzi, "achieveList2",{r=0,g=0,b=0,a=255})     
        local lingqu = CSResourceMgr.seekNodeByName(parent, "lingqu")
        CSResourceMgr.setButtonStringColorByNode(lingqu, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setButtonStringByNode(lingqu, "achieveList3", {r=45,g=61,b=0,a=255,w=1})
        CSResourceMgr.seekNodeByName(parent,"db2"):setColor({r=5,g=23,b=43,a=255})
        local yidacheng = CSResourceMgr.seekNodeByName(parent, "yidacheng")
        yidacheng:loadTexture(CocosModuleMgr.getWordImage("rw_yiwancheng.png"))
        yidacheng:setVisible(false)
        for k,v in pairs(pokemonAchievementInfo.petIDs) do
            local pokemonInfo = PokemonInfo.getPokemonInfoByID(v)
            local pet = CSResourceMgr.seekNodeByName(parent, "pet"..k)
            pet:setVisible(true)
            local petIcon = CSResourceMgr.seekNodeByName(pet, "petIcon")
            CSResourceMgr.setSpriteTextureByNode(petIcon, "Pet/PetIcon/"..pokemonInfo.icon..".png")
            petIcon:setScale(0.9,0.9)
            pet:loadTexture("Pet/BasicPetList_2/Stage/"..pokemonInfo.rarePoint..".png")
            CSResourceMgr.seekNodeByName(pet,"rare"):loadTexture(orderString[pokemonInfo.rarePoint])
            local icon1 = "UI/CommonFiles/"..pokemonInfo.elementAtt1..".png"
            -- local icon2 = "Pet/AttriIcon/small_"..pokemonInfo.elementAtt1..".png"
            CSResourceMgr.seekNodeByName(pet,"attr"):loadTexture(icon1)
            -- CSResourceMgr.seekNodeByName(pet,"attrBack"):loadTexture(icon2)
            local name = CSResourceMgr.seekNodeByName(pet, "name")
            CSResourceMgr.setLabelColorByNode(name, PokemonInfo.COLOR[pokemonInfo.rarePoint])
            CSResourceMgr.setLabelStringByNode(name, pokemonInfo.name) 
            if not AchievementListMgr.isHavePet(v) then
                if not isFinish then
                    setButtonGray(pet)
                end
                CSResourceMgr.setButtonEnabledByNode(lingqu, false)
                CSResourceMgr.setButtonStringByNode(lingqu, "achieveList3", {r=63,g=63,b=63,a=255,w=1,s=1})
            end
            local petBtn = CSResourceMgr.seekNodeByName(parent,  "pet"..k.."Btn")
            CSResourceMgr.clickEventBindingByNode(petBtn, function()
                PetInfoViewMgr.show(SceneMgr.getRunningScene, v)
                end,3)
        end
        local charInfo = CharInfo.get()
        achievementpoint = charInfo["achievementpoint"] or 0
        CSResourceMgr.setLabelString(resNameTop, "achieveNum", achievementpoint)
        if isFinish then
            lingqu:setVisible(false)
            yidacheng:setVisible(true)
            CSResourceMgr.seekNodeByName(parent,"jiangli"):setVisible(false)
        else
            local jiangli1Num = CSResourceMgr.seekNodeByName(parent,"jiangli1Num") 
            local jiangli2Num = CSResourceMgr.seekNodeByName(parent,"jiangli2Num") 
            local waitTime = needWait and 0.8 or 0
            parent:performWithDelay(function()
                CSResourceMgr.setLabelColorByNode(jiangli1Num, {r=255,g=252,b=0,a=255})
                CSResourceMgr.setLabelStringByNode(jiangli1Num, "x"..pokemonAchievementInfo.point, {r=0,g=0,b=0,a=255,w=1,s=1})
                CSResourceMgr.setLabelColorByNode(jiangli2Num, {r=255,g=255,b=255,a=255})
                CSResourceMgr.setLabelStringByNode(jiangli2Num, "x"..pokemonAchievementInfo.mcash, {r=0,g=0,b=0,a=255,w=1,s=1})
                end,waitTime)
            local jiangliOne = CSResourceMgr.seekNodeByName(parent,"jiangli1") 
            local jiangliTwo = CSResourceMgr.seekNodeByName(parent,"jiangli2") 
            local function finish()
                lingqu:setVisible(false)
                yidacheng:setVisible(true)
                transition.moveBy(jiangliOne, {y=50, time=0.8})
                transition.fadeOut(jiangliOne, {time=0.8})
                transition.moveBy(jiangliTwo, {y=50, time=0.8})
                transition.fadeOut(jiangliTwo, {time=0.8})
                transition.fadeOut(jiangli1Num, {time=0.8})
                transition.fadeOut(jiangli2Num, {time=0.8})
                CSResourceMgr.seekNodeByName(parent,"jiangliwenzi"):setVisible(false)
                parent:performWithDelay(function()
                    CSResourceMgr.seekNodeByName(parent,"jiangli"):setVisible(false)
                end,0.8)
            end
            CSResourceMgr.clickEventBindingByNode(lingqu, function()
                NetInterface.sendWithBlock("GC_FinishPokemonAchievement_Ack", function()
                    local AchievementSend = require("src.Net.Send.AchievementSend")
                    AchievementSend.sendCG_FinishPokemonAchievement_Req({pokeAchievementID = pokemonAchievementInfo.id})
                    end,function()
                        redPointNum2 = redPointNum2 - 1
                        CSResourceMgr.getNodeByName(resName,"redPoint2"):setVisible(redPointNum2>0)
                        TaskWatcherManager.saveCompleteCWChengjiu()
                        GameAudio.playUISound("reward")
                        finish()
                        table.insert(finishPetAchieve,pokemonAchievementInfo.id)
                        achievementpoint = achievementpoint + pokemonAchievementInfo.point
                        CSResourceMgr.setLabelString(resNameTop, "achieveNum", achievementpoint)
                    end)
                end)
        end
    end

    local pokemonAchievementCount = AchievementInfo.getPokemonAchievementInfoCount()
    for i=1,pokemonAchievementCount do
        table.insert(funcTable,function()
            local pokemonAchievementInfo = AchievementInfo.getPokemonAchievementInfoById(i)
            local list = CSResourceMgr.getNodeByName(resNameB, "ListView")
            achievementsB[i] = CSResourceMgr.getNodeByName(resNameB, "cj"):clone()
            achievementsB[i]:setCascadeOpacityEnabled(true)
            list:pushBackCustomItem(achievementsB[i])
            achievementsB[i]:setVisible(true)
            achievementsB[i]:setScaleY(0)
            transition.scaleTo(achievementsB[i], {scale=1, time=0.2})
            setAchievement(achievementsB[i],pokemonAchievementInfo)
        end)
    end
    UnblockLoader.load(funcTable, "AchievementListMgr.showC")
end

function AchievementListMgr.resetTabC()
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    local parent = CSResourceMgr.getNodeByName(resName, "zhendiban3")
    local function loadCSB()
        local layer = CSResourceMgr.createRes(parent, resNameC)

        local diff = CocosModuleMgr.getScreenSizeDiff()
        for i=1,3 do
            local Panel = CSResourceMgr.getNodeByName(resNameC, "Panel"..i)
            local psize = Panel:getContentSize()
            Panel:setContentSize(psize.width, psize.height+diff)
        end
        local diban = CSResourceMgr.getNodeByName(resNameC, "diban")
        local dsize = diban:getContentSize()
        diban:setContentSize(dsize.width, dsize.height+diff)
        local frame = CSResourceMgr.getNodeByName(resNameC, "frame")
        local fsize = frame:getContentSize()
        frame:setContentSize(fsize.width, fsize.height+diff)
        local tabs = CSResourceMgr.getNodeByName(resNameC,"tabs")
        local tposy = tabs:getPositionY()
        tabs:setPositionY(tposy+diff)
        local decor = CSResourceMgr.getNodeByName(resNameC,"decor")
        local dposy = decor:getPositionY()
        decor:setPositionY(dposy+diff)
        local resetBtn = CSResourceMgr.getNodeByName(resNameC,"resetBtn")
        local rposy = resetBtn:getPositionY()
        resetBtn:setPositionY(rposy+diff)
        local desc = CSResourceMgr.getNodeByName(resNameC,"desc")
        local dposy = desc:getPositionY()
        desc:setPositionY(dposy+diff)
        CSResourceMgr.setLabelString(resNameC, "desc", "DebutSkillsRules")
        CSResourceMgr.setButtonStringColorByNode(resetBtn, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setButtonStringByNode(resetBtn, "skillReset1",{r=0,g=0,b=0,a=255,w=1,s=1})

        local charInfo = CharInfo.get()
        achievementpoint = charInfo["achievementpoint"] or 0
        CSResourceMgr.setLabelString(resNameTop, "achieveNum", achievementpoint)

        local unLockPath1 = {"UI/CommonFiles/atk_trough_red_light_02.png","UI/CommonFiles/def_trough_blue_light_02.png","UI/CommonFiles/aid_trough_green_light_02.png"}
        local unLockPath2 = {"UI/CommonFiles/atk_trough_red_light_01.png","UI/CommonFiles/def_trough_blue_light_01.png","UI/CommonFiles/aid_trough_green_light_01.png"}
        local backPath = {"UI/CommonFiles/skill_atk_base_red_02.png","UI/CommonFiles/skill_def_base_blue_02.png","UI/CommonFiles/skill_aid_base_green_02.png"}
        local backPath2 = {"UI/CommonFiles/skill_atk_base_red_01.png","UI/CommonFiles/skill_def_base_blue_01.png","UI/CommonFiles/skill_aid_base_green_01.png"}

        --id = 100*t+i
        local function setScrollView(t)
            local Panel = CSResourceMgr.getNodeByName(resNameC, "Panel"..t)
            local scrollviewLayer = CSResourceMgr.createRes(Panel, scrollViewRes[t])
            local scrollview = CSResourceMgr.getNodeByName(scrollViewRes[t], "scrollview")
            local scrollwidth = scrollview:getContentSize().width
            local oringinheight = scrollview:getContentSize().height
            local scrollheight = oringinheight+diff
            scrollview:setContentSize(scrollwidth, scrollheight)
            scrollview:setVisible(true)
            scrollview:setOpacity(0)
            transition.fadeIn(scrollview, {time=0.3})
            local index = 1
            for i=1,AchievementInfo.getPotentialInfoCount() do
                local id = PotentialInfoConfig.getEntryID(i)
                local potentialInfo = AchievementInfo.getPotentialInfoById(id)
                if not potentialInfo then
                    break
                end
                if id<=100+t*100 and id>t*100 then
                    local skill = CSResourceMgr.seekNodeByName(scrollview,"skill"..index)
                    skillTable[t][id] = skill
                    local skillIcon = CSResourceMgr.seekNodeByName(skill,"icon"..index)
                    CSResourceMgr.setSpriteTextureByNode(skillIcon, potentialInfo.icon and "Battle/skillIcon/"..potentialInfo.icon or "empty.png")
                    skillIcon:setScale(0.8,0.8)
                    local num = CSResourceMgr.seekNodeByName(skill,"num")
                    CSResourceMgr.setLabelColorByNode(num, {r=255,g=255,b=255,a=255})
                    CSResourceMgr.setLabelStringByNode(num, potentialInfo.point)
                    skill:setColor(grayColor)
                    local back1 = CSResourceMgr.seekNodeByName(skill,"iconBG")
                    CSResourceMgr.setSpriteTextureByNode(back1, backPath2[curTreeTab])
                    CSResourceMgr.setButtonTextureByNode(skill, backPath[curTreeTab], backPath[curTreeTab], backPath[curTreeTab])

                    if AchievementListMgr.isFinishSkill(id) then
                        local tab = math.floor(id/100)
                        skill:setColor({r=255,g=255,b=255,a=255})
                        local arrow = CSResourceMgr.seekNodeByName(skill,"arrow")
                        local arrows = arrow:getChildren()
                        if #arrows==2 then
                            for k,v in pairs(arrows) do
                                CSResourceMgr.setSpriteTextureByNode(v,unLockPath2[tab])
                                v:setCapInsets({x = 20,y = 20,width = 4,height = 4})
                            end
                        elseif #arrows==1 then
                            for k,v in pairs(arrows) do
                                CSResourceMgr.setSpriteTextureByNode(v,unLockPath1[tab])
                            end
                        end
                    end

                    CSResourceMgr.clickEventBindingByNode(skill,function()
                        local operable = AchievementListMgr.canBuySkill(id)
                        local canBuy = achievementpoint>=potentialInfo.point
                        AchievementListMgr.showSkillInfo(potentialInfo,operable,canBuy,function()
                        NetInterface.sendWithBlock("GC_BuyPotential_Ack", function()
                            local AchievementSend = require("src.Net.Send.AchievementSend")
                            AchievementSend.sendCG_BuyPotential_Req({potentialID = id})
                            end,function()
                                TaskWatcherManager.saveAddOneQianLiDian()
                                table.insert(finishSkillTable[t],id)
                                achievementpoint = achievementpoint - potentialInfo.point
                                CSResourceMgr.setLabelString(resNameTop, "achieveNum", achievementpoint)
                                skill:setColor({r=255,g=255,b=255,a=255})
                                local arrow = CSResourceMgr.seekNodeByName(skill,"arrow")
                                local arrows = arrow:getChildren()
                                if #arrows==2 then
                                    for k,v in pairs(arrows) do
                                        CSResourceMgr.setSpriteTextureByNode(v,unLockPath2[curTreeTab])
                                        v:setCapInsets({x = 20,y = 20,width = 4,height = 4})
                                    end
                                elseif #arrows==1 then
                                    for k,v in pairs(arrows) do
                                        CSResourceMgr.setSpriteTextureByNode(v,unLockPath1[curTreeTab])
                                    end
                                end
                            end)
                        end)
                    end)
                index = index + 1
                end
            end
        end
        local selColor = {r=255,g=243,b=227,a=255}
        local selOutColor = {r=89,g=47,b=5,a=255}
        local unselColor = {r=227,g=233,b=255,a=255}
        local unselOutColor = {r=10,g=22,b=65,a=0}
        local tabName = {"achieveList10", "achieveList11","achieveList12"}
        for var=1, 3 do
            CSResourceMgr.clickEventBinding(resNameC, "tab"..var, function()
                GameAudio.playUISound("sheetClick")
                CSResourceMgr.setButtonEnabled(resNameC, "tab"..curTreeTab, true)
                CSResourceMgr.setButtonStringColor(resNameC, "tab"..curTreeTab, unselColor)
                CSResourceMgr.getNodeByName(resNameC, "Panel"..curTreeTab):setVisible(false)
                CSResourceMgr.setButtonString(resNameC, "tab"..curTreeTab, tabName[curTreeTab],"",unselOutColor)
                local tabbtn = CSResourceMgr.getNodeByName(resNameC, "tab"..curTreeTab)
                tabbtn:setPositionY(0)
                -- tabbtn:setScale(1, 1)
                tabbtn:setLocalZOrder(1)
                curTreeTab = var
                CSResourceMgr.setButtonEnabled(resNameC, "tab"..curTreeTab, false)
                CSResourceMgr.setButtonStringColor(resNameC, "tab"..curTreeTab, selColor)
                CSResourceMgr.getNodeByName(resNameC, "Panel"..curTreeTab):setVisible(true)
                CSResourceMgr.setButtonString(resNameC, "tab"..curTreeTab, tabName[curTreeTab],"",selOutColor)
                local curtabbtn = CSResourceMgr.getNodeByName(resNameC, "tab"..curTreeTab)
                curtabbtn:setPositionY(5)
                -- curtabbtn:setScale(1.1, 1.1)
                curtabbtn:setLocalZOrder(2)
                if curTreeTab==1 and not treeALoad then
                    setScrollView(curTreeTab)
                    treeALoad = true
                end
                if curTreeTab==2 and not treeBLoad then
                    setScrollView(curTreeTab)
                    treeBLoad = true
                end
                if curTreeTab==3 and not treeCLoad then
                    setScrollView(curTreeTab)
                    treeCLoad = true
                end
            end)
            CSResourceMgr.setButtonStringColor(resNameC, "tab"..var, unselColor)
            CSResourceMgr.setButtonString(resNameC, "tab"..var, tabName[var],"",unselOutColor)
            local tabbtn = CSResourceMgr.getNodeByName(resNameC, "tab"..var)
            tabbtn:setPositionY(0)
            -- tabbtn:setScale(1, 1)
            tabbtn:setLocalZOrder(1)
        end
        CSResourceMgr.setButtonStringColor(resNameC, "tab"..curTreeTab, selColor)
        CSResourceMgr.setButtonString(resNameC, "tab"..curTreeTab, tabName[curTreeTab],"",selOutColor)
        CSResourceMgr.setButtonEnabled(resNameC, "tab"..curTreeTab, false)
        CSResourceMgr.getNodeByName(resNameC, "Panel"..curTreeTab):setVisible(true)
        local curtabbtn = CSResourceMgr.getNodeByName(resNameC, "tab"..curTreeTab)
        curtabbtn:setPositionY(5)
        -- curtabbtn:setScale(1.1, 1.1)
        curtabbtn:setLocalZOrder(2) 

        setScrollView(curTreeTab)
        treeALoad = true

        CSResourceMgr.clickEventBindingByNode(resetBtn,function()
            AchievementListMgr.showResetSkill()
        end)
    end

    loadCSB()
end

function AchievementListMgr.requestInfo()
    local fieldNameList = {}
    local achievementListInfo = AchievementInfo.getClientAchievementListInfo()
    for k,achievementId in pairs(achievementListInfo) do
         local achievementInfo = AchievementInfo.getAchievementInfoById(achievementId[1])
         table.insert(fieldNameList, achievementInfo.countFieldName)
    end
    table.insert(fieldNameList, "achievementPoint")
    table.insert(fieldNameList, "ResetAchievementCount")
    NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
                local LoginSend = require("src.Net.Send.LoginSend")
                LoginSend.sendCG_GetCharacterValues_Req(fieldNameList)
                end)
end

function AchievementListMgr.hide()
    UIStack.pop("AchievementListMgr")
    AchievementListMgr.enableTopBar(false)
    UnblockLoader.cancel("AchievementListMgr.show")
    UnblockLoader.cancel("AchievementListMgr.showB")
    UnblockLoader.cancel("AchievementListMgr.showC")
    CSResourceMgr.removeList(resNameA, "ListView")
    CSResourceMgr.removeList(resNameB, "ListView")
    achievementListCopy = achievementList
    achievements = {}
    achievementsB = {}
    achievementList = {}
    tabBLoad = false
    tabALoad = false
    tabCLoad = false
    curTab = 1
    curTreeTab = 1
    skillTable = {}
    skillTable[1] = {}
    skillTable[2] = {}
    skillTable[3] = {}
    treeBLoad = false
    treeALoad = false
    treeCLoad = false

    if redPointNum == 0 and redPointNum2 == 0 then
        StatusBarMgr.hideRedPoint(3)
    else
        StatusBarMgr.addRedPoint(3)
    end
    GameGuideMgr.checkProcess()
    -- for i=1,3 do
    --     CSResourceMgr.removeCSObjectByTag(scrollViewRes[i])
    -- end
    CSResourceMgr.removeCSObjectByTag(resName)
    CSResourceMgr.removeCSObjectByTag(resNameA)
    CSResourceMgr.removeCSObjectByTag(resNameB)
    CSResourceMgr.removeCSObjectByTag(resNameC)
    CSResourceMgr.removeCSObjectByTag(resNameBG)
    CSResourceMgr.removeCSObjectByTag(resNameE)
    GameAudio.playUISound("retract")
end

function AchievementListMgr.setAchievementIDs(achievementIDs)
    for k,achievementID in pairs(achievementIDs) do
        local index =  math.floor((achievementID-1000)/5) + 1
        if not achievementList[index] then
            achievementList[index] = {}
        end
        achievementList[index][#achievementList[index]+1] = achievementID
    end
    achievementListCopy = achievementList
    if isWaitCheck then
        AchievementListMgr.checkAchieveOK(countFieldName)
        isWaitCheck = false
    end
    AchievementListMgr.reset(achievementList)
end

function AchievementListMgr.isThisAchievementOK(countFieldName)
    if not countFieldNameTable then
        countFieldNameTable = {}
        local allAchieve = AchievementInfo.getClientAchievementListInfo()
        for k,v in pairs(allAchieve) do
            local name = AchievementInfo.getAchievementInfoById(v[1]).countFieldName
            countFieldNameTable[name] = name
        end
    end
    if not countFieldNameTable[countFieldName] then
        return
    end
    if not achievementListCopy and not CSResourceMgr.getCsbObj(resName) and not isSend then
        isSend = true
        NetInterface.sendWithBlock("GC_GetAchievements_Ack", function()
            local AchievementSend = require("src.Net.Send.AchievementSend")
            AchievementSend.sendCG_GetAchievements_Req()
            end,function()
                isWaitCheck = true
            end)
    elseif not achievementListCopy then
        isWaitCheck = true
    else
        AchievementListMgr.checkAchieveOK(countFieldName)
    end
end

function AchievementListMgr.checkAchieveOK(countFieldName)
    local allAchieve = AchievementInfo.getClientAchievementListInfo()
    for k,v in pairs(allAchieve) do
        if AchievementInfo.getAchievementInfoById(v[1]).isVisable==0 then
            return false
        end
        if AchievementInfo.getAchievementInfoById(v[1]).countFieldName == countFieldName then
            if AchievementInfo.getAchievementInfoById(v[1]).isVisable==0 then
                return false
            end
            local index =  math.floor((v[1]-1000)/5) + 1
            if not achievementListCopy[index] then
                achievementListCopy[index] = {}
            end
            if #achievementListCopy[index] == 5 then
                return false
            end
            local currentAchieveID = 0
            if achievementListCopy[index][#achievementListCopy[index]] then
                currentAchieveID = achievementListCopy[index][#achievementListCopy[index]]+1
            else
                currentAchieveID = v[1]
            end
            local curAchievementInfo = AchievementInfo.getAchievementInfoById(currentAchieveID)
            local needValue = curAchievementInfo.num
            local charInfo = CharInfo.get()
            local curValue = charInfo[curAchievementInfo.countFieldName] or 0
            if curValue>=needValue then
                StatusBarMgr.addRedPoint(3)
                return true
            end
        end
    end
    return false
end

function AchievementListMgr.finishAchieveNum()
    local num = 0
    for k,v in pairs(achievementList) do
        for kk,vv in pairs(v) do
            num = num + 1
        end
    end
    return num
end

function AchievementListMgr.isHavePet(petID)
    local petWiki = PetHandBook.getPetWikiInfoLst()
    if not isHavePokeInfoLst then
        isHavePokeInfoLst = AchievementListMgr.initPokeMonDataInfo()
    end
    if petWiki[petID] or isHavePokeInfoLst[petID] then
        return true
    end
    return false
end

function AchievementListMgr.setFinishPetAchieve(pokeAchievementIDs)
    finishPetAchieve = pokeAchievementIDs
end

function AchievementListMgr.checkPetRedPoint()
    local pokemonAchievementCount = AchievementInfo.getPokemonAchievementInfoCount()
    redPointNum2 = pokemonAchievementCount
    for i=1,pokemonAchievementCount do
        local pokemonAchievementInfo = AchievementInfo.getPokemonAchievementInfoById(i)
        local isFinish = AchievementListMgr.isFinishPetAchieve(pokemonAchievementInfo.id)
        if isFinish then
            redPointNum2 = redPointNum2 -1
        else
            for k,v in pairs(pokemonAchievementInfo.petIDs) do
                local pokemonInfo = PokemonInfo.getPokemonInfoByID(v)
                if not AchievementListMgr.isHavePet(v) then
                    redPointNum2 = redPointNum2 -1
                    break
                end
            end
        end
    end

    CSResourceMgr.getNodeByName(resName,"redPoint2"):setVisible(redPointNum2>0)
end

function AchievementListMgr.isFinishPetAchieve(pokeAchievementID)
    for k,v in pairs(finishPetAchieve) do
        if v == pokeAchievementID then
            return true
        end
    end
    return false
end

function AchievementListMgr.setFinishSkill(potentials)
    finishSkillTable = {}
    finishSkillTable[1] = {}
    finishSkillTable[2] = {}
    finishSkillTable[3] = {}
    for k,v in pairs(potentials) do
        local tab = math.floor(v/100)
        table.insert(finishSkillTable[tab],v)
    end
    isReadSkillInfo = true
    if CSResourceMgr.getCsbObj(resName) then
        AchievementListMgr.resetTabC()
    end
end

function AchievementListMgr.isFinishSkill(potentialID)
    local tab = math.floor(potentialID/100)
    for k,v in pairs(finishSkillTable[tab]) do
        if v == potentialID then
            return true
        end
    end
    return false
end

function AchievementListMgr.canBuySkill(id)
    for k,v in pairs(AchievementInfo.getPotentialInfoById(id).parents) do
        if not AchievementListMgr.isFinishSkill(v) then
            return false
        end
    end
    if AchievementListMgr.isFinishSkill(id) then
        return false
    end
    return true
end

function AchievementListMgr.showSkillInfo(potentialInfo,operable,canBuy,callback)
    local function close()
        UIStack.pop("AchievementListMgr.showSkillInfo")
        AchievementListMgr.enableTopBar(true)
        CSResourceMgr.removeCSObjectByTag(resNameD)
        UnblockLoader.cancel("AchievementListMgr.showSkillInfo")
    end
    UIStack.push("AchievementListMgr.showSkillInfo",function()
        close()
    end,false)
    AchievementListMgr.enableTopBar(false)
    local function loadCSB()
        local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameD)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resNameD, 320, 480)
        CSResourceMgr.clickEventBinding(resNameD,"btn_close",function()
            close()
        end)
        CSResourceMgr.clickEventBinding(resNameD,"btn",function()
            close()
        end)
        layer:setVisible(false)
    end
    local function loadUI()
        local skillIcon     = potentialInfo.icon and "Battle/skillIcon/"..potentialInfo.icon or "empty.png"
        local panel         = CSResourceMgr.getNodeByName(resNameD, "btn")
        local panel1        = CSResourceMgr.getNodeByName(resNameD, "panel1")
        local title         = CSResourceMgr.seekNodeByName(panel1, "name")
        local skill_Icon     = CSResourceMgr.seekNodeByName(panel1, "skillIcon")
        local skillName     = CSResourceMgr.seekNodeByName(panel1, "skill_name")
        local type_title    = CSResourceMgr.seekNodeByName(panel1, "type_title")
        local skillInfoTitle= CSResourceMgr.seekNodeByName(panel1, "skill_info_title")
        local skillDesc     = CSResourceMgr.seekNodeByName(panel1, "skill_info")
        local btnLearn   = CSResourceMgr.seekNodeByName(panel1, "btn_learn")

        CSResourceMgr.setSpriteTextureByNode(skill_Icon, skillIcon)
        CSResourceMgr.setLabelStringByNode(title, "train45", nil, 1, 264)
        CSResourceMgr.setLabelStringByNode(skillInfoTitle, "AchieveSkill3", nil, 1, 110)
        CSResourceMgr.setButtonStringByNode(btnLearn, "train80", {r=0,g=0,b=0,a=255,w=1,s=1})
        CSResourceMgr.setLabelStringByNode(skillDesc, potentialInfo.desc)
        CSResourceMgr.setLabelStringByNode(skillName, potentialInfo.name)

        local tabName = {"achieveList10", "achieveList11","achieveList12"}
        CSResourceMgr.setLabelColorByNode(type_title, {r=144,g=238,b=255,a=255,w=1})
        CSResourceMgr.setLabelStringByNode(type_title, tabName[potentialInfo.potentialType],{r=12,g=27,b=38,a=255,w=1,s=1})

        local sameColorStr1 = {title,skillInfoTitle}
        for k,v in pairs(sameColorStr1) do
            CSResourceMgr.setLabelColorByNode(v, {r=144,g=238,b=255,a=255,w=1})
        end

        if operable then
            CSResourceMgr.clickEventBindingByNode(btnLearn, function ()
                    if callback then
                        callback()
                    end
                    close()
                end)
        else
            CSResourceMgr.getNodeByName(resNameD, "background1"):setContentSize(590, 450)
            btnLearn:setVisible(false)
        end
        CSResourceMgr.setButtonEnabledByNode(btnLearn,canBuy)
    end
    local function playAction()
        CSResourceMgr.getCsbObj(resNameD):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resNameD, "panel1"), "down")
    end

    local funcTable = {loadCSB, loadUI, playAction}
    UnblockLoader.load(funcTable,"AchievementListMgr.showSkillInfo")
end

function AchievementListMgr.enableTopBar(enabled)
    if CSResourceMgr.getCsbObj(resNameTop) then
        local node = CSResourceMgr.getNodeByName(resNameTop, "up")
        if enabled then
            node:setVisible(true)
            transition.moveTo(node, {y=151, time=0.2})
        else
            node:setPositionY(230)
            node:setVisible(false)
        end
    end
end

function AchievementListMgr.getSkillUpInfo(effect)
    local skillUpID = 0
    local skillNum = 0
    local upInfo = nil
    for k,v in pairs(finishSkillTable[3]) do
        local potentialInfo = AchievementInfo.getPotentialInfoById(v)
        if potentialInfo.effect == effect then
            if v>skillUpID then
                skillUpID = v
                upInfo = potentialInfo
            end
            skillNum = skillNum + 1
        end
    end
    return upInfo,skillNum
end

function AchievementListMgr.getAttackSkillIDs()
    local attackSkillTable = {}
    local attackSkillIDs = {}
    for i=1,2 do
        for k,v in pairs(finishSkillTable[i]) do
            local potentialInfo = AchievementInfo.getPotentialInfoById(v)
            if not attackSkillTable[potentialInfo.effect] then
                attackSkillTable[potentialInfo.effect] = v
            else
                if attackSkillTable[potentialInfo.effect]<v then
                    attackSkillTable[potentialInfo.effect] = v
                end
            end
        end
    end
    for k,v in pairs(attackSkillTable) do
        table.insert(attackSkillIDs,v)
    end
    return attackSkillIDs
end

function AchievementListMgr.isThisPetAchieveOK(petID)
    local achieveId = 0
    local achieveInfo = nil
    local isHaveAchieve = false
    local pokemonAchievementCount = AchievementInfo.getPokemonAchievementInfoCount()
    for i=1,pokemonAchievementCount do
        local pokemonAchievementInfo = AchievementInfo.getPokemonAchievementInfoById(i)
        for k,v in pairs(pokemonAchievementInfo.petIDs) do
            if v == petID then
                achieveId = i
                achieveInfo = pokemonAchievementInfo
                isHaveAchieve = true
                break
            end
        end
    end
    if not isHaveAchieve then
        return false
    end

    if AchievementListMgr.isFinishPetAchieve(achieveId) then
        return false
    end
    for k,v in pairs(achieveInfo.petIDs) do
        if not AchievementListMgr.isHavePet(v) then
            return false
        end
    end
    return achieveInfo
end

function AchievementListMgr.setVisible(visible)
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    AchievementListMgr.enableTopBar(visible)
end

function AchievementListMgr.initPokeMonDataInfo()
    isHavePokeInfoLst = {}
    local pokeInfo = PokemonInfo.getAllPets()
    for i=1,#pokeInfo do
        isHavePokeInfoLst[pokeInfo[i].pokeID] = pokeInfo[i].pokeID   
    end
    return isHavePokeInfoLst
end

function AchievementListMgr.showResetSkill()
    local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameE)
    layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
    CSResourceMgr.setRelativePosition(resNameE, 320, 480)

    CSResourceMgr.setLabelColor(resNameE, "txt_dbtitle", {r=144,g=238,b=255,a=255})
    CSResourceMgr.setLabelString(resNameE, "txt_dbtitle", "skillReset2", "", {r=0,g=0,b=0,a=255,w=1,s=1})
    CSResourceMgr.setLabelColor(resNameE, "txt_jobchange", {r=217,g=234,b=255,a=255})
    CSResourceMgr.setLabelString(resNameE, "txt_jobchange", "skillReset3", "", {r=11,g=17,b=67,a=255,w=1})
    CSResourceMgr.setLabelColor(resNameE, "txt_mcashnum", {r=217,g=234,b=255,a=255})
    CSResourceMgr.setLabelString(resNameE, "txt_mcashnum", CharInfo.getMCash(), "", {r=11,g=17,b=67,a=255,w=1},nil,77)
    CSResourceMgr.setLabelColor(resNameE, "txt_xiaohao", {r=217,g=234,b=255,a=255})
    CSResourceMgr.setLabelString(resNameE, "txt_xiaohao", "skillReset7", "", {r=11,g=17,b=67,a=255,w=1})
    local resetachievementcount = CharInfo.get()["resetachievementcount"] or 1
    local txt_changejob = CSResourceMgr.getNodeByName(resNameE,"txt_changejob")

    --阿杜修改英文版显示
    local fontSize = LuaSqlite.LANG_TYPE~= 1 and 20 or 18
    local richLabel = CocosModuleMgr.createRichLabel(txt_changejob, CocosModuleMgr.createStringWithFormat({"skillReset4", resetachievementcount}),
                     fontSize, "cuyuan_GBK.ttf", TownChatMgr.MAX_LABEL_WIDTH,nil,nil,nil,true)
    CSResourceMgr.getNodeByName(resNameE,"txt_xiaohao"):setFontSize(fontSize)

    local price = 0
    local values = SystemInfo.getGlobalConfigAddInfoByID(73).values
    for i=1,resetachievementcount do
        if values[i] then
            price = values[i]
        end
    end
    CSResourceMgr.setLabelColor(resNameE, "txt_xhnum", {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelString(resNameE, "txt_xhnum", price, "", {r=0,g=0,b=0,a=255,w=1})

    local btn_ok = CSResourceMgr.getNodeByName(resNameE,"btn_ok")
    CSResourceMgr.setButtonStringColorByNode(btn_ok, {r=227,g=233,b=255,a=255})
    CSResourceMgr.setButtonStringByNode(btn_ok, "skillReset8", {r=0,g=0,b=0,a=255,w=2})
    local btn_cancel = CSResourceMgr.getNodeByName(resNameE,"btn_cancel")
    CSResourceMgr.setButtonStringColorByNode(btn_cancel, {r=227,g=233,b=255,a=255})
    CSResourceMgr.setButtonStringByNode(btn_cancel, "skillReset9", {r=0,g=0,b=0,a=255,w=2})

    CSResourceMgr.clickEventBindingByNode(btn_cancel,function()
        CSResourceMgr.removeCSObjectByTag(resNameE)
    end)

    CSResourceMgr.clickEventBinding(resNameE,"bg",function()
        CSResourceMgr.removeCSObjectByTag(resNameE)
    end)

    CSResourceMgr.clickEventBindingByNode(btn_ok,function()
        if CharInfo.getMCash()<price then
            StandardTipsMgr.show(0, "NetErrorText346")
        else
            NetInterface.sendWithBlock("GC_ResetAchievement_Ack", function()
                local AchievementSend = require("src.Net.Send.AchievementSend")
                AchievementSend.sendCG_ResetAchievement_Req()
                end,function()
                    CSResourceMgr.removeCSObjectByTag(resNameE)
                    StandardTipsMgr.show(0, "skillReset10")
                    finishSkillTable = {}
                    finishSkillTable[1] = {}
                    finishSkillTable[2] = {}
                    finishSkillTable[3] = {}
                    treeALoad = false
                    treeBLoad = false
                    treeCLoad = false
                    curTreeTab = 1
                    AchievementListMgr.resetTabC()
                end,function(code)
                    if code == Proto.Error.ERROR_HONOR_POINT_NOT_ENOUGH then
                        StandardTipsMgr.show(0, "skillReset11")
                    end
                end)
        end
    end)
end

function AchievementListMgr.getFinishSkillNum()
    local num = 0
    for i=1,3 do
        for k,v in pairs(finishSkillTable[i]) do
            num = num + 1
        end
    end
    return num
end

function AchievementListMgr.getFinishPetAchieveNum()
    local num = 0
    for k,v in pairs(finishPetAchieve) do
        num = num + 1
    end
    return num
end

return AchievementListMgr