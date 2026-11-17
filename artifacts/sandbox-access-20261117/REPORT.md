# MONSTER2 verification — 2026-11-17

## Access and database

Effective session policy is workspace-write/restricted network. Project and /tmp
are writable; .git, .codex, .agents and .aws are read-only. Project .codex and
.agents contain no configuration or AGENTS.md. No sandbox configuration was
changed. Unix socket access from the sandbox failed with PermissionError:
Operation not permitted. systemctl inside the sandbox likewise could not reach
the system bus. Per-command require_escalated approvals successfully enabled the
same tests and host diagnostics; full system access was not requested.

TEST_DATABASE_URL was inherited from the Codex session without replacement:
postgresql:///monster2_test_db?host=/run/postgresql

The server processes also use this URL, assigned to their DATABASE_URL explicitly.
Verified current_database=monster2_test_db, current_user=quagmihn, rolsuper=false.
No production database/role access or changes, role creation, pg_hba.conf edits,
or PostgreSQL superuser tests were performed.

## Changes and validation

- Existing workspace fix for homes jsonb_build_object parameter $2::text is
  validated by the real PostgreSQL character/home integration test.
- Expanded that test to run quest 1 -> 10001, server-issued battle completion,
  child quest activation, reward amount and duplicate reward protection against
  PostgreSQL. This reproduced IndeterminateDatatypeError for parameter $5 in
  commit_configured_tutorial_quest; fixed it with $5::text.
- Integration tests now verify database identity and reject superuser execution
  before schema initialization, and clean up their account even on failure.
- Month-card read returns a successful empty vector plus isNeverBuy=1 only for
  an existing character with null month_card_until. Other cases retain failure;
  purchase/claim behavior is unchanged. This fixes the observed login gate for
  the new test character; actual Waydroid ACK 3106 code=0 was observed.
- CharBaseInfo sends the VipInfo configuration ID (stored VIP level + 1).
  VipInfo.dat row ID 1 represents displayed VIP 0. This fixes vipInfo=nil on
  relogin without changing stored VIP. Regression checks the actual config row.

Final command from server/: python -m unittest discover -s tests -v

PASS: 45 tests, no skips, including real PostgreSQL integration. See tests.log.
This is backend/contract validation, not proof of completed Android gameplay.

## Waydroid and APK

Initial host and sandbox session status both STOPPED. Host service was active;
its log recorded container stop at 21:31:39, with a post-stop hook status 126.
The reason that stop was initiated was not established. With separate approval,
waydroid session start brought Android up on wayland-1 as quagmihn UID 1000,
IP 192.168.240.112. No container service restart, pm clear, or Android system
image modification was performed.

Installed dist/monster2_patched.apk via adb install -r, preserving data.
Incremental install was unsupported; streamed install completed with Success.
APK signature verification passed v1/v2/v3.
SHA256: f2a721a93bcf9e261684b3555717aee49c5ec4ca60e256be4ee76bb0d9bc6567

## Runtime results

| Check | Result | Evidence / limitation |
| --- | --- | --- |
| PostgreSQL access via scoped approval | PASS | database-state.log; non-superuser |
| Waydroid session/container | PASS | waydroid-status.log, RUNNING |
| APK signature/install/start | PASS | AppActivity launched, screenshots |
| HTTP world list | PASS | Actual Android request returned Private World |
| TCP auth/binding/login | PASS | tcp.log: 2130/2126, 2211/2179, 131/132, 2156/2183 |
| Starter pet and character persistence | PASS | Actual client created char_id=10, pet template 7 |
| Loading | FAIL | Month-card/VIP gates fixed, but recurring request 227 has no response and ACK 225 times out, causing reconnect |
| Quest 10001 activation | PASS | Quest 1 committed; 10001 persisted status=0, progress=[0] |
| Quest 10001 completion on Android | BLOCKED | Tutorial battle did not finish; no request 263 observed |
| Tutorial battle creation | PASS | Actual group 99998 request 136, ACK 210 code=0 |
| Tutorial battle play-through | FAIL | BattleScene loaded then returned to Town; persisted battle state remains started |
| Scene transitions | FAIL | Login/CreateChar/Town/Lab and demo battle render; actual tutorial BattleScene does not remain playable |
| Intro video / audio | FAIL | Can't play this video; audio AssetManager reports compressed assets |

Additional actual client failure: PetEducationMgrB.lua:209 compares missing
petInfo.Stage with a number. Pet JSON currently supplies evolution but not Stage.
Battle render also logs no friendly pet information; exact cause of the immediate
return to Town has not yet been established. See final-client.log,
battle-client.log and tcp.log. These are application/protocol issues, separate
from the resolved sandbox access restriction.

Gameplay-ready: NO.

Waydroid and the two test server processes (HTTP 8080, TCP 5568) remain running
for follow-up investigation, using the test database. No APK rebuild was needed
for the Python server fixes. Earlier user workspace changes were preserved.
