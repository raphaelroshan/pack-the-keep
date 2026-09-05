# P81 gameplay clarity verification

**Build:** `0.69.0-gameplay-clarity`  
**Engine:** Godot 4.7.2 stable  
**Automated evidence:** not human P16 evidence

P81 removes contradictions found by the gameplay and writing evaluations without changing combat authority or balance. An undamaged Recovery now prioritizes flexibility, the War Council describes opening pressure instead of seeds, targetless threats state that their target is not locked, and Results places one concrete replay experiment before its analysis and chronology. Normal Settings contains only player controls; Session Notes remains available only with `--debug-ui`.

The capture harness now gives tutorial steps distinct readiness states, records inspection and intervention only when they were actually captured, and accepts an authoritative terminal result before the nominal third phase. This was exercised with the staged First Watch introduction, Ash Ford, Greywatch, and the overwhelming Last Stand.

## Visual evidence

- `docs/visual_evidence/v0.69.0-gameplay-clarity-greywatch-1280x720/`
- `docs/visual_evidence/v0.69.0-gameplay-clarity-greywatch-2560x1440/`
- `docs/visual_evidence/v0.69.0-gameplay-clarity-ash-ford-1280x720/`
- `docs/visual_evidence/v0.69.0-gameplay-clarity-ash-ford-2560x1440/`

Focused regression coverage includes `test_keep_state.gd`, P2, P10, P30, P38, P48, P52, P53, P79, P80, K5, K7, the copy validator, the investment validators, and release identity. The repository-owned agent-QA result remains the final gate.

## Boundary

The next gameplay risk is combat pacing and actor congestion. It should be handled as a separate simulation/presentation experiment with before-and-after timing evidence, not folded into this language and evidence-reliability pass.
