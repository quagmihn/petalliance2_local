local XProcessExtend = {}

function XProcessExtend.extend(object, dataObj, protoList)
	local NetMgr = require("Net.NetMgr")
	local MsgPrinter = require("Net.MsgPrinter")

	if (object and dataObj and protoList) then
		for i = 1, #protoList do
			local proto = protoList[i]
			local parseFunc = Proto["parseP_" .. proto]

			if (nil ~= parseFunc) then
				-- 每个process函数
				object["on" .. proto] = function(msg)

					local res = parseFunc(msg)
					MsgPrinter.rcvMsg(res, proto)
					if (dataObj["on" .. proto]) then
						dataObj["on" .. proto](res)
					else
						print("[Warning] No data function of proto " .. proto)
					end
					return res.code
				end
			else
				print("[Error] No parse function of proto " .. proto)
			end
		end

		object["registProcess"] = function()
			for i = 1, #protoList do
				local proto = protoList[i]
				local parseFunc = Proto["parseP_" .. proto]
				if (nil ~= parseFunc) then
					local protoID = string.upper(proto)
					NetMgr.addProcess(Proto.Command[protoID], object["on" .. proto])
				else
					print("[Error] No parse function of proto " .. proto)
				end
			end
		end
	end

	return object
end

return XProcessExtend