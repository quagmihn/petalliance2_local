# Draw request maintenance

| Client operation | Request → response | Verified scope |
| --- | --- | --- |
| Machine draw | 1392 → 1561 | The request carries four WORD fields. The existing local server returns code 1 without a reward payload. Framed TCP and PostgreSQL verify the rejection leaves wallet, inventory, Pet count and completed quest count unchanged. |
| Cooldown read | 1573 → 1526 | Existing response shape has contract coverage. Full eligibility behavior remains open. |
| Machine information read | 1519 → 1396 | Declared in the existing client. Runtime behavior was outside this maintenance change. |
| Limited activity draw | 396 → 397 | Separate protocol operation. Runtime behavior was outside this maintenance change. |

The earlier Waydroid trace shows 1561/code 1 resolving the pending network callback. The network wrapper then hides its loading overlay. Guide 10010 independently disabled touch after the tap and waited for the result popup loader. The failure path never created that popup, so its cleanup callback never ran.

The guide now waits only when the draw request is pending and leaves the request overlay to the network wrapper. Failure, timeout and machine close discard the result callback and release guide state. The quest stays active. Cold login can start the guide again. The first single and ten draw controls recover on failure, and the single draw request is no longer replayed automatically on reconnect.

Successful free, single and ten draw rewards, counters and result animations remain unverified.
