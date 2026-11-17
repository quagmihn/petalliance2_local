--vesion number 1.0
--@client side LifeSkillLstViewMgr.lua
--[[
这个文件是生活技能列表界面
--]]
--script writer Leon Lee
--creation time 2016-3-16

local LifeSkillLstViewMgr = {}
local useunblockloader = true
--翻译
local trans_lifeskill = "lifeSkill001" --"生活技能"
local trans_currjob = "lifeSkill002"--"当前职业：" 
local trans_szs = "lifeSkill003"--"时装师" 
local trans_jjs = "lifeSkill004"--"家具师"
local trans_zhs = "lifeSkill005"--"装潢师"
local trans_skilllv = "lifeSkill006"--"技能等级："
local trans_needskilllv = "lifeSkill007" --"需求技能等级"
local trans_needitem = "lifeSkill008"--"所需材料"
local trans_make = "lifeSkill009"--"制 造"
local trans_changejob = "lifeSkill010"--"切换职业"
local trans_changejob1 =  "lifeSkill011"--"这是你第"
local trans_changejob2 =  "lifeSkill012"--"次切换职业"
local trans_noselitem = "lifeSkill013"--"当前未选中任何打造物品"
local trans_nomakingpic = "lifeSkill053"--"该物品的图纸未激活"

local trans_error_nochoice = "lifeSkill014" --"请选择图纸"
local trans_error_nomoney = "lifeSkill015"--"金钱不足"
local trans_error_noitems =  "lifeSkill016"--"材料不足"
local trans_error_lverror = "lifeSkill017"--"技能等级过低"
local trans_error_careerwrong = "lifeSkill018" --"职业不匹配"
local trans_error_cantbuydrawing = "无法购买"
local trans_sucess_make = "lifeSkill019" --"恭喜，制造成功"
local trans_error_bagfull = "lifeSkill052"
local trans_alreadyhave = "lifeSkill061"--可激活
local trans_jihuotuzhi= "lifeSkill062"--点击下方激活按钮激活此图纸
local trans_goumai = "lifeSkill063"
local trans_wutuzhi = "lifeSkill064"
local trans_activesucce = "lifeSkill065"
local trans_batchmake = "lifeSkill066"

---------------------------------我是分割线------------------------------------

--数据层
local drawingInfo={
    [1] ={},
    [2] ={},
    [3] ={},
}

local lifeSkillInfo = {} --玩家的生活技能新
local drawingInBags = {} --背包内的图纸
local filterDataList = {} --当前列表的数据
local listTable = {}
local btnBottomState = {state=0,condtion=false,needcash = 0,makeid = 0,needlv = 0,index = 0} --底部按钮的切换状态 state-0制造 state-1切换职业state-2购买图纸 condtion-表示是否符合条件,needcash-现金数量,makeid-制造物品的id,needlv-制造物品的等级
local EnumDrawingMakingState = { --元素的制造状态
    MakingStateNoLevel = 0,--等级不够
    MakingStateNoPic = 1,--无图纸
    MakingStateReady = 2,--准备就绪
}

local bottomStartPos = 323 --底部的中心位置
local currentFirstListIndex = 1

local spawncount = 8
local spacing = 5
local countperline = 1
local bufferZone = 120
local lislistcellHeight = 110

local qianliInfo = 
{
    qianliLV = 0,
    qianliSkillInfo = nil
}

--初始化玩家职业信息
local function initLifeSkillInfo()
    local cjson = require("cjson")
    local data = CharInfo.getLifeSkillInfo()
    print("initLifeSkillInfo data........"..data)
    lifeSkillInfo = cjson.decode(data)
    
    lifeSkillInfo.level = lifeSkillInfo.level or 1
    lifeSkillInfo.exp = lifeSkillInfo.exp or 0
    if lifeSkillInfo.changeTimes == nil then 
        lifeSkillInfo.changeTimes = 1 
    else
        lifeSkillInfo.changeTimes = lifeSkillInfo.changeTimes+1
    end
    TaskWatcherManager.onLifeSkillLVChange(lifeSkillInfo.level)
end

local itemIdRewardsPairs={}
--取数据的函数
--初始化合成配方表
--    {itemid = 1,itemname="小y的内裤",itemdesc="从小霞房间偷取的内裤啊啊啊从小霞房间偷取的内裤啊啊啊小霞房间偷取的内裤",item_icon = "xxx",needlv=1,costs={},exp},
local function initDrawingInfo()
	drawingInfo[1] = {}
	drawingInfo[2] = {}
	drawingInfo[3] = {}
	
    local drawingInfoVec = ItemInfo.getDrawingInfoAllId()
    local data
    for i = 1,#drawingInfoVec do
        data = drawingInfoVec[i]
        local itemdata={};
        itemdata.itemid = data.id
        itemdata.itemname = data.name
        itemdata.itemdesc = data.description
        itemdata.itemicon = data.itemID
        itemdata.needlv =  data.level
        itemdata.costs = data.costs
        itemdata.exp = data.exp
        itemdata.drawingtype = data.drawingType
        itemdata.currencyType = data.currencyType
        itemdata.price = data.price
        --print("data.drawingType:"..data.drawingType)
        itemdata.awards = data.awards
        table.insert(drawingInfo[data.career],itemdata)
        itemIdRewardsPairs[itemdata.itemicon] = data.awards
    end
    
end

local function refreshData()

    initLifeSkillInfo()
end



---获得玩家的职业ID
local function getPlayerJobId()
    return tonumber(lifeSkillInfo.career)
end

---获得玩家的职业
local function getPlayerJobName()
    --此处应该是各种逻辑，获得玩家的职业
    local careerId = tonumber(lifeSkillInfo.career)
    if careerId == 1 then
        return trans_szs
    end
    
    if careerId == 2 then
        return trans_jjs
    end
    
    if careerId == 3 then
    
        return trans_zhs
    end

end

---获得玩家的职业等级
--@param jobType int 职业类型
local function getPlayerJobLv(jobType)
    --此处应该是各种逻辑取职业等级
    jobType = jobType or 1

    local level = lifeSkillInfo.level or 1
    return "Lv "..level
end


local function getPlayerExpAndAllExp(jobType)
    jobType = jobType or 1
    local lastexp = 0
    local exp = lifeSkillInfo.exp or 0
    
    local allexp = ExperienceInfo.getLifeSkillExpInfoByID(lifeSkillInfo.level+1)
    local lastexp = ExperienceInfo.getLifeSkillExpInfoByID(lifeSkillInfo.level)
    if lastexp == nil then 
        lastexp = 0 
    else
        lastexp = lastexp.exp  
    end
    
    
    if allexp==nil then
        allexp = ExperienceInfo.getLifeSkillExpInfoByID(lifeSkillInfo.level)
    end
    print("level,exp,lastexp,allexp"..lifeSkillInfo.level,exp,lastexp,allexp.exp)
    return exp-lastexp,allexp.exp-lastexp
end

---获得玩家职业经验
--@param jobType int 职业类型
local function getPlayerJobExp(jobType)
--此处应该是各种逻辑获取职业经验
    jobType = jobType or 1
    
    local exp,allexp = getPlayerExpAndAllExp(jobType)
   
    return exp.."/"..allexp
end



---获得当前显示的道具名称
local function getCurItemName()
--此处应该是获得逻辑
--此处应该经过翻译
    return "道具名称"
end

---获得当前显示的道具描述
local function getCurItemDesc()
    --此处应该是获得逻辑
    --此处应该经过翻译
    return "道具描述 道具描述..................."
end

---获取当前资源的道具数量
local function getCurItemNum()
    --此处应该是获得逻辑
    return "99"
end


---获取当前资源的所需道具数量
local function getCurItemAllNum()
    --此处应该是获得逻辑
    return "999"
end

---获得当前底部按钮的名字
local function getCurBottomBtnName()
--此处应该是获得逻辑
    return trans_make
end
---------------------------------我是分割线------------------------------------

--ui初始化信息
local resNameLifeSkillLst =  "" --列表UI资源
local resNameBg = ""--背景UI资源
local resNameTop = "" --头部通用框
local resNameSkill = "" --潜力技能界面
local isTxtInited = false


