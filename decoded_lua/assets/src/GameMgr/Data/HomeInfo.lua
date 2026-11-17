local HomeInfo = {}

local CurrentHomeCharID = 0                         --0:代表家族大厅
local FurnitureInfo = nil
local LocalHomeInfo = nil
local LocalPlayerInfo = {}
local MaxHomeGuestNum = 9

local NeighborHomeInfo = {nil, nil}
local allSortedFamilyMembers = {}

HomeInfo.CHAT_CONTENT_INVITE_ENTER_HOME = "invite_enter_home"
HomeInfo.CHAT_CONTENT_HOME_PLAYER_UPDATE = "home_player_update"
HomeInfo.CHAT_CONTENT_HOME_PLAYER_LEAVE = "home_player_leave"
HomeInfo.CHAT_CONTENT_HOME_CHANGED = "home_changed"

function HomeInfo.Init()
    CurrentHomeCharID = CharInfo.getCharID()
    
    if FurnitureInfo==nil then
    	FurnitureInfo = {}
        local FurnitureInfoReader = TxtReader.new("Config/Furniture.txt")
        local FurnitureData = FurnitureInfoReader.init({"id", "name", "width", "anchor_x", "anchor_y", "res_path"}, 1)
        for key, var in pairs(FurnitureData) do
            local id = tonumber(var.id)
            FurnitureInfo[id] = {name=(var["name"]), width=tonumber(var["width"]), anchor_x=tonumber(var["anchor_x"]), anchor_y=tonumber(var["anchor_y"]), res_path=(var["res_path"])}
            --print("@@@@@@@@@@@@@@@@@name="..FurnitureInfo[id].name)
        end
    end
    
    LocalHomeInfo = nil
    LocalPlayerInfo = {}
    MaxHomeGuestNum = 9
    
    NeighborHomeInfo = {nil, nil}
    allSortedFamilyMembers = {}
end

function HomeInfo.SetCurrentHomeCharID(id)
    CurrentHomeCharID = id
end

function HomeInfo.GetCurrentHomeCharID()
    return CurrentHomeCharID
end

function HomeInfo.SetLocalHomeInfo(info)
    if info ~= nil then
        LocalHomeInfo = info
        StatusBarMgr.refreshServerTime()
    end
end

function HomeInfo.GetLocalHomeInfo()
    return LocalHomeInfo
end

function HomeInfo.GetLocalHomeFurnitureNum()
    local num = 0
    if LocalHomeInfo ~= nil and LocalHomeInfo.furnitures ~= nil then
        for k,v in pairs(LocalHomeInfo.furnitures) do
            num = num + 1
        end
    end
    --print("+++++++GetLocalHomeFurnitureNum num=",num)
    return num
end

function HomeInfo.GetMaxRareDegreeFurniture(type)
    local FurnitureID = nil
    local maxRareDegree = -1
    if type ~= Proto.FT_NONE and LocalHomeInfo ~= nil and LocalHomeInfo.furnitures ~= nil then
        for k,v in pairs(LocalHomeInfo.furnitures) do
            local itemID = v.itemID
            local itemData = ItemInfo.getItemInfoById(itemID)
            if itemData ~= nil and itemData.paramA == type and itemData.itemRare > maxRareDegree then
                FurnitureID = itemID
                maxRareDegree = itemData.itemRare
            end
        end
    end
    return FurnitureID
end

function HomeInfo.ClearLocalPlayerInfo()
    for i=1, #LocalPlayerInfo do
        TownPlayerMgr.removePlayer(LocalPlayerInfo[i].charID)
    end
    LocalPlayerInfo = {}
end

function HomeInfo.GetLocalPlayerInfo()
    return LocalPlayerInfo
end

function HomeInfo.getFurnitureInfoByID(id)
    local data = FurnitureInfo[id]
    if data ~= nil then
        return data.name,data.width,data.anchor_x,data.anchor_y,data.res_path
    end
end

function HomeInfo.getFurnitureInfo()
    return FurnitureInfo
end

