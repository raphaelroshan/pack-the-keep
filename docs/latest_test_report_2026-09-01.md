# Pack the Keep — Latest Test Report

| Field | Result |
| --- | --- |
| Build | `0.53.0-investment-vertical` |
| Local engine | Godot 4.7.2, headless Dummy audio |
| Complete verification | PASS |
| Runtime catalog | PASS: 3 keeps, 1 region, 29 pieces, 15 packs, 4 commanders, 12 enemies, 14 doctrines, 20 scenarios, 14 events, 2 modifiers |
| Scenario matrix | PASS: 228 viable cases and 456 uninterrupted/resumed simulations |
| Outcome distribution | 216 held, 12 partial breach, 0 collapse |
| Performance budget | PASS: 40 runs in 3848 ms; 120 large-text UI refreshes in 135 ms |
| Responsive decision follow-up | PASS: 1280×720 at 125% keeps Enter Keep and both next-choice controls in the first viewport; 1600×900 at 100% retains the full overview and two-column rail; 1280×720 at 150% keeps focused primary actions visible; Preparation carries the commander/defense/keep relationship and authored question without state mutation |
| Actor readability | PASS: all active defender and enemy profiles resolve original board-scale silhouettes; role identity and tactical overlays remain in the read-only presentation; unknown profiles retain procedural fallback |
| Authored audio feedback | PASS: all fourteen semantic cues resolve distinct reproducible original WAV assets; output uses a bounded four-player pool; mute/zero-volume suppression, generated-tone fallback, and simulation non-mutation remain covered |
| Combat effect readability | PASS: defender melee/ranged and hostile melee/ranged/demolition profiles resolve five distinct original 48×48 textures; effects stay within existing response/impact beats and preserve reduced-motion and simulation invariants |
| Room damage and repair feedback | PASS: stable rooms remain quiet; damaged/breached profiles and repair confirmation resolve three distinct original textures; normal-flow tutorial repairs target the exact room/defender and report the authoritative restored amount without snapshot mutation |
| Room-function accents | PASS: seven Greywatch functional rooms resolve seven distinct original 32×32 SVG silhouettes; the inner yard, outer wall, Ash Ford, and Twinwatch remain unaccented; high contrast preserves geometry and simulation state; no active room-function profile depends on Tiny Dungeon |
| Room-label legibility | PASS: every active room label fits its reserved board width; Greywatch, Ash Ford, and Twinwatch resolve keep-specific labels; empty placement guides are outline-only; inspection retains full names without state mutation |
| Authored core actor readability | PASS: four defender-role and four signature-enemy SVG silhouettes resolve from stable original paths; tactical overlays and simulation state remain unchanged |
| Complete authored actor set | PASS: all twelve enemy IDs resolve unique original 32×32 SVG silhouettes; unknown IDs retain procedural fallback; no current actor profile depends on Tiny Battle |
| PTK Early Access roadmap | PASS: PTK-EA-1 through PTK-EA-6, all approved breadth floors, three six-scenario keeps, twelve commander/keep starts, Marshal assignment mechanics, Battering Ram/Harrier counterplay, event breadth, responsive UI, and distribution boundary |
| PTK investment roadmap | PASS: PTK-I1 through PTK-I6; three distinct keep-authored first plans; save/resume at Preparation, live Battle, Recovery, and terminal Results; cross-keep consequence continuation; 1280×720 and 1600×900 Ash Ford captures; evidence and distribution-boundary validation |
| P51/P52 focused tests | PASS: all P51 content plus 18 mixed-plan Twilight Crossroads runs across balanced, Gloam-heavy, and Outrider-heavy seeds; exact preview/spawn parity; active-event save/load parity; one-shot route effects; branch-aware terminal mastery; concise player-facing seed guidance; controller focus; and responsive layout |
| P53 integrated flow | PASS: 2560×1440 at 150% UI scale with high contrast, reduced motion, muted semantic cues, controller-first focus, Preparation/live-Battle/Recovery/terminal-Results save/load, authored-decision save/load, and reachable terminal replay |
| Human sessions | 0 completed; pending and not inferred |

The complete `scripts/verify.sh` suite is the final local gate for this candidate. Packaged Windows verification remains a separate CI step, and no human observation or distribution approval is claimed here.
