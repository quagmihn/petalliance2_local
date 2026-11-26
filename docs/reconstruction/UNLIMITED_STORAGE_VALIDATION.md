# Private storage validation

`LOCAL_UNLIMITED_PET_STORAGE` and `LOCAL_UNLIMITED_ITEM_STORAGE` require the private/test launcher and local provider. With them enabled, the shared reward, capture, Market and Gacha paths accept inventory above the old slot caps. Stack quantities remain inside the 32-bit client range and instance IDs are preserved.

Pet login pages cap at 24 reserve rows and a 16 KiB frame, while sending the current formation alongside each page. An early 100-row page test produced a native Waydroid crash after TCP responses near 47 KiB. The same fixture subsequently loaded correctly with pages no larger than 12,996 bytes. PostgreSQL and protocol tests exercise 40, 100, 250 and 500 Pets and at least 500 item stacks, with a 4,000,000,000 stack serialization test. The client UI showed 500 owned Pets and opened the QA Bag with 516 stored item IDs. QA subsequently acquired more Pets through draws and cold-logged into the same account.

The client loads all reserve pages into memory and renders the collection from its cache. Safe maximum size beyond the exercised counts is unverified. Legacy inventory actions still require individual stress testing.
