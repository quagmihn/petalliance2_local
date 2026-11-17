local ScienceViewMgr = {}

local resName = ""
local resName1 = ""
local resName2 = ""
local resNameBG = ""
local tag = ""
local outlineParam = nil
local tabname = {}
local curTab = 1
local mainSkillNodes = {}
local subSkillNodes = {}

function ScienceViewMgr.Init()
    resName = "Player/Science/ScienceMain.csb"
    resName1 = "Player/Science/ScienceTab1.csb"
    resName2 = "Player/Science/ScienceTab2.csb"
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    tag = "ScienceViewMgr"
    outlineParam = {r=0,g=0,b=0,a=255,w=1,s=1}
    tabname = {"town2", "train36", "train37"}
    curTab = 1
    mainSkillNodes = {}
    subSkillNodes = {}
end

function ScienceViewMgr.show(scene, tab)
    if CSResourceMgr.getCsbObj(resNameBG, tag) then
        return
    end
    UIStack.push(tag, ScienceViewMgr.hide, true)
    
    curTab = tab or curTab
    local diff = CocosModuleMgr.getScreenSizeDiff()
    
    local function checkPos(node, diff)
        local tposy = node:getPositionY()
        node:setPositionY(tposy+diff)
    end

    local function checkSize(node, diff)
        local fsize = node:getContentSize()
        node:setContentSize(fsize.width, fsize.height+diff)
    end
    
    local function setTab()
        local tagA, tagB = "1", "2"
        local tabnode1 = CSResourceMgr.getCsbObj(resName1, tagA)
        local tabnode2 = CSResourceMgr.getCsbObj(resName1, tagB)
        local tabnode3 = CSResourceMgr.getCsbObj(resName2)
        local parent = CSResourceMgr.getNodeByName(resName, "parent")
        local function setNodeVisible(node, boolVisible)
        	if node then
                node:setVisible(boolVisible)
        	else
                if boolVisible then
        	   	    return false
        	    end
        	end
        	return true
        end
        if curTab==2 then
            setNodeVisible(tabnode2, false)
            setNodeVisible(tabnode3, false)
            if not setNodeVisible(tabnode1, true) then
                --主属性tab
                local function loadCSB()
                    local layer = CSResourceMgr.createRes(parent, resName1, tagA)
                    layer:setAnchorPoint(0.5, 1)
                    layer:pos(0, 0)
                    checkSize(CSResourceMgr.getNodeByName(resName1, "list", tagA), diff)
                    CSResourceMgr.setSpriteTexture(resName1, "skdb", ScienceInfo.getIconFrameRes(1), tagA)
                end
                local funcTable = {loadCSB}
                local skillInfo = ScienceInfo.getMainSkillInfo()
                mainSkillNodes = {}
                for var=1, #skillInfo do
                    local skInfo = skillInfo[var]
                    table.insert(funcTable, function()
                    	local list = CSResourceMgr.getNodeByName(resName1, "list", tagA)
                    	local node = CSResourceMgr.getNodeByName(resName1, "example", tagA):clone()
                        mainSkillNodes[skInfo.id] = node
                        list:pushBackCustomItem(node)
                        ScienceViewMgr.refreshSkillItem(skInfo)
                    end)
                    table.insert(funcTable, function()
                        mainSkillNodes[skInfo.id]:setScaleY(0)
                        mainSkillNodes[skInfo.id]:show()
                        transition.scaleTo(mainSkillNodes[skInfo.id], {time=0.1, scale=1})
                    end)
                end
                UnblockLoader.load(funcTable, tag.."1")
            end
        elseif curTab==3 then
            setNodeVisible(tabnode1, false)
            setNodeVisible(tabnode3, false)
            if not setNodeVisible(tabnode2, true) then
                --副属性tab
                local function loadCSB()
                    local layer = CSResourceMgr.createRes(parent, resName1, tagB)
                    layer:setAnchorPoint(0.5, 1)
                    layer:pos(0, 0)
                    checkSize(CSResourceMgr.getNodeByName(resName1, "list", tagB), diff)
                    CSResourceMgr.setSpriteTexture(resName1, "skdb", ScienceInfo.getIconFrameRes(2), tagB)
                end
                local funcTable = {loadCSB}
                local skillInfo = ScienceInfo.getSubSkillInfo()
                subSkillNodes = {}
                for var=1, #skillInfo do
                    local skInfo = skillInfo[var]
                    table.insert(funcTable, function()
                        local list = CSResourceMgr.getNodeByName(resName1, "list", tagB)
                        local node = CSResourceMgr.getNodeByName(resName1, "example", tagB):clone()
                        subSkillNodes[skInfo.id] = node
                        list:pushBackCustomItem(node)
                        ScienceViewMgr.refreshSkillItem(skInfo)
                    end)
                    table.insert(funcTable, function()
                        subSkillNodes[skInfo.id]:setScaleY(0)
                        subSkillNodes[skInfo.id]:show()
                        transition.scaleTo(subSkillNodes[skInfo.id], {time=0.1, scale=1})
                    end)
                end
                UnblockLoader.load(funcTable, tag.."2")
            end
        elseif curTab==1 then
            setNodeVisible(tabnode1, false)
            setNodeVisible(tabnode2, false)
            if not setNodeVisible(tabnode3, true) then
                --实验室tab
                local layer = CSResourceMgr.createRes(parent, resName2)
                layer:setAnchorPoint(0.5, 1)
                layer:pos(0, 0)
                checkSize(CSResourceMgr.getNodeByName(resName2, "list"), diff)
                checkSize(CSResourceMgr.getNodeByName(resName2, "ldb"), diff)
                local oinfo = ScienceInfo.getPurchaseOrder()
                ScienceViewMgr.refreshMaterialOrder(oinfo)
                CSResourceMgr.clickEventBinding(resName2, "reset", function()
                    local curTimes = ScienceInfo.getPurchaseOrderRefreshTimes()
                    local orderRule = ScienceInfo.getResetPurchaseOrderConsume()
                    if curTimes>=#orderRule then
                        StandardTipsMgr.show(1, "science24")
                    	return
                    end
                    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, CocosModuleMgr.createStringWithFormat({"science23",
                        orderRule[curTimes+1]}), function()
                            NetInterface.sendWithBlock("GC_ResetScienceConsumes_Ack", function()
                                local PetSend = require("src.Net.Send.PetSend")
                                PetSend.sendCG_ResetScienceConsumes_Req()
                            end, function()
                                local oinfo = ScienceInfo.getPurchaseOrder()
                                ScienceViewMgr.refreshMaterialOrder(oinfo)
                            end, function(code)
                                TipsMgr.showError(nil, code)
                            end)
                        end)
                end)
                CSResourceMgr.setLabelString(resName2, "title", "science6", nil, outlineParam, nil, 500)
                CSResourceMgr.setLabelString(resName2, "info", "science7", nil, outlineParam, nil, 500)
                CSResourceMgr.setLabelColor(resName2, "info", {r=255,g=252,b=0,a=255})
                CSResourceMgr.setButtonString(resName2, "reset", "science5", nil, outlineParam)
            end
        end
    end
    
    local function checkTab()
    	local daydiff = CocosModuleMgr.getDayTimeDiff(ScienceInfo.getPurchaseOrderTime(), CharInfo.getServerTime())
    	if daydiff~=0 then
            NetInterface.sendWithBlock("GC_GetScienceDatas_Ack", function()
    			local PetSend = require("src.Net.Send.PetSend")
    			PetSend.sendCG_GetScienceDatas_Req()
            end, setTab, setTab)
    	else
    	    setTab()
    	end
    end
    
    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG, tag)
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, tag)
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    end
    
    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CocosModuleMgr.setEdgeDistance(layer, nil, nil, 0, nil)
        CSResourceMgr.getNodeByName(resName, "db"):hide()

        checkPos(CSResourceMgr.getNodeByName(resName, "shade"), -diff)
        checkSize(CSResourceMgr.getNodeByName(resName, "imgdb"), diff)

        CSResourceMgr.setLabelColor(resName, "title", {r=214,g=245,b=251,a=255})
        CSResourceMgr.setLabelString(resName, "title", "science1", "", {r=26,g=37,b=48,a=255})
        CSResourceMgr.getNodeByName(resName, "line"):zorder(2)
        local textColor = {{r=82,g=82,b=82,a=255}, {r=255,g=255,b=255,a=255}}
        local outlineColor = {{r=230,g=230,b=230,a=255,w=1}, {r=0,g=0,b=0,a=255,w=1,s=1}}
        local function setTabButton(index, enable)
            CSResourceMgr.setButtonEnabled(resName, "tab"..index, enable)
            local type = 1
            if not enable then
            	type = 2
            end
            CSResourceMgr.setLabelString(resName, "tabtext"..index, tabname[index], "", outlineColor[type], nil, 100)
            CSResourceMgr.setLabelColor(resName, "tabtext"..index, textColor[type])
            CSResourceMgr.getNodeByName(resName, "tab"..index):setScale(1+(type-1)/10)
            CSResourceMgr.getNodeByName(resName, "tab"..index):setLocalZOrder(type-1)
        end
        for var=1, #tabname do
            CSResourceMgr.clickEventBinding(resName, "tab"..var, function()
                local n = curTab
                setTabButton(n, true)
                curTab = var
                checkTab()
                setTabButton(var, false)
            end, nil, nil, "sheetClick")
            if var==curTab then
                setTabButton(var, false)
            else
                setTabButton(var, true)
            end
        end
        
        CSResourceMgr.clickEventBinding(resName, "close", ScienceViewMgr.hide)
        CSResourceMgr.buttonEventBinding(resName, "add_hpoint", function()
        end)
        CSResourceMgr.clickEventBinding(resName, "add_gcoin", function()
            ExchangeViewMgr.show(scene, ExchangeViewMgr.GCASHTYPE)
        end)
        CSResourceMgr.clickEventBinding(resName, "add_mcoin", function()
            PurchaseViewMgr.show(scene)
        end)
        ScienceViewMgr.refreshGold()
        ScienceViewMgr.refreshCash()
        ScienceViewMgr.refreshPoint()
    end
    
    local function playCSB()
    	CSResourceMgr.playAction(resName, 0, 10, false)
        local node = CSResourceMgr.getNodeByName(resName, "db")
        node:show()
        CocosModuleMgr.showUIAnimation(node, "up")
        checkTab()
    end
    
    local funcTable = {loadBG, loadCSB, playCSB}
    UnblockLoader.load(funcTable, tag)
