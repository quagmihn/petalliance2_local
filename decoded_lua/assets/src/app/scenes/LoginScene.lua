local LoginScene = class("LoginScene", function()
    return display.newScene("LoginScene")
end)
local boolFirst = true
function LoginScene:ctor()
    LoginViewMgr.show(self)
    CocosModuleMgr.addTouchEffect(self)
end

function LoginScene:onEnter()
    if boolFirst then
        if device.platform=="ios" or device.platform=="android" then
            CocosModuleMgr.playVideo("Video/take0.mp4", function()
                LoginViewMgr.playAnimation()
            end, true)
        end
        boolFirst = false
    end
end

function LoginScene:onExit()
    display.clearMemory()
end

return LoginScene