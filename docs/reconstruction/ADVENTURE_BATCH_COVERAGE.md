# Adventure batch validation

`python tools/audit_adventure_batch.py` walks all 290 available Adventure definitions. It checks authored geometry, reward references, event types and battle groups. There are 275 Adventures with authored geometry, 270 with resolvable configured clear rewards and 267 with no known structural errors within the audited fields. The report records individual blocked references and separate gameplay status. Event families encountered are 0, 1, 2, 3, 4, 5, 6, 7, 8, 20, 21 and 22.

Adventure completion 3082/2995 now resolves the clear award through DropInfo. Previously the code used a flat list from a different reward domain. PostgreSQL/TCP regression exercises a sequence through Adventure IDs 1–3. Current Android evidence covers earlier authored paths in the checkpoint. Crown validation, every outlying event family and a three-clear Android sequence remain open.
