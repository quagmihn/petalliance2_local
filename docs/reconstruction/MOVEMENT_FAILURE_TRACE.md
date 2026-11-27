# Movement failure trace

Walking in Town is local. The Lua position publisher periodically sends the current position as a self-addressed JSON message over chat request 45 after joining `zhucheng_2` (380 → 386). The old relay stub handled this as ordinary chat, returned ACK 35/code 1, and the normal `ChatProcess.onGC_Chat_Ack` error path displayed “Failed.” The player could already move while the subsequent position message failed.

The server recognizes the verified town position shape only on the current joined Town channel, with a configured Town resource and a finite in-range X position. The authoritative position update is session-local. Duplicate reports do not create gameplay events or database writes. Direct chat and unsupported channels retain their error responses.

Several real Waydroid ground taps moved the character and camera. The same TCP session recorded position changes including X=319.5 and X=92.0043, followed by 45 → 35/code 0. The Market building remained interactive and two purchases succeeded afterward. The initial Adventure click trace separately contained a 722 obstacle call with no response, fixed by the authored interaction handler. This establishes the Town false failure and the 722 obstacle path. Interactions on other movement families have not all been retraced.

The production check reproduced several Town ground taps after the owner's cold login. The official server recorded position changes from X=319.5 to X=1761.3305 with code 0. The owner could open Market Commerce afterward. The production trace is `live.log` in the evidence directory.