local tabTextArray={trans_szs,trans_jjs,trans_zhs}
local fontInfo = {--该界面所有的文本格式信息，用于界面设置
    txt_title ={
        have_selstate = false, --是否有选中态
        outline_width = 2,
        font_color = {r =144,g=238,b=255,a=255},
        outline_color = {r =38,g=54,b=76,a=255},
        text = trans_lifeskill
    },
    
    txt_jobtitle={
        have_selstate = false, --是否有选中态
        outline_width = 1,
        font_color = {r =144,g=238,b=255,a=255},          
        outline_color = {r =0,g=0,b=0,a=255},   
        text = trans_currjob 
    },
    
    txt_job={
        have_selstate = false, --是否有选中态
        outline_width = 1,
        font_color = {r =255,g=252,b=0,a=255},          
        outline_color = {r =0,g=0,b=0,a=255},   
        text = "function"
    },
    
    txt_skilllv={
       have_selstate = false, --是否有选中态
       outline_width = 1, 
       font_color = {r =144,g=238,b=255,a=255},  
       outline_color = {r =0,g=0,b=0,a=255},    
       text = trans_skilllv                     
    },
    
    txt_lvnum={
        have_selstate = false, --是否有选中态
        outline_width = 1, 
        font_color = {r =255,g=252,b=0,a=255},  
        outline_color = {r =0,g=0,b=0,a=255},    
        text = "function"                     
    },
    
    txt_exp={
        have_selstate = false, --是否有选中态
        outline_width = 1, 
        font_color = {r =255,g=255,b=255,a=255},  
        outline_color = {r =0,g=0,b=0,a=255},    
        text = "function"                 
    },
    
    btn_tab1={
        have_selstate = true, --是否有选中态
        outline_width = 2, 
        font_color = {r =227,g=233,b=255,a=255},  --默认未选中
        outline_color = {r =10,g=22,b=65,a=255},     --默认未选中
        font_color_sel = {r =255,g=243,b=227,a=255},--选中  
        outline_color_sel = {r =89,g=47,b=5,a=255}, --选中   
        text = trans_szs                     
    },
    

    btn_tab2={
        have_selstate = true, --是否有选中态
        outline_width = 2, 
        font_color = {r =227,g=233,b=255,a=255},  --默认未选中
        outline_color = {r =10,g=22,b=65,a=255},     --默认未选中
        font_color_sel = {r =255,g=243,b=227,a=255},--选中  
        outline_color_sel = {r =89,g=47,b=5,a=255}, --选中      
        text = trans_jjs                   
    },
    

    btn_tab3={
        have_selstate = true, --是否有选中态
        outline_width = 2, 
        font_color = {r =227,g=233,b=255,a=255},  --默认未选中
        outline_color = {r =10,g=22,b=65,a=255},     --默认未选中
        font_color_sel = {r =255,g=243,b=227,a=255},--选中  
        outline_color_sel = {r =89,g=47,b=5,a=255}, --选中     
        text = trans_zhs                    
    },
    
    txt_icontitle={
        have_selstate = true, --是否有选中态
        outline_width = nil, 
        font_color = {r =255,g=240,b=0,a=255},  --默认未选中
        outline_color = {r =0,g=0,b=0,a=255,w=1,s=1},     --默认未选中
        font_color_sel = {r =255,g=240,b=0,a=255},--选中  
        outline_color_sel = {r =0,g=0,b=0,a=255,w=1,s=1}, --选中     
        text = getCurItemName()      
    },
    
    txt_listskilllv={
        have_selstate = true, --是否有选中态
        outline_width = nil, 
        font_color = {r =255,g=255,b=255,a=255},  --默认未选中
        outline_color = {r =65,g=91,b=112,a=255,w=1},     --默认未选中
        font_color_sel = {r =255,g=255,b=255,a=255},--选中  
        outline_color_sel = {r =65,g=91,b=112,a=255,w =1 }, --选中     
        text = trans_needskilllv      
    },
    
    txt_listlvnum={
        have_selstate = true, --是否有选中态
        outline_width = 1, 
        font_color = {r =255,g=255,b=255,a=255},  --默认足够
        outline_color = {r =0,g=0,b=0,a=255},     --默认足够
        font_color_sel = {r =247,g=125,b=71,a=255},  --默认足够
        outline_color_sel = {r =0,g=0,b=0,a=255},     --默认足够
        text = "nodata"      
    },

    
    txt_itemdesc={
        have_selstate = true, --是否有选中态
        outline_width = nil, 
        font_color = {r =71,g=96,b=103,a=255},  --默认未选中
        outline_color = {r =5,g=48,b=84,a=255},     --默认未选中
        font_color_sel = {r =135,g=91,b=7,a=255},--选中  
        outline_color_sel = {r =160,g=86,b=5,a=255}, --选中     
        text = getCurItemDesc()      
    },
    
    txt_bottomtab ={
        have_selstate = false, --是否有选中态
        outline_width = 1, 
        font_color = {r =144,g=238,b=255,a=255},  
        outline_color = {r =0,g=0,b=0,a=255,w=nil,s=1},    
        text = trans_needitem  
    },
    
    txt_itemnum1 ={
        have_selstate = true, --此处表示道具数量不够
        outline_width = 1, 
        font_color = {r =255,g=255,b=255,a=255},  --数量充足
        outline_color = {r =0,g=0,b=0,a=255}, --数量充足
        font_color_sel = {r =255,g=72,b=0,a=255},--数量不够
        outline_color_sel = {r =0,g=0,b=0,a=255}, --数量不够    
        text = getCurItemNum() 
    },
    
    txt_itemnum3 ={
        have_selstate = true, --此处表示道具数量不够
        outline_width = 1, 
        font_color = {r =255,g=255,b=255,a=255},  --数量充足
        outline_color = {r =0,g=0,b=0,a=255}, --数量充足
        font_color_sel = {r=147,g=254,b=6,a=255},
        outline_color_sel = {r =0,g=0,b=0,a=255},
        text = getCurItemAllNum()
    },
    
    txt_changejob1 = {
        have_selstate = false,
        outline_width = nil, 
        font_color = {r =195,g=235,b=255,a=255},
        outline_color = {r =0,g=0,b=0,a=255},
        text =  trans_changejob1         
    },
    
    txt_changejob2 = {
        have_selstate = false,
        outline_width = nil, 
        font_color = {r =195,g=235,b=255,a=255},
        outline_color = {r =0,g=0,b=0,a=255},
        text =  trans_changejob2        
    },
    
    txt_changejobnum = {
        have_selstate = false,
        outline_width = nil, 
        font_color = {r =244,g=241,b=0,a=255},
        outline_color = {r =0,g=0,b=0,a=255},
        text =  trans_changejob2        
    },
    
    btn_bottom = {
        have_selstate = false, 
        outline_width = 2, 
        font_color = {r =255,g=255,b=255,a=255},  
        outline_color = {r =0,g=0,b=0,a=255}, 
        text =getCurBottomBtnName()   
    
    },
    
    txt_btnbottom = {
        have_selstate = false, 
        outline_width = 1, 
        font_color = {r =255,g=255,b=255,a=255},  
        outline_color = {r =0,g=0,b=0,a=255,w=1,s=1}, 
        text =getCurBottomBtnName()     
    },
    
    txt_nochoic = {
        have_selstate = false,
        outline_width = nil, 
        font_color = {r =227,g=233,b=255,a=255},
        outline_color = {r =0,g=0,b=0,a=255},
        text =  trans_noselitem        
    },
    
}

local bgImageColorInfo = { --背景图片颜色切换信息
    pic_listtitlebg = {
        have_selstate = true,
        color_default = {r=67,g=85,b=100,a=255},
        color_sel = {r=181,g=122,b=9,a=255},     
    },
    
    pic_lvnumbg = {
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

--UI数据
local currentTab = 1 -- 1、时装  2、家具 3、装潢
local currentFilterStr = nil
local listCellTable = {
    [1] = {},
    [2] = {},
    [3] = {},

} --list 表的集合

local tabCellTable ={} --tab页元素的合集
local tabOriginY = 0;--tab页的原始位置
---设置label的字体
local function setLabel(label,string,outline,outlinewidth,textColor,maxwidth)

 
    CSResourceMgr.setLabelColorByNode(label,textColor)

    
    
    CSResourceMgr.setLabelStringByNode(label,string,nil)
    if outlinewidth~=nil  then
        --label:enableOutline(outline, outlinewidth)
        CSResourceMgr.setLabelStringByNode(label,string,outline,nil,nil)
    else
        CSResourceMgr.setLabelStringByNode(label,string,nil,nil,nil)
    end
    
    --[[
    if outline.s==1 then
        label:enableShadow()
    end
    ]]
    if maxwidth~=nil then
        CSResourceMgr.setLabelMaxWidthByNode(label,maxwidth)
    end
    
end


--[[这些只是测试数据
local testDataTableLst1 ={
    {itemid = 1,itemname="小y的内裤",itemdesc="从小霞房间偷取的内裤啊啊啊从小霞房间偷取的内裤啊啊啊小霞房间偷取的内裤",item_icon = "xxx",needlv=1},
    {itemid = 1,itemname="小x内裤",itemdesc="从小霞房间偷取的内裤啊啊啊从小霞房间偷取的内裤啊啊啊小霞房间偷取的内裤",item_icon = "xxx",needlv=2},
    {itemid = 1,itemname="小z的内裤",itemdesc="从小霞房间偷取的内裤啊啊啊从小霞房间偷取的内裤啊啊啊小霞房间偷取的内裤",item_icon = "xxx",needlv=3},    
    {itemid = 1,itemname="小5的内裤",itemdesc="从小霞房间偷取的内裤啊啊啊从小霞房间偷取的内裤啊啊啊小霞房间偷取的内裤",item_icon = "xxx",needlv=3},     
    }
    
local testDataTableLst2 ={
    {itemid = 1,itemname="小y的内衣",itemdesc="从小霞房间偷取的内裤啊啊啊从小霞房间偷取的内裤啊啊啊小霞房间偷取的内裤",item_icon = "xxx",needlv=1},
    {itemid = 1,itemname="小x内衣",itemdesc="从小霞房间偷取的内裤啊啊啊从小霞房间偷取的内裤啊啊啊小霞房间偷取的内裤",item_icon = "xxx",needlv=2},
    {itemid = 1,itemname="小z的内衣",itemdesc="从小霞房间偷取的内裤啊啊啊从小霞房间偷取的内裤啊啊啊小霞房间偷取的内裤",item_icon = "xxx",needlv=3},    
    {itemid = 1,itemname="小5的内衣",itemdesc="从小霞房间偷取的内裤啊啊啊从小霞房间偷取的内裤啊啊啊小霞房间偷取的内裤",item_icon = "xxx",needlv=3},     
}

local testDataTableLst3 ={
    {itemid = 1,itemname="小y的内衣",itemdesc="从小霞房间偷取的内裤啊啊啊从小霞房间偷取的内裤啊啊啊小霞房间偷取的内裤",item_icon = "xxx",needlv=1},
    {itemid = 1,itemname="小x的袜子",itemdesc="从小霞房间偷取的内裤啊啊啊从小霞房间偷取的内裤啊啊啊小霞房间偷取的内裤",item_icon = "xxx",needlv=2},
    {itemid = 1,itemname="小z的袜子",itemdesc="从小霞房间偷取的内裤啊啊啊从小霞房间偷取的内裤啊啊啊小霞房间偷取的内裤",item_icon = "xxx",needlv=3},    
    {itemid = 1,itemname="小5的袜子",itemdesc="从小霞房间偷取的内裤啊啊啊从小霞房间偷取的内裤啊啊啊小霞房间偷取的内裤",item_icon = "xxx",needlv=3},     
}
]]

--UI操作
--[[
consume type
"金币" : "1",
"钻石" : "2",
"道具" : "3",
"角色经验" : "4",
"宠物" : "5",
"强化点数" : "6",
"升星点数" : "7",
"洗练石" : "8",

]]
local function createDrawingIconByConsumeId(id)
    local consume = ItemInfo.getConsumeElementInfoById(id)
    local itype = consume.elementType
    
    
    if itype~= 3 and itype~=1 and itype~=2 then
        StandardTipsMgr.show(1,"wrong type:"..type)
        return nil    
    end

    local iteminfo = nil

    
    local myItemNum = 0 
    print("itype................................."..itype) 
    if itype == 3 then 
        local itemnum = ItemInfo.getCharItemNum(consume.elementID) 
        if itemnum~=nil then   
            if type(itemnum) ~="number" then
                myItemNum = ItemInfo.getFurnitureNumByID(consume.elementID)
            else 
                myItemNum = itemnum
            end
        else
            --myItemNum = ItemInfo.getFurnitureNumByID(consume.elementID)
        end

    end
    if itype == 1 then myItemNum = CharInfo.getGCash() end
    if itype == 2 then myItemNum = CharInfo.getMCash() end
    
    local needItemNum = consume.num
    local itemBuff = false --是否有道具减少buff
    if itype == 1 or itype == 2 then
        btnBottomState.needcash = needItemNum
    else
        iteminfo = ItemInfo.getItemInfoById(consume.elementID)
         btnBottomState.needcash = 0
         if qianliInfo.qianliSkillInfo~=nil and iteminfo.id == 162 then 
            itemBuff = true
            needItemNum = needItemNum - qianliInfo.qianliSkillInfo.params[1]
            if needItemNum <= 0 then 
                needItemNum = 1 
            end
         end
    end
    
    --插入条件设置
    local itemEnough = true
    
    if needItemNum <= myItemNum then --足够
        itemEnough = true
    else
        itemEnough = false       
    end

    local iconnode = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"btn_icon"):clone()
    --开始设置文字
    local myItemtxt = CSResourceMgr.seekNodeByName(iconnode,"txt_itemnum1")
    local neddItemtxt = CSResourceMgr.seekNodeByName(iconnode,"txt_itemnum3")
    
    if itype == 3 then --如果是道具的话,就下面那样显示
        local showNumStr = 0
        if myItemNum > 999 then 
            showNumStr = "999+" 
        else
            showNumStr = tostring(myItemNum)
        end
        
        if myItemNum < needItemNum then
            setLabel(myItemtxt,showNumStr,fontInfo.txt_itemnum1.outline_color_sel,fontInfo.txt_itemnum1.outline_width,fontInfo.txt_itemnum1.font_color_sel)
        else
            setLabel(myItemtxt,showNumStr,fontInfo.txt_itemnum1.outline_color,fontInfo.txt_itemnum1.outline_width,fontInfo.txt_itemnum1.font_color)        
        end
    
        if itemBuff then
        
            setLabel(neddItemtxt,tostring(needItemNum),fontInfo.txt_itemnum3.outline_color_sel,fontInfo.txt_itemnum3.outline_width,fontInfo.txt_itemnum3.font_color_sel)  
            local arrowicon =  CSResourceMgr.seekNodeByName(iconnode,"pic_arrowicon")
            arrowicon:setVisible(true)
        else
            setLabel(neddItemtxt,tostring(needItemNum),fontInfo.txt_itemnum3.outline_color,fontInfo.txt_itemnum3.outline_width,fontInfo.txt_itemnum3.font_color)  
        end
        
    else --如果是钱的话,设空
        setLabel(myItemtxt,"",fontInfo.txt_itemnum1.outline_color_sel,fontInfo.txt_itemnum1.outline_width,fontInfo.txt_itemnum1.font_color_sel)
        setLabel(neddItemtxt,"",fontInfo.txt_itemnum3.outline_color,fontInfo.txt_itemnum3.outline_width,fontInfo.txt_itemnum3.font_color) 
        local neddItemtxt2 = CSResourceMgr.seekNodeByName(iconnode,"txt_itemnum2")
        setLabel(neddItemtxt2,tostring(needItemNum),fontInfo.txt_itemnum3.outline_color,fontInfo.txt_itemnum3.outline_width,fontInfo.txt_itemnum3.font_color)   
    end
     


    local itemicon = nil
    local dibanicon = nil
    
    if itype == 3 then
       
        if iteminfo.icon == nil then
            StandardTipsMgr.show(1,"no this item icon:" ..itype,consume.elementID)
            return nil
        end  
        itemicon = iteminfo.icon
        
        dibanicon = ItemInfo.getItemRareBGImage(consume.elementID)
    end

    if itype == 1 then
        iteminfo = ItemInfo.getItemInfoById(9998)
        if iteminfo.icon == nil then
            StandardTipsMgr.show(1,"no this item icon:" ..itype,consume.elementID)
            return nil
        end  
        itemicon = iteminfo.icon
        dibanicon = ItemInfo.getItemRareBGImage(9998)
    end

    if itype == 2 then
        iteminfo = ItemInfo.getItemInfoById(9999)
        if iteminfo.icon == nil then
            StandardTipsMgr.show(1,"no this item icon:" ..itype,consume.elementID)
            return nil
        end 
        itemicon = iteminfo.icon  
        dibanicon = ItemInfo.getItemRareBGImage(9999)      
    end

    local iconpic =  CSResourceMgr.seekNodeByName(iconnode,"pic_itemicon")
    CSResourceMgr.setButtonTextureByNode(iconnode,dibanicon,dibanicon,dibanicon)
    
    CSResourceMgr.clickEventBindingByNode(iconnode,function()
        local itemDescViewMgr = require("src.GameMgr.Item.ItemInfoViewMgr")
        print("iteminfo........................."..iteminfo.id)
        itemDescViewMgr.show(iteminfo,false)
    end,true) 
    iconpic:loadTexture(itemicon)

    return iconnode,itemEnough
end


---显示合成需要消耗的材料
local function showDrawingCosts(costs)
    print("costs num........................" ..#costs)
    local nochoictxt = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"txt_nochoic") 
    if costs == nil then
        nochoictxt:setVisible(true)
    else 
        nochoictxt:setVisible(false) 
        local startpos =bottomStartPos
        startpos = startpos-(#costs-1)*47*1.5/1.2
        local bottombg = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"pic_bottombg2")
        bottombg:removeAllChildren()
        local isItemEnough = true
        for i=1,#costs do
            print("costs..................."..costs[i])
            local iconitem,itemEnough = createDrawingIconByConsumeId(costs[i])
            if iconitem~=nil then
                bottombg:addChild(iconitem)
                iconitem:setPosition(startpos+(i-1)*47*3/1.2, 52)            
            end
            
            if itemEnough == false then
                isItemEnough = false
            end
        end
        
        btnBottomState.condtion = isItemEnough
     
    end
end

---显示最底部的button按钮
--@param tabindex int 当前切换的序号
--@param listcell cellnode 选中的列表元素
--@param isshowjob bool 是否显示职业
local function showBottomButton(tabindex,isshowjob,buttonstr)
    isshowjob = isshowjob or 1
    local middlebtn_pos = {x=287,y=-40}
    local leftbtn_pos = {x=152,y=-40}
    local rightbtn_pos = {x=423,y=-40}
    local middletxt_pos = {x=286,y=-40}
    local lefttxt_pos = {x=151,y=-40}
    local righttxt_pos = {x=423,y= -40}
    local bottomBtn = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"btn_bottom")
    local bottomtxt = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"txt_btnbottom")

    --make
    local bottomBtn_1 = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"btn_bottom_1")   
    local bottomtxt_1 = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"txt_btnbottom_1")

    --batch make
    local bottomBtn_2 = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"btn_bottom_2")   
    local bottomtxt_2 = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"txt_btnbottom_2")

    if tabindex~= lifeSkillInfo.career and isshowjob == 1 then --不是当前职业，显示切换
        buttonstr = buttonstr or trans_changejob
        bottomBtn_1:setVisible(false)
        bottomtxt_1:setVisible(false)

        bottomBtn_2:setVisible(false)
        bottomtxt_2:setVisible(false)

        bottomBtn:setPosition(middlebtn_pos)
        bottomtxt:setPosition(middletxt_pos)
        setLabel(bottomtxt,buttonstr,fontInfo.txt_btnbottom.outline_color,fontInfo.txt_btnbottom.outline_width,fontInfo.txt_btnbottom.font_color)
        btnBottomState.state = 1 
        btnBottomState.condtion = false
    else
        buttonstr = buttonstr or trans_make
        --CSResourceMgr.setButtonStringByNode(bottomBtn,buttonstr,fontInfo.btn_bottom.ouline_color)
        setLabel(bottomtxt,buttonstr,fontInfo.txt_btnbottom.outline_color,fontInfo.txt_btnbottom.outline_width,fontInfo.txt_btnbottom.font_color)
        btnBottomState.state = 0 
        btnBottomState.condtion = false

        bottomBtn_1:setVisible(false)
        bottomtxt_1:setVisible(false)

        bottomBtn:setPosition(leftbtn_pos)
        bottomtxt:setPosition(lefttxt_pos)

        bottomBtn_2:setVisible(true)
        bottomtxt_2:setVisible(true)

        setLabel(bottomtxt_2,trans_batchmake,fontInfo.txt_btnbottom.outline_color,fontInfo.txt_btnbottom.outline_width,fontInfo.txt_btnbottom.font_color)
    end
    
    if buttonstr == trans_goumai then

        buttonstr = buttonstr or trans_changejob
        bottomBtn_1:setVisible(false)
        bottomtxt_1:setVisible(false)

        bottomBtn_2:setVisible(false)
        bottomtxt_2:setVisible(false)

        bottomBtn:setPosition(middlebtn_pos)
        bottomtxt:setPosition(middletxt_pos)
        setLabel(bottomtxt,buttonstr,fontInfo.txt_btnbottom.outline_color,fontInfo.txt_btnbottom.outline_width,fontInfo.txt_btnbottom.font_color)
        btnBottomState.state = 2  
    end
    
