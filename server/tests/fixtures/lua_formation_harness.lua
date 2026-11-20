local root = "decoded_lua/assets/src/GameMgr/"
local originalRequire = require
local parsed, friendly, save, request = {}, nil, nil, nil
require = function(name)
    if name == "cjson" then
        return {decode=function(value) return assert(parsed[value]) end}
    elseif name == "src.Net.Send.PetSend" then
        return {sendCG_UpdatePetArmys_Req=function(params) request=params.petArmys[1] end}
    elseif name == "src.GameMgr.Battle.BattleGetPetInfo" then
        return {new=function(group) friendly=group; return {{}} end}
    elseif name == "src.GameMgr.Battle.BattleCotroller" then
        return {init=function() end}
    elseif name == "src.GameMgr.Battle.BattleFuncMgr" then
        return {}
    end
    return originalRequire(name)
end

function clone(value)
    local copy = {}
    for k,v in pairs(value) do copy[k] = v end
    return copy
end

local starter = {objID=21, pokeID=1}
local old = {objID=22, pokeID=26}
local panda = {objID=37, pokeID=45}
local helper = {objID=38, pokeID=7}
parsed = {starter=starter, old=old, panda=panda, helper=helper}
local working = {{starter, panda}}
PetFormationMgr = {TEAM_NUM=1, getCurTab=function() return 1 end,
    getTabIsInit=function() return {true} end,
    getSelPet=function() return working end, getHelpPet=function() return {{}} end}
TaskWatcherManager = {saveChangeArmyTeam=function() end}
local redraws = 0
StatusBarMgr = {refreshFightPower=function() redraws=redraws+1 end}
NetInterface = {sendWithBlock=function(_, send, success) send(); save=success end}
PokemonInfo = assert(loadfile(root.."Data/PokemonInfo.lua"))()
PokemonInfo.refreshSciencePower = function() end
PokemonInfo.setFollowPokemon = function() end
PokemonInfo.set({activePets={"starter","old"}, unactivePets={"panda"}, activeHelperPets={"helper"}})
local editor = assert(loadfile(root.."Pet/PetListMgr.lua"))()
editor.savePetTeam(true)
assert(request.armyMembers[2] == 37 and #request.helpArmyMembers == 0)
assert(PokemonInfo.getActivePets()[2] == old, "changed active team before ACK")
working[1][2] = old
save()
assert(redraws == 1)
assert(PokemonInfo.getPetArmy(1)[2] == 37)
assert(PokemonInfo.getActivePets()[2] == panda)
assert(PokemonInfo.getUnactivePets()[22] == old and PokemonInfo.getUnactivePets()[38] == helper)
assert(PokemonInfo.getUnactivePets()[37] == nil and #PokemonInfo.getActiveHelperPets() == 0)
assert(not PokemonInfo.applyPrimaryArmy({21,37}, {37}))
assert(not PokemonInfo.applyPrimaryArmy({21,9999}, {}))
assert(PokemonInfo.getActivePets()[2] == panda and redraws == 1)

SceneMgr = {previousScene="MainScene"}
sz_T2S = tostring
BattlePVPMgr = {mIsPVPBattle=false}
AchievementListMgr = {getAttackSkillIDs=function() return {} end}
AvatarViewMgr = {getFashionSkills=function() return {} end}
BattleMgr = {new=function() return {} end}
BattleUIMgr = {Init=function() end, addUI=function() end}
TEAM_A = 1
local battle = assert(loadfile(root.."Map/BattleMapMgr.lua"))()
battle.getWeather = function() return nil end
battle.setEnemyPets({[0]={{objID=1}}})
battle.createBattleScene({})
assert(friendly[0][2].objID == 37 and friendly[0][2].pokeID == 45)
battle.setMyPets({})
assert(PokemonInfo.applyPrimaryArmy({21,22}, {}))
battle.createBattleScene({})
assert(friendly[0][2].objID == 22 and friendly[0][2].pokeID == 26)

local scriptPet = {objID=1, pokeID=33}
battle.setMyPets({[0]={scriptPet}, [1]={}})
battle.createBattleScene({})
assert(friendly[0][1] == scriptPet)

local adventure = assert(loadfile(root.."Searching/AdvPetsMgr.lua"))()
adventure.Init()
assert(PokemonInfo.applyPrimaryArmy({21,22,37}, {38}))
adventure.setCurrTeam(1)
assert(adventure.advArmy[3] == 37 and adventure.advHelpArmy[1] == 38)
assert(PokemonInfo.applyPrimaryArmy({21,37}, {}))
assert(adventure.advArmy[2] == 22, "changed an in-progress expedition snapshot")
adventure.setCurrTeam(1)
assert(adventure.advArmy[2] == 37 and adventure.advArmy[3] == nil and #adventure.advHelpArmy == 0)
print("LUA_FORMATION_OK")
