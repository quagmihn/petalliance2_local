---Plist管理类，负责管理游戏中的plist图片
local PlistMgr = {}


function PlistMgr.Init()
   
   --[[
    local sprite = display.newSprite("Pet/peticon.png")
    cc.Director:getInstance():getRunningScene():addChild(sprite)
    sprite:setVisible(false)
    sprite:retain()
    ]]
end


function PlistMgr.setSpriteTexture(sprite,filename)
    local iconnamepathTable = string.split(filename,"/")
    if #iconnamepathTable>2 then 
        if iconnamepathTable[1] == "Pet" and iconnamepathTable[2] == "PetIcon" then 
            display.addSpriteFrames("Pet/peticon.plist","Pet/peticon.png",function(plistfilename,image)display.newSprite("#"..iconnamepathTable[3])
            sprite:loadTexture(iconnamepathTable[3],ccui.TextureResType.plistType)
            return true
            end)

        else
            return nil 
        end
    else
        return nil 
    end

end


return PlistMgr