--vesion number 1.0
--@client side PetHandBook.lua
--[[
这个文件是宠物图鉴界面
--]]
--script writer Leon Lee
--creation time 2016-5-12

local PetHandBook = {}
local debugprint = false --是否开启调试打印
--翻译
local trans_cwtj = "petBook107"
local trans_qb = "petBook108"
local trans_cs = "petBook109"
local trans_xy = "petBook110"
local trans_pt = "petBook111"
local tabTextArray = {trans_qb,trans_cs,trans_xy,trans_pt}
---------------------------------我是分割线------------------------------------
--数据信息
local pokemonInfoLst = nil --宠物总列表
local pokemonTypeInfoLst = nil --宠物分类列表
--local pokemonTypeInfoTail = {} --宠物分类传说
--local pokemonTypeInfoRare = {} --宠物分类稀有
--local pokemonTypeInfoNormal = {} --宠物分类普通
local curPokeMonInfoLst = nil
--ui初始化信息
local resNamePetHandBook = "" --图鉴UI资源
local resNameBg = "" --背景UI资源
local isHavePokeInfoLst = {} --是否激活过
local fontInfo = {
    txt_title={
        have_selstate = false, --是否有选中态
        outline_width = 1,
        font_color = {r =144,g=238,b=255,a=255},          
        outline_color = {r =0,g=0,b=0,a=255},   
        text = trans_cwtj                  
    },  
	
	txt_tab1text={
		have_selstate = true, --是否有选中态
		outline_width = 1, 
		font_color = {r =82,g=82,b=82,a=255},  --默认未选中
		outline_color = {r =236,g=236,b=236,a=255},     --默认未选中
		font_color_sel = {r =255,g=255,b=255,a=255},--选中  
		outline_color_sel = {r =209,g=138,b=0,a=255}, --选中   
		text = trans_qb                     
    },
	
	txt_tab2text={
		have_selstate = true, --是否有选中态
		outline_width = 1, 
		font_color = {r =82,g=82,b=82,a=255},  --默认未选中
		outline_color = {r =236,g=236,b=236,a=255},     --默认未选中
		font_color_sel = {r =255,g=255,b=255,a=255},--选中  
		outline_color_sel = {r =209,g=138,b=0,a=255}, --选中   
		text = trans_cs                     
    },
	
	txt_tab3text={
		have_selstate = true, --是否有选中态
		outline_width = 1, 
		font_color = {r =82,g=82,b=82,a=255},  --默认未选中
		outline_color = {r =236,g=236,b=236,a=255},     --默认未选中
		font_color_sel = {r =255,g=255,b=255,a=255},--选中  
		outline_color_sel = {r =209,g=138,b=0,a=255}, --选中   
		text = trans_xy                     
    },
	
	txt_tab4text={
		have_selstate = true, --是否有选中态
		outline_width = 1, 
		font_color = {r =82,g=82,b=82,a=255},  --默认未选中
		outline_color = {r =236,g=236,b=236,a=255},     --默认未选中
		font_color_sel = {r =255,g=255,b=255,a=255},--选中  
		outline_color_sel = {r =209,g=138,b=0,a=255}, --选中   
		text = trans_pt                     
    },
}

local currentTabId = 0
local leftBtnArray = {}
local topBtnArray = {}
local originLeftTabPosX,clickedLeftTabPosX

local resizePosYTable = {"txt_title","btn_all"} --需要重新设置尺寸的元素表
local resetContentSizeTable = {"frame","list1","background","black"} --需要重新设置contentsize的表
local petWikiList = {}

--下面的变量都是用于列表的优化更新
local listUpadateHandler = nil --用于优化列表更新
local updateInterval = 1.0/24.0
local timeTick = 0
local scheduler = require("src.framework.scheduler")
local spawnCount =8
local listcellTemplate = nil
local totalheight = 0
local spacing = 0
local lastContentPosY = -1
local listcellHeight = 186
local reuseItemOffset = 0
local bufferZone = 190
local countPerLine = 3
-----------------------------------------------------------
--
--

