local GameNoticeMgr = {}

GameNoticeMgr.DEFAULT_CONTENT_WIDTH = 400

local haveShown = false
local showDelayTime = 0.5
local buttonCallback = {}
local titleTable = {}
local contentTable = {}
local testStr = ""

local isGameNoticeShown = true

function GameNoticeMgr.Init()
    --[[    
    haveShown = true--false
    showDelayTime = 0.5
    buttonCallback = {}
    titleTable = {}
    contentTable = {}
    testStr = string.rep("测试多加点字", 25)
    
    GameNoticeMgr.InitButtonClickEvent()
    ]]
end

function GameNoticeMgr.InitButtonClickEvent()
    buttonCallback[1] = function()
        TipsMgr.show(nil, "测试活动按钮1点击了")
        GameNoticeMgr.hide()
    end
	buttonCallback[2] = function()
		TipsMgr.show(nil, "测试活动按钮2点击了")
        GameNoticeMgr.hide()
	end
    buttonCallback[3] = nil
    buttonCallback[4] = function()
        TipsMgr.show(nil, "测试活动按钮4点击了")
        GameNoticeMgr.hide()
    end
    buttonCallback[5] = function()
        TipsMgr.show(nil, "测试活动按钮5点击了")
        GameNoticeMgr.hide()
    end
end

function GameNoticeMgr.show(scene)
    if haveShown then
	   return false
    end
	haveShown = true
	showDelayTime = 0.5
	
    GameNoticeMgr.addGameNoticeLayer(scene)
end

function GameNoticeMgr.hide()
    CSResourceMgr.getNodeByName("UI/GameNotice/GameNoticeLayer.csb", {"bg", "diban", "list"}):removeAllItems()
    CSResourceMgr.removeCSObjectByTag("UI/GameNotice/GameNoticeLayer.csb")
end

function GameNoticeMgr.addGameNoticeLayer(scene)
    local layer = CSResourceMgr.createRes(scene, "UI/GameNotice/GameNoticeLayer.csb")
    layer:setLocalZOrder(95)
    CSResourceMgr.setRelativePosition("UI/GameNotice/GameNoticeLayer.csb", 320, 480)

    local infoList = GameNoticeMgr.getUpdateInfo()
    local line = CSResourceMgr.getNodeByName("UI/GameNotice/GameNoticeLayer.csb",{"sep_example"}):clone()
    line:setVisible(true)
    CSResourceMgr.getNodeByName("UI/GameNotice/GameNoticeLayer.csb", {"bg", "diban", "list"}):pushBackCustomItem(line)
    for key,var in pairs(infoList) do
        if var[1]~=nil and var[3]~=nil then
            --图片
            if var[2]~=nil then
                local image = CSResourceMgr.getNodeByName("UI/GameNotice/GameNoticeLayer.csb",{"image_example"}):clone()
                image:loadTextures("UI/GameNotice/"..var[2], "UI/GameNotice/"..var[2], "UI/GameNotice/"..var[2])
                image:ignoreContentAdaptWithSize(false)
                image:setVisible(true)
                CSResourceMgr.getNodeByName("UI/GameNotice/GameNoticeLayer.csb", {"bg", "diban", "list"}):pushBackCustomItem(image)
            end
            --按钮
            if buttonCallback[key] then
                CSResourceMgr.clickEventBinding("UI/GameNotice/GameNoticeLayer.csb",{"btn_example"}, function(sender, state)
                    buttonCallback[key]()
                end)
                local button = CSResourceMgr.getNodeByName("UI/GameNotice/GameNoticeLayer.csb",{"btn_example"}):clone()
                button:setVisible(true)
                CSResourceMgr.getNodeByName("UI/GameNotice/GameNoticeLayer.csb", {"bg", "diban", "list"}):pushBackCustomItem(button)
            end
            --标题
            local title = CSResourceMgr.getNodeByName("UI/GameNotice/GameNoticeLayer.csb",{"title_example"}):clone()
            title:setString(LuaSqlite.getLanguageByKey(var[1]))
            title:enableOutline({r=0,g=0,b=0,a=255}, 1)
            title:setVisible(true)
            titleTable[key] = title
            CSResourceMgr.getNodeByName("UI/GameNotice/GameNoticeLayer.csb", {"bg", "diban", "list"}):pushBackCustomItem(title)
            --内容
            local content = CSResourceMgr.getNodeByName("UI/GameNotice/GameNoticeLayer.csb",{"content_example"}):clone()
            content:setString(LuaSqlite.getLanguageByKey(var[3])..testStr)
            CSResourceMgr.setLabelMaxWidthByNode(content, GameNoticeMgr.DEFAULT_CONTENT_WIDTH, -1)
            content:setVisible(true)
            contentTable[key] = content
            CSResourceMgr.getNodeByName("UI/GameNotice/GameNoticeLayer.csb", {"bg", "diban", "list"}):pushBackCustomItem(content)
            --分割线
            local line = CSResourceMgr.getNodeByName("UI/GameNotice/GameNoticeLayer.csb",{"sep_example"}):clone()
            line:setVisible(true)
            CSResourceMgr.getNodeByName("UI/GameNotice/GameNoticeLayer.csb", {"bg", "diban", "list"}):pushBackCustomItem(line)
        end
    end
    CSResourceMgr.clickEventBinding("UI/GameNotice/GameNoticeLayer.csb", {"bg", "diban", "close"}, function()
        GameNoticeMgr.hide()
    end)

    layer:setOpacity(0)
    layer:performWithDelay(function()
        for key,var in pairs(titleTable) do
            CocosModuleMgr.sharpenLabel(var, 1)
        end
        for key,var in pairs(contentTable) do
            CocosModuleMgr.sharpenLabel(var, 1)
        end
        transition.fadeIn(layer, {time = 0.5})
    end, showDelayTime)
    showDelayTime = 0 
