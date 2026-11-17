local MyFamilyLstViewMgr = {}

--vesion number 1.0
--@client side NyFamilyListViewMgr.lua
--[[
这个文件是我的家族列表界面
--]]
--script writer Leon Lee
--creation time 2016-4-22


--类成员函数
MyFamilyLstViewMgr.famliyMemberLst = {}
--const
local CONST_PERPAGE_NUM = 6

local trans_myfamilylst = "family28"--"我的家族"
local trans_familymember = "family48"--"家族成员"
local trans_familylst= "family24"--"家族列表"
local trans_familyrequestlst = "family44"--"申请列表"
local trans_familyjidi = "family49"--"前往基地"
local trans_familyhyd = "tips39"--"家族贡献度"
local trans_loginlabel = "family36"--"上次登录时间:"
local trans_jobtitle = "family37"--"职位:"
local trans_familynotice = "family38"--"家族公告"
local trans_loginstr = "family39"--"未登陆"
local trans_elder = "family32"--"长老"
local trans_manager = "family33"--"管理员"
local trans_nojob = "family42"--"无职位"
local trans_creater ="family43" --"族长"
local trans_needcheck = "family2"--"手动确认"
local trans_noneedcheck = "family1"--"自动确认"
local trans_jzzz = "family50"--"家族宗旨: "
local trans_jzgg = "family38"--"家族公告: "
local trans_defaultjzgg = "family58"

---------------------------------我是分割线------------------------------------

--ui初始化信息
local resNameMyFamilyLst = ""
local resNameBg = ""



