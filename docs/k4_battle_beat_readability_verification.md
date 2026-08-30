# K4 — Battle beat readability verification

- Build: `0.27.0-battle-beat-readability`
- Scope: presentation-only staging over existing deterministic combat ticks

## Automated evidence

`tests/test_k4_battle_beat_readability.gd` verifies the eight ordered beat identities, ambient Forecast/Approach/Target Lock/Wind-up projection, defender-before-hostile exchange staging, speed-scaled effect duration, reduced-motion fallback, and serialized-state invariance.

Existing P2, P35, and P44 tests preserve real-time/manual-step behavior, role-specific attack motion, health trails and recoil, semantic audio, pause controls, and the Battle snapshot boundary. The full `scripts/verify.sh` suite remains the release gate.

## Visual evidence

The graphical capture harness passed at 1600×900. `/tmp/pack-the-keep-k4/04_assault_phase_1.png` confirms the compact Forecast badge remains above the keep without covering tactical geometry. `/tmp/pack-the-keep-k4-exchange/04_assault_phase_1.png` confirms the Defender Response badge remains legible alongside health bars, target lines, and the assault timeline.

These captures are automated visual evidence, not human playtest findings.

## Boundary result

The simulation still resolves one authoritative tick atomically. K4 only sequences the already-derived traces and impacts for presentation, and scales the effect duration so it completes before the next tick at every supported speed.