end

function GameNoticeMgr.getUpdateInfo()
    local filePath = cc.FileUtils:getInstance():fullPathForFilename("UI/GameNotice/UpdateNotice.plist")
    local valPlist = cc.FileUtils:getInstance():getValueMapFromFile(filePath)
    
    local size = valPlist["size"]
    local valTable = {}
    for var=1, size do
        valTable[var] = {valPlist["title"..var],valPlist["image"..var],valPlist["text"..var]}
    end
    
    return valTable
end

function GameNoticeMgr.checkProto(scene)
    local boolChecked = UserSettings.get("check", 15)
    if boolChecked then
        return
    end
    local txtFileName = "Config/Proto.txt"
    local fileExist = cc.FileUtils:getInstance():isFileExist(txtFileName)
    if not fileExist then
    	return
    end
    
    local res = "UI/Login/Proto.csb"
    CSResourceMgr.createRes(scene, res):zorder(CocosModuleMgr.ZORDER_GUIDE)
    CSResourceMgr.setRelativePosition(res, 320, 480)
    local diff = CocosModuleMgr.getScreenSizeDiff()
    local db = CSResourceMgr.getNodeByName(res, "db")
    local dsize = db:getContentSize()
    db:setContentSize(dsize.width, dsize.height+diff)
    CSResourceMgr.clickEventBinding(res, "ok", function()
        UserSettings.set({check=1}, 15)
        CSResourceMgr.removeList(res, "list")
    	CSResourceMgr.removeCSObjectByTag(res)
    end)
    local checkBoxVec = {}
    
    local function setList(filename, listname, titlename, listdbname, titledbname, checkname, infoname)
        CSResourceMgr.setLabelString(res, infoname, "tips49", nil, {r=0,g=0,b=0,a=255,s=1,w=1}, nil, 240)
        CSResourceMgr.getNodeByName(res, infoname):show()
        local checkbox = CSResourceMgr.getNodeByName(res, checkname)
        checkbox:show()
        table.insert(checkBoxVec, checkbox)
        checkbox:addEventListener(function()
            local isselected = true
            for var=1, #checkBoxVec do
                if not checkBoxVec[var]:isSelected() then
            		isselected = false
            		break
            	end
            end
            CSResourceMgr.setButtonEnabled(res, "ok", isselected)
        end)
    
        local ProtoReader = TxtReader.new(filename)
        ProtoReader.init({"id", "content", "color", "size"}, 1)

        if titledbname then
            local tdb = CSResourceMgr.getNodeByName(res, titledbname)
            local dposy = tdb:getPositionY()
            tdb:setPositionY(dposy+diff)
            tdb:show()
        end
        if listdbname then
            local listdb = CSResourceMgr.getNodeByName(res, listdbname)
            local ldbsize = listdb:getContentSize()
            listdb:setContentSize(ldbsize.width, ldbsize.height+diff)
            listdb:show()
        end
        local list = CSResourceMgr.getNodeByName(res, listname)
        local lsize = list:getContentSize()
        list:setContentSize(lsize.width, lsize.height+diff)
        list:show()
        local title = CSResourceMgr.getNodeByName(res, titlename)
        local tposy = title:getPositionY()
        title:setPositionY(tposy+diff)
        title:show()

        local function addLabel(n)
            local data = ProtoReader.get(n)
            if not data then
                return
            end
            local cLabel = CSResourceMgr.getNodeByName(res, "text"):clone()
            if data.color then
                local colorVec = lua_string_split(data.color, ",")
                if colorVec then
                    CSResourceMgr.setLabelColorByNode(cLabel, {r=colorVec[1] or 255, g=colorVec[2] or 255, b=colorVec[3] or 255, a=255})
                end
            end
            if data.size then
                cLabel:setFontSize(data.size)
            end
            if data.content then
                local content = string.gsub(data.content, "\\n", "\n")
                CSResourceMgr.setLabelStringByNode(cLabel, content, nil, -1)
                CSResourceMgr.setLabelMaxWidthByNode(cLabel, lsize.width, -1)
            else
                CSResourceMgr.setLabelStringByNode(cLabel, "", nil, -1)
            end
            list:pushBackCustomItem(cLabel)
            addLabel(n+1)
        end
        addLabel(2)
        
        CSResourceMgr.setLabelString(res, titlename, ProtoReader.get(1).content, nil, {r=0,g=0,b=0,a=255,s=1,w=1}, nil, lsize.width-15)
        return checkbox
    end
    
    local txtFileNameEx = "Config/Proto2.txt"
    local fileExistEx = cc.FileUtils:getInstance():isFileExist(txtFileNameEx)
    if not fileExistEx then
        setList(txtFileName, "list", "title", nil, "tdb", "check", "info")
    else
        setList(txtFileName, "list1", "title1", "listdb1", nil, "check1", "info1"):setSelected(false)
        setList(txtFileNameEx, "list2", "title2", "listdb2", nil, "check2", "info2"):setSelected(false)
        CSResourceMgr.setButtonEnabled(res, "ok", false)
    end
end

function GameNoticeMgr.checkNotice(scene)
    if isGameNoticeShown then
    	return
    end
    local server = "http://192.168.240.1:8080/"
    local function callback(event)
        local ok = (event.name == "completed")
        local request = event.request
        if event.name then print("request event.name = " .. event.name) end
        if not ok then
            if request:getErrorMessage()~="" then
                print("请求失败 "..request:getErrorMessage())
            end
            return
        end
        local code = request:getResponseStatusCode()
        if code ~= 200 then
            print("请求错误，代码 "..request:getResponseStatusCode())
            return
        end
        print("game notice: ", string.char(request:getResponseString()))
        DialogBoxMgr.showSmallDialogBox(scene, 1, request:getResponseString(), nil, nil, nil, false)
        isGameNoticeShown = true
    end

    local urlStr = server.."gamenotice.txt"
    local request = network.createHTTPRequest(callback, urlStr, "GET")
    print("Download Url:"..urlStr)
    request:setTimeout(10)
    request:start()
end

return GameNoticeMgr