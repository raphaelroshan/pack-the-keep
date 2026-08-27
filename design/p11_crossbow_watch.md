# P11 — Crossbow Watch vs. Shielded Advance

## Intent

Add one teaching pair that asks the player to answer armor with deliberate ranged positioning rather than more generic damage. The visual direction follows the supplied references: disciplined red-armored pressure opposed by a violet-accented mobile crossbow watch.

## Friendly doctrine: Layered Crossfire

### Crossbow Patrol

- Upper-wall ranged unit with finite ammunition.
- Carries the `armor_piercing` strength tag and therefore ignores authored armor reduction.
- Strong against Shield Guards and Climbers; narrow targets and ammunition keep it specialized.

### Watch Banner

- Non-attacking support piece for either floor.
- Grants one non-stacking response damage to a nearby ranged unit on the same floor.
- Asks the player to spend space and materials on a firing network rather than another attacker.

## Enemy question: Shielded Advance

### Shield Guard

- Slow gate-road infantry with 2 armor.
- Armor reduces each non-piercing defender contribution, so several ordinary attackers do not automatically equal one correct counter.
- Targets Barracks, Gate, then Inner Yard to pressure the keep’s response organization.

## Scenario: Red Banner Road

1. Isolate one Shield Guard under Shielded Advance.
2. Combine a Shield Guard with Raiders under Gate Assault.
3. Combine armor, sabotage, and a flanking Climber under Shielded Advance.

## Acceptance criteria

- Catalog validation covers the new armor fields and all cross-references.
- Pike Squad deals 2 after Shield Guard armor; an upper Crossbow Patrol deals 3 by piercing it.
- A nearby Watch Banner raises Crossbow Patrol response to 4 without stacking.
- The same seed and command sequence reproduce the same three-wave result.
- Save/load preserves active Crossbow Watch pieces and Shield Guard combat state.
- Preparation, Battle, and Results expose the new pack, scenario, doctrine, enemy, armor, and causal report.
- Existing 36-run and Relief Road balance baselines remain unchanged.

## Non-goals

- No projectile physics, directional facing, critical hits, armor durability, or new commander.
- Portrait references guide palette and silhouette only; no external image is copied into the repository.
