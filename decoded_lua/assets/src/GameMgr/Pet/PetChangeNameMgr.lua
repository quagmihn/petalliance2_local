local PetChangeNameMgr = {}

local resName = {}

local labelColor = {
    {r=255,g=255,b=255,a=255},
    {r=144,g=238,b=255,a=255},
}

local outlineColor = {
    {r=0,g=0,b=0,a=255},
    {r=0,g=0,b=0,a=255,w=1,s=1},
    {r=0,g=0,b=0,a=255,w=1,s=2},
}

function PetChangeNameMgr.Init()
    resName = "Pet/Education/PetChangeName.csb"
end

function PetChangeNameMgr.show(scene, objID, closeCallback)
    UIStack.push("PetChangeNameMgr", PetChangeNameMgr.hide, false)
    
    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName)
        CSResourceMgr.setRelativePosition(resName, 320, 480)

        local panel = CSResourceMgr.getNodeByName(resName, "panel")
        panel:setVisible(false)

        local btnClose = CSResourceMgr.getNodeByName(resName, "btn")
        CSResourceMgr.clickEventBindingByNode(btnClose, function ()
            PetChangeNameMgr.hide()
            if closeCallback ~= nil then closeCallback() end
        end)
    end

    local function sendChangeNameMsg(objID, newPetName, oldIsModify)
        NetInterface.sendWithBlock("GC_ChangePetName_Ack", function()
            local PetSend = require("src.Net.Send.PetSend")
            PetSend.sendCG_ChangePetName_Req({
                petObjID = objID,
                newName = tostring(newPetName)
                })
            end,
            function ()
                PetChangeNameMgr.hide()
                if closeCallback ~= nil then closeCallback() end
                PetChangeNameMgr.OnChangeNameSuccess(objID)
                local newPetInfo = PokemonInfo.getPetInfoByObjID(objID)
                local pokeInfo = PokemonInfo.getPokemonInfoByID(newPetInfo.pokeID)
                if oldIsModify == true then
                    DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 1, "train136")
                else
                    local rarePoint = pokeInfo.rarePoint
                    if rarePoint >= 4 then
                        if newPetInfo.personal.isModify == nil or newPetInfo.personal.isModify == false then
                            DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 1, "train135")
                        else
                            local strUp = ""
                            if rarePoint == 4 then
                                strUp = SystemInfo.getGlobalConfigAddInfoByID(26004).values[3]
                            elseif rarePoint == 5 then
                                strUp = SystemInfo.getGlobalConfigAddInfoByID(26005).values[3]
							elseif rarePoint == 6 then
                                strUp = SystemInfo.getGlobalConfigAddInfoByID(26006).values[3]
                            end
                            local strTips = CocosModuleMgr.createStringWithFormat({"train134", strUp})
                            DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 1, strTips)
                        end
                    else
                        DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 1, "train137")
                    end
                end
                oldIsModify = newPetInfo.personal.isModify
                PetListMgr.setUpdateFlag("changeName")
            end,
            function ()
                DialogBoxMgr.showDialogBox(SceneMgr.getRunningScene, 1, "train139")
            end)
    end

    local function loadUI()
        local labelTitle1 = CSResourceMgr.getNodeByName(resName, "title")
        local labelTitle2 = CSResourceMgr.getNodeByName(resName, "title2")
        local labelFree   = CSResourceMgr.getNodeByName(resName, "str_free")
        local labelNum    = CSResourceMgr.getNodeByName(resName, "num")
        local spriteBG    = CSResourceMgr.getNodeByName(resName, "chat_bg")
        local btnChange   = CSResourceMgr.getNodeByName(resName, "btn_change")

        local freeCnt = SystemInfo.getGlobalConfigAddInfoByID(26100).values[1]
        local costNum = SystemInfo.getGlobalConfigAddInfoByID(26101).values[1]
        local changeCnt = 0
        local petInfo = PokemonInfo.getPetInfoByObjID(objID)
        if petInfo.personal ~= nil and petInfo.personal.changeTimes ~= nil then
            changeCnt = petInfo.personal.changeTimes
        end
        if changeCnt < freeCnt then
            costNum = 0
        end

        local petName = PetEducationMgr.getPetName(petInfo)

        -- personal
        --     name
        --     isModify
        --     changeTimes

        CSResourceMgr.setLabelStringByNode(labelTitle1, "train131", outlineColor[3], nil, 500)
        CSResourceMgr.setLabelStringByNode(labelTitle2, "train132", outlineColor[2], nil, 500)
        CSResourceMgr.setLabelStringByNode(labelFree  , "train133", outlineColor[2], nil, 500)
        CSResourceMgr.setLabelStringByNode(labelNum, "x"..costNum, outlineColor[3], nil, 80)

        CSResourceMgr.setLabelColorByNode(labelTitle1, labelColor[2])
        CSResourceMgr.setLabelColorByNode(labelTitle2, labelColor[2])
        CSResourceMgr.setLabelColorByNode(labelFree,   labelColor[2])

        labelFree:setVisible(costNum == 0)

        local editbox = CocosModuleMgr.newTextEditor(spriteBG, "empty", 360, 60, 185, 30, 
            TownChatMgr.LABEL_FONT_SIZE+8, TownChatMgr.MAX_WORD_SIZE, petName)

        CSResourceMgr.clickEventBindingByNode(btnChange, function ()
            if costNum > CharInfo.getMCash() then
                DialogBoxMgr.showDialogBox(scene, 1, "advtips4")--钻石不足
            else
                local nameText = editbox:getText()
                if PetChangeNameMgr.checkNameLegal(nameText) then
                    local isModify = (petInfo.personal ~= nil and petInfo.personal.isModify ~= nil) and petInfo.personal.isModify or nil
                    sendChangeNameMsg(objID, nameText, isModify)
                end
            end
        end)
    end

    local function playAction()
        local panel = CSResourceMgr.getNodeByName(resName, "panel")
        panel:setVisible(true)
        CocosModuleMgr.showUIAnimation(panel, "down")
    end

    local funcTable = {loadCSB, loadUI, playAction}
    UnblockLoader.load(funcTable, "PetChangeNameMgr")
end

function PetChangeNameMgr.OnChangeNameSuccess(objID)
    PetEducationMgr.OnChangeNameSuccess(objID)
end

function PetChangeNameMgr.checkNameLegal(name)
    if string.len(name) < 1 then
        DialogBoxMgr.showDialogBox(scene, 1, "train158")--请输入宠物名字
        return false
    elseif string.len(name) > 18 then
        DialogBoxMgr.showDialogBox(scene, 1, "train159")--名字长度过长
        return false
    else
        SystemInfo.checkShieldString(name)
    end
    return true
end

function PetChangeNameMgr.hide()
    UnblockLoader.cancel("PetChangeNameMgr")
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("PetChangeNameMgr")
end

return PetChangeNameMgr