# P36 Assault Readiness and Phase Transitions

## Intent

The player should never lose the first readable combat beat because an assault starts running while their attention is moving from Preparation or Recovery to the battlefield. The first assault gets an explicit ready state; later phases pause only when their doctrine or enemy family changes.

## Authority

Readiness is presentation-only. `PackKeepState.start_wave()` still creates the authoritative wave immediately at tick zero. The UI pauses presentation before any delta is submitted and clears readiness through the existing pause/resume input. No new combat state, timer, wave, or save field is introduced.

## Behavior

- Starting phase one opens Battle at tick zero with **Sound the Bell — Begin Phase 1** focused.
- The ready line names the current doctrine and arriving enemy families.
- Finishing recovery starts the next authoritative phase as before.
- If doctrine changes or a new enemy family appears, the new phase opens ready and paused.
- If both doctrine and enemy roster are unchanged, the phase continues live after recovery.
- Loading an active tick-zero save reconstructs readiness from authored scenario data; later-tick saves resume with the existing behavior.
- First Watch retains its stricter authored pause-and-inspect steps.

## Acceptance

- Waiting in readiness does not advance the battle step or clock.
- Space, controller pause binding, and the primary action all begin the same continuous simulation.
- Manual step is unavailable until readiness is acknowledged.
- Speed selection before start does not alter the eventual authoritative result.
- Save/load at tick-zero readiness restores the same wave, roster, and ready reason without adding save fields.
- Existing quick-playtest, tutorial, pause, and multi-wave flows remain deterministic.

