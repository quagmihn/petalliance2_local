# Execution checkpoint

## 2026-11-26 · Pet stars, VIP and private economy

The requested `monster2_rebuild_opencode` path was absent. Active HTTP and
TCP both used `/home/quagmihn/Project/monster2_rebuild/server` from baseline
`1022e96170e5adccc3836f9b53ecb68113773d6a`. The installed baseline APK was
`cf5c1c63ad0725cf6b6658f51c77ed733a9eb7cac0bd8b043522b2b3e5d6b5d7`,
which retained four Adventure Lua differences from the older documented APK.
The update overlays four Pet/store Lua modules onto that installed baseline.

| Evidence | Result |
| --- | --- |
| Test suite | 133 passed with `monster2_test_db`, zero skips |
| Waydroid Pet | STATUS opened by default. Panda UID 1347 kept its template and formation while upgrading 0 → 5 stars. Each operation received 1650/code 0. Stage +25 was a QA prerequisite. HP 3,746 → 5,619 and power 3,168 → 4,750 persisted after restart. |
| Waydroid VIP | QA account 848 / char 834 displayed VIP 20. A claim granted Katty and three item stacks. The privilege screen still showed COMPLETED on cold login. |
| Waydroid VIP Shop | SKU 310 accepted purchases of 10 and 1 above its configured limit of 10. Wallet debits were 5,000 and 500 and PostgreSQL saved both transactions. |
| Waydroid recharge | N2 +160, N3 +80, M10001 +400 and M10002 +800. Each M-PASS added an entitlement and its eligible initial daily claim (+160 and +320). Both cards and the final balance 462,556 persisted after cold login. |
| Arena | Nine shop slots are loaded from type 1. Stock, pricing, refresh and committed purchase passed protocol and PostgreSQL tests. In the Android combat lobby, 277 had no response on the previous build. The release sends a rejection until a real Arena lobby is available. |

Gameplay source `3fb95618589b9a6bb7ab0fe2879def01a09c53b9` was deployed
with the default `server/run_all.sh` profile. Both listeners authenticated
to `monster2_db` as `monster2`. Schema deployment adds the VIP and Arena
purchase ledger tables. Owner account 6 / char 2 remained at VIP 15 with
its predeployment character fingerprint. The VIP 20 admin plan was dry-run
against that exact pair. A test-only fixture owns all recorded gameplay
purchases.

The signed APK SHA256 is
`d5b54e278c2ba8d6a86f9f2ea2924eede10e3e049cfc794c0e7fb363a9970dbd`.
The certificate SHA256 remains
`f6a9b74ac979b6f3c221eb0b21789619b1238c89ca813b9033a60425cf489a3a`.
The dump `artifacts/pet-economy-20261126/monster2_db-predeploy.dump` has
SHA256 `93367692c8ed72d7d758c70ca800367ff3bff83a108c0a56d41aae156a20ab2f`.
An isolated socket-only restore under a non-superuser validated 182 public
constraints and restored 5 characters, 53 Pets and 61 inventory rows.

[Launcher and rollback](LAUNCHER_PARITY_REPORT.md) · [Pet and skill scope](PET_CONTENT_COVERAGE.md) ·
[Photos and state evidence](../../artifacts/pet-economy-20261126/) ·
[Next acceptance](IMPLEMENTATION_BACKLOG.md)

## 2026-11-25 · Wise Arena, item rewards, Skill Gacha and launcher parity

The official launcher runs from this repository and its default private
profile uses `monster2_db` as role `monster2`. The service and ordinary
`./server/run_all.sh` invocation on gameplay commit `5f9a078` produced
identical startup identities and HTTP version payloads. Both listeners
independently checked the database pool, and both runs used
192.168.240.1:8080 and :5568 with simulated local checkout.
[Launcher parity evidence](LAUNCHER_PARITY_REPORT.md)

