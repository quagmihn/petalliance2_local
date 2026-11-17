--vesion number 1.0
--@client side AdvConfirmMgrNew.lua
--[[
  这个文件是新版的探索界面的UI
--]]
--script writer Leon Lee
--creation time 2016-2-20fp小
--扫荡券item id
local ticket_id = 10000
local AdvConfirmMgrNew = {}

AdvConfirmMgrNew.isTerrWin = false  -- 领主争夺战斗结果

local isLocalDataInited = false
local MCash;
local ButTimesTable--购买次数
local OpenLevel = 0

local resNameBg=""

local resNameAdvNewA,resNameAdvNew,resNameAdvNewC,resNameAdvNewD,resNameTopRight,resNameTopLeft

local advInfo --探索信息,改成数组更好 1-普通 2-英雄 3-精英
local encounterBar 
local dropBar

local bgUI,advUI,topUI,midUI,bottomUI;
local dIconTbl = {}  --drops
local terrAwardTbl = {} --副本奖励信息
local saodangTiaoJian = {}--完成星数、剩余次数、体力



local tNumText; --玩家剩余次数数值文本
local pNumText; --副本所需体力数值文本
local qNumText; --副本所需等级文本
local yudi = {}
local lzinfo={} --领地信息
local currLzBossinfo = {}--当前领地的boss信息
local bosspets = {} --领主的宠物
local maxChallenTimes = 5
local curChallenTimes = 0
local curBuyTimes = 0 
local lzAvartarInfo = nil

local teamCounts = 1 --只是为了解决bug写的变量
local currTeamIdx = 1  --当前队伍索引
local teamPageView     --team pages
local TEAM_MAX    = 2
local team_names = {
    "1号队伍",
    "2号队伍",
    "3号队伍",
    "4号队伍",
    "5号队伍"
}

--扫荡开启条件
local fbOpenCondition = {
    putong={
        level = -1,
        starcnt = -1,
    },
    
    jinying={
        level = -1,
        starcnt = -1,
    },
    
    yingxiong={
        level = -1,
        starcnt = -1,
    },
} 

local currTab = 1 --1普通  2精英 3英雄 4领主
local lznickname --领主的昵称
local lzfamilyname --领主的家族名称
local allQcTimes = {} --table,三种副本的清除总次数,只需要初始化一次
local qcPerTimes = {} --table,三种副本每次能够扫荡的次数
local eliteNumber = 10000 --精英关卡的后缀数字
local heroNumber = 20000 --英雄关卡的后缀数字

--需要读lang表的文字列出来
local tsbtntext = "Territorialbtn1" --"探 索"
local needsdqtext = "Territorialtips3"--"扫荡券不够"
local needtltext = "Territorialtips4"--"体力值不够"
local pttabtext = "Territorialbtn2"--"普 通"
local jytabtext = "Territorialbtn3"--"精 英"
local yxtabtext = "Territorialbtn4"--"英 雄"
local lingzhutabtext = "Territorialtext1"--"领 主"
local lzjianglitext = "Territorialtext2"--"领主奖励"
local diaoluotext = "Territorialtext8"--"掉 落"
local tzbtntext = "Territorialbtn5"--"挑 战"
local xhtltext="Territorialtips16"--"消耗体力:"
local opentimeleft="Territorialtext3"--"下次开放争夺时间:"
local challengetimeleft = "Territorialtext4"--"剩余挑战领主时间:"
local challencsleft="Territorialtext5"--"剩余次数:"
local sdqtext="Territorialtext10"--"扫荡券:"
local saodangtext = "Territorialbtn6"--"扫 荡"
local saodangtentext = "Territorialbtn7"--"扫 荡 <1>次"
local phbtext = "Territorialbtn8"--"排 行 榜"
local lztitletext="Territorialtext1"--"领主:"
local jztitletext="Territorialtext7"--"家族:"
local djxztext="Territorialtips17"--"等级限制:"
local lairdBuffText="Territorialtips18"--"领主提升挂机收益"
local djxztext2="Territorialtips21"--"推荐等级"

local goumaitips = "Territorialtips2"--"是否花费150M购买挑战次数"
local lzzhenrongtext = "Territorialtext12" --"领主阵容"
local gongxixinlz = "Territorialtips10" --"恭喜你成为新的领主"
local tiaozhanshibai = "Territorialtips9" --"真遗憾，挑战失败"

--错误序列
local needteammeber="Territorialtips1"--"挑战队伍不能为空"
local lowlevel = "Territorialtips5"--"角色等级不够"
local lowstage = "Territorialtips6" --"领主要求通关皇冠"
local lowCrown = "Territorialtips19" --"扫荡要求通关皇冠"
local maxbuy = "Territorialtips7" --"已达购买最大次数上限"
local nochallengetimes = "Territorialtips8" --"挑战次数不够"
local alreadyleizhu = "Territorialtips11" --"已经是擂主"
local befighting = "Territorialtips12"--"战斗中"
local nomcash = "Territorialtips13"--"钻石不足"
local notopentime = "Territorialtips14" --"争夺时间未到"
local fubenunlock = "Territorialtips15"  --"副本未解锁"

--local originTabPos = 0
local normalAdvId = 0

local Difficulties = {
    common = {
        font_size  = {
        [1] = 22,--未选中状态
        [2] = 23,--选中状态
        },
        outline = {
            [1] = {r=226,g=226,b=226,a=255},  --未选中状态
            [2] = {r=209,g=138,b=0,a=255},       --选中状态
        },
        textColor = {
            [1] = {r=82,g=82,b=82,a=255},  --未选中状态
            [2] = {r=255,g=255,b=255,a=255},  --选中状态
        },
    },
    --formal
    [1] = {
        text = pttabtext,
        actionValue = 10,

    },
    --elite
    [2]  = {
        text = jytabtext,
        actionValue = 15,
    },
    --hero
    [3]   = {
        text = yxtabtext,
        actionValue = 20,
    },
    
    --lingzhu
    [4] ={       
        text = lingzhutabtext,
        actionValue = 20,
    },
}


local function errorTipsProcess(errornumber)

    if errornumber == 445 then
        StandardTipsMgr.show(1,lowlevel)
        return
    end
    
    if errornumber == 446 then
        StandardTipsMgr.show(1,fubenunlock)
        return
    end
    
    if errornumber == 447 then
    
        StandardTipsMgr.show(1,nochallengetimes)
        return 
    end
    
    if errornumber == 448 then
    
        StandardTipsMgr.show(1,alreadyleizhu)
        return       
    end
    
    if errornumber == 449 then
    
        StandardTipsMgr.show(1,befighting)
        return
    end
    
    if errornumber == 450 then
        StandardTipsMgr.show(1,maxbuy)
        return   
    end
    
    if errornumber == 451 then
        StandardTipsMgr.show(1,nomcash)
        return   
    end
    
    if errornumber == 452 then
        StandardTipsMgr.show(1,notopentime)
        return   
    end
end

local function setLabel(label,string,outline,textColor,fontSize,maxwidth,singleline,outlinewidth)

    CSResourceMgr.setLabelColorByNode(label,textColor)
    CSResourceMgr.setLabelStringByNode(label,string,nil,nil,singleline)
    outlinewidth = outlinewidth or 2
    if outlinewidth~=nil and outline ~=nil  then
        label:enableOutline(outline, outlinewidth)
    end
  
    CSResourceMgr.setLabelColorByNode(label,textColor)
    CSResourceMgr.setLabelStringByNode(label,string,nil,nil,singleline)


    if maxwidth~=nil then
        CSResourceMgr.setLabelMaxWidthByNode(label,maxwidth)
    end


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

local function setTeamBoard(pets)
    local teamSample = CSResourceMgr.createRes(nil, "Searching/advConfirm/teamPage.csb","team-lz")
    local teamBoard = CSResourceMgr.createRes(nil,"Searching/advConfirm/advConTeam.csb")
    local teamBg = CSResourceMgr.seekNodeByName(teamBoard, "TeamBg")
    local m_db = CSResourceMgr.seekNodeByName(teamBg,"army_db")
    local h_db = CSResourceMgr.seekNodeByName(teamBg,"helpArmy_db")
    
    local m_label = CSResourceMgr.seekNodeByName(teamBg,"m_pet_label")
    local h_label = CSResourceMgr.seekNodeByName(teamBg,"h_pet_label")
    CSResourceMgr.setLabelStringByNode(m_label,"train107")
    CSResourceMgr.setLabelStringByNode(h_label,"train108")
    CSResourceMgr.setLabelColorByNode(m_label, {r=255,g=166,b=4,a=255})
    CSResourceMgr.setLabelColorByNode(h_label, {r=255,g=166,b=4,a=255})
    
    local m_pet = pets["m_pets"]
    local h_pet = pets["h_pets"]

    for i = 1, 3 do
        if i <= #m_pet then
            local pInfo = m_pet[i]
            local p = PetListMgr.createPetNodeByPetInfo(pInfo,"m_army-lz-"..i,true)   -- PetListMgr.createPetNode(pInfo,"m_army-lz-"..i)
            m_db:addChild(p.node)
            p.node:setPosition(75+96*(i-1), 88)
            p.node:setAnchorPoint(0.5,0.5) 
        else
            local p = CSResourceMgr.seekNodeByName(teamSample,"emptynode"):clone()
            m_db:addChild(p)
            p:setPosition(56+96*(i-1), 63)
            p:setAnchorPoint(0.5,0.5) 
        end
    end

    for i = 1, 3 do
        if i <= #h_pet then
            local pInfo = h_pet[i]
            local p = PetListMgr.createPetNodeByPetInfo(pInfo,"h_army-lz-"..i,true)   -- PetListMgr.createPetNode(pInfo,"h_army-lz-"..i)
            h_db:addChild(p.node)
            p.node:setPosition(75+96*(i-1), 88)
            p.node:setAnchorPoint(0.5,0.5) 
        else
            local p = CSResourceMgr.seekNodeByName(teamSample,"emptynode"):clone()
            h_db:addChild(p)
            p:setPosition(56+96*(i-1), 63)
            p:setAnchorPoint(0.5,0.5) 
        end
    end
    
    teamBg:removeFromParent()
    return teamBg
end

---add team
--@param idx int 翻页编号
--@param team_num int 队伍编号
local function addTeamByIdx(idx, team_num)
    team_num = team_num or idx
    if idx > TEAM_MAX then print("team num overflow") return end
    
    --print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>",team_num)
    
    --获得编队宠物信息
    local pets = AdvPetsMgr.setMyPets(team_num)
    
 --   local startFunc = os.clock()
    local teamSample = CSResourceMgr.createRes(nil, "Searching/advConfirm/teamPage.csb","team"..team_num)
 --   local endFunc = os.clock()
  --  print("create res5 take time:"..endFunc-startFunc)
    teamCounts=teamCounts+1
    local teamPage = CSResourceMgr.seekNodeByName(teamSample,"teamPage"):clone()
    teamPage:setCascadeOpacityEnabled(true)
    if pets~=nil and #pets > 0 then
        for i=1, #pets do 
            local p = PetListMgr.createPetNode(pets[i],"team"..team_num..teamCounts..i)
            teamPage:addChild(p.node)
            p.node:setPosition(60+100*(i-1), 85)
            p.node:setAnchorPoint(0.5,0.5) 
            p.node:setScale(0.8,0.8)
            
        end
        
        if #pets < 6 then
            for i =#pets+1,6 do
                local p = CSResourceMgr.seekNodeByName(teamSample,"emptynode"):clone()
                p:setCascadeOpacityEnabled(true)
                teamPage:addChild(p)
                p:setPosition(50+100*(i-1), 63)
                p:setAnchorPoint(0.5,0.5) 
                p:setScale(0.77,0.77)
            end
        end
    else
       
        for i=1,6 do

            local p = CSResourceMgr.seekNodeByName(teamSample,"emptynode"):clone()
            p:setCascadeOpacityEnabled(true)
            teamPage:addChild(p)
            p:setPosition(50+100*(i-1), 63)
            p:setAnchorPoint(0.5,0.5) 
            p:setScale(0.77,0.77)
        end

    end

   
    CSResourceMgr.seekNodeByName(teamPage,"block"):setLocalZOrder(2)
    teamPageView:insertPage(teamPage, idx)