local fontInfo = {
    txt_title ={
        have_selstate = false, --是否有选中态
        outline_width = 2,
        font_color = {r =144,g=238,b=255,a=255},
        outline_color = {r =38,g=54,b=76,a=255},
        text = trans_myfamilylst
    },
    
    txt_playername = {
        have_selstate = false, --是否有选中态
        outline_width = 1,
        font_color = {r =255,g=252,b=0,a=255},
        outline_color = {r =0,g=0,b=0,a=255},
        text = "no data"   
    },
    
    txt_population = {
        have_selstate = false, --是否有选中态
        outline_width = 1,
        font_color = {r =144,g=238,b=255,a=255},
        outline_color = {r =0,g=0,b=0,a=255},
        text = "no data"          
    },
    
    txt_fightingpower = {
        have_selstate = false, --是否有选中态
        outline_width = 1,
        font_color = {r =144,g=238,b=255,a=255},
        outline_color = {r =0,g=0,b=0,a=255},
        text = "no data"      
    },
    
    txt_coin = {
        have_selstate = false, --是否有选中态
        outline_width = 1,
        font_color = {r =144,g=238,b=255,a=255},
        outline_color = {r =0,g=0,b=0,a=255},
        text = "no data"      
    },
    
    
    txt_familynotice = {
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =196,g=230,b=252,a=255},
        outline_color = {r =0,g=0,b=0,a=255},
        text = trans_familynotice    
    },
    --[[
    txt_noticecont={
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =196,g=230,b=252,a=255},
        outline_color = {r =0,g=0,b=0,a=255},
        text = "no data"     
    },
    ]]
    txt_member={
        have_selstate = false, --是否有选中态
        outline_width = 2,
        font_color = {r =255,g=255,b=255,a=255},
        outline_color = {r =71,g=138,b=194,a=255},
        text = trans_familymember         
    },
    
    txt_familylst = {
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =227,g=233,b=255,a=255},
        outline_color = {r =0,g=0,b=0,a=255},
        text = trans_familylst       
    },
    
    txt_requestlst = {
    
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =227,g=233,b=255,a=255},
        outline_color = {r =0,g=0,b=0,a=255},
        text = trans_familyrequestlst        
    },
    
    txt_familybase = {
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =227,g=233,b=255,a=255},
        outline_color = {r =0,g=0,b=0,a=255},
        text = trans_familyjidi      
    },
    
    txt_icontitle = {
        have_selstate = false, --是否有选中态
        outline_width = 1,
        font_color = {r =227,g=233,b=255,a=255},
        outline_color = {r =0,g=0,b=0,a=255},
        text = ""          
    },
    
    txt_level = {
        have_selstate = false, --是否有选中态
        outline_width = 1,
        font_color = {r =255,g=252,b=0,a=255},
        outline_color = {r =0,g=0,b=0,a=255},
        text = "LV0"       
        
    },
    
    txt_jobcont = {
        have_selstate = false, --是否有选中态
        outline_width = 1,
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
	
	txt_joinway = {
        have_selstate = false, --是否有选中态
        outline_width = 1,
        font_color = {r =144,g=238,b=255,a=255},
        outline_color = {r =0,g=0,b=0,a=255},
        text = trans_needcheck	
	
	}
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



local function resizePosY(resizeTable)
    local diff = CocosModuleMgr.getScreenSizeDiff()
    for i= 1,#resizeTable do
        local resizecell = CSResourceMgr.getNodeByName(resNameMyFamilyLst, resizeTable[i])
        local cposy = resizecell:getPositionY()
        resizecell:setPositionY(cposy+diff)
    end
end

--根据屏幕适配尺寸
local function resize()

    local diff = CocosModuleMgr.getScreenSizeDiff()
    local frame = CSResourceMgr.getNodeByName(resNameMyFamilyLst, "frame")
    local fsize = frame:getContentSize()
    frame:setContentSize(fsize.width, fsize.height+diff)

    local diban = CSResourceMgr.getNodeByName(resNameMyFamilyLst, "panel_diwen")
    local dbsize = diban:getContentSize()
    diban:setContentSize(dbsize.width, dbsize.height+diff)

    local listbg1 = CSResourceMgr.getNodeByName(resNameMyFamilyLst, "pic_listbg1")
    dbsize = listbg1:getContentSize()
    listbg1:setContentSize(dbsize.width, dbsize.height+diff)

    local listbg2 = CSResourceMgr.getNodeByName(resNameMyFamilyLst, "pic_listbg2")
    dbsize = listbg2:getContentSize()
    listbg2:setContentSize(dbsize.width, dbsize.height+diff)

    local list1 = CSResourceMgr.getNodeByName(resNameMyFamilyLst, "list1")
    dbsize = list1:getContentSize()
    list1:setContentSize(dbsize.width, dbsize.height+diff)
    list1:setVisible(true)

    local title = CSResourceMgr.getNodeByName(resNameMyFamilyLst, "txt_title")
    local tposy = title:getPositionY()
    title:setPositionY(tposy+diff)
    local close = CSResourceMgr.getNodeByName(resNameMyFamilyLst, "close")
    local cposy = close:getPositionY()
    close:setPositionY(cposy+diff)


    --dbsize = list1:getContentSize()
    --list1:setContentSize(dbsize.width, dbsize.height+diff)
 
    local resizetable = {}
    table.insert(resizetable,"pic_topbg")
    table.insert(resizetable,"pic_familyicon")
    table.insert(resizetable,"txt_playername")
    table.insert(resizetable,"pic_populationbg")
    table.insert(resizetable,"txt_population")
    table.insert(resizetable,"pic_population")
    table.insert(resizetable,"pic_fightingbg")
    table.insert(resizetable,"txt_fightingpower")
    table.insert(resizetable,"pic_fighting")
    table.insert(resizetable,"pic_coinbg")    
    table.insert(resizetable,"txt_coin")    
    table.insert(resizetable,"pic_coin")    
    table.insert(resizetable,"txt_familynotice")    
    --table.insert(resizetable,"txt_noticecont")  
    table.insert(resizetable,"pic_memberbg")   
    table.insert(resizetable,"txt_member")   
    table.insert(resizetable,"pic_joinbg")
    table.insert(resizetable,"pic_joinicon")
    table.insert(resizetable,"txt_joinway")	
    resizePosY(resizetable)
end

local function hideUI()
    GameAudio.playUISound("retract")
	UnblockLoader.cancel("MyFamilyListViewMgr.loadlist")
    SceneMgr.setMapVisible(true)
    local list1 = CSResourceMgr.getNodeByName(resNameMyFamilyLst,"list1") 
    if list1 then
        list1:removeAllItems()
    end

    CSResourceMgr.removeCSObjectByTag(resNameMyFamilyLst)
    CSResourceMgr.removeCSObjectByTag(resNameBg,"MyFamilyLstBg")
    UIStack.pop("MyFamilyLstViewMgr")
end

function MyFamilyLstViewMgr.refreshUIBaseData(info)
    if CSResourceMgr.getCsbObj(resNameMyFamilyLst) and info ~= nil then
        if info.icon ~= nil then
            local familyicon = CSResourceMgr.getNodeByName(resNameMyFamilyLst,"pic_familyicon")
            CSResourceMgr.setButtonTextureByNode(familyicon,info.icon,info.icon,info.icon)
            CSResourceMgr.setSpriteTexture(resNameMyFamilyLst, "pic_coin", string.sub(info.icon, 1, -5).."_hz.png")
        end
        --if info.purpose ~= nil then
            fontInfo.txt_familynotice.text = LuaSqlite.getLanguageByKey(trans_jzgg)--info.notice
        --end
        if info.notice ~= nil and info.notice~="" then
            fontInfo.txt_familynotice.text = fontInfo.txt_familynotice.text..info.notice
        else
            fontInfo.txt_familynotice.text = fontInfo.txt_familynotice.text..LuaSqlite.getLanguageByKey(trans_defaultjzgg)
        end
        
        if info.needCheckJoin ~= nil then
            local needCheckJoin = tonumber(info.needCheckJoin)
            if needCheckJoin == 1 then
                fontInfo.txt_joinway.text = trans_needcheck
            else
                fontInfo.txt_joinway.text = trans_noneedcheck
            end
        end
        
        for k,v in pairs(fontInfo) do 
            local concatstr = ""..k

            if concatstr ~= "txt_familynotice" then
                local txtcell = CSResourceMgr.getNodeByName(resNameMyFamilyLst,concatstr)
                --print(v.text)
                setLabel(txtcell,v.text,v.outline_color,v.outline_width,v.font_color)
            else
                local input = CSResourceMgr.getNodeByName(resNameMyFamilyLst, "txt_familynotice")
                input:setString(v.text)
            end
        end
    end
end

function MyFamilyLstViewMgr.initUIBaseData()
    if CSResourceMgr.getCsbObj(resNameMyFamilyLst) then
        local info =  FamilyInfo.GetLocalFamilyInfo()
        if info == nil then
            return
        end

        local familyicon = CSResourceMgr.getNodeByName(resNameMyFamilyLst,"pic_familyicon")
        CSResourceMgr.setButtonTextureByNode(familyicon,info.icon,info.icon,info.icon)
        CSResourceMgr.setSpriteTexture(resNameMyFamilyLst, "pic_coin", string.sub(info.icon, 1, -5).."_hz.png")
        --familyicon:loadTexture(info.icon)
        CSResourceMgr.clickEventBindingByNode(familyicon,function() 
            FamilyInfoMgr.show(SceneMgr.getRunningScene)
        end,3)
        fontInfo.txt_playername.text = info.name.." Lv"..((info.familyLevel ~= nil and tostring(info.familyLevel) or "1").." Id"..(info._id or 0))
        fontInfo.txt_coin.text = (info.familyCoin ~= nil and tostring(info.familyCoin) or "0")
        fontInfo.txt_familynotice.text = LuaSqlite.getLanguageByKey(trans_jzgg)--LuaSqlite.getLanguageByKey(trans_jzzz)..":"..info.purpose
        
        if info.notice ~= nil and info.notice~="" then
            fontInfo.txt_familynotice.text = fontInfo.txt_familynotice.text..info.notice
        else
            fontInfo.txt_familynotice.text = fontInfo.txt_familynotice.text..LuaSqlite.getLanguageByKey(trans_defaultjzgg)
        end
        
        fontInfo.txt_population.text = ""..info.memberCount.."/"..tostring(30 + (info.familyLevel or 1)*4)
        
    	local needCheckJoin = tonumber(info.needCheckJoin)
    	if needCheckJoin == 1 then
    		fontInfo.txt_joinway.text = trans_needcheck
    	else
    		fontInfo.txt_joinway.text = trans_noneedcheck
    	end
       
        ---------------------------
        --@param
        --@return
        local  function setShowApplyButton()
            local applybtn = CSResourceMgr.getNodeByName(resNameMyFamilyLst,"btn_requestlst")
            local requesttxt = CSResourceMgr.getNodeByName(resNameMyFamilyLst,"txt_requestlst")
            local job = FamilyInfo.GetJobByMemberID(CharInfo.getCharID())
            local familylstbtn = CSResourceMgr.getNodeByName(resNameMyFamilyLst,"btn_familylst")
            local familybasebtn = CSResourceMgr.getNodeByName(resNameMyFamilyLst,"btn_familybase")
            local familylsttxt = CSResourceMgr.getNodeByName(resNameMyFamilyLst,"txt_familylst") 
            local familybasetxt =   CSResourceMgr.getNodeByName(resNameMyFamilyLst,"txt_familybase")      
            if job == FamilyInfo.JobType.Job_Member then
    		  applybtn:setVisible(false)
    		  requesttxt:setVisible(false)
                familylstbtn:setPositionX(118+60)
                familylsttxt:setPositionX(117+60)
               familybasebtn:setPositionX(487-60)
                familybasetxt:setPositionX(488-60)
               
    		end
    		--[[
        	local mycharid = CharInfo.getCharID()
        	if mycharid == info.leaderID then
        	   applybtn:setVisible(true)
        	   requesttxt:setVisible(true)
        	else
    			if info.elders~= nil then --长老
    				for k,v in pairs(info.elders) do 
    					if tonumber(k) == mycharid then
    						applybtn:setVisible(true)
    						requesttxt:setVisible(true)						
    						break
    					end
    				end
    			end
    
                if info.managers~= nil then --管理员
    				for k,v in pairs(info.managers) do 
    					if tonumber(k) == mycharid then
    						applybtn:setVisible(true)
    						requesttxt:setVisible(true)						
    						break
    					end
    				end
    			end
        	end
        	]]--
        end
        
        for k,v in pairs(fontInfo) do 
            local concatstr = ""..k
           
            if concatstr ~= "txt_familynotice" then
                local txtcell = CSResourceMgr.getNodeByName(resNameMyFamilyLst,concatstr)
                --print(v.text)
                setLabel(txtcell,v.text,v.outline_color,v.outline_width,v.font_color)
            else
                local input = CSResourceMgr.getNodeByName(resNameMyFamilyLst, "txt_familynotice")
                input:setString(v.text)
            end
        end
        
        setShowApplyButton()
    end
end 


local function createListCell(data, rank, total)

    local function setCellData(data)
        fontInfo.txt_icontitle.text = data.name
        fontInfo.txt_level.text = "LV"..data.level
        if data.logoutTime~=nil then
            local timestr = data.logoutTime["$date"]
            fontInfo.txt_logincont.text = string.sub(timestr,0,10)
        end
        
        local job = FamilyInfo.GetJobByMemberID(data.charID)
        if job == FamilyInfo.JobType.Job_Leader then
            fontInfo.txt_jobcont.text = trans_creater
        elseif job == FamilyInfo.JobType.Job_Elder then
            fontInfo.txt_jobcont.text = trans_elder
        elseif job == FamilyInfo.JobType.Job_Master then
            fontInfo.txt_jobcont.text = trans_manager
        else
            fontInfo.txt_jobcont.text = trans_nojob
        end
        --[[
        local info =  FamilyInfo.GetLocalFamilyInfo()
        local charid = data.charID
        
        if info.leaderID == data.charID then
            fontInfo.txt_jobcont.text = trans_creater   
        else
            fontInfo.txt_jobcont.text = trans_nojob        
        end
        
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
        ]]--
    end
    
    setCellData(data)
    local listcell = CSResourceMgr.getNodeByName(resNameMyFamilyLst,"btn_listexample"):clone()

    local listtitlebg = CSResourceMgr.seekNodeByName(listcell,"pic_listtitlebg")
    listtitlebg:setColor(bgImageColorInfo.pic_listtitlebg.color_default)


    local listiconbg = CSResourceMgr.seekNodeByName(listcell,"pic_listiconbg")
    listiconbg:setColor(bgImageColorInfo.pic_listiconbg.color_default)

    local hydbg = CSResourceMgr.seekNodeByName(listcell,"pic_hydbg")
    hydbg:setColor(bgImageColorInfo.pic_hydbg.color_default)
    --hydbg:setColor({r=0,g=0,b=0})
    --print("sui bia jia de" ..hydbg)
   

    local hydtitle = CSResourceMgr.seekNodeByName(listcell,"txt_hydtitle")
    setLabel(hydtitle,CocosModuleMgr.createStringWithFormat({fontInfo.txt_hydtitle.text,rank}),fontInfo.txt_hydtitle.outline_color,fontInfo.txt_hydtitle.outline_width,fontInfo.txt_hydtitle.font_color,nil,100)

    local hydnum = CSResourceMgr.seekNodeByName(listcell,"txt_hydnum")
    local devotePoint = data.devotePoint or 0
    --[[
    if data.validDevote == true then
        devotePoint = data.devotePoint
    end
    ]]
    setLabel(hydnum,tostring(devotePoint),fontInfo.txt_hydnum.outline_color,fontInfo.txt_hydnum.outline_width,fontInfo.txt_hydnum.font_color)

    local icontitle = CSResourceMgr.seekNodeByName(listcell,"txt_icontitle")
    setLabel(icontitle,fontInfo.txt_icontitle.text,fontInfo.txt_icontitle.outline_color,fontInfo.txt_icontitle.outline_width,fontInfo.txt_icontitle.font_color)

    local joblabel = CSResourceMgr.seekNodeByName(listcell,"txt_joblabel")
    setLabel(joblabel,fontInfo.txt_joblabel.text,fontInfo.txt_joblabel.outline_color,fontInfo.txt_joblabel.outline_width,fontInfo.txt_joblabel.font_color,nil,45)

    local jobcont = CSResourceMgr.seekNodeByName(listcell,"txt_jobcont")
    setLabel(jobcont,fontInfo.txt_jobcont.text,fontInfo.txt_jobcont.outline_color,fontInfo.txt_jobcont.outline_width,fontInfo.txt_jobcont.font_color,nil,100)

    local loginlabel = CSResourceMgr.seekNodeByName(listcell,"txt_loginlabel")
    setLabel(loginlabel,fontInfo.txt_loginlabel.text,fontInfo.txt_loginlabel.outline_color,fontInfo.txt_loginlabel.outline_width,fontInfo.txt_loginlabel.font_color,nil,100)    

    local logincont = CSResourceMgr.seekNodeByName(listcell,"txt_logincont")
    setLabel(logincont,fontInfo.txt_logincont.text,fontInfo.txt_logincont.outline_color,fontInfo.txt_logincont.outline_width,fontInfo.txt_logincont.font_color,nil,100) 

    local level = CSResourceMgr.seekNodeByName(listcell,"txt_level")
    setLabel(level,fontInfo.txt_level.text,fontInfo.txt_level.outline_color,fontInfo.txt_level.outline_width,fontInfo.txt_level.font_color) 

	local pic = CSResourceMgr.seekNodeByName(listcell,"pic_icon")
	
	local fashionInfo = ItemInfo.getFashionItemInfoById(data.fashion.curFashion[1])
	pic:loadTexture(fashionInfo.filePath)
	
    local percent = FamilyDataInfo.getFamilyDevoteBufferInfoById(total - rank + 1).bufferRate/100
    local fightlabel = CSResourceMgr.seekNodeByName(listcell,"txt_fightingpercent")
    CSResourceMgr.setLabelStringByNode(fightlabel, "+"..CocosModuleMgr.createStringWithFormat({"home013", percent}),{r =0,g=0,b=0,a=255,w=1})
	
	CSResourceMgr.clickEventBindingByNode(listcell,function() 
        FamilyPlayerViewMgr.show(SceneMgr.getRunningScene, data.charID, data.name)
	end)
	
    return listcell
end

local function createListCellFromApplyData(data) --根据申请列表的数据创建列表
    local function setCellData(data)
        fontInfo.txt_icontitle.text = data.name
        fontInfo.txt_level.text = "LV "..data.level
        
        fontInfo.txt_jobcont.text = trans_nojob
        fontInfo.txt_hydnum.text = tostring(data.devotePoint or 0)
        --[[
        local info =  FamilyInfo.GetLocalFamilyInfo()
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
        ]]--
    end
    
    setCellData(data)
    local listcell = CSResourceMgr.getNodeByName(resNameMyFamilyLst,"btn_listexample"):clone()

    local listtitlebg = CSResourceMgr.seekNodeByName(listcell,"pic_listtitlebg")
    listtitlebg:setColor(bgImageColorInfo.pic_listtitlebg.color_default)


    local listiconbg = CSResourceMgr.seekNodeByName(listcell,"pic_listiconbg")
    listiconbg:setColor(bgImageColorInfo.pic_listiconbg.color_default)

    local hydbg = CSResourceMgr.seekNodeByName(listcell,"pic_hydbg")
    hydbg:setColor(bgImageColorInfo.pic_hydbg.color_default)
    --hydbg:setColor({r=0,g=0,b=0})
    --print("sui bia jia de" ..hydbg)
   

    local hydtitle = CSResourceMgr.seekNodeByName(listcell,"txt_hydtitle")
    setLabel(hydtitle,fontInfo.txt_hydtitle.text,fontInfo.txt_hydtitle.outline_color,fontInfo.txt_hydtitle.outline_width,fontInfo.txt_hydtitle.font_color,nil,100)

    local hydnum = CSResourceMgr.seekNodeByName(listcell,"txt_hydnum")
    setLabel(hydnum,fontInfo.txt_hydnum.text,fontInfo.txt_hydnum.outline_color,fontInfo.txt_hydnum.outline_width,fontInfo.txt_hydnum.font_color)

    local icontitle = CSResourceMgr.seekNodeByName(listcell,"txt_icontitle")
    setLabel(icontitle,fontInfo.txt_icontitle.text,fontInfo.txt_icontitle.outline_color,fontInfo.txt_icontitle.outline_width,fontInfo.txt_icontitle.font_color)

    local joblabel = CSResourceMgr.seekNodeByName(listcell,"txt_joblabel")
    setLabel(joblabel,fontInfo.txt_joblabel.text,fontInfo.txt_joblabel.outline_color,fontInfo.txt_joblabel.outline_width,fontInfo.txt_joblabel.font_color,nil,45)

    local jobcont = CSResourceMgr.seekNodeByName(listcell,"txt_jobcont")
    setLabel(jobcont,fontInfo.txt_jobcont.text,fontInfo.txt_jobcont.outline_color,fontInfo.txt_jobcont.outline_width,fontInfo.txt_jobcont.font_color,nil,100)

    local loginlabel = CSResourceMgr.seekNodeByName(listcell,"txt_loginlabel")
    setLabel(loginlabel,fontInfo.txt_loginlabel.text,fontInfo.txt_loginlabel.outline_color,fontInfo.txt_loginlabel.outline_width,fontInfo.txt_loginlabel.font_color,nil,100)    

    local logincont = CSResourceMgr.seekNodeByName(listcell,"txt_logincont")
    setLabel(logincont,fontInfo.txt_logincont.text,fontInfo.txt_logincont.outline_color,fontInfo.txt_logincont.outline_width,fontInfo.txt_logincont.font_color,nil,100) 

    local level = CSResourceMgr.seekNodeByName(listcell,"txt_level")
    setLabel(level,fontInfo.txt_level.text,fontInfo.txt_level.outline_color,fontInfo.txt_level.outline_width,fontInfo.txt_level.font_color) 

	local pic = CSResourceMgr.seekNodeByName(listcell,"pic_icon")
	
	local fashionInfo = ItemInfo.getFashionItemInfoById(data.fashion.curFashion[1])
	pic:loadTexture(fashionInfo.filePath)
	
	CSResourceMgr.clickEventBindingByNode(listcell,function() 
        FamilyPlayerViewMgr.show(SceneMgr.getRunningScene, data.charID, data.name)
	end)
	
    return listcell	
end

local function resetListCellTable(datalist)
   -- print("#datalist......" ..MyFamilyLstViewMgr.famliyLstJsonStr)
    local list1 = CSResourceMgr.getNodeByName(resNameMyFamilyLst,"list1")
    list1:removeAllItems()
	
	local funcTable = {}
	UnblockLoader.cancel("MyFamilyListViewMgr.loadlist")
    if datalist ~= nil then
        local selfIdx = -1
        for i=1, #datalist do
            if datalist[i].charID == CharInfo.getCharID() then
                table.insert(funcTable,function() 
                    local listcell = createListCell(datalist[i], i, #datalist)
                    listcell:setScaleY(0)
                    list1:pushBackCustomItem(listcell)
                    transition.scaleTo(listcell,{scale=1.0,time = 0.1})
                end)
                selfIdx = i
                break
            end
        end

        for i=1, #datalist do
            if i ~= selfIdx then
    			table.insert(funcTable,function() 
                    local listcell = createListCell(datalist[i], i, #datalist)
    				listcell:setScaleY(0)
    				list1:pushBackCustomItem(listcell)
    				transition.scaleTo(listcell,{scale=1.0,time = 0.1})
    			end)
            end
        end   
		 UnblockLoader.load(funcTable,"MyFamilyListViewMgr.loadlist")
    end
end

local function addUI(scene)
    if CSResourceMgr.getCsbObj(resNameMyFamilyLst) then
        return
    end
    
    SceneMgr.setMapVisible(false) 
    
    local bgUI = CSResourceMgr.createRes(scene,resNameBg ,"MyFamilyLstBg")
    local csbUI = CSResourceMgr.createRes(scene,resNameMyFamilyLst)
    
    local function loadBG()

        bgUI:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBg, 320, 480,"MyFamilyLstBg")
    end    
    
    local function loadCSB()
        csbUI:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        csbUI:setVisible(false)
        CSResourceMgr.setRelativePosition(resNameMyFamilyLst, 320, 480)   
        CocosModuleMgr.setEdgeDistance(csbUI,nil,nil,nil,0) 
        resize()
        MyFamilyLstViewMgr.initUIBaseData()

        
        --close按钮绑定
        CSResourceMgr.clickEventBinding(resNameMyFamilyLst,"close",function()
            hideUI()
        end)
    end
    
    local function playCSB()
        CSResourceMgr.getCsbObj(resNameMyFamilyLst):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resNameMyFamilyLst), "up", function()
            end)

    end
	

		
    local function buttonBinding()
        local familybase = CSResourceMgr.getNodeByName(resNameMyFamilyLst,"btn_familybase")
        CSResourceMgr.clickEventBindingByNode(familybase,function()
            hideUI()
            FamilyInfo.GoHome()
        end)
        
		local familylst = CSResourceMgr.getNodeByName(resNameMyFamilyLst,"btn_familylst")
        CSResourceMgr.clickEventBindingByNode(familylst,function()
			hideUI()
			FamilyListViewMgr.show(SceneMgr.getRunningScene)
		end)
		
		local requestlst = CSResourceMgr.getNodeByName(resNameMyFamilyLst,"btn_requestlst")
        CSResourceMgr.clickEventBindingByNode(requestlst,function()
            FamilyApplyListViewMgr.show(scene)        
        end
        )
    end
    
    loadBG()
    loadCSB()
    playCSB()
    buttonBinding()
