--[[
For quick-cocos2d-x
SocketTCP lua
@author zrong (zengrong.net)
Creation: 2013-11-12
Last Modification: 2013-12-05
@see http://cn.quick-x.com/?topic=quickkydsocketfzl
]]
local SOCKET_TICK_TIME = 0.1 			-- check socket data interval
local SOCKET_RECONNECT_TIME = 5			-- socket reconnect try interval
local SOCKET_CONNECT_FAIL_TIMEOUT = 3	-- socket failure timeout

local STATUS_CLOSED = "closed"
local STATUS_NOT_CONNECTED = "Socket is not connected"
local STATUS_ALREADY_CONNECTED = "already connected"
local STATUS_ALREADY_IN_PROGRESS = "Operation already in progress"
local STATUS_TIMEOUT = "timeout"

local PROTOL_HEAD_LEN = 2
local RECEIVE_SUCCESS = 1
local RECEIVE_ERROR = 2
local RECEIVE_WAIT = 3

local scheduler = require("framework.scheduler")
local socket = require("socket")
local NetLog = require("Net.NetLog")

local SocketTCP = class("SocketTCP")

SocketTCP.EVENT_DATA = "SOCKET_TCP_DATA"
SocketTCP.EVENT_CLOSE = "SOCKET_TCP_CLOSE"
SocketTCP.EVENT_CLOSED = "SOCKET_TCP_CLOSED"
SocketTCP.EVENT_CONNECTED = "SOCKET_TCP_CONNECTED"
SocketTCP.EVENT_CONNECT_FAILURE = "SOCKET_TCP_CONNECT_FAILURE"

SocketTCP._VERSION = socket._VERSION
SocketTCP._DEBUG = socket._DEBUG

function SocketTCP.getTime()
	return socket.gettime()
end

function SocketTCP:ctor(__host, __port, __retryConnectWhenFailure)

	cc.GameObject.extend(self)
		:addComponent("framework.cc.components.behavior.EventProtocol")
		:exportMethods()

    self.host = __host
    self.port = __port
	self.tickScheduler = nil			-- timer for data
	self.reconnectScheduler = nil		-- timer for reconnect
	self.connectTimeTickScheduler = nil	-- timer for connect timeout
	self.name = 'SocketTCP'
	self.tcp = nil
	self.isRetryConnect = __retryConnectWhenFailure
	self.isConnected = false

	self.protoHead = ""
	self.protoPartial = ""

end

function SocketTCP:setName( __name )
	self.name = __name
	return self
end

function SocketTCP:setTickTime(__time)
	SOCKET_TICK_TIME = __time
	return self
end

function SocketTCP:setReconnTime(__time)
	SOCKET_RECONNECT_TIME = __time
	return self
end

function SocketTCP:setConnFailTime(__time)
	SOCKET_CONNECT_FAIL_TIMEOUT = __time
	return self
end
	
local function isSupportIpv6(_domain)
    local result = socket.dns.getaddrinfo(_domain)
    local ipv6 = false
    if result then
        for k,v in pairs(result) do
            if v.family == "inet6" then
                ipv6 = true
                break
            end
        end
    end
    return ipv6
end

function SocketTCP:connect(__host, __port, __retryConnectWhenFailure)
	if __host then self.host = __host end
	if __port then self.port = __port end
	if __retryConnectWhenFailure ~= nil then self.isRetryConnect = __retryConnectWhenFailure end
	assert(self.host or self.port, "Host and port are necessary!")
	--printInfo("%s.connect(%s, %d)", self.name, self.host, self.port)
	local errMsg = nil
	if isSupportIpv6(__host) then
		self.tcp, errMsg = socket.tcp6()
	else
		self.tcp, errMsg = socket.tcp()
	end

	if (nil == self.tcp) then
		print("socket.tcp() failed!")
		print(errMsg)
		return
	end
	self.tcp:settimeout(0)

	self.waitConnect = 0
	if (not self:__checkConnect()) then
		scheduler.performWithDelayGlobal(function() self:__connectTimeTick() end, SOCKET_TICK_TIME)
	end
end

function SocketTCP:__checkConnect()
	local __succ = self:_connect()
	if __succ then
		self:_onConnected()
	end
	return __succ
end

function SocketTCP:__connectTimeTick()
	if self.isConnected then
		return
	end
	if (not self:__checkConnect()) then
		self.waitConnect = self.waitConnect + SOCKET_TICK_TIME
		if (self.waitConnect >= SOCKET_CONNECT_FAIL_TIMEOUT) then
			self.waitConnect = 0
			self:close()
			self:_connectFailure()
		else
			scheduler.performWithDelayGlobal(function() self:__connectTimeTick() end, SOCKET_TICK_TIME)
		end
	end
end

function SocketTCP:send(__data)
	assert(self.isConnected, self.name .. " is not connected.")
	return self.tcp:send(__data)
end

function SocketTCP:close( ... )
	--printInfo("%s.close", self.name)
	self.tcp:close();
	if self.connectTimeTickScheduler then scheduler.unscheduleGlobal(self.connectTimeTickScheduler) end
	if self.tickScheduler then scheduler.unscheduleGlobal(self.tickScheduler) end
	self:dispatchEvent({name=SocketTCP.EVENT_CLOSE})
end

-- disconnect on user's own initiative.
function SocketTCP:disconnect()
	if self.tickScheduler then scheduler.unscheduleGlobal(self.tickScheduler) end
	self:_disconnect()
	self.isRetryConnect = false -- initiative to disconnect, no reconnect.
end

--------------------
-- private
--------------------

--- When tcp is nil,create it
function SocketTCP:_createTcp()
	local errMsg = nil
	self.tcp, errMsg = socket.tcp()
	if (nil == self.tcp) then
		print("socket.tcp() failed!")
		print(errMsg)
		return false
    else
        return true
	end
