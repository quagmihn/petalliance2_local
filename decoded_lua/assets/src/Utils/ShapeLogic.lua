local ShapeLogic = class("ShapeLogic")

local STATE_OFF = 0
local STATE_ON = 1
local exactFlag = false

function ShapeLogic:ctor(params)

	self.rowCount = params.row or 3
	self.columnCount = params.column or 3

	self.atomState = {}
	for i = 1, self.rowCount do
		self.atomState[i] = {}
	end
	self:clear()

end

function ShapeLogic:getRowCount()

	return self.rowCount

end

function ShapeLogic:getColumnCount()

	return self.columnCount
	
end

function ShapeLogic:getState(row, col)

	if (row >= 1 and row <= self.rowCount
		and col >= 1 and col <= self.columnCount) then
		return self.atomState[row][col]
	else
		return STATE_OFF
	end

end

function ShapeLogic:turnOn(row, col)

	if (row >= 1 and row <= self.rowCount
		and col >= 1 and col <= self.columnCount) then
		self.atomState[row][col] = STATE_ON
	end

end

function ShapeLogic:turnOff(row, col)

	if (row >= 1 and row <= self.rowCount
		and col >= 1 and col <= self.columnCount) then
		self.atomState[row][col] = STATE_OFF
	end

end

function ShapeLogic:containShape(obj)

	local row, column = obj:getRowCount(), obj:getColumnCount()
	if (row > self.rowCount or column > self.columnCount) then
		return false
	end

	for y = 1, self.rowCount - row + 1 do
		for x = 1, self.columnCount - column + 1 do
			local matchFlag = true

			for i = 1, row do
				for j = 1, column do
					if (true == exactFlag) then
						if (obj:getState(i, j) ~= self:getState(y + i - 1, x + j - 1)) then
							matchFlag = false
							break
						end
					else
						if (STATE_ON == obj:getState(i, j) and STATE_OFF == self:getState(y + i - 1, x + j - 1)) then
							matchFlag = false
							break
						end
					end
				end

				if (false == matchFlag) then
					break
				end
			end

			if (true == matchFlag) then
				return true, y, x
			end
		end
	end

	return false

end

function ShapeLogic:clear()

	for i = 1, self.rowCount do
		for j = 1, self.columnCount do
			self:turnOff(i, j)
		end
	end

end

function ShapeLogic:dumpState()

	print("ShapeLogic:dumpState 1")

	for i = 1, self.rowCount do
		local val = ""
		for j = 1, self.columnCount do
			val = val .. self.atomState[i][j] .. " "
		end
		print(val)
	end

	print("ShapeLogic:dumpState 2")

end

ShapeLogic.STATE_OFF = STATE_OFF
ShapeLogic.STATE_ON = STATE_ON

return ShapeLogic