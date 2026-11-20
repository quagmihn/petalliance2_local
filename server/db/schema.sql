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

-- Idempotent local-only recharge ledger. The client supplies an order key in
-- the existing RechargeTestCmd appID field; this ledger is never a payment
-- provider receipt.
CREATE TABLE IF NOT EXISTS local_recharge_transactions (
    transaction_id BIGSERIAL PRIMARY KEY,
    char_id BIGINT NOT NULL REFERENCES characters(char_id) ON DELETE CASCADE,
    order_key TEXT NOT NULL,
    package_kind TEXT NOT NULL CHECK (package_kind IN ('normal','month')),
    package_id INTEGER NOT NULL,
    paid_amount BIGINT NOT NULL CHECK (paid_amount >= 0),
    rewards JSONB NOT NULL,
    simulated BOOLEAN NOT NULL DEFAULT TRUE CHECK (simulated),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(char_id, order_key)
);

CREATE TABLE IF NOT EXISTS local_month_cards (
    char_id BIGINT NOT NULL REFERENCES characters(char_id) ON DELETE CASCADE,
    package_id INTEGER NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    last_claim_day BIGINT,
    PRIMARY KEY (char_id, package_id)
);

CREATE TABLE IF NOT EXISTS local_draw_history (
    draw_id BIGSERIAL PRIMARY KEY,
    char_id BIGINT NOT NULL REFERENCES characters(char_id) ON DELETE CASCADE,
    machine_id INTEGER NOT NULL,
    draw_count INTEGER NOT NULL CHECK (draw_count IN (1, 10)),
    is_free BOOLEAN NOT NULL,
    draw_day BIGINT NOT NULL,
    currency TEXT NOT NULL CHECK (currency IN ('gold', 'diamond')),
    cost BIGINT NOT NULL CHECK (cost >= 0),
    awards JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL
);
ALTER TABLE local_draw_history ADD COLUMN IF NOT EXISTS request_key TEXT;
CREATE UNIQUE INDEX IF NOT EXISTS local_draw_request_key
    ON local_draw_history(char_id, request_key) WHERE request_key IS NOT NULL;
CREATE INDEX IF NOT EXISTS local_draw_history_by_machine
    ON local_draw_history(char_id, machine_id, draw_day) WHERE is_free;
CREATE INDEX IF NOT EXISTS local_paid_draw_recent
    ON local_draw_history(char_id, machine_id, draw_count, created_at) WHERE NOT is_free;

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

-- Stage is the independent strengthening counter used by PetAdvanceInfo.
-- Evolution changes species; it must not be reused as a strengthening level.
ALTER TABLE pets ADD COLUMN IF NOT EXISTS training_stage INTEGER NOT NULL DEFAULT 0 CHECK (training_stage >= 0);
ALTER TABLE pets ADD COLUMN IF NOT EXISTS passive_skills_json JSONB NOT NULL DEFAULT '[]'::jsonb;

CREATE TABLE IF NOT EXISTS inventory (
    id BIGSERIAL PRIMARY KEY,
    char_id BIGINT NOT NULL REFERENCES characters(char_id) ON DELETE CASCADE,
    item_id INTEGER NOT NULL,
    count BIGINT NOT NULL DEFAULT 0 CHECK (count >= 0),
    UNIQUE(char_id, item_id)
);

CREATE TABLE IF NOT EXISTS adventure_cell_claims (
    char_id BIGINT NOT NULL REFERENCES characters(char_id) ON DELETE CASCADE,
    adventure_id INTEGER NOT NULL,
    floor INTEGER NOT NULL,
    map_col INTEGER NOT NULL,
    map_row INTEGER NOT NULL,
    awards JSONB NOT NULL DEFAULT '[]'::jsonb,
    claimed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY(char_id, adventure_id, floor, map_col, map_row)
);

CREATE TABLE IF NOT EXISTS adventure_fired_events (
    char_id BIGINT NOT NULL REFERENCES characters(char_id) ON DELETE CASCADE,
    adventure_id INTEGER NOT NULL,
    event_id INTEGER NOT NULL,
    fired_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (char_id, adventure_id, event_id)
);

CREATE TABLE IF NOT EXISTS character_adventures (
    char_id BIGINT PRIMARY KEY REFERENCES characters(char_id) ON DELETE CASCADE,
    adventure_id INTEGER NOT NULL,
    started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at TIMESTAMPTZ,
    completion_star INTEGER NOT NULL DEFAULT 0,
    completion_awards_json JSONB NOT NULL DEFAULT '[]'::jsonb
);
ALTER TABLE character_adventures ADD COLUMN IF NOT EXISTS completion_star INTEGER NOT NULL DEFAULT 0;
ALTER TABLE character_adventures ADD COLUMN IF NOT EXISTS completion_awards_json JSONB NOT NULL DEFAULT '[]'::jsonb;

