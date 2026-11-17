local PetMenuMgr = {}

PetMenuMgr.RANK_NUM = 2

local resName = ""
local resNameBG = ""

local petMenuStr = {}
local petMenuIcon = {}
local petMenuColor = {}
local petMenuBtn = {}

function PetMenuMgr.Init()
    print("PetMenuMgr初始化")
    
    resName = "Pet/Menu/PetMenu.csb"
    resNameBG = "Pet/Formation/FormationBG.csb"
    
    for var=1, 10 do
    	petMenuStr[var] = "petmenu"..var
        petMenuIcon[var] = 
        {
                able = string.format("Pet/Menu/qh_bz%04d.png", var),
                disable = string.format("Pet/Menu/qh_bz%04d.png", var),
        }
    end
    petMenuColor = {able = {r=102,g=51,b=0,a=255}, disable = {r=0,g=51,b=102,a=255}}
    petMenuBtn = {able = "Pet/Menu/qh_anniu0001.png", disable = "Pet/Menu/qh_anniu0002.png"}
end

function PetMenuMgr.show(scene)
    if CSResourceMgr.getCsbObj(resName) then
        PetMenuMgr.hide()
    	return
    end
    
    local function loadCSB()
        local curLayerBG = CSResourceMgr.createRes(scene, resNameBG, "PetMenuMgr")
        curLayerBG:setLocalZOrder(CocosModuleMgr.ZORDER_BOARD)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "PetMenuMgr")
        curLayerBG:setOpacity(0)
        transition.fadeIn(curLayerBG, {time=1})
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        
        CSResourceMgr.clickEventBinding(resName, "close", function()
        	PetMenuMgr.hide()
        end)

        local list = CSResourceMgr.getNodeByName(resName, "list")
        list:removeAllItems()
        local panelTable = {}
        for i=1, #petMenuStr do
            local row = math.ceil(i/PetMenuMgr.RANK_NUM)
            local rank = i%PetMenuMgr.RANK_NUM
            if rank==0 then
                rank = PetMenuMgr.RANK_NUM
            end
            if rank==1 then
                local panel = CSResourceMgr.getNodeByName(resName, "panel"):clone()
                table.insert(panelTable, panel)
                list:pushBackCustomItem(panel)
                list:performWithDelay(function()
                    list:jumpToTop()
                end, 0.1)
            end
            local function itemFunc()
                local parent = panelTable[row]
                local label = CSResourceMgr.seekNodeByName(parent, "t"..rank)
                CSResourceMgr.setLabelStringByNode(label, petMenuStr[i])
                label:enableOutline(petMenuColor.able, 6)
                local sprite = CSResourceMgr.seekNodeByName(parent, "s"..rank)
                CSResourceMgr.setSpriteTextureByNode(sprite, petMenuIcon[i].able)
                local diban = CSResourceMgr.seekNodeByName(parent, "b"..rank)
                CSResourceMgr.buttonEventBindingByNode(diban, function(sender)
                    label:enableOutline(petMenuColor.disable, 6)
                    CSResourceMgr.setSpriteTextureByNode(sprite, petMenuIcon[i].disable)
                    CSResourceMgr.setButtonTextureByNode(sender, petMenuBtn.disable, petMenuBtn.disable, petMenuBtn.disable)
                end, function(sender)
                    label:enableOutline(petMenuColor.able, 6)
                    CSResourceMgr.setSpriteTextureByNode(sprite, petMenuIcon[i].able)
                    CSResourceMgr.setButtonTextureByNode(sender, petMenuBtn.able, petMenuBtn.disable, petMenuBtn.disable)
                    TipsMgr.show(scene, petMenuStr[i].."被点击")
                    PetMenuMgr.hide()
                    if i==1 then
                        PetFormationMgr.show(scene, function()
                            PetMenuMgr.show(SceneMgr.getRunningScene)
                        end)
                    elseif i==2 then
                        PetStrengthenMgr.show(scene, function()
                            PetMenuMgr.show(SceneMgr.getRunningScene)
                        end)
                    elseif i==3 then
                        PetListMgr.show(SceneMgr.getRunningScene,function(sender)
                            PetEducationMgr.show(SceneMgr.getRunningScene, sender.objID, 1, function()
                                PetListMgr.refresh(PokemonInfo.getPetInfoByObjID(sender.objID))
                            end)
                        end,nil,
                        function()
                            PetMenuMgr.show(SceneMgr.getRunningScene)
                        end)
                    elseif i==4 then
                        NetInterface.sendWithBlock("GC_GetPetArmys_Ack", function()
                            local PetSend = require("src.Net.Send.PetSend")
                            PetSend.sendCG_GetPetArmys_Req()
                        end, function()
                            print("其他数据请求完毕")
                        end)
                    end
                end, nil, function(sender)
                    label:enableOutline(petMenuColor.able, 6)
                    CSResourceMgr.setSpriteTextureByNode(sprite, petMenuIcon[i].able)
                    CSResourceMgr.setButtonTextureByNode(sender, petMenuBtn.able, petMenuBtn.disable, petMenuBtn.disable)
                end)
                diban:setVisible(true)
            end
            itemFunc()
        end
        
        --[[
        local panel = CSResourceMgr.getNodeByName(resName, "panel"):clone()
        list:pushBackCustomItem(panel)
        list:performWithDelay(function()
            list:jumpToTop()
        end, 0.1)]]
    end

    local function playCSB()
        CSResourceMgr.playAction(resName, 0, 5, false)
    end

    local funcTable = {loadCSB, playCSB}

    UnblockLoader.load(funcTable, "PetMenuMgr")
end

function PetMenuMgr.hide()
    CSResourceMgr.playActionWithCallback(resName, 50, 55, 1, function()
        CSResourceMgr.getNodeByName(resName, "list"):removeAllItems()
        UnblockLoader.cancel("PetMenuMgr")
        CSResourceMgr.removeCSObjectByTag(resName)
        CSResourceMgr.removeCSObjectByTag(resNameBG, "PetMenuMgr")
    end)
end

return PetMenuMgr