-- Net.Proto.Proto_System_Types

function Proto.parseSystemStringInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 编号
	data.name=Proto.parseString(entry); -- 名称
	data.content=Proto.parseSystemStringContent(entry); -- 内容
	return data;
end

function Proto.getSystemStringInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeSystemStringInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 编号
	Proto.writeString(msg,data.name); -- 名称
	Proto.writeSystemStringContent(msg,data.content); -- 内容
end

function Proto.parseBasicVariableConfig(entry)
	local data={};
	data.awardRate=Proto.parseDWORD(entry); -- 掉宝率(百分比)
	data.experienceRate=Proto.parseDWORD(entry); -- 经验比率(百分比)
	data.gCashRate=Proto.parseDWORD(entry); -- 金钱比率(百分比)
	data.attrRate=Proto.parseDWORD(entry); -- 帮贡比率(百分比)
	data.challengeNpcTime=Proto.parseDWORD(entry); -- NPC争夺战开始时间(相当于0点的秒数)
	data.mobility=Proto.parseDWORD(entry); -- 行动力
	data.canGetOnlinePresent=Proto.parseBYTE(entry); -- 可以获得在线奖励
	return data;
end

function Proto.writeBasicVariableConfig(msg,data)
	Proto.writeDWORD(msg,data.awardRate); -- 掉宝率(百分比)
	Proto.writeDWORD(msg,data.experienceRate); -- 经验比率(百分比)
	Proto.writeDWORD(msg,data.gCashRate); -- 金钱比率(百分比)
	Proto.writeDWORD(msg,data.attrRate); -- 帮贡比率(百分比)
	Proto.writeDWORD(msg,data.challengeNpcTime); -- NPC争夺战开始时间(相当于0点的秒数)
	Proto.writeDWORD(msg,data.mobility); -- 行动力
	Proto.writeBYTE(msg,data.canGetOnlinePresent); -- 可以获得在线奖励
end

function Proto.parseGlobalActivityRecord(entry)
	local data={};
	data.confraternityWarEnterLimitTime=Proto.parseActRecordID(entry); -- 工会战进入禁止
	data.experiencePercentage=Proto.parseActRecordID(entry); -- 经验比率
	data.experiencePercentageDeadline=Proto.parseActRecordID(entry); -- 经验比率有效时间
	data.autoRecoverHPPoint=Proto.parseActRecordID(entry); -- 自动HP补充点数
	data.autoRecoverSPPoint=Proto.parseActRecordID(entry); -- 自动SP补充点数
	return data;
end

function Proto.writeGlobalActivityRecord(msg,data)
	Proto.writeActRecordID(msg,data.confraternityWarEnterLimitTime); -- 工会战进入禁止
	Proto.writeActRecordID(msg,data.experiencePercentage); -- 经验比率
	Proto.writeActRecordID(msg,data.experiencePercentageDeadline); -- 经验比率有效时间
	Proto.writeActRecordID(msg,data.autoRecoverHPPoint); -- 自动HP补充点数
	Proto.writeActRecordID(msg,data.autoRecoverSPPoint); -- 自动SP补充点数
end

