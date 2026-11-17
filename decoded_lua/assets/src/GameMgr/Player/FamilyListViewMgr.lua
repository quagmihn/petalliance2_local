local FamilyListViewMgr = {}

--vesion number 1.0
--@client side FamilyListViewMgr.lua
--[[
这个文件是家族列表界面
--]]
--script writer Leon Lee
--creation time 2016-4-22

--类成员函数
FamilyListViewMgr.famliyLstJsonStr = ""
--const
local CONST_PERPAGE_NUM = 7

--翻译
local trans_familylst = "family24"--"家族列表"
local trans_createfamily = "family25"--"创建家族"
local trans_searchfamily = "family26"--"搜索家族"
local trans_finalpage = "family27"--"已是最后一页"
local trans_myfamily = "family28"--"我的家族"
local trans_familyapply = "family29"--"是否申请加入家族：<1>"
local trans_jzzz = "family50"
local trans_defaultjzzz = "family59"
---------------------------------我是分割线------------------------------------

--ui初始化信息
local resNameFamilyList = "" --家族列表函数
local resNameBg = ""--背景UI资源
local listCellTable = {}
local currentPageIndex = 0
local fontInfo = {
    txt_title ={
        have_selstate = false, --是否有选中态
        outline_width = 2,
        font_color = {r =144,g=238,b=255,a=255},
        outline_color = {r =38,g=54,b=76,a=255},
        text = trans_familylst
    },
    
    txt_icontitle={
        have_selstate = true, --是否有选中态
        outline_width = 1, 
        font_color = {r =255,g=252,b=0,a=255},  --默认未选中
        outline_color = {r =5,g=48,b=84,a=255},     --默认未选中
        font_color_sel = {r =255,g=255,b=255,a=255},--选中  
        outline_color_sel = {r =160,g=86,b=5,a=255}, --选中     
        text = "no data"     
    },
    --[[
    txt_itemdesc={
        have_selstate = true, --是否有选中态
        outline_width = nil, 
        font_color = {r =71,g=96,b=103,a=255},  --默认未选中
        outline_color = {r =5,g=48,b=84,a=255},     --默认未选中
        font_color_sel = {r =135,g=91,b=7,a=255},--选中  
        outline_color_sel = {r =160,g=86,b=5,a=255}, --选中     
        text = "no data"
        },
    ]]    
    txt_myfamily={
        have_selstate = true, --是否有选中态
        outline_width = nil, 
        font_color = {r =227,g=233,b=255,a=255},  --默认未选中
        outline_color = {r =0,g=0,b=0,a=255},     --默认未选中
        font_color_sel = {r =135,g=91,b=7,a=255},--选中  
        outline_color_sel = {r =160,g=86,b=5,a=255}, --选中     
        text = trans_createfamily
    },
    
    txt_search={
        have_selstate = true, --是否有选中态
        outline_width = nil, 
        font_color = {r =227,g=233,b=255,a=255},  --默认未选中
        outline_color = {r =0,g=0,b=0,a=255},     --默认未选中
        font_color_sel = {r =135,g=91,b=7,a=255},--选中  
        outline_color_sel = {r =160,g=86,b=5,a=255}, --选中     
        text = trans_searchfamily
    },
    txt_pagegang={
        have_selstate = false, --是否有选中态
        outline_width = nil, 
        font_color = {r =255,g=255,b=255,a=255},  --默认未选中
        outline_color = {r =0,g=0,b=0,a=255},     --默认未选中
        text = "no data"
    },    
}

local bgImageColorInfo = { --背景图片颜色切换信息
    pic_listtitlebg = {
        have_selstate = true,
        color_default = {r=67,g=85,b=100,a=255},
        color_sel = {r=181,g=122,b=9,a=255},     
    },

    pic_rknumbg = {
        have_selstate = true,
        color_default = {r=67,g=85,b=100,a=255},
        color_sel = {r=181,g=122,b=9,a=255},     
    },
    
    pic_fightpowerbg = {
        have_selstate = true,
        color_default = {r=67,g=85,b=100,a=255},
        color_sel = {r=181,g=122,b=9,a=255},     
    },

    pic_listiconbg = {
        have_selstate = true,
        color_default = {r=128,g=161,b=172,a=255},
        color_sel = {r=220,g=167,b=6,a=255},          
    },
}

