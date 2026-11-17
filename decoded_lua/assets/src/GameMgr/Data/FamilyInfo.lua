local FamilyInfo = {}

FamilyInfo.JobType = {Job_None = 0,Job_Leader = 1,Job_Elder = 2,Job_Master = 3,Job_Member = 4}

local LocalFamilyInfo = nil
local queryFamilyInfo = nil
local LocalFamilyMembersInfo = nil
local LastQueryMemberDetailInfo = nil
local IconInfo = nil
local enableDisplayGrid = true
local enableMoveCell = true
local enableTriggerGrid = true
local lastMoveCellIndex = 0
local targetMoveCellIndex = 0
local enableQueryMyFamily = true

FamilyInfo.CMD = {
    CREATE_FAMILY = "CreateFamily",                                             --创建家族
    JOIN_FAMILY = "JoinFamily",                                                 --加入家族
    ACCEPT_MEMBER = "AcceptMember",                                             --同意加入家族
    REFUSE_MEMBER = "RefuseMember",                                             --拒绝加入家族
    QUERY_MY_FAMILY = "QueryMyFamily",                                          --查询我的家族
    QUERY_FAMILY = "QueryFamily",                                               --查询家族
    QUERY_MY_FAMILY_MEMBERS = "QueryMyFamilyMembers",
    QUERY_MY_FAMILY_APPLYS = "QueryMyFamilyApplys",
    QUERY_FAMILY_MEMBERS = "QueryFamilyMembers",
    DISMISS_FAMILY = "DisbandFamily",                                           --解散家族
    QUIT_FAMILY = "LeaveFamily",                                                --退出家族
    TRANSFER_FAMILY = "ChangeLeader",                                           --转让家族
    MODIFY_FAMILY_INFO = "ChangeInfo",                                          --修改家族信息
    KICK_FAMILY_MEMBER = "KickMember",                                          --家族踢人
    CHAT_CONTENT_INVITE_ENTER_FAMILY = "invite_enter_family",
    CHAT_CONTENT_INVITE_ENTER_FAMILY_ACK = "invite_enter_family_ack",
    UPDATE_FIGHT_POINT = "UpdateFightPoint",                                    --更新自己的家族战斗力
    GET_FAMILY_QUEST = "GetFamilyQuest",                                        --查询家族任务
    APPLY_FAMILY_QUEST = "ApplyFamilyQuest",                                    --领取家族任务
    COMMIT_FAMILY_QUEST = "CommitFamilyQuest",                                  --提交家族任务
    LEVEL_UP_FAMILY = "LevelUpFamily",                                          --升级家族
    GET_FAMILY_DEVOTE_BUFFER = "GetFamilyDevoteBuffer",                         --领取家族贡献度排名
    QUERY_FAMILY_DONATION = "QueryFamilyDonation",                              --查询家族捐赠
    FAMILY_DONATION = "FamilyDonation",                                         --家族捐赠
    BUY_FAMILY_DONATION_ITEM = "BuyFamilyDonationItem",                         --购买家族捐赠道具
    RESET_FAMILY_QUEST = "ResetFamilyQuest",                                    --家族任务重置
}

function FamilyInfo.Init()
    LocalFamilyInfo = nil
    queryFamilyInfo = nil
    LocalFamilyMembersInfo = nil
    LastQueryMemberDetailInfo = nil
    if IconInfo==nil then
    	IconInfo = {}
        local IconInfoReader = TxtReader.new("Config/FamilyIcon.txt")
        local IconData = IconInfoReader.init({"id", "name","res_path"}, 1)
        for key, var in pairs(IconData) do
            local id = tonumber(var.id)
            IconInfo[id] = {name=(var["name"]), res_path=(var["res_path"])}
            --print("@@@@@@@@@@@@@@@@@name="..IconInfo[id].name)
        end
    end
    enableDisplayGrid = true
    enableMoveCell = true
    enableTriggerGrid = true
    lastMoveCellIndex = 0
    targetMoveCellIndex = 0
    enableQueryMyFamily = true
end

function FamilyInfo.reset()
    enableDisplayGrid = true
    enableMoveCell = true
    enableTriggerGrid = true
    lastMoveCellIndex = 0
    targetMoveCellIndex = 0
end

function FamilyInfo.getIconInfo()
    return IconInfo
end

function FamilyInfo.SetLocalFamilyInfo(info)
    LocalFamilyInfo = info
    StatusBarMgr.setFamilyBuffBtn()
end

function FamilyInfo.SetQueryFamilyInfo(info)
    queryFamilyInfo = info
end

function FamilyInfo.GetMyFamilyName()
    if CharInfo.getFamilyID() ~= nil and LocalFamilyInfo ~= nil then
        return LocalFamilyInfo.name or ""
    end
    return ""
end

function FamilyInfo.ModifyFamilyInfo(info)
    if info ~= nil and LocalFamilyInfo ~= nil then
        if info.icon ~= nil then
            LocalFamilyInfo.icon = info.icon
        end
        if info.needCheckJoin ~= nil then
            LocalFamilyInfo.needCheckJoin = info.needCheckJoin
        end
        if info.purpose ~= nil then
            LocalFamilyInfo.purpose = info.purpose
        end
        if info.notice ~= nil then
            LocalFamilyInfo.notice = info.notice
        end
        if info.access ~= nil then
            if info.access["elders"] ~= nil then
                LocalFamilyInfo.elders = info.access["elders"]
                --print("@@@@@@@@@@@@LocalFamilyInfo.elders="..sz_T2S(LocalFamilyInfo.elders))
            end
            if info.access["managers"] ~= nil then
                LocalFamilyInfo.managers = info.access["managers"]
                --print("@@@@@@@@@@@@LocalFamilyInfo.managers="..sz_T2S(LocalFamilyInfo.managers))
            end
        end
    end
end

function FamilyInfo.GetLocalFamilyInfo()
    return LocalFamilyInfo
end

function FamilyInfo.GetQueryFamilyInfo()
    return queryFamilyInfo
