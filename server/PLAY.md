# Start Monster2

Run `./server/run_all.sh` from the project root, or invoke the launcher by
absolute path. It defaults to `monster2_db` as role `monster2`, using the
system PostgreSQL Unix socket in `/run/postgresql`. Start Waydroid before
connecting the Android client.

Hosts with different PostgreSQL connection settings can set DATABASE_URL in
`server/.env.production`. Use Bash assignments and mode 0600. The file is
ignored by Git. Local PostgreSQL authentication can supply credentials
without storing them in the launcher.

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

### Local draw trials

Configure `MONSTER2_TEST_DRAW_CATALOG` with the path to your JSON prize pool
when running the test launcher. Use a machine index as the key and a list of
`item_id`, `count`, and positive integer `weight` records as the value. The
server validates the item IDs and reads the prices and cooldowns from the
metadata already used by the client. Use only the independent QA account.
Launch with the QA APK pointing at the same test ports.

The JSON prizes define local test behavior. This does not use the original
reward pools or apply first-draw bonuses, guarantees, wish, dream, or VIP
rules. The local draw route requires `GAME_ENV=test`, the actual database
`monster2_test_db`, and a character created with `--independent`.

The verified gameplay APK is `dist/monster2_gameplay.apk`, SHA256
`2957196b52dc2d86e87e1df8a5ab878aa0bf8f66c91407e17f2bff00af70f90f`.
Keep signed APKs and database backups outside Git.
