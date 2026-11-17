import asyncio
import struct
import unittest

from protocol import (Reader, Writer, frame, read_frame, redact_payload,
                      redact_response_payload, safe_request_fields, success_code,
                      xor_payload)


class ProtocolTests(unittest.TestCase):
    def test_little_endian_frame_and_distinct_ack_mapping(self):
        packet = frame(2130, b"alice\0secret\0")
        self.assertEqual(packet[:4], struct.pack("<HH", 17, 2130))
        self.assertNotEqual(2130, 2126)
        self.assertEqual(len(success_code().bytes()), 9)

    def test_xor_is_symmetric_and_keeps_frame_header_outside(self):
        body = b"test payload with mixed sizes"
        self.assertEqual(xor_payload(xor_payload(body)), body)
        self.assertEqual(frame(1, body)[:4], struct.pack("<HH", 4 + len(body), 1))

    def test_redaction_preserves_parseable_lengths(self):
        payload = Writer().string("device-id").string("1").string("device-token").bytes()
        safe = redact_payload(2211, payload)
        self.assertEqual(len(safe), len(payload))
        self.assertNotIn(b"device-id", safe)
        self.assertNotIn(b"device-token", safe)
        self.assertEqual(safe_request_fields(2211, payload)["world_id"], "1")

        ack = success_code().u8(1).string("device-id").string("1").string("device-token").bytes()
        redacted_ack = redact_response_payload(2126, ack)
        self.assertEqual(len(redacted_ack), len(ack))
        self.assertNotIn(b"device-token", redacted_ack)


class FrameReadTests(unittest.IsolatedAsyncioTestCase):
    async def test_fragmented_and_concatenated_frames(self):
        reader = asyncio.StreamReader()
        one = frame(2130, xor_payload(b"a\0b\0"))
        two_body = b"d\0" + b"1\0t\0"
        two = frame(2211, xor_payload(two_body))
        task = asyncio.create_task(read_frame(reader))
        reader.feed_data(one[:1])
        await asyncio.sleep(0)
        reader.feed_data(one[1:4])
        reader.feed_data(one[4:] + two)
        first = await task
        second = await read_frame(reader)
        self.assertEqual(first, (2130, b"a\0b\0", len(one)))
        self.assertEqual(second, (2211, two_body, len(two)))

    async def test_truncated_frame_raises(self):
        reader = asyncio.StreamReader()
        reader.feed_data(b"\x08\x00\x01")
        reader.feed_eof()
        with self.assertRaises(asyncio.IncompleteReadError):
            await read_frame(reader)


if __name__ == "__main__":
    unittest.main()
