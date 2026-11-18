import unittest
from types import SimpleNamespace
import asyncio
import os
from unittest.mock import patch

from handlers import economy
from http_gateway import handle as http_handle
from protocol import Reader, Writer


class NoWriteDB:
    async def grant_item(self, *args, **kwargs):
        raise AssertionError("unvalidated purchase attempted a database write")


class EconomySafetyTests(unittest.IsolatedAsyncioTestCase):
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
