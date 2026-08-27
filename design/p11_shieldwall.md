# P11 — Shieldwall vs. Break the Line

## Intent

Add a third teaching pair about the value and limits of a fortified anchor. Shieldwall should make ordinary room and piece pressure safer, while Shieldbreakers visibly punish a layout that concentrates every answer behind one protected frontline.

## Friendly doctrine: Anchored Gates

### Shield Wardens

- Two-cell frontline unit with reliable melee response.
- Reduces incoming damage to one adjacent friendly piece by one through a non-stacking guard effect.
- Strong when protecting a specialist, but expensive and slow to cover separated threats.

### Emergency Shutters

- Non-attacking fortification for either floor.
- Reduces damage to an adjacent room by two.
- Uses valuable space and provides no benefit against a protection-piercing enemy.

## Enemy question: Break the Line

### Shieldbreaker

- Heavy gate-road attacker that targets the living frontline or fortification with the highest maximum health before falling back to rooms.
- Ignores adjacent piece guards, room protection, and sacrificial barricades.
- Remains vulnerable to direct damage, commander intervention, and a preserved secondary line.

## Scenario: The Splintered Gate

1. Isolate one Shieldbreaker under Break the Line.
2. Combine a Shieldbreaker with a Raider under Gate Assault.
3. Combine a Shieldbreaker, Shield Guard, and Sapper under Break the Line.

## Acceptance criteria

- Validators cover numeric protection fields and Shieldbreaker targeting/protection flags.
- Shield Wardens reduce damage to an adjacent piece by one against ordinary attackers without stacking.
- Emergency Shutters reduce adjacent room damage by two against ordinary attackers.
- Shieldbreaker selects the strongest eligible frontline/fortification and ignores both protection effects plus Breakaway Barricade.
- Save/load and same-seed replay preserve target choice, health, and complete three-wave results.
- Preparation, Battle, and Results expose the pack, scenario, selected frontline target, and protection-piercing state.
- Existing P1, Relief Road, Crossbow Watch, and Bell Guard baselines remain unchanged.

## Non-goals

- No facing, knockback, armor durability, active shutter toggles, taunt UI, or arbitrary threat retargeting.
- Protection is integer damage reduction, not percentage mitigation.
- No new raster art; the first pass uses procedural shield and hammer markers.
