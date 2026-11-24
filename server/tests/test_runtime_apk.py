import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


class RuntimeAPKContract(unittest.TestCase):
    def test_activity_handles_waydroid_resize_configuration(self):
        result = subprocess.run(["aapt", "dump", "xmltree", str(ROOT / "dist/monster2_local-guide-runtime.apk"),
                                 "AndroidManifest.xml"], check=True, capture_output=True, text=True)
        activity = result.stdout.split('"org.cocos2dx.lua.AppActivity"', 1)[1].split("E: intent-filter", 1)[0]
        value = int(activity.split("configChanges", 1)[1].split("=(type 0x11)", 1)[1].strip().split()[0], 16)
        self.assertEqual(value & 0x1900, 0x1900)
