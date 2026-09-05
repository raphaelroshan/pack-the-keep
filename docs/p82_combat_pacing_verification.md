# P82 combat pacing verification

**Build:** `0.70.0-combat-cadence`  
**Engine:** Godot 4.7.2 stable  
**Evidence type:** deterministic automation and visual capture; not human P16 evidence

At 1× speed, each authoritative combat tick now spans 1.5 real seconds, making a six-tick phase roughly nine seconds. Half and double speed remain proportional, manual stepping remains immediate, and attack effects finish within their corresponding interval. The authoritative simulation still receives the same six ticks and produces unchanged seeded outcomes.

Attackers that share a target now retain a deterministic three-column contact formation. When four or more enemies are active, only the focused actor receives an on-board status badge; the timeline and roster continue to describe every threat.

## Evidence

- `docs/visual_evidence/v0.70.0-combat-cadence-greywatch-1280x720/`
- `docs/visual_evidence/v0.70.0-combat-cadence-greywatch-2560x1440/`
- `docs/visual_evidence/v0.70.0-combat-cadence-ash-ford-1280x720/`
- `docs/visual_evidence/v0.70.0-combat-cadence-ash-ford-2560x1440/`
- Focused overwhelming-flow review: `/tmp/ptk-p82-last-stand-spacing/04a_paused_threat_dossier.png`

Focused automated checks cover wall-clock pacing, pause and auto-pause behavior, scaled exchange duration, shared-target spacing, crowded badge suppression, save boundaries, and unchanged core combat results. The full repository agent-QA gate is the release-candidate check.

## Boundary

This establishes a testable default cadence, not a human preference result. P16 observation should determine whether 1.5 seconds per tick is retained or tuned.