end

local function setMyTeam(team_num)
    local teamSample = CSResourceMgr.createRes(nil, "Searching/advConfirm/teamPage.csb","team"..team_num)
    local teamPage = CSResourceMgr.seekNodeByName(teamSample,"teamPage"):clone()

    AdvPetsMgr.setMyPets(team_num)

    local m_db = CSResourceMgr.getNodeByName(resNameAdvNewC,{"db","dakuang","TeamBg","army_db"})
    local h_db = CSResourceMgr.getNodeByName(resNameAdvNewC,{"db","dakuang","TeamBg","helpArmy_db"})
    
    local teamBg = CSResourceMgr.getNodeByName(resNameAdvNewC,{"db","dakuang","TeamBg"})
    local m_label = CSResourceMgr.seekNodeByName(teamBg,"m_pet_label")
    local h_label = CSResourceMgr.seekNodeByName(teamBg,"h_pet_label")
    CSResourceMgr.setLabelStringByNode(m_label,"train107")
    CSResourceMgr.setLabelStringByNode(h_label,"train108")

    local m_army = AdvPetsMgr.advArmy
    local h_army = AdvPetsMgr.advHelpArmy

    for i = 1, 3 do
        if i <= #m_army then
            local pInfo = PokemonInfo.getPetInfoByObjID(m_army[i])
            local p = PetListMgr.createPetNode(pInfo,"m_army"..team_num..i,true)
            m_db:addChild(p.node)
            p.node:setPosition(75+96*(i-1), 88)
            p.node:setAnchorPoint(0.5,0.5) 
            -- p.node:setScale(0.8,0.8)
        else
            local p = CSResourceMgr.seekNodeByName(teamSample,"emptynode"):clone()
            m_db:addChild(p)
            p:setPosition(56+96*(i-1), 63)
            p:setAnchorPoint(0.5,0.5) 
            -- p:setScale(0.77,0.77)
        end
    end

    for i = 1, 3 do
        if i <= #h_army then
            local pInfo = PokemonInfo.getPetInfoByObjID(h_army[i])
            local p = PetListMgr.createPetNode(pInfo,"h_army"..team_num..i,true)
            h_db:addChild(p.node)
            p.node:setPosition(75+96*(i-1), 88)
            p.node:setAnchorPoint(0.5,0.5) 
            -- p.node:setScale(0.8,0.8)
        else
            local p = CSResourceMgr.seekNodeByName(teamSample,"emptynode"):clone()
            h_db:addChild(p)
            p:setPosition(56+96*(i-1), 63)
            p:setAnchorPoint(0.5,0.5) 
            -- p:setScale(0.77,0.77)
        end
    end
end

---设置领主编队
--@param parent node 父节点
local function showLingZhuTeam()
    local parent = CSResourceMgr.getNodeByName(resNameAdvNew,"pic_lzyudibg")
    parent:removeAllChildren()

    local node = setTeamBoard(bosspets)
    parent:addChild(node)
    node:setPosition(310, 84)
end

local function showLZAvatarInfo(delay)
    --print("lzAvartarInfo:")
    if CharInfo.get().maplock >= OpenLevel and AdvStarMgr.checkClearFlag(normalAdvId) then
        UnblockLoader.cancel("AdvConfirmMgrNew-getLzInfo")  
        --print("lzAvartarInfo:"..lzAvartarInfo)
        
        local delay = delay or false
        local function showAvartar()
            if lzAvartarInfo ~= nil then
                local funcTable = {}
                table.insert(funcTable,function() 
                    local actor = CSResourceMgr.getNodeByName(resNameAdvNewA,"ActorAnim")
                    PlayerAnimeMgr.removePlayerByTag("AdvConfirmNew_AnimPlay", true)
                    PlayerAnimeMgr.createPlayer(actor,{x=0,y=0,gender = lzAvartarInfo.gender,skin = lzAvartarInfo.fashion.curFashion},"AdvConfirmNew_AnimPlay")            
                end)

                UnblockLoader.load(funcTable, "AdvConfirmMgrNew-getLzInfo")     
            end             
        end
        
        if not delay then
            showAvartar()
        else
            local scheduler = require("src.framework.scheduler")
            scheduler.performWithDelayGlobal(function()
                --print("1秒后再添加")
                showAvartar()
            end, 1)
        
        end
    end
    
end

local function setYuDiBar(tabindex)
    
    local yudiBar = CSResourceMgr.getNodeByName(resNameAdvNew,"yudibg")
    local lzyudiBar = CSResourceMgr.getNodeByName(resNameAdvNew,"pic_lzyudibg")
    local lzzrbg = CSResourceMgr.getNodeByName(resNameAdvNew,"pic_lzzrbg")
    local leftwing =  CSResourceMgr.getNodeByName(resNameAdvNew,"pic_leftwing")
    local rightwing =  CSResourceMgr.getNodeByName(resNameAdvNew,"pic_rightwing")
    if tabindex ~= 4 then
        yudiBar:setVisible(true)
        lzyudiBar:setVisible(false)
        lzzrbg:setVisible(false)
        leftwing:setVisible(false)
        rightwing:setVisible(false)
    else
        yudiBar:setVisible(false)
        lzyudiBar:setVisible(true)
        lzzrbg:setVisible(true)
        leftwing:setVisible(true)
        rightwing:setVisible(true)
        
    end
end


---遇敌初始化
local function initEncounter()

    CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameAdvNewD)
    yudi = {}
    --print("initEncounter currtab........................"..currTab)
    setYuDiBar(currTab)
    local datainfo = advInfo[currTab]
    if currTab~=4 then --不是领主
        local p2 = datainfo.fightWarning  --副本提示2[遇敌提示]
        local enctrNum = 0
    
        local ecnt = stringSep(p2, "(%d+,%d+)",",")
    
        for k, v in pairs(ecnt) do
            --print(".............v"..v)
            local tbl = string.split(v, ",")
            local eType = tonumber(tbl[1])
            local subType = tonumber(tbl[2])
    
            if eType == LtEventOption.EVENT_TRAINER then
                local trainerInfo = AdventureInfo.getMonsterGroupManInfoByID(subType)
                local _icon = CharInfo.getHeadIcon("["..trainerInfo.figure.."]")
                if trainerInfo~=nil then
                    table.insert(yudi,{icon=_icon, scale=1})
                end
            elseif eType == LtEventOption.EVENT_MONSTER then
                local _info = AdventureInfo.getMonstrosityInfoByID(subType)
                if _info then
                    local _icon = AdvPetsMgr.getPetIcon(tonumber(_info.petnumber))
                    table.insert(yudi,{icon=_icon, scale=92/80})
                end
            end
        end
        
        local yudiBar = CSResourceMgr.getNodeByName(resNameAdvNew,"yudibg")
        yudiBar:removeAllChildren() 

        for k,v in pairs(yudi) do  
            local yudikuang = CSResourceMgr.getNodeByName(resNameAdvNewD,"yudikuang"):clone()
            yudikuang:setCascadeOpacityEnabled(true)
            local iconnode = CSResourceMgr.seekNodeByName(yudikuang,"yudi1")
            iconnode:loadTexture(v.icon)
            iconnode:setScale(v.scale or 1)
            yudikuang:setVisible(true)
            yudikuang:removeFromParent(true)
            yudiBar:addChild(yudikuang)
            yudikuang:setPosition(92+143*(k-1),71)
        end
    else --获得领主的宠物
        showLingZhuTeam()
    end 
end


