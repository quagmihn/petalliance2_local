--create by hxf 2015-12-28
local AdvConfirmMgr = {}

local advInfo

-- tab : 1, 2, 3  =>  普通，精英，英雄
local currTab = 1
local preTab  = currTab

--difficulty
local Difficulties = {
    common = {
        font_size  = 28,
        outline = {
            [1] = {r=255,g=255,b=255,a=255},  --未选中状态
            [2] = {r=51,g=0,b=0,a=255},       --选中状态
        },
        textColor = {
            [1] = {r=138,g=107,b=102,a=255},  --未选中状态
            [2] = {r=255,g=255,b=204,a=255},  --选中状态
        },
    },
    --formal
    [1] = {
        text = "普通",
        actionValue = 10,
        
    },
    --elite
    [2]  = {
        text = "精英",
        actionValue = 15,
    },
    --hero
    [3]   = {
        text = "英雄",
        actionValue = 20,
    },
}

local resName = "Searching/advConfirm/advConfirm.csb"

local encounterBar
local dropBar

local mIconTbl = {}  --monsters or trainers
local dIconTbl = {}  --drops

local teamPageView     --team pages
local TEAM_MAX    = 4  --
local currTeamIdx = 1  --当前队伍索引
local team_names = {
        "1号队伍",
        "2号队伍",
        "3号队伍",
        "4号队伍",
}

--扫荡券item id
local ticket_id = 10000

function AdvConfirmMgr.Init()
    encounterBar = nil
    dropBar = nil
end

---目标方格字符串分割
--@param string string 目标字符串
--@param format string 分割单元格式，例:(%d,%d,%d,%d)
--@return #table 目标字符串分割为对应table
local function stringSep(string, format, separator)
    if string == nil then return nil  end
    separator = separator or nil
    local str = clone(string)
    if str == "0" then 
        return "0"     --设为nil保存到plist时出错，未判nil 
    end
    local result = {}
    local startP = 1
    local endP = 0
    local destStr = ""
    while destStr ~= nil do
        startP, endP, destStr = string.find(str,format,endP+1)
        table.insert(result, destStr)
    end
    return result
end

---设置文本(cocos studio中已经设置颜色等相关参数的文字，貌似会叠加[cocos_studio中字体颜色必须设置为白色])
local function setLabel(label,string,outline,textColor,fontSize)
    --文本
    if string ~= nil then label:setString(string) end
    --边框
    label:enableOutline(outline, 2)
    --文字颜色
    label:setTextColor(textColor)
    --文字大小
    if fontSize ~= nil then label:setFontSize(fontSize) end
end

---获取遇敌信息
local function getEnctr(eType, subType)
    if eType == SearchingMapMgr.EVENT_MONSTER then
        return AdventureInfo.getMonstrosityInfoByID(subType)
    elseif eType == SearchingMapMgr.EVENT_TRAINER then
        return AdventureInfo.getMonsterGroupManInfoByID(subType)
    else 
    end
end

---clear icon set
local function clearIcon()
    if encounterBar then
        for key, value in pairs(mIconTbl) do
            encounterBar:removeChild(value)
        end
    end
    if dropBar then
        for key, value in pairs(dIconTbl) do
            dropBar:removeChild(value)
        end
    end
    mIconTbl = {}
    dIconTbl = {} 
end

--遇敌掉落Icon设置, 根据副本id读取信息
local function setWithAdvID(advId)

    clearIcon()

    advInfo = AdventureInfo.getAdventureInfoByID(advId)

    local starImg  = "Searching/advConfirm/ts_xing.png"
    local starImgX = "Searching/advConfirm/ts_xing2.png"
    local star_1 = CSResourceMgr.getNodeByName(resName,"star1")
    local star_2 = CSResourceMgr.getNodeByName(resName,"star2")
    local star_3 = CSResourceMgr.getNodeByName(resName,"star3")
    local stars = {star_1, star_2,star_3}
    local starRecord = (AdventureInfo.getFinishedByID(advId) ~= nil) and AdventureInfo.getFinishedByID(advId).star or 0
    AdvStarMgr.setStars(stars,starRecord,starImg,starImgX)

    if advInfo == nil then
        print("advID:",advId)
        print("ADV_DEBUG_INFO: get adventure info failed, make sure  that the file [AdventureInfo.dat] is correct.")
        return
    end

    local p1 = advInfo.prompt_1  --副本提示1
    local p2 = advInfo.prompt_2  --副本提示2[遇敌提示]
    local p3 = advInfo.prompt_3  --副本提示3

    local advNameText = LuaSqlite.getLanguageByKey(advInfo.name)
    local advName = CSResourceMgr.getNodeByName(resName,"advName")
    setLabel(advName,advNameText,{r=153,g=0,b=0,a=255},{r=255,g=255,b=204,a=255},30)

    local advDescText = LuaSqlite.getLanguageByKey(advInfo.prompt_1)
    local advDesc = CSResourceMgr.getNodeByName(resName,"instru")
    setLabel(advDesc,advDescText,{},{r=76,g=76,b=76,a=255},18)

