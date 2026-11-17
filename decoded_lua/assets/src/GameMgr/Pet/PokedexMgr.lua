local PokedexMgr = {}

---图鉴滑动面板会按照[宠物种类总数]、[显示区域尺寸]、[元素中心间隔]、[空白边距]自动布局
--图鉴贴图尺寸暂定为70*70

PokedexMgr.DEFAULT_FRAME_WIDTH = 590                --显示区域宽
PokedexMgr.DEFAULT_FRAME_HEIGHT = 500               --显示区域高
PokedexMgr.DEFAULT_ELEMENT_DISTANCE = 90            --按钮元素的中心间隔
PokedexMgr.DEFAULT_SCROLLVIEW_BORDER = 150          --滑动区域的空白边距

PokedexMgr.DEFAULT_SCROLLVIEW_SENSOR_X = 3          --滑动的灵敏度（横），需要根据图鉴总数量调整（成反比）
PokedexMgr.DEFAULT_SCROLLVIEW_SENSOR_Y = 3          --滑动的灵敏度（纵），需要根据图鉴总数量调整（成反比）

PokedexMgr.DEFAULT_SCALE_S = 0.27                   --缩放倍率s
PokedexMgr.DEFAULT_SCALE_M = 0.43                   --缩放倍率m
PokedexMgr.DEFAULT_SCALE_L = 0.71                   --缩放倍率l
 

PokedexMgr.DEFAULT_CENTER_WIDTH = 5                 --中心放大的按钮个数（横），初始化时会另外计算
PokedexMgr.DEFAULT_CENTER_HEIGHT = 2                --中心放大的按钮个数（纵），初始化时会另外计算

local resName = ""
local buttonArr = {}
local rowSize = 0
local scrollWidth = 0
local scrollHeight = 0
local isLoaded = false
local preScrollX = 0
local preScrollY = 0
local rate_x = 0
local rate_y = 0

function PokedexMgr.Init()
	print("PokedexMgr初始化")
	
    resName = "Pet/PokedexView.csb"
    buttonArr = {}
    rowSize = 0
    scrollWidth = 0
    scrollHeight = 0
    isLoaded = false
    preScrollX = 0
    preScrollY = 0
    rate_x = 0
    rate_y = 0
end

