local battleTemplates = {}
function getBattleTemplateInstance(templateInfo)
    if nil ~= battleTemplates[templateInfo.name] then
        return battleTemplates[templateInfo.name]
    end
    if templateInfo.code == "" then
        --assert(false,string.format("未实现的模板:%s",templateInfo.name))
        templateInfo.code = "NormalAttack"        
		if IS_SERVER_CODE == nil then
			--require("src.Utils.GenUtils").printTable(templateInfo)
		end
    end
	local templateClass = nil
	if IS_SERVER_CODE == nil then
		templateClass = require("src.GameMgr.Battle.templates."..templateInfo.code)
	else
		printFileLog("templates."..templateInfo.code)
		templateClass = require("templates."..templateInfo.code)
	end
    if templateClass.Instance == nil then
		if IS_SERVER_CODE == nil then
			--require("src.Utils.GenUtils").printTable(templateInfo)
		end 
        battleTemplates[templateInfo.name] = templateClass.Instance
    end
    templateClass.Instance = templateClass.new(templateInfo)
    return templateClass.Instance
end