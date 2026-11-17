local PetEvolutionEffectMgr = {}

local resName = ""
PetEvolutionEffectMgr.objID = nil
PetEvolutionEffectMgr.pokeID = nil
PetEvolutionEffectMgr.oldPetInfo = nil

function PetEvolutionEffectMgr.Init()
    print("PetEvolutionEffectMgr初始化")
    resName = "Pet/Education/evolution/evo_effect.csb"

    PetEvolutionEffectMgr.objID = nil
    PetEvolutionEffectMgr.pokeID = nil
    PetEvolutionEffectMgr.oldPetInfo = nil
end

function PetEvolutionEffectMgr.hide()
    UnblockLoader.cancel("PetEvolutionEffectMgr")

    local pInfo = PokemonInfo.getPetInfoByObjID(PetEvolutionEffectMgr.oldPetInfo.objID)
    if PetEducationMgr.perFC < pInfo.fc then
        PetFCEffectMgr.show(SceneMgr.getRunningScene, PetEducationMgr.perFC, pInfo.fc)
    end
    PetEducationMgr.showPetEvolutionChangeSkillUI(PetEvolutionEffectMgr.oldPetInfo, PetEducationMgr.addSkills, 1)

    PetEvolutionEffectMgr.objID = nil
    PetEvolutionEffectMgr.pokeID = nil
    PetEvolutionEffectMgr.oldPetInfo = nil

    CSResourceMgr.removeCSObjectByTag(resName)
end

function PetEvolutionEffectMgr.show(oldPokeID, newPokeID, oldSkin, newSkin, oldPetInfo)
    PetEvolutionEffectMgr.oldPetInfo = oldPetInfo
    
    local layer
    local function loadCSB()
        layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
    end

    local function playCSB()
        local aniRes = PokemonInfo.getPokemonResByID(oldPokeID)
        local ani = AnimationMgr.createAni(layer, aniRes, 320, 440, "evo_effect"..oldPokeID)
        AnimationMgr.playAni(aniRes, "idle", true, "evo_effect"..oldPokeID)
        ani:setScale(0.9)
        AnimationMgr.setSkin(aniRes, oldSkin, "evo_effect"..oldPokeID)

        local bar = CSResourceMgr.getNodeByName(resName, "k")
        -- bar:setVisible(true)

        local label = CSResourceMgr.seekNodeByName(layer, "desc")
        local name1 = LuaSqlite.getLanguageByKey(PokemonInfo.getPokemonInfoByID(oldPokeID).name)
        CSResourceMgr.setLabelStringByNode(label, name1.."train166")
        -- CSResourceMgr.setLabelColorByNode(label, {r=0,g=0,b=0,a=255})

        layer:performWithDelay(function()
            AnimationMgr.removeGafObjectByTag(aniRes, "evo_effect"..oldPokeID)
            -- bar:setVisible(false)
        end, 4.8)--宠物消失时间

        layer:performWithDelay(function()
            aniRes = PokemonInfo.getPokemonResByID(newPokeID)
            ani = AnimationMgr.createAni(layer, aniRes, 320, 440, "evo_effect"..newPokeID)
            AnimationMgr.playAni(aniRes, "idle", true, "evo_effect"..newPokeID)
            AnimationMgr.setSkin(aniRes, newSkin, "evo_effect"..newPokeID)

            -- bar:setVisible(true)
            local name2 = LuaSqlite.getLanguageByKey(PokemonInfo.getPokemonInfoByID(newPokeID).name)
            print("name2  : ", name2)
            CSResourceMgr.setLabelStringByNode(label, name1.."进化成了"..name2, {r=0,g=0,b=0,a=255,w=1,s=2})--to do
        end, 4.8)--进化后宠物显示时间
        
        layer:performWithDelay(function()
            ani:setOpacity(90)
            local scaleto_1_2 = cc.ScaleTo:create(0.1, 1.4)
            local scaleto_1_0 = cc.ScaleTo:create(0.1, 1.0)
            local action = cc.Sequence:create(scaleto_1_2, scaleto_1_0)
            local repeatforever = cc.RepeatForever:create(action)
            ani:runAction(repeatforever)
            
            local particle = CSResourceMgr.createParticle(layer, "Spine/effects/NewParticle_1.plist", 320, 480)
            local effect   = AnimationMgr.createAni(layer, "Gaf/effect/evo_effect.gaf", 240, 1250)
            particle:setScale(0.5)
            effect:setScale(0.7)
            AnimationMgr.playAni("Gaf/effect/evo_effect.gaf", "do", false)
            AnimationMgr.playAniWithCallback("Gaf/effect/evo_effect.gaf", "do", function()
                layer:performWithDelay(function()
                    AnimationMgr.removeGafObjectByTag(aniRes,"evo_effect"..newPokeID)
                    PetEvolutionEffectMgr.hide()
                    PetEvolutionEffectMgr.goToAppStore(newPokeID)
                end,2.0)
            end, "", true)
        end,0.5)

        local btnBG = CSResourceMgr.seekNodeByName(layer, "bg")
        CSResourceMgr.clickEventBindingByNode(btnBG, function ()
            transition.stopTarget(layer)
            AnimationMgr.removeGafObjectByTag(aniRes, "evo_effect"..oldPokeID)
            AnimationMgr.removeGafObjectByTag(aniRes, "evo_effect"..newPokeID)
            AnimationMgr.removeGafObjectByTag("Gaf/effect/evo_effect.gaf")
            PetEvolutionEffectMgr.hide()
            PetEvolutionEffectMgr.goToAppStore(newPokeID)
        end)
    end    

    local funcTable = {loadCSB, playCSB}
    UnblockLoader.load(funcTable, "PetEvolutionEffectMgr")
end

function PetEvolutionEffectMgr.goToAppStore(pokeID)
    -- if device.platform == "ios" and PetEducationMgr.checkPetEvolutionS(pokeID) then
    --     iOSFunction.goToAppStore()
    -- end
    if PetEducationMgr.iosSendPetEvolution == false then
        local haveQuest = false
        for k,v in pairs(QuestInfo.getCurQuestInfos()) do
            if k == 10070 then
                haveQuest = true
                break
            end
        end
        if haveQuest == true and QuestInfo.checkQuestFinished(10070) == false and (device.platform == "ios" or device.platform == "windows") then
            PetEducationMgr.iosSendPetEvolution = true
            DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, "tips58", function ()
                iOSFunction.goToAppStore()
            end)
        end
    end
end

return PetEvolutionEffectMgr