end

function ScienceViewMgr.hide()
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    UnblockLoader.cancel(tag.."1")
    UnblockLoader.cancel(tag.."2")
    UnblockLoader.cancel(tag.."3")
    UnblockLoader.cancel(tag)
    CSResourceMgr.removeList(resName1, "list", "1")
    CSResourceMgr.removeList(resName1, "list", "2")
    CSResourceMgr.removeList(resName2, "list")
    CSResourceMgr.removeCSObjectByTag(resName1, "1")
    CSResourceMgr.removeCSObjectByTag(resName1, "2")
    CSResourceMgr.removeCSObjectByTag(resName2)
    CSResourceMgr.removeCSObjectByTag(resName)
    CSResourceMgr.removeCSObjectByTag(resNameBG, tag)
    mainSkillNodes = {}
    subSkillNodes = {}
    StatusBarMgr.refreshFightPower(PetFormationMgr.getCurTab())
    GameAudio.playUISound("retract")
    UIStack.pop(tag)
end

function ScienceViewMgr.refreshGold()
    local curLayer = CSResourceMgr.getCsbObj(resName)
    if curLayer then
        CSResourceMgr.setLabelString(resName, "gcoin", CharInfo.getGCash(), "", nil, -1, 100)
    end
end

function ScienceViewMgr.refreshCash()
    local curLayer = CSResourceMgr.getCsbObj(resName)
    if curLayer then
        CSResourceMgr.setLabelString(resName, "mcoin", CharInfo.getMCash(), "", nil, -1, 100)
    end
