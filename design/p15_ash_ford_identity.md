# P15 — Ash Ford Defensive Identity

## Intent

Prove a second defensive identity before adding a regional map. Ash Ford reuses the game's stable room functions and existing combat vocabulary, but presents a different room graph and asks the player to preserve a clear crossing rather than fill a compact courtyard.

## Keep contract

`ash_ford_redoubt` maps the same nine stable functional room IDs onto a long river crossing. Their displayed names, positions, criticality, and connections differ from Greywatch. Enemy definitions can therefore keep targeting stable functions while the board and report communicate a distinct place.

The causeway cells form a visible protected lane. If no defender footprint occupies that lane, incoming room damage is reduced by one because runners can move warnings, tools, and civilians across the crossing. Blocking any lane cell removes that benefit. This is deterministic and derived entirely from authoritative placement state.

Ash Ford repairs are shallow and distributed: five materials restore twenty condition. Greywatch retains its eight-material, thirty-condition repair. The player is encouraged to stabilize several exposed functions instead of restoring one deep fortification.

## Teaching scenario

`ash_ford_crossing` uses Rolling Breach, Distributed Sabotage, and Area Pressure. Runner Network plus Field Engineers is the documented baseline: mobile pieces exploit the clear causeway while repair support manages damage on separated banks.

## Acceptance criteria

- Scenario selection switches to `ash_ford_redoubt` and resets the authoritative room state to that layout.
- The room graph and recovery profile differ from Greywatch and survive save/load through the scenario ID.
- A clear causeway reduces room damage by exactly one; an occupied causeway does not.
- Both commanders complete all three waves with the documented two-pack baseline across three fixed seeds.
- Scenario selection, board rendering, room labels, and recovery cards expose the active keep rather than hard-coded Greywatch geometry.
- Existing Greywatch scenario behavior and deterministic outcomes remain unchanged; shared inventory/count assertions expand for the new content.