end

function FamilyInfo.SetLocalFamilyMembersInfo(info)
    --print("@@@@@@@@@@info=",sz_T2S(info))
    LocalFamilyMembersInfo = info
end

function FamilyInfo.GetLocalFamilyMembersInfo()
    return LocalFamilyMembersInfo
end

function FamilyInfo.SetLastQueryMemberDetailInfo(info)
    LastQueryMemberDetailInfo = info
    --print("++++++++++LastQueryMemberDetailInfo"..sz_T2S(LastQueryMemberDetailInfo))
end

function FamilyInfo.GetLastQueryMemberDetailInfo()
    return LastQueryMemberDetailInfo
end

function FamilyInfo.GetJobByMemberID(MemberID)
    if LocalFamilyInfo ~= nil then
        if LocalFamilyInfo.leaderID ~= nil and LocalFamilyInfo.leaderID == MemberID then
            return FamilyInfo.JobType.Job_Leader
        end
        if LocalFamilyInfo.elders ~= nil then
            for charID,v in pairs(LocalFamilyInfo.elders) do
                if tonumber(charID) == MemberID then
                    return FamilyInfo.JobType.Job_Elder
                end
            end
        end
        if LocalFamilyInfo.managers ~= nil then
            for charID,v in pairs(LocalFamilyInfo.managers) do
                if tonumber(charID) == MemberID then
                    return FamilyInfo.JobType.Job_Master
                end
            end
        end  
    end
    return FamilyInfo.JobType.Job_Member
end

function FamilyInfo.CreateFamily(icon, name, purpose, announcement, confirm)
    local cjson = require("cjson")
    local contents = json.encode({icon = icon, name = name, purpose = purpose, notice = announcement, needCheckJoin = confirm})
    local FamilySend = require("src.Net.Send.FamilySend")
    enableQueryMyFamily = false
    NetInterface.sendWithBlock("GC_FAMILY_ACK", function()
        --print("!!!!!!!!!!!!!!!sendCG_Family_Req contents="..contents)
        FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.CREATE_FAMILY, concent = contents})
    end,function()
    --print("!!!!!!!!!!!!!!!GC_GETHOME_ACK")
        --print("############CreateFamily LocalFamilyInfo="..tostring(LocalFamilyInfo))
        if LocalFamilyInfo == nil then
            LocalFamilyInfo = {}
        end
        LocalFamilyInfo.name = name
        StandardTipsMgr.show(0,"family63")
        enableQueryMyFamily = true
        FamilyInfo.QueryMyFamily(false, function()
            FamilyInfo.UpdateFightPoint(false, StatusBarMgr.getTotalFightPoint())
        end)
    end, function(code)
        --TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"login12", code}))
        --DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "create family failed:error code="..tostring(code))
        enableQueryMyFamily = true
        if code == Proto.Error.ERROR_NOTENOUGH_RMB then
            StandardTipsMgr.show(1,"tips14")
        end
    end)
end

function FamilyInfo.QueryFamily(familyID, withBlock)
    local cjson = require("cjson")
    local contents = json.encode({familyID = familyID})
    local FamilySend = require("src.Net.Send.FamilySend")
    local func
    if withBlock == nil or withBlock == true then
        func = NetInterface.sendWithBlock
    else
        func = NetInterface.send
    end
    func("GC_FAMILY_ACK", function()
        print("!!!!!!!!!!!!!!!QueryFamily---sendCG_Family_Req contents="..contents)
        FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.QUERY_FAMILY, concent = contents})
    end,function()
        --print("!!!!!!!!!!!!!!!GC_GETHOME_ACK")
    end, function(code)
        --TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"login12", code}))
        --DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "query family failed:error code="..tostring(code))
        if code == Proto.Error.ERROR_NO_FAMILY then
            StandardTipsMgr.show(1,"family4")
        end
    end)
end

function FamilyInfo.QueryMyFamily(withBlock,callback)
    if enableQueryMyFamily then
        local cjson = require("cjson")
        local contents = json.encode({})
        local FamilySend = require("src.Net.Send.FamilySend")
        local func
        if withBlock == nil or withBlock == true then
            func = NetInterface.sendWithBlock
        else
            func = NetInterface.send
        end
        enableQueryMyFamily = false
        func("GC_FAMILY_ACK", function()
            print("!!!!!!!!!!!!!!!QueryMyFamily---sendCG_Family_Req contents="..contents)
            FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.QUERY_MY_FAMILY, concent = contents})
        end,function()
            enableQueryMyFamily = true
            if callback then callback() end
        --print("!!!!!!!!!!!!!!!GC_GETHOME_ACK")
        end, function(code)
            enableQueryMyFamily = true
            --TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"login12", code}))
            --DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "query family failed:error code="..tostring(code))
            if code == Proto.Error.ERROR_NO_FAMILY then
                --StandardTipsMgr.show(1,"family4")
                --DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "family4")
            else
                --TipsMgr.showError(SceneMgr.getRunningScene,code)
            end
        end)
    end
end

function FamilyInfo.UpdateFightPoint(withBlock, fightPoint)
    local cjson = require("cjson")
    local contents = json.encode({fightPoint = fightPoint})
    local FamilySend = require("src.Net.Send.FamilySend")
    local func
    if withBlock == nil or withBlock == true then
        func = NetInterface.sendWithBlock
    else
        func = NetInterface.send
    end
    
    func("GC_FAMILY_ACK", function()
        print("!!!!!!!!!!!!!!!UpdateFightPoint---sendCG_Family_Req contents="..contents)
        FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.UPDATE_FIGHT_POINT, concent = contents})
    end,function()
    end, function(code)

        --TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"login12", code}))
        --DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "query family failed:error code="..tostring(code))
        if code == Proto.Error.ERROR_NO_FAMILY then
            StandardTipsMgr.show(1,"family4")
            --DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "family4")
        else
            TipsMgr.showError(SceneMgr.getRunningScene,code)
        end
    end)
end

