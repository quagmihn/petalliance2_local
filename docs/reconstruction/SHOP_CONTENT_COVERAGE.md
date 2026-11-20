# Shop content coverage

| Family | Count | References and runtime |
| --- | ---: | --- |
| Market | 90 SKUs | 90 startup-validated SKU-to-item links and PostgreSQL transaction coverage. Prior Waydroid purchase evidence is limited to the capture-ball flow. |
| CommonShop | 5 shop definitions, 55 pools, 567 offers | 493 offer rows reference 386 missing ItemInfo IDs. These offers remain off. |
| ActivityShop | 7 rows | Three missing item IDs. Eligibility and claims remain partial. |
| FamilyShop | 50 rows | Catalog parsed. Purchase and membership flows remain partial. |
| Adventure NPC shops | 2 definitions | 62 offer rows reference missing item IDs. Server map-state payload still emits an empty NPC shop vector. |
| Local recharge | 12 normal packages, 2 M-PASS packages | Existing simulated ledger and entitlement flow covered by prior Waydroid acceptance. |

OrderMan expects Market SKU 203, which is absent from the target MarketInfo.
New product or reward definitions require independent source evidence.

[Previous purchase and M-PASS evidence](EXECUTION_CHECKPOINT.md)
