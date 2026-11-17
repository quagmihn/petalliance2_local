local FamilyTransListViewMgr = {}

--vesion number 1.0
--@client side FamilyTransListViewMgr.lua
--[[
这个文件是家族转让列表界面
--]]
--script writer Leon Lee
--creation time 2016-4-29

--const
local CONST_PERPAGE_NUM = 6

--翻译
local trans_transfrerfamily = "family7"
local trans_cancel = "family31"
local trans_elder = "family32"
local trans_manager = "family33"
local trans_yijiaozuzhang = "family34"
local trans_familyhyd = "family152"
local trans_loginlabel = "family36"
local trans_jobtitle = "family37"
local trans_familynotice = "family130"
local trans_loginstr = "family39"
local trans_elder = "family40"
local trans_manager = "family41"
local trans_nojob = "family42"
local trans_creater = "family43"

---------------------------------我是分割线------------------------------------

--ui初始化信息
local resNameFamilyTransList = ""
local fontInfo = {
	txt_maintitle ={
		have_selstate = false, --是否有选中态
		outline_width = 2,
		font_color = {r =144,g=238,b=255,a=255},
		outline_color = {r =38,g=54,b=76,a=255},
		text = trans_transfrerfamily
	},

	txt_close ={
        have_selstate = false, --是否有选中态
        outline_width = 2,
        font_color = {r =227,g=233,b=255,a=255},
        outline_color = {r =0,g=0,b=0,a=255},
        text = trans_cancel
    },	

}

local bgImageColorInfo = { --背景图片颜色切换信息
    pic_listtitlebg = {
        have_selstate = true,
        color_default = {r=67,g=85,b=100,a=255},
        color_sel = {r=181,g=122,b=9,a=255},     
    },

    pic_hydbg = {
    
        have_selstate = true,
        color_default = {r=48,g=65,b=79,a=255},
        color_sel = {r=220,g=167,b=6,a=255},          
    },
    
    pic_listiconbg = {
        have_selstate = true,
        color_default = {r=128,g=161,b=172,a=255},
        color_sel = {r=220,g=167,b=6,a=255},          
    },
}

local lstFontInfo ={
    txt_icontitle = {
        have_selstate = false, --是否有选中态
        outline_width = 1,
        font_color = {r =227,g=233,b=255,a=255},
        outline_color = {r =0,g=0,b=0,a=255},
        text = "no data"          
    },
    
    txt_level = {
        have_selstate = false, --是否有选中态
        outline_width = 2,
        font_color = {r =255,g=252,b=0,a=255},
        outline_color = {r =0,g=0,b=0,a=255},
        text = "LV 0"       
        
    },
    
    txt_jobcont = {
        have_selstate = false, --是否有选中态
        outline_width = 2,
        font_color = {r =255,g=252,b=0,a=255},
        outline_color = {r =5,g=48,b=84,a=255},
        text = trans_nojob    
    
    },
    
    txt_joblabel = {
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =71,g=96,b=103,a=255},
        outline_color = {r =5,g=48,b=84,a=255},
        text = trans_jobtitle      
    
    },
    
    txt_loginlabel = {
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =71,g=96,b=103,a=255},
        outline_color = {r =5,g=48,b=84,a=255},
        text = trans_loginlabel     
    },
    
    txt_logincont = {
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =71,g=96,b=103,a=255},
        outline_color = {r =5,g=48,b=84,a=255},
        text = trans_loginstr       
    
    },
    
    txt_hydtitle = {
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =71,g=96,b=103,a=255},
        outline_color = {r =5,g=48,b=84,a=255},
        text = trans_familyhyd      
    
    },
    
    txt_hydnum = {
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =255,g=255,b=255,a=255},
        outline_color = {r =5,g=48,b=84,a=255},
        text = "0"       

    },

}

---------------------------------我是分割线------------------------------------
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

