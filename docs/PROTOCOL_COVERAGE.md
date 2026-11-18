# Protocol coverage

Request IDs and ACK IDs are parsed from the server's literal command map; dispatch routes come from Python AST. Client serializer definitions live under `decoded_lua/assets/src/Net/Proto` and `Net/Send`.

| Request ID | Request name | Response ID | Server route | Coverage status |
| --- | --- | --- | --- | --- |
| 4 | fire_adventure_event | 5 | unmapped | no explicit route |
| 18 | recover_tower | 17 | unmapped | no explicit route |
| 45 | chat | 35 | send_chat | handler routed; feature behavior must be integration/runtime tested |
| 55 | get_pet_wiki | 54 | unmapped | no explicit route |
| 59 | get_items | 37 | get_items | handler routed; feature behavior must be integration/runtime tested |
| 61 | claim_vip | notification/paired ACK not represented in CMD | claim_vip_award | handler routed; feature behavior must be integration/runtime tested |
| 63 | get_vip_awards | 62 | unmapped | no explicit route |
| 69 | get_potentials | 70 | unmapped | no explicit route |
| 72 | get_achievements | 74 | unmapped | no explicit route |
| 79 | red_heart | notification/paired ACK not represented in CMD | red_heart | handler routed; feature behavior must be integration/runtime tested |
| 86 | buy_npc | notification/paired ACK not represented in CMD | buy_npc | handler routed; feature behavior must be integration/runtime tested |
| 90 | recharge_test | 89 | recharge_test | handler routed; feature behavior must be integration/runtime tested |
| 96 | get_wishing_trees | 97 | unmapped | no explicit route |
| 118 | get_home | 32 | get_home | handler routed; feature behavior must be integration/runtime tested |
| 128 | get_life_skill_data | 181 | life_skill | handler routed; feature behavior must be integration/runtime tested |
| 136 | create_pve_battle | 210 | handle | tutorial/adventure paths routed; type 1 tutorial wild encounter Waydroid start tested |
| 154 | get_activities | 152 | unmapped | no explicit route |
| 227 | get_treasure_box_data | 225 | get_data | handler routed; feature behavior must be integration/runtime tested |
| 263 | pve_battle_end | 186 | unmapped | no explicit route |
| 347 | get_friends | 253 | unmapped | no explicit route |
| 380 | change_channel | 386 | change_channel | handler routed; feature behavior must be integration/runtime tested |
| 391 | get_seven_day_award | 390 | get_seven_day_award | handler routed; feature behavior must be integration/runtime tested |
| 398 | buy_mcash | 406 | buy_mcash | handler routed; feature behavior must be integration/runtime tested |
| 400 | quest_commit | 726 | commit_quest | handler routed; feature behavior must be integration/runtime tested |
| 412 | get_world_open_time | 410 | unmapped | no explicit route |
| 446 | get_world_boss | 450 | unmapped | no explicit route |
| 463 | buy_gcash | 449 | buy_gcash | handler routed; feature behavior must be integration/runtime tested |
| 481 | buy_product | 471 | buy_product | handler routed; feature behavior must be integration/runtime tested |
| 501 | get_week_champion | 498 | get_week_champion | handler routed; feature behavior must be integration/runtime tested |
| 516 | use_item | 526 | use_item | Pet EXP feed handler; PostgreSQL TCP integration tested; Waydroid blocked |
| 561 | pet_equip_strengthen | notification/paired ACK not represented in CMD | pet_equip_strengthen | handler routed; feature behavior must be integration/runtime tested |
| 577 | buy_market | 563 | buy_market | handler routed; feature behavior must be integration/runtime tested |
| 595 | buy_activity | 593 | buy_activity | handler routed; feature behavior must be integration/runtime tested |
| 632 | change_character_info | 630 | change_character_info | handler routed; feature behavior must be integration/runtime tested |
| 659 | get_science | 651 | unmapped | no explicit route |
| 662 | recharge_cd | 655 | get_recharge_cd | handler routed; feature behavior must be integration/runtime tested |
| 690 | read_info | 721 | read_info | handler routed; feature behavior must be integration/runtime tested |
| 729 | pet_super_evolve | notification/paired ACK not represented in CMD | pet_evolve | handler routed; feature behavior must be integration/runtime tested |
| 770 | get_character_values | 747 | get_character_values | handler routed; feature behavior must be integration/runtime tested |
| 785 | quest_list | 26 | get_quests | handler routed; feature behavior must be integration/runtime tested |
| 806 | get_signin | 676 | unmapped | no explicit route |
| 858 | buy_goods | 1953 | buy_goods | handler routed; feature behavior must be integration/runtime tested |
| 930 | check_unread_mail | 1077 | unmapped | no explicit route |
| 1038 | pet_advance_stage | 1032 | advance_stage | handler routed; feature behavior must be integration/runtime tested |
| 1074 | get_explore | 1109 | unmapped | no explicit route |
| 1214 | get_server_time | 1216 | get_server_time | handler routed; feature behavior must be integration/runtime tested |
| 1242 | buy_power | 991 | buy_power | handler routed; feature behavior must be integration/runtime tested |
| 1247 | pet_evolve | notification/paired ACK not represented in CMD | pet_evolve | handler routed; feature behavior must be integration/runtime tested |
| 1283 | get_friend_detail | 1261 | get_friend_detail | handler routed; feature behavior must be integration/runtime tested |
| 1302 | pet_skill_level | notification/paired ACK not represented in CMD | pet_skill_level | handler routed; feature behavior must be integration/runtime tested |
| 1338 | get_map_events | 1433 | unmapped | no explicit route |
| 1392 | capsule_egg | 1561 | capsule_egg | handler routed; feature behavior must be integration/runtime tested |
| 1573 | get_capsule_cds | 1526 | get_capsule_egg_cds | handler routed; feature behavior must be integration/runtime tested |
| 1596 | pet_star_up | notification/paired ACK not represented in CMD | pet_star_up | handler routed; feature behavior must be integration/runtime tested |
| 1644 | query_self_territory | 1664 | query_self_territory | handler routed; feature behavior must be integration/runtime tested |
| 1655 | create_character | 807 | create_character | handler routed; feature behavior must be integration/runtime tested |
| 1755 | update_army | 1756 | update_army | handler routed; feature behavior must be integration/runtime tested |
| 1760 | get_army | 1774 | get_army | handler routed; feature behavior must be integration/runtime tested |
| 1819 | territory_info | 1901 | territory_info | handler routed; feature behavior must be integration/runtime tested |
| 2042 | buy_packet | 2043 | buy_packet | handler routed; feature behavior must be integration/runtime tested |
| 2075 | get_fashions | 2102 | get_fashions | handler routed; feature behavior must be integration/runtime tested |
| 2098 | restore_fashions | 2066 | restore_fashions | handler routed; feature behavior must be integration/runtime tested |
| 2121 | set_fashions | 2109 | set_fashions | handler routed; feature behavior must be integration/runtime tested |
| 2130 | platform_login | 2126 | platform_login | handler routed; feature behavior must be integration/runtime tested |
| 2156 | device_login | 2183 | device_login | handler routed; feature behavior must be integration/runtime tested |
| 2211 | device_bind | 2179 | device_bind | handler routed; feature behavior must be integration/runtime tested |
| 2996 | create_adventure | 3080 | create_adventure | handler routed; feature behavior must be integration/runtime tested |
| 2998 | get_adventure_award | 3079 | get_adventure_award | handler routed; feature behavior must be integration/runtime tested |
| 2999 | get_current_adventure | 2997 | unmapped | no explicit route |
| 3078 | get_finished_adventures | 3081 | get_finished_adventures | handler routed; feature behavior must be integration/runtime tested |
| 3082 | finish_adventure | 2995 | finish_adventure | handler routed; feature behavior must be integration/runtime tested |
| 3102 | take_month_card | 3103 | take_month_card | handler routed; feature behavior must be integration/runtime tested |
| 3104 | load_month_card | 3106 | load_month_card | handler routed; feature behavior must be integration/runtime tested |
| 3133 | quest_update | 3132 | update_quest | handler routed; feature behavior must be integration/runtime tested |
| 3140 | query_pets | 3139 | query_pets | handler routed; feature behavior must be integration/runtime tested |