function PokedexMgr.show(scene)
    local petTotal = 150--719            --宠物总数以后从表中获取
    rowSize = math.ceil(math.sqrt(petTotal))
    scrollWidth = PokedexMgr.DEFAULT_ELEMENT_DISTANCE*rowSize+PokedexMgr.DEFAULT_SCROLLVIEW_BORDER*2
    scrollHeight = PokedexMgr.DEFAULT_ELEMENT_DISTANCE*rowSize+PokedexMgr.DEFAULT_SCROLLVIEW_BORDER*2
    buttonArr = {}
    isLoaded = false
    preScrollX = 56     --为了初始图鉴时完美移到中间，这个数字需要调试后获取
    preScrollY = 53     --为了初始图鉴时完美移到中间，这个数字需要调试后获取
    PokedexMgr.DEFAULT_CENTER_WIDTH = math.ceil((PokedexMgr.DEFAULT_FRAME_WIDTH-PokedexMgr.DEFAULT_SCROLLVIEW_BORDER*2)/PokedexMgr.DEFAULT_ELEMENT_DISTANCE)
    PokedexMgr.DEFAULT_CENTER_HEIGHT = math.ceil((PokedexMgr.DEFAULT_FRAME_HEIGHT-PokedexMgr.DEFAULT_SCROLLVIEW_BORDER*2)/PokedexMgr.DEFAULT_ELEMENT_DISTANCE)
    rate_x = PokedexMgr.checkFloat(100/(rowSize-PokedexMgr.DEFAULT_CENTER_WIDTH))
    rate_y = PokedexMgr.checkFloat(100/(rowSize-PokedexMgr.DEFAULT_CENTER_HEIGHT))

	local curLayer = CSResourceMgr.createRes(scene, resName)
	CSResourceMgr.setRelativePosition(resName, 320, 480)
	curLayer:setLocalZOrder(25)
	
    local selPetIcon = CSResourceMgr.getNodeByName(resName, "icon")
    CSResourceMgr.setSpriteTexture(resName, "icon", "Pet/pokedex_diban.png")
    local selPetInfoStr = "宠物名称：呵呵呵\n宠物描述：韩寒会画画后悔画韩红，韩寒会画画后悔画韩红，红红火火恍恍惚惚何厚铧。\n宠物编号："
    CSResourceMgr.setLabelString(resName, "info", selPetInfoStr)
    CSResourceMgr.setLabelMaxWidth(resName, "info", 600)
    selPetIcon:setScale(1.5)
	
	CSResourceMgr.clickEventBinding(resName, "close", function()
		PokedexMgr.hide()
	end)
	
    PokedexMgr.setLoadProgressTips(0)
    local hud = CSResourceMgr.getNodeByName(resName, "hud")
    local ani = cc.RepeatForever:create(cc.RotateBy:create(1.5, 180))
    hud:runAction(ani)
	
	--创建图鉴元素按钮
	local scrollView = CSResourceMgr.getNodeByName(resName, "scrollview")
	local function createBtn(var)
        local example = CSResourceMgr.getNodeByName(resName, "example"):clone()
        example:setVisible(true)
        scrollView:addChild(example)
        local x = ((var-1)%rowSize)*PokedexMgr.DEFAULT_ELEMENT_DISTANCE+PokedexMgr.DEFAULT_ELEMENT_DISTANCE/4+PokedexMgr.DEFAULT_SCROLLVIEW_BORDER
        local y = scrollHeight-PokedexMgr.DEFAULT_ELEMENT_DISTANCE/2-math.floor((var-1)/rowSize)*PokedexMgr.DEFAULT_ELEMENT_DISTANCE-PokedexMgr.DEFAULT_SCROLLVIEW_BORDER
        local diff = 0
        if math.floor((var-1)/rowSize)%2==0 then
            diff = PokedexMgr.DEFAULT_ELEMENT_DISTANCE/2
        end
        example:setPosition(x+diff, y)
        example:setScale(0, 0)
        return example
	end
    local funcTable = {}
    local funcTableSize = rowSize*2+1
	for var=1, rowSize do
	    buttonArr[var] = {}
	    local function initBtn()
            for i=1, rowSize do
                local example = createBtn(i+(var-1)*rowSize)
                buttonArr[var][i] = example
            end
            PokedexMgr.setLoadProgressTips(math.floor(var*100/funcTableSize))
        end
        table.insert(funcTable, initBtn)
	end
	--设置图鉴元素贴图
	local petid_cal = -1
    local function setBtnTexture(var, i)
        if petid_cal==-1 then
            petid_cal = (var-1)*rowSize+i
        end
        petid_cal = petid_cal+1
        local dibanRes = "Pet/pokedex_diban.png"--PokemonInfo.getPokemonIconByID(petid_cal)
        CSResourceMgr.setButtonTextureByNode(buttonArr[var][i], dibanRes, dibanRes, dibanRes)
        local pid = petid_cal
        local filenameIcon = dibanRes
        CSResourceMgr.clickEventBindingByNode(buttonArr[var][i], function()
            --图鉴宠物被点击
            --TipsMgr.show(scene, "No."..pid)
            CSResourceMgr.setSpriteTexture(resName, "icon", filenameIcon)
            CSResourceMgr.setLabelString(resName, "info", selPetInfoStr..pid)
        end, true)
        transition.scaleTo(buttonArr[var][i], {scale=PokedexMgr.DEFAULT_SCALE_S, time=0.1})
    end
    for var=1, rowSize do
        local function initBtnTexture()
            for i=1, rowSize do
                setBtnTexture(var, i)
            end
            PokedexMgr.setLoadProgressTips(math.floor((var+rowSize)*100/funcTableSize))
        end
        table.insert(funcTable, initBtnTexture)
    end
    local function finished()
        isLoaded = true
        local hud = CSResourceMgr.getNodeByName(resName, "hud")
        local tips = CSResourceMgr.getNodeByName(resName, "tips")
        transition.stopTarget(hud)
        hud:setVisible(false)
        tips:setVisible(false)
        PokedexMgr.checkButtons(preScrollX, preScrollY)
        PokedexMgr.setLoadProgressTips(100)
    end
    table.insert(funcTable, finished)
    UnblockLoader.load(funcTable, "PokedexMgr-show")
    
    scrollView:setInnerContainerSize({width = scrollWidth, height = scrollHeight})
    PokedexMgr.DEFAULT_SCROLLVIEW_SENSOR_X = rate_x/2
    PokedexMgr.DEFAULT_SCROLLVIEW_SENSOR_Y = rate_y/2
    scrollView:addEventListener(function(sender, state)
        local w = scrollView:getInnerContainer():getContentSize().width-PokedexMgr.DEFAULT_FRAME_WIDTH
        local perW = math.floor(scrollView:getInnerContainer():getPositionX()/w*(-100))
        local h = scrollView:getInnerContainer():getContentSize().height-PokedexMgr.DEFAULT_FRAME_HEIGHT
        local perH = math.floor(100-(scrollView:getInnerContainer():getPositionY()/h*(-100)))
        --print("scrolllView:"..perW..","..perH)
        if preScrollX-perW>PokedexMgr.DEFAULT_SCROLLVIEW_SENSOR_X or 
           preScrollX-perW<-PokedexMgr.DEFAULT_SCROLLVIEW_SENSOR_X or  
           preScrollY-perH>PokedexMgr.DEFAULT_SCROLLVIEW_SENSOR_Y or 
           preScrollY-perH<-PokedexMgr.DEFAULT_SCROLLVIEW_SENSOR_Y then
            preScrollX = perW
            preScrollY = perH
            PokedexMgr.checkButtons(perW, perH)
        end
    end)
    
    scrollView:jumpToPercentHorizontal(preScrollX)
    scrollView:jumpToPercentVertical(preScrollY)
