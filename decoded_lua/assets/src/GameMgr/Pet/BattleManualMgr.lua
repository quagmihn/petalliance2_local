local BattleManualMgr = {}

local resNameBG = "Pet/Formation/FormationBGNew.csb"

local resName_main = ""
local resNameTable = {}
local tagTable     = {}

local list
local richLabelS

local npcAni

local pageBG
local pageBubble

BattleManualMgr.text = {
    "manual1", 
    "manual2", 
    "manual3", 
    "manual4", 
}

local tabTitle = {}
local tabText  = {}

local PAGE_NUM_MAX = 3
local currentPage  = 0

local pageBuffer = {}

local pageContents = {}

function BattleManualMgr.Init()
    resName_main = "Pet/BattleManual/BattleManual_main.csb"

    resNameTable = {
        [0] = "Pet/BattleManual/BattleManual_0.csb",  -- menu
        [1] = "Pet/BattleManual/BattleManual_1.csb",  -- page1
        [2] = "Pet/BattleManual/BattleManual_1.csb",  -- page2
        [3] = "Pet/BattleManual/BattleManual_1.csb",  -- page3
    }
    
    tagTable = {
        bg   = "BattleManual_bg"  ,
        main = "BattleManual_main",
        [0]  = "BattleManualMgr_0",
        [1]  = "BattleManualMgr_1",
        [2]  = "BattleManualMgr_2",
        [3]  = "BattleManualMgr_3",
    }
    
    npcAni      = nil
    
    pageBG      = nil
    pageBubble  = nil
    
    currentPage = 0
    
    pageBuffer = {}
    
    tabTitle = {
        [0] = {},
        [1] = {
            "manual11",
            "manual12",
            "manual13",
            "manual14",
            "manual15",
            "manual16",
            "manual17",
            "manual18",
        },
        [2] = {
            "manual21",
            "manual22",
            "manual23",
            "manual24",
        },
        [3] = {
            "manual31",
            "manual32",
            "manual33",
            "manual34",
        },
    }
    
    tabText = {
        [0] = {},
        [1] = {
            
        }
    }
    
    pageContents = {
        [0] = {
            title = BattleManualMgr.text[1],
            npcid = 2,
        },
        [1] = {
            title = BattleManualMgr.text[2],
            npcid = 2,
            tabTitle = tabTitle[1],
            tabContent = {
                [1] = {type = 2, img = "", desc = "manual111"},
                [2] = {type = 2, img = "", desc = "manual121"},
                [3] = {type = 2, img = "", desc = "manual131"},
                [4] = {type = 2, img = "", desc = "manual141"},
                [5] = {type = 2, img = "", desc = "manual151"},
                [6] = {type = 2, img = "", desc = "manual161"},
                [7] = {type = 2, img = "", desc = "manual171"},
                [8] = {type = 2, img = "", desc = "manual181"},
            },
        },
        [2] = {
            title = BattleManualMgr.text[3],
            npcid = 11,
            tabTitle = tabTitle[2],
            tabContent = {
                [1] = {type = 2, img = "", desc = "manual211"},
                [2] = {type = 2, img = "", desc = "manual221"},
                [3] = {type = 2, img = "", desc = "manual231"},
                [4] = {type = 2, img = "", desc = "manual241"},
            },
        },
        [3] = {
            title = BattleManualMgr.text[4],
            npcid = 16,
            tabTitle = tabTitle[3],
            tabContent = {
                [1] = {type = 1, img = "Pet/BattleManual/strategy_figure_basic_large.png", desc = "", tips = {"manual312", "manual311"}},
                [2] = {type = 2, img = "", desc = "manual321"},
                [3] = {type = 2, img = "", desc = "manual331"},
                [4] = {type = 2, img = "", desc = "manual341"},
            },
        },
    }
end

local function loadBG(scene)
    local tag = tagTable["bg"]
    local bgLayer = CSResourceMgr.createRes(scene, resNameBG, tag)
    bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
    CSResourceMgr.setRelativePosition(resNameBG, 320, 480, tag)
    bgLayer:setOpacity(0)
    transition.fadeIn(bgLayer, {time=0.3})
end

local showInnerPage

