local FamilyApplyListViewMgr = {}

--vesion number 1.0
--@client side FamilyApplyListViewMgr.lua
--[[
这个文件是家族申请列表界面
--]]
--script writer Leon Lee
--creation time 2016-4-29

--const
local CONST_PERPAGE_NUM = 6


--翻译

local trans_applylist = "family44"--"申请列表"
local trans_close = "family45"--"关闭"
local trans_accept = "family46"--"接受"
local trans_decline = "family47"--"拒绝"

---------------------------------我是分割线------------------------------------

--ui初始化信息
local resNameFamilyApplyList = ""
local familyApplyList = {}
local fontInfo = {

	txt_maintitle ={
        have_selstate = false, --是否有选中态
        outline_width = 2,
        font_color = {r =144,g=238,b=255,a=255},
        outline_color = {r =38,g=54,b=76,a=255},
        text = trans_applylist
    },
	
	txt_close ={
        have_selstate = false, --是否有选中态
        outline_width = 2,
        font_color = {r =227,g=233,b=255,a=255},
        outline_color = {r =0,g=0,b=0,a=255},
        text = trans_close
    },	
	
	
}

local lstFontInfo = {

	txt_playername ={
        have_selstate = false, --是否有选中态
        outline_width = 1,
        font_color = {r =255,g=255,b=255,a=255},
        outline_color = {r =5,g=48,b=84,a=255},
        text = "no data"
    },		

    txt_playerlv ={
        have_selstate = false, --是否有选中态
        outline_width = 1,
        font_color = {r =255,g=252,b=0,a=255},
        outline_color = {r =0,g=0,b=0,a=255},
        text = "no data"
    },	
    
    txt_ok = {
        have_selstate = false, --是否有选中态
        outline_width = 1,
        font_color = {r =255,g=255,b=255,a=255},
        outline_color = {r =62,g=77,b=27,a=255,w = 1},
        text = trans_accept     
    },

    txt_cancel={
        have_selstate = false, --是否有选中态
        outline_width = 1,
        font_color = {r =255,g=255,b=255,a=255},
        outline_color = {r =62,g=77,b=27,a=255,w=1},
        text = trans_decline    
    },	
}

local bgImageColorInfo = { --背景图片颜色切换信息
    pic_namebg = {
        have_selstate = false,
        color_default = {r=148,g=169,b=175,a=255},   
    },

    pic_lvbg = {
        have_selstate = false,
        color_default = {r=88,g=105,b=110,a=255},         
    },
}


--逻辑变量
local currentListOperIndex = -1 --当前列表操作的序号
local currentListOperData = nil --当前列表操作的数据

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

function FamilyApplyListViewMgr.hideUI()
	UnblockLoader.cancel("FamilyApplyListViewMgr.loadlist")
	local list1 = CSResourceMgr.getNodeByName(resNameFamilyApplyList,"list1")
	if list1 then
		list1:removeAllItems()
	end
	
	CSResourceMgr.removeCSObjectByTag(resNameFamilyApplyList)
    UIStack.pop("FamilyApplyListViewMgr")
end

local function createListCell(data)

	local function setCellData(data)
		lstFontInfo.txt_playername.text = data.name
        lstFontInfo.txt_playerlv.text = "Lv"..data.level
	end
	
	setCellData(data)
	
	local listcell = CSResourceMgr.getNodeByName(resNameFamilyApplyList,"btn_listexample"):clone()
	
	local namebg = CSResourceMgr.seekNodeByName(listcell,"pic_namebg")
	namebg:setColor(bgImageColorInfo.pic_namebg.color_default)
	
	local lvbg = CSResourceMgr.seekNodeByName(listcell,"pic_lvbg")
	lvbg:setColor(bgImageColorInfo.pic_lvbg.color_default)
	
  
	for k,v in pairs(lstFontInfo) do
		local concatstr = ""
        local txtcell = CSResourceMgr.seekNodeByName(listcell,concatstr..k)
        --print("concatstr2..k:"..concatstr..k)
		setLabel(txtcell,v.text,v.outline_color,v.outline_width,v.font_color)	
	end
	
    local pic = CSResourceMgr.seekNodeByName(listcell,"pic_headicon")

    local fashionInfo = ItemInfo.getFashionItemInfoById(data.fashion.curFashion[1])
    pic:loadTexture(fashionInfo.filePath)
    
    local acceptbtn = CSResourceMgr.seekNodeByName(listcell,"btn_ok")
    local decliebtn = CSResourceMgr.seekNodeByName(listcell,"btn_cancel")
    
    CSResourceMgr.clickEventBindingByNode(acceptbtn,function() 
        FamilyInfo.AcceptMember(data.charID, data.name)
        local list1 = CSResourceMgr.getNodeByName(resNameFamilyApplyList,"list1")
        local items = list1:getItems()
        for i=1, #items do
            if items[i] == listcell then
                currentListOperIndex = i - 1
                break
            end
        end
		currentListOperData = listcell.data
    end)
    
    CSResourceMgr.clickEventBindingByNode(decliebtn,function() 
        FamilyInfo.RefuseMember(data.charID)
        local list1 = CSResourceMgr.getNodeByName(resNameFamilyApplyList,"list1")
        local items = list1:getItems()
        for i=1, #items do
            if items[i] == listcell then
                currentListOperIndex = i - 1
                break
            end
        end
		currentListOperData = listcell.data
    end)   
    
    
    return listcell
