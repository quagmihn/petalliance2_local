local CocosModuleMgr = {}

CocosModuleMgr.ZORDER_WORLDMAP = 0
CocosModuleMgr.ZORDER_MAP_BACK = 1
CocosModuleMgr.ZORDER_PLAYER = 2
CocosModuleMgr.ZORDER_CHARACTOR = 3
CocosModuleMgr.ZORDER_MAP_FRONT = 4
CocosModuleMgr.ZORDER_BOARD = 5
CocosModuleMgr.ZORDER_MOVETOUCH = 6
CocosModuleMgr.ZORDER_BAR = 10
CocosModuleMgr.ZORDER_CHAT = 15
CocosModuleMgr.ZORDER_WINDOW = 20
CocosModuleMgr.ZORDER_FLOAT = 25
CocosModuleMgr.ZORDER_MSGBOX = 90
CocosModuleMgr.ZORDER_GUIDE = 95
CocosModuleMgr.ZORDER_TIPS = 98
CocosModuleMgr.ZORDER_HUD = 99
CocosModuleMgr.ZORDER_LOADING = 100

---Z值使用记录：
--
--0.大地图
--1.远景<中景
--2.其他玩家的宠物<其他玩家
--3.主角的宠物<主角
--4.前景
--5.战斗技能菜单
--9.任务向导
--10.人物状态条/聊天面板/菜单面板
--11.小地图面板
--15.NPC对话框
--25.查看玩家/宠物信息面板/宠物列表面板/宠物图鉴面板
--25.商店面板/充值面板/拍卖行面板/物品信息面板/系统设置面板/邮件面板/公会面板
--90.任务强制引导
--95.更新公告
--96.弹出提示对话框
--98.弹出Tips
--99.调试信息层/转菊花遮罩层
--100.场景切换Loading层
--

CocosModuleMgr.fontName = {}    --记录字体文件名对应的"真实名称"
CocosModuleMgr.effectFileTable = {}
CocosModuleMgr.effectTable = {}
CocosModuleMgr.loadingbarTable = {}
CocosModuleMgr.ParticleTable = {}
CocosModuleMgr.VideoPlayer = nil
CocosModuleMgr.VideoCallBack = nil
CocosModuleMgr.IsMusicOpen = true 

---重新初始化CocosModuleMgr，用于动态lua调试
function CocosModuleMgr.Init()

    CocosModuleMgr.fontName["cuyuan_GBK.ttf"] = "FZCuYuan-M03"
    CocosModuleMgr.fontName["xiyuan_GBK.ttf"] = "FZXiYuan-M01"
    CocosModuleMgr.fontName["cuhei_GBK.ttf"] = "FZLanTingHeiS-DB1-GBK"
    CocosModuleMgr.fontName["chaocuhei_GBK.ttf"] = "FZChaoCuHei-M10"
    CocosModuleMgr.fontName["th.ttf"] = "FZChaoCuHei-M10"
    CocosModuleMgr.fontName["vn.ttf"] = "FZChaoCuHei-M10"
    
    CocosModuleMgr.effectFileTable = 
    {
            {res = "UI/Effect/shine1.csb", size = 128},     --1
            {res = "UI/Effect/shine2.csb", size = 100},     --2
            {res = "UI/Effect/shine3.csb", size = 128},     --3
            {res = "UI/Effect/redPoint.csb", size = 128},   --4
            {res = "UI/Effect/shine4.csb", size = 75},      --5
            {res = "UI/Effect/shine5.csb", size = 128},     --6
            {res = "Spine/effects/touch1.png", size = 90},  --7
    }
    CocosModuleMgr.effectTable = {}
    CocosModuleMgr.loadingbarTable = {}
    CocosModuleMgr.ParticleTable = {}
    CocosModuleMgr.VideoPlayer = nil
end

---镜头拉近效果
--@param scene node 当前场景
--@param anchorX float 放大中心点占屏宽的比例
--@param anchorY float 放大中心点占屏高的比例
function CocosModuleMgr.CameraEffects(scene, anchorX, anchorY)
    local scale = 2
    scene:setAnchorPoint(anchorX, anchorY)
    transition.scaleTo(scene, {scale = scale, time = 0.5})
    scene:performWithDelay(function()
        transition.scaleTo(scene, {scale = 1, time = 0.5})
        scene:performWithDelay(function()
            scene:setAnchorPoint(0.5, 0.5)
        end, 0.5)
    end, 2)
end

---多颜色、带表情文字RichLabel，注意：不用时请使用removeFromParent(true)防止内存泄漏
--local multiStr = "[fontColor=42426f]哈哈哈哈哈哈!![/fontColor][image=wsk1.png scale=1.3][/image]"
--@param parent node 父节点
--@param string string 内容字符串，可以用CocosModuleMgr.createRichLabelString创建
--@param fontSize int 字体大小
--@param font string 字体资源路径
--@param rowWidth int 最长宽度，超出会换行
--@param posx int 横坐标，不填默认为0
--@param posy int 纵坐标，不填默认为0
--@param sharpenRate int 锐化度0~1，0最弱，1最强，默认为1
--@param removeOutline bool 是否去除自动描边（不填默认加上描边，描边色根据字体颜色深浅自动分配）
--@return #node richlabel对象node(可以通过node.realWidth和node.realHeight获取其实际大小)
function CocosModuleMgr.createRichLabel(parent, string, fontSize, font, rowWidth, posx, posy, sharpenRate, removeOutline)
    local RichLabel = require("src.GameMgr.Support.RichLabel")
    
    local str = "test001"
    --[[
    --[{"color":"0FFFFF","text":"清除自身所有负面状态，并向敌军上/下半场吞吐雷电，\n造成"},
    --{"color":"FFFFFF","text":"#enter#"},
    --{"color":"F0FF00","text":"[360]","number":998},
    --{"image":"UI/Chat/Emoji/em01.png","text":"口"},
    --{"color":"FF0F00","text":"+700*法强的魔法攻击攻"}]
    --]]
    
    if not cc.FileUtils:getInstance():isFileExist(font) then
        print("找不到该字体，创建RichLabel失败！")
        return nil
    end
    if CocosModuleMgr.fontName[font]==nil then
        --计算字体的中英文字符的宽度必须填写真实的字体名
        print("字体的[真实]名称尚未注册，创建RichLabel失败！")
        return nil
    end

    string = string or str
    string = LuaSqlite.getLanguageByKey(string)
    --print("===========", string)
    posx = posx or 0
    posy = posy or 0
    sharpenRate = sharpenRate or 1
    sharpenRate = sharpenRate*CocosModuleMgr.getDeviceSharpenRate()+1
    local useOutline = true
    if removeOutline==true then
    	useOutline = false
    end
    --[[
    str:字符串 fontSize:字体大小  rowWidth:行宽 rowSpace:行间距
    --]]
    if LuaSqlite.FONT_SIZE_DIFF[LuaSqlite.LANG_TYPE] then
        fontSize = fontSize-LuaSqlite.FONT_SIZE_DIFF[LuaSqlite.LANG_TYPE]
    end
    font = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1]
    local ricLab = RichLabel.new({str=string, fontSize=fontSize, rowWidth=rowWidth, font=font, 
        sharpenRate=sharpenRate, outline=useOutline})
    ricLab:setPosition(posx, posy+ricLab.realHeight)
    ricLab:setCascadeOpacityEnabled(true)
    
    if parent~=nil then
        parent:addChild(ricLab)
    end
    --print("text:"..string.."\nfont:"..font)
    return ricLab
end