function FamilyInfo.GetFamilyQuest()
    local cjson = require("cjson")
    local contents = json.encode({})
    local FamilySend = require("src.Net.Send.FamilySend")
    
    NetInterface.sendWithBlock("GC_FAMILY_ACK", function()
        print("!!!!!!!!!!!!!!!GetFamilyQuest---sendCG_Family_Req contents="..contents)
        FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.GET_FAMILY_QUEST, concent = contents})
    end,function()
    end, function(code)
        --StandardTipsMgr.show(1,"GetFamilyQuest failed code="..code)
        if code == Proto.Error.ERROR_NO_FAMILY then
            StandardTipsMgr.show(1,"CantSendMsg3")
        end
    end)
end

function FamilyInfo.ApplyFamilyQuest(index, questLevel)
    local cjson = require("cjson")
    local contents = json.encode({applyIndex = index})
    local FamilySend = require("src.Net.Send.FamilySend")

    NetInterface.sendWithBlock("GC_FAMILY_ACK", function()
        print("!!!!!!!!!!!!!!!ApplyFamilyQuest---sendCG_Family_Req contents="..contents)
        FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.APPLY_FAMILY_QUEST, concent = contents})
    end,function()
        StandardTipsMgr.show(0,"family81")
        TaskWatcherManager.saveAcceptFamilyQuestState({questLevel = questLevel})
    end, function(code)
        if code == Proto.Error.ERROR_CHARLEVEL then
            StandardTipsMgr.show(1,"Territorialtips5")
        elseif code == Proto.Error.ERROR_FAIL then
            StandardTipsMgr.show(1,"family82")
        elseif code == Proto.Error.ERROR_TODAY_FAMILY_QUEST_MAX then
            StandardTipsMgr.show(1,"family84")
        else
            StandardTipsMgr.show(1,"family147")
        end
    end)
end

function FamilyInfo.CommitFamilyQuest(successCallback)
    local cjson = require("cjson")
    local contents = json.encode({})
    local FamilySend = require("src.Net.Send.FamilySend")

    NetInterface.sendWithBlock("GC_FAMILY_ACK", function()
        print("!!!!!!!!!!!!!!!CommitFamilyQuest---sendCG_Family_Req contents="..contents)
        FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.COMMIT_FAMILY_QUEST, concent = contents})
    end,function()
        if successCallback then
            successCallback()
        end
    end, function(code)
        if code == Proto.Error.ERROR_TODAY_FAMILY_QUEST_MAX then
            StandardTipsMgr.show(1,"family84")
        else
            --StandardTipsMgr.show(1,"CommitFamilyQuest failed code="..code)
        end
    end)
end

function FamilyInfo.LevelUpFamily()
    local cjson = require("cjson")
    local contents = json.encode({})
    local FamilySend = require("src.Net.Send.FamilySend")

    NetInterface.sendWithBlock("GC_FAMILY_ACK", function()
        print("!!!!!!!!!!!!!!!LevelUpFamily---sendCG_Family_Req contents="..contents)
        FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.LEVEL_UP_FAMILY, concent = contents})
    end,function()
        GameAudio.playUISound("success")
        local info = FamilyInfo.GetLocalFamilyInfo()
        if info ~= nil then
            info.familyLevel = info.familyLevel or 1
            info.familyCoin = info.familyCoin - FamilyDataInfo.getFamilyLevelInfoById(info.familyLevel).familyCoin
            info.familyLevel = info.familyLevel + 1
            FurnitureViewMgr.upgradeFamilyYard(info.familyLevel)
        end
        StandardTipsMgr.show(0,"family79")
    end, function(code)
        StandardTipsMgr.show(1,"family80")
    end)
end

function FamilyInfo.GetFamilyDevoteBuffer()
    local cjson = require("cjson")
    local contents = json.encode({})
    local FamilySend = require("src.Net.Send.FamilySend")

    NetInterface.sendWithBlock("GC_FAMILY_ACK", function()
        print("!!!!!!!!!!!!!!!GetFamilyDevoteBuffer---sendCG_Family_Req contents="..contents)
        FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.GET_FAMILY_DEVOTE_BUFFER, concent = contents})
    end,function()
        StandardTipsMgr.show(0,"family111")
    end, function(code)
        StandardTipsMgr.show(1,"GetFamilyDevoteBuffer failed code="..code)
    end)
end

function FamilyInfo.JoinFamily(familyID)
    local cjson = require("cjson")
    local contents = json.encode({familyID = familyID})
    local FamilySend = require("src.Net.Send.FamilySend")
    enableQueryMyFamily = false
    NetInterface.sendWithBlock("GC_FAMILY_ACK", function()
        print("!!!!!!!!!!!!!!!JoinFamily---sendCG_Family_Req contents="..contents)
        FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.JOIN_FAMILY, concent = contents})
    end,function()
    --print("!!!!!!!!!!!!!!!GC_GETHOME_ACK")
        GameAudio.playUISound("success")
        StandardTipsMgr.show(0,"family14")
        enableQueryMyFamily = true
        FamilyInfo.QueryMyFamily(false, function()
            FamilyInfo.UpdateFightPoint(false, StatusBarMgr.getTotalFightPoint())
        end)
        TaskWatcherManager.saveJoinFamilyState()
    end, function(code)
        --TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"login12", code}))
        --DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "query family failed:error code="..tostring(code))
        enableQueryMyFamily = true
        if code == Proto.Error.ERROR_INCONFRATERNITY then
            StandardTipsMgr.show(1,"family9")
        elseif code == Proto.Error.ERROR_QUEUEFULL then
            StandardTipsMgr.show(1,"family109")
        elseif code == Proto.Error.ERROR_APPLY_FULL then
            StandardTipsMgr.show(1,"NetErrorText505")
        end
    end)
end

