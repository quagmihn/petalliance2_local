-- Net.Proto.Proto_InstantTactic_Types

Proto.AGST_STOP		= 0						-- []
Proto.AGST_MOVING	= Proto.AGST_STOP + 1	-- []
Proto.AGST_BATTLE	= Proto.AGST_MOVING + 1	-- []
Proto.AGST_CAMP		= Proto.AGST_BATTLE + 1	-- []
Proto.ILTT_ENTIRE	= 0						-- []
Proto.ILTT_BEGIN	= Proto.ILTT_ENTIRE + 1	-- []
Proto.ILTT_TARGET	= Proto.ILTT_BEGIN + 1	-- []
Proto.ILTT_THROUGH	= Proto.ILTT_TARGET + 1	-- []

function Proto.parseInstantTacticCountry(entry)
	local data={};
	data.id=Proto.parseInstantTacticID(entry); -- 战场ID
	data.country=Proto.parseCountryID(entry); -- 国家ID
	return data;
end

function Proto.getInstantTacticCountryIDLen()
	return Proto.getInstantTacticIDLen();
end

function Proto.writeInstantTacticCountry(msg,data)
	Proto.writeInstantTacticID(msg,data.id); -- 战场ID
	Proto.writeCountryID(msg,data.country); -- 国家ID
end

function Proto.parseInstantTacticTypeInfo(entry)
	local data={};
	data.id=Proto.parseInstantTacticStyle(entry); -- 类型ID
	data.name=Proto.parseString(entry); -- 名称
	data.map=Proto.parseString(entry); -- 地形文件
	return data;
end

function Proto.getInstantTacticTypeInfoIDLen()
	return Proto.getInstantTacticStyleLen();
end

function Proto.writeInstantTacticTypeInfo(msg,data)
	Proto.writeInstantTacticStyle(msg,data.id); -- 类型ID
	Proto.writeString(msg,data.name); -- 名称
	Proto.writeString(msg,data.map); -- 地形文件
end

function Proto.parseInstantTacticCampInfo(entry)
	local data={};
	data.id=Proto.parseInstantTacticStyle(entry); -- 类型ID
	data.name=Proto.parseString(entry); -- 名称
	data.map=Proto.parseString(entry); -- 地形文件
	data.initLocation=Proto.parsePOS2D(entry); -- 初始位置
	data.initDirect=Proto.parseDirectType(entry); -- 初始方向
	return data;
end

function Proto.getInstantTacticCampInfoIDLen()
	return Proto.getInstantTacticStyleLen();
end

function Proto.writeInstantTacticCampInfo(msg,data)
	Proto.writeInstantTacticStyle(msg,data.id); -- 类型ID
	Proto.writeString(msg,data.name); -- 名称
	Proto.writeString(msg,data.map); -- 地形文件
	Proto.writePOS2D(msg,data.initLocation); -- 初始位置
	Proto.writeDirectType(msg,data.initDirect); -- 初始方向
end

function Proto.parseCountryWithRelation(entry)
	local data={};
	data.country=Proto.parseCountryID(entry); -- 参与国度
	data.allies=Proto.parseVector(entry,Proto.parseCountryID); -- 友好的国家
	return data;
end

function Proto.writeCountryWithRelation(msg,data)
	Proto.writeCountryID(msg,data.country); -- 参与国度
	Proto.writeVector(msg,data.allies,Proto.writeCountryID); -- 友好的国家
end

function Proto.parseConflictCountrys(entry)
	local data={};
	data.countrys=Proto.parseVector(entry,Proto.parseCountryWithRelation); -- 敌对国度
	return data;
end

function Proto.writeConflictCountrys(msg,data)
	Proto.writeVector(msg,data.countrys,Proto.writeCountryWithRelation); -- 敌对国度
end

function Proto.parseInstantTacticBrief(entry)
	local data={};
	data.id=Proto.parseInstantTacticID(entry); -- 即时战略战场ID
	data.style=Proto.parseInstantTacticStyle(entry); -- 类型
	data.conflict=Proto.parseConflictCountrys(entry); -- 战阵参与国家
	return data;
end

