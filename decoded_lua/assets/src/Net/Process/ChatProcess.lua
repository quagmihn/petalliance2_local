require("src.Net.Proto.ProtoInclude")

local ChatProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function ChatProcess.init()
    NetMgr.addProcess(Proto.Command.GC_CHANGECHANNEL_ACK,
        ChatProcess.onGC_ChangeChannel_Ack)
    NetMgr.addProcess(Proto.Command.GC_CHAT_NTF,
        ChatProcess.onGC_Chat_Ntf)
    NetMgr.addProcess(Proto.Command.GC_CHAT_ACK,
        ChatProcess.onGC_Chat_Ack)
    NetMgr.addProcess(Proto.Command.GC_USESPACEBUGLE_ACK,
        ChatProcess.onGC_UseSpaceBugle_Ack)
    NetMgr.addProcess(Proto.Command.GC_SPACEBUGLE_NTF,
        ChatProcess.onGC_SpaceBugle_Ntf)

    NetMgr.addProcess(Proto.Command.ZC_SCREENCHAT_BRD, 
        ChatProcess.onZC_ScreenChat_Brd) 

end

function ChatProcess.onZC_ScreenChat_Brd(msg)
	
    local res = Proto.parseP_ZC_ScreenChat_Brd(msg)
    MsgPrinter.rcvMsg(res, "ZC_ScreenChat_Brd")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    return res.code
	
end


function ChatProcess.onGC_SpaceBugle_Ntf(msg)

    local res = Proto.parseP_GC_SpaceBugle_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_SpaceBugle_Ntf")
--    print("GC_SpaceBugle_Ntf....",BattlePVPMgr.getBattleID()) 
--    if not BattlePVPMgr.getBattleID() then
--        local btn = CSResourceMgr.getNodeByName("Charactor/Menu/MainMenu.csb","b1")
--        if btn then
--            BattleFuncMgr.nodeVaryColor(btn,{255,0,125}) 
--        else
--            BattleFuncMgr.removeVaryColor()
--        end
--    else
--        BattleFuncMgr.removeVaryColor()
--    end
    BattlePVPMgr.onRecvNewBattleID(tonumber(res.content.text))
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_SPACEBUGLE_NTF)
    return res.code

end

function ChatProcess.onGC_UseSpaceBugle_Ack(msg)

    local res = Proto.parseP_GC_UseSpaceBugle_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_UseSpaceBugle_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_USESPACEBUGLE_ACK)
    return res.code

end

function ChatProcess.onGC_Chat_Ack(msg)

    local res = Proto.parseP_GC_Chat_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_Chat_Ack")

    if (Proto.Error.ERROR_OK == res.code) then
    else
        TipsMgr.showError(nil, res.code)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CHAT_ACK)
    return res.code

end

