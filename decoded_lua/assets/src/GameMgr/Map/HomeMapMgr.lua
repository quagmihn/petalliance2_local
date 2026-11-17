local HomeMapMgr = {}

function HomeMapMgr.Init()
    print("HomeMapMgr初始化")
end

function HomeMapMgr.createWithRes(scene, mapRes, LeftDeliveryPointCallback)
    TownMapMgr.setPetScale(0.35)
    
    TownMapMgr.createWithRes(scene, mapRes, LeftDeliveryPointCallback, nil)
    TownMapMgr.setPlayerScale(0.5)
    local effect = PlayerAnimeMgr.showWorldPKEffect(TownMapMgr.Player,CharInfo.getVIPLevel(),PlayerAnimeMgr.SELF_TAG_STRING)
    if effect ~= nil then
        effect:setScale(0.75,0.75)
    end
    TownChatMgr.removeUI()
end

function HomeMapMgr.setMapButton(btnName, callback)
    TownMapMgr.setMapButton(btnName,callback)
end

return HomeMapMgr