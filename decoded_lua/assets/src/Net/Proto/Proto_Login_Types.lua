-- Net.Proto.Proto_Login_Types

Proto.SS_OFF_LINE	= 0						-- [服务器状态]下线
Proto.SS_ON_LINE	= Proto.SS_OFF_LINE + 1	-- [服务器状态]在线
Proto.RC_OP_GEN	= 0						-- [奖励编码操作类型]生成奖励编码
Proto.RC_OP_EXC	= Proto.RC_OP_GEN + 1	-- [奖励编码操作类型]兑换奖励编码
Proto.RGT_SYSTEM		= 0							-- [奖励编码生成方式]普通系统生成
Proto.RGT_PLAYER		= Proto.RGT_SYSTEM + 1		-- [奖励编码生成方式]玩家生成
Proto.RGT_SYSTEM_LONG	= Proto.RGT_PLAYER + 1		-- [奖励编码生成方式]普通系统生成长期可用
Proto.RGT_COUNT			= Proto.RGT_SYSTEM_LONG + 1	-- [奖励编码生成方式]数量
Proto.RC_NORMAL				= 0								-- [奖励编码类型]普通奖励类型
Proto.RC_ROOKIE_RECOMMAND	= Proto.RC_NORMAL + 1			-- [奖励编码类型]新手推荐奖励
Proto.RC_ROOKIE				= Proto.RC_ROOKIE_RECOMMAND + 1	-- [奖励编码类型]新手奖励
Proto.RC_COUNT				= Proto.RC_ROOKIE + 1			-- [奖励编码类型]数量
Proto.ST_MANAGER	= 0						-- [服务器类型]Manager
Proto.ST_GATE		= Proto.ST_MANAGER + 1	-- [服务器类型]Gate
Proto.ST_AI			= Proto.ST_GATE + 1		-- [服务器类型]AI
Proto.ST_ZONE		= Proto.ST_AI + 1		-- [服务器类型]Zone
Proto.ST_PROCESS	= Proto.ST_ZONE + 1		-- [服务器类型]Process
Proto.ST_FRIEND		= Proto.ST_PROCESS + 1	-- [服务器类型]Friend
Proto.ST_BATTLE		= Proto.ST_FRIEND + 1	-- [服务器类型]Battle
Proto.ST_SNS		= Proto.ST_BATTLE + 1	-- [服务器类型]SNS
Proto.ST_ARENA		= Proto.ST_SNS + 1		-- [服务器类型]Arena
Proto.ST_CHAT		= Proto.ST_ARENA + 1	-- [服务器类型]Chat
Proto.ST_LOGIN		= Proto.ST_CHAT + 1		-- [服务器类型]Login
Proto.ST_LOG		= Proto.ST_LOGIN + 1	-- [服务器类型]Log
Proto.MSPS_NEEDLOGIN	= 0							-- [角色的仓库密码状态,只有在MSPS_NEEDLOGIN的时候才需要输入密码]需要进行密码验证
Proto.MSPS_LOGIN		= Proto.MSPS_NEEDLOGIN + 1	-- [角色的仓库密码状态,只有在MSPS_NEEDLOGIN的时候才需要输入密码]已经验证
Proto.MSPS_EMPTY		= Proto.MSPS_LOGIN + 1		-- [角色的仓库密码状态,只有在MSPS_NEEDLOGIN的时候才需要输入密码]密码为空(无需验证)
Proto.PT_FANGCUN	= 0						-- [平台类型]方寸
Proto.PT_NDCOM		= Proto.PT_FANGCUN + 1	-- [平台类型]91
Proto.PT_JIFENG		= Proto.PT_NDCOM + 1	-- [平台类型]机锋
Proto.PT_DANGLE		= Proto.PT_JIFENG + 1	-- [平台类型]当乐
Proto.PT_UC			= Proto.PT_DANGLE + 1	-- [平台类型]UC
Proto.PT_YUN		= Proto.PT_UC + 1		-- [平台类型]云游游
Proto.PT_APPLE		= Proto.PT_YUN + 1		-- [平台类型]苹果
Proto.PT_FACEBOOK	= Proto.PT_APPLE + 1	-- [平台类型]facebook
Proto.PT_PAYPAL		= Proto.PT_FACEBOOK + 1	-- [平台类型]paypal
Proto.PT_GOOGLE		= Proto.PT_PAYPAL + 1	-- [平台类型]谷歌
Proto.PVT_LOGIN		= 0						-- [平台验证类型]登陆
Proto.PVT_RECHARGE	= Proto.PVT_LOGIN + 1	-- [平台验证类型]充值
Proto.PPT_NONE		= 0						-- []
Proto.PPT_ITEM		= Proto.PPT_NONE + 1	-- []
Proto.PPT_PET		= Proto.PPT_ITEM + 1	-- []
Proto.PPT_PETEQUIP	= Proto.PPT_PET + 1		-- []