| Verification | What happened |
| --- | --- |
| Waydroid, Trainer | QA character 4 entered Wise Arena floor two. The authored Trainer stepped one tile toward the player, issued scene 96 battle, and the party won with the configured 21 Pet EXP. |
| Waydroid, wild battle | The reported request 136 uses type 2 with scene 111. The old server accepted just Trainer type 3 for Adventure. The new server resolved scene 111 through DisposableInfo 7 and let the client battle Bashful, gain 16 Pet EXP and exit with the configured 64 character EXP and two balls. One-time event 7 persisted. The QA map retained its clear and crown after cold login. |
| PostgreSQL and TCP, capture | Configured world-map wild encounters accept eligible balls. Tests exercise a miss, a catch, replay without another grant, and the same owned Pet UID. The Wise Arena Bashful encounter has zero capture attempts. An eligible UI capture remains open. |
| Waydroid, event rewards | QA character 4 claimed the first recharge mail and Seven-Day day 1. The first claim added 640 diamonds, Katty UID 37, ten original Thunderwrath books and a Silver Bag(M). The second claim set `seven1=1` and granted five Whittiger fragments, a potion and a cookie. |
| Waydroid, Silver Bag | Bag showed success, consumed item 188 and saved 500 silver in `currencies_json.goldCoin`. The old failing item 187 was the small Silver Bag. PostgreSQL tests cover it and configured chest 199. |
| Waydroid, Skill | QA character 4 paid 98 and 898 diamonds for x1 and x10. The x10 displayed real Jumpkick and passive books. Zupedo UID 6 learned Jumpkick 1711, then upgraded to 1712 after a restart for one book and 15 shards. A related reconnect loop was traced to untyped JSON parameters in request 632 and fixed. |
| Waydroid, Senior and Supreme | QA character 7 completed free, paid x1 and x10 on both machines through the ordinary launcher. All six ACKs 1561 succeeded. Senior awarded C/B/A Pets, balls, and materials and charged 105,000 gold. Supreme awarded S Pets, Master Balls, and two kinds of fashion vouchers and charged 2,876 diamonds. PostgreSQL recorded draws 58–63 and balances 95,010 gold and 1,124 diamonds. |
| PostgreSQL, fragments | Five fragments 38012 synthesize one template 26 Pet. Concurrent requests share one available stack and create one Pet. Android synthesis remains open. |

The APK SHA256 is
`b469bf2b35885edee69427600a31f41bb55c2b92bcae0bbb9f3c7236d00414b6`
and signing certificate SHA256 is
`f6a9b74ac979b6f3c221eb0b21789619b1238c89ca813b9033a60425cf489a3a`.
The installed package matched the signed file. The previous signed APK
is in the local rollback folder. Gacha catalog SHA256 is
`30e863eb46d64ff40f5d137cca98685a4993fd1e1495493249555afa74247900`.
The full suite passed 127 tests with `monster2_test_db`. No migration was
required. The predeployment dump SHA256 is
`a11959f8e349f8812cf60cad41d37b1d0cdbef750c9940f72c407f0f0f2bb375`.
The isolated socket-only restore exited 0, validated 182 constraints
and restored five characters, 35 Pets, 65 quests and 29 inventory rows.

Code milestones are `42b3e97`, `44a7e58`, `84b883c`, `895fa93`,
`21bde9b`, `5c879f3`, `049dde9` and `5f9a078`. The local evidence in
`artifacts/gameplay-runtime-20261124` contains the rollback APK,
database dump, PostgreSQL snapshots, launcher and TCP logs, and Waydroid
screenshots including `qa25-a-trainer-detection-one-step.png`,
`qa25-a-wild-accepted.png`, `qa25-a-wise-clear.png`,
`qa25-a-seven-day1-claimed.png`, `qa25-b-skill-x10.png` and
`qa25-final-a-jumpkick-lv2.png`. The Senior and Supreme x10 reward
screens are `qa25-final-b-senior-rewards.png` and
`qa25-final-b-supreme-x10.png`. [Remaining work](IMPLEMENTATION_BACKLOG.md)

## 2026-11-24 · Panda formation, Wise Arena and Town Market

The official launcher serves HTTP 8080 and TCP 5568 on the Waydroid bridge.
Both pools verified `monster2_db` as `monster2`. The catalog SHA256 is
`75ada34ad42be2bf79667c87a8e15f10ab3e5ee828b76653eea51f11e0bc5795`.
`LOCAL_PAYMENT_SANDBOX=1` and `PAYMENT_PROVIDER=local` are set for the
private test host.

| Area | Waydroid and PostgreSQL evidence |
| --- | --- |
| Sequential tutorial | Android user 11, account 74 and character 6 continued without a seeded quest or reward. Lost Forest and Secret Path retained three crowns each. The character completed the Slash introduction and the free Senior → Supreme sequence. Ledger rows granted item 33066 and Grade A Panda (template 45, UID 36), each at zero cost. |
| Formation | The guide had selected the first high-rarity Pet, Whittiger. The same-signer APK update now selects template 45. ACK 1756 saved Panda in fighting slot 1 beside Zupedo and moved Whittiger to reserve. Quest 10011 committed. The game restored team power 955 on cold login, fielded Panda in the Selena fight, and persisted its 24 EXP. |
| Story and map | The official server now recognizes authored finish markers in `story.txt` only after the prerequisite commits. Android received success for story 30000 after 10032. In Wise Arena, Panda cut three obstacles, the party crossed to the authored second floor, beat the configured trainer, and cleared with two crowns (mask 14), 64 character EXP and item 2 ×2. Panda's cumulative EXP was 45 after the second trainer. The gold/chest crown remains unverified. |
| Ordinary draws | Independent QA user 10 / character 4 completed ordinary Senior free, Skill x1 and Skill x10. Requests 1392 returned success via 1561, animations displayed and the menus remained responsive. Ledger rows 49–51 granted item 212 ×1 and eleven Skill rewards, with 98 and 898 diamond deductions. The resulting diamond balance was 1,938. |
| Town Market | The auction screen was waiting on missing ACKs 493 and 520. It now receives empty player-listing results and can open the configured Mall. Through the normal Android UI, QA character 4 bought SKU 188 (Normal Essence, item 35) for 20 diamonds. The client displayed Purchase success and 1,918 diamonds. PostgreSQL recorded 1,938 → 1,918 diamonds and 0 → 1 of item 35. The wire sent inventory 112, wallet 473 and success 563. |

