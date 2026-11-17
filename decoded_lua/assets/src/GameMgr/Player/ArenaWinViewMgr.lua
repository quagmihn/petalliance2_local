local ArenaWinViewMgr = {}

local resName = ""
local resNameBG = ""
local resLight = ""
local recordNum = 0
local recordRounds = {}
local battleResult = 0
local TeamA = {}
local TeamB = {}

function ArenaWinViewMgr.Init()
    print("ArenaWinViewMgr初始化")
    
    resName = "Player/Arena/ArenaWinView.csb"
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    resLight = "Spine/effects/Ui_zhandoujiesuanguangxiao.png"
    recordNum = 0
    recordRounds = {}
    battleResult = 0
    TeamA = {}
    TeamB = {}
end

function ArenaWinViewMgr.hide()
    UnblockLoader.cancel("ArenaWinViewMgr")
    AnimationMgr.removeGafObjectByTag(resLight)
    CSResourceMgr.removeCSObjectByTag(resName)
    CSResourceMgr.removeCSObjectByTag(resNameBG, "ArenaWinViewMgr")
    UIStack.pop("ArenaWinViewMgr")
end

local function setLabel(label,string,outline,outlinewidth,textColor,maxwidth)
    CSResourceMgr.setLabelColorByNode(label,textColor)
    CSResourceMgr.setLabelStringByNode(label,string,outline)
    if outlinewidth~=nil  then
        label:enableOutline(outline, outlinewidth)
    end

    if maxwidth~=nil then
        CSResourceMgr.setLabelMaxWidthByNode(label,maxwidth)
    end
end

function ArenaWinViewMgr.show(scene, oldRank, newRank, awardNum)
    UIStack.push("ArenaWinViewMgr", ArenaWinViewMgr.hide, true)
	local function loadCSB()
        local curLayerBG = CSResourceMgr.createRes(scene, resNameBG, "ArenaWinViewMgr")
        curLayerBG:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW+1)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "ArenaWinViewMgr")

        local layer = CSResourceMgr.createRes(scene, resName)
        CSResourceMgr.setFullScreen(resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW+1)

        local win = CocosModuleMgr.getWordImage("adventureWin.png")
        CSResourceMgr.getNodeByName(resName, "winString"):loadTexture(win)

        local btnRep = CSResourceMgr.getNodeByName(resName, "btn_rep")
        local btnExit = CSResourceMgr.getNodeByName(resName, "btn_exit")
        local diff = CocosModuleMgr.getScreenSizeDiff()
        ViewMgrUtils.vFitSetPos(-diff, {btnRep, btnExit})
    end

    local function loadUI()
        local light = CSResourceMgr.getNodeByName(resName, "light")
        local rankUP = CSResourceMgr.getNodeByName(resName, "rank_up")
        local rankNum = CSResourceMgr.getNodeByName(resName, "rank_num")
        -- local rankAdd = CSResourceMgr.getNodeByName(resName, "rank_add")
        local rankInfo = CSResourceMgr.getNodeByName(resName, "rank_info")

        local rankNumUp = CocosModuleMgr.getWordImage("paimingtisheng.png")
        CSResourceMgr.getNodeByName(resName, "rank_up"):loadTexture(rankNumUp)

        local info = CocosModuleMgr.createStringWithFormat({"arena58", awardNum})
        local richLabel = CocosModuleMgr.createRichLabel(rankInfo, info, 26, "cuyuan_GBK.ttf", 580)

        CSResourceMgr.setLabelStringByNode(rankNum, newRank, {r=0,g=33,b=154,a=255,w=4}, nil, 104)
        -- CSResourceMgr.setLabelStringByNode(rankAdd, "+"..(oldRank-newRank), {r=0,g=0,b=0,a=255,s=1}, nil, 104)

        CSResourceMgr.setLabelColorByNode(rankNum, {r=0,g=255,b=252,a=255})
        -- CSResourceMgr.setLabelColorByNode(rankAdd, {r=138,g=255,b=0,a=255})
        -- rankAdd:setPositionX(rankNum:getPositionX() + rankNum:getContentSize().width)

        -- if not AnimationMgr.getGafObj(resLight) then
        --     AnimationMgr.createAni(light, resLight, 0, 0)
        --     AnimationMgr.playAni(resLight, "animation", true)
        -- end
        ArenaEffectMgr.playBattleWinSpine(light)

        local bgbg = CSResourceMgr.getNodeByName(resName, "title_db")
        bgbg:setVisible(false)
    end

    local function loadBtn()
        local btnRep = CSResourceMgr.getNodeByName(resName, "btn_rep")
        local btnExit = CSResourceMgr.getNodeByName(resName, "btn_exit")
        local strRep = CSResourceMgr.seekNodeByName(btnRep, "str_rep")
        local strExit = CSResourceMgr.seekNodeByName(btnExit, "str_exit")

        CSResourceMgr.setLabelStringByNode(strRep, "arena59", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 180)
        CSResourceMgr.setLabelStringByNode(strExit, "arena60", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 180)

        CSResourceMgr.clickEventBindingByNode(btnRep, function ()
            NetInterface.sendWithBlock("GC_GetArenaRecode_Ack", function()
                local ArenaSend = require("src.Net.Send.ArenaSend")
                ArenaSend.sendCG_GetArenaRecode_Req({startIndex = 0,endIndex = 1})
            end,function()
                
            end)
        end)

        CSResourceMgr.clickEventBindingByNode(btnExit, function ()
            ArenaWinViewMgr.hide()
        end)
    end

    local function playAction()
        local bg1 = CSResourceMgr.getNodeByName(resName, "bg1")
        local rate = 0.05
        local winString = CSResourceMgr.getNodeByName(resName, "winString")
        winString:setVisible(true)
        winString:setScale(2.4)
        winString:performWithDelay(function()
            local scale1 = cc.ScaleTo:create(3*rate,0.8)
            local scale2 = cc.ScaleTo:create(2*rate,1.2)
            local scale3 = cc.ScaleTo:create(2*rate,1.0)
            winString:runAction(cc.Sequence:create(scale1,scale2,scale3))
            ArenaWinViewMgr.playEffect(bg1)
            -- ArenaWinViewMgr.playEffect2(bg1)
        end, 0.01)
    end

    local funcTable = {loadCSB, loadUI, loadBtn}
    UnblockLoader.load(funcTable,"ArenaWinViewMgr")
