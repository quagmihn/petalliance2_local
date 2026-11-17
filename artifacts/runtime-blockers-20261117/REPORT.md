# MONSTER2 runtime blockers — verified 2026-11-17

**Release acceptance for the requested tutorial flow: PASS on Waydroid.**

Test database: `monster2_test_db`, role `quagmihn`, `rolsuper=false`, inherited
`TEST_DATABASE_URL`. Android gameplay used account 9 / character 10 / Pet UID 10,
template 7. Automated TCP tests create a separate random account and delete it
in cleanup. Production was never connected to or modified.

## Acceptance results

| Criterion | Result | Evidence |
| --- | --- | --- |
| Request 227 receives ACK 225 | PASS | Actual client callback resolves with code 0 in acceptance-evidence.log |
| No reconnect loop | PASS | No ack_timeout/Lua errors in final gameplay PID 2797 or relogin PID 2986; same live session used for create/end/commit |
| Pet Stage present and valid | PASS | Persisted training_stage=0; JSON Stage=0; real Pet rendered and fought |
| Player/enemy battle team rendered | PASS | Actual attacks and damage shown; Pet template 7 fought template 13 |
| Tutorial won by gameplay | PASS | victory.png; no SQL quest completion or artificial runtime result |
| Client request 263 / ACK 186 | PASS | Host 22:35:22, session f453c0bce762, code 0 |
| Quest 10001 completion / ACK 726 | PASS | Same session, request 400 with quest ID 10001; code 0 |
| Quest 2 and 10002 notification | PASS | ACK 404 contains both; client logs recv quest id and new mission 10002 |
| PostgreSQL progress | PASS | victory-database.log: 10001 status=1/progress=[1], 2 and 10002 status=0 |
| Battle state won | PASS | Actual completed encounter finished_at=22:35:22.454226+07 |
| Progress after cold login | PASS | relogin-database.log and relogin-complete.png; client receives 10001, 2, 10002; 2000 gold retained |
| Automated regression | PASS | 51 tests, zero skips/errors/failures, including actual TCP/PostgreSQL, Lua contracts, APK manifest |
| APK validation | PASS | Signature v1/v2/v3, configChanges verified; install -r preserved data |

Historical interrupted attempts remain `started`; the encounter completed in
the acceptance session is `won`. No old encounter was manually marked won.
Android logs use UTC; host/PostgreSQL logs use UTC+07.

## Root causes and changes

### Request 227 / ACK 225

Exact names: `CG_GETTREASUREBOXDATA_REQ` and `GC_GETTREASUREBOXDATA_ACK`.
`Proto_TreasureBox.lua` writes only the command WORD for the request. ACK decoder
reads WORD code, then NUL-terminated string `boxes` on success.
`TreasureBoxProcess` decodes that JSON into `TreasureBoxInfo`, which iterates
records with `type` and optional `time`. An account without awarded boxes has
an empty collection, as also represented by TreasureBoxInfo.Init().

TCP logs proved request 227 reached dispatch, which fell through to
startup_empty_ack and returned None. The new treasure handler reads validated
`game_values.treasure_boxes`, returning stored records or the new-account empty
collection. Integration tests use a nonempty persisted record to catch a
hardcoded empty response. Lua request/ACK decoder contract is exercised too.

Once 227 was fixed, real logs exposed two more missing startup reads causing
reconnect: `CG_GETLIFESKILLDATA_REQ` 128 / ACK 181 and `CM_READINFO_REQ` 690 /
ACK 721. Handlers now read character state using the actual Lua schemas;
missing new-account state is level/exp 0 or an empty ReadInfo string respectively.
Final clients received these ACKs and remained connected throughout battle.

### Pet data and BattleScene exit

The old serializer lacked `Stage` and JSON-encoded asyncpg JSONB strings a
second time: `skills`/`equips` became strings inside Pet JSON. BattleGetPetInfo
expects skill arrays with four indexed slots; its pairs() call and slot 4
energy access cannot consume a string/empty list. PetEducationMgrB also requires
numeric Stage. These were invalid payloads, not evidence that the Pet UID was
missing from PostgreSQL.

