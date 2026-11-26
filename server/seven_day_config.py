"""SevenDaysActivity offers backed by authoritative character state."""
from client_config import table

SUPPORTED_TYPES = {1, 3, 7, 10, 36}


async def eligible(conn, char_id, level, task_type, conditions):
    if task_type in (1, 7):
        return True
    if task_type == 10:  # RenWuDengJiWatcher
        return len(conditions) == 1 and 0 < conditions[0] <= level
    if task_type == 36 and len(conditions) == 2:  # CWShouJiWatcher
        count, grade = conditions
        templates = [template for template, pet in table("PokemonInfo").items()
                     if grade == 0 or pet["rarePoint"] == grade]
        owned = await conn.fetchval(
            "SELECT count(*) FROM pets WHERE char_id=$1 AND pet_template_id=ANY($2::int[])",
            char_id, templates)
        return 0 < count <= owned
    if task_type == 3 and len(conditions) == 1:  # FubenTongGuanWatcher
        difficulty, base = divmod(conditions[0], 10_000)
        configured = table("AdventureInfo").get(base, {}).get("diffcultType", 0)
        if not 0 <= difficulty < configured <= 3:
            return False
        variants = [base + offset * 10_000 for offset in range(configured)]
        cleared = await conn.fetchval(
            """SELECT count(*) FROM character_adventure_clears WHERE char_id=$1
               AND adventure_id=ANY($2::int[]) AND star_mask & 8 <> 0""", char_id, variants)
        return cleared >= difficulty + 1
    return False