function Proto.parseGlobalConfigInfo(entry)
	local data={};
	data.id=Proto.parseBYTE(entry); -- 配置编号
	data.moneyCash=Proto.parseMoneyType(entry); -- 冲值币类型
	data.moneyBindCash=Proto.parseMoneyType(entry); -- 绑定代冲值币类型
	data.moneyGame=Proto.parseMoneyType(entry); -- 游戏币类型
	data.moneyBindGame=Proto.parseMoneyType(entry); -- 绑定代游戏币类型
	data.warningRange=Proto.parseBYTE(entry); -- 玩家的错误容许尺度
	data.maxInBagPetCount=Proto.parseBYTE(entry); -- 宠物袋宠物最大数量
	data.maxFreePetCount=Proto.parseBYTE(entry); -- 最大自由宠物数量
	data.maxActivePetCount=Proto.parseBYTE(entry); -- 最大活动(显示)宠物数量
	data.levelUpMax=Proto.parseWORD(entry); -- 宠物最大等级
	data.firstSpring=Proto.parseString(entry); -- 第一个春天起始的系统时间
	data.seasonTime=Proto.parseTIME_SEC(entry); -- 一个季节所占秒数
	data.plantCheckInterval=Proto.parseTIME_SEC(entry); -- 植物更新周期秒数
	data.plantGrowthSpeed=Proto.parseWORD(entry); -- 植物基本每周期生长粒度
	data.plantIrrigateMillisecond=Proto.parseDWORD(entry); -- 植物基本灌溉所需时间
	data.plantIngatherMillisecond=Proto.parseDWORD(entry); -- 植物基本收获所需时间
	data.plantRemoveMillisecond=Proto.parseDWORD(entry); -- 植物基本移除所需时间
	data.gardenNinkiHalfLife=Proto.parseWORD(entry); -- 庄园人气半衰期(分钟)
	data.gardenMinSummonInterval=Proto.parseTIME_SEC(entry); -- 庄园最短召唤动态NPC时间间隔(秒)
	data.gardenMaxSummonInterval=Proto.parseTIME_SEC(entry); -- 庄园最长召唤动态NPC时间间隔(秒)
	data.gardenSummonNpcsCyc=Proto.parseDWORD(entry); -- 庄园动态NPC召唤总周期(分钟)
	data.gardenSummonNpcsRadix=Proto.parseDWORD(entry); -- 庄园动态NPC召唤周期计算基数
	data.petFatigueInterval=Proto.parseTIME_SEC(entry); -- 宠物疲劳度增加所需间隔时间(秒)
	data.petFatigueIncreaseValue=Proto.parseWORD(entry); -- 宠物疲劳度每周期增加点数
	data.petAttribRecoverInterval=Proto.parseTIME_SEC(entry); -- 宠物属性恢复所需间隔时间(秒)
	data.petBaseHPRecoverRate=Proto.parseWORD(entry); -- 宠物标准HP每次恢复比率(万分率)
	data.petBaseSPRecoverRate=Proto.parseWORD(entry); -- 宠物标准SP每次恢复比率(万分率)
	data.miniutesOfLimitAfterLogin=Proto.parseWORD(entry); -- 登陆后不允许卖物品的限制时间(分钟)
	data.puzzleMaxTime=Proto.parseTIME_SEC(entry); -- 拼图进度最长占有时间(秒)
	data.puzzlePlusTime=Proto.parseTIME_SEC(entry); -- 每次开启拼图进度延长占有时间(秒)
	data.puzzleFreeTimeLimit=Proto.parseTIME_SEC(entry); -- 自由拼图进度(可被占有的)保留时间(秒)
	data.competitionEmbattleTimeLimit=Proto.parseDWORD(entry); -- 竞技布阵期倒数等待时间(毫秒)
	data.competitionDecisionTimeLimit=Proto.parseDWORD(entry); -- 竞技决策期倒数等待时间(毫秒)
	data.competitionBuffMax=Proto.parseBYTE(entry); -- 竞技单位增益状态的最大携带数量
	data.competitionDebuffMax=Proto.parseBYTE(entry); -- 竞技单位减益状态的最大携带数量
	data.competitionNormalAttackTime=Proto.parseDWORD(entry); -- 竞技普通攻击播放时间(毫秒)
	data.competitionEscapeTime=Proto.parseDWORD(entry); -- 竞技逃跑播放时间(毫秒)
	data.competitionChangePetTime=Proto.parseDWORD(entry); -- 竞技交换宠物播放时间(毫秒)
	data.maxConfraternityMember=Proto.parseWORD(entry); -- 公会最大成员限制
	data.confraternityCreatePay=Proto.parseDWORD(entry); -- 创建公会资金
	data.confraternityMoneyTakeRate=Proto.parseWORD(entry); -- 帮派会长招募冲值抽头率(万分率)
	data.confraternityMoneyTakeItemType=Proto.parseDWORD(entry); -- 帮派会长招募冲值抽头道具类型
	data.countryLorderMoneyTakeRate=Proto.parseWORD(entry); -- 国家领主帮派会长冲值抽头率(万分率)
	data.countryLorderMoneyTakeItemType=Proto.parseDWORD(entry); -- 国家领主帮派会长冲值抽头道具类型
	data.confraternityNpcFightCost=Proto.parseDWORD(entry); -- 帮派NPC争夺战报名费
	data.confraternityNpcPay=Proto.parseDWORD(entry); -- 帮派NPC保护费数额
	data.confraternityNpcFightDuration=Proto.parseTIME_SEC(entry); -- 帮派NPC争夺战持续时间(秒)
	data.confraternityNpcFightWinCount=Proto.parseWORD(entry); -- 帮派NPC争夺战胜利需要场次
	data.confraternityWarPeriod=Proto.parseTIME_SEC(entry); -- 工会战时长
	data.confraternityWarLoserProtectTime=Proto.parseTIME_SEC(entry); -- 工会战战败方保护时间
	data.confraternityWarWinnerProtectTime=Proto.parseTIME_SEC(entry); -- 工会战战胜方保护时间
	data.confraternityWarHistoryTime=Proto.parseTIME_SEC(entry); -- 工会战历史保留时间
	data.questLevelBeyondDiff=Proto.parseWORD(entry); -- 等级差距超过定值使NPC不显示可接任务标识等级差
	data.maxDivulge=Proto.parseDWORD(entry); -- 国战最高暴露值
	data.appearDivulge=Proto.parseDWORD(entry); -- 国战显隐暴露值
	data.itemBulletinLasts=Proto.parseTIME_SEC(entry); -- 宝箱道具公告持续时间（毫秒）
	data.pkBulletinLasts=Proto.parseTIME_SEC(entry); -- PK公告持续时间（毫秒）
	data.weddingBulletinLasts=Proto.parseTIME_SEC(entry); -- 婚礼公告持续时间（毫秒）
	data.searchGardenCD=Proto.parseDWORD(entry); -- 搜索庄园冷却时间（秒）
	data.maxInWarhousePetCount=Proto.parseWORD(entry); -- 最大仓库宠物数量
	data.maxTeamUpDistance=Proto.parseDWORD(entry); -- 组队距离限定
	data.activityRecords=Proto.parseGlobalActivityRecord(entry); -- 保留活动记录
	data.validateRetryTimes=Proto.parseBYTE(entry); -- 验证可重试次数
	data.validateTimeOutSec=Proto.parseWORD(entry); -- 验证超时时间（秒）
	data.validateCompetition=Proto.parseDWORD(entry); -- 触发验证需要的与怪竞技次数
	data.validateForceBinded=Proto.parseBYTE(entry); -- 验证送道具是否绑定
	data.ridingPetHungerTime=Proto.parseDWORD(entry); -- 骑宠饥饿间隔
	data.baseCharMoveSpeed=Proto.parseDWORD(entry); -- 人物基础移动速度
	data.basePetMoveSpeed=Proto.parseDWORD(entry); -- 宠物基础移动速度
	data.baseNpcMoveSpeed=Proto.parseDWORD(entry); -- npc基础移动速度
	data.maxRidingPetFill=Proto.parseDWORD(entry); -- 骑宠满足度上限
	data.forbiddenProcessBanTime=Proto.parseTIME_SEC(entry); -- 违规程序封停时间
	data.quitConfraternityCoolDown=Proto.parseTIME_SEC(entry); -- 退会冷却
	data.charLevelUpMax=Proto.parseWORD(entry); -- 人物最大等级
	data.maxHealth=Proto.parseDWORD(entry); -- 健康度上限
	data.utf8Trans=Proto.parseWORD(entry); -- utf8转码开关
	data.cullPresent=Proto.parseDWORD(entry); -- 新手礼包ID
	data.versionAvailable=Proto.parseDWORD(entry); -- 最低可登陆版本
	data.signinDrawing=Proto.parseDWORD(entry); -- 每日签到奖励表
	data.vipDrawing=Proto.parseDWORD(entry); -- vip签到奖励表
	data.challengeDrawing=Proto.parseDWORD(entry); -- 挑战好友奖励表
	data.mCashDrawing=Proto.parseVector(entry,Proto.parseDWORD); -- M币抽奖奖励表
	data.mCashDrawingCost=Proto.parseDWORD(entry); -- M币抽奖价格
	data.smallBuglePriceMCash=Proto.parseDWORD(entry); -- 小喇叭费用M币
	data.bossChanllenageTimeClearMCash=Proto.parseDWORD(entry); -- 挑战boss等待时间清零m币价格
	data.activeAwards=Proto.parseVector(entry,Proto.parseDWORD); -- 摇一摇奖励组(活跃度奖励)
	data.heroStageIDBegin=Proto.parseDWORD(entry); -- 英雄关卡ID开始
	data.heroStageIDEnd=Proto.parseDWORD(entry); -- 英雄关卡ID结束
	data.inviteCodeisOpen=Proto.parseBYTE(entry); -- 激活码是否开放
	data.clearStruggePriceM=Proto.parseWORD(entry); -- 清空努力值价格M
	data.resetSelfAttributePriceM=Proto.parseWORD(entry); -- 重置个体值价格M
	data.resetEquipPriceM=Proto.parseWORD(entry); -- 重置武器价格M
	data.resetEquipPriceG=Proto.parseWORD(entry); -- 重置武器价格G
	data.resetEquipPriceItem=Proto.parseDWORD(entry); -- 重置武器道具
	data.initPacketCapacity=Proto.parseWORD(entry); -- 初始背包格数
	data.robotsBegin=Proto.parseWORD(entry); -- 机器人编号开始
	data.robotsEnd=Proto.parseWORD(entry); -- 机器人编号结束
	data.resetSelfAttributePriceItem=Proto.parseDWORD(entry); -- 重置个体值道具
	data.mCashDrawingDouble=Proto.parseDWORD(entry); -- M币抽奖下次翻倍道具
	data.TGUseCountTodayLimit=Proto.parseWORD(entry); -- 玩家训练场每日租用上限
	data.confraternityDrawing=Proto.parseVector(entry,Proto.parseDWORD); -- 工会抽奖奖励
	data.arenaChallengeTimes=Proto.parseBYTE(entry); -- 玩家训练场每日挑战次数
	data.arenaChallengeCost=Proto.parseDWORD(entry); -- 竞技场额外挑战次数花费
	data.moneyTreeAwardID=Proto.parseDWORD(entry); -- 摇钱树奖励ID
	data.moneyTreePrice=Proto.parseDWORD(entry); -- 摇钱树树M币价格
	data.moneyTreeDailyTimesLimit=Proto.parseDWORD(entry); -- 摇钱树每日次数限制
	data.petAssignPointItem=Proto.parseDWORD(entry); -- 宠物配点道具
	data.petReduceStrugglesItemCost=Proto.parseCostInfo(entry); -- 宠物减少努力值道具
	data.petReduceStrugglesMoneyCost=Proto.parseCostInfo(entry); -- 宠物减少努力值花费
	data.injectFreeSoulCount=Proto.parseDWORD(entry); -- 每日免费注入灵魂数量
	data.starSoulResetTime=Proto.parseString(entry); -- 星魂殿每日重置时间
	return data;
