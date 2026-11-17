require("config")
require("framework.init")
require("framework.shortcodes")
require("framework.cc.init")

local UpdateMgr  = class("UpdateMgr", function()
    return display.newScene("UpdateMgr")
end)

UpdateMgr.reviewVer = nil
local obbVersion = "1.0.128745" --该版本号必须和apk还有obb的版本号一样
local serverAndroidTestMode = false
local serverAndroidTestMode2 = false
local serverIosTestMode = false

local tips_ForDifferentLang = 
{
        --1英语
        {
            "Update",
            "It is the latest version, entering game",
            "%s.zip download failed or decompress failed",
            "Network connection failed, please try again",
            "Installing patch, please wait",
            "Downloading resource file %d%%",
            "Update Succeeded",
            "Getting version information",
            "Version information request error\n",
            "Update contents failed",
            "Current version is DEBUG version, dosen't need to update", 
            "Patch download failed",
            "Loading Resource...",
            "You are using an outdated version.\nPlease update to the latest version\nvia app store.",
            "Initializing the game,please wait",
        },
        --2繁体中
        {
            "更新",
            "已經是最新版本，不需要更新",
            "%s.zip下載失敗或解壓失敗了",
            "網路連接失敗，版本更新出錯",
            "補丁正在安裝，請稍候",
            "已下載%d%%",
            "更新成功",
            "正在獲取版本資訊",
            "版本更新資訊請求網路出錯\n",
            "更新目錄創建失敗",
            "當前版本為DEBUG版本，不需要更新", 
            "本地無法存儲，無法下載補丁",
            "資源載入中...",
            "當前版本過舊，請前往應用商店更新",
            "正在解壓資源，請稍後..",
        },
        --3简体中
        {
            "更新",
            "已经是最新版本，不需要更新",
            "%s.zip下载失败或解压失败了",
            "网络连接失败，版本更新出错",
            "补丁正在安装，请稍候",
            "已下载%d%%",
            "更新成功",
            "正在获取版本信息",
            "版本更新信息请求网络出错\n",
            "更新目录创建失败",
            "当前版本为DEBUG版本，不需要更新", 
            "本地无法存储，无法下载补丁",
            "资源加载中...",
            "当前版本过旧，请前往应用商店更新", 
            "正在解压资源，请稍候...",
        },
}
local tips = {}

UpdateLogSender   = require("src.GameMgr.Update.UpdateLogSender")
UpdateLogFunction   = require("src.GameMgr.Update.UpdateLogFunction")

--判断是否开启自动更新
local NEEDUPDATE = false

if device.platform == "android" then 
    local args = {}
    local sig = "()Ljava/lang/String;"
    local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/FCSdk", "getPackageName", args, sig)
    print("=================getPackageName===================:",ret)
    if ok and ret == "avidly.pet.alliance.gwxlm_test" then 
        serverAndroidTestMode = true
    elseif ok and ret == "avidly.pet.alliance.gwxlm_test1" then 
        serverAndroidTestMode2 = true
    end
end

if device.platform == "ios" then
    local ok, ver = luaoc.callStaticMethod("iOSsystemFunc", "getVersion", nil)
    if ok and tonumber(ver) == 9999 then
        serverAndroidTestMode = true
    end
end


--补丁地址
local server       = "http://192.168.240.1:8080/patch/"--private server
-- Private server patch endpoint is fixed above.




local versionFile  = "version.xml"
local verTmpFile   = "versiontmp.xml"
local localVersion = "1.0.00000"
local storedLocalVersion = localVersion
local newVersion   = nil

local delayTime    = 0.5