CREATE TABLE IF NOT EXISTS character_adventure_clears (
    char_id BIGINT NOT NULL REFERENCES characters(char_id) ON DELETE CASCADE,
    adventure_id INTEGER NOT NULL,
    star_mask INTEGER NOT NULL CHECK (star_mask BETWEEN 8 AND 15),
    PRIMARY KEY (char_id, adventure_id)
);

INSERT INTO character_adventure_clears(char_id,adventure_id,star_mask)
SELECT char_id,adventure_id,completion_star
FROM character_adventures
WHERE completed_at IS NOT NULL AND completion_star BETWEEN 8 AND 15
ON CONFLICT (char_id,adventure_id) DO NOTHING;

CREATE TABLE IF NOT EXISTS quests (
    id BIGSERIAL PRIMARY KEY,
    char_id BIGINT NOT NULL REFERENCES characters(char_id) ON DELETE CASCADE,
    quest_id INTEGER NOT NULL,
    status INTEGER NOT NULL DEFAULT 0,
    progress JSONB NOT NULL DEFAULT '{}'::jsonb,
    UNIQUE(char_id, quest_id)
);

-- Persist the exact configured quest rewards so a retried CommitQuest returns
-- the same award payload without granting the reward twice.
CREATE TABLE IF NOT EXISTS quest_reward_claims (
    char_id BIGINT NOT NULL REFERENCES characters(char_id) ON DELETE CASCADE,
    quest_id INTEGER NOT NULL,
    awards JSONB NOT NULL DEFAULT '[]'::jsonb,
    claimed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (char_id, quest_id)
);

-- Idempotency for world-map gift/collect nodes reported by the target client.
CREATE TABLE IF NOT EXISTS world_map_node_claims (
    char_id BIGINT NOT NULL REFERENCES characters(char_id) ON DELETE CASCADE,
    quest_id INTEGER NOT NULL,
    map_id INTEGER NOT NULL,
    node_id INTEGER NOT NULL,
    claimed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (char_id, quest_id, map_id, node_id)
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
    battle_type INTEGER NOT NULL DEFAULT 5,
    battle_type_id INTEGER NOT NULL DEFAULT 99998,
    adventure_id INTEGER,
    state TEXT NOT NULL CHECK (state IN ('started','won','lost')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    finished_at TIMESTAMPTZ
);
ALTER TABLE tutorial_battle_sessions ADD COLUMN IF NOT EXISTS battle_type INTEGER NOT NULL DEFAULT 5;
ALTER TABLE tutorial_battle_sessions ADD COLUMN IF NOT EXISTS battle_type_id INTEGER NOT NULL DEFAULT 99998;
ALTER TABLE tutorial_battle_sessions ADD COLUMN IF NOT EXISTS adventure_id INTEGER;
ALTER TABLE tutorial_battle_sessions ADD COLUMN IF NOT EXISTS capture_attempts_remaining INTEGER NOT NULL DEFAULT 0
    CHECK (capture_attempts_remaining >= 0);
ALTER TABLE tutorial_battle_sessions ADD COLUMN IF NOT EXISTS captured_pet_uid BIGINT REFERENCES pets(pet_uid);
ALTER TABLE tutorial_battle_sessions ADD COLUMN IF NOT EXISTS fighter_uids BIGINT[];
CREATE INDEX IF NOT EXISTS tutorial_battle_sessions_char_session_idx
    ON tutorial_battle_sessions(char_id, session_id, battle_id DESC);

CREATE TABLE IF NOT EXISTS wild_battle_capture_attempts (
    battle_id BIGINT NOT NULL REFERENCES tutorial_battle_sessions(battle_id) ON DELETE CASCADE,
    attempt_no INTEGER NOT NULL CHECK (attempt_no > 0),
    ball_item_id INTEGER NOT NULL,
    catch_rate INTEGER NOT NULL CHECK (catch_rate BETWEEN 0 AND 100),
    roll INTEGER NOT NULL CHECK (roll BETWEEN 0 AND 99),
    caught BOOLEAN NOT NULL,
    rate_bonus INTEGER NOT NULL DEFAULT 0 CHECK (rate_bonus >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (battle_id, attempt_no)
);
