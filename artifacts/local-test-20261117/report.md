# Local validation 2026-11-17

Workspace: /home/quagmihn/Project/monster2_rebuild (actual spelling).
SQL homeName parameter now explicitly casts $2::text. Live regression remains unverified because database authentication fails before SQL execution.

| Test | Execution environment | Status | Log file | Evidence |
|---|---|---|---|---|
| Python unit suite | Local Python 3.14, PYTHONPATH=server | PASS | python-suite.log | 44 passed; one PostgreSQL test skipped in discovery and executed separately below |
| PostgreSQL integration | Outside sandbox; asyncpg; Unix socket /run/postgresql; monster2_test_db; quagminh | BLOCKED | postgres.log | Actual test attempted; InvalidAuthorizationSpecificationError: role "quagminh" does not exist |
| Lua parser/serializer | Local Lua, Python harness | PASS | lua-protocol.log, lua-suite.log | LUA_BATTLE_PROTO_OK; harness suite passed |
| Existing APK build artifact verification | Local Android SDK; dist/monster2_localized.apk | PASS | apk-signature.log, apk-alignment.log, apk-package.log | v1/v2/v3 signatures verified; zip alignment successful; package com.petalliance2.sea |
| Fresh APK rebuild | Local workspace | BLOCKED | report.md | Not executed; only existing artifact validated; no client source changed |
| APK installation | Host-context Waydroid diagnostic outside sandbox | BLOCKED | waydroid-status.log, android-boot.log | Session STOPPED; sudo -n requires a password; installation not attempted |
| Android runtime initialization | Host-context diagnostic outside sandbox | BLOCKED | android-boot.log | sudo: a password is required; boot completion unverified |
| TCP server/client integration | Android client + dedicated PostgreSQL required | BLOCKED | postgres.log, waydroid-status.log | Database role absent and Android session unavailable |
| Loading completion | Android runtime | BLOCKED | waydroid-status.log, android-boot.log | No new runnable client session |
| TownScene interactive entry | Android runtime | BLOCKED | waydroid-status.log, android-boot.log | No runtime scene evidence |
| Tutorial quest and battle progression | Android runtime + dedicated PostgreSQL | BLOCKED | postgres.log, android-boot.log | Prerequisites unavailable |
| Same-session protocol traces | Android client + server | BLOCKED | postgres.log, waydroid-status.log | No correlated session for 136→210, 263→186, 400→726, 785→26, NTF404, 45→35, 1644→1664, 501→498 |

Exact loading stop cannot be determined without a current correlated session. Historical logs were not treated as current evidence. No production database access, account_id=6/char_id=2 modification, app reset, or APK installation was performed. Escalation was requested and used for the actual PostgreSQL test and Waydroid diagnostics; these host-context commands still hit the restrictions above.