--    local enctrNum = 0
--    local ecnt = stringSep(p2, "(%d,%d)",",")
--    local enconterBar = CSResourceMgr.getNodeByName(resName,"enconterBar")
--    for k, v in pairs(ecnt) do
--        local tbl = string.split(v, ",")
--        local info = getEnctr(tonumber(tbl[1]),tonumber(tbl[2]))
--        if info ~= nil then
--            enctrNum = enctrNum + 1
--            local micon = CSResourceMgr.getNodeByName(resName,"iconSample"):clone()
--            micon:setVisible(true)
--            micon:removeFromParent(true)
--            enconterBar:addChild(micon)
--            micon:setPosition(145+100*(enctrNum-1), 66)
--            table.insert(mIconTbl,micon)
--            local btn = CSResourceMgr.seekNodeByName(micon,"iconBtn")
--            local img = "Searching/advclear/ditu_nan.png"
--            CSResourceMgr.setButtonTextureByNode(btn,img,img,img)
--            btn:setScale(0.6)
--
--        end
--    end

    --+++++++++    掉落        ++++++++++
--    local dropNum = 0
--    local rewards = advInfo.rewards_Icon
--    local tbl = string.split(rewards,",")
--    local dropBar = CSResourceMgr.getNodeByName(resName,"dropBar")
--    for k,v in pairs(tbl) do
--        dropNum = dropNum + 1
--        local itemInfo = ItemInfo.getItemInfoById(tonumber(v))
--        table.insert(SearchingMapMgr.dropTable,clone(itemInfo))
--        local dicon = CSResourceMgr.getNodeByName(resName,"iconSample"):clone()
--        dicon:setVisible(true)
--        dicon:removeFromParent(true)
--        dropBar:addChild(dicon)
--        dicon:setPosition(145+100*(dropNum-1), 66)
--        table.insert(dIconTbl,dicon)
--        local btn = CSResourceMgr.seekNodeByName(dicon,"iconBtn")
--        CSResourceMgr.setButtonTextureByNode(btn,itemInfo.icon,itemInfo.icon,itemInfo.icon)
--        CSResourceMgr.clickEventBindingByNode(btn,function()
--            local itemDescViewMgr = require("src.GameMgr.Searching.itemDescViewMgr")
--            itemDescViewMgr.show(itemInfo)
--        end,true)
--    end
--
    local pNumText = advInfo.power   --Difficulties[currTab].actionValue
    local pNum = CSResourceMgr.getNodeByName(resName,"pNum")
    pNum:setString(pNumText)
    
end