---创建RichLabel内容的格式字符串
--@param string_table table 字符串组
--{{color="FFFFFF", text="xxxx"},{image="1.png",text="口"}}
function CocosModuleMgr.createRichLabelString(string_table)
    local format_str = 
    [[
    [#extra]
    ]]
    local format_text = [[{"color":"#colorInfo","text":"#textInfo"}]]
    local format_image = [[{"image":"#imageInfo","text":"#textInfo"}]]
    
    for tags,info in pairs(string_table) do
        local str = ""
        if not info.image then
            str = string.gsub(format_text, "#colorInfo", info.color)
            str = string.gsub(str, "#textInfo", LuaSqlite.getLanguageByKey(info.text))
        else
            str = string.gsub(format_image, "#imageInfo", info.image)
            str = string.gsub(str, "#textInfo", info.text)
        end
        format_str = string.gsub(format_str, "#extra", str..",#extra")
    end
    format_str = string.gsub(format_str, ",#extra", "")
    
    return format_str
end

---检查是否是RichLabel的字符串
--@param str string 字符串
--@return #bool 是否是RichLabel字符串
function CocosModuleMgr.checkIsRichLabelString(str)
    str = LuaSqlite.getLanguageByKey(str)
    local tmpStr = string.gsub(string.gsub(str, " ", ""), "\n", "")
    if string.sub(tmpStr, 1, 1)=="[" and string.sub(tmpStr, -1, -1)=="]" then
        return true
    else
        return false
    end
end

function CocosModuleMgr.createStringWithFormat(string_table)
    local formatStr = LuaSqlite.getLanguageByKey(string_table[1]) 
    for var=2, #string_table do
        formatStr = string.gsub(formatStr, "<"..(var-1)..">", LuaSqlite.getLanguageByKey(string_table[var]))
    end
    return formatStr
end

---设置csb中创建的label的清晰度
--@param label node 所设置的label
--@param sharpenRate float 清晰度，范围0~1，0最模糊，1最清晰
--@param outlineColor color 描边色
function CocosModuleMgr.sharpenLabel(label, sharpenRate, outlineColor)
    if device.platform=="android" then
    	return false
    end
    if sharpenRate>1 or sharpenRate<0 then
    	--print("设置label清晰度失败，清晰度数值有误")
    	return false
    end
    if label:getScaleX()~=1 or label:getScaleY()~=1 then
        --print("设置label清晰度失败，该label已被拉伸过："..label:getScaleX().."-"..label:getScaleY().."，不支持再设置清晰度")
    	return false
    end

    sharpenRate = sharpenRate*CocosModuleMgr.getDeviceSharpenRate()+1
	local fontSize = math.floor(label:getFontSize()*sharpenRate)
    sharpenRate = fontSize/label:getFontSize()
    local areaSize = label:getContentSize()
    label:setFontSize(fontSize)
    label:setTextAreaSize({width = areaSize.width*sharpenRate, height = areaSize.height*sharpenRate})    
    
    label:setScale(1/sharpenRate, 1/sharpenRate)
    if outlineColor~=nil then
        local outlineBorder = outlineColor.w or CSResourceMgr.DEFAULT_LABEL_OUTLINE_BORDER
        label:enableOutline(outlineColor, outlineBorder*sharpenRate)
    end
end

---获取当前设备分辨率的清晰度效果比率
function CocosModuleMgr.getDeviceSharpenRate()
    local size = cc.Director:getInstance():getOpenGLView():getViewPortRect()
    local rate = size.width/CSResourceMgr.DEFAULT_CSB_WIDTH
    if rate<1 then
        rate = 0
    elseif rate>=1 and rate<=1.5 then
        rate = rate - 0.5
    else
        rate = 1
    end
    return rate
end

---设置node坐标，并以多分辨率适配
-- 规定以640*960分辨率制定坐标
--@param node node 所设置的node
--@param posx int 横坐标
--@param posy int 纵坐标
function CocosModuleMgr.setRelativePosition(node, posx, posy)
    if node == nil then
        print("CocosModuleMgr.setRelativePosition: node还没有被创建，请先创建。")
        return false
    end
    local size = cc.Director:getInstance():getOpenGLView():getViewPortRect()
    
    local rate = 1
    if CONFIG_SCREEN_AUTOSCALE=="FIXED_WIDTH" then
        rate = size.height/CSResourceMgr.DEFAULT_CSB_HEIGHT
    else
        rate = size.width/CSResourceMgr.DEFAULT_CSB_WIDTH
    end
    
    local ratex = posx/DEFAULT_GAME_SCREEN_WIDTH
    local ratey = posy/DEFAULT_GAME_SCREEN_HEIGHT
    local diffx = -size.x/rate
    local diffy = -size.y/rate
    local finalPosx = ratex*(CSResourceMgr.DEFAULT_CSB_WIDTH-diffx*2)+diffx
    local finalPosy = ratey*(CSResourceMgr.DEFAULT_CSB_HEIGHT-diffy*2)+diffy
    node:setAnchorPoint(0.5, 0.5)
    node:setPosition(finalPosx, finalPosy)
    --print("\nposx="..posx..",posy="..posy..",rate="..rate.."\nscreen rect:{"..size.x..","..size.y..","..size.width..","..size.height
    --    .."}\nratex="..ratex..",ratey="..ratey.." \nfinal pos:"..finalPosx..","..finalPosy
    --    .."\nGAME screen:"..DEFAULT_GAME_SCREEN_WIDTH..","..DEFAULT_GAME_SCREEN_HEIGHT)
end

---获取以多分辨率适配后的x,y
-- 规定以640*960分辨率制定坐标
--@param posx int 横坐标
--@param posy int 纵坐标
function CocosModuleMgr.getRelativePosition(posx, posy)
    local size = cc.Director:getInstance():getOpenGLView():getViewPortRect()
    local rate = 1
    if CONFIG_SCREEN_AUTOSCALE=="FIXED_WIDTH" then
        rate = size.height/CSResourceMgr.DEFAULT_CSB_HEIGHT
    else
        rate = size.width/CSResourceMgr.DEFAULT_CSB_WIDTH
    end

    local ratex = posx/DEFAULT_GAME_SCREEN_WIDTH
    local ratey = posy/DEFAULT_GAME_SCREEN_HEIGHT
    local diffx = -size.x/rate
    local diffy = -size.y/rate
    local finalPosx = ratex*(CSResourceMgr.DEFAULT_CSB_WIDTH-diffx*2)+diffx
    local finalPosy = ratey*(CSResourceMgr.DEFAULT_CSB_HEIGHT-diffy*2)+diffy
    return finalPosx, finalPosy
end

---获取屏幕尺寸差值
function CocosModuleMgr.getScreenSizeDiff()
    if CONFIG_SCREEN_AUTOSCALE=="FIXED_WIDTH" then
        local width_make = DEFAULT_GAME_SCREEN_WIDTH
        local height_make = DEFAULT_GAME_SCREEN_HEIGHT
        local size = cc.Director:getInstance():getOpenGLView():getViewPortRect()
        local rate = size.width/width_make
        local diffy = size.height-rate*height_make
        diffy = diffy/rate
        --print("当前屏幕尺寸差值为", diffy)
        return diffy
    else
        print("暂不提供")
        return 0
    end
end

---用边距设置node坐标，并以多分辨率适配
-- 规定以640*960分辨率制定边距大小
--@param node node 所设置的node
--@param Left int 左边距，左右最多只能填一边，不填传nil
--@param Right int 右边距，左右最多只能填一边，不填传nil
--@param Up int 上边距，上下最多只能填一边，不填传nil
--@param Down int 下边距，上下最多只能填一边，不填传nil
--@param boolScale bool 是否需要根据分辨率缩小尺寸（大屏不放大）
--@param boolScaleRate float 缩小效果倍率，调节缩小尺寸的效果(0无效，...，0.5中等效果，...，1最强效果)
--@return #float 缩放倍数
function CocosModuleMgr.setEdgeDistance(node, Left, Right, Up, Down, boolScale, boolScaleRate)
    if node == nil then
        print("CocosModuleMgr.setEdgeDistance: node还没有被创建，请先创建。")
        return 1
    end
    boolScale = boolScale or false
    boolScaleRate = boolScaleRate or 1
    if device.platform == "android" then
        boolScale = false
    end
    
    node:setAnchorPoint(0.5, 0.5)
    local nodeScaleX = node:getScaleX()
    local nodeScaleY = node:getScaleY()
    local nodeSize = node:getContentSize()
    nodeSize.width = nodeSize.width*nodeScaleX
    nodeSize.height = nodeSize.height*nodeScaleY
    
    local size = cc.Director:getInstance():getOpenGLView():getViewPortRect()
    local rate = 1
    if CONFIG_SCREEN_AUTOSCALE=="FIXED_WIDTH" then
        rate = size.height/CSResourceMgr.DEFAULT_CSB_HEIGHT
    else
        rate = size.width/CSResourceMgr.DEFAULT_CSB_WIDTH
    end
    local diffx = -size.x/rate
    local diffy = -size.y/rate
    local tmp_ratex = 1
    local tmp_ratey = 1
    if boolScale then
        if boolScaleRate>1 or boolScaleRate<0 then
        	boolScaleRate = 1
        end
        if rate>1 then
            rate = (rate-1)*boolScaleRate+1
            tmp_ratex = nodeScaleX/rate
            tmp_ratey = nodeScaleY/rate
            node:setScale(tmp_ratex, tmp_ratey)
            nodeSize.width = nodeSize.width/rate
            nodeSize.height = nodeSize.height/rate
        end
    end
    
    if Left then
        node:setPosition(Left*tmp_ratex+nodeSize.width/2+diffx, node:getPositionY())
    end
    
    if Right then
        node:setPosition(-Right*tmp_ratex-nodeSize.width/2+CSResourceMgr.DEFAULT_CSB_WIDTH-diffx, node:getPositionY())
    end
    
    if Up then
        node:setPosition(node:getPositionX(), -Up*tmp_ratey-nodeSize.height/2+CSResourceMgr.DEFAULT_CSB_HEIGHT-diffy)
    end
    
    if Down then
        node:setPosition(node:getPositionX(), Down*tmp_ratey+nodeSize.height/2+diffy)
    end
    
    return tmp_ratex, tmp_ratey
end

---创建文字编辑框
--@param parent node 父节点
--@param resName string 底板资源名
--@param width int 宽度
--@param height int 高度
--@param posx int 横坐标
--@param posy int 纵坐标
--@param fontSize int 字体大小
--@param maxInputLength int 最长限制
--@param placeHolder string 默认提示字符
--@param inputFlag int 输入标识,0密码,1普通,2限数字
--@param endedFunc function 输入完毕回调
--@param boolCheckShield bool 是否检查屏蔽字，不填默认检查
function CocosModuleMgr.newTextEditor(parent, resName, width, height, posx, posy, fontSize, maxInputLength, placeHolder, inputFlag, 
endedFunc, boolCheckShield)
    if boolCheckShield==nil then
    	boolCheckShield = true
    end
    inputFlag = inputFlag or cc.EDITBOX_INPUT_FLAG_SENSITIVE
    local isNumeric = false
    if inputFlag==cc.EDITBOX_INPUT_MODE_NUMERIC then
    	isNumeric = true
    end
    local function onEdit(event, editbox)
        if event == "began" then
        -- 开始输入
        elseif event == "changed" then
            -- 输入框内容发生变化
            if string.len(editbox:getText())>maxInputLength then
                local tmpstr = ChatMsgMgr.SubUTF8String(editbox:getText(), maxInputLength)
                editbox:setText(tmpstr)
            end
            if isNumeric then
                if not tonumber(editbox:getText()) then
                    editbox:setText("0")
                end
            end
        elseif event == "ended" then
        -- 输入结束
            local shieldStr = editbox:getText()
            if boolCheckShield then
                shieldStr = SystemInfo.checkShieldString(editbox:getText())
            end
            shieldStr = string.gsub(shieldStr, "\"", "")
            editbox:setText(shieldStr)
            if endedFunc then
            	endedFunc()
            end
        elseif event == "return" then
        -- 从输入框返回
        end
    end
    local editbox = cc.ui.UIInput.new({
        image = resName,
        listener = onEdit,
        size = cc.size(width, height),
        x = posx,
        y = posy
    })
    if inputFlag==cc.EDITBOX_INPUT_MODE_NUMERIC then
        editbox:setInputMode(inputFlag)
        inputFlag = cc.EDITBOX_INPUT_FLAG_SENSITIVE
    end
    editbox:setPlaceHolder(LuaSqlite.getLanguageByKey(placeHolder))
    editbox:setFont("FZCuYuan-M03", fontSize)
    editbox:setMaxLength(maxInputLength)
    editbox:setInputFlag(inputFlag)
    editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    parent:addChild(editbox)
    return editbox
end

---为node添加特效（一个node同时只能有一个特效）
--@param node node node实例
--@param type int 种类，init中有序号
function CocosModuleMgr.showShiningToNode(node, type)
    if not node then
    	return
    end
	local size = node:getContentSize()
	
    local pwidth = CocosModuleMgr.effectFileTable[type].size
    local pheight = CocosModuleMgr.effectFileTable[type].size
	
    local ratex = 1
	local ratey = 1
	if size.height < size.width then
        ratex = size.height/pheight
        ratey = size.height/pheight
    else
        ratex = size.width/pwidth
        ratey = size.width/pwidth
	end
	
    if CocosModuleMgr.effectTable[node]~=nil then
        CocosModuleMgr.hideShiningToNode(node)
	end
	CocosModuleMgr.effectTable[node] = {tag=tostring(node), res=CocosModuleMgr.effectFileTable[type].res}
    local eff = nil
    if AnimationMgr.getAniType(CocosModuleMgr.effectTable[node].res)==AnimationMgr.ANI_TYPE_CSB then
		eff = CSResourceMgr.createRes(node, CocosModuleMgr.effectTable[node].res, CocosModuleMgr.effectTable[node].tag)
        CSResourceMgr.playAllFrame(CocosModuleMgr.effectTable[node].res, true, CocosModuleMgr.effectTable[node].tag)
	elseif AnimationMgr.getAniType(CocosModuleMgr.effectTable[node].res)==AnimationMgr.ANI_TYPE_SPINE then
        eff = AnimationMgr.createAni(node, CocosModuleMgr.effectTable[node].res, 0, 0, CocosModuleMgr.effectTable[node].tag)
        AnimationMgr.playAni(CocosModuleMgr.effectTable[node].res, "idle", true, CocosModuleMgr.effectTable[node].tag)
	end
	if eff then
        eff:setAnchorPoint(0.5, 0.5)
        eff:setPosition(size.width/2, size.height/2)
        eff:setScale(ratex, ratey)
	end
end

---为node删除特效
--@param node node node实例
function CocosModuleMgr.hideShiningToNode(node)
    if node==nil or CocosModuleMgr.effectTable[node]==nil then
        return false
    end
    if CocosModuleMgr.effectTable[node].res~=nil and CocosModuleMgr.effectTable[node].tag~=nil then
        if AnimationMgr.getAniType(CocosModuleMgr.effectTable[node].res)==AnimationMgr.ANI_TYPE_CSB then
            CSResourceMgr.removeCSObjectByTag(CocosModuleMgr.effectTable[node].res, CocosModuleMgr.effectTable[node].tag)
        else
            AnimationMgr.removeGafObjectByTag(CocosModuleMgr.effectTable[node].res, CocosModuleMgr.effectTable[node].tag)
        end
        CocosModuleMgr.effectTable[node] = {}
    end
end

---为node去色/恢复颜色, 使用九宫格的控件不支持（强行使用的话，控件会消失）
--@param node node node实例
--@param doDark bool 是否去色
function CocosModuleMgr.darkNode(node, doDark)
    if node==nil then
        print("node为空，node去色失败")
        return false
    end
    if node.getVirtualRenderer then
        node:getVirtualRenderer():setScale9Enabled(false)
        node = node:getVirtualRenderer():getSprite()
    end
    if doDark then
        local vertDefaultSource = "\n"..
            "attribute vec4 a_position; \n" ..
            "attribute vec2 a_texCoord; \n" ..
            "attribute vec4 a_color; \n"..                                                    
            "#ifdef GL_ES  \n"..
            "varying lowp vec4 v_fragmentColor;\n"..
            "varying mediump vec2 v_texCoord;\n"..
            "#else                      \n" ..
            "varying vec4 v_fragmentColor; \n" ..
            "varying vec2 v_texCoord;  \n"..
            "#endif    \n"..
            "void main() \n"..
            "{\n" ..
            "gl_Position = CC_PMatrix * a_position; \n"..
            "v_fragmentColor = a_color;\n"..
            "v_texCoord = a_texCoord;\n"..
            "}"

        local pszFragSource = "#ifdef GL_ES \n" ..
            "precision mediump float; \n" ..
            "#endif \n" ..
            "varying vec4 v_fragmentColor; \n" ..
            "varying vec2 v_texCoord; \n" ..
            "void main(void) \n" ..
            "{ \n" ..
            "vec4 c = texture2D(CC_Texture0, v_texCoord); \n" ..
            "gl_FragColor.xyz = vec3(0.4*c.r + 0.4*c.g +0.4*c.b); \n"..
            "gl_FragColor.w = c.w; \n"..
            "}"

        local pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,pszFragSource)

        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
        pProgram:link()
        pProgram:updateUniforms()
        node:setGLProgram(pProgram)
    else
        node:setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgram(cc.GLProgramCache:getInstance()
            :getGLProgram("ShaderPositionTextureColor_noMVP")))
    end
