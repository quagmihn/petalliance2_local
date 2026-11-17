local ConfraInfoViewMgr = {}

local curResName = ""
local curScene = nil

function ConfraInfoViewMgr.Init()
    print("ConfraInfoViewMgr初始化")
    
    curResName = ""
    curScene = nil
end

function ConfraInfoViewMgr.show(scene, info)
    curResName = "Confraternity/ConfraternityInfoView.csb"
    curScene = scene    
    
	local function loadCSB()
        CSResourceMgr.createRes(scene, curResName):setLocalZOrder(25)
        CSResourceMgr.setRelativePosition(curResName, 320, 480)

        CSResourceMgr.clickEventBinding(curResName, {"db"}, function()
        	ConfraInfoViewMgr.hide()
        end)
        CSResourceMgr.clickEventBinding(curResName, {"db", "diban", "apply"}, function()
        	TipsMgr.show(scene, "假装申请惹~")
        	ConfraInfoViewMgr.hide()
        end, "", true)
        CSResourceMgr.setLabelString(curResName, {"db", "diban", "name"}, info.name, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        CSResourceMgr.setLabelString(curResName, {"db", "diban", "leader"}, CocosModuleMgr.createStringWithFormat({"家族族长：<1>", info.player[1].name}), "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        CSResourceMgr.setLabelString(curResName, {"db", "diban", "info"}, CocosModuleMgr.createStringWithFormat({"家族等级：<1>   家族人数：<2>", info.level, #info.player}), "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        CSResourceMgr.setLabelString(curResName, {"db", "diban", "desc"}, info.desc)
        CSResourceMgr.setLabelMaxWidth(curResName, {"db", "diban", "desc"}, 390)
        CSResourceMgr.setButtonString(curResName, {"db", "diban", "apply"}, "申请加入", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
    end

    local function playCSB()
        CSResourceMgr.playAction(curResName, 0, 5, false)
    end

    local function loadMember()
        ConfraInfoViewMgr.loadMember(info.player)
    end

    local funcTable = {loadCSB, playCSB, loadMember}

    UnblockLoader.load(funcTable, "ConfraInfoViewMgr")
end

function ConfraInfoViewMgr.hide()
    UnblockLoader.cancel("ConfraInfoViewMgr")
    UnblockLoader.cancel("ConfraInfoViewMgr-loadMember")
	CSResourceMgr.playActionWithCallback(curResName, 50, 55, 1, function()
        CSResourceMgr.getNodeByName(curResName, {"db", "diban", "list"}):removeAllItems()
		CSResourceMgr.removeCSObjectByTag(curResName)
	end)
end

function ConfraInfoViewMgr.loadMember(info)
    local funcTable = {}
	for key, var in pairs(info) do
	local function addToList()
            CSResourceMgr.setButtonTexture(curResName, {"example", "icon"}, var.icon, var.icon, var.icon)
            CSResourceMgr.setLabelString(curResName, {"example", "name"}, var.name)
            CSResourceMgr.setLabelString(curResName, {"example", "level"}, CocosModuleMgr.createStringWithFormat({"Lv.<1>", var.level}))
            CSResourceMgr.clickEventBinding(curResName, "example", function()
                PlayerInfoViewMgr.show(curScene, var)
            end)
            local playBtn = CSResourceMgr.getNodeByName(curResName, "example"):clone()
            playBtn:setVisible(true)
            CSResourceMgr.getNodeByName(curResName, {"db", "diban", "list"}):pushBackCustomItem(playBtn)
            playBtn:setScaleY(0)
            transition.scaleTo(playBtn, {scaleY = 1, time = 0.1})
	end
        table.insert(funcTable, addToList)
	end
    UnblockLoader.load(funcTable, "ConfraInfoViewMgr-loadMember")
end

return ConfraInfoViewMgr