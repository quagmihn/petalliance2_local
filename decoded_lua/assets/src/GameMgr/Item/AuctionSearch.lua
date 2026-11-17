local AuctionSearch = {}


--翻译
local trans_sousuo = "exchange053"
local trans_wupinming = "exchange094"
local trans_searchError = "exchange052"
local trans_fastsearch = "exchange079"
local trans_selattri = "exchange080"
local trans_selgrade = "exchange081"
local trans_itemsearch = "exchange082"
local trans_itemfilter = "exchange083"
local trans_selskilllevel = "exchange084"
local trans_selattri = "exchange085"
local trans_selcolor = "exchange086"
local trans_white = "exchange087"
local trans_green = "exchange088"
local trans_blue  = "exchange089"
local trans_pruple = "exchange090"
local trans_golden = "exchange091"
local trans_orange = "exchange092"
local trans_red = "exchange093"

---------------------------------我是分割线------------------------------------
--ui初始化信息
local resNameAuctionSearch =  "" --列表UI资源
local typetbl = {}
local stritemidtable = {}
local fontInfo = {--该界面所有的文本格式信息，用于界面设置

    txt_title={
        have_selstate = false, --是否有选中态
        outline_width = 2,
        font_color = {r =144,g=238,b=255,a=255},
        outline_color = {r =38,g=54,b=76,a=255},
        text = trans_fastsearch
    },

    txt_content={
        have_selstate = false, --是否有选中态
        outline_width = 2,
        font_color = {r =227,g=233,b=255,a=255},
        outline_color = {r =0,g=0,b=0,a=255},
        text = "no data"
    },

    txt_search = {
        have_selstate = true, --是否有选中态
        outline_width = 0,
        font_color = {r =217,g=234,b=255,a=255},
        outline_color = {r =11,g=17,b=67,a=255},
        font_color_sel = {r =255,g=252,b=0,a=255},
        outline_color_sel = {r =11,g=17,b=67,a=255},
        text = trans_itemsearch       
    },

    txt_filter={
        have_selstate = true, --是否有选中态
        outline_width = 0,
        font_color = {r =217,g=234,b=255,a=255},
        outline_color = {r =11,g=17,b=67,a=255},
        font_color_sel = {r =255,g=252,b=0,a=255},
        outline_color_sel = {r =11,g=17,b=67,a=255},
        text = trans_itemfilter       
    },

    txt_gradetxt = {
         have_selstate = true, --是否有选中态
        outline_width = 0,
        font_color = {r =217,g=234,b=255,a=255},
        outline_color = {r =11,g=17,b=67,a=255},
        font_color_sel = {r =255,g=252,b=0,a=255},
        outline_color_sel = {r =11,g=17,b=67,a=255},
        text = trans_selskilllevel    
    
    },

    txt_colortxt = {
        have_selstate = true, --是否有选中态
        outline_width = 0,
        font_color = {r =217,g=234,b=255,a=255},
        outline_color = {r =11,g=17,b=67,a=255},
        font_color_sel = {r =255,g=252,b=0,a=255},
        outline_color_sel = {r =11,g=17,b=67,a=255},
        text = trans_selattri    
    },

    txt_colorseltitle = {
        have_selstate = true, --是否有选中态
        outline_width = 0,
        font_color = {r =217,g=234,b=255,a=255},
        outline_color = {r =11,g=17,b=67,a=255},
        font_color_sel = {r =255,g=252,b=0,a=255},
        outline_color_sel = {r =11,g=17,b=67,a=255},
        text = trans_selcolor    
    }
    
}

local currentitype = 17
local currentsubtype = 1
local currentgrade = 1
local currentattri = 1

local searchTypeFilterTable = {1,21,22} --只有在分类类型里面才能进入细分搜索的界面
local uiInitInVisibleData = {--初始化时设置可见性为无法看见的元件名称
    [1] = {"edb","search","txt_colortxt","txt_gradetxt","img_grade","txt_colorsel","img_attri","btn_selcolortxt"},
    [21] = {"edb","search","txt_colortxt","txt_gradetxt","img_grade","txt_colorsel","img_attri","btn_selcolortxt"},
    [22] = {"edb","search","txt_colortxt","txt_gradetxt","img_grade","txt_colorsel","img_attri","btn_selcolortxt"},
    [17] = {"btn_filterok","btn_selgrade","btn_selcolor","btn_selcolortxt"}

}