end

---为node变亮/恢复颜色, 使用九宫格的控件不支持（强行使用的话，控件会消失）
--@param node node node实例
--@param lightenRate float 亮度，亮度从0开始越大越亮，0不亮
function CocosModuleMgr.lightenNode(node, lightenRate)
    if node==nil or lightenRate==nil then
        print("node为空或lightenRate为空，node去色失败")
        return false
    end
    lightenRate = tonumber(lightenRate)
    if lightenRate==nil then
        print("lightenRate不正确，node去色失败")
        return false
    end
    if node.getVirtualRenderer then
        node:getVirtualRenderer():setScale9Enabled(false)
        node = node:getVirtualRenderer():getSprite()
    end
    if lightenRate>0 then
        local vertDefaultSource = "\n"..
            "attribute vec4 a_position; \n" ..
            "attribute vec2 a_texCoord; \n" ..
            "attribute vec4 a_color; \n"..                                                    
            "#ifdef GL_ES  \n"..
            "varying lowp vec4 v_fragmentColor;\n"..
            "varying mediump vec2 v_texCoord;\n"..
            "#else                      \n" ..
            "varying vec4 v_fragmentColor; \n" ..
            "varying vec2 v_texCoord;  \n"..
            "#endif    \n"..
            "void main() \n"..
            "{\n" ..
            "gl_Position = CC_PMatrix * a_position; \n"..
            "v_fragmentColor = a_color;\n"..
            "v_texCoord = a_texCoord;\n"..
            "}"

        local pszFragSource = "#ifdef GL_ES \n" ..
            "precision mediump float; \n" ..
            "#endif \n" ..
            "varying vec4 v_fragmentColor; \n" ..
            "varying vec2 v_texCoord; \n" ..
            "void main(void) \n" ..
            "{ \n" ..
            "vec4 c = texture2D(CC_Texture0, v_texCoord); \n" ..
            "gl_FragColor.x = c.r*"..(lightenRate+1.0).."; \n"..
            "gl_FragColor.y = c.g*"..(lightenRate+1.0).."; \n"..
            "gl_FragColor.z = c.b*"..(lightenRate+1.0).."; \n"..
            "gl_FragColor.w = c.w; \n"..
            "}"

        local pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,pszFragSource)
        if pProgram then
            pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
            pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
            pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
            pProgram:link()
            pProgram:updateUniforms()
            node:setGLProgram(pProgram)
        end
    else
        node:setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgram(cc.GLProgramCache:getInstance()
            :getGLProgram("ShaderPositionTextureColor_noMVP")))
    end