local function setMiddle2FamilyYard()
    if SceneMgr.currentScene == "HomeScene" then
        local info = FamilyInfo.GetLocalFamilyInfo()
        if info ~= nil then
            FurnitureViewMgr.setMiddle2FamilyYard(info.familyLevel or 1, info.name)
        end
    end
end

local function setLower2FamilyYard()
    if SceneMgr.currentScene == "HomeScene" then
        local info = FamilyInfo.GetLocalFamilyInfo()
        if info ~= nil then
            FurnitureViewMgr.setLower2FamilyYard(info.familyLevel or 1, info.name)
        end
    end
end

function HomeInfo.GetHomeInfo(withBlock)
    if CurrentHomeCharID > 0 then
        local HomeSend = require("src.Net.Send.HomeSend")
        local func
        if withBlock == nil or withBlock == true then
            func = NetInterface.sendWithBlock
        else
            func = NetInterface.send
        end
        if TOUCH_PIPELINE_DIAGNOSTICS then
            print(string.format("[NET_DIAG] home_request mode=%s request_id=%s expected_ack=GC_GETHOME_ACK char_id=%s scene=%s",
                (withBlock == nil or withBlock == true) and "blocking" or "async",
                tostring(Proto.Command.CG_GETHOME_REQ), tostring(CurrentHomeCharID), tostring(SceneMgr.currentScene)))
        end
        
        func("GC_GETHOME_ACK", function()
            --print("!!!!!!!!!!!!!!!sendCG_GetHome_Req")
            HomeSend.sendCG_GetHome_Req(CurrentHomeCharID)
        end,function()
            --print("!!!!!!!!!!!!!!!GC_GETHOME_ACK")
        end, function(code)
            --TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"login12", code}))
            StandardTipsMgr.show(1, "get home failed ")
        end)
    else
        setMiddle2FamilyYard()
    end
end

function HomeInfo.SetHomeInfo(homeName, addFurnitureObjID, addIdx, delFurnitureObjID, moveFurnitureObjID, moveIdx)
    local HomeSend = require("src.Net.Send.HomeSend")
    
    NetInterface.sendWithBlock("GC_SETHOME_ACK", function()
        --print("!!!!!!!!!!!!!!!sendCG_SetHome_Req")
        local cjson = require("cjson")
        local addFurnitures = {}
        if addFurnitureObjID ~= 0 then
            local contents = json.encode({objID = addFurnitureObjID, otherParam = {Index = addIdx}})
            addFurnitures = {contents}
        end
        local moveFurnitures = {}
        if moveFurnitureObjID ~= 0 then
            local contents = json.encode({objID = moveFurnitureObjID, otherParam = {Index = moveIdx}})
            moveFurnitures = {contents}
        end
        HomeSend.sendCG_SetHome_Req({homeName = homeName, addFurnitures = addFurnitures, delFurnitureObjID = delFurnitureObjID, moveFurnitures = moveFurnitures})
    end,function()
        --print("!!!!!!!!!!!!!!!GC_SETHOME_ACK")
        if addFurnitureObjID ~= 0 and delFurnitureObjID == 0 then
            TaskWatcherManager.savePutANewFurniture({furnitureNum = HomeInfo.GetLocalHomeFurnitureNum()})
        end
    end, function(code)
        --TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"login12", code}))
        StandardTipsMgr.show(1, "set home failed ")
    end)
end

function HomeInfo.BuyHome()
    local HomeSend = require("src.Net.Send.HomeSend")

    NetInterface.sendWithBlock("GC_BUYHOME_ACK", function()
        --print("!!!!!!!!!!!!!!!sendCG_BuyHome_Req")
        HomeSend.sendCG_BuyHome_Req()
    end,function()
        --print("!!!!!!!!!!!!!!!GC_BUYHOME_ACK")
        StandardTipsMgr.show(0,"home021")
        TaskWatcherManager.saveJiaYuanKuoJIanState()
    end, function(code)
        --TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"login12", code}))
        if code == Proto.Error.ERROR_NOTENOUGH_RMB then
            StandardTipsMgr.show(1,"tips14")
        end
    end)
end