end

local function request(scene)
    --local function callback()
        addUI(scene)
    
    --end
    FamilyInfo.QueryMyFamily(true)
    FriendsViewMgr.getAllFriendToChat()
end
---------------------------------我是分割线------------------------------------
---类函数
function MyFamilyLstViewMgr.Init()
    resNameMyFamilyLst= "Player/Family/MyFamilyList.csb"
    resNameBg = "Pet/Formation/FormationBG.csb"
end

function MyFamilyLstViewMgr.show(scene)
    GameAudio.playUISound("popup")
    UIStack.push("MyFamilyLstViewMgr",MyFamilyLstViewMgr.hide,false)
    request(scene)
end

function MyFamilyLstViewMgr.refreshMemberList(members)
    MyFamilyLstViewMgr.famliyMemberLst = members
    print("famliyMemberLst "..sz_T2S(members))
    local info =  FamilyInfo.GetLocalFamilyInfo()
    if CSResourceMgr.getCsbObj(resNameMyFamilyLst) then
        local cjson = require("cjson")
        --local members = cjson.decode(MyFamilyLstViewMgr.famliyMemberLstJsonStr)
        local tbl = {}
        local familyFightPoint = 0
        for k,v in pairs(members) do
            --[[
            if v.devotePoint == nil then
                v.devotePoint = 0
                v.validDevote = false
            else
                if tonumber(v.lastSetDevotePointTime or 0) > (info ~= nil and tonumber(info.lastDevoteRefreshTime or 0) or 0) then
                    v.validDevote = true
                else
                    v.validDevote = false
                end
            end
            ]]
            tbl[#tbl + 1] = v
            familyFightPoint = familyFightPoint + (v.fightPoint or 0)
        end
        print("==========DevoteTable="..sz_T2S(tbl))
        
        --[[
        table.sort(tbl, function(a, b)
            if a.validDevote ~= b.validDevote then
                return a.validDevote
            else
                return a.devotePoint > b.devotePoint
            end
        end)
        ]]
        table.sort(tbl, function(a, b)
            local job_a = FamilyInfo.GetJobByMemberID(a.charID)
            local job_b = FamilyInfo.GetJobByMemberID(b.charID)
            return job_a < job_b
        end)
        
        local txtcell = CSResourceMgr.getNodeByName(resNameMyFamilyLst,"txt_fightingpower")
        fontInfo.txt_fightingpower.text = tostring(familyFightPoint)
        setLabel(txtcell,familyFightPoint,fontInfo.txt_fightingpower.outline_color,fontInfo.txt_fightingpower.outline_width,fontInfo.txt_fightingpower.font_color)
        resetListCellTable(tbl)
    end
end

function MyFamilyLstViewMgr.addNewMemberFromApplyLst(data)
    if CSResourceMgr.getCsbObj(resNameMyFamilyLst) then
        --local listcell = createListCellFromApplyData(data)
    	--local list1 = CSResourceMgr.getNodeByName(resNameMyFamilyLst,"list1")
    	--list1:pushBackCustomItem(listcell)
        FamilyInfo.QueryMyFamily(true)
	end
end

function MyFamilyLstViewMgr.hide()
    hideUI()
end

function MyFamilyLstViewMgr.IsOpen()
    return CSResourceMgr.getCsbObj(resNameMyFamilyLst)
end

return MyFamilyLstViewMgr