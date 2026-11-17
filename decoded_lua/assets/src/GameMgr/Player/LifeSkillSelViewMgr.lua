--vesion number 1.0
--@client side LifeSkillSelViewMgr.lua
--[[
这个文件是生活技能选择界面,只有在第一次界面选择的时候才会有
--]]
--script writer Leon Lee
--creation time 2016-3-18

local LifeSkillSelViewMgr = {}

--翻译
local trans_szs = "lifeSkill003"--"时装师" 
local trans_jjs = "lifeSkill004"--"家具师"
local trans_zhs = "lifeSkill005"--"装潢师"
local trans_zyxz = "lifeSkill054"--"职业选择"
local trans_szdesc = "lifeSkill055"--"头饰、衣服、裤子、背饰、武器"
local trans_jjdesc= "lifeSkill056"--"床、衣柜、沙发、桌子、电视等"
local trans_zhdesc = "lifeSkill057"--"床、衣柜、沙发、桌子、电视等"
local trans_szdesccont = "lifeSkill058"--"时装师可以制作角色时装"
local trans_jjdesccont= "lifeSkill059"--"家具师可以制作家园家具"
local trans_zhdesccont =  "lifeSkill060"--"装潢师可以制作家园饰品"
local trans_notopen = "exchange049"
local tabTextArray = {trans_szs,trans_jjs,trans_zhs}

--数据层--
local skillChangeData = 
{
    [1]={jobid =1 ,changetimes = 1,jobname = tabTextArray[1],needcash = 0},
    [2]={jobid =2 ,changetimes = 1,jobname = tabTextArray[2],needcash =0} ,
    [3]={jobid =3 ,changetimes = 1,jobname = tabTextArray[3],needcash = 0},

}

--初始化
local function initSkillChangeData()
    local info = ExperienceInfo.getLifeSkillCareerChangeByID(1)
    local consume = ItemInfo.getConsumeElementInfoById(info.elemID)
    print("need cash..........."..consume.num)
    skillChangeData[1].needcash = consume.num
    skillChangeData[2].needcash = consume.num
    skillChangeData[3].needcash = consume.num
end


---------------------------------我是分割线------------------------------------
--ui初始化信息
local resNameLifeSkillSel =  "" --列表UI资源
local fontInfo = {--该界面所有的文本格式信息，用于界面设置
    txt_maintitle ={
        have_selstate = false, --是否有选中态
        outline_width = 2,
        font_color = {r =144,g=238,b=255,a=255},
        outline_color = {r =38,g=54,b=76,a=255},
        text = trans_zyxz
    },
    
    txt_job1title={
        have_selstate = false, --是否有选中态
        outline_width = 2,
        font_color = {r =255,g=255,b=255,a=255},
        outline_color = {r =169,g=71,b=194,a=255},
        text = trans_szs        
    
    },
    
    txt_job2title={
        have_selstate = false, --是否有选中态
        outline_width = 2,
        font_color = {r =255,g=255,b=255,a=255},
        outline_color = {r =71,g=138,b=194,a=255},
        text = trans_jjs        

    },
    
    txt_job3title={
        have_selstate = false, --是否有选中态
        outline_width = 2,
        font_color = {r =255,g=255,b=255,a=255},
        outline_color = {r =194,g=114,b=71,a=255},
        text = trans_zhs       

    },
    
    txt_job1destitle={
        have_selstate = false, --是否有选中态
        outline_width = 1,
        font_color = {r =255,g=255,b=255,a=255},
        outline_color = {r =93,g=71,b=103,a=255},
        text = trans_szdesc       

    },
    
    txt_job2destitle={
        have_selstate = false, --是否有选中态
        outline_width = 1,
        font_color = {r =255,g=255,b=255,a=255},
        outline_color = {r =71,g=140,b=194,a=255},
        text = trans_jjdesc       

    },
    
    txt_job3destitle={
        have_selstate = false, --是否有选中态
        outline_width = 1,
        font_color = {r =255,g=255,b=255,a=255},
        outline_color = {r =137,g=102,b=52,a=255},
        text = trans_zhdesc       

    },
    
    
    txt_job1descont={
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =93,g=71,b=103,a=255},
        outline_color = {r =93,g=71,b=103,a=255},
        text = trans_szdesccont      

    },

    txt_job2descont={
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =71,g=140,b=194,a=255},
        outline_color = {r =71,g=140,b=194,a=255},
        text = trans_jjdesccont       

    },

    txt_job3descont={
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =137,g=102,b=52,a=255},
        outline_color = {r =137,g=102,b=52,a=255},
        text = trans_zhdesccont       

    },
}


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