end

---底部UI布局切换
--@param tabindex int 当前切换的tab序号
--@param listcell cellnode 选中的列表元素
--@param costs table 合成消耗材料的集合
--@param bool  isshowjob 是否显示职业
local function showBottom(tabindex,listcell,costs,isshowjob)
    isshowjob = isshowjob or 1
    --print("isshowjob..........."..isshowjob)
    showBottomButton(tabindex,isshowjob)
    local changejob1txt = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"txt_changejob1")
    local changejob2txt = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"txt_changejob2")
    local changejobnum = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"txt_changejobnum")
    local bottomtab = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"txt_bottomtab")
    
    
    if tabindex~= lifeSkillInfo.career and  isshowjob == 1 then --非本职业

        setLabel(changejob1txt,fontInfo.txt_changejob1.text,fontInfo.txt_changejob1.outline_color,fontInfo.txt_changejob1.outline_width,fontInfo.txt_changejob1.font_color)
        setLabel(changejob2txt,fontInfo.txt_changejob2.text,fontInfo.txt_changejob2.outline_color,fontInfo.txt_changejob1.outline_width,fontInfo.txt_changejob2.font_color)
       -- setLabel(changejobnum,tostring(lifeSkillInfo.changeTimes+1),fontInfo.txt_changejobnum.outline_color,fontInfo.txt_changejobnum.outline_width,fontInfo.txt_changejobnum.font_color)
        setLabel(changejobnum,tostring(lifeSkillInfo.changeTimes),fontInfo.txt_changejobnum.outline_color,fontInfo.txt_changejobnum.outline_width,fontInfo.txt_changejobnum.font_color)
        --print("change job txt:",fontInfo.txt_changejob1.text,fontInfo.txt_changejob2.text,tostring(lifeSkillInfo.changeTimes))
        changejob1txt:setVisible(true)
        changejob2txt:setVisible(true)
        changejobnum:setVisible(true)
        bottomtab:setVisible(false)
        --local info = ExperienceInfo.getLifeSkillCareerChangeByID(lifeSkillInfo.changeTimes+1)
        local info = ExperienceInfo.getLifeSkillCareerChangeByID(lifeSkillInfo.changeTimes)
        if info~= nil then
            local coststable = {info.elemID}  
            showDrawingCosts(coststable)
        else
            local info = ExperienceInfo.getLifeSkillCareerChangeByID(10)    
            local coststable = {info.elemID}  
            showDrawingCosts(coststable)        
        end
    else
        
        changejob1txt:setVisible(false)
        changejob2txt:setVisible(false)
        changejobnum:setVisible(false)  
        bottomtab:setVisible(true)
        local curlist = nil 
        local list1 = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"list1") 
        local list2 = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"list2") 
        local list3 = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"list3") 
        
        if currentTab == 1 then end
            curlist = list1
        if currentTab == 2 then end
            curlist = list2
        if currentTab == 3 then end
            curlist = list3
        
     

        if listcell~= nil and costs~=nil then
            showDrawingCosts(costs)
            
        else
           
           if curlist.selid > 0 then --有选中
                showDrawingCosts(filterDataList[curlist.selid].costs)

           else --没有,显示还没有选中
                local bottombg = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"pic_bottombg2")
                bottombg:removeAllChildren()
                local nochoictxt = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"txt_nochoic") 
                setLabel(nochoictxt,fontInfo.txt_nochoic.text,fontInfo.txt_nochoic.outline_color,fontInfo.txt_nochoic.outline_width,fontInfo.txt_nochoic.font_color)
                nochoictxt:setVisible(true)
           end
        end      
    end
end