local function initPodexCellColor(p,id)
    if isHavePokeInfoLst[id] == nil and petWikiList[id] == nil then
        --print("no pet id is:"..pokeArray[i].id)
        p.button:setColor({r=77,g=77,b=77,a=255})
        p.head:setColor({r=77,g=77,b=77,a=255})
        p.rare:setColor({r=77,g=77,b=77,a=255})
        p.attri:setColor({r=77,g=77,b=77,a=255})
        p.headBK:setColor({r=77,g=77,b=77,a=255})
        --p.rarei:setColor({r=77,g=77,b=77,a=255})
        --p.attri:setColor({r=77,g=77,b=77,a=255})
        --p.name:setColor({r=77,g=77,b=77,a=255})
    else
        p.button:setColor({r=255,g=255,b=255,a=255})
        p.head:setColor({r=255,g=255,b=255,a=255})
        p.rare:setColor({r=255,g=255,b=255,a=255})
        p.attri:setColor({r=255,g=255,b=255,a=255})
        p.headBK:setColor({r=255,g=255,b=255,a=255})        
    end
end


local function createListCell(pokeArray)

	local listcell = CSResourceMgr.getNodeByName(resNamePetHandBook,"pic_listbgexmaple"):clone()
	listcell.element = {}
	--local bg = CSResourceMgr.seekNodeByName(listcell,"pic_listbg")  
	--bg:setColor({r=37,g=53,b=69,a=255})
	local list1 = CSResourceMgr.getNodeByName(resNamePetHandBook,"list1")
	for i = 1,#pokeArray do
        local p = BattleFuncMgr.startCreatePetHandBookData(pokeArray[i])
       
        initPodexCellColor(p,pokeArray[i].id)
        
        --[[
        if isHavePokeInfoLst[pokeArray[i].id] == nil then
            --print("no pet id is:"..pokeArray[i].id)
            p.button:setColor({r=77,g=77,b=77,a=255})
            p.head:setColor({r=77,g=77,b=77,a=255})
            p.rare:setColor({r=77,g=77,b=77,a=255})
            p.attri:setColor({r=77,g=77,b=77,a=255})
            p.headBK:setColor({r=77,g=77,b=77,a=255})
            --p.rarei:setColor({r=77,g=77,b=77,a=255})
            --p.attri:setColor({r=77,g=77,b=77,a=255})
            --p.name:setColor({r=77,g=77,b=77,a=255})
        end
]]
        listcell:addChild(p.button)
        p.button:setPosition(90+160*(i-1), 75)
        p.button:setAnchorPoint(0.5,0.5) 
        p.button:setScale(1.7)
        listcell.element[i] = p.button
   
        CSResourceMgr.clickEventBindingByNode(p.button,function() 
            --LifeSkillSelViewMgr.show(SceneMgr.getRunningScene)
            --local listcell0 = list1:getItem(10)
            --local x,y = listcell0:getPosition()
            --print("parent position is:"..x,y)
            
            --local worldposx,worldposy = listcell0:convertToWorldSpaceAR(cc.p(x,y))
            PetInfoViewMgr.show(SceneMgr.getRunningScene,pokeArray[i].id )
            --local viewpos = list1:convertToNodeSpaceAR(cc.p(worldposx,worldposy))
			--print("viewpos position is:"..viewpos.x,viewpos.y)
			
			--local container = (list1:getInnerContainer())
            --local pos1,pos2 = container:getPosition()
            --print("inery postion y is:"..pos2)
        end,3)
        BattleFuncMgr.endCreatePetCard()
	end
    --
    --[[
    for i = 1,4 do
        local node = CSResourceMgr.seekNodeByName(listcell,"btn_diban"..i)   
        node:setVisible(false)
    end
    
	for i = 1,#pokeArray do
	    local parent = CSResourceMgr.seekNodeByName(listcell,"btn_diban"..i)
	    parent:setVisible(true)

	    
        local p = PetListMgr.createHandBookPetNode(pokeArray[i],"pokemon"..i,parent)
        if isHavePokeInfoLst[pokeArray[i].id] == nil then
            --print("no pet id is:"..pokeArray[i].id)
            p.node:setColor({r=77,g=77,b=77,a=255})
            p.icon:setColor({r=77,g=77,b=77,a=255})
            p.rareicon:setColor({r=77,g=77,b=77,a=255})
            p.attricon:setColor({r=77,g=77,b=77,a=255})
            p.rarei:setColor({r=77,g=77,b=77,a=255})
            p.attri:setColor({r=77,g=77,b=77,a=255})
            --p.name:setColor({r=77,g=77,b=77,a=255})
        end
        CSResourceMgr.clickEventBindingByNode(p.node,function() 
            --LifeSkillSelViewMgr.show(SceneMgr.getRunningScene)
            PetInfoViewMgr.show(SceneMgr.getRunningScene,pokeArray[i].id )

        end,3)
		--listcell:addChild(p.node)
        --p.node:setPosition(70+130*(i-1), 55)
        --p.node:setAnchorPoint(0.5,0.5) 
        p.node:setScale(0.9,0.9)
       
	end
	]]
	return listcell
