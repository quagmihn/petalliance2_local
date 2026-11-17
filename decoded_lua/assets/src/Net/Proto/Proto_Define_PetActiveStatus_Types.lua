-- Net.Proto.Proto_Define_PetActiveStatus_Types

Proto.PAS_SLEEP				= 0								-- [宠物活动状态]不活动
Proto.PAS_ACTIVE			= Proto.PAS_SLEEP + 1			-- [宠物活动状态]活动
Proto.PAS_INBAG				= Proto.PAS_ACTIVE + 1			-- [宠物活动状态]在袋中
Proto.PAS_DEATH				= Proto.PAS_INBAG + 1			-- [宠物活动状态]死亡
Proto.PAS_INWAREHOUSE		= Proto.PAS_DEATH + 1			-- [宠物活动状态]在仓库中
Proto.PAS_DISCARD			= Proto.PAS_INWAREHOUSE + 1		-- [宠物活动状态]丢弃
Proto.PAS_FUSION			= Proto.PAS_DISCARD + 1			-- [宠物活动状态]被献祭
Proto.PAS_INDORM			= Proto.PAS_FUSION + 1			-- [宠物活动状态]在宿舍中
Proto.PAS_SACRED			= Proto.PAS_INDORM + 1			-- [宠物活动状态]被融合
Proto.PAS_INTG				= Proto.PAS_SACRED + 1			-- [宠物活动状态]在训练场中
Proto.PAS_TG_COMPLETE		= Proto.PAS_INTG + 1			-- [宠物活动状态]训练完成
Proto.PAS_INHANGUP			= Proto.PAS_TG_COMPLETE + 1		-- [宠物活动状态]挂机中
Proto.PAS_HANGUP_COMPLETE	= Proto.PAS_INHANGUP + 1		-- [宠物活动状态]挂机完成
Proto.PAS_EATED				= Proto.PAS_HANGUP_COMPLETE + 1	-- [宠物活动状态]被吃掉
Proto.PAS_IMMOLATED			= Proto.PAS_EATED + 1			-- [宠物活动状态]被献祭
Proto.PAS_COUNT				= Proto.PAS_IMMOLATED + 1		-- [宠物活动状态]状态总数

