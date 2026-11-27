# Stamina purchase

The old 1242 handler always rejected. The new 1242/991 path uses BuyPowerInfo's 19 price steps, VipInfo purchase limits and ExperienceInfo regeneration. Purchased stamina can overflow the natural cap within the protocol's unsigned 16-bit field. A current quote from the exchange UI and the locked daily purchase counter prevent application of a stale duplicate. 473 updates stamina, wallet and count. The same transaction advances the appropriate daily mission.

The isolated Waydroid character exchanged 50 diamonds for 120 stamina (428,513 → 428,463 diamonds, 9,679 → 9,799 stamina). Screenshots and TCP packets are in `artifacts/arena-missions-20261127/`. PostgreSQL coverage includes a replay of the old quote and a cold session. Higher price tiers and VIP limits were read from configuration.
