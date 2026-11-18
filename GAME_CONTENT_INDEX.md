# Game content index

Generated from `apk_extracted/assets/res/Config/NewQuestInfo.dat` with `server/quest_config.py`; quest IDs and raw objective fields are fully parsed. Text names/descriptions are localization keys/empty strings in this binary table, so prose semantics remain partial unless confirmed by client Lua.

Quest records: **747**. IDs are listed in the table below.

Quest type numeric values are retained as configured; client enum names need separate enum confirmation. Parent and child links are direct configuration edges. Rewards are raw configured fields, not inferred.

| ID | Type | Name key | Prerequisite | Children | Objective(s) | Award ID / gold / EXP / diamonds | NPC / map unlock | Status |
|---:|---:|---|---:|---|---|---|---|---|
| 1 | 0 | xsyd1; strong=1; visible=0 | — | 10001 | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 2 | 0 | rwmc1; strong=0; visible=1 | 10001 | 3, 10038, 10039, 10046 | type=19, main=1, sub=0, final=0, amount=1, query=0 | 4000 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 3 | 0 | rwmc2; strong=0; visible=1 | 2 | 4 | type=19, main=2, sub=0, final=0, amount=1, query=0 | 4001 / 200 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 4 | 0 | rwmc3; strong=0; visible=1 | 3 | 5 | type=19, main=3, sub=0, final=0, amount=1, query=0 | 4002 / 200 / 80 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 5 | 0 | rwmc4; strong=0; visible=1 | 4 | 6 | type=19, main=4, sub=0, final=0, amount=1, query=0 | 4003 / 0 / 80 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 6 | 0 | rwmc5; strong=0; visible=1 | 5 | 7 | type=19, main=5, sub=0, final=0, amount=1, query=0 | 4004 / 200 / 90 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 7 | 0 | rwmc6; strong=0; visible=1 | 6 | 8 | type=19, main=6, sub=0, final=0, amount=1, query=0 | 4005 / 0 / 90 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 8 | 0 | rwmc7; strong=0; visible=1 | 7 | 9, 17 | type=19, main=7, sub=0, final=0, amount=1, query=0 | 4006 / 200 / 90 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 9 | 0 | rwmc8; strong=0; visible=1 | 8 | 10, 18 | type=19, main=8, sub=0, final=0, amount=1, query=0 | 4007 / 0 / 90 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10 | 0 | rwmc9; strong=0; visible=1 | 9 | 11, 19 | type=19, main=9, sub=0, final=0, amount=1, query=0 | 4008 / 500 / 100 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 11 | 0 | rwmc10; strong=0; visible=1 | 10 | 21, 20 | type=19, main=10, sub=0, final=0, amount=1, query=0 | 4009 / 500 / 100 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 17 | 0 | rwmc10007; strong=0; visible=1 | 8 | — | type=19, main=10007, sub=0, final=0, amount=1, query=0 | 4015 / 200 / 100 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 18 | 0 | rwmc10008; strong=0; visible=1 | 17 | — | type=19, main=10008, sub=0, final=0, amount=1, query=0 | 4016 / 0 / 100 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 19 | 0 | rwmc10009; strong=0; visible=1 | 18 | 175 | type=19, main=10009, sub=0, final=0, amount=1, query=0 | 4017 / 400 / 110 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 20 | 0 | rwmc10010; strong=0; visible=1 | 11 | — | type=19, main=10010, sub=0, final=0, amount=1, query=0 | 4017 / 500 / 110 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 21 | 0 | rwmc11; strong=0; visible=1 | 11 | 22, 30 | type=19, main=11, sub=0, final=0, amount=1, query=0 | 4018 / 0 / 100 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 22 | 0 | rwmc12; strong=0; visible=1 | 21 | 23, 31 | type=19, main=12, sub=0, final=0, amount=1, query=0 | 4018 / 0 / 100 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 23 | 0 | rwmc13; strong=0; visible=1 | 22 | 24, 32 | type=19, main=13, sub=0, final=0, amount=1, query=0 | 4019 / 0 / 110 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 24 | 0 | rwmc14; strong=0; visible=1 | 23 | 25, 26, 33 | type=19, main=14, sub=0, final=0, amount=1, query=0 | 4019 / 0 / 110 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 25 | 0 | rwmc15; strong=0; visible=1 | 24 | 34 | type=19, main=15, sub=0, final=0, amount=1, query=0 | 4019 / 0 / 110 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 26 | 0 | rwmc16; strong=0; visible=1 | 24 | 27, 35 | type=19, main=16, sub=0, final=0, amount=1, query=0 | 4020 / 0 / 120 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 27 | 0 | rwmc17; strong=0; visible=1 | 26 | 28, 36 | type=19, main=17, sub=0, final=0, amount=1, query=0 | 4020 / 0 / 120 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 28 | 0 | rwmc18; strong=0; visible=1 | 27 | 29, 37 | type=19, main=18, sub=0, final=0, amount=1, query=0 | 4020 / 0 / 120 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 29 | 0 | rwmc19; strong=0; visible=1 | 28 | 38, 49 | type=19, main=19, sub=0, final=0, amount=1, query=0 | 12004 / 0 / 130 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30 | 0 | rwmc10011; strong=0; visible=1 | 21 | 39 | type=19, main=10011, sub=0, final=0, amount=1, query=0 | 4019 / 0 / 110 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 31 | 0 | rwmc10012; strong=0; visible=1 | 22 | 40 | type=19, main=10012, sub=0, final=0, amount=1, query=0 | 4019 / 0 / 110 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 32 | 0 | rwmc10013; strong=0; visible=1 | 23 | 41 | type=19, main=10013, sub=0, final=0, amount=1, query=0 | 4020 / 0 / 120 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 33 | 0 | rwmc10014; strong=0; visible=1 | 24 | 42 | type=19, main=10014, sub=0, final=0, amount=1, query=0 | 4020 / 0 / 120 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 34 | 0 | rwmc10015; strong=0; visible=1 | 25 | 43 | type=19, main=10015, sub=0, final=0, amount=1, query=0 | 4020 / 0 / 120 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 35 | 0 | rwmc10016; strong=0; visible=1 | 26 | 44 | type=19, main=10016, sub=0, final=0, amount=1, query=0 | 4021 / 0 / 130 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 36 | 0 | rwmc10017; strong=0; visible=1 | 27 | 45 | type=19, main=10017, sub=0, final=0, amount=1, query=0 | 4021 / 0 / 130 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 37 | 0 | rwmc10018; strong=0; visible=1 | 28 | 46 | type=19, main=10018, sub=0, final=0, amount=1, query=0 | 4021 / 0 / 130 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 38 | 0 | rwmc10019; strong=0; visible=1 | 29 | 47 | type=19, main=10019, sub=0, final=0, amount=1, query=0 | 4022 / 0 / 140 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 39 | 0 | rwmc20011; strong=0; visible=1 | 30 | — | type=19, main=20011, sub=0, final=0, amount=1, query=0 | 4023 / 0 / 120 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 40 | 0 | rwmc20012; strong=0; visible=1 | 31 | — | type=19, main=20012, sub=0, final=0, amount=1, query=0 | 4020 / 0 / 120 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 41 | 0 | rwmc20013; strong=0; visible=1 | 32 | — | type=19, main=20013, sub=0, final=0, amount=1, query=0 | 4020 / 0 / 120 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 42 | 0 | rwmc20014; strong=0; visible=1 | 33 | — | type=19, main=20014, sub=0, final=0, amount=1, query=0 | 4021 / 0 / 130 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 43 | 0 | rwmc20015; strong=0; visible=1 | 34 | — | type=19, main=20015, sub=0, final=0, amount=1, query=0 | 4021 / 0 / 130 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 44 | 0 | rwmc20016; strong=0; visible=1 | 35 | — | type=19, main=20016, sub=0, final=0, amount=1, query=0 | 4021 / 0 / 130 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 45 | 0 | rwmc20017; strong=0; visible=1 | 36 | — | type=19, main=20017, sub=0, final=0, amount=1, query=0 | 4021 / 0 / 130 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 46 | 0 | rwmc20018; strong=0; visible=1 | 37 | — | type=19, main=20018, sub=0, final=0, amount=1, query=0 | 4022 / 0 / 140 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 47 | 0 | rwmc20019; strong=0; visible=1 | 38 | — | type=19, main=20019, sub=0, final=0, amount=1, query=0 | 4022 / 0 / 140 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 48 | 0 | rwmc20010; strong=0; visible=1 | 20 | — | type=19, main=20010, sub=0, final=0, amount=1, query=0 | 4017 / 0 / 120 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 49 | 0 | rwmc21; strong=0; visible=1 | 29 | 50, 59 | type=19, main=21, sub=0, final=0, amount=1, query=0 | 4023 / 100 / 130 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 50 | 0 | rwmc22; strong=0; visible=1 | 49 | 51, 60 | type=19, main=22, sub=0, final=0, amount=1, query=0 | 4024 / 0 / 130 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 51 | 0 | rwmc23; strong=0; visible=1 | 50 | 52, 61 | type=19, main=23, sub=0, final=0, amount=1, query=0 | 4025 / 200 / 140 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 52 | 0 | rwmc24; strong=0; visible=1 | 51 | 53, 62 | type=19, main=24, sub=0, final=0, amount=1, query=0 | 4026 / 0 / 140 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 53 | 0 | rwmc25; strong=0; visible=1 | 52 | 54, 63 | type=19, main=25, sub=0, final=0, amount=1, query=0 | 4027 / 300 / 140 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 54 | 0 | rwmc26; strong=0; visible=1 | 53 | 55, 64 | type=19, main=26, sub=0, final=0, amount=1, query=0 | 4028 / 0 / 150 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 55 | 0 | rwmc27; strong=0; visible=1 | 54 | 56, 65 | type=19, main=27, sub=0, final=0, amount=1, query=0 | 4029 / 400 / 150 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 56 | 0 | rwmc28; strong=0; visible=1 | 55 | 57, 66 | type=19, main=28, sub=0, final=0, amount=1, query=0 | 4030 / 0 / 150 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 57 | 0 | rwmc29; strong=0; visible=1 | 56 | 58, 67 | type=19, main=29, sub=0, final=0, amount=1, query=0 | 4031 / 500 / 160 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 58 | 0 | rwmc30; strong=0; visible=1 | 57 | 68, 79 | type=19, main=30, sub=0, final=0, amount=1, query=0 | 4032 / 500 / 160 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 59 | 0 | rwmc10021; strong=0; visible=1 | 49 | 69 | type=19, main=10021, sub=0, final=0, amount=1, query=0 | 4033 / 200 / 140 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 60 | 0 | rwmc10022; strong=0; visible=1 | 50 | 70 | type=19, main=10022, sub=0, final=0, amount=1, query=0 | 4034 / 300 / 150 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 61 | 0 | rwmc10023; strong=0; visible=1 | 51 | 71 | type=19, main=10023, sub=0, final=0, amount=1, query=0 | 4034 / 300 / 150 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 62 | 0 | rwmc10024; strong=0; visible=1 | 52 | 72 | type=19, main=10024, sub=0, final=0, amount=1, query=0 | 4035 / 300 / 150 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 63 | 0 | rwmc10025; strong=0; visible=1 | 53 | 73 | type=19, main=10025, sub=0, final=0, amount=1, query=0 | 4036 / 400 / 150 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 64 | 0 | rwmc10026; strong=0; visible=1 | 54 | 74 | type=19, main=10026, sub=0, final=0, amount=1, query=0 | 4037 / 400 / 160 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 65 | 0 | rwmc10027; strong=0; visible=1 | 55 | 75 | type=19, main=10027, sub=0, final=0, amount=1, query=0 | 4038 / 500 / 170 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 66 | 0 | rwmc10028; strong=0; visible=1 | 56 | 76 | type=19, main=10028, sub=0, final=0, amount=1, query=0 | 4039 / 500 / 170 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 67 | 0 | rwmc10029; strong=0; visible=1 | 57 | 77 | type=19, main=10029, sub=0, final=0, amount=1, query=0 | 4040 / 600 / 170 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 68 | 0 | rwmc10030; strong=0; visible=1 | 58 | 78 | type=19, main=10030, sub=0, final=0, amount=1, query=0 | 4041 / 600 / 170 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 69 | 0 | rwmc20021; strong=0; visible=1 | 59 | — | type=19, main=20021, sub=0, final=0, amount=1, query=0 | 4042 / 200 / 150 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 70 | 0 | rwmc20022; strong=0; visible=1 | 60 | — | type=19, main=20022, sub=0, final=0, amount=1, query=0 | 4043 / 200 / 150 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 71 | 0 | rwmc20023; strong=0; visible=1 | 61 | — | type=19, main=20023, sub=0, final=0, amount=1, query=0 | 4044 / 400 / 150 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 72 | 0 | rwmc20024; strong=0; visible=1 | 62 | — | type=19, main=20024, sub=0, final=0, amount=1, query=0 | 4045 / 400 / 160 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 73 | 0 | rwmc20025; strong=0; visible=1 | 63 | — | type=19, main=20025, sub=0, final=0, amount=1, query=0 | 4046 / 400 / 160 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 74 | 0 | rwmc20026; strong=0; visible=1 | 64 | — | type=19, main=20026, sub=0, final=0, amount=1, query=0 | 4047 / 600 / 160 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 75 | 0 | rwmc20027; strong=0; visible=1 | 65 | — | type=19, main=20027, sub=0, final=0, amount=1, query=0 | 4048 / 600 / 170 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 76 | 0 | rwmc20028; strong=0; visible=1 | 66 | — | type=19, main=20028, sub=0, final=0, amount=1, query=0 | 4049 / 600 / 170 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 77 | 0 | rwmc20029; strong=0; visible=1 | 67 | — | type=19, main=20029, sub=0, final=0, amount=1, query=0 | 4050 / 700 / 170 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 78 | 0 | rwmc20030; strong=0; visible=1 | 68 | — | type=19, main=20030, sub=0, final=0, amount=1, query=0 | 4051 / 700 / 170 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 79 | 0 | rwmc31; strong=0; visible=1 | 58 | 80, 89 | type=19, main=31, sub=0, final=0, amount=1, query=0 | 11050 / 200 / 160 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 80 | 0 | rwmc32; strong=0; visible=1 | 79 | 81, 90 | type=19, main=32, sub=0, final=0, amount=1, query=0 | 11051 / 200 / 170 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 81 | 0 | rwmc33; strong=0; visible=1 | 80 | 82, 91 | type=19, main=33, sub=0, final=0, amount=1, query=0 | 11052 / 200 / 170 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 82 | 0 | rwmc34; strong=0; visible=1 | 81 | 83, 92 | type=19, main=34, sub=0, final=0, amount=1, query=0 | 11053 / 300 / 170 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 83 | 0 | rwmc35; strong=0; visible=1 | 82 | 84, 93 | type=19, main=35, sub=0, final=0, amount=1, query=0 | 11054 / 300 / 180 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 84 | 0 | rwmc36; strong=0; visible=1 | 83 | 85, 94 | type=19, main=36, sub=0, final=0, amount=1, query=0 | 11055 / 300 / 180 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 85 | 0 | rwmc37; strong=0; visible=1 | 84 | 86, 95 | type=19, main=37, sub=0, final=0, amount=1, query=0 | 11056 / 300 / 180 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 86 | 0 | rwmc38; strong=0; visible=1 | 85 | 87, 96 | type=19, main=38, sub=0, final=0, amount=1, query=0 | 11057 / 400 / 180 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 87 | 0 | rwmc39; strong=0; visible=1 | 86 | 88, 97 | type=19, main=39, sub=0, final=0, amount=1, query=0 | 11058 / 400 / 190 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 88 | 0 | rwmc40; strong=0; visible=1 | 87 | 98, 109 | type=19, main=40, sub=0, final=0, amount=1, query=0 | 11059 / 400 / 190 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 89 | 0 | rwmc10031; strong=0; visible=1 | 79 | 99 | type=19, main=10031, sub=0, final=0, amount=1, query=0 | 11060 / 300 / 180 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 90 | 0 | rwmc10032; strong=0; visible=1 | 80 | 100 | type=19, main=10032, sub=0, final=0, amount=1, query=0 | 11061 / 300 / 180 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 91 | 0 | rwmc10033; strong=0; visible=1 | 81 | 101 | type=19, main=10033, sub=0, final=0, amount=1, query=0 | 11062 / 300 / 180 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 92 | 0 | rwmc10034; strong=0; visible=1 | 82 | 102 | type=19, main=10034, sub=0, final=0, amount=1, query=0 | 11063 / 400 / 190 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 93 | 0 | rwmc10035; strong=0; visible=1 | 83 | 103 | type=19, main=10035, sub=0, final=0, amount=1, query=0 | 11064 / 400 / 190 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 94 | 0 | rwmc10036; strong=0; visible=1 | 84 | 104 | type=19, main=10036, sub=0, final=0, amount=1, query=0 | 11065 / 400 / 190 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 95 | 0 | rwmc10037; strong=0; visible=1 | 85 | 105 | type=19, main=10037, sub=0, final=0, amount=1, query=0 | 11066 / 500 / 200 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 96 | 0 | rwmc10038; strong=0; visible=1 | 86 | 106 | type=19, main=10038, sub=0, final=0, amount=1, query=0 | 11067 / 500 / 200 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 97 | 0 | rwmc10039; strong=0; visible=1 | 87 | 107 | type=19, main=10039, sub=0, final=0, amount=1, query=0 | 11068 / 500 / 200 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 98 | 0 | rwmc10040; strong=0; visible=1 | 88 | 108 | type=19, main=10040, sub=0, final=0, amount=1, query=0 | 11069 / 500 / 210 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 99 | 0 | rwmc20031; strong=0; visible=1 | 89 | — | type=19, main=20031, sub=0, final=0, amount=1, query=0 | 11070 / 400 / 180 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 100 | 0 | rwmc20032; strong=0; visible=1 | 90 | — | type=19, main=20032, sub=0, final=0, amount=1, query=0 | 11071 / 400 / 180 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 101 | 0 | rwmc20033; strong=0; visible=1 | 91 | — | type=19, main=20033, sub=0, final=0, amount=1, query=0 | 11072 / 400 / 180 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 102 | 0 | rwmc20034; strong=0; visible=1 | 92 | — | type=19, main=20034, sub=0, final=0, amount=1, query=0 | 11073 / 500 / 190 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 103 | 0 | rwmc20035; strong=0; visible=1 | 93 | — | type=19, main=20035, sub=0, final=0, amount=1, query=0 | 11074 / 500 / 190 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 104 | 0 | rwmc20036; strong=0; visible=1 | 94 | — | type=19, main=20036, sub=0, final=0, amount=1, query=0 | 11075 / 500 / 190 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 105 | 0 | rwmc20037; strong=0; visible=1 | 95 | — | type=19, main=20037, sub=0, final=0, amount=1, query=0 | 11076 / 500 / 200 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 106 | 0 | rwmc20038; strong=0; visible=1 | 96 | — | type=19, main=20038, sub=0, final=0, amount=1, query=0 | 11077 / 500 / 200 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 107 | 0 | rwmc20039; strong=0; visible=1 | 97 | — | type=19, main=20039, sub=0, final=0, amount=1, query=0 | 11078 / 500 / 200 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 108 | 0 | rwmc20040; strong=0; visible=1 | 98 | — | type=19, main=20040, sub=0, final=0, amount=1, query=0 | 11079 / 500 / 210 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 109 | 0 | rwmc41; strong=0; visible=1 | 88 | 110, 120 | type=19, main=41, sub=0, final=0, amount=1, query=0 | 11080 / 400 / 190 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 110 | 0 | rwmc42; strong=0; visible=1 | 109 | 121, 111, 112 | type=19, main=42, sub=0, final=0, amount=1, query=0 | 11081 / 400 / 200 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 111 | 0 | rwmc43; strong=0; visible=1 | 110 | 122 | type=19, main=43, sub=0, final=0, amount=1, query=0 | 11082 / 400 / 200 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 112 | 0 | rwmc44; strong=0; visible=1 | 110 | 123, 113 | type=19, main=44, sub=0, final=0, amount=1, query=0 | 11083 / 500 / 210 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 113 | 0 | rwmc45; strong=0; visible=1 | 112 | 124, 114, 115 | type=19, main=45, sub=0, final=0, amount=1, query=0 | 11084 / 500 / 210 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 114 | 0 | rwmc46; strong=0; visible=1 | 113 | 125 | type=19, main=46, sub=0, final=0, amount=1, query=0 | 11085 / 500 / 220 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 115 | 0 | rwmc47; strong=0; visible=1 | 113 | 126, 116 | type=19, main=47, sub=0, final=0, amount=1, query=0 | 11086 / 600 / 220 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 116 | 0 | rwmc48; strong=0; visible=1 | 115 | 127, 117 | type=19, main=48, sub=0, final=0, amount=1, query=0 | 11087 / 600 / 220 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 117 | 0 | rwmc49; strong=0; visible=1 | 116 | 118, 119, 128, 142 | type=19, main=49, sub=0, final=0, amount=1, query=0 | 11088 / 600 / 230 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 118 | 0 | rwmc50; strong=0; visible=1 | 2087 | 129 | type=19, main=50, sub=0, final=0, amount=1, query=0 | 11089 / 600 / 230 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 119 | 0 | rwmc51; strong=0; visible=1 | 2089 | 130 | type=19, main=51, sub=0, final=0, amount=1, query=0 | 11090 / 600 / 230 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 120 | 0 | rwmc10041; strong=0; visible=1 | 109 | 131 | type=19, main=10041, sub=0, final=0, amount=1, query=0 | 11091 / 500 / 210 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 121 | 0 | rwmc10042; strong=0; visible=1 | 110 | 132 | type=19, main=10042, sub=0, final=0, amount=1, query=0 | 11092 / 500 / 210 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 122 | 0 | rwmc10043; strong=0; visible=1 | 111 | 133 | type=19, main=10043, sub=0, final=0, amount=1, query=0 | 11093 / 500 / 210 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 123 | 0 | rwmc10044; strong=0; visible=1 | 112 | 134 | type=19, main=10044, sub=0, final=0, amount=1, query=0 | 11094 / 600 / 220 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 124 | 0 | rwmc10045; strong=0; visible=1 | 113 | 135 | type=19, main=10045, sub=0, final=0, amount=1, query=0 | 11095 / 600 / 220 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 125 | 0 | rwmc10046; strong=0; visible=1 | 114 | 136 | type=19, main=10046, sub=0, final=0, amount=1, query=0 | 11096 / 600 / 220 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 126 | 0 | rwmc10047; strong=0; visible=1 | 115 | 137 | type=19, main=10047, sub=0, final=0, amount=1, query=0 | 11097 / 700 / 230 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 127 | 0 | rwmc10048; strong=0; visible=1 | 116 | 138 | type=19, main=10048, sub=0, final=0, amount=1, query=0 | 11098 / 700 / 230 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 128 | 0 | rwmc10049; strong=0; visible=1 | 117 | 139 | type=19, main=10049, sub=0, final=0, amount=1, query=0 | 11099 / 700 / 230 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 129 | 0 | rwmc10050; strong=0; visible=1 | 118 | 140 | type=19, main=10050, sub=0, final=0, amount=1, query=0 | 11100 / 700 / 230 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 130 | 0 | rwmc10051; strong=0; visible=1 | 119 | 141 | type=19, main=10051, sub=0, final=0, amount=1, query=0 | 11101 / 700 / 240 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 131 | 0 | rwmc20041; strong=0; visible=1 | 120 | — | type=19, main=20041, sub=0, final=0, amount=1, query=0 | 11102 / 600 / 210 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 132 | 0 | rwmc20042; strong=0; visible=1 | 121 | — | type=19, main=20042, sub=0, final=0, amount=1, query=0 | 11103 / 600 / 210 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 133 | 0 | rwmc20043; strong=0; visible=1 | 122 | — | type=19, main=20043, sub=0, final=0, amount=1, query=0 | 11104 / 600 / 210 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 134 | 0 | rwmc20044; strong=0; visible=1 | 123 | — | type=19, main=20044, sub=0, final=0, amount=1, query=0 | 11105 / 700 / 220 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 135 | 0 | rwmc20045; strong=0; visible=1 | 124 | — | type=19, main=20045, sub=0, final=0, amount=1, query=0 | 11106 / 700 / 220 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 136 | 0 | rwmc20046; strong=0; visible=1 | 125 | — | type=19, main=20046, sub=0, final=0, amount=1, query=0 | 11107 / 700 / 220 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 137 | 0 | rwmc20047; strong=0; visible=1 | 126 | — | type=19, main=20047, sub=0, final=0, amount=1, query=0 | 11108 / 800 / 230 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 138 | 0 | rwmc20048; strong=0; visible=1 | 127 | — | type=19, main=20048, sub=0, final=0, amount=1, query=0 | 11109 / 800 / 230 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 139 | 0 | rwmc20049; strong=0; visible=1 | 128 | — | type=19, main=20049, sub=0, final=0, amount=1, query=0 | 11110 / 800 / 230 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 140 | 0 | rwmc20050; strong=0; visible=1 | 129 | — | type=19, main=20050, sub=0, final=0, amount=1, query=0 | 11111 / 800 / 240 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 141 | 0 | rwmc20051; strong=0; visible=1 | 130 | — | type=19, main=20051, sub=0, final=0, amount=1, query=0 | 11112 / 800 / 240 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 142 | 0 | rwmc52; strong=0; visible=1 | 117 | 143, 153 | type=19, main=52, sub=0, final=0, amount=1, query=0 | 11127 / 500 / 230 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 143 | 0 | rwmc53; strong=0; visible=1 | 142 | 144, 154 | type=19, main=53, sub=0, final=0, amount=1, query=0 | 11128 / 500 / 240 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 144 | 0 | rwmc54; strong=0; visible=1 | 143 | 145, 155 | type=19, main=54, sub=0, final=0, amount=1, query=0 | 11129 / 500 / 240 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 145 | 0 | rwmc55; strong=0; visible=1 | 144 | 146, 156 | type=19, main=55, sub=0, final=0, amount=1, query=0 | 11130 / 600 / 240 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 146 | 0 | rwmc56; strong=0; visible=1 | 145 | 147, 157 | type=19, main=56, sub=0, final=0, amount=1, query=0 | 11131 / 600 / 250 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 147 | 0 | rwmc57; strong=0; visible=1 | 146 | 148, 158 | type=19, main=57, sub=0, final=0, amount=1, query=0 | 11132 / 600 / 250 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 148 | 0 | rwmc58; strong=0; visible=1 | 147 | 149, 159 | type=19, main=58, sub=0, final=0, amount=1, query=0 | 11133 / 600 / 250 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 149 | 0 | rwmc59; strong=0; visible=1 | 148 | 150, 160 | type=19, main=59, sub=0, final=0, amount=1, query=0 | 11134 / 600 / 250 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 150 | 0 | rwmc60; strong=0; visible=1 | 149 | 151, 161 | type=19, main=60, sub=0, final=0, amount=1, query=0 | 11135 / 600 / 260 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 151 | 0 | rwmc61; strong=0; visible=1 | 150 | 152, 162 | type=19, main=61, sub=0, final=0, amount=1, query=0 | 11136 / 700 / 260 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 152 | 0 | rwmc62; strong=0; visible=1 | 151 | 178, 163 | type=19, main=62, sub=0, final=0, amount=1, query=0 | 11137 / 700 / 260 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 153 | 0 | rwmc10052; strong=0; visible=1 | 142 | 164 | type=19, main=10052, sub=0, final=0, amount=1, query=0 | 11138 / 600 / 240 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 154 | 0 | rwmc10053; strong=0; visible=1 | 143 | 165 | type=19, main=10053, sub=0, final=0, amount=1, query=0 | 11139 / 600 / 250 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 155 | 0 | rwmc10054; strong=0; visible=1 | 144 | 166 | type=19, main=10054, sub=0, final=0, amount=1, query=0 | 11140 / 600 / 250 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 156 | 0 | rwmc10055; strong=0; visible=1 | 145 | 167 | type=19, main=10055, sub=0, final=0, amount=1, query=0 | 11141 / 700 / 250 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 157 | 0 | rwmc10056; strong=0; visible=1 | 146 | 168 | type=19, main=10056, sub=0, final=0, amount=1, query=0 | 11142 / 700 / 260 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 158 | 0 | rwmc10057; strong=0; visible=1 | 147 | 169 | type=19, main=10057, sub=0, final=0, amount=1, query=0 | 11143 / 700 / 260 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 159 | 0 | rwmc10058; strong=0; visible=1 | 148 | 170 | type=19, main=10058, sub=0, final=0, amount=1, query=0 | 11144 / 700 / 260 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 160 | 0 | rwmc10059; strong=0; visible=1 | 149 | 171 | type=19, main=10059, sub=0, final=0, amount=1, query=0 | 11145 / 700 / 260 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 161 | 0 | rwmc10060; strong=0; visible=1 | 150 | 172 | type=19, main=10060, sub=0, final=0, amount=1, query=0 | 11146 / 700 / 270 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 162 | 0 | rwmc10061; strong=0; visible=1 | 151 | 173 | type=19, main=10061, sub=0, final=0, amount=1, query=0 | 11147 / 800 / 270 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 163 | 0 | rwmc10062; strong=0; visible=1 | 152 | 174 | type=19, main=10062, sub=0, final=0, amount=1, query=0 | 11148 / 800 / 270 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 164 | 0 | rwmc20052; strong=0; visible=1 | 153 | — | type=19, main=20052, sub=0, final=0, amount=1, query=0 | 11149 / 700 / 250 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 165 | 0 | rwmc20053; strong=0; visible=1 | 154 | — | type=19, main=20053, sub=0, final=0, amount=1, query=0 | 11150 / 700 / 250 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 166 | 0 | rwmc20054; strong=0; visible=1 | 155 | — | type=19, main=20054, sub=0, final=0, amount=1, query=0 | 11151 / 700 / 250 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 167 | 0 | rwmc20055; strong=0; visible=1 | 156 | — | type=19, main=20055, sub=0, final=0, amount=1, query=0 | 11152 / 800 / 260 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 168 | 0 | rwmc20056; strong=0; visible=1 | 157 | — | type=19, main=20056, sub=0, final=0, amount=1, query=0 | 11153 / 800 / 260 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 169 | 0 | rwmc20057; strong=0; visible=1 | 158 | — | type=19, main=20057, sub=0, final=0, amount=1, query=0 | 11154 / 800 / 260 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 170 | 0 | rwmc20058; strong=0; visible=1 | 159 | — | type=19, main=20058, sub=0, final=0, amount=1, query=0 | 11155 / 800 / 270 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 171 | 0 | rwmc20059; strong=0; visible=1 | 160 | — | type=19, main=20059, sub=0, final=0, amount=1, query=0 | 11156 / 800 / 270 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 172 | 0 | rwmc20060; strong=0; visible=1 | 161 | — | type=19, main=20060, sub=0, final=0, amount=1, query=0 | 11157 / 800 / 270 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 173 | 0 | rwmc20061; strong=0; visible=1 | 162 | — | type=19, main=20061, sub=0, final=0, amount=1, query=0 | 11158 / 900 / 280 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 174 | 0 | rwmc20062; strong=0; visible=1 | 163 | — | type=19, main=20062, sub=0, final=0, amount=1, query=0 | 11159 / 900 / 280 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 175 | 0 | rwms20009; strong=0; visible=1 | 19 | — | type=19, main=20009, sub=0, final=0, amount=1, query=0 | 11161 / 500 / 130 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 176 | 0 | ycrw20009; strong=0; visible=0 | 177 | 10068 | type=19, main=20009, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 177 | 0 | ycrw10009; strong=0; visible=0 | 20007 | 176 | type=19, main=10009, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 178 | 0 | rwmc63; strong=0; visible=1 | 152 | 179, 180, 188 | type=19, main=63, sub=0, final=0, amount=1, query=0 | 11162 / 700 / 270 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 179 | 0 | rwmc64; strong=0; visible=1 | 178 | 189 | type=19, main=64, sub=0, final=0, amount=1, query=0 | 11163 / 700 / 270 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 180 | 0 | rwmc65; strong=0; visible=1 | 178 | 181, 190 | type=19, main=65, sub=0, final=0, amount=1, query=0 | 11164 / 700 / 280 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 181 | 0 | rwmc66; strong=0; visible=1 | 180 | 182, 191 | type=19, main=66, sub=0, final=0, amount=1, query=0 | 11165 / 800 / 280 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 182 | 0 | rwmc67; strong=0; visible=1 | 181 | 183, 192 | type=19, main=67, sub=0, final=0, amount=1, query=0 | 11166 / 800 / 280 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 183 | 0 | rwmc68; strong=0; visible=1 | 182 | 184, 185, 193 | type=19, main=68, sub=0, final=0, amount=1, query=0 | 11167 / 800 / 290 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 184 | 0 | rwmc69; strong=0; visible=1 | 183 | 194 | type=19, main=69, sub=0, final=0, amount=1, query=0 | 11168 / 900 / 290 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 185 | 0 | rwmc70; strong=0; visible=1 | 183 | 186, 195 | type=19, main=70, sub=0, final=0, amount=1, query=0 | 11169 / 900 / 290 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 186 | 0 | rwmc71; strong=0; visible=1 | 185 | 187, 196 | type=19, main=71, sub=0, final=0, amount=1, query=0 | 11170 / 900 / 290 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 187 | 0 | rwmc72; strong=0; visible=1 | 186 | 197, 208 | type=19, main=72, sub=0, final=0, amount=1, query=0 | 11171 / 900 / 300 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 188 | 0 | rwmc10063; strong=0; visible=1 | 178 | 198 | type=19, main=10063, sub=0, final=0, amount=1, query=0 | 11172 / 800 / 280 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 189 | 0 | rwmc10064; strong=0; visible=1 | 179 | 199 | type=19, main=10064, sub=0, final=0, amount=1, query=0 | 11173 / 800 / 280 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 190 | 0 | rwmc10065; strong=0; visible=1 | 180 | 200 | type=19, main=10065, sub=0, final=0, amount=1, query=0 | 11174 / 800 / 290 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 191 | 0 | rwmc10066; strong=0; visible=1 | 181 | 201 | type=19, main=10066, sub=0, final=0, amount=1, query=0 | 11175 / 900 / 290 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 192 | 0 | rwmc10067; strong=0; visible=1 | 182 | 202 | type=19, main=10067, sub=0, final=0, amount=1, query=0 | 11176 / 900 / 290 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 193 | 0 | rwmc10068; strong=0; visible=1 | 183 | 203 | type=19, main=10068, sub=0, final=0, amount=1, query=0 | 11177 / 900 / 300 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 194 | 0 | rwmc10069; strong=0; visible=1 | 184 | 204 | type=19, main=10069, sub=0, final=0, amount=1, query=0 | 11178 / 1000 / 300 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 195 | 0 | rwmc10070; strong=0; visible=1 | 185 | 205 | type=19, main=10070, sub=0, final=0, amount=1, query=0 | 11179 / 1000 / 310 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 196 | 0 | rwmc10071; strong=0; visible=1 | 186 | 206 | type=19, main=10071, sub=0, final=0, amount=1, query=0 | 11180 / 1000 / 310 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 197 | 0 | rwmc10072; strong=0; visible=1 | 187 | 207 | type=19, main=10072, sub=0, final=0, amount=1, query=0 | 11181 / 1000 / 310 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 198 | 0 | rwmc20063; strong=0; visible=1 | 188 | — | type=19, main=20063, sub=0, final=0, amount=1, query=0 | 11182 / 900 / 290 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 199 | 0 | rwmc20064; strong=0; visible=1 | 189 | — | type=19, main=20064, sub=0, final=0, amount=1, query=0 | 11183 / 900 / 290 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 200 | 0 | rwmc20065; strong=0; visible=1 | 190 | — | type=19, main=20065, sub=0, final=0, amount=1, query=0 | 11184 / 900 / 290 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 201 | 0 | rwmc20066; strong=0; visible=1 | 191 | — | type=19, main=20066, sub=0, final=0, amount=1, query=0 | 11185 / 1000 / 290 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 202 | 0 | rwmc20067; strong=0; visible=1 | 192 | — | type=19, main=20067, sub=0, final=0, amount=1, query=0 | 11186 / 1000 / 300 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 203 | 0 | rwmc20068; strong=0; visible=1 | 193 | — | type=19, main=20068, sub=0, final=0, amount=1, query=0 | 11187 / 1000 / 300 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 204 | 0 | rwmc20069; strong=0; visible=1 | 194 | — | type=19, main=20069, sub=0, final=0, amount=1, query=0 | 11188 / 1100 / 300 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 205 | 0 | rwmc20070; strong=0; visible=1 | 195 | — | type=19, main=20070, sub=0, final=0, amount=1, query=0 | 11189 / 1100 / 310 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 206 | 0 | rwmc20071; strong=0; visible=1 | 196 | — | type=19, main=20071, sub=0, final=0, amount=1, query=0 | 11190 / 1100 / 310 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 207 | 0 | rwmc20072; strong=0; visible=1 | 197 | — | type=19, main=20072, sub=0, final=0, amount=1, query=0 | 11191 / 1100 / 310 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 208 | 0 | rwmc73; strong=0; visible=1 | 187 | 209, 210, 218 | type=19, main=73, sub=0, final=0, amount=1, query=0 | 11195 / 800 / 300 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 209 | 0 | rwmc74; strong=0; visible=1 | 208 | 219 | type=19, main=74, sub=0, final=0, amount=1, query=0 | 11196 / 800 / 300 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 210 | 0 | rwmc75; strong=0; visible=1 | 208 | 211, 220 | type=19, main=75, sub=0, final=0, amount=1, query=0 | 11197 / 800 / 310 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 211 | 0 | rwmc76; strong=0; visible=1 | 210 | 212, 221 | type=19, main=76, sub=0, final=0, amount=1, query=0 | 11198 / 900 / 310 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 212 | 0 | rwmc77; strong=0; visible=1 | 211 | 213, 222 | type=19, main=77, sub=0, final=0, amount=1, query=0 | 11199 / 900 / 310 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 213 | 0 | rwmc78; strong=0; visible=1 | 212 | 214, 215, 223 | type=19, main=78, sub=0, final=0, amount=1, query=0 | 11200 / 900 / 320 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 214 | 0 | rwmc79; strong=0; visible=1 | 213 | 224 | type=19, main=79, sub=0, final=0, amount=1, query=0 | 11201 / 1000 / 320 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 215 | 0 | rwmc80; strong=0; visible=1 | 213 | 216, 217, 225 | type=19, main=80, sub=0, final=0, amount=1, query=0 | 11202 / 1000 / 320 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 216 | 0 | rwmc81; strong=0; visible=1 | 215 | 226 | type=19, main=81, sub=0, final=0, amount=1, query=0 | 11203 / 1000 / 330 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 217 | 0 | rwmc82; strong=0; visible=1 | 215 | 227, 238 | type=19, main=82, sub=0, final=0, amount=1, query=0 | 11204 / 1000 / 330 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 218 | 0 | rwmc10073; strong=0; visible=1 | 208 | 228 | type=19, main=10073, sub=0, final=0, amount=1, query=0 | 11205 / 900 / 320 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 219 | 0 | rwmc10074; strong=0; visible=1 | 209 | 229 | type=19, main=10074, sub=0, final=0, amount=1, query=0 | 11206 / 900 / 320 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 220 | 0 | rwmc10075; strong=0; visible=1 | 210 | 230 | type=19, main=10075, sub=0, final=0, amount=1, query=0 | 11207 / 900 / 320 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 221 | 0 | rwmc10076; strong=0; visible=1 | 211 | 231 | type=19, main=10076, sub=0, final=0, amount=1, query=0 | 11208 / 1000 / 330 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 222 | 0 | rwmc10077; strong=0; visible=1 | 212 | 232 | type=19, main=10077, sub=0, final=0, amount=1, query=0 | 11209 / 1000 / 330 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 223 | 0 | rwmc10078; strong=0; visible=1 | 213 | 233 | type=19, main=10078, sub=0, final=0, amount=1, query=0 | 11210 / 1000 / 330 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 224 | 0 | rwmc10079; strong=0; visible=1 | 214 | 234 | type=19, main=10079, sub=0, final=0, amount=1, query=0 | 11211 / 1100 / 330 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 225 | 0 | rwmc10080; strong=0; visible=1 | 215 | 235 | type=19, main=10080, sub=0, final=0, amount=1, query=0 | 11212 / 1100 / 340 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 226 | 0 | rwmc10081; strong=0; visible=1 | 216 | 236 | type=19, main=10081, sub=0, final=0, amount=1, query=0 | 11213 / 1100 / 340 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 227 | 0 | rwmc10082; strong=0; visible=1 | 217 | 237 | type=19, main=10082, sub=0, final=0, amount=1, query=0 | 11214 / 1100 / 340 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 228 | 0 | rwmc20073; strong=0; visible=1 | 218 | — | type=19, main=20073, sub=0, final=0, amount=1, query=0 | 11215 / 1000 / 320 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 229 | 0 | rwmc20074; strong=0; visible=1 | 219 | — | type=19, main=20074, sub=0, final=0, amount=1, query=0 | 11216 / 1000 / 320 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 230 | 0 | rwmc20075; strong=0; visible=1 | 220 | — | type=19, main=20075, sub=0, final=0, amount=1, query=0 | 11217 / 1000 / 320 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 231 | 0 | rwmc20076; strong=0; visible=1 | 221 | — | type=19, main=20076, sub=0, final=0, amount=1, query=0 | 11218 / 1100 / 330 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 232 | 0 | rwmc20077; strong=0; visible=1 | 222 | — | type=19, main=20077, sub=0, final=0, amount=1, query=0 | 11219 / 1100 / 330 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 233 | 0 | rwmc20078; strong=0; visible=1 | 223 | — | type=19, main=20078, sub=0, final=0, amount=1, query=0 | 11220 / 1100 / 330 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 234 | 0 | rwmc20079; strong=0; visible=1 | 224 | — | type=19, main=20079, sub=0, final=0, amount=1, query=0 | 11221 / 1200 / 330 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 235 | 0 | rwmc20080; strong=0; visible=1 | 225 | — | type=19, main=20080, sub=0, final=0, amount=1, query=0 | 11222 / 1200 / 340 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 236 | 0 | rwmc20081; strong=0; visible=1 | 226 | — | type=19, main=20081, sub=0, final=0, amount=1, query=0 | 11223 / 1200 / 340 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 237 | 0 | rwmc20082; strong=0; visible=1 | 227 | — | type=19, main=20082, sub=0, final=0, amount=1, query=0 | 11224 / 1200 / 340 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 238 | 0 | rwmc83; strong=0; visible=1 | 217 | 239, 248 | type=19, main=83, sub=0, final=0, amount=1, query=0 | 11226 / 1100 / 340 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 239 | 0 | rwmc84; strong=0; visible=1 | 238 | 240, 241, 249 | type=19, main=84, sub=0, final=0, amount=1, query=0 | 11227 / 1100 / 340 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 240 | 0 | rwmc85; strong=0; visible=1 | 239 | 250 | type=19, main=85, sub=0, final=0, amount=1, query=0 | 11228 / 1100 / 340 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 241 | 0 | rwmc86; strong=0; visible=1 | 239 | 242, 251 | type=19, main=86, sub=0, final=0, amount=1, query=0 | 11229 / 1200 / 340 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 242 | 0 | rwmc87; strong=0; visible=1 | 241 | 243, 252 | type=19, main=87, sub=0, final=0, amount=1, query=0 | 11230 / 1200 / 340 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 243 | 0 | rwmc88; strong=0; visible=1 | 242 | 244, 245, 253 | type=19, main=88, sub=0, final=0, amount=1, query=0 | 11231 / 1200 / 340 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 244 | 0 | rwmc89; strong=0; visible=1 | 243 | 254 | type=19, main=89, sub=0, final=0, amount=1, query=0 | 11232 / 1300 / 340 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 245 | 0 | rwmc90; strong=0; visible=1 | 243 | 246, 255 | type=19, main=90, sub=0, final=0, amount=1, query=0 | 11233 / 1300 / 340 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 246 | 0 | rwmc91; strong=0; visible=1 | 245 | 247, 256 | type=19, main=91, sub=0, final=0, amount=1, query=0 | 11234 / 1300 / 340 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 247 | 0 | rwmc92; strong=0; visible=1 | 246 | 257, 268 | type=19, main=92, sub=0, final=0, amount=1, query=0 | 11235 / 1300 / 340 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 248 | 0 | rwmc10083; strong=0; visible=1 | 238 | 258 | type=19, main=10083, sub=0, final=0, amount=1, query=0 | 11236 / 1200 / 350 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 249 | 0 | rwmc10084; strong=0; visible=1 | 239 | 259 | type=19, main=10084, sub=0, final=0, amount=1, query=0 | 11237 / 1200 / 350 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 250 | 0 | rwmc10085; strong=0; visible=1 | 240 | 260 | type=19, main=10085, sub=0, final=0, amount=1, query=0 | 11238 / 1200 / 350 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 251 | 0 | rwmc10086; strong=0; visible=1 | 241 | 261 | type=19, main=10086, sub=0, final=0, amount=1, query=0 | 11239 / 1300 / 350 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 252 | 0 | rwmc10087; strong=0; visible=1 | 242 | 262 | type=19, main=10087, sub=0, final=0, amount=1, query=0 | 11240 / 1300 / 350 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 253 | 0 | rwmc10088; strong=0; visible=1 | 243 | 263 | type=19, main=10088, sub=0, final=0, amount=1, query=0 | 11241 / 1300 / 350 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 254 | 0 | rwmc10089; strong=0; visible=1 | 244 | 264 | type=19, main=10089, sub=0, final=0, amount=1, query=0 | 11242 / 1400 / 350 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 255 | 0 | rwmc10090; strong=0; visible=1 | 245 | 265 | type=19, main=10092, sub=0, final=0, amount=1, query=0 | 11243 / 1400 / 350 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 256 | 0 | rwmc10091; strong=0; visible=1 | 246 | 266 | type=19, main=10090, sub=0, final=0, amount=1, query=0 | 11244 / 1400 / 350 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 257 | 0 | rwmc10092; strong=0; visible=1 | 247 | 267 | type=19, main=10091, sub=0, final=0, amount=1, query=0 | 11245 / 1400 / 350 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 258 | 0 | rwmc20083; strong=0; visible=1 | 248 | — | type=19, main=20083, sub=0, final=0, amount=1, query=0 | 11246 / 1300 / 360 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 259 | 0 | rwmc20084; strong=0; visible=1 | 249 | — | type=19, main=20084, sub=0, final=0, amount=1, query=0 | 11247 / 1300 / 360 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 260 | 0 | rwmc20085; strong=0; visible=1 | 250 | — | type=19, main=20085, sub=0, final=0, amount=1, query=0 | 11248 / 1300 / 360 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 261 | 0 | rwmc20086; strong=0; visible=1 | 251 | — | type=19, main=20086, sub=0, final=0, amount=1, query=0 | 11249 / 1400 / 360 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 262 | 0 | rwmc20087; strong=0; visible=1 | 252 | — | type=19, main=20087, sub=0, final=0, amount=1, query=0 | 11250 / 1400 / 360 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 263 | 0 | rwmc20088; strong=0; visible=1 | 253 | — | type=19, main=20088, sub=0, final=0, amount=1, query=0 | 11251 / 1400 / 360 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 264 | 0 | rwmc20089; strong=0; visible=1 | 254 | — | type=19, main=20089, sub=0, final=0, amount=1, query=0 | 11252 / 1500 / 360 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 265 | 0 | rwmc20090; strong=0; visible=1 | 255 | — | type=19, main=20092, sub=0, final=0, amount=1, query=0 | 11253 / 1500 / 360 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 266 | 0 | rwmc20091; strong=0; visible=1 | 256 | — | type=19, main=20090, sub=0, final=0, amount=1, query=0 | 11254 / 1500 / 360 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 267 | 0 | rwmc20092; strong=0; visible=1 | 257 | — | type=19, main=20091, sub=0, final=0, amount=1, query=0 | 11255 / 1500 / 360 / 0 | NPC fields in objective; unlock_map= | Config parsed; runtime status not inferred |
| 268 | 0 | rwmc93; strong=0; visible=1 | 247 | 269, 278 | type=19, main=93, sub=0, final=0, amount=1, query=0 | 11257 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 269 | 0 | rwmc94; strong=0; visible=1 | 268 | 270, 279 | type=19, main=94, sub=0, final=0, amount=1, query=0 | 11258 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 270 | 0 | rwmc95; strong=0; visible=1 | 269 | 271, 280 | type=19, main=95, sub=0, final=0, amount=1, query=0 | 11259 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 271 | 0 | rwmc96; strong=0; visible=1 | 270 | 272, 281 | type=19, main=96, sub=0, final=0, amount=1, query=0 | 11260 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 272 | 0 | rwmc97; strong=0; visible=1 | 271 | 273, 282 | type=19, main=97, sub=0, final=0, amount=1, query=0 | 11261 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 273 | 0 | rwmc98; strong=0; visible=1 | 272 | 274, 283 | type=19, main=98, sub=0, final=0, amount=1, query=0 | 11262 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 274 | 0 | rwmc99; strong=0; visible=1 | 273 | 275, 284 | type=19, main=99, sub=0, final=0, amount=1, query=0 | 11263 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 275 | 0 | rwmc100; strong=0; visible=1 | 274 | 276, 285 | type=19, main=100, sub=0, final=0, amount=1, query=0 | 11264 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 276 | 0 | rwmc101; strong=0; visible=1 | 275 | 277, 286 | type=19, main=101, sub=0, final=0, amount=1, query=0 | 11265 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 277 | 0 | rwmc102; strong=0; visible=1 | 276 | 287 | type=19, main=102, sub=0, final=0, amount=1, query=0 | 11266 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 278 | 0 | rwmc10093; strong=0; visible=1 | 268 | 288 | type=19, main=10093, sub=0, final=0, amount=1, query=0 | 11267 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 279 | 0 | rwmc10094; strong=0; visible=1 | 269 | 289 | type=19, main=10094, sub=0, final=0, amount=1, query=0 | 11268 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 280 | 0 | rwmc10095; strong=0; visible=1 | 270 | 290 | type=19, main=10095, sub=0, final=0, amount=1, query=0 | 11269 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 281 | 0 | rwmc10096; strong=0; visible=1 | 271 | 291 | type=19, main=10096, sub=0, final=0, amount=1, query=0 | 11270 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 282 | 0 | rwmc10097; strong=0; visible=1 | 272 | 292 | type=19, main=10097, sub=0, final=0, amount=1, query=0 | 11271 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 283 | 0 | rwmc10098; strong=0; visible=1 | 273 | 293 | type=19, main=10098, sub=0, final=0, amount=1, query=0 | 11272 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 284 | 0 | rwmc10099; strong=0; visible=1 | 274 | 294 | type=19, main=10099, sub=0, final=0, amount=1, query=0 | 11273 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 285 | 0 | rwmc10100; strong=0; visible=1 | 275 | 295 | type=19, main=10100, sub=0, final=0, amount=1, query=0 | 11274 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 286 | 0 | rwmc10101; strong=0; visible=1 | 276 | 296 | type=19, main=10101, sub=0, final=0, amount=1, query=0 | 11275 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 287 | 0 | rwmc10102; strong=0; visible=1 | 277 | 297 | type=19, main=10102, sub=0, final=0, amount=1, query=0 | 11276 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 288 | 0 | rwmc20093; strong=0; visible=1 | 278 | — | type=19, main=20093, sub=0, final=0, amount=1, query=0 | 11277 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 289 | 0 | rwmc20094; strong=0; visible=1 | 279 | — | type=19, main=20094, sub=0, final=0, amount=1, query=0 | 11278 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 290 | 0 | rwmc20095; strong=0; visible=1 | 280 | — | type=19, main=20095, sub=0, final=0, amount=1, query=0 | 11279 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 291 | 0 | rwmc20096; strong=0; visible=1 | 281 | — | type=19, main=20096, sub=0, final=0, amount=1, query=0 | 11280 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 292 | 0 | rwmc20097; strong=0; visible=1 | 282 | — | type=19, main=20097, sub=0, final=0, amount=1, query=0 | 11281 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 293 | 0 | rwmc20098; strong=0; visible=1 | 283 | — | type=19, main=20098, sub=0, final=0, amount=1, query=0 | 11282 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 294 | 0 | rwmc20099; strong=0; visible=1 | 284 | — | type=19, main=20099, sub=0, final=0, amount=1, query=0 | 11283 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 295 | 0 | rwmc20100; strong=0; visible=1 | 285 | — | type=19, main=20100, sub=0, final=0, amount=1, query=0 | 11284 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 296 | 0 | rwmc20101; strong=0; visible=1 | 286 | — | type=19, main=20101, sub=0, final=0, amount=1, query=0 | 11285 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 297 | 0 | rwmc20102; strong=0; visible=1 | 287 | — | type=19, main=20102, sub=0, final=0, amount=1, query=0 | 11286 / 2000 / 380 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1001 | 2 | rwmc1001; strong=0; visible=1 | — | — | type=3, main=0, sub=0, final=0, amount=5, query=0 | 8001 / 0 / 400 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1002 | 2 | rwmc1002; strong=0; visible=1 | — | — | type=4, main=0, sub=0, final=0, amount=3, query=0 | 8002 / 800 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1003 | 2 | rwmc1003; strong=0; visible=1 | — | — | type=5, main=0, sub=0, final=0, amount=1, query=0 | 8003 / 700 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1004 | 2 | rwmc1004; strong=0; visible=1 | — | — | type=7, main=0, sub=0, final=0, amount=5, query=0 | 8004 / 0 / 400 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1005 | 2 | rwmc1005; strong=0; visible=1 | — | — | type=8, main=0, sub=0, final=0, amount=1, query=0 | 8005 / 1000 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1006 | 2 | rwmc1006; strong=0; visible=1 | — | — | type=9, main=0, sub=0, final=0, amount=3, query=0 | 8006 / 0 / 400 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1008 | 2 | rwmc1008; strong=0; visible=1 | — | — | type=13, main=0, sub=0, final=0, amount=5, query=0 | 8008 / 500 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1009 | 2 | rwmc1009; strong=0; visible=1 | — | — | type=6, main=0, sub=0, final=0, amount=2, query=0 | 8009 / 500 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1010 | 2 | rwmc1010; strong=0; visible=1 | — | — | type=26, main=0, sub=0, final=0, amount=1, query=0 | 8010 / 700 / 0 / 20 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1011 | 2 | rwmc1011; strong=0; visible=1 | — | — | type=17, main=0, sub=0, final=0, amount=1, query=0 | 8011 / 0 / 400 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1015 | 2 | rwmc1015; strong=0; visible=1 | — | — | type=27, main=0, sub=0, final=0, amount=1, query=0 | 8015 / 600 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1016 | 2 | rwmc1016; strong=0; visible=1 | — | — | type=34, main=0, sub=0, final=0, amount=1, query=0 | 8016 / 0 / 350 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1017 | 2 | rwmc1017; strong=0; visible=1 | — | — | type=39, main=0, sub=0, final=0, amount=1, query=0 | 8017 / 0 / 400 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1018 | 2 | rwmc1018; strong=0; visible=1 | — | — | type=36, main=0, sub=0, final=0, amount=3, query=0 | 8018 / 600 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1019 | 2 | rwmc1019; strong=0; visible=1 | — | — | type=40, main=7, sub=0, final=0, amount=1, query=0 | 8019 / 400 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1021 | 2 | rwmc1021; strong=0; visible=1 | — | — | type=11, main=0, sub=0, final=0, amount=1, query=0 | 8021 / 0 / 50 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1022 | 2 | rwmc1022; strong=0; visible=1 | — | — | type=42, main=0, sub=0, final=0, amount=2, query=0 | 8022 / 1200 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1023 | 2 | rwmc1023; strong=0; visible=1 | — | — | type=44, main=0, sub=0, final=0, amount=1, query=0 | 8023 / 1000 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1501 | 0 | rwmc1501; strong=0; visible=1 | — | — | type=18, main=1, sub=11, final=1003, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1502 | 0 | rwmc1502; strong=0; visible=1 | — | — | type=18, main=1, sub=53, final=1006, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1503 | 0 | rwmc1503; strong=0; visible=1 | — | — | type=18, main=1, sub=45, final=1014, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1504 | 0 | rwmc1504; strong=0; visible=1 | — | — | type=18, main=2, sub=36, final=1021, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1505 | 0 | rwmc1505; strong=0; visible=1 | — | — | type=18, main=3, sub=4, final=1030, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1506 | 0 | rwmc1506; strong=0; visible=1 | — | — | type=18, main=3, sub=63, final=1044, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1507 | 0 | rwmc1507; strong=0; visible=1 | — | — | type=18, main=4, sub=46, final=1059, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1508 | 0 | rwmc1508; strong=0; visible=1 | — | — | type=19, main=10007, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1509 | 0 | rwmc1509; strong=0; visible=1 | — | — | type=19, main=20010, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1510 | 0 | rwmc1510; strong=0; visible=1 | — | — | type=19, main=10015, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1511 | 0 | rwmc1511; strong=0; visible=1 | — | — | type=19, main=20019, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1512 | 0 | rwmc1512; strong=0; visible=1 | — | — | type=19, main=20024, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1513 | 0 | rwmc1513; strong=0; visible=1 | — | — | type=42, main=0, sub=0, final=0, amount=3, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1514 | 0 | rwmc1514; strong=0; visible=1 | — | — | type=42, main=0, sub=0, final=0, amount=10, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1515 | 0 | rwmc1515; strong=0; visible=1 | — | — | type=42, main=0, sub=0, final=0, amount=20, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1516 | 0 | rwmc1516; strong=0; visible=1 | — | — | type=42, main=0, sub=1, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1517 | 0 | rwmc1517; strong=0; visible=1 | — | — | type=42, main=1, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1518 | 0 | rwmc1518; strong=0; visible=1 | — | — | type=42, main=2, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1519 | 0 | rwmc1519; strong=0; visible=1 | — | — | type=42, main=3, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1520 | 0 | rwmc1520; strong=0; visible=1 | — | — | type=42, main=4, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1521 | 0 | rwmc1521; strong=0; visible=1 | — | — | type=20, main=0, sub=0, final=0, amount=5, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1522 | 0 | rwmc1522; strong=0; visible=1 | — | — | type=20, main=0, sub=0, final=0, amount=10, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1523 | 0 | rwmc1523; strong=0; visible=1 | — | — | type=20, main=0, sub=0, final=0, amount=15, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1524 | 0 | rwmc1524; strong=0; visible=1 | — | — | type=20, main=0, sub=0, final=0, amount=20, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1525 | 0 | rwmc1525; strong=0; visible=1 | — | — | type=20, main=0, sub=0, final=0, amount=25, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1526 | 0 | rwmc1526; strong=0; visible=1 | — | — | type=20, main=0, sub=0, final=0, amount=30, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1527 | 0 | rwmc1527; strong=0; visible=1 | — | — | type=20, main=0, sub=0, final=0, amount=40, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 1528 | 0 | rwmc1528; strong=0; visible=1 | — | — | type=20, main=0, sub=0, final=0, amount=50, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 2002 | 0 | rwmc2003; strong=1; visible=0 | — | — | type=18, main=1, sub=11, final=1003, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 2004 | 0 | rwmc2005; strong=0; visible=0 | 20001 | 2005, 10055, 10025, 10026, 10027, 10060, 10061, 10062 | type=18, main=1, sub=18, final=1004, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=9 | Config parsed; runtime status not inferred |
| 2005 | 0 | rwmc2006; strong=0; visible=0 | 2004 | 20002 | type=18, main=1, sub=19, final=1005, amount=1, query=0 | 11002 / 0 / 0 / 0 | NPC fields in objective; unlock_map=10 | Config parsed; runtime status not inferred |
| 2006 | 0 | rwmc2007; strong=0; visible=0 | 20002 | 2007 | type=18, main=1, sub=53, final=1006, amount=1, query=0 | 11001 / 0 / 0 / 0 | NPC fields in objective; unlock_map=12 | Config parsed; runtime status not inferred |
| 2007 | 0 | rwmc2008; strong=0; visible=0 | 2006 | 20003 | type=18, main=1, sub=23, final=1007, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=13 | Config parsed; runtime status not inferred |
| 2008 | 0 | rwmc2009; strong=0; visible=0 | 20003 | 30005, 2009 | type=18, main=1, sub=26, final=1008, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=15 | Config parsed; runtime status not inferred |
| 2009 | 0 | rwmc2010; strong=0; visible=0 | 2008 | 10066, 20004 | type=18, main=1, sub=28, final=1009, amount=1, query=0 | 11003 / 0 / 0 / 0 | NPC fields in objective; unlock_map=16 | Config parsed; runtime status not inferred |
| 2010 | 0 | rwmc2011; strong=0; visible=0 | 20004 | 20005, 10051, 10028, 10029, 10030, 10063, 10064, 10065 | type=18, main=1, sub=32, final=1010, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=18 | Config parsed; runtime status not inferred |
| 2011 | 0 | rwmc2012; strong=0; visible=0 | 20005 | 2012 | type=18, main=1, sub=54, final=1011, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=20 | Config parsed; runtime status not inferred |
| 2012 | 0 | rwmc2013; strong=0; visible=0 | 2011 | 2013 | type=18, main=1, sub=39, final=1012, amount=1, query=0 | 11004 / 0 / 0 / 0 | NPC fields in objective; unlock_map=21 | Config parsed; runtime status not inferred |
| 2013 | 0 | rwmc2014; strong=0; visible=0 | 2013 | 20006 | type=18, main=1, sub=41, final=1013, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=22 | Config parsed; runtime status not inferred |
| 2014 | 0 | rwmc2015; strong=0; visible=0 | 20006 | 2015 | type=18, main=1, sub=45, final=1014, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=24 | Config parsed; runtime status not inferred |
| 2015 | 0 | rwmc2016; strong=0; visible=0 | 2014 | 20007, 10067 | type=18, main=1, sub=47, final=1015, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=25 | Config parsed; runtime status not inferred |
| 2016 | 0 | rwmc2017; strong=0; visible=0 | 20008 | 20021 | type=18, main=2, sub=3, final=1016, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=28 | Config parsed; runtime status not inferred |
| 2017 | 0 | rwmc2018; strong=0; visible=0 | 20021 | 20022 | type=18, main=2, sub=9, final=1017, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=30 | Config parsed; runtime status not inferred |
| 2018 | 0 | rwmc2019; strong=0; visible=0 | 20022 | 30015, 20023 | type=18, main=2, sub=16, final=1018, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=32 | Config parsed; runtime status not inferred |
| 2019 | 0 | rwmc2020; strong=0; visible=0 | 20023 | 2020 | type=18, main=2, sub=23, final=1019, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=34 | Config parsed; runtime status not inferred |
| 2020 | 0 | rwmc2021; strong=0; visible=0 | 2019 | 20024 | type=18, main=2, sub=28, final=1020, amount=1, query=0 | 11022 / 0 / 0 / 0 | NPC fields in objective; unlock_map=35 | Config parsed; runtime status not inferred |
| 2021 | 0 | rwmc2022; strong=0; visible=0 | 20024 | 2022, 2023, 20025 | type=18, main=2, sub=36, final=1021, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=37 | Config parsed; runtime status not inferred |
| 2022 | 0 | rwmc2023; strong=0; visible=0 | 2021 | 30014 | type=18, main=2, sub=39, final=1022, amount=1, query=0 | 11023 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 2023 | 0 | rwmc2024; strong=0; visible=0 | 2021 | 30016, 20026 | type=18, main=2, sub=45, final=1023, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=40 | Config parsed; runtime status not inferred |
| 2024 | 0 | rwmc2025; strong=0; visible=0 | 20026 | 2025 | type=18, main=2, sub=51, final=1024, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=42 | Config parsed; runtime status not inferred |
| 2025 | 0 | rwmc2026; strong=0; visible=0 | 2024 | 20027 | type=18, main=2, sub=53, final=1025, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=43 | Config parsed; runtime status not inferred |
| 2026 | 0 | rwmc2027; strong=0; visible=0 | 20027 | 2027 | type=18, main=2, sub=59, final=1026, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=45 | Config parsed; runtime status not inferred |
| 2027 | 0 | rwmc2028; strong=0; visible=0 | 2026 | 30017, 2028 | type=18, main=2, sub=62, final=1027, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=46 | Config parsed; runtime status not inferred |
| 2028 | 0 | rwmc2029; strong=0; visible=0 | 2027 | 20028 | type=18, main=2, sub=69, final=1028, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=47 | Config parsed; runtime status not inferred |
| 2029 | 0 | rwmc2030; strong=0; visible=0 | 20028 | 30018, 20029 | type=18, main=2, sub=79, final=1029, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=49 | Config parsed; runtime status not inferred |
| 2030 | 0 | rwmc2031; strong=0; visible=0 | 20029 | 20030 | type=18, main=3, sub=4, final=1030, amount=1, query=0 | 11027 / 0 / 0 / 0 | NPC fields in objective; unlock_map=51 | Config parsed; runtime status not inferred |
| 2031 | 0 | rwmc2032; strong=0; visible=0 | 20030 | 2032 | type=18, main=3, sub=8, final=1031, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=53 | Config parsed; runtime status not inferred |
| 2032 | 0 | rwmc2033; strong=0; visible=0 | 2031 | 20031 | type=18, main=3, sub=11, final=1032, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=54 | Config parsed; runtime status not inferred |
| 2033 | 0 | rwmc2034; strong=0; visible=0 | 20031 | 2034 | type=18, main=3, sub=14, final=1033, amount=1, query=0 | 11028 / 0 / 0 / 0 | NPC fields in objective; unlock_map=56 | Config parsed; runtime status not inferred |
| 2034 | 0 | rwmc2035; strong=0; visible=0 | 2033 | 30021, 20032 | type=18, main=3, sub=15, final=1034, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=57 | Config parsed; runtime status not inferred |
| 2035 | 0 | rwmc2036; strong=0; visible=0 | 20032 | 2036 | type=18, main=3, sub=19, final=1035, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=59 | Config parsed; runtime status not inferred |
| 2036 | 0 | rwmc2037; strong=0; visible=0 | 2035 | 20033 | type=18, main=3, sub=21, final=1036, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=60 | Config parsed; runtime status not inferred |
| 2037 | 0 | rwmc2038; strong=0; visible=0 | 20033 | 30022, 20034 | type=18, main=3, sub=30, final=1037, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=62 | Config parsed; runtime status not inferred |
| 2038 | 0 | rwmc2039; strong=0; visible=0 | 20034 | 2039 | type=18, main=3, sub=35, final=1038, amount=1, query=0 | 11029 / 0 / 0 / 0 | NPC fields in objective; unlock_map=64 | Config parsed; runtime status not inferred |
| 2039 | 0 | rwmc2040; strong=0; visible=0 | 2038 | 20035 | type=18, main=3, sub=38, final=1039, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=65 | Config parsed; runtime status not inferred |
| 2040 | 0 | rwmc2041; strong=0; visible=0 | 20035 | 2041 | type=18, main=3, sub=46, final=1040, amount=1, query=0 | 11030 / 0 / 0 / 0 | NPC fields in objective; unlock_map=67 | Config parsed; runtime status not inferred |
| 2041 | 0 | rwmc2042; strong=0; visible=0 | 2040 | 30023, 2042 | type=18, main=3, sub=48, final=1041, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=68 | Config parsed; runtime status not inferred |
| 2042 | 0 | rwmc2043; strong=0; visible=0 | 2042 | 20036 | type=18, main=3, sub=51, final=1042, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=69 | Config parsed; runtime status not inferred |
| 2043 | 0 | rwmc2044; strong=0; visible=0 | 20036 | 20037 | type=18, main=3, sub=57, final=1043, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=71 | Config parsed; runtime status not inferred |
| 2044 | 0 | rwmc2045; strong=0; visible=0 | 20037 | 2045 | type=18, main=3, sub=63, final=1044, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=73 | Config parsed; runtime status not inferred |
| 2045 | 0 | rwmc2046; strong=0; visible=0 | 2044 | 20038 | type=18, main=3, sub=66, final=1045, amount=1, query=0 | 11031 / 0 / 0 / 0 | NPC fields in objective; unlock_map=74 | Config parsed; runtime status not inferred |
| 2046 | 0 | rwmc2047; strong=0; visible=0 | 20038 | 2047 | type=18, main=3, sub=75, final=1046, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=76 | Config parsed; runtime status not inferred |
| 2047 | 0 | rwmc2048; strong=0; visible=0 | 2046 | 30025, 2048 | type=18, main=3, sub=78, final=1047, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=77 | Config parsed; runtime status not inferred |
| 2048 | 0 | rwmc2049; strong=0; visible=0 | 2047 | 20039 | type=18, main=3, sub=80, final=1048, amount=1, query=0 | 11032 / 0 / 0 / 0 | NPC fields in objective; unlock_map=78 | Config parsed; runtime status not inferred |
| 2049 | 0 | rwmc2050; strong=0; visible=0 | 20039 | 20040 | type=18, main=4, sub=4, final=1049, amount=1, query=0 | 11033 / 0 / 0 / 0 | NPC fields in objective; unlock_map=80 | Config parsed; runtime status not inferred |
| 2050 | 0 | rwmc2051; strong=0; visible=0 | 20040 | 2051 | type=18, main=4, sub=8, final=1050, amount=1, query=0 | 11034 / 0 / 0 / 0 | NPC fields in objective; unlock_map=82 | Config parsed; runtime status not inferred |
| 2051 | 0 | rwmc2052; strong=0; visible=0 | 2050 | 30027, 2052 | type=18, main=4, sub=9, final=1051, amount=1, query=0 | 11035 / 0 / 0 / 0 | NPC fields in objective; unlock_map=83 | Config parsed; runtime status not inferred |
| 2052 | 0 | rwmc2053; strong=0; visible=0 | 2051 | 20041 | type=18, main=4, sub=11, final=1052, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=84 | Config parsed; runtime status not inferred |
| 2053 | 0 | rwmc2054; strong=0; visible=0 | 20041 | 20042 | type=18, main=4, sub=18, final=1053, amount=1, query=0 | 11036 / 0 / 0 / 0 | NPC fields in objective; unlock_map=86 | Config parsed; runtime status not inferred |
| 2054 | 0 | rwmc2055; strong=0; visible=0 | 20042 | 2055 | type=18, main=4, sub=25, final=1054, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=88 | Config parsed; runtime status not inferred |
| 2055 | 0 | rwmc2056; strong=0; visible=0 | 2054 | 20043 | type=18, main=4, sub=27, final=1055, amount=1, query=0 | 11037 / 0 / 0 / 0 | NPC fields in objective; unlock_map=89 | Config parsed; runtime status not inferred |
| 2056 | 0 | rwmc2057; strong=0; visible=0 | 20043 | 2057 | type=18, main=4, sub=32, final=1056, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=91 | Config parsed; runtime status not inferred |
| 2057 | 0 | rwmc2058; strong=0; visible=0 | 2056 | 20044 | type=18, main=4, sub=35, final=1057, amount=1, query=0 | 11038 / 0 / 0 / 0 | NPC fields in objective; unlock_map=92 | Config parsed; runtime status not inferred |
| 2058 | 0 | rwmc2059; strong=0; visible=0 | 20044 | 2059 | type=18, main=4, sub=42, final=1058, amount=1, query=0 | 11039 / 0 / 0 / 0 | NPC fields in objective; unlock_map=94 | Config parsed; runtime status not inferred |
| 2059 | 0 | rwmc2060; strong=0; visible=0 | 2058 | 2060 | type=18, main=4, sub=46, final=1059, amount=1, query=0 | 11040 / 0 / 0 / 0 | NPC fields in objective; unlock_map=95 | Config parsed; runtime status not inferred |
| 2060 | 0 | rwmc2061; strong=0; visible=0 | 2059 | 30029, 2061 | type=18, main=4, sub=49, final=1060, amount=1, query=0 | 11041 / 0 / 0 / 0 | NPC fields in objective; unlock_map=96 | Config parsed; runtime status not inferred |
| 2061 | 0 | rwmc2062; strong=0; visible=0 | 2060 | 20045 | type=18, main=4, sub=54, final=1061, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=97 | Config parsed; runtime status not inferred |
| 2062 | 0 | rwmc2063; strong=0; visible=0 | 20045 | 2063 | type=18, main=4, sub=63, final=1062, amount=1, query=0 | 11042 / 0 / 0 / 0 | NPC fields in objective; unlock_map=99 | Config parsed; runtime status not inferred |
| 2063 | 0 | rwmc2064; strong=0; visible=0 | 2062 | 2064 | type=18, main=4, sub=67, final=1063, amount=1, query=0 | 11043 / 0 / 0 / 0 | NPC fields in objective; unlock_map=100 | Config parsed; runtime status not inferred |
| 2064 | 0 | rwmc2065; strong=0; visible=0 | 2063 | 20046 | type=18, main=4, sub=70, final=1064, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=101 | Config parsed; runtime status not inferred |
| 2065 | 0 | rwmc2066; strong=0; visible=0 | 20046 | 2066 | type=18, main=4, sub=78, final=1065, amount=1, query=0 | 11044 / 0 / 0 / 0 | NPC fields in objective; unlock_map=103 | Config parsed; runtime status not inferred |
| 2066 | 0 | rwmc2067; strong=0; visible=0 | 2065 | 2067 | type=18, main=4, sub=82, final=1066, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=104 | Config parsed; runtime status not inferred |
| 2067 | 0 | rwmc2068; strong=0; visible=0 | 2066 | 20047 | type=18, main=4, sub=85, final=1067, amount=1, query=0 | 11045 / 0 / 0 / 0 | NPC fields in objective; unlock_map=105 | Config parsed; runtime status not inferred |
| 2068 | 0 | rwmc2069; strong=0; visible=0 | 20047 | 20048 | type=18, main=4, sub=91, final=1068, amount=1, query=0 | 11046 / 0 / 0 / 0 | NPC fields in objective; unlock_map=107 | Config parsed; runtime status not inferred |
| 2069 | 0 | rwmc2070; strong=0; visible=0 | 20048 | 2070 | type=18, main=4, sub=99, final=1069, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=109 | Config parsed; runtime status not inferred |
| 2070 | 0 | rwmc2071; strong=0; visible=0 | 2069 | 2071 | type=18, main=4, sub=103, final=1070, amount=1, query=0 | 11047 / 0 / 0 / 0 | NPC fields in objective; unlock_map=110 | Config parsed; runtime status not inferred |
| 2071 | 0 | rwmc2072; strong=0; visible=0 | 2070 | 20049 | type=18, main=4, sub=106, final=1071, amount=1, query=0 | 11048 / 0 / 0 / 0 | NPC fields in objective; unlock_map=111 | Config parsed; runtime status not inferred |
| 2072 | 0 | rwmc2073; strong=0; visible=0 | 20049 | 20050 | type=18, main=5, sub=3, final=1072, amount=1, query=0 | 11113 / 0 / 0 / 0 | NPC fields in objective; unlock_map=113 | Config parsed; runtime status not inferred |
| 2073 | 0 | rwmc2074; strong=0; visible=0 | 20050 | 2074 | type=18, main=5, sub=10, final=1073, amount=1, query=0 | 11114 / 0 / 0 / 0 | NPC fields in objective; unlock_map=115 | Config parsed; runtime status not inferred |
| 2074 | 0 | rwmc2075; strong=0; visible=0 | 2074 | 20051 | type=18, main=5, sub=14, final=1074, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=116 | Config parsed; runtime status not inferred |
| 2075 | 0 | rwmc2076; strong=0; visible=0 | 20051 | 2076 | type=18, main=5, sub=20, final=1075, amount=1, query=0 | 11115 / 0 / 0 / 0 | NPC fields in objective; unlock_map=118 | Config parsed; runtime status not inferred |
| 2076 | 0 | rwmc2077; strong=0; visible=0 | 2075 | 30032, 2077, 20057 | type=18, main=5, sub=22, final=1076, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=119 | Config parsed; runtime status not inferred |
| 2077 | 0 | rwmc2078; strong=0; visible=0 | 2076 | 20052 | type=18, main=5, sub=29, final=1077, amount=1, query=0 | 11116 / 0 / 0 / 0 | NPC fields in objective; unlock_map=120 | Config parsed; runtime status not inferred |
| 2078 | 0 | rwmc2079; strong=0; visible=0 | 20052 | 2079 | type=18, main=5, sub=35, final=1078, amount=1, query=0 | 11117 / 0 / 0 / 0 | NPC fields in objective; unlock_map=122 | Config parsed; runtime status not inferred |
| 2079 | 0 | rwmc2080; strong=0; visible=0 | 2078 | 20053 | type=18, main=5, sub=37, final=1079, amount=1, query=0 | 11118 / 0 / 0 / 0 | NPC fields in objective; unlock_map=123 | Config parsed; runtime status not inferred |
| 2080 | 0 | rwmc2081; strong=0; visible=0 | 20053 | 30035, 2081, 20058 | type=18, main=5, sub=43, final=1080, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=125 | Config parsed; runtime status not inferred |
| 2081 | 0 | rwmc2082; strong=0; visible=0 | 2080 | 20054 | type=18, main=5, sub=49, final=1081, amount=1, query=0 | 11119 / 0 / 0 / 0 | NPC fields in objective; unlock_map=126 | Config parsed; runtime status not inferred |
| 2082 | 0 | rwmc2083; strong=0; visible=0 | 20054 | 2083 | type=18, main=5, sub=56, final=1082, amount=1, query=0 | 11120 / 0 / 0 / 0 | NPC fields in objective; unlock_map=128 | Config parsed; runtime status not inferred |
| 2083 | 0 | rwmc2084; strong=0; visible=0 | 2082 | 20055 | type=18, main=5, sub=61, final=1083, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=129 | Config parsed; runtime status not inferred |
| 2084 | 0 | rwmc2085; strong=0; visible=0 | 20055 | 2085 | type=18, main=5, sub=68, final=1084, amount=1, query=0 | 11121 / 0 / 0 / 0 | NPC fields in objective; unlock_map=131 | Config parsed; runtime status not inferred |
| 2085 | 0 | rwmc2086; strong=0; visible=0 | 2084 | 2086 | type=18, main=5, sub=72, final=1085, amount=1, query=0 | 11122 / 0 / 0 / 0 | NPC fields in objective; unlock_map=132 | Config parsed; runtime status not inferred |
| 2086 | 0 | rwmc2087; strong=0; visible=0 | 2085 | 20056 | type=18, main=5, sub=75, final=1086, amount=1, query=0 | 11123 / 0 / 0 / 0 | NPC fields in objective; unlock_map=133 | Config parsed; runtime status not inferred |
| 2087 | 0 | rwmc2088; strong=0; visible=0 | 20056 | — | type=18, main=5, sub=78, final=1087, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 2088 | 0 | rwmc2089; strong=0; visible=0 | 20056 | 2089 | type=18, main=5, sub=89, final=1088, amount=1, query=0 | 11124 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 2089 | 0 | rwmc2090; strong=0; visible=0 | 2088 | — | type=18, main=5, sub=91, final=1089, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 2090 | 0 | rwmc2091; strong=0; visible=0 | 20058 | 20059 | type=18, main=6, sub=4, final=1090, amount=1, query=0 | 11192 / 0 / 0 / 0 | NPC fields in objective; unlock_map=135 | Config parsed; runtime status not inferred |
| 2091 | 0 | rwmc2092; strong=0; visible=0 | 20059 | 20060 | type=18, main=6, sub=16, final=1091, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=137 | Config parsed; runtime status not inferred |
| 2092 | 0 | rwmc2093; strong=0; visible=0 | 20060 | 20061 | type=18, main=6, sub=25, final=1092, amount=1, query=0 | 11192 / 0 / 0 / 0 | NPC fields in objective; unlock_map=138 | Config parsed; runtime status not inferred |
| 2093 | 0 | rwmc2094; strong=0; visible=0 | 20061 | 30040, 2094 | type=18, main=6, sub=32, final=1093, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=140 | Config parsed; runtime status not inferred |
| 2094 | 0 | rwmc2095; strong=0; visible=0 | 2093 | 2095 | type=18, main=6, sub=39, final=1094, amount=1, query=0 | 11192 / 0 / 0 / 0 | NPC fields in objective; unlock_map=141 | Config parsed; runtime status not inferred |
| 2095 | 0 | rwmc2096; strong=0; visible=0 | 2094 | 20062 | type=18, main=6, sub=43, final=1095, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=142 | Config parsed; runtime status not inferred |
| 2096 | 0 | rwmc2097; strong=0; visible=0 | 20062 | 2097 | type=18, main=6, sub=51, final=1096, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=144 | Config parsed; runtime status not inferred |
| 2097 | 0 | rwmc2098; strong=0; visible=0 | 2096 | 20063 | type=18, main=6, sub=53, final=1097, amount=1, query=0 | 11192 / 0 / 0 / 0 | NPC fields in objective; unlock_map=145 | Config parsed; runtime status not inferred |
| 2098 | 0 | rwmc2099; strong=0; visible=0 | 20063 | 20064 | type=18, main=6, sub=61, final=1098, amount=1, query=0 | 11192 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 2099 | 0 | rwmc2100; strong=0; visible=0 | 20064 | 2100 | type=18, main=6, sub=67, final=1099, amount=1, query=0 | 11192 / 0 / 0 / 0 | NPC fields in objective; unlock_map=147 | Config parsed; runtime status not inferred |
| 2100 | 0 | rwmc2101; strong=0; visible=0 | 2099 | 20065 | type=18, main=6, sub=73, final=1100, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=148 | Config parsed; runtime status not inferred |
| 2101 | 0 | rwmc2102; strong=0; visible=0 | 20065 | 2102 | type=18, main=6, sub=81, final=1101, amount=1, query=0 | 11192 / 0 / 0 / 0 | NPC fields in objective; unlock_map=150 | Config parsed; runtime status not inferred |
| 2102 | 0 | rwmc2103; strong=0; visible=0 | 2101 | 20066 | type=18, main=6, sub=84, final=1102, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=151 | Config parsed; runtime status not inferred |
| 2103 | 0 | rwmc2104; strong=0; visible=0 | 20066 | 30043, 20067 | type=18, main=6, sub=92, final=1103, amount=1, query=0 | 11192 / 0 / 0 / 0 | NPC fields in objective; unlock_map=153 | Config parsed; runtime status not inferred |
| 2104 | 0 | rwmc2105; strong=0; visible=0 | 20067 | 20068 | type=18, main=6, sub=101, final=1104, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=155 | Config parsed; runtime status not inferred |
| 2106 | 0 | rwmc2107; strong=0; visible=0 | 20068 | 20069 | type=18, main=6, sub=115, final=1106, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=158 | Config parsed; runtime status not inferred |
| 2107 | 0 | rwmc2108; strong=0; visible=0 | 20069 | 30046, 2108 | type=18, main=6, sub=122, final=1107, amount=1, query=0 | 11192 / 0 / 0 / 0 | NPC fields in objective; unlock_map=160 | Config parsed; runtime status not inferred |
| 2108 | 0 | rwmc2109; strong=0; visible=0 | 2107 | 2109 | type=18, main=6, sub=128, final=1108, amount=1, query=0 | 11192 / 0 / 0 / 0 | NPC fields in objective; unlock_map=161 | Config parsed; runtime status not inferred |
| 2109 | 0 | rwmc2110; strong=0; visible=0 | 2108 | 20070 | type=18, main=7, sub=6, final=1109, amount=1, query=0 | 11193 / 0 / 0 / 0 | NPC fields in objective; unlock_map=162 | Config parsed; runtime status not inferred |
| 2110 | 0 | rwmc2111; strong=0; visible=0 | 20070 | — | type=18, main=7, sub=13, final=1110, amount=1, query=0 | 11193 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 2111 | 0 | rwmc2112; strong=0; visible=0 | 20070 | 20072 | type=18, main=7, sub=18, final=1111, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=164 | Config parsed; runtime status not inferred |
| 2112 | 0 | rwmc2113; strong=0; visible=0 | 20072 | 2113 | type=18, main=7, sub=28, final=1112, amount=1, query=0 | 11193 / 0 / 0 / 0 | NPC fields in objective; unlock_map=166 | Config parsed; runtime status not inferred |
| 2113 | 0 | rwmc2114; strong=0; visible=0 | 2112 | 2114 | type=18, main=7, sub=34, final=1113, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=167 | Config parsed; runtime status not inferred |
| 2114 | 0 | rwmc2115; strong=0; visible=0 | 2113 | 20073 | type=18, main=7, sub=38, final=1114, amount=1, query=0 | 11193 / 0 / 0 / 0 | NPC fields in objective; unlock_map=168 | Config parsed; runtime status not inferred |
| 2115 | 0 | rwmc2116; strong=0; visible=0 | 20073 | 2116 | type=18, main=7, sub=45, final=1115, amount=1, query=0 | 11193 / 0 / 0 / 0 | NPC fields in objective; unlock_map=170 | Config parsed; runtime status not inferred |
| 2116 | 0 | rwmc2117; strong=0; visible=0 | 2115 | 2117 | type=18, main=7, sub=50, final=1116, amount=1, query=0 | 11193 / 0 / 0 / 0 | NPC fields in objective; unlock_map=171 | Config parsed; runtime status not inferred |
| 2117 | 0 | rwmc2118; strong=0; visible=0 | 2116 | 20074 | type=18, main=7, sub=55, final=1117, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=172 | Config parsed; runtime status not inferred |
| 2119 | 0 | rwmc2119; strong=0; visible=0 | 20075 | — | type=18, main=7, sub=64, final=1118, amount=1, query=0 | 11193 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 2120 | 0 | rwmc2120; strong=0; visible=0 | 20075 | — | type=18, main=7, sub=67, final=1119, amount=1, query=0 | 11193 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 2121 | 0 | rwmc2121; strong=0; visible=0 | 20075 | 2122 | type=18, main=7, sub=72, final=1120, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=176 | Config parsed; runtime status not inferred |
| 2122 | 0 | rwmc2122; strong=0; visible=0 | 2121 | 2123 | type=18, main=7, sub=76, final=1121, amount=1, query=0 | 11193 / 0 / 0 / 0 | NPC fields in objective; unlock_map=177 | Config parsed; runtime status not inferred |
| 2123 | 0 | rwmc2123; strong=0; visible=0 | 2122 | 20077 | type=18, main=7, sub=79, final=1122, amount=1, query=0 | 11193 / 0 / 0 / 0 | NPC fields in objective; unlock_map=178 | Config parsed; runtime status not inferred |
| 2124 | 0 | rwmc2124; strong=0; visible=0 | 20077 | 2125 | type=18, main=7, sub=88, final=1123, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=180 | Config parsed; runtime status not inferred |
| 2125 | 0 | rwmc2125; strong=0; visible=0 | 2124 | 20078 | type=18, main=7, sub=91, final=1124, amount=1, query=0 | 11193 / 0 / 0 / 0 | NPC fields in objective; unlock_map=181 | Config parsed; runtime status not inferred |
| 2126 | 0 | rwmc2126; strong=0; visible=0 | 20078 | 2127 | type=18, main=7, sub=95, final=1125, amount=1, query=0 | 11193 / 0 / 0 / 0 | NPC fields in objective; unlock_map=183 | Config parsed; runtime status not inferred |
| 2127 | 0 | rwmc2127; strong=0; visible=0 | 2126 | 2128 | type=18, main=7, sub=96, final=1126, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=184 | Config parsed; runtime status not inferred |
| 2128 | 0 | rwmc2128; strong=0; visible=0 | 2127 | 20079 | type=18, main=7, sub=97, final=1127, amount=1, query=0 | 11193 / 0 / 0 / 0 | NPC fields in objective; unlock_map=185 | Config parsed; runtime status not inferred |
| 2129 | 0 | rwmc2129; strong=0; visible=0 | 20079 | 20080 | type=18, main=8, sub=6, final=1128, amount=1, query=0 | 11225 / 0 / 0 / 0 | NPC fields in objective; unlock_map=187 | Config parsed; runtime status not inferred |
| 2130 | 0 | rwmc2130; strong=0; visible=0 | 20080 | — | type=18, main=8, sub=15, final=1129, amount=1, query=0 | 11225 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 2131 | 0 | rwmc2131; strong=0; visible=0 | 20080 | 2132 | type=18, main=8, sub=22, final=1130, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=189 | Config parsed; runtime status not inferred |
| 2132 | 0 | rwmc2132; strong=0; visible=0 | 2131 | 20082 | type=18, main=8, sub=24, final=1131, amount=1, query=0 | 11225 / 0 / 0 / 0 | NPC fields in objective; unlock_map=190 | Config parsed; runtime status not inferred |
| 2133 | 0 | rwmc2133; strong=0; visible=0 | 20082 | 2134 | type=18, main=8, sub=32, final=1132, amount=1, query=0 | 11225 / 0 / 0 / 0 | NPC fields in objective; unlock_map=192 | Config parsed; runtime status not inferred |
| 2134 | 0 | rwmc2134; strong=0; visible=0 | 2133 | 20083 | type=18, main=8, sub=35, final=1133, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=193 | Config parsed; runtime status not inferred |
| 2135 | 0 | rwmc2135; strong=0; visible=0 | 20083 | 2136 | type=18, main=8, sub=41, final=1134, amount=1, query=0 | 11225 / 0 / 0 / 0 | NPC fields in objective; unlock_map=195 | Config parsed; runtime status not inferred |
| 2136 | 0 | rwmc2136; strong=0; visible=0 | 2135 | 2137 | type=18, main=8, sub=44, final=1135, amount=1, query=0 | 11225 / 0 / 0 / 0 | NPC fields in objective; unlock_map=196 | Config parsed; runtime status not inferred |
| 2137 | 0 | rwmc2137; strong=0; visible=0 | 2136 | 20084 | type=18, main=8, sub=49, final=1136, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=197 | Config parsed; runtime status not inferred |
| 2138 | 0 | rwmc2138; strong=0; visible=0 | 20084 | 2139 | type=18, main=8, sub=57, final=1137, amount=1, query=0 | 11225 / 0 / 0 / 0 | NPC fields in objective; unlock_map=199 | Config parsed; runtime status not inferred |
| 2139 | 0 | rwmc2139; strong=0; visible=0 | 2138 | 2140 | type=18, main=8, sub=61, final=1138, amount=1, query=0 | 11225 / 0 / 0 / 0 | NPC fields in objective; unlock_map=200 | Config parsed; runtime status not inferred |
| 2140 | 0 | rwmc2140; strong=0; visible=0 | 2139 | 20085 | type=18, main=8, sub=65, final=1139, amount=1, query=0 | 11225 / 0 / 0 / 0 | NPC fields in objective; unlock_map=201 | Config parsed; runtime status not inferred |
| 2141 | 0 | rwmc2141; strong=0; visible=0 | 20085 | 2142 | type=18, main=8, sub=71, final=1140, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=203 | Config parsed; runtime status not inferred |
| 2142 | 0 | rwmc2142; strong=0; visible=0 | 2141 | 2143, 2144, 20086 | type=18, main=8, sub=73, final=1141, amount=1, query=0 | 11225 / 0 / 0 / 0 | NPC fields in objective; unlock_map=204 | Config parsed; runtime status not inferred |
| 2143 | 0 | rwmc2143; strong=0; visible=0 | 2142 | — | type=18, main=8, sub=76, final=1142, amount=1, query=0 | 11225 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 2144 | 0 | rwmc2144; strong=0; visible=0 | 2142 | 2145 | type=18, main=8, sub=82, final=1143, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=205 | Config parsed; runtime status not inferred |
| 2145 | 0 | rwmc2145; strong=0; visible=0 | 2144 | 20087 | type=18, main=8, sub=88, final=1144, amount=1, query=0 | 11225 / 0 / 0 / 0 | NPC fields in objective; unlock_map=206 | Config parsed; runtime status not inferred |
| 2146 | 0 | rwmc2146; strong=0; visible=0 | 20087 | — | type=18, main=8, sub=95, final=1145, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 2147 | 0 | rwmc2147; strong=0; visible=0 | 20087 | — | type=18, main=8, sub=97, final=1146, amount=1, query=0 | 11225 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 2148 | 0 | rwmc2148; strong=0; visible=0 | 20087 | 2149 | type=18, main=8, sub=104, final=1147, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=208 | Config parsed; runtime status not inferred |
| 2149 | 0 | rwmc2149; strong=0; visible=0 | 2148 | 20089 | type=18, main=8, sub=107, final=1148, amount=1, query=0 | 11225 / 0 / 0 / 0 | NPC fields in objective; unlock_map=209 | Config parsed; runtime status not inferred |
| 2150 | 0 | rwmc2150; strong=0; visible=0 | 20089 | 2151 | type=18, main=8, sub=115, final=1149, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=211 | Config parsed; runtime status not inferred |
| 2151 | 0 | rwmc2151; strong=0; visible=0 | 2150 | 2152 | type=18, main=8, sub=118, final=1150, amount=1, query=0 | 11225 / 0 / 0 / 0 | NPC fields in objective; unlock_map=212 | Config parsed; runtime status not inferred |
| 2152 | 0 | rwmc2152; strong=0; visible=0 | 2151 | 20090 | type=18, main=9, sub=4, final=1151, amount=1, query=0 | 11256 / 0 / 0 / 0 | NPC fields in objective; unlock_map=213 | Config parsed; runtime status not inferred |
| 2153 | 0 | rwmc2153; strong=0; visible=0 | 20090 | 2154 | type=18, main=9, sub=12, final=1152, amount=1, query=0 | 11256 / 0 / 0 / 0 | NPC fields in objective; unlock_map=215 | Config parsed; runtime status not inferred |
| 2154 | 0 | rwmc2154; strong=0; visible=0 | 2153 | 20091 | type=18, main=9, sub=15, final=1153, amount=1, query=0 | 11256 / 0 / 0 / 0 | NPC fields in objective; unlock_map=216 | Config parsed; runtime status not inferred |
| 2155 | 0 | rwmc2155; strong=0; visible=0 | 20091 | 2156 | type=18, main=9, sub=22, final=1154, amount=1, query=0 | 11256 / 0 / 0 / 0 | NPC fields in objective; unlock_map=218 | Config parsed; runtime status not inferred |
| 2156 | 0 | rwmc2156; strong=0; visible=0 | 2155 | 20092 | type=18, main=9, sub=24, final=1155, amount=1, query=0 | 11256 / 0 / 0 / 0 | NPC fields in objective; unlock_map=219 | Config parsed; runtime status not inferred |
| 2157 | 0 | rwmc2157; strong=0; visible=0 | 20092 | — | type=18, main=9, sub=28, final=1156, amount=1, query=0 | 11256 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 2158 | 0 | rwmc2158; strong=0; visible=0 | 20092 | 2159 | type=18, main=9, sub=35, final=1157, amount=1, query=0 | 11256 / 0 / 0 / 0 | NPC fields in objective; unlock_map=221 | Config parsed; runtime status not inferred |
| 2159 | 0 | rwmc2159; strong=0; visible=0 | 2158 | 2160 | type=18, main=9, sub=38, final=1158, amount=1, query=0 | 11256 / 0 / 0 / 0 | NPC fields in objective; unlock_map=222 | Config parsed; runtime status not inferred |
| 2160 | 0 | rwmc2160; strong=0; visible=0 | 2159 | 20094 | type=18, main=9, sub=44, final=1159, amount=1, query=0 | 11256 / 0 / 0 / 0 | NPC fields in objective; unlock_map=223 | Config parsed; runtime status not inferred |
| 2161 | 0 | rwmc2161; strong=0; visible=0 | 20094 | 20095 | type=18, main=9, sub=56, final=1160, amount=1, query=0 | 11256 / 0 / 0 / 0 | NPC fields in objective; unlock_map=225 | Config parsed; runtime status not inferred |
| 2162 | 0 | rwmc2162; strong=0; visible=0 | 20095 | — | type=18, main=9, sub=66, final=1161, amount=1, query=0 | 11256 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 2163 | 0 | rwmc2163; strong=0; visible=0 | 20095 | — | type=18, main=9, sub=70, final=1162, amount=1, query=0 | 11256 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 2164 | 0 | rwmc2164; strong=0; visible=0 | 20095 | — | type=18, main=9, sub=74, final=1163, amount=1, query=0 | 11256 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 2165 | 0 | rwmc2165; strong=0; visible=0 | 20095 | 2166 | type=18, main=9, sub=84, final=1164, amount=1, query=0 | 11256 / 0 / 0 / 0 | NPC fields in objective; unlock_map=227 | Config parsed; runtime status not inferred |
| 2166 | 0 | rwmc2166; strong=0; visible=0 | 2165 | 20097 | type=18, main=9, sub=87, final=1165, amount=1, query=0 | 11256 / 0 / 0 / 0 | NPC fields in objective; unlock_map=228 | Config parsed; runtime status not inferred |
| 2167 | 0 | rwmc2167; strong=0; visible=0 | 20097 | 20098 | type=18, main=9, sub=94, final=1166, amount=1, query=0 | 11256 / 0 / 0 / 0 | NPC fields in objective; unlock_map=230 | Config parsed; runtime status not inferred |
| 2168 | 0 | rwmc2168; strong=0; visible=0 | 20098 | 2169 | type=18, main=9, sub=102, final=1167, amount=1, query=0 | 11256 / 0 / 0 / 0 | NPC fields in objective; unlock_map=232 | Config parsed; runtime status not inferred |
| 2169 | 0 | rwmc2169; strong=0; visible=0 | 2168 | 20099 | type=18, main=9, sub=105, final=1168, amount=1, query=0 | 11256 / 0 / 0 / 0 | NPC fields in objective; unlock_map=233 | Config parsed; runtime status not inferred |
| 2170 | 0 | rwmc2170; strong=0; visible=0 | 20099 | 2171 | type=18, main=9, sub=113, final=1169, amount=1, query=0 | 11256 / 0 / 0 / 0 | NPC fields in objective; unlock_map=235 | Config parsed; runtime status not inferred |
| 2171 | 0 | rwmc2171; strong=0; visible=0 | 2170 | 2172 | type=18, main=9, sub=116, final=1170, amount=1, query=0 | 11256 / 0 / 0 / 0 | NPC fields in objective; unlock_map=236 | Config parsed; runtime status not inferred |
| 2172 | 0 | rwmc2172; strong=0; visible=0 | 2171 | 20100 | type=18, main=10, sub=2, final=1171, amount=1, query=0 | 11287 / 0 / 0 / 0 | NPC fields in objective; unlock_map=237 | Config parsed; runtime status not inferred |
| 2173 | 0 | rwmc2173; strong=0; visible=0 | 20100 | 2174 | type=18, main=10, sub=9, final=1172, amount=1, query=0 | 11287 / 0 / 0 / 0 | NPC fields in objective; unlock_map=239 | Config parsed; runtime status not inferred |
| 2174 | 0 | rwmc2174; strong=0; visible=0 | 2173 | 20101 | type=18, main=10, sub=11, final=1173, amount=1, query=0 | 11287 / 0 / 0 / 0 | NPC fields in objective; unlock_map=240 | Config parsed; runtime status not inferred |
| 2175 | 0 | rwmc2175; strong=0; visible=0 | 20101 | 2176 | type=18, main=10, sub=15, final=1174, amount=1, query=0 | 11287 / 0 / 0 / 0 | NPC fields in objective; unlock_map=242 | Config parsed; runtime status not inferred |
| 2176 | 0 | rwmc2176; strong=0; visible=0 | 2175 | 20102 | type=18, main=10, sub=16, final=1175, amount=1, query=0 | 11287 / 0 / 0 / 0 | NPC fields in objective; unlock_map=243 | Config parsed; runtime status not inferred |
| 2177 | 0 | rwmc2177; strong=0; visible=0 | 20102 | 2178 | type=18, main=10, sub=23, final=1176, amount=1, query=0 | 11287 / 0 / 0 / 0 | NPC fields in objective; unlock_map=245 | Config parsed; runtime status not inferred |
| 2178 | 0 | rwmc2178; strong=0; visible=0 | 2177 | 20103 | type=18, main=10, sub=24, final=1177, amount=1, query=0 | 11287 / 0 / 0 / 0 | NPC fields in objective; unlock_map=246 | Config parsed; runtime status not inferred |
| 2179 | 0 | rwmc2179; strong=0; visible=0 | 20103 | 2180 | type=18, main=10, sub=29, final=1178, amount=1, query=0 | 11287 / 0 / 0 / 0 | NPC fields in objective; unlock_map=248 | Config parsed; runtime status not inferred |
| 2180 | 0 | rwmc2180; strong=0; visible=0 | 2179 | 20104 | type=18, main=10, sub=30, final=1179, amount=1, query=0 | 11287 / 0 / 0 / 0 | NPC fields in objective; unlock_map=249 | Config parsed; runtime status not inferred |
| 2181 | 0 | rwmc2181; strong=0; visible=0 | 20104 | 2182 | type=18, main=10, sub=35, final=1180, amount=1, query=0 | 11287 / 0 / 0 / 0 | NPC fields in objective; unlock_map=251 | Config parsed; runtime status not inferred |
| 2182 | 0 | rwmc2182; strong=0; visible=0 | 2181 | 2183 | type=18, main=10, sub=39, final=1181, amount=1, query=0 | 11287 / 0 / 0 / 0 | NPC fields in objective; unlock_map=252 | Config parsed; runtime status not inferred |
| 2183 | 0 | rwmc2183; strong=0; visible=0 | 2182 | 20105 | type=18, main=10, sub=43, final=1182, amount=1, query=0 | 11287 / 0 / 0 / 0 | NPC fields in objective; unlock_map=253 | Config parsed; runtime status not inferred |
| 2184 | 0 | rwmc2184; strong=0; visible=0 | 20105 | 20106 | type=18, main=10, sub=50, final=1183, amount=1, query=0 | 11287 / 0 / 0 / 0 | NPC fields in objective; unlock_map=255 | Config parsed; runtime status not inferred |
| 2185 | 0 | rwmc2185; strong=0; visible=0 | 20106 | 2186 | type=18, main=10, sub=56, final=1184, amount=1, query=0 | 11287 / 0 / 0 / 0 | NPC fields in objective; unlock_map=257 | Config parsed; runtime status not inferred |
| 2186 | 0 | rwmc2186; strong=0; visible=0 | 2185 | 20107 | type=18, main=10, sub=59, final=1185, amount=1, query=0 | 11287 / 0 / 0 / 0 | NPC fields in objective; unlock_map=258 | Config parsed; runtime status not inferred |
| 2187 | 0 | rwmc2187; strong=0; visible=0 | 20107 | 2188 | type=18, main=10, sub=65, final=1186, amount=1, query=0 | 11287 / 0 / 0 / 0 | NPC fields in objective; unlock_map=260 | Config parsed; runtime status not inferred |
| 2188 | 0 | rwmc2188; strong=0; visible=0 | 2187 | 2189 | type=18, main=10, sub=68, final=1187, amount=1, query=0 | 11287 / 0 / 0 / 0 | NPC fields in objective; unlock_map=261 | Config parsed; runtime status not inferred |
| 2189 | 0 | rwmc2189; strong=0; visible=0 | 2188 | 2190 | type=18, main=10, sub=71, final=1188, amount=1, query=0 | 11287 / 0 / 0 / 0 | NPC fields in objective; unlock_map=262 | Config parsed; runtime status not inferred |
| 2190 | 0 | rwmc2190; strong=0; visible=0 | 2189 | 20108 | type=18, main=10, sub=72, final=1189, amount=1, query=0 | 11287 / 0 / 0 / 0 | NPC fields in objective; unlock_map=263 | Config parsed; runtime status not inferred |
| 2191 | 0 | rwmc2191; strong=0; visible=0 | 20108 | 20109 | type=18, main=10, sub=78, final=1190, amount=1, query=0 | 11287 / 0 / 0 / 0 | NPC fields in objective; unlock_map=265 | Config parsed; runtime status not inferred |
| 2192 | 0 | rwmc2192; strong=0; visible=0 | 20109 | 2193 | type=18, main=10, sub=83, final=1191, amount=1, query=0 | 11287 / 0 / 0 / 0 | NPC fields in objective; unlock_map=267 | Config parsed; runtime status not inferred |
| 2193 | 0 | rwmc2193; strong=0; visible=0 | 2192 | — | type=18, main=10, sub=86, final=1192, amount=1, query=0 | 11287 / 0 / 0 / 0 | NPC fields in objective; unlock_map=268 | Config parsed; runtime status not inferred |
| 10001 | 0 | xsyd2; strong=1; visible=0 | 1 | 2, 10002 | type=2, main=0, sub=0, final=0, amount=1, query=0 | 2000 / 2000 / nil / 0 | NPC fields in objective; unlock_map=1 | Config parsed; runtime status not inferred |
| 10002 | 0 | xsyd3; strong=1; visible=0 | 10001 | 10003 | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=2 | Config parsed; runtime status not inferred |
| 10003 | 0 | xsyd4; strong=1; visible=0 | 10002 | 10005 | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10004 | 0 | xsyd5; strong=1; visible=0 | — | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10005 | 0 | xsyd6; strong=1; visible=0 | 10003 | 10006 | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10006 | 0 | xsyd7; strong=1; visible=0 | 10005 | 10007 | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10007 | 0 | xsyd8; strong=1; visible=0 | 10006 | 10008 | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=3 | Config parsed; runtime status not inferred |
| 10008 | 0 | xsyd9; strong=1; visible=0 | 10007 | 29999 | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10009 | 0 | xsyd10; strong=1; visible=0 | 29999 | 10010 | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10010 | 0 | xsyd11; strong=1; visible=0 | 10009 | 10011 | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10011 | 0 | xsyd12; strong=1; visible=0 | 10010 | 10032 | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10012 | 0 | xsyd13; strong=1; visible=0 | 30008 | 10019 | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10013 | 0 | xsyd14; strong=1; visible=0 | 20026 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10014 | 0 | xsyd15; strong=1; visible=0 | 20005 | 20009 | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10015 | 0 | xsyd16; strong=1; visible=0 | 30009 | 20008 | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10016 | 0 | xsyd17; strong=1; visible=0 | 20003 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10017 | 0 | xsyd18; strong=1; visible=0 | 20008 | 10050 | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10018 | 0 | xsyd19; strong=1; visible=0 | — | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=q4 | Config parsed; runtime status not inferred |
| 10019 | 0 | xsyd20; strong=0; visible=0 | 10012 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10020 | 0 | xsyd21; strong=0; visible=0 | — | — | type=20, main=0, sub=0, final=0, amount=10, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10021 | 0 | xsyd22; strong=0; visible=0 | — | — | type=35, main=0, sub=0, final=0, amount=5, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=q1 | Config parsed; runtime status not inferred |
| 10022 | 0 | xsyd23; strong=0; visible=0 | — | — | type=31, main=0, sub=0, final=0, amount=12, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=q4 | Config parsed; runtime status not inferred |
| 10023 | 0 | xsyd24; strong=1; visible=0 | — | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 11005 / nil / nil / 0 | NPC fields in objective; unlock_map=q3 | Config parsed; runtime status not inferred |
| 10024 | 0 | xsyd25; strong=1; visible=0 | 10014 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10025 | 0 | xsyd26; strong=0; visible=1 | 2004 | — | type=37, main=0, sub=0, final=0, amount=5, query=0 | 11006 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10026 | 0 | xsyd27; strong=0; visible=1 | 2004 | — | type=37, main=0, sub=0, final=0, amount=5, query=0 | 11007 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10027 | 0 | xsyd28; strong=0; visible=1 | 2004 | — | type=37, main=0, sub=0, final=0, amount=5, query=0 | 11008 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10028 | 0 | xsyd29; strong=0; visible=1 | 2010 | — | type=38, main=0, sub=0, final=0, amount=12, query=0 | 11009 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10029 | 0 | xsyd30; strong=0; visible=1 | 2010 | — | type=38, main=0, sub=0, final=0, amount=12, query=0 | 11010 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10030 | 0 | xsyd31; strong=0; visible=1 | 2010 | — | type=38, main=0, sub=0, final=0, amount=12, query=0 | 11011 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10031 | 0 | xsyd32; strong=1; visible=0 | 10038 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10032 | 0 | xsyd33; strong=1; visible=0 | 10011 | 30000, 20001 | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=6 | Config parsed; runtime status not inferred |
| 10033 | 0 | xsyd34; strong=1; visible=0 | — | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10034 | 0 | xsyd35; strong=1; visible=0 | — | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10035 | 0 | xsyd36; strong=1; visible=0 | 10035 | 10036 | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10036 | 0 | xsyd37; strong=1; visible=0 | 10036 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10037 | 0 | xsyd38; strong=1; visible=0 | 30001 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10038 | 0 | xsyd39; strong=0; visible=0 | 2 | 10031 | type=20, main=0, sub=0, final=0, amount=11, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10039 | 0 | xsyd40; strong=0; visible=0 | 2 | 10040, 10041, 10042 | type=20, main=0, sub=0, final=0, amount=15, query=0 | 11012 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10040 | 0 | xsyd41; strong=1; visible=0 | 10039 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 11049 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10041 | 0 | xsyd42; strong=1; visible=0 | 10040 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10042 | 0 | xsyd43; strong=1; visible=0 | 10039 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10043 | 0 | xsyd44; strong=0; visible=0 | — | — | type=20, main=0, sub=0, final=0, amount=3, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10044 | 0 | xsyd45; strong=1; visible=0 | — | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10045 | 0 | xsyd46; strong=1; visible=0 | — | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10046 | 0 | xsyd47; strong=0; visible=0 | 2 | 10047 | type=20, main=0, sub=0, final=0, amount=13, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10047 | 0 | xsyd48; strong=1; visible=0 | 10046 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10048 | 0 | xsyd49; strong=0; visible=0 | 2 | 10044 | type=20, main=0, sub=0, final=0, amount=13, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10049 | 0 | xsyd50; strong=1; visible=0 | 10043 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10050 | 0 | xsyd51; strong=1; visible=0 | 10017 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10051 | 0 | xsyd52; strong=1; visible=0 | 2015 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10052 | 0 | xsyd53; strong=1; visible=0 | 10051 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=q4 | Config parsed; runtime status not inferred |
| 10053 | 0 | xsyd54; strong=1; visible=0 | 10051 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=q4 | Config parsed; runtime status not inferred |
| 10054 | 0 | xsyd55; strong=1; visible=0 | 10051 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=q4 | Config parsed; runtime status not inferred |
| 10055 | 0 | xsyd56; strong=1; visible=0 | 2004 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10056 | 0 | xsyd57; strong=1; visible=0 | 10055 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=q3 | Config parsed; runtime status not inferred |
| 10057 | 0 | xsyd58; strong=1; visible=0 | 10055 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=q3 | Config parsed; runtime status not inferred |
| 10058 | 0 | xsyd59; strong=1; visible=0 | 10055 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=q3 | Config parsed; runtime status not inferred |
| 10059 | 0 | xsyd60; strong=1; visible=0 | 30005 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10060 | 0 | xsyd61; strong=0; visible=0 | 2004 | 10056 | type=37, main=0, sub=0, final=0, amount=5, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=q3 | Config parsed; runtime status not inferred |
| 10061 | 0 | xsyd62; strong=0; visible=0 | 2004 | 10057 | type=37, main=0, sub=0, final=0, amount=5, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=q3 | Config parsed; runtime status not inferred |
| 10062 | 0 | xsyd63; strong=0; visible=0 | 2004 | 10058 | type=37, main=0, sub=0, final=0, amount=5, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=q3 | Config parsed; runtime status not inferred |
| 10063 | 0 | xsyd64; strong=1; visible=0 | 2010 | 10052 | type=38, main=0, sub=0, final=0, amount=12, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=q3 | Config parsed; runtime status not inferred |
| 10064 | 0 | xsyd65; strong=1; visible=0 | 2010 | 10053 | type=38, main=0, sub=0, final=0, amount=12, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=q3 | Config parsed; runtime status not inferred |
| 10065 | 0 | xsyd66; strong=1; visible=0 | 2010 | 10054 | type=38, main=0, sub=0, final=0, amount=12, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=q3 | Config parsed; runtime status not inferred |
| 10066 | 0 | xsyd67; strong=1; visible=0 | 2009 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10067 | 0 | xsyd69; strong=1; visible=0 | 2015 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10068 | 0 | xsyd70; strong=1; visible=0 | 20000 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 10071 | 0 | xsyd73; strong=1; visible=0 | 20033 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 20000 | 0 | ycrw2; strong=0; visible=0 | 10008 | — | type=19, main=2, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=5 | Config parsed; runtime status not inferred |
| 20001 | 0 | ycrw3; strong=0; visible=0 | 10032 | 30001, 2004 | type=19, main=3, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=7 | Config parsed; runtime status not inferred |
| 20002 | 0 | ycrw4; strong=0; visible=0 | 2005 | 30004, 2006 | type=19, main=4, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=11 | Config parsed; runtime status not inferred |
| 20003 | 0 | ycrw5; strong=0; visible=0 | 2007 | 2008, 10016 | type=19, main=5, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=14 | Config parsed; runtime status not inferred |
| 20004 | 0 | ycrw6; strong=0; visible=0 | 2009 | 30006, 2010 | type=19, main=6, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=17 | Config parsed; runtime status not inferred |
| 20005 | 0 | ycrw7; strong=0; visible=0 | 2010 | 10014, 2011, 20009 | type=19, main=7, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=19 | Config parsed; runtime status not inferred |
| 20006 | 0 | ycrw8; strong=0; visible=0 | 2013 | 2014, 30008 | type=19, main=8, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=23 | Config parsed; runtime status not inferred |
| 20007 | 0 | ycrw9; strong=0; visible=0 | 2015 | 177, 30009, 20008 | type=19, main=9, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=26 | Config parsed; runtime status not inferred |
| 20008 | 0 | ycrw10; strong=0; visible=0 | 20007 | 10017, 2016 | type=19, main=10, sub=0, final=0, amount=1, query=0 | 11013 / nil / nil / 0 | NPC fields in objective; unlock_map=27 | Config parsed; runtime status not inferred |
| 20009 | 0 | ycrw10007; strong=0; visible=0 | 20005 | 10024 | type=19, main=10007, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 20021 | 0 | ycrw11; strong=0; visible=0 | 2016 | 2017 | type=19, main=11, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=29 | Config parsed; runtime status not inferred |
| 20022 | 0 | ycrw12; strong=0; visible=0 | 2017 | 2018 | type=19, main=12, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=31 | Config parsed; runtime status not inferred |
| 20023 | 0 | ycrw13; strong=0; visible=0 | 2018 | 2019 | type=19, main=13, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=33 | Config parsed; runtime status not inferred |
| 20024 | 0 | ycrw14; strong=0; visible=0 | 2020 | 2021 | type=19, main=14, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=36 | Config parsed; runtime status not inferred |
| 20025 | 0 | ycrw15; strong=0; visible=0 | 2021 | — | type=19, main=15, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 20026 | 0 | ycrw16; strong=0; visible=0 | 2023 | 10013, 2024 | type=19, main=16, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=41 | Config parsed; runtime status not inferred |
| 20027 | 0 | ycrw17; strong=0; visible=0 | 2025 | 30019, 2026 | type=19, main=17, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=44 | Config parsed; runtime status not inferred |
| 20028 | 0 | ycrw18; strong=0; visible=0 | 2028 | 2029 | type=19, main=18, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=48 | Config parsed; runtime status not inferred |
| 20029 | 0 | ycrw19; strong=0; visible=0 | 2029 | 2030 | type=19, main=19, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=50 | Config parsed; runtime status not inferred |
| 20030 | 0 | ycrw21; strong=0; visible=0 | 2030 | 30020, 2031 | type=19, main=21, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=52 | Config parsed; runtime status not inferred |
| 20031 | 0 | ycrw22; strong=0; visible=0 | 2032 | 2033 | type=19, main=22, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=55 | Config parsed; runtime status not inferred |
| 20032 | 0 | ycrw23; strong=0; visible=0 | 2034 | 2035 | type=19, main=23, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=58 | Config parsed; runtime status not inferred |
| 20033 | 0 | ycrw24; strong=0; visible=0 | 2036 | 2037, 10071 | type=19, main=24, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=61 | Config parsed; runtime status not inferred |
| 20034 | 0 | ycrw25; strong=0; visible=0 | 2037 | 2038 | type=19, main=25, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=63 | Config parsed; runtime status not inferred |
| 20035 | 0 | ycrw26; strong=0; visible=0 | 2039 | 2040 | type=19, main=26, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=66 | Config parsed; runtime status not inferred |
| 20036 | 0 | ycrw27; strong=0; visible=0 | 2042 | 30024, 2043 | type=19, main=27, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=70 | Config parsed; runtime status not inferred |
| 20037 | 0 | ycrw28; strong=0; visible=0 | 2043 | 2044 | type=19, main=28, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=72 | Config parsed; runtime status not inferred |
| 20038 | 0 | ycrw29; strong=0; visible=0 | 2045 | 2046 | type=19, main=29, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=75 | Config parsed; runtime status not inferred |
| 20039 | 0 | ycrw30; strong=0; visible=0 | 2048 | 2049, 30026 | type=19, main=30, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=79 | Config parsed; runtime status not inferred |
| 20040 | 0 | ycrw31; strong=0; visible=0 | 2049 | 2050 | type=19, main=31, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=81 | Config parsed; runtime status not inferred |
| 20041 | 0 | ycrw32; strong=0; visible=0 | 2052 | 2053 | type=19, main=32, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=85 | Config parsed; runtime status not inferred |
| 20042 | 0 | ycrw33; strong=0; visible=0 | 2053 | 2054 | type=19, main=33, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=87 | Config parsed; runtime status not inferred |
| 20043 | 0 | ycrw34; strong=0; visible=0 | 2055 | 30028, 2056 | type=19, main=34, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=90 | Config parsed; runtime status not inferred |
| 20044 | 0 | ycrw35; strong=0; visible=0 | 2057 | 2058 | type=19, main=35, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=93 | Config parsed; runtime status not inferred |
| 20045 | 0 | ycrw36; strong=0; visible=0 | 2061 | 2062 | type=19, main=36, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=98 | Config parsed; runtime status not inferred |
| 20046 | 0 | ycrw37; strong=0; visible=0 | 2064 | 2065 | type=19, main=37, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=102 | Config parsed; runtime status not inferred |
| 20047 | 0 | ycrw38; strong=0; visible=0 | 2067 | 30030, 2068 | type=19, main=38, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=106 | Config parsed; runtime status not inferred |
| 20048 | 0 | ycrw39; strong=0; visible=0 | 2068 | 2069 | type=19, main=39, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=108 | Config parsed; runtime status not inferred |
| 20049 | 0 | ycrw40; strong=0; visible=0 | 2071 | 2072 | type=19, main=40, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=112 | Config parsed; runtime status not inferred |
| 20050 | 0 | ycrw41; strong=0; visible=0 | 2072 | 30031, 2073 | type=19, main=41, sub=0, final=0, amount=1, query=0 | 0 / 400 / 190 / 0 | NPC fields in objective; unlock_map=114 | Config parsed; runtime status not inferred |
| 20051 | 0 | ycrw42; strong=0; visible=0 | 2074 | 2075 | type=19, main=42, sub=0, final=0, amount=1, query=0 | 0 / 400 / 200 / 0 | NPC fields in objective; unlock_map=117 | Config parsed; runtime status not inferred |
| 20052 | 0 | ycrw44; strong=0; visible=0 | 2077 | 2078 | type=19, main=44, sub=0, final=0, amount=1, query=0 | 0 / 500 / 210 / 0 | NPC fields in objective; unlock_map=121 | Config parsed; runtime status not inferred |
| 20053 | 0 | ycrw45; strong=0; visible=0 | 2079 | 30034, 2080 | type=19, main=45, sub=0, final=0, amount=1, query=0 | 0 / 500 / 210 / 0 | NPC fields in objective; unlock_map=124 | Config parsed; runtime status not inferred |
| 20054 | 0 | ycrw47; strong=0; visible=0 | 2081 | 2082 | type=19, main=47, sub=0, final=0, amount=1, query=0 | 0 / 600 / 220 / 0 | NPC fields in objective; unlock_map=127 | Config parsed; runtime status not inferred |
| 20055 | 0 | ycrw48; strong=0; visible=0 | 2083 | 30037, 2084 | type=19, main=48, sub=0, final=0, amount=1, query=0 | 0 / 600 / 220 / 0 | NPC fields in objective; unlock_map=130 | Config parsed; runtime status not inferred |
| 20056 | 0 | ycrw49; strong=0; visible=0 | 2086 | 30038, 2087, 2088, 2090 | type=19, main=49, sub=0, final=0, amount=1, query=0 | 0 / 600 / 230 / 0 | NPC fields in objective; unlock_map=134 | Config parsed; runtime status not inferred |
| 20057 | 0 | ycrw43; strong=0; visible=0 | 2076 | 30033 | type=19, main=43, sub=0, final=0, amount=1, query=0 | 0 / 400 / 200 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 20058 | 0 | ycrw46; strong=0; visible=0 | 2080 | 30036 | type=19, main=46, sub=0, final=0, amount=1, query=0 | 0 / 500 / 220 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 20059 | 0 | ycrw52; strong=0; visible=0 | 2090 | 30039, 2091 | type=19, main=52, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=136 | Config parsed; runtime status not inferred |
| 20060 | 0 | ycrw53; strong=0; visible=0 | 2091 | 2092 | type=19, main=53, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 20061 | 0 | ycrw54; strong=0; visible=0 | 2092 | 2093 | type=19, main=54, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=139 | Config parsed; runtime status not inferred |
| 20062 | 0 | ycrw55; strong=0; visible=0 | 2095 | 2096 | type=19, main=55, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=143 | Config parsed; runtime status not inferred |
| 20063 | 0 | ycrw56; strong=0; visible=0 | 2097 | 30041, 2098, 2099 | type=19, main=56, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=146 | Config parsed; runtime status not inferred |
| 20064 | 0 | ycrw57; strong=0; visible=0 | 2098 | — | type=19, main=57, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 20065 | 0 | ycrw58; strong=0; visible=0 | 2100 | 2101 | type=19, main=58, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=149 | Config parsed; runtime status not inferred |
| 20066 | 0 | ycrw59; strong=0; visible=0 | 2102 | 30042, 2103 | type=19, main=59, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=152 | Config parsed; runtime status not inferred |
| 20067 | 0 | ycrw60; strong=0; visible=0 | 2103 | 2104 | type=19, main=60, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=154 | Config parsed; runtime status not inferred |
| 20068 | 0 | ycrw61; strong=0; visible=0 | 2105 | 30044, 2106 | type=19, main=61, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=157 | Config parsed; runtime status not inferred |
| 20069 | 0 | ycrw62; strong=0; visible=0 | 2106 | 30045, 2107 | type=19, main=62, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=159 | Config parsed; runtime status not inferred |
| 20070 | 0 | ycrw63; strong=0; visible=0 | 2109 | 2110, 20071, 2111, 30047 | type=19, main=63, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=163 | Config parsed; runtime status not inferred |
| 20071 | 0 | ycrw64; strong=0; visible=0 | 20070 | — | type=19, main=64, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 20072 | 0 | ycrw65; strong=0; visible=0 | 2111 | 2112 | type=19, main=65, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=165 | Config parsed; runtime status not inferred |
| 20073 | 0 | ycrw66; strong=0; visible=0 | 2114 | 2115 | type=19, main=66, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=169 | Config parsed; runtime status not inferred |
| 20074 | 0 | ycrw67; strong=0; visible=0 | 2117 | 20075, 30048 | type=19, main=67, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=174 | Config parsed; runtime status not inferred |
| 20075 | 0 | ycrw68; strong=0; visible=0 | 20074 | 20076, 2119, 2120, 2121 | type=19, main=68, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=175 | Config parsed; runtime status not inferred |
| 20076 | 0 | ycrw69; strong=0; visible=0 | 20075 | — | type=19, main=69, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 20077 | 0 | ycrw70; strong=0; visible=0 | 2123 | 2124 | type=19, main=70, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=179 | Config parsed; runtime status not inferred |
| 20078 | 0 | ycrw71; strong=0; visible=0 | 2125 | 2126 | type=19, main=71, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=182 | Config parsed; runtime status not inferred |
| 20079 | 0 | ycrw72; strong=0; visible=0 | 2128 | 2129, 30049 | type=19, main=72, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=186 | Config parsed; runtime status not inferred |
| 20080 | 0 | ycrw73; strong=0; visible=0 | 2129 | 20081, 2130, 2131 | type=19, main=73, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=188 | Config parsed; runtime status not inferred |
| 20081 | 0 | ycrw74; strong=0; visible=0 | 20080 | — | type=19, main=74, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 20082 | 0 | ycrw75; strong=0; visible=0 | 2132 | 2133 | type=19, main=75, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=191 | Config parsed; runtime status not inferred |
| 20083 | 0 | ycrw76; strong=0; visible=0 | 2134 | 2135 | type=19, main=76, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=194 | Config parsed; runtime status not inferred |
| 20084 | 0 | ycrw77; strong=0; visible=0 | 2137 | 2138 | type=19, main=77, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=198 | Config parsed; runtime status not inferred |
| 20085 | 0 | ycrw78; strong=0; visible=0 | 2140 | 2141 | type=19, main=78, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=202 | Config parsed; runtime status not inferred |
| 20086 | 0 | ycrw79; strong=0; visible=0 | 2142 | — | type=19, main=79, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 20087 | 0 | ycrw80; strong=0; visible=0 | 2145 | 2146, 2147, 20088, 2148 | type=19, main=80, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=207 | Config parsed; runtime status not inferred |
| 20088 | 0 | ycrw81; strong=0; visible=0 | 20087 | — | type=19, main=81, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 20089 | 0 | ycrw82; strong=0; visible=0 | 2149 | 2150 | type=19, main=82, sub=0, final=0, amount=1, query=0 | 11204 / 0 / 0 / 0 | NPC fields in objective; unlock_map=210 | Config parsed; runtime status not inferred |
| 20090 | 0 | ycrw83; strong=0; visible=0 | 2152 | 2153 | type=19, main=83, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=214 | Config parsed; runtime status not inferred |
| 20091 | 0 | ycrw84; strong=0; visible=0 | 2154 | 2155 | type=19, main=84, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=217 | Config parsed; runtime status not inferred |
| 20092 | 0 | ycrw85; strong=0; visible=0 | 2156 | 2157, 20093, 2158 | type=19, main=85, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=220 | Config parsed; runtime status not inferred |
| 20093 | 0 | ycrw86; strong=0; visible=0 | 20092 | — | type=19, main=86, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 20094 | 0 | ycrw87; strong=0; visible=0 | 2160 | 2161 | type=19, main=87, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=224 | Config parsed; runtime status not inferred |
| 20095 | 0 | ycrw88; strong=0; visible=0 | 2161 | 2162, 2163, 2164, 20096, 2165 | type=19, main=88, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=226 | Config parsed; runtime status not inferred |
| 20096 | 0 | ycrw89; strong=0; visible=0 | 20095 | — | type=19, main=89, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 20097 | 0 | ycrw90; strong=0; visible=0 | 2166 | 2167 | type=19, main=90, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=229 | Config parsed; runtime status not inferred |
| 20098 | 0 | ycrw91; strong=0; visible=0 | 2167 | 2168 | type=19, main=91, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=231 | Config parsed; runtime status not inferred |
| 20099 | 0 | ycrw92; strong=0; visible=0 | 2169 | 2170 | type=19, main=92, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=234 | Config parsed; runtime status not inferred |
| 20100 | 0 | ycrw93; strong=0; visible=0 | 2172 | 2173 | type=19, main=93, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=238 | Config parsed; runtime status not inferred |
| 20101 | 0 | ycrw94; strong=0; visible=0 | 2174 | 2175 | type=19, main=94, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=241 | Config parsed; runtime status not inferred |
| 20102 | 0 | ycrw95; strong=0; visible=0 | 2176 | 2177 | type=19, main=95, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=244 | Config parsed; runtime status not inferred |
| 20103 | 0 | ycrw96; strong=0; visible=0 | 2178 | 2179, 30050 | type=19, main=96, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=247 | Config parsed; runtime status not inferred |
| 20104 | 0 | ycrw97; strong=0; visible=0 | 2180 | 2181 | type=19, main=97, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=250 | Config parsed; runtime status not inferred |
| 20105 | 0 | ycrw98; strong=0; visible=0 | 2183 | 2184 | type=19, main=98, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=254 | Config parsed; runtime status not inferred |
| 20106 | 0 | ycrw99; strong=0; visible=0 | 2184 | 2185 | type=19, main=99, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=256 | Config parsed; runtime status not inferred |
| 20107 | 0 | ycrw100; strong=0; visible=0 | 2186 | 2187 | type=19, main=100, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=259 | Config parsed; runtime status not inferred |
| 20108 | 0 | ycrw101; strong=0; visible=0 | 2190 | 2191 | type=19, main=101, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=264 | Config parsed; runtime status not inferred |
| 20109 | 0 | ycrw102; strong=0; visible=0 | 2191 | 2192 | type=19, main=102, sub=0, final=0, amount=1, query=0 | 0 / 0 / 0 / 0 | NPC fields in objective; unlock_map=266 | Config parsed; runtime status not inferred |
| 29999 | 0 | jqcf0; strong=1; visible=0 | 10008 | 20000, 10009 | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=4 | Config parsed; runtime status not inferred |
| 30000 | 0 | jqcf1; strong=1; visible=0 | 10032 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30001 | 0 | jqcf2; strong=1; visible=0 | 20001 | 10037 | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30002 | 0 | jqcf3; strong=1; visible=0 | — | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30003 | 0 | jqcf4; strong=1; visible=0 | — | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30004 | 0 | jqcf5; strong=1; visible=0 | 20002 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30005 | 0 | jqcf6; strong=1; visible=0 | 2008 | 10059 | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30006 | 0 | jqcf7; strong=1; visible=0 | 20004 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30007 | 0 | jqcf8; strong=1; visible=0 | — | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30008 | 0 | jqcf9; strong=1; visible=0 | 20006 | 10012 | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30009 | 0 | jqcf10; strong=1; visible=0 | 20007 | 10015 | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30010 | 0 | jqcf11; strong=1; visible=0 | — | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30011 | 0 | jqcf12; strong=1; visible=0 | — | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30012 | 0 | jqcf13; strong=1; visible=0 | — | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30013 | 0 | jqcf14; strong=1; visible=0 | — | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30014 | 0 | jqcf15; strong=1; visible=0 | 2022 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30015 | 0 | jqcf16; strong=1; visible=0 | 2018 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30016 | 0 | jqcf17; strong=1; visible=0 | 2023 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30017 | 0 | jqcf18; strong=1; visible=0 | 2027 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30018 | 0 | jqcf19; strong=1; visible=0 | 2029 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30019 | 0 | jqcf20; strong=1; visible=0 | 20027 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30020 | 0 | jqcf21; strong=1; visible=0 | 20030 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30021 | 0 | jqcf22; strong=1; visible=0 | 2034 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30022 | 0 | jqcf23; strong=1; visible=0 | 2037 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30023 | 0 | jqcf24; strong=1; visible=0 | 2041 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30024 | 0 | jqcf25; strong=1; visible=0 | 20036 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30025 | 0 | jqcf26; strong=1; visible=0 | 2047 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30026 | 0 | jqcf27; strong=1; visible=0 | 20039 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30027 | 0 | jqcf28; strong=1; visible=0 | 2051 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30028 | 0 | jqcf29; strong=1; visible=0 | 20043 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30029 | 0 | jqcf30; strong=1; visible=0 | 2060 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30030 | 0 | jqcf31; strong=1; visible=0 | 20047 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30031 | 0 | jqcf32; strong=1; visible=0 | 20050 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30032 | 0 | jqcf33; strong=1; visible=0 | 2076 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30033 | 0 | jqcf34; strong=1; visible=0 | 20057 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30034 | 0 | jqcf35; strong=1; visible=0 | 20053 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30035 | 0 | jqcf36; strong=1; visible=0 | 2080 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30036 | 0 | jqcf37; strong=1; visible=0 | 20058 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30037 | 0 | jqcf38; strong=1; visible=0 | 20055 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30038 | 0 | jqcf39; strong=1; visible=0 | 20056 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30039 | 0 | jqcf40; strong=1; visible=0 | 20059 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30040 | 0 | jqcf41; strong=1; visible=0 | 2093 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30041 | 0 | jqcf42; strong=1; visible=0 | 20063 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30042 | 0 | jqcf43; strong=1; visible=0 | 20066 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30043 | 0 | jqcf44; strong=1; visible=0 | 2104 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30044 | 0 | jqcf45; strong=1; visible=0 | 20068 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30045 | 0 | jqcf46; strong=1; visible=0 | 20069 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30046 | 0 | jqcf47; strong=1; visible=0 | 2107 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30047 | 0 | jqcf48; strong=1; visible=0 | 20070 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30048 | 0 | jqcf49; strong=1; visible=0 | 20074 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30049 | 0 | jqcf50; strong=1; visible=0 | 20079 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |
| 30050 | 0 | jqcf51; strong=1; visible=0 | 20103 | — | type=2, main=0, sub=0, final=0, amount=1, query=0 | 0 / nil / nil / 0 | NPC fields in objective; unlock_map=nil | Config parsed; runtime status not inferred |