After a cold login on character 4, the Bag still showed Normal Essence
and the ordinary draw items, with the committed 1,918-diamond balance.
The corresponding screen is `market-qa-bag-cold.png`.

The APK at `dist/monster2_local-guide-runtime.apk` has SHA256
`3958e0faabf3b7ada03aa913e1db94835d7c0756a898ff07c8660e92ebec12ac`.
Its signing certificate has SHA256
`f6a9b74ac979b6f3c221eb0b21789619b1238c89ca813b9033a60425cf489a3a`.
The archive change was limited to encrypted `GameGuideMgr1.lua` among
12,655 non-signature entries. Waydroid retained app data. The source
commits are `f53b47a` (formation), `a72b67e` (story), and `a997cb5`
(Town Market query responses).

The pre-deployment backup `artifacts/content-continuation-20261124/monster2_db-predeploy.dump`
has SHA256 `61a0398deee3fb9fce66f64d1e42e7cdd6e8d14d687c586245bce25c4b557561`.
The dump has 131 TOC entries. An isolated socket-only cluster restored it
in one transaction, validated 182 public constraints, and matched the COPY
data across all 18 tables. These changes required no schema migration.
The post-QA backup has SHA256
`062d37add773e8cd84c7fde604ee3fe520802c0f815b4db17cdb196392585f71`
and a readable 131-entry TOC.

The local evidence directory contains the before/after TSV snapshots,
`sequence-panda.png`, `sequence-panda-correct-selection.png`,
`sequence-wise-arena-clear-final.png`, ordinary draw screenshots, and
the machine-readable content registry. Earlier signed APKs referenced in
this document are stored under `artifacts/dist-cleanup-20261124/archive/`.
The previous guide APK with a reused filename is
`monster2_local-guide-runtime-20261122.apk` in that archive.

The post-cleanup suite passed all **119 tests** on `monster2_test_db`.
`dist` is 719 MiB and contains the active APK, build-base APK, local
signing keystore, and fresh-install OBB. The cleanup moved 16 historical
APKs and the overlay directory to the local archive and removed 41
generated files totaling 9,150,425,194 bytes. The manifest and per-file
actions are in `artifacts/dist-cleanup-20261124/result.json`. The installed
APK signature, ZIP alignment, package ID, and SHA256 were verified again.

## 2026-11-22 · Sequential tutorial, inventory and Adventure recovery

The official launcher serves the project source on HTTP 8080 and TCP 5568.
Each pool independently verified `monster2_db` as `monster2`. Local checkout
remained enabled with `LOCAL_PAYMENT_SANDBOX=1` and `PAYMENT_PROVIDER=local`.
The Gacha catalog SHA256 is
`75ada34ad42be2bf79667c87a8e15f10ab3e5ee828b76653eea51f11e0bc5795`.
The installed `com.petalliance2.sea` matched
`dist/monster2_local-guide-runtime.apk`, SHA256
`60a285d19f6a819cbed7e6a415e28337c181c96ee8190e2338b7d3c241e28a27`,
with certificate SHA256
`f6a9b74ac979b6f3c221eb0b21789619b1238c89ca813b9033a60425cf489a3a`.
Only the encrypted `GameGuideMgr1.lua` changed among 12,655 non-signature
entries. The in-place same-signer upgrade preserved app data.

| Area | Evidence |
| --- | --- |
| Sequential character | User 11, account 74 and character 6 were created through Waydroid in the November 19 run. This pass resumed the same unseeded character. PostgreSQL recorded Lost Forest mask 15, level 2 and cumulative EXP 60. The map displayed 1/10, one cleared map with three crowns. The player claimed quest 2 through the Quest panel after cold login. |
| Adventure quest refresh | PostgreSQL had quest 2 at `[1]` while the open client still showed `0/1`. The clear now returns the committed quest rows through 404 after 2995, with existing 473 and 1749. Framed TCP tests verify the exact objective vector and that a retry grants no second reward. |
| Feed and Enhance | Lost Forest awarded one Exp Potion(S). The player used it through Bag → Pet → Feed and raised Zupedo UID 15 from accumulated EXP 16 to 109, level 2, and displayed power 383 → 412. Cold login restored the new result. The guide now identifies that starter instead of looking for UID 1. The player then used the Enhance button, consuming three cookies and 100 gold. PostgreSQL recorded Stage 1 and the live Pet panel displayed power 439. The transaction now publishes the updated wallet and Bag before ACK 1032. |
| Prior scripted draw | Independent tutorial checkpoint, user 12, completed both guided free draws, displayed Grade A Panda (template 45, owned UID 18), and finished formation. Its snapshot matched after a cold login. The separate paid x1 and x10 trials used ordinary configured rewards. |
| Appearance and store | Prior controlled Waydroid profile redeemed item 31049, equipped appearance 1049, changed scene and cold-logged into Town wearing the saved Silver Helmet. Market links for all 90 enabled offers resolve. The latest VIP cap and transaction changes have PostgreSQL/TCP evidence. |
| Map identity | Lost Forest and Secret Path use different authored `SceneInfo.number` cells with the same environment and dimensions. Prior Android screenshots show both corrected floors and portal clears. The current pass reconfirmed all Lost Forest objectives on the sequential account. The regressed reverse join was also repaired in the machine-readable export. |

