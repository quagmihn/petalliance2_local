
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 0 
 
-- display FPS stats on screen
DEBUG_FPS = false

-- dump memory info every 10 seconds
DEBUG_MEM = false

-- load deprecated API
LOAD_DEPRECATED_API = false

-- load shortcodes API
LOAD_SHORTCODES_API = true 

-- screen orientation
CONFIG_SCREEN_ORIENTATION = "portrait" 

-- design resolution
CONFIG_SCREEN_WIDTH  = 640 
CONFIG_SCREEN_HEIGHT = 960

-- auto scale mode
CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"

CONFIG_STORE_PATH = ""

GameConfig = {}

function checkDirOK(path)
    require "lfs"
    local oldpath = lfs.currentdir()
    if lfs.chdir(path) then
        lfs.chdir(oldpath)
        return true
    end
    if lfs.mkdir(path) then
        return true
    end
    return false
end

function GameConfig.setResourcePath()
    CONFIG_STORE_PATH = device.writablePath.."download/"
    if device.platform == "ios" then
        CONFIG_STORE_PATH = string.gsub(device.writablePath, "Documents/", "Library/FCPatchs/")
        if checkDirOK(CONFIG_STORE_PATH) then
            print("create patch folder")
        else
            print("failed to create patch folder")
        end

        CONFIG_STORE_PATH = CONFIG_STORE_PATH.."download/"
    end
end