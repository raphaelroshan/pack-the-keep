# Pack the Keep — latest visual and implementation review

**Build:** `0.69.0-gameplay-clarity`

**Roadmap packet:** P81

## Result

The 1280×720 and 2560×1440 flows retain the board-first vertical while removing several trust-breaking contradictions found by the gameplay and writing evaluators.

- Recovery says `Preserve flexibility` when neither rooms nor defenders need repair; it no longer promotes a stable room as damage control.
- War Council describes opening pressure and garrison stakes in player language.
- Targetless approaching enemies read `Not locked yet` consistently in the dossier, roster, inspector, and board tooltip.
- Results exposes `TRY NEXT` before detailed analysis and replaces implementation labels with assault, plan, and decision language.
- Normal Settings contains only player options. Session Notes remains a `--debug-ui` instrument.
- The capture harness recognizes each First Watch briefing, records only completed optional beats, and terminates correctly when Last Stand collapses before Recovery.

## Evidence reviewed

- `docs/visual_evidence/v0.69.0-gameplay-clarity-greywatch-1280x720/`
- `docs/visual_evidence/v0.69.0-gameplay-clarity-greywatch-2560x1440/`
- `docs/visual_evidence/v0.69.0-gameplay-clarity-ash-ford-1280x720/`
- `docs/visual_evidence/v0.69.0-gameplay-clarity-ash-ford-2560x1440/`
- Temporary branch checks: First Watch introduction, normal Settings, and overwhelming Last Stand early terminal flow.

## Next risk

The next bounded experiment is combat pacing and actor congestion at the gate. Current phases remain deterministic six-tick simulations; changing their observable duration or spatial separation requires separate balance and readability evidence.

## Boundary

These are automated captures and deterministic tests, not human P16 observations. Owner approval remains required before external distribution.