function FamilyInfo.AcceptMember(charID, charName)
    local cjson = require("cjson")
    local contents = json.encode({acceptCharID = charID})
    local FamilySend = require("src.Net.Send.FamilySend")
    NetInterface.sendWithBlock("GC_FAMILY_ACK", function()
        print("!!!!!!!!!!!!!!!AcceptMember---sendCG_Family_Req contents="..contents)
        FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.ACCEPT_MEMBER, concent = contents})
    end,function()
        FamilyInfo.BroadcastMessageInFamilyChannel(CocosModuleMgr.createStringWithFormat({"family57", charName}))
        FamilyApplyListViewMgr.finishMemberAdd(charID)
        --print("!!!!!!!!!!!!!!!GC_GETHOME_ACK")
    end, function(code)
        --StandardTipsMgr.show(1,"AcceptMember failed code="..code)
        --TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"login12", code}))
        --DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "query family failed:error code="..tostring(code))
        if code == Proto.Error.ERROR_FAIL then
            FamilyApplyListViewMgr.refreshApplyList({})
            FamilyInfo.QueryMyFamily(true)
            StandardTipsMgr.show(1,"family122")
        else
            FamilyApplyListViewMgr.delCurOperListCell(charID)
        end
    end)
end

function FamilyInfo.RefuseMember(charID)
    local cjson = require("cjson")
    local contents = json.encode({refuseCharID = charID})
    local FamilySend = require("src.Net.Send.FamilySend")
    NetInterface.sendWithBlock("GC_FAMILY_ACK", function()
        print("!!!!!!!!!!!!!!!RefuseMember---sendCG_Family_Req contents="..contents)
        FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.REFUSE_MEMBER, concent = contents})
    end,function()
        FamilyApplyListViewMgr.delCurOperListCell(charID)
    --print("!!!!!!!!!!!!!!!GC_GETHOME_ACK")
    end, function(code)
    --TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"login12", code}))
    --DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "query family failed:error code="..tostring(code))
        if code == Proto.Error.ERROR_FAIL then
            FamilyApplyListViewMgr.refreshApplyList({})
            FamilyInfo.QueryMyFamily(true)
            StandardTipsMgr.show(1,"family122")
        else
            FamilyApplyListViewMgr.delCurOperListCell(charID)
        end
    end)
end

function FamilyInfo.SendInviteEnterFamily(friendID)
    local cjson = require("cjson")
    local contents = json.encode({family_msg = FamilyInfo.CMD.CHAT_CONTENT_INVITE_ENTER_FAMILY, name = LocalFamilyInfo.name, id = CharInfo.getFamilyID()})
    local ChatSend = require("src.Net.Send.ChatSend")
    ChatSend.sendCG_Chat_Req({charID = friendID, channel = "", concent = contents})
end

function FamilyInfo.SendInviteEnterFamilyAck(friendID, result)
    local cjson = require("cjson")
    local contents = json.encode({family_msg = FamilyInfo.CMD.CHAT_CONTENT_INVITE_ENTER_FAMILY_ACK, result = result})
    local ChatSend = require("src.Net.Send.ChatSend")
    ChatSend.sendCG_Chat_Req({charID = friendID, channel = "", concent = contents})
end

function FamilyInfo.DismissFamily()
    local cjson = require("cjson")
    local contents = json.encode({})
    local FamilySend = require("src.Net.Send.FamilySend")
    NetInterface.sendWithBlock("GC_FAMILY_ACK", function()
        print("!!!!!!!!!!!!!!!DismissFamily---sendCG_Family_Req contents="..contents)
        FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.DISMISS_FAMILY, concent = contents})
    end,function()
    --print("!!!!!!!!!!!!!!!GC_GETHOME_ACK")
        StandardTipsMgr.show(0,"family15")
    end, function(code)
    --TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"login12", code}))
    --DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "query family failed:error code="..tostring(code))
    --if code == Proto.Error.ERROR_NO_FAMILY then
    --    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "family4")
    --end
    end)
end

function FamilyInfo.QuitFamily()
    local cjson = require("cjson")
    local contents = json.encode({})
    local FamilySend = require("src.Net.Send.FamilySend")
    NetInterface.sendWithBlock("GC_FAMILY_ACK", function()
        print("!!!!!!!!!!!!!!!QuitFamily---sendCG_Family_Req contents="..contents)
        FamilyInfo.BroadcastMessageInFamilyChannel(CocosModuleMgr.createStringWithFormat({"family51", CharInfo.getNickName()}))
        FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.QUIT_FAMILY, concent = contents})
    end,function()
        StandardTipsMgr.show(0,"family55")
        if MyFamilyLstViewMgr.IsOpen() then
            MyFamilyLstViewMgr.hide()
        end
        
        if SceneMgr.currentScene == "HomeScene" then
            SceneMgr.replaceScene(SceneMgr.getRunningScene, "MainScene")
            TownMapMgr.setPetScale(0.5)
            TownMapMgr.setPlayerScale(0.7)
            TownMapMgr.Pet:setLocalZOrder(CocosModuleMgr.ZORDER_PLAYER)
            TownMapMgr.Pet:setScale(TownMapMgr.DEFAULT_PET_SCALE, TownMapMgr.DEFAULT_PET_SCALE)
            TownMapMgr.Player:setLocalZOrder(CocosModuleMgr.ZORDER_PLAYER)
        end
    --print("!!!!!!!!!!!!!!!GC_GETHOME_ACK")
    end, function(code)
    --TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"login12", code}))
    --DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "query family failed:error code="..tostring(code))
    --if code == Proto.Error.ERROR_NO_FAMILY then
    --    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "family4")
    --end
        StandardTipsMgr.show(1,"family56")
    end)
end

function FamilyInfo.TransferFamily(charID, charName)
    local cjson = require("cjson")
    local contents = json.encode({newLeaderID = charID})
    local FamilySend = require("src.Net.Send.FamilySend")
    NetInterface.sendWithBlock("GC_FAMILY_ACK", function()
        print("!!!!!!!!!!!!!!!TransferFamily---sendCG_Family_Req contents="..contents)
        FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.TRANSFER_FAMILY, concent = contents})
    end,function()
        StandardTipsMgr.show(0,"family22")
        FamilyTransListViewMgr.hide()
        FamilyInfo.BroadcastMessageInFamilyChannel(CocosModuleMgr.createStringWithFormat({"family54", CharInfo.getNickName(), charName}))
        FamilyInfo.QueryMyFamily()
    end, function(code)
        StandardTipsMgr.show(1,"family23")
    --end
    end)