---掉落初始化
local function initDrop()
    local dropNum = 0
    local startpos = 125+47*4 --掉落框初始的位置
    --dropbar init
    dropBar = CSResourceMgr.getNodeByName(resNameAdvNew,"diaoluodb")
    dropBar:removeAllChildren()
    
    if currTab~=4 then --不是领主
        local datainfo = advInfo[currTab]
        local rewards = datainfo.rewards_Icon
        local tbl = string.split(rewards,",")
        
        table.insert(tbl, 9997)
        
        startpos = startpos-(#tbl-1)*50
        
        for k,v in pairs(tbl) do
            -- print("diao luo k,v"..k,v)
            dropNum = dropNum + 1
            local itemID = tonumber(v)
            local itemInfo = ItemInfo.getItemInfoById(itemID)
            table.insert(SearchingMapMgr.dropTable,clone(itemInfo))
            
            local itemNum
            if itemID == 9997 then  -- 经验提示
                local aid = SearchingMapMgr.currAdventure
                if CharInfo.get()["advexp"..currTab] == 0 or aid > AdventureInfo.getHighestAdv(math.ceil(aid / 10000)) then
                    itemNum = datainfo.Exp_rewards
                else
                    itemNum = CharInfo.get()["advexp"..currTab]
                end
            end
            
            --阿杜修改英文版显示
            local dicon = ItemInfo.getItemIconById(itemID, itemNum, nil, LuaSqlite.LANG_TYPE == 1)
            
            dicon:setVisible(true)
            dicon:setScale(80 / dicon:getContentSize().width)
            -- dicon:removeFromParent(true)
            dropBar:addChild(dicon)
            dicon:setPosition(startpos+100*(dropNum-1), 55)
            table.insert(dIconTbl,dicon)
            
            CSResourceMgr.clickEventBindingByNode(dicon,function()
                local itemDescViewMgr = require("src.GameMgr.Item.ItemInfoViewMgr")
                itemDescViewMgr.show(itemInfo,false)
            end,3)
        end
    else
        local tbl = clone(terrAwardTbl)
        local terrInfo = TerritorialInfo.getTerritorialInfoByID(normalAdvId).territorialList[1]
        if terrInfo and terrInfo.winPoint then
            table.insert(tbl, {itemID = 9991, count = terrInfo.winPoint})
        end
        startpos = startpos-(#tbl-1)*50
        for k,v in pairs(tbl) do
            dropNum = dropNum + 1
            
            local itemID = tonumber(v.itemID)
            local itemNum = v.count
            
            local itemInfo = ItemInfo.getItemInfoById(itemID)
            table.insert(SearchingMapMgr.dropTable,clone(itemInfo))
            
            --阿杜修改英文版显示
            local dicon = ItemInfo.getItemIconById(itemID, itemNum, nil, LuaSqlite.LANG_TYPE == 1)

            dicon:setVisible(true)
            dicon:setScale(80 / dicon:getContentSize().width)
            -- dicon:removeFromParent(true)
            dropBar:addChild(dicon)
            dicon:setPosition(startpos+100*(dropNum-1), 55)
            table.insert(dIconTbl,dicon)
            
            CSResourceMgr.clickEventBindingByNode(dicon,function()
                local itemDescViewMgr = require("src.GameMgr.Item.ItemInfoViewMgr")
                itemDescViewMgr.show(itemInfo,false)
            end,3)            
       end
    end
    --transition.scaleTo(dropBar, {scaleY = 1, time = 0.1})
end

--获得副本遇敌和掉落信息
local function setEnctrAndDrop()
    initEncounter()
    initDrop()
end 

---初始化探索的前置条件信息，只调用一次
--@param _advId 普通副本id
local function initFBSearchCondition(_normalAdvId)
    local starCntNormal = AdvStarMgr.getStarNumByID(_normalAdvId)
    local starCntElite = AdvStarMgr.getStarNumByID(_normalAdvId+eliteNumber)
    local starCntHero = AdvStarMgr.getStarNumByID(_normalAdvId+heroNumber)
    fbOpenCondition.putong.starcnt = starCntNormal;
    fbOpenCondition.jinying.starcnt = starCntElite;
    fbOpenCondition.yingxiong.starcnt = starCntHero;
    
    --print("starCntNormal......................." ..starCntNormal)

end

---获得扫荡的相关条件信息
--@param _advId 副本id
local function getSaoDangInfo(_advId)
    if currTab==4 then return end
    
    print("getSaoDangInfo........ advId:".._advId)
    saodangTiaoJian = {}
    local starRecord = AdvStarMgr.getStarNumByID(_advId)
    local info = AdventureInfo.getFinishedByID(_advId)
    local qctimes = info.qctimes
 
    local tNum = 0
    if qctimes == 0 then 
       tNum = allQcTimes[currTab] 
    else
        local diff = CocosModuleMgr.getDayTimeDiff(info.qcupdatetime,CharInfo.getServerTime())
        
        diff = diff or 1
        if diff <=0 then 
     
            tNum = allQcTimes[currTab] - qctimes
            --print("diff<=0....."..tNum)
        else
            tNum = allQcTimes[currTab]   
            --print("diff>0....."..tNum)     
        end
    end
    
    --获取体力值
    local actionPownNum = CharInfo.getActionValue()
    
    -- mod: 普通，精英本不限制挑战次数(受体力限制)
    if currTab == 1 or currTab == 2 then
        tNum = math.floor(CharInfo.getActionValue() / tonumber(pNumText))
     end
    
    table.insert(saodangTiaoJian,starRecord)
    table.insert(saodangTiaoJian,tNum)
    table.insert(saodangTiaoJian,actionPownNum)
end

local function refreshSaodangInfo(refreshid)
    if CSResourceMgr.getCsbObj(resNameAdvNew) and currTab~=4 then
        if refreshid == SearchingMapMgr.currAdventure then
            getSaoDangInfo(SearchingMapMgr.currAdventure)
            local tNum = CSResourceMgr.getNodeByName(resNameAdvNewC,"tnum")
            tNum:setString(tostring(saodangTiaoJian[2]).."/"..allQcTimes[currTab])
            local datainfo = advInfo[currTab]
            pNumText = datainfo.power   --Difficulties[currTab].actionValue
            local pNum = CSResourceMgr.getNodeByName(resNameAdvNewC,"pnum")
            pNum:setString(CharInfo.getActionValue().."/"..pNumText)
            --扫荡条件判断
            --获得当前还能扫荡的次数
            local timesLeft = saodangTiaoJian[2]
            if timesLeft > qcPerTimes[currTab] then timesLeft = qcPerTimes[currTab] end
            local saodangtenbtntext = CSResourceMgr.getNodeByName(resNameAdvNewC,"sdsctext")
            
            local strtext = CocosModuleMgr.createStringWithFormat({saodangtentext,tostring(timesLeft)})
            print("saodangtentext......"..strtext)
            setLabel(saodangtenbtntext,strtext,{r=0,g=0,b=0,a=255},{r=242,g=255,b=239,a=255},30,nil,150) 
           
            saodangTiaoJian[3] = timesLeft
            
            --判断是否引导正确
            local val1 = SystemInfo.getGlobalConfigAddInfoByID(21010).values[1]
            --local val = SystemInfo.getGlobalConfigAddInfoByID(24009).values[1]

            local mapLock = CharInfo.get().maplock
            --print("charlock & val1"..mapLock,val1)
            if tonumber(mapLock)<tonumber(val1) then --扫荡变灰
                local btn_saodang = CSResourceMgr.getNodeByName(resNameAdvNewC,"saodangbtn")
                local btn_saodangX10 = CSResourceMgr.getNodeByName(resNameAdvNewC,"saodangtenbtn")
                CSResourceMgr.setButtonEnabledByNode(btn_saodang,false)
                CSResourceMgr.setButtonEnabledByNode(btn_saodangX10,false)
            else
                local btn_saodang = CSResourceMgr.getNodeByName(resNameAdvNewC,"saodangbtn")
                local btn_saodangX10 = CSResourceMgr.getNodeByName(resNameAdvNewC,"saodangtenbtn")
                CSResourceMgr.setButtonEnabledByNode(btn_saodang,true)
                CSResourceMgr.setButtonEnabledByNode(btn_saodangX10,true)
            end
        end
    end

end


--此函数判断是否能够扫荡 
--@param _tnum 扫荡的次数
--@param _actionnum 扫荡所需的体力
local function canSaodang(_tnum,_actionnum)
    
    if _tnum == 0 then _tnum = 1 end
    if CharInfo.getActionValue() < _tnum*_actionnum then --体力不够
        StandardTipsMgr.show(1,needtltext)
        ExchangeViewMgr.show(SceneMgr.getRunningScene,1, function()
            AdvConfirmMgrNew.refreshSaodangInfo(SearchingMapMgr.currAdventure)
        end)
        return false;
    end
    
    return true
    
end

---获取玩家的挑战信息:现在只包括挑战次数

local function getUserChanllengInfo()

       
    NetInterface.send("GC_TerritoryCountInfo_Ack",function()
        local TerritorialInfoSend = require("src.Net.Send.TerritorialSend")
        TerritorialInfoSend.sendCG_TerritoryCountInfo_Req() 
        end,
        function() 
      
            if currTab == 4 then
                local challenlabel = CSResourceMgr.getNodeByName(resNameAdvNewC,"challentimes")
                local challeninfo = TerritorialInfo.getChallengeInfo()
                local challentext = challeninfo.maxCount - challeninfo.tcount.."/"..challeninfo.maxCount
                maxChallenTimes = challeninfo.maxCount
                curChallenTimes = challeninfo.maxCount - challeninfo.tcount
                curBuyTimes = challeninfo.buyCount 
               
                --print("getUserChanllengInfo().................."..challentext)
                challenlabel:setString(challentext)
            end
        end,
    
        function(code)
            TipsMgr.showError(nil,code)
        end)
    
end

---此函数读取副本领主的信息
--@param _fubenid int 副本的id
local function getStageLZBossInfo(_fubenid)
    print("getStageLZBossInfo........")
    currLzBossinfo = nil
    bosspets = {
        m_pets = {},
        h_pets = {},
    }

    if #terrAwardTbl ==0 then return end
    TerritorialInfo.getStageBossInfo(normalAdvId,function(info) --读取领主信息
        if info.adventureID~=normalAdvId then  return 
        end 
        
        local function initLzInfo()
            if info.charID then
                lznickname = info.nickname
                lzfamilyname = info.familyName or "--"
                lzAvartarInfo = info
                
                -- 设置领主宠物
                local i = 0
                for k,v in pairs(info.pets) do
                    bosspets["m_pets"][k] = v
                end
                if info.helpPets then
                    for k,v in pairs(info.helpPets) do
                        bosspets["h_pets"][k] = v
                    end
                else
                    print("ERROR: help pets is null...")
                    bosspets["h_pets"] = {}
                end
                
                if currTab == 4 then
                    -- 获得编队宠物信息
                    showLingZhuTeam()
                end
            else
                lzAvartarInfo = nil
                lznickname = "--"
                lzfamilyname = "--"
                PlayerAnimeMgr.removePlayerByTag("AdvConfirmNew_AnimPlay",true)

                if currTab == 4 then
                    showLingZhuTeam()
                end
            end
        end
        
        --local funcTable = {initLzInfo}
        --UnblockLoader.load(funcTable, "AdvConfirmMgrNew-getLzInfo")

        
        local function setLzNameAndFamily() 
            --设置领主的名称以及家族名称
            local bossname = CSResourceMgr.getNodeByName(resNameAdvNewA,"bossname")
            local familyname = CSResourceMgr.getNodeByName(resNameAdvNewA,"familyname")
    
            setLabel(bossname,lznickname,nil,{r=242,g=255,b=239,a=255})
            setLabel(familyname,lzfamilyname,nil,{r=242,g=255,b=239,a=255})  

            --阿杜修改英文版显示
            if LuaSqlite.LANG_TYPE == 3 then 
                local lzName = CSResourceMgr.getNodeByName(resNameAdvNewA,"LzText")
                local posX = lzName:getPositionX()
                local width = lzName:getContentSize().width
                bossname:setPositionX(posX+width+10)
                local jzName = CSResourceMgr.getNodeByName(resNameAdvNewA,"JzText")
                local posX2 = jzName:getPositionX()
                local width2 = jzName:getContentSize().width
                familyname:setPositionX(posX2+width2+10)
            end
        end
        
        --UnblockLoader.cancel("AdvConfirmMgrNew-getLzInfo")  
        --local funcTable = {initLzInfo,setLzNameAndFamily}
        --UnblockLoader.load(funcTable, "AdvConfirmMgrNew-getLzInfo")       
        initLzInfo()
        setLzNameAndFamily() 
        showLZAvatarInfo(true)
        
        if info.charID == CharInfo.getCharID() then
            local label = CSResourceMgr.getNodeByName(resNameAdvNewA,"lairdBuff")
            CSResourceMgr.setLabelColorByNode(label,{r=0,g=255,b=0,a=255})
            CSResourceMgr.setLabelStringByNode(label,lairdBuffText)
            label:setVisible(true)
        else
            local label = CSResourceMgr.getNodeByName(resNameAdvNewA,"lairdBuff")
            label:setVisible(false)
        end
    end)
end

local function hideUI()

    -- AdvPetsMgr.Init()
    -- SceneMgr.setMapVisible(true)
    UnblockLoader.cancel("AdvConfirmMgrNew-getLzInfo")  
    UnblockLoader.cancel("AdvConfirmMgrNew-AddUI")
    --UnblockLoader.cancel("AdvConfirmMgrNew-getLzInfo")

    PlayerAnimeMgr.removePlayerByTag("AdvConfirmNew_AnimPlay")
--    local pageview = CSResourceMgr.getNodeByName(resNameAdvNewC,"teamVeiw")
--    if pageview then 
--        pageview:removeAllPages()
--    end

    local ydbg = CSResourceMgr.getNodeByName(resNameAdvNew,"yudibg")
    if ydbg then
        ydbg:removeAllChildren()
    end
    CSResourceMgr.removeCSObjectByTag(resNameAdvNewC)
    CSResourceMgr.removeCSObjectByTag(resNameAdvNewA)
    CSResourceMgr.removeCSObjectByTag(resNameAdvNew)
    CSResourceMgr.removeCSObjectByTag(resNameBg,"advConfirmNewBg")
    CSResourceMgr.removeCSObjectByTag(resNameAdvNewD)
    CSResourceMgr.removeCSObjectByTag(resNameTopRight,"advConfirNewTopRight")
    CSResourceMgr.removeCSObjectByTag(resNameTopLeft,"advConfirNewTopLeft")
    
    advInfo = {
        [1] = {},
        [2] = {},
        [3] = {},
    }
    encounterBar = nil 
    dropBar =nil
    advUI = nil
    topUI = nil
    midUI = nil
    bottomUI = nil;
    dIconTbl = {}  --drops
    terrAwardTbl = {} --副本奖励信息
    saodangTiaoJian = {}--完成星数、扫荡券、体力
    yudi = {}
    lzinfo = {}
    currLzBossinfo = {}
    bosspets = {}
    currTab = -1
    lzAvartarInfo = nil
end

local function resetQcCount(_advID, _callback)
    NetInterface.sendWithBlock("GC_RESETADVENTURETIMES_ACK",function()
        local AdventrueSend = require("src.Net.Send.AdventureSend")
        AdventrueSend.sendCG_ResetAdventureTimes_Req({adventureID = _advID,})
    end,function()
        if _callback then _callback() end
    end)
end

local function checkVipAuth(_vipLevel)
    
end

local function showResetTips(__advID)
    local vipLevel = CharInfo.getVIPLevel()  -- VIP_ID
    local vipInfo  = CharInfo.getVipInfoByID(vipLevel)

    local info = AdventureInfo.getFinishedByID(__advID)
    local qcupdatetime = info.qcupdatetime or 0

    -- 一天重置一次重置次数
    local offsetTime = SystemInfo.getGlobalConfigAddInfoByID(6900).values[1]
    local dayDiff = CocosModuleMgr.getDayTimeDiff(qcupdatetime, CharInfo.getServerTime(), offsetTime)
    if dayDiff ~= 0 then
        info.qcrefreshtimes = 0
    end

    local resetCount = info.qcrefreshtimes or 0
    local reCountMax = vipInfo.reCommon
    local countLeft = reCountMax - resetCount
    
    local VIP_MAX = SystemInfo.getGlobalConfigAddInfoByID(55).values[1]
    if countLeft == 0 and vipLevel == VIP_MAX then
        StandardTipsMgr.show(1, CocosModuleMgr.createStringWithFormat({"advtips6",CharInfo.getVipInfoByID(VIP_MAX).reCommon}))
        return
    end

    local consumeNum = AdventureInfo.getResetInfoByID(resetCount + 1).cost

    local tip = CocosModuleMgr.createStringWithFormat({"advtips2",consumeNum,vipInfo.viplevel,reCountMax,countLeft})

    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, tip, function()
        if CharInfo.getMCash() < consumeNum then
            StandardTipsMgr.show(1, "advtips4")
            return
        end
        
        if countLeft <= 0 then
            local nextLevel = vipLevel
            local _reCommon = reCountMax
            while _reCommon <= reCountMax do
                nextLevel = nextLevel + 1
                _reCommon = CharInfo.getVipInfoByID(nextLevel).reCommon
            end
            
            local _tip = CocosModuleMgr.createStringWithFormat({"advtips3", nextLevel})
            
            StandardTipsMgr.show(1, _tip)
            return
        end
        
        resetQcCount(__advID, function()
        end)
    end)
end


local function saodangStart()
    --print("sao dang start.....................................................................")
    
    if currTab~=4 then
        -- 三皇冠以下不能扫荡
        local starcnt = saodangTiaoJian[1]
        if starcnt < 3 then
            StandardTipsMgr.show(1,lowCrown)
            return false
        end

        local timesLeft = saodangTiaoJian[2]
        if currTab == 3 and timesLeft <= 0 then
            showResetTips(SearchingMapMgr.currAdventure)
            return 
        end
        
        if canSaodang(1,tonumber(pNumText)) == true then
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

                    --[[
                    local tNumText = ItemInfo.getCharItemNum(ticket_id)
                    local tNum = CSResourceMgr.getNodeByName(resNameAdvNewC,"tnum")
                    tNum:setString(tNumText)
                    ]]
                    
                    refreshSaodangInfo(SearchingMapMgr.currAdventure)
                end,
                function()
                    --print("saodang 连接中...")
                end)
        end
    else
        GameAudio.playUISound("popup")
        StageBossListMgr.show(SceneMgr.getRunningScene)
    end

     
     --如果是领主tab页--zhu shi diao
     --StageBossListMgr.show(SceneMgr.getRunningScene)
     