end

function Proto.getGlobalConfigInfoIDLen()
	return Proto.getBYTELen();
end

function Proto.writeGlobalConfigInfo(msg,data)
	Proto.writeBYTE(msg,data.id); -- 配置编号
	Proto.writeMoneyType(msg,data.moneyCash); -- 冲值币类型
	Proto.writeMoneyType(msg,data.moneyBindCash); -- 绑定代冲值币类型
	Proto.writeMoneyType(msg,data.moneyGame); -- 游戏币类型
	Proto.writeMoneyType(msg,data.moneyBindGame); -- 绑定代游戏币类型
	Proto.writeBYTE(msg,data.warningRange); -- 玩家的错误容许尺度
	Proto.writeBYTE(msg,data.maxInBagPetCount); -- 宠物袋宠物最大数量
	Proto.writeBYTE(msg,data.maxFreePetCount); -- 最大自由宠物数量
	Proto.writeBYTE(msg,data.maxActivePetCount); -- 最大活动(显示)宠物数量
	Proto.writeWORD(msg,data.levelUpMax); -- 宠物最大等级
	Proto.writeString(msg,data.firstSpring); -- 第一个春天起始的系统时间
	Proto.writeTIME_SEC(msg,data.seasonTime); -- 一个季节所占秒数
	Proto.writeTIME_SEC(msg,data.plantCheckInterval); -- 植物更新周期秒数
	Proto.writeWORD(msg,data.plantGrowthSpeed); -- 植物基本每周期生长粒度
	Proto.writeDWORD(msg,data.plantIrrigateMillisecond); -- 植物基本灌溉所需时间
	Proto.writeDWORD(msg,data.plantIngatherMillisecond); -- 植物基本收获所需时间
	Proto.writeDWORD(msg,data.plantRemoveMillisecond); -- 植物基本移除所需时间
	Proto.writeWORD(msg,data.gardenNinkiHalfLife); -- 庄园人气半衰期(分钟)
	Proto.writeTIME_SEC(msg,data.gardenMinSummonInterval); -- 庄园最短召唤动态NPC时间间隔(秒)
	Proto.writeTIME_SEC(msg,data.gardenMaxSummonInterval); -- 庄园最长召唤动态NPC时间间隔(秒)
	Proto.writeDWORD(msg,data.gardenSummonNpcsCyc); -- 庄园动态NPC召唤总周期(分钟)
	Proto.writeDWORD(msg,data.gardenSummonNpcsRadix); -- 庄园动态NPC召唤周期计算基数
	Proto.writeTIME_SEC(msg,data.petFatigueInterval); -- 宠物疲劳度增加所需间隔时间(秒)
	Proto.writeWORD(msg,data.petFatigueIncreaseValue); -- 宠物疲劳度每周期增加点数
	Proto.writeTIME_SEC(msg,data.petAttribRecoverInterval); -- 宠物属性恢复所需间隔时间(秒)
	Proto.writeWORD(msg,data.petBaseHPRecoverRate); -- 宠物标准HP每次恢复比率(万分率)
	Proto.writeWORD(msg,data.petBaseSPRecoverRate); -- 宠物标准SP每次恢复比率(万分率)
	Proto.writeWORD(msg,data.miniutesOfLimitAfterLogin); -- 登陆后不允许卖物品的限制时间(分钟)
	Proto.writeTIME_SEC(msg,data.puzzleMaxTime); -- 拼图进度最长占有时间(秒)
	Proto.writeTIME_SEC(msg,data.puzzlePlusTime); -- 每次开启拼图进度延长占有时间(秒)
	Proto.writeTIME_SEC(msg,data.puzzleFreeTimeLimit); -- 自由拼图进度(可被占有的)保留时间(秒)
	Proto.writeDWORD(msg,data.competitionEmbattleTimeLimit); -- 竞技布阵期倒数等待时间(毫秒)
	Proto.writeDWORD(msg,data.competitionDecisionTimeLimit); -- 竞技决策期倒数等待时间(毫秒)
	Proto.writeBYTE(msg,data.competitionBuffMax); -- 竞技单位增益状态的最大携带数量
	Proto.writeBYTE(msg,data.competitionDebuffMax); -- 竞技单位减益状态的最大携带数量
	Proto.writeDWORD(msg,data.competitionNormalAttackTime); -- 竞技普通攻击播放时间(毫秒)
	Proto.writeDWORD(msg,data.competitionEscapeTime); -- 竞技逃跑播放时间(毫秒)
	Proto.writeDWORD(msg,data.competitionChangePetTime); -- 竞技交换宠物播放时间(毫秒)
	Proto.writeWORD(msg,data.maxConfraternityMember); -- 公会最大成员限制
	Proto.writeDWORD(msg,data.confraternityCreatePay); -- 创建公会资金
	Proto.writeWORD(msg,data.confraternityMoneyTakeRate); -- 帮派会长招募冲值抽头率(万分率)
	Proto.writeDWORD(msg,data.confraternityMoneyTakeItemType); -- 帮派会长招募冲值抽头道具类型
	Proto.writeWORD(msg,data.countryLorderMoneyTakeRate); -- 国家领主帮派会长冲值抽头率(万分率)
	Proto.writeDWORD(msg,data.countryLorderMoneyTakeItemType); -- 国家领主帮派会长冲值抽头道具类型
	Proto.writeDWORD(msg,data.confraternityNpcFightCost); -- 帮派NPC争夺战报名费
	Proto.writeDWORD(msg,data.confraternityNpcPay); -- 帮派NPC保护费数额
	Proto.writeTIME_SEC(msg,data.confraternityNpcFightDuration); -- 帮派NPC争夺战持续时间(秒)
	Proto.writeWORD(msg,data.confraternityNpcFightWinCount); -- 帮派NPC争夺战胜利需要场次
	Proto.writeTIME_SEC(msg,data.confraternityWarPeriod); -- 工会战时长
	Proto.writeTIME_SEC(msg,data.confraternityWarLoserProtectTime); -- 工会战战败方保护时间
	Proto.writeTIME_SEC(msg,data.confraternityWarWinnerProtectTime); -- 工会战战胜方保护时间
	Proto.writeTIME_SEC(msg,data.confraternityWarHistoryTime); -- 工会战历史保留时间
	Proto.writeWORD(msg,data.questLevelBeyondDiff); -- 等级差距超过定值使NPC不显示可接任务标识等级差
	Proto.writeDWORD(msg,data.maxDivulge); -- 国战最高暴露值
	Proto.writeDWORD(msg,data.appearDivulge); -- 国战显隐暴露值
	Proto.writeTIME_SEC(msg,data.itemBulletinLasts); -- 宝箱道具公告持续时间（毫秒）
	Proto.writeTIME_SEC(msg,data.pkBulletinLasts); -- PK公告持续时间（毫秒）
	Proto.writeTIME_SEC(msg,data.weddingBulletinLasts); -- 婚礼公告持续时间（毫秒）
	Proto.writeDWORD(msg,data.searchGardenCD); -- 搜索庄园冷却时间（秒）
	Proto.writeWORD(msg,data.maxInWarhousePetCount); -- 最大仓库宠物数量
	Proto.writeDWORD(msg,data.maxTeamUpDistance); -- 组队距离限定
	Proto.writeGlobalActivityRecord(msg,data.activityRecords); -- 保留活动记录
	Proto.writeBYTE(msg,data.validateRetryTimes); -- 验证可重试次数
	Proto.writeWORD(msg,data.validateTimeOutSec); -- 验证超时时间（秒）
	Proto.writeDWORD(msg,data.validateCompetition); -- 触发验证需要的与怪竞技次数
	Proto.writeBYTE(msg,data.validateForceBinded); -- 验证送道具是否绑定
	Proto.writeDWORD(msg,data.ridingPetHungerTime); -- 骑宠饥饿间隔
	Proto.writeDWORD(msg,data.baseCharMoveSpeed); -- 人物基础移动速度
	Proto.writeDWORD(msg,data.basePetMoveSpeed); -- 宠物基础移动速度
	Proto.writeDWORD(msg,data.baseNpcMoveSpeed); -- npc基础移动速度
	Proto.writeDWORD(msg,data.maxRidingPetFill); -- 骑宠满足度上限
	Proto.writeTIME_SEC(msg,data.forbiddenProcessBanTime); -- 违规程序封停时间
	Proto.writeTIME_SEC(msg,data.quitConfraternityCoolDown); -- 退会冷却
	Proto.writeWORD(msg,data.charLevelUpMax); -- 人物最大等级
	Proto.writeDWORD(msg,data.maxHealth); -- 健康度上限
	Proto.writeWORD(msg,data.utf8Trans); -- utf8转码开关
	Proto.writeDWORD(msg,data.cullPresent); -- 新手礼包ID
	Proto.writeDWORD(msg,data.versionAvailable); -- 最低可登陆版本
	Proto.writeDWORD(msg,data.signinDrawing); -- 每日签到奖励表
	Proto.writeDWORD(msg,data.vipDrawing); -- vip签到奖励表
	Proto.writeDWORD(msg,data.challengeDrawing); -- 挑战好友奖励表
	Proto.writeVector(msg,data.mCashDrawing,Proto.writeDWORD); -- M币抽奖奖励表
	Proto.writeDWORD(msg,data.mCashDrawingCost); -- M币抽奖价格
	Proto.writeDWORD(msg,data.smallBuglePriceMCash); -- 小喇叭费用M币
	Proto.writeDWORD(msg,data.bossChanllenageTimeClearMCash); -- 挑战boss等待时间清零m币价格
	Proto.writeVector(msg,data.activeAwards,Proto.writeDWORD); -- 摇一摇奖励组(活跃度奖励)
	Proto.writeDWORD(msg,data.heroStageIDBegin); -- 英雄关卡ID开始
	Proto.writeDWORD(msg,data.heroStageIDEnd); -- 英雄关卡ID结束
	Proto.writeBYTE(msg,data.inviteCodeisOpen); -- 激活码是否开放
	Proto.writeWORD(msg,data.clearStruggePriceM); -- 清空努力值价格M
	Proto.writeWORD(msg,data.resetSelfAttributePriceM); -- 重置个体值价格M
	Proto.writeWORD(msg,data.resetEquipPriceM); -- 重置武器价格M
	Proto.writeWORD(msg,data.resetEquipPriceG); -- 重置武器价格G
	Proto.writeDWORD(msg,data.resetEquipPriceItem); -- 重置武器道具
	Proto.writeWORD(msg,data.initPacketCapacity); -- 初始背包格数
	Proto.writeWORD(msg,data.robotsBegin); -- 机器人编号开始
	Proto.writeWORD(msg,data.robotsEnd); -- 机器人编号结束
	Proto.writeDWORD(msg,data.resetSelfAttributePriceItem); -- 重置个体值道具
	Proto.writeDWORD(msg,data.mCashDrawingDouble); -- M币抽奖下次翻倍道具
	Proto.writeWORD(msg,data.TGUseCountTodayLimit); -- 玩家训练场每日租用上限
	Proto.writeVector(msg,data.confraternityDrawing,Proto.writeDWORD); -- 工会抽奖奖励
	Proto.writeBYTE(msg,data.arenaChallengeTimes); -- 玩家训练场每日挑战次数
	Proto.writeDWORD(msg,data.arenaChallengeCost); -- 竞技场额外挑战次数花费
	Proto.writeDWORD(msg,data.moneyTreeAwardID); -- 摇钱树奖励ID
	Proto.writeDWORD(msg,data.moneyTreePrice); -- 摇钱树树M币价格
	Proto.writeDWORD(msg,data.moneyTreeDailyTimesLimit); -- 摇钱树每日次数限制
	Proto.writeDWORD(msg,data.petAssignPointItem); -- 宠物配点道具
	Proto.writeCostInfo(msg,data.petReduceStrugglesItemCost); -- 宠物减少努力值道具
	Proto.writeCostInfo(msg,data.petReduceStrugglesMoneyCost); -- 宠物减少努力值花费
	Proto.writeDWORD(msg,data.injectFreeSoulCount); -- 每日免费注入灵魂数量
	Proto.writeString(msg,data.starSoulResetTime); -- 星魂殿每日重置时间
