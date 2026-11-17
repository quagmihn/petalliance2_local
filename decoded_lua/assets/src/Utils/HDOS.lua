require("lfs")
 
function exists(path)

    return CCFileUtils:sharedFileUtils():isFileExist(path)

end
 
function mkdir(path)

    if not exists(path) then
        return lfs.mkdir(path)
    end
    return true

end

local function rmdirImp(path)

    local iter, dir_obj = lfs.dir(path)
    while true do
        local dir = iter(dir_obj)
        if (nil == dir) then
        	break
        end
        
        if dir ~= "." and dir ~= ".." then
            local curDir = path .. dir
            local mode = lfs.attributes(curDir, "mode") 
            if ("directory" == mode) then
                rmdirImp(curDir .. "/")
            elseif ("file" == mode) then
                os.remove(curDir)
            end
        end
    end

    local succ, des = os.remove(path)
    return succ

end
 
function rmdir(path)

    if exists(path) then
    	rmdirImp(path)
    end
    return true

end

local HDOS = {
	exists = exists,
	mkdir = mkdir,
	rmdir = rmdir,
}
return HDOS