end

local function saodangx10Start()
    -- vip<1>以下不能多次扫荡
    local vipAtLeast = SystemInfo.getGlobalConfigAddInfoByID(72).values[1]
    if CharInfo.getVIPLevel() - 1 < vipAtLeast then
        StandardTipsMgr.show(1,CocosModuleMgr.createStringWithFormat({"Territorialtips23", vipAtLeast}))
        return
    end

    -- 三皇冠以下不能扫荡
    local starcnt = saodangTiaoJian[1]
    if starcnt < 3 then
        StandardTipsMgr.show(1,lowCrown)
        return false
    end

    local timesLeft = saodangTiaoJian[2]
    if currTab == 3 and timesLeft <= 0 then 
        showResetTips(SearchingMapMgr.currAdventure)
        return
    end

    if canSaodang(saodangTiaoJian[3],tonumber(pNumText)) == true then
        if not NetInterface.isConnect then return end
        
        local _isManyTimes = 1  -- 多次扫荡标志
        if saodangTiaoJian[3] > 1 then _isManyTimes = saodangTiaoJian[3] end
        if saodangTiaoJian[3] == 1 then _isManyTimes = 0 end -- 仅有一次时不为多次扫荡
        NetInterface.sendWithBlock("GC_QUICKCLEARADVENTURE_ACK", 
        function() 
            local AdventureSend = require("src/Net/Send/AdventureSend.lua")
            AdventureSend.sendCG_QuickClearAdventure_Req({
                adventureID = SearchingMapMgr.currAdventure,
                clearType   = 0,  -- 扫荡类型 0:扫荡券
                isManyTimes = _isManyTimes,   -- 是否连续扫荡 1 是 0 否
            })
        end, 
        function()
            refreshSaodangInfo(SearchingMapMgr.currAdventure)
        end,
        function()
            --print("saodangX10 连接中...")
        end)
    end    
end



---界面逻辑刷新通用接口
---@param isCountDownRefresh bool 是否是倒计时终结调用
local function refresh(isCountDownRefresh)

    if not CSResourceMgr.getCsbObj(resNameAdvNew) then return end
    
    local countDownEnd = isCountDownRefresh or false
    if currTab == 4 then --领主
        local timeCountDown = CSResourceMgr.getNodeByName(resNameAdvNewC,"lzcountdown")
        local lzDesc = CSResourceMgr.getNodeByName(resNameAdvNewC,"miaoshulz")
        lzinfo = TerritorialInfo.getAdventureTerritorialInfo(normalAdvId)
        if lzinfo.boolOpen == true then --领主挑战开放了
            setLabel(lzDesc,challengetimeleft,nil,{r=242,g=255,b=239,a=255},nil,nil,200)  
            local tansuoBtn = CSResourceMgr.getNodeByName(resNameAdvNewC,"TanSuoBtn")
            CSResourceMgr.setButtonEnabled(resNameAdvNewC,"TanSuoBtn",true)
            timeCountDown:setVisible(true)
        else
            -- setLabel(lzDesc,opentimeleft,nil,{r=242,g=255,b=239,a=255},nil,nil,200)  
            CSResourceMgr.setButtonEnabled(resNameAdvNewC,"TanSuoBtn",false)
            
            local timeStr = StageBossListMgr.getStageBeginTime(normalAdvId)
            CSResourceMgr.setLabelStringByNode(lzDesc,CocosModuleMgr.createStringWithFormat({"Territorialtext13",timeStr}))
            timeCountDown:setVisible(false)
        end

        getStageLZBossInfo()
        showLZAvatarInfo(true)
        getUserChanllengInfo()
        
        if countDownEnd == true then 
            if lzinfo.countdown ~=0 then
                CocosModuleMgr.setTimeLabelCountDown(timeCountDown,lzinfo.countdown,function() refresh(true)  end)
             end
        else
            CocosModuleMgr.setTimeLabelCountDown(timeCountDown,lzinfo.countdown,function() refresh(true)  end)
        end
    elseif currTab > 0 then
        getStageLZBossInfo()   
    else
        return    
    end
end

--遇敌掉落Icon设置, 根据副本id读取信息
--@param _advId 当前的副本id
local function setWithAdvID(_advId)
    
    -- 已完成皇冠设置
    local starRecord = (AdventureInfo.getFinishedByID(_advId) ~= nil) and AdventureInfo.getFinishedByID(_advId).star or 0
    AdvStarMgr.setStars({},starRecord,nil,nil)
    
    local _crowne_db =  CSResourceMgr.getNodeByName(resNameTopLeft,"crowne_db","advConfirNewTopLeft")
    if currTab ~= 4 then
        _crowne_db:setVisible(true)
        local starNum = AdvStarMgr.getStarNumByID(_advId)
        
        for i = 1, AdvStarMgr.STAR_MAX do
            if i <= starNum then CSResourceMgr.seekNodeByName(_crowne_db,"crowne_"..i):setVisible(true)
            else CSResourceMgr.seekNodeByName(_crowne_db,"crowne_"..i):setVisible(false) end
        end
    else
        _crowne_db:setVisible(false)
    end

    local datainfo = nil
    
    datainfo = advInfo[1]
    if _advId > 10000 and _advId < 20000 then
        datainfo = advInfo[2]
    end
    
    if _advId > 20000 then
        datainfo = advInfo[3]
    end
      
    local advNameText = LuaSqlite.getLanguageByKey(datainfo.name)
    local advName = CSResourceMgr.getNodeByName(resNameAdvNewA,"AdvTitle")
    if advNameText ~= "" then
        setLabel(advName,advNameText,{r=40,g=53,b=7,a=255},{r=166,g=242,b=255,a=255},36)
    end
    
    local advDiaoluo = CSResourceMgr.getNodeByName(resNameAdvNew,"diaoluotext")
    setLabel(advDiaoluo,diaoluotext,{r=40,g=53,b=7,a=255},{r=166,g=242,b=255,a=255},24)
    
    getSaoDangInfo(_advId)--获取扫荡的信息
    
    local advDescText = LuaSqlite.getLanguageByKey(datainfo.prompt_1)
    local advDesc = CSResourceMgr.getNodeByName(resNameAdvNew,"miaoshu")
    
    local lzDesc = CSResourceMgr.getNodeByName(resNameAdvNewC,"miaoshulz")
    local timeCountDown = CSResourceMgr.getNodeByName(resNameAdvNewC,"lzcountdown")
    
    --领主阵容
    local lzzrtextLabel = CSResourceMgr.getNodeByName(resNameAdvNew,"lzzrtext")
    
    -- 切换页签不获取领主信息
    --getStageLZBossInfo(normalAdvId)--获得领主老大信息
    
    if currTab~=4 then --不是领主tab
        pNumText = datainfo.power   --Difficulties[currTab].actionValue
        local pNum = CSResourceMgr.getNodeByName(resNameAdvNewC,"pnum")
        if pNumText == nil then
            pNum:setString(pNumText)
        else
            pNum:setString(CharInfo.getActionValue().."/"..pNumText)
        end

        qNumText = datainfo.level   --等级需求
        local qNum = CSResourceMgr.getNodeByName(resNameAdvNewC,"qnum")
        qNum:setString(qNumText)
        
        if AdventureInfo.isFirstAid(_advId) then
            local djxzztext = CSResourceMgr.getNodeByName(resNameAdvNewC,"DengJiText")
            setLabel(djxzztext,djxztext,{r=0,g=0,b=0,a=255},{r=242,g=255,b=239,a=255},30,nil,LuaSqlite.LANG_TYPE ~= 1 and 200 or 90)
            
            if CharInfo.getLevel() < datainfo.level then
                CSResourceMgr.setLabelColorByNode(qNum,{r=255,g=0,b=0,a=255})
                NpcDialogueMgr.show(1361)
            else
                CSResourceMgr.setLabelColorByNode(qNum,{r=255,g=255,b=255,a=255})
            end
        else
            CSResourceMgr.setLabelColorByNode(qNum,{r=255,g=255,b=255,a=255})
            local djxzztext = CSResourceMgr.getNodeByName(resNameAdvNewC,"DengJiText")
            setLabel(djxzztext,djxztext2,{r=0,g=0,b=0,a=255},{r=242,g=255,b=239,a=255},30,nil,LuaSqlite.LANG_TYPE ~= 1 and 200 or 90)
        end
        --扫荡条件判断段
        local starcnt = saodangTiaoJian[1]
        --print("完成星数...................." ..starcnt)
        local btn_saodang = CSResourceMgr.getNodeByName(resNameAdvNewC,"saodangbtn")
        local btn_saodangX10 = CSResourceMgr.getNodeByName(resNameAdvNewC,"saodangtenbtn")
        
        local texNormal   = "Pet/Education/cwxx_anniu_1.png"
        local texPressed  = "Pet/Education/cwxx_anniu_2.png"
        local texDisabled = "Pet/Education/cwxx_anniu3.png"
        if starcnt~=3 then
            --CSResourceMgr.setButtonEnabledByNode(btn_saodang,false)
            --CSResourceMgr.setButtonEnabledByNode(btn_saodangX10,false)
            CSResourceMgr.setButtonTextureByNode(btn_saodang,texDisabled,texDisabled,texDisabled)
            CSResourceMgr.setButtonTextureByNode(btn_saodangX10,texDisabled,texDisabled,texDisabled)
        else
            --CSResourceMgr.setButtonEnabledByNode(btn_saodang,true)
            --CSResourceMgr.setButtonEnabledByNode(btn_saodangX10,true)
            CSResourceMgr.setButtonTextureByNode(btn_saodang,texNormal,texPressed,texDisabled)
            CSResourceMgr.setButtonTextureByNode(btn_saodangX10,texNormal,texPressed,texDisabled)
        end
        -- vip<1>以下不能多次扫荡, 按钮置灰
        local vipAtLeast = SystemInfo.getGlobalConfigAddInfoByID(72).values[1]
        if CharInfo.getVIPLevel() - 1 < vipAtLeast then
            CSResourceMgr.setButtonTextureByNode(btn_saodangX10,texDisabled,texDisabled,texDisabled)
        end

        local tsBtn = CSResourceMgr.getNodeByName(resNameAdvNewC,"TanSuoBtn")
        --探索条件判断,jy关卡
        if AdventureInfo.isFirstAid(SearchingMapMgr.currAdventure) and CharInfo.getLevel() < tonumber(datainfo.level) then
            CSResourceMgr.setButtonEnabledByNode(tsBtn,false)
        else
            CSResourceMgr.setButtonEnabledByNode(tsBtn,true)    
        end  
