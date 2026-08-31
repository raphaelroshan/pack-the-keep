# Pack the Keep — Latest Test Report

| Field | Result |
| --- | --- |
| Build | `0.32.0-twinwatch` |
| Local engine | Godot 4.7.2, headless Dummy audio |
| Complete verification | PASS |
| Runtime catalog | PASS: 3 keeps, 1 region, 17 pieces, 9 packs, 3 commanders, 8 enemies, 9 doctrines, 12 scenarios, 9 events, 2 modifiers |
| Scenario matrix | PASS: 99 viable cases and 198 uninterrupted/resumed simulations |
| Outcome distribution | 90 held, 9 partial breach, 0 collapse |
| Performance budget | PASS: 40 runs in 2193 ms; 120 large-text UI refreshes in 122 ms |
| P51 focused tests | PASS: Quartermaster authority/UI plus Twinwatch spatial rule, recovery, save/load, two-answer viability, ridge presentation, and non-mutating redraw |
| Human sessions | 0 completed; pending and not inferred |

The complete `scripts/verify.sh` suite passed locally. The existing packaged Windows and human hardware gates remain separate: CI must still build and exercise the Windows candidate, and no human observation or distribution approval is claimed here.
