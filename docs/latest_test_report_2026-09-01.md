# Pack the Keep — Latest Test Report

| Field | Result |
| --- | --- |
| Build | `0.48.0-authored-room-accents` |
| Local engine | Godot 4.7.2, headless Dummy audio |
| Complete verification | PASS |
| Runtime catalog | PASS: 3 keeps, 1 region, 21 pieces, 11 packs, 3 commanders, 10 enemies, 12 doctrines, 15 scenarios, 10 events, 2 modifiers |
| Scenario matrix | PASS: 126 viable cases and 252 uninterrupted/resumed simulations |
| Outcome distribution | 117 held, 9 partial breach, 0 collapse |
| Performance budget | PASS: 40 runs in 2558 ms; 120 large-text UI refreshes in 119 ms |
| Responsive decision follow-up | PASS: 1280×720 at 125% keeps Enter Keep and both next-choice controls in the first viewport; 1600×900 at 100% retains the full overview and two-column rail; 1280×720 at 150% keeps focused primary actions visible; Preparation carries the commander/defense/keep relationship and authored question without state mutation |
| Temporary actor readability | PASS: formation/ranged defender textures and ranged/heavy/siege hostile textures load from the licensed CC0 kit; role silhouettes and all tactical overlays remain in the read-only board presentation; missing textures retain procedural fallback |
| Tactile audio feedback | PASS: every semantic battle beat resolves a distinct loadable temporary CC0 sample; output uses a bounded four-player pool; mute/zero-volume suppression, generated-tone fallback, and simulation non-mutation remain covered |
| Combat effect readability | PASS: defender melee/ranged and hostile melee/ranged/demolition profiles resolve distinct loadable temporary CC0 textures; effects stay within existing response/impact beats and preserve reduced-motion and simulation invariants |
| Room damage and repair feedback | PASS: stable rooms remain quiet; damaged/breached profiles resolve distinct loadable textures; normal-flow tutorial repairs target the exact room/defender and report the authoritative restored amount without snapshot mutation |
| Room-function accents | PASS: seven Greywatch functional rooms resolve seven distinct original 32×32 SVG silhouettes; the inner yard, outer wall, Ash Ford, and Twinwatch remain unaccented; high contrast preserves geometry and simulation state; no active room-function profile depends on Tiny Dungeon |
| Room-label legibility | PASS: every active room label fits its reserved board width; Greywatch, Ash Ford, and Twinwatch resolve keep-specific labels; empty placement guides are outline-only; inspection retains full names without state mutation |
| Authored core actor readability | PASS: four defender-role and four signature-enemy SVG silhouettes resolve from stable original paths; tactical overlays and simulation state remain unchanged |
| Complete authored actor set | PASS: all ten enemy IDs resolve unique original 32×32 SVG silhouettes; unknown IDs retain procedural fallback; no current actor profile depends on Tiny Battle |
| P51/P52 focused tests | PASS: all P51 content plus 18 mixed-plan Twilight Crossroads runs across balanced, Gloam-heavy, and Outrider-heavy seeds; exact preview/spawn parity; active-event save/load parity; one-shot route effects; branch-aware terminal mastery; concise player-facing seed guidance; controller focus; and responsive layout |
| P53 integrated flow | PASS: 2560×1440 at 150% UI scale with high contrast, reduced motion, muted semantic cues, controller-first focus, ordinary-recovery save/load, authored-decision save/load, and reachable terminal replay |
| Human sessions | 0 completed; pending and not inferred |

The complete `scripts/verify.sh` suite passed locally after the authored room-function update. The existing packaged Windows and human hardware gates remain separate: CI must still build and exercise the Windows candidate, and no human observation or distribution approval is claimed here.
