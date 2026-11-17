require("src.Net.Proto.ProtoInclude")

local XDatReader = {}

function XDatReader.new(name)

	local object = {}

	object.fileName = "Config/" .. name .. ".dat"

	function object.init()
	   
        if object.entryCount then
	    	return
	    end
        fcdat.CDatMgr:getDatMgr():loadTable(object.fileName, Proto["get" .. name .. "IDLen"]())
        object.entryCount = fcdat.CDatMgr:getDatMgr():getEntryCount(object.fileName)
        object.entrys = {}
        object.entrysByID = {}
        
	end

	function object.unload()
	
        fcdat.CDatMgr:getDatMgr():unloadTable(object.fileName)
        
	end

	function object.getEntryCount()

        return object.entryCount

	end

	function object.getEntryID(idx)
	
        if object.entrys[idx] then
			return object.entrys[idx].id
		else
            local entry = fcdat.CDatMgr:getDatMgr():getEntry(object.fileName, idx - 1)
            if entry then
                entry:readBegan()
                local luaEntry = Proto["parse" .. name](entry)
                object.entrys[idx] = luaEntry
                return object.entrys[idx].id
            else
                return nil
            end
		end

	end

	function object.readEntry(idx)

        if object.entrys[idx] then
            return object.entrys[idx]
        else
            local entry = fcdat.CDatMgr:getDatMgr():getEntry(object.fileName, idx - 1)
            if entry then
                entry:readBegan()
                local luaEntry = Proto["parse" .. name](entry)
                object.entrys[idx] = luaEntry
                return object.entrys[idx]
            else
                return nil
            end
        end

	end
 
	function object.readEntryByID(id)

        if object.entrysByID[id] then
            return object.entrysByID[id]
        else
            local entry = fcdat.CDatMgr:getDatMgr():getEntryByID(object.fileName, id)
            if entry then
                entry:readBegan()
                local luaEntry = Proto["parse" .. name](entry)
                object.entrysByID[id] = luaEntry
                return object.entrysByID[id]
            else
                return nil
            end
        end

	end
	
    object.init()

	return object

end

return XDatReader