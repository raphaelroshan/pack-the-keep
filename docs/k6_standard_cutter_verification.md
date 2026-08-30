# K6 — Standard Cutter verification

- Build: `0.28.0-standard-cutter`
- Scope: one assigned-specialist-hunter enemy family and one authored teaching scenario

## Automated evidence

`tests/test_k6_standard_cutter.gd` verifies assigned-first targeting, vulnerable-specialist fallback, unit-only fallback, catalog rejection of malformed targeting data, deterministic save/resume parity, and twelve two-answer scenario runs across both commanders and three seeds. `tests/test_k6_standard_cutter_ui.gd` verifies normal-flow scenario selection, visible recommended answers, focused counter text, assigned-hunter language, and the dedicated standard silhouette. The P12 matrix expands to 60 viable cases and 120 uninterrupted/resumed simulations.

## Visual evidence

The 1600×900 captures in `/tmp/pack-the-keep-k6` show The Cut Standard's question and answer framing in Preparation and a paused tick-three contact where the Cutter's forked standard, `CMD` cue, assigned Pike target, cadence, projected Rear Guard response, health, and direct counter remain readable with the keep visible.

This is automated visual evidence, not a human playtest finding.
