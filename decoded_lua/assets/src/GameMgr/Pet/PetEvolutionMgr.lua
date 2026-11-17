local PetEvolutionMgr = {}

function PetEvolutionMgr.Init()
    print("PetEvolutionMgr初始化")
end

function PetEvolutionMgr.evolutionInTown(id)
    PokemonInfo.setFollowPokemon(id)
    local petRes = PokemonInfo.getPokemonResByID(id)
    TownMapMgr.setCharactorPet(id)
    TownMapMgr.Pet:setOpacity(0)
    transition.fadeIn(TownMapMgr.Pet, {time = 0.5})
    local ani1 = AnimationMgr.createAni(TownMapMgr.Pet, "Spine/effects/evolution.png", 0, 0, petRes)
    local ani2 = AnimationMgr.createAni(TownMapMgr.Pet, "Spine/effects/evolution_down.png", 0, 0, petRes.."1")
    local ani3 = AnimationMgr.createAni(TownMapMgr.Pet, "Spine/effects/evolution_down.png", 0, 0, petRes.."2")
    ani1:setScale(2)
    ani2:setScale(2)
    ani3:setScale(2)
    AnimationMgr.playAniWithCallback(ani1.res, "animation1", function()
        transition.fadeOut(ani1, {time = 1})
        ani1:performWithDelay(function()
            AnimationMgr.removeGafObjectByTag(ani1.res, ani1.tag)
        end, 1)
    end, ani1.tag)
    AnimationMgr.playAniWithCallback(ani2.res, "animation1", function()
        transition.fadeOut(ani2, {time = 1})
        ani2:performWithDelay(function()
            AnimationMgr.removeGafObjectByTag(ani2.res, ani2.tag)
        end, 1)
    end, ani2.tag)
    AnimationMgr.playAniWithCallback(ani3.res, "animation2", function()
        transition.fadeOut(ani3, {time = 1})
        ani3:performWithDelay(function()
            AnimationMgr.removeGafObjectByTag(ani3.res, ani3.tag)
        end, 1)
    end, ani3.tag)
end

return PetEvolutionMgr