---------------------------------我是分割线------------------------------------
--[[
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
]]
--局部函数
---设置label的字体
local function setLabel(label,string,outline,outlinewidth,textColor,maxwidth,singleline)

    CSResourceMgr.setLabelColorByNode(label,textColor)
    CSResourceMgr.setLabelStringByNode(label,string,nil,nil,singleline)
    if outlinewidth~=nil  then
        label:enableOutline(outline, outlinewidth)
    end

    if maxwidth~=nil then
        CSResourceMgr.setLabelMaxWidthByNode(label,maxwidth)
    end
end

---关闭UI
local function  hideUI()
    GameAudio.playUISound("retract")
    SceneMgr.setMapVisible(true)
    UnblockLoader.cancel("FamilyListViewMgr.show")
	UnblockLoader.cancel("FamilyListViewMgr.loadlist")
    local list1 = CSResourceMgr.getNodeByName(resNameFamilyList,"list1") 
    if list1 then
        list1:removeAllItems()
    end



    CSResourceMgr.removeCSObjectByTag(resNameFamilyList)
    CSResourceMgr.removeCSObjectByTag(resNameBg,"FamilyLstBg")
    currentPageIndex = 0
    UIStack.pop("FamilyListViewMgr")
end

local function initUIBaseData()
    
    local myfamiltext = CSResourceMgr.getNodeByName(resNameFamilyList,"txt_myfamily")
    
    if CharInfo.getFamilyID()~= nil then
        fontInfo.txt_myfamily.text = trans_myfamily
    else
        fontInfo.txt_myfamily.text = trans_createfamily
    end
    setLabel(myfamiltext,fontInfo.txt_myfamily.text,fontInfo.txt_myfamily.outline_color,fontInfo.txt_myfamily.outline_width,fontInfo.txt_myfamily.font_color)
    
    local search = CSResourceMgr.getNodeByName(resNameFamilyList,"txt_search")
    setLabel(search,fontInfo.txt_search.text,fontInfo.txt_search.outline_color,fontInfo.txt_search.outline_width,fontInfo.txt_search.font_color)

    local title = CSResourceMgr.getNodeByName(resNameFamilyList,"txt_title")
    setLabel(title,fontInfo.txt_title.text,fontInfo.txt_title.outline_color,fontInfo.txt_title.outline_width,fontInfo.txt_title.font_color)
          
    --local page1 = CSResourceMgr.getNodeByName(resNameFamilyList,"txt_page1")
    --page1:setVisible(false)
 
    --local page2 = CSResourceMgr.getNodeByName(resNameFamilyList,"txt_page2")
    --page2:setVisible(false)
    

    local page = CSResourceMgr.getNodeByName(resNameFamilyList,"txt_pagegang")
    setLabel(page,"1",fontInfo.txt_pagegang.outline_color,fontInfo.txt_pagegang.outline_width,fontInfo.txt_pagegang.font_color)


end

--根据屏幕适配尺寸
local function resize()

    local diff = CocosModuleMgr.getScreenSizeDiff()
    local frame = CSResourceMgr.getNodeByName(resNameFamilyList, "frame")
    local fsize = frame:getContentSize()
    frame:setContentSize(fsize.width, fsize.height+diff)
    
    local diban = CSResourceMgr.getNodeByName(resNameFamilyList, "panel_diwen")
    local dbsize = diban:getContentSize()
    diban:setContentSize(dbsize.width, dbsize.height+diff)
    
    local listbg1 = CSResourceMgr.getNodeByName(resNameFamilyList, "pic_listbg1")
    dbsize = listbg1:getContentSize()
    listbg1:setContentSize(dbsize.width, dbsize.height+diff)

    local listbg2 = CSResourceMgr.getNodeByName(resNameFamilyList, "pic_listbg2")
    dbsize = listbg2:getContentSize()
    listbg2:setContentSize(dbsize.width, dbsize.height+diff)
    
    local list1 = CSResourceMgr.getNodeByName(resNameFamilyList, "list1")
    dbsize = list1:getContentSize()
    list1:setContentSize(dbsize.width, dbsize.height+diff)
    
    local title = CSResourceMgr.getNodeByName(resNameFamilyList, "txt_title")
    local tposy = title:getPositionY()
    title:setPositionY(tposy+diff)
    local close = CSResourceMgr.getNodeByName(resNameFamilyList, "close")
    local cposy = close:getPositionY()
    close:setPositionY(cposy+diff)
    
    local list1 = CSResourceMgr.getNodeByName(resNameFamilyList, "list1")
    --dbsize = list1:getContentSize()
    --list1:setContentSize(dbsize.width, dbsize.height+diff)
    list1:setVisible(true)
    