function UpdateMgr:ctor()
    
    UpdateLogSender.Init()
    local langID = self:getDeviceLanguage()
    tips = tips_ForDifferentLang[langID]

    display.newSprite("Scene/update.png", display.cx, display.cy):addTo(self)
    self.path = CONFIG_STORE_PATH
    print("Download Path: "..self.path)
    self:createDownPath(self.path)
    
    local versionPlist = cc.FileUtils:getInstance():getValueMapFromFile(self.path.."version.plist")
    localVersion = versionPlist["version"]
    if localVersion==nil then
        local filePath = cc.FileUtils:getInstance():fullPathForFilename(versionFile)
        localVersion = cc.FileUtils:getInstance():getStringFromFile(filePath)
    end    
    storedLocalVersion = string.gsub(localVersion, "\n", "")
    
    if langID==3 then
        -- self.gametip = display.newTTFLabel({
        --     font = "cuyuan_GBK.ttf",
        --     text = "抵制不良游戏      拒绝盗版游戏      注意自我保护      谨防上当受骗\n适度游戏益脑      沉迷游戏伤身      合理安排时间      享受健康生活",
        --     size = 20,
        --     align = cc.TEXT_ALIGN_CENTER, 
        --     color = display.COLOR_WHITE
        -- }):pos(display.cx, display.top-50):addTo(self)
        -- self.gametip:enableOutline({r=0,g=0,b=0,a=255}, 2)
    end 

    self.versionLabel = display.newTTFLabel({
        font = "cuyuan_GBK.ttf",
        text = string.format("ver:%s",localVersion),
        size = 36, 
        align = cc.TEXT_ALIGN_CENTER, 
        color = display.COLOR_WHITE
    }):pos(display.cx,200):addTo(self)
    self.versionLabel:enableOutline({r=0,g=0,b=0,a=255}, 1)
    self.versionLabel:setScale(0.5)
    
    self.updateProgress = self:newProgressTimer("UI/CommonFiles/achievement_progress_base_01.png", 
        "UI/CommonFiles/achievement_progress_bar_orange_01.png"):pos(display.cx, 120):addTo(self)
    self.updateProgress:setVisible(false)
    self.progressLabel  = display.newTTFLabel({
        font = "cuyuan_GBK.ttf",
        text = tips[15], 
        size = 50, 
        align = cc.TEXT_ALIGN_CENTER, 
        color = display.COLOR_WHITE
    }):pos(display.cx,160):addTo(self) 
    self.progressLabel:enableOutline({r=0,g=0,b=0,a=255}, 2)
    self.progressLabel:setScale(0.5)
    
    self.progressHud = display.newSprite("Scene/hud_big.png"):pos(display.cx,display.cy):addTo(self)
    local ani = cc.RepeatForever:create(cc.RotateBy:create(1, 180))
    self.progressHud:runAction(ani)
end


