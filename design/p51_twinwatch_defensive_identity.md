# P51.2 — Twinwatch Bastion Defensive Identity

## Player-facing purpose

Twinwatch Bastion asks the player to split a small defense across two exposed posts. Greywatch rewards a compact core and Ash Ford rewards an empty transit lane; Twinwatch instead rewards maintaining one living combat defender at both the West Gatehouse and East Arsenal.

The intended feeling is controlled division: concentrating every unit on one approach is strong locally but leaves the opposite post unable to relay warning or absorb pressure.

## Data shape

- Keep ID: `twinwatch_bastion`
- Scenario ID: `the_divided_bell`
- Spatial rule: `paired_bastions`
- Anchors: `gate` and `armory`
- Active benefit: reduce incoming room damage by exactly 1 while both anchors have an adjacent living combat defender.
- Recovery: seven materials restore twenty-five room condition, between Greywatch's deep repair and Ash Ford's shallow repair.
- Visual identity: a cold ridge fort with two separated bastion masses and a narrow central court.

Stable functional room IDs remain unchanged so enemy definitions, save validation, reports, and inspection continue to use the existing authority boundary.

## Teaching scenario

`The Divided Bell` introduces the keep through Gate Assault, Feint and Flank, and Area Pressure. The first wave establishes the west approach, the second tests whether the east post has a mobile answer, and the third checks whether both posts remain staffed under broad damage.

Two documented answers remain viable:

- **Anchored pair:** Pike Squad at the West Gatehouse plus Shield Wardens at the East Arsenal.
- **Mobile pair:** Pike Squad at the West Gatehouse plus Runner Pair at the East Arsenal.

## Acceptance criteria

1. Selecting The Divided Bell activates a third authored room graph and ridge visual identity.
2. The paired-bastions rule is inactive with zero or one staffed anchor and active only when both anchors have adjacent living combat defenders.
3. Active paired watch reduces room damage by exactly one and turns off immediately when either anchor defender is disabled or removed.
4. Both documented answers complete all three waves without collapse for all three commanders across three fixed seeds.
5. Save/load preserves the keep identity, room state, placement state, spatial-rule state, and replay key.
6. Scenario, board, Preparation summary, high contrast, large text, and controller navigation use existing data-driven paths without hiding the fort.
7. The all-scenario matrix expands to eleven non-overwhelming scenarios, three commanders, and three seeds: 99 viable cases and 198 uninterrupted/resumed simulations.

## Non-goals

- No new pack, enemy family, doctrine, event chain, campaign map, or save-schema migration.
- No general pathfinding or freeform destruction.
- No change to Greywatch compact adjacency or Ash Ford clear-causeway behavior.
