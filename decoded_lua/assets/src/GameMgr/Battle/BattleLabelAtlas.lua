local BattleLabelAtlas = {}
local CCSUILoader = require("src.framework.cc.uiloader.CCSUILoader")

BattleLabelAtlas.BATTLELABEL = {}
BattleLabelAtlas.BMFONT      = {}

-- LABELATLAS_TIMES_LIMIT  = 15
-- LABELATLAS_NUMS_LIMIT   = 9
BMFONT_SIZE             = 1.1  

BMFONT_ZORDER           = 6

BattleLabelAtlas.BATTLELABEL["red"]         = {"Battle/Atlas_red.png", 22, 27, "."}
BattleLabelAtlas.BATTLELABEL["fightNor"]    = {"UI/Atlas/fight_yellow.png",40,50,"/"}
BattleLabelAtlas.BATTLELABEL["fightCri"]    = {"UI/Atlas/fight_yellow.png",40,50,"/"}
BattleLabelAtlas.BATTLELABEL["fightAdd"]    = {"UI/Atlas/fightAdd.png",40,50,"/"}
BattleLabelAtlas.BATTLELABEL["timeNum"]     = {"UI/Atlas/timeNum.png", 45, 55, "/"}
BattleLabelAtlas.BATTLELABEL["roundNum"]    = {"UI/Atlas/roundNum.png", 50, 58, "/"}
BattleLabelAtlas.BATTLELABEL["exp"]         = {"UI/Atlas/exp.png", 30, 54, "/"}
BattleLabelAtlas.BATTLELABEL["exp_green"]   = {"UI/Atlas/exp_green.png", 30, 54, "/"}
																						
-- [2][3] "#"坐标调整  [4]"#"大小 [5]其他字的大小
BattleLabelAtlas.BMFONT["normal"]    = {"Battle/battleLabel/battle_number_crit.fnt",20,14,2.5,1.2,
                                        "Battle/battleLabel/battle_number_crit_0.png"}
BattleLabelAtlas.BMFONT["strong"]    = {"Battle/battleLabel/battle_number_restraint.fnt",13,10,1.0,1.2,
										"Battle/battleLabel/battle_number_restraint_0.png"}
BattleLabelAtlas.BMFONT["weak"]    	 = {"Battle/battleLabel/battle_number_restrainted.fnt",13,-15,1.0,1.2,
										"Battle/battleLabel/battle_number_restrainted_0.png"}
BattleLabelAtlas.BMFONT["add"]       = {"Battle/battleLabel/battle_number_return.fnt",0,0,1.0,1.2,
										"Battle/battleLabel/battle_number_return_0.png"}
BattleLabelAtlas.BMFONT["free"]      = {"Battle/battleLabel/battle_number_return.fnt",0,0,1.0,1.2,
										"Battle/battleLabel/battle_number_return_0.png"}

return BattleLabelAtlas