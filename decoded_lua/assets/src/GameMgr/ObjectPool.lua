local ObjectPool = {}

local isOpenLog = false --打印日志标志位，如果为true打开打印日志

ObjectPool.unusedObjectPool={} --未使用的对象列表,结构key,table
ObjectPool.usingObjectPoolIndex = {} --正在使用的对象的index序号

--所有ObjectPool的种类都是定死的，不存在通用的说法。因为必须控制内存，禁止滥用
ObjectPool.keyTable = {"PetListUI", "LostTowerPetList","CheckView"} --对象池种类关键字:petlist宠物面板宠物列表、LostTowerPetList:千层塔宠物列表

local function isKeyInObjectPool(keyval)
    for i = 1,#ObjectPool.keyTable do
        if ObjectPool.keyTable[i] == keyval then
			return true
		end
	end
	return false
end

---扩展对象池的尺寸
--@param objectArray array 对象数组
--@param size int 扩展的大小
local function reserveSize(objectArray,size)
	if #objectArray > 0 then
		for i =1,size do
			local object = objectArray[1]:clone()
			object:retain()
			table.insert(objectArray,object)
		end
	end
end

function ObjectPool.freeAll() --释放对象池中的所有对象
    for k,v in pairs(ObjectPool.unusedObjectPool) do
        for i = 1,#v do
            v[i]:release()
        end
        v = {}
    end
    for k,v in pairs(ObjectPool.usingObjectPoolIndex) do
		v = 0
    end
end

function ObjectPool.init() --对象池初始化，必须放在初始化的第一个
    --目前永不释放
    --ObjectPool.freeAll() --首先释放原来对象池的内容
    
    --开始初始化对象池
    for i = 1,#ObjectPool.keyTable do
        local unusepool = {}
        local key = ObjectPool.keyTable[i]
        if ObjectPool.unusedObjectPool[key]==nil then
            ObjectPool.unusedObjectPool[key] = unusepool
            ObjectPool.usingObjectPoolIndex[key] = 1
        end
    end
end

---添加对象池对象
--@param key string 关键字名，表示某种类型的对象池,不在指定列表中的对象不予理睬
--@param object ref 必须继承ref智能指针的类型
function ObjectPool.add(key,object)
    if isKeyInObjectPool(key) then
        if isOpenLog then print("add object into object pool") end
        object:retain()
		table.insert(ObjectPool.unusedObjectPool[key],object)
	end
end

---获取某种类型对象池的对象
--@param key string 关键字名，表示某种类型的对象池,不在指定列表中的对象不予理睬
--@param num int 获得对象池的数量
--@return returnObjectArray table 返回的对象列表
function ObjectPool.getObjectFromPool(key,num)
	local returnObjectArray = {}
	if isKeyInObjectPool(key) then
		local objectArray = ObjectPool.unusedObjectPool[key]
		local objectPoolIndex = ObjectPool.usingObjectPoolIndex[key]
		local leftnum = #objectArray-objectPoolIndex
        if isOpenLog then print("#objectArray,objectPoolIndex,leftnum is:"..#objectArray,objectPoolIndex,leftnum) end
		if leftnum< num then
			reserveSize(objectArray,((num-leftnum)*2))
		end

		local index = objectPoolIndex
		for i=objectPoolIndex+1,objectPoolIndex+num do
            if isOpenLog then print("objectPoolIndex add index is:"..i) end
			table.insert(returnObjectArray,objectArray[i])
			index = index+1
		end
		
        if isOpenLog then print("After use the ObjectPoolIndex is:"..index) end
		ObjectPool.usingObjectPoolIndex[key] = index
	end
	
	return returnObjectArray
end

---返还某种类型对象池的对象
--@param key string 关键字名，表示某种类型的对象池,不在指定列表中的对象不予理睬
--@param num int 返还的对象的数量
function ObjectPool.returnObjectToPool(key,num)
	if isKeyInObjectPool(key) then
		local index = ObjectPool.usingObjectPoolIndex[key]
		local newindex = index - num
		if newindex < 1 then newindex = 1 end
		ObjectPool.usingObjectPoolIndex[key] = newindex
	end
end

---重设对象池,所有对象默认为空闲
--@param key string 关键字名，表示某种类型的对象池,不在指定列表中的对象不予理睬
function ObjectPool.reset(key)
    if isKeyInObjectPool(key) then
        ObjectPool.usingObjectPoolIndex[key] = 1
    end    
end

---重设所有对象池,所有对象池为空闲
function ObjectPool.resetAll()
    for i = 1,#ObjectPool.keyTable do 
        print("reset is key is........"..ObjectPool.keyTable[i])
        ObjectPool.reset(ObjectPool.keyTable[i])
    end

end



return ObjectPool