end


local function createListCell(data)
    local listcell = CSResourceMgr.getNodeByName(resNameFamilyList,"btn_listexample"):clone()
    
    CSResourceMgr.setSpriteTextureByNode(CSResourceMgr.seekNodeByName(listcell, "pic_icon"), data.icon)
    
    local joinstyle_bg = CSResourceMgr.seekNodeByName(listcell, "joinstyle_bg")
    joinstyle_bg:setColor({r=0,g=0,b=0})
    joinstyle_bg:setOpacity(155)
    
    local joinstyle = CSResourceMgr.seekNodeByName(listcell, "join_style")
    if data.needCheckJoin == 0 then
        CSResourceMgr.setLabelStringByNode(joinstyle, "family1", {r=0,g=0,b=0,a=255,w=1})
    else
        CSResourceMgr.setLabelStringByNode(joinstyle, "family2", {r=0,g=0,b=0,a=255,w=1})
    end
    
    local listtitlebg = CSResourceMgr.seekNodeByName(listcell,"pic_listtitlebg")
    listtitlebg:setColor(bgImageColorInfo.pic_listtitlebg.color_default)

    local rknumbg = CSResourceMgr.seekNodeByName(listcell,"pic_rknumbg")
    rknumbg:setColor(bgImageColorInfo.pic_rknumbg.color_default)

    local fightpowerbg = CSResourceMgr.seekNodeByName(listcell,"pic_fightpowerbg")
    fightpowerbg:setColor(bgImageColorInfo.pic_fightpowerbg.color_default)
    
    local listiconbg = CSResourceMgr.seekNodeByName(listcell,"pic_listiconbg")
    listiconbg:setColor(bgImageColorInfo.pic_listiconbg.color_default)

    local icontitle = CSResourceMgr.seekNodeByName(listcell,"txt_icontitle")
    setLabel(icontitle,data.name.." Lv"..(data.familyLevel or 1),fontInfo.txt_icontitle.outline_color,fontInfo.txt_icontitle.outline_width,fontInfo.txt_icontitle.font_color)
    
    local familynumstr = tostring(data.memberNum).."/"..(30 + (data.familyLevel or 1)*4)
    local familynum = CSResourceMgr.seekNodeByName(listcell,"txt_listrknum")
    familynum:setString(familynumstr)
    --setLabel(familynum,familynumstr,fontInfo.txt_icontitle.outline_color,fontInfo.txt_icontitle.outline_width,fontInfo.txt_icontitle.font_color)

    local battlepowerstr = "999999"
    local battlepower = CSResourceMgr.seekNodeByName(listcell,"txt_listbattlepower")
    battlepower:setString(battlepowerstr)
        
    local itemdesc = CSResourceMgr.seekNodeByName(listcell,"txt_itemdesc")
    if data.purpose == nil or data.purpose == "" then
        data.purpose = LuaSqlite.getLanguageByKey(trans_defaultjzzz)
    end
    local textstr = LuaSqlite.getLanguageByKey(trans_jzzz)..":"..data.purpose
    --setLabel(itemdesc,textstr,fontInfo.txt_itemdesc.outline_color,fontInfo.txt_itemdesc.outline_width,fontInfo.txt_itemdesc.font_color,nil,400)
    itemdesc:setString(textstr)

    if CharInfo.getFamilyID()==nil then
        CSResourceMgr.clickEventBindingByNode(listcell,
        
			function() 
				--如果没有家族,请求加入弹框
			
				DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,2,
				
				
				CocosModuleMgr.createStringWithFormat({trans_familyapply,data.name}),
				function() --ok 
				    FamilyInfo.JoinFamily(data._id)
				end,
				
				function()
				
				end)
				
			end)
    else --如果有家族，点击就没反映了
        CSResourceMgr.setButtonEnabledByNode(listcell,false)
    end
    return listcell
