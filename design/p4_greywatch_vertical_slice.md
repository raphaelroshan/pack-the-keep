# Pack the Keep — P4 Greywatch Vertical Slice Decision

## Decision

P4 turns the three-wave auto-sequence into a complete, replayable Greywatch vertical slice. The slice keeps the deterministic simulation and fort-first board as the source of truth, then adds enough decision feedback for a tester to understand why a run held, partially breached, or collapsed.

The core contract is deliberately small. A resolved wave records an immutable summary row. The existing two-action recovery interval remains the only boundary between waves. Recovery advice identifies the next doctrine and names a trade-off, but it never performs a repair, assignment, placement, or pack action automatically. The player must still spend or preserve the actions and explicitly close the interval.

## Recovery trade-offs

The first recovery choice is between restoring a damaged function and improving the next response. Repairing a room spends materials and one interval action. Assigning a compatible piece spends an action but changes the next wave’s response behavior. Unused actions are recorded rather than silently treated as free repairs. This maintains the original Greywatch principle: repair one exposed function while leaving another risk visible.

The advice is deterministic and advisory. Distributed Sabotage points toward Workshop or Supply Room coverage, Feint and Flank points toward North Tower or Old Chapel coverage, and Area Pressure points toward Inner Yard and adjacent support rooms. The authoritative commands continue to validate affordability, role, adjacency, floor, and action budget.

## Scorecard contract

Each completed wave contributes its wave number, doctrine, outcome, breach level, morale after resolution, defeated enemies, room damage, piece damage, ammunition spent, enemy attacks, and recovery actions used. The scenario scorecard aggregates those rows and exposes a deterministic replay key based on scenario, commander, and seed. The scorecard is persisted as part of the existing schema-compatible payload; old saves simply load with an empty history.

The scorecard is intentionally descriptive rather than a new reward economy. It gives testers a stable way to compare layouts and commanders without introducing campaign progression, rarity, multiplayer balancing, or storefront claims before the core loop is proven.

## Commander and layout lenses

The Castellan’s compact-adjacency identity and Lockdown ability remain unchanged. The Warden’s open-lane identity and Rally ability remain unchanged. P4 makes those differences visible beside the board by showing a layout lens and live counts for ground, upper, wall, and courtyard placements. A selected piece can be removed during Preparation so the player can re-place it and compare compact and open-lane arrangements. Removal is not allowed during Battle or recovery and does not refund materials.

This is a deliberately reversible layout tool rather than a new construction system. It provides meaningful comparison without adding drag-and-drop complexity, hidden repositioning rules, or a second placement path.

## Non-goals and trade-offs

P4 does not add a new faction, a fourth wave, a procedural keep generator, generated art, campaign meta-progression, or a new save schema. The procedural fort renderer remains a functional visual fallback. The focus is learning whether a player can read the forecast, choose a recovery priority, adapt the next layout, and understand the final result.

The scorecard uses compact text rows to preserve the fort’s screen space. At the current 1280×720 playtest target, the board and primary action remain the visual priority; dense historical detail belongs in a future expandable report if tester feedback shows that the compact format is insufficient.

## Acceptance criteria

A tester can start Gatehouse Lock, inspect the layout lens, remove and re-place a selected piece during Preparation, resolve all three authored waves, see the recovery advice after each non-collapse wave, use explicit repair or assignment actions, and read a terminal three-row scorecard. Repeating the same seed, commander, layout, and commands produces the same scorecard and causal report. Changing the commander or layout changes the visible lens and may change the outcome without changing the simulation’s deterministic rules.
