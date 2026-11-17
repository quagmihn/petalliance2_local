
local SharedDatas = {}

function SharedDatas.setNumber(Num)
	assert(SharedDatas.sharedNumber == nil,"some one useing The SharedDatas number") 

	SharedDatas.sharedNumber = Num
end

function SharedDatas.getNumber()
	if SharedDatas.sharedNumber ~= nil then
		local tmp =  SharedDatas.sharedNumber
		SharedDatas.sharedNumber = nil
		return tmp
	end
end

function SharedDatas.setTable(Tab)
	assert(SharedDatas.sharedTable == nil,"some one useing The SharedDatas table")

	SharedDatas.sharedTable = Tab
end

function SharedDatas.getTable()
	if SharedDatas.sharedTable ~= nil then
		local tmp =  SharedDatas.sharedTable
		SharedDatas.sharedTable = nil
		return tmp
	end
end
function SharedDatas.setBool(Bool)
	assert(SharedDatas.sharedBool == nil,"some one useing The SharedDatas bool")
	SharedDatas.sharedBool = Bool
end

function SharedDatas.getBool()
	if SharedDatas.sharedBool ~= nil then
		local tmp =  SharedDatas.sharedBool
		SharedDatas.sharedBool = nil
		return tmp
	end
end

function SharedDatas.setString(str)
	assert(SharedDatas.sharedString == nil,"some one useing The SharedDatas string")

	SharedDatas.sharedString = str
end

function SharedDatas.getString()
	if SharedDatas.sharedString ~= nil then
		local tmp =  SharedDatas.sharedString
		SharedDatas.sharedString = nil
		return tmp
	end
end


return SharedDatas