end


local function resetListCellTable(datalist)

    local list1 = CSResourceMgr.getNodeByName(resNameFamilyList,"list1")
    list1:removeAllItems()
    
    local funcTable = {}
    UnblockLoader.cancel("FamilyListViewMgr.loadlist")
	
    if datalist ~= nil then
        print("#datalist......" ..#datalist)
       
        for i =1,#datalist do
			table.insert(funcTable,function() 
				local listcell = createListCell(datalist[i])
				listcell:setScaleY(0)
				list1:pushBackCustomItem(listcell)
				transition.scaleTo(listcell,{scale=1.0,time = 0.1})
			end)

            
        end    
		
        UnblockLoader.load(funcTable,"FamilyListViewMgr.loadlist")
    end
end

local function sendPageRequest(pageindex)
    pageindex = pageindex or currentPageIndex
    local FamilySend =  require("src.Net.Send.FamilySend")
    local pagetable = {startIndex = pageindex ,num = CONST_PERPAGE_NUM}
    local str = json.encode(pagetable)
    FamilySend.sendCG_Family_Req({cmd ="QueryFamilyList",concent = str })
end

local function buttonBinding()
    local searchfamilybtn = CSResourceMgr.getNodeByName(resNameFamilyList,"btn_search")
    CSResourceMgr.clickEventBindingByNode(searchfamilybtn,function() 
        --print("搜索家族界面")
        GameAudio.playUISound("ok")
        SearchFamilyMgr.show(SceneMgr.getRunningScene)
    end)
    
    local ruleBtn = searchfamilybtn:clone()
    local layer   = CSResourceMgr.getCsbObj(resNameFamilyList)
    ruleBtn:addTo(layer)
    ruleBtn:setPosition(455,860+CocosModuleMgr.getScreenSizeDiff())
    local text = ruleBtn:getTitleRenderer()
    text:setPositionY(text:getPositionY()+3)
    ruleBtn:setTitleText(LuaSqlite.getLanguageByKey("activity13"))
    CSResourceMgr.clickEventBindingByNode(ruleBtn,function() 
        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,1,"familySignIn9",function()             
                    end,nil,nil,true)
    end)

    local myfamilybtn = CSResourceMgr.getNodeByName(resNameFamilyList,"btn_myfamily")
    CSResourceMgr.clickEventBindingByNode(myfamilybtn,function() 

        if CharInfo.getFamilyID()==nil then
            GameAudio.playUISound("ok")
            CreateFamilyMgr.show(SceneMgr.getRunningScene)
        else       
            hideUI()
            MyFamilyLstViewMgr.show(SceneMgr.getRunningScene)    
        end
    end)
    
    local jiantour = CSResourceMgr.getNodeByName(resNameFamilyList,"btn_jiantour")
    local jiantoul = CSResourceMgr.getNodeByName(resNameFamilyList,"btn_jiantoul")    
    
    CSResourceMgr.clickEventBindingByNode(jiantour,
    
    
        function() 
            GameAudio.playUISound("petchange")
            local cjson = require("cjson")
            local tbl = cjson.decode(FamilyListViewMgr.famliyLstJsonStr)
            if tbl.familys == nil or #tbl.familys < CONST_PERPAGE_NUM then
                StandardTipsMgr.show(1,trans_finalpage)
            else
                NetInterface.sendWithBlock("GC_FAMILY_ACK",function() 
                    
                    sendPageRequest(currentPageIndex+CONST_PERPAGE_NUM)
                end,
                function()
                    local cjson = require("cjson")
                    local tbl = cjson.decode(FamilyListViewMgr.famliyLstJsonStr)
                    if tbl.familys == nil then 
                        StandardTipsMgr.show(1,trans_finalpage)  
                    else
                        currentPageIndex = currentPageIndex+CONST_PERPAGE_NUM
                        resetListCellTable(tbl.familys)
                        local pagenum = currentPageIndex/CONST_PERPAGE_NUM+1
                        local pagegang = CSResourceMgr.getNodeByName(resNameFamilyList,"txt_pagegang")
                        setLabel(pagegang,tostring(pagenum),fontInfo.txt_pagegang.outline_color,fontInfo.txt_pagegang.outline_width,fontInfo.txt_pagegang.font_color)                  
                    end

    
                end,
                function(code) 
                    StandardTipsMgr.show(1,code)
                end)            
            end
           
    end,3)
    
    
    CSResourceMgr.clickEventBindingByNode(jiantoul,


        function() 
            GameAudio.playUISound("petchange")
            if currentPageIndex < CONST_PERPAGE_NUM then
                --StandardTipsMgr.show(1,trans_finalpage)
            else
                NetInterface.sendWithBlock("GC_FAMILY_ACK",function() 

                        sendPageRequest(currentPageIndex-CONST_PERPAGE_NUM)
                end,
                function()
                    currentPageIndex = currentPageIndex-CONST_PERPAGE_NUM
                    local cjson = require("cjson")
                    local tbl = cjson.decode(FamilyListViewMgr.famliyLstJsonStr)
                    resetListCellTable(tbl.familys)
                    local pagenum = currentPageIndex/CONST_PERPAGE_NUM+1
                    local pagegang = CSResourceMgr.getNodeByName(resNameFamilyList,"txt_pagegang")
                    setLabel(pagegang,tostring(pagenum),fontInfo.txt_pagegang.outline_color,fontInfo.txt_pagegang.outline_width,fontInfo.txt_pagegang.font_color)

                end,
                function(code) 
                    StandardTipsMgr.show(1,code)
                end)            
            end

        end,3)