local btnFuncCallBack = { --按钮初始化的回调绑定
    ["btn_selgrade"] = nil,
    ["btn_selcolor"] = nil,
    ["btn_selcolortxt"] = nil
}

local attrData = {--属性列表
    [1] = "UI/CommonFiles/1.png",
    [3] = "UI/CommonFiles/3.png",
    [5] = "UI/CommonFiles/5.png",
    [10] = "UI/CommonFiles/11.png",
    [11] = "UI/CommonFiles/10.png",
    [12] = "UI/CommonFiles/12.png",
    [13] = "UI/CommonFiles/13.png",
    [16] = "UI/CommonFiles/16.png",
    [18] = "UI/CommonFiles/18.png",
}

local attrributeType = { 
	"ATTR_COMMON",
	"ATTR_FIGHT",
	"ATTR_WIND",
	"ATTR_DRUG",
	"ATTR_LAND",
	"ATTR_ROCK",
	"ATTR_WORM",
	"ATTR_GHOST",
	"ATTR_STEEL",
	"ATTR_WATER",
	"ATTR_FIRE",
	"ATTR_GRASS",
	"ATTR_ELEC",
	"ATTR_SUPER",
	"ATTR_ICE",
	"ATTR_DRAGON",
	"ATTR_EVIL",
	"ATTR_GOBLIN",
}

local gradData = {--等阶列表
    [1] = "Pet/Education/c.png",
    [2] = "Pet/Education/b.png",
    [3] = "Pet/Education/a.png",
    [4] = "Pet/Education/s.png",
    [5] = "Pet/Education/2s.png",
    --[6] = "Pet/Education/3s.png"
}

local colorData = {
    trans_white,
    trans_green,
    trans_blue,
    trans_pruple,
    trans_golden,
    trans_orange,
    --trans_red
}

local colorDataColor={
    [1] = {r=255,g=255,b=255,a=255},
    [2] = {r=0,g=255,b=0,a=255},
    [3] = {r=0,g=210,b=255,a=255},
    [4] = {r=240,g=0,b=255,a=255},
    [5] = {r=218,g=178,b=115,a=255},
    [6] = {r=255,g=165,b=0,a=255},
    --[7] = {r=255,g=0,b=0,a=255},
}
---------------------------------我是分割线------------------------------------
---设置label的字体
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

local function hideUI()
    UnblockLoader.cancel("AuctionSearch-loadAuctionSearchList")
    local list = CSResourceMgr.getNodeByName(resNameAuctionSearch,"list")
    if list~=nil then 
        list:removeAllChildren()
    end
    GameAudio.playUISound("retract")
    CSResourceMgr.removeCSObjectByTag(resNameAuctionSearch)
end

local function createList(itype)
    
    local list = CSResourceMgr.getNodeByName(resNameAuctionSearch,"list")
    local typetbl = AuctionMgrNew.getSearchLabeleLst(itype)
    local funcTable = {}
    stritemidtable = {}
    local itemnameArray = {}

    for i=1,#typetbl do
		print("typetbl[i].............. is",typetbl[i])
        local iteminfo = ItemInfo.getItemInfoById(typetbl[i])
        stritemidtable[iteminfo.name] = typetbl[i]
        itemnameArray[i] = iteminfo.name
    end
    for i=1,#typetbl do
        local function makeCell()
            local listcell = CSResourceMgr.getNodeByName(resNameAuctionSearch,"btn_filter"):clone()
            local labelText = CSResourceMgr.seekNodeByName(listcell,"txt_content")
            --print("typetbl[i]......................."..typetbl[i])

            setLabel(labelText,itemnameArray[i],fontInfo.txt_content.outline_color,fontInfo.txt_content.outline_width,fontInfo.txt_content.font_color)
            CSResourceMgr.clickEventBindingByNode(listcell,function()
                --print("itemid.."..typetbl[i])
                GameAudio.playUISound("sheetClick") 
                AuctionMgrNew.sendSearchRequest(typetbl[i])
                AuctionMgrNew.setSortBtnState(true,true)
                hideUI()
            end)
            list:pushBackCustomItem(listcell)
        end
        table.insert(funcTable,makeCell)
    end
    UnblockLoader.load(funcTable,"AuctionSearch-loadAuctionSearchList")
