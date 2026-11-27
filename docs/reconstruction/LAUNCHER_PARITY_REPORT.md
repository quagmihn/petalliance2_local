# Official launcher parity

The default invocation from the repository is `./server/run_all.sh`.
It loads the private `local` profile, verifies `monster2_db`, and serves
the configured Waydroid bridge. The tracked defaults select the current
Gacha catalog and local-only payment. Plain settings in the optional
ignored `server/.env.production` can configure connection details.
Explicit `production` disables simulation. The test profile requires an
explicit test database connection. The play option retains its separate
legacy database.

Startup records Git commit, both database pools, listener addresses, the
expected Android package and hash, and the resolved content hashes. It
fails for occupied ports without stopping the listening process.

## Acceptance on 2026-11-25

Run A launched `server/run_all.sh` as the official user service. Run B
started with `./server/run_all.sh` from the project root in an ordinary
terminal. Both reported commit `5f9a078efb8f15b6ab47a71228309b6149d26958`,
the same source directory, Waydroid endpoints 192.168.240.1:8080 and :5568,
and `monster2_db` as `monster2`. Each HTTP and TCP child verified its own
pool. Run A used PIDs 14320 and 14321. Run B used 14897 and 14898.

The normalized startup records match byte for byte, including the
configuration paths and hashes, expected APK, simulated payment mode
and commit. The HTTP version responses also match byte for byte. The
Gacha catalog hash is
`30e863eb46d64ff40f5d137cca98685a4993fd1e1495493249555afa74247900`.
The previous manual replay also tried a second launch while both ports
were owned. It returned the listening PIDs and preserved both processes.
Ctrl+C exited 130 and released both listeners.

Evidence is stored locally in `artifacts/gameplay-runtime-20261124`,
including `launcher-a-5f9a078.log`, `launcher-b-5f9a078.log`, their
matching `.identity` files and `version-a.xml` / `version-b.xml`.

[Current parity evidence](EXECUTION_CHECKPOINT.md)
# 2026-11-26 Pet and economy deployment

The official project is `/home/quagmihn/Project/monster2_rebuild`. The
default `server/run_all.sh` command selected private local payment,
VIP Shop unlimited, the three verified local Gacha pools, and
`monster2_db` as role `monster2`. The controlled Waydroid suite used
the same launcher in test mode. Both listeners independently logged their
database identity. `./server/run_all.sh doctor` provides the report
while the production listeners are already active.

The first production start on gameplay commit `3fb9561` opened HTTP 8080
as PID 20023 and TCP 5568 as PID 20024. The dirty flag at that start
reflected pending documentation changes. The final startup log recorded
with the documentation commit is `production-launcher-final.log` under
`artifacts/pet-economy-20261126/`.

The backup in that folder has SHA256
`93367692c8ed72d7d758c70ca800367ff3bff83a108c0a56d41aae156a20ab2f`.
Restore verification is in `restore.log`. Rollback uses the previous
server source and the preserved `installed-base.apk` with the same
signing certificate. Both new ledger tables can remain in place. Keep
the owner character and any newer transactions if a release rollback is
needed. The signed current APK and all QA evidence are recorded in the
[execution checkpoint](EXECUTION_CHECKPOINT.md).

## 2026-11-26 · Private freedom and expanded economy

The official `./server/run_all.sh` started the clean milestone `4768edb6afe0e1e6ae9ed7ac155a1496a649c3d6` and then the profile fix `822403b93b73b337e49dff208a56222dfe426287` from `/home/quagmihn/Project/monster2_rebuild`. Final HTTP PID 13990 listened on 8080 and TCP PID 13991 on 5568. The final startup marked the worktree dirty due to the pending report edits. Both listeners bound to the Waydroid bridge and independently authenticated to `monster2_db` as `monster2`. The integration profile used `monster2_test_db` as `quagmihn`.

