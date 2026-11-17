local json = require("framework.json")

local ChineseSize = 3 -- 修正宽度缺陷(范围:3~4)
local OutlineSize = 2 -- 描边宽度
local RichLabel = class("RichLabel", function()
    return display.newLayer()
end)

RichLabel.wordWidthMap = {}     --用来存储字符宽度，提高效率

--[[
--需要传入一个tab
--可选参数auto(自适应安卓机宽度)
--坐标最好传固定数值
-- param = {str, font, fontSize, rowWidth, rowSpace}
--]]
function RichLabel:ctor(param, auto)
	if auto then 
		if device.platform == "android" then
			param.rowWidth = param.rowWidth - 50 
		end
	end

	param.str = param.str or "传入的字符串为nil"
	param.font = param.font or "cuyuan_GBK.ttf"
	param.fontSize = param.fontSize or 14
	param.rowWidth = param.rowWidth or 640
	param.rowSpace = param.rowSpace or -4
	
    self.rowWidth = param.rowWidth
    self.sharpenRate = math.floor(param.fontSize*param.sharpenRate)/param.fontSize
	self.font = param.font
    self.fontsize = param.fontSize
    self.useOutline = param.outline
	
	local textTab = self:initData(param.str, param.font, param.fontSize, param.rowWidth)
	self:setContentSize(1, 1)
	local ptab, copyVar = self:automaticNewline(textTab) -- 纯字符表,渲染表

	local ocWidth = 0  -- 当前占宽
	local ocRow   = 1  -- 当前行
	local ocHeight = 0 -- 当前高度
	local btn,useWidth,useHeight = 0,0,0
	for k,v in pairs(copyVar) do
		local params = {}
		self:tab_addDataTo(params, v)
		-- 计算实际渲染宽度
		if params.row == ocRow then
			ocWidth = ocWidth + useWidth
		else
			ocRow = params.row
			ocWidth = 0
			-- 计算实际渲染高度
			ocHeight = ocHeight + useHeight + param.rowSpace --修正高度间距
		end
		local maxsize = params.size 
		local byteSize = math.floor((maxsize + 2) / ChineseSize)
		params.width  = byteSize*params.breadth     -- 控件宽度
		params.height = maxsize                     -- 控件高度
		params.x = ocWidth       					-- 控件x坐标
		params.y = -(ocHeight)                      -- 控件y坐标
		params.scene = self
		btn,useWidth,useHeight = self:creatViewObj(params)
	end
	ocWidth = ocWidth + useWidth
    ocHeight = ocHeight + useHeight
    if ocRow > 1 then
        ocWidth = param.rowWidth
    end

	self.realWidth = ocWidth
	self.realHeight = ocHeight
    self.ptab = ptab
end

-- 初始化数据
function RichLabel:initData(str, font, fontSize, rowWidth)
    local tab = self:parseString(str, {font = font, size = fontSize})
    local var = {}
    var.tab = tab         -- 文本字符
    var.width = rowWidth  -- 指定宽度
    return var
end

-- 全角 半角string.len()
function RichLabel:accountTextLen(str, tsize)
	local font = self.font
	local list,lenlist = self:comminuteText(str)
	local aLen = 0
	for k,v in pairs(list) do
	    --这个算法本来效率很低，我改一下算法
        aLen = aLen+self:getLabelTTFWidth(v, tsize, lenlist[k])
	end
	return aLen
end

function RichLabel:getLabelTTFWidth(str, fontsize, charnum)
    local font = self.font
    local tsize = fontsize or self.fontsize
    local v = str
    local keyStr = font.."-"..v.."-"..(tsize*self.sharpenRate)
    if not RichLabel.wordWidthMap[keyStr] then
        local m_pobTexture = nil
        m_pobTexture = cc.Label:createWithTTF(v, font, tsize*self.sharpenRate)
        local width = m_pobTexture:getContentSize().width
        if self.useOutline then
            --width = width/self.sharpenRate+math.floor(OutlineSize*self.sharpenRate)/self.sharpenRate*2*charnum  --描边宽度
            width = width/self.sharpenRate+math.floor(1*self.sharpenRate)/self.sharpenRate*2*charnum
        else
            width = width/self.sharpenRate
        end
        RichLabel.wordWidthMap[keyStr] = width
        m_pobTexture:removeFromParent(true)
    end
    return RichLabel.wordWidthMap[keyStr]
end