end

function FamilyInfo.KickFamilyMember(charID, charName)
    local cjson = require("cjson")
    local contents = json.encode({kickID = charID})
    local FamilySend = require("src.Net.Send.FamilySend")
    NetInterface.sendWithBlock("GC_FAMILY_ACK", function()
        print("!!!!!!!!!!!!!!!KickFamilyMember---sendCG_Family_Req contents="..contents)
        FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.KICK_FAMILY_MEMBER, concent = contents})
    end,function()
    --print("!!!!!!!!!!!!!!!GC_GETHOME_ACK")
        StandardTipsMgr.show(0,"family21")
        FamilyInfo.BroadcastMessageInFamilyChannel(CocosModuleMgr.createStringWithFormat({"family52", charName}))
        FamilyInfo.QueryMyFamily()
    end, function(code)
    --TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"login12", code}))
        --DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "Kick Family Member:error code="..tostring(code))
    --if code == Proto.Error.ERROR_NO_FAMILY then
    --    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "family4")
    --end
        StandardTipsMgr.show(1,"family20")
    end)
end

function FamilyInfo.ModifyFamilyIcon(icon)
    local cjson = require("cjson")
    local contents = json.encode({icon = icon})
    local FamilySend = require("src.Net.Send.FamilySend")
    FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.MODIFY_FAMILY_INFO, concent = contents})
end

function FamilyInfo.ModifyFamilyConfirmStyle(confirm)
    local cjson = require("cjson")
    local contents = json.encode({needCheckJoin = confirm})
    local FamilySend = require("src.Net.Send.FamilySend")
    FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.MODIFY_FAMILY_INFO, concent = contents})
end

function FamilyInfo.ModifyFamilyPurpose(purpose)
    local cjson = require("cjson")
    local contents = json.encode({purpose = purpose})
    local FamilySend = require("src.Net.Send.FamilySend")
    FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.MODIFY_FAMILY_INFO, concent = contents})
end

function FamilyInfo.ModifyFamilyAnnouncement(announcement)
    local cjson = require("cjson")
    local contents = json.encode({notice = announcement})
    local FamilySend = require("src.Net.Send.FamilySend")
    FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.MODIFY_FAMILY_INFO, concent = contents})
end

function FamilyInfo.ModifyFamilyAccessElder(charID)
    local oldJob = FamilyInfo.GetJobByMemberID(charID)
    if oldJob ~= FamilyInfo.JobType.Job_Elder then
        local elders_tbl = {}
        if LocalFamilyInfo.elders ~= nil then
            for k,v in pairs(LocalFamilyInfo.elders) do
                elders_tbl[k] = 1
            end
        end
        elders_tbl[tostring(charID)] = 1
        --tbl[tostring(charID + 1111)] = 1
        
        local job_tbl = {}
        job_tbl["elders"] = elders_tbl
        
        if oldJob == FamilyInfo.JobType.Job_Master then
            local masters_tbl = {}
            if LocalFamilyInfo.managers ~= nil then
                for k,v in pairs(LocalFamilyInfo.managers) do
                    if tonumber(k) ~= charID then
                        masters_tbl[k] = 1
                    end
                end
            end
            job_tbl["managers"] = masters_tbl
        end
        
        local access_tbl = {}
        access_tbl["access"] = job_tbl
        local cjson = require("cjson")
        local contents = cjson.encode(access_tbl)
        local FamilySend = require("src.Net.Send.FamilySend")
        NetInterface.sendWithBlock("GC_FAMILY_ACK", function()
            print("!!!!!!!!!!!!!!!ModifyFamilyAccessElder---sendCG_Family_Req contents="..contents)
            FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.MODIFY_FAMILY_INFO, concent = contents})
        end,function()
            StandardTipsMgr.show(0,"family19")
            FamilyInfo.QueryMyFamily()
        end, function(code)
            StandardTipsMgr.show(1,"family18")
        end)
    end
end

function FamilyInfo.ModifyFamilyAccessMaster(charID)
    local oldJob = FamilyInfo.GetJobByMemberID(charID)
    if oldJob ~= FamilyInfo.JobType.Job_Master then
        local masters_tbl = {}
        if LocalFamilyInfo.managers ~= nil then
            for k,v in pairs(LocalFamilyInfo.managers) do
                masters_tbl[k] = 1
            end
        end
        masters_tbl[tostring(charID)] = 1
        --tbl[tostring(charID + 1111)] = 1
    
        local job_tbl = {}
        job_tbl["managers"] = masters_tbl
        
        if oldJob == FamilyInfo.JobType.Job_Elder then
            local elders_tbl = {}
            if LocalFamilyInfo.elders ~= nil then
                for k,v in pairs(LocalFamilyInfo.elders) do
                    if tonumber(k) ~= charID then
                        elders_tbl[k] = 1
                    end
                end
            end
            job_tbl["elders"] = elders_tbl
        end
        
        local access_tbl = {}
        access_tbl["access"] = job_tbl
        local cjson = require("cjson")
        local contents = cjson.encode(access_tbl)
        local FamilySend = require("src.Net.Send.FamilySend")
        NetInterface.sendWithBlock("GC_FAMILY_ACK", function()
            print("!!!!!!!!!!!!!!!ModifyFamilyAccessMaster---sendCG_Family_Req contents="..contents)
            FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.MODIFY_FAMILY_INFO, concent = contents})
        end,function()
            StandardTipsMgr.show(0,"family19")
            FamilyInfo.QueryMyFamily()
        end, function(code)
            StandardTipsMgr.show(1,"family18")
        end)
    end
end