end

function Proto.parseOnlineBulletinCaption(entry)
	local data={};
	data.key_code=Proto.parseBulletinCode(entry); -- 关键词
	data.releaseTime=Proto.parseTIME_SEC(entry); -- 发布日期
	return data;
end

function Proto.writeOnlineBulletinCaption(msg,data)
	Proto.writeBulletinCode(msg,data.key_code); -- 关键词
	Proto.writeTIME_SEC(msg,data.releaseTime); -- 发布日期
end

function Proto.parseOnlineBulletin(entry)
	local data={};
	data.caption=Proto.parseOnlineBulletinCaption(entry); -- 标识
	data.title=Proto.parseBulletinTitle(entry); -- 标签
	data.text=Proto.parseBulletinText(entry); -- 正文
	return data;
end

function Proto.writeOnlineBulletin(msg,data)
	Proto.writeOnlineBulletinCaption(msg,data.caption); -- 标识
	Proto.writeBulletinTitle(msg,data.title); -- 标签
	Proto.writeBulletinText(msg,data.text); -- 正文
end

function Proto.parseForbiddenProcessInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 编号
	data.process=Proto.parseString(entry); -- 进程名
	return data;
end

function Proto.getForbiddenProcessInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeForbiddenProcessInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 编号
	Proto.writeString(msg,data.process); -- 进程名
end

function Proto.parseClientConfigScriptInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 编号
	data.fileName=Proto.parseString(entry); -- 文件名
	return data;
end

function Proto.getClientConfigScriptInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeClientConfigScriptInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 编号
	Proto.writeString(msg,data.fileName); -- 文件名
end

function Proto.parseGlobalKeyCodeInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 编号
	data.keyCode=Proto.parseString(entry); -- 键值
	return data;
end

function Proto.getGlobalKeyCodeInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeGlobalKeyCodeInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 编号
	Proto.writeString(msg,data.keyCode); -- 键值
end

function Proto.parseGlobalConfigAddInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.name=Proto.parseString(entry); -- 属性
	data.values=Proto.parseVector(entry,Proto.parseDWORD); -- 值
	data.describe=Proto.parseString(entry); -- 描述
	return data;
end

function Proto.getGlobalConfigAddInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeGlobalConfigAddInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeString(msg,data.name); -- 属性
	Proto.writeVector(msg,data.values,Proto.writeDWORD); -- 值
	Proto.writeString(msg,data.describe); -- 描述
end

