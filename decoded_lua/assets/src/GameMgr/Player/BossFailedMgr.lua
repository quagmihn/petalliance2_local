local BossFailedMgr = {}

local resName = ""
local enableShow = true
local bossFailedParams = nil

function BossFailedMgr.Init()
    resName = "Player/Boss/BossFailed.csb"
    enableShow = true
    bossFailedParams = nil
end

local function initStaticData(btnTxt1, btnTxt2, diamond)
    local cash = CSResourceMgr.getNodeByName(resName,"cash")
    CSResourceMgr.setLabelStringByNode(cash, CharInfo.getMCash(), {r=0,g=0,b=0,a=255,w=1})
    local win = CSResourceMgr.getNodeByName(resName,"win")
    win:loadTexture(CocosModuleMgr.getWordImage("adventureLose.png"))
    local buff = CSResourceMgr.getNodeByName(resName,"buff")
    CSResourceMgr.setLabelStringByNode(buff, "worldboss17", {r=0,g=0,b=0,a=255,w=1})
    local txt = CSResourceMgr.getNodeByName(resName,{"db", "txt"})
    CSResourceMgr.setLabelStringByNode(txt, "x"..diamond, {r=0,g=0,b=0,a=255,w=1})
    if diamond > CharInfo.getMCash() then
        CSResourceMgr.setLabelColorByNode(txt, {r=255,g=0,b=0,a=255})
    end
    CSResourceMgr.setButtonString(resName, {"db", "immediately"}, btnTxt1 or "worldboss1", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setButtonString(resName, {"db", "town"}, btnTxt2 or "worldboss2", nil, {r=0,g=0,b=0,a=255,w=1})
    
    local tip1 = CSResourceMgr.getNodeByName(resName, {"db", "bg_tip", "tip1"})
    local tip2 = CSResourceMgr.getNodeByName(resName, {"db", "bg_tip", "tip2"})
    if btnTxt1 == "worldboss1" then
        CSResourceMgr.setLabelStringByNode(tip1, "worldboss14", {r=0,g=0,b=0,a=255,w=1})
    else
        CSResourceMgr.setLabelStringByNode(tip1, "worldboss16", {r=0,g=0,b=0,a=255,w=1})
    end
    CSResourceMgr.setLabelStringByNode(tip2, "worldboss15", {r=0,g=0,b=0,a=255,w=1})
end

function BossFailedMgr.hideUI()
    enableShow = true
    bossFailedParams = nil
    CSResourceMgr.removeCSObjectByTag(resName)
    --UIStack.pop("BossFailedMgr")
end

function BossFailedMgr.enableShow(enable, resetParams)
    enableShow = enable
    if resetParams == true then
        bossFailedParams = nil
    end
end

function BossFailedMgr.getBossFailedParams()
    return bossFailedParams
end

function BossFailedMgr.show(scene, diamond, btnTxt1, btnTxt2)
    bossFailedParams = {diamond = diamond, btnTxt1 = btnTxt1, btnTxt2 = btnTxt2}
    if not enableShow then
        return
    end
    
    if CSResourceMgr.getCsbObj(resName) then
        BossFailedMgr.hideUI()
    end
    
    --UIStack.push("BossFailedMgr",BossFailedMgr.hideUI,false)
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        --CocosModuleMgr.setEdgeDistance(curLayer, nil, nil, 0, nil, false)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)
        
        CSResourceMgr.clickEventBinding(resName, "immediately", function()
            if diamond <= CharInfo.getMCash() then
                BossFailedMgr.hideUI()
                --if immeCallback then immeCallback() end
                if btnTxt1 == "worldboss1" then
                    WorldBossInfo.DiamondRecoverAll(function()
                        BossMapMgr.setPetRevived(true)
                        BossMapMgr.setPlayerOwnerBallsEmpty(false)
                        BossMapMgr.setPlayerHp(CharInfo.getCharID(), CharInfo.getLevel())
                        BossMapMgr.changePlayerCurrentState(CharInfo.getCharID(), true)
                        BossMapMgr.makePlayerOwnerPowerOverwhelming(2.0)
                        BossTopBarMgr.createCacheCards(PetEducationMgr.getPetWithOutYoke(PokemonInfo.getAllPets()))
                        BossBattleMgr.clearRestraint()
                    end)
                else
                    WorldBossInfo.DiamondRecoverPet(function()
                        --BossMapMgr.setPlayerHp(CharInfo.getCharID(), CharInfo.getLevel())
                        --BossMapMgr.changePlayerCurrentState(CharInfo.getCharID(), true)
                        BossMapMgr.setPetRevived(true)
                        BossMapMgr.setPlayerOwnerBallsEmpty(false)
                        BossTopBarMgr.createCacheCards(PetEducationMgr.getPetWithOutYoke(PokemonInfo.getAllPets()))
                    end)
                end
            else
                StandardTipsMgr.show(1,"tips14")
            end
        end)
        
        CSResourceMgr.clickEventBinding(resName, "town", function()
            BossFailedMgr.hideUI()
            --if townCallback then townCallback() end
            BossTopBarMgr.hideUI()
        end)
        
        initStaticData(btnTxt1, btnTxt2, diamond)
    end
    
    local function playCSB()
        local node = CSResourceMgr.getNodeByName(resName, "db")
        if node ~= nil then
            node:setVisible(true)
            CocosModuleMgr.showUIAnimation(node, "down")
        end
    end
    
    loadCSB()
    playCSB()
end

return BossFailedMgr