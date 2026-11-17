local ArenaEffectMgr = {}

function ArenaEffectMgr.playBattleWinSpine(parent)
	local res = CocosModuleMgr.getWordImage("Ui_zhandoujiesuan.png")
    local effAni = AnimationMgr.createAni(parent, res, 0, 0, "battle_win_spine")
    AnimationMgr.playAni(effAni.res, "animation", true, "battle_win_spine")
end

return ArenaEffectMgr