---add team
--@param idx int 翻页编号
--@param team_num int 队伍编号
local function addTeamByIdx(idx, team_num)
    team_num = team_num or idx
    if idx > TEAM_MAX then print("team num overflow") return end

    local petNodeTbl = {}

    local ii = 6

    local teamSample = CSResourceMgr.createRes(nil, "Searching/advConfirm/teamSample.csb","team"..team_num)
    local teamPage = CSResourceMgr.seekNodeByName(teamSample,"teamSample"):clone()
    for i=1, ii do 
        local p = CSResourceMgr.seekNodeByName(teamPage,"pet"):clone()
        teamPage:addChild(p)
        p:setPosition(50+80*(i-1), 50)
        table.insert(petNodeTbl,p)
    end

    local pets = AdvPetsMgr.setMyPets(team_num)

    for k=1, #pets do
        local spot = CSResourceMgr.seekNodeByName(petNodeTbl[k],"spot")
        spot:loadTexture("Searching/advConfirm/ts_sxse0002.png")

        local pet = CSResourceMgr.seekNodeByName(petNodeTbl[k],"petIcon")
        local petIcon = AdvPetsMgr.getPetIcon(pets[k].pokeID) --PokemonInfo.getPokemonIconByID(pets[k].pokeID)
        pet:loadTexture(petIcon)
        --pet:setScale(0.68)
        pet:setPosition(56.0, 56.0)

        local pLvText = tostring(pets[k].level)
        local pLvLabel = CSResourceMgr.seekNodeByName(petNodeTbl[k], "pLv")
        setLabel(pLvLabel,pLvText,{r=0,g=0,b=0,a=128},{r=255,g=255,b=255,a=255},18)
    end

    teamPageView:insertPage(teamPage, idx)
end

--关闭副本确认界面
local function hideConfirm()
end

function AdvConfirmMgr.switchToTab(tab)
    preTab  = currTab
    currTab = tab
end


