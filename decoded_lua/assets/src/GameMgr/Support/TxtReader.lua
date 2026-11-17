local TxtReader = {}

function TxtReader.Init()
    print("TxtReader初始化")
end

function TxtReader.new(name)
	
    local object = {}

    object.fileName = name
    object.content = {}
    
    ---读表
    --@param params table 列的名字
    --@param keyParamIdx int 主键在params中的下标，不填默认主键为行数
    --@param numberKeys table 数字信息，不填则内容都为字符串
    function object.init(params, keyParamIdx, numberKeys) 
        local fileExist = cc.FileUtils:getInstance():isFileExist(object.fileName)
        if fileExist == false then
            print(object.fileName.."不存在，读取失败")
            return object.content
        end
        local filePath = cc.FileUtils:getInstance():fullPathForFilename(object.fileName)
        local rfile = cc.FileUtils:getInstance():getStringFromFile(filePath)
        local stable = lua_string_split(string.gsub(rfile, "\r", ""), "\n")
        for tags, line in pairs(stable) do
            if tags>1 and line~="" then
                local ltable = lua_string_split(line, "\t")
                local idx = tags-1
                if keyParamIdx then
                    if ltable[keyParamIdx] then
                        idx = tonumber(ltable[keyParamIdx])
                        object.content[idx] = {}
                    end
                else
                    object.content[idx] = {}
                end
                for key, var in pairs(ltable) do
                    if params[key] then
                        object.content[idx][params[key]] = var
                        if var=="nil" then
                        	object.content[idx][params[key]] = nil
                        elseif numberKeys ~= nil and numberKeys[params[key]] ~= nil then  
                            object.content[idx][params[key]] = tonumber(var) 
                        end  
                        --print(idx..","..params[key].."="..var) 
                    end
                end
            end
        end
        return object.content
    end

    function object.unload()
        object.content = {}
    end

    function object.getEntryCount()
        return #object.content
    end
    
    function object.get(idx)
        return object.content[idx] or object.content[tostring(idx)] or object.content[tonumber(idx)]
    end

    function object.search(key, var)
        for i, val in pairs(object.content) do
            if val[key]==var or val[key]==tostring(var) or val[key]==tonumber(var) then
        		return val
        	end
        end
    end

    return object
	
end

return TxtReader