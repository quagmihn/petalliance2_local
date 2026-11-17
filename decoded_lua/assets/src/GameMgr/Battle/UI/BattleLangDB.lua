local BattleLangDB = {}

BattleLangDB["fight"]   = LuaSqlite.getLanguageByKey("battleword9")    --出战
BattleLangDB["help"]   	= LuaSqlite.getLanguageByKey("battleword10")   --支援
BattleLangDB["findPet"]     = LuaSqlite.getLanguageByKey("battleword11")   --发现野生精灵
BattleLangDB["findPetSe"]   = LuaSqlite.getLanguageByKey("battleword12")   --发现稀有精灵
BattleLangDB["restTimes"]   = LuaSqlite.getLanguageByKey("battleword13")   --剩余次数
BattleLangDB["own"]   		= LuaSqlite.getLanguageByKey("battleword14")   --已拥有
BattleLangDB["fighting"]   	= LuaSqlite.getLanguageByKey("battleword15")   --出战中
BattleLangDB["rate"]   	    = LuaSqlite.getLanguageByKey("battleword16")   --几率
BattleLangDB["wait"]   	    = LuaSqlite.getLanguageByKey("battleword18")        --等待中
BattleLangDB["cancel"]   	= LuaSqlite.getLanguageByKey("battleword19")        --取消
BattleLangDB["autoClose"]  	= LuaSqlite.getLanguageByKey("battleword20")        --自动战斗关闭
BattleLangDB["autoOpen"]   	= LuaSqlite.getLanguageByKey("battleword21")        --自动战斗开启
BattleLangDB["noManu"]   	= LuaSqlite.getLanguageByKey("battleword22")        --当前不能手动战斗
BattleLangDB["replay"]      = LuaSqlite.getLanguageByKey("arena59")        --回放
BattleLangDB["quit"]   	    = LuaSqlite.getLanguageByKey("arena60")        --退出




return BattleLangDB