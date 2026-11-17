local PetEatPetViewMgr = {}

local resName = ""
local selectMainPetInfo = nil
local selectEatPetInfo = nil
local aniPokeID = nil
local selPetNode = nil

function PetEatPetViewMgr.Init()
    print("PetEatPetViewMgr初始化")
    resName = "Pet/Education/EatPetView.csb"
    selectMainPetInfo = nil
    selectEatPetInfo = nil
    aniPokeID = nil
    selPetNode = nil
    local mapSkillInfoReader = TxtReader.new("Config/MapSkill.txt")
    mapskillInfo = mapSkillInfoReader.init({"id","HandBookID","desc","langID"},1)
end

function PetEatPetViewMgr.hide()
    UnblockLoader.cancel("PetEatPetViewMgr")

    if aniPokeID and selectMainPetInfo then
        local aniRes = PokemonInfo.getPokemonResByID(aniPokeID)
        AnimationMgr.removeGafObjectByTag(aniRes, "eat_pet_"..aniPokeID)
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end

    selectMainPetInfo = nil
    selectEatPetInfo = nil
    aniPokeID = nil
    selPetNode = nil
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("PetEatPetViewMgr")
end

function PetEatPetViewMgr.show(scene)
    UIStack.push("PetEatPetViewMgr", PetEatPetViewMgr.hide, false)

    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName)
        CSResourceMgr.setRelativePosition(resName, 320, 480)

        local panel = CSResourceMgr.getNodeByName(resName, "panel")
        panel:setVisible(false)
    end

    local function loadUI()
        local labelTitle    = CSResourceMgr.getNodeByName(resName, "title")
        local labelMainPet  = CSResourceMgr.getNodeByName(resName, "str_main_title")
        local labelEatPet   = CSResourceMgr.getNodeByName(resName, "str_sel_title")
        local labelInfo     = CSResourceMgr.getNodeByName(resName, "str_cost_title")
        CSResourceMgr.setLabelStringByNode(labelTitle, "train201", {r=0,g=0,b=0,a=255,w=1,s=3})
        CSResourceMgr.setLabelStringByNode(labelMainPet, "train202", {r=0,g=0,b=0,a=255,w=1,s=2}, 100)
        CSResourceMgr.setLabelStringByNode(labelEatPet, "train203", {r=0,g=0,b=0,a=255,w=1,s=2}, 100)
        CSResourceMgr.setLabelStringByNode(labelInfo, "train204", {r=0,g=0,b=0,a=255,w=1,s=2}, nil, 316)

        CSResourceMgr.setLabelColorByNode(labelTitle,   {r=166,g=243,b=255,a=255})
        CSResourceMgr.setLabelColorByNode(labelMainPet, {r=84 ,g=177,b=235,a=255})
        CSResourceMgr.setLabelColorByNode(labelEatPet,  {r=84 ,g=177,b=235,a=255})
        CSResourceMgr.setLabelColorByNode(labelInfo,    {r=48 ,g=214,b=248,a=255})

        local btnCancel = CSResourceMgr.getNodeByName(resName, "btn_cancel")
        local strCancel = CSResourceMgr.getNodeByName(resName, "str_cancel")
        CSResourceMgr.setLabelStringByNode(strCancel, "train23", {r=0,g=0,b=0,a=255,w=1,s=2}, nil, 144)
        CSResourceMgr.setLabelColorByNode(strCancel, {r=227,g=233,b=255,a=255})
        CSResourceMgr.clickEventBindingByNode(btnCancel, function ()
            PetEatPetViewMgr.hide()
        end)

        local btnSure= CSResourceMgr.getNodeByName(resName, "btn_sure")
        local strSure = CSResourceMgr.getNodeByName(resName, "str_sure")
        CSResourceMgr.setLabelStringByNode(strSure, "train62", {r=0,g=0,b=0,a=255,w=1,s=2}, nil, 144)
        CSResourceMgr.setLabelColorByNode(strSure, {r=227,g=233,b=255,a=255})
        CSResourceMgr.clickEventBindingByNode(btnSure, function ()
            if selectMainPetInfo and selectEatPetInfo then
                local skillIDs = {}
                for k,v in pairs(mapskillInfo) do
                    table.insert(skillIDs, tonumber(v.HandBookID))
                end

                local function sendEatPetReq()
                    if selectMainPetInfo.objID and selectEatPetInfo.objID then
                        NetInterface.sendWithBlock("GC_EatPet_Ack", function()
                            local PetEducationSend = require("src/Net/Send/PetEducationSend.lua")
                            PetEducationSend.sendCG_EatPet_Req({
                                petObjID = selectMainPetInfo.objID,
                                eatPetObjID = selectEatPetInfo.objID,
                            })
                        end, function()
                            selectEatPetInfo = nil
                            PetEatPetViewMgr.refreshSelPet()
                            local parent = CSResourceMgr.getNodeByName(resName,"pet_ani")
                            local effAni = AnimationMgr.createAni(parent, "Spine/effects/Ui_chongwushengji.png", 
                                    parent:getContentSize().width/2, parent:getContentSize().height/2, "eatPet")
                            effAni:setPosition(effAni:getPositionX()+20, effAni:getPositionY()-100)
                            AnimationMgr.playAni(effAni.res, "animation", false, "eatPet")
                        end, function ()
                            StandardTipsMgr.show(1, CocosModuleMgr.createStringWithFormat({"train205", code}))
                        end)
                    end
                end

                local function checkPetSkill()
                    for i=1,#selectMainPetInfo.skills do
                        local skillId = selectMainPetInfo.skills[i]
                        local id = math.floor(skillId * 0.1)
                        for i = 1, #skillIDs do
                            if id == skillIDs[i] then
                                return true
                            end
                        end
                    end
                    return false
                end
                if checkPetSkill() == true then
                    DialogBoxMgr.showDialogBox(scene, 2, "train209", function ()
                        sendEatPetReq()
                    end)
                else
                    sendEatPetReq()
                end
            elseif not selectMainPetInfo then
                DialogBoxMgr.showDialogBox(scene, 1, "train206")
            elseif not selectEatPetInfo then
                DialogBoxMgr.showDialogBox(scene, 1, "train207")
            end
        end)
    end

    local function playAction()
        local panel = CSResourceMgr.getNodeByName(resName, "panel")
        panel:setVisible(true)
        CocosModuleMgr.showUIAnimation(panel, "down")
    end

    local funcTable = {loadCSB, loadUI, PetEatPetViewMgr.refreshMainPet, PetEatPetViewMgr.refreshSelPet, playAction}
    UnblockLoader.load(funcTable, "PetEatPetViewMgr")