end

local function clipRenderTarget(filename, renderTarget, x, y, width, height)
    if renderTarget then
        local clip = cc.RenderTexture:create(width, height)
        clip:beginWithClear(0, 0, 0, 0)
        renderTarget:setAnchorPoint(0.0,0.0)
        renderTarget:setPosition(x, y)
        renderTarget:visit()
        clip:endToLua()
        return clip:saveToFile(filename, cc.IMAGE_FORMAT_JPEG, false)
    end
    return false
end

---渲染节点至文件(cc.IMAGE_FORMAT_PNG or cc.IMAGE_FORMAT_JPEG)
--@param node 渲染节点
--@param filename 目标文件名
--@param width 目标文件width
--@param height 目标文件height
function CocosModuleMgr.renderNodeToFile(nodeMap, nodePlayer, filename, width, height, clipX, clipY, clipWidth, clipHeight)
    if nodeMap and nodePlayer then
        local renderTarget = cc.RenderTexture:create(width, height)
        renderTarget:beginWithClear(0, 0, 0, 0)
        nodeMap:visit()
        nodePlayer:visit()
        renderTarget:endToLua()
        if clipX then
            return clipRenderTarget(filename, renderTarget, clipX, clipY, clipWidth + nodeMap:getPositionX(), clipHeight)
        else
            return renderTarget:saveToFile(filename, cc.IMAGE_FORMAT_JPEG, false)
        end
    end
    return false
end

---创建一个带遮罩的node
--@param parent node 父节点，不填则不加任何节点上
--@param textureSp node 需要被遮罩的node，这个node请不要不要加到任何节点上（本函数不会设置它的坐标，有需要请自行设置）
--@param maskResName string 遮罩图片名称
--@param pos vec2_table 遮罩图片的坐标（请根据屏幕分辨率换算好）, 格式：{x=0, y=0}
--@return #node 带遮罩的node
function CocosModuleMgr.maskSprite(parent, textureSp, maskResName, pos)
    --[[
    local __rTex = cc.RenderTexture:create(maskSp:getContentSize().width, maskSp:getContentSize().height)
    
    local __bf = cc.blendFunc(GL_ONE, GL_ZERO)
    maskSp:setBlendFunc(__bf)
    local __bfs = cc.blendFunc(GL_DST_ALPHA, GL_ZERO)
    textureSp:setBlendFunc(__bfs)
    
    __rTex:begin()
    maskSp:visit()
    textureSp:visit()
    __rTex:endToLua()
    --]]
    
    local mask = display.newSprite(maskResName)
    mask:setPosition(pos.x, pos.y)
    
    local clippingNode = cc.ClippingNode:create(mask)
    clippingNode:setStencil(mask)
    clippingNode:setInverted(true)
    clippingNode:setAlphaThreshold(0.9)
    clippingNode:addChild(textureSp)
    if parent then
        clippingNode:addTo(parent)
    end
    
    return clippingNode
end

---设置屏幕是否可点击
--@param boolTouch bool 是否可点击
--@param tag string 为了不让自己的禁屏被其他人解掉，可以填次参数
function CocosModuleMgr.setScreenTouch(boolTouch, tag)
    local resName = "Scene/CommonMask.csb"
    local boolClick = tag==nil
    tag = tag or ""
    tag = "setScreenTouch"..tag
    if TOUCH_PIPELINE_DIAGNOSTICS then
        print(string.format("[TOUCH_DIAG] screen_lock action=%s tag=%s scene=%s stack=%s",
            boolTouch and "release" or "acquire", tostring(tag), tostring(SceneMgr.currentScene),
            debug.traceback("", 2)))
    end
    if boolTouch then
        --print("恢复屏幕点击", tag)
        CSResourceMgr.removeCSObjectByTag(resName, tag)
    else
        --print("禁止屏幕点击", tag)
        local mask = CSResourceMgr.createRes(SceneMgr.getRunningScene, resName, tag)
        mask:setLocalZOrder(CocosModuleMgr.ZORDER_GUIDE)
        if TOUCH_PIPELINE_DIAGNOSTICS then
            print(string.format("[TOUCH_DIAG] screen_lock_mask node=%s z=%s visible=%s",
                tostring(mask.name or mask), tostring(mask:getLocalZOrder()), tostring(mask:isVisible())))
        end
        CSResourceMgr.setRelativePosition(resName, 320, 480, tag)
        if not boolClick then
        	CSResourceMgr.clickEventBinding(resName, "mask", function()
                AwardsListMgr.spClose()
            end, tag, nil, "")
        end
    end