---根据传入的数据创建列表
--@param data table {itemid = id,itemname="xxx",itemdesc="xxx",item_icon = "xxx",needlv=12}
local function createListCell(data,item)
    local listcell = nil
    if item == nil then
        listcell = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"btn_listexample"):clone()
    else
        listcell = item
	end

    if data == nil then 
        return listcell
    end
    local listtitlebg = CSResourceMgr.seekNodeByName(listcell,"pic_listtitlebg")
    listtitlebg:setColor(bgImageColorInfo.pic_listtitlebg.color_default)
    
    local lvnumbg = CSResourceMgr.seekNodeByName(listcell,"pic_lvnumbg")
    lvnumbg:setColor(bgImageColorInfo.pic_lvnumbg.color_default)
    

    local listiconbg = CSResourceMgr.seekNodeByName(listcell,"pic_listiconbg")
    listiconbg:setColor(bgImageColorInfo.pic_listiconbg.color_default)
    
    local icontitle = CSResourceMgr.seekNodeByName(listcell,"txt_icontitle")
    setLabel(icontitle,data.itemname,fontInfo.txt_icontitle.outline_color,fontInfo.txt_icontitle.outline_width,fontInfo.txt_icontitle.font_color)
    
    local itemdesc = CSResourceMgr.seekNodeByName(listcell,"txt_itemdesc")
    setLabel(itemdesc,data.itemdesc,fontInfo.txt_itemdesc.outline_color,fontInfo.txt_itemdesc.outline_width,fontInfo.txt_itemdesc.font_color,455)
    
    local txtskilllv = CSResourceMgr.seekNodeByName(listcell,"txt_listskilllv")
    

    setLabel(txtskilllv,fontInfo.txt_listskilllv.text,fontInfo.txt_listskilllv.outline_color,fontInfo.txt_listskilllv.outline_width,fontInfo.txt_listskilllv.font_color)

    local skilllvnum = CSResourceMgr.seekNodeByName(listcell,"txt_listlvnum")
    
    local picIcon = CSResourceMgr.seekNodeByName(listcell,"pic_icon")
    --print("data.itemicon"..data.itemicon)
    local iteminfo = ItemInfo.getItemInfoById(data.itemicon)
    local icon = iteminfo.icon
    picIcon:loadTexture(icon)
    
  
    local listicon = CSResourceMgr.seekNodeByName(listcell, "btn_listicon")


       
    CSResourceMgr.buttonEventBindingByNode(listicon, function ()
                     local rewardid = itemIdRewardsPairs[data.itemicon]
                    local rewardinfo = AdventureInfo.getRewardInfoByID(tonumber(rewardid[1]))
                    local awardinfo = ItemInfo.getAwardElementInfoById(rewardinfo.element[1])
                    local awardid = 0

                    if awardinfo.elementType == 1 or awardinfo.elementType == 2  then
                        awardid = awardinfo.elementType
                    else
                        awardid = awardinfo.elementID
                    end
                    ItemInfoViewMgr.show({id = awardid,rewardid =itemIdRewardsPairs[data.itemicon] }, false)
                    --print("iteminfoviewmgr awards.........",data.itemicon,itemIdRewardsPairs[data.itemicon])
                end, function ()
                    --ItemInfoViewMgr.hide()
                end, function ()
                end, function ()
                    --ItemInfoViewMgr.hide()
                end, true)
    --print("texture tererwsrwt "..data.itemid)
    local texture = ItemInfo.getItemRareBGImage(data.itemicon)
    
    CSResourceMgr.setButtonTextureByNode(listicon,texture,texture,texture)
    
    local iconlock = CSResourceMgr.seekNodeByName(listcell,"pic_iconlock")
    iconlock:setVisible(false)
    local function isInDrawingPics(id) --判断是否拥有该图纸
         if lifeSkillInfo.drawings == nil then
            return false
            
         else
         
            for i = 1,#lifeSkillInfo.drawings do
                if tonumber(lifeSkillInfo.drawings[i]) == tonumber(id) then
                        return true
                end
            end
         end
         
         return false
    end
    
    local function isHaveDrawingPics(id) --判断背包里是否拥有该图纸
        if #drawingInBags == 0 then
            return false
        else
           for i = 1,#drawingInBags do
            --print("..............",drawingInBags[i].id,tonumber(id))
                if tonumber(drawingInBags[i].id) == tonumber(id) then
                    return true
                end
           end 
        end
        
        return false
    end
    
    if data.needlv <= lifeSkillInfo.level then
    
        local ret = isInDrawingPics(data.itemid)
        if ret == true then
            listcell.makingstate = EnumDrawingMakingState.MakingStateReady 
            picIcon:setColor({r=255,g=255,b=255}) 
        else
            listcell.makingstate = EnumDrawingMakingState.MakingStateNoPic 
            picIcon:setColor({r=77,g=77,b=77})   
            if isHaveDrawingPics(data.itemicon) then
                local str1 = LuaSqlite.getLanguageByKey(data.itemname)
                local str2 = LuaSqlite.getLanguageByKey(trans_alreadyhave)
                setLabel(icontitle,str1..str2,fontInfo.txt_icontitle.outline_color,fontInfo.txt_icontitle.outline_width,fontInfo.txt_icontitle.font_color)
            end
        end
        setLabel(skilllvnum,data.needlv,fontInfo.txt_listlvnum.outline_color,fontInfo.txt_listlvnum.outline_width,fontInfo.txt_listlvnum.font_color)
        
    else
        local ret = isInDrawingPics(data.itemid)
        if ret == true then
            listcell.makingstate = EnumDrawingMakingState.MakingStateNoLevel
            picIcon:setColor({r=255,g=255,b=255})
        else
            listcell.makingstate = EnumDrawingMakingState.MakingStateNoPic 
            if isHaveDrawingPics(data.itemicon) then
                local str = LuaSqlite.getLanguageByKey(data.itemname)
                setLabel(icontitle,str..trans_alreadyhave,fontInfo.txt_icontitle.outline_color,fontInfo.txt_icontitle.outline_width,fontInfo.txt_icontitle.font_color)
            end
            picIcon:setColor({r=77,g=77,b=77})
        end
        --picIcon:setColor({r=77,g=77,b=77})
        setLabel(skilllvnum,data.needlv,fontInfo.txt_listlvnum.outline_color_sel,fontInfo.txt_listlvnum.outline_width,fontInfo.txt_listlvnum.font_color_sel)        
    end
 
  
    --local lock_icon = CSResourceMgr.seekNodeByName(listcell,"pic_iconlock")
    --lock_icon:setVisible(false)
    
    return listcell
    

    
end

---改变Tab的样式
--@param tabindex  要设置样式的tab页签号
--@param beSel bool 是否选中状态
local function changeTabStyleByIndex(tabindex,beSel)
    local strcolor
    local stroutline
    if beSel then --如果被选中
        if tabindex == 1 then  
            strcolor = fontInfo.btn_tab1.font_color_sel
            stroutline = fontInfo.btn_tab1.outline_color_sel
            
        end
        
        if tabindex == 2 then  
            strcolor = fontInfo.btn_tab2.font_color_sel
            stroutline = fontInfo.btn_tab2.outline_color_sel
        end
        
    
        if tabindex == 3 then  
            strcolor = fontInfo.btn_tab3.font_color_sel
            stroutline = fontInfo.btn_tab3.outline_color_sel
        end
        
        tabCellTable[tabindex]:setPositionY(tabOriginY+6)
    else
        if tabindex == 1 then  
            strcolor = fontInfo.btn_tab1.font_color
            stroutline = fontInfo.btn_tab1.outline_color
        end

        if tabindex == 2 then  
            strcolor = fontInfo.btn_tab2.font_color
            stroutline = fontInfo.btn_tab2.outline_color
        end

        if tabindex == 3 then  
            strcolor = fontInfo.btn_tab3.font_color
            stroutline = fontInfo.btn_tab3.outline_color
            
        end    
        
        tabCellTable[tabindex]:setPositionY(tabOriginY)
    end
    
    CSResourceMgr.setButtonStringByNode(tabCellTable[tabindex],tabTextArray[tabindex],stroutline)
    CSResourceMgr.setButtonStringColorByNode(tabCellTable[tabindex],strcolor)

end

---改变listcell元素的样式
--@param listcell node list行的节点
--@param beSel bool 是否是选中态
local function changeListCellStyle(listcell,beSel)  
    beSel = beSel or false
    if beSel == true then --选中态
        CSResourceMgr.setButtonEnabledByNode(listcell,false)
        
        local listtitlebg = CSResourceMgr.seekNodeByName(listcell,"pic_listtitlebg")
        listtitlebg:setColor(bgImageColorInfo.pic_listtitlebg.color_sel)
        
        local lvnumbg = CSResourceMgr.seekNodeByName(listcell,"pic_lvnumbg")
        lvnumbg:setColor(bgImageColorInfo.pic_lvnumbg.color_sel)  
        
        local listiconbg = CSResourceMgr.seekNodeByName(listcell,"pic_listiconbg")
        listiconbg:setColor(bgImageColorInfo.pic_listiconbg.color_sel)    
        
        local icontitle = CSResourceMgr.seekNodeByName(listcell,"txt_icontitle")
        CSResourceMgr.setLabelColorByNode(icontitle,fontInfo.txt_icontitle.font_color_sel)
        
        local itemdesc = CSResourceMgr.seekNodeByName(listcell,"txt_itemdesc")
        CSResourceMgr.setLabelColorByNode(itemdesc,fontInfo.txt_itemdesc.font_color_sel) 
        
        local txtskilllv = CSResourceMgr.seekNodeByName(listcell,"txt_listskilllv")       
        CSResourceMgr.setLabelColorByNode(txtskilllv,fontInfo.txt_listskilllv.font_color_sel) 
               
    else --非选中态
        CSResourceMgr.setButtonEnabledByNode(listcell,true)

        local listtitlebg = CSResourceMgr.seekNodeByName(listcell,"pic_listtitlebg")
        listtitlebg:setColor(bgImageColorInfo.pic_listtitlebg.color_default)

        local lvnumbg = CSResourceMgr.seekNodeByName(listcell,"pic_lvnumbg")
        lvnumbg:setColor(bgImageColorInfo.pic_lvnumbg.color_default)      
        
        local listiconbg = CSResourceMgr.seekNodeByName(listcell,"pic_listiconbg")
        listiconbg:setColor(bgImageColorInfo.pic_listiconbg.color_default)  

        local icontitle = CSResourceMgr.seekNodeByName(listcell,"txt_icontitle")
        CSResourceMgr.setLabelColorByNode(icontitle,fontInfo.txt_icontitle.font_color)

        local itemdesc = CSResourceMgr.seekNodeByName(listcell,"txt_itemdesc")
        CSResourceMgr.setLabelColorByNode(itemdesc,fontInfo.txt_itemdesc.font_color) 

        local txtskilllv = CSResourceMgr.seekNodeByName(listcell,"txt_listskilllv")       
        CSResourceMgr.setLabelColorByNode(txtskilllv,fontInfo.txt_listskilllv.font_color)    
    end
end



---切换页签的tab的UI相关
--@param tabindex int 切换的页签编号
local function onTabChangeUI(tabindex)
    --重置当前的列表
    
    local bottomBtn = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"btn_bottom")
    CSResourceMgr.setButtonEnabledByNode(bottomBtn,true)
    
    local list1 = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"list1") 
    local list2 = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"list2") 
    local list3 = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"list3") 
    
    
    local oldList;
    if tabindex == 1 then oldList = list1 end
    if tabindex == 2 then oldList = list2 end
    if tabindex == 3 then oldList = list3 end
    
    
    if oldList.selid>0 then --有选中，重置样式 
        changeListCellStyle(listCellTable[currentTab][oldList.selid],false) 
        oldList.selid = 0
    end
    
    currentTab = tabindex
    if currentTab == 1 then 
        CSResourceMgr.setButtonEnabledByNode(tabCellTable[currentTab],false) 
        CSResourceMgr.setButtonEnabledByNode(tabCellTable[2],true)
        CSResourceMgr.setButtonEnabledByNode(tabCellTable[3],true)  
        changeTabStyleByIndex(currentTab,true)
        changeTabStyleByIndex(2,false)
        changeTabStyleByIndex(3,false)
        list1:setVisible(true)
        list2:setVisible(false)
        list3:setVisible(false)
        
    end

    if currentTab == 2 then 
        CSResourceMgr.setButtonEnabledByNode(tabCellTable[currentTab],false) 
        CSResourceMgr.setButtonEnabledByNode(tabCellTable[1],true)
        CSResourceMgr.setButtonEnabledByNode(tabCellTable[3],true)  
        changeTabStyleByIndex(currentTab,true)
        changeTabStyleByIndex(1,false)
        changeTabStyleByIndex(3,false)
        list2:setVisible(true)
        list1:setVisible(false)
        list3:setVisible(false)
    end

    if currentTab == 3 then 
        CSResourceMgr.setButtonEnabledByNode(tabCellTable[currentTab],false) 
        CSResourceMgr.setButtonEnabledByNode(tabCellTable[1],true)
        CSResourceMgr.setButtonEnabledByNode(tabCellTable[2],true)  
        changeTabStyleByIndex(currentTab,true)
        changeTabStyleByIndex(1,false)
        changeTabStyleByIndex(2,false)
        
        list3:setVisible(true)
        list1:setVisible(false)
        list2:setVisible(false)
    end  
    
    showBottom(currentTab)
      
end


