# Pack the Keep — Latest Test Report

| Field | Result |
| --- | --- |
| Build | `0.31.0-quartermaster` |
| Local engine | Godot 4.7.2, headless Dummy audio |
| Complete verification | PASS |
| Runtime catalog | PASS: 2 keeps, 1 region, 17 pieces, 9 packs, 3 commanders, 8 enemies, 9 doctrines, 11 scenarios, 9 events, 2 modifiers |
| Scenario matrix | PASS: 90 viable cases and 180 uninterrupted/resumed simulations |
| Outcome distribution | 81 held, 9 partial breach, 0 collapse |
| Performance budget | PASS: 40 runs in 1433 ms; 120 large-text UI refreshes in 122 ms |
| P51 focused tests | PASS: Quartermaster authority, save/load, pricing, recovery, ability, War Council, Preparation, and Battle state |
| Human sessions | 0 completed; pending and not inferred |

The complete `scripts/verify.sh` suite passed locally. The existing packaged Windows and human hardware gates remain separate: CI must still build and exercise the Windows candidate, and no human observation or distribution approval is claimed here.
