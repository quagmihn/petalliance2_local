local Data = {}

function Data.init()

	require("Data.GenInfo").init()
	require("Data.PackInfo").init()
	require("Data.CreditCardInfo").init()
	require("Data.PetInfo").init()
	require("Data.BattleInfo").init()
	require("Data.QuestInfo").init()
	require("Data.StoryInfo").init()
	require("Data.ItemInfo").init()
	require("Data.MailInfo").init()
	require("Data.SystemInfo").init()
	require("Data.StoreInfo").init()
	
end

return Data