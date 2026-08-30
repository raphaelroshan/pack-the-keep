# K6 — Standard Cutter enemy family

## Player-facing purpose

The Standard Cutter teaches that a room assignment creates a valuable command
anchor as well as a benefit. It hunts an assigned specialist first, then falls
back to the weakest precision, support, or control piece. The player must decide
whether to stop it with an exposed precision line or preserve a mobile reserve
behind the main defense.

## Data shape

- Enemy: `standard_cutter`
- Doctrine: `cut_the_chain`
- Scenario: `the_cut_standard`
- Targeting: `unit_hunter`, with `targets_assigned_first: true`
- Fallback categories: `precision`, `support`, and `control`
- Direct counter: `crossbow_patrol`
- Alternative counter family: `mobile_response`, especially `rear_guard`

## Spatial rule and weakness

An assigned specialist anywhere in the keep is the preferred target. If no
assigned defender is active, the lowest-condition vulnerable specialist is
chosen. The Cutter has no armor, arrives late enough for three defender
responses, and is therefore weak to a prepared high-ground firing line or a
mobile reserve that can keep attacking after contact.

## Recovery consequence

If the Cutter disables an assigned specialist, its room benefit becomes
inactive. Recovery must spend one of its two actions repairing that defender or
accept the missing command benefit in the next assault.

## Visual states

- A forked-standard silhouette distinguishes the family at approach distance.
- `COMMAND` appears beside the actor.
- The existing target line resolves onto the assigned specialist.
- Existing cadence, health, wind-up, impact, damage trail, and defeated states
  remain authoritative presentation of the normal combat exchange.

## Acceptance criteria

1. Assigned living pieces are targeted before unassigned preferred categories.
2. With no assigned piece, the lowest-condition precision/support/control piece
   is targeted; with none, normal unit-hunter fallback still finds a defender.
3. Crossbow Watch and Fallback Convoy each provide a deterministic non-collapse
   answer to the authored three-wave scenario.
4. The enemy is explained in forecast, inspection, battle, Recovery, and Results
   through existing data-driven presentation.
5. Save identity, battle timing, accessibility, controller focus, and all prior
   scenarios remain unchanged.

## Focused tests

- Catalog and validator coverage for the new boolean targeting contract.
- Target-priority coverage for assigned and fallback targets.
- Same-seed save/load replay coverage.
- Two-loadout scenario viability coverage.
- Board visual-registry and normal-flow scenario-selection coverage.
