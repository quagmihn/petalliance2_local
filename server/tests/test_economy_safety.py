import unittest
from types import SimpleNamespace
import asyncio
import os
import secrets
from unittest.mock import patch

from handlers import economy
from http_gateway import handle as http_handle
from protocol import Reader, Writer


class NoWriteDB:
    async def grant_item(self, *args, **kwargs):
        raise AssertionError("unvalidated purchase attempted a database write")


class EconomySafetyTests(unittest.IsolatedAsyncioTestCase):
    def test_wallet_notification_uses_committed_character_columns(self):
        row = {"currencies_json": {"diamond": 999999999, "m_cash": 999999999, "viplevel": 0,
                                    "g_cash": 999999999, "goldCoin": 7},
               "gold": 30, "diamond": 1200, "stamina": 9,
               "vip_level": 2, "vip_points": 50}
        ack_id, payload = economy.wallet_update(row)
        from json import loads
        values = loads(Reader(payload).string())
        self.assertEqual(ack_id, 473)
        self.assertEqual((values["diamond"], values["m_cash"]), (1200, 1200))
        self.assertEqual((values["gold"], values["g_cash"]), (30, 30))
        self.assertEqual(values["goldCoin"], 7)
        from client_config import table
        self.assertEqual(table("VipInfo")[values["viplevel"]]["viplevel"], row["vip_level"])

    async def test_unknown_market_catalog_does_not_grant_or_return_success(self):
        session = SimpleNamespace(db=NoWriteDB(), char_id=2)
        ack_id, payload = await economy.buy_market(
            session, Writer().u32(5001).u32(2).bytes())
        self.assertEqual(ack_id, 563)
        self.assertEqual(Reader(payload).u16(), 1)

    async def test_unknown_purchase_is_rejected_without_database_mutation(self):
        session = SimpleNamespace(db=NoWriteDB(), char_id=2, account_id=6)
        ack_id, payload = await economy.buy_market(
            session, Writer().u32(5001).u32(2).bytes())
        self.assertEqual((ack_id, Reader(payload).u16()), (563, 1))

    async def test_test_recharge_is_not_a_successful_fake_payment(self):
        session = SimpleNamespace(db=NoWriteDB(), char_id=2)
        ack_id, payload = await economy.recharge_test(
            session, Writer().u32(2).string("1").bytes())
        self.assertEqual(ack_id, 89)
        self.assertEqual(Reader(payload).u16(), 1)

    async def test_local_recharge_catalog_gate_idempotency_and_month_card(self):
        dsn = os.getenv("TEST_DATABASE_URL")
        if not dsn:
            self.skipTest("TEST_DATABASE_URL required")
        from db.database import Database
        db = await Database.connect(dsn)
        username = "recharge-test-" + secrets.token_hex(8)
        try:
            self.assertEqual(await db.pool.fetchval("SELECT current_database()"),
                             "monster2_test_db")
            await db.initialize()
            account_id = await db.pool.fetchval(
                "INSERT INTO accounts(username,token) VALUES($1,$2) RETURNING user_id",
                username, secrets.token_hex(16))
            char_id = await db.pool.fetchval(
                "INSERT INTO characters(account_id,world_id,name) VALUES($1,1,$2) RETURNING char_id",
                account_id, username)
            session = SimpleNamespace(db=db, char_id=char_id, account_id=account_id)
            order = "local:N2:test-order-" + secrets.token_hex(8)
            body = Writer().u32(2).string(order).bytes()
            with patch.dict(os.environ, {"LOCAL_PAYMENT_SANDBOX": "1", "PAYMENT_PROVIDER": "local", "GAME_ENV": "test"}):
                result = await economy.recharge_test(session, body)
                self.assertEqual([msg for msg, _ in result], [473, 89])
                values = __import__("json").loads(Reader(result[0][1]).string())
                self.assertEqual(values["diamond"], 160)
                self.assertEqual(values["recharge"]["totalMoney"], 99)
                self.assertEqual(Reader(result[1][1]).u16(), 0)
                duplicate = await economy.recharge_test(session, body)
                self.assertEqual(Reader(duplicate[1][1]).u16(), 0)
                self.assertEqual(await db.pool.fetchval(
                    "SELECT diamond FROM characters WHERE char_id=$1", char_id), 160)
                self.assertEqual(await db.pool.fetchval(
                    "SELECT count(*) FROM local_recharge_transactions WHERE char_id=$1 "
                    "AND simulated AND package_id=2", char_id), 1)
                month_order = "local:M10001:test-order-" + secrets.token_hex(8)
                month = await economy.recharge_test(
                    session, Writer().u32(10001).string(month_order).bytes())
                self.assertEqual(Reader(month[1][1]).u16(), 0)
                row = await db.pool.fetchrow(
                    "SELECT diamond,month_card_until,recharge_total FROM characters WHERE char_id=$1",
                    char_id)
                self.assertEqual((row["diamond"], row["recharge_total"]), (560, 598))
                self.assertIsNotNone(row["month_card_until"])
                card_request = Writer().i32(10001).bytes()
                claim = await economy.take_month_card(session, card_request)
                self.assertEqual([msg for msg, _ in claim], [473, 3103])
                duplicate = await economy.take_month_card(session, card_request)
                self.assertEqual(Reader(duplicate[1][1]).i32(), 0)
                self.assertEqual(await db.pool.fetchval(
                    "SELECT diamond FROM characters WHERE char_id=$1", char_id), 720)
                self.assertEqual(Reader((await economy.take_month_card(
                    session, Writer().i32(10002).bytes()))[1]).i32(), 1)
                renew_order = "local:M10001:renew-" + secrets.token_hex(8)
                await economy.recharge_test(session, Writer().u32(10001).string(renew_order).bytes())
                renewed = await db.pool.fetchval(
                    "SELECT month_card_until FROM characters WHERE char_id=$1", char_id)
                self.assertEqual((renewed - row["month_card_until"]).days, 30)
                await economy.take_month_card(session, card_request)
                self.assertEqual(await db.pool.fetchval(
                    "SELECT diamond FROM characters WHERE char_id=$1", char_id), 1120)
                await db.pool.execute(
                    "UPDATE local_month_cards SET expires_at=now() WHERE char_id=$1", char_id)
                self.assertEqual(Reader((await economy.take_month_card(session, card_request))[1]).i32(), 1)
            with patch.dict(os.environ, {"LOCAL_PAYMENT_SANDBOX": "0", "PAYMENT_PROVIDER": "local", "GAME_ENV": "test"}):
                rejected = await economy.recharge_test(session, body)
                self.assertEqual((rejected[0], Reader(rejected[1]).u16()), (89, 1))
        finally:
            await db.pool.execute("DELETE FROM accounts WHERE username=$1", username)
            await db.close()

    async def _request_http_payment(self, sandbox):
        class MemoryWriter:
            def __init__(self): self.output = bytearray()
            def get_extra_info(self, _name): return ("test-peer", 1)
            def write(self, data): self.output.extend(data)
            async def drain(self): pass
            def close(self): pass
            async def wait_closed(self): pass

        with patch.dict(os.environ, {"LOCAL_PAYMENT_SANDBOX": sandbox}):
            reader = asyncio.StreamReader()
            reader.feed_data(b"POST /pay HTTP/1.1\r\nHost: localhost\r\nContent-Length: 2\r\n\r\n{}")
            reader.feed_eof()
            writer = MemoryWriter()
            await http_handle(reader, writer, None)
            return bytes(writer.output)

    async def test_http_payment_never_returns_fake_success(self):
        disabled = await self._request_http_payment("0")
        self.assertIn(b"403 Forbidden", disabled)
        self.assertIn(b"sandbox_disabled", disabled)
        configured = await self._request_http_payment("1")
        self.assertIn(b"501 Not Implemented", configured)
        self.assertIn(b"sandbox_adapter_unconfigured", configured)


if __name__ == "__main__":
    unittest.main()