end

function ScienceViewMgr.refreshPoint()
    local curLayer = CSResourceMgr.getCsbObj(resName)
    if curLayer then
        CSResourceMgr.setLabelString(resName, "hpoint", ScienceInfo.getSciencePoint(), "", nil, -1, 100)
    end
end

--name,desc,icon,star,level,lock,id,exp,type
function ScienceViewMgr.refreshSkillItem(info)
    local vec = {mainSkillNodes, subSkillNodes}
    local index = info.id
    local type = info.type
    if not index or not type then
    	return
    end
    if not vec[type] then
    	return
    end
    if not vec[type][index] then
    	return
    end
    local node = vec[type][index]
    if not node.stars then
        node.stars = {}
        for n=1, ScienceInfo.getMaxStar() do
            local star = display.newSprite("empty.png")
            star:addTo(node)
            star:pos(194+(n-1)*34, 96)
            node.stars[n] = star
        end
	end
    local b1 = CSResourceMgr.seekNodeByName(node, "b1")
    local b2 = CSResourceMgr.seekNodeByName(node, "b2")
    local t1 = CSResourceMgr.seekNodeByName(node, "t1")
    local t2 = CSResourceMgr.seekNodeByName(node, "t2")
    local n1 = CSResourceMgr.seekNodeByName(node, "n1")
    local n2 = CSResourceMgr.seekNodeByName(node, "n2")
    local icon = CSResourceMgr.seekNodeByName(node, "icon")
    local skdb = CSResourceMgr.seekNodeByName(node, "skdb")
	local starnum = info.star
	local level = info.level
	if CharInfo.getLevel()<info.lock then
		node:setColor({r=100,g=100,b=100})
        icon:setColor({r=100,g=100,b=100})
        skdb:setColor({r=100,g=100,b=100})
		starnum = 0
		level = 1
        CSResourceMgr.setButtonStringByNode(b1, CocosModuleMgr.createStringWithFormat({"train51", info.lock}), outlineParam)
        CSResourceMgr.setButtonEnabledByNode(b1, false)
        CSResourceMgr.setLabelColorByNode(t1, {r=216,g=216,b=216,a=255})
        CSResourceMgr.setLabelColorByNode(t2, {r=216,g=216,b=216,a=255})
        CSResourceMgr.setLabelColorByNode(n1, {r=127,g=127,b=127,a=255})
        CSResourceMgr.setLabelColorByNode(n2, {r=127,g=127,b=127,a=255})
        b1:show()
        b2:hide()
	else
        node:setColor({r=255,g=255,b=255})
        icon:setColor({r=255,g=255,b=255})
        skdb:setColor({r=255,g=255,b=255})
        CSResourceMgr.setButtonStringByNode(b1, "train50", outlineParam)
        CSResourceMgr.setButtonEnabledByNode(b1, true)
        CSResourceMgr.setLabelColorByNode(t1, {r=200,g=214,b=233,a=255})
        CSResourceMgr.setLabelColorByNode(t2, {r=200,g=214,b=233,a=255})
        CSResourceMgr.setLabelColorByNode(n1, {r=0,g=246,b=255,a=255})
        CSResourceMgr.setLabelColorByNode(n2, {r=78,g=255,b=0,a=255})
        b1:hide()
        b2:show()
        if starnum>=ScienceInfo.getMaxStar() and info.level>=ScienceInfo.getMaxLevel() then
            CSResourceMgr.setButtonStringByNode(b2, "science2", outlineParam)
            CSResourceMgr.setButtonEnabledByNode(b2, false)
        else
            if info.level<ScienceInfo.getMaxLevel() then
                b1:show()
                b2:hide()
            else
                info.exp = ScienceInfo.getExpMax(info.id, starnum, level)
            end
            CSResourceMgr.setButtonStringByNode(b2, "science3", outlineParam)
            CSResourceMgr.setButtonEnabledByNode(b2, true)
        end
	end
    for var=1, starnum do
		CSResourceMgr.setSpriteTextureByNode(node.stars[var], "Player/Science/xing.png")
	end
	if node.starnum then
		if node.starnum<starnum then
            local star = node.stars[starnum]
            CSResourceMgr.setSpriteTextureByNode(star, "Player/Science/xing_hui.png")
            local aniRes = "Gaf/effect/starupEffect.gaf"
            local tag = "science"..info.id.."-"..starnum
            local ani = AnimationMgr.createAni(star, aniRes, 0+15, 650+7, tag)
            ani:setGlobalZOrder(100)
            AnimationMgr.playAniWithCallback(aniRes, "do", function()
                AnimationMgr.removeGafObjectByTag(aniRes, tag)
                cc.Director:getInstance():getTextureCache():removeUnusedTextures()
                CSResourceMgr.setSpriteTextureByNode(star, "Player/Science/xing.png")
            end, tag)
		end
	end
	node.starnum = starnum
    for var=starnum+1, ScienceInfo.getMaxStar() do
        CSResourceMgr.setSpriteTextureByNode(node.stars[var], "Player/Science/xing_hui.png")
    end
    CSResourceMgr.clickEventBindingByNode(b1, function()
        ScienceDevelopMgr.showFeed(info)
    end)
    CSResourceMgr.clickEventBindingByNode(b2, function()
        ScienceDevelopMgr.showUpgrade(info)
    end)
    CSResourceMgr.setLabelStringByNode(t1, info.name, outlineParam, nil, 100)
    CSResourceMgr.setLabelStringByNode(t2, info.desc, outlineParam, nil, 100)
    CSResourceMgr.setLabelStringByNode(n1, "Lv"..level, outlineParam, nil, 150)
    local effstr = "science4"
    if type==2 then
        effstr = "<1>%"
    end
    CSResourceMgr.setLabelStringByNode(n2, CocosModuleMgr.createStringWithFormat({effstr, 
        ScienceInfo.getSkillEffect(info.id, starnum, level)}), outlineParam, nil, 150)
    if info.icon then
        icon:pos(58, 59)
    	CSResourceMgr.setSpriteTextureByNode(icon, info.icon)
    end
