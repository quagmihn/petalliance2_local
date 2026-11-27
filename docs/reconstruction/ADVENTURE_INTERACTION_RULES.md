# Adventure interaction rules

The installed client's 722 request carries source ID, scene cell ID, Adventure ID and interaction kind. The former server had no handler, including for Adventure 4 scene cell 124 recorded at 18:16:41. The supported interaction pairs ACK 746 with scoped validation against the active run and authored cell.

| Interaction | Config evidence | Requirement |
| --- | --- | --- |
| Chop tree | `obstruction.txt` obstruction 5 and scene event; `AdvPetsMgr.useSkill` | Any owned Pet with a valid active-slot skill in group 36. The client searches fighting team, then support, then other owned Pets. Ownership outside the formation can qualify, and Panda is one possible provider. |
| Play flute on obstacle | `fbpickup.txt` source and target definitions; `SearchingFuncMgr` | Claim the configured tool in this run, then use it on its configured target. Adventure 4 cell 150 on floor 1 supplies the flute for cell 173 on floor 2. |
| Clear or revisit cell | `SceneInfo`, Adventure run events | Reject wrong Adventure, scene or tool. Keep successful mutations run-local and apply no second debit/grant from the same cleared cell. Resume rehydrates removed events. |

PostgreSQL tests cover rejection without the skill, acceptance with an owned reserve Pet, rejection before obtaining the flute, pickup and consumption, duplicate rejection, and three cleared cells returned after reconnect. The client releases its own interaction state on failure/timeout. Other obstacle families, sealed boxes and original positive-capture layouts require independent evidence.
