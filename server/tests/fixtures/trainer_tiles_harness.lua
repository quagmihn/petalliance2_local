local trainers = dofile("decoded_lua/assets/src/GameMgr/Searching/AdvCharMgr.lua")
local blocked = {}
local function index(col, row)
    if col >= 1 and col <= 6 and row >= 1 and row <= 3 then
        return (row - 1) * 6 + col
    end
end
local function coords(tile)
    return (tile - 1) % 6 + 1, math.floor((tile - 1) / 6) + 1
end
LtMapOption = {
    getMapType = function() return "ADVENTURE" end,
    convertToIndex = index, convertToCoord = coords,
    isReachable = function(col, row)
        local tile = index(col, row)
        return tile ~= nil and not blocked[tile]
    end,
}
LtEventOption = {EVENT_VOID = 0, EVENT_TRAINER = 8, EVENT_OTHERTRAINER = 16}
local trainerTile = index(2, 2)
local first = index(3, 2)
local second = index(4, 2)
local clicked
local stepped, battles = {}, {}
local state = {}
local node = {performWithDelay = function(_, callback) callback() end}
local trainer = {info = {pos = trainerTile, floor = 1, vision = 2,
                        direction = {c = 1, r = 0}, node = node}}
SearchingMapMgr = {currFloor = 1, sceneID = {floor1 = {[trainerTile] = 96}},
                   floorTargetBlocks = {floor1 = {}}}
SearchingMgr = {
    playerCurrPosition = first, canMove = true,
    mapInfoTable = {[trainerTile] = 0, [first] = 0},
    eventInfoTable = {[trainerTile] = LtEventOption.EVENT_TRAINER, [first] = LtEventOption.EVENT_VOID},
    eventStateInfoTable = state,
    itemTypeTable = {[trainerTile] = {id = 3, groupCode = "trainer", pokemons = {11}}},
    checkPlayer = function(tile)
        local x, y = coords(tile)
        local px, py = coords(SearchingMgr.playerCurrPosition)
        return math.abs(x - px) + math.abs(y - py) == 1
    end,
    enterBattleAt = function(tile, info) battles[#battles + 1] = {tile, info[2].sceneID} end,
    unlock4TrainerMovedOrFailed = function() end,
    Lock_monsterAt = function() end,
}
SearchingUIMgr = {TurnToBlock = function() end}
SceneMgr = {getRunningScene = node}
LuaSqlite = {getLanguageByKey = function(value) return value end}
Proto = {BTT_ADVENTURE_MONSTER_MAN_GROUP = 3}
CSResourceMgr = {clickEventBindingByNode = function(_, callback) clicked = callback end}
trainers.turnTo = function() end
trainers.cancelWatching = function() end
trainers.Attack = function() end
trainers.Idle = function() end
trainers.setEmoji = function() end
trainers.activateAllTrainer = function() end
trainers.stepToBlock = function(char, tile)
    local pos = char.info.pos
    stepped[#stepped + 1] = tile
    SearchingMgr.eventInfoTable[tile] = SearchingMgr.eventInfoTable[pos]
    SearchingMgr.itemTypeTable[tile] = SearchingMgr.itemTypeTable[pos]
    SearchingMapMgr.sceneID.floor1[tile] = SearchingMapMgr.sceneID.floor1[pos]
    char.info.pos = tile
    return true
end
trainers.addTrainer(trainer)
state[trainerTile] = 1
assert(not trainers.check(trainer))                               -- merely adjacent
assert(not trainers.check(trainer, index(5, 2)))                  -- outside vision
assert(not trainers.check(trainer, index(2, 3)))                  -- beside/outside vision
assert(trainers.approachTile(trainer, second) == first)
blocked[first] = true
assert(not trainers.check(trainer, second))                       -- blocked path
blocked[first] = nil
SearchingMgr.eventInfoTable[first] = LtEventOption.EVENT_TRAINER
assert(not trainers.check(trainer, second))                       -- occupied tile
SearchingMgr.eventInfoTable[first] = LtEventOption.EVENT_VOID
state[trainerTile] = 3
assert(not trainers.check(trainer, second))                       -- defeated
trainers.battle_(trainer)
assert(#battles == 0 and not SearchingMgr.onbattle)
state[trainerTile] = 1
SearchingMgr.playerCurrPosition = index(2, 3)
trainers.clickEvent(trainer)
clicked()
assert(#battles == 1 and #stepped == 0 and battles[1][2] == 96)     -- adjacent tap
trainers.recoverRejectedBattle(trainerTile)
assert(SearchingMgr.canMove and not SearchingMgr.onbattle and state[trainerTile] == 1)
assert(not trainers.check(trainer))                               -- reject doesn't retrigger
SearchingMgr.playerCurrPosition = second
assert(trainers.check(trainer))
trainers.battle_(trainer)
assert(#stepped == 1 and stepped[1] == first and #battles == 2 and battles[2][2] == 96)