local function hideUI()

    local list1 = CSResourceMgr.getNodeByName(resNameFamilyTransList,"list1")
	if list1 then
		list1:removeAllItems()
	end
	
    CSResourceMgr.removeCSObjectByTag(resNameFamilyTransList)
    UIStack.pop("FamilyTransListViewMgr")
end


local function createListCell(data)

    local info =  FamilyInfo.GetLocalFamilyInfo()
    
    if info.leaderID == data.charID then --自己不能转让给自己直接return nil
        return nil        
    end
	local function setCellData(data)
        lstFontInfo.txt_icontitle.text = data.name
        lstFontInfo.txt_level.text = "LV "..data.level
        if data.logoutTime~=nil then
            local timestr = data.logoutTime["$date"]
            lstFontInfo.txt_logincont.text = string.sub(timestr,0,10)
        end
        

  
        local charid = data.charID

        
        
        
        if info.elders~= nil then
            for i = 1,#info.elders do 
                if info.elders[i] == charid then
                    fontInfo.txt_jobcont = trans_elder
                    break
                end
            end
        end 
        
        if info.managers~= nil then
            for i = 1,#info.managers do
                if info.managers[i] == charid then
                    fontInfo.txt_jobcont = trans_manager
                    break
                end               
            end
        end
    end
    
    setCellData(data)
    local listcell = CSResourceMgr.getNodeByName(resNameFamilyTransList,"btn_listexample"):clone()

    local listtitlebg = CSResourceMgr.seekNodeByName(listcell,"pic_listtitlebg")
    listtitlebg:setColor(bgImageColorInfo.pic_listtitlebg.color_default)


    local listiconbg = CSResourceMgr.seekNodeByName(listcell,"pic_listiconbg")
    listiconbg:setColor(bgImageColorInfo.pic_listiconbg.color_default)

    local hydbg = CSResourceMgr.seekNodeByName(listcell,"pic_hydbg")
    hydbg:setColor(bgImageColorInfo.pic_hydbg.color_default)
    --hydbg:setColor({r=0,g=0,b=0})
    --print("sui bia jia de" ..hydbg)
   

    local hydtitle = CSResourceMgr.seekNodeByName(listcell,"txt_hydtitle")
    setLabel(hydtitle,lstFontInfo.txt_hydtitle.text,lstFontInfo.txt_hydtitle.outline_color,lstFontInfo.txt_hydtitle.outline_width,lstFontInfo.txt_hydtitle.font_color,nil,100)

    local hydnum = CSResourceMgr.seekNodeByName(listcell,"txt_hydnum")
    setLabel(hydnum,tostring(data.devotePoint or 0),lstFontInfo.txt_hydnum.outline_color,lstFontInfo.txt_hydnum.outline_width,lstFontInfo.txt_hydnum.font_color)

    local icontitle = CSResourceMgr.seekNodeByName(listcell,"txt_icontitle")
    setLabel(icontitle,lstFontInfo.txt_icontitle.text,lstFontInfo.txt_icontitle.outline_color,lstFontInfo.txt_icontitle.outline_width,lstFontInfo.txt_icontitle.font_color)

    local joblabel = CSResourceMgr.seekNodeByName(listcell,"txt_joblabel")
    setLabel(joblabel,lstFontInfo.txt_joblabel.text,lstFontInfo.txt_joblabel.outline_color,lstFontInfo.txt_joblabel.outline_width,lstFontInfo.txt_joblabel.font_color,nil,45)

    local jobcont = CSResourceMgr.seekNodeByName(listcell,"txt_jobcont")
    setLabel(jobcont,lstFontInfo.txt_jobcont.text,lstFontInfo.txt_jobcont.outline_color,lstFontInfo.txt_jobcont.outline_width,lstFontInfo.txt_jobcont.font_color,nil,100)

    local loginlabel = CSResourceMgr.seekNodeByName(listcell,"txt_loginlabel")
    setLabel(loginlabel,lstFontInfo.txt_loginlabel.text,lstFontInfo.txt_loginlabel.outline_color,lstFontInfo.txt_loginlabel.outline_width,lstFontInfo.txt_loginlabel.font_color,nil,100)    

    local logincont = CSResourceMgr.seekNodeByName(listcell,"txt_logincont")
    setLabel(logincont,lstFontInfo.txt_logincont.text,lstFontInfo.txt_logincont.outline_color,lstFontInfo.txt_logincont.outline_width,lstFontInfo.txt_logincont.font_color,nil,100) 

    local level = CSResourceMgr.seekNodeByName(listcell,"txt_level")
    setLabel(level,lstFontInfo.txt_level.text,lstFontInfo.txt_level.outline_color,lstFontInfo.txt_level.outline_width,lstFontInfo.txt_level.font_color) 

	local pic = CSResourceMgr.seekNodeByName(listcell,"pic_icon")
	
	local fashionInfo = ItemInfo.getFashionItemInfoById(data.fashion.curFashion[1])
	pic:loadTexture(fashionInfo.filePath)
	
	CSResourceMgr.clickEventBindingByNode(listcell,function() 
        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,2,


            CocosModuleMgr.createStringWithFormat({trans_yijiaozuzhang,data.name}),
            function() --ok 
                FamilyInfo.TransferFamily(data.charID, data.name)
            end,

            function()

            end)
	end)
	
    return listcell