- Payment provider `local` and simulated checkout are active on the private profile.
- The launcher prints the three freedom/storage flags, source and effective Gacha pool hashes, content hashes, and the expected APK hash. The effective Gacha pool SHA256 is `a145820735be48148e59543dfee6e4cce7fc6fa52a1329f793f8ec0de33ac677`.
- The installed APK is package `com.petalliance2.sea`, version code 7, SHA256 `e0c0fb48914610f158de5368cd45218534bdac77b9495bfe16032f74628cf10c`. `apksigner verify` confirmed signer SHA256 `f6a9b74ac979b6f3c221eb0b21789619b1238c89ca813b9033a60425cf489a3a`. The previous APK remains in `dist/` for rollback.
- The production dump `artifacts/freedom-level50-20261126/monster2_db-before.dump` has SHA256 `5a8f7db861ecae098a6f11fdd32092dace91cf48e7216d30bfce17ffb4266111`. It was restored in a separate socket-only cluster under a non-superuser role. The restore contained 207 constraints, 5 characters, 72 Pets, 83 inventory rows, and the matching owner state.
- The release suite passed 141 tests with `TEST_DATABASE_URL=postgresql:///monster2_test_db` and zero skips. The APK overlay's Lua files also passed `luac -p`. Deployment uses existing DB tables and the character JSON field.

## 2026-11-27 · Chest, Market and Adventure economy

`./server/run_all.sh doctor` verified the local profile, release APK, target content hashes, 90 Market offers, 236 chest plans and 270 sweep configurations. The local startup exposed HTTP 8080 and TCP 5568 on `192.168.240.1`. HTTP PID 3602 and TCP PID 3603 independently connected to `monster2_db` as `monster2`. The startup recorded clean code `4d088379d84067b4a06deb420273059e0a708ef7` and the official project source path. QA ran the same source through the launcher's `test` profile, connecting to `monster2_test_db` as `quagmihn`.

- Installed package `com.petalliance2.sea`, version code 7. Installed APK SHA256 `dafb7f8c1dd5a877d6c6d07e440f5c504cb5bb125aa2389f0bd6a9cb24f4f2e3`. The existing signer SHA256 `f6a9b74ac979b6f3c221eb0b21789619b1238c89ca813b9033a60425cf489a3a` allowed updating in place, with app data retained.
- `minh` was verified in PostgreSQL and on cold Waydroid login as account 6, character 2, Level 50 and VIP 20. Live Market displays 999999999 silver; the genuine stored balance remains 10600. Ground taps in the live Town also produced 45 → 35/code 0. Owner purchase resources were preserved during acceptance.
- Backup SHA256 `9ddee5cfad95db65aaede4185b4df33e4b3488963bde58a1990924abf2889dca`. The backup was restored as a non-superuser in an isolated PostgreSQL cluster before deployment. No schema migration was needed. Source and APK rollback points are `822403b93b73b337e49dff208a56222dfe426287` and `dist/monster2_local-freedom-runtime.apk`. Keep newer player state if rolling back source or APK.
- PostgreSQL regression passed 150 tests with no skips. Changed Lua files passed `luac -p`, and the APK passed signature and alignment checks.

Artifacts under `artifacts/adventure-economy-20261126/` include `live.log`, `doctor-final.log`, `live-minh-cold-login.png`, `live-minh-market-silver.png`, both QA logs, and the isolated backup verification. The artifact directory is local to the project machine.

## Arena lobby, Market and Pet progression · 2026-11-27

The active official invocation is `./server/run_all.sh` from `/home/quagmihn/Project/monster2_rebuild`. Revision `e4dc8e12b38f6499d0d1bc4e2b4e5d0d26169f2e` serves from its tracked server tree. The startup dirty flag was caused by contemporaneous documentation edits. At 16:43 ICT, HTTP 81769 and TCP 81770 independently verified `monster2_db` as `monster2`; both ports bind to 192.168.240.1. The QA test profile verified the same catalogs against `monster2_test_db` as `quagmihn` and was stopped before the local profile started.

| Checked value | Recorded identity |
| --- | --- |
| APK SHA256 | `dafb7f8c1dd5a877d6c6d07e440f5c504cb5bb125aa2389f0bd6a9cb24f4f2e3` |
| Installed signing certificate SHA256 | `f6a9b74ac979b6f3c221eb0b21789619b1238c89ca813b9033a60425cf489a3a` |
| Market pricing SHA256 | `5b1acca7265f6d0b6b689914ba25180166bf21a8aab9330e911197a0290257e1` |
| NPC catalog SHA256 | `3058108688d9739e898edb30473bd64634f285093e68e17478296735a56724db` |
| Effective Gacha pool SHA256 | `a145820735be48148e59543dfee6e4cce7fc6fa52a1329f793f8ec0de33ac677` |

The backup and isolated restore preceded the additive Pet training and Relation column. For rollback, restart the previous server revision with the same configuration and leave the additive column in place to retain any new Pet progression. If an individual data correction is necessary, use a targeted transaction against the recorded affected rows. The safety evidence is in `artifacts/arena-missions-20261127/`.
