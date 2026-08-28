# P17 Combat Target Commitments

## Player-facing purpose

Mixed waves should ask whether the keep has enough distinct answers, not reward one defender for attacking every compatible enemy in the same second. When the battle is paused, the player should be able to focus a threat and see which defenders will commit on the next step, how much damage they are expected to deal, and whether the threat will still reach contact.

## Authoritative data and owner

`PackKeepState` remains the sole combat authority. No new save fields are required. Existing piece instance fields (`attack_cooldown`, `ammo`, `attacks`, `damage_dealt`, `targets_stopped`, and `last_target`) and enemy instance fields (`hp`, `arrival_step`, `damage`, `slot`, and `defeated`) determine the next engagement.

Target priority is deterministic and evaluated in this order:

1. Already at contact on the resolving step.
2. Earlier arrival step.
3. Higher effective damage after piece rules and armor.
4. Higher enemy contact damage.
5. Lower projected remaining health.
6. Lower stable wave slot.

Each ready defender may appear in at most one engagement per step. Planned damage is applied to projected health while later defenders choose, preventing avoidable overcommitment. `defender_response_preview()` derives the same plan without changing state.

## Acceptance criteria

1. A defender attacks at most one enemy during one combat step.
2. Support and fortification pieces with no authored attack never inherit incidental combat damage.
3. Ranged ammunition and cooldown tick at most once per defender per step.
4. All defender engagements resolve before surviving enemies make contact.
5. Mixed threats select targets by the documented stable priority and replay identically after save/load.
6. The focused-enemy panel shows next-step attackers, expected damage, projected health, and contact state.
7. All nine scenarios remain viable for both commanders and three seeds in uninterrupted and resumed runs.

## Tests

- `tests/test_initial_combat.gd`: mixed-threat targeting, one-shot ammunition, cooldown ticking, preview non-mutation, and save/load preview parity.
- `tests/test_keep_state.gd`: baseline battle outcome and causal report regression.
- `tests/test_p11_shieldwall.gd`: a two-line Shieldwall teaching layout still holds against three authored breaker waves.
- `tests/test_p12_alpha_scenario_matrix.gd`: 54 viable scenario combinations and 108 deterministic uninterrupted/resumed simulations.
- `tests/test_multi_wave.gd` and `tests/test_multi_wave_ui.gd`: authored sequence and presentation regression.

## Non-goals

- Direct player-issued focus-fire or retarget commands.
- Projectile travel, collision, movement simulation, or line-of-sight pathfinding.
- New enemies, packs, commanders, or combat resources.
- Changing save schema 4.
- Replacing authored six-step waves with an unbounded real-time scheduler.