end

local function createSearchList(filterstr)
    local list = CSResourceMgr.getNodeByName(resNameAuctionSearch,"list")
    list:removeAllItems()
    local typetbl = {}
    local funcTable = {}
    for k,v in pairs(stritemidtable) do 
        local str = LuaSqlite.getLanguageByKey(k)
        print("itemname.....:"..str,filterstr)
        if string.find(str,filterstr)~=nil then 
            local data = {}
            data.name = str
            data.itemid = v
            table.insert(typetbl,data)
        end
    end

   for i=1,#typetbl do
        local function makeCell()
            local listcell = CSResourceMgr.getNodeByName(resNameAuctionSearch,"btn_filter"):clone()
            local labelText = CSResourceMgr.seekNodeByName(listcell,"txt_content")
            --local iteminfo = ItemInfo.getItemInfoById(typetbl[i])
            --stritemidtable[iteminfo.name] = typetbl[i]
            setLabel(labelText,typetbl[i].name,fontInfo.txt_content.outline_color,fontInfo.txt_content.outline_width,fontInfo.txt_content.font_color)
            CSResourceMgr.clickEventBindingByNode(listcell,function()
                --print("itemid.."..typetbl[i])
                GameAudio.playUISound("sheetClick") 
                AuctionMgrNew.sendSearchRequest(typetbl[i].itemid)
                AuctionMgrNew.setSortBtnState(true,true)
                hideUI()
            end)
            list:pushBackCustomItem(listcell)
        end
        table.insert(funcTable,makeCell)
    end

    if #funcTable > 0 then 
        UnblockLoader.cancel("AuctionSearch-loadAuctionSearchList")
        UnblockLoader.load(funcTable,"AuctionSearch-loadAuctionSearchList")
    end

end

local function createAttriList()
    currentattri = 1
    local list = CSResourceMgr.getNodeByName(resNameAuctionSearch,"list")
    list:removeAllItems()
    local btn_selgrade = CSResourceMgr.getNodeByName(resNameAuctionSearch,"btn_selgrade")
    local btn_selcolor = CSResourceMgr.getNodeByName(resNameAuctionSearch,"btn_selcolor")
    btn_selgrade:setVisible(false)
    btn_selcolor:setVisible(false)
    local btn_filterok = CSResourceMgr.getNodeByName(resNameAuctionSearch,"btn_filterok")
    CSResourceMgr.setButtonEnabledByNode(btn_filterok,false)

    local attrtble = {}
    for i = 1,18 do
        if attrData[i]~=nil then 
           table.insert(attrtble,i) 
        end
    end
    
    local count = #attrtble /3
    local mod = #attrtble %3
    local index = 0
    local function makeAttriCell()
        local listcell = CSResourceMgr.getNodeByName(resNameAuctionSearch,"panel_attri"):clone()
        for j = 1,3 do 
            index = index + 1
            local btn = CSResourceMgr.seekNodeByName(listcell,"btn_attr"..j)
            if index > #attrtble then 
                btn:setVisible(false) 
            else
                local imageattr = CSResourceMgr.seekNodeByName(listcell,"img_attr"..j)
                CSResourceMgr.setSpriteTextureByNode(imageattr,attrData[attrtble[index]])
                btn.index = index
                CSResourceMgr.clickEventBindingByNode(btn,function()
                        local image =  CSResourceMgr.getNodeByName(resNameAuctionSearch,"img_attri")
                        CSResourceMgr.setSpriteTextureByNode(image,attrData[attrtble[btn.index]])
                        currentattri = attrtble[btn.index]
                        btn_selgrade:setVisible(true)
                        btn_selcolor:setVisible(true)
                        list:removeAllItems()
                        CSResourceMgr.setButtonEnabledByNode(btn_filterok,true)
                end)
            end
        end

        list:pushBackCustomItem(listcell)
    end

    for i = 1,count do 
        makeAttriCell()
    end

    if mod > 0 then 
        makeAttriCell()       
    end


    
