import shutil
import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


@unittest.skipUnless(shutil.which("lua"), "Lua interpreter is not installed")
class GachaGuideRecoveryTests(unittest.TestCase):
    def test_rejection_cancels_result_wait_without_completing_guide(self):
        script = r'''
local buttons, loaders = {}, {}
local pending, locked = false, false
local function noop() end
local node = {
    performWithDelay=function(_, callback) callback() end,
}
SceneMgr = {currentScene="MainScene", getRunningScene=node}
QuestInfo = {
    getCurGuideIDs=function() return {10010} end,
    getNewQuestInfoById=function() return {name="guide"} end,
    sendQuestFinished=function() error("rejected draw completed the quest") end,
}
CharInfo = {get=function() return {} end, getLevel=function() return 1 end}
GameLogMgr = {dataTypeEnum={}, UserGameState={}, OnGameStateChange=noop}
CheckViewMgr = {hide=noop}
NoticeViewMgr = {hide=noop}
SystemOptionsMgr = {getOption=function() return true end}
NpcDialogueMgr = {show=function(_, callback) callback() end}
GachaViewMgr = {getLastTime=function() return 1, 0 end}
CSResourceMgr = {
    getNodeByName=function(_, key)
        if key == "getItem_Copy" then
            error("a rejected draw opened a result")
        end
        return key
    end,
    seekNodeByName=function(_, key) return key end,
}
CocosModuleMgr = {
    setScreenTouch=function(enabled) locked = not enabled end,
    setButtonGuide=function(button, _, callback) buttons[button] = callback end,
    showUnlockAnimation=function(_, callback) callback() end,
}
UnblockLoader = {
    addCallback=function(tag, callback) loaders[tag] = callback end,
    cancel=function(tag) loaders[tag] = nil end,
}
NetInterface = {
    sendWithBlock=function(_, _, success) success() end,
    hasPending=function() return pending end,
}
local dir = "decoded_lua/assets/src/GameMgr/Common/"
GameGuideMgr = dofile(dir.."GameGuideMgr.lua")
dofile(dir.."GameGuideMgr1.lua")
GameGuideMgr.checkScene = function(_, callback) callback() end

local function reachDraw()
    GameGuideMgr.checkProcess()
    buttons.Button_nd()
    loaders.GachaViewMgr()
    buttons.Button_Enter2()
    loaders.GachaViewMgrA()
    assert(GameGuideMgr.checkIsGuiding())
    assert(not locked)
end

reachDraw()
pending = true
buttons.Button_Go()
assert(loaders.GachaViewMgrB and not locked)
GameGuideMgr.cancelGachaResultWait()
assert(not loaders.GachaViewMgrB and not locked and not GameGuideMgr.checkIsGuiding())
GameGuideMgr.checkProcess()
assert(not GameGuideMgr.checkIsGuiding(), "same guide restarted immediately")

-- Cold session and client-side rejection before any network request.
GameGuideMgr = dofile(dir.."GameGuideMgr.lua")
dofile(dir.."GameGuideMgr1.lua")
GameGuideMgr.checkScene = function(_, callback) callback() end
pending = false
reachDraw()
buttons.Button_Go()
assert(not loaders.GachaViewMgrB and not locked and not GameGuideMgr.checkIsGuiding())
'''
        result = subprocess.run(
            [shutil.which("lua"), "-e", script],
            cwd=ROOT, text=True, capture_output=True, check=False,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