function UpdateMgr:downIndexedVersion(isTmpZip)
    --GameLogMgr1.OnGameStateChange(GameLogMgr.UserGameState.STATE_UPDATEGAME_START)
    UpdateLogSender.logUpdateStart()
    local versionUrl = server..versionFile
    if isTmpZip then
        print("检查临时补丁")
        versionUrl = server..verTmpFile
    end
    local packageUrl = ""
    if isTmpZip then 
        packageUrl = server..newVersion..".zip"
    else
        packageUrl = server..newVersion.."_"..localVersion..".zip"
    end
    
    local assetsManager = cc.AssetsManager:new(packageUrl,versionUrl,self.path)  
    assetsManager:retain() 
    
    local function onError(event)  
        print("onError:"..event)
        --GameLogMgr1.OnGameStateChange(GameLogMgr.UserGameState.STATE_UPDATEGAME_ERROR)
        
        if event==2 then
        	if not isTmpZip then
                local AssetsVersion = assetsManager:getVersion()
                cc.FileUtils:getInstance():writeToFile({version=AssetsVersion},self.path.."version.plist")
                localVersion = AssetsVersion
                UpdateLogSender.logUpdateFail()
                self:downIndexedVersion(true)
        		return
        	end
            print("经确认，临时补丁也是最新版本了")
            self.progressLabel:setString(tips[2])
            self:performWithDelay(function()
                self:afterUpdateStart()
            end, delayTime)
        elseif event==3 then
            print(localVersion..".zip下载失败或解压失败了")
            self.progressLabel:setString(string.format(tips[3],localVersion))
            UpdateLogSender.logUpdateFail()
            self:performWithDelay(function()
                self:getNewestVersion()
            end, delayTime)
        elseif event==4 then
            if isTmpZip then
                print("临时补丁下载不到，就当更新好了")
                self.progressLabel:setString(tips[7])
                self:performWithDelay(function ()
                    self:afterUpdateStart()
                end, delayTime)
            else
                print(localVersion..".zip找不到，要去下0.zip了")
                localVersion = 0
                UpdateLogSender.logUpdateFail()
                self:performWithDelay(function()
                    self:downIndexedVersion()
                end, delayTime)
            end
        elseif event==1 then
            print("当前没有网络")
            self.progressLabel:setString(tips[4])
            UpdateLogSender.logUpdateFail()
            self:performWithDelay(function()
                self:getNewestVersion()
            end, delayTime)
        elseif event==0 then
            print("本地无法存储，无法下载补丁")
            self.progressLabel:setString(tips[12])
            UpdateLogSender.logUpdateFail()
            self:performWithDelay(function()
                self:getNewestVersion()
            end, delayTime)
        end
    end

    local function onProgress(event)  
        print("onProgress:"..event)
        if event > 100 then event = 0 end
        self.progressLabel:setString(string.format(tips[6],event))
        self.updateProgress:setVisible(true)
        
        self.updateProgress.progressTimer:setPercentage(event)
        if event==100 then
            self.progressLabel:setString(tips[5])
        end
    end
    
    local function onSuccess(event)  
        print("onSuccess")
        --GameLogMgr1.OnGameStateChange(GameLogMgr.UserGameState.STATE_UPDATEGAME_SUCCESS)
        
        if not isTmpZip then
            print("正牌补丁下载完毕")
            local AssetsVersion = assetsManager:getVersion()
            cc.FileUtils:getInstance():writeToFile({version=AssetsVersion},self.path.."version.plist")
            localVersion = AssetsVersion
            self:downIndexedVersion(true)
            return
        end
        print("临时补丁下载完毕")
        self.progressLabel:setString(tips[7])
        self:performWithDelay(function ()
            self:afterUpdateStart()
        end, delayTime)
    end
      
    assetsManager:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
    assetsManager:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR)
    assetsManager:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS)
    assetsManager:setConnectionTimeout(3)  
    assetsManager:update()
    
    print("\npackageUrl:"..packageUrl.."\nversionUrl:"..versionUrl.."\nstore path:"..self.path)

    return
end


function UpdateMgr:getNewestVersion()
    self.progressLabel:setString(tips[8])

    local function callback(event)
        local ok = (event.name == "completed")
        local request = event.request
        if event.name then print("request event.name = " .. event.name) end
        if not ok then
            if request:getErrorMessage()~="" then
                print("请求失败 "..request:getErrorMessage())
                self.progressLabel:setString(tips[9]..request:getErrorMessage())
                self:performWithDelay(function ()
                    self:getNewestVersion()
                end, delayTime)
            end
            return
        end
        local code = request:getResponseStatusCode()
        if code ~= 200 then
            print("请求错误，代码 "..request:getResponseStatusCode())
            self.progressLabel:setString(tips[9]..request:getResponseStatusCode())
            self:performWithDelay(function ()
                self:getNewestVersion()
            end, delayTime)
            return
        end
        localVersion = storedLocalVersion
        print("new version:"..request:getResponseString())
        print("local version:"..localVersion)

        if request:getResponseString()~=localVersion then
            local newList   = string.split(request:getResponseString(), ".")
            local localList = string.split(localVersion, ".")
            if table.getn(newList)~=3 or table.getn(localList)~=3 then
                print("服务器或本地version.txt格式错误，版本更新出错")
                self:performWithDelay(function ()
                    self:getNewestVersion()
                end, delayTime)
                return
            end
            if tonumber(newList[3]) > tonumber(localList[3]) then
                print("需要更新...")
                --GameLogMgr.OnGameStateChange(GameLogMgr.UserGameState.STATE_UPDATEGAME)
                newVersion = request:getResponseString()
                self:downIndexedVersion()
            else
            	 print("超过最新版本，不需要更新")
            	 newVersion = request:getResponseString()
            	 self:downIndexedVersion(true)
            end
        else
            print("已经是最新版本，不需要更新")
            newVersion = request:getResponseString()
            self:downIndexedVersion(true)
        end
    end

    local urlStr = server..versionFile
    local request = network.createHTTPRequest(callback, urlStr, "GET")
    print("Download Url:"..urlStr)
    request:setTimeout(10)
    request:start()