function FamilyInfo.ModifyFamilyAccessMember(charID)
    local oldJob = FamilyInfo.GetJobByMemberID(charID)
    if oldJob ~= FamilyInfo.JobType.Job_Member then
        local job_tbl = {}
        if oldJob == FamilyInfo.JobType.Job_Elder then
            local elders_tbl = {}
            if LocalFamilyInfo.elders ~= nil then
                for k,v in pairs(LocalFamilyInfo.elders) do
                    if tonumber(k) ~= charID then
                        elders_tbl[k] = 1
                    end
                end
            end
            job_tbl["elders"] = elders_tbl
        elseif oldJob == FamilyInfo.JobType.Job_Master then
            local masters_tbl = {}
            if LocalFamilyInfo.managers ~= nil then
                for k,v in pairs(LocalFamilyInfo.managers) do
                    if tonumber(k) ~= charID then
                        masters_tbl[k] = 1
                    end
                end
            end
            job_tbl["managers"] = masters_tbl
        end
        --local tbl = {}
        --tbl[tostring(charID)] = 1
        --tbl[tostring(charID + 1111)] = 1
        
        local access_tbl = {}
        access_tbl["access"] = job_tbl
        local cjson = require("cjson")
        local contents = cjson.encode(access_tbl)
        local FamilySend = require("src.Net.Send.FamilySend")
        NetInterface.sendWithBlock("GC_FAMILY_ACK", function()
            print("!!!!!!!!!!!!!!!ModifyFamilyAccessMember---sendCG_Family_Req contents="..contents)
            FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.MODIFY_FAMILY_INFO, concent = contents})
        end,function()
            StandardTipsMgr.show(0,"family19")
            FamilyInfo.QueryMyFamily()
        end, function(code)
            StandardTipsMgr.show(1,"family18")
        end)
    end
end

function FamilyInfo.BroadcastMessageInFamilyChannel(msg)
    local cjson = require("cjson")
    local contents = json.encode({textType = "text", concent = msg})
    local familyID = CharInfo.getFamilyID()
    if familyID ~= nil then
        local ChatSend = require("src.Net.Send.ChatSend")
        ChatSend.sendCG_Chat_Req({charID = "", channel = "family_"..tostring(familyID), concent = contents})
    end
end

function FamilyInfo.GoHome()
    GameAudio.playUISound("homeEnter")
    if SceneMgr.currentScene == "HomeScene" then
        HomeInfo.BroadcastHomePlayerLeaveMsg(CharInfo.getNickName())
    end
    if CharInfo.getFamilyID() == nil then
        HomeInfo.SetCurrentHomeCharID(CharInfo.getCharID())
    else
        HomeInfo.SetCurrentHomeCharID(0)
    end
    SceneMgr.mapEnterType = 1
    SceneMgr.replaceScene(SceneMgr.getRunningScene, "HomeScene")
end

function FamilyInfo.GetFamilyCopyMapInfo()
    local w, h = FamilyCopyMapMgr.getLocalCopyMapSize()
    if w <= 0 or h <= 0 then
        local FamilySend = require("src.Net.Send.FamilySend")
        
        NetInterface.sendWithBlock("GC_GetDungeon_Ack", function()
            print("!!!!!!!!!!!!!!!GetFamilyCopyMapInfo---sendCG_GetDungeon_Req")
            FamilySend.sendCG_GetDungeon_Req({type = 1})
        end,function()
        end, function(code)
            StandardTipsMgr.show(1,"GetFamilyCopyMapInfo failed code="..code)
        end)
    else
        if SceneMgr.currentScene == "FamilyCopyMapScene" then
            FamilyCopyMapMgr.addLocalCopyMapInfo({})
            FamilyCopyMapMgr.addLocalMembersInfo({})
            FamilyCopyMapMgr.addLocalBuffInfo({})
        end
    end
end

function FamilyInfo.FamilyCopyMovingGrid(index, width)
    targetMoveCellIndex = index
    if enableMoveCell and targetMoveCellIndex ~= lastMoveCellIndex then
        local x = math.ceil(index/width)
        local y = (index%width == 0 and width or index%width)
        local FamilySend = require("src.Net.Send.FamilySend")
        
        NetInterface.send("GC_DungeonMoveCell_Ack", function()
            print("!!!!!!!!!!!!!!!FamilyCopyMovingGrid---sendCG_DungeonMoveCell_Req",x,y)
            enableMoveCell = false
            lastMoveCellIndex = targetMoveCellIndex
            FamilySend.sendCG_DungeonMoveCell_Req({x = x, y = y, path = "", type = 1})
        end,function()
            enableMoveCell = true
            if targetMoveCellIndex ~= lastMoveCellIndex then
                FamilyInfo.FamilyCopyMovingGrid(targetMoveCellIndex, width)
            end
        end, function(code)
            enableMoveCell = true
            if targetMoveCellIndex ~= lastMoveCellIndex then
                FamilyInfo.FamilyCopyMovingGrid(targetMoveCellIndex, width)
            end
            StandardTipsMgr.show(1,"FamilyCopyMovingGrid failed code="..code)
        end)
    end
end

function FamilyInfo.FamilyCopyDisplayGrid(x, y)
    if enableDisplayGrid then
        local FamilySend = require("src.Net.Send.FamilySend")
    
        NetInterface.send("GC_FamilyDisplayCell_Ack", function()
            print("!!!!!!!!!!!!!!!FamilyCopyDisplayGrid---sendCG_FamilyDisplayCell_Req",x,y)
            enableDisplayGrid = false
            FamilySend.sendCG_FamilyDisplayCell_Req({x = x, y = y})
        end,function()
            enableDisplayGrid = true
            if SceneMgr.currentScene == "FamilyCopyMapScene" then
                FamilyCopyTopBarMgr.decCurrentStepNum()
                FamilyCopyMapMgr.playDisplayGridEffect(x, y)
            end
            --FamilyCopyMapMgr.displayGrid(x, y)
        end, function(code)
            enableDisplayGrid = true
            StandardTipsMgr.show(1,"family102")
        end)
    end