--        if _advId > 10000 and _advId < 20000 then
--            if AdventureInfo.isFirstAid(SearchingMapMgr.currAdventure) and CharInfo.getLevel()<tonumber(advInfo[1].level) then
--                CSResourceMgr.setButtonEnabledByNode(tsBtn,false)
--            else
--                CSResourceMgr.setButtonEnabledByNode(tsBtn,true)  
--            end
--        elseif _advId > 20000 and _advId < 30000 then
--            if AdventureInfo.isFirstAid(SearchingMapMgr.currAdventure) and CharInfo.getLevel()<tonumber(advInfo[1].level) then
--                CSResourceMgr.setButtonEnabledByNode(tsBtn,false)
--            else
--                CSResourceMgr.setButtonEnabledByNode(tsBtn,true)  
--            end
--        else
--            if AdventureInfo.isFirstAid(SearchingMapMgr.currAdventure) and CharInfo.getLevel() < tonumber(advInfo[currTab].level) then
--                CSResourceMgr.setButtonEnabledByNode(tsBtn,false)
--            else
--                CSResourceMgr.setButtonEnabledByNode(tsBtn,true)    
--            end      
--        end
        setLabel(advDesc,advDescText,{r=0,g=0,b=0,a=255},{r=242,g=255,b=239,a=255},22,500)
        lzDesc:setString("")
        --lzzrtextLabel:setString("")
        timeCountDown:setString("")
        transition.stopTarget(timeCountDown)
    else
        getUserChanllengInfo() --领主tab才需要获得信息
        advDesc:setString("")
        setLabel(lzzrtextLabel,lzzhenrongtext,{r=194,g=114,b=71,a=255},{r=255,g=255,b=255,a=255},24,nil,100)   

        lzinfo = TerritorialInfo.getAdventureTerritorialInfo(normalAdvId)
        if lzinfo.boolOpen == true then --领主挑战开放了
            --advDesc:setString(challengetimeleft)
            --setLabel(lzDesc,challengetimeleft,{r=0,g=0,b=0,a=255},{r=242,g=255,b=239,a=255})  
            setLabel(lzDesc,challengetimeleft,nil,{r=242,g=255,b=239,a=255},nil,nil,200) 
            local tansuoBtn = CSResourceMgr.getNodeByName(resNameAdvNewC,"TanSuoBtn")
            CSResourceMgr.setButtonEnabled(resNameAdvNewC,"TanSuoBtn",true)
            timeCountDown:setVisible(true)
        else
            --advDesc:setString(opentimeleft)
            --setLabel(lzDesc,opentimeleft,{r=0,g=0,b=0,a=255},{r=242,g=255,b=239,a=255})  
            --setLabel(lzDesc,opentimeleft,nil,{r=242,g=255,b=239,a=255},nil,nil,200)
            CSResourceMgr.setButtonEnabled(resNameAdvNewC,"TanSuoBtn",false)

            local timeStr = StageBossListMgr.getStageBeginTime(normalAdvId)
            CSResourceMgr.setLabelStringByNode(lzDesc,CocosModuleMgr.createStringWithFormat({"Territorialtext13",timeStr}))
            timeCountDown:setVisible(false)
        end
        
        --local h,m,s = countDownTime(lzinfo.countdown)
        --performCountDown(timeCountDown,h,m,s,"","")
        CocosModuleMgr.setTimeLabelCountDown(timeCountDown,lzinfo.countdown,function()
            refresh()
        end)
        
        --阿杜修改英文版显示
        if LuaSqlite.LANG_TYPE ~= 1 then 
            local posX = lzDesc:getPositionX()
            local width = lzDesc:getContentSize().width
            timeCountDown:setPositionX(posX+width)
        end


    end

    --设置领主的名称以及家族名称
    local bossname = CSResourceMgr.getNodeByName(resNameAdvNewA,"bossname")
    local familyname = CSResourceMgr.getNodeByName(resNameAdvNewA,"familyname")

    setLabel(bossname,lznickname,nil,{r=242,g=255,b=239,a=255})
    setLabel(familyname,lzfamilyname,nil,{r=242,g=255,b=239,a=255})

    --阿杜修改英文版显示
    if LuaSqlite.LANG_TYPE ~= 1 then 
        local lzName = CSResourceMgr.getNodeByName(resNameAdvNewA,"LzText")
        local posX = lzName:getPositionX()
        local width = lzName:getContentSize().width
        bossname:setPositionX(posX+width+10)
        local jzName = CSResourceMgr.getNodeByName(resNameAdvNewA,"JzText")
        local posX2 = jzName:getPositionX()
        local width2 = jzName:getContentSize().width
        familyname:setPositionX(posX2+width2+10)
    end
end

---此函数读取领主的奖励
--@param _fubenid int 副本的id
local function getTerriorAwardById(_fubenid)
    local terrioData = TerritorialInfo.getTerritorialInfoByID(_fubenid)
    terrAwardTbl= {}
    if terrioData == nil then return end
    local awardVec = terrioData.territorialList[1].award

    for k,v in pairs(awardVec) do
        local itemdata;
        itemdata = TerritorialInfo.getTerritorialAwardInfoByID(v)
        table.insert(terrAwardTbl,itemdata)
        print("itemdata.............:"..itemdata.id..itemdata.id)
    end
end



---初始化副本信息,此函数只在打开界面调用一次
--@param _curadv 当前副本的初始信息
local function initData(_curadv)
    local aid = _curadv % 10000
    
    AdvPetsMgr.Init()   -- pet init [clear data]
    
    normalAdvId = aid
    initFBSearchCondition(aid)

    advInfo[1] = AdventureInfo.getAdventureInfoByID(aid) --先读取普通地图
    if advInfo[1] == nil then
        TipsMgr.show(SceneMgr.getRunningScene,"get adventure info"..aid.. "failed")
        --print("ADV_DEBUG_INFO: get adventure info failed, make sure  that the file [AdventureInfo.dat] is correct.")
        return
    end
    
    if advInfo[1].diffcultType > 1 then --普通+精英
        --读出精英关卡的内容
        local advId = aid+10000
        advInfo[2] = AdventureInfo.getAdventureInfoByID(advId)
        if advInfo[2] == nil then
            TipsMgr.show(SceneMgr.getRunningScene,"get adventure info"..advId.. "failed")
        end
    end
    
    if advInfo[1].diffcultType >2 then --普通+精英+英雄
        --读出精英关卡的内容
        local advId = aid+20000
        advInfo[3] = AdventureInfo.getAdventureInfoByID(advId)
        if advInfo[3] == nil then
            TipsMgr.show(SceneMgr.getRunningScene,"get adventure info"..advId.. "failed")
        end
    end
    
    bosspets = {
        m_pets = {},
        h_pets = {},
    }
    print("getTerriorAwardById"..aid)
    getTerriorAwardById(aid)

end


