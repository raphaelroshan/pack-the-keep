# Pack the Keep — Latest Test Report

| Field | Result |
| --- | --- |
| Build | `0.37.0-seeded-pressure` |
| Local engine | Godot 4.7.2, headless Dummy audio |
| Complete verification | PASS |
| Runtime catalog | PASS: 3 keeps, 1 region, 21 pieces, 11 packs, 3 commanders, 10 enemies, 12 doctrines, 15 scenarios, 10 events, 2 modifiers |
| Scenario matrix | PASS: 126 viable cases and 252 uninterrupted/resumed simulations |
| Outcome distribution | 117 held, 9 partial breach, 0 collapse |
| Performance budget | PASS: 40 runs in 3886 ms; 120 large-text UI refreshes in 149 ms |
| P51/P52 focused tests | PASS: all P51 content plus 18 mixed-plan Twilight Crossroads runs across balanced, Gloam-heavy, and Outrider-heavy seeds; exact preview/spawn parity; active-event save/load parity; one-shot route effects; branch-aware terminal mastery; player-facing seed guidance; controller focus; and responsive layout |
| Human sessions | 0 completed; pending and not inferred |

The complete `scripts/verify.sh` suite passed locally. The existing packaged Windows and human hardware gates remain separate: CI must still build and exercise the Windows candidate, and no human observation or distribution approval is claimed here.