end

function PetEatPetViewMgr.getPetAttrStr(petInfo)
    local pokeInfo = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
    local str = "petBook"..pokeInfo.skins[petInfo.skin].attribType
    return str
end

function PetEatPetViewMgr.refreshMainPet()
    local selectedPet   = selectMainPetInfo ~= nil
    local btnMainPet    = CSResourceMgr.getNodeByName(resName, "btn_main_pet")
    local btnMainPetAdd = CSResourceMgr.getNodeByName(resName, "btn_main_add")
    local labelPetAttr  = CSResourceMgr.getNodeByName(resName, "str_main_info")
    local petAniNode    = CSResourceMgr.getNodeByName(resName, "pet_ani")

    btnMainPetAdd:setVisible(not selectedPet)
    labelPetAttr:setVisible(selectedPet)

    if (aniPokeID and selectMainPetInfo and aniPokeID ~= selectMainPetInfo.pokeID) or (aniPokeID and selectMainPetInfo == nil) then
        local aniRes = PokemonInfo.getPokemonResByID(aniPokeID)
        AnimationMgr.removeGafObjectByTag(aniRes, "eat_pet_"..aniPokeID)
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end

    if selectedPet == true then
        local pokeID = selectMainPetInfo.pokeID
        local aniRes = PokemonInfo.getPokemonResByID(pokeID)
        local aniAni = AnimationMgr.createAni(petAniNode, aniRes, 0, 0, "eat_pet_"..pokeID)
        AnimationMgr.playAni(aniRes, "idle", true, "eat_pet_"..pokeID)
        AnimationMgr.setSkin(aniRes, selectMainPetInfo.skin, "eat_pet_"..pokeID)
        aniAni:setScale(0.8)

        local petHeight = BattleCANI.petbody.get(pokeID).headUD
        aniAni:setPositionY(petHeight < 150 and -40 or -100)
        aniPokeID = pokeID

        if selectMainPetInfo.skin ~= 0 then
            local skinAttr = PetEatPetViewMgr.getPetAttrStr(selectMainPetInfo)
            CSResourceMgr.setLabelStringByNode(labelPetAttr, skinAttr, {r=0,g=0,b=0,a=255,w=1,s=2}, nil, 150)
            CSResourceMgr.setLabelColorByNode(labelPetAttr, {r=252,g=143,b=71,a=255})
        else
            CSResourceMgr.setLabelStringByNode(labelPetAttr, "", {r=0,g=0,b=0,a=255,w=1,s=2}, nil, 150)
        end
    else
        aniPokeID = nil
    end

    local function setMainPetBtn(node)
        CSResourceMgr.clickEventBindingByNode(node, function ()
            PetCommonListViewMgr.showEatPetList(SceneMgr.getRunningScene, nil, selectMainPetInfo, 1, function ()
                PetEatPetViewMgr.refreshMainPet()
                if selectMainPetInfo and selectEatPetInfo then
                    selectEatPetInfo = nil
                    PetEatPetViewMgr.refreshSelPet()
                    PetEatPetViewMgr.setLabelCost()
                end
            end)
        end)
    end
    setMainPetBtn(btnMainPet)
    setMainPetBtn(btnMainPetAdd)
