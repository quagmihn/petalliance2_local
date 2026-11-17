local ArenaMainMgr = {}

local resName = ""

function ArenaMainMgr.Init()
	resName = "Player/ArenaMain.csb"
end

function ArenaMainMgr.getWAreaUseTimes()
    local PKtimeMax = SystemInfo.getGlobalConfigAddInfoByID(64003).values[1]
    local PKtimes   = PKtimeMax - (CharInfo.getTodayWArenaFightTimes() or 0)
    local updateTime  = CharInfo.getWArenaUpdateTime()
    local todayTime   = CharInfo.getServerTime()
    local buyPKTimes   = CharInfo.getTodayWArenaFightRefreshTimes()
    local pkHour = SystemInfo.getGlobalConfigAddInfoByID(90).values[1]
    if nil == updateTime then
        return PKtimeMax,PKtimeMax,0
    end
    if PKtimes < 0 then
        PKtimes = 0
    end

    if CocosModuleMgr.getDayTimeDiff(updateTime, todayTime, pkHour*3600) == 0 then
        return PKtimeMax,(PKtimes or PKtimeMax),(buyPKTimes or 0)
    else
        return PKtimeMax,PKtimeMax,0
    end
    
end

function ArenaMainMgr.show(scene)
    UIStack.push("ArenaMainMgr", ArenaMainMgr.hide, false)
    
    local function loadCsb()
        local layer = CSResourceMgr.createRes(scene, resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CocosModuleMgr.setRelativePosition(layer, 320, 480)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)

        CSResourceMgr.setLabelColor(resName, "title", {r=166,g=243,b=255,a=255})
        CSResourceMgr.setLabelString(resName, "title", "town7", "", {r=37,g=54,b=75,a=255})
        CSResourceMgr.setSpriteTexture(resName, "image3", CocosModuleMgr.getWordImage("arena_pictures_02.png"), "", false)
        CSResourceMgr.setSpriteTexture(resName, "image2", CocosModuleMgr.getWordImage("arena_pictures_03.png"), "", false)
        local nameStr = {"arena1","CrossServerWar1", "arenapk1"}
        local lockInfo = {SystemInfo.getGlobalConfigAddInfoByID(24002).values[1],SystemInfo.getGlobalConfigAddInfoByID(64004).values[1],SystemInfo.getGlobalConfigAddInfoByID(24013).values[1]}
        local lockStr = {}
        for var=1, #lockInfo do
            if lockInfo[var]==999 then
                lockStr[var] = "tips41"
        	else
                lockStr[var] = CocosModuleMgr.createStringWithFormat({"tips15", lockInfo[var]})
        	end
        end
        
        for var=1, #nameStr do
            CSResourceMgr.setLabelColor(resName, "text"..var, {r=251,g=240,b=215,a=255})
            CSResourceMgr.setLabelString(resName, "text"..var, nameStr[var], "", {r=80,g=61,b=35,a=255,w=1}, nil, 140)
            CSResourceMgr.clickEventBinding(resName, "b"..var, function()
                ArenaMainMgr.hide()
                if var==1 then
                    if CharInfo.getAutoArenaBattle() == false then
                        ArenaViewMgr.request(scene)
                    else
                        MArenaViewMgr.request(scene)
                    end
                elseif var==2 then
                    if false == ArenaMainMgr.checkWorldFullPets() then
                        StandardTipsMgr.show(1, "CrossServerWar17")
                        return 
                    end
                    if true == ArenaMainMgr.checkWorldPK() then
                        local WorldPKUIMgr = require("src.GameMgr.Player.WorldPKUIMgr")
                        WorldPKUIMgr.new(scene)
                    else
                        StandardTipsMgr.show(1, "CrossServerWar16")
                    end
                elseif var==3 then
                    ArenaPKViewMgr.show(scene)
                end
            end, "", 2)
            if CharInfo.getLevel()<lockInfo[var] then
                CSResourceMgr.setButtonEnabled(resName, "b"..var, false)
                --CSResourceMgr.getNodeByName(resName, "infodb"..var):setVisible(false)
                CSResourceMgr.getNodeByName(resName, "b"..var):setColor({r=100,g=100,b=100})
                -- CSResourceMgr.setLabelString(resName, "lock"..var, lockStr[var], "", {r=0,g=0,b=0,a=255,w=1}, nil, 200)
                CSResourceMgr.setLabelString(resName, "info"..var, lockStr[var], "", {r=0,g=0,b=0,a=255,w=1}, nil, 200)
            else
                if var==1 then
                    local timesAll = SystemInfo.getGlobalConfigAddInfoByID(7004).values[1]
                    local timesRemain = CharInfo.getAutoArenaBattle() == false and ArenaInfo.getChallengeTimes() or ArenaInfo.getMChallengeTimes()
                    local iStr = CocosModuleMgr.createStringWithFormat({"arena56", timesRemain, timesAll})
                    CSResourceMgr.setLabelString(resName, "info"..var, iStr, "", nil, nil, 180)
                elseif var==2 then
                    local PKtimeMax,PKtimes = ArenaMainMgr.getWAreaUseTimes()
                    timesAll = PKtimes.."/"..PKtimeMax
                    local iStr = CocosModuleMgr.createStringWithFormat({"CrossServerWar5",
                        timesAll})
                    CSResourceMgr.setLabelString(resName, "info"..var, iStr, "", nil, nil, 180)
                elseif var==3 then
                    local curArenaLevel = ArenaInfo.getPVPArenaLevel()
                    local curArenaName = ArenaInfo.getPVPArenaGradeInfoById(curArenaLevel).gradeName
                    local iStr = CocosModuleMgr.createStringWithFormat({"arena57", curArenaName})
                    CSResourceMgr.setLabelString(resName, "info"..var, iStr, "", nil, nil, 180)
                end
            end
            if (device.platform=="ios" or device.platform=="windows") and lockInfo[var] == 999 then
                CSResourceMgr.getNodeByName(resName, "b"..var):setVisible(false)
                CSResourceMgr.getNodeByName(resName, "text"..var):setVisible(false)
                CSResourceMgr.getNodeByName(resName, "lock"..var):setVisible(false)
            end
        end

        CSResourceMgr.clickEventBinding(resName, "bg", function()
            ArenaMainMgr.hide()
        end)
    end

    local function playCsb()
        local db = CSResourceMgr.getNodeByName(resName, "db")
        db:setVisible(true)
        CocosModuleMgr.showUIAnimation(db, "down")
    end

    local funcTable = {loadCsb, playCsb}
    UnblockLoader.load(funcTable, "ArenaMainMgr.show")