local resNameBg="Searching/advConfirm/advConfirmNewUIA.csb"
function AdvConfirmMgr.addUI(scene, currAdv)
    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBg)
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBg, 320, 480)
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    end


    currAdv = tonumber(currAdv)
    print("*********      ",currAdv)
    SearchingMapMgr.currAdventure = currAdv  --默认为普通，精英(1000X), 英雄(2000X)
    local advconf

    local currTeamNum = 4
    local currTeamPage = 1
    local tnameText = team_names
    
    local init
    local function loadCSB()
        local s = os.clock()

        advconf = CSResourceMgr.createRes(scene,resName)
        CSResourceMgr.setFullScreen(resName)
        CocosModuleMgr.setRelativePosition(advconf, 320, 480)
        advconf:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)

        --local db = CSResourceMgr.getNodeByName(resName,"db")

        --取掉模糊
        --SearchingUIMgr.sceneBlur(db)

        --关闭按钮
        local closeIcon = "Searching/advConfirm/ts_guanbi0001.png"
        local closeIconX = "Searching/advConfirm/ts_guanbi0002.png"
        CSResourceMgr.setButtonTexture(resName,"close",closeIcon,closeIconX,closeIconX)

        --探索按钮事件[移到init中，引导会有bug]
        CSResourceMgr.clickEventBinding(resName,"btn_tansuo",function()
            if advInfo == nil then
                print("ADV_DEBUG_INFO: get adventure info failed, make sure  that the file [AdventureInfo.dat] is correct.")
                return
            else
                if NetInterface.isConnect then
                    NetInterface.sendWithBlock("GC_ACTIVEPETARMY_ACK", function()
                        local PetSend = require("src.Net.Send.PetSend")
                        PetSend.sendCG_ActivePetArmy_Req({petArmyIndex=currTeamIdx,})
                    end, function()
                        print("GC_ACTIVEPETARMY_ACK DONE", currTeamIdx)
                        AdvPetsMgr.setCurrTeam(currTeamIdx)

                        NetInterface.sendWithBlock("GC_CREATEADVENTURE_ACK", function()
                            local AdventureSend = require("src/Net/Send/AdventureSend.lua")
                            AdventureSend.sendCG_CreateAdventure_Req({adventureID = SearchingMapMgr.currAdventure})
                        end, 
                        function()
                            encounterBar = nil
                            dropBar = nil
                            advconf:removeAllChildren()
                            advconf:removeFromParent(true)
                            SceneMgr.replaceScene(scene, "SearchingScene")
                        end, 
                        function()
                        end)
                    end)
                else
                    advconf:removeAllChildren()
                    advconf:removeFromParent(true)
                    SceneMgr.replaceScene(scene, "SearchingScene")
                end
            end
        end)
        
        init()

        print("lllllllllstaaa:",os.clock()-s)

    end

    init = function()
    
        AdvPetsMgr.Init()   --pet init [clear data]
    
        local formal = CSResourceMgr.getNodeByName(resName,"formal")
        local elite  = CSResourceMgr.getNodeByName(resName,"elite")
        local hero  = CSResourceMgr.getNodeByName(resName,"hero")

        setLabel(formal, 
            Difficulties[1].text, 
            Difficulties.common.outline[2], 
            Difficulties.common.textColor[2], 
            Difficulties.common.font_size
        )
        setLabel(elite,  
            Difficulties[2].text,  
            Difficulties.common.outline[1], 
            Difficulties.common.textColor[1], 
            Difficulties.common.font_size
        )
        setLabel(hero,  
            Difficulties[3].text,  
            Difficulties.common.outline[1], 
            Difficulties.common.textColor[1], 
            Difficulties.common.font_size
        )
        local btn_formal = CSResourceMgr.getNodeByName(resName,"btn_formal")
        local btn_elite = CSResourceMgr.getNodeByName(resName,"btn_elite")
        local btn_hero = CSResourceMgr.getNodeByName(resName,"btn_hero")
        CSResourceMgr.setButtonEnabledByNode(btn_formal,false)
        btn_elite:setLocalZOrder(-1)
        btn_hero:setLocalZOrder(-1)

        local rareText = "稀有"
        local rareOutline = {r=153,g=0,b=0,a=255}
        local rareTextColor = {r=255,g=231,b=137,a=255}

        SearchingMapMgr.dropTable = {}

        --++++++++++++++++++    消耗               +++++++++++++++++++++++++++++++++++++++
        
        local pText = "消耗体力:"
        local power = CSResourceMgr.getNodeByName(resName,"power")
        setLabel(power,pText,{r=69,g=56,b=47,a=255},{r=255,g=255,b=204,a=255},20)
        local pNum = CSResourceMgr.getNodeByName(resName,"pNum")
        setLabel(pNum,"",{r=0,g=0,b=0,a=255},{r=255,g=255,b=255,a=255},20)

        local tText = "持有扫荡券:"
        local ticket = CSResourceMgr.getNodeByName(resName,"ticket")
        setLabel(ticket,tText,{r=69,g=56,b=47,a=255},{r=255,g=255,b=204,a=255},20)
        local tNumText = ItemInfo.getCharItemNum(ticket_id)
        local tNum = CSResourceMgr.getNodeByName(resName,"tNum")
        setLabel(tNum,tNumText,{r=0,g=0,b=0,a=255},{r=255,g=255,b=255,a=255},20)


        --++++++++++++++++++     扫荡             +++++++++++++++++++++++++++++++++++++++
        
        local sText = "扫荡"
        local sX10Text = "扫荡十次"
        local goText = "探索"

        CSResourceMgr.setButtonString(resName, "btn_saodang",    sText,    "", {r=0,g=102,b=153,a=255})
        CSResourceMgr.setButtonString(resName, "btn_saodangX10", sX10Text, "", {r=0,g=102,b=153,a=255})
        CSResourceMgr.setButtonString(resName, "btn_tansuo",     goText,   "", {r=153,g=0,b=0,a=255})
    
        setWithAdvID(currAdv)
        local tname = CSResourceMgr.getNodeByName(resName,"teamname")
        setLabel(tname,tnameText[1],{r=0,g=0,b=0,a=255},{r=255,g=255,b=255,a=255},25)
        
        teamPageView = CSResourceMgr.getNodeByName(resName,"TeamPageView")
        
        local t_1 = (currTeamIdx-1<1) and TEAM_MAX or currTeamIdx-1
        local t_2 = currTeamIdx
        local t_3 = (currTeamIdx+1>TEAM_MAX) and 1 or currTeamIdx+1
        addTeamByIdx(0,t_1)
        addTeamByIdx(1,t_2)
        addTeamByIdx(2,t_3)

        local currTeam = currTeamIdx
        local nextTeam

        local function rollToTeam(idx,pre)
            pre = pre or 1
            local tname = CSResourceMgr.getNodeByName(resName,"teamname")
            tname:setString(tnameText[idx])  --队伍名称
            CSResourceMgr.getNodeByName(resName,"page"..pre):loadTexture("Searching/advConfirm/ts_biaoshi0001.png")
            CSResourceMgr.getNodeByName(resName,"page"..idx):loadTexture("Searching/advConfirm/ts_biaoshi0002.png")
        end

        --pageIndex序号0开始    = = |||
        --page循环
        teamPageView:addEventListener(function(sender, eventType)
            local index = teamPageView:getCurPageIndex()
            local pre = currTeam      
            if index == 0 then   --scroll to left
                currTeam = (currTeam-1<1) and TEAM_MAX or currTeam-1
                nextTeam = (currTeam-1<1) and TEAM_MAX or currTeam-1
                teamPageView:removePageAtIndex(2)
                addTeamByIdx(0, nextTeam)
                teamPageView:scrollToPage(1)
                teamPageView:update(10)
                currTeamIdx = currTeam
                rollToTeam(currTeam,pre)
            elseif index == 2 then   --scroll to right
                currTeam = (currTeam+1>TEAM_MAX) and 1 or currTeam+1
                nextTeam = (currTeam+1>TEAM_MAX) and 1 or currTeam+1
                teamPageView:removePageAtIndex(0)
                addTeamByIdx(2, nextTeam)
                teamPageView:scrollToPage(1)
                teamPageView:update(10)
                currTeamIdx = currTeam
                rollToTeam(currTeam,pre)
            end

        end)
        teamPageView:scrollToPage(1)
        teamPageView:update(10)  --取消scroll
        rollToTeam(currTeamIdx)
        --滚动手感调整
        teamPageView:setCustomScrollThreshold(20.0)
        teamPageView:isUsingCustomScrollThreshold()
    end
    
    local function playCSB()
        CSResourceMgr.playAction(resName, 0, 5, false)
    end
    
    -- 遇敌初始化
    local function initEncounter()
        local p2 = advInfo.prompt_2  --副本提示2[遇敌提示]
        local enctrNum = 0
        local ecnt = stringSep(p2, "(%d,%d)",",")
        local _pp = CSResourceMgr.createRes(nil,"Searching/advConfirm/Enctr_Drop_bar.csb","enctrbar")
        if not encounterBar then 
            local parent = CSResourceMgr.getNodeByName(resName,"ts_dit4")
            encounterBar = CSResourceMgr.seekNodeByName(_pp,"bar")
            encounterBar:removeFromParent(true)
            parent:addChild(encounterBar)
            encounterBar:setPosition(260,509)
            local eText = "遇\n敌"
            local title = CSResourceMgr.seekNodeByName(encounterBar,"title")
            setLabel(title,eText,{r=0,g=0,b=0,a=255},{r=255,g=255,b=255,a=255},25)
        end
        encounterBar:setScaleY(0)
        for k, v in pairs(ecnt) do
            local tbl = string.split(v, ",")
            local info = getEnctr(tonumber(tbl[1]),tonumber(tbl[2]))
            if info ~= nil then
                enctrNum = enctrNum + 1

                local micon = CSResourceMgr.seekNodeByName(_pp,"iconSample"):clone()
                micon:setVisible(true)
                micon:removeFromParent(true)
                encounterBar:addChild(micon)
                micon:setPosition(145+100*(enctrNum-1), 66)
                table.insert(mIconTbl,micon)
                local btn = CSResourceMgr.seekNodeByName(micon,"iconBtn")
                local img = "Searching/advclear/ditu_nan.png"
                CSResourceMgr.setButtonTextureByNode(btn,img,img,img)
                btn:setScale(0.6)
            end
        end
        
        transition.scaleTo(encounterBar, {scaleY = 1, time = 0.1})
    end
    
    -- 掉落初始化
    local function initDrop()
        local dropNum = 0
        local rewards = advInfo.rewards_Icon
        local tbl = string.split(rewards,",")
        local _pp = CSResourceMgr.createRes(nil,"Searching/advConfirm/Enctr_Drop_bar.csb","dropbar")
        if not dropBar then 
            local parent = CSResourceMgr.getNodeByName(resName,"ts_dit4")
            dropBar = CSResourceMgr.seekNodeByName(_pp,"bar")
            dropBar:removeFromParent(true)
            parent:addChild(dropBar)
            dropBar:setPosition(260,387)
            local dText = "掉\n落"
            local title = CSResourceMgr.seekNodeByName(dropBar,"title")
            setLabel(title,dText,{r=0,g=0,b=0,a=255},{r=255,g=255,b=255,a=255},25)
        end
        dropBar:setScaleY(0)
        for k,v in pairs(tbl) do
            dropNum = dropNum + 1

            local itemInfo = ItemInfo.getItemInfoById(tonumber(v))
            table.insert(SearchingMapMgr.dropTable,clone(itemInfo))

            local dicon = CSResourceMgr.seekNodeByName(_pp,"iconSample"):clone()
            dicon:setVisible(true)
            dicon:removeFromParent(true)
            dropBar:addChild(dicon)
            dicon:setPosition(145+100*(dropNum-1), 66)
            table.insert(dIconTbl,dicon)
            local btn = CSResourceMgr.seekNodeByName(dicon,"iconBtn")
            CSResourceMgr.setButtonTextureByNode(btn,itemInfo.icon,itemInfo.icon,itemInfo.icon)
            CSResourceMgr.clickEventBindingByNode(btn,function()
                local itemDescViewMgr = require("src.GameMgr.Searching.itemDescViewMgr")
                itemDescViewMgr.show(itemInfo)
            end,true)
        end
        transition.scaleTo(dropBar, {scaleY = 1, time = 0.1})
    end
    
    local function buttonBinding()
        --close按钮绑定
        CSResourceMgr.clickEventBinding(resName,"close",function()
            encounterBar = nil
            dropBar = nil
            AdvPetsMgr.Init()
            UnblockLoader.cancel("SearchingUIMgr-addConfirmUI")
            CSResourceMgr.removeCSObjectByTag(resName)
        end)

        local formal = CSResourceMgr.getNodeByName(resName,"formal")
        local elite  = CSResourceMgr.getNodeByName(resName,"elite")
        local hero  = CSResourceMgr.getNodeByName(resName,"hero")
        local btn_formal = CSResourceMgr.getNodeByName(resName,"btn_formal")
        local btn_elite = CSResourceMgr.getNodeByName(resName,"btn_elite")
        local btn_hero = CSResourceMgr.getNodeByName(resName,"btn_hero")

        local function setEnctrAndDrop()
            dropBar:setScaleY(0)
            initEncounter()
            encounterBar:performWithDelay(function()
                initDrop()
            end,0.2)
        end

        --普通关卡按钮绑定
        CSResourceMgr.clickEventBinding(resName,"btn_formal",function()
            CSResourceMgr.setButtonEnabledByNode(btn_formal,false)
            CSResourceMgr.setButtonEnabledByNode(btn_elite,true)
            CSResourceMgr.setButtonEnabledByNode(btn_hero,true)
            btn_formal:setPositionY(704)
            btn_formal:setLocalZOrder(1)
            btn_elite:setPositionY(716)
            btn_elite:setLocalZOrder(-1)
            btn_hero:setPositionY(716)
            btn_hero:setLocalZOrder(-1)
            setLabel(formal, nil, Difficulties.common.outline[2], Difficulties.common.textColor[2], nil)
            setLabel(elite,  nil, Difficulties.common.outline[1], Difficulties.common.textColor[1], nil)
            setLabel(hero,   nil, Difficulties.common.outline[1], Difficulties.common.textColor[1], nil)
            SearchingMapMgr.currAdventure = currAdv
            SearchingMapMgr.dropTable = {}
            setWithAdvID(SearchingMapMgr.currAdventure)
            setEnctrAndDrop()
        end)

        --精英关卡按钮绑定
        CSResourceMgr.clickEventBinding(resName,"btn_elite",function()
            CSResourceMgr.setButtonEnabledByNode(btn_formal,true)
            CSResourceMgr.setButtonEnabledByNode(btn_elite,false)
            CSResourceMgr.setButtonEnabledByNode(btn_hero,true)
            btn_formal:setPositionY(716)
            btn_formal:setLocalZOrder(-1)
            btn_elite:setPositionY(704)
            btn_elite:setLocalZOrder(1)
            btn_hero:setPositionY(716)
            btn_hero:setLocalZOrder(-1)
            setLabel(formal, nil, Difficulties.common.outline[1], Difficulties.common.textColor[1], nil)
            setLabel(elite,  nil, Difficulties.common.outline[2], Difficulties.common.textColor[2], nil)
            setLabel(hero,   nil, Difficulties.common.outline[1], Difficulties.common.textColor[1], nil)
            SearchingMapMgr.dropTable = {}
            SearchingMapMgr.currAdventure = currAdv + 10000
            setWithAdvID(SearchingMapMgr.currAdventure)
            setEnctrAndDrop()
        end)

        --英雄关卡按钮绑定
        CSResourceMgr.clickEventBinding(resName,"btn_hero",function()
            CSResourceMgr.setButtonEnabledByNode(btn_formal,true)
            CSResourceMgr.setButtonEnabledByNode(btn_elite,true)
            CSResourceMgr.setButtonEnabledByNode(btn_hero,false)
            btn_formal:setPositionY(716)
            btn_formal:setLocalZOrder(-1)
            btn_elite:setPositionY(716)
            btn_elite:setLocalZOrder(-1)
            btn_hero:setPositionY(704)
            btn_hero:setLocalZOrder(1)
            setLabel(formal, nil, Difficulties.common.outline[1], Difficulties.common.textColor[1], nil)
            setLabel(elite,  nil, Difficulties.common.outline[1], Difficulties.common.textColor[1], nil)
            setLabel(hero,   nil, Difficulties.common.outline[2], Difficulties.common.textColor[2], nil)
            SearchingMapMgr.dropTable = {}
            SearchingMapMgr.currAdventure = currAdv + 20000
            setWithAdvID(SearchingMapMgr.currAdventure)
            setEnctrAndDrop()
        end)



        --扫荡按钮事件
        local btn_saodang = CSResourceMgr.getNodeByName(resName,"btn_saodang")
        CSResourceMgr.clickEventBinding(resName,"btn_saodang",function()
            if not NetInterface.isConnect then return end
            btn_saodang:getTitleRenderer():enableOutline({r=53,g=63,b=134,a=255},2)
            NetInterface.sendWithBlock("GC_QUICKCLEARADVENTURE_ACK", 
            function() 
                local AdventureSend = require("src/Net/Send/AdventureSend.lua")
                AdventureSend.sendCG_QuickClearAdventure_Req({
                    adventureID = SearchingMapMgr.currAdventure,
                    clearType   = 0,  -- 扫荡类型 0:扫荡券
                    isManyTimes  = 0,  -- 是否连续扫荡 1 是 0 否
                })
            end, 
            function()
                local tNumText = ItemInfo.getCharItemNum(ticket_id)
                local tNum = CSResourceMgr.getNodeByName(resName,"tNum")
                tNum:setString(tNumText)
            end,
            function(code)
                TipsMgr.showError(nil, code)
            end, nil, false)
        end)
        local btn_saodangX10 = CSResourceMgr.getNodeByName(resName,"btn_saodangX10")
        CSResourceMgr.clickEventBinding(resName,"btn_saodangX10",function()
            if not NetInterface.isConnect then return end
            btn_saodangX10:getTitleRenderer():enableOutline({r=53,g=63,b=134,a=255},2)
            NetInterface.sendWithBlock("GC_QUICKCLEARADVENTURE_ACK", 
            function() 
                local AdventureSend = require("src/Net/Send/AdventureSend.lua")
                AdventureSend.sendCG_QuickClearAdventure_Req({
                    adventureID = SearchingMapMgr.currAdventure,
                    clearType   = 0,  -- 扫荡类型 0:扫荡券
                    isManyTimes  = 1,   -- 是否连续扫荡 1 是 0 否
                })
            end, 
            function()
                print("扫荡成功！")
                local tNumText = ItemInfo.getCharItemNum(ticket_id)
                local tNum = CSResourceMgr.getNodeByName(resName,"tNum")
                tNum:setString(tNumText)
            end,
            function(code)
                TipsMgr.showError(nil, code)
            end, nil, false)
        end)
    end

    local funcTable = {loadCSB, playCSB, initEncounter, initDrop, buttonBinding, }
    --local funcTable = {loadBG }
    
--    for i=1,#funcTable do
--        funcTable[i]()
--    end
    
    UnblockLoader.load(funcTable, "SearchingUIMgr-addConfirmUI")
    
end

return AdvConfirmMgr