end

---为按钮添加强制引导
--@param button node 按钮实例
--@param arrowDir float 箭头方向，0→ 1↓ 2← 3↑，默认左(0.5↘ 1.5↙ 2.5↖ 3.5↗)
--@param callback function 点击附加事件
--@param arrowScale float 箭头缩放大小，如果填了则会随父节点缩放
function CocosModuleMgr.setButtonGuide(button, arrowDir, callback, arrowScale)
    local arrowRes = "Spine/effects/Ui_xinshouyindaoshouzhi.png"
    local circleRes = "Spine/effects/Ui_xinshouyindaoguangquan.png"
    local resName = "Scene/CommonMask.csb"
    local shadeRes = "Scene/CommonGuide.csb"
    if button==nil then
        print("引导按钮为nil，直接执行回调")
        if callback then
            callback()
        end
        return false
    end
    --[[
    if not button:isTouchEnabled() then
        print("引导按钮不可点击，直接执行回调")
        if callback then
            callback()
        end
        return false
    end
    if not button:isVisible() then
        print("引导按钮不可见，直接执行回调")
        if callback then
            callback()
        end
        return false
    end
    ]]
    print("增加引导按钮")
    CSResourceMgr.createRes(SceneMgr.getRunningScene, resName):setLocalZOrder(CocosModuleMgr.ZORDER_GUIDE)
    CSResourceMgr.setRelativePosition(resName, 320, 480)
    local size = button:getContentSize()
    
    --递归算真实scale
    local buttonScaleX = 1
    local function getTrueScaleX(node)
        --print("-----scalex", buttonScaleX)
        buttonScaleX = buttonScaleX*node:getScaleX()
        local parent = node:getParent()
        if parent then
            getTrueScaleX(parent)
        end
    end
    if not arrowScale then
        getTrueScaleX(button)
        buttonScaleX = math.abs(buttonScaleX)
    end    
    local buttonScaleY = 1
    local function getTrueScaleY(node)
        --print("-----scaley", buttonScaleY)
        buttonScaleY = buttonScaleY*node:getScaleY()
        local parent = node:getParent()
        if parent then
            getTrueScaleY(parent)
        end
    end
    if not arrowScale then
        getTrueScaleY(button)
        buttonScaleY = math.abs(buttonScaleY)
    end
    
    arrowScale = arrowScale or 1
    
    --添加阴影
    local shadeLayer = CSResourceMgr.createRes(button, shadeRes)
    local shadeNode = CSResourceMgr.getNodeByName(shadeRes, "node")
    shadeLayer:setPosition(size.width/2, size.height/2)
    local trueSize = {width=size.width*buttonScaleX, height=size.height*buttonScaleY}
    local sx = shadeNode:getScaleX()
    shadeNode:setScaleX(sx/buttonScaleX)
    local sy = shadeNode:getScaleY()
    shadeNode:setScaleY(sy/buttonScaleY)
    if trueSize.width>100 then
        sx = shadeNode:getScaleX()
        shadeNode:setScaleX(sx*trueSize.width/100)
    end
    if trueSize.height>100 then
        sy = shadeNode:getScaleY()
        shadeNode:setScaleY(sy*trueSize.height/100)
    end
    shadeNode:setGlobalZOrder(CocosModuleMgr.ZORDER_GUIDE)
    shadeLayer:setOpacity(0)
    transition.fadeIn(shadeLayer, {time=0.5})
    
    local gzorder = button:getGlobalZOrder()
    local function addAni(resStr)
        local eff = AnimationMgr.createAni(CSResourceMgr.getCsbObj(shadeRes), resStr, 0, 0)
        AnimationMgr.playAni(resStr, "animation", true)
        eff:setAnchorPoint(0.5, 0.5)
        eff:setScale(arrowScale/buttonScaleX, arrowScale/buttonScaleY)
        arrowDir = arrowDir or 0
        eff:setRotation(90*arrowDir)
        eff:setGlobalZOrder(CocosModuleMgr.ZORDER_GUIDE)
    end
    addAni(circleRes)
    addAni(arrowRes)
    
    button:setGlobalZOrder(CocosModuleMgr.ZORDER_GUIDE)
    CSResourceMgr.addButtonListener(button, function()
        AnimationMgr.removeGafObjectByTag(arrowRes)
        AnimationMgr.removeGafObjectByTag(circleRes)
        CSResourceMgr.removeCSObjectByTag(resName)
        CSResourceMgr.removeCSObjectByTag(shadeRes)
        button:setGlobalZOrder(gzorder)
        if callback then
            callback()
        end
    end)
end

---为按钮添加非强制引导
--@param button node 按钮实例
--@param arrowDir float 箭头方向，0→ 1↓ 2← 3↑，默认左(0.5↘ 1.5↙ 2.5↖ 3.5↗)
--@param callback function 点击附加事件
--@param arrowScale float 箭头缩放大小
function CocosModuleMgr.setButtonHint(button, arrowDir, callback, arrowScale)
    local arrowRes = "Spine/effects/Ui_xinshouyindaoshouzhi.png"
    if button==nil then
        return false
    end
    local size = button:getContentSize()

    arrowScale = arrowScale or 1
    local function addAni(resStr)
        local eff = AnimationMgr.createAni(button, resStr, 0, 0, tostring(button))
        AnimationMgr.playAni(eff.res, "animation", true, eff.tag)
        eff:setPosition(size.width/2, size.height/2)
        eff:setAnchorPoint(0.5, 0.5)
        eff:setScale(arrowScale)
        arrowDir = arrowDir or 0
        eff:setRotation(90*arrowDir)
        eff:setGlobalZOrder(CocosModuleMgr.ZORDER_GUIDE)
        return eff
    end
    local effAni = addAni(arrowRes)
    CSResourceMgr.addButtonListener(button, function()
        AnimationMgr.removeGafObjectByTag(effAni.res, effAni.tag)
        if callback then
            callback()
        end
    end)
    return effAni
end

---为node添加引导手指, 一定时间后自动消失
--@param node node node实例
--@param arrowDir float 箭头方向，0→ 1↓ 2← 3↑，默认左(0.5↘ 1.5↙ 2.5↖ 3.5↗)
--@param callback function 手指消失后的回调
--@param arrowScale float 箭头缩放大小
--@param timeSeconds float 持续时间
function CocosModuleMgr.setNodeHint(node, arrowDir, callback, arrowScale, timeSeconds)
    if node==nil then
        return false
    end
	CocosModuleMgr.setScreenTouch(false)
    local arrowRes = "Spine/effects/yindao_zhishi.png"
    local size = node:getContentSize()
    arrowScale = arrowScale or 1
    local function addAni(resStr)
        local eff = AnimationMgr.createAni(node, resStr, 0, 0, tostring(node))
        AnimationMgr.playAni(eff.res, "animation", true, eff.tag)
        AnimationMgr.setSpeedRate(eff.res, 0.5, eff.tag)
        eff:setPosition(size.width/2, size.height/2)
        eff:setAnchorPoint(0.5, 0.5)
        eff:setScale(arrowScale*0.7)
        arrowDir = arrowDir or 0
        --eff:setRotation(90*arrowDir)
        local tipNode = CSResourceMgr.createRes(eff, "UI/Effect/guide/guide"..(arrowDir*10)..".csb", tostring(node))
        tipNode:setAnchorPoint(0.5, 0.5)
        eff:setGlobalZOrder(CocosModuleMgr.ZORDER_GUIDE)
        CSResourceMgr.setSpriteTexture(tipNode.res, "db", CocosModuleMgr.getWordImage("guide_word_dialog.png"), tipNode.tag, false)
        CSResourceMgr.getNodeByName(tipNode.res, "db", tipNode.tag):setGlobalZOrder(CocosModuleMgr.ZORDER_GUIDE)
        CSResourceMgr.getNodeByName(tipNode.res, "arrow", tipNode.tag):setGlobalZOrder(CocosModuleMgr.ZORDER_GUIDE)
        return eff
    end
    local effAni = addAni(arrowRes)
    SceneMgr.getRunningScene:performWithDelay(function()
        AnimationMgr.removeGafObjectByTag(effAni.res, effAni.tag)
        CocosModuleMgr.setScreenTouch(true)
        if callback then
            callback()
        end
    end, timeSeconds or 1)
