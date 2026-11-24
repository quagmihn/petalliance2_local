# Item catalog

The target APK contains **1,776 ItemInfo templates across 25 type codes**.
The registry records the original ID, name and description keys, English
localization when present, icon path, rarity, bind/use flags, effect
parameters, and reverse references from awards and shops. It records
unresolved paths and leaves unverified stack limits and level requirements
empty. See the [content registry](CONTENT_REFERENCE_MATRIX.md).

| Family | Config source | Examples and gameplay state |
| --- | --- | --- |
| Capture consumables | ItemInfo type 9, PokemonBallInfo | Three ball templates. Capture consumes the actual stack through the battle handler. |
| Pet EXP consumables | ItemInfo type 19, GlobalConfigAddInfo ID 9 | Six potion templates. Only the configured feed IDs are enabled. Consumption, the Pet UID update, level cap, and cold login have PostgreSQL/TCP tests. Waydroid received and consumed the starter's configured Lost Forest potion, then restored its EXP and level on cold login. |
| Pet fragments | PetPieceInfo and ItemInfo type 15 | 103 fragment definitions. The fragment ID refers to an item, while its Pet link and GeneInfo use separate IDs. |
| Reward boxes and event items | ItemInfo use flags, effect parameters and RewardInfo | Exported with their source parameters. Box contents and use rules require per-family verification. |
| Appearance vouchers | ItemInfo type 22 and FashionItemInfo | 291 voucher templates. A single use exchanges the stack unit for the referenced appearance ID. |
| Equipment | EquipmentInfo, PetEquipInfo and ItemInfo type 26 | Five character equipment grade/part rows and 39 Pet equipment definitions. Type 26 carries equipment-fragment links. Equipment instances, slots, refinement and ownership require their own protocol contracts. |

The server stores stacks in `inventory(char_id,item_id,count)`. Bag reads
send absolute quantities with notification 112. A successful use sends the
remaining stack and the authoritative Pet or fashion state before ACK 526.
Market purchases check distinct-item capacity and update the stack inside the
wallet transaction. Capture, potion, and fashion transfer tests verify the
inventory debit and the committed result. Splitting stacks and general
equipment acquisition and use remain outside the verified paths.

104 ItemInfo icon paths do not resolve literally to an entry in the target
APK. The registry keeps those exact paths for asset lookup work. They include
references that may be relative to a texture atlas or optional resources.
