# Content reference matrix

This audit uses the packaged XDat schemas, text files and English localization
database. It compares key binary tables with the exact runtime APK and reads
the alternate extracted snapshot separately. The target data yielded 228
parsed files and nine discovered files with parser blockers.

| Scope | Parsed | Reference evidence and coverage |
| --- | --- | --- |
| Items | 1,776 | 25 item types, 104 unresolved literal icons, 291 fashion links validated |
| Pet | 252 templates, 3,730 skills, 88 evolution rows | Panda, starter Pets and ordinary selected rewards have direct template validation |
| Equipment | 5 character configurations, 39 Pet equipment templates | Stats and upgrade-definition rows parsed, owned-instance lifecycle remains open |
| Fashion | 300 appearances, 10 suit effects | Voucher acquisition, equip and cold login are database tested |
| Gacha | 3 machines, 17 groups, 27 entries | All target draw references resolved, scripted Panda and normal pools implemented |
| Shop | 90 Market SKUs, 5 CommonShop definitions, 55 pools with 567 offers, 7 Activity and 50 Family products | Market resolves all item references. The rest require their own eligibility and stock semantics. |
| Quests | 747 | Parent and reward edges, Adventure targets, world-event links and intro Pet references. Unknown objective types retain their original fields. |
| Maps | 290 Adventures, 22,486 scene cells, 220 world events | The index preserves each Adventure ID, floor-cell membership, goal rows, authored scene events, and reward references. |
| Battles | 907 trainer groups, 2,142 monster records | Trainer member and helper references were checked against monster records. |
| Events and rewards | 43 activities, 31 sign-ins, 182 stationary awards, 3,211 RewardInfo, 2,994 AwardElementInfo | Parsed configuration and audited links, with runtime claims tracked by flow. |

Configured but unresolved targets include 493 CommonShop offer rows
(386 distinct IDs), 62 Adventure NPC offer rows (41 distinct IDs), three
ActivityShop items (410, 413, 414), 33 Pet award targets, one quest parent, and
367 quest-to-reward links (291 distinct RewardInfo IDs). These counters are
for the target APK snapshot. A missing reference does not make another
namespace with the same number a valid substitute.

Lost Forest and Secret Path share environment 1 and 5×6 dimensions. Each
has its own 30 authored `SceneInfo.number` cells. The trainer cells are 15
and 44, using groups 1 and 2. The predecessor, goal IDs, clear rewards,
EXP and progression rows differ by Adventure ID. The export includes the
exact-grid check used for entry. `FloorRelationInfo` belongs to Lost Tower.
[Map identity](MAP_IDENTITY_MATRIX.md)

## Generate the machine-readable files

```bash
python tools/build_content_registry.py \
  --apk dist/monster2_local-guide-runtime.apk \
  --output artifacts/content-continuation-20261122/catalogs
```

- `content_registry.jsonl` contains item, Pet, fashion and equipment records
  with exact asset paths and protocol/persistence annotations.
- `GACHA_CONTENT_MATRIX.json` links machines, pools, weights, rewards, costs
  and provenance across both asset snapshots.
- `quest_dependencies.json` contains quest nodes, objective arguments and
  unresolved dependencies. `adventure_content.json` maps each Adventure to
  its goal rows, cells by floor and authored events.
- `config_tables.json` contains raw parsed records for the audited content
  families. `content_coverage.json` lists discovered files and the full
  unresolved reference sets.

The exports describe source coverage. Gameplay outcomes and their verification
levels are recorded in [Coverage](COVERAGE_REPORT.md).