end

local function createGradeList()
    currentgrade = 1
    local list = CSResourceMgr.getNodeByName(resNameAuctionSearch,"list")
    list:removeAllItems()
    local btn_selgrade = CSResourceMgr.getNodeByName(resNameAuctionSearch,"btn_selgrade")
    local btn_selcolor = CSResourceMgr.getNodeByName(resNameAuctionSearch,"btn_selcolor")
    btn_selgrade:setVisible(false)
    btn_selcolor:setVisible(false)
    local btn_filterok = CSResourceMgr.getNodeByName(resNameAuctionSearch,"btn_filterok")
    CSResourceMgr.setButtonEnabledByNode(btn_filterok,false)
    
    local count = #gradData /3
    local mod = #gradData %3
    local index = 0
    local function makeGradeCell()
        local listcell = CSResourceMgr.getNodeByName(resNameAuctionSearch,"panel_attri"):clone()
        for j = 1,3 do 
            local btn = CSResourceMgr.seekNodeByName(listcell,"btn_attr"..j)
            index = index + 1
            if index > #gradData then
                btn:setVisible(false)
            else
                local imageattr = CSResourceMgr.seekNodeByName(listcell,"img_attr"..j)
                CSResourceMgr.setSpriteTextureByNode(imageattr,gradData[index])
                btn.index = index
                CSResourceMgr.clickEventBindingByNode(btn,function()
                    local image =  CSResourceMgr.getNodeByName(resNameAuctionSearch,"img_grade")
                    CSResourceMgr.setSpriteTextureByNode(image,gradData[btn.index])
                    print("btn.index.........................."..btn.index)
                    currentgrade = btn.index
                    btn_selgrade:setVisible(true)
                    btn_selcolor:setVisible(true)
                    list:removeAllItems()
                    CSResourceMgr.setButtonEnabledByNode(btn_filterok,true)
                end)
            end
        end

        list:pushBackCustomItem(listcell)
    end

    for i = 1,count do 
        makeGradeCell()
    end

    if mod > 0 then 
        makeGradeCell()       
    end

end

local function createColorSelList()
   currentgrade = 0
   currentattri = ""
   local list = CSResourceMgr.getNodeByName(resNameAuctionSearch,"list")
    list:removeAllItems()
    local btn_selcolortxt = CSResourceMgr.getNodeByName(resNameAuctionSearch,"btn_selcolortxt")
    btn_selcolortxt:setVisible(false)
    local btn_filterok = CSResourceMgr.getNodeByName(resNameAuctionSearch,"btn_filterok")
    CSResourceMgr.setButtonEnabledByNode(btn_filterok,false)
    local function makeCell(i)
        local listcell = CSResourceMgr.getNodeByName(resNameAuctionSearch,"btn_filter"):clone()
        local labelText = CSResourceMgr.seekNodeByName(listcell,"txt_content")
        --local iteminfo = ItemInfo.getItemInfoById(typetbl[i])
        --stritemidtable[iteminfo.name] = typetbl[i]
        setLabel(labelText,colorData[i],fontInfo.txt_content.outline_color,fontInfo.txt_content.outline_width,fontInfo.txt_content.font_color)
        CSResourceMgr.clickEventBindingByNode(listcell,function()
            --print("itemid.."..typetbl[i])
            currentgrade = i-1
            currentattri = ""
            btn_selcolortxt:setVisible(true)
            local colorselresult = CSResourceMgr.getNodeByName(resNameAuctionSearch,"txt_colorselresult")
            setLabel(colorselresult,colorData[i],colorDataColor[i],nil,colorDataColor[i])
            AuctionMgrNew.setSortBtnState(true,true)
            CSResourceMgr.setButtonEnabledByNode(btn_filterok,true)
            list:removeAllItems()
        end)
        list:pushBackCustomItem(listcell)
    end

   for i=1,#colorData do
        makeCell(i) 
   end
   list:jumpToTop() 
end