## Tutorial chain observed in config and Lua

`1 → 10001 → {2, 10002} → 10003 → 10005 → 10006 → 10007 ...` (branches continue in the raw table; see every child edge above). `GameGuideMgr.lua` dispatches guide IDs to client walkthroughs; only IDs with corresponding guide handlers have a known UI flow.

## Source and coverage limits

- Full quest IDs, numeric types, parent/child references, raw objectives, reward fields, map-unlock strings, visibility and strong-guide flags: **FULL**.
- Objective natural-language meanings and NPC names: **PARTIAL**; numeric event codes and IDs are retained without guessing.
- Quest runtime state and rewards for untested quests: **NOT VERIFIED**.
- Side/daily/event quest reset behavior: config present but server lifecycle coverage is not established by this index.

## Other discovered catalogs

These catalogs are parsed from shipped config. Presence is not proof of handler/runtime support. Activity dates and payment provider schedules are historical config and are not treated as live availability.

### Event and activity catalog (43 records)

Source: `apk_extracted/assets/res/Config/ActivityInfoClient.dat`.

| ID | Configured data |
|---:|---|
| 1 | 签到有奖 — type=3, page=1, opens=0d, duration=604800s, params=['1_10000,1', '3241_1,2', '125_1,3', '3052_50,4', '45_5,5', '2097_1,6', '3247_1,7'] |
| 3 | 首充奖励 — type=12, page=0, opens=0d, duration=518400000s, params=['1,1,308_1&4341_10&2_640&135_1,9999'] |
| 4 | 领体力 — type=11, page=3, opens=0d, duration=518400000s, params=['12:00:00,14:00:00,120', '18:00:00,20:00:00,120'] |
| 5 | 封测返利 — type=14, page=1, opens=0d, duration=604800s, params=['20,3000,20,10'] |
| 6 | 每日首充 — type=12, page=0, opens=0d, duration=518400000s, params=['4,1,7_10&122_2&2_80,9999'] |
| 7 | 限时扭蛋 — type=18, page=1, opens=0d, duration=432000s, params=['1,3688,1,2067,2068', '2,1288,1,2069,2070'] |
| 8 | 累计充值 — type=12, page=2, opens=1d, duration=0s, params=['2,6,2_100&129_3,1000', '25,2_150&129_10,1000', '60,2_300&372_1,1000', '100,2_400&372_3,1000', '200,2_1000&372_8,1000', '500,2_1888&372_20,1000'] |
| 9 | 消费返利 — type=13, page=2, opens=0d, duration=0s, params=['0,3000,1_200000,1000', '10000,1_300000,1000', '20000,1_400000,1000', '50000,60005_400,1000', '90000,60006_600,1000'] |
| 11 | 成长基金 — type=6, page=1, opens=0d, duration=518400000s, params=['14,2000,1_5000&5_20', '10,2_300', '15,2_400', '25,2_600', '30,2_700', '35,2_800', '40,2_1000', '45,2_1200', '50,2_1688'] |
| 12 | 洛天依积分 — type=17, page=1, opens=0d, duration=604800s, params=['1,3272_1', '3,3272_1', '10,3272_1', '20,3311_1&3312_1&3313_1&3314_1', '100,2_1000', '200,2_500', '500,2_300', '1000,2_200', '99999,2_100'] |
| 14 | 封测发奖 — type=15, page=1, opens=0d, duration=604800s, params=['21,3229_1'] |
| 16 | 千层塔 — type=19, page=3, opens=0d, duration=86400s, params=['1,4,5'] |
| 17 | 神秘新宠现已到来 — type=1, page=1, opens=0d, duration=518400s, params=['--'] |
| 18 | 【论坛】晒时装，夺豪礼 — type=1, page=1, opens=0d, duration=518400s, params=['--'] |
| 19 | ViP尊贵商店 — type=1, page=1, opens=0d, duration=518400000s, params=['--'] |
| 21 | 千层塔双S — type=37, page=3, opens=0d, duration=518400000s, params=['6,21,22', '7,21,22'] |
| 100 | 连续登陆 — type=24, page=1, opens=0d, duration=0s, params=['3,377_1'] |
| 165 | 生存战层数 — type=32, page=4, opens=0d, duration=2332800s, params=['191_500&185_1,2', '191_600&185_1,4', '191_700&185_2,6', '191_800&185_2,8', '191_900&185_3,10', '191_1000&185_3,12'] |
| 196 | 生存战 — type=30, page=4, opens=0d, duration=2332800s, params=['--'] |
| 197 | 活动商店 — type=31, page=4, opens=0d, duration=2332800s, params=['--'] |
| 202 | 限时扭蛋 — type=18, page=4, opens=0d, duration=2592000s, params=['3,30,3,2067,2068'] |
| 205 | 远征参与 — type=35, page=4, opens=0d, duration=2592000s, params=['1_5000&2_30,1'] |
| 206 | 远征过关 — type=36, page=4, opens=0d, duration=864000s, params=['60005_2&60006_2,2', '60005_4&60006_4,4', '60005_6&60006_6,6', '60005_8&60006_8,8'] |
| 212 | 大联盟 — type=33, page=4, opens=0d, duration=1728000s, params=['3322_5&377_1,5'] |
| 213 | 组队副本 — type=21, page=4, opens=0d, duration=2592000s, params=['3,1_5000&2_30'] |
| 221 | SSS宠 — type=1, page=4, opens=0d, duration=1728000s, params=['--'] |
| 223 | 挑战状1 — type=23, page=4, opens=0d, duration=2592000s, params=['1,1_5000&2_30'] |
| 224 | 挑战状2 — type=25, page=4, opens=0d, duration=2592000s, params=['1_5000&2_30,3', '60005_3&60006_3,5', '60005_4&60006_4,7', '60005_5&60006_5,9'] |
| 225 | 挑战状3 — type=26, page=4, opens=0d, duration=1728000s, params=['60005_3&60006_3,50', '60005_4&60006_4,100', '60005_5&60006_5,150'] |
| 235 | 首冲改改改 — type=1, page=4, opens=0d, duration=2937600s, params=['--'] |
| 245 | 每日累冲 — type=12, page=4, opens=0d, duration=2592000s, params=['3,800,129_1&184_2&299_1,1000'] |
| 246 | 公众号送礼 — type=1, page=4, opens=0d, duration=86400s, params=['--'] |
| 247 | 交易所特卖 — type=1, page=4, opens=0d, duration=1123200s, params=['--'] |
| 253 | 大吉霸的大福利 — type=0, page=4, opens=0d, duration=604800s, params=['9999,10,247_1'] |
| 264 | VIP打折 — type=1, page=4, opens=0d, duration=86400s, params=['--'] |
| 306 | 每日累冲-2 — type=12, page=4, opens=0d, duration=1123200s, params=['3,12,60023_1&299_5,1000'] |
| 400 | 累计充值-六一 — type=12, page=4, opens=0d, duration=604800s, params=['2,80,104_5&106_5&98_1,1000', '400,2172_1&104_5&98_2,1000', '800,2139_1&104_5&98_5,1000', '2400,184_15&104_5&106_5,1000', '4000,184_25&106_5&98_5,1000', '8000,184_35&243_35&336_2,1000', '10000,243_35&336_3&242_1,1000', '20000,336_5&50052_1&380_10,1000'] |
| 401 | 累计充值-六一 — type=12, page=4, opens=0d, duration=604800s, params=['2,80,104_5&106_5&98_1,1000', '400,104_5&106_5&98_2,1000', '800,2173_1&104_5&98_5,1000', '2400,12070_15&104_5&106_5,1000', '4000,12070_25&106_5&98_5,1000', '8000,12070_35&12071_35&336_2,1000', '10000,12071_35&336_3&236_1,1000', '20000,336_5&50053_1&380_10,1000'] |
| 402 | 累计充值-六一 — type=12, page=4, opens=0d, duration=604800s, params=['2,80,104_5&106_5&98_1,1000', '400,104_5&106_5&98_2,1000', '800,2140_1&104_5&98_5,1000', '2400,184_15&104_5&106_5,1000', '4000,184_25&106_5&98_5,1000', '8000,184_35&243_35&336_2,1000', '10000,243_35&336_3&242_1,1000', '20000,336_5&50054_1&380_10,1000'] |
| 403 | 累计充值-六一 — type=12, page=4, opens=0d, duration=604800s, params=['2,80,104_5&106_5&98_1,1000', '400,104_5&106_5&98_2,1000', '800,2141_1&104_5&98_5,1000', '2400,12070_15&104_5&106_5,1000', '4000,12070_25&106_5&98_5,1000', '8000,12070_35&12071_35&336_2,1000', '10000,12071_35&336_3&236_1,1000', '20000,336_5&50053_1&380_10,1000'] |
| 501 | 消费返利-周更新 — type=13, page=4, opens=0d, duration=604800s, params=['0,500,104_2&105_10&106_2,1000', '1000,104_3&105_15&106_3,1000', '1500,104_5&105_20&106_5,1000', '3000,106_7&107_3&108_3,1000', '6000,106_10&107_5&105_5,1000', '10000,106_10&107_10&105_10,1000', '15000,98_10&336_5&129_1,1000', '20000,129_2&60005_30&60006_50,1000'] |
| 502 | 消费返利-周更新 — type=13, page=4, opens=0d, duration=604800s, params=['0,500,104_2&105_10&106_2,1000', '1000,104_3&105_15&106_3,1000', '1500,104_5&105_20&106_5,1000', '3000,106_7&107_3&108_3,1000', '6000,106_10&107_5&105_5,1000', '10000,106_10&107_10&105_10,1000', '15000,98_10&336_5&129_1,1000', '20000,129_2&60005_30&60006_50,1000'] |
| 633 | 宠物搜集令 — type=22, page=4, opens=0d, duration=2592000s, params=['--'] |

