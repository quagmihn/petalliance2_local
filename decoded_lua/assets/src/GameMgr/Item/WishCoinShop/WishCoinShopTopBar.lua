local WishCoinShopTopBar = {}
local resName  =  "Charactor/TopInfoArena.csb"
local resTag   =  "WishCoinShopTopBar"
  

function WishCoinShopTopBar.show()
    local layer      = CSResourceMgr.createRes(SceneMgr.getRunningScene,resName,resTag)
    local add_mcoin  = CSResourceMgr.getNodeByName(resName,"add_mcoin",resTag)
    local ditu_gcoin = CSResourceMgr.getNodeByName(resName,"ditu_gcoin",resTag)
    local mcoin      = CSResourceMgr.getNodeByName(resName,"mcoin",resTag)
    local add_hpoint = CSResourceMgr.getNodeByName(resName,"add_hpoint",resTag)
    local add_gcoin  = CSResourceMgr.getNodeByName(resName,"add_gcoin",resTag)
    local wishRes  = "Pet/Education/icn_summon_01.png"
    local dreamRes = "Pet/Education/icn_dream_01.png" 

    add_mcoin:hide()
    ditu_gcoin:hide()
	mcoin:hide()
    
    add_hpoint:setScale(0.55,0.55)
    add_gcoin:setScale(0.55,0.55)

    CSResourceMgr.setButtonTextureByNode(add_hpoint, wishRes, wishRes, wishRes)
    CSResourceMgr.setButtonTextureByNode(add_gcoin, dreamRes, dreamRes, dreamRes)

	local function loadCSB()
		layer:zorder(CocosModuleMgr.ZORDER_WINDOW)
		CocosModuleMgr.setEdgeDistance(layer, 0, nil, 0, nil)
		local panel = CSResourceMgr.getNodeByName(resName, "up",resTag)
        if panel then
            panel:setVisible(true)
            transition.moveTo(panel, {y=151, time=0.2})
        end
	end 
	local function loadNum() 
        CSResourceMgr.setLabelColor(resName, "hpoint", {r=190,g=221,b=245,a=255},resTag)
        CSResourceMgr.setLabelColor(resName, "gcoin",  {r=190,g=221,b=245,a=255},resTag)
        WishCoinShopTopBar.update()
    end
    local function loadBtn()
    	CSResourceMgr.clickEventBinding(resName, "close", function()
                WishCoinShopView:hide()
                CSResourceMgr.removeCSObjectByTag(resName,resTag)
                
        end,resTag)
    end
    local funcTable = {loadCSB,loadNum,loadBtn}
    for key,var in pairs(funcTable) do
    	var()
    end
end

function WishCoinShopTopBar.update()
    local hpoint = CSResourceMgr.getNodeByName(resName,"hpoint",resTag)
    local gcoin  = CSResourceMgr.getNodeByName(resName,"gcoin",resTag)
    local hpointStr = BagViewMgr.getItemNum(9992) or 0
    local gcoinStr  = BagViewMgr.getItemNum(9993) or 0
    if hpointStr > 9999999 then
        hpointStr = "9999999+"
    end
    if gcoinStr > 9999999 then
        gcoinStr = "9999999+"
    end
    hpoint:setString(hpointStr)
    gcoin:setString(gcoinStr) 
end

return WishCoinShopTopBar