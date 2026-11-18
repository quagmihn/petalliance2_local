local NetInterface = {}
local CallbackMgr = require("src.Net.CallbackMgr")


local sendMsgCaches = {}
local noResendMsgCaches = {}

NetInterface.isConnect = false 
NetInterface.isConnecting = false
NetInterface.isClientClosed = false
NetInterface.isWaiting = false

function NetInterface.Init()
    print("NetInterface初始化")

    NetInterface.isWaiting = false
    sendMsgCaches = {}

    NetInterface.isConnect = false
    NetInterface.isConnecting = false
    NetInterface.isClientClosed = false
    noResendMsgCaches = {}
    --NetInterface.connectServer(nil)
end

---连接GATE服务器
--@param successCallback function 成功回调
--@param errorCallback function 失败回调
function NetInterface.connectServer(successCallback, errorCallback)
    print("NetInterface.connectServer")
    if NetInterface.isWaiting then
        print("NetInterface.connectServer isWaiting,ingore")
        return
    end

    NetInterface.isWaiting = true
    local NetMgr = require("src.Net.NetMgr")
    local tag = "ConnectServer..."
        
    NetMgr.init()
    OvertimeListener.start(function()
        --LoadingView.show()
        NetMgr.connect(function(res)
            print("callback in NetInterface::connectServer res:"..tostring(res))
            --LoadingView.hide()
            --LoadingView.show()
            OvertimeListener.cancel(tag)
            if res then
                NetInterface.isWaiting = false 
                --LoadingView.hide()               
                if nil ~= successCallback then
                    successCallback()
                end
            else
                if nil ~= errorCallback then
                
                    NetInterface.isWaiting = false
                    --LoadingView.hide()
                    errorCallback()
                else
                    NetInterface.isWaiting = true
                    OvertimeListener.restart(LuaSqlite.getLanguageByKey("tips56"), tag)    
                end
            end
        end)
    end, tag, LuaSqlite.getLanguageByKey("tips56"))
end

---发送协议
--@param ackName string ack名称，必填，请勿填错
--@param func function 发送协议函数
--@param successCallback function 成功回调
--@param errorCallback function 失败回调
--@param waitTime 
--@param canResend default is true,set false means not resendable
function NetInterface.send(ackName, func, successCallback, errorCallback,waitTime,canResend)
    local ackID = Proto.Command[string.upper(ackName)]
    if not ackID then
        ackID = Proto.CommandL[string.upper(ackName)]
    end
    ackName = ackName or "default"
    if TOUCH_PIPELINE_DIAGNOSTICS then
        print(string.format("[NET_DIAG] request mode=async expected_ack=%s expected_id=%s scene=%s",
            tostring(ackName), tostring(ackID), tostring(SceneMgr.currentScene)))
    end
    if canResend == nil then canResend = true end
    if canResend == true then 
        sendMsgCaches[ackName] = {type=0, sendFunc=func, sCallback=successCallback, eCallback=errorCallback}
    else
        noResendMsgCaches[ackName] = {type=0, sendFunc=func, sCallback=successCallback, eCallback=errorCallback}
    end
    
    if not func then
        return
    end
    
    OvertimeListener.start(function()
        func()
        CallbackMgr.registCallFunc(ackID, function(code)
            if TOUCH_PIPELINE_DIAGNOSTICS then
                print(string.format("[NET_DIAG] ack_complete mode=async expected_ack=%s expected_id=%s code=%s",
                    tostring(ackName), tostring(ackID), tostring(code)))
            end
            OvertimeListener.cancel(ackName, true)
            sendMsgCaches[ackName] = nil
            noResendMsgCaches[ackName] = nil
            if code==0 then
                if successCallback then
                    successCallback()
                end
            else
                --ProtoErrorTransferText.showNetErrorText(code)
                if errorCallback then
                    errorCallback(code)
                end
            end
        end)
    end, ackName, nil, function()
        if TOUCH_PIPELINE_DIAGNOSTICS then
            print(string.format("[NET_DIAG] ack_timeout mode=async expected_ack=%s expected_id=%s scene=%s loading_visible=%s",
                tostring(ackName), tostring(ackID), tostring(SceneMgr.currentScene), tostring(LoadingView.isLoadingViewShow)))
        end
        print("NetInterface.send overtime,reset connection ackName:",ackName)
        print("show trace")
        print(debug.traceback("", 2))
        OvertimeListener.cancel(ackName, true)
        NetInterface.isConnect = false
        NetInterface.isWaiting = false
        local NetMgr = require("src.Net.NetMgr")
        NetMgr.reconnector = nil
        if nil ~= NetMgr.socket then 
            NetMgr.disconnect()
        end
    end
	,waitTime)
end

