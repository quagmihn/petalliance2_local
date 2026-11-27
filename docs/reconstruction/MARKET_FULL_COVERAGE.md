# Market and local silver

The 90 target `MarketInfo` SKUs resolve to real `ItemInfo` IDs and passed PostgreSQL purchase tests that checked the exact item, quantity and debit for every offer.

| Client family | Catalog offers | Currency | Evidence |
| --- | ---: | --- | --- |
| Market Commerce | 6 | Silver | All tested against PostgreSQL. Real Waydroid Dye purchase repeated twice. |
| Market Mall | 43 | Diamonds | All tested against PostgreSQL. Catalog visible in Waydroid. |
| VIP Shop | 41 | Diamonds | All tested against PostgreSQL, with separate prior Waydroid VIP-shop repeat-purchase evidence. |

`LOCAL_UNLIMITED_SILVER` only applies to a matched account, character and name with the local payment provider and private launcher profile. The ordinary local profile authorizes `6:2:minh`. The test profile explicitly authorized `848:834:QArichadventure`. Neither profile uses a physical balance correction. Silver is projected as 999999999, the Market quote and log retain the configured price, and gold, diamonds, VIP, stock conditions and valid item checks remain enforced.

In Waydroid, the test character bought Dye (SKU 101, item 162) twice. Request 577 received ACK 563/code 0, the logs recorded the 10-silver price each time and PostgreSQL gained two Dye. The stored `goldCoin` remained 0. See `qa-market-silver.png`, `qa-market-silver-success.png` and `qa.log` in the evidence directory. Market Shop listings from other players, Stall and equipment instance effects require separate protocol/ownership work.

Cold Waydroid login on the official database confirmed Level 50 / VIP 20 and opened Market → Commerce for `minh`. The UI displays 999999999 silver while PostgreSQL continues to report 10600. No owner purchase was made during verification. See `live-minh-market-silver.png` and `live.log`.