end
--- When connect a connected socket server, it will return "already connected"
-- @see: http://lua-users.org/lists/lua-l/2009-10/msg00584.html
function SocketTCP:_connect()
    if self.tcp == nil then 
        
        local ret = SocketTCP:_createTcp()
        print("tcp is nil,SocketTCP:_connect(),result is:")
        if ret == false then return ret end
    end
	local __succ, __status = self.tcp:connect(self.host, self.port)
	local ret = (__succ == 1 or __status == STATUS_ALREADY_CONNECTED)
	if (ret) then
		local ip, port, xo = self.tcp:getpeername()
		print("getpeername:", ip, port, xo)
		NetLog.log("getpeername: " .. ip .. " " .. port .. " " .. xo)

		ip, port, xo = self.tcp:getsockname()
		print("getsockname:", self.tcp:getsockname())
		NetLog.log("getsockname: " .. ip .. " " .. port .. " " .. xo)
	end
	return ret
end

function SocketTCP:_disconnect()
	self.isConnected = false
	if (nil ~= self.tcp) then
		self.tcp:shutdown()
		self.tcp = nil
		self:dispatchEvent({name=SocketTCP.EVENT_CLOSED})
	end
end

function SocketTCP:_onDisconnect()
	--printInfo("%s._onDisConnect", self.name);
	self.isConnected = false
	self:dispatchEvent({name=SocketTCP.EVENT_CLOSED})
	self:_reconnect();
end

-- connecte success, cancel the connection timerout timer
function SocketTCP:_onConnected()
	--printInfo("%s._onConnectd", self.name)
	self.isConnected = true
	self:dispatchEvent({name=SocketTCP.EVENT_CONNECTED})
	if self.connectTimeTickScheduler then scheduler.unscheduleGlobal(self.connectTimeTickScheduler) end

	-- start to read TCP data
	self.tickScheduler = scheduler.scheduleGlobal(function() self:__tick() end, SOCKET_TICK_TIME)
end

function SocketTCP:__tick()

	local rcvCount = 0
	while true do
		if (false == self.isConnected) then
			break
		end

		local ret = self:receive()
		if (RECEIVE_SUCCESS == ret) then
			rcvCount = rcvCount + 1
			if (rcvCount >= 20) then
				break
			end
		else
			break
		end
	end

end

function SocketTCP:receive()

	local __body, __status, __partial = self.tcp:receive("*a")
	--print("__bodyxp", __body, "__status", __status, "__partial", __partial)

	if (__status == STATUS_CLOSED or __status == STATUS_NOT_CONNECTED) then
		print("[ERR] Receive error1. __status: " .. __status)
		NetLog.log("Receive error1. __status: " .. __status)

    	self:close()
    	if self.isConnected then
    		self:_onDisconnect()
    	else
    		self:_connectFailure()
    	end
   		return RECEIVE_ERROR
	end

	if (__body and __partial) then
		__body = __body .. __partial
	elseif (__partial) then
		__body = __partial
	end

	if (nil == __body) then
		print("[ERR] Receive error2. __status: " .. __status)
		NetLog.log("Receive error2. __status: " .. __status)
		return RECEIVE_ERROR
	elseif (#__body > 0) then
		NetLog.log("Receive. __body: -[\"" .. __body .. "\"]-")
	end

	self.protoPartial = self.protoPartial .. __body
	if ("" == self.protoHead) then
		local ret = self:receiveHead()
		if (RECEIVE_SUCCESS == ret) then
			return self:receiveBody()
		else
			return ret
		end
	else
		return self:receiveBody()
	end

end

function SocketTCP:receiveHead()

	if (#self.protoPartial >= PROTOL_HEAD_LEN) then
		self.protoHead = string.sub(self.protoPartial, 1, PROTOL_HEAD_LEN)
		self.protoPartial = string.sub(self.protoPartial, PROTOL_HEAD_LEN + 1)
		return RECEIVE_SUCCESS
	else
		return RECEIVE_WAIT
	end

end

function SocketTCP:receiveBody()

	if (self.protoHead == "") then
		return RECEIVE_ERROR
	end

	local msg = require("Net.ByteArray").new()
	msg:writeBuf(self.protoHead)
	msg._pos = 1
	local needLen = msg:readUShort() - PROTOL_HEAD_LEN
	
	if (#self.protoPartial >= needLen) then
		local protoHead, protoPartial = self.protoHead, self.protoPartial
		self.protoHead = ""
		self.protoPartial = string.sub(self.protoPartial, needLen + 1)
		local msg2 = fcdat.CDatMgr:getDatMgr():getFreeEntry(protoHead .. string.sub(protoPartial, 1, needLen))
		self:dispatchEvent({name = SocketTCP.EVENT_DATA, data = msg2})
		return RECEIVE_SUCCESS
	else
		return RECEIVE_WAIT
	end

end

function SocketTCP:_connectFailure(status)
	--printInfo("%s._connectFailure", self.name);
	self:dispatchEvent({name=SocketTCP.EVENT_CONNECT_FAILURE})
	self:_reconnect();
end

-- if connection is initiative, do not reconnect
function SocketTCP:_reconnect(__immediately)
	if not self.isRetryConnect then return end
	printInfo("%s._reconnect", self.name)
	if __immediately then self:connect() return end
	if self.reconnectScheduler then scheduler.unscheduleGlobal(self.reconnectScheduler) end
	local __doReConnect = function ()
		self:connect()
	end
	self.reconnectScheduler = scheduler.performWithDelayGlobal(__doReConnect, SOCKET_RECONNECT_TIME)
end

return SocketTCP