function RichLabel:addDataToRenderTab(copyVar, tab, text, index, current, strLen)
	local tag = #copyVar + 1
	copyVar[tag] = {}
	self:tab_addDataTo(copyVar[tag], tab)
	copyVar[tag].text = text 
	copyVar[tag].index = index                  -- 该行的第几个字符开始
	copyVar[tag].row = current                  -- 第几行
	copyVar[tag].breadth = strLen   			-- 所占宽度
	copyVar[tag].tag = tag	-- 唯一下标
end

function RichLabel:automaticNewline(var)
	-- 根据限定的宽度, 再切割。确定行数
	local allTab = {}   -- 总的字符数组
	local copyVar = {}  -- 准备渲染的数组
	local useLen = 0    -- 记录该行使用长度信息
	local str = ""		-- 储存该行字符
	local current = 1 	-- 记录最大行数
	for ktb,tab in ipairs(var.tab) do
        tab.text = string.gsub(tab.text, "\n", "")
        if tab.text=="#enter#" then
            current = current+1
            useLen = 0          -- 重算占用长度
            str = ""            -- 重新填充字符
        else
            local txtTab, member = self:comminuteText(tab.text) -- 切割字符串数组,字符数
            local num = self.rowWidth -- 每一行最大宽度
            -- 最后一行被占用却未占满先填满
            if useLen > 0 then
                local remain = num - useLen
                local txtLen = self:accountTextLen(tab.text, tab.size)
                if txtLen <= remain then -- 新的文本块长度小于剩余长度则直接拼接 
                    allTab[current] = allTab[current] .. tab.text
                    self:addDataToRenderTab(copyVar, tab, tab.text, (useLen + 1), current, txtLen)
                    useLen = useLen + txtLen
                    txtTab = {}
                else -- 填满最后一行
                    local cTag = 0
                    local mstr = ""
                    local sIndex = useLen+1
                    local s_Len = 0
                    for k,element in pairs(txtTab) do
                        local sLen = self:accountTextLen(element, tab.size)
                        if (useLen + sLen) <= num then
                            useLen = useLen + sLen
                            s_Len = s_Len + sLen
                            cTag = k
                            mstr = mstr .. element
                        else
                            if string.len(mstr) > 0 then
                                allTab[current] = allTab[current] .. mstr
                                self:addDataToRenderTab(copyVar, tab, mstr, (sIndex), current, s_Len)
                            end
                            current = current+1
                            useLen = 0          -- 重算占用长度
                            str = ""            -- 重新填充字符
                            s_Len = 0
                            break
                        end
                    end
                    for i=1,cTag do
                        table.remove(txtTab, 1)
                    end
                end 
            end
            -- 填充字符
            for k,element in pairs(txtTab) do
                local sLen = self:accountTextLen(element, tab.size)
                if (useLen + sLen) <= num then 
                    useLen = useLen + sLen -- 记录字符已占用该行长度
                    str = str .. element   -- 拼接该行字符
                else
                    allTab[current] =  str -- 储存已经装满字符的行 
                    self:addDataToRenderTab(copyVar, tab, str, 1, current, useLen)
                    current = current + 1  -- 开辟新的一行
                    useLen = sLen          -- 重算占用长度
                    str = element          -- 重新填充字符
                end
                if k == #txtTab then -- 最后一行字符占用情况
                    if useLen <= num then 
                        allTab[current] = str
                        self:addDataToRenderTab(copyVar, tab, str, 1, current, useLen)
                    end
                end
            end
	    end
	end
	return allTab, copyVar
end

-- 拆分出单个字符
function RichLabel:comminuteText(str)
    local list = {}
    local lenlist = {}
    local len = string.len(str)
    local i = 1
    while i <= len do
        local c = string.byte(str, i)
        local shift = 1
        local clen = 1
        if c > 0 and c <= 127 then
            shift = 1
            if self:checkIsEnglishChar(c) then
                for var=i+1, len do
                    local c_ = string.byte(str, var)
                    if self:checkIsEnglishChar(c_) then
                        shift = shift + 1
                        clen = clen + 1
                    else
                        break
                    end
                end
            end
        elseif (c >= 192 and c <= 223) then
            shift = 2
        elseif (c >= 224 and c <= 239) then
            shift = 3
        elseif (c >= 240 and c <= 247) then
            shift = 4
        end
        local char = string.sub(str, i, i + shift - 1)
        if self:getLabelTTFWidth(char, nil, clen)>self.rowWidth and clen>1 then
            for var=1, clen do
                local schar = string.sub(str, i + var - 1, i + var - 1)
                table.insert(list, schar)
                table.insert(lenlist, 1)
            end
        else
            table.insert(list, char)
            table.insert(lenlist, clen)
        end
        i = i + shift
    end
    return list, lenlist
