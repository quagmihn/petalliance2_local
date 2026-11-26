# Arena exchange acceptance

ShopInfo type 1 defines nine slots using pools 1, 2, 7, 8 and 9. Across the nine slot positions 157 positive-weight rows resolve through AwardElementInfo to ItemInfo, representing 61 distinct offers. The catalog preserves authored prices, grant quantities and available stock. The server uses the same stored offer order for request 778 / ACK 1746 and zero-based buy request 858 / ACK 1953.

A checkout locks the character's catalog and Arena points, checks rank-independent stock and the level-11 unlock, validates Bag capacity, grants the item, deducts Arena points, and commits the purchase ledger. Handled refreshes use the configured VIP refresh limit, diamond cost and 06:00 slot rotation. PostgreSQL tests cover low level, insufficient points, forbidden client score edits, simultaneous repeat checkout, inventory grant, and reload of exhausted stock.

Waydroid Arena checkout remains open. Tapping the original Arena showed request 277 reached the test server and had no reply at the time. The release now responds with the declared error for an unavailable combat lobby, releasing the pending callback. The lobby also asks for replay history through 267. NPC battle fields, legitimate participation rewards, rank and end-of-battle accounting are still open. [Waydroid entry](../../artifacts/pet-economy-20261126/qa-arena-entry.png)
