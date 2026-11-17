CREATE TABLE IF NOT EXISTS accounts (
    user_id BIGSERIAL PRIMARY KEY,
    username TEXT NOT NULL UNIQUE,
    token TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS device_bindings (
    device_id TEXT NOT NULL,
    world_id INTEGER NOT NULL,
    device_token TEXT NOT NULL,
    account_id BIGINT NOT NULL REFERENCES accounts(user_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (device_id, world_id), UNIQUE(device_token)
);

CREATE TABLE IF NOT EXISTS characters (
    char_id BIGSERIAL PRIMARY KEY,
    account_id BIGINT NOT NULL REFERENCES accounts(user_id) ON DELETE CASCADE,
    world_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    gender SMALLINT NOT NULL DEFAULT 0,
    avatar INTEGER NOT NULL DEFAULT 0,
    level INTEGER NOT NULL DEFAULT 1 CHECK (level > 0),
    exp BIGINT NOT NULL DEFAULT 0,
    gold BIGINT NOT NULL DEFAULT 0,
    diamond BIGINT NOT NULL DEFAULT 0,
    vip_level INTEGER NOT NULL DEFAULT 0,
    stamina INTEGER NOT NULL DEFAULT 999,
    vip_points BIGINT NOT NULL DEFAULT 0,
    recharge_total BIGINT NOT NULL DEFAULT 0,
    month_card_until TIMESTAMPTZ,
    first_charge_claimed BOOLEAN NOT NULL DEFAULT FALSE,
    currencies_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    game_values JSONB NOT NULL DEFAULT '{}'::jsonb,
    map_id INTEGER NOT NULL DEFAULT 0,
    pos_x REAL NOT NULL DEFAULT 0,
    pos_y REAL NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(account_id, world_id), UNIQUE(world_id, name)
);

ALTER TABLE characters ADD COLUMN IF NOT EXISTS gender SMALLINT NOT NULL DEFAULT 0;
ALTER TABLE characters ADD COLUMN IF NOT EXISTS stamina INTEGER NOT NULL DEFAULT 999;
ALTER TABLE characters ADD COLUMN IF NOT EXISTS vip_points BIGINT NOT NULL DEFAULT 0;
ALTER TABLE characters ALTER COLUMN vip_points SET DEFAULT 0;
ALTER TABLE characters ADD COLUMN IF NOT EXISTS recharge_total BIGINT NOT NULL DEFAULT 0;
ALTER TABLE characters ADD COLUMN IF NOT EXISTS month_card_until TIMESTAMPTZ;
ALTER TABLE characters ADD COLUMN IF NOT EXISTS first_charge_claimed BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE characters ADD COLUMN IF NOT EXISTS currencies_json JSONB NOT NULL DEFAULT '{}'::jsonb;
ALTER TABLE characters ADD COLUMN IF NOT EXISTS game_values JSONB NOT NULL DEFAULT '{}'::jsonb;

-- Remove the legacy always-on GM wallet enforcement. Balances are now changed
-- only by validated transactional gameplay operations. Local payment sandbox
-- is separately gated by LOCAL_PAYMENT_SANDBOX in the server process.
DROP TRIGGER IF EXISTS characters_sandbox_wallet ON characters;
DROP FUNCTION IF EXISTS monster2_sandbox_wallet();

CREATE TABLE IF NOT EXISTS pets (
    pet_uid BIGSERIAL PRIMARY KEY,
    char_id BIGINT NOT NULL REFERENCES characters(char_id) ON DELETE CASCADE,
    pet_template_id INTEGER NOT NULL,
    nickname TEXT NOT NULL DEFAULT '',
    level INTEGER NOT NULL DEFAULT 1,
    exp BIGINT NOT NULL DEFAULT 0,
    star INTEGER NOT NULL DEFAULT 0,
    evolution INTEGER NOT NULL DEFAULT 0,
    slot_index INTEGER NOT NULL DEFAULT -1,
    skills_json JSONB NOT NULL DEFAULT '[]'::jsonb,
    equips_json JSONB NOT NULL DEFAULT '[]'::jsonb
);

CREATE TABLE IF NOT EXISTS inventory (
    id BIGSERIAL PRIMARY KEY,
    char_id BIGINT NOT NULL REFERENCES characters(char_id) ON DELETE CASCADE,
    item_id INTEGER NOT NULL,
    count BIGINT NOT NULL DEFAULT 0 CHECK (count >= 0),
    UNIQUE(char_id, item_id)
);

CREATE TABLE IF NOT EXISTS quests (
    id BIGSERIAL PRIMARY KEY,
    char_id BIGINT NOT NULL REFERENCES characters(char_id) ON DELETE CASCADE,
    quest_id INTEGER NOT NULL,
    status INTEGER NOT NULL DEFAULT 0,
    progress JSONB NOT NULL DEFAULT '{}'::jsonb,
    UNIQUE(char_id, quest_id)
);

CREATE TABLE IF NOT EXISTS homes (
    char_id BIGINT PRIMARY KEY REFERENCES characters(char_id) ON DELETE CASCADE,
    home_data JSONB NOT NULL DEFAULT '{"level":1,"furnitures":{}}'::jsonb,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- A tutorial encounter is server-issued and bound to the live TCP session.
-- This prevents a quest commit alone from claiming the first-battle objective.
CREATE TABLE IF NOT EXISTS tutorial_battle_sessions (
    battle_id BIGSERIAL PRIMARY KEY,
    char_id BIGINT NOT NULL REFERENCES characters(char_id) ON DELETE CASCADE,
    session_id TEXT NOT NULL,
    group_id INTEGER NOT NULL,
    state TEXT NOT NULL CHECK (state IN ('started','won','lost')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    finished_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS tutorial_battle_sessions_char_session_idx
    ON tutorial_battle_sessions(char_id, session_id, battle_id DESC);
