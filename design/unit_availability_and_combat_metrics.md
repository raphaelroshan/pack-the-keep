# Pack the Keep — Unit Availability and Combat Metrics

## Design goal

Units should enter the keep because the player chose a coherent pack, not because a large roster was silently available. Once placed, combat should remain readable through a small set of health and role metrics rather than a spreadsheet of hidden modifiers.

## Availability model

Greywatch begins with a **Pike Line starter kit** containing Pike Squad and Narrow Gate. The starter kit is always available so the first battle can be played immediately. Additional units become available only when their pack is opened during Preparation.

| Availability state | Meaning | Placement rule |
|---|---|---|
| **Starter** | Pike Squad and Narrow Gate are available at run start | May be placed before opening another pack |
| **Pack unlocked** | Opening a pack adds its pieces to the available catalogue | New pieces may be placed immediately if materials and space allow |
| **Placed** | The unit exists in Greywatch with mutable health and metrics | It may be assigned during a repair interval |
| **Disabled** | Unit health reached zero | It contributes no attacks or defense until repaired |
| **Removed** | Unit is removed from the layout | Its instance metrics remain in the report for the current run |

Each pack can be opened once per run. The prototype allows two additional pack openings before the first wave and one new pack opening during each later Preparation phase. Packs cannot be opened during combat or inside a repair interval. This keeps availability meaningful without introducing rarity or duplicate collection.

## Combat stat contract

Static unit definitions live in `PIECES`. Runtime instances store only mutable state and counters. The minimum combat profile is:

| Metric | Stored where | Purpose |
|---|---|---|
| `max_health` | Static definition and instance | Defines the unit’s full durability |
| `health` | Instance | Current durability; reaches zero when disabled |
| `attack` | Static definition | Base damage contribution against valid enemy types |
| `defense` | Static definition | Future-facing protection value and room adjacency context |
| `attack_interval` | Static definition | Number of battle steps between attacks |
| `range` | Static definition | Readable lane or floor reach, not a hidden global multiplier |
| `role` and `targets` | Static definition | Explains what the unit is for and against |
| `condition` | Instance mirror | Normalized display value, `health / max_health` |

The prototype uses one attack resolution per eligible unit per battle step. There is no floating-point combat randomness. A unit with zero health is disabled, keeps its placement footprint, and produces a named report line.

## Efficient tracking

The simulation uses dictionaries keyed by stable instance ID. Static definitions are read from `PIECES`; the instance stores `health`, `condition`, `assignment`, `attack_cooldown`, `attacks`, `damage_dealt`, `targets_stopped`, `last_target`, and `disabled`. This avoids creating a separate object for every damage event while preserving enough data for a battle report.

The run-level `combat_metrics` dictionary aggregates battle steps, unit attacks, damage dealt, enemy attacks, room damage, piece damage, repairs, disabled units, and defeated enemies. The player sees a concise summary; agents and tests can inspect the full dictionary. Metrics are updated at the moment an action resolves rather than reconstructed by parsing log strings.

## Enemy health and attack tracking

Enemy instances carry `max_health`, `hp`, `damage`, `arrival_step`, `target`, `attacks_received`, `damage_taken`, and `defeated`. The existing `hp` field remains as a compatibility alias for the current prototype. An enemy’s health bar is shown with its route and doctrine, and a defeated enemy disappears from the active actor display while remaining in the report.

Enemy attacks increment `enemy_attacks` and either `room_damage` or `piece_damage`. Room damage is measured in condition points; piece damage is measured against unit health. This preserves the distinction between a keep function being breached and a defender being disabled.

## Upgrade and acquisition boundaries

The first slice does not add unit levels, rarity, duplicate copies, permanent attack inflation, or an independent experience currency. Progression can later add new unit definitions or side-grade rules, but the combat contract must continue to answer three questions: what is this unit for, how healthy is it, and what did it accomplish in the last battle?
