require("framework.init")

local FontInclude = {}

FontInclude.suffix = {}
FontInclude.isInit = false

function FontInclude.fontTrans(font)


    if FontInclude.isInit == false then
        FontInclude.isInit = true;

        if "ios" == device.platform then
            HDUtils:fontMapSetDefault("DFPYuanW7")
            HDUtils:fontMapSet("DFYuanStd-W9","DFYuanStd-W9")
            HDUtils:fontMapSet("DFYuanW5","DFYuanW5")
            HDUtils:fontMapSet("DFPYuanW7","DFPYuanW7")
        elseif "windows" == device.platform then
            HDUtils:fontMapSetDefault("华康圆体W7(P)")
            HDUtils:fontMapSet("DFYuanStd-W9","DFYuan Std W9")
            HDUtils:fontMapSet("DFYuanW5","华康圆体W5")
            HDUtils:fontMapSet("DFPYuanW7","华康圆体W7(P)")
        elseif  device.platform == "android" then
            HDUtils:fontMapSetDefault("res/font/DFPYuanW7.ttf")
            HDUtils:fontMapSet("DFYuanStd-W9","res/font/DFYuanStd-W9.ttf")
            HDUtils:fontMapSet("DFYuanW5","res/font/DFYuanW5.ttc")
            HDUtils:fontMapSet("DFPYuanW7","res/font/DFPYuanW7.ttf")
        else
            assert(false,"该平台不支持")
        end
    end

    local fontjie = HDUtils:fontMapGet(font)

    return fontjie

end

return FontInclude