---根据副本的数据初始化UI的布局
--@param tab1 button 普通按钮
--@param tab2 button 精英按钮
--@param tab3 button 英雄按钮
--@param tab4 button 领主按钮
local function uiLayerInit(tab1,tab2,tab3,tab4)
    if advInfo[1].diffcultType == 1 then --只有普通
        local tab2x,tab2y = tab2:getPosition()
        tab4:setPosition(tab2x,tab2y)
        tab2:setVisible(false)
      
        tab3:setVisible(false)
    end
    
    if advInfo[1].diffcultType == 2 then --只有普通+精英
        local tab3x,tab3y = tab3:getPosition()
        local tab2x,tab2y = tab2:getPosition()
        
        local tab1info = AdventureInfo.getFinishedByID(normalAdvId)
        local tab2info = AdventureInfo.getFinishedByID(normalAdvId+eliteNumber)

        if tab1info.star > 0 then        --如果普通过关了,显示精英,同时领主标签去tab3的位置
            tab2:setVisible(true)
            tab3:setVisible(false)
            tab4:setPosition(tab3x,tab3y)
        else --如果没有过关,不显示精英，同时领主标签去tab2的位置
            tab2:setVisible(false)
            tab3:setVisible(false)
            tab4:setPosition(tab2x,tab2y)
        end
        --tab4:setPosition(tab3x,tab3y)
        --tab3:setVisible(false)
    end   
    
    if advInfo[1].diffcultType == 3 then --普通+精英+英雄
         local tab3x,tab3y = tab3:getPosition()
         local tab2x,tab2y = tab2:getPosition()     
         
        local tab1info = AdventureInfo.getFinishedByID(normalAdvId)
        local tab2info = AdventureInfo.getFinishedByID(normalAdvId+eliteNumber) 
    
        local tab3info = AdventureInfo.getFinishedByID(normalAdvId+heroNumber) 
        
        if tab2info.star>0 then --如果精英过关了，现实普通、精英、英雄
        
            tab1:setVisible(true)
            tab2:setVisible(true)
            tab3:setVisible(true)
            
        elseif tab1info.star>0 then --如果只有普通过关，精英没有过
            
            tab2:setVisible(true)
            tab3:setVisible(false)
            tab4:setPosition(tab3x,tab3y)  
            
        else--如果没有过关,不显示精英，同时领主标签去tab2的位置
            tab2:setVisible(false)
            tab3:setVisible(false)
            tab4:setPosition(tab2x,tab2y)                   
        end
        
        
    end
    
    print("OpenLevel:,terrAwardTbl:"..OpenLevel,#terrAwardTbl)
    
    if CharInfo.get().maplock >= OpenLevel and AdvStarMgr.checkClearFlag(normalAdvId) and #terrAwardTbl >  0 then
        tab4:setVisible(true)  
    else
        tab4:setVisible(false)           
    end
end

---tab切换的统一效果函数，为了方便
--@param btncheck 选中的按钮
--@param btncacel1 未选中的按钮1
--@param btncacel2 未选中的按钮2
--@param btncacel3 未选中的按钮3
--@param check     选中的空间          
--@param cancel1   取消的控件1    
--@param cancel2   取消的控件2
--@param cancel3   取消的控件3
--@param checktext 选中的文本
--@param cancel1text 未选中选中的文本 1     
--@param cancel2text 未选中选中的文本 2  
--@param cancel3text 未选中选中的文本 3

local function effectChange(btncheck,btncacel1,btncancel2,btncancel3,check,cancel1,cancel2,cancel3,checktext,cancel1text,cancel2text,cancel3text)
    CSResourceMgr.setButtonEnabledByNode(btncheck,false)
    CSResourceMgr.setButtonEnabledByNode(btncacel1,true)
    CSResourceMgr.setButtonEnabledByNode(btncancel2,true)
    CSResourceMgr.setButtonEnabledByNode(btncancel3,true)

    btncheck:setScale(1.1)
    --btncheck:setPositionY(originTabPos+1)
    btncheck:setLocalZOrder(1)

    --btncacel1:setPositionY(originTabPos)
    btncacel1:setLocalZOrder(-1)
    btncacel1:setScale(1)

    --btncancel2:setPositionY(originTabPos)
    btncancel2:setLocalZOrder(-1)
    btncancel2:setScale(1)

    --btncancel3:setPositionY(originTabPos)
    btncancel3:setLocalZOrder(-1)
    btncancel3:setScale(1)

    setLabel(check, checktext, Difficulties.common.outline[2], Difficulties.common.textColor[2], nil,nil,120)
    setLabel(cancel1,  cancel1text, Difficulties.common.outline[1], Difficulties.common.textColor[1], nil,nil,120)
    setLabel(cancel2,  cancel2text, Difficulties.common.outline[1], Difficulties.common.textColor[1], nil,nil,120)
    setLabel(cancel3,  cancel3text, Difficulties.common.outline[1], Difficulties.common.textColor[1], nil,nil,120)
end





local function uiChange() --点击UI切换

    if currTab~=4 then --副本
        CSResourceMgr.getNodeByName(resNameAdvNewC,"lzrnode"):setVisible(false)
        CSResourceMgr.getNodeByName(resNameAdvNewC,"saodangtenbtn"):setVisible(true)
        CSResourceMgr.getNodeByName(resNameAdvNewC,"saodangbtn"):setPosition(515, -22)
         
        local saodangbtntext = CSResourceMgr.getNodeByName(resNameAdvNewC,"sdtext")
        setLabel(saodangbtntext,saodangtext,{r=0,g=0,b=0,a=255},{r=242,g=255,b=239,a=255},30,nil,120)
        
        CSResourceMgr.getNodeByName(resNameAdvNewC,"TiLiText"):setVisible(true)
        CSResourceMgr.getNodeByName(resNameAdvNewC,"DengJiText"):setVisible(true)
        CSResourceMgr.getNodeByName(resNameAdvNewC,"pnum"):setVisible(true)
        CSResourceMgr.getNodeByName(resNameAdvNewC,"qnum"):setVisible(true)

        CSResourceMgr.getNodeByName(resNameAdvNewC,"SdQuanText"):setVisible(not (currTab == 1 or currTab == 2))
        CSResourceMgr.getNodeByName(resNameAdvNewC,"count_db"):setVisible(not (currTab == 1 or currTab == 2))
        CSResourceMgr.getNodeByName(resNameAdvNewC,"tnum"):setVisible(not (currTab == 1 or currTab == 2))
        if currTab == 1 or currTab == 2 then
            CSResourceMgr.getNodeByName(resNameAdvNewC,"DengJiText"):setPositionY(-36)
            CSResourceMgr.getNodeByName(resNameAdvNewC,"qnum"):setPositionY(-36)

            CSResourceMgr.getNodeByName(resNameAdvNewC,"TiLiText"):setPositionY(-67)
            CSResourceMgr.getNodeByName(resNameAdvNewC,"pnum"):setPositionY(-67)
        else
            CSResourceMgr.getNodeByName(resNameAdvNewC,"DengJiText"):setPositionY(-26)
            CSResourceMgr.getNodeByName(resNameAdvNewC,"qnum"):setPositionY(-26)

            CSResourceMgr.getNodeByName(resNameAdvNewC,"TiLiText"):setPositionY(-57)
            CSResourceMgr.getNodeByName(resNameAdvNewC,"pnum"):setPositionY(-57)
        end
        --阿杜修改英文版显示
        if LuaSqlite.LANG_TYPE~= 1 then
            local posX = CSResourceMgr.getNodeByName(resNameAdvNewC,"DengJiText"):getPositionX()
            local width = CSResourceMgr.getNodeByName(resNameAdvNewC,"DengJiText"):getContentSize().width
            CSResourceMgr.getNodeByName(resNameAdvNewC,"qnum"):setPositionX(posX+width+10)
            local posX2 = CSResourceMgr.getNodeByName(resNameAdvNewC,"TiLiText"):getPositionX()
            local width2 = CSResourceMgr.getNodeByName(resNameAdvNewC,"TiLiText"):getContentSize().width
            CSResourceMgr.getNodeByName(resNameAdvNewC,"pnum"):setPositionX(posX2+width2+10)
        end
    else --领主
        CSResourceMgr.getNodeByName(resNameAdvNewC,"lzrnode"):setVisible(true)
        CSResourceMgr.getNodeByName(resNameAdvNewC,"saodangtenbtn"):setVisible(false)       
        
        local saodangbtntext = CSResourceMgr.getNodeByName(resNameAdvNewC,"sdtext")
        setLabel(saodangbtntext,phbtext,{r=0,g=0,b=0,a=255},{r=242,g=255,b=239,a=255},30,nil,120) 
        local btn_saodang = CSResourceMgr.getNodeByName(resNameAdvNewC,"saodangbtn")
        CSResourceMgr.setButtonEnabledByNode(btn_saodang,true)
        btn_saodang:setPosition(112, -80)
        
        local texNormal   = "Pet/Education/cwxx_anniu_1.png"
        local texPressed  = "Pet/Education/cwxx_anniu_2.png"
        local texDisabled = "Pet/Education/cwxx_anniu3.png"
        CSResourceMgr.setButtonTextureByNode(btn_saodang,texNormal,texPressed,texDisabled)

        CSResourceMgr.getNodeByName(resNameAdvNewC,"TiLiText"):setVisible(false)
        CSResourceMgr.getNodeByName(resNameAdvNewC,"DengJiText"):setVisible(false)
        CSResourceMgr.getNodeByName(resNameAdvNewC,"pnum"):setVisible(false) 
        CSResourceMgr.getNodeByName(resNameAdvNewC,"qnum"):setVisible(false)    
        CSResourceMgr.getNodeByName(resNameAdvNewC,"SdQuanText"):setVisible(false)
        CSResourceMgr.getNodeByName(resNameAdvNewC,"tnum"):setVisible(false)
        CSResourceMgr.getNodeByName(resNameAdvNewC,"count_db"):setVisible(false)
    end
end


local function initTopAndLeft()
    local topRight = CSResourceMgr.createRes(SceneMgr.getRunningScene,resNameTopRight,"advConfirNewTopRight")
    CSResourceMgr.setFullScreen(resNameTopRight,"advConfirNewTopRight")
    CocosModuleMgr.setEdgeDistance(topRight, nil, 0, 0, nil, false)
    topRight:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW) 
    local close = CSResourceMgr.seekNodeByName(topRight,"btn_close")
    CSResourceMgr.clickEventBindingByNode(close,function() 
        AdvConfirmMgrNew.hide()
    end)  
    
    local topLeft = CSResourceMgr.createRes(SceneMgr.getRunningScene,resNameTopLeft,"advConfirNewTopLeft")
    CSResourceMgr.setFullScreen(resNameTopLeft,"advConfirNewTopLeft")
    CocosModuleMgr.setEdgeDistance(topLeft, 0, nil, 0, nil, false)
    topLeft:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW + 1) 
  
end

local function initadvUIData(_curadv,_curtab)
    print(_curadv, _curtab)

    --转换为数值型
    _curadv = tonumber(_curadv)
    
    local aid = _curadv % 10000
    
    SearchingMapMgr.currAdventure = _curadv
    if _curtab == 1 then
        SearchingMapMgr.currAdventure = aid --默认为普通，精英(1000X), 英雄(2000X)
    end

    if _curtab == 2 then 
        SearchingMapMgr.currAdventure = aid+10000 --默认为普通，精英(1000X), 英雄(2000X)    
    end

    if _curtab == 3 then
        SearchingMapMgr.currAdventure = aid+20000 --默认为普通，精英(1000X), 英雄(2000X)      
    end

    currTab =  _curtab

    --开始初始化
    initData(_curadv)
end

local function csbBottomLogic()

    if currTab~=4 then
        --探索按钮文字
        local tsBtnText = CSResourceMgr.getNodeByName(resNameAdvNewC,"tsbtntext")
        setLabel(tsBtnText,tsbtntext,{r=0,g=0,b=0,a=255},{r=242,g=255,b=239,a=255},30,nil,120)

    else
        --挑战按钮文字
        local tsBtnText = CSResourceMgr.getNodeByName(resNameAdvNewC,"tsbtntext")
        setLabel(tsBtnText,tzbtntext,{r=0,g=0,b=0,a=255},{r=242,g=255,b=239,a=255},30,nil,120)            
    end

    --local saodangtenbtntext = CSResourceMgr.getNodeByName(resNameAdvNewC,"sdsctext")
    --setLabel(saodangtenbtntext,saodangtentext,{r=0,g=0,b=0,a=255},{r=242,g=255,b=239,a=255},30,nil,120)  

    local cstext = CSResourceMgr.getNodeByName(resNameAdvNewC,"csleft")
    setLabel(cstext,challencsleft,{r=0,g=0,b=0,a=255},{r=165,g=208,b=255,a=255},30,nil,90)  

    local tilitext = CSResourceMgr.getNodeByName(resNameAdvNewC,"TiLiText")
    setLabel(tilitext,xhtltext,{r=0,g=0,b=0,a=255},{r=242,g=255,b=239,a=255},30,nil,LuaSqlite.LANG_TYPE ~= 1 and 200 or 90)  

    local sdqqtext = CSResourceMgr.getNodeByName(resNameAdvNewC,"SdQuanText")
    setLabel(sdqqtext,sdqtext,{r=0,g=0,b=0,a=255},{r=242,g=255,b=239,a=255},30,nil,90) 

    local djxzztext = CSResourceMgr.getNodeByName(resNameAdvNewC,"DengJiText")
    if AdventureInfo.isFirstAid(SearchingMapMgr.currAdventure) then
        setLabel(djxzztext,djxztext,{r=0,g=0,b=0,a=255},{r=242,g=255,b=239,a=255},30,nil,LuaSqlite.LANG_TYPE ~= 1 and 200 or 90)
    else
        setLabel(djxzztext,djxztext2,{r=0,g=0,b=0,a=255},{r=242,g=255,b=239,a=255},30,nil,LuaSqlite.LANG_TYPE ~= 1 and 200 or 90)
    end

    uiChange()

    setMyTeam(1)

    refreshSaodangInfo(SearchingMapMgr.currAdventure)

    --扫荡按钮事件
    local btn_saodang = CSResourceMgr.getNodeByName(resNameAdvNewC,"saodangbtn")
    CSResourceMgr.clickEventBinding(resNameAdvNewC,"saodangbtn",saodangStart)
    local btn_saodangX10 = CSResourceMgr.getNodeByName(resNameAdvNewC,"saodangtenbtn")
    CSResourceMgr.clickEventBinding(resNameAdvNewC,"saodangtenbtn",saodangx10Start)    

end