The grade and item names come from the target APK. Two local guided supply
rules fill specific missing progression grants. `AdventureInfo[1]` lists
item 154 in the preview and Lua dialogue 19 says the enhancement material
was already acquired. The shipped clear gives only the potion. After
Lost Forest and a leveled starter, quest 10005 supplies the shortfall up to
the configured Stage 1 cost (three Milchick Cookies). A saved character in
10006 can receive the same one-time grant on its next Bag load. The route
capture guide highlights `BattleCCSB.ballOrder[1]` (ball item 2) and its
three authored encounters each specify three capture attempts. The
one-time supply uses those IDs and counts and retains the configured catch
rate. These are local supply rules, with original grant timing unverified.

The latest suite ran **118 tests** using `monster2_test_db`. No schema
migration was required for the current fixes. The pre-deployment dump
`artifacts/content-continuation-20261122/monster2_db-predeploy.dump` has
SHA256 `e2093a54e344ab8f7853491d1d6e67eef9f9050ae290012f6b9c3d81e97912b7`.
It restored in one transaction to a separate socket-only cluster under a
non-superuser role. All 182 public constraints validated and all 18 tables
matched the dump's COPY data. The local evidence directory contains the
screenshots, state snapshots and compiled registries. The owner profile
was excluded from fixture writes.

Source commits `b7d2c83` (Adventure quest refresh and export), `f55e8ca`
(starter UID), `768ae54` (training material), `33c4997` (Enhance
notifications), and `e921f3d` (capture supply).
[Content catalog and exports](CONTENT_REFERENCE_MATRIX.md)

## 2026-11-20 · Battle Pet EXP, authored Adventure IDs and Senior rarity

- Battle create ACK 210 already supplied a configured EXP amount from
  MonsterGroupManInfo or MonstrosityInfo. Lua rendered it for the fighting
  cards. The previous handler for 263 marked the battle and quests without
  updating Pet EXP. The new transaction uses the issued snapshot of
  fighting UIDs and validates the UID/HP result vector. Support and reserve
  slots do not receive this reward. The roster and reward come from the
  database and server configuration. Pet levels and caps share the EXP
  table semantics used for feeding. Updates 3141 follow the transaction
  commit and precede ACK 186. Replay against a closed encounter grants
  nothing. The legacy client protocol carries no global battle nonce.
- **Waydroid Pet EXP PASS** on QA account 75 / char 7, session
  `3b4aebcf4067`. The trainer used group 1 and advertised +16.
  PostgreSQL changed Panda UID 18 and Zupedo UID 17 from Lv1 EXP 0 to
  Lv1 EXP 16. Both 3141 packets arrived before 186, and Panda's Status
  tab showed 16/50 before login was restarted. After an official server
  restart and Android cold login (session `f5c13f74ec88`), the same tab
  still showed 16/50. The PostgreSQL integration test independently
  confirms a 44 → 60 crossing to Lv2, reserve/support exclusion,
  a formation edit after battle issue, and concurrent duplicate rejection.
- The additive `tutorial_battle_sessions.fighter_uids` column stores the
  issuance roster. Existing entries keep their historical values. In-flight
  entries issued before the migration can finish without retroactive EXP
  when they lack an issuance snapshot. For rollback, use the previous
  server commit and retain the nullable column and existing player EXP.
- The Adventure join formerly used a field type from AdventureInfo.
  The wire cell layout now uses SceneInfo.number, which is the authored
  Adventure ID. Coverage is 275 of 290 exact grids (previous join 22).
  Fifteen placeholder maps return 3080/code 1 before persisting a run.
  The PostgreSQL framed integration passes Adventure 1 → 2 → 3 with
  synthetic clear masks, distinct wire rewards and independent stars.
  [Map analysis](MAP_GENERATION_ANALYSIS.md)