local function sendFilterSearchReq(gradeLevel,attrilevel)
    local selectid = ""
    attrilevel = attrilevel or ""
    gradeLevel = tostring(gradeLevel)
    print("attrilevel is ........"..attrilevel)
    if attrilevel~="" then 
        attrilevel = attrributeType[attrilevel]
        selectid = currentitype.."_"..currentsubtype.."_"..gradeLevel.."_"..attrilevel
    else
         selectid = currentitype.."_"..currentsubtype.."_"..gradeLevel     
    end

    

    AuctionMgrNew.sendSearchRequest(nil,selectid)
    AuctionMgrNew.setSortBtnState(true,true)
    hideUI()    
end

local function addUI(scene,itype)

    local function loadCSB()
        local csbUI = CSResourceMgr.createRes(scene,resNameAuctionSearch)
        csbUI:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resNameAuctionSearch, 320, 480) 

        for i = 1,#uiInitInVisibleData[17] do 
            local uicell = CSResourceMgr.getNodeByName(resNameAuctionSearch,uiInitInVisibleData[17][i])
            uicell:setVisible(false)
        end

        local db = CSResourceMgr.getNodeByName(resNameAuctionSearch,"db")
        db:setVisible(false)
        local title = CSResourceMgr.getNodeByName(resNameAuctionSearch,"txt_title")
        setLabel(title,fontInfo.txt_title.text,fontInfo.txt_title.outline_color,fontInfo.txt_title.outline_width,fontInfo.txt_title.font_color)
        createList(itype)

            local editbox = CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resNameAuctionSearch, "edb"), "empty.png", 
        230, 42, 150, 22, 24, 50, "",nil,nil,false)

        CSResourceMgr.setButtonString(resNameAuctionSearch, "search", trans_sousuo,nil,{r=0,g=0,b=0,a=255})
        CSResourceMgr.clickEventBinding(resNameAuctionSearch, "search",function()
            local name = editbox:getText()
            if name=="" then
                 StandardTipsMgr.show(1, trans_searchError)
                --TipsMgr.show(trans_searchError)
        	    return
            end
            createSearchList(name)
        end)
        
        local close = CSResourceMgr.getNodeByName(resNameAuctionSearch,"db")
        close:setVisible(false)

        CSResourceMgr.clickEventBinding(resNameAuctionSearch, "bg", function()
            AuctionSearch.hide()
        end)
        CSResourceMgr.clickEventBinding(resNameAuctionSearch,"btn_close",function() 
            AuctionSearch.hide()
        end) 
    end

    local function playCSB()

        GameAudio.playUISound("popup")
        local db = CSResourceMgr.getNodeByName(resNameAuctionSearch,"db")
        local close = CSResourceMgr.getNodeByName(resNameAuctionSearch,"btn_close")
        db:setVisible(true)
        close:setVisible(true)
        CocosModuleMgr.showUIAnimation(db,"down")
        CocosModuleMgr.showUIAnimation(close,"down")

    end

    loadCSB()
    playCSB()
end

local function searchGradeAndAttriCallBack()
    local txt_search = CSResourceMgr.getNodeByName(resNameAuctionSearch,"txt_search")
    txt_search:setVisible(false)

    local txt_filter = CSResourceMgr.getNodeByName(resNameAuctionSearch,"txt_filter")
    txt_filter:setVisible(false)

    local txt_gradetxt = CSResourceMgr.getNodeByName(resNameAuctionSearch,"txt_gradetxt")
    txt_gradetxt:setVisible(true)

    local img_grade = CSResourceMgr.getNodeByName(resNameAuctionSearch,"img_grade")
    img_grade:setVisible(true)

    local txt_colortxt = CSResourceMgr.getNodeByName(resNameAuctionSearch,"txt_colortxt")
    txt_colortxt:setVisible(true)

    local img_attri = CSResourceMgr.getNodeByName(resNameAuctionSearch,"img_attri")
    img_attri:setVisible(true)

    btnFuncCallBack["btn_selcolor"] = createAttriList
    btnFuncCallBack["btn_selgrade"] = createGradeList

   local btn_filterok = CSResourceMgr.getNodeByName(resNameAuctionSearch,"btn_filterok")
   btn_filterok:setVisible(true)
end

