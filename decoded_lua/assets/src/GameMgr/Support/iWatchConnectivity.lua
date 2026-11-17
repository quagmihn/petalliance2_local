local iWatchConnectivity = {}

local ballVec = {}

function iWatchConnectivity.Init()
    ballVec = {
        [1] = 2,
        [2] = 3,
        [3] = 1,
    }
end

function iWatchConnectivity.checkIsBall(itemID)
	for key, var in pairs(ballVec) do
		if var==itemID then
			return true
		end
	end
	return false
end

function iWatchConnectivity.saveMainData()
    if device.platform == "ios" or device.platform == "windows" then
        local finfo = FamilyInfo.GetLocalFamilyInfo() or {}
        local fname = finfo.name or LuaSqlite.getLanguageByKey("personalInfo3")
        UserSettings.set({
            name   = CharInfo.getNickName(),
            charid = CharInfo.getCharID(),
            level  = CharInfo.getLevel(),
            icon   = CharInfo.getHeadIcon(CharInfo.getCurfashion()),
            power  = PokemonInfo.getFightPointByObjID(PokemonInfo.getPetArmy(1)),
            rank   = CharInfo.getArenaTopRank(),
            achv   = CharInfo.get().achievementpoint or 0,
            family = fname,
            arena  = CharInfo.getArenaScore(),
            floor  = CharInfo.get().losttowerfloor or 0,
            tower  = CharInfo.get().losttowerpoint or 0,
        }, 12)
	end
end

function iWatchConnectivity.saveItemData()
    if device.platform == "ios" or device.platform == "windows" then
        local watchRandomPetVec = PokemonInfo.getWatchRandomPetVec()
        UserSettings.set({
            ball1   = ItemInfo.getCharItemNum(2),
            ball2   = ItemInfo.getCharItemNum(3),
            ball3   = ItemInfo.getCharItemNum(1),
            pokeid  = watchRandomPetVec.petID,
            icon    = watchRandomPetVec.petIcon,
        }, 13)
    end
end

function iWatchConnectivity.initSession()
    if device.platform == "ios" then
        luaoc.callStaticMethod("WCInterface", "initWC", {listener = function(key, jsonStr)
            print("iWatch Connectivity listener, ", key)
            local cjson = require("cjson")
            local tbl = cjson.decode(jsonStr)
            if tbl then
                for k, v in pairs(tbl) do
                    print("info:", k, v)
                end
            end
            if key=="CatchPet" then
                iWatchConnectivity.checkCatchPet()
            end
        end, charinfoFile=UserSettings.getFullPath(12), extensioninfoFile=UserSettings.getFullPath(13),
        catchpetFile=UserSettings.getFullPath(14), successDesc=LuaSqlite.getLanguageByKey("iwatch1"),
        failDesc=LuaSqlite.getLanguageByKey("iwatch2"), errorDesc=LuaSqlite.getLanguageByKey("iwatch3")})
    end
end

function iWatchConnectivity.checkCatchPet()
    if device.platform == "ios" or device.platform == "windows" then
        if CharInfo.getCharID()==0 then
        	return
        end
	    --发送协议后执行这句
	    local function finish()
            UserSettings.set({
                pokeid  = 0,
                ballid  = 0,
            }, 14)
	    end
        local ballid = UserSettings.get("ballid", 14) or 0
        local pokeid = UserSettings.get("pokeid", 14) or 0
        ballid = tonumber(ballid) or 0
        pokeid = tonumber(pokeid) or 0
        if ballid~=0 and pokeid~=0 then
            NetInterface.sendWithBlock("GC_IwatchCatchPet_Ack", function()
                local PetSend = require("src.Net.Send.PetSend")
                PetSend.sendCG_IwatchCatchPet_Req({petID = pokeid, itemID = ballVec[ballid]})
            end, function()
                DialogBoxMgr.showSmallDialogBox(nil, 1, "iwatch8")
                finish()
            end, function(code)
                print("iwatch catch pet error code", code)
                StandardTipsMgr.show(1, "iwatch4")
                if code==515 then
                    StandardTipsMgr.show(1, "iwatch7")
                elseif code==31 then
                    StandardTipsMgr.show(1, "iwatch6")
                elseif code==357 then
                    StandardTipsMgr.show(1, "iwatch5")
                end
                finish()
            end)
        else
            finish()
	    end
	end
end

return iWatchConnectivity