- The production Senior cap is tier 4 in every ordinary draw mode.
  Its remaining entries are two items at relative weights 1,500 and
  4,300. The three enabled ordinary pools have eight total rows.
  Supreme validates configured Pet references through tier 6, while
  the target pool still only supplies items. The scripted Panda guarantee
  stays separate. [Rarity and gaps](GACHA_RARITY_MATRIX.md)
- Independent Pet audit found 191 valid Fight, 3 Material and 58 Fight
  entries missing basic attack configuration. The 58 resolve only to 0
  in all three available snapshots. The reference audit still reports
  426 missing item IDs, 33 Pet IDs, 291 reward IDs and one quest parent.
  The alternate market offers SKU 203 for item 9986 at one diamond,
  with incompatible pricing for adjacent products. Target SKU 203
  stays disabled. [Pet audit](PET_TEMPLATE_MATRIX.md) · [Shop audit](SHOP_CONTENT_COVERAGE.md)
- **117 tests PASS** on `monster2_test_db`. Code commits are `1a73b04`
  (EXP), `35864b0` (Senior), `605084d` (Adventure) and `9dfcb4e`
  (Pet audit). The official launcher runs `9dfcb4e86dd17d8fa49639bf8879ad5458ea8818`
  using HTTP PID 54044 and TCP PID 54045, both verified as
  `monster2_db` / `monster2`. Local-only payment remains active.
- Pre-migration dump SHA256
  `dc474d5700dea52e496a902f92f81267527a8bfe08a8f542a8604fc711e7d1c5`.
  The isolated single-transaction restore as a non-superuser role
  recovered five characters and 33 Pets. The official game data and the
  owned account were excluded from fixture writes. Installed APK remains
  SHA256 `5e4360f91bc2d88a9aa3a978c4da357f115b4f6f8ceba85e9a9ed98d541b83a6`.
  Evidence and backup are under `artifacts/battle-exp-20261120/`.

## 2026-11-20 · Saved formation, trainer progress and content validation

- The owner trace showed 1755 saved Panda UID 27 in place of Catepii UID 3,
  then group 2003 launched successfully. The Lua success callback updated the
  editor's UID lists. BattleScene still read the previous active-object list.
  The repaired callback applies the saved main, support and reserve state
  together. New Adventure entries replace the previous expedition slots.
  [Formation trace](FORMATION_BATTLE_TRACE.md)
- An independent Waydroid replay on QA account 75 / character 7 used
  UID 17 / template 7 and UID 18 / template 45. The first run revealed a
  missing battle-end callback specific to this guide. The final APK
  replayed group 2003, switched to Panda, and won using real combat input.
  In session `6eedfc1f8c74`, requests 136, 263 and 400 received ACKs
  210, 186 and 726 with code 0 and quest notification 404. PostgreSQL
  recorded battle 24 as won and quest 10032 as completed at progress
  `[1]`. Selina's post-battle dialogue appeared. The client summary showed
  +24 Pet EXP, while both persisted Pet EXP values stayed at 0. Battle
  EXP persistence is a separate outstanding case from the battle result.
- In the same Waydroid session, the editor saved Panda in slot 0 and Zupedo
  in slot 1. After ACK 1756, Panda became the follower and the Secret Path
  preview put it first. The normal trainer encounter used the saved UID
  order 18/17 and finished via 263/186. The portal cleared Adventure 2
  via 3082/2995 with mask 12. PostgreSQL stored 62 character EXP and
  item 2 ×1. See `qa-after-editor-save.tsv`, `qa-secret-path-cleared.tsv`
  and the Secret Path screenshots. No costume or checkout mutation was
  needed for this test.
- Cold Waydroid login in session `be3b0ee3fad9` returned the saved
  formation `[18,17]` through 1774 and Adventure 2 / mask 12 through 1749.
  The preview showed Panda first and the earned star. PostgreSQL output
  in `qa-after-cold-relogin.tsv` matched the snapshot from immediately
  after the clear. A second Secret Path trainer battle after relogin
  used order `[18,17]` and finished with another 186/code 0.
- The creation, Gacha, capture and reward paths share the Pet skill
  initializer. Its reference validation identifies 194 of 252 templates
  with usable starting skills. The other 58 lack a configured basic
  attack. The rarity audit found that the current Senior pool's sole Pet
  is tier 5 (orange), above the requested Gold tier 4 cap. Supreme's
  ordinary pool has no Pet. The active catalog is still the target-normal
  catalog with its previous weights and SHA256
  `75ada34ad42be2bf79667c87a8e15f10ab3e5ee828b76653eea51f11e0bc5795`.
  [Content registry](COMPLETE_CONTENT_REGISTRY.md)
- Map pickup and clear transactions now check their Adventure ID against
  the locked active run. An integration test enters Adventure 1, switches
  to Adventure 2 from another connection, then verifies the stale
  requests cannot award a cell pickup or close Adventure 2.
  [Map generation and identity](MAP_GENERATION_ANALYSIS.md)