function Proto.parseCharBriefInfo(entry)
	local data={};
	data.userID=Proto.parseCharacterID(entry); -- 玩家ID
	data.nickname=Proto.parseNickName(entry); -- 玩家昵称
	data.gender=Proto.parseBYTE(entry); -- 玩家性别(0:女,1:男)
	data.level=Proto.parseWORD(entry); -- 等级
	data.icon=Proto.parseBYTE(entry); -- 头像
	data.vipLevel=Proto.parseBYTE(entry); -- vip等级
	data.chanllenageTimes=Proto.parseDWORD(entry); -- 挑战次数
	data.chanlleangeUserRate=Proto.parseDWORD(entry); -- 挑战好友胜率
	return data;
end

function Proto.writeCharBriefInfo(msg,data)
	Proto.writeCharacterID(msg,data.userID); -- 玩家ID
	Proto.writeNickName(msg,data.nickname); -- 玩家昵称
	Proto.writeBYTE(msg,data.gender); -- 玩家性别(0:女,1:男)
	Proto.writeWORD(msg,data.level); -- 等级
	Proto.writeBYTE(msg,data.icon); -- 头像
	Proto.writeBYTE(msg,data.vipLevel); -- vip等级
	Proto.writeDWORD(msg,data.chanllenageTimes); -- 挑战次数
	Proto.writeDWORD(msg,data.chanlleangeUserRate); -- 挑战好友胜率
end

function Proto.parseCharBaseInfo(entry)
	local data={};
	data.username=Proto.parseUserName(entry); -- 玩家账号
	data.nickname=Proto.parseNickName(entry); -- 玩家昵称
	data.gender=Proto.parseBYTE(entry); -- 玩家性别(0:女,1:男)
	data.country=Proto.parseCountryID(entry); -- 所属国家
	data.g_cash=Proto.parseDWORD(entry); -- 玩家G币
	data.m_cash=Proto.parseDWORD(entry); -- 玩家M币
	data.totalMoney=Proto.parseDWORD(entry); -- 充值总数
	data.vipLevel=Proto.parseBYTE(entry); -- vip等级
	data.charClientflag=Proto.parseDWORD(entry); -- 客户端自定义标志
	data.totalAchivementPoints=Proto.parseDWORD(entry); -- 总成就点
	data.currentAchivementPoints=Proto.parseDWORD(entry); -- 当前成就点
	data.loginCountry=Proto.parseCountryID(entry); -- 所在国家
	data.zone=Proto.parseTownID(entry); -- 所在小镇
	data.teamID=Proto.parseDWORD(entry); -- 组队ID
	data.hasZoneGarden=Proto.parseBYTE(entry); -- 当前小镇有无庄园
	if (data.hasZoneGarden~=0) then
		data.zoneGardenID=Proto.parseGardenID(entry); -- 当前小镇庄园ID
		data.zoneGardenName=Proto.parseGardenName(entry); -- 当前小镇庄园名称
		data.zoneGardenMainWork=Proto.parseBYTE(entry); -- 当前小镇庄园主业
		data.zoneGardenStatus=Proto.parseBYTE(entry); -- 当前小镇庄园状态(0:冻结;非0:活动)
	end
	data.hasConfraternity=Proto.parseBYTE(entry); -- 有无帮会
	if (data.hasConfraternity~=0) then
		data.confraternityID=Proto.parseDWORD(entry); -- 帮会ID
	end
	data.charflag=Proto.parseDWORD(entry); -- 玩家标志信息
	data.isForceLocation=Proto.parseBYTE(entry); -- 是否强制登陆位置
	if (data.isForceLocation~=0) then
		data.loginLocation=Proto.parsePOS2D(entry); -- 强制登陆位置
		data.loginDirect=Proto.parseDirectType(entry); -- 强制登陆方向
	end
	data.hasActiveGarden=Proto.parseBYTE(entry); -- 是否有活动庄园
	if (data.hasActiveGarden~=0) then
		data.activeGardenTown=Proto.parseTownID(entry); -- 活动庄园所在小镇
		data.activeGardenID=Proto.parseGardenID(entry); -- 活动庄园ID
	end
	data.hasMarriage=Proto.parseBYTE(entry); -- 婚否
	if (data.hasMarriage~=0) then
		data.consortID=Proto.parseDWORD(entry); -- 配偶ID
	end
	data.level=Proto.parseWORD(entry); -- 等级
	data.exp=Proto.parseDWORD(entry); -- 经验
	data.actionValue=Proto.parseWORD(entry); -- 体力
	data.actionValueMax=Proto.parseWORD(entry); -- 最大体力
	data.lastActionValueChangeTime=Proto.parseDWORD(entry); -- 体力最后更新时间
	data.lastEatFoodTime=Proto.parseDWORD(entry); -- 食物增加体力最后更新时间
	data.currentFoodType=Proto.parseDWORD(entry); -- 当前食物类型
	data.curFashion=Proto.parseString(entry); -- 当前时装
	return data;