end

function ArenaMainMgr.checkWorldFullPets()
    local petArmy = PokemonInfo.getPetArmy(1)
    local petHelpVec = PokemonInfo.getPetHelpArmy()
    local petNumber  = 0
    for key,var in pairs(petArmy) do
        if key > 3 then break end
        petNumber = petNumber + 1
    end
    for key,var in pairs(petHelpVec) do
        petNumber = petNumber + 1
    end
    if petNumber >= 6 then
        return true
    else
        return false
    end
end

function ArenaMainMgr.checkWorldPK()
    local todayTime   = CharInfo.getServerTime()
    local todayInfo   = os.date("*t",todayTime)
    local lastTime    = 0 
    local w = os.date("%w", CharInfo.getServerTime())
    local todaysTottalSec = todayInfo.hour * 3600 + todayInfo.min * 60 + todayInfo.sec
    local GlobalWeek = SystemInfo.getGlobalConfigAddInfoByID(64001).values[1]
    local GlobalSec  = SystemInfo.getGlobalConfigAddInfoByID(64001).values[2]
    local restWD = GlobalWeek - w

    if restWD == 0 and todaysTottalSec > GlobalSec then
        todayInfo.hour = math.floor(GlobalSec/3600)
        todayInfo.min  = math.floor((GlobalSec - todayInfo.hour*3600)/60)
        todayInfo.sec  = GlobalSec - todayInfo.hour*3600 - todayInfo.min*60
        lastTime   = os.time(todayInfo)
        if todayTime <= lastTime + 3600 then
            return false
        end
    end
    return true
    
end

function ArenaMainMgr.hide()
    UnblockLoader.cancel("ArenaMainMgr.show")
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("ArenaMainMgr")
end

return ArenaMainMgr