---关闭UI
local function  hideUI()
    UnblockLoader.cancel("LifeSkillSelViewMgr.show")
    CSResourceMgr.removeCSObjectByTag(resNameLifeSkillSel)
end

---初始化
local function initBaseUI()
    local mainTitle = CSResourceMgr.getNodeByName(resNameLifeSkillSel,"txt_maintitle")
    local jobTitle1 = CSResourceMgr.getNodeByName(resNameLifeSkillSel,"txt_job1title")
    local jobTitle2 = CSResourceMgr.getNodeByName(resNameLifeSkillSel,"txt_job2title")
    local jobTitle3 = CSResourceMgr.getNodeByName(resNameLifeSkillSel,"txt_job3title")
    local job1destitle = CSResourceMgr.getNodeByName(resNameLifeSkillSel,"txt_job1destitle")
    local job2destitle = CSResourceMgr.getNodeByName(resNameLifeSkillSel,"txt_job2destitle")
    local job3destitle = CSResourceMgr.getNodeByName(resNameLifeSkillSel,"txt_job3destitle")
    local job1descont = CSResourceMgr.getNodeByName(resNameLifeSkillSel,"txt_job1descont")
    local job2descont = CSResourceMgr.getNodeByName(resNameLifeSkillSel,"txt_job2descont")
    local job3descont = CSResourceMgr.getNodeByName(resNameLifeSkillSel,"txt_job3descont")
    
    setLabel(mainTitle,fontInfo.txt_maintitle.text,fontInfo.txt_maintitle.outline_color,fontInfo.txt_maintitle.outline_width,fontInfo.txt_maintitle.font_color)
    setLabel(jobTitle1,fontInfo.txt_job1title.text,fontInfo.txt_job1title.outline_color,fontInfo.txt_job1title.outline_width,fontInfo.txt_job1title.font_color)
    setLabel(jobTitle2,fontInfo.txt_job2title.text,fontInfo.txt_job2title.outline_color,fontInfo.txt_job2title.outline_width,fontInfo.txt_job2title.font_color)
    setLabel(jobTitle3,fontInfo.txt_job3title.text,fontInfo.txt_job3title.outline_color,fontInfo.txt_job3title.outline_width,fontInfo.txt_job3title.font_color)
    setLabel(job1destitle,fontInfo.txt_job1destitle.text,fontInfo.txt_job1destitle.outline_color,fontInfo.txt_job1destitle.outline_width,fontInfo.txt_job1destitle.font_color)
    setLabel(job2destitle,fontInfo.txt_job2destitle.text,fontInfo.txt_job2destitle.outline_color,fontInfo.txt_job2destitle.outline_width,fontInfo.txt_job2destitle.font_color)
    setLabel(job3destitle,fontInfo.txt_job3destitle.text,fontInfo.txt_job3destitle.outline_color,fontInfo.txt_job3destitle.outline_width,fontInfo.txt_job3destitle.font_color)
    setLabel(job1descont,fontInfo.txt_job1descont.text,fontInfo.txt_job1descont.outline_color,fontInfo.txt_job1descont.outline_width,fontInfo.txt_job1descont.font_color)
    setLabel(job2descont,fontInfo.txt_job2descont.text,fontInfo.txt_job2descont.outline_color,fontInfo.txt_job2descont.outline_width,fontInfo.txt_job2descont.font_color)
    setLabel(job3descont,fontInfo.txt_job3descont.text,fontInfo.txt_job3descont.outline_color,fontInfo.txt_job3descont.outline_width,fontInfo.txt_job3descont.font_color)

