# P51.5 — Twilight Road Combined Challenge

## Player-facing purpose

The Twilight Road asks the player to preserve two kinds of readiness at once: enough route control or damage to answer an early Outrider, and enough light or close interception to answer a concealed Gloam Knife. The first two phases restate each question alone; the final phase combines them without introducing a third rule.

## Data shape and authority

- Doctrine ID: `twilight_crossing`
- Scenario ID: `the_twilight_road`
- Phase one: `rapid_breakthrough` with one Outrider.
- Phase two: `veiled_entry` with one Gloam Knife.
- Phase three: `twilight_crossing` with two Outriders and two Gloam Knives.

The scenario composes existing authoritative `momentum_profile` and `concealment_profile` behavior. It adds no new combat state, command, save field, target mode, or presentation authority.

## Viable answers

1. **Prepared routes:** Road Wardens plus Lantern Watch divide roles cleanly. Stake Line delays Outriders for Hook Guard while Lantern Post reveals Gloam Knives for Dusk Bow.
2. **Flexible response:** Crossbow Watch plus Runner Network concentrate ranged damage on Outriders while an open-lane Runner Pair intercepts concealed Gloam Knives in melee.

Both plans must complete all three phases for every commander across three fixed seeds and remain byte-identical after an active-wave save/load checkpoint.

## Acceptance criteria

1. The scenario introduces Outrider and Gloam Knife separately before combining them.
2. The final forecast and Battle roster expose charge and visibility states together.
3. Road Wardens plus Lantern Watch and Crossbow Watch plus Runner Network each avoid collapse in all eighteen commander/seed runs.
4. Save/load preserves both special states and the canonical replay key.
5. War Council names both questions and both plan families without presenting a mandatory build.
6. The all-scenario matrix expands to fourteen non-overwhelming scenarios, three commanders, and three seeds: 126 viable cases and 252 uninterrupted/resumed simulations.

## Non-goals

- No new enemy, pack, commander, keep, combat modifier, campaign reward, or save migration.
- No random composition, hidden counter, forced pack opening, or fourth phase.
- No claim of human balance or public-alpha readiness.
