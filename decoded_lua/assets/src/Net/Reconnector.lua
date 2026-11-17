local Reconnector = {}

local cacheMsgs = {}
local NetMgr = nil

function Reconnector.init(listener)
    print("Reconnector.init")
	Reconnector.doing = false
    Reconnector.flag = false
	Reconnector.reconnectListener = listener
	NetMgr = require("src.Net.NetMgr")
	
end

function Reconnector.canReconnect()
    
	return Reconnector.canDo
end

function Reconnector.reconnecting()
    --LoadingView.show()
    --TipsMgr.show(nil, "网络重连中...")
	return Reconnector.doing
end

function Reconnector.onConnectSuccess()

	print("reconnect success")
    Reconnector.doing = false
	LoginViewMgr.deviceRelogin()
    
end

function Reconnector.onConnectFailed()

    print("reconnect failed")
    NetMgr.reconnector = nil
    Reconnector.doing = false
    
end

function Reconnector.finish()
    --Reconnector.doing = false
    Reconnector.flag = false
    if nil ~= Reconnector.reconnectListener then
        Reconnector.reconnectListener()
    end
    --TipsMgr.show(SceneMgr.getRunningScene, "reconnect finish")
    LoadingView.hide()
    --TipsMgr.show(SceneMgr.getRunningScene, "重连成功")
    NetMgr.reconnector = nil
    TownChatMgr.changeSceneChannel()
end

function Reconnector.reconnectImp()
    LoadingView.show()
    print("Reconnector.reconnectImp")
    NetInterface = require("src.GameMgr.Support.NetInterface")
    Reconnector.doing = true
    Reconnector.flag = true
    print("call NetInterface.connectServer")
    NetInterface.connectServer(Reconnector.onConnectSuccess,Reconnector.onConnectFailed)
    
end

return Reconnector