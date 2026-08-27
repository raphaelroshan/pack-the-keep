# Pack the Keep — Initial Real-Time Auto-Battle Contract

## Player-facing model

Pack the Keep is a **real-time presentation of a deterministic auto-battle**. The player does not issue individual attack commands. Instead, the player chooses a commander, opens packs, places and assigns defenders, starts an invasion, and decides when to pause, inspect, use a commander skill, or accept the next automatic battle step. The same seed and the same state-changing commands must always produce the same result.

The UI clock runs at `0.5x`, `1x`, or `2x`, but it only controls when the authoritative simulation receives a one-second step. Manual stepping is the inspection tool for testing and accessibility; it is not a separate combat ruleset.

## Enemy path and behavior

Each enemy enters through a named route and advances toward a behavior-defined target. Raiders take the Gate Road and prioritize the Gate. Sappers use the Service Lane and choose a vulnerable Workshop, Supply Room, Armory, or Repair Station. Climbers use the North Tower Line, can target an upper-floor defender, and otherwise pressure North Tower or Old Chapel. Siege Beasts use the Outer Approach and apply area pressure to up to three eligible rooms when contact resolves.

An enemy begins as `APPROACHING`. At its authored arrival step it resolves a target using the authoritative lowest-condition and stable-ID tie-break rules, then attacks that target on each subsequent contact step. Defenders can stop an enemy before contact. A stopped enemy contributes no room damage, while an enemy that reaches contact produces a causal report entry and may damage a room or piece.

## Defender combat roles

Defenders auto-attack every eligible battle step when their attack interval is ready, they are alive and enabled, and their counter family can affect the current enemy. Melee defenders represent contact control: Pike Squad is a short-range, no-ammunition Gate Road counter and becomes stronger when assigned to Gate. Ranged defenders represent prepared fire: Fire Team controls approach zones and is the primary Climber and Siege Beast counter; Fire Brazier extends the upper-floor denial role when available. Repair Station and Scout Post are support pieces and do not deal direct attack damage in the initial run.

Location matters through floor and assignment rules. Pike Squad’s Gate Road response is not valid from an unrelated route. Fire Team’s strongest Climber response requires an upper-floor position or its Inner Yard response assignment. Castellan adjacency, Warden open lanes, specialist assignments, and Rally/Lockdown are skills that modify the otherwise automatic attack or mitigation routine. These modifiers are deterministic and reported in the battle log.

## Ammunition

Ranged attack pieces have finite battle ammunition. A successful ranged attack spends one round; an empty weapon cannot contribute until the next recovery reload. Melee pieces use no ammunition. Ammunition is visible in the piece inspector and map label, and the aggregate combat report records rounds spent. Completing the authored repair interval reloads all surviving pieces to their maximum ammunition. Reloading is a recovery transition, not a hidden mid-battle action.

The initial ammunition values are intentionally small and readable: Fire Team carries four rounds and Fire Brazier carries three when available. They are balance levers, not realism claims. A later slice can add resupply buildings, ammunition packs, skills that conserve rounds, or deliberate reload choices without changing the command-driven architecture.

## Skills and interventions

A piece’s skill is its authored role and assignment effect, not a free-form ability button. Commander skills are the explicit intervention layer: Lockdown reduces the next contact’s room damage and repairs placed pieces; Rally restores morale and coordinates the next response. These skills are armed once per wave, consume command points, and resolve through the authoritative core on the next battle step.

## Outcomes and recovery

A wave ends when all enemies are stopped or the six-step authored timeline completes. A Hold grants recovery resources and morale, a Partial Breach preserves play and opens a two-action repair interval, and Collapse ends the interval and returns the run to preparation. The recovery panel prioritizes critical breached rooms, critical damaged rooms, and then the lowest-condition remaining rooms using stable tie-breaks. Repairs and reloads remain explicit state transitions.

## Verification criteria

The initial run is complete when a tester can place a starter defender, start an invasion, watch it advance automatically in real time, pause and inspect a focused enemy, observe route/target/role/ammunition changes, use a commander skill, read a causal report, reach a Hold/Partial Breach/Collapse outcome, and enter recovery without a manual debug path. Tests must prove that presentation speed, pause, focus selection, preview, reload timing, and UI accessibility do not introduce nondeterminism. A same-seed command replay must produce the same serialized outcome and combat metrics.

## Boundaries

This slice does not add individual projectile simulation, physics-based pathfinding, multiplayer, direct target commands, ammo resupply buildings, controller remapping, final animation sheets, authored sound effects, or commercial storefront readiness. The path model is authored and deterministic; the presentation may later animate movement between the named route and target without moving the rules into the renderer.