local function searchByTextInput()
    local edb = CSResourceMgr.getNodeByName(resNameAuctionSearch,"edb")
    edb:setVisible(true)  

    local search = CSResourceMgr.getNodeByName(resNameAuctionSearch,"search")
    search:setVisible(true) 

    local btn_selgrade = CSResourceMgr.getNodeByName(resNameAuctionSearch,"btn_selgrade")
    btn_selgrade:setVisible(false)  

    local btn_selcolor = CSResourceMgr.getNodeByName(resNameAuctionSearch,"btn_selcolor")
    btn_selcolor:setVisible(false) 
 
    createList(currentitype.."-"..currentsubtype)

end

local function searchGradeOnlyCallBack()
    currentattri = ""
    currentgrade = 0
    local txt_search = CSResourceMgr.getNodeByName(resNameAuctionSearch,"txt_search")
    txt_search:setVisible(false)

    local txt_filter = CSResourceMgr.getNodeByName(resNameAuctionSearch,"txt_filter")
    txt_filter:setVisible(false)

    local btn_selgrade = CSResourceMgr.getNodeByName(resNameAuctionSearch,"btn_selgrade")
    btn_selgrade:setVisible(false)

    local btn_selcolor = CSResourceMgr.getNodeByName(resNameAuctionSearch,"btn_selcolor")
    btn_selcolor:setVisible(false)

    local btn_filterok = CSResourceMgr.getNodeByName(resNameAuctionSearch,"btn_filterok")
    btn_filterok:setVisible(true)

    local btn_selcolortxt = CSResourceMgr.getNodeByName(resNameAuctionSearch,"btn_selcolortxt")
    btn_selcolortxt:setVisible(true)
    
end

local function initUIandBindClickEvent(itype,isubtype)
    local txt_search = CSResourceMgr.getNodeByName(resNameAuctionSearch,"txt_search")
    setLabel(txt_search,fontInfo.txt_search.text,fontInfo.txt_search.outline_color,fontInfo.txt_search.outline_width,fontInfo.txt_search.font_color) 
  
 
    local  txt_filter = CSResourceMgr.getNodeByName(resNameAuctionSearch,"txt_filter")
    setLabel(txt_filter,fontInfo.txt_filter.text,fontInfo.txt_filter.outline_color,fontInfo. txt_filter.outline_width,fontInfo.txt_filter.font_color) 
      
      local txt_gradetxt = CSResourceMgr.getNodeByName(resNameAuctionSearch,"txt_gradetxt")
    setLabel(txt_gradetxt,fontInfo.txt_gradetxt.text,fontInfo.txt_gradetxt.outline_color,fontInfo.txt_gradetxt.outline_width,fontInfo.txt_gradetxt.font_color)   

      local txt_colortxt = CSResourceMgr.getNodeByName(resNameAuctionSearch,"txt_colortxt")
    setLabel(txt_colortxt,fontInfo.txt_colortxt.text,fontInfo.txt_colortxt.outline_color,fontInfo.txt_colortxt.outline_width,fontInfo.txt_colortxt.font_color)   

      local txt_colorseltitle = CSResourceMgr.getNodeByName(resNameAuctionSearch,"txt_colorseltitle")
    setLabel(txt_colorseltitle,fontInfo.txt_colorseltitle.text,fontInfo.txt_colorseltitle.outline_color,fontInfo.txt_colorseltitle.outline_width,fontInfo.txt_colorseltitle.font_color) 
     
    
     local txt_colorselresult = CSResourceMgr.getNodeByName(resNameAuctionSearch,"txt_colorselresult")
     print("colorData 1 is .................."..colorData[1])
    setLabel(txt_colorselresult,colorData[1],1,nil,colorDataColor[1]) 

    local btn_selgrade = CSResourceMgr.getNodeByName(resNameAuctionSearch,"btn_selgrade")
    
    if currentitype == 1 then 
        btnFuncCallBack["btn_selcolor"] = searchGradeAndAttriCallBack
    else
        btnFuncCallBack["btn_selcolor"] = searchGradeOnlyCallBack
    end
    btnFuncCallBack["btn_selgrade"] = searchByTextInput
    btnFuncCallBack["btn_selcolortxt"] = createColorSelList
    CSResourceMgr.clickEventBinding(resNameAuctionSearch, "btn_selgrade", function()
            btnFuncCallBack["btn_selgrade"]()
    end)

    CSResourceMgr.clickEventBinding(resNameAuctionSearch, "btn_selcolor", function()
            btnFuncCallBack["btn_selcolor"]()
    end)

    CSResourceMgr.clickEventBinding(resNameAuctionSearch, "btn_selcolortxt", function()
            btnFuncCallBack["btn_selcolortxt"]()
    end)