end

function PokedexMgr.checkButtons(rx, ry)
    if not isLoaded then
    	return
    end
    local show_x = PokedexMgr.DEFAULT_CENTER_WIDTH
    local show_y = PokedexMgr.DEFAULT_CENTER_HEIGHT
    local x = PokedexMgr.checkFloat(rx/rate_x)+1
    local y = PokedexMgr.checkFloat(ry/rate_y)+1
    --中心按钮放大
    for var=x, x+show_x-1 do
        for i=y, y+show_y-1 do
            PokedexMgr.playScaleAnimation(var, i, PokedexMgr.DEFAULT_SCALE_L)
    	end
    end
    --内圈按钮中等放大
    for var=x-1, x+show_x do
        PokedexMgr.playScaleAnimation(var, y-1, PokedexMgr.DEFAULT_SCALE_M)
        PokedexMgr.playScaleAnimation(var, y+show_y, PokedexMgr.DEFAULT_SCALE_M)
    end
    for var=y, y+show_y-1 do
        PokedexMgr.playScaleAnimation(x-1, var, PokedexMgr.DEFAULT_SCALE_M)
        PokedexMgr.playScaleAnimation(x+show_x, var, PokedexMgr.DEFAULT_SCALE_M)
    end
    --外圈按钮保持最小
    for var=x-2, x+show_x+1 do
        PokedexMgr.playScaleAnimation(var, y-2, PokedexMgr.DEFAULT_SCALE_S)
        PokedexMgr.playScaleAnimation(var, y+show_y+1, PokedexMgr.DEFAULT_SCALE_S)
    end
    for var=y, y+show_y-1 do
        PokedexMgr.playScaleAnimation(x-2, var, PokedexMgr.DEFAULT_SCALE_S)
        PokedexMgr.playScaleAnimation(x+show_x+1, var, PokedexMgr.DEFAULT_SCALE_S)
    end
    --print("checkButtons start:"..x..","..y)
end

function PokedexMgr.playScaleAnimation(row, line, scale)
    local btn = buttonArr[line]
    if btn then
        btn = btn[row]
        if btn then
            local time = 0.2
            transition.scaleTo(btn, {scale=scale, time=time})
        end
    end
end

function PokedexMgr.checkFloat(var)
	if var>=math.floor(var)+0.5 then
		return math.ceil(var)
	else
	    return math.floor(var)
	end
end

function PokedexMgr.setLoadProgressTips(percent)
    CSResourceMgr.setLabelString(resName, "tips", CocosModuleMgr.createStringWithFormat({"图鉴正在卖力加载中...<1>%", percent}), "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
end

function PokedexMgr.hide()
    local scrollView = CSResourceMgr.getNodeByName(resName, "scrollview")
    scrollView:removeAllChildren()
    CSResourceMgr.removeCSObjectByTag(resName)
    UnblockLoader.cancel("PokedexMgr-show")
end

return PokedexMgr