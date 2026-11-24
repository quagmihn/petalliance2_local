# Gacha content matrix

## Scripted tutorial

Guide quest 10010 follows 10009 and activates formation guide 10011.
`GameGuideMgr1.firstGacha` opens Senior machine 1, uses its free single,
then opens Supreme machine 2 and uses its free single. Dialogue 29 explicitly
names Grade A Panda. We identified template **45** using `petname45` and
the explicit template check in `GameGuideMgr3.firstSkillPromote`. The client
expects to show the new-Pet reveal before finishing the guide. A regular item
in the Supreme result cannot satisfy this flow.

| Scope | Evidence | Server rule |
| --- | --- | --- |
| Senior tutorial step | Machine 1 first group 4 → AwardElementInfo 164 → item 33066 | Consume the first guided Senior free attempt and grant this configured item. |
| Supreme tutorial step | NPC dialogue 29/30 and explicit Panda template 45 in the later guide | Active quest 10010, committed parent and a prior Senior free draw. Consume the one-time guide free entitlement, grant Panda, and persist objective progress in the same transaction. |
| Legacy recovery | Ordinary draws were recorded before the Panda rule existed | For an active, incomplete guide, report the outstanding Supreme entitlement as free. Ordinary history still exists. |
| Formation | Guide 10011 shows Edit Team and asks the player to deploy Panda | Select template 45 in the Android editor. Validate Panda in a committed fighting slot before accepting the quest commit. |

Both available static table variants point Supreme's first group 5 to
AwardElementInfo 165, item 34066 (Pumpkin Bag). This contradicts the tutorial
dialogue and reveal. The scripted rule follows the independent Lua and
localization evidence. The ordinary prizes are derived from the tables.

The unseeded Waydroid sequence completed both free draws and showed the
purple Grade A Panda. PostgreSQL recorded one voucher 33066 and one Panda
with template 45 and owned UID 36. Quest 10011 committed, cold login restored
Panda in fighting slot 1, and a real battle awarded it EXP. The independent
QA character subsequently used ordinary Senior free, Skill x1, and Skill x10
on the same APK and server. The ordinary paths granted 1, 1, and 10 items
at costs of 0, 98, and 898 respectively.

## Ordinary machines

| ID | Normal / first / first ten / regular ten / guarantee group | Confirmed normal awards and weights | Cost x1 / x10 | Free rule |
| --- | --- | --- | --- | --- |
| 1 Senior | 1 / 4 / 7 / 9 / 11 | Items 209 (1,500) and 212 (4,300). The source also lists Pet 180 (4,200), outside the local tier-4 cap. | 10,000 / 95,000 gold | Five per day, 300-second cooldown |
| 2 Supreme | 2 / 5 / 8 / 10 / 12 | Items 213 (1,500), 214 (4,200), 31049 (4,300) | 288 / 2,588 diamonds | 48-hour cooldown for the ordinary free draw |
| 3 Skill | 3 / 3 / 13 / 13 / 3 | Items 35023 (6,020), 31066 (2,780), 33066 (1,200) | 98 / 898 diamonds | Paid modes |

The exact target APK and the project server tables share the same hashes for
the audited files. They resolve 17 groups and 27 weighted entries. The
alternate extracted snapshot has 18 groups and 25 entries. Its normal pool
links for Senior and Supreme point to 21 and 23. The alternate snapshot's
group 25 totals 1,000 and is not a normal machine pool. Both variants are in
the generated `GACHA_CONTENT_MATRIX.json`.

The launcher validates the target's three normal pools and enables eight
ordinary entries after applying the Senior cap. For x10, the server uses
ten independent selections from the
configured normal pool as its local sequence rule. The source contains
separate first-ten, regular-ten, and ten-draw guarantee groups, but their
original server precedence and reset timing are unverified. Wish and Dream
link to RewardInfo 30009/30010. Their ledger effects, selection protocols,
and VIP or M-PASS modifiers remain unverified.

[Execution checkpoint](EXECUTION_CHECKPOINT.md) · [Generate the matrix](CONTENT_REFERENCE_MATRIX.md)