end


function UpdateMgr:checkUpdateGame()
    if device.platform=="ios" or device.platform=="android" then
        local urlStr = nil
        if device.platform=="ios" then
            urlStr = server.."ver_ios.xml"
        elseif device.platform=="android" then
        	urlStr = server.."ver_android.xml"
        end
        print("Version Url:"..urlStr)

        local request = network.createHTTPRequest(function(event)
            local ok = (event.name == "completed")
            local request = event.request
            if event.name then print("request event.name = " .. event.name) end
            if not ok then
                if request:getErrorMessage()~="" then
                    print("请求失败 "..request:getErrorMessage())
                    self:performWithDelay(function ()
                        self:getNewestVersion()
                    end, delayTime)
                end
                return
            end
            local code = request:getResponseStatusCode()
            if code ~= 200 then
                print("请求错误，代码 "..request:getResponseStatusCode())
                self:performWithDelay(function ()
                    self:getNewestVersion()
                end, delayTime)
                return
            end
            
            local gameVer = tonumber(self:getGameVersion())
            local lowestVer = tonumber(request:getResponseString())
            print("lowest game version:"..lowestVer)
            print("current game version:"..gameVer)

            if lowestVer>gameVer then
                print("需要强制更新")
                self:showNeedUpdateTips()
            else
                print("不需要强制更新")
                self:getNewestVersion()
            end
        end, urlStr, "GET")
        request:setTimeout(10)
        request:start()
    else
        self:getNewestVersion()
    end
end