function HomeInfo.SendInviteEnterHome(friendID)
    local cjson = require("cjson")
    local contents = json.encode({home_msg = HomeInfo.CHAT_CONTENT_INVITE_ENTER_HOME})
    local ChatSend = require("src.Net.Send.ChatSend")
    ChatSend.sendCG_Chat_Req({charID = friendID, channel = "", concent = contents})
end

function HomeInfo.BroadcastHomePlayerUpdateMsg(level, confraternity, nickname, petID, petname, posx, speed, playerSkin)
    local cjson = require("cjson")
    local contents = json.encode({home_msg = HomeInfo.CHAT_CONTENT_HOME_PLAYER_UPDATE, level = level, confraternity = confraternity, nickname = nickname, petID = petID, petname = petname, posx = posx, speed = speed, playerSkin = playerSkin})
    local ChatSend = require("src.Net.Send.ChatSend")
    ChatSend.sendCG_Chat_Req({charID = "", channel = "Home_"..tostring(CurrentHomeCharID == 0 and "yard_"..(CharInfo.getFamilyID() or 0) or CurrentHomeCharID), concent = contents})
end

function HomeInfo.SendHomePlayerUpdateMsg(friendID, level, confraternity, nickname, petID, petname, posx, speed, playerSkin)
    local cjson = require("cjson")
    local contents = json.encode({home_msg = HomeInfo.CHAT_CONTENT_HOME_PLAYER_UPDATE, level = level, confraternity = confraternity, nickname = nickname, petID = petID, petname = petname, posx = posx, speed = speed, playerSkin = playerSkin})
    local ChatSend = require("src.Net.Send.ChatSend")
    ChatSend.sendCG_Chat_Req({charID = friendID, channel = "Home_"..tostring(CurrentHomeCharID == 0 and "yard_"..(CharInfo.getFamilyID() or 0) or CurrentHomeCharID), concent = contents})
end

function HomeInfo.BroadcastHomePlayerLeaveMsg(nickname)
    local cjson = require("cjson")
    local contents = json.encode({home_msg = HomeInfo.CHAT_CONTENT_HOME_PLAYER_LEAVE, nickname = nickname})
    local ChatSend = require("src.Net.Send.ChatSend")
    ChatSend.sendCG_Chat_Req({charID = "", channel = "Home_"..tostring(CurrentHomeCharID == 0 and "yard_"..(CharInfo.getFamilyID() or 0) or CurrentHomeCharID), concent = contents})
end

function HomeInfo.BroadcastHomeChanged(home)
    local cjson = require("cjson")
    local contents = json.encode({home_msg = HomeInfo.CHAT_CONTENT_HOME_CHANGED, home = home})
    local ChatSend = require("src.Net.Send.ChatSend")
    ChatSend.sendCG_Chat_Req({charID = "", channel = "Home_"..tostring(CurrentHomeCharID == 0 and "yard_"..(CharInfo.getFamilyID() or 0) or CurrentHomeCharID), concent = contents})
end

function HomeInfo.IsPlayerExist(charID)
    if charID ~= nil then
        for i=1, #LocalPlayerInfo do
            if charID == LocalPlayerInfo[i].charID then
                return i
            end
        end
    end
    return nil
end

function HomeInfo.AddLocalPlayer(charIDFrom, level, confraternity, nickname, petID, petname, posx, speed, playerSkin)
    if #LocalPlayerInfo < MaxHomeGuestNum then
        local diff = CocosModuleMgr.getScreenSizeDiff()
        TownPlayerMgr.addPlayerWithRes({charID = charIDFrom, mapres = "Map/TownMap/home_01.csb", level = level, confraternity = confraternity, nickname = nickname, petID = petID, petname = petname, posx = posx, speed = speed, playerSkin = playerSkin, posY = TownMapMgr.DEFAULT_TMAP_POSY_DIFF + 40 + (diff<0 and diff*0.66 or 0), playerScale = 0.8, playerZOrder = CocosModuleMgr.ZORDER_GUIDE - 2, mapNode = TownMapMgr.Map})
    end
    if HomeInfo.IsPlayerExist(charIDFrom) == nil then
        if #LocalPlayerInfo < MaxHomeGuestNum then
            table.insert(LocalPlayerInfo,{charID = charIDFrom, nickname = nickname, timestamp = CharInfo.getServerTime()})
        end
        HomeInfo.SendHomePlayerUpdateMsg(charIDFrom, tostring(CharInfo.getLevel()), FamilyInfo.GetMyFamilyName(), CharInfo.getNickName(), PokemonInfo.getFollowPokemonID(), CharInfo.getNickName().."的宠物", 260, 300, CharInfo.getCurfashion())
    end