---此函数打开探索界面的UI 
--@param _scene 当前玩家所在的场景 ,类型为scene
--@param _curadv 当前副本的编号,类型为数值型
--@param _curtab 当前的页签号
--@param callback function 加载完成的回调
local function addUI(_scene,_curadv,_curtab,callback)
    if CSResourceMgr.getCsbObj(resNameAdvNew) then
        if normalAdvId ~= _curadv then
            AdvConfirmMgrNew.hide()
        else
            return
        end
    end
    
    
    initadvUIData(_curadv,_curtab)
    --print("resNameBg" ..resNameBg)
    
    _curadv = SearchingMapMgr.currAdventure
    
    --local bgUI = CSResourceMgr.createRes(_scene, resNameBg,"advConfirmNewBg")
    --topUI = CSResourceMgr.createRes(_scene, resNameAdvNewA)
    --bottomUI  = CSResourceMgr.createRes(_scene, resNameAdvNewC)

    --创建那张背景图片
    local function loadBG()
        bgUI = CSResourceMgr.createRes(_scene, resNameBg,"advConfirmNewBg")
        bgUI:setVisible(false)
        bgUI:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)    
        CSResourceMgr.setRelativePosition(resNameBg, 320, 480,"advConfirmNewBg")
    end
    
    local function csbTopLogic()

        --加载关卡图片
        local aid = _curadv % 10000
        local mapIcon = CSResourceMgr.getNodeByName(resNameAdvNewA,"MapIcon")
        mapIcon:loadTexture(WorldMapInfo.getAdventureIcon(aid))

        --加载家族和领主名称
        if CharInfo.get().maplock >= OpenLevel and AdvStarMgr.checkClearFlag(normalAdvId) and #terrAwardTbl >  0 then
            local lzName = CSResourceMgr.getNodeByName(resNameAdvNewA,"LzText")
            local jzName = CSResourceMgr.getNodeByName(resNameAdvNewA,"JzText")
            --阿杜修改英文版显示
            if LuaSqlite.LANG_TYPE == 1 then
                setLabel(lzName,lztitletext,nil,{r=242,g=255,b=239,a=255},23,nil,70)
                setLabel(jzName,jztitletext,nil,{r=242,g=255,b=239,a=255},23,nil,70)  
            else
                setLabel(lzName,lztitletext,nil,{r=242,g=255,b=239,a=255},23)
                setLabel(jzName,jztitletext,nil,{r=242,g=255,b=239,a=255},23)  
            end
       else
            CSResourceMgr.getNodeByName(resNameAdvNewA,"LzText"):setVisible(false)
            CSResourceMgr.getNodeByName(resNameAdvNewA,"JzText"):setVisible(false)
            CSResourceMgr.getNodeByName(resNameAdvNewA,"pic_lzdeco"):setVisible(false)
            CSResourceMgr.getNodeByName(resNameAdvNewA,"bossname"):setVisible(false)
            CSResourceMgr.getNodeByName(resNameAdvNewA,"familyname"):setVisible(false)     
       end
    end
    
    local function loadCSBTop()
        topUI = CSResourceMgr.createRes(_scene, resNameAdvNewA)
        topUI:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        topUI:setVisible(false)
        CSResourceMgr.setFullScreen(resNameAdvNewA)
    
    
        CSResourceMgr.setRelativePosition(resNameAdvNewA, 320, 480)
        CocosModuleMgr.setEdgeDistance(topUI, nil, nil, 0, nil)
    
        --csbTopLogic()

    end
    
    local function loadCSBBotm()
        
        bottomUI  = CSResourceMgr.createRes(_scene, resNameAdvNewC)
        CSResourceMgr.setFullScreen(resNameAdvNewC)
        bottomUI:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        bottomUI:setVisible(false)
        CSResourceMgr.setRelativePosition(resNameAdvNewC, 320, 480)
        CocosModuleMgr.setEdgeDistance(bottomUI, nil, nil, nil, 0)

        
        --csbBottomLogic()
    end

    
 
    
    local function playCSBBottmonAction()

        -- CSResourceMgr.playAllFrame(resNameAdvNew,false)
        
        CocosModuleMgr.showUIAnimation(bottomUI,"up",function() 
            -- showLZAvatarInfo(true)
        end)
        bottomUI:setVisible(true)
     
    end
    
    --创建界面
    local function loadCSBA()
        advUI = CSResourceMgr.createRes(_scene, resNameAdvNew)

        --setYuDiBar(currTab)
        
        CSResourceMgr.setFullScreen(resNameAdvNew)
        advUI:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
       
        advUI:setVisible(false)
        CSResourceMgr.setFullScreen(resNameAdvNew)
        CSResourceMgr.setRelativePosition(resNameAdvNew, 320, 480)
     
        --close按钮绑定
        CSResourceMgr.clickEventBinding(resNameAdvNewA,"closebtn",function()
            AdvConfirmMgrNew.hide()
        end)
        
        --页签绑定
        local formal = CSResourceMgr.getNodeByName(resNameAdvNew,"putongtext")
        local elite  = CSResourceMgr.getNodeByName(resNameAdvNew,"jytext")
        local hero  = CSResourceMgr.getNodeByName(resNameAdvNew,"yxtext")
        local lz = CSResourceMgr.getNodeByName(resNameAdvNew,"lztext")
  
        setLabel(formal, 
            Difficulties[1].text, 
            Difficulties.common.outline[2], 
            Difficulties.common.textColor[2], 
            Difficulties.common.font_size[2]
        )
        setLabel(elite,  
            Difficulties[2].text,  
            Difficulties.common.outline[1], 
            Difficulties.common.textColor[1], 
            Difficulties.common.font_size[1]
        )
        setLabel(hero,  
            Difficulties[3].text,  
            Difficulties.common.outline[1], 
            Difficulties.common.textColor[1], 
            Difficulties.common.font_size[1]
        )
        
        setLabel(lz,  
            Difficulties[4].text,  
            Difficulties.common.outline[1], 
            Difficulties.common.textColor[1], 
            Difficulties.common.font_size[1]
        )
        
        
        local btn_formal = CSResourceMgr.getNodeByName(resNameAdvNew,"pttab")
        local btn_elite = CSResourceMgr.getNodeByName(resNameAdvNew,"jytab")
        local btn_hero = CSResourceMgr.getNodeByName(resNameAdvNew,"yxtab")
        local btn_lz = CSResourceMgr.getNodeByName(resNameAdvNew,"lztab")
        

        btn_formal:setScaleY(1.1)
        CSResourceMgr.setButtonEnabledByNode(btn_formal,false)
        btn_elite:setLocalZOrder(-1)
        btn_hero:setLocalZOrder(-1)  
        
        --页签绑定完毕  
        
        --UI布局显示
        uiLayerInit(btn_formal,btn_elite,btn_hero,btn_lz)
    end
    
    local function playCSBMiddleAction()

       -- CSResourceMgr.playAllFrame(resNameAdvNew,false)
        advUI:setVisible(true)
        CocosModuleMgr.showUIAnimation(advUI,"up")
        
        --[[
        local originx,originy = advUI:getPosition()
        advUI:setPosition(originx,originy-juli1)
      
        transition.execute(advUI, cc.MoveTo:create(time1, cc.p(originx, originy)), {
            delay = 0.0,
            easing = {fangshi1, value1}, 
            onComplete = function()
                print("move completed")
            end,
        })
        --]]
    end
    

    
    local function ButtonBinding()

        local formal = CSResourceMgr.getNodeByName(resNameAdvNew,"putongtext")
        local elite  = CSResourceMgr.getNodeByName(resNameAdvNew,"jytext")
        local hero  = CSResourceMgr.getNodeByName(resNameAdvNew,"yxtext")
        local master  = CSResourceMgr.getNodeByName(resNameAdvNew,"lztext")
        local btn_formal = CSResourceMgr.getNodeByName(resNameAdvNew,"pttab")
        local btn_elite = CSResourceMgr.getNodeByName(resNameAdvNew,"jytab")
        local btn_hero = CSResourceMgr.getNodeByName(resNameAdvNew,"yxtab")   
        local btn_master = CSResourceMgr.getNodeByName(resNameAdvNew,"lztab")     
        
        if currTab == 1 then
            effectChange(btn_formal,btn_elite,btn_hero,btn_master,formal,elite,hero,master,pttabtext,jytabtext,yxtabtext,lingzhutabtext)
        end
        
        if currTab == 2 then
            effectChange(btn_elite,btn_formal,btn_hero,btn_master,elite,formal,hero,master,jytabtext,pttabtext,yxtabtext,lingzhutabtext)
        end
        
        if currTab == 3 then
            effectChange(btn_hero,btn_formal,btn_elite,btn_master,hero,formal,elite,master,yxtabtext,pttabtext,jytabtext,lingzhutabtext)
        end
        
        if currTab == 4 then
            effectChange(btn_master,btn_formal,btn_elite,btn_hero,master,formal,elite,hero,lingzhutabtext,pttabtext,jytabtext,yxtabtext)
        end

   

        
        --普通关卡按钮绑定
        CSResourceMgr.clickEventBinding(resNameAdvNew,"pttab",function()
        
            currTab = 1
            effectChange(btn_formal,btn_elite,btn_hero,btn_master,formal,elite,hero,master,pttabtext,jytabtext,yxtabtext,lingzhutabtext)
            SearchingMapMgr.currAdventure = _curadv % 10000
            SearchingMapMgr.dropTable = {}
            setWithAdvID(SearchingMapMgr.currAdventure)
            setEnctrAndDrop()
                
            --探索按钮文字
            local tsBtnText = CSResourceMgr.getNodeByName(resNameAdvNewC,"tsbtntext")
            setLabel(tsBtnText,tsbtntext,{r=0,g=0,b=0,a=255},{r=242,g=255,b=239,a=255},30,nil,120)
            
            uiChange()
             
            refreshSaodangInfo(SearchingMapMgr.currAdventure)
           
        end,"", nil, "sheetClick")
        
        --PlayerAnimeMgr.createPlayer(parent,params,tag)
        --精英关卡按钮绑定
        CSResourceMgr.clickEventBinding(resNameAdvNew,"jytab",function()
            currTab = 2
            effectChange(btn_elite,btn_formal,btn_hero,btn_master,elite,formal,hero,master,jytabtext,pttabtext,yxtabtext,lingzhutabtext)
            SearchingMapMgr.dropTable = {}
            SearchingMapMgr.currAdventure = _curadv % 10000 + 10000
            setWithAdvID(SearchingMapMgr.currAdventure)
            setEnctrAndDrop()
            --探索按钮文字
            local tsBtnText = CSResourceMgr.getNodeByName(resNameAdvNewC,"tsbtntext")
            setLabel(tsBtnText,tsbtntext,{r=0,g=0,b=0,a=255},{r=242,g=255,b=239,a=255},30,nil,120)
            
            uiChange()
            refreshSaodangInfo(SearchingMapMgr.currAdventure)
        end,"", nil, "sheetClick")  
        
        --英雄关卡按钮绑定
        CSResourceMgr.clickEventBinding(resNameAdvNew,"yxtab",function()
            currTab = 3
            effectChange(btn_hero,btn_formal,btn_elite,btn_master,hero,formal,elite,master,yxtabtext,pttabtext,jytabtext,lingzhutabtext)
            SearchingMapMgr.dropTable = {}
            SearchingMapMgr.currAdventure = _curadv % 10000 + 20000
            setWithAdvID(SearchingMapMgr.currAdventure)
            setEnctrAndDrop()
            --探索按钮文字
            local tsBtnText = CSResourceMgr.getNodeByName(resNameAdvNewC,"tsbtntext")
            setLabel(tsBtnText,tsbtntext,{r=0,g=0,b=0,a=255},{r=242,g=255,b=239,a=255},30,nil,120)
            uiChange()
            refreshSaodangInfo(SearchingMapMgr.currAdventure)
        end,"", nil, "sheetClick")
        
        --领主按钮绑定
        CSResourceMgr.clickEventBinding(resNameAdvNew,"lztab",function()
            currTab = 4
            effectChange(btn_master,btn_formal,btn_elite,btn_hero,master,formal,elite,hero,lingzhutabtext,pttabtext,jytabtext,yxtabtext)
            SearchingMapMgr.dropTable = {}
            SearchingMapMgr.currAdventure = _curadv % 10000 + 20000
            setWithAdvID(SearchingMapMgr.currAdventure)
            setEnctrAndDrop()
            
            local advDiaoluo = CSResourceMgr.getNodeByName(resNameAdvNew,"diaoluotext")
            setLabel(advDiaoluo,lzjianglitext,{r=40,g=53,b=7,a=255},{r=166,g=242,b=255,a=255},24)
            
            --探索按钮文字
            local tsBtnText = CSResourceMgr.getNodeByName(resNameAdvNewC,"tsbtntext")
            setLabel(tsBtnText,tzbtntext,{r=0,g=0,b=0,a=255},{r=242,g=255,b=239,a=255},30,nil,120)
            uiChange()
        end,"", nil, "sheetClick")
        
        setWithAdvID(_curadv)
        getStageLZBossInfo(normalAdvId)
        
        --购买次数按钮绑定
        CSResourceMgr.clickEventBinding(resNameAdvNewC,"addbutton",function()
            local viplevel = CharInfo.getVIPLevel()
            local curmaxbuy = CharInfo.getVipInfoByID(viplevel).terrBuyNum  -- ButTimesTable[tonumber(viplevel)]
            if curBuyTimes >= curmaxbuy then
                StandardTipsMgr.show(1,maxbuy)
                return
            end 
            DialogBoxMgr.showSmallDialogBox(scene, 2, goumaitips, function()
 
                    if tonumber(MCash)>CharInfo.getMCash() then
                        StandardTipsMgr.show(1,"tips14")
                        --TipsMgr.show(SceneMgr.getRunningScene, "tips14")
                        return
                    end
                    NetInterface.sendWithBlock("GC_TerritorialResetInfo_Ack",function() 
                        local BuyChallengSend = require("src.Net.Send.TerritorialSend")
                        print("BuyChallengSend..........................")
                        BuyChallengSend.sendCG_TerritorialResetInfo_Req()
                    end,function()
                        if currTab == 4 then
                            local challenlabel = CSResourceMgr.getNodeByName(resNameAdvNewC,"challentimes")
                            maxChallenTimes = maxChallenTimes+1;
                            curChallenTimes = curChallenTimes+1
                            curBuyTimes = curBuyTimes+1
                            local challentext = curChallenTimes.."/"..maxChallenTimes

                            --print("getUserChanllengInfo().................."..challentext)
                            challenlabel:setString(challentext)
                        end                              
                    end,function(code)
                        errorTipsProcess(tonumber(code))
                        --StandardTipsMgr.show(1,maxbuy)
                    end)
               end)
        end,nil,3)
           
        CSResourceMgr.clickEventBinding(resNameAdvNewC,"TanSuoBtn",function()
            -- 非领主页签检查
            if currTab ~= 4 then
                local timesLeft = saodangTiaoJian[2]
                if currTab == 3 and timesLeft <= 0 then 
                    showResetTips(SearchingMapMgr.currAdventure)
                    return 
                end
                
                if advInfo[currTab].level > CharInfo.getLevel() and AdventureInfo.isFirstAid(SearchingMapMgr.currAdventure) then
                    StandardTipsMgr.show(1,lowlevel)
                    return
                end
            end
        
            local pets = PokemonInfo.getPetArmy(AdvPetsMgr.getCurrTeam())
            local helppets = PokemonInfo.getPetHelpArmy()
     
            if pets == nil or #pets <=0 then --没有宠物
                StandardTipsMgr.show(1,needteammeber)
                return
            end
            if currTab == 4 then --挑战绑定
                local key = normalAdvId
                local mypetsID={}
                --获得编队宠物信息
                --local pets = AdvPetsMgr.getCurrMyPets()
                local function canChallenge()--是否可以挑战 1可以 0不可以
                    if pets == nil or #pets <=0 then --没有宠物
                        StandardTipsMgr.show(1,needteammeber)
                        return 0
                    end 
        
                    if CharInfo.getLevel() < lzinfo.level then
                        --print("lzinfo.levellzinfo.levellzinfo.level"..lzinfo.level)
                        StandardTipsMgr.show(1,lowlevel)
                        return 0
                    end
        
                    local starRecord = AdvStarMgr.getStarNumByID(lzinfo.lock)
        
                    if starRecord < lzinfo.star then
                        StandardTipsMgr.show(1,lowstage)
                        return 0                       
                    end
        
                    return 1
                end
    
                if canChallenge()~=1 then return end
                
                if lzAvartarInfo and lzAvartarInfo.charID and lzAvartarInfo.charID == CharInfo.getCharID() then
                    StandardTipsMgr.show(1,alreadyleizhu)
                    return
                end
    
                NetInterface.send("GC_TerritoryFight_Ack", function()
                    local TerritorialSend = require("src.Net.Send.TerritorialSend")
                    TerritorialSend.sendCG_TerritoryFight_Req({adventureID=key, petsID=pets,helpPetsID = helppets})
                end, function()
                    print("GC_TerritoryFight_Ack finish")
                    local result = 1;
                    if tonumber(TerritorialInfo.getBattleInfo().id) ~= 0 then
                        AdvConfirmMgrNew.hide()
                        
                        local myPets = {}
                        myPets[OUTPETS], myPets[INPETS] = TerritorialInfo.getBattleInfo().self or {}, TerritorialInfo.getBattleInfo().selfHelp or {}
                        local enemyPets = {}
                        enemyPets[OUTPETS], enemyPets[INPETS] = TerritorialInfo.getBattleInfo().enemy or {}, TerritorialInfo.getBattleInfo().enemyHelp or {}
                        
                        BattleMapMgr.setArenaBattle(myPets, enemyPets, function(detail)
                           -- result = AdvConfirmMgrNew.isTerrWin  -- detail.result
                            
                            MapSeekerMgr.SeekFunc = function()
                                addUI(SceneMgr.getRunningScene,normalAdvId,4)
                                
                                if AdvConfirmMgrNew.isTerrWin == PLAYER_WIN then
                                    StandardTipsMgr.show(0,gongxixinlz)
                                else
                                    StandardTipsMgr.show(1,tiaozhanshibai)
                                end
                            end
    
                        end,true)
    
    
                    else
                        StandardTipsMgr.show(0,gongxixinlz)
                        refresh()
    
                    end
                end, 
                function(code)
                    errorTipsProcess(tonumber(code))
                    --TipsMgr.showError(nil, code)
                end) 
                return           
            end
    
            if advInfo == nil then
                print("ADV_DEBUG_INFO: get adventure info failed, make sure  that the file [AdventureInfo.dat] is correct.")
                return
            else
                if canSaodang(1,tonumber(pNumText)) == false then
                    -- StandardTipsMgr.show(1,needtltext)
                    return
                end
    
                if NetInterface.isConnect then
                    print("GC_ACTIVEPETARMY_ACK DONE", currTeamIdx)
                    AdvPetsMgr.setCurrTeam(1)

                    NetInterface.sendWithBlock("GC_CREATEADVENTURE_ACK", function()
                        local AdventureSend = require("src/Net/Send/AdventureSend.lua")
                        AdventureSend.sendCG_CreateAdventure_Req({adventureID = SearchingMapMgr.currAdventure})
                    end, 
                    function()
                        AdvConfirmMgrNew.hide()
                        SearchingMapMgr.initFloorSize()
                        SceneMgr.replaceScene(_scene, "SearchingScene")
                    end, 
                    function()
                    end)
                end
            end

            UIStack.closeAllUI()
            
        end,nil,1) -- end of saodangBtn binding
        
    end
    
    local function playCSBTopAction()
        
        bgUI:setVisible(true)
        -- SceneMgr.setMapVisible(false)
        local top = CSResourceMgr.getCsbObj(resNameAdvNewA)
        top:setVisible(true)
        CocosModuleMgr.showUIAnimation(top,"down")
        
        local crowne_db = CSResourceMgr.getCsbObj(resNameTopLeft,"advConfirNewTopLeft")
        local close = CSResourceMgr.getCsbObj(resNameTopRight,"advConfirNewTopRight")
        CocosModuleMgr.showUIAnimation(crowne_db,"down")  
        CocosModuleMgr.showUIAnimation(close,"down")     
        --[[
        local originx,originy = topUI:getPosition()
        topUI:setPosition(originx,originy+juli1)
        topUI:setOpacity(255)
        transition.execute(topUI, cc.MoveTo:create(time1, cc.p(originx, originy)), {
            delay = 0.0,
            easing = {fangshi1, value1},   
            onComplete = function()
                print("move completed")
            end,
        })
--]]
        playCSBMiddleAction()
        playCSBBottmonAction()
        

    end
   
       
    

   
    loadBG()
    initTopAndLeft()
    
   
    loadCSBTop()
   
    loadCSBA()
    
    loadCSBBotm()

    setEnctrAndDrop()
    ButtonBinding()
    playCSBTopAction()
    csbTopLogic()
    csbBottomLogic()


    if callback then callback() end