function UpdateMgr:checkObbPacket()
    local function isHaveObb(versionNow,versionObb)
        local ver1 = string.split(versionNow, ".")
        local ver2 = string.split(versionObb, ".")
        print("ver1[1],ver2[1]",ver1[1],ver2[1])
        print("ver1[2],ver2[2]",ver1[2],ver2[2])
        print("ver1[3],ver2[3]",ver1[3],ver2[3])
        if tonumber(ver1[1]) == tonumber(ver2[1]) then
            if tonumber(ver1[2]) == tonumber(ver2[2]) then
                if tonumber(ver1[3]) == tonumber(ver2[3]) then
                    return false
                else
                    return tonumber(ver1[3]) > tonumber(ver2[3])
                end
            else
                return tonumber(ver1[2]) > tonumber(ver2[2])
            end
        else
            return tonumber(ver1[1]) > tonumber(ver2[1])
        end
    end
    print("localVersion:",localVersion.."       ".."obbVersion:",obbVersion)
    print(tostring(isHaveObb(localVersion,obbVersion)))
    if not isHaveObb(localVersion,obbVersion) then
        print("start ================")

        if device.platform == "android" then
            
            local args = {}
            local sig  = "()I"
            local ok,versioncode = luaj.callStaticMethod("org/cocos2dx/lua/FCSdk","getVersionCode",args,sig)
            print("versioncode is..............",versioncode)
           
            local packageUrl = "/mnt/sdcard/Android/obb/com.petalliance2.sea/main."..versioncode..".com.petalliance2.sea.obb"

            local versionUrl = ""
            print("obbstart:\npackageUrl:"..packageUrl.."\nversionUrl:"..versionUrl.."\nstore path:"..self.path)
            local assetsManager = cc.AssetsManager:new(packageUrl,versionUrl,self.path)  
            assetsManager:retain() 
    
            local function onError(event)  
                print("onError:"..event)
                --GameLogMgr1.OnGameStateChange(GameLogMgr.UserGameState.STATE_UPDATEGAME_ERROR)
                
                if event==2 then
                    print("obb经确认")

                    self:performWithDelay(function()
                        self:checkUpdateGame()
                    end, delayTime)
 
                elseif event==3 then
                    print(packageUrl.."解压失败了")
                    storedLocalVersion = "1.0.00000"
                    --self.progressLabel:setString(string.format(tips[3],localVersion))
                    --UpdateLogSender.logUpdateFail()
                    self:performWithDelay(function()
                        self:checkUpdateGame()
                    end, delayTime)
                elseif event==4 then
   
                    print(packageUrl.."obb.zip找不到，直接走下一步流程")
                    storedLocalVersion = "1.0.00000"
                    --UpdateLogSender.logUpdateFail()
                    self:performWithDelay(function()
                        self:checkUpdateGame()
                    end, delayTime)
                    
                elseif event==1 then
                    print("obb当前没有网络")
                    self.progressLabel:setString(tips[4])
                    --UpdateLogSender.logUpdateFail()
                    self:performWithDelay(function()
                        self:checkUpdateGame()
                    end, delayTime)
                elseif event==0 then
                    print("obb本地无法存储，无法下载补丁")
                    self.progressLabel:setString(tips[12])
                    --UpdateLogSender.logUpdateFail()
                    self:performWithDelay(function()
                        self:checkUpdateGame()
                    end, delayTime)
                end
            end

            local function onProgress(event)  
                print("onProgress:"..event)
                if event > 100 then event = 0 end
                self.progressLabel:setString(string.format(tips[15],event))
                self.updateProgress:setVisible(true)
                self.updateProgress.progressTimer:setPercentage(event)
                if event==100 then
                    self.progressLabel:setString(tips[5])
                end
            end
            
            local function onSuccess(event)  
                print("onSuccess")
                --GameLogMgr1.OnGameStateChange(GameLogMgr.UserGameState.STATE_UPDATEGAME_SUCCESS)
                print("obb解压完毕")
                cc.FileUtils:getInstance():writeToFile({version=obbVersion},self.path.."version.plist")
                self.progressLabel:setString(tips[7])
                storedLocalVersion = obbVersion
                self:performWithDelay(function ()
                    self:checkUpdateGame()
                end, delayTime)
            end
              
            assetsManager:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
            assetsManager:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR)
            assetsManager:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS)
            assetsManager:setConnectionTimeout(3)  
            assetsManager:update()
            
            print("\npackageUrl:"..packageUrl.."\nversionUrl:"..versionUrl.."\nstore path:"..self.path)
        end


        print("over ================")
    else
        self:checkUpdateGame()
    end
end

function UpdateMgr:checkReviewVersion()
    if device.platform=="ios" then
        local urlStr = server.."review_ver.xml"
        print("Version Url:"..urlStr)

        local request = network.createHTTPRequest(function(event)
            local ok = (event.name == "completed")
            local request = event.request
            if event.name then print("request event.name = " .. event.name) end
            if not ok then
                if request:getErrorMessage()~="" then
                    print("请求失败 "..request:getErrorMessage())
                    self:performWithDelay(function ()
                        self:checkUpdateGame()
                    end, delayTime)
                end
                return
            end
            local code = request:getResponseStatusCode()
            if code ~= 200 then
                print("请求错误，代码 "..request:getResponseStatusCode())
                self:performWithDelay(function ()
                    self:checkUpdateGame()
                end, delayTime)
                return
            end

            local gameVer = tonumber(self:getGameVersion())
            local reviewVer = tonumber(request:getResponseString())
            print("review game version:"..reviewVer)
            print("current game version:"..gameVer)
            
            UpdateMgr.reviewVer = reviewVer

            if reviewVer==gameVer then
                print("当前是审核版本，不下载补丁")
                self:afterUpdateStart()
            else
                self:checkUpdateGame()
            end
        end, urlStr, "GET")
        request:setTimeout(10)
        request:start()
    else
        self:checkObbPacket()
        --self:checkUpdateGame()
    end
end