### Recharge package catalog (12 records)

Source: `apk_extracted/assets/res/Config/NormalRechargeInfo.dat`.

| ID | Configured data |
|---:|---|
| 2 | recharge5 — money=99, currency=80+0, bonusRate=2, order=1 |
| 3 | recharge5 — money=99, currency=80+0, bonusRate=0, order=10 |
| 4 | recharge6 — money=499, currency=400+0, bonusRate=2, order=2 |
| 5 | recharge7 — money=999, currency=800+0, bonusRate=2, order=4 |
| 6 | recharge7 — money=999, currency=800+180, bonusRate=0, order=11 |
| 7 | recharge8 — money=2999, currency=2400+0, bonusRate=2, order=5 |
| 8 | recharge9 — money=4999, currency=4000+0, bonusRate=2, order=7 |
| 9 | recharge9 — money=4999, currency=4000+1600, bonusRate=0, order=12 |
| 10 | recharge4 — money=9999, currency=8000+0, bonusRate=2, order=8 |
| 11 | recharge4 — money=9999, currency=8000+5000, bonusRate=0, order=9 |
| 12 | recharge6 — money=499, currency=400+80, bonusRate=0, order=3 |
| 13 | recharge8 — money=2999, currency=2400+900, bonusRate=0, order=6 |