end

function RichLabel:checkIsEnglishChar(byteVal)
    if (byteVal>=48 and byteVal<=57) or (byteVal>=65 and byteVal<=90) or (byteVal>=97 and byteVal<=122) then
    	return true
    end
    return false
end

function RichLabel:creatViewObj(params)
	if not params.image then 
        local font = params.font

        local lab = cc.Label:createWithTTF(params.text, font, params.size*self.sharpenRate)
        local outLineBorder = math.floor(OutlineSize*self.sharpenRate)
        if params.color then
            lab:setTextColor(cc.c4b(params.color.r,params.color.g,params.color.b,255))
            local grayLevel = params.color.r*0.299 + params.color.g*0.587 + params.color.b*0.114;
            if self.useOutline then
                if grayLevel>=64 then
                    --lab:enableOutline({r=0,g=0,b=0,a=200}, OutlineSize)             --黑描边old
                    lab:enableOutline({r=0,g=0,b=0,a=200}, outLineBorder)             --黑描边
                else
                    --lab:enableOutline({r=255,g=255,b=255,a=200}, OutlineSize)       --白描边old
                    lab:enableOutline({r=255,g=255,b=255,a=200}, outLineBorder)       --白描边
                end
                lab:setAdditionalKerning(-outLineBorder)
            end
        else
            lab:setTextColor(cc.c4b(0,0,0,255))
            if self.useOutline then
                --lab:enableOutline({r=255,g=255,b=255,a=200}, OutlineSize)           --默认描边old
                lab:enableOutline({r=255,g=255,b=255,a=200}, outLineBorder)           --默认描边
                lab:setAdditionalKerning(-outLineBorder)
            end
        end
        
        lab:setAnchorPoint(0, 1)
        lab:setPosition(params.x, params.y)
        lab:setTouchSwallowEnabled(false)
        local scaleX = lab:getScaleX()
        local scaleY = lab:getScaleY()
        lab:setScale(scaleX/self.sharpenRate, scaleY/self.sharpenRate)
        params.scene:addChild(lab)
        local useWidth = lab:getBoundingBox().width
	    local useHeight = lab:getBoundingBox().height
        return lab,useWidth,useHeight
	else
		--ui/texture/
	    local btn = cc.ui.UIPushButton.new("empty.png", {scale9 = true})
	        :setButtonSize(params.width, params.height)
            :setButtonLabel("normal", cc.ui.UILabel.newTTFLabel_({
	            text  = params.text,
	            size  = params.size,
	            color = params.color,
	            font  = params.font,
	        }))
	        :onButtonPressed(function(event)
	        	event.target:getButtonLabel("normal"):setPosition(0, 0)
	        end)
	        :onButtonClicked(function(event)
	            event.target:getButtonLabel("normal"):setPosition(0, 0)
	            if self.listener then self.listener(event.target, params) end
	        end)
	        :onButtonRelease(function(event)
	        	event.target:getButtonLabel("normal"):setPosition(0, 0)
	    	end)
	        :align(display.LEFT_TOP, params.x, params.y)
	        :addTo(params.scene)
	    btn:setButtonLabelAlignment(display.TOP_LEFT)
	    btn:setTouchSwallowEnabled(false)
	    local normalLab = btn:getButtonLabel("normal")
	    normalLab:setPosition(0, 0)
	    local useWidth = normalLab:getBoundingBox().width
	    local useHeight = normalLab:getBoundingBox().height
	    if params.image then
	    	self:imageManage(btn, params, useWidth)
	    end
	    return btn,useWidth,useHeight
	end
end

-- 图片标签处理
function RichLabel:imageManage(object, params, useWidth)
	local g = display.newSprite(params.image, 0, -4)
    g:setScaleX(useWidth / g:getContentSize().width * 1.2)
    g:setScaleY(params.size / g:getContentSize().height * 1.2)
    g:setAnchorPoint(0, 1)
	object:addChild(g, 1)
	object:setButtonLabelString("normal", "")
	local move1 = cc.MoveBy:create(0.5, {x=0, y=2})
    local move2 = cc.MoveBy:create(0.5, {x=0, y=-2})
    g:runAction(cc.RepeatForever:create(cc.Sequence:create(move1, move2)))
    object.imageSprite = g
end

function RichLabel:tab_addDataTo(tab, src)
    for k,v in pairs(src) do
        tab[k] = v
    end