end

function HomeInfo.RemoveLocalPlayer(charID)
    TownPlayerMgr.removePlayer(charID)
    local idx = HomeInfo.IsPlayerExist(charID)
    if idx ~= nil then
        table.remove(LocalPlayerInfo, idx)
    end
end

function HomeInfo.IsCurrentHomeGuestNumReachMax()
    return false
    --return #LocalPlayerInfo >= MaxHomeGuestNum
end

function HomeInfo.GetNeighborHomeInfo()
    NeighborHomeInfo = {nil, nil}
    
    NetInterface.send("GC_GetFriendDetail_Ack", function()
        local ChatUserSend = require("src.Net.Send.ChatUserSend")
        ChatUserSend.sendCG_GetFriendDetail_Req({friendID = (CurrentHomeCharID > 0 and CurrentHomeCharID or CharInfo.getCharID())})
    end,function()
        local detail = FamilyInfo.GetLastQueryMemberDetailInfo()
        --print("#############detail="..sz_T2S(detail))
        if detail ~= nil and ((CurrentHomeCharID < 1 and detail.charID == CharInfo.getCharID()) or (detail.charID == CurrentHomeCharID)) and detail.familyID ~= nil and detail.familyID >= 1 then
            FamilyInfo.QueryFamily(detail.familyID, false)
        end
    end)
end