function Proto.getInstantTacticBriefIDLen()
	return Proto.getInstantTacticIDLen();
end

function Proto.writeInstantTacticBrief(msg,data)
	Proto.writeInstantTacticID(msg,data.id); -- 即时战略战场ID
	Proto.writeInstantTacticStyle(msg,data.style); -- 类型
	Proto.writeConflictCountrys(msg,data.conflict); -- 战阵参与国家
end

function Proto.parseTacticState(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 状态ID
	data.power=Proto.parseshort(entry); -- 强度
	data.timeLimit=Proto.parseTIME_SEC(entry); -- 到期时间
	data.castArmy=Proto.parseArmyGroupID(entry); -- 施展方
	return data;
end

function Proto.getTacticStateIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeTacticState(msg,data)
	Proto.writeDWORD(msg,data.id); -- 状态ID
	Proto.writeshort(msg,data.power); -- 强度
	Proto.writeTIME_SEC(msg,data.timeLimit); -- 到期时间
	Proto.writeArmyGroupID(msg,data.castArmy); -- 施展方
end

function Proto.parseTacticArmyAttrib(entry)
	local data={};
	data.eyeshotRange=Proto.parseint(entry); -- 视野
	data.moveSpeed=Proto.parseint(entry); -- 基本移动速度(单位时间移动的距离)
	data.contactRange=Proto.parseshort(entry); -- 冲突范围
	data.covert=Proto.parseshort(entry); -- 隐蔽能力
	data.detect=Proto.parseshort(entry); -- 探测能力
	return data;
end

function Proto.writeTacticArmyAttrib(msg,data)
	Proto.writeint(msg,data.eyeshotRange); -- 视野
	Proto.writeint(msg,data.moveSpeed); -- 基本移动速度(单位时间移动的距离)
	Proto.writeshort(msg,data.contactRange); -- 冲突范围
	Proto.writeshort(msg,data.covert); -- 隐蔽能力
	Proto.writeshort(msg,data.detect); -- 探测能力
end

function Proto.parseArmyGroupBrief(entry)
	local data={};
	data.id=Proto.parseArmyGroupID(entry); -- 编号
	data.country=Proto.parseCountryID(entry); -- 所属国度
	data.leaderID=Proto.parseDWORD(entry); -- 长官ID
	data.memberCount=Proto.parseWORD(entry); -- 成员ID
	data.states=Proto.parseVector(entry,Proto.parseTacticState); -- 状态
	data.basicAttrib=Proto.parseTacticArmyAttrib(entry); -- 基本属性值
	return data;
end

function Proto.getArmyGroupBriefIDLen()
	return Proto.getArmyGroupIDLen();
end

function Proto.writeArmyGroupBrief(msg,data)
	Proto.writeArmyGroupID(msg,data.id); -- 编号
	Proto.writeCountryID(msg,data.country); -- 所属国度
	Proto.writeDWORD(msg,data.leaderID); -- 长官ID
	Proto.writeWORD(msg,data.memberCount); -- 成员ID
	Proto.writeVector(msg,data.states,Proto.writeTacticState); -- 状态
	Proto.writeTacticArmyAttrib(msg,data.basicAttrib); -- 基本属性值
end

function Proto.parseTacticLocation(entry)
	local data={};
	data.pos=Proto.parsePOS2D(entry); -- 所处位置
	data.dir=Proto.parseDirectType(entry); -- 方向
	return data;
end

function Proto.writeTacticLocation(msg,data)
	Proto.writePOS2D(msg,data.pos); -- 所处位置
	Proto.writeDirectType(msg,data.dir); -- 方向
end

function Proto.parseArmyMemberBrief(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 角色ID
	data.states=Proto.parseVector(entry,Proto.parseTacticState); -- 状态
	return data;
end

function Proto.getArmyMemberBriefIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeArmyMemberBrief(msg,data)
	Proto.writeDWORD(msg,data.id); -- 角色ID
	Proto.writeVector(msg,data.states,Proto.writeTacticState); -- 状态
end

function Proto.parseLineTrack_BODY_Entire(entry)
	local data={};
	data.startPos=Proto.parsePOS2D(entry); -- 起点位置
	data.endPos=Proto.parsePOS2D(entry); -- 落点位置
	return data;
end

function Proto.writeLineTrack_BODY_Entire(msg,data)
	Proto.writePOS2D(msg,data.startPos); -- 起点位置
	Proto.writePOS2D(msg,data.endPos); -- 落点位置
end

function Proto.parseLineTrack_BODY_Begin(entry)
	local data={};
	data.startPos=Proto.parsePOS2D(entry); -- 起点位置
	data.dir=Proto.parseDirectType(entry); -- 方向
	return data;
end

function Proto.writeLineTrack_BODY_Begin(msg,data)
	Proto.writePOS2D(msg,data.startPos); -- 起点位置
	Proto.writeDirectType(msg,data.dir); -- 方向
end

function Proto.parseLineTrack_BODY_Target(entry)
	local data={};
	data.endPos=Proto.parsePOS2D(entry); -- 目标位置
	data.dir=Proto.parseDirectType(entry); -- 方向
	return data;
end

function Proto.writeLineTrack_BODY_Target(msg,data)
	Proto.writePOS2D(msg,data.endPos); -- 目标位置
	Proto.writeDirectType(msg,data.dir); -- 方向
end

function Proto.parseLineTrack_BODY_Through(entry)
	local data={};
	data.passPos=Proto.parsePOS2D(entry); -- 路过位置
	data.dir=Proto.parseDirectType(entry); -- 方向
	return data;
end

function Proto.writeLineTrack_BODY_Through(msg,data)
	Proto.writePOS2D(msg,data.passPos); -- 路过位置
	Proto.writeDirectType(msg,data.dir); -- 方向
end

function Proto.parseLineTrack(entry)
	local data={};
	data.style=Proto.parseBYTE(entry); -- 类型
	data.body={}; -- 
	if (data.style==Proto.ILTT_ENTIRE) then
		data.body.entire=Proto.parseLineTrack_BODY_Entire(entry); -- 全部
	end
	if (data.style==Proto.ILTT_BEGIN) then
		data.body.begin=Proto.parseLineTrack_BODY_Begin(entry); -- 起点
	end
	if (data.style==Proto.ILTT_TARGET) then
		data.body.target=Proto.parseLineTrack_BODY_Target(entry); -- 终点
	end
	if (data.style==Proto.ILTT_THROUGH) then
		data.body.through=Proto.parseLineTrack_BODY_Through(entry); -- 经过
	end
	return data;
end

function Proto.writeLineTrack(msg,data)
	Proto.writeBYTE(msg,data.style); -- 类型
	if (data.style==Proto.ILTT_ENTIRE) then
		Proto.writeLineTrack_BODY_Entire(msg,data.body.entire); -- 全部
	end
	if (data.style==Proto.ILTT_BEGIN) then
		Proto.writeLineTrack_BODY_Begin(msg,data.body.begin); -- 起点
	end
	if (data.style==Proto.ILTT_TARGET) then
		Proto.writeLineTrack_BODY_Target(msg,data.body.target); -- 终点
	end
	if (data.style==Proto.ILTT_THROUGH) then
		Proto.writeLineTrack_BODY_Through(msg,data.body.through); -- 经过
	end
end

function Proto.parseArmyGroupInTactic(entry)
	local data={};
	data.brief=Proto.parseArmyGroupBrief(entry); -- 简要信息
	data.location=Proto.parseTacticLocation(entry); -- 位置
	data.status=Proto.parseBYTE(entry); -- 状态
	return data;
end

function Proto.writeArmyGroupInTactic(msg,data)
	Proto.writeArmyGroupBrief(msg,data.brief); -- 简要信息
	Proto.writeTacticLocation(msg,data.location); -- 位置
	Proto.writeBYTE(msg,data.status); -- 状态
end

function Proto.parseInstantTacticScan(entry)
	local data={};
	data.groups=Proto.parseVector(entry,Proto.parseArmyGroupInTactic); -- 军团
	return data;
end

function Proto.writeInstantTacticScan(msg,data)
	Proto.writeVector(msg,data.groups,Proto.writeArmyGroupInTactic); -- 军团
end