end

---为某个精灵添加心情
--@param parent node 父节点
--@param type int 心情种类，目前有1~5
--@param posx float 横坐标
--@param posy float 纵坐标
--@param boolAutoDisappear bool 是否自动消失
--@return #node 所创建的心情node
function CocosModuleMgr.showMood(parent, type, posx, posy, boolAutoDisappear)
    if not parent or type<1 or type>11 then
    	return nil
    end
    local filename = string.format("UI/Emoji/mood/mood_%02d.csb", type)
    local tag = tostring(parent)
    local node = CSResourceMgr.createRes(parent, filename, tag)
    CSResourceMgr.playAllFrame(filename, true, tag)
    --[[
    local sx = parent:getScaleX()
    local sy = parent:getScaleY()
    node:setScale(1/sx, 1/sy)
    ]]
    node:setPosition(posx, posy)
    if boolAutoDisappear then
        node:performWithDelay(function()
            transition.fadeOut(node, {time = 0.5})
        end, 3)
        node:performWithDelay(function()
            CSResourceMgr.removeCSObjectByTag(filename, tag)
        end, 3.5)
    end
    return node
end

---为当前场景添加触摸效果
--@param scene node 场景
function CocosModuleMgr.addTouchEffect(scene)
    local touchLayer = display.newLayer():addTo(scene)
    touchLayer:setLocalZOrder(CocosModuleMgr.ZORDER_LOADING)
    touchLayer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
    	if event.name == "began" then
            local footPrintRes = "Spine/effects/Ui_jiemiandianji.png"
            local footPrint = AnimationMgr.createAni(scene, footPrintRes, event.x, event.y)
            AnimationMgr.playAniWithCallback(footPrintRes, "animation", nil, nil, true)
            footPrint:setLocalZOrder(CocosModuleMgr.ZORDER_TIPS)
    	end
    end)
end

function CocosModuleMgr.setLoadingBarPercent(node, percent, diff, callback)
    local function updateLoadingBar(node, p, diff, callback)
        if not CocosModuleMgr.loadingbarTable[node] then
        	return
        end
        if p>CocosModuleMgr.loadingbarTable[node] and diff>0 then
            return
        end
        if p<CocosModuleMgr.loadingbarTable[node] and diff<0 then
            return
        end
        if diff==0 then
            return
        end
        node:setPercent(p)
        if callback then
            callback(p)
        end
        node:performWithDelay(function()
            updateLoadingBar(node, p+diff, diff, callback)
        end, 0.01)
    end

    if (percent==0 and diff>0) or (percent==100 and diff<0) then
        node:setPercent(percent)
        CocosModuleMgr.loadingbarTable[node] = percent
    else
        local curpercent = node:getPercent()
        CocosModuleMgr.loadingbarTable[node] = percent
        transition.stopTarget(node)
        updateLoadingBar(node, curpercent, diff, callback)
    end
end

---获取格式化时间字符串
--@param seconds int 秒数，不填则为服务器时间
--@param type int 格式化类型
--@return #string 格式化时间字符串
function CocosModuleMgr.getTimeStr(seconds, type)
	type = type or 1
    seconds = seconds or CharInfo.getServerTime()
    local timezoneOffset = CocosModuleMgr.getLocalTimeZone()-CharInfo.getServerTimeZone()
    seconds = seconds-timezoneOffset
    if os.date("*t",os.time()).isdst then -- 夏令时
        seconds = seconds - 3600
    end
	if type==1 then
        return os.date("%X", seconds)
    elseif type==2 then
        return os.date("%H", seconds)
    elseif type==3 then
        return os.date("%M", seconds)
    elseif type==4 then
        return os.date("%m", seconds)
    elseif type==5 then
        return os.date("%d", seconds)
    elseif type==6 then
        return os.date("%w", seconds)
    elseif type==7 then
        return os.date("%Y", seconds)
    elseif type==8 then
        return os.date("%S", seconds)
	end
end

---获取本机时区
function CocosModuleMgr.getLocalTimeZone()
    local now = os.time()
    return os.difftime(now, os.time(os.date("!*t", now)))
end

---获取两个时间的间隔天数
--@param t1 int 时间1(先)
--@param t2 int 时间2(后)
--@param offsetTime int 重置时间点，默认为表内填的每日重置时间，n*3600
--@return #int 间隔天数(t2-t1)
function CocosModuleMgr.getDayTimeDiff(t1, t2, offsetTime)
    if not t1 or not t2 then
    	return
    end
    if not offsetTime then
    	offsetTime = SystemInfo.getGlobalConfigAddInfoByID(6900).values[1]
    end
    local df1 = (t1+CharInfo.getServerTimeZone()-offsetTime)/86400
    local df2 = (t2+CharInfo.getServerTimeZone()-offsetTime)/86400
    local d1 = math.floor(df1)
    local d2 = math.floor(df2)
    --[[
    print("GetDayTimeDiff:\n", t1, d1.."d", math.floor((df1-d1)*24).."h\n", 
        t2, d2.."d", math.floor((df2-d2)*24).."h\n", "offsetTime:", offsetTime.."s")]]
    return d2-d1
end

function CocosModuleMgr.createAtlasLabel(number, res, width, height, char, diff)
    local CCSUILoader = require("src.framework.cc.uiloader.CCSUILoader")
    local filePath = cc.FileUtils:getInstance():fullPathForFilename(res) 
    local fileExist = cc.FileUtils:getInstance():isFileExist(res)
    if fileExist == false then
        return nil
    end
    local label = nil
    if diff then
        label = display.newSprite("empty.png")
        local strLen = string.len(number)
        local tmpWidth = width+diff
        for var=1, strLen do
            local str = string.sub(number, var, var)
            local tmpLabel = CCSUILoader:createLabelAtlas({
                stringValue = str,
                charMapFileData = {path = filePath},
                itemWidth = width,
                itemHeight = height,
                startCharMap = char,
                ignoreSize = true,
                x = 0,
                y = 0,})
            tmpLabel:addTo(label)
            tmpLabel:setPosition(tmpWidth/2+(var-1)*tmpWidth, height/2)
        end
        label:setCascadeOpacityEnabled(true)
        label:setContentSize(tmpWidth*strLen, height)
    else
        label = CCSUILoader:createLabelAtlas({
            stringValue = number,
            charMapFileData = {path = filePath},
            itemWidth = width,
            itemHeight = height,
            startCharMap = char,
            ignoreSize = true,
            x = 0,
            y = 0,})
        label:setCascadeOpacityEnabled(true)
    end
    return label
end

