# P52.1 — Twilight Crossroads Recovery Choice

## Intent

Make the final phase of The Twilight Road replay differently because of an authored recovery decision, not because of hidden randomness, grind, or a new combat subsystem.

## Player-facing contract

After phase two, the road crews have time to prepare exactly one route before the combined final assault:

- **Replant the road stakes** spends one recovery action and delays every Outrider in phase three.
- **Carry lamp oil to the stair** spends one recovery action and reveals every Gloam Knife in phase three.

The event states both consequences before selection. The remaining recovery action can still be used for repair or reassignment. The chosen preparation appears immediately in the next forecast, in enemy inspection, in the battle roster, and in causal battle narration.

## Simulation authority

- Stable event ID: `twilight_crossroads`.
- Trigger: The Twilight Road, Recovery after wave two, once per run.
- Stable one-shot flags: `twilight_stakes_ready` and `twilight_lamps_ready`.
- `KeepState` applies either flag only while constructing phase-three enemy state, then marks it spent.
- The existing per-enemy `momentum_delayed` and `concealment_revealed` fields remain authoritative during combat and across save/load.
- Existing Stake Line and Lantern Post counters remain valid. The event supplements a missing counter; it does not weaken or replace placed defenses.

## Viable answers

The existing prepared-route and flexible-response plans remain viable. Two mixed plans prove the replay choice changes the build question:

1. Road Wardens plus Crossbow Watch chooses lamp oil, retaining prepared Outrider delay while buying final-wave visibility.
2. Lantern Watch plus Runner Network chooses road stakes, retaining visibility and close interception while buying final-wave tempo.

Neither branch awards permanent progression or changes content unlocks.

## Verification

- Both choices consume exactly one recovery action and survive an active-event save/load checkpoint.
- Before the choice, the final-wave forecast shows neither authored route preparation for mixed builds.
- After the choice, the forecast and spawned enemies reflect only the selected route preparation.
- One-shot flags are spent when phase three starts and do not leak into later state.
- Both mixed plans complete all three phases for all commanders and fixed seeds, with uninterrupted/save-resumed identity.
- The event panel remains readable and controller-reachable at 1280×720 and 2560×1440.