end

-- string.split()
function RichLabel:strSplit(str, flag)
	local tab = {}
	while true do
		local n = string.find(str, flag)
		if n then
			local first = string.sub(str, 1, n-1) 
			str = string.sub(str, n+1, #str) 
			table.insert(tab, first)
		else
			table.insert(tab, str)
			break
		end
	end
	return tab
end

-- 解析输入的文本
function RichLabel:parseString(str, param)
	local tb 
	local s = string.find(str,"%[color")
	if not s then
		tb = json.decode(str)
	end
	if tb then
		for k,v in pairs(tb) do
			if not v.number then  v.number = k end -- 未指定number则自动生成
			self:tab_addDataTo(v, param)
			if v.color then
				v.color = self:GetTextColor(v.color)
			end
            if v.image and v.text then
                if string.sub(v.image, 1, 14)=="UI/Chat/Emoji/" then
                    v.text = "oooo"     --大表情占位符，该字体用这个串
                end
            end
		end
	else
		tb = self:parseString1(str, param)
		print("RichLabel串非json格式，使用表情符号会出错...")
	end
	return tb
end

-- 解析输入的文本
function RichLabel:parseString1(str, param)
	local clumpheadTab = {} -- 标签头
	for w in string.gfind(str, "%b[]") do 
		if  string.sub(w,2,2) ~= "/" then-- 去尾
			table.insert(clumpheadTab, w)
		end
	end
	-- 解析标签
	local totalTab = {}
	for k,ns in pairs(clumpheadTab) do
		local tab = {}
		local tStr  
		-- 第一个等号前为块标签名
		string.gsub(ns, string.sub(ns, 2, #ns-1), function (w)
			local n = string.find(w, "=")
			if n then
				local temTab = self:strSplit(w, " ") -- 支持标签内嵌
				for k,pstr in pairs(temTab) do
					local temtab1 = self:strSplit(pstr, "=")
					-- 截取等号前的string
					local pname = temtab1[1]
					if k == 1 then tStr = pname end -- 标签头
					-- 截取等号后的string
					local js = temtab1[2]
					local p = string.find(js, "[^%d.]")
        			if not p then js = tonumber(js) end
					if pname == "color" then
						tab[pname] = self:GetTextColor(js)
					else
						tab[pname] = js
					end
				end
			end
		end)
		if tStr then
			-- 取出文本
			local beginFind,endFind = string.find(str, "%[%/"..tStr.."%]")
			local endNumber = beginFind-1
			local gs = string.sub(str, #ns+1, endNumber)
			tab["text"] = gs
			-- 截掉已经解析的字符
			str = string.sub(str, endFind+1, #str)
			if param then
				if not tab.number then  tab.number = k end -- 未指定number则自动生成
				tab.type = tab.type or 0
				self:tab_addDataTo(tab, param) 
			end
			table.insert(totalTab, tab)
		end
	end
	-- 普通格式label显示
	if table.nums(clumpheadTab) == 0 then
		local ptab = {}
		ptab.text = str
		if param then
			param.number = 1
			self:tab_addDataTo(ptab, param) 
		end
		table.insert(totalTab, ptab)
	end
	return totalTab
end

--[[解析16进制颜色rgb值]]
function  RichLabel:GetTextColor(xStr)
    if string.len(xStr) == 6 then
        local tmp = {}
        for i = 0,5 do
            local str =  string.sub(xStr,i+1,i+1)
            if(str >= '0' and str <= '9') then
                tmp[6-i] = str - '0'
            elseif(str == 'A' or str == 'a') then
                tmp[6-i] = 10
            elseif(str == 'B' or str == 'b') then
                tmp[6-i] = 11
            elseif(str == 'C' or str == 'c') then
                tmp[6-i] = 12
            elseif(str == 'D' or str == 'd') then
                tmp[6-i] = 13
            elseif(str == 'E' or str == 'e') then
                tmp[6-i] = 14
            elseif(str == 'F' or str == 'f') then
                tmp[6-i] = 15
            else
                print("Wrong color value.")
                tmp[6-i] = 0
            end
        end
        local r = tmp[6] * 16 + tmp[5]
        local g = tmp[4] * 16 + tmp[3]
        local b = tmp[2] * 16 + tmp[1]
        return cc.c3b(r,g,b)
    end
    return cc.c3b(255,255,255)
end

-- 设置监听函数
function  RichLabel:setClickEventListener(eventName)
	self.listener = eventName
end

return RichLabel