---发送协议，并阻塞游戏
--@param ackName string ack名称，必填，请勿填错
--@param func function 发送协议函数
--@param successCallback function 成功回调
--@param errorCallback function 失败回调
--@param waitTime 
--@param canResend default is true,set false means not resendable
function NetInterface.sendWithBlock(ackName, func, successCallback, errorCallback, waitTime, canResend, timeoutCallback)
    DebugInfoMgr.SENDMSG = {ackName, func, successCallback, errorCallback, waitTime, canResend, timeoutCallback}
    local ackID = Proto.Command[string.upper(ackName)]
    if not ackID then
        ackID = Proto.CommandL[string.upper(ackName)]
    end
    ackName = ackName or "default"
    if TOUCH_PIPELINE_DIAGNOSTICS then
        print(string.format("[NET_DIAG] request mode=blocking expected_ack=%s expected_id=%s scene=%s login_progress=%s",
            tostring(ackName), tostring(ackID), tostring(SceneMgr.currentScene), tostring(LoginMsgMgr.IsInLoginProgress)))
    end
    if canResend == nil then canResend = true end
    if canResend == true then
        sendMsgCaches[ackName] = {type=1, sendFunc=func, sCallback=successCallback,
            eCallback=errorCallback, waitTime=waitTime, canResend=canResend,
            timeoutCallback=timeoutCallback}
    else
        noResendMsgCaches[ackName] = {type=0, sendFunc=func, sCallback=successCallback,
            eCallback=errorCallback, waitTime=waitTime, canResend=canResend,
            timeoutCallback=timeoutCallback}
    end
    
    if not func then
    	return
    end
    
	OvertimeListener.start(function()
        if LoginMsgMgr.IsInLoginProgress == false then
            LoadingView.show()
        end
        func()
        CallbackMgr.registCallFunc(ackID, function(code)
            if TOUCH_PIPELINE_DIAGNOSTICS then
                print(string.format("[NET_DIAG] ack_complete mode=blocking expected_ack=%s expected_id=%s code=%s loading_visible=%s",
                    tostring(ackName), tostring(ackID), tostring(code), tostring(LoadingView.isLoadingViewShow)))
            end
            OvertimeListener.cancel(ackName, true)
            sendMsgCaches[ackName] = nil
            noResendMsgCaches[ackName] = nil
            LoadingView.hide()
            if code==0 then
                if successCallback then
                    successCallback()
                end
            else
               -- ProtoErrorTransferText.showNetErrorText(code)
                if errorCallback then
                    errorCallback(code)
                end
            end
        end)
    end, ackName, nil, function()
        if TOUCH_PIPELINE_DIAGNOSTICS then
            print(string.format("[NET_DIAG] ack_timeout mode=blocking expected_ack=%s expected_id=%s scene=%s loading_visible=%s",
                tostring(ackName), tostring(ackID), tostring(SceneMgr.currentScene), tostring(LoadingView.isLoadingViewShow)))
        end
        print("NetInterface.sendWithBlock overtime,reset connection ackName:",ackName)
        OvertimeListener.cancel(ackName, true)
        sendMsgCaches[ackName] = nil
        noResendMsgCaches[ackName] = nil
        LoadingView.hide()
        if timeoutCallback then
            timeoutCallback()
        end
        NetInterface.isConnect = false
        NetInterface.isWaiting = false
        local NetMgr = require("src.Net.NetMgr")
        NetMgr.reconnector = nil
        NetMgr.disconnect()
--		local blockMsg = {}
--		blockMsg.ackName = ackName
--		blockMsg.func = func
--		blockMsg.successCallback = successCallback
--		blockMsg.errorCallback = errorCallback
--		NetMgr.setBlockMsgOnReconnected(blockMsg)
    end
	,waitTime)
end

---断线重连后发送
function NetInterface.hasPending(ackName)
    return sendMsgCaches[ackName] ~= nil or noResendMsgCaches[ackName] ~= nil
end

function NetInterface.resend()
    print("断线重连后，检查补发未发送成功的消息")
    local resendEntries = {}
    for key, var in pairs(sendMsgCaches) do
        resendEntries[#resendEntries + 1] = {key, var}
    end
    for _, entry in ipairs(resendEntries) do
        local key, var = entry[1], entry[2]
        if sendMsgCaches[key] ~= var then
            -- A callback may have resolved the request while the replay list
            -- was being prepared. Do not send a stale operation.
        else
        print("确认补发消息", key)
        if var.type==0 then
            NetInterface.send(key, var.sendFunc, var.sCallback, var.eCallback)
        elseif var.type==1 then
            NetInterface.sendWithBlock(key, var.sendFunc, var.sCallback, var.eCallback,
                var.waitTime, var.canResend, var.timeoutCallback)
        end
        end
    end

    for key, var in pairs(noResendMsgCaches) do
        var.eCallback(-1) --错误-1表示重连超时
    end
    noResendMsgCaches = {}

    if SceneMgr.currentScene=="MainScene" and not NetInterface.hasPending("ZC_QuestList_Ack") then
        NetInterface.sendWithBlock("ZC_QuestList_Ack", function()
            local NewQuestSend = require("src.Net.Send.NewQuestSend")
            NewQuestSend.sendCZ_QuestList_Req()
        end)
    end
    TeamInfo.checkTeamStatus()
    TeamInfo.checkTeamMapStatus()
    WorldBossInfo.checkBossMapStatus()

end

return NetInterface
