local captured, left, ack, sentResult
local committed = 0
local node = {performWithDelay=function(_, func) func() end}
GameGuideMgr = {checkScene=function(_, callback) callback() end,
                finishProcess=function() committed=committed+1 end}
BattleCCSB = {stopQuitBattle=function() end, stopAutoBattle=function() end}
BattleUIMgr = {}
BattleGuide = {funcs={}}
GUIDE_FIRST, GUIDE_SECOND, GUIDE_THIRD, GUIDE_FINISH = 1, 2, 3, 4
PLAYER_WIN = 1
CSResourceMgr = {getNodeByName=function() end}
CocosModuleMgr = {setScreenTouch=function() end, setButtonGuide=function(_, _, callback) callback() end}
WorldMapMgr = {setMapMoveFinishFunc=function(func) left=func end,
               getMapPointNode=function() return node end,
               locateToPoint=function() end, addEvent=function() end}
EmbeddedMapMgr = {addEvent=function(params) assert(params.param==2003); captured=params.battleCallback; return node end}
BattleMapMgr = {sendGameOver=function(result, pets, onCommitted)
    assert(pets.objID[1]==31)
    sentResult, ack = result, onCommitted
end}
assert(loadfile("decoded_lua/assets/src/GameMgr/Common/GameGuideMgr2.lua"))()

local function encounter(result)
    GameGuideMgr.firstBuff()
    left()
    local exit = assert(BattleGuide.funcs[GUIDE_FINISH])
    captured({result=result,me={objID={31},hp={23}}})
    assert(sentResult==result)
    return exit
end

local exit=encounter(PLAYER_WIN)
exit()
assert(committed==0, "guide committed before the battle ACK")
ack()
assert(committed==1)

exit=encounter(PLAYER_WIN)
ack()
assert(committed==1, "guide committed before leaving the summary")
exit()
assert(committed==2)

exit=encounter(0)
ack()
exit()
assert(committed==2, "confirmed loss advanced the guide")
print("LUA_GUIDE_BATTLE_COMMIT_OK")
