local PetStarupResetViewMgr = {}

local resName = ""


function PetStarupResetViewMgr.Init()
    resName = "Pet/Education/PetStarupReset.csb"
end

function PetStarupResetViewMgr.hide()
    UnblockLoader.cancel("PetStarupResetViewMgr")
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("PetStarupResetViewMgr")
end

function PetStarupResetViewMgr.show(scene, objID, closeCallback)
    UIStack.push("PetStarupResetViewMgr", PetStarupResetViewMgr.hide, false)
    
    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName)
        CSResourceMgr.setRelativePosition(resName, 320, 480)

        local panel = CSResourceMgr.getNodeByName(resName, "panel")
        panel:setVisible(false)

        local btnClose = CSResourceMgr.getNodeByName(resName, "btn_close")
        CSResourceMgr.clickEventBindingByNode(btnClose, function ()
            PetStarupResetViewMgr.hide()
        end)
    end

    local function loadUI()
        local labelTitle    = CSResourceMgr.getNodeByName(resName, "title")
        local btnCancel     = CSResourceMgr.getNodeByName(resName, "btn_cancel")
        local btnSure       = CSResourceMgr.getNodeByName(resName, "btn_sure")
        local strCancel     = CSResourceMgr.getNodeByName(resName, "str_cancel")
        local strSure       = CSResourceMgr.getNodeByName(resName, "str_sure")
        local parent        = CSResourceMgr.getNodeByName(resName, "background_5")

        local petInfo = PokemonInfo.getPetInfoByObjID(objID)
        local diamondCost = PokemonInfo.getPetResetStarInfoById(petInfo.star).consume
        local str = CocosModuleMgr.createStringWithFormat({"train208", diamondCost})

        CSResourceMgr.setLabelStringByNode(labelTitle, str, nil, nil, 422)
        CSResourceMgr.setLabelStringByNode(strCancel, "tips4", nil, nil, 105)
        CSResourceMgr.setLabelStringByNode(strSure, "tips3", nil, nil, 105)

        CSResourceMgr.setLabelColorByNode(labelTitle, {r=217,g=234,b=255,a=255})
        CSResourceMgr.setLabelColorByNode(strCancel, {r=217,g=234,b=255,a=255})
        CSResourceMgr.setLabelColorByNode(strSure, {r=217,g=234,b=255,a=255})

        local petStarupInfo = PokemonInfo.getPetStarUpInfoByID(petInfo.pokeID)
        local needPetID     = petStarupInfo.costPet[1]
        local needPetCount  = 0
        for i = 1, petInfo.star do
            needPetCount = needPetCount + petStarupInfo.num2[i]
        end
        local petInfo2 = PokemonInfo.getPokemonInfoByID(needPetID)
        local pieceID = petInfo2.gainParam
        local pieceInfo = ItemInfo.getPetPieceInfoById(pieceID)
        local needPetPieceCnt = math.floor(needPetCount * pieceInfo.num * 0.6)

        local needResID = petStarupInfo.costItem[1]
        local needResCnt = 0
        for i = 1, petInfo.star do
            needResCnt = needResCnt + petStarupInfo.num1[i]
        end
        needResCnt = math.floor(needResCnt * 0.6)
        local itemTable = {needResID, pieceID}
        local showTable = {}
        table.insert(showTable,{needResID, needResCnt})
        table.insert(showTable,{pieceID, needPetPieceCnt})

        for k,v in pairs(parent:getChildren()) do
            parent:removeChild(v)
        end
        for i = 1, 2 do
            local getCnt = i == 1 and needResCnt or needPetPieceCnt
            local itemNode = ItemInfo.getItemIconById(itemTable[i], getCnt)
            itemNode:addTo(parent)
            itemNode:setPosition((i - 1.5) * 130 + 223, 50)
            itemNode:setScale(0.8)
            CSResourceMgr.clickEventBindingByNode(itemNode, function ()
                ItemInfoViewMgr.show({id = itemTable[i]}, false)
            end)
        end

        CSResourceMgr.clickEventBindingByNode(btnCancel, function ()
            PetStarupResetViewMgr.hide()
        end)

        CSResourceMgr.clickEventBindingByNode(btnSure, function ()
            NetInterface.sendWithBlock("GC_RESETPETSTAR_ACK", function()
            local PetEducationSend = require("src/Net/Send/PetEducationSend.lua")
            PetEducationSend.sendCG_ResetPetStar_Req({
                objID = petInfo.objID,
                })
            end,function ()
                PetEducationMgr.showPet(petInfo.objID)
                PetStarupResetViewMgr.hide()
                AwardsListMgr.show(scene, showTable)
                PetListMgr.setUpdateFlag("rare")
                if closeCallback then closeCallback() end
            end,function ()
                -- print("faild in star up!")
            end)
        end)
    end

    local function playAction()
        local panel = CSResourceMgr.getNodeByName(resName, "panel")
        panel:setVisible(true)
        CocosModuleMgr.showUIAnimation(panel, "down")
    end

    local funcTable = {loadCSB, loadUI, playAction}
    UnblockLoader.load(funcTable, "PetStarupResetViewMgr")
end

return PetStarupResetViewMgr