end


local function sendSelJobRequest(jobid,scene)
    NetInterface.sendWithBlock("GC_UnlockLifeSkill_Ack",function() 
        local lifeSkillSend =  require("src.Net.Send.LifeSkillSend")
        lifeSkillSend.sendCG_UnlockLifeSkill_Req(jobid)
    end,function()
        --hideUI()
		LifeSkillSelViewMgr.hide()
        LifeSkillLstViewMgr.show(scene)
    end,

    function(code) 
        --hideUI() 
        LifeSkillSelViewMgr.hide()
		TipsMgr.showError(scene, code) 
    end)
end

local function addUI(scene)
    if CSResourceMgr.getCsbObj(resNameLifeSkillSel) then
        return;
    end
    
    initSkillChangeData()
  
    local function loadCSB()
    
        local csbUI = CSResourceMgr.createRes(scene,resNameLifeSkillSel)
        csbUI:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        
        local db = CSResourceMgr.seekNodeByName(csbUI,"db")
        db:setVisible(false)
        
        --CSResourceMgr.setFullScreen(resNameLifeSkillSel)
        CSResourceMgr.setRelativePosition(resNameLifeSkillSel, 320, 480)  
        
        initBaseUI()
        --close按钮绑定
        CSResourceMgr.clickEventBinding(resNameLifeSkillSel,"btn_close",function()
            --hideUI()
            LifeSkillSelViewMgr.hide()
			GameGuideMgr.checkProcessInTown()
        end)   
        
        --切换职业按钮绑定
        CSResourceMgr.clickEventBinding(resNameLifeSkillSel,"btn_db1",function() 
            --LifeSkillJobChangeViewMgr.show(scene,skillChangeData[1],true)
            sendSelJobRequest(1)
        end)
        
        CSResourceMgr.clickEventBinding(resNameLifeSkillSel,"btn_db2",function() 
            --LifeSkillJobChangeViewMgr.show(scene,skillChangeData[2],true)
            sendSelJobRequest(2)
        end)
        
        CSResourceMgr.clickEventBinding(resNameLifeSkillSel,"btn_db3",function() 
            --LifeSkillJobChangeViewMgr.show(scene,skillChangeData[3],true)
            sendSelJobRequest(3)
        end)
    
    end
    
    local function playCSB()
        --GameAudio.playUISound("popup")
        local db = CSResourceMgr.getNodeByName(resNameLifeSkillSel,"db")
        db:setVisible(true)
        CocosModuleMgr.showUIAnimation(db, "up", function()
            end)

    end
    
    --loadCSB()
    --playCSB()
    
    local funcTable = {loadCSB, playCSB}
    UnblockLoader.load(funcTable, "LifeSkillSelViewMgr.show")
end
---------------------------------我是分割线------------------------------------
--类函数
function LifeSkillSelViewMgr.Init()
    resNameLifeSkillSel = "Player/LifeSkill/LifeSkillSelJob.csb"
end


function LifeSkillSelViewMgr.show(scene)
	UIStack.push("LifeSkillSelViewMgr",LifeSkillSelViewMgr.hide,false)
    scene = scene or SceneMgr.getRunningScene
    addUI(scene)
end


function LifeSkillSelViewMgr.hide()
    hideUI()
	UIStack.pop("LifeSkillSelViewMgr")
end