--[[
    local funcTable = {loadBG,initTopAndLeft,loadCSBTop,loadCSBA,loadCSBBotm,setEnctrAndDrop,ButtonBinding,csbTopLogic,csbBottomLogic,playCSBTopAction,csbTopLogic,csbBottomLogic,function()
      if callback then callback() end end}
    UnblockLoader.load(funcTable, "AdvConfirmMgrNew-AddUI")
  
 ]]


end

function AdvConfirmMgrNew.show(scene,curadv,curtab,callback)
    UIStack.closeAllUI()
    UIStack.push("AdvConfirmMgrNew",AdvConfirmMgrNew.hide,true)
    addUI(scene,curadv,curtab,callback)
end

function AdvConfirmMgrNew.hide()
    hideUI()
    UIStack.pop("AdvConfirmMgrNew")
    if ItemInfoViewMgr.isInGetWay then
        ItemInfoViewMgr.isInGetWay = false
        if StatusBarMgr.TOPBARSHOW then
            StatusBarMgr.showTopInfoBar(StatusBarMgr.getTopBarCallback(),0)
        end
        PetEducationMgr.refreshUIAfterCallBack()
    end
end

function AdvConfirmMgrNew.refreshServerTime()
    refresh()
end

function AdvConfirmMgrNew.Init()
    --advInfo = nil --探索信息
    advInfo = {
        [1] = {},
        [2] = {},
        [3] = {},
    }
    encounterBar = nil 
    dropBar = nil
    advUI = nil
    topUI = nil
    midUI= nil
    bottomUI=nil
    dIconTbl = {}  --drops
    terrAwardTbl = {} --副本奖励信息
    saodangTiaoJian = {}--完成星数、扫荡券、体力
 


    tNumText = 0; --玩家剩余次数数值文本
    pNumText = 0; --副本所需体力数值文本
    qNumText = 0; --副本所需等级文本
    yudi = {}
    lzinfo={} --领地信息
    currLzBossinfo = {}--当前领地的boss信息
    bosspets = {} --领主的宠物
    currTab = -1
    
    if isLocalDataInited==false then
        resNameBg = "Pet/Formation/FormationBG.csb"
        resNameAdvNewA = "Searching/advConfirm/advConfirmNewUIA.csb"
        resNameAdvNew = "Searching/advConfirm/advConfirmNewUIB.csb"
        resNameAdvNewC = "Searching/advConfirm/advConfirmNewUIC.csb"
        resNameAdvNewD = "Searching/advConfirm/advConfirmNewUID.csb"
        resNameTopRight = "Searching/advConfirm/top_right.csb"
        resNameTopLeft = "Searching/advConfirm/top_left.csb"
        OpenLevel = SystemInfo.getGlobalConfigAddInfoByID(22000).values[1]
        MCash = SystemInfo.getGlobalConfigAddInfoByID(15000).values[1] 
        local buytimesstr = SystemInfo.getGlobalConfigAddInfoByID(15001)
        ButTimesTable = buytimesstr.values

        local info = SystemInfo.getGlobalConfigAddInfoByID(8002)
        table.insert(allQcTimes,info.values[1])
        table.insert(allQcTimes,info.values[2])
        table.insert(allQcTimes,info.values[3])

        local info2 = SystemInfo.getGlobalConfigAddInfoByID(8001)
        table.insert(qcPerTimes,info2.values[1])
        table.insert(qcPerTimes,info2.values[2])
        table.insert(qcPerTimes,info2.values[3])
                
    	isLocalDataInited = true
    end
    
    --初始化翻译
--    tsbtntext = LuaSqlite.getLanguageByKey(tsbtntext)
--    tsbtntext = LuaSqlite.getLanguageByKey(tsbtntext)  
--    needtltext = LuaSqlite.getLanguageByKey(needtltext)  
--    pttabtext = LuaSqlite.getLanguageByKey(pttabtext)
--    jytabtext = LuaSqlite.getLanguageByKey(jytabtext)
--    yxtabtext = LuaSqlite.getLanguageByKey(yxtabtext)   
--    lingzhutabtext = LuaSqlite.getLanguageByKey(lingzhutabtext) 
--    lzjianglitext = LuaSqlite.getLanguageByKey(lzjianglitext)   
--    diaoluotext = LuaSqlite.getLanguageByKey(diaoluotext)
--    tzbtntext = LuaSqlite.getLanguageByKey(tzbtntext)    
--    xhtltext = LuaSqlite.getLanguageByKey(xhtltext) 
--    opentimeleft = LuaSqlite.getLanguageByKey(opentimeleft) 
--    challengetimeleft = LuaSqlite.getLanguageByKey(challengetimeleft) 
--    challencsleft = LuaSqlite.getLanguageByKey(challencsleft) 
--    sdqtext = LuaSqlite.getLanguageByKey(sdqtext) 
--    saodangtext = LuaSqlite.getLanguageByKey(saodangtext) 
--    saodangtentext = LuaSqlite.getLanguageByKey(saodangtentext)
--    phbtext = LuaSqlite.getLanguageByKey(phbtext)
--    lztitletext = LuaSqlite.getLanguageByKey(lztitletext)
--    goumaitips = LuaSqlite.getLanguageByKey(goumaitips)      
--    needteammeber = LuaSqlite.getLanguageByKey(needteammeber)
end

---扫荡信息刷新相关
function AdvConfirmMgrNew.refreshSaodangInfo(refreshid)

    refreshSaodangInfo(refreshid)
end

--为物品获得途径而创建
function AdvConfirmMgrNew.showForGetWay(scene,curadv,curtab,callback)
    normalAdvId = 0
    UIStack.push("AdvConfirmMgrNew",AdvConfirmMgrNew.hide,true)
    addUI(scene,curadv,curtab,callback)
    ItemInfoViewMgr.isInGetWay = true
    StatusBarMgr.hideTopInfoBar(0,1)
end

function AdvConfirmMgrNew.test()
    showLingZhuTeam()
end

return AdvConfirmMgrNew