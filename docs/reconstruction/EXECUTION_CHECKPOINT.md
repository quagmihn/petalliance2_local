# Execution checkpoint

## Official local draw deployment

- The reported bytes `0100010001000000` are four little-endian WORDs in the
  shipped writer, `optType=1, choice=1, bFree=1, choiceEx=0`. Machine 1 exists.
  The code that emitted `no_local_catalog` used a test-only environment gate
  and a partial machine-2 JSON. The request did not select a bad mode.
  Before deployment the production unit was failed with status 137 and had
  no listeners. The prior logged launcher ran code `58c07a0`, HTTP PID 120794
  and TCP PID 120795 from `server/` against `monster2_db`.
- Backup `artifacts/gacha-runtime/monster2_db-before-gacha.dump` SHA256
  `e1e45b1cb2855b5bd2ca13fe0501cc0db2a5ae7e296d46f29f00c4e77eb0dc18`.
  Restored in one transaction into a private PostgreSQL cluster as a
  non-superuser restore role.
- Release `2cbe0bbf311b26259e301f620deafd1ea8c239a6` booted using the official
  unit, HTTP 140117 and TCP 140118, both in the repository `server/` directory.
  Both pools verified `monster2_db` / `monster2`.
  `GAME_ENV=production`, `MONSTER2_DRAW_CATALOG=config/local_draw.json`.
  Payment settings remain `LOCAL_PAYMENT_SANDBOX=1`, `PAYMENT_PROVIDER=local`.
- Active test and official TCP log hashes matched
  `c43e24de424c90e99443dcf360a9fe906e8cd583c6347d07aec2c41a2b2c3b45`,
  with 3 machines, 3 normalized local pools, 8 reward entries and 0 missing
  references. Machines 1 and 2 accept free, x1 and x10 for eligible requests.
  Machine 3 accepts paid x1 and x10. The pool weights are local design choices.
  Original guarantee, wish, dream and VIP interactions remain unsupported.
- 108 automated tests passed on `monster2_test_db`. An invalid catalog was
  rejected before listeners started. Live test and live production both
  accepted free, x1 and x10, rejected the replayed key and returned the earned
  12 items after cold TCP login. The production smoke used disposable account
  61 / character 3 and removed it afterward. The before and after snapshot
  of real account 6 / character 2 gold, diamonds, item stacks and Pet count
  matched. PostgreSQL tests verified a Pet grant and persistent retry rejection.
  The Lua regression suite verified guide cleanup on rejection, timeout and
  reconnect along with ignoring a result after the draw callback is cancelled.
- ADB was online, Waydroid was RUNNING and Android reported boot complete.
  The staged update preserved Android user 0 app data. Installed
  `com.petalliance2.sea` APK SHA256
  `89eb276aa803c1ddbe1c02e48d6ce2f59399d3e7e98be23d7474142200291d7e`
  (`dist/monster2_local-gacha-labeled.apk`). The client labels the menus
  as local pools and removes the legacy prize preview.
- Waydroid owner account connected to the official server, reached MainScene
  and opened the Gacha menu with cooldown read `1573 → 1526/code 0`.
- **Android Gacha acceptance remains open.** The separate Android QA user
  needs to complete its agreement prompt before it can be used for payoff,
  animation, close and relogin checks. Draws were not attempted on the real
  account. Runtime TCP proof does not cover Android result rendering.

The previous APK is `dist/monster2_local-recharge.apk` with SHA256
`364d275f98101e548758bc7b46ce775b7c9d0f13f830a574d24d2a2df5134e76`.
The database change is additive. Preserve later player progress when rolling
back the server or APK.

## Opt-in draw and independent fixture follow-up

- Code commit `f7da34d673f3a0b1cc3ec17649d166de7b72e0bc` passed 105 tests with
  real PostgreSQL. The official test launcher used that clean commit on
  `monster2_test_db` at HTTP 18080 and TCP 15568.
- Smoke verification from a disposable independent fixture read its seeded
  quest and Adventure state, drew free, x1 and x10, and read 24 items after a cold
  TCP relogin. PostgreSQL held 124 diamonds from an initial 3,000 and ledger
  costs 0, 288 and 2,588. The fixture and its ledger rows were then removed
  through the fixture rollback.
- The local QA APK is `dist/local-draw-qa.apk`, SHA256
  `26de18810b4e95c5c4619597a66eb3e194354abbf054bc8d36742cc100bf13b0`.
  This APK uses only the alternate ports configured for the test launcher.
- The first streamed Android installation stalled in dexopt and Android's
  Package Manager became unavailable. A Waydroid session restart and a staged
  APK install restored Package Manager. Waydroid launched the signed QA APK in
  profile 10 and reached the agreement screen. Evidence is
  `artifacts/local-draw-qa/waydroid.png`. No Android draw was performed.
- The test service was stopped and Android returned to the owner profile on
  its original APK SHA256
  `364d275f98101e548758bc7b46ce775b7c9d0f13f830a574d24d2a2df5134e76`.
- For the next independent scenario, seed its active quest and Adventure
  prerequisites using [PLAY.md](../../server/PLAY.md). Verify the distinct UI
  paths by tapping their actual controls in the authorized QA profile.

## Source and runtime

- Official launcher from clean commit `58c07a01b389d5fde0c8e1c2c021e8733595dd37`. Verified HTTP PID 120794 and TCP PID 120795 on `monster2_db` as `monster2`, with `LOCAL_PAYMENT_SANDBOX=1` and `PAYMENT_PROVIDER=local`.
- Client repair commit `9449da9` and isolated QA fixture commit `99dde99`. The official test launcher verified clean `99dde996084838eb46cdcfeb7fabc581f791dbbb` on `monster2_test_db`, using HTTP 18080 and TCP 15568. The test listener was stopped at the end of verification.
- Restored Android owner user 0 and the prior installed APK after the test. Installed SHA256 `364d275f98101e548758bc7b46ce775b7c9d0f13f830a574d24d2a2df5134e76`.
- Local signed QA APK `dist/monster2_gacha-recovery-qa.apk` SHA256 `9abd5a15bb94282802814d6fb1f4ccdd301bef8a430a3f157b693610a5bdd471`. The QA-only build connects to the alternate test ports and has the same signer as the prior APK. Its three repair modules came from the tracked source.
- Local evidence under `artifacts/gacha-input-20261118/` includes the suite log, test launcher log and Waydroid screenshot at the agreement screen. Production database and application preferences were not used for fixture creation.

## Verified and remaining

1. The 103-test suite passed with PostgreSQL enabled. Real framed TCP verified the existing draw rejection and unchanged persistent state. Lua verified guide callback cleanup and preservation of quest status.
2. The separate Android QA profile, user 10, has reached the app's agreement screen. An authorized profile operator needs to handle that prompt to continue the isolated in-app tests. The QA service can be relaunched with `./server/run_all.sh test`, `DATABASE_URL` pointing at `monster2_test_db`, `HTTP_PORT=18080`, `GAME_PORT=15568`, and the same local payment flags.
3. Use the documented fixture in [server/PLAY.md](../../server/PLAY.md) after a QA device binding exists. Capture the reject-and-close sequence, then check store and map input. Record the sequential tutorial independently from any fixture.
4. Verify actual PURCHASE and M-PASS claim with wallet and entitlement state. Then verify consecutive map clears and cold relogin. Existing tests cover local payment transactions. Successful draw rewards, counters and result animations remain outside the maintenance checkpoint.
