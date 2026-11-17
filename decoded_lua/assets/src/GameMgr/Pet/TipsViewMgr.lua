local TipsViewMgr = {}

local resName = ""
local cloneNode = nil

function TipsViewMgr.Init()
    print("TipsViewMgr初始化")
    resName = "Pet/Education/TipsView.csb"
end

function TipsViewMgr.hide()
    UnblockLoader.cancel("TipsViewMgr")
    CSResourceMgr.removeCSObjectByTag(resName)
    if cloneNode ~= nil then
        cloneNode:removeFromParent()
        cloneNode = nil
    end
    -- UIStack.pop("TipsViewMgr")
end

local function setLabel(node, string, outline, outlinewidth, textColor, maxwidth)
    CSResourceMgr.setLabelColorByNode(node, textColor)
    CSResourceMgr.setLabelStringByNode(node, string, outline)
    if outlinewidth ~= nil then
        node:enableOutline(outline, outlinewidth)
    end

    if maxwidth ~= nil then
        CSResourceMgr.setLabelMaxWidthByNode(node,maxwidth)
    end
end

--parentNode 父节点
--node 目标节点
--diffX 横向偏移值
--diffY 纵向偏移值
--posType 冒泡位置(1左边，2中间，3右边)
function TipsViewMgr.show(scene, parentNode, node, string, labelColor, outline, diffX, diffY, posType)
    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
    end

    local function loadUI()
        local btnTips = CSResourceMgr.getNodeByName(resName, "tips")
        cloneNode = CSResourceMgr.getNodeByName(resName, "tips1"):clone()
        local str = CSResourceMgr.seekNodeByName(cloneNode, "str")
        local up = CSResourceMgr.seekNodeByName(cloneNode, "up")

        local pos = parentNode:convertToWorldSpace(cc.p(node:getPositionX(), node:getPositionY()))
        cloneNode:addTo(scene)
        cloneNode:setPosition(pos.x + diffX, pos.y + diffY)
        local idx = posType % 3 == 0 and 3 or posType % 3
        up:setPositionX(100 - (idx - 1) * 100)
        cloneNode:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)

        setLabel(str, string, outline, nil, labelColor, 250)
        str:setAnchorPoint(0.5, 0)

        local strHeight = str:getContentSize().height
        up:setContentSize(280, strHeight + 20)

        CSResourceMgr.clickEventBindingByNode(btnTips, function ()
            TipsViewMgr.hide()
        end)
    end

    local funcTable = {loadCSB, loadUI}
    UnblockLoader.load(funcTable, "TipsViewMgr")
end

return TipsViewMgr