### Month-card packages (2 records)

Source: `apk_extracted/assets/res/Config/MonthCardRechargeInfo.dat`.

| ID | Configured data |
|---:|---|
| 10001 | recharge1 — money=499, days=30, daily=160, initial=400 |
| 10002 | recharge50 — money=999, days=90, daily=320, initial=800 |

### Fashion catalog (300 records)

Source: `apk_extracted/assets/res/Config/FashionItemInfo.dat`.

| ID | Configured data |
|---:|---|
| 1 | fashion0001 — sex=2, file=Player/Avatar/eye1.png, hidden=0, skill=0 |
| 2 | fashion0002 — sex=2, file=Player/Avatar/eye10.png, hidden=0, skill=0 |
| 3 | fashion0003 — sex=2, file=Player/Avatar/eye3.png, hidden=1, skill=0 |
| 4 | fashion0004 — sex=2, file=Player/Avatar/eye2.png, hidden=1, skill=0 |
| 5 | fashion0005 — sex=2, file=Player/Avatar/eye5.png, hidden=0, skill=0 |
| 6 | fashion0006 — sex=2, file=Player/Avatar/eye4.png, hidden=0, skill=0 |
| 7 | fashion0007 — sex=2, file=Player/Avatar/eye7.png, hidden=0, skill=0 |
| 8 | fashion0008 — sex=2, file=Player/Avatar/eye6.png, hidden=1, skill=0 |
| 9 | fashion0009 — sex=2, file=Player/Avatar/eye9.png, hidden=1, skill=0 |
| 10 | fashion0010 — sex=2, file=Player/Avatar/eye8.png, hidden=1, skill=0 |
| 11 | fashion0011 — sex=2, file=Player/Avatar/eye12.png, hidden=1, skill=0 |
| 12 | fashion0012 — sex=2, file=Player/Avatar/eye14.png, hidden=1, skill=0 |
| 13 | fashion0013 — sex=2, file=Player/Avatar/eye11.png, hidden=1, skill=0 |
| 14 | fashion0014 — sex=2, file=Player/Avatar/eye13.png, hidden=1, skill=0 |
| 15 | fashion0015 — sex=2, file=Player/Avatar/eye15.png, hidden=0, skill=0 |
| 16 | fashion0016 — sex=2, file=Player/Avatar/eye16.png, hidden=0, skill=0 |
| 1001 | fashion1001 — sex=2, file=Player/Avatar/nv1_tou.png, hidden=0, skill=0 |
| 1002 | fashion1002 — sex=2, file=Player/Avatar/nv2_tou.png, hidden=0, skill=0 |
| 1003 | fashion1003 — sex=2, file=Player/Avatar/nv3_tou.png, hidden=0, skill=0 |
| 1004 | fashion1004 — sex=2, file=Player/Avatar/nan1_tou.png, hidden=0, skill=0 |
| 1005 | fashion1005 — sex=2, file=Player/Avatar/nan8_tou.png, hidden=0, skill=0 |
| 1006 | fashion1006 — sex=2, file=Player/Avatar/nan12_tou.png, hidden=0, skill=0 |
| 1007 | fashion1007 — sex=2, file=Player/Avatar/nan6_tou.png, hidden=0, skill=0 |
| 1008 | fashion1008 — sex=2, file=Player/Avatar/nv4_tou.png, hidden=0, skill=0 |
| 1009 | fashion1009 — sex=2, file=Player/Avatar/nv10_tou.png, hidden=0, skill=0 |
| 1010 | fashion1010 — sex=2, file=Player/Avatar/nv7_tou.png, hidden=0, skill=0 |
| 1011 | fashion1011 — sex=2, file=Player/Avatar/nan9_tou.png, hidden=0, skill=0 |
| 1012 | fashion1012 — sex=2, file=Player/Avatar/nan2_tou.png, hidden=0, skill=0 |
| 1013 | fashion1013 — sex=2, file=Player/Avatar/nan4_tou.png, hidden=0, skill=0 |
| 1014 | fashion1014 — sex=2, file=Player/Avatar/nan13_tou.png, hidden=0, skill=0 |
| 1015 | fashion1015 — sex=2, file=Player/Avatar/nan17_tou.png, hidden=0, skill=0 |
| 1016 | fashion1016 — sex=2, file=Player/Avatar/nv16_tou.png, hidden=0, skill=0 |
| 1017 | fashion1017 — sex=2, file=Player/Avatar/nv19_tou.png, hidden=0, skill=0 |
| 1018 | fashion1018 — sex=2, file=Player/Avatar/nan18_tou.png, hidden=0, skill=0 |
| 1019 | fashion1019 — sex=2, file=Player/Avatar/nv33_tou.png, hidden=0, skill=0 |
| 1020 | fashion1020 — sex=2, file=Player/Avatar/nan34_tou.png, hidden=0, skill=0 |
| 1021 | fashion1021 — sex=2, file=Player/Avatar/nan35_tou.png, hidden=0, skill=0 |
| 1022 | fashion1022 — sex=2, file=Player/Avatar/nv11_tou.png, hidden=0, skill=0 |
| 1023 | fashion1023 — sex=2, file=Player/Avatar/nan36_tou.png, hidden=0, skill=0 |
| 1024 | fashion1024 — sex=2, file=Player/Avatar/nan20_tou.png, hidden=0, skill=0 |
| 1025 | fashion1025 — sex=2, file=Player/Avatar/nv38_tou.png, hidden=0, skill=0 |
| 1026 | fashion1026 — sex=2, file=Player/Avatar/nv40_tou.png, hidden=0, skill=0 |
| 1027 | fashion1027 — sex=2, file=Player/Avatar/nv44_tou.png, hidden=0, skill=0 |
| 1028 | fashion1028 — sex=2, file=Player/Avatar/nv15_tou.png, hidden=0, skill=0 |
| 1029 | fashion1029 — sex=2, file=Player/Avatar/nv41_tou.png, hidden=0, skill=0 |
| 1030 | fashion1030 — sex=2, file=Player/Avatar/nv21_tou.png, hidden=0, skill=0 |
| 1031 | fashion1031 — sex=2, file=Player/Avatar/nan37_tou.png, hidden=0, skill=0 |
| 1032 | fashion1032 — sex=2, file=Player/Avatar/nan23_tou.png, hidden=0, skill=0 |
| 1033 | fashion1033 — sex=2, file=Player/Avatar/nv39_tou.png, hidden=1, skill=0 |
| 1034 | fashion1034 — sex=2, file=Player/Avatar/nv42_tou.png, hidden=1, skill=0 |
| 1035 | fashion1035 — sex=2, file=Player/Avatar/nv43_tou.png, hidden=1, skill=0 |
| 1036 | fashion1036 — sex=2, file=Player/Avatar/nan22_tou.png, hidden=1, skill=0 |
| 1037 | fashion1037 — sex=2, file=Player/Avatar/nan25_tou.png, hidden=1, skill=0 |
| 1038 | fashion1038 — sex=2, file=Player/Avatar/nv26_tou.png, hidden=1, skill=0 |
| 1039 | fashion1039 — sex=2, file=Player/Avatar/nv29_tou.png, hidden=1, skill=0 |
| 1040 | fashion1040 — sex=2, file=Player/Avatar/nan30_tou.png, hidden=1, skill=0 |
| 1041 | fashion1041 — sex=2, file=Player/Avatar/nv24_tou.png, hidden=1, skill=0 |
| 1042 | fashion1042 — sex=2, file=Player/Avatar/nan27_tou.png, hidden=1, skill=0 |
| 1043 | fashion1043 — sex=2, file=Player/Avatar/nv28_tou.png, hidden=1, skill=0 |
| 1044 | fashion1044 — sex=2, file=Player/Avatar/nv31_tou.png, hidden=1, skill=0 |
| 1045 | fashion1045 — sex=2, file=Player/Avatar/nv14_tou.png, hidden=1, skill=0 |
| 1046 | fashion1046 — sex=2, file=Player/Avatar/nan32_tou.png, hidden=0, skill=0 |
| 1047 | fashion1047 — sex=2, file=Player/Avatar/nan3_tou.png, hidden=1, skill=0 |
| 1048 | fashion1048 — sex=2, file=Player/Avatar/nv13_tou.png, hidden=1, skill=0 |
| 1049 | fashion1049 — sex=2, file=Player/Avatar/nan14_tou.png, hidden=0, skill=0 |
| 1050 | fashion1050 — sex=2, file=Player/Avatar/nv45_tou.png, hidden=1, skill=0 |
| 1051 | fashion1051 — sex=2, file=Player/Avatar/nan28_tou.png, hidden=1, skill=0 |
| 1052 | fashion1052 — sex=2, file=Player/Avatar/nan29_tou.png, hidden=1, skill=0 |
| 1053 | fashion1053 — sex=2, file=Player/Avatar/nan38_tou.png, hidden=1, skill=0 |
| 1054 | fashion1054 — sex=2, file=Player/Avatar/nan39_tou.png, hidden=1, skill=0 |
| 1055 | fashion1055 — sex=2, file=Player/Avatar/nv36_tou.png, hidden=1, skill=0 |
| 1056 | fashion1056 — sex=2, file=Player/Avatar/nv47_tou.png, hidden=1, skill=0 |
| 1057 | fashion1057 — sex=2, file=Player/Avatar/nv57_tou.png, hidden=0, skill=0 |
| 1058 | fashion1058 — sex=2, file=Player/Avatar/nv58_tou.png, hidden=0, skill=0 |
| 1059 | fashion1059 — sex=2, file=Player/Avatar/nv59_tou.png, hidden=0, skill=0 |
| 1060 | fashion1060 — sex=2, file=Player/Avatar/nan26_tou.png, hidden=1, skill=0 |
| 1061 | fashion1061 — sex=2, file=Player/Avatar/nv61_tou.png, hidden=1, skill=0 |
| 1062 | fashion1062 — sex=2, file=Player/Avatar/nan33_tou.png, hidden=0, skill=0 |
| 1063 | fashion1063 — sex=2, file=Player/Avatar/nan48_tou.png, hidden=1, skill=0 |
| 1064 | fashion1064 — sex=2, file=Player/Avatar/nan60_tou.png, hidden=1, skill=0 |
| 1065 | fashion1065 — sex=2, file=Player/Avatar/nv46_tou.png, hidden=1, skill=0 |
| 1066 | fashion1066 — sex=2, file=Player/Avatar/nv66_tou.png, hidden=0, skill=0 |
| 1072 | fashion1072 — sex=2, file=Player/Avatar/nv67_tou.png, hidden=0, skill=0 |
| 1073 | fashion1073 — sex=2, file=Player/Avatar/nan61_tou.png, hidden=0, skill=0 |
| 1074 | fashion1074 — sex=2, file=Player/Avatar/nv68_tou.png, hidden=1, skill=0 |
| 1075 | fashion1075 — sex=2, file=Player/Avatar/nan62_tou.png, hidden=1, skill=0 |
| 1076 | fashion1076 — sex=2, file=Player/Avatar/nv69_tou.png, hidden=1, skill=0 |
| 1077 | fashion1077 — sex=2, file=Player/Avatar/nan63_tou.png, hidden=1, skill=0 |
| 2001 | fashion2001 — sex=2, file=Player/Avatar/nv1_shangyi.png, hidden=0, skill=0 |
| 2002 | fashion2002 — sex=2, file=Player/Avatar/nv2_shangyi.png, hidden=0, skill=0 |
| 2003 | fashion2003 — sex=2, file=Player/Avatar/nv3_shangyi.png, hidden=0, skill=0 |
| 2004 | fashion2004 — sex=2, file=Player/Avatar/nan1_shangyi.png, hidden=0, skill=0 |
| 2005 | fashion2005 — sex=2, file=Player/Avatar/nan8_shangyi.png, hidden=0, skill=0 |
| 2006 | fashion2006 — sex=2, file=Player/Avatar/nan12_shangyi.png, hidden=0, skill=0 |
| 2007 | fashion2007 — sex=2, file=Player/Avatar/nan6_shangyi.png, hidden=0, skill=0 |
| 2008 | fashion2008 — sex=2, file=Player/Avatar/nv4_shangyi.png, hidden=0, skill=0 |
| 2009 | fashion2009 — sex=2, file=Player/Avatar/nv10_shangyi.png, hidden=0, skill=0 |
| 2010 | fashion2010 — sex=2, file=Player/Avatar/nv7_shangyi.png, hidden=0, skill=0 |
| 2011 | fashion2011 — sex=2, file=Player/Avatar/nan9_shangyi.png, hidden=0, skill=0 |
| 2012 | fashion2012 — sex=2, file=Player/Avatar/nan2_shangyi.png, hidden=0, skill=0 |
| 2013 | fashion2013 — sex=2, file=Player/Avatar/nan4_shangyi.png, hidden=0, skill=0 |
| 2014 | fashion2014 — sex=2, file=Player/Avatar/nan13_shangyi.png, hidden=0, skill=0 |
| 2015 | fashion2015 — sex=2, file=Player/Avatar/nan17_shangyi.png, hidden=0, skill=0 |
| 2016 | fashion2016 — sex=2, file=Player/Avatar/nv16_shangyi.png, hidden=0, skill=0 |
| 2017 | fashion2017 — sex=2, file=Player/Avatar/nv19_shangyi.png, hidden=0, skill=0 |
| 2018 | fashion2018 — sex=2, file=Player/Avatar/nan18_shangyi.png, hidden=0, skill=0 |
| 2019 | fashion2019 — sex=2, file=Player/Avatar/nv33_shangyi.png, hidden=0, skill=0 |
| 2020 | fashion2020 — sex=2, file=Player/Avatar/nan34_shangyi.png, hidden=0, skill=0 |
| 2021 | fashion2021 — sex=2, file=Player/Avatar/nan35_shangyi.png, hidden=0, skill=0 |
| 2022 | fashion2022 — sex=2, file=Player/Avatar/nv11_shangyi.png, hidden=0, skill=0 |
| 2023 | fashion2023 — sex=2, file=Player/Avatar/nan36_shangyi.png, hidden=0, skill=0 |
| 2024 | fashion2024 — sex=2, file=Player/Avatar/nan20_shangyi.png, hidden=0, skill=0 |
| 2025 | fashion2025 — sex=2, file=Player/Avatar/nv38_shangyi.png, hidden=0, skill=0 |
| 2026 | fashion2026 — sex=2, file=Player/Avatar/nv40_shangyi.png, hidden=0, skill=0 |
| 2027 | fashion2027 — sex=2, file=Player/Avatar/nv44_shangyi.png, hidden=0, skill=0 |
| 2028 | fashion2028 — sex=2, file=Player/Avatar/nv15_shangyi.png, hidden=0, skill=0 |
| 2029 | fashion2029 — sex=2, file=Player/Avatar/nv41_shangyi.png, hidden=0, skill=0 |
| 2030 | fashion2030 — sex=2, file=Player/Avatar/nv21_shangyi.png, hidden=0, skill=0 |
| 2031 | fashion2031 — sex=2, file=Player/Avatar/nan37_shangyi.png, hidden=0, skill=0 |
| 2032 | fashion2032 — sex=2, file=Player/Avatar/nan23_shangyi.png, hidden=0, skill=0 |
| 2033 | fashion2033 — sex=2, file=Player/Avatar/nv39_shangyi.png, hidden=1, skill=0 |
| 2034 | fashion2034 — sex=2, file=Player/Avatar/nv42_shangyi.png, hidden=1, skill=0 |
| 2035 | fashion2035 — sex=2, file=Player/Avatar/nv43_shangyi.png, hidden=1, skill=0 |
| 2036 | fashion2036 — sex=2, file=Player/Avatar/nan22_shangyi.png, hidden=1, skill=0 |
| 2037 | fashion2037 — sex=2, file=Player/Avatar/nan25_shangyi.png, hidden=1, skill=0 |
| 2038 | fashion2038 — sex=2, file=Player/Avatar/nv26_shangyi.png, hidden=1, skill=0 |
| 2039 | fashion2039 — sex=2, file=Player/Avatar/nv29_shangyi.png, hidden=1, skill=0 |
| 2040 | fashion2040 — sex=2, file=Player/Avatar/nan30_shangyi.png, hidden=1, skill=0 |
| 2041 | fashion2041 — sex=2, file=Player/Avatar/nv24_shangyi.png, hidden=1, skill=0 |
| 2042 | fashion2042 — sex=2, file=Player/Avatar/nan27_shangyi.png, hidden=1, skill=0 |
| 2043 | fashion2043 — sex=2, file=Player/Avatar/nv28_shangyi.png, hidden=1, skill=0 |
| 2044 | fashion2044 — sex=2, file=Player/Avatar/nv31_shangyi.png, hidden=1, skill=0 |
| 2045 | fashion2045 — sex=2, file=Player/Avatar/nv14_shangyi.png, hidden=1, skill=0 |
| 2046 | fashion2046 — sex=2, file=Player/Avatar/nan32_shangyi.png, hidden=0, skill=0 |
| 2047 | fashion2047 — sex=2, file=Player/Avatar/nan3_shangyi.png, hidden=1, skill=0 |
| 2048 | fashion2048 — sex=2, file=Player/Avatar/nv13_shangyi.png, hidden=1, skill=0 |
| 2049 | fashion2049 — sex=2, file=Player/Avatar/nan14_shangyi.png, hidden=0, skill=0 |
| 2050 | fashion2050 — sex=2, file=Player/Avatar/nv45_shangyi.png, hidden=1, skill=0 |
| 2051 | fashion2051 — sex=2, file=Player/Avatar/nan28_shangyi.png, hidden=1, skill=0 |
| 2052 | fashion2052 — sex=2, file=Player/Avatar/nan29_shangyi.png, hidden=1, skill=0 |
| 2053 | fashion2053 — sex=2, file=Player/Avatar/nan38_shangyi.png, hidden=1, skill=0 |
| 2054 | fashion2054 — sex=2, file=Player/Avatar/nan39_shangyi.png, hidden=1, skill=0 |
| 2055 | fashion2055 — sex=2, file=Player/Avatar/nv36_shangyi.png, hidden=1, skill=0 |
| 2056 | fashion2056 — sex=2, file=Player/Avatar/nv47_shangyi.png, hidden=1, skill=0 |
| 2057 | fashion2057 — sex=2, file=Player/Avatar/nv57_shangyi.png, hidden=0, skill=0 |
| 2058 | fashion2058 — sex=2, file=Player/Avatar/nv58_shangyi.png, hidden=0, skill=0 |
| 2059 | fashion2059 — sex=2, file=Player/Avatar/nv59_shangyi.png, hidden=0, skill=0 |
| 2060 | fashion2060 — sex=2, file=Player/Avatar/nan26_shangyi.png, hidden=1, skill=0 |
| 2061 | fashion2061 — sex=2, file=Player/Avatar/nv61_shangyi.png, hidden=1, skill=0 |
| 2062 | fashion2062 — sex=2, file=Player/Avatar/nan33_shangyi.png, hidden=0, skill=0 |
| 2063 | fashion2063 — sex=2, file=Player/Avatar/nan48_shangyi.png, hidden=1, skill=0 |
| 2064 | fashion2064 — sex=2, file=Player/Avatar/nan60_shangyi.png, hidden=1, skill=0 |
| 2065 | fashion2065 — sex=2, file=Player/Avatar/nv46_shangyi.png, hidden=1, skill=0 |
| 2066 | fashion2066 — sex=2, file=Player/Avatar/nv66_shangyi.png, hidden=0, skill=0 |
| 2072 | fashion2072 — sex=2, file=Player/Avatar/nv67_shangyi.png, hidden=0, skill=0 |
| 2073 | fashion2073 — sex=2, file=Player/Avatar/nan61_shangyi.png, hidden=0, skill=0 |
| 2074 | fashion2074 — sex=2, file=Player/Avatar/nv68_shangyi.png, hidden=1, skill=0 |
| 2075 | fashion2075 — sex=2, file=Player/Avatar/nan62_shangyi.png, hidden=1, skill=0 |
| 2076 | fashion2076 — sex=2, file=Player/Avatar/nv69_shangyi.png, hidden=1, skill=0 |
| 2077 | fashion2077 — sex=2, file=Player/Avatar/nan63_shangyi.png, hidden=1, skill=0 |
| 3001 | fashion3001 — sex=2, file=Player/Avatar/nv1_xia.png, hidden=0, skill=0 |
| 3002 | fashion3002 — sex=2, file=Player/Avatar/nv2_xia.png, hidden=0, skill=0 |
| 3003 | fashion3003 — sex=2, file=Player/Avatar/nv3_xia.png, hidden=0, skill=0 |
| 3004 | fashion3004 — sex=2, file=Player/Avatar/nan1_xia.png, hidden=0, skill=0 |
| 3005 | fashion3005 — sex=2, file=Player/Avatar/nan8_xia.png, hidden=0, skill=0 |
| 3006 | fashion3006 — sex=2, file=Player/Avatar/nan12_xia.png, hidden=0, skill=0 |
| 3007 | fashion3007 — sex=2, file=Player/Avatar/nan6_xia.png, hidden=0, skill=0 |
| 3008 | fashion3008 — sex=2, file=Player/Avatar/nv4_xia.png, hidden=0, skill=0 |
| 3009 | fashion3009 — sex=2, file=Player/Avatar/nv10_xia.png, hidden=0, skill=0 |
| 3010 | fashion3010 — sex=2, file=Player/Avatar/nv7_xia.png, hidden=0, skill=0 |
| 3011 | fashion3011 — sex=2, file=Player/Avatar/nan9_xia.png, hidden=0, skill=0 |
| 3012 | fashion3012 — sex=2, file=Player/Avatar/nan2_xia.png, hidden=0, skill=0 |
| 3013 | fashion3013 — sex=2, file=Player/Avatar/nan4_xia.png, hidden=0, skill=0 |
| 3014 | fashion3014 — sex=2, file=Player/Avatar/nan13_xia.png, hidden=0, skill=0 |
| 3015 | fashion3015 — sex=2, file=Player/Avatar/nan17_xia.png, hidden=0, skill=0 |
| 3016 | fashion3016 — sex=2, file=Player/Avatar/nv16_xia.png, hidden=0, skill=0 |
| 3017 | fashion3017 — sex=2, file=Player/Avatar/nv19_xia.png, hidden=0, skill=0 |
| 3018 | fashion3018 — sex=2, file=Player/Avatar/nan18_xia.png, hidden=0, skill=0 |
| 3019 | fashion3019 — sex=2, file=Player/Avatar/nv33_xia.png, hidden=0, skill=0 |
| 3020 | fashion3020 — sex=2, file=Player/Avatar/nan34_xia.png, hidden=0, skill=0 |
| 3021 | fashion3021 — sex=2, file=Player/Avatar/nan35_xia.png, hidden=0, skill=0 |
| 3022 | fashion3022 — sex=2, file=Player/Avatar/nv11_xia.png, hidden=0, skill=0 |
| 3023 | fashion3023 — sex=2, file=Player/Avatar/nan36_xia.png, hidden=0, skill=0 |
| 3024 | fashion3024 — sex=2, file=Player/Avatar/nan20_xia.png, hidden=0, skill=0 |
| 3025 | fashion3025 — sex=2, file=Player/Avatar/nv38_xia.png, hidden=0, skill=0 |
| 3026 | fashion3026 — sex=2, file=Player/Avatar/nv40_xia.png, hidden=0, skill=0 |
| 3027 | fashion3027 — sex=2, file=Player/Avatar/nv44_xia.png, hidden=0, skill=0 |
| 3028 | fashion3028 — sex=2, file=Player/Avatar/nv15_xia.png, hidden=0, skill=0 |
| 3029 | fashion3029 — sex=2, file=Player/Avatar/nv41_xia.png, hidden=0, skill=0 |
| 3030 | fashion3030 — sex=2, file=Player/Avatar/nv21_xia.png, hidden=0, skill=0 |
| 3031 | fashion3031 — sex=2, file=Player/Avatar/nan37_xia.png, hidden=0, skill=0 |
| 3032 | fashion3032 — sex=2, file=Player/Avatar/nan23_xia.png, hidden=0, skill=0 |
| 3033 | fashion3033 — sex=2, file=Player/Avatar/nv39_xia.png, hidden=1, skill=0 |
| 3034 | fashion3034 — sex=2, file=Player/Avatar/nv42_xia.png, hidden=1, skill=0 |
| 3035 | fashion3035 — sex=2, file=Player/Avatar/nv43_xia.png, hidden=1, skill=0 |
| 3036 | fashion3036 — sex=2, file=Player/Avatar/nan22_xia.png, hidden=1, skill=0 |
| 3037 | fashion3037 — sex=2, file=Player/Avatar/nan25_xia.png, hidden=1, skill=0 |
| 3038 | fashion3038 — sex=2, file=Player/Avatar/nv26_xia.png, hidden=1, skill=0 |
| 3039 | fashion3039 — sex=2, file=Player/Avatar/nv29_xia.png, hidden=1, skill=0 |
| 3040 | fashion3040 — sex=2, file=Player/Avatar/nan30_xia.png, hidden=1, skill=0 |
| 3041 | fashion3041 — sex=2, file=Player/Avatar/nv24_xia.png, hidden=1, skill=0 |
| 3042 | fashion3042 — sex=2, file=Player/Avatar/nan27_xia.png, hidden=1, skill=0 |
| 3043 | fashion3043 — sex=2, file=Player/Avatar/nv28_xia.png, hidden=1, skill=0 |
| 3044 | fashion3044 — sex=2, file=Player/Avatar/nv31_xia.png, hidden=1, skill=0 |
| 3045 | fashion3045 — sex=2, file=Player/Avatar/nv14_xia.png, hidden=1, skill=0 |
| 3046 | fashion3046 — sex=2, file=Player/Avatar/nan32_xia.png, hidden=0, skill=0 |
| 3047 | fashion3047 — sex=2, file=Player/Avatar/nan3_xia.png, hidden=1, skill=0 |
| 3048 | fashion3048 — sex=2, file=Player/Avatar/nv13_xia.png, hidden=1, skill=0 |
| 3049 | fashion3049 — sex=2, file=Player/Avatar/nan14_xia.png, hidden=0, skill=0 |
| 3050 | fashion3050 — sex=2, file=Player/Avatar/nv45_xia.png, hidden=1, skill=0 |
| 3051 | fashion3051 — sex=2, file=Player/Avatar/nan28_xia.png, hidden=1, skill=0 |
| 3052 | fashion3052 — sex=2, file=Player/Avatar/nan29_xia.png, hidden=1, skill=0 |
| 3053 | fashion3053 — sex=2, file=Player/Avatar/nan38_xia.png, hidden=1, skill=0 |
| 3054 | fashion3054 — sex=2, file=Player/Avatar/nan39_xia.png, hidden=1, skill=0 |
| 3055 | fashion3055 — sex=2, file=Player/Avatar/nv36_xia.png, hidden=1, skill=0 |
| 3056 | fashion3056 — sex=2, file=Player/Avatar/nv47_xia.png, hidden=1, skill=0 |
| 3057 | fashion3057 — sex=2, file=Player/Avatar/nv57_xia.png, hidden=0, skill=0 |
| 3058 | fashion3058 — sex=2, file=Player/Avatar/nv58_xia.png, hidden=0, skill=0 |
| 3059 | fashion3059 — sex=2, file=Player/Avatar/nv59_xia.png, hidden=0, skill=0 |
| 3060 | fashion3060 — sex=2, file=Player/Avatar/nan26_xia.png, hidden=1, skill=0 |
| 3061 | fashion3061 — sex=2, file=Player/Avatar/nv61_xia.png, hidden=1, skill=0 |
| 3062 | fashion3062 — sex=2, file=Player/Avatar/nan33_xia.png, hidden=0, skill=0 |
| 3063 | fashion3063 — sex=2, file=Player/Avatar/nan48_xia.png, hidden=1, skill=0 |
| 3064 | fashion3064 — sex=2, file=Player/Avatar/nan60_xia.png, hidden=1, skill=0 |
| 3065 | fashion3065 — sex=2, file=Player/Avatar/nv46_xia.png, hidden=1, skill=0 |
| 3066 | fashion3066 — sex=2, file=Player/Avatar/nv66_xia.png, hidden=0, skill=0 |
| 3072 | fashion3072 — sex=2, file=Player/Avatar/nv67_xia.png, hidden=0, skill=0 |
| 3073 | fashion3073 — sex=2, file=Player/Avatar/nan61_xia.png, hidden=0, skill=0 |
| 3074 | fashion3074 — sex=2, file=Player/Avatar/nv68_xia.png, hidden=1, skill=0 |
| 3075 | fashion3075 — sex=2, file=Player/Avatar/nan62_xia.png, hidden=1, skill=0 |
| 3076 | fashion3076 — sex=2, file=Player/Avatar/nv69_xia.png, hidden=1, skill=0 |
| 3077 | fashion3077 — sex=2, file=Player/Avatar/nan63_xia.png, hidden=1, skill=0 |
| 4001 | fashion4001 — sex=2, file=Player/Avatar/nv1_bei.png, hidden=0, skill=63021 |
| 4002 | fashion4002 — sex=2, file=Player/Avatar/nv7_bei.png, hidden=0, skill=63061 |
| 4003 | fashion4003 — sex=2, file=Player/Avatar/nv3_bei.png, hidden=0, skill=62031 |
| 4004 | fashion4004 — sex=2, file=Player/Avatar/nv13_bei.png, hidden=0, skill=63101 |
| 4005 | fashion4005 — sex=2, file=Player/Avatar/nan25_bei.png, hidden=0, skill=62071 |
| 4006 | fashion4006 — sex=2, file=Player/Avatar/nan34_bei.png, hidden=0, skill=63041 |
| 4007 | fashion4007 — sex=2, file=Player/Avatar/nan1_bei.png, hidden=0, skill=63081 |
| 4008 | fashion4008 — sex=2, file=Player/Avatar/nv41_bei.png, hidden=0, skill=62011 |
| 4009 | fashion4009 — sex=2, file=Player/Avatar/nan20_bei.png, hidden=0, skill=62091 |
| 4010 | fashion4010 — sex=2, file=Player/Avatar/nan18_bei.png, hidden=0, skill=62051 |
| 4011 | fashion4011 — sex=2, file=Player/Avatar/nan9_bei.png, hidden=1, skill=0 |
| 4012 | fashion4012 — sex=2, file=Player/Avatar/nan6_bei.png, hidden=1, skill=0 |
| 4022 | fashion4022 — sex=2, file=Player/Avatar/nv11_bei.png, hidden=1, skill=0 |
| 4023 | fashion4023 — sex=2, file=Player/Avatar/nan36_bei.png, hidden=1, skill=0 |
| 4026 | fashion4026 — sex=2, file=Player/Avatar/nv40_bei.png, hidden=1, skill=0 |
| 4027 | fashion4027 — sex=2, file=Player/Avatar/nv44_bei.png, hidden=1, skill=0 |
| 4031 | fashion4031 — sex=2, file=Player/Avatar/nan37_bei.png, hidden=1, skill=0 |
| 4033 | fashion4033 — sex=2, file=Player/Avatar/nv39_bei.png, hidden=0, skill=64265 |
| 4046 | fashion4046 — sex=2, file=Player/Avatar/nan32_bei.png, hidden=0, skill=64263 |
| 4047 | fashion4047 — sex=2, file=Player/Avatar/nan3_bei.png, hidden=0, skill=64263 |
| 4057 | fashion4057 — sex=2, file=Player/Avatar/nv57_bei.png, hidden=0, skill=64264 |
| 4058 | fashion4058 — sex=2, file=Player/Avatar/nv58_bei.png, hidden=0, skill=64263 |
| 4066 | fashion4066 — sex=2, file=Player/Avatar/nv66_bei.png, hidden=0, skill=63101 |
| 4072 | fashion4072 — sex=2, file=Player/Avatar/nv67_bei.png, hidden=0, skill=63101 |
| 4073 | fashion4073 — sex=2, file=Player/Avatar/nan61_bei.png, hidden=0, skill=62101 |
| 4074 | fashion4074 — sex=2, file=Player/Avatar/nv68_bei.png, hidden=1, skill=63111 |
| 4075 | fashion4075 — sex=2, file=Player/Avatar/nan62_bei.png, hidden=1, skill=62111 |
| 4076 | fashion4076 — sex=2, file=Player/Avatar/nv69_bei.png, hidden=1, skill=63111 |
| 4077 | fashion4077 — sex=2, file=Player/Avatar/nan63_bei.png, hidden=1, skill=62111 |
| 5001 | fashion5001 — sex=2, file=Player/Avatar/nv1_wuqi.png, hidden=0, skill=60011 |
| 5002 | fashion5002 — sex=2, file=Player/Avatar/nv2_wuqi.png, hidden=0, skill=60051 |
| 5003 | fashion5003 — sex=2, file=Player/Avatar/nv3_wuqi.png, hidden=0, skill=61061 |
| 5004 | fashion5004 — sex=2, file=Player/Avatar/nv10_wuqi.png, hidden=0, skill=61071 |
| 5005 | fashion5005 — sex=2, file=Player/Avatar/nan6_wuqi.png, hidden=0, skill=61021 |
| 5006 | fashion5006 — sex=2, file=Player/Avatar/nan4_wuqi.png, hidden=0, skill=60071 |
| 5007 | fashion5007 — sex=2, file=Player/Avatar/nan8_wuqi.png, hidden=0, skill=61081 |
| 5008 | fashion5008 — sex=2, file=Player/Avatar/nv4_wuqi.png, hidden=0, skill=61041 |
| 5009 | fashion5009 — sex=2, file=Player/Avatar/nan20_wuqi.png, hidden=0, skill=60081 |
| 5010 | fashion5010 — sex=2, file=Player/Avatar/nv14_wuqi.png, hidden=0, skill=60091 |
| 5011 | fashion5011 — sex=2, file=Player/Avatar/nan12_wuqi.png, hidden=0, skill=61101 |
| 5012 | fashion5012 — sex=2, file=Player/Avatar/nan2_wuqi.png, hidden=0, skill=60031 |
| 5013 | fashion5013 — sex=2, file=Player/Avatar/nan18_wuqi.png, hidden=0, skill=61091 |
| 5014 | fashion5014 — sex=2, file=Player/Avatar/nan13_wuqi.png, hidden=0, skill=60101 |
| 5015 | fashion5015 — sex=2, file=Player/Avatar/nan1_wuqi.png, hidden=1, skill=0 |
| 5016 | fashion5016 — sex=2, file=Player/Avatar/nv40_wuqi.png, hidden=1, skill=0 |
| 5019 | fashion5019 — sex=2, file=Player/Avatar/nv33_wuqi.png, hidden=1, skill=0 |
| 5020 | fashion5020 — sex=2, file=Player/Avatar/nan34_wuqi.png, hidden=0, skill=64271 |
| 5021 | fashion5021 — sex=2, file=Player/Avatar/nan35_wuqi.png, hidden=1, skill=0 |
| 5023 | fashion5023 — sex=2, file=Player/Avatar/nan36_wuqi.png, hidden=0, skill=61091 |
| 5024 | fashion5024 — sex=2, file=Player/Avatar/nv38_wuqi.png, hidden=1, skill=0 |
| 5027 | fashion5027 — sex=2, file=Player/Avatar/nv44_wuqi.png, hidden=0, skill=0 |
| 5029 | fashion5029 — sex=2, file=Player/Avatar/nv41_wuqi.png, hidden=1, skill=0 |
| 5031 | fashion5031 — sex=2, file=Player/Avatar/nan37_wuqi.png, hidden=1, skill=0 |
| 5033 | fashion5033 — sex=2, file=Player/Avatar/nv39_wuqi.png, hidden=0, skill=64321 |
| 5034 | fashion5034 — sex=2, file=Player/Avatar/nv42_wuqi.png, hidden=1, skill=60101 |
| 5035 | fashion5035 — sex=2, file=Player/Avatar/nv43_wuqi.png, hidden=1, skill=0 |
| 5037 | fashion5037 — sex=2, file=Player/Avatar/nan25_wuqi.png, hidden=0, skill=64271 |
| 5048 | fashion5048 — sex=2, file=Player/Avatar/nv13_wuqi.png, hidden=1, skill=0 |
| 5050 | fashion5050 — sex=2, file=Player/Avatar/nv45_wuqi.png, hidden=1, skill=0 |
| 5057 | fashion5057 — sex=2, file=Player/Avatar/nv57_wuqi.png, hidden=0, skill=64271 |
| 5058 | fashion5058 — sex=2, file=Player/Avatar/nv58_wuqi.png, hidden=0, skill=64311 |
| 5066 | fashion5066 — sex=2, file=Player/Avatar/nv66_wuqi.png, hidden=0, skill=61101 |
| 5072 | fashion5072 — sex=2, file=Player/Avatar/nv67_wuqi.png, hidden=0, skill=60101 |
| 5073 | fashion5073 — sex=2, file=Player/Avatar/nan61_wuqi.png, hidden=0, skill=61101 |
| 5074 | fashion5074 — sex=2, file=Player/Avatar/nv68_wuqi.png, hidden=1, skill=61111 |
| 5075 | fashion5075 — sex=2, file=Player/Avatar/nan62_wuqi.png, hidden=1, skill=60111 |
| 5076 | fashion5076 — sex=2, file=Player/Avatar/nv69_wuqi.png, hidden=1, skill=60111 |
| 5077 | fashion5077 — sex=2, file=Player/Avatar/nan63_wuqi.png, hidden=1, skill=61111 |

