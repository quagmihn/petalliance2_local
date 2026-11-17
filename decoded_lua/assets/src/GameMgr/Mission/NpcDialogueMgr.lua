local NpcDialogueMgr = {}

NpcDialogueMgr.DEFAULT_LABEL_UPDATE_TIME = 0.05
NpcDialogueMgr.DEFAULT_LABEL_UPDATE_SOUND = "Music/sound/label_update.m4a"
NpcDialogueMgr.LABEL_MAX_WIDTH = 560
NpcDialogueMgr.USE_RICHLABEL = false

local D_res = ""
local curString = ""
local curStringProcess = 0
local curStringLen = 0

local preResName = ""
local preName = ""
local preType = -1

local emoji = {}
local NPCDlgInfo = nil
local NPCStoryInfo = nil
local npcAni = nil
local audioHandle = nil

local spAniVec = {}

---重新初始化NpcDialogueMgr，用于动态lua调试
function NpcDialogueMgr.Init()
    D_res = ""
    curString = ""
    curStringProcess = 0
    curStringLen = 0
    
    preResName = ""
    preName = ""
    preType = -1
    
    emoji = {"yukuai", "deyi", "fennu", "kaixin", "ku", "liuhan"}
    
    if NPCDlgInfo==nil then
        NPCDlgInfo = TxtReader.new("Config/npc.txt")
        NPCDlgInfo.init({"id", "name", "message", "type", "moodId", "resName"}, 1)
    end
    
    if NPCStoryInfo==nil then
        local NPCStoryInfoReader = TxtReader.new("Config/story.txt")
        NPCStoryInfo = NPCStoryInfoReader.init({"id", "dialog", "yesStr", "noStr", "yes", "no", "face"}, 1, {id=1, face=1})
        for key, var in pairs(NPCStoryInfo) do
            local dialogVec = lua_string_split(var.dialog, ",")
            var.dialog = {}
            for k=1, #dialogVec do
                if tonumber(dialogVec[k]) then
                    table.insert(var.dialog, tonumber(dialogVec[k]))
                end
            end
            if var.yes then
                local dialogVec = lua_string_split(var.yes, ",")
                var.yes = {}
                for k=1, #dialogVec do
                    if tonumber(dialogVec[k]) then
                        table.insert(var.yes, tonumber(dialogVec[k]))
                    end
                end
            end
            if var.no then
                local dialogVec = lua_string_split(var.no, ",")
                var.no = {}
                for k=1, #dialogVec do
                    if tonumber(dialogVec[k]) then
                        table.insert(var.no, tonumber(dialogVec[k]))
                    end
                end
            end
        end
    end
    
    audioHandle = nil
    
    spAniVec = {
        ["em2.png"] = {res = "boshi.png", ani = {"idle2", "idle", "chayao", "taishou"}},
    }
    NpcDialogueMgr.hide()
end

