# K4 — Battle beat readability

## Purpose

Make each deterministic assault tick readable as a short combat sentence: forecast, approach, target lock, wind-up, defender response, hostile impact, consequence, and settle. This is a presentation timeline over the existing authoritative result, not a new combat scheduler.

## Contract

- `PackKeepState` still resolves the entire tick, including target selection, damage, ammunition, cooldowns, room state, and outcomes.
- The UI derives ambient beats from current authoritative state and stages already-resolved exchange traces afterward.
- Effect duration scales inversely with 0.5x, 1x, and 2x playback so one presentation exchange fits within its next simulation interval.
- Reduced motion replaces travel and recoil with a short static consequence state.
- Pausing, manual stepping, replay keys, saves, health values, and attack order are unchanged.

## Acceptance

1. Tick-zero readiness is labelled Forecast.
2. Moving threats are labelled Approach; committed targets transition through Target Lock and Wind-up.
3. A resolved exchange presents defender response before hostile impact, then exposes damage consequence and settling.
4. Ranged projectiles, melee lunges, demolition strikes, health trails, damage labels, and recoil retain their role-specific grammar.
5. 2x effects finish within the next half-second tick; 0.5x effects remain legible without overlapping the next two-second tick.
6. Reduced motion suppresses travel and recoil while retaining target, damage, and consequence information.
7. Beat projection is deterministic and does not mutate serialized state.
