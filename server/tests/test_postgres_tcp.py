"""Real TCP + PostgreSQL regression. Combat result here is a protocol fixture;
Android gameplay is validated separately and cannot be inferred from this test.
"""
import asyncio
import json
import os
import secrets
import struct
import unittest
from unittest.mock import patch
from db.database import Database
from game_socket import handle_client
from pet_config import validate_pet
from protocol import Reader, Writer, frame, xor_payload


class PostgreSQLTCPFlow(unittest.IsolatedAsyncioTestCase):
    async def test_new_account_quest_chain_and_relogin(self):
        dsn = os.getenv("TEST_DATABASE_URL")
        if not dsn:
            self.skipTest("TEST_DATABASE_URL required")
        db = await Database.connect(dsn)
        server = None; writer = None; account_id = None
        connections = set()
        async def accept(r, w):
            task = asyncio.current_task(); connections.add(task)
            try:
                await handle_client(r, w, db)
            finally:
                connections.discard(task)
        try:
            identity = await db.pool.fetchrow("SELECT current_database() name,rolsuper FROM pg_roles WHERE rolname=current_user")
            self.assertEqual(identity["name"], "monster2_test_db")
            self.assertFalse(identity["rolsuper"])
            await db.initialize()
            server = await asyncio.start_server(accept, "127.0.0.1", 0)
            port = server.sockets[0].getsockname()[1]
            reader, writer = await asyncio.open_connection("127.0.0.1", port)
            async def receive():
                length, msg = struct.unpack("<HH", await reader.readexactly(4))
                return msg, await reader.readexactly(length - 4), length
            async def send(msg, body, expected):
                writer.write(frame(msg, xor_payload(body))); await writer.drain()
                actual, response, _ = await asyncio.wait_for(receive(), 3)
                self.assertEqual(actual, expected)
                return Reader(response)
            async def win_battle(pet_uid, expected_exp):
                trace = Writer().u16(1).vector_strings([f"{pet_uid},120"]).bytes()
                writer.write(frame(263, xor_payload(trace)))
                await writer.drain()
                updates = []
                while True:
                    msg, body, _ = await asyncio.wait_for(receive(), 3)
                    packet = Reader(body)
                    if msg == 186:
                        self.assertEqual((packet.u16(), packet.u32()), (0, expected_exp))
                        packet.finish()
                        return updates
                    self.assertEqual((msg, packet.u64()), (3141, pet_uid))
                    updates.append(json.loads(packet.string()))
                    packet.finish()

            async def commit_quest(quest_id):
                writer.write(frame(400, xor_payload(Writer().u32(quest_id).bytes())))
                await writer.drain()
                notes = []
                while True:
                    msg, body, _ = await asyncio.wait_for(receive(), 3)
                    if msg == 726:
                        return Reader(body), notes
                    self.assertIn(msg, (112, 3141, 473))
                    notes.append(msg)
            suffix = secrets.token_hex(8)
            username, token = "tcp-test-" + suffix, secrets.token_hex(16)
            r = await send(2130, Writer().string(username).string(token).bytes(), 2126)
            self.assertEqual(r.i32(), 0)
            account_id = await db.pool.fetchval("SELECT user_id FROM accounts WHERE username=$1", username)
            self.assertNotEqual(account_id, 6)
            binding = Writer().string("tcp-device-" + suffix).string("1").string(secrets.token_hex(16)).bytes()
            self.assertEqual((await send(2211, binding, 2179)).i32(), 0)
            self.assertEqual((await send(2156, binding, 2183)).i32(), 0)
            initial_fashions = [1, 1001, 2001, 3001, 4001, 5001]
            create = (Writer().string("tcp-char-" + suffix).u8(1).u8(1).u8(7).u8(1)
                      .i32(1).string("").u8(len(initial_fashions)))
            for fashion_id in initial_fashions: create.u32(fashion_id)
            create = create.bytes()
            r = await send(1655, create, 807)
            self.assertEqual((r.i32(), r.string(), r.i32()), (0, "", 0))
            char_id = r.u32(); self.assertNotEqual(char_id, 2)
            async def draw_state():
                return await db.pool.fetchrow(
                    """SELECT gold, diamond,
                       (SELECT count(*) FROM pets WHERE char_id=$1) AS pets,
                       (SELECT coalesce(jsonb_object_agg(item_id, count), '{}'::jsonb)
                        FROM inventory WHERE char_id=$1) AS items,
                       (SELECT count(*) FROM quests WHERE char_id=$1 AND status=1) AS quests_finished
                       FROM characters WHERE char_id=$1""", char_id)

            before_draw = await draw_state()
            draw = Writer().u16(2).u16(1).u16(1).u16(0).bytes()
            rejected = await send(1392, draw, 1561)
            self.assertEqual(rejected.u16(), 1)
            rejected.finish()
            self.assertEqual(await draw_state(), before_draw)
            # Exercise the configured local recharge on the real framed TCP
            # route. Its response is a committed wallet notification followed
            # by the protocol ACK; repeating the same order cannot grant twice.
            with patch.dict(os.environ, {"LOCAL_PAYMENT_SANDBOX": "1",
                                         "PAYMENT_PROVIDER": "local", "GAME_ENV": "test"}):
                order_key = "local:N2:tcp-test-" + suffix
                recharge_body = Writer().u32(2).string(order_key).bytes()
                for _attempt in range(2):
                    writer.write(frame(90, xor_payload(recharge_body))); await writer.drain()
                    msg, body, _ = await asyncio.wait_for(receive(), 3)
                    self.assertEqual(msg, 473)
                    wallet = json.loads(Reader(body).string())
                    self.assertEqual(wallet["diamond"], 160)
                    msg, body, _ = await asyncio.wait_for(receive(), 3)
                    self.assertEqual((msg, Reader(body).u16()), (89, 0))
                self.assertEqual(await db.pool.fetchval(
                    "SELECT diamond FROM characters WHERE char_id=$1", char_id), 160)
                self.assertEqual(await db.pool.fetchval(
                    "SELECT count(*) FROM local_recharge_transactions WHERE char_id=$1 "
                    "AND order_key=$2 AND simulated", char_id, order_key), 1)
            fashions = await send(2075, b"", 2102)
            self.assertEqual(fashions.u16(), 0)
            fashion_state = json.loads(fashions.string()); fashions.finish()
            self.assertEqual(fashion_state["curFashion"], initial_fashions)
            self.assertTrue(all(fashion_id in group for fashion_id, group in
                                zip(initial_fashions[1:5], fashion_state["bag"][:4])))
            profile = await send(1283, Writer().string(str(char_id)).bytes(), 1261)
            self.assertEqual(profile.u16(), 0)
            own_profile = json.loads(profile.string())
            self.assertEqual((own_profile["charID"], own_profile["vipLevel"], own_profile["pets.num"]),
                             (char_id, 13, 1))  # N2's 99 reaches the target's VIP 12 threshold.
            profile.finish()
            # ItemInfo 34066 is consumed to own FashionItemInfo 4066. The
            # underlying item ID is not an appearance ID or an equipment UID.
            token_item_id, acquired_fashion_id = 34066, 4066
            await db.pool.execute(
                "INSERT INTO inventory(char_id,item_id,count) VALUES($1,$2,2)",
                char_id, token_item_id)
            use = Writer().u32(token_item_id).u32(0).string("").u32(1).bytes()
            bag_update = await send(516, use, 112)
            self.assertEqual(bag_update.u8(), 1)
            self.assertEqual(json.loads(bag_update.string()), {"itemID": token_item_id, "num": 1})
            bag_update.finish()
            msg, body, _ = await receive()
            self.assertEqual(msg, 2105)
            self.assertIn(acquired_fashion_id, json.loads(Reader(body).string())["bag"][3])
            msg, body, _ = await receive()
            self.assertEqual(msg, 526)
            redeemed = Reader(body)
            self.assertEqual((redeemed.u16(), redeemed.u32(), redeemed.u32()), (0, token_item_id, 1))
            self.assertEqual(redeemed.u8(), 0)
            redeemed.finish()
            self.assertEqual((await send(516, use, 526)).u16(), 455)
            self.assertEqual(await db.pool.fetchval(
                "SELECT count FROM inventory WHERE char_id=$1 AND item_id=$2", char_id, token_item_id), 1)
            # Keep unrelated Inventory assertions on their original fixture.
            await db.pool.execute("DELETE FROM inventory WHERE char_id=$1 AND item_id=$2",
                                  char_id, token_item_id)
            changed_fashions = [*initial_fashions[:4], acquired_fashion_id, 0]
            set_fashion = Writer().u8(len(changed_fashions))
            for fashion_id in changed_fashions: set_fashion.u32(fashion_id)
            updated = await send(2121, set_fashion.bytes(), 2109)
            self.assertEqual(updated.u16(), 0)
            self.assertEqual(json.loads(updated.string())["curFashion"], changed_fashions)
            updated.finish()
            self.assertEqual(await db.pool.fetchval(
                "SELECT game_values->>'curfashion' FROM characters WHERE char_id=$1", char_id),
                json.dumps(changed_fashions, separators=(",", ":")))
            r = await send(3140, Writer().u64(char_id).u32(0).u32(10).bytes(), 3139)
            self.assertEqual(r.u16(), 0); self.assertEqual(r.u64(), char_id)
            r.u32(); r.u32(); self.assertEqual(r.u8(), 1)
            starter = json.loads(r.string())
            validate_pet(starter)
            pet_uid = starter["objID"]
            formation = (Writer().u8(1).u32(1).u8(1).u32(pet_uid).u8(0).bytes())
            self.assertEqual((await send(1755, formation, 1756)).u16(), 0)
            formation = (Writer().u8(1).u32(1).u8(1).u32(0).u8(0).bytes())
            self.assertEqual((await send(1755, formation, 1756)).u16(), 1)
            army = await send(1760, b"", 1774)
            self.assertEqual(army.u16(), 0)
            self.assertEqual(json.loads(army.string()), {"1": [pet_uid], "1h": []})

            # The client's quest 10008 capture guide uses a type-1 wild monster
            # ID (999997..999999), distinct from trainer group 99999/type 5.
            await db.pool.execute(
                "INSERT INTO quests(char_id,quest_id,status,progress) VALUES($1,10008,0,'[0]'::jsonb)",
                char_id)
            wild = await send(136, Writer().u32(1).u32(999999).u32(0).bytes(), 210)
            self.assertEqual(wild.u16(), 0); self.assertEqual(wild.u8(), 1)
            wild_enemy = json.loads(wild.string())
            self.assertEqual((wild_enemy["mID"], wild_enemy["canCatch"]), (999999, True))
            self.assertEqual((wild.u32(), wild.u8()), (8, 0)); wild.finish()
            await db.pool.execute(
                "INSERT INTO inventory(char_id,item_id,count) VALUES($1,2,1) "
                "ON CONFLICT(char_id,item_id) DO UPDATE SET count=EXCLUDED.count", char_id)
            # Deterministic configured-rate boundary: roll 0 is below the
            # Para Ball's positive configured catch chance for this species.
            with patch("secrets.randbelow", return_value=0):
                writer.write(frame(15, xor_payload(Writer().u32(26).u32(2).bytes())))
                await writer.drain()
                msg, body, _ = await receive()
                self.assertEqual(msg, 112)
                item_state = Reader(body); self.assertEqual(item_state.u8(), 1)
                self.assertEqual(json.loads(item_state.string()), {"itemID": 2, "num": 0})
                item_state.finish()
                msg, body, _ = await receive()
                self.assertEqual(msg, 3141)
                captured_uid = Reader(body).u64()
                self.assertGreater(captured_uid, 0)
                pet_body = Reader(body); pet_body.u64(); captured_pet = json.loads(pet_body.string()); pet_body.finish()
                self.assertEqual(captured_pet["pokeID"], 26)
                msg, body, _ = await receive()
                capture_ack = Reader(body)
                self.assertEqual((msg, capture_ack.u16(), capture_ack.u16()), (198, 0, 1))
                captured_payload = json.loads(capture_ack.string())
                self.assertEqual(captured_payload["objID"], captured_uid)
                self.assertEqual(capture_ack.u32(), 0); capture_ack.finish()
            self.assertEqual(await db.pool.fetchval(
                "SELECT count(*) FROM pets WHERE char_id=$1 AND pet_uid=$2 AND pet_template_id=26",
                char_id, captured_uid), 1)
            self.assertIsNone(await db.pool.fetchval(
                "SELECT count FROM inventory WHERE char_id=$1 AND item_id=2", char_id))
            capture_progress = await db.pool.fetchval(
                "SELECT progress FROM quests WHERE char_id=$1 AND quest_id=10008", char_id)
            self.assertEqual(json.loads(capture_progress) if isinstance(capture_progress, str)
                             else capture_progress, [1])
            # A duplicate delivery of the successful request returns the
            # already-created Pet without consuming a second ball or creating
            # another Pet. The client is also patched to disable auto-resend.
            duplicate = await send(15, Writer().u32(26).u32(2).bytes(), 112)
            self.assertEqual(duplicate.u8(), 1)
            self.assertEqual(json.loads(duplicate.string()), {"itemID": 2, "num": 0})
            duplicate.finish()
            msg, body, _ = await receive()
            self.assertEqual(msg, 198)
            duplicate_ack = Reader(body)
            self.assertEqual((duplicate_ack.u16(), duplicate_ack.u16()), (0, 1))
            self.assertEqual(json.loads(duplicate_ack.string())["objID"], captured_uid)
            duplicate_ack.u32(); duplicate_ack.finish()
            self.assertEqual(await db.pool.fetchval(
                "SELECT count(*) FROM pets WHERE char_id=$1 AND pet_template_id=26", char_id), 1)
            # BattleScene transitions can reconnect the TCP socket between the
            # create request and end request. The authenticated character's
            # active encounter must survive that fresh transport session.
            writer.close()
            await writer.wait_closed()
            reader, writer = await asyncio.open_connection("127.0.0.1", port)
            login_after_reconnect = await send(2156, binding, 2183)
            self.assertEqual(login_after_reconnect.i32(), 0)
            denied = Writer().u16(1).vector_strings([f"{captured_uid},120"]).bytes()
            self.assertEqual((await send(263, denied, 186)).u16(), 1)
            updates = await win_battle(pet_uid, 8)
            self.assertEqual([pet["exp"] for pet in updates], [8])
            replay = Writer().u16(1).vector_strings([f"{pet_uid},120"]).bytes()
            self.assertEqual((await send(263, replay, 186)).u16(), 1)
            self.assertEqual(await db.pool.fetchval("SELECT exp FROM pets WHERE pet_uid=$1", captured_uid), 0)
            self.assertEqual(await db.pool.fetchval(
                "SELECT state FROM tutorial_battle_sessions WHERE char_id=$1 AND battle_type=1 "
                "ORDER BY battle_id DESC LIMIT 1", char_id), "won")
            self.assertTrue(await db.start_tutorial_wild_battle(
                char_id, "abandoned-session", 999997, 10008, 3))
            self.assertTrue(await db.start_tutorial_wild_battle(
                char_id, "new-session", 999998, 10008, 3))
            states = await db.pool.fetch(
                "SELECT battle_type_id,state FROM tutorial_battle_sessions "
                "WHERE char_id=$1 AND battle_type=1 ORDER BY battle_id DESC LIMIT 2", char_id)
            self.assertEqual([(row["battle_type_id"], row["state"]) for row in states],
                             [(999998, "started"), (999997, "lost")])
            self.assertTrue(await db.finish_tutorial_battle(char_id, "other-session", False))
            self.assertEqual(await db.pool.fetchval(
                "SELECT state FROM tutorial_battle_sessions WHERE char_id=$1 AND battle_type_id=999998",
                char_id), "lost")
            self.assertTrue(await db.start_tutorial_wild_battle(
                char_id, "capture-after-win", 999997, 10008, 3))
            self.assertTrue(await db.finish_tutorial_battle(char_id, "capture-after-win", True))
            post_win_session = await db.pool.fetchrow(
                "SELECT battle_type,battle_type_id,state,capture_attempts_remaining,captured_pet_uid "
                "FROM tutorial_battle_sessions WHERE char_id=$1 ORDER BY battle_id DESC LIMIT 1", char_id)
            self.assertEqual(tuple(post_win_session), (1, 999997, "won", 3, None))
            await db.pool.execute(
                "INSERT INTO inventory(char_id,item_id,count) VALUES($1,2,1) "
                "ON CONFLICT(char_id,item_id) DO UPDATE SET count=EXCLUDED.count", char_id)
            with patch("secrets.randbelow", return_value=0):
                post_win_capture = await db.capture_wild_pet(
                    char_id, "capture-after-win", 26, 2)
            self.assertIsNotNone(post_win_capture)
            self.assertTrue(post_win_capture["caught"])
            self.assertGreater(post_win_capture["pet_uid"], 0)
            wild_progress = await db.pool.fetchval(
                "SELECT progress FROM quests WHERE char_id=$1 AND quest_id=10008", char_id)
            self.assertEqual(json.loads(wild_progress) if isinstance(wild_progress, str)
                             else wild_progress, [1])
            await db.pool.execute(
                "DELETE FROM quests WHERE char_id=$1 AND quest_id=10008", char_id)
            await db.pool.execute(
                "UPDATE characters SET recharge_total=4321 WHERE char_id=$1", char_id)
            recharge_values = await send(770, Writer().u8(1).string("recharge").bytes(), 747)
            self.assertEqual(recharge_values.u16(), 0)
            self.assertEqual(json.loads(recharge_values.string()),
                             {"recharge": {"totalMoney": 4321}})
            recharge_values.finish()

            # Feed a configured EXP potion through the actual TCP protocol. Pet EXP
            # is cumulative and distinct from character EXP and training Stage.
            from client_config import table
            pokemon = table("PokemonInfo")[starter["pokeID"]]
            costs = table("PetAdvanceInfo")[1]["stageCons"][int(pokemon["elementAtt1"]) - 1]["costs"]
            consume_table = table("ConsumeElementInfo")
            await db.pool.execute("UPDATE characters SET level=2,gold=10000,diamond=10000 WHERE char_id=$1", char_id)
            await db.pool.execute(
                "INSERT INTO inventory(char_id,item_id,count) VALUES($1,10002,1) "
                "ON CONFLICT(char_id,item_id) DO UPDATE SET count=EXCLUDED.count", char_id)
            writer.write(frame(516, xor_payload(
                Writer().u32(10002).u32(pet_uid).string("").u32(1).bytes())))
            await writer.drain()
            msg, body, _ = await receive()
            self.assertEqual(msg, 112)
            item_updates = Reader(body)
            self.assertEqual(item_updates.u8(), 1)
            self.assertEqual(json.loads(item_updates.string()), {"itemID": 10002, "num": 0})
            item_updates.finish()
            msg, body, _ = await receive()
            update = Reader(body)
            self.assertEqual((msg, update.u64()), (3141, pet_uid))
            fed_pet = json.loads(update.string()); update.finish()
            self.assertEqual((fed_pet["level"], fed_pet["exp"]), (2, 108))
            msg, body, _ = await receive()
            feed = Reader(body)
            self.assertEqual((msg, feed.u16(), feed.u32(), feed.u32()), (526, 0, 10002, 0))
            self.assertEqual(feed.u8(), 0); feed.finish()
            self.assertEqual(await db.pool.fetchval(
                "SELECT (SELECT count FROM inventory WHERE char_id=$1 AND item_id=10002)", char_id), None)
            pet_state = await db.pool.fetchrow(
                "SELECT level,exp FROM pets WHERE char_id=$1 AND pet_uid=$2", char_id, pet_uid)
            self.assertEqual((pet_state["level"], pet_state["exp"]), (2, 108))

            # Town Market blocks input during its initial auction search.
            own_listings = await send(478, b"", 493)
            self.assertEqual((own_listings.u16(), own_listings.u8()), (0, 0))
            own_listings.finish()
            query = Writer().u32(1).u32(1).u32(0).u32(0).u32(0).u32(6).string("").bytes()
            results = await send(492, query, 520)
            self.assertEqual((results.u16(), results.u8()), (0, 0))
            results.finish()

            # Product 201 is configured as one Master Ball for 600 MCash.
            await db.pool.execute("UPDATE characters SET diamond=10000 WHERE char_id=$1", char_id)
            writer.write(frame(577, xor_payload(Writer().u32(201).u32(1).bytes())))
            await writer.drain()
            msg, body, _ = await receive()
            self.assertEqual(msg, 112)
            market_item = Reader(body)
            self.assertEqual(market_item.u8(), 1)
            self.assertEqual(json.loads(market_item.string()), {"itemID": 1, "num": 1})
            market_item.finish()
            msg, body, _ = await receive()
            self.assertEqual(msg, 473)
            market_wallet = json.loads(Reader(body).string())
            self.assertEqual(market_wallet["m_cash"], 9400)
            msg, body, _ = await receive()
            self.assertEqual((msg, Reader(body).u16()), (563, 0))
            self.assertEqual(await db.pool.fetchval(
                "SELECT count FROM inventory WHERE char_id=$1 AND item_id=1", char_id), 1)
            limit_sku = 178
            capped_buy = Writer().u32(limit_sku).u32(10).bytes()
            await db.pool.execute("UPDATE characters SET vip_level=0 WHERE char_id=$1", char_id)
            self.assertEqual((await send(577, capped_buy, 563)).u16(), 1)  # VIP rank too low
            await db.pool.execute(
                """UPDATE characters SET vip_level=12,
                   game_values=game_values || '{"buyMarketItemNum_178":10,"buyMarketItemTime_178":1}'
                   WHERE char_id=$1""", char_id)
            limited_items = await send(577, capped_buy, 112)
            self.assertEqual(limited_items.u8(), 1)
            self.assertEqual(json.loads(limited_items.string()), {"itemID": 187, "num": 10})
            msg, body, _ = await receive()
            self.assertEqual(msg, 473)
            limited_wallet = json.loads(Reader(body).string())
            self.assertEqual((limited_wallet["m_cash"], limited_wallet["buyMarketItemNum_178"]),
                             (9200, 10))
            self.assertGreater(limited_wallet["buyMarketItemTime_178"], 1)
            msg, body, _ = await receive()
            self.assertEqual((msg, Reader(body).u16()), (563, 0))
            self.assertEqual((await send(577, Writer().u32(limit_sku).u32(1).bytes(), 563)).u16(), 1)
            forged_counter = Writer().u32(char_id).string("buyMarketItemNum_178").string("0")
            self.assertEqual((await send(632, forged_counter.bytes(), 630)).u16(), 1)
            self.assertEqual(await db.pool.fetchval(
                "SELECT diamond FROM characters WHERE char_id=$1", char_id), 9200)
            self.assertEqual(await db.pool.fetchval(
                "SELECT count FROM inventory WHERE char_id=$1 AND item_id=187", char_id), 10)

            # Exercise the real Stage-up protocol against configured costs in the test DB.
            for cost_id in costs:
                cost = consume_table[cost_id]
                if cost["elementType"] == 3:
                    await db.pool.execute(
                        """INSERT INTO inventory(char_id,item_id,count) VALUES($1,$2,$3)
                           ON CONFLICT(char_id,item_id) DO UPDATE SET count=EXCLUDED.count""",
                        char_id, cost["elementID"], cost["num"])
            before_costs = await db.pool.fetchrow(
                "SELECT gold,diamond FROM characters WHERE char_id=$1", char_id)
            stage_items = await send(1038, Writer().u32(pet_uid).bytes(), 112)
            self.assertEqual((stage_items.u8(), json.loads(stage_items.string())),
                             (1, {"itemID": 154, "num": 0}))
            stage_items.finish()
            wallet_id, wallet_body, _ = await receive()
            self.assertEqual(wallet_id, 473)
            self.assertEqual(json.loads(Reader(wallet_body).string())["g_cash"], before_costs["gold"] - 100)
            stage_id, stage_body, _ = await receive()
            self.assertEqual(stage_id, 1032)
            stage_ack = Reader(stage_body)
            self.assertEqual((stage_ack.u16(), stage_ack.u32(), stage_ack.u16()), (0, pet_uid, 1))
            stage_ack.finish()
            self.assertEqual(await db.pool.fetchval(
                "SELECT training_stage FROM pets WHERE char_id=$1 AND pet_uid=$2", char_id, pet_uid), 1)
            for cost_id in costs:
                cost = consume_table[cost_id]
                if cost["elementType"] == 3:
                    self.assertIsNone(await db.pool.fetchval(
                        "SELECT count FROM inventory WHERE char_id=$1 AND item_id=$2",
                        char_id, cost["elementID"]))
            r = await send(3140, Writer().u64(char_id).u32(0).u32(10).bytes(), 3139)
            self.assertEqual((r.u16(), r.u64()), (0, char_id)); r.u32(); r.u32()
            self.assertEqual(r.u8(), 1)
            upgraded_pet = json.loads(r.string())
            self.assertEqual((upgraded_pet["objID"], upgraded_pet["Stage"],
                              upgraded_pet["level"], upgraded_pet["exp"]), (pet_uid, 1, 2, 108))
            inactive_count = r.u8()
            for _ in range(inactive_count):
                r.string()
            self.assertEqual(r.u32(), inactive_count)
            helper_count = r.u8()
            for _ in range(helper_count):
                r.string()
            r.finish()
            after_costs = await db.pool.fetchrow(
                "SELECT gold,diamond FROM characters WHERE char_id=$1", char_id)
            for cost_id in costs:
                cost = consume_table[cost_id]
                if cost["elementType"] == 1:
                    self.assertEqual(before_costs["gold"] - after_costs["gold"], cost["num"])
                elif cost["elementType"] == 2:
                    self.assertEqual(before_costs["diamond"] - after_costs["diamond"], cost["num"])
            second_stage = await send(1038, Writer().u32(pet_uid).bytes(), 1032)
            self.assertEqual(second_stage.u16(), 1); second_stage.finish()
            self.assertEqual(await db.pool.fetchval(
                "SELECT training_stage FROM pets WHERE char_id=$1 AND pet_uid=$2", char_id, pet_uid), 1)

            trainer_request = Writer().u32(3).u32(15).u32(0).bytes()
            self.assertEqual((await send(136, trainer_request, 210)).u16(), 1)
            entered = await send(2996, Writer().u32(1).bytes(), 3080)
            self.assertEqual((entered.u16(), entered.u32()), (0, 1))
            self.assertEqual(json.loads(entered.string())["advID"], 1)
            entered.finish()
            trainer = await send(136, trainer_request, 210)
            self.assertEqual((trainer.u16(), trainer.u8()), (0, 1))
            self.assertEqual(json.loads(trainer.string())["mID"], 1)
            self.assertEqual((trainer.u32(), trainer.u8()), (16, 0)); trainer.finish()
            self.assertEqual((await send(263, Writer().u16(0).vector_strings([]).bytes(), 186)).u16(), 0)
            event_ack = await send(4, Writer().u32(1).u8(2).u32(5).u32(30).bytes(), 5)
            self.assertEqual(event_ack.u16(), 0); event_ack.finish()
            self.assertEqual(await db.pool.fetchval(
                "SELECT count(*) FROM adventure_fired_events WHERE char_id=$1 AND adventure_id=1",
                char_id), 2)
            finish = await send(3082, Writer().u16(12).bytes(), 2995)
            self.assertEqual(finish.u16(), 0)
            awards = [finish.string() for _ in range(finish.u8())]; finish.finish()
            self.assertEqual(awards, [
                '{"elementType":"exp","elementID":0,"num":60}',
                '{"elementType":"item","elementID":10002,"num":1}',
            ])
            self.assertIsNotNone(await db.pool.fetchval(
                "SELECT completed_at FROM character_adventures WHERE char_id=$1", char_id))
            self.assertEqual(await db.pool.fetchval(
                "SELECT exp FROM characters WHERE char_id=$1", char_id), 60)
            self.assertEqual(await db.pool.fetchval(
                "SELECT count FROM inventory WHERE char_id=$1 AND item_id=10002", char_id), 1)
            async def verify_clear_notifications():
                msg, body, _ = await receive()
                self.assertEqual(msg, 473)
                progress = json.loads(Reader(body).string())
                self.assertEqual((progress["level"], progress["exp"]), (2, 60))
                msg, body, _ = await receive()
                stars = Reader(body)
                self.assertEqual((msg, stars.u8()), (1749, 1))
                self.assertEqual(json.loads(stars.string()), {"advID": 1, "star": 12})
                stars.finish()

            await verify_clear_notifications()
            # A retried clear returns the retained ACK payload without granting twice.
            retry = await send(3082, Writer().u16(12).bytes(), 2995)
            self.assertEqual(retry.u16(), 0); self.assertEqual([retry.string() for _ in range(retry.u8())], awards)
            retry.finish()
            await verify_clear_notifications()
            # Starting another run must preserve previously earned stars.
            await db.start_adventure(char_id, 2)
            stale_cell = await send(2998, Writer().u32(1).u32(5).u32(6).bytes(), 3079)
            self.assertEqual(stale_cell.u16(), 1); stale_cell.finish()
            stale_clear = await send(3082, Writer().u16(12).bytes(), 2995)
            self.assertEqual(stale_clear.u16(), 1); stale_clear.finish()
            self.assertEqual(await db.current_adventure_id(char_id), 2)
            self.assertFalse(await db.pool.fetchval(
                "SELECT EXISTS(SELECT 1 FROM adventure_cell_claims WHERE char_id=$1)", char_id))
            finished = await send(3078, b"", 3081)
            self.assertEqual((finished.u16(), finished.u32()), (0, 1))
            finished.finish()
            msg, body, _ = await receive()
            stars = Reader(body)
            self.assertEqual((msg, stars.u8()), (1749, 1))
            self.assertEqual(json.loads(stars.string()), {"advID": 1, "star": 12})
            stars.finish()
            self.assertEqual(await db.pool.fetchval(
                "SELECT exp FROM characters WHERE char_id=$1", char_id), 60)
            # ID 4 with no payload is the native SYSPING_ACK; it is intentionally
            # one-way. The following request proves the socket remains usable.
            writer.write(frame(4, b"")); await writer.drain()
            seven_day = await send(391, Writer().u32(24).u32(0).bytes(), 390)
            self.assertEqual(seven_day.u16(), 1); seven_day.finish()
            r = await send(227, b"", 225)
            self.assertEqual((r.u16(), r.string()), (0, "[]")); r.finish()
            self.assertEqual((await send(128, b"", 181)).u16(), 0)
            self.assertEqual((await send(690, Writer().string("sevenDayCompleteTask").bytes(), 721)).u16(), 0)
            self.assertEqual((await send(785, b"", 26)).u16(), 0)
            self.assertEqual((await receive())[0], 404)
            self.assertEqual((await commit_quest(1))[0].u16(), 0)
            self.assertEqual((await receive())[0], 404)
            self.assertEqual((await send(136, bytes.fromhex("050000009e86010000000000"), 210)).u16(), 0)
            # Explicit synthetic protocol fixture; never used as runtime proof.
            await win_battle(pet_uid, 16)
            writer.write(frame(400, xor_payload(Writer().u32(10001).bytes())))
            await writer.drain()
            reward_messages = []
            while True:
                msg, body, _ = await asyncio.wait_for(receive(), 3)
                reward_messages.append(msg)
                if msg == 726:
                    commit = Reader(body)
                    self.assertEqual(commit.u16(), 0)
                    self.assertEqual(commit.u32(), 10001)
                    quest_awards = [json.loads(commit.string()) for _ in range(commit.u8())]
                    commit.finish()
                    break
            self.assertEqual(reward_messages, [3141, 473, 726])
            self.assertIn({"elementType": "pet", "elementID": 116, "num": 1}, quest_awards)
            self.assertEqual(await db.pool.fetchval(
                "SELECT count(*) FROM pets WHERE char_id=$1 AND pet_template_id=116", char_id), 1)
            msg, body, _ = await receive(); self.assertEqual(msg, 404)
            ntf = Reader(body); children = []
            for _ in range(ntf.u8()):
                children.append(ntf.u32()); ntf.u8(); ntf.u64()
                for _ in range(ntf.u8()): ntf.u32()
            ntf.finish(); self.assertEqual(children, [2, 10002])
            writer.close(); await writer.wait_closed()
            reader, writer = await asyncio.open_connection("127.0.0.1", port)
            self.assertEqual((await send(1684, Writer().i32(char_id).string(token).bytes(), 773)).i32(), 0)
            fashions = await send(2075, b"", 2102)
            self.assertEqual(fashions.u16(), 0)
            fashion_state = json.loads(fashions.string())
            self.assertEqual(fashion_state["curFashion"], changed_fashions)
            self.assertIn(acquired_fashion_id, fashion_state["bag"][3])
            fashions.finish()
            values = await send(770, Writer().u8(1).string("curfashion").bytes(), 747)
            self.assertEqual(values.u16(), 0)
            self.assertEqual(json.loads(values.string())["curfashion"],
                             json.dumps(changed_fashions, separators=(",", ":")))
            values.finish()
            self.assertEqual((await send(785, b"", 26)).u16(), 0)
            self.assertEqual((await receive())[0], 404)
            self.assertEqual(await db.pool.fetchval("SELECT status FROM quests WHERE char_id=$1 AND quest_id=10001", char_id), 1)
            self.assertEqual(await db.pool.fetchval("SELECT count(*) FROM quests WHERE char_id=$1 AND quest_id IN (2,10002)", char_id), 2)

            # Complete the configured tutorial/Adventure chain against real
            # PostgreSQL rows over the same TCP handler. This is a synthetic
            # test character, never the play character.
            await db.pool.execute("UPDATE characters SET level=2 WHERE char_id=$1", char_id)
            update = Writer().u32(10002).u8(0).u64(1).u8(1).u32(1).bytes()
            self.assertEqual((await send(3133, update, 3132)).u16(), 0)
            self.assertEqual((await commit_quest(10002))[0].u16(), 0)
            self.assertEqual((await receive())[0], 404)
            self.assertEqual((await send(2996, Writer().u32(1).bytes(), 3080)).u16(), 0)
            # The second configured map clear advances event-19 story progress.
            self.assertEqual((await send(3082, Writer().u16(12).bytes(), 2995)).u16(), 0)
            progress_id, progress_body, _ = await receive()
            notice = Reader(progress_body)
            self.assertEqual((progress_id, notice.u8(), notice.u32(), notice.u8()), (404, 1, 2, 0))
            notice.u64()
            self.assertEqual((notice.u8(), notice.u32()), (1, 1))
            notice.finish()
            self.assertEqual((await receive())[0], 473)
            self.assertEqual((await receive())[0], 1749)
            story_progress = await db.pool.fetchval(
                "SELECT progress FROM quests WHERE char_id=$1 AND quest_id=2", char_id)
            self.assertEqual(json.loads(story_progress) if isinstance(story_progress, str)
                             else story_progress, [1])
            self.assertEqual((await commit_quest(2))[0].u16(), 0)
            story_children = Reader((await receive())[1])
            spawned = []
            for _ in range(story_children.u8()):
                spawned.append(story_children.u32()); story_children.u8(); story_children.u64()
                for _ in range(story_children.u8()): story_children.u32()
            story_children.finish()
            self.assertIn(3, spawned)
            await db.pool.execute(
                "UPDATE quests SET progress='[1]'::jsonb WHERE char_id=$1 AND quest_id=3", char_id)
            item_commit, item_notes = await commit_quest(3)
            self.assertEqual((item_commit.u16(), item_commit.u32()), (0, 3))
            item_awards = [json.loads(item_commit.string()) for _ in range(item_commit.u8())]
            item_commit.finish()
            self.assertEqual(item_notes, [112, 473])
            self.assertIn({"elementType": "item", "elementID": 10003, "num": 30}, item_awards)
            self.assertEqual(await db.pool.fetchval(
                "SELECT count FROM inventory WHERE char_id=$1 AND item_id=10003", char_id), 30)
            child_message, child_body, _ = await receive()
            self.assertEqual(child_message, 404)
            retry_item_commit, _ = await commit_quest(3)
            retry_item_commit.u16(); retry_item_commit.u32()
            retry_awards = [json.loads(retry_item_commit.string())
                            for _ in range(retry_item_commit.u8())]
            retry_item_commit.finish()
            self.assertEqual(retry_awards, item_awards)
            self.assertEqual(await db.pool.fetchval(
                "SELECT count FROM inventory WHERE char_id=$1 AND item_id=10003", char_id), 30)
            guide_progress = await db.pool.fetchval(
                "SELECT progress FROM quests WHERE char_id=$1 AND quest_id=10003", char_id)
            self.assertEqual(json.loads(guide_progress) if isinstance(guide_progress, str)
                             else guide_progress, [0])
            self.assertEqual((await commit_quest(10003))[0].u16(), 0)
            self.assertEqual((await receive())[0], 404)
            self.assertEqual(await db.pool.fetchval(
                "SELECT status FROM quests WHERE char_id=$1 AND quest_id=10003", char_id), 1)
            guide_progress = await db.pool.fetchval(
                "SELECT progress FROM quests WHERE char_id=$1 AND quest_id=10003", char_id)
            self.assertEqual(json.loads(guide_progress) if isinstance(guide_progress, str)
                             else guide_progress, [1])

            # Configured event-18 map-node trainer: map_event 1003 is type 0,
            # whose configured object is MonsterGroupManInfo 2003.
            await db.pool.execute(
                "UPDATE characters SET game_values=game_values || jsonb_build_object('map_lock','4-0') WHERE char_id=$1",
                char_id)
            await db.pool.execute(
                "INSERT INTO quests(char_id,quest_id,status,progress) VALUES($1,1501,0,'[0]')",
                char_id)
            denied = await send(136, Writer().u32(5).u32(99999).u32(0).bytes(), 210)
            self.assertEqual(denied.u16(), 1); denied.finish()
            locked_node = await send(136, Writer().u32(5).u32(2003).u32(0).bytes(), 210)
            self.assertEqual(locked_node.u16(), 1); locked_node.finish()
            await db.pool.execute(
                "UPDATE characters SET game_values=game_values || jsonb_build_object('map_lock','5-0') WHERE char_id=$1",
                char_id)
            node_battle = await send(136, Writer().u32(5).u32(2003).u32(0).bytes(), 210)
            self.assertEqual((node_battle.u16(), node_battle.u8()), (0, 1))
            node_enemy = json.loads(node_battle.string())
            self.assertEqual(node_enemy["mID"], 1001)
            self.assertEqual(node_battle.u32(), 24); node_battle.u8(); node_battle.finish()
            await win_battle(pet_uid, 24)
            node_progress = await db.pool.fetchval(
                "SELECT progress FROM quests WHERE char_id=$1 AND quest_id=1501", char_id)
            self.assertEqual(json.loads(node_progress) if isinstance(node_progress, str)
                             else node_progress, [1])
            node_update = Writer().u32(1501).u8(0).u64(1).u8(1).u32(1).bytes()
            self.assertEqual((await send(3133, node_update, 3132)).u16(), 0)
            node_commit, _ = await commit_quest(1501)
            self.assertEqual((node_commit.u16(), node_commit.u32(), node_commit.u8()), (0, 1501, 0))
            node_commit.finish()

            # Gift node: map_event 1006 is configured type 2, which the client
            # exposes as EmbeddedMapMgr event type 3 and reports through 3133.
            await db.pool.execute(
                "UPDATE characters SET game_values=game_values || jsonb_build_object('map_lock','10-0') WHERE char_id=$1",
                char_id)
            await db.pool.execute(
                "INSERT INTO quests(char_id,quest_id,status,progress) VALUES($1,1502,0,'[0]')",
                char_id)
            gift_update = Writer().u32(1502).u8(0).u64(1).u8(1).u32(1).bytes()
            locked_gift = await send(3133, gift_update, 3132)
            self.assertEqual(locked_gift.u16(), 1); locked_gift.finish()
            await db.pool.execute(
                "UPDATE characters SET game_values=game_values || jsonb_build_object('map_lock','11-0') WHERE char_id=$1",
                char_id)
            gift_ack = await send(3133, gift_update, 3132)
            self.assertEqual(gift_ack.u16(), 0); gift_ack.finish()
            duplicate_gift = await send(3133, gift_update, 3132)
            self.assertEqual(duplicate_gift.u16(), 0); duplicate_gift.finish()
            gift_progress = await db.pool.fetchval(
                "SELECT progress FROM quests WHERE char_id=$1 AND quest_id=1502", char_id)
            self.assertEqual(json.loads(gift_progress) if isinstance(gift_progress, str)
                             else gift_progress, [1])
            self.assertEqual(await db.pool.fetchval(
                "SELECT count(*) FROM world_map_node_claims WHERE char_id=$1 AND quest_id=1502",
                char_id), 1)

            # Wild node: event 1014 is type 1 and references MonstrosityInfo 215.
            await db.pool.execute(
                "UPDATE characters SET game_values=game_values || jsonb_build_object('map_lock','22-0') WHERE char_id=$1",
                char_id)
            await db.pool.execute(
                "INSERT INTO quests(char_id,quest_id,status,progress) VALUES($1,1503,0,'[0]')",
                char_id)
            wild_req = Writer().u32(1).u32(215).u32(0).bytes()
            locked_wild = await send(136, wild_req, 210)
            self.assertEqual(locked_wild.u16(), 1); locked_wild.finish()
            await db.pool.execute(
                "UPDATE characters SET game_values=game_values || jsonb_build_object('map_lock','23-0') WHERE char_id=$1",
                char_id)
            wrong_node_wild = await send(136, Writer().u32(1).u32(215).u32(1).bytes(), 210)
            self.assertEqual(wrong_node_wild.u16(), 1); wrong_node_wild.finish()
            wild_battle = await send(136, wild_req, 210)
            self.assertEqual((wild_battle.u16(), wild_battle.u8()), (0, 1))
            wild_enemy = json.loads(wild_battle.string())
            self.assertEqual(wild_enemy["mID"], 215)
            self.assertTrue(wild_enemy["canCatch"])
            self.assertEqual(wild_battle.u32(), 16); wild_battle.u8(); wild_battle.finish()
            await win_battle(pet_uid, 16)
            wild_template = table("MonstrosityInfo")[215]["petnumber"]
            await db.pool.execute(
                "INSERT INTO inventory(char_id,item_id,count) VALUES($1,2,2) "
                "ON CONFLICT(char_id,item_id) DO UPDATE SET count=EXCLUDED.count", char_id)
            wrong_capture = await send(15, Writer().u32(999999).u32(2).bytes(), 198)
            self.assertEqual(wrong_capture.u16(), 303)
            capture = Writer().u32(wild_template).u32(2).bytes()
            with patch("secrets.randbelow", return_value=99):
                self.assertEqual((await send(15, capture, 112)).u8(), 1)
                msg, body, _ = await receive()
                attempt = Reader(body)
                self.assertEqual((msg, attempt.u16(), attempt.u16()), (198, 0, 2))
            with patch("secrets.randbelow", return_value=0):
                self.assertEqual((await send(15, capture, 112)).u8(), 1)
                msg, body, _ = await receive()
                caught = Reader(body)
                world_captured_uid = caught.u64()
                self.assertEqual((msg, json.loads(caught.string())["pokeID"]), (3141, wild_template))
                msg, body, _ = await receive()
                result = Reader(body)
                self.assertEqual((msg, result.u16(), result.u16()), (198, 0, 1))
            self.assertEqual((await send(15, capture, 112)).u8(), 1)
            msg, body, _ = await receive()
            duplicate = Reader(body)
            self.assertEqual((msg, duplicate.u16(), duplicate.u16()), (198, 0, 1))
            self.assertEqual(json.loads(duplicate.string())["objID"], world_captured_uid)
            self.assertEqual(await db.pool.fetchval(
                "SELECT count(*) FROM wild_battle_capture_attempts WHERE battle_id=("
                "SELECT max(battle_id) FROM tutorial_battle_sessions WHERE char_id=$1)", char_id), 2)
            wild_progress = await db.pool.fetchval(
                "SELECT progress FROM quests WHERE char_id=$1 AND quest_id=1503", char_id)
            self.assertEqual(json.loads(wild_progress) if isinstance(wild_progress, str)
                             else wild_progress, [1])
            wild_commit, _ = await commit_quest(1503)
            self.assertEqual((wild_commit.u16(), wild_commit.u32(), wild_commit.u8()), (0, 1503, 0))
            wild_commit.finish()

            # The starter's owned UID is assigned by PostgreSQL. The guide
            # commits depend on the saved Pet level and training stage.
            await db.pool.execute("UPDATE pets SET level=1,training_stage=0 WHERE pet_uid=$1", pet_uid)
            self.assertEqual((await commit_quest(10005))[0].u16(), 1)
            await db.pool.execute("UPDATE pets SET level=2 WHERE pet_uid=$1", pet_uid)
            feed_commit, feed_notifications = await commit_quest(10005)
            self.assertEqual((feed_commit.u16(), feed_notifications), (0, [112]))
            self.assertEqual((await receive())[0], 404)
            self.assertEqual(await db.pool.fetchval(
                "SELECT count FROM inventory WHERE char_id=$1 AND item_id=154", char_id), 3)
            replay_feed, _ = await commit_quest(10005)
            self.assertEqual(replay_feed.u16(), 0)
            self.assertEqual(await db.pool.fetchval(
                "SELECT count FROM inventory WHERE char_id=$1 AND item_id=154", char_id), 3)
            self.assertEqual((await commit_quest(10006))[0].u16(), 1)
            # Simulate a legacy save with an existing single cookie and no
            # supply receipt. Two concurrent login repairs top up once.
            await db.pool.execute("UPDATE inventory SET count=1 WHERE char_id=$1 AND item_id=154", char_id)
            await db.pool.execute(
                """UPDATE quest_reward_claims SET awards='{"awards":[],"pets":[]}'
                   WHERE char_id=$1 AND quest_id=10005""", char_id)
            await asyncio.gather(db.reconcile_starter_training(char_id), db.reconcile_starter_training(char_id))
            self.assertEqual(await db.pool.fetchval(
                "SELECT count FROM inventory WHERE char_id=$1 AND item_id=154", char_id), 3)
            await db.pool.execute("UPDATE pets SET training_stage=1 WHERE pet_uid=$1", pet_uid)
            self.assertEqual((await commit_quest(10006))[0].u16(), 0)
            self.assertEqual((await receive())[0], 404)
            group_ack = await send(136, Writer().u32(5).u32(99999).u32(0).bytes(), 210)
            self.assertEqual(group_ack.u16(), 0); self.assertEqual(group_ack.u8(), 1)
            group_enemy = json.loads(group_ack.string())
            self.assertEqual(group_enemy["mID"], 999994)
            self.assertEqual(group_enemy["skill1"], 541)
            self.assertEqual((group_ack.u32(), group_ack.u8()), (37, 0)); group_ack.finish()
            await win_battle(pet_uid, 37)
            battle_progress = await db.pool.fetchval(
                "SELECT progress FROM quests WHERE char_id=$1 AND quest_id=10007", char_id)
            self.assertEqual(json.loads(battle_progress) if isinstance(battle_progress, str)
                             else battle_progress, [1])
            self.assertEqual((await commit_quest(10007))[0].u16(), 0)
            child_ntf = Reader((await receive())[1]); spawned = []
            for _ in range(child_ntf.u8()):
                spawned.append(child_ntf.u32()); child_ntf.u8(); child_ntf.u64()
                for _ in range(child_ntf.u8()): child_ntf.u32()
            child_ntf.finish(); self.assertEqual(spawned, [10008])
            self.assertEqual(await db.pool.fetchval(
                "SELECT status FROM quests WHERE char_id=$1 AND quest_id=10007", char_id), 1)

            guided_wild = Writer().u32(1).u32(999997).u32(0).bytes()
            supply = await send(136, guided_wild, 112)
            self.assertEqual((supply.u8(), json.loads(supply.string())), (1, {"itemID": 2, "num": 3}))
            supply.finish()
            battle_start, battle_data, _ = await receive()
            self.assertEqual((battle_start, Reader(battle_data).u16()), (210, 0))
            retry = await send(136, guided_wild, 210)
            self.assertEqual(retry.u16(), 0)
            self.assertEqual(await db.pool.fetchval(
                "SELECT count FROM inventory WHERE char_id=$1 AND item_id=2", char_id), 3)
            with patch("secrets.randbelow", return_value=91):
                spent = await send(15, Writer().u32(26).u32(2).bytes(), 112)
                self.assertEqual((spent.u8(), json.loads(spent.string())), (1, {"itemID": 2, "num": 2}))
                spent.finish()
                result_id, result_body, _ = await receive()
                capture_retry = Reader(result_body)
                self.assertEqual((result_id, capture_retry.u16(), capture_retry.u16()), (198, 0, 2))
                self.assertEqual((capture_retry.string(), capture_retry.u32()), ("", 0))
                capture_retry.finish()
            with patch("secrets.randbelow", return_value=0):
                self.assertEqual((await send(15, Writer().u32(26).u32(2).bytes(), 112)).u8(), 1)
                self.assertEqual((await receive())[0], 3141)
                capture_id, capture_body, _ = await receive()
                capture = Reader(capture_body)
                self.assertEqual((capture_id, capture.u16(), capture.u16()), (198, 0, 1))
            self.assertEqual((await send(263, Writer().u16(0).vector_strings([]).bytes(), 186)).u16(), 0)
            self.assertEqual((await commit_quest(10008))[0].u16(), 0)
            self.assertEqual((await receive())[0], 404)
            self.assertEqual((await commit_quest(29999))[0].u16(), 0)
            self.assertEqual((await receive())[0], 404)
            self.assertEqual((await commit_quest(10009))[0].u16(), 1)

            # Consecutive clear protocol with synthetic star masks. Android
            # evidence is recorded separately from this persistence fixture.
            before_maps = await db.pool.fetchval("SELECT exp FROM characters WHERE char_id=$1", char_id)
            for adv_id, cells, exp, item, amount in (
                    (1, 30, 60, 10002, 1), (2, 30, 62, 2, 1), (3, 60, 64, 2, 2)):
                entered = await send(2996, Writer().u32(adv_id).bytes(), 3080)
                self.assertEqual((entered.u16(), entered.u32()), (0, adv_id))
                self.assertEqual(len(json.loads(entered.string())["events"]), cells)
                entered.finish()
                if adv_id == 2:
                    self.assertEqual((await send(136, trainer_request, 210)).u16(), 1)
                if adv_id == 3:
                    # Wise Arena's one-time cell 111 unwraps via DisposableInfo
                    # 7 to wild monster 1. Its authored capture count is zero.
                    self.assertEqual((await send(136, Writer().u32(2).u32(110).u32(0).bytes(), 210)).u16(), 1)
                    wild_scene = Writer().u32(2).u32(111).u32(0).bytes()
                    wild = await send(136, wild_scene, 210)
                    self.assertEqual((wild.u16(), wild.u8()), (0, 1))
                    wild_pet = json.loads(wild.string())
                    self.assertEqual(wild_pet["mID"], 1)
                    self.assertNotIn("canCatch", wild_pet)
                    self.assertEqual((wild.u32(), wild.u8()), (16, 0))
                    wild.finish()
                    await win_battle(pet_uid, 16)
                    self.assertEqual((await send(136, wild_scene, 210)).u16(), 1)
                    repeat = await send(2996, Writer().u32(3).bytes(), 3080)
                    self.assertEqual((repeat.u16(), repeat.u32()), (0, 3))
                    dismissed = next(event for event in json.loads(repeat.string())["events"]
                                     if event["sceneID"] == 111)
                    self.assertEqual((dismissed["type"], dismissed["eventID"]), (0, 0))
                    self.assertEqual((await send(136, wild_scene, 210)).u16(), 1)
                cleared = await send(3082, Writer().u16(8).bytes(), 2995)
                self.assertEqual((cleared.u16(), cleared.u8()), (0, 2))
                self.assertEqual(json.loads(cleared.string()),
                                 {"elementType": "exp", "elementID": 0, "num": exp})
                self.assertEqual(json.loads(cleared.string()),
                                 {"elementType": "item", "elementID": item, "num": amount})
                cleared.finish()
                if adv_id in (2, 3):
                    quest_notice, quest_body, _ = await receive()
                    quest = Reader(quest_body)
                    quest_id = 20000 if adv_id == 2 else 4
                    self.assertEqual((quest_notice, quest.u8(), quest.u32(), quest.u8()), (404, 1, quest_id, 0))
                    quest.u64()
                    self.assertEqual((quest.u8(), quest.u32()), (1, 1))
                    quest.finish()
                self.assertEqual([(await receive())[0], (await receive())[0]], [473, 1749])
            self.assertEqual(await db.pool.fetchval(
                "SELECT exp FROM characters WHERE char_id=$1", char_id), before_maps + 186)
            self.assertEqual([tuple(r) for r in await db.adventure_clears(char_id)],
                             [(1, 12), (2, 8), (3, 8)])
            self.assertEqual((await commit_quest(10009))[0].u16(), 0)
            gacha_unlocked = Reader((await receive())[1])
            self.assertEqual((gacha_unlocked.u8(), gacha_unlocked.u32()), (1, 10010))
            await db.pool.execute(
                """INSERT INTO quests(char_id,quest_id,status,progress)
                   VALUES($1,10032,0,'[0]'),($1,30000,0,'[0]')""", char_id)
            self.assertEqual((await commit_quest(30000))[0].u16(), 1)
            await db.pool.execute(
                "UPDATE quests SET status=1,progress='[1]' WHERE char_id=$1 AND quest_id=10032", char_id)
            self.assertEqual((await commit_quest(30000))[0].u16(), 0)
        finally:
            if writer:
                writer.close(); await writer.wait_closed()
            if server:
                server.close(); await server.wait_closed()
            if connections:
                await asyncio.gather(*list(connections))
            if account_id is not None:
                await db.pool.execute("DELETE FROM accounts WHERE user_id=$1", account_id)
            await db.close()
