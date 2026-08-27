# P11 — Hardened Vanguard Challenge Modifier

## Intent

Close the P11 content-breadth phase with an optional difficulty choice that exercises the existing modifier contract without granting permanent player power. The Campaign Ledger should support more than one data-driven modifier and make the selected trade-off clear before a run begins.

## Player question

Can the same readable defense survive when every enemy formation takes longer to break?

## Rules

1. Completing The Relief Road unlocks both Roadside Intelligence and Hardened Vanguard.
2. Exactly one modifier, or no modifier, may be equipped for the next run.
3. Hardened Vanguard adds 2 current and maximum health to every enemy when each wave is created.
4. The bonus changes no arrival timing, target selection, damage, armor, signal, or protection rule.
5. The Campaign Ledger names the selected modifier, its status, effect, and limitation before applying it.

## Acceptance criteria

- Modifier definitions remain individual validated JSON records with stable IDs.
- `enemy_health_bonus` requires a positive bounded integer and is rejected on unrelated effects.
- A wave started with Hardened Vanguard stores the increased health in enemy runtime state.
- Save/load during that wave and same-seed replay preserve identical enemy state and outcomes.
- Roadside Intelligence still costs one starting morale and reveals composition exactly as before.
- Locked, unlocked, equipped, unequipped, and mutually exclusive selection paths are covered in core and UI tests.
- Existing no-modifier scenario baselines remain unchanged.

## Non-goals

- No score multiplier, material reward, achievement, difficulty ladder, or modifier stacking.
- No per-enemy random health roll.
- No mid-run modifier changes.

**Trade-off:** The first challenge modifier increases durability uniformly. This is deliberately narrow so the selection, validation, persistence, and causal presentation contract can be proven before modifiers alter multiple systems.