### Role level and EXP table (100 records)

Source: `apk_extracted/assets/res/Config/ExperienceInfo.dat`.

| ID | Configured data |
|---:|---|
| 1 |  — roleExp=60, powerCap=80, levelPower=20, petLevelMax=1 |
| 2 |  — roleExp=140, powerCap=83, levelPower=20, petLevelMax=2 |
| 3 |  — roleExp=240, powerCap=86, levelPower=20, petLevelMax=3 |
| 4 |  — roleExp=360, powerCap=89, levelPower=20, petLevelMax=4 |
| 5 |  — roleExp=510, powerCap=92, levelPower=20, petLevelMax=5 |
| 6 |  — roleExp=700, powerCap=95, levelPower=25, petLevelMax=6 |
| 7 |  — roleExp=950, powerCap=98, levelPower=25, petLevelMax=7 |
| 8 |  — roleExp=1250, powerCap=101, levelPower=25, petLevelMax=8 |
| 9 |  — roleExp=1690, powerCap=104, levelPower=25, petLevelMax=9 |
| 10 |  — roleExp=2200, powerCap=107, levelPower=25, petLevelMax=10 |
| 11 |  — roleExp=2780, powerCap=110, levelPower=30, petLevelMax=11 |
| 12 |  — roleExp=3450, powerCap=113, levelPower=30, petLevelMax=12 |
| 13 |  — roleExp=4220, powerCap=116, levelPower=30, petLevelMax=13 |
| 14 |  — roleExp=5080, powerCap=119, levelPower=30, petLevelMax=14 |
| 15 |  — roleExp=6050, powerCap=122, levelPower=30, petLevelMax=15 |
| 16 |  — roleExp=7120, powerCap=125, levelPower=35, petLevelMax=16 |
| 17 |  — roleExp=8310, powerCap=128, levelPower=35, petLevelMax=17 |
| 18 |  — roleExp=9640, powerCap=131, levelPower=35, petLevelMax=18 |
| 19 |  — roleExp=11120, powerCap=134, levelPower=35, petLevelMax=19 |
| 20 |  — roleExp=12760, powerCap=137, levelPower=35, petLevelMax=20 |
| 21 |  — roleExp=14530, powerCap=140, levelPower=40, petLevelMax=21 |
| 22 |  — roleExp=16450, powerCap=143, levelPower=40, petLevelMax=22 |
| 23 |  — roleExp=18520, powerCap=146, levelPower=40, petLevelMax=23 |
| 24 |  — roleExp=20750, powerCap=149, levelPower=40, petLevelMax=24 |
| 25 |  — roleExp=23150, powerCap=150, levelPower=40, petLevelMax=25 |
| 26 |  — roleExp=25740, powerCap=150, levelPower=50, petLevelMax=26 |
| 27 |  — roleExp=28520, powerCap=150, levelPower=50, petLevelMax=27 |
| 28 |  — roleExp=31510, powerCap=150, levelPower=50, petLevelMax=28 |
| 29 |  — roleExp=34730, powerCap=150, levelPower=50, petLevelMax=29 |
| 30 |  — roleExp=38190, powerCap=150, levelPower=50, petLevelMax=30 |
| 31 |  — roleExp=41910, powerCap=150, levelPower=60, petLevelMax=31 |
| 32 |  — roleExp=45910, powerCap=150, levelPower=60, petLevelMax=32 |
| 33 |  — roleExp=50200, powerCap=150, levelPower=60, petLevelMax=33 |
| 34 |  — roleExp=54820, powerCap=150, levelPower=60, petLevelMax=34 |
| 35 |  — roleExp=59780, powerCap=150, levelPower=60, petLevelMax=35 |
| 36 |  — roleExp=65110, powerCap=150, levelPower=70, petLevelMax=36 |
| 37 |  — roleExp=70840, powerCap=150, levelPower=70, petLevelMax=37 |
| 38 |  — roleExp=77000, powerCap=150, levelPower=70, petLevelMax=38 |
| 39 |  — roleExp=83630, powerCap=150, levelPower=70, petLevelMax=39 |
| 40 |  — roleExp=90760, powerCap=150, levelPower=70, petLevelMax=40 |
| 41 |  — roleExp=98260, powerCap=150, levelPower=80, petLevelMax=41 |
| 42 |  — roleExp=106260, powerCap=150, levelPower=80, petLevelMax=42 |
| 43 |  — roleExp=114960, powerCap=150, levelPower=80, petLevelMax=43 |
| 44 |  — roleExp=124260, powerCap=150, levelPower=80, petLevelMax=44 |
| 45 |  — roleExp=134360, powerCap=150, levelPower=80, petLevelMax=45 |
| 46 |  — roleExp=145260, powerCap=150, levelPower=90, petLevelMax=46 |
| 47 |  — roleExp=156960, powerCap=150, levelPower=90, petLevelMax=47 |
| 48 |  — roleExp=169660, powerCap=150, levelPower=90, petLevelMax=48 |
| 49 |  — roleExp=183360, powerCap=150, levelPower=90, petLevelMax=49 |
| 50 |  — roleExp=198160, powerCap=150, levelPower=90, petLevelMax=50 |
| 51 |  — roleExp=214060, powerCap=150, levelPower=100, petLevelMax=51 |
| 52 |  — roleExp=231260, powerCap=150, levelPower=100, petLevelMax=52 |
| 53 |  — roleExp=249860, powerCap=150, levelPower=100, petLevelMax=53 |
| 54 |  — roleExp=269960, powerCap=150, levelPower=100, petLevelMax=54 |
| 55 |  — roleExp=291760, powerCap=150, levelPower=100, petLevelMax=55 |
| 56 |  — roleExp=315260, powerCap=150, levelPower=100, petLevelMax=56 |
| 57 |  — roleExp=340760, powerCap=150, levelPower=100, petLevelMax=57 |
| 58 |  — roleExp=368360, powerCap=150, levelPower=100, petLevelMax=58 |
| 59 |  — roleExp=398160, powerCap=150, levelPower=100, petLevelMax=59 |
| 60 |  — roleExp=430460, powerCap=150, levelPower=100, petLevelMax=60 |
| 61 |  — roleExp=465460, powerCap=150, levelPower=100, petLevelMax=61 |
| 62 |  — roleExp=503360, powerCap=150, levelPower=100, petLevelMax=62 |
| 63 |  — roleExp=544360, powerCap=150, levelPower=100, petLevelMax=63 |
| 64 |  — roleExp=588760, powerCap=150, levelPower=100, petLevelMax=64 |
| 65 |  — roleExp=636860, powerCap=150, levelPower=100, petLevelMax=65 |
| 66 |  — roleExp=689060, powerCap=150, levelPower=100, petLevelMax=66 |
| 67 |  — roleExp=745560, powerCap=150, levelPower=100, petLevelMax=67 |
| 68 |  — roleExp=806860, powerCap=150, levelPower=100, petLevelMax=68 |
| 69 |  — roleExp=873260, powerCap=150, levelPower=100, petLevelMax=69 |
| 70 |  — roleExp=945260, powerCap=150, levelPower=100, petLevelMax=70 |
| 71 |  — roleExp=1023360, powerCap=150, levelPower=100, petLevelMax=71 |
| 72 |  — roleExp=1108060, powerCap=150, levelPower=100, petLevelMax=72 |
| 73 |  — roleExp=1199960, powerCap=150, levelPower=100, petLevelMax=73 |
| 74 |  — roleExp=1299660, powerCap=150, levelPower=100, petLevelMax=74 |
| 75 |  — roleExp=1407760, powerCap=150, levelPower=100, petLevelMax=75 |
| 76 |  — roleExp=1525060, powerCap=150, levelPower=100, petLevelMax=76 |
| 77 |  — roleExp=1652360, powerCap=150, levelPower=100, petLevelMax=77 |
| 78 |  — roleExp=1790560, powerCap=150, levelPower=100, petLevelMax=78 |
| 79 |  — roleExp=1940460, powerCap=150, levelPower=100, petLevelMax=79 |
| 80 |  — roleExp=2103160, powerCap=150, levelPower=100, petLevelMax=80 |
| 81 |  — roleExp=2282220, powerCap=150, levelPower=100, petLevelMax=81 |
| 82 |  — roleExp=2481200, powerCap=150, levelPower=100, petLevelMax=82 |
| 83 |  — roleExp=2703660, powerCap=150, levelPower=100, petLevelMax=83 |
| 84 |  — roleExp=2953160, powerCap=150, levelPower=100, petLevelMax=84 |
| 85 |  — roleExp=3233260, powerCap=150, levelPower=100, petLevelMax=85 |
| 86 |  — roleExp=3547520, powerCap=150, levelPower=100, petLevelMax=86 |
| 87 |  — roleExp=3899500, powerCap=150, levelPower=100, petLevelMax=87 |
| 88 |  — roleExp=4292760, powerCap=150, levelPower=100, petLevelMax=88 |
| 89 |  — roleExp=4730860, powerCap=150, levelPower=100, petLevelMax=89 |
| 90 |  — roleExp=5217360, powerCap=150, levelPower=100, petLevelMax=90 |
| 91 |  — roleExp=5755820, powerCap=150, levelPower=100, petLevelMax=91 |
| 92 |  — roleExp=6349800, powerCap=150, levelPower=100, petLevelMax=92 |
| 93 |  — roleExp=7002860, powerCap=150, levelPower=100, petLevelMax=93 |
| 94 |  — roleExp=7718560, powerCap=150, levelPower=100, petLevelMax=94 |
| 95 |  — roleExp=8500460, powerCap=150, levelPower=100, petLevelMax=95 |
| 96 |  — roleExp=9352120, powerCap=150, levelPower=100, petLevelMax=96 |
| 97 |  — roleExp=10277100, powerCap=150, levelPower=100, petLevelMax=97 |
| 98 |  — roleExp=11278960, powerCap=150, levelPower=100, petLevelMax=98 |
| 99 |  — roleExp=12361260, powerCap=150, levelPower=100, petLevelMax=99 |
| 100 |  — roleExp=13527560, powerCap=150, levelPower=100, petLevelMax=100 |

