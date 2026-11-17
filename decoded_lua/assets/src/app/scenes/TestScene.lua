require("src.GameMgr.GameInit")

local TestScene = class("TestScene", function()
    return display.newScene("TestScene")
end)

function TestScene:ctor()
    local db = display.newSprite("timg.png")
    db:pos(display.cx, display.cy)
    db:addTo(self)

    local touchLayer = display.newLayer():addTo(self)
    touchLayer:setLocalZOrder(CocosModuleMgr.ZORDER_MOVETOUCH)
    touchLayer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    local prePos = nil
    local border = 4
    local function touchListener(event)
        event.x = math.floor(event.x)
        event.y = math.floor(event.y)
        if event.name == "began" then
            prePos = {event.x, event.y}
            return true
        end
        if event.name == "moved" or event.name == "ended" then
            local diff = math.sqrt((prePos[1]-event.x)*(prePos[1]-event.x)+(prePos[2]-event.y)*(prePos[2]-event.y))
            if diff>border then
                local line = display.newLine({prePos, {event.x, event.y}},
                    {borderColor = cc.c4f(0.12, 1, 1, 1), borderWidth = border})
                line:addTo(self)
                --line:clear()
                prePos = {event.x, event.y}
            end
            return true
        end
    end
    touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, touchListener)
end

function TestScene:onEnter()
    SceneMgr.clearScene(self)
end

function TestScene:onExit()
    --SceneMgr.onSceneExit(self)
end

return TestScene
