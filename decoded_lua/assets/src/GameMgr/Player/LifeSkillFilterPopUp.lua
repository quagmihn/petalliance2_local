local LifeSkillFilterPopUp = {}

LifeSkillFilterPopUp.lasttype = -1
LifeSkillFilterPopUp.lastid = -1
--翻译
local trans_shaixuan = "lifeSkill025" --"筛选"
local filterLabel  = {
    [1]={
        "lifeSkill026",--"显示全部",
        "lifeSkill027",--"头 饰",
        "lifeSkill028",--"衣 服",
        "lifeSkill029",--"裤 子",
        "lifeSkill030",--"背 饰",
        "lifeSkill031",--"武 器"
    },


    [3]={
        "lifeSkill026",--"显示全部",
        "lifeSkill032",--"门牌",
        "lifeSkill033",--"门",
        "lifeSkill034",--"旅行箱",
        "lifeSkill035",--"墙纸",
        "lifeSkill036",--"地板",
        "lifeSkill037",--"盆栽",
        "lifeSkill038",--"墙饰",
        "lifeSkill039",--"吊灯"
    },
    [2]={
        "lifeSkill026",--"显示全部",
        "lifeSkill040",--"床",
        "lifeSkill041",--"衣柜",
        "lifeSkill042",--"沙发",
        "lifeSkill043",--"桌子",
        "lifeSkill044",--"电视",
        "lifeSkill045",--"跑步机",
        "lifeSkill046",--"电脑"
    },

}


local filter = {
    [1]={
        "显示全部",
        "头饰",
        "衣服",
        "裤子",
        "背饰",
        "武器"
    },
    

    [3]={
        "显示全部",
        "门牌",
        "门",
        "旅行箱",
        "墙纸",
        "地板",
        "盆栽",
        "墙饰",
        "吊灯"
    },
    [2]={
        "显示全部",
        "床",
        "衣柜",
        "沙发",
        "桌子",
        "电视",
        "跑步机",
        "电脑"
    },

}

--[[
local filter = {
    [1]={
        "lifeSkill026",--"显示全部",
        "lifeSkill027",--"头 饰",
        "lifeSkill028",--"衣 服",
        "lifeSkill029",--"裤 子",
        "lifeSkill030",--"背 饰",
        "lifeSkill031",--"武 器"
    },
    

    [2]={
        "lifeSkill026",--"显示全部",
        "lifeSkill032",--"门牌",
        "lifeSkill033",--"门",
        "lifeSkill034",--"旅行箱",
        "lifeSkill035",--"墙纸",
        "lifeSkill036",--"地板",
        "lifeSkill037",--"盆栽",
        "lifeSkill038",--"墙饰",
        "lifeSkill039",--"吊灯"
    },
    [3]={
        "lifeSkill026",--"显示全部",
        "lifeSkill040",--"床",
        "lifeSkill041",--"衣柜",
        "lifeSkill042",--"沙发",
        "lifeSkill043",--"桌子",
        "lifeSkill044",--"电视",
        "lifeSkill045",--"跑步机",
        "lifeSkill046",--"电脑"
    },

}
]]

---------------------------------我是分割线------------------------------------
--ui初始化信息
local resNameFilterPopup =  "" --列表UI资源
local fontInfo = {--该界面所有的文本格式信息，用于界面设置

    txt_title={
        have_selstate = false, --是否有选中态
        outline_width = 2,
        font_color = {r =144,g=238,b=255,a=255},
        outline_color = {r =38,g=54,b=76,a=255},
        text = trans_shaixuan
    },
    
    txt_content={
        have_selstate = false, --是否有选中态
        outline_width = 2,
        font_color = {r =227,g=233,b=255,a=255},
        outline_color = {r =0,g=0,b=0,a=255},
        text = "no data"
    },
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
    local list = CSResourceMgr.getNodeByName(resNameFilterPopup,"list")
    list:removeAllChildren()
    CSResourceMgr.removeCSObjectByTag(resNameFilterPopup)
end

local function createList(type)
    local list = CSResourceMgr.getNodeByName(resNameFilterPopup,"list")
    local typetbl = filterLabel[type]
    for i=1,#typetbl do
        local listcell = CSResourceMgr.getNodeByName(resNameFilterPopup,"btn_filter"):clone()
        local labelText = CSResourceMgr.seekNodeByName(listcell,"txt_content")
        setLabel(labelText,typetbl[i],fontInfo.txt_content.outline_color,fontInfo.txt_content.outline_width,fontInfo.txt_content.font_color)
        if LifeSkillFilterPopUp.lasttype == type then
            if i == LifeSkillFilterPopUp.lastid then
                CSResourceMgr.setButtonEnabledByNode(listcell,false)
            end
        end
        CSResourceMgr.clickEventBindingByNode(listcell,function() 
            GameAudio.playUISound("sheetClick")
            if i == 1 then
                LifeSkillLstViewMgr.filterList(nil)           
            else
                LifeSkillLstViewMgr.filterList(filter[type][i])
          
            end
             LifeSkillFilterPopUp.lastid = i
            hideUI()
        end)
        list:pushBackCustomItem(listcell)
    end
    LifeSkillFilterPopUp.lasttype = type
end



local function addUI(scene,type)

    local function loadCSB()
        local csbUI = CSResourceMgr.createRes(scene,resNameFilterPopup)
        csbUI:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameFilterPopup, 320, 480) 
        
        local db = CSResourceMgr.getNodeByName(resNameFilterPopup,"db")
        db:setVisible(false)
        local title = CSResourceMgr.getNodeByName(resNameFilterPopup,"txt_title")
        setLabel(title,fontInfo.txt_title.text,fontInfo.txt_title.outline_color,fontInfo.txt_title.outline_width,fontInfo.txt_title.font_color)
        createList(type)
        CSResourceMgr.getNodeByName(resNameFilterPopup,"btn_close"):setVisible(false)
        CSResourceMgr.clickEventBinding(resNameFilterPopup,"btn_close",function() 
            hideUI()
        end) 
    end
    
    local function playCSB()
    
        local db = CSResourceMgr.getNodeByName(resNameFilterPopup,"db")
        local close = CSResourceMgr.getNodeByName(resNameFilterPopup,"btn_close")
        db:setVisible(true)
        close:setVisible(true)
        --CSResourceMgr.getNodeByName(resNameFilterPopup,"btn_close"):setVisible(true)
        CocosModuleMgr.showUIAnimation(db,"down")
        CocosModuleMgr.showUIAnimation(close,"down")
        
    end
    
    loadCSB()
    playCSB()
end


---------------------------------我是分割线------------------------------------
--类函数

function LifeSkillFilterPopUp.reset()
    LifeSkillFilterPopUp.lasttype = -1
    LifeSkillFilterPopUp.lastid = -1
end
function LifeSkillFilterPopUp.Init()
    resNameFilterPopup = "Player/LifeSkill/LifeSkillFilterPop.csb" 
    LifeSkillFilterPopUp.reset()
end
function LifeSkillFilterPopUp.show(scene,type)
    addUI(scene,type)
end

function LifeSkillFilterPopUp.hide()
    
    hideUI()
    
end
return LifeSkillFilterPopUp