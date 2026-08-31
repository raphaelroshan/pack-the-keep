# P51.3 — Road Wardens / Outrider Teaching Pair

## Player-facing purpose

The Road Wardens ask whether the player will spend space on a prepared interception line or spend damage on stopping a fast threat outright. The Outrider is a unit hunter, not a room destroyer: it reaches exposed precision, recon, and support defenders one tick earlier than ordinary pressure unless a living Stake Line controls one of its authored approach rooms.

The intended lesson is tempo rather than raw durability. A delayed charge gives a modest Hook Guard enough time to finish its target; an undelayed charge can still be answered by concentrated precision or an open-lane mobile reserve.

## Data shape and authority

- Pack ID: `road_wardens`
- Pieces: `hook_guard` and `stake_line`
- Enemy ID: `outrider`
- Doctrine ID: `rapid_breakthrough`
- Scenario ID: `before_the_horn`
- Enemy profile: `momentum_profile`
- Counter modifier: `route_delay`
- Effective timing: the Outrider's authored contact tick is increased by exactly one when a living route-delay piece is adjacent to any room in its authored target route.

`PackKeepState` owns counter detection, effective arrival timing, target selection, damage, logs, inspection, and persistence. Presentation reads the resulting `momentum_delayed` state and never changes it. Save schema 4 remains valid because active enemies already serialize their authoritative dictionaries; validation gains an optional boolean check for the new state.

## Counterplay

Three visible answers are supported:

1. **Road Wardens:** Stake Line delays contact while Hook Guard commits repeated control damage.
2. **Crossbow Watch:** Crossbow Patrol plus Watch Banner deals enough focused ranged damage to stop the Outrider on its original contact tick.
3. **Runner Network:** Runner Pair uses an open lane to intercept the fast unit without buying the dedicated pack.

The isolated scenario proves the first two as full three-wave baselines. Runner Network remains a declared fallback family and receives direct combat coverage.

## Trade-off and readability

- Stake Line occupies a two-cell ground edge, deals no direct damage, and only affects authored breakthrough momentum.
- Hook Guard is ground-only, has no armor piercing, and contributes little against enemies outside its narrow target list.
- Outriders visibly announce `MOMENTUM LIVE` or `CHARGE DELAYED`, expose both base and effective contact timing, and continue to clear defenders before falling back to ordinary unit-hunter targeting.
- The event feed names why timing changed at assault start.

## Acceptance criteria

1. Runtime validation rejects malformed or unknown momentum counter definitions.
2. An unopposed Outrider contacts at tick two; a legal living Stake Line delays it to tick three.
3. Moving, disabling, or omitting the Stake Line prevents the delay before the wave starts.
4. Road Wardens and Crossbow Watch each complete all three `before_the_horn` waves without collapse for all three commanders across three fixed seeds.
5. Runner Pair visibly damages and can stop Outriders while it retains an open lane.
6. Save/load preserves effective arrival, momentum state, target state, and replay identity exactly.
7. War Council, Preparation, Battle inspection, map/timeline labels, large text, high contrast, and controller paths expose the question without hiding the fortress.
8. The all-scenario matrix expands to twelve non-overwhelming scenarios, three commanders, and three seeds: 108 viable cases and 216 uninterrupted/resumed simulations.

## Non-goals

- No freeform movement, knockback, stun stack, damage-over-time, cavalry pathfinding, or new input mode.
- No change to ordinary enemy arrival timing or signal-smoke behavior.
- No combined scenario with other P51 enemy families until the second teaching pair ships independently.
- No save-schema migration, campaign economy, human-test claim, or public-alpha approval.