function UpdateMgr:checkNetWork()
    local function callback(event)
        local ok = (event.name == "completed")
        local request = event.request
        if event.name then print("request event.name = " .. event.name) end
        if not ok then
            if request:getErrorMessage()~="" then
                print("请求失败 "..request:getErrorMessage())
                self:performWithDelay(function ()
                    self:checkNetWork()
                end, delayTime)
            end
            return
        end
        local code = request:getResponseStatusCode()
        if code ~= 200 then
            print("请求错误，代码 "..request:getResponseStatusCode())
            self:performWithDelay(function ()
                self:checkNetWork()
            end, delayTime)
            return
        end
        self:checkReviewVersion()
    end

    local urlStr = server..versionFile
    local request = network.createHTTPRequest(callback, urlStr, "GET")
    print("Download Url:"..urlStr)
    request:setTimeout(10)
    request:start()
end


function UpdateMgr:onEnter()
    if not NEEDUPDATE then
        print("当前版本为DEBUG版本，不需要更新！")
        self.progressLabel:setString(tips[11])
        self:performWithDelay(function ()
            self:noUpdateStart()
        end, delayTime)
        return
    end
    self:checkNetWork()
end


function UpdateMgr:afterUpdateStart()
    require("src.GameMgr.GameInit")
    UpdateLogSender.logUpdateEnd()
    print("更新成功，启动游戏")
    local function endcallback()
        SceneMgr.replaceScene(self, "LoginScene")
    end
    self.progressLabel:setString(tips[13])
    GameInit.Init(nil, self.updateProgress, endcallback)
end


function UpdateMgr:noUpdateStart()
    require("src.GameMgr.GameInit")

    print("DEBUG启动游戏")
    local function endcallback()
        SceneMgr.replaceScene(self, "LoginScene")
    end
    self.progressLabel:setString(tips[13])
    GameInit.Init(nil, self.updateProgress, endcallback)
end


function UpdateMgr:createDownPath(path)
    if not self:checkDirOK(path) then
        print("更新目录创建失败")
        self.progressLabel:setString(tips[10])
    end
end


function UpdateMgr:checkDirOK(path)
    require "lfs"
    local oldpath = lfs.currentdir()
    if lfs.chdir(path) then
        lfs.chdir(oldpath)
        return true
    end
    if lfs.mkdir(path) then
        return true
    end
end


function UpdateMgr:newProgressTimer(bgBarImg, progressBarImg) 
    local bg = display.newSprite(bgBarImg)
    local progressTimer = cc.ProgressTimer:create(display.newSprite(progressBarImg))
    bg.progressTimer = progressTimer
    progressTimer:setType(cc.PROGRESS_TIMER_TYPE_BAR) 
    progressTimer:setPercentage(0)
    progressTimer:setMidpoint({x=0, y=0})
    progressTimer:setBarChangeRate({x=1, y=0})
    progressTimer:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2) 
    bg:addChild(progressTimer, 140)
    return bg
end


function UpdateMgr:delAllFilesInDirectory(path)
    for file in lfs.dir(path) do
      if file ~= "." and file ~= ".." then
          local f = path..'/'..file
          local attr = lfs.attributes (f)
          assert (type(attr) == "table")
          if attr.mode == "directory" then
              self:delAllFilesInDirectory (f)
          else
              os.remove(f)
          end
      end
    end
end


function UpdateMgr:getDeviceLanguage()
    local currentLanguageType = cc.Application:getInstance():getCurrentLanguage()
    print("current language code", currentLanguageType)
    local lang = 1

    --[[
    ENGLISH=0, CHINESE=1, FRENCH=2, ITALIAN=3, GERMAN=4, SPANISH=5, DUTCH=6, RUSSIAN=7,
    KOREAN=8, JAPANESE=9, HUNGARIAN=10, PORTUGUESE=11, ARABIC==12, NORWEGIAN=13, POLISH=14]]
    if currentLanguageType == 0 then  
        lang = 1
        print("current language is English")  
    elseif currentLanguageType == 1 then
        if self:isTraditionalChinese()==true then
            lang = 2
            print("current language is Chinese hant") 
        else
            lang = 3
            print("current language is Chinese hans") 
        end
    end

    return lang
end


