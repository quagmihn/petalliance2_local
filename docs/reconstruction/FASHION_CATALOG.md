# Fashion catalog

The target APK includes **300 FashionItemInfo appearances, 291 ItemInfo
vouchers of type 22, and 10 FashionSuitEffectInfo definitions**. The
machine-readable registry includes the wearable ID, sex field, exact asset
path, localization key, ordering, visibility, effect fields, and reverse
voucher/award/shop links. The target APK contains the icon for each of the
300 decoded appearances.

| Example | Item template | Appearance template | Resource |
| --- | ---: | ---: | --- |
| Halloween Bottom | 33066 | 3066 | `Player/Avatar/nv66_xia.png` |
| Pumpkin Bag | 34066 | 4066 | `Player/Avatar/nv66_bei.png` |
| Silver Helmet | 31049 | 1049 | `Player/Avatar/nan14_tou.png` |

The appearance ID comes from the voucher's `paramA`. Request 516 consumes
one voucher and adds the appearance to `characters.game_values.fashion_info`
in one transaction. An already-owned costume returns the client's
`ERROR_FASHION_EXIST` and keeps the item. The same ownership data is
available via GetFashions 2075/2102. The existing equip path 2121/2109
requires ownership and persists the current vector for login serialization.
The generic character-value setter rejects direct edits to the fashion state.

PostgreSQL/TCP tests cover the voucher transfer, duplicate rejection, equip,
and cold login. Waydroid acquired and equipped Silver Helmet through the
Bag and wardrobe, then showed it in Town and after a cold login on the QA
profile. Costume effects, the equipment instance inventory and full
appearance coverage across scenes are separate from the voucher ownership
contract. [Content registry](CONTENT_REFERENCE_MATRIX.md)
