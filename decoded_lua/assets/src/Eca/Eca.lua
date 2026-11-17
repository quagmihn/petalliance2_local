require("Eca.EcaInclude")
local HDVector = require("Utils.HDVector")

local spaces = {}

local LISTENER_INVALID = 0
local LISTENER_FUNC = 1
local LISTENER_FUNC_COND = 2
local LISTENER_OBJ_FUNC = 3
local LISTENER_OBJ_FUNC_COND = 4

local function reformListener(event, listener)

	local ret = {}
	if (nil ~= event and nil ~= listener) then
		if ("function" == type(listener)) then
			-- 只是函数
			ret.type = LISTENER_FUNC
			ret.func = listener
			return ret
		elseif ("table" == type(listener)) then
			if (nil ~= listener[1] 
				and nil ~= listener[2] and "function" == type(listener[2])
				and nil ~= listener[3] and ("boolean" == type(listener[3]) 
					or "number" == type(listener[3]) or "string" == type(listener[3]))) then
				-- 对象+函数+条件
				ret.type = LISTENER_OBJ_FUNC_COND
				ret.obj = listener[1]
				ret.func = listener[2]
				ret.cond = listener[3]
				return ret
			elseif (nil ~= listener[1] and nil ~= listener[2]) then
				if ("function" == type(listener[1]) and ("boolean" == type(listener[2]) 
					or "number" == type(listener[2]) or "string" == type(listener[2]))) then
					-- 函数+条件
					ret.type = LISTENER_FUNC_COND
					ret.func = listener[1]
					ret.cond = listener[2]
					return ret
				elseif ("function" == type(listener[2])) then
					-- 对象+函数
					ret.type = LISTENER_OBJ_FUNC
					ret.obj = listener[1]
					ret.func = listener[2]
					return ret
				end
			elseif (nil ~= listener[1] and "function" == type(listener[1])) then
				-- 只是函数
				ret.type = LISTENER_FUNC
				ret.func = listener[1]
				return ret
			end
		end
	end

end

local function compareListener(lis1, lis2)

	-- 这个函数用来判断注册在同一个event下的listener是否相等，不允许同一个函数重复注册
	-- 同一个listener响应不同event的话，不作限制
	if (lis1.type ~= lis2.type) then
		return false
	end

	if (LISTENER_FUNC == lis1.type) then
		return (lis1.func == lis2.func)
	elseif (LISTENER_FUNC_COND == lis1.type) then
		-- 同一个函数带不同的条件允许多次注册，不会同一时间发生两次调用
		return (lis1.func == lis2.func and lis1.cond == lis2.cond)
	elseif (LISTENER_OBJ_FUNC == lis1.type) then
		-- 理论上讲某个obj的不同函数注册响应同一个event没有问题
		-- 但是这么做好像没什么意义，所以不允许了，要做事就在同一个函数内做
		return (lis1.obj == lis2.obj and lis1.func == lis2.func)
	elseif (LISTENER_OBJ_FUNC_COND == lis1.type) then
		-- 如果obj和条件都相等，就等价于上一种情况
		-- 但是同一个函数带有不同的条件，或不同的函数各自带不同的条件，是允许存在的
		return (lis1.obj == lis2.obj and lis1.func == lis2.func and lis1.cond == lis2.cond)
	end

	return false

end

local function addListener(event, listener)

	local listenerXP = reformListener(event, listener)
	if (nil ~= listenerXP) then
		if (not spaces[event]) then
			spaces[event] = {}
			HDVector.extend(spaces[event])
		end

		local delegate = spaces[event]
		for i = 1, #delegate do
			if (compareListener(listenerXP, delegate[i])) then
				return
			end
		end

		delegate:push_back(listenerXP)
	end

end

local function delListener(event, listener)

	if (spaces[event]) then
		local listenerXP = reformListener(event, listener)
		local delegate = spaces[event]
		for i = 1, #delegate do
			if (compareListener(listenerXP, delegate[i])) then
				delegate:erase(i)
				break
			end
		end
	end

end

local function clearListener(event)

	if (spaces[event]) then
		spaces[event]:clear()
	end

end

local function dispatchEvent(event, cond, params)

	local delegate = spaces[event]
	if (nil == delegate) then
		return
	end

	if (nil ~= params and "table" == type(params)) then
		params.ecaEvent = event
	end

	for i = 1, #delegate do
		local listener = delegate[i]
		if (listener) then
			if ((LISTENER_FUNC_COND == listener.type and cond == listener.cond)
				or LISTENER_FUNC == listener.type) then
				listener.func(params)
			elseif ((LISTENER_OBJ_FUNC_COND == listener.type and cond == listener.cond)
				or LISTENER_OBJ_FUNC == listener.type) then
				listener.func(listener.obj, params)
			end
		end
	end

end

local Eca = {
	addListener = addListener,
	delListener = delListener,
	-- clearListener = clearListener,
	dispatchEvent = dispatchEvent,
}
return Eca