function ChatProcess.onGC_Chat_Ntf(msg)

    local res = Proto.parseP_GC_Chat_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_Chat_Ntf")
    if res.concent ~= nil then
        --print("**********onGC_Chat_Ntf res.channel="..res.channel.." res.concent="..res.concent)
        local cjson = require("cjson")
        local content = cjson.decode(res.concent) or {}
        if content.home_msg ~= nil then
            --print("$$$$$$$$$$invite_enter_home res.charIDFrom="..tostring(res.charIDFrom))
            if content.home_msg == HomeInfo.CHAT_CONTENT_INVITE_ENTER_HOME then
                if tonumber(res.charIDFrom) ~= CharInfo.getCharID() and (SceneMgr.currentScene ~= "HomeScene" or HomeInfo.GetCurrentHomeCharID() ~= tonumber(res.charIDFrom)) and not TeamInfo.getInfo(TeamInfo.KEY_TEAMID) and SceneMgr.currentScene ~= "BossMapScene" then
                    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, res.charIDFromName..LuaSqlite.getLanguageByKey("home003"), function()
                        if SceneMgr.currentScene == "HomeScene" then
                            HomeInfo.BroadcastHomePlayerLeaveMsg(CharInfo.getNickName())
                        end
                        HomeInfo.SetCurrentHomeCharID(tonumber(res.charIDFrom))
                        FamilyInfo.SetLastQueryMemberDetailInfo({nickname = res.charIDFromName})
                        SceneMgr.mapEnterType = 1
                        SceneMgr.replaceScene(SceneMgr.getRunningScene, "HomeScene")
                    end, nil, nil, false)
                end
            elseif content.home_msg == HomeInfo.CHAT_CONTENT_HOME_PLAYER_UPDATE then
                --print("@@@@@@@@@@@@recv HomeInfo.CHAT_CONTENT_HOME_PLAYER_UPDATE:"..sz_T2S(content))
                if tonumber(res.charIDFrom) ~= CharInfo.getCharID() and SceneMgr.currentScene == "HomeScene" then
                    HomeInfo.AddLocalPlayer(res.charIDFrom, content.level, content.confraternity, content.nickname, content.petID, content.petname, content.posx, content.speed, content.playerSkin)
                end
            elseif content.home_msg == HomeInfo.CHAT_CONTENT_HOME_PLAYER_LEAVE then
                if tonumber(res.charIDFrom) ~= CharInfo.getCharID() and SceneMgr.currentScene == "HomeScene" then
                    HomeInfo.RemoveLocalPlayer(res.charIDFrom)
                end
            elseif content.home_msg == HomeInfo.CHAT_CONTENT_HOME_CHANGED then
                local cfg = content.home
                if tonumber(res.charIDFrom) ~= CharInfo.getCharID() and SceneMgr.currentScene == "HomeScene" and cfg and HomeInfo.GetCurrentHomeCharID() == tonumber(res.charIDFrom) then
                    FurnitureViewMgr.EmptyFurnitureTable()
                    FurnitureViewMgr.InitPlaceableArea(3)
                    FurnitureViewMgr.InitBlueRedSprite()
                    FurnitureViewMgr.InitBlockInfo()
                    FurnitureViewMgr.InitExpandLevel()
                    if cfg.level ~= nil then
                        FurnitureViewMgr.SetExpandLevel(cfg.level)
                    else
                        FurnitureViewMgr.SetExpandLevel(1)
                    end
                    if cfg.homeName ~= nil then
                        FurnitureViewMgr.SetHomeName(cfg.homeName)
                    else
                        FurnitureViewMgr.SetHomeName(res.charIDFromName)
                    end
                    if cfg.furnitures ~= nil then
                        for k,v in pairs(cfg.furnitures) do
                            --print("###########GC_GetHome_Ack k="..tostring(k))
                            local objID = tonumber(k)
                            local itemID = v.itemID
                            --print("###########GC_GetHome_Ack objID="..tostring(objID).." itemID="..tostring(itemID))
                            local Index = v.otherParam["Index"]
                            --print("###########GC_GetHome_Ack index="..tostring(Index))
                            local FurnitureType = FurnitureViewMgr.GetFurnitureType(itemID)
                            if FurnitureType == Proto.FT_DOOR or FurnitureType == Proto.FT_DOORBOARD or FurnitureType == Proto.FT_LAMP or 
                                FurnitureType == Proto.FT_ROOT or FurnitureType == Proto.FT_FLOOR or FurnitureType == Proto.FT_WALLPAPER then
                                FurnitureViewMgr.ShowFixedFurnitureFromServer(FurnitureType, itemID, objID, Index)
                            else
                                FurnitureViewMgr.ShowFurnitureByIndex(itemID, objID, Index, FurnitureType)
                            end
                        end
                    end
    
                    FurnitureViewMgr.SortFurniture()
                end
            end
        elseif content.family_msg ~= nil then
            if content.family_msg == FamilyInfo.CMD.CHAT_CONTENT_INVITE_ENTER_FAMILY then
                if tonumber(res.charIDFrom) ~= CharInfo.getCharID() and SceneMgr.currentScene ~= "BossMapScene" then
                    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, CocosModuleMgr.createStringWithFormat({"family11", res.charIDFromName,
                        content.name, content.id}), function()
                        FamilyInfo.JoinFamily(content.id)
                        FamilyInfo.SendInviteEnterFamilyAck(res.charIDFrom, 1)
                    end, function()
                        FamilyInfo.SendInviteEnterFamilyAck(res.charIDFrom, 0)
                    end, nil, false)
                end
            elseif content.family_msg == FamilyInfo.CMD.CHAT_CONTENT_INVITE_ENTER_FAMILY_ACK then
                if tonumber(res.charIDFrom) ~= CharInfo.getCharID() then
                    if content.result == 0 then
                        StandardTipsMgr.show(1, "family10")
                    else
                        StandardTipsMgr.show(0, "family16")
                    end
                end
            end
        else
            TownChatMgr.onMessageNtf(res.channel,res.charIDFromName,res.concent,res.charIDTo,res.charIDFrom)
        end
    end

    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CHAT_NTF)
    return res.code

end

function ChatProcess.onGC_ChangeChannel_Ack(msg)

    local res = Proto.parseP_GC_ChangeChannel_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ChangeChannel_Ack")
    --print("@@@@@@@@@@@@@ChangeChannel_Ack res.code="..tostring(res.code))
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CHANGECHANNEL_ACK)
    return res.code

end

return ChatProcess