end

function Proto.writeCharBaseInfo(msg,data)
	Proto.writeUserName(msg,data.username); -- 玩家账号
	Proto.writeNickName(msg,data.nickname); -- 玩家昵称
	Proto.writeBYTE(msg,data.gender); -- 玩家性别(0:女,1:男)
	Proto.writeCountryID(msg,data.country); -- 所属国家
	Proto.writeDWORD(msg,data.g_cash); -- 玩家G币
	Proto.writeDWORD(msg,data.m_cash); -- 玩家M币
	Proto.writeDWORD(msg,data.totalMoney); -- 充值总数
	Proto.writeBYTE(msg,data.vipLevel); -- vip等级
	Proto.writeDWORD(msg,data.charClientflag); -- 客户端自定义标志
	Proto.writeDWORD(msg,data.totalAchivementPoints); -- 总成就点
	Proto.writeDWORD(msg,data.currentAchivementPoints); -- 当前成就点
	Proto.writeCountryID(msg,data.loginCountry); -- 所在国家
	Proto.writeTownID(msg,data.zone); -- 所在小镇
	Proto.writeDWORD(msg,data.teamID); -- 组队ID
	Proto.writeBYTE(msg,data.hasZoneGarden); -- 当前小镇有无庄园
	if (data.hasZoneGarden~=0) then
		Proto.writeGardenID(msg,data.zoneGardenID); -- 当前小镇庄园ID
		Proto.writeGardenName(msg,data.zoneGardenName); -- 当前小镇庄园名称
		Proto.writeBYTE(msg,data.zoneGardenMainWork); -- 当前小镇庄园主业
		Proto.writeBYTE(msg,data.zoneGardenStatus); -- 当前小镇庄园状态(0:冻结;非0:活动)
	end
	Proto.writeBYTE(msg,data.hasConfraternity); -- 有无帮会
	if (data.hasConfraternity~=0) then
		Proto.writeDWORD(msg,data.confraternityID); -- 帮会ID
	end
	Proto.writeDWORD(msg,data.charflag); -- 玩家标志信息
	Proto.writeBYTE(msg,data.isForceLocation); -- 是否强制登陆位置
	if (data.isForceLocation~=0) then
		Proto.writePOS2D(msg,data.loginLocation); -- 强制登陆位置
		Proto.writeDirectType(msg,data.loginDirect); -- 强制登陆方向
	end
	Proto.writeBYTE(msg,data.hasActiveGarden); -- 是否有活动庄园
	if (data.hasActiveGarden~=0) then
		Proto.writeTownID(msg,data.activeGardenTown); -- 活动庄园所在小镇
		Proto.writeGardenID(msg,data.activeGardenID); -- 活动庄园ID
	end
	Proto.writeBYTE(msg,data.hasMarriage); -- 婚否
	if (data.hasMarriage~=0) then
		Proto.writeDWORD(msg,data.consortID); -- 配偶ID
	end
	Proto.writeWORD(msg,data.level); -- 等级
	Proto.writeDWORD(msg,data.exp); -- 经验
	Proto.writeWORD(msg,data.actionValue); -- 体力
	Proto.writeWORD(msg,data.actionValueMax); -- 最大体力
	Proto.writeDWORD(msg,data.lastActionValueChangeTime); -- 体力最后更新时间
	Proto.writeDWORD(msg,data.lastEatFoodTime); -- 食物增加体力最后更新时间
	Proto.writeDWORD(msg,data.currentFoodType); -- 当前食物类型
	Proto.writeString(msg,data.curFashion); -- 当前时装