- **114 tests PASS** with the separate `monster2_test_db`. Source commits
  are `64c215b` (formation), `7bc70f7` (acquisition validation), `003a8b7`
  (map identity guards) and `5435176` (guided result). The official service
  launched with `5435176b06689c0aeceb5d906c6f6e79a5a5cbdb`, HTTP PID
  38215 and TCP PID 38216. Both connections verified `monster2_db` as
  role `monster2`. Existing local-only checkout settings remain active.
- The backup `artifacts/formation-content-20261120/monster2_db-predeploy.dump`
  has SHA256 `cea50a295928074facdba7e8baae332fccbbe5c9a2df665c7fe2a1da58df2406`.
  A private socket-only PostgreSQL restore ran in one transaction using
  a non-superuser and returned five characters and 33 Pets. The changes
  require no schema migration. The owner character was read-only during QA.
- Installed APK `dist/monster2_local-formation-runtime.apk` verified
  SHA256 `5e4360f91bc2d88a9aa3a978c4da357f115b4f6f8ceba85e9a9ed98d541b83a6`.
  The in-place install retained app data and the baseline signing
  certificate. Seven Lua entries changed. The earlier verified
  `dist/monster2_local-gacha-runtime.apk` is the APK rollback candidate.
  Local evidence includes `official.log`, `replay-android.log`,
  `qa-before-replay.tsv`, `qa-after-replay.tsv` and the battle screenshots.

## 2026-11-20 · Tutorial progression integrity and Market preflight

- Adventure trainer victories previously incremented every active objective
  marked event type 2. The client uses the same marker for quests 10010
  and 10011, so a battle could make the Gacha quest look complete before
  the award and could bypass the formation check. The Gacha commit now
  requires a matching committed draw receipt. A pending guide with stale
  progress still has its remaining free draw. The formation commit checks
  that the required Pet is in fighting slots 0–2.
- The target Lua opens Senior free x1, then Supreme free x1. Dialogue 29/30
  identifies Grade A Panda, and `GameGuideMgr3.firstSkillPromote` checks
  template 45. The packaged Supreme first pool references item 34066.
  The existing one-time Pet award is a local compatibility rule for the
  scripted guide, with the draw cost, Pet and quest progress committed
  together. For normal draws, the backend uses the active catalog.
  [Gacha evidence](GACHA_CONTENT_MATRIX.md)
- The Market startup check validates that each of the 90 enabled offers
  has a known item and a positive price. The purchase handler uses the same
  validated offers. This milestone required zero schema migrations.
- Source commit `d26c4819b73abe8cffdfb316ce81e877d7eae3a6` is live from
  `server/run_all.sh production`. HTTP PID 10461 on 8080 and TCP PID 10462
  on 5568 verified `monster2_db` as role `monster2`.
  `LOCAL_PAYMENT_SANDBOX=1` and `PAYMENT_PROVIDER=local` retain their prior
  values. The active catalog is `server/config/target_draw.json`, SHA256
  `75ada34ad42be2bf79667c87a8e15f10ab3e5ee828b76653eea51f11e0bc5795`,
  with three machines and nine enabled normal awards. The existing
  `local_draw.json` is an older replacement catalog.
- The pre-deployment dump `artifacts/content-integrity-20261120/monster2_db-predeploy.dump`
  has SHA256 `8ba1c1675acbc2149a7ae5f147303aae4789fef11935239187bd7f282e2a5938`.
  It restored in one transaction in an isolated, socket-only cluster.
  The restore log records the non-superuser restore identity, five
  characters and 25 public tables. The owner account was excluded from QA
  actions. Rollback of this code uses the previous commit `95b2b48`.
- **POSTGRESQL + TCP PASS**. 111 tests passed with `monster2_test_db`,
  including a real Adventure battle, rejection of forged guide progress,
  one grant under concurrent requests, cold framed login, formation
  validation, and invalid Market catalog references.
- **WAYDROID PASS for cold relogin** on Android user 12 and QA account 75 /
  character 7. TCP session `07ae25773cc9` returned QueryPets `3140 → 3139`
  and QuestList `785 → 26/404`. Waydroid opened the Town guide for the next
  step. A read-only PostgreSQL snapshot matched the earlier guide capture:
  Pet UID 18 / template 45 in fighting slot 1, two committed guide draws
  and completed quests 10010/10011. The installed
  `com.petalliance2.sea` SHA256 was
  `a205db8689de4ccd370c69cac12843192af3e3e25b30d62303b72cccd9153017`.
  Evidence is in `artifacts/content-integrity-20261120/`, including
  `official.log`, `tests.log`, `qa-relogin-state.tsv` and
  `waydroid-qa-town-cold-login.png`.
- Prior Android captures in `artifacts/content-restoration-20261119/`
  show the staged tutorial result and formation, ordinary free/x1/x10 and
  outfit equip/relogin. The separate fresh character reached quest 10002
  active after 10001. A fresh sequential run through 10010, equipment
  ownership and full Lost Forest/Secret Path clears remain open.
  [Next acceptance tasks](IMPLEMENTATION_BACKLOG.md)