end


local function addUI2(scene,itype,isubtype)
    local function loadCSB()
        local csbUI = CSResourceMgr.createRes(scene,resNameAuctionSearch)
        csbUI:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resNameAuctionSearch, 320, 480) 

        for i = 1,#uiInitInVisibleData[itype] do 
            local uicell = CSResourceMgr.getNodeByName(resNameAuctionSearch,uiInitInVisibleData[itype][i])
            uicell:setVisible(false)
        end

        local btn_filterok = CSResourceMgr.getNodeByName(resNameAuctionSearch,"btn_filterok")
        btn_filterok:setVisible(false)
        
        local db = CSResourceMgr.getNodeByName(resNameAuctionSearch,"db")
        db:setVisible(false)
        local title = CSResourceMgr.getNodeByName(resNameAuctionSearch,"txt_title")
        setLabel(title,trans_fastsearch,fontInfo.txt_title.outline_color,fontInfo.txt_title.outline_width,fontInfo.txt_title.font_color)

       
        initUIandBindClickEvent(itype,isubtype)
        --createList(itype)

            local editbox = CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resNameAuctionSearch, "edb"), "empty.png", 
        230, 42, 150, 22, 24, 50, "",nil,nil,false)

        CSResourceMgr.setButtonString(resNameAuctionSearch, "search", trans_sousuo,nil,{r=0,g=0,b=0,a=255})
        CSResourceMgr.clickEventBinding(resNameAuctionSearch, "search",function()
            local name = editbox:getText()
            if name=="" then
                 StandardTipsMgr.show(1, trans_searchError)
                --TipsMgr.show(trans_searchError)
        	    return
            end
            createSearchList(name)
        end)
        
        local close = CSResourceMgr.getNodeByName(resNameAuctionSearch,"db")
        close:setVisible(false)

        CSResourceMgr.clickEventBinding(resNameAuctionSearch, "bg", function()
            AuctionSearch.hide()
        end)
        CSResourceMgr.clickEventBinding(resNameAuctionSearch,"btn_close",function() 
            AuctionSearch.hide()
        end) 

        local btn_filterok = CSResourceMgr.getNodeByName(resNameAuctionSearch,"btn_filterok")
        CSResourceMgr.clickEventBinding(resNameAuctionSearch,"btn_filterok",function()
            print("currentgrade&currentattri"..currentgrade,currentattri)
            sendFilterSearchReq(currentgrade,currentattri)
        end)
    end

    local function playCSB()

        GameAudio.playUISound("popup")
        local db = CSResourceMgr.getNodeByName(resNameAuctionSearch,"db")
        local close = CSResourceMgr.getNodeByName(resNameAuctionSearch,"btn_close")
        db:setVisible(true)
        close:setVisible(true)
        CocosModuleMgr.showUIAnimation(db,"down")
        CocosModuleMgr.showUIAnimation(close,"down")

    end

    loadCSB()
    playCSB()
end

local function canShowAdvancedSearchUI(itype)
    for i = 1,#searchTypeFilterTable do 
        if searchTypeFilterTable[i] == itype then 
            return true
        end
    end

    return false
end
---------------------------------我是分割线------------------------------------
--类函数

function AuctionSearch.Init()
    resNameAuctionSearch = "Item/Auction/AuctionSearch.csb" 
end
function AuctionSearch.show(scene,itype,isubtype)
    UIStack.push("AuctionSearch",AuctionSearch.hide,false)
    
    currentitype = itype
    currentsubtype = isubtype

    if canShowAdvancedSearchUI(itype) == true then 
        addUI2(scene,itype,isubtype)
    else
       addUI(scene,itype.."-"..isubtype)
    end
   
end

function AuctionSearch.hide()
    hideUI()
	UIStack.pop("AuctionSearch")
end


return AuctionSearch