function LifeSkillSelViewMgr.request(scene)
    
    local openlevel = SystemInfo.getGlobalConfigAddInfoByID(24004).values[1]
    if CharInfo.getLevel() < openlevel then 
        StandardTipsMgr.show(1,trans_notopen)
        return
    end
    if not NetInterface.isConnect then
        StandardTipsMgr.show(1,"network erro")
        return
    end

    NetInterface.sendWithBlock("GC_GetLifeSkillData_Ack",function() 
        local lifeSkillSend =  require("src.Net.Send.LifeSkillSend")
        lifeSkillSend.sendCG_GetLifeSkillData_Req()
    end,function() 
        local data = CharInfo.getLifeSkillInfo()
        local cjson = require("cjson")
        local lifeSkillInfo = cjson.decode(data)
        if lifeSkillInfo == nil then 
            LifeSkillSelViewMgr.show(scene)
        else
        ---if string.find(data,"null")~=nil or lifeSkillInfo.career == nil  then
            if lifeSkillInfo.career == "null" or lifeSkillInfo.career == nil  then   
                LifeSkillSelViewMgr.show(scene)
            else
                LifeSkillLstViewMgr.show(scene)
            end
        end

    end,

    function(code) 
        TipsMgr.showError(scene, code) 
    end)

    --[[
    if CharInfo.getLifeSkillInfo() == nil then
        NetInterface.sendWithBlock("GC_GetLifeSkillData_Ack",function() 
            local lifeSkillSend =  require("src.Net.Send.LifeSkillSend")
            lifeSkillSend.sendCG_GetLifeSkillData_Req()
        end,function() 
            local data = CharInfo.getLifeSkillInfo()
            local cjson = require("cjson")
            local lifeSkillInfo = cjson.decode(data)
   
   
            if string.find(data,"null")~=nil or lifeSkillInfo.career == nil  then
                LifeSkillSelViewMgr.show(scene)
            else
                LifeSkillLstViewMgr.show(scene)
            end

        end,

        function(code) 
            TipsMgr.showError(scene, code) 
        end)

    else

        if string.find(CharInfo.getLifeSkillInfo(),"null")~=nil  then
            LifeSkillSelViewMgr.show(scene)
        else
            local data = CharInfo.getLifeSkillInfo()
            local cjson = require("cjson")
            local lifeSkillInfo = cjson.decode(data)
            if lifeSkillInfo.career ~= nil then
                LifeSkillLstViewMgr.show(scene)
            else
                LifeSkillSelViewMgr.show(scene)                
            end
            
        end

    end
    ]]
    
    



    --[[
    NetInterface.sendWithBlock("GC_UnlockLifeSkill_Ack",function() 
    local lifeSkillSend =  require("src.Net.Send.LifeSkillSend")
    lifeSkillSend.sendCG_UnlockLifeSkill_Req(1)
    end,function() 
    isRequested = true  
    print("LifeskillString........."..CharInfo.getLifeSkillInfo())
    end,

    function(code) 
    TipsMgr.showError(scene, code) 
    end)
    ]]
    --[[
    NetInterface.sendWithBlock("GC_ChangeLifeCareer_Ack",function() 
    local lifeSkillSend =  require("src.Net.Send.LifeSkillSend")
    lifeSkillSend.sendCG_ChangeLifeCareer_Req(2)
    end,function() 
    isRequested = true  
    print("LifeskillString........."..CharInfo.getLifeSkillInfo())
    end,

    function(code) 
    TipsMgr.showError(scene, code) 
    end)
    ]]


    --[[
    NetInterface.sendWithBlock("GC_Manufacture_Ack",function() 
    local lifeSkillSend =  require("src.Net.Send.LifeSkillSend")
    lifeSkillSend.sendCG_Manufacture_Req(1)
    end,function() 
    isRequested = true  
    print("LifeskillString........."..CharInfo.getLifeSkillInfo())
    end,

    function(code) 
    TipsMgr.showError(scene, code) 
    end)
    ]]

end



return LifeSkillSelViewMgr