local function sortAllFamilyMembersByActivity(allFamilyMembers)
    local info =  FamilyInfo.GetLocalFamilyInfo()
    allSortedFamilyMembers = {}
    for k,v in pairs(allFamilyMembers) do
        --[[
        if v.devotePoint == nil then
            v.devotePoint = 0
            v.validDevote = false
        else
            if tonumber(v.lastSetDevotePointTime or 0) > (info ~= nil and tonumber(info.lastDevoteRefreshTime or 0) or 0) then
                v.validDevote = true
            else
                v.validDevote = false
            end
        end
        ]]
        allSortedFamilyMembers[#allSortedFamilyMembers + 1] = v
        --print("=======allSortedFamilyMembers:"..sz_T2S(allSortedFamilyMembers))
    end
    
    --[[
    table.sort(allSortedFamilyMembers, function(a, b)
        if a.validDevote ~= b.validDevote then
            return a.validDevote
        else
            return a.devotePoint > b.devotePoint
        end
    end)
    ]]
end

function HomeInfo.getAllSortedFamilyMembers()
    return allSortedFamilyMembers
end

function HomeInfo.clearAllSortedFamilyMembers()
    allSortedFamilyMembers = {}
end

function HomeInfo.getDefaultHomeNameByID(charID)
    if charID > 0 then
        if charID == CharInfo.getCharID() then
            return CharInfo.getNickName()
        end
        for floor=1, #allSortedFamilyMembers do
            if allSortedFamilyMembers[floor].charID == charID then
                return allSortedFamilyMembers[floor].name
            end
        end
        local info = FamilyInfo.GetLastQueryMemberDetailInfo()
        if info then
            return info.nickname
        end
    end
    return "home009"
end

function HomeInfo.getCurrentHomeFloor()                         --(-1):代表家族大厅
    if CurrentHomeCharID < 1 then
        return -1
    end
    for floor=1, #allSortedFamilyMembers do
        if allSortedFamilyMembers[floor].charID == CurrentHomeCharID then
            return floor
        end
    end
    return nil
end

function HomeInfo.getCharHomeFloorByID(charID)
    for floor=1, #allSortedFamilyMembers do
        if allSortedFamilyMembers[floor].charID == charID then
            return (#allSortedFamilyMembers - floor + 1)
        end
    end
    return nil
end

function HomeInfo.getCharFamilyRankByID(charID)
    for rank=1, #allSortedFamilyMembers do
        if allSortedFamilyMembers[rank].charID == charID then
            return rank, #allSortedFamilyMembers
        end
    end
    return 1, 1
end

local function getHigherNeighborByFloor(allFamilyMembers, floor)
    if floor > 1 then
        NeighborHomeInfo[1] = {charID = allSortedFamilyMembers[floor - 1].charID}
        FurnitureViewMgr.setHigherNeighborHomeName(allSortedFamilyMembers[floor - 1].name)
    else
        if floor < 0 then
            NeighborHomeInfo[1] = {charID = allSortedFamilyMembers[#allSortedFamilyMembers].charID}
            FurnitureViewMgr.setHigherNeighborHomeName(allSortedFamilyMembers[#allSortedFamilyMembers].name)
        else
            NeighborHomeInfo[1] = nil
            FurnitureViewMgr.setHigherHomeVisible(false)
        end
    end
end

local function getLowerNeighborByFloor(allFamilyMembers, floor)
    if floor < #allSortedFamilyMembers and floor > 0 then
        NeighborHomeInfo[2] = {charID = allSortedFamilyMembers[floor + 1].charID}
        FurnitureViewMgr.setLowerNeighborHomeName(allSortedFamilyMembers[floor + 1].name)
    else
        if CharInfo.getFamilyID() ~= nil and floor == #allSortedFamilyMembers and HomeInfo.getCharHomeFloorByID(CharInfo.getCharID()) ~= nil then
            NeighborHomeInfo[2] = {charID = 0}
        else
            NeighborHomeInfo[2] = nil
            FurnitureViewMgr.setLowerHomeVisible(false)
        end
    end
end

function HomeInfo.GetNeighborByActivity(allFamilyMembers)
    if allFamilyMembers ~= nil then
        --print("======sort before:",sz_T2S(allFamilyMembers))
        sortAllFamilyMembersByActivity(allFamilyMembers)
        --print("======sort after:",sz_T2S(allSortedFamilyMembers))
        local CurrentHomeFloor = HomeInfo.getCurrentHomeFloor()
        if CurrentHomeFloor ~= nil then
            getHigherNeighborByFloor(allFamilyMembers, CurrentHomeFloor)
            getLowerNeighborByFloor(allFamilyMembers, CurrentHomeFloor)
            --print("========NeighborHomeInfo=",sz_T2S(NeighborHomeInfo))
            local HomeSend = require("src.Net.Send.HomeSend")
            if NeighborHomeInfo[1] ~= nil then
                NetInterface.send("GC_GETHOME_ACK", function()
                    HomeSend.sendCG_GetHome_Req(NeighborHomeInfo[1].charID)
                end,function()
                    if NeighborHomeInfo[2] ~= nil then
                        if NeighborHomeInfo[2].charID > 0 then
                            NetInterface.send("GC_GETHOME_ACK", function()
                                HomeSend.sendCG_GetHome_Req(NeighborHomeInfo[2].charID)
                            end,function()
                                FurnitureViewMgr.updateElevatorInfo((CurrentHomeFloor > 0 and (#allSortedFamilyMembers - CurrentHomeFloor + 1).."F" or "B1"), true, true)
                            end, function(code)
                                StandardTipsMgr.show(1, "get home failed code="..tostring(code))
                            end)
                        else
                            FurnitureViewMgr.updateElevatorInfo((CurrentHomeFloor > 0 and (#allSortedFamilyMembers - CurrentHomeFloor + 1).."F" or "B1"), true, true)
                            setLower2FamilyYard()
                        end
                    else
                        FurnitureViewMgr.updateElevatorInfo((CurrentHomeFloor > 0 and (#allSortedFamilyMembers - CurrentHomeFloor + 1).."F" or "B1"), true, false)
                    end
                end, function(code)
                    --TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"login12", code}))
                    StandardTipsMgr.show(1, "get home failed code="..tostring(code))
                end)
            elseif NeighborHomeInfo[2] ~= nil then
                if NeighborHomeInfo[2].charID > 0 then
                    NetInterface.send("GC_GETHOME_ACK", function()
                        HomeSend.sendCG_GetHome_Req(NeighborHomeInfo[2].charID)
                    end,function()
                        FurnitureViewMgr.updateElevatorInfo((CurrentHomeFloor > 0 and (#allSortedFamilyMembers - CurrentHomeFloor + 1).."F" or "B1"), false, true)
                    end,function(code)
                        StandardTipsMgr.show(1, "get home failed code="..tostring(code))
                    end)
                else
                    FurnitureViewMgr.updateElevatorInfo((CurrentHomeFloor > 0 and (#allSortedFamilyMembers - CurrentHomeFloor + 1).."F" or "B1"), false, true)
                    setLower2FamilyYard()
                end
            else
                FurnitureViewMgr.updateElevatorInfo((CurrentHomeFloor > 0 and (#allSortedFamilyMembers - CurrentHomeFloor + 1).."F" or "B1"), false, false)
            end
        end
    end
end

function HomeInfo.SetNeighborHomeInfo(charID, home)
    home = home or {}
    if charID ~= nil and home ~= nil then
        for k,v in pairs(NeighborHomeInfo) do
            if v.charID == charID then
                v.home = home
                if k == 1 then
                    FurnitureViewMgr.ShowHigherNeighborHomeInfo(home)
                elseif k == 2 then
                    FurnitureViewMgr.ShowLowerNeighborHomeInfo(home)
                end
                break
            end
        end
    end
    print("@@@@@@@@NeighborHomeInfo="..sz_T2S(NeighborHomeInfo))
end

function HomeInfo.upStairs()
    if NeighborHomeInfo[1] ~= nil then
        if SceneMgr.currentScene == "HomeScene" then
            HomeInfo.BroadcastHomePlayerLeaveMsg(CharInfo.getNickName())
        end
        
        HomeInfo.SetCurrentHomeCharID(NeighborHomeInfo[1].charID)
        HomeMenuMgr.resetMenu()
        HomeInfo.ClearLocalPlayerInfo()
        HomeInfo.GetHomeInfo(false)
        HomeInfo.GetNeighborHomeInfo()
        
        local ChatSend = require("src.Net.Send.ChatSend")
        ChatSend.sendCG_ChangeChannel_Req({channel = "Home_"..tostring(HomeInfo.GetCurrentHomeCharID() == 0 and "yard_"..(CharInfo.getFamilyID() or 0) or HomeInfo.GetCurrentHomeCharID()),data = "{}"})

        HomeInfo.BroadcastHomePlayerUpdateMsg(tostring(CharInfo.getLevel()), FamilyInfo.GetMyFamilyName(), CharInfo.getNickName(), PokemonInfo.getFollowPokemonID(), CharInfo.getNickName().."的宠物", 260, 300, CharInfo.getCurfashion())
    end
end

function HomeInfo.downStairs()
    if NeighborHomeInfo[2] ~= nil then
        if SceneMgr.currentScene == "HomeScene" then
            HomeInfo.BroadcastHomePlayerLeaveMsg(CharInfo.getNickName())
        end
        
        HomeInfo.SetCurrentHomeCharID(NeighborHomeInfo[2].charID)
        HomeMenuMgr.resetMenu()
        HomeInfo.ClearLocalPlayerInfo()
        HomeInfo.GetHomeInfo(false)
        HomeInfo.GetNeighborHomeInfo()

        local ChatSend = require("src.Net.Send.ChatSend")
        ChatSend.sendCG_ChangeChannel_Req({channel = "Home_"..tostring(HomeInfo.GetCurrentHomeCharID() == 0 and "yard_"..(CharInfo.getFamilyID() or 0) or HomeInfo.GetCurrentHomeCharID()),data = "{}"})

        HomeInfo.BroadcastHomePlayerUpdateMsg(tostring(CharInfo.getLevel()), FamilyInfo.GetMyFamilyName(), CharInfo.getNickName(), PokemonInfo.getFollowPokemonID(), CharInfo.getNickName().."的宠物", 260, 300, CharInfo.getCurfashion())
    end
end

return HomeInfo
