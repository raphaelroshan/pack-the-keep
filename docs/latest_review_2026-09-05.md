# Pack the Keep — latest visual and implementation review

**Build:** `0.70.0-combat-cadence`

**Roadmap packet:** P82

## Result

The 1280×720 and 2560×1440 flows retain the P81 clarity improvements and give combat more room to read. A normal-speed six-tick assault now lasts roughly nine seconds instead of six, while half and double speed remain proportional and manual steps remain immediate.

- Recovery says `Preserve flexibility` when neither rooms nor defenders need repair; it no longer promotes a stable room as damage control.
- War Council describes opening pressure and garrison stakes in player language.
- Targetless approaching enemies read `Not locked yet` consistently in the dossier, roster, inspector, and board tooltip.
- Results exposes `TRY NEXT` before detailed analysis and replaces implementation labels with assault, plan, and decision language.
- Normal Settings contains only player options. Session Notes remains a `--debug-ui` instrument.
- The capture harness recognizes each First Watch briefing, records only completed optional beats, and terminates correctly when Last Stand collapses before Recovery.
- Shared-target attackers retain deterministic contact spacing, and crowded assaults reserve the on-board status badge for the focused threat while keeping every enemy in the roster and timeline.

## Evidence reviewed

- `docs/visual_evidence/v0.70.0-combat-cadence-greywatch-1280x720/`
- `docs/visual_evidence/v0.70.0-combat-cadence-greywatch-2560x1440/`
- `docs/visual_evidence/v0.70.0-combat-cadence-ash-ford-1280x720/`
- `docs/visual_evidence/v0.70.0-combat-cadence-ash-ford-2560x1440/`
- Temporary branch checks: First Watch introduction, normal Settings, and overwhelming Last Stand early terminal flow.

## Next risk

The next bounded task is real P16 observation of decision comprehension and preferred combat cadence. Automation can prove timing, outcomes, and visibility, but not enjoyment.

## Boundary

These are automated captures and deterministic tests, not human P16 observations. Owner approval remains required before external distribution.
