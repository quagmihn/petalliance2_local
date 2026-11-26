# Wardrobe acceptance

Private-local freedom is an opt-in character attribute. The APK requests it from PostgreSQL-backed character values. The Profile → COSTUME button respects that attribute independently of the story map lock, and the existing wardrobe keeps its own ownership and save logic.

Waydroid QA account 848 / char 834 equipped Silver Helmet and saved through 2121/2109. Redeeming vouchers 32001 and 33001 produced owned costume entries through 516/526 and 2105. The final look, `[1003,2001,3001,0,5023,1]`, appeared after a cold launch. Screenshots `qa-fashion-equipped.png` and `qa-return-cold.png` are in the runtime evidence directory.

The current catalog links 291 wearable vouchers. Supreme admits 172 visible vouchers whose icons and appearance images exist. Owned equipment instances, mounts, furniture placement, and a complete runtime pass across all wearable slots remain open.

On the first production startup the profile's 1261 response omitted `fashion.curFashion`, even though Wardrobe ACK 2102 already contained it. This caused a recorded Lua exception and an empty avatar panel. The follow-up revision shares the same state loader between the two responses. The final `owner-profile-restored-appearance.png` shows the restored avatar after a server restart and cold login.
