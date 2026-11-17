local ArenaRecordMgr = {}

local resName = ""
local recordNode = {}
ArenaRecordMgr.LABLE_OUTLINE_THICK = 1
ArenaRecordMgr.RECORD_NUM = 30
local textColor = {
    {r=246,g=74,b=1,a=255},   --下降文字颜色
    {r=102,g=255,b=0,a=255},    --上升文字颜色
}
local spritePath = {
    "UI/CommonFiles/frame_playback_label_red_su.png",   --失败旗子
    "UI/CommonFiles/frame_playback_label_green_su.png",    --胜利旗子
}
local spritePath2 = {
    "UI/CommonFiles/buff2.png",   --失败箭头
    "UI/CommonFiles/buff1.png",    --胜利箭头
}
local lastMsg = nil
local colorOne = false
-- local stopRequire = true
local recordNum = 0
local recordRounds = {}
local TeamA = {}
local TeamB = {}
local battleResult = 0
ArenaRecordMgr.isShareBattle = false
local enemyName = ""

local battlePetInfo = {}

function ArenaRecordMgr.Init()
    print("ArenaRecordMgr初始化")
    resName = "Player/Arena/ArenaRecord.csb"
    lastMsg = nil
    -- stopRequire = true
    recordNum = 0
    recordRounds = {}
    TeamA = {}
    TeamB = {}
    battleResult = 0
    enemyName = ""
    battlePetInfo = {}
end