---重置List表
--@param dataList tablelst datalist数据表集合data table {itemname="xxx",itemdesc="xxx",item_icon = "xxx",needlv=12}
--@param curTab int 当前的Tab页
local function resetListCellTable(dataList,curTab,filterstr)

    
    local function showActivateDrawingMoneyOnBottom(type,num) --显示激活图纸需要的价格

		print("showActivateDrawingMoneyOnBottom:type,num::"..type,num)
        local needmoneynum = 0
        local startpos = bottomStartPos
        local itemicon = nil
        local dibanicon = nil
        local iteminfo = nil
        local itemid = 9999
        local changejob1txt = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"txt_changejob1")
        local changejob2txt = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"txt_changejob2")
        local changejobnum = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"txt_changejobnum")
        local bottomtab = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"txt_bottomtab")
        changejob1txt:setVisible(false)
        changejob2txt:setVisible(false)
        changejobnum:setVisible(false)
        bottomtab:setVisible(true)
        --setLabel(changejob1txt,trans_goumai,fontInfo.txt_changejob1.outline_color,fontInfo.txt_changejob1.outline_width,fontInfo.txt_changejob1.font_color)
        --setLabel(changejob2txt,"",fontInfo.txt_changejob2.outline_color,fontInfo.txt_changejob1.outline_width,fontInfo.txt_changejob2.font_color)
        --setLabel(changejobnum,"",fontInfo.txt_changejobnum.outline_color,fontInfo.txt_changejobnum.outline_width,fontInfo.txt_changejobnum.font_color)
        if type == Proto.AET_GCASH	then --金币
            needmoneynum = CharInfo.getGCash()
			itemid = 9998
		end
		
		if type == Proto.AET_MCASH	then --M币
			needmoneynum =  CharInfo.getMCash()
			itemid = 9999
		end
		
		if type == Proto.AET_GOLDCOIN then --银币
			needmoneynum = CharInfo.getSilverCash()
			itemid = 9996
		end
		
		if type == Proto.AET_NONE then --不能购买
            local bottomBtn = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"btn_bottom")
            CSResourceMgr.setButtonEnabledByNode(bottomBtn,false)
			return nil
		else
            local bottomBtn = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"btn_bottom")
            CSResourceMgr.setButtonEnabledByNode(bottomBtn,true)
            showBottomButton(curTab,nil,trans_goumai)
			local iconnode = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"btn_icon"):clone()
			local myItemtxt = CSResourceMgr.seekNodeByName(iconnode,"txt_itemnum1")
			local neddItemtxt = CSResourceMgr.seekNodeByName(iconnode,"txt_itemnum3")
			setLabel(myItemtxt,"",fontInfo.txt_itemnum1.outline_color_sel,fontInfo.txt_itemnum1.outline_width,fontInfo.txt_itemnum1.font_color_sel)
			setLabel(neddItemtxt,"",fontInfo.txt_itemnum3.outline_color,fontInfo.txt_itemnum3.outline_width,fontInfo.txt_itemnum3.font_color) 
			local neddItemtxt2 = CSResourceMgr.seekNodeByName(iconnode,"txt_itemnum2")
            setLabel(neddItemtxt2,tostring(num),fontInfo.txt_itemnum3.outline_color,fontInfo.txt_itemnum3.outline_width,fontInfo.txt_itemnum3.font_color)  
      
			iteminfo = ItemInfo.getItemInfoById(itemid)
			if iteminfo.icon == nil then
				StandardTipsMgr.show(1,"no this item icon:" ..type,consume.elementID)
				return nil
			end  
			itemicon = iteminfo.icon
			dibanicon = ItemInfo.getItemRareBGImage(itemid)
			local iconpic =  CSResourceMgr.seekNodeByName(iconnode,"pic_itemicon")
			CSResourceMgr.setButtonTextureByNode(iconnode,dibanicon,dibanicon,dibanicon)
            iconpic:loadTexture(itemicon)
            --iconnode:setPosition(startpos,45)
			return iconnode
		end
		
    end
    
    
    local function setDataInfoForUnActivateDrawing(i) --设置未激活图纸的信息
        local bottombg = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"pic_bottombg2")
        bottombg:removeAllChildren()
        local icnode = showActivateDrawingMoneyOnBottom(filterDataList[i].currencyType,filterDataList[i].price)
        local startpos = bottomStartPos
        if icnode~= nil then
            bottombg:addChild(icnode)
            icnode:setPosition(startpos, 52)  
            local nochoictxt = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"txt_nochoic") 
            setLabel(nochoictxt,"",fontInfo.txt_nochoic.outline_color,fontInfo.txt_nochoic.outline_width,fontInfo.txt_nochoic.font_color)
        
                
        else
        
            local nochoictxt = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"txt_nochoic") 
            setLabel(nochoictxt,trans_wutuzhi,fontInfo.txt_nochoic.outline_color,fontInfo.txt_nochoic.outline_width,fontInfo.txt_nochoic.font_color)
            nochoictxt:setVisible(true)
        
        end

    end
    
    currentFilterStr = filterstr
    local list1 = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"list1") 
    local list2 = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"list2") 
    local list3 = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"list3") 
    list1.selid = 0
    list2.selid = 0
    list3.selid = 0
    if curTab == 1 then  list1:removeAllItems() end
    if curTab == 2 then  list2:removeAllItems() end
    if curTab == 3 then  list3:removeAllItems() end
    
    listCellTable[curTab] = {}
    local funcTable = {}
    UnblockLoader.cancel("LifeSkillLstViewMgr.loadlist"..curTab)

    
  --  HighPerformList.makeHighPerFormVerticalList(list1,spawnCount,spacing,countPerLine,bufferZone,listcellHeight,datalist,callback)
    filterDataList = {}
    if filterstr~=nil then
        for i = 1,#dataList do
            if dataList[i].drawingtype == filterstr then
                table.insert(filterDataList,dataList[i])
            end       
        end
    else
        filterDataList = dataList
    end
    
    listTable = {list1,list2,list3}
    local cnt = #filterDataList
    if cnt > spawncount then
        cnt = spawncount
    end
    for i =1,cnt do--#dataList do  
		local function showListCell()
            local listCell = createListCell(filterDataList[i])
			table.insert(listCellTable[curTab],listCell)
			listCell:setScaleY(0)
			--if curTab == 1 then 
			if filterstr ==nil then
                listTable[curTab]:pushBackCustomItem(listCell)
			else
                print("compare......."..filterDataList[i].drawingtype,filterstr)
                if filterDataList[i].drawingtype == filterstr then
                    listTable[curTab]:pushBackCustomItem(listCell)
				end
			end 
   
			CSResourceMgr.clickEventBindingByNode(listCell,function()  
				
                    if listTable[curTab].selid ~= i then
				
                        if listTable[curTab].selid ~= 0 then 
                            changeListCellStyle(listCellTable[curTab][listTable[curTab].selid],false) 
					end
					changeListCellStyle(listCellTable[curTab][i],true)
				end
                    listTable[curTab].selid = i --当前选中的内容
				--showDrawingCosts(drawingInfo[curTab][i].costs)
	 

                    btnBottomState.makeid = filterDataList[i].itemid
                    btnBottomState.needlv = filterDataList[i].needlv
                    btnBottomState.iconid = filterDataList[i].itemicon
				btnBottomState.index = i
                if listCell.makingstate == EnumDrawingMakingState.MakingStateNoPic then
                    if curTab == lifeSkillInfo.career then 
                        local bottomBtn = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"btn_bottom")
                        CSResourceMgr.setButtonEnabledByNode(bottomBtn,false)
                        --showBottomButton(curTab,listCell,nil,trans_goumai)
                    end
                    setDataInfoForUnActivateDrawing(i) 

                else
                    showBottom(curTab,listCell,filterDataList[i].costs,0)
                    if btnBottomState.condition == false then
                        local bottomBtn = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"btn_bottom")
                        CSResourceMgr.setButtonEnabledByNode(bottomBtn,false)   
                    else
                        local bottomBtn = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"btn_bottom")
                        CSResourceMgr.setButtonEnabledByNode(bottomBtn,true)                         
                    end
				   
				end
			end)
			-- end
			
			--[[
			if curTab == 2 then 
				if filterstr ==nil then
					list2:pushBackCustomItem(listCell)
				else
                    print("compare......."..filterDataList[i].drawingtype,filterstr)
                    if filterDataList[i].drawingtype == filterstr then
						list2:pushBackCustomItem(listCell)
					end
				end 
				CSResourceMgr.clickEventBindingByNode(listCell,function()  
				
					if list2.selid ~= i then
						if list2.selid ~= 0 then 
							changeListCellStyle(listCellTable[curTab][list2.selid],false) 
						end
						changeListCellStyle(listCellTable[curTab][i],true)
					end
					list2.selid = i --当前选中的内容
					btnBottomState.makeid = drawingInfo[2][i].itemid
					btnBottomState.needlv = drawingInfo[2][i].needlv
					--showDrawingCosts(drawingInfo[curTab][i].costs)
					btnBottomState.index = i
                    if listCell.makingstate == EnumDrawingMakingState.MakingStateNoPic then
                    
                        if curTab == lifeSkillInfo.career then 
                            local bottomBtn = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"btn_bottom")
                            CSResourceMgr.setButtonEnabledByNode(bottomBtn,false)
                        end
                         setDataInfoForUnActivateDrawing(i) 

                    else
                        showBottom(curTab,listCell,drawingInfo[curTab][i].costs,0)
                        if btnBottomState.condition == false then
                            local bottomBtn = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"btn_bottom")
                            CSResourceMgr.setButtonEnabledByNode(bottomBtn,false)   
                        else
                            local bottomBtn = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"btn_bottom")
                            CSResourceMgr.setButtonEnabledByNode(bottomBtn,true)                         
                        end
                    end
					--showBottom(curTab,listCell,drawingInfo[curTab][i].costs,0)
				end) 
			end
			
			if curTab == 3 then 
				if filterstr ==nil then
					list3:pushBackCustomItem(listCell)
				else
                    print("compare......."..filterDataList[i].drawingtype,filterstr)
                    if filterDataList[i].drawingtype == filterstr then
						list3:pushBackCustomItem(listCell)
					end
				end 
				CSResourceMgr.clickEventBindingByNode(listCell,function()  
					if list3.selid ~= i then
						if list3.selid ~= 0 then 
							changeListCellStyle(listCellTable[curTab][list3.selid],false) 
						end
						changeListCellStyle(listCellTable[curTab][i],true)
					end
					list3.selid = i --当前选中的内容
					btnBottomState.makeid = drawingInfo[3][i].itemid
					btnBottomState.needlv = drawingInfo[3][i].needlv
					--showDrawingCosts(drawingInfo[curTab][i].costs)
					btnBottomState.index = i
					
                    if listCell.makingstate == EnumDrawingMakingState.MakingStateNoPic then
                        if curTab == lifeSkillInfo.career then 
                            local bottomBtn = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"btn_bottom")
                            CSResourceMgr.setButtonEnabledByNode(bottomBtn,false)
                        end
                        setDataInfoForUnActivateDrawing(i) 
                    else
                        showBottom(curTab,listCell,drawingInfo[curTab][i].costs,0)
                        if btnBottomState.condition == false then
                            local bottomBtn = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"btn_bottom")
                            CSResourceMgr.setButtonEnabledByNode(bottomBtn,false)   
                        else
                            local bottomBtn = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"btn_bottom")
                            CSResourceMgr.setButtonEnabledByNode(bottomBtn,true)                         
                        end
                    end
					--showBottom(curTab,listCell,drawingInfo[curTab][i].costs,0)
				end) 
			end	
			]]
			transition.scaleTo(listCell,{scale=1.0,time=0.2})
		end
		
		--showListCell()

		table.insert(funcTable,showListCell)
    end
    
    local function makeHightPerformList()
       -- HighPerformList.resetHighPerFormList(list1)
        --HighPerformList.resetHighPerFormList(list2)
       -- HighPerformList.resetHighPerFormList(list3)
       currentFirstListIndex = 1
       
        HighPerformList.makeHighPerFormVerticalList(listTable[curTab],spawncount,spacing,countperline,bufferZone,lislistcellHeight,filterDataList,
            function(item,currentindex)
                if currentindex >currentFirstListIndex then
                    currentFirstListIndex = currentindex - spawncount+1
                else
                    currentFirstListIndex = currentindex
                end
                if currentFirstListIndex <0 then currentFirstListIndex = 1 end
                local listcell = createListCell(filterDataList[currentindex],item)
                listCellTable[curTab][currentindex] = listcell
                if listTable[curTab].selid ~= currentindex then
                    changeListCellStyle(listcell,false)
                else
                    changeListCellStyle(listcell,true)
                end
                
                CSResourceMgr.clickEventBindingByNode(listcell,function()  
                    
                    if listTable[curTab].selid ~= currentindex then
                        if listTable[curTab].selid ~= 0 then 
                            changeListCellStyle(listCellTable[curTab][listTable[curTab].selid],false) 
                        end
                        changeListCellStyle(listCellTable[curTab][currentindex],true)
                    end
                    listTable[curTab].selid = currentindex --当前选中的内容
                        btnBottomState.makeid = filterDataList[currentindex].itemid
                        btnBottomState.needlv = filterDataList[currentindex].needlv
                        btnBottomState.iconid = filterDataList[currentindex].itemicon
                    --showDrawingCosts(drawingInfo[curTab][i].costs)
                    btnBottomState.index = currentindex

                    if listcell.makingstate == EnumDrawingMakingState.MakingStateNoPic then
                        if curTab == lifeSkillInfo.career then 
                            local bottomBtn = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"btn_bottom")
                            CSResourceMgr.setButtonEnabledByNode(bottomBtn,false)
                        end
                        setDataInfoForUnActivateDrawing(currentindex) 
                    else
                            showBottom(curTab,listcell,filterDataList[currentindex].costs,0)
                        if btnBottomState.condition == false then
                            local bottomBtn = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"btn_bottom")
                            CSResourceMgr.setButtonEnabledByNode(bottomBtn,false)   
                        else
                            local bottomBtn = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"btn_bottom")
                            CSResourceMgr.setButtonEnabledByNode(bottomBtn,true)                         
                        end
                    end
                    --showBottom(curTab,listCell,drawingInfo[curTab][i].costs,0)
                end) 
            end
        )
  

    end
    
    table.insert(funcTable,makeHightPerformList)


	UnblockLoader.load(funcTable,"LifeSkillLstViewMgr.loadlist"..curTab)
    
