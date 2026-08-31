# Pack the Keep — Latest Test Report

| Field | Result |
| --- | --- |
| Build | `0.33.0-road-wardens` |
| Local engine | Godot 4.7.2, headless Dummy audio |
| Complete verification | PASS |
| Runtime catalog | PASS: 3 keeps, 1 region, 19 pieces, 10 packs, 3 commanders, 9 enemies, 10 doctrines, 13 scenarios, 9 events, 2 modifiers |
| Scenario matrix | PASS: 108 viable cases and 216 uninterrupted/resumed simulations |
| Outcome distribution | 99 held, 9 partial breach, 0 collapse |
| Performance budget | PASS: 40 runs in 3980 ms; 120 large-text UI refreshes in 155 ms |
| P51 focused tests | PASS: Quartermaster, Twinwatch, and Road Wardens/Outrider authority, UI, save/load, two-answer viability, and non-mutating presentation |
| Human sessions | 0 completed; pending and not inferred |

The complete `scripts/verify.sh` suite passed locally. The existing packaged Windows and human hardware gates remain separate: CI must still build and exercise the Windows candidate, and no human observation or distribution approval is claimed here.