---播放按钮解锁动画
--@param button node 按钮实例
--@param callback function 解锁完成回调
--@param type int 动画类型，1通用型2建筑型3小节点型。默认1
function CocosModuleMgr.showUnlockAnimation(button, callback, type)
    type = type or 1
    if not button then
    	return
    end
    local tag = tostring(button)
    --print("播放解锁动画", type, tostring(button))
    transition.stopTarget(button)
    CocosModuleMgr.setScreenTouch(false, tag)
    if button:isTouchEnabled() then
        CSResourceMgr.setButtonEnabledByNode(button, false)
    end
    local size = button:getContentSize()
    local curScale = button:getScale()
    local sequence = nil
    local delayTime = 0
    local aniRes = {}
    local aniSpeed = 1
    local aniPos = {}
    local aniScale = 1
    if type==2 then
        sequence = transition.sequence({
            cc.ScaleTo:create(0.1, curScale*1.05),
            cc.ScaleTo:create(0.1, curScale),
        })
        delayTime = 0.1
        aniRes = {"Spine/effects/Ui_changjingjianzhujiesuo_qian.png", "Spine/effects/Ui_changjingjianzhujiesuo_hou.png"}
        aniSpeed = 0.5
        aniPos = {width=size.width/2, height=0}
        aniScale = 1.2
    else
        sequence = transition.sequence({
            cc.RotateTo:create(0.05, 20),
            cc.RotateTo:create(0.1, -20),
            cc.RotateTo:create(0.1, 20),
            cc.RotateTo:create(0.1, -20),
            cc.RotateTo:create(0.1, 20),
            cc.RotateTo:create(0.1, -20),
            cc.RotateTo:create(0.1, 20),
            cc.RotateTo:create(0.1, -20),
            cc.RotateTo:create(0.05, 0),
            cc.ScaleTo:create(0.1, curScale*1.3),
            cc.ScaleTo:create(0.05, curScale),
            cc.ScaleTo:create(0.1, curScale*1.1),
            cc.ScaleTo:create(0.05, curScale),
        })
        delayTime = 0.8
        aniRes = {"Spine/effects/Ui_tubiaojiesuo_1.png", "Spine/effects/Ui_tubiaojiesuo_2.png"}
        aniSpeed = 1
        aniPos = {width=size.width/2, height=size.height/2}
        aniScale = 1
    end
    button:runAction(sequence)
    button:performWithDelay(function()
        CSResourceMgr.setButtonEnabledByNode(button, true)
        local ani1 = AnimationMgr.createAni(button, aniRes[1], aniPos.width, aniPos.height, tostring(button))
        AnimationMgr.playAniWithCallback(ani1.res, "animation", nil, ani1.tag, true)
        AnimationMgr.setSpeedRate(ani1.res, aniSpeed, ani1.tag)
        ani1:setScale(aniScale)
        local ani2 = AnimationMgr.createAni(button, aniRes[2], aniPos.width, aniPos.height, tostring(button))
        ani2:setLocalZOrder(-1)
        AnimationMgr.playAniWithCallback(ani2.res, "animation", nil, ani2.tag, true)
        AnimationMgr.setSpeedRate(ani2.res, aniSpeed, ani2.tag)
        ani2:setScale(aniScale)
    end, delayTime)
    button:performWithDelay(function()
        CocosModuleMgr.setScreenTouch(true, tag)
        if callback then
            callback()
        end
    end, 1.5)
    if type==1 then
        GameAudio.playUISound("questUnlock")
    elseif type==2 or type==3 then
        GameAudio.playUISound("unlock")
    end

    --新加解锁TIPS
    local tipsBtn = CSResourceMgr.seekNodeByName(button,"UnLockTipsBtn")
    if tipsBtn then
        tipsBtn:setVisible(false)
    end
end

---播放UI打开动画,调用方式举例CocosModuleMgr.showUIAnimation(node,"up")
--@param node node 要播放动画的节点，该节点不能为空  
--@param animtype string 播放动画的方式 up为往上,down为往下
--@param callback function 动画播放完成回调，可不填
function CocosModuleMgr.showUIAnimation(node, animtype, callback)
    local fangshi1 = "elasticOut"
    local juli1 = 400
    local time1 = 0.5
    local value1 = 1
    local originx,originy = node:getPosition()
    
    if(animtype == "up") then
        node:setPosition(originx, originy-juli1)
    end
    
    if(animtype == "down") then
        node:setPosition(originx, originy+juli1)
    end    
    transition.execute(node, cc.MoveTo:create(time1, cc.p(originx, originy)), {
        delay = 0.0,
        easing = {fangshi1, value1}, 
        onComplete = function()
            if callback then
            	callback()
            end
        end,
    })
end

---设置label倒计时
--@param timeLabel node 时间label
--@param second int 初始秒数
--@param endCallback function 倒计时结束回调，不处理则不填
--@param secCallback function 每秒回调，会传sender秒数，不处理则不填
function CocosModuleMgr.setTimeLabelCountDown(timeLabel, second, endCallback, secCallback)
    second = tonumber(second) or -1
    if not timeLabel or second<0 then
    	return
    end
    local function updateTime(timeLabel, h, m, s)
        local h_str = string.format("%02d", h)
        local m_str = string.format("%02d", m)
        local s_str = string.format("%02d", s)
        CSResourceMgr.setLabelStringByNode(timeLabel, h_str..":"..m_str..":"..s_str)
        timeLabel:performWithDelay(function()
            updateTime(timeLabel, h, m, s)
        end, 1)
        if secCallback then
            secCallback(h*3600+m*60+s)
        end
        s=s-1
        if s<0 then
            s=59
            m=m-1
            if m<0 then
                m=59
                h=h-1
                if h<0 then
                    h=0
                    m=0
                    s=0
                    transition.stopTarget(timeLabel)
                    if endCallback then
                    	endCallback()
                    end
                end
            end
        end
    end
    local h = math.floor(second/3600)
    local m = math.floor((second-h*3600)/60)
    local s = second-h*3600-m*60
    transition.stopTarget(timeLabel)
    updateTime(timeLabel, h, m, s)
end

---设置label顺计时
--@param timeLabel node 时间label
--@param second int 初始秒数
--@param callback function 每秒回调，会传sender秒数，不处理则不填
function CocosModuleMgr.setTimeLabelCountUp(timeLabel, second, callback)
    second = tonumber(second) or -1
    if not timeLabel or second<0 then
        return
    end
    local function updateTime(timeLabel, h, m, s)
        local h_str = string.format("%02d", h)
        local m_str = string.format("%02d", m)
        local s_str = string.format("%02d", s)
        CSResourceMgr.setLabelStringByNode(timeLabel, h_str..":"..m_str..":"..s_str)
        timeLabel:performWithDelay(function()
            updateTime(timeLabel, h, m, s)
        end, 1)
        if callback then
            callback(h*3600+m*60+s)
        end
        s=s+1
        if s>59 then
            s=0
            m=m+1
            if m>59 then
                m=0
                h=h+1
                if h>23 then
                    h=0
                    m=0
                    s=0
                end
            end
        end
    end
    local h = math.floor(second/3600)
    local m = math.floor((second-h*3600)/60)
    local s = second-h*3600-m*60
    transition.stopTarget(timeLabel)
    updateTime(timeLabel, h, m, s)
end

