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