function ArenaRecordMgr.show(scene)
    ArenaRecordMgr.isShareBattle = false
    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CocosModuleMgr.setEdgeDistance(layer, nil, nil, nil, 0)
        layer:setOpacity(0)
        transition.fadeIn(layer, {time=0.3})

        local diff = CocosModuleMgr.getScreenSizeDiff()
        local list = CSResourceMgr.getNodeByName(resName, "list")
        local lsize = list:getContentSize()
        list:setContentSize(lsize.width, lsize.height+diff)
        local titleIcon = CSResourceMgr.getNodeByName(resName, "titleIcon")
        local tiposy = titleIcon:getPositionY()
        titleIcon:setPositionY(tiposy+diff)   
        local title = CSResourceMgr.getNodeByName(resName, "title")
        local tposy = title:getPositionY()
        title:setPositionY(tposy+diff)   

        CSResourceMgr.setLabelColorByNode(title, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(title, "ArenaRecord0", {r=0,g=0,b=0,a=255,w=1,s=1})
        -- stopRequire = false
        ArenaRecordMgr.requireRecord()
    end

    loadCSB()
    -- local funcTable = {loadCSB}
    -- UnblockLoader.load(funcTable,"ArenaRecordMgr")
end

-- function ArenaRecordMgr.stopRequireRecord()
--     stopRequire = true
-- end

function ArenaRecordMgr.requireRecord(index)
    -- if stopRequire then
    --     return
    -- end
    NetInterface.sendWithBlock("GC_GetArenaRecode_Ack", function()
            local ArenaSend = require("src.Net.Send.ArenaSend")
            ArenaSend.sendCG_GetArenaRecode_Req({startIndex = 0,endIndex = 20})
        end,function()
            -- if not stopRequire then
            --     ArenaRecordMgr.requireRecord(index+1)
            -- end
        end)
end

function ArenaRecordMgr.setRecord(var)
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    local list = CSResourceMgr.getNodeByName(resName,"list")
    local parent =  CSResourceMgr.getNodeByName(resName, "info_diban"):clone()
    parent:setVisible(true)
    list:pushBackCustomItem(parent)
    local label_playerName = CSResourceMgr.seekNodeByName(parent,"label_playerName")
    CSResourceMgr.setLabelColorByNode(label_playerName, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(label_playerName, var.otherParam.name, {r=0,g=0,b=0,a=255,w=1,s=1})
    local label_family = CSResourceMgr.seekNodeByName(parent,"label_family")
    CSResourceMgr.setLabelColorByNode(label_family, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(label_family, var.otherParam.familyName, {r=0,g=0,b=0,a=255,w=1,s=1})
    local Label_replay = CSResourceMgr.seekNodeByName(parent,"Label_replay")
    CSResourceMgr.setLabelColorByNode(Label_replay, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(Label_replay, "ArenaRecord1", {r=0,g=0,b=0,a=255,w=1,s=1})
    local Label_share = CSResourceMgr.seekNodeByName(parent,"Label_share")
    CSResourceMgr.setLabelColorByNode(Label_share, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(Label_share, "ArenaRecord7", {r=0,g=0,b=0,a=255,w=1,s=1})
    local label_result = CSResourceMgr.seekNodeByName(parent,"label_result")
    CSResourceMgr.setLabelColorByNode(label_result, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(label_result, var.isWin == 1 and "ArenaRecord2" or "ArenaRecord3", {r=0,g=0,b=0,a=255,w=1,s=1})--1是输
    local label_chageNum = CSResourceMgr.seekNodeByName(parent,"label_chageNum")
    CSResourceMgr.setLabelColorByNode(label_chageNum, var.isWin == 1 and textColor[1] or textColor[2])
    local deltaRank = var.oldRank-var.newRank
    if deltaRank<0 then
        deltaRank = -deltaRank
    end
    CSResourceMgr.setLabelStringByNode(label_chageNum, deltaRank, {r=0,g=0,b=0,a=255,w=1,s=1})
    local label_playerLv = CSResourceMgr.seekNodeByName(parent,"label_playerLv")
    CSResourceMgr.setLabelColorByNode(label_playerLv,{r=255,g=252,b=0,a=255})
    CSResourceMgr.setLabelStringByNode(label_playerLv, "Lv."..var.otherParam.level, {r=0,g=0,b=0,a=255,w=1,s=1})
    local sprite_flag = CSResourceMgr.seekNodeByName(parent,"sprite_flag")
    sprite_flag:loadTexture(var.isWin == 1 and spritePath[1] or spritePath[2])
    local sprite_arrow = CSResourceMgr.seekNodeByName(parent,"sprite_arrow")
    sprite_arrow:loadTexture(var.isWin == 1 and spritePath2[1] or spritePath2[2])
    local time = CSResourceMgr.seekNodeByName(parent,"time")
    CSResourceMgr.setLabelColorByNode(time,{r=120,g=146,b=154,a=255})
    local minutes = math.ceil((CharInfo.getServerTime()-var.t)/60)
    if minutes>=1440 then
        CSResourceMgr.setLabelStringByNode(time,CocosModuleMgr.createStringWithFormat({"ArenaRecord6", math.ceil(minutes/1440)})) --天前
    elseif minutes>=60 then
        CSResourceMgr.setLabelStringByNode(time,CocosModuleMgr.createStringWithFormat({"ArenaRecord5", math.ceil(minutes/60)})) --小时前
    else
        CSResourceMgr.setLabelStringByNode(time,CocosModuleMgr.createStringWithFormat({"ArenaRecord4", minutes})) --分钟前
    end
    if var.otherParam.fashion then
        local sprite_playerIcon = CSResourceMgr.seekNodeByName(parent, "sprite_playerIcon")
        sprite_playerIcon:loadTexture(CharInfo.getHeadIcon(var.otherParam.fashion.curFashion))
        sprite_playerIcon:setScale(1.3)
    end

    CSResourceMgr.seekNodeByName(parent, "icon_family"):loadTexture("Confraternity/icon_qizhi1_hz.png")
    CSResourceMgr.seekNodeByName(parent, "backGround_family"):setColor({r=184,g=200,b=204,a=255})
    CSResourceMgr.seekNodeByName(parent, "background_playerName"):setColor({r=184,g=200,b=204,a=255})
    CSResourceMgr.seekNodeByName(parent, "backGround_left_1"):setColor({r=154,g=180,b=188,a=255})
    CSResourceMgr.seekNodeByName(parent, "backGround_left_2"):setColor({r=180,g=199,b=204,a=255})
    CSResourceMgr.seekNodeByName(parent, "bg"):setColor(colorOne and {r=43,g=65,b=98,a=255} or {r=3,g=23,b=49,a=255})

    CSResourceMgr.seekNodeByName(parent, "family"):setVisible(false)

    local btn_replay = CSResourceMgr.seekNodeByName(parent,"btn_replay")
    CSResourceMgr.clickEventBindingByNode(btn_replay, function()
        battleResult = var.isWin
        BattleMapMgr.setBattleCallback(function()
            MapSeekerMgr.SeekFunc = function()
                ArenaViewMgr.show(SceneMgr.getRunningScene)
            end
        end)
        recordNum = 0
        recordRounds = {}
        TeamA = {}
        TeamB = {}
        NetInterface.sendWithBlock("GC_PlayArenaRecode_Ack", function()
                local ArenaSend = require("src.Net.Send.ArenaSend")
                ArenaSend.sendCG_PlayArenaRecode_Req({t=tostring(var.t)})
            end)
    end)

    local btn_share = CSResourceMgr.seekNodeByName(parent,"btn_share")
    CSResourceMgr.clickEventBindingByNode(btn_share, function()
        battleResult = var.isWin
        if not ArenaRecordMgr.isShareBattle then
            ArenaRecordMgr.isShareBattle = true
            enemyName = var.otherParam.name
            NetInterface.sendWithBlock("GC_PlayArenaRecode_Ack", function()
                    local ArenaSend = require("src.Net.Send.ArenaSend")
                    ArenaSend.sendCG_PlayArenaRecode_Req({t=tostring(var.t)})
                end,nil,function()
                    ArenaRecordMgr.isShareBattle = false
                end)
        end
    end)
end

function ArenaRecordMgr.addPetInfo2(str)
    battlePetInfo = {}
    local cjson = require("cjson")
    local var = cjson.decode(str)
    for k,v in pairs(var) do
        battlePetInfo[k] = v
    end
end

function ArenaRecordMgr.addPetInfo3(str)
    local cjson = require("cjson")
    local var = cjson.decode(str)
    for k,v in pairs(var) do
        battlePetInfo[k] = v
    end
end

function ArenaRecordMgr.addPetInfo4(str)
    local cjson = require("cjson")
    local var = cjson.decode(str)
    for k,v in pairs(var) do
        battlePetInfo[k] = v
    end
    battlePetInfo = json.encode(battlePetInfo)
    print("battlePetInfo",battlePetInfo)
    ArenaRecordMgr.setBattlePets(battlePetInfo)
end

function ArenaRecordMgr.setBattlePets(jsStr)
    local cjson = require("cjson")
    local var = cjson.decode(jsStr)
    local petA = {}
    petA[OUTPETS] = {}
    for k,v in pairs(var.enemyPets) do
        petA[OUTPETS][k+1]=v
    end
    petA[INPETS] = {}
    for k,v in pairs(var.enemyHelperPets or {}) do
        petA[INPETS][k+1]=v
    end
    TeamA = petA
    local petB = {}
    petB[OUTPETS] = {}
    for k,v in pairs(var.selfPets) do
        petB[OUTPETS][k+1]=v
    end
    petB[INPETS] = {}
    for k,v in pairs(var.selfHelperPets or {}) do
        petB[INPETS][k+1]=v
    end
    TeamB = petB
end

function ArenaRecordMgr.update(jsStr)
    local cjson = require("cjson")
    if not jsStr[1] then
        return
    end
    local var = cjson.decode(jsStr[1]) or {}
    colorOne = not colorOne
    ArenaRecordMgr.setRecord(var)
end

function ArenaRecordMgr.hide()
    -- stopRequire = true
    recordNum = 0
    recordRounds = {}
    TeamA = {}
    TeamB = {}
    battleResult = 0
    enemyName = ""
    battlePetInfo = {}
    local list = CSResourceMgr.getNodeByName(resName,"list")
    CSResourceMgr.removeListByNode(list)
    CSResourceMgr.removeCSObjectByTag(resName)
end

function ArenaRecordMgr.setRecordNum(num)
    recordNum = num
end

function ArenaRecordMgr.setRecordRounds(index,recode)
    recordNum = recordNum - 1
    local var = loadstring("return "..recode)()
    recordRounds[index+1] = var
    if recordNum == 0 and not ArenaRecordMgr.isShareBattle then
        BattleMapMgr.setRecordToBattle(TeamA,TeamB,recordRounds,battleResult) 
    elseif recordNum == 0 and ArenaRecordMgr.isShareBattle then
        if battleResult == 0 then
            battleResult = 1
        elseif battleResult == 1 then
            battleResult = 0
        end
        BattleCotroller.shareBattleRecord(TownChatMgr.shareBattleToChat,enemyName,TeamA,TeamB,battleResult,recordRounds)
    end
end

return ArenaRecordMgr