Stage is an independent strengthening counter: PetEducationMgrB uses
PetAdvanceInfo(Stage+1), and BattleBasicValueCalc uses it separately from star,
species and level. Added persistent `pets.training_stage` and
`passive_skills_json`; evolution remains separate. Fresh unstrengthened pets
start at Stage 0. Existing test character 10 alone had its empty legacy skill
lists initialized once by admin/repair_test_pet.py, using GeneInfo and weighted
GeneProbabilityInfo, then persisted. That tool refuses char 2/account 6 and
requires the named non-superuser test database. It never edits quest/battle state.

Pet serialization now decodes JSONB arrays, supplies four configured active
skills and resolved passive skill IDs, and validates UID/template/skills/Stage/
HP/collections. Personal stat training counters are 0 for the untrained starter;
HP is calculated from the same PokemonInfo race data and BattleBasicValueCalc
formula, with strengthening/star modifiers. Actual starter HP was 171.
Primary and helper formation vectors now agree with army 1 / 1h UID arrays.
Tests cover all three starter templates, malformed payload rejection, independent
Stage/evolution, and primary/helper UID consistency.

The client SceneMgr used pcall and silently fell back to the preceding scene on
initialization errors. The rebuilt APK logs a traceback for scene requests and
uses xpcall to retain initialization failure stacks. After valid Pet data,
BattleScene remained playable. The observed final BattleScene -> Town stack is
the victory exit button callback in BattleCCSB.lua:2188, after ACK 186/726;
see scene-exit-evidence.log. No battle bypass or forced result was added.

A further real battle error was HP: 1782 in MonstrosityInfo is a per-mille
modifier, not an absolute HP value. The client calculated maxHP=208 but the
server sent currentHP=1782. The server now derives current HP from the config:
floor(117 * 1782 / 1000) = 208. The final actual battle used 208/208 and ended
with the client's normal victory/result/quest requests.

### Activity lifecycle during relogin

Repeated starts exposed an Activity configuration recreation: onDestroy followed
by cocos_android_app_init twice in the same PID and native Application assertion.
AppActivity configChanges lacked screenLayout, smallestScreenSize and density.
The rebuilt APK adds those flags (0x400006e4 -> 0x40001fe4), preserving all other
manifest data. Cold relogin then succeeded and retained quest progress.

Only AndroidManifest.xml and encrypted SceneMgr.lua differ from the previous
APK, excluding signing metadata. Native libraries and other assets are identical.
Waydroid was unfrozen through its approved ContainerManager.Unfreeze method;
no container service restart or Android system image edit was performed.

## Protected data and practical limits

Account 6 in the test database has identical before/after fingerprints.
Character 2 was absent from the test database before and after; it was never
created, modified or deleted. Production account 6/character 2 was not accessed.
No production role, pg_hba.conf, or superuser test execution was used.

The acceptance covers this tutorial path. Existing language-key display,
compressed audio/video asset errors, and later unsupported game systems remain
outside these fixes; this is not certification of every gameplay feature.

## Artifacts and reproduction

- APK: `dist/monster2_runtime.apk` (not committed; generated binary).
- SHA256: `358d9b8bccb046ee83e86e240890f7f24e60a31d8c2b2e98718c9c1f48161002`.
- Build from the existing base with `python tools/build_runtime_client.py`,
  zipalign output to `dist/monster2_runtime-aligned.apk`, then sign with the
  existing dist/debug.keystore into dist/monster2_runtime.apk.
- Run from server/: `python -m unittest discover -s tests -v`, inheriting
  TEST_DATABASE_URL. Use command-specific approval for socket/TCP restrictions.
- `test_postgres_tcp.py` uses real network and PostgreSQL but a synthetic combat
  result fixture; Android victory evidence is separately recorded above.
- Committed evidence logs are filtered to exclude raw client auth credentials.
  Raw logcat captures remain local for diagnosis.

The test HTTP 8080 / TCP 5568 servers and Waydroid remain available for follow-up.