end

local function createDummyListCell()
    local listcell = CSResourceMgr.getNodeByName(resNamePetHandBook,"pic_listbgexmaple"):clone()
    return listcell
end

local function updateItem(item,isdown,countperline,spawncount,showlist)
    local index = item.index
	local currentindex = 0
	if isdown then --如果是向下滑
		currentindex = item.index - spawncount*countPerLine
		if debugprint then 
            print("isdown true item.index:"..item.index,currentindex)
        end
		
	else --向上滑
		currentindex = item.index + spawncount*countPerLine
		if debugprint then
            print("isdown false item.index:"..item.index,currentindex)
        end
	end
	
	if currentindex >  0 then
        --local cellindex = (item.index)%countperline
       item.index = currentindex
       for i=1,countPerLine do
			if item.element[i] ~=nil then
                --print("currentindex+i-1,#showlist"..currentindex+i-1,#showlist)
                local showlistindex = currentindex+i-1
                if showlistindex > #showlist then
                    item.element[i]:setVisible(false)
                else
                    item.element[i]:setVisible(true)
                    local p = BattleFuncMgr.startCreatePetHandBookData(showlist[currentindex+i-1],item.element[i])	
                    initPodexCellColor(p,showlist[currentindex+i-1].id)
                    CSResourceMgr.clickEventBindingByNode(p.button,function() 
                        PetInfoViewMgr.show(SceneMgr.getRunningScene,showlist[currentindex+i-1].id )      
    
                    end,3)
                end
             else
                local p = BattleFuncMgr.startCreatePetHandBookData(showlist[currentindex+i-1])  
                initPodexCellColor(p,showlist[currentindex+i-1].id)
                CSResourceMgr.clickEventBindingByNode(p.button,function() 
                    PetInfoViewMgr.show(SceneMgr.getRunningScene,showlist[currentindex+i-1].id )
                end,3)               
			end
	   end
        --print("currentindex,cellindex",currentindex,cellindex)
        --BattleFuncMgr.startCreatePetHandBookData(pokemonInfoLst[currentindex],item.element[cellindex])
	end
end


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

local function resizePosY(resizeTable)
    local diff = CocosModuleMgr.getScreenSizeDiff()
    for i= 1,#resizeTable do
        local resizecell = CSResourceMgr.getNodeByName(resNamePetHandBook, resizeTable[i])
        local cposy = resizecell:getPositionY()
        resizecell:setPositionY(cposy+diff)
    end
end

local function resetContentSize(resetContentSizeTable)
	local diff = CocosModuleMgr.getScreenSizeDiff()
	for i = 1,#resetContentSizeTable do
        local resetcell = CSResourceMgr.getNodeByName(resNamePetHandBook, resetContentSizeTable[i])	
		local dbsize = resetcell:getContentSize()
		resetcell:setContentSize(dbsize.width, dbsize.height+diff)
	end
end

PetHandBook.tableprint = function(data,cstring)  
    if data == nil then   
        print("core.print data is nil");  
    end  
    local cs = cstring .. " ";  
    print(cstring .."{");  
    if(type(data)=="table") then  
        for k, v in pairs(data) do  
            print(cs..tostring(k).." = "..tostring(v));  
            if(type(v)=="table") then  
                PetHandBook.tableprint(v,cs);  
            end  
        end  
    else  
        print(cs..tostring(data));  
    end  
    print(cstring .."}");  
end  

local function initPokeMonDataInfo()
    local pokeInfo = PokemonInfo.getAllPets()
    for i=1,#pokeInfo do
        if debugprint then
            print("pokeInfo[i].pokeID:"..pokeInfo[i].pokeID)
        end
        isHavePokeInfoLst[pokeInfo[i].pokeID] = 1    
    end
end

local function initFontInfo()
	for k,v in pairs (fontInfo) do
		local concatstr = ""
        local txtcell = CSResourceMgr.getNodeByName(resNamePetHandBook,concatstr..k)
		setLabel(txtcell,v.text,v.outline_color,v.outline_width,v.font_color)
	end
end

local function setLeftTabBtnState(tabBtn,isSelected)
    local isEnabled = false
    local posx = originLeftTabPosX
    if isSelected == false then isEnabled = true end
	if isSelected == true then posx = clickedLeftTabPosX end
    CSResourceMgr.setButtonEnabledByNode(tabBtn,isEnabled)
    local btn1 = CSResourceMgr.seekNodeByName(tabBtn,"btn_iconall")
    CSResourceMgr.setButtonEnabledByNode(btn1,isEnabled)
    local btn2 = CSResourceMgr.seekNodeByName(clickedTabBtn,"btn_attrico")
    CSResourceMgr.setButtonEnabledByNode(btn2,isEnabled) 
	tabBtn:setPositionX(posx)
end

local function setTopTabBtnState(tabBtn,isSelected)
    local isEnabled = false  
    if isSelected == false then isEnabled = true end
    CSResourceMgr.setButtonEnabledByNode(tabBtn,isEnabled) 
    local arrorws  = CSResourceMgr.seekNodeByName(tabBtn,"arrows")
   if isSelected == true then
        tabBtn:setScale(1.1)
        tabBtn:setLocalZOrder(5)
        arrorws:setVisible(true)
   else
        arrorws:setVisible(false)
        tabBtn:setScale(1.0)
   end
   
end

local function initUIBaseData()

    
	initFontInfo()
	resetContentSize(resetContentSizeTable)
    resizePosY(resizePosYTable)
    --左侧tab标签页添加
    local index =0
   -- local istbg1_small = CSResourceMgr.getNodeByName(resNamePetHandBook,"pic_listbg1_small")
   -- local diwen_small = CSResourceMgr.getNodeByName(resNamePetHandBook,"panel_diwen_small")    
    --local istbg2_small = CSResourceMgr.getNodeByName(resNamePetHandBook,"pic_listbg2_small")
    --local listbg2 = CSResourceMgr.getNodeByName(resNamePetHandBook,"pic_listbg2")
    local list1 = CSResourceMgr.getNodeByName(resNamePetHandBook,"list1")

   -- istbg1_small:setLocalZOrder(6)
    --diwen_small:setLocalZOrder(6)     
    --istbg2_small:setLocalZOrder(6) 
    --listbg2:setLocalZOrder(5) 
    leftBtnArray = {}
    local btnall = CSResourceMgr.getNodeByName(resNamePetHandBook,"btn_all")
    btnall.id = 0
    local parent = CSResourceMgr.getNodeByName(resNamePetHandBook,"frame")
	table.insert(leftBtnArray,btnall)
	
	btnall:setLocalZOrder(1)
    local x,y = btnall:getPosition()
    originLeftTabPosX = x
    clickedLeftTabPosX = x-10
    
    
    for i = 1,18 do
        local cnt = #pokemonTypeInfoLst[i]
        if cnt > 0 then --有该属性，添加属性标签
            index = index+1
            local btn = CSResourceMgr.getNodeByName(resNamePetHandBook,"btn_all"):clone()
            local btnarri = CSResourceMgr.seekNodeByName(btn,"btn_attrico")
            local filename = "UI/CommonFiles/"..i..".png"
            CSResourceMgr.setButtonTextureByNode(btnarri,filename,filename,filename)
            parent:addChild(btn)
            btn:setPosition(x,y-index*70)
            --btnarri:setScale(1.6)
            btn.id = i
            table.insert(leftBtnArray,btn)
            
        end
    end
    
    local background = CSResourceMgr.getNodeByName(resNamePetHandBook,"background")
    background:setLocalZOrder(2)
    
    local black = CSResourceMgr.getNodeByName(resNamePetHandBook,"black")
    black:setLocalZOrder(2)
        
    setLeftTabBtnState(btnall,true)
    local tab1 = CSResourceMgr.getNodeByName(resNamePetHandBook,"tab1")
    local tab2 = CSResourceMgr.getNodeByName(resNamePetHandBook,"tab2")   
    local tab3 = CSResourceMgr.getNodeByName(resNamePetHandBook,"tab3")
    local tab4 = CSResourceMgr.getNodeByName(resNamePetHandBook,"tab4")    
    tab1:setLocalZOrder(3)
	tab2:setLocalZOrder(3)
	tab3:setLocalZOrder(3)
	tab4:setLocalZOrder(3)
    tab1.id = 0
    tab2.id = 5
    tab3.id = 3
    tab4.id = 1
    tab1.index = 1
    tab2.index = 2
    tab3.index = 3
    tab4.index = 4
    
    topBtnArray = {}
    table.insert(topBtnArray,tab1)
    table.insert(topBtnArray,tab2)
    table.insert(topBtnArray,tab3)
    table.insert(topBtnArray,tab4)
    

    local txtcell = CSResourceMgr.getNodeByName(resNamePetHandBook,"txt_tab1text")
    setLabel(txtcell,fontInfo.txt_tab1text.text,fontInfo.txt_tab1text.outline_color_sel,fontInfo.txt_tab1text.outline_width,fontInfo.txt_tab1text.font_color_sel)
    setTopTabBtnState(tab1,true)
    curPokeMonInfoLst =pokemonInfoLst
    

end


local function getItemPositionYInView(item,list)
    local x,y = item:getPosition()
    local worldPos = item:getParent():convertToWorldSpaceAR(cc.p(x,y));
    local viewPos = list:convertToNodeSpaceAR(worldPos);
    return viewPos.y;
end

local function resetListCell(dataList)
	local list1 = CSResourceMgr.getNodeByName(resNamePetHandBook,"list1")
    list1:setLocalZOrder(7)
    
    if listUpadateHandler~=nil then 
        scheduler.unscheduleGlobal(listUpadateHandler)
        listUpadateHandler = nil
    end
    
    list1:removeAllItems()
	

    local allnum = #dataList--pokemonInfoLst
    local index = 0
	local listCellArray = {}
	UnblockLoader.cancel("PetHandBook-loadlist")
	
    local totalcount = math.floor(allnum/3)
	if allnum%3 > 0 then totalcount = totalcount+1 end
	--local totalcount = math(allnum/3+allnum%3)
    while allnum > 0 do
        
		local testPokeArray = {}
        for i = 1,3 do

            index = index+1
            allnum = allnum-1
            table.insert(testPokeArray,dataList[index])
		    
            if allnum == 0 then table.insert(listCellArray,testPokeArray) break end
			if i == 3 then 
				table.insert(listCellArray,testPokeArray) 
			end
        end
        
    end
	local funcTable = {}
	

	for i = 1,#listCellArray do	
	   if i <= spawnCount and i <=#listCellArray then 
            table.insert(funcTable,function() 
                local listcell = createListCell(listCellArray[i])
                
                listcellHeight = listcell:getContentSize().height
                listcell:setScaleY(0)
                list1:pushBackCustomItem(listcell)
                transition.scaleTo(listcell,{scale=1.0,time=0.1})
                
                listcell.index = 1+(i-1)*countPerLine
            end)   
	   else
	       break
	   --[[
            table.insert(funcTable,function() 
                local listcell = createDummyListCell()
                list1:pushBackCustomItem(listcell)
                listcell:setVisible(false)
            end) 	  
            ]]     	   
	   end
	end
	
	local function resizeInnerHeight()
        if totalcount > 0 then 
            totalheight = listcellHeight * totalcount + (totalcount-1)*spacing;
            reuseItemOffset = (listcellHeight + spacing) * (spawnCount);
            local size = list1:getInnerContainerSize()
            --print("before setInnerSize height:"..size.height)
            size.height = totalheight
           
            -- list1:forceDoLayout()
            list1:requestRefreshView()
    		list1:doLayout()
            list1:setInnerContainerSize({width = size.width,height = totalheight})
            --print("after setInnerSize height:"..size.height)
            -- print("total height,resueItemOffset,listcellheight"..size.height,reuseItemOffset,listcellHeight)
			list1:jumpToTop()
        end
    end
     table.insert(funcTable,resizeInnerHeight)
    --[[
    for i=1,#funcTable do
        funcTable[i]()

    end
    ]]
   
    
    --注册全局事件   
    local function registerCheckFunc()
        timeTick = os.clock()
        listUpadateHandler = scheduler.scheduleUpdateGlobal(function() 
            local deltaTime = os.clock() - timeTick
            if deltaTime < updateInterval then return end
            timeTick = os.clock()
            local container = (list1:getInnerContainer())
            local pos1,pos2 = container:getPosition()
            local listviewheight = list1:getContentSize().height
            local isDown = false
            if pos2 -lastContentPosY<0 then isDown = true end
            if lastContentPosY~=-1 then
                local cnt = #dataList
                if cnt > spawnCount then 
                    cnt = spawnCount
                end

                for i = 1 ,cnt do
                    if i > totalcount then break end
                    local item = list1:getItem(i-1)
                    if debugprint then
                        print("i-1,cnt,totalcount"..i-1,cnt,totalcount)
                    end
                    local itemPos = getItemPositionYInView(item,list1);
                    local x,y = item:getPosition()
                    if isDown then 
                        if  itemPos < -bufferZone and y + reuseItemOffset < totalheight then
                            item:setPositionY(item:getPositionY() + reuseItemOffset)


                            updateItem(item,isDown,countPerLine,spawnCount,dataList)                   
                        end

                        --this->updateItem(itemID, i);
                    else 
                        if  itemPos > bufferZone + listviewheight and y - reuseItemOffset >= 0 then
                            --print("item index, posy,reuseitemoffset"..item:getPositionY(),reuseItemOffset)
                            item:setPositionY(item:getPositionY() - reuseItemOffset)
                            updateItem(item,isDown,countPerLine,spawnCount,dataList) 

                        end

                    end
                end
            end
            --print("inery postion y is:"..pos2)
            container = (list1:getInnerContainer())
            pos1,pos2 = container:getPosition()
            lastContentPosY = pos2
        end)    
    end
    table.insert(funcTable,registerCheckFunc)
   UnblockLoader.load(funcTable,"PetHandBook-loadlist",0.1)
	
	--[[
    for i=1,#funcTable do
        funcTable[i]()

    end
]]
end

local function showCurrentPokemonInfoLst()

    local showPokeMonInfoLst = {}
    if currentTabId == 0 then 
        resetListCell(curPokeMonInfoLst)  
    else
        for i = 1,#curPokeMonInfoLst do
            if curPokeMonInfoLst[i].rarePoint >=currentTabId and curPokeMonInfoLst[i].rarePoint <=currentTabId+1 then
                table.insert(showPokeMonInfoLst,curPokeMonInfoLst[i])
            end
        end  
        resetListCell(showPokeMonInfoLst)   
    end    
end

local function onLeftTabChange(clickedTabBtn)

    for i = 1, #leftBtnArray do
        setLeftTabBtnState(leftBtnArray[i],false)
    end
    
    setLeftTabBtnState(clickedTabBtn,true)
    if clickedTabBtn.id > 0 then

        curPokeMonInfoLst = pokemonTypeInfoLst[clickedTabBtn.id]
        --resetListCell(pokemonTypeInfoLst[clickedTabBtn.id])
    else

        curPokeMonInfoLst = pokemonInfoLst  
        --resetListCell(pokemonInfoLst)   
    end
    
    showCurrentPokemonInfoLst()
end

local function onTopTabChange(clickedTabBtn)
    for i = 1,#topBtnArray do
        setTopTabBtnState(topBtnArray[i],false)
        topBtnArray[i]:setLocalZOrder(#topBtnArray-i+3)      
    end
    
    setTopTabBtnState(clickedTabBtn,true)
    clickedTabBtn:setLocalZOrder(6)
    local index = clickedTabBtn.id
    local i = clickedTabBtn.index
    
    
    local txtcell = CSResourceMgr.getNodeByName(resNamePetHandBook,"txt_tab1text")
    setLabel(txtcell,fontInfo.txt_tab1text.text,fontInfo.txt_tab1text.outline_color,fontInfo.txt_tab1text.outline_width,fontInfo.txt_tab1text.font_color)
    
    
    txtcell = CSResourceMgr.getNodeByName(resNamePetHandBook,"txt_tab2text")
    setLabel(txtcell,fontInfo.txt_tab2text.text,fontInfo.txt_tab1text.outline_color,fontInfo.txt_tab1text.outline_width,fontInfo.txt_tab1text.font_color)

    
    txtcell = CSResourceMgr.getNodeByName(resNamePetHandBook,"txt_tab3text")
    setLabel(txtcell,fontInfo.txt_tab3text.text,fontInfo.txt_tab1text.outline_color,fontInfo.txt_tab1text.outline_width,fontInfo.txt_tab1text.font_color)

    
    txtcell = CSResourceMgr.getNodeByName(resNamePetHandBook,"txt_tab4text")
    setLabel(txtcell,fontInfo.txt_tab4text.text,fontInfo.txt_tab1text.outline_color,fontInfo.txt_tab1text.outline_width,fontInfo.txt_tab1text.font_color)
  
 
    txtcell = CSResourceMgr.getNodeByName(resNamePetHandBook,"txt_tab"..clickedTabBtn.index.."text")
    setLabel(txtcell,tabTextArray[i],fontInfo.txt_tab1text.outline_color_sel,fontInfo.txt_tab1text.outline_width,fontInfo.txt_tab1text.font_color_sel)
    
    currentTabId = index
    
    
    --[[
    local showPokeMonInfoLst = {}
    if index == 0 then 
        resetListCell(curPokeMonInfoLst)  
    else
        for i = 1,#curPokeMonInfoLst do
            if curPokeMonInfoLst[i].rarePoint >=index and curPokeMonInfoLst[i].rarePoint <=index+1 then
                table.insert(showPokeMonInfoLst,curPokeMonInfoLst[i])
            end
        end  
        resetListCell(showPokeMonInfoLst)   
    end
    ]]
    
    showCurrentPokemonInfoLst()
 
    
    
end

local function buttonBinding()
    for i = 1,#leftBtnArray do
        CSResourceMgr.clickEventBindingByNode(leftBtnArray[i],function() 
            onLeftTabChange(leftBtnArray[i])
        end,1,"sheetClick")
        
        local btn1 = CSResourceMgr.seekNodeByName(leftBtnArray[i],"btn_iconall")
        CSResourceMgr.clickEventBindingByNode(btn1,function() 
            onLeftTabChange(leftBtnArray[i])
        end,1,"sheetClick")

        local btn2 = CSResourceMgr.seekNodeByName(leftBtnArray[i],"btn_attrico")
        CSResourceMgr.clickEventBindingByNode(btn2,function() 
            onLeftTabChange(leftBtnArray[i])
        end,1,"sheetClick")
    end
    
    for i=1,#topBtnArray do
        CSResourceMgr.clickEventBindingByNode(topBtnArray[i],function() 
            onTopTabChange(topBtnArray[i])
        end,1,"sheetClick")
    end

end

local function hideUI()
    GameAudio.playUISound("retract")
    if listUpadateHandler~=nil then 
        scheduler.unscheduleGlobal(listUpadateHandler)
        listUpadateHandler = nil
    end
   
    StatusBarMgr.hideTopInfoBar()
      UIStack.pop("PetHandBook")
    UnblockLoader.cancel("PetHandBook-loadlist")
    UnblockLoader.cancel("PetHandBook")    
	CSResourceMgr.getNodeByName(resNamePetHandBook, "list1"):removeAllItems()
    CSResourceMgr.removeCSObjectByTag(resNamePetHandBook)
    CSResourceMgr.removeCSObjectByTag(resNameBg,"PetHandBookBg")
    PersonalCenterMgr.setResVisible(true)
    SceneMgr.setMapVisible(true)
end

local function setMyPets()
    local myPets =  PokemonInfo.getAllPets()
end

local function addUI(scene)
	if CSResourceMgr.getCsbObj(resNamePetHandBook) then
		return
	end
	
    local bgUI = CSResourceMgr.createRes(scene,resNameBg,"PetHandBookBg")
	local csb = CSResourceMgr.createRes(scene,resNamePetHandBook)
	
	local function loadBG()
		bgUI:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
		CSResourceMgr.setRelativePosition(resNameBg,320,480,"PetHandBookBg")
	end
	
	local function loadCSB()
		csb:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
		CSResourceMgr.setRelativePosition(resNamePetHandBook,320,480)
        CocosModuleMgr.setEdgeDistance(csb,nil,nil,nil,0) 
		csb:setVisible(false)

        
		--close 按钮
        --CSResourceMgr.getNodeByName(resNamePetHandBook,"close"):setVisible(false)
		--CSResourceMgr.clickEventBinding(resNamePetHandBook,"close",function() 
		--	hideUI()
		--end)
	end
	
	local function playCSB()
	   
		CSResourceMgr.getCsbObj(resNamePetHandBook):setVisible(true)
        GameAudio.playUISound("popup")
		CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resNamePetHandBook), "up")
        StatusBarMgr.showTopInfoBar(function()
            --hideUI()
            PetHandBook.hide()
       end,1)
	end
    
    local function initPokeDexData()
        resetListCell(pokemonInfoLst)
    end
  
    initPokeMonDataInfo()
    
    
    loadBG()
    loadCSB()
    initUIBaseData()
    resetListCell(pokemonInfoLst)
   
    playCSB()
    buttonBinding()

   -- local funcTable = {loadBG,loadCSB,playCSB, initUIBaseData,initPokeDexData,buttonBinding}
    
   -- UnblockLoader.load(funcTable, "PetHandBook")

