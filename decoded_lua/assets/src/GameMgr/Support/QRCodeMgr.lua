local QRCodeMgr = {}

local errorLangKey = ""

function QRCodeMgr.Init()
    errorLangKey = "qrcode3"
end

function QRCodeMgr.getQRCode(key)
	print("QRCodeMgr.getQRCode(key):----------"..key)
    if key=="" then
    	key = nil
    end
    key = key or "null"
	local charID = CharInfo.getCharID()
    local fileName = "qr__"..charID..".jpg"
    local fileExist = cc.FileUtils:getInstance():isFileExist(fileName)
    if fileExist then
        return fileName
    end
    if device.platform == "ios" then
        local fullPath = CONFIG_STORE_PATH..fileName
        local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getQRCode", {filePath=fullPath, key=key})
        if ok then
            print("生成二维码成功")
        else
            StandardTipsMgr.show(1, errorLangKey)
        end
    elseif device.platform == "android" then
        local fullPath = CONFIG_STORE_PATH
        local code = key
        local picname = "qr__"..charID
        print("fullPath ,code,picname is.........",fullPath,code,picname)
        --写luaj
        local args = {fullPath,code,picname}
        local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
        local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/FCSdk", "getQRCode", args, sig)
        if ok then 
            --StandardTipsMgr.show(1, CONFIG_STORE_PATH..picname)
            print("生成二维码成功")
        else
            StandardTipsMgr.show(1, errorLangKey)
        end
    else
        fileName = "qrcode.jpg"
        StandardTipsMgr.show(1, "Current Platform do not support")
    end
    return fileName
end



function QRCodeMgr.scanQRCode(callback)
    if device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "scanQRCode", {listener=function(key)
        	if callback then
        		callback(key)
        	end
        end})
        if ok then
            print("开始扫描二维码")
        else
            StandardTipsMgr.show(1, errorLangKey)
        end
    elseif device.platform == "android" then
        AndroidFunction.scanCodeCallBack = callback
        --写luaj
        local luacallbackname = "globalOnScanCodeResult"
        local args = {luacallbackname}
        local sig = "(Ljava/lang/String;)V"
        local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/FCSdk", "scanQRCode", args, sig)  
        if ok then 
            print("开始扫描二维码")
        else
            StandardTipsMgr.show(1, errorLangKey)      
        end     
    else
        StandardTipsMgr.show(1, "Current Platform do not support")
    end
end

function QRCodeMgr.quitScanQRCode()
    if device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "quitScanQRCode", nil)
        if ok then
            print("取消扫描二维码")
        else
            StandardTipsMgr.show(1, errorLangKey)
        end
    elseif device.platform == "android" then
        --写luaj
    else
        StandardTipsMgr.show(1, "Current Platform do not support")
    end
end

return QRCodeMgr