local function showMainPage(scene, closeCallback)
    scene = scene or SceneMgr.getRunningScene
    local tag = tagTable["main"]
    local layer = CSResourceMgr.createRes(scene,resName_main,tag)
    CSResourceMgr.setFullScreen(resName_main,tag)

    layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
    CSResourceMgr.setRelativePosition(resName_main, 320, 480, tag)
    CocosModuleMgr.setEdgeDistance(layer, nil, nil, nil, 0)
    
    local bg = CSResourceMgr.getNodeByName(resName_main,"bg",tag)
    local diff = CocosModuleMgr.getScreenSizeDiff()
    bg:setPositionY((960+diff)-1160*layer:getScale())  -- 1160:弹窗高度 
    
    CSResourceMgr.setLabelColor(resName_main,{"bg","title_db","title"},{r=64,g=81,b=103,a=255},tag)
    CSResourceMgr.setLabelString(resName_main,{"bg","title_db","title"},pageContents[0]["title"],tag,{r=185,g=199,b=217,a=255},nil,nil)

    CSResourceMgr.clickEventBinding(resName_main, {"bg", "return"}, function()
        showInnerPage(0)
    end, tag)
    CSResourceMgr.getNodeByName(resName_main, {"bg", "return"}, tagTable["main"]):setVisible(false)
    
    CSResourceMgr.clickEventBinding(resName_main, {"bg", "close"}, function()
        BattleManualMgr.hide()
        if closeCallback then closeCallback() end
    end, tag)
    
    if npcAni then
        if npcAni.res and npcAni.tag then
            AnimationMgr.removeGafObjectByTag(npcAni.res,npcAni.tag)
        end
    end
    local parent = CSResourceMgr.getNodeByName(resName_main,{"bottombar","npcTex"},tagTable["main"])
    npcAni = AnimationMgr.createAni(parent,"Spine/npc/boshi.png",0,0,"bmanual")
    CSResourceMgr.setLabelString(resName_main,{"bottombar","d_name_l"},"manualem2",tagTable["main"],{r=0,g=0,b=0,a=255,w=1,s=1},nil,266)
    npcAni:setScale(0.7)

end

-- 设置页签内容
local function setInnerPageContent(page, tab)
    local resName = resNameTable[page]
    local tag     = tagTable[page]
    local contents = pageContents[page].tabContent[tab]
    
    local type = contents.type
    
    list = CSResourceMgr.getNodeByName(resName,"ListView",tag)
    list:removeAllItems()
    
    if not type then return end
    
    if type == 1 then      -- 图
        local image2 = CSResourceMgr.getNodeByName(resName,{"bg","image2"},tag)

        list:setVisible(true)
        image2:setVisible(false)
    
        local tex = CSResourceMgr.getNodeByName(resName,"image",tag):clone()
        tex:loadTexture(contents.img)
        list:pushBackCustomItem(tex)
        if contents.tips then
            local _tips = contents.tips
            local label1 = CSResourceMgr.getNodeByName(resName,"desc",tag):clone()
            CSResourceMgr.setLabelStringByNode(label1,_tips[1])
            tex:addChild(label1)
            label1:setPosition(130,260)
            
            local label2 = CSResourceMgr.getNodeByName(resName,"desc",tag):clone()
            CSResourceMgr.setLabelStringByNode(label2,_tips[2])
            tex:addChild(label2)
            label2:setPosition(320,260)
        end
    elseif type == 2 then  -- 文
        local image2 = CSResourceMgr.getNodeByName(resName,{"bg","image2"},tag)
        image2:setPosition(list:getPositionX(), list:getPositionY())

        list:setVisible(false)
        image2:setVisible(true)
    
        local bg     = CSResourceMgr.getNodeByName(resName,{"bg","image"},tag):clone()
        local bubble = CSResourceMgr.getNodeByName(resName,{"bg","image2","bubble"},tag)
        
        CSResourceMgr.seekNodeByName(bubble,"desc_list"):removeAllItems()
        
        local title = CSResourceMgr.seekNodeByName(bubble,"bubble_t")
        CSResourceMgr.setLabelStringByNode(title, pageContents[page]["tabTitle"][tab],{r=0,g=0,b=0,a=255,w=1})
        CSResourceMgr.setLabelColorByNode(title,{r=103,g=203,b=255,a=255})
        
        local labelMaxWidth = 400
        local info = LuaSqlite.getLanguageByKey(contents.desc)
        if CocosModuleMgr.checkIsRichLabelString(info) then
            local tmpNode = CSResourceMgr.seekNodeByName(bubble,"bubble_desc"):clone()
            local tmpNode2 = CSResourceMgr.getNodeByName(resName,"desc_db",tag):clone()
            
            richLabelS = CocosModuleMgr.createRichLabel(tmpNode2, contents.desc, tmpNode:getFontSize(), "cuyuan_GBK.ttf", labelMaxWidth, 0, 0, nil, false)
            richLabelS:setAnchorPoint(0.0, 1.0)
            richLabelS:setPosition(0, richLabelS.realHeight)
            tmpNode2:setContentSize(richLabelS.realWidth, richLabelS.realHeight)
            
            CSResourceMgr.seekNodeByName(bubble,"desc_list"):pushBackCustomItem(tmpNode2)
        else
            local label = CSResourceMgr.seekNodeByName(bubble,"bubble_desc"):clone()
            CSResourceMgr.setLabelStringByNode(label,contents.desc,{r=0,g=0,b=0,a=255,w=1})
            CSResourceMgr.setLabelMaxWidthByNode(label,labelMaxWidth)
            label:setAnchorPoint(0.0,1.0)

            CSResourceMgr.seekNodeByName(bubble,"desc_list"):pushBackCustomItem(label)
        end
    elseif type == 3 then  -- 图文
    end