function UpdateMgr:isTraditionalChinese()
    if device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "isTraditionalChinese", nil)
        if ok then
            if ret==0 then
                return true
            else
                return false
            end
        else
            return false
        end
    elseif device.platform == "android" then
        local args = {}
        local sig = "()I"
        local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/GameLaguage", "isChineseTradictional", args, sig)
        if ok then
            if ret==0 then
                return true
            else
                return false
            end
        else
            return false
        end
    end
end


function UpdateMgr:getGameVersion()
    if device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getVersion", nil)
        print("iOSFunction.getVersion()", ret)
        return ret
    end

    if device.platform == "android" then
        local args = {}
        local sig = "()Ljava/lang/String;"
        local ok,versions = luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "getGameVersion", args, sig)
        if not ok then 
            print("androidFunction.getVersion() not found:ver 0") 
            return "0"
        else
            print("androidFunction.getVersion() found:ver",versions) 
            return versions  
        end
    end
    
    return "1.0"
end

local function exitGame()
    if device.platform == "android" then 
        local args = {}
        local sig = "()V"
        luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "exitApp", args, sig)     
    end 

    if device.platform == "windows" then 
        StandardTipsMgr.show(0,"windows不让退，继续测试")
    end    
end

function UpdateMgr:showNeedUpdateTips()
    local function updateAlertView(parent, messageText, okCallback)
        local function newButton(params)
            local btn = cc.ui.UIPushButton.new({ normal = params.tex[1], pressed = params.tex[2] }, {scale9 = true})
            btn:setButtonSize(params.size[1], params.size[2])
            --btn:setButtonLabel(cc.ui.UILabel.new({text = "", size = 16, color = display.COLOR_BLUE}))
            btn:onButtonPressed(function(event) end)
            btn:onButtonRelease(function(event) end)
            btn:onButtonClicked(function(event)
                if params.clickFunc then params.clickFunc() end
            end)
            btn:align(display.CENTER, params.pos[1], params.pos[2])
            btn:setLocalZOrder(params.zorder)
            return btn
        end

        local db = newButton({
            tex  = {"UI/CommonFiles/common_tips_frame.png","UI/CommonFiles/common_tips_frame.png"},
            size = {480,300},
            pos  = {display.cx, display.cy},
            zorder = 100,
            clickFunc = function() print("db...") end
        })
        db:addTo(parent)
        local label = cc.ui.UILabel.new({
            UILabelType = 2,
            size = 26,
            text  = messageText,
            font  = "cuyuan_GBK.ttf",
            x     = 0,
            y     = 0+20,
            align = cc.ui.TEXT_ALIGN_CENTER,
        })
        label:addTo(db) label:setLocalZOrder(1) label:setAnchorPoint(0.5,0.5)
        local okButton = newButton({
            tex  = {"UI/CommonFiles/gou_anniu1.png","UI/CommonFiles/gou_anniu2.png"},
            size = {130,130},
            pos  = {0,-125},
            zorder = 1,
            clickFunc = function() 
                if okCallback then okCallback() end
                --db:removeFromParent()
            end
        })
        okButton:addTo(db)

        db:setScale(0)
        transition.scaleTo(db,{scale=1.0,time=0.1})
    end
    updateAlertView(self, tips[14] or "当前版本过旧，请前往应用商店更新",
        function()
            if device.platform == "android" then
                local url = "http://192.168.240.1:8080/"
                if isAustralia then
                    server = "http://192.168.240.1:8080/"
                end
                local args = {url}
                local sig = "(Ljava/lang/String;)V"
                luaj.callStaticMethod("org/cocos2dx/lua/FCSdk", "LocalView", args, sig)   
                -- local args = {}
                -- local sig = "()V"
                -- luaj.callStaticMethod("org/cocos2dx/lua/FangCunLog", "processVersionUpdate", args, sig)               
            elseif device.platform == "ios" then
                local _appID = 1126014282
                luaoc.callStaticMethod("iOSsystemFunc", "goToUpdate", nil)
            end
            exitGame()
        end)
end


string.startWith = function(str,strStart)
    local a,_ = string.find(str,strStart)
    return a==1
end


string.split = function(s, p)
    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt
end


return UpdateMgr
