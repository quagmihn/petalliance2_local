--vesion number 1.0
--@client side LifeSkillJobChangeViewMgr.lua
--[[
这个文件是生活技能切换职业列表
--]]
--script writer Leon Lee
--creation time 2016-3-16

local LifeSkillJobChangeViewMgr = {}
--翻译
local trans_changejob = "lifeSkill020"--"切换职业"
local trans_changgejobtxt= "lifeSkill021"--"是否确认切换成"
local trans_di = "lifeSkill022"--"第"(已经修改成整句话的RICHLABEL)
local trans_ci = "lifeSkill023"--"次"
local trans_xiaohao = "lifeSkill024"--"需消耗:"

--数据层


---------------------------------我是分割线------------------------------------
--ui初始化信息
local resNameLifeSkillJobChange =  "" --列表UI资源

local fontInfo = {--该界面所有的文本格式信息，用于界面设置
    txt_dbtitle ={
        have_selstate = false, --是否有选中态
        outline_width = 2,
        font_color = {r =144,g=238,b=255,a=255},
        outline_color = {r =38,g=54,b=76,a=255},
        text = trans_changejob
    },
    
    
    txt_mcashnum ={
        have_selstate = false, --是否有选中态
        outline_width = 1,
        font_color = {r =217,g=234,b=255,a=255},
        outline_color = {r =11,g=17,b=67,a=255},
        text = "nodata"
    },
 
    txt_jobchange ={
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =217,g=234,b=255,a=255},
        outline_color = {r =11,g=17,b=67,a=255},
        text = trans_changgejobtxt
    },  
    
    txt_jobname ={
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =217,g=234,b=255,a=255},
        outline_color = {r =11,g=17,b=67,a=255},
        text = "nodata"
    }, 
    
    txt_di ={
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =217,g=234,b=255,a=255},
        outline_color = {r =11,g=17,b=67,a=255},
        text = trans_di
    },    
    
    
    txt_ci ={
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =217,g=234,b=255,a=255},
        outline_color = {r =11,g=17,b=67,a=255},
        text = trans_ci
    },  
    
    txt_qienum ={
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =255,g=204,b=0,a=255},
        outline_color = {r =11,g=17,b=67,a=255},
        text = "nodata"
    }, 
    
    
    txt_xhnum ={
        have_selstate = false, --是否有选中态
        outline_width = 1,
        font_color = {r =255,g=255,b=255,a=255},
        outline_color = {r =0,g=0,b=0,a=255},
        text = "nodata"
    }, 
    
    
    txt_changejob ={
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =217,g=234,b=255,a=255},
        outline_color = {r =11,g=17,b=67,a=255},
        text = trans_changejob
    }, 
    
    txt_xiaohao ={
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =217,g=234,b=255,a=255},
        outline_color = {r =11,g=17,b=67,a=255},
        text = trans_xiaohao
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
    CSResourceMgr.removeCSObjectByTag(resNameLifeSkillJobChange)
end

