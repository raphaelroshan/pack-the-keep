# P51.4 — Lantern Watch / Gloam Knife Teaching Pair

## Player-facing purpose

The Lantern Watch asks whether the player will spend an upper-wall footprint to reveal a concealed approach or expose melee defenders to stop it at close range. Gloam Knives are unit hunters, not room destroyers: until a living Lantern Post covers one of their authored approach rooms, ranged defenders cannot commit damage to them. Melee defenders can still intercept the threat normally.

The intended lesson is visibility and coverage rather than raw durability. A revealed Gloam Knife becomes an ordinary precision target; an unrevealed one forces the keep to rely on close interception and accept the contact risk that creates.

## Data shape and authority

- Pack ID: `lantern_watch`
- Pieces: `dusk_bow` and `lantern_post`
- Enemy ID: `gloam_knife`
- Doctrine ID: `veiled_entry`
- Scenario ID: `the_unlit_stair`
- Enemy profile: `concealment_profile`
- Counter modifier: `route_reveal`
- Visibility rule: a living route-reveal piece adjacent to any authored target room when the wave begins marks Gloam Knives as revealed for that wave. Otherwise their concealment blocks ranged defender damage while melee response remains legal.

`PackKeepState` owns reveal detection, response eligibility, logs, inspection, forecast state, and persistence. Presentation reads `concealment_revealed` and never changes it. Save schema 4 remains valid because active enemies already serialize their authoritative dictionaries; validation gains an optional boolean check for the new state.

## Counterplay

Three visible answers are supported:

1. **Lantern Watch:** Lantern Post reveals the route while Dusk Bow commits ranged damage before contact.
2. **Road Wardens:** Hook Guard ignores concealment by fighting in melee and can stop the isolated threat without lighting the route.
3. **Runner Network:** Runner Pair remains a mobile melee fallback when an open response lane is preserved.

The isolated scenario proves the first two as full three-wave baselines. Concealment must not weaken melee response, alter enemy arrival timing, or affect unrelated enemies.

## Trade-off and readability

- Lantern Post occupies an upper-wall footprint, deals no direct damage, and only reveals authored concealed approaches.
- Dusk Bow has finite ammunition and narrow targets; without route light it cannot damage a concealed Gloam Knife.
- Gloam Knives visibly announce `VEILED` or `REVEALED` in forecast, battle roster, focus inspection, and the event feed.
- Defender previews omit ranged attacks that concealment blocks, so the displayed next response matches authoritative combat.

## Acceptance criteria

1. Runtime validation rejects malformed or unknown concealment counter definitions.
2. An unrevealed Gloam Knife takes no ranged damage, but legal melee damage remains unchanged.
3. A living Lantern Post beside an authored approach room reveals the threat at wave start; moving, disabling, or omitting it prevents reveal.
4. Lantern Watch and Road Wardens each complete all three `the_unlit_stair` waves without collapse for all three commanders across three fixed seeds.
5. Runner Pair visibly damages and can stop Gloam Knives while it retains an open lane.
6. Save/load preserves reveal state, target state, and replay identity exactly.
7. War Council, Preparation, Battle inspection, map/timeline labels, large text, high contrast, and controller paths expose the visibility question without hiding the fortress.
8. The all-scenario matrix expands to thirteen non-overwhelming scenarios, three commanders, and three seeds: 117 viable cases and 234 uninterrupted/resumed simulations.

## Non-goals

- No stealth movement, detection radius simulation, accuracy rolls, fog of war, status stacking, or new input mode.
- No change to ordinary enemy arrival timing, signal smoke, breakthrough momentum, armor, or protection.
- No combined P51 challenge until this pair ships independently.
- No save-schema migration, campaign economy, human-test claim, or public-alpha approval.
