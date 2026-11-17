local CallbackMgr = {}

local FuncTable = {}

function CallbackMgr.registCallFunc(key, callback)
    if key and callback then
        if TOUCH_PIPELINE_DIAGNOSTICS then
            print(string.format("[NET_DIAG] callback_pending register ack_id=%s replaced=%s",
                tostring(key), tostring(FuncTable[key] ~= nil)))
        end
        FuncTable[key] = callback
    elseif TOUCH_PIPELINE_DIAGNOSTICS then
        print(string.format("[NET_DIAG] callback_pending rejected ack_id=%s has_callback=%s",
            tostring(key), tostring(callback ~= nil)))
    end
end

function CallbackMgr.doCallFunc(code, key)
    if key and FuncTable[key] then
        if TOUCH_PIPELINE_DIAGNOSTICS then
            print(string.format("[NET_DIAG] callback_pending resolve ack_id=%s code=%s", tostring(key), tostring(code)))
        end
        local tmpFunc = FuncTable[key]
        FuncTable[key] = nil
        tmpFunc(code)
	elseif TOUCH_PIPELINE_DIAGNOSTICS then
        print(string.format("[NET_DIAG] callback_pending unmatched actual_ack_id=%s code=%s", tostring(key), tostring(code)))
	end
end

return CallbackMgr
