# Draw request maintenance

## Local draw checkpoint

Five call sites serialize `1392` through `PetSend.sendCG_CapsuleEgg_Req` in
`GachaViewMgr.lua`. They are the machine single and ten buttons, repeat from each
result screen, and the wish or dream confirmation. The prior single-result
repeat branch also issued a second draw on reconnect. The draw paths now disable
automatic replay. A legacy request contains four WORDs with no operation ID, so
the server cannot distinguish a repeated paid request from another intentional
purchase. Free limits and debits are checked while holding the character row.

`Proto_Pet.lua` decodes `1561` as a WORD status and, on success, a vector of
JSON strings. `PetProcess.lua` sends one result to the single screen or a vector
to the multi-result screen. Item results carry `elementType`, `elementID` and
`num`. Wallet and absolute inventory updates arrive before the result ACK.

`CapsuleEggInfo.dat` contains three machine rows. `CapsuleEggAwardInfo.dat`
contains 17 groups and 27 positive weighted entries. Every group sums to
10,000. The normal, first, first-ten, normal-ten and guarantee references
resolve. All 27 prize references resolve through `AwardElementInfo.dat`, and
`ConsumeElementInfo.dat` supplies quoted prices. `GachaMayGet.txt` is a display
preview. The unresolved contract is when and how the live server applied
first-draw, ten-draw and guaranteed groups during a sequence, together with
VIP or entitlement interactions and sentinel values in the free limits.

`server/local_draw.py` audits the packaged data and loads a separate prize JSON
for opt-in QA. The test rules cover weighted item-only prizes, free single,
paid single and paid ten. Paid ten makes ten independent selections using the
local weights. The local free rules use the displayed cooldown, a daily cap
for machine 1, cooldown alone for machine 2, and paid-only machine 3.

The successful transaction writes cost and awards to `local_draw_history`,
deducts the wallet and grants inventory together. The original reward groups
are excluded from this simulation. No local prize catalog is enabled by
default.

| Client operation | Request → response | Verified scope |
| --- | --- | --- |
| Machine draw | 1392 → 1561 | The request carries four WORD fields. The existing local server returns code 1 without a reward payload. Framed TCP and PostgreSQL verify the rejection leaves wallet, inventory, Pet count and completed quest count unchanged. |
| Cooldown read | 1573 → 1526 | Existing response shape has contract coverage. Full eligibility behavior remains open. |
| Machine information read | 1519 → 1396 | Declared in the existing client. Runtime behavior was outside this maintenance change. |
| Limited activity draw | 396 → 397 | Separate protocol operation. Runtime behavior was outside this maintenance change. |

The earlier Waydroid trace shows 1561/code 1 resolving the pending network callback. The network wrapper then hides its loading overlay. Guide 10010 independently disabled touch after the tap and waited for the result popup loader. The failure path never created that popup, so its cleanup callback never ran.

The guide now waits only when the draw request is pending and leaves the request overlay to the network wrapper. Failure, timeout and machine close discard the result callback and release guide state. The quest stays active. Cold login can start the guide again. The first single and ten draw controls recover on failure, and the single draw request is no longer replayed automatically on reconnect.

Successful free, single and ten draw rewards, counters and result animations remain unverified.
