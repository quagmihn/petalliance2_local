local UnblockLoader = {}

UnblockLoader.DEFAULT_TIME_DELAY = 0.01
UnblockLoader.USE_COROUTINE = true      --关闭后UnblockLoader.addCallback失效
UnblockLoader.SHOW_LOG = false          --关闭后不显示执行方法log

--IF ERROR OCCURS, THIS LOADER WILL NEVER RESUME.
UnblockLoader.BACKGROUND_LOADER_TAG = "WILL_NEVER_CLEAN"

local coroutine = nil
local coroutineFunc = {}
local coroutineCaches = {}
local coroutineCallback = {}
local scheduler = nil

local ucounter = 0

function UnblockLoader.Init()
    coroutine = require("coroutine")
    scheduler = require("src.framework.scheduler")
    
    UnblockLoader.clean()
    
    ucounter = 0
end

--[[
local function test1()
end
local function test2()
end
local function test3()
end
local function test4()
end
print("加载大量UI时拆成小模块执行")
UnblockLoader.load({test1, test2, test3, test4})
--]]

---携程加载
--@param funcTable table 执行函数数组
--@param tag string 标签，相当于句柄，不填则默认生成一个数字标签
--@param time floar 函数执行间隔时间，不填则默认0.01
--@return #string 标签
function UnblockLoader.load(funcTable, tag, time)
    local i = tag or UnblockLoader.counter()
    time = time or UnblockLoader.DEFAULT_TIME_DELAY
    if not UnblockLoader.USE_COROUTINE then
        for var=1, #funcTable do
        	funcTable[var]()
        end
        if coroutineCallback[i] then
            coroutineCallback[i]()
            coroutineCallback[i] = nil
        end
    	return
    end    
    
    if coroutineFunc[i] then
        if not coroutineCaches[i] then
        	coroutineCaches[i] = {}
        end
        for var=1, #funcTable do
            table.insert(coroutineCaches[i], funcTable[var])
        end
        if UnblockLoader.SHOW_LOG then
            print("UnblockLoader执行未完成, tag:"..i, "在末尾添加方法", #funcTable, #coroutineCaches[i])
        end
    else
        if UnblockLoader.SHOW_LOG then
            print("UnblockLoader开始, tag:"..i, "方法总数:"..#funcTable)
        end
        coroutineFunc[i] = coroutine.create(function()
            for var=1, #funcTable do
                local ret, errMessage = pcall(function()
                    funcTable[var]()
                end)
                if not ret then
                    print("UnblockLoader执行报错, tag:", i, "index:", var, "error:", errMessage)
                end
                UnblockLoader.resume(i, time)
                if UnblockLoader.SHOW_LOG then
                    print("UnblockLoader挂起, tag:"..i, "方法index:"..var)
                end
                coroutine.yield()
            end
            if coroutineCaches[i] then
                local function checkCaches(index)
                    if coroutineCaches[i][index] then
                        local ret, errMessage = pcall(function()
                            coroutineCaches[i][index]()
                        end)
                        if not ret then
                            print("UnblockLoader执行报错, tag:", i, "cache index:", index, "error:", errMessage)
                        end
                        UnblockLoader.resume(i, time)
                        if UnblockLoader.SHOW_LOG then
                            print("UnblockLoader挂起, tag:"..i, "补充方法index:"..index)
                        end
                        coroutine.yield()
                        checkCaches(index+1)
                    else
                        coroutineCaches[i] = nil
            		end
            	end
                checkCaches(1)
            end
            if coroutineCallback[i] then
                coroutineCallback[i]()
                coroutineCallback[i] = nil
            end
            coroutineFunc[i] = nil
        end)
        coroutine.resume(coroutineFunc[i])
    end
    return i

    --[[
    --不能直接用计时器，因为执行时间不确定
    for key, var in pairs(funcTable) do
        scheduler.performWithDelayGlobal(function()
            var()
        end, UnblockLoader.DEFAULT_TIME_DELAY*(key-1))
    end
    --]]
end

---不要外部调用
function UnblockLoader.resume(i, time)
    time = time or UnblockLoader.DEFAULT_TIME_DELAY 
    scheduler.performWithDelayGlobal(function()
        if coroutineFunc[i]~=nil then
            if UnblockLoader.SHOW_LOG then
                print("UnblockLoader恢复, tag:"..i)
            end
            coroutine.resume(coroutineFunc[i])
        end
    end, time)
end

---不要外部调用
function UnblockLoader.counter()
    ucounter = ucounter+1
    if ucounter>100 then
        ucounter = 0
    end
	return ucounter
end

---取消携程加载
--@param tag string 标签
function UnblockLoader.cancel(tag)
    if not tag then
    	return
    end
    if UnblockLoader.SHOW_LOG then
        print("UnblockLoader取消, tag:"..tag)
    end
	coroutineFunc[tag] = nil
	coroutineCaches[tag] = nil
	coroutineCallback[tag] = nil
end

---添加携程加载完毕的回调
--@param tag string 标签
--@param callback function 回调方法
function UnblockLoader.addCallback(tag, callback)
    if not tag then
        return
    end
    coroutineCallback[tag] = callback
end

---切换场景时清空
function UnblockLoader.clean()
    for key, var in pairs(coroutineFunc) do
        if key~=UnblockLoader.BACKGROUND_LOADER_TAG then
            UnblockLoader.cancel(key)
    	end
    end
end

return UnblockLoader