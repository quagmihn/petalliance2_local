# Start Monster2

Run `./server/run_all.sh` from the project root, or invoke the launcher by
absolute path. It defaults to `monster2_db` as role `monster2`, using the
system PostgreSQL Unix socket in `/run/postgresql`. Start Waydroid before
connecting the Android client.

Hosts with different PostgreSQL connection settings can set DATABASE_URL in
`server/.env.production`. Use Bash assignments and mode 0600. The file is
ignored by Git. Local PostgreSQL authentication can supply credentials
without storing them in the launcher.

The default `local` profile is defined in `server/config/local-play.env`.
It enables simulated checkout and M-PASS on the private Waydroid bridge or
loopback. The optional ignored environment file can configure the database
connection. Explicit `./server/run_all.sh production` disables checkout
simulation.

The default ports are HTTP 8080 and TCP 5568. Ctrl+C shuts down both children.
Run `./server/run_all.sh test` with an explicit DATABASE_URL for
`monster2_test_db`. Use `./server/run_all.sh play` with `server/.env.play`
for the previous `monster2_play_db` environment. The launcher verifies the
actual database identity before either service starts.

## Independent QA accounts

Create a fresh account on `monster2_test_db` with a starting level, wallet and
item stacks suited to the scenario. The fixture reads its connection from
`TEST_DATABASE_URL` and checks the server-reported database and role before
writing. Run the command first as a dry run, then rerun it with `--apply`.

```bash
python server/admin/copy_legacy_character_test.py --fresh-control \
  --level 2 --gold 500 --diamond 250 --item 1 3 \
  --manifest artifacts/legacy-pet-compat-20261118/example-qa.json
```

For an Android QA device whose binding already exists in `monster2_test_db`,
add `--device-id <test-device-id>` to use that device's existing test login.
Point the QA client at the test launcher. Keep the private manifest outside
Git and use it to remove the fixture and restore the previous test binding.

```bash
python server/admin/copy_legacy_character_test.py \
  --rollback artifacts/legacy-pet-compat-20261118/example-qa.json
```

This fixture supplies starting resources. Quest and tutorial progression still
follow the normal client and server paths. Record fixture based interactions
separately from a sequential tutorial playthrough.

For independent checks, add `--independent` and choose level 2 or above. This
creates an isolated account without the starter guide. Use `--active-quest ID`
to seed an active non-tutorial quest and `--cleared-adventure ID MASK` to seed a
clear prerequisite. Both flags are repeatable. These seeds establish a test
starting point. They do not exercise the preceding quest or Adventure.

### Local draw catalog

The launcher defaults to `server/config/local_play_draw.json`. It validates
reward IDs against the packaged templates and prints configuration and asset
hashes before opening the ports. Ordinary x10 draws make ten selections from
the machine's local weighted pool. The exact original server's sequence,
Wish, Dream and VIP rules remain unverified. Prior catalog definitions remain
in `server/config`. To select one in an isolated test, set
`MONSTER2_DRAW_CATALOG` to its server-relative or absolute path.

Active guide 10010 owns a single scripted free Supreme Panda draw after the
free Senior step. The draw and quest progress share one transaction. Use the
isolated account fixture for ordinary test draws. The patched runtime APK
sends a replay key. Identical legacy paid requests without a key are rejected
for eight seconds after a draw.

The current Android release is `dist/monster2_local-guide-runtime.apk`, SHA256
`b469bf2b35885edee69427600a31f41bb55c2b92bcae0bbb9f3c7236d00414b6`.
`dist/monster2_patched.apk` is the client build input. The signing keystore
and fresh-install OBB are also in `dist`. Older releases are archived locally
under `artifacts/dist-cleanup-20261124/archive/`.
See the [runtime checkpoint](../docs/reconstruction/EXECUTION_CHECKPOINT.md)
for the matching official server commit and Android acceptance.
Keep signed APKs and database backups outside Git.
