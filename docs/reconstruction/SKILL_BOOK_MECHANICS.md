# Skill learning and enhancement

Talent/support rows in PetSkillInfo use type 7 or 8. The client uses request
1302 with the owned Pet UID and zero-based skill slot and expects ACK 1371
with the new skill ID. The server advances the same skill family by one
level, validates types and matches the client's Skill Shard cost from
GlobalConfigAddInfo 6401–6404 and 6551–6556. Pet update 3141 follows the
inventory change. PostgreSQL verified Panda talent 3761 → 3762 using
42 shards and preserved the new ID.

Regular skill levels consume an eligible skill book and a shard quantity.
Skill Gacha can grant configured book items 20171, 20230, 20307 and 20043
as well as Skill Shards. ItemInfo links the books to PetSkillInfo.
Login uses 583 and changed book counts use 133. Request 1282 carries
the Pet UID, slot and selected book. Server validation covers the active,
profound and passive slot types, element restrictions, dedicated Pet
whitelists, passive rank and duplicate families. PostgreSQL locks the
Pet and costs, persists the new ID, and returns 3141 and ACK 1369.
Request 1302 uses the same transaction for level increases with the
original book and shard costs.

The integration covers failed compatibility and insufficient cost with no
debit, concurrent replay for an identical replacement, learn 1711,
upgrade 1712 for one book and 15 shards, and saved profound and passive
slots. Recipes for crafting a book and education-specific skill flows
remain open. Several separately configured chest labels resolve to a
potion or Pet fragment in the linked RewardInfo records.

Waydroid QA character 4 drew real Jumpkick and passive books from Skill
x10. Zupedo UID 6 learned Jumpkick in its empty active slot and the
client rendered the skill acquisition. The follow-up 632 progress save
exposed an asyncpg parameter type error that triggered a reconnect loop.
The server now binds both JSON arguments as text and tests its ACK 630.
After restarting the official server the Pet still had Jumpkick. The
client upgraded it to level 2 with the last matching book and 15 shards.
ACK 1371 returned skill 1712 and PostgreSQL retained it in that slot.