end

-- 切入页面设置
local function setInnerPage(page)
    local title = CSResourceMgr.getNodeByName(resName_main,{"bg","title_db","title"},tagTable["main"])
    CSResourceMgr.setLabelStringByNode(title,pageContents[page]["title"])

    if npcAni then
        if npcAni.res and npcAni.tag then
            AnimationMgr.removeGafObjectByTag(npcAni.res,npcAni.tag)
        end
    end
    local npcid = pageContents[page]["npcid"]
    local parent = CSResourceMgr.getNodeByName(resName_main,{"bottombar","npcTex"},tagTable["main"])
    local anires
    if npcid == 2 then
        anires = "Spine/npc/boshi.png"
    else
        anires = "Spine/npc/em"..npcid..".png"
    end
    npcAni = AnimationMgr.createAni(parent,anires,0,0,"bmanual"..npcid)
    CSResourceMgr.setLabelString(resName_main,{"bottombar","d_name_l"},"manualem"..npcid,tagTable["main"],{r=0,g=0,b=0,a=255,w=1,s=1},nil,266)
    npcAni:setScale(0.7)
    
    if page == 0 then
        CSResourceMgr.getNodeByName(resName_main, {"bg", "return"}, tagTable["main"]):setVisible(false)
    elseif page == 1 then
    elseif page == 2 then
    elseif page == 3 then
    end
    
    if page ~= 0 then
        local currentSelect = 1
        local lastSelect = pageContents[page].record["select"]
        local btns       = pageContents[page].record["button"]
        CSResourceMgr.setButtonEnabledByNode(btns[lastSelect],true)
        CSResourceMgr.setButtonEnabledByNode(btns[currentSelect],false)
        pageContents[page].record["select"] = currentSelect
        
        setInnerPageContent(page, currentSelect)

        CSResourceMgr.getNodeByName(resName_main, {"bg", "return"}, tagTable["main"]):setVisible(true)
    end
end