end

function FamilyInfo.FamilyCopyTriggerGrid(x, y, callback)
    if enableTriggerGrid then
        local FamilySend = require("src.Net.Send.FamilySend")
        
        NetInterface.send("GC_FireDungeonCell_Ack", function()
            print("!!!!!!!!!!!!!!!FamilyCopyTriggerGrid---sendCG_FireDungeonCell_Req",x,y)
            enableTriggerGrid = false
            FamilySend.sendCG_FireDungeonCell_Req({x = x, y = y, type = 1})
        end,function()
            enableTriggerGrid = true
            if SceneMgr.currentScene == "FamilyCopyMapScene" then
                FamilyCopyTopBarMgr.decCurrentStepNum()
            end
            if callback then callback() end
        end, function(code)
            enableTriggerGrid = true
            StandardTipsMgr.show(1,"family102")
        end)
    end
end

function FamilyInfo.FamilyBattleEnd(isWin, battleID, monsterHp, dps, x, y)
    local FamilySend = require("src.Net.Send.FamilySend")

    NetInterface.send("GC_DungeonBattleEnd_Ack", function()
        print("!!!!!!!!!!!!!!!FamilyBattleEnd---sendCG_DungeonBattleEnd_Req",isWin,battleID,monsterHp,dps,x,y)
        FamilySend.sendCG_DungeonBattleEnd_Req({isWin = isWin, battleID = battleID, monsterHp = monsterHp, dps = dps, x = x, y = y, type = 1})
    end,function()

    end, function(code)
        StandardTipsMgr.show(1,"FamilyBattleEnd failed code="..code)
    end)
end

function FamilyInfo.FamilyChangeFloor(type)
    local FamilySend = require("src.Net.Send.FamilySend")

    NetInterface.send("GC_DungeonChangeFloor_Ack", function()
        print("!!!!!!!!!!!!!!!FamilyChangeFloor---sendCG_DungeonChangeFloor_Req",type)
        FamilySend.sendCG_DungeonChangeFloor_Req({type = type, mapType = 1})
        FamilyCopyMapMgr.playChangeFloorEffect()
    end,function()
        if type == 1 then
            FamilyCopyMapMgr.incOwnerPlayerCurrentFloor()
        else
            FamilyCopyMapMgr.decOwnerPlayerCurrentFloor()
        end
        FamilyCopyMapMgr.cleanLocalCopyMapInfo()
        FamilyInfo.GetFamilyCopyMapInfo()
    end, function(code)
        StandardTipsMgr.show(1,"FamilyChangeFloor failed code="..code)
    end)
end

function FamilyInfo.GetFamilyCopyResetTime()
    local FamilySend = require("src.Net.Send.FamilySend")

    NetInterface.sendWithBlock("GC_GetDungeonCreateTime_Ack", function()
        print("!!!!!!!!!!!!!!!GetFamilyCopyResetTime---sendCG_GetDungeonCreateTime_Req")
        FamilySend.sendCG_GetDungeonCreateTime_Req()
    end,function()
    end, function(code)
        StandardTipsMgr.show(1,"GetFamilyCopyResetTime failed code="..code)
    end)
end

function FamilyInfo.ResetFamilyCopy()
    local FamilySend = require("src.Net.Send.FamilySend")

    NetInterface.sendWithBlock("GC_ResetDungeon_Ack", function()
        print("!!!!!!!!!!!!!!!ResetFamilyCopy---sendCG_ResetDungeon_Req")
        FamilySend.sendCG_ResetDungeon_Req()
    end,function()
    end, function(code)
        StandardTipsMgr.show(1,"ResetFamilyCopy failed code="..code)
    end)
end

function FamilyInfo.GetFamilyAwardInfo()
    local FamilySend = require("src.Net.Send.FamilySend")

    NetInterface.sendWithBlock("GC_GetDungeonAwardInfo_Ack", function()
        print("!!!!!!!!!!!!!!!GetFamilyAwardInfo---sendCG_GetDungeonAwardInfo_Req")
        FamilySend.sendCG_GetDungeonAwardInfo_Req()
    end,function()
    end, function(code)
        StandardTipsMgr.show(1,"GetFamilyAwardInfo failed code="..code)
    end)
end

function FamilyInfo.GetFamilyAward()
    local FamilySend = require("src.Net.Send.FamilySend")

    NetInterface.sendWithBlock("GC_GetDungeonAward_Ack", function()
        print("!!!!!!!!!!!!!!!GetFamilyAward---sendCG_GetDungeonAward_Req")
        FamilySend.sendCG_GetDungeonAward_Req()
    end,function()
    end, function(code)
        StandardTipsMgr.show(1,"GetFamilyAward failed code="..code)
    end)
end

function FamilyInfo.GetFamilyEventLog()
    local FamilySend = require("src.Net.Send.FamilySend")

    NetInterface.sendWithBlock("GC_GetDungeonLog_Ack", function()
        print("!!!!!!!!!!!!!!!GetFamilyLog---sendCG_GetDungeonLog_Req")
        FamilySend.sendCG_GetDungeonLog_Req()
    end,function()
    end, function(code)
        StandardTipsMgr.show(1,"GetFamilyLog failed code="..code)
    end)
end

function FamilyInfo.QueryFamilyDonation()
    local cjson = require("cjson")
    local contents = json.encode({})
    local FamilySend = require("src.Net.Send.FamilySend")
    NetInterface.sendWithBlock("GC_FAMILY_ACK", function()
        print("!!!!!!!!!!!!!!!QueryFamilyDonation---sendCG_Family_Req contents="..contents)
        FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.QUERY_FAMILY_DONATION, concent = contents})
    end,function()
    --print("!!!!!!!!!!!!!!!GC_GETHOME_ACK")
    end, function(code)
        --TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"login12", code}))
        --DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "query family failed:error code="..tostring(code))
        if code == Proto.Error.ERROR_NO_FAMILY then
            StandardTipsMgr.show(1,"family4")
        end
    end)