end

local function addUI(scene)
    if CSResourceMgr.getCsbObj(resNameFamilyList) then
        return
    end   
    
    SceneMgr.setMapVisible(false)
    
    local bgUI = CSResourceMgr.createRes(scene,resNameBg ,"FamilyLstBg")
    local csbUI = CSResourceMgr.createRes(scene,resNameFamilyList)

    local function loadBG()

        bgUI:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBg, 320, 480,"FamilyLstBg")
    end    
    
    local function loadCSB()
        csbUI:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        csbUI:setVisible(false)
        CSResourceMgr.setRelativePosition(resNameFamilyList, 320, 480)   
        CocosModuleMgr.setEdgeDistance(csbUI,nil,nil,nil,0)        
        
        resize()
        initUIBaseData()
        
        local cjson = require("cjson")
        local tbl = cjson.decode(FamilyListViewMgr.famliyLstJsonStr)
        resetListCellTable(tbl.familys)
        --close按钮绑定
        CSResourceMgr.clickEventBinding(resNameFamilyList,"close",function()
            hideUI()
        end)
    end
    
    local function playCSB()
        CSResourceMgr.getCsbObj(resNameFamilyList):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resNameFamilyList), "up", function()
            end)

    end
    
    
    loadBG()
    loadCSB()
    playCSB()
    buttonBinding()
end

local function request(scene)
    NetInterface.sendWithBlock("GC_FAMILY_ACK",function() 
        sendPageRequest()
    end,
    function()
        scene = scene or SceneMgr.getRunningScene
        addUI(scene)

    end
    ,
    function(code) 
        StandardTipsMgr.show(1,code)
    end)
end



---------------------------------我是分割线------------------------------------
--类函数
function FamilyListViewMgr.Init()
    resNameFamilyList = "Player/Family/FamilyList.csb"
    resNameBg = "Pet/Formation/FormationBG.csb"
    currentPageIndex = 0;
end

function FamilyListViewMgr.getCurrentPageIndex()
    return currentPageIndex
end

function FamilyListViewMgr.show(scene)
    GameAudio.playUISound("popup")
    UIStack.push("FamilyListViewMgr",FamilyListViewMgr.hide,false)
    request(scene)
end

function FamilyListViewMgr.hide()
    hideUI()
end

function FamilyListViewMgr.IsOpen()
    return CSResourceMgr.getCsbObj(resNameFamilyList)
end

return FamilyListViewMgr