### In-game shop catalog (5 shop entries, 55 pools)

ShopInfo references configured ShopPoolInfo pools. Currency semantics for the raw price field must be confirmed against the owning shop manager before serving purchases.

| Shop ID | Pool IDs |
|---:|---|
| 1 | [1, 1, 1, 2, 2, 2, 7, 8, 9] |
| 3 | [10, 11, 12, 13, 14, 15, 16, 17, 18] |
| 4 | [19, 20, 21, 22, 23, 24, 25, 26, 27] |
| 5 | [100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113] |
| 6 | [200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213] |

Pool item/price/count catalog:

| Pool | Item IDs | Prices | counts |
|---:|---|---|---|
| 1 | 12020, 12021, 12030, 12031, 12043, 12044, 12045, 12046, 12047, 12052, 12053, 12054, 12020, 12021, 12030, 12031, 12043, 12044, 12045, 12046, 12047, 12052, 12053, 12054 | 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000 | 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 |
| 2 | 12032, 12042, 12048, 12049, 12050, 12051, 12055, 12056, 12057, 12058, 12059, 12060, 12070, 12032, 12042, 12048, 12049, 12050, 12051, 12055, 12056, 12057, 12058, 12059, 12060, 12070 | 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 6000, 6000, 6000, 6000, 6000, 6000, 6000, 6000, 6000, 6000, 6000, 6000, 6000 | 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 |
| 3 | 108, 108, 108, 107, 107, 107, 107, 106, 106, 106, 106, 105, 105, 105, 105 | 400, 1000, 2000, 400, 1000, 2000, 3000, 400, 1000, 2000, 3000, 400, 1000, 2000, 3000 | 2, 5, 10, 2, 5, 10, 15, 2, 5, 10, 15, 2, 5, 10, 15 |
| 4 | 108, 108, 108, 108, 5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7 | 400, 1000, 2000, 3000, 40, 80, 200, 400, 60, 120, 300, 600, 240, 480, 1200 | 2, 5, 10, 15, 1, 2, 5, 10, 1, 2, 5, 10, 1, 2, 5 |
| 5 | 18, 18, 18, 18, 19, 19, 19, 19, 20, 20 | 80, 160, 400, 800, 80, 160, 400, 800, 80, 160 | 1, 2, 5, 10, 1, 2, 5, 10, 1, 2 |
| 6 | 20, 20, 21, 21, 21, 21, 22, 22, 22, 22 | 400, 800, 80, 160, 400, 800, 80, 160, 400, 800 | 5, 10, 1, 2, 5, 10, 1, 2, 5, 10 |
| 7 | 23, 23, 23, 23, 24 | 80, 160, 400, 800, 80 | 1, 2, 5, 10, 1 |
| 8 | 24, 24, 25, 25 | 160, 400, 80, 160 | 2, 5, 1, 2 |
| 9 | 25, 26, 26, 26 | 400, 80, 160, 400 | 5, 1, 2, 5 |
| 10 | 4001, 4002, 4003, 4004, 4005, 4006, 4007, 4008, 4009, 4010, 4011, 4012, 4013, 4014, 4015, 4016, 4017, 4018, 4019, 4020, 4021, 4022, 4023, 4024, 4025, 4026, 4027, 4028, 4029, 4030, 4031, 4325, 4351 | 5000, 5000, 5000, 5000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 80, 80, 80, 80, 80, 5000, 5000 | 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 |
| 11 | 4032, 4033, 4313, 4314, 4034, 4035, 4036, 4037, 4342, 4038, 4312, 4039, 4040, 4041, 4042, 4043, 4044, 4045, 4046, 4047, 4048, 4049, 4050, 4051, 4052, 4053, 4054, 4055, 4056, 4057, 4058, 4059, 4060, 4061, 4062, 4063, 4064, 4065, 4321, 4324, 4345, 4349 | 5000, 5000, 5000, 1000, 5000, 5000, 5000, 5000, 5000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 80, 80, 80, 80, 80, 80, 5000, 5000, 5000, 5000 | 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 |
| 12 | 4066, 4067, 4068, 4069, 4070, 4071, 4072, 4073, 4074, 4075, 4076, 4077, 4078, 4079, 4080, 4081, 4082, 4083, 4084, 4085, 4086, 4087, 4088, 4089, 4090, 4091, 4092, 4093, 4094, 4095, 4096, 4097, 4098, 4347 | 5000, 5000, 5000, 5000, 5000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 80, 80, 80, 80, 80, 5000 | 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 |
| 13 | 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4129, 4343, 4344, 4354, 4355 | 5000, 5000, 5000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 80, 80, 80, 80, 80, 5000, 5000, 5000, 5000 | 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 |
| 14 | 4130, 4131, 4132, 4133, 4134, 4135, 4340, 4136, 4137, 4138, 4139, 4140, 4141, 4142, 4143, 4144, 4145, 4146, 4147, 4148, 4149, 4150, 4151, 4152, 4153, 4154, 4155, 4156, 4157, 4158, 4159, 4160, 4161, 4162, 4350, 4353 | 5000, 5000, 5000, 5000, 5000, 5000, 5000, 1000, 1000, 1000, 1000, 1000, 1000, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 80, 80, 80, 80, 80, 80, 80, 1000, 80, 5000, 5000 | 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 |
| 15 | 4163, 4164, 4165, 4166, 4167, 4168, 4169, 4170, 4171, 4172, 4173, 4174, 4175, 4176, 4177, 4178, 4179, 4180, 4181, 4182, 4183, 4184, 4322, 4323, 4352 | 5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 360, 360, 360, 360, 360, 500, 1200, 5000 | 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 |
| 16 | 4185, 4186, 4187, 4311, 4188, 4189, 4190, 4191, 4192, 4193, 4194, 4195, 4196, 4197, 4198, 4199, 4200, 4201, 4202, 4203, 4204, 4205, 4206, 4207, 4208, 4310, 4209, 4210, 4211, 4212, 4213, 4214, 4215, 4216, 4348 | 5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 360, 360, 360, 360, 360, 360, 360, 360, 360, 1000, 360, 360, 80, 80, 80, 80, 80, 80, 5000 | 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 |
| 17 | 4217, 4218, 4219, 4220, 4221, 4222, 4223, 4224, 4225, 4226, 4227, 4228, 4229, 4230, 4231, 4232, 4233, 4234, 4235, 4236, 4237, 4238, 4239, 4240, 4241, 4242, 4243, 4244, 4245 | 5000, 5000, 5000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 80, 80, 80, 80, 80 | 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 |
| 18 | 4246, 4247, 4248, 4249, 4250, 4251, 4252, 4253, 4254, 4255, 4256, 4257, 4258, 4259, 4260, 4261, 4262, 4263, 4264, 4265, 4266, 4267, 4268, 4269, 4270, 4271, 4272, 4273, 4274, 4275, 4276, 4277, 4278, 4279, 4280, 4281, 4282, 4283, 4284, 4285, 4286, 4287, 4288, 4289, 4290, 4291, 4292, 4293, 4294, 4295, 4296, 4297, 4298, 4299, 4300, 4301, 4302, 4303, 4304, 4305, 4306, 4307, 4308, 4309, 4326, 4327, 4328, 4329, 4330, 4331, 4332, 4333, 4334, 4335, 4336, 4337, 4338, 4339 | 5000, 5000, 5000, 5000, 5000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 360, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000 | 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 |
| 19 | 60007, 60008, 60011, 60012, 60005, 60006 | 50, 125, 50, 125, 60, 40 | 5, 5, 5, 5, 5, 5 |
| 20 | 60001, 60002, 60005, 60006 | 300, 800, 60, 40 | 1, 1, 5, 5 |
| 21 | 50007, 50008, 50009, 50010, 50011, 50012, 50013, 50014, 50015, 50016, 50017, 50018 | 500, 500, 500, 500, 500, 500, 500, 500, 500, 500, 500, 500 | 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 |
| 22 | 60008, 60009, 60012, 60013 | 125, 160, 125, 160 | 5, 5, 5, 5 |
| 23 | 60001, 60002, 60005, 60005, 60006, 60006 | 300, 800, 180, 120, 120, 80 | 1, 1, 15, 10, 15, 10 |
| 24 | 60008, 60009, 60012, 60013 | 200, 250, 200, 250 | 10, 10, 10, 10 |
| 25 | 60001, 60002, 60003, 60005, 60005, 60006, 60006 | 300, 800, 2000, 350, 240, 250, 170 | 1, 1, 1, 30, 20, 30, 20 |
| 26 | 50019, 50020, 50021, 50022, 50023, 50024 | 2000, 2000, 2000, 2000, 2000, 2000 | 1, 1, 1, 1, 1, 1 |
| 27 | 50025, 50026, 50027, 50028, 50029, 50030 | 6000, 6000, 6000, 6000, 6000, 6000 | 1, 1, 1, 1, 1, 1 |
| 100 | 12020, 12021, 12030, 12031, 12043, 12044, 12045, 12046, 12047, 12052, 274, 384, 326 | 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 100, 150, 500 | 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 1, 1, 1 |
| 101 | 12020 | 100 | 4 |
| 102 | 12021 | 100 | 4 |
| 103 | 12030 | 100 | 4 |
| 104 | 12031 | 100 | 4 |
| 105 | 12043 | 100 | 4 |
| 106 | 12044 | 100 | 4 |
| 107 | 12045 | 100 | 4 |
| 108 | 12046 | 100 | 4 |
| 109 | 12047 | 100 | 4 |
| 110 | 12052 | 100 | 4 |
| 111 | 274 | 200 | 1 |
| 112 | 384 | 300 | 1 |
| 113 | 326 | 500 | 1 |
| 200 | 269, 12055, 12056, 12057, 12058, 12059, 12060, 12048, 12049, 12050, 12051, 12032, 12042 | 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5 | 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4 |
| 201 | 269 | 10 | 4 |
| 202 | 12055 | 10 | 4 |
| 203 | 12056 | 10 | 4 |
| 204 | 12057 | 10 | 4 |
| 205 | 12058 | 10 | 4 |
| 206 | 12059 | 10 | 4 |
| 207 | 12060 | 10 | 4 |
| 208 | 12048 | 10 | 4 |
| 209 | 12049 | 10 | 4 |
| 210 | 12050 | 10 | 4 |
| 211 | 12051 | 10 | 4 |
| 212 | 12032 | 10 | 4 |
| 213 | 12042 | 10 | 4 |