end

function PetEatPetViewMgr.refreshSelPet()
    local labelPetAttr = CSResourceMgr.getNodeByName(resName, "str_sel_info")
    local btnSelPet    = CSResourceMgr.getNodeByName(resName, "btn_sel_pet")
    local btnSelPetAdd = CSResourceMgr.getNodeByName(resName, "btn_sel_add")
    local selNode      = CSResourceMgr.getNodeByName(resName, "node_sel")

    labelPetAttr:setVisible(selectEatPetInfo ~= nil)

    if selectEatPetInfo and selectEatPetInfo.skin ~= 0 then
        local skinAttr = PetEatPetViewMgr.getPetAttrStr(selectEatPetInfo)
        CSResourceMgr.setLabelStringByNode(labelPetAttr, skinAttr, {r=0,g=0,b=0,a=255,w=1,s=2}, nil, 150)
        CSResourceMgr.setLabelColorByNode(labelPetAttr, {r=252,g=143,b=71,a=255})
    else
        CSResourceMgr.setLabelStringByNode(labelPetAttr, "", {r=0,g=0,b=0,a=255,w=1,s=2}, nil, 150)
    end

    local function setSelPetBtn(node)
        CSResourceMgr.clickEventBindingByNode(node, function ()
            if selectMainPetInfo == nil then
                DialogBoxMgr.showDialogBox(scene, 1, "train206")
            else
                PetCommonListViewMgr.showEatPetList(SceneMgr.getRunningScene, selectMainPetInfo, selectEatPetInfo, 2, function ()
                    PetEatPetViewMgr.refreshSelPet()
                    PetEatPetViewMgr.setLabelCost()
                end)
            end
        end)
    end

    if selectEatPetInfo ~= nil then
        selPetNode = BattleFuncMgr.startCreatePetCard(selectEatPetInfo, 3, true).button
        selPetNode:setVisible(true)
        selPetNode:setScale(1.3, 1.3)
        selPetNode:addTo(selNode)
        selPetNode:setPosition(0, -8)

        setSelPetBtn(selPetNode)
        BattleFuncMgr.endCreatePetCard()
    else
        if selPetNode then
            selPetNode:setVisible(false)
            selPetNode = nil
        end
        for k,v in pairs(selNode:getChildren()) do
            selNode:removeChild(v)
        end
    end
    setSelPetBtn(btnSelPet)
    setSelPetBtn(btnSelPetAdd)
    PetEatPetViewMgr.setLabelCost()
end

function PetEatPetViewMgr.setLabelCost()
    local cost = not selectMainPetInfo and 0 or PokemonInfo.getPokemonInfoByID(selectMainPetInfo.pokeID).eatCost
    local labelCost = CSResourceMgr.getNodeByName(resName, "str_cost")
    CSResourceMgr.setLabelStringByNode(labelCost, cost, {r=0,g=0,b=0,a=255,w=1,s=2})
    labelCost:setVisible(selectEatPetInfo ~= nil)
end

function PetEatPetViewMgr.setSelectMainPetInfo(petInfo)
    if selectMainPetInfo and selectMainPetInfo.objID == petInfo.objID then
        selectMainPetInfo = nil
    else
        selectMainPetInfo = petInfo
    end
end

function PetEatPetViewMgr.setSelectEatPetInfo(petInfo)
    if selectEatPetInfo and selectEatPetInfo.objID == petInfo.objID then
        selectEatPetInfo = nil
    else
        selectEatPetInfo = petInfo
    end
end

function PetEatPetViewMgr.onEatPetSuccess()
    selectMainPetInfo = PokemonInfo.getPetInfoByObjID(selectMainPetInfo.objID)
    PetEatPetViewMgr.refreshMainPet()
end

return PetEatPetViewMgr