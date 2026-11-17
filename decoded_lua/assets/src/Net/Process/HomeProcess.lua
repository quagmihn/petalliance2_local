require("src.Net.Proto.ProtoInclude")

local HomeProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function HomeProcess.init()
    NetMgr.addProcess(Proto.Command.GC_BUYHOME_ACK,
        HomeProcess.onGC_BuyHome_Ack)
    NetMgr.addProcess(Proto.Command.GC_SETHOME_ACK,
        HomeProcess.onGC_SetHome_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETHOME_ACK,
        HomeProcess.onGC_GetHome_Ack)

end

function HomeProcess.onGC_GetHome_Ack(msg)

    local res = Proto.parseP_GC_GetHome_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetHome_Ack")
    if TOUCH_PIPELINE_DIAGNOSTICS then
        print(string.format("[NET_DIAG] home_ack actual_id=%s code=%s char_id=%s home_bytes=%s scene=%s",
            tostring(res.msgID), tostring(res.code), tostring(res.charID),
            tostring(res.home and #res.home or 0), tostring(SceneMgr.currentScene)))
    end
    if (Proto.Error.ERROR_OK == res.code) then
        print("###########GetHome_Ack res.charID="..tostring(res.charID).." res.home="..tostring(res.home))
        local cjson = require("cjson")
        local cfg = cjson.decode(res.home)
        if res.charID == CharInfo.getCharID() then
            HomeInfo.SetLocalHomeInfo(cfg)
        end
        --print(sz_T2S(cfg))
        if SceneMgr.currentScene == "HomeScene" then
            if res.charID == HomeInfo.GetCurrentHomeCharID() then
                if cfg ~= nil then
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
                        FurnitureViewMgr.SetHomeName(HomeInfo.getDefaultHomeNameByID(res.charID))
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
                else
                    FurnitureViewMgr.SetHomeName(HomeInfo.getDefaultHomeNameByID(res.charID))
                end
                TownMapMgr.Pet:setLocalZOrder(CocosModuleMgr.ZORDER_GUIDE - 1)
            else
                HomeInfo.SetNeighborHomeInfo(res.charID, cfg)
            end
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETHOME_ACK)
    return res.code

end

function HomeProcess.onGC_SetHome_Ack(msg)

    local res = Proto.parseP_GC_SetHome_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_SetHome_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("###########SetHome_Ack res.home="..tostring(res.home))
        local cjson = require("cjson")
        local cfg = cjson.decode(res.home)
        HomeInfo.SetLocalHomeInfo(cfg)
        if cfg.furnitures ~= nil then
            for k,v in pairs(cfg.furnitures) do
                --print("###########GC_GetHome_Ack k="..tostring(k))
                local objID = tonumber(k)
                local itemID = v.itemID
                --print("###########GC_GetHome_Ack objID="..tostring(objID).." itemID="..tostring(itemID))
                local Index = v.otherParam["Index"]
                --print("###########GC_GetHome_Ack index="..tostring(Index))
                --FurnitureViewMgr.ShowFurnitureByIndex(itemID, objID, Index)
                local furniture = FurnitureViewMgr.GetFurnitureByIndex(Index)
                if furniture ~= nil then
                    furniture:setTag(objID)
                end
                FurnitureViewMgr.SetFurnitureNewObjIDByIndex(Index,objID)
            end
        end
        
        HomeInfo.BroadcastHomeChanged(cfg)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_SETHOME_ACK)
    return res.code

end

function HomeProcess.onGC_BuyHome_Ack(msg)

    local res = Proto.parseP_GC_BuyHome_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_BuyHome_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("###########BuyHome_Ack res="..tostring(res.home))
        local cjson = require("cjson")
        local cfg = cjson.decode(res.home)
        --if cfg.level ~= nil and cfg.level > FurnitureViewMgr.GetExpandLevel() then
        FurnitureViewMgr.SetExpandLevel(cfg.level or 1)
        local home = HomeInfo.GetLocalHomeInfo()
        if home then
            home.level = cfg.level or 1
        end
        --end
        HomeInfo.BroadcastHomeChanged(cfg)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_BUYHOME_ACK)
    return res.code

end

return HomeProcess