### Event and map-event schemas

The client includes activity, event, event-NPC, map-event, and random-event managers/configs. These are IDs/config records, not proof of present-day eligibility or a fully implemented event lifecycle.

- `EventInfo`: 6 parsed records (**config found; runtime partial/unverified**).
- `EventNpcInfo`: 197 parsed records (**config found; runtime partial/unverified**).
- `MapEventInfo`: 220 parsed records (**config found; runtime partial/unverified**).
- `EventListInfo`: 459 parsed records (**config found; runtime partial/unverified**).
- `npc.txt`: **source located; semantics not fully normalized**.
- `TownNpc.txt`: **source located; semantics not fully normalized**.
- `map_npc.txt`: **source located; semantics not fully normalized**.
- `map_list.txt`: **source located; semantics not fully normalized**.
- `map_node.txt`: **source located; semantics not fully normalized**.
- `map_event.txt`: **source located; semantics not fully normalized**.
- `quest.txt`: **source located; semantics not fully normalized**.
- `ExpOpenLock.txt`: **source located; semantics not fully normalized**.
- `ExperienceInfo.dat`: **parsed by quest/client config reader**.

### Recharge safety

The catalogs above describe configured bundles only. The live payment provider flow has not been connected or simulated by this report; no receipt is fabricated. A local recharge sandbox still requires an explicit environment gate, provider isolation, idempotency and end-to-end tests before it can be called implemented.
