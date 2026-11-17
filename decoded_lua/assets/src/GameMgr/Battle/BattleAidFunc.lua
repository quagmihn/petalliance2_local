local BattleAidFunc = {}

function BattleAidFunc.str2Enum(str)

	local ret, enum = pcall(loadstring("return Proto." .. str))
    if (true ~= ret) then
        printError("Can not find enum of " .. str)
    end
    return enum

end

function BattleAidFunc.str2Percent(str)

	local percent = tonumber(string.sub(str, 1, #str - 1)) / 100
    if (nil == percent) then
        printError("Can not convert " .. str .. " to percent")
    end
    return percent

end

function BattleAidFunc.normalize(val)

    if (nil == val) then
        printError("Can not normalize value of nil !")
    end
    return math.floor(math.max(1, val))

end

function BattleAidFunc.getAttributeStateValue(skillID,petID)
    local skillAttrit = PokemonInfo.getPetSkillInfoById(skillID).skillAtt
    local petAttriFirst = PokemonInfo.getPokemonInfoByID(petID).elementAtt1
    local petAttriSce = PokemonInfo.getPokemonInfoByID(petID).elementAtt2
    return  ELEMENT_GRAMS[skillAttrit][petAttriFirst] * ELEMENT_GRAMS[skillAttrit][petAttriSce]
end

function BattleAidFunc.getSkillDesc(data, templateLevel, templateReplace, templateValue)

    local attName = {
        ["AT_HP"] = "AT_HP", --"血量",
        ["AT_ATK"] = "AT_ATK", --"物攻",
        ["AT_DEF"] = "AT_DEF", --"物防",
        ["AT_SATK"] = "AT_SATK", --"魔攻",
        ["AT_SDEF"] = "AT_SDEF", --"魔防",
        ["AT_SPEED"] = "AT_SPEED", --"速度",
        ["AT_CRT"] = "AT_CRT", --"暴击率",
        ["AT_EVD"] = "AT_EVD", --"闪避率",
        ["AT_CRTHURT"] = "AT_CRTHURT", --"暴击伤害",
        ["AT_RAGE"] = "AT_RAGE", --"怒气",
        ["AT_ENERGY"] = "AT_ENERGY", --"能量",
        ["AT_RATE"] = "AT_RATE", --"命中",
        ["AT_HEALRATE"] = "AT_HEALRATE", --"治疗修正",
        ["AT_ANTICRT"] = "AT_ANTICRT", --"暴击抵抗",
        ["AT_DAMAGEREDUCE"] = "AT_DAMAGEREDUCE", --"减伤",
        ["AT_PENETRATION"] = "AT_PENETRATION", --"物理穿透"
        ["AT_SPENETRATION"] = "AT_SPENETRATION", --"魔法穿透"

        ["AWT_HOT"] = "AWT_HOT", --"炎热",
        ["AWT_RAIN"] = "AWT_RAIN", --"下雨",
        ["AWT_WIND"] = "AWT_WIND", --"刮风",
        ["AWT_HOLE"] = "AWT_HOLE", --"地穴",
        ["AWT_TUNDER"] = "AWT_TUNDER", --"打雷",
        ["AWT_SWAMP"] = "AWT_SWAMP", --"沼泽",
        ["AWT_SUN"] = "AWT_SUN", --"晴天",

        ["eST_Normal"] = "eST_Normal", --"主动技能",
        ["eST_Passive"] = "eST_Passive", --"被动技能",
        ["eST_Profound"] = "eST_Profound", --"奥义技能",
        ["eST_Assist"] = "eST_Assist", --"援助技能",
    }

    local roundName = "持续回合"
    local AT_TYPE = "物攻或魔攻"
    local desc = ""

    if data and data.ownerInfo and data.ownerInfo.descs then
        desc = LuaSqlite.getLanguageByKey(data.ownerInfo.descs[1])
        
        for key, value in string.gmatch(desc, "%b{}") do
            local begin, finish = string.find(key, "%b{}")
            local a, b = string.find(desc, key)
            local idx = tonumber(string.sub(key, begin+1, begin+1))
            local idx2 = tonumber(string.sub(key, begin+2, begin+2))
            local att = string.sub(key, begin+4, finish-1)
            local replaceDesc = ""
            if idx2 == 0 then
                for i=1,#data.ownerInfo.templateDatas[idx].conditions do
                    local Template = data.ownerInfo.templateDatas[idx].conditions[i]:getTemplate()
                    replaceDesc = Template:onGetSkillDesc(data.ownerInfo.templateDatas[idx].conditions[i],templateLevel)
                    if attName[replaceDesc] then
                        replaceDesc = LuaSqlite.getLanguageByKey(attName[replaceDesc])
                    end
                    desc = string.gsub(desc, key, replaceDesc)
                end
            else
                if att == AT_TYPE then
                    print("skillid---",data.skillid)
                    local skillInfo = BattleInfo.getSkillInfoByIDRaw(data.skillid)
                    if skillInfo.skill_B_Type == Proto.eST_Physics then
                        replaceDesc = LuaSqlite.getLanguageByKey(attName["AT_ATK"])
                    elseif skillInfo.skill_B_Type == Proto.eST_Special then
                        replaceDesc = LuaSqlite.getLanguageByKey(attName["AT_SATK"])
                    else
                        replaceDesc = AT_TYPE
                    end
                    desc = string.gsub(desc, key, replaceDesc)
                end
                for i=1,#data.ownerInfo.templates[idx].actions[idx2].params do
                    if data.ownerInfo.templates[idx].actions[idx2].params[i].name == att then
                        if att == roundName then
                            replaceDesc = tostring(data.ownerInfo.templates[idx].actions[idx2].params[i].datas[templateLevel])
                        elseif templateReplace and templateReplace[att] then
                            
                            replaceDesc = templateReplace[att]
                        else
                            local attType = data.ownerInfo.templates[idx].actions[idx2].params[i].datas[templateLevel]
                                or data.ownerInfo.templates[idx].actions[idx2].params[i].datas[1]
                            if attName[attType] then
                                replaceDesc = LuaSqlite.getLanguageByKey(attName[attType])
                                if templateValue then
                                    replaceDesc = templateValue..replaceDesc
                                end
                            else
                                replaceDesc = attType
                            end 
                        end
                        desc = string.gsub(desc, key, replaceDesc)
                    end
                end
            end
        end
    end
    if IS_SERVER_CODE == nil and BattleLogConfig.skillDesc then
        printFileLog("技能描述",desc)
    end
    return desc
    
end

function BattleAidFunc.testTagEvent(tagTemplateInfo,eventType,tagName)
    if tagTemplateInfo.event == EVENT_DESC[eventType] then
        return true
    end
    return false
end

function BattleAidFunc.testTagCondition(tagTemplateInfo,ownerPet,tagLevel,id)
    local templateDatas = tagTemplateInfo.conditions
    for i=1,#templateDatas do
        template = templateDatas[i]:getTemplate()
        if nil ~= template.checkCondition then
            if false == template:checkCondition(templateDatas[i],ownerPet,tagLevel,id) then
                return false
            end
        end
    end
    return true
end
return BattleAidFunc