end
---------------------------------我是分割线------------------------------------
function PetHandBook.Init()
	resNamePetHandBook = "Pet/HandBook/PetHandBook.csb"
    resNameBg = "Pet/Formation/FormationBGNew.csb"
    if pokemonInfoLst == nil or pokemonTypeInfoLst == nil then --如果没有初始化过，初始化
        pokemonInfoLst,pokemonTypeInfoLst = PokemonInfo.getPokemonInfoAllID()
	end
	petWikiList = {}
end

function PetHandBook.hide()
    hideUI()
   
end

function PetHandBook.show(scene)
    UIStack.push("PetHandBook",PetHandBook.hide,true)
	addUI(scene)
    SceneMgr.setMapVisible(false)	
    PersonalCenterMgr.setResVisible(false)
end

function PetHandBook.SetPetWikiInfo(petWiki)
    for k,v in pairs(petWiki) do
        petWikiList[v] = v
    end
end

function PetHandBook.getPetWikiInfoLst()
    return petWikiList
end

function PetHandBook.addPetToHandBook(pokeId)
    petWikiList[pokeId] = pokeId
end

function PetHandBook.setVisible(visible)
    
    if  CSResourceMgr.getCsbObj(resNamePetHandBook) then
        CSResourceMgr.getCsbObj(resNamePetHandBook):setVisible(visible)
        if visible == false then
            StatusBarMgr.hideTopInfoBar()
        else
            
            StatusBarMgr.showTopInfoBar(function()
                --hideUI()
                PetHandBook.hide()
            end)
        end
    end
end


return PetHandBook