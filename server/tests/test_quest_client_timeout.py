import shutil
import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
QUEST_INFO = ROOT / "decoded_lua/assets/src/GameMgr/Data/QuestInfo.lua"
NET_INTERFACE = ROOT / "decoded_lua/assets/src/GameMgr/Support/NetInterface.lua"


@unittest.skipUnless(shutil.which("lua"), "Lua interpreter is not installed")
class QuestClientTimeoutTests(unittest.TestCase):
    def test_continuous_finish_flag_releases_on_error_and_timeout(self):
        script = r'''
Proto = {QUEST_STATUS_NORMAL=0, QUEST_STATUS_DONE=1}
TipsMgr = {showError=function() end}
local touch = {}
CocosModuleMgr = {setScreenTouch=function(value) touch[#touch+1]=value end}
local callbacks
NetInterface = {sendWithBlock=function(name, send, success, failure, wait, resend, timeout)
  callbacks = {success=success, failure=failure, timeout=timeout}
end}
package.preload["src.Net.Send.NewQuestSend"] = function()
  return {sendCZ_CommitQuest_Req=function() end}
end
local questInfo = assert(loadfile(arg[0]))()
questInfo.getNewQuestInfoById = function()
  return {objectiveList={{eventType=0}}}
end
local data = {questID=7, status=0, progressList={1}}
local upvalues = {}
for i=1, 16 do
  local name, value = debug.getupvalue(questInfo.sendQuestFinished, i)
  if not name then break end
  upvalues[name] = {index=i, value=value}
end
assert(upvalues.curQuestDatas)
local quests = {[7]=data}
debug.setupvalue(questInfo.sendQuestFinished, upvalues.curQuestDatas.index, quests)
assert(questInfo.sendQuestFinished(7, true))
local flag
for i=1, 16 do
  local name, value = debug.getupvalue(questInfo.sendQuestFinished, i)
  if name == "isContinuousFinishing" then flag=value end
end
assert(flag == true)
callbacks.failure(123)
for i=1, 16 do
  local name, value = debug.getupvalue(questInfo.sendQuestFinished, i)
  if name == "isContinuousFinishing" then flag=value end
end
assert(flag == false and quests[7].status == 0)
assert(touch[#touch] == true)
assert(questInfo.sendQuestFinished(7, true))
callbacks.timeout()
for i=1, 16 do
  local name, value = debug.getupvalue(questInfo.sendQuestFinished, i)
  if name == "isContinuousFinishing" then flag=value end
end
assert(flag == false and quests[7].status == 0)
assert(touch[#touch] == true)
'''
        result = subprocess.run([shutil.which("lua"), "-e", script, str(QUEST_INFO)],
                                cwd=ROOT, text=True, capture_output=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_timeout_callback_survives_blocking_request_reconnect_resend(self):
        script = r'''
Proto = {Command={GC_TEST_ACK=1}, CommandL={}}
DebugInfoMgr = {}
LoginMsgMgr = {IsInLoginProgress=true}
SceneMgr = {currentScene="TownScene"}
TeamInfo = {checkTeamStatus=function() end, checkTeamMapStatus=function() end}
WorldBossInfo = {checkBossMapStatus=function() end}
LoadingView = {show=function() end, hide=function() end}
local overtime = {}
OvertimeListener = {
  start=function(startFn, tag, text, timeoutFn, wait)
    overtime[#overtime+1] = {tag=tag, timeout=timeoutFn, wait=wait}
    startFn()
  end,
  cancel=function() end
}
package.preload["src.Net.CallbackMgr"] = function()
  return {registCallFunc=function() end}
end
package.preload["src.Net.NetMgr"] = function()
  return {disconnect=function() end}
end
local net = assert(loadfile(arg[0]))()
local fired = 0
net.sendWithBlock("GC_TEST_ACK", function() end, nil, nil, 12, true,
                  function() fired=fired+1 end)
assert(overtime[1].wait == 12)
net.resend()
assert(#overtime == 2 and overtime[2].wait == 12)
overtime[2].timeout()
assert(fired == 1)
'''
        result = subprocess.run([shutil.which("lua"), "-e", script, str(NET_INTERFACE)],
                                cwd=ROOT, text=True, capture_output=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