end

---重置Tab列表
local function resetTabCellTable()
    tabCellTable = {}
    local tab1 = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"btn_tab1") 
    local tab2 = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"btn_tab2") 
    local tab3 = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"btn_tab3")


    table.insert(tabCellTable,tab1)
    table.insert(tabCellTable,tab2)
    table.insert(tabCellTable,tab3)

    CSResourceMgr.clickEventBindingByNode(tab1,function() GameAudio.playUISound("sheetClick") resetListCellTable(drawingInfo[1],1) onTabChangeUI(1)  end)
    CSResourceMgr.clickEventBindingByNode(tab2,function() GameAudio.playUISound("sheetClick") resetListCellTable(drawingInfo[2],2) onTabChangeUI(2)  end)
    CSResourceMgr.clickEventBindingByNode(tab3,function() GameAudio.playUISound("sheetClick") resetListCellTable(drawingInfo[3],3) onTabChangeUI(3)  end)

    onTabChangeUI(currentTab)
end

---获取背包的图纸
-- getDrawingInBags
local function getDrawingInBags()
    drawingInBags = {}
    local bagItemInfo = ItemInfo.getCharItemInfo()
    for key, var in pairs(bagItemInfo) do
        local iteminfo = ItemInfo.getItemInfoById(key)
        local itemtype = iteminfo.itemType
        if itemtype == Proto.IC_DRAWING then
      
            table.insert(drawingInBags,iteminfo)
        end
    end
end

---show exp
local function showExp()

    local exp,allexp = getPlayerExpAndAllExp()
    local expfront = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"pic_expfront")
    expfront:setScaleX(exp/allexp)
end

local function initQianliSkillInfo()
    local skillUpInfo,num = AchievementListMgr.getSkillUpInfo("forge")
    
    qianliInfo.qianliLV = num
    qianliInfo.qianliSkillInfo = skillUpInfo

   
--    CSResourceMgr.createRes(SceneMgr.getRunningScene,resNameSkill)      
--    local skillBtn = CSResourceMgr.getNodeByName(resNameSkill, "skillBtn"):clone()


--    [[
--    local skillLv = CSResourceMgr.seekNodeByName(skillBtn, "skillLv")
--    CSResourceMgr.setLabelColorByNode(skillLv, {r=255,g=255,b=255,a=255})
--    CSResourceMgr.setLabelStringByNode(skillLv, "Lv"..num, {r=0,g=0,b=0,a=255})
--    ]]

    local node1 = CSResourceMgr.getNodeByName(resNameLifeSkillLst, "pic_node1")
    --node1:setLocalZOrder(10)
    if qianliInfo.qianliSkillInfo~=nil then
        local icon = CSResourceMgr.seekNodeByName(node1, "pic_icon")
        local iconRes = "Battle/skillIcon/"..skillUpInfo.icon
        --print("iconRes........"..iconRes)
        icon:setScale(0.5)
        CSResourceMgr.setSpriteTextureByNode(icon, iconRes)
        
        CSResourceMgr.clickEventBindingByNode(node1, function()
            AchievementListMgr.showSkillInfo(qianliInfo.qianliSkillInfo,false,false,nil)
        end)
    
        local skillLv = CSResourceMgr.seekNodeByName(node1, "txt_qllv")
        CSResourceMgr.setLabelColorByNode(skillLv, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(skillLv, "Lv"..num, {r=0,g=0,b=0,a=255})
   else
        node1:setVisible(false) 
   end
end

---初始化UI基础数据
local function initUIBaseData()
   
    local tab1 = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"btn_tab1") 
    tabOriginY = tab1:getPositionY()  
    
    local title = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"txt_title") 
    setLabel(title,fontInfo.txt_title.text,fontInfo.txt_title.outline_color,fontInfo.txt_title.outline_width,fontInfo.txt_title.font_color)
    
    local jobtitle = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"txt_jobtitle") 
    setLabel(jobtitle,fontInfo.txt_jobtitle.text,fontInfo.txt_jobtitle.outline_color,fontInfo.txt_jobtitle.outline_width,fontInfo.txt_jobtitle.font_color)
    
    local job = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"txt_job") 
    setLabel(job,getPlayerJobName(),fontInfo.txt_job.outline_color,fontInfo.txt_job.outline_width,fontInfo.txt_job.font_color)

    --阿杜修改英文版显示
    if LuaSqlite.LANG_TYPE ~= 1 then
        jobtitle:setFontSize(30)
        jobtitle:setPositionX(130)
        job:setPositionX(127)
    end
    if LuaSqlite.LANG_TYPE == 6 then	--印尼版
        jobtitle:setVisible(false)
        job:setPositionX(50)
		job:setFontSize(job:getFontSize()-5)
	end	
	
	if LuaSqlite.LANG_TYPE == 5 then	--泰文版
        jobtitle:setVisible(false)
        job:setPositionX(50)
    end
	
    local skilllv = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"txt_skilllv") 
    setLabel(skilllv,fontInfo.txt_skilllv.text,fontInfo.txt_skilllv.outline_color,fontInfo.txt_skilllv.outline_width,fontInfo.txt_skilllv.font_color)
    
    local lvnum = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"txt_lvnum") 
    setLabel(lvnum,getPlayerJobLv(),fontInfo.txt_lvnum.outline_color,fontInfo.txt_lvnum.outline_width,fontInfo.txt_lvnum.font_color)
    
    local exp = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"txt_exp") 
    setLabel(exp,getPlayerJobExp(),fontInfo.txt_exp.outline_color,fontInfo.txt_exp.outline_width,fontInfo.txt_exp.font_color)
    
    local bottomtabtext = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"txt_bottomtab") 
    setLabel(bottomtabtext,fontInfo.txt_bottomtab.text,fontInfo.txt_bottomtab.outline_color,fontInfo.txt_bottomtab.outline_width,fontInfo.txt_bottomtab.font_color)
    
    local nochoictxt = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"txt_nochoic") 
    setLabel(nochoictxt,fontInfo.txt_nochoic.text,fontInfo.txt_nochoic.outline_color,fontInfo.txt_nochoic.outline_width,fontInfo.txt_nochoic.font_color)
    --getDrawingInBags()
    showExp()
    initQianliSkillInfo()
end

local function updateCashNum()

    local silverCash = CharInfo.getSilverCash()
    if silverCash == nil then silverCash = 0 end
    CSResourceMgr.setLabelString(resNameTop, "hpoint", silverCash, "", nil, -1)
    CSResourceMgr.setLabelString(resNameTop, "gcoin", CharInfo.getGCash(), "", nil, -1)
    CSResourceMgr.setLabelString(resNameTop, "mcoin", CharInfo.getMCash(), "", nil, -1)
end

local function refreshTopUIData()
    local job = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"txt_job") 
    setLabel(job,getPlayerJobName(),fontInfo.txt_job.outline_color,fontInfo.txt_job.outline_width,fontInfo.txt_job.font_color)


    local lvnum = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"txt_lvnum") 
    setLabel(lvnum,getPlayerJobLv(),fontInfo.txt_lvnum.outline_color,fontInfo.txt_lvnum.outline_width,fontInfo.txt_lvnum.font_color)

    local exp = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"txt_exp") 
    setLabel(exp,getPlayerJobExp(),fontInfo.txt_exp.outline_color,fontInfo.txt_exp.outline_width,fontInfo.txt_exp.font_color)
    
    showExp()
    
end
--刷新
local function refreshUIData()
    if not CSResourceMgr.getCsbObj(resNameLifeSkillLst) then return end
    refreshData()
    refreshTopUIData()
    print("updateCashNum..........")
    updateCashNum()
    
    local list1 = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"list1") 
    local list2 = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"list2") 
    local list3 = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"list3") 
    resetListCellTable(drawingInfo[currentTab],currentTab,currentFilterStr)
    --[[
    if list1.selid > 0 then changeListCellStyle(listCellTable[1][list1.selid ],false) end
    if list2.selid > 0 then changeListCellStyle(listCellTable[2][list2.selid ],false) end
    if list3.selid > 0 then changeListCellStyle(listCellTable[3][list3.selid ],false) end

    list1.selid = 0
    list2.selid = 0
    list3.seldid = 0

    showBottom(currentTab)
    ]]
end

--刷新等级限制
local function refreshNeedLv()
    --for i = 1,#listCellTable[currentTab] do
    for i = currentFirstListIndex,currentFirstListIndex+spawncount-1 do
        local listcell = listCellTable[currentTab][i]
        print("currentFirstListIndex & i is:"..currentFirstListIndex,i)
        local data = filterDataList[i]
        local skilllvnum = CSResourceMgr.seekNodeByName(listcell,"txt_listlvnum")
        local picIcon = CSResourceMgr.seekNodeByName(listcell,"pic_icon")
       -- print("data.needlv,lifeSkillInfo.level"..data.needlv,lifeSkillInfo.level,picIcon)
        if data.needlv <= lifeSkillInfo.level then
            --picIcon:setColor({r=255,g=255,b=255})   
            setLabel(skilllvnum,data.needlv,fontInfo.txt_listlvnum.outline_color,fontInfo.txt_listlvnum.outline_width,fontInfo.txt_listlvnum.font_color)

        else
            --picIcon:setColor({r=77,g=77,b=77})
            setLabel(skilllvnum,data.needlv,fontInfo.txt_listlvnum.outline_color_sel,fontInfo.txt_listlvnum.outline_width,fontInfo.txt_listlvnum.font_color_sel)        

        end  
    end

