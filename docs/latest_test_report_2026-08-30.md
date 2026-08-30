# Pack the Keep — Latest Main Test Report

## Build and verification

| Field | Result |
|---|---|
| Branch tested | `feat/k6-command-disruptor-slice` before merge to `main` |
| Build | `v0.28.0-standard-cutter` |
| Engine | Godot 4.7.2 |
| Visual test display | 1600×900 local graphical renderer |
| Automated verification | PASS: complete `scripts/verify.sh` suite |
| Runtime content | PASS: 2 keeps, 17 pieces, 9 packs, 8 enemies, 9 doctrines, 11 scenarios |
| Scenario matrix | PASS: 60 viable cases and 120 uninterrupted/resumed simulations |
| Human playtest gate | PENDING: no human observations inferred from automation |

## K6 evidence

The Standard Cutter is one controlled enemy-family addition. It prioritizes a living assigned specialist, falls back to the weakest precision/support/control piece, and never substitutes room damage for its unit-hunter role. The Cut Standard names Crossbow Watch and Fallback Convoy as separate answers.

Focused verification covers malformed content rejection, assigned-first targeting, unit-only fallback, save/load parity, two commanders, two loadouts, three seeds, normal-flow scenario selection, focused threat inspection, large text, high contrast, reduced motion, and the dedicated forked-standard silhouette.

The 1600×900 screenshots in `/tmp/pack-the-keep-k6` show the Preparation question/answer framing and a paused tick-three contact with the assigned target, projected Rear Guard response, cadence, health, and counter visible while the keep remains primary.

## Findings

The new teaching question is readable without adding another menu or status subsystem. Precision fire stops the Cutter before contact; the mobile reserve accepts limited contact while maintaining a second line. The compact `CMD` board cue remains subordinate to health, focus, and target lines.

No automated regression or deterministic divergence was found. The known release limitation remains unchanged: the build is an internal pre-alpha candidate and has no completed human-session evidence.

## Next roadmap step

K7 should add one bounded, forecastable variation that changes the tactical question on replay and then compare the chosen answer with the encountered pressure in Results. It must retain at least two viable solutions and avoid rarity, grind, or hidden counters.