-- 初始界面设置
local function initInnerPage(page)
    local resName = resNameTable[page]
    local tag     = tagTable[page]
    
    local title = CSResourceMgr.getNodeByName(resName_main,{"bg","title_db","title"},tagTable["main"])
    CSResourceMgr.setLabelStringByNode(title,pageContents[page]["title"])

    if npcAni then
        if npcAni.res and npcAni.tag then
            AnimationMgr.removeGafObjectByTag(npcAni.res,npcAni.tag)
        end
    end
    local npcid = pageContents[page]["npcid"]
    local parent = CSResourceMgr.getNodeByName(resName_main,{"bottombar","npcTex"},tagTable["main"])
    local anires
    if npcid == 2 then
        anires = "Spine/npc/boshi.png"
    else
        anires = "Spine/npc/em"..npcid..".png"
    end
    npcAni = AnimationMgr.createAni(parent,anires,0,0,"bmanual"..npcid)
    CSResourceMgr.setLabelString(resName_main,{"bottombar","d_name_l"},"manualem"..npcid,tagTable["main"],{r=0,g=0,b=0,a=255,w=1,s=1},nil,266)
    npcAni:setScale(0.7)
    
    local _tabs = pageContents[page]["tabTitle"]
    
    if page == 0 then
        local imgTable = {
            CocosModuleMgr.getWordImage("strategy_cal_basic.png"),
            CocosModuleMgr.getWordImage("strategy_cal_venetica.png"),
            CocosModuleMgr.getWordImage("strategy_cal_fighting.png"),
        }
        for i = 1, PAGE_NUM_MAX do
            local button = CSResourceMgr.getNodeByName(resName, {"bg", "Button"..i}, tag)
            CSResourceMgr.clickEventBindingByNode(button, function()
                showInnerPage(i)
            end)
            CSResourceMgr.seekNodeByName(button,"title"..i):loadTexture(imgTable[i])
        end
        
        return
    else
        CSResourceMgr.getNodeByName(resName_main, {"bg", "return"}, tagTable["main"]):setVisible(true)
    end

    local diff = CocosModuleMgr.getScreenSizeDiff()
    local layer = CSResourceMgr.getCsbObj(resName_main,tagTable["main"])
    list = CSResourceMgr.getNodeByName(resName,"ListView",tag)
    list:setContentSize(list:getContentSize().width, 1024 + ((960+diff)-1160*layer:getScale()) - 80*layer:getScale())

    local parent = CSResourceMgr.getNodeByName(resName,"bg",tag)
    local buttonSample = CSResourceMgr.getNodeByName(resName,{"bg", "button"},tag)
    local originalX, originalY = buttonSample:getPosition()

    local currentSelect = 1
    pageContents[page].record = {}
    pageContents[page].record["select"] = currentSelect
    pageContents[page].record["button"] = {}
    for i = 1, #_tabs do
        local button = buttonSample
        if i > 1 then
            button = CSResourceMgr.getNodeByName(resName,{"bg", "button"},tag):clone()
            parent:addChild(button)
            button:setLocalZOrder(-1)
        end
        button:setPosition(originalX, originalY - 75*(i - 1))
        table.insert(pageContents[page].record["button"],button)
        
        local label = CSResourceMgr.seekNodeByName(button,"text")
        CSResourceMgr.setLabelStringByNode(label,_tabs[i])
        
        if i == currentSelect then
            CSResourceMgr.setButtonEnabledByNode(button,false)
        else
            CSResourceMgr.setButtonEnabledByNode(button,true)
        end
        
        CSResourceMgr.clickEventBindingByNode(button,function(sender)
            local select = pageContents[page].record["select"]
            local btns   = pageContents[page].record["button"]

            CSResourceMgr.setButtonEnabledByNode(btns[select],true)
            for i = 1, #btns do
                if btns[i] == sender then
                    setInnerPageContent(page, i)
                    pageContents[page].record["select"] = i
                    CSResourceMgr.setButtonEnabledByNode(btns[i],false)
                end
            end
        end,1,"sheetClick")
    end
    setInnerPageContent(page, currentSelect)
end

local function init()
    showInnerPage = function(page)
        local prePage = currentPage
        currentPage = page

        local resName = resNameTable[page]
        local tag     = tagTable[page]
        
        if pageBuffer[prePage] then
            pageBuffer[prePage]:setVisible(false)
        end
        
        if CSResourceMgr.getCsbObj(resName,tag) then
            if pageBuffer[page] then
                pageBuffer[currentPage]:setVisible(true)
            end
            
            setInnerPage(page)

            return
        end
        
        local content = CSResourceMgr.getNodeByName(resName_main,{"bg", "content"},tagTable["main"])
        local pageNode = CSResourceMgr.createRes(content, resName, tag)
        pageNode:setPosition(-320, 0)

        pageBuffer[currentPage] = pageNode

        initInnerPage(page)
    end
end

function BattleManualMgr.show(scene, closeCallback)
    UIStack.push("BattleManualMgr",BattleManualMgr.hide,true)

    BagViewMgr.setVisible(false)
    
    scene = scene or SceneMgr.getRunningScene
    
    init()
    
    local function load1()
        loadBG(scene)
    end
    
    local function load2()
        showMainPage(scene, closeCallback)
    end
    
    local function load3()
        showInnerPage(0)
    end
    
    local funcTable = {load1, load2, load3}
    
--    load1() load2() load3()
    
    UnblockLoader.load(funcTable, "BattleManualMgr")
end

function BattleManualMgr.hide()
    UIStack.pop("BattleManualMgr")

    BagViewMgr.setVisible(true)

    currentPage = 0
    pageBuffer = {}

    for i = 0, PAGE_NUM_MAX, 1 do
        CSResourceMgr.removeCSObjectByTag(resNameTable[i], tagTable[i])
    end
    CSResourceMgr.removeCSObjectByTag(resName_main, tagTable["main"])
    CSResourceMgr.removeCSObjectByTag(resNameBG,tagTable["bg"])
    
end

return BattleManualMgr