end

function ArenaWinViewMgr.update(jsStr)
    local cjson = require("cjson")
    if not jsStr[1] then
        return
    end
    print(jsStr[1])
    local var = cjson.decode(jsStr[1]) or {}
    ArenaWinViewMgr.setRecord(var)
end

function ArenaWinViewMgr.setRecord(var)
    battleResult = var.isWin
    BattleMapMgr.setBattleCallback(function()
        MapSeekerMgr.SeekFunc = function()
            ArenaViewMgr.show(SceneMgr.getRunningScene)
        end
    end)
    NetInterface.sendWithBlock("GC_PlayArenaRecode_Ack", function()
        local ArenaSend = require("src.Net.Send.ArenaSend")
        ArenaSend.sendCG_PlayArenaRecode_Req({t=tostring(var.t)})
    end)
end

function ArenaWinViewMgr.setRecordNum(num)
    recordNum = num
end

function ArenaWinViewMgr.setBattlePets(jsStr)
    local cjson = require("cjson")
    local var = cjson.decode(jsStr)
    local petA = {}
    petA[OUTPETS] = {}
    for k,v in pairs(var.enemyPets) do
        print("111 : ", v)
        petA[OUTPETS][k+1]=v
    end
    petA[INPETS] = {}
    for k,v in pairs(var.enemyHelperPets or {}) do
        print("222 : ", v)
        petA[INPETS][k+1]=v
    end
    TeamA = petA
    local petB = {}
    petB[OUTPETS] = {}
    for k,v in pairs(var.selfPets) do
        print("333 : ", v)
        petB[OUTPETS][k+1]=v
    end
    petB[INPETS] = {}
    for k,v in pairs(var.selfHelperPets or {}) do
        print("444 : ", v)
        petB[INPETS][k+1]=v
    end
    TeamB = petB
end

function ArenaWinViewMgr.setRecordRounds(index, recode)
    recordNum = recordNum - 1
    local var = loadstring("return "..recode)()
    recordRounds[index+1] = var
    if recordNum == 0 then
        print("Team : ", TeamA, TeamB, recordRounds, battleResult)
        BattleMapMgr.setRecordToBattle(TeamA, TeamB, recordRounds, battleResult) 
    end
end

function ArenaWinViewMgr.playEffect(parent)--升阶
    local effAni = AnimationMgr.createAni(parent, "Spine/arena/UI_JJCshengjie.png", 
            parent:getContentSize().width/2, parent:getContentSize().height/2, "arena_shengjie")
    AnimationMgr.playAni(effAni.res, "animation", false, "arena_shengjie")
    AnimationMgr.playAniWithCallback(effAni.res, "Spine/arena/UI_JJCshengjie.png", function()
        transition.fadeOut(effAni, {time = 1})
    end, "arena_shengjie", true)
end

function ArenaWinViewMgr.playEffect2(parent)--降阶
    local effAni = AnimationMgr.createAni(parent, "Spine/arena/UI_JJCjj.png", 
            parent:getContentSize().width/2, parent:getContentSize().height/2, "arena_jj")
    AnimationMgr.playAni(effAni.res, "animation", false, "UI_JJCjj")
    AnimationMgr.playAniWithCallback(effAni.res, "Spine/arena/UI_JJCshengjie.png", function()
        transition.fadeOut(effAni, {time = 1})
    end, "arena_jj", true)
end

return ArenaWinViewMgr