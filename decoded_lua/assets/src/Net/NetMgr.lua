require("src.Net.Proto.ProtoInclude")

local NetMgr = {}
local GenInfo = require("src.Data.GenInfo")
local Reconnector = nil
local HDVector = require("src.Utils.HDVector")
local scheduler = require("framework.scheduler")
local NetLog = require("src.Net.NetLog")
local GenUtils = require("Utils.GenUtils")
NetMgr.isWhiteNameUser = false
local usernameForCheck = ""


local serverIP = ""
local serverPort = "" 
local world = 1
local PING_TIMEOUT = 1000
NetMgr.IS_SERVERLIST_PUBLISH = nil

ServerIPMrg = require("src.Net.ServerIPMrg")


local serverListAddress = "http://192.168.240.1:8080/mxm/serverList"
local worldListAddress = "http://192.168.240.1:8080/mxmevoListWorld?channel=android"--"http://139.196.249.157:8300/mxmevoListWorld?channel=dev"--
local gameServerAddress = {{"192.168.240.1",5568}}--卓游{{"139.196.249.157",8300}}--
local errorReportAddress = "http://192.168.240.1:8080/debug.clientlog"
local queryPlatformCharacterAddress = "http://192.168.240.1:8080/mxmevoListUserCharacters"--"http://116.228.6.173:11105/mxmevoListUserCharacters"
local queryDeviceCharacterAddress = "http://192.168.240.1:8080/mxmevoGetCharBriefByDevice"--"http://116.228.6.173:11105/mxmevoGetCharBriefByDevice"
local isWhiteUserAddress = "http://192.168.240.1:8080/isWhiteUser?"--"http://116.228.6.173:11105/mxmevoGetCharBriefByDevice"

serverListAddress, worldListAddress , gameServerAddress ,errorReportAddress ,queryPlatformCharacterAddress,queryDeviceCharacterAddress ,isWhiteUserAddress,NetMgr.IS_SERVERLIST_PUBLISH  = ServerIPMrg.getServerIPInfo()

----Tips: you'd better not use Chinese in this file.

function NetMgr.init()
    print("NetMgr::init")
    NetMgr.disconnect()
    NetMgr.socket = nil

    NetMgr.socket = require("src.Net.HDSocketTCP").new(NetMgr.SERVER_GATE)

    NetMgr.checkSysPingFlag = false
    NetMgr.sysPingTime = 0
    NetMgr.updateScheduler = scheduler.scheduleGlobal(NetMgr.update, 1)

    if nil == NetMgr.msgQueue then
        NetMgr.msgQueue = {}
        HDVector.extend(NetMgr.msgQueue)
    end 

    require("src.Net.Process.LoginProcess").init()
    require("src.Net.Process.NewQuestProcess").init()
    require("src.Net.Process.PetProcess").init()
    require("src.Net.Process.PVPProcess").init()
    require("src.Net.Process.ChatProcess").init()
    require("src.Net.Process.AdventureProcess").init()
    require("src.Net.Process.PVEProcess").init()
    require("src.Net.Process.ItemProcess").init()
    require("src.Net.Process.ExploreProcess").init()
    require("src.Net.Process.ArenaProcess").init()
    require("src.Net.Process.PetEducationProcess").init()
    require("src.Net.Process.AchievementProcess").init()
    require("src.Net.Process.LostTowerProcess").init()
    require("src.Net.Process.TerritorialProcess").init()
    require("src.Net.Process.MailProcess").init()
    require("src.Net.Process.FashionProcess").init()
    require("src.Net.Process.CommonShopProcess").init()
    require("src.Net.Process.IMProcess").init()
    require("src.Net.Process.ChatUserProcess").init()
	require("src.Net.Process.LifeSkillProcess").init()	
	require("src.Net.Process.SigninProcess").init()    
	require("src.Net.Process.HomeProcess").init()
    require("src.Net.Process.MarketProcess").init()
    require("src.Net.Process.MonthCardProcess").init()
    require("src.Net.Process.FamilyProcess").init()    
    require("src.Net.Process.PortalProcess").init()
    require("src.Net.Process.FashionShowProcess").init()
    require("src.Net.Process.ActivateCodeProcess").init()
    require("src.Net.Process.MessageBoardProcess").init()
    require("src.Net.Process.VipProcess").init()
    require("src.Net.Process.NewShopProcess").init()
    require("src.Net.Process.WishingTreeProcess").init()
    require("src.Net.Process.ActivityProcess").init()
    require("src.Net.Process.TeamProcess").init()
    require("src.Net.Process.TreasureBoxProcess").init()
    require("src.Net.Process.BulletinProcess").init()
    require("src.Net.Process.WorldBossProcess").init()
    require("src.Net.Process.PetEquipProcess").init()
    require("src.Net.Process.ExpeditionProcess").init()
    require("src.Net.Process.OrderManProcess").init()
    require("src.Net.Process.WArenaProcess").init()
    --<For auto script, please do not change or delete this code!>--

    if serverIP == "" or serverPort == "" then
        serverIP = "192.168.240.1"
        serverPort = 5568
    end
    NetMgr.setCheckSysPing(false)
    
    cc.DebugHelper:SetErrorReportURL(errorReportAddress)
    cc.DebugHelper:AddErrorReportInfo("packageVer", "1")
    cc.DebugHelper:AddErrorReportInfo("platform", "1")
