# P42 Battle Command Hierarchy Verification

- Build: `0.24.1-battle-command-hierarchy`
- Scope: presentation-only Battle command grouping and focus
- Authoritative simulation changes: none

## Automated evidence

- `tests/test_p42_battle_command_hierarchy.gd` verifies the default visible hierarchy, collapsed tactical controls, disclosure invariance, focused-threat routing, First Watch focus, and 125% stacked layout.
- Existing pause, readiness, speed, manual-step, controller, tutorial, response-preview, and deterministic combat tests remain in `scripts/verify.sh`.

## Visual evidence

A local 1600×900 render was inspected with the command rail at scroll origin. Battle state, Sound the Bell, Lockdown availability, threat guidance, focused Raider action, and the Tactical controls disclosure are visible before the detailed response card. The fortress and contact timeline remain the dominant visual body.

## Human evidence

No human comprehension or pacing claim is made. The next controlled playtest should verify that a new player notices the bell/pause action, identifies the focused threat, and discovers Tactical controls only when needed.