end

local function resetListCellTable()

    local cjson = require("cjson")
    --local tbl = cjson.decode(FamilyApplyListViewMgr.familyApplyListJsonStr)
	local list1 = CSResourceMgr.getNodeByName(resNameFamilyApplyList,"list1")
	list1:removeAllItems()
	
	local index = 0 --用来记录的序号
	local funcTable = {}
	UnblockLoader.cancel("FamilyApplyListViewMgr.loadlist")
    for k,v in pairs(familyApplyList) do
		table.insert(funcTable,function() 
			local listcell = createListCell(v)
			listcell.index = index
			listcell.data = v
			listcell:setScaleY(0)
			list1:pushBackCustomItem(listcell)
			index = index+1
			transition.scaleTo(listcell,{scale=1.0,time = 0.1})
		end)

	end
	UnblockLoader.load(funcTable,"FamilyApplyListViewMgr.loadlist")
end

local function initUIBaseData()

	for k,v in pairs(fontInfo) do
		local concatstr = ""
		local txtcell = CSResourceMgr.getNodeByName(resNameFamilyApplyList,concatstr..k)
        
		setLabel(txtcell,v.text,v.outline_color,v.outline_width,v.font_color)	
	end
	
	
end


local function addUI(scene)
	if CSResourceMgr.getCsbObj(resNameFamilyApplyList) then
		return
	end
	
	local csbUI = CSResourceMgr.createRes(scene,resNameFamilyApplyList)
	local function loadCSB()
		csbUI:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
		csbUI:setVisible(false)
		CSResourceMgr.setRelativePosition(resNameFamilyApplyList,320,480)
		--CocosModuleMgr.setEdgeDistance(csbUI,nil,nil,nil,0)
		initUIBaseData()
		--resetListCellTable()
	end
	
	local function playCSB()
        CSResourceMgr.getCsbObj(resNameFamilyApplyList):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resNameFamilyApplyList), "down", function()
            end)
	end
	
	local function buttonBinding()
        --close按钮绑定
        CSResourceMgr.clickEventBinding(resNameFamilyApplyList,"btn_close",function()
            FamilyApplyListViewMgr.hideUI()
        end)
        
        CSResourceMgr.clickEventBinding(resNameFamilyApplyList, "bg", function()
            FamilyApplyListViewMgr.hideUI()
        end)
	end
	
	loadCSB()
	playCSB()
	buttonBinding()
	
	FamilyInfo.QueryMyFamily(true)
end

---------------------------------我是分割线------------------------------------
---类函数
function FamilyApplyListViewMgr.Init()
	resNameFamilyApplyList = "Player/Family/FamilyApplyLst.csb"
    familyApplyList = {}
end

function FamilyApplyListViewMgr.show(scene)
    UIStack.push("FamilyApplyListViewMgr",FamilyApplyListViewMgr.hideUI,false)
	addUI(scene)
end

function FamilyApplyListViewMgr.refreshApplyList(apply)
	familyApplyList = apply or {}
	if CSResourceMgr.getCsbObj(resNameFamilyApplyList) then
	   resetListCellTable()
	end
end

function FamilyApplyListViewMgr.isOpen()
    if CSResourceMgr.getCsbObj(resNameFamilyApplyList) then
        return true
    else
        return false
    end
end

function FamilyApplyListViewMgr.delCurOperListCell(charID) --删除当前操作的列表
    if charID then
        familyApplyList[tostring(charID)] = nil
    end
    
    if CSResourceMgr.getCsbObj(resNameFamilyApplyList) then
        local list1 = CSResourceMgr.getNodeByName(resNameFamilyApplyList,"list1")
        list1:removeItem(currentListOperIndex)
        local items = list1:getItems()
        if #items == 0 then
            familyApplyList = {}
        end
		
		currentListOperIndex = -1
    end
end

function FamilyApplyListViewMgr.finishMemberAdd(charID) --完成家族成员添加
    FamilyApplyListViewMgr.delCurOperListCell(charID)
    MyFamilyLstViewMgr.addNewMemberFromApplyLst(currentListOperData)
    currentListOperData = nil
end




return FamilyApplyListViewMgr