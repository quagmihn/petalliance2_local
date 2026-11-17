local LocalPushMgr = {}
local Eca = require("Eca.Eca")

LocalPushMgr.BattleEnergyFull = 1
LocalPushMgr.LocalPushCount = LocalPushMgr.BattleEnergyFull + 1

function LocalPushMgr.init()

	Eca.addListener(ECA.OnCreditCardRefresh, LocalPushMgr.OnCreditCardRefresh)

end

function LocalPushMgr.setLocalPush(type, elapse)

	if (LocalPushMgr.BattleEnergyFull == type) then
		LocalPush:unregisterLocalPush(LocalPushMgr.BattleEnergyFull)
		LocalPush:registerLocalPush(elapse, LocalPushMgr.BattleEnergyFull, "Notice", "行动力已满")
	end

end

function LocalPushMgr.OnCreditCardRefresh(id)

	if (Proto.CREDIT_ID_BATTLE_ENERGY == id) then
		local recoverTime = require("Data.CreditCardInfo").getCardRecoverTime(Proto.CREDIT_ID_BATTLE_ENERGY)
		local curTime = require("Utils.HDTime").getCurTime()
		LocalPushMgr.setLocalPush(LocalPushMgr.BattleEnergyFull, recoverTime - curTime)
	end

end

return LocalPushMgr