- The current APK passed signature verification. A second Waydroid cold
  login as the independent account 64 / character 4 rendered the equipped
  helmet in Town. STORE reopened and its VIP tab displayed the configured
  level restriction. The selected offer required VIP 12, while the profile
  was VIP 0. The click left the wallet at 2,454 diamonds and sent no 577.
  The eligible Market purchase on this deployment remains pending. See
  `waydroid-qa-outfit-cold-login.png` and `waydroid-vip-eligibility.png`.
- Static shop dependency check found that
  `OrderManUIMgr:buyOrderItems` dereferences Market SKU 203 for item 9986
  while 203 is absent from the target MarketInfo. The password product
  purchase is blocked by the missing SKU and price. Market SKU 202 for a
  separate caller exists and has a valid item reference.

## 2026-11-19 · Official Gacha Waydroid acceptance

**WAYDROID_VERIFIED** for all eight local draw actions exposed by the client.
The official launcher runs `monster2_db` as PostgreSQL role `monster2`.

### Runtime mismatch and repairs

- The earlier `no_local_catalog` came from a test-only feature gate and a
  machine-2 fixture. The installed client schema in `Proto_Pet.lua` decodes
  `0100010001000000` as four little-endian WORDs: `optType=1` (Senior),
  `choice=1` (one draw), `bFree=1`, `choiceEx=0`. Newer APKs append a local
  idempotency key. The server accepts the original eight-byte body.
- No official listeners were running at the start of this session. The
  retrieved TCP trace from the previous official session showed successful
  draw ACKs followed by unanswered request `1519` and a client disconnect.
  This request reads the original wish/dream state. The server now answers
  `1396/code 1`, which the installed client parses and uses to release the
  blocking callback. A separate cold-login trace found the bulletin request
  `324` timing out. It now receives `320/code 0` with a full `Proto.Code`
  header and an empty bulletin vector.
- Result popups now display the item and Pet awards from ACK `1561`. The
  client hides the original guaranteed-rarity banner and the ungranted bonus
  EXP and wish-coin icons. Retry checks the current wallet and restores the
  machine controls on rejection or timeout. The existing guide cancellation
  and reconnect cleanup remain exercised by the Lua tests.
- Source commit `f42e1d55d9512bd294ba9ab808f615587c5ea0b1` completed Gacha
  response handling, diagnostics, and result rendering. Live source commit
  `7ceebb116f69b7a2e61b63ac9e85d43a4508e106` corrects the bulletin wire
  structure. After restart, `server/run_all.sh` logged `dirty=no`. HTTP PID
  17036 and TCP PID 17037 both ran from the project's `server/` directory
  and their pools independently verified `monster2_db` / `monster2`.
  HTTP advertised `192.168.240.1:5568` through port 8080. Both processes
  had `GAME_ENV=production`, `MONSTER2_DRAW_CATALOG=config/local_draw.json`,
  `LOCAL_PAYMENT_SANDBOX=1`, and `PAYMENT_PROVIDER=local`.
  `MONSTER2_TEST_DRAW_CATALOG` was absent from both.

### Catalog and backup

- The official catalog is [server/config/local_draw.json](../../server/config/local_draw.json).
  The launcher resolves it against `server/` and validates references and
  normalized weights before opening either port. The TCP process logs the
  loaded catalog. The test and official launcher logs matched SHA256
  `c43e24de424c90e99443dcf360a9fe906e8cd583c6347d07aec2c41a2b2c3b45`,
  with three machines, three local pools, eight reward entries, zero missing
  references, and the modes below. The APK's original data contains three
  machines, 17 linked pools, and 27 award entries. The local pools use explicit
  weights totaling 10,000 per pool and original price and cooldown metadata.
  Original rarity artwork is still present on the machine selection screen.
  First-draw, guarantee, wish, dream and VIP rules remain unsupported.
- The untouched pre-deployment backup is
  `artifacts/gacha-runtime-20261119/monster2_db-before-gacha-runtime.dump`.
  SHA256 `b4bbb27fb6e850288da96e53523ee50a6d21d17d5dd76916fa12d744012fcde2`.
  It restored in one transaction into `monster2_restore_gacha_b4bbb27f`.
  The restore exited successfully. Data digests matched for all 17 tables,
  including characters, Pets, quests, inventory, and the Gacha ledger.
  All 182 constraints were validated. The existing production draw ledger
  was reused. The owner account's wallet, inventory, Pet slots and draw
  count matched the pre-deployment snapshot.

### Real client results and persistence

- Waydroid reached Android boot completion and ADB was online after restarting
  the desktop session and unfreezing its container. The authorized agreement
  and the draws used Android user 10, a separate device login, and controlled
  account 64 / character 4. The fixture set level 15, map unlock 5, and a
  bounded test wallet. It skipped the sequential tutorial, which is a separate
  acceptance case.