local function addUI(scene,uidata,isfirst)

    local function loadCSB()
    
        local csbUI = CSResourceMgr.createRes(scene,resNameLifeSkillJobChange)
        csbUI:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameLifeSkillJobChange, 320, 480)  
        
        local txt_dbtitle = CSResourceMgr.getNodeByName(resNameLifeSkillJobChange,"txt_dbtitle")
        setLabel(txt_dbtitle,fontInfo.txt_dbtitle.text,fontInfo.txt_dbtitle.outline_color,fontInfo.txt_dbtitle.outline_width,fontInfo.txt_dbtitle.font_color)
        
        local txt_mcashnum = CSResourceMgr.getNodeByName(resNameLifeSkillJobChange,"txt_mcashnum")
        setLabel(txt_mcashnum,tostring(CharInfo.getMCash()),fontInfo.txt_mcashnum.outline_color,fontInfo.txt_mcashnum.outline_width,fontInfo.txt_mcashnum.font_color)
        
        --阿杜修改英文版显示
        if LuaSqlite.LANG_TYPE==1 then 
            local txt_jobchange =  CSResourceMgr.getNodeByName(resNameLifeSkillJobChange,"txt_jobchange")
            setLabel(txt_jobchange,fontInfo.txt_jobchange.text,fontInfo.txt_jobchange.outline_color,fontInfo.txt_jobchange.outline_width,fontInfo.txt_jobchange.font_color)
            
            local txt_jobname = CSResourceMgr.getNodeByName(resNameLifeSkillJobChange,"txt_jobname")
            setLabel(txt_jobname,uidata.jobname,fontInfo.txt_jobname.outline_color,fontInfo.txt_jobname.outline_width,fontInfo.txt_jobname.font_color)
        else
            local txt_jobchange =  CSResourceMgr.getNodeByName(resNameLifeSkillJobChange,"txt_jobchange")
            txt_jobchange:setAnchorPoint(0.5, 1)
            txt_jobchange:setPositionX(238)
            setLabel(txt_jobchange,LuaSqlite.getLanguageByKey(fontInfo.txt_jobchange.text)..LuaSqlite.getLanguageByKey(uidata.jobname),fontInfo.txt_jobchange.outline_color,nil,fontInfo.txt_jobchange.font_color)
        end
        
        
        local txt_di = CSResourceMgr.getNodeByName(resNameLifeSkillJobChange,"txt_di")
        --阿杜修改英文版显示
        local fontSize = LuaSqlite.LANG_TYPE==3 and 20 or 18
        local richLabel = CocosModuleMgr.createRichLabel(txt_di, CocosModuleMgr.createStringWithFormat({fontInfo.txt_di.text, tostring(uidata.changetimes)}),
                         fontSize, "cuyuan_GBK.ttf", TownChatMgr.MAX_LABEL_WIDTH,nil,nil,nil,true)

        local txt_xiaohao =  CSResourceMgr.getNodeByName(resNameLifeSkillJobChange,"txt_xiaohao")
        setLabel(txt_xiaohao,fontInfo.txt_xiaohao.text,fontInfo.txt_xiaohao.outline_color,fontInfo.txt_xiaohao.outline_width,fontInfo.txt_xiaohao.font_color)
        
        
        local txt_xhnum = CSResourceMgr.getNodeByName(resNameLifeSkillJobChange,"txt_xhnum")
        setLabel(txt_xhnum,tostring(uidata.needcash),fontInfo.txt_xhnum.outline_color,fontInfo.txt_xhnum.outline_width,fontInfo.txt_xhnum.font_color)
        
        

        local btnOk = CSResourceMgr.getNodeByName(resNameLifeSkillJobChange,"btn_ok")
        CSResourceMgr.setButtonStringByNode(btnOk, "LtYes",{r=0,g=0,b=0,a=255})
        CSResourceMgr.clickEventBindingByNode(btnOk,function()  
            GameAudio.playUISound("jobExchange")
            NetInterface.sendWithBlock("GC_ChangeLifeCareer_Ack",function() 
                local lifeSkillSend =  require("src.Net.Send.LifeSkillSend")
                lifeSkillSend.sendCG_ChangeLifeCareer_Req(uidata.jobid)
            end,function()
                hideUI() 
                if isfirst == nil then
                    LifeSkillLstViewMgr.refresh(1)
                else
                    LifeSkillSelViewMgr.hide()
                    LifeSkillLstViewMgr.show(scene)
                end
            end,

            function(code) 
                hideUI() 
                TipsMgr.showError(scene, code) 
            end)
        
        end)
        
        local btnCancel = CSResourceMgr.getNodeByName(resNameLifeSkillJobChange,"btn_cancel")
        CSResourceMgr.setButtonStringByNode(btnCancel, "LtNo",{r=0,g=0,b=0,a=255})
        CSResourceMgr.clickEventBindingByNode(btnCancel,function() 
            GameAudio.playUISound("retract")
            
            hideUI()
        end)
        
    end
    
    local function playCSB()
        GameAudio.playUISound("popup")
        local db = CSResourceMgr.getNodeByName(resNameLifeSkillJobChange,"db")
        db:setVisible(true)
      
        --CSResourceMgr.getNodeByName(resNameFilterPopup,"btn_close"):setVisible(true)
        CocosModuleMgr.showUIAnimation(db,"down")
      
    end
    
    loadCSB()
    playCSB()
end



---------------------------------我是分割线------------------------------------
function LifeSkillJobChangeViewMgr.Init()
    resNameLifeSkillJobChange = "Player/LifeSkill/LifeSkillJobChange.csb" 
end


--[[
uidata = {jobid = xx,changetimes = xx,jobname = xx,needcash = xx}
]]
function LifeSkillJobChangeViewMgr.show(scene,uidata,isfirst)
    scene = scene or SceneMgr.getRunningScene
    addUI(scene,uidata,isfirst)
end
return LifeSkillJobChangeViewMgr