---显示NPC对话框
--@param id int 对话id
--@param callback function 点击回调函数
function NpcDialogueMgr.show(id, callback)
    local info = nil
    local audioID = nil
    if type(id)=="table" then
    	info = id
    	audioID = info.audio
    else
        info = NPCDlgInfo.get(id) or {}
        audioID = id
    end
    
    if audioID then
        --放配音
        local adFilename = "Music/npc/"..audioID..GameAudio.getFileTypeString()
        local fileExist = cc.FileUtils:getInstance():isFileExist(adFilename)
        if fileExist == true then
            if audioHandle then
                audio.stopSound(audioHandle)
            end
            audioHandle = GameAudio.playSound(adFilename)
        end
    end
    
    local scene = SceneMgr.getRunningScene
    local resName = info.resName
    local SpecialAni = nil
    if resName then
        if spAniVec[resName] then
            SpecialAni = spAniVec[resName].ani
            resName = spAniVec[resName].res            
        end
        resName = "Spine/npc/"..resName
    end
    local message = info.message or "message not found!"
    local name = info.name or CharInfo.getNickName()
    local moodId = tonumber(info.moodId)
    local type = tonumber(info.type) or 0
    
    --判断人物是否和之前一样
    local isSameNPC = false
    if preResName==resName and preName==name and preType==type then
    	isSameNPC = true
    end
    preResName = resName
    preName = name
    preType = type
    
    D_res = "NPC/Dialogue_Right.csb"
    if type == 1 then
    	D_res = "NPC/Dialogue_Left.csb"
    end
    local node = CSResourceMgr.createRes(scene, D_res)
    CSResourceMgr.setRelativePosition(D_res, 320, 480)
    CocosModuleMgr.setEdgeDistance(node, nil, nil, nil, 0)
    local button = CSResourceMgr.getNodeByName(D_res, "Button")
    button:setTouchEnabled(false)
    node:setLocalZOrder(CocosModuleMgr.ZORDER_GUIDE)
    
    CSResourceMgr.setLabelColor(D_res, "name", {r=255,g=252,b=0,a=255})
    CSResourceMgr.setLabelString(D_res, "name", name, "", {r=0,g=0,b=0,a=255})
    --阿杜修改英文版显示
    local name = CSResourceMgr.getNodeByName(D_res,"name")
    if LuaSqlite.LANG_TYPE ~= 1 then
        if type == 1 then
            name:setAnchorPoint(0,0.5)
            name:setPositionX(30)
        else
            name:setAnchorPoint(1,0.5)
            name:setPositionX(580)
        end 
    end

    if resName then
        npcAni = AnimationMgr.createAni(CSResourceMgr.getNodeByName(D_res, "npc"), resName, 0, 0)
        if SpecialAni then
            local playNum = 1
            local function playIdle()
                if playNum>3 then
                    AnimationMgr.playAni(npcAni.res, SpecialAni[1], true, npcAni.tag)
                    return
                end
                local randomIndex = GetRandom.random(2, #SpecialAni)
                AnimationMgr.playAniWithCallback(npcAni.res, SpecialAni[randomIndex], playIdle, npcAni.tag, false)
                playNum = playNum+1
            end
            playIdle()
        else
            if moodId and emoji[moodId] then
                AnimationMgr.playAni(npcAni.res, emoji[moodId], true, npcAni.tag)
            end
        end
    end
    
    message = LuaSqlite.getLanguageByKey(message)
    message = string.gsub(message, "（玩家名）", CharInfo.getNickName())
    message = string.gsub(message, "（宠物名）", 
        LuaSqlite.getLanguageByKey(PokemonInfo.getPokemonInfoByID(PokemonInfo.getFollowPokemonID()).name))
    
    if CocosModuleMgr.checkIsRichLabelString(message) then
        local commonLabel = CSResourceMgr.getNodeByName(D_res, "message")
        local label = CocosModuleMgr.createRichLabel(button, message, 24, "cuyuan_GBK.ttf", NpcDialogueMgr.LABEL_MAX_WIDTH, 0, 0, nil, true)
        label:setVisible(false)
        label:setPosition(commonLabel:getPositionX(), commonLabel:getPositionY())

        local function AniFinished()
            CSResourceMgr.clickEventBinding(D_res, "db", function()
                CSResourceMgr.callButtonFunc(D_res, "Button")
            end)
            CSResourceMgr.playAction(D_res, 25, 58, true)
            label:setVisible(true)
            button:setTouchEnabled(true)
        end

        if isSameNPC then
            AniFinished()
        else
            CSResourceMgr.playActionWithCallback(D_res, 0, 20, 1, function()
                AniFinished()
            end)
        end

        CSResourceMgr.clickEventBinding(D_res, "Button", function()
            NpcDialogueMgr.hide()
            if callback~=nil then
                callback()
            else
                preResName = ""
                preName = ""
                preType = -1
            end
        end)
    else
    --[[
        local msg_vec = lua_string_split(message, "#")
        local emObj = nil
        if #msg_vec==3 then
            local emFile = "UI/Emoji/"..msg_vec[2].."/"..msg_vec[2]..".csb"
            message = "　　"..msg_vec[1]
            emObj = CSResourceMgr.createRes(button, emFile)
            emObj:setPosition(30, 123)
            CSResourceMgr.playAllFrame(emFile, true)
            local move1 = cc.MoveBy:create(0.5, {x=0, y=2})
            local move2 = cc.MoveBy:create(0.5, {x=0, y=-2})
            emObj:runAction(cc.RepeatForever:create(cc.Sequence:create(move1, move2)))
            emObj:setVisible(false)
        end
    --]]
        CSResourceMgr.setLabelString(D_res, "message", message, "")
        CSResourceMgr.setLabelMaxWidth(D_res, "message", NpcDialogueMgr.LABEL_MAX_WIDTH)
        local label = CSResourceMgr.getNodeByName(D_res, "message")
        label:setAnchorPoint(0, 1)
        label:setVisible(false)
        CSResourceMgr.getNodeByName(D_res, "enter"):setVisible(false)
        
        local function AniFinished()
            --[[
            if emObj then
            emObj:setVisible(true)
            end
            --]]
            CSResourceMgr.clickEventBinding(D_res, "db", function()
                CSResourceMgr.callButtonFunc(D_res, "Button")
            end)
            CSResourceMgr.playAction(D_res, 25, 58, true)
            label:setVisible(true)
            NpcDialogueMgr.setLabel(label, message)
            button:setTouchEnabled(true)
        end

        if isSameNPC then
            AniFinished()
        else
            CSResourceMgr.playActionWithCallback(D_res, 0, 20, 1, function()
                AniFinished()
            end)
        end

        CSResourceMgr.clickEventBinding(D_res, "Button", function()
            if curStringProcess<string.utf8len(curString) then
                NpcDialogueMgr.cancelLabelEffect(label)
            else
                NpcDialogueMgr.hide()
                if callback~=nil then
                    callback()
                else
                    preResName = ""
                    preName = ""
                    preType = -1
                end
            end
        end)
    end
end

---手动关闭NPC对话框
function NpcDialogueMgr.hide()
    if npcAni then
        local ret,errMessage = pcall(function()
            AnimationMgr.removeGafObjectByTag(npcAni.res, npcAni.tag)
            npcAni = nil
        end)
    end
    CSResourceMgr.removeCSObjectByTag("NPC/Dialogue_Right.csb")
    CSResourceMgr.removeCSObjectByTag("NPC/Dialogue_Left.csb")
end

---外部请勿调用
function NpcDialogueMgr.setLabel(label, string)
	curString = string
    curStringProcess = 0
    curStringLen = 0
    label:setString("")
    NpcDialogueMgr.updateLabel(label)
end

---外部请勿调用
function NpcDialogueMgr.updateLabel(label)
    if curStringProcess>=string.utf8len(curString) then
        transition.stopTarget(label)
        CSResourceMgr.getNodeByName(D_res, "enter"):setVisible(true)
    	return
    end
    label:performWithDelay(function()
        curStringProcess = curStringProcess + 1
        local tmpstr = NpcDialogueMgr.getUpdateStr(curStringProcess)
        --print("updateLabel:"..tmpstr)
        label:setString(tmpstr)
        --[[
        if curStringProcess%3==0 and device.platform~="windows" then
            GameAudio.playSound(NpcDialogueMgr.DEFAULT_LABEL_UPDATE_SOUND)
        end]]
        NpcDialogueMgr.updateLabel(label)
    end, NpcDialogueMgr.DEFAULT_LABEL_UPDATE_TIME) 
end

---外部请勿调用
function NpcDialogueMgr.cancelLabelEffect(label)
    transition.stopTarget(label)
    label:setString(curString)
    CSResourceMgr.getNodeByName(D_res, "enter"):setVisible(true)
    curStringProcess = string.utf8len(curString)
end

---外部请勿调用
function NpcDialogueMgr.getUpdateStr(process)
    curStringLen = curStringLen + 1
    local tmpstr = ChatMsgMgr.SubUTF8String(curString, curStringLen)
    --print("getUpdateStr:"..tmpstr..",len:"..string.utf8len(tmpstr)..",pro:"..process)
    if process>string.utf8len(tmpstr) then
        return NpcDialogueMgr.getUpdateStr(process)
    else
        return tmpstr
    end
end

function NpcDialogueMgr.checkStory(process)
    local curGuideInfo = NPCStoryInfo[process]
    if not curGuideInfo then
        return false
    end
    return true
end

function NpcDialogueMgr.showStory(process)
    local curGuideInfo = NPCStoryInfo[process]
    if not curGuideInfo then
        print("这个剧情没有填表", process)
    	return
    end
    local function showDialog(index)
        NpcDialogueMgr.show(curGuideInfo.dialog[index], function()
            if curGuideInfo.dialog[index+1] then
                showDialog(index+1)
            else
                if curGuideInfo.yes and curGuideInfo.no then
                    if curGuideInfo.face==1 then
                        PlayerAnimeMgr.getPlayer(PlayerAnimeMgr.SELF_TAG_STRING):setScaleX(-1)
                    end
                    local selRes = "NPC/DialogueSelector.csb"
                    local node = CSResourceMgr.createRes(SceneMgr.getRunningScene, selRes)
                    CSResourceMgr.setRelativePosition(selRes, 320, 480)
                    CocosModuleMgr.setEdgeDistance(node, nil, nil, nil, 0)
                    node:setLocalZOrder(CocosModuleMgr.ZORDER_GUIDE)
                    
                    CSResourceMgr.setLabelString(selRes, "name", CharInfo.getNickName(), "", {r=0,g=0,b=0,a=255}, nil, 300)
                    CSResourceMgr.setLabelString(selRes, "text1", curGuideInfo.yesStr, "", nil, nil, 450)
                    CSResourceMgr.getNodeByName(selRes, "text1"):enableOutline({r=0,g=0,b=0,a=255}, 1)
                    CSResourceMgr.setLabelString(selRes, "text2", curGuideInfo.noStr, "", nil, nil, 450)
                    CSResourceMgr.getNodeByName(selRes, "text2"):enableOutline({r=0,g=0,b=0,a=255}, 1)
                    
                    local function showMsg(dialog, idx)
                        local function finish()
                            GameGuideMgr.finishProcess()
                            if curGuideInfo.face==1 then
                                PlayerAnimeMgr.getPlayer(PlayerAnimeMgr.SELF_TAG_STRING):setScaleX(1)
                            end
                        end
                        if not dialog[idx] then
                            finish()
                        end
                        NpcDialogueMgr.show(dialog[idx], function()
                            if dialog[idx+1] then
                                showMsg(dialog, idx+1)
                            else
                                finish()
                            end
                        end)
                    end
                    CSResourceMgr.clickEventBinding(selRes, "btn1", function()
                        showMsg(curGuideInfo.yes, 1)
                        CSResourceMgr.removeCSObjectByTag(selRes)
                    end)
                    CSResourceMgr.clickEventBinding(selRes, "btn2", function()
                        showMsg(curGuideInfo.no, 1)
                        CSResourceMgr.removeCSObjectByTag(selRes)
                    end)
                    
                    CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(selRes, "selbg"), "up")
                else
                    GameGuideMgr.finishProcess()
                end
            end
        end)
    end
    if #curGuideInfo.dialog>0 then
        showDialog(1)
    end
end

return NpcDialogueMgr