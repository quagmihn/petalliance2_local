import json
import sqlite3
import unittest
from pathlib import Path

from client_config import table


ROOT = Path(__file__).resolve().parents[2]


class CaptureShopClientContractTests(unittest.TestCase):
    def test_confirmation_uses_market_catalog_price(self):
        product = table("MarketInfo")[201]
        self.assertEqual((product["itemID"], product["coinType"], product["num"]), (1, 2, 600))
        lua = (ROOT / "decoded_lua/assets/src/GameMgr/Battle/BattleCCSB.lua").read_text()
        self.assertIn("ItemInfo.getMarketInfoById(201)", lua)
        self.assertIn('createStringWithFormat({"advtips9", tostring(price)})', lua)
        self.assertNotIn('showSmallDialogBox(SceneMgr.getRunningScene,2,"advtips9"', lua)

    def test_all_packaged_locales_have_dynamic_price_placeholder(self):
        paths = sorted((ROOT / "apk_extracted/assets/res/Config/db").glob("lang*.db"))
        self.assertEqual(len(paths), 6)
        for path in paths:
            with sqlite3.connect(path) as conn:
                row = conn.execute("SELECT lang FROM tbl_lang WHERE code='advtips9'").fetchone()
                self.assertIsNotNone(row, path.name)
                value = row[0]
                self.assertIn("<1>", value, path.name)
                self.assertNotIn("100", value, path.name)

    def test_android_recharge_buttons_use_local_ordered_protocol_path(self):
        pay = (ROOT / "decoded_lua/assets/src/Utils/pay/PayConfig.lua").read_text()
        purchase = (ROOT / "decoded_lua/assets/src/GameMgr/Item/PurchaseViewMgr.lua").read_text()
        builder = (ROOT / "tools/build_runtime_client.py").read_text()
        self.assertIn('function PayConfig.payLocal(id, isMonthCard)', pay)
        self.assertIn('appID = "local:"..kind..tostring(id)..":"..', pay)
        self.assertIn('PayConfig.payLocal(v.id, false)', purchase)
        self.assertIn('PayConfig.payLocal(MoonInfo.id, true)', purchase)
        self.assertNotIn('PayConfig.pay(v.id)', purchase)
        self.assertNotIn('iOSFunction.BuyItem(scene, v.id)', purchase)
        self.assertIn('"assets/src/Utils/pay/PayConfig.lua"', builder)
        self.assertIn('"assets/src/GameMgr/Item/PurchaseViewMgr.lua"', builder)


if __name__ == "__main__":
    unittest.main()