end

local function hideTopInfoBar()
    local node = CSResourceMgr.getNodeByName(resNameTop, "up")
    
    if node then
        GameAudio.playUISound("retract")
        transition.moveBy(node, {y=79, time=0.1})
        node:setVisible(false)
        CSResourceMgr.removeCSObjectByTag(resNameTop)
        
    end
end

---关闭UI
local function  hideUI()

    UnblockLoader.cancel("LifeskillLstMgr.show")
	UnblockLoader.cancel("LifeSkillLstViewMgr.loadlist1")
    UnblockLoader.cancel("LifeSkillLstViewMgr.loadlist2")
    UnblockLoader.cancel("LifeSkillLstViewMgr.loadlist3")
    local list1 = listTable[1]
    if list1 then
        list1:removeAllItems()
        --HighPerformList.resetHighPerFormList(list1)
    end
    
    local list2 = listTable[2] 
    if list2 then
        list2:removeAllItems()
        --HighPerformList.resetHighPerFormList(list2)
    end
    
    local list3 = listTable[3]
    if list3 then
        list3:removeAllItems()
        --HighPerformList.resetHighPerFormList(list3)
    end

    HighPerformList.resetAllSchedule()
    CSResourceMgr.removeCSObjectByTag(resNameLifeSkillLst)
    CSResourceMgr.removeCSObjectByTag(resNameBg,"LifeSkillLstBg")
    --CSResourceMgr.removeCSObjectByTag(resNameSkill)
    hideTopInfoBar()
    SceneMgr.setMapVisible(true)
    LifeSkillFilterPopUp.reset()
    currentFirstListIndex = 1
end

--根据屏幕适配尺寸
local function resize()
    local diff = CocosModuleMgr.getScreenSizeDiff()
    local frame = CSResourceMgr.getNodeByName(resNameLifeSkillLst, "frame")
    local fsize = frame:getContentSize()
    frame:setContentSize(fsize.width, fsize.height+diff)

--[[
    local diban = CSResourceMgr.getNodeByName(resNameLifeSkillLst, "panel_diwen")
    local dbsize = diban:getContentSize()
    diban:setContentSize(dbsize.width, dbsize.height+diff)

    local listbg1 = CSResourceMgr.getNodeByName(resNameLifeSkillLst, "pic_listbg1")
    dbsize = listbg1:getContentSize()
    listbg1:setContentSize(dbsize.width, dbsize.height+diff)
    
    local listbg2 = CSResourceMgr.getNodeByName(resNameLifeSkillLst, "pic_listbg2")
    dbsize = listbg2:getContentSize()
    listbg2:setContentSize(dbsize.width, dbsize.height+diff)
    ]]
    local list1 = CSResourceMgr.getNodeByName(resNameLifeSkillLst, "list1")
    dbsize = list1:getContentSize()
    list1:setContentSize(dbsize.width, dbsize.height+diff)

    local list2 = CSResourceMgr.getNodeByName(resNameLifeSkillLst, "list2")
    dbsize = list2:getContentSize()
    list2:setContentSize(dbsize.width, dbsize.height+diff)


    local list3 = CSResourceMgr.getNodeByName(resNameLifeSkillLst, "list3")
    dbsize = list3:getContentSize()
    list3:setContentSize(dbsize.width, dbsize.height+diff)

    local line = CSResourceMgr.getNodeByName(resNameLifeSkillLst, "line")
    local tposy = line:getPositionY()
    line:setPositionY(tposy+diff)
    
    local lvbg1 = CSResourceMgr.getNodeByName(resNameLifeSkillLst, "pic_lvbg1")
    local tposy = lvbg1:getPositionY()
    lvbg1:setPositionY(tposy+diff)    
    
    local skilllv = CSResourceMgr.getNodeByName(resNameLifeSkillLst, "txt_skilllv")
    local tposy = skilllv:getPositionY()
    skilllv:setPositionY(tposy+diff)  
    
    local lvnum = CSResourceMgr.getNodeByName(resNameLifeSkillLst, "txt_lvnum")
    local tposy = lvnum:getPositionY()
    lvnum:setPositionY(tposy+diff)  
    
    local cposy = 0
    --[[
    local close = CSResourceMgr.getNodeByName(resNameLifeSkillLst, "close")
    local cposy = close:getPositionY()
    close:setPositionY(cposy+diff)
]]
    local title = CSResourceMgr.getNodeByName(resNameLifeSkillLst, "txt_title")
    local tposy = title:getPositionY()
    title:setPositionY(tposy+diff)
    --[[
    local close = CSResourceMgr.getNodeByName(resNameLifeSkillLst, "close")
    local cposy = close:getPositionY()
    close:setPositionY(cposy+diff)
]]
    local titlebg = CSResourceMgr.getNodeByName(resNameLifeSkillLst, "pic_titlebg")
    cposy = titlebg:getPositionY()
    titlebg:setPositionY(cposy+diff)

    local jobtitle = CSResourceMgr.getNodeByName(resNameLifeSkillLst, "txt_jobtitle")
    cposy = jobtitle:getPositionY()
    jobtitle:setPositionY(cposy+diff)

    local job = CSResourceMgr.getNodeByName(resNameLifeSkillLst, "txt_job")
    cposy = job:getPositionY()
    job:setPositionY(cposy+diff)

    local expfront = CSResourceMgr.getNodeByName(resNameLifeSkillLst, "pic_expfront")
    cposy = expfront:getPositionY()
    expfront:setPositionY(cposy+diff)
    
    local expbase = CSResourceMgr.getNodeByName(resNameLifeSkillLst, "pic_expbase")
    cposy = expbase:getPositionY()
    expbase:setPositionY(cposy+diff)
    
    local exp = CSResourceMgr.getNodeByName(resNameLifeSkillLst, "txt_exp")
    cposy = exp:getPositionY()
    exp:setPositionY(cposy+diff)  
    local x,y = exp:getPosition() 
    print("exp:x,y:"..x,y)
    
    local node1 = CSResourceMgr.getNodeByName(resNameLifeSkillLst, "pic_node1")
    cposy = node1:getPositionY()
    node1:setPositionY(cposy+diff) 
    local x,y = node1:getPosition() 
    print("node1:x,y:"..x,y)


    local tabposY = 0
    for var=1, 3 do
        local tabbtn = CSResourceMgr.getNodeByName(resNameLifeSkillLst, "btn_tab"..var)
        local tabposy = tabbtn:getPositionY()
        tabbtn:setPositionY(tabposy+diff)
        tabposY = tabposy+diff
    end

end

local function showTopInfoBar(callback)
    callback = callback or function() end
    local node = CSResourceMgr.getNodeByName(resNameTop, "up")
    if node then
        node:setVisible(true)
        transition.moveBy(node, {y=-79, time=0.2})
        CSResourceMgr.clickEventBinding(resNameTop, "close", function()
            callback()
        end)
    end
end



