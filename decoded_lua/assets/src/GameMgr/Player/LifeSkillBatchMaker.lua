--LifeSkillBatchMaker.lua
--Date
--此文件由[BabeLua]插件自动生成
local LifeSkillBatchMaker ={}

local trans_batchMaker = "lifeSkill066"
local trans_makerNum = "lifeSkill067"
local trans_needCailiao = "lifeSkill068"
local trans_error_numlimit = "lifeSkill069"
local editBox1 = nil
local editBox2 = nil

local uiData = nil
local batchMakerInfoData = nil
local resNameBatchMaker = ""

local bottomStartPos = 280 --底部的中心位置
local itemNumTable = {}
local maxItemNum = 10000000

local fontInfo = {--该界面所有的文本格式信息，用于界面设置
    txt_title ={
        have_selstate = false, --是否有选中态
        outline_width = 2,
        font_color = {r =144,g=238,b=255,a=255},
        outline_color = {r =38,g=54,b=76,a=255},
        text = trans_batchMaker
    },

    
    txt_job={
        have_selstate = false, --是否有选中态
        outline_width = 1,
        font_color = {r =144,g=238,b=255,a=255},          
        outline_color = {r =12,g=27,b=38,a=255},   
        text = "function"
    },
    
    txt_icontitle={
        have_selstate = true, --是否有选中态
        outline_width = nil, 
        font_color = {r =255,g=255,b=255,a=255},  --默认未选中
        outline_color = {r =0,g=0,b=0,a=255,w=1,s=1},     --默认未选中
        font_color_sel = {r =255,g=240,b=0,a=255},--选中  
        outline_color_sel = {r =0,g=0,b=0,a=255,w=1,s=1}, --选中     
        text = "title"      
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
    
 
      txt_itemnum1 ={
        have_selstate = true, --此处表示道具数量不够
        outline_width = 1, 
        font_color = {r =255,g=255,b=255,a=255},  --数量充足
        outline_color = {r =0,g=0,b=0,a=255}, --数量充足
        font_color_sel = {r =255,g=72,b=0,a=255},--数量不够
        outline_color_sel = {r =0,g=0,b=0,a=255}, --数量不够    
        text = 1
    },
    
    txt_itemnum3 ={
        have_selstate = true, --此处表示道具数量不够
        outline_width = 1, 
        font_color = {r =255,g=255,b=255,a=255},  --数量充足
        outline_color = {r =0,g=0,b=0,a=255}, --数量充足
        font_color_sel = {r=147,g=254,b=6,a=255},
        outline_color_sel = {r =0,g=0,b=0,a=255},
        text = 1
    },  
 
  
    

    
    txt_btnbottom = {
        have_selstate = false, 
        outline_width = 1, 
        font_color = {r =255,g=255,b=255,a=255},  
        outline_color = {r =0,g=0,b=0,a=255,w=1,s=1}, 
        text =trans_maker   
    },
    
    
}
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
local function createDrawingIconByConsumeId(id,btnBottomState,qianliInfo)
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

    return iconnode,itemEnough,myItemNum,needItemNum
end

---显示合成需要消耗的材料
local function showDrawingCosts(data)
    print("costs num........................" ..#data.costs)
    local costs = data.costs
    if costs == nil then
    else 
        local startpos =bottomStartPos
        startpos = startpos-(#costs-1)*47*1.5/1.2
        local bottombg = CSResourceMgr.getNodeByName(resNameBatchMaker,"img_labelbg")
        bottombg:removeAllChildren()
        local isItemEnough = true
        itemNumTable = {}
        if #costs > 0 then 
            maxItemNum = 10000000
        else
            maxItemNum = 0
        end 
        for i=1,#costs do
            print("costs..................."..costs[i])
            local itemnum,needitemnum
            local iconitem,itemEnough,itemnum,needitemnum = createDrawingIconByConsumeId(costs[i],data.btnBottomState,data.qianliInfo)
            itemNumTable[i]={itemnum,needitemnum}
            local maxitem = math.floor(itemnum/needitemnum)
            print("maxite is ......................."..maxitem)
            if maxitem <= maxItemNum then 
                maxItemNum = maxitem
            end
            if iconitem~=nil then
                iconitem:setScale(0.9)
                bottombg:addChild(iconitem)
                iconitem:setPosition(startpos+(i-1)*47*2.6/1.2, 52)            
            end
            
            if itemEnough == false then
                isItemEnough = false
            end
        end
        
        data.btnBottomState.condtion = isItemEnough
     
    end
end

local function hideUI()
    GameAudio.playUISound("retract")
    UnblockLoader.cancel("LifeSkillBatchMaker.show")
    CSResourceMgr.removeCSObjectByTag(resNameBatchMaker)
end

local function initUIBaseData(data)
    showDrawingCosts(data)

    local listicon = CSResourceMgr.getNodeByName(resNameBatchMaker, "btn_icon")
    CSResourceMgr.buttonEventBindingByNode(listicon, function ()
                    ItemInfoViewMgr.show({id = data.itemid}, false)
                end, function ()
                    ItemInfoViewMgr.hide()
                end, function ()
                end, function ()
                    ItemInfoViewMgr.hide()
                end, true)
    --print("texture tererwsrwt "..data.itemid)
    print("data.itemid is......................"..data.itemid)
    local texture = ItemInfo.getItemRareBGImage(data.itemid)
    local picIcon = CSResourceMgr.seekNodeByName(listicon,"img_icon")
    --print("data.itemicon"..data.itemicon)
    local iteminfo = ItemInfo.getItemInfoById(data.itemid)
    local icon = iteminfo.icon
    picIcon:loadTexture(icon)
    CSResourceMgr.setButtonTextureByNode(listicon,texture,texture,texture)

    local title = CSResourceMgr.getNodeByName(resNameBatchMaker,"txt_dbtitle") 
    setLabel(title,fontInfo.txt_title.text,fontInfo.txt_title.outline_color,fontInfo.txt_title.outline_width,fontInfo.txt_title.font_color)

    local iconTitle = CSResourceMgr.getNodeByName(resNameBatchMaker,"txt_title1") 
    setLabel(iconTitle,iteminfo.name,fontInfo.txt_btnbottom.outline_color,fontInfo.txt_btnbottom.outline_width,fontInfo.txt_btnbottom.font_color)

    local bottomTitle = CSResourceMgr.getNodeByName(resNameBatchMaker,"txt_make") 
    setLabel(bottomTitle,"lifeSkill009",fontInfo.txt_btnbottom.outline_color,fontInfo.txt_btnbottom.outline_width,fontInfo.txt_btnbottom.font_color)

    local maxTitle = CSResourceMgr.getNodeByName(resNameBatchMaker,"txt_max") 
    setLabel(maxTitle,"MAX",fontInfo.txt_btnbottom.outline_color,fontInfo.txt_btnbottom.outline_width,fontInfo.txt_btnbottom.font_color)

    local txt_title2 = CSResourceMgr.getNodeByName(resNameBatchMaker,"txt_title2") 
    setLabel(txt_title2,trans_makerNum,fontInfo.txt_job.outline_color,fontInfo.txt_job.outline_width,fontInfo.txt_job.font_color)

    local txt_title3 = CSResourceMgr.getNodeByName(resNameBatchMaker,"txt_title3") 
    setLabel(txt_title3,trans_needCailiao,fontInfo.txt_job.outline_color,fontInfo.txt_job.outline_width,fontInfo.txt_job.font_color)

    local fieldtextbg1 = CSResourceMgr.getNodeByName(resNameBatchMaker,"img_textbg")
    local oldnum = 1
    local currentnum = 1
    editBox1 =  CocosModuleMgr.newTextEditor(fieldtextbg1,"empty.png",140,36,75,18,24,10,1,2,function()         
         local number = tonumber(editBox1:getText())
         if number > maxItemNum then 
            StandardTipsMgr.show(1,trans_error_numlimit)
            editBox1:setText(oldnum)
         else
            oldnum = number
         end
    end)
    local btnBottom =  CSResourceMgr.getNodeByName(resNameBatchMaker,"btn_make")
     CSResourceMgr.clickEventBindingByNode(btnBottom, function()
        LifeSkillLstViewMgr.sendManufactureReq(data.makeid,oldnum)
        end)
     local btnMax = CSResourceMgr.getNodeByName(resNameBatchMaker,"btn_max")
     CSResourceMgr.clickEventBindingByNode(btnMax,function()
        oldnum = maxItemNum
        editBox1:setText(maxItemNum)
     end)

end

local function addUI(scene,data)
    if CSResourceMgr.getCsbObj(resNameBatchMaker) or data == nil then
        return  
    end  
    batchMakerInfoData = data

    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resNameBatchMaker)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBatchMaker, 320, 480)

        initUIBaseData(data)

        CSResourceMgr.getNodeByName(resNameBatchMaker, "img_tcd"):setVisible(false)   
         CSResourceMgr.getNodeByName(resNameBatchMaker, "btn_close"):setVisible(false)  
        --[[
        CSResourceMgr.clickEventBinding(resNameBuyInfoMgr, "bg", function()
        hideUI()
        end)
        ]]
        CSResourceMgr.clickEventBinding(resNameBatchMaker, "btn_close", function()
            --hideUI()
			LifeSkillBatchMaker.hide()
        end)    
        
    end
    
    local function playCSB()
        GameAudio.playUISound("popup")
        local db = CSResourceMgr.getNodeByName(resNameBatchMaker, "img_tcd")
        db:setVisible(true)
        local clostbtn =  CSResourceMgr.getNodeByName(resNameBatchMaker, "btn_close")
        clostbtn:setVisible(true) 
        CocosModuleMgr.showUIAnimation(db, "down")
         CocosModuleMgr.showUIAnimation(clostbtn, "down")
    end

    loadCSB()
    playCSB()
end

function LifeSkillBatchMaker.Init()
    resNameBatchMaker = "Player/LifeSkill/LifeSkillMultiMaker.csb"
    resNameLifeSkillLst =  "Player/LifeSkill/LifeSkillList.csb" 
    editBox1= nil
    editBox2= nil
end

function LifeSkillBatchMaker.show(scene,data,uidata)	 
	UIStack.push("LifeSkillBatchMaker",LifeSkillBatchMaker.hide,false)
    uiData = uidata
    addUI(scene,data)
end

function LifeSkillBatchMaker.hide()
	hideUI()
	UIStack.pop("LifeSkillBatchMaker")
end
return LifeSkillBatchMaker























--endregion