function CocosModuleMgr.playVideo(res, callback, boolClickSkip, bShowSKip)
    if device.platform~="ios" and device.platform~="android" then
        if callback then
            DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "Windows Platform do not support VideoPlayer...", function()
                callback()
            end)
        end
        return
    end
    if CocosModuleMgr.VideoPlayer then
        CocosModuleMgr.VideoPlayer:removeFromParent(true)
        CocosModuleMgr.VideoPlayer = nil
    end
    local boolMusicOpen = GameAudio.getMusicOpen()
    CocosModuleMgr.IsMusicOpen = boolMusicOpen
    GameAudio.setMusicOpen(false)
    local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, "Scene/CommonMask.csb", "CocosModuleMgr.playVideo")
    CSResourceMgr.setRelativePosition(layer.res, 320, 480, layer.tag)
    layer:setLocalZOrder(CocosModuleMgr.ZORDER_LOADING)
    SceneMgr.setMapVisible(false)
    local layerBlack = CSResourceMgr.createRes(SceneMgr.getRunningScene, "Scene/CommonBlack.csb", "CocosModuleMgr.playVideo")
    CSResourceMgr.setRelativePosition(layerBlack.res, 320, 480, layerBlack.tag)
    layerBlack:setLocalZOrder(CocosModuleMgr.ZORDER_LOADING)
    transition.fadeIn(layerBlack, {time=0.5})
    local videoPlayer = ccexp.VideoPlayer:create()
    videoPlayer:setPosition(display.cx, display.cy)
    videoPlayer:setAnchorPoint(cc.p(0.5, 0.5))
    --videoPlayer:setContentSize(cc.size(display.widthInPixels, display.heightInPixels))
    videoPlayer:setContentSize(cc.size(display.width, display.height))
    if device.platform=="ios" then
        videoPlayer:setFileName(res)
        CocosModuleMgr.VideoCallBack = callback
        layer:performWithDelay(function()
            if CocosModuleMgr.VideoPlayer then
                if bShowSKip and not boolClickSkip then --如果显示跳过按
                    AndroidFunction.ShowVideoSkip()
                end
            end
        end, 2)
    else
        local fullPath = cc.FileUtils:getInstance():fullPathForFilename(res)
        fullPath = string.gsub(fullPath,"assets/","")
        CocosModuleMgr.VideoCallBack = callback
        videoPlayer:setFileName(fullPath)
        layer:performWithDelay(function()
            if CocosModuleMgr.VideoPlayer then
            	print("看看安卓视频放没放出来:"..fullPath)
                if bShowSKip and not boolClickSkip then --如果显示跳过按
                    AndroidFunction.ShowVideoSkip()
                end
                --[[
                if not CocosModuleMgr.VideoPlayer:isPlaying() then
                    print("安卓视频没放出来")
                    if boolMusicOpen then
                        GameAudio.setMusicOpen(true)
                    end
                    CSResourceMgr.removeCSObjectByTag(layer.res, layer.tag)
                    CSResourceMgr.removeCSObjectByTag(layerBlack.res, layerBlack.tag)
                    CocosModuleMgr.playVideo(res, callback,boolClickSkip,bShowSKip)
                else
                    print("安卓视频放出来了")
                    if bShowSKip and not boolClickSkip then --如果显示跳过按钮
                        AndroidFunction.ShowVideoSkip()
                    end
            	end
                ]]
            end
        end, 2)
    end
    videoPlayer:setKeepAspectRatioEnabled(true)
    videoPlayer:setFullScreenEnabled(false)
    videoPlayer:setVisible(true)
    SceneMgr.getRunningScene:addChild(videoPlayer)
    videoPlayer:play()
    local function closeFunc()
        layer:performWithDelay(function()
            --CSResourceMgr.callButtonFunc(layer.res, "mask", layer.tag)
            --videoPlayer:removeFromParent(true)
            CocosModuleMgr.VideoPlayer:removeFromParent(true)
            CocosModuleMgr.VideoPlayer = nil
            CSResourceMgr.removeCSObjectByTag(layer.res, layer.tag)
            CSResourceMgr.removeCSObjectByTag(layerBlack.res, layerBlack.tag)
            SceneMgr.setMapVisible(true)
            if callback then
                callback()
            end
            if boolMusicOpen then
                GameAudio.setMusicOpen(true)
            end
            if device.platform == "android" then 
                AndroidFunction.videoSkipViewHide()
            elseif device.platform == "ios" then
                iOSFunction.delSkipButton()
            end
        end, 0.1)
    end
    videoPlayer:addEventListener(function(sender, state)
        print("videoPlayer EventListener 状态", state)
        if state==3 then
            closeFunc()
        end
    end)
    videoPlayer:setTouchEnabled(false)
    CocosModuleMgr.VideoPlayer = videoPlayer
    if boolClickSkip then
        CSResourceMgr.clickEventBinding(layer.res, "mask", function()
            closeFunc()
        end, layer.tag)
    end
end

function CocosModuleMgr.setShareButton(boolShow)
    local resName = "Charactor/shareBtn.csb"
	if boolShow then
		local layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
		CocosModuleMgr.setEdgeDistance(layer, 0, nil, 0, nil)
		CSResourceMgr.clickEventBinding(resName, "share", function()
			print("share")
		end, "", 3)
	else
	    CSResourceMgr.removeCSObjectByTag(resName)
	end
end

function CocosModuleMgr.getWordImage(picName)
    return "Words/"..LuaSqlite.getLangFolderName().."/"..picName
end

--截图分享，只适用于获取宠物时
function CocosModuleMgr.shareScreenSnapShot()
    local resName = "Charactor/QRCode.csb"
    local serverName = GameLogMgr.roleInfo.serverName
    local scene = cc.Director:getInstance():getRunningScene()
    local QRNode = CSResourceMgr.createRes(scene, resName)
    QRNode:zorder(CocosModuleMgr.ZORDER_LOADING)
    CocosModuleMgr.setEdgeDistance(QRNode, 0, nil, 0, nil)
    CSResourceMgr.setSpriteTexture(resName, "qrcode", CocosModuleMgr.getWordImage("dl_qrcode.png"), nil, false)
    CSResourceMgr.setLabelString(resName, "info", CocosModuleMgr.createStringWithFormat({"服务器：<1>\n昵称：<2>\n等级：<3>",
        serverName, CharInfo.getNickName(), CharInfo.getLevel()}), nil, {r=0,g=0,b=0,a=255,s=1,w=1})

    local screen = cc.RenderTexture:create(display.width, display.height)
    screen:beginWithClear(0, 0, 0, 0)
    scene:visit()
    screen:endToLua()
    local result = screen:saveToFile("share.jpg", cc.IMAGE_FORMAT_JPEG, false)    
    CSResourceMgr.removeCSObjectByTag(resName)
    if result==true then
        print("截图成功")
        local filePath = cc.FileUtils:getInstance():fullPathForFilename("share.jpg")
        luaoc.callStaticMethod("SdkInterface", "weixinShare", {path=filePath})
    else
        print("截图失败")
    end    
end

---获取两个时间是不是同一个星期
--@param t1 int 时间1(先)
--@param t2 int 时间2(后)
--@param offsetTime int 重置时间点，默认为表内填的每日重置时间，n*3600
-- function CocosModuleMgr.weekTimeDiff(t1, t2, week, offsetTime)
--     if not offsetTime then
--         offsetTime = SystemInfo.getGlobalConfigAddInfoByID(6900).values[1]
--     end
--     if t1 > t2 then
--         local temp = t1
--         t1 = t2
--         t2 = temp
--     end
--     local dayDiff = CocosModuleMgr.getDayTimeDiff(t1, t2, offsetTime)
--     if dayDiff == 0 then
--         return 0
--     end
--     if dayDiff >= 7 then
--         return dayDiff / 7
--     end
--     local w1 = tonumber(CocosModuleMgr.getTimeStr(t1, 6))
--     local w2 = tonumber(CocosModuleMgr.getTimeStr(t2, 6))
--     if dayDiff > 0 then
--         if w2 > w1 and (w1 > week or w2 < week) then
--             return 0
--         elseif w2 < w1 and (w2 > week or w1 < week) then
--             return 0
--         else
--             return 1
--         end
--     end
--     return 0
-- end

--@param t时间(秒)
--@param week 周几刷新(0-6)
--用于2次时间对比，相等则是同一周期
function CocosModuleMgr.getWeekRefreshTime(t, week, offsetTime)
    if not offsetTime then
        offsetTime = SystemInfo.getGlobalConfigAddInfoByID(6900).values[1]
    end
    local w = tonumber(CocosModuleMgr.getTimeStr(t, 6))
    local o2 = tonumber(CocosModuleMgr.getTimeStr(t, 2)) * 3600 + tonumber(CocosModuleMgr.getTimeStr(t, 3)) * 60 + tonumber(CocosModuleMgr.getTimeStr(t, 8))
    if week < w then
        return t - o2 - (w - week) * 24 * 3600 + offsetTime
    elseif week > w then
        return t - o2 - (w + 7 - week) * 24 * 3600 + offsetTime
    else
        if o2 > offsetTime then
            return t - o2 - (w - week) * 24 * 3600 + offsetTime
        elseif o2 < offsetTime then
            return t - o2 - (w + 7 - week) * 24 * 3600 + offsetTime
        end
    end
    return t
end

---获取带逗号的数字字符串
--@param num number or string 数字
function CocosModuleMgr.getNumberString(num)
    if not num then
    	return ""
    end
    local numberStr = num..""
    local length = string.len(numberStr)
    local newString = ""
    for var=1, math.ceil(length/3) do
        local splitStr = string.sub(numberStr, -var*3, -(1+(var-1)*3))
        if var==1 then
            newString = splitStr
        else
            newString = splitStr..","..newString
        end
    end
    return newString
end

return CocosModuleMgr
