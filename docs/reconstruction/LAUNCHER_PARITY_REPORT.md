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
