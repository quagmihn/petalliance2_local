local PlayerInfoViewMgr = {}

PlayerInfoViewMgr.PLAYER_POSX = 480
PlayerInfoViewMgr.PLAYER_POSY = 1200

local resName = ""
local curPlayerRes = ""

function PlayerInfoViewMgr.Init()
    resName = "Player/PlayerBoard.csb"
    curPlayerRes = ""
end

function PlayerInfoViewMgr.show(scene, info)
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(25)
        CSResourceMgr.setRelativePosition(resName, 320, 480)

        info.name = info.name or ""
        info.res = info.res or "Gaf/char/001.gaf"
        curPlayerRes = info.res
        --...
        
        CSResourceMgr.clickEventBinding(resName, {"bg"}, function()
            PlayerInfoViewMgr.hide()
        end)
        CSResourceMgr.setLabelString(resName, {"db", "name"}, info.name.." ", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        local testStr = "等级：-\n签名：-\n\n\n公会信息：-\n携带宠物：-\n徽章展示：-\n\n\n        【按钮区域】\n添加好友        公会详情\n加入黑名单     邀请决斗 "
        CSResourceMgr.setLabelString(resName, {"db", "info"}, testStr, "", {r=0,g=0,b=0,a=64})
        CSResourceMgr.getNodeByName(resName, "info"):setAnchorPoint(0.5, 1)
        --...
    end

    local function playCSB()
        CSResourceMgr.playActionWithCallback(resName, 0, 5, 1, function()
            AnimationMgr.createAni(CSResourceMgr.getCsbObj(resName), info.res, PlayerInfoViewMgr.PLAYER_POSX, PlayerInfoViewMgr.PLAYER_POSY, "PlayerInfoBoard")
            AnimationMgr.playAni(info.res, "idle", true, "PlayerInfoBoard")
        end)
    end

    local funcTable = {loadCSB, playCSB}

    UnblockLoader.load(funcTable)
end

function PlayerInfoViewMgr.hide()
    AnimationMgr.removeGafObjectByTag(curPlayerRes, "PlayerInfoBoard")
    CSResourceMgr.playActionWithCallback(resName, 50, 55, 1, function()
        CSResourceMgr.removeCSObjectByTag(resName)
    end)
end

return PlayerInfoViewMgr