end

local function resetListCellTable()

    local cjson = require("cjson")
    local datalist = MyFamilyLstViewMgr.famliyMemberLst

    local list1 = CSResourceMgr.getNodeByName(resNameFamilyTransList,"list1")
    list1:removeAllItems()
	local funcTable = {}
	UnblockLoader.cancel("FamilyTransListViewMgr.loadlist")
    if datalist ~= nil then

        for k,v in pairs(datalist) do
			
			table.insert(funcTable,function() 
				local listcell = createListCell(v)
				if listcell~=nil then
					listcell:setScaleY(0)
					list1:pushBackCustomItem(listcell)
					transition.scaleTo(listcell,{scale=1.0,time=0.1})
				end
			end)


        end 
		UnblockLoader.load(funcTable,"FamilyTransListViewMgr.loadlist")
    end
end

local function initUIBaseData()

	for k,v in pairs(fontInfo) do
		local concatstr = ""
		local txtcell = CSResourceMgr.getNodeByName(resNameFamilyTransList,concatstr..k)
        
		setLabel(txtcell,v.text,v.outline_color,v.outline_width,v.font_color)	
	end
	
	
end

local function addUI(scene)
	if CSResourceMgr.getCsbObj(resNameFamilyTransList) then
	
		return
	end
	
	local csbUI = CSResourceMgr.createRes(scene,resNameFamilyTransList)
	
	local function loadCSB()
		csbUI:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
		csbUI:setVisible(false)
		CSResourceMgr.setRelativePosition(resNameFamilyTransList,320,480)
		initUIBaseData()
		resetListCellTable()
	end
	
	local function playCSB()
        CSResourceMgr.getCsbObj(resNameFamilyTransList):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resNameFamilyTransList), "down", function()
            end)	
	end
	
    local function buttonBinding()
        --close按钮绑定
        CSResourceMgr.clickEventBinding(resNameFamilyTransList,"btn_close",function()
            hideUI()
        end)

        CSResourceMgr.clickEventBinding(resNameFamilyTransList, "bg", function()
            hideUI()
        end)
    end
    
    loadCSB()
    playCSB()
    buttonBinding()
    
end

function FamilyTransListViewMgr.Init()

    resNameFamilyTransList =  "Player/Family/FamilyTransLst.csb"
end

function FamilyTransListViewMgr.show(scene)
    UIStack.push("FamilyTransListViewMgr",FamilyTransListViewMgr.hide,false)
    addUI(scene)
end

function FamilyTransListViewMgr.hide()
    hideUI()
end

return FamilyTransListViewMgr