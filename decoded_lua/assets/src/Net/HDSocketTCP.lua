local HDSocketTCP = class("HDSocketTCP")
local NetMgr = require("src.Net.NetMgr")
local Eca = require("src.Eca.Eca")
local Reconnector = require("src.Net.Reconnector")
local NetLog = require("src.Net.NetLog")

function HDSocketTCP:ctor(type)

	local SocketTCP = require("src.framework.cc.net.SocketTCP")
	self.socketImp = SocketTCP.new()

	self.type = type

	self.socketImp:addEventListener(SocketTCP.EVENT_CONNECTED, function(event) self:onStatus(event) end)
	self.socketImp:addEventListener(SocketTCP.EVENT_CLOSE, function(event) self:onStatus(event) end)
	self.socketImp:addEventListener(SocketTCP.EVENT_CLOSED, function(event) self:onStatus(event) end)
	self.socketImp:addEventListener(SocketTCP.EVENT_CONNECT_FAILURE, function(event) self:onStatus(event) end)
	self.socketImp:addEventListener(SocketTCP.EVENT_DATA, function(event) self:onData(event) end)

	self.connectAddr = nil
	self.connectPort = nil
	self.connectListener = nil

	self.msgProcessor = {}

end

function HDSocketTCP:connect(addr, port, listener)

	self.connectAddr = addr
	self.connectPort = port
	self.socketImp:connect(addr, port)
	self.connectListener = listener

end

function HDSocketTCP:reconnect(listener)

	self.socketImp:connect(self.connectAddr, self.connectPort)
	self.connectListener = listener

end

function HDSocketTCP:disconnect()

	self.socketImp:disconnect()

end

require("src.framework.cc.utils.bit")

local function encode(content, key)
    local temp = nil
    local val = ""
    key = key or "4inch_MxM"
    local klen = string.len(key)
    local len = string.len(content)
    local index = 1
    for var=1, len do
        local data = string.sub(content, var, var)
        temp = bit.bxor(string.byte(data), string.byte(string.sub(key, index, index)))
        index = index+1
        if index>klen then
            index = 1
        end
        val = val..string.char(temp)
    end
    local rval = ""
    index = 1
    for var=1, len do
        local data = string.sub(val, -var, -var)
        temp = bit.bxor(string.byte(data), string.byte(string.sub(key, index, index)))
        index = index+1
        if index>klen then
            index = 1
        end
        rval = string.char(temp)..rval
    end
    return rval
end

local bEncoded = true
function HDSocketTCP:send(msg)
    
    if bEncoded then 
        print("[INFO] SendMsg id " .. msg:readUShort())

	    msg._pos = 1
	    local len = msg:readUShort()
	    local id = msg:readUShort()
        print("[INFO] SendMsg id " .. len,id)
	    msg._pos = 5
        local data1 = msg:readString(string.len(msg:getPack())-4)
        local data = encode(data1,"4inch_MxM")
        msg._pos = 5
        msg:writeString(data)
	    NetLog.log("Send: id = " .. id .. ",  " .. msg:toString(16))
        msg._pos = 1
	    self.socketImp:send(msg:getPack())
    else 
        print("[INFO] SendMsg id " .. msg:readUShort())

	    msg._pos = 1
	    local len = msg:readUShort()
	    local id = msg:readUShort()
	    msg._pos = 1
	    NetLog.log("Send: id = " .. id .. ",  " .. msg:toString(16))
	    self.socketImp:send(msg:getPack())
    end
end

function HDSocketTCP:onStatus(event)

	print("[INFO] HDSocketTCP.onStatus:" .. event.name)
    --TipsMgr.show(nil, "network:" .. event.name)
    --TipsMgr.show(nil, "网络连接中...")
	NetLog.log("Status: " .. event.name)

    local SocketTCP = require("src.framework.cc.net.SocketTCP")
	if (SocketTCP.EVENT_CONNECTED == event.name and self.connectListener) then
        NetInterface.isConnect = true
		self.connectListener(true)
	elseif (SocketTCP.EVENT_CONNECT_FAILURE == event.name and self.connectListener) then
        NetInterface.isConnect = false
		self.connectListener(false)
	elseif (SocketTCP.EVENT_CLOSE == event.name or SocketTCP.EVENT_CLOSED == event.name) then
        NetInterface.isConnect = false
	end

end

function HDSocketTCP:addProcess(id, processor)

	if (self.msgProcessor[id] ~= nil) then
		print("[WARNING] Duplicated msg processor of msg id: " .. id)
	end
	self.msgProcessor[id] = processor

end

function HDSocketTCP:onData(event)

    --local msg = require("src.framework.cc.utils.ByteArray").new()
	--msg:writeBuf(event.data)
	local msg = event.data
    NetMgr.sysPingTime = os.clock()

	--msg._pos = 1

    if bEncoded then 
        --[[
        local msg2 = require("src.framework.cc.utils.ByteArray").new()
	    msg2:writeBuf(msg:readUnsigned(2))
        msg2:writeBuf(msg:readUnsigned(2))
        msg2:writeBuf(msg:readUnsigned(2))
        msg2:writeBuf(msg:readUnsigned(2))
        local data1 = encode(msg:readString(len),"4inch_MxM")
        msg2:writeString(data1)
       
        len = msg2:readUnsigned(2)
        self:processMsg(msg2)
        ]]

        --[[
        local msg2 = fcdat.CDatMgr:getDatMgr():getFreeEntry(msg:readString())
        local len2 = msg2:readUnsigned(2)
        print("len2 is........................"..len2)
        self:processMsg(msg2)
        ]]
	    local len = msg:readUnsigned(2)
	    self:processMsg(msg)
    else
	    local len = msg:readUnsigned(2)
	    self:processMsg(msg)

    end
	
	--if (len ~= msg:getLen()) then
	--	print("[ERROR] Msg length incorrect!")
	--	NetLog.log("Recv: incorrect msg len.  " .. msg:toString(16))
	--else
	--	local id = msg:readUShort()
	--	msg._pos = 3
	--	--print("[INFO] Receive msg: " .. msg:toString(16))
	--	--NetLog.log("Recv: id = " .. id .. ",  " .. msg:toString(16))
	--	self:processMsg(msg)
	--end

end

function HDSocketTCP:processMsg(msg)

	local msgID = msg:readUnsigned(2)
    print("onMsgRcv msgID:"..msgID)

	local code = nil
	if (self.msgProcessor[msgID]) then
		code = self.msgProcessor[msgID](msg)
	end

	if (NetMgr.SERVER_LOGIN == self.type) then
        --if (Proto.CommandL.LC_SELECTZONE_ACK == msgID and Proto.ErrorL.ERROR_LOGIN_OK == code) then
		--	self:disconnect()
		--end

		Eca.dispatchEvent(ECA.OnLoginMsgRcv, msgID, code)
	else
		if (Proto.Command.GC_ENTERZONE_ACK == msgID and Proto.Error.ERROR_OK == code) then
			Reconnector.reset()
		end

		Eca.dispatchEvent(ECA.OnMsgRcv, msgID, code)
	end
	
end

return HDSocketTCP
