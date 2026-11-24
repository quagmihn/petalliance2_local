# Shop content coverage

| Family | Count | References and runtime |
| --- | ---: | --- |
| Market | 90 SKUs | 90 startup-validated SKU-to-item links and PostgreSQL transaction coverage. Waydroid purchased Normal Essence through Town → Market → Mall for 20 diamonds. A prior run purchased a capture ball. |
| CommonShop | 5 shop definitions, 55 pools, 567 offers | 493 offer rows reference 386 missing ItemInfo IDs. These offers remain off. |
| ActivityShop | 7 rows | Three missing item IDs. Eligibility and claims remain partial. |
| FamilyShop | 50 rows | Catalog parsed. Purchase and membership flows remain partial. |
| Adventure NPC shops | 2 definitions | 62 offer rows reference missing item IDs. Server map-state payload still emits an empty NPC shop vector. |
| Local recharge | 12 normal packages, 2 M-PASS packages | Existing simulated ledger and entitlement flow covered by prior Waydroid acceptance. |

OrderMan expects Market SKU 203, which is absent from the target MarketInfo.
The alternate `apk_raw/unpacked` market contains a row pointing to the
same item 9986 at one diamond. Nearby offers 201 and 202 have
different prices in the target economy, so the alternate price has no
confirmed target equivalent. SKU 203 stays disabled. Equipment and
costume purchases through the distinct shop families remain open.

The 90 enabled Market offers contain neither item type 4
(`IC_EQUIP`) nor item type 22 (`IC_FASHION`). The existing
fashion voucher/equip acceptance covers wardrobe ownership. Market
equipment and costume checkout remain unverified.

Town Market's first tab queries player-authored listings. The server currently
has none and returns empty results via 493 and 520. The Mall and Commerce
tabs load their own packaged offers and checkout through 577 → 563.

[Previous purchase and M-PASS evidence](EXECUTION_CHECKPOINT.md)