end

--type,num,total,item
function ScienceViewMgr.refreshMaterialOrder(infoVec)
	local list = CSResourceMgr.getNodeByName(resName2, "list")
	if not list then
		return
	end
	CSResourceMgr.removeListByNode(list)
	UnblockLoader.cancel(tag.."3")
    local funcTable = {}
    local orderNodes = {}
    for var=1, #infoVec do
		table.insert(funcTable, function()
            local info = infoVec[var]
            local node = CSResourceMgr.getNodeByName(resName2, "example"):clone()
            orderNodes[var] = node
            list:pushBackCustomItem(node)
            local remark = CSResourceMgr.seekNodeByName(node, "remark")
            local db1 = CSResourceMgr.seekNodeByName(node, "db1")
            local db2 = CSResourceMgr.seekNodeByName(node, "db2")
            local db3 = CSResourceMgr.seekNodeByName(node, "db3")
            local db4 = CSResourceMgr.seekNodeByName(node, "db4")
            local t1 = CSResourceMgr.seekNodeByName(node, "t1")
            local t2 = CSResourceMgr.seekNodeByName(node, "t2")
            local t3 = CSResourceMgr.seekNodeByName(node, "t3")
            local t4 = CSResourceMgr.seekNodeByName(node, "t4")
            local t5 = CSResourceMgr.seekNodeByName(node, "t5")
            local icon = CSResourceMgr.seekNodeByName(node, "icon")
            local enter = CSResourceMgr.seekNodeByName(node, "enter")
            local finish = CSResourceMgr.seekNodeByName(node, "finish")
            local price = info.price
            if info.type==2 then
                CSResourceMgr.setSpriteTextureByNode(remark, CocosModuleMgr.getWordImage("remark_urgent_need.png"))
            	CSResourceMgr.setSpriteTextureByNode(db4, "Player/Science/share_prompt_need_su.png")
            	CSResourceMgr.setLabelStringByNode(t5, "x"..info.rate, {r=161,g=2,b=171,a=255,w=1})
                CSResourceMgr.setLabelColorByNode(t5, {r=255,g=255,b=255,a=255})
                CSResourceMgr.setLabelColorByNode(t4, {r=0,g=254,b=156,a=255})
            elseif info.type==3 then
                CSResourceMgr.setSpriteTextureByNode(remark, CocosModuleMgr.getWordImage("remark_short.png"))
                CSResourceMgr.setSpriteTextureByNode(db4, "Player/Science/share_prompt_short_su.png")
                CSResourceMgr.setLabelStringByNode(t5, "x"..info.rate, {r=25,g=0,b=6,a=255,w=1})
                CSResourceMgr.setLabelColorByNode(t5, {r=255,g=66,b=0,a=255})
                CSResourceMgr.setLabelColorByNode(t4, {r=66,g=255,b=0,a=255})
            end
            remark:zorder(2)
            db4:zorder(2)
            t1:zorder(1)
            t2:zorder(1)
            t3:zorder(1)
            t4:zorder(1)
            t5:zorder(2)
            icon:zorder(2)
            finish:zorder(2)
            finish:scale(0.85)
            db1:setColor({r=171,g=192,b=198,a=255})
            db2:setColor({r=81,g=112,b=137,a=255})
            db3:setColor({r=81,g=112,b=137,a=255})
            local iteminfo = ItemInfo.getItemInfoById(info.item)
            if iteminfo then
                local itemnode = ItemInfo.getItemIconById(iteminfo.id)
                itemnode:addTo(node)
                itemnode:pos(60, 60)
                itemnode:zorder(1)
                itemnode:scale(0.6)
                CSResourceMgr.clickEventBindingByNode(itemnode, function()
                	ItemInfoViewMgr.show({id=iteminfo.id}, false)
                end, 3)
                CSResourceMgr.setLabelStringByNode(t1, iteminfo.name, outlineParam, nil, 200)
                CSResourceMgr.setLabelColorByNode(t1, {r=255,g=240,b=0,a=255})
            end
            CSResourceMgr.setLabelStringByNode(t2, "science10", outlineParam, nil, 90)
            CSResourceMgr.setLabelColorByNode(t3, {r=166,g=243,b=255,a=255})
            CSResourceMgr.setLabelStringByNode(t4, CocosModuleMgr.createStringWithFormat({"science9", price}), outlineParam, nil, 120)
            CSResourceMgr.setSpriteTextureByNode(finish, CocosModuleMgr.getWordImage("rw_yiwancheng.png"))
            local function refreshNum(num)
                CSResourceMgr.setLabelStringByNode(t3, num.."/"..info.total, outlineParam, nil, 150)
            	if num>=info.total then
                    enter:hide()
                    finish:show()
                else
                    enter:show()
                    finish:hide()
            	end
            end
            CSResourceMgr.setButtonStringByNode(enter, "science8", outlineParam)
            CSResourceMgr.clickEventBindingByNode(enter, function()
                ItemNumViewMgr.show({id=info.item, sum=ItemInfo.getCharItemNum(info.item), title="science17",
                    award=ScienceInfo.ITEM_ID, max=info.total-info.num, price=price, richtext=CocosModuleMgr.createRichLabelString(
                        {{color="FFFFFF", text="science10"}, {color="FF0000", text=info.num.."/"..info.total}})}, function(num)
                            NetInterface.sendWithBlock("GC_ScienceConsume_Ack", function()
                                print("submit <ScienceConsume> order:", info.id, num)
                                local PetSend = require("src.Net.Send.PetSend")
                                PetSend.sendCG_ScienceConsume_Req(info.id, num)
                            end, function()
                                info.num = num+info.num
                                refreshNum(info.num)
                                AwardsListMgr.show(SceneMgr.getRunningScene, {{ScienceInfo.ITEM_ID, price*num}})
                                ScienceInfo.changeSciencePoint()
                            end, function(code)
                                TipsMgr.showError(nil, code)
                            end)
                        end)
            end)
            refreshNum(info.num)
		end)
		table.insert(funcTable, function()
            orderNodes[var]:setScaleY(0)
            orderNodes[var]:show()
            transition.scaleTo(orderNodes[var], {time=0.1, scale=1})
		end)
	end
    UnblockLoader.load(funcTable, tag.."3")
end

return ScienceViewMgr