end

function Proto.parsePetBaseInfo(entry)
	local data={};
	data.name=Proto.parseLifeNick(entry); -- 宠物名称
	data.gender=Proto.parseBYTE(entry); -- 宠物性别
	data.level=Proto.parseWORD(entry); -- 等级
	data.natureGene=Proto.parseUnitNatureGene(entry); -- 遗传天性
	data.experience=Proto.parseDWORD(entry); -- 经验值
	data.ownerID=Proto.parseUserID(entry); -- 主人ID
	data.ownerName=Proto.parseNickName(entry); -- 主人昵称
	data.remainingAttribute=Proto.parseWORD(entry); -- 可分配属性
	data.g_cash=Proto.parseDWORD(entry); -- 宠物G币
	data.raceType=Proto.parseDWORD(entry); -- 动物类型
	data.selfAttrib=Proto.parseBYTE(entry); -- 个体值
	data.struggles=Proto.parseStruggles(entry); -- 努力值
	data.assignPoints=Proto.parseAssignPoints(entry); -- 分配值
	data.turnTimes=Proto.parseBYTE(entry); -- 转生次数
	data.preRace=Proto.parseDWORD(entry); -- 转生前种族
	data.turnLevel=Proto.parseDWORD(entry); -- 转生累计等级
	data.turnExp=Proto.parseDWORD(entry); -- 转生累计经验
	data.growth=Proto.parseDWORD(entry); -- 发育度
	data.fatigue=Proto.parseWORD(entry); -- 饥饿度
	data.fatigueUpdateTime=Proto.parseTIME_SEC(entry); -- 饥饿度更新时间
	data.hp=Proto.parseDWORD(entry); -- 当前HP
	data.sp=Proto.parseDWORD(entry); -- 当前SP
	data.hasFoodState=Proto.parseBYTE(entry); -- 是否有食物临时增益状态
	if (data.hasFoodState ~=0) then
		data.foodID=Proto.parseDWORD(entry); -- 临时增益食物ID
	end
	data.homeID=Proto.parseDWORD(entry); -- 宠物家(宠物主人的活动庄园ID,如果没有则为0)
	data.health=Proto.parseDWORD(entry); -- 健康度
	data.power=Proto.parseDWORD(entry); -- 战斗力
	return data;
end

function Proto.writePetBaseInfo(msg,data)
	Proto.writeLifeNick(msg,data.name); -- 宠物名称
	Proto.writeBYTE(msg,data.gender); -- 宠物性别
	Proto.writeWORD(msg,data.level); -- 等级
	Proto.writeUnitNatureGene(msg,data.natureGene); -- 遗传天性
	Proto.writeDWORD(msg,data.experience); -- 经验值
	Proto.writeUserID(msg,data.ownerID); -- 主人ID
	Proto.writeNickName(msg,data.ownerName); -- 主人昵称
	Proto.writeWORD(msg,data.remainingAttribute); -- 可分配属性
	Proto.writeDWORD(msg,data.g_cash); -- 宠物G币
	Proto.writeDWORD(msg,data.raceType); -- 动物类型
	Proto.writeBYTE(msg,data.selfAttrib); -- 个体值
	Proto.writeStruggles(msg,data.struggles); -- 努力值
	Proto.writeAssignPoints(msg,data.assignPoints); -- 分配值
	Proto.writeBYTE(msg,data.turnTimes); -- 转生次数
	Proto.writeDWORD(msg,data.preRace); -- 转生前种族
	Proto.writeDWORD(msg,data.turnLevel); -- 转生累计等级
	Proto.writeDWORD(msg,data.turnExp); -- 转生累计经验
	Proto.writeDWORD(msg,data.growth); -- 发育度
	Proto.writeWORD(msg,data.fatigue); -- 饥饿度
	Proto.writeTIME_SEC(msg,data.fatigueUpdateTime); -- 饥饿度更新时间
	Proto.writeDWORD(msg,data.hp); -- 当前HP
	Proto.writeDWORD(msg,data.sp); -- 当前SP
	Proto.writeBYTE(msg,data.hasFoodState); -- 是否有食物临时增益状态
	if (data.hasFoodState ~=0) then
		Proto.writeDWORD(msg,data.foodID); -- 临时增益食物ID
	end
	Proto.writeDWORD(msg,data.homeID); -- 宠物家(宠物主人的活动庄园ID,如果没有则为0)
	Proto.writeDWORD(msg,data.health); -- 健康度
	Proto.writeDWORD(msg,data.power); -- 战斗力
end

function Proto.parseNpcBaseInfo(entry)
	local data={};
	data.name=Proto.parseLifeNick(entry); -- NPC名称
	data.level=Proto.parseWORD(entry); -- 等级
	data.experience=Proto.parseDWORD(entry); -- 经验值
	data.g_cash=Proto.parseDWORD(entry); -- NPCG币
	data.raceType=Proto.parseDWORD(entry); -- 动物类型
	data.selfAttrib=Proto.parseBYTE(entry); -- 个体值
	data.struggle=Proto.parseWORD(entry); -- 努力值
	return data;
end

function Proto.writeNpcBaseInfo(msg,data)
	Proto.writeLifeNick(msg,data.name); -- NPC名称
	Proto.writeWORD(msg,data.level); -- 等级
	Proto.writeDWORD(msg,data.experience); -- 经验值
	Proto.writeDWORD(msg,data.g_cash); -- NPCG币
	Proto.writeDWORD(msg,data.raceType); -- 动物类型
	Proto.writeBYTE(msg,data.selfAttrib); -- 个体值
	Proto.writeWORD(msg,data.struggle); -- 努力值
end

function Proto.parseServerInfo(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- 服务器类型
	data.ip=Proto.parseDWORD(entry); -- IP
	data.port=Proto.parseWORD(entry); -- 端口
	data.players=Proto.parseDWORD(entry); -- 玩家数
	data.npcs=Proto.parseDWORD(entry); -- NPC数
	data.pets=Proto.parseDWORD(entry); -- 宠物数
	return data;
end

function Proto.writeServerInfo(msg,data)
	Proto.writeBYTE(msg,data.type); -- 服务器类型
	Proto.writeDWORD(msg,data.ip); -- IP
	Proto.writeWORD(msg,data.port); -- 端口
	Proto.writeDWORD(msg,data.players); -- 玩家数
	Proto.writeDWORD(msg,data.npcs); -- NPC数
	Proto.writeDWORD(msg,data.pets); -- 宠物数
end

function Proto.parseCullPetInfo(entry)
	local data={};
	data.id=Proto.parseBYTE(entry); -- 编号
	data.itemGenerateID=Proto.parseDWORD(entry); -- 道具生成规则ID
	return data;
end

function Proto.getCullPetInfoIDLen()
	return Proto.getBYTELen();
end

function Proto.writeCullPetInfo(msg,data)
	Proto.writeBYTE(msg,data.id); -- 编号
	Proto.writeDWORD(msg,data.itemGenerateID); -- 道具生成规则ID
end

function Proto.parseFriendBaseInfo(entry)
	local data={};
	data.nickname=Proto.parseNickName(entry); -- 玩家昵称
	data.gender=Proto.parseBYTE(entry); -- 玩家性别(0:女,1:男)
	data.country=Proto.parseCountryID(entry); -- 所属国家
	return data;
end

function Proto.writeFriendBaseInfo(msg,data)
	Proto.writeNickName(msg,data.nickname); -- 玩家昵称
	Proto.writeBYTE(msg,data.gender); -- 玩家性别(0:女,1:男)
	Proto.writeCountryID(msg,data.country); -- 所属国家
end

function Proto.parseGameZoneInfo(entry)
	local data={};
	data.managerHandle=Proto.parseHandleType(entry); -- handle
	data.managerSerial=Proto.parseSerialType(entry); -- serial
	data.zoneID=Proto.parseWORD(entry); -- 大区编号
	data.desc=Proto.parseString(entry); -- 描述
	return data;
end

function Proto.writeGameZoneInfo(msg,data)
	Proto.writeHandleType(msg,data.managerHandle); -- handle
	Proto.writeSerialType(msg,data.managerSerial); -- serial
	Proto.writeWORD(msg,data.zoneID); -- 大区编号
	Proto.writeString(msg,data.desc); -- 描述
end

function Proto.parseGateServerInfo(entry)
	local data={};
	data.ip=Proto.parseIPDesc(entry); -- ip
	data.port=Proto.parseDWORD(entry); -- 端口
	return data;
end

function Proto.writeGateServerInfo(msg,data)
	Proto.writeIPDesc(msg,data.ip); -- ip
	Proto.writeDWORD(msg,data.port); -- 端口
end

function Proto.parseRewardCodingInfo(entry)
	local data={};
	data.rewardType=Proto.parseWORD(entry); -- 奖励编码类型
	data.rewardCode=Proto.parseString(entry); -- 奖励编码
	return data;
end

function Proto.writeRewardCodingInfo(msg,data)
	Proto.writeWORD(msg,data.rewardType); -- 奖励编码类型
	Proto.writeString(msg,data.rewardCode); -- 奖励编码
end

function Proto.parseRewardCodingConfig(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 编码
	data.rewardType=Proto.parseWORD(entry); -- 奖励编码类型
	data.rawardItem=Proto.parseDWORD(entry); -- 奖励道具
	data.rawardItemCount=Proto.parseWORD(entry); -- 奖励道具数量
	data.rewardGenType=Proto.parseBYTE(entry); -- 奖励编码生成类型
	data.rewardCodeDesc=Proto.parseString(entry); -- 奖励编码描述
	return data;
end

function Proto.getRewardCodingConfigIDLen()
	return Proto.getWORDLen();
end

function Proto.writeRewardCodingConfig(msg,data)
	Proto.writeWORD(msg,data.id); -- 编码
	Proto.writeWORD(msg,data.rewardType); -- 奖励编码类型
	Proto.writeDWORD(msg,data.rawardItem); -- 奖励道具
	Proto.writeWORD(msg,data.rawardItemCount); -- 奖励道具数量
	Proto.writeBYTE(msg,data.rewardGenType); -- 奖励编码生成类型
	Proto.writeString(msg,data.rewardCodeDesc); -- 奖励编码描述
end

function Proto.parsePlatformValidateInfo_BODY_Fangcun(entry)
	local data={};
	data.username=Proto.parseZoic_StringForUnion_20_(entry); -- 用户名
	data.password=Proto.parseZoic_StringForUnion_20_(entry); -- 密码
	return data;
end

function Proto.writePlatformValidateInfo_BODY_Fangcun(msg,data)
	Proto.writeZoic_StringForUnion_20_(msg,data.username); -- 用户名
	Proto.writeZoic_StringForUnion_20_(msg,data.password); -- 密码
end

function Proto.parsePlatformValidateInfo_BODY_NdComLogin(entry)
	local data={};
	data.uin=Proto.parseZoic_StringForUnion_20_(entry); -- 91账号ID
	data.sessionID=Proto.parseZoic_StringForUnion_40_(entry); -- SessinID
	return data;
end

function Proto.writePlatformValidateInfo_BODY_NdComLogin(msg,data)
	Proto.writeZoic_StringForUnion_20_(msg,data.uin); -- 91账号ID
	Proto.writeZoic_StringForUnion_40_(msg,data.sessionID); -- SessinID
end

function Proto.parsePlatformValidateInfo_BODY_NdComRecharge(entry)
	local data={};
	data.cooOrderSerial=Proto.parseZoic_StringForUnion_40_(entry); -- 商户订单号
	return data;
end

function Proto.writePlatformValidateInfo_BODY_NdComRecharge(msg,data)
	Proto.writeZoic_StringForUnion_40_(msg,data.cooOrderSerial); -- 商户订单号
end

function Proto.parsePlatformValidateInfo_BODY_GfanLogin(entry)
	local data={};
	data.username=Proto.parseZoic_StringForUnion_50_(entry); -- 用户名
	data.password=Proto.parseZoic_StringForUnion_40_(entry); -- 密码
	return data;
end

function Proto.writePlatformValidateInfo_BODY_GfanLogin(msg,data)
	Proto.writeZoic_StringForUnion_50_(msg,data.username); -- 用户名
	Proto.writeZoic_StringForUnion_40_(msg,data.password); -- 密码
end

function Proto.parsePlatformValidateInfo_BODY_GfanRecharge(entry)
	local data={};
	data.orderId=Proto.parseZoic_StringForUnion_40_(entry); -- 订单号
	return data;
end

function Proto.writePlatformValidateInfo_BODY_GfanRecharge(msg,data)
	Proto.writeZoic_StringForUnion_40_(msg,data.orderId); -- 订单号
end

function Proto.parsePlatformValidateInfo_BODY_UcLogin(entry)
	local data={};
	data.sessionId=Proto.parseZoic_StringForUnion_40_(entry); -- 会话ID
	return data;
end

function Proto.writePlatformValidateInfo_BODY_UcLogin(msg,data)
	Proto.writeZoic_StringForUnion_40_(msg,data.sessionId); -- 会话ID
end

function Proto.parsePlatformValidateInfo_BODY_UcRecharge(entry)
	local data={};
	data.orderId=Proto.parseZoic_StringForUnion_40_(entry); -- 订单号
	return data;
end

function Proto.writePlatformValidateInfo_BODY_UcRecharge(msg,data)
	Proto.writeZoic_StringForUnion_40_(msg,data.orderId); -- 订单号
end

function Proto.parsePlatformValidateInfo_BODY_YunLogin(entry)
	local data={};
	data.userId=Proto.parseZoic_StringForUnion_40_(entry); -- 用户ID
	data.channelID=Proto.parseWORD(entry); -- 渠道ID
	return data;
end

function Proto.writePlatformValidateInfo_BODY_YunLogin(msg,data)
	Proto.writeZoic_StringForUnion_40_(msg,data.userId); -- 用户ID
	Proto.writeWORD(msg,data.channelID); -- 渠道ID
end

function Proto.parsePlatformValidateInfo_BODY_YunRecharge(entry)
	local data={};
	data.orderId=Proto.parseZoic_StringForUnion_40_(entry); -- 订单号
	return data;
end

function Proto.writePlatformValidateInfo_BODY_YunRecharge(msg,data)
	Proto.writeZoic_StringForUnion_40_(msg,data.orderId); -- 订单号
end

function Proto.parsePlatformValidateInfo_BODY_FacebookLogin(entry)
	local data={};
	data.userId=Proto.parseZoic_StringForUnion_50_(entry); -- 用户ID
	data.token=Proto.parseZoic_StringForUnion_300_(entry); -- 登陆令牌
	return data;
end

function Proto.writePlatformValidateInfo_BODY_FacebookLogin(msg,data)
	Proto.writeZoic_StringForUnion_50_(msg,data.userId); -- 用户ID
	Proto.writeZoic_StringForUnion_300_(msg,data.token); -- 登陆令牌
end

function Proto.parsePlatformValidateInfo(entry)
	local data={};
	data.platformType=Proto.parseBYTE(entry); -- 平台类型,
	data.validateType=Proto.parseBYTE(entry); -- 平台验证类型,
	data.body={}; -- 
	if (data.platformType==Proto.PT_FANGCUN) then
		data.body.fangcun=Proto.parsePlatformValidateInfo_BODY_Fangcun(entry); -- 方寸
	end
	if (data.platformType==Proto.PVT_LOGIN) then
		data.body.ndComLogin=Proto.parsePlatformValidateInfo_BODY_NdComLogin(entry); -- 91登陆
	end
	if (data.platformType==Proto.PVT_RECHARGE) then
		data.body.ndComRecharge=Proto.parsePlatformValidateInfo_BODY_NdComRecharge(entry); -- 91充值
	end
	if (data.platformType==Proto.PVT_LOGIN) then
		data.body.gfanLogin=Proto.parsePlatformValidateInfo_BODY_GfanLogin(entry); -- 机锋登陆
	end
	if (data.platformType==Proto.PVT_RECHARGE) then
		data.body.gfanRecharge=Proto.parsePlatformValidateInfo_BODY_GfanRecharge(entry); -- 机锋充值
	end
	if (data.platformType==Proto.PVT_LOGIN) then
		data.body.ucLogin=Proto.parsePlatformValidateInfo_BODY_UcLogin(entry); -- UC登陆
	end
	if (data.platformType==Proto.PVT_RECHARGE) then
		data.body.ucRecharge=Proto.parsePlatformValidateInfo_BODY_UcRecharge(entry); -- UC充值
	end
	if (data.platformType==Proto.PVT_LOGIN) then
		data.body.yunLogin=Proto.parsePlatformValidateInfo_BODY_YunLogin(entry); -- Yun登陆
	end
	if (data.platformType==Proto.PVT_RECHARGE) then
		data.body.yunRecharge=Proto.parsePlatformValidateInfo_BODY_YunRecharge(entry); -- Yun充值
	end
	if (data.platformType==Proto.PVT_LOGIN) then
		data.body.facebookLogin=Proto.parsePlatformValidateInfo_BODY_FacebookLogin(entry); -- facebook登陆
	end
	if (data.validateType==Proto.PVT_LOGIN) then
		data.innerCode=Proto.parseString(entry); -- 内侧激活码
	end
	return data;
end

function Proto.writePlatformValidateInfo(msg,data)
	Proto.writeBYTE(msg,data.platformType); -- 平台类型,
	Proto.writeBYTE(msg,data.validateType); -- 平台验证类型,
	if (data.platformType==Proto.PT_FANGCUN) then
		Proto.writePlatformValidateInfo_BODY_Fangcun(msg,data.body.fangcun); -- 方寸
	end
	if (data.platformType==Proto.PVT_LOGIN) then
		Proto.writePlatformValidateInfo_BODY_NdComLogin(msg,data.body.ndComLogin); -- 91登陆
	end
	if (data.platformType==Proto.PVT_RECHARGE) then
		Proto.writePlatformValidateInfo_BODY_NdComRecharge(msg,data.body.ndComRecharge); -- 91充值
	end
	if (data.platformType==Proto.PVT_LOGIN) then
		Proto.writePlatformValidateInfo_BODY_GfanLogin(msg,data.body.gfanLogin); -- 机锋登陆
	end
	if (data.platformType==Proto.PVT_RECHARGE) then
		Proto.writePlatformValidateInfo_BODY_GfanRecharge(msg,data.body.gfanRecharge); -- 机锋充值
	end
	if (data.platformType==Proto.PVT_LOGIN) then
		Proto.writePlatformValidateInfo_BODY_UcLogin(msg,data.body.ucLogin); -- UC登陆
	end
	if (data.platformType==Proto.PVT_RECHARGE) then
		Proto.writePlatformValidateInfo_BODY_UcRecharge(msg,data.body.ucRecharge); -- UC充值
	end
	if (data.platformType==Proto.PVT_LOGIN) then
		Proto.writePlatformValidateInfo_BODY_YunLogin(msg,data.body.yunLogin); -- Yun登陆
	end
	if (data.platformType==Proto.PVT_RECHARGE) then
		Proto.writePlatformValidateInfo_BODY_YunRecharge(msg,data.body.yunRecharge); -- Yun充值
	end
	if (data.platformType==Proto.PVT_LOGIN) then
		Proto.writePlatformValidateInfo_BODY_FacebookLogin(msg,data.body.facebookLogin); -- facebook登陆
	end
	if (data.validateType==Proto.PVT_LOGIN) then
		Proto.writeString(msg,data.innerCode); -- 内侧激活码
	end
end

function Proto.parsePlatformRechargeInfo(entry)
	local data={};
	data.rechargeId=Proto.parseDWORD(entry); -- 充值记录ID
	data.charId=Proto.parseDWORD(entry); -- 角色ID
	data.mCash=Proto.parseDWORD(entry); -- 游戏币
	return data;
end

function Proto.writePlatformRechargeInfo(msg,data)
	Proto.writeDWORD(msg,data.rechargeId); -- 充值记录ID
	Proto.writeDWORD(msg,data.charId); -- 角色ID
	Proto.writeDWORD(msg,data.mCash); -- 游戏币
end

function Proto.parsePasswordGiftInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 
	data.password=Proto.parseString(entry); -- 口令
	data.gCash=Proto.parseDWORD(entry); -- 奖励游戏币
	data.startTime=Proto.parseString(entry); -- 开始时间
	data.endTime=Proto.parseString(entry); -- 有效期
	return data;
end

function Proto.getPasswordGiftInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePasswordGiftInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 
	Proto.writeString(msg,data.password); -- 口令
	Proto.writeDWORD(msg,data.gCash); -- 奖励游戏币
	Proto.writeString(msg,data.startTime); -- 开始时间
	Proto.writeString(msg,data.endTime); -- 有效期
end

function Proto.parsePasswordProductInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 
	data.group=Proto.parseDWORD(entry); -- 
	data.productType=Proto.parseDWORD(entry); -- 
	data.productId=Proto.parseDWORD(entry); -- 
	data.num=Proto.parseDWORD(entry); -- 
	data.params=Proto.parseString(entry); -- 
	data.weight=Proto.parseDWORD(entry); -- 
	data.passwordCoin=Proto.parseDWORD(entry); -- 
	return data;
end

function Proto.getPasswordProductInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePasswordProductInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 
	Proto.writeDWORD(msg,data.group); -- 
	Proto.writeDWORD(msg,data.productType); -- 
	Proto.writeDWORD(msg,data.productId); -- 
	Proto.writeDWORD(msg,data.num); -- 
	Proto.writeString(msg,data.params); -- 
	Proto.writeDWORD(msg,data.weight); -- 
	Proto.writeDWORD(msg,data.passwordCoin); -- 
end

