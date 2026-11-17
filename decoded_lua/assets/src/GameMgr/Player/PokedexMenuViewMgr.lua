local PokedexMenuViewMgr = {}

local resName = ""
local namePath = {}
local btnNameTable = {}

function PokedexMenuViewMgr.hide()
    UnblockLoader.cancel("PokedexMenuViewMgr")
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("PokedexMenuViewMgr")
end

function PokedexMenuViewMgr.Init()
    print("PokedexMenuViewMgr初始化")

    resName      = "Charactor/PokedexMenu.csb"
    namePath     = {"pokedex_cal_paradex_01.png", "pokedex_cal_skillinfo_01.png", "pokedex_cal_parapedia_01.png"}
    btnNameTable = {"pokedex_pet", "pokedex_skill", "pokedex_view"}
end

function PokedexMenuViewMgr.show(scene)
    UIStack.push("PokedexMenuViewMgr", PokedexMenuViewMgr.hide, false)
    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName)
        CSResourceMgr.setRelativePosition(resName, 320, 480)

        local panel = CSResourceMgr.getNodeByName(resName, "panel")
        panel:setVisible(false)

        local btnClose = CSResourceMgr.getNodeByName(resName, "btn_bg")
        CSResourceMgr.clickEventBindingByNode(btnClose, function ()
            PokedexMenuViewMgr.hide()
        end)
    end

    local function loadUI()
        local btnTable = {}
        local nameTable = {}
        local panel = CSResourceMgr.getNodeByName(resName, "panel")
        for i = 1, #btnNameTable do
            btnTable[i] = CSResourceMgr.seekNodeByName(panel, tostring(btnNameTable[i]))
            nameTable[i] = CSResourceMgr.seekNodeByName(btnTable[i], "name")
            CSResourceMgr.setSpriteTextureByNode(nameTable[i], CocosModuleMgr.getWordImage(namePath[i]))
        end

        CSResourceMgr.clickEventBindingByNode(btnTable[1], function ()
            PetHandBook.show(scene)
        end, 1)

        CSResourceMgr.clickEventBindingByNode(btnTable[2], function ()
            SkillBookViewMgr.show(scene)
        end, 1)

        CSResourceMgr.clickEventBindingByNode(btnTable[3], function ()
            BattleManualMgr.show(scene)
        end, 1)
    end

    local function playAction()
        local panel = CSResourceMgr.getNodeByName(resName, "panel")
        panel:setVisible(true)
        CocosModuleMgr.showUIAnimation(panel, "down")
    end
    
    local funcTable = {loadCSB, loadUI, playAction}
    UnblockLoader.load(funcTable, "PokedexMenuViewMgr")
end

return PokedexMenuViewMgr