end

function NetMgr.setBlockMsgOnReconnected(blockMsg)
	NetMgr.blockMsgOnReconnected = blockMsg
end

-- connect

function NetMgr.connect(listener)
    print("connect game server ip:"..serverIP..", port:"..serverPort)
    NetMgr.socket:connect(serverIP,serverPort,listener)
end

-- disconnect

function NetMgr.disconnect()
    if nil ~= NetMgr.socket then
        NetMgr.socket:disconnect()
        NetMgr.socket = nil
     end
    NetMgr.setCheckSysPing(false)
end

-- send

function NetMgr.send(func, data)
    if (nil == func) then
        assert(false)
        return
    end
    local msg = NetMgr.newMsg()
    func(msg, data)
    NetMgr.updateMsgLen(msg)
--[[
    if not NetInterface.isConnect then
        TipsMgr.show(SceneMgr.getRunningScene, "reconnect server...")
        NetInterface.connectServer(function()
            NetMgr.send(func, data)
        end)
        return
    end
]]
    if not NetInterface.isConnect then
        print("send message failed:save message...")
        NetMgr.msgQueue:push_back(msg)
    else
        NetMgr.socket:send(msg)
    end

end

function NetMgr.sendDirect(msg)

    NetMgr.socket:send(msg)

end

function NetMgr.newMsg()

    local msg = require("src.framework.cc.utils.ByteArray").new()
    msg:writeUShort(0xCDCD)
    return msg

end

function NetMgr.updateMsgLen(msg)

    msg._pos = 1
    msg:writeUShort(msg:getLen())

end

-- process

function NetMgr.addProcess(id, func)

    NetMgr.socket:addProcess(id, func)
end

-- ping

function NetMgr.onSysPing_Req(server)
    if NetMgr.socket == nil then
        return
    end
    if false == NetInterface.isConnect then
        return
    end
    NetMgr.sysPingTime = os.clock()
    NetMgr.sendSysPing_Ack()
    print("send ping", server)
end

function NetMgr.sendSysPing_Ack(socket)

    local msg = NetMgr.newMsg()
    msg:writeUShort(Proto.CommandL.SYSPING_ACK)
    NetMgr.updateMsgLen(msg)
    NetMgr.socket:send(msg)

end

function NetMgr.setCheckSysPing(flag)

    NetMgr.checkSysPingFlag = flag
    if (true == flag) then
        NetMgr.sysPingTime = os.clock()
        NetLog.log("setCheckSysPing: true")
    else
        NetMgr.sysPingTime = 0
        NetLog.log("setCheckSysPing: false")
    end

end

local poorNetTest = 0
local startDisconTime = os.clock()
function NetMgr.update()
    if -1 == g_userID then
        return
    end
    if (true == NetMgr.checkSysPingFlag) then
        local interval = os.clock() - NetMgr.sysPingTime
        if (interval > PING_TIMEOUT) then
            NetMgr.disconnect()
        end
    end

    if poorNetTest >0 then 
        --math.randomseed(tostring(os.time()):reverse():sub(1, 6)) 
        local randomnum = math.random(100)
        --print("Yaaaaaa.........randomnum is:"..randomnum)
        local timediff =os.clock()-startDisconTime
        if poorNetTest >=randomnum and timediff >10 then 
            startDisconTime = os.clock()
            if NetInterface.isConnect then
                --print("Yaaaaaa......... network crashed!!!! heiheihei:"..randomnum) 
                NetMgr.disconnect()
            end
        end
    end

    if not NetInterface.isConnect and (not NetInterface.isWaiting) then
        print("NetMgr.update:server disconnected...")
        if NetMgr.reconnector == nil then
            print("NetMgr.update:init reconnector")
            NetMgr.reconnector = require("src.Net.Reconnector")
            NetMgr.reconnector.init(NetMgr.onReconnected)  
            
        end
        if  NetMgr.reconnector.reconnecting() == false then
            print("NetMgr.update:call reconnector.reconnectImp")
            NetMgr.reconnector.reconnectImp()
        elseif NetMgr.reconnector.reconnecting() == nil then
            print("NetMgr.update:server disconnected reconnector is null")  
        elseif NetMgr.reconnector.reconnecting() == true then
            print("NetMgr.update:server disconnected reconnector is true")  
        end

    end
end

-- reconnect

function NetMgr.onReconnected()
    if #NetMgr.msgQueue > 0 then
        print("Send msg in msg queue:",#NetMgr.msgQueue)
        for i = 1, #NetMgr.msgQueue do
            NetMgr.sendDirect(NetMgr.msgQueue[i])
        end
        NetMgr.msgQueue:clear()
    end 
    NetMgr.setCheckSysPing(false)
	NetInterface.resend()
--	if NetMgr.blockMsgOnReconnected ~= nil then
--		NetInterface.sendWithBlock(NetMgr.blockMsgOnReconnected.ackName, NetMgr.blockMsgOnReconnected.func, 
--          NetMgr.blockMsgOnReconnected.successCallback, NetMgr.blockMsgOnReconnected.errorCallback)
--		NetMgr.blockMsgOnReconnected = nil
--	end
end

function NetMgr.setServerInfo(ip,port)
    print("NetMgr.setServerInfo:",ip,port)
    serverIP = ip
    serverPort = port 
end

function NetMgr.getServerList()
    local function callback(event)
        local ok = (event.name == "completed")
        local request = event.request
        if event.name then print("request event.name = " .. event.name) end
        if not ok then
            if request:getErrorMessage()~="" then
                print("request serverList failed"..request:getErrorMessage())
                --TipsMgr.show(SceneMgr.getRunningScene, "request serverList failed ,use default server")
                TipsMgr.show(SceneMgr.getRunningScene, "tips56")
                --[[
                NetInterface.connectServer(function()
                    LoginViewMgr.autoLogin()
                end)
                ]]
                SceneMgr.getRunningScene:performWithDelay(function()
                    NetMgr.getServerList()
                end, 1)
                
            end
            return
        end
        local code = request:getResponseStatusCode()
        if code ~= 200 then
            --TipsMgr.show(SceneMgr.getRunningScene, "request serverList failed ,use default server")
            TipsMgr.show(SceneMgr.getRunningScene, "tips56")
            --[[
            NetInterface.connectServer(function()
                LoginViewMgr.autoLogin()
            end)
            ]]
           SceneMgr.getRunningScene:performWithDelay(function()
                    NetMgr.getServerList()
                end, 1)
            return
        end
        
        local responseString = request:getResponseString() 
        print("serverList response:"..responseString)
        
        local serverList = {}
		if NetMgr.IS_SERVERLIST_PUBLISH == nil then
			local serverListString = GenUtils.splitString(responseString, "\n")
			for i=1,#serverListString do
				local serverInfo = {}
				if serverListString[i] ~= "" then
					print("server:",serverListString[i])
					local temp = GenUtils.splitString(serverListString[i],":")
					serverInfo.desc = temp[1]
					serverInfo.zoneID = i
					if temp[4] == "" or temp[4] == nil then
						serverInfo.world = "1"
					else
						serverInfo.world = temp[4]
					end
					
					if temp[5] == "" or temp[5] == nil then
						serverInfo.hot = 1
					else
						serverInfo.hot = temp[5] * 1
					end
					
					if temp[6] == "" or temp[6] == nil then
						serverInfo.isNew = 0
					else
						serverInfo.isNew = temp[5] * 1
					end

					serverInfo.ip = temp[2]
					print("port:" .. temp[3])
					serverInfo.port = temp[3]*1
					table.insert(serverList, serverInfo)
				end
			end
		else
			local cjson = require("cjson")
            local j = cjson.decode(responseString)
			for i=1,#j["worlds"] do
				if j["worlds"][i]["id"] ~= nil or j["worlds"][i]["name"] ~= nil then
					local serverInfo = {}
					serverInfo.zoneID = i
					serverInfo.world = j["worlds"][i]["id"]
					serverInfo.desc = j["worlds"][i]["name"]
					serverInfo.hot = j["worlds"][i]["state"]
					if serverInfo.hot == nil then
						serverInfo.hot = 0
					end
					serverInfo.isNew = j["worlds"][i]["isNew"]
					if serverInfo.isNew == nil then
						serverInfo.isNew = 0
					end
					serverInfo.ip = gameServerAddress[i%(#gameServerAddress) + 1][1]
					serverInfo.port = gameServerAddress[i%(#gameServerAddress) + 1][2]
					if iOSFunction.isReviewVer() then
						if serverInfo.desc == "test1" then
							table.insert(serverList, serverInfo)
						end
					else
						table.insert(serverList, serverInfo)
					end
				end
			end
		end
        
        for i=1,#serverList do
            print("server:",serverList[i].desc)
        end
        LoginViewMgr.setServerListData(serverList)
    end

    local function whiteListCallBack(event)
        local ok = (event.name == "completed")
        local request = event.request
        if event.name then print("request event.name = " .. event.name) end
        if not ok then
            if request:getErrorMessage()~="" then
                print("request whiteList failed"..request:getErrorMessage())
            
            end
            return
        end
        local code = request:getResponseStatusCode()
        if code ~= 200 then
            print("request whiteList failed code is not 200")
            return
        end
        
        local responseString = request:getResponseString() 
        print("whiteList response:"..responseString)     
        local cjson = require("cjson")
        local j = cjson.decode(responseString) 
        NetMgr.isWhiteNameUser = j["ret"]   
    end

    local function getIsWhiteListUser()
        local whiteListStr = isWhiteUserAddress.."username="..usernameForCheck.."&mac="..AndroidFunction.getMacAddress()
        local whitelistrequest = network.createHTTPRequest(whiteListCallBack, whiteListStr, "GET")
        print("whiteList Url:"..whiteListStr)
        whitelistrequest:setTimeout(10)
        whitelistrequest:start()   
    end
	
	local function callback2(event)
        local ok = (event.name == "completed")
        local request = event.request
        if event.name then print("request event.name = " .. event.name) end
        if not ok then
			print("callback2 not ok:"..request:getErrorMessage())   
			return
        end
        local code = request:getResponseStatusCode()
        if code ~= 200 then
            print("callback2 not ok2:"..request:getErrorMessage())
            return
        end
        
        local responseString = request:getResponseString() 
        print("callback2 response:"..responseString)
        LoginViewMgr.setCharInfo(responseString)
        getIsWhiteListUser()
	end
	
	local function callback3(event)
        local ok = (event.name == "completed")
        local request = event.request
        if event.name then print("request event.name = " .. event.name) end
        if not ok then
			print("callback3 not ok:"..request:getErrorMessage())
			return
        end
        local code = request:getResponseStatusCode()
        if code ~= 200 then
            print("callback3 not ok2:"..request:getErrorMessage())
            return
        end
        
        local responseString = request:getResponseString() 
        print("callback3 response:"..responseString)
        LoginViewMgr.setCharInfo(responseString)
	end


    
    --[[
    local function urlencode(s)
        -- convert line endings
        s = string.gsub(tostring(input), "\n", "\r\n")
        s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
        return string.gsub(s, " ", "+")
    end
    ]]
    local urlStr = serverListAddress
	if NetMgr.IS_SERVERLIST_PUBLISH ~= nil then
		urlStr = worldListAddress
	end
    local request = network.createHTTPRequest(callback, urlStr, "GET")
    print("serverList Url:"..urlStr)
    request:setTimeout(10)
    request:start()
	
	if (device.platform == "android" or device.platform == "ios") and LoginViewMgr.DEBUG_MODE == false then
		local ut = getPlatform_UsernameToken()
        usernameForCheck = ut.username
		local urlStr2 = queryPlatformCharacterAddress .. "?username=" .. ut.username .. "&token=" .. ut.token
		local request2 = network.createHTTPRequest(callback2, urlStr2, "GET")
		print("queryPlatformCharacterAddress Url:"..urlStr2)
		request2:setTimeout(10)
		request2:start()
        -- getIsWhiteListUser()

    else
		local username = UserSettings.get("username_device", 6) or ""
		local password = UserSettings.get("password_device", 6) or ""
		local urlStr2 = queryDeviceCharacterAddress .. "?device=" .. username .. "&world=1&token=" .. password
		local request2 = network.createHTTPRequest(callback3, urlStr2, "GET")
		print("queryDeviceCharacterAddress2 Url:"..urlStr2)
		request2:setTimeout(10)
		request2:start()

        --[[
        local whiteListStr = "http://192.168.240.1:8080/isWhiteUser?".."username=".."@12342455".."&mac=".."FF:FF:FF:FF:FF"
        local whitelistrequest = network.createHTTPRequest(whiteListCallBack, whiteListStr, "GET")
        print("whiteList Url:"..whiteListStr)
        whitelistrequest:setTimeout(10)
        whitelistrequest:start()
        ]]
    end
	
end

function NetMgr.showNetState()
    print("show netstate:")
    print("\tNetInterface.isConnect:", NetInterface.isConnect)
    print("\tNetInterface.isWaiting:", NetInterface.isWaiting)
    print("\tNetMgr.reconnector:",NetMgr.reconnector)
end

return NetMgr