local function addUI(scene)
    if CSResourceMgr.getCsbObj(resNameLifeSkillLst) then
        return
    end
    
    local bgUI = CSResourceMgr.createRes(scene,resNameBg ,"LifeSkillLstBg")
    local csbUI = CSResourceMgr.createRes(scene,resNameLifeSkillLst)
    local function loadBG()

        bgUI:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBg, 320, 480,"LifeSkillLstBg")
    end
    

    
    local function loadCSB()
    
        local top = CSResourceMgr.createRes(scene, resNameTop)
        top:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CocosModuleMgr.setEdgeDistance(top, 0, nil, 0, nil)
        local silverCash = CharInfo.getSilverCash()
        --print("silvercash"..silverCash)
        if silverCash == nil then silverCash = 0 end
        CSResourceMgr.setLabelString(resNameTop, "hpoint", silverCash, "", nil, -1)
        CSResourceMgr.setLabelString(resNameTop, "gcoin", CharInfo.getGCash(), "", nil, -1)
        CSResourceMgr.setLabelString(resNameTop, "mcoin", CharInfo.getMCash(), "", nil, -1)
        CSResourceMgr.setLabelColor(resNameTop, "hpoint", {r=190,g=221,b=245,a=255})
        CSResourceMgr.setLabelColor(resNameTop, "gcoin", {r=190,g=221,b=245,a=255})
        CSResourceMgr.setLabelColor(resNameTop, "mcoin", {r=190,g=221,b=245,a=255})
        csbUI:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        csbUI:setVisible(false)
        --CSResourceMgr.setFullScreen(resNameLifeSkillLst)
        --CSResourceMgr.setRelativePosition(resNameLifeSkillLst, 320, 480)   
        --CocosModuleMgr.setEdgeDistance(csbUI,nil,nil,nil,0)
        
      
        resize()
        
        
        
        initLifeSkillInfo()
        initUIBaseData()
 
        --print("currentTab........."..currentTab)
        --resetListCellTable(drawingInfo[currentTab],currentTab)
        --resetListCellTable(drawingInfo[2],2)
        --resetListCellTable(drawingInfo[3],3)   
        currentTab = getPlayerJobId()
        resetListCellTable(drawingInfo[currentTab],currentTab)
        resetTabCellTable()     
  

        
        --底部按钮绑定
        CSResourceMgr.clickEventBinding(resNameLifeSkillLst,"btn_bottom",function() 
            if btnBottomState.state == 1 then --切换职业
                if btnBottomState.condtion == false then
                    StandardTipsMgr.show(1,trans_error_nomoney)
                
                else --弹出切换职业的选择框
 --               local uidataTable = {jobid =currentTab ,changetimes = lifeSkillInfo.changeTimes+1,jobname = tabTextArray[currentTab],needcash = btnBottomState.needcash}
                local uidataTable = {jobid =currentTab ,changetimes = lifeSkillInfo.changeTimes,jobname = tabTextArray[currentTab],needcash = btnBottomState.needcash}

                    LifeSkillJobChangeViewMgr.show(scene,uidataTable)
                    --[[
                    NetInterface.sendWithBlock("GC_ChangeLifeCareer_Ack",function() 
                        local lifeSkillSend =  require("src.Net.Send.LifeSkillSend")
                        lifeSkillSend.sendCG_ChangeLifeCareer_Req(currentTab)
                    end,function() 
                        refreshUIData()
                    end,
    
                    function(code) 
                        TipsMgr.showError(scene, code) 
                    end)
                    ]]
                end
            end
            
            if btnBottomState.state == 0 then --制造
                local level = lifeSkillInfo.level or 1
               
                if btnBottomState.makeid == 0 then
                    StandardTipsMgr.show(1,trans_error_nochoice)  
                elseif currentTab~= lifeSkillInfo.career then
                    StandardTipsMgr.show(1,trans_error_careerwrong) 
                elseif btnBottomState.needlv > level then
                    StandardTipsMgr.show(1,trans_error_lverror) 

                elseif btnBottomState.condtion == false then
                    StandardTipsMgr.show(1,trans_error_noitems) 

                else --制造
                    --LifeSkillLstViewMgr.sendManufactureReq(btnBottomState.makeid,1)


                    
                    NetInterface.sendWithBlock("GC_Manufacture_Ack",function() 
                        local lifeSkillSend =  require("src.Net.Send.LifeSkillSend")
                        local params = {}
                        params.makeid = btnBottomState.makeid
                        params.count = 1
                        lifeSkillSend.sendCG_Manufacture_Req(params)
                    end,function() 
                       
                
                        GameAudio.playUISound("success")
                        local drawinfo = filterDataList[btnBottomState.index]
                       
                        local rewardinfo = AdventureInfo.getRewardInfoByID(tonumber(drawinfo.awards[1]))
                        local iteminfo = nil
                        
                        local awardinfo = ItemInfo.getAwardElementInfoById(rewardinfo.element[1])
                        local awardid = 0
                        if awardinfo.elementType == 1 or awardinfo.elementType == 2  then
                            awardid = awardinfo.elementType
                        else
                            awardid = awardinfo.elementID
                        end
                        refreshData()
                        refreshTopUIData()
                        refreshNeedLv()
                        local list = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"list"..currentTab) 
                        local selid = list.selid
                        print("selid......."..selid)
                        local listcell = listCellTable[currentTab][selid]
                        showBottom(currentTab,listCellTable[currentTab][selid],filterDataList[selid].costs,0)
                        --StandardTipsMgr.show(0,trans_sucess_make)
                        AwardsListMgr.show(scene,{{awardid,rewardinfo.nReward[1]}})
                        
                        TaskWatcherManager.saveShenghuoJiNengState(btnBottomState.makeid)
                    end,
    
                    function(code) 
                        if code == 422 then
                            StandardTipsMgr.show(1,trans_error_bagfull)
                        else
                            TipsMgr.showError(scene, code)    
                        end

                    end)     
                                                   
                end         
            end
        
            if btnBottomState.state == 2 then --购买
                local level = lifeSkillInfo.level or 1
                if btnBottomState.makeid == 0 then
                    StandardTipsMgr.show(1,trans_error_nochoice)  

                elseif btnBottomState.needlv > level then
                    StandardTipsMgr.show(1,trans_error_lverror) 
                else
                    NetInterface.sendWithBlock("GC_BuyDrawings_Ack",function() 
                        local lifeSkillSend =  require("src.Net.Send.LifeSkillSend")
                        print("btnBottomState.makeid"..btnBottomState.makeid)
                        lifeSkillSend.sendCG_BuyDrawings_Req(btnBottomState.makeid)
                    end,function() 
                        GameAudio.playUISound("success")
                        local list = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"list"..currentTab) 
                        local selid = list.selid
                        print("selid......."..selid)
                        local listcell = listCellTable[currentTab][selid]
                        showBottom(currentTab,listCellTable[currentTab][selid],filterDataList[selid].costs,0) 
                        local picIcon = CSResourceMgr.seekNodeByName(listcell,"pic_icon")
                        picIcon:setColor({r=255,g=255,b=255})
                        listcell.makingstate = EnumDrawingMakingState.MakingStateReady 
                        if lifeSkillInfo.drawings == nil then
                            lifeSkillInfo.drawings = {}
                        end
                        updateCashNum()
                        table.insert(lifeSkillInfo.drawings,btnBottomState.makeid)
                        TaskWatcherManager.lifeskillInfo = lifeSkillInfo
                        TipsMgr.show(scene,trans_activesucce);                   
                    end,
                    function(code)
    
                        if code == Proto.Error.ERROR_DRAWING_CANNT_BUY_HERE then
                            StandardTipsMgr.show(1,trans_error_cantbuydrawing)
                        else
                            if code == Proto.Error.ERROR_NOT_ENOUGH_GCASH then
                                StandardTipsMgr.show(1,trans_error_nomoney)                           
                            end
    
                            if code == Proto.Error.ERROR_TERR_NOT_ENOUGH_MCASH then
                                StandardTipsMgr.show(1,trans_error_nomoney)  
                            end
    
                            if code == Proto.Error.ERROR_NOT_ENOUGH_GOLDCOIN then
                                StandardTipsMgr.show(1,trans_error_nomoney)  
                            end
                        end
    
                        --TipsMgr.showError(scene, code)                
                    end)              
                end

            end
        end)

        CSResourceMgr.clickEventBinding(resNameLifeSkillLst,"btn_bottom_2",function() 
            GameAudio.playUISound("popup")
                local level = lifeSkillInfo.level or 1
               
            if btnBottomState.makeid == 0 then
                StandardTipsMgr.show(1,trans_error_nochoice)  
            elseif currentTab~= lifeSkillInfo.career then
                StandardTipsMgr.show(1,trans_error_careerwrong) 
            elseif btnBottomState.needlv > level then
                StandardTipsMgr.show(1,trans_error_lverror) 

            elseif btnBottomState.condtion == false then
                StandardTipsMgr.show(1,trans_error_noitems) 

            else --制造
                local list = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"list"..currentTab) 
                local selid = list.selid
                local data = {}
                data.costs = filterDataList[selid].costs
                data.btnBottomState = btnBottomState
                data.qianliInfo = qianliInfo
                data.itemid = btnBottomState.iconid
                data.makeid = btnBottomState.makeid
                LifeSkillBatchMaker.show(SceneMgr.getRunningScene,data,1)
                --[[
                NetInterface.sendWithBlock("GC_Manufacture_Ack",function() 
                    local lifeSkillSend =  require("src.Net.Send.LifeSkillSend")
                    local params = {}
                    params.makeid = btnBottomState.makeid
                    params.count = 1
                    lifeSkillSend.sendCG_Manufacture_Req(params)
                end,function() 
                        
                    GameAudio.playUISound("success")
                    local drawinfo = filterDataList[btnBottomState.index]
                       
                    local rewardinfo = AdventureInfo.getRewardInfoByID(tonumber(drawinfo.awards[1]))
                    local iteminfo = nil
                        
                    local awardinfo = ItemInfo.getAwardElementInfoById(rewardinfo.element[1])
                    local awardid = 0
                    if awardinfo.elementType == 1 or awardinfo.elementType == 2  then
                        awardid = awardinfo.elementType
                    else
                        awardid = awardinfo.elementID
                    end
                    refreshData()
                    refreshTopUIData()
                    refreshNeedLv()
                    local list = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"list"..currentTab) 
                    local selid = list.selid
                    print("selid......."..selid)
                    local listcell = listCellTable[currentTab][selid]
                    showBottom(currentTab,listCellTable[currentTab][selid],filterDataList[selid].costs,0)
                    --StandardTipsMgr.show(0,trans_sucess_make)
                    AwardsListMgr.show(scene,{{awardid,rewardinfo.nReward[1]}})
                        
                    TaskWatcherManager.saveShenghuoJiNengState(btnBottomState.makeid)
                end,
    
                function(code) 
                    if code == 422 then
                        StandardTipsMgr.show(1,trans_error_bagfull)
                    else
                        TipsMgr.showError(scene, code)    
                    end

                end)   ]]                                   
            end         
            
        end,nil,1)
        
        CSResourceMgr.clickEventBinding(resNameLifeSkillLst,"btn_select",function() 
            GameAudio.playUISound("popup")
            LifeSkillFilterPopUp.show(scene,currentTab)
        end,nil,3)
        
        
        CSResourceMgr.clickEventBinding(resNameTop, "add_gcoin", function()
            ExchangeViewMgr.show(SceneMgr.getRunningScene,ExchangeViewMgr.GCASHTYPE)
        end)
        CSResourceMgr.clickEventBinding(resNameTop, "add_mcoin", function()
            PurchaseViewMgr.show(SceneMgr.getRunningScene,LifeSkillLstViewMgr.hide)
        end)
        
        --close按钮绑定
        --[[
        CSResourceMgr.clickEventBinding(resNameLifeSkillLst,"close",function()
            hideUI()
            GameGuideMgr.checkProcessInTown()
        end)
        ]]
    end
    
    
    local function playCSB()
        GameAudio.playUISound("popup")
        CSResourceMgr.getCsbObj(resNameLifeSkillLst):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resNameLifeSkillLst), "up", function()
            end)
        showTopInfoBar(function()LifeSkillLstViewMgr.hide()  end)
    end
    
    if useunblockloader then
        local funcTable = {loadBG, loadCSB, playCSB}
        UnblockLoader.load(funcTable, "LifeskillLstMgr.show")   
    else
        loadBG()
        loadCSB()
        playCSB()
    end

    SceneMgr.setMapVisible(false)


end


---------------------------------我是分割线------------------------------------


--类函数
function LifeSkillLstViewMgr.Init()
    resNameLifeSkillLst =  "Player/LifeSkill/LifeSkillList.csb" 
    resNameBg = "Pet/Formation/FormationBGNew.csb"
    resNameTop = "Charactor/TopInfoLayerSilverCoin2.csb"
    resNameSkill = "Player/SkillUpItem.csb"
    if isTxtInited==false then
        initDrawingInfo()
        isTxtInited = true
    end
    
    currentFirstListIndex = 1
end

function LifeSkillLstViewMgr.show(scene)
    UIStack.push("LifeSkillLstViewMgr",LifeSkillLstViewMgr.hide,true)
    scene = scene or SceneMgr.getRunningScene
    addUI(scene)

end

function LifeSkillLstViewMgr.hide()
    hideUI()
    GameGuideMgr.checkProcessInTown()
    UIStack.pop("LifeSkillLstViewMgr")
    --print("UIStack.pop(LifeSkillLstViewMgr)")
end

function LifeSkillLstViewMgr.refresh(type)
    type = type or 0
    if type == 0 then
        refreshUIData()  
    else
        refreshUIData()  
        showBottom(currentTab) 
    end

end


function LifeSkillLstViewMgr.filterList(filterstr)
    resetListCellTable(drawingInfo[currentTab],currentTab,filterstr)
end

function LifeSkillLstViewMgr.changeVisible(visible)

    CSResourceMgr.getCsbObj(resNameLifeSkillLst):setVisible(visible)
    CSResourceMgr.getCsbObj(resNameBg,"LifeSkillLstBg"):setVisible(visible)
    CSResourceMgr.getCsbObj(resNameTop):setVisible(visible)   
   -- CSResourceMgr.getCsbObj(resNameSkill):setVisible(visible)
end

function LifeSkillLstViewMgr.sendManufactureReq(makeid,count)
    NetInterface.sendWithBlock("GC_Manufacture_Ack",function() 
                        local lifeSkillSend =  require("src.Net.Send.LifeSkillSend")
                        local params = {}
                        params.makeid = makeid
                        params.count = count
                        lifeSkillSend.sendCG_Manufacture_Req(params)
                    end,function() 
                       
                        LifeSkillBatchMaker.hide()
                        GameAudio.playUISound("success")

                        local drawinfo = filterDataList[btnBottomState.index]
                       
                        local rewardinfo = AdventureInfo.getRewardInfoByID(tonumber(drawinfo.awards[1]))
                        
                        local awardinfo = ItemInfo.getAwardElementInfoById(rewardinfo.element[1])
                        local awardid = 0
                        if awardinfo.elementType == 1 or awardinfo.elementType == 2  then
                            awardid = awardinfo.elementType
                        else
                            awardid = awardinfo.elementID
                        end
                        refreshData()
                        refreshTopUIData()
                        refreshNeedLv()
                        local list = CSResourceMgr.getNodeByName(resNameLifeSkillLst,"list"..currentTab) 
                        local selid = list.selid
                        print("selid......."..selid)
                        local listcell = listCellTable[currentTab][selid]
                        showBottom(currentTab,listCellTable[currentTab][selid],filterDataList[selid].costs,0)
                        --StandardTipsMgr.show(0,trans_sucess_make)
                        local awardShowInfo = {}
                        for i=1,count do 
                            table.insert(awardShowInfo,{awardid,rewardinfo.nReward[1]})
                        end
                        AwardsListMgr.show(SceneMgr.getRunningScene,awardShowInfo)
                        
                        TaskWatcherManager.saveShenghuoJiNengState(btnBottomState.makeid)
                    end,
    
                    function(code) 
                        if code == 422 then
                            StandardTipsMgr.show(1,trans_error_bagfull)
                        else
                            TipsMgr.showError(scene, code)    
                        end

                    end)     

end

return LifeSkillLstViewMgr