end

function FamilyInfo.FamilyDonation(goldNum, itemID, itemNum)
    local cjson = require("cjson")
    local contents = json.encode({goldNum = goldNum, itemID = itemID, itemNum = itemNum})
    local FamilySend = require("src.Net.Send.FamilySend")
    NetInterface.sendWithBlock("GC_FAMILY_ACK", function()
        print("!!!!!!!!!!!!!!!FamilyDonation---sendCG_Family_Req contents="..contents)
        FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.FAMILY_DONATION, concent = contents})
    end,function()
        --print("!!!!!!!!!!!!!!!GC_GETHOME_ACK")
        StandardTipsMgr.show(0,"family117")
        BagViewMgr.refreshItemInfo()
    end, function(code)
    --TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"login12", code}))
    --DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "query family failed:error code="..tostring(code))
        StandardTipsMgr.show(1,"FamilyDonation failed code="..code)
    end)
end

function FamilyInfo.BuyFamilyDonationItem(itemID, itemNum)
    local cjson = require("cjson")
    local contents = json.encode({itemID = itemID, itemNum = itemNum})
    local FamilySend = require("src.Net.Send.FamilySend")
    NetInterface.sendWithBlock("GC_FAMILY_ACK", function()
        print("!!!!!!!!!!!!!!!BuyFamilyDonationItem---sendCG_Family_Req contents="..contents)
        FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.BUY_FAMILY_DONATION_ITEM, concent = contents})
    end,function()
        --print("!!!!!!!!!!!!!!!GC_GETHOME_ACK")
        StandardTipsMgr.show(0,"LtTips6")
        BuyInfoMgr2.hide()
        BagViewMgr.refreshItemInfo()
        FamilyDonateMgr.updateItemNum()
    end, function(code)
        --TipsMgr.show(scene, CocosModuleMgr.createStringWithFormat({"login12", code}))
        --DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "query family failed:error code="..tostring(code))
        StandardTipsMgr.show(1,"BuyFamilyDonationItem failed code="..code)
    end)
end

function FamilyInfo.ResetFamilyQuest(successCallback)
    local cjson = require("cjson")
    local contents = json.encode({})
    local FamilySend = require("src.Net.Send.FamilySend")
    NetInterface.sendWithBlock("GC_FAMILY_ACK", function()
        print("!!!!!!!!!!!!!!!ResetFamilyQuest---sendCG_Family_Req contents="..contents)
        FamilySend.sendCG_Family_Req({cmd = FamilyInfo.CMD.RESET_FAMILY_QUEST, concent = contents})
    end,function()
        StandardTipsMgr.show(0,"family128")
        local info = FamilyInfo.GetLocalFamilyInfo()
        if info ~= nil then
            info.lastResetFamilyQuestTime = CharInfo.getServerTime()
            local familyLevel = (info.familyLevel or 1)
            local resetCoin = FamilyDataInfo.getFamilyLevelInfoById(familyLevel).resetFamilyQuestCost or 0
            info.familyCoin = (info.familyCoin or 0) - resetCoin
            info.resetFamilyQuestNum = (info.resetFamilyQuestNum or 0) + 1
        end
        if successCallback then successCallback() end
        FamilyInfo.GetFamilyQuest()
    end, function(code)
        StandardTipsMgr.show(1,"family129")
    end)
end

function FamilyInfo.GetFamilyShopData()
    local FamilySend = require("src.Net.Send.FamilySend")

    NetInterface.sendWithBlock("GC_GetFamilyShopData_Ack", function()
        print("!!!!!!!!!!!!!!!GetFamilyShopData---sendCG_GetFamilyShopData_Req")
        FamilySend.sendCG_GetFamilyShopData_Req()
    end,function()
    end, function(code)
        StandardTipsMgr.show(1,"GetFamilyShopData failed code="..code)
    end)
end

function FamilyInfo.BuyFamilyShopGoods(goodsID, successCallback)
    local FamilySend = require("src.Net.Send.FamilySend")

    NetInterface.sendWithBlock("GC_BuyFamilyShopGoods_Ack", function()
        print("!!!!!!!!!!!!!!!BuyFamilyShopGoods---sendCG_BuyFamilyShopGoods_Req goodsID=",goodsID)
        FamilySend.sendCG_BuyFamilyShopGoods_Req({goodsID = goodsID})
    end,function()
        StandardTipsMgr.show(0,"recharge21")
        if successCallback then successCallback() end
    end, function(code)
        StandardTipsMgr.show(1,"family142")
    end)
end

function FamilyInfo.RefreshFamilyShop(successCallback, failedCallback)
    local FamilySend = require("src.Net.Send.FamilySend")

    NetInterface.sendWithBlock("GC_RefalshFamilyShop_Ack", function()
        print("!!!!!!!!!!!!!!!RefreshFamilyShop---sendCG_RefalshFamilyShop_Req")
        FamilySend.sendCG_RefalshFamilyShop_Req()
    end,function()
        print("RefreshFamilyShop success!!!!")
        if successCallback then successCallback() end
    end, function(code)
        if failedCallback then failedCallback() end
        StandardTipsMgr.show(1,"RefreshFamilyShop failed code="..code)
    end)
end

function FamilyInfo.LevelRefreshFamilyShop(successCallback, failedCallback)
    local FamilySend = require("src.Net.Send.FamilySend")

    NetInterface.sendWithBlock("GC_LevelReflashFamilyShop_Ack", function()
        print("!!!!!!!!!!!!!!!LevelRefreshFamilyShop---sendCG_LevelReflashFamilyShop_Req")
        FamilySend.sendCG_LevelReflashFamilyShop_Req()
    end,function()
        print("LevelRefreshFamilyShop success!!!!")
        if successCallback then successCallback() end
    end, function(code)
        if failedCallback then failedCallback() end
        StandardTipsMgr.show(1,"LevelRefreshFamilyShop failed code="..code)
    end)
end

return FamilyInfo