- Installed package `com.petalliance2.sea` matched the signed release
  `dist/monster2_local-gacha-runtime.apk`, SHA256
  `a205db8689de4ccd370c69cac12843192af3e3e25b30d62303b72cccd9153017`.
  APK certificate SHA256
  `f6a9b74ac979b6f3c221eb0b21789619b1238c89ca813b9033a60425cf489a3a`.
  Of 12,655 non-signature archive entries, only the packed
  `GachaViewMgr.lua` changed from the prior installed APK. The in-place update
  preserved application data. The encrypted module matches tracked source
  after decoding.

| Machine | Free | Paid x1 | Paid x10 |
| --- | --- | --- | --- |
| Senior (1) | WAYDROID_VERIFIED, five daily chances and 300-second cooldown | WAYDROID_VERIFIED, 10,000 gold | WAYDROID_VERIFIED, 95,000 gold |
| Supreme (2) | WAYDROID_VERIFIED, 48-hour cooldown | WAYDROID_VERIFIED, 288 diamonds | WAYDROID_VERIFIED, 2,588 diamonds |
| Skill (3) | — | WAYDROID_VERIFIED, 98 diamonds | WAYDROID_VERIFIED, 898 diamonds |

- The rebuilt APK recorded eight successful `1392 → 1561/code 0` callbacks
  and displayed the draw results. Supreme's extra `1519 → 1396/code 1`
  resolved without a callback timeout. During a Senior retry, the QA wallet
  was temporarily set below the price to simulate a stale client balance.
  `1561/code 1` displayed the failure, the ledger count remained five,
  and the next draw worked from the same machine after restoring the test wallet.
- After both passes, the QA ledger held 11 successful transactions. The ledger
  totals matched the Bag (item 1 ×39 and item 2 ×45) and the collection (four
  new Catepii, template 26). The final wallet was 85,000 gold and 540 diamonds
  from a 200,000 gold and 7,000 diamond test budget. Closing Gacha opened the
  Bag immediately. After an official server restart and app force-stop, a
  new login showed the same wallet, Bag counts and five Pets. The PostgreSQL
  snapshots matched before and after. The final cold login resolved
  `324 → 320/code 0` and stayed connected during the Bag and Pet checks.
- **TCP_TESTED** on both `monster2_test_db` and `monster2_db` through the
  official launcher with the same catalog. A disposable character in each
  environment exercised free, x1 and x10, checked notification and ACK order,
  replayed a request key, and verified the rewards on a cold TCP relogin.
  **UNIT_TESTED / PostgreSQL integration**: all 108 tests passed. Coverage
  includes startup failure with an incomplete catalog, source/hash/mode
  parity, original request bytes, cooldown rejection, replay protection,
  Lua guide cleanup, and the bulletin and Gacha follow-up ACKs.
- Local evidence under `artifacts/gacha-runtime-20261119/`:
  `waydroid-final-supreme-paid-x10.png`, `waydroid-final-rejected-retry.png`,
  `waydroid-final-relogin-bag.png`, `waydroid-final-relogin-pets.png`,
  `waydroid-final-net.log`, `waydroid-final-relogin.log`, `official.log`,
  `tests.log`, `restore.txt` and the PostgreSQL snapshots.

### STORE and M-PASS follow-up

- The same QA profile opened STORE and used the already deployed local
  payment path. Package 2 credited 160 diamonds, and M-PASS package 10001
  credited 400 diamonds and created a 30-day entitlement. Both sent
  `90 → 473, 89/code 0` and recorded `simulated=true`. Cold login requested
  the eligible daily claim using `3102 → 473, 3103/code 0`, credited 160
  diamonds, and persisted claim day 20776. The wallet moved from 540 to
  700 to 1,100 to 1,260 diamonds.
- The daily wallet notification exposed a VIP representation mismatch:
  PostgreSQL rank 0 was sent as client table ID 0. The login packet uses ID
  1 for rank 0. Commit `cae7a80f752686d9b2a6af87183c729b96c83bf3` now uses
  the same mapping for login, character values and wallet notifications.
  STORE reopened after relogin. A renewal credited 400 diamonds and extended
  the entitlement by 30 days to 2027-01-18 17:58:06 UTC+07. The claim-day
  row retained 20776. The VIP progress display and legacy M-PASS perk text
  still require separate verification against the configured rewards.
- Evidence: `waydroid-next-local-purchase.png`,
  `waydroid-next-mpass-purchase.png`, `waydroid-next-mpass-store-reopened.png`,
  `waydroid-next-mpass-renewal.png` and the purchase snapshots in the same
  artifact directory. No external checkout was used.

The next runtime cases are an in-game item purchase with gold and consecutive
Adventure map clears. The original Gacha tutorial sequence is tracked
separately from the isolated draw fixture.

## Official local draw